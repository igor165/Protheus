#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "HSPAHM57.CH"
STATIC lOdonto := .T.

/*/. 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ HSPAHM57 ³ Autor ³ Rogerio Tabosa		³ data ³ 21/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Prontuario Eletronico Clinica                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Gestao Hospitalar                            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM57()

	Local aSize:={},aObjs:={},aInfo:={},aPObj:={},aPEnc:={}, aPAux := {},aPMem := {},aPGet := {}
	Local aButtons 		:= {}
	Local cEspUsu    	:= ""
	Local nL			:= 0
	Local nSayCol		:= 0
	Local oSay
	Local lRes800		:= .F.
	Local aPCal 		:= Array(1)
	Local oMenu 		:= nil
	LOCAL aCpoGcyClone
	LOCAL nCpoGcy 		:= 0
	LOCAL aGTJadd 		:= {}
	LOCAL nI 			:= 0
	Local cMVTpAltaM 	:= SuperGetMV("MV_TPALTAM", NIL, "01")
	Static oFolder		:= Nil
	
	Private lSupervisor := .T.

	Private lTelaOK		:= .F.
	Private lAltaCli	:= SuperGetMV("MV_ALTACLI", NIL, .F.)  // Alta após confirmar o atendimento
	Private lPnlCli		:= SuperGetMV("MV_PNLCLI", NIL, .F.)
	Private lPOrcCl		:= SuperGetMV("MV_PORCCL", NIL, .F.)  // Permite gerar pre orçamento para auto gestão
	Private cMVTabOrc	:= SuperGetMV("MV_TABORC", NIL, "")  // Permite gerar pre orçamento para auto gestão
	Private cGDBCodTab	:= ""
	Private nFiltro		:= 2
	Private oButton2 := nil, oMenu02 := nil, oMenu0201 := nil, oMenu0202 := nil, oMenu0203 := nil
	Private cCadastro  	:= OemToAnsi(STR0006) //"Prontuario Eletronico - Clinicas"
	Private nOpcPE
	Private oGetPac 	:= Nil
	Private oBtnEfe		:= Nil
	Private oFolGetsImg	:= Nil
	Private aHeadPac 	:= {}, aColsPac := {}
	Private aHeadGT9Or 	:= {}, aColsGT9Or := {}
	Private aHeadSCK 	:= {}, aColsSCK := {}
	Private nGt9NumFat 	:= 0
	Private nGt9NumCli 	:= 0
	Private nGt9Cobran	:= 0
	Private nGt9NumLoj 	:= 0
	Private nGt9DtEmis 	:= 0
	Private nGt9Status 	:= 0
	Private nAtPac		:= 0
	Private cAtPac		:= ""
	Private cNPPac		:= "" //Numero do Prontuario do Paciente
	Private aMntperg	:= {}
	Private aTelaPer 	:= {}
	Private aAnmSConf	:= {}
	Private aMneSele   	:= {}  //utilizada para armazenar todos os mnemonicos selecionados para cada pergunta
	Private oEncPer
	Private cEnvServ 	:= GetEnvServer()
	Private cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()))

//================================================================¿
//³ variaveis de utilizado no MATA415 e MATA416 para inclusão
// e Efetivação de Orçamento		 							 ³
//================================================================Ù
	Private aRotina := {		;
		{STR0001, "AxPesqui"  , 0, 1, 0, .F.},; 	//"Pesquisar"
	{STR0002, "A415Visual", 0, 2, 0, NIL},;	//"Visualizar"
	{STR0003, "A415Inclui", 0, 3, 0, NIL},; 	//"Incluir"
	{STR0004, "A415Altera", 0, 4, 0, NIL},; 	//"Alterar"
	{STR0005, "A415Exclui", 0, 5, 0, NIL} }	//"Exclui"
	PRIVATE aHeadC6:= {}
	PRIVATE aHeadD4:= {}
	Private lAtuGTC			:= .F.
	Private nAtOPlnOld		:= 1
	Private nAtIPlnOld		:= 0
	Private nGTCHisAte		:= 0
	Private oGDGT8, aHGT8 := {}, aCGT8 := {}, nUGT8 := 0
	Private oGetItePln, aHSCKPln := {}, aCSCKPln := {}
	Private oGetOrcPen, aHeadGTP := {}, aColsGTP := {}
	Private oGetOrcPln, aHGT9Pln := {}, aCGT9Pln := {}
	Private oGetHisAte, aHGTC := {}, aCGTC := {}
	Private oGetGTC, aHGTC2 := {}, aCGTC2 := {}
	Private oGetMPI, aHMPI := {}, aCMPI := {}
	Private nGTCItem	:= 0
	Private nMPICodReg	:= 0
	Private nMPIOrcGer	:= 0
	Private nMPICodPro	:= 0
	Private nMPIDenReg	:= 0
	Private nMPIItem	:= 0
	Private nMPIItemOr	:= 0
	Private nMPIHisAte	:= 0
	Private aCodUsr		:= {}
	Private aCodUsuCpa  := {} //Usuario que chamou paciente painel
	Private aCodUsuRat  := {} //Usuario que marcou atendimento ao paciente
	Private aRMntQues	:= {}
	Private aCpOrcAlt	:= {"GT9_COBRAN"}
	Private aCpoGcy  := {"GCY_REGATE","GCY_NOME","GM8_HORAGE","GM8_OBSERV","GCY_DATATE","GCY_HORATE","GCY_CODLOC","GCY_NOMLOC","GCY_DINIPE", "GCY_HINIPE", "GCY_DINIAC", "GCY_HINIAC", "GM8_CODAGE"}
	Private aJoinGcy := {{" LEFT JOIN " + RetSqlName("GM8") + " GM8", "GM8.GM8_HORAGE", "GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_REGATE = GCY.GCY_REGATE AND GM8.GM8_CODAGE = GM8.GM8_AGDPRC AND GM8.GM8_REGGER = GCY.GCY_REGGER", "GM8_HORAGE"}}
	Private	aCpoSck  := {"GTJ_PRIORI","CK_ITEM","CK_PRODUTO","CK_UM","CK_QTDVEN","CK_PRCVEN","CK_VALOR","CK_OPER","CK_TES","CK_LOCAL", "CK_DESCONT",;
		"CK_VALDESC","CK_PEDCLI","CK_DESCRI", "CK_PRUNIT", "CK_OBS", "CK_ENTREG", "CK_COMIS1", "CK_DT1VEN","GTJ_PROPAI"}
	Private aJoinSck := {{" LEFT JOIN " + RetSqlName("GTJ") + " GTJ", "GTJ.GTJ_PRIORI", "GTJ.GTJ_FILIAL = '" + xFilial("GTJ") + "' AND GTJ.D_E_L_E_T_ <> '*' AND GTJ.GTJ_NUMORC = SCK.CK_NUM AND GTJ.GTJ_ITEM = SCK.CK_ITEM ", "GTJ_PRIORI"}}
	Private	aCpoGtp  := {}//{"GTP_ITEM","GTP_PRODUT","GTP_DESPRO","GTP_CODGLO","GTP_DESGLO","GTP_DATGLO","GTP_HORGLO", "GTP_NUMORC"}

//Retirada coluna CK_QTDVEN
	Private	aCpoSckPln  := {"GTJ_PRIORI","GTJ_PRODUT","GTJ_DESPRO","GTJ_ITEM","CK_OBS", "GTJ_PROPAI","GTJ_DPROPA", "GTJ_DENREG","GTJ_DESREG", "GTJ_FADENT", "GTJ_FACDES"}
	Private aJoinSckPln := {{" LEFT JOIN " + RetSqlName("SCK") + " SCK", "SCK.CK_ITEM", "SCK.CK_FILIAL = '" + xFilial("SCK") + "' AND SCK.D_E_L_E_T_ <> '*' AND GTJ.GTJ_NUMORC = SCK.CK_NUM AND GTJ.GTJ_ITEM = SCK.CK_ITEM ", "CK_ITEM"}}
	Private cOrdeSck := "GTJ_PRIORI"
	Private aCpoGTC		:= {"GTC_ITEM","GTC_DATHIS","GTC_DENREG","GTC_DESREG","GTC_FADENT","GTC_FACDES","GTC_HISATE"}
	Private cPlaAte		:= ""
	Private cRedPro		:= ""
	Private cRGerSel	:= ""
	Private cGuiAte		:= ""
	Private aCpoMPI		:= {"GTD_ITEM","GTD_DATHIS","GTD_DENREG","GTD_DESREG","GTD_FADENT","GTD_FACDES","GTD_HISATE"}
	Private oCalend
	Private Inclui 		:= .F.
	Private cCrmLog		:= ""
	Private cCodLoc		:= ""
	Private cCliPad		:= ""
	Private cLojPad		:= ""
	Private cGcsTipLoc := "J" // Variavel utilizada pelo fonte HSPFFSXB para listar os setores do tipo
	Private nGDOpc			:= GD_INSERT + GD_UPDATE + GD_DELETE
	Private cEspecMed	:= ""
	Private cCdQues		:= ""
	Private cDirImg		:= ""
	Private oTBitmap1
	Private aLegGT9 := 	{;
		{"GT9_STATUS == '0'", "BR_AMARELO"},; //0=Orc. Pendente;1=Pend.Fin.\Nao Autoriz;2=Aprovado;3=Liberado;4=Cancelado;5=Em tratamento;6=Finalizado
	{"GT9_STATUS == '1'", "BR_VERMELHO"},;
		{"GT9_STATUS == '2'", "BR_AZUL"},;
		{"GT9_STATUS == '3'", "BR_VERDE"},;
		{"GT9_STATUS == '4'", "BR_PRETO"},;
		{"GT9_STATUS == '5'", "BR_VIOLETA"},;
		{"GT9_STATUS == '6'", "BR_BRANCO"}}
	Private cCobranca := ""
	Private aLegGTJ := 	{;
		{"GTJ_STATUS == '0'", "BR_AMARELO"},;
		{"GTJ_STATUS == '1'", "BR_VERDE"},;
		{"GTJ_STATUS == '2'", "BR_PRETO"},;
		{"GTJ_STATUS == '3'", "BR_LARANJA"},;
		{"GTJ_STATUS == '4'", "BR_AZUL"},;
		{"GTJ_STATUS == '5'", "BR_VERMELHO"}}
	Private aLegGTP := 	{;
		{"GTP_STATUS == '0'", "BR_VERMELHO"},;
		{"GTP_STATUS == '1'", "BR_VERDE"}}
	Private aColors := {CLR_HRED, CLR_HRED} // Linha Vermelha / Fundo Vermelho
	Private cCodOdtGr := "" // Codigo do Odontograma utilizado
	Private cImgOdtGr := "" // Imagem do Odontograma utilizado
	Private cTipOdtGr := "" // Imagem do Odontograma utilizado
	Private cAliasMPI := "GTD" // Imagem do Odontograma utilizado
	Private cAliasHIS := "GTC" // Arquivo do odontograma
	Private aCoordOdg := {}
	Private cDispTela := "1"
	Private lMudMPI 	:= SuperGetMV("MV_MUDMPI", NIL, .F.)
	Private nRegGcy	  := 0
	Private bKeyF5 		//:= SetKey(VK_F5, {|| FS_REFRESH()})
	Private bKeyF10
	Private __cCdJustGT9 := ""
	Private __cCdUsrFGT9 := ""
	Private lExCobran		:=  .t.	//HS_ExisDic({{"C", "GT9_COBRAN"}},.F.)
	Private lExGt9RegGer	:=  .t.	//HS_ExisDic({{"C", "GT9_REGGER"}},.F.)
	Private lAltCobran	:= .F.
	Private lVisValSb1	:= .T. // Indica se o profissional poderá visualizar os valores do orçamento
	Private cHsB1TipPro := SuperGetMV("MV_TPPRSB1", NIL, "") // Filtro por tipo B1_TIPO na SB1
	Private cCodSala       := ""
	Private aLegGCY := 	{;
		{"!empty(GCY_DINIPE) .and. !empty(GCY_HINIPE) .and. !empty(GCY_DINIAC) .and. !empty(GCY_HINIAC)", "BR_VERDE"},;  //Em Atendimento
	{"!empty(GCY_DINIPE) .and. !empty(GCY_HINIPE) .and.  empty(GCY_DINIAC) .and.  empty(GCY_HINIAC)", "BR_VERMELHO"},; //Chamado para atendimento
	{ "empty(GCY_DINIPE) .and.  empty(GCY_HINIPE) .and.  empty(GCY_DINIAC) .and.  empty(GCY_HINIAC)", "BR_CINZA"}}       //Aguardando atendimento
	Private cUsrPass    := ""  //GRAVA LOGIN
	Private lChkPen		:= .T.
	Private cFilItPln	:= " AND GTJ_STATUS IN ('0','3','4') "
	Private cCondicao	:= ""
	Private cChaveLock  := ""
	Private cChaveAtu   := ""
	Private lVisPltFin  := .F.
	Private lExCliSAt  	:= .F.
	Private lPExCNM  	:= SuperGetMV("MV_PEXCNM", NIL, .F.)  // Permite usuarios nao medicos a realizar o Exame Clinico
	Private lAvisoProm	:=.F.

//VARIAVEIS PROMOÇÃO DA SAUDE
	Private lMVPromo := SuperGetMV("MV_PROSAUD", NIL, .F.)  // Promoção a Saude
	If lMVPromo
		Private aPerPro:={}
		Private nGetCODPRO	:=0
		Private nGetVida  	:=0
		Private NGETNROSEQ :=0
		Private NGETSTATUS	:=0
		Private nGetRISCO	:=0
		Private oMenuPr2 	:= nil
		Private oMenuPr01 	:= nil
		Private oMenuPr02 	:= nil
		Private oMenuPr03 	:= nil
		Private oMenuPr04 	:= nil
		Private oMenuPr05 	:= nil
		Private oMenuPr06 	:= nil
		Private oMenuPr07 	:= nil
		Private oMenuPr08 	:= nil
		Private oMenuPr09 	:= nil
		Private oMenuPr10 	:= nil
		Private oMenuPr11 	:= nil
		Private oMenuPr12 	:= nil
		Private oMenuPr1 	:= nil
		Private oButtPr2 	:= nil
		Private oGetBOM
		Private aHeadBOM :={}
		Private aColsBOM :={}
		Private AlegBOM  :={;
			{"BOM_STATUS == '0'", "BR_AZUL"},;
			{"BOM_STATUS == '1'", "BR_AMARELO"},;
			{"BOM_STATUS == '2'", "BR_VERDE"},;
			{"BOM_STATUS == '3'", "BR_VERMELHO"},;
			{"BOM_STATUS == '5'", "BR_CINZA"}}
	EndIf
	PRIVATE lHsPrEl57 := ExistBlock("HSPREL57") // Ponto de Entrada no Grid do Paciente
	PRIVATE cOrdGcy := ""

	IF lHsPrEl57
		aCpoGcyClone := ACLONE(aCpoGcy)
		aCpoGcy := ExecBlock("HSPREL57", .F., .F., {aCpoGcy})
		IF LEN(aCpoGcy) > LEN(aCpoGcyClone)
			SX3->(DBSETORDER(2))
			FOR nCpoGcy := 1 TO LEN(aCpoGcy)
				IF SX3->(DBSEEK(aCpoGcy[nCpoGcy]))
				IF SX3->(X3Uso(X3_USADO) .And. cNivel >= X3_NIVEL .And. X3_BROWSE == "S" .And. X3_CONTEXT <> "V" .And. X3_TIPO <> "M")
						IF !(aCpoGcy[nCpoGcy] $ cOrdGcy)	//	Evita repetir o campo
							cOrdGcy += IIF(!EMPTY(cOrdGcy), ", ", "") + aCpoGcy[nCpoGcy]
						ENDIF
					ENDIF
				ENDIF
			NEXT
		ELSE
			aCpoGcy := ACLONE(aCpoGcyClone)	//	Não pode excluir campos
		ENDIF
	ENDIF
	If !Empty(cHsB1TipPro)
		cHsB1TipPro := HS_InSql(PADR(Alltrim(cHsB1TipPro), Len(SB1->B1_TIPO)),Len(SB1->B1_TIPO),",")
	EndIf
	Define  FONT oFont NAME "Arial,12," BOLD
	DEFINE CURSOR oCursor HAND

	aCpoSck := FS_AJUSORD(aCpoSck,{"GTJ_PRIORI","CK_PRODUTO","CK_DESCRI"})
	AADD(aJoinSck    , {"", "GTJ.GTJ_STATUS" , "", "GTJ_STATUS"})
	
	AADD(aJoinSckPln , {"", "SCK.CK_QTDVEN"  , "", "CK_QTDVEN" })
	AADD(aJoinSckPln , {"", "SCK.CK_VALOR"   , "", "CK_VALOR"  })
	AADD(aJoinSckPln , {"", "SCK.CK_OBS"     , "", "CK_OBS"    })
	
	AADD(aJoinGcy    , {"", "GM8.GM8_OBSERV" , "", "GM8_OBSERV"})
	AADD(aJoinGcy    , {"", "GM8.GM8_CODAGE" , "", "GM8_CODAGE"})
	aCpoSckPln := FS_AJUSORD(aCpoSckPln,{"GTJ_PRIORI","GTJ_PRODUT","GTJ_DESPRO", "GTJ_PROPAI","GTJ_DPROPA"})

//Ponto de Entrada para Inserir campos na GTJ
	If ExistBlock("HM57ADDGTJ")
		aGTJadd := ExecBlock("HM57ADDGTJ", .F., .F.)
		For nI := 1 To Len(aGTJadd)
			AADD(aCpoSckPln,aGTJadd[nI])
		Next nI
	EndIf
//================================================================¿
//³  Verifica autorizacao acesso para o medico e retorna dados ³
//================================================================Ù
	aCodUsr := HS_VldDAnm(!lPExCNM,.F.)

	If !aCodUsr[1] .AND. !lPExCNM // Se não é medico e usuario comum não é permitido, sai da rotina
		Return()
	ElseIf lPExCNM
		lExCliSAt := .T.
	EndIf
	
//================================================================¿
//³ Verifico se vai ser nessesario autorização do supervidor      ³
//================================================================Ù
lSupervisor := IIf(GBJ->(FieldPos("GBJ_SOLAUT")) > 0,GBJ->GBJ_SOLAUT ="1",.T.) // 0-NÃO ## 1 -SIM

//================================================================¿
//³ Pergunta (Setor de Atendimento)		                         ³
//================================================================Ù
//Pergunte("HSPM57", aCodUsr[1] )
If aCodUsr[1]
	If !Pergunte("HSPM57", .T.)
		Return()
	EndIf
Else
	Pergunte("HSPM57", .F.)
EndIf
cCodLoc	:= IIf(ValType(MV_PAR01) == "C", MV_PAR01, cCodLoc ) 
nFiltro	:= IIf(ValType(MV_PAR02) == "N", MV_PAR02, 2 )
cCodSala:= IIf(ValType(MV_PAR03) == "C", MV_PAR03, "" )

//================================================================¿
//³ Atribui CRM do Medico e Busca Especialidades                 ³
//================================================================Ù
	cCrmLog := aCodUsr[2]
	If aCodUsr[1]
		cEspUsu := HS_REspMed(cCrmLog)
		cEspecMed := "'"+StrTran(cEspUsu,"/","','")+"'"
	EndIf

//Verificando se o profissional logado tem permissao para repetir procedimentos para Planos de Tratamento finalizados
	dbSelectArea("GBJ")
	dbSetOrder(1)
	If dbSeek(xFilial("GBJ") + cCrmLog ) .AND. !Empty(cCrmLog)
		lVisPltFin 	:= (GBJ->GBJ_VISPLT == "1")
		lExCliSAt	:= (GBJ->GBJ_EXCSAT == "1")
	EndIf

//=======================================================¿
//³ Monta aHeader do SC6 para utilização do MATA416      ³
//=======================================================Ù
	aHeadC6 := {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC6",.T.)
	While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
		If (  ((X3Uso(SX3->X3_USADO) .And. ;
				!( Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And.;
				Trim(SX3->X3_CAMPO) != "C6_QTDEMP"  .And.;
				Trim(SX3->X3_CAMPO) != "C6_QTDENT") .And.;
				cNivel >= SX3->X3_NIVEL) .Or.;
				Trim(SX3->X3_CAMPO)=="C6_NUMORC" .Or. ;
				Trim(SX3->X3_CAMPO)=="C6_NUMOP"  .Or. ;
				Trim(SX3->X3_CAMPO)=="C6_ITEMOP" .Or. ;
				Trim(SX3->X3_CAMPO)=="C6_OP" .Or. ;
				Trim(SX3->X3_CAMPO)=="C6_OPC" )
			Aadd(aHeadC6,{TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				IIf(Trim(SX3->X3_CAMPO)=="C6_NUMORC",".F.",SX3->X3_VALID),;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

//=======================================================¿
//³ Monta aHeader do SD4 para utilização do MATA416		 ³
//=======================================================Ù
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SD4")
	While ( !Eof() .And. SX3->X3_ARQUIVO == "SD4" )
		If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
			Aadd(aHeadD4,{ Trim(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT })
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

//================================================================¿
//³ Busca Odontogramas atribuidos a especialidade profissional   ³
//================================================================Ù
	cCond := ""
	cCond :=" GTE.GTE_FILIAL = '" + xFilial("GTE") + "' AND GTE.D_E_L_E_T_ <> '*' "
	If aCodUsr[1]
		cCond +=" AND GTE_ESPECI IN "
		cCond +=" ( "+cEspecMed+"	) "
	EndIf
	cCodOdtGr := HS_OdnGram(cCond)

	If !Empty(cCodOdtGr)
		DbSelectArea("GTE")
		DbSetOrder(1)
		If DbSeek(xFilial("GTE") + cCodOdtGr)
			cImgOdtGr := Alltrim(GTE->GTE_IMAGEM)
			cDispTela := GTE->GTE_TELA
			cTipOdtGr := GTE->GTE_TIPCFG  // Define o se é Odontograma ou Mapeamento de Imagens em geral
			cAliasMPI := IIf(cTipOdtGr  == "0", "GTH", "GTD")
			cAliasHIS := IIf(cTipOdtGr  == "0", "GTO", "GTC")
		EndIf
		aCoordOdg := HS_COORDMPI(cCodOdtGr)
	EndIf

	If cTipOdtGr == "0"
		aCpoGTC := {"GTO_ITEM","GTO_DATHIS","GTO_CODREG","GTO_DESREG","GTO_HISATE"}
		aCpoMPI := {"GTH_ITEM","GTH_DATHIS","GTH_CODREG","GTH_DESREG","GTH_HISATE","GTH_CODPRO","GTH_DESPRO","GTH_ORCGER","GTH_ITEMOR"}
		aCpoGtp := {"GTP_ITEM","GTP_PRODUT","GTP_DESPRO","GTP_CODGLO","GTP_DESGLO","GTP_DATGLO","GTP_HORGLO","GTP_NUMORC"}
	Else	//	Odonto
		aCpoGTC := {"GTC_ITEM","GTC_DATHIS","GTC_DENREG","GTC_DESREG","GTC_FADENT","GTC_FACDES","GTC_HISATE"}
		aCpoMPI := {"GTD_ITEM","GTD_DATHIS","GTD_DENREG","GTD_DESREG","GTD_FADENT","GTD_FACDES","GTD_HISATE","GTD_CODPRO","GTD_DESPRO","GTD_ORCGER","GTD_ITEMOR"}
		aCpoGtp := {"GTP_ITEM","GTP_PRODUT","GTP_DESPRO","GTP_CODGLO","GTP_DESGLO","GTP_DATGLO","GTP_HORGLO","GTP_NUMORC","GTP_DENREG","GTP_DESREG","GTP_FADENT","GTP_FACDES"}
	EndIf
	FS_ADX3COLS(cAliasMPI, @aCpoMPI)
	FS_ADX3COLS(cAliasHIS, @aCpoGTC)
	aCpoGTC := FS_AJUSORD(aCpoGTC)

//Ponto de Entrada para Ordenar campos na GTC
	If ExistBlock("HM57GTCORD")
		aCpoGTC := ExecBlock("HM57GTCORD", .F., .F., {aCpoGTC})
	EndIf


//================================================================¿
//³ Busca Questionarios atribuidos ao profissional               ³
//================================================================Ù
	If aCodUsr[1]
		cCond := ""
		cCond :=" GFS.GFS_FILIAL = '" + xFilial("GFS") + "' AND GFS.D_E_L_E_T_ <> '*' "
		cCond +=" AND (GFS_CODCRM = '"+aCodUsr[2]+"' OR GFS_CODCRM = '') "
		cCond +=" AND (GFS_CODESP IN "
		cCond +=" ( "+cEspecMed+"	) OR GFS_CODESP = '')"
		cCond +=" AND (GFS_TIPPRO = '"+HS_IniPadr("GBJ", 1, cCrmLog, "GBJ_TIPPRO",, .F.)+"' OR GFS_TIPPRO = '') "
		cCdQues := (aRMntQues := HS_MntQues(cCond))[1]
		cDirImg := Alltrim(aRMntQues[3])
	EndIf

	lVisValSb1 := (HS_IniPadr("GBJ", 1, cCrmLog, "GBJ_VVALPE",, .F.) == "1")
	If !lVisValSb1
		aCpoSck  := {"GTJ_PRIORI","CK_ITEM","CK_PRODUTO","CK_QTDVEN","CK_OPER","CK_TES","CK_LOCAL","CK_PEDCLI","CK_DESCRI", "CK_OBS"}
	EndIf

//================================================================¿
//³ Monta Dimensões da Tela						                 ³
//================================================================Ù
	aSize 			:= MsAdvSize(.T.)
	aObjects := {}
	aAdd( aObjects, { 100, 021, .T., .T.,.T.} ) // Grid Pacientes e Calendario
	aAdd( aObjects, { 100, 002, .T., .T.,.T.} ) // Grid Pacientes e Calendario
	aAdd( aObjects, { 100, 077, .T., .T.,.T.} ) // Folders
	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPPanel := MsObjSize( aInfo, aObjects, .T.)

	aObjects := {}
	aAdd( aObjects, { 072, 100, .T., .T.,.T.} ) // Grid Pacientes
	aAdd( aObjects, { 028, 100, .T., .T.,.T.} ) // Calendario
	aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0, 0 }
	aPInfo := MsObjSize( aInfo, aObjects, .T., .T.)

	aObjects := {}
	aAdd( aObjects, { 100, 100, .T., .T.} ) // Folder Anamnese
	aInfo  := { aPPanel[3, 2], aPPanel[3, 2], aPPanel[3, 3], aPPanel[3, 4], 0, 0 }
	aPFolAna := MsObjSize( aInfo, aObjects, .T., .F./*,.T.*/)

	aObjects := {}
	aAdd( aObjects, { 100, 100, .T., .T.,.T.} ) // Folder Grids Orçamento
	aInfo  := { aPPanel[3, 2], aPPanel[3, 2], aPPanel[3, 3], aPPanel[3, 4], 0, 0 }
	aPFolGrid := MsObjSize( aInfo, aObjects, .T., .F./*,.T.*/)

	aObjects := {}
	aAdd( aObjects, { 100, 040, .T., .T.} ) // Grid Orcamento Cabeçalho
	If lPOrcCl
		aAdd( aObjects, { 100, 040, .T., .T.,.T.} ) // Grid Orçamento itens
	Else
		aAdd( aObjects, { 100, 040, .T., .T.} ) // Grid Orçamento itens
	EndIf
	aAdd( aObjects, { 100, 020, .T., .T.} ) // Grid Legenda Orçamento

	aInfo := { aPFolGrid[1, 2], aPFolGrid[1, 2], aPFolGrid[1, 3], aPFolGrid[1, 4], 0, 0 }
	aPOrc := MsObjSize( aInfo, aObjects, .T.,.F./*,.T.*/)

	aObjects := {}
	aAdd( aObjects, { 100, 022, .T., .T.} ) // Grid Orcamento Cabeçalho
	aAdd( aObjects, { 100, 035, .T., .T.} ) // Grid Orçamento itens
	aAdd( aObjects, { 100, 043, .T., .T.} ) // Grid Legenda Orçamento

	aInfo  := { aPFolGrid[1, 2], aPFolGrid[1, 2], aPFolGrid[1, 3], aPFolGrid[1, 4], 0, 0 }
	aPTrat := MsObjSize( aInfo, aObjects, .T.,.F./*,.T.*/)

//=================================== Folder Exame Clinico ========================
	aObjects := {}
	aAdd( aObjects, { 100, 100, .T., .T.,.T.} )
	aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3 ], aPPanel[1, 4 ], 0, 0 }
	aPDiv := MsObjSize( aInfo, aObjects, .T.,.T.,.T.)  // ObjSize do Folder Exame Clinico

	aObjects := {}
	aAdd( aObjects, { 060, 100, .T., .T.} )
	aAdd( aObjects, { 040, 100, .T., .T.} )

	aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0, 0 }
	aPExCliV := MsObjSize( aInfo, aObjects, .T., .T.,.T.)  // Obj Imagem e Grid Vertical

	aObjects := {}
	aAdd( aObjects, { 100, 060, .T., .T.} ) // Imagem na Horizontal
	aAdd( aObjects, { 100, 040, .T., .T.} ) // Grid na Horizontal

	aInfo  := { aPFolGrid[1, 2], aPFolGrid[1, 2], aPFolGrid[1, 3], aPFolGrid[1, 4], 0, 0 }
	aPExCliH := MsObjSize( aInfo, aObjects, .T.,.F./*,.T.*/) //Obj Imagem e Grid Horizontal

	DEFINE MSDIALOG oDlgPE TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of GetWndDefault() PIXEL
	nDif := IIf(aPInfo[2, 4] < 65, 70 - aPInfo[2, 4],0) //Diferença do tamanho do calendário para resoluções menores

	oPanel1 := tPanel():New(aPInfo[1, 1]+30, aPInfo[1, 2],, oDlgPE,,,,,, aPInfo[1, 3], aPInfo[1, 4]+nDif)// Pacientes
	oPanel2 := tPanel():New(aPInfo[2, 1]+28, aPInfo[2, 2],, oDlgPE,,,,,, aPInfo[2, 3], aPInfo[2, 4]+nDif)//Calendario
	oPanel3 := tPanel():New(aPPanel[3, 1]+nDif, aPPanel[3, 2],, oDlgPE,,,,,, aPPanel[3, 3], aPPanel[3, 4])//Folders

//================================================================¿
//³ Botão Gravar Atendimento na Tela                                        			 ³
//================================================================Ù
	If GetNewPar("MV_BTGRATD",.F.)
		oPanel4 := tPanel():New(aPInfo[1, 1]+100, aPInfo[2, 2]+80,, oDlgPE,,,,,, aPInfo[1, 3]+100, aPInfo[2, 1]+18)
		oButton := tButton():New(0, 1, STR0099, oPanel4, {|| fs_Salva()}, 45, 15)	//	"Grava Atend."
	EndIf
		
// P.E. para habilitar ou inibir as guias de Odonto: "Orçamento", "Plano de Tratamento" e "Exame Clinico"
	If ExistBlock("HSGODON")
		lOdonto := ExecBlock("HSGODON", .F., .F., {})
	EndIf

//================================================================¿
//³ Folder Principal    						                 ³
//================================================================Ù
	IF lOdonto
		@ aPPanel[3, 1], aPPanel[3, 2] FOLDER oFolder SIZE aPPanel[3, 3], aPPanel[3, 4]  OF oPanel3 PIXEL PROMPTS STR0007, STR0008, STR0009, STR0010 //"Anamnese", "Orçamento", "Plano de tratamento", "Exame Clinico"
	ELSE
		@ aPPanel[3, 1], aPPanel[3, 2] FOLDER oFolder SIZE aPPanel[3, 3], aPPanel[3, 4]  OF oPanel3 PIXEL PROMPTS STR0007	//"Anamnese"
	ENDIF
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

//================================================================¿
//³ Folder pendencias    						                 ³
//================================================================Ù
	If lPOrcCl .AND. lOdonto
		@ aPOrc[2, 1], aPOrc[2, 2] FOLDER oFolPend SIZE aPOrc[2, 3], aPOrc[2, 4]  OF oFolder:aDialogs[2] PIXEL PROMPTS "Itens", "Pendencias"
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

//================================================================¿
//³ Calendario                                        			 ³
//================================================================Ù
	oCalend := MsCalend():New(02, 01, oPanel2)
	If !(!aCodUsr[1] .AND. lPExCNM)
		oCalend:bChangeMes := {|| FS_DesmCal(oCalend:dDiaAtu),oCalend:Refresh()}
		oCalend:bChange := {|| FS_LSTPAC(DTOS(oCalend:dDiaAtu))}
	EndIf

	If !aCodUsr[1] .AND. lPExCNM
		oCalend:Disable()
	EndIf

	bKeyF5  := SetKey(VK_F5, {|| MsgRun(STR0011,, { || FS_REFRESH(DTOS(oCalend:dDiaAtu))})})
	bKeyF10 := SetKey(VK_F10, {|| MsgRun(STR0101,, { || FS_GERORC(cAliasMPI)})}) //"Gerando Orçamento..."

//================================================================¿
//³ Busca Atendimentos de Acordo com o Profissional e Local de At³
//================================================================Ù
	If nFiltro == 2
		HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODCRM = '" + cCrmLog + "' AND GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + DTOS(oCalend:dDiaAtu) +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'",.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,,,,aCpoGcy,aJoinGcy,,,,,)
	ElseIf nFiltro == 3 // Todos pacientes
		HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + DTOS(oCalend:dDiaAtu) +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'",.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,lHsPrEl57,,,aCpoGcy,aJoinGcy,,cOrdGcy,,,)
	Else // nFiltro == 1
		HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + DTOS(oCalend:dDiaAtu) +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'" + ;
			" AND EXISTS (" + ;
			"SELECT 1 FROM " + retSqlName("GCZ") + " GCZ" + ;
			" JOIN " + retSqlName("GCY") + " GCYY ON GCZ.GCZ_REGATE = GCYY.GCY_REGATE" + ; //LINHA ADICIONAL
		" JOIN " + retSqlName("GD7") + " GD7" + ;
			" ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GD7.GD7_FILIAL ='" +xFilial("GD7") +"' AND GD7.D_E_L_E_T_<>'*'" + ;
			" AND GCZ.GCZ_FILIAL ='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_<>'*'" + ;
			" JOIN " + retSqlName("GA7") + " GA7" + ;
			" ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GD7.GD7_CODDES" + ;
			" AND GA7_CODESP IN (" + cEspecMed + ")" + ;
			" AND GA7.GA7_FILIAL ='" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_<>'*'" + ;
			" WHERE GCZ.GCZ_FILIAL ='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_<>'*'" + ;//" WHERE GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL ='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_<>'*'" + ;//
		")"  ;
			,.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,,,, aCpoGcy,aJoinGcy,,,,,)
	Endif
	nGcyRegAte := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_REGATE"})
	nGcyOk     := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_OK    "})
	nGcyNome   := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_NOME  "})
	nGcyDinipe := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_DINIPE"})
	nGcyHinipe := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_HINIPE"})
	nGcyDiniac := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_DINIAC"})
	nGcyHiniac := aScan(aHeadPac, {|aVet| aVet[2] == "GCY_HINIAC"})
	nHspStareg := aScan(aHeadPac, {|aVet| aVet[2] == "HSP_STAREG"})
	nGcyObserv := aScan(aHeadPac, {|aVet| aVet[2] == "GM8_OBSERV"})
	nGcyCodAge := aScan(aHeadPac, {|aVet| aVet[2] == "GM8_CODAGE"})

//================================================================¿
//³ Grid dos pacientes 											 ³
//================================================================Ù
	oGetPac:= MsNewGetDados():New(aPInfo[1, 1], aPInfo[1, 2], aPInfo[1, 3], aPInfo[1, 4], 0,,,,,,,,,, oPanel1, aHeadPac, aColsPac)
	oGetPac:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetPac:oBrowse:BlDblClick := {|| iIf(oGetPac:oBrowse:nColPos <> nGcyOk .AND.  oGetPac:oBrowse:nColPos <> nHspStaReg, IIf(oGetPac:oBrowse:nColPos <> nGcyObserv, FS_M57LEG(),FS_EMemo("Observação do Agendamento",oGetPac:aCols[oGetPac:nAt, nGcyCodAge])),MsgRun(STR0011,, { || (M57CHKORC(), FS_LOADPAC(oGetPac:aCols[oGetPac:nAt, nGcyRegAte]))}) )   } //"Aguarde, buscando dados..."

