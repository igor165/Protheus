#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "GPEM858.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ GPEM858 ³ Autor ³Tiago Malta                      ³ Data ³ 01/04/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Manutencao ARI                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga-Venezuela			                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÁÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³11/05/2011³009206/2011³Alteração de Estrutura de campos para o ARI.³±±
±±³            ³          ³           ³                                            ³±±
±±³Jonathan Glz³04/05/2015³ PCREQ-4256³Se realiza ajuste a la funcion GPEM858, se  ³±±
±±³            ³          ³           ³elimina la modificacion al diccionario de   ³±±
±±³            ³          ³           ³datos (SX1) por motivo de adeciacion de     ³±±
±±³            ³          ³           ³nueva estructura de SXs para version 12     ³±±
±±³            ³          ³           ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function GPEM858()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea			:= GetArea()
Local nOpca			:= 0
Local aIndexSRA		:= {}				//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro
Private cAnoBas 		:= ""
Private cCadastro 	:= OemToAnsi(STR0001)
Private aRotina 		:= {}

	DbSelectArea("SRA")
	SRA->(DbsetOrder(1))
	SRA->(DbGoTop())

	cFiltraRh := CHKRH("GPEM858","SRA","1")
	bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
	Eval(bFiltraBrw)

	aRotina :=  MenuDef()

	mBrowse( 6, 1,22,75,"SRA")
	EndFilBrw("SRA",aIndexSRA)

RestArea( aArea )

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³MenuDef  ³ Autor ³Tiago Malta               ³ Data ³ 01/04/11         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Menu da Manutencao ARI                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga-Venezuela			                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MenuDef()

Local aRotina :=	{	{STR0010,"PesqBrw"  		, 0 , 1,,.F.},; //"Pesquisar"
						{STR0002,"GPEM858M"    , 0 , 4},;
						{STR0003,"GPER858"  		, 0 , 7} } //"Imprimir ARI"
Return aRotina

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³GPEM858M ³ Autor ³Tiago Malta               ³ Data ³ 01/04/11         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Estrutura e Montagem da Tela de Manutencao ISLR                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga-Venezuela			                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function GPEM858M(cAlias,nReg,nOpc)

Local oCkPRRem,oCbPRRem,oGtPRRem,oGtPRDes
Local oCkPVRem,oCbPVRem,oGtPVRem,oGtPVDes,oGtPVC,oGtPVA,oGtPVD  ,oGtPVT
Local oCkSVRem,oCbSVRem,oGtSVRem,oGtSVDes,oGtSVC,oGtSVA,oGtSVD  ,oGtSVT
Local oCkTVRem,oCbTVRem,oGtTVRem,oGtTVDes,oGtTVC,oGtTVA,oGtTVD  ,oGtTVT
Local oInstEns,oSegSCM ,oSMOH   ,oJuAMA  ,oVTotD,oAbPNa,oOnusFam,oQtdDep,oImpAnt,oTotOnu
Local oCklPRRem,oCklPVRem,oCklSVRem,oCklTVRem,oPasta
Local lOpc:=.T.,lConf:=.F.,lOpcG := .F.
Local aPasta	:= {STR0004,STR0005}
Local cVar1 := "" ,  cVar2 := "",cVar3 := "",cVar4 := "",cVar5 := ""
Local nTotDep := 0

