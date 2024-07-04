#INCLUDE "PROTHEUS.CH"
#INCLUDE "QDOA030.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ ÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDOA030    ³ Autor ³ Aldo Marini Junior         ³ Data ³ 24/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Verificacao de Pendencias                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDOA030(ExpA1)                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Vetor contendo as pendencias do usuario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ Siga Quality ( Controle de Documentos )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacoes³ O vetor aPenden pode se montado atraves de chamada no programa    ³±±
±±³           ³ principal.                                                        ³±±
±±³           ³ Opcao Atualizacoes + Pendencias do MNU.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³   Data   ³  BOPS  ³ Programador ³Alteracao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 03/07/01 ³  4615  ³ Eduardo S.  ³ Incluido um botao "filtro" na tela de penden³±±
±±³          ³        ³             ³ cias para filtrar/selecionar por tipo de pen³±±
±±³          ³        ³             ³ dencia e foi incluido um combobox para sele-³±±
±±³          ³        ³             ³ cionar a ordem das pendencias.              ³±±
±±³ 14/12/01 ³ xxxxxx ³ Eduardo S.  ³ Acerto para verificar as etapas no momento  ³±±
±±³          ³        ³             ³ de carregar as pendencias                   ³±±
±±³ 27/02/02 ³  META  ³ Eduardo S.  ³ Alterado para apresentar Pendencias e Avisos³±±
±±³          ³        ³             ³ em Folder, Melhoria e Otimizacao na Rotina. ³±±
±±³ 05/03/02 ³ xxxxxx ³ Eduardo S.  ³ Alterado para visualizar/baixar aviso de Do-³±±
±±³          ³        ³             ³ cumentos Referenciados.                     ³±±
±±³ 01/04/02 ³  META  ³ Eduardo S.  ³ Alteracao devido novo conceito na utiliza-  ³±±
±±³          ³        ³             ³ cao dos arquivos de Usuarios\Centros de Cus-³±±
±±³          ³        ³             ³ to\Funcoes pelo Quality.                    ³±±
±±³ 13/05/02 ³ xxxxxx ³ Eduardo S.  ³ Incluido a visualizacao de Aviso de Ausencia³±±
±±³          ³        ³             ³ Temporaria.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef( lRotina )

Local aRotina := {}

Default lRotina := .F.

If lRotina
	aRotina     := { {"","",0,0}, {"","",0,0},;
	    			 {"","QD050Telas",0,3},;
					 {STR0003,"QD050Telas",0,4},;
					 {"","",0,0}, {"","",0,0} } //"Alterar"
Else
	aRotina     := { {STR0003,"QD050Telas",0,4} } //"Alterar"
EndIf
Return aRotina

Function QDOA030(aPenden1,aAvisos1)

Local aPenden	  := {}
Local aAvisos	  := {}
Local aUsrMat    := QA_USUARIO()
Local lApelido   := aUsrMat[1]

Private oQD1
Private bCampo      := { |nCPO| Field( nCPO ) }
Private cCadastro   := OemToAnsi( STR0001 ) //"Cadastro de Documentos"
Private cTpCopia    := OemToAnsi( STR0002 ) //"Copia Controlada"
Private cNomFilial  := Space(40)
Private cFilApSol   := Space(FWSizeFilial()) //Space(02)
Private cCodApSol   := Space(06)
Private cFilApDes   := Space(FWSizeFilial()) //Space(02)
Private cCodApDes   := Space(06)
Private cFilMat     := cFilAnt
Private cDtEmiss    := CTOD("  /  /  ")
Private cObjetivo   := " "
Private cMotRevi    := " "
Private cApElabo    := " "
Private cApRevis    := " "
Private cApAprov    := " "
Private cApHomol    := " "	   
Private cElabora    := " "
Private cRevisor    := " "
Private cAprovad    := " "
Private cHomolog    := " "
Private cSumario    := " "
Private cRodape     := " "
Private cNomRece    := " "
Private cQD1Tmp     := "" 
Private aListID     := {}
Private aListWD     := {}
Private axtextos    := {} 
Private lPendBai    := .F.
Private Inclui      := .f.
Private lIncDepois  := .f.
Private lGeraRev    := .f.
Private lCritica    := .f.
Private lSolicitacao:= .f.
Private lRefresh    := .t.
Private lPendencia  := .t.
Private lAltDoc     := .t.
Private nOrdPend    := GetMV("MV_QDOORPD",.F.,1) // "Define a Ordem Padrao de apresentacao dos dados na Tela de Pendencias do Controle de Documentos de 1 a 11 (conforme botao de filtra Pendencias)"
Private cQDHFil		:= xFilial("QDH")
Private aRotina     := MenuDef( .T. )
Private lTrat:= GetMv("MV_QDOQDG",.T.,.F.)
Private lGerRev:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se lApelido( indica se o apelido do usuario e igual ao do configurador ) ³
//³ permite utilizar ou nao a rotina                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lApelido 
	Help( " ", 1, "QD_LOGIN",,OemToAnsi(STR0046)+Chr(13)+OemToAnsi(STR0047),1) // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
	Return .f.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o vetor aPenden / aAvisos           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPenden := If(aPenden1 == Nil,{},aPenden1)
aAvisos := If(aAvisos  == Nil,{},aAvisos1)

DbSelectArea("QDZ")
DbSetOrder(1)

If Len(aPenden) == 0 .Or. (Len(aPenden) == 1 .And. aPenden[1,9] == -1) .Or.;
	Len(aAvisos) == 0 .Or. (Len(aAvisos) == 1 .And. aAvisos[1,6] == -1)
	aPenden:= {}
	aAvisos:= {}
	MsgRun(OemToAnsi(STR0015), OemToAnsi(STR0016), {|| QD030LePen(@aPenden,,nOrdPend,@aAvisos)})	// "Selecionando Pendencias..." ### "Aguarde"
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Pendencias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aPenden) > 1 .Or. (Len(aPenden) == 1 .And. aPenden[1,9] <> -1 ) .Or.;
	Len(aAvisos) > 1 .Or. (Len(aAvisos) == 1 .And. aAvisos[1,6] <> -1 )
	QD030MsDlg(@aPenden,@aAvisos)
Else
	Help(" ",1,"QDNEPENDE")
EndIf

QD1->(DbSetOrder(1))

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD030MsDlg ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta tela de Pendencias                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD030MsDlg(ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Vetor contendo as Pendencias                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA030                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD030MsDlg(aPenden,aAvisos)

Local oDlgFolder
Local oBtn1
Local oBtn2
Local oBtn4
Local oNome
Local oDepto
Local oNomeFd2
Local oDeptoFd2
Local oQD1
Local oQDS

Local bQD1Line1
Local cQD1      := " "
Local cQDS      := " "
Local cNomeFd2  := " "
Local cDeptoFd2 := " "
Local cNome     := " "
Local cDepto    := " "
Local cTipoPend := " "          
Local cMvQDRefIn:= GetMv("MV_QDREFIN",.F.,"1")//Define a Referencia do Documento Invertida (1-PaisxFilhos ,2-FilhosxPais, 3-Ambas)
Local aArea		:= {}

DEFINE MSDIALOG oDlgFolder TITLE OemToAnsi(STR0004) FROM 000,000 TO 420,750 OF oMainWnd PIXEL // "Manuten‡„o de Pendˆncias"
                                                                             
@ 015,000 FOLDER oPend PROMPTS OemToAnsi(STR0039),OemToAnsi(STR0040) SIZE 450,183 OF oDlgFolder PIXEL // "Pendencias" ### "Avisos"

oPend:bChange:= {|| If((Len(aAvisos)==1 .And. aAvisos[1,6]==-1) .And. oPend:nOption <> 1,(oPend:nOption:=1,Help(" ",1,"QDNEAVISO",,OemToAnsi(STR0042),1)),; // "Nao existem avisos para voce."
	If((Len(aPenden)==1 .And. aPenden[1,9]==-1) .And. oPend:nOption <> 2,(oPend:nOption:=2,Help(" ",1,"QDNEPENDE")),"")),; // "Nao existem pendencias para voce."
	QD30AtuFold(aPenden,oQD1,bQD1Line1,aAvisos,oQDS,bQDSLine1,oPend,oDlgFolder)}

oPend:Align := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder Pendencias				      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 003,003 TO 147,340 LABEL OemToAnsi(STR0005) OF oPend:aDialogs[1] PIXEL // " Documentos "

@ 153,003 SAY OemToAnsi(STR0006) SIZE 040,010 OF oPend:aDialogs[1] PIXEL // " Solicitante "
@ 152,031 GET oNome VAR cNome SIZE 120,007 OF oPend:aDialogs[1] PIXEL
oNome:lReadOnly:= .T.

@ 152,155 GET oDepto VAR cDepto SIZE 125,007 OF oPend:aDialogs[1] PIXEL
oDepto:lReadOnly:= .T.

IF FWModeAccess("QDH") == "C" //Empty(cQDHFil)
	bQD1Line1 := { || 	If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0,;
		{ " "," "," "," "," "," "," "," "," "},;
		{ aPenden[oQD1:nAt,10], aPenden[oQD1:nAt,1], aPenden[oQD1:nAt,2], aPenden[oQD1:nAt,3], aPenden[oQD1:nAt,4], aPenden[oQD1:nAt,5], aPenden[oQD1:nAt,6], aPenden[oQD1:nAt,7], aPenden[oQD1:nAt,8] }) }
	
	IF cMvQDRefIn <> "1"
		bQDSLine1 := {||{QDO030MsgA(aAvisos[oQDS:nAt,1]),aAvisos[oQDS:nAt,2],aAvisos[oQDS:nAt,3],aAvisos[oQDS:nAt,4],aAvisos[oQDS:nAt,8],aAvisos[oQDS:nAt,9]}}
	Else
		bQDSLine1 := {||{QDO030MsgA(aAvisos[oQDS:nAt,1]),aAvisos[oQDS:nAt,2],aAvisos[oQDS:nAt,3],aAvisos[oQDS:nAt,4]}}
	Endif
	
Else
	bQD1Line1 := { || 	If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0,;
		{ " "," "," "," "," "," "," "," "," "," " },;
		{ QDO30FIL(aPenden[oQD1:nAt,11]),aPenden[oQD1:nAt,10], aPenden[oQD1:nAt,1], aPenden[oQD1:nAt,2], aPenden[oQD1:nAt,3], aPenden[oQD1:nAt,4], aPenden[oQD1:nAt,5], aPenden[oQD1:nAt,6], aPenden[oQD1:nAt,7], aPenden[oQD1:nAt,8] }) }
	
	IF cMvQDRefIn <> "1"
		bQDSLine1 := {||{QDO30FIL(aAvisos[oQDS:nAt,10]),QDO030MsgA(aAvisos[oQDS:nAt,1]),aAvisos[oQDS:nAt,2],aAvisos[oQDS:nAt,3],aAvisos[oQDS:nAt,4],aAvisos[oQDS:nAt,8],aAvisos[oQDS:nAt,9]}}
	Else
		bQDSLine1 := {||{QDO30FIL(aAvisos[oQDS:nAt,8]),QDO030MsgA(aAvisos[oQDS:nAt,1]),aAvisos[oQDS:nAt,2],aAvisos[oQDS:nAt,3],aAvisos[oQDS:nAt,4]}}
	Endif
	
Endif					

                                                      
oQD1 := TCBrowse():New(012,006,330,130,,,,oPend:aDialogs[1],,,,,,,,,,,,.F.,"QD1",.T.,,.F.)
IF FWModeAccess("QDH") == "E" //!Empty(cQDHFil)
	oQD1:AddColumn(TCColumn():New(TitSx3("QD1_FILIAL")[1], {|| QDO30FIL(aPenden[oQD1:nAt,11])},,,,"LEFT",15, .F., .F.,,,, .F., ) )
Endif
oQD1:AddColumn(TCColumn():New(TitSx3("QDH_CODTP")[1] , {||	If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,10]) },,,,"LEFT",10, .F., .F.,,,, .F., ) )
oQD1:AddColumn(TCColumn():New(TitSx3("QDH_DOCTO")[1] , {|| If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,1] ) },,,,"LEFT",50, .F., .F.,,,, .F., ) )
oQD1:AddColumn(TCColumn():New(TitSx3("QDH_RV")[1]    , {|| If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,2] ) },,,,"LEFT",10, .F., .F.,,,, .F., ) )
oQD1:AddColumn(TCColumn():New(TitSx3("QDH_TITULO")[1], {|| If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,3] ) },,,,"LEFT",100, .F., .F.,,,, .F., ) )
oQD1:AddColumn(TCColumn():New(TitSx3("QD1_TPPEND")[1], {|| If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,4] ) },,,,"LEFT",70, .F., .F.,,,, .F., ) )
oQD1:AddColumn(TCColumn():New(TitSx3("QD1_DTGERA")[1], {|| If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,5] ) },,,,"LEFT",50, .F., .F.,,,, .F., ) )
oQD1:AddColumn(TCColumn():New(TitSx3("QDH_DTVIG")[1] , {|| If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,6] ) },,,,"LEFT",35, .F., .F.,,,, .F., ) )
oQD1:AddColumn(TCColumn():New(TitSx3("QDH_DTIMPL")[1], {|| If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,7] ) },,,,"LEFT",35, .F., .F.,,,, .F., ) )
oQD1:AddColumn(TCColumn():New(TitSx3("QDH_DTLIM")[1] , {|| If(oQD1:nAt > Len(aPenden) .Or. oQD1:nAt = 0," ",aPenden[oQD1:nAt,8] ) },,,,"LEFT",35, .F., .F.,,,, .F., ) )
				
IF nOrdPend != 1
	QDO030Ord(@aPenden,nOrdPend)
Endif	

oQD1:blDBLCLICK:= {|| QD030BxPen(oQD1:nAt,@aPenden,@lPendBai,cTipoPend,nOrdPend,@aAvisos),;
	If(QD30AtuFold(aPenden,oQD1,bQD1Line1,aAvisos,oQDS,bQDSLine1,oPend,oDlgFolder),;
	If(oPend:nOption == 1,QD030LeTxt(oQD1:nAt,aPenden,@oNome,@cNome,@oDepto,@cDepto,1),;
	QD030LeTxt(oQDS:nAt,aAvisos,@oNomeFd2,@cNomeFd2,@oDeptoFd2,@cDeptoFd2,2)),oDlgFolder:End()) }

oQD1:BCHANGE:=  {|| QD030LeTxt(oQD1:nAt,aPenden,@oNome,@cNome,@oDepto,@cDepto,1) }
oQD1:SetArray(aPenden)
oQD1:bLine:= bQD1Line1
oQD1:GoTop()
oQD1:cToolTip:= OemToAnsi(STR0011) //"Duplo click para Baixar Pendˆncia"	
oQD1:UpStable()
oQD1:Refresh()					

DEFINE SBUTTON oBtn1 FROM 003,345 WHEN Len(aPenden) > 1 .Or. (Len(aPenDen) == 1 .And. aPenden[1,9] <> -1 );
	TYPE    11 ENABLE OF oPend:aDialogs[1];
	ACTION (QD030BxPen(oQD1:nAt,@aPenden,@lPendBai,cTipoPend,nOrdPend,@aAvisos),;
	If(QD30AtuFold(aPenden,oQD1,bQD1Line1,aAvisos,oQDS,bQDSLine1,oPend,oDlgFolder),;
	If(oPend:nOption == 1,QD030LeTxt(oQD1:nAt,aPenden,@oNome,@cNome,@oDepto,@cDepto,1),;
	QD030LeTxt(oQDS:nAt,aAvisos,@oNomeFd2,@cNomeFd2,@oDeptoFd2,@cDeptoFd2,2)),oDlgFolder:End()) )