//================================================================¿
//³ Monta perguntas na Aba de Anamnese e Imagens caso esteja param³
//================================================================Ù
	If !Empty(cDirImg)
		If lMVPromo
			@ aPPanel[3, 1] , aPPanel[3, 2] FOLDER oFolGetsImg SIZE aPPanel[3, 3] , aPPanel[3, 4] + 90 Pixel OF oFolder:aDialogs[1] Prompts STR0012, STR0013,"Promoção da Saúde" //"Questionário", "Imagem"
		Else
			@ aPPanel[3, 1] , aPPanel[3, 2] FOLDER oFolGetsImg SIZE aPPanel[3, 3] , aPPanel[3, 4] + 90 Pixel OF oFolder:aDialogs[1] Prompts STR0012, STR0013 //"Questionário", "Imagem"
		Endif
	Else
		If lMVPromo
			@ aPPanel[3, 1] , aPPanel[3, 2] FOLDER oFolGetsImg SIZE aPPanel[3, 3] , aPPanel[3, 4] + 90 Pixel OF oFolder:aDialogs[1] Prompts STR0012,"Promoção da Saúde"   //"Questionário"
		Else
			@ aPPanel[3, 1] , aPPanel[3, 2] FOLDER oFolGetsImg SIZE aPPanel[3, 3] , aPPanel[3, 4] + 90 Pixel OF oFolder:aDialogs[1] Prompts STR0012   //"Questionário"
		Endif
	EndIf
	oFolGetsImg:Align := CONTROL_ALIGN_ALLCLIENT
	aMntperg := HS_MntPerg(cCdQues, oFolGetsImg:aDialogs[1],, aPFolAna[1], .F., "PER", "oEncPer",, "aTelaPer", CONTROL_ALIGN_ALLCLIENT, .F., "G")

//================================================================¿
//³ Monta Imagens do questionario e grid de imagens              ³
//================================================================Ù
	If !Empty(cDirImg)
		oTScrollBox :=  TScrollBox():New(oFolGetsImg:aDialogs[2],aPExCliV[1,1],aPExCliV[1,2],aPExCliV[1,3],aPExCliV[1,4],.T.,.T.,.T.)
		oTScrollBox:Align := CONTROL_ALIGN_ALLCLIENT
		lImagem := .T.
		HS_BDados("GT8", @aHGt8, @aCGt8, @nUGt8, 1,, "GT8->GT8_CHAVE = '000000'",, ,,,,,,,, ,,,,,, ,, )
		nGT8Arquiv := aScan(aHGt8, {| aVet | aVet[2] == "GT8_ARQUIV"})

		oGDGt8 := MsNewGetDados():New(aPExCliV[2, 1], aPExCliV[2, 2], aPExCliV[2, 3], aPExCliV[2, 4] , GD_INSERT + GD_DELETE,,,,,,,,,, oFolGetsImg:aDialogs[2], aHGt8, aCGt8)

		oGDGt8:oBrowse:align := CONTROL_ALIGN_RIGHT
		oGDGt8:oBrowse:BlDblClick := {|| FS_ALTIMG(oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv], cDirImg)}
		oGDGt8:oBrowse:bAdd    := {|| FS_AddLin(cDirImg)}
		oGDGt8:oBrowse:bGotFocus := {|| FS_ATUIMG(oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv])}
		oGDGt8:oBrowse:bChange := {|| FS_ATUIMG(oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv])}

	//================================================================¿
	//³ Objeto que recebe a imagem                                   ³
	//================================================================Ù
		oTBitmap1 := TBitmap():New(0,0,900,900,,oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv],.T.,oTScrollBox,,,.F.,.F.,,,.F.,,.T.,,.F.)
		oTBitmap1:lAutoSize := .T.
	EndIf

//================================================================¿
//³ Objeto Referente a Promoção da Saúde                                    ³
//================================================================Ù
	If lMVPromo
		PLSFOPRO(aPOrc[1, 1],aPOrc[1, 2],aPOrc[1, 3]+120,aPOrc[1, 4], oFolGetsImg:aDialogs[IIf(Empty(cDirImg),2,3)],"",aCodUsr[2])
	Endif
	HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_CLIENT = '0000000' ",, "GT9_STATUS", "/",,,,,,, aLegGT9,, .T.,,, /*aCpoGcy*/,,, "GT9_NUMFAT DESC")
	nGt9NumFat := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_NUMFAT"})
	nGt9NumLoj := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_NUMLOJ"})
	nGt9DtEmis := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_DTEMIS"})
	nGt9Status := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_STATUS"})
	nGt9NumCli := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_CLIENT"})
	nGt9Cobran := aScan(aHeadGT9Or, {|aVet| aVet[2] == "GT9_COBRAN"})

	IF lOdonto
	//================================================================¿
	//³ Grid dos Orcamentos do Faturamento							 ³
	//================================================================Ù
		oGetOrc:= MsNewGetDados():New(aPOrc[1, 1], aPOrc[1, 2], aPOrc[1, 3]-10, aPOrc[1, 4], GD_UPDATE,,,,aCpOrcAlt,,,,,, oFolder:aDialogs[2], aHeadGT9Or, aColsGT9Or)
		oGetOrc:oBrowse:bGotFocus := {|| FS_ATUITEM(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat]) , Iif(lVisValSb1,FS_ORCTotal(oDlgPE, oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat]),Nil), lAltCobran := oGetOrc:aCols[oGetOrc:nAt, nGt9Status] == "BR_AMARELO"}
		oGetOrc:oBrowse:bChange := {|| FS_ATUITEM(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat]), Iif(lVisValSb1,FS_ORCTotal(oDlgPE, oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat]),Nil), lAltCobran := oGetOrc:aCols[oGetOrc:nAt, nGt9Status] == "BR_AMARELO"}
		oGetOrc:cFieldOk           := "If(lAltCobran .AND. lExCobran, HS_M57COBR(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat]), .T.)"

		HS_BDados("SCK" , @aHeadSCK, @aColsSCK,, 1,, " SCK.CK_NUM = '000000' ",,,"/",,,,,,.T.,,,.T.,,,aCpoSck  ,aJoinSck,,cOrdeSck)
		nSckProdut := aScan(aHeadSCK, {|aVet| aVet[2] ==  "CK_PRODUTO"})
		nCKVALDESC	:= aScan(aHeadSCK, {|aVet| aVet[2] == "CK_VALDESC"})
		nCKQTDVEN := aScan(aHeadSCK, {|aVet| aVet[2] ==   "CK_QTDVEN "})
		nCKPRCVEN := aScan(aHeadSCK, {|aVet| aVet[2] == "CK_PRCVEN "})
		nCKPRUNIT := aScan(aHeadSCK, {|aVet| aVet[2] == "CK_PRUNIT "})
		nCKVALOR := aScan(aHeadSCK, {|aVet| aVet[2] ==  "CK_VALOR  "})
		NCKITEN	:=  aScan(aHeadSCK, {|aVet| aVet[2] ==  "CK_ITEM   "})

	//================================================================¿
	//³ Impressão dos totais na tela								 ³
	//================================================================Ù
		nSayCol	:= 100
		If lVisValSb1
			@ aPOrc[1, 3]-08,05+nSayCol SAY oSay PROMPT OemToAnsi(STR0014) SIZE 060,009 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE FONT oFont //"Total do Or‡amento "
			@ aPOrc[1, 3]-08,120+nSayCol SAY oSay PROMPT OemToAnsi(STR0015) SIZE 060,009 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE FONT oFont//"Descontos "
			@ aPOrc[1, 3]-08,180+nSayCol SAY oSay PROMPT OemToAnsi("=")	SIZE 060,009 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE FONT oFont//"="
			@ aPOrc[1, 3]-08,60+nSayCol SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR",16) OF oFolder:aDialogs[2]  PIXEL COLOR CLR_HBLUE FONT oFont
			oSay:Cargo := STR0016  //"Valor"
			@ aPOrc[1, 3]-08,150+nSayCol SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR",14) OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE FONT oFont
			oSay:Cargo := STR0017 //"Desconto"
			@ aPOrc[1, 3]-08,210+nSayCol SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR ",16) OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE FONT oFont
			oSay:Cargo := STR0018	   //"Total"
		EndIf

		HS_BDados("GTP" , @aHeadGTP, @aColsGTP,, 1,, " GTP.GTP_REGATE = '000000' ",,"GTP_STATUS","/",,,,"GTP_IDMARC","'LBNO'",.T.,aLegGTP,,.T.,,,aCpoGtp  ,,,"GTP_ITEM")
		nGtpCodGlo 	:= aScan(aHeadGTP, {|aVet| aVet[2] ==  "GTP_CODGLO"})
		nGtpProdut	:= aScan(aHeadGTP, {|aVet| aVet[2] == "GTP_PRODUT"})
		nGTPSTATUS	:= aScan(aHeadGTP, {|aVet| aVet[2] == "GTP_STATUS"})
		nGTPIDMARC 	:= aScan(aHeadGTP, {|aVet| aVet[2] == "GTP_IDMARC"})
		nGTPNumOrc 	:= aScan(aHeadGTP, {|aVet| aVet[2] == "GTP_NUMORC"})
		nGTPITEM	:= aScan(aHeadGTP, {|aVet| aVet[2] ==  "GTP_ITEM  "})
		nGTPDESPRO	:= aScan(aHeadGTP, {|aVet| aVet[2] ==  "GTP_DESPRO"})
		If cAliasHIS == "GTC"
			nGTPDenReg	:= aScan(aHeadGTP, {|aVet| aVet[2] ==  "GTP_DENREG"})
			nGTPFaDent	:= aScan(aHeadGTP, {|aVet| aVet[2] ==  "GTP_FADENT"})
		EndIf

	//==================================================================¿
	//³ Grid dos Itens Orcamentos do Faturamento e Pendencias Criticadas³
	//==================================================================Ù
		If lPOrcCl
			oGetOrcIte:= MsNewGetDados():New(aPOrc[2, 1], aPOrc[2, 2], aPOrc[2, 3], aPOrc[2, 4], 0,,,,,,,,,, oFolPend:aDialogs[1], aHeadSCK, aColsSCK)
			oGetOrcIte:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

			oGetOrcPen:= MsNewGetDados():New(aPOrc[2, 1], aPOrc[2, 2], aPOrc[2, 3], aPOrc[2, 4], 0,,,,,,,,,, oFolPend:aDialogs[2], aHeadGTP, aColsGTP)
			oGetOrcpen:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGetOrcpen:oBrowse:BlDblClick := {|| FS_DbCkGTP()}
		Else
			oGetOrcIte:= MsNewGetDados():New(aPOrc[2, 1], aPOrc[2, 2], aPOrc[2, 3], aPOrc[2, 4], 0,,,,,,,,,, oFolder:aDialogs[2], aHeadSCK, aColsSCK)
		EndIf
	//================================================================¿
	//³ Legendas do Orçamento										 ³
	//================================================================Ù
		@ aPOrc[3, 1]+5, 015 BitMap NAME "BR_AMARELO" SIZE 8, 8 NOBORDER Of  oFolder:aDialogs[2] PIXEL
		@ aPOrc[3, 1]+5, 025 Say STR0019 Of  oFolder:aDialogs[2] PIXEL //"Orc. Pendente"

		@ aPOrc[3, 1]+5, 075 BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of  oFolder:aDialogs[2] PIXEL
		@ aPOrc[3, 1]+5, 085 Say STR0020 Of  oFolder:aDialogs[2] PIXEL // "Pend. Financ."

		@ aPOrc[3, 1]+5, 135 BitMap NAME "BR_AZUL" SIZE 8, 8 NOBORDER Of  oFolder:aDialogs[2] PIXEL
		@ aPOrc[3, 1]+5, 145 Say STR0021 Of  oFolder:aDialogs[2] PIXEL //"Aprovado"

		@ aPOrc[3, 1]+5, 185 BitMap NAME "BR_VERDE" SIZE 8, 8 NOBORDER Of  oFolder:aDialogs[2] PIXEL
		@ aPOrc[3, 1]+5, 195 Say STR0022 Of  oFolder:aDialogs[2] PIXEL // "Liberado"

		@ aPOrc[3, 1]+5, 235 BitMap NAME "BR_PRETO" SIZE 8, 8 NOBORDER Of  oFolder:aDialogs[2] PIXEL
		@ aPOrc[3, 1]+5, 245 Say STR0023 Of  oFolder:aDialogs[2] PIXEL // "Cancelado"

		@ aPOrc[3, 1]+5, 285 BitMap NAME "BR_VIOLETA" SIZE 8, 8 NOBORDER Of  oFolder:aDialogs[2] PIXEL
		@ aPOrc[3, 1]+5, 295 Say STR0024 Of  oFolder:aDialogs[2] PIXEL // "Em tratamento"

		@ aPOrc[3, 1]+5, 345 BitMap NAME "BR_BRANCO" SIZE 8, 8 NOBORDER Of  oFolder:aDialogs[2] PIXEL
		@ aPOrc[3, 1]+5, 355 Say STR0025 Of  oFolder:aDialogs[2] PIXEL // "Finalizado"

// cria os menus
		oMenu02 := tMenu():new(0, 0, 0, 0, .T., , oMenu)
// cria os itens dos menus
		oMenu0201 := tMenuItem():new(oMenu02, STR0026, , , , {|| FS_INCORC(oGetOrc:aCols)}, , , , , , , , , .T.)
		oMenu0202 := tMenuItem():new(oMenu02, STR0027, , , , {|| FS_EFEORC(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat], IIf(lExCobran,oGetOrc:aCols[oGetOrc:nAt, nGt9Cobran],"1")),FS_REOROR(oGetOrc:aCols[oGetOrc:nAt, nGt9NumCli])}, , , , , , , , , .T.)
		oMenu0203 := tMenuItem():new(oMenu02, STR0057, , , , {|| FS_CANORC(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat])}, , , , , , , , , .T.) //"Cancelar"
		oMenu0204 := tMenuItem():new(oMenu02, STR0004, , , , {|| FS_ALTORC(oGetOrc:aCols[oGetOrc:nAt, nGt9NumFat])}, , , , , , , , , .T.) //"Alterar"
		If lPOrcCl
			oMenu0205 := tMenuItem():new(oMenu02, STR0124, , , , {|| FS_GERPEND()}, , , , , , , , , .T.) //"Gerar Pend."
		EndIf
		oMenu02:add(oMenu0201)
		oMenu02:add(oMenu0202)
		oMenu02:add(oMenu0203)
		oMenu02:add(oMenu0204)
		If lPOrcCl
			oMenu02:add(oMenu0205)
		EndIf

		oButton2 := tButton():New(aPOrc[3, 1]+3, 400, STR0102, oFolder:aDialogs[2], {|| }, 050, 010,,,, .T.)    //"Orcamento"
		oButton2:setPopupMenu(oMenu02)

		oMenu0202:Disable() //Desabilita Botão de efetiva para utilização apenas em Status Orc. Pendente
		oMenu0204:Disable() //Desabilita Botão de efetiva para utilização apenas em Status Orc. Pendente
		If !lVisValSb1
			oMenu0201:Disable() //Desabilita inclusão caso o profissional nao visualize valores
		EndIf
		HS_BDados("GT9", @aHGT9Pln, @aCGT9Pln,, 1,, " GT9.GT9_CLIENT = '0000000' AND GT9.GT9_STATUS IN('3','5'" + iIf(lVisPltFin,",'6'","") + ")  ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,, /*aCpoGcy*/,,,"GT9_NUMFAT DESC",)

	//================================================================¿
	//³ Grid dos Orcamentos do Plano de Tratamento					 ³
	//================================================================Ù
		oGetOrcPln:= MsNewGetDados():New(aPTrat[1, 1], aPTrat[1, 2], aPTrat[1, 3], aPTrat[1, 4], 0,,,,,,,,,, oFolder:aDialogs[3], aHGT9Pln, aCGT9Pln)
		oGetOrcPln:oBrowse:bGotFocus := {|| FS_ATUITEM(oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat], .T.)}
		oGetOrcPln:oBrowse:bChange := {|| FS_ATUITEM(oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat],.T.,.T.)}
	//Ponto de Entrada para Ordenar campos na GTJ
		If ExistBlock("HM57GTJORD")
			aCpoSckPln	:= ExecBlock("HM57GTJORD", .F., .F., { aCpoSckPln } )
		EndIf
		HS_BDados("GTJ" , @aHSCKPln, @aCSCKPln,        , 1   ,        , " GTJ.GTJ_NUMORC = '000000' "      ,        ,"GTJ_STATUS","/"     ,         ,        ,        ,        ,        ,.T.     , aLegGTJ,        ,  .T.    ,           ,         ,aCpoSckPln  ,aJoinSckPln,          ,cOrdeSck           )
		nSckStatus := aScan(aHSCKPln, {|aVet| aVet[2] ==  "GTJ_STATUS"})
		nSckProPln := aScan(aHSCKPln, {|aVet| aVet[2] ==  "GTJ_PRODUT"})
		nSckItePln	:=  aScan(aHSCKPln, {|aVet| aVet[2] ==  "GTJ_ITEM  "})

	//================================================================¿
	//³ Grid dos Itens Orcamentos do Plano de Tratamento			 ³
	//================================================================Ù
		@ aPTrat[2, 1], aPTrat[2, 2]+5 Say "Procedimentos:" Of  oFolder:aDialogs[3] PIXEL COLOR CLR_HBLUE FONT oFont
		oGetItePln:= MsNewGetDados():New(aPTrat[2, 1]+7, aPTrat[2, 2], aPTrat[2, 3], aPTrat[2, 4], 0,,,,,,,,,, oFolder:aDialogs[3], aHSCKPln, aCSCKPln)
		oGetItePln:oBrowse:bChange := {|| FS_ATUHIS(oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat], oGetItePln:aCols[oGetItePln:nAt, nSckProPln],oGetItePln:aCols[oGetItePln:nAt,nSckItePln]), nAtIPlnOld := oGetItePln:nAt }
		oGetItePln:oBrowse:bGotFocus := {|| IIf(nAtIPlnOld <> oGetItePln:nAt,FS_ATUHIS(oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat], oGetItePln:aCols[oGetItePln:nAt, nSckProPln],oGetItePln:aCols[oGetItePln:nAt,nSckItePln]),Nil), nAtIPlnOld := oGetItePln:nAt }
		oGetItePln:oBrowse:BlDblClick := {|| Fs_opPlnTrat() }
		oGetItePln:oBrowse:bDelete := {||FS_CANITPL(oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat],oGetItePln:aCols[oGetItePln:nAt, nSckItePln]) }

	//================================================================¿
	//³ Grid do Historico de Atendimento / Observação    			 ³
	//================================================================Ù
		HS_BDados(cAliasHIS, @aHGTC, @aCGTC,, 1,, " " + cAliasHIS + "." + cAliasHIS + "_NUMFAT = '000000' AND " + cAliasHIS + "." + cAliasHIS + "_CODPRO = '000000000000000' ",,,"/",,,,,,.T.,,,,,, aCpoGTC)
		nGTCItem 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_ITEM"})
		nGTCDatHis 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_DATHIS"})
		nGTCHisAte 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_HISATE"})
		If cAliasHIS == "GTC"
			nGTCDenReg 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_DENREG"})
			nGTCDesReg 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_DESREG"})
			nGTCFadent 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_FADENT"})
			nGTCFacDes 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_FACDES"})
		Else
			nGTOCodReg 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_CODREG"})
			nGTODesReg 	:= aScan(aHGTC, {| aVet | AllTrim(aVet[2]) == cAliasHIS + "_DESREG"})
			nGTCDenReg := nGTOCodReg
			nGTCDesReg := nGTODesReg
		EndIf

		If Empty(aCGTC[1, nGTCItem])
		//O codigo de item da primeira linha do grid vai corresponder ao ultimo item+1 do historico associado ao orcamento
			aCGTC[1, nGTCItem] := StrZero(fs_ultItemGT(cAliasHIS, oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat], )+1, Len(GTC->GTC_ITEM))
		EndIf
		@ aPTrat[3, 1], aPTrat[3, 2]+5 Say STR0109 Of  oFolder:aDialogs[3] PIXEL COLOR CLR_HBLUE FONT oFont //"Total do Or‡amento "
		oChkPen := tCheckBox():New(aPTrat[3, 1],aPTrat[3, 4]/2  ,OemToAnsi(STR0110), {|u|if( pcount()>0,lChkPen := u, lChkPen)}, oFolder:aDialogs[3],050,010,,{|| IIf( lChkPen,cFilItPln	:= " AND GTJ_STATUS IN ('0','3','4') ",cFilItPln	:= " " ), FS_ATUITEM(oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat], .T.)  },,,,,,.T.)  // // // //"Urgente"
		oGetHisAte := MsNewGetDados():New(aPTrat[3, 1]+7, aPTrat[3, 2], aPTrat[3, 3]-12, aPTrat[3, 4], nGDOpc,,,/*"+" + cAliasHIS + "_ITEM"*/,,,5000,,,, oFolder:aDialogs[3], aHGTC, aCGTC)
		oGetHisAte:bChange := {|| fs_gChangeGT(cAliasHIS,@oGetHisAte, oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat], nGTCItem)}

	//================================================================¿
	//³ Odontograma/Exame Clinico					    			 ³
	//================================================================Ù
		If cDispTela == "0"
			oTScrollBox1 :=  TScrollBox():New(oFolder:aDialogs[4],aPExCliH[1,1],aPExCliH[1,2],aPExCliH[1,3],aPExCliH[1,4],.T.,.T.,.T.)
			oDrawer := tDrawer():New(aPExCliH[1, 1],aPExCliH[1, 2],oTScrollBox1,aPExCliH[1, 3],aPExCliH[1, 4])
		Else
			oTScrollBox1 :=  TScrollBox():New(oFolder:aDialogs[4],aPExCliV[1,1],aPExCliV[1,2],aPExCliV[1,3],aPExCliV[1,4],.T.,.T.,.T.)
			oDrawer := tDrawer():New(aPExCliV[1, 1],aPExCliV[1, 2],oTScrollBox1,aPExCliV[1, 3],aPExCliV[1, 4])
			oTScrollBox:Align := CONTROL_ALIGN_ALLCLIENT
		EndIf

	// Define cores iniciais
		oDrawer:SetColors(aColors[1], aColors[2])

	// Blocos de código do mouse
		oDrawer:blClicked := {|o,x,y| FS_ADDEXCLI(x,y)}
		oDrawer:OpenImage(cImgOdtGr) //"C:\Protheus\Protheus_Data11_Demo\ODONTOGRAMA2.JPG"

	//================================================================¿
	//³ Grid dos Exames Clinicos					    			 ³
	//================================================================Ù
		HS_BDados(cAliasMPI, @aHMPI, @aCMPI,, 1,, cAliasMPI + "_REGATE = '000000' ",,,"/",,,,,,.T.,,,,,, aCpoMPI,,,IIf(cTipOdtGr == "0","GTH_CODREG","GTD_DENREG"))
		nMPIItem 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == cAliasMPI + "_ITEM"})
		nMPIDatHis 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == cAliasMPI + "_DATHIS"})
		nMPIHisAte 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == cAliasMPI + "_HISATE"})
		If cTipOdtGr == "0"
			nMPICodReg 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == "GTH_CODREG"})
			nMPIDesReg 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == "GTH_DESREG"})
			nMPIDenReg := nMPICodReg
		Else
			nMPIDenReg 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == "GTD_DENREG"})
			nMPIDesReg 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == "GTD_DESREG"})
			nMPIFadent 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == "GTD_FADENT"})
			nMPIFacDes 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == "GTD_FACDES"})
			nMPICodReg	:= nMPIDenReg
		EndIf
	If Hs_ExisDic({{"C",cAliasMPI + "_CODPRO"}},.F.)
		nMPICodPro	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == cAliasMPI + "_CODPRO"})
		nMPIOrcGer	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == cAliasMPI + "_ORCGER"})
		nMPIItemOr 	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == cAliasMPI + "_ITEMOR"})
		If Hs_ExisDic({{"C",cAliasMPI + "_DESPRO"}},.F.)
			nMPIDesPro	:= aScan(aHMPI, {| aVet | AllTrim(aVet[2]) == cAliasMPI + "_DESPRO"})
		endif
	EndIf
		If Empty(aCMPI[1, nMPIItem])
			aCMPI[1, nMPIItem] := StrZero(1, Len(GTD->GTD_ITEM))
		EndIf
		If cDispTela == "0"
			oGetMPI:= MsNewGetDados():New(aPExCliH[2, 1], aPExCliH[2, 2], aPExCliH[2, 3]-15, aPExCliH[2, 4], nGDOpc,,,"+" + cAliasMPI + "_ITEM",,,,,,, oFolder:aDialogs[4], aHMPI, aCMPI)
		Else
			oGetMPI:= MsNewGetDados():New(aPExCliV[2, 1], aPExCliV[2, 2], aPExCliV[2, 3]-15, aPExCliV[2, 4], nGDOpc,,,"+" + cAliasMPI + "_ITEM",,,,,,, oFolder:aDialogs[4], aHMPI, aCMPI)
			oGetMPI:oBrowse:align := CONTROL_ALIGN_RIGHT
		EndIf

		If Empty(cImgOdtGr)
			oFolder:aDialogs[4]:lActive := .F.
		EndIf
	ENDIF
	aAdd(aButtons,     {"PMSRRFSH",   {|| MsgRun(STR0011,, { || FS_REFRESH(DTOS(oCalend:dDiaAtu))})},STR0100, STR0100})    //"Atualiza Dados" ### "Atualiza Dados"
	aAdd(aButtons,     {"S4WB001N",   {|| HS_ObrgPer(aMntPerg[3], aMntPerg[2]) .AND. FS_GRVATEN()}, STR0099,STR0099})    //"Grava Atend." ### "Grava Atend."
	IF lOdonto
		aAdd(aButtons,   {"S4WB001N",   {|| FS_ORDPLN(oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumCli],oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat])}, "Ordena Ficha","Ordena Ficha"})
		aAdd(aButtons,   {"S4WB001N",   {|| FS_GERORC(cAliasMPI)}, STR0098, STR0098})    //"Gera Orçam." ### "Gera Orçam."
		Aadd(aButtons,   {"edit_ocean", {||FS_ChamaFicha()}, STR0097}) //"Ficha de Tratamento"
		If lPOrcCl
			aAdd(aButtons, {"S4WB001N",   {|| FS_PREORC(cAliasMPI)}, STR0125 , STR0125})    //"Pré Orçam."
		EndIf
	ENDIF
	FS_StFolder(.F.)
	If !aCodUsr[1]
		oGetPac:Disable()
	EndIf
	If lPOrcCl .AND. lOdonto
		oFolPend:aDialogs[2]:Disable()
	EndIf
	ACTIVATE MSDIALOG oDlgPE ON INIT EnchoiceBar (	oDlgPE,	{|| nOpcPE := 1, IIF(IIF(lOdonto, fs_vldProExeM57(@oGetOrcPln,@oGetItePln), .T.) .AND. ;
		FS_VLDOK(.T.) .AND. HS_ObrgPer(aMntPerg[3], aMntPerg[2]) .AND. IIF (lMVPromo,PLSPROVER(aPerPro,oFolGetsImg), .T.),;
		(FS_UByName(cChaveLock),oDlgPE:End()), nOpcPE := 0)}, {|| nOpcPE := 0, (FS_UByName(cChaveLock),oDlgPE:End()) },, aButtons)

//================================================================¿
//³ Confirma todas as Anamneses Pendentes Após o fechamento		 ³
//================================================================Ù
	For nL := 1 To Len(aAnmSConf)
		DbSelectArea("GFU")
		DbSetOrder(1)
		If DbSeek(xFilial("GFU") + aAnmSConf[nL,1])
			RecLock("GFU" , .F.)
			GFU->GFU_STANAM := "1"
			GFU->GFU_DATCON := Date()
			GFU->GFU_HORCON := Time()
			MsUnlock()
		EndIf
		If lAltaCli // Realiza alta para os paciente sem confirmação
			DbSelectArea("GCY")
			DbSetOrder(1)
			If DbSeek(xFilial("GCY")+aAnmSConf[nL,2]) //RegAte
				RecLock("GCY", .F.)
				GCY->GCY_DATALT := DDATABASE
				GCY->GCY_HORALT := TIME()
				GCY->GCY_CRMALT := cCrmLog
				GCY->GCY_TPALTA := Padr(cMVTpAltaM, 2)
				GCY->GCY_LOGALT	:= HS_LogArq()
				MsUnLock()
			EndIf

			DbSelectArea("GCZ")
			DbSetOrder(2)
			DbSeek(xFilial("GCZ") + aAnmSConf[nL,2])
			While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .And. GCZ->GCZ_REGATE == aAnmSConf[nL,2]
				If GCZ->GCZ_STATUS == "0" .And. Empty(GCZ->GCZ_DCPARF)
					RecLock("GCZ", .F.)
					GCZ->GCZ_DCPARF := DDATABASE
					MsUnLock()
				Endif
				DbSkip()
			End
		EndIf
	Next nL

//================================================================¿
//³ Realiza Gravação dos Dados 									 ³
//================================================================Ù
	If nOpcPE == 1
		DbSelectArea("GCY")
		DbSetOrder(1)
		DbSeek(xFilial("GCY")+cAtPac)
		FS_GrvM57(.T.,.T.,cCrmLog,,iIf(valType(aMntperg)=="A",aMntperg[2], {}), "G", ,cCdQues,,!Empty(cDirImg))
	EndIf
	FS_UByName(cChaveLock)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FS_DesmCalºAutor  ³Rogerio Tabosa      º Data ³  18/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desmarca e limpa a selecao dos dias do calendario           º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DesmCal(dDataAtu)
	Local dLimpaSele := FirstDay(dDataAtu)

	While CMonth(dLimpaSele) == CMonth(dDataAtu)
		oCalend:addRestri(day(dLimpaSele), CLR_BLACK, CLR_WHITE)
		dLimpaSele  := dLimpaSele + 1
	EndDo
	oCalend:Refresh()
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATUIMG ºAutor  ³Saude                º Data ³  16/11/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para atualizar a imagem do questionario     .        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_ATUIMG(cImg)

	If !Empty(cImg)
		oTBitmap1:Load( , cImg )
		oTBitmap1:Refresh()
	EndIf
Return()

Static Function FS_AddLin(cDirImg)
	oGDGt8:lChgField := .F.
	oGDGt8:AddLine(.T., .F.)
	oGDGt8:lNewLine := .F.
	FS_ALTIMG("", cDirImg)
Return

Static Function FS_ALTIMG(cImg, cDirImg)
	Local cImgRet
	Default cDirImg :=  ""

	If Empty(cImg)
		cImgRet := HS_EDITIMG("", cDirImg, IIf(Empty(cAtPac), "000001",cAtPac))
	Else
		cImgRet := HS_EDITIMG(cImg, cDirImg, IIf(Empty(cAtPac), "000001",cAtPac))
	EndIf

	If !Empty(cImgRet)
		oTBitmap1:Load( , cImgRet )
		oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv] := cImgRet
	Else
		oTBitmap1:SetEmpty()
	EndIf
	oTBitmap1:Refresh()
	oGDGt8:Refresh()

Return


 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATUORC  ºAutor  ³Saude               º Data ³  27/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a atualização do orçamento do paciente na tabela GT9    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºParametros³ 1 - Codigo do paciente para busca do codigo do cliente GBH º±±
±±º          ³ 2 - Codigo do cliente para filtro apenas pelo cliente      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATUORC(cRegGer, cCodCli, cModCobr)
	Local aArea			:= getArea()
	Local cSql			:= ""
	Local nL			:= 0
	Local aSCJ			:= {}
	Local cCond			:= ""
	Local aCtrVig
	Local aVigOrc		:= {} //PE de vigencia do tratamento
	Local dVigIni		:= CTOD("")
	Local dVigFim		:= CTOD("")
	Local lHsfusvig		:= lHsfusvig // Ponto de Entrada da Vigencia do tratamento

	Default cRegGer 	:= ""
	Default cCodCli 	:= ""
	Default cModCobr	:= "0"

/* *****************************************************************************
				BUSCA CODIGO DO CLIENTE DO CADASTRO DE PACIENTE
********************************************************************************/
	If Empty(cCodCli) .AND. !Empty(cRegGer)
	GBH->(DbSetOrder(1))
		If DbSeek(xFilial("GBH") + cRegGer, .F.)
			If !Empty(GBH->GBH_CODCLI)
				cCodCli := GBH->GBH_CODCLI
			Else
				HS_MSGINF(STR0028,STR0029, STR0030)//"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"
				Return()
			EndIf
		Else
			HS_MSGINF(STR0028,STR0029, STR0030)//"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"
			Return()
		EndIf
	EndIf

	If !Empty(cCodCli)
		cCond := " AND SCJ.CJ_CLIENTE = '" + cCodCli + "'"
	EndIf

/* *****************************************************************************
VERIFICA SE EXISTE ALGUM ORÇAMENTO DO FATURAMENTO SCJ QUE NÃO ESTA INSERIDO
NO LOJA (SL1) E NO GH(GT9) APÓS A UTILIZAÇÃO DA ROTINA DE EFETIVAÇÃO DO ORÇAMENTO
********************************************************************************/
cSql := " SELECT CJ_NUM, CJ_STATUS, CJ_CLIENTE, CJ_EMISSAO, CJ_VALIDA FROM " + RetSqlName("SCJ") + " SCJ "
	cSql += " WHERE SCJ.D_E_L_E_T_ = ' ' AND SCJ.CJ_FILIAL = '" + xFilial("SCJ") + "' " + cCond // Concatena Codigo do Cliente caso exista
	cSql += " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("GT9") + " GT9 WHERE GT9.GT9_NUMFAT = SCJ.CJ_NUM AND "
	cSql += " GT9.D_E_L_E_T_ = ' ' AND GT9.GT9_FILIAL = '" + xFilial("GT9") + "')"
	If cModCobr == "1" // Para cobrança particular verfica no Loja
		cSql += " UNION "
	cSql += " SELECT CJ_NUM, CJ_STATUS, CJ_CLIENTE, CJ_EMISSAO, CJ_VALIDA "
		cSql += " FROM " + RetSqlName("SCJ") + " SCJ "
		cSql += " JOIN " + RetSqlName("GT9") + " GT9 ON GT9_NUMLOJ = '" + SPACE(TamSx3("GT9_NUMLOJ")[1]) + "'"
		cSql += " AND GT9_NUMFAT = CJ_NUM AND GT9.GT9_FILIAL = '" + xFilial("GT9") + "' AND GT9.D_E_L_E_T_ = ' '
		cSql += " WHERE CJ_STATUS = 'B' AND SCJ.CJ_FILIAL = '" + xFilial("SCJ") + "' AND SCJ.D_E_L_E_T_ = ' ' " + cCond // Concatena Codigo do Cliente caso exista
	EndIf

	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYORC"

	DbSelectArea("QRYORC")
	While !Eof()
	AADD(aSCJ, {QRYORC->CJ_NUM, QRYORC->CJ_STATUS, QRYORC->CJ_CLIENTE, QRYORC->CJ_EMISSAO, IIf(!Empty(cRGerSel) .AND. !Empty(cCond),cRGerSel,""), QRYORC->CJ_VALIDA  } )
		DbSkip()
	EndDo
	DbCloseArea()

	If Len(aSCJ) > 0
		If cModCobr == "1" // Para cobrança particular insere no Loja
			MsgRun(STR0031,, { || HS_AtuLoja(aSCJ, cUsername)})  //"Aguarde, atualizando venda..."
		Else
			For nL := 1 To Len(aSCJ)
				DbSelectArea("SCJ")
				DbSetorder(1)
				DbSeek(xFilial("SCJ") + aSCJ[nL,1])
				RecLock("GT9", .T.)
				GT9->GT9_FILIAL := xFilial("GT9")
				GT9->GT9_NUMFAT	:= aSCJ[nL,1]
				GT9->GT9_CLIENT	:= aSCJ[nL,3]
				GT9->GT9_USUORC	:= cUsername
				GT9->GT9_DTEMIS	:= STOD(aSCJ[nL,4])
				GT9->GT9_STATUS	:= '0'
				GT9->GT9_COBRAN	:= '0'
				If !Empty(cCond)		//HS_ExisDic({{"C", "GT9_REGGER"}},.F.) .AND.
					GT9->GT9_REGGER	:= cRGerSel
				EndIf

				aCtrVig := HS_GETNRCTR(SA1->A1_COD)
					dVigIni := IIf(Empty(aCtrVig[2]), STOD(aSCJ[nL,4]), STOD(aCtrVig[2]))
					dVigFim := IIf(Empty(aCtrVig[3]), STOD(aSCJ[nL,6]), STOD(aCtrVig[3]))
				If lHsfusvig // Ponto de Entrada da Vigencia do tratamento
					aVigOrc := ExecBlock("HSFUSVIG", .F., .F., {aSCJ[nL,1], SA1->A1_COD})
					If ValType(aVigOrc) == "A"
						dVigIni := aVigOrc[1]
						dVigFim := aVigOrc[2]
					EndIf
				EndIf
				GT9->GT9_NRCONT	:= aCtrVig[1]//HS_GETNRCTR(SA1->A1_COD)
				GT9->GT9_VIGINI	:= dVigIni
				GT9->GT9_VIGFIN	:= dVigFim
				If ValType("__cCdJustGT9") # "U" .AND. !Empty(__cCdJustGT9) //.AND. HS_ExisDic({{"C", "GT9_MTVAGE"}},.F.)
					GT9->GT9_MTVAGE := __cCdJustGT9
					GT9->GT9_USRFOR := __cCdUsrFGT9
					__cCdJustGT9 	:= ""
					__cCdUsrFGT9	:= ""
				EndIf
				MsUnlock()
				FS_GRVGTJ(aSCJ[nL,1])
			Next nL
		EndIf
	Else
		FS_GRVGTJ(SCJ->CJ_NUM)
	EndIf

	RestArea(aArea)
Return()


 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATUITEM ºAutor  ³Saude               º Data ³  27/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a atualização dos itens do orçamento no GRID 		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATUITEM(cNumFat, lPlnTrat, lPlnTratChg)

	Local aArea 		:= GetArea()
	Default lPlnTrat 	:= .F.
	Default lPlnTratChg	:= .F.

	If !lPlnTrat
		aColsSCK := {}
		HS_BDados("SCK" , @aHeadSCK, @aColsSCK, , 1,, " SCK.CK_NUM = '" + cNumFat + "' ",,, "/",,,,,, .T.,,, .T.,,, aCpoSck, aJoinSck,, cOrdeSck)
		oGetOrcIte:setArray(aColsSCK)
		oGetOrcIte:oBrowse:Refresh()
		If oGetOrc:aCols[oGetOrc:NaT,nGt9Status] == "BR_AMARELO" .AND. lVisValSb1
			oMenu0202:Enable()
			oMenu0204:Enable()
		Else
			oMenu0202:Disable()
			oMenu0204:Disable()
		EndIf
		If oGetOrc:aCols[oGetOrc:NaT,nGt9Status] == "BR_AZUL"
			oMenu0203:Disable()
		Else
			oMenu0203:Enable()
		EndIf
	Else  //Grid do Plano de tratamento
		aCSCKPln := {}
		HS_BDados("GTJ" , @aHSCKPln, @aCSCKPln,, 1,, " GTJ.GTJ_NUMORC = '" + cNumFat + "' " + cFilItPln,,"GTJ_STATUS","/",,,,,,.T., aLegGTJ,,.T.,,,aCpoSckPln  ,aJoinSckPln,,cOrdeSck)
		oGetItePln:setArray(aCSCKPln)
		oGetItePln:oBrowse:Refresh()
		oGetOrcPln:oBrowse:SetFocus() //Importante: Atualiza Historico de Tramento
		oGetItePln:oBrowse:SetFocus() //Importante: Atualiza Historico de Tramento

		//Atualizar Historico do Tratamento apos posicionamento do orçamento	
		FS_ATUHIS(oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat], oGetItePln:aCols[oGetItePln:nAt, nSckProPln],oGetItePln:aCols[oGetItePln:nAt,nSckItePln])

	EndIf
	RestArea(aArea)

Return

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LOADPAC ºAutor  ³Saude               º Data ³  27/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os dados do paciente e habilita alteração		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LOADPAC(cRegAte)

	Local aArea 		:= GetArea()
	Local nL			:= 0
	local nI            := 0
	Local cCodCli		:= ""
	Local aControl 		:= {}
	Local nX			:= 0
	local lGcyCodSal    := .t.	//HS_ExisDic({{"C", "GCY_CODSAL"}},.F.)
	local lGcyDiniac    := .t.	//HS_ExisDic({{"C", "GCY_DINIAC"}},.F.)
	local cUsuHsp       := Space(15)
	local aCodUsrPss    := {}
	local lGcyUsucPa    := .t.	//HS_ExisDic({{"C", "GCY_USUCPA"}},.F.)
	local lGcyUsuRat    := .t. 	//HS_ExisDic({{"C", "GCY_USURAT"}},.F.)
	local lPnlCli       := SuperGetMV("MV_PNLCLI", NIL, .F.)
	local lPerg         := .F.
	Local cCndGT9		:= ""
	Local cMatvid		:= ""

	Private nColPosGcy    := oGetPac:oBrowse:nColPos

	if nColPosGcy == nGcyOk .or. nColPosGcy == nHspStareg
		cChaveAtu := "M57GCY" + oGetPac:aCols[oGetPac:nAt, nGcyRegAte]
		if !FS_LByName(cChaveAtu )
			HS_MsgInf(STR0096, STR0029, STR0035)  //"Paciente está em atendimento com outro profissional!" ### "Atenção", "Validação Prontuário Clinicas"
			Return(Nil)
		endif

	//Verifica se ha algum paciente selecionado, se houver, passa ate confirmacao de gravacao do paciente selecionado anteriormente
		if !fs_isPacSel(@oGetPac)
			lPerg := .T.
			if !(fs_isPerAtuPac(oGetPac:aCols[oGetPac:nAt, nGcyNome]))//Nome do paciente
				Return(Nil)
			endif
		endif

		If Empty(cRegAte)
			Return(Nil)
		EndIf

	//================================================================¿
	//³ Paciente já esta selecionado								 ³
	//================================================================Ù
		If !FS_VLDOK()
			Return(Nil)
		EndIf

		aAuxGTC	:= {}
		lAtuGTC := .F.

	//================================================================¿
	//³ Salva os dados do atendimento anterior caso tenha iniciado	 ³
	//================================================================Ù
		If nAtPac <> 0 .AND. cAtPac <> cRegAte
			If MsgYesNo(STR0032 + Alltrim(oGetPac:aCols[nAtPac, nGcyNome]) + "?", STR0029) //"Deseja gravar o atendimento do paciente: " "Atenção"
				If oGetPac:aCols[oGetPac:nAt, nHspStareg] == "BR_VERMELHO" .AND. lPnlCli .AND. lAltaCli
					HS_MsgInf(STR0093, STR0029, STR0035)  //"Paciente ainda não chegou para atendimento, não pode ser dispensado!""Atenção", "Validação Prontuário Clinicas"
				Else
				//================================================================¿
				//³ Posiciona no registro de atendimento anterior	 ³
				//================================================================Ù
					DbSelectArea("GCY")
					DbSetOrder(1)
					DbSeek(xFilial("GCY") + cAtPac)
				// Joga dados do atendimento na memoria
					DbSelectArea("GCY")
					RegToMemory("GCY", .F.)
				// Joga dados do paciente na memoria
					DbSelectArea("GBH")
					DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
					DbSeek(xFilial("GBH") + GCY->GCY_REGGER)
					RegToMemory("GBH", .F.)
					FS_GrvM57(.T.,.F.,cCrmLog,,iIf(valType(aMntperg)=="A",aMntperg[2], {}), "G", ,cCdQues,,!Empty(cDirImg))
				EndIf
			EndIf
		EndIf
	//Verifica se deve exibir mensagem ao medico confirmando alteracao do status do atendimento ao paciente
		if !lPerg .AND. !(fs_isPerAtuPac(oGetPac:aCols[oGetPac:nAt, nGcyNome]))
			Return(Nil)
		endif
		If SuperGetMV("MV_PSSCPE", NIL, .F.)
			If FS_VldSenhM57(@cUsuHsp,@cUsrPass)
				If !(aCodUsrPss := HS_VldDAnm(.T.,,cUsuHsp))[1]
					return
				else
					cCrmLog   := aCodUsrPss[2]
					cEspUsu   := HS_REspMed(cCrmLog)
					cEspecMed := "'"+StrTran(cEspUsu,"/","','")+"'"
				EndIf
			else
				return
			endif
		endif

	//================================================================¿
	//³ Gravação dos campos que indicam inicio do atendimento medico ³
	//================================================================Ù
		DbSelectArea("GCY")
		DbSetOrder(1)
		DbSeek(xFilial("GCY") + cRegAte)
		If lGcyDiniac .AND. IIf(lPnlCli,empty(oGetPac:aCols[oGetPac:nAt, nGcyDiniac]),.T.) .AND. cAtPac <> cRegAte .AND. lMudMPI
			HS_ChgMapIm()
		EndIf

		RecLock("GCY",.F.)
		GCY->GCY_DINIPE := IIf(!Empty(GCY->GCY_DINIPE) .AND. nColPosGcy == nHspStareg,GCY->GCY_DINIPE,dDataBase)
		GCY->GCY_HINIPE := IIf(!Empty(GCY->GCY_HINIPE) .AND. nColPosGcy == nHspStareg,GCY->GCY_HINIPE,Time())
		if lGcyCodSal
			GCY->GCY_CODSAL := IIf(Empty(GCY->GCY_CODSAL),cCodSala, GCY->GCY_CODSAL)
		endif
		if lGcyUsucPa
			GCY->GCY_USUCPA := IIf(Empty(GCY->GCY_USUCPA),cCrmLog, GCY->GCY_USUCPA)
		endif
		MsUnlock()

		if nColPosGcy == nHspStareg
			if lGcyDiniac
				if !empty(oGetPac:aCols[oGetPac:nAt, nGcyDinipe]) .and. !empty(oGetPac:aCols[oGetPac:nAt, nGcyHinipe]) .and. empty(oGetPac:aCols[oGetPac:nAt, nGcyDiniac]) .and. empty(oGetPac:aCols[oGetPac:nAt, nGcyHiniac])
					RecLock("GCY",.F.)
					GCY->GCY_DINIAC  := dDataBase
					GCY->GCY_HINIAC  := Time()
					if lGcyUsuRat
						GCY->GCY_USURAT := cCrmLog
					endif
					MsUnlock()
					if lPnlCli
						FS_StFolder(.T.)
					endif
				endif
			endif
		endif

		//Atualizando dados do grid
		for nI := 1 to len(aLegGCY)
			if &(aLegGCY[nI,1])
				oGetPac:aCols[oGetPac:nAt, nHspStareg] := aLegGCY[nI,2]
				oGetPac:aCols[oGetPac:nAt, nGcyDinipe] := GCY->GCY_DINIPE
				oGetPac:aCols[oGetPac:nAt, nGcyHinipe] := GCY->GCY_HINIPE
				oGetPac:aCols[oGetPac:nAt, nGcyDiniac] := GCY->GCY_DINIAC
				oGetPac:aCols[oGetPac:nAt, nGcyHiniac] := GCY->GCY_HINIAC
				exit
			endif
		next nI
		oGetPac:oBrowse:Refresh()
		//================================================================¿
		//³ Paciente já esta selecionado								 ³
		//================================================================Ù

		If cAtPac == cRegAte
			Return(Nil)
		EndIf


	//================================================================¿
	//³ Posiciona no registro de atendimento do paciente do Grid	 ³
	//================================================================Ù
		DbSelectArea("GCY")
		DbSetOrder(1)
		DbSeek(xFilial("GCY") + cRegAte)
	// Joga dados do atendimento na memoria
		RegToMemory("GCY", .F.)
		DbSelectArea("GCZ")
		DbSetOrder(2)
		DbSeek(xFilial("GCZ") + cRegAte)
		cPlaAte	:= GCZ->GCZ_CODPLA
		cGuiAte := GCZ->GCZ_NRSEQG

		DbSelectArea("GA9")
		DbSetOrder(1)
		DbSeek(xFilial("GA9") + GCZ->GCZ_CODCON)

		cCobranca 	:= GA9->GA9_TIPCON
		cRedPro		:= GA9->GA9_REDPRO
	//================================================================¿
	//³ Atualiza o Orçamento do Paciente							 ³
	//================================================================Ù
		FS_ATUORC(GCY->GCY_REGGER,,cCobranca)
	//================================================================¿
	//³ Atualiza o Status do Orçamento do Paciente				     ³
	//================================================================Ù
		HS_STATORC(GCY->GCY_REGGER)
	// Joga dados do paciente na memoria
		DbSelectArea("GBH")
		DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
		DbSeek(xFilial("GBH") + GCY->GCY_REGGER)
		RegToMemory("GBH", .F.)
	//================================================================¿
	//³ Codigo do Cliente do cadastro de paciente 					 ³
	//================================================================Ù
		cCodCli := GBH->GBH_CODCLI
		cCliPad := GBH->GBH_CODCLI
		cRGerSel:= GBH->GBH_CODPAC
		If Empty(cCodCli)
			HS_MSGINF(STR0028,STR0029, STR0030)  // "Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"
			Return()
		EndIf

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1") + cCodCli)

		cLojPad := SA1->A1_LOJA

	//================================================================¿
	//³ Desmarca outros registros marcados e deixa apenas selecionado ³
	//================================================================Ù
		oGetPac:aCols[oGetPac:nAt, nGcyOk] := "LBTIK"
		For nL := 1 To Len(oGetPac:aCols)
			If oGetPac:aCols[nL, nGcyOk] == "LBTIK" .AND. nL <> oGetPac:nAt
				oGetPac:aCols[nL, nGcyOk] := "LBNO"
			EndIf
		Next nL

		oGetPac:oBrowse:Refresh()
		nAtPac	:= oGetPac:nAt
		cAtPac	:= cRegAte
		nRegGcy	:= GCY->(Recno())
		cNPPac	:= GCY->GCY_REGGER
		oFolder:nOption := 1
	//================================================================¿
	//³ Atualiza Anamnese sem confirmação							 ³
	//================================================================Ù
		DbSelectArea("GFU")
		DbSetOrder(2) //GFU_FILIAL+GFU_REGATE+GFU_CODCRM+GFU_TPANAM+GFU_STANAM
		If DbSeek(xFilial("GFU") + cRegAte + cCrmLog + "00")
			HS_BusResp("GFK", {{"GFK->GFK_CDANAM", GFU->GFU_CDANAM}, {"GFK->GFK_CDQUES", cCDQues}}, "PER")

			aMntperg := HS_MntPerg(cCDQues, oFolGetsImg:aDialogs[1],, aPFolAna[1], .F., "PER", "oEncPer",, "aTelaPer", CONTROL_ALIGN_ALLCLIENT, .F., "G"/*cAcesso*/)
		//================================================================¿
		//³ Lista Imagens												 ³
		//================================================================Ù
			If !Empty(cDirImg)
				aCGt8 := {}
				aHGt8 := {}
				HS_BDados("GT8", @aHGt8, @aCGt8, , 1,, "GT8->GT8_CHAVE = '" + GFU->GFU_CDANAM + "'",, ,,,,,,,, ,,,,,, ,, )
				oGDGt8:SetArray(aCGt8)
				oGDGt8:oBrowse:Refresh()
				FS_ATUIMG(oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv],.T.)
			EndIf
		Else
		//================================================================¿
		//³ Limpa variaveis do questionario anterior 					  ³
		//================================================================Ù
			HS_LIMPQUEST()
		//Linha 1483 comentada para ajuste visual dos campos com consulta padrão(F3) conf chamado TIDUMS - Thiago Fonseca
		//aMntperg := HS_MntPerg(cCdQues, oFolGetsImg:aDialogs[1],, aPFolAna[1], .F., "PER", "oEncPer",, "aTelaPer", CONTROL_ALIGN_ALLCLIENT, .F., "G")
		EndIf

		IF lOdonto
	//================================================================¿
	//³ Atualiza Grid de orçamentos									 ³
	//================================================================Ù
			aColsGT9Or := {}
			HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_REGGER = '" + cRgerSel + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
			oGetOrc:setArray(aColsGT9Or)
			oGetOrc:oBrowse:Refresh()
			oGetOrc:oBrowse:SetFocus()

	//================================================================¿
	//³ Atualiza Pendencias Criticadas								 ³
	//================================================================Ù
			If lPOrcCl // .AND. Hs_ExisDic({{"T","GTP"}},.F.)	 // HS_ExisDic({{"C", "GT9_COBRAN"}},.F.)
				FS_ATUPEN(cAtPac)
			EndIf
	//================================================================¿
	//³ Atualiza Grid de orçamentos	 do Plano de tratamento			 ³
	//================================================================Ù
			aCGT9Pln := {}
			If lExGt9RegGer .AND. !Empty(cRGerSel)
				cCndGT9 := " AND (GT9.GT9_REGGER = '" + cRGerSel + "' OR GT9.GT9_REGGER = '" + SPace(TamSx3("GT9_REGGER")[1]) + "')"
			EndIf

			HS_BDados("GT9", @aHGT9Pln, @aCGT9Pln,, 1,, " GT9.GT9_REGGER = '" + cRgerSel + "' AND GT9.GT9_STATUS IN('3','5'" + iIf(lVisPltFin,",'6'","") + ") " + cCndGT9,,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")

			oGetOrcPln:setArray(aCGT9Pln)
			oGetOrcPln:oBrowse:Refresh()
			oGetOrcPln:oBrowse:SetFocus()
			oGetItePln:nAt := 1
			FS_ATUHIS(oGetOrcPln:aCols[1, nGt9NumFat], oGetItePln:aCols[1, nSckProPln],oGetItePln:aCols[1,nSckItePln])
			oGetItePln:oBrowse:Refresh()
			oGetItePln:oBrowse:SetFocus() //Importante: Atualiza Historico de Tramento

	//================================================================¿
	//³ Atualiza Grid de Exame CLinico e Mapeamento de Imagem  		  ³
	//================================================================Ù
			aCMPI := {}
			HS_BDados(cAliasMPI, @aHMPI, @aCMPI,, 1,, cAliasMPI + "_REGATE = '" + cRegAte + "' AND " + cAliasMPI + "_CODCFG = '" + cCodOdtGr + "' ",,,"/",,,,,,.T.,,,,,, aCpoMPI,,,IIf(cTipOdtGr == "0","GTH_CODREG","GTD_DENREG"))

			If Empty(aCMPI[1, nMPIItem])
				aCMPI[1, nMPIItem] := StrZero(1, Len(GTD->GTD_ITEM))
			EndIf
			oGetMPI:setArray(aCMPI)
			oGetMPI:oBrowse:Refresh()

	//================================================================¿
	//³ Limpa totais da Aba de Orçamento  							 ³
	//================================================================Ù
			aControl := oDlgPE:aControls
			For nX := 1 To Len(aControl)
				If ( ValType(aControl[nX])=="O")
					If ( ValType(aControl[nX]:Cargo)=="C")
						Do Case
						Case ( aControl[nX]:Cargo $ STR0018) //"Total"
							aControl[nX]:SetText(0)
						Case ( aControl[nX]:Cargo $ STR0017 ) //"Desconto"
							aControl[nX]:SetText(0)
						Case ( aControl[nX]:Cargo $ STR0016) //"Valor"
							aControl[nX]:SetText(0)
						EndCase
					EndIf
				EndIf
			Next nX
		ENDIF
	
	//================================================================¿
	//³ Habilita o folder para alterações							 ³
	//================================================================Ù
		if lPnlCli
			if !empty(GCY->GCY_DINIAC)//oGetPac:aCols[oGetPac:nAt, nHspStaReg] == "BR_VERDE"
				FS_StFolder(.T.)
			else
				FS_StFolder(.F.)
			endif
		else
			FS_StFolder(.T.)
		endif
	endif

//	Não utiliza Painel de Chamadas
	IF !lPnlCli .AND. oGetPac:aCols[oGetPac:nAt, nHspStareg] == "BR_VERMELHO"
		FS_LOADPAC(cRegAte)
	ENDIF

 //Atualiza Dados referente a Promoção da Saude
	If lMVPromo
		PLSFOREFR(cRgerSel)
	Endif

//Exibe os Alerta da promoção Saude
	If lMVPromo
		PLSPROEXAL(oGetBOM:aCols,oGetBOM:aCols[oGetBOM:nAt, nGetCODPRO], oGetBOM:aCols[oGetBOM:nAt, nGetVida], nGetCODPRO,oGetBOM:aCols[oGetBOM:nAt, nGetRISCO],nGetRISCO)
	Endif
	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GrvM57  ºAutor  ³ Saude             º Data ³  07/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que confirma a Anamnese.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GrvM57(lInclui, lConfirma, cCodCrm, cGfuTpAnam, aCposGrv, cAcesso, cAnmOri, cCdQues, cTpNasc, lImagem)

	Local nForMne := 0
	Local cMnSele := ""
	Local cOldCrm  := ""
	Local aTabDesp := {"GD5","GD6","GD7"}
	Local nCntFor  := 0
	Local nLI		:= 0
	Local lAltaCli	:= SuperGetMV("MV_ALTACLI", NIL, .F.)  // Alta após confirmar o atendimento
	Local lSenProPac:= SuperGetMV("MV_PSSCPE", NIL, .F.)
	Local cMatvid	:=""
	Local ni		:=0

	Default cAnmOri := Space(TamSx3("GFU_ANMORI")[1])		//IIF(Hs_ExisDic({{"C","GFU_ANMORI"}}),Space(TamSx3("GFU_ANMORI")[1]),"")
	Default lConfirma	:= .T.
	Default lInclui		:= .T.
	Default cGfuTpAnam	:= "0"
	Default lImagem		:= .F.
	Default cTpNasc  	:= ""

	IF lOdonto
	//================================================================¿
	//³Grava itens do Plano de Tratamento                             ³
	//================================================================ÄÙ
		FS_GRVGTC(oGetItePln:nAt)

	//================================================================¿
	//³Grava exame clinico                                            ³
	//================================================================ÄÙ
		If !Empty(cCodOdtGr)
			FS_GRVGTD(cCodOdtGr, GCY->GCY_REGATE)
		EndIf
	ENDIF

	/* Grava GFU */
	If lInclui
		M->GFU_CDANAM := HS_VSxeNum("GFU", "M->GFU_CDANAM", 1)
		ConfirmSx8()
		RecLock("GFU", .T.)
		GFU->GFU_FILIAL	:= xFilial("GFU")
		GFU->GFU_REGATE	:= GCY->GCY_REGATE
		GFU->GFU_CDANAM	:= M->GFU_CDANAM
		GFU->GFU_TPANAM	:= cGfuTpAnam
		GFU->GFU_REGGER	:= GCY->GCY_REGGER
		GFU->GFU_NOMPAC := IIf (!Empty(cTpNasc), HS_INIPADR("GB2", 1, GCY->GCY_REGATE + cTpNasc,"GB2_NOME",,.F.), GCY->GCY_NOME)
		GFU->GFU_CODCRM	:= cCodCrm
		GFU->GFU_STANAM	:= "0"
		GFU->GFU_CDQUES	:= cCdQues
		GFU->GFU_CODESP	:= Hs_Inipadr("GFS",1, cCdQues, "GFS_CODESP")
		GFU->GFU_ANMORI	:= cAnmOri
		MsUnlock()
	EndIf

	If lConfirma
		RecLock("GFU", .F.)
		GFU->GFU_STANAM := "1"
		GFU->GFU_DATCON := Date()
		GFU->GFU_HORCON := Time()
		MsUnlock()
	Else
		AADD(aAnmSConf, {GFU->GFU_CDANAM, GCY->GCY_REGATE})
	EndIf
//================================================================¿
//³Gravação da imagem                                             ³
//================================================================ÄÙ
	If lImagem .AND. lInclui
		For nLI := 1 To Len(oGDGT8:aCols)
			If !oGDGT8:aCols[nLI, Len(oGDGT8:aHeader) + 1] .AND. !Empty(oGDGT8:aCols[nLI , nGT8Arquiv])
				DbSelectArea("GT8")
				DbSetOrder(1)
				If !DbSeek(xFilial("GT8") + GFU->GFU_CDANAM + oGDGT8:aCols[nLI , nGT8Arquiv])
					RecLock("GT8", .T.)
					GT8->GT8_FILIAL	:= xFilial("GT8")
					GT8->GT8_CHAVE := GFU->GFU_CDANAM
					GT8->GT8_ARQUIV := oGDGT8:aCols[nLI , nGT8Arquiv]
					MsUnlock()
				EndIf
			EndIf
		Next nLI
	EndIf

	If cGfuTPAnam == "0" // Somente para anamneses
		DbSelectArea("GCY")
		DbSetOrder(1)
		DbSeek(xFilial("GCY")+GCY->GCY_REGATE)
		RecLock("GCY", .F.)

		If Len(aCodUsr) < 3 .Or. aCodUsr[3]
			GCY->GCY_CRMANM := cCodCrm
		EndIf

		If cAcesso == "E"
			GCY->GCY_STATUS := "1"
			GCY->GCY_DTPTRI := dDataBase
			GCY->GCY_HRPTRI := Time()
		ElseIf !lConfirma
			GCY->GCY_STATUS := "2"
			GCY->GCY_DTANAM := dDataBase
			GCY->GCY_HRANAM := Time()
		Else
			GCY->GCY_STATUS := IIF(HS_PosGfu(GCY->GCY_REGATE, aCodUsr[2], "00",.T.) .Or. HS_PosGfu(GCY->GCY_REGATE, aCodUsr[2], "10",.T.),GCY->GCY_STATUS,"3")
			GCY->GCY_DTACON := dDataBase
			GCY->GCY_HRACON := Time()
		EndIf

		If lConfirma .AND. lAltaCli
			GCY->GCY_DATALT := DDATABASE
			GCY->GCY_HORALT := TIME()
			GCY->GCY_CRMALT := cCodCrm
			GCY->GCY_TPALTA := Padr(SuperGetMV("MV_TPALTAM", NIL, "01"), 2)
			if lSenProPac
				GCY->GCY_LOGALT	:= cUsrPass + " - " + StrZero(Day(Date()), 02) + "/" + StrZero(Month(Date()), 02) + "/" + Str(Year(Date()), 04) + " - " + Time() + "h"
			else
				GCY->GCY_LOGALT	:= HS_LogArq()
			endif
		EndIf
		MsUnLock()
	EndIf

	If lConfirma .AND. lAltaCli
		DbSelectArea("GCZ")
		DbSetOrder(2)
		DbSeek(xFilial("GCZ") + GCY->GCY_REGATE)
		While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .And. GCZ->GCZ_REGATE == GCY->GCY_REGATE
			If GCZ->GCZ_STATUS == "0" .And. Empty(GCZ->GCZ_DCPARF)
				RecLock("GCZ", .F.)
				GCZ->GCZ_DCPARF := GCY->GCY_DATALT
				MsUnLock()
			Endif
			DbSkip()
		End
	EndIf

	if len(aCposGrv) > 0
	// Grava Repositorio de Respostas do Prontuário
		if lMVPromo
			aPerPro:=HS_GrvResp("GFK", {{"GFK->GFK_CDANAM", GFU->GFU_CDANAM}, {"GFK->GFK_CDQUES", GFU->GFU_CDQUES}}, aCposGrv)
		Else
			HS_GrvResp("GFK", {{"GFK->GFK_CDANAM", GFU->GFU_CDANAM}, {"GFK->GFK_CDQUES", GFU->GFU_CDQUES}}, aCposGrv)
		Endif

		DbSelectArea("GHP")
		DbSetOrder(1)
		DbSeek(xFilial("GHP") + GFU->GFU_CDQUES)
		While !GHP->(Eof()) .And. GHP->GHP_FILIAL == xFilial("GHP") .And. GHP->GHP_CDQUES == GFU->GFU_CDQUES
			HS_ABTExec(GHP->GHP_CODFUN)
			GHP->(DbSkip())
		End

	//Grava na tabela GCH todos os codigos dos mnemonicos selecionados para a pergunta
		If Len(aMneSele) > 0
			For nForMne := 1 To Len(aMneSele)
				DbSelectArea("GCH")
				DbSetOrder(1)
				If DbSeek(xFilial("GCH") + aMneSele[nForMne, 1]) .And. !(aMneSele[nForMne, 2] $ GCH->GCH_MNESEL)
					cMnSele := cMnSele + IIF(!Empty(AllTrim(cMnSele)), "/", "") + aMneSele[nForMne, 2] //código sequencial do mnemonico
				EndIf
			Next
			If !Empty(cMnSele)
				RecLock("GCH", .F.)
				GCH->GCH_MNESEL := cMnSele + "/"
				MsUnLock()
			EndIf
		EndIf

		If !Empty(GFS->GFS_FUNCAO)
			&(GFS->GFS_FUNCAO)
		EndIf
	endif

	If ExistBlock("HSIMPANAM")
		ExecBlock("HSIMPANAM", .F., .F., aCposGrv)
	EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_INCORC  ºAutor  ³ Saude             º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada da inclusão de orçamento do faturamento             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INCORC(AcolsOrc)
	Local aArea 	:= GetArea()
	Local nStack	:= GetSX8Len()
	Local lOrcLib	:= .T.
	Local nPosLib   := 0
	Local nPosTrat  := 0
	Local aOrca		:= {}

//================================================================
//Chamada da rotina para Verificar se Existe Orcamento liberado  |
//									                             |
//================================================================
	nPosLib  := aScan(AcolsOrc, {| aVet | aVet[1] == "BR_VERDE"})
	nPosTrat := aScan(AcolsOrc, {| aVet | aVet[1] == "BR_VIOLETA"})
	If  nPosLib > 0 .or. nPosTrat > 0
		If lSupervisor
			aOrca:=FS_VerOrc()
			lOrcLib:=aOrca[1]
			If !lOrcLib
				Return()
			Else
				__cCdJustGT9 := aOrca[2]
				__cCdUsrFGT9 := aOrca[3]
			Endif
		Else
			__cCdJustGT9 := HS_Justif()
			__cCdUsrFGT9 := __CUSERID
		Endif

			DbSelectArea("GDN")
			GDN->(dbSetOrder(1))
			If GDN->(DbSeek(xFilial("GDN") + cCodLoc))
				HSPAHP44(.T., cCodLoc, {{"GBH", 1, cRgerSel}, {"SA1", 1, cCliPad}, {"GCY", 1, cAtPac}})
			EndIf
	Endif
//================================================================
//Chamada da rotina automatica para criação das variaveis        |
//necessárias e execução dos Ajustas                             |
//================================================================
	MATA415({},{},3)
	MATA410({},{},3)
//================================================================¿
//³Chamada da Inclusão do Orçamento                               ³
//================================================================Ù
	If A415Inclui("SCJ",1,3,Nil,,cCliPad,cLojPad)
		FS_ATUORC("", cCliPad, cCobranca)

		aColsGT9Or := {}

//	HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_CLIENT = '" + cCliPad + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
		HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_REGGER = '" + cRgerSel + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
		oGetOrc:setArray(aColsGT9Or)
		oGetOrc:oBrowse:Refresh()
		oGetOrc:oBrowse:SetFocus()
		While GetSX8Len() > nStack
			RollBackSX8()
		EndDo
	Else
		While GetSX8Len() > nStack
			RollBackSX8()
		EndDo
	EndIf

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_EFEORC  ºAutor  ³ Saude             º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada da efetivação de orçamento do faturamento           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EFEORC(cNOrc, cModCobr)
	Local aArea 	:= GetArea()
	Local nRecno	:= 0
	Local nL		:= 0
	Local cCodDes	:= ""
	Local aGeISol	:= {}
	Local cCodSol	:= ""
	Local lRet		:= .T.
	Local dDatAtOrc := GetNewPar("MV_RDCDTOR","")
//Caso seja cobrança por convenio faz as validações iniciais de guia plano e etc...
//HS_VPROPLS(cRegGer, cCodPla, cCodCrm, cCodPro, dDatAut)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se data do parametro MV_RDCDTOR inferior a 11/04/2013, altera para    ³
//³ esta data pois e a data de correcao da gravacao do GTJ_ITEPAI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(dDatAtOrc) .And. Dtos(dDatAtOrc) < '20130411'
		dDatAtOrc := Stod('20130411')
	EndIf

	If cModCobr == "0" .AND. lExCobran
		For nL := 1 To Len(oGetOrcIte:aCols)
			cCodDes := PADR(oGetOrcIte:aCols[nL, nSckProdut], TAMSX3("GA7_CODPRO")[1])
			DbSelectArea("GA7")
			DbSetOrder(1)
			If DbSeek(xFilial("GA7") + cCodDes) .AND. GA7->GA7_VINSB1 = "1"
				If cRedPro == "1"
					If !HS_VPROPLS(cRGerSel, cPlaAte, cCrmLog, cCodDes, dDataBase, .T.)
						lRet := .F.
					EndIf
				Else
					If !(lAut := Hs_DespAut("GE3", cPlaAte, cCodDes, , "4"))
						If !HS_VProced(cPlaAte, cCodLoc, cCodDes,,,,,,,,, dDataBase,,oGetOrcIte:aCols[nL, nCKQTDVEN])
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Endif
		Next nL
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os itens foram deletados do orcamento                     ³
//³ OBS: So atualiza itens lancados depois da data da correcao do chamado ³
//³ TGRZ14. Itens anteriores foram gravados com o GTJ_ITEPAI incorreto    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SCJ->(DbSetOrder(1))//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
	If SCJ->(DbSeek(xFilial("SCJ")+cNOrc))
		GTJ->(DbSetOrder(1))//GTJ_FILIAL+GTJ_NUMORC+GTJ_ITEM
		SCK->(DbSetOrder(1))//CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
		GT9->(DbSetOrder(1))//GT9_FILIAL+GT9_NUMFAT+GT9_NUMLOJ
		If !Empty(dDatAtOrc) .And. GT9->GT9_DTEMIS >= dDatAtOrc .And. GT9->(DbSeek(xFilial("GT9")+cNOrc)) .And. GTJ->(DbSeek(xFilial("GTJ")+cNOrc))
			While GTJ->(GTJ_FILIAL+GTJ_NUMORC) == xFilial("GTJ")+cNOrc .And. !GTJ->(Eof())
				If GTJ->GTJ_STATUS <> "2" .And. !SCK->(DbSeek(xFilial("SCK")+GTJ->(GTJ_NUMORC+Iif(Empty(GTJ->GTJ_ITEPAI),GTJ->GTJ_ITEM,GTJ_ITEPAI))))
					GTJ->(RecLock("GTJ", .F.))
					GTJ->GTJ_STATUS := "2"
					GTJ->(MsUnlock())
				EndIf
				GTJ->(DbSkip())
			EndDo
		EndIf
	EndIf

	If !lRet
		Return()
	EndIf

	DbSelectArea("SCJ")
	DbSetOrder(1)
	If Empty(cNOrc) .OR. !DbSeek(xFilial("SCJ") + cNOrc)
		Return()
	EndIf
	nRecno := Recno()

	MATA415({},{},3) //Chamada da rotina automatica para criação das variaveis necessárias e execução dos Ajustas

	While __lSx8
		RollBackSxe()
	End
//MATA416({},{},3)
	DbSelectArea("SCJ")
	DbGoTo(nRecno)
	A415Baixa("SCJ",nRecno,4)

	While __lSx8
		RollBackSxe()
	End

	If cModCobr == "0" .AND. lExCobran  .AND. cRedPro <> "1"//Verifica procedimentos que necessitam de autorização
		DbSelectArea("SCJ")
		DbGoTo(nRecno)
		If SCJ->CJ_STATUS == 'B'
			For nL := 1 To Len(oGetOrcIte:aCols)
				cCodDes := PADR(oGetOrcIte:aCols[nL, nSckProdut], TAMSX3("GA7_CODPRO")[1])
				DbSelectArea("GA7")
				DbSetOrder(1)
				If DbSeek(xFilial("GA7") + cCodDes) .AND. GA7->GA7_VINSB1 = "1"
					If (lAut := Hs_DespAut("GE3", cPlaAte, cCodDes, , "4"))
						AADD(aGeISol, {cCodDes,oGetOrcIte:aCols[nL, nCKQTDVEN], cGuiAte})
					EndIf
				Endif
			Next nL
			If Len(aGeISol) == 0 // Caso nenhum procedimento precise de alteração orçamento esta liberado para tratamento
				DbSelectArea("GT9")
				DbSetOrder(1)
				If DbSeek(xFilial("GT9") + cNOrc)
					RecLock("GT9", .F.)
					GT9->GT9_STATUS := "3"
					MsUnlock()
				EndIf
			Else
				cCodSol := FS_GrvSol(cAtPac,aGeISol)
				If !Empty(cCodSol)
					DbSelectArea("GT9")
					DbSetOrder(1)
					If DbSeek(xFilial("GT9") + cNOrc)
						RecLock("GT9", .F.)
						GT9->GT9_CODSOL := cCodSol
						GT9->GT9_STATUS := "2"
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cRedPro == "1" .AND. cModCobr == "0"
		DbSelectArea("GT9")
		DbSetOrder(1)
		If DbSeek(xFilial("GT9") + cNOrc)
			RecLock("GT9", .F.)
			GT9->GT9_STATUS := "3"
			MsUnlock()
		EndIf
	EndIf

	FS_ATUORC("", cCliPad, cModCobr)

	aColsGT9Or := {}

//HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_CLIENT = '" + cCliPad + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
	HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_REGGER = '" + cRgerSel + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
	oGetOrc:setArray(aColsGT9Or)
	oGetOrc:oBrowse:Refresh()
	oGetOrc:oBrowse:SetFocus()

	RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LSTPAC  ºAutor  ³ Rogerio Tabosa    º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista pacientes de acordo com a Data e Desabilita os controlº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LSTPAC(cDatAte)
	Local aArea := GetArea()

	If lTelaOK .AND. !Empty(oGetPac:aCols[nAtPac, nGcyNome]) // Se estiver am atendimento Atualiza Orçamento, Caso contrario Atualiza os pacientes.
		If MsgYesNo(STR0032 + Alltrim(oGetPac:aCols[nAtPac, nGcyNome]) + "?", STR0029) //"Deseja gravar o atendimento do paciente: " "Atenção"
		//================================================================¿
		//³ Posiciona no registro de atendimento anterior	 ³
		//================================================================Ù
			DbSelectArea("GCY")
			DbSetOrder(1)
			DbSeek(xFilial("GCY") + cAtPac)
		// Joga dados do atendimento na memoria
			DbSelectArea("GCY")
			RegToMemory("GCY", .F.)
		// Joga dados do paciente na memoria
			DbSelectArea("GBH")
			DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
			DbSeek(xFilial("GBH") + GCY->GCY_REGGER)
			RegToMemory("GBH", .F.)
			FS_GrvM57(.T.,.F.,cCrmLog,,iIf(valType(aMntperg)=="A",aMntperg[2],{})	, "G", ,cCdQues,,!Empty(cDirImg))
		EndIf
	EndIf

	Inclui := .F.
	aColsPac := {}

//================================================================¿
//³ Busca Atendimentos de Acordo com o Profissional e Local de At³
//================================================================Ù
	If nFiltro == 2
		HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODCRM = '" + cCrmLog + "' AND GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + cDatAte +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'",.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,,,, aCpoGcy,aJoinGcy)
	ElseIf nFiltro == 3 // Todos pacientes
		HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + cDatAte +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'",.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,lHsPrEl57,,,aCpoGcy,aJoinGcy,,cOrdGcy,,,)
	Else // nFiltro == 1
		HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + cDatAte +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'" + ;
			" AND EXISTS (" + ;
			"SELECT 1 FROM " + retSqlName("GCZ") + " GCZ" + ;
			" JOIN " + retSqlName("GCY") + " GCYY ON GCZ.GCZ_REGATE = GCYY.GCY_REGATE" + ; //LINHA ADICIONAL
		" JOIN " + retSqlName("GD7") + " GD7" + ;
			" ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GD7.GD7_FILIAL ='" +xFilial("GD7") +"' AND GD7.D_E_L_E_T_<>'*'" + ;
			" AND GCZ.GCZ_FILIAL ='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_<>'*'" + ;
			" JOIN " + retSqlName("GA7") + " GA7" + ;
			" ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GD7.GD7_CODDES" + ;
			" AND GA7_CODESP IN (" + cEspecMed + ")" + ;
			" AND GA7.GA7_FILIAL ='" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_<>'*'" + ;
			" WHERE GCZ_REGATE = GCY_REGATE AND GCZ.GCZ_FILIAL ='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_<>'*'" + ;
			")"  ;
			,.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,,,, aCpoGcy,aJoinGcy)
	Endif

//HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODCRM = '" + cCrmLog + "' AND GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + cDatAte +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'",,,"/",,,,{"GCY_OK"},{"'LBNO'"},.T.,,,,,, aCpoGcy)
	oGetPac:setArray(aColsPac)
	oGetPac:oBrowse:Refresh()
	nAtPac		:= 0
	cAtPac		:= ""
	cRGerSel    := ""
	cNPPac		:= ""
	oFolder:nOption := 1
	FS_StFolder(.F.)
//oTimer:DeActivate()

	RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ORCTotal ³ Autor ³Saude                ³ Data ³ 27.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totalizacao do orcamento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ORCTotal(oDlgPE, cNOrc)
	Local aArea   	:= GetArea()
	Local nTotVal 	:= 0
	Local nTotDesc	:= 0
	Local nPerDesc  := 0
	Local nX  		:= 0
	Local aControl
//Local nL		:= 0

/*If nCKPRUNIT == 0
	Return()
EndIf*/
	aControl := oDlgPE:aControls

	DbSelectArea("SCJ")
	DbSetOrder(1)
	If Empty(cNOrc) .OR. !DbSeek(xFilial("SCJ") + cNOrc)
		Return()
	EndIf
	RegToMemory("SCJ", .F.)

	nPerDesc  := M->CJ_DESC4
//=======================================================¿
//³Soma o os valores e os descontos, mostrando-os na tela³
//=======================================================Ù

	DbSelectArea("SCK")
	DbSetOrder(1)
	If DbSeek(xFilial("SCK") + cNOrc)
		While !Eof() .AND. SCK->CK_NUM == cNOrc
			nTotVal  += SCK->CK_VALOR
			If (SCK->CK_PRUNIT > SCK->CK_PRCVEN )
				nTotDesc += A410Arred((SCK->CK_PRUNIT * SCK->CK_QTDVEN),"CK_VALOR") - A410Arred((SCK->CK_PRCVEN * SCK->CK_QTDVEN),"CK_VALOR")
			Else
				nTotDesc += SCK->CK_VALDESC
			EndIf
			DbSkip()
		EndDo
	EndIf
/*For nL := 1 To Len(oGetOrcIte:aCols)
	nTotVal  += oGetOrcIte:aCols[nL,nCKVALOR]
	If (oGetOrcIte:aCols[nL,nCKPRUNIT] > oGetOrcIte:aCols[nL,nCKPRCVEN] )
		nTotDesc += A410Arred((oGetOrcIte:aCols[nL,nCKPRUNIT] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR") - A410Arred((oGetOrcIte:aCols[nL,nCKPRCVEN] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR")
	Else
		nTotDesc += oGetOrcIte:aCols[nL,nCKVALDESC]
	EndIf

Next nL*/
	nTotDesc += M->CJ_DESCONT
	nTotVal  -= M->CJ_DESCONT
	nTotDesc += A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")
	nTotVal  -= A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")
//=======================================================¿
//³Calcula o Desconto por Total                          ³
//=======================================================Ù
/*If nTotVal > 0 .And. FtRegraDesc(4,nTotVal+nTotDesc,M->CJ_DESC4) <> nPerDesc
	//=======================================================¿
	//³Soma o os valores e os descontos, mostrando-os na tela³
	//=======================================================?
	nTotVal := 0
	nTotDesc:= 0
	For nL := 1 To Len(oGetOrcIte:aCols)
		nTotVal  += oGetOrcIte:aCols[nL,nCKVALOR]
		If (oGetOrcIte:aCols[nL,nCKPRUNIT] > oGetOrcIte:aCols[nL,nCKPRCVEN] )
			nTotDesc += A410Arred((oGetOrcIte:aCols[nL,nCKPRUNIT] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR") - A410Arred((oGetOrcIte:aCols[nL,nCKPRCVEN] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR")
		Else
			nTotDesc += oGetOrcIte:aCols[nL,nCKVALDESC]
		EndIf
	Next nL
EndIf */

//================================================================¿
//³Soma as variaveis da Enchoice                                  ³
//================================================================?
	nTotVal += M->CJ_FRETE
	nTotVal += M->CJ_SEGURO
	nTotVal += M->CJ_DESPESA
	nTotVal += M->CJ_FRETAUT

//================================================================¿
//³Joga os totais na tela para o objeto correspondente            ³
//================================================================?
	For nX := 1 To Len(aControl)
		If ( ValType(aControl[nX])=="O")
			If ( ValType(aControl[nX]:Cargo)=="C")
				Do Case
				Case ( aControl[nX]:Cargo $ STR0018) //"Total"
					aControl[nX]:SetText(nTotVal)
				Case ( aControl[nX]:Cargo $ STR0017 ) //"Desconto"
					aControl[nX]:SetText(nTotDesc)
				Case ( aControl[nX]:Cargo $ STR0016) //"Valor"
					aControl[nX]:SetText(nTotVal+nTotDesc)
				EndCase
			EndIf
		EndIf
	Next nX

	RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATUHIS  ºAutor  ³ Rogerio Tabosa    º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza historico do atendimento do plano de tratamento    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATUHIS(cNOrc, cProduto, cItemOr)
	Local aArea   	:= GetArea()
	Local cCondHIS  := ""
	Default cItemOr := ""

If HS_ExisDic({{"C", cAliasHIS + "_ITEMOR"}},.F.)
	cCondHIS := " AND " + cAliasHIS + "_ITEMOR = '" + cItemOr + "' "
EndIf

	aCGTC := {}
	HS_BDados(cAliasHIS, @aHGTC, @aCGTC,, 1,, " " + cAliasHIS + "." + cAliasHIS + "_NUMFAT = '" + cNOrc + "' AND " + cAliasHIS + "." + cAliasHIS + "_CODPRO = '" + cProduto + "' " + cCondHIS,,,"/",,,,,,.T.,,,,,, aCpoGTC)
	If Empty(aCGTC[1, nGTCItem])
	//aCGTC[1, nGTCItem] := StrZero(1, Len(GTC->GTC_ITEM))
	//O codigo de item da primeira linha do grid vai corresponder ao ultimo item+1 do historico associado ao orcamento
		aCGTC[1, nGTCItem] := StrZero(fs_ultItemGT(cAliasHIS, oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat], )+1, Len(GTC->GTC_ITEM))
	EndIf

	oGetHisAte:setArray(aCGTC)
	oGetHisAte:oBrowse:Refresh()

	If Empty(cProduto)
		oGetHisAte:Disable()
	Else
		oGetHisAte:Enable()
	EndIf
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRVGTC  ºAutor  ³ Rogerio Tabosa    º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava historico do atendimento do plano de tratameto        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRVGTC(nAtPai)
	Local aArea		:= GetArea()
	Local lSeek		:= .F.
	Local nL		:= 0
	Local cNOrc		:= ""
	Local cProd		:= ""
	Local cItemOr	:= ""
Local lExItemOr	:= .T.		//HS_ExisDic({{"C", cAliasHIS + "_ITEMOR"}},.F.)
	Local aItens

	Default nAtPai 	:= 0

//GTC_FILIAL+GTC_NUMFAT+GTC_ITEMOR

	If Empty(oGetHisAte:aCols[1,nGTCHisAte])
		Return()
	EndIf

	If nAtPai = 0
		cNOrc := PADR(oGetOrcPln:aCols[oGetOrcPln:nAt,nGt9NumFat], TAMSX3(cAliasHIS + "_NUMFAT")[1])
		cProd := PADR(oGetItePln:aCols[oGetItePln:nAt,nSckProPln], TAMSX3(cAliasHIS + "_CODPRO")[1])
		cItemOr := StrZero(Val(oGetItePln:aCols[oGetItePln:nAt,nSckItePln]), Len(SCK->CK_ITEM))
	Else
		cNOrc := PADR(oGetOrcPln:aCols[IIf(lAtuGTC, nAtPai, oGetOrcPln:nAt),nGt9NumFat] , TAMSX3(cAliasHIS + "_NUMFAT")[1])
		cProd := PADR(oGetItePln:aCols[IIf(!lAtuGTC, nAtPai, oGetItePln:nAt),nSckProPln] , TAMSX3(cAliasHIS + "_CODPRO")[1])
		cItemOr := StrZero(Val(oGetItePln:aCols[IIf(!lAtuGTC, nAtPai, oGetItePln:nAt),nSckItePln]), Len(SCK->CK_ITEM))
	EndIf

	If Empty(cNOrc) .OR. Empty(cProd)
		Return()
	EndIf

	DbSelectArea(cAliasHIS)
	DbSetOrder(IIf(lExItemOr,2,1))

	For nL := 1 To Len(oGetHisAte:aCols)
		lSeek := DbSeek(xFilial(cAliasHIS) + cNOrc + IIf(lExItemOr,cItemOr,cProd) + oGetHisAte:aCols[nL, nGTCItem])
		If oGetHisAte:aCols[nL, Len(oGetHisAte:aHeader)+1 ] == .T. .AND. lSeek // Se a linha esta deletada na get e achou o kra no banco
			RecLock(cAliasHIS, .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2(cAliasHIS)
	
		ElseIf !oGetHisAte:aCols[nL, Len(oGetHisAte:aHeader)+1]
			RecLock(cAliasHIS, !lSeek )
			HS_GRVCPO(cAliasHIS, oGetHisAte:aCols, oGetHisAte:aHeader, nL)
			&(cAliasHIS + "->" + cAliasHIS + "_FILIAL") := xFilial(cAliasHIS)
			&(cAliasHIS + "->" + cAliasHIS + "_NUMFAT")	:= cNOrc
			&(cAliasHIS + "->" + cAliasHIS + "_CODPRO")	:= cProd
			If lExItemOr
				&(cAliasHIS + "->" + cAliasHIS + "_ITEMOR")	:= cItemOr
			EndIf
			MsUnlock()
		EndIf
	Next nL

//lAtuGTC := .F.
	RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_STATORC ºAutor  ³ Rogerio Tabosa    º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza Status do Orçamento no Do GH (GT9)                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_STATORC(cRegGer, cCodCli, lMsg)
	Local aArea		:= getArea()
	Local cSql		:= ""
	Local cNewStat  := ""
	Local lExCobran	:=  .T.		//HS_ExisDic({{"C", "GT9_COBRAN"}},.F.)
	Local dDatAtOrc := GetNewPar("MV_RDCDTOR","")

	Default cRegGer := ""
	Default cCodCli := ""
	Default lMsg	:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se data do parametro MV_RDCDTOR inferior a 11/04/2013, altera para    ³
//³ esta data pois e a data de correcao da gravacao do GTJ_ITEPAI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(dDatAtOrc) .And. Dtos(dDatAtOrc) < '20130411'
		dDatAtOrc := Stod('20130411')
	EndIf
/* *****************************************************************************
				BUSCA CODIGO DO CLIENTE DO CADASTRO DE PACIENTE
********************************************************************************/
	If Empty(cCodCli) .AND. !Empty(cRegGer)
		DbSelectArea("GBH")
		DbSetOrder(1)
		If DbSeek(xFilial("GBH") + cRegGer)
			If !Empty(GBH->GBH_CODCLI)
				cCodCli := GBH->GBH_CODCLI
			Else
				If lMsg
					HS_MSGINF(STR0028,STR0029, STR0030)    //"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"
				EndIf
				Return()
			EndIf
		Else
			If lMsg
				HS_MSGINF(STR0028,STR0029, STR0030)    //"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"
			EndIf
			Return()
		EndIf
	EndIf

	If Empty(cCodCli)
		Return()
	EndIf

	DbSelectArea("GT9")
	DbSetorder(2)
	If !DbSeek(xFilial("GT9") + cCodCli)
		Return()
	EndIf

	cSql := " SELECT GT9_NUMFAT, GT9_NUMLOJ" + IIf(lExCobran, ",GT9_CODSOL","") + ",GT9_STATUS, GT9_DTEMIS FROM " + RetSqlName("GT9") + " GT9 "
	cSql += " WHERE GT9.GT9_CLIENT = '" + cCodCli + "' AND GT9.D_E_L_E_T_ <> '*' AND GT9.GT9_FILIAL = '" + xFilial("GT9") + "' "

	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYORC"

/* {{ 'SCJ->CJ_STATUS=="A"' , 'ENABLE' },; 					//Orcamento em Aberto
	{ 'SCJ->CJ_STATUS=="B"' , 'DISABLE'},;					//Orcamento Baixado
	{ 'SCJ->CJ_STATUS=="C"' , 'BR_PRETO'},;					//Orcamento Cancelado
	{ 'SCJ->CJ_STATUS=="D"' , 'BR_AMARELO'},;				//Orcamento nao Orcado
	{ 'SCJ->CJ_STATUS=="F"' , 'BR_MARROM' }}				//Orcamento bloqueado*/
	DbSelectArea("QRYORC")
	If !Eof()
		While !QRYORC->(Eof())
			If !Empty(QRYORC->GT9_NUMLOJ)
				cNewStat := FS_VERSTLOJ(QRYORC->GT9_NUMLOJ, QRYORC->GT9_STATUS)
				If cNewStat == "BR_VERMELHO"  // Venda Finalizada
					cNewStat := "3"
				ElseIf cNewStat == "BR_PINK" //Venda Cancelada
					cNewStat := "4"
				ElseIf cNewStat == "BR_AZUL" .AND. QRYORC->GT9_STATUS == "3" //Não autorizado
					cNewStat := "2"
				Else
					cNewStat := ""
				EndIf
			ElseIf IIf(lExCobran, !Empty(QRYORC->GT9_CODSOL) ,.F.)
				DbSelectArea("GNX")
				DbSetOrder(1)
				If DbSeek(xFilial("GNX") + QRYORC->GT9_CODSOL)
					If !(GNX->GNX_STATUS $ '01')
						If  GNX->GNX_STATUS == "2"
							cNewStat := "3"
						ElseIf GNX->GNX_STATUS == "4"
							cNewStat := "4"
						Else
							cNewStat := "2" //Não autorizado
						EndIf
					EndIf
				EndIf
			Else
				DbSelectArea("SCJ")
				DbSetOrder(1)
				If DbSeek(xFilial("SCJ") + QRYORC->GT9_NUMFAT)
					If SCJ->CJ_STATUS == "C" //Orçamento Cancelado
						cNewStat := "4"
					Else
						cNewStat := ""
					EndIf
				EndIf
			EndIf
			If !Empty(cNewStat)
				DbSelectArea("GT9")
				DbSetOrder(1)
				If DbSeek(xFilial("GT9") + QRYORC->GT9_NUMFAT)
					If GT9->GT9_STATUS <> cNewStat .AND. GT9->GT9_STATUS <> "6" .AND. GT9->GT9_STATUS <> "4"
						RecLock("GT9", .F.)
						GT9->GT9_STATUS	:= cNewStat
						MsUnlock()
					EndIf
				EndIf
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se os itens foram deletados do orcamento                     ³
		//³ OBS: So atualiza itens lancados depois da data da correcao do chamado ³
		//³ TGRZ14. Itens anteriores foram gravados com o GTJ_ITEPAI incorreto    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SCJ->(DbSetOrder(1))//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
			If !Empty(dDatAtOrc) .And. QRYORC->GT9_DTEMIS >= DtoS(dDatAtOrc) .And. SCJ->(DbSeek(xFilial("SCJ")+QRYORC->GT9_NUMFAT))
				GTJ->(DbSetOrder(1))//GTJ_FILIAL+GTJ_NUMORC+GTJ_ITEM
				SCK->(DbSetOrder(1))//CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
				If GTJ->(DbSeek(xFilial("GTJ")+QRYORC->GT9_NUMFAT))
					While GTJ->(GTJ_FILIAL+GTJ_NUMORC) == xFilial("GTJ")+QRYORC->GT9_NUMFAT .And. !GTJ->(Eof())
						If GTJ->GTJ_STATUS <> "2" .And. !SCK->(DbSeek(xFilial("SCK")+GTJ->(GTJ_NUMORC+Iif(Empty(GTJ->GTJ_ITEPAI),GTJ->GTJ_ITEM,GTJ_ITEPAI))))
							GTJ->(RecLock("GTJ", .F.))
							GTJ->GTJ_STATUS := "2"
							GTJ->(MsUnlock())
						EndIf
						GTJ->(DbSkip())
					EndDo
				EndIf
			EndIf
			QRYORC->(DbSkip())
		EndDo
	EndIf
	DbSelectArea("QRYORC")
	DbCloseArea()

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VERSTLOJºAutor  ³Saude              º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define o Status do orçamento no loja de acordo com a regra º±±
±±º          ³ do                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERSTLOJ(cNum, cStatGT9)
	Local aArea		:= GetArea()
	Local lLjPedVe	:= SuperGetMV("MV_LJPEDVE", NIL, .F.) //Verifica se utiliza emissao de Pedidos de Venda
	Local lPosPed	:= .F.
	Local cRet		:= ""

	DEFAULT cStatGT9 := "" // Status

	dbSelectArea("SM0")
	dbGotop()

	DbSelectArea("SL1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SL1") +cNum)
		Return("")
	EndIf

	lPosPed := SL1->(FieldPos("L1_PEDRES")) > 0 .AND. SLQ->(FieldPos("LQ_PEDRES")) > 0	//Verifica se os campos L1_PEDRES e LQ_PEDRES estao criados

	IF !Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_SERIE) .AND. AllTrim(SL1->L1_STATUS) == "T"
		cRet := "BR_BRANCO"			//"Transação TEF desfeita"
	EndIf
	If !Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_SERIE) .AND. SL1->L1_STATUS <> "D" .AND. SL1->L1_STATUS <> "F"
		cRet := "BR_VERMELHO"		//"Vendas efetuadas"
	EndIf
	If Empty(SL1->L1_DOC) .AND. Empty(SL1->L1_RESERVA) .AND. dDataBase<=SL1->L1_DTLIM .AND. SL1->L1_STATUS <> "D" .AND. IIf(SL1->(FieldPos("L1_STORC")) >0, SL1->L1_STORC <> "C", .T.)
		cRet := "BR_VERDE"			//"Orçamentos em aberto"
	EndIf
	If lLjPedVe .AND. lPosPed
		If Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D" .AND. Empty(SL1->L1_PEDRES)
			cRet := "BR_AMARELO"	//"Orcamentos com reservas"
		EndIf
		If Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D" .AND. !Empty(SL1->L1_PEDRES)
			cRet := "BR_LARANJA"	//"Orcamentos com Pedidos de Venda"
		EndIf
	Else
		If Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D"
			cRet := "BR_AMARELO"	//"Orcamentos com reservas"
		EndIf
	EndIf

	If Empty(SL1->L1_DOC) .AND.  Empty(SL1->L1_RESERVA) .AND. dDataBase>SL1->L1_DTLIM  .AND. SL1->L1_STATUS<>"D" .AND. IIf(SL1->(FieldPos("L1_STORC")) > 0 , SL1->L1_STORC <> "C" , .T.)
		cRet := "BR_PRETO"			//"Orcamentos em aberto vencidos"
	EndIf
	If Empty(SL1->L1_DOC) .AND. SL1->L1_TIPO=="P"       .AND. !Empty(SL1->L1_DOCPED)   .AND. SL1->L1_STATUS<>"D"
		cRet := "BR_AZUL"			//"Pedidos encerrados"
	EndIf
	If cStatGT9 == "3" .AND. Empty(SL1->L1_DOC+SL1->L1_SERIE) .AND. SL1->L1_STATUS<>"D"
		cRet := "BR_AZUL"			//"Pedidos encerrados" - por Exclusão de Nota (LOJA140)
	EndIf
	If SL1->L1_STATUS="D"
		cRet := "BR_MARROM"			//"Devoluções pendentes"
	EndIf
	If LjNfPafEcf(SM0->M0_CGC)
		If Empty(SL1->L1_DOC) .AND. SL1->(FieldPos("L1_STORC")) > 0 .AND. SL1->L1_STORC == "C"
			cRet := "BR_PINK"		//"Orçamentos Cancelados"
		EndIf
	Else
		If Empty(SL1->L1_DOC) .AND. LjAnalisaLeg(6)[1] .AND. SL1->(FieldPos("L1_STORC")) > 0 .AND. SL1->L1_STORC == "C"
			cRet := "BR_PINK"			//"Orçamentos Cancelados"
		EndIf
	EndIf
	If SL1->(FieldPos("L1_NUMFRT")) > 0
		If SL1->L1_STATUS = "F" .AND. SL1->L1_SITUA = "FR" .AND. !Empty(SL1->L1_NUMFRT)
			cRet := "BR_CINZA"		//"Orcamnetos pagos no FrontLoja"
		EndIf
		If (!Empty(SL1->L1_DOC) .OR. !Empty(SL1->L1_DOCPED)) .AND. SL1->L1_STATUS = "F" .AND. Empty(SL1->L1_NUMFRT) .AND. !Empty(SL1->L1_NUMORIG)
			cRet := "BR_AZUL"			//"Pedidos encerrados"
		EndIf
	EndIf

	RestArea(aArea)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ADDEXCLIºAutor  ³Saude              º Data ³  04/01/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona exame clinico de acordo com dente/reg selecionado º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ADDEXCLI(nX, nY)
/*Local aCoordenada := {{'18  ','DI   ',{17,148}, {37,148}, {20,159}, {34,159}},;
					  {'17  ','IL   ',{273,145}, {290,145}, {276,161}, {288,161}}}*/
	Local nL	:= 0
	Local nMenX	:= 0
	Local nMenY	:= 0
	Local nMaiX	:= 0
	Local nMaiY	:= 0
	Local cCodReg	:= ""
	Local cFace		:= ""
	Local cObsHisAte    := ""
	Local cProduto  := ""
	Local lRet 	    := .F.
	Local lIncOld   := Inclui
	Local aRetObs	:= {}
local lCodPro   := .T.		//Hs_ExisDic({{"C",cAliasMPI + "_CODPRO"}},.F.)
local lDesPro   := .T.		//Hs_ExisDic({{"C",cAliasMPI + "_DESPRO"}},.F.)

	If Empty(aCoordOdg)
		Return(.T.)
	EndIf

	aCoordenada := aClone(aCoordOdg)

	For nL := 1 To Len(aCoordenada)
		nMenX := Iif(aCoordenada[nL,3,1] > aCoordenada[nL,5,1], aCoordenada[nL,5,1], aCoordenada[nL,3,1])
		nMenY := Iif(aCoordenada[nL,3,2] > aCoordenada[nL,4,2], aCoordenada[nL,4,2], aCoordenada[nL,3,2])

		nMaiX := Iif(aCoordenada[nL,4,1] > aCoordenada[nL,6,1], aCoordenada[nL,6,1], aCoordenada[nL,4,1])
		nMaiY := Iif(aCoordenada[nL,5,2] > aCoordenada[nL,6,2], aCoordenada[nL,5,2], aCoordenada[nL,6,2])

		If nX > nMenX .AND. nX < nMaiX .AND. nY > nMenY .AND. nY < nMaiY  .AND. Empty(cCodReg)
			cCodReg	:= aCoordenada[nL, 1]
			cFace	:= aCoordenada[nL, 2]
			Exit
		EndIf
	Next nL

	If !Empty(cCodReg) //.AND. (IIf(cTipOdtGr == "1",!Empty(cFace),.T.))
		lRet := .T.
		aRetObs := FS_OBSDENTE()
		cObsHisAte 	:= aRetObs[1]
		cProduto	:= aRetObs[2]
		If !Empty(cProduto)
			If !(Len(oGetMPI:aCols) <= 1 .AND. Empty(oGetMPI:aCols[1, IIf(cTipOdtGr == "1",nMPIDenReg,nMPICodReg)]))
				oGetMPI:AddLine(.T., .F.)
				oGetMPI:lNewLine := .F.
			EndIf
			Inclui := .F.

			If cTipOdtGr == "1"
				oGetMPI:aCols[Len(oGetMPI:aCols), nMPIDenReg] := cCodReg
				oGetMPI:aCols[Len(oGetMPI:aCols), nMPIDesReg] := HS_INIPADR('B04',1,cCodReg,'B04_DESCRI')
				oGetMPI:aCols[Len(oGetMPI:aCols), nMPIFadent] := cFace
				oGetMPI:aCols[Len(oGetMPI:aCols), nMPIFacDes] := HS_INIPADR('B09',1,cFace,'B09_FACDES')
			Else
				oGetMPI:aCols[Len(oGetMPI:aCols), nMPICodReg] := cCodReg
				oGetMPI:aCols[Len(oGetMPI:aCols), nMPIDesReg] := HS_INIPADR('GTI',1,cCodReg,'GTI_DESCRI')
			EndIf
			If lCodPro
				oGetMPI:aCols[Len(oGetMPI:aCols), nMPICodPro] := cProduto
				if lDesPro
					oGetMPI:aCols[Len(oGetMPI:aCols), nMPIDesPro] := Posicione('SB1',1,xFilial('SB1')+cProduto,'B1_DESC')
				endif
			EndIf

			oGetMPI:aCols[Len(oGetMPI:aCols), nMPIHisAte] := cObsHisAte
			oGetMPI:oBrowse:Refresh()
			Inclui := lIncOld
		EndIf
	EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_OdnGram ºAutor  ³Rogerio Tabosa      º Data ³  04/01/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para apresentar os odontogramas  para seleção.       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_OdnGram(cCond)

	Local aArea    := GetArea()
	Local aHGTE    := {}
	Local aCGTE    := {}
	Local nIDMARK  := 0
	Local nOpcA    := 0
	Local oGTE
	Local cCdOdont  := ""
	Local nFor     := 0
	Local nUGTE    := 0
	Local aJoin    := {}
	Local lExbTela := .F.
	Local cSql     := ""

	If (nUGTE := HS_BDados("GTE", @aHGTE, @aCGTE,, 1,, cCond,,,,,,, "GTE_IDMARK", "'LBNO'")) > 1
		lExbTela := .T.
		nGTEIDMARK := aScan(aHGTE, {| aVet | aVet[2] == "GTE_IDMARK"})
		nGTECODIGO := aScan(aHGTE, {| aVet | aVet[2] == "GTE_CODIGO"})

		aSize    := MsAdvSize(.T.)
		aObjects := {}
		AAdd(aObjects, {100, 100, .T., .T.})

		aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
		aPObjs := MsObjSize(aInfo, aObjects, .T.)

		nOpcA := 0
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0033) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Odontograma"

		oGTE := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4],,,,,,,,,,,, aHGTE, aCGTE)
		oGTE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGTE:oBrowse:BlDblClick := {|| FS_DblClik(oGTE)}

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(FS_OdgSel(oGTE), oDlg:End(), nOpcA := 0)}, ;
			{|| nOpcA := 0, oDlg:End()})
		If nOpcA == 1

			For nFor := 1 To Len(oGTE:aCols)
				If oGTE:aCols[nFor, nGTEIDMARK] == "LBTIK"
					cCdOdont := oGTE:aCols[nFor, nGTECODIGO]
					Exit
				EndIf
			Next
		EndIf

	ElseIf (nUGTE == 1)
		nGTEIDMARK := aScan(aHGTE, {| aVet | aVet[2] == "GTE_IDMARK"})
		nGTECODIGO := aScan(aHGTE, {| aVet | aVet[2] == "GTE_CODIGO"})
		cCdOdont := alltrim(aCGTE[1, nGTECODIGO])
	EndIf

	RestArea(aArea)
Return(cCdOdont)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DblClik ºAutor  ³Saude          z    º Data ³ 20/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para marcar e desmarcar o item.                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DblClik(oGTE)
	Local nFor := 0
// Limpa todos os campos menos o que está posicionado
	For nFor := 1 To Len(oGTE:aCols)
		If oGTE:oBrowse:nAt != nFor
			oGTE:aCols[nFor, nGTEIDMARK] := "LBNO"
		EndIf
	Next
	oGTE:aCols[oGTE:oBrowse:nAt, nGTEIDMARK] := IIf(oGTE:aCols[oGTE:oBrowse:nAt, nGTEIDMARK] == "LBTIK", "LBNO", "LBTIK")
	oGTE:oBrowse:Refresh()

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_QuesSel ºAutor  ³Patricia Queiroz    º Data ³ 20/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para pegar o questionário selecionado                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OdgSel(oGTE)
	Local aArea   := GetArea()
	Local nCont   := 0
	Local nFor    := 0
	Local lRet    := .T.

	For nFor := 1 To Len(oGTE:aCols)
		If oGTE:aCols[nFor, nGTEIDMARK] == "LBTIK"
			nCont++
		EndIf
	Next

	If nCont == 0
		HS_MsgInf(STR0034, STR0029, STR0035)  //"Selecione apenas um questionário.""Atenção", "Validação Prontuário Clinicas"
		lRet := .F.
	ElseIf nCont > 1
		HS_MsgInf(STR0034, STR0029, STR0035) //"Selecione apenas um questionário.""Atenção", "Validação Prontuário Clinicas"
		lRet := .F.
	EndIf

	RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_COORDMPIºAutor  ³Rogerio Tabosa      º Data ³ 04/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Retorna as coordenadas definidas do Odontograma             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_COORDMPI(cCodigo)
/*Local aCoordenada := {{'18  ','DI   ',{17,148}, {37,148}, {20,159}, {34,159}},;
					  {'17  ','IL   ',{273,145}, {290,145}, {276,161}, {288,161}}}*/
	Local aArea 	:= GetArea()
	Local aRet 		:= {}
	Local cSql 		:= ""
	Local cCpoId 	:= IIf(cTipOdtGr == "1" ,"GTF_DENREG, GTF_FADENT ", "GTG_CODIGO")
	Local cAliasC	:= IIf(cTipOdtGr == "1" ,"GTF", "GTG")

	cSql := " SELECT " + cAliasC + "_CXSUP1, " + cAliasC + "_CYSUP1, " + cAliasC + "_CXSUP2, " + cAliasC + "_CYSUP2, "
	cSql += " " + cAliasC + "_CXINF1, " + cAliasC + "_CYINF1, " + cAliasC + "_CXINF2, " + cAliasC + "_CYINF2," + cCpoId
	cSql += " FROM " + RetSqlName(cAliasC) + " " + cAliasC + " WHERE " + cAliasC + "." + cAliasC + "_CODCFG = '" + cCodigo + "'"
	cSql += " AND " + cAliasC + "_FILIAL = '" + xFilial(cAliasC) + "' AND " + cAliasC + ".D_E_L_E_T_ <> '*' "
	cSql := ChangeQuery(cSql)
	TCQuery cSql New Alias "REGMPI"
	DbSelectArea("REGMPI")
	While !Eof()
		If cTipOdtGr == "1"
			AADD(aRet, {REGMPI->GTF_DENREG,REGMPI->GTF_FADENT,{REGMPI->GTF_CXSUP1,REGMPI->GTF_CYSUP1},{REGMPI->GTF_CXSUP2,REGMPI->GTF_CYSUP2},;
				{REGMPI->GTF_CXINF1,REGMPI->GTF_CYINF1},{REGMPI->GTF_CXINF2,REGMPI->GTF_CYINF2}})
		Else
			AADD(aRet, {REGMPI->GTG_CODIGO,"",{REGMPI->GTG_CXSUP1,REGMPI->GTG_CYSUP1},{REGMPI->GTG_CXSUP2,REGMPI->GTG_CYSUP2},;
				{REGMPI->GTG_CXINF1,REGMPI->GTG_CYINF1},{REGMPI->GTG_CXINF2,REGMPI->GTG_CYINF2}})
		EndIf
		DbSkip()
	EndDo
	DbSelectArea("REGMPI")
	DbCloseArea()
	RestArea(aArea)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRVGTD  ºAutor  ³ Rogerio Tabosa    º Data ³  27/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Exame Clinico								          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_GRVGTD(cCodigo, cRegAte)

	Local aArea		:= GetArea()
	Local lSeek		:= .F.
	Local nL		:= 0

	For nL := 1 To Len(oGetMPI:aCols)
		DbSelectArea(cAliasMPI)
		DbSetOrder(1)//GTD_FILIAL+GTD_REGATE+GTD_ITEM     GTH OU GTD
		lSeek := DbSeek(xFilial(cAliasMPI) + cRegAte + oGetMPI:aCols[nL, nMPIItem])
		If oGetMPI:aCols[nL, Len(oGetMPI:aHeader)+1 ] == .T. .AND. lSeek // Se a linha esta deletada na get e achou o kra no banco
			RecLock(cAliasMPI, .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2(cAliasMPI)
		Else
			If !oGetMPI:aCols[nL, Len(oGetMPI:aHeader)+1 ]
				RecLock(cAliasMPI, !lSeek )
				HS_GRVCPO(cAliasMPI, oGetMPI:aCols, oGetMPI:aHeader, nL)
				&(cAliasMPI + "->" + cAliasMPI + "_FILIAL") := xFilial(cAliasMPI)
				&(cAliasMPI + "->" + cAliasMPI + "_REGATE") := cRegAte
				&(cAliasMPI + "->" + cAliasMPI + "_CODCFG") := cCodigo
				MsUnlock()
			EndIf
		EndIf
	Next nL
	RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_OBSDENTEºAutor  ³ Rogerio Tabosa    º Data ³  05/01/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe tela para atribuir comentário do Exame CLinico do Denteº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSDENTE()
	Local cComent 	:= Space(TamSx3("GTD_HISATE")[1])
	Local cProdut 	:= Space(TamSx3("B1_COD")[1])
	Local cDesPro 	:= Space(TamSx3("GA7_DESC")[1])
	Local cTexto

	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )


	DEFINE MSDIALOG oDlgDent TITLE STR0036 From 120, 000 To 400 , 550 Of oMainWnd Pixel   //"Observação"

	@ 010, 010 Say STR0095  Of oDlgDent Pixel COLOR CLR_BLUE    // "Procedimento"
	@ 020, 010 MsGet oProd VAR cProdut Size 40, 009 VALID FS_VLDOBS(cProdut, @cDesPro, @cTexto) F3 "HSPSB1" OF oDlgDent Pixel COLOR CLR_BLACK

	@ 010, 055 Say STR0094  Of oDlgDent Pixel COLOR CLR_BLUE    // "Descrição"
	@ 020, 055 MsGet oDes VAR cDesPro READONLY Size 205, 009 OF oDlgDent Pixel COLOR CLR_BLACK
	oDes:Disable()
	@ 035, 010 Say STR0037  Of oDlgDent Pixel COLOR CLR_BLUE    // "Informe a observação:"
	@ 045, 010 MsGet oSol VAR cComent Size 250, 009 OF oDlgDent Pixel COLOR CLR_BLACK

	@ 060, 010 Say STR0094 OF oDlgDent PIXEL COLOR CLR_BLUE  //"Observação do procedimento:"
	@ 070, 010 GET oTexto VAR cTexto MEMO READONLY SIZE 250, 051 OF oDlgDent PIXEL
	oTexto:Disable()

	oBtnOk := tButton():New(@125, 115, STR0038, oDlgDent, {|| Iif(!Empty(cProdut),oDlgDent:End(),Nil)}, 050, 012,,,, .T.)    //"Confirma"

	ACTIVATE MSDIALOG oDlgDent CENTERED

Return({cComent, cProdut})

