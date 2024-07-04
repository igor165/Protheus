#DEFINE GD_INSERT 1
#DEFINE GD_UPDATE 2
#DEFINE GD_DELETE 4
#INCLUDE "MATA926.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"

Static lUsaSped
Static cDocStat
Static cSerStat
Static cEspStat
Static cCliStat
Static cLojStat

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Mata926  ³ Autor ³ Mary C. Hergert       ³ Data ³ 21/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra os complementos de notas fiscais de entrada e de  ³±±
±±³          ³ saida com as informacoes necessarias ao Sped.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do documento                                ³±±
±±³          ³ ExpC2 = Serie                                              ³±±
±±³          ³ ExpC3 = Especie                                            ³±±
±±³          ³ ExpC4 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC5 = Loja                                               ³±±
±±³          ³ ExpC6 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC7 = Verifica se e devolucao ou beneficiamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata926(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,cCFOP,cItem,cTestCase)

Local aArea			:= GetArea()

Local lUsaSped 		:= cPaisLoc == "BRA"

Local lTabCDT		:= lUsaSped
Local lTabCG8		:= GetNewPar("MV_REMASRJ", .F.)
Local lTabF0A   	:= AliasInDic("F0A")

Private lCompExp	:= lUsaSped
Private lCompCD0	:= lUsaSped
Private lAnfavea	:= lUsaSped
Private lCompDoc	:= .F.
Private aHAgua		:= {}
Private aCAgua		:= {}
Private aHEner		:= {}
Private aCEner		:= {}
Private aHComun		:= {}
Private aCComun		:= {}
Private aHGas		:= {}
Private aCGas		:= {}
Private aHImp		:= {}
Private aCImp		:= {}
Private aHComb		:= {}
Private aCComb		:= {}
Private aHMed		:= {}
Private aCMed		:= {}
Private aHArma		:= {}
Private aCArma		:= {}
Private aHVeic		:= {}
Private aCVeic		:= {}
Private aHProc		:= {}
Private aCProc		:= {}
Private aHGuia		:= {}
Private aCGuia		:= {}
Private aHDoc		:= {}
Private aCDoc		:= {}
Private aHCp		:= {}
Private aCCp		:= {}
Private aHLoc		:= {}
Private aCLoc		:= {}
Private aHExp		:= {}
Private aCExp		:= {}
Private aHAnfC		:= {}
Private aCAnfC		:= {}
Private aHAnfI		:= {}
Private aCAnfI		:= {}
Private aHRes		:= {}
Private aCRes		:= {}
Private lRefresh	:= .T.
Private aNFSped		:= {cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,cCFOP}
Private aCplSped	:= {}
Private aDocRef		:= {}
Private aNfCupom	:= {}
Private aHInfc		:= {}
Private aCInfc		:= {}
Private cFormul		:= ""
Private cOpcaoFrt	:= ""
Private cOpcaoExt	:= ""
Private dDatReceb   := CtoD("  /  /    ")
Private cUfDest		:= Space(2)
Private cMDest		:= Space(5)
Private lM926VlCpNF := ExistBlock("M926VlCpNF")
Private aHRemas		:= {}
Private aCRemas		:= {}
Private aHCrdAcum	:= {}
Private aCCrdAcum	:= {}
Private aHCCF8		:= {}
Private aCCCF8		:= {}
Private lSdoc		:= TamSx3("F3_SERIE")[1] == 14

Default cCFOP		:= ""
Default cTestCase   := "MATA926TESTCASE"

Private lCmpCD0		:= 	CD0->(ColumnPos("CD0_CHVNFE"))>0 .And. CD0->(ColumnPos("CD0_ITENFE"))>0 .And. CD0->(ColumnPos("CD0_VLUNOP"))>0 .And.;
						CD0->(ColumnPos("CD0_PICMSE"))>0 .And. CD0->(ColumnPos("CD0_ALQSTE"))>0 .And. CD0->(ColumnPos("CD0_RESPRE"))>0 .And.;
						CD0->(ColumnPos("CD0_MOTRES"))>0 .And. CD0->(ColumnPos("CD0_CHNFRT"))>0 .And. CD0->(ColumnPos("CD0_PANFRT"))>0 .And.;
						CD0->(ColumnPos("CD0_SRNFRT"))>0 .And. CD0->(ColumnPos("CD0_NRNFRT"))>0 .And. CD0->(ColumnPos("CD0_ITNFRT"))>0 .And.;
						CD0->(ColumnPos("CD0_CODDA")) >0 .And. CD0->(ColumnPos("CD0_NUMDA"))>0 .And.  CD0->(ColumnPos("CD0_ID"))>0 	.And.;
						CD0->(ColumnPos("CD0_BSULMT"))>0 .And. CD0->(ColumnPos("CD0_VLUNCR"))>0
Private lCompCF8		:= AliasIndic("CF8") .And. cEntSai == 'E'.And. CF8->(ColumnPos("CF8_DOC")) >0 .And. CF8->(ColumnPos("CF8_SERIE")) >0
Private aHRastr := {}
Private aCRastr := {}
Private cOriNF  := cEntSai
Private lProcRef:= .F.

If cEntSai == 'E'
	cFormul := SF1->F1_FORMUL
Else
	cFormul := 'S'
EndIf

//Verifica se os dicionários foram atualizados para o REINF (04/2018).
If 	CDG->(FieldPos('CDG_ITEM'	)) > 0	.AND.	;
	CDG->(FieldPos('CDG_ITPROC'	)) > 0	.AND.	;
	CCF->(FieldPos('CCF_IDITEM' )) > 0	.AND.	;
	CCF->(FieldPos('CCF_TRIB'	)) > 0	.AND.	;
	CCF->(FieldPos('CCF_INDSUS'	)) > 0	.AND.	;
	CCF->(FieldPos('CCF_SUSEXI' )) > 0	.AND.	;
	CCF->(FieldPos('CCF_MONINT' )) > 0
	lProcRef := .T.
EndIf

If lProcRef
	//--Ajusta tabela CCF (Processos relacionados) para acesso via Modelo2.
	AJUSTMODL2()
	//--Ajusta tabela CDG (Processos refer. no documento) para ítens de processos relacionados.
	AJUSTITCDG()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F12                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F12 To

IF lTabCG8
	dbSelectArea("CG8")
EndIF

dbSelectArea("CFF")

IF lCompCF8
	dbSelectArea("CF8")
EndIF

If lUsaSped
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua ajustes na base das tabelas de complemento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFU")
	dbSelectArea("SFX")
	dbSelectArea("CD3")
	dbSelectArea("CD4")
	dbSelectArea("CD5")
	dbSelectArea("CD6")
	dbSelectArea("CD7")
	dbSelectArea("CD8")
	dbSelectArea("CD9")
	dbSelectArea("CDB")
	dbSelectArea("CDC")
	dbSelectArea("CDD")
	dbSelectArea("CDE")
	dbSelectArea("CDF")
	dbSelectArea("CDG")
	If lTabCDT
		dbSelectArea("CDT")
	EndIf
	If lCompExp
		dbSelectArea("CDL")
	EndIf
	If lAnfavea
		dbSelectArea("CDR")
		dbSelectArea("CDS")
	EndIf
	If lCompCD0
		dbSelectArea("CD0")
	EndIf
	If lTabF0A
		dbSelectArea("F0A")
	EndIf
	M926Tela(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,cCFOP,cItem,cTestCase)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona na tabela original antes da chamada da rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M926Tela ³ Autor ³ Mary C. Hergert       ³ Data ³ 21/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a dialog da consulta                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do documento                                ³±±
±±³          ³ ExpC2 = Serie                                              ³±±
±±³          ³ ExpC3 = Especie                                            ³±±
±±³          ³ ExpC4 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC5 = Loja                                               ³±±
±±³          ³ ExpC6 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC7 = Indica se o documento e de devol/beneficiamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Tela(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,cCFOP,cItem,cTestCase)

Local aPaineis		:= {}
Local aPnTree		:= {}
Local aCompl 		:= {}
Local aMedica		:= {}
Local aArma			:= {}
Local aVeic			:= {}
Local aCombust		:= {}
Local aEnergia		:= {}
Local aGas			:= {}
Local aAgua			:= {}
Local aComunica		:= {}
Local aAnfaveaC		:= {}
Local aAnfaveaI		:= {}
Local aMantem		:= {{},{},{},{},{},{},{},{},{},{}}  //Arrays 7 e 8 (Anfavea - Cab / Itens), 9 - Informações Complementares
Local aCoord		:= {{},{},{},{},{}}
Local aSize 		:= MsAdvSize()
Local aPnlNF		:= {}
Local aGets			:= {}
Local aSugerido		:= {}
Local aObrigat		:= {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}} //Arrays 16 e 17 (Anfavea - Cab / Itens), 18 - Informações Complementares
Local aGNRE			:= {}
Local aLocal		:= {}
Local aObjects 		:= {}
Local aPosObj		:= {}
Local aInfo			:= {}
Local aPosObj2		:= {}
Local aRessarc		:= {}
Local aImport		:= {}
Local aExport		:= {}
Local aRemas		:= {}
Local aCrdAcum 		:= {}
Local aDCCF8 		:= {}

Local cDescr		:= ""
Local cTab			:= ""

Local lRet			:= .F.
Local lGera			:= .F.
Local lValid		:= .F.
Local lExpInd		:= .F.
Local lTabCG8		:= GetNewPar("MV_REMASRJ", .F.)
Local cMvEstado		:= GetNewPar("MV_ESTADO", .F.)
Local lTabCFF		:= cMvEstado == "SP"

Local nX			:= 0
Local nTop    		:= 0
Local nLeft   		:= 0
Local nBottom 		:= 0
Local nRight  		:= 0

Local oDlg
Local oTree
Local oPanel
Local oPanel3
Local oFont			:= TFont():New("Arial",,14,,.F.)
Local oFont16		:= TFont():New("Arial",,16,,.F.)
Local oFont16b		:= TFont():New("Arial",,16,,.T.)
Local nTo			:= Iif(lCompExp,23,19)

Local lCompF0A 	:= AliasIndic("F0A")
Local aRastr	:= {}

Local aRetAuto  := {}
Local aItem		:= {"aCAgua","aCArma","aCComb","aCComun","aCEner","aCGas","aCImp","aCMed","aCVeic","aCProc","aCGuia","aCDoc","aCCp","aCLoc","aCInfc", "aCExp", "aCAnfC", "aCAnfI", "aCRes", "aCRemas", "aCCrdAcum","aCCCF8","aCRastr"}

Private T_Cargo		:= ""

Default cCFOP		:= ""
Default cTestCase   := "MATA926TESTCASE"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³-> Complementos a gerar:             ³
//³01 - Agua canalizada                 ³
//³02 - Armas de fogo                   ³
//³03 - Combustível                     ³
//³04 - Comunicacao e telecomunicacao   ³
//³05 - Energia eletrica                ³
//³06 - Gás canalizado                  ³
//³07 - Importacao                      ³
//³08 - Medicamentos                    ³
//³09 - Veiculos automotores            ³
//³->Informacoes complementares a gerar:³
//³10 - Processos                       ³
//³11 - Guias                           ³
//³12 - Documentos                      ³
//³13 - Cupons                          ³
//³14 - Locais de entrega/coleta        ³
//³15 - Exportacao                      ³
//³16 - Cabeçalho Anfavea               ³
//³17 - Itens Anfavea                   ³
//³18 - Informações Complementares      ³
//³19 - Ressarcimento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nTo

	lGera	:= .F.
	cAbre	:= "PMSEDT3"
	cFecha	:= "PMSEDT3"

	Do Case
		Case nX == 1
			cDescr	:= STR0004
			cTab	:= "CD4"
		Case nX == 2
			cDescr 	:= STR0005
			cTab	:= "CD8"
		Case nX == 3
			cDescr 	:= STR0006
			cTab	:= "CD6"
		Case nX == 4
			cDescr 	:= STR0007
			cTab	:= "SFX"
		Case nX == 5
			cDescr 	:= STR0008
			cTab	:= "SFU"
		Case nX == 6
			cDescr 	:= STR0009
			cTab   	:= "CD3"
		Case nX == 7
			cDescr 	:= STR0010
			cTab	:= "CD5"
		Case nX == 8
			cDescr 	:= STR0011
			cTab   	:= "CD7"
		Case nX == 9
			cDescr 	:= STR0012
			cTab	:= "CD9"
		Case nX == 10
			cDescr 	:= STR0050
			cTab	:= "CDG"
			lGera	:= .T.
		Case nX == 11
			cDescr 	:= STR0051
			cTab	:= "CDC"
			lGera	:= .T.
		Case nX == 12
			cDescr	:= STR0052 //"Documentos fiscais"
			cTab	:= "CDD"
		Case nX == 13
			cDescr 	:= STR0053
			cTab	:= "CDE"
		Case nX == 14
			cDescr 	:= STR0054
			cTab	:= "CDF"
		Case nX == 15
			cDescr	:= STR0071 //"Informações Complementares"
			cTab	:= "CDT"
			lGera	:= .T.
		Case nX == 16
			cDescr 	:= "Exportação"
			cTab	:= "CDL"
			lGera	:= .F.
		Case nX == 17
			cDescr 	:= "Anfavea (Cabeçalho)"
			cTab	:= "CDR"
			lGera	:= .F.
		Case nX == 18
			cDescr 	:= "Anfavea (Itens)"
			cTab	:= "CDS"
			lGera	:= .F.
		Case nX == 19
			cDescr 	:= "Compl. Ressarc."
			cTab	:= "CD0"
			If cEntSai == 'E'
				lGera	:= .F.
			Else
				lGera	:= .T.
			Endif
		Case nX == 20 .AND. lTabCG8
			cDescr	:= "REMAS-Rio de Janeiro" //"Informações Complementares"
			cTab	:= "CG8"
			lGera	:= .T.
		Case nX == 21
			cDescr	:= "Crédito Acumulado de ICMS"
			cTab	:= "CFF"
			lGera	:= .T.
		Case nX == 22
			cDescr	:= "Demais Docs. PIS COF."
			cTab	:= "CF8"
			lGera	:= .T.
		Case nX == 23
			cDescr	:= STR0079 // "Rastreabilidade"
			cTab	:= "F0A"
	EndCase

	aAdd(aCompl,{cDescr,cTab,lGera,cAbre,cFecha})
Next

FwMsgRun(,{|oSay|M926Comp(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,@aCompl,@aMedica,@aArma,@aVeic,@aCombust,@aEnergia,@aGas,@aAgua,@aComunica,@aSugerido,@aGNRE,@aNfCupom,@aDocRef,@aLocal,@lExpInd,@aAnfaveaC,@aAnfaveaI,@aRessarc,@aImport,@aRemas,@aCrdAcum,cCFOP,cItem,@aDCCF8,@aRastr,@aExport,oSay)},"Processando...")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A variavel aCplSped e private para execucao dos filtros das consultas padrao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aCplSped,aClone(aCompl))
aAdd(aCplSped,aClone(aMedica))
aAdd(aCplSped,aClone(aArma))
aAdd(aCplSped,aClone(aVeic))
aAdd(aCplSped,aClone(aCombust))
aAdd(aCplSped,aClone(aGas))
aAdd(aCplSped,aClone(aComunica))
aAdd(aCplSped,aClone(aEnergia))
aAdd(aCplSped,aClone(aAnfaveaC))
aAdd(aCplSped,aClone(aAnfaveaI))
aAdd(aCplSped,aClone(aRessarc))
aAdd(aCplSped,aClone(aImport))
aAdd(aCplSped,aClone(aRastr))

If ! IsBlind()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Resolve os objetos lateralmente                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects := {}

	AAdd( aObjects, { 72,   40, .T., .T. } )
	AAdd( aObjects, { 150,  50, .T., .T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. , .T. )
	// Painel 1 - onde sera montada a tree (fixo)
	aCoord[1] := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,3]-19,aPosObj[1,4]}
	// Painel 4 - complemento desabilitado
	aCoord[5] := {aPosObj[2,1],aPosObj[2,2]+3,aPosObj[2,3]-19,aPosObj[2,4]-163}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Resolve os objetos da parte direita                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aInfo := { aPosObj[2,2], aPosObj[2,1], aPosObj[2,4], aPosObj[2,3], 0, 0, 3, 0 }

	aObjects := {}
	AAdd( aObjects, { 162,  60, .F., .F., .F. } )
	AAdd( aObjects, { 162,  97, .F., .F., .F. } )

	aPosObj2 := MsObjSize( aInfo, aObjects, .T.)
	// Painel 2 - onde serao apresentadas as informacoes da nota fiscal a complementar (fixo)
	aCoord[2] := {aPosObj2[1,1],aPosObj2[1,2],aPosObj2[1,3]+9,aPosObj2[1,4]}
	// Painel 3 - onde serao apresentadas as informacoes complementares de cada nota fiscal (variavel)
	aCoord[3] := {aPosObj2[2,1]+17,aPosObj2[2,2],aPosObj2[2,3],aPosObj2[2,4]}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coordenadas para montagem da dialog ³
	//³Reduzindo o tamanho da dialog maxima³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTop    := aSize[7]
	nLeft   := 0
	nBottom := aSize[6]
	nRight  := aSize[5]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coordenadas para montagem dos paineis, conforme a janela principal³
	//³linha inicial, coluna inicial, linha final, coluna final          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Tree - tree com os complementos disponiveis (com base no painel 1)
	aCoord[4] := {5,5,aCoord[1][3]-5,aCoord[1][4]-5}

	DEFINE FONT oFont NAME "Arial" SIZE 0, -10

	DEFINE MSDIALOG oDlg FROM aSize[7],00 TO aSize[6],aSize[5] TITLE STR0001 OF oMainWnd PIXEL //"Complementos por documento fiscal"

	oPanel := TPanel():New(aCoord[1][1],aCoord[1][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[1][4],aCoord[1][3],.T.,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Paineis do no de complementos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanel3 := TPanel():New(aCoord[3][1]+30,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.)
	oPanel4 := TPanel():New(aCoord[2][1],aCoord[2][2],STR0055,oDlg,oFont16b,.T.,.T.,CLR_WHITE,CLR_HGRAY/*CLR_BLUE*/,aCoord[2][4],aCoord[2][3],.T.,.T.) //"Complementos por documento fiscal"
	aAdd(aPnTree,{oPanel3,1})
	aAdd(aPnTree,{oPanel4,1})
	bSay := &('{|| "' + STR0034+STR0035 + '"}') //Os complementos dos documentos fiscais de entrada e saída deverão ser informados para que seja possível a geração do Sped (Sistema Público de Escrituração Digital) Fiscal.
	TSay():New(15,15,bSay,oPanel3,,oFont16,.F.,.F.,.F.,.T.,,,330,100,.F.,.F.,.F.,.F.,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Paineis do no de informacoes complementares³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanel3 := TPanel():New(aCoord[3][1]+30,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.)
	oPanel4 := TPanel():New(aCoord[2][1],aCoord[2][2],STR0049,oDlg,oFont16b,.T.,.T.,CLR_WHITE,CLR_HGRAY/*CLR_BLUE*/,aCoord[2][4],aCoord[2][3],.T.,.T.) // "Informacoes complementares"
	aAdd(aPnTree,{oPanel3,2})
	aAdd(aPnTree,{oPanel4,2})
	bSay := &('{|| "' + STR0034+STR0035 + '"}') //Os complementos dos documentos fiscais de entrada e saída deverão ser informados para que seja possível a geração do Sped (Sistema Público de Escrituração Digital) Fiscal.
	TSay():New(15,15,bSay,oPanel3,,oFont16,.F.,.F.,.F.,.T.,,,330,100,.F.,.F.,.F.,.F.,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o tree que ira conter os complementos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree := DbTree():New(aCoord[4][1],aCoord[4][2],aCoord[4][3],aCoord[4][4],oPanel,,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nos principais - complementos e informacoes complementares³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree:AddItem(Padr(STR0003,40),"L1SFT"+StrZero(0,5,0),"FOLDER5","FOLDER6",,,1) // "Complementos"
	oTree:AddItem(Padr(STR0049,40),"L1SF3"+StrZero(0,5,0),"FOLDER5","FOLDER6",,,1) // "Informações complementares"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os subitens ao no de complementos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to 9
		oTree:TreeSeek("L1SFT"+StrZero(0,5,0))
		oTree:AddItem(aCompl[nX][1],"L2SFT"+StrZero(nX,5,0),aCompl[nX][4],aCompl[nX][5],,,2)
	Next

	If lCompExp
		oTree:TreeSeek("L1SFT"+StrZero(0,5,0))
		oTree:AddItem(aCompl[16][1],"L2SFT"+StrZero(16,5,0),aCompl[16][4],aCompl[16][5],,,2)
	EndIf

	If lAnfavea
		//Cabeçalho
		oTree:TreeSeek("L1SFT"+StrZero(0,5,0))
		oTree:AddItem(aCompl[17][1],"L2SFT"+StrZero(17,5,0),aCompl[17][4],aCompl[17][5],,,2)
		//Itens
		oTree:TreeSeek("L1SFT"+StrZero(0,5,0))
		oTree:AddItem(aCompl[18][1],"L2SFT"+StrZero(18,5,0),aCompl[18][4],aCompl[18][5],,,2)
	EndIf

	oTree:TreeSeek("L1SFT"+StrZero(0,5,0))
	oTree:AddItem(aCompl[19][1],"L2SFT"+StrZero(19,5,0),aCompl[19][4],aCompl[19][5],,,2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Adiciona Comp. Rastreabilidade  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lCompF0A
		oTree:TreeSeek("L1SFT"+StrZero(0,5,0))
		oTree:AddItem(aCompl[23][1],"L2SFT"+StrZero(23,5,0),aCompl[23][4],aCompl[23][5],,,2)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Muda as propriedades do no de complementos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree:TreeSeek("L1SFT"+StrZero(0,5,0))
	oTree:lShowHint := .F.
	oTree:bChange   := {|| M926ShHi(oTree,aPaineis,aPnTree,aPnlNF)}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os subitens ao no de informacoes complementares³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 10 to 15
		oTree:TreeSeek("L1SF3"+StrZero(0,5,0))
		oTree:AddItem(aCompl[nX][1],"L2SF3"+StrZero(nX,5,0),"PMSEDT3","PMSEDT3",,,2)
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os REMAS do Rio de Janeiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTabCG8
		oTree:TreeSeek("L1SF3"+StrZero(0,5,0))
		oTree:AddItem(aCompl[20][1],"L2SF3"+StrZero(20,5,0),"PMSEDT3","PMSEDT3",,,2)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adic. compl C´redito Acumulado ICMS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTabCFF
		oTree:TreeSeek("L1SF3"+StrZero(0,5,0))
		oTree:AddItem(aCompl[21][1],"L2SF3"+StrZero(21,5,0),"PMSEDT3","PMSEDT3",,,2)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Adiciona Demais Docs. PIS COF.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lCompCF8
		oTree:TreeSeek("L1SF3"+StrZero(0,5,0))
		oTree:AddItem(aCompl[22][1],"L2SF3"+StrZero(22,5,0),"PMSEDT3","PMSEDT3",,,2)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Muda as propriedades do no de informacoes complementares ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree:TreeSeek("L1SF3"+StrZero(0,5,0))
	oTree:lShowHint := .F.
	oTree:bLClicked := {|| M926ShHi(oTree,aPaineis,aPnTree,aPnlNF)}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Vai para o inicio da arvore e fecha os nos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree:TreeSeek("L1SFT"+StrZero(0,5,0))

	M926Obj(oTree,@aPaineis,aCompl,oDlg,aCoord,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aPnTree,@aPnlNF,aGets,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aComunica,@aObrigat,@aMantem,aGNRE,aNfCupom,aDocRef,aLocal,aAgua,lExpInd,aAnfaveaC,aAnfaveaI,aRessarc,aImport,aRemas,aCrdAcum,aDCCF8,aRastr,aExport)

		ACTIVATE MSDIALOG oDlg ON INIT ;
		EnchoiceBar(oDlg,{|| lValid := M926Valid(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCompl,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aAgua,aComunica,aMantem,aGets,aSugerido,aObrigat,aGNRE,aNfCupom,aDocRef,aLocal,aAnfaveaC,aAnfaveaI,aRessarc,oTree,cItem,aRastr),;
		Iif(lValid,FwMsgRun(,{|oSay|lRet := M926Fim(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCompl,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aAgua,aComunica,aMantem,aGets,aSugerido,aObrigat,aGNRE,aNfCupom,aDocRef,aLocal,aAnfaveaC,aAnfaveaI,aRessarc,cItem,oSay)},"Gravando..."),.F.),;
		Iif(lRet,oDlg:End(),.T.)},;
		{||oDlg:End()})
Else
	//-- Tratamento para Automação dos Cenários
	If FindFunction("GetParAuto")
		aRetAuto := GetParAuto(cTestCase)
		If !Empty(aRetAuto)
			M926Cols(aCompl,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aComunica,@aObrigat,@aMantem,aGNRE,aNfCupom,aDocRef,aLocal,aAgua,lExpInd,aAnfaveaC,aAnfaveaI,aRessarc,aImport,aRemas,aCrdAcum,aDCCF8,aRastr,@aExport,)
			For nX := 1 to Len(aRetAuto)
				&(aItem[aRetAuto[nX,1]]) := aClone(aRetAuto[nX,2])
			Next nX
			M926Fim(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCompl,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aAgua,aComunica,aMantem,aGets,aSugerido,aObrigat,aGNRE,aNfCupom,aDocRef,aLocal,aAnfaveaC,aAnfaveaI,aRessarc,cItem,)
		EndIf
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M926Obj  ³ Autor ³ Mary C. Hergert       ³ Data ³ 21/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os objetos de preenchimento de cada tipo de comple-  ³±±
±±³          ³ mento.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Tree com todos os complementos                     ³±±
±±³          ³ ExpA2 = Array com os paineis de cada complemento           ³±±
±±³          ³ ExpA3 = Array com os complementos que serao gerados        ³±±
±±³          ³ ExpO4 = Objeto com a dialog dos complementos               ³±±
±±³          ³ ExpA5 = Array com as coordenadas dos paineis da tela       ³±±
±±³          ³ ExpC7 = Numero do documento                                ³±±
±±³          ³ ExpC8 = Serie                                              ³±±
±±³          ³ ExpC9 = Especie                                            ³±±
±±³          ³ ExpCA = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpCB = Loja                                               ³±±
±±³          ³ ExpCC = Tipo - entrada / saida                             ³±±
±±³          ³ ExpCD = Verifica se e devolucao ou beneficiamento          ³±±
±±³          ³ ExpAE = Painel principal                                   ³±±
±±³          ³ ExpAD = Painel com os dados da NF                          ³±±
±±³          ³ ExpAF = Array contendo todas as getdados da tela           ³±±
±±³          ³ ExpAG = Itens da NF do grupo medicamentos                  ³±±
±±³          ³ ExpAH = Itens da NF do grupo armas de fogo                 ³±±
±±³          ³ ExpAI = Itens da NF do grupo veiculos automotores          ³±±
±±³          ³ ExpAJ = Itens da NF do grupo combustiveis                  ³±±
±±³          ³ ExpAK = Itens da NF de energia eletrica                    ³±±
±±³          ³ ExpAL = Itens da NF de gas canalizado                      ³±±
±±³          ³ ExpAM = Itens da NF de agua canalizada                     ³±±
±±³          ³ ExpAN = Itens da NF de comunicacao/telecomunicacao         ³±±
±±³          ³ ExpA0 = Array com os documentos de importacao              ³±±
±±³          ³ ExpAQ = Array com as guias de recolhimento referenciadas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhuma                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Obj(oTree,aPaineis,aCompl,oDlg,aCoord,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aPnTree,aPnlNF,aGets,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aComunica,aObrigat,aMantem,aGNRE,aNfCupom,aDocRef,aLocal,aAgua,lExpInd,aAnfaveaC,aAnfaveaI,aRessarc,aImport,aRemas,aCrdAcum,aDCCF8,aRastr,aExport)

Local nX			:= 0
Local nAltSay		:= 10
Local nTamSay		:= 50
Local nAltGet		:= 10
Local nPainel		:= 0
Local nCorDisab		:= CLR_HGRAY
Local nG1			:= 25
Local nG2			:= 05
Local nG3			:= 05
Local nP1			:= 36
Local nP2			:= 10
Local nP3			:= 15
Local nSoma			:= 22
Local oObjFoc
Local oFont			:= TFont():New("Arial",,14,,.F.)
Local oFontB		:= TFont():New("Arial",,14,,.T.)
Local oGrpAg
Local oGrpEn
Local oGrpCom
Local oGrpGas
Local oGrpImp
Local oGrpComb
Local oGrpMed
Local oGrpAr
Local oGrpVei
Local oGetAg
Local oGetEn
Local oGetCom
Local oGetGas
Local oGetImp
Local oGetComb
Local oGetMed
Local oGetAr
Local oGetVei
Local oGrpProc
Local oGetProc
Local oGetGuia
Local oGrpDoc
Local oGetDoc
Local oGrpCp
Local oGetCp
Local oGrpLoc
Local oGetLoc
Local oGrpExp
Local oGetExp
Local oGrpAnfC
Local oGetAnfC
Local oGrpAnfI
Local oGetAnfI
Local oGetInfc
Local oGrpInfc
Local oGetRes
Local oGrpRes
Local oGetRemas
Local oGrpRemas
Local oGetCrdAcu
Local oGrpCrdAcu
Local oGetCF8
Local oGrpCF8
Local oGrpRastr
Local oGetRastr
Local cMenPrcRef:= ''
Local lCodMun := CDT->(FieldPos('CDT_UFDEST')) > 0 .and. CDT->(FieldPos('CDT_MDEST')) > 0 .and. cEntSai == "S" .And. aModNot(cEspecie) $ "06|28|29|66" //Segundo o Layout do SpedFiscal, essas informações devem ser preenchidas somente para NFs de saída dos modelos de nota relacionados.

//Monta mensagem de alerta referete ao REINF
cMenPrcRef := STR0091 + CRLF
cMenPrcRef += STR0092 + CRLF
cMenPrcRef += STR0093 + CRLF
cMenPrcRef += STR0094 + CRLF
cMenPrcRef += STR0095

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Cabeçalho padrao para todos os complementos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M926NF(oFont,nAltSay,nTamSay,nAltGet,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCoord,@aPnlNF,oDlg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objeto para manter o foco da janela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjFoc := TGet():New(1000000000,1000000000,,oTree,1,1,,,,,,,,.T.,,,,,,,,,)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o aCols e o aHeader dos complementos e das informacoes complementares ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FwMsgRun(,{|oSay|M926Cols(aCompl,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aComunica,@aObrigat,@aMantem,aGNRE,aNfCupom,aDocRef,aLocal,aAgua,lExpInd,aAnfaveaC,aAnfaveaI,aRessarc,aImport,aRemas,aCrdAcum,aDCCF8,aRastr,@aExport,oSay)},"Processando...")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GETDADOS DOS COMPLEMENTOS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aCompl)

	Do Case

		Case nX == 1

			// agua canalizada - por nota fiscal
			If aCompl[nX][03]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpAg	:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0040,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - água canalizada"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetAg := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpAg,aHAgua,aCAgua)
				oGetAg:bLinhaOk := &("{|| M926Ag(oGetAg,aObrigat) }")

			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0025,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de água canalizada"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 2

			// arma de fogo
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpAr	:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0041,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - armas de fogo"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetAr := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpAr,aHArma,aCArma)
				oGetAr:bLinhaOk := &("{|| M926Arma(oGetAr,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.F.,aArma) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0026,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de operações com armas de fogo"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 3

			// combustivel
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpComb:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0042,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - combustíveis"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetComb := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpComb,aHComb,aCComb)
				oGetComb:bLinhaOk := &("{|| M926Comb(oGetComb,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.F.,aCombust) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0027,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de operações com combustíveis"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 4

			// comunicacao/telecomunicacao
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpCom	:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0043,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - comunicação/telecomunicação"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetCom := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpCom,aHComun,aCComun)
				oGetCom:bLinhaOk := &("{|| M926Tele(oGetCom,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.F.) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0028,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de serviços de comunicação e telecomunicação"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 5

			// energia eletrica
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpEn	:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0044,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - energia elétrica"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetEn := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpEn,aHEner,aCEner)
				oGetEn:bLinhaOk := &("{|| M926Ener(oGetEn,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.F.) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0029,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de consumo ou fornecimento de energia elétrica"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 6

			// gas canalizado
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpGas := TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0045,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - gás canalizado"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetGas := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpGas,aHGas,aCGas)
				oGetGas:bLinhaOk := &("{|| M926Gas(oGetGas,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.F.) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0030,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de consumo ou fornecimento de gás canalizado"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 7

			// importacao - por nota fiscal
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpImp	:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0046,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - importações"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetImp := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpImp,aHImp,aCImp)
				oGetImp:bLinhaOk := &("{|| M926Imp(oGetImp,aObrigat,.F.) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0031,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de operações de importação"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 8

			// medicamentos
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpMed	:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0047,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - medicamentos"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetMed := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpMed,aHMed,aCMed)
				oGetMed:bLinhaOk := &("{|| M926Med(oGetMed,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.F.,aMedica) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0032,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de operações com medicamentos"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 9

			// veiculos
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpVei := TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0048,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - veículos automotores"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetVei := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpVei,aHVeic,aCVeic)
				oGetVei:bLinhaOk := &("{|| M926Veic(oGetVei,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.F.,aVeic) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0033,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de operações com veículos automotores"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 10

			// Processos referenciados
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o painel onde serao inseridas as informacoes do complemento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lProcRef
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
				nPainel	:= Len(aPaineis)
				oGrpProc:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0056,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - processos referenciados"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetProc := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpProc,aHProc,aCProc)
				oGetProc:bLinhaOk := &("{|| M926Proc(oGetProc,aObrigat,.F.) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],cMenPrcRef,oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
			EndIf

		Case nX == 11

			// Guias de recolhimento referenciadas
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o painel onde serao inseridas as informacoes do complemento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
			nPainel	:= Len(aPaineis)
			oGrpGuia:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0057,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - Guias de recolhimento referenciadas"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a Getdados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGetGuia := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpGuia,aHGuia,aCGuia)
			oGetGuia:bLinhaOk := &("{|| M926Guia(oGetGuia,aObrigat,.F.) }")

		Case nX == 12

			// Documentos fiscais referenciados
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
				nPainel	:= Len(aPaineis)
				oGrpDoc:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0058,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - Documentos fiscais referenciados"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetDoc := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpDoc,aHDoc,aCDoc)
				oGetDoc:bLinhaOk := &("{|| M926Doc(oGetDoc,aObrigat,.F.,aDocRef,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF) }")

			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0063,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),2}) //"Este documento fiscal não possui outros documentos referenciados"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 13

			// Cupons fiscais referenciados
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1],aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
				nPainel	:= Len(aPaineis)
				oGrpCp:= TGroup():New(nG1,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0059,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - Cupons fiscais referenciados"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetCp := MsNewGetDados():New(nP1,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpCp,aHCp,aCCp)
				oGetCp:bLinhaOk := &("{|| M926Cup(oGetCp,aObrigat,.F.,aNfCupom) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0061,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),2}) //"Este documento fiscal não possui cupom fiscal referenciado"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 14

			// Local da coleta e entrega
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4]-5,aCoord[3][3],.T.,.T.),2})
				nPainel	:= Len(aPaineis)
				oGrpLoc:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0060,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - Local de coleta e entrega"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Nao e permitido inserir novos itens porque somente deve haver 1 local de coleta/entrega por documento
				oGetLoc := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpLoc,aHLoc,aCLoc)
				oGetLoc:bLinhaOk := &("{|| M926Loc(oGetLoc,aObrigat,.F.,aLocal) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0062,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),2}) //"Este documento fiscal não possui cliente de entrega"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 15

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o painel onde serao inseridas as informacoes do complemento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M926NF(oFont,nAltSay,nTamSay,nAltGet,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCoord,@aPnlNF,oDlg,.T.,.T.,.T.,lCodMun)

			aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
			nPainel	:= Len(aPaineis)
			oGrpInfc:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0072,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - Informaçoes Complementares"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a Getdados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGetInfc := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpInfc,aHInfc,aCInfc)
			oGetInfc:bLinhaOk := &("{|| M926Infc(oGetInfc,aObrigat,.F.) }")

		Case nX == 16 .And. lCompExp

			// Exportacao - por nota fiscal
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpExp	:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0096,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - exportações"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetExp := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpExp,aHExp,aCExp)
				oGetExp:bLinhaOk := &("{|| M926Exp(oGetExp,aObrigat,.F.) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0097,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este tipo de documento fiscal não possui complemento de exportação"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 17 .And. lAnfavea

			// Anfavea - por Cabeçalho de nota fiscal
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento Cabeçalho ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpAnfC:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,"Informações complementares - Anfavea (Cabeçalho)",aPaineis[nPainel][1],,,.T.,.T.)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetAnfC := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpAnfC,aHAnfC,aCAnfC)
				oGetAnfC:bLinhaOk := &("{|| M926AnfC(oGetAnfC,aObrigat,.F.) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],"Este tipo de documento fiscal não possui complemento Anfavea (Cabeçalho)",oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 18 .And. lAnfavea

			// Anfavea - por Itens de nota fiscal
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento itens     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpAnfI:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,"Informações complementares - Anfavea (Itens)",aPaineis[nPainel][1],,,.T.,.T.)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetAnfI := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpAnfI,aHAnfI,aCAnfI)
				oGetAnfI:bLinhaOk := &("{|| M926AnfI(oGetAnfI,aObrigat,.F.) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],"Este tipo de documento fiscal não possui complemento Anfavea (Itens)",oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 19

			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpRes	:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,"Complemento - Ressarcimento",aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - água canalizada"
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetRes := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpRes,aHRes,aCRes)
				oGetRes:bLinhaOk := &("{|| M926Res(oGetRes,aObrigat) }")

			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],"Este tipo de documento fiscal não possui complemento de Ressarcimento",oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 20

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o painel onde serao inseridas as informacoes do REMAS do Município do Rio de Janeiro³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// REMAS
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
				nPainel	:= Len(aPaineis)
				oGrpRemas:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,"Remas Rio de Janeiro",aPaineis[nPainel][1],,,.T.,.T.) //"REMAS Rio de Janeiro"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Nao e permitido inserir novos itens porque somente deve haver 1 local de coleta/entrega por documento
				oGetRemas := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpRemas,aHRemas,aCRemas)
				//oGetRemas:bLinhaOk := &("{|| M926Loc(oGetRemas,aObrigat,.F.,aLocal) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],"Sem informações para REMAS",oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),2}) //"Este documento fiscal não possui cliente de entrega"
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 21

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o painel onde serao inseridas as informacoes ref. a crédito acumulado de ICMS-CAT207      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
				nPainel	:= Len(aPaineis)
				oGrpCrdAcu	:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,"Crédito Acumulado - ICMS",aPaineis[nPainel][1],,,.T.,.T.) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetCrdAcu := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_DELETE+GD_UPDATE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpCrdAcu,aHCrdAcum,aCCrdAcum)
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],"Sem Informações para Crédito Acumulado",oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) 
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 22

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o painel onde serao inseridas as informacoes ref. a crédito acumulado de ICMS-CAT207      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),2})
				nPainel	:= Len(aPaineis)
				oGrpCF8	:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,"Demais Docs. PIS COF.",aPaineis[nPainel][1],,,.T.,.T.) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetCF8 := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_DELETE,/*LinhaOk*/,/*GetdadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpCF8,aHCCF8,aCCCF8)  				  

			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],"Demais Docs. PIS COF.",oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) 
				nPainel	:= Len(aPaineis)
			Endif

		Case nX == 23

			// Rastreabilidade
			If aCompl[nX][03]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o painel onde serao inseridas as informacoes do complemento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPaineis,{TPanel():New(aCoord[3][1]+nSoma,aCoord[3][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[3][4],aCoord[3][3],.T.,.T.),1})
				nPainel	:= Len(aPaineis)
				oGrpRastr	:= TGroup():New(nG3,nG2,aCoord[3][3]-5,aCoord[3][4]-5,STR0080,aPaineis[nPainel][1],,,.T.,.T.) //"Informações complementares - Rastreabilidade"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a Getdados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetRastr := MsNewGetDados():New(nP3,nP2,aCoord[3][3]-10,aCoord[3][4]-10,GD_INSERT+GD_UPDATE+GD_DELETE,/*LinhaOk*/,/*GetDadosOk*/,/*cIniPos*/,/*aAlter*/,/*.F.*/,990,/*cAmpoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oGrpRastr,aHRastr,aCRastr)
				oGetRastr:bLinhaOk := &("{|| M926Rastr(oGetRastr,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.F.,aRastr) }")
			Else
				aAdd(aPaineis,{TPanel():New(aCoord[5][1],aCoord[5][2],STR0081,oDlg,oFontB,.T.,.T.,,nCorDisab,aCoord[5][4],aCoord[5][3],.T.,.T.),1}) //"Este documento fiscal não possui itens com complemento de Rastreabilidade"
				nPainel	:= Len(aPaineis)
			Endif
	EndCase
Next

aGets := {oGetAg,oGetAr,oGetComb,oGetCom,oGetEn,oGetGas,oGetImp,oGetMed,oGetVei,oGetProc,oGetGuia,oGetDoc,oGetCp,oGetLoc,oGetInfc,oGetExp,oGetAnfC,oGetAnfI,oGetRes,oGetRemas,oGetCrdAcu,oGetCF8,oGetRastr}

M926ShHi(oTree,aPaineis,aPnTree,aPnlNF)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M926ShHi ³ Autor ³ Mary C. Hergert       ³ Data ³ 21/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita/desabilita o painel de acordo com cada complemento³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Tree com todos os complementos                     ³±±
±±³          ³ ExpA2 = Array com os paineis de cada complemento           ³±±
±±³          ³ ExpA3 = Painel principal                                   ³±±
±±³          ³ ExpA3 = Painel com os dados da NF                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926ShHi(oTree,aPaineis,aPnTree,aPnlNF)

Local cLevel	:= SubStr(oTree:GetCargo(),1,2)
Local cNo		:= SubStr(oTree:GetCargo(),3,3)

Local nCargo	:= Val(SubStr(oTree:GetCargo(),6,5))
Local nI		:= 0
Local nY		:= 0
Local nNo		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica em qual no o foco esta posicionado:³
//³nNo == 1 -> complementos                    ³
//³nNo == 2 -> informacoes complementares      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ("SFT"$cNo)
	nNo := 1
Else
	nNo := 2
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe o painel onde o foco esta posicionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !("L1"$cLevel)
	For nY := 1 to Len(aPnTree)
		aPnTree[nY][1]:Hide()
	Next
	For nY := 1 to Len(aPnlNF)
		aPnlNF[nY]:Show()
	Next
Endif

For nI := 1 To Len(aPaineis)
	If (nI==nCargo) .And. ("L2"$cLevel)
		If nNo == aPaineis[nI][2]
			aPaineis[nI][1]:Show()
		Else
			aPaineis[nI][1]:Hide()
		Endif
	Else
		aPaineis[nI][1]:Hide()
	Endif
Next

If ("L1"$cLevel)
	For nY := 1 to Len(aPnTree)
		If nNo == aPnTree[nY][2]
			aPnTree[nY][1]:Show()
		Else
			aPnTree[nY][1]:Hide()
		Endif
	Next
	For nY := 1 to Len(aPnlNF)
		aPnlNF[nY]:Hide()
	Next
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M926Comp ³ Autor ³ Mary C. Hergert       ³ Data ³ 21/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica quais complementos a nota fiscal selecionada      ³±±
±±³          ³ devera gerar, verificando:                                 ³±±
±±³          ³ - especie da NF (para notas fiscais de energia eletrica,   ³±±
±±³          ³   gas, agua e comunicacao/telecomunicacao                  ³±±
±±³          ³ - cliente/fornecedor (para importacao)                     ³±±
±±³          ³ - grupo do produto (para medicamentos, armas de fogo,      ³±±
±±³          ³   veiculos e combustiveis)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do documento                                ³±±
±±³          ³ ExpC2 = Serie                                              ³±±
±±³          ³ ExpC3 = Especie                                            ³±±
±±³          ³ ExpC4 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC5 = Loja                                               ³±±
±±³          ³ ExpC6 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC7 = Indica se o documento e de devolucao/beneficia.    ³±±
±±³          ³ ExpA8 = Complementos a serem gerados                       ³±±
±±³          ³ ExpA9 = Itens da NF do grupo medicamentos                  ³±±
±±³          ³ ExpAA = Itens da NF do grupo armas de fogo                 ³±±
±±³          ³ Exp1B = Itens da NF do grupo veiculos automotores          ³±±
±±³          ³ Exp1C = Itens da NF do grupo combustiveis                  ³±±
±±³          ³ Exp1D = Itens da NF de energia eletrica                    ³±±
±±³          ³ Exp1E = Itens da NF de gas canalizado                      ³±±
±±³          ³ Exp1F = Itens da NF de agua canalizada                     ³±±
±±³          ³ Exp1G = Itens da NF de comunicacao/telecomunicacao         ³±±
±±³          ³ Exp1H = Complementos sugeridos pelo sistema (log)          ³±±
±±³          ³ Exp1I = Array com as guias de recolhimento referenciadas   ³±±
±±³          ³ Exp1J = Array com os cupons fiscais referenciados          ³±±
±±³          ³ Exp1K = Array com os documentos referenciados              ³±±
±±³          ³ Exp1L = Array com os locais de coleta/entrega              ³±±
±±³          ³ Exp1M = Itens da NF da Anfavea Cabecalho                   ³±±
±±³          ³ Exp1N = Itens da NF da Anfavea Itens                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 = Indica se a NF possui complementos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Comp(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCompl,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aAgua,aComunica,aSugerido,aGNRE,aNfCupom,aDocRef,aLocal,lExpInd,aAnfaveaC,aAnfaveaI,aRessarc,aImport,aRemas,aCrdAcum,cCFOP,cItem,aDCCF8,aRastr,aExport,oSay)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Complementos a serem gerados:     ³
//³01 - Agua canalizada              ³
//³02 - Armas de fogo                ³
//³03 - Combustível                  ³
//³04 - Comunicacao e telecomunicacao³
//³05 - Energia eletrica             ³
//³06 - Gás canalizado               ³
//³07 - Importacao                   ³
//³08 - Medicamentos                 ³
//³09 - Veiculos automotores         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aArea		:= GetArea()
Local aAuxGuia	:= {}

Local cModelo 	:= ""
Local cTpcli	:= ""
Local cMVMedica	:= ""
Local cMVArmFog	:= Alltrim(SuperGetMv("MV_ARMFOG"))	//Grupos de produtos separados por "/" que identifica Armas de Fogo
Local cMVVeicNv	:= Alltrim(SuperGetMv("MV_VEICNV"))	//Grupos de produtos separados por "/" que identifica Veiculos Novos
Local cMVCombus	:= Alltrim(SuperGetMv("MV_COMBUS"))	//Grupos de produtos separados por "/" que identifica Combustiveis
Local cMVAnfavea:= Alltrim(SuperGetMv("MV_ANFAVEA",,""))//Grupos de produtos separados por "/" que identifica ANFAVEA
Local cAliasSB1	:= "SB1"
Local cAliasSFT	:= "SFT"
Local cAliasSD1	:= "SD1"
Local cAlsD1Imp	:= "SD1"
Local cAliasSD2	:= "SD2"
Local cAliasSF1	:= "SF1"
Local cAliasSF2	:= "SF2"
Local cVerGrup	:= Alltrim(cMVMedica) + Alltrim(cMVArmFog) + Alltrim(cMVVeicNv) + Alltrim(cMVCombus) + Alltrim(cMVAnfavea)
Local cComp		:= ""
Local cCupom 	:= ""
Local cSerCup	:= ""

Local lVerifica	:= .T.
Local lQuery	:= .F.

Local nPos		:= 0
Local nPos2		:= 0
Local nX		:= 0

#IFDEF TOP
	Local cGrpAux	:= ""
	Local cBranco	:= "%''%"
#ELSE
	Local cGrupos	:= Alltrim(cMVMedica) + "/" + Alltrim(cMVArmFog) + "/" + Alltrim(cMVVeicNv) + "/" + Alltrim(cMVCombus) + "/" + Alltrim(cMVAnfavea)
	Local cArqInd	:= ""
	Local cChave	:= ""
	Local cCondicao	:= ""
#ENDIF

Local dDataFabric	:= CtoD("  /  /    ")
Local dDataValid	:= CtoD("  /  /    ")
Local nPrcMax		:= 0
Local lAchouSF2		:= .F.
Local lAchouSF1		:= .F.
Local cGrpRasNFE	:= ""
Local nTamDoc		:= 9
Local nTamSer		:= 3
Local lObjSay		:= Type("oSay") != "U"
Local lCDDTMov		:= CDD->(FieldPos('CDD_ENTSAI')) > 0

Default cCFOP		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|cMVMedica - Grupos de produtos separados por "/" que identifica Medicamentos|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMVMedica := GetParam("MV_MEDIC")

// Grupos de Produtos que devem gerar o Grupo I80 - Rastreabilidade na NF-e
// Estes grupos sao informados na tabela generica T0 para evitar a criacao
// de "n" parametros sequenciais.
cGrpRasNFE := GetTable("T0")

cVerGrup := Alltrim(cMVMedica) + Alltrim(cMVArmFog) + Alltrim(cMVVeicNv) + Alltrim(cMVCombus) + Alltrim(cMVAnfavea) + AllTrim(cGrpRasNFE)
#IFDEF TOP
#ELSE
	cGrupos	:= Alltrim(cMVMedica) + "/" + Alltrim(cMVArmFog) + "/" + Alltrim(cMVVeicNv) + "/" + Alltrim(cMVCombus) + "/" + Alltrim(cMVAnfavea) + "/" + AllTrim(cGrpRasNFE)
#ENDIF

If lObjSay
	oSay:cCaption := (STR0064) //"Complementos por espécie"
EndIf
ProcessMessages()

dbSelectArea("SFT")
SFT->(dbSetOrder(1))

dbSelectArea("SB1")
SB1->(dbSetOrder(1))

dbSelectArea("SF1")
SF1->(dbSetOrder(1))

dbSelectArea("SF2")
SF2->(dbSetOrder(1))

dbSelectArea("SA1")
SA1->(dbSetOrder(1))

dbSelectArea("SA2")
SA2->(dbSetOrder(1))

dbSelectArea("SD1")
SD1->(dbSetOrder(1))

dbSelectArea("SD2")
SD2->(dbSetOrder(1))

dbSelectArea("SF6")
SF6->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica pela especie da nota fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cModelo := aModNot(cEspecie)

lEnergia := ((Alltrim(cModelo)$"01/55") .And. SubStr(Alltrim(cCFOP),1,3)$"525/625")

If cModelo $ "06|66" .Or. lEnergia
	// Energia Eletrica
	aCompl[05][03]	:= .T.
	lVerifica 		:= .F.
ElseIf cModelo == "21"
	// Telecomunicacao
	aCompl[04][03]	:= .T.
	lVerifica 		:= .F.
ElseIf cModelo == "22"
	// Comunicacao
	aCompl[04][03]	:= .T.
	lVerifica 		:= .F.
ElseIf cModelo == "28"
	// Gas Canalizado
	aCompl[06][03]	:= .T.
	lVerifica 		:= .F.
ElseIf cModelo == "29"
	// Agua Canalizada
	aCompl[01][03]	:= .T.
	lVerifica 		:= .F.
Endif

If lVerifica

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica pelo cliente/fornecedor -  importacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEntSai == "E"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona cliente/fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpNF $ "DB"
			SA1->(dbSeek(xFilial("SA1")+cClieFor+cLoja))
			cTpCli := SA1->A1_TIPO
		Else
			SA2->(dbSeek(xFilial("SA2")+cClieFor+cLoja))
			cTpCli := SA2->A2_TIPO
		Endif

		If cTpCli == "X" .And. !Alltrim(cCFOP)$"1663/1664/2663/2664"
			// Importacao
			aCompl[07][03]	:= .T.
		Endif

	Else
		lExpInd := A926ExpInd(cDoc,cSerie,cClieFor,cLoja)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona cliente/fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpNF $ "DB"
			SA2->(dbSeek(xFilial("SA2")+cClieFor+cLoja))
			cTpCli := SA2->A2_TIPO
		Else
			SA1->(dbSeek(xFilial("SA1")+cClieFor+cLoja))
			cTpCli := SA1->A1_TIPO
		Endif

		If (cTpCli == "X" .Or. lExpInd) .And. lCompExp .And. !Alltrim(cCFOP)$"5663/5664/5665/5666/6663/6664/6665/6666"
			// Exportacao
			aCompl[16][03]	:= .T.
		Endif
	Endif

Endif

If lVerifica .And. !Empty(cVerGrup)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica pelo grupo de produtos dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP

		If TcSrvType()<>"AS/400"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a expressao para o select dos grupos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Medicamentos
			If !Empty(cMVMedica) .And. Right(cMVMedica,1) <> "/"
				cMVMedica := cMVMedica + "/"
			Endif
			// Armas
			If !Empty(cMVArmFog) .And. Right(cMVArmFog,1) <> "/"
				cMVArmFog := cMVArmFog + "/"
			Endif
			// Veiculos
			If !Empty(cMVVeicNv) .And. Right(cMVVeicNv,1) <> "/"
				cMVVeicNv := cMVVeicNv + "/"
			Endif
			// Combustivel
			If !Empty(cMVCombus) .And. Right(cMVCombus,1) <> "/"
				cMVCombus := cMVCombus + "/"
			Endif
			// Anfavea
			If !Empty(cMVAnfavea) .And. Right(cMVAnfavea,1) <> "/"
				cMVAnfavea := cMVAnfavea + "/"
			Endif
			// Rastreabilidade
			If !Empty(cGrpRasNFE) .And. Right(cGrpRasNFE,1) <> "/"
				cGrpRasNFE := cGrpRasNFE + "/"
			EndIf
			cGrpAux := cMVMedica + cMVArmFog + cMVVeicNv + cMVCombus + cMVAnfavea + cGrpRasNFE
			cGrpAux := StrTran(cGrpAux,"/",",")
			cGrpAux	:= Alltrim(cGrpAux)
			If Right(cGrpAux,1) == ","
				cGrpAux := SubStr(cGrpAux,1,Len(cGrpAux)-1)
			Endif
			cGrpAux := StrTran(cGrpAux,",","','")
			cGrpAux := "'" + cGrpAux + "'"
			cGrpAux := "(" + cGrpAux + ")"
			cGrpAux := "%" + cGrpAux + "%"

			lQuery 		:= .T.
			cAliasSFT	:= GetNextAlias()
			cAliasSB1	:= cAliasSFT

			BeginSql Alias cAliasSFT

				SELECT SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR,SFT.FT_LOJA,
					SFT.FT_ESPECIE,SFT.FT_TIPOMOV,SFT.FT_ITEM,SFT.FT_PRODUTO,SFT.FT_QUANT,SB1.B1_GRUPO,SB1.B1_UM,
					SB1.B1_PESO, SB1.B1_CODEMB, SB1.B1_PESBRU, SB1.B1_REFBAS, SB1.B1_TPPROD


				FROM %table:SFT% SFT, %table:SB1% SB1

				WHERE SFT.FT_FILIAL = %xFilial:SFT% AND
					SFT.FT_NFISCAL = %Exp:cDoc% AND
					SFT.FT_SERIE = %Exp:cSerie% AND
					SFT.FT_CLIEFOR = %Exp:cClieFor% AND
					SFT.FT_LOJA = %Exp:cLoja% AND
					SFT.FT_TIPOMOV = %Exp:cEntSai% AND
					SFT.%NotDel% AND
					SB1.B1_FILIAL = %xFilial:SB1% AND
					SB1.B1_COD = SFT.FT_PRODUTO AND
					SB1.B1_GRUPO IN %Exp:cGrpAux% AND
					SB1.%NotDel%

				ORDER BY %Order:SFT%
			EndSql

			dbSelectArea(cAliasSFT)

		Else

	#ENDIF
			cArqInd   := CriaTrab(Nil,.F.)
			cChave    := SFT->(IndexKey())
			cCondicao := 'FT_FILIAL == "' + xFilial("SFT") + '" .AND. '
			cCondicao += 'FT_NFISCAL == "' + cDoc + '" .AND. '
			cCondicao += 'FT_SERIE == "' + cSerie + '" .AND. '
			cCondicao += 'FT_CLIEFOR == "' + cClieFor + '" .AND. '
			cCondicao += 'FT_LOJA == "' + cLoja + '" .AND. '
			cCondicao += 'FT_TIPOMOV == "' + cEntSai + '"'
			IndRegua(cAliasSFT,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAliasSFT)->(dbGotop())
	#IFDEF TOP
		Endif
	#ENDIF

	If lObjSay
		oSay:cCaption := (STR0065) //"Complementos por grupo de produto"
	EndIf
	ProcessMessages()

	Do While !((cAliasSFT)->(Eof()))

		If !lQuery
			If !(cAliasSB1)->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
				(cAliasSFT)->(dbSkip())
				Loop
			Endif
			If !(cAliasSB1)->B1_GRUPO $ cGrupos
				(cAliasSFT)->(dbSkip())
				Loop
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Medicamentos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim((cAliasSB1)->B1_GRUPO) $ cMVMedica
			SD1->(DbSeek(xFilial("SD1")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))
			SB8->(DbSetOrder(4))
			SB8->(DbSeek(xFilial("SB8")+SD1->D1_LOTEFOR+SD1->D1_COD+SD1->D1_LOCAL))
			If !Empty(DTOS(SB8->B8_DFABRIC))
				dDataFabric	:= SB8->B8_DFABRIC
			Else
				dDataFabric	:= SD1->D1_DFABRIC
			EndIf

			If  !Empty(DTOS(SB8->B8_DTVALID))
				dDataValid := SB8->B8_DTVALID
			Else
				dDataValid := SD1->D1_DTVALID
			EndIf

			If (cAliasSFT)->FT_TIPOMOV == 'S'
				SD2->(DbSetOrder(3))
				SD2->(DbSeek(xFilial("SD2")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))
				SB8->(DbSetOrder(1))
				SB8->(DbSeek(xFilial("SB8")+SD2->D2_COD+SD2->D2_LOCAL+DTOS(SD2->D2_DTVALID)+SD2->D2_LOTECTL))
				If !Empty(DTOS(SB8->B8_DFABRIC))
					dDataFabric := SB8->B8_DFABRIC
				Else
					dDataFabric := SD2->D2_DFABRIC
				EndIf
				If !Empty(DTOS(SB8->B8_DTVALID))
					dDataValid := SB8->B8_DTVALID
				Else
					dDataValid := SD2->D2_DTVALID
				EndIf

				SC5->(DbSetOrder(1))
				SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))

				DA1->(DbSetOrder(1))
				IF DA1->(DbSeek(xFilial("DA1")+SC5->C5_TABELA+(cAliasSFT)->FT_PRODUTO))
					nPrcMax := DA1->DA1_PRCMAX
				Else
					DA1->(DbSetOrder(4))
					IF DA1->(DbSeek(xFilial("DA1")+SC5->C5_TABELA+(cAliasSFT)->B1_GRUPO))
						nPrcMax := DA1->DA1_PRCMAX
					Endif
				EndIf
			EndIf
			aAdd(aMedica,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO,;
						(cAliasSFT)->FT_QUANT,;
						dDataFabric,;
						(cAliasSB1)->B1_REFBAS,;
						(cAliasSB1)->B1_TPPROD,;
						nPrcMax,;
						dDataValid})

			lVerifica 		:= .F.
			aCompl[08][03]	:= .T.
			cComp := "8"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armas de fogo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim((cAliasSB1)->B1_GRUPO) $ cMVArmFog
			aAdd(aArma,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
			lVerifica 		:= .F.
			aCompl[02][03]	:= .T.
			cComp := "2"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Veiculos novos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim((cAliasSB1)->B1_GRUPO) $ cMVVeicNv
			aAdd(aVeic,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
			lVerifica 		:= .F.
			aCompl[09][03]	:= .T.
			cComp := "9"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Combustiveis³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim((cAliasSB1)->B1_GRUPO) $ cMVCombus
			aAdd(aCombust,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
			lVerifica 		:= .F.
			aCompl[03][03]	:= .T.
			cComp := "3"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Anfavea     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim((cAliasSB1)->B1_GRUPO) $ cMVAnfavea
			nPos	:= aScan(aAnfaveaC,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == (cAliasSFT)->FT_FILIAL+;
						(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+;
						(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_TIPOMOV})
			If nPos == 0
				aAdd(aAnfaveaC,{(cAliasSFT)->FT_FILIAL,;
							(cAliasSFT)->FT_NFISCAL,;
							(cAliasSFT)->FT_SERIE,;
							(cAliasSFT)->FT_CLIEFOR,;
							(cAliasSFT)->FT_LOJA,;
							(cAliasSFT)->FT_TIPOMOV})
				lVerifica 		:= .F.
				aCompl[17][03]	:= .T.
				cComp := "17"
			Endif
			aAdd(aAnfaveaI,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO,;
						(cAliasSFT)->FT_ESPECIE,;
						(cAliasSB1)->B1_UM,;
						(cAliasSB1)->B1_PESO,;
						(cAliasSB1)->B1_CODEMB,;
						(cAliasSB1)->B1_PESBRU})
			lVerifica 		:= .F.
			aCompl[18][03]	:= .T.
			cComp := "18"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rastreabilidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SX5->(MsSeek(xFilial("SX5")+"T0"+(cAliasSB1)->B1_GRUPO)) // Apenas os produtos com o grupo informado na tabela T0.

			aAdd(aRastr,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})

			lVerifica := .F.
			aCompl[23][03] := .T.
			cComp := "23"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os complementos sugeridos pelo sistema para geracao do log de auditoria³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aSugerido,{(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_ESPECIE,;
			(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_TIPOMOV,(cAliasSFT)->FT_ITEM,;
			(cAliasSFT)->FT_PRODUTO,cComp})

		(cAliasSFT)->(dbSkip())

	Enddo

	If !lQuery
		RetIndex("SFT")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSFT)
		dbCloseArea()
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os itens das notas que nao possuem grupo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(aCompl[02][03] .And. aCompl[03][03] .And. aCompl[08][03] .And. aCompl[09][03] .And. aCompl[17][03] .And. aCompl[18][03] .And. aCompl[23][03])

	#IFDEF TOP

		If TcSrvType()<>"AS/400"

			lQuery 		:= .T.
			cAliasSFT	:= GetNextAlias()

			BeginSql Alias cAliasSFT

				SELECT SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR,SFT.FT_LOJA,
					SFT.FT_TIPOMOV,SFT.FT_ITEM,SFT.FT_PRODUTO,SFT.FT_ESPECIE

				FROM %table:SFT% SFT

				WHERE SFT.FT_FILIAL = %xFilial:SFT% AND
					SFT.FT_NFISCAL = %Exp:cDoc% AND
					SFT.FT_SERIE = %Exp:cSerie% AND
					SFT.FT_CLIEFOR = %Exp:cClieFor% AND
					SFT.FT_LOJA = %Exp:cLoja% AND
					SFT.FT_TIPOMOV = %Exp:cEntSai% AND
					SFT.%NotDel%

				ORDER BY %Order:SFT%
			EndSql

			dbSelectArea(cAliasSFT)

		Else

	#ENDIF
			cArqInd   := CriaTrab(Nil,.F.)
			cChave    := SFT->(IndexKey())
			cCondicao := 'FT_FILIAL == "' + xFilial("SFT") + '" .AND. '
			cCondicao += 'FT_NFISCAL == "' + cDoc + '" .AND. '
			cCondicao += 'FT_SERIE == "' + cSerie + '" .AND. '
			cCondicao += 'FT_CLIEFOR == "' + cClieFor + '" .AND. '
			cCondicao += 'FT_LOJA == "' + cLoja + '" .AND. '
			cCondicao += 'FT_TIPOMOV == "' + cEntSai + '"'
			IndRegua(cAliasSFT,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAliasSFT)->(dbGotop())
	#IFDEF TOP
		Endif
	#ENDIF

	If lObjSay
		oSay:cCaption := (STR0066) //"Itens dos complementos"
	EndIf
	ProcessMessages()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento exclusivo para: Importacao.																	³
	//³Nos casos em que a Nota Fiscal foi emitida com bloqueio de movimento, eh necessario trazer as informacoes³
	//³da tabela SD1, pois soh ira gerar as tabelas SFT e SF3 depois de classificar a nota.						³
	//|O mesmo tratamento serve para os casos que não geram livro                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If /*(cAliasSFT)->(Eof()) .And.*/ aCompl[07][03]
		If lQuery
			ImpQrySD1(cDoc,cSerie,cClieFor,cLoja,@cAlsD1Imp,.T.)
		Else
			ImpQrySD1(cDoc,cSerie,cClieFor,cLoja,@cAlsD1Imp,.F.,cArqInd,cChave,cCondicao)
		Endif
	Endif

	Do While !((cAliasSFT)->(Eof()))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Energia Eletrica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCompl[05][03]
			aAdd(aEnergia,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
			cComp := "5"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gas canalizado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCompl[06][03]
			aAdd(aGas,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
			cComp := "6"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Importacao    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCompl[07][03]
			aAdd(aImport,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						"",;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
			cComp := "7"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Agua canalizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCompl[01][03]
			/*aAdd(aAgua,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})*/
			cComp := "1"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Comunicacao/telecomunicacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCompl[04][03]
			aAdd(aComunica,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
			cComp := "4"
		Endif

		If aCompl[16][03] .And. lCompExp
			aAdd(aExport,{(cAliasSFT)->FT_PRODUTO,;
						(cAliasSFT)->FT_ITEM,;
						"",;
						"",;
						"",;
						"",;
						(cAliasSFT)->FT_ITEM,;
						""})
			cComp := "16"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Compl. Ressarcimento       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCompl[19][03]
			/*
			aAdd(aRessarc,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
						*/
			aAdd(aRessarc,{(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
			cComp := "19"
		Endif

		//REMAS
		If aCompl[20][03] .and. len(aRemas)=1
			aAdd(aRemas,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA})
			cComp := "20"
		Endif

		If aCompl[21][03]
			aAdd(aCrdAcum,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA})
			cComp := "21"
		Endif

		If aCompl[22][03]
			aAdd(aDCCF8,{(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_TIPOMOV})
			cComp := "22"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os complementos sugeridos pelo sistema para geracao do log de auditoria³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aSugerido,{(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_ESPECIE,;
			(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_TIPOMOV,(cAliasSFT)->FT_ITEM,;
			(cAliasSFT)->FT_PRODUTO,cComp})

		(cAliasSFT)->(dbSkip())

	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento exclusivo para: Importacao.																	³
	//³Nos casos em que a Nota Fiscal foi emitida com bloqueio de movimento, eh necessario trazer as informacoes³
	//³da tabela SD1, pois soh ira gerar as tabelas SFT e SF3 depois de classificar a nota.						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If /*!(Len(aImport) > 0) .And.*/ aCompl[07][03]
		Do While !((cAlsD1Imp)->(Eof()))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Importacao    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCompl[07][03]
				If(aScan(aImport,{|X| X[1]==(cAlsD1Imp)->D1_FILIAL;
					.And. X[2]==(cAlsD1Imp)->D1_DOC     .And. x[3]==(cAlsD1Imp)->D1_SERIE;
					.And. x[4]==(cAlsD1Imp)->D1_FORNECE .And. x[5]==(cAlsD1Imp)->D1_LOJA;
					.And. x[7]==(cAlsD1Imp)->D1_ITEM    .And. x[8]==(cAlsD1Imp)->D1_COD}))==0
					aAdd(aImport,{(cAlsD1Imp)->D1_FILIAL,;
					(cAlsD1Imp)->D1_DOC,;
					(cAlsD1Imp)->D1_SERIE,;
					(cAlsD1Imp)->D1_FORNECE,;
					(cAlsD1Imp)->D1_LOJA,;
					"",;
					(cAlsD1Imp)->D1_ITEM,;
					(cAlsD1Imp)->D1_COD})
					cComp := "7"
				EndIf
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava os complementos sugeridos pelo sistema para geracao do log de auditoria³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aSugerido,{(cAlsD1Imp)->D1_DOC,(cAlsD1Imp)->D1_SERIE,cEspecie,;
				(cAlsD1Imp)->D1_FORNECE,(cAlsD1Imp)->D1_LOJA,"E",(cAlsD1Imp)->D1_ITEM,;
				(cAlsD1Imp)->D1_COD,cComp})
			(cAlsD1Imp)->(dbSkip())
		Enddo
		If !lQuery
			RetIndex("SD1")
			dbClearFilter()
			Ferase(cArqInd+OrdBagExt())
		Else
			dbSelectArea(cAlsD1Imp)
			dbCloseArea()
		Endif
	Endif

	If !lQuery
		RetIndex("SFT")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSFT)
		dbCloseArea()
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existem guias de recolhimento para o documento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAuxGuia := MtxGuiaRec(Iif(cEntSai=="E","1","2"),cDoc,cSerie,cClieFor,cLoja)

If Len(aAuxGuia) > 0
	nPos	:= aScan(aAuxGuia[1],{|x| Alltrim(x[1]) == "F6_NUMERO"})
	nPos2	:= aScan(aAuxGuia[1],{|x| Alltrim(x[1]) == "F6_EST"})
Endif

If lObjSay
	oSay:cCaption := (STR0067) //"Guias referenciadas"
EndIf
ProcessMessages()

For nX := 1 to Len(aAuxGuia)
	aAdd(aGNRE,{aAuxGuia[nX][nPos][2],aAuxGuia[nX][nPos2][2]})
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia de documentos referenciados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEntSai == "E"

	lQuery := .F.

	#IFDEF TOP

		If TcSrvType()<>"AS/400"

			lQuery 		:= .T.
			cAliasSD1	:= GetNextAlias()

			BeginSql Alias cAliasSD1

				SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,
					SD1.D1_NFORI,D1_SERIORI,SD1.D1_TIPO,SD1.D1_TES,SD1.D1_ORIGLAN

				FROM %table:SD1% SD1

				WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
					SD1.D1_DOC = %Exp:cDoc% AND
					SD1.D1_SERIE = %Exp:cSerie% AND
					SD1.D1_FORNECE = %Exp:cClieFor% AND
					SD1.D1_LOJA = %Exp:cLoja% AND
					SD1.D1_NFORI <> %Exp:cBranco% AND
					SD1.%NotDel%
				ORDER BY %Order:SD1%
			EndSql

			dbSelectArea(cAliasSD1)

		Else

	#ENDIF
			cArqInd   := CriaTrab(Nil,.F.)
			cChave    := SD1->(IndexKey())
			cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .AND. '
			cCondicao += 'D1_DOC == "' + cDoc + '" .AND. '
			cCondicao += 'D1_SERIE == "' + cSerie + '" .AND. '
			cCondicao += 'D1_FORNECE == "' + cClieFor + '" .AND. '
			cCondicao += 'D1_LOJA == "' + cLoja + '" .AND. '
			cCondicao += '!EMPTY(D1_NFORI) .AND. !EMPTY(D1_SERIORI)'
			IndRegua(cAliasSD1,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAliasSD1)->(dbGotop())
	#IFDEF TOP
		Endif
	#ENDIF

	If lObjSay
		oSay:cCaption := (STR0068) //"Documentos referenciados"
	EndIf
	ProcessMessages()

	Do While !((cAliasSD1)->(Eof()))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o cliente/fornecedor do documento original³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(dbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
		lAchouSF2 := .F.  // Forço a reinicialização da variável a cada passo do laço.

		// Quando for devolução de cupom não deve ser utilizado campos de cliente e loja
		If !Alltrim((cAliasSD1)->D1_ORIGLAN) $ "LO/LF"
			If cTpNF $ "DB"
				If !SF2->(dbSeek(xFilial("SF2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
					(cAliasSD1)->(dbSkip())
					Loop
				Else
					lAchouSF2 := .T.
				EndIf
			ElseIf SF4->F4_PODER3 == "D"
				If !SF2->(dbSeek(xFilial("SF2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
					(cAliasSD1)->(dbSkip())
					Loop
				Else
					lAchouSF2 := .T.
				EndIf
			Else
				If !SF1->(dbSeek(xFilial("SF1")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
					(cAliasSD1)->(dbSkip())
					Loop
				Endif
			Endif


			If (nPos	:= aScan(aDocRef,{|x|	x[1] == (cAliasSD1)->D1_NFORI	 .And. ;
												x[2] == (cAliasSD1)->D1_SERIORI .And. ;
												x[3] == Iif(lAchouSF2 .And. SF4->F4_PODER3 == "D",SF2->F2_CLIENTE,(cAliasSF1)->F1_FORNECE) .And. ;
												x[4] == (cAliasSF1)->F1_LOJA	 .And. ;
												x[5] == (cAliasSD1)->D1_TIPO})) == 0
				If lAchouSF2
					aAdd(aDocRef,{(cAliasSD1)->D1_NFORI,(cAliasSD1)->D1_SERIORI,SF2->F2_CLIENTE,SF2->F2_LOJA,(cAliasSD1)->D1_TIPO,SF2->F2_CHVNFE,"2",Alltrim(STRZERO(Month(SF2->F2_EMISSAO),2)) + Alltrim(STR(YEAR(SF2->F2_EMISSAO),4)),SF2->F2_ESPECIE})
				Else
					aAdd(aDocRef,{(cAliasSD1)->D1_NFORI,(cAliasSD1)->D1_SERIORI,(cAliasSF1)->F1_FORNECE,(cAliasSF1)->F1_LOJA,(cAliasSD1)->D1_TIPO,(cAliasSF1)->F1_CHVNFE,"1",Alltrim(STRZERO(Month((cAliasSF1)->F1_EMISSAO),2)) + Alltrim(STR(YEAR((cAliasSF1)->F1_EMISSAO),4)),(cAliasSF1)->F1_ESPECIE})
				EndIf
				aCompl[12][03]	:= .T. // habilita aba de documento fiscal
			EndIf
		Endif

		If cTpNF $ "DB" .And. Alltrim((cAliasSD1)->D1_ORIGLAN) $ "LO/LF"

			If SF2->(dbSeek(xFilial("SF2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI))

				If aModNot(SF2->F2_ESPECIE)  $ "02/59/65" // 02 - Cupom Fiscal  / 59 - SAT CF-E / NFCe
					//Evita a duplicidade de cupons fiscais, em caso de mais de item por nota
					If ( aScan( aNfCupom, { |x| x[1] == SF2->F2_DOC	.and.;
												x[2] == SF2->F2_SERIE	.and.;
												x[3] == SF2->F2_CLIENTE	.and.;
												x[4] == SF2->F2_LOJA	.and.;
												x[5] == SF2->F2_TIPO } ) == 0 )

						aAdd(aNfCupom,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO})
						aCompl[13][03]	:= .T. // habilita a aba de Cupom Fiscal
					EndIf
				Else
					lAchouSF2 := .T.
					If (nPos	:= aScan(aDocRef,{|x|	x[1] == (cAliasSD1)->D1_NFORI	 .And. ;
													x[2] == (cAliasSD1)->D1_SERIORI .And. ;
													x[3] == Iif(lAchouSF2 .And. SF4->F4_PODER3 == "D",SF2->F2_CLIENTE,(cAliasSF1)->F1_FORNECE) .And. ;
													x[4] == (cAliasSF1)->F1_LOJA	 .And. ;
													x[5] == (cAliasSD1)->D1_TIPO})) == 0
						If lAchouSF2
							aAdd(aDocRef,{(cAliasSD1)->D1_NFORI,(cAliasSD1)->D1_SERIORI,SF2->F2_CLIENTE,SF2->F2_LOJA,(cAliasSD1)->D1_TIPO,SF2->F2_CHVNFE,"2",Alltrim(STRZERO(Month(SF2->F2_EMISSAO),2)) + Alltrim(STR(YEAR(SF2->F2_EMISSAO),4))})
						Else
							aAdd(aDocRef,{(cAliasSD1)->D1_NFORI,(cAliasSD1)->D1_SERIORI,(cAliasSF1)->F1_FORNECE,(cAliasSF1)->F1_LOJA,(cAliasSD1)->D1_TIPO,(cAliasSF1)->F1_CHVNFE,"1",Alltrim(STRZERO(Month((cAliasSF1)->F1_EMISSAO),2)) + Alltrim(STR(YEAR((cAliasSF1)->F1_EMISSAO),4))})
						EndIf
						aCompl[12][03]	:= .T. // habilita aba de documento referenciado
					EndIf
				EndIf
			EndIf

		endif

		(cAliasSD1)->(dbSkip())

	Enddo

	if !Alltrim((cAliasSD1)->D1_ORIGLAN) $ "LO" .and. !aCompl[12][03] .and. lCDDTMov
			aCompl[12][03]	:= .T.    //Permitir complemento para notas que precisam ser vinculadas mas não foram preenchidas nos campos de origem da nota. // ISSUE DSERFIS1-15367
			lCompDoc := .T.
	EndIf
	
	If !lQuery
		RetIndex("SD1")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	Endif

Else

	lQuery := .F.

	#IFDEF TOP

		If TcSrvType()<>"AS/400"

			lQuery 		:= .T.
			cAliasSD2	:= GetNextAlias()

			BeginSql Alias cAliasSD2

				SELECT SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,
					SD2.D2_NFORI,SD2.D2_SERIORI,SD2.D2_TIPO,SD2.D2_TES

				FROM %table:SD2% SD2

				WHERE SD2.D2_FILIAL = %xFilial:SD2% AND
					SD2.D2_DOC = %Exp:cDoc% AND
					SD2.D2_SERIE = %Exp:cSerie% AND
					SD2.D2_CLIENTE = %Exp:cClieFor% AND
					SD2.D2_LOJA = %Exp:cLoja% AND
					SD2.D2_NFORI <> %Exp:cBranco% AND
					SD2.%NotDel%
				ORDER BY %Order:SD2%
			EndSql

			dbSelectArea(cAliasSD2)

		Else

	#ENDIF
			cArqInd   := CriaTrab(Nil,.F.)
			cChave    := SD2->(IndexKey())
			cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .AND. '
			cCondicao += 'D2_DOC == "' + cDoc + '" .AND. '
			cCondicao += 'D2_SERIE == "' + cSerie + '" .AND. '
			cCondicao += 'D2_CLIENTE == "' + cClieFor + '" .AND. '
			cCondicao += 'D2_LOJA == "' + cLoja + '" .AND. '
			cCondicao += '!EMPTY(D2_NFORI) .AND. !EMPTY(D2_SERIORI)'
			IndRegua(cAliasSD2,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAliasSD2)->(dbGotop())
	#IFDEF TOP
		Endif
	#ENDIF

	Do While !((cAliasSD2)->(Eof()))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o cliente/fornecedor do documento original³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(dbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
		lAchouSF1 := .F.  // Forço a reinicialização da variável a cada passo do laço.

		If cTpNF $ "DB"
			If !SF1->(dbSeek(xFilial("SF1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				If cTpNF $ "D"
					(cAliasSD2)->(dbSkip())
					Loop
				ElseIf cTpNF $ "B" .And. !SF2->(dbSeek(xFilial("SF2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI))
					(cAliasSD2)->(dbSkip())
					Loop
				Else
					lAchouSF1 := .F.
				EndIf
			Else
				lAchouSF1 := .T.
			Endif
		ElseIf SF4->F4_PODER3 == "D"
			If !SF1->(dbSeek(xFilial("SF1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				(cAliasSD2)->(dbSkip())
				Loop
			Else
				lAchouSF1 := .T.
			Endif
		Else
			If !SF2->(dbSeek(xFilial("SF2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI)) // Retirado a validação do pesquisa o codigo do cliente + loja para validar tambem notas de acordo com a legislaçõa Abaixo trecho do RICMS que trata dessa operação. Art. 245. Na remessa da mercadoria com o fim específico de exportação, o estabelecimento remetente emitirá nota fiscal
				(cAliasSD2)->(dbSkip())
				Loop
			Endif
		Endif

		If (nPos	:= aScan(aDocRef,{|x|	x[1] == (cAliasSD2)->D2_NFORI	 .And. ;
											x[2] == (cAliasSD2)->D2_SERIORI .And. ;
											x[3] == Iif(lAchouSF1 .And. SF4->F4_PODER3 == "D",(cAliasSF1)->F1_FORNECE,(cAliasSF2)->F2_CLIENTE) .And. ;
											x[4] == (cAliasSF2)->F2_LOJA	 .And. ;
											x[5] == (cAliasSD2)->D2_TIPO})) == 0
			If lAchouSF1
				aAdd(aDocRef,{(cAliasSD2)->D2_NFORI,(cAliasSD2)->D2_SERIORI,(cAliasSF1)->F1_FORNECE,(cAliasSF1)->F1_LOJA,(cAliasSD2)->D2_TIPO,(cAliasSF1)->F1_CHVNFE,"1",Alltrim(STRZERO(Month((cAliasSF1)->F1_EMISSAO),2)) + Alltrim(STR(YEAR((cAliasSF1)->F1_EMISSAO),4)),(cAliasSF1)->F1_ESPECIE})
			Else
				aAdd(aDocRef,{(cAliasSD2)->D2_NFORI,(cAliasSD2)->D2_SERIORI,(cAliasSF2)->F2_CLIENTE,(cAliasSF2)->F2_LOJA,(cAliasSD2)->D2_TIPO,(cAliasSF2)->F2_CHVNFE,"2",Alltrim(STRZERO(Month((cAliasSF2)->F2_EMISSAO),2)) + Alltrim(STR(YEAR((cAliasSF2)->F2_EMISSAO),4)),(cAliasSF2)->F2_ESPECIE})
			Endif
			aCompl[12][03]	:= .T.
		EndIf


		(cAliasSD2)->(dbSkip())

	Enddo

	If !aCompl[12][03] .and. lCDDTMov
		aCompl[12][03]	:= .T.    //Permitir complemento para notas que precisam ser vinculadas mas não foram preenchidas nos campos de origem da nota. // ISSUE DSERFIS1-15367
		lCompDoc := .T.
	Endif

	If !lQuery
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	Endif

Endif

If cEntSai == "S"

	If lObjSay
		oSay:cCaption := (STR0069) //"Cupons fiscais e locais referenciados"
	EndIf
	ProcessMessages()

	SF2->(dbSeek(xFilial("SF2")+cDoc+cSerie+cClieFor+cLoja))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia de cupons referenciados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SF2->F2_NFCUPOM)
		nTamDoc := TamSx3("F2_DOC")[1]
		nTamSer := TamSx3("F2_SERIE")[1]
		cSerCup := Padr(SubStr(SF2->F2_NFCUPOM,1,nTamSer),nTamSer)
		cCupom  := Padr(SubStr(SF2->F2_NFCUPOM,nTamSer+1,nTamDoc+nTamSer),nTamDoc)
		If SF2->(dbSeek(xFilial("SF2")+cCupom+cSerCup))
			aAdd(aNfCupom,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO})
			aCompl[13][03]	:= .T.
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cliente de entrega e diferente do cliente faturado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ((SF2->F2_CLIENT <> SF2->F2_CLIENTE) .Or. (SF2->F2_LOJENT <> SF2->F2_LOJA)) .And. (!Empty(SF2->F2_CLIENT) .And. !Empty(SF2->F2_LOJENT))
		aAdd(aLocal,{SF2->F2_CLIENT,SF2->F2_LOJENT})
		aCompl[14][03]	:= .T.
	Endif
EndIF
RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M926Cols ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o aHeader e o aCols dos complementos que devem       ³±±
±±³          ³ apresentar informacoes por item - GetDados.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os complementos                          ³±±
±±³          ³ ExpC2 = Numero da nota fiscal                              ³±±
±±³          ³ ExpC3 = Serie da nota fiscal                               ³±±
±±³          ³ ExpC4 = Especie da nota fiscal                             ³±±
±±³          ³ ExpC5 = Cliente/fornecedor                                 ³±±
±±³          ³ ExpC6 = Loja do cliente/fornecedor                         ³±±
±±³          ³ ExpC7 = Indicacao de entrada/saida                         ³±±
±±³          ³ ExpC8 = Indica se a NF e de devol./beneficiamento          ³±±
±±³          ³ ExpA9 = Itens da NF do grupo medicamentos                  ³±±
±±³          ³ ExpAA = Itens da NF do grupo armas de fogo                 ³±±
±±³          ³ ExpAB = Itens da NF do grupo veiculos automotores          ³±±
±±³          ³ ExpAC = Itens da NF do grupo combustiveis                  ³±±
±±³          ³ ExpAD = Itens da NF de energia eletrica                    ³±±
±±³          ³ ExpAE = Itens da NF de gas canalizado                      ³±±
±±³          ³ ExpAF = Itens da NF de agua canalizada                     ³±±
±±³          ³ ExpAG = Itens da NF de comunicacao/telecomunicacao         ³±±
±±³          ³ ExpAH = Complementos sugeridos pelo sistema (log)          ³±±
±±³          ³ ExpAI = Array com as guias de recolhimento referenciadas   ³±±
±±³          ³ ExpAJ = Array com os cupons fiscais referenciados          ³±±
±±³          ³ ExpAK = Array com os documentos referenciados              ³±±
±±³          ³ ExpAL = Array com os locais de coleta/entrega              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Cols(aCompl,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aComunica,aObrigat,aMantem,aGNRE,aNfCupom,aDocRef,aLocal,aAgua,lExpInd,aAnfaveaC,aAnfaveaI,aRessarc,aImport,aRemas,aCrdAcum,aDCCF8,aRastr,aExport,oSay)

Local aCampos	:= {}
Local aHeader	:= {}
Local aCols		:= {}
Local aPermite	:= {}
Local aCabPer	:= {}

Local cTabela	:= ""
Local cAlias	:= ""
Local cArqInd	:= ""
Local cChave	:= ""

Local lQuery	:= .F.
Local lPossui	:= .F.
Local lCompCG8	:= GetNewPar("MV_REMASRJ", .F.)
Local cMvEstado	:= GetNewPar("MV_ESTADO", .F.)
Local lCompCFF	:= cMvEstado == "SP"
Local lCompF0A   := AliasIndic("F0A")
Local lCmpFcp 	:= CD0->(ColumnPos("CD0_FCPST")) > 0
Local lObjSay   := Type("oSay") != "U"
Local lCddMnRf	:= CDD->(FieldPos("CDD_MEANRF")) > 0
Local lCddMdRf	:= CDD->(FieldPos("CDD_MODREF")) > 0
Local nX		:= 0
Local nY		:= 0
Local nG		:= 0
Local nCount	:= 1
Local nI		:= 0
Local nScan		:= 0
Local cWhen		:= .F.
Local nPosMt    := 0

Local cValidCpoAnt	:= ""
Local cValidCpoNov	:= ""
Local nA			:= 0

Local lMT926CD5 := ExistBlock("MT926CD5")
Local lMT926CDL := ExistBlock("MT926CDL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Da posicao 1 a 9, consideram-se os complementos e da 10 a 14, as informacoes complementares³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX := 1 to Len(aCompl)

	If lObjSay
		oSay:cCaption := (STR0070 + aCompl[nX][1]) //"Apresentando informações: "
	EndIf
	ProcessMessages()

	aCampos		:= {}
	aCols		:= {}
	aHeader		:= {}
	aPermite	:= {}
	aCabPer		:= {}

	Do Case
		Case nX == 1
			// agua canalizada
			aCampos := {"CD4_CLASCO","CD4_TPCLAS","CD4_VLTERC"}
			cTabela := "CD4"
			// Issue DSERFIS1-26855 - Foi incluído esse campo para preenchimento do campo 13 VL_FORN - C600 - Pacote 010881 ATUSX
			If CD4->(FieldPos("CD4_VLFORN")) > 0
				AADD(aCampos, "CD4_VLFORN")
			EndIf
			aCabPer		:= {"CD4_FILIAL","CD4_DOC","CD4_SERIE","CD4_CLIFOR","CD4_LOJA","CD4_TPMOV"}
			aPermite	:= aClone(aAgua)
		Case nX == 2
			// arma de fogo
			aCampos := {"CD8_ITEM","CD8_COD","CD8_TPARMA","CD8_NUMARM","CD8_DESCR"}
			cTabela := "CD8"
			aCabPer		:= {"CD8_FILIAL","CD8_DOC","CD8_SERIE","CD8_CLIFOR","CD8_LOJA","CD8_TPMOV","CD8_ITEM","CD8_COD"}
			aPermite	:= aClone(aArma)
		Case nX == 3
			// combustivel
			aCampos := {"CD6_ITEM","CD6_COD","CD6_CODANP","CD6_TRANSP","CD6_PLACA","CD6_SEFAZ","CD6_PASSE","CD6_HORA","CD6_TEMP","CD6_VOLUME","CD6_PBRUTO","CD6_PLIQUI","CD6_MOTOR","CD6_CPFMOT","CD6_TANQUE","CD6_QTDE"}
			AADD(aCampos,"CD6_UFPLAC")
			AADD(aCampos,"CD6_QTAMB" )
			AADD(aCampos,"CD6_UFCONS")
			AADD(aCampos,"CD6_BCCIDE")
			AADD(aCampos,"CD6_VALIQ")
			AADD(aCampos,"CD6_VCIDE")
			If CD6->(ColumnPos("CD6_BICO")) > 0 .And. CD6->(ColumnPos("CD6_BOMBA")) > 0 .And. CD6->(ColumnPos("CD6_ENCINI")) > 0 .And. CD6->(ColumnPos("CD6_ENCFIN")) > 0
				aadd(aCampos,"CD6_BICO")
				aadd(aCampos,"CD6_BOMBA")
				aadd(aCampos,"CD6_ENCINI")
				aadd(aCampos,"CD6_ENCFIN")
			Endif
			// Campos inseridos na NF-e 4.0
			If CD6->(ColumnPos("CD6_DESANP")) > 0 .And. CD6->(ColumnPos("CD6_PGLP")) > 0 .And. CD6->(ColumnPos("CD6_PGNN")) > 0 .And. CD6->(ColumnPos("CD6_PGNI")) > 0 .And. CD6->(ColumnPos("CD6_VPART")) > 0
				aadd(aCampos,"CD6_DESANP")
				aadd(aCampos,"CD6_PGLP")
				aadd(aCampos,"CD6_PGNN")
				aadd(aCampos,"CD6_PGNI")
				aadd(aCampos,"CD6_VPART")
			EndIf
			cTabela := "CD6"
			aCabPer		:= {"CD6_FILIAL","CD6_DOC","CD6_SERIE","CD6_CLIFOR","CD6_LOJA","CD6_TPMOV","CD6_ITEM","CD6_COD"}
			aPermite	:= aClone(aCombust)
		Case nX == 4
			// comunicacao/telecomunicacao
			aCampos 	:= {"FX_ITEM","FX_COD","FX_CLASCON","FX_GRPCLAS","FX_CLASSIF","FX_VALTERC","FX_RECEP","FX_LOJAREC","FX_TIPSERV","FX_TIPOREC","FX_DTINI","FX_DTFIM","FX_PERFIS","FX_AREATER","FX_TERMINA","FX_VOL115","FX_CHV115","FX_TPASSIN","FX_ESTREC","FX_ESTHIPO","FX_ESTMOTI","FX_ESTCONT"}
			cTabela 	:= "SFX"
			aCabPer		:= {"FX_FILIAL","FX_DOC","FX_SERIE","FX_CLIFOR","FX_LOJA","FX_TIPOMOV","FX_ITEM","FX_COD"}
			aPermite	:= aClone(aComunica)
		Case nX == 5
			// energia eletrica
			aCampos		:= {"FU_ITEM","FU_COD","FU_CLASCON","FU_CLCOSEF","FU_GRPCLAS","FU_CLASSIF","FU_VALTERC","FU_TIPOREC","FU_RECEP","FU_LOJAREC","FU_CONSTOT","FU_VOL115","FU_CHV115","FU_TIPLIGA","FU_GRUPT","FU_VLFORN","FU_CODUNC","FU_PERFIS","FU_SUBCLC","FU_AREATER","FU_TERMINA","FU_DTINI","FU_DTFIM","FU_DTLEIT","FU_DTANT","FU_DEMCT","FU_DEMCTP"}
			cTabela		:= "SFU"
			aCabPer		:= {"FU_FILIAL","FU_DOC","FU_SERIE","FU_CLIFOR","FU_LOJA","FU_TIPOMOV","FU_ITEM","FU_COD"}
			aPermite	:= aClone(aEnergia)
		Case nX == 6
			// gas canalizado
			aCampos := {"CD3_ITEM","CD3_COD","CD3_CLASCO","CD3_TPCLAS","CD3_VLTERC","CD3_TPREC","CD3_RECEP","CD3_LOJARE"}
			AADD(aCampos,"CD3_VOL115")
			AADD(aCampos,"CD3_CHV115")
			// Issue DSERFIS1-26855 - Foi incluído esse campo para preenchimento do campo 13 VL_FORN - C600 - Pacote 010881 ATUSX 
			If CD3->(FieldPos("CD3_VLFORN")) > 0
				AADD(aCampos, "CD3_VLFORN")
			EndIf
			cTabela := "CD3"
			aCabPer		:= {"CD3_FILIAL","CD3_DOC","CD3_SERIE","CD3_CLIFOR","CD3_LOJA","CD3_TPMOV","CD3_ITEM","CD3_COD"}
			aPermite	:= aClone(aGas)
		Case nX == 7
			// importacao - por nota fiscal
			aCampos := {"CD5_ITEM",;					// 1°   Item da Nota
						"CD5_TPIMP",;					// 2°   Tp. doc. imp
						"CD5_DOCIMP",;					// 3°	Doc. imp.
						"CD5_BSPIS",;					// 4°	Base PIS
						"CD5_ALPIS",;					// 5°	Alíq. PIS
						"CD5_VLPIS",;					// 6°	Val. PIS
						"CD5_BSCOF",;					// 7°	Base Cofins
						"CD5_ALCOF",;					// 8°	Alíq. Cofins
						"CD5_VLCOF",;					// 9°	Val. Cofins
						"CD5_ACDRAW",;					// 10°	Ato Concesso
						"CD5_DTPPIS",;					// 11°	Dt Pag Pis
						"CD5_DTPCOF",;					// 12°	Dt Pag Cofin
						"CD5_LOCAL",;					// 13°	Local Serv
						"CD5_NDI",;						// 14°	No. da DI/DA
						"CD5_DTDI",;					// 15°	Registro DI
						"CD5_LOCDES",;					// 16°	Descr.Local
						"CD5_UFDES",;					// 17°	UF Desembara
						"CD5_DTDES",;					// 18°	Dt Desembar.
						"CD5_CODEXP",;					// 19°	Exportador
						"CD5_LOJEXP",;					// 20°	Loja Exp.
						"CD5_NADIC",;					// 21°	Adicao
						"CD5_SQADIC",;					// 22°	Seq Adicao
						"CD5_CODFAB",;					// 23°	Fabricante
						"CD5_LOJFAB",;					// 24°	Loja Fab.
						"CD5_VDESDI",;					// 25°	Vlr Desconto
						"CD5_BCIMP",;					// 26°	Vlr BC Impor
						"CD5_DSPAD",;					// 27°	Vlr Desp.Adu
						"CD5_VLRII",;					// 28°	Vlr Imp.Impo
						"CD5_VLRIOF",;					// 29°	Vlr IOF
						"CD5_VTRANS",;					// 30°	Via Transp
						"CD5_VAFRMM",;					// 31°	Val. AFRMM
						"CD5_INTERM",;					// 32°	Forma Import
						"CD5_CNPJAE",;					// 33°	CNPJ Adqui.
						"CD5_UFTERC"}					// 34°	UF Terceiro
			cTabela := "CD5"
			If lMT926CD5
				aCampos := ExecBlock("MT926CD5",.F.,.F.,{aCampos})
			EndIf
			aCabPer		:= {"CD5_FILIAL","CD5_DOC","CD5_SERIE","CD5_FORNEC","CD5_LOJA","CD5_TPMOV","CD5_ITEM"}
			aPermite	:= aClone(aImport)
		Case nX == 8
			// medicamentos
			aCampos := {"CD7_ITEM","CD7_COD","CD7_LOTE","CD7_QTDLOT","CD7_FABRIC","CD7_VALID","CD7_REFBAS","CD7_TPPROD","CD7_PRECO"}
			cTabela := "CD7"
			aCabPer		:= {"CD7_FILIAL","CD7_DOC","CD7_SERIE","CD7_CLIFOR","CD7_LOJA","CD7_TPMOV","CD7_ITEM","CD7_COD","CD7_QTDLOT","CD7_FABRIC","CD7_REFBAS","CD7_TPPROD","CD7_PRECO","CD7_VALID"}
			// Campos inseridos na NF-e 4.0
			If CD7->(ColumnPos("CD7_CODANV")) > 0
				aadd(aCampos,"CD7_CODANV")
			EndIf

    	If CD7->(ColumnPos("CD7_MOTISE")) > 0
				aadd(aCampos,"CD7_MOTISE")
			EndIf

			aPermite	:= aClone(aMedica)
		Case nX == 9
			// veiculos
			aCampos := {"CD9_ITEM","CD9_COD","CD9_TPOPER","CD9_CHASSI","CD9_CODCOR","CD9_DSCCOR","CD9_POTENC","CD9_CM3POT","CD9_PESOLI","CD9_PESOBR","CD9_SERIAL","CD9_TPCOMB","CD9_NMOTOR","CD9_CMKG","CD9_DISTEI","CD9_RENAVA","CD9_ANOMOD","CD9_ANOFAB","CD9_TPPINT","CD9_TPVEIC","CD9_ESPVEI","CD9_CONVIN","CD9_CONVEI","CD9_CODMOD","CD9_CILIND","CD9_TRACAO","CD9_LOTAC","CD9_CORDE","CD9_RESTR"}
			cTabela := "CD9"
			aCabPer		:= {"CD9_FILIAL","CD9_DOC","CD9_SERIE","CD9_CLIFOR","CD9_LOJA","CD9_TPMOV","CD9_ITEM","CD9_COD"}
			aPermite	:= aClone(aVeic)
		Case nX == 10
			// Informacoes complementares - processos referenciados
			aCampos := {"CDG_ITEM","CDG_PROCES","CDG_TPPROC","CDG_ITPROC","CDG_DESCCF","CDG_VALOR","CDG_IFCOMP"}
			cTabela := "CDG"
		Case nX == 11
			// Informacoes complementares - guias de recolhimento referenciadas
			aCampos := {"CDC_GUIA","CDC_UF","CDC_IFCOMP"}
			aAdd(aCampos,"CDC_DCCOMP")
			cTabela := "CDC"
			aCabPer		:= {"CDC_GUIA","CDC_UF"}
			aPermite	:= aClone(aGNRE)
		Case nX == 12
			// Informacoes complementares - documentos referenciados
			aCampos := {"CDD_DOCREF","CDD_SERREF","CDD_PARREF","CDD_LOJREF","CDD_IFCOMP"}
			cTabela := "CDD"
			aCabPer := {"CDD_DOCREF","CDD_SERREF","CDD_PARREF","CDD_LOJREF"}
			If CDD->(ColumnPos("CDD_CHVNFE"))>0
				aAdd(aCampos,"CDD_CHVNFE")
				aAdd(aCabPer,"")
				aAdd(aCabPer,"CDD_CHVNFE")
			Endif
			if lCompDoc
				aCampos := {"CDD_DOCREF","CDD_SERREF","CDD_PARREF","CDD_LOJREF","CDD_CHVNFE","CDD_ENTSAI","CDD_IFCOMP"}
				aCabPer := {"CDD_DOCREF","CDD_SERREF","CDD_PARREF","CDD_LOJREF","CDD_CHVNFE","CDD_ENTSAI",""}				
			Endif
			If lCddMnRf
				If !lCompDoc
					aAdd(aCampos,"CDD_ENTSAI")
					aAdd(aCabPer,"CDD_ENTSAI")				
				Endif
				aAdd(aCampos,"CDD_MEANRF")
				aAdd(aCabPer,"CDD_MEANRF")
				If lCddMdRf
					aAdd(aCampos,"CDD_MODREF")
					aAdd(aCabPer,"CDD_MODREF")
				Endif
			Endif		
			aPermite	:= aClone(aDocRef)
		
		Case nX == 13
			// Informacoes complementares - cupons referenciados
			aCampos := {"CDE_CPREF","CDE_SERREF","CDE_PARREF","CDE_LOJREF","CDE_IFCOMP"}
			cTabela := "CDE"
			aCabPer		:= {"CDE_CPREF","CDE_SERREF","CDE_PARREF","CDE_LOJREF"}
			aPermite	:= aClone(aNfCupom)
		Case nX == 14
			// Informacoes complementares - local de coleta/entrega
			aCampos := {"CDF_TPTRAN","CDF_COLETA","CDF_LOJCOL","CDF_ENTREG","CDF_LOJENTR","CDF_IFCOMP"}
			cTabela := "CDF"
			aCabPer		:= {"CDF_ENTREG","CDF_LOJENT"}
			aPermite	:= aClone(aLocal)
		Case nX == 15
			// Informacoes complementares - Informações complementares
			aCampos := {"CDT_IFCOMP"}
			aAdd(aCampos,"CDT_DCCOMP")
			cTabela := "CDT"
		Case nX == 16 .And. lCompExp
			// exportacao
			If lSdoc
				aCampos := {"CDL_PRODNF","CDL_ITEMNF","CDL_INDDOC","CDL_NUMDE","CDL_DTDE","CDL_NATEXP","CDL_NRREG","CDL_DTREG","CDL_CHCEMB","CDL_DTCHC","CDL_DTAVB","CDL_TPCHC","CDL_PAIS","CDL_NRMEMO","CDL_FORNEC","CDL_LOJFOR","CDL_DOCORI","CDL_SERORI","CDL_DTORI","CDL_ESPORI","CDL_PRDORI","CDL_ITEORI","CDL_NFEXP","CDL_SEREXP","CDL_ESPEXP","CDL_EMIEXP","CDL_CHVEXP","CDL_QTDEXP","CDL_UFEMB","CDL_LOCEMB","CDL_CODMOE","CDL_VLREXP","CDL_NRDESP","CDL_ACDRAW", "CDL_LOCDES"}
			Else
				aCampos := {"CDL_PRODNF","CDL_ITEMNF","CDL_INDDOC","CDL_NUMDE","CDL_DTDE","CDL_NATEXP","CDL_NRREG","CDL_DTREG","CDL_CHCEMB","CDL_DTCHC","CDL_DTAVB","CDL_TPCHC","CDL_PAIS","CDL_NRMEMO","CDL_FORNEC","CDL_LOJFOR","CDL_DOCORI","CDL_SERORI","CDL_PRDORI","CDL_ITEORI","CDL_NFEXP","CDL_SEREXP","CDL_ESPEXP","CDL_EMIEXP","CDL_CHVEXP","CDL_QTDEXP","CDL_UFEMB","CDL_LOCEMB","CDL_CODMOE","CDL_VLREXP","CDL_NRDESP","CDL_ACDRAW","CDL_LOCDES"}
			EndIf
			cTabela := "CDL"
			If lMT926CDL
				aCampos := ExecBlock("MT926CDL",.F.,.F.,{aCampos})
			EndIf
			aCabPer		:= {"CDL_PRODNF","CDL_ITEMNF"}
			aPermite	:= aClone(aExport)
		Case nX == 17 .And. lAnfavea
			// Informacoes complementares Cabeçalho Anfavea
			aCampos := {"CDR_VERSAO","CDR_CDTRAN","CDR_NMTRAN","CDR_CDRECP","CDR_NMRECP","CDR_CDENT","CDR_DTENT","CDR_NUMINV"}
			cTabela := "CDR"
			aCabPer := {"CDR_TPMOV","CDR_DOC","CDR_SERIE","CDR_ESPEC","CDR_CLIFOR","CDR_LOJA"}
			aPermite:= aClone(aAnfaveaC)
		Case nX == 18 .And. lAnfavea
			// Informacoes complementares Itens Anfavea
			If lSdoc
				aCampos := {"CDS_ITEM","CDS_PRODUT","CDS_PEDCOM","CDS_SGLPED","CDS_SEPPEN","CDS_TPFORN","CDS_UM","CDS_DTVALI","CDS_PEDREV","CDS_CDPAIS",;
							"CDS_PBRUTO","CDS_PLIQUI","CDS_TPCHAM","CDS_NUMCHA","CDS_DTCHAM","CDS_QTDEMB","CDS_QTDIT","CDS_LOCENT",;
							"CDS_PTUSO","CDS_TPTRAN","CDS_LOTE","CDS_CPI","CDS_NFEMB","CDS_SEREMB","CDS_DTEMB","CDS_ESPEMB","CDS_CDEMB","CDS_AUTFAT","CDS_CDITEM"}
			Else
				aCampos := {"CDS_ITEM","CDS_PRODUT","CDS_PEDCOM","CDS_SGLPED","CDS_SEPPEN","CDS_TPFORN","CDS_UM","CDS_DTVALI","CDS_PEDREV","CDS_CDPAIS",;
							"CDS_PBRUTO","CDS_PLIQUI","CDS_TPCHAM","CDS_NUMCHA","CDS_DTCHAM","CDS_QTDEMB","CDS_QTDIT","CDS_LOCENT",;
							"CDS_PTUSO","CDS_TPTRAN","CDS_LOTE","CDS_CPI","CDS_NFEMB","CDS_SEREMB","CDS_CDEMB","CDS_AUTFAT","CDS_CDITEM"}
			EndIf
			cTabela := "CDS"
			aCabPer	:= {"CDS_FILIAL","CDS_DOC","CDS_SERIE","CDS_CLIFOR","CDS_LOJA","CDS_TPMOV","CDS_ITEM","CDS_PRODUT","CDS_ESPEC",;
						"CDS_UM","CDS_PLIQUI","CDS_CDEMB","CDS_PBRUTO"}
			aPermite:= aClone(aAnfaveaI)
		Case nX == 19
			// Informacoes complementares - Nota de Ressarcimento
			aCampos := {"CD0_ITEM","CD0_COD","CD0_DOCENT","CD0_SERENT","CD0_FORNE","CD0_LOJENT","CD0_ESPECIE","CD0_EMISSAO","CD0_QUANT","CD0_VUNIT","CD0_VALBST"}
			If lCmpCD0
				aCampos :=	{"CD0_ITEM","CD0_COD","CD0_DOCENT","CD0_SERENT","CD0_FORNE","CD0_LOJENT","CD0_ESPECIE","CD0_EMISSAO","CD0_QUANT","CD0_VUNIT","CD0_VALBST",;
							"CD0_CHVNFE","CD0_ITENFE","CD0_VLUNOP","CD0_PICMSE","CD0_ALQSTE","CD0_VLUNRE","CD0_BSULMT","CD0_VLUNCR","CD0_RESPRE","CD0_MOTRES","CD0_CHNFRT",;
							"CD0_PANFRT","CD0_LJPANF","CD0_SRNFRT","CD0_NRNFRT","CD0_ITNFRT","CD0_CODDA","CD0_NUMDA"}
			Endif
			If lCmpFcp
				AADD(aCampos,"CD0_FCPST")
			Endif
			cTabela := "CD0"
			aCabPer	:= {"CD0_ITEM","CD0_COD"}
			aPermite:= aClone(aRessarc)
		Case nX == 20 .And. lCompCG8
		// REMAS Rio de Janeiro
			aCampos := {"CG8_TPESP","CG8_VLINC","CG8_USOCON","CG8_CODORI","CG8_CODDES"}
			cTabela := "CG8"
			aCabPer	:= {"CG8_NUMDOC","CG8_SERIE"}
			aPermite:= aClone(aRemas)
		Case nX == 21 .And. lCompCFF
		// Crédito Acumulado de ICMS
			aCampos := {"CFF_ITEMNF", "CFF_CODIGO", "CFF_CODLEG", "CFF_ANEXO", "CFF_ART", "CFF_INC", "CFF_ALIN", "CFF_PRG", "CFF_ITM", "CFF_LTR", "CFF_OBS"}
			cTabela := "CFF"
		Case nX == 22 .And. lCompCF8
		//Demais Docs. PIS COF.
			aCampos := {"CF8_DOC","CF8_SERIE","CF8_CLIFOR","CF8_LOJA","CF8_DTOPER","CF8_VLOPER","CF8_CSTPIS","CF8_BASPIS","CF8_ALQPIS","CF8_VALPIS","CF8_CSTCOF","CF8_BASCOF",;
						"CF8_ALQCOF","CF8_VALCOF","CF8_RECBRU","CF8_CODBCC","CF8_INDORI","CF8_ITEM","CF8_INDOPE","CF8_TPREG","CF8_PART","CF8_CODCTA",;
						"CF8_CNATRE","CF8_CODCCS","CF8_DESCPR","CF8_TNATRE","CF8_GRPNC","CF8_DTFIMN","CF8_SCORGP","CF8_SALDO","CF8_PROJ"}
			cTabela := "CF8"
		Case nX == 23 .And. lCompF0A
			aCampos := {"F0A_ITEM","F0A_COD","F0A_LOTE","F0A_QTDLOT","F0A_FABRIC","F0A_VALID","F0A_CODAGR"}
			aCabPer := {"F0A_FILIAL","F0A_DOC","F0A_SERIE","F0A_CLIFOR","F0A_LOJA","F0A_TPMOV","F0A_ITEM","F0A_COD"}
			aPermite	:= aClone(aRastr)
			cTabela := "F0A"
	EndCase

	If Len(aCampos) > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montando aHeader                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(2)
		For nY := 1 to Len(aCampos)

			If SX3->(dbSeek(aCampos[nY]))
				If X3USO(SX3->X3_USADO) .Or. (SX3->X3_ARQUIVO == "CDL" .And.  X3USO(SX3->X3_USADO,9))
					cF3 	:= SX3->X3_F3
					cValid	:= SX3->X3_VALID
					cWhen	:= SX3->X3_WHEN

					//Ajusta consulta padrão de acordo com o documento (ENtrada/Saida)
					If nX == 10
						If AllTrim(SX3->X3_CAMPO) == "CDG_ITEM"
							If cEntSai == "S"
								cF3 := "SD2CDG"
							Else
								cF3 := "SD1CDG"
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³A consulta padrao do documento referenciado vai mudar de acordo com ³
					//³o tipo de documento - entrada/saida                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nX == 12

						IF lCompDoc
							If SX3->X3_CAMPO == "CDD_DOCREF" 
								cF3 := "DOCRFT"								
							Endif
						Else
							If SX3->X3_CAMPO == "CDD_DOCREF"
								If cEntSai == "S"
									If cTpNF $ "DB"
										cF3 := "DOCREN"
									Else
										cF3 := "DOCRS"
									Endif
								Else
									If cTpNF $ "DB"
										cF3 := "DOCRS"
									Else
										cF3 := "DOCREN"
									Endif
								Endif
							Endif

							If SX3->X3_CAMPO == "CDD_PARREF"
								If cEntSai == "S"
									If cTpNF $ "DB"
										cF3 	:= "SA2"
										cValid	:= 'ExistCpo("SA2")'
									Else
										cF3 	:= "SA1"
										cValid	:= 'ExistCpo("SA1")'
									Endif
								Else
									If cTpNF $ "DB"
										cF3 	:= "SA1"
										cValid	:= 'ExistCpo("SA1")'
									Else
										cF3 	:= "SA2"
										cValid	:= 'ExistCpo("SA2")'
									Endif
								Endif
							Endif

							If SX3->X3_CAMPO == "CDD_LOJREF"
								If cEntSai == "S"
									If cTpNF $ "DB"
										cValid	:= "ExistCpo('SA2',GDFieldGet('CDD_PARREF')+M->CDD_LOJREF)"
									Else
										cValid	:= "ExistCpo('SA1',GDFieldGet('CDD_PARREF')+M->CDD_LOJREF)"
									Endif
								Else
									If cTpNF $ "DB"
										cValid	:= "ExistCpo('SA1',GDFieldGet('CDD_PARREF')+M->CDD_LOJREF)"
									Else
										cValid	:= "ExistCpo('SA2',GDFieldGet('CDD_PARREF')+M->CDD_LOJREF)"
									Endif
								Endif
							Endif
						Endif

					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³A consulta padrao do local de coleta/entrega vai mudar de acordo com   ³
					//³o tipo de documento - entrada/saida                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nX == 14
						If SX3->X3_CAMPO == "CDF_ENTREG"
							If cEntSai == "S"
								If cTpNF $ "DB"
									cF3 	:= "SA2"
									cValid	:= 'ExistCpo("SA2")'
								Else
									cF3 	:= "SA1"
									cValid	:= 'ExistCpo("SA1")'
								Endif
							Endif
						Endif

						If SX3->X3_CAMPO == "CDF_LOJENT"
							If cEntSai == "S"
								If cTpNF $ "DB"
									cValid	:= "ExistCpo('SA2',GDFieldGet('CDF_ENTREG')+M->CDF_LOJENT)"
								Else
									cValid	:= "ExistCpo('SA1',GDFieldGet('CDF_ENTREG')+M->CDF_LOJENT)"
								Endif
							Endif
						Endif

						If SX3->X3_CAMPO == "CDF_COLETA"
							If cEntSai == "S"
								If cTpNF $ "DB"
									cF3 	:= "SA2"
									cValid	:= 'ExistCpo("SA2")'
								Else
									cF3 	:= "SA1"
									cValid	:= 'ExistCpo("SA1")'
								Endif
							Endif
						Endif

						If SX3->X3_CAMPO == "CDF_LOJCOL"
							If cEntSai == "S"
								If cTpNF $ "DB"
									cValid	:= "ExistCpo('SA2',GDFieldGet('CDF_COLETA')+M->CDF_LOJCOL)"
								Else
									cValid	:= "ExistCpo('SA1',GDFieldGet('CDF_COLETA')+M->CDF_LOJCOL)"
								Endif
							Endif
						Endif
					Endif

					If nX == 16
						If SX3->X3_CAMPO $ "CDL_ITEMNF"
							cWhen := ".T."
						EndIf
					Endif

					aAdd(aHeader,{Alltrim(X3Titulo(SX3->X3_TITULO)),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						cValid,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						cF3,;
						SX3->X3_CONTEXT,;
						/*CBOX*/,;
						/*RELACAO*/,;
						cWhen})
				Endif
				If X3Obrigat(SX3->X3_CAMPO)
					aAdd(aObrigat[nX],{SX3->X3_CAMPO,SX3->X3_TIPO})
				Endif
			Endif
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta os filtros para cada uma das tabelas para carregar o aCols ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lPossui := M926Filtro(cTabela,@cArqInd,@cChave,@cAlias,@lQuery,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF)

		If !lPossui
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para os complementos por item, carrega com o conteudo dos itens do SFT³
			//³que permitem o complemento.                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aPermite) > 0
				For nI := 1 to Len(aPermite)
					aAdd(aCols,Array(Len(aHeader)+1))
					aCols[Len(aCols)][Len(aHeader)+1] := .F.
					For nY := 1 To Len(aHeader)
						aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
						nScan := aScan(aCabPer,{|x| x == Alltrim(aHeader[nY][2])})
						If nScan > 0
							aCols[Len(aCols)][nY] := aPermite[nI][nScan]
						Endif
					Next nY
				Next
			Else
				aAdd(aCols,Array(Len(aHeader)+1))
				aCols[Len(aCols)][Len(aHeader)+1] := .F.
				For nY := 1 To Len(aHeader)
					aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
				Next nY
			Endif
		Else
			nCount := 1
			dbSelectArea(cAlias)
			While !Eof()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Os complementos de agua somente possuem complemento por NF³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*If nX == 1 .And. nCount > 1
					Exit
				Endif*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Sera necessario armazenar os complementos de importacao gravados anteriormente.         ³
				//³Como neste tipo de complemento e possivel alterar o numero do documento de importacao   ³
				//³(que faz parte da chave), armazena-se os complementos existentes para a atualização das ³
				//³informacoes prestadas pelo usuario.                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nX == 7 .And. cTabela == "CD5"
					aAdd(aMantem[1],{CD5_DOC,CD5_SERIE,CD5_FORNEC,CD5_LOJA,CD5_DOCIMP,Str(CD5_ALPIS,5,2),Str(CD5_ALCOF,5,2),CD5_NADIC,CD5_ITEM,.F.})
				Endif
				If nX == 10 .And. cTabela == "CDG"
					aAdd(aMantem[2],{CDG_PROCES,CDG_TPPROC,Iif(lProcRef,CDG_ITEM,""),Iif(lProcRef,CDG_ITPROC,""),.F.})
				Endif
				If nX == 11 .And. cTabela == "CDC"
					aAdd(aMantem[3],{CDC_GUIA,CDC_UF,CDC_DCCOMP,.F.})
				Endif
				If nX == 12 .And. cTabela == "CDD"	
					aAdd(aMantem[4],{})	
					nPosMt := len(aMantem[4])			
					If lCompDoc 
						aAdd(aMantem[4][nPosMt],"CDD_DOCREF")
						aAdd(aMantem[4][nPosMt],"CDD_SERREF")
						aAdd(aMantem[4][nPosMt],"CDD_PARREF")
						aAdd(aMantem[4][nPosMt],"CDD_LOJREF")
						aAdd(aMantem[4][nPosMt],"CDD_CHVNFE")
						aAdd(aMantem[4][nPosMt],"CDD_ENTSAI")
						if lCddMnRf
							aAdd(aMantem[4][nPosMt],"CDD_MEANRF") 
						Endif
						if lCddMdRf
							aAdd(aMantem[4][nPosMt],"CDD_MODREF") 
						Endif
						aAdd(aMantem[4][nPosMt],.F.)
					ElseIf CDD->(ColumnPos("CDD_CHVNFE"))>0
						aAdd(aMantem[4][nPosMt],"CDD_DOCREF")
						aAdd(aMantem[4][nPosMt],"CDD_SERREF")
						aAdd(aMantem[4][nPosMt],"CDD_PARREF")
						aAdd(aMantem[4][nPosMt],"CDD_LOJREF")
						aAdd(aMantem[4][nPosMt],"CDD_CHVNFE")
						if lCddMnRf
							aAdd(aMantem[4][nPosMt],"CDD_MEANRF")
						Endif
						if lCddMdRf
							aAdd(aMantem[4][nPosMt],"CDD_MODREF")
						Endif
						aAdd(aMantem[4][nPosMt],.F.)
					Else
						aAdd(aMantem[4][nPosMt],"CDD_DOCREF")
						aAdd(aMantem[4][nPosMt],"CDD_SERREF")
						aAdd(aMantem[4][nPosMt],"CDD_PARREF")
						aAdd(aMantem[4][nPosMt],"CDD_LOJREF")
						if lCddMnRf
							aAdd(aMantem[4][nPosMt],"CDD_MEANRF")
						Endif
						if lCddMdRf
							aAdd(aMantem[4][nPosMt],"CDD_MODREF")
						Endif
						aAdd(aMantem[4][nPosMt],.F.)
					Endif
					
				Endif
				If nX == 15 .And. cTabela == "CDT"
					aAdd(aMantem[6],{CDT_IFCOMP,CDT_DCCOMP,.F.})
				Endif
				If nX == 16 .And. cTabela == "CDL" .And. lCompExp
					If lSdoc
						aAdd(aMantem[5],{CDL_DOC,CDL_SERIE,CDL_CLIENT,CDL_LOJA,CDL_NUMDE,CDL_DOCORI,CDL_SERORI,CDL_FORNEC,CDL_LOJFOR,CDL_NRREG,CDL_ITEMNF,CDL_NRMEMO,CDL_DTORI,.F.})
					Else
						aAdd(aMantem[5],{CDL_DOC,CDL_SERIE,CDL_CLIENT,CDL_LOJA,CDL_NUMDE,CDL_DOCORI,CDL_SERORI,CDL_FORNEC,CDL_LOJFOR,CDL_NRREG,CDL_ITEMNF,CDL_NRMEMO,.F.})
					EndIF
				Endif
				If nX == 17 .And. cTabela == "CDR" .And. lAnfavea
					aAdd(aMantem[7],{CDR_TPMOV,CDR_DOC,CDR_SERIE,CDR_CLIFOR,CDR_LOJA,.F.})
				Endif
				If nX == 18 .And. cTabela == "CDS" .And. lAnfavea
					aAdd(aMantem[7],{CDS_TPMOV,CDS_SERIE,CDS_DOC,CDS_CLIFOR,CDS_LOJA,CDS_ITEM,CDS_PRODUTO,.F.})
				Endif
				If nX == 19 .And. cTabela == "CD0"
					aAdd(aMantem[10],{CD0_TPMOV,CD0_SERIE,CD0_DOC,CD0_CLIFOR,CD0_LOJA,CD0_ITEM,CD0_COD,.F.})
				Endif
				If nX == 20 .And. cTabela == "CG8"
					aAdd(aMantem[10],{CG8_TPESP,CG8_VLINC,CG8_USOCONR,CG8_CODORI,CG8_CODDES,.F.})
				Endif
				If nX == 21 .And. cTabela == "CFF"
					aAdd(aMantem[10],{CFF_CODIGO,CFF_CODLEG, CFF_ANEXO, CFF_ART, CFF_INC, CFF_ALIN, CFF_PRG, CFF_ITM,CFF_LTR, CFF_OBS,.F.})
				Endif

				nCount++

				Aadd(aCols,Array(Len(aHeader)+1))

				For nY :=1 to Len(aHeader)
					cTipo := aHeader[nY][8]
					If cTipo == "D"
						cData := (cAlias)->(FieldGet(FieldPos(aHeader[nY,2])))
						If !Empty(cData)
							#IFDEF TOP
								cData2:= substr(cdata,7,2)+'/'+substr(cdata,5,2)+'/'+substr(cdata,1,4)
							#ELSE
								cData2:= dtoc(cdata)
							#ENDIF
						Else
							cData2:= "  /  /    "
						Endif
						aCols[Len(aCols)][nY] := Ctod(cData2)
					Else
						aCols[Len(aCols)][nY] := (cAlias)->(FieldGet(FieldPos(aHeader[nY,2])))
						If nX == 10 //Processos referenciados (CDG)
							If nY == 5 .And. Empty(aCols[Len(aCols)][nY]) //Campo: CDG_DESCCF
								aCols[Len(aCols)][nY] := MT926PRPOS(xFilial('CCF'), aCols[Len(aCols)][02], aCols[Len(aCols)][03], aCols[Len(aCols)][04])
							EndIf
						EndIf
					EndIf
				Next nY
				aCols[Len(aCols)][Len(aHeader)+1] := .F.
				dbSelectArea(cAlias)
				dbSkip()
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ao reabrir a tela de complementos apos exclusao, deve-se verificar os campos que devem ser preenchidos pela	³
			//³rotina, coloca-los em ordem e apresentar na tela todos os itens da nota fiscal novamente						³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTabela $ "CD5/CD6"
				For nG := 1 To Len(aPermite)
					If aScan(aCols,{|aX|aX[1]==aPermite[nG,7]})==0
						aAdd(aCols,Array(Len(aHeader)+1))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Importacao - Itens excluidos sao reabertos com o campo CD5_ITEM preenchido.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cTabela == "CD5"
							aCols[Len(aCols)][1] := aPermite[nG,7]
							For nY := 2 To Len(aHeader)
								aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
								aCols[Len(aCols)][Len(aHeader)+1] := .F.
							Next nY
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Combustiveis - Itens excluidos sao reabertos com os campos CD6_ITEM e CD6_COD preenchidos.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Elseif cTabela $ "CD6"
							aCols[Len(aCols)][1] := aPermite[nG,7]
							aCols[Len(aCols)][2] := aPermite[nG,8]
							For nY := 3 To Len(aHeader)
								aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
								aCols[Len(aCols)][Len(aHeader)+1] := .F.
							Next nY
						Endif
					EndIf
				Next nG
				aSort(aCols,,,{|x,y| x[1]<y[1]})
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha as areas montadas para o filtro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M926Close(cTabela,cArqInd,cAlias,lQuery)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada que permite incluir novas validações³
		//³nos campos de Complemento                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lM926VlCpNF
			for nA:=1 to len(aHeader)
				cValidCpoAnt := AllTrim(aHeader[nA][6]) //Preservar as validações do sistema
				cValidCpoNov := ExecBlock("M926VlCpNF",.F.,.F.,{aHeader[nA][2],aHeader[nA][6]})
				If !cValidCpoAnt$cValidCpoNov .and. !Empty(cValidCpoAnt)
					aHeader[nA][6] := cValidCpoAnt + " .and. " + cValidCpoNov
				Else
					aHeader[nA][6] := cValidCpoNov
				Endif
			next
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Passa o conteudo do aHeader e do aCols de acordo com o complemento         ³
		//³Carrega o aCols com os itens que devem gerar o complemento em notas fiscais³
		//³que ainda nao possuam o complemento cadastrado.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
		Case nX == 1
			// agua canalizada
			aHAgua	:=	aHeader
			aCAgua	:=	aCols
		Case nX == 2
			// arma de fogo
			aHArma	:=	aHeader
			aCArma	:=	aCols
		Case nX == 3
			// combustivel
			aHComb	:=	aHeader
			aCComb	:=	aCols
		Case nX == 4
			// comunicacao/telecomunicacao
			aHComun	:= aHeader
			aCComun	:=	aCols
		Case nX == 5
			// energia eletrica
			aHEner	:=	aHeader
			aCEner	:=	aCols
		Case nX == 6
			// gas canalizado
			aHGas	:=	aHeader
			aCGas	:=	aCols
		Case nX == 7
			// importacao - por nota fiscal
			aHImp	:=	aHeader
			aCImp	:=	aCols
		Case nX == 8
			// medicamentos
			aHMed	:=	aHeader
			aCMed	:=	aCols
		Case nX == 9
			// veiculos
			aHVeic	:=	aHeader
			aCVeic	:=	aCols
		Case nX == 10
			// processos referenciados
			aHProc	:=	aHeader
			aCProc	:=	aCols
		Case nX == 11
			// guia de recolhimento referenciada
			aHGuia	:=	aHeader
			aCGuia	:=	aCols
		Case nX == 12
			// documento referenciado
			aHDoc 	:=	aHeader
			aCDoc 	:=	aCols
		Case nX == 13
			// cupom fiscal referenciado
			aHCp  	:=	aHeader
			aCCp  	:=	aCols
		Case nX == 14
			// local da coleta e entrega
			aHLoc	:=	aHeader
			aCLoc	:=	aCols
		Case nX == 15
			// Informaçoes Complementares
			aHInfc	:=	aHeader
			aCInfc	:=	aCols
		Case nX == 16
			// exportacao
			aHExp	:=	aHeader
			aCExp	:=	aCols
		Case nX == 17
			// Anfavea Cab
			aHAnfC	:=	aHeader
			aCAnfC	:=	aCols
		Case nX == 18
			// Anfavea Itens
			aHAnfI	:=	aHeader
			aCAnfI	:=	aCols
		Case nX == 19
			// Ressarcimento
			aHRes	:=	aHeader
			aCRes	:=	aCols
		Case nX == 20
			// Remas
			aHRemas	:=	aHeader
			aCRemas	:=	aCols
		Case nX == 21
			// Credito Acumulado ICMS
			aHCrdAcum	:=	aHeader
			aCCrdAcum	:=	aCols
		Case nX == 22
			// Demais Docs. PIS COF
			aHCCF8	:=	aHeader
			aCCCF8	:=	aCols
		Case nX == 23
			// Rastreabilidade
			aHRastr	:=	aHeader
			aCRastr	:=	aCols
		EndCase
	Endif
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M926NF   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria o cabecalho dos complementos (fixo para todos os mode-³±±
±±³          ³ los com os dados da nota fiscal a ser complementada)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Painel onde os componentes serao inseridos         ³±±
±±³          ³ ExpO2 = Font a ser utilizada                               ³±±
±±³          ³ ExpN3 = Altura padrao dos objetos Say                      ³±±
±±³          ³ ExpN4 = Tamanho padrao dos objetos Say                     ³±±
±±³          ³ ExpN5 = Altura padrao dos objetos Get                      ³±±
±±³          ³ ExpC6 = Numero da nota fiscal                              ³±±
±±³          ³ ExpC7 = Serie da nota fiscal                               ³±±
±±³          ³ ExpC8 = Especie da nota fiscal                             ³±±
±±³          ³ ExpC9 = Codigo do cliente/fornecedor                       ³±±
±±³          ³ ExpCA = Loja do cliente/fornecedor                         ³±±
±±³          ³ ExpCB = Movimento de Entrada ou Saida                      ³±±
±±³          ³ ExpCC = Indica se a NF e de devol./beneficiamento          ³±±
±±³          ³ ExpAD = Coordenadas dos paineis principais                 ³±±
±±³          ³ ExpAE = Painel onde serao montados os dados da NF          ³±±
±±³          ³ ExpOF = Dialog principal                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926NF(oFont,nAltSay,nTamSay,nAltGet,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCoord,aPnlNF,oDlg,lIndFrt,lIndExt,lDatRecb,lCodMun) 

Local aOpcao		:= {}
Local aColuna		:= {15,65,145,185,250,298}
Local bSay			:= {|| Nil}
Local bVar			:= {|| Nil}
Local bWhen			:= {|| Nil}

Local cOpcao		:= ""
Local cPesqF3		:= ""

Local nLinSay		:= 19
Local nLinGet		:= 17
Local nTamGet		:= 55
Local nTamGet2		:= 30

Local oGrpNF
Local oPanel

Local oDescMun	
Local cDescMun 		:= ""
Local aObjetos 		:= Array(2)

DEFAULT	lIndFrt		:= .F.
DEFAULT	lIndExt		:= .F.
DEFAULT lDatRecb	:= .F.
Default	lCodMun		:= .F.

oPanel := TPanel():New(aCoord[2][1],aCoord[2][2],'',oDlg,oDlg:oFont,.T.,.T.,,,aCoord[2][4],aCoord[2][3],.T.,.T.)
aAdd(aPnlNF,oPanel)

oGrpNF := TGroup():New(5,5,aCoord[2][3]-5,aCoord[2][4]-5,STR0023,oPanel,,,.T.,.T.) //"Informações do documento fiscal"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo de documento - entrada/saida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aOpcao,STR0016) //"Entrada"
aAdd(aOpcao,STR0017) //"Saída"

bSay := &('{|| "' + STR0015 + '"}') // "Tipo"
TSay():New(nLinSay,aColuna[1],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

bVar := &("{ | u | If( PCount() == 0, cOpcao,cOpcao := u)}")
oCombo := TCombobox():New(nLinGet,aColuna[2],bVar,aOpcao,nTamGet,10,oGrpNF,,,,,,.T.,,,,bWhen)
oCombo:lReadOnly := .T.

If cEntSai == "E"
	oCombo:nAt := 1
Else
	oCombo:nAt := 2
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indicacao da Escrituração extemporânea   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIndExt
	aOpcao := {}
	aAdd(aOpcao,"Ext regular")
	aAdd(aOpcao,"Ext complementar")
	aAdd(aOpcao,"")

	cOpcaoExt:= ""
	If CDT->(dbSeek(xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja))
		Do Case
			Case CDT->CDT_SITEXT == "R"
				cOpcaoExt := aOpcao[1]
			Case CDT->CDT_SITEXT == "P"
				cOpcaoExt := aOpcao[2]
		EndCase
	EndIf

	bSay := &('{|| "' + "Extemporânea" + '"}')
	TSay():New(nLinSay,aColuna[3],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

	bVar   := &("{ | u | If( PCount() == 0, cOpcaoExt,cOpcaoExt := u)}")
	oCombo := TCombobox():New(nLinGet,aColuna[4],bVar,aOpcao,nTamGet,10,oGrpNF,,,,,,.T.,,,,bWhen)
Endif
lIndExt:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Data de Recebimento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDatRecb
	If CDT->(dbSeek(xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja))
		dDatReceb	:=	CDT->CDT_DTAREC
	EndIf

	bSay := &('{|| "' + "Data Recebimento" + '"}')
	TSay():New(nLinSay,aColuna[5],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

	bVar := &("{|u| If(PCount()== 0,dDatReceb,dDatReceb :=u)}")
	TGet():New(nLinGet,aColuna[6],bVar,oGrpNF,nTamGet,nAltGet,PesqPict("CDT","CDT_DTAREC"),,,,,,,.T.,,,,,,,,,,)

	nLinSay := nLinSay + 18
	nLinGet := nLinGet + 18
Endif
lDatRecb := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Numero da nota fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bSay := &('{|| "' + STR0024 + '"}') // "Número"
TSay():New(nLinSay,aColuna[1],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

bVar := &("{ | u | If( PCount() == 0, cDoc,cDoc := u)}")
TGet():New(nLinGet,aColuna[2],bVar,oGrpNF,nTamGet,nAltGet,"@!",,,,,,,.T.,,, bWhen,,,,.T.,,,cDoc)
cDocStat := Eval({ | u | If( PCount() == 0, cDoc,cDoc := u)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Serie da nota fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bSay := &('{|| "' + STR0014 + '"}') // "Serie"
TSay():New(nLinSay,aColuna[3],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

bVar := &("{ | u | If( PCount() == 0, cSerie,cSerie := u)}")
TGet():New(nLinGet,aColuna[4],bVar,oGrpNF,nTamGet2,nAltGet,"!!!",,,,,,,.T.,,, bWhen,,,,.T.,,,cSerie)
cSerStat := Eval({ | u | If( PCount() == 0, cSerie,cSerie := u)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Especie da nota fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bSay := &('{|| "' + STR0018 + '"}') // "Espécie"
TSay():New(nLinSay,aColuna[5],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

bVar := &("{ | u | If( PCount() == 0, cEspecie,cEspecie := u)}")
TGet():New(nLinGet,aColuna[6],bVar,oGrpNF,nTamGet2,nAltGet,"@!",,,,,,,.T.,,, bWhen,,,,.T.,,"42")
cEspStat := Eval({ | u | If( PCount() == 0, cEspecie,cEspecie := u)})

nLinSay := nLinSay + 18
nLinGet := nLinGet + 18

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cliente/Fornecedor da nota fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bSay := &('{|| "' + STR0019 + '"}') // "Cliente/fornecedor"
TSay():New(nLinSay,aColuna[1],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

// Verifica se e cliente ou fornecedor para montar o F3 do get
If cEntSai == "E"
	If cTpNF $ "DB"
		cPesqF3 := "SA1"
	Else
		cPesqF3 := "SA2"
	Endif
Else
	If cTpNF $ "DB"
		cPesqF3 := "SA2"
	Else
		cPesqF3 := "SA1"
	Endif
Endif
bVar := &("{ | u | If( PCount() == 0, cClieFor,cClieFor := u)}")
TGet():New(nLinGet,aColuna[2],bVar,oGrpNF,nTamGet,nAltGet,"@!",,,,,,,.T.,,, bWhen,,,,.T.,,cPesqF3)
cCliStat := Eval({ | u | If( PCount() == 0, cClieFor,cClieFor := u)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loja da nota fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bSay := &('{|| "' + STR0020 + '"}') // "Loja"
TSay():New(nLinSay,aColuna[3],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

bVar := &("{ | u | If( PCount() == 0, cLoja,cLoja := u)}")
TGet():New(nLinGet,aColuna[4],bVar,oGrpNF,nTamGet2,nAltGet,"@!",,,,,,,.T.,,, bWhen,,,,.T.,,)
cLojStat := Eval({ | u | If( PCount() == 0, cLoja,cLoja := u)})

If lIndFrt
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indicacao de Frete  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aOpcao := {}
	aAdd(aOpcao,"Terceiros")    //0
	aAdd(aOpcao,"Emitente")     //1
	aAdd(aOpcao,"Destinatário") //2
	aAdd(aOpcao,"Transp. Próp. por conta Remetente") //3
	aAdd(aOpcao,"Transp. Próp. por conta Destinatário") //4
	aAdd(aOpcao,"Sem frete")    //9
	aAdd(aOpcao,"")
	cOpcaoFrt := ""
	If CDT->(dbSeek(xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja))
		Do Case
			Case CDT->CDT_INDFRT == "0"
				cOpcaoFrt := aOpcao[1]
			Case CDT->CDT_INDFRT == "1"
				cOpcaoFrt := aOpcao[2]
			Case CDT->CDT_INDFRT == "2"
				cOpcaoFrt := aOpcao[3]
			Case CDT->CDT_INDFRT == "3" //R = Por conta remetente
				cOpcaoFrt := aOpcao[4]
			Case CDT->CDT_INDFRT == "4" //D = Por conta destinatário
				cOpcaoFrt := aOpcao[5]
			Case CDT->CDT_INDFRT == "9"
				cOpcaoFrt := aOpcao[6]
		EndCase
	EndIf

	bSay := &('{|| "' + "Frete" + '"}')
	TSay():New(nLinSay,aColuna[5],bSay,oGrpNF,,oFont,.F.,.F.,.F.,.T.,,,nTamSay,nAltSay,.F.,.F.,.F.,.F.,.F.)

	bVar   := &("{ | u | If( PCount() == 0, cOpcaoFrt,cOpcaoFrt := u)}")
	oCombo := TCombobox():New(nLinGet,aColuna[6],bVar,aOpcao,42,10,oGrpNF,,,,,,.T.,,,,bWhen)

	
EndIf

//Codigo de Municipio de Destino
IF lCodMun
	nLinSay := nLinSay + 18
	nLinGet := nLinGet + 18

	If CDT->(dbSeek(xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja)) 
		cUFDest	:=	CDT->CDT_UFDEST
		cMdest	:=  CDT->CDT_MDEST
	EndIf	

	@ nLinSay,aColuna[1] SAY "UF Destino" Of oGrpNF PIXEL SIZE nTamSay,nAltSay
	@ nLinSay,aColuna[2] MSGET aObjetos[1] VAR cUFDest WHEN .T. PICTURE PesqPict("CDT","CDT_UFDEST") ;
						 SIZE nTamGet,nAltGet PIXEL OF oGrpNF F3 CpoRetF3("CDT_UFDEST") ;
						 VALID Vazio() .Or. ExistCpo("SX5","12"+cUFDest)
	aObjetos[1]:cSX1Hlp := "CDT_UFDEST"						 
						 	

	@ nLinSay,aColuna[3] SAY "Município" Of oGrpNF PIXEL SIZE nTamSay,nAltSay
	@ nLinSay,aColuna[4] MSGET aObjetos[2] VAR cMdest WHEN .T. PICTURE PesqPict("CDT","CDT_MDEST") ;
						SIZE nTamGet,nAltGet PIXEL OF oGrpNF F3 CpoRetF3("CDT_MDEST") ;
						VALID Vazio() .Or. DescMun(Alltrim(cMdest),@oDescMun,@cDescMun,Alltrim(cUFDest))
	aObjetos[2]:cSX1Hlp := "CDT_MDEST"
	
	@ nLinSay,aColuna[5] MSGET oDescMun VAR cDescMun WHEN .F. OF oGrpNF PIXEL SIZE 130,006
	If !Empty(cMdest)		
		DescMun(Alltrim(cMdest),@oDescMun,@cDescMun,Alltrim(cUFDest))
	Endif
		
Endif
	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Filtro³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua o filtro/query de todos os complementos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome da tabela                                     ³±±
±±³          ³ ExpC2 = Indice criado para codebase                        ³±±
±±³          ³ ExpC3 = Alias criado para top                              ³±±
±±³          ³ ExpL4 = Indicacao de top/codebase                          ³±±
±±³          ³ ExpC5 = Numero da nota fiscal                              ³±±
±±³          ³ ExpC6 = Serie da nota fiscal                               ³±±
±±³          ³ ExpC7 = Especie da nota fiscal                             ³±±
±±³          ³ ExpC8 = Cliente/fornecedor                                 ³±±
±±³          ³ ExpC9 = Loja do cliente/fornecedor                         ³±±
±±³          ³ ExpCA = Indicacao de entrada/saida                         ³±±
±±³          ³ ExpCB = Indica se a NF e de devol./beneficiamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Filtro(cTabela,cArqInd,cChave,cAlias,lQuery,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF)

Local aArea		:= GetArea()
Local cWhere	:= ""
Local cCondicao := ""
Local cCampo	:= ""

Local lPossui	:= .F.
Local lPrim		:= .T. //Variavel de controle para o primeiro campo da Select
Local aCmpSx3	:= {}  //Array que vai buscar dados do SX3
Local nY		:= 0
Local lCmpCFF 	:= CFF->(FieldPos('CFF_TIPO')) > 0

#IFDEF TOP
	Local cSelect	:= "" 
	Local cFrom		:= ""
	Local cOrder	:= ""
#ENDIF

cAlias := cTabela
dbSelectArea(cTabela)

If Left(cTabela,2) $ "CD/CG/CF/F0"
	cCampo	:= SubStr(cTabela,1,3)
Else
	cCampo	:= SubStr(cTabela,2,3)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a chave e a condicao padrao para todos os filtros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	cFrom		:= "%" + RetSqlName(cTabela) + " " + cTabela + "%"
	cOrder		:= "%" + SqlOrder((cTabela)->(IndexKey())) + "%"
	cWhere		:= "%" + cTabela + "." + cCampo + "_FILIAL" + " = '" + xFilial(cTabela) + "' AND "
#ELSE
	cChave		:= (cTabela)->(IndexKey())
	cCondicao	:= cCampo + '_FILIAL == "' + xFilial(cTabela) + '" .AND. '
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta as expressoes de acordo com cada tabela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case

	Case cTabela == "CD3"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CD3.CD3_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CD3.CD3_DOC = '" + cDoc + "' AND "
		cWhere		+= "CD3.CD3_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CD3.CD3_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CD3.CD3_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CD3_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CD3_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CD3_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CD3_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CD3_LOJA == "' + cLoja + '"'

	Case cTabela == "CD4"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CD4.CD4_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CD4.CD4_DOC = '" + cDoc + "' AND "
		cWhere		+= "CD4.CD4_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CD4.CD4_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CD4.CD4_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CD4_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CD4_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CD4_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CD4_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CD4_LOJA == "' + cLoja + '"'

	Case cTabela == "CD5"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CD5.CD5_DOC = '" + cDoc + "' AND "
		cWhere		+= "CD5.CD5_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CD5.CD5_FORNEC = '" + cClieFor + "' AND "
		cWhere		+= "CD5.CD5_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CD5_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CD5_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CD5_FORNEC == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CD5_LOJA == "' + cLoja + '"'

	Case cTabela == "CD6"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CD6.CD6_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CD6.CD6_DOC = '" + cDoc + "' AND "
		cWhere		+= "CD6.CD6_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CD6.CD6_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CD6.CD6_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CD6_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CD6_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CD6_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CD6_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CD6_LOJA == "' + cLoja + '"'

	Case cTabela == "CD7"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CD7.CD7_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CD7.CD7_DOC = '" + cDoc + "' AND "
		cWhere		+= "CD7.CD7_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CD7.CD7_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CD7.CD7_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CD7_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CD7_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CD7_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CD7_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CD7_LOJA == "' + cLoja + '"'

	Case cTabela == "CD8"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CD8.CD8_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CD8.CD8_DOC = '" + cDoc + "' AND "
		cWhere		+= "CD8.CD8_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CD8.CD8_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CD8.CD8_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CD8_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CD8_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CD8_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CD8_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CD8_LOJA == "' + cLoja + '"'

	Case cTabela == "CD9"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CD9.CD9_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CD9.CD9_DOC = '" + cDoc + "' AND "
		cWhere		+= "CD9.CD9_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CD9.CD9_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CD9.CD9_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CD9_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CD9_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CD9_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CD9_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CD9_LOJA == "' + cLoja + '"'

	Case cTabela == "SFU"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "SFU.FU_TIPOMOV = '" + cEntSai + "' AND "
		cWhere		+= "SFU.FU_DOC = '" + cDoc + "' AND "
		cWhere		+= "SFU.FU_SERIE = '" + cSerie + "' AND "
		cWhere		+= "SFU.FU_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "SFU.FU_LOJA = '" + cLoja + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'FU_TIPOMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'FU_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'FU_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'FU_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'FU_LOJA == "' + cLoja + '"'

	Case cTabela == "SFX"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "SFX.FX_TIPOMOV = '" + cEntSai + "' AND "
		cWhere		+= "SFX.FX_DOC = '" + cDoc + "' AND "
		cWhere		+= "SFX.FX_SERIE = '" + cSerie + "' AND "
		cWhere		+= "SFX.FX_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "SFX.FX_LOJA = '" + cLoja + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'FX_TIPOMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'FX_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'FX_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'FX_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'FX_LOJA == "' + cLoja + '"'

	Case cTabela == "CDG"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CDG.CDG_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CDG.CDG_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDG.CDG_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDG.CDG_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CDG.CDG_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDG_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CDG_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDG_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDG_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDG_LOJA == "' + cLoja + '"'

	Case cTabela == "CDT"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CDT.CDT_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CDT.CDT_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDT.CDT_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDT.CDT_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CDT.CDT_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDT_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CDT_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDT_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDT_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDT_LOJA == "' + cLoja + '"'

	Case cTabela == "CDC"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CDC.CDC_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CDC.CDC_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDC.CDC_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDC.CDC_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CDC.CDC_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDC_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CDC_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDC_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDC_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDC_LOJA == "' + cLoja + '"'

	Case cTabela == "CDD"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CDD.CDD_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CDD.CDD_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDD.CDD_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDD.CDD_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CDD.CDD_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDD_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CDD_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDD_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDD_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDD_LOJA == "' + cLoja + '"'

	Case cTabela == "CDE"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CDE.CDE_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CDE.CDE_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDE.CDE_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDE.CDE_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CDE.CDE_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDE_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CDE_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDE_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDE_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDE_LOJA == "' + cLoja + '"'

	Case cTabela == "CDF"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CDF.CDF_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CDF.CDF_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDF.CDF_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDF.CDF_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CDF.CDF_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDF_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CDF_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDF_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDF_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDF_LOJA == "' + cLoja + '"'

	Case cTabela == "CDL" .And. lCompExp

		cWhere		+= "CDL.CDL_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDL.CDL_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDL.CDL_CLIENT = '" + cClieFor + "' AND "
		cWhere		+= "CDL.CDL_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDL_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDL_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDL_CLIENT == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDL_LOJA == "' + cLoja + '"'

	Case cTabela == "CDR"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CDR.CDR_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CDR.CDR_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDR.CDR_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDR.CDR_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CDR.CDR_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDR_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CDR_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDR_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDR_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDR_LOJA == "' + cLoja + '"'

	Case cTabela == "CDS"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CDS.CDS_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CDS.CDS_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CDS.CDS_DOC = '" + cDoc + "' AND "
		cWhere		+= "CDS.CDS_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CDS.CDS_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CDS_TPMOV == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CDS_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CDS_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CDS_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CDS_LOJA == "' + cLoja + '"'

	Case cTabela == "CD0"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere		+= "CD0.CD0_TPMOV = '" + cEntSai + "' AND "
		cWhere		+= "CD0.CD0_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CD0.CD0_DOC = '" + cDoc + "' AND "
		cWhere		+= "CD0.CD0_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CD0.CD0_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao 	+= 'CD0_TPMOV  == "' + cEntSai + '" .AND. '
		cCondicao 	+= 'CD0_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CD0_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CD0_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CD0_LOJA == "' + cLoja + '"'

	Case cTabela == "CG8"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cWhere		+= "CG8.CG8_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CG8.CG8_NUMDOC = '" + cDoc + "' AND "
		cWhere		+= "CG8.CG8_FORNEC = '" + cClieFor + "' AND "
		cWhere		+= "CG8.CG8_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cCondicao 	+= 'CG8_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CG8_NUMDOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CG8_FORNEC == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CG8_LOJA == "' + cLoja + '"'

	Case cTabela == "CFF"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cWhere		+= "CFF.CFF_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CFF.CFF_NUMDOC = '" + cDoc + "' AND "
		cWhere		+= "CFF.CFF_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CFF.CFF_LOJA = '" + cLoja  + "' AND "

		If lCmpCFF
			cWhere += "CFF.CFF_TPMOV = '" + cEntSai + "' AND "
			cWhere += "CFF.CFF_TIPO = '" + cTpNF + "' AND "
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cCondicao 	+= 'CFF_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CFF_NUMDOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CFF_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CFF_LOJA == "' + cLoja + '"'

		If lCmpCFF
			cCondicao += "CFF.CFF_TPMOV = '" + cEntSai + "' AND "
			cCondicao += "CFF.CFF_TIPO = '" + cTpNF + "' AND "
		EndIf

	Case cTabela == "CF8"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cWhere		+= "CF8.CF8_SERIE = '" + cSerie + "' AND "
		cWhere		+= "CF8.CF8_DOC = '" + cDoc + "' AND "
		cWhere		+= "CF8.CF8_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "CF8.CF8_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cCondicao 	+= 'CF8_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'CF8_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'CF8_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'CF8_LOJA == "' + cLoja + '"'

	Case cTabela == "F0A"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para TOP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cWhere		+= "F0A.F0A_SERIE = '" + cSerie + "' AND "
		cWhere		+= "F0A.F0A_DOC = '" + cDoc + "' AND "
		cWhere		+= "F0A.F0A_CLIFOR = '" + cClieFor + "' AND "
		cWhere		+= "F0A.F0A_LOJA = '" + cLoja  + "' AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a expressao para codebase³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cCondicao 	+= 'F0A_SERIE == "' + cSerie + '" .AND. '
		cCondicao 	+= 'F0A_DOC == "' + cDoc + '" .AND. '
		cCondicao 	+= 'F0A_CLIFOR == "' + cClieFor + '" .AND. '
		cCondicao 	+= 'F0A_LOJA == "' + cLoja + '"'

EndCase

If !Empty(cWhere) .Or. !Empty(cCondicao)

	#IFDEF TOP
		If TcSrvType()<>"AS/400"

			lQuery 	:= .T.
			cAlias	:= GetNextAlias()

			cWhere	+= cTabela + ".D_E_L_E_T_= ' ' %"

			aCmpSx3 := FWSX3Util():GetAllFields(cTabela, .F.)

			For nY := 1 to Len(aCmpSx3)

				If lPrim
					cSelect += "%"+cTabela+"."+Alltrim(aCmpSx3[nY])+""
					lprim := .F.
				Else
					cSelect += ","+cTabela+"."+Alltrim(aCmpSx3[nY])+""
				Endif

			Next nY

			cSelect += "%"

			BeginSql Alias cAlias

				SELECT %Exp:cSelect%
				FROM %Exp:cFrom%
				WHERE %Exp:cWhere%
				ORDER BY %Exp:cOrder%
			EndSql

			dbSelectArea(cAlias)

		Else
	#ENDIF
			lQuery	:= .F.
			cArqInd	:=	CriaTrab(Nil,.F.)
			IndRegua(cAlias,cArqInd,cChave,,cCondicao,STR0036) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAlias)->(dbGotop())
	#IFDEF TOP
		Endif
	#ENDIF

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se possui o complemento ou será incluido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While !(cAlias)->(Eof())
	lPossui := .T.
	Exit
Enddo

(cAlias)->(dbGotop())

RestArea(aArea)

Return lPossui

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M926Close³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fecha as areas abertas pela funcao de filtro               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome da tabela                                     ³±±
±±³          ³ ExpC2 = Indice criado para codebase                        ³±±
±±³          ³ ExpC3 = Alias criado para top                              ³±±
±±³          ³ ExpL4 = Indicacao de top/codebase                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Close(cTabela,cArqInd,cAlias,lQuery)

If !lQuery
	RetIndex(cTabela)
	dbClearFilter()
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAlias)
	dbCloseArea()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Valid ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida as informacoes apresentadas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC5 = Numero da nota fiscal                              ³±±
±±³          ³ ExpC6 = Serie da nota fiscal                               ³±±
±±³          ³ ExpC7 = Especie da nota fiscal                             ³±±
±±³          ³ ExpC8 = Cliente/fornecedor                                 ³±±
±±³          ³ ExpC9 = Loja do cliente/fornecedor                         ³±±
±±³          ³ ExpCA = Indicacao de entrada/saida                         ³±±
±±³          ³ ExpCB = Indica se a NF e de devol./beneficiamento          ³±±
±±³          ³ ExpAC = Itens do complemento de medicamentos               ³±±
±±³          ³ ExpAD = Itens do complemento de armas de fogo              ³±±
±±³          ³ ExpAE = Itens do complemento de veiculos                   ³±±
±±³          ³ ExpAF = Itens do complemento de combustiveis               ³±±
±±³          ³ ExpAG = Itens do complemento de energia eletrica           ³±±
±±³          ³ ExpAH = Itens do complemento de gas canalizado             ³±±
±±³          ³ ExpAI = Itens do complemento de comunicacao/telecom.       ³±±
±±³          ³ ExpAJ = Complementos sugeridos pelo sistema                ³±±
±±³          ³ Exp1K = Array com as guias de recolhimento referenciadas   ³±±
±±³          ³ Exp1L = Array com os cupons fiscais referenciados          ³±±
±±³          ³ Exp1M = Array com os documentos referenciados              ³±±
±±³          ³ Exp1N = Array com os locais de coleta/entrega              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Valid(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCompl,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aAgua,aComunica,aMantem,aGets,aSugerido,aObrigat,aGNRE,aNfCupom,aDocRef,aLocal,aAnfaveaC,aAnfaveaI,aRessarc,oTree,cItem,aRastr)

Local aCols		:= {}
Local aHeader	:= {}
Local aCabec	:= {"aHAgua","aHArma","aHComb","aHComun","aHEner","aHGas","aHImp","aHMed","aHVeic","aHProc","aHGuia","aHDoc","aHCp","aHLoc","aHInfc","aHExp", "aHAnfC", "aHAnfI", "aHRes", "aHRemas", "aHCrdAcum","aHCCF8","aHRastr"}

Local lGrava	:= .T.
Local lTabCG8	:= GetNewPar("MV_REMASRJ", .F.)

Local cMvEstado	:= GetNewPar("MV_ESTADO", .F.)
Local lTabCFF	:= cMvEstado == "SP"

Local nX 		:= 0
Local nCargo    := Val(SubStr(oTree:GetCargo(),6,5))
Local cTextoNF  := ""
Local lEic      := SuperGetMv("MV_EASY",,"N") == "S"
Local lCompF0A  := AliasInDic("F0A")

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  | Se o cargo for a Guia de Recolhimento e a especie for NFCF     |
  | conforme solicitação nao podemos deixar gerar o complemento.   |
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nCargo == 11 .And. Alltrim(cEspecie) == "NFCF"
	cTextoNF := "Esta espécie de Nota fiscal não pode conter Guia de Recolhimento." + chr(13)+ chr(10)
	cTextoNF += "Para Maiores informações ler Boletim de guia de recolhimento."
	MsgAlert(cTextoNF)
	Return .F.
EndIf


For nX := 1 to Len(aCabec)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o aHeader e o aCols generico para efetuar a gravacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader	:= &(aCabec[nX])

	If ValType(aGets[nX]) == "O"
		aCols 	:= aGets[nX]:aCols
	Else
		aCols	:= {}
	Endif

	If ValType(aGets[nX]) == "O"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua as validacoes de todos os complementos que devem ser      ³
		//³gerados para a nota fiscal. Somente apos a validacao de todos os ³
		//³complementos e que sera efetuada a gravacao.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case nX == 1
				If !M926Ag(aGets[nX],aObrigat)
					lGrava := .F.
				Endif
			Case nX == 2
				If !M926Arma(aGets[nX],cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.T.,aArma)
					lGrava := .F.
				Endif
			Case nX == 3
				If !M926Comb(aGets[nX],cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.T.,aCombust)
					lGrava := .F.
				Endif
			Case nX == 4
				If !M926Tele(aGets[nX],cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.T.)
					lGrava := .F.
				Endif
			Case nX == 5
				If !M926Ener(aGets[nX],cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.T.)
					lGrava := .F.
				Endif
			Case nX == 6
				If !M926Gas(aGets[nX],cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.T.)
					lGrava := .F.
				Endif
			Case nX == 7
				If !lEic
					If !M926Imp(aGets[nX],aObrigat,.T.)
						lGrava := .F.
					Endif
				Endif
			Case nX == 8
				If !M926Med(aGets[nX],cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.T.,aMedica)
					lGrava := .F.
				Endif
			Case nX == 9
				If !M926Veic(aGets[nX],cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.T.,aVeic)
					lGrava := .F.
				Endif
			Case nX == 10
				If M926Exist(aCols) .And. !M926Proc(aGets[nX],aObrigat,.T.)
					lGrava := .F.
				Endif
			Case nX == 11
				If M926Exist(aCols) .And. !M926Guia(aGets[nX],aObrigat,.T.)
					lGrava := .F.
				Endif
			Case nX == 12
				If M926Exist(aCols) .And. !M926Doc(aGets[nX],aObrigat,.T.,aDocRef,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF)
					lGrava := .F.
				Endif
			Case nX == 13
				If M926Exist(aCols) .And. !M926Cup(aGets[nX],aObrigat,.T.,aNfCupom)
					lGrava := .F.
				Endif
			Case nX == 14
				If M926Exist(aCols) .And. !M926Loc(aGets[nX],aObrigat,.T.,aLocal)
					lGrava := .F.
				Endif
			Case nX == 15
				If M926Exist(aCols) .And. !M926Infc(aGets[nX],aObrigat,.T.)
					lGrava := .F.
				Endif
			Case nX == 16 .And. lCompExp
				If !M926Exp(aGets[nX],aObrigat,.T.)
					lGrava := .F.
				Endif
			Case nX == 17 .And. lAnfavea
				If !M926AnfC(aGets[nX],aObrigat,.T.)
					lGrava := .F.
				Endif
			Case nX == 18 .And. lAnfavea
				If !M926AnfI(aGets[nX],aObrigat,.T.)
					lGrava := .F.
				Endif
			/*Case nX == 19 .And. lCompCD0
				If !M926Ag(aGets[nX],aObrigat)
					lGrava := .F.
				Endif
			*/
			Case nX == 20 .And. lTabCG8
				lGrava := .T.
			Case nX == 21 .And. lTabCFF
				If M926Exist(aCols)
					lGrava := .T.
				EndIf
			/*Case nX == 22 .And. lCompCF8
				lGrava := .T.*/
			Case nX == 23 .And. lCompF0A
				If M926Exist(aCols) .And. !M926Rastr(aGets[nX],cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,.T.,aRastr)
					lGrava := .F.
				EndIf
		EndCase
	Endif
Next

Return lGrava

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Fim   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as gravacoes nas tabelas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC5 = Numero da nota fiscal                              ³±±
±±³          ³ ExpC6 = Serie da nota fiscal                               ³±±
±±³          ³ ExpC7 = Especie da nota fiscal                             ³±±
±±³          ³ ExpC8 = Cliente/fornecedor                                 ³±±
±±³          ³ ExpC9 = Loja do cliente/fornecedor                         ³±±
±±³          ³ ExpCA = Indicacao de entrada/saida                         ³±±
±±³          ³ ExpCB = Indica se a NF e de devol./beneficiamento          ³±±
±±³          ³ ExpAC = Itens do complemento de medicamentos               ³±±
±±³          ³ ExpAD = Itens do complemento de armas de fogo              ³±±
±±³          ³ ExpAE = Itens do complemento de veiculos                   ³±±
±±³          ³ ExpAF = Itens do complemento de combustiveis               ³±±
±±³          ³ ExpAG = Itens do complemento de energia eletrica           ³±±
±±³          ³ ExpAH = Itens do complemento de gas canalizado             ³±±
±±³          ³ ExpAI = Itens do complemento de comunicacao/telecom.       ³±±
±±³          ³ ExpAJ = Complementos sugeridos pelo sistema                ³±±
±±³          ³ Exp1K = Array com as guias de recolhimento referenciadas   ³±±
±±³          ³ Exp1L = Array com os cupons fiscais referenciados          ³±±
±±³          ³ Exp1M = Array com os documentos referenciados              ³±±
±±³          ³ Exp1N = Array com os locais de coleta/entrega              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Fim(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aCompl,aMedica,aArma,aVeic,aCombust,aEnergia,aGas,aAgua,aComunica,aMantem,aGets,aSugerido,aObrigat,aGNRE,aNfCupom,aDocRef,aLocal,aAnfaveaC,aAnfaveaI,aRessarc,cItem,oSay)

Local aArea		:= GetArea()
Local aCols		:= {}
Local aHeader	:= {}
Local aCabec	:= {"aHAgua","aHArma","aHComb","aHComun","aHEner","aHGas","aHImp","aHMed","aHVeic","aHProc","aHGuia","aHDoc","aHCp","aHLoc","aHInfc","aHExp", "aHAnfC", "aHAnfI", "aHRes", "aHRemas", "aHCrdAcum","aHCCF8","aHRastr"}
Local aItem		:= {"aCAgua","aCArma","aCComb","aCComun","aCEner","aCGas","aCImp","aCMed","aCVeic","aCProc","aCGuia","aCDoc","aCCp","aCLoc","aCInfc", "aCExp", "aCAnfC", "aCAnfI", "aCRes", "aCRemas", "aCCrdAcum","aCCCF8","aCRastr"}

Local aDeleta	:= {}
Local aDel		:= {}
Local aPos		:= If(lSdoc,{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0})

Local cAlerta	:= ""
Local cGrvFrt   := ""
Local cSitExt	:= ""
Local cItemOld	:= ""
Local cDtEntrada:= ""

// Variaveis para controle da DC0
Local cCodEnt	:= ""
Local cSerEnt	:= ""
Local cEspeci	:= ""
Local cForne	:= ""
Local cLojEnt	:= ""
Local nCvh		:= 0

Local lExiste	:= .F.
Local lExclusao	:= .F.
Local lRet		:= .F.
Local lAtualiza	:= .T.
Local lTabCG8	:= GetNewPar("MV_REMASRJ", .F.)
Local cMvEstado	:= GetNewPar("MV_ESTADO", .F.)
Local lTabCFF	:= cMvEstado == "SP"
Local lCompF0A := AliasInDic("F0A")
Local lCmpCFF  := CFF->(FieldPos('CFF_TIPO')) > 0

Local lCodMun 	:= CDT->(FieldPos('CDT_UFDEST')) > 0 .and. CDT->(FieldPos('CDT_MDEST')) > 0
Local laltMun	:= .F.
Local lCddMeaRf	:= CDD->(FieldPos("CDD_MEANRF")) > 0
Local lCddMdaRf	:= CDD->(FieldPos("CDD_MODREF")) > 0

Local nX 		:= 0
Local nY		:= 0
Local nZ		:= 0
Local nI		:= 0
Local nPos		:= 0
Local nPos2		:= 0
Local nPos3		:= 0
Local nPos4		:= 0
Local nPos5		:= 0
Local nPos6		:= 0
Local nPos7		:= 0
Local nPos8		:= 0
Local nCount	:= 0
Local nPosQt	:= 0
Local nPosVUn	:= 0
Local nPosVBST	:= 0
Local dDtOri	:= CtoD("  /  /    ")
Local cEspOri	:= ""
Local cSerOri	:= ""
Local dDtExp	:= CtoD("  /  /    ")
Local cEspExp 	:= ""
Local cSerExp 	:= ""
Local dDtEmb	:= CtoD("  /  /    ")
Local cEspEmb	:= ""
Local cSerEmb	:= ""
Local cCompLin	:= ""
Local nTamDoc   := TamSX3("CD7_DOC")[1]
Local lObjSay   := Type("oSay") != "U"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Setando o indice das tabelas que serao atualizadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CD3->(dbSetOrder(1))
CD4->(dbSetOrder(1))
CD5->(dbSetOrder(4))
CD6->(dbSetOrder(1))
CD7->(dbSetOrder(1))
CD8->(dbSetOrder(1))
CD9->(dbSetOrder(1))
CDC->(dbSetOrder(1))
CDD->(dbSetOrder(1))
CDE->(dbSetOrder(1))
CDF->(dbSetOrder(1))
CDG->(dbSetOrder(1))
CDT->(dbSetOrder(1))
SFU->(dbSetOrder(1))
SFX->(dbSetOrder(1))
If lCompExp
	CDL->(dbSetOrder(1))
EndIf
If lAnfavea
	CDR->(dbSetOrder(1))
	CDS->(dbSetOrder(1))
EndIf

dbSelectArea("CD0")
CD0->(dbSetOrder(1))

If lTabCG8
	dbSelectArea("CG8")
	CG8->(dbSetOrder(1))
EndIf

If lTabCFF
	dbSelectArea("CFF")
	If lCmpCFF
		CFF->(dbSetOrder(4))
	Else
		CFF->(dbSetOrder(1))
	EndIf
EndIf

If lCompCF8
	dbSelectArea("CF8")
	CF8->(dbSetOrder(3))
EndIf

If cEntSai == 'E'
	dbSelectArea("CF8")
	CF8->(dbSetOrder(3))
EndIf

If lCompF0A
	dbSelectArea("F0A")
	F0A->(DbSetOrder(1))
EndIf

DbSelectArea("SF3")
SF3->(DbSetOrder(4))

Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os itens sugeridos para que fossem gerados os complementos³
	//³no arquivo de log - apenas para os complementos com itens       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M926Log(aSugerido)

	For nX := 1 to Len(aCabec)

		If lObjSay
			oSay:cCaption := (aCompl[nX][1])
		EndIf
		ProcessMessages()

		aDeleta := {}
		aDel	:= {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o aHeader e o aCols generico para efetuar a gravacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeader	:= &(aCabec[nX])

		If !Empty(aGets) .And. ValType(aGets[nX]) == "O"
			aCols := aGets[nX]:aCols
		Else
			aCols	:= &(aItem[nX])
		Endif

		If !Empty(aCols)

			lRet := .T.

			Do Case

				Case nX == 1

					For nY := 1 to Len(aCols)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se o item existe para altera-lo ou gravar um novo.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lExiste	:= CD4->(dbSeek(xFilial("CD4")+cEntSai+cSerie+cDoc+cClieFor+cLoja))

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se o item nao esta excluido no aCols³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !aCols[nY][Len(aHeader)+1]

							If !lExiste
								RecLock("CD4",.T.)
								CD4->CD4_FILIAL	:= xFilial("CD4")
								CD4->CD4_TPMOV	:= cEntSai
								CD4->CD4_DOC	:= cDoc
								SerieNfId("CD4",1,"CD4_SERIE",,,,cSerie)
								CD4->CD4_ESPEC	:= cEspecie
								CD4->CD4_CLIFOR	:= cClieFor
								CD4->CD4_LOJA	:= cLoja
							Else
								RecLock("CD4",.F.)
							Endif

							For nZ := 1 To Len(aHeader)
								CD4->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
							Next nY

							MsUnLock()

							If SF3->(DbSeek(xFilial("SF3")+cClieFor+cLoja+cDoc+cSerie))
								RecLock("SF3",.F.)
								SF3->F3_CLASCO	:=	CD4->CD4_CLASCO
								MsUnlock()
							Endif

							FkCommit()
						Else
							If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se confirma a exclusao dos itens³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
								If nCount <= 0
									lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
									nCount ++
								Endif
								If lExclusao
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Deleta o item posicionado pelo aCols³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									RecLock("CD4",.F.)
									CD4->(dbDelete())
									MsUnLock()
									FkCommit()
								Endif
							Endif
						Endif
					Next

				Case nX == 2

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD8_ITEM"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD8_COD"})

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
					//³item exista em um registro do aCols nao marcado para delecao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nPos > 0 .AND. nPos2 > 0
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste	:= CD8->(dbSeek(xFilial("CD8")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If !lExiste
									RecLock("CD8",.T.)
									CD8->CD8_FILIAL	:= xFilial("CD8")
									CD8->CD8_TPMOV	:= cEntSai
									CD8->CD8_DOC	:= cDoc
									SerieNfId("CD8",1,"CD8_SERIE",,,,cSerie)
									CD8->CD8_CLIFOR	:= cClieFor
									CD8->CD8_LOJA	:= cLoja
								Else
									RecLock("CD8",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									CD8->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY

								MsUnLock()
								FkCommit()
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CD8",.F.)
										CD8->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf
				Case nX == 3

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD6_ITEM"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD6_COD"})
					nPos3	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD6_PLACA"})
					nPos4	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD6_TANQUE"})

					If nPos > 0 .AND. nPos2 > 0 .AND. nPos3 > 0 .AND. nPos4 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste	:= CD6->(dbSeek(xFilial("CD6")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]+aCols[nY][nPos3]+aCols[nY][nPos4]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If !lExiste
									RecLock("CD6",.T.)
									CD6->CD6_FILIAL	:= xFilial("CD6")
									CD6->CD6_TPMOV	:= cEntSai
									CD6->CD6_DOC	:= cDoc
									SerieNfId("CD6",1,"CD6_SERIE",,,,cSerie)
									CD6->CD6_CLIFOR	:= cClieFor
									CD6->CD6_LOJA	:= cLoja
								Else
									RecLock("CD6",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									CD6->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY

								MsUnLock()
								FkCommit()
							Else
								If lExiste// .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CD6",.F.)
										CD6->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf
				Case nX == 4

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="FX_ITEM"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="FX_COD"})

					If nPos > 0 .AND. nPos2 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste	:= SFX->(dbSeek(xFilial("SFX")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If !lExiste
									RecLock("SFX",.T.)
									SFX->FX_FILIAL	:= xFilial("SFX")
									SFX->FX_TIPOMOV	:= cEntSai
									SFX->FX_DOC		:= cDoc
									SerieNfId("SFX",1,"FX_SERIE",,,,cSerie)
									SFX->FX_CLIFOR	:= cClieFor
									SFX->FX_LOJA	:= cLoja
								Else
									RecLock("SFX",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									SFX->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY

								MsUnLock()
								FkCommit()
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("SFX",.F.)
										SFX->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf
				Case nX == 5

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="FU_ITEM"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="FU_COD"})

					If nPos > 0 .AND. nPos2 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste	:= SFU->(dbSeek(xFilial("SFU")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If !lExiste
									RecLock("SFU",.T.)
									SFU->FU_FILIAL	:= xFilial("SFU")
									SFU->FU_TIPOMOV	:= cEntSai
									SFU->FU_DOC		:= cDoc
									SerieNfId("SFU",1,"FU_SERIE",,,,cSerie)
									SFU->FU_CLIFOR	:= cClieFor
									SFU->FU_LOJA	:= cLoja
								Else
									RecLock("SFU",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									SFU->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY

								MsUnLock()
								FkCommit()
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("SFU",.F.)
										SFU->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf
				Case nX == 6

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD3_ITEM"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD3_COD"})

					If nPos > 0 .AND. nPos2 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste	:= CD3->(dbSeek(xFilial("CD3")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If !lExiste
									RecLock("CD3",.T.)
									CD3->CD3_FILIAL	:= xFilial("CD3")
									CD3->CD3_TPMOV	:= cEntSai
									CD3->CD3_DOC	:= cDoc
									SerieNfId("CD3",1,"CD3_SERIE",,,,cSerie)
									CD3->CD3_CLIFOR	:= cClieFor
									CD3->CD3_LOJA	:= cLoja
								Else
									RecLock("CD3",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									CD3->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY

								MsUnLock()
								FkCommit()
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CD3",.F.)
										CD3->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf
				Case nX == 7

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD5_DOCIMP"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD5_ALPIS"})
					nPos3	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD5_ALCOF"})
					nPos6	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD5_NADIC"})
					nPos7	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD5_SQADIC"})
					nPos8	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD5_ITEM"})

					If nPos > 0 .AND. nPos2 > 0 .AND. nPos3 > 0 .AND. nPos6 > 0 .AND. nPos7 > 0 .AND. nPos8 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existem campos deletados e nao deletados de mesma chave³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI := 1 to Len(aCols)
							//Grava CD5 somente se os campos estiverem preenchidos 
							If Empty(aCols[nI,nPos]) .And. Empty(aCols[nI,nPos8]) .And. Empty(aCols[nI,nPos7])
								aCols[nI][Len(aHeader)+1] := .T.
							EndIf
							If aCols[nI][Len(aHeader)+1]
								aAdd(aDel,{aCols[nI][nPos],Str(aCols[nI][nPos2],5,2),Str(aCols[nI][nPos3],5,2),aCols[nI][nPos6]})
							Endif
						Next

						For nI := 1 to Len(aCols)
							If !aCols[nI][Len(aHeader)+1]
								If aScan(aDel,{|x| x[1] == aCols[nI][nPos] .And. x[2] == Str(aCols[nI][nPos2],5,2) .And. x[2] == Str(aCols[nI][nPos3],5,2) .And. x[2] == aCols[nI][nPos6] }) > 0
									aAdd(aDeleta,{aCols[nI][nPos],Str(aCols[nI][nPos2],5,2),Str(aCols[nI][nPos3],5,2),aCols[nI][nPos6]})
								Endif
							Endif
						Next

						For nY := 1 to Len(aCols)
							lExiste 	:= CD5->(dbSeek(xFilial("CD5")+cDoc+cSerie+cClieFor+cLoja+aCols[nY][nPos8]))
							lAtualiza 	:= .T.
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]
								If lExiste
									RecLock("CD5",.F.)
								Else
									RecLock("CD5",.T.)
									CD5->CD5_FILIAL	:= xFilial("CD5")
									CD5->CD5_DOC	:= cDoc
									SerieNfId("CD5",1,"CD5_SERIE",,,,cSerie)
									CD5->CD5_ESPEC	:= cEspecie
									CD5->CD5_FORNEC	:= cClieFor
									CD5->CD5_LOJA	:= cLoja
									CD5->CD5_ALPIS	:= aCols[nY][nPos2]
									CD5->CD5_ALCOF	:= aCols[nY][nPos3]
									CD5->CD5_NADIC	:= aCols[nY][nPos6]
									CD5->CD5_ITEM	:= aCols[nY][1]
								Endif
								For nZ := 1 To Len(aHeader)
									CD5->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY
								MsUnLock()
								FkCommit()
							Else
								// Exclusao
								If lExiste
									If nCount <= 0
										cAlerta 	+= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
										lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										lAtualiza := .F.
									Endif
								Endif
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Atualiza o array com os documentos que permanecerao na tabela³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lAtualiza
								nPosx := aScan(aMantem[1],{|x| x[1]+x[2]+x[3]+x[4]+x[9]==cDoc+cSerie+cClieFor+cLoja+aCols[nY][nPos8]})
								If nPosx > 0
									aMantem[1][nPosx][10] := .T.
								EndIf
							Endif
						Next
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Como no complemento de importacao o numero do documento de importacao                          ³
						//³faz parte da chave e e possivel altera-lo, apos a atualizacao dos complementos,                ³
						//³exclui-se as referencias que existiam na base mas nao existem mais devido a alteracao no acols.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI := 1 to Len(aMantem[1])
							If !aMantem[1][nI][10]
								If CD5->(dbSeek(xFilial("CD5")+aMantem[1][nI][1]+aMantem[1][nI][2]+aMantem[1][nI][3]+aMantem[1][nI][4]+aMantem[1][nI][9]))
									RecLock("CD5",.F.)
									CD5->(dbDelete())
									MsUnLock()
									FkCommit()
								Endif
							Endif
						Next
					EndIf
				Case nX == 8

					nPos		:= aScan(aHeader,{|x| Alltrim(x[2])=="CD7_ITEM"})
					nPos2		:= aScan(aHeader,{|x| Alltrim(x[2])=="CD7_COD"})

					If nPos > 0 .AND. nPos2 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste	:= CD7->(dbSeek(xFilial("CD7")+cEntSai+cSerie+PADR(cDoc,nTamDoc)+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If !lExiste
									RecLock("CD7",.T.)
									CD7->CD7_FILIAL	:= xFilial("CD7")
									CD7->CD7_TPMOV	:= cEntSai
									CD7->CD7_DOC	:= cDoc
									SerieNfId("CD7",1,"CD7_SERIE",,,,cSerie)
									CD7->CD7_CLIFOR	:= cClieFor
									CD7->CD7_LOJA	:= cLoja
								Else
									RecLock("CD7",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									CD7->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY

								MsUnLock()
								FkCommit()
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CD7",.F.)
										CD7->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf
				Case nX == 9

					nPos		:= aScan(aHeader,{|x| Alltrim(x[2])=="CD9_ITEM"})
					nPos2		:= aScan(aHeader,{|x| Alltrim(x[2])=="CD9_COD"})

					If nPos > 0 .AND. nPos2 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste	:= CD9->(dbSeek(xFilial("CD9")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If !lExiste
									RecLock("CD9",.T.)
									CD9->CD9_FILIAL	:= xFilial("CD9")
									CD9->CD9_TPMOV	:= cEntSai
									CD9->CD9_DOC	:= cDoc
									SerieNfId("CD9",1,"CD9_SERIE",,,,cSerie)
									CD9->CD9_CLIFOR	:= cClieFor
									CD9->CD9_LOJA	:= cLoja
								Else
									RecLock("CD9",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									CD9->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY

								MsUnLock()
								FkCommit()
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CD9",.F.)
										CD9->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf
				Case nX  == 10

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente efetua o processo de gravacao se existir informacoes no aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If M926Exist(aCols)

						nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDG_PROCES"})
						nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDG_TPPROC"})
						nPos3	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDG_ITEM"})
						nPos4	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDG_ITPROC"})

						If nPos > 0 .AND. nPos2 > 0 .AND. nPos3 > 0 .AND. nPos4 > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se existem campos deletados e nao deletados de mesma chave³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nI := 1 to Len(aCols)
								If aCols[nI][Len(aHeader)+1]
										aAdd(aDel,{	aCols[nI][nPos]	,	;
													aCols[nI][nPos2],	;
													aCols[nI][nPos3],	;
													aCols[nI][nPos4],	;
													aCols[nI][nPos] + aCols[nI][nPos2] + aCols[nI][nPos3] + aCols[nI][nPos4]})
								EndIf
							Next

							For nI := 1 to Len(aCols)
								If !aCols[nI][Len(aHeader)+1]
									cCompLin := aCols[nI][nPos] + aCols[nI][nPos2] + aCols[nI][nPos3] + aCols[nI][nPos4]
									If aScan(aDel,{|aVal| aVal[05] == cCompLin}) > 0
										aAdd(aDeleta,{aCols[nI][nPos],aCols[nI][nPos2],aCols[nI][nPos3],aCols[nI][nPos4]})
									Endif
								Endif
							Next

							For nY := 1 to Len(aCols)

								CDG->(DbSetOrder(01)) //CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA+CDG_PROCES+CDG_TPPROC+CDG_ITEM+CDG_ITPROC
								
								lExiste := CDG->(dbSeek(xFilial('CDG') + cEntSai + cDoc + cSerie + cClieFor + cLoja + aCols[nY][nPos] + aCols[nY][nPos2] + aCols[nY][nPos3] + aCols[nY][nPos4]))

								lAtualiza 	:= .T.

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se o item nao esta excluido no aCols³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !aCols[nY][Len(aHeader)+1]
									If lExiste
										RecLock("CDG",.F.)
									Else
										RecLock("CDG",.T.)
										CDG->CDG_FILIAL	:= xFilial("CDG")
										CDG->CDG_TPMOV	:= cEntSai
										CDG->CDG_DOC	:= cDoc
										SerieNfId("CDG",1,"CDG_SERIE",,,,cSerie)
										CDG->CDG_CLIFOR	:= cClieFor
										CDG->CDG_LOJA	:= cLoja
									Endif
									For nZ := 1 To Len(aHeader)
										CDG->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
									Next nY

									MsUnLock()
									FkCommit()
								Else
									// Exclusao
									If lExiste .And. aScan(aDeleta,{|x| x[1] == aCols[nY][nPos] .And. x[2] == aCols[nY][nPos2] .And. x[3] == aCols[nY][nPos3] .And. x[4] == aCols[nY][nPos4]}) == 0
										If nCount <= 0
											cAlerta 	:= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
											lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037))
											nCount ++
										Endif
										If lExclusao
											lAtualiza := .F.
											RecLock("CDG",.F.)
											CDG->(dbDelete())
											MsUnLock()
											FkCommit()
										Endif
									Endif
								Endif

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Atualiza o array com os documentos que permanecerao na tabela³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lAtualiza
									nPos5 := aScan(aMantem[2],{|x| x[1]+x[2]+x[3]+x[4] == aCols[nY][nPos] + aCols[nY][nPos2] + aCols[nY][nPos3] + aCols[nY][nPos4]})
									If nPos5 > 0
										aMantem[2][nPos5][5] := .T.
									Endif
								Endif
							Next
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Como no processo referenciado o numero e tipo de processo e a informacao complementar          ³
							//³fazem parte da chave e e possivel altera-los, apos a atualizacao das informacoes complementares³
							//³exclui-se as referencias que existiam na base mas nao existem mais devido a alteracao no acols.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nI := 1 to Len(aMantem[2])
								If !aMantem[2][nI][5]
									CDG->(DbSetOrder(01))
									If CDG->(dbSeek(xFilial("CDG") + cEntSai  + cDoc   + cSerie   + cClieFor  + cLoja   + aMantem[2][nI][1] + aMantem[2][nI][2] + AllTrim(aMantem[2][nI][3]) + aMantem[2][nI][4] ))
										RecLock("CDG",.F.)
										CDG->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Next
						EndIf
					Endif

				Case nX  == 11

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente efetua o processo de gravacao se existir informacoes no aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If M926Exist(aCols)
						nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDC_GUIA"})
						nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDC_UF"})
						nPos3	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDC_DCCOMP"})

						If nPos > 0 .AND. nPos2 > 0 .AND. nPos3 > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se existem campos deletados e nao deletados de mesma chave³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nI := 1 to Len(aCols)
								If aCols[nI][Len(aHeader)+1]
									aAdd(aDel,{aCols[nI][nPos],aCols[nI][nPos2]})
								Endif
							Next

							For nI := 1 to Len(aCols)
								If !aCols[nI][Len(aHeader)+1]
									If aScan(aDel,{|x| x[1] == aCols[nI][nPos] .And. x[2] == aCols[nI][nPos2]}) > 0
										aAdd(aDeleta,{aCols[nI][nPos],aCols[nI][nPos2]})
									Endif
								Endif
							Next

							For nY := 1 to Len(aCols)

								lExiste 	:= CDC->(dbSeek(xFilial("CDC")+cEntSai+cDoc+cSerie+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))
								lAtualiza 	:= .T.

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se o item nao esta excluido no aCols³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !aCols[nY][Len(aHeader)+1]
									If lExiste
										RecLock("CDC",.F.)
									Else
										RecLock("CDC",.T.)
										CDC->CDC_FILIAL	:= xFilial("CDC")
										CDC->CDC_TPMOV	:= cEntSai
										CDC->CDC_DOC	:= cDoc
										SerieNfId("CDC",1,"CDC_SERIE",,,,cSerie)
										CDC->CDC_CLIFOR	:= cClieFor
										CDC->CDC_LOJA	:= cLoja
									Endif
									For nZ := 1 To Len(aHeader)
										CDC->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
									Next nY

									MsUnLock()
									FkCommit()
								Else
									// Exclusao
									If lExiste .And. aScan(aDeleta,{|x| x[1] == aCols[nY][nPos] .And. x[2] == aCols[nY][nPos2] }) == 0
										If nCount <= 0
											cAlerta 	:= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
											lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037))
											nCount ++
										Endif
										If lExclusao
											lAtualiza := .F.
											RecLock("CDC",.F.)
											CDC->(dbDelete())
											MsUnLock()
											FkCommit()
										Endif
									Endif
								Endif

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Atualiza o array com os documentos que permanecerao na tabela³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lAtualiza
									nPos4 := aScan(aMantem[3],{|x| x[1]+x[2]+x[3] ==;
											aCols[nY][nPos]+aCols[nY][nPos2]+aCols[nY][nPos3]})
									If nPos4 > 0
										aMantem[3][nPos4][4] := .T.
									Endif
								Endif
							Next
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Como nas guias referenciadas  o numero e tipo de processo e a informacao complementar          ³
							//³fazem parte da chave e e possivel altera-los, apos a atualizacao das informacoes complementares³
							//³exclui-se as referencias que existiam na base mas nao existem mais devido a alteracao no acols.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nI := 1 to Len(aMantem[3])
								If !aMantem[3][nI][4]
									If CDC->(dbSeek(xFilial("CDC")+cEntSai+cDoc+cSerie+cClieFor+cLoja+aMantem[3][nI][1]+aMantem[3][nI][2]))
										RecLock("CDC",.F.)
										CDC->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Next
						EndIf
					Endif

				Case nX  == 12

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente efetua o processo de gravacao se existir informacoes no aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If M926Exist(aCols)

						nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDD_DOCREF"})
						nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDD_SERREF"})
						nPos3	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDD_PARREF"})
						nPos4	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDD_LOJREF"})
						IF CDD->(ColumnPos("CDD_CHVNFE"))>0
							nPos5	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDD_CHVNFE"})
						Endif
						IF lCompDoc
							nPos6	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDD_ENTSAI"})
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existem campos deletados e nao deletados de mesma chave³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nPos > 0 .AND. nPos2 > 0 .AND. nPos3 > 0 .AND. nPos4 > 0
							For nI := 1 to Len(aCols)
								If aCols[nI][Len(aHeader)+1]
									aAdd(aDel,{aCols[nI][nPos],aCols[nI][nPos2],aCols[nI][nPos3],aCols[nI][nPos4]})
								Endif
							Next

							For nI := 1 to Len(aCols)
								If !aCols[nI][Len(aHeader)+1]
									If aScan(aDel,{|x| x[1] == aCols[nI][nPos] .And. x[2] == aCols[nI][nPos2] .And. x[3] == aCols[nI][nPos3] .And. x[4] == aCols[nI][nPos4]}) > 0
										aAdd(aDeleta,{aCols[nI][nPos],aCols[nI][nPos2],aCols[nI][nPos3],aCols[nI][nPos4]})
									Endif
								Endif
							Next

							For nY := 1 to Len(aCols)

								lExiste 	:= CDD->(dbSeek(xFilial("CDD")+cEntSai+cDoc+cSerie+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]+aCols[nY][nPos3]+aCols[nY][nPos4]))

								lAtualiza 	:= .T.

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se o item nao esta excluido no aCols³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !aCols[nY][Len(aHeader)+1]
									If lExiste
										RecLock("CDD",.F.)
									Else
										RecLock("CDD",.T.)
										CDD->CDD_FILIAL	:= xFilial("CDD")
										CDD->CDD_TPMOV	:= cEntSai
										CDD->CDD_DOC	:= cDoc
										SerieNfId("CDD",1,"CDD_SERIE",,,,cSerie)
										CDD->CDD_CLIFOR	:= cClieFor
										CDD->CDD_LOJA	:= cLoja
									Endif
									For nZ := 1 To Len(aHeader)
										CDD->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))

										If aHeader[nZ][2] == "CDD_SERREF"
											SerieNfId("CDD",1,"CDD_SERREF",,,,aCols[nY][nZ])
										EndIf

									Next nY

									MsUnLock()
									FkCommit()
								Else
									// Exclusao
									If lExiste .And. aScan(aDeleta,{|x| x[1] == aCols[nY][nPos] .And. x[2] == aCols[nY][nPos2] .And. x[3] == aCols[nY][nPos3] .And. x[4] == aCols[nY][nPos4]}) == 0
										If nCount <= 0
											cAlerta 	:= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
											lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037))
											nCount ++
										Endif
										If lExclusao
											lAtualiza := .F.
											RecLock("CDD",.F.)
											CDD->(dbDelete())
											MsUnLock()
											FkCommit()
										Endif
									Endif
								Endif
								If lCompDoc
									nPos7 := 7
								Elseif CDD->(ColumnPos("CDD_CHVNFE"))>0
									nPos7 := 6
								Else
									nPos7 := 5
								Endif

								If lCddMeaRf
									nPos7++
								endif
								if lCddMdaRf
									nPos7++
								endif
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Atualiza o array com os documentos que permanecerao na tabela³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lAtualiza
									nPos6 := aScan(aMantem[4],{|x| x[1]+x[2]+x[3]+x[4] ==;
											aCols[nY][nPos]+aCols[nY][nPos2]+aCols[nY][nPos3]+aCols[nY][nPos4]})
									If nPos6 > 0
										aMantem[4][nPos6][nPos7] := .T.
									Endif
								Endif
							Next
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Como nos documentos referenciados o documento, cliente e loja fazem parte      ³
							//³da chave e e possivel altera-los, sempre se exluem as referencias que nao farao³
							//³mais parte da base.                                                            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nI := 1 to Len(aMantem[4])
								If !aMantem[4][nI][nPos7]
									If CDD->(dbSeek(xFilial("CDD")+cEntSai+cDoc+cSerie+cClieFor+cLoja+aMantem[4][nI][1]+aMantem[4][nI][2]+aMantem[4][nI][3]+aMantem[4][nI][4]))
										RecLock("CDD",.F.)
										CDD->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Next
						EndIf
					Endif

				Case nX  == 13

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente efetua o processo de gravacao se existir informacoes no aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If M926Exist(aCols)

						nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDE_CPREF"})
						nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDE_SERREF"})
						nPos3	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDE_PARREF"})
						nPos4	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDE_LOJREF"})

						If nPos > 0 .AND. nPos2 > 0 .AND. nPos3 > 0 .AND. nPos4 > 0
							For nY := 1 to Len(aCols)

								lExiste 	:= CDE->(dbSeek(xFilial("CDE")+cEntSai+cDoc+cSerie+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]+aCols[nY][nPos3]+aCols[nY][nPos4]))
								lAtualiza 	:= .T.

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se o item nao esta excluido no aCols³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !aCols[nY][Len(aHeader)+1]
									If lExiste
										RecLock("CDE",.F.)
									Else
										RecLock("CDE",.T.)
										CDE->CDE_FILIAL	:= xFilial("CDE")
										CDE->CDE_TPMOV	:= cEntSai
										CDE->CDE_DOC	:= cDoc
										SerieNfId("CDE",1,"CDE_SERIE",,,,cSerie)
										CDE->CDE_CLIFOR	:= cClieFor
										CDE->CDE_LOJA	:= cLoja
									Endif
									For nZ := 1 To Len(aHeader)
										CDE->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))

										If aHeader[nZ][2] == "CDE_SERREF"
											SerieNfId("CDE",1,"CDE_SERREF",,,,aCols[nY][nZ])
										EndIf

									Next nY

									MsUnLock()
									FkCommit()
								Else
									// Exclusao
									If lExiste
										If nCount <= 0
											cAlerta 	:= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
											lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037))
											nCount ++
										Endif
										If lExclusao
											lAtualiza := .F.
											RecLock("CDE",.F.)
											CDE->(dbDelete())
											MsUnLock()
											FkCommit()
										Endif
									Endif
								Endif

							Next
						EndIf
					Endif

				Case nX  == 14

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente efetua o processo de gravacao se existir informacoes no aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If M926Exist(aCols)

						nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDF_ENTREG"})
						nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDF_LOJENT"})

						If nPos > 0 .AND. nPos2 > 0
							For nY := 1 to Len(aCols)
								lExiste 	:= CDF->(dbSeek(xFilial("CDF")+cEntSai+cDoc+cSerie+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

								lAtualiza 	:= .T.

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se o item nao esta excluido no aCols³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !aCols[nY][Len(aHeader)+1]
									If lExiste
										RecLock("CDF",.F.)
									Else
										RecLock("CDF",.T.)
										CDF->CDF_FILIAL	:= xFilial("CDF")
										CDF->CDF_TPMOV	:= cEntSai
										CDF->CDF_DOC	:= cDoc
										SerieNfId("CDF",1,"CDF_SERIE",,,,cSerie)
										CDF->CDF_CLIFOR	:= cClieFor
										CDF->CDF_LOJA	:= cLoja
									Endif
									For nZ := 1 To Len(aHeader)
										CDF->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
									Next nY

									MsUnLock()
									FkCommit()
								Else
									// Exclusao
									If lExiste
										If nCount <= 0
											cAlerta 	:= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
											lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037))
											nCount ++
										Endif
										If lExclusao
											lAtualiza := .F.
											RecLock("CDF",.F.)
											CDF->(dbDelete())
											MsUnLock()
											FkCommit()
										Endif
									Endif
								Endif

							Next
						EndIf
					Endif

				Case nX  == 15

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente efetua o processo de gravacao se existir informacoes no aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If M926Exist(aCols)

						nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDT_IFCOMP"})

						If nPos > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se existem campos deletados e nao deletados de mesma chave³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nI := 1 to Len(aCols)
								If aCols[nI][Len(aHeader)+1]
									aAdd(aDel,{aCols[nI][nPos]})
								Endif
							Next

							For nI := 1 to Len(aCols)
								If !aCols[nI][Len(aHeader)+1]
									If aScan(aDel,{|x| x[1] == aCols[nI][nPos]}) > 0
										aAdd(aDeleta,{aCols[nI][nPos]})
									Endif
								Endif
							Next

							For nY := 1 to Len(aCols)

								lExiste 	:= CDT->(dbSeek(xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja+aCols[nY][nPos]))
								lAtualiza 	:= .T.

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se o item nao esta excluido no aCols³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !aCols[nY][Len(aHeader)+1]
									If lExiste
										RecLock("CDT",.F.)
									Else
										RecLock("CDT",.T.)
										CDT->CDT_FILIAL	:= xFilial("CDT")
										CDT->CDT_TPMOV	:= cEntSai
										CDT->CDT_DOC	:= cDoc
										SerieNfId("CDT",1,"CDT_SERIE",,,,cSerie)
										CDT->CDT_CLIFOR	:= cClieFor
										CDT->CDT_LOJA	:= cLoja
									Endif
									For nZ := 1 To Len(aHeader)
										CDT->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
									Next nY
									MsUnLock()
									FkCommit()
								Else
									// Exclusao
									If lExiste .And. aScan(aDeleta,{|x| x[1] == aCols[nY][nPos]}) == 0
										If nCount <= 0
											cAlerta 	:= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
											lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037))
											nCount ++
										Endif
										If lExclusao
											lAtualiza := .F.
											RecLock("CDT",.F.)
											CDT->(dbDelete())
											MsUnLock()
											FkCommit()
										Endif
									Endif
								Endif

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Atualiza o array com os documentos que permanecerao na tabela³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lAtualiza
									nPos4 := aScan(aMantem[6],{|x| x[1] ==;
											aCols[nY][nPos]})
									If nPos4 > 0
										aMantem[6][nPos4][Len(aMantem[6][nPos4])] := .T.
									Endif
								Endif
							Next
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Como no processo referenciado o numero e tipo de processo e a informacao complementar          ³
							//³fazem parte da chave e e possivel altera-los, apos a atualizacao das informacoes complementares³
							//³exclui-se as referencias que existiam na base mas nao existem mais devido a alteracao no acols.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nI := 1 to Len(aMantem[6])
								If !aMantem[6][nI][Len(aMantem[6][nI])]
									If CDT->(dbSeek(xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja+aMantem[6][nI][1]))
										RecLock("CDT",.F.)
										CDT->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Next
						EndIf
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica gravacao do Indicador de Frete|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Do Case
						Case Alltrim(cOpcaoFrt) == "Terceiros"
							cGrvFrt := "0"
						Case Alltrim(cOpcaoFrt) == "Emitente"
							cGrvFrt := "1"
						Case Alltrim(cOpcaoFrt) == "Destinatário"
							cGrvFrt := "2"
						Case Alltrim(cOpcaoFrt) == "Transp. Próp. por conta Remetente"
							cGrvFrt := "3"
						Case Alltrim(cOpcaoFrt) == "Transp. Próp. por conta Destinatário"
							cGrvFrt := "4"
						Case Alltrim(cOpcaoFrt) == "Sem frete"
							cGrvFrt := "9"
						Case Alltrim(cOpcaoFrt) == ""
							cGrvFrt := " "
					EndCase

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Indicacao da Escrituração extemporânea   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Do Case
						Case Alltrim(cOpcaoExt) == "Ext regular"
							cSitExt := "R"
						Case Alltrim(cOpcaoExt) == "Ext complementar"
							cSitExt := "P"
						Case Alltrim(cOpcaoExt) == ""
							cSitExt := " "
					EndCase

					//Alteração Código de Municipio
					If lCodMun .and. cMdest	<>  CDT->CDT_MDEST
						laltMun := .T. 
					Endif

					If cGrvFrt <> CDT->CDT_INDFRT .OR. cSitExt <> CDT->CDT_SITEXT .OR.;
						dDatReceb <> CDT->CDT_DTAREC .OR. laltMun

						If CDT->(dbSeek(xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja))
							cChave := xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja
							Do While !CDT->(Eof()) .And. xFilial("CDT")+CDT->CDT_TPMOV+CDT->CDT_DOC+CDT->CDT_SERIE+CDT->CDT_CLIFOR+CDT->CDT_LOJA == cChave
								RecLock("CDT",.F.)
								CDT->CDT_INDFRT	:= cGrvFrt
								CDT->CDT_SITEXT	:= cSitExt
								CDT->CDT_DTAREC	:= dDatReceb
								IF lCodMun
									CDT->CDT_UFDEST := cUFDest
									CDT->CDT_MDEST  := cMdest
								Endif
								MsUnLock()
								FkCommit()
								CDT->(dbSkip())
							Enddo
						Else
							RecLock("CDT",.T.)
							CDT->CDT_FILIAL	:= xFilial("CDT")
							CDT->CDT_TPMOV	:= cEntSai
							CDT->CDT_DOC	:= cDoc
							SerieNfId("CDT",1,"CDT_SERIE",,,,cSerie)
							CDT->CDT_CLIFOR	:= cClieFor
							CDT->CDT_LOJA	:= cLoja
							CDT->CDT_INDFRT	:= cGrvFrt 
							CDT->CDT_SITEXT	:= cSitExt
							CDT->CDT_DTAREC := dDatReceb
							IF lCodMun
								CDT->CDT_UFDEST := cUFDest
								CDT->CDT_MDEST  := cMdest
							Endif
							MsUnLock()
							FkCommit()
						EndIf
					EndIf

				Case nX == 16 .And. lCompExp

					aPos[01] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_NUMDE"})
					aPos[06] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_NRREG"})
					aPos[02] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_DOCORI"})
					aPos[03] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_SERORI"})
					aPos[04] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_FORNEC"})
					aPos[05] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_LOJFOR"})
					aPos[07] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_ITEMNF"})
					aPos[08] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_NRMEMO"})
					If lSdoc
						aPos[09] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_DTORI"})
						aPos[10] := aScan(aHeader,{|x| Alltrim(x[2])=="CDL_ESPORI"})
					EndIf

					If aPos[01] > 0 .AND. aPos[02] > 0 .AND. aPos[03] > 0 .AND. aPos[04] > 0 .AND. aPos[05] > 0 .AND. aPos[06] > 0 .AND. aPos[07] > 0 .AND. aPos[08] > 0
						For nY := 1 to Len(aCols)

							If SerieNfId("CDL",3,"CDL_SERORI") == "CDL_SDOCOR" .AND. aPos[03] > 0 .AND. aPos[09] > 0 .AND. aPos[10] > 0
								cSerId := Substr(aCols[nY][aPos[03]],1,3) + StrZero(Month(aCols[nY][aPos[09]]),2) + Str(Year(aCols[nY][aPos[09]]),4) + PADR(AllTrim(aCols[nY][aPos[10]]),TamSX3("CDL_ESPORI")[1])
							ElseIf aPos[03] > 0
								cSerId := Substr(aCols[nY][aPos[03]],1,3)
							Else
								cSerId := ""
							EndIf

							If aPos[01] <= 0 .OR. aPos[02] <= 0 .OR. aPos[04] <= 0 .OR. aPos[05] <= 0 .OR. aPos[06] <= 0 .OR. aPos[07] <= 0 .OR. aPos[08] <= 0
								lExiste := .F.
							Else
								lExiste 	:= CDL->(dbSeek(xFilial("CDL")+cDoc+cSerie+cClieFor+cLoja+aCols[nY][aPos[01]]+aCols[nY][aPos[02]]+cSerId+aCols[nY][aPos[04]]+aCols[nY][aPos[05]]+aCols[nY][aPos[06]]+aCols[nY][aPos[07]]+aCols[nY][aPos[08]]))
							EndIf
							lAtualiza	:= .T.

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]
								If lExiste
									RecLock("CDL",.F.)
								Else
									RecLock("CDL",.T.)
									CDL->CDL_FILIAL	:= xFilial("CDL")
									CDL->CDL_DOC	:= cDoc
									SerieNfId("CDL",1,"CDL_SERIE",,,,cSerie)
									CDL->CDL_ESPEC	:= cEspecie
									CDL->CDL_CLIENT	:= cClieFor
									CDL->CDL_LOJA	:= cLoja
								Endif
								For nZ := 1 To Len(aHeader)
									CDL->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
									If lSdoc
										If aHeader[nZ][2] == "CDL_SERORI"
											cSerOri := aCols[nY][nZ]
										Elseif aHeader[nZ][2] == "CDL_DTORI "
											dDtOri := aCols[nY][nZ]
										Elseif aHeader[nZ][2] == "CDL_ESPORI"
											cEspOri := aCols[nY][nZ]
										ElseIf aHeader[nZ][2] == "CDL_SEREXP"
											cSerExp := aCols[nY][nZ]
										Elseif aHeader[nZ][2] == "CDL_EMIEXP"
											dDtExp := aCols[nY][nZ]
										Elseif aHeader[nZ][2] == "CDL_ESPEXP"
											cEspExp := aCols[nY][nZ]
										EndIf
									EndIf
								Next nY

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Id da serie para compor as chaves das funcoes ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lSdoc
									SerieNfId("CDL",1,"CDL_SERORI",dDtOri,cEspOri,cSerOri)
									SerieNfId("CDL",1,"CDL_SEREXP",dDtExp,cEspExp,cSerExp)
								EndIf

								MsUnLock()
								FkCommit()
							Else
								// Exclusao
								If lExiste
									If nCount <= 0
										cAlerta 	:= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
										lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037)) //"Atenção"
										nCount ++
									Endif
									If lExclusao
										lAtualiza := .F.
									Endif
								Endif
							Endif

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Atualiza o array com os documentos que permanecerao na tabela³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lSdoc
								If lAtualiza
									nPosx := aScan(aMantem[5],{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8]+x[9]+x[10]+x[11]+x[12]+x[13] ==;
											cDoc+cSerie+cClieFor+cLoja+aCols[nY][aPos[01]]+aCols[nY][aPos[02]]+aCols[nY][aPos[03]]+aCols[nY][aPos[04]]+aCols[nY][aPos[05]]+aCols[nY][aPos[06]]+aCols[nY][aPos[07]]+aCols[nY][aPos[08]]+Dtos(aCols[nY][aPos[09]])})
									If nPosx > 0
										aMantem[5][nPosx][14] := .T.
									Endif
								Endif
							Else
								If lAtualiza
									nPosx := aScan(aMantem[5],{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8]+x[9]+x[10]+x[11]+x[12] ==;
											cDoc+cSerie+cClieFor+cLoja+aCols[nY][aPos[01]]+aCols[nY][aPos[02]]+aCols[nY][aPos[03]]+aCols[nY][aPos[04]]+aCols[nY][aPos[05]]+aCols[nY][aPos[06]]+aCols[nY][aPos[07]]+aCols[nY][aPos[08]]})
									If nPosx > 0
										aMantem[5][nPosx][13] := .T.
									Endif
								Endif
							Endif
						Next
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Como no complemento de exportacao o numero do documento de exportacao                          ³
						//³faz parte da chave e e possivel altera-lo, apos a atualizacao dos complementos,                ³
						//³exclui-se as referencias que existiam na base mas nao existem mais devido a alteracao no acols.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI := 1 to Len(aMantem[5])
							If lSdoc
								If !aMantem[5][nI][14]
									If (CDL->(dbSeek(xFilial("CDL")+aMantem[5][nI][1]+aMantem[5][nI][2]+aMantem[5][nI][3]+aMantem[5][nI][4]+aMantem[5][nI][5]+aMantem[5][nI][6]+aMantem[5][nI][7]+aMantem[5][nI][8]+aMantem[5][nI][9]+aMantem[5][nI][10]+aMantem[5][nI][11]+aMantem[5][nI][12]+aMantem[5][nI][13])))
										RecLock("CDL",.F.)
										CDL->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Else
								If !aMantem[5][nI][13]
									If (CDL->(dbSeek(xFilial("CDL")+aMantem[5][nI][1]+aMantem[5][nI][2]+aMantem[5][nI][3]+aMantem[5][nI][4]+aMantem[5][nI][5]+aMantem[5][nI][6]+aMantem[5][nI][7]+aMantem[5][nI][8]+aMantem[5][nI][9]+aMantem[5][nI][10]+aMantem[5][nI][11]+aMantem[5][nI][12])))
										RecLock("CDL",.F.)
										CDL->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf

				Case nX == 17 .And. lAnfavea

					For nY := 1 to Len(aCols)

						lExiste 	:= CDR->(dbSeek(xFilial("CDR")+cEntSai+cDoc+cSerie+cClieFor+cLoja))
						lAtualiza 	:= .T.

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se o item nao esta excluido no aCols³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !aCols[nY][Len(aHeader)+1]
							If lExiste
								RecLock("CDR",.F.)
							Else
								RecLock("CDR",.T.)
								CDR->CDR_FILIAL	:= xFilial("CDR")
								CDR->CDR_TPMOV	:= cEntSai
								CDR->CDR_DOC	:= cDoc
								SerieNfId("CDR",1,"CDR_SERIE",,,,cSerie)
								CDR->CDR_ESPEC	:= cEspecie
								CDR->CDR_CLIFOR	:= cClieFor
								CDR->CDR_LOJA	:= cLoja
							Endif
							For nZ := 1 To Len(aHeader)
								CDR->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
							Next nY

							MsUnLock()
							FkCommit()
						Else
							// Exclusao
							If lExiste
								If nCount <= 0
									cAlerta		:= STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									lExclusao	:= MsgYesNo(cAlerta,OemToAnsi(STR0037))
									nCount ++
								Endif

								If lExclusao
									lAtualiza := .F.
								Endif
							Endif
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o array com os documentos que permanecerao na tabela³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lAtualiza
							nPosx := aScan(aMantem[7],{|x| x[1]+x[2]+x[3]+x[4]+x[5] ==;
									 cEntSai+cDoc+cSerie+cClieFor+cLoja})
							If nPosx > 0
								aMantem[7][nPosx][6] := .T.
							Endif
						Endif
					Next
				Case nX == 18 .And. lAnfavea

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDS_ITEM"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CDS_PRODUT"})

					If nPos > 0 .AND. nPos2 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste := CDS->(dbSeek(xFilial("CDS")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If !lExiste
									RecLock("CDS",.T.)
									CDS->CDS_FILIAL	:= xFilial("CDS")
									CDS->CDS_TPMOV	:= cEntSai
									SerieNfId("CDS",1,"CDS_SERIE",,,,cSerie)
									CDS->CDS_DOC	:= cDoc
									CDS->CDS_CLIFOR	:= cClieFor
									CDS->CDS_LOJA	:= cLoja
									CDS->CDS_ITEM	:= aCols[nY][nPos]
									CDS->CDS_PRODUT	:= aCols[nY][nPos2]
									CDS->CDS_ESPEC	:= cEspecie
								Else
									RecLock("CDS",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									CDS->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
									If lSdoc
										If aHeader[nZ][2] == "CDS_SEREMB"
											cSerEmb := aCols[nY][nZ]
										Elseif aHeader[nZ][2] == "CDS_DTEMB "
											dDtEmb := aCols[nY][nZ]
										Elseif aHeader[nZ][2] == "CDS_ESPEMB"
											cEspEmb := aCols[nY][nZ]
										EndIf
									EndIf
								Next nY

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Id da serie para compor as chaves das funcoes ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lSdoc
									SerieNfId("CDS",1,"CDS_SEREMB",dDtEmb,cEspEmb,cSerEmb)
								EndIf
								MsUnLock()
								FkCommit()
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CDS",.F.)
										CDS->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf
				Case nX == 19

					nPos		:= aScan(aHeader,{|x| Alltrim(x[2])=="CD0_ITEM"})
					nPos2		:= aScan(aHeader,{|x| Alltrim(x[2])=="CD0_COD"})
					nPosQt		:= aScan(aHeader,{|x| Alltrim(x[2])=="CD0_QUANT"})
					nPosVUn		:= aScan(aHeader,{|x| Alltrim(x[2])=="CD0_VUNIT"})
					nPosVBST	:= aScan(aHeader,{|x| Alltrim(x[2])=="CD0_VALBST"})

					If	nPos > 0 .And. nPos2 > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)
							nCvh := 0
							For nCvh := 1 To Len(aHeader)
								Do Case
									Case Alltrim(aHeader[nCvh][2]) == "CD0_DOCENT"
										cCodEnt := aCols[nY][nCvh]
									Case Alltrim(aHeader[nCvh][2]) == "CD0_SERENT"
										cSerEnt := aCols[nY][nCvh]
									Case Alltrim(aHeader[nCvh][2]) == "CD0_ESPECI"
										cEspeci := aCols[nY][nCvh]
									Case Alltrim(aHeader[nCvh][2]) == "CD0_FORNE"
										cForne := aCols[nY][nCvh]
									Case Alltrim(aHeader[nCvh][2]) == "CD0_LOJENT"
										cLojEnt := aCols[nY][nCvh]
								EndCase
							Next nCvh

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste	:= CD0->(dbSeek(xFilial("CD0")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]+cCodEnt+cSerEnt+cEspeci+cForne+cLojEnt))
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]
								If nPosQt>0 .And. nPosVUn>0 .And. nPosVBST>0
									If aCols[nY][nPosQt]>0	.And.;
										aCols[nY][nPosVUn]>0 .And.;
										aCols[nY][nPosVBST]>0
										If !lExiste
											RecLock("CD0",.T.)
											CD0->CD0_FILIAL	:= xFilial("CD0")
											CD0->CD0_TPMOV	:= cEntSai
											CD0->CD0_DOC	:= cDoc
											SerieNfId("CD0",1,"CD0_SERIE",,,,cSerie)
											CD0->CD0_CLIFOR	:= cClieFor
											CD0->CD0_LOJA	:= cLoja
											CD0->CD0_DOCENT := cCodEnt
											CD0->CD0_SERENT := cSerEnt
											CD0->CD0_ESPECI := cEspeci
											CD0->CD0_FORNE  := cForne
											CD0->CD0_LOJENT := cLojEnt
											IF lCmpCD0 .And. Empty(CD0->CD0_ID)//Novos campos CD0
												CD0->CD0_ID := FWUUID("MATA926")
											Endif
										Else
											RecLock("CD0",.F.)
										Endif
										For nZ := 1 To Len(aHeader)
											CD0->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
										Next nY
										CD0->(MsUnLock())
										FkCommit()
										If lCompCD0
											dbSelectArea("CD0")
											CD0->(dbSetOrder(1))
										EndIf
									EndIf
								EndIf
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CD0",.F.)
										CD0->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					EndIf

				Case nX == 20 .And. lTabCG8
					nPos := aScan(aHeader,{|x| Alltrim(x[2])=="CG8_TPESP"})
					If	nPos > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste := CG8->(dbSeek(xFilial("CG8")+cDoc+cSerie+cClieFor+cLoja))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]

								If len(alltrim(aCols[nY][nPos]))>0

									If !lExiste
										RecLock("CG8",.T.)
										CG8->CG8_FILIAL	:= xFilial("CG8")
										CG8->CG8_NUMDOC	:= cDoc
										SerieNfId("CG8",1,"CG8_SERIE",,,,cSerie)
										CG8->CG8_FORNEC	:= cClieFor
										CG8->CG8_LOJA	:= cLoja
									Else
										RecLock("CG8",.F.)
									Endif

									For nZ := 1 To Len(aHeader)
										CG8->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
									Next nY

									MsUnLock()
									FkCommit()
								EndIf
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0038 //"Todos os itens selecionados serão excluídos podendo, desta forma, "
									cAlerta += STR0039 //"excluir todo o complemento do documento. Confirma a exclusão?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CG8",.F.)
										CG8->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					Endif

				Case nX == 21 .And. lTabCFF

					CFF->(dbSelectArea("CFF"))

					If lCmpCFF
						CFF->(DbSetOrder (4))	
					Else
						CFF->(DbSetOrder (1))
					EndIf	

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_CODLEG"})
					nPos1	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_CODIGO"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_ANEXO"})
					nPos3	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_ART"})
					nPos4	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_INC"})
					nPos5	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_ALIN"})
					nPos6	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_PRG"})
					nPos7	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_ITM"})
					nPos8	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_LTR"})
					nPos9	:= aScan(aHeader,{|x| Alltrim(x[2])=="CFF_ITEMNF"})

					//SE ESTIVER ALTERANDO UM REGISTRO JA CADASTRADO NA TABELA, ELE EXCLUI ESSE REGISTRO, POIS SERÁ GRAVADO UM NOVO LOGO ABAIXO
					For nY := 1 to Len(aCols)
						If lCmpCFF //Verifica se existe o campo CCF_TIPO para que o dbseek seja efetuado com o mesmo
							IF CFF->(DbSeek(xFilial("CFF")+cDoc+cSerie+cClieFor+cLoja+cEntSai+cTpNF))
								RecLock("CFF",.F.)
								CFF->(dbDelete())
								MsUnLock()
								FkCommit()
							EndIf
						Else
							IF CFF->(DbSeek(xFilial("CFF")+cDoc+cSerie+cClieFor+cLoja))
								RecLock("CFF",.F.)
								CFF->(dbDelete())
								MsUnLock()
								FkCommit()
							EndIf
						EndIf
					Next
					If	nPos > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
						//³item exista em um registro do aCols nao marcado para delecao.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cItem	:= aCols[nY][nPos9]
							If lCmpCFF
								lExiste	:= CFF->(DbSeek(xFilial("CFF")+cDoc+cSerie+cClieFor+cLoja+cEntSai+cTpNF+aCols[nY][nPos]+aCols[nY][nPos1]+aCols[nY][nPos2]+aCols[nY][nPos3]+aCols[nY][nPos4]+aCols[nY][nPos5]+aCols[nY][nPos6]))
							Else
								lExiste	:= CFF->(DbSeek(xFilial("CFF")+cDoc+cSerie+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos1]+aCols[nY][nPos2]+aCols[nY][nPos3]+aCols[nY][nPos4]+aCols[nY][nPos5]+aCols[nY][nPos6]+aCols[nY][nPos7]+aCols[nY][nPos8]))
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]
								If len(alltrim(aCols[nY][nPos]))>0
									If !lExiste .Or. (lExiste .And. cItem<> cItemOld)
										RecLock("CFF",.T.)
										CFF->CFF_FILIAL	:= xFilial("CFF")
										CFF->CFF_NUMDOC	:= (cDoc)
										SerieNfId("CFF",1,"CFF_SERIE",,,,cSerie)
										CFF->CFF_CLIFOR	:= (cClieFor)
										CFF->CFF_LOJA	:= (cLoja)
										
										If lCmpCFF
											CFF->CFF_TPMOV := cEntSai
											CFF->CFF_TIPO  := cTpNF
										EndIf

										CFF->CFF_ITEMNF	:= (cItem)
									Else
										RecLock("CFF",.F.)
									Endif
									For nZ := 1 To Len(aHeader)
										CFF->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
									Next nY
									cItemOld := cItem
									MsUnLock()
									FkCommit()
								EndIf
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0038 //"Todos os itens selecionados serão excluídos podendo, desta forma, "
									cAlerta += STR0039 //"excluir todo o complemento do documento. Confirma a exclusão?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("CFF",.F.)
										CFF->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next
					Endif
				Case nX == 22 .And. lCompCF8

					CF8->(dbSelectArea("CF8"))
					CF8->(DbSetOrder(3))
					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="CF8_DOC"})
					lExiste	:= CF8->(DbSeek(xFilial("CF8")+cDoc+cSerie+cClieFor+cLoja))
					If	nPos > 0
						//³Deleta o item posicionado pelo aCols³
						For nI := 1 to Len(aCols)
							If aCols[nI][Len(aHeader)+1]
								RecLock("CF8",.F.)
								CF8->(dbDelete())
								MsUnLock()
								FkCommit()
							Endif
						Next
					Endif

				Case nX == 23 .And. lCompF0A

					nPos	:= aScan(aHeader,{|x| Alltrim(x[2])=="F0A_ITEM"})
					nPos2	:= aScan(aHeader,{|x| Alltrim(x[2])=="F0A_COD"})

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Exclui os itens marcados para delecao do aCols, caso o mesmo ³
					//³item exista em um registro do aCols nao marcado para delecao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If nPos > 0 .AND. nPos2 > 0
						aDeleta := M926DelDup(aCols,aHeader,nPos)

						For nY := 1 to Len(aCols)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item existe para altera-lo ou gravar um novo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lExiste := F0A->(dbSeek(xFilial("F0A")+cEntSai+cSerie+PADR(cDoc,TamSX3("F0A_DOC")[1])+cClieFor+cLoja+aCols[nY][nPos]+aCols[nY][nPos2]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item nao esta excluido no aCols³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !aCols[nY][Len(aHeader)+1]
								If !lExiste
									RecLock("F0A",.T.)
									F0A->F0A_FILIAL	:= xFilial("F0A")
									F0A->F0A_TPMOV	:= cEntSai
									F0A->F0A_DOC	:= cDoc
									F0A->F0A_SERIE	:= cSerie
									F0A->F0A_CLIFOR	:= cClieFor
									F0A->F0A_LOJA	:= cLoja
								Else
									RecLock("F0A",.F.)
								Endif

								For nZ := 1 To Len(aHeader)
									F0A->(FieldPut(FieldPos(aHeader[nZ][2]),aCols[nY][nZ]))
								Next nY

								MsUnLock()
								FkCommit()
							Else
								If lExiste .And. (aScan(aDeleta,{|x| x == aCols[nY][nPos]}) == 0)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se confirma a exclusao dos itens³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cAlerta := STR0076 //"Todos os itens selecionados serao excluidos. Deseja continuar?"
									If nCount <= 0
										lExclusao := MsgYesNo(cAlerta,OemToAnsi(STR0037))
										nCount ++
									Endif
									If lExclusao
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Deleta o item posicionado pelo aCols³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("F0A",.F.)
										F0A->(dbDelete())
										MsUnLock()
										FkCommit()
									Endif
								Endif
							Endif
						Next nY
					EndIf
			EndCase
		Endif
	Next

	// Integracao NATIVA PROTHEUS x TAF
	If lRet
		If cPaisLoc == "BRA" .And. GetNewPar("MV_INTTAF","N") == "S" .And. SFT->(FieldPos("FT_TAFKEY")) > 0
			If FindFunction("TAFVldAmb") .And. TAFVldAmb("1") .And. FindFunction("DocFisxTAF")
				DbSelectArea("SFT")
				SFT->(dbSetOrder(1))
				SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja))
				cDtEntrada := SFT->FT_ENTRADA

				// Chama Job para intregacao NATIVA do documento fiscal do Protheus no TAF
				/*
					DocFisxTAF(c_EmpresaT,c_FilialT,a_DocSFT,l_LmTafKey)
					@param c_EmpresaT, caracter, contem a empresa para thread
					@param c_FilialT, caracter, contem a filial para thread
					@param a_DocSFT, array, contem as informações do documento informado
					@param l_LmTafKey, logico, se deve limpar o campo FT_TAFKEY

					@author Vitor Ribeiro (vitor.e@totvs.com.br)
					@since 02/01/2018
				*/
				StartJob("DocFisxTAF",GetEnvServer(),.F.,cEmpAnt,cFilAnt,{cDoc,cSerie,cClieFor,cLoja,cEntSai,cDtEntrada},.T.)
			EndIf
		EndIf
	EndIf

End Transaction

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Ag    ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de agua canalizada           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Ag(oGetAg,aObrigat)
Local aCols		:= oGetAg:aCols
Local lRet		:= .T.
Local lObrigat	:= .F.
Local nX		:= 0
Local cCampoRet	:= ""

For nX := 1 to Len(aCols)
	If !(aCols[nX][Len(aHAgua)+1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lObrigat := M926Obrig(aObrigat,aHAgua,aCols[nX],1,@cCampoRet)
			Exit
		Endif
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926OBR1",,cCampoRet,3,1)
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Imp   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de importacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Imp(oGetImp,aObrigat,lTudoOk)
Local	aCols		:= oGetImp:aCols
Local	aPos		:= {}
Local	aDocImp		:= {}
Local	lRet		:= .T.
Local	lPis		:= .F.
Local	lCofins		:= .F.
Local	lObrigat	:= .F.
Local	lDiAdic		:= .F.
Local 	cCampoRet	:=	""
Local 	nX			:= 0
Local 	nAt			:= oGetImp:nAt
Local 	nZ			:= 0
Local 	nTo			:= 0
Local 	nIni		:= 0

Default	lTudoOk	:=	.F.

nTo	:=	Iif(lTudoOk,Len(aCols),nAt)
nIni:=	Iif(lTudoOk,1,nAt)

aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_DOCIMP"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_BSPIS"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_ALPIS"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_VLPIS"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_BSCOF"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_ALCOF"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_VLCOF"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_NACDRAW"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_NADIC"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_SQADIC"}))
aAdd(aPos,aScan(aHImp,{|x| Alltrim(x[2])=="CD5_NDI"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o numero da adicao e a sequencia de adicao ja foram digitados em outra linha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nZ := ASCANX(aCols,{|x| x[14] == aCols[nAt][aPos[11]] .And. x[20] == aCols[nAt][aPos[9]] .And. x[21] == aCols[nAt][aPos[10]] .And. !x[Len(aHImp)+1]},nAt+1)) >0
	lDiAdic	:=	.T.
Endif

If (nZ := ASCANX(aCols,{|x| x[14] == aCols[nAt][aPos[11]] .And. x[20] == aCols[nAt][aPos[9]] .And. x[21] == aCols[nAt][aPos[10]] .And. !x[Len(aHImp)+1]},1,nAt-1)) >0
	lDiAdic	:=	.T.
Endif

For nX := nIni to nTo

	If !(aCols[nX][Len(aHImp)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³³Verifica se algum campo obrigatorio nao foi digitado				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lObrigat := M926Obrig(aObrigat,aHImp,aCols[nX],7,@cCampoRet)
			Exit
		Endif

		aAdd(aDocImp,{aCols[nX][aPos[1]],aCols[nX][aPos[3]],aCols[nX][aPos[6]],aCols[nX][aPos[9]]})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe base de PIS sem aliquota ou valor ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[nX][aPos[2]] + aCols[nX][aPos[3]] + aCols[nX][aPos[4]] > 0) .And. (aCols[nX][aPos[2]] == 0 .Or. (aCols[nX][aPos[2]] > 0 .And. aCols[nX][aPos[3]] > 0 .And. aCols[nX][aPos[4]] == 0))
			lPis := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe base de COFINS sem aliquota ou valor ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[nX][aPos[5]] + aCols[nX][aPos[6]] + aCols[nX][aPos[7]] > 0) .And. (aCols[nX][aPos[5]] == 0 .Or. (aCols[nX][aPos[5]] > 0 .And. aCols[nX][aPos[6]] > 0 .And. aCols[nX][aPos[7]] == 0))
			lCofins := .T.
		Endif

	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa que o numero do documento ja foi informado em outro item.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lDiAdic .And. lObrigat) .Or. lObrigat
	Help("  ",1,"A926OBR2",,cCampoRet,3,1)
	lRet := .F.
Elseif lDiAdic
	Help("  ",1,"A926DUP",,"CD5_NDI, CD5_NADIC, CD5_SQADIC",3,1)
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe base de PIS sem aliquota ou valor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPis
	Help("  ",1,"A926Pis")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe base de Cofins sem aliquota ou valor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCofins
	Help("  ",1,"A926Cof")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Tele  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de comunicacao/telecom       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da get dados de comunicacao                 ³±±
±±³          ³ ExpC2 = Numero do documento                                ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Especie                                            ³±±
±±³          ³ ExpC5 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC6 = Loja                                               ³±±
±±³          ³ ExpC7 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC8 = Indica se o documento e de devol/beneficiamento    ³±±
±±³          ³ ExpC9 = Array com os campos obrigatorios das tabelas       ³±±
±±³          ³ ExpCA = Indica se e validacao do ok da janela              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Indicacao de validacao ok ou nao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Tele(oGetCom,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,lFinal)

Local aCols			:= oGetCom:aCols
Local aItens		:= {}
Local aPos			:= {}
Local lRet			:= .T.
Local lDuplica		:= .F.
Local lItem			:= .F.
Local lObrigat		:= .F.
Local lReceita		:= .F.
Local lMVESTTELE	:=  GetNewPar("MV_ESTTELE", .F.)
Local lSeek			:= .T.
Local nX			:= 0
Local nAt			:= oGetCom:nAt

SFT->(dbSetOrder(1))
SA1->(dbSetOrder(1))

aAdd(aPos,aScan(aHComun,{|x| Alltrim(x[2])=="FX_ITEM"}))
aAdd(aPos,aScan(aHComun,{|x| Alltrim(x[2])=="FX_COD"}))
aAdd(aPos,aScan(aHComun,{|x| Alltrim(x[2])=="FX_RECEP"}))
aAdd(aPos,aScan(aHComun,{|x| Alltrim(x[2])=="FX_LOJAREC"}))
aAdd(aPos,aScan(aHComun,{|x| Alltrim(x[2])=="FX_TIPOREC"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHComun)+1])

	If M926Obrig(aObrigat,aHComun,aCols[nAt],4)
		lObrigat := .T.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso haja receptor da receita, os campos FX_RECEP, FX_LOJAREC e FX_TIPOREC devem estar preenchidos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(aCols[nAt][aPos[3]]) .And. Empty(aCols[nAt][aPos[4]])) .Or.;
		(Empty(aCols[nAt][aPos[3]]) .And. !Empty(aCols[nAt][aPos[4]])) .Or.;
		(!Empty(aCols[nAt][aPos[3]]) .And. !Empty(aCols[nAt][aPos[4]]) .And. Empty(aCols[nAt][aPos[5]])) .Or.;
		(Empty(aCols[nAt][aPos[3]]) .And. Empty(aCols[nAt][aPos[4]]) .And. !Empty(aCols[nAt][aPos[5]]))
		lReceita := .T.
	Endif

Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHComun)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacoes do ok da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M926Obrig(aObrigat,aHComun,aCols[nX],4)
				lObrigat := .T.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o receptor da receita existe na tabela de clientes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]]) .And. !SA1->(dbSeek(xFilial("SA1")+aCols[nX][aPos[3]]+aCols[nX][aPos[4]]))
				lReceita := .T.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso haja receptor da receita, os campos FX_RECEP, FX_LOJAREC e FX_TIPOREC devem estar preenchidos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (!Empty(aCols[nX][aPos[3]]) .And. Empty(aCols[nX][aPos[4]])) .Or.;
				(Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]])) .Or.;
				(!Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]]) .And. Empty(aCols[nX][aPos[5]])) .Or.;
				(Empty(aCols[nX][aPos[3]]) .And. Empty(aCols[nX][aPos[4]]) .And. !Empty(aCols[nX][aPos[5]]))
				lReceita := .T.
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence a nota fiscal que esta sendo complementada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Para tipo de receita igual a 6- Receita própria – serviços a faturar em período futuro existe uma exceção, pois não terá item correspondete no livro
		//e quando o parâmetro MV_ESTTELE estiver igual a .T.
		lSeek	:= .T.
		IF lMVESTTELE .AND. Alltrim(aCols[nX][10]) == "6"
			lSeek	:= .F.
		EndIF

		If lSeek
			If !SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nX][aPos[1]]+aCols[nX][aPos[2]]))
				lItem := .T.
			Endif
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido nao esta em duplicidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aItens,{|x| x == aCols[nX][aPos[1]]}) > 0
			lDuplica := .T.
		Endif
		aAdd(aItens,aCols[nX][aPos[1]])

	Endif

Next

If lObrigat
	Help("  ",1,"A926ComObr")
	lRet := .F.
Endif

If lDuplica
	Help("  ",1,"A926Dupl")
	lRet := .F.
Endif

If lItem
	Help("  ",1,"A926Itens")
	lRet := .F.
Endif

If lReceita
	Help("  ",1,"A926Recep")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Ener  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de energia eletrica          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da get energia eletrica                     ³±±
±±³          ³ ExpC2 = Numero do documento                                ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Especie                                            ³±±
±±³          ³ ExpC5 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC6 = Loja                                               ³±±
±±³          ³ ExpC7 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC8 = Indica se o documento e de devol/beneficiamento    ³±±
±±³          ³ ExpC9 = Array com os campos obrigatorios das tabelas       ³±±
±±³          ³ ExpCA = Indica se e validacao do ok da janela              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Indicacao de validacao ok ou nao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Ener(oGetEn,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,lFinal)

Local aCols		:= oGetEn:aCols
Local aItens	:= {}
Local aPos		:= {}

Local lRet		:= .T.
Local lDuplica	:= .F.
Local lItem		:= .F.
Local lObrigat	:= .F.
Local lReceita	:= .F.

Local nX		:= 0
Local nAt		:= oGetEn:nAt

SFT->(dbSetOrder(1))
SA1->(dbSetOrder(1))

aAdd(aPos,aScan(aHEner,{|x| Alltrim(x[2])=="FU_ITEM"}))
aAdd(aPos,aScan(aHEner,{|x| Alltrim(x[2])=="FU_COD"}))
aAdd(aPos,aScan(aHEner,{|x| Alltrim(x[2])=="FU_RECEP"}))
aAdd(aPos,aScan(aHEner,{|x| Alltrim(x[2])=="FU_LOJAREC"}))
aAdd(aPos,aScan(aHEner,{|x| Alltrim(x[2])=="FU_TIPOREC"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHEner)+1])

	If M926Obrig(aObrigat,aHEner,aCols[nAt],5)
		lObrigat := .T.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso haja receptor da receita, os campos FU_RECEP, FU_LOJAREC e FU_TIPOREC devem estar preenchidos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(aCols[nAt][aPos[3]]) .And. Empty(aCols[nAt][aPos[4]])) .Or.;
		(Empty(aCols[nAt][aPos[3]]) .And. !Empty(aCols[nAt][aPos[4]])) .Or.;
		(!Empty(aCols[nAt][aPos[3]]) .And. !Empty(aCols[nAt][aPos[4]]) .And. Empty(aCols[nAt][aPos[5]])) .Or.;
		(Empty(aCols[nAt][aPos[3]]) .And. Empty(aCols[nAt][aPos[4]]) .And. !Empty(aCols[nAt][aPos[5]]))
		lReceita := .T.
	Endif

Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHEner)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacoes do ok da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M926Obrig(aObrigat,aHEner,aCols[nX],5)
				lObrigat := .T.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o receptor da receita existe na tabela de clientes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]]) .And. !SA1->(dbSeek(xFilial("SA1")+aCols[nX][aPos[3]]+aCols[nX][aPos[4]]))
				lReceita := .T.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso haja receptor da receita, os campos FU_RECEP, FU_LOJAREC e FU_TIPOREC devem estar preenchidos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (!Empty(aCols[nX][aPos[3]]) .And. Empty(aCols[nX][aPos[4]])) .Or.;
				(Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]])) .Or.;
				(!Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]]) .And. Empty(aCols[nX][aPos[5]])) .Or.;
				(Empty(aCols[nX][aPos[3]]) .And. Empty(aCols[nX][aPos[4]]) .And. !Empty(aCols[nX][aPos[5]]))
				lReceita := .T.
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence a nota fiscal que esta sendo complementada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nX][aPos[1]]+aCols[nX][aPos[2]]))
			lItem := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido nao esta em duplicidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aItens,{|x| x == aCols[nX][aPos[1]]}) > 0
			lDuplica := .T.
		Endif
		aAdd(aItens,aCols[nX][aPos[1]])

	Endif

Next

If lObrigat
	Help("  ",1,"A926EneObr")
	lRet := .F.
Endif

If lDuplica
	Help("  ",1,"A926Dupl")
	lRet := .F.
Endif

If lItem
	Help("  ",1,"A926Itens")
	lRet := .F.
Endif

If lReceita
	Help("  ",1,"A926Recep")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Gas   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de gas canalizado            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da get dados de gas canalizado              ³±±
±±³          ³ ExpC2 = Numero do documento                                ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Especie                                            ³±±
±±³          ³ ExpC5 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC6 = Loja                                               ³±±
±±³          ³ ExpC7 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC8 = Indica se o documento e de devol/beneficiamento    ³±±
±±³          ³ ExpC9 = Array com os campos obrigatorios das tabelas       ³±±
±±³          ³ ExpCA = Indica se e validacao do ok da janela              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Indicacao de validacao ok ou nao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Gas(oGetGas,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,lFinal)

Local aCols		:= oGetGas:aCols
Local aItens	:= {}
Local aPos		:= {}

Local lRet		:= .T.
Local lDuplica	:= .F.
Local lItem		:= .F.
Local lObrigat	:= .F.
Local lReceita	:= .F.

Local nX		:= 0
Local nAt		:= oGetGas:nAt

SFT->(dbSetOrder(1))
SA1->(dbSetOrder(1))

aAdd(aPos,aScan(aHGas,{|x| Alltrim(x[2])=="CD3_ITEM"}))
aAdd(aPos,aScan(aHGas,{|x| Alltrim(x[2])=="CD3_COD"}))
aAdd(aPos,aScan(aHGas,{|x| Alltrim(x[2])=="CD3_RECEP"}))
aAdd(aPos,aScan(aHGas,{|x| Alltrim(x[2])=="CD3_LOJARE"}))
aAdd(aPos,aScan(aHGas,{|x| Alltrim(x[2])=="CD3_TPREC"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHGas)+1])

	If M926Obrig(aObrigat,aHGas,aCols[nAt],6)
		lObrigat := .T.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso haja receptor da receita, os campos CD3_RECEP, CD3_LOJARE e CD3_TPREC devem estar preenchidos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(aCols[nAt][aPos[3]]) .And. Empty(aCols[nAt][aPos[4]])) .Or.;
		(Empty(aCols[nAt][aPos[3]]) .And. !Empty(aCols[nAt][aPos[4]])) .Or.;
		(!Empty(aCols[nAt][aPos[3]]) .And. !Empty(aCols[nAt][aPos[4]]) .And. Empty(aCols[nAt][aPos[5]])) .Or.;
		(Empty(aCols[nAt][aPos[3]]) .And. Empty(aCols[nAt][aPos[4]]) .And. !Empty(aCols[nAt][aPos[5]]))
		lReceita := .T.
	Endif

Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHGas)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacoes do ok da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M926Obrig(aObrigat,aHGas,aCols[nX],6)
				lObrigat := .T.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o receptor da receita existe na tabela de clientes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]]) .And. !SA1->(dbSeek(xFilial("SA1")+aCols[nX][aPos[3]]+aCols[nX][aPos[4]]))
				lReceita := .T.
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso haja receptor da receita, os campos CD3_RECEP, CD3_LOJARE e CD3_TPREC devem estar preenchidos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (!Empty(aCols[nX][aPos[3]]) .And. Empty(aCols[nX][aPos[4]])) .Or.;
				(Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]])) .Or.;
				(!Empty(aCols[nX][aPos[3]]) .And. !Empty(aCols[nX][aPos[4]]) .And. Empty(aCols[nX][aPos[5]])) .Or.;
				(Empty(aCols[nX][aPos[3]]) .And. Empty(aCols[nX][aPos[4]]) .And. !Empty(aCols[nX][aPos[5]]))
				lReceita := .T.
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence a nota fiscal que esta sendo complementada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nX][aPos[1]]+aCols[nX][aPos[2]]))
			lItem := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido nao esta em duplicidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aItens,{|x| x == aCols[nX][aPos[1]]}) > 0
			lDuplica := .T.
		Endif
		aAdd(aItens,aCols[nX][aPos[1]])

	Endif

Next

If lObrigat
	Help("  ",1,"A926GasObr")
	lRet := .F.
Endif

If lDuplica
	Help("  ",1,"A926Dupl")
	lRet := .F.
Endif

If lItem
	Help("  ",1,"A926Itens")
	lRet := .F.
Endif

If lReceita
	Help("  ",1,"A926Recep")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Med   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de medicamentos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da get dados de medicamentos                ³±±
±±³          ³ ExpC2 = Numero do documento                                ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Especie                                            ³±±
±±³          ³ ExpC5 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC6 = Loja                                               ³±±
±±³          ³ ExpC7 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC8 = Indica se o documento e de devol/beneficiamento    ³±±
±±³          ³ ExpC9 = Array com os campos obrigatorios das tabelas       ³±±
±±³          ³ ExpCA = Indica se e validacao do ok da janela              ³±±
±±³          ³ ExpCB = Array com os itens do grupo de medicamentos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Indicacao de validacao ok ou nao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Med(oGetMed,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,lFinal,aMedica)

Local aCols		:= oGetMed:aCols
Local aItens	:= {}
Local aPos		:= {}

Local lRet		:= .T.
Local lDuplica	:= .F.
Local lItem		:= .F.
Local lObrigat	:= .F.
Local lGrupo 	:= .F.

Local nX		:= 0
Local nAt		:= oGetMed:nAt

SFT->(dbSetOrder(1))

aAdd(aPos,aScan(aHMed,{|x| Alltrim(x[2])=="CD7_ITEM"}))
aAdd(aPos,aScan(aHMed,{|x| Alltrim(x[2])=="CD7_COD"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHMed)+1])

	If M926Obrig(aObrigat,aHMed,aCols[nAt],8)
		lObrigat := .T.
	Endif

Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHMed)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacoes do ok da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M926Obrig(aObrigat,aHMed,aCols[nX],8)
				lObrigat := .T.
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence a nota fiscal que esta sendo complementada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nX][aPos[1]]+aCols[nX][aPos[2]]))
			lItem := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence ao grupo de medicamentos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(aScan(aMedica,{|x| x[1] == xFilial("CD7") .And. ;
			x[2] == cDoc .And. ;
			x[3] == cSerie .And.;
			x[4] == cClieFor .And. ;
			x[5] == cLoja .And.;
			x[6] == cEntSai .And.;
			x[7] == aCols[nX][aPos[1]] .And.;
			x[8] == aCols[nX][aPos[2]]}) > 0)
			lGrupo := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido nao esta em duplicidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aItens,{|x| x == aCols[nX][aPos[1]]}) > 0
			lDuplica := .T.
		Endif
		aAdd(aItens,aCols[nX][aPos[1]])

	Endif

Next

If lObrigat
	Help("  ",1,"A926MedObr")
	lRet := .F.
Endif

If lDuplica
	Help("  ",1,"A926Dupl")
	lRet := .F.
Endif

If lItem
	Help("  ",1,"A926Itens")
	lRet := .F.
Endif

If lGrupo
	Help("  ",1,"A926Grupo")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Arma  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de armas de fogo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da get dados de armas de fogo               ³±±
±±³          ³ ExpC2 = Numero do documento                                ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Especie                                            ³±±
±±³          ³ ExpC5 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC6 = Loja                                               ³±±
±±³          ³ ExpC7 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC8 = Indica se o documento e de devol/beneficiamento    ³±±
±±³          ³ ExpC9 = Array com os campos obrigatorios das tabelas       ³±±
±±³          ³ ExpCA = Indica se e validacao do ok da janela              ³±±
±±³          ³ ExpCB = Array com os itens do grupo de armas de fogo       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Indicacao de validacao ok ou nao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Arma(oGetAr,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,lFinal,aArma)

Local aCols		:= oGetAr:aCols
Local aItens	:= {}
Local aPos		:= {}

Local lRet		:= .T.
Local lDuplica	:= .F.
Local lItem		:= .F.
Local lObrigat	:= .F.
Local lGrupo 	:= .F.

Local nX		:= 0
Local nAt		:= oGetAr:nAt

SFT->(dbSetOrder(1))

aAdd(aPos,aScan(aHArma,{|x| Alltrim(x[2])=="CD8_ITEM"}))
aAdd(aPos,aScan(aHArma,{|x| Alltrim(x[2])=="CD8_COD"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHArma)+1])

	If M926Obrig(aObrigat,aHArma,aCols[nAt],2)
		lObrigat := .T.
	Endif

Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHArma)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacoes do ok da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M926Obrig(aObrigat,aHArma,aCols[nX],2)
				lObrigat := .T.
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence a nota fiscal que esta sendo complementada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nX][aPos[1]]+aCols[nX][aPos[2]]))
			lItem := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence ao grupo de medicamentos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(aScan(aArma,{|x| x[1] == xFilial("CD8") .And. ;
			x[2] == cDoc .And. ;
			x[3] == cSerie .And.;
			x[4] == cClieFor .And. ;
			x[5] == cLoja .And.;
			x[6] == cEntSai .And.;
			x[7] == aCols[nX][aPos[1]] .And.;
			x[8] == aCols[nX][aPos[2]]}) > 0)
			lGrupo := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido nao esta em duplicidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aItens,{|x| x == aCols[nX][aPos[1]]}) > 0
			lDuplica := .T.
		Endif
		aAdd(aItens,aCols[nX][aPos[1]])

	Endif

Next

If lObrigat
	Help("  ",1,"A926ArmObr")
	lRet := .F.
Endif

If lDuplica
	Help("  ",1,"A926Dupl")
	lRet := .F.
Endif

If lItem
	Help("  ",1,"A926Itens")
	lRet := .F.
Endif

If lGrupo
	Help("  ",1,"A926Grupo")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Comb  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de combustiveis              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da get dados de combustiveis                ³±±
±±³          ³ ExpC2 = Numero do documento                                ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Especie                                            ³±±
±±³          ³ ExpC5 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC6 = Loja                                               ³±±
±±³          ³ ExpC7 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC8 = Indica se o documento e de devol/beneficiamento    ³±±
±±³          ³ ExpC9 = Array com os campos obrigatorios das tabelas       ³±±
±±³          ³ ExpCA = Indica se e validacao do ok da janela              ³±±
±±³          ³ ExpCB = Array com os itens do grupo de combustiveis        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Comb(oGetComb,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,lTudoOk,aCombust)
Local 	aCols		:= oGetComb:aCols
Local 	aItens 		:= {}
Local 	aPos		:= {}
Local 	lRet		:= .T.
Local 	lDuplica	:= .F.
Local 	lItem		:= .F.
Local 	lObrigat	:= .F.
Local 	lGrupo 		:= .F.
Local 	nX	   		:= 0
Local 	nAt			:= oGetComb:nAt
Local	nTo			:=	0
Local	nIni		:=	0
Local 	cCampoRet	:=	""

Default	lTudoOk	:=	.F.

nTo	:=	Iif(lTudoOk,Len(aCols),nAt)
nIni:=	Iif(lTudoOk,1,nAt)

SFT->(dbSetOrder(1))

aAdd(aPos,aScan(aHComb,{|x| Alltrim(x[2])=="CD6_ITEM"}))
aAdd(aPos,aScan(aHComb,{|x| Alltrim(x[2])=="CD6_COD"}))

For nX := nIni to nTo

	If !(aCols[nX][Len(aHComb)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lObrigat := M926Obrig(aObrigat,aHComb,aCols[nX],3,@cCampoRet)
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence a nota fiscal que esta sendo complementada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nX][aPos[1]]+aCols[nX][aPos[2]]))
			lItem := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence ao grupo de combustiveis³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(aScan(aCombust,{|x| x[1] == xFilial("CD6") .And. ;
			x[2] == cDoc .And. ;
			x[3] == cSerie .And.;
			x[4] == cClieFor .And. ;
			x[5] == cLoja .And.;
			x[6] == cEntSai .And.;
			x[7] == aCols[nX][aPos[1]] .And.;
			x[8] == aCols[nX][aPos[2]]}) > 0)
			lGrupo := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido nao esta em duplicidade. Chave: Item+Tanque³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aItens,{|x| x == aCols[nX][aPos[1]]+aCols[nX][15]}) > 0
			lDuplica := .T.
		Endif
		aAdd(aItens,aCols[nX][aPos[1]]+aCols[nX][15])

	Endif

Next

If lObrigat
	Help("  ",1,"A926OBRCO",,cCampoRet,3,1)
	lRet := .F.
Endif

If lDuplica
	Help("  ",1,"A926DUPCOM",,"CD6_ITEM, CD6_TANQUE",3,1)
	lRet := .F.
Endif

If lItem
	Help("  ",1,"A926Itens")
	lRet := .F.
Endif

If lGrupo
	Help("  ",1,"A926Grupo")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Veic  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de veiculos automotores      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da get dados de veiculos                    ³±±
±±³          ³ ExpC2 = Numero do documento                                ³±±
±±³          ³ ExpC3 = Serie                                              ³±±
±±³          ³ ExpC4 = Especie                                            ³±±
±±³          ³ ExpC5 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC6 = Loja                                               ³±±
±±³          ³ ExpC7 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC8 = Indica se o documento e de devol/beneficiamento    ³±±
±±³          ³ ExpC9 = Array com os campos obrigatorios das tabelas       ³±±
±±³          ³ ExpCA = Indica se e validacao do ok da janela              ³±±
±±³          ³ ExpCB = Array com os itens do grupo de veiculos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Veic(oGetVeic,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,lFinal,aVeic)

Local aCols		:= oGetVeic:aCols
Local aItens	:= {}
Local aPos		:= {}

Local lRet		:= .T.
Local lDuplica	:= .F.
Local lItem		:= .F.
Local lObrigat	:= .F.
Local lGrupo 	:= .F.

Local nX		:= 0
Local nAt		:= oGetVeic:nAt

SFT->(dbSetOrder(1))

aAdd(aPos,aScan(aHVeic,{|x| Alltrim(x[2])=="CD9_ITEM"}))
aAdd(aPos,aScan(aHVeic,{|x| Alltrim(x[2])=="CD9_COD"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHVeic)+1])

	If M926Obrig(aObrigat,aHVeic,aCols[nAt],9)
		lObrigat := .T.
	Endif

Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHVeic)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacoes do ok da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M926Obrig(aObrigat,aHVeic,aCols[nX],9)
				lObrigat := .T.
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence a nota fiscal que esta sendo complementada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nX][aPos[1]]+aCols[nX][aPos[2]]))
			lItem := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence ao grupo de medicamentos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(aScan(aVeic,{|x| x[1] == xFilial("CD9") .And. ;
			x[2] == cDoc .And. ;
			x[3] == cSerie .And.;
			x[4] == cClieFor .And. ;
			x[5] == cLoja .And.;
			x[6] == cEntSai .And.;
			x[7] == aCols[nX][aPos[1]] .And.;
			x[8] == aCols[nX][aPos[2]]}) > 0)
			lGrupo := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido nao esta em duplicidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aItens,{|x| x == aCols[nX][aPos[1]]}) > 0
			lDuplica := .T.
		Endif
		aAdd(aItens,aCols[nX][aPos[1]])

	Endif

Next

If lObrigat
	Help("  ",1,"A926VeicObr")
	lRet := .F.
Endif

If lDuplica
	Help("  ",1,"A926Dupl")
	lRet := .F.
Endif

If lItem
	Help("  ",1,"A926Itens")
	lRet := .F.
Endif

If lGrupo
	Help("  ",1,"A926Grupo")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Proc  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes dos processos referenciados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Proc(oGetProc,aObrigat,lFinal)

Local aCols		:= oGetProc:aCols
Local aPos		:= {}
Local aProcess	:= {}

Local lRet		:= .T.
Local lRepete	:= .F.
Local lObrigat	:= .F.

Local nX		:= 0
Local nAt		:= oGetProc:nAt

aAdd(aPos,aScan(aHProc,{|x| Alltrim(x[2])=="CDG_ITEM"  }))
aAdd(aPos,aScan(aHProc,{|x| Alltrim(x[2])=="CDG_PROCES"}))
aAdd(aPos,aScan(aHProc,{|x| Alltrim(x[2])=="CDG_TPPROC"}))
aAdd(aPos,aScan(aHProc,{|x| Alltrim(x[2])=="CDG_ITPROC"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHProc)+1])
	If M926Obrig(aObrigat,aHProc,aCols[nAt],10)
		lObrigat := .T.
	Endif
Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHProc)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			lObrigat := M926Obrig(aObrigat,aHProc,aCols[nX],10)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o processo + informacao complementar nao foi digitado em outra linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//		If aScan(aProcess,{|x| x[1] == aCols[nX][aPos[1]] .And. x[2] == aCols[nX][aPos[2]] .And. x[3] == aCols[nX][aPos[3]]}) > 0
		If aScan(aProcess,{|x| x[1] == aCols[nX][aPos[1]] .And. x[2] == aCols[nX][aPos[2]] .And. x[3] == aCols[nX][aPos[3]] .And. x[4] == aCols[nX][aPos[4]]}) > 0
			lRepete := .T.
		Endif
		aAdd(aProcess,{aCols[nX][aPos[1]],aCols[nX][aPos[2]],aCols[nX][aPos[3]],aCols[nX][aPos[4]]})

	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se o processo + informacao complementar nao foi digitado em outra linha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRepete
	Help("  ",1,"A926Proc")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926ProcObr")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Infc  ³ Autor ³ João F. Cozer F.      ³ Data ³ 28/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes dos processos referenciados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Infc(oGetInfc,aObrigat,lFinal)

Local aCols		:= oGetInfc:aCols
Local aPos		:= {}
Local aProcess	:= {}

Local lRet		:= .T.
Local lRepete	:= .F.
Local lObrigat	:= .F.

Local nX		:= 0
Local nAt		:= oGetInfc:nAt

aAdd(aPos,aScan(aHInfc,{|x| Alltrim(x[2])=="CDT_IFCOMP"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHInfc)+1])
	If M926Obrig(aObrigat,aHInfc,aCols[nAt],15)
		lObrigat := .T.
	Endif
Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHInfc)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			lObrigat := M926Obrig(aObrigat,aHInfc,aCols[nX],15)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o processo + informacao complementar nao foi digitado em outra linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aProcess,{|x| x[1] == aCols[nX][aPos[1]]}) > 0
			lRepete := .T.
		Endif
		aAdd(aProcess,{aCols[nX][aPos[1]]})

	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se a informacao complementar nao foi digitado em outra linha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRepete
	Help("  ",1,"A926Infc")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926InfcObr")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Guia  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes das guias de recolhimento referenciada³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Guia(oGetGuia,aObrigat,lFinal)

Local aCols		:= oGetGuia:aCols
Local aPos		:= {}
Local aGuias  	:= {}

Local lRet		:= .T.
Local lRepete	:= .F.
Local lObrigat	:= .F.
Local lGuiaUFOk := .T.

Local nX		:= 0
Local nAt		:= oGetGuia:nAt

aAdd(aPos,aScan(aHGuia,{|x| Alltrim(x[2])=="CDC_GUIA"}))
aAdd(aPos,aScan(aHGuia,{|x| Alltrim(x[2])=="CDC_UF"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHGuia)+1])
	If M926Obrig(aObrigat,aHGuia,aCols[nAt],11)
		lObrigat := .T.
	Endif
Endif

dbSelectArea("SF6")
SF6->(DbSetOrder(1))

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHGuia)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
		   	lObrigat := M926Obrig(aObrigat,aHGuia,aCols[nX],11)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a guia + UF nao foi lancada em mais de uma linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aGuias,{|x| x[1] == aCols[nX][aPos[1]] .And. x[2] == aCols[nX][aPos[2]]}) > 0
			lRepete := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a guia + UF existe na SF6                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(SF6->(dbSeek(xFilial("SF6")+aCols[nX][aPos[2]]+aCols[nX][aPos[1]])))
			lGuiaUFOk := .F.
		EndIf

		aAdd(aGuias,{aCols[nX][aPos[1]],aCols[nX][aPos[2]]})
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa  se a guia + UF nao foi lancada em mais de uma linha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRepete
	Help("  ",1,"A926Guia")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926GuiaObr")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se alguma das guias não está cadastrada ou se n pertence a UF digitada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lGuiaUFOk
   	Help("  " ,1,"A926GUIAUF")
  	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Doc   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes das guias de documentos referenciados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Doc(oGetDoc,aObrigat,lFinal,aDocRef,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF)

Local aCols		:= oGetDoc:aCols
Local aPos		:= {}
Local aDocs		:= {}

Local lRet		:= .T.
Local lRepete	:= .F.
Local lObrigat	:= .F.
Local lDoc		:= .F.
Local lRef 		:= .T.
Local lProDoc	:= .T.

Local nX		:= 0
Local nI		:= 0
Local nAt		:= oGetDoc:nAt

aAdd(aPos,aScan(aHDoc,{|x| Alltrim(x[2])=="CDD_DOCREF"}))
aAdd(aPos,aScan(aHDoc,{|x| Alltrim(x[2])=="CDD_SERREF"}))
aAdd(aPos,aScan(aHDoc,{|x| Alltrim(x[2])=="CDD_PARREF"}))
aAdd(aPos,aScan(aHDoc,{|x| Alltrim(x[2])=="CDD_LOJREF"}))
If CDD->(ColumnPos("CDD_CHVNFE"))>0
	aAdd(aPos,aScan(aHDoc,{|x| Alltrim(x[2])=="CDD_CHVNFE"}))
Endif
If CDD->(FieldPos("CDD_MEANRF")) > 0
	aAdd(aPos,aScan(aHDoc,{|x| Alltrim(x[2])=="CDD_MEANRF"}))
Endif
If CDD->(FieldPos("CDD_MODREF")) > 0
	aAdd(aPos,aScan(aHDoc,{|x| Alltrim(x[2])=="CDD_MODREF"}))
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHDoc)+1])
	If M926Obrig(aObrigat,aHDoc,aCols[nAt],12)
		lObrigat := .T.
	Endif
Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHDoc)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			lObrigat := M926Obrig(aObrigat,aHDoc,aCols[nX],12)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o documento nao foi lancado em mais de uma linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aDocs,{|x| x[1] == aCols[nX][aPos[1]] .And. x[2] == aCols[nX][aPos[2]];
			.And. x[3] == aCols[nX][aPos[3]] .And. x[4] == aCols[nX][aPos[4]]}) > 0
			lRepete := .T.
		Endif
		aAdd(aDocs,{aCols[nX][aPos[1]],aCols[nX][aPos[2]],aCols[nX][aPos[3]],aCols[nX][aPos[4]]})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o documento selecionado foi lancado como NFORI e SERIEORI³
		//³para nao permitir que sejam relacionados documentos divergentes.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(aScan(aDocRef,{|x|	x[1] == aCols[nX][aPos[1]] .And. ;
								x[2] == aCols[nX][aPos[2]] .And. ;
								x[3] == aCols[nX][aPos[3]] .And. ;
								x[4] == aCols[nX][aPos[4]]}) > 0)
			
			lDoc := .T.
		Endif

	Endif
Next

If lCompDoc // Complementar nota sem origem preenchida na nota
	lDoc := .F.
	For nI := 1 to len(aCols)
		If !Empty(aCols[nI][1]) .or. !Empty(aCols[nI][2])			
			
			lProDoc := cEntSai+cDoc+cSerie+cClieFor+cLoja <> iIF(aCols[nI][6]=="1","E","S")+aCols[nI][1]+aCols[nI][2]+aCols[nI][3]+aCols[nI][4]
			
			If lProDoc
				If aCols[nI][6] == '1'
					lRef := SF1->(MsSeek(xFilial("SF1")+aCols[nI][1]+aCols[nI][2]+aCols[nI][3]+aCols[nI][4]))
				Else
					lRef := SF2->(MsSeek(xFilial("SF2")+aCols[nI][1]+aCols[nI][2]+aCols[nI][3]+aCols[nI][4]))				
				Endif
			Endif
		Endif
	next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se o documento nao foi lancado em mais de uma linha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRepete
	Help("  ",1,"A926Doc")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926DocObr")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa que o documento selecionado nao esta relacionado ao documento original³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDoc
	Help("  ",1,"A926DocRef")
	lRet := .F.
Endif

If !lRef
	Help("  ",1,"")
	Help(NIL, NIL, STR0098,; //"Documento referenciado não existe"
	 NIL, STR0098, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0099}) //"Documento referenciado não existe para tipo de movimento."
	lRet := .F.
Endif

If !lProDoc	
	Help(NIL, NIL, STR0100,; //"Referencia igual a complementada"
	 NIL, STR0101,; //"Documento referenciado não pode ser o mesmo documento complementado"
	  1, 0, NIL, NIL, NIL, NIL, NIL, {STR0102}) //"Não deve ser informado como documento referenciado o mesmo documento que esta sendo complementado"
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Cup   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes das guias de cupons referenciados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Cup(oGetCup,aObrigat,lFinal,aNfCupom)

Local aCols		:= oGetCup:aCols
Local aPos		:= {}
Local aDocs		:= {}

Local lRet		:= .T.
Local lRepete	:= .F.
Local lObrigat	:= .F.
Local lDoc		:= .F.

Local nX		:= 0
Local nAt		:= oGetCup:nAt

aAdd(aPos,aScan(aHCp,{|x| Alltrim(x[2])=="CDE_CPREF"}))
aAdd(aPos,aScan(aHCp,{|x| Alltrim(x[2])=="CDE_SERREF"}))
aAdd(aPos,aScan(aHCp,{|x| Alltrim(x[2])=="CDE_PARREF"}))
aAdd(aPos,aScan(aHCp,{|x| Alltrim(x[2])=="CDE_LOJREF"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHCp)+1])
	If M926Obrig(aObrigat,aHCp,aCols[nAt],13)
		lObrigat := .T.
	Endif
Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHCp)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			lObrigat := M926Obrig(aObrigat,aHCp,aCols[nX],13)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o cupom nao foi lancado em mais de uma linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aDocs,{|x| x[1] == aCols[nX][aPos[1]] .And. x[2] == aCols[nX][aPos[2]];
			.And. x[3] == aCols[nX][aPos[3]] .And. x[4] == aCols[nX][aPos[4]]}) > 0
			lRepete := .T.
		Endif
		aAdd(aDocs,{aCols[nX][aPos[1]],aCols[nX][aPos[2]],aCols[nX][aPos[3]],aCols[nX][aPos[4]]})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o documento selecionado e o cupom fiscal da NF Cupom³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(aScan(aNfCupom,{|x| x[1] == aCols[nX][aPos[1]] .And.;
			x[2] == aCols[nX][aPos[2]] .And.;
			x[3] == aCols[nX][aPos[3]] .And.;
			x[4] == aCols[nX][aPos[4]]}) > 0)
			lDoc := .T.
		Endif

	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se o cupom nao foi lancado em mais de uma linha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRepete
	Help("  ",1,"A926Cup")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926CupObr")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se o documento selecionado e o cupom fiscal da NF Cupom.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDoc
	Help("  ",1,"A926CupRel")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Loc   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes das guias de locais referenciados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Loc(oGetLoc,aObrigat,lFinal,aLocal)

Local aCols		:= oGetLoc:aCols
Local aPos		:= {}

Local lRet		:= .T.
Local lObrigat	:= .F.
Local lLocal	:= .F.

Local nX		:= 0
Local nAt		:= oGetLoc:nAt

aAdd(aPos,aScan(aHLoc,{|x| Alltrim(x[2])=="CDF_ENTREG"}))
aAdd(aPos,aScan(aHLoc,{|x| Alltrim(x[2])=="CDF_LOJENT"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHLoc)+1])
	If M926Obrig(aObrigat,aHLoc,aCols[nAt],14)
		lObrigat := .T.
	Endif
Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHLoc)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			lObrigat := M926Obrig(aObrigat,aHLoc,aCols[nX],14)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o cliente de entrega selecionado é o do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(aScan(aLocal,{|x| x[1] == aCols[nX][aPos[1]] .And.;
			x[2] == aCols[nX][aPos[2]]}) > 0)
			lLocal := .T.
		Endif

	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926LocObr")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa que o cliente selecionado nao e o cliente de entrega gravado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLocal
	Help("  ",1,"A926NLocal")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SpedClas ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna apenas as classes de consumo do modelo de NF       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F. dependendo da execucao do filtro                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SpedClas(cCampo)

Local cTipo		:= ""
Local cModelo	:= ""
Local cVar		:= ""
Local cCampo	:= Iif(cCampo == NIL, "", cCampo)
Local lRet		:= .T.

If aNFSped <> Nil .And. Len(aNFSped) > 0 .And. aNFSped[3] <> Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o modelo de nota selecionado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cModelo := aModNot(aNFSped[3])

	lEnergia := ((Alltrim(cModelo)$"01/55") .And. SubStr(Alltrim(aNFSped[08]),1,3)$"525/625")

	If (cModelo $ "06|66" .Or. lEnergia) .And. cCampo == "FU_CLCOSEF" //Energia Eletrica e irá gerar a SEF.
		cTipo := "5"
	ElseIf cModelo $ "06|66" .Or. lEnergia
		cTipo := "4"
	ElseIf cModelo == "21"
		cTipo := "3"
	ElseIf cModelo == "22"
		cTipo := "3"
	ElseIf cModelo == "28"
		cTipo := "2"
	ElseIf cModelo == "29"
		cTipo := "1"
	Endif

	cVar := " {|| CC5->CC5_TIPO == cTipo .And. Iif(!Empty(CC5_DTFINA),CC5_DTFINA >= dDataBase,.T.)}"
	lRet := Eval(&(cVar))

Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SpedItem ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna apenas os itens da NF que devem gerar o complemento³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F. dependendo da execucao do filtro                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SpedItem()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicoes do array aNFSped                            ³
//³01 = numero do documento fiscal                       ³
//³02 = serie                                            ³
//³03 = epecie                                           ³
//³04 = cliente/fornecedor                               ³
//³05 = loja                                             ³
//³06 = movimento de Entrada ou Saida                    ³
//³07 = tipo (devolucao/beneficiamento)                  ³
//³08 = array com os complementos a serem gerados        ³
//³09 = array com os itens de medicamentos               ³
//³10 = array com os itens de armas de fogo              ³
//³11 = array com os itens de veiculos                   ³
//³12 = array com os itens de combustiveis               ³
//³13 = array com os itens de gas                        ³
//³14 = array com os itens de comunicacao/telecomunicacao³
//³15 = array com os itens de energia eletrica           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCompara	:= ""
Local cTabela	:= ""

Local lRet		:= .T.

Local nArray	:= 0

If aCplSped <> Nil .And. Len(aCplSped) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro para as notas fiscais de armas       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCplSped[01][02][03]
		nArray 	:= 3
		cTabela := aCplSped[01][02][02]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro para as notas fiscais de combustiveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCplSped[01][03][03]
		nArray 	:= 5
		cTabela := aCplSped[01][03][02]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro para as notas fiscais de comunicacao, energia eletrica e gas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If aCplSped[01][04][03] .Or. aCplSped[01][05][03] .Or. aCplSped[01][06][03]
    	cChave := xFilial("SFT")+aNFSped[06]+aNFSped[02]+aNFSped[01]+aNFSped[04]+aNFSped[05]
		cCompara := FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro para as notas fiscais de medicamentos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCplSped[01][08][03]
		nArray := 2
		cTabela := aCplSped[01][08][02]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro para as notas fiscais de veiculos    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCplSped[01][09][03]
		nArray := 4
		cTabela := aCplSped[01][09][02]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro para as notas fiscais de Importacao	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCplSped[01][07][03]
		cChave := xFilial("SFT")+aNFSped[06]+aNFSped[02]+aNFSped[01]+aNFSped[04]+aNFSped[05]
		cCompara := FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro para as notas fiscais com rastreabilidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCplSped[01][23][03]
		nArray := 13
		cTabela := aCplSped[01][23][02]
	Endif

	If nArray > 0
		lRet := (aScan(aCplSped[nArray],{|x| x[1] == xFilial(cTabela) .And. ;
			x[2] == SFT->FT_NFISCAL .And. ;
			x[3] == SFT->FT_SERIE .And.;
			x[4] == SFT->FT_CLIEFOR .And. ;
			x[5] == SFT->FT_LOJA .And.;
			x[6] == SFT->FT_TIPOMOV .And.;
			x[7] == SFT->FT_ITEM .And.;
			x[8] == SFT->FT_PRODUTO}) > 0)
	Else
	   	lRet := (cChave == cCompara)
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M926Log  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o log dos complementos trazidos automaticamente pelo ³±±
±±³          ³ sistema para futura auditoria.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Complementos sugeridos pelo sistema                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Log(aSugerido)

Local nX := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codigos dos complementos:     ³
//³1=Água;                       ³
//³2=Armas;                      ³
//³3=Combustíveis;               ³
//³4=Comunicação/Telecomunicação;³
//³5=Energia;                    ³
//³6=Gás;                        ³
//³7=Importação;                 ³
//³8=Medicamentos;               ³
//³9=Veiculos                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CDB->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicoes do array aSugerido:³
//³1 = (cAliasSFT)->FT_NFISCAL ³
//³2 = (cAliasSFT)->FT_SERIE   ³
//³3 = (cAliasSFT)->FT_ESPECIE ³
//³4 = (cAliasSFT)->FT_CLIEFOR ³
//³5 = (cAliasSFT)->FT_LOJA    ³
//³6 = (cAliasSFT)->FT_TIPOMOV ³
//³7 = (cAliasSFT)->FT_ITEM    ³
//³8 = (cAliasSFT)->FT_PRODUTO ³
//³9 = cComp                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o complemento sugerido pelo sistema nao estiver na tabela de logs,       ³
//³grava nova ocorrencia. Este log sera utilizado para futuras auditorias, caso³
//³o usuario exclua os complementos dos produtos identificados pelo sistema.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aSugerido)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava o log apenas dos complementos por item.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aSugerido[nX][9] $ "2345689"
		If !(CDB->(dbSeek(xFilial("CDB")+aSugerido[nX][6]+aSugerido[nX][1]+aSugerido[nX][2]+aSugerido[nX][4]+aSugerido[nX][5]+aSugerido[nX][7]+aSugerido[nX][8]+aSugerido[nX][9])))
			RecLock("CDB",.T.)
			CDB->CDB_FILIAL	:= xFilial("CDB")
			CDB->CDB_TPMOV	:= aSugerido[nX][6]
			CDB->CDB_DOC	:= aSugerido[nX][1]
			SerieNfId("CDB",1,"CDB_SERIE",,,,aSugerido[nX][2])
			CDB->CDB_ESPEC	:= aSugerido[nX][3]
			CDB->CDB_CLIFOR	:= aSugerido[nX][4]
			CDB->CDB_LOJA	:= aSugerido[nX][5]
			CDB->CDB_ITEM	:= aSugerido[nX][7]
			CDB->CDB_COD	:= aSugerido[nX][8]
			CDB->CDB_COMPL	:= aSugerido[nX][9]
			MsUnLock()
			FkCommit()
		Endif
	Endif
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Obrig ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existem campos obrigatorios nao preenchidos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os campos obrigatorios                   ³±±
±±³          ³ ExpA2 = Array com os campos da get dados                   ³±±
±±³          ³ ExpA3 = Array com o conteudo do campo                      ³±±
±±³          ³ ExpN4 = Numero que indica o complemento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. para existencia de campos obrigatorios em branco       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Obrig(aObrigat,aHeader,aCols,nComp,cCampoRet)

Local lRet	:= .F.
Local nX	:= 0
Local nPos	:= 0

Local xConteudo
Local lObrigCmp := .F.

Default	cCampoRet := ""

For nX := 1 to Len(aObrigat[nComp])
	lObrigCmp := .F.
	nPos := aScan(aHeader,{|x| x[2] == aObrigat[nComp][nX][1]})
	If nPos > 0
		xConteudo := aCols[nPos]

		If aObrigat[nComp][nX][2] $ "C|D"
			If Empty(xConteudo)
				lRet := .T.
				lObrigCmp := .T.
			Endif
		ElseIf aObrigat[nComp][nX][2] == "N"
			If xConteudo == 0
				lRet := .T.
				lObrigCmp := .T.
			Endif
		Endif

		If aObrigat[nComp][nX][1] == "CDD_SERREF" .and. lRet
			aCols[2] := "   "
			lRet := .F.
		EndIf

	Endif

	If lObrigCmp .And. !AllTrim(aObrigat[nComp][nX][1])$cCampoRet
		cCampoRet += Iif(Empty(cCampoRet),"",", ")+AllTrim(aObrigat[nComp][nX][1])
	EndIf
Next

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926DelDup³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existem campos duplicados entre os deletados e ³±±
±±³          ³ os nao deletados.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os campos do aCols                       ³±±
±±³          ³ ExpA2 = Array com os campos do aHeader                     ³±±
±±³          ³ ExpN3 = Posicao no aCols do campo de item do documento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aDeleta = array com os itens deletados duplicados que devem³±±
±±³          ³ ser desconsiderados na gravacao do complemento.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926DelDup(aCols,aHeader,nPosItem)

Local aDeleta	:= {}
Local aDuplic	:= aCols

Local nX		:= 0
Local nY		:= 0

For nX := 1 to Len(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se nao existe um item deletado e um item nao deletado com mesmas caracteristicas no aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCols[nX][Len(aHeader)+1]
		For nY := 1 to Len(aDuplic)
			If aDuplic[nY][nPosItem] == aCols[nX][nPosItem] .And. !aDuplic[nY][Len(aHeader)+1]
				aAdd(aDeleta,aCols[nX][nPosItem])
				Exit
			Endif
		Next
	Endif

Next

Return aDeleta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Exist ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o aCols foi preenchido ou se apenas foi criado ³±±
±±³          ³ em branco                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os campos do aCols                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Indicacao da existencia de campos no aCols                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M926Exist(aCols)

Local lExiste	:= .F.

Local nX		:= 0
Local nY		:= 0

For nX := 1 to Len(aCols)

	If lExiste
		Exit
	Endif

	For nY := 1 to Len(aCols[nX])

		If ValType(aCols[nX][nY]) == "C"
			If !Empty(aCols[nX][nY])
				lExiste := .T.
				Exit
			Endif
		Endif

		If ValType(aCols[nX][nY]) == "N"
			If aCols[nX][nY] <> 0
				lExiste := .T.
				Exit
			Endif
		Endif

	Next

Next

Return lExiste

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SpedDoc  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna apenas os documentos que existam nos itens da      ³±±
±±³          ³ nota fiscal que esta sendo complementada                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Tipo de filtro (1-Entrada,2-Saida,3-Cupom)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F. dependendo da execucao do filtro                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SpedDoc(nFiltro)

Local lRet	:= .F.

Local nPos 	:= 0

If aDocRef <> Nil .And. Len(aDocRef) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro na consulta padrao de entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFiltro == 1
		nPos := aScan(aDocRef,{|x| x[1] == SF1->F1_DOC .And. x[2] == SF1->F1_SERIE .And. x[3] == SF1->F1_FORNECE .And. x[4] == SF1->F1_LOJA})
	ElseIf nFiltro == 2
		nPos := aScan(aDocRef,{|x| x[1] == SF2->F2_DOC .And. x[2] == SF2->F2_SERIE .And. x[3] == SF2->F2_CLIENTE .And. x[4] == SF2->F2_LOJA})
	Endif

	lRet := nPos > 0

	If nFiltro == 2 .AND. nPos == 0 .and. lCompDoc //Quando nota não possuir nota de origem não validar consulta padrão. validação sera do formulario
		lRet := .T.
	Endif	

Endif

If aNfCupom <> Nil .And. Len(aNfCupom) > 0

	If nFiltro == 3

		nPos := aScan(aNfCupom,{|x| x[1] == SF2->F2_DOC .And. x[2] == SF2->F2_SERIE .And. x[3] == SF2->F2_CLIENTE .And. x[4] == SF2->F2_LOJA})

   		lRet := nPos > 0 .And. !Empty(SF2->F2_PDV)

	Endif

Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SpedDoc  ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui os complementos por NF e por item quando o SF3 ou   ³±±
±±³          ³ o SFT forem excluidos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F. dependendo da execucao do filtro                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926DlSped(nTipo,cDoc,cSerie,cClieFor,cLoja,cTpCfo,cItem,cProd)

Local cChave	:= ""
Local cTpMov	:= ""

Local lTabCDT
Local lCompExp
Local lAnfavea
Local lCompCD0
Local lCompF0A := AliasIndic("F0A")
Local lCompCF8 := AliasIndic("CF8") .And. CF8->(ColumnPos("CF8_DOC")) >0 .And. CF8->(ColumnPos("CF8_SERIE")) >0
Local nTamDoc   := TamSX3("CD7_DOC")[1]

Default lUsaSped := cPaisLoc == "BRA"

lTabCDT		:= lUsaSped
lCompExp	:= lUsaSped
lAnfavea	:= lUsaSped
lCompCD0	:= lUsaSped

If lUsaSped
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui os complementos por documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
		If nTipo == 1
			If Left(cTpCfo,1) $ "123"
				cTpMov := "E"
			Else
				cTpMov := "S"
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³Importacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			cChave := cDoc+cSerie+cClieFor+cLoja
			CD5->(dbSetOrder(1))
			CD5->(dbSeek(xFilial("CD5")+cDoc+cSerie+cClieFor+cLoja))
			Do While ! CD5->(Eof()) .And. xFilial("CD5")+cChave == xFilial("CD5")+CD5->CD5_DOC+CD5->CD5_SERIE+CD5->CD5_FORNEC+CD5->CD5_LOJA
				RecLock("CD5",.F.)
				CD5->(dbDelete())
				MsUnLock()
				CD5->(fKCommit())
				CD5->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Guias de recolhimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChave := cTpMov+cDoc+cSerie+cClieFor+cLoja
			CDC->(dbSetOrder(1))
			CDC->(dbSeek(xFilial("CDC")+cTpMov+cDoc+cSerie+cClieFor+cLoja))
			Do While ! CDC->(Eof()) .And. xFilial("CDC")+cChave == xFilial("CDC")+CDC->CDC_TPMOV+CDC->CDC_DOC+CDC->CDC_SERIE+CDC->CDC_CLIFOR+CDC->CDC_LOJA
				RecLock("CDC",.F.)
				CDC->(dbDelete())
				MsUnLock()
				CDC->(fKCommit())
				CDC->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Documentos referenciados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CDD->(dbSetOrder(1))
			CDD->(dbSeek(xFilial("CDD")+cTpMov+cDoc+cSerie+cClieFor+cLoja))
			Do While ! CDD->(Eof()) .And. xFilial("CDD")+cChave == xFilial("CDD")+CDD->CDD_TPMOV+CDD->CDD_DOC+CDD->CDD_SERIE+CDD->CDD_CLIFOR+CDD->CDD_LOJA
				RecLock("CDD",.F.)
				CDD->(dbDelete())
				MsUnLock()
				CDD->(fKCommit())
				CDD->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cupons referenciados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CDE->(dbSetOrder(1))
			CDE->(dbSeek(xFilial("CDE")+cTpMov+cDoc+cSerie+cClieFor+cLoja))
			Do While ! CDE->(Eof()) .And. xFilial("CDE")+cChave == xFilial("CDE")+CDE->CDE_TPMOV+CDE->CDE_DOC+CDE->CDE_SERIE+CDE->CDE_CLIFOR+CDE->CDE_LOJA
				RecLock("CDE",.F.)
				CDE->(dbDelete())
				MsUnLock()
				CDE->(fKCommit())
				CDE->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Local de entrega     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CDF->(dbSetOrder(1))
			CDF->(dbSeek(xFilial("CDF")+cTpMov+cDoc+cSerie+cClieFor+cLoja))
			Do While ! CDF->(Eof()) .And. xFilial("CDF")+cChave == xFilial("CDF")+CDF->CDF_TPMOV+CDF->CDF_DOC+CDF->CDF_SERIE+CDF->CDF_CLIFOR+CDF->CDF_LOJA
				RecLock("CDF",.F.)
				CDF->(dbDelete())
				MsUnLock()
				CDF->(fKCommit())
				CDF->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processos referenciados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CDG->(dbSetOrder(1))
			CDG->(dbSeek(xFilial("CDG")+cTpMov+cDoc+cSerie+cClieFor+cLoja))
			Do While ! CDG->(Eof()) .And. xFilial("CDG")+cChave == xFilial("CDG")+CDG->CDG_TPMOV+CDG->CDG_DOC+CDG->CDG_SERIE+CDG->CDG_CLIFOR+CDG->CDG_LOJA
				RecLock("CDG",.F.)
				CDG->(dbDelete())
				MsUnLock()
				CDG->(fKCommit())
				CDG->(dbSkip())
			Enddo
			If lTabCDT
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Informações complementares
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CDT->(dbSetOrder(1))
				CDT->(dbSeek(xFilial("CDT")+cTpMov+cDoc+cSerie+cClieFor+cLoja))
				Do While ! CDT->(Eof()) .And. xFilial("CDT")+cChave == xFilial("CDT")+CDT->CDT_TPMOV+CDT->CDT_DOC+CDT->CDT_SERIE+CDT->CDT_CLIFOR+CDT->CDT_LOJA
					RecLock("CDT",.F.)
					CDT->(dbDelete())
					MsUnLock()
					CDT->(fKCommit())
					CDT->(dbSkip())
				Enddo
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agua canalizada         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChave := cTpMov+cSerie+cDoc+cClieFor+cLoja
			CD4->(dbSetOrder(1))
			CD4->(dbSeek(xFilial("CD4")+cTpMov+cSerie+cDoc+cClieFor+cLoja))
			Do While ! CD4->(Eof()) .And. xFilial("CD4")+cChave == xFilial("CD4")+CD4->CD4_TPMOV+CD4->CD4_SERIE+CD4->CD4_DOC+CD4->CD4_CLIFOR+CD4->CD4_LOJA
				RecLock("CD4",.F.)
				CD4->(dbDelete())
				MsUnLock()
				CD4->(fKCommit())
				CD4->(dbSkip())
			Enddo
			If lCompExp
				//ÚÄÄÄÄÄÄÄÄÄÄ¿
				//³Exportacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÙ
				cChave := cDoc+cSerie+cClieFor+cLoja
				CDL->(dbSetOrder(1))
				CDL->(dbSeek(xFilial("CDL")+cDoc+cSerie+cClieFor+cLoja))
				Do While ! CDL->(Eof()) .And. xFilial("CDL")+cChave == xFilial("CDL")+CDL->CDL_DOC+CDL->CDL_SERIE+CDL->CDL_CLIENT+CDL->CDL_LOJA
					RecLock("CDL",.F.)
					CDL->(dbDelete())
					MsUnLock()
					CDL->(fKCommit())
					CDL->(dbSkip())
				Enddo
			EndIf
			If lAnfavea
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Anfavea Cab  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChave := cTpMov+cDoc+cSerie+cClieFor+cLoja
				CDR->(dbSetOrder(1))
				CDR->(dbSeek(xFilial("CDR")+cTpMov+cDoc+cSerie+cClieFor+cLoja))
				Do While ! CDR->(Eof()) .And. xFilial("CDR")+cChave == xFilial("CDR")+CDR->CDR_TPMOV+CDR->CDR_DOC+CDR->CDR_SERIE+CDR->CDR_CLIFOR+CDR->CDR_LOJA
					RecLock("CDR",.F.)
					CDR->(dbDelete())
					MsUnLock()
					CDR->(fKCommit())
					CDR->(dbSkip())
				Enddo
			EndIf
		Else
			cTpMov	:= cTpCfo
			cChave 	:= cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gas canalizado          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CD3->(dbSetOrder(1))
			CD3->(dbSeek(xFilial("CD3")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
			Do While ! CD3->(Eof()) .And. xFilial("CD3")+cChave == xFilial("CD3")+CD3->CD3_TPMOV+CD3->CD3_SERIE+CD3->CD3_DOC+CD3->CD3_CLIFOR+CD3->CD3_LOJA+CD3->CD3_ITEM+CD3->CD3_COD
				RecLock("CD3",.F.)
				CD3->(dbDelete())
				MsUnLock()
				CD3->(fKCommit())
				CD3->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Combustiveis            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CD6->(dbSetOrder(1))
			CD6->(dbSeek(xFilial("CD6")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
			Do While ! CD6->(Eof()) .And. xFilial("CD6")+cChave == xFilial("CD6")+CD6->CD6_TPMOV+CD6->CD6_SERIE+CD6->CD6_DOC+CD6->CD6_CLIFOR+CD6->CD6_LOJA+CD6->CD6_ITEM+CD6->CD6_COD
				RecLock("CD6",.F.)
				CD6->(dbDelete())
				MsUnLock()
				CD6->(fKCommit())
				CD6->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Medicamentos            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CD7->(dbSetOrder(1))
			CD7->(dbSeek(xFilial("CD7")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
			Do While ! CD7->(Eof()) .And. xFilial("CD7")+cChave == xFilial("CD7")+CD7->CD7_TPMOV+CD7->CD7_SERIE+CD7->CD7_DOC+CD7->CD7_CLIFOR+CD7->CD7_LOJA+CD7->CD7_ITEM+CD7->CD7_COD
				RecLock("CD7",.F.)
				CD7->(dbDelete())
				MsUnLock()
				CD7->(fKCommit())
				CD7->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armas de fogo           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CD8->(dbSetOrder(1))
			CD8->(dbSeek(xFilial("CD8")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
			Do While ! CD8->(Eof()) .And. xFilial("CD8")+cChave == xFilial("CD8")+CD8->CD8_TPMOV+CD8->CD8_SERIE+CD8->CD8_DOC+CD8->CD8_CLIFOR+CD8->CD8_LOJA+CD8->CD8_ITEM+CD8->CD8_COD
				RecLock("CD8",.F.)
				CD8->(dbDelete())
				MsUnLock()
				CD8->(fKCommit())
				CD8->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Veiculos                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CD9->(dbSetOrder(1))
			CD9->(dbSeek(xFilial("CD9")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
			Do While ! CD9->(Eof()) .And. xFilial("CD9")+cChave == xFilial("CD9")+CD9->CD9_TPMOV+CD9->CD9_SERIE+CD9->CD9_DOC+CD9->CD9_CLIFOR+CD9->CD9_LOJA+CD9->CD9_ITEM+CD9->CD9_COD
				RecLock("CD9",.F.)
				CD9->(dbDelete())
				MsUnLock()
				CD9->(fKCommit())
				CD9->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Energia eletrica        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SFU->(dbSetOrder(1))
			SFU->(dbSeek(xFilial("SFU")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
			Do While ! SFU->(Eof()) .And. xFilial("SFU")+cChave == xFilial("SFU")+SFU->FU_TIPOMOV+SFU->FU_SERIE+SFU->FU_DOC+SFU->FU_CLIFOR+SFU->FU_LOJA+SFU->FU_ITEM+SFU->FU_COD
				RecLock("SFU",.F.)
				SFU->(dbDelete())
				MsUnLock()
				SFU->(fKCommit())
				SFU->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Comunicacao / telecom   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SFX->(dbSetOrder(1))
			SFX->(dbSeek(xFilial("SFX")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
			Do While ! SFX->(Eof()) .And. xFilial("SFX")+cChave == xFilial("SFX")+SFX->FX_TIPOMOV+SFX->FX_SERIE+SFX->FX_DOC+SFX->FX_CLIFOR+SFX->FX_LOJA+SFX->FX_ITEM+SFX->FX_COD
				RecLock("SFX",.F.)
				SFX->(dbDelete())
				MsUnLock()
				SFX->(fKCommit())
				SFX->(dbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Anfavea Itens³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAnfavea
				CDS->(dbSetOrder(1))
				CDS->(dbSeek(xFilial("CDS")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
				Do While ! CDS->(Eof()) .And. xFilial("CDS")+cChave == xFilial("CDS")+CDS->CDS_TPMOV+CDS->CDS_SERIE+CDS->CDS_DOC+CDS->CDS_CLIFOR+CDS->CDS_LOJA+CDS->CDS_ITEM+CDS->CDS_PRODUT
					RecLock("CDS",.F.)
					CDS->(dbDelete())
					MsUnLock()
					CDS->(fKCommit())
					CDS->(dbSkip())
				Enddo
			Endif
			//Ressarcimento
			If lCompCD0
				CD0->(dbSetOrder(1))
				CD0->(dbSeek(xFilial("CD0")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
				Do While ! CD0->(Eof()) .And. xFilial("CD0")+cChave == xFilial("CD0")+CD0->CD0_TPMOV+CD0->CD0_SERIE+CD0->CD0_DOC+CD0->CD0_CLIFOR+CD0->CD0_LOJA+CD0->CD0_ITEM+CD0->CD0_COD
					RecLock("CD0",.F.)
					CD0->(dbDelete())
					MsUnLock()
					CD0->(fKCommit())
					CD0->(dbSkip())
				Enddo
			Endif
			//Rastreabilidade
			If lCompF0A
				F0A->(dbSetOrder(1))
				F0A->(dbSeek(xFilial("F0A")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
				Do While ! F0A->(Eof()) .And. xFilial("F0A")+cChave == xFilial("F0A")+F0A->F0A_TPMOV+F0A->F0A_SERIE+F0A->F0A_DOC+F0A->F0A_CLIFOR+F0A->F0A_LOJA+F0A->F0A_ITEM+F0A->F0A_COD
					RecLock("F0A",.F.)
					F0A->(dbDelete())
					MsUnLock()
					F0A->(fKCommit())
					F0A->(dbSkip())
				Enddo
			Endif
			If lCompCF8
				cChave := PADR(cDoc,nTamDoc)+cSerie+cClieFor+cLoja
				CF8->(dbSetOrder(3)) //CF8_FILIAL+CF8_DOC+CF8_SERIE+CF8_CLIFOR+CF8_LOJA
				CF8->(dbSeek(xFilial("CF8")+cChave))
				Do While ! CF8->(Eof()) .And. xFilial("CF8")+cChave == xFilial("CF8")+CF8->CF8_DOC+CF8->CF8_SERIE+CF8->CF8_CLIFOR+CF8->CF8_LOJA
					RecLock("CF8",.F.)
					CF8->(dbDelete())
					MsUnLock()
					CF8->(fKCommit())
					CF8->(dbSkip())
				Enddo
			Endif
		Endif
	End Transaction
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Exp   ³ Autor ³ Liber De Esteban      ³ Data ³ 30/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de exportacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±³Parametros³ Expl3 = Informa se valida somente a linha .F. ou todo o    ³±±
±±³            aCols (.T.)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Exp(oGetExp,aObrigat,lFinal)

Local aCols		  := oGetExp:aCols
Local aPos		  := {}
Local aDocExp	  := {}
Local aDocRep	  := {}

Local lRet		  := .T.
Local lObrigat    := .F.
Local lRepete     := .F.
//Local lDuplItem   := .F.
Local lAchouDoc   := .T.
Local lExpIndir   := .F.
Local lRepDocExIn := .F.

Local nX		  := 0
Local nPosIteCdl  := 0
Local nPosIteOri  := 0
Local nPosPrdOri  := 0
Local nDocExp     := 0

Local nAt		:= oGetExp:nAt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sera utilizado indice por nota fiscal ou por item da nota fiscal, caso o usuario informe o item no campo³
//³CDL_ITEMOR utiliza o mesmo na busca, caso contrario utilizo apenas a NF.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF1->(dbSetOrder(1))
SD1->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta array com os campos utilizados na rotina de complemento de exportacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_INDDOC"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_NUMDE"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_DTDE"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_NATEXP"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_NRREG"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_DTREG"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_CHCEMB"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_DTCHC"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_DTAVB"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_TPCHC"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_PAIS"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_NRMEMO"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_FORNEC"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_LOJFOR"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_DOCORI"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_SERORI"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_NFEXP"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_SEREXP"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_ESPEXP"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_EMIEXP"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_CHVNFE"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_CHVEXP"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_QTDEXP"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_UFEMB"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_LOCEMB"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui os campo CDL_ITEMNF / CDL_ITEORI no array para posterior tratamento, os     ³
//³mesmos foram criados devido a necessidade de se amarrar o documento de exportacao  ³
//³ ao item da nota fiscal na geracao dos registros 1100 e 1105 do Sped Fiscal        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_ITEMNF"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_ITEORI"}))
aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_PRDORI"}))
If lSdoc
	aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_DTORI"}))
	aAdd(aPos,aScan(aHExp,{|x| Alltrim(x[2])=="CDL_ESPORI"}))
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazeno Item e codigo do produto de origem para posterior filtro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosIteCdl := aPos[26]
nPosIteOri := aPos[27]
nPosPrdOri := aPos[28]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHExp)+1])
	If M926Obrig(aObrigat,aHExp,aCols[nAt],16)
		lObrigat := .T.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Verifica se Produto e Item existem no Documento     ³
    //³Fiscal (apenas da linha que esta sendo manipulada)  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !A926BscItm("SD2") .AND. aCols[nAt,1]+aCols[nAt,2] <> ""
		Alert("Não Existe Produto e Item no Documento Fiscal para o mesmo item de Exportação")
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a nota fiscal original (para exportacoes indiretas)³
//³existe na base de dados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. aCols[nAt][aPos[4]] == "1" .And. !Empty(Alltrim(aCols[nAt][aPos[15]]+aCols[nAt][aPos[16]]+aCols[nAt][aPos[13]]+aCols[nAt][aPos[14]]+Iif(nPosPrdOri > 0,aCols[nAt][nPosPrdOri],"")+Iif(nPosIteOri > 0,aCols[nAt][nPosIteOri],"")))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o cliente informe o produto e o item eu verifico a existencia da nota fiscal / Item  ³
	//³na tabela SD1                                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aCols[nAt][nPosPrdOri]) .And. !Empty(aCols[nAt][nPosIteOri])
		If !SD1->(MsSeek(xFilial("SD1")+aCols[nAt][aPos[15]]+aCols[nAt][aPos[16]]+aCols[nAt][aPos[13]]+aCols[nAt][aPos[14]]+aCols[nAt][nPosPrdOri]+aCols[nAt][nPosIteOri]))
			lAchouDoc := .F.
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Senao eu verifico a existencia da nota fiscal na SF1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		If !SF1->(MsSeek(xFilial("SF1")+aCols[nAt][aPos[15]]+aCols[nAt][aPos[16]]+aCols[nAt][aPos[13]]+aCols[nAt][aPos[14]]))
			lAchouDoc := .F.
		Endif
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executo o processamento dos itens informados pelo usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aCols)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se o registro atual nao esta deletado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(aCols[nX][Len(aHExp)+1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			lObrigat := M926Obrig(aObrigat,aHExp,aCols[nX],16)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exportacoes Diretas nao apresentam numero de memorando de exportacao.			³
		//³Exportacoes Indiretas apresentam numero de memorando de exportacao,  			³
		//³porem em uma mesma DI, e portanto para um mesmo numero de memorando,				³
		//³pode haver mais de um produto, mais de uma NF e assim por diante. Por			³
		//³este motivo, o tratamento para validacao do memorando de exportacao foi retirado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Verifico se eh um registro de exportacao indireta
		/*If aCols[nX][aPos[4]] $ "1"
			lExpIndir	:=	.T.
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o numero do memorando p/ exportacoes diretas.               ³
		//³Não pode haver dois itens com o mesmo memorando (CDL_NRMEMO).      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lExpIndir
			If aScan(aDocExp,{|x| x[8] == aCols[nX][aPos[12]]}) > 0
				lDuplItem := .T.
			EndIf
		Endif*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o numero do documento de Exportacao nao foi informado em outra linha para mesmo documento de entrada ³
		//|apenas faz a verificacao quando o item nao for incluido, caso contrario o usuario pode informar a mesma chave    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosIteCdl <= 0 .Or. (nPosIteCdl > 0 .And. Empty(aCols[nX][nPosIteCdl]))
			If aScan(aDocExp, {|x|;
				x[1] == aCols[nX][aPos[2]] .And. ;
				x[2] == aCols[nX][aPos[15]] .And.;
				x[3] == aCols[nX][aPos[16]] .And.;
				x[4] == aCols[nX][aPos[13]] .And.;
				x[5] == aCols[nX][aPos[14]] .And.;
				x[6] == aCols[nX][aPos[5]] .And.;
				x[8] == aCols[nX][aPos[12]]}) > 0
				lRepete := .T.
			Endif
		Endif

		//Caso de exportacao indireta, deve verificar se o documento original ja foi usado para o mesmo item
		//senao permite o usuario gravar o mesmo item duas vezes, para origens diferentes
		If lExpIndir
			If (nDocExp := aScan(aDocExp, {|x|;
				x[2] == aCols[nX][aPos[15]] .And.;
				x[3] == aCols[nX][aPos[16]] .And.;
				x[4] == aCols[nX][aPos[13]] .And.;
				x[5] == aCols[nX][aPos[14]] .And.;
				x[7] == aCols[nX][nPosIteCdl] .And.;
				x[8] == aCols[nX][aPos[12]]})) > 0
				lRepDocExIn := .T.
				aAdd(aDocRep,{aDocExp[nDocExp][7],aDocExp[nDocExp][2],aDocExp[nDocExp][3],aDocExp[nDocExp][4],aDocExp[nDocExp][5]})
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a nota fiscal original (para exportacoes indiretas)³
		//³existe na base de dados                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal .And. lExpIndir .And. !Empty(Alltrim(aCols[nAt][aPos[15]]+aCols[nAt][aPos[16]]+aCols[nAt][aPos[13]]+aCols[nAt][aPos[14]]+Iif(nPosPrdOri > 0,aCols[nAt][nPosPrdOri],"")+Iif(nPosIteOri > 0,aCols[nAt][nPosIteOri],"")))
			If !SF1->(MsSeek(xFilial("SF1")+aCols[nX][aPos[15]]+aCols[nX][aPos[16]]+aCols[nX][aPos[13]]+aCols[nX][aPos[14]]))
				lAchouDoc := .F.
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso os campos de referencia dos itens da nota fiscal nao existam eu verifico³
			//³se o documento de origem informado existe na SF1                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !SF1->(MsSeek(xFilial("SF1")+aCols[nAt][aPos[15]]+aCols[nAt][aPos[16]]+aCols[nAt][aPos[13]]+aCols[nAt][aPos[14]]))
				lAchouDoc := .F.
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o cliente informe o produto e o item eu verifico a existencia da nota fiscal / Item  ³
			//³na tabela SD1                                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aCols[nAt][nPosPrdOri]) .And. !Empty(aCols[nAt][nPosIteOri])
				If !SD1->(MsSeek(xFilial("SD1")+aCols[nAt][aPos[15]]+aCols[nAt][aPos[16]]+aCols[nAt][aPos[13]]+aCols[nAt][aPos[14]]+aCols[nAt][nPosPrdOri]+aCols[nAt][nPosIteOri]))
					lAchouDoc := .F.
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Senao eu verifico a existencia da nota fiscal na SF1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				If !SF1->(MsSeek(xFilial("SF1")+aCols[nAt][aPos[15]]+aCols[nAt][aPos[16]]+aCols[nAt][aPos[13]]+aCols[nAt][aPos[14]]))
					lAchouDoc := .F.
				Endif
			EndIf
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimento array para validacao de duplicidade de informacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aDocExp,{aCols[nX][aPos[2]],aCols[nX][aPos[15]],aCols[nX][aPos[16]],aCols[nX][aPos[13]],aCols[nX][aPos[14]],aCols[nX][aPos[5]],Iif(nPosIteCdl>0,aCols[nX][nPosIteCdl],""),aCols[nX][aPos[12]]})
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa que o numero do documento ja foi informado em outro item.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRepete
	Help("  ",1,"A926EXP")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe uma exportacao indireta sem documento    ³
//³original vinculado ou se o documento original nao existe na³
//³base de dados.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAchouDoc
	Help("  ",1,"A926AchDoc")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"OBRIGAT2")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*If lDuplItem
	Help("  ",1,"A926ITEDUP")
	lRet := .F.
Endif*/

If lRepDocExIn
	Alert("Existe numeração de Documentos Fiscais de Entrada utilizados repetidamente para o mesmo item de Exportação Indireta"+CRLF+CRLF+M926Msgm(aDocRep,"CDL"))
	lRet := .F.
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtuComp  ³ Autor ³ Cleber Stenio         ³ Data ³ 10/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alimenta dados nos coplementos do SPED automaticamente     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do documento                                ³±±
±±³          ³ ExpC2 = Serie                                              ³±±
±±³          ³ ExpC3 = Especie                                            ³±±
±±³          ³ ExpC4 = Cliente/Fornecedor                                 ³±±
±±³          ³ ExpC5 = Loja                                               ³±±
±±³          ³ ExpC6 = Tipo - entrada / saida                             ³±±
±±³          ³ ExpC7 = Verifica se e devolucao ou beneficiamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                       		                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtuComp(cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF)
Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSF2	:= SF2->(GetArea())
Local cMVMedica := "" //Grupos de produtos separados por "/" que identifica Medicamento
Local cVerGrup	:= ""
Local cAliasSB1	:= "SB1"
Local cAliasSD1	:= "SD1"
Local cAliasSD2	:= "SD2"
Local cAliasSF1	:= "SF1"
Local cAliasSF2	:= "SF2"
Local lAchouSF1	:= .F.
Local lAchouSF2	:= .F.
Local lQuery	:= .F.
Local cCondicao	:= ""
Local cLoteOri  := ""
Local cBranco	:= "%''%"
Local lExiste   := .F.
Local cMVRastro	:= Alltrim(SuperGetMv("MV_RASTRO",,"N"))
Local aChave    := {cEntSai,cSerie,cDoc,cClieFor,cLoja}

Local dDataFabric := CtoD("  /  /    ")
Local dDataValid  := CtoD("  /  /    ")
Local dDtFabOri   := CtoD("  /  /    ")
Local nPrcMax     := 0
Local nPrcOri     := 0

Local cAlias	:= "SD1"
Local cCstCred	:= "50#51#52#53#54#55#56#60#61#62#63#64#65#66"//CSTs de crédito
Local cCstTrib	:= "01#02#03#05"  //CSts tributáveis
Local cCstNTrib	:="04#06#07#08#09#49#99" //CSts não tributáveis
Local cIndOrig	:=""
Local cTpReg	:= ""
Local nBasPis	:= 0
Local nAliqPis	:= 0
Local nValPis	:= 0
Local nBasCof	:= 0
Local nAliqCOF	:= 0
Local nValCof	:= 0
Local l103910	:= Alltrim(cEntSai) == "E" .And. FunName() $ ("MATA910")
Local lC1100450	:= SF4->(ColumnPos("F4_CODINFC")) > 0 .And. SF4->(ColumnPos("F4_FORINFC")) > 0
Local cRetForm	:= ""
Local cGrpRasNFE := ""
Local lTabF0A    := AliasInDic("F0A")
Local lTabF2Q    := AliasInDic("F2Q")
Local lD8DFABRIC := SB8->(ColumnPos("B8_DFABRIC")) > 0
Local lD8DTVALID := SB8->(ColumnPos("B8_DTVALID")) > 0
Local lB1REFBAS  := SB1->(ColumnPos("B1_REFBAS" )) > 0
Local lB1TPPROD  := SB1->(ColumnPos("B1_TPPROD" )) > 0
Local lDA1PRCMAX := DA1->(ColumnPos("DA1_PRCMAX")) > 0
Local lPrcOri    := lTabF2Q.And.F2Q->(ColumnPos("F2Q_PMXANV")) > 0
Local lCodAnv    := lTabF2Q.And.F2Q->(ColumnPos("F2Q_CODANV")) > 0
Local lF2QRefBas := lTabF2Q.And.F2Q->(ColumnPos("F2Q_REFANV")) > 0
Local lF2QTpProd := lTabF2Q.And.F2Q->(ColumnPos("F2Q_TIPANV")) > 0
Local lMotAnv    := lTabF2Q.And.F2Q->(ColumnPos("F2Q_MOTISE")) > 0
Local lCD7CodAnv := CD7->(ColumnPos("CD7_CODANV")) > 0
Local lCD7MotAnv := CD7->(ColumnPos("CD7_MOTISE")) > 0
Local lCDDTMov	 := CDD->(FieldPos('CDD_ENTSAI')) > 0
Local lCddMeaRf	 := CDD->(FieldPos('CDD_MEANRF')) > 0
Local lCddMdaRf	 := CDD->(FieldPos('CDD_MODREF')) > 0

Local cCodAnv	 := ''
Local cMotAnv  := ''
Local cRefBas	 := ''
Local cTpProd	 := ''
Local nTamDoc    := TamSX3("F2_DOC")[1]
Local nTamItem   := TamSx3("CD7_ITEM")[1]
Local cItem		 := ""
Local cNfiscal	 := PADR(cDoc,nTamDoc)
Local cMenPad    := ""
Local cMenNota	 := ""
Local cIndOper 	 := ""

Local lLoja := FWIsInCallStack("LOJA720")

#IFDEF TOP
	Local cGrpAux	:= ""
#ELSE
	Local cGrupos	:= Alltrim(cMVMedica)
	Local cArqInd	:= ""
	Local cChave	:= ""
#ENDIF

Default lUsaSped :=	cPaisLoc == "BRA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Grupos de produtos separados por "/" que identifica Medicamentos|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMVMedica := GetParam("MV_MEDIC")

// Grupos de Produtos que devem gerar o Grupo I80 - Rastreabilidade na NF-e
// Estes grupos sao informados na tabela generica T0 para evitar a criacao
// de "n" parametros sequenciais.
cGrpRasNFE := GetTable("T0")

cVerGrup := Alltrim(cMVMedica) + AllTrim(cGrpRasNFE)

If !Empty(cVerGrup) .And. lUsaSped .And. "S"$cMVRastro

	If cEntSai=="E"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica pelo grupo de produtos dos itens³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP

			If TcSrvType()<>"AS/400"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a expressao para o select dos grupos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Medicamentos
				If !Empty(cMVMedica) .And. Right(cMVMedica,1) <> "/"
					cMVMedica := cMVMedica + "/"
				Endif
				// Rastreabilidade
				If !Empty(cGrpRasNFE) .And. Right(cGrpRasNFE,1) <> "/"
					cGrpRasNFE := cGrpRasNFE + "/"
				Endif
				cGrpAux := cMVMedica + cGrpRasNFE
				cGrpAux := StrTran(cGrpAux,"/",",")
				cGrpAux := Alltrim(cGrpAux)
				If Right(cGrpAux,1) == ","
					cGrpAux := SubStr(cGrpAux,1,Len(cGrpAux)-1)
				Endif
				cGrpAux := StrTran(cGrpAux,",","','")
				cGrpAux := "'" + cGrpAux + "'"
				cGrpAux := "(" + cGrpAux + ")"
				cGrpAux := "% " + cGrpAux + " %"

				lQuery 		:= .T.
				cAliasSD1	:= GetNextAlias()
				cAliasSB1	:= cAliasSD1

				BeginSql Alias cAliasSD1
					COLUMN D1_DTVALID AS DATE
					COLUMN D1_DFABRIC AS DATE

					SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_TIPO,
					SD1.D1_COD, SD1.D1_ITEM, SD1.D1_LOTECTL, SD1.D1_DTVALID, SD1.D1_QUANT, SD1.D1_LOCAL, SB1.B1_GRUPO, SB1.B1_UM,
					SB1.B1_PESO, SB1.B1_CODEMB, SB1.B1_PESBRU,SD1.D1_LOTEFOR,SD1.D1_NUMLOTE,SD1.D1_DFABRIC,SD1.D1_NFORI,SD1.D1_SERIORI,SD1.D1_ITEMORI

					FROM %table:SD1% SD1, %table:SB1% SB1

					WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
						SD1.D1_DOC = %Exp:cDoc% AND
						SD1.D1_SERIE = %Exp:cSerie% AND
						SD1.D1_FORNECE = %Exp:cClieFor% AND
						SD1.D1_LOJA = %Exp:cLoja% AND
						SD1.%NotDel% AND
						SB1.B1_FILIAL = %xFilial:SB1% AND
						SB1.B1_COD = SD1.D1_COD AND
						SB1.B1_GRUPO IN %Exp:cGrpAux% AND
						SB1.%NotDel%
					ORDER BY %Order:SD1%
				EndSql

				dbSelectArea(cAliasSD1)

			Else

		#ENDIF
				cArqInd   := CriaTrab(Nil,.F.)
				cChave    := SD1->(IndexKey())
				cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .AND. '
				cCondicao += 'D1_DOC == "' + cDoc + '" .AND. '
				cCondicao += 'D1_SERIE == "' + cSerie + '" .AND. '
				cCondicao += 'D1_FORNECE == "' + cClieFor + '" .AND. '
				cCondicao += 'D1_LOJA == "' + cLoja + '"'
				IndRegua(cAliasSD1,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
				#IFNDEF TOP
					DbSetIndex(cArqInd+OrdBagExt())
				#ENDIF
				(cAliasSD1)->(dbGotop())
		#IFDEF TOP
			Endif
		#ENDIF

		IncProc(STR0065) //"Complementos por grupo de produto"

		Do While !((cAliasSD1)->(Eof()))

			If !lQuery
				If !(cAliasSB1)->(dbSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
					(cAliasSD1)->(dbSkip())
					Loop
				Endif
				If !(cAliasSB1)->B1_GRUPO $ cGrupos
					(cAliasSD1)->(dbSkip())
					Loop
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o item existe para altera-lo ou gravar um novo.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Medicamentos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim((cAliasSB1)->B1_GRUPO) $ cMVMedica
				dbSelectArea("CD7")
				CD7->(dbSetOrder(1)) //CD7_FILIAL+CD7_TPMOV+CD7_SERIE+CD7_DOC+CD7_CLIFOR+CD7_LOJA+CD7_ITEM+CD7_COD
				lExiste   := CD7->(dbSeek(xFilial("CD7")+cEntSai+cSerie+Padr(cDoc,nTamDoc)+cClieFor+cLoja+Padr((cAliasSD1)->D1_ITEM,nTamItem)+(cAliasSD1)->D1_COD))
				nPrcOri   := GetAdvFVal( "CD7", "CD7_PRECO", xFilial("CD7")+"S"+(cAliasSD1)->D1_SERIORI+PADR((cAliasSD1)->D1_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD1)->D1_ITEMORI+(cAliasSD1)->D1_COD, 1 , "")
				cLoteOri  := GetAdvFVal( "CD7", "CD7_LOTE",  xFilial("CD7")+"S"+(cAliasSD1)->D1_SERIORI+PADR((cAliasSD1)->D1_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD1)->D1_ITEMORI+(cAliasSD1)->D1_COD, 1 , "")
				dDtFabOri := GetAdvFVal( "CD7", "CD7_FABRIC",xFilial("CD7")+"S"+(cAliasSD1)->D1_SERIORI+PADR((cAliasSD1)->D1_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD1)->D1_ITEMORI+(cAliasSD1)->D1_COD, 1 , "")
				If !Empty((cAliasSD1)->D1_LOTECTL) .Or. !Empty(cLoteOri)
					If !lExiste
						//Busca informações na tabela F2Q (Complemento fiscal do produto).
						If lTabF2Q
							F2Q->(DbSetOrder(01))
							If F2Q->(DbSeek(xFilial('F2Q') + (cAliasSD1)->D1_COD))
								nPrcOri := If(lPrcOri	, F2Q->F2Q_PMXANV, 0 )
								cCodAnv := If(lCodAnv	, F2Q->F2Q_CODANV, '')
								cRefBas := If(lF2QRefBas, F2Q->F2Q_REFANV, '')
								cTpProd := If(lF2QTpProd, F2Q->F2Q_TIPANV, '')
								cMotAnv := If(lMotAnv , F2Q->F2Q_MOTISE, '')
							Else
								nPrcOri := 0
								cCodAnv := ''
								cRefBas := ''
								cTpProd := ''
								cMotAnv := ''
							EndIf
						EndIf
						//Caso os campos "referência" e "tipo" não estejam cadastrados na tabela F2Q
						//verifica no cadastro de produto.
						SB1->(DbSetOrder(01))
						If SB1->(DbSeek(xFilial('SB1') + (cAliasSD1)->D1_COD))
							If Empty(cRefBas)
								cRefBas := If(lB1REFBAS, SB1->B1_REFBAS, '')
							EndIf
							If Empty(cTpProd)
								cTpProd := If(lB1TPPROD, SB1->B1_TPPROD, '')
							EndIf
						EndIf
						SB8->(DbSetOrder(5))
						SB8->(DbSeek(xFilial("SB8")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOTECTL+(cAliasSD1)->D1_NUMLOTE+DTOS((cAliasSD1)->D1_DTVALID)))
						If lD8DFABRIC .And. !Empty(DTOS(SB8->B8_DFABRIC))
							dDataFabric	:= SB8->B8_DFABRIC
						Else
							dDataFabric	:= (cAliasSD1)->D1_DFABRIC
						EndIf
						If lD8DTVALID .And. !Empty(DTOS(SB8->B8_DTVALID))
							dDataValid	:= SB8->B8_DTVALID
						Else
							dDataValid	:= (cAliasSD1)->D1_DTVALID
						EndIf
						RecLock("CD7",.T.)
						CD7->CD7_FILIAL	:= (cAliasSD1)->D1_FILIAL
						CD7->CD7_TPMOV	:= "E"
						CD7->CD7_DOC	:= (cAliasSD1)->D1_DOC
						CD7->CD7_SERIE	:= (cAliasSD1)->D1_SERIE
						CD7->CD7_CLIFOR	:= (cAliasSD1)->D1_FORNECE
						CD7->CD7_LOJA	:= (cAliasSD1)->D1_LOJA
						CD7->CD7_ITEM	:= (cAliasSD1)->D1_ITEM
						CD7->CD7_COD	:= (cAliasSD1)->D1_COD
						CD7->CD7_LOTE	:= If(Empty(cLoteOri),(cAliasSD1)->D1_LOTECTL,cLoteOri)
						CD7->CD7_VALID	:= dDataValid
						CD7->CD7_QTDLOT	:= (cAliasSD1)->D1_QUANT
						CD7->CD7_FABRIC	:= If(Empty(dDtFabOri), dDataFabric, dDtFabOri)
						CD7->CD7_REFBAS	:= cRefBas
						CD7->CD7_TPPROD	:= cTpProd
						CD7->CD7_PRECO	:= nPrcOri
						If lCD7CodAnv
							CD7->CD7_CODANV := cCodAnv
						EndIf
						If lCD7MotAnv
							CD7->CD7_MOTISE := cMotAnv
						EndIf
					Else
						RecLock("CD7",.F.)
						CD7->CD7_LOTE	:= (cAliasSD1)->D1_LOTECTL
						CD7->CD7_VALID	:= (cAliasSD1)->D1_DTVALID
					EndIf
					MsUnLock()
					FkCommit()
				EndIf
			Endif
			nPrcOri := 0
			cCodAnv := ''
			cRefBas := ''
			cTpProd := ''
			cMotAnv := ''

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rastreabilidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTabF0A .And. AllTrim((cAliasSB1)->B1_GRUPO) $ cGrpRasNFE
				dbSelectArea("F0A")
				F0A->(dbSetOrder(1))
				lExiste   := F0A->(dbSeek(xFilial("F0A")+cEntSai+cSerie+PADR(cDoc,nTamDoc)+cClieFor+cLoja+(cAliasSD1)->D1_ITEM+(cAliasSD1)->D1_COD))
				cLoteOri  := GetAdvFVal( "F0A", "F0A_LOTE",   xFilial("F0A")+"S"+(cAliasSD1)->D1_SERIORI+PADR((cAliasSD1)->D1_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD1)->D1_ITEMORI+(cAliasSD1)->D1_COD, 1 , "")
				dDtFabOri := GetAdvFVal( "F0A", "F0A_FABRIC", xFilial("F0A")+"S"+(cAliasSD1)->D1_SERIORI+PADR((cAliasSD1)->D1_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD1)->D1_ITEMORI+(cAliasSD1)->D1_COD, 1 , "")
				If !Empty((cAliasSD1)->D1_LOTECTL) .Or. !Empty(cLoteOri)
					If !lExiste
						SB8->(DbSetOrder(5))
						SB8->(DbSeek(xFilial("SB8")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOTECTL+(cAliasSD1)->D1_NUMLOTE+DTOS((cAliasSD1)->D1_DTVALID)))
						If lD8DFABRIC .And. !Empty(DTOS(SB8->B8_DFABRIC))
							dDataFabric	:= SB8->B8_DFABRIC
						Else
							dDataFabric	:= (cAliasSD1)->D1_DFABRIC
						EndIf
						If lD8DTVALID .And. !Empty(DTOS(SB8->B8_DTVALID))
							dDataValid	:= SB8->B8_DTVALID
						Else
							dDataValid	:= (cAliasSD1)->D1_DTVALID
						EndIf
						RecLock("F0A",.T.)
						F0A->F0A_FILIAL	:= (cAliasSD1)->D1_FILIAL
						F0A->F0A_TPMOV	:= "E"
						F0A->F0A_DOC	:= (cAliasSD1)->D1_DOC
						F0A->F0A_SERIE	:= (cAliasSD1)->D1_SERIE
						F0A->F0A_CLIFOR	:= (cAliasSD1)->D1_FORNECE
						F0A->F0A_LOJA	:= (cAliasSD1)->D1_LOJA
						F0A->F0A_ITEM	:= (cAliasSD1)->D1_ITEM
						F0A->F0A_COD	:= (cAliasSD1)->D1_COD
						F0A->F0A_LOTE	:= IIf(Empty((cAliasSD1)->D1_LOTECTL),cLoteOri,(cAliasSD1)->D1_LOTECTL)
						F0A->F0A_VALID	:= dDataValid
						F0A->F0A_QTDLOT	:= (cAliasSD1)->D1_QUANT
						F0A->F0A_FABRIC	:= IIf(Empty(dDtFabOri), dDataFabric, dDtFabOri)
					Else
						RecLock("F0A",.F.)
						F0A->F0A_LOTE	:= (cAliasSD1)->D1_LOTECTL
						F0A->F0A_VALID	:= (cAliasSD1)->D1_DTVALID
					EndIf
					MsUnLock()
					FkCommit()
				EndIf
			Endif
			(cAliasSD1)->(dbSkip())
		EndDo
		(cAliasSD1)->(dbCloseArea())
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica pelo grupo de produtos dos itens³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP

			If TcSrvType()<>"AS/400"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta a expressao para o select dos grupos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Medicamentos
				If !Empty(cMVMedica) .And. Right(cMVMedica,1) <> "/"
					cMVMedica := cMVMedica + "/"
				Endif

				// Rastreabilidade
				If !Empty(cGrpRasNFE) .And. Right(cGrpRasNFE,1) <> "/"
					cGrpRasNFE := cGrpRasNFE + "/"
				Endif

				cGrpAux := cMVMedica + cGrpRasNFE

				cGrpAux := StrTran(cGrpAux,"/",",")
				cGrpAux := Alltrim(cGrpAux)
				If Right(cGrpAux,1) == ","
					cGrpAux := SubStr(cGrpAux,1,Len(cGrpAux)-1)
				Endif
				cGrpAux := StrTran(cGrpAux,",","','")
				cGrpAux := "'" + cGrpAux + "'"
				cGrpAux := "(" + cGrpAux + ")"
				cGrpAux := "%" + cGrpAux + "%"

				lQuery 		:= .T.
				cAliasSD2	:= GetNextAlias()
				cAliasSB1	:= cAliasSD2

				BeginSql Alias cAliasSD2
					COLUMN D2_DTVALID AS DATE
					COLUMN D2_DFABRIC AS DATE

					SELECT SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_TIPO,
					SD2.D2_COD, SD2.D2_LOCAL,SD2.D2_ITEM, SD2.D2_LOTECTL,SD2.D2_DTVALID,SD2.D2_PEDIDO, SD2.D2_QUANT, D2_DFABRIC,
					SB1.B1_GRUPO, SB1.B1_UM,SB1.B1_PESO, SB1.B1_CODEMB, SB1.B1_PESBRU,SD2.D2_NFORI,SD2.D2_SERIORI,D2_ITEMORI

					FROM %table:SD2% SD2, %table:SB1% SB1

					WHERE SD2.D2_FILIAL = %xFilial:SD2% AND
						SD2.D2_DOC = %Exp:cDoc% AND
						SD2.D2_SERIE = %Exp:cSerie% AND
						SD2.D2_CLIENTE = %Exp:cClieFor% AND
						SD2.D2_LOJA = %Exp:cLoja% AND
						SD2.%NotDel% AND
						SB1.B1_FILIAL = %xFilial:SB1% AND
						SB1.B1_COD = SD2.D2_COD AND
						SB1.B1_GRUPO IN %Exp:cGrpAux% AND
						SB1.%NotDel%
					ORDER BY %Order:SD2%
				EndSql

				dbSelectArea(cAliasSD2)

			Else

		#ENDIF
				cArqInd   := CriaTrab(Nil,.F.)
				cChave    := SD2->(IndexKey())
				cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .AND. '
				cCondicao += 'D2_DOC == "' + cDoc + '" .AND. '
				cCondicao += 'D2_SERIE == "' + cSerie + '" .AND. '
				cCondicao += 'D2_CLIENTE == "' + cClieFor + '" .AND. '
				cCondicao += 'D2_LOJA == "' + cLoja + '"'
				IndRegua(cAliasSD2,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
				#IFNDEF TOP
					DbSetIndex(cArqInd+OrdBagExt())
				#ENDIF
				(cAliasSD2)->(dbGotop())
		#IFDEF TOP
			Endif
		#ENDIF

		IncProc(STR0065) //"Complementos por grupo de produto"

		Do While !((cAliasSD2)->(Eof()))

			If !lQuery
				If !(cAliasSB1)->(dbSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
					(cAliasSD2)->(dbSkip())
					Loop
				Endif
				If !(cAliasSB1)->B1_GRUPO $ cGrupos
					(cAliasSD2)->(dbSkip())
					Loop
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o item existe para altera-lo ou gravar um novo.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cItem		:= Padr((cAliasSD2)->D2_ITEM,nTamItem)
			cNfiscal	:= PADR(cDoc,nTamDoc)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Medicamentos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim((cAliasSB1)->B1_GRUPO) $ cMVMedica
				dbSelectArea("CD7")
				CD7->(dbSetOrder(1)) //CD7_FILIAL+CD7_TPMOV+CD7_SERIE+CD7_DOC+CD7_CLIFOR+CD7_LOJA+CD7_ITEM+CD7_COD
				lExiste   := CD7->(dbSeek(xFilial("CD7")+cEntSai+cSerie+cNfiscal+cClieFor+cLoja+cItem+(cAliasSD2)->D2_COD))
				nPrcOri   := GetAdvFVal( "CD7", "CD7_PRECO",  xFilial("CD7")+"E"+(cAliasSD2)->D2_SERIORI+PADR((cAliasSD2)->D2_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD2)->D2_ITEMORI+(cAliasSD2)->D2_COD, 1 , "" )
				cLoteOri  := GetAdvFVal( "CD7", "CD7_LOTE",   xFilial("CD7")+"E"+(cAliasSD2)->D2_SERIORI+PADR((cAliasSD2)->D2_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD2)->D2_ITEMORI+(cAliasSD2)->D2_COD, 1 , "" )
				dDtFabOri := GetAdvFVal( "CD7", "CD7_FABRIC", xFilial("CD7")+"E"+(cAliasSD2)->D2_SERIORI+PADR((cAliasSD2)->D2_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD2)->D2_ITEMORI+(cAliasSD2)->D2_COD, 1 , "" )
				If (!Empty((cAliasSD2)->D2_LOTECTL) .Or. !Empty(cLoteOri)) .And. "S"$cMVRastro
					If !lExiste
						SC5->(DbSetOrder(1))
						SC5->(DbSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO))
						DA1->(DbSetOrder(1))
						DA1->(DbSeek(xFilial("DA1")+SC5->C5_TABELA+(cAliasSD2)->D2_COD))
						nPrcMax := Iif(lDA1PRCMAX,DA1->DA1_PRCMAX,0)
						SB8->(DbSetOrder(1))
						SB8->(DbSeek(xFilial("SB8")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_LOCAL+DTOS((cAliasSD2)->D2_DTVALID)+(cAliasSD2)->D2_LOTECTL))
						If lD8DFABRIC .And. !Empty(DTOS(SB8->B8_DFABRIC))
							dDataFabric	:= SB8->B8_DFABRIC
						Elseif Empty(dDtFabOri) .And. !EMPTY((cAliasSD2)->D2_DFABRIC)
							dDataFabric	:= (cAliasSD2)->D2_DFABRIC
						Else
							dDataFabric	:= dDtFabOri
						EndIf
						If lD8DTVALID .And. !Empty(DTOS(SB8->B8_DTVALID))
							dDataValid	:= SB8->B8_DTVALID
						Else
							dDataValid	:= (cAliasSD2)->D2_DTVALID
						EndIf
						//Busca informações na tabela F2Q (Complemento fiscal do produto).
						If lTabF2Q
							F2Q->(DbSetOrder(01))
							If F2Q->(DbSeek(xFilial('F2Q') + (cAliasSD2)->D2_COD))
								nPrcOri := If(lPrcOri	, F2Q->F2Q_PMXANV, 0 )
								cCodAnv := If(lCodAnv	, F2Q->F2Q_CODANV, '')
								cRefBas := If(lF2QRefBas, F2Q->F2Q_REFANV, '')
								cTpProd := If(lF2QTpProd, F2Q->F2Q_TIPANV, '')
								cMotAnv := If(lMotAnv, F2Q->F2Q_MOTISE, '')
							Else
								cCodAnv := ''
								cRefBas := ''
								cTpProd := ''
								cMotAnv := ''
							EndIf
						EndIf
						//Caso os campos "referência" e "tipo" não estejam cadastrados na tabela F2Q
						//verifica no cadastro de produto.
						SB1->(DbSetOrder(01))
						If SB1->(DbSeek(xFilial('SB1') + (cAliasSD2)->D2_COD))
							If Empty(cRefBas)
								cRefBas := If(lB1REFBAS, SB1->B1_REFBAS, '')
							EndIf
							If Empty(cTpProd)
								cTpProd := If(lB1TPPROD, SB1->B1_TPPROD, '')
							EndIf
						EndIf
						RecLock("CD7",.T.)
						CD7->CD7_FILIAL	:= (cAliasSD2)->D2_FILIAL
						CD7->CD7_TPMOV	:= "S"
						CD7->CD7_DOC	:= (cAliasSD2)->D2_DOC
						CD7->CD7_SERIE	:= (cAliasSD2)->D2_SERIE
						CD7->CD7_CLIFOR	:= (cAliasSD2)->D2_CLIENTE
						CD7->CD7_LOJA	:= (cAliasSD2)->D2_LOJA
						CD7->CD7_ITEM	:= (cAliasSD2)->D2_ITEM
						CD7->CD7_COD	:= (cAliasSD2)->D2_COD
						CD7->CD7_LOTE	:= IIf(Empty(cLoteOri),(cAliasSD2)->D2_LOTECTL,cLoteOri)
						CD7->CD7_FABRIC	:= dDataFabric
						CD7->CD7_VALID	:= dDataValid
						CD7->CD7_QTDLOT	:= (cAliasSD2)->D2_QUANT
						CD7->CD7_REFBAS	:= cRefBas
						CD7->CD7_TPPROD	:= cTpProd
						CD7->CD7_PRECO	:= Iif(nPrcOri > 0 ,nPrcOri,nPrcMax)//a variável nPrcOri pode receber o valor da origem ou do complemento fiscal (F2Q). A variável nPrcMax recebe seu valor da tabela de preços do produto.
						If lCD7CodAnv
							CD7->CD7_CODANV := cCodAnv
						EndIf
						If lCD7MotAnv
							CD7->CD7_MOTISE := cMotAnv
						EndIf
					Else
						RecLock("CD7",.F.)
						CD7->CD7_LOTE	:= (cAliasSD2)->D2_LOTECTL
						CD7->CD7_VALID	:= (cAliasSD2)->D2_DTVALID
					EndIf
					MsUnLock()
					FkCommit()
				EndIf
			EndIf
			nPrcOri := 0
			cCodAnv := ''
			cRefBas := ''
			cTpProd := ''
			cMotAnv := ''

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rastreabilidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTabF0A .And. AllTrim((cAliasSB1)->B1_GRUPO) $ cGrpRasNFE
				dbSelectArea("F0A")
				F0A->(dbSetOrder(1))
				lExiste   := F0A->(dbSeek(xFilial("F0A")+cEntSai+cSerie+cNfiscal+cClieFor+cLoja+cItem+(cAliasSD2)->D2_COD))
				cLoteOri  := GetAdvFVal( "F0A", "F0A_LOTE",   xFilial("F0A")+"E"+(cAliasSD2)->D2_SERIORI+PADR((cAliasSD2)->D2_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD2)->D2_ITEMORI+(cAliasSD2)->D2_COD, 1 , "" )
				dDtFabOri := GetAdvFVal( "F0A", "F0A_FABRIC", xFilial("F0A")+"E"+(cAliasSD2)->D2_SERIORI+PADR((cAliasSD2)->D2_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD2)->D2_ITEMORI+(cAliasSD2)->D2_COD, 1 , "" )
				dDtValid  := GetAdvFVal( "F0A", "F0A_VALID",  xFilial("F0A")+"E"+(cAliasSD2)->D2_SERIORI+PADR((cAliasSD2)->D2_NFORI,nTamDoc)+cClieFor+cLoja+(cAliasSD2)->D2_ITEMORI+(cAliasSD2)->D2_COD, 1 , "" )
				If (!Empty((cAliasSD2)->D2_LOTECTL) .Or. !Empty(cLoteOri)) .And. "S"$cMVRastro
					If !lExiste
						SB8->(DbSetOrder(1))
						SB8->(DbSeek(xFilial("SB8")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_LOCAL+DTOS((cAliasSD2)->D2_DTVALID)+(cAliasSD2)->D2_LOTECTL))
						If lD8DFABRIC .And. !Empty(DTOS(SB8->B8_DFABRIC))
							dDataFabric	:= SB8->B8_DFABRIC
						Elseif Empty(dDtFabOri) .And. !EMPTY((cAliasSD2)->D2_DFABRIC)
							dDataFabric	:= (cAliasSD2)->D2_DFABRIC
						Else
							dDataFabric	:= dDtFabOri
						EndIf
						If lD8DTVALID .And. !Empty(DTOS(SB8->B8_DTVALID))
							dDataValid	:= SB8->B8_DTVALID
						ElseIf !Empty((cAliasSD2)->D2_DTVALID)
							dDataValid	:= (cAliasSD2)->D2_DTVALID
						Else
							dDataValid := dDtValid
						EndIf
						RecLock("F0A",.T.)
						F0A->F0A_FILIAL	:= (cAliasSD2)->D2_FILIAL
						F0A->F0A_TPMOV	:= "S"
						F0A->F0A_DOC	:= (cAliasSD2)->D2_DOC
						F0A->F0A_SERIE	:= (cAliasSD2)->D2_SERIE
						F0A->F0A_CLIFOR	:= (cAliasSD2)->D2_CLIENTE
						F0A->F0A_LOJA	:= (cAliasSD2)->D2_LOJA
						F0A->F0A_ITEM	:= (cAliasSD2)->D2_ITEM
						F0A->F0A_COD	:= (cAliasSD2)->D2_COD
						F0A->F0A_LOTE	:= IIf(Empty((cAliasSD2)->D2_LOTECTL),cLoteOri,(cAliasSD2)->D2_LOTECTL)
						F0A->F0A_FABRIC	:= dDataFabric
						F0A->F0A_VALID	:= dDataValid
						F0A->F0A_QTDLOT	:= (cAliasSD2)->D2_QUANT
					Else
						RecLock("F0A",.F.)
						F0A->F0A_LOTE	:= (cAliasSD2)->D2_LOTECTL
						F0A->F0A_VALID	:= (cAliasSD2)->D2_DTVALID
					EndIf
					MsUnLock()
					FkCommit()
				EndIf
			Endif
			(cAliasSD2)->(dbSkip())
		EndDo
		(cAliasSD2)->(dbCloseArea())
	EndIf
EndIf

If cEntSai=="E" .AND. !cTpNF$"D|B"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica pelo grupo de produtos dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP

		If TcSrvType()<>"AS/400"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a expressao para o select dos grupos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			lQuery 		:= .T.
			cAlias	:= GetNextAlias()
			cAliasSB1	:= cAlias

			If l103910
				BeginSql Alias cAlias
					COLUMN D1_DTDIGIT AS DATE
					COLUMN D1_DTFIMNT AS DATE

					SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_TIPO,SD1.D1_COD,SD1.D1_ITEM,SD1.D1_DTDIGIT,
					SD1.D1_TES,SD1.D1_CONTA,SD1.D1_CC,SD1.D1_CF,SD1.D1_ALQCOF,SD1.D1_ALQPIS,SD1.D1_BASECOF,SD1.D1_BASEPIS,SD1.D1_VALCOF,SD1.D1_VALPIS,
					SD1.D1_ALQIMP5,SD1.D1_ALQIMP6,SD1.D1_BASIMP5,SD1.D1_BASIMP6,SD1.D1_VALIMP5,SD1.D1_VALIMP6,
					SF4.F4_CSTCF1,SF4.F4_CSTPF1,SF4.F4_EFDF100,SF4.F4_TPREG,
					SD1.D1_TNATREC,SD1.D1_CNATREC,SD1.D1_GRUPONC,SD1.D1_DTFIMNT,SF4.F4_CODBCC

					FROM %table:SD1% SD1
					JOIN %Table:SF4% SF4 ON (SF4.F4_FILIAL=%xFilial:SF4% AND SD1.D1_TES = SF4.F4_CODIGO AND SF4.%NotDel%)

					WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
						SD1.D1_DOC = %Exp:cDoc% AND
						SD1.D1_SERIE = %Exp:cSerie% AND
						SD1.D1_FORNECE = %Exp:cClieFor% AND
						SD1.D1_LOJA = %Exp:cLoja% AND
						SF4.F4_EFDF100 IN ('1','2') AND
						SF4.F4_CSTCF1 <> ' ' AND
						SF4.F4_CSTPF1 <> ' ' AND
						SD1.%NotDel%
					ORDER BY %Order:SD1%
				EndSql
			Else
				BeginSql Alias cAlias
					COLUMN D1_DTDIGIT AS DATE
					COLUMN FT_DTFIMNT AS DATE

					SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_TIPO,SD1.D1_COD,SD1.D1_ITEM,SD1.D1_DTDIGIT,
					SD1.D1_TES,SD1.D1_CONTA,SD1.D1_CC,SD1.D1_CF,SD1.D1_ALQCOF,SD1.D1_ALQPIS,SD1.D1_BASECOF,SD1.D1_BASEPIS,SD1.D1_VALCOF,SD1.D1_VALPIS,
					SD1.D1_ALQIMP5,SD1.D1_ALQIMP6,SD1.D1_BASIMP5,SD1.D1_BASIMP6,SD1.D1_VALIMP5,SD1.D1_VALIMP6,
					SF4.F4_CSTCF1,SF4.F4_CSTPF1,SF4.F4_EFDF100,SF4.F4_TPREG,
					SFT.FT_VALCONT,SFT.FT_TNATREC,SFT.FT_CNATREC,SFT.FT_GRUPONC,SFT.FT_DTFIMNT,SFT.FT_CODBCC

					FROM %table:SD1% SD1
					JOIN %Table:SF4% SF4 ON (SF4.F4_FILIAL=%xFilial:SF4% AND SD1.D1_TES = SF4.F4_CODIGO AND SF4.%NotDel%)
					JOIN %Table:SFT% SFT ON (SFT.FT_FILIAL=%xFilial:SFT% AND SFT.FT_NFISCAL = SD1.D1_DOC AND  SFT.FT_SERIE = SD1.D1_SERIE AND SFT.FT_CLIEFOR = SD1.D1_FORNECE AND SFT.FT_LOJA = SD1.D1_LOJA AND SFT.FT_ITEM = SD1.D1_ITEM AND SFT.FT_PRODUTO = SD1.D1_COD AND SFT.%NotDel%)

					WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
						SD1.D1_DOC = %Exp:cDoc% AND
						SD1.D1_SERIE = %Exp:cSerie% AND
						SD1.D1_FORNECE = %Exp:cClieFor% AND
						SD1.D1_LOJA = %Exp:cLoja% AND
						SF4.F4_EFDF100 IN ('1','2') AND
						SF4.F4_CSTCF1 <> ' ' AND
						SF4.F4_CSTPF1 <> ' ' AND
						SD1.%NotDel%
					ORDER BY %Order:SD1%
				EndSql
			EndIf

			dbSelectArea(cAlias)

		Else

	#ENDIF
			cArqInd   := CriaTrab(Nil,.F.)
			cChave    := SD1->(IndexKey())
			cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .AND. '
			cCondicao += 'D1_DOC == "' + cDoc + '" .AND. '
			cCondicao += 'D1_SERIE == "' + cSerie + '" .AND. '
			cCondicao += 'D1_FORNECE == "' + cClieFor + '" .AND. '
			cCondicao += 'D1_LOJA == "' + cLoja + '"'
			IndRegua(cAlias,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAlias)->(dbGotop())
	#IFDEF TOP
		Endif
	#ENDIF

	IncProc(STR0065) //"Complementos por grupo de produto"

	nAliqPis:= SuperGetMv("MV_TXPIS")
	nAliqCof:= SuperGetMv("MV_TXCOFIN")

	Do While !((cAlias)->(Eof()))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item existe para altera-lo ou gravar um novo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CF8")
		CF8->(dbSetOrder(3))
		lExiste	:= CF8->(dbSeek(xFilial("CF8")+PADR(cDoc,nTamDoc)+cSerie+cClieFor+cLoja))

		If (cAlias)->F4_CSTPF1 $ cCstCred
			cIndOper := "0"
		ElseIf (cAlias)->F4_CSTPF1 $ cCstTrib
			cIndOper := "1"
		ElseIf (cAlias)->F4_CSTPF1 $ cCstNTrib
			cIndOper := "2"
		EndIF

		cIndOrig:= Iif((cAlias)->F4_EFDF100=='2',Iif(Substr((cAlias)->D1_CF,1,1) == "3","1","0"),"")
		cTpReg 	:= Iif((cAlias)->F4_TPREG$'1|2',Iif((cAlias)->F4_TPREG=='1','2','1'),"")

		nBasPis		:=Iif((cAlias)->D1_BASIMP6 > 0,(cAlias)->D1_BASIMP6,(cAlias)->D1_BASEPIS)
		nAliqPis	:=Iif((cAlias)->D1_ALQIMP6 > 0,(cAlias)->D1_ALQIMP6,Iif((cAlias)->D1_ALQPIS > 0,(cAlias)->D1_ALQPIS,nAliqPis))
		nValPis		:=Iif((cAlias)->D1_VALIMP6 > 0,(cAlias)->D1_VALIMP6,(cAlias)->D1_VALPIS)
		nBasCof		:=Iif((cAlias)->D1_BASIMP5 > 0,(cAlias)->D1_BASIMP5,(cAlias)->D1_BASECOF)
		nAliqCOF	:=Iif((cAlias)->D1_ALQIMP5 > 0,(cAlias)->D1_ALQIMP5,Iif((cAlias)->D1_ALQCOF > 0, (cAlias)->D1_ALQCOF,nAliqCof))
		nValCof		:=Iif((cAlias)->D1_VALIMP5 > 0,(cAlias)->D1_VALIMP5,(cAlias)->D1_VALCOF)

		IF cIndOper == "0"
			//Para as operações com direito ao crédito, o produto será gravado na CF8, já que se trata de operação de crédito, quando mais informações
			//enviar no F100 mais transparente ficará a declaração, isso já acontece com o código do participante, se for operação com direito ao crédito
			//o participante é obrigatório, por este motivo não irei acumular CF8 para operações com créditos, irei gravar uma CF8 para cada item de nota.
			lExiste	:= .F.
		EndIf

		If cIndOper <> "" // Impede o usuário de gravar CF8 caso cadastre condições não previstas em cCstCred, cCstTrib ou cCstNTrib https://jiraproducao.totvs.com.br/browse/DSERFISE-5085

			If !lExiste
				RecLock("CF8",.T.)
				CF8->CF8_FILIAL	:= (cAlias)->D1_FILIAL
				CF8->CF8_CODIGO	:= GetSXENum("CF8","CF8_CODIGO")
				CF8->CF8_PART	:= "2"
				CF8->CF8_TPREG	:= cTpReg
				CF8->CF8_INDOPE	:= cIndOper
				CF8->CF8_DOC	:= (cAlias)->D1_DOC
				CF8->CF8_SERIE	:= (cAlias)->D1_SERIE
				CF8->CF8_CLIFOR	:= (cAlias)->D1_FORNECE
				CF8->CF8_LOJA	:= (cAlias)->D1_LOJA
				If cIndOper == "0"
					CF8->CF8_ITEM	:= (cAlias)->D1_COD
				EndIF
				CF8->CF8_DTOPER	:= (cAlias)->D1_DTDIGIT
				CF8->CF8_CSTPIS	:= (cAlias)->F4_CSTPF1
				CF8->CF8_BASPIS	:= nBasPis
				CF8->CF8_ALQPIS	:= nAliqPis
				CF8->CF8_VALPIS	:= nValPis
				CF8->CF8_CSTCOF	:= (cAlias)->F4_CSTCF1
				CF8->CF8_BASCOF	:= nBasCof
				CF8->CF8_ALQCOF	:= nAliqCOF
				CF8->CF8_VALCOF	:= nValCof
				CF8->CF8_CODBCC	:= IIF(l103910, (cAlias)->F4_CODBCC, (cAlias)->FT_CODBCC )
				CF8->CF8_CODCTA	:= (cAlias)->D1_CONTA
				CF8->CF8_CODCCS	:= (cAlias)->D1_CC
				CF8->CF8_TNATRE	:= IIF(l103910, (cAlias)->D1_TNATREC, (cAlias)->FT_TNATREC )
				CF8->CF8_CNATRE	:= IIF(l103910, (cAlias)->D1_CNATREC, (cAlias)->FT_CNATREC )
				CF8->CF8_GRPNC	:= IIF(l103910, (cAlias)->D1_GRUPONC, (cAlias)->FT_GRUPONC )
				CF8->CF8_DTFIMN	:= IIF(l103910, (cAlias)->D1_DTFIMNT, (cAlias)->FT_DTFIMNT )
				CF8->CF8_INDORI	:= cIndOrig
				CF8->CF8_VLOPER	:= IIF(l103910, IIF( MaFisFound("IT",Val((cAlias)->D1_ITEM)), MafisRet(Val((cAlias)->D1_ITEM),"LF_VALCONT"),0), (cAlias)->FT_VALCONT)
			Else
				RecLock("CF8",.F.)
				CF8->CF8_VLOPER	+= IIF(l103910, IIF( MaFisFound("IT",Val((cAlias)->D1_ITEM)), MafisRet(Val((cAlias)->D1_ITEM),"LF_VALCONT"),0), (cAlias)->FT_VALCONT)
				CF8->CF8_BASPIS	+= nBasPis
				CF8->CF8_VALPIS	+= nValPis
				CF8->CF8_BASCOF	+= nBasCof	
				CF8->CF8_VALCOF	+= nValCof
			Endif
		
		EndIf
		MsUnLock()
		FkCommit()
		(cAlias)->(dbSkip())
		ConfirmSX8()
	Enddo
	(cAlias)->(dbCloseArea())
Endif

IF	lC1100450
	If cEntSai=="E"
		#IFDEF TOP

			If TcSrvType()<>"AS/400"

				lQuery 		:= .T.
				cAliasSD1	:= GetNextAlias()

				BeginSql Alias cAliasSD1
					COLUMN D1_DTDIGIT AS DATE
					COLUMN D1_DTFIMNT AS DATE

					SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,SF4.F4_CODINFC,SF4.F4_FORINFC
					FROM %table:SD1% SD1
					JOIN %Table:SF4% SF4 ON (SF4.F4_FILIAL=%xFilial:SF4% AND SD1.D1_TES = SF4.F4_CODIGO AND SF4.%NotDel%)
					WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
						SD1.D1_DOC = %Exp:cDoc% AND
						SD1.D1_SERIE = %Exp:cSerie% AND
						SD1.D1_FORNECE = %Exp:cClieFor% AND
						SD1.D1_LOJA = %Exp:cLoja% AND
						SF4.F4_CODINFC <> '' AND
						SD1.%NotDel%
					ORDER BY %Order:SD1%
				EndSql

				dbSelectArea(cAliasSD1)

			Endif
		#ENDIF

		IncProc(STR0065) //"Complementos por grupo de produto"

		Do While !((cAliasSD1)->(Eof()))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena o resultado da formula³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SM4")
			SM4->( DbSetOrder( 1 ))
			If SM4->( MsSeek( xFilial("SM4") + (cAliasSD1)->F4_FORINFC ) )
				If "SF1->F1_MENPAD + SF1->F1_MENNOTA" $ SM4->M4_FORMULA 
					cRetForm := SM4->M4_FORMULA
					cMenPad := SF1->F1_MENPAD
					cMenNota := SF1->F1_MENNOTA
					If SM4->( MsSeek( xFilial("SM4") + cMenPad ) ) .And. !Empty(cMenPad)
						cMenPad :=  ' '+ &(SM4->M4_FORMULA)
						cMenPad := Strtran(cRetForm ,"SF1->F1_MENPAD + SF1->F1_MENNOTA" ,cMenPad )
						cRetForm := (AllTrim(cMenNota) + cMenPad)
					Else 
						cRetForm := &(cRetForm)
					EndIf
				Else
					cRetForm := &(SM4->M4_FORMULA)
				EndIf	
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o item existe para altera-lo ou gravar um novo.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//³Informações Complementares por NF³
			dbSelectArea("CDT")
			CDT->(dbSetOrder(1))
			If	CDT->(MsSeek (xFilial ("CDT")+"E"+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->F4_CODINFC))
				If !Empty(Alltrim(cRetForm))
					RecLock("CDT",.F.)
					CDT->CDT_DCCOMP := cRetForm
					MsUnLock()
					FkCommit()
				EndIf
			Else
				RecLock("CDT",.T.)
				CDT->CDT_FILIAL := (cAliasSD1)->D1_FILIAL
				CDT->CDT_TPMOV  := "E"
				CDT->CDT_DOC    := (cAliasSD1)->D1_DOC
				CDT->CDT_SERIE  := (cAliasSD1)->D1_SERIE
				CDT->CDT_CLIFOR := (cAliasSD1)->D1_FORNECE
				CDT->CDT_LOJA   := (cAliasSD1)->D1_LOJA
				CDT->CDT_IFCOMP := (cAliasSD1)->F4_CODINFC
				CDT->CDT_DCCOMP := Alltrim(cRetForm)
				MsUnLock()
				FkCommit()
			EndIf

			(cAliasSD1)->(dbSkip())
		Enddo
		(cAliasSD1)->(dbCloseArea())
	Else

		#IFDEF TOP

			If TcSrvType()<>"AS/400"

				lQuery 		:= .T.
				cAliasSD2	:= GetNextAlias()

				BeginSql Alias cAliasSD2
					COLUMN D2_DTDIGIT AS DATE
					COLUMN D2_DTFIMNT AS DATE

					SELECT SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SF4.F4_CODINFC,SF4.F4_FORINFC
					FROM %table:SD2% SD2
					JOIN %Table:SF4% SF4 ON (SF4.F4_FILIAL=%xFilial:SF4% AND SD2.D2_TES = SF4.F4_CODIGO AND SF4.%NotDel%)
					WHERE SD2.D2_FILIAL = %xFilial:SD2% AND
						SD2.D2_DOC = %Exp:cDoc% AND
						SD2.D2_SERIE = %Exp:cSerie% AND
						SD2.D2_CLIENTE = %Exp:cClieFor% AND
						SD2.D2_LOJA = %Exp:cLoja% AND
						((SF4.F4_CODINFC <> '') OR
						(SF4.F4_FORINFC <> '')) AND
						SD2.%NotDel%
					ORDER BY %Order:SD2%
				EndSql

				dbSelectArea(cAliasSD2)

			Endif
		#ENDIF

		IncProc(STR0065) //"Complementos por grupo de produto"

		Do While !((cAliasSD2)->(Eof()))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena o resultado da formula³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRetForm := ""
			cMenPad := ""
			dbSelectArea("SM4")
			SM4->( DbSetOrder( 1 ))
			If SM4->( MsSeek( xFilial("SM4") + (cAliasSD2)->F4_FORINFC ) )
				If "SC5->C5_MENPAD" $ SM4->M4_FORMULA .AND. IsInCallStack("MAPVLNFS")
					cRetForm := SM4->M4_FORMULA
					cMenPad := SC5->C5_MENPAD
					If SM4->( MsSeek( xFilial("SM4") + cMenPad ) ) .And. !Empty(cMenPad)
						cMenPad := '"'+ &(SM4->M4_FORMULA) + '"'	
						cMenPad := Strtran(cRetForm ,"SC5->C5_MENPAD" ,cMenPad )
						cRetForm := &(cMenPad)
					Else 
						cRetForm := &(cRetForm)
					EndIf
				Else
					cRetForm := &(SM4->M4_FORMULA)
				EndIf	
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o item existe para altera-lo ou gravar um novo.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//³Informações Complementares por NF³
			dbSelectArea("CDT")
			CDT->(dbSetOrder(1))

			If	CDT->(MsSeek (xFilial ("CDT")+"S"+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->F4_CODINFC))
				If !Empty(Alltrim(cRetForm))
					RecLock("CDT",.F.)
					CDT->CDT_DCCOMP := cRetForm
					MsUnLock()
					FkCommit()
				EndIf
			Else
				RecLock("CDT",.T.)
				CDT->CDT_FILIAL := (cAliasSD2)->D2_FILIAL
				CDT->CDT_TPMOV  := "S"
				CDT->CDT_DOC    := (cAliasSD2)->D2_DOC
				CDT->CDT_SERIE  := (cAliasSD2)->D2_SERIE
				CDT->CDT_CLIFOR := (cAliasSD2)->D2_CLIENTE
				CDT->CDT_LOJA   := (cAliasSD2)->D2_LOJA
				CDT->CDT_IFCOMP := (cAliasSD2)->F4_CODINFC
				CDT->CDT_DCCOMP := Alltrim(cRetForm)
				MsUnLock()
				FkCommit()
			EndIf

			(cAliasSD2)->(dbSkip())
		Enddo
		(cAliasSD2)->(dbCloseArea())
	EndIf
EndIF

If cEntSai=="E"

	lQuery := .F.

	#IFDEF TOP

		If TcSrvType()<>"AS/400"

			lQuery 		:= .T.
			cAliasSD1	:= GetNextAlias()

			BeginSql Alias cAliasSD1

				SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,
					SD1.D1_NFORI,D1_SERIORI,SD1.D1_TIPO,SD1.D1_TES,SD1.D1_ORIGLAN

				FROM %table:SD1% SD1

				WHERE SD1.D1_FILIAL = %xFilial:SD1% AND
					SD1.D1_DOC = %Exp:cDoc% AND
					SD1.D1_SERIE = %Exp:cSerie% AND
					SD1.D1_FORNECE = %Exp:cClieFor% AND
					SD1.D1_LOJA = %Exp:cLoja% AND
					SD1.D1_NFORI <> %Exp:cBranco% AND
					SD1.%NotDel%
				ORDER BY %Order:SD1%
			EndSql

			dbSelectArea(cAliasSD1)

		Else

	#ENDIF
			cArqInd   := CriaTrab(Nil,.F.)
			cChave    := SD1->(IndexKey())
			cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .AND. '
			cCondicao += 'D1_DOC == "' + cDoc + '" .AND. '
			cCondicao += 'D1_SERIE == "' + cSerie + '" .AND. '
			cCondicao += 'D1_FORNECE == "' + cClieFor + '" .AND. '
			cCondicao += 'D1_LOJA == "' + cLoja + '" .AND. '
			cCondicao += '!EMPTY(D1_NFORI) .AND. !EMPTY(D1_SERIORI)'
			IndRegua(cAliasSD1,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAliasSD1)->(dbGotop())
			ProcRegua(LastRec())
	#IFDEF TOP
		Endif
	#ENDIF

	IncProc(STR0068) //"Documentos referenciados"

	Do While !((cAliasSD1)->(Eof()))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o cliente/fornecedor do documento original³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(dbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
		lAchouSF2 := .F.  // Forço a reinicialização da variável a cada passo do laço.

		If cTpNF $ "DB"
			SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			
			If lLoja .And. ; //Origem do LOJA (SIGALOJA)
				SF2->(dbSeek(xFilial("SF2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI)) .And. ; // Quando for devolução de cupom não deve ser utilizado campos de cliente e loja na busca
				aModNot(SF2->F2_ESPECIE) $ "02/59/65" // 02 - Cupom Fiscal  / 59 - SAT CF-E / 65 - NFC-e
				lAchouSF2 := .T.
			ElseIf !SF2->(dbSeek(xFilial("SF2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
				(cAliasSD1)->(dbSkip())
				Loop
			Else
				lAchouSF2 := .T.
			EndIf
		ElseIf SF4->F4_PODER3 == "D"
			If !SF2->(dbSeek(xFilial("SF2")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
				(cAliasSD1)->(dbSkip())
				Loop
			Else
				lAchouSF2 := .T.
			EndIf
		Else
			If !SF1->(dbSeek(xFilial("SF1")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
				(cAliasSD1)->(dbSkip())
				Loop
			Endif
		Endif

		if aModNot(SF2->F2_ESPECIE) $ "02/59/65" // quando se tratar de cupom fiscal como referencia, deve ser gravada a CDE
			CDE->(dbSetOrder(1)) // CDE_FILIAL, CDE_TPMOV, CDE_DOC, CDE_SERIE, CDE_CLIFOR, CDE_LOJA, CDE_CPREF, CDE_SERREF, CDE_PARREF, CDE_LOJREF
			if CDE->(dbSeek(xFilial("CDE")+cEntSai+cNfiscal+cSerie+cClieFor+cLoja+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA))
				RecLock("CDE", .F.)
			else
				RecLock("CDE", .T.)
				CDE->CDE_FILIAL := xFilial("CDE")
				CDE->CDE_TPMOV	:= cEntSai
				CDE->CDE_DOC	:= cNfiscal
				CDE->CDE_SERIE	:= cSerie
				CDE->CDE_CLIFOR := cClieFor
				CDE->CDE_LOJA	:= cLoja
			EndIf
			CDE->CDE_CPREF := (cAliasSD1)->D1_NFORI
			CDE->CDE_SERREF := (cAliasSD1)->D1_SERIORI

			If lAchouSF2
				CDE->CDE_PARREF := (cAliasSF2)->F2_CLIENTE
				CDE->CDE_LOJREF := (cAliasSF2)->F2_LOJA
			else 
				CDE->CDE_PARREF := (cAliasSF1)->F1_FORNECE
				CDE->CDE_LOJREF := (cAliasSF1)->F1_LOJA
			EndIf

			CDE->(MsUnlock())
		else
			CDD->(dbSetOrder(1)) //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF
			If CDD->(dbSeek(xFilial("CDD")+cEntSai+cNfiscal+cSerie+cClieFor+cLoja+(cAliasSD1)->(D1_NFORI+D1_SERIORI)+cClieFor+cLoja))
				RecLock("CDD",.F.)
			Else
				RecLock("CDD",.T.)
				CDD->CDD_FILIAL	:= xFilial("CDD")
				CDD->CDD_TPMOV	:= cEntSai
				CDD->CDD_DOC	:= cNfiscal
				CDD->CDD_SERIE	:= cSerie
				CDD->CDD_CLIFOR	:= cClieFor
				CDD->CDD_LOJA	:= cLoja
			Endif
			CDD->CDD_DOCREF := (cAliasSD1)->D1_NFORI
			CDD->CDD_SERREF := (cAliasSD1)->D1_SERIORI
			If lAchouSF2
				CDD->CDD_PARREF := (cAliasSF2)->F2_CLIENTE
				CDD->CDD_LOJREF := (cAliasSF2)->F2_LOJA
				CDD->CDD_CHVNFE := (cAliasSF2)->F2_CHVNFE
				If lCddMeaRf
					CDD->CDD_MEANRF	:= Alltrim(STRZERO(Month((cAliasSF2)->F2_EMISSAO),2)) + Alltrim(STR(YEAR((cAliasSF2)->F2_EMISSAO),4)) 
				Endif	
				If lCddMdaRf
					CDD->CDD_MODREF	:= aModnot((cAliasSF2)->F2_ESPECIE)
				Endif	
				If lCDDTMov
					CDD->CDD_ENTSAI := "2"
				Endif
			Else
				CDD->CDD_PARREF := (cAliasSF1)->F1_FORNECE
				CDD->CDD_LOJREF := (cAliasSF1)->F1_LOJA
				CDD->CDD_CHVNFE := (cAliasSF1)->F1_CHVNFE
				If lCddMeaRf
					CDD->CDD_MEANRF	:= Alltrim(STRZERO(Month((cAliasSF1)->F1_EMISSAO),2)) + Alltrim(STR(YEAR((cAliasSF1)->F1_EMISSAO),4)) 
				Endif	
				If lCddMdaRf
					CDD->CDD_MODREF	:= aModnot((cAliasSF1)->F1_ESPECIE)
				Endif
				If lCDDTMov
					CDD->CDD_ENTSAI := "1"
				Endif
			Endif
			
			CDD->(MsUnLock())
		Endif

		(cAliasSD1)->(dbSkip())
	Enddo

	If !lQuery
		RetIndex("SD1")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	Endif

Else
	lQuery := .F.

	#IFDEF TOP

		If TcSrvType()<>"AS/400"

			lQuery 		:= .T.
			cAliasSD2	:= GetNextAlias()

			BeginSql Alias cAliasSD2

				SELECT SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,
					SD2.D2_NFORI,SD2.D2_SERIORI,SD2.D2_TIPO,SD2.D2_TES

				FROM %table:SD2% SD2

				WHERE SD2.D2_FILIAL = %xFilial:SD2% AND
					SD2.D2_DOC = %Exp:cDoc% AND
					SD2.D2_SERIE = %Exp:cSerie% AND
					SD2.D2_CLIENTE = %Exp:cClieFor% AND
					SD2.D2_LOJA = %Exp:cLoja% AND
					SD2.D2_NFORI <> %Exp:cBranco% AND
					SD2.%NotDel%
				ORDER BY %Order:SD2%
			EndSql

			dbSelectArea(cAliasSD2)

		Else

	#ENDIF
			cArqInd   := CriaTrab(Nil,.F.)
			cChave    := SD2->(IndexKey())
			cCondicao := 'D2_FILIAL == "' + xFilial("SD2") + '" .AND. '
			cCondicao += 'D2_DOC == "' + cDoc + '" .AND. '
			cCondicao += 'D2_SERIE == "' + cSerie + '" .AND. '
			cCondicao += 'D2_CLIENTE == "' + cClieFor + '" .AND. '
			cCondicao += 'D2_LOJA == "' + cLoja + '" .AND. '
			cCondicao += '!EMPTY(D2_NFORI) .AND. !EMPTY(D2_SERIORI)'
			IndRegua(cAliasSD2,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAliasSD2)->(dbGotop())
			ProcRegua(LastRec())
	#IFDEF TOP
		Endif
	#ENDIF

	Do While !((cAliasSD2)->(Eof()))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o cliente/fornecedor do documento original³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(dbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
		lAchouSF1 := .F.  // Forço a reinicialização da variável a cada passo do laço.

		If cTpNF $ "DB"
			If !SF1->(dbSeek(xFilial("SF1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				(cAliasSD2)->(dbSkip())
				Loop
			Else
				lAchouSF1 := .T.
			Endif
		ElseIf SF4->F4_PODER3 == "D"
			If !SF1->(dbSeek(xFilial("SF1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				(cAliasSD2)->(dbSkip())
				Loop
			Else
				lAchouSF1 := .T.
			Endif
		Else
			If !SF2->(dbSeek(xFilial("SF2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				(cAliasSD2)->(dbSkip())
				Loop
			Endif
		Endif

		CDD->(dbSetOrder(1)) //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF
		If CDD->(dbSeek(xFilial("CDD")+cEntSai+cDoc+cSerie+cClieFor+cLoja+(cAliasSD2)->(D2_NFORI+D2_SERIORI)+cClieFor+cLoja))
			RecLock("CDD",.F.)
		Else
			RecLock("CDD",.T.)
			CDD->CDD_FILIAL	:= xFilial("CDD")
			CDD->CDD_TPMOV	:= cEntSai
			CDD->CDD_DOC	:= cDoc
			CDD->CDD_SERIE	:= cSerie
			CDD->CDD_CLIFOR	:= cClieFor
			CDD->CDD_LOJA	:= cLoja
		Endif
		CDD->CDD_DOCREF := (cAliasSD2)->D2_NFORI
		CDD->CDD_SERREF := (cAliasSD2)->D2_SERIORI
		If lAchouSF1
			CDD->CDD_PARREF := (cAliasSF1)->F1_FORNECE
			CDD->CDD_LOJREF := (cAliasSF1)->F1_LOJA
			CDD->CDD_CHVNFE := (cAliasSF1)->F1_CHVNFE
			If lCDDTMov
				CDD->CDD_ENTSAI := "1"
			Endif
			If lCddMeaRf
				CDD->CDD_MEANRF	:= Alltrim(STRZERO(Month((cAliasSF1)->F1_EMISSAO),2)) + Alltrim(STR(YEAR((cAliasSF1)->F1_EMISSAO),4)) 
			Endif	
			If lCddMdaRf
				CDD->CDD_MODREF	:= aModnot((cAliasSF1)->F1_ESPECIE)
			Endif
		Else
			CDD->CDD_PARREF := (cAliasSF2)->F2_CLIENTE
			CDD->CDD_LOJREF := (cAliasSF2)->F2_LOJA
			CDD->CDD_CHVNFE := (cAliasSF2)->F2_CHVNFE
			If lCDDTMov
				CDD->CDD_ENTSAI := "2"
			Endif
			If lCddMeaRf
				CDD->CDD_MEANRF	:= Alltrim(STRZERO(Month((cAliasSF2)->F2_EMISSAO),2)) + Alltrim(STR(YEAR((cAliasSF2)->F2_EMISSAO),4)) 
			Endif	
			If lCddMdaRf
				CDD->CDD_MODREF	:= aModnot((cAliasSF2)->F2_ESPECIE)
			Endif
		Endif
		MsUnLock()

		(cAliasSD2)->(dbSkip())
	Enddo

	If !lQuery
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	Endif

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para atualizar dados nas tabelas   ³
//³ de complementos do SPED                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("MATUCOMP")
	ExecBlock("MATUCOMP",.f.,.f.,aChave)
EndIf

RestArea(aAreaSF1)
RestArea(aAreaSF2)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA926   ºAutor  ³Mary C. Hergert     º Data ³  09/29/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Identifica se a nota fiscal eh de remessa para exportacao   º±±
±±º          ³para habilitar a tela de complementos                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A926ExpInd(cDoc,cSerie,cClieFor,cLoja)

Local cCFOPInd 	:= GetNewPar("MV_EXPIND","5501/5502/6501/6502")
Local cAliasSF3	:= "SF3"

Local lRet		:= .F.

#IFDEF TOP

	If TcSrvType()<>"AS/400"

		cCFOPInd := StrTran(cCFOPInd,"/",",")
		cCFOPInd := Alltrim(cCFOPInd)
		If Right(cCFOPInd,1) == ","
			cCFOPInd := SubStr(cCFOPInd,1,Len(cCFOPInd)-1)
		Endif
		cCFOPInd := StrTran(cCFOPInd,",","','")
		cCFOPInd := "'" + cCFOPInd + "'"
		cCFOPInd := "(" + cCFOPInd + ")"
		cCFOPInd := "%" + cCFOPInd + "%"

		cAliasSF3 := GetNextAlias()

		BeginSql Alias cAliasSF3

			SELECT SF3.F3_FILIAL,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA,
				SF3.F3_CFO

			FROM %table:SF3% SF3

			WHERE SF3.F3_FILIAL = %xFilial:SF3% AND
				SF3.F3_NFISCAL = %Exp:cDoc% AND
				SF3.F3_SERIE = %Exp:cSerie% AND
				SF3.F3_CLIEFOR = %Exp:cClieFor% AND
				SF3.F3_LOJA = %Exp:cLoja% AND
				SF3.F3_CFO IN %Exp:cCFOPInd%

			ORDER BY %Order:SF3%
		EndSql

		dbSelectArea(cAliasSF3)

	Else

#ENDIF
		cArqInd   := CriaTrab(Nil,.F.)
		cChave    := SF3->(IndexKey())
		cCondicao := 'F3_FILIAL == "' + xFilial("SF3") + '" .AND. '
		cCondicao += 'F3_NFISCAL == "' + cDoc + '" .AND. '
		cCondicao += 'F3_SERIE == "' + cSerie + '" .AND. '
		cCondicao += 'F3_CLIEFOR == "' + cClieFor + '" .AND. '
		cCondicao += 'F3_LOJA == "' + cLoja + '" .AND. '
		cCondicao += 'ALLTRIM(F3_CFO) $ "' + cCFOPInd + '"'
		IndRegua(cAliasSF3,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		(cAliasSF3)->(dbGotop())
#IFDEF TOP
	Endif
#ENDIF

Do While ! (cAliasSF3)->(Eof())
	lRet := .T.
	Exit
Enddo
RetIndex("SF3")
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926AnfC  ³ Autor ³ Luciana Pires         ³ Data ³ 13/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha Compl. Anfavea (Cabecalho)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926AnfC(oGetAnf,aObrigat,lFinal)

Local aCols		:= oGetAnf:aCols
Local aPos		:= {}

Local lRet		:= .T.
Local lObrigat	:= .F.

Local nX		:= 0
Local nAt		:= oGetAnf:nAt

aAdd(aPos,aScan(aHAnfC,{|x| Alltrim(x[2])=="CDR_VERSAO"}))
aAdd(aPos,aScan(aHAnfC,{|x| Alltrim(x[2])=="CDR_CDTRAN"}))
aAdd(aPos,aScan(aHAnfC,{|x| Alltrim(x[2])=="CDR_NMTRAN"}))
aAdd(aPos,aScan(aHAnfC,{|x| Alltrim(x[2])=="CDR_CDRECP"}))
aAdd(aPos,aScan(aHAnfC,{|x| Alltrim(x[2])=="CDR_NMRECP"}))
aAdd(aPos,aScan(aHAnfC,{|x| Alltrim(x[2])=="CDR_CDENT"}))
aAdd(aPos,aScan(aHAnfC,{|x| Alltrim(x[2])=="CDR_DTENT"}))
aAdd(aPos,aScan(aHAnfC,{|x| Alltrim(x[2])=="CDR_NUMINV"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHAnfC)+1])
	If M926Obrig(aObrigat,aHAnfC,aCols[nAt],16)
		lObrigat := .T.
	Endif
Endif

For nX := 1 to Len(aCols)
	If !(aCols[nX][Len(aHAnfC)+1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			lObrigat := M926Obrig(aObrigat,aHAnfC,aCols[nX],16)
		Endif
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926AnfObr")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926AnfI  ³ Autor ³ Luciana Pires         ³ Data ³ 13/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha Compl. Anfavea (Itens)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926AnfI(oGetAnf,aObrigat,lFinal)

Local aCols		:= oGetAnf:aCols
Local aPos		:= {}

Local lRet		:= .T.
Local lObrigat	:= .F.

Local nX		:= 0
Local nAt		:= oGetAnf:nAt

aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_PEDCOM"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_SGLPED"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_SEPPEN"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_TPFORN"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_UM"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_DTVALI"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_PEDREV"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_CDPAIS"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_PBRUTO"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_PLIQUI"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_TPCHAM"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_NUMCHA"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_DTCHAM"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_QTDEMB"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_QTDIT"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_LOCENT"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_PTUSO"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_TPTRAN"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_LOTE"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_CPI"}))
aAdd(aPos,aScan(aHAnfI,{|x| Alltrim(x[2])=="CDS_CDITEM"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHAnfI)+1])
	If M926Obrig(aObrigat,aHAnfI,aCols[nAt],17)
		lObrigat := .T.
	Endif
Endif

For nX := 1 to Len(aCols)
	If !(aCols[nX][Len(aHAnfI)+1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
		//³(somente quando for validacao do ok da rotina)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			lObrigat := M926Obrig(aObrigat,aHAnfI,aCols[nX],17)
		Endif
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926AnfObr")
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M926Res   ³ Autor ³ Mary C. Hergert       ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua as validacoes da linha de ressarcimento             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto que contem a get dados                      ³±±
±±³Parametros³ ExpA2 = Array com os campos obrigatorios                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nao ha.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M926Res(oGetRes,aObrigat)

Local aColsR	:= oGetRes:aCols

Local lRet		:= .T.
Local lObrigat	:= .F.

Local nX		:= 0

For nX := 1 to Len(aColsR)
	If !(aColsR[nX][Len(aHRes)+1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo obrigatorio nao foi digitado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M926Obrig(aObrigat,aHRes,aColsR[nX],1)
			lObrigat := .T.
		Endif
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa se existe algum campo obrigatorio que nao foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lObrigat
	Help("  ",1,"A926ResObr")
	lRet := .F.
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ImpQrySD1 | Autor ³Luccas Curcio                 ³ Data ³09/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Query da Tabela SD1 para Complemento de Importacao           		 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ImpQrySD1(cDoc,cSerie,cClieFor,cLoja,cAlsD1Imp,lQuery,cArqInd,,	 ³±±
±±³			 ³cChave,cCondicao)								 					 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³cDoc -> Numero do Documento                   					 ³±±
±±³          ³cSerie -> Serie do Documento             							 ³±±
±±³ 		 ³cClieFor  -> Codigo do cliente ou fornecedor           			 ³±±
±±³          ³cLoja -> Codigo da Loja do Cliente ou Fornecedor			 		 ³±±
±±³			 ³cAlsD1Imp   -> Alias do arquivo para a tabela SD1        			 ³±±
±±³          ³lQuery  -> Flag se o ambiente eh top ou nao                        ³±±
±±³          |cArqInd -> Indice de arqui (ambiente DBF)                     	 ³±±
±±³          ³cChave -> Chave para criacao do arquivo (ambiente DBF)			 ³±±
±±³          ³cCondicao  -> Condicao para criacao do arquivo (ambiente DBF)		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - MATA926                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpQrySD1(cDoc,cSerie,cClieFor,cLoja,cAlsD1Imp,lQuery,cArqInd,cChave,cCondicao)
Default	lQuery		:= .F.
Default	cArqInd		:= ""
Default	cChave		:= ""
Default	cCondicao	:= ""

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery 		:= .T.
			cAlsD1Imp	:= GetNextAlias()
			BeginSql Alias cAlsD1Imp
				SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_ITEM,SD1.D1_COD
				FROM %table:SD1% SD1
				WHERE SD1.D1_FILIAL = %xFilial:SFT% AND
					SD1.D1_DOC 		= %Exp:cDoc% AND
					SD1.D1_SERIE 	= %Exp:cSerie% AND
					SD1.D1_FORNECE 	= %Exp:cClieFor% AND
					SD1.D1_LOJA 	= %Exp:cLoja% AND
					SD1.%NotDel%
				ORDER BY %Order:SD1%
			EndSql
			dbSelectArea(cAlsD1Imp)
		Else
	#ENDIF
			cArqInd   := CriaTrab(Nil,.F.)
			cChave    := SD1->(IndexKey())
			cCondicao := 'D1_FILIAL == "' + xFilial("SD1") + '" .AND. '
			cCondicao += 'D1_DOC == "' + cDoc + '" .AND. '
			cCondicao += 'D1_SERIE == "' + cSerie + '" .AND. '
			cCondicao += 'D1_FORNECE == "' + cClieFor + '" .AND. '
			cCondicao += 'D1_LOJA == "' + cLoja + '"'
			IndRegua(cAlsD1Imp,cArqInd,cChave,,cCondicao,STR0002) //"Selecionado registros"
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			(cAlsD1Imp)->(dbGotop())
	#IFDEF TOP
		Endif
	#ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A926VldPrdºAutor  ³Rodrigo Aguilar     º Data ³  10/05/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada pela consulta padrao SD1PRD, esta consultaº±±
±±º          ³ eh utilizada no campo CDL_PRDORI para buscar os produtos   º±±
±±º          ³ referentes a nota fiscal de origem na rotina de complementoº±±
±±º          ³ de exportacao                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAlias - String para filtro na consulta padrao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cRet - String para filtro na consulta padrao               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA926                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A926VldPrd(cAlias)

Local cRet := " "
Local cFil := xFilial(cAlias)

Default cAlias := ""

If cAlias == "SD1"
	cRet := '@#D1_FILIAL=="'+cFil+'" .And. D1_DOC=="'+aCols[N,17]+'" .And. D1_SERIE=="'+aCols[N,18]+'" .And. D1_FORNECE=="'+aCols[N,15]+'" .And. D1_LOJA=="'+aCols[N,16]+'"@#'
ElseIf cAlias == "SD2"
	cRet := '@#D2_FILIAL=="'+cFil+'" .And. D2_DOC=="'+SF2->F2_DOC+'" .And. D2_SERIE=="'+SF2->F2_SERIE+'" .And. D2_CLIENTE=="'+SF2->F2_CLIENTE+'" .And. D2_LOJA=="'+SF2->F2_LOJA+'"@#'
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A926VCmPrdºAutor  ³Rodrigo Aguilar     º Data ³  10/05/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada pelo Valid dos campos CDL_ITEORI e        º±±
±±º          ³ CDL_ITEMNF para verificar se o item informado existe no    º±±
±±º          ³ documento fiscal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAlias - String para filtro na consulta padrao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cRet - String para filtro na consulta padrao               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA926                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A926VCmPrd(cAlias)

Local lRet := .F.

Default cAlias := ""

If cAlias == "SD1"
	lRet := ( Padr(M->CDL_ITEORI,TamSx3("D1_ITEM")[1]) == Posicione("SD1",1,xFilial("SD1")+aCols[N,17]+aCols[N,18]+aCols[N,15]+aCols[N,16]+aCols[N,19]+M->CDL_ITEORI,"D1_ITEM" ) )
ElseIf cAlias == "SD2"
	lRet := ( Padr(M->CDL_ITEMNF,TamSx3("D2_ITEM")[1]) == Posicione("SD2",3,xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)+aCols[N,1]+M->CDL_ITEMNF,"D2_ITEM" ) )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} M926Msgm
Funcao generica que gera a mensagem de alerta a ser apresentada nas validacoes
de complementos fiscais

@param	aInfMsgm -> Array contendo as informacoes que deverao ser apresentadas na tela
		cTab -> Tabela que esta sendo validada

@return cRet -> Texto a ser apresentado

@author Luccas Curcio
@since 21/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function M926Msgm(aInfMsgm,cTab)
Local	nX		:=	0
Local	cRet	:=	""

//Exportacao
If cTab == "CDL"

	For nX := 1 To Len(aInfMsgm)

		cRet := Alltrim("[Item:"+aInfMsgm[nX][1]+"] [Doc:"+aInfMsgm[nX][2]+"] [Ser:"+SubStr(aInfMsgm[nX][3],1,3)+"] [Forn:"+aInfMsgm[nX][4]+"] [Loja:"+aInfMsgm[nX][5]+"]"+CRLF)

	Next nX

Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cBoxVTrans

Cria opcoes para o campo CD5_VTRANS

@return cRet -> Texto a ser apresentado

@author Natalia Sartori
@since 29/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function cBoxVTrans()

Local nI	:= 0
Local cRet	:= ""
Local aOpc	:= {}

AADD(aOpc,"1 =Marítima")
AADD(aOpc,"2 =Fluvial")
AADD(aOpc,"3 =Lacustre")
AADD(aOpc,"4 =Aérea")
AADD(aOpc,"5 =Postal")
AADD(aOpc,"6 =Ferroviária")
AADD(aOpc,"7 =Rodoviária")
AADD(aOpc,"8 =Conduto")
AADD(aOpc,"9 =Meios próprios")
AADD(aOpc,"10=Entrada/Saída ficta")
AADD(aOpc,"11=Courier")
AADD(aOpc,"12=Handcarry")
AADD(aOpc,"13=Por Reboque")

For nI:=1 To Len(aOpc)
	cRet += IIf(empty(cRet),'',';') + aOpc[nI]
Next

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} M926Rastr

Funcao de validacao para o complemento de rastreabilidade.

@return cRet -> Texto a ser apresentado

@author joao.pellegrini
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function M926Rastr(oGetRastr,cDoc,cSerie,cEspecie,cClieFor,cLoja,cEntSai,cTpNF,aObrigat,lFinal,aRastr)

Local aCols		:= oGetRastr:aCols
Local aItens	:= {}
Local aPos		:= {}

Local lRet		:= .T.
Local lDuplica	:= .F.
Local lItem		:= .F.
Local lObrigat	:= .F.
Local lGrupo 	:= .F.

Local nX		:= 0
Local nAt		:= oGetRastr:nAt

SFT->(dbSetOrder(1))

aAdd(aPos,aScan(aHRastr,{|x| Alltrim(x[2])=="F0A_ITEM"}))
aAdd(aPos,aScan(aHRastr,{|x| Alltrim(x[2])=="F0A_COD"}))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se algum campo obrigatorio nao foi digitado³
//³(apenas da linha que esta sendo manipulada - aT)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFinal .And. !(aCols[nAt][Len(aHRastr)+1])

	If M926Obrig(aObrigat,aHRastr,aCols[nAt],8)
		lObrigat := .T.
	Endif

Endif

For nX := 1 to Len(aCols)

	If !(aCols[nX][Len(aHRastr)+1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacoes do ok da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se algum campo obrigatorio nao foi digitado em todos os itens³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M926Obrig(aObrigat,aHRastr,aCols[nX],8)
				lObrigat := .T.
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence a nota fiscal que esta sendo complementada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SFT->(dbSeek(xFilial("SFT")+cEntSai+cSerie+cDoc+cClieFor+cLoja+aCols[nX][aPos[1]]+aCols[nX][aPos[2]]))
			lItem := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido pertence ao grupo de rastreabilidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(aScan(aRastr,{|x| x[1] == xFilial("F0A") .And. ;
			x[2] == cDoc .And. ;
			x[3] == cSerie .And.;
			x[4] == cClieFor .And. ;
			x[5] == cLoja .And.;
			x[6] == cEntSai .And.;
			x[7] == aCols[nX][aPos[1]] .And.;
			x[8] == aCols[nX][aPos[2]]}) > 0)
			lGrupo := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item inserido nao esta em duplicidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aItens,{|x| x == aCols[nX][aPos[1]]}) > 0
			lDuplica := .T.
		Endif

		aAdd(aItens,aCols[nX][aPos[1]])

	Endif

Next

If lDuplica
	Help("  ",1,"A926Dupl")
	lRet := .F.
Endif

If lItem
	Help("  ",1,"A926Itens")
	lRet := .F.
Endif

If lGrupo
	Help("  ",1,"A926Grupo")
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MT926VLD
Validacao de campos (preocessos referenciados).
@return	lRet
@author	Paulo Krüger
@since	19/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function MT926VLD(cFilOri, cCampo)

Local lRet		    :=	.T.
Local lContinua	    :=	.F.
Local cAlias00	    :=	''
Local cAlias01	    :=	''
Local cNumero		:=	''
Local cTipo		    :=	''
Local cItem		    :=	''
Local cFilDoc		:=	''
Local cNumDoc		:=	''
Local cSerDoc		:=	''
Local cTipDoc		:=	''
Local cItmDoc		:=	''
Local cFornece	    :=  ''
Local cLojaFor	    :=	''
Local nPosProces	:=	0
Local nPosTipo	    :=	0
Local nPosItProc	:=	0
Local aArea		    :=	{}
Local cNFOri		:=  ''

If !(Type('cOriNF') == "C")
	cNFOri := Iif(IsInCallStack('T521TELA'), "S", "")
Else
	cNFOri := cOriNF
EndIf

aArea := GetArea()

nPosProces 	:= AScan(aHeader,{|x| AllTrim(x[2])=="CDG_PROCES"})
nPosTipo 	:= AScan(aHeader,{|x| AllTrim(x[2])=="CDG_TPPROC"})
nPosItProc	:= AScan(aHeader,{|x| AllTrim(x[2])=="CDG_ITPROC"})

cNumero		:= If(ReadVar() == 'M->CDG_PROCES',&(ReadVar()),aCols[n][nPosProces])
cTipo		:= If(ReadVar() == 'M->CDG_TPPROC',&(ReadVar()),aCols[n][nPosTipo]  )
cItem		:= If(ReadVar() == 'M->CDG_ITPROC',&(ReadVar()),aCols[n][nPosItProc])

If AllTrim(cCampo)		== 'M->CDG_PROCES'
	If !Empty(cTipo)	.and.	!Empty(cItem)
		lContinua := .T.
	EndIf
ElseIf AllTrim(cCampo)	== 'M->CDG_TPPROC'
	If !Empty(cNumero)	.and.	!Empty(cItem)
		lContinua := .T.
	EndIf
ElseIf AllTrim(cCampo)	== 'M->CDG_ITPROC'
	If !Empty(cNumero)	.and.	!Empty(cTipo)
		lContinua := .T.
	EndIf
EndIf

If AllTrim(cCampo)		== 'M->CDG_ITEM'
		lContinua := .T.
EndIf

If lContinua

	If cNFOri == 'S'
		//Consiste ítem da Nota Fiscal de Saída
		If AllTrim(cCampo) == 'M->CDG_ITEM'

			If AllTrim(M->CDG_ITEM) <> '*'

				cFilDoc	:=	SF2->F2_FILIAL
				cNumDoc	:=	SF2->F2_DOC
				cSerDoc	:=	SF2->F2_SERIE
				cTipDoc :=	SF2->F2_TIPO
				cItmDoc :=	AllTrim(&cCampo)

				cAlias00 := GetNextAlias()

				BeginSql Alias cAlias00

				SELECT	SD2.D2_ITEM ITEM
				FROM	%Table:SD2% SD2
				WHERE	SD2.%notDel%
					AND SD2.D2_FILIAL	=	%Exp:cFilDoc%
					AND SD2.D2_DOC		=	%Exp:cNumDoc%
					AND SD2.D2_SERIE	=	%Exp:cSerDoc%
					AND SD2.D2_TIPO		=	%Exp:cTipDoc%
					AND SD2.D2_ITEM		=	%Exp:cItmDoc%
				EndSql

				(cAlias00)->(DbGoTop())

				If (cAlias00)->(Eof())
					MsgAlert(STR0085 + ' ' + cItmDoc + ' ' + STR0088 + cNumDoc + ' ' + STR0089 + ' '  + cSerDoc + ' ' + STR0084 + ' ' + cTipDoc + ' ' + STR0087, STR0090) //Item / da Nota Fiscal: / Série: / Tipo: / não cadastrado. / Item de Nota Fiscal incorreto!
					lRet := .F.
				EndIf

				lContinua := .F.
				(cAlias00)->(DbCloseArea())

			EndIf
		EndIf
	ElseIf cNFOri == 'E'
		//Consiste ítem da Nota Fiscal de Entrada
		If AllTrim(cCampo) == 'M->CDG_ITEM'

			If AllTrim(M->CDG_ITEM) <> '*'

				cFilDoc	:=	SF1->F1_FILIAL
				cNumDoc	:=	SF1->F1_DOC
				cSerDoc	:=	SF1->F1_SERIE
				cTipDoc :=	SF1->F1_TIPO
				cFornece:=  SF1->F1_FORNECE
				cLojaFor:=	SF1->F1_LOJA

				cItmDoc :=	AllTrim(&cCampo)

				cAlias00 := GetNextAlias()

				BeginSql Alias cAlias00

				SELECT	SD1.D1_ITEM ITEM
				FROM	%Table:SD1% SD1
				WHERE	SD1.%notDel%
					AND SD1.D1_FILIAL	=	%Exp:cFilDoc%
					AND SD1.D1_DOC		=	%Exp:cNumDoc%
					AND SD1.D1_SERIE	=	%Exp:cSerDoc%
					AND SD1.D1_TIPO		=	%Exp:cTipDoc%
					AND SD1.D1_ITEM		=	%Exp:cItmDoc%
					AND SD1.D1_FORNECE	=	%Exp:cFornece%
					AND SD1.D1_LOJA		=	%Exp:cLojaFor%

				EndSql

				(cAlias00)->(DbGoTop())

				If (cAlias00)->(Eof())
					MsgAlert(STR0085 + ' ' + cItmDoc + ' ' + STR0088 + ' ' + cNumDoc + ' ' + STR0089 + ' '  + cSerDoc + ' ' + STR0084 + ' ' + cTipDoc + ' ' + STR0087, STR0090) //Item / da Nota Fiscal: / Série: / Tipo: / não cadastrado. / Item de Nota Fiscal incorreto!
					lRet := .F.
				EndIf

				lContinua := .F.
				(cAlias00)->(DbCloseArea())
			EndIf
		EndIf
	EndIf

	If lContinua

		If CCF->(FieldPos('CCF_IDITEM')) > 0

			//Consiste demais ítens do grid
			cAlias01 := GetNextAlias()

			BeginSql Alias cAlias01

			SELECT	CCF_NUMERO NUMPROC
			FROM	%Table:CCF% CCF
			WHERE	CCF.%notDel%
				AND CCF.CCF_FILIAL	=	%Exp:cFilOri%
				AND CCF.CCF_NUMERO	=	%Exp:cNumero%
				AND CCF.CCF_TIPO	=	%Exp:cTipo%
				AND CCF.CCF_IDITEM	=	%Exp:cItem%
			EndSql

			(cAlias01)->(DbGoTop())

			If (cAlias01)->(Eof())
				MsgAlert(STR0082 + ' ' + cFilOri + ' ' + STR0083 + ' ' + cNumero + ' ' + STR0084 + ' ' + cTipo + ' ' + STR0085 + ' ' + cItem + ' ' + STR0087, STR0086) // Filial: / Processo: / Tipo: / Item: / não cadastrado / Processos referenciados não cadastrados!
				lRet := .F.
			EndIf

			(cAlias01)->(DbCloseArea())

		EndIf

	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AJUSTMODL2
Ajusta base para manipulação em Modelo2.
@author Paulo Krüger
@since 15/02/2018
/*/
//-------------------------------------------------------------------

Static Function AJUSTMODL2()

Local cAlias00	:= ''
Local cAlias01	:= ''
Local cItem		:= ''
Local nTamItem	:= 0
Local nQtdReg	:= 0

If CCF->(FieldPos('CCF_IDITEM')) == 0
	Return
EndIf

nTamItem := TamSX3('CCF_IDITEM')[01]
cItem	 := Space(nTamItem)
//Calcula quantidade de registros a serem compatibilizados

cAlias00 := GetNextAlias()
BeginSql Alias cAlias00
SELECT	COUNT(*) NREG
FROM	%Table:CCF% CCF
WHERE			CCF.%notDel%
		AND		CCF_IDITEM	= %Exp:cItem%
EndSql

(cAlias00)->(DbGoTop())

nQtdReg := (cAlias00)->(NREG)

(cAlias00)->(DbCloseArea())

If nQtdReg > 0

	ProcRegua(nQtdReg)

	cAlias01 := GetNextAlias()
	BeginSql Alias cAlias01
	SELECT	CCF.R_E_C_N_O_	RECNO
	FROM	%Table:CCF% CCF
	WHERE			CCF.%notDel%
			AND		CCF_IDITEM	= %Exp:cItem%
	EndSql

	(cAlias01)->(DbGoTop())

	While (cAlias01)->(!Eof())

		IncProc(STR0010) //Compatibilizando base de dados.

		CCF->(dBGoTo((cAlias01)->RECNO))

		RecLock('CCF',.F.)

		CCF->CCF_IDITEM := StrZero(1,nTamItem)

		CCF->(MsUnLock())

		(cAlias01)->(dBSkip())

	EndDo
	(cAlias01)->(DbCloseArea())

EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AJUSTITCDG
Ajusta tabela CDG (Processos refer. no documento) para ítens de processos relacionados.
@author Paulo Krüger
@since 15/02/2018
/*/
//-------------------------------------------------------------------

Static Function AJUSTITCDG()

Local cAlias00	:= ''
Local cAlias01	:= ''
Local cItem		:= ''
Local nTamItPr	:= 0
Local nQtdReg	:= 0

If CDG->(FieldPos('CDG_ITPROC')) > 0
	nTamItPr := TamSX3('CDG_ITPROC')[01]
EndIf

cItem	 := Space(nTamItPr)
//Calcula quantidade de registros a serem compatibilizados
cAlias00 := GetNextAlias()
BeginSql Alias cAlias00
SELECT	COUNT(*) NREG
FROM	%Table:CDG% CDG
WHERE			CDG.%notDel%
		AND		CDG_ITEM	= %Exp:cItem%
EndSql

(cAlias00)->(DbGoTop())

nQtdReg := (cAlias00)->(NREG)

(cAlias00)->(DbCloseArea())

If nQtdReg > 0

	ProcRegua(nQtdReg)

	cAlias01 := GetNextAlias()
	BeginSql Alias cAlias01
	SELECT	CDG.R_E_C_N_O_	RECNO
	FROM	%Table:CDG% CDG
	WHERE			CDG.%notDel%
			AND		CDG_ITEM	= %Exp:cItem%
	EndSql

	(cAlias01)->(DbGoTop())

	While (cAlias01)->(!Eof())

		IncProc(STR0010) //Compatibilizando base de dados.

		CDG->(dBGoTo((cAlias01)->RECNO))

		RecLock('CDG',.F.)

		CDG->CDG_ITEM	:= '*'
		CDG->CDG_ITPROC	:= StrZero(1,nTamItPr)

		CDG->(MsUnLock())

		(cAlias01)->(dBSkip())

	EndDo
	(cAlias01)->(DbCloseArea())

EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MT926NTPOS
Retorna variáveis da Nota em Tela
@author Paulo Krüger
@since 21/02/2018
/*/
//-------------------------------------------------------------------

Function MT926NTPOS()

Local  aArray := ()

	aArray := ARRAY(5)

	aArray[01] := cDocStat
	aArray[02] := cSerStat
	aArray[03] := cEspStat
	aArray[04] := cCliStat
	aArray[05] := cLojStat

Return(aArray)


//-------------------------------------------------------------------
/*/{Protheus.doc} MT926PRPOS
Posiciona processo referenciado
@author Paulo Krüger
@since 21/02/2018
/*/
//-------------------------------------------------------------------

Function MT926PRPOS(cFilOri, cProcess, cTpProces, cItProces)

Local	cAlias01	:=	''
Local	cRet		:=	''

If CCF->(FieldPos('CCF_IDITEM')) == 0
	Return(cRet)
EndIf

cAlias01 := GetNextAlias()
BeginSql Alias cAlias01
SELECT	CCF_DESCJU DESCRI
FROM	%Table:CCF% CCF
WHERE			CCF.%notDel%
		AND		CCF_FILIAL	= %Exp:cFilOri%
		AND		CCF_NUMERO	= %Exp:cProcess%
		AND		CCF_TIPO	= %Exp:cTpProces%
		AND		CCF_IDITEM	= %Exp:cItProces%
EndSql
(cAlias01)->(DbGoTop())

If	(cAlias01)->(!Eof())
	cRet := (cAlias01)->DESCRI
Else
	cRet := Space(TamSX3('CDG_DESCCF')[01])
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetParam
Pesquisa parametros
@author Vicco
@since 19/12/2018
/*/
//-------------------------------------------------------------------
Static Function GetParam(cParam)
Local cRet := ""

Default cParam := ""

DbSelectArea("SX6")
SX6->(DbSetOrder(1))
If (SX6->(DbSeek(xFilial("SX6")+cParam)))
	Do While !SX6->(Eof()) .And. xFilial("SX6")==SX6->X6_FIL .And. cParam$SX6->X6_VAR
		If !Empty(SX6->X6_CONTEUD)
			cRet += "/" + AllTrim(SX6->X6_CONTEUD)
		EndIf
		SX6->(DbSkip())
	EndDo
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTable
Pesquisa tabela genericas
@author Vicco
@since 19/12/2018
/*/
//-------------------------------------------------------------------
Static Function GetTable(cTabela)
Local cRet 		:= ""
Local nX   		:= 0
Local aDadosSX5 := {}

Default cTabela := ""

aDadosSX5 := FWGetSX5(cTabela)

For nX := 1 to Len(aDadosSX5)
  
  cRet += "/"+Alltrim(aDadosSX5[nX][3])

Next nX

Return cRet

/*/
Função: DescMun
Autor: Rafael Oliveira
Descrição: Preenche a descricao do Municipio

Parametros: cCodMun  = Codigo do Municipio
           oDescMun = Objeto da descricao ddo Municipio
           cDescMun = Descricao do Municipio
           cUF      = UF do Municipio

/*/
Static Function DescMun(cCodMun,oDescMun,cDescMun,cUF)
Local lRet := .T.

If !Empty(cCodMun) 	
	CC2->(dbSetOrder(1))
	lRet := CC2->(MsSeek(xFilial("CC2")+cUF+cCodMun))	
	
	If lRet
		cDescMun:= CC2->CC2_MUN
		oDescMun:Refresh()
	Else   
		Help("",1,"NOTEXISTMUN",,"Municipio não existe",1,0)
		cDescMun := ""	
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A926BscItmºAutor  ³Ronaldo Silva       º Data ³  23/01/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada no gatilho disparado pelo campo CDL_PRODNFº±±
±±º          ³ para buscar o item do documento fiscal de saida.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAlias - String para filtro na consulta padrao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cRet - String para filtro na consulta padrao               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA926                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A926BscItm(cAlias)

Local lRet := .F.

Default cAlias := ""

dbSelectArea(cAlias)
dbSetOrder(3)

If SD2->(dbSeek(xFilial(cAlias)+cDocStat+cSerStat+cCliStat+cLojStat+aCols[N,1]+aCols[N,2]))
	lRet := .T. 
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  A926BgtEx   ³Ronaldo 		       º Data ³  28/04/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada no gatilho disparado pelo campo CDL_SEREXP º±±
±±º          ³ para buscar o item do documento fiscal de saida.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cRet - String para filtro na consulta padrao               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA926                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A926BgtEx()

Local nQtd := 0 
local nNf := AScan(aHeader,{|x| AllTrim(x[2])=="CDL_DOCORI"})

local nSer := AScan(aHeader,{|x| AllTrim(x[2])=="CDL_SERORI"})
local nFor := AScan(aHeader,{|x| AllTrim(x[2])=="CDL_FORNEC"})
local nLjFor := AScan(aHeader,{|x| AllTrim(x[2])=="CDL_LOJFOR"})
local nProd := AScan(aHeader,{|x| AllTrim(x[2])=="CDL_PRODNF"})
LOcal nItem := AScan(aHeader,{|x| AllTrim(x[2])=="CDL_ITEORI"})

dbSelectArea("SD1")
dbSetOrder(1)


If SD1->(dbSeek(xFilial("SD1")+aCols[N,nNf]+aCols[N,nSer]+aCols[N,nFor]+aCols[N,nLjFor]+aCols[N,nProd]+aCols[N,nItem]))
	nQtd := SD2->D2_QUANT
Endif

Return nQtd