Private cMatSra :=Space(6) ,cNomSra :=Space(60)
Private cCbPRRem:="" ,cCbPVRem:="" ,cCbSVRem:="" ,cCbTVRem:=""
Private lCkPRRem:=.F.,lCkPVRem:=.F.,lCkSVRem:=.F.,lCkTVRem:=.F.
Private nGtPRC:= 0 ,nGtPRA:= 0 ,nGtPRD:= 0 ,nGtPRT:= 0, nGtPRRem := 0 ,oGtPRC,oGtPRA,oGtPRD  ,oGtPRT , nGtPRDes:= 0
Private nGtPVRem:= 0 ,nGtPVDes:= 0 , nGtPVC:= 0 ,nGtPVA:= 0 ,nGtPVD:= 0 ,nGtPVT:= 0
Private nGtSVRem:= 0 ,nGtSVDes:= 0 , nGtSVC:= 0 ,nGtSVA:= 0 ,nGtSVD:= 0 ,nGtSVT:= 0
Private nGtTVRem:= 0 ,nGtTVDes:= 0 , nGtTVC:= 0 ,nGtTVA:= 0 ,nGtTVD:= 0 ,nGtTVT:= 0
Private aCbMeses:= {STR0018,STR0019,STR0020,STR0021,STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,;//"Nao Definido"#"Janeiro"#"Fevereiro"#"Marco"#"Abril"#"Maio"#"Junho"#"Julho"#"Agosto"#"Setembro"#"Outubro"
STR0029,STR0030}//"Novembro"#"Dezembro"
Private nAbPNa:= 0 , nOnusFam:= 0 ,nQtdDep := 0 , nTotOnu := 0 , nImpAnt:= 0 , nVTotD:= 0
Private nInstEns:= 0 , nSegSCM:=0 ,nJuAMA:= 0,nSMOH := 0
Private oDlg    ,oMatSra ,oNomSra
Private aCodigo := {"1R","1V","2V","3V"}

	Pergunte("GPEM858",.T.)

	cAnoBas  := MV_PAR01

	// Função que carrega os registros do ARI.
	GPEM858G()

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 100,100 TO 620,1000 STYLE DS_MODALFRAME STATUS PIXEL
	oPasta	:= TFolder():New(035,005,aPasta,{},oDlg,,,,.T.,.F.,445,220,)


	@ 010 ,010 TO  030,440  LABEL "" 				  																			PIXEL OF oDlg
	@ 015 ,015 SAY  STR0032												SIZE 050,7 												PIXEL OF oDlg//"MATRICULA"
	@ 015 ,060 MSGET oMatSra VAR cMatSra  ;
																		SIZE 040,7 WHEN IIF(nOpc==3,.T.,.F.)         			PIXEL OF oDlg
	@ 015 ,110 SAY  STR0033									  			SIZE 050,7												PIXEL OF oDlg//"NOME"
	@ 015 ,145 MSGET oNomSra VAR cNomSra								SIZE 200,7 WHEN .F.					 					PIXEL OF oDlg

	//*************************************************************************************************************************************************
	//=================================================================================================================================================
	//INFORMACOES ARI
	//=================================================================================================================================================
	//*************************************************************************************************************************************************
	@ 010 ,010 TO  160,440  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]
	@ 010 ,315 TO  025,440  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]
	@ 010 ,150 TO  160,230  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]
	@ 025 ,315 TO  160,345  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]
	@ 025 ,345 TO  160,375  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]
	@ 025 ,375 TO  160,405  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]
	@ 025 ,405 TO  160,440  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]
	@ 040 ,010 TO  130,440  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]
	@ 070 ,010 TO  100,440  LABEL "" 				  																			PIXEL OF oPasta:aDialogs[1]

	@ 015 ,155 SAY  STR0034												SIZE 100,7 												PIXEL OF oPasta:aDialogs[1]//"REMUNERACAO ANUAL"
	@ 015 ,250 SAY  STR0035												SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//DEDUCOES
	@ 015 ,350 SAY  STR0036			 									SIZE 100,7		 										PIXEL OF oPasta:aDialogs[1]//"ENCARGOS FAMILIARES"
	@ 020 ,040 SAY  STR0037 											SIZE 100,7 												PIXEL OF oPasta:aDialogs[1]//"INFORMACAO SEGUNDO AR-1"
	@ 025 ,155 SAY  SPACE(20)+STR0038									SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//"BS"
	@ 025 ,250 SAY  SPACE(12)+STR0038									SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//"BS"
	@ 030 ,320 SAY  STR0039 											SIZE 020,7 												PIXEL OF oPasta:aDialogs[1]//CONY
	@ 030 ,350 SAY  STR0040												SIZE 020,7 												PIXEL OF oPasta:aDialogs[1]//ASC
	@ 030 ,380 SAY  STR0041		 										SIZE 020,7		 										PIXEL OF oPasta:aDialogs[1]//DESC
	@ 030 ,410 SAY  STR0042												SIZE 020,7 												PIXEL OF oPasta:aDialogs[1]//TOTAL

	//=================================================================================================================================================
	//PRIMEIRA RELACAO
	//=================================================================================================================================================
	@ 045 ,015 SAY  STR0043												SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//PRIMEIRA
	@ 055 ,015 SAY  STR0044 											SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//RELACAO
	@ 050 ,060 CHECKBOX oCklPRRem 	VAR 	lCkPRRem Prompt "" 			SIZE 050,7 WHEN lOpcG									PIXEL OF oPasta:aDialogs[1] ;
	ON CLICK (Iif(!lCkPRRem,(cCbPrRem:=aCbMeses[1],oCbPRRem:SetFocus(),oCbPRRem:Refresh()),(oCbPRRem:SetFocus(),oCbPRRem:Refresh())))
	@ 050 ,090 COMBOBOX oCbPRRem    VAR 	cCbPRRem ITEMS 	aCbMeses	SIZE 050,7 WHEN Iif((nOpc==2),lCkPRRem,.F.)	PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (IIF(UPPER(cCbPRRem)==UPPER(STR0018),(Aviso(STR0006,STR0045,{STR0008}),.F.),.T.))//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
	@ 050 ,160 MSGET 	oGtPRRem 	VAR 	nGtPrRem VALID (IIF(UPPER(cCbPRRem)==UPPER(STR0018).and.lCkPRRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 050,7 WHEN lOpcG Picture "@E 9,999,999.99"			PIXEL OF oPasta:aDialogs[1]
	@ 050 ,240 MSGET 	oGtPRDes 	VAR 	nGtPrDes VALID (IIF(UPPER(cCbPRRem)==UPPER(STR0018).and.lCkPRRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 050,7 WHEN lOpcG Picture "@E 9,999,999.99"			PIXEL OF oPasta:aDialogs[1]
	@ 050 ,320 MSGET 	oGtPRC	 	VAR 	nGtPRC  VALID (IIF(UPPER(cCbPRRem)==UPPER(STR0018).and.lCkPRRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.));// Cony - "Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999"					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtPRT:=nGtPRC+nGtPRA+nGtPRD,oGtPRT:Refresh())
	@ 050 ,350 MSGET 	oGtPRA 		VAR 	nGtPRA VALID (IIF(UPPER(cCbPRRem)==UPPER(STR0018).and.lCkPRRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;// Asc - "Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999"					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtPRT:=nGtPRC+nGtPRA+nGtPRD,oGtPRT:Refresh())
	@ 050 ,380 MSGET 	oGtPRD 		VAR 	nGtPRD VALID (IIF(UPPER(cCbPRRem)==UPPER(STR0018).and.lCkPRRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;// Desc - "Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999"					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtPRT:=nGtPRC+nGtPRA+nGtPRD,oGtPRT:Refresh())
	@ 050 ,410 MSGET 	oGtPRT 		VAR 	nGtPRT						SIZE 020,7 WHEN .F.  Picture "@E 9999"					PIXEL OF oPasta:aDialogs[1]  // Total
	//=================================================================================================================================================
	//PRIMEIRA VARIACAO
	//=================================================================================================================================================
	@ 075 ,015 SAY  STR0043 											SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//PRIMEIRA
	@ 085 ,015 SAY  STR0046 											SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//VARIACAO
	@ 080 ,060 CHECKBOX oCklPVRem 	VAR 	lCkPVRem Prompt "" 			SIZE 050,7 WHEN lOpcG									PIXEL OF oPasta:aDialogs[1] ;
	ON CLICK (Iif(!lCkPVRem,(cCbPVRem:=aCbMeses[1],oCbPVRem:SetFocus(),oCbPVRem:Refresh()),(oCbPVRem:SetFocus(),oCbPVRem:Refresh())))
	@ 080 ,090 COMBOBOX oCbPVRem 	VAR     cCbPVRem ITEMS 	aCbMeses	SIZE 050,7 WHEN Iif((nOpc==2),lCkPVRem,lOpc)PIXEL OF oPasta:aDialogs[1]
	@ 080 ,160 MSGET 	oGtPVRem 	VAR 	nGtPVRem VALID (IIF(UPPER(cCbPVRem)==UPPER(STR0018).and.lCkPvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 050,7 WHEN lOpcG Picture "@E 9,999,999.99" 																			PIXEL OF oPasta:aDialogs[1]
	@ 080 ,240 MSGET 	oGtPVDes 	VAR 	nGtPVDes VALID (IIF(UPPER(cCbPVRem)==UPPER(STR0018).and.lCkPvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 050,7 WHEN lOpcG Picture "@E 9,999,999.99" 																			PIXEL OF oPasta:aDialogs[1]
	@ 080 ,320 MSGET 	oGtPVC	 	VAR 	nGtPVC VALID (IIF(UPPER(cCbPVRem)==UPPER(STR0018).and.lCkPvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 																						PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtPVT:=nGtPVC+nGtPVA+nGtPVD,oGtPVT:Refresh())
	@ 080 ,350 MSGET 	oGtPVA 		VAR 	nGtPVA VALID (IIF(UPPER(cCbPVRem)==UPPER(STR0018).and.lCkPvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 																						PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtPVT:=nGtPVC+nGtPVA+nGtPVD,oGtPVT:Refresh())
	@ 080 ,380 MSGET 	oGtPVD 		VAR 	nGtPVD	VALID (IIF(UPPER(cCbPVRem)==UPPER(STR0018).and.lCkPvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 																						PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtPVT:=nGtPVC+nGtPVA+nGtPVD,oGtPVT:Refresh())
	@ 080 ,410 MSGET 	oGtPVT 		VAR 	nGtPVT						SIZE 020,7 WHEN .F.  Picture "@E 9999" 					PIXEL OF oPasta:aDialogs[1]
	//SEGUNDA VARIACAO
	@ 105 ,015 SAY  STR0047 											SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//"SEGUNDA"
	@ 115 ,015 SAY  STR0046		 										SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//"VARIACAO"
	@ 110 ,060 CHECKBOX oCklSVRem 	VAR 	lCkSVRem Prompt "" 			SIZE 050,7 WHEN lOpcG									PIXEL OF oPasta:aDialogs[1] ;
	ON CLICK (Iif(!lCkSVRem,(cCbSVRem:=aCbMeses[1],oCbSVRem:SetFocus(),oCbSVRem:Refresh()),(oCbSVRem:SetFocus(),oCbSVRem:Refresh())))
	@ 110 ,090 COMBOBOX oCbSVRem 	VAR 	cCbSVRem ITEMS 	aCbMeses	SIZE 050,7 WHEN Iif((nOpc==2),lCkSVRem,lOpc)PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (IIF(UPPER(cCbSVRem)==UPPER(STR0018),(Aviso(STR0006,STR0045,{STR0008}),.F.),.T.))//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
	@ 110 ,160 MSGET 	oGtSVRem 	VAR 	nGtSVRem VALID (IIF(UPPER(cCbSVRem)==UPPER(STR0018).and.lCkSvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 050,7 WHEN lOpcG Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[1]
	@ 110 ,240 MSGET 	oGtSVDes 	VAR 	nGtSVDes  VALID (IIF(UPPER(cCbSVRem)==UPPER(STR0018).and.lCkSvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 050,7 WHEN lOpcG Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[1]
	@ 110 ,320 MSGET 	oGtSVC	 	VAR 	nGtSVC  VALID (IIF(UPPER(cCbSVRem)==UPPER(STR0018).and.lCkSvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtSVT:=nGtSVC+nGtSVA+nGtSVD,oGtSVT:Refresh())
	@ 110 ,350 MSGET 	oGtSVA 		VAR 	nGtSVA  VALID (IIF(UPPER(cCbSVRem)==UPPER(STR0018).and.lCkSvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtSVT:=nGtSVC+nGtSVA+nGtSVD,oGtSVT:Refresh())
	@ 110 ,380 MSGET 	oGtSVD 		VAR 	nGtSVD  VALID (IIF(UPPER(cCbSVRem)==UPPER(STR0018).and.lCkSvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtSVT:=nGtSVC+nGtSVA+nGtSVD,oGtSVT:Refresh())
	@ 110 ,410 MSGET 	oGtSVT 		VAR 	nGtSVT						SIZE 020,7 WHEN .F.  Picture "@E 9999" 					PIXEL OF oPasta:aDialogs[1]
	//=================================================================================================================================================
	//TERCEIRA VARIACAO
	//=================================================================================================================================================
	@ 145 ,015 SAY  STR0048 											SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//"TERCEIRA"
	@ 135 ,015 SAY  STR0046 											SIZE 050,7 												PIXEL OF oPasta:aDialogs[1]//"VARIACAO"
	@ 140 ,060 CHECKBOX oCklTVRem 	Var 	lCkTVRem Prompt "" 			SIZE 050,7 WHEN lOpcG									PIXEL OF oPasta:aDialogs[1] ;
	ON CLICK (Iif(!lCkTVRem,(cCbTVRem:=aCbMeses[1],oCbTVRem:SetFocus(),oCbTVRem:Refresh()),(oCbTVRem:SetFocus(),oCbTVRem:Refresh())))
	@ 140 ,090 COMBOBOX oCbTVRem	VAR 	cCbTVRem ITEMS 	aCbMeses	SIZE 050,7 WHEN Iif((nOpc==2),lCkTVRem,lOpc)PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (IIF(UPPER(cCbTVRem)==UPPER(STR0018),(Aviso(STR0006,STR0045,{STR0008}),.F.),.T.))//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
	@ 140 ,160 MSGET 	oGtTVRem 	VAR 	nGtTVRem  VALID (IIF(UPPER(cCbTVRem)==UPPER(STR0018).and.lCkTvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 050,7 WHEN lOpcG Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[1]
	@ 140 ,240 MSGET 	oGtTVDes 	VAR 	nGtTVDes VALID (IIF(UPPER(cCbTVRem)==UPPER(STR0018).and.lCkTvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 050,7 WHEN lOpcG Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[1]
	@ 140 ,320 MSGET 	oGtTVC	 	VAR 	nGtTVC VALID (IIF(UPPER(cCbTVRem)==UPPER(STR0018).and.lCkTvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtTVT:=nGtTVC+nGtTVA+nGtTVD,oGtTVT:Refresh())
	@ 140 ,350 MSGET 	oGtTVA 		VAR 	nGtTVA VALID (IIF(UPPER(cCbTVRem)==UPPER(STR0018).and.lCkTvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtTVT:=nGtTVC+nGtTVA+nGtTVD,oGtTVT:Refresh())
	@ 140 ,380 MSGET 	oGtTVD 		VAR 	nGtTVD VALID (IIF(UPPER(cCbTVRem)==UPPER(STR0018).and.lCkTvRem==.T.,(Aviso(STR0006,STR0045,{STR0008}),.T.),.T.)) ;//"Nao Definido"#"Atencao"#"Informe Mes correspondente"#"OK"
																		SIZE 020,7 WHEN lOpcG Picture "@E 999" 					PIXEL OF oPasta:aDialogs[1] ;
	ON CHANGE (nGtTVT:=nGtTVC+nGtTVA+nGtTVD,oGtTVT:Refresh())
	@ 140 ,410 MSGET 	oGtTVT 		VAR 	nGtTVT						SIZE 020,7 WHEN .F.  Picture "@E 9999" 					PIXEL OF oPasta:aDialogs[1]
	//*************************************************************************************************************************************************
	//=================================================================================================================================================
	//PASTA  2 - INFORMACOES COMPLEMENTARES ARI
	//=================================================================================================================================================
	//*************************************************************************************************************************************************
	@ 010 ,010 TO  090,440  LABEL STR0059 				  																		PIXEL OF oPasta:aDialogs[2]//"Deducoes pagas durante o ano"
	@ 020 ,015 SAY  STR0060 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Instituições de ensino"
	@ 020 ,300 MSGET 	oInstEns 	VAR 	nInstEns  					SIZE 100,7 WHEN lOpc Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[2] ;
	ON CHANGE (nVTotD:=nInstEns+nSegSCM+nSMOH+nJuAMA,GP858VLDES(),oVTotD:Refresh())
	@ 030 ,015 SAY  STR0061 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Seguros saúde, cirurgias e maternidade"
	@ 030 ,300 MSGET 	oSegSCM 	VAR 	nSegSCM 					SIZE 100,7 WHEN lOpc Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[2] ;
	ON CHANGE (nVTotD:=nInstEns+nSegSCM+nSMOH+nJuAMA,GP858VLDES(),oVTotD:Refresh())
	@ 040 ,015 SAY  STR0062 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Serviços médicos odontológicos e hospitais (inclui plano familiar)"
	@ 040 ,300 MSGET 	oSMOH	 	VAR 	nSMOH 						SIZE 100,7 WHEN lOpc Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[2] ;
	ON CHANGE (nVTotD:=nInstEns+nSegSCM+nSMOH+nJuAMA,GP858VLDES(),oVTotD:Refresh())
	@ 050 ,015 SAY  STR0063 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Juros pela aquisição de moradia ou aluguel"
	@ 050 ,300 MSGET 	oJuAMA	 	VAR 	nJuAMA	 					SIZE 100,7 WHEN lOpc Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[2] ;
	ON CHANGE (nVTotD:=nInstEns+nSegSCM+nSMOH+nJuAMA,GP858VLDES(),oVTotD:Refresh())
	@ 060 ,015 SAY  Replicate("_",180)									SIZE 400,7 												PIXEL OF oPasta:aDialogs[2]
	@ 070 ,015 SAY  STR0064 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Valor Total em Deducoes "
	@ 070 ,300 MSGET 	oVTotD	 	VAR 	nVTotD 						SIZE 100,7 WHEN .F. Picture "@E 999,999,999.99" 		PIXEL OF oPasta:aDialogs[2]

	@ 100 ,010 TO  160,440  LABEL STR0065 				  																		PIXEL OF oPasta:aDialogs[2]//"Abatimento ao Imposto"
	@ 120 ,015 SAY  STR0066 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Abatimentos pessoa natural (art. 63 da lei)"
	@ 120 ,300 MSGET 	oAbPNa 		VAR 	nAbPNa 						SIZE 100,7 WHEN lOpc Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[2]
	@ 130 ,015 SAY  STR0067 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Ônus familiar "
	@ 130 ,060 MSGET 	oOnusFam 	VAR 	nOnusFam 					SIZE 080,7 WHEN lOpc Picture "@E 9,999,999.99" 			PIXEL OF oPasta:aDialogs[2] ;
	ON CHANGE (nTotOnu:=nOnusFam*nQtdDep,oTotOnu:Refresh())
	@ 130 ,150 SAY  STR0068 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Quantidade"
	@ 130 ,200 MSGET 	oQtdDep 	VAR 	nQtdDep 					SIZE 050,7 WHEN lOpc Picture "@E 99" 					PIXEL OF oPasta:aDialogs[2] ;
	ON CHANGE (nTotOnu:=nOnusFam*nQtdDep,oTotOnu:Refresh())
	@ 130 ,280 SAY 	" = " 	 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]
	@ 130 ,300 MSGET 	oTotOnu 	VAR 	nTotOnu 					SIZE 100,7 WHEN .F. Picture  "@E 999,999,999.99"		PIXEL OF oPasta:aDialogs[2]
	@ 140 ,015 SAY  STR0069 											SIZE 200,7 												PIXEL OF oPasta:aDialogs[2]//"Impostos retidos em anos anteriores"
	@ 140 ,300 MSGET 	oImpAnt 	VAR 	nImpAnt 					SIZE 100,7 WHEN lOpc Picture "@E 999,999,999.99" 			PIXEL OF oPasta:aDialogs[2]

	//=================================================================================================================================================
  	@ 165 ,010 TO  200,440  LABEL  				  																				PIXEL OF oPasta:aDialogs[1]
	//@ 170 ,015 SAY  STR0049  											SIZE 300,7								 				PIXEL OF oPasta:aDialogs[1]//"Para que as informacoes aqui inseridas sejam exibidas nos relatorios ARC e ARI e necessario clicar na opcao"
	//@ 180 ,015 SAY  STR0050 											SIZE 300,7 												PIXEL OF oPasta:aDialogs[1]//"disponivel no quadro 'INFORMACAO SEGUNDO AR-1' para o movimento de relacao ou variacao e definir o mes correspondente."
	@ 165 ,010 TO  200,440  LABEL  				  																				PIXEL OF oPasta:aDialogs[2]

	DEFINE SBUTTON FROM 230,380 TYPE 1 ACTION (lConf:=.t.,oDlg:End()) 									ENABLE OF oDlg
	DEFINE SBUTTON FROM 230,410 TYPE 2 ACTION (lConf:=.F.,oDlg:End())									ENABLE OF oDlg
	oDlg:LESCCLOSE := .F.//Nao Permitir fechar a janela pelo X
	ACTIVATE MSDIALOG oDlg CENTERED

	//=================================================================================================================================================
	//Inclusao, Alteracao e Exclusao de Registro
	//=================================================================================================================================================
	If lConf

		IF lCkTVRem
			cVar1 := aCodigo[4]
			cVar2 := "nGtTVRem"
			cVar3 := "nGtTVC"
			cVar4 := "nGtTVA"
			cVar5 := "nGtTVD"
			cVar6 := "cCbTVRem"
		ELSEIF lCkSVRem
			cVar1 := aCodigo[3]
			cVar2 := "nGtSVRem"
			cVar3 := "nGtSVC"
			cVar4 := "nGtSVA"
			cVar5 := "nGtSVD"
			cVar6 := "cCbSVRem"
		ELSEIF lCkPVRem
			cVar1 := aCodigo[2]
			cVar2 := "nGtPVRem"
			cVar3 := "nGtPVC"
			cVar4 := "nGtPVA"
			cVar5 := "nGtPVD"
			cVar6 := "cCbPVRem"
		ELSEIF lCkPRRem
			cVar1 := aCodigo[1]
			cVar2 := "nGtPRRem"
			cVar3 := "nGtPRC"
			cVar4 := "nGtPRA"
			cVar5 := "nGtPRD"
			cVar6 := "cCbPrRem"
		ENDIF

		Begin Transaction
		If nOpc==2

			DBSELECTAREA("RGS")
			RGS->( DBSETORDER(3) )
			IF !RGS->( DBSEEK( xFilial("RGS") + cMatSra + cVar1 + cAnoBas ) )
				RecLock("RGS",.T.)
			ELSE
				RecLock("RGS",.F.)
			ENDIF

			RGS->RGS_FILIAL:=xFilial("RGS")
			RGS->RGS_ANO   :=cAnoBas
			RGS->RGS_MAT   :=cMatSra
			RGS->RGS_NOME  :=cNomSra
			RGS->RGS_CODIGO:= cVar1
			RGS->RGS_MES   := RetMesRGS(&cVar6)
			RGS->RGS_SALARI:= &cVar2  // remuneração
			RGS->RGS_QTDDEP:= &cVar3  //cony
			RGS->RGS_DEPASC:= &cVar4  //asc
			RGS->RGS_DEPDES:= &cVar5  //desc
			RGS->RGS_INSTEN:=nInstEns
			RGS->RGS_SEGSAL:=nSegSCM
			RGS->RGS_SERVME:=nSMOH
			RGS->RGS_INTERA:=nJuAMA
			RGS->RGS_REBAJP:=nAbPNa
			RGS->RGS_CARGAF:=nOnusFam
			RGS->RGS_IMPEST:=nImpAnt
			RGS->(MsUnlock())

			// Gera Percentual de IR e Grava na Tabela SRA.
			nTotDep := &cVar3 + &cVar4 + &cVar5
			GeraPercent( cMatSra , &cVar2 , nInstEns+nSegSCM+nSMOH+nJuAMA , nAbPNa + (nTotDep * nOnusFam) )
		Endif
		End Transaction
	Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³RetMesRGS³ Autor ³Marcos Kato               ³ Data ³ 03/02/09         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tratamento Mes da Tela de Manutencao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga-Venezuela			                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function RetMesRGS(cConteudo)
Local cRet:=""
If UPPER(cConteudo)=UPPER(STR0019)//"Janeiro"
	cRet:="01"
ElseIf UPPER(cConteudo)=UPPER(STR0020)//"FEVEREIRO"
	cRet:="02"
ElseIf UPPER(cConteudo)=UPPER(STR0021)//"MARCO"
	cRet:="03"
ElseIf UPPER(cConteudo)=UPPER(STR0022)//"ABRIL"
	cRet:="04"
ElseIf UPPER(cConteudo)=UPPER(STR0023)//"MAIO"
	cRet:="05"
ElseIf UPPER(cConteudo)=UPPER(STR0024)//"JUNHO"
	cRet:="06"
ElseIf UPPER(cConteudo)=UPPER(STR0025)//"JULHO"
	cRet:="07"
ElseIf UPPER(cConteudo)=UPPER(STR0026)//"AGOSTO"
	cRet:="08"
ElseIf UPPER(cConteudo)=UPPER(STR0027)//"SETEMBRO"
	cRet:="09"
ElseIf UPPER(cConteudo)=UPPER(STR0028)//"OUTUBRO"
	cRet:="10"
ElseIf UPPER(cConteudo)=UPPER(STR0029)//"NOVEMBRO"
	cRet:="11"
ElseIf UPPER(cConteudo)=UPPER(STR0030)//"DEZEMBRO"
	cRet:="12"
Endif
Return cRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEM858   ºAutor  ³Microsiga           º Data ³  04/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Função que carrega as infromações da tabela RGS.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPEM858G()
Local cVar1
Local cVar2
Local cVar3
Local cVar4
Local cVar5
Local aTab := {}
Local cCodigo
Local cVarA
Local cVarB
Local cVarC
Local cVarD
Local cVarE
Local cVarF
Local cVarG
Local cVarH
Local lAchou := .F.

	cMatSra:=SRA->RA_MAT
	cNomSra:=SRA->RA_NOME

	Dbselectarea("RGS")
	RGS->(DBSETORDER(3))
	RGS->(DBSEEK( xFilial("RGS") + SRA->RA_MAT))
	While RGS->(!EOF()) .AND. RGS->RGS_MAT == SRA->RA_MAT

		cCodigo := RGS->RGS_CODIGO

		IF cCodigo == aCodigo[4]
			cVarA := "nGtTVRem"
			cVarB := "nGtTVC"
			cVarC := "nGtTVA"
			cVarD := "nGtTVD"
			cVarE := "lCkTVRem"
			cVarF := "cCbTVRem"
			cVarG := "nGtTVT"
			cVarH := "nGtTVDes"
		ELSEIF cCodigo == aCodigo[3]
			cVarA := "nGtSVRem"
			cVarB := "nGtSVC"
			cVarC := "nGtSVA"
			cVarD := "nGtSVD"
			cVarE := "lCkSVRem"
			cVarF := "cCbSVRem"
			cVarG := "nGtSVT"
			cVarH := "nGtSVDes"
		ELSEIF cCodigo == aCodigo[2]
			cVarA := "nGtPVRem"
			cVarB := "nGtPVC"
			cVarC := "nGtPVA"
			cVarD := "nGtPVD"
			cVarE := "lCkPVRem"
			cVarF := "cCbPVRem"
			cVarG := "nGtPVT"
			cVarH := "nGtPVDes"
		ELSEIF cCodigo == aCodigo[1]
			cVarA := "nGtPRRem"
			cVarB := "nGtPRC"
			cVarC := "nGtPRA"
			cVarD := "nGtPRD"
			cVarE := "lCkPRRem"
			cVarF := "cCbPRRem"
			cVarG := "nGtPRT"
			cVarH := "nGtPRDes"
		ENDIF

		&cVarF   := aCbMeses[Val(RGS->RGS_MES)+1]
		&cVarA   := RGS->RGS_SALARI // remuneração
		&cVarB   := RGS->RGS_QTDDEP  //cony
		&cVarC   := RGS->RGS_DEPASC  //asc
		&cVarD   := RGS->RGS_DEPDES  //desc
		nInstEns := RGS->RGS_INSTEN
		nSegSCM  := RGS->RGS_SEGSAL
		nSMOH    := RGS->RGS_SERVME
		nJuAMA   := RGS->RGS_INTERA
		nAbPNa   := RGS->RGS_REBAJP
		nOnusFam := RGS->RGS_CARGAF
		nImpAnt  := RGS->RGS_IMPEST

		&cVarH := nInstEns+nSegSCM+nSMOH+nJuAMA
		nVTotD := &cVarH
		&cVarG := &cVarB + &cVarC + &cVarD
		RGS->(DBSKIP())
	ENDDO

	IF MV_PAR02 == 1

		lCkPRRem := .t.
		cVar1 := "nGtPRC"
		cVar2 := "nGtPRA"
		cVar3 := "nGtPRD"
		cVar4 := "nGtPRT"
		cVar5 := "nGtPRDes"

		IF RGS->( DBSEEK( xFilial("RGS") + cMatSra + aCodigo[1] + cAnoBas ) )
			nInstEns := RGS->RGS_INSTEN
			nSegSCM  := RGS->RGS_SEGSAL
			nSMOH    := RGS->RGS_SERVME
			nJuAMA   := RGS->RGS_INTERA
			nAbPNa   := RGS->RGS_REBAJP
			nOnusFam := RGS->RGS_CARGAF
			nImpAnt  := RGS->RGS_IMPEST
			&cVar5 := RGS->RGS_INSTEN + RGS->RGS_SEGSAL + RGS->RGS_SERVME + RGS->RGS_INTERA
			nVTotD := &cVar5
			nQtdDep:= &cVar4
			nTotOnu:= nOnusFam * nQtdDep
			lAchou := .T.
		ELSE
			cCbPRRem := aCbMeses[2]
			nGtPrRem := SRA->RA_SALARIO * 12
		ENDIF

	ELSEIF MV_PAR02 == 2
		lCkPVRem := .t.
		cVar1 := "nGtPVC"
		cVar2 := "nGtPVA"
		cVar3 := "nGtPVD"
		cVar4 := "nGtPVT"
		cVar5 := "nGtPVDes"

		IF RGS->( DBSEEK( xFilial("RGS") + cMatSra + aCodigo[2] + cAnoBas ) )
			nInstEns := RGS->RGS_INSTEN
			nSegSCM  := RGS->RGS_SEGSAL
			nSMOH    := RGS->RGS_SERVME
			nJuAMA   := RGS->RGS_INTERA
			nAbPNa   := RGS->RGS_REBAJP
			nOnusFam := RGS->RGS_CARGAF
			nImpAnt  := RGS->RGS_IMPEST
			&cVar5 := RGS->RGS_INSTEN + RGS->RGS_SEGSAL + RGS->RGS_SERVME + RGS->RGS_INTERA
			nVTotD := &cVar5
			nQtdDep:= &cVar4
			nTotOnu:= nOnusFam * nQtdDep
			lAchou := .T.
		ELSE
   			cCbPVRem := aCbMeses[4]
   			nGtPVRem := SRA->RA_SALARIO * 9
		ENDIF

	ELSEIF MV_PAR02 == 3
		lCkSVRem := .t.
		cVar1 := "nGtSVC"
		cVar2 := "nGtSVA"
		cVar3 := "nGtSVD"
		cVar4 := "nGtSVT"
		cVar5 := "nGtSVDes"

		IF RGS->( DBSEEK( xFilial("RGS") + cMatSra + aCodigo[3] + cAnoBas ) )
			nInstEns := RGS->RGS_INSTEN
			nSegSCM  := RGS->RGS_SEGSAL
			nSMOH    := RGS->RGS_SERVME
			nJuAMA   := RGS->RGS_INTERA
			nAbPNa   := RGS->RGS_REBAJP
			nOnusFam := RGS->RGS_CARGAF
			nImpAnt  := RGS->RGS_IMPEST
			&cVar5 := RGS->RGS_INSTEN + RGS->RGS_SEGSAL + RGS->RGS_SERVME + RGS->RGS_INTERA
			nVTotD := &cVar5
			nQtdDep:= &cVar4
			nTotOnu:= nOnusFam * nQtdDep
			lAchou := .T.
		ELSE
	 		cCbSVRem := aCbMeses[7]
	 		nGtSVRem := SRA->RA_SALARIO * 6
		ENDIF

	ELSEIF MV_PAR02 == 4
		lCkTVRem := .t.
		cVar1 := "nGtTVC"
		cVar2 := "nGtTVA"
		cVar3 := "nGtTVD"
		cVar4 := "nGtTVT"
		cVar5 := "nGtTVDes"

		IF RGS->( DBSEEK( xFilial("RGS") + cMatSra + aCodigo[4] + cAnoBas ) )
			nInstEns := RGS->RGS_INSTEN
			nSegSCM  := RGS->RGS_SEGSAL
			nSMOH    := RGS->RGS_SERVME
			nJuAMA   := RGS->RGS_INTERA
			nAbPNa   := RGS->RGS_REBAJP
			nOnusFam := RGS->RGS_CARGAF
			nImpAnt  := RGS->RGS_IMPEST
			&cVar5 := RGS->RGS_INSTEN + RGS->RGS_SEGSAL + RGS->RGS_SERVME + RGS->RGS_INTERA
			nVTotD := &cVar5
			nQtdDep:= &cVar4
			nTotOnu:= nOnusFam * nQtdDep
			lAchou := .T.
		ELSE
	 		cCbTVRem := aCbMeses[10]
			nGtTVRem := SRA->RA_SALARIO * 3
		ENDIF

	ENDIF

	IF !lAchou

		&cVar1 := 0
		&cVar2 := 0
		&cVar3 := 0

		DBSELECTAREA("SRB")
		SRB->( DbSeek(xFilial("SRB")+SRA->RA_MAT) )
		While SRB->(!eof()) .and. SRB->RB_MAT == SRA->RA_MAT
			IF !( SRB->RB_TIPIR $ " 4" )
				IF SRB->RB_GRAUPAR == "1"
			   		&cVar1 += 1
				ELSEIF SRB->RB_GRAUPAR == "2"
					&cVar2 += 1
				ELSEIF SRB->RB_GRAUPAR == "3"
					&cVar3 += 1
				ENDIF
			ENDIF
			SRB->(dbskip())
		Enddo

		&cVar4 := &cVar1 + &cVar2 + &cVar3
		&cVar5 := nInstEns+nSegSCM+nSMOH+nJuAMA
		fRetTab(@aTab,"S023",,,dDataBase)

		IF LEN(aTab) > 0
			nAbPNa := aTab[5]     // Rebaja Personal
			nOnusFam := aTab[6]   // Carga Familiar
			nQtdDep  := &cVar4   // Quantidade Depen
			nTotOnu  := aTab[6] * &cVar4   // Total Familiar
		ENDIF

	ENDIF

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP858VLDESºAutor  ³Tiago Malta         º Data ³  04/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que atualiza o campo de total de desconto da tela.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GP858VLDES()

	IF lCkPRRem
		nGtPRDes := nVTotD
	ELSEIF lCkPVRem
		nGtPVDes := nVTotD
	ELSEIF lCkSVRem
		nGtSVDes := nVTotD
	ELSEIF lCkTVRem
		nGtTVDes := nVTotD
	ENDIF

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraPercentºAutor ³Tiago Malta         º Data ³  04/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Função que calcula e atualiza o percentual de ir no       º±±
±±º          ³   cadastro do funcionario.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraPercent( cMatSra , nRemune , nDesgrav , nRebaj )
	Local aTabUT   := {}
	Local aTabARI  := {}
	Local aTabISLR := {}
	Local nValUT   := 0
	Local nValB    := 0
	Local nValD    := 0
	Local nValF    := 0
	Local nPercent := 0
	Local nPos     := 0
	Local nPerc    := 0
	Local nDeduc   := 0
	Local nValG    := 0
	Local nValH    := 0
	Local nValI    := 0

		fRetTab(@aTabUT  ,"S002",,,dDataBase)
		fRetTab(@aTabARI ,"S023",,,dDataBase)
		fRetTab(@aTabISLR,"S013",,,dDataBase,,.t.)

		IF Len(aTabUT) > 0 .and. Len(aTabARI) > 0 .and. Len(aTabISLR) > 0

			nValDesU := aTabARI[7]
			nValUT   := aTabUT[5]
			nValB    := nRemune / nValUT
			nValD    := nDesgrav / nValUT
			nValF    := nValB - nValDesU

			aSort( aTabISLR ,,, {|x,y| x[5] < y[5] } )
			nPos := Ascan( aTabISLR , { |x| x[5] >= nValF } )

			IF nPos > 0
				nPerc  := aTabISLR[nPos][6]
				nDeduc := aTabISLR[nPos][7]
				nValG  := ( nValF * ( nPerc / 100 ) ) - nDeduc
			ELSE
				Return()
			ENDIF

			nValH    := nRebaj
			nValI    := nValG - nValH
			nPercent := nValI / nValB

		Endif

		IF nPercent > 0
			DBSELECTAREA("SRA")
			DBSETORDER(1)
			DBSEEK( xFilial("SRA") + cMatSra )

			Reclock("SRA",.F.)
			SRA->RA_PERCEIR := nPercent
			SRA->( MsUnlock() )
		ENDIF

Return()