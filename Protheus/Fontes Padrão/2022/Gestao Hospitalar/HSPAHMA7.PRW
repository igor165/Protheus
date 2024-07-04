#INCLUDE "hspahma7.ch"
#INCLUDE "MSMGADD.CH"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHMA7  º Autor ³ José Orfeu         º Data ³  27/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa para implementacao da Anamnese Eletronica         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static cFiltroGfu := ""
Static lMarkGfu := .F.
Static __cMa7Aces := "C"

Function HSPAHMA7()
Local aCampos := {	{"C", "GFS_IDMARK"},;
                  	{"C", "GFU_STAINT"}}
Local bKeyF12 := SetKey(VK_F12, {|| FS_FilMA7(.T., @cFilMA7) } )
Local aCores  := {	{"GCY->GCY_STATUS == '0'", "BR_VERDE"   }, ; //Recepcionado
                    {"GCY->GCY_STATUS == '1'", "BR_AMARELO" }, ; //Pré-Triagem
                    {"GCY->GCY_STATUS == '2'", "BR_LARANJA" }, ; //Anamnese
                    {"GCY->GCY_STATUS == '3'", "BR_VERMELHO"} }  //Anamnese confirmada

/*************************************************************/

Local aSize		:= {}										//Array com o tamnho da tela
Local oFWLayer   												//Layer
Local oPLUp													// Painel Superior da Esquerda
Local oPRUp													// Painel Superior da Direita
Local oPMiddle												// Painel Central
Static oBrwGCY												//Browse dos programas
Static oMBrwGM8												//Mark Browse dos Elegiveis
Local cTitulo 		:= ""										//Variavel com o Titulo da Dialog
Local oDlgPRO
Local aHeadBOA		:= {}
Local aStruct		:= {}
Local aTitles     := {}


/*************************************************************/

Private lMVPromo := SuperGetMV("MV_PROSAUD", NIL, .F.)  // Promoção a Saude
Private lAvisoProm	:=.F.
Private cFilMA7 := ""

Private lFilGm1    := .F.     // Utilizado na validação e no filtro da pergunta do codigo do setor
Private cGcsTipLoc := "01234CDEJ"  // Utilizado na validação e no filtro da pergunta do codigo do setor
Private cCadastro  := STR0005 //"Anamnese"
Private aCodUsr    := {}

//Private aRotina := MenuDef()
Private aRotina := {}

Private dDatDe     := CToD(" ")                   // MV_PAR01 HSMA7A   ¦ 01       ¦ Da Data de Atendimento ?
Private dDatAte    := CToD(" ")                   // MV_PAR02 HSMA7A   ¦ 02       ¦ AtÚ Data de Atendimento ?
Private cCodLoc    := Space(Len(GCY->GCY_CODLOC)) // MV_PAR03 HSMA7A   ¦ 03       ¦ Setor ?
Private cPlaDe     := Space(Len(GCZ->GCZ_CODPLA)) // MV_PAR04 HSMA7A   ¦ 04       ¦ Do Plano ?
Private cPlaAte    := Space(Len(GCZ->GCZ_CODPLA)) // MV_PAR05 HSMA7A   ¦ 05       ¦ Ate o Plano ?
Private nVisAnm    := 1                           // MV_PAR06 HSMA7A   ¦ 06       ¦ Vis.anamnese de outro profis.
Private nQtdAnm    := 0                           // MV_PAR07 HSMA7A   ¦ 07       ¦ Quantidade de anamneses
Private cLocCon    := ""                          // MV_PAR08 HSMA7A   ¦ 08       ¦ Setor do Consultorio
Private nStatus    := 5                           // MV_PAR09 HSMA7A   ¦ 09       ¦ Situação do atendimento
//Private __cMa7Aces := "C"
Private aMneSele   := {}  //utilizada para armazenar todos os mnemonicos selecionados para cada pergunta
Private lFilVir    := HS_ExisDic({{"C", "GBJ_CRMVIR"}},.F.)
Private cEspUsu    := ""
Private lFilExcl   := HS_ExisDic({{"C", "GBJ_PROEXC"}},.F.)
Private lVerFil	 := HS_ExisDic({{"C", "GBJ_VIFILI"}},.F.)

If !HS_ExisDic(aCampos)
	Return(.F.)
EndIf

/* Verificar autorizacao de acesso para o medico */
If !(aCodUsr := HS_VldDAnm(.T.))[1]
	SetKey(VK_F12, bKeyF12)
	Return(Nil)
EndIf