// Valida existencia do Procedimento/Produto
Static Function FS_VLDOBS(cProdut, cDesProd, cObserv)
	Local aArea := GetArea()
	Local lRet := .F.

	DbSelectArea("GA7")
	DbSetOrder(1)
	If DbSeek(xFilial("GA7") + PadR(AllTrim(cProdut), Len(GA7->GA7_CODPRO)))
		cDesProd := GA7->GA7_DESC
		cObserv	 := GA7->GA7_OBSERV
		oTexto:Refresh()
	EndIf

	DbSelectArea("SB1")
	DbSetOrder(1)
	lRet := DbSeek(xFilial("SB1") + PadR(AllTrim(cProdut), Len(SB1->B1_COD)))
	RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_REFRESH ºAutor  ³ Rogerio Tabosa    º Data ³  27/01/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza Grid de Orçamento, Plano de tratamento e Pacientes º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REFRESH(cDatAte)

	Local aArea := GetArea()
	Local cCndGT9	:= ""

	If lTelaOK  // Se estiver am atendimento Atualiza Orçamento, Caso contrario Atualiza os pacientes.
	//M57CHKORC()	//	Limpa Registros relacionados aos itens excluídos no Orçamento Padrão(SCK) 
		IF lOdonto
			DbSelectArea("GBH")
			DbSetOrder(1)
			DbSeek(xFilial("GBH")+cRgerSel)
			cCliPad := GBH->GBH_CODCLI
			HS_STATORC(,cCliPad)
			FS_ATUORC("", cCliPad)
			aColsGT9Or := {}
			HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_REGGER = '" + cRgerSel + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
			oGetOrc:setArray(aColsGT9Or)
			oGetOrc:oBrowse:Refresh()
			oGetOrc:oBrowse:SetFocus()
			oGetOrcIte:oBrowse:SetFocus()

		//================================================================¿
		//³ Atualiza Grid de orçamentos	 do Plano de tratamento			 ³
		//================================================================Ù
			If lExGt9RegGer .AND. !Empty(cRGerSel)
				cCndGT9 := " AND (GT9.GT9_REGGER = '" + cRGerSel + "' OR GT9.GT9_REGGER = '" + SPace(TamSx3("GT9_REGGER")[1]) + "')"
			EndIf
			aCGT9Pln := {}
			HS_BDados("GT9", @aHGT9Pln, @aCGT9Pln,, 1,, " GT9.GT9_REGGER = '" + cRgerSel + "' AND GT9.GT9_STATUS IN('3','5'" + iIf(lVisPltFin,",'6'","") + ") " + cCndGT9,,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
			oGetOrcPln:setArray(aCGT9Pln)
			oGetOrcPln:oBrowse:Refresh()
			oGetOrcPln:oBrowse:SetFocus()
			oGetItePln:oBrowse:SetFocus()
			If lPOrcCl		//.AND. Hs_ExisDic({{"T","GTP"}},.F.)
				FS_ATUPEN(cAtPac)
			EndIf
		
		//================================================================¿
		//³ Atualiza Grid de Exame CLinico e Mapeamento de Imagem  		  ³
		//================================================================Ù
			aCMPI := {}
			HS_BDados(cAliasMPI, @aHMPI, @aCMPI,, 1,, cAliasMPI + "_REGATE = '" + oGetPac:aCols[oGetPac:nAt, nGcyRegAte] + "' AND " + cAliasMPI + "_CODCFG = '" + cCodOdtGr + "' ",,,"/",,,,,,.T.,,,,,, aCpoMPI,,,IIf(cTipOdtGr == "0","GTH_CODREG","GTD_DENREG"))
			If Empty(aCMPI[1, nMPIItem])
				aCMPI[1, nMPIItem] := StrZero(1, Len(GTD->GTD_ITEM))
			EndIf
			oGetMPI:setArray(aCMPI)
			oGetMPI:oBrowse:Refresh()
		ENDIF
	Else
		aColsPac := {}

	//================================================================¿
	//³ Busca Atendimentos de Acordo com o Profissional e Local de At³
	//================================================================Ù
		If nFiltro == 2
			HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODCRM = '" + cCrmLog + "' AND GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + cDatAte +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'",.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,,,, aCpoGcy,aJoinGcy)
		ElseIf nFiltro == 3 // Todos pacientes
			HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + cDatAte +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'",.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,,,, aCpoGcy,aJoinGcy)
		Else // nFiltro == 1
			HS_BDados("GCY", @aHeadPac, @aColsPac,, 1,, " GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + cDatAte +"' AND GCY.GCY_DATALT = '" + SPACE(TamSx3("GCY_DATALT")[1]) + "'" + ;
				" AND EXISTS (" + ;
				"SELECT 1 FROM " + retSqlName("GCZ") + " GCZ" + ;
				" JOIN " + retSqlName("GCY") + " GCYY ON GCZ.GCZ_REGATE = GCYY.GCY_REGATE" + ; //LINHA ADICIONAL
			" JOIN " + retSqlName("GD7") + " GD7" + ;
				" ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GD7.GD7_FILIAL ='" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_<>'*'" + ;
				" AND GCZ.GCZ_FILIAL ='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_<>'*'" + ;
				" JOIN " + retSqlName("GA7") + " GA7" + ;
				" ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GD7.GD7_CODDES" + ;
				" AND GA7_CODESP IN (" + cEspecMed + ")" + ;
				" AND GA7.GA7_FILIAL ='" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_<>'*'" + ;
				" WHERE GCZ_REGATE = GCY_REGATE AND GCZ.GCZ_FILIAL ='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_<>'*'" + ;
				")"  ;
				,.T.,"HSP_STAREG","/",,,,{"GCY_OK"},{"'LBNO'"},.T.,aLegGCY,,,,, aCpoGcy,aJoinGcy)
		Endif
		oGetPac:setArray(aColsPac)
		oGetPac:oBrowse:Refresh()
	EndIf

//Refresh promoção da Saúde
	If lMVPromo
		PLSFOREFR(cRgerSel)
	Endif
	RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_LIMPQUESTºAutor  ³ Rogerio Tabosa    º Data ³  22/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa as variaveis de memoria do questionário			      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_LIMPQUEST()
	Local nField := 0
	If ValType("__aField") <> "U"
		For nField := 1 To Len(__aField)
			If !Empty(__aField[nField][10])
				&(__aField[nField][2]) := InitPad(__aField[nField][10])
			Else
				If __aField[nField][3] == "D"
					&(__aField[nField][2]) :=  Ctod("  /  /  ")
				ElseIf __aField[nField][3] == "N"
					&(__aField[nField][2]) :=  0
				Else
					&(__aField[nField][2]) :=  Space(__aField[nField][4])
				Endif
			Endif
		Next
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLDOK  TºAutor  ³ Saude             º Data ³  22/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida dados dos grid da GTC E GTD         			      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLDOK(lVldPnl)

	Local lRet	:= .T.
	Local lAltaCli	:= SuperGetMV("MV_ALTACLI", NIL, .F.)  // Alta após confirmar o atendimento
	Default lVldPnl := .F.

	If !lTelaOK
		Return(lRet)
	EndIf
	If oGetPac:aCols[oGetPac:nAt, nHspStareg] == "BR_VERMELHO" .AND. lPnlCli .AND. lAltaCli   .AND. lVldPnl
		HS_MsgInf(STR0093, STR0029, STR0035)  //"Paciente ainda não chegou para atendimento, não pode ser dispensado!""Atenção", "Validação Prontuário Clinicas"
		Return(.F.)
	EndIf
	IF lOdonto
		If Len(oGetHisAte:aCols) <= 1
			If !Empty(oGetHisAte:aCols[1, nGTCDenReg])
				If !(lRet := oGetHisAte:TudoOk())
					Return(lRet)
				EndIf
			EndIf
		Else
			If !(lRet := oGetHisAte:TudoOk())
				Return(lRet)
			EndIf
		EndIf
		If Len(oGetMPI:aCols) <= 1
			If !Empty(oGetMPI:aCols[1, nMPICodReg]) .OR. !Empty(oGetMPI:aCols[1, nMPICodReg])
				If !(lRet := oGetMPI:TudoOk())
					Return(lRet)
				EndIf
			EndIf
		Else
			If !(lRet := oGetMPI:TudoOk())
				Return(lRet)
			EndIf
		EndIf
	ENDIF

Return (lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GRVATEN³ Autor ³ Saude     			³ Data ³ 12/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravação do Atendimento sem fechar a tela                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE      		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GRVATEN()

	Local aArea 	:= GetArea()
	Local lRet:=	.T.

	If lMVPromo
		lRet:=	PLSPROVER(aPerPro,oFolGetsImg)
		If !lret
			Return(.F.)
		Endif
	Endif
	If lTelaOK
		If oGetPac:aCols[oGetPac:nAt, nHspStareg] == "BR_VERMELHO" .AND. lPnlCli .AND. lAltaCli
			HS_MsgInf(STR0093, STR0029, STR0035) //"Paciente ainda não chegou para atendimento, não pode ser dispensado!""Atenção", "Validação Prontuário Clinicas"
			Return(.F.)
		EndIf
		DbSelectArea("GCY")
		DbSetOrder(1)
		DbSeek(xFilial("GCY")+cAtPac)
		FS_GrvM57(.T.,.T.,cCrmLog,,iIf(valType(aMntperg)=="A",aMntperg[2],{}), "G", ,cCdQues,,!Empty(cDirImg))
		FS_StFolder(.F.)
		FS_LSTPAC(DTOS(oCalend:dDiaAtu))
	EndIf
	RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_ORDPLN ³ Autor ³ Saude     			³ Data ³ 12/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravação do Atendimento sem fechar a tela                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA410  		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ORDPLN(cClient,cNumOrc)
	Local aArea 	:= GetArea()
	Local cSql		:= ""
	Local lRet      :=.F.
	Local nCnt		:= 0
	Local cStrOrc	:= ""
	Local lPergunte := .F.
	Local cNomPac	:= ""

	Private aItensAlte := {}

	If !(lTelaOK .AND. oFolder:nOption == 3)
		cNumOrc := ""
	EndIf

	If Empty(cNumOrc)
	//HS_MSGINF("Selecione o orçamento no Plano de tratamento!",STR0029, STR0030)//"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"
	//Return()
		If Pergunte("HSPM61", .T.)
			DbSelectArea("GBH")
			DbSetOrder(1)
			If DbSeek(xFilial("GBH") + MV_PAR01)
				cClient := GBH->GBH_CODCLI
				cNomPac	:= GBH->GBH_NOME
				lPergunte := .T.
			EndIf
		Else
			RestArea(aArea)
			Return()
		EndIf
	EndIf
	If Empty(cNomPac)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1") + cClient)
		cNomPac := Alltrim(SA1->A1_NOME)
	EndIf

	/*Verifica se Tem mais Que um orcamento para o Mesmo Cliente  */
/*If HS_CountTB("GT9", "GT9_CLIENT  = '" + cClient + "' AND GT9_STATUS IN ('2','3')")  > 1
	lRet:= .T.//FS_REOROR(cClient)
Endif*/

	cSql := " SELECT GT9_NUMFAT FROM " + RetSqlName("GT9")  + " GT9 "
	cSql += " WHERE GT9_CLIENT  = '" + cClient + "' AND GT9_STATUS IN ('2','3') "
	cSql += " AND GT9.D_E_L_E_T_ <> '*' AND GT9_FILIAL = '" + xFilial("GT9")  + "'"

	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYGT9"

	While !Eof()
		nCnt ++
		cStrOrc += QRYGT9->GT9_NUMFAT + ","
		DbSkip()
	End

	lRet := (nCnt > 1)

	DbSelectArea("QRYGT9")
	DbCloseArea()


//HS_MSGINF("Selecione o orçamento no Plano de tratamento!",STR0029, STR0030)//"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"
//Return()

	cSql := " SELECT " + iIf(lPergunte,"DISTINCT ","") + "GTJ_NUMORC FROM " + RetSqlName("GTJ") + " GTJ JOIN " + RetSqlName("GT9") + " GT9 "
	cSql += " ON GT9_NUMFAT = GTJ_NUMORC AND GT9_CLIENT = '" + cClient + "' AND GT9_STATUS IN('2','3','5' ) AND GT9.D_E_L_E_T_ <> '*'AND GT9_FILIAL = '" + xFilial("GT9") + "' "
	cSql += " WHERE  GTJ_STATUS = '0' AND "
	If !lRet
		if lPergunte
			cSql +=""
		else
			cSql +=" GTJ_NUMORC = '" + cNumOrc + "' AND"
		endif
	Else
		cSql +=" GTJ_NUMORC IN (" + HS_InSql(cStrOrc,6,",") +") AND "
	Endif
	cSql += " GTJ.D_E_L_E_T_ <> '*' AND GTJ_FILIAL = '" + xFilial("GTJ") + "' "

	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYORC"

	DbSelectArea("QRYORC")
	If Eof()
		DbSelectArea("QRYORC")
		DbCloseArea()
		HS_MSGINF(STR0092,STR0029, STR0030)//"Ordem não pode ser alterada pois não possui itens pendentes!" ### "Atenção" ### "Validação Atualização Orçamento"
		Return()
	else
		While !Eof()
			cStrOrc += QRYORC->GTJ_NUMORC + ","
			DbSkip()
		End
	EndIf
	DbSelectArea("QRYORC")
	DbCloseArea()

	HS_FTRREO(oMainWnd, STR0091 + IIf(Empty(cNomPac), "", " - " + Alltrim(cNomPac)), "GTJ", 1, "GTJ_NUMORC IN (" + HS_InSql(cStrOrc,6,",") +") AND GTJ_STATUS = '0' ", "GTJ_PRIORI", "HS_M57REORD(oGDReord)",, "GTJ_MTVAGE/GTJ_USRFOR/GTJ_DESMTV", .F.,,.T., "HS_M57REORD(oGDReord, .T.)") //"Prioridade do tratamento" ###

	RestArea(aArea)
Return

Function HS_M57REORD(oGD, lVldEdit)
	Local lRet 		:= .T.
	Local nProdut 	:= 0
	Local cProd1 	:= ""
	Local cProd2 	:= ""
	Local cPriGA71 	:= ""
	Local cPriGA72 	:= ""
	Local cPriGFR1 	:= ""
	Local cPriGFR2 	:= ""
	Local cEsp1 	:= ""
	Local cEsp2 	:= ""
	Local nCol     	:= oGD:oBrowse:nColPos
	Local nLin     := oGD:oBrowse:nAt
	local cMensagem := ""
	local lReorPlTra:= SuperGetMV("MV_REOPLT", NIL, .F.) // Indica se o hospital/clinica permite reordenacao de prioridade dos procedimentos quando houver incomptibilidade com os pré requisitos

	Private nColFatura  := 0
	Private nColItemFat := 0
	Private cUserAut    := ""
	Private cCodJust    := Space(TamSx3("GT7_CODMTV")[1])

	Default lVldEdit	:= .F.

	If lVldEdit
		If Len(Alltrim(&(ReadVar()))) <> 6
			HS_MSGINF(STR0090,STR0029, STR0030)//"Prioridade invalida!","Atenção", "Validação Atualização Orçamento"
			Return(.F.)
		EndIf
	EndIf

	nColFatura  := aScan(oGD:aHeader, {|aVet| aVet[2] == "GTJ_NUMORC"})
	nColItemFat := aScan(oGD:aHeader, {|aVet| aVet[2] == "GTJ_ITEM  "})

	nProdut := aScan(oGD:aHeader, {|aVet| aVet[2] == "GTJ_PRODUT"})
	cProd1 	:= oGD:aCols[nLin, nProdut]
	If nCol == nSobe .AND. nCol == 1
		cProd2 	:= oGD:aCols[nLin - 1, nProdut]
	ElseIf nCol == nDesce .AND. nCol < Len(oGD:aCols)
		cProd2 	:= oGD:aCols[nLin + 1, nProdut]
	Else
		Return(.T.)
	EndIf

	DbSelectArea("GA7")
	DbGoTop()
	DbSetOrder(1)
	If DbSeek(xFilial("GA7") + PADR(cProd1, TamSx3("GA7_CODPRO")[1]))
		cEsp1 		:= GA7->GA7_CODESP
		cPriGA71	:= GA7->GA7_PRIORI
		DbSelectArea("GFR")
		DbGoTop()
		DbSetOrder(1)
		DbSeek(xFilial("GFR") + GA7->GA7_CODESP)
		cPriGFR1 := GFR->GFR_PRIORI
	Else
		Return(.T.)
	EndIf
	DbSelectArea("GA7")
	DbGoTop()
	DbSetOrder(1)
	If DbSeek(xFilial("GA7") + PADR(cProd2, TamSx3("GA7_CODPRO")[1]))
		cEsp2 		:= GA7->GA7_CODESP
		cPriGA72	:= GA7->GA7_PRIORI
		DbSelectArea("GFR")
		DbGoTop()
		DbSetOrder(1)
		DbSeek(xFilial("GFR") + GA7->GA7_CODESP)
		cPriGFR2 := GFR->GFR_PRIORI
	Else
		Return(.T.)
	EndIf

	If cEsp1 <> cEsp2
		cMensagem := STR0087 + chr(10) + chr(13) + STR0089 //"Ordenação invalida!" ### "Prioridade de execução da especialidade incompatível com o pré requisito."
		If nCol == nSobe
			If cPriGFR2 > cPriGFR1
				Return(.T.)
			Else
			/*
			HS_MSGINF("Ordenação invalida!" + chr(10) + chr(13) + ;
			"Prioridade de execução da especialidade incompatível com o pré requisito.",STR0029, STR0030)//"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"*/
				if lReorPlTra
					cMensagem += chr(10) + chr(13) + chr(10) + chr(13) + STR0086 //"Deseja forçar alteração de prioridade ?"
					if msgYesno(cMensagem, STR0030) // cMensagem ### "Validação Atualização Orçamento"
						if fs_autProSup(@cUserAut,@cCodJust)
							aAdd(aItensAlte,{oGD:aCols[nLin, nColFatura],oGD:aCols[nLin, nColItemFa],cUserAut,cCodJust})
							return(.T.)
						else
							return(.F.)
						endif
					else
						Return(.F.)
					endif
				else
					HS_MSGINF(cMensagem,STR0029, STR0030)//cMensagem,"Atenção", "Validação Atualização Orçamento"
					Return(.F.)
				endif
			EndIf
		ElseIf nCol == nDesce
			If cPriGFR2 < cPriGFR1
				Return(.T.)
			Else
			/*
			HS_MSGINF("Ordenação invalida!" + chr(10) + chr(13) + ;
			"Prioridade de execução da especialidade incompatível com o pré requisito.",STR0029, STR0030)//"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"*/
				if lReorPlTra
					cMensagem += chr(10) + chr(13) + chr(10) + chr(13) + STR0086 //"Deseja forçar alteração de prioridade ?"
					if msgYesno(cMensagem, STR0030) // cMensagem ### "Validação Atualização Orçamento"
						if fs_autProSup(@cUserAut,@cCodJust)
							aAdd(aItensAlte,{oGD:aCols[nLin, nColFatura],oGD:aCols[nLin, nColItemFa],cUserAut,cCodJust})
							return(.T.)
						else
							return(.F.)
						endif
					else
						Return(.F.)
					endif
				else
					HS_MSGINF(cMensagem,STR0029, STR0030)//cMensagem,"Atenção", "Validação Atualização Orçamento"
					Return(.F.)
				endif
			EndIf
		EndIf
	Else
		cMensagem := STR0087 + chr(10) + chr(13) + STR0088 //"Ordenação invalida!" ### "Prioridade de execução do procedimento incompatível com o pré requisito."
		If nCol == nSobe
			If cPriGA72 > cPriGA71
				Return(.T.)
			Else
			/*
			HS_MSGINF("Ordenação invalida!" + chr(10) + chr(13) + ;
			"Prioridade de execução do procedimento incompatível com o pré requisito.",STR0029, STR0030)//"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"*/
				if lReorPlTra
					cMensagem += chr(10) + chr(13) + chr(10) + chr(13) + STR0086 //"Deseja forçar alteração de prioridade ?"
					if msgYesno(cMensagem, STR0030) // cMensagem ### "Validação Atualização Orçamento"
						if fs_autProSup(@cUserAut,@cCodJust)
							aAdd(aItensAlte,{oGD:aCols[nLin, nColFatura],oGD:aCols[nLin, nColItemFa],cUserAut,cCodJust})
							return(.T.)
						else
							return(.F.)
						endif
					else
						Return(.F.)
					endif
				else
					HS_MSGINF(cMensagem,STR0029, STR0030)//cMensagem,"Atenção", "Validação Atualização Orçamento"
					Return(.F.)
				endif
			EndIf
		ElseIf nCol == nDesce
			If cPriGA72 < cPriGA71
				Return(.T.)
			Else
			/*
			HS_MSGINF("Ordenação invalida!" + chr(10) + chr(13) + ;
			"Prioridade de execução do procedimento incompatível com o pré requisito.",STR0029, STR0030)//,"Atenção", "Validação Atualização Orçamento"*/
				if lReorPlTra
					cMensagem += chr(10) + chr(13) + chr(10) + chr(13) + STR0086 //"Deseja forçar alteração de prioridade ?"
					if msgYesno(cMensagem, STR0030) // cMensagem ### "Validação Atualização Orçamento"
						if fs_autProSup(@cUserAut,@cCodJust)
							aAdd(aItensAlte,{oGD:aCols[nLin, nColFatura],oGD:aCols[nLin, nColItemFa],cUserAut,cCodJust})
							return(.T.)
						else
							return(.F.)
						endif
					else
						Return(.F.)
					endif
				else
					HS_MSGINF(cMensagem,STR0029, STR0030)//cMensagem,"Atenção", "Validação Atualização Orçamento"
					Return(.F.)
				endif
			EndIf
		EndIf
	EndIf

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_REOROR ³ Autor ³ Saude     			³ Data ³ 04/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordenação de Prioridade para mais que um orçamento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP  		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FS_REOROR(cClient)

	Local aArea 	:= GetArea()
	Local cSql		:= ""
	Local nIt		:=0
	Local aGTJ 		:={}
	Local nMaxPrio  := ""
	Local lProcPai  := .T.		//Hs_ExisDic({{"C", "GTJ_PROPAI"}}, .F.)
	local cProc     := ""
	local cProcPai  := ""
	local cSessao   := ""

	/* Atualização da Prioridade Quando tiver mais de 1 orçamento para o Cliente*/

	cSql := " SELECT MAX(GTJ_PRIORI) MAXPRIO FROM " + RetSqlName("GT9")  + " GT9 "
	cSql += " JOIN " + RetSqlName("GTJ")  + " GTJ  ON GTJ_NUMORC = GT9_NUMFAT"
	cSql += " AND GTJ.D_E_L_E_T_ <> '*' AND GTJ_FILIAL = '" + xFilial("GTJ")  + "'"
	cSql += " WHERE GT9_CLIENT  = '" + cClient + "' AND GT9_STATUS IN ('3') "
	cSql += " AND GT9.D_E_L_E_T_ <> '*' AND GT9_FILIAL = '" + xFilial("GT9")  + "'"

	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYMAX"
	If !Eof()
		nMaxPrio := Val(QRYMAX->MAXPRIO)
	Endif

	DbSelectArea("QRYMAX")
	QRYMAX->(DbCloseArea())


	cSql := " SELECT     GTJ.GTJ_NUMORC, GTJ.GTJ_PRODUT, GTJ.GTJ_ITEM, GTJ.GTJ_PRIORI "
	iIf(lProcPai, cSql += ", GTJ.GTJ_PROPAI, GTJ_SESSAO ", )
	cSql += " FROM       " + RetSqlName("GTJ") + " GTJ "
	cSql += "           JOIN " + RetSqlName("GT9") + " GT9 ON GTJ.GTJ_NUMORC = GT9.GT9_NUMFAT AND GT9.GT9_CLIENT='" + cClient + "' AND GT9.GT9_STATUS='2' AND GT9.D_E_L_E_T_ <> '*' AND GT9_FILIAL = '" + xFilial("GT9") + "' "
	cSql += " WHERE      GTJ.GTJ_STATUS <> '1' AND GTJ.D_E_L_E_T_ <> '*'  AND GTJ_FILIAL = '" + xFilial("GTJ") + "' "


	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYITEN"

	DbSelectArea("QRYITEN")
	DbGoTop()

	While QRYITEN->(!eof() )
		DbSelectArea("GA7")

		DbSetOrder(1)

		If DbSeek(xFilial("GA7") + PADR(QRYITEN->GTJ_PRODUT, TamSx3("GA7_CODPRO")[1]))
			DbSelectArea("GFR")
			DbGoTop()
			DbSetOrder(1)
			DbSeek(xFilial("GFR") + GA7->GA7_CODESP)
			AADD(aGTJ, {QRYITEN->GTJ_NUMORC, QRYITEN->GTJ_ITEM, GFR->GFR_PRIORI,GA7->GA7_PRIORI,QRYITEN->GTJ_PRODUT, iIf(lProcPai, QRYITEN->GTJ_PROPAI,nil),iIf(lProcPai, QRYITEN->GTJ_SESSAO,nil)})
		Else
			AADD(aGTJ, {QRYITEN->GTJ_NUMORC, QRYITEN->GTJ_ITEM, "","", QRYITEN->GTJ_PRODUT, iIf(lProcPai, QRYITEN->GTJ_PROPAI,nil),iIf(lProcPai, QRYITEN->GTJ_SESSAO,nil)})
		EndIf
		DbSelectArea("QRYITEN")
		DbSkip()

	Enddo
	if lProcPai
		aSort(aGTJ,,,{|x,y| x[3] + x[4] + x[6] + x[7] + x[5] < y[3] + y[4] + y[6] + y[7] + Y[5]})
	else
		aSort(aGTJ,,,{|x,y| x[3] + x[4] < y[3] + y[4]})
	endif

//nOrd := 0
	nOrd  := 10
	For nIt := 1 To Len(aGTJ)
	//nOrd := nOrd + 10
		if lProcPai
			cProc    := aGTJ[nIt,5]
			cProcPai := aGTJ[nIt,6]
			cSessao  := aGTJ[nIt,7]
		//if nIt > 1 .and. cPct == aGTJ[nIt-1,5]  .and. cProc == aGTJ[nIt-1,6] .and. !empty(cProc)
			if nIt > 1 .and. empty(cProcPai)
				nOrd := nOrd + 10
			elseif nIt > 1 .and. cProcPai == aGTJ[nIt-1,6] .and. cSessao <> aGTJ[nIt-1,7]
				nOrd := nOrd + 10
			elseif nIt > 1 .and. cProcPai <> aGTJ[nIt-1,6]
				nOrd := nOrd + 10
			endif


			DbSelectArea("GTJ")
			GTJ->(DbSetOrder(1))
			If 	GTJ->(MsSeek(xFilial("GTJ")+aGTJ[nIt][1]+aGTJ[nIt][2]))
				RecLock("GTJ", .F.)
				GTJ->GTJ_PRIORI	:= PADL(Alltrim(Str(nOrd + nMaxPrio)),TamSx3("GTJ_PRIORI")[1],"0")
				MsUnlock()
			Endif
		else
			DbSelectArea("GTJ")
			GTJ->(DbSetOrder(1))
			If 	GTJ->(MsSeek(xFilial("GTJ")+aGTJ[nIt][1]+aGTJ[nIt][2]))
				RecLock("GTJ", .F.)
				GTJ->GTJ_PRIORI	:= PADL(Alltrim(Str(nOrd + nMaxPrio)),TamSx3("GTJ_PRIORI")[1],"0")
				MsUnlock()
			Endif
			nOrd := nOrd + 10
		Endif
	Next nIt


	DbSelectArea("QRYITEN")
	QRYITEN->(DbCloseArea() )


	RestArea(aArea)

Return(.T.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_VerOrc ³ Autor ³ Saude     			³ Data ³ 06/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificação se existe Orcamento Liberado e chama tela Senha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP  		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VerOrc(nOpcao)
	Local lRet		:=.F.
	Local aUsuario	:={}
	Local cSuperio 	:=""
	Local cCodigo	:= ""
	Local lRetVLD := .T.
	Default nOpcao := 6


//Ponto de Entrada para validar se irá apresentar a tela de senha
	If ExistBlock("HSPVLDUSR") .And. nOpcao == 3
		lRetVLD := ExecBlock("HSPVLDUSR")
	
		IF 	!lRetVLD
			cSuperio:=__CUSERID
			cCodigo:=HS_Justif()
			If !Empty(cCodigo)
				lRet:=.T.
			Else
				lRet:=.F.
			Endif
		ENDIF
	EndIf

	If lRetVLD
		aUsuario:=HS_RetSup()
		If aUsuario[1]==.T.
			cSuperio:=aUsuario[2]
			cCodigo:=HS_Justif()
			If !Empty(cCodigo)
				lRet:=.T.
			Else
				lRet:=.F.
			Endif
		Else
			lRet:=.F.
		Endif
	EndIf
Return({lRet,cCodigo,cSuperio})



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CANORC ºAutor  ³ Saude             º Data ³  10/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada de  Cancelamento de orçamento do faturamento        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_CANORC(cNOrc)
	Local aArea 	:= GetArea()
	Local nRecno	:= 0
	Local aOrca		:={}

	DbSelectArea("SCJ")
	DbSetOrder(1)
	If Empty(cNOrc) .OR. !DbSeek(xFilial("SCJ") + cNOrc)
		Return()
	EndIf
	nRecno := Recno()


	If oGetOrc:aCols[oGetOrc:NaT,nGt9Status] == "BR_AMARELO"

		MATA415({},{},3) //Chamada da rotina automatica para criação das variaveis necessárias e execução dos Ajustas

		While __lSx8
			RollBackSxe()
		End

		DbSelectArea("SCJ")
		DbGoTo(nRecno)
		A415Cancel("SCJ",nRecno,4)

		While __lSx8
			RollBackSxe()
		End

		FS_ATUORC("", cCliPad)

		aColsGT9Or := {}
//	HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_CLIENT = '" + cCliPad + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
		HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_REGGER = '" + cRgerSel + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
		oGetOrc:setArray(aColsGT9Or)
		oGetOrc:oBrowse:Refresh()
		oGetOrc:oBrowse:SetFocus()

	Elseif oGetOrc:aCols[oGetOrc:NaT,nGt9Status] == "BR_VERDE" .OR. oGetOrc:aCols[oGetOrc:NaT,nGt9Status] == "BR_VIOLETA"

		If lSupervisor
			aOrca:=FS_VerOrc()
			lOrcLib:=aOrca[1]
			If !lOrcLib
				Return()
			Else
				__cCdJustGT9 := aOrca[2]
				__cCdUsrFGT9 := aOrca[3]
			Endif
		Else
			__cCdJustGT9 := HS_Justif()
			__cCdUsrFGT9 := __CUSERID
		Endif


		DbSelectArea("GTJ")
		DbSetOrder(1)
		DbSeek(xFilial("GTJ") + cNOrc)
		While !Eof() .And. GTJ->GTJ_FILIAL == xFilial("GTJ") .And. GTJ->GTJ_NUMORC == cNOrc
			If GTJ->GTJ_STATUS <> "1"
				RecLock("GTJ", .F.)
				GTJ->GTJ_STATUS	:= "2"
				MsUnlock()
			Endif
			DbSkip()
		End

		DbSelectArea("GT9")
		DbSetOrder(1)
		If DbSeek(xFilial("GT9") + cNOrc)
			RecLock("GT9", .F.)
			GT9->GT9_STATUS	:= "4"
			GT9->GT9_MTVAGE := __cCdJustGT9
			GT9->GT9_USRFOR := __cCdUsrFGT9
			MsUnlock()
			__cCdJustGT9 	:= ""
			__cCdUsrFGT9	:= ""
		EndIf
	//Chamada de Função para Reordenar apartir dos Itens Cancelados
		FS_REORCAN(oGetOrc:aCols[oGetOrc:nAt, nGt9NumCli],.F.)
	//Chamada de Função para Atualizar a Tela
	//FS_REFRESH(DTOS(oCalend:dDiaAtu))
	Endif
	FS_REFRESH(DTOS(oCalend:dDiaAtu))

	RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CANORC ºAutor  ³ Saude             º Data ³  10/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada de  Cancelamento de orçamento do faturamento        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_ALTORC(cNOrc)
	Local aArea 	:= GetArea()
	Local nRecno	:= 0
	Local dDatAtOrc := GetNewPar("MV_RDCDTOR","")
	Local cGTJItem := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se data do parametro MV_RDCDTOR inferior a 11/04/2013, altera para    ³
//³ esta data pois e a data de correcao da gravacao do GTJ_ITEPAI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(dDatAtOrc) .And. Dtos(dDatAtOrc) < '20130411'
		dDatAtOrc := Stod('20130411')
	EndIf

	DbSelectArea("SCJ")
	DbSetOrder(1)
	If Empty(cNOrc) .OR. !DbSeek(xFilial("SCJ") + cNOrc)
		Return()
	EndIf
	nRecno := Recno()

	If oGetOrc:aCols[oGetOrc:NaT,nGt9Status] == "BR_AMARELO"

		MATA415({},{},3) //Chamada da rotina automatica para criação das variaveis necessárias e execução dos Ajustas

		While __lSx8
			RollBackSxe()
		End

		DbSelectArea("SCJ")
		DbGoTo(nRecno)
		A415Altera("SCJ",nRecno,4)

		While __lSx8
			RollBackSxe()
		End

		FS_ATUORC("", cCliPad)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os itens foram deletados do orcamento                     ³
	//³ OBS: So atualiza itens lancados depois da data da correcao do chamado ³
	//³ TGRZ14. Itens anteriores foram gravados com o GTJ_ITEPAI incorreto    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SCJ->(DbSetOrder(1))//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
		If SCJ->(DbSeek(xFilial("SCJ")+cNOrc))
			GTJ->(DbSetOrder(1))//GTJ_FILIAL+GTJ_NUMORC+GTJ_ITEM
			SCK->(DbSetOrder(1))//CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
			GT9->(DbSetOrder(1))//GT9_FILIAL+GT9_NUMFAT+GT9_NUMLOJ
			
			GTJ->(DbSeek(xFilial("GTJ")+cNOrc+"ZZ"))
			GTJ->(DbSkip(-1))
			If GTJ->GTJ_NUMORC == cNOrc
				IIf( GTJ->GTJ_ITEM >= "99",cGTJItem := SOMA1(GTJ->GTJ_ITEM,2),cGTJItem := "99")
			EndIF
			
			If !Empty(dDatAtOrc) .And. GT9->GT9_DTEMIS >= dDatAtOrc .And. GT9->(DbSeek(xFilial("GT9")+cNOrc)) .And. GTJ->(DbSeek(xFilial("GTJ")+cNOrc))
				While GTJ->(GTJ_FILIAL+GTJ_NUMORC) == xFilial("GTJ")+cNOrc .And. !GTJ->(Eof())
					If GTJ->GTJ_STATUS <> "2" .And. !SCK->(DbSeek(xFilial("SCK")+GTJ->(GTJ_NUMORC+Iif(Empty(GTJ->GTJ_ITEPAI),GTJ->GTJ_ITEM,GTJ_ITEPAI))))
						GTJ->(RecLock("GTJ", .F.))
						GTJ->GTJ_STATUS := "2"
						GTJ->GTJ_ITEM		:= cGTJItem
						 
						GTJ->(MsUnlock())
					EndIf
					GTJ->(DbSkip())
				EndDo
			EndIf
		EndIf

		aColsGT9Or := {}
//	HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_CLIENT = '" + cCliPad + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
		HS_BDados("GT9", @aHeadGT9Or, @aColsGT9Or,, 1,, " GT9.GT9_REGGER = '" + cRgerSel + "' ",,"GT9_STATUS","/",,,,,,,aLegGT9,,.T.,,,,,,"GT9_NUMFAT DESC")
		oGetOrc:setArray(aColsGT9Or)
		oGetOrc:oBrowse:Refresh()
		oGetOrc:oBrowse:SetFocus()
	Endif

	RestArea(aArea)
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAHMLEG ³ Autor ³Paulo Emidio de Barros ³ Data ³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas no Agendamento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAHM29LEG()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM57LEG()
	Local aLegenda := {}
	Aadd(aLegenda,{"BR_AMARELO"   , STR0104}) //"Pendente"
	Aadd(aLegenda,{"BR_VERDE"     , STR0105}) //"Realizado"
	Aadd(aLegenda,{"BR_PRETO"     , STR0023}) //"Cancelado"
	Aadd(aLegenda,{"BR_LARANJA"   , STR0106}) //"Agendado"
	Aadd(aLegenda,{"BR_AZUL"      , STR0107}) //"Em atendimento"
	Aadd(aLegenda,{"BR_VERMELHO"  , STR0108}) //"Proc. Repetido"

	BrwLegenda(cCadastro,STR0009,aLegenda)  //"Agendamento" ### "Plano de Tratamento"

Return(NIL)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_REORCAN ³ Autor ³ Saude     			³ Data ³ 10/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordenação de Prioridade para Orcamento Cancelado           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP  		                        		     		  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FS_REORCAN(cClient,lIten)

	Local aArea 	:= GetArea()
	Local cSql		:= ""
	Local nIt		:=0
	Local aGTJ 		:={}
	Local nMinPrio  := 0
	Local nOrd		:=0


	cSql := " SELECT MIN(GTJ_PRIORI) MINPRIO FROM " + RetSqlName("GT9")  + " GT9 "
	cSql += " JOIN " + RetSqlName("GTJ")  + " GTJ  ON GTJ_NUMORC = GT9_NUMFAT"
	If !lIten
		cSql += " AND GTJ.GTJ_STATUS = '2'  "
	Endif
	cSql += " AND GTJ.D_E_L_E_T_ <> '*' AND GTJ_FILIAL = '" + xFilial("GTJ")  + "'"
	cSql += " WHERE GT9_CLIENT  = '" + cClient + "' "
	If !lIten
		cSql += "AND GT9_STATUS IN ('4') "
	Endif
	cSql += " AND GT9.D_E_L_E_T_ <> '*' AND GT9_FILIAL = '" + xFilial("GT9")  + "'"

	cSql := ChangeQuery(cSql)

	TCQUERY cSql NEW ALIAS "QRYMIN"

	DbSelectArea("QRYMIN")
	DbGoTop()
	If !Eof()
		nMinPrio := Val(QRYMIN->MINPRIO)
	Endif

	DbSelectArea("QRYMIN")
	QRYMIN->(DbCloseArea())

	cSql := " SELECT     GTJ.GTJ_NUMORC, GTJ.GTJ_PRODUT, GTJ.GTJ_ITEM, GTJ.GTJ_PRIORI "
	cSql += " FROM       " + RetSqlName("GTJ") + " GTJ "
	cSql += "           JOIN " + RetSqlName("GT9") + " GT9 ON GTJ.GTJ_NUMORC = GT9.GT9_NUMFAT AND GT9.GT9_CLIENT='" + cClient + "' AND GT9.GT9_STATUS='3' AND GT9.D_E_L_E_T_ <> '*' AND GT9_FILIAL = '" + xFilial("GT9") + "' "
	cSql += " WHERE "
	If !lIten
		cSql += "GTJ.GTJ_STATUS <> '1'  "
	Else
		cSql += "GTJ.GTJ_STATUS NOT IN  ('1','2')  "
	Endif
	cSql += "AND GTJ.D_E_L_E_T_ <> '*'  AND GTJ_FILIAL = '" + xFilial("GTJ") + "' "

	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYITEN"

	DbSelectArea("QRYITEN")
	DbGoTop()


	While QRYITEN->(!eof() )
		AADD(aGTJ, {QRYITEN->GTJ_NUMORC, QRYITEN->GTJ_ITEM, QRYITEN->GTJ_PRIORI })
		DbSelectArea("QRYITEN")
		DbSkip()
	Enddo

	aSort(aGTJ,,,{|x,y| x[3]  < y[3] })

	For nIt := 1 To Len(aGTJ)
		nOrd := VAL(aGTJ[nIt][3] )
		DbSelectArea("GTJ")
		GTJ->(DbSetOrder(1))
		If 	GTJ->(MsSeek(xFilial("GTJ")+aGTJ[nIt][1]+aGTJ[nIt][2]))
			If   nOrd > nMinPrio
				RecLock("GTJ", .F.)
				GTJ->GTJ_PRIORI	:= PADL(Alltrim(Str(nOrd-nMinPrio)),TamSx3("GTJ_PRIORI")[1],"0")
				MsUnlock()
			Endif
		Endif
	Next nIt

	DbSelectArea("QRYITEN")
	QRYITEN->(DbCloseArea() )

	RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_CANITPL ³ Autor ³ Saude     			³ Data ³ 10/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordenação de Prioridade para Orcamento Cancelado         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP  		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FS_CANITPL(cNOrc,cItem,nOpcao)
	Local aArea     := getArea()
	Local aOrca		:= {}
	Local lOrcLib	:= .T.
	Local lIten		:= .T.
	Local lHspahm54 := .F.
	Default nOpcao  := 6
//Verifica se o procedimento ja foi finalizado
	DbSelectArea("GTJ")
	DbSetOrder(1)
	If DbSeek(xFilial("GTJ") + cNOrc +cItem)
		If GTJ->GTJ_STATUS == "1" //0=Pendente;1=Realizado;2=Cancelado;3=Agendado;4=Em atendimento;5=Proc.Repetido
			HS_MSGINF(STR0115,STR0029, STR0080) //"Não é possível excluir um procedimento realizado!" ### "Atenção" ### "Validação Prontuário Eletrônico"
			restArea(aArea)
			Return()
		endif
	endif

	If lSupervisor
		aOrca:=FS_VerOrc()
		lOrcLib:=aOrca[1]
		If !lOrcLib
			Return()
		Else
			__cCdJustGT9 := aOrca[2]
			__cCdUsrFGT9 := aOrca[3]
		Endif
	Else
		__cCdJustGT9 := HS_Justif()
		__cCdUsrFGT9 := __CUSERID
	Endif

	DbSelectArea("GTJ")
	DbSetOrder(1)
	If DbSeek(xFilial("GTJ") + cNOrc +cItem)
		If GTJ->GTJ_STATUS <> "1" //0=Pendente;1=Realizado;2=Cancelado;3=Agendado;4=Em atendimento;5=Proc.Repetido
			RecLock("GTJ", .F.)
			GTJ->GTJ_STATUS	:= "2"
			GTJ->GTJ_MTVAGE := __cCdJustGT9
			GTJ->GTJ_USRFOR := __cCdUsrFGT9
			GTJ->GTJ_DATFOR :=  dDatabase
			GTJ->GTJ_HORFOR :=  time()
			MsUnlock()
			__cCdJustGT9 	:= ""
			__cCdUsrFGT9	:= ""
		Endif
	Endif
//Reordena os obejtos da tela (nao executa a acao caso seja chamada por outra rotina - Ex: Agenda)
	if funName() == "HSPAHM57"
		FS_REORCAN(oGetOrc:aCols[oGetOrc:nAt, nGt9NumCli],lIten)
	//Chamada de Função para Atualizar a Tela
		FS_REFRESH(DTOS(oCalend:dDiaAtu))
	endif
//Se a rotina foi chamada pela Agenda, altera o valor do local
	if funName() == "HSPAHM54"
		lHspahm54 := .T.
	endif

	DbSelectArea("GDN")
	GDN->(dbSetOrder(1))
//If GDN->(DbSeek(xFilial("GDN") + cCodLoc))
	If GDN->(DbSeek(xFilial("GDN") + iIf(lHspahm54, GM8->GM8_CODLOC, cCodLoc)))

		HSPAHP44(.T., cCodLoc, {{"GBH", 1, cRgerSel}, {"SCJ", 1, cNOrc}, {"GCY", 1, cAtPac}, {"GT9", 1, cNOrc}, {"SA1", 1, cCliPad}})
	EndIf
	restArea(aArea)

Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GERORC  ³ Autor ³ Saude     			³ Data ³ 10/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordenação de Prioridade para Orcamento Cancelado         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP  		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GERORC(cAlias, aItePre, cModCobr, lRefresh, cCodTabUt)

	Local cOrcAtu		:= ""
	Local nI			:= 0
	Local nP			:= 0
	Local aItens  	:= {}
	Local aItePct 	:= {}
	Local cItem		:= ""
	Local nItem     	:= 0
	Local cSql			:= ""
	Local aDenGTJ		:= {}
	local cProcPai  	:= ""
	local cPct      	:= ""
	local cDenReg   	:= ""
	local cFaDent   	:= ""
	local nPac      	:= 1
	Local aVigOrc		:= {} //PE de vigencia do tratamento
	Local dVigIni		:= CTOD("")
	Local dVigFim		:= CTOD("")
	Local lGa2Sessao	:= .T.		//Hs_ExisDic({{"C","GA2_SESSAO"}},.F.)
	Local aOrca     	:= {}
	Local lOrcLib   	:= .F.
	Local cCodReg		:= ""
	Local aTabTemp	:= {}
	Local aTabPrec	:= {}
	Local nPrcPart	:= 0
	Local cTabCob		:= ""
	Local aPrecPro	:= {}

	Default aItePre		:= {}
	Default cModCobr	:= cCobranca
	Default lRefresh	:= .T.
	Default cCodTabUt	:= ""

If !Hs_ExisDic({{"C",cAlias + "_CODPRO"}},.T.)
	Return()
EndIf
	If Len(aItePre) == 0

		//Se o paciente possui algum orcamento liberado e/ou em atendimento
		if hs_pacTrat(cRGerSel) .AND. lSupervisor
			
			//Chama tela de senha
			aOrca   := FS_VerOrc()
			lOrcLib := aOrca[1]
			If !lOrcLib
				HS_MSGINF(STR0114, STR0029, STR0010) //"Login e/ou senha informados incorretamente. Orçamento não foi gerado!" ###  ###
				Return()
			Endif
			__cCdJustGT9 := aOrca[2]
			__cCdUsrFGT9 := aOrca[3]
		Endif

		If !(oFolder:lActive .AND. oFolder:nOption == 4)
			MsgStop(STR0085) //"Opção disponivel somente no Exame Clinico!"
			Return()
		ElseIf Len(oGetMPI:aCols) == 1 .AND. Empty(oGetMPI:aCols[1,nMPICodPro])
			MsgStop(STR0084) //"Informe os itens a serem inseridos no orçamento!"
			Return()
		EndIf
		If !MsgYesno(STR0083, STR0029) //"Confirma a geração do orçamento?" ### "Atenção"
			Return()
		EndIf
	EndIf
		If lExCliSAt .AND. 	aScan(oGetPac:aCols, {|aVet| aVet[nGcyOk] == "LBTIK"}) == 0
			If Pergunte("HSPM61", .T.)
				cCodReg := MV_PAR01
			Else
				RestArea(aArea)
				Return()
			EndIf
			DbSelectArea("GBH")
			DbSetOrder(1)
			If DbSeek(xFilial("GBH") + cCodReg)
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1") + GBH->GBH_CODCLI)
				cCliPad := GBH->GBH_CODCLI
				cLojPad := SA1->A1_LOJA
				cRGerSel := GBH->GBH_CODPAC
				cModCobr := FS_GETMODCBR(cRGerSel)
			Else
				RestArea(aArea)
				Return()
			EndIf
		Else
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1") + cCliPad)
		EndIf
		DbSelectArea("GC6")
		DbSetOrder(1)
		If dbSeek(xFilial("GC6") + GA9->GA9_CODCON)
			while GC6->GC6_CODCON == GA9->GA9_CODCON
				nPosTab := aScan(aTabTemp, {|aVet| aVet[2] == GC6->GC6_TABPRO})
				if nPosTab == 0
					aAdd(aTabTemp, {GC6->GC6_CODCON, GC6->GC6_TABPRO, GC6->GC6_DATVIG, GC6->GC6_TABAUX, GC6->GC6_PRIORI})
				else
					if GC6->GC6_DATVIG > aTabTemp[nPosTab][3] //Se é mais atual, substitui e prioriza
						aTabTemp[nPosTab] := {GC6->GC6_CODCON, GC6->GC6_TABPRO, GC6->GC6_DATVIG, GC6->GC6_TABAUX, GC6->GC6_PRIORI}
					endif
				endif
				GC6->(dbSkip())
			enddo
		endif
		if len(aTabTemp) > 0
			aSort(aTabTemp,,,{|x,y| x[5] < y[5]})
			for nI := 1 to len(aTabTemp)
				if empty(aTabTemp[nI,4])
					if aScan(aTabPrec, {|aVet| aVet == aTabTemp[nI,4]}) == 0
						aAdd(aTabPrec, aTabTemp[nI,4])
					endif
				endif
			next nI
			if len(aTabPrec) > 0
				cTabCob := aTabPrec[1]
			endif
		endif
		If Len(aItePre) = 0
			For nI := 1 To Len(oGetMPI:aCols)
				If ValType("nMPIDenReg") # "U" .AND. ValType("nMPIFadent") # "U"
					cDenReg   := oGetMPI:aCols[nI,nMPIDenReg]
					cFaDent   := oGetMPI:aCols[nI,nMPIFaDent]
				EndIf
				If Empty(oGetMPI:aCols[nI,nMPIOrcGer]) .AND. !oGetMPI:aCols[nI, Len(oGetMPI:aHeader)+1]
					DbSelectArea("GA7")
					DbSetOrder(1)
					DbSeek(xFilial("GA7") + oGetMPI:aCols[nI,nMPICodPro])
					DbSelectArea("SB1")
					DbSetOrder(1)
					If DbSeek(xFilial("SB1") + oGetMPI:aCols[nI,nMPICodPro]).AND. GA7->GA7_VINSB1 = "1"
				//Localiza pacote
						aPrecPro := FS_RETPRC(oGetMPI:aCols[nI,nMPICodPro], cPlaAte, dDataBase, cTabCob, aTabPrec)
						if aPrecPro[1]
							nPrcPart := aPrecPro[2]
						else
							nPrcPart := aPrecPro[2]
						//HS_MsgInf(STR0116 + " [" +  alltrim(oGetMPI:aCols[nI,nMPICodPro]) + " - " + ALLTRIM(Posicione('GA7',1,xFilial('GA7') + Padr(alltrim(oGetMPI:aCols[nI,nMPICodPro]), TamSx3("GA7_CODPRO")[1]) , 'GA7_DESC  ')) + ; //"O procedimento"
							//"] " + STR0117 + " (" + cTabCob + " - " + ALLTRIM(Posicione('GDB',1,xFilial('GDB') + cTabCob, 'GDB_DESCRI')) + ")." + CHR(10) + CHR(13) + CHR(10) + CHR(13) +; //"não possui vinculo com a tabela de procedimentos definida"
							//STR0118, STR0029, STR0035)  // ### "O orçamento não foi gerado", "Validação Prontuário Clinicas"
					    //Return()
						endif
						DbSelectArea("GA1")
						DbSetOrder(3)
						If DbSeek(xFilial("GA1") + PADR(SB1->B1_COD,TamSx3("GA1_CODPRO")[1]) )
							cPct     := GA1->GA1_CODPCT
							cProcPai := ""
						else
					//Se nao ha pacote, grava o codigo do produto (+ NRO PRA DIFERENCIACAO)
					//cPct     := PADR(SB1->B1_COD,TamSx3("GA1_CODPRO")[1])+ cValToChar(nPac)
							cPct     := ""
					//nPac++
						endif

						aItePct := HS_RetPct(oGetMPI:aCols[nI,nMPICodPro], 3) // Inclui itens do Pacote/Procedimento Padrão
						If Len(aItePct) > 0
							AADD(aItens ,{oGetMPI:aCols[nI,nMPICodPro], SB1->B1_PRV1, SB1->B1_PRV1, SB1->B1_UM, SB1->B1_DESC,SB1->B1_PRV1,0,0,1,""/* Codigo do Item gerado no orçamento */, oGetMPI:aCols[nI,nMPIItem],cPct,oGetMPI:aCols[nI,nMPICodPro],cDenReg, cFaDent, "" ,.T., "" })
							For nP := 1 to Len(aItePct)
								DbSelectArea("SB1")
								DbGoTop()
								DbSetOrder(1)
								If DbSeek(xFilial("SB1") + PadR(AllTrim(aItePct[nP,2]), Len(SB1->B1_COD)))
									AADD(aItens ,{aItePct[nP,2], SB1->B1_PRV1, SB1->B1_PRV1, SB1->B1_UM, SB1->B1_DESC,SB1->B1_PRV1,0,0,1,""/* Codigo do Item gerado no orçamento */, oGetMPI:aCols[nI,nMPIItem],aItePct[nP,9]/*Pacote*/,aItePct[nP,10]/*Proced pai*/,cDenReg, cFaDent,iIf(lGa2Sessao,aItePct[nP,11],"")/*GA2_SESSAO*/,.F., "" })
								EndIf
							Next nP
						Else              //If cModCobr == "0"  Tipo de convenio (GA9_TIPCON = 0:Convenio;1:Particular)
							AADD(aItens ,{oGetMPI:aCols[nI,nMPICodPro], nPrcPart, nPrcPart, SB1->B1_UM, SB1->B1_DESC,nPrcPart,0,0,1,""/* Codigo do Item gerado no orçamento */, oGetMPI:aCols[nI,nMPIItem],cPct,"",cDenReg, cFaDent, "" ,.T., ""})
				//Else
				//	AADD(aItens ,{oGetMPI:aCols[nI,nMPICodPro], SB1->B1_PRV1, SB1->B1_PRV1, SB1->B1_UM, SB1->B1_DESC,SB1->B1_PRV1,0,0,1,""/* Codigo do Item gerado no orçamento */, oGetMPI:aCols[nI,nMPIItem],cPct,"",cDenReg, cFaDent,"",.T., "" })
						EndIf
					EndIf
				EndIf
			Next nI
		Else
			aItens := aClone(aItePre)
		EndIf
		if Len(aItens) > 0
			cOrcAtu := HS_GORCAUT(@aItens,, cCliPad, SA1->A1_LOJA, SA1->A1_NOME, dDataBase)
		EndIf
		If !Empty(cOrcAtu)
			For nI := 1 To Len(oGetMPI:aCols)
				If Empty(oGetMPI:aCols[nI,nMPIOrcGer]) .AND. (nPosIte := aScan(aItens, {|aVet| aVet[11] == oGetMPI:aCols[nI,nMPIItem]})) > 0 .and. oGetMPI:aCols[nI,len(oGetMPI:aCols[nI])] == .F.
					oGetMPI:aCols[nI,nMPIOrcGer] := cOrcAtu
					oGetMPI:aCols[nI,nMPIItemOr] := Strzero(val(aItens[nPosIte, 10]),tamSx3("GTD_ITEMOR")[1])
					DbSelectArea(cAliasHIS)
					DbSetOrder(2) //GTO_FILIAL+GTO_NUMFAT+GTO_ITEMOR // GTC_FILIAL+GTC_NUMFAT+GTC_ITEMOR
					If DbSeek(xFilial(cAliasHIS) + oGetMPI:aCols[nI,nMPIOrcGer] + oGetMPI:aCols[nI,nMPIItemOr])
						cSql := " SELECT MAX(" + cAliasHIS + "_ITEM) nItem FROM " + RetSqlName(cAliasHIS) + " " + cAliasHIS
						cSql += " WHERE " + cAliasHIS + "_FILIAL = '" + xFilial(cAliasHIS) + "' AND " + cAliasHIS + "_NUMFAT = '" + oGetMPI:aCols[nI,nMPIOrcGer] + "' "
						cSql += " AND " + cAliasHIS + "_ITEMOR = '" + oGetMPI:aCols[nI,nMPIItemOr] + "' AND D_E_L_E_T_ <> '*'"
						cSql := ChangeQuery(cSql)
						TCQUERY cSql NEW ALIAS "QRYMAX"
						If !QRYMAX->(Eof())
							if !empty(QRYMAX->nItem)
								cItem := StrZero(QRYMAX->nItem + 1, Len(GTC->GTC_ITEM))
							else
								QRYMAX->(dbCloseArea())
						/////////
								cSql := " SELECT MAX(" + cAliasHIS + "_ITEM) nItem FROM " + RetSqlName(cAliasHIS) + " " + cAliasHIS
								cSql += " WHERE " + cAliasHIS + "_FILIAL = '" + xFilial(cAliasHIS) + "' AND " + cAliasHIS + "_NUMFAT = '" + oGetMPI:aCols[nI,nMPIOrcGer] + "' "
								cSql += " AND D_E_L_E_T_ <> '*'"
								cSql := ChangeQuery(cSql)
								TCQUERY cSql NEW ALIAS "QRYMAX"
								If !QRYMAX->(Eof())
									cItem := StrZero(val(QRYMAX->nItem) + 1, Len(GTC->GTC_ITEM))
								endif
						////
							endif
						EndIf
						DbSelectArea("QRYMAX")
						QRYMAX->(dbCloseArea())
					Else
						cItem := StrZero(++nItem, Len(GTC->GTC_ITEM))
					EndIf
					DbSelectArea(cAliasHIS)
					RecLock(cAliasHIS , .T.)
					&(cAliasHIS+"->"+cAliasHIS+"_FILIAL") 	:= xFilial(cAliasHIS)
					&(cAliasHIS+"->"+cAliasHIS+"_NUMFAT") 	:= oGetMPI:aCols[nI,nMPIOrcGer]
					&(cAliasHIS+"->"+cAliasHIS+"_ITEM") 	:= cItem
					&(cAliasHIS+"->"+cAliasHIS+"_ITEMOR") 	:= StrZero(Val(oGetMPI:aCols[nI,nMPIItemOr]), Len(SCK->CK_ITEM))
					&(cAliasHIS+"->"+cAliasHIS+"_DATHIS") 	:= dDataBase
					&(cAliasHIS+"->"+cAliasHIS+"_HISATE") 	:= oGetMPI:aCols[nI,nMPIHisAte]
					&(cAliasHIS+"->"+cAliasHIS+"_CODPRO") 	:= oGetMPI:aCols[nI,nMPICodPro]
					If cAliasHIS == "GTC"
						&(cAliasHIS+"->"+cAliasHIS+"_DENREG") 	:= oGetMPI:aCols[nI,nMPIDenReg]
						&(cAliasHIS+"->"+cAliasHIS+"_FADENT") 	:= oGetMPI:aCols[nI,nMPIFaDent]
					Else
						&(cAliasHIS+"->"+cAliasHIS+"_CODREG") 	:= oGetMPI:aCols[nI,nMPICodReg]
						&(cAliasHIS+"->"+cAliasHIS+"_DESREG") 	:= oGetMPI:aCols[nI,nMPIDesReg]
					EndIf
					MsUnlock()
				EndIf
				If cAliasHIS == "GTC"
					AADD(aDenGTJ, {oGetMPI:aCols[nI,nMPIOrcGer], StrZero(Val(oGetMPI:aCols[nI,nMPIItemOr]), Len(SCK->CK_ITEM)), oGetMPI:aCols[nI,nMPIDenReg], oGetMPI:aCols[nI,nMPIFaDent]	})
				EndIf
			Next nI
			DbSelectArea("SCJ")
			DbSetorder(1)
			DbSeek(xFilial("SCJ") + cOrcAtu)
			RecLock("GT9", .T.)
			GT9->GT9_FILIAL := xFilial("GT9")
			GT9->GT9_NUMFAT	:= cOrcAtu
			GT9->GT9_CLIENT	:= cCliPad
			GT9->GT9_USUORC	:= cUsername
			GT9->GT9_DTEMIS	:= SCJ->CJ_EMISSAO
			GT9->GT9_STATUS	:= '0'
			GT9->GT9_COBRAN	:= cModCobr
			If !Empty(cCodTabUt)		//HS_ExisDic({{"C", "GT9_TABUTI"}},.F.) .AND. !Empty(cCodTabUt)
				GT9->GT9_TABUTI	:= cCodTabUt
			EndIf
			If !Empty(cRGerSel)			//HS_ExisDic({{"C", "GT9_REGGER"}},.F.) .AND. !Empty(cRGerSel)
				GT9->GT9_REGGER	:= cRGerSel
			EndIf
			aCtrVig := HS_GETNRCTR(cCliPad)
			GT9->GT9_NRCONT	:= aCtrVig[1]//HS_GETNRCTR(SA1->A1_COD)
			GT9->GT9_VIGINI	:= IIf(Empty(aCtrVig[2]), SCJ->CJ_EMISSAO, STOD(aCtrVig[2]))
			GT9->GT9_VIGFIN	:= IIf(Empty(aCtrVig[3]), SCJ->CJ_VALIDA, STOD(aCtrVig[3]))
			If ExistBlock("HSFUSVIG") // Ponto de Entrada da Vigencia do tratamento
				aVigOrc := ExecBlock("HSFUSVIG", .F., .F., {cOrcAtu, SA1->A1_COD})
				If ValType(aVigOrc) == "A"
					dVigIni := aVigOrc[1]
					dVigFim := aVigOrc[2]
				EndIf
				GT9->GT9_VIGINI	:= IIF(!Empty(dVigIni), dVigIni,GT9->GT9_VIGINI)
				GT9->GT9_VIGFIN	:= IIF(!Empty(dVigFim), dVigFim,GT9->GT9_VIGFIN)
			EndIf
	If Type("__cCdJustGT9") # "U" .AND. !Empty(__cCdJustGT9) //.AND. HS_ExisDic({{"C", "GT9_MTVAGE"}},.F.)
				GT9->GT9_MTVAGE := __cCdJustGT9
				GT9->GT9_USRFOR := __cCdUsrFGT9
				__cCdJustGT9 	:= ""
				__cCdUsrFGT9	:= ""
			EndIf
			MsUnlock()
			FS_GRVGTJ(cOrcAtu, aDenGTJ, aItens)
			fs_Salva()	//	Grava Atendimento
			HS_MSGINF(STR0082 + cOrcAtu + "", STR0029, STR0010)//"Orçamento gerado: " ### "Atenção" ### "Exame Clinico"
		Else
			HS_MSGINF(STR0081, STR0029, STR0010) //"Orçamento não gerado! Verifique se existem itens e os mesmos ainda não foram gerados." ###  ###
		EndIf
		if funName() == "HSPAHM57" .AND. lRefresh
			FS_REFRESH(DTOS(oCalend:dDiaAtu))
		endif

Return(cOrcAtu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GrvSol ³ Autor ³ Saude     			³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GRAVA SOLICITACAO DE AUTORIZACAO NA GNX                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GrvSol(cRegAte,aGE3)
	Local nI       := 0
	Local aHProc  := {{	"","GE3_FILIAL"},{"","GE3_DATSOL"},{"","GE3_HORSOL"},{"","GE3_QTDSOL"},{"","GE3_CODDES"},{"","GE3_CODPRT"},;
		{"","GE3_SEQDES"},{"","GE3_LOGARQ"},{"","GE3_STATUS"},{"","GE3_REGATE"},{"","GE3_NRSEQG"}}
	Local aCProc  := {}
	Local aHMat   := {}
	Local aCMat   := {}
	Local cCodSol := ""

	For nI := 1 to Len(aGE3)
		AADD(aCProc,{xFilial("GE3"),dDataBase,Time(),aGE3[nI][2],aGE3[nI][1],,GetSXEnum("GE3","GE3_SEQDES",, 1),HS_LogArq(),"0",cRegAte,aGE3[nI][3]})
	Next nI

	DbSelectArea("GCY")
	DbSetOrder(1)
	If DbSeek(xFilial("GCY") + cRegAte)
		cCodSol := HS_GRVGNX(GCY->GCY_REGGER,GCY->GCY_NOME,Substring(cUsuario,7,15),,cRegAte, HS_IniPadr("GCZ", 2, cRegAte, "GCZ_CODPLA",,.F.),"E","2",GCY->GCY_REGIME,"1",HS_IniPadr("GCZ", 2, cRegAte, "GCZ_INDCLI",,.F.),,,aHProc,aCProc,aHMat,aCmat,GCY->GCY_CODCRM,GCY->GCY_CIDINT,HS_IniPadr("GCZ", 2, cRegAte, "GCZ_TDTISS",,.F.),cCodSol)
	EndIf

Return(cCodSol)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HS_M57COBR ³ Autor ³ Saude     			³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GRAVA MODO DE COBRANÇA NO CAMPO                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M57COBR(cNumOrc, cModCobr)
	Local aArea := GetArea()

	DbSelectArea("GT9")
	DbSetOrder(1)
	If DbSeek(xFilial("GT9") + cNumOrc)
		If GT9->GT9_COBRAN <> M->GT9_COBRAN
			RecLock("GT9", .F.)
			GT9->GT9_COBRAN := M->GT9_COBRAN
			MsUnlock()
		EndIf
	EndIf

	RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_ADX3COLS ³ Autor ³ Saude     			³ Data ³ 08/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona restante dos campos do arquivo no aCpos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_ADX3COLS(cAlias, aCampos, lAjustaOrdem)
	Local aArea := GetArea()
	DbSelectArea("SX3")
	DbSetOrder(1) // X3_ARQUIVO
	DbGoTop()
	DbSeek(cAlias)
	While !Eof() .And. SX3->X3_ARQUIVO == cAlias
		If 	X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE = "S" .AND. !("FILIAL" $ SX3->X3_CAMPO)
			If aScan(aCampos, {|aVet| aVet == Alltrim(SX3->X3_CAMPO)}) == 0
				aAdd(aCampos, SX3->X3_CAMPO)
			EndIf
		EndIf
		DbSkip()
	EndDo
	RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GRVGTJ  ³ Autor ³ Saude     			³ Data ³ 09/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava itens do orçamento na GTJ                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GRVGTJ(cNumOrc, aDente, aItens)
	Local aArea	:= getArea()
	Local aSCK := {}
	Local aGTJ := {}
	Local cSql := ""
	Local nIt, nOrd	:= 0
	Local nPs	:= 0
	local nI    := 0
	local cPct  := ""
	local cProcPai := ""
	Local cSessao  := ""

	Default aDente := {}
	Default aItens := {}

	DbSelectArea("SCK")
	DbSetOrder(1)
	If !DbSeek(xFilial("SCK") + cNumOrc)
		Return()
	EndIf

	if empty(aItens)

		cSql := " SELECT CK_ITEM, CK_PRODUTO FROM " + RetSqlName("SCK") + " SCK "
		cSql += " WHERE CK_NUM = '" + cNumOrc + "' AND CK_FILIAL = '" + xFilial("SCK") + "' AND D_E_L_E_T_ <> '*' "
		cSql := ChangeQuery(cSql)
		TCQUERY cSql NEW ALIAS "QRYSCK"

		DbSelectArea("QRYSCK")
		While !Eof()
			AADD(aSCK, {QRYSCK->CK_PRODUTO, QRYSCK->CK_ITEM, "", "","","","",""})
			DbSkip()
		End
		DbSelectArea("QRYSCK")
		DbCloseArea()
	else
		For nI := 1 to len(aItens)
//		AADD(aSCK, {aItens[nI,1]/*Produto*/, aItens[nI,10]/*Item*/,aItens[nI,12]/*Pacote*/,iIf(empty(aItens[nI,13]),aItens[nI,1],aItens[nI,13])/*Proc Principal*/,aItens[nI,14]/*DENREG*/,aItens[nI,15]/*FADENT*/ })
			If !aItens[nI,17]
				AADD(aSCK, {aItens[nI,1]/*Produto*/, aItens[nI,10]/*Item*/,aItens[nI,12]/*Pacote*/,iIf(empty(aItens[nI,13]),nil,aItens[nI,13])/*Proc Principal*/,aItens[nI,14]/*DENREG*/,aItens[nI,15]/*FADENT*/,aItens[nI,16]/*GA2_SESSAO*/, aItens[nI, 18]/* GTJ_ITEPAI */ })
			ElseIf aItens[nI,17] .AND. Empty(aItens[nI,13])
				AADD(aSCK, {aItens[nI,1]/*Produto*/, aItens[nI,10]/*Item*/,aItens[nI,12]/*Pacote*/,iIf(empty(aItens[nI,13]),nil,aItens[nI,13])/*Proc Principal*/,aItens[nI,14]/*DENREG*/,aItens[nI,15]/*FADENT*/,aItens[nI,16]/*GA2_SESSAO*/, aItens[nI, 18]/* GTJ_ITEPAI */  })
			EndIf
		next nI
	endif


	//Ordenação do plano de tratamento conforme configuração
	For nIt := 1 To Len(aSCK)
		DbSelectArea("GA7")
		DbGoTop()
		DbSetOrder(1)
		//If DbSeek(xFilial("GA7") + PADR(aSCK[nIt,1], TamSx3("GA7_CODPRO")[1]))
		If DbSeek(xFilial("GA7") + PADR(aSCK[nIt,4], TamSx3("GA7_CODPRO")[1]))
			DbSelectArea("GFR")
			DbGoTop()
			DbSetOrder(1)
			DbSeek(xFilial("GFR") + GA7->GA7_CODESP)
			//AADD(aGTJ, {aSCK[nIt,1],aSCK[nIt,2], GFR->GFR_PRIORI,GA7->GA7_PRIORI})
			AADD(aGTJ, {aSCK[nIt,1],aSCK[nIt,2], GFR->GFR_PRIORI,GA7->GA7_PRIORI, aSCK[nIt,3]/*pACOTE*/,aSCK[nIt,4]/*Proc Princ*/,aSCK[nIt,5]/*DENREG*/,aSCK[nIt,6]/*FADENT*/,aSCK[nIt,7]/*GA2_SESSAO*/, aSCK[nIt,8]})
		Else
			AADD(aGTJ, {aSCK[nIt,1],aSCK[nIt,2], ""             ,""             , aSCK[nIt,3]          ,aSCK[nIt,4]              ,aSCK[nIt,5]/*DENREG*/,aSCK[nIt,6]/*FADENT*/,aSCK[nIt,7]/*GA2_SESSAO*/, aSCK[nIt,8]})
		EndIf
	Next nIt
	//aSort(aGTJ,,,{|x,y| x[3] + x[4] + x[5] < y[3] + y[4] + y[5]})
	aSort(aGTJ,,,{|x,y| x[3] + x[4] + x[5] + x[9] < y[3] + y[4] + y[5] + y[9]})
	//nOrd := 0
	nOrd := 10
	For nIt := 1 To Len(aGTJ)
		cPct     := aGTJ[nIt,5]
		cProcPai := aGTJ[nIt,6]
		cSessao  := aGTJ[nIt,9]
		DbSelectArea("GTJ") //GTJ_FILIAL + GTJ_NUMORC + GTJ_ITEM 
		DbSetorder(1)
		If !DbSeek(xFilial("GTJ") + cNumOrc + aGTJ[nIt, 2])
			RecLock("GTJ", .T.)
			GTJ->GTJ_FILIAL := xFilial("GTJ")
			GTJ->GTJ_NUMORC	:= cNumOrc
			GTJ->GTJ_ITEM	:= aGTJ[nIt, 2]
			GTJ->GTJ_STATUS	:= '0'
			//GTJ->GTJ_PRIORI	:= PADL(Alltrim(Str(nOrd)),TamSx3("GTJ_PRIORI")[1],"0")
			//if nIt > 1 .and. cPct == aGTJ[nIt-1,5] .and. !empty(cPct)
				If nIt > 1 .and. cPct == aGTJ[nIt-1,5] .and. cSessao == aGTJ[nIt-1,9] .and. !empty(cPct)
				GTJ->GTJ_PRIORI	:= PADL(Alltrim(Str(nOrd)),TamSx3("GTJ_PRIORI")[1],"0")
				Else
					IIf(nIt > 1,nOrd := nOrd + 10,)
				GTJ->GTJ_PRIORI	:= PADL(Alltrim(Str(nOrd)),TamSx3("GTJ_PRIORI")[1],"0")
				Endif

			GTJ->GTJ_PRODUT := aGTJ[nIt,1]
			If Len(aDente) > 0			//Hs_ExisDic({{"C", "GTJ_DENREG"}}, .F.) .AND. Len(aDente) > 0
				/*
				If (nPs := aScan(aDente, {|aVet| aVet[1]+aVet[2] == cNumOrc+aGTJ[nIt, 2]})) > 0
					GTJ->GTJ_DENREG := aDente[nPs, 3]
					GTJ->GTJ_FADENT := aDente[nPs, 4]
				EndIf
				*/
				GTJ->GTJ_DENREG := aGTJ[nIt, 7]
				GTJ->GTJ_FADENT := aGTJ[nIt, 8]
			EndIF
			GTJ->GTJ_PROPAI := aGTJ[nIt, 6]
			GTJ->GTJ_SESSAO := aGTJ[nIt, 9]
			GTJ->GTJ_ITEPAI := aGTJ[nIt,10]

			MsUnlock()
		
		EndIf
	Next nIt
	RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_vldSala³ Autor ³ Saude     	 	     ³ Data ³14/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o codigo da sala (usado no pergunte HSPM57)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        		           |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function hs_vldSala(cVar)
	local aArea := GetArea()
	local lRet  := .F.
	Default cVar  := &(readVar())

	DbSelectArea("GF3")
	DbSetOrder(1)
	if !empty(cVar) .and. DbSeek(xFilial("GF3") + cVar)
		lRet := .T.
	elseif !empty(cVar)
		lRet := .F.
		HS_MSGINF(STR0079,STR0029, STR0080) //"Sala não localizada!" ### "Atenção" ### "Validação Prontuário Eletrônico"
	elseif empty(cVar)
		lRet := .T.
	endif
	RestArea(aArea)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VldSenhM57ºAutor  ³ Saude              º Data ³22/06/2011º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Programa para valida‡Æo de senha/profissional              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VldSenhM57(cUsuHsp, cLogin, lExibeSala, lExibeMoti, cMotivo)
	Local llPassW 		:= .F.
	Local cMudaSala		:= Space(TamSx3("GM6_CODSAL")[1])

	Private cSenHsp    := Space(25)
//Private cUsuHsp := Space(15)
	Default cUsuHsp    := Space(25)
	Default cLogin     := ""
	Default lExibeSala := .T.
	Default lExibeMoti := .F.
	cMotivo		:= Space(TamSx3("GT7_CODMTV")[1])

	DEFINE MSDIALOG oDlgSenha TITLE STR0111 FROM 0,0 TO 120,320 PIXEL                             //"Senha"
	@ 010,002 Say OemToAnsi(STR0078) Size 050, 009 PIXEL COLOR CLR_BLUE //"Nome do Usuario: "
	@ 010,055 MSGet oEdit1 var cUsuHsp Size 100, 009 OF oDlgSenha PIXEL COLOR CLR_BLACK
	@ 025,002 Say OemToAnsi(STR0077) Size 050, 009 PIXEL COLOR CLR_BLUE //"Senha do Usuario: "
	@ 025,055 MSGet oEdit2 var cSenHsp PASSWORD Size 100, 009 OF oDlgSenha PIXEL COLOR CLR_BLACK
	if lExibeSala
		@ 042,002 Say OemToAnsi(STR0076) Size 050, 009 PIXEL COLOR CLR_BLUE //"Sala: "
		@ 042,055 MSGet oEdit3 var cMudaSala Size 30, 009 F3 "GF3" VALID Hs_VldSala(cMudaSala) OF oDlgSenha PIXEL COLOR CLR_BLACK
	elseif lExibeMoti
		@ 042,002 Say OemToAnsi(STR0075) Size 050, 009 PIXEL COLOR CLR_BLUE //"Motivo: "
		@ 042,055 MSGet oEdit4 var cMotivo Size 30, 009 F3 "GT7" VALID Hs_vldJust(cMotivo) OF oDlgSenha PIXEL COLOR CLR_BLACK
	endif

	//oBtn1 := tButton():New(042, 113, "Confirmar", oDlgSenha, {|| FS_QdoPswM57(cUsuHsp, cSenHsp, @llPassW, @cLogin )}, 040, 011,,,, .T.)//"Confirmar"
	oBtn1 := tButton():New(042, 113, STR0056, oDlgSenha, {|| iIf(fs_VldMotivo(lExibeMotivo, cMotivo),FS_QdoPswM57(cUsuHsp, cSenHsp, @llPassW, @cLogin ),llPassW := .F. )}, 040, 011,,,, .T.)//"Confirmar"
	ACTIVATE MSDIALOG oDlgSenha CENTERED

	If llPassW .AND. !Empty(cMudaSala)
		cCodSala := cMudaSala
	EndIf

Return(llPassW)

static function fs_VldMotivo(lMot, cCodMot)
	local lRet := .T.
	if lMot
		if empty(cCodMot)
			lRet := .F.
			HS_MSGINF(STR0074, STR0029, STR0030) //"Informe o motivo para reordenação dos procedimentos!"
		endif
	endif

return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_QdoPswM57ºAutor  ³ Suporte Rdmake     º Data ³  02/06/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Valida a senha digitada.                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAQDO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_QdoPswM57(cUsuHsp, cSenHsp, llPassW, cLogin)
//Local i := 0
	Local _daduser  :=_grupo:={}
	Default cLogin := space(25)

	PswOrder(2)

	If PswSeek(cUsuHsp, .T.)
		_daduser := PswRet(1)
		cLogin := _daduser[1,2]

		PswOrder(2)
		If PswSeek(cUsuHsp,.T.)
			If PswName(cSenHsp)
				llPassW := .T.
			Else
				llPassW := .F.
				MsgInfo(STR0072,STR0073) //"A senha esta incorreta!"###"Senha"
			EndIf
		EndIf
	Else
		llPassW := .F.
		MsgInfo(OemToAnsi(STR0070),OemToAnsi(STR0071)) //"Usuário sem permissão para acesso!" ### "Usuário"
	Endif


	oDlgSenha:End()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_M57LEG ³ Autor ³Paulo Emidio de Barros ³ Data ³02/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas no Agendamento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAHM54LEG()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FS_M57LEG()
	local aLegenda := {}

	Aadd(aLegenda,{"BR_VERDE"   ,OemToAnsi(STR0067)}) //"Em Atendimento"
	Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0068)}) //"Chamado no Painel"
	Aadd(aLegenda,{"BR_CINZA"   ,OemToAnsi(STR0069)}) //"Aguardando Atendimento"


	BrwLegenda(cCadastro,STR0066,aLegenda) //"Legenda"

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HS_ChgMapIm³ Autor ³ Saude     	 	     ³ Data ³27/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Muda a imagem do mapeamento						           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        		           |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_ChgMapIm()
	Local aArea 	:= GetArea()
	Local cCodNew	:= ""

//================================================================¿
//³ Busca Odontogramas atribuidos a especialidade profissional   ³
//================================================================Ù
	cCond := ""
	cCond :=" GTE.GTE_FILIAL = '" + xFilial("GTE") + "' AND GTE.D_E_L_E_T_ <> '*' "
	cCond +=" AND GTE_ESPECI IN "
	cCond +=" ( "+cEspecMed+"	) AND GTE_TIPCFG = '" + cTipOdtGr + "'"
	cCodNew := HS_OdnGram(cCond)

	If cCodNew == cCodOdtGr
		Return()
	EndIf

	cCodOdtGr := cCodNew

	If !Empty(cCodOdtGr)
		DbSelectArea("GTE")
		DbSetOrder(1)
		If DbSeek(xFilial("GTE") + cCodOdtGr)
			cImgOdtGr := Alltrim(GTE->GTE_IMAGEM)
		/*If !(":" $ cImgOdtGr)
			cImgOdtGr := cDirRaiz + cImgOdtGr
		EndIf*/
			aCoordOdg := HS_COORDMPI(cCodOdtGr)
		Else
			Return
		EndIf
	EndIf

	oDrawer:ClearImage()
	oDrawer:OpenImage(cImgOdtGr)
	oDrawer:Refresh()

	RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AJUSORDº Autor ³ Microsiga          º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta ordem de exibicao dos campos na tela.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_AJUSORD( aCpos , aForca )

	Local aArea 	:= getArea()
	Local aOrdena	:= {}
	Local aRet		:= {}
	Local cAlsAtu	:= ""
	Local nI		:= 0

	Default aForca	:= {}

	For nI := 1 To Len(aCpos)

		cAlsAtu := SubStr(aCpos[nI],1,(at(aCpos[nI],"_")-1))
		DBSelectArea("SX3")
		SX3->( DBSetOrder(2) )
		SX3->( DbGoTop() )
		If SX3->( DBSeek(aCpos[nI]) ) .And. ( SX3->X3_BROWSE == "S" .OR. aScan( aForca , {|aVet| aVet == aCpos[nI]} ) > 0 )

			AADD( aOrdena , { aCpos[nI] , cAlsAtu , SX3->X3_ORDEM } )

		EndIf

	Next nI

	aSort(aOrdena,,,{|x,y| x[2] + x[3] < y[2] + y[3]})

	For nI := 1 To Len(aOrdena)

		AADD(aRet, aOrdena[nI,1])

	Next nI

	RestArea(aArea)

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_vIncReo      ³Autor³Saude               ³Data³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe mensagem de incompatibilidade recebida e, caso o     ³±±
±±³          ³ usuario clique no botao "Forcar" chama  tela para digitacao³±±
±±³          ³ de senha do superior                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_autProSup(cMsg)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ cMsg - Mensagem de incompatibilidade que será exibida      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

static function fs_autProSup(cUserAut, cMotivo)
	local aArea        := getArea()
	local lRet         := .F.
	local cUserReor    := Space(25)
	local cPassReor    := Space(25)
	local aCoduserAut  := ""

	Default cUserAut := Space(25)
	Default cMotivo  := Space(TamSx3("GT7_CODIGO")[1])

	if SuperGetMV("MV_PSSCPE", NIL, .F.)
		if allTrim(upper(SuperGetMV("MV_PSSTIP", NIL, "M"))) == "M" //Medico
			If FS_VldSenhM57(@cUserReor,@cPassReor, .F., .T. , @cMotivo)
				If !(aCoduserAut := HS_VldDAnm(.T.,,cUserReor))[1]
					lRet := .F.
				else
				//MSGINFO("O medico tem permissao ...")
					lRet     := .T.
					PswOrder(1)
					PswSeek(cUserReor,.T.)
					cUserAut  := PSWRET(1)[1][4]
				EndIf
			endif
		elseif allTrim(upper(SuperGetMV("MV_PSSTIP", NIL, "M"))) == "S" //Usuario Superior
			aCoduserAut := FS_VERORC()
			if aCoduserAut[1]
				lRet     := .T.
				PswOrder(1)
				PswSeek(aCoduserAut[3],.T.)
				cUserAut  := PSWRET(1)[1][4]
				cMotivo   := aCoduserAut[2]
			else
				lRet := .F.
			endif
		else
			HS_MSGINF(STR0065,STR0029, STR0030)//"Ajuste o valor do parâmetro 'MV_PSSTIP' para definir o tipo de usuário autorizador para reordenação de prioridade do procedimento!","Atenção", "Validação Atualização Orçamento"
			lRet := .F.
		endif
	else
		lRet := .T.
		PswOrder(1)
		PswSeek(__CUSERID,.T.)
		cUserAut  := PSWRET(1)[1][4]
		cMotivo   := HS_Justif()
		if empty(cMotivo)
			HS_MSGINF(STR0063 + chr(10) + chr(13) + ;
				STR0064,STR0029, STR0030)//"Informe o motivo para reordenação de prioridade do procedimento!" ### "Procedimento não foi reordenado." ### "Atenção" ### "Validação Atualização Orçamento"
			lRet := .F.
		endif
	endif

	restArea(aArea)
return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fs_opPlnTrat     ³Autor³Saude               ³Data³11/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exibe a tela de opcoes para manipulacao de itens do plano de³±±
±±³          ³tratamento                                                  ³±±
±±³          ³VALIDO SOMENTE PARA AGENDAMENTO ATRAVES DA SOLICITACAO APAC ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_opPlnTrat()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function fs_opPlnTrat()
	local aArea      := getArea()
	Local oBtnOk
	Local oBtnCanc
	Local oRadioPlTr
	Local nRadioPlTr := 1
	Local nI := 0
	Local nTamI := 45
	Local nTamTela := 130
	Local aOpcPlnTrt  := {}
	Local aRdItens := {STR0058,STR0059,STR0060,STR0061} //"Repetir" ### "Finalizar" ### "Excluir" ### "Grava Histórico"
	Local aItensadd := {}

//Ponto de Entrada para customização das Opções
	If ExistBlock("HM57ADDOPC")
		aItensadd := ExecBlock("HM57ADDOPC", .F., .F.)
		For nI := 1 To Len(aItensadd)
			AADD(aRdItens,aItensadd[nI])
			nTamI += 10 - (nI / 2)
			nTamTela += 15
		Next nI
	EndIf


	Static oDlgPlnTrat

//Se o duplo click foi na coluna "status", exibe a legenda
	if oGetItePln:oBrowse:nColPos == nSckStatus
		HSPAHM57LEG()
	elseif !empty(oGetItePln:aCols[oGetItePln:nAt,nSckProPln]) .AND. !(oGetItePln:aCols[oGetItePln:nAt,nSckStatus] == "BR_PRETO")
		DEFINE MSDIALOG oDlgPlnTrat TITLE STR0062 FROM 000, 000  TO nTamTela, 200 COLORS 0, 16777215 PIXEL //"Selecione a opção : "

		dbSelectArea("GT9")
		dbSetOrder(1)
		if dbSeek(xFilial("GT9") + oGetOrcPln:aCols[oGetOrcPln:nAt,nGt9NumFat])
			if GT9->GT9_STATUS == "6"
				@ 004, 025 RADIO oRadioPlTr VAR nRadioPlTr ITEMS STR0058 SIZE 050, 031 OF oDlgPlnTrat COLOR 0, 16777215 PIXEL //"Repetir"
		//se nao esta liberado/em tratamento/finalizado nao permite manipulacao
			elseif GT9->GT9_STATUS $ "0124" //0=Orc. Pendente;1=Pend. Financ.;2=Aprovado;3=Liberado;4=Cancelado;5=Em tratamento;6=Finalizado
				HS_MSGINF(STR0112 + " (" +;
					hs_gDesCbx("GT9_STATUS", GT9->GT9_STATUS) + ") " + STR0113,STR0029, STR0030	)//"Não é possível manipular o procedimento pois o status atual do orçamento (XXXXXX) não permite alteração!","Atenção", "Validação Atualização Plano de Tratamento"
				restArea(aArea)
				return
			else
			//@ 004, 025 RADIO oRadioPlTr VAR nRadioPlTr ITEMS STR0058,STR0059,STR0060,STR0061 SIZE 050, 031 OF oDlgPlnTrat COLOR 0, 16777215 PIXEL //"Repetir" ### "Finalizar" ### "Excluir" ### "Grava Histórico"
				oRadioPlTr := tRadMenu():New(005,025,aRdItens,{|u|if(PCount()>0,nRadioPlTr:=u,nRadioPlTr)},oDlgPlnTrat,,,,,,,,100,10,,,,.T.)
			endif
		endif
		@ nTamI, 005 BUTTON oBtnOk   PROMPT STR0056 SIZE 037, 012 OF oDlgPlnTrat ACTION {|| oDlgPlnTrat:End(),fs_opcPlnTrat(nRadioPlTr)} PIXEL //"Confirmar"
		@ nTamI, 058 BUTTON oBtnCanc PROMPT STR0057 SIZE 037, 012 OF oDlgPlnTrat ACTION {|| oDlgPlnTrat:End()} PIXEL //"Cancelar"

		ACTIVATE MSDIALOG oDlgPlnTrat CENTERED

	endif

	restArea(aArea)
return(NIL)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fs_opcPlnTrat    ³Autor³Saude               ³Data³12/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica a opcao selecionada (nOpcao) na funcao fs_opPlnTrat³±±
±±³          ³e executa as acoes correspondentes para o procedimento      ³±±
±±³          ³selecionado em oGetItePln                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_opcPlnTrat(nOpcao)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ nOpcao - Indica o a acao que deve ser executada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

static function fs_opcPlnTrat(nOpcao)
	local aArea      := getArea()
	local cNomCampo  := ""
	local aCposGtj   := {}
	local aCposVlr   := {}
	local nQtdRep    := 0
	local cNumItem   := ""
	local nPriori    := 0
	local nQtdItem   := 0
	local nI         := 0
	local nJ         := 0
	local nL         := 0
	local cNumOrc    := oGetOrcPln:aCols[oGetOrcPln:nAt, nGt9NumFat]
	local cProced    := oGetItePln:aCols[oGetItePln:nAt, nSckProPln]
	local cCodItem   := oGetItePln:aCols[oGetItePln:nAt, nSckItePln]
	local lExisProPai:= .F.
	local cCodProPai := ""
	local cMsg       := ""
	local aTrat      := {}
	local nItensRep  := 0
	local nMvQtdRep  := 0
	local cCrmExec   := ""
	nMvQtdRep  := GetNewPar("MV_QTDREP", 0)

//Ponto de Entrada para validação da Opção Selecionada
	If ExistBlock("HM57VLDOPC")

		lRet := ExecBlock("HM57VLDOPC", .F., .F.,{nOpcao})
		If nOpcao > 4 .Or. !lRet
			Return(.F.)
		EndIf
	EndIf

	if nOpcao == 1 //Repetir Procedimento
		DbSelectArea("GT9")
		DbSetOrder(1)
		If DbSeek(xFilial("GT9") + cNumOrc )
			nQtdRep := GT9->GT9_QTDREP
			//if nQtdRep > 0
			if nQtdRep >= nMvQtdRep
            	//HS_MSGINF("Não foi possível repetir o procedimento pois o orçamento selecionado já possui procedimento(s) repetido(s)!",STR0029, STR0030)//"","Atenção", "Validação Atualização Orçamento"
				HS_MSGINF(STR0054 + " (" + GT9->GT9_NUMFAT + ") " + STR0055 + " (" + cValToChar(nMvQtdRep) + ") !",STR0029, STR0030)//"Não foi possível repetir o procedimento selecionado pois o orçamento correspondente" ### "já atingiu a quantidade máxima de repetições por plano de tratamento / orçamento" ### "Atenção", "Validação Atualização Orçamento"
			else
				DbSelectArea("GTJ")
				DbSetOrder(1)
				If DbSeek(xFilial("GTJ") + cNumOrc + cCodItem )
					//Verifica o profissional executante
					cCrmExec := GTJ->GTJ_CRMEXE

				    //Verifica se o o procedimento selecionado foi realizado
					if GTJ->GTJ_STATUS == "1"
                        //Verifica se o procedimento selecionado faz parte de um tratamento
						if !empty(GTJ->GTJ_PROPAI)
							if msgYesNo(STR0053) //"O procedimento selecionado faz parte de um tratamento, deseja repetir os demais procedimentos já realizados desse tratamento?"
								lExisProPai := .T.
								cCodProPai  := GTJ->GTJ_PROPAI
							endif
						endif

						//Incrementa a quantidade de repeticoes na GT9
						RecLock("GT9", .F.)
						GT9->GT9_QTDREP := ( nQtdRep + 1 )
						MsUnlock()

					 	//Varre a tabela até o ultimo item do orçamento para  obter numero do novo item (cNumItem) e prioridade (nPriori)
						DbSelectArea("GTJ")
						GTJ->(dbGoTop())
						DbSetOrder(1)
						DbSeek(xFilial("GTJ") + cNumOrc)
						while GTJ->GTJ_FILIAL + GTJ->GTJ_NUMORC == xFilial("GTJ") + cNumOrc
							cNumItem := GTJ->GTJ_ITEM
							if val(GTJ->GTJ_PRIORI) > nPriori
								nPriori := val(GTJ->GTJ_PRIORI)
							endif
							GTJ->(dbSkip())
						end

						cNumItem := strZero((val(cNumItem)+1),TamSx3("GTJ_ITEM")[1])
						cPriori  := strZero( nPriori + 10 ,TamSx3("GTJ_PRIORI")[1])


						//Verifica todos os campos da tabela
						aCposGtj := hs_gCpoSx3("GTJ")


						if lExisProPai
							//Verifica quais itens do mesmo tratamento serao repetidos e os adiciona ao vetor aTrat
							DbSelectArea("GTJ")
							GTJ->(dbGoTop())
							DbSetOrder(1)
							DbSeek(xFilial("GTJ") + cNumOrc)
							while GTJ->GTJ_FILIAL + GTJ->GTJ_NUMORC  == xFilial("GTJ") + cNumOrc
							 	//Se faz parte do mesmo tratamento e ja foi realizado
								if GTJ->GTJ_PROPAI == cCodProPai .and. GTJ->GTJ_STATUS == "1" //Realizado
									//Adiciona o procedimento do tratamento que será repetido ao vetor
									aAdd(aTrat, {GTJ->GTJ_FILIAL, GTJ->GTJ_NUMORC, GTJ->GTJ_ITEM, GTJ->GTJ_PRIORI } )
								endif
								GTJ->(dbSkip())
							end

							//se o vetor dos procedimentos que serao repetidos nao estiver vazio
							if !empty(aTrat)
								aSort(aTrat,,,{|x,y| x[4]  < y[4]})
								nItensRep := len(aTrat)
								if nItensRep > 1
									cMsg += STR0052 + ": "	 + chr(10) + chr(13) + chr(10) + chr(13) //"Os procedimentos"
								else
									cMsg += STR0044 + " " //"O procedimento"
								endif
								for nI := 1 to nItensRep
									//Verifica se a prioridade é igual à anterior
									if nI > 1
										if aTrat[nI,4] > aTrat[nI-1,4]
											cPriori  := strZero( val(cPriori) + 10 ,TamSx3("GTJ_PRIORI")[1])
										endif
									endif
									DbSelectArea("GTJ")
									GTJ->(dbGoTop())
									DbSetOrder(1)
									DbSeek(aTrat[nI,1] + aTrat[nI,2] + aTrat[nI,3]) //Filial + Orcamento + Item

									//Preenche vetor com campos e valores para cada campo
									for nJ:= 1 to len(aCposGtj)
										aAdd(aCposVlr,{aCposGtj[nJ], &("GTJ->" + aCposGtj[nJ]) } )
									next nJ


								 	//Atualiza o status do item atual para "Proc Repetido"
									RecLock("GTJ", .F.)
									GTJ->GTJ_STATUS := "5" //aLegGTJ - "Proc Repetido" / HSPAHM57LEG()
									MsUnlock()

									//Inclui novo registro
									RecLock("GTJ", .T.)
									for nL:= 1 to len(aCposVlr)
										cNomCampo := allTrim(aCposVlr[nL,1])
										if cNomCampo == "GTJ_PRIORI"
											&("GTJ->" + cNomCampo) := cPriori
										elseif cNomCampo == "GTJ_ITEM"
											&("GTJ->" + cNomCampo) := strZero((val(cNumItem)),TamSx3("GTJ_ITEM")[1])
											cNumItem := strZero((val(cNumItem)+1),TamSx3("GTJ_ITEM")[1])
										elseif cNomCampo == "GTJ_STATUS"
											&("GTJ->" + cNomCampo) := "0" //Pendente
										elseif cNomCampo == "GTJ_CRMANT" .and. !empty(cCrmExec)
											&("GTJ->" + cNomCampo) := cCrmExec
										else
											&("GTJ->" + cNomCampo) := aCposVlr[nL,2]
										endif
									next nL
									GTJ->GTJ_ITEREP := .T.
									MsUnlock()
									if nItensRep > 1
										cMsg += "'" + allTrim(cProced) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1')+cProced,'B1_DESC')) + ")" +  chr(10) + chr(13) + ;
											STR0049 + "         : " + GTJ->GTJ_ITEM + chr(10) + chr(13) + ;
											STR0050 + ": " + GTJ->GTJ_PRIORI  + chr(10) + chr(13) //"Item" ### "Prioridade"
									endif

									//Limpa o vetor de dados
									aCposVlr := {}

								next nI
								if nItensRep > 1
									cMsg += chr(10) + chr(13) + STR0051 //"foram repetidos."
								else
									cMsg += "'" + allTrim(cProced) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1')+cProced,'B1_DESC')) + ") " + STR0048 + chr(10) + chr(13) + ;
										STR0049 + "         : " + GTJ->GTJ_ITEM + chr(10) + chr(13) + ;
										STR0050 + ": " + GTJ->GTJ_PRIORI +  chr(10) + chr(13) + chr(10) + chr(13)//STR0048 ### "Item" ### "Prioridade"
								endif

							endif
						else
							DbSelectArea("GTJ")
							GTJ->(dbGoTop())
							DbSetOrder(1)
							DbSeek(xFilial("GTJ") + cNumOrc + cCodItem )//Posiciona no registro

							//Preenche vetor com campos e valores para cada campo
							for nI:= 1 to len(aCposGtj)
								aAdd(aCposVlr,{aCposGtj[nI], &("GTJ->" + aCposGtj[nI]) } )
							next nI

						 	//Ajusta o status do procedimento para "5" (Repetido) na GTJ
							RecLock("GTJ", .F.)
							GTJ->GTJ_STATUS := "5" //aLegGTJ - "Proc Repetido" / HSPAHM57LEG()
							MsUnlock()

							//Inclui novo registro
							RecLock("GTJ", .T.)
							for nI:= 1 to len(aCposVlr)
								cNomCampo := allTrim(aCposVlr[nI,1])
								if cNomCampo == "GTJ_PRIORI"
									&("GTJ->" + cNomCampo) := strZero( nPriori + 10 ,TamSx3("GTJ_PRIORI")[1])
								elseif cNomCampo == "GTJ_ITEM"
									&("GTJ->" + cNomCampo) := strZero((val(cNumItem)),TamSx3("GTJ_ITEM")[1])
								elseif cNomCampo == "GTJ_STATUS"
									&("GTJ->" + cNomCampo) := "0" //Pendente
								elseif cNomCampo == "GTJ_CRMANT" .and. !empty(cCrmExec)
									&("GTJ->" + cNomCampo) := cCrmExec
								else
									&("GTJ->" + cNomCampo) := aCposVlr[nI,2]
								endif
							next nI
							GTJ->GTJ_ITEREP := .T.
							MsUnlock()
							cMsg := STR0044 + " '" + allTrim(cProced) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1')+cProced,'B1_DESC')) + ") " + STR0048 + chr(10) + chr(13) +chr(10) + chr(13) + ;
								STR0049 + "         : " + GTJ->GTJ_ITEM + chr(10) + chr(13) +;
								STR0050 + ": " + GTJ->GTJ_PRIORI //"O procedimento" ### "foi repetido!" ### "Item" ### "Prioridade"
						endif

						FS_REFRESH(DTOS(oCalend:dDiaAtu))
						HS_MSGINF(cMsg, STR0029, STR0030)
						FS_ATUITEM(cNumOrc, .T.)
						oGetItePln:oBrowse:Refresh()
						oGetItePln:oBrowse:SetFocus()
					else
						HS_MSGINF(STR0047,STR0029, STR0030)//"Só é possível repetir procedimentos que já foram realizados!","Atenção", "Validação Atualização Orçamento"
					endif
				endif
			endif
		endif
	fs_AtuStaGT9(GTJ->GTJ_NUMORC)
	FS_REFRESH(DTOS(oCalend:dDiaAtu))
	oGetItePln:oBrowse:Refresh()
	oGetItePln:oBrowse:SetFocus()
elseif nOpcao == 2 //Finaliza procedimento
	FS_GRVGTC(0)
	DbSelectArea("GTJ")
	DbSetOrder(1)
	//Localiza o item, atualiza seu status e executa resfresh na tela
	nLinOrc := oGetOrcPln:nAt
	If DbSeek(xFilial("GTJ") + cNumOrc + cCodItem )
		if GTJ->GTJ_STATUS $ "034" // "0" = Pendente / "4" = Em atendimento
			RecLock("GTJ", .F.)
			GTJ->GTJ_STATUS := "1"
			GTJ->GTJ_CRMEXE := cCrmLog
			MsUnlock()
			//Atualiza os status da GT9
			fs_AtuStaGT9(GTJ->GTJ_NUMORC)
			//Gera valor de repasse para o profissional
			if GetNewPar("MV_GERREPA", .F.)
				hs_gerRepAuto(GCY->GCY_REGATE, cProced, cNumOrc, cCodItem, cCrmLog, GTJ->GTJ_DENREG, GTJ->GTJ_FADENT, GTJ->GTJ_ITEREP, GTJ->GTJ_CRMANT)
			endif
			HS_MSGINF(STR0044 + " '" + allTrim(cProced) + "' (" + Alltrim(Posicione('SB1',1,xFilial('SB1')+cProced,'B1_DESC')) + ") " + STR0045, STR0029, STR0030)//"O procedimento" ### "foi finalizado!"
			FS_REFRESH(DTOS(oCalend:dDiaAtu))
			oGetItePln:oBrowse:Refresh()
			oGetItePln:oBrowse:SetFocus()
		else
			HS_MSGINF(STR0043,STR0029, STR0030)//"Não foi possível finalizar o procedimento pois o status atual não permite alteração!","Atenção", "Validação Atualização Orçamento"
		endif
	endif

	FS_REFRESH(DTOS(oCalend:dDiaAtu))
	FS_ATUITEM(cNumOrc, .T.)
	fs_AtuStaGT9(cNumOrc)


	oGetItePln:oBrowse:Refresh()
	oGetItePln:oBrowse:SetFocus()
elseif nOpcao == 3 //Exclui procedimento
	FS_CANITPL(cNumOrc,cCodItem,nOpcao)
	fs_AtuStaGT9(cNumOrc)
	oGetOrcPln:refresh()

	FS_REFRESH(DTOS(oCalend:dDiaAtu))
	FS_ATUITEM(cNumOrc, .T.)
	oGetItePln:oBrowse:Refresh()
	oGetItePln:oBrowse:SetFocus()
ElseIf nOpcao == 4 //Grava historico
	FS_GRVGTC(0)
endif

restArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada HS57PLAOK acionado após todo processamento do confirma  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("HS57PLAOK")
	ExecBlock("HS57PLAOK", .F., .F.,{cNumOrc,cProced,cCodItem,nOpcao})
EndIf

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fs_vldProExeM57  ³Autor³Saude               ³Data³12/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se no grid de procedimentos há algum procedimento ³±±
±±³          ³ em execução                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_vldProExeM57(oGetOrc,oGetItens)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function fs_vldProExeM57(oGetOrc,oGetItens)

	local nI      := 0
	local nJ      := 0
	local lRet    := .T.
	local cNumOrc := ""

	for nI := 1 to len(oGetOrc:aCols)
		cNumOrc := oGetOrc:aCols[nI, nGt9NumFat]
		FS_ATUITEM(cNumOrc, .T.)
		for nJ := 1 to len(oGetItens:aCols)
			if oGetItens:aCols[nJ, nSckStatus] == "BR_AZUL" //"Em Atendimento"
				HS_MSGINF(STR0041 + " " + cNumOrc + " " + STR0042 ,STR0029, STR0030)//"Verifique o(s) procedimento(s) em atendimento no orçamento " ### "para confirmar!" #### "Atenção", "Validação Atualização Orçamento"
				FS_REFRESH(DTOS(oCalend:dDiaAtu))
				oGetItens:oBrowse:Refresh()
				oGetItens:oBrowse:SetFocus()
				return  .F.
			endif
		next nJ
	next nI

return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³hs_gCpoSx3       ³Autor³Saude               ³Data³12/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorna os campos nao virtuais da tabela informada          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ hs_gCpoSx3(cAlias)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ cAlias - Tabela                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aCampos                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function hs_gCpoSx3(cAlias)
	local aArea    := getArea()
	local aCampos  := {}

	dbSelectArea("SX3")
	dbSetOrder(1)
	If DbSeek(cAlias)
		while SX3->X3_ARQUIVO == cAlias
			if X3_CONTEXT <> "V"
				aAdd(aCampos, SX3->X3_CAMPO)
			endif
			SX3->(dbSkip())
		end
	endif

	restArea(aArea)
return aCampos
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fs_isPacSel      ³Autor³Saude               ³Data³19/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se ha algum paciente selecionado no grid           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_isPacSel(oGetDad)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ oGetDad - Objeto NewGetDados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function fs_isPacSel(oGetDad)
	local lRet    := .F.
	local nI      := 0

	for nI := 1 to len(oGetDad:aCols)
		if oGetDad:aCols[nI, nGcyOk] == "LBTIK"
			lRet := .T.
			exit
		endif
	next nI

return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fs_isPerAtuPac   ³Autor³Saude               ³Data³19/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se o sistema deve exibir uma mensagem de confirma- ³±±
±±³          ³cao antes de atualizar o status de atendimento ao paciente. ³±±
±±³          ³Se a mensagem for exibida, soh retorna .T. caso o medico    ³±±
±±³          ³confirme a alteracao.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_isPerAtuPac(cNomePac)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ cNomePac - Nome do paciente selecionado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

static function fs_isPerAtuPac(cNomePac)
	local lPnlCli       := SuperGetMV("MV_PNLCLI", NIL, .F.)
	local lRet          := .T.

	if lPnlCli
		if nColPosGcy == nGcyOk
			if oGetPac:aCols[oGetPac:nAt, nGcyOk] <> "LBTIK" .AND. !(msgYesNo(STR0040 + " " + Alltrim(cNomePac) + "?")) //"Confirma chamada ao paciente"
				lRet := .F.
			endif
		elseIf nColPosGcy == nHspStareg
			if oGetPac:aCols[oGetPac:nAt, nHspStareg] == "BR_CINZA"
				if !(msgYesNo(STR0103 + Alltrim(cNomePac) + "?")) //"Confirma chamada ao paciente "
					lRet := .F.
				endif
			elseIf oGetPac:aCols[oGetPac:nAt, nHspStareg] == "BR_VERMELHO" .AND. !(MsgYesNo(STR0039 + " " + Alltrim(cNomePac) + "?"))//"Confirma atendimento ao paciente"
				lRet := .F.
			endif
		endif
	endif

	if !lRet
	//Libera o registro anterior
		FS_UByName(cChaveAtu)
	else
		if cChaveAtu <> cChaveLock
			FS_UByName(cChaveLock)
			cChaveLock := cChaveAtu
		endif
	endif

return lRet


//-----------------------------------------------
Static Function FS_LByName(cChave)
	Local lRet  := .F.

	lRet := LockByName(cChave, .T., .T., .F.)

Return(lRet)


Static Function FS_UByName(cChave)

	UnLockByName(cChave, .T., .T., .F.)

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fs_AtuStaGT9     ³Autor³Saude               ³Data³20/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Atualiza o status da GT9 conforme procedimentos finalizados ³±±
±±³          ³na GTJ                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_AtuStaGT9(cNumOrc)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ cNumOrc - Numero do orcamento                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function fs_AtuStaGT9(cNumOrc)
	local aArea      := getArea()
	local lFinal     := .T.
	local lExec      := .F.
	local lProcFin   := .F.
	local cStatusGT9 := ""
	local nPend      := 0
	local nExec      := 0
//GTJ
//0=Pendente;1=Realizado;2=Cancelado;3=Agendado;4=Em atendimento;5=Proc.Repetido

	dbSelectArea("GTJ")
	dbGoTop()
	dbSetOrder(1)
	If DbSeek( xFilial("GTJ") + cNumOrc)
		while GTJ->GTJ_NUMORC == cNumOrc
			if GTJ->GTJ_STATUS $ "1"
				lProcFin := .T.
				nExec++
				if nPend > 0
					lExec  := .T.
				endif
			elseIf GTJ->GTJ_STATUS $ "034"
				lFinal := .F.
				nPend++
				if  lProcFin
					lExec  := .T.
				endif
			endif
			GTJ->(dbSkip())
		end
	endif
	GTJ->(DbCloseArea())

	if lFinal
		cStatusGT9 := "6"
		lFinal := .T.
	elseif lExec
		cStatusGT9 := "5"
		lFinal := .F.
	else
		cStatusGT9 := "3"
		lFinal := .F.
	endif

//GT9
//0=Orc. Pendente;1=Pend. Financ.;2=Aprovado;3=Liberado;4=Cancelado;5=Em tratamento;6=Finalizado

//Atualiza status na GT9
	dbSelectArea("GT9")
	dbSetOrder(1)
	If DbSeek(xFilial("GT9") + cNumOrc)
		RecLock("GT9", .F.)
	//Verifica se ha somente procedimentos cancelados/repetidos
		if fs_verOrcCan(cNumOrc)
			GT9->GT9_STATUS := "4"
			lFinal := .F.
	//Verifica se ha somente procedimentos repetidos e pendentes - Esta em execucao
		elseif fs_veOrAtRep(cNumOrc)
			GT9->GT9_STATUS := "5"
			lFinal := .F.
		else
			GT9->GT9_STATUS := cStatusGT9
		endif
		MsUnlock()
	endif
	GT9->(DbCloseArea())

	if funName() == "HSPAHM57"
		FS_REFRESH(DTOS(oCalend:dDiaAtu))
	endif
	restArea(aArea)
return lFinal


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |fs_verOrcCan     ³Autor³Saude               ³Data³31/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se todos itens do orcamento estao cancelados       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_verOrcCan(cNumOrc)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ cNumOrc - Numero do orcamento                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function fs_verOrcCan(cNumOrc)
	local aArea      := getArea()
	local lFinal     := .T.

	dbSelectArea("GTJ")
	dbGoTop()
	dbSetOrder(1)
	If DbSeek( xFilial("GTJ") + cNumOrc)
		while GTJ->GTJ_NUMORC == cNumOrc
		//0=Pendente;1=Realizado;2=Cancelado;3=Agendado;4=Em atendimento;5=Proc.Repetido
			if !(GTJ->GTJ_STATUS $ "25")
				return .F.
			endif
			GTJ->(dbSkip())
		end
	endif

	GTJ->(DbCloseArea())

	restArea(aArea)
return lFinal

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |fs_veOrAtRep     ³Autor³Saude               ³Data³31/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se o orcamento possui somente procedimentos        ³±±
±±³          ³repetidos e pendentes (Esta em execucao)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fs_veOrAtRep(cNumOrc)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ cNumOrc - Numero do orcamento                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function fs_veOrAtRep(cNumOrc)
	local aArea      := getArea()
	local lAtend     := .T.
	local lExec      := .F.

	dbSelectArea("GTJ")
	dbGoTop()
	dbSetOrder(1)
	If DbSeek( xFilial("GTJ") + cNumOrc)
		while GTJ->GTJ_NUMORC == cNumOrc
		//0=Pendente;1=Realizado;2=Cancelado;3=Agendado;4=Em atendimento;5=Proc.Repetido
			if !(GTJ->GTJ_STATUS $ "0235")
				return .F.
			else
				if GTJ->GTJ_STATUS $ "5"
					lExec := .T.
				endif
			endif
			GTJ->(dbSkip())
		end
	endif

	GTJ->(DbCloseArea())

	restArea(aArea)
return iIf(lExec, lAtend, .F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |hs_pacTrat       ³Autor³Saude               ³Data³06/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se o paciente possui algum orcamento liberado e/ou ³±±
±±³          ³em execucao                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ hs_pacTrat(cCodPac)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Argumentos³ cCodPac - Codigo do paciente                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function hs_pacTrat(cCodPac)
	local aArea := getArea()
	local lret  := .F.
	local cSql  := ""

	cSql := " SELECT COUNT(*) AS QTDE FROM " + retSqlName("GT9")
	cSql += " WHERE GT9_FILIAL = '" + xFilial("GT9") + "'"
	cSql += " AND GT9_REGGER = '" + cCodPac  + "'"
	cSql += " AND GT9_STATUS IN ('3','5')" //liberado / em execucao
	cSql += " AND D_E_L_E_T_ <> '*'"
	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYQTD"

	If !QRYQTD->(Eof())
		lRet := QRYQTD->QTDE > 0
	endif

	QRYQTD->(DbCloseArea())

	restArea(aArea)
return lret


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_gChangeGTº Autor ³ Saude            º Data ³  15/12/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza automaticamente o conteudo da(s) coluna(s) da     º±±
±±º          ³ nova linha criada para incluir valor do campo _ITEM        º±±
±±º          ³ com incremento de 1 para evitar duplicidade na chaveunica  º±±
±±º          ³ nas tabelas GTH e GTO                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function fs_gChangeGT(cAliasHis, oGetHis, cNumFat, nItem)
	local aArea     := getArea()
	local nUltItem  := 0
	local cUltItem  := ""
	local nI        := 0
	local nIx        := 0

	if (Empty(oGetHis:aCols[oGetHis:oBrowse:nAt, nItem]) )

	//Varre o aCols para verificar o maior valor de item ja existente
		for nI := 1 to len(oGetHis:aCols)
			if val(oGetHis:aCols[nI, nItem]) > nUltItem
			//Define o valor com base no aCols
				nUltItem := val(oGetHis:aCols[nI, nItem])
			endif
			If nI + 1 == len(oGetHis:aCols)
				For nIx := 1 to Len(oGetHis:aCols[nI]) - 1
					If !OGETHIS:AHEADER[nIx,2] == (cAliasHis + "_HISATE")
						OGETHIS:ACOLS[nI + 1 ,nIx]:= IIf(OGETHIS:AHEADER[nIx,2] == (cAliasHis + "_DATHIS"),dDataBase,OGETHIS:ACOLS[nI ,nIx])					
					EndIf
				Next
			Endif
		next nI

	//Verificando ultimo item para o orcamento na tabela de historico utilizada (GTC ou GTO)
		nUltItem := fs_ultItemGT(cAliasHis, cNumFat, nUltItem)

	else

		restArea(aArea)
		return
	endif

	cUltItem := strZero(nUltItem + 1, TamSx3(cAliasHis + "_ITEM")[1])
	oGetHis:aCols[oGetHis:oBrowse:nAt, nItem]:= cUltItem

	oGetHis:Refresh()

	restArea(aArea)
return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_ultItemGTº Autor ³ Saude            º Data ³  15/12/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica ultimo item na tabela de historico do prontuario  º±±
±±º          ³ GTC/GTO                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

static function fs_ultItemGT(cAlias, cNumFat, nUltItem)
	local aArea      := getArea()
	local nItemAtu   := 0
	Default nUltItem := 0

	dbSelectArea(cAliasHis)
	dbSetOrder(1)
	if dbSeek(xFilial(cAlias) + cNumFat)
		while &(cAlias + "_NUMFAT") == cNumFat
			nItemAtu := Val(&(cAlias + "->" + cAliasHis + "_ITEM"))
			if nItemAtu > nUltItem
				nUltItem := nItemAtu
			endif
			&(cAlias)->(dbSkip())
		end
	endif

	&(cAlias)->(dbCloseArea())
	restArea(aArea)

return nUltItem



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± ±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_PREORC  ³ Autor ³ Saude     			³ Data ³ 25/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pre Orçamento para validação no PLS (Rede Propria)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP  		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_PREORC(cAliasIte, aCols)
	Local nI 		:= 0
	Local nP		:= 0
	Local nC		:= 0
	Local cProcPai  := ""
	Local cPct		:= ""
	Local aItens	:= {}
	Local aItePct	:= {}
	Local aIteCri	:= {}
	Local aCriAux	:= {}
	Local cOrcRet	:= ""
	Local cDenReg   	:= ""
	Local cFaDent   	:= ""
	Local 	lGa2Sessao 	:= .T.	//Hs_ExisDic({{"C","GA2_SESSAO"}},.F.)


	If cRedPro <> "1"
		HS_MsgInf(STR0127, STR0029, STR0035)  //"O convênio não esta parametrizado como Rede Propria!" ### "Atenção", "Validação Prontuário Clinicas"
		Return()
	EndIf

	If !(oFolder:lActive .AND. oFolder:nOption == 4)
		MsgStop(STR0085) //"Opção disponivel somente no Exame Clinico!"
		Return()
	ElseIf Len(oGetMPI:aCols) == 1 .AND. Empty(oGetMPI:aCols[1,nMPICodPro])
		MsgStop(STR0084) //"Informe os itens a serem inseridos no orçamento!"
		Return()
	EndIf

	If !MsgYesno(STR0128, STR0029) //"Confirma a geração do orçamento?" ### "Atenção"
		Return()
	EndIf

	For nI := 1 To Len(oGetMPI:aCols)
		aCriAux := {}
		If ValType("nMPIDenReg") # "U" .AND. ValType("nMPIFadent") # "U"
			cDenReg   := oGetMPI:aCols[nI,nMPIDenReg]
			cFaDent   := oGetMPI:aCols[nI,nMPIFaDent]
		EndIf
		If Empty(oGetMPI:aCols[nI,nMPIOrcGer]) .AND. !oGetMPI:aCols[nI, Len(oGetMPI:aHeader)+1]
			DbSelectArea("GA7")
			DbSetOrder(1)
			DbSeek(xFilial("GA7") + oGetMPI:aCols[nI,nMPICodPro])

			If Empty(GA7->GA7_TABPLS) .OR. Empty(GA7->GA7_PROPLS)
				HS_MsgInf(STR0129 +  oGetMPI:aCols[nI,nMPICodPro] + STR0130, STR0029, STR0035)  //"O procedimento [" ### "] não possui vinculo com a tabela e procedimento no PLS!" ### "O convênio não esta parametrizado como Rede Propria!" ### "Atenção", "Validação Prontuário Clinicas"
				Return()
			EndIf

			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1") + oGetMPI:aCols[nI,nMPICodPro]) .AND. GA7->GA7_VINSB1 = "1"

				If HS_VPROPLS(cRGerSel, cPlaAte, cCrmLog, oGetMPI:aCols[nI,nMPICodPro], dDataBase, .F.,@aCriAux,.F.)
				//Localiza pacote
					DbSelectArea("GA1")
					DbSetOrder(3)
					If DbSeek(xFilial("GA1") + PADR(SB1->B1_COD,TamSx3("GA1_CODPRO")[1]) )
						cPct     := GA1->GA1_CODPCT
						cProcPai := ""
					Else
					//Se nao ha pacote, grava o codigo do produto (+ NRO PRA DIFERENCIACAO)
					//cPct     := PADR(SB1->B1_COD,TamSx3("GA1_CODPRO")[1])+ cValToChar(nPac)
						cPct     := ""
					//nPac++
					Endif

					aItePct := HS_RetPct(oGetMPI:aCols[nI,nMPICodPro], 3) // Inclui itens do Pacote/Procedimento Padrão
					If Len(aItePct) > 0
						AADD(aItens ,{oGetMPI:aCols[nI,nMPICodPro], SB1->B1_PRV1, SB1->B1_PRV1, SB1->B1_UM, SB1->B1_DESC,SB1->B1_PRV1,0,0,1,""/* Codigo do Item gerado no orçamento */, oGetMPI:aCols[nI,nMPIItem],cPct,oGetMPI:aCols[nI,nMPICodPro],cDenReg, cFaDent, "" ,.T., "" })
						For nP := 1 to Len(aItePct)
							DbSelectArea("SB1")
							DbGoTop()
							DbSetOrder(1)
							If DbSeek(xFilial("SB1") + PadR(AllTrim(aItePct[nP,2]), Len(SB1->B1_COD)))
								AADD(aItens ,{aItePct[nP,2], SB1->B1_PRV1, SB1->B1_PRV1, SB1->B1_UM, SB1->B1_DESC,SB1->B1_PRV1,0,0,1,""/* Codigo do Item gerado no orçamento */, oGetMPI:aCols[nI,nMPIItem],aItePct[nP,9]/*Pacote*/,aItePct[nP,10]/*Proced pai*/,cDenReg, cFaDent,iIf(lGa2Sessao,aItePct[nP,11],"")/*GA2_SESSAO*/,.F., "" })
							EndIf
						Next nP
				//
					Else
						AADD(aItens ,{oGetMPI:aCols[nI,nMPICodPro], GA8->GA8_VLRPRO, GA8->GA8_VLRPRO, SB1->B1_UM, SB1->B1_DESC,GA8->GA8_VLRPRO,0,0,1,""/* Codigo do Item gerado no orçamento */, oGetMPI:aCols[nI,nMPIItem],cPct,"",cDenReg, cFaDent, "" ,.T., ""})
					EndIf
				Else
					If Len(aCriAux) > 0
					//"GTP_NUMORC""GTP_PRODUT""GTP_CODGLO""GTP_DESGLO""GTP_DATGLO""GTP_HORGLO"
						For nC := 1 To Len(aCriAux)
							If !Empty(aCriAux[nC,1])
								AADD(aIteCri ,{"", oGetMPI:aCols[nI,nMPICodPro], aCriAux[nC,1], aCriAux[nC, 2], cDenReg, cFaDent})
							EndIf
						Next nC
					EndIf
				EndIf
			EndIf
		EndIf
	Next nI

	If Len(aItens) > 0
		cOrcRet := FS_GERORC(cAliasIte, aItens)
	EndIf
	If Len(aIteCri) > 0
		HS_M57GRVCRI(cAtPac, aIteCri)
		HS_MsgInf(STR0131, STR0029, STR0035)  //"Existem procedimentos que foram criticados, verifique as pendencias na aba orçamento!" ### "O convênio não esta parametrizado como Rede Propria!" ### "Atenção", "Validação Prontuário Clinicas"
	EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± ±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HS_M57GRVCRI³ Autor ³ Saude     			³ Data ³ 27/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava criticas dos procedimentos validados no orçamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP  		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M57GRVCRI(cRgAten, aItens)
	Local aArea := getArea()
	Local nI	:= 0
	Local cItem	:= StrZero(0, Len(GTC->GTC_ITEM))
	Local cSql	:= ""

	DbSelectArea("GTP")
	DbSetOrder(2)
	If DbSeek(xFilial("GTP") + cRgAten)  //Soma mais um ao item
		cSql := "SELECT MAX(GTP.GTP_ITEM) MAXNUM FROM " + RetSqlName("GTP") + " GTP"
		cSQL += " WHERE"
		cSQL += " GTP.GTP_FILIAL = '" + xFilial("GTP") + "' AND GTP.D_E_L_E_T_ <> '*' "
		cSQL += " AND GTP.GTP_REGATE = '" + cRgAten + "' "

		cSQL :=  ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "QRYGTP"

		cItem := QRYGTP->MAXNUM

		DbSelectArea("QRYGTP")
		DbCloseArea()
	EndIf

	For nI := 1 to Len(aItens)
		cItem := Soma1(cItem)
		RecLock("GTP", .T.)
		GTP->GTP_FILIAL	:= xFilial("GTP")
		GTP->GTP_NUMORC := SPACE(TamSx3("GTP_NUMORC")[1])
		GTP->GTP_REGATE	:= cRgAten
		GTP->GTP_PRODUT	:= aItens[nI, 2]
		GTP->GTP_STATUS := '0'
		GTP->GTP_CODGLO := aItens[nI, 3]
		GTP->GTP_DESGLO := aItens[nI, 4]
		GTP->GTP_DATGLO := dDatabase
		GTP->GTP_HORGLO := Time()
		GTP->GTP_ITEM 	:= StrZero(Val(cItem), Len(GTP->GTP_ITEM))
		If cTipOdtGr == "1"
			GTP->GTP_DENREG := aItens[nI, 5]
			GTP->GTP_FADENT := aItens[nI, 6]
		EndIf
		MsUnlock()
	Next nI

	RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATUPEN  ºAutor  ³ Saude             º Data ³  01/11/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza historico do atendimento do plano de tratameto     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATUPEN(cRegAte, cNumOrc)
	Local aArea   	:= GetArea()

	Default cNumOrc := ""

	aColsGTP := {}
	HS_BDados("GTP", @aHeadGTP, @aColsGTP,, 1,, " GTP_REGATE = '" + cAtPac + "' AND GTP_FILIAL= '" + xFilial("GTP") + "' AND D_E_L_E_T_ <> '*' " ,,"GTP_STATUS","/",,,,"GTP_IDMARC","'LBNO'",.T.,aLegGTP,,,,, aCpoGTP,,,"GTP_ITEM")
//HS_BDados("GTE", @aHGTE, @aCGTE,, 1,, cCond,,,,,,, "GTE_IDMARK", "'LBNO'")

	If Len(aColsGTP) == 1 .AND. Empty(aColsGTP[1,nGtpProdut])
		aColsGTP[1,nGTPDESPRO] := Space(TamSx3("GTP_DESPRO")[1])
	EndIf

	oGetOrcPen:setArray(aColsGTP)
	oGetOrcPen:oBrowse:Refresh()

	If Len(aColsGTP) > 0
		oFolPend:aDialogs[2]:Enable() //Desabilita Folder para utilização do Duplo Clique
	Else
		oFolPend:aDialogs[2]:Disable() //Desabilita Folder para utilização do Duplo Clique
	EndIf
	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DblClik ºAutor  ³Saude          z    º Data ³ 20/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para marcar e desmarcar o item.                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DbCkGTP()
	If oGetOrcPen:oBrowse:nColPos == nGTPSTATUS
		FS_M57LEGGTP()
	Else
		If oGetOrcPen:aCols[oGetOrcPen:oBrowse:nAt, nGTPSTATUS] == "BR_VERMELHO"
			oGetOrcPen:aCols[oGetOrcPen:oBrowse:nAt, nGTPIDMARC] := IIf(oGetOrcPen:aCols[oGetOrcPen:oBrowse:nAt, nGTPIDMARC] == "LBTIK", "LBNO", "LBTIK")
			oGetOrcPen:oBrowse:Refresh()
		EndIf
	EndIf
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GERPEND ºAutor  ³Saude          z    º Data ³ 10/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para marcar e desmarcar o item.                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GERPEND()
	Local aArea		:= getArea()
	Local lEntrou	:= .F.
	Local aItens	:= {}
	Local nP, nI	:= 0
	Local aItePct 	:= {}
	Local cDenReg	:= ""
	Local cFaDent	:= ""
	Local lGa2Sessao:= .T.	//Hs_ExisDic({{"C","GA2_SESSAO"}},.F.)
	Local nPrcPart	:= 0
	Local cTabCob	:= ""
	Local nPosMPI	:= 0
	Local aTabTemp:= {}
	Local aTabPrec:= {}
	Local aPrecPro:= {}
	Local nPosTab := 0

	If oFolPend:lActive .AND. oFolPend:nOption == 2
	//Verificando tabelas de cobranca secundaria do convenio
		DbSelectArea("GC6")
		DbSetOrder(1)
		If dbSeek(xFilial("GC6") + GA9->GA9_CODCON)
			while GC6->GC6_CODCON == GA9->GA9_CODCON
				nPosTab := aScan(aTabTemp, {|aVet| aVet[2] == GC6->GC6_TABPRO})
				if nPosTab == 0
					aAdd(aTabTemp, {GC6->GC6_CODCON, GC6->GC6_TABPRO, GC6->GC6_DATVIG, GC6->GC6_TABAUX, GC6->GC6_PRIORI})
				else
					if GC6->GC6_DATVIG > aTabTemp[nPosTab][3] //Se é mais atual, substitui
						aTabTemp[nPosTab] := {GC6->GC6_CODCON, GC6->GC6_TABPRO, GC6->GC6_DATVIG, GC6->GC6_TABAUX, GC6->GC6_PRIORI}
					endif
				endif
				GC6->(dbSkip())
			enddo
		endif
		if len(aTabTemp) > 0
			aSort(aTabTemp,,,{|x,y| x[5] < y[5]})
			for nI := 1 to len(aTabTemp)
				if !empty(aTabTemp[nI,4])
					if aScan(aTabPrec, {|aVet| aVet == aTabTemp[nI,4]}) == 0
						aAdd(aTabPrec, aTabTemp[nI,4])
					endif
				endif
			next nI
			if len(aTabPrec) > 0
				cTabCob := aTabPrec[1]
			endif
		endif

	//Verificando tabela via parametro
		if empty(cTabCob)
			cTabCob := FS_GETTAB()
			If Empty(cTabCob)
			//HS_MsgInf("Tabela " + " (" + cTabCob + ") " + " não encontrada!",STR0029, STR0035) //"Tabela " ### "não encontrada!" ### "Atenção", "Validação Prontuário Clinicas"
				Return()
			EndIf
		endif

		DbSelectArea("GDB")
		DbSetOrder(1)
		If !(dbSeek(xFilial("GDB")+cTabCob))
			HS_MsgInf(STR0120 + " (" + cTabCob + ") " + STR0121,STR0029, STR0035) //"Tabela " ### "não encontrada!" ### "Atenção", "Validação Prontuário Clinicas"
			Return()
		Endif

		For nI := 1 to Len(oGetOrcPen:aCols)
			If oGetOrcPen:aCols[nI, nGTPSTATUS] == "BR_VERMELHO" .AND. oGetOrcPen:aCols[nI, nGTPIDMARC] == "LBTIK"
				lEntrou := .T.
				If ValType("nGTPDenReg") # "U" .AND. ValType("nGTPFaDent") # "U"
					cDenReg   := oGetOrcPen:aCols[nI,nGTPDenReg]
					cFaDent   := oGetOrcPen:aCols[nI,nGTPFaDent]
				EndIf
				If !oGetOrcPen:aCols[nI, Len(oGetOrcPen:aHeader)+1]
					DbSelectArea("GA7")
					DbSetOrder(1)
					DbSeek(xFilial("GA7") + oGetOrcPen:aCols[nI,nGtpProdut])

					If Empty(GA7->GA7_TABPLS) .OR. Empty(GA7->GA7_PROPLS)
						HS_MsgInf(STR0116 + " [" +  oGetOrcPen:aCols[nI,nGtpProdut] + "] " + STR0119, STR0029, STR0035)  //"O procedimento", "não possui vinculo com a tabela e procedimento no PLS!" ### "Atenção" ### "Validação Prontuário Clinicas"
						Return()
					EndIf

					DbSelectArea("SB1")
					DbSetOrder(1)
					If DbSeek(xFilial("SB1") + oGetOrcPen:aCols[nI,nGtpProdut]) .AND. GA7->GA7_VINSB1 = "1"
					//Localiza pacote
					//nPrcPart := FS_RETPRC(oGetOrcPen:aCols[nI,nGtpProdut], cPlaAte, dDataBase, cTabCob, aTabPrec)
						aPrecPro := FS_RETPRC(oGetOrcPen:aCols[nI,nGtpProdut], cPlaAte, dDataBase, cTabCob, aTabPrec)
						if aPrecPro[1]
							nPrcPart := aPrecPro[2]
						else
							nPrcPart := aPrecPro[2]
						//HS_MsgInf(STR0116 + " [" +  alltrim(oGetOrcPen:aCols[nI,nGtpProdut]) + " - " + ALLTRIM(Posicione('GA7',1,xFilial('GA7') + Padr(alltrim(oGetOrcPen:aCols[nI,nGtpProdut]), TamSx3("GA7_CODPRO")[1]) , 'GA7_DESC  ')) + ; //"O procedimento"
							//"] " + STR0117 + " (" + cTabCob + " - " + ALLTRIM(Posicione('GDB',1,xFilial('GDB') + cTabCob, 'GDB_DESCRI')) + ")." + CHR(10) + CHR(13) + CHR(10) + CHR(13) +; //"não possui vinculo com a tabela de procedimentos definida"
							//STR0118, STR0029, STR0035)  // ### "O orçamento não foi gerado", "Validação Prontuário Clinicas"
					    //Return()
						endif

						DbSelectArea("GA1")
						DbSetOrder(3)
						If DbSeek(xFilial("GA1") + PADR(SB1->B1_COD,TamSx3("GA1_CODPRO")[1]) )
							cPct     := GA1->GA1_CODPCT
							cProcPai := ""
						Else
							cPct     := ""
						Endif

						aItePct := HS_RetPct(oGetOrcPen:aCols[nI,nGtpProdut], 3) // Inclui itens do Pacote/Procedimento Padrão
						If Len(aItePct) > 0
							AADD(aItens ,{oGetOrcPen:aCols[nI,nGtpProdut], nPrcPart, nPrcPart, SB1->B1_UM, SB1->B1_DESC,nPrcPart,0,0,1,""/* Codigo do Item gerado no orçamento */, ""/*oGetMPI:aCols[nI,nMPIItem]*/,cPct,oGetOrcPen:aCols[nI,nGtpProdut],cDenReg, cFaDent, "" ,.T., "" })
							For nP := 1 to Len(aItePct)
								DbSelectArea("SB1")
								DbGoTop()
								DbSetOrder(1)
								If DbSeek(xFilial("SB1") + PadR(AllTrim(aItePct[nP,2]), Len(SB1->B1_COD)))
									AADD(aItens ,{aItePct[nP,2], nPrcPart, nPrcPart, SB1->B1_UM, SB1->B1_DESC,nPrcPart,0,0,1,""/* Codigo do Item gerado no orçamento */, ""/*oGetMPI:aCols[nI,nMPIItem]*/,aItePct[nP,9]/*Pacote*/,aItePct[nP,10]/*Proced pai*/,cDenReg, cFaDent,iIf(lGa2Sessao,aItePct[nP,11],"")/*GA2_SESSAO*/,.F., "" })
								EndIf
							Next nP
						Else
							AADD(aItens ,{oGetOrcPen:aCols[nI,nGtpProdut], nPrcPart, nPrcPart, SB1->B1_UM, SB1->B1_DESC,nPrcPart,0,0,1,""/* Codigo do Item gerado no orçamento */, ""/*oGetMPI:aCols[nI,nMPIItem]*/,cPct,"",cDenReg, cFaDent, "" ,.T., ""})
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI
		If !lEntrou
			HS_MsgInf(STR0122, STR0029, STR0035)  //"Selecione o(s) procedimento(s)!" ### "Atenção", "Validação Prontuário Clinicas"
			Return()
		EndIf
		If Len(aItens) > 0
			cOrcRet := FS_GERORC(cAliasMPI, aItens, "1",.F., cTabCob)
		EndIf
		If !Empty(cOrcRet)
			For nI := 1 to Len(oGetOrcPen:aCols)
				If oGetOrcPen:aCols[nI, nGTPSTATUS] == "BR_VERMELHO" .AND. oGetOrcPen:aCols[nI, nGTPIDMARC] == "LBTIK"
					oGetOrcPen:aCols[nI, nGtpNumOrc] 	:= cOrcRet
					oGetOrcPen:aCols[nI, nGTPSTATUS] 	:= "BR_VERDE"
					oGetOrcPen:aCols[nI, nGTPIDMARC]	:= "LBNO"
					DbSelectArea("GTP")
					DbSetOrder(3)
					If DbSeek(xFilial("GTP") + cAtPac + oGetOrcPen:aCols[nI, nGTPItem])
						RecLock("GTP", .F.)
						GTP->GTP_NUMORC := cOrcRet
						GTP->GTP_STATUS	:= "1"
						MsUnlock()
					EndIf
					If ValType("nMPIDenReg") # "U" .AND. ValType("nMPIFadent") # "U"
						If (nPosMPI := aScan(oGetMPI:aCols, {|aVet| Empty(aVet[nMPIOrcGer]) .AND. aVet[nMPICodPro] == oGetOrcPen:aCols[nI, nGtpProdut] .AND. aVet[nMPIDenReg] == oGetOrcPen:aCols[nI, nGtpDenReg] .AND. aVet[nMPIFaDent] == oGetOrcPen:aCols[nI, nGtpFaDent] })) > 0
							oGetMPI:aCols[nPosMPI, nMPIOrcGer] := cOrcRet
						EndIf
					Else
						If (nPosMPI := aScan(oGetMPI:aCols, {|aVet| Empty(aVet[nMPIOrcGer]) .AND. aVet[nMPICodPro] == oGetOrcPen:aCols[nI, nGtpProdut] })) > 0
							oGetMPI:aCols[nPosMPI, nMPIOrcGer] := cOrcRet
						EndIf
					EndIf
				EndIf
			Next nI
			oGetMPI:oBrowse:Refresh()
		EndIf
		If funName() == "HSPAHM57"
			FS_REFRESH(DTOS(oCalend:dDiaAtu))
		endif
	Else
		HS_MsgInf(STR0123, STR0029, STR0035)  //"É necessário selecionar a pasta Pendencias para gerar o orçamento!" ### "Atenção", "Validação Prontuário Clinicas"
		Return()
	EndIf
	RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_RETPRC ºAutor  ³Saude		            º Data ³  26/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o preco do procedimento da tabela de precos		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RETPRC(cCodPro, cCodPla, dDatVig, cCodTab, aTabPrec)

	Local aArea		:= GetArea()
	Local aRVldVig 	:= {{0, "GA8_VLRPRO"}}
	Local nPreco	:= 0
	Local cCodCon	:= HS_IniPadr("GCM", 2, cCodPla, "GCM_CODCON",, .F.)
	Local nI       := 0
	Local lFound  := .F.

	Default cCodTab	:= ""
	Default aTabPrec  := {}

	If Empty(cCodTab)
		cCodTab := HS_RTabPre("GC6", cCodPla, cCodPro, dDatVig)[1]
		DbSelectArea("GC6")
		DbSetOrder(1)
		If DbSeek(xFilial("GC6") + cCodCon + cCodPla + cCodTab)
			If Empty(GC6->GC6_PRIORI)
			//Return(0)
				return {.F., 0}
			Else
				cCodTab := GC6->GC6_TABPRO
			EndIf
		ElseIf Empty(GC6->GC6_TABAUX)
			cCodTab := GC6->GC6_TABAUX
		//Return(0)
			return {.F., 0}
		EndIf
	EndIf

	if len(aTabPrec) > 0
		for nI := 1 to len(aTabPrec)
			DbSelectArea("GA8")
			DbSetOrder(1)
			if DbSeek(xFilial("GA8") +  Padr(ALLTRIM(cCodPro), TamSx3("GA8_CODPRO")[1]) + Padr(aTabPrec[nI], TamSx3("GA8_TABPRO")[1]))
				cCodTab := Padr(aTabPrec[nI], TamSx3("GA8_TABPRO")[1])
				lFound := .T.
				exit
			endif
		next nI
	else
		DbSelectArea("GA8")
		DbSetOrder(1)
		if DbSeek(xFilial("GA8") +  Padr(ALLTRIM(cCodPro), TamSx3("GA8_CODPRO")[1]) + Padr(cCodTab, TamSx3("GA8_TABPRO")[1]))
			cCodTab := Padr(cCodTab, TamSx3("GA8_TABPRO")[1])
			lFound := .T.
		endif
	endif
	HS_VldVig("GA8", "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_TABPRO = '" + Padr(cCodTab, TamSx3("GA8_TABPRO")[1]) + "' AND GA8_CODPRO = '" + cCodPro + "'", "GA8_DATVIG", @aRVldVig, dDataBase)
	nPreco := aRVldVig[1,1]
	RestArea(aArea)

Return {lFound, nPreco}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GETTAB ºAutor  ³Saude		            º Data ³  26/12/11º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna  a tabela de precos		  						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GETTAB()

	Local aArea		:= GetArea()
	Local cTabRet	:= ""

	If At("/", cMVTabOrc) > 0 .OR. At("\", cMVTabOrc) > 0
		cGDBCodTab := cMVTabOrc
		cTabRet	:= HS_TabOrc()
		If !Fs_vldTab(cTabRet)
		//HS_MsgInf("Tabela não encontrada!",STR0029, STR0035) //"Tabela " ### "não encontrada!" ### "Atenção", "Validação Prontuário Clinicas"
			cTabRet := ""//cTabRet	:= HS_TabOrc()
		EndIf
	Else
		cGDBCodTab := ""
		cTabRet	:= cMVTabOrc
	EndIf
	RestArea(aArea)

Return(cTabRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_TabOrc º Autor ³Saude               º Data ³  27/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chama Tela Para Escolha da tabela                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_TabOrc()

	Local cCodTab 	:= Space(TamSx3("GDB_CHAVE")[1])
	Local oCodTab,oTab
	Local cDesTab	:=Space(TamSx3("GDB_DESCRI")[1])
	Local oDlgTab
	Local nOpcTab	:= 0

	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObjs := MsObjSize( aInfo, aObjects, .T. )
	DEFINE MSDIALOG oDlgTab TITLE STR0132 From 120, 000 To 244 , 550 Of oMainWnd Pixel   //"Tabela"
	@ 010, 010 Say STR0133 Of oDlgTab Pixel COLOR CLR_BLUE // "Cod. Tabela"
	@ 010, 070 MSGet oCodTab Var cCodTab F3 "GDB   " Valid  Fs_vldTab(cCodTab) Picture "@!" Size 50, 010 Of oDlgTab Pixel Color CLR_BLACK
	@ 030, 010 Say STR0134  Of oDlgTab Pixel COLOR CLR_BLUE    // "Descrição "
	@ 030, 070 MsGet oTab VAR cDesTab:= HS_IniPadr("GDB", 1, cCodTab, "GDB_DESCRI",, .F.) READONLY Size 140, 009 OF oDlgTab Pixel COLOR CLR_BLACK
	oBtnOk := tButton():New(@ 45, 115, STR0135, oDlgTab, {|| nOpcTab := 1, oDlgTab:End()}, 050, 012,,,, .T.)    //"Confirma"
	ACTIVATE MSDIALOG oDlgTab CENTERED
	If nOpcTab == 0
		cCodTab := ""
	EndIf

Return(cCodTab)

//Valid do campo Codigo da Tabela
Static Function Fs_vldTab(cCodTab)

	local aArea := getArea()
	local lRet := .T.

	dbSelectArea("GDB")
	dbSetOrder(1)
	if !(dbSeek(xFilial("GDB")+cCodTab)) .OR. !(Alltrim(cCodTab) $ cMVTabOrc)
		HS_MsgInf(STR0132 + " (" + cCodTab + ") " + STR0136,STR0029, STR0035) //"Tabela " ### "não encontrada!" ### "Atenção", "Validação Prontuário Clinicas"
		lRet := .F.
	endif
	restArea(aArea)

return lRet

//Legenda GTP pendecias/criticas orçamento
Function FS_M57LEGGTP()

	Local aLegenda := {}
	Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0137)}) //"Pendente"
	Aadd(aLegenda,{"BR_VERDE"   ,OemToAnsi(STR0138)}) //"Gerado"
	BrwLegenda(cCadastro,STR0066,aLegenda) //"Legenda"

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_StFolder³ Autor ³ Saude     	 	     ³ Data ³17/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita e desabilita os folders de acordo com config       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        		           |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_StFolder(lHabilita)

	If lHabilita
		oFolder:Enable()
		IF lOdonto
			oFolder:aDialogs[2]:Enable()
			oFolder:aDialogs[3]:Enable()
		ENDIF
		oFolGetsImg:Enable()
		lTelaOK	:= .T.
	Else
		If lExCliSAt
			oFolGetsImg:Disable()
			IF lOdonto
				oFolder:aDialogs[2]:Disable()
				oFolder:aDialogs[3]:Disable()
			ENDIF
			If !aCodUsr[1]
				oFolder:nOption := 4
			EndIf
		Else
			oFolder:Disable()
		EndIf
		lTelaOK	:= .F.
	EndIf

Return()

//-------------------------------------------
Static Function FS_EMemo(cLabel,cCodAge)

	Local aArea	:= GetArea()
	Local oDlgM
	Local cTexto := ""

	If Empty(cCodAge)
		Return()
	EndIf
	cLabel := IIf(cLabel == Nil,"", cLabel)
	DbSelectArea("GM8")
	DbSetOrder(1)
	If DbSeek(xFilial("GM8") + cCodAge)
		cTexto := GM8->GM8_OBSERV//E_MSMM(GM8->GM8_OBSERV)
	EndIf
	DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,510 TITLE STR0139 PIXEL //"Observação"
	@ 015, 004 TO 085, 200 Label cLabel OF oDlgM PIXEL
	@ 025, 010 GET oTexto VAR cTexto MEMO READONLY SIZE 178.64, 051 OF oDlgM PIXEL
	DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (oDlgM:End()) ENABLE OF oDlgM
	ACTIVATE MSDIALOG oDlgM CENTERED
	RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ChamaFicha³ Autor ³ Saude     	 	     ³ Data ³17/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da ficha de tratamento com ou sem o paciente posic. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        		           |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_ChamaFicha()

	Local aArea		:= getArea()
	Local cCodReg	:= ""

	If !(lTelaOK)
		cCodReg := ""
	Else
		cCodReg := cRGerSel
	EndIf
	If Empty(cCodReg)
		If Pergunte("HSPM61", .T.)
			cCodReg := MV_PAR01
		Else
			RestArea(aArea)
			Return()
		EndIf
	EndIf
	fs_perfCli(3 , cCodReg)
	RestArea(aArea)

Return()

//-------------------------------------------
Static Function FS_GETMODCBR(cCodPac)

	Local cModo := "0"

	DbSelectArea("GD4")
	DbSetorder(2)
	If !DbSeek(xFilial("GD4") + cCodPac + "1")
		Return(cModo)
	EndIf
	DbSelectArea("GA9")
	DbSetorder(1)
	If !DbSeek(xFilial("GA9") + GD4->GD4_CODCON)
		Return(cModo)
	EndIf
	cModo 	:= GA9->GA9_TIPCON

Return(cModo)

***************************************************************************************************
//	08/12/15 - Rotina para Apagar Itens Relacionados aos Itens Excluidos no Orçamento Padrão 
FUNCTION M57CHKORC
*****************************

	LOCAL cSql := ""
   
	cSql := "SELECT DISTINCT CK_NUM, CK_ITEM "	//	Itens no Orçamento
	cSql +=   "FROM " + RetSqlName("SCK") + " SCK, " + RetSqlName("GTJ") + " GTJ "
	cSql +=  "WHERE SCK.D_E_L_E_T_ = '*' AND  CK_FILIAL = '" + xFilial("SGK") + "' "
	cSql +=    "AND GTJ.D_E_L_E_T_ = ' ' AND GTJ_STATUS = '2' AND GTJ_FILIAL = '" + xFilial("GTJ") + "' "
	cSql +=    "AND CK_NUM = GTJ_NUMORC  AND    CK_ITEM = GTJ_ITEM "
	cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "QRYDEL"
	IF !QRYDEL->(EOF())
		GTJ->(DBSETORDER(1))	//	Item Orcamento x Pln Tratamento
		GTC->(DBSETORDER(2))	//	Historico Tratamento Clinica
		GTD->(DBSETORDER(2))	//	Historico Exame Clinico
		GTH->(DBSETORDER(2))	//	HIST. EXAME CLINICO - GERAL
		GTO->(DBSETORDER(2))	//	Hist Tratamento Clinica Geral
		GT9->(DBSETORDER(1))	//	Itens do Orçamento Padrão
		SCK->(DBSETORDER(1))	//	Relac Orcamento Fat x Loja
		WHILE !QRYDEL->(EOF())
			IF GTJ->(DBSEEK(XFILIAL() + QRYDEL->(CK_NUM + CK_ITEM)))
				RECLOCK("GTJ")
				DBDELETE()
				MSUNLOCK()
			ENDIF
			IF GTC->(DBSEEK(XFILIAL() + QRYDEL->(CK_NUM + CK_ITEM)))
				RECLOCK("GTC")
				DBDELETE()
				MSUNLOCK()
			ENDIF
			IF GTD->(DBSEEK(XFILIAL() + QRYDEL->(CK_NUM + CK_ITEM)))
				RECLOCK("GTD")
				DBDELETE()
				MSUNLOCK()
			ENDIF
			IF GTH->(DBSEEK(XFILIAL() + QRYDEL->(CK_NUM + CK_ITEM)))
				RECLOCK("GTH")
				DBDELETE()
				MSUNLOCK()
			ENDIF
			IF GTO->(DBSEEK(XFILIAL() + QRYDEL->(CK_NUM + CK_ITEM)))
				RECLOCK("GTO")
				DBDELETE()
				MSUNLOCK()
			ENDIF
			IF !SCK->(DBSEEK(XFILIAL() + QRYDEL->CK_NUM))
				IF GT9->(DBSEEK(XFILIAL() + QRYDEL->CK_NUM))
					RECLOCK("GT9")
					DBDELETE()
					MSUNLOCK()
				ENDIF
			ENDIF
			QRYDEL->(DBSKIP())
		ENDDO
	ENDIF
	QRYDEL->(DbCloseArea())

RETURN(.T.)

***************************************************************************************************
//	22/12/15 - Grava todos os dados do Atendimento
STATIC FUNCTION fs_Salva()
*****************************

	FS_GrvM57(.T.,.F.,cCrmLog,,iIf(valType(aMntperg)=="A",aMntperg[2], {}), "G", ,cCdQues,,!Empty(cDirImg))

RETURN