oBtn1:cToolTip := OemToAnsi( STR0012 ) // "Baixa Pˆndencia"
oBtn1:cCaption := STR0048 //"Baixa"

DEFINE SBUTTON oBtn2 FROM 018,345 TYPE 17 ENABLE OF oPend:aDialogs[1];
	ACTION  (QDO030Filt(@aPenden,@cTipoPend,@nOrdPend),oQD1:SetArray(aPenden),oQD1:bLine:= bQD1Line1,oQD1:UpStable(),oQD1:Refresh())
oBtn2:cToolTip := OemToAnsi(STR0041) // "Filtra Pˆndencias"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder Avisos     				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 003,003 TO 147,340 LABEL OemToAnsi(STR0040) OF oPend:aDialogs[2] PIXEL // "Avisos"

oQDS := TCBrowse():New(012,006,330,130,,,,oPend:aDialogs[2],,,,,,,,,,,,.F.,"QDS",.T.,,.F.)
IF FWModeAccess("QDH") == "E" //!Empty(cQDHFil)
	IF cMvQDRefIn <> "1"
		oQDS:AddColumn(TCColumn():New(TitSx3("QDS_FILIAL")[1], {|| QDO30FIL(aAvisos[oQDS:nAt,10])},,,,"LEFT",15, .F., .F.,,,, .F., ) )
	Else
		oQDS:AddColumn(TCColumn():New(TitSx3("QDS_FILIAL")[1], {|| QDO30FIL(aAvisos[oQDS:nAt,8] )},,,,"LEFT",15, .F., .F.,,,, .F., ) )
	Endif
Endif
oQDS:AddColumn(TCColumn():New(OemToAnsi(STR0040)      , {|| QDO030MsgA(aAvisos[oQDS:nAt,1],aAvisos[oQDS:nAt,3],aAvisos[oQDS:nAt,4]) },,,,"LEFT",130, .F., .F.,,,, .F., ) )
oQDS:AddColumn(TCColumn():New(TitSx3("QDS_DTGERA")[1] , {|| aAvisos[oQDS:nAt,2] },,,,"LEFT",50, .F., .F.,,,, .F., ) )
oQDS:AddColumn(TCColumn():New(TitSx3("QDS_DOCTO")[1]  , {|| aAvisos[oQDS:nAt,3] },,,,"LEFT",50, .F., .F.,,,, .F., ) )
oQDS:AddColumn(TCColumn():New(TitSx3("QDS_RV")[1]     , {|| aAvisos[oQDS:nAt,4] },,,,"LEFT",30, .F., .F.,,,, .F., ) )
IF cMvQDRefIn <> "1"
	oQDS:AddColumn(TCColumn():New(TitSx3("QDS_DOCREF")[1], {|| aAvisos[oQDS:nAt,8] },,,,"LEFT",50, .F., .F.,,,, .F., ) )
	oQDS:AddColumn(TCColumn():New(TitSx3("QDS_RVREF")[1] , {|| aAvisos[oQDS:nAt,9] },,,,"LEFT",50, .F., .F.,,,, .F., ) )
Endif

oQDS:lColDrag := .T.
oQDS:lMChange := .T.

oQDS:blDBLCLICK:={|| QDO030BxAv(oQDS:nAt,@aAvisos,@aPenden,cTipoPend,nOrdPend),;
	IF(QD30AtuFold(aPenden,oQD1,bQD1Line1,aAvisos,oQDS,bQDSLine1,oPend,oDlgFolder),;
	If(oPend:nOption == 1,QD030LeTxt(oQD1:nAt,aPenden,@oNome,@cNome,@oDepto,@cDepto,1),;
	QD030LeTxt(oQDS:nAt,aAvisos,@oNomeFd2,@cNomeFd2,@oDeptoFd2,@cDeptoFd2,2)),oDlgFolder:End()) }

oQDS:BCHANGE:= {|| QD030LeTxt(oQDS:nAt,aAvisos,@oNomeFd2,@cNomeFd2,@oDeptoFd2,@cDeptoFd2,2) }
oQDS:SetArray(aAvisos)
oQDS:bLine   := bQDSLine1
oQDS:GoTop()

/*@ 153,003 SAY OemToAnsi(STR0006) SIZE 040,010 OF oPend:aDialogs[2] PIXEL // " Solicitante "
@ 152,031 GET oNomeFd2 VAR cNomeFd2 SIZE 120,007 OF oPend:aDialogs[2] PIXEL
oNomeFd2:lReadOnly:= .T.
	
@ 152,155 GET oDeptoFd2 VAR cDeptoFd2 SIZE 125,007 OF oPend:aDialogs[2] PIXEL
oDeptoFd2:lReadOnly:= .T.    */
	
DEFINE SBUTTON oBtn4 FROM 003,345 WHEN Len(aAvisos) > 1 .Or. (Len(aAvisos) == 1 .And. aAvisos[1,6] <> -1 );
	TYPE    11 ENABLE OF oPend:aDialogs[2];
	ACTION (QDO030BxAv(oQDS:nAt,@aAvisos,@aPenden,cTipoPend,nOrdPend),;
	IF(QD30AtuFold(aPenden,oQD1,bQD1Line1,aAvisos,oQDS,bQDSLine1,oPend,oDlgFolder),;
	If(oPend:nOption == 1,QD030LeTxt(oQD1:nAt,aPenden,@oNome,@cNome,@oDepto,@cDepto,1),;
	QD030LeTxt(oQDS:nAt,aAvisos,@oNomeFd2,@cNomeFd2,@oDeptoFd2,@cDeptoFd2,2)),oDlgFolder:End()))

If Existblock("QD030BTAV")
	DEFINE SBUTTON oBtn5 FROM 018,345 TYPE 5 ENABLE OF oPend:aDialogs[2];
		ACTION  (Execblock ("QD030BTAV",.F.,.F.,{@aAvisos,oQDS:nAt}),oQD1:Refresh()) // (oQDS:nAt,@aAvisos,@aPenden,cTipoPend,nOrdPend),oQD1:Refresh())
Endif

If Len(aPenden) == 0 .Or. (Len(aPenden) == 1 .And. aPenden[1,9] == -1)
	oPend:nOption:= 2
EndIf