cEspUsu := HS_REspMed(aCodUsr[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da função que apresenta a tela ³
//³com os pacietnes que foram internados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction('PLSSINMED')
	PLSSINMED()
EndIf
DbSelectArea("GCY")
DbSetOrder(1)  //GCY_FILIAL + GCY_REGATE

If FS_FilMA7(.F., @cFilMA7)

aSize := FWGetDialogSize( oMainWnd )

DEFINE MSDIALOG oDlgPRO TITLE STR0005 	FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Inicializa o FWLayer		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFwLayer := FwLayer():New()
oFwLayer:Init(oDlgPRO,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Cria o Layer Superior	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ //If lR7
oFWLayer:addLine("UpAtend", 72, .F.) //layer superior Programas e Alertas
oFWLayer:addLine( "DownAgend",28, .F.) 	//Coluna Grid dos Programas
//oFWLayer:addCollumn( "GridRight",25, .T. , "UpProgramas") 	//Coluna Grid dos Alertas

oPUp	:= oFWLayer:GetLinePanel( "UpAtend" ) // Objeto Panel central
oPDown	:= oFWLayer:GetLinePanel( "DownAgend" ) // Objeto Panel central

oDlgPRO:lMaximized := .T. //Janela maximizada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	MBrowse da dos programas cadastrados        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAlias 	:= "GCY"
cFilter := cFilMA7 //"GCY_FILIAL == '" + xFilial("GCY") + "' .AND. GCY_STATUS = '3' "


oMBrwGCY:= FWMBrowse():New()
oMBrwGCY:SetAlias(cAlias)
oMBrwGCY:SetMenuDef("HSPAHMA7")
oMBrwGCY:SetDescription("Atendimentos")
oMBrwGCY:SetFilterDefault(cFilter)
oMBrwGCY:SetOwner(oPUp)
//oMBrwGCY:DisableDetails()
//oMBrwGCY:DisableConfig()
//oMBrwGCY:DisableFilter()
oMBrwGCY:DisableLocate()
//oMBrwGCY:DisableSeek()
oMBrwGCY:DisableReport()
//oMBrwGCY:lLocate := .T.
oMBrwGCY:SetWalkThru(.F.)
oMBrwGCY:SetAmbiente(.F.)
oMBrwGCY:ForceQuitButton()


oMBrwGCY:AddLegend( "GCY_STATUS == '0' ", "GREEN"	, "Recepcionado"	,,.F. )//Recepcionado
oMBrwGCY:AddLegend( "GCY_STATUS == '1' ", "YELLOW"	, "Pré-Triagem"	,,.F. )//Pré-Triagem
oMBrwGCY:AddLegend( "GCY_STATUS == '2' ", "ORANGE"	, "Anamnese"	,,.F. )//Anamnese
oMBrwGCY:AddLegend( "GCY_STATUS == '3' ", "RED"	, "Anamnese confirmada "	,,.F. )//Anamnese confirmada

oMBrwGCY:Activate()

//oMBrwGCY:Disable()



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	MBrowse da dos pacientes elegiveis/inscritos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("GM8")
cAlias := "GM8"
cFilGm8 :=""
cFilGm8 := "GM8_FILIAL == '" + xFilial("GM8") + "' .AND. GM8_DATAGE == '" + DTOS(DDATABASE) + "' .AND. GM8_CODCRM == '" + aCodUsr[2] + "' .AND. GM8_REGGER <> '" + Space(Tamsx3("GM8_REGGER")[1]) + "'"


oMBrwGM8:= FWMBrowse():New()
oMBrwGM8:SetAlias(cAlias)
oMBrwGM8:SetDescription("Agendamentos")
oMBrwGM8:SetFilterDefault(cFilGm8)
oMBrwGM8:SetOwner(oPDown)
oMBrwGM8:DisableDetails()
oMBrwGM8:DisableConfig()
oMBrwGM8:DisableFilter()
oMBrwGM8:DisableLocate()
//oMBrwGM8:DisableSeek()
oMBrwGM8:DisableReport()
oMBrwGM8:SetAmbiente(.F.)
oMBrwGM8:SetWalkThru(.F.)
oMBrwGM8:SetMenuDef("")
oMBrwGM8:SetDoubleClick ( {|| HS_MA7GEAT()} )

//oMBrwGM8:lLocate := .T.
//oMBrwGM8:ForceQuitButton()
oMBrwGM8:AddLegend( "GM8_STATUS == '0' ", "GRAY"	, "Livre"	,,.F. )
oMBrwGM8:AddLegend( "GM8_STATUS == '1' ", "RED"		, "Ocupado"	,,.F. )
oMBrwGM8:AddLegend( "GM8_STATUS == '2' ", "YELLOW"	, "Bloqueado"	,,.F. )
oMBrwGM8:AddLegend( "GM8_STATUS == '3' ", "PINK"	, "Atendido"	,,.F. )
oMBrwGM8:AddLegend( "GM8_STATUS == '4' ", "BLUE"	, "Ocupado/Bloqueado"	,,.F. )
oMBrwGM8:AddLegend( "GM8_STATUS == '5' ", "ORANGE"	, "Confirmado"	,,.F. )
oMBrwGM8:AddLegend( "GM8_STATUS == '7' ", "BROWN"	, "Em conferencia"	,,.F. )
oMBrwGM8:Activate()



oTimer := TTimer():New(30000, {|| PProRefresh() }, oDlgPRO ) // Disparo será de 30 segundos
oTimer:Activate()

aRotina := MenuDef()

Activate MsDialog oDlgPRO Centered
/*********************************************************************************/



EndIf

SetKey(VK_F12, bKeyF12)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_MA7    ºAutor  ³Eduardo Alves       º Data ³  28/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Funcao de Tratamento da Anamnese.                          ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±º          ³ Integração PLS e Prontuario Eletronico:                    º±±
±±º          ³    lIntPls := .T.                                          º±±
±±º          ³    aDataPls[1] := Codigo Paciente (Carteirinha)            º±±
±±º          ³    aDataPls[2] := Codigo Atendimento PLS(BBD/BTH)          º±±
±±º          ³    aDataPls[3] := Codigo Plano paciente PLSxGH(BI3_HSPPLA) º±±
±±º          ³    aDataPls[4] := Codigo RDA / Medico PLS                  º±±
±±º          ³    aDataPls[5] := Codigo CBO Especialidade Medico PLS      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                                       //*****
Function HS_MntMA7(cAliasMA7, nRegMA7, nOpcMA7, aCposBrw, cTpNasc, nQtdAnm, nVisAnm, lIntPls, aDataPls, lTriagem, lPromo)
Local aArea		:= GetArea()
Local bKeyF6	:=	SetKey(VK_F6)
Local bKeyF7	:=	SetKey(VK_F7)
Local bKeyF8	:=	SetKey(VK_F8)
Local bKeyF12	:=	SetKey(VK_F12)
Local nGDOpc 	:= IIf( Str(aRotina[nOpcMA7, 4], 2) $ "03/04" , GD_INSERT + GD_UPDATE + GD_DELETE, 0)

Local oDlgMa7, nOpcDlg	:= 0
Local oEncGcy, oEncBBD,oEncGbh, oEncGb2, oEncGfu, aJoinGfu := {}, aMntperg := {}
local oGDGfu, aHGfu := {}, aCGfu := {}, nUGfu := nQtdAnm, cCondGfu	:= ""
Local lInclui	:= .F., lConfirma := .F., cGfuTpAnam := "0"
Local aSize		:= {}, aObjects := {}, aInfo := {}, aPPanel := {}, aPInfo := {}, aPGets := {}
Local aButtons	:= {}

Local oFolder, oPanelTop, oPanelBot, oPanelLef, oPanelRig

Local cCDQues 		:= "", cCodEsp := "" //, cDirImg := ""
Local nGfuCdAnam	:= 0, nGfuCdQues := 0, nGfuRegAte := 0, nGfuRegGer := 0
Local cAcesso		:= IIf(Type("__cMa7Aces") <> "U", __cMa7Aces, "G")
Local aRMntQues

Local aLeg 		:= {	{"  HS_VldInte(TMPGFU->GFU_REGATE) == 'I'", "BR_VERDE"},;
						{"  HS_VldInte(TMPGFU->GFU_REGATE) == 'N'", "BR_AZUL"}}
Local aFieldGCY	:= {}, aFolderGCY := {}, aFieldGBH := {}, aFolderGBH := {}, aFieldGB2 := {}, aFolderGB2 := {}, aFieldBBD := {}, aFolderBBD := {}
Local cCond		:= ""
Local oDlgAnm, aAnmRet := {}, nOpcAnm := 0
Local cEspecMed	:= ""
Local cAnmOri	:= ""
Local lReserv   := HS_ExisDic({{"C", "GFU_RESERV"}},.F.)
Local lImagem	:= .F.
Local lCriTriag := .F.  //*****
Local cMsgTri   := ""   //*****
LOCAL lMVPromo  := SuperGetMV("MV_PROSAUD", NIL, .F.)  // Promoção a Saude
LOCAL lMVConf   := SuperGetMV("MV_HSPCANA", NIL, .F.)  // Confirma Anamnese

//Variaveis integração PLS
Local cCodGbh	:= ""
Local cRegAte   := ""
Local cNrSeqG	:= ""
Local cSqlBBD	:= ""
Local cConvPLS	:= ""
Local cErroInt	:= ""
Local cProExclu:=""
Local lCrmExc:=.F.
Local lProfExl:=.f.


If lMVPromo
	Private 	 nRegPromo := nRegMA7
	Private	 aPerPro:={}
	Private	 oMenuPr2 	:= nil
 	Private	 oMenuPr01 	:= nil
	Private	 oMenuPr02 	:= nil
	Private	 oMenuPr03 	:= nil
	Private	 oMenuPr04 	:= nil
	Private	 oMenuPr05 	:= nil
	Private	 oMenuPr06 	:= nil
	Private	 oMenuPr07 	:= nil
	Private	 oMenuPr08 	:= nil
	Private	 oMenuPr09 	:= nil
	Private	 oMenuPr10 	:= nil
	Private	 oMenuPr11 	:= nil
	Private	 oMenuPr12 	:= nil
	Private	 oMenuPr1 	:= nil
	Private  oButtPr2 	:= nil
	Private	 nGetCODPRO	:=0
	Private  nGetVida  	:=0
	Private	 NGETNROSEQ :=0
	Private	 NGETSTATUS	:=0
	Private	 nGetRISCO	:=0
	Private  oGetBOM
	Private  aHeadBOM	:={}
	Private  aColsBOM	:={}
	Private  AlegBOM	:={{"BOM_STATUS == '0'", "BR_AZUL"},;
						{"BOM_STATUS == '1'", "BR_AMARELO"},;
						{"BOM_STATUS == '2'", "BR_VERDE"},;
						{"BOM_STATUS == '3'", "BR_VERMELHO"},;
						{"BOM_STATUS == '5'", "BR_CINZA"}}

EndIf
Private oGDGT8, aHGT8 := {}, aCGT8 := {}, nUGT8 := 0
Private oGDGT8Vis, aHGT8Vis := {}, aCGT8Vis := {}
Private oFolVisImg := Nil
Private nRecBBD	:= 0
Private __cCrmPls	:= ""
Private cDirImg 	:= ""

Private aTelaGcy := {}, aGetsGcy := {}
Private aTelaGbh := {}, aGetsGbh := {}
Private aTelaGb2 := {}, aGetsGb2 := {}
Private aTelaPer := {}, aGetsPer := {}
Private aTelaHis := {}, aGetsHis := {}
Private lExtAnm	 := IIf(Type("lVisExt")<>"U",lVisExt, .F.)
Private cRegPA	 := ""
Private cChaveSRA :=""
Private bOK 	  := {|| nOpcDlg := 1, Iif(nOpcMA7 != 4, IIf(HS_ObrgPer(aMntPerg[3], aMntPerg[2]) , (FS_GrvMA7(lInclui,;
					 IIf(lIntPls,.T.,lConfirma), aCodUsr[2], cGfuTpAnam, aMntPerg[2],;
					 cAcesso, cAnmOri,cCdQues, cTpNasc, lImagem), nOpcDlg := 0, oDlgMa7:End()), nOpcDlg := 0), oDlgMa7:End())}

Private lFilial:=.T.
Private lVerFil	 := HS_ExisDic({{"C", "GBJ_VIFILI"}},.F.)

Default cTpNasc  	:= ""
Default nQtdAnm  	:= 0
Default nVisAnm  	:= 0
Default lIntPls		:= .F.
Default aDataPls	:= {}
Default lTriagem	:= .F.
Default lPromo	:= .F. // Variavel que indica que é abertura da tela apenas para visualizar aba da Promoção

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integração Prontuario Eletronico Gestão Hospitalar com o PLS             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntPls .AND. !Empty(aDataPls)
	If !(nOpcMA7 == 2 .AND. Empty(aDataPls[10]))
		If Empty(cConvPLS := GetNewPar("MV_CONVPLS", ""))
			HS_MSGINF(STR0094,STR0021, STR0022)// "Necessário informar o código do Convênio do Plano de Saude no Gestão Hospitalar (Parametro MV_CONVPLS)!"###"Atenção"###"Inclusão/Retificação de anamnese"
			Return(Nil)
		EndIf

		Hs_TabPLS("A",xFilial("BBD"), .T.)

		DbSelectArea("GA9")
		DbSetOrder(1)
		If DbSeek(xFilial("GA9") + Alltrim(cConvPLS))
			If Empty(GA9->GA9_CRMVIR)
				cErroInt += STR0096  + "CRM Virtual(GA9_CRMVIR) ] " + chr(10)// "Necessário atribuir a informação de integração no Cadastro do Convênio no Gestão Hospitalar [ "###"Atenção"###"Inclusão/Retificação de anamnese"
			EndIf
			If Empty(GA9->GA9_LOCATP)
				cErroInt += STR0096  + "Local Atend Pls(GA9_LOCATP) ] " + chr(10)// "Necessário atribuir a informação de integração no Cadastro do Convênio no Gestão Hospitalar [ "###"Atenção"###"Inclusão/Retificação de anamnese"
			EndIf
			If Empty(GA9->GA9_CDGPLA)
				cErroInt += STR0096  + "Guia Pad Pls(GA9_CDGPLA) ] " + chr(10)// "Necessário atribuir a informação de integração no Cadastro do Convênio no Gestão Hospitalar [ "###"Atenção"###"Inclusão/Retificação de anamnese"
			EndIf
			If Empty(GA9->GA9_CONPLA)
				cErroInt += STR0096  + "Loc Consult Pls(GA9_CONPLA) ] " + chr(10)// "Necessário atribuir a informação de integração no Cadastro do Convênio no Gestão Hospitalar [ "###"Atenção"###"Inclusão/Retificação de anamnese"
			EndIf
			If Empty(GA9->GA9_CLIPAD)
				cErroInt += STR0096  + "Clinica Padr(GA9_CLIPAD) ] " + chr(10)// "Necessário atribuir a informação de integração no Cadastro do Convênio no Gestão Hospitalar [ "###"Atenção"###"Inclusão/Retificação de anamnese"
			EndIf
			If Empty(GA9->GA9_ORIPAD)
				cErroInt += STR0096  + "Origem Padr(GA9_ORIPAD) ] " + chr(10)// "Necessário atribuir a informação de integração no Cadastro do Convênio no Gestão Hospitalar [ "###"Atenção"###"Inclusão/Retificação de anamnese"
			EndIf
			If Empty(GA9->GA9_CARPAD)
				cErroInt += STR0096  + "Carater Padr(GA9_CARPAD) ] " + chr(10)// "Necessário atribuir a informação de integração no Cadastro do Convênio no Gestão Hospitalar [ "###"Atenção"###"Inclusão/Retificação de anamnese"
			EndIf
			If Empty(GetNewPar("MV_EMPRPLS", ""))
				cErroInt += "Preencher parametro MV_EMPRPLS" + chr(10)
			EndIf
			If !Empty(cErroInt)
				HS_MSGINF(cErroInt,STR0021, STR0022)
				Return(Nil)
			EndIf
		Else
			HS_MSGINF(STR0095,STR0021, STR0022)// "Convênio informado no Parametro MV_CONVPLS é invalido!"###"Atenção"###"Inclusão/Retificação de anamnese"
			Return(Nil)
		EndIf

		Hs_TabPLS("F",xFilial("BBD"), .T.)

		cCodGbh := HS_GBHXPLS(aDataPls[1]) // Gera registro na GBH do Cadastro do Beneficiario
		If Empty(aDataPls[10])
			cRegAte	:= HS_GCYXPLS(cCodGbh,aDataPls[2],aDataPls[5], aDataPls[1], aDataPls[11])// Gera registro na GCY do atendimento do paciente
		Else
			cRegAte := aDataPls[10]
		EndIf
		cNrSeqG	:= HS_GCZXPLS(cRegAte,aDataPls[3])	// Gera registro na GCZ da Guia do paciente

		Hs_TabPLS("A",xFilial("BBD"), .T.)

		DbSelectArea("GCY")
		DbSetOrder(1)
		DbSeek(xFilial("GCY") + cRegAte)
		nRegMA7 := GCY->(Recno())
		__cCrmPls := GCY->GCY_CODCRM
		aCodUsr := HS_VldDAnm(.T.)

		If Empty(GCY->GCY_CDATPL) .AND. !Empty(aDataPls[2])
			RecLock("GCY",.F.)
				GCY->GCY_CDATPL := aDataPls[2]
			MsUnlock()
		EndIf

		If HS_ExisDic({{"C", "BBD_ATEHSP"}},.F.)  // Grava numero de atendimento do Gestão Hospitalar na tabela de consultas do PLS
			cSqlBBD := " SELECT R_E_C_N_O_ NRREG FROM " + RetSqlName("BBD") + " WHERE BBD_CODIGO = '" + aDataPls[6] + "'"
			cSqlBBD += " AND BBD_CODINT = '" + aDataPls[7] + "' AND BBD_CODLOC = '" + aDataPls[8] + "'"
			cSqlBBD += " AND BBD_DATA = '" + aDataPls[9] + "' AND BBD_CODPAC = '" + aDataPls[1] + "'"
			cSqlBBD += " AND D_E_L_E_T_ <> '*' AND BBD_FILIAL = '" + xFilial("BBD") + "'"

			cSqlBBD := ChangeQuery(cSqlBBD)
			TCQuery cSqlBBD New Alias "REGBBD"
			DbSelectArea("REGBBD")
			If !Eof()
				While !REGBBD->(Eof())
					nRecBBD := REGBBD->NRREG
					DbSelectArea("BBD")
					DbGoTo(nRecBBD)
					RegToMemory("BBD", .F.)
					IF Empty(BBD->BBD_ATEHSP)
						RecLock("BBD",.F.)
							BBD->BBD_ATEHSP := cRegAte
						MsUnlock()
						Exit
					EndIf

					DbSelectArea("BBD")
					DbGoTo(nRecBBD)
					RegToMemory("BBD", .F.)
					REGBBD->(DbSkip())
				End

			EndIf
			DbSelectArea("REGBBD")
			REGBBD->(DbCloseArea())
		EndIf

		DbSelectArea("GBH")
		DbSetOrder(1)
		DbSeek(xFilial("GBH") + cCodGbh)
		//Atualiza Dados referente a Promoção da Saude
	Else
		HS_MsgInf(STR0023, STR0021, STR0024) //"Não foi encontrada nenhuma anamnese para o atendimento selecionado"###"Atenção"###"Visualização de anamnese/retificadora"
		Return(Nil)
	EndIf
EndIf

//Validacao antes de entrar na tela 
If ExistBlock("HSMA7VLD")
	DbSelectArea("GBH")
	DbSetOrder(1)
	DbSeek(xFilial("GBH") + GCY->GCY_REGGER)

	If !ExecBlock("HSMA7VLD", .F., .F.)
		Return
	EndIf
EndIf

If !HS_ExisDic({{"C", "GMT_CODLOC"}})
	Return(Nil)
EndIf


If Type("aMneSele") # "A"
	Private aMneSele   := {}  //utilizada para armazenar todos os mnemonicos selecionados para cada pergunta
EndIf

If Type("lFilVir") # "L"
	Private lFilVir    := HS_ExisDic({{"C", "GBJ_CRMVIR"}},.F.)
EndIf

If Type("cEspUsu") # "C" .AND. (IIf(Type("cHistPA") # "U", Empty(cHistPA),.T.))
	Private cEspUsu    := HS_REspMed(IIf(!Empty(__cCrmPls),__cCrmPls,aCodUsr[2]))
EndIf

If FunName() # "HSPAHMA7" .AND. (IIf(Type("cHistPA") # "U", Empty(cHistPA),.T.))
	HS_PenMA7("GCY", GCY->(RecNo()), 0)
EndIf

If Empty(__cCrmPls)
	__cCrmPls := GCY->GCY_CODCRM
EndIf

cEspecMed := IIF(lFilVir, "'"+StrTran(cEspUsu,"/","','")+"'","")

If HS_ExisDic({{"C", "GBJ_VISANT"}}, .F.)
	// Mostra tela de antecedentes
	If !lIntPLS .AND. !Empty(__cCrmPls)
		PswOrder(1) // indice por ID
		PswSeek(__CUSERID,.T.)  // Pesquisa o ID no cadastro de usuario
		cChaveSRA := substr(pswret(1)[1,22],3,tamsx3("RA_FILIAL")[1]+tamsx3("RA_MAT")[1])
		// A partir do sra->ra_mat posiciona em gbj->gbj_crm e pega se mostra tela de antecedentes
	EndIf
	If Posicione("GBJ",1,xFilial("GFS") + IIf(!Empty(__cCrmPls),__cCrmPls,Posicione("SRA",1,cChaveSRA,"RA_CODIGO")),"GBJ_VISANT") == '1' .AND. (nOpcMa7 <> 2 .AND. !lPromo)
		HS_AntMA7(cAliasMA7, nRegMA7, nOpcMA7) // Tela de antecedentes
	Endif
EndIf

//Apresenta todos os botões
aButtons := {	{"PRINT02" , {|| FS_DocRel(oGDGfu:aCols[oGDGfu:nAt, nGfuRegAte], oGDGfu:aCols[oGDGfu:nAt, nGfuCdAnam])}, STR0017},; //"Doc/Relat"
				{"S4WB001N", {|| nOpcDlg := 1, Iif(lConfirma := nOpcMA7 == 4, oDlgMa7:End(), IIf(lConfirma := HS_ObrgPer(aMntPerg[3], aMntPerg[2]),;
				oDlgMa7:End(), nOpcDlg := 0))},Iif(lMVPromo ,STR0019, "Confirmar Anam.")}}//Confirmar Anam.

If lMVConf //Confirmar Anamnese
	Aadd(aButtons, {"S4WB001N", bOK, "OK"})
EndIf

If (IIf(Type("cHistPA") # "U", Empty(cHistPA),.T.)) // Se não for historico do Pronto Atendimento adiciona botao de despesas
	Aadd(aButtons, {"S4WB011N", {|| HS_CtrlM24({GCY->GCY_ATENDI, GCY->GCY_REGATE, "P", 7, GCY->GCY_CODLOC, ""})}, STR0018 }) //"Despesas"
EndIf
Aadd(aButtons, {"BR_VERDE_OCEAN", {|| FS_Leg()}, STR0060, STR0016}) //"Intercorrência"###"Legenda"
Aadd(aButtons, {"AUTOM",          {|| HS_M01INT(GCY->GCY_REGATE,,,.F.)}, STR0060, STR0061}) //"Intercorrência"###"Interc."
Aadd(aButtons, {"NOTE",           {|| HS_AntMA7(cAliasMA7, nRegMA7, nOpcMA7)}, STR0076, STR0077}) //"Antecedentes"###"Anteced."
Aadd(aButtons, {"PENDENTE",       {|| HS_M07HIST(cTpNasc)}, STR0068, STR0068}) //"Histórico"###"Histórico"
Aadd(aButtons, {"S4WB005N",       {|| HS_PreMA7(cAliasMA7, nRegMA7, nOpcMA7, cTpNasc)}, STR0064, STR0064}) //
Aadd(aButtons, {"S4WB007N",       {|| HSPAHM08(GCY->GCY_REGATE,,,IIf(Type("nVisPE") # "U" .AND. nVisPE > 0, nVisPE,0)) }, STR0087, STR0088}) //
If (IIf(Type("cHistPA") # "U", Empty(cHistPA),.T.)) .AND. !Empty(cRegPA := FS_VANMPA(GCY->GCY_REGATE,GCY->GCY_CODLOC)) // Verifica se o paciente veio do PA e se existe anamneses no PA
	Aadd(aButtons, {"PARAMETROS_OCEAN",       {|| oDlgMa7:End(),FS_EXANPA(cRegPA)}, "Hist. Pronto Atendimento", "Hist. PA"}) //
EndIf
Aadd(aButtons, {"PENDENTE",       {|| HSPGBHBco(IIf(empty(oGDGfu:aCols[oGDGfu:nAt, nGfuRegGer]),GCY->GCY_REGGER,oGDGfu:aCols[oGDGfu:nAt, nGfuRegGer]))}, "Conhecimento", "Conhecimento"}) //

If ExistBlock("HSPMA7MA")
	aButtons := ACLONE(ExecBlock("HSPMA7MA", .F., .F., {aButtons}))
EndIf

If !lTriagem
	If cAcesso <> 'E' .And. GCY->GCY_ATENDI <> '0' .And. nOpcMA7 <> 2 .And. IIF(lFilVir,HS_IniPadr("GBJ", 1, GCY->GCY_CODCRM, "GBJ_CRMVIR",,.F.) <> "1",.T.) ;
	.And. ((!Empty(GCY->GCY_CRMANM) .And. GCY->GCY_CRMANM <> aCodUsr[2]) .Or. (Empty(GCY->GCY_CRMANM) .And. GCY->GCY_CODCRM <> aCodUsr[2]))
   		HS_MsgInf(STR0020, STR0021, STR0022) //"Somente o médico responsável pelo atendimento tem permissão para realizar uma anamnese normal."###"Atenção"###"Inclusão/Retificação de anamnese"
   		SetKey(VK_F6 , bKeyF6 )
   		SetKey(VK_F7 , bKeyF7 )
   		SetKey(VK_F8 , bKeyF8 )
   		SetKey(VK_F12, bKeyF12)
   		Return(Nil)
	EndIf
Else
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verificacoes padrao                                            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cAcesso <> 'E' .And. GCY->GCY_ATENDI <> '0' .And. nOpcMA7 <> 2 .And. IIF(lFilVir,HS_IniPadr("GBJ", 1, GCY->GCY_CODCRM, "GBJ_CRMVIR",,.F.) <> "1",.T.)

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Verifica se o tipo do usuario logado permite realizar a triagem ou ³
        //³ o usuario logado e o profissional que realizou o atendimento       ³
   	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If !((HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_TIPPRO") $ GetNewPar("MV_HSTRIPR","")) .Or. ( Empty(GCY->GCY_CRMANM).And. GCY->GCY_CODCRM == aCodUsr[2]))
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    	//³ Se a anamnese ja foi preenchida por um medico (GCY_CRMANM) critica ³
	   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If (!Empty(GCY->GCY_CRMANM) .And. GCY->GCY_CRMANM <> aCodUsr[2])
	            lCriTriag := .T.
	            cMsgTri := STR0097 //"O usuario logado nao e o medico que realizou o atendimento ou um profissional de enfermagem autorizado."
	        EndIf
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    	//³ Se vinculo funcional vazio critica                                 ³
	   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		If !lCriTriag .And. Empty(aCodUsr[2])
	   		    lCriTriag := .T.
	            cMsgTri := STR0098 //"Usuário sem vínculo funcional cadastrado."
	   		EndIf

        EndIf

        If lCriTriag
            HS_MsgInf(cMsgTri, STR0021, STR0022) //"Somente o médico responsável pelo atendimento tem permissão para realizar uma anamnese normal."###"Atenção"###"Inclusão/Retificação de anamnese"
   			SetKey(VK_F6 , bKeyF6 )
   			SetKey(VK_F7 , bKeyF7 )
   			SetKey(VK_F8 , bKeyF8 )
   			SetKey(VK_F12, bKeyF12)
   			Return(Nil)
        EndIf
    EndIf
EndIf

If IIF(Len(aCodUsr) > 2,aCodUsr[3],.F.) .And.  IIF(lFilVir,HS_IniPadr("GBJ", 1, GCY->GCY_CODCRM, "GBJ_CRMVIR",,.F.) == "1" .And. !Hs_CompEsp(GCY->GCY_CODCRM,aCodUsr[2]),.F.)
	HS_MsgInf(STR0084, STR0021, STR0022) //"Especialidades do Profissional logado incompativeis com especialidades do Profissional do Atendimento"###"Atenção"###"Inclusão/Retificação de anamnese"
	SetKey(VK_F6 , bKeyF6 )
	SetKey(VK_F7 , bKeyF7 )
	SetKey(VK_F8 , bKeyF8 )
	SetKey(VK_F12, bKeyF12)
	Return(Nil)
EndIf

If nOpcMA7 == 2 // Visualizar
	If	!HS_PosGfu(GCY->GCY_REGATE, aCodUsr[2], "11") .And. ; // Procura anamnese retificadora confirmada
		!HS_PosGfu(GCY->GCY_REGATE, aCodUsr[2], "10") .And. ; // Procura anamnese retificadora aberta
		!HS_PosGfu(GCY->GCY_REGATE, aCodUsr[2], "01") .And. ; // Procura anamnese fechada
		!HS_PosGfu(GCY->GCY_REGATE, aCodUsr[2], "00")         // Procura anamnese aberta
		If (IIf(Type("cHistPA") # "U", Empty(cHistPA),.T.))
			HS_MsgInf(STR0023, STR0021, STR0024) //"Não foi encontrada nenhuma anamnese para o atendimento selecionado"###"Atenção"###"Visualização de anamnese/retificadora"
		EndIf
		If HS_ExisDic({{"C", "GFS_DIRIMG"}},.F.)
			cDirImg := Alltrim(HS_IniPadr("GFS", 1, GFU->GFU_CDQUES, "GFS_DIRIMG",,.F.))
		EndIf
		SetKey(VK_F6 , bKeyF6 )
		SetKey(VK_F7 , bKeyF7 )
		SetKey(VK_F8 , bKeyF8 )
		SetKey(VK_F12, bKeyF12)
		If (IIf(Type("cHistPA") # "U", Empty(cHistPA),.T.))
			Return(Nil)
		EndIf
	EndIf
ElseIf nOpcMA7 == 3 // Anamnese
	cGfuTpAnam := "0"
	If Fs_EscAnm(GCY->GCY_REGATE, @lInclui, "0", "0",@aAnmRet)[1] == 0
		SetKey(VK_F6 , bKeyF6 )
		SetKey(VK_F7 , bKeyF7 )
		SetKey(VK_F8 , bKeyF8 )
		SetKey(VK_F12, bKeyF12)
		Return(Nil)
	EndIf
ElseIf nOpcMA7 == 4 // Retificadora
	cGfuTpAnam := "1"
	aAux := Fs_EscAnm(GCY->GCY_REGATE, @lInclui, "1", "0",@aAnmRet)
	If aAux[1] == 0//Cancelar
		SetKey(VK_F6 , bKeyF6 )
		SetKey(VK_F7 , bKeyF7 )
		SetKey(VK_F8 , bKeyF8 )
		SetKey(VK_F12, bKeyF12)
		Return(Nil)
	ElseIf aAux[1] == 2//Incluir
		aAuxRet := aClone(aAnmRet)
		aAnmRet := {}
		If Alltrim(Str((aAux := Fs_EscAnm(GCY->GCY_REGATE, @lInclui, "0", "1",@aAnmRet, .F.))[1])) $ "0/2"
			If aAux[1] == 2
				HS_MsgInf("Nenhuma anamnese está confirmada. Impossível realizar 'Retificadora'", STR0021, STR0028) //"Para fazer a primeira anamnese do atendimento utilize a opção [Anamnese]."###"Atenção"###"Inclusão de anamnese retificadora."
			EndIf
			SetKey(VK_F6 , bKeyF6 )
			SetKey(VK_F7 , bKeyF7 )
			SetKey(VK_F8 , bKeyF8 )
			SetKey(VK_F12, bKeyF12)
			Return(Nil)
		EndIf

		aAnmRet:= aClone(aAuxRet)
		cCdQues := GFU->GFU_CDQUES
		If HS_ExisDic({{"C", "GFS_DIRIMG"}},.F.)
			cDirImg := Alltrim(HS_IniPadr("GFS", 1, GFU->GFU_CDQUES, "GFS_DIRIMG",,.F.))
		EndIf
		cAnmOri := GFU->GFU_CDANAM
		lInclui := .T.
	EndIf
EndIf

If Empty(cCdQues)
	If Empty(GFU->GFU_CDQUES)
		cCond :="GFS.GFS_FILIAL = '" + xFilial("GFS") + "' AND GFS.D_E_L_E_T_ <> '*' "
		cCond +="					AND (GFS_CODCRM = '"+aCodUsr[2]+"' OR GFS_CODCRM = '') "
		cCond +="				  AND (GFS_CODESP IN "
		cCond +="							( "+cEspecMed+"	) OR GFS_CODESP = '')"
		cCond +="					AND (GFS_TIPPRO = '"+HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_TIPPRO",, .F.)+"' OR GFS_TIPPRO = '') "

		If Hs_ExisDic({{"C","GFS_CODLOC"}},.F.)
			cCond +="					AND (GFS_CODLOC = '"+GCY->GCY_CODLOC+"' OR GFS_CODLOC = '') "
		EndIF

		cCdQues := (aRMntQues := HS_MntQues(cCond))[1]
		cDirImg := alltrim(aRMntQues[3])
	Else
		cCdQues := GFU->GFU_CDQUES
		If HS_ExisDic({{"C", "GFS_DIRIMG"}},.F.)
			cDirImg := Alltrim(HS_IniPadr("GFS", 1, GFU->GFU_CDQUES, "GFS_DIRIMG",,.F.))
		EndIf
	EndIf
Endif

If Empty(cCdQues)
	If !Empty(aRMntQues) .And. !aRMntQues[2]
		HS_MsgInf(STR0030, STR0021, STR0031) //"Nenhum questionário foi encontrado para os parâmetros (médico, especialidade e tipo de profissional) informados."###"Atenção"###"Localizando questionário para anamnese."
	EndIf
	SetKey(VK_F6 , bKeyF6 )
	SetKey(VK_F7 , bKeyF7 )
	SetKey(VK_F8 , bKeyF8 )
	SetKey(VK_F12, bKeyF12)
	Return(Nil)
Else
	If lInclui .And. aAnmRet[1] .And. !Fs_VQueEsp(cCdQues, aAnmRet[3], aAnmRet[4])
		HS_MsgInf("Atendimento possui questionário aberto para a mesma especialidade do questionário escolhido.", STR0021, "Validação Questionário")
		SetKey(VK_F6 , bKeyF6 )
		SetKey(VK_F7 , bKeyF7 )
		SetKey(VK_F8 , bKeyF8 )
		SetKey(VK_F12, bKeyF12)
		Return(Nil)
	EndIf
EndIf

If !HS_VldQues(cCDQues, cAcesso)
	HS_MsgInf(STR0032 + cCDQues + "]", STR0021, "HS_MntPerg") //"Não foi encontrado nenhuma pergunta para o questionário ["###"Atenção"
	SetKey(VK_F6 , bKeyF6 )
	SetKey(VK_F7 , bKeyF7 )
	SetKey(VK_F8 , bKeyF8 )
	SetKey(VK_F12, bKeyF12)
	RestArea(aArea)
	Return(Nil)
EndIf

If !lInclui
	HS_BusResp("GFK", {{"GFK->GFK_CDANAM", GFU->GFU_CDANAM}, {"GFK->GFK_CDQUES", GFU->GFU_CDQUES}}, "PER")
EndIf

cCondGfu := "GFU->GFU_REGGER = '" + GCY->GCY_REGGER + "' AND GFU->GFU_STANAM = '1' "
If Type("cHistPA") # "U" .AND. !Empty(cHistPA)
	cCondGfu += " AND GFU->GFU_REGATE = '" + cHistPA + "' "
EndIf

If lReserv
	If Empty(cTpNasc)
		cCondGfu += " AND (GFU->GFU_RESERV = '" + cTpNasc + "' OR GFU->GFU_RESERV = 'Y' ) "
	Else
		cCondGfu += " AND GFU->GFU_RESERV = '" + cTpNasc + "' "
	EndIf
Endif

If nVisAnm == 1 // 1-Não visualiza anamneses de outro profissional
	cCondGfu += " AND GFU->GFU_CODCRM = '" + aCodUsr[2] + "'"
EndIf

If  lMVPromo 
	If GBJ->( FieldPos('GBJ_PROEXC') ) > 0
	If lCrmExc:=Iif(lProfExl,HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_PROEXC",,.F.) <> "1",.T.) // 1-Profissional não é Exclusivo
		cProExclu:=Fs_CrmExcl()
		cCondGfu +=  " AND GFU->GFU_CODCRM NOT IN (" + cProExclu + ")"
		EndIf
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se tiver configurado para exibir as anamnese de outras filiais     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
iF lVerFil
	lFilial:=Iif(lVerFil,HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_VIFILI",,.F.) <> "1",.T.)
Else
	lFilial:=.T.
Endif

aJoinGfu := {{" JOIN " + RetSqlName("GCY") + " GCY", "GCY.GCY_ATENDI",  Iif(lFilial,"GCY.GCY_FILIAL = '" + xFilial("GCY")+"' AND","")+"  GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GFU.GFU_REGATE", "GFU_ATENDI"}}


HS_BDados("GFU", @aHGfu, @aCGfu, @nUGfu, 1,lFilial, cCondGfu,, "GFU_STAINT",,,,,,,, aLeg,,,,,, aJoinGfu,, "GFU_DATCON DESC,GFU_CDANAM DESC")
nGfuCdAnam := aScan(aHGfu, {| aVet | aVet[2] == "GFU_CDANAM"})
nGfuCdQues := aScan(aHGfu, {| aVet | aVet[2] == "GFU_CDQUES"})
nGfuRegAte := aScan(aHGfu, {| aVet | aVet[2] == "GFU_REGATE"})
nGfuRegGer := aScan(aHGfu, {| aVet | aVet[2] == "GFU_REGGER"})

// Joga dados do atendimento na memoria
DbSelectArea("GCY")
RegToMemory("GCY", .F.)

// Joga dados do paciente na memoria
DbSelectArea("GBH")
DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
DbSeek(xFilial("GBH") + GCY->GCY_REGGER)
RegToMemory("GBH", .F.)

If lReserv .And. !Empty(cTpNasc)
	// Joga dados do paciente na memoria
	DbSelectArea("GB2")
	DbSetOrder(1) //GB2_REGATE + GB2_TPNASC
	DbSeek(xFilial("GB2") + GCY->GCY_REGATE + cTpNasc)
	RegToMemory("GB2", .F.)
Endif

aSize 			:= MsAdvSize(.T.)

aObjects := {}
aAdd( aObjects, { 100, 040, .T., .T., .T.} )
aAdd( aObjects, { 100, 060, .T., .T., .T.} )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
aAdd( aObjects, { 050, 100, .T., .T., .T.} )
aAdd( aObjects, { 050, 100, .T., .T.} )

aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0, 0 }
aPInfo := MsObjSize( aInfo, aObjects, .T., .T., .T.)

aObjects := {}
aAdd( aObjects, { 050, 100, .T., .T.} )
aAdd( aObjects, { 050, 100, .T., .T.} )

aInfo  := { aPPanel[2, 2], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4], 0, 0 }
aPGets := MsObjSize( aInfo, aObjects, .T., .T.)

DEFINE MSDIALOG oDlgMa7 TITLE OemToAnsi(IIf(Type("cHistPA") # "U" .AND. !Empty(cHistPA),"Historico de Anamnese no Pronto Atendimento",STR0005)) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Anamnese"

	/* Panels para manipulação do tamanho da Tela */
	oPanelTop	:=	tPanel():New(aPPanel[1, 1], aPPanel[1, 2],, oDlgMa7,,,,,,	aPPanel[1, 3],	aPPanel[1, 4])
	oPanelTop:Align := CONTROL_ALIGN_TOP

	oPanelBot	:=	tPanel():New(aPPanel[2, 1], aPPanel[2, 2],, oDlgMa7,,,,,, aPPanel[2, 3], aPPanel[2, 4])
	oPanelBot:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelLef	:=	tPanel():New(aPPanel[2, 1], aPPanel[2, 2],, oPanelBot,,,,,, aPPanel[2, 3]/2, aPPanel[2, 4])
	oPanelLef:Align := CONTROL_ALIGN_LEFT

	oPanelRig	:=	tPanel():New(aPPanel[2, 1] + 10, aPPanel[2, 2],, oPanelBot,,,,,, aPPanel[2, 3]/2, aPPanel[2, 4])
	oPanelRig:Align := CONTROL_ALIGN_RIGHT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este Botão oBtnCnf é Utilizado na Promoção da Saúde e seu posicionamento em tela está definido estrategicamente																³
	//³ tem por Objetivo setar o ultimo campo da anamnese para a gravação 																												³
	//³ e é utilizado pelos Profissionais de Saúde da Promoção como um Botão Rápido para a agravação das Anamneses.																	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lMVPromo
		oBtnCnf := tButton():New(aPPanel[2, 1] + 1, (aPPanel[2, 3]/2)-60, "Confirmar Anam.", oDlgMa7, {|| nOpcDlg := 1, Iif(lConfirma := nOpcMA7 == 4, oDlgMa7:End(), IIf(lConfirma := HS_ObrgPer(aMntPerg[3], aMntPerg[2]), oDlgMa7:End(), nOpcDlg := 0))}, 060, 008,,,, .T.)    //"Efetiva"
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel: oPanelTop - aPInfo[1] Dados do Atendimento	/ Dados do Paciente																																																																																															³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReserv .And. !Empty(cTpNasc)
		@ aPInfo[1, 1], aPInfo[1, 2] FOLDER oFolder SIZE aPInfo[1, 3], aPInfo[1, 4] Pixel OF oPanelTop Prompts "RN", STR0034, STR0033 //"&1-Paciente"###"&2-Atendimento"
	Else
		@ aPInfo[1, 1], aPInfo[1, 2] FOLDER oFolder SIZE aPInfo[1, 3], aPInfo[1, 4] Pixel OF oPanelTop Prompts STR0034, STR0033 //"&1-Paciente"###"&2-Atendimento"
	Endif
	oFolder:Align := CONTROL_ALIGN_LEFT

	If lReserv .And. !Empty(cTpNasc)
		FS_AdField("GB2", @aFieldGB2, @aFolderGB2, MV_PAR01)
		oEncGb2 := MsMget():New("GB2", GB2->(RecNo()), 2,,,,, aPInfo[1],,,,,, oFolder:aDialogs[1],,,, "aTelaGb2",, .T., aFieldGB2, aFolderGB2)
		oEncGb2:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	Endif

	FS_AdField("GBH", @aFieldGBH, @aFolderGBH, GCY->GCY_CODLOC)
	oEncGbh := MsMget():New("GBH", GBH->(RecNo()), 2,,,,, aPInfo[1],,,,,, IIF(lReserv .And. !Empty(cTpNasc), oFolder:aDialogs[2], oFolder:aDialogs[1]),,,, "aTelaGbh",, .T., aFieldGBH, aFolderGBH)
	oEncGbh:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	If lIntPls .AND. nRecBBD > 0 // Aba de atendimento com os dados do atendimento no PLS
		FS_AdField("BBD", @aFieldBBD, @aFolderBBD, GCY->GCY_CODLOC)
		oEncBBD := MsMget():New("BBD", nRecBBD, 2,,,,, aPInfo[1],,,,,, oFolder:aDialogs[2],,,, "aTelaGcy",, .T., aFieldBBD, aFolderBBD)
		oEncBBD:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		FS_AdField("GCY", @aFieldGCY, @aFolderGCY, GCY->GCY_CODLOC)
		oEncGcy := MsMget():New("GCY", GCY->(RecNo()), 2,,,,, aPInfo[1],,,,,, IIF(lReserv .And. !Empty(cTpNasc), oFolder:aDialogs[3], oFolder:aDialogs[2]),,,, "aTelaGcy",, .T., aFieldGCY, aFolderGCY)
		oEncGcy:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel: oPanelLef	- Questinarios																																																																																																																																					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !Empty(cDirImg)
		IF !lMVPromo
			@ aPInfo[1, 1] , aPInfo[1, 2] FOLDER oFolGetsImg SIZE aPInfo[1, 3] , aPInfo[1, 4] + 90 Pixel OF oPanelLef Prompts "Questionário", "Imagem" //"&1-Paciente"###"&2-Atendimento"
		Else

			@ aPInfo[1, 1] , aPInfo[1, 2] FOLDER oFolGetsImg SIZE aPInfo[1, 3] , aPInfo[1, 4] + 90 Pixel OF oPanelLef Prompts "Questionário", "Imagem","Promoção da Saude" //"&1-Paciente"###"&2-Atendimento"

		Endif

		@ aPInfo[1, 1] , aPInfo[1, 2] FOLDER oFolVisImg SIZE aPInfo[1, 3] , aPInfo[1, 4] + 90 Pixel OF oPanelRig Prompts "Questionário", "Imagem" //"&1-Paciente"###"&2-Atendimento"
		aMntperg := HS_MntPerg(cCDQues, oFolGetsImg:aDialogs[1],, aPGets[1], nOpcMA7 == 2, "PER", "oEncPer",, "aTelaPer", CONTROL_ALIGN_ALLCLIENT, .T., cAcesso)

		If Len(oEncPer:aEntryCtrls) > 0
			oEncPer:aEntryCtrls[1]:SetFocus()
		EndIf
	Else
		If !lMVPromo
			aMntperg := HS_MntPerg(cCDQues, oPanelLef,, aPGets[1], nOpcMA7 == 2, "PER", "oEncPer",, "aTelaPer", CONTROL_ALIGN_ALLCLIENT, .T., cAcesso)
		Else
			@ aPInfo[1, 1] , aPInfo[1, 2] FOLDER oFolGetsImg SIZE aPInfo[1, 3] , aPInfo[1, 4] + 90 Pixel OF oPanelLef Prompts "Questionário", "Promoção da Saude" //"&1-Paciente"###"&2-Atendimento"
			aMntperg := HS_MntPerg(cCDQues, oFolGetsImg:aDialogs[1],, aPGets[1], nOpcMA7 == 2, "PER", "oEncPer",, "aTelaPer", CONTROL_ALIGN_ALLCLIENT, .T., cAcesso)
		Endif

		If Len(oEncPer:aEntryCtrls) > 0
			oEncPer:aEntryCtrls[1]:SetFocus()
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel: oPanelTop	- oPInfo[2] Anamneses																																																																																																																																								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oGDGfu := MsNewGetDados():New(aPInfo[2, 1], aPInfo[2, 2], aPInfo[2, 3], aPInfo[2, 4], 0,,,,,,,,,, oPanelTop, aHGfu, aCGfu)
	oGDGfu:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
	If !Empty(oGDGfu:aCols[1, nGfuCDQues])
		If !Empty(cDirImg)
	   		oGDGfu:oBrowse:bChange := {|| oFolVisImg:nOption := 1, oFolVisImg:Refresh(), HS_BusResp("GFK", {{"GFK->GFK_CDANAM", oGDGfu:aCols[oGDGfu:nAt, nGfuCDAnam]}, {"GFK->GFK_CDQUES", oGDGfu:aCols[oGDGfu:nAt, nGfuCDQues]}}, "HIS"), ;
			HS_MntPerg(oGDGfu:aCols[oGDGfu:nAt, nGfuCDQues], oFolVisImg:aDialogs[1],, aPGets[2], .T., "HIS", "oEncHis",, "aTelaHis", CONTROL_ALIGN_ALLCLIENT, .F., "G"/*cAcesso*/) , FS_VISIMG(oGDGfu:aCols[oGDGfu:nAt, nGfuCDAnam])}
			oGDGfu:oBrowse:BlDblClick := {|| FS_DespAte(oGDGfu:aCols[oGDGfu:nAt, nGfuRegAte])}
		Else
			oGDGfu:oBrowse:bChange := {|| HS_BusResp("GFK", {{"GFK->GFK_CDANAM", oGDGfu:aCols[oGDGfu:nAt, nGfuCDAnam]}, {"GFK->GFK_CDQUES", oGDGfu:aCols[oGDGfu:nAt, nGfuCDQues]}}, "HIS"), ;
			HS_MntPerg(oGDGfu:aCols[oGDGfu:nAt, nGfuCDQues], oPanelRig,, aPGets[2], .T., "HIS", "oEncHis",, "aTelaHis", CONTROL_ALIGN_ALLCLIENT, .F., "G"/*cAcesso*/)}
			oGDGfu:oBrowse:BlDblClick := {|| FS_DespAte(oGDGfu:aCols[oGDGfu:nAt, nGfuRegAte])}
		EndIf
	EndIf
	If !Empty(cDirImg)
		oFolVisImg:bChange    := {|| Iif(oFolVisImg:nOption == 2,oGDGt8Vis:oBrowse:SetFocus(),Nil) , Iif(oFolVisImg:nOption == 2,FS_ATUIMG(oGDGt8Vis:aCols[1, nGT8Arquiv],.T.),Nil)}
		oTScrollBox :=  TScrollBox():New(oFolGetsImg:aDialogs[2],60,0,160,270,.T.,.T.,.T.)
		oTScrollVis :=  TScrollBox():New(oFolVisImg:aDialogs[2],60,0,160,270,.T.,.T.,.T.)
		lImagem := .T.
		HS_BDados("GT8", @aHGt8, @aCGt8, @nUGt8, 1,, "GT8->GT8_CHAVE = '" + IIf(!lInclui,GFU->GFU_CDANAM,"000000") + "'",, ,,,,,,,, ,,,,,, ,, )
		HS_BDados("GT8", @aHGt8Vis, @aCGt8Vis,, 1,, "GT8->GT8_CHAVE = '" + oGDGfu:aCols[oGDGfu:nAt, nGfuCDAnam] + "'",, ,,,,,,,, ,,,,,, ,, )
		nGT8Arquiv := aScan(aHGt8, {| aVet | aVet[2] == "GT8_ARQUIV"})

		oGDGt8 := MsNewGetDados():New(aPInfo[2, 1]+10, aPInfo[2, 2]+10, aPInfo[2, 3] - 80, aPInfo[2, 4] - 50, GD_INSERT + GD_DELETE,,,,,,,,,, oFolGetsImg:aDialogs[2], aHGt8, aCGt8)
		oGDGt8:oBrowse:align := CONTROL_ALIGN_TOP
		If !(nOpcMA7 == 2)
			oGDGt8:oBrowse:BlDblClick := {|| FS_ALTIMG(oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv], cDirImg)}
     		oGDGt8:oBrowse:bAdd    := {|| FS_AddLin(cDirImg)}
		EndIf
		oGDGt8:oBrowse:bGotFocus := {|| FS_ATUIMG(oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv])}
		oGDGt8:oBrowse:bChange := {|| FS_ATUIMG(oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv])}
     	//oGDGt8:oBrowse:bDelete := {|| HS_GDAtrib(oGDTD, {{nTDStaReg, "BR_CINZA", "BR_VERDE"}}), oGDTD:DelLine()}
     	oGDGt8:lChgField := .F.

		oGDGt8Vis := MsNewGetDados():New(aPInfo[2, 1]+10, aPInfo[2, 2]+10, aPInfo[2, 3] - 80, aPInfo[2, 4] - 50, 0,,,,,,,,,, oFolVisImg:aDialogs[2], aHGt8Vis, aCGt8Vis)
		oGDGt8Vis:oBrowse:align := CONTROL_ALIGN_TOP
		oGDGt8Vis:oBrowse:bGotFocus := {|| FS_ATUIMG(oGDGt8Vis:aCols[oGDGt8Vis:nAt, nGT8Arquiv],.T.)}
		oGDGt8Vis:oBrowse:bChange := {|| FS_ATUIMG(oGDGt8Vis:aCols[oGDGt8Vis:nAt, nGT8Arquiv],.T.)}
     	oGDGt8Vis:lChgField := .F.

		oTBitmap1 := TBitmap():New(01,01,900,900,,oGDGt8:aCols[oGDGt8:nAt, nGT8Arquiv],.T.,oTScrollBox,,,.F.,.F.,,,.F.,,.T.,,.F.)
	    oTBitmap1:lAutoSize := .F.

		oTBitmap2 := TBitmap():New(01,01,900,900,,oGDGt8Vis:aCols[oGDGt8Vis:nAt, nGT8Arquiv],.T.,oTScrollVis,,,.F.,.F.,,,.F.,,.T.,,.F.)
	    oTBitmap2:lAutoSize := .F.

	EndIf
	If lMVPromo
		PLSFOPRO(aPInfo[1, 1],aPInfo[1, 2],aPInfo[2, 3]+50,aPInfo[2, 4]/2, oFolGetsImg:aDialogs[IIf(Empty(cDirImg),2,3)],"", aCodUsr[2], GCY->GCY_CODLOC)
 	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Panel: oPanelRig	- Historico das Anamneses																																																																																																																										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !Empty(oGDGfu:aCols[1, nGfuCDQues])
		HS_BusResp("GFK", {{"GFK->GFK_CDANAM", oGDGfu:aCols[1, nGfuCDAnam]}, {"GFK->GFK_CDQUES", oGDGfu:aCols[1, nGfuCDQues]}}, "HIS")
		If !Empty(cDirImg)
			HS_MntPerg(oGDGfu:aCols[1, nGfuCDQues], oFolVisImg:aDialogs[1],, aPGets[2], .T., "HIS", "oEncHis",, "aTelaHis", CONTROL_ALIGN_ALLCLIENT, .F., "G"/*cAcesso*/)
		Else
			HS_MntPerg(oGDGfu:aCols[1, nGfuCDQues], oPanelRig,, aPGets[2], .T., "HIS", "oEncHis",, "aTelaHis", CONTROL_ALIGN_ALLCLIENT, .F., "G"/*cAcesso*/)
		EndIf
	EndIf

	If lMVPromo
		PLSFOREFR(GCY->GCY_REGGER)
 		If nOpcMa7 == 2
	 		If Empty(cDirImg) .AND. lPromo // foca no registro da promoção da saúde
	 			oFolGetsImg:nOption := 2
	 		ElseIf !Empty(cDirImg)  .AND. lPromo
	 			oFolGetsImg:nOption := 3
	 		EndIf
	 	EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada - Apos o OK da Anamnese       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("HSMA7ANT")
		ExecBlock("HSMA7ANT", .F., .F., {nOpcMa7, cCDQues})
	EndIf
If lExtAnm
	ACTIVATE MSDIALOG oDlgMa7 ON INIT EnchoiceBar (oDlgMa7,	{|| nOpcDlg := 1, oDlgMa7:End() }, ;
 															{|| nOpcDlg := 0, oDlgMa7:End() },,{{"PRINT02" , {|| FS_DocRel(oGDGfu:aCols[oGDGfu:nAt, nGfuRegAte], oGDGfu:aCols[oGDGfu:nAt, nGfuCdAnam])}, STR0017}})
Else
	ACTIVATE MSDIALOG oDlgMa7 ON INIT EnchoiceBar (oDlgMa7,	{|| nOpcDlg := 1, Iif(nOpcMA7 != 4, IIf(HS_ObrgPer(aMntPerg[3], aMntPerg[2]) , oDlgMa7:End(), nOpcDlg := 0), oDlgMa7:End())},;
															{|| nOpcDlg := 0, oDlgMa7:End()},, aButtons)
Endif
If (nOpcDlg == 1) .And. IIf(!lIntPls,(AllTrim(STR(aRotina[nOpcMA7, 4])) $ "3/4"),.T.) .AND. (IIf(Type("cHistPA") # "U",Empty(cHistPA),.T.))
//	Begin Transaction
	If lMVConf
	   	FS_GrvMA7(lInclui, IIf(lIntPls,.T.,.T.), aCodUsr[2], cGfuTpAnam, aMntPerg[2], cAcesso, cAnmOri, cCdQues, cTpNasc, lImagem)
	Else
		FS_GrvMA7(lInclui, IIf(lIntPls,.T.,lConfirma), aCodUsr[2], cGfuTpAnam, aMntPerg[2], cAcesso, cAnmOri, cCdQues, cTpNasc, lImagem)
	EndIf

//	End Transaction
	If lConfirma .AND. !lIntPls
		HS_RelMa7(cAliasMa7, nRegMa7, nOpcMa7)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Apos o OK da Anamnese       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("HSPMA7OK")
	ExecBlock("HSPMA7OK", .F., .F., {nOpcDlg, lConfirma})
EndIf
SetKey(VK_F6 , bKeyF6 )
SetKey(VK_F7 , bKeyF7 )
SetKey(VK_F8 , bKeyF8 )
SetKey(VK_F12, bKeyF12)

If lIntPls .AND. Type("__nOpcAnmGH")<>"U"
	__cRegAtGh 	:= GCY->GCY_REGATE //Variaveis utilizadas no PLSA305
	__nOpcAnmGH := nOpcDlg
EndIf

RestArea(aArea)
DbSelectArea("GCY")
DbGoTop()
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_EncMa7 ºAutor  ³Eduardo Alves       º Data ³  07/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para Encaminhar Anamnese.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_EncMa7(cAliasMA7, nRegMA7, nOpcMA7)
Local bKeyF6	:=	SetKey(VK_F6)
Local bKeyF7	:=	SetKey(VK_F7)
Local bKeyF8	:=	SetKey(VK_F8)
Local bKeyF12	:=	SetKey(VK_F12)
Local aArea 	:= GetArea()
Local oDlgMA7, oEncGfu
Local aTela 	:= {}, aGets := {}
Local aSize 	:= {}, aObjects := {}, aInfo := {}, aPGets := {}
Local oObjMBrw 	:= GetObjBrow()
Local aAnm 		:=  {}, aRetif :=  {}, nPos := 0

/* Verifica se o Usuario pode encaminhar um anamnese */

If	Fs_RetAnms(GCY->GCY_REGATE, "0", "0")[1] .Or. ; // Procura anamnese aberta
	Fs_RetAnms(GCY->GCY_REGATE, "1", "0")[1]        // Procura anamnese retificadora aberta
	HS_MsgInf("Há anamnese(s) sem confirmação. Operação cancelada.", STR0021, STR0024) //"Há anamnese(s) sem confirmação. Operação cancelada."###"Atenção"###"Visualização de anamnese/retificadora"
Else
	aAnm   :=  Fs_RetAnms(GCY->GCY_REGATE, "0", "1")
	aRetif :=  Fs_RetAnms(GCY->GCY_REGATE, "1", "1")

	nPos := aScan(aAnm[3], {|aVet| aVet[2] == "GFU_CDANAM"})

	aSort( aAnm[4],,,{|x,y| x[nPos] > y[nPos] })

	aSort( aRetif[4],,,{|x,y| x[nPos] > y[nPos] })

	If Select("GFU") > 0
		GFU->(DbCloseArea())
	EndIf
	DbSelectArea("GFU")
	GFU->(DbSetOrder(1))
	If GFU->(DbSeek(xFilial("GFU") + IIF(aAnm[4, 1, nPos] > aRetif[4, 1, nPos], aAnm[4, 1, nPos],aRetif[4, 1, nPos])))
		RegToMemory("GFU", .F.)
	Else
		HS_MsgInf(STR0089, STR0021, STR0036) //"Não há confirmação de anamnese para este atendimento. Operação cancelada."###"Atenção"###"Visualização de anamnese/retificadora"
		Return(Nil)
	EndIf

	aSize := MsAdvSize(.T.)

	aObjects := {}
	aAdd( aObjects, { 100, 100, .T., .T.} )

	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPGets := MsObjSize( aInfo, aObjects, .T., .T.)

	DEFINE MSDIALOG oDlgMa7 TITLE OemToAnsi(STR0009) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Encaminhar"

		oEncGfu := MsMget():New("GFU", RecNo(), nOpcMA7,,,,, aPGets[1], {"GFU_CODCRM"},,,,, oDlgMA7) //,,,,,, .T.)
		oEncGfu:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		oEncGfu:AENTRYCTRLS[aScan(oEncGfu:aGets, {| aVet | "GFU_CODCRM" $ aVet})]:BLOSTFOCUS := {|| HS_VldMa7(1)}

	ACTIVATE MSDIALOG oDlgMa7 ON INIT EnchoiceBar (oDlgMa7,	{|| nOpcMA7 := 1, IIf(Obrigatorio(aGets, aTela), oDlgMa7:End(), nOpcMA7 := 0)},;
                                                 									{|| nOpcMA7 := 0, oDlgMa7:End()})

	If nOpcMa7 == 1
		If Select("GCY") > 0
			GCY->(DbCloseArea())
		EndIf
		DbSelectArea("GCY")
		GCY->(DbSetOrder(1)) // GCY_FILIAL + GCY_REGATE
		GCY->(DbSeek(xFilial("GCY") + M->GFU_REGATE))
		RecLock("GCY", .F.)
			GCY->GCY_CRMANM := M->GFU_CODCRM
		MsUnLock()
	EndIf
EndIf

SetKey(VK_F6 , bKeyF6 )
SetKey(VK_F7 , bKeyF7 )
SetKey(VK_F8 , bKeyF8 )
SetKey(VK_F12, bKeyF12)


oMBrwGCY:CleanFilter()
oMBrwGCY:SetFilterDefault(cFilMa7)
GCY->(DbGoTop())
oMBrwGCY:Refresh()
	
// MsgRun(STR0039, STR0040, {|| SetMBTopFilter("GCY", cFilMA7), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando as anamneses..."###"Seleção de registros"
//MsgRun(STR0039, STR0040, {|| DbSetFilter( { || .T. }, '@' + cFilMA7 ), oMBrwGCY:GoTop(), oMBrwGCY:Refresh()}) //"Selecionando as anamneses..."###"Seleção de registros"

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ExcMa7 ºAutor  ³Eduardo Alves       º Data ³  07/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para Excluir Anamnese.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ExcMa7(cAliasMA7, nRegMA7, nOpcMA7)
	Local bKeyF6		:=	SetKey(VK_F6)
 Local bKeyF7		:=	SetKey(VK_F7)
 Local bKeyF8		:=	SetKey(VK_F8)
  Local bKeyF12	:=	SetKey(VK_F12)
	Local aArea := GetArea()
	Local oDlgMA7, oEncGfu, cGfuCDAnam := ""
	Local aTela := {}, aGets := {}
	Local aSize := {}, aObjects := {}, aInfo := {}, aPGets := {}
	Local lInclui := .F., aAnmRet := {}
	Local aHDados := {}, aCDados := {}
	Local nX := 0, nY := 0
	Local nOpca := 0

 aAnmRet := Fs_RetAnms(GCY->GCY_REGATE, "", "0")

 If !aAnmRet[1]
  SetKey(VK_F6 , bKeyF6 )
  SetKey(VK_F7 , bKeyF7 )
  SetKey(VK_F8 , bKeyF8 )
  SetKey(VK_F12, bKeyF12)
  RestArea(aArea)
  Return(Nil)
 EndIf

 aAdd(aHDados, {" "     , "cMark"  , "@BMP"  ,  2, 0, ".F.", ""    , "C", "", "V" ,"","","","V"})

 For nX := 1 to len(aAnmRet[3])
  aAdd(aHDados, aAnmRet[3][nX])
 Next

 nGFUCDANAM := aScan(aHDados, { |aVet| aVet[2] == "GFU_CDANAM"})

 For nX := 1 to len(aAnmRet[4])
  aAdd(aCDados    , {})
  aAdd(aCDados[nX], "LBNO")
  For nY := 1 to len(aAnmRet[4][nX])
   aAdd(aCDados[nX], aAnmRet[4][nX][nY])
  Next
 Next

	aSize 			:= MsAdvSize(.T.)

 aObjects := {}
 aAdd( aObjects, { 100, 100, .T., .T.} )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPGets := MsObjSize( aInfo, aObjects, .T., .T.)


 DEFINE MSDIALOG oDlg TITLE "Anamnese/Retificadoras Abertas" From 000, 000 To 300, 700 Of oMainWnd Pixel

  oGDGfu := MsNewGetDados():New(aPGets[1,1], aPGets[1,2], aPGets[1,3], aPGets[1,4],0,,,,,,,,,, oDlg, aHDados, aCDados)
  oGDGfu:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  oGDGfu:oBrowse:BlDblClick := { || FS_DbClik(oGDGfu) }

 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||nOpca := 1, oDlg:End()}, {|| nOpca := 0, oDlg:End()})

 If nOpca == 0 .OR. aScan(oGDGfu:aCols, {| aVet | aVet[1] == "LBTIK"}) == 0
  SetKey(VK_F6 , bKeyF6 )
  SetKey(VK_F7 , bKeyF7 )
  SetKey(VK_F8 , bKeyF8 )
  SetKey(VK_F12, bKeyF12)
  RestArea(aArea)
  Return(Nil)
 EndIf

 cGfuCDAnam := oGDGfu:aCols[aScan(oGDGfu:aCols, {| aVet | aVet[1] == "LBTIK"}), nGFUCdAnam]

 DbSelectArea("GFU")
 DbSetOrder(1) //GFU_FILIAL + GFU_CDANAM

	/* Verifica se o Usuario pode excluir uma anamnese */
	If !DbSeek(xFilial("GFU") + cGfuCDAnam) // Procura a anamnese / retificadora
		HS_MsgInf(STR0023, STR0021, STR0037) //"Não foi encontrada nenhuma anamnese para o atendimento selecionado"###"Atenção"###"Exclusão de anamnese/retificadora."

	Else

		DbSelectArea("GFU")
		RegToMemory("GFU", .F.)

		aSize 			:= MsAdvSize(.T.)

  aObjects := {}
  aAdd( aObjects, { 100, 100, .T., .T.} )

  aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  aPGets := MsObjSize( aInfo, aObjects, .T., .T.)

  DEFINE MSDIALOG oDlgMa7 TITLE OemToAnsi(STR0038) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Exclusão"
   oEncGfu := MsMget():New("GFU", RecNo(), 2,,,,, aPGets[1],,,,,, oDlgMA7,,,,,, .T.)
		 oEncGfu:oBox:Align := CONTROL_ALIGN_ALLCLIENT

  ACTIVATE MSDIALOG oDlgMa7 ON INIT EnchoiceBar (oDlgMa7,	{|| nOpcMA7 := 1, oDlgMa7:End()}, {|| nOpcMA7 := 0, oDlgMa7:End()})

		If nOpcMa7 == 1
		 Begin Transaction
		  // Retorna o atendimento ao status 0=Recepcionado
		  DbSelectArea("GCY")
		  DbSetOrder(1) //GCY_FILIAL + GCY_REGATE
		  If DbSeek(xFilial("GCY") + M->GFU_REGATE)
		   RecLock("GCY", .F.)
		    GCY->GCY_STATUS := "0"
		    GCY->GCY_DTPTRI := CToD(" ")
	     GCY->GCY_HRPTRI := Space(Len(GCY->GCY_HRPTRI))
	     GCY->GCY_DTANAM := CToD(" ")
	     GCY->GCY_HRANAM := Space(Len(GCY->GCY_HRANAM))
		   MsUnLock()
		  EndIf

		  // Exclui repositorio de respostas da anamnese
		  DbSelectArea("GFK")
		  DbSetOrder(1) // GFK_FILIAL + GFK_CDANAM + GFK_CDQUES + GFK_GRPPER + GFK_CODPER
		  While DbSeek(xFilial("GFK") + M->GFU_CDANAM)
		   RecLock("GFK", .F., .F.)
		    DbDelete()
		   MsUnLock()
		   WriteSx2("GFK")
		  End

		  // Exclui anamnese
		  DbSelectArea("GFU")
		  DbSetOrder(1) //GFU_FILIAL + GFU_CDANAM
		  If DbSeek(xFilial("GFU") + M->GFU_CDANAM)
		   RecLock("GFU", .F., .F.)
		    DBDelete()
		   MsUnLock()
		   WriteSx2("GFU")
		  EndIf
		 End Transaction
		EndIf
 EndIf

 SetKey(VK_F6 , bKeyF6 )
 SetKey(VK_F7 , bKeyF7 )
 SetKey(VK_F8 , bKeyF8 )
 SetKey(VK_F12, bKeyF12)
 RestArea(aArea)
Return(Nil)

Static Function FS_DbClik(oObj)
 Local cMarc   :=  oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos]
 Local nAt     := 0

 While (nAt := aScan(oObj:aCols, {| aVet | aVet[1] == "LBTIK"})) > 0
  oObj:aCols[nAt, 1] := "LBNO"
 End

 If oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "LBTIK/LBNO"
  oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := IIF(cMarc == "LBTIK", "LBNO", "LBTIK")
 EndIf

 oObj:Refresh()
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_PacMa7 ºAutor  ³Eduardo Alves       º Data ³  28/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta de paciente                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_PacMa7(cAliasMA7)
 Local bKeyF6		:=	SetKey(VK_F6)
 Local bKeyF7		:=	SetKey(VK_F7)
 Local bKeyF8		:=	SetKey(VK_F8)
  Local bKeyF12	:=	SetKey(VK_F12)
 Local aArea   := GetArea()
 Local cSqlGfu := ""
 Local cReadVarOld := __ReadVar

 Private cGbhCodPac := GCY->GCY_REGGER

 __ReadVar := "GCY->GCY_REGGER"

 If HS_ConPac(1, .T.)
  cSqlGfu := "SELECT MAX(GFU_REGATE) GFU_REGATE FROM " + RetSqlName("GFU") + " " + ;
             "WHERE GFU_FILIAL = '" + xFilial("GFU") + "' AND D_E_L_E_T_ <> '*' AND GFU_REGGER = '" + cGbhCodPac + "'"

  cSqlGfu := ChangeQuery(cSqlGfu)

  TCQuery cSqlGfu New Alias "MAXATE"

  DBSelectArea("GCY")
  DBSetOrder(1) //GCY_FILIAL + GCY_REGATE
  DBSeek(xFilial("GCY") + MAXATE->GFU_REGATE)

  DBSelectArea("MAXATE")
  DBCloseArea()

  DBSelectArea("GCY")

  HS_MntMA7(cAliasMA7, GCY->(RecNo()), 2)
 EndIf

 __ReadVar := cReadVarOld

 SetKey(VK_F6 , bKeyF6 )
 SetKey(VK_F7 , bKeyF7 )
 SetKey(VK_F8 , bKeyF8 )
 SetKey(VK_F12, bKeyF12)

 RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FilMA7 ºAutor  ³Eduardo Alves       º Data ³  28/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtro da MBrowse                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FilMA7(lSetFilter, cFilMA7)
//Local oObjMBrw     := ""
Local lRet         := .T.
Local cEspecMed    := IIF(lFilVir, "'"+StrTran(cEspUsu,"/","','")+"'","")
local cEspe:=""

Default lSetFilter := .T.
//oObjMBrw := IIf(lSetFilter, GetObjBrow(), Nil)
HS_PosSX1({{"HSPMA7", "07", PadL(Str(HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_QTANAM",, .F.), 3), 3)}})

If (lRet := Pergunte("HSPMA7", .T.))

	dDatDe  := DToS(MV_PAR01) //HSMA7A   ¦ 01       ¦ Da Data de Atendimento ?
	dDatAte := DToS(MV_PAR02) //HSMA7A   ¦ 02       ¦ AtÚ Data de Atendimento ?
	cCodLoc := MV_PAR03       //HSMA7A   ¦ 03       ¦ Setor ?
	cPlaDe  := MV_PAR04       //HSMA7A   ¦ 04       ¦ Do Plano ?
	cPlaAte := MV_PAR05       //HSMA7A   ¦ 05       ¦ Ate o Plano ?
	nVisAnm := MV_PAR06       //HSMA7A   ¦ 06       ¦ Vis.anamnese de outro profis.
	nQtdAnm := MV_PAR07       //HSMA7A   ¦ 07       ¦ Quantidade de anamneses
	cLocCon := MV_PAR08       //HSMA7A   ¦ 08       ¦ Setor do consultorio
	nStatus := MV_PAR09       //HSMA7A   ¦ 09       ¦ Situação do atendimento

	cFilMA7 := "@GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY_TPALTA <> '99'"

	If nVisAnm == 1 // 1-Não visualiza anamneses de outro profissional
		//Exibe os dados que foram agendados para o medico logado atender
		cFilMA7 += "AND GCY_CODCRM = '" + aCodUsr[2] + "'"
	EndIf

	//Atendimentos de médicos virtuais validando a especialidade
	If(!Empty(cEspecMed))
		cEspe:= Fs_CrmQry(cEspecMed)
		If(!Empty(cEspe))
			cFilMA7 +=  " AND GCY_CODCRM IN ("+cEspe+")
		EndIf
	EndIf

	// Data de atendimento inicial
	If !Empty(dDatDe)
		cFilMA7 += " AND GCY_DATATE >= '" + dDatDe + "'"
	EndIf

	// Data de atendimento final
	If !Empty(dDatAte)
		cFilMA7 += " AND GCY_DATATE <= '" + dDatAte + "'"
	EndIf

	// Codigo do setor
	If !Empty(cCodLoc)
		cFilMA7 += " AND GCY_CODLOC = '" + cCodLoc + "'"
	EndIf

/*  If !Empty(cPlaDe) .Or. !Empty(cPlaAte)
  cRegge:= Fs_GCZQry(cPlaDe,cPlaAte)
   cFilMA7 += "	.AND. GCY_REGATE $ ("+cRegge+")"
//   cFilMA7 += + ")"

  EndIf */
	If nStatus <> 5 //1-Recepcionado, 2-Pré-Triagem, 3-Anamnese, 4-Anamnese Confirmada e 5-Todos
		cFilMa7 += " AND GCY_STATUS = '" + Str(nStatus - 1, 1) + "'"
	EndIf

	If lSetFilter
		oMBrwGCY:CleanFilter()
		oMBrwGCY:SetFilterDefault(cFilMa7)
		GCY->(DbGoTop())
		oMBrwGCY:Refresh()
		// 	 MsgRun(STR0039, STR0040, {|| SetMBTopFilter("GCY", cFilMA7), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando as anamneses..."###"Seleção de registros"
		//MsgRun(STR0039, STR0040, {|| DbSetFilter( { || .T. }, '@' + cFilMA7 ), oMBrwGCY:GoTop(), oMBrwGCY:Refresh()}) //"Selecionando as anamneses..."###"Seleção de registros"
		//MsgRun(STR0039, STR0040, {|| DbSetFilter( { || .T. }, '@' + cFilMA7 ), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando as anamneses..."###"Seleção de registros"
	Else
		HS_PenMA7("GCY", GCY->(RecNo()), 0,nVisAnm)
	EndIf

Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldMA7 ºAutor  ³Eduardo Alves       º Data ³  07/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Caso nao seja passado o parametro cPerg indica que serao va º±±
±±º          ³lidadas as variaveis de memoria do fonte.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_VldMa7(nVld)
 Local lRet := .T.

 // CRM do médico
 If     nVld == 1
  IF     !(lRet := !Empty(&(ReadVar())))
   HS_MsgInf(STR0041, STR0021, STR0042) //"O CRM do profissional é obrigatório."###"Atenção"###"Profissional"

  ElseIf !(lRet := HS_SeekRet("SRA", ReadVar(), 11, .F., "GFU_NOMCRM", "RA_NOME",,, .T.)) .Or. ;
         !(lRet := HS_SeekRet("GBJ", ReadVar(),  1, .F.,,,,, .T.))
   HS_MsgInf(STR0043, STR0021, STR0042) //"CRM do profissional não encontrado."###"Atenção"###"Profissional"
  ElseIf IIF(lFilVir, HS_IniPadr("GBJ", 1, &(ReadVar()), "GBJ_CRMVIR",,.F.) == "1",.T.)
   HS_MsgInf(STR0085, STR0021, STR0042) //"Profissional escolhido é virtual."###"Atenção"###"Profissional"
   lRet := .F.
  EndIf
 // Codigo do setor
 ElseIf nVld == 3 .And. !Empty(&(ReadVar()))
  lRet := HS_VldCSet(&(ReadVar()), "", cGcsTipLoc, STR0044) //"Prontuário Eletrônico"

 ElseIf nVld == 6
  If !(lRet := !(Empty(&(ReadVar()))))
   HS_MsgInf(STR0045, STR0021, STR0046) //"O setor do consultório é obrigatório."###"Atenção"###"Setor"
  Else
   lFilGm1 := .T. // Ativa validação do acesso do profissional no setor
   lRet := HS_VldCSet(&(ReadVar()), "", "D", STR0044) //"Prontuário Eletrônico"
   lFilGm1 := .F.
  Endif

	EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GrvMA7  ºAutor  ³ Jose Orfeu        º Data ³  07/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que confirma a Anamnese.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GrvMA7(lInclui, lConfirma, cCodCrm, cGfuTpAnam, aCposGrv, cAcesso, cAnmOri, cCdQues, cTpNasc, lImagem)

Local nForMne    := 0
Local cMnSele    := ""
Local cOldCrm    := ""
Local aTabDesp   := {"GD5","GD6","GD7"}
Local nCntFor    := 0
Local nLI		 := 0
Local lMVPromo   := SuperGetMV("MV_PROSAUD", NIL, .F.)  // Promoção a Saude
Local lMVVerEleg := SuperGetMV("MV_VELEGUI", NIL, .F.)  // Promoção a Saude
Local cMatvid    := ""
Local aCodUsrBak := {}
Default cAnmOri  := IIF(Hs_ExisDic({{"C","GFU_ANMORI"}}),Space(TamSx3("GFU_ANMORI")[1]),"")
Default cCodCrm  := ""

/* Grava GFU */
If lInclui
	M->GFU_CDANAM := HS_VSxeNum("GFU", "M->GFU_CDANAM", 1)
	ConfirmSx8()
	RecLock("GFU", .T.)
	GFU->GFU_FILIAL	:= xFilial("GFU")
	GFU->GFU_REGATE	:= M->GCY_REGATE
	GFU->GFU_CDANAM	:= M->GFU_CDANAM
	GFU->GFU_TPANAM	:= cGfuTpAnam
	GFU->GFU_REGGER	:= M->GCY_REGGER
	GFU->GFU_NOMPAC := IIf (!Empty(cTpNasc), HS_INIPADR("GB2", 1, M->GCY_REGATE + cTpNasc,"GB2_NOME",,.F.), M->GCY_NOME)
	GFU->GFU_CODCRM	:= cCodCrm
	GFU->GFU_STANAM	:= "0"
	GFU->GFU_CDQUES	:= cCdQues
	If !Empty(cTpNasc) .And. HS_ExisDic({{"C", "GFU_RESERV"}},.F.)
		GFU->GFU_RESERV	:= cTpNasc
	Endif

	If(Hs_ExisDic({{"C","GFU_CODESP"},{"C","GFU_ANMORI"}},.F.))
		GFU->GFU_CODESP	:= Hs_Inipadr("GFS",1, cCdQues, "GFS_CODESP")
		GFU->GFU_ANMORI	:= cAnmOri
	EndIf

	MsUnlock()
EndIf

If lConfirma
	RecLock("GFU", .F.)
	GFU->GFU_STANAM := "1"
	GFU->GFU_DATCON := Date()
	GFU->GFU_HORCON := Time()
	MsUnlock()
	AltCli()
EndIf

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
	DbSeek(xFilial("GCY")+M->GCY_REGATE)
	RecLock("GCY", .F.)

	If Len(aCodUsr) < 3 .Or. aCodUsr[3]
		If IIF(lFilVir,HS_IniPadr("GBJ", 1, GCY->GCY_CODCRM, "GBJ_CRMVIR",,.F.) == "1",.F.)
			cOldCrm  := M->GCY_CODCRM
			GCY->GCY_CODCRM := cCodCrm
		EndIf
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

	MsUnLock()

	If!Empty(cOldCrm)
		DbSelectArea("GCZ")
		DbSetOrder(2)//GCZ_FILIAL+GCZ_REGATE+GCZ_STATUS+GCZ_NRSEQG
		DbSeek(xFilial("GCZ")+GCY->GCY_REGATE+"0")

		While !GCZ->(EoF()) .And. GCZ->GCZ_REGATE == GCY_REGATE .And. GCZ->GCZ_STATUS == "0"

			For nCntFor := 1 to len (aTabDesp)
				DbSelectArea(aTabDesp[nCntFor])
				DbSetOrder(2)//GD5_FILIAL+GD5_NRSEQG+DTOS(GD5_DATDES)
				DbSeek(xFilial(aTabDesp[nCntFor])+GCZ->GCZ_NRSEQG)
				While ! &(aTabDesp[nCntFor]+"->(EoF())") .And. &(aTabDesp[nCntFor]+"->"+aTabDesp[nCntFor]+"_NRSEQG") == GCZ->GCZ_NRSEQG

					If &(aTabDesp[nCntFor]+"->"+aTabDesp[nCntFor]+"_CODCRM") == cOldCrm
						RecLock(aTabDesp[nCntFor],.F.)
						&(aTabDesp[nCntFor]+"->"+aTabDesp[nCntFor]+"_CODCRM") := GCY->GCY_CODCRM
						MsUnLock()
					EndIf
					DbSkip()
				EndDo
			Next nCntFor

			DbSelectArea("GCZ")
			DbSkip()
		EndDo
	EndIf

EndIf

// Grava Repositorio de Respostas do Prontuário
aPerPro:=HS_GrvResp("GFK", {{"GFK->GFK_CDANAM", GFU->GFU_CDANAM}, {"GFK->GFK_CDQUES", GFU->GFU_CDQUES}}, aCposGrv)

If HS_ExisDic({{"T", "GHP"}}, .F.)
	DbSelectArea("GHP")
	DbSetOrder(1)
	DbSeek(xFilial("GHP") + GFU->GFU_CDQUES)
	While !GHP->(Eof()) .And. GHP->GHP_FILIAL == xFilial("GHP") .And. GHP->GHP_CDQUES == GFU->GFU_CDQUES
		HS_ABTExec(GHP->GHP_CODFUN)
		GHP->(DbSkip())
	End
EndIf

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


If lMVPromo
	If lMVVerEleg //verifica elegibiloidade apos confirmacao
		If PLSPROVER(aPerPro,oFolGetsImg, )
			HS_MntMA7("GCY", nRegPromo, 2,,,,,,,,.T.)
		EndIf
	EndIf
	cMatvid:= PLSRTVID(M->GCY_REGGER)
	DbSelectArea("BOM")
	DbSetOrder(3)
	IF DbSeek(xFilial("BOM")+cMatvid+"0")
		While !BOM->(EoF()) .And. BOM->BOM_VIDA == cMatvid
			If  Empty(BOM->BOM_MEDRSP)
				RecLock("BOM", .F.)
				BOM->BOM_MEDRSP := cCodCrm
				MsUnLock()
			Endif
		BOM->(DbSkip())
		End
	Endif
Endif

aCodUsrBak := aCodUsr
If lConfirma .And. GetNewPar("MV_HSPCERD","0") == "1"
	HSPRQUES("GFK", "GFK_CDANAM", /*cValChv*/, /*cCdQues*/, M->GCY_REGATE, /*cAssinatura*/, cCodCrm, /*cCodloc*/, .T.,GFU->GFU_CDANAM)
EndIf
aCodUsr := aCodUsrBak

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_PosGfu ºAutor  ³Eduardo Alves       º Data ³  07/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posiciona na Anamnese (GFU).                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_PosGfu(cRegAte, cCodCrm, cTipoStatus, lRest)
	Local aArea := GetArea()
	Local lRet := .F., nRecGfu := GFU->(RecNo()), nIdxGfu := GFU->(IndexOrd())

	Default lRest := .F.
	Private lExtAnm   := IIf(Type("lVisExt")<>"U",lVisExt, .F.)

 If lExtAnm
	DbSelectArea("GFU")
	DbSetOrder(3) // GFU_CODCRM + GFU_TPANAM + GFU_STANAM
	lRet := DbSeek(xFilial("GFU") + cCodCrm + cTipoStatus )
 Else
	DbSelectArea("GFU")
	DbSetOrder(2) // GFU_FILIAL + GFU_REGATE + GFU_CODCRM + GFU_TPANAM + GFU_STANAM
	lRet := DbSeek(xFilial("GFU") + cRegAte + cCodCrm + cTipoStatus)
 Endif

	If lRest
	 DbSetOrder(nIdxGfu)
		DBGoTo(nRecGfu)
	EndIf

	RestArea(aArea)
Return(lRet)

Static Function FS_DespAte(cRegAte)
 Local aArea := GetArea(), nGcyRecNo := 0

 DbSelectArea("GCY")
 DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
 nGcyRecNo := RecNo()

 If IIf(cRegAte <> GCY->GCY_REGATE, DbSeek(xFilial("GCY") + cRegAte), .T.)

  HS_CtrlM24({GCY->GCY_ATENDI, GCY->GCY_REGATE, "P", 7, GCY->GCY_CODLOC, ""})

 EndIf

 DbGoTo(nGcyRecNo)
 RestArea(aArea)
Return(.T.)

Function HS_PenMA7(cAliasMA7, nRegMA7, nOpcMA7, nVisAnm)
 Local bKeyF6		:=	SetKey(VK_F6)
 Local bKeyF7		:=	SetKey(VK_F7)
 Local bKeyF8		:=	SetKey(VK_F8)
  Local bKeyF12	:=	SetKey(VK_F12)
 Local aArea := GetArea(), oDlgMA7
	Local oGDGfu, aJoinGfu := {}, aHGfu := {}, aCGfu := {}, cCondGfu := {}, oRecGfu, nRecGfu := 0
	Local aSize := {}, aObjects := {}, aInfo := {}, aPPanel := {}, aPEnch := {}, aPGets := {}
	Local nGfuMMarca := 0, nGfuCdAnam := 0, nGfuCdQues := 0, nGfuRegAte := 0
 Local cAcesso := IIf(Type("__cMa7Aces") <> "U", __cMa7Aces, "G")
 Local aButtons := {{STR0047 , {|| nRecGfu := FS_FilGfu(oGDGfu, cCondGfu, aJoinGfu), oRecGfu:Refresh()}, STR0047}, ; //"FILTRO"###"FILTRO"
                    {"CHECKED", {|| FS_MarkGfu(oGDGfu, nGfuMMarca), oRecGfu:Refresh()}, STR0048}} //"Marca"
 Local oPanelPes, oPanelTop, oPanelBot, oPanelLef, oPanelRig

 Default nVisAnm  := 0
 DbSelectArea("GFU")
 DbSetOrder(1) // GFU_FILIAL + GFU_CDANAM

 cCondGfu := "GFU->GFU_STANAM = '0'"
	If nVisAnm == 1 // 1-Não visualiza anamneses de outro profissional
	 cCondGfu += " AND GFU->GFU_CODCRM = '" + aCodUsr[2] + "'"
	EndIf

	aJoinGfu := {{" JOIN " + RetSqlName("GCY") + " GCY", "GCY.GCY_ATENDI", "GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GFU.GFU_REGATE", "GFU_ATENDI"}}

 If (nRecGfu := HS_BDados("GFU", @aHGfu, @aCGfu,, 1,, cCondGfu,,,,,,, "GFU_MMARCA",,,,,,,,, aJoinGfu,, "GFU_CDANAM DESC")) > 0
  nGfuMMarca := aScan(aHGfu, {| aVet | aVet[2] == "GFU_MMARCA"})
  nGfuCdAnam := aScan(aHGfu, {| aVet | aVet[2] == "GFU_CDANAM"})
  nGfuCdQues := aScan(aHGfu, {| aVet | aVet[2] == "GFU_CDQUES"})
  nGfuRegAte := aScan(aHGfu, {| aVet | aVet[2] == "GFU_REGATE"})

	 aSize 			:= MsAdvSize(.T.)

  aObjects := {}
  aAdd( aObjects, { 100, 010, .T., .T., .T.} )
  aAdd( aObjects, { 100, 030, .T., .T., .T.} )
  aAdd( aObjects, { 100, 060, .T., .T., .T.} )

  aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  aPPanel := MsObjSize( aInfo, aObjects, .T. )

  aObjects := {}
  aAdd( aObjects, { 100, 100, .T., .T.} )

  aInfo  := { aPPanel[2, 2], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4], 0, 0 }
	 aPEnch := MsObjSize( aInfo, aObjects, .T., .T.)

  aObjects := {}
  aAdd( aObjects, { 100, 100, .T., .T.} )

  aInfo  := { aPPanel[3, 2], aPPanel[3, 2], aPPanel[3, 3], aPPanel[3, 4], 0, 0 }
	 aPGets := MsObjSize( aInfo, aObjects, .T., .T.)

  DEFINE MSDIALOG oDlgMa7 TITLE OemToAnsi(STR0049) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Anamneses sem confirmação."
   /* Panels para manipulação do tamanho da Tela */
   oPanelPes	:=	tPanel():New(aPPanel[1, 1], aPPanel[1, 2],, oDlgMa7,,,,,, aPPanel[1, 3], aPPanel[1, 4])
   oPanelPes:Align := CONTROL_ALIGN_TOP

   oPanelTop	:=	tPanel():New(aPPanel[1, 1], aPPanel[2, 2],, oDlgMa7,,,,,,	aPPanel[2, 3],	aPPanel[2, 4])
   oPanelTop:Align := CONTROL_ALIGN_TOP

   oPanelBot	:=	tPanel():New(aPPanel[2, 1], aPPanel[3, 2],, oDlgMa7,,,,,, aPPanel[3, 3], aPPanel[3, 4])
   oPanelBot:Align := CONTROL_ALIGN_ALLCLIENT

   oGDGfu := MsNewGetDados():New(aPEnch[1, 1], aPEnch[1, 2], aPEnch[1, 3], aPEnch[1, 4], 0,,,,,,,,,, oPanelTop, aHGfu, aCGfu)
   oGDGfu:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
   If !Empty(oGDGfu:aCols[1, nGfuCDQues])
    oGDGfu:oBrowse:bChange := {|| HS_BusResp("GFK", {{"GFK->GFK_CDANAM", oGDGfu:aCols[oGDGfu:nAt, nGfuCDAnam]}, {"GFK->GFK_CDQUES", oGDGfu:aCols[oGDGfu:nAt, nGfuCDQues]}}, "HIS"), ;
                                  HS_MntPerg(oGDGfu:aCols[oGDGfu:nAt, nGfuCDQues], oPanelBot,, aPGets[1], .T., "HIS", "oEncHis",,, CONTROL_ALIGN_ALLCLIENT, .T., "G"/*cAcesso*/)}
    oGDGfu:oBrowse:BlDblClick := {|| oGDGfu:aCols[oGDGfu:nAt, nGfuMMarca] := IIf(oGDGfu:aCols[oGDGfu:nAt, nGfuMMarca] == "LBNO", "LBTIK", "LBNO")}
	 	Endif

	 	@ 005, 230 Say oRecGfu Var "[" + StrZero(nRecGfu, 4) + STR0050  OF oPanelPes PIXEL COLOR CLR_BLUE //"] Registros"

   HS_GDPesqu(,, oGDGfu, oPanelPes, 002)
  ACTIVATE MSDIALOG oDlgMa7 ON INIT EnchoiceBar (oDlgMa7,	{|| FS_ConfAnm(oGDGfu, nGfuCDAnam, nGfuRegAte, nGfuMMarca), oDlgMa7:End()}, {|| oDlgMa7:End()},, aButtons)
 ElseIf nOpcMA7 <> 0
  HS_MsgInf(STR0051, STR0021, STR0012) //"Não foi encontrada nenhuma anamnese sem confirmaçao."###"Atenção"###"Pendências"
 EndIf

 SetKey(VK_F6 , bKeyF6 )
 SetKey(VK_F7 , bKeyF7 )
 SetKey(VK_F8 , bKeyF8 )
 SetKey(VK_F12, bKeyF12)

	RestArea(aArea)
Return(Nil)

Static Function FS_ConfAnm(oGDGfu, nGfuCDAnam, nGfuRegAte, nGfuMMarca)
 Local aArea := GetArea()
 Local nForGfu := 0
Local aCertDigi  := {}
Local aCodUsrBak := {}		

 Begin Transaction
  For nForGfu := 1 To Len(oGDGfu:aCols)
   If oGDGfu:aCols[nForGfu, nGfuMMarca] == "LBTIK"

		aaDd(aCertDigi,{"","",""})   
		
	   DbSelectArea("GFU")
    DbSetOrder(1) // GFU_FILIAL + GFU_CDANAM
    If DbSeek(xFilial("GFU") + oGDGfu:aCols[nForGfu, nGfuCDAnam])
	  		aCertDigi[len(aCertDigi)][1] := GFU->GFU_CDANAM 
     RecLock("GFU", .F.)
	    	GFU->GFU_STANAM := "1"
	    	GFU->GFU_DATCON := Date()
	    	GFU->GFU_HORCON := Time()
	    MsUnlock()
	   EndIf

    DbSelectArea("GCY")
    DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
    If DbSeek(xFilial("GCY") + oGDGfu:aCols[nForGfu, nGfuRegAte])
			aCertDigi[len(aCertDigi)][2] := GCY->GCY_REGATE	
			aCertDigi[len(aCertDigi)][3] := GCY->GCY_REGGER
     RecLock("GCY", .F.)
 	   	GCY->GCY_STATUS := IIF(HS_PosGfu(GCY->GCY_REGATE, aCodUsr[2], "00",.T.) .Or. HS_PosGfu(GCY->GCY_REGATE, aCodUsr[2], "10",.T.),GCY->GCY_STATUS,"3") // 3-Anamnese Confirmada
 	   	GCY->GCY_DTACON := dDataBase
 	    GCY->GCY_HRACON := Time()
 	   MsUnlock()
 	  EndIf

	  EndIf
	 Next
 End Transaction

 RestArea(aArea)

aCodUsrBak := aCodUsr
For nForGfu := 1 To Len(aCertDigi)
	// Joga dados do atendimento na memoria
	DbSelectArea("GCY")
	RegToMemory("GCY",.F.,.T.,.F.)
	
	// Joga dados do paciente na memoria
	DbSelectArea("GBH")
	DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
	DbSeek(xFilial("GBH") + aCertDigi[nForGfu][3])
	RegToMemory("GBH",.F.,.T.,.F.)
	If GetNewPar("MV_HSPCERD","0") == "1"	
		HSPRQUES("GFK", "GFK_CDANAM", /*cValChv*/, /*cCdQues*/, aCertDigi[nForGfu][2], /*cAssinatura*/, /*cCodCrm*/, /*cCodloc*/, .T.,aCertDigi[nForGfu][1])
	Endif	
Next	
aCodUsr := aCodUsrBak


Return(Nil)

Static Function FS_FilGfu(oGDGfu, cCondGfu, aJoinGfu)
 Local aHGfu := {}, aCGfu := {}
 Local cFiltro := BuildExpr("GFU",, cFiltroGfu, .T.)
 Local nRecGfu := HS_BDados("GFU", @aHGfu, @aCGfu,, 1,, cCondGfu + IIf(!Empty(cFiltro), " AND " + cFiltro, ""),,,,,,, "GFU_MMARCA",,,,,,,,, aJoinGfu,, "GFU_DATCON DESC,GFU_CDANAM DESC")

 cFiltroGfu := cFiltro

 oGDGfu:SetArray(aCGfu)
 oGDGfu:oBrowse:Refresh()
Return(nRecGfu)

Static Function FS_MarkGfu(oGDGfu, nGfuMMarca)
 Local nForGfu := 0

 For nForGfu := 1 To Len(oGDGfu:aCols)
  oGDGfu:aCols[nForGfu, nGfuMMarca] := IIf(lMarkGfu, "LBNO", "LBTIK")
 Next

 lMarkGfu := !lMarkGfu
Return(Nil)

Function HS_AgeMa7(cAliasMa7, nRegMa7, nOpcMa7)
 Local bKeyF6		:=	SetKey(VK_F6)
 Local bKeyF7		:=	SetKey(VK_F7)
 Local bKeyF8		:=	SetKey(VK_F8)
 Local bKeyF12	:=	SetKey(VK_F12)
 Local aArea   := GetArea()
 Local cCodPro := HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_CODPRO",, .F.)
 Private aRotina := {{"", "", 0, 1}, ; //"Pesquisar"
                     {"", "", 0, 3}, ; //"Agendar"
                     {"", "", 0, 4}, ; //"Cancelar"
                     {"", "", 0, 4}, ; //"Transferir"
                     {"", "", 0, 4}, ; //"Alterar"
                     {"", "", 0, 1}}   //"Legenda"

 Private cGcsCodLoc := GCY->GCY_CODLOC // ou cLocCon
 Private __aCpAuM29 := {} // Campos que estrão preeenchidos na agenda - {campo, conteudo, executa valid}

 aAdd(__aCpAuM29, {"M->GM8_REGGER", GCY->GCY_REGGER, .T.})
 aAdd(__aCpAuM29, {"M->GM8_CODCRM", aCodUsr[2], .T.})
 If !Empty(cCodPro)
  aAdd(__aCpAuM29, {"M->GM8_CODPRO", cCodPro   , .T.})
 EndIf


 If     nOpcMa7 == 1 // Agenda Ambulatorial
  DbSelectArea("GM8")
	 HSPM29Atu('GM8', GM8->(RecNo()), 2)
 ElseIf nOpcMa7 == 2 // Consulta Agenda Ambulatorial
	 HS_ConsAge("A")
	ElseIf nOpcMa7 == 3 // Agenda Cirurgica
	 DbSelectArea("GMJ")
	 HS_M39Atu('GMJ', GMJ->(RecNo()), 2)
	ElseIf nOpcMa7 == 4 // Consulta Agenda Ambulatorial
	 HS_ConsAge("C")
	EndIf

 MBrChgLoop(.F.)

 SetKey(VK_F6 , bKeyF6 )
 SetKey(VK_F7 , bKeyF7 )
 SetKey(VK_F8 , bKeyF8 )
 SetKey(VK_F12, bKeyF12)

 RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	   ³HS_ExtMa7 ³ Autor ³José Orfeu             ³ Data ³24/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ EXTRATO                                             					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Alias do Arquivo                       									  ³±±
±±³          ³ ExpN02 - Nr. do registro                        									  ³±±
±±³          ³ ExpN03 - Opcao Selecionada                          					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno 	 ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSPAHMA7 											                                    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_ExtMa7(cAliasMa7, nRegMa7, nOpcMa7)
 Local aArea	:= GetArea()

 DbSelectArea("GCY")
 RegToMemory("GCY", .F.)

 HS_EXTM24C(GCY->GCY_REGGER, "P", 2)

 RestArea(aArea)
Return()

Function HS_RelMa7(cAliasMa7, nRegMa7, nOpcMa7, lPosiGFU, cCodAnm)
 Local aArea := GetArea()
 Local aAnm  := {}, aRetif := {}
 Local nPos := 0
 Local lMVPromo := SuperGetMV("MV_PROSAUD", NIL, .F.)  // Promoção a Saude
 Default lPosiGFU := .F.

  If lPosiGFU
	  DbSelectArea("GFU")
	  DbSetOrder(1) //GFU_FILIAL+GFU_CDANAM

	  If !Empty(cCodAnm)
	   DbSeek(xFilial("GFU") + cCodAnm)
	  Else
		  aAnm   :=  Fs_RetAnms(GCY->GCY_REGATE, "0", "1")
		  aRetif :=  Fs_RetAnms(GCY->GCY_REGATE, "1", "1")
		  nPos := aScan(aAnm[3], {|aVet| aVet[2] == "GFU_CDANAM"})
		  aSort( aAnm[4],,,{|x,y| x[nPos] > y[nPos] })
		  aSort( aRetif[4],,,{|x,y| x[nPos] > y[nPos] })

		  DbSelectArea("GFU")
	  	DbSetOrder(1)
		  DbSeek(xFilial("GFU") + IIF(aAnm[4, 1, nPos] > aRetif[4, 1, nPos], aAnm[4, 1, nPos],aRetif[4, 1, nPos]))

	  EndIf

	  DbSelectArea("GFK")
	  DbSetOrder(1) //GFK_FILIAL+GFK_CDANAM+GFK_CDQUES+GFK_GRPPER+GFK_CODPER
	  DbSeek(xFilial("GFK")+GFU->GFU_CDANAM)
	 EndIf

If Empty(cLocCon) .AND. lExtAnm
	Pergunte("HSPSET", .T.)
	cLocCon := MV_PAR01
EndIf

IF !(lMVPromo)
	HSPAHP44(.F., cLocCon)
Endif

 RestArea(aArea)
Return(Nil)

Static Function FS_DocRel(cRegAte, cCodAnm)
 Local aArea := GetArea()

 DbSelectArea("GCY")
 DbSetOrder(1) // GCY_FILIAL + GCY_REGATE
 If !Empty(cRegAte) .And. DbSeek(xFilial("GCY") + cRegAte)

  HS_RelMa7("GCY", GCY->(RecNo()), 2, .T., cCodAnm)

 Else
  HS_MsgInf(STR0052 + cRegAte + STR0053, STR0021, STR0015) //"Atendimento ["###"] não encontrado"###"Atenção"###"Docs/Relat."

 EndIf

 RestArea(aArea)
Return(Nil)


Function HS_LegMA7()
Local aArea := getArea()
 Local aLegMA7 := { {"BR_VERDE"   , STR0054}, ; //"Recepcionado"
                    {"BR_AMARELO" , STR0055}, ; //"Pré-Triagem"
 			 									      {"BR_LARANJA" , STR0005}, ; //"Anamnese"
   											      {"BR_VERMELHO", STR0056}} //"Anamnese confirmada"

 BrwLegenda(cCadastro, STR0016, aLegMA7) //"Legenda"
RestArea(aArea)

//oMBrwGCY:CleanFilter()
//oMBrwGCY:SetFilterDefault("GCY_STATUS == '3'")
//oMBrwGCY:Refresh()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_MntQues ºAutor  ³Patricia Queiroz    º Data ³  20/03/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para apresentar os questionários para seleção.       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_MntQues(cCond)

Local aArea    := GetArea()
Local aHGFS    := {}
Local aCGFS    := {}
Local nIDMARK  := 0
Local nOpcA    := 0
Local oGFS
Local cCdQues  := ""
Local cDirImg  := ""
Local nFor     := 0
Local nUGFS    := 0
Local aJoin    := {}
Local lExbTela := .F.
Local cSql     := ""
Local cAces    := "'0', "+IIF(__cMA7Aces == "E", "'1'", "'2'")
Local nGFSDIRIMG := 0
Local lExDicImg	:=  HS_ExisDic({{"C", "GFS_DIRIMG"}},.F.)

cCond += 	" AND EXISTS(SELECT GFT.GFT_CDQUES " +;
			"            FROM " + RetSqlName("GFT") + " GFT " +;
			"            WHERE GFT.GFT_FILIAL = '" + xFilial("GFT") + "' AND GFT.D_E_L_E_T_ <> '*' AND GFT.GFT_CDQUES = GFS.GFS_CDQUES AND GFT.GFT_TPPERM IN (" + cAces + ") )"
cCond += 	" AND GFS.GFS_IDATIV = '1' AND GFS.GFS_TPQUES = '0' "

If (nUGFS := HS_BDados("GFS", @aHGFS, @aCGFS,, 1,, cCond,,,,,,, "GFS_IDMARK", "'LBNO'")) > 1
	lExbTela := .T.
	nGFSIDMARK := aScan(aHGFS, {| aVet | aVet[2] == "GFS_IDMARK"})
	nGFSCDQUES := aScan(aHGFS, {| aVet | aVet[2] == "GFS_CDQUES"})
	If lExDicImg
		nGFSDIRIMG := aScan(aHGFS, {| aVet | aVet[2] == "GFS_DIRIMG"})
	EndIf

	aSize    := MsAdvSize(.T.)
	aObjects := {}
	AAdd(aObjects, {100, 100, .T., .T.})

	aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
	aPObjs := MsObjSize(aInfo, aObjects, .T.)

	nOpcA := 0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0057) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Questionário"

	oGFS := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4],,,,,,,,,,,, aHGFS, aCGFS)
	oGFS:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGFS:oBrowse:BlDblClick := {|| FS_DblClik(oGFS)}

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(FS_QueSel(oGFS), oDlg:End(), nOpcA := 0)}, ;
	{|| nOpcA := 0, oDlg:End()})
	If nOpcA == 1

		For nFor := 1 To Len(oGFS:aCols)
			If oGFS:aCols[nFor, nGFSIDMARK] == "LBTIK"
				cCdQues := oGFS:aCols[nFor, nGFSCDQUES]
				If lExDicImg
					cDirImg := alltrim(oGFS:aCols[nFor, nGFSDIRIMG])
				EndiF
				Exit
			EndIf
		Next
	EndIf

ElseIf (nUGFS == 1)
	nGFSIDMARK := aScan(aHGFS, {| aVet | aVet[2] == "GFS_IDMARK"})
	nGFSCDQUES := aScan(aHGFS, {| aVet | aVet[2] == "GFS_CDQUES"})
	nGFSDIRIMG := aScan(aHGFS, {| aVet | aVet[2] == "GFS_DIRIMG"})
	cCdQues := alltrim(aCGFS[1, nGFSCDQUES])
	If lExDicImg
		cDirImg := aCGFS[1, nGFSDIRIMG]
	EndIf
EndIf

RestArea(aArea)

Return({cCdQues, lExbTela, cDirImg})




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
Static Function FS_QueSel(oGFS)

 Local aArea   := GetArea()
 Local nCont   := 0
 Local nFor    := 0
 Local lRet    := .T.

 For nFor := 1 To Len(oGFS:aCols)
  If oGFS:aCols[nFor, nGFSIDMARK] == "LBTIK"
   nCont++
  EndIf
 Next

	If nCont == 0
  HS_MsgInf(STR0086, STR0021, STR0059)  //"Por favor, selecione apenas um questionário."###"Atenção"###"Validação de Questionário"
  lRet := .F.
 ElseIf nCont > 1
  HS_MsgInf(STR0058, STR0021, STR0059)  //"Por favor, selecione apenas um questionário."###"Atenção"###"Validação de Questionário"
  lRet := .F.
 EndIf

 RestArea(aArea)

Return(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DblClik ºAutor  ³Patricia Queiroz    º Data ³ 20/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para marcar e desmarcar o item.                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DblClik(oGFS)
	Local nFor := 0
	// Limpa todos os campos menos o que está posicionado
 For nFor := 1 To Len(oGFS:aCols)
	 If oGFS:oBrowse:nAt != nFor
	    oGFS:aCols[nFor, nGFSIDMARK] := "LBNO"
  EndIf
 Next
 oGFS:aCols[oGFS:oBrowse:nAt, nGFSIDMARK] := IIf(oGFS:aCols[oGFS:oBrowse:nAt, nGFSIDMARK] == "LBTIK", "LBNO", "LBTIK")
 oGFS:oBrowse:Refresh()
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldInteº Autor  ³Patricia Queiroz    º Data ³ 04/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para montar a legenda das anamneses que possui inter_º±±
º±±           correncia.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VldInte(cRegAte)

 Local aArea  := GetArea()
 Local cLeg   := ""

 DbSelectArea("GHK")
 DbSetOrder(2)
 If DbSeek(xFilial("GHK") + cRegAte)
  cLeg := "I"
 Else
  cLeg := "N"
 End

 RestArea(aArea)
Return(cLeg)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_Leg    º Autor ³Patricia Queiroz    º Data ³ 04/04/07    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para montar a legenda das anamneses que possui inter_º±±
º±±           correncia.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Leg()

Local aLeg := {{"BR_VERDE", STR0062}, ; //"Possui Intercorrência"
               {"BR_AZUL" , STR0063}}   //"Não Possui Intercorrência"

BrwLegenda(STR0060, STR0016, aLeg) //"Intercorrência"###"Legenda"
Return(Nil)


Function HS_M07HIST(cTpNasc,nVisAnm)

 Local aArea := GetArea()
 Local aHGFUHist := {}, aCGFUHist := {}, nUGFUHist := 0
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local nOpcMA7 := 0, nQtAnam := 0, nFor := 0
 Local oDlgHist := Nil, oGDGFUHist := Nil
 Local aButtons := {}, aAnamneses := {}
 Local lMarca := .T.
 Local cCondGfu := ""
 Local cGFSFicha := ""
 Local cDirTxt := GetMV("MV_DIRTXT")
 Local aRTxt := {}, aRImg := {}, aREtq := {}
 Local aRtDadFic := {}, aPosArq := {}

 Private nGFUSTAINT := 0, nGFUCDANAM := 0, nGFUCDQUES := 0

 IF(ValType(cTpNasc) <> "C")
  cTpNasc := ""
 Endif

 cCondGfu := "GFU->GFU_REGGER = '" + GCY->GCY_REGGER + "' AND GFU->GFU_STANAM = '1'"

	If HS_ExisDic({{"C", "GFU_RESERV"}},.F.)
	 cCondGfu += " AND GFU->GFU_RESERV = '" + cTpNasc + "'"
	Endif

	If nVisAnm == 1 // 1-Não visualiza anamneses de outro profissional
	 cCondGfu += " AND GFU->GFU_CODCRM = '" + aCodUsr[2] + "'"
	EndIf
	
iF lVerFil
	lFilial:=Iif(lVerFil,HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_VIFILI",,.F.) <> "1",.T.)
Else
	lFilial:=.T.
Endif

 aJoinGfu := {{" JOIN " + RetSqlName("GCY") + " GCY", "GCY.GCY_ATENDI", Iif(lFilial,"GCY.GCY_FILIAL = '" + xFilial("GCY")+"' AND","")+"   GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GFU.GFU_REGATE", "GFU_ATENDI"}}

 HS_BDados("GFU" , @aHGFUHist , @aCGFUHist , @nUGFUHist , 1,lFilial, cCondGfu,,,,,,, "GFU_STAINT", "'LBNO'",,,,,,, aJoinGfu)
 nSTAINT := aScan(aHGfuHist, {| aVet | aVet[2] == "GFU_STAINT"})
 nCDANAM := aScan(aHGfuHist, {| aVet | aVet[2] == "GFU_CDANAM"})
 nCDQUES := aScan(aHGfuHist, {| aVet | aVet[2] == "GFU_CDQUES"})

 nQtAnam := HS_IniPadr("GBJ", 1, aCodUsr[2], "GBJ_QTANAM",, .F.)

 aSort(aCGFUHist,,,{|x,y| x[nCDANAM] > y[nCDANAM]})

 nFor :=1
 While nFor <= Len(aCGFUHist) .And. nFor <= nQtAnam // Se a iteração for menor igual a quantidade de anamneses e se a houver essa quantidade de linhas no acols
  aCGFUHist[nFor, nSTAINT] := "LBTIK"
  nFor++
 End

 Aadd(aButtons, {"CHECKED", {|| FS_Mark(lMarca, @oGDGFUHist, nSTAINT), lMarca := !lMarca}, STR0066, STR0067}) //"Todos"###"Marcar Todos"

 aSize 			:= MsAdvSize(.T.)

 aObjects := {}
 aAdd( aObjects, { 100, 100, .T., .T.} )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPGets := MsObjSize( aInfo, aObjects, .T., .T.)

 DEFINE MSDIALOG oDlgHist TITLE OemToAnsi(STR0068) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Histórico"

	 oGDGFUHist := MsNewGetDados():New(aPGets[1, 1], aPGets[1, 2], aPGets[1, 3], aPGets[1, 4], 0,,,,,,,,,, oDlgHist, aHGFUHist, aCGFUHist)
	 oGDGFUHist:oBrowse:BlDblClick := {|| oGDGFUHist:aCols[oGDGFUHist:nAt, nSTAINT] := IIf(oGDGFUHist:aCols[oGDGFUHist:nAt, nSTAINT] == "LBNO", "LBTIK", "LBNO") }
  oGDGFUHist:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlgHist ON INIT EnchoiceBar (oDlgHist,	{|| nOpcMA7 := 1, oDlgHist:End()},;
                                                									  {|| nOpcMA7 := 0, oDlgHist:End()},,aButtons)
 If nOpcMA7 == 1
  For nFor := 1 To Len(oGDGFUHist:aCols)
//   aAdd(aAnamneses, {oGDGFUHist:aCols[nFor, nCDANAM], oGDGFUHist:aCols[nFor, nCDQUES]})
   If oGDGFUHist:aCols[nFor, nSTAINT] == "LBTIK" .And. !Empty(cGFSFicha := (HS_IniPadr("GFS", 1, oGDGFUHist:aCols[nFor, nCDQUES], "GFS_FFICHA"))) .And. (aRtDadFic := HS_DetFic(cDirTxt, cGFSFicha))[1]
    aAdd(aPosArq, {"GFU", 1, oGDGFUHist:aCols[nFor, nCDANAM]})
    If aRtDadFic[3] $ "012"
     aAdd(aRTxt, {cGFSFicha, Str(aRtDadFic[2]), aRtDadFic[3], Str(aRtDadFic[4]), aRtDadFic[5], aRtDadFic[6]})
    ElseIf aRtDadFic[3] $ "34"
     aAdd(aRImg, {cGFSFicha, Str(aRtDadFic[2]), aRtDadFic[3], Str(aRtDadFic[4]), aRtDadFic[5], aRtDadFic[6]})
    ElseIf aRtDadFic[3] $ "5"
     aAdd(aREtq, {cGFSFicha, })
    EndIf
   EndIf
  Next

  HS_CtrlImp("GFU", "HSPAHMA7", "Questionários", "M", .T., aRTxt, aRImg, aREtq, aPosArq, {'_SetOwnerPrvt("__aVarResp", HS_BusResp("GFK", {{"GFK->GFK_CDANAM", GFU->GFU_CDANAM}, {"GFK->GFK_CDQUES", GFU->GFU_CDQUES}}, "__cGFK"))'})
//  HSPAHR25(aAnamneses,aCodUsr[2])

 EndIf

	RestArea(aArea)
Return()

Static Function FS_Mark(lMarca, oGet, nPos)
 Local nFor := 0

 For nFor := 1 To Len(oGet:aCols)
  oGet:aCols[nFor, nPos] := IIf(lMarca, "LBTIK", "LBNO")
 Next

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHMA7  ºAutor  ³Luiz Pereira S. Jr. º Data ³  10/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descrição do ComboBox quando o campo da qustiona- º±±
±±º          ³rio eh um combo.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_MA7RDes(cCodPer, cOpcao)

 Local aArea := GetArea(), cRet := ""

 If !Empty(AllTrim(cOpcao))

  DbSelectArea("GCH")
  DbSetOrder(1) //GCH_FILIAL+GCH_CODPER
  DbSeek(xFilial("GCH") + cCodPer)

  If !Empty(cRet := IIF(At("#", GCH->GCH_CBOX) > 0, SubStr(GCH->GCH_CBOX, 2), ""))
   cRet := &(cRet)
   cRet := SubStr(cRet, At(cOpcao + "=", cRet) + Len(cOpcao + "="))
   cRet := IIF(At(";", cRet) > 0, SubStr(cRet, 1, At(";", cRet) - 1), cRet)
  Else
   // Pega opcao do sinal de igualdade ate o fim da opcao
   cRet := SubStr(GCH->GCH_CBOX, At(cOpcao + "=", GCH->GCH_CBOX) + Len(cOpcao + "="))
   cRet := IIF(At(";", cRet) > 0, SubStr(cRet, 1, At(";", cRet) - 1), cRet)
  EndIf

 EndIf

 RestArea(aArea)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHMA7  ºAutor  ³Luiz Pereira S. Jr. º Data ³  07/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite a configuração dos campos do atendimento e do pa-   º±±
±±º          ³ciente na tela de anmnese.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_CfgMA7()

 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local oDlgCfg := Nil, nOpcDlg := 0
 Local aCSX2 := {}, aHSX2 := {}
 Local aCSX3 := {}, aHSX3 := {}
 Local oGetSX2  := Nil, oGetSX3 := Nil
 Local aTabelas := {}
 Local cCodLoc  := ""

 Private nUSX2    := 0, nUSX3 := 0, nArquivo := 0, nDescricao := 0
 Private cArquivo := "", cDescricao := ""
 Private cTabAnt  := "GBH"
 Private cGcsTipLoc := "12348C"

 
 If !HS_ExisDic({{"C", "GMT_CODLOC"}})
	 Return(Nil)
 EndIf


If  FunName() <> "HSPAHP04" .and. !Pergunte("HSPM7A", .T.)
  Return()
 Else
  cCodLoc := MV_PAR01
 EndIf

 //Monta aHeader e aCols o SX2
 Aadd(aHSX2, {STR0069,"cArquivo", "@!", 6, 0,".F.",""    , "C", "", "V" ,"" , "","","V"}) //"Arquivo"
 nArquivo   := ++nUSX2

 Aadd(aHSX2, {STR0070,"cDescSX2", "@!", Len(X2Nome()), 0,".F.",""    , "C", "", "V" ,"" , "","","V"}) //"Descricao"
 nDescSX2   := ++nUSX2

 DbSelectArea("SX2")
 DbSetOrder(1)
If FunName() == "HSPAHP04"
	DbSeek("GAV")
	aAdd(aCSX2, {"GAV", X2Nome(), .F.})
Else
 DbSeek("GBH")
 aAdd(aCSX2, {"GBH", X2Nome(), .F.})

 DbSeek("GCY")
 aAdd(aCSX2, {"GCY", X2Nome(), .F.})

 DbSeek("GB2")
 aAdd(aCSX2, {"GB2", X2Nome(), .F.})

 DbSeek("BBD")
 aAdd(aCSX2, {"BBD", X2Nome(), .F.})
 //Monta aHeader e aCols o SX3
 Endif
 Aadd(aHSX3, {" ","cMostra", "@BMP", 2, 0,".F.",""    , "C", "", "V" ,"" , "","","V"})
 nMostra   := ++nUSX3

 Aadd(aHSX3, {" -","cSobe", "@BMP", 2, 0,".F.",""    , "C", "", "V" ,"" , "","","V"})
 nSobe     := ++nUSX3

 Aadd(aHSX3, {" +","cDesce", "@BMP", 2, 0,".F.",""    , "C", "", "V" ,"" , "","","V"})
 nDesce    := ++nUSX3

 Aadd(aHSX3, {STR0071,"cOrdem", "@!", 3, 0,".F.",""    , "C", "", "V" ,"" , "","","V"}) //Ordem
 nOrdem    := ++nUSX3

 Aadd(aHSX3, {STR0072,"cCampo", "@!", Len(SX3->X3_CAMPO), 0,".F.",""    , "C", "", "V" ,"" , "","","V"}) //"Campo"
 nCampo    := ++nUSX3

 Aadd(aHSX3, {STR0073,"cTitulo", "@!", Len(X3Titulo()), 0,".F.",""    , "C", "", "V" ,"" , "","","V"}) //"Título"
 nTitulo   := ++nUSX3

 Aadd(aHSX3, {STR0070,"cDescricao", "@!", Len(X3DESCRIC()), 0,".F.",""    , "C", "", "V" ,"" , "","","V"}) //"Descrição"
 nDescricao   := ++nUSX3

 aTabelas := {}

If FunName() == "HSPAHP04"
	cTabAnt  := "GAV"
	FS_MA7AdCp("GAV", @aTabelas, cCodLoc:=Space(Tamsx3("GAV_CODLOC")[1]))
Else
 FS_MA7AdCp("GBH", @aTabelas, cCodLoc)
 FS_MA7AdCp("GCY", @aTabelas, cCodLoc)
 FS_MA7AdCp("GB2", @aTabelas, cCodLoc)
 FS_MA7AdCp("BBD", @aTabelas, cCodLoc)
Endif
 aSize 			:= MsAdvSize(.T.)
 aObjects := {}

 aAdd( aObjects, { 100, 020, .T., .T.} )
 aAdd( aObjects, { 100, 080, .T., .T.} )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )


 DEFINE MSDIALOG oDlgCfg TITLE OemToAnsi(STR0074) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd // "Configuração de Campos"

  oGetSX2 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], 0,,,,,, 99999,,,,oDlgCfg, aHSX2, aCSX2)
  oGetSX2:bChange := {|| FS_MA7Chg(@oGetSX2, @oGetSX3, @aTabelas) }
  oGetSX2:oBrowse:Align := CONTROL_ALIGN_TOP

  oGetSX3 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], GD_UPDATE,,,,,, 99999,,,,oDlgCfg, aHSX3, aTabelas[1,2])
  oGetSX3:oBrowse:BlDblClick := {||FS_DblClk(@oGetSX3)}
  oGetSX3:oBrowse:Align := CONTROL_ALIGN_BOTTOM

 ACTIVATE MSDIALOG oDlgCfg ON INIT EnchoiceBar (oDlgCfg,	{|| nOpcDlg := 1, oDlgCfg:End()},;
                                                									{|| nOpcDlg := 0, oDlgCfg:End()})

 aTabelas[oGetSX2:nAt, 2] := aClone(oGetSX3:aCols)

 If nOpcDlg == 1
  FS_MA7GrCf(oGetSX2, aTabelas, cCodLoc)
 EndIf

Return()

Static Function FS_AdField(cAlias, aFieldTab, aFoldTab, cCodLoc)
 Local aArea    := GetArea()
 Local aAreaSX3 := SX3->(GetArea())
 Local cValid   := ""
 Local nOrdem   := 1, nFor := 0
 Local aCpo     := {}

 Default aFoldTab := {}

 If HS_CountTB("GMT", "GMT_CODLOC = '" + cCodLoc + "' AND GMT_TABELA = '" + cAlias + "'") == 0
  cCodLoc := SPACE(LEN(GMT->GMT_CODLOC))
 Endif

 DbSelectArea("GMT")
 DbSetOrder(1) //GMT_FILIAL+GMT_TABELA+GMT_ORDEM
 DbSeek(xFilial("GMT") + cCodLoc + cAlias)
 While !GMT->(Eof()) .And. GMT->GMT_FILIAL == xFilial("GMT") .And. cCodLoc == GMT->GMT_CODLOC .And. cAlias == GMT->GMT_TABELA

  DbSelectArea("SX3")
  DbSetOrder(2)
  If DbSeek(GMT->GMT_CAMPO) .And. GMT->GMT_MOSTRA == "1" // Se achar no dicionário e se eh pra mostrar esse campo
   cValid := IIf(!Empty(SX3->X3_VALID), AllTrim(SX3->X3_VALID), "")
   cValid += IIf(!Empty(cValid) .And. !Empty(SX3->X3_VLDUSER), " .And. " + AllTrim(SX3->X3_VLDUSER), IIf(!Empty(SX3->X3_VLDUSER), AllTrim(SX3->X3_VLDUSER), ""))

   //Cria os folders necessários
   DbSelectArea("SXA")
   DbSetOrder(1) //XA_ALIAS+XA_ORDEM
   If DbSeek(cAlias + SX3->X3_FOLDER)
    If (nFolder := aScan(aFoldTab, {| aVet | aVet == SXA->XA_DESCRIC})) == 0
     aAdd(aFoldTab, XADESCRIC())
     nFolder := Len(aFoldTab)
    EndIf
   Else
    nFolder := 0
   EndIf

   //Adiciona os campos num array temporário
   aAdd(aCpo, {PadL(AllTrim(Str(nFolder)), Len(SX3->X3_FOLDER)), PadL(AllTrim(Str(nOrdem)), Len(SX3->X3_ORDEM)), SX3->X3_CAMPO})

		EndIf
		nOrdem++
	 GMT->(DbSkip())
 End

	If aScan(aCpo, {|aVet| aVet[1] == "0"}) > 0 //Verifica se há algum campo com nfolder == 0
	 aAdd(aFoldTab, STR0075)//"Outros"          //Se tiver criar o folder "Outros"

	 For nFor := 1 To Len(aCpo)
	  If aCpo[nFor, 1] == "0"
	   aCpo[nFor, 1] := PadL(AllTrim(Str(Len(aFoldTab))), Len(SX3->X3_FOLDER))
	  EndIf
 	Next nFor
	EndIf

	aSort(aCpo,,,{|X,Y| X[1]+X[2] < Y[1]+Y[2] })// Ordena o array temporario -> Folder + Ordem

	//              1        2       3        4        5          6          7           8          9        10       11      12          13
 // aField = {<cTitle>,<cField>,<cType>,<nSize>,<nDecimal>,<cPicture>,<{uValid}>,<.lObrigat.>,<nLevel>,<cInitPad>,<cF3>,<{uWhen}>,<.lVisual.>,;
 //               14       15      16          17          18
 //           <.lChave.>,<cBox>,<nFolder>,<.lNAltera.>,<cPictVar>})

 For nFor := 1 To Len(aCpo)
  DbSelectArea("SX3")
  DbSetOrder(2)
  DbSeek(aCpo[nFor, 3])

  ADD FIELD aFieldTab TITULO     X3TITULO();
   												       CAMPO		    SX3->X3_CAMPO ;
                      TIPO		     SX3->X3_TIPO	;
                      TAMANHO	   SX3->X3_TAMANHO	;
	                     DECIMAL    SX3->X3_DECIMAL	;
	                     PICTURE	   SX3->X3_PICTURE	;
	                     NIVEL	     SX3->X3_NIVEL	;
	                     INITPAD	   SX3->X3_RELACAO	;
	                     F3	        SX3->X3_F3	;
	                     BOX	       X3CBOX()		;
	                     FOLDER	    Val(aCpo[nFor, 1])

	Next nFor

	RestArea(aAreaSX3)
	RestArea(aArea)
Return()

Static Function FS_MA7GrCf(oGetSX2, aTabelas, cCodLoc)
 Local aArea    := GetArea()
 Local nForSX2  := 0, nForCpo := 0
 Local aAreaSX3 := SX3->(GetArea())

 For nForSX2 := 1 To Len(oGetSX2:aCols)
  For nForCpo := 1 To Len(aTabelas[nForSX2, 2])
   DbSelectArea("GMT")
   DbSetOrder(2)
   If !DbSeek(xFilial("GMT") + cCodLoc + aTabelas[nForSX2, 1] + aTabelas[nForSX2, 2][nForCpo, nCampo])
    RecLock("GMT", .T.)
     GMT->GMT_FILIAL := xFilial("GMT")
     GMT->GMT_TABELA := aTabelas[nForSX2, 1]
     GMT->GMT_MOSTRA := IIf(aTabelas[nForSX2, 2][nForCpo, nMostra] == "LBTIK", "1", "0")
     GMT->GMT_ORDEM  := aTabelas[nForSX2, 2][nForCpo, nOrdem]
     GMT->GMT_CAMPO  := aTabelas[nForSX2, 2][nForCpo, nCampo]
     GMT->GMT_CODLOC := cCodLoc
    MsUnlock()
   Else
    RecLock("GMT", .F.)
     GMT->GMT_MOSTRA := IIf(aTabelas[nForSX2, 2][nForCpo, nMostra] == "LBTIK", "1", "0")
     GMT->GMT_ORDEM  := aTabelas[nForSX2, 2][nForCpo, nOrdem]
    MsUnlock()
   EndIf
  Next nForCpo
 Next nForSX2

 RestArea(aAreaSX3)
 RestArea(aArea)
Return

Static Function FS_MA7AdCp(cAlias, aTabelas, cCodLoc)
 Local aArea    := GetArea()
 Local aAreaSX3 := SX3->(GetArea())
 Local nFor     := 0

 aAdd(aTabelas, {cAlias, {}} )

 DbSelectArea("GMT")
 DbSetOrder(1)
 DbSeek(xFilial("GMT") + cCodLoc + cAlias)

 While !GMT->(Eof()) .And.  GMT->GMT_CODLOC == cCodLoc .And.  GMT->GMT_TABELA == cAlias
  SX3->(DbSetOrder(2))
  If !SX3->(DbSeek(GMT->GMT_CAMPO))
   RecLock("GMT", .F., .F.)
    DbDelete()
   MsUnlock   ()
   WriteSX2("GMT")
  Else
   aAdd(aTabelas[Len(aTabelas), 2], {IIf(GMT->GMT_MOSTRA == "1", "LBTIK", "LBNO"), "metas_cima_16", "metas_baixo_16", GMT->GMT_ORDEM, SX3->X3_CAMPO, X3TITULO(), X3DESCRIC(), .F.})
  EndIf
  GMT->(DbSkip())
 End

 GMT->(DbSetOrder(2))

 DbSelectArea("SX3")
 DbSetOrder(1)
 Dbseek(cAlias)
 While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias
  If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
   If !GMT->(DbSeek(xFilial("GMT") + cCodLoc + cAlias + SX3->X3_CAMPO))
    aAdd(aTabelas[Len(aTabelas), 2], {"LBNO", "metas_cima_16", "metas_baixo_16", Space(Len(SX3->X3_ORDEM)), SX3->X3_CAMPO, X3TITULO(), X3DESCRIC(), .F. })
   EndIf
  EndIf
  SX3->(DbSkip())
 End

 For nFor := 1 To Len(aTabelas[Len(aTabelas), 2])
  aTabelas[Len(aTabelas), 2][nFor, nOrdem] := StrZero(nFor, Len(SX3->X3_ORDEM))
 Next nFor

 RestArea(aAreaSX3)
 RestArea(aArea)
Return()

Static Function FS_MA7Chg(oGetSX2, oGetSX3, aTabelas)
 Local aArea := GetArea()
 Local nPos  := 0

 If cTabAnt # oGetSX2:aCols[oGetSX2:nAt, nArquivo]
  nPos := aScan(aTabelas, {| aVet | aVet[1] == cTabAnt})//procura conteudo anterior
  aTabelas[nPos, 2] := aClone(oGetSX3:aCols)//Guarda  o conteudo anterior do acols
  oGetSX3:SetArray(aTabelas[oGetSX2:nAt, 2])
  cTabAnt := oGetSX2:aCols[oGetSX2:nAt, nArquivo]
 EndIf

 oGetSX3:oBrowse:Refresh()

 RestArea(aArea)
Return()

Static Function FS_DblClk(oGet)

 Local nCol     := oGet:oBrowse:nColPos
 Local nLin     := oGet:oBrowse:nAt
 Local aCols    := aClone(oGet:aCols)
 Local cNovaOrd := ""

 If nCol == nSobe
  If nLin > 1
   cNovaOrd := oGet:aCols[nLin - 1, nOrdem]
   oGet:aCols[nLin - 1, nOrdem] := oGet:aCols[nLin, nOrdem]
   oGet:aCols[nLin, nOrdem] := cNovaOrd
   oGet:oBrowse:nAt--
  EndIf
 ElseIf nCol == nDesce
  If nLin < Len(oGet:aCols)
   cNovaOrd := oGet:aCols[nLin + 1, nOrdem]
   oGet:aCols[nLin + 1, nOrdem] := oGet:aCols[nLin, nOrdem]
   oGet:aCols[nLin, nOrdem] := cNovaOrd
   oGet:oBrowse:nAt++
  EndIf
 Else
  oGet:aCols[nLin, nMostra] := IIf(oGet:aCols[nLin, nMostra] == "LBNO", "LBTIK", "LBNO")
 EndIf

 aSort(oGet:aCols,,,{|x,y| x[nOrdem] < y[nOrdem]})

 oGet:oBrowse:Refresh()
Return(.T.)

Function HS_PreMA7(cAlias, nReg, nOpc, cTpNasc)
 Local aArea := GetArea()

 Private aRotina   := {{ "", "", 0 , 4},;
								               { "", "", 0 , 2},;
                       { "", "", 0 , 4},;
                       { "", "", 0 , 3}}

 IF(ValType(cTpNasc) <> "C")
  cTpNasc := ""
 Endif
 HS_MntAbq(cAlias, nReg, 1, , cTpNasc)

 RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HS_AntMA7³ Autor ³wsilva                 ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Antecedentes pessoais do paciente                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_AntMA7(cAlias,nReg,nOpc)
Local oDlgMA7
Local oEnchoice, oEnchFoto, oPanelEsq, oPanelDir
Local aMeiaTela, aSuperior
Local aPMemo
Local aCpoEnchoi := {}, aCpoEnchFT := {}
Local aButtons := {}
Local oBmp
Local cProntuario
Local bKeyF6,bKeyF7,bKeyF8
Local aCampos := {{"C", "GBH_ANTPES"},;
		{"C", "GBH_ANTFAM"},;
		{"C", "GBH_ANTOBS"},;
		{"C", "GMT_CODLOC"}}
Private	cAntPes := ""
Private	cAntFam := ""
Private	cAntObs := ""
Private aTela := {}, aGets := {}
Private lEdtCodLoc := INCLUI  //Campo lEdtCodLoc usado no dicionario (X3_WHEN) do campo GBH_CODLOC
	
	// Se não tiver os campos avisa e aborta
If !HS_ExisDic(aCampos, .T.)
	Return(.F.)
EndIf
	
	// Pega o prontuário do paciente
cProntuario := GCY->GCY_REGGER
if nOpc == 8
	If (lRet := Pergunte("HSPM7A", .T.))
		cProntuario := MV_PAR01       //HSPM7A   ¦ 01       ¦ Prontuário ?
	Else
		Return(.F.)
	Endif
Endif
	
// Botões
Aadd(aButtons, {"NOTE",           {|| FS_MsgInf(1)}, STR0078, STR0080}) //"Antecedentes Pessoais"###"Pessoais"
Aadd(aButtons, {"NOTE",           {|| FS_MsgInf(2)}, STR0079, STR0081}) //"Antecedentes Familiares"###"Famil."
Aadd(aButtons, {"NOTE",           {|| FS_MsgInf(3)}, STR0082, STR0083}) //"Antecedentes Clínicos e Cirúrgicos"###"Clin. e Cir."
Aadd(aButtons, {"PENDENTE",       {|| HS_M07HIST()}, STR0068, STR0068}) //"Histórico"###"Histórico"
bKeyF6 := SetKey( VK_F6, {|| FS_MsgInf(1)} ) //"Antecedentes Pessoais"
bKeyF7 := SetKey( VK_F7, {|| FS_MsgInf(2)} ) //"Antecedentes Familiares"
bKeyF8 := SetKey( VK_F8, {|| FS_MsgInf(3)} ) //"Antecedentes Clínicos e Cirúrgicos"

aCpoEnchoi := FS_CpoEnch(GCY->GCY_CODLOC) // Pegue os campos para enchoice
AADD(aCpoEnchFT, "GBH_BITMAP") // Pega o campo Foto para enchoice

// Joga dados do paciente na memoria
DbSelectArea("GBH")
DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
DbSeek(xFilial("GBH") + cProntuario)
RegToMemory("GBH",.F.) // Gera variavies de memoria para o GBH

aSize := MsAdvSize(.T.) // Pega o tamanho da tela
	
// Divide a tela em duas partes verticais
aObjects := {}
AAdd( aObjects, { 050, 100, .T., .T.} ) // Usar o quarto parâmetro se for usar folder
AAdd( aObjects, { 050, 100, .T., .T.} )
aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aMeiaTela := MsObjSize( aInfo, aObjects, .T.)
DEFINE MSDIALOG oDlgMA7 TITLE OemToAnsi(STR0001) From 0,0 TO aSize[6], aSize[5] PIXEL of oMainWnd//"Cadastro de Paciente"
DEFINE FONT oFont NAME "Arial" SIZE 10,20 BOLD
	
oEnchoice:=MsMGet():New("GBH", nReg, nOpc,,,,aCpoEnchoi,	{34, 0, aMeiaTela[1, 3], (aMeiaTela[1, 4]/2)-20}/*aSuperior[1]*/,,,,,,oDlgMA7)
@ 34,((aMeiaTela[1, 4]/2) + (aMeiaTela[1, 4]/4))-50  REPOSITORY oBmp SIZE (aMeiaTela[2, 1]),(aMeiaTela[1, 4]/5)  of oDlgMA7 Pixel
oBmp:lAutoSize := .F. // Para permitir stretch
//oBmp:Align     := CONTROL_ALIGN_ALLCLIENT
//oBmp:lStretch  := !oBmp:lStretch
oBmp:LoadBmp(M->GBH_BITMAP)
	
cAntPes := E_MSMM(GBH->GBH_ANTPES,10)
cAntFam := E_MSMM(GBH->GBH_ANTFAM,10)
cAntObs := E_MSMM(GBH->GBH_ANTOBS,10)
	
@ aMeiaTela[2, 1]+15,aMeiaTela[2, 2]+5 Say STR0078 Of oDlgMA7 Pixel Font oFont COLOR CLR_BLUE //"Antecedentes Pessoais"
@ aMeiaTela[2, 1]+30,aMeiaTela[2, 2]+1 Get oObsPes Var cAntPes MEMO SIZE (aMeiaTela[2, 4]/3)-5, aMeiaTela[2, 3]-aMeiaTela[2, 1]-30 OF oDlgMA7 Pixel
oObsPes:lReadOnly := .T.

@ aMeiaTela[2, 1]+15,aMeiaTela[2, 2]+6+((aMeiaTela[2, 4]/3)-5) Say STR0079 Of oDlgMA7 Pixel Font oFont COLOR CLR_BLUE //"Antecedentes Familiares"
@ aMeiaTela[2, 1]+30,aMeiaTela[2, 2]+2+((aMeiaTela[2, 4]/3)-5) Get oObsFam Var cAntFam MEMO SIZE (aMeiaTela[2, 4]/3)-5, aMeiaTela[2, 3]-aMeiaTela[2, 1]-30 OF oDlgMA7 Pixel
oObsFam:lReadOnly := .T.

@ aMeiaTela[2, 1]+15,aMeiaTela[2, 2]+7+((aMeiaTela[2, 4]/3)-5)*2 Say STR0082 Of oDlgMA7 Pixel Font oFont COLOR CLR_BLUE //"Antecedentes Clínicos e Cirúrgicos"
@ aMeiaTela[2, 1]+30,aMeiaTela[2, 2]+3+((aMeiaTela[2, 4]/3)-5)*2 Get oObsObs Var cAntObs MEMO SIZE (aMeiaTela[2, 4]/3)-5, aMeiaTela[2, 3]-aMeiaTela[2, 1]-30 OF oDlgMA7 Pixel
oObsObs:lReadOnly := .T.

ACTIVATE MSDIALOG oDlgMA7 ON INIT EnchoiceBar(oDlgMA7, {|| oDlgMA7:End()}, {|| oDlgMA7:End()},, aButtons)
SetKey(VK_F6, bKeyF6)
SetKey(VK_F7, bKeyF7)
SetKey(VK_F8, bKeyF8)

Return(NIL)

// Retorna os campos conforme seleção para mostrar na enchoice
Static Function FS_CpoEnch(cCodLoc)
 Local aCpoEnchoi := {}
	Local cSql := ""

 If HS_CountTB("GMT", "GMT_CODLOC = '" + cCodLoc + "' AND GMT_TABELA = 'GBH'") == 0
  cCodLoc := SPACE(LEN(GMT->GMT_CODLOC))
 Endif

 cSql := "SELECT GMT_CAMPO,GMT_ORDEM FROM "+RetSqlName("GMT")+" GMT WHERE GMT_FILIAL = '" + xFilial("GMT") + "' AND GMT.D_E_L_E_T_ <> '*' "
	cSql += "AND GMT_CODLOC = '" + cCodLoc + "' AND GMT_MOSTRA = '1' AND GMT_TABELA = 'GBH' ORDER BY GMT_ORDEM"

 cSql := ChangeQuery(cSql)
 TCQuery cSql New Alias "TMPGMT"
 DbSelectArea("TMPGMT")
 While !EOF()
 	If TMPGMT->GMT_CAMPO <> "GBH_BITMAP" // Conforme definição no Bops 135147 não
	 	AADD(aCpoEnchoi, TMPGMT->GMT_CAMPO) // pode apresentar foto aqui e sim em campo apropriado
	 EndIf
	 dbskip()
 End
 DBCloseArea()
Return(aCpoEnchoi)

// Editar os antecedentes
Static Function FS_MsgInf(nVal)
	Local oDlgMsg, oTexto, oBtnOk, oBtnCancel
	Local cMensagem := ""
	Local lOpc := .F.
	If nVal == 1
		cMensagem := STR0078 //"Antecedentes pessoais"
	ElseIf nVal == 2
		cMensagem := STR0079 //"Antecedentes familiares"
	ElseIf nVal == 3
		cMensagem := STR0082 //"Antecedentes Clínicos e Cirúrgicos"
	EndIf

	DEFINE MSDIALOG oDlgMsg FROM	62,100 TO 320,510 TITLE OemToAnsi(cMensagem) PIXEL
	 cMensagem := ""
		@ 005, 004 GET oTexto VAR cMensagem MEMO /*NO VSCROLL*/ SIZE 200, 100 OF oDlgMsg PIXEL
		oBtnOk := tButton():New(115, 100, "Ok", oDlgMsg, {|| lOpc := .T.,oDlgMsg:End()},,,,,,.T.)
		oBtnCancel := tButton():New(115, 140, "Cancel", oDlgMsg, {|| oDlgMsg:End()},,,,,,.T.)
		oBtnOk:SetFocus()
	ACTIVATE MSDIALOG oDlgMsg CENTERED

	// Grava no campo MEMO
	if lOpc
		PswOrder(1) // indice por ID
		PswSeek(__CUSERID,.T.)  // Pesquisa o ID no cadastro de usuario
	   	cChaveSRA := substr(substr(pswret(1)[1,22],3,tamsx3("RA_FILIAL")[1]+tamsx3("RA_MAT")[1]),1,7) +" "+SUBSTR(substr(pswret(1)[1,22],3,tamsx3("RA_FILIAL")[1]+tamsx3("RA_MAT")[1]),8,8)
		cMensagem := ">> " + DToC(dDataBase) + " - " + time() + " - " + Posicione("SRA",1,cChaveSRA,"RA_MAT") + " - DR(a). " + Alltrim(Posicione("SRA",1,cChaveSRA,"RA_NOME")) + " <<"+chr(13)+chr(10) + cMensagem + chr(13)+chr(10) + "_________________________________________________________"  + chr(13)+chr(10)
		If nVal == 1
			cAntPes += cMensagem
			MSMM(,10,,cAntPes,1,,,"GBH","GBH_ANTPES")
		ElseIf nVal == 2
			cAntFam += cMensagem
			MSMM(,10,,cAntFam,1,,,"GBH","GBH_ANTFAM")
		ElseIf nVal == 3
			cAntObs += cMensagem
			MSMM(,10,,cAntObs,1,,,"GBH","GBH_ANTOBS")
		EndIf
	EndIf
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Hs_CompEspºAutor  ³Microsiga           º Data ³  08/18/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para comparacao das especialidades entre o    º±±
±±º          ³medico e o medico virtual                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Hs_CompEsp(cCrmVir, cCrmMed)
Local aArea   := getArea()
Local lRet    := .F.
Local cEspVir := HS_REspMed(cCrmVir)+"/"	// Especialidades do medico virtual
Local cEspMed := HS_REspMed(cCrmMed)+"/"	// Especialidades do medico
Local nPos    := 1							// Inicializa na primeira posicao

While at("/", SubStr(cEspMed,nPos) ) > 0 // Verifica se não e o final das especialidades

	If (SubStr(cEspMed, nPos, at("/", SubStr(cEspMed,1) )-1) $  cEspVir)	// Compara cada especialidade do medico com a do medico virtual
		RestArea(aArea)
		Return(.T.)
	EndIf
	nPos := nPos + 3	// Pula de 3 em 3 casas, para verificar o codigo na especialidade corretamente //:= at("/", SubStr(cEspMed,nPos) )+1

End
RestArea(aArea)
Return(lRet)

Static Function Fs_EscAnm(cRegAte, lInclui, cTipo, cStatus,aAnmRet, lBtnInc)
 Local cRet    := Space(TamSx3("GFU_CDANAM")[1])
 Local nOpcAnm := 2
 Local aBtnAnm := {}
 Local aArea     := getArea()
 Default lBtnInc := .T.


  lInclui    := .T.

	 If (aAnmRet := Fs_RetAnms(GCY->GCY_REGATE, cTipo, cStatus))[1]

   If lBtnInc
	   aBtnAnm := {{"S4WB007N" , {|| nOpcAnm := 2, oDlgAnm:End() }, "Incluir Nova "+IIF(cTipo == "0","Anmnese","Retificadora"), "Incluir"}}
	  EndIf

	  DEFINE MSDIALOG oDlgAnm TITLE IIF(cTipo == "0","Anmneses","Retificadoras")+" em Aberto" From 000, 000 To 300, 500 Of oMainWnd Pixel

   oGDGfu := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlgAnm, aAnmRet[3], aAnmRet[4])
   oGDGfu:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlgAnm CENTERED ON INIT EnchoiceBar(oDlgAnm, {|| nOpcAnm := 1, oDlgAnm:End()}, {|| nOpcAnm := 0, oDlgAnm:End()},,aBtnAnm)

	  IF nOpcAnm # 0
    DbSelectArea("GFU")
    DbSetOrder(1)//GFU_FILIAL+GFU_CDANAM
    If nOpcAnm == 1
     If DbSeek(xFilial("GFU")+ oGDGfu:aCols[oGDGfu:nAt, aScan(aAnmRet[3],{|aVet| aVet[2] == "GFU_CDANAM"}) ])
      lInclui  := .F.
      cRet     := oGDGfu:aCols[oGDGfu:nAt, aScan(aAnmRet[3],{|aVet| aVet[2] == "GFU_CDANAM"}) ]
     EndIf
    Else
     DbSeek(xFilial("GFU")+ Space(TamSx3("GFU_CDANAM")[1]))
    EndIf
   EndIf
	 Else
   DbSelectArea("GFU")
   DbSetOrder(1)//GFU_FILIAL+GFU_CDANAM
   DbSeek(xFilial("GFU")+ Space(TamSx3("GFU_CDANAM")[1]))
	 EndIf

 RestArea(aArea)
Return({nOpcAnm, cRet})

Static Function Fs_RetAnms(cRegAte, cTipo, cStatus, lMarca)
 Local aArea     := getArea()
 Local cEspecMed := "'"+StrTran(cEspUsu,"/","','")+"'"
 Local aHGFU := {}, aCGFU := {}, nUGFU := 0
 Local nCntAnm := 0
 Local cCpos     := "GFU_REGATE/GFU_CDANAM/GFU_TPANAM/GFU_DSQUES/GFU_STANAM/GFU_CDQUES/GFU_CODESP"
 Local cCond     := ""

 Default lMarca := .F.

 cCond := "     GFU.GFU_REGATE = '"+cRegAte+"' "
 cCond += " AND GFU.GFU_CODCRM = '"+aCodUsr[2]+"'"
 cCond += IIF(cTipo   # nil .And. !Empty(cTipo)  ," AND GFU.GFU_TPANAM = '"+cTipo+"' ","")
 cCond += IIF(cStatus # nil .And. !Empty(cStatus)," AND GFU.GFU_STANAM = '"+cStatus+"'","")
 cCond += " AND (GFU.GFU_CODESP = '"+Space(TamSx3("GFU_CODESP")[1])+"' "
 cCond += " OR GFU.GFU_CODESP IN ("+cEspecMed+")) "

 nCntAnm := HS_BDados("GFU", @aHGFU, @aCGFU, @nUGFU, 1,, cCond,,,cCpos,,,,IIF(lMarca,"GFU_MMARCA",Nil),,.T.)

 aRet := {nCntAnm > 0,nCntAnm,aHGFU,aCGFU}

 RestArea(aArea)
Return(aRet)

Static Function Fs_VQueEsp(cCodQues, aHeader, aCols)
 Local aArea    := getArea()
 Local cQuesEsp := Hs_IniPadr("GFS", 1, cCodQues, "GFS_CODESP",,.F.)
 Local nGfuCodEsp := aScan(aHeader, {|aVet| aVet[2] == "GFU_CODESP"})
 Local nI := 0

 For nI := 1 to len(aCols)
  If aCols[nI, nGfuCodEsp] == cQuesEsp
   RestArea(aArea)
   Return(.F.)
  EndIf
 Next nI

 RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Bruno Santos          ³ Data ³ 11/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local lMVPromo := SuperGetMV("MV_PROSAUD", NIL, .F.)  // Promoção a Saude
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aRotAgd :=  { {STR0001, "HS_AgeMa7", 0, 03}, ; //"Ambulatorial"
                     {STR0002, "HS_AgeMa7", 0, 02}, ; //"Cons.Ambulat"
                     {STR0003, "HS_AgeMa7", 0, 03}, ; //"Reserva"
                     {STR0004, "HS_AgeMa7", 0, 02} }  //"Cons.Reserva"


Local  aRotRel     := {{STR0015, "HS_RelMA7()", 13, 2}, ;//"Docs/Relat."
		                 {OemtoAnsi(STR0093), 'HSPRQUES("GFK", "GFK_CDANAM", "","",GCY->GCY_REGATE,,,GCY->GCY_CODLOC)', 0, 2}} //"Anamnese

Local aRotina :=	{	{STR0006, "AxPesqui"	,	1,	1}, ; //"Pesquisar"
             									{STR0007, "HS_MntMA7",	2,	2}, ; //"Visualizar"
             									{STR0005, "HS_MntMA7",	3,	4}, ; //"Anamnese"
            	 								{STR0008, "HS_MntMA7",	4,	4}, ; //"Retificadora"
            	 								{STR0009, "HS_EncMA7",	5,	4}, ; //"Encaminhar"
            	 								{STR0010, "HS_ExcMA7",	6,	5}, ; //"Excluir"
            	 								{STR0011, "HS_PacMA7",	7,	2}, ; //"Paciente"
            	 								{STR0076, "HS_AntMA7",	15,	2},; //"Antecedentes"
            	 								{STR0012, "HS_PenMA7", 8, 2}, ; //"Pendências"
            	 								{STR0064, "HS_PreMA7", 9, 2}, ; //"Prescrição"
            	 								{STR0013, aRotAgd    ,	10,	4}, ;//"Agenda"
            	 								{STR0014, "HS_ExtMA7", 11, 2}, ;//"Extrato"
            	 								{STR0065, "HS_CfgMA7()",12, 4},;//"Config. Campos"
            	 								{STR0015, aRotRel	 , 13, 2}, ;//"Docs/Relat."
            	 								{STR0016, "HS_LegMa7", 14, 2}, ;//"Legenda"
            	 								{OemtoAnsi(STR0087), "HSPAHM08(GCY->GCY_REGATE)" , 15, 04} } //
If lMVPromo
	aadd(aRotRel,{OemtoAnsi(STR0147), 'PLSRPRO04("GCY->GCY_REGGER","")', 0, 2})
	If FindFunction('PLSRPRO03')
	   aadd(aRotRel,{OemtoAnsi(STR0146), 'PLSRPRO03("GCY->GCY_REGGER")', 0, 2})//"Graficos Crescimento/
   Endif
Endif 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona rotinas relacionadas a assinatura digital   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_HSPCERD","0") == "1"                
	aadd(aRotina,{STR0148, 'HMA7Ficha', 16, 2}) //"Ficha de Tratamento"
	aadd(aRotina,{STR0149, 'HS_AsLoMA7', 17, 2}) //"Assinatura em lote"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("HSMA7ROT")
	aRotAdic := ExecBlock("HSMA7ROT", .F., .F., {})
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf
Return(aRotina)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_VANMPA³ Autor ³ Rogerio Tabosa        ³ Data ³ 30/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a existencia de Anamnese para o atendimento       ³±±
±±³          ³ do paciente no setor do PA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNrReg - Registro de Atendimento atual do paciente         ³±±
±±³          ³ cCodLoc - Local atual do atendimento do paciente           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_VANMPA(cNrReg, cCodLoc)
Local aArea    	:= getArea()
Local cRegPa   	:= ""
Local cSql 		:= ""
Local lRet		:= .F.

If Empty(cNrReg) .OR. Empty(cCodLoc)
	Return("")
EndIf

DbSelectArea("GCS")
DbSetOrder(1)
If DbSeek (xFilial("GCS") + cCodLoc)
	If GCS->GCS_TIPLOC <> "0" .AND. GCS->GCS_TIPLOC <> "3"//Internacao
		Return("")
	EndIf
	GCS->(DbCloseArea())
EndIf

DbSelectArea("GCY")
DbSetOrder(1)
If DbSeek (xFilial("GCY") + cNrReg)
	If GCY->GCY_ATORIG <> "2" //Pronto Atendimento
		Return("")
	Else
		cSql := "SELECT GCY_REGATE FROM " + RetSqlName("GCY") + " WHERE GCY_ATEDST='" + GCY->GCY_REGATE + "' AND GCY_FILIAL= '" + xFilial("GCY") + "'  AND D_E_L_E_T_ <> '*' "
		cSql := ChangeQuery(cSql)
		TCQuery cSql New Alias "TMPGCY"
		DbSelectArea("TMPGCY")
 		If !EOF()
 			cRegPA  := TMPGCY->GCY_REGATE
 		EndIf
 		TMPGCY->(DbCloseArea())
	EndIf
	//GCY->(DbCloseArea())
EndIf

DbSelectArea("GFU")
DbSetOrder(2) //  FILIAL + REGATE + CODCRM + TPANAM + STANAM
If DbSeek(xFilial("GFU") + cRegPA)
	lRet := .T.
	GFU->(DbCloseArea())
EndIf

DbSelectArea("GBY")
DbSetOrder(5) //GBY_FILIAL+GBY_REGATE+GBY_SEQDES
If DbSeek(xFilial("GBY") + cRegPA)
	lRet := .T.
	GBY->(DbCloseArea())
EndIf

RestArea(aArea)
Return(IIf(lRet,cRegPA,""))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_EXANPA| Autor ³ Rogerio Tabosa        ³ Data ³ 30/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a Anamese do paciente no Pronto Atendimento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_EXANPA(cNrReg)
Local aArea    	:= getArea()
Local nRegGcy	:= 0
Local lExAnm	:= .F.
Local lExPE		:= .F.
Private cHistPA := ""
Private nVisPE	:= 1 // Somente visualizacao no pedido de Exames (1 = sim, 0 = nao)

If Empty(cNrReg)
	Return(Nil)
EndIf

cHistPA := cNrReg // utilizado nas outras funções para identificar que esta sendo visualizado os registros de outro atendimento

DbSelectArea("GCY")
DbSetOrder(1)
If DbSeek(xFilial("GCY") + cNrReg)

	DbSelectArea("GFU")
	DbSetOrder(2) //  filial + regate + codcrm + tpanam + stanam
	If DbSeek(xFilial("GFU") + cNrReg)
		lExAnm := .T.
	EndIf

	DbSelectArea("GBY")
	DbSetOrder(5) //GBY_FILIAL+GBY_REGATE+GBY_SEQDES
	If DbSeek(xFilial("GBY") + cNrReg)
		lExPE := .T.
	EndIf
	If 	!lExAnm .AND. lExPE
		HSPAHM08(GCY->GCY_REGATE,,,1)
	Else
		nRegGcy := GCY->(RecNo())
		HS_MntMA7("GCY", nRegGcy, 2)
	EndIf
EndIf

RestArea(aArea)
Return(cRegPA)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HSPMA7Bco³ Autor ³ Microsiga            º Data ³ 29/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Chama a rotina do Banco do Conhecimento.					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function HSPGBHBco(cRegGer, aCpoGbh)

Local aArea		:= GetArea()
Local aAreaGBH	:= GBH->(GetArea())
Local aRotBack	:= {}
Local cQuery	:= ""
Local cIndex	:= ""

Default aCpoGbh := {}
If Type("aRotina") == "U"
	Private aRotina := {}
Else
	DEFAULT aRotina := {}
Endif

DbSelectArea("GBH")
DbSetOrder(1)
DbSeek(xFilial("GBH") + cRegGer )         //cCdAnam

aRotBack	:= aRotina
aRotina 	:= {{"Conhecimento",'MsDocument',0,3}} //"Conhecimento"

DbSelectArea("GBH")
cIndex := CriaTrab(NIL,.F.)

cQuery := "GBH_FILIAL == '" + xFilial("GBH") + "' "
cQuery += " .And. GBH_CODPAC == '" + cRegGer + "'"
//cQuery += " .And. GBH_CODCRM == '" + cCodCrm + "'"
//cQuery += " .And. GFU_CDANAM == '" + cCdAnam + "'"

IndRegua("GBH",cIndex,GBH->(IndexKey()),,cQuery)

If GBH->(!Eof())
	if empty(aCpoGbh)
		MaWndBrowse(0,0,300,600,"Conhecimento - Paciente","GBH",,aRotina,,,,.T.,,,,,,.F.) //"Conhecimento - Liberação / Autorização Odontológica"
	else
		MaWndBrowse(0,0,300,600,"Conhecimento - Paciente","GBH",aCpoGbh,aRotina,,,,.T.,,,,,.F.,.F.) //"Conhecimento - Liberação / Autorização Odontológica"
	endif
EndIf

RetIndex( "GBH" )
dbClearFilter()
FErase( cIndex+OrdBagExt() )

aRotina := aRotBack

dbSelectArea("GBH")
dbSetOrder(1)

RestArea(aAreaGbh)
RestArea(aArea)

Return .T.

Static Function FS_ALTIMG(cImg, cDirImg)
Local cImgRet
Default cDirImg :=  ""

If Empty(cImg)
	cImgRet := HS_EDITIMG("", cDirImg)
Else
	cImgRet := HS_EDITIMG(cImg, cDirImg)
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


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_EDITIMG³ Autor ³ SAude            º Data ³ 16/11/10     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina para edição de imagens no Gestão Hospitalar     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

Function HS_EDITIMG(cImg, cDirImg, cIdFoto)
Local lMVUDrFoto := (GetMV("MV_UDRFOTO",, "0") == "1")
Private __cArqAnamnese := "" //Variavel utilizada no FUNCB para atribuir foto capturada
Private isText := .F.
Private colors := {CLR_HRED, -1} // Linha Vermelha / Fundo Transparente
Default cImg := ""
Default cDirImg := ""
Default cIdFoto := "000001"

Private cFileRet := cImg

DEFINE DIALOG oDlg TITLE "Edição de Imagem" FROM 180,180 TO 550,700 PIXEL

// Menu de Opções
oMenu := TMenu():New()
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Abre',,,,{||isText:=.F.,openFile(cDirImg)}))
If lMVUDrFoto
	oMenu:Add(TMenuItem():New(oMenu:Owner(),'Captura',,,,{||isText:=.F.,FS_CAPFOTO(cIdFoto)}))
EndIf
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Salva',,,,{|| isText :=.F.,saveFile(cImg,cDirImg)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Texto',,,,{||isText:=.T.}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Selecao',,,,{||isText:=.F.,oDrawer:SetType(0)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Traço',,,,{||isText:=.F.,oDrawer:SetType(1)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Livre',,,,{||isText:=.F.,oDrawer:SetType(2)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Circulo',,,,{||isText:=.F.,oDrawer:SetType(3)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Retang.',,,,{||isText:=.F.,oDrawer:SetType(4)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Oval',,,,{||isText:=.F.,oDrawer:SetType(5)}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Fonte',,,,;
{||oDrawer:SetFontText(TFont():New('Verdana',0,-30)),alert('Fonte alterada')}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Cores',,,,{||defineColor()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Desfaz',,,,{||oDrawer:Undo()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Recorta',,,,{||oDrawer:Crop()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Cola',,,,{||oDrawer:Paste()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Limpa',,,,{||cFileRet:="",oDrawer:ClearImage()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Confirma',,,,{|| oDlg:end()}))
oMenu:Add(TMenuItem():New(oMenu:Owner(),'Cancela',,,,{||cFileRet:="",oDlg:End()}))

// Cria Scroll e TDrawer para a imagem
oTScrollBox :=  TScrollBox():New(oDlg,02,80,184,180,.T.,.T.,.T.)
oDrawer := tDrawer():New(0,0,oTScrollBox,900,550)

// Define cores iniciais
oDrawer:SetColors(colors[1], colors[2])

// Blocos de código do mouse
oDrawer:blClicked := {|o,x,y| click(x,y)}
//oDrawer:brClicked := {|o,x,y| Alert('Click direito do mouse')}

if ( file(cImg) )
	oDrawer:OpenImage(cImg)
	cFileRet := cImg
endif

ACTIVATE MSDIALOG oDlg CENTERED ON INIT If(Empty(cImg),(openFile()),Nil)


Return(cFileRet)

//------------------------------
// Funções de apoio
//------------------------------

Static Function FS_CAPFOTO(cIdFoto)
Local oEnchoice
HS_CapFoto(cIdFoto, oEnchoice, "M->GBH_BITMAP", .T.)
If !Empty(__cArqAnamnese)
	If ( File(__cArqAnamnese) )
		oDrawer:OpenImage(__cArqAnamnese)
		cFileRet := __cArqAnamnese
	Endif
EndIf
Return()

Static Function click(x,y)
if (isText)
	text := 'Digite o texto'
	inputQuery('Adiciona texto','Digite texto - "|" para pulo de linha',@text)
	oDrawer:AddText(x,y,text)
endif
Return

Static Function openFile(cDirImg)
cFile := AllTrim( cGetFile( 'Arquivo JPG|*.Jpg|Arquivo PNG|*.Png|Arquivo BMP|*.Bmp',;
'Selecione arquivo', 0, IIf(Empty(cDirImg),'C:\Dir\',cDirImg), .T.,;
GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ) )

if ( file(cFile) )
	oDrawer:OpenImage(cFile)
	cFileRet := cFile
endif
Return


Static Function saveFile(cImgPad,cDirImg)
Local cFile := ""
Local lSubs	:= .F.
Default cImgPad := ""

While !lSubs
	cFile := IIf(!Empty(cImgPad),cImgPad,IIf(Empty(cDirImg),'C:\Dir\imagem.JPG', Alltrim(cDirImg) + 'imagem.JPG'))
	inputQuery('Salva imagem','Arquivo (JPG, PNG ou BMP)',@cFile)
	If (File(cFile))
		If MsgYesno("Arquivo já existe, deseja substitui-lo?",STR0021)
			lSubs := .T.
		EndIf
	Else
		lSubs := .T.
	EndIf
EndDo
oDrawer:SaveImage( cFile, 'JPG' )
cFileRet := cFile
Return

Static Function inputQuery(cTitulo,cDescr,cResult)
Local cGet1 := PadR(cResult,200)
Local oGet1
Local oDlgInput
DEFINE MSDIALOG oDlgInput TITLE cTitulo FROM 178,181 TO 270,443 PIXEL

@ 002,002 Say cDescr Size 131,008 of oDlgInput Pixel
@ 014,002 Get oTGet VAR cGet1 SIZE 130,009 PIXEL OF oDlgInput
oBtn1 := TButton():New( 30,002, 'Ok'     , oDlgInput,;
{|| cResult:=Trim(cGet1),oDlgInput:End() },25,15,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtn2 := TButton():New( 30,034, 'Cancela', oDlgInput,;
{|| cResult:='',oDlgInput:End() },25,15,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgInput CENTERED
Return

Static Function defineColor()
Local oDlgColor
DEFINE MSDIALOG oDlgColor TITLE 'Escolhe as Cores Linha/Fundo' FROM 01,01 TO 450,450 PIXEL

oColorPen   := tColorTriangle():New(001,02,oDlgColor,200,100)
oColorBrush := tColorTriangle():New(102,02,oDlgColor,200,100)
oBtn1 := TButton():New( 202,006, 'Ok', oDlgColor,{|| colors[1] := oColorPen:retColor(),;
colors[2]:=oColorBrush:retColor(),oDlgColor:End() },;
25,15,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgColor CENTERED

// Define cores para a pintura
oDrawer:SetColors(colors[1], colors[2])
Return

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

Static Function FS_ATUIMG(cImg,lVis)
Default lVis := .F.
If !Empty(cImg)
	If lVis
		oTBitmap2:Load( , cImg )
		oTBitmap2:Refresh()
	Else
		oTBitmap1:Load( , cImg )
		oTBitmap1:Refresh()
	EndIf
EndIf
Return()

Static Function FS_AddLin(cDirImg)

oGDGt8:lChgField := .F.
oGDGt8:AddLine(.T., .F.)
oGDGt8:lNewLine := .F.

FS_ALTIMG("", cDirImg)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VISIMG ºAutor  ³Saude                º Data ³  16/11/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para visualizar a imagem do questionario     .       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_VISIMG(cCdAnam)

aCGt8Vis := {}
aHGt8Vis := {}

HS_BDados("GT8", @aHGt8Vis, @aCGt8Vis, , 1,, "GT8->GT8_CHAVE = '" + cCdAnam + "'",, ,,,,,,,, ,,,,,, ,, )

oGDGt8Vis:SetArray(aCGt8Vis)
oGDGt8Vis:oBrowse:Refresh()

If Empty(aCGt8Vis)  .OR. (Len(aCGt8Vis) == 1 .AND. Empty(aCGt8Vis[1, nGT8Arquiv]))
	oFolVisImg:aDialogs[2]:lActive := .F.
Else
	oFolVisImg:aDialogs[2]:lActive := .T.
EndIf
FS_ATUIMG(oGDGt8Vis:aCols[oGDGt8Vis:nAt, nGT8Arquiv],.T.)

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ALTCLI    ºAutor  ³Microsiga           º Data ³  12/21/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ALTA AUTOMATICA E GERACAO DE CONTAS NO PLS                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AltCli()
Local lIntegr  := GetMv("MV_HSPPLS")
Local lAltaCli := SuperGetMV("MV_ALTACLI", NIL, .F.)  // Alta após confirmar o atendimento
Local aProcPls := {}

	DbSelectArea("GCZ")
	DbSetOrder(2)
	DbSeek(xFilial("GCZ") + M->GCY_REGATE)

	DbSelectArea("GA9")
	DbSetOrder(1)
	DbSeek(xFilial("GA9") + GCZ->GCZ_CODCON)

	DbSelectArea("GCM")
	DbSetOrder(2)
	DbSeek(xFilial("GCM") + GCZ->GCZ_CODPLA)

	DbSelectArea("GD4")
	DbSetOrder(1)
	DbSeek(xFilial("GD4") + M->GCY_REGGER + GCZ->GCZ_CODPLA)

	DbSelectArea("GBJ")
	DbSetOrder(1)
	DbSeek(xFilial("GBJ") + M->GCY_CODCRM)

	DbSelectArea("GCS")
	DbSetOrder(1)
	DbSeek(xFilial("GCS") + M->GCY_CODLOC)

	If M->GCY_ATENDI $ "14" .And. lIntegr .And. GA9->GA9_REDPRO == "1" .And. lAltaCli .And. !Empty(SuperGetMV("MV_TPALTAM", NIL, ""))
		DbSelectArea("GCY")
		DbSetOrder(1)//GCY_FILIAL, GCY_REGATE
		If DbSeek(xFilial("GCY")+M->GCY_REGATE)
			RecLock("GCY", .F.)
			GCY->GCY_DATALT := DDATABASE
			GCY->GCY_HORALT := TIME()
			GCY->GCY_CRMALT := aCodUsr[2]
			GCY->GCY_TPALTA := SuperGetMV("MV_TPALTAM", NIL, "01")
			GCY->GCY_LOGALT	:= HS_LogArq()
			MsUnLock()
		EndIf

		DbSelectArea("GCZ")
		DbSetOrder(2)//GCZ_FILIAL, GCZ_REGATE, GCZ_STATUS, GCZ_NRSEQG
		DbSeek(xFilial("GCZ") + M->GCY_REGATE)
		While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .And. GCZ->GCZ_REGATE == M->GCY_REGATE
			If GCZ->GCZ_STATUS == "0" .And. Empty(GCZ->GCZ_DCPARF)
				RecLock("GCZ", .F.)
				GCZ->GCZ_DCPARF := DDATABASE
				MsUnLock()
			Endif
			DbSkip()
		EndDo
        //Posiciona novamente na GCZ
		DbSelectArea("GCZ")
		DbSetOrder(2)//GCZ_FILIAL, GCZ_REGATE, GCZ_STATUS, GCZ_NRSEQG
		DbSeek(xFilial("GCZ") + M->GCY_REGATE)

		cRdaGBJ := GBJ->GBJ_RDAPLS
		cRdaLoc := GBJ->GBJ_RDALOC
		cRdaEsp := GBJ->GBJ_RDAESP

		cSqlDes := " SELECT GA7_TIPPRO, GA7_TABPLS, GA7_PROPLS, GD7_CODDES, GD7_QTDDES, GD7_DATDES, GA7_CODESP, GD7_DENREG, GD7_FADENT, GD7_SEQDES "
		cSqlDes += " FROM " + RetSqlName("GD7") + " GD7 "
		cSqlDes += " JOIN " + RetSqlName("GA7") + " GA7 ON GD7_CODDES = GA7_CODPRO "
		cSqlDes += " AND GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
		cSqlDes += " AND GA7_PROPLS <> '" + SPACE(TamSx3("GA7_PROPLS")[1]) + "'"
		cSqlDes += " AND GA7_TABPLS <> '" + SPACE(TamSx3("GA7_TABPLS")[1]) + "'"
		cSqlDes += " WHERE  GD7.GD7_NRSEQG = '" + GCZ->GCZ_NRSEQG + "' "
		cSqlDes += " AND GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_STAPLS <> '1' "

		cSqlDes := ChangeQuery(cSqlDes)
		TCQuery cSqlDes New Alias "TMPGD7"

		DbSelectArea("TMPGD7")
		If !Eof()
			cCodEsp	:= TMPGD7->GA7_CODESP
			dDatPro := STOD(TMPGD7->GD7_DATDES)
			While !Eof()
				AADD(aProcPls,{TMPGD7->GA7_TABPLS,TMPGD7->GA7_PROPLS,TMPGD7->GD7_QTDDES, TMPGD7->GD7_DENREG , TMPGD7->GD7_FADENT, TMPGD7->GD7_SEQDES, TMPGD7->GA7_TIPPRO})
				DbSkip()
			EndDo
		EndIf
		DbSelectArea("TMPGD7")
		DbCloseArea()

		If Alltrim(GCS->GCS_TIPLOC) $ "1J" .And. GA9->GA9_REDPRO == "1" .And. ((GA9->GA9_CTAMED == "1" .And. GCM->GCM_CTAMED <> "0") .Or. GCM->GCM_CTAMED == "1") .And. Len(aProcPls) > 0
			//GERAR CONTAS MÉDICAS NO PLS
			HS_VldPLS(	GD4->GD4_MATRIC, M->GCY_NOME, M->GCY_DTNASC, GCZ->GCZ_CODPLA, "", 0, dDatPro, "  :  ",;
			M->GCY_CIDALT,  cRdaEsp,;
			HS_IniPadR("GBJ", 1, GCZ->GCZ_CODCRM, "GBJ_RDAPLS",, .F.),;
			cRdaGBJ	, aProcPls, cRdaGBJ,"99",.F.)
		EndIf
	EndIf
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PProRefresh  ºAutor  ³Microsiga        º Data ³  01/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ rEFRESH NO oBJETO                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PProRefresh()
Local nReg    := 0
DbSelectArea("GCY")
nReg          := RecNo()
//DbGoTop()
oMBrwGCY:Refresh()
DbGoTo(nReg)
//GCY->(DbGoTop())

//DbSelectArea("GM8")
//DbGoTop()
//oMBrwGM8:Refresh()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fs_CrmQry ³ Autor ³                    ³ Data ³21.12.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna todas as especialidades do Profissional               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Todas as especialidades separadas por "/"              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Crm do Profissional                                    ³±±
±±³	         ³ExpL2: Se usuario seleciona especialidade quando houver mais  ³±±
±±³	         ³       de uma                                            (OPC)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fs_CrmQry(cEspecMed)
 Local cSqlcrm := "",  aArea := GetArea()  ,cLstEsp:=""



   cSqlcrm := "SELECT GBJ_CRM  "
   cSqlcrm +=  "                    FROM "+RetSqlName("GBJ")+" GBJ "
   cSqlcrm +=  "                   WHERE GBJ.GBJ_FILIAL = '"+xFilial("GBJ")+"' AND GBJ.D_E_L_E_T_ <> '*' "
   cSqlcrm +=  "                     AND GBJ.GBJ_CRMVIR = '1' "
   cSqlcrm +=  "                     AND (GBJ.GBJ_ESPEC1 in ("+cEspecMed+") OR GBJ.GBJ_ESPEC2 in ("+cEspecMed+") OR GBJ.GBJ_ESPEC3 in ("+cEspecMed+") "
   cSqlcrm +=  "                      OR  GBJ_CRM IN (SELECT GFP_CODCRM "
   cSqlcrm +=  "                                        FROM "+RetSqlName("GFP")+" GFP "
   cSqlcrm +=  "                                       WHERE GFP.GFP_FILIAL = '"+xFilial("GFP")+"' AND GFP.D_E_L_E_T_ <> '*' "
   cSqlcrm += "                                         AND GFP_CODESP IN ("+cEspecMed+")  ) ) "



 TCQuery cSqlcrm New Alias "TMPCODCRM"

  While !Eof()

 	 cLstEsp +=  "'" + TMPCODCRM->GBJ_CRM +"'/"

  	DbSkip()
 End


cLstEsp := IIF(lFilVir, ""+StrTran(SUBSTR(cLstEsp,1,LEN(cLstEsp)-1),"/",",")+"","")

DbSelectArea("TMPCODCRM")
TMPCODCRM->(DbCloseArea())


 RestArea(aArea)
Return(cLstEsp)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fs_GCZQry  ºAutor  ³Microsiga           º Data ³  01/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Busca informação Da Gcy                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*Static Function Fs_GCZQry(cPlaDe,cPlaAte)
 Local cSqlGCZ := ""
 Local aArea := GetArea()
 Local cLstEsp:=""

   cSqlGCZ += "SELECT GCZ.GCZ_REGATE "
   cSqlGCZ += "FROM " + RetSqlName("GCZ") + " GCZ "
   cSqlGCZ += " WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' "
   cSqlGCZ += " AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_REGATE = GCY_REGATE "
   If !Empty(cPlaDe)
    cSqlGCZ += " AND GCZ.GCZ_CODPLA >= '" + cPlaDe + "'"
   EndIf

   If !Empty(cPlaAte)
    cSqlGCZ += " AND GCZ.GCZ_CODPLA <= '" + cPlaAte + "'"
   EndIf
TCQuery cSqlGCZ New Alias "TMPCODGCZ"

  While !Eof()

 	 cLstEsp +=  TMPCODGCZ->GCZ_REGATE+"/"

  	DbSkip()
 End


cLstEsp := IIF(lFilVir, "'"+StrTran(cLstEsp,"/",",")+"'","")

DbSelectArea("TMPCODGCZ")
TMPCODGCZ->(DbCloseArea())

 RestArea(aArea)
Return(cLstEsp)
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_MA7GEATºAutor  ³Microsiga           º Data ³  01/16/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o atendimento automatico atraves do browse do medico  º±±
±±º          ³ pulando o processo de recepcao do paciente                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SAUDE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_MA7GEAT()
Local aArea := getArea()

GBJ->(DbSetOrder(1))
GBJ->(MsSeek(xFilial("GBJ") + aCodUsr[2]))

GCS->(DbSetOrder(1))
GCS->(MsSeek(xFilial("GCS") + GM8->GM8_CODLOC))

If GCS->( FieldPos('GCS_PMTATE') ) > 0 .And. GBJ->( FieldPos('GBJ_PMTATE') ) > 0
	If !(GBJ->GBJ_PMTATE == "1" .AND. GCS->GCS_PMTATE == "1") // verifica se o profissional tem permissao e o setor tambem para o atendimento direto
		HS_MsgInf("Profissional e/ou setor de atendimento nao permite recepcionar diretamente!", STR0021, STR0042)
		Return(Nil)
	EndIf
EndIf


If MsgYesno("Deseja realmente recepcionar o paciente?",STR0021) // GERA OS REGISTROS NECESSARIOS PARA O ATENDIMENTO
	If GM8->GM8_STATUS == '1' .AND. Empty(GM8->GM8_REGATE) //0=liberado;1=Ocupado;2=Bloqueado;3=Atendido;4=Ocupado/Bloqueado;5=Confirmado;6=Retorno
		MsgRun("Aguarde, atualizando...",, { || cRegAte:= HS_GATEAGE(	GM8->GM8_REGGER, GM8->GM8_CODCRM, Posicione("GCM", 2, xFilial("GCM") + GM8->GM8_CODPLA, "GCM_CODCON"),;
												GM8->GM8_CODPLA,"1" , GM8->GM8_CODLOC, Posicione("GD4", 1, xFilial("GD4") + GM8->GM8_REGGER + GM8->GM8_CODPLA,;
		 										"GD4_MATRIC"), , , GM8->GM8_CODAGE, .T.)})
	Else
		HS_MsgInf("Somente pacientes com status de Agenda Ocupada podem ser recepcionados!", STR0021, STR0042)
	EndIf
EndIf
PProRefresh()
RestArea(aArea)
Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fs_CrmExcl ³ Autor ³                    ³ Data ³01.09.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Crm do Profissional com Exlusividades               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Todas os Profissionais separados por "/"              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fs_CrmExcl()
Local cSqlExc := ""
Local  aArea 	:= GetArea()  
Local cLstEsp	:=	""

cSqlExc := "SELECT GBJ_CRM  "
cSqlExc +=  "                    FROM "+RetSqlName("GBJ")+" GBJ "
cSqlExc +=  "                   WHERE GBJ.GBJ_FILIAL = '"+xFilial("GBJ")+"' AND GBJ.D_E_L_E_T_ <> '*' "
cSqlExc +=  "                     AND GBJ.GBJ_PROEXC IN( '1') "
TCQuery cSqlExc New Alias "TMPCRMEXC"

 While !Eof()
	 cLstEsp +=  TMPCRMEXC->GBJ_CRM +"/"
  	DbSkip()
 End

cLstEsp := IIF(lFilExcl, "'"+StrTran(SUBSTR(cLstEsp,1,LEN(cLstEsp)-1),"/","','")+"'","'")

DbSelectArea("TMPCRMEXC")
TMPCRMEXC->(DbCloseArea())

RestArea(aArea)
Return(cLstEsp)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_AsLoMA7 ³ Autor ³ TOTVS                 ³ Data ³26.01.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a assinatura do certificado digital por lote         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function HS_AsLoMA7()

Local nTipoRel  := 0
Local dDataDe   
Local dDataAte  
Local cProf      := ""
Local aLog       := {}
Local aGuiasLote := {}
Local aMntImp    := {}
Local nCont      := 0
Local cFolderXml := ""    
Local lOk        := .T.

Local cQuaint    := ""
Local cLeiInt    := ""
Local cImpVia    := ""
Local cStatus    := ""
					
If !Pergunte("HSPMA7CD")
	Return
EndIf

nTipoRel   := mv_par01
dDataDe    := mv_par02
dDataAte   := mv_par03
cProf      := mv_par04     
nProInativ := mv_par05       

If Empty(cProf) .And. nProInativ <> 2
	MsgInfo(STR0150) //"É necessário informar o profissional."
	Return
EndIf       

If nProInativ == 2
	cProf := ""     
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query de certificacao de anameneses       									         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipoRel == 1
	
	cSQL := " SELECT GFU.R_E_C_N_O_, GFU_NOMPAC, GFU_REGATE, GFU_DATCON, GFU_CODCRM FROM "+RetSqlName("GFU")+ " GFU " 
	If nProInativ == 2
		cSQL += " INNER JOIN "+RetSqlName("GBJ")+" GBJ"
	    cSQL += " ON GBJ_CRM = GFU_CODCRM "  
	    cSQL += " AND GBJ_FILIAL = '"+xFilial("GBJ")+"' "  
	    cSQL += " AND GBJ_STATUS = '0' "
	    cSQL += " AND GBJ.D_E_L_E_T_ <> '*' "
    EndIf
	cSQL += " WHERE GFU_FILIAL = '"+xFilial("GFU")+"' " 
	If nProInativ <> 2	
		cSQL += " AND GFU_CODCRM = '"+ cProf  +"' "     
	EndIf	
	cSQL += " AND GFU_DATCON >= '"+Dtos(dDataDe)+"' "   
    cSQL += " AND GFU_DATCON <= '"+Dtos(dDataAte)+"' "   	
	cSQL += " AND GFU_STAASS <> '1' "
	cSQL += " AND GFU.D_E_L_E_T_ <> '*' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)     
	TcSetField("TRB","GFU_DATCON","D",8,0)
	While !Trb->( Eof() )           
	
	 	AaDd(aLog,{TRB->GFU_REGATE,TRB->GFU_NOMPAC,TRB->GFU_CODCRM,Substr(Dtos(TRB->GFU_DATCON),7,2)+"/"+Substr(Dtos(TRB->GFU_DATCON),5,2)+"/"+Substr(Dtos(TRB->GFU_DATCON),1,4)})
		Trb->( DbSkip() )
	EndDo
   
Else
	cSQL := " SELECT GHV.R_E_C_N_O_, GCY.GCY_NOME, GHV.GHV_REGATE, GCY.GCY_REGGER, GHV.GHV_DATPRE, "
	cSQL += " GCY.GCY_CODLOC, GCY.GCY_DATATE, GHV.GHV_CODCRM FROM "+RetSqlName("GHV")+" GHV "
	
	cSQL += " INNER JOIN "+RetSqlName("GCY")+" GCY" 
    cSQL += " ON GCY_REGATE = GHV_REGATE " 
    cSQL += " AND GCY_FILIAL = '"+xFilial("GCY")+"' "   
	cSQL += " AND GCY.D_E_L_E_T_ <> '*' "
    
	If nProInativ == 2
		cSQL += " INNER JOIN "+RetSqlName("GBJ")+" GBJ"
	    cSQL += " ON GBJ_CRM = GHV_CODCRM "  
	    cSQL += " AND GBJ_FILIAL = '"+xFilial("GBJ")+"' "  
	    cSQL += " AND GBJ_STATUS = '0' "
	    cSQL += " AND GBJ.D_E_L_E_T_ <> '*' "
    EndIf        
    
   	cSQL += " WHERE GHV_FILIAL = '"+xFilial("GHV")+"' "
	
	If nProInativ <> 2	
		cSQL += " AND GHV_CODCRM = '"+ cProf  +"' "   
	EndIf
	cSQL += " AND GHV_DATPRE >= '"+Dtos(dDataDe)+"' "   
    cSQL += " AND GHV_DATPRE <= '"+Dtos(dDataAte)+"' "   
    cSQL += " AND GHV_STATUS = '3' " 	
	cSQL += " AND GHV_STAASS <> '1' "
	cSQL += " AND GHV.D_E_L_E_T_ <> '*' "

	

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)     
	TcSetField("TRB","GHV_DATPRE","D",8,0)
	TcSetField("TRB","GCY_DATATE","D",8,0)
	While !Trb->( Eof() )           
	
	 	AaDd(aLog,{TRB->GHV_REGATE,TRB->GCY_NOME,TRB->GHV_CODCRM,Substr(Dtos(TRB->GHV_DATPRE),7,2)+"/"+Substr(Dtos(TRB->GHV_DATPRE),5,2)+"/"+Substr(Dtos(TRB->GHV_DATPRE),1,4)})
		Trb->( DbSkip() )
	EndDo
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe registros para realizar a assinatura							       			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len(aLog) > 0
	PLSCRIGEN(aLog,{ {STR0151,"@C",6} , {STR0152,"@C",40 },{STR0153,"@C",10 }, {STR0154,"@C",8 }  },STR0155) //"Reg.Atend."##"Paciente"##"Reg.Prof."##"Data"##"Registros não certificados"
EndIf

If len(aLog) > 0 .And. MsgYesNo(STR0156) //"Confirma a assinatura em lote dos registros selecionados?"
	cFolderXml := "cert"+Dtos(Date()) + "_"+Strtran(Time(),":","")
	Trb->(DbGoTop())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera PDFs de anamnese                    							       			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipoRel == 1
		While !Trb->( Eof() )    
			GFU->(DbGoTo(TRB->R_E_C_N_O_))       
			HSPRQUES("GFK", "GFK_CDANAM",,, GFU->GFU_REGATE,, GFU->GFU_CODCRM,,.T.,GFU->GFU_CDANAM,.T.,@aGuiasLote)
			Trb->( DbSkip() )
		EndDo    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera PDFs de prescricao                   							       			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else  
		GHX->(DbSetOrder(4))//GHX_FILIAL + GHX_SEQPRE + GHX_REGATE + GHX_SEQITE
		GB1->(DbSetOrder(1))//GB1_FILIAL+GB1_REGATE+DTOS(GB1_DATAE)+GB1_HORAE
		
		While !Trb->( Eof() )      
			GHV->(DbGoTo(TRB->R_E_C_N_O_))  
			If GHX->(DbSeek(xFilial("GHX")+GHV->(GHV_SEQPRE + GHV_REGATE))) 
				aMntImp := {}      
				While GHV->(GHV_SEQPRE+GHV_REGATE) == GHX->(GHX_SEQPRE+GHX_REGATE) .And. !GHX->(Eof())
					
					GFZ->(DbSetOrder(1))
					GFW->(DbSetOrder(1))
					GFY->(DbSetOrder(1))
					GHS->(DbSetOrder(1))
					
					If GB1->(DbSeek(xFilial("GB1")+GHV->GHV_REGATE+Dtos(TRB->GCY_DATATE)))
						While GHV->GHV_REGATE+Dtos(TRB->GCY_DATATE) == GB1->GB1_REGATE+Dtos(GB1->GB1_DATAE) .And. !GB1->(Eof())
							If GHV->GHV_DATPRE >= GB1->GB1_DATAE .And. (GHV->GHV_DATPRE <= GB1->GB1_DATAS .Or. Empty(GB1->GB1_DATAS)) 
								cQuaint := GB1->GB1_QUARTO
								cLeiInt := GB1->GB1_LEITO
								Exit
							EndIf
							GB1->(DbSkip())
						EndDo
					EndIf
					
				   GHV->(RecLock("GHV",.F.))
					If Empty(GHV->GHV_IMPVIA)
			   			GHV->GHV_IMPVIA := "0"
		   			ElseIf GHV->GHV_IMPVIA <> "1"
			   			GHV->GHV_IMPVIA := "1"
					Endif      
					GHV->(MsUnlock())
					
					cImpVia := HS_RDescrB("GHV_IMPVIA", GHV->GHV_IMPVIA)   
					cStatus := HS_RDescrB("GHV_STATUS", GHV->GHV_STATUS) 
					
				    aAdd(aMntImp, {GHV->GHV_REGATE, TRB->GCY_REGGER, TRB->GCY_NOME, cQuaint, cLeiInt, TRB->GCY_CODLOC, GHV->GHV_CODCRM, TRB->GCY_DATATE,;
					GHV->GHV_DATPRE, GHV->GHV_HORCRI, GHX->GHX_SEQITE, GHX->GHX_TPITMP,;
					GHX->GHX_APRESE, GHX->GHX_APRESD, GHX->GHX_CDITMP, Posicione("GFZ", 1, xFilial("GFZ") + GHX->GHX_CDFRQA, "GFZ_DSFRQA"),; 
					GHX->GHX_IDREGI, GHX->GHX_DISPAR, GHX->GHX_CDFRQA, cImpVia, cStatus, GHX->GHX_OBSREG, ;
					GHX->GHX_VOLUME, Posicione("GFW", 1, xFilial("GFZ") + GHX->GHX_CODVIA, "GFW_DESVIA"), GHX->GHX_VELINF, ; 
					Posicione("GFY", 1, xFilial("GFZ") + GHX->GHX_CDMINF, "GFY_DSMINF"), GHX->GHX_CDMEDI, Posicione("GHS", 1, xFilial("GFZ") + GHX->GHX_MOTIVO, "GHS_DESMOT")})
					
					GHX->(DbSkip())
				    
				EndDo
				
				HSPAHR22(aMntImp,.T.,.T.,@aGuiasLote)
			EndIf
	   		
			Trb->( DbSkip() )
		EndDo    
	EndIf

	If nProInativ == 2 
		For nCont := 1 to len(aGuiasLote)
			fDirPdfHSP(aGuiasLote[nCont][3],IIf(nTipoRel == 1,"A","P"))
		Next
	Else
		fDirPdfHSP(cProf,IIf(nTipoRel == 1,"A","P")) 
	Endif
	
	If MakeDir(GetTempPath()+"totvsprinter\") == 3
		MsgInfo(STR0157+GetTempPath()+"totvsprinter\") //"Não foi possível criar o diretorio "
		lOk := .F.
	EndIf       
	
	If MakeDir(GetTempPath()+"totvsprinter\"+cFolderXml) == 3
		MsgInfo(STR0157+GetTempPath()+"totvsprinter\"+cFolderXml) //"Não foi possível criar o diretorio "
		lOk := .F.
	EndIf       
	
	If lOk  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Copia 			  													       			 ³
  		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCont := 1 to len(aGuiasLote)
			__CopyFile( aGuiasLote[nCont][1], GetTempPath()+"totvsprinter\"+cFolderXml+"\"+ aGuiasLote[nCont][2] ) 
	    Next
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama rotina para assinar digitalmente os arquivos - Anamnese		       			 ³
  		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipoRel == 1
			MsAguarde( {|| HSCertDig("4",,cProf,cFolderXml,aGuiasLote) })
		Else
			MsAguarde( {|| HSCertDig("5",,cProf,cFolderXml,aGuiasLote) })
		EndIf	
	EndIf    
ElseIf len(aLog) == 0
	MsgInfo(STR0158) //"Não foram encontrados registros para assinar."
EndIf

Trb->( DbCloseArea() )    

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HMA7Ficha  ³ Autor ³ TOTVS                 ³ Data ³01.02.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama rotina de Ficha de tratamento do paciente              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/               
Function HMA7Ficha()  
Local aArea		:= getArea()
Local cCodReg	:= ""
                            
If Pergunte("HSPM61", .T.)
	cCodReg := MV_PAR01
Else
	RestArea(aArea)
	Return()
EndIf

fs_perfCli(3 , cCodReg)
RestArea(aArea)
Return()