ACTIVATE MSDIALOG oDlgFolder ON INIT (EnchoiceBar(oDlgFolder,{||oDlgFolder:End()},{||oDlgFolder:End()})) CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD030BxPen ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta tela de Pendencias                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD030MsDlg(ExpN1,ExpA1,ExpL1,ExpC1,ExpN2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Posicao dentro do vetor da Pendencia                      ³±±
±±³           ³ ExpA1 - Vetor contendo as Pendencias                              ³±±
±±³           ³ ExpL1 - Baixa Pendencia (.T./.F.)                                 ³±±
±±³           ³ ExpC1 - Tipo de Pendencia                                         ³±±
±±³           ³ ExpN2 - Ordem das Pendencias                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA030                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD030BxPen(nPos,aPenden,lPendBai,cTipoPend,nOrdPend,aAvisos)

Local nReg   := aPenden[ nPos,9 ]

Local nRegQDH:= 0
Local cFiltroQdh := QDH->(DbFilter())
Local cArea		 := Alias(), nRecno := QDH->(Recno())
Local cSvFilAnt	 := cFilAnt
Local nC
Local lMvQgint	 := GetMV("MV_QGINT",.F.,1) == "S"
Local lQDHExc	 := .F.
Private lButUser := .T.

If ! Empty(cFiltroQdh)
	DbSelectArea("QDH")
	Set Filter To
	DbSelectArea(cArea)
Endif


lPendBai := If(lPendBai == NIL,.F.,lPendBai)
cTipoPend:= If(cTipoPend==NIL," ",cTipoPend)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o Arquivo no Documento Selecionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QD1->(DbGoTo(nReg))

QDH->(DbSetOrder(1))
If QDH->(DBSEEK(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
	For nC:= 1 To QDH->(FCount())
	    cCampo:= Upper(AllTrim(QDH->(FieldName(nC))))
	    M->&cCampo.:= QDH->(FieldGet(FieldPos(cCampo)))
	Next						
	nRegQDH := QDH->(Recno())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a pendencia for de Distribuicao, chama a rotina de distribuicao de documentos ³
//³ senao segue abre o documento para a baixa da pendencia.                          ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMvQgint 
	DbSelectArea("QAA")
	DbSetOrder(6)
	
	PswOrder(1)
	PswSeek(__cUserID)
	aRetUser := PswRet(1)

   	If QAA->(DbSeek(aRetUser[1][2]))
		If QAA->QAA_TPUSR == "1"
   			IF QD1->QD1_DEPTO <> QAA->QAA_CC
	   			Messagedlg(STR0054,,3)//"O usuário logado está como funcionário e foi transferido de departamento mas não teve a pendência transferida"
	   			 Return( .F. )
			Endif
		Endif
	Endif
Endif

If Existblock("QD030BXP")
	Execblock("QD030BXP",.F.,.F.)
Endif

If QD1->QD1_TPPEND == "I  "
	QDOA110(nRegQDH)
ElseIf QD1->QD1_TPPEND $"D  ,DC ,E  ,EC ,R  ,A  ,H  ,L  "
	Inclui := .f.
	If QDH->QDH_STATUS $ "DC ,EC "
		lCritica := .t.
	Endif
	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(Fwfilial('QDH')))
		cFilAnt	:= M->QDH_FILIAL // Alterada a filial para pendências acessadas de filiais diferentes da original do documento
		lQDHExc := .T.	
	EndIf	
	If dDatabase < QDH->QDH_DTIMPL
		lPendBai := .t.
		QD050Telas( "QDH", Recno(), 2, lPendBai )
		dbSelectArea("QDH")
		Set Filter To
		lPendBai := .f.
	Else
		If QDH->QDH_STATUS == "L  "
			lPendBai:=.t.
			QD050Telas( "QDH", Recno(), 2, lPendBai  )
			dbSelectArea("QDH")
			Set Filter To
			lPendBai:=.f.
		Else
			QD050Telas( "QDH", Recno(), 4, lPendBai  )
			dbSelectArea("QDH")
			Set Filter To
		EndIf
	EndIf
	If lQDHExc
		cFilAnt := cSvFilAnt // Restaura a filial logada após o processamento das pendências
	EndIf
EndIf

If ExistBlock( "QD1BXPD" )
	ExecBlock( "QD1BXPD", .f., .f. )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclusao de ponto de entrada para chamar rotina de baixa solicitacoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "QDOAP04" )
	llBaixa := .F.
	ExecBlock( "QDOAP04", .f., .f. )
	If llBaixa
		nRad02 := 2
		QD052BAIXA("QDP",QDP->(Recno()),2)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remonta o vetor aPenden 								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QDH")
Set Filter To 
QD030LePen(@aPenden,cTipoPend,nOrdPend,@aAvisos)

QD1->(DbSetOrder(3))

If ! Empty(cFiltroQdh)
	DbSelectArea("QDH")
	Set Filter To &(cFiltroQdh)
	DbSeek(xFilial())
	DbGoto(nRecno)
	DbSelectArea(cArea)
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD030LeTxt ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Le o conteudo texto do QA2 referente a pendencia                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD030LeTxt(ExpN1,ExpA1,ExpO1,ExpC1,ExpO2,ExpC2)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Posicao dentro do vetor da Pendencia                      ³±±
±±³           ³ ExpA1 - Vetor contendo as Pendencias                              ³±±
±±³           ³ ExpO1 - Objeto com o Nome do Usuario da gerador da Pendencia      ³±±
±±³           ³ ExpC1 - Variavel associada ao objeto oNome                        ³±±
±±³           ³ ExpO2 - Objeto com o Departamento gerador da Pendencia            ³±±
±±³           ³ ExpC2 - Variavel associada ao objeto oDepto                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA030                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD030LeTxt(nPos,aPenden,oNome,cNome,oDepto,cDepto,nFolder)

If Len(aPenden) == 0
	Return Nil
End

If nFolder == 1
	QD1->(DbGoTo(aPenden[nPos,9]))
	DbSelectArea("QD1")

	If ( QDH->( DBSEEK( QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV ) ) )

		If QD1->QD1_TPPEND $ "DC ,E  ,EC ,R  ,A  ,H  ,I  ,SD ,SDC"
			QAA->(DBSEEK( QD1->QD1_FMATBX + QD1->QD1_MATBX ) )
		ElseIf QD1->QD1_TPPEND $ "L  "
			QD1->(DbSetOrder(2))
			If QD1->( DBSEEK(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+"E  "))
				QAA->( DBSEEK( QD1->QD1_FILMAT + QD1->QD1_MAT ) )
			Else
				QAA->( DBSEEK( QDH->QDH_FILMAT + QDH->QDH_MAT ) )
			EndIf
		Else
			QAA->( DBSEEK( QDH->QDH_FILMAT + QDH->QDH_MAT ) )
		EndIf

	Endif
Else
	QDS->(DbGoTo(aPenden[nPos,6]))
	QAA->(DbSeek(QDS->QDS_FMATBX+QDS->QDS_MATBX))
EndIf

If QAA->(Found())
	cNome  := QAA->QAA_NOME
	cDepto := QA_NDEPT( QAA->QAA_CC, .T., QAA->QAA_FILIAL )
Else
	cNome  := Space( 30 )
	cDepto := Space( 30 )
EndIf

If QD1->QD1_TPPEND =="D  "
	cNome := STR0055	//"Não existe Solicitante para esta etapa"
	cDepto:= Space(30)
Endif 


If oNome <> Nil
	oNome:Refresh()
EndIf

If oDepto <> Nil
	oDepto:Refresh()
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD030LePen ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 18/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Le o conteudo texto do QA2 referente a pendencia ( Objetivo )     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD030LePen(ExpA1,ExpC1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Vetor com os dados de QD1 - Distribuicao por Usuario      ³±±
±±³           ³ ExpC1 - Tipo de Pendencia                                         ³±±
±±³           ³ ExpN1 - Ordem das Pendencias                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA030()/SIGAQDO()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD030LePen(aQD1,cTipoPend,nOrdPend,aQDS)

Local nDias   := GetMV( "MV_QDIALIM" )
Local dData   := dDatabase
Local aUsrMat := QA_USUARIO()
Local cMatFil := aUsrMat[2]
Local cMatCod := aUsrMat[3]
Local cMatDep := aUsrMat[4]
Local aArea	  := {}
Local cMvQDRefIn:= GetMv("MV_QDREFIN",.F.,"1") //Define a Referencia do Documento Invertida (1-PaisxFilhos ,2-FilhosxPais, 3-Ambas) 
Local aAReaQDS:= {}
Local cDtVig    := GetMv("MV_QDHDTIM",.f.,"2") // Habilita Calculo a partir da data de Implantacao 1=Sim / 2=Nao   
Local lQDOAP22 := ExistBlock("QDOAP22")
Local lQDOAP02 := ExistBlock("QDOAP02")

Default cTipoPend := " "
Default nOrdPend  := 1

aQD1:= {}
aQDS:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as pendencias no Array (campos)                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QDH->( DbSetOrder(1) )
QD1->( DbSetOrder(3) )
If QD1->( DBSEEK( cMatFil + cMatCod + "P" ) )
	While !QD1->( Eof() ) .And. QD1->QD1_FILMAT + QD1->QD1_MAT + QD1->QD1_PENDEN == cMatFil + cMatCod + "P"
		If ! Empty(cTipoPend)
			If !(QD1->QD1_TPPEND $ cTipoPend)
				QD1->( DbSkip() )
				Loop
			Endif
		EndIf
		If QD1->QD1_TPDIST $ "2,4" .and. QD1->QD1_TPPEND == "L  "
			QD1->( DbSkip() )
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PONTO DE ENTRADA INCLUDO PARA TRATAMENTO DE OUTROS TIPOS DE COPIAS       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ_ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lQDOAP22  .and. QD1->QD1_TPPEND == "L  "
			IF ExecBlock("QDOAP22",.F.,.F.,{QD1->QD1_TPDIST})
				QD1->( DbSkip() )
				Loop
			Endif
		Endif
		If QDH->( DBSEEK( QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV ) )
			If QD1->QD1_TPPEND == "I  "
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se usuario pode ter pendencia de distribuicao de documentos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ! QDZ->(DBSEEK(QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + cMatDep + cMatCod + cMatFil)) .And.;
					QDH->QDH_FILDEP + QDH->QDH_DEPTOD <> cMatFil + cMatDep
					QD1->( DbSkip() )
					Loop
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a data limite( validade) do documento nao esta vazia.                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(QDH->QDH_DTLIM)
				If QDH->QDH_DTLIM <= dData .and. QD1->QD1_TPPEND $"D  ,DC ,E  ,EC ,R  ,A  ,H  ,L  "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a data de implantacao e menor que a data dosistema ( documento vencido )      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If QD1->QD1_TPPEND <> "L  " 
						QD1->( DbSkip() ) 
						Loop
					Else
						If cDtVig <> "1"  
							QD1->( DbSkip() ) 
						    Loop					
						Endif 
					Endif
				Endif
				If QDH->QDH_DTIMPL > dData
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a data de implantacao ainda esta por vir...                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (QDH->QDH_DTLIM - dData ) > nDias
						QD1->( DbSkip() )
						Loop
					Endif
				Endif
			Endif
		Endif
		
		If lQDOAP02
			ExecBlock( "QDOAP02", .f., .f. )
		Endif
		
		Aadd( aQD1,{ QD1->QD1_DOCTO,;
			QD1->QD1_RV,;
			Left( QDH->QDH_TITULO ,40 ),;
	   		Left( QA_NSIT(QD1->QD1_TPPEND),40),;
			DTOC( QD1->QD1_DTGERA ) + " " + QD1->QD1_HRGERA,;
			DTOC( QDH->QDH_DTVIG  ),;
			DTOC( QDH->QDH_DTIMPL ),;
			DTOC( QDH->QDH_DTLIM  ),;
			QD1->( Recno() ),;
			QDH->QDH_CODTP ,;
	   		QD1->QD1_FILIAL } )
		
		QD1->( DbSkip() )
	Enddo
Endif

If Len(aQD1) == 0
	Aadd( aQD1,{ " "," "," "," "," "," "," "," ", -1 ," "," "} )
Endif

If Empty(cTipoPend) .And. nOrdPend == 1
	If Len( aQD1 ) > 0
	   aQD1 := aSort( aQD1,,,{ |x,y| x[1] + x[2] + x[5] + x[6] < y[1] + y[2] + y[5] + y[6] } )
	EndIf
Else
	QDO030Ord(@aQD1,nOrdPend)
EndIf

aArea:=GetARea()
cQuery :="SELECT QDS.QDS_FILIAL,QDS.QDS_DTGERA,QDS.QDS_HRGERA,QDS.QDS_TPPEND, "
cQuery +="QDS.QDS_DOCTO,QDS.QDS_RV,QDS.QDS_CHAVE,QDS.R_E_C_N_O_ " 
IF cMvQDRefIn <> "1"
	cQuery +=",QDS.QDS_DOCREF, QDS.QDS_RVREF "		
Endif
cQuery +="FROM " + RetSqlName("QDS")+" QDS "
cQuery +="WHERE "                             
cQuery +="QDS.QDS_FILMAT='"+cMatFil+"' AND "
cQuery +="QDS.QDS_MAT='"+cMatCod+"' AND "
cQuery +="QDS.QDS_PENDEN='P' AND "	
cQuery +="QDS.D_E_L_E_T_ <> '*' " 					

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2"
Else
	cQuery += " ORDER BY " + SqlOrder("QDS_DTGERA+QDS_HRGERA")
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDS",.T.,.T.)

TcSetField("TMPQDS","QDS_DTGERA","D")

DbGotop()
While TMPQDS->(!Eof())       
 	If cMvQDRefIn <> "1"
		Aadd(aQDS,{TMPQDS->QDS_TPPEND,;
			DTOC(TMPQDS->QDS_DTGERA)+" "+TMPQDS->QDS_HRGERA,;
			TMPQDS->QDS_DOCTO,;
			TMPQDS->QDS_RV,;
			TMPQDS->QDS_CHAVE,;
			TMPQDS->R_E_C_N_O_,;
			DTOS(TMPQDS->QDS_DTGERA)+" "+TMPQDS->QDS_HRGERA,;
			TMPQDS->QDS_DOCREF,;
			TMPQDS->QDS_RVREF,;
			TMPQDS->QDS_FILIAL})	 		
	Else
      		Aadd(aQDS,{TMPQDS->QDS_TPPEND,;
      			DTOC(TMPQDS->QDS_DTGERA)+" "+TMPQDS->QDS_HRGERA,;
      			TMPQDS->QDS_DOCTO,;
      			TMPQDS->QDS_RV,;
      			TMPQDS->QDS_CHAVE,;
      			TMPQDS->R_E_C_N_O_,;
      			DTOS(TMPQDS->QDS_DTGERA)+" "+TMPQDS->QDS_HRGERA,;
      			TMPQDS->QDS_FILIAL})
	Endif	      		
	TMPQDS->(DbSkip())
EndDo
TMPQDS->(DbCLOSEAREA())
RestARea(aArea)

If Len(aQDS) == 0
	IF cMvQDRefIn <> "1"
   		Aadd( aQDS,{ " "," "," "," "," ",-1 ," "," "," ", " " } )	
  	Else
   		Aadd( aQDS,{ " "," "," "," "," ", -1," ", " " } )
   	Endif   		
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDO030Filt³ Autor ³ Eduardo de Souza      		 ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Selecionar os tipos de pendencias                          			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO030Filt(ExpA1,ExpC1,ExpN1)                            			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contento as Pendencias                       			 ³±±
±±³          ³ ExpC1 - Tipo de Pendencia                                  			 ³±±
±±³          ³ ExpN1 - Ordem das Pendencias                               			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QDOA030                                                     			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO030Filt(aPenden,cTipoPend,nOrdPend)

Local	oWnd
Local	oDlg
Local	oListbox
Local	oOk 	 := LoaDbitmap( GetResources(), "LBOK" )
Local	oNo 	 := LoaDbitmap( GetResources(), "LBNO" )

Local	cMvPar := cTipoPend
Local	nOpca  := 0
Local	aNiv	 := {}
Local cAlias := Alias()
Local cCombOrd  := OemToAnsi(STR0029) 	// "Cod Doc+Revisão"
Local oCombOrd
Local aCombOrd  := {OemToAnsi(STR0029),; // "Cod Doc+Revisao"
    				OemToAnsi(STR0030),;  // "Cod Doc+Revisao+Dat Vigencia"
 					OemToAnsi(STR0031),;  // "Cod Doc+Revisao+Data Geracao" 
					OemToAnsi(STR0032),;  // "Tipo Pend+Dat Vigencia"
					OemToAnsi(STR0033),;  // "Tipo Pend+Cod Doc+Revisao"
 					OemToAnsi(STR0034),;  // "Dat Vigencia"
 					OemToAnsi(STR0035),;  // "Data Geracao"
					OemToAnsi(STR0036),;  // "Dat Implata"
					OemToAnsi(STR0037),;  // "Dat Validade"
					OemToAnsi(STR0038),;  // "Titulo Doc"					 
					OemToAnsi(STR0049)}   // //"Tipo Doc+Cod Doc+Revisao"
Local nFor
Local oBtn1,oBtn2,nCnt
Local aBkpPen:={}
Local aRetSX5 := FWGetSX5("Q7")
Local nX

oWnd:= GetWndDefault()

Aadd( aNiv, {If ( "O  " $ cMvPar, .T., .F. ), OemToAnsi( STR0018 ), "O  "} ) //"Todos"

If !Empty(aRetSX5)
	For nX := 1 To Len(aRetSX5)
		If !Empty(aRetSX5[nX,3])
			If Substr(aRetSX5[nX,3],1,3) $ cMvpar
				Aadd(aNiv,{.T.,Alltrim(aRetSX5[nX,4]),Substr(aRetSX5[nX,3],1, 3)})
			Else
				Aadd(aNiv,{.F.,Alltrim(aRetSX5[nX,4]),Substr(aRetSX5[nX,3],1, 3)})
			EndIf
		EndIf
	Next nX
Else
	Help(" ",1,"QDOR050SIT")		// Parametro Default
	AADD(aNiv,{If("D  "$cMvPar,.T.,.F.),OemToAnsi(STR0019),"D  "}) //"Digita‡„o"
	AADD(aNiv,{If("E  "$cMvPar,.T.,.F.),OemToAnsi(STR0020),"E  "}) //"Elabora‡„o"
	AADD(aNiv,{If("R  "$cMvPar,.T.,.F.),OemToAnsi(STR0021),"R  "}) //"Revis„o"
	AADD(aNiv,{If("A  "$cMvPar,.T.,.F.),OemToAnsi(STR0022),"A  "}) //"Aprova‡„o"
	AADD(aNiv,{If("H  "$cMvPar,.T.,.F.),OemToAnsi(STR0023),"H  "}) //"Homologa‡„o"
	AADD(aNiv,{If("I  "$cMvPar,.T.,.F.),OemToAnsi(STR0024),"I  "}) //"Distribui‡„o"
	AADD(aNiv,{If("L  "$cMvPar,.T.,.F.),OemToAnsi(STR0025),"L  "}) //"Leitura"
EndIf


If Empty(cMvPar)
	For nCnt:=1 to Len(aNiv)
		aNiv[nCnt,1] := .T.
	Next nCnt
EndIf

DEFINE MSDIALOG oDlg FROM 000,000 TO 330,257 TITLE OemToAnsi(STR0041) PIXEL //"Filtra Pendencias"

@ 010,003 TO 039,127 LABEL OemToAnsi(STR0028) OF oDlg PIXEL // "Ordem"
@ 018,006 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 118,010 PIXEL OF oDlg;
	ON CHANGE (QDO030Ord(@aPenden,oCombOrd:nAt),nOrdPend:= oCombOrd:nAt)

IF nOrdPend != 1
	oCombOrd:nAt:= nOrdPend           
    oCombOrd:Refresh()
Endif

@ 037,003 LISTBOX oListBox FIELDS HEADER " ",OemToAnsi(STR0027);
	SIZE 123, 107 PIXEL OF oDlg;
	ON DbLCLICK QDO030Cl(@oListBox,@aNiv)    
oListBox:SetArray(aNiv)
oListBox:bLine := { || {If(aNiv[oListBox:nAt,1],oOk,oNo),aNiv[oListBox:nAt,2]}}

DEFINE SBUTTON oBtn1 FROM 150,063 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1,oDlg:End())
DEFINE SBUTTON oBtn2 FROM 150,095 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	cMvPar:= " "
	For nFor := 1 TO Len(aNiv)
		cMvPar += If(aNiv[nFor,1],aNiv[nFor,3],"***")
	Next nFor
EndIf

DbSelectArea(cAlias)

aBkpPen:= Aclone(aPenden)
QD030LePen(@aPenden,cMvPar,nOrdPend)
cTipoPend:= cMvPar

If (Len(aPenden)==1 .And. aPenden[1,9]==-1)
	Help(" ",1,"QDNEPENDE")	
	aPenden:=AClone(aBkpPen)
Endif	

RETURN .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDO030Cl   ³ Autor ³ Eduardo de Souza             ³ Data ³ 03/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tratar o click da pergunte                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO030Cl(ExpO1,ExpA1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto ListBox de Tipo de Pendencia                        ³±±
±±³          ³ ExpA1 - Array contento Tipos de Pendencia                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA030                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDO030Cl(oListBox,aNiv)

Local nI:=0

aNiv[oListBox:nAt,1] := !aNiv[oListBox:nAt,1] 

If oListBox:nAt == 1	// Todos
	For nI:= 2 to Len(aNiv)
		aNiv[nI,1] := aNiv[1,1]
	Next nI
Else
	If !aNiv[oListBox:nat,1]
		aNiv[1,1]:=.F.
	EndIf
EndIf

oListBox:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDO030Ord ³ Autor ³ Eduardo de Souza             ³ Data ³ 03/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordenar vetor de Pendencias                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO030Ord(ExpA1,ExpN1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo as Pendencias                               ³±±
±±³          ³ ExpN1 - Ordem das Pendencias                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA030                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO030Ord(aPenden,nOrdPend)

If nOrdPend == 1
	aPenden := aSort( aPenden,,,{ |x,y| x[1] + x[2] < y[1] + y[2] } )	// "Cod Doc+Revisao"
ElseIf nOrdPend == 2
	aPenden := aSort( aPenden,,,{ |x,y| x[1] + x[2] + x[6] < y[1] + y[2] + y[6] } ) // "Cod Doc+Revisao+Dat Vigencia"
ElseIf nOrdPend == 3
	aPenden := aSort( aPenden,,,{ |x,y| x[1] + x[2] + x[5] < y[1] + y[2] + y[5] } ) // "Cod Doc+Revisao+Data Geracao"
ElseIf nOrdPend == 4
	aPenden := aSort( aPenden,,,{ |x,y| x[4] + x[6] < y[4] + y[6] } ) 			   // "Tipo Pend+Dat Vigencia"
ElseIf nOrdPend == 5
	aPenden := aSort( aPenden,,,{ |x,y| x[4] + x[1] + x[2] < y[4] + y[1] + y[6] } ) // "Tipo Pend+Cod Doc+Revisao"
ElseIf nOrdPend == 6
	aPenden := aSort( aPenden,,,{ |x,y| ctod(x[6]) < ctod(y[6]) } )  // "Dat Vigencia"
ElseIf nOrdPend == 7
	aPenden := aSort( aPenden,,,{ |x,y| ctod(x[5]) < ctod(y[5]) } )  // "Data Geracao"
ElseIf nOrdPend == 8
	aPenden := aSort( aPenden,,,{ |x,y| ctod(x[7]) < ctod(y[7]) } )  // "Dat Implata"
ElseIf nOrdPend == 9
	aPenden := aSort( aPenden,,,{ |x,y| ctod(x[8]) < ctod(y[8]) } ) // "Dat Validade"
ElseIf nOrdPend == 10
	aPenden := aSort( aPenden,,,{ |x,y| x[3] < y[3] } )               // "Titulo Doc"
ElseIf nOrdPend == 11
	aPenden := aSort( aPenden,,,{ |x,y| x[10] + x[1] + x[2] < y[10] + y[1] + Y[2] } ) //"Tipo Doc+Cod Doc+Revisao"
Else
	aPenden := aSort( aPenden,,,{ |x,y| x[3] < y[3] } )               // "Titulo Doc"
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDO030MsgA³ Autor ³ Eduardo de Souza             ³ Data ³ 21/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Mensagem do Aviso                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO030MsgA(ExpC1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo de Aviso                                              ³±±
±±³          | ExpC2 - Documento  												  ³±±
±±³          | ExpC3 - Revisao 												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA030                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO030MsgA(cTipoAviso,cDocto,cRev)
Local 	cMsg    := ""
Local   nPosQDH	:= QDH->(Recno())
Local   nIndQDH := QDH->(IndexOrd())
Default cDocto  := ""
Default cRev    := ""

If cTipoAviso =="VEN" 
	QDH->(DbSetOrder(1))
	If QDH->(DBSEEK(xFilial("QDH")+cDocto+cRev)) 
		If (QDH->QDH_DTLIM - dDatabase) > 0
			cMsg:= OemToAnsi(STR0052)//"** Documento a Vencer"
		Else
			cMsg:= OemToAnsi(STR0053)//"**Documento Vencido"
		EndIf
	EndIF
	QDH->(DbSetOrder(nIndQDH))
	QDH->(dbGoto(nPosQDH))
Else
	If SX5->(DbSeek(xFilial("SX5")+"QH"+cTipoAviso))
		cMsg:= x5Descri()
	EndIf
EndIf

Return cMsg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDO030BxAv ³ Autor ³ Eduardo de Souza            ³ Data ³ 26/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Tela de Aviso                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO030BxAv()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA030                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO030BxAv(nPos,aAvisos,aPenden,cTipoPend,nOrdPend)

Local lAviso 	:= .T.
Local nPosQAA	:= QAA->(Recno())
Local nOrdQAA	:= QAA->(IndexOrd())
Local aUsrMat	:= QA_USUARIO()
Local cMatFil	:= aUsrMat[2]
Local cMatCod	:= aUsrMat[3]
Local cMatDep	:= aUsrMat[4]
Local cRv    	:= ""
Local cGerARV   := GetMV("MV_QDBXARF",.F.,"2") // "Define se pede confirmacao de geracao de revisao para aviso Referenciado."
Local lGerARV   := .T.
Local cMvQDRefIn:= GetMv("MV_QDREFIN",.F.,"1") //Define a Referencia do Documento Invertida (1-PaisxFilhos ,2-FilhosxPais, 3-Ambas) 
Local aArea		:= {}
Local cQDSFil	:= cQDHFil        
Local lQGTRM	:= GetMV("MV_QGTRM",.F.,"2")=="1" .AND. GetMv("MV_QGINT")=="S" // "Indica se os modulos Quality estÒo integrados com Modulo SIGATRM trabalha em conjunto com MV_QGINT"
Local lBxAvRef	:= .T.


IF FWModeAccess("QDS") == "E" //!Empty(cQDSFil)

	IF cMvQDRefIn <> "1"
		cQDSFil:=aAvisos[nPos,10]
	Else
		cQDSFil:=aAvisos[nPos,8]
	Endif
	IF !(aAvisos[nPos,1] $ "CAN.TMP")
		IF cQDSFil<>cQDHFil
			MsgAlert(OemToAnsi(STR0051)+" "+QDO30FIL(cQDSFil))     	 //"Este Aviso devera ser baixado na Filial"
			Return
		Endif
	Endif
Endif

DbSelectArea("QDH")
Set Filter To
DbGotop()

If aAvisos[nPos,1] == "SID" .Or. aAvisos[nPos,1] == "SAD" // Solicitacoes
	
	QDP->(DbSetOrder(3))
	If QDP->(DBSEEK(xFilial("QDP")+aAvisos[nPos,5]+aAvisos[nPos,3]+aAvisos[nPos,4])) 
		lNoCancel:=.F.
		QD052BAIXA("QDP",QDP->(Recno()),6)
	EndIf

ElseIf aAvisos[nPos,1] == "VEN" // Documento Vencido
	QDH->(DbSetOrder(1))
	If QDH->(DBSEEK(xFilial("QDH")+aAvisos[nPos,3]+aAvisos[nPos,4]))
		QD050GerRv("QDH",QDH->(Recno()),6)
	EndIF
ElseIf aAvisos[nPos,1] == "CAN" // Documento Cancelado
	
	QDH->(DbSetOrder(1))
	If QDH->(DBSEEK(cQDSFil+aAvisos[nPos,3]+aAvisos[nPos,4]))
		If QD050Telas("QDH",QDH->(Recno()),2) == 1
			If MsgYesNo(OemtoAnsi(STR0044),OemToAnsi(STR0045)) // "Finalizar Aviso ?"  ### "Atencao"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Baixa o Aviso de Documento Cancelado       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QDS->(DbSetOrder(1))
				If QDS->(DBSEEK(cMatFil+cMatCod+"P"+"CAN"+QDH->QDH_DOCTO+QDH->QDH_RV))
					RecLock("QDS",.F.)
					QDS->QDS_PENDEN := "B"
					QDS->QDS_DTBAIX:= dDataBase
					QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
					QDS->QDS_FMATBX := cMatFil
					QDS->QDS_MATBX  := cMatCod
					QDS->QDS_DEPBX  := cMatDep
					QDS->(MsUnlock())
				EndIf
			EndIf
		EndIf
		DbSelectArea("QDH")
		Set Filter To
		DbGotop()
	EndIf
	
ElseIf aAvisos[nPos,1] == "REF" // Documento Referenciado
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pede confirmacao para baixar o Aviso de Referencia sem gerar revisao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cGerARV == "1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Baixa o Aviso de Referencia                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MsgYesNo(OemtoAnsi(STR0050),OemToAnsi(STR0045)) // "Deseja baixar o Aviso sem gerar revisao ?"  ### "Atencao"
			
			lGerARV := .F.			
			lBxAvRef:= .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada para gerar uma justificativa e/ou executar acoes, controla a baixa do aviso de documento referenciado.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock( "QDOAP34" )
				lBxAvRef:= ExecBlock( "QDOAP34", .f., .f. )
			Endif
            
            If lBxAvRef
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Baixa o Aviso de Referencia                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QDS->(DbSetOrder(2))
				If QDS->(DBSEEK(xFilial("QDH")+aAvisos[nPos,3]+aAvisos[nPos,4]+"REF"))
					While QDS->(!Eof()) .And. 	QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV+QDS->QDS_TPPEND == ;
						xFilial("QDH")+aAvisos[nPos,3]+aAvisos[nPos,4]+"REF"
						If QDS->QDS_PENDEN == "P"
							RecLock("QDS",.F.)
							QDS->QDS_PENDEN := "B"
							QDS->QDS_DTBAIX:= dDataBase
							QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
							QDS->QDS_FMATBX := cMatFil
							QDS->QDS_MATBX  := cMatCod
							QDS->QDS_DEPBX  := cMatDep
							QDS->(MsUnlock())
						EndIf
						QDS->(DbSkip())
					EndDo
				EndIf
			Endif
		Endif
	Endif
	
	If lGerARV
		QDH->(DbSetOrder(1))
		cRv:= QDUltRvDoc(aAvisos[nPos,3])
		If QDH->(DBSEEK(xFilial("QDH")+aAvisos[nPos,3]+cRv))
			If QD050GerRv("QDH",QDH->(Recno()),6)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Baixa o Aviso de Referencia                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QDS->(DbSetOrder(2))
				If QDS->(DBSEEK(xFilial("QDH")+aAvisos[nPos,3]+aAvisos[nPos,4]+"REF"))
					While QDS->(!Eof()) .And. 	QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV+QDS->QDS_TPPEND == ;
						xFilial("QDH")+aAvisos[nPos,3]+aAvisos[nPos,4]+"REF"
						If QDS->QDS_PENDEN == "P"
							RecLock("QDS",.F.)
							QDS->QDS_PENDEN := "B"
							QDS->QDS_DTBAIX:= dDataBase
							QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
							QDS->QDS_FMATBX := cMatFil
							QDS->QDS_MATBX  := cMatCod
							QDS->QDS_DEPBX  := cMatDep
							QDS->(MsUnlock())
						EndIf
						QDS->(DbSkip())
					EndDo
				EndIf
			EndIf
			DbSelectArea("QDH")
			Set Filter To
			DbGotop()
		EndIf
	Endif
	
ElseIf aAvisos[nPos,1] == "TRE" // Necessidade de Treinamento
	
	QD080Inclu("QDA",QDA->(Recno()),3,aAvisos[nPos,3],aAvisos[nPos,4],lAviso)
	
ElseIf aAvisos[nPos,1] == "TI " // Agendamento de Treinamento
	IF !lQGTRM  //Nao Integrado com SIGATRM
		QDA->(DbSetOrder(2))
		If QDA->(DBSEEK(xFilial("QDA")+aAvisos[nPos,3]+aAvisos[nPos,4]+SubStr(aAvisos[nPos,5],1,8)))
			If QD080Visual("QDA",QDA->(Recno()),2)
				If MsgYesNo(OemtoAnsi(STR0044),OemToAnsi(STR0045)) // "Finalizar Aviso ?"  ### "Atencao"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Baixa o Aviso de Agendamento de Treinamento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QDS->(DbSetOrder(1))
					If QDS->(DBSEEK(cMatFil+cMatCod+"P"+"TI "+QDA->QDA_DOCTO+QDA->QDA_RV+QDA->QDA_ANO+QDA->QDA_NUMERO))
						RecLock("QDS",.F.)
						QDS->QDS_PENDEN := "B"
						QDS->QDS_DTBAIX:= dDataBase
						QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
						QDS->QDS_FMATBX := cMatFil
						QDS->QDS_MATBX  := cMatCod
						QDS->QDS_DEPBX  := cMatDep
						QDS->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf
	Else                                   
		//Integrado com SIGATRM		                
		QA_VisTRM(cMatCod)
		If MsgYesNo(OemtoAnsi(STR0044),OemToAnsi(STR0045)) // "Finalizar Aviso ?"  ### "Atencao"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Baixa o Aviso de Agendamento de Treinamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QDS->(DbSetOrder(1))
			If QDS->(DBSEEK(cMatFil+cMatCod+"P"+"TI "+aAvisos[nPos,3]+aAvisos[nPos,4]+aAvisos[nPos,5]))
				RecLock("QDS",.F.)
				QDS->QDS_PENDEN := "B"
				QDS->QDS_DTBAIX:= dDataBase
				QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
				QDS->QDS_FMATBX := cMatFil
				QDS->QDS_MATBX  := cMatCod
				QDS->QDS_DEPBX  := cMatDep
				QDS->(MsUnlock())
			EndIf
		EndIf		
	Endif
	
ElseIf aAvisos[nPos,1] == "TMP" // Ausencia Temporaria
	QAE->(DbSetOrder(1))
	If QAE->(DBSEEK(xFilial("QAE")+aAvisos[nPos,5]))
		QX040TELAS("QAE",QAE->(Recno()),2)
	EndIf
	
ElseIf aAvisos[nPos,1] == "QUE" // Questionario
	QAG->(DbSetOrder(2))
	If !QAG->(DbSeek(xFilial("QAG")+aAvisos[nPos,3]+aAvisos[nPos,4]))
		//Inclui
		QX050Telas("QAG",0,3,aAvisos[nPos,3],aAvisos[nPos,4],lAviso)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avisa que ja existe e		 ³
		//³Baixa o Aviso de  Questionario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QX050Telas("QAG",QAG->(Recno()),4,aAvisos[nPos,3],aAvisos[nPos,4],lAviso)
		QDS->(DbSetOrder(1))
		IF QDS->(DbSeek(cMatFil+cMatCod+"P"+"QUE"+aAvisos[nPos,3]+aAvisos[nPos,4]))
			RecLock("QDS",.F.)
			QDS->QDS_PENDEN := "B"
			QDS->QDS_DTBAIX:= dDataBase
			QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
			QDS->QDS_FMATBX := cMatFil
			QDS->QDS_MATBX  := cMatCod
			QDS->QDS_DEPBX  := cMatDep
			QDS->(MsUnlock())
		EndiF
	Endif
	
EndIf
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Remonta o array Avisos             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QD030LePen(@aPenden,cTipoPend,nOrdPend,@aAvisos)

QAA->(DbSetOrder(nOrdQAA))
QAA->(DbGoto(nPosQAA))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD30AtuFold ³ Autor ³ Eduardo de Souza    ³ Data ³ 06/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Atualiza Folder Pendencias/Avisos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QD30AtuFold(ExpA1,ExpO1,ExpB1,ExpA2,ExpO2,ExpB2,ExpO3,ExpO4)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo os Documentos Pendentes             ³±±
±±³          ³ ExpO1 - Objeto List Box Pendencias                         ³±±
±±³          ³ ExpB1 - Bloco QD1Line1                                     ³±±
±±³          ³ ExpA2 - Array contendo Avisos                              ³±±
±±³          ³ ExpO2 - Objeto List Box Avisos                             ³±±
±±³          ³ ExpB2 - Bloco QDSLine1                                     ³±±
±±³          ³ ExpO3 - Objeto Folder                                      ³±±
±±³          ³ ExpO4 - Objeto Tela Folder                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD30AtuFold(aPenden,oQD1,bQD1Line1,aAvisos,oQDS,bQDSLine1,oPend,oDlgFolder)
Local lRet:=.T.

If oPend:nOption == 1
	If Len(aPenden) > 1 .Or. (Len(aPenden) == 1 .And. aPenden[1,9] <> -1)
		If oQD1:nAt > Len(aPenden)
			oQD1:nAt:= Len(aPenden)
		EndIf
		oQD1:SetArray(aPenden)
		oQD1:bLine:= bQD1Line1
		oQD1:Refresh()
	ElseIf Len(aAvisos) > 1 .Or. (Len(aAvisos) == 1 .And. aAvisos[1,6] <> -1)
		oPend:nOption:= 2
		oQDS:SetArray(aAvisos)
		oQDS:bLine:= bQDSLine1
		oQDS:Refresh()
	Else
		lRet:=.F.
	EndIf
Else
	If Len(aAvisos) > 1 .Or. (Len(aAvisos) == 1 .And. aAvisos[1,6] <> -1)
		If oQDS:nAt > Len(aAvisos)
			oQDS:nAt:= Len(aAvisos)
		EndIf
		oQDS:SetArray(aAvisos)
		oQDS:bLine:= bQDSLine1
		oQDS:Refresh()
	ElseIf Len(aPenden) > 1 .Or. (Len(aPenden) == 1 .And. aPenden[1,9] <> -1)
		oPend:nOption:= 1
		oQD1:SetArray(aPenden)
		oQD1:bLine:= bQD1Line1
		oQD1:Refresh()
	Else
		lRet:=.F.
	EndIf
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDO30FIL  ºAutor  ³Telso Carneiro      º Data ³  13/10/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Localiza o Nome da Filial para os ListBox                  º±±
±±º			 ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QDO30FIL(Filial )                          				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  oQI2:bLine;oQI21:bLine;oQI3:bLine;oQI5:bLine              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QDO30FIL(cCodFil)
local aArea   := GetArea()
Local nPosSM0 := 1
Local cFilAtu :=""  

DbSelectArea("SM0")
DbSetOrder(1)
nPosSM0:= Recno()

If SM0->(DbSeek(cEmpAnt+cCodFil))
	cFilAtu := cCodFil+"-"+FWGETCODFILIAL //SM0->M0_FILIAL
Endif
SM0->(DbGoto(nPosSM0))

RestArea(aArea)

Return(cFilAtu)
