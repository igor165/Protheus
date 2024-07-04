#INCLUDE "TOTVS.CH"
#INCLUDE "QNCA050.CH"
#INCLUDE "OLECONT.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA050  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao de Pendencias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³01/10/02³ ---- ³ Alterado para baixar etapa aleatoriamente³±±
±±³Eduardo S.  ³30/10/02³059432³ Alterado para qdo o parametro MV_QNEAPLA ³±±
±±³            ³        ³      ³ estiver definido com "2", nao encerrar au³±±
±±³            ³        ³      ³ tomaticamente o Plano e FNCs relacionadas³±±
±±³Eduardo S.  ³06/11/02³ Melh ³ Alteracao na pendencia de Etapas para per³±±
±±³            ³        ³      ³ mitir anexar documentos.                 ³±±
±±³Eduardo S.  ³06/02/03³062327³ Acerto para gravar a data de realizacao  ³±±
±±³            ³        ³      ³ somente para a etapa atual.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA050()
Local aButtons   := {}
Local aData      := {}
Local aQI2       := {}
Local aQI21      := {}
Local aQI2Sit    := {}
Local aQI3       := {}
Local aQI3Sit    := {}
Local aQI5       := {}
Local aQI51      := {}
Local aQTipo     := {}
Local aSize      := MsAdvSize()
Local aStatus    := {}
Local aUsrMat    := QNCUSUARIO()
Local cBarRmt    := IIF(IsSrvUnix(),"/","\")
Local cChaveQI5  := ""
Local cDelAnexo  := GetMv("MV_QDELFNC",.F.,"1") // "Apagar Documentos Anexos no Diretorio Temporario"
Local cQI2       := ""
Local cQI21      := ""
Local cQI3       := ""
Local cQI5       := ""
Local cQI51      := ""
Local lPendencia := .F.
Local lQNCGBXIT  := ExistBlock("QNCGBXIT")
Local nOpcao     := 0
Local nQI5Status := 0
Local nT         := 0
Local nTF        := 0
Local oBtn04     := NIL
Local oBtn05     := NIL
Local oBtn06     := NIL
Local oBtn07     := NIL
Local oBtn08     := NIL
Local oBtn09     := NIL
Local oBtn11     := NIL
Local oBtn12     := NIL
Local oBtn13     := NIL
Local oBtn14     := NIL
Local oBtn15     := NIL
Local oBtn16     := NIL
Local oBtn17     := NIL
Local oBtn20     := NIL
Local oBtn21     := NIL
Local oDlg       := NIL
Local oFont      := NIL
Local oPanel     := NIL
Local oPanel1    := NIL
Local oPanel2    := NIL
Local oPanel3    := NIL
Local oPanel4    := NIL
Local oPanel5    := NIL

Private aHeadAne   := {}
Private aQPath     := QDOPATH()
Private cAttach    := ""
Private cCadastro  := ""
Private cDescDF12  := ""
Private cEncAutPla := AllTrim(GetMv("MV_QNEAPLA",.f.,"1")) // Encerramento Automatico de Plano
Private cMail      := ""
Private cMatCod    := aUsrMat[3]
Private cMatDep    := aUsrMat[4]
Private cMatFil    := aUsrMat[2]
Private cQPathFNC  := QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
Private cQPathTrm  := aQPath[3]
Private lApelido   := aUsrMat[1]
Private lBaixaAle  := If(GetMv("MV_QNCBALE",.f.,"2") == "1",.T.,.F.) // Baixa Aleatoria de Etapas
Private lExecQI5   := .F.
Private lQn050Lfil := .F.
Private lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.) //Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Private oFolder1   := NIL
Private oMFolder12 := NIL
Private oQI2       := NIL
Private oQI21      := NIL
Private oQI3       := NIL
Private oQI5       := NIL
Private oQI51      := NIL

DEFAULT aUsuarios := {}

If GetMv("MV_QTMKPMS",.F.,1) == 4 .OR. GetMv("MV_QTMKPMS",.F.,1) == 3
	MsgAlert(STR0103)
	Return NIL
Endif

If lTMKPMS
	aStatus := {"  0%"," 25%"," 50%"," 75%","100%",STR0084}//"Reprovado"
Else
	aStatus :=	{"  0%"," 25%"," 50%"," 75%","100%"}
Endif


If !Right( cQPathFNC,1 ) == cBarRmt
	cQPathFNC := cQPathFNC + cBarRmt
Endif
If !Right( cQPathTrm,1 ) == cBarRmt
	cQPathTrm := cQPathTrm + cBarRmt
Endif

QNCCBOX("QI2_STATUS",@aQI2Sit)
QNCCBOX("QI3_STATUS",@aQI3Sit)
QNCCBOX("QI3_TIPO"  ,@aQTipo)

INCLUI   := .F.
lRefresh := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Usuario Logado esta cadastrado no Cad.Usuarios/Responsaveis atraves   ³
//³ do Apelido cadastro no Configurador                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lApelido
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
	return NIL
Endif

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as pendencias no Array (campos) - Plano de Acao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QI2")
dbSetOrder(1)

dbSelectArea("QI9")
dbSetOrder(1)

If Existblock("QN050LFIL")
	lQn050Lfil := Execblock("QN050LFIL",.F.,.F.,{cMatFil,cMatCod,cMatDep})
Endif

//Carrega Array aQI3
QNCA50QI3(@aQI3,cMatFil,cMatCod,lQn050Lfil)

// Carrega Array aQI5
QNCA50QI5(@aQI5,cMatFil,cMatCod,lQn050Lfil)

If Len(aQI3) == 0
	AADD( aQI3,{" "," "," "," ",CTOD(" / / "),CTOD(" / / "),"1",0," " })
Endif

dbSelectArea("QI5")
dbSetOrder(1)

// Posiciona as Ocorrencias/Nao-conformidades Relacionadas
QNC050LeFNC(1,aQI5,@aQI2,aQI3,.F.,aQI2Sit)
QNC050LeFNC(1,aQI5,@aQI21,aQI3,.T.,aQI2Sit)
If Len(aQI5) == 0 .And. ((Len(aQI2) > 0 .And. aQI2[1,1] <> " ") .Or. (Len(aQI3) > 0 .And. aQI3[1,1] <> " "))
	aAdd(aQI5,{Space(10),Space(2)," ",Space(10),CtoD("  /  /  ","DDMMYY"),CtoD("  /  /  ","DDMMYY"),0,Space(50),Space(10),Space(10)," " })
Endif

If !( ( Len(aQI5) > 0 .And. !Empty(aQI5[1,1])) .Or. ;
	  ( Len(aQI2) > 0 .And. !Empty(aQI2[1,1])) .Or. ;
	  ( Len(aQI3) > 0 .And. !Empty(aQI3[1,1])) )
   Help( " ", 1, "QNCNPENDE" )
   Return Nil
EndIf

AADD( aQI51,{Space(10)," "," "," "," "," "," ",CTOD(" / / "),CTOD(" / / ")," "," "," ",0," " })

If !(lExecQI5)
	aQI5 := aSort(aQI5,,,{|x,y| DtoS(x[5]) < DtoS(y[5]) })
Endif

CursorArrow()

DEFINE FONT oFont NAME "Courier New" SIZE 6,0

DEFINE MSDIALOG oDlg FROM aSize[7],000 TO aSize[6],aSize[5] TITLE OemToAnsi(STR0001) PIXEL OF oMainWnd // "Manuten‡ao de Pendˆncias"

@ 013,002 FOLDER oFolder1 SIZE 315,183 OF oDlg PIXEL ;
          PROMPTS OemtoAnsi(STR0054),OemtoAnsi(STR0042),OemToAnsi(STR0043) // "Etapas/Passos" ### "Plano de Acao" ### "Ficha de Ocorrencias/Nao-Conformidades"

oFolder1:Align := CONTROL_ALIGN_ALLCLIENT
oFolder1:aDialogs[1]:BWHEN:={|| !Empty(aQI5[1,1])} // Folder 1 - Etapas/Passos

IF !ExistBlock( "QNC50BLFD" )
	oFolder1:aDialogs[2]:BWHEN:={|| !Empty(aQI3[1,1])} // Folder 2 - Plano de Acao
	oFolder1:aDialogs[3]:BWHEN:={|| !Empty(aQI2[1,1])} // Folder 3 - Ficha de Ocorrencias/Nao-conformidades
Else
	oFolder1:aDialogs[2]:BWHEN:={|| ExecBlock( "QNC50BLFD", .f., .f., {2} )} // Folder 2 - Plano de Acao
	oFolder1:aDialogs[3]:BWHEN:={|| ExecBlock( "QNC50BLFD", .f., .f., {3} )} // Folder 3 - Ficha de Ocorrencias/Nao-conformidades
Endif

@ 00,00 MSPANEL oPanel PROMPT "" SIZE 008,014 OF oFolder1:aDialogs[1]
oPanel:Align := CONTROL_ALIGN_TOP 

// Folder 1 - Etapas/Passos
@ 1,001 BUTTON oBtn11 PROMPT OemToAnsi(STR0044) SIZE 75,10 OF oPanel PIXEL ; // "Baixar Etapa Plano Acao"
        ACTION (QNC050BxPen(oQI5:nAt,@aQI5,aStatus,oQi5,6,dDataBase),oDlg:end(),QNCA050()) ;
        WHEN !Empty(aQI5[1,1])

@ 1,076 BUTTON oBtn12 PROMPT OemToAnsi(STR0045) SIZE 75,10 OF oPanel PIXEL ; // "Descricao Plano de Acao"
        ACTION QNCVIEWMEMO("1",aQI5,oQI5:nAt,,,aQI5[oQI5:nAt,11]) ;
        WHEN !Empty(aQI5[1,1])

@ 1,151 BUTTON oBtn13 PROMPT OemToAnsi(STR0046)  SIZE 75,10 OF oPanel PIXEL ; // "Cadastro Plano de Acao"
        ACTION (QNC050CdAca(aQI5[oQI5:nAt,7],4),,oQI3:Refresh(.T.),oDlg:end(),QNCA050());
        WHEN !Empty(aQI5[1,1])

@ 1,226 BUTTON oBtn05 PROMPT OemToAnsi(STR0058)  SIZE 75,10 OF oPanel PIXEL ; // "Visualiza Etapas"
        ACTION QNC050VSETA(oQI5:nAt,aQI5,aStatus) ;
        WHEN !Empty(aQI5[1,1])

@ 012, 002 LISTBOX oQI5 VAR cQI5 FIELDS HEADER Alltrim(TitSx3("QI5_FILIAL")[1]),;
											   Alltrim(TitSx3("QI5_CODIGO")[1]),;
                                               Alltrim(TitSx3("QI5_STATUS")[1]),;
                                               Alltrim(TitSx3("QI5_TPACAO")[1]),;
                                               Alltrim(TitSx3("QI5_DESCRE")[1]),;
                                               Alltrim(TitSx3("QI5_PRAZO" )[1]),;
                                               Alltrim(TitSx3("QI5_REALIZ" )[1]) ;
   		   COLSIZES NIL,42,42 ;
           SIZE 309,aSize[4]-130 OF oFolder1:aDialogs[1] PIXEL ;
           ON DBLCLICK (QNC050BxPen(oQI5:nAt,@aQI5,aStatus,oQi5,6,dDataBase),oQI5:Refresh(.T.),oDlg:end(),QNCA050());
           ON CHANGE (QNC050LeFNC(oQI5:nAt,aQI5,@aQI21,aQI3,.T.,aQI2Sit),;
                      oQI21:aArray:=aQI21,;
                      oQI21:bLogicLen:={|| Len(aQI21)},;
                      oQI21:Refresh(.T.),;
                      If(Empty(AllTrim(aQI21[1,1])) ,(oBtn14:Disable(),oBtn15:Disable(),oBtn16:Disable(),oBtn04:Disable()),;
                      (oBtn14:Enable(),oBtn15:Enable(),oBtn16:Enable(),oBtn04:Enable())),;
                      If(!aQI21[oQI21:nAt,11],oBtn15:Disable(),oBtn15:Enable()),;
                      oBtn14:Refresh(),oBtn15:Refresh(),oBtn16:Refresh(),oBtn04:Refresh() )                  
oQI5:SetArray(aQI5)
oQI5:cToolTip := OemToAnsi(STR0002) //"Duplo click para Baixar Pendˆncia"
oQI5:bLine    := {||{ QNC50FIL(aQI5[oQI5:nAt,11]),Transform(aQI5[oQI5:nAt,1],PesqPict("QI5","QI5_CODIGO"))+"  "+aQI5[oQI5:nAt,2],aStatus[Val(aQI5[oQI5:nAt,3])+1],aQI5[oQI5:nAt,4],aQI5[oQI5:nAt,8],DTOC(aQI5[oQI5:nAt,5]),DTOC(aQI5[oQI5:nAt,6])}}
oQI5:Align := CONTROL_ALIGN_TOP

@ 00,00 MSPANEL oPanel1 PROMPT " "+OemToAnsi(STR0019) SIZE 008,020 OF oFolder1:aDialogs[1] // "Ficha Ocorrencia/Nao-conformidades Relacionadas"
oPanel1:Align := CONTROL_ALIGN_TOP

@ 8,001 BUTTON oBtn14 PROMPT OemToAnsi(STR0047) SIZE 75,10 OF oPanel1 PIXEL ; // "Descricao Detalhada"
          ACTION QNCVIEWMEMO("2",aQI21,oQI21:nAt) ;
          WHEN !Empty(aQI21[1,1])

@ 8,076 BUTTON oBtn15 PROMPT OemToAnsi(STR0048) SIZE 75,10 OF oPanel1 PIXEL ; // "Documento Anexo"
          ACTION (aRotina := { {"","",0,1}, {"","",0,2}, {"","",0,3},{"","",0,4} },;
          		 QI2->(DbGoto(aQI21[oQI21:nAt,5])),;
          		 RegToMemory("QI2"), FQNCANEXO("QIF",2,aQI21[oQI21:nAt,13]));
          WHEN aQI21[oQI21:nAt,11]

@ 8,151 BUTTON oBtn16 PROMPT OemToAnsi(STR0049) SIZE 75,10 OF oPanel1 PIXEL ; // "Cadastro"
          ACTION QNC050CaFNC(aQI21[oQI21:nAt,5],2,aQI21,oQI21:nAt,aQI2Sit) ;
          WHEN !Empty(aQI21[1,1])

@ 8,226 BUTTON oBtn04 PROMPT OemToAnsi(STR0059) SIZE 75,10 OF oPanel1 PIXEL ; // "Impressao"
          ACTION QNC050IFNC(aQI21[oQI21:nAt,5]) ;
          WHEN !Empty(aQI21[1,1])


@ 120, 005 LISTBOX oQI21 VAR cQI21 FIELDS HEADER " ",Alltrim(TitSx3("QI2_STATUS")[1]),;
													Alltrim(TitSx3("QI2_PRIORI")[1]),;
													Alltrim(TitSx3("QI2_FILIAL")[1]),;
													Alltrim(TitSx3("QI2_FNC")[1]),;
													Alltrim(TitSx3("QI2_DESCR")[1]),;
										    		Alltrim(TitSx3("QI2_OCORRE")[1]),;
										    		Alltrim(TitSx3("QI2_CONPRE")[1]),;
										    		Alltrim(TitSx3("QI2_CONREA")[1]) ;
		     COLSIZES NIL,NIL,30,NIL,42 ;
             SIZE 303,50  OF oFolder1:aDialogs[1] PIXEL ;
             ON DBLCLICK  QNC050CaFNC(aQI21[oQI21:nAt,5],2,aQI21,oQI21:nAt,aQI2Sit)

oQI21:SetArray(aQI21)
oQI21:bLine    := {||{QNC50FNCor(aQI21[oQI21:nAt,12]+aQI21[oQI21:nAt,2]+aQI21[oQI21:nAt,3]),aQI21[oQI21:nAt,1],aQI21[oQI21:nAt,6],QNC50FIL(aQI21[oQI21:nAt,12]),Transform(aQI21[oQI21:nAt,2],PesqPict("QI2","QI2_FNC"))+"  "+aQI21[oQI21:nAt,3],aQI21[oQI21:nAt,4],DtoC(aQI21[oQI21:nAt,7]),DtoC(aQI21[oQI21:nAt,8]),DtoC(aQI21[oQI21:nAt,9])}}
oQI21:cToolTip := OemToAnsi(STR0053) //"Duplo click para Visualizar a Ficha de Ocorrencia/Nao-Conformidade"
oQI21:bCHANGE:= { || ( If(!aQI21[oQI21:nAt,11],oBtn15:Disable(),oBtn15:Enable()),oBtn15:Refresh() ) }
oQI21:Align := CONTROL_ALIGN_TOP

// Folder 2 - Plano de Acao
@ 00,00 MSPANEL oPanel2 PROMPT "" SIZE 008,014 OF oFolder1:aDialogs[2]
oPanel2:Align := CONTROL_ALIGN_TOP

@ 1,001 BUTTON oBtn08 PROMPT OemToAnsi(STR0049) SIZE 75,10 OF oPanel2 PIXEL ; // "Cadastro"
        ACTION (QNC050CdAca(aQI3[oQI3:nAt,8],4,2),oQI3:Refresh(.T.),aQI5,oDlg:end(),QNCA050());
        WHEN !Empty(aQI3[1,1])

@ 1,076 BUTTON oBtn09 PROMPT OemToAnsi(STR0047) SIZE 75,10 OF oPanel2 PIXEL ; // "Descricao Detalhada"
        ACTION QNCVIEWMEMO("1",aQI3,oQI3:nAt,,,aQI3[oQI3:nAt,9]) ;
        WHEN !Empty(aQI3[1,1])

@ 012, 002 LISTBOX oQI3 VAR cQI3 FIELDS HEADER " ",Alltrim(TitSx3("QI3_FILIAL")[1]),;
												Alltrim(TitSx3("QI3_CODIGO")[1]),;
												Alltrim(TitSx3("QI2_DESCR")[1]),;   //QI3_PROBLE
                                               	Alltrim(TitSx3("QI3_STATUS")[1]),;
                                               	Alltrim(TitSx3("QI3_ABERTU")[1]),;
                                               	Alltrim(TitSx3("QI3_ENCPRE")[1]),;
                                               	Alltrim(TitSx3("QI3_TIPO")[1]);
		   COLSIZES NIL,NIL,42,100,42 ;
           SIZE 309,aSize[4]-150  OF oFolder1:aDialogs[2] PIXEL ;  //68
           ON DBLCLICK (QNC050CdAca(aQI3[oQI3:nAt,8],4,2),oQI3:Refresh(.T.),aQI5) ;

oQI3:SetArray(aQI3)
oQI3:cToolTip:= OemToAnsi(STR0055) //"Duplo click para entrar no Cadastro"
oQI3:bLine   := {||{QNC50PLCor(aQI3[oQI3:nAt,9]+aQI3[oQI3:nAt,1]+aQI3[oQI3:nAt,2]),;  //Led
                         QNC50FIL(aQI3[oQI3:nAt,9]),;
                         Transform(aQI3[oQI3:nAt,1],PesqPict("QI3","QI3_CODIGO"))+"  "+aQI3[oQI3:nAt,2],;
                         aQI3[oQI3:nAt,3],; // Memo Descricao
                         aQI3[oQI3:nAt,4],;
                         DTOC(aQI3[oQI3:nAt,5]),;
                         DTOC(aQI3[oQI3:nAt,6]),;
                         aQI3[oQI3:nAt,7] }}
oQI3:bChange := { || If( Len(aQI3) > 0 .And. Len(aQI51) > 0,;
							(FQNC050QI51(@aQI51," ",aQI3[oQI3:nAt,8],aStatus,aQi5),;
                      oQI51:aArray:=aQI51,;
                      oQI51:bLogicLen:={|| Len(aQI51)},;
                      oQI51:Refresh(.T.)),"") }
oQI3:Align := CONTROL_ALIGN_TOP

oFolder1:bSetOption := { |nFolder| If(nFolder = 2, Eval(oQI3:bChange), Nil) }

@ 00,00 MSPANEL oPanel3 PROMPT " "+OemToAnsi(STR0056) SIZE 008,020 OF oFolder1:aDialogs[2] // "Etapas/Passos do Plano de Acao"
oPanel3:Align := CONTROL_ALIGN_TOP

@ 8,001 BUTTON oBtn06 PROMPT OemToAnsi(STR0057) SIZE 75,10 OF oPanel3 PIXEL ; // "Descricao Completa"
        ACTION QNCVIEWMEMO("31",aQI51,oQI51:nAt,OemToAnsi(STR0057),93) ; //"Descricao Completa"
        WHEN !Empty(aQI51[1,1])

@ 8,076 BUTTON oBtn07 PROMPT OemToAnsi(STR0022) SIZE 75,10 OF oPanel3 PIXEL ; // "Observacoes"
        ACTION QNCVIEWMEMO("32",aQI51,oQI51:nAt,OemToAnsi(STR0022),93) ;
        WHEN !Empty(aQI51[1,1])

@ 100, 004 LISTBOX oQI51 VAR cQI51 FIELDS HEADER 	Alltrim(TitSx3("QI5_STATUS")[1]),;
                                               		Alltrim(TitSx3("QI5_TPACAO")[1]),;
													Alltrim(TitSx3("QI5_MAT")[1]),;
                                               		Alltrim(TitSx3("QI5_NUSR")[1]),;
                                               		Alltrim(TitSx3("QI5_PRAZO" )[1]),;
                                               		Alltrim(TitSx3("QI5_REALIZ" )[1]);
           SIZE 305,70 OF oFolder1:aDialogs[2] PIXEL

oQI51:SetArray(aQI51)
oQI51:bLine := {||{ aStatus[Val(aQI51[oQI51:nAt,3])+1],aQI51[oQI51:nAt,4],aQI51[oQI51:nAt,5]+"-"+aQI51[oQI51:nAt,6],aQI51[oQI51:nAt,7],DTOC(aQI51[oQI51:nAt,8]),DTOC(aQI51[oQI51:nAt,9])}}
oQI51:Align := CONTROL_ALIGN_TOP

// Folder 3 - Ficha de Ocorrencias/Nao-conformidades
@ 00,00 MSPANEL oPanel5 PROMPT "" SIZE 008,014 OF oFolder1:aDialogs[3]
oPanel5:Align := CONTROL_ALIGN_TOP

@ 1,001 BUTTON oBtn17 PROMPT OemToAnsi(STR0049)     SIZE 75,10 OF oPanel5 PIXEL ; // "Cadastro"
          ACTION (QNC050CaFNC(aQI2[oQI2:nAt,5],4,@aQI2,oQI2:nAt,aQI2Sit),oQI2:Refresh(.T.)) ;
          WHEN !Empty(aQI2[1,1])

@ 1,076 BUTTON oBtn21 PROMPT OemToAnsi(STR0048)  SIZE 75,10 OF oPanel5 PIXEL ; // "Documento Anexo"
          ACTION (aRotina := { {"","",0,1}, {"","",0,2}, {"","",0,3},{"","",0,4} },;
          		 QI2->(DbGoto(aQI2[oQI2:nAt,5])),;
	      		 RegToMemory("QI2"), FQNCANEXO("QIF",2,aQI2[oQI2:nAt,13])) WHEN aQI2[oQI2:nAt,11]

@ 1,151 BUTTON oBtn20 PROMPT OemToAnsi(STR0059)  SIZE 75,10 OF oPanel5 PIXEL ; // "Impressao"
          ACTION QNC050IFNC(aQI2[oQI2:nAt,5]) ;
          WHEN !Empty(aQI2[1,1])

@ 1, 002 LISTBOX oQI2 VAR cQI2 FIELDS HEADER 	" ",Alltrim(TitSx3("QI2_STATUS")[1]),;
													Alltrim(TitSx3("QI2_PRIORI")[1]),;
													Alltrim(TitSx3("QI2_FILIAL")[1]),;
													Alltrim(TitSx3("QI2_FNC")[1]),;
													Alltrim(TitSx3("QI2_DESCR")[1]),;
										    		Alltrim(TitSx3("QI2_OCORRE")[1]),;
										    		Alltrim(TitSx3("QI2_CONPRE")[1]),;
										    		Alltrim(TitSx3("QI2_CONREA")[1]) ;
		     COLSIZES NIL,NIL,30,NIL,42 ;
             SIZE 309,aSize[4]-130  OF oFolder1:aDialogs[3] PIXEL ; //105
             ON DBLCLICK  	(QNC050CaFNC(aQI2[oQI2:nAt,5],4,@aQI2,oQI2:nAt,aQI2Sit),oQI2:Refresh(.T.))
cDescDF12 := aQI2[1,10]
oQI2:SetArray(aQI2)
oQI2:bLine    := {||{QNC50FNCor(aQI2[oQI2:nAt,12]+aQI2[oQI2:nAt,2]+aQI2[oQI2:nAt,3]),;
 	aQI2[oQI2:nAt,1],aQI2[oQI2:nAt,6],QNC50FIL(aQI2[oQI2:nAt,12]),Transform(aQI2[oQI2:nAt,2],PesqPict("QI2","QI2_FNC"))+"  "+aQI2[oQI2:nAt,3],aQI2[oQI2:nAt,4],DtoC(aQI2[oQI2:nAt,7]),DtoC(aQI2[oQI2:nAt,8]),DtoC(aQI2[oQI2:nAt,9])}}
oQI2:cToolTip := OemToAnsi(STR0002) //"Duplo click para Baixar Pendˆncia"
oQI2:bCHANGE:= { || (cDescDF12 := aQI2[oQI2:nAt,10],oMFolder12:Refresh(.T.),;
			 		If(!aQI2[oQI2:nAt,11],oBtn21:Disable(),oBtn21:Enable()),oBtn21:Refresh() ) }
oQI2:Align := CONTROL_ALIGN_TOP


@ 00,00 MSPANEL oPanel4 PROMPT " "+OemToAnsi(STR0021) SIZE 008,060 OF oFolder1:aDialogs[3] //"Descricao Detalhada"
oPanel4:Align := CONTROL_ALIGN_BOTTOM

@ 8,001 GET oMFolder12 VAR cDescDF12 MEMO READONLY SIZE aSize[5]/2,35 PIXEL OF oPanel4 NO VSCROLL
oMFolder12:oFont:= oFont
oPanel4:Align := CONTROL_ALIGN_TOP

aAdd(aButtons,{"NOTE"   , {||QNC50FNCor("",.T.)} , OemToAnsi( STR0066 ),OemToAnsi(STR0076) } )   //"Legenda da FNC" //"Leg.FNC"
aAdd(aButtons,{"PENDENTE"   , {||QNC50PLCor("",.T.)} , OemToAnsi( STR0067 ),OemToAnsi(STR0077) } )    //"Legenda do Plano de Acao" //"Leg.PLA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar os botoes da enchoicebar                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock( "QNCPENBT" )
	aButtons := ExecBlock( "QNCPENBT", .f., .f., {aButtons} )
Endif

oFolder1:nOption := IF(!Empty(aQI5[1,1]),1,IF(!Empty(aQI3[1,1]),2,IF(!Empty(aQI2[1,1]),3,1)))

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=2,oDlg:End()},,aButtons)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a gravacao das baixas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == 1
	QAA->(dbSetOrder(1))
	QI9->(dbSetOrder(1))
	QI5->(dbSetOrder(1))

	If !Empty(aQI5[1,1]) .And. !Empty(aQI5[1,2])

		Begin Transaction

			For nT := 1 to Len(aQI5)

        		dbSelectArea("QI5")
				dbGoTo(aQI5[nT,7])
				cChaveQI5 := QI5->(QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_SEQ)

				If aQI5[nT,3] == "4"	// Item Baixado
					If lTMKPMS
						aArea      := GetArea()
						lPendencia := QNC50VALPEND()
						RestArea(aArea)
					Endif
                Endif

				aArea := GetArea()
				If aQI5[nT,3] == "5" //Item Rejeitado
					lPendencia := QNC50BXPEND(QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO)
				Endif
				RestArea(aArea)

				dbSelectArea("QI5")
				dbGoTo(aQI5[nT,7])
				cChaveQI5 := QI5->(QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_SEQ)
				If !lPendencia .And. QI5->(DbSeek(cChaveQI5))
					RecLock("QI5",.F.)
					nQI5Status := QI5->QI5_STATUS
					If QI5->QI5_STATUS <> aQI5[nT,3] .and. QI5->(RECNO()) == aQI5[nT,7]
						QI5->QI5_REALIZ:= dDataBase
						QI5->QI5_STATUS:= aQI5[nT,3]
					EndIf

					If !Empty(aQI5[nT,8]) 
						QI5->QI5_DESCRE := aQI5[nT,8]
					EndIf

					If !lTMKPMS
						If aQI5[nT,3] == "4"	// Item Baixado //esta comentado pq foi inserido dentro da funcao QNC50BXPEND
							QI5->QI5_PEND:= "N"
							If Empty(QI5->QI5_PRAZO)
								QI5->QI5_PRAZO:= dDataBase
							Endif
						Endif
					Endif

					QI5->(MsUnLock())
					QI5->(FKCOMMIT())
					If IsInCallStack("QNCA050")
						If !Empty(aQI5[nT,9])
							MSMM(QI5_DESCCO,,,aQI5[nT,9],1,,,"QI5","QI5_DESCCO")
						EndIf
						If !Empty(aQI5[nT,10])
							MSMM(QI5_DESCOB,,,aQI5[nT,10],1,,,"QI5","QI5_DESCOB")
						EndIf
					EndIf
	        	Endif

	        	If lQNCGBXIT 
					ExecBlock("QNCGBXIT",.F.,.F.,{aQI5[nT,7]})	///Passa QI5 que acabou de atualizar/baixar.
				EndIf

				If lBaixaAle .And. !lTMKPMS
					QN030BxAle(aQI5,nT) // Baixa Aleatoria
				Else
					If !lPendencia
						If !lTMKPMS
							QN030BxOrd(aQI5,nT) // Baixa pela ordem cadastrada
						Else
						  	If aQI5[nT,3] == "4"	// Item Baixado
							  	Q50BXTMKPMS(QI5->QI5_FILIAL,QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,,nQI5Status)
							Endif
						Endif
					Endif
				EndIf

			Next
		End Transaction
	Endif

	If FindFunction("QNCATULEG")
		QNCATULEG(cMatFil,cMatCod) //Atualiza o status do usuario após baixa de pendencias
	EndIf

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Libera SoftLock do QI5³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nT := 1 to Len(aQI5)
		dbSelectArea("QI5")
		dbGoTo(aQI5[nT,7])
		MsUnLock()
	Next
Endif

If Len(aUsuarios) > 0 .And. lBaixaAle
	QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
	aUsuarios := {}
Endif

If cDelAnexo == "1"
	aData := DIRECTORY(cQPathTrm+"*.*")
	For nTF:= 1 to Len(aData)
		If 	Subs(aData[nTF,1], Len(QI2->QI2_FNC) + 1, 1) = "F" .And.;
			Subs(aData[nTF,1], Len(QI2->QI2_FNC + "F" + QI2->QI2_REV) + 1, 1) = "F" .And.;
			File(cQPathTrm+AllTrim(aData[nTF,1]))
			FErase(cQPathTrm+AllTrim(aData[nTF,1]))
	   Endif
	Next
EndIf

IF ExistBlock( "QNCBXFIM" )
	ExecBlock( "QNCBXFIM", .f., .f., {aQI5,nOpcao} )
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCVIEWMEMO³ Autor ³ Aldo Marini Junior   ³ Data ³ 10/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para visualizar descricao detalhada               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050MEMO(cTipo,aArray,nPos)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo do Cadastro(1-Plano de Acao,2-FNC)            ³±±
±±³          ³ ExpA1 = Array com os dados do cadastro                     ³±±
±±³          ³ ExpN1 = posicao atual do array/listbox                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCVIEWMEMO(cTipo,aArray,nPos,cTitulo,nTam,cFilArray)
Local oFont
Local oDlg
Local oTexto
Local cTexto    := OemToAnsi(STR0052)	// "Nao ha Descricao Detalhada"
Local nLargJan  := 0
Local nLargMemo := 0

Default cTitulo := OemToAnsi(STR0047)  // "Descricao Detalhada"
Default nTam    := 80
Default cFilArray := xFilial("QI3")

If Len(aArray) == 0
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera Texto ja' existente (nLi e' a linha atual da getdados)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cTipo == "1" // Plano de Acao
	QI3->(DbSetOrder(1))
	If QI3->(dbSeek(cFilArray+Right(aArray[nPos,1],4)+aArray[nPos,1]+aArray[nPos,2]))
		cTexto := MSMM(QI3->QI3_PROBLE,80)
	Endif
ElseIf cTipo == "2" // Ficha Ocorrencia/Nao-Conformidade
	cTexto := aArray[nPos,10]
ElseIf cTipo == "31" // Etapa/Passo Plano de Acao - Descricao Completa
   cTexto := aArray[nPos,11]
ElseIf cTipo == "32" // Etapa/Passo Plano de Acao - Observacao
   cTexto := aArray[nPos,12]
Endif

nTam := If(nTam < Len(Trim(cTitulo)),Len(Trim(cTitulo))+2,nTam)
nLargJan := (nTam * 6)+40

DEFINE FONT oFont NAME "Courier New" SIZE 6,0

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) FROM 15,1 TO 196,nLargJan PIXEL FONT oFont

If nTam > 50
	nLargMemo := round(3.08 * nTam,0)+7
Else
	nLargMemo := round(3.10 * nTam,0)+8
EndIf

@ 6,4 GET oTexto VAR cTexto MEMO READONLY SIZE nLargMemo,60 PIXEL OF oDlg NO VSCROLL
oTexto:oFont:= oFont
oTexto:lReadOnly := .T.

DEFINE SBUTTON FROM 75,2 TYPE 2 PIXEL ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050BxPen³ Autor ³ Aldo Marini Junior   ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para baixar pendencias                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050BxPen(nPos,aQI5,aStatus)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Posicao da linha atual                             ³±±
±±³          ³ ExpA1 = Array com os dados das Etapas/Acoes                ³±±
±±³          ³ ExpA2 = Array com as descricoes dos percentuais            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC050BxPen(nPos,aQI5,aStatus,oList,nPosL,dData)
Local aAreaQI5   := {}
Local aButton    := {}
Local aQPath     := QDOPATH()
Local cBarRmt    := IIF(IsSrvUnix(),"/","\")
Local cCodAcao   := aQI5[nPos,1]
Local cDelAnexo  := GetMv("MV_QDELFNC",.F.,"1") // "Apagar Documentos Anexos no Diretorio Temporario"
Local cDescD     := aQI5[nPos,9]
Local cDescO     := aQI5[nPos,10]
Local cDescR     := aQI5[nPos,8]
Local cEncAutPla := AllTrim(SuperGetMv("MV_QNEAPLA",.f.,"1")) // Encerramento Automatico de Plano
Local cFileTrm	 := ""
Local cNomFilial := Space(30)
Local cQPathFNC  := QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
Local cQPathTrm  := aQPath[3]
Local cRevAcao   := aQI5[nPos,2]
Local cTpAcao    := aQI5[nPos,4]
Local dPrazo     := aQI5[nPos,5]
Local lAltAcao   := If(SuperGetMv("MV_QNCAUET",.F.,"1")=="1",.T.,.F.) // 1=SIM 2=NAO - ALTERACAO DO CAMPO DESCRICAO RESUMIDA E OBSERVACAO
Local lAltDeta   := If(GetMv("MV_QNCADET",.F.,"1")=="1",.T.,.F.) // 1=SIM 2=NAO - ALTERACAO DO CAMPO DESCRICAO DETALHADA
Local lErase     := .T.
Local lPendencia := .F.
Local lRet       := .F.
Local lVcausa    := SuperGetMv("MV_VCAUSA",.F.,.F.)
Local nOpcao     := 0
Local nOrdQI3	 := 1
Local nReg       := aQI5[oQI5:nAt,7]
Local nT		 := 0
Local nX         := 0
Local oCodAcao	 := NIL
Local oDescR     := NIL
Local oDlg       := NIL
Local oMemo1     := NIL
Local oMemo2     := NIL
Local oPane7	 := NIL
Local oPrazo     := NIL
Local oRevAcao   := NIL
Local oTpAcao    := NIL

Private aColAnx  := {}
Private aMsSize  := MsAdvSize()
Private aInfo    :={aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4}
Private aObjects :={{ 100, 100, .T., .T., .T. }}
Private aPosObj  := MsObjSize( aInfo, aObjects, .T. , .T. )
Private lAbreWin := .T.
Private nItem    := Val(aQI5[nPos,3])+1 // Alterado para Private para customizacao JNJ

// Valida preenchimento do parâmetro de MV_QNCPDOC caso o mesmo esteja sem "\" e incluso.
If !Right( cQPathFNC,1 ) == cBarRmt
	cQPathFNC := cQPathFNC + cBarRmt
Endif
If !Right( cQPathTrm,1 ) == cBarRmt
	cQPathTrm := cQPathTrm + cBarRmt
Endif

DEFINE FONT oFont NAME "Arial" BOLD SIZE 9,14

dbSelectArea("QI5")
dbGoTo(nReg)

If FWModeAccess("QI5") == "E" .And. cFilAnt <> QI5->QI5_FILIAL // Validacao para Baixar a Etapa somente na Filial de Origem
	#IFDEF AXS
		cNomFilial := QI5->QI5_FILIAL
	#ELSE
	DbSelectArea( "SM0" )
	nRegAnterior := Recno()
	If DbSeek( cEmpAnt + QI5->QI5_FILIAL )
		cNomFilial := FWGETCODFILIAL+"-"+SM0->M0_FILIAL //SM0->M0_CODFIL
	EndIf
	DbGoTo( nRegAnterior )
	#ENDIF

	MsgAlert(OemToAnsi(STR0061+" "+cNomFilial))	// "Este Plano de Acao/Etapa devera ser baixado na Filial"

Else

IF ExistBlock( "QNCABXPE" )
	lAbreWin := ExecBlock( " QNCABXPE", .f., .f., {aQI5} )
Endif

If Empty(aQI5[nPos,1])
	Return
Endif

cCadastro := OemToAnsi(STR0007)  //"Plano de Acao - Baixa Pendencia"

If ValType("lAbreWin") == "U"
	lAbreWin := .T.
Endif

If lAbreWin

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel

	@ 00,00 MSPANEL oPane7 PROMPT "" SIZE 008,1100 OF oDlg
	oPane7:Align := CONTROL_ALIGN_ALLCLIENT

	@ 005, 000 TO 73,aMsSize[5]/2 LABEL  OF oPane7 PIXEL

	@ 005,205 TO 70,300 LABEL OemToAnsi(STR0010) OF oPane7 COLOR CLR_BLUE PIXEL //"Perc. Baixa"
	If lTMKPMS
		@ 011,210 RADIO oItem VAR nItem 3D SIZE 040,020 OF oPane7 PIXEL ;
			  ITEMS OemToAnsi(aStatus[1]),OemToAnsi(aStatus[2]),OemToAnsi(aStatus[3]),;
	                   OemToAnsi(aStatus[4]),OemToAnsi(aStatus[5]),OemToAnsi(aStatus[6])
	Else
		@ 011,210 RADIO oItem VAR nItem 3D SIZE 040,020 OF oPane7 PIXEL ;
				  ITEMS OemToAnsi(aStatus[1]),OemToAnsi(aStatus[2]),OemToAnsi(aStatus[3]),;
		                   OemToAnsi(aStatus[4]),OemToAnsi(aStatus[5])
	EndIf
	
	@ 013,006 SAY OemToAnsi(STR0008) SIZE 050,007  OF oPane7  PIXEL	//"Codigo Acao"
	@ 013,122 SAY OemToAnsi(STR0013) SIZE 050,007  OF oPane7  PIXEL	//"Prazo Baixa"
	@ 029,006 SAY OemToAnsi(STR0009) SIZE 030,007  OF oPane7  PIXEL	//"Tipo Acao"
	@ 045,006 SAY OemToAnsi(STR0023) SIZE 050,007  OF oPane7  PIXEL	//"Desc.Resumida"

	@ 012,045 MSGET oCodAcao VAR cCodAcao PICTURE PesqPict("QI5","QI5_CODIGO") SIZE 052,010 OF oPane7 PIXEL
	@ 012,100 MSGET oRevAcao VAR cRevAcao PICTURE "99"             SIZE 008,010 OF oPane7 PIXEL
	@ 012,154 MSGET oPrazo   VAR dPrazo   PICTURE "@D"             SIZE 038,010 OF oPane7 PIXEL
	@ 028,045 MSGET oTpAcao  VAR cTpAcao  PICTURE "@!"             SIZE 148,010 OF oPane7 PIXEL
	@ 044,045 MSGET oDescR   VAR cDescR                            SIZE 148,010 OF oPane7 PIXEL WHEN lAltAcao
	oCodAcao:lReadOnly:= .T.
	oRevAcao:lReadOnly:= .T.
	oPrazo:lReadOnly  := .T.
	oTpAcao:lReadOnly := .T.

	If aMsSize[4] < 206
		@ 72,003 SAY OemToAnsi(STR0021) SIZE 120,015 COLOR CLR_BLUE FONT oFont OF oPane7 PIXEL//"Descricao Detalhada"
		@ 79,000 GET oMemo1 VAR cDescD MEMO NO VSCROLL SIZE aMsSize[5]/2,50 PIXEL OF oPane7 WHEN lAltDeta

		@ 133,003 SAY OemToAnsi(STR0022) SIZE 120,015 COLOR CLR_BLUE FONT oFont OF oPane7 PIXEL// "Observacoes"
		@ 140,000 GET oMemo2 VAR cDescO MEMO NO VSCROLL SIZE aMsSize[5]/2,50 PIXEL OF oPane7 WHEN lAltAcao
	Else
		@ 075,004 SAY OemToAnsi(STR0021) SIZE 120,015 COLOR CLR_BLUE FONT oFont OF oPane7 PIXEL//"Descricao Detalhada"
		@ 082,000 GET oMemo1 VAR cDescD MEMO NO VSCROLL SIZE aMsSize[5]/2,90 PIXEL OF oPane7 WHEN lAltDeta

		@ 173,004 SAY OemToAnsi(STR0022) SIZE 120,015 COLOR CLR_BLUE FONT oFont OF oPane7 PIXEL // "Observacoes"
		@ 180,000 GET oMemo2 VAR cDescO MEMO NO VSCROLL SIZE aMsSize[5]/2,90 PIXEL OF oPane7 WHEN lAltAcao
	Endif

	oMemo1:bLClicked := {||AllwaysTrue()}
	oMemo2:bLClicked := {||AllwaysTrue()}

	aAreaQI3 := {}
	aAreaQI3 := QI3->(GETAREA())
	DBSELECTAREA("QI3")
	DBSETORDER(1)//QI3_FILIAL+QI3_ANO+QI3_CODIGO+QI3_REV
	IF QI3->(DBSEEK( aQI5[nPos,11]+SubStr(cCodAcao,LEN(cCodAcao)-3,4)+cCodAcao+cRevAcao))
		nRecnoQI3 := QI3->(RECNO())
	ENDIF
	QI3->(DBCLOSEAREA())
	RESTAREA(aAreaQI3)

	aAdd(aButton ,{"SDUPROP" , {||QNC050AnePla(nPos,aQI5,@aColAnx)}, OemToAnsi(STR0048),OemToAnsi(STR0065) } )  //"Documento Anexo"  //"Doc.Anexo"

	If ExistBlock("QN50BUBX")
		aButton := ExecBlock("QN50BUBX", .f., .f., {aButton})
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IF(QNC050LiOk(cDescR,aQI5,nPos,cDescD,cDescO),(nOpcao:=1,oDlg:End()),"")},{|| nOpcao:=2,oDlg:End()},,aButton)CENTERED

	If nOpcao == 1		// OK
		aQI5[nPos,3] := Str(nItem-1,1)
		aQI5[nPos,8] := cDescR
		aQI5[nPos,9] := cDescD
		aQI5[nPos,10] := cDescO
		If ExistBlock("QNCPABXP")
			ExecBlock("QNCPABXP", .f., .f., {aQI5})
		EndIf
		
		Begin Transaction

			For nT := 1 to Len(aQI5)

        		dbSelectArea("QI5")
				dbGoTo(aQI5[nT,7])
				cChaveQI5 := QI5->(QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_SEQ)

				If aQI5[nT,3] == "4"	// Item Baixado
					If lTMKPMS
						aArea      := GetArea()
						lPendencia := QNC50VALPEND()
						RestArea(aArea)
					Endif
                Endif

				aArea      := GetArea()
				If aQI5[nT,3] == "5" //Item Rejeitado
					lPendencia := QNC50BXPEND(QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO)
				Endif
				RestArea(aArea)

				dbSelectArea("QI5")
				dbGoTo(aQI5[nT,7])
				cChaveQI5 := QI5->(QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_SEQ)
				If !lPendencia .And. QI5->(DbSeek(cChaveQI5))
					RecLock("QI5",.F.)
					nQI5Status := QI5->QI5_STATUS
					If QI5->QI5_STATUS <> aQI5[nT,3] .and. QI5->(RECNO()) == aQI5[nT,7]
						QI5->QI5_REALIZ:= dDataBase
						QI5->QI5_STATUS:= aQI5[nT,3]
					EndIf

					QI5->QI5_DESCRE:= aQI5[nT,8]

					If !lTMKPMS
						If aQI5[nT,3] == "4"	// Item Baixado //esta comentado pq foi inserido dentro da funcao QNC50BXPEND
							QI5->QI5_PEND:= "N"
							If Empty(QI5->QI5_PRAZO)
								QI5->QI5_PRAZO:= dDataBase
							Endif
						Endif
					Endif
					
					MSMM(QI5_DESCCO,,,aQI5[nT,9],1,,,"QI5","QI5_DESCCO")
					MSMM(QI5_DESCOB,,,aQI5[nT,10],1,,,"QI5","QI5_DESCOB")

					QI5->(MsUnLock())
					QI5->(FKCOMMIT())
	        	Endif

				If lBaixaAle .And. !lTMKPMS
					QN030BxAle(aQI5,nT) // Baixa Aleatoria
				Else
					If !lPendencia
						If !lTMKPMS
							QN030BxOrd(aQI5,nT) // Baixa pela ordem cadastrada
						Else
						  	If aQI5[nT,3] == "4"	// Item Baixado
							  	Q50BXTMKPMS(QI5->QI5_FILIAL,QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,,nQI5Status)
							Endif
						Endif
					Endif
				EndIf

			Next

			aAreaQI5 := QI5->(GetArea())
			FOR nX := 1 TO LEN(aQI5)
				IF aQI5[nX,1]+aQI5[nX,2] == QI3->QI3_CODIGO+QI3->QI3_REV
					IF aQI5[nX,3] <> "4"
						lRet := .T.
						EXIT
					ENDIF
				ENDIF
			NEXT nX

			IF !lRet .AND. lVcausa .AND. cEncAutPla <> '2'
				QI6->(Dbsetorder(01))
				QI6->(Dbgotop())
				IF !QI6->(Dbseek(xFilial('QI6')+QI3->QI3_CODIGO+QI3->QI3_REV))
					Help(NIL, NIL, "Causa", NIL, "O Plano de Ação " +ALLTRIM(QI3->QI3_CODIGO)+ ", Revisão " +ALLTRIM(QI3->QI3_REV)+ " não possui CAUSA cadastrada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe uma causa, ou desative o parâmetro MV_VCAUSA."})
					DisarmTransaction()
				ELSE
					lRet := .T.
				ENDIF
			ENDIF
			RestArea(aAreaQI5)

		End Transaction
		

		If oList # Nil .And. nPosL # Nil .And. dData # Nil
			If nItem = 5
				oList:aArray[oList:nAt][nPosL] := dData	// Data da Realizacao
			Else
				oList:aArray[oList:nAt][nPosL] := Ctod("")	// Limpa Data da Realizacao
			Endif

			IF Len(aColAnx) >= 1
				cAliasAnex 	:= "QIE"   	// Variaveis utilizadas em QNCFGet
				aCols 		:= aClone(aColAnx)  // FQNCANEXO
				aHeader		:= {}
				nAColsAtu 	:= 0
				nUsado		:= 0
				nOrdQI3     :=QI3->(IndexOrd())
				QI3->(DbSetOrder(2))
				If QI3->(DbSeek(aQI5[nPos,11]+aQI5[nPos,1]+aQI5[nPos,2]))
					RegToMemory("QI3",.F.)
			  		QNCGAnexo(3,,aCols)
				EndIf
				QI3->(DbSetOrder(nOrdQI3))

		  	ENDIF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava ou Exclui o Documento anexo                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If QIE->(DbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
				While QIE->(!Eof()) .And. QIE->QIE_FILIAL+QIE->QIE_CODIGO+QIE->QIE_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
					cFileTrm:= AllTrim(QIE->QIE_ANEXO)
					If !File(cQPathFNC+cFileTrm)
						If File(cQPathTrm+cFileTrm)
					    	If !CpyT2S(cQPathTrm+cFileTrm,cQPathFNC,.T.)
								Help(" ",1,"QNAOCOPIOU")
					      	Endif
						Else
							If File(cQPathFNC+cFileTrm)
								FErase(cQPathFNC+cFileTrm)
							Endif
						Endif
					EndIf
					QIE->(DbSkip())
				EndDo
	  		EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Variavel de flag para identificar se pode apagar os anexos da FNC ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lErase
				If cDelAnexo == "1"
					aArqFNC := DIRECTORY(cQPathTrm+"*.*")
					For nT:= 1 to Len(aArqFNC)
						If 	QI3->QI3_CODIGO + "_" + QI3->QI3_REV + "_" =;
							Left(aArqFNC[nT,1], Len(QI3->QI3_CODIGO + "_" + QI3->QI3_REV + "_")) .And.;
							File(cQPathTrm+AllTrim(aArqFNC[nT,1]))
							FErase(cQPathTrm+AllTrim(aArqFNC[nT,1]))
					   Endif
					Next
				EndIf
			Endif

		Endif
	Endif
Endif

Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050LeFNC³ Autor ³ Aldo Marini Junior   ³ Data ³ 02/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para carregar os Lactos de FNC relacionados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050BxPen(nPos,aQI5,aQI2,lRelac,aQI2Sit)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Posicao da linha atual                             ³±±
±±³          ³ ExpA1 = Array com os dados das FNC                         ³±±
±±³          ³ ExpA2 = Array com os dados das Etapas/Acoes                ³±±
±±³          ³ ExpA3 = Array com os dados do Plano de Acao                ³±±
±±³          ³ ExpL1 = Valor logico indicando relacionamento entre QI2/QI5³±±
±±³          ³ ExpA3 = Array com as descricoes do tipo de Status-QI2      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC050LeFNC(nPos,aQI5,aQI2,aQI3,lRelac,aQI2Sit)
Local aArea   := GetArea()
Local aQI2Pri := {}
Local cAnexo  := ""
Local cQuery  := ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o conteudo do X3_CBOX no array                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QNCCBOX("QI2_PRIORI",@aQI2Pri)

aQI2 := {}

If lRelac	// Pendencias das Etapas dos Planos de Acao
	If Len(aQI5) > 0
		cQuery :=" SELECT QI2.QI2_FILIAL,QI2.QI2_ANO,QI2.QI2_FNC,QI2.QI2_REV,QI2.QI2_ANEXO, "
		cQuery +=" QI2.QI2_STATUS, QI2.QI2_DESCR,QI2.R_E_C_N_O_,QI2.QI2_PRIORI,QI2.QI2_OCORRE,"
		cQuery +=" QI2.QI2_CONPRE,QI2.QI2_CONREA,QI2.QI2_DDETA "
		cQuery +=" FROM " + RetSqlName("QI9") + " QI9, "+RetSqlName("QI2") + " QI2 "
		cQuery +=" WHERE  "+Iif(!lQn050Lfil,"QI9.QI9_FILIAL='"+aQI5[nPos,11]+"' AND","")+" QI9.QI9_CODIGO='"+aQI5[nPos,1]+"' AND QI9.QI9_REV ='"+aQI5[nPos,2]+"' AND "
		cQuery +=" QI9.QI9_FILIAL=QI2.QI2_FILIAL AND QI9.QI9_FNC=QI2.QI2_FNC AND QI9.QI9_REVFNC=QI2.QI2_REV AND "
		cQuery +=" QI9.D_E_L_E_T_ <> '*' AND QI2.D_E_L_E_T_ <> '*' "

		If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
			cQuery += " ORDER BY 1,2,3,4"
		Else
			cQuery += " ORDER BY " + SqlOrder("QI2_FILIAL+QI2_ANO+QI2_FNC+QI2_REV")
		Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("QNCFILPD")
			cQuery := ExecBlock("QNCFILPD", .f., .f.,{"QI2",cQuery})
		EndIf
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQI2",.T.,.T.)

		TcSetField("TMPQI2","QI2_OCORRE","D")
		TcSetField("TMPQI2","QI2_CONPRE","D")
		TcSetField("TMPQI2","QI2_CONREA","D")

		TMPQI2->(DbGoTop())
		While TMPQI2->(!Eof())
			cAnexo:=""
			If ! Empty(TMPQI2->QI2_ANEXO)
				cAnexo := AllTrim(TMPQI2->QI2_ANEXO)
			Else
				IF QIF->(MSSeek(xFilial("QIF") + TMPQI2->QI2_FNC + TMPQI2->QI2_REV))
					cAnexo := AllTrim(QIF->QIF_ANEXO)
				Endif
			Endif
			aAdd(aQI2,{aQI2Sit[Val(TMPQI2->QI2_STATUS)],;
				TMPQI2->QI2_FNC,;
				TMPQI2->QI2_REV,;
				TMPQI2->QI2_DESCR,;
				TMPQI2->R_E_C_N_O_,;
				aQI2Pri[Val(TMPQI2->QI2_PRIORI)],;
				TMPQI2->QI2_OCORRE,;
				TMPQI2->QI2_CONPRE,;
				TMPQI2->QI2_CONREA,;
				MSMM(TMPQI2->QI2_DDETA,80),;
				! Empty(cAnexo),;
				TMPQI2->QI2_FILIAL,;
				TMPQI2->QI2_STATUS })
			TMPQI2->(DbSkip())
		Enddo
		TMPQI2->(DBCLOSEAREA())
	Endif
Else
	cQuery :=" SELECT QI2.QI2_FILRES,QI2.QI2_MATRES,QI2.QI2_STATUS,QI2.QI2_FILIAL,QI2.QI2_ANO,QI2.QI2_FNC,QI2.QI2_REV,QI2.QI2_ANEXO, "
	cQuery +=" QI2.QI2_DESCR,QI2.R_E_C_N_O_,QI2.QI2_PRIORI,QI2.QI2_OCORRE,"
	cQuery +=" QI2.QI2_CONPRE,QI2.QI2_CONREA,QI2.QI2_DDETA "
	cQuery +=" FROM " + RetSqlName("QI2") + " QI2 "
	cQuery +=" WHERE "+Iif(!lQn050Lfil,"QI2.QI2_FILRES='"+cMatFil+"' AND","")+" QI2.QI2_MATRES ='"+cMatCod+"' AND "
	cQuery +=" QI2.QI2_CONREA='"+SPACE(8)+"' AND "
	cQuery +=" QI2.D_E_L_E_T_ <> '*' "

	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cQuery += " ORDER BY 1,2,3"
	Else
		cQuery += " ORDER BY " + SqlOrder("QI2_FILRES+QI2_MATRES+QI2_STATUS")
	Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QNCFILPD")
		cQuery := ExecBlock("QNCFILPD", .f., .f.,{"QI2",cQuery})
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQI2",.T.,.T.)

	TcSetField("TMPQI2","QI2_OCORRE","D")
	TcSetField("TMPQI2","QI2_CONPRE","D")
	TcSetField("TMPQI2","QI2_CONREA","D")

	TMPQI2->(DbGoTop())
	While TMPQI2->(!Eof())
		cAnexo:=""
		If ! Empty(TMPQI2->QI2_ANEXO)
			cAnexo := AllTrim(TMPQI2->QI2_ANEXO)
		Else
			IF QIF->(MSSeek(xFilial("QIF") + TMPQI2->QI2_FNC + TMPQI2->QI2_REV))
				cAnexo := AllTrim(QIF->QIF_ANEXO)
			Endif
		Endif
		aAdd(aQI2,{aQI2Sit[Val(TMPQI2->QI2_STATUS)],;
			TMPQI2->QI2_FNC,;
			TMPQI2->QI2_REV,;
			TMPQI2->QI2_DESCR,;
			TMPQI2->R_E_C_N_O_,;
			aQI2Pri[Val(TMPQI2->QI2_PRIORI)],;
			TMPQI2->QI2_OCORRE,;
			TMPQI2->QI2_CONPRE,;
			TMPQI2->QI2_CONREA,;
			MSMM(TMPQI2->QI2_DDETA,80),;
			! Empty(cAnexo),;
			TMPQI2->QI2_FILIAL,;
			TMPQI2->QI2_STATUS })

		TMPQI2->(DbSkip())
	Enddo
	TMPQI2->(DBCLOSEAREA())
Endif
RestARea(aArea)

If Len(aQI2) == 0 .And. ( Len(aQI5) > 0 .Or. Len(aQI3) > 0)
	aAdd(aQI2,{Space(4),Space(10),Space(2),OemToAnsi(IF(lRelac,STR0011,STR0006)),;	// "Nenhuma Ocorrencia/Nao-conformidade Relacionada" ### "Nenhuma Ocorrencia/Nao-conformidade Pendente"
				  0," ",CTOD("  /  /  ","DDMMYY"),CTOD("  /  /  ","DDMMYY"),CTOD("  /  /  ","DDMMYY")," ",.F.," ", "", 0})
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050CdAca³ Autor ³ Aldo Marini Junior   ³ Data ³ 03/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Visualizar/Alterar Plano de Acao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050CdAca(nReg) 	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Registro do Plano de Acao                ³±±
±±³          ³ ExpN2 = Numero da opcao do Cadastro(2-Visualizar-4-Alterar)³±±
±±³          ³ ExpN3 = Numero do Cadastro origem (1-Etapas/2-Plano)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC050CdAca(nReg, nOpc, nCadast, aQI5)
Local cNomFilial := Space(30)

default aQI5 := {}

Private aRotina := { {"","",0,0}, {STR0012,"QNC030Alt",0,2}, {"","",0,0}, {"","",0,4} } //"Visualizar"
INCLUI := .F.

nOpc    := If(nOpc == NIL, 2, nOpc)
nCadast := If(nCadast == NIL, 1, nCadast)

If nCadast == 1
	dbSelectArea("QI5")
	dbGoTo(nReg)

	If FWModeAccess("QI5") == "E" .And. cFilAnt <> QI5->QI5_FILIAL .And. nOpc == 4
		#IFDEF AXS
			cNomFilial := QI5->QI5_FILIAL
		#ELSE
		DbSelectArea( "SM0" )
		nRegAnterior := Recno()
		If DbSeek( cEmpAnt + QI5->QI5_FILIAL )
		   cNomFilial := FWGETCODFILIAL+"-"+SM0->M0_FILIAL //SM0->M0_CODFIL
		EndIf
		DbGoTo( nRegAnterior )
		#ENDIF

		MsgAlert(OemToAnsi(STR0061+" "+cNomFilial))	// "Este Plano de Acao/Etapa devera ser baixado na Filial"

	Else
		dbSelectArea("QI3")
		dbSetOrder(1)
		If dbSeek(QI5->QI5_FILIAL+Right(QI5->QI5_CODIGO,4)+QI5->QI5_CODIGO+QI5->QI5_REV)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao de Visualizacao do Plano de Acao do Programa QNCA030  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QNC030Alt("PEN",QI3->(Recno()),nOpc)
		Endif
	Endif
Else
	If nReg > 0
		If FWModeAccess("QI3") == "E" .And. cFilAnt <> QI3->QI3_FILIAL .And. nOpc == 4
			#IFDEF AXS
				cNomFilial := QI3->QI3_FILIAL
			#ELSE
			DbSelectArea( "SM0" )
			nRegAnterior := Recno()
			If DbSeek( cEmpAnt + QI3->QI3_FILIAL )
			   cNomFilial := FWGETCODFILIAL+"-"+SM0->M0_FILIAL //SM0->M0_CODFIL
			EndIf
			DbGoTo( nRegAnterior )
			#ENDIF

			MsgAlert(OemToAnsi(STR0061+" "+cNomFilial))	// "Este Plano de Acao/Etapa devera ser baixado na Filial"
		Else
			QNC030Alt("PEN",nReg,nOpc)
			if nOpc == 4
				// Carrega Array aQI5
				QNCA50QI5(@aQI5,cMatFil,cMatCod,lQn050Lfil)
			Endif
		Endif
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050CaFNC³ Autor ³ Aldo Marini Junior   ³ Data ³ 03/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Carregar Ficha Ocorrencia/Nao-conformidade   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050CaFNC(nReg,nOpc,aArray,nPos,aQI2Sit)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Registro da Ocorrencia/Nao-conformidade  ³±±
±±³          ³ ExpN2 = Numero do Opcao                                    ³±±
±±³          ³ ExpA1 = Array a ser atualizado                             ³±±
±±³          ³ ExpN3 = Numero da posicao atual do aArray                  ³±±
±±³          ³ ExpA2 = Array com as descricoes do status-QI2              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC050CaFNC(nReg,nOpc,aArray,nPos,aQI2Sit)
Local cAliasOld := Alias()
Local nIndexOrd	:= IndexOrd()
Local cNomFilial:= Space(30)
Local aQI2Pri	:= {}

Private aRotina := { {"","",0,0}, {STR0012,"QNC040Alt",0,2}, {"","",0,0}, {STR0020,"QNC040Alt",0,4}, {"","",0,0}, {"","",0,0} } //"Visualizar" ### "Alterar"
INCLUI := .F.
ALTERA := IF(nOpc==2,.F.,.T.)
lRefresh := .F.

If nReg > 0
	dbSelectArea("QI2")
	dbGoTo(nReg)

	If FWModeAccess("QI2") == "E" .And. cFilAnt <> QI2->QI2_FILIAL .And. nOpc == 4 .AND. !lQn050Lfil
		#IFDEF AXS
			cNomFilial := QI2->QI2_FILIAL
		#ELSE
		DbSelectArea( "SM0" )
		nRegAnterior := Recno()
		If DbSeek( cEmpAnt + QI2->QI2_FILIAL )
		   cNomFilial := FWGETCODFILIAL+"-"+SM0->M0_FILIAL //SM0->M0_CODFIL
		EndIf
		DbGoTo( nRegAnterior )
		#ENDIF

		MsgAlert(OemToAnsi(STR0062+" "+cNomFilial)) // "Esta Ficha de Ocorrencia/Nao-Conformidade devera ser baixada na Filial"

	Else
		If QI2->QI2_STATUS $ "1,2,3,4"	// Registrada, Em Analise, Procede, Nao Procede
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao de Visualizacao/Alteracao da Ocorrencia/Nao-conformidade do Progr. QNCA040 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF QNC040Alt("PEN",nReg,nOpc) == 1
				QNCCBOX("QI2_PRIORI",@aQI2Pri)
				aArray[nPos,1] := aQI2Sit[Val(QI2->QI2_STATUS)]
				aArray[nPos,6] := aQI2Pri[Val(QI2->QI2_PRIORI)]
				aArray[nPos,4] := QI2->QI2_DESCR
				aArray[nPos,7] := QI2->QI2_OCORRE
				aArray[nPos,8] := QI2->QI2_CONPRE
				aArray[nPos,9] := QI2->QI2_CONREA
			Endif
		Elseif	QI2->QI2_STATUS $ "5"	// Cancelada
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao de Visualizacao/Alteracao da Ocorrencia/Nao-conformidade do Progr. QNCA040 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF QNC040Alt("PEN",nReg,2) == 1     //Visualiza
				QNCCBOX("QI2_PRIORI",@aQI2Pri)
				aArray[nPos,1] := aQI2Sit[Val(QI2->QI2_STATUS)]
				aArray[nPos,6] := aQI2Pri[Val(QI2->QI2_PRIORI)]
				aArray[nPos,4] := QI2->QI2_DESCR
				aArray[nPos,7] := QI2->QI2_OCORRE
				aArray[nPos,8] := QI2->QI2_CONPRE
				aArray[nPos,9] := QI2->QI2_CONREA
			Endif
		Endif
	Endif

	dbSelectArea(cAliasOld)
	dbSetOrder(nIndexOrd)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050LiOk ³ Autor ³ Aldo Marini Junior   ³ Data ³ 30/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa Validar campos em branco                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050LiOk(cDescR,aQI5)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campos caracter contendo Descricao Resumida        ³±±
±±³          ³ ExpA1 = Array contendo os lactos das Etapas Pendentes      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC050LiOk(cDescR,aQI5,nPos,mDesDet,mdesobs)
Local lAltDeta := If(GetMv("MV_QNCADET",.F.,"1")=="1",.T.,.F.) // 1=SIM 2=NAO - ALTERACAO DO CAMPO DESCRICAO DETALHADA
Local lRet     := .T.

If Empty(cDescR)
	MsgAlert(OemToAnsi(STR0024))	// "Campo Descricao Resumida em Branco, devera ser preenchida as Acoes Efetuadas."
	lRet := .F.
Endif
If lAltDeta .and. Empty(MdesDet)
	MsgAlert("Campo Descricao detalhada em Branco, devera ser detalhada as Acoes Efetuadas.")
	lRet := .F.
EndIf
IF ExistBlock( "QNCAEACO" )
	aQI5[nPos,8] := cDescR
	aQI5[nPos,9] := MdesDet
	aQI5[nPos,10] := mdesobs
	lRet := ExecBlock( "QNCAEACO", .f., .f.,{aQI5,nPos})
Endif

IF lRet
	QI5->(DbGoto(aQI5[nPos,7]))
	IF !SoftLock("QI5")
		lRet := .F.
	Endif
Endif


Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050LiOk ³ Autor ³ Aldo Marini Junior   ³ Data ³ 30/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa Validar campos em branco                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050LiOk(cDescR,aQI5)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campos caracter contendo Descricao Resumida        ³±±
±±³          ³ ExpA1 = Array contendo os lactos das Etapas Pendentes      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC050QI51(aQI51, cChave, nReg, aStatus, aQi5)
Local nPosQi5 := 0
Default cChave := QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
Default nReg := 0
aQI51 := {}
If !Empty(cChave) .Or. nReg > 0
	If nReg > 0
		QI3->(dbGoTo(nReg))
		cChave := QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
	Endif
	If QI5->(dbSeek(cChave))
		While !QI5->(Eof()) .And. cChave == QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV
			If (nPosQi5 := Ascan(aQi5, { |x| x[7] = QI5->(Recno()) })) > 0	// Caso a ficha esteja carregada utilizo pelo Array para trazer a posicao atual da Pendencia
				AADD( aQI51,{	aQi5[nPosQi5][1],;					// Codigo Plano de Acao
								aQi5[nPosQi5][2],;					// Revisao da Acao
								aQi5[nPosQi5][3],;					// Status da Acao
								aQi5[nPosQi5][4],;					// Tipo da Acao
								cMatFil,;							// Filial do Usuario
								cMatCod,;							// Matriculo do Usuario
								QA_NUSR(cMatFil,cMatCod,.F.),; 	// Nome do Usuario
								aQi5[nPosQi5][5],;					// Prazo/Vecto da Acao
								aQi5[nPosQi5][6],;					// Data Realizacao/Baixa
								aQi5[nPosQi5][8],;
								aQi5[nPosQi5][9],;
								aQi5[nPosQi5][10],;
								QI5->(Recno()),;
								aQi5[nPosQi5][11]})// Registro para controle
			Else
				AADD( aQI51,{	QI5->QI5_CODIGO,;						// Codigo Plano de Acao
								QI5->QI5_REV,;							// Revisao da Acao
								QI5->QI5_STATUS,;						// Status da Acao
								FQNCDTPACAO(QI5->QI5_TPACAO),;			// Tipo da Acao
								QI5->QI5_FILMAT,;						// Filial do Usuario
								QI5->QI5_MAT,;							// Matriculo do Usuario
								QA_NUSR(QI5->QI5_FILMAT,QI5->QI5_MAT,.F.),; 	// Nome do Usuario
								QI5->QI5_PRAZO,;						// Prazo/Vecto da Acao
								QI5->QI5_REALIZ,;						// Data Realizacao/Baixa
								QI5->QI5_DESCRE,;
								MSMM(QI5->QI5_DESCCO,80),;
								MSMM(QI5->QI5_DESCOB,80),;
								QI5->(Recno()),;
								QI5->QI5_FILIAL	})							// Registro para controle
			Endif
	      	QI5->(dbSkip())
	   Enddo
	Endif
Endif
If Len(aQI51) == 0
	AADD( aQI51,{Space(10)," "," "," "," "," "," ",CTOD(" / / "),CTOD(" / / ")," "," "," ",0," " })
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050IFNC ³ Autor ³ Aldo Marini Junior   ³ Data ³ 30/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a Ficha de Ocorrencia/Nao-Conformidade             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050IFNC(nRegQI2)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do registro do QI2                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC050IFNC(nRegQI2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime a Ficha de Ocorrencia/Nao-Conformidade formato MsPrint ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QI2")
DbGoto(nRegQI2)
If ExistBlock("QNCR051")
	ExecBlock( "QNCR051",.f.,.f.,{nRegQI2})
Else
	QNCR050(nRegQI2)
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050VSETA³ Autor ³ Aldo Marini Junior   ³ Data ³ 30/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para visualizar as etapas do Plano de Acao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050VSETA(nPos,aQI5,aStatus)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Posicao da linha atual                             ³±±
±±³          ³ ExpA1 = Array com os dados das Etapas/Acoes                ³±±
±±³          ³ ExpA2 = Array com as descricoes dos percentuais            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC050VSETA(nPos,aQI5,aStatus)
Local aQI5Loc  := {}
Local cCodAcao := aQI5[nPos,1]
Local cDescD   := Space(1)
Local cDescO   := Space(1)
Local cFilAcao := aQI5[nPos,11]
Local cQI5     := NIL
Local cRevAcao := aQI5[nPos,2]
Local cChave   := cFilAcao+cCodAcao+cRevAcao
Local nOpcao   := 0
Local nPosQi5  := 0
Local oDlg     := NIL
Local oMemo1   := NIL
Local oMemo2   := NIL
Local oQI5     := NIL
DEFINE FONT oFont NAME "Arial" BOLD SIZE 10,16

Private aMsSize  := MsAdvSize()
Private aInfo    :={aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4}
Private aObjects :={{ 100, 100, .T., .T., .T. }}
Private aPosObj  := MsObjSize( aInfo, aObjects, .T. , .T. )
DEFINE FONT oFont NAME "Arial" BOLD SIZE 9,14

If Empty(AllTrim(cCodAcao))
   Return
Endif


If QI5->(dbSeek(cChave))
	While !QI5->(Eof()) .And. cChave == QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV
		If (nPosQi5 := Ascan(aQi5, { |x| x[7] = QI5->(Recno()) })) > 0	// Caso a ficha esteja carregada utilizo pelo Array para trazer a posicao atual da Pendencia
			AADD( aQI5Loc,{	aQi5[nPosQi5][3],;					// Status da Acao
							aQi5[nPosQi5][4],;					// Tipo da Acao
							cMatFil,;							// Filial do Usuario
							cMatCod,;							// Matriculo do Usuario
							QA_NUSR(cMatFil,cMatCod,.F.),; 	// Nome do Usuario
							aQi5[nPosQi5][5],;					// Prazo/Vecto da Acao
							aQi5[nPosQi5][6],;					// Data Realizacao/Baixa
							aQi5[nPosQi5][8],;
							aQi5[nPosQi5][9],;
							aQi5[nPosQi5][10],;
							QI5->(Recno()),;
							aQi5[nPosQi5][11]})					// Registro para controle
		Else
			AADD( aQI5Loc,{	QI5->QI5_STATUS,;								// Status da Acao
							AllTrim(FQNCDTPACAO(QI5->QI5_TPACAO)),;		// Tipo da Acao
							QI5->QI5_FILMAT,;								// Filial do Usuario
							QI5->QI5_MAT,;									// Matriculo do Usuario
							QA_NUSR(QI5->QI5_FILMAT,QI5->QI5_MAT,.F.),; 	// Nome do Usuario
							QI5->QI5_PRAZO,;								// Prazo/Vecto da Acao
							QI5->QI5_REALIZ,;								// Data Realizacao/Baixa
							QI5->QI5_DESCRE,;
							MSMM(QI5->QI5_DESCCO,80),;
							MSMM(QI5->QI5_DESCOB,80),;
							QI5->(Recno()),;
							QI5->QI5_FILIAL	})								// Registro para controle
		Endif
	   	QI5->(dbSkip())
	Enddo
Endif

If Len(aQI5Loc) == 0
	AADD( aQI5Loc,{" "," "," "," "," ",CTOD(" / / "),CTOD(" / / ")," "," "," ",0," " })
Endif

cCadastro := OemToAnsi(STR0056)  //"Etapas/Passos do Plano de Acao"
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel

@ 00,00 MSPANEL oPane6 PROMPT "" SIZE 008,1000 OF oDlg
oPane6:Align := CONTROL_ALIGN_ALLCLIENT

@ 03, 004 LISTBOX oQI5 VAR cQI5 FIELDS HEADER 	Alltrim(TitSx3("QI5_STATUS")[1]),;
                                               	Alltrim(TitSx3("QI5_TPACAO")[1]),;
                                               	Alltrim(TitSx3("QI5_MAT")[1]),;
                                               	Alltrim(TitSx3("QI5_NUSR")[1]),;
                                               	Alltrim(TitSx3("QI5_PRAZO" )[1]),;
                                               	Alltrim(TitSx3("QI5_REALIZ" )[1]) ;
           COLSIZES 35,130,40,170,30,30 ;
           SIZE 255,68 OF oPane6 PIXEL

oQI5:SetArray(aQI5Loc)
oQI5:bLine := {||{ aStatus[Val(aQI5Loc[oQI5:nAt,1])+1],aQI5Loc[oQI5:nAt,2],aQI5Loc[oQI5:nAt,3]+"-"+aQI5Loc[oQI5:nAt,4],aQI5Loc[oQI5:nAt,5],DTOC(aQI5Loc[oQI5:nAt,6]),DTOC(aQI5Loc[oQI5:nAt,7])}}
oQI5:Align := CONTROL_ALIGN_TOP

If aMsSize[4] < 206
	@ 72,003 SAY OemToAnsi(STR0021) SIZE 120,015 COLOR CLR_BLUE FONT oFont OF oPane6 PIXEL//"Descricao Detalhada"
	@ 79,000 GET oMemo1 VAR cDescD MEMO NO VSCROLL SIZE aMsSize[5]/2,50 PIXEL OF oPane6

	@ 133,003 SAY OemToAnsi(STR0022) SIZE 120,015 COLOR CLR_BLUE FONT oFont OF oPane6 PIXEL// "Observacoes"
	@ 140,000 GET oMemo2 VAR cDescO MEMO NO VSCROLL SIZE aMsSize[5]/2,50 PIXEL OF oPane6
Else
	@ 082,004 SAY OemToAnsi(STR0021) SIZE 120,015 COLOR CLR_BLUE FONT oFont OF oPane6 PIXEL//"Descricao Detalhada"
	@ 089,000 GET oMemo1 VAR cDescD MEMO NO VSCROLL SIZE aMsSize[5]/2,80 PIXEL OF oPane6

	@ 169,004 SAY OemToAnsi(STR0022) SIZE 120,015 COLOR CLR_BLUE FONT oFont OF oPane6 PIXEL // "Observacoes" 164 171
	@ 176,000 GET oMemo2 VAR cDescO MEMO NO VSCROLL SIZE aMsSize[5]/2,85 PIXEL OF oPane6
Endif

oMemo1:bLClicked := {||AllwaysTrue()}
oMemo2:bLClicked := {||AllwaysTrue()}
oMemo1:lReadOnly := .T.
oMemo2:lReadOnly := .T.
oQI5:bChange := {|| (cDescD:=aQI5Loc[oQI5:nAt,9],;
                       cDescO:=aQI5Loc[oQI5:nAt,10],;
                       oMemo1:Refresh(),oMemo2:Refresh()) }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=2,oDlg:End()}) CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030BxOrd ³ Autor ³ Eduardo de Souza     ³ Data ³ 27/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa a pendencia pela ordem cadastrada.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030BxOrd(ExpA1,ExpN1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo as pendencias                       ³±±
±±³          ³ ExpN1 - Posicao do Array                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QN030BxOrd(aQI5,nT)
Local aArea      := ()
Local aMsg       := {}
Local aUsrMat    := QNCUSUARIO()
Local cArea      := ""
Local cCAcao     := ""
Local cChamado   := ""
Local cCODIGO    := ""
Local cCRev      := ""
Local cDescEtapa := ""
Local cFAcao     := ""
Local cMsg       := ""
Local cOrigem    := ""
Local cSeek      := ""
Local cStatus    := ""
Local cTitRep    := ""
Local cTpMail    := "1"
Local i          := 0
Local lBaixa     := .F.
Local lenvia     := .T.
Local lOK        := .T.
Local nEmpAnt    := len(cEmpAnt)
Local nFilAnt    := 0
Local nFilFun    := 0
Local x          := 0

If aQI5[nT,3] == "4"	// Item Baixado

	cFAcao := QI5->QI5_FILIAL
	cCAcao := QI5->QI5_CODIGO
	cCRev  := QI5->QI5_REV
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Permitir a obrigatoriedade ou nao de execucao de tarefa.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	If lTMKPMS
		If (GetMv("MV_QTMKPMS",.F.,1) == 3) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
			If QI5->QI5_SEQ <> Q50SEQPL(QI5->QI5_FILIAL,QI5->QI5_CODIGO,QI5->QI5_REV)
		    	aArea := GetArea()
			    IF !QAltObrigEtp(QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,.F.,,QI5->QI5_SEQ)
			    	lOK := .F.
			    Endif
				RestArea(aArea)
			Endif
		Endif
	Endif

	If lOK
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Plano de Acao no arquivo QI3			             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    QI3->(dBSetOrder(1))
		If QI3->(dbSeek(QI5->QI5_FILIAL+Right(QI5->QI5_CODIGO,4)+QI5->QI5_CODIGO+QI5->QI5_REV))
			lBaixa:= .T.
		Endif

		If lTMKPMS
			IF (GetMv("MV_QTMKPMS",.F.,1) == 2) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
			    nIndexOrd  := IndexOrd()

			    QI9->(dBSetOrder(1))
				If QI9->(dbSeek(QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV))
					dbSelectArea("QI2")
					dbSetOrder(2)
					If QI2->(MsSeek(xFilial("QI2")+QI9->QI9_FNC+QI9->QI9_CODIGO+QI9->QI9_REV))
						cArea   := QI2->QI2_DESDEP
				   		cOrigem := QI2->QI2_ORIGEM
					Endif
				Endif

				cDescEtapa := FQNCDTPACAO(QI5->QI5_TPACAO)//Descricao da etapa
				cTPACAO    := QI5->QI5_TPACAO // Tipo de acao atual
				dPRAZO     := QI5->QI5_PRAZO  // Prazo da FNC atual
				dREALIZ    := QI5->QI5_REALIZ // Dt da FNC atual
				cStatus    := ""

				nEmpAnt := len(cEmpAnt)
				nFilFun := len(cFilAnt)
				nFilAnt := len(cFilAnt)

		        If cOrigem == "TMK"
				    cCodigo:= RDZRETENT("QAA",xFilial("QAA")+QI5->QI5_MAT,"SU7",,,.T.,.F.)
			    Else
				   	cCodigo:= RDZRETENT("QAA",xFilial("QAA")+QI5->QI5_MAT,"AE8",,,.T.,.F.)
				Endif

			    dbSelectArea("QI5")
				dbSetOrder(nIndexOrd)
			Endif
	    Endif

		QI5->(DbSkip())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SO PODERA EXECUTAR/IR PARA PROXIMA ETAPA - SE O CAMPO QI5_OBRIGA ESTIVER COMO 1(OBRIGATORIO)   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If lTMKPMS
			If QI5->QI5_OBRIGA == "2" .And. Empty(QI5->QI5_PEND) //QI5->QI5_PEND <> "S" .Or.
			    cSeek:= QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV
				While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == cSeek
					If QI5->QI5_OBRIGA == "1"
						Exit
					Else
						QI5->(DbSkip())
					Endif
				EndDo
			Endif
		Endif

		If (cFAcao+cCAcao+cCRev == QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV) .And. QI5->QI5_STATUS <> "4"
			DbSelectArea("QI5")
			RecLock("QI5",.F.)
			If QI5->QI5_PEND <> "N" .or. Empty(QI5->QI5_PEND)
				QI5->QI5_PEND:= "S"
			Endif
			MsUnlock()
			FKCOMMIT()
			cStatus := QI5->QI5_TPACAO //Status da proxima acao

			If cMatFil+cMatCod <> QI5->QI5_FILMAT+QI5->QI5_MAT
				If QAA->(dbSeek(QI5->QI5_FILMAT + QI5->QI5_MAT )) .And. ;
					QAA->QAA_RECMAI == "1" .And. !Empty(QAA->QAA_EMAIL)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Nao envia e-mail para o mesmo usuario com o mesmo de Plano de Acao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cTitRep:=(OemToAnsi(STR0033)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV)
					lenvia:=.T.
					For i:=1 To Len(aUsuarios)
					 	IF aUsuarios[i,1] == QAA->QAA_LOGIN
					 	    For x:=1 To Len(aUsuarios[i,3])
					 			IF AT(cTitRep,aUsuarios[i,3,x,1]) > 0
					 	   			lenvia:=.F.
									Exit
					 	   		Endif
							Next
						Endif
						IF !lenvia
						   Exit
						Endif
					Next

					IF lenvia

						cTpMail:= QAA->QAA_TPMAIL

						// ETAPAS DO PLANO DE ACAO
						If cTpMail == "1"
							cMsg := QNCSENDMAIL(3,OemToAnsi(STR0060),.T.)	// "Existe(m) Etapa(s) para voce neste Plano de Acao para ser executado."
						Else
							cMsg := OemToAnsi(STR0028)+DtoC(QI3->QI3_ABERTU)+Space(10)+OemToAnsi(STR0029)+DtoC(QI5->QI5_PRAZO)+CHR(13)+CHR(10)	 // "Plano de Acao Iniciado em " ### " Data Prevista p/ Conclusao da Etapa: "
							cMsg += CHR(13)+CHR(10)
							cMsg += OemToAnsi(STR0030)+QI5->QI5_TPACAO+"-"+FQNCDSX5("QD",QI5->QI5_TPACAO)+CHR(13)+CHR(10)	// "Tipo Acao/Etapa: "
							cMsg += Replicate("-",80)+CHR(13)+CHR(10)
							cMsg += OemToAnsi(STR0031)+CHR(13)+CHR(10)	// "Descricao Detalhada: "
							cMsg += MSMM(QI3->QI3_PROBLE,80)+CHR(13)+CHR(10)
							cMsg += Replicate("-",80)+CHR(13)+CHR(10)
							cMsg += CHR(13)+CHR(10)
							cMsg += CHR(13)+CHR(10)
							cMsg += OemToAnsi(STR0032)+CHR(13)+CHR(10)	// "Atenciosamente "
							cMsg += QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT,.F.)+CHR(13)+CHR(10)
							cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
							cMsg += CHR(13)+CHR(10)
							cMsg += OemToAnsi(STR0036) 	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
						Endif

						cMail := AllTrim(QAA->QAA_EMAIL)
						cAttach := ""
						aMsg:={{OemToAnsi(STR0033)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach } }	// "Plano de Acao No. "

						// Geracao de Mensagem para o Responsavel da Etapa do Plano de Acao
						IF ExistBlock( "QNCEACAO" )
							aMsg := ExecBlock( "QNCEACAO", .f., .f., { OemToAnsi(STR0060) } ) // // "Existe(m) Etapa(s) para voce neste Plano de Acao para ser executado."
						Endif

						aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg} )
					EndIf
				Endif
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Baixa Plano de Acao					 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBaixa
				QN030BxPla()
			Endif
		Endif

		If Len(aUsuarios) > 0
			QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
			aUsuarios := {}
		Endif

		//Executa rotina de atualizacao no TMK
		If lTMKPMS .And. !lBaixa
			IF (GetMv("MV_QTMKPMS",.F.,1) == 2) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
				aArea := GetArea()
				If QI9->(dbSeek(QI5->QI5_FILMAT+QI5->QI5_CODIGO+QI5->QI5_REV))
				   dbSelectArea("QI2")
				   QI2->(DBSetOrder(2))
				   If QI2->(dbSeek(QI9->QI9_FILIAL+QI9->QI9_FNC+QI9->QI9_REVFNC))
				   		cChamado:= QI2->QI2_NCHAMA
				   		cArea   := QI2->QI2_DESDEP
				   Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³QI5->QI5_FILMAT    	= Filial da etapa atual					³
				//³QI5->QI5_CODIGO		= Codigo da etapa atual 				³
				//³QI5->QI5_REV 		= Revisao da etapa atual  				³
				//³cDescEtapa 			= Descricao da etapa atual  			³
				//³cTPACAO 				= Codigo da  etapa atual      		    ³
				//³cRespon				= Responsavel pela etapa atual  		³
				//³cArea				= Modulo/Depto q foi aberto a FNC  		³
				//³cStatus 				= Codigo da proxima etapa     			³
				//³dPrazo 				= Prazo da FNC atual            		³
				//³dRealiz 				= Dt da FNC atual              			³
				//³cChamado				= Numero do chamado          		    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QATUTMK(QI5->QI5_FILMAT,QI5->QI5_CODIGO,QI5->QI5_REV,cDescEtapa,cTPACAO,cCodigo,cArea,cStatus,dPrazo,dRealiz,cChamado)
				RestArea(aArea)
			Endif
		Endif
	Endif
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030BxAle ³ Autor ³ Eduardo de Souza     ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa a pendencia na ordem aleatoria/paralela.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030BxAle(ExpA1,ExpN1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo as pendencias                       ³±±
±±³          ³ ExpN1 - Posicao do Array                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QN030BxAle(aQI5,nT)
Local cCAcao     := ""
Local cCRev      := ""
Local cFAcao     := ""
Local lBxPlano   := .T.

If aQI5[nT,3] == "4"	// Item Baixado

	cFAcao := QI5->QI5_FILIAL
	cCAcao := QI5->QI5_CODIGO
	cCRev  := QI5->QI5_REV

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Plano de Acao no arquivo QI3	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QI3->(dBSetOrder(1))
	If QI3->(dbSeek(QI5->QI5_FILIAL+Right(QI5->QI5_CODIGO,4)+QI5->QI5_CODIGO+QI5->QI5_REV))

		If QI5->(DbSeek(cFAcao+cCAcao+cCRev))
			While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == cFAcao+cCAcao+cCRev
				If QI5->QI5_PEND == "S"
					lBxPlano:= .F.
					EXIT
				EndIf
				QI5->(DbSkip())
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Baixa Plano de Acao     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lBxPlano
			QN030BxPla()
		EndIf
	Endif

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030BxPla ³ Autor ³ Eduardo de Souza     ³ Data ³ 30/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa o plano de Acao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030BxPla()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Rejeite de Plano					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QN030BxPla(cRejPlan,cCodPla,cRevPla)
Local aAreaOri	 := GetArea()
Local aAreaQI3	 := {}
Local aMsg	  	 := {}
Local aUsrMat    := QNCUSUARIO()
Local cEncAutPla := AllTrim(GetMv("MV_QNEAPLA",.f.,"1"))       // Encerramento Automatico de Plano
Local cMatCod    := aUsrMat[3]
Local cMatFil    := aUsrMat[2]
Local cMensag    := ""
Local cMsg       := ""
Local cTpMail    := "1"
Local lBxPlano   := .T.
Local lExistPend := .F.
Local lQNCBXFNC  := ExistBlock( "QNCBXFNC" )
Local lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³

Default cCodPla	 := QI3->QI3_CODIGO
Default cRejPlan := ""
Default cRevPla	 := QI3->QI3_REV

dbSelectArea("QI3")
aAreaQI3 := GetArea()
dbSetOrder(2)
If !Empty(cCodPla)
	IF QI3->(dbSeek(xFilial("QI3")+cCodPla+cRevPla))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encerramento Automatico do Plano de Acao.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cEncAutPla == "1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Consistencia para nao encerrar o Plano de Acao caso existam pendencias filhas a serem executadas.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lExistPend := .T.      // independente de ter ou não Ações etapas será True.
			dbSelectArea("QI5")
			QI5->(dBSetOrder(1))
	        IF QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
	        	lExistPend := .F.   // Se tiver ações etapas muda para False sem pendencias e caso exista pendencia muda para True
				While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
					If QI5->QI5_PEND == "S"
						lExistPend := .T.
					Endif
					QI5->(dbSkip())
				Enddo
	        Endif


			If !Empty(cRejPlan)
			 	RecLock("QI3",.F.)
			 	If alltrim(cRejPlan) == "5"	//Se for uma rejeição total de plano/FNC
				 	QI3->QI3_STATUS := "4" //Nao-Procede
				 Else
					QI3->QI3_STATUS := "5" //Cancelada
				 EndIf
				QI3->(MsUnLock())
				FKCOMMIT()
			Else
				If !lExistPend
					RecLock("QI3",.F.)
					QI3->QI3_ENCREA := dDataBase
					If Empty(QI3->QI3_ENCPRE)
						QI3->QI3_ENCPRE := dDataBase
					Endif
					If QI3->QI3_STATUS < "3"
						QI3->QI3_STATUS := "3"	// 3-Procede
					Endif
					QI3->(MsUnLock())
					FKCOMMIT()
				Endif
			Endif

			If lTMKPMS
				If !Empty(cRejPlan) .Or. !lExistPend
				    If cRejPlan <> "5"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso a baixa do Plano tratar-se de um plano filho, deve se buscar na QI9³
						//³o codigo e revisão do Plano Pai para habititar/gerar a pendencia        ³
						//³da etapa pai que gerou este plano filho que esta sendo baixado, pq o    ³
						//³mesmo encontra-se sem pendencia. 									   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("QI9")
						QI9->(DBSetOrder(1))
						If QI9->(MsSeek(xFilial("QI9")+QI3->QI3_CODIGO+QI3->QI3_REV)) .AND. QI9->QI9_AGREG == "S"
							dbSelectArea("QI5")
							QI5->(DBSetOrder(1))
							IF QI5->(MsSeek( xFilial("QI5") + QI9->QI9_PLAGRE+ QI9->QI9_REVPL ))
								While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == QI9->QI9_FILIAL + QI9->QI9_PLAGRE+ QI9->QI9_REVPL
				                    If Empty(QI5->QI5_REALIZ) .And. (QI5->QI5_PEND) == "N"
				                    	RecLock("QI5",.F.)
				                    	QI5->QI5_PEND := "S"
				   						MsUnlock()
										FKCOMMIT()
			            				If QI9FindFNC(QI5->QI5_CODIGO,QI5->QI5_REV,.T.,.T.,.F.) > 0
											QNQI5xPMS({QI5->(Recno())}, QI2->QI2_FNC ,QI2->QI2_REV)
										Else
											QNQI5xPMS({QI5->(Recno())})
										EndIf
			                	    	Exit
				                    Endif
									QI5->(dbSkip())
								EndDo
							Endif
						Endif
					Endif
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Plano de Acao no arquivo QI9                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QI9->(DBSETORDER(1))
			If QI9->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
				If QI9->QI9_AGREG == "S"
					lBxPlano := .F.
				Endif
				If cEncAutPla == "1" .and. lExistPend // proteção para não fazer a baixa da FNC qdo existem pendencias.
					lBxPlano := .F.
				Endif

				If lBxPlano
					While QI9->(!Eof()) .And. QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV == QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV
			            QI2->(DBSETORDER(1))
						If QI2->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_FNC,4)+QI9->QI9_FNC+QI9->QI9_REVFNC)) .And. Empty(QI2->QI2_CONREA)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Baixa Ficha de Ocorrencia/Nao-conformidades caso Plano de Acao esteja baixado ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							RecLock("QI2",.F.)
							QI2->QI2_CONREA := dDatabase
							If Empty(QI2->QI2_CONPRE)
								QI2->QI2_CONPRE := dDataBase
							Endif
							If !Empty(cRejPlan)
								QI2->QI2_STATUS := "5"	///Ficha Cancelada/Rejeitada.
							Else
								If QI2->QI2_STATUS < "3"
									QI2->QI2_STATUS := "3" // 3-Ficha Baixada
								Endif
							EndIf

							MsUnlock()
							FKCOMMIT()

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Encerra atendimento no TMK³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							IF QI2->QI2_ORIGEM == "TMK"
			    	  			QNCbxTMK(QI2->QI2_FNC,QI2->QI2_REV) //SE ESTA BAIXADA BAIXO O ATENDIMENTO
				      		EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Avisa TMK do encerramento da FNC, caso o Plano esteja amarrado a mais de uma FNC. |                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lTMKPMS .And. Empty(QI9->QI9_PLAGRE) .And. QI9->QI9_AGREG == 'N'
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³QI5->QI5_FILMAT    	= Filial da etapa atual					³
								//³QI5->QI5_CODIGO		= Codigo da etapa atual 				³
								//³QI5->QI5_REV 		= Revisao da etapa atual  				³
								//³cDescEtapa 			= Descricao da etapa atual  			³
								//³cTPACAO 				= Codigo da  etapa atual      		    ³
								//³cRespon				= Responsavel pela etapa atual  		³
								//³cArea				= Modulo/Depto q foi aberto a FNC  		³
								//³cStatus 				= Codigo da proxima etapa     			³
								//³dPrazo 				= Prazo da FNC atual            		³
								//³dRealiz 				= Dt da FNC atual              			³
								//³cChamado				= Numero do chamado          		    ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							  //	QATUTMK(QI9->QI9_FILIAL,QI9->QI9_FNC,QI9->QI9_REVFNC,,,,,,,dDataBase,QI2->QI2_NCHAMA)
							Endif

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se ultima Etapa foi realizada para avisar Resp. Acao³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES
								If QAA->(dbSeek(QI2->QI2_FILRES + QI2->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Envio de e-Mail para o responsavel das FNC relacionadas                  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If !Empty(QAA->QAA_EMAIL) .And. !lTMKPMS

										cMail := AllTrim(QAA->QAA_EMAIL)
										cTpMail:= QAA->QAA_TPMAIL

										// ETAPAS DO PLANO DE ACAO
										If cTpMail == "1"
											cMensag := OemToAnsi(STR0037)+DtoC(QI3->QI3_ENCREA)+CHR(13)+CHR(10)	// "Este Plano de Acao foi baixado no dia "
											cMensag += OemToAnsi(STR0041) 															// "Favor verificar a Baixa da Ficha de Ocorrencia/Nao-conformidade."
											cMsg := QNCSENDMAIL(2,cMensag,.T.)
										Else
											cMsg := OemToAnsi(STR0037)+DtoC(QI3->QI3_ENCREA)+CHR(13)+CHR(10)	 // "Este Plano de Acao foi baixado no dia "
											cMsg += CHR(13)+CHR(10)
											cMsg += OemToAnsi(STR0038)+Space(1)+TransForm(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+QI2->QI2_REV+Space(1)+OemToAnsi(STR0039)+CHR(13)+CHR(10)	// "A Ficha de Ocorrencia/Nao-conformidade " ### "esta relacionada."
											cMsg += Replicate("-",80)+CHR(13)+CHR(10)
											cMsg += OemToAnsi(STR0040)+CHR(13)+CHR(10)	// "Descricao Detalhada da Ocorrencia/Nao-conformidade:"
											cMsg += CHR(13)+CHR(10)
											cMsg += MSMM(QI2->QI2_DDETA,80)+CHR(13)+CHR(10)
											cMsg += Replicate("-",80)+CHR(13)+CHR(10)
											cMsg += CHR(13)+CHR(10)
											cMsg += OemToAnsi(STR0041)+CHR(13)+CHR(10) // "Favor verificar a Baixa da Ficha de Ocorrencia/Nao-conformidade."
											cMsg += CHR(13)+CHR(10)
											cMsg += CHR(13)+CHR(10)
											cMsg += OemToAnsi(STR0032)+CHR(13)+CHR(10)	// "Atenciosamente "
											cMsg += QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT,.F.)+CHR(13)+CHR(10)
											cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
											cMsg += CHR(13)+CHR(10)
											cMsg += OemToAnsi(STR0036) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
										Endif

										cAttach := ""
										aMsg:={{OemToAnsi(STR0033)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach } }	// "Plano de Acao No. "

										// Geracao de Mensagem para o Responsavel da Ficha de Ocorrencias/Nao-conformidades
										IF lQNCBXFNC 
											aMsg := ExecBlock( "QNCBXFNC", .f., .f. )
										Endif

										aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )
									Endif
								Endif
							Endif
						Endif
						QI9->(dbSkip())
					Enddo
				Endif
			Endif
		EndIf

		dbSelectArea("QI5")
		QNCAvisa("QI3",2,QI3->(QI3_FILIAL+QI3_CODIGO+QI3->QI3_REV),"1",cMatFil,cMatCod)

	Endif
EndIF
RestArea(aAreaQI3)
RestArea(aAreaOri)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC050AnePla³ Autor ³ Eduardo de Souza    ³ Data ³ 06/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Documentos Anexos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC050AnePla()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QNC050AnePla(nPos,aQI5,aColAnx)

Local nOrdQI3:= QI3->(IndexOrd())
Private aRotina      := { { "0", "0" ,0, 1 },{ "0", "0" ,0, 2 },{ "0", "0" ,0, 3 },;
                          { "0", "0" ,0, 4 },{ "0", "0" ,0, 5 } }
QI3->(DbSetOrder(2))
If QI3->(DbSeek(aQI5[nPos,11]+aQI5[nPos,1]+aQI5[nPos,2]))
	RegToMemory("QI3",.F.)
	FQNCANEXO("QIE",4,"3",@aColAnx)
EndIf

QI3->(DbSetOrder(nOrdQI3))
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC50FNCorºAutor  ³Telso Carneiro      º Data ³  15/06/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Led das Posicao das FNC                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QNC50FNCor(cFNCRev,lLegenda)              				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cFNCRev- Chave de Pesquisa da FNC+REVISAO                   º±±
±±º          lLegenda- Valor Logico para Tela de Legenda da FNC           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  oQI2:bLine,oQI21:bLine                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QNC50FNCor(cFNCRev,lLegenda)
Local oLed := " "
Local aArea:= GetArea()
Local aAreaQI2:=QI2->(GetArea())
Local nI
Local aCores := { { 'QI2->QI2_OBSOL=="S"'     , 'BR_PRETO'},;
				{ '!Empty(QI2->QI2_CONREA)', 'BR_VERDE' },;
            	{ 'Empty(QI2->QI2_CONREA) .And. !Empty(QI2->QI2_CODACA) .And. !Empty(QI2->QI2_REVACA)', 'BR_AMARELO' },;
            	{ 'Empty(QI2->QI2_CONREA)', 'BR_VERMELHO' } }

Local aLegenda := {{'ENABLE'    , OemtoAnsi(STR0068) },;  //"Ficha Baixada"
                   {'BR_AMARELO', OemtoAnsi(STR0069) },;     //"Ficha pendente com Plano Acao"
                   {'DISABLE'   , OemtoAnsi(STR0070) },;	  //"Ficha pendente sem Plano Acao"
                   {'BR_PRETO'  , OemtoAnsi(STR0071) } }	  //"Ficha com Revisao Obsoleta"
QI2->(DbClearFilter())
IF lLegenda
	BrwLegenda(cCadastro,STR0072,aLegenda)  //"Legenda"
Else
	QI2->(DbSetOrder(2))
	IF QI2->(DbSeek(cFNCRev))
	    For nI:=1 TO Len(aCores)
	       IF &(aCores[nI,1])
	          oLed:=LoaDbitmap( GetResources(),aCores[nI,2])
	          EXIT
	       Endif
	    Next
	Else
		oLed:=LoaDbitmap( GetResources(),'BR_CINZA')
	Endif
Endif
QI2->(RestArea(aAreaQI2))
RestArea(aArea)

Return(oLed)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC50PLCorºAutor  ³Telso Carneiro      º Data ³  15/06/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Led das Posicao das Plano de Acao                          º±±
±±º			 ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QNC50PLCor(cPLNRev,lLegenda)              				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cPLNRev- Chave de Pesquisa da FNC+REVISAO                   º±±
±±º          lLegenda- Valor Logico para Tela de Legenda da Plano de Acao º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  oQI3:bLine                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QNC50PLCor(cPLNRev,lLegenda)
Local oLed := " "
Local aArea:= GetArea()
Local aAreaQI3:=QI3->(GetArea())
Local nI    := 1
Local aExeb := {}

Local aCores:={{'QI3->QI3_OBSOL=="S"'     , 'BR_PRETO'},;
					{"!Empty(QI3->QI3_ENCREA)" , 'BR_VERDE' },;
					{"Empty(QI3->QI3_ENCREA)"  , 'BR_VERMELHO'}}

Local aLegenda := { {'ENABLE' , OemtoAnsi(STR0073) },;  //"Plano de Acao Baixado"
						{'DISABLE', OemtoAnsi(STR0074) },;  //"Plano de Acao Pendente"
						{'BR_PRETO', OemtoAnsi(STR0075) } }  //"Plano de Acao Obsoleto"

IF ExistBlock( "QNC50LPLN" )
	aExeb:=ExecBlock( "QNC50LPLN", .f., .f. ,{aCores,aLegenda} )
	aCores  :=aExeb[1]
	aLegenda:=aExeb[2]
Endif

IF lLegenda
	BrwLegenda(cCadastro,STR0072,aLegenda) //"Legenda"
Else
	QI3->(DbSetOrder(2))
	IF QI3->(DbSeek(cPLNRev))
		For nI:=1 TO Len(aCores)
			IF &(aCores[nI,1])
				oLed:=LoaDbitmap( GetResources(),aCores[nI,2])
				EXIT
			Endif
		Next
	Endif
Endif
QI3->(RestArea(aAreaQI3))
RestArea(aArea)

Return(oLed)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC50FIL  ºAutor  ³Telso Carneiro      º Data ³  13/08/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Localiza o Nome da Filial para os ListBox                  º±±
±±º			 ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QNC50FIL(Filial )                          				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  oQI2:bLine;oQI21:bLine;oQI3:bLine;oQI5:bLine              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QNC50FIL(cCodFil)
local aArea   := GetArea()
Local nPosSM0 := 1
Local cFilAtu :=""

DbSelectArea("SM0")
DbSetOrder(1)
nPosSM0:= Recno()

If SM0->(DbSeek(cEmpAnt+cCodFil))
	cFilAtu := cCodFil+"-"+SM0->M0_FILIAL
Endif
SM0->(DbGoto(nPosSM0))

RestArea(aArea)

Return(cFilAtu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC50VALPEND ºAutor  ³Leandro          º Data ³  13/08/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se a pendencia possui algum plano agregado para     º±±
±±º			 ³ geracao de plano filho    								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QNC50VALPEND()                            				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMK E PMS                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNC50VALPEND()
Local lPendencia := .F.
Local lTMKPMS 	 := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local aArea		 := ()

If (ProcName(1) == "QNCA050") .Or. (ProcName(1) =="QNC050PMS")
	Private aUsrMat   := QNCUSUARIO()
	Private cMatFil   := aUsrMat[2]
	Private cMatCod   := aUsrMat[3]
	Private aRotina   := { { "0", "0" ,0, 1 },{ "0", "0" ,0, 2 },{ "0", "0" ,0, 3 },;
                          { "0", "0" ,0, 4 },{ "0", "0" ,0, 5 } }
	Private aHeadAne  := {}
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Qdo integrado c/PMS e existir tarefa gerada no PMS para a tarefa, somente pelo PMS sera possivel a manutencao na porcentagem de execucao da tarefa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKPMS
    If (GetMv("MV_QTMKPMS",.F.,1)== 3) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
		If nModulo == 36  //QNC
			DbselectArea("QI9")
			QI9->(dbSetOrder(1))
			If QI9->(MsSeek(QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV))
				DbselectArea("AF9")
				AF9->(dbSetOrder(6))
				If AF9->(MsSeek(xFilial("AF9")+QI9->QI9_FNC+QI9->QI9_REVFNC+QI5->QI5_TPACAO))
					Aviso(STR0078,STR0085+AF9->AF9_TAREFA+STR0088,{"ok"})//"Atencao"##"Manutencao nessa etapa, somente através da tarefa "###"no ambiente PMS"
					lPendencia := .T.
				Endif
			Endif
			If Empty(QI5->QI5_PROJET)
				Aviso(STR0078,STR0089+QI5->QI5_CODIGO+" - "+QI5->QI5_REV,{"ok"})//"Devido a configuração do parametro MV_QTMKPMS é necessario configurar o Projeto para encerrar essa etapa, via Plano de acao "
				lPendencia := .T.
			Endif
			If !lPendencia
				If Empty(QI5->QI5_REVISA)
					Aviso(STR0078,STR0090+QI5->QI5_CODIGO+" - "+QI5->QI5_REV,{"ok"})//"Devido a configuração do parametro MV_QTMKPMS é necessario configurar a Revisao do Projeto para encerrar essa etapa, via Plano de acao "
					lPendencia := .T.
				Endif
				If !lPendencia
					If Empty(QI5->QI5_PRJEDT)
						Aviso(STR0078,STR0091+QI5->QI5_CODIGO+" - "+QI5->QI5_REV,{"ok"})//"Devido a configuração do parametro MV_QTMKPMS é necessario configurar a EDT ref. ao Projeto para encerrar essa etapa, via Plano de acao "
						lPendencia := .T.
		            Endif
		        Endif
	        Endif
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao sobre a obrigatoriedade de inclusao de documento anexo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea := GetArea()
If !lPendencia
	If lTMKPMS
		lPendencia := QNCVldDocs(QI5->QI5_CODIGO,QI5->QI5_TPACAO,QI5->QI5_REV)///lDocsOk=.F.=Tem Pendencia
	Endif
Endif
RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a etapa possua Etapa filha, primeiramente estas deverao ser executadas , ³
//³para apos sua conclusao a etapa pai poder ser executada.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//A execucao do trecho abaixo foi comentado para atender:
//a transacao na integração PMS -> QNC onde precisa ser feita a quebra da função em:
//1. Função que valida pendencias/documentos (executada antes / fora da transação do PMS) retornando .T./.F. para permitir a baixa da tarefa PMS com 100%.
//2. Função que grava a baixa pendencia/rejeição de etapa/plano e gera a próxima tarefa. (deve ser executada dentro da transação PMS).
/*If !lPendencia
	aArea      := GetArea()
	lPendencia := QVALPLFILHO()
	RestArea(aArea)
Endif	*/

Return lPendencia


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QVALPLFILHO     ºAutor  ³Leandro       º Data ³  16/07/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se a pendencia possui plano agregado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QVALPLFILHO()                              				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMK E PMS                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QVALPLFILHO()
Local lPendencia := .F.
Local cSeek      := ""
Local nRegAnt    := 0

BEGIN TRANSACTION
If QI5->QI5_PLAGR == "1" .And. QI5->QI5_PEND == "S"
    dbSelectArea("QI9")
    dbSetOrder(1)
  	If QI9->(MsSeek(xFilial("QI9")+QI5->QI5_CODIGO+QI5->QI5_REV))
   		If QI5->QI5_AGREG == "N"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O campo QI5_AGREG controla se o plano agregado foi criado/gerado ³
			//³e deve ser alterado para "S" antes da execução do QNCGeraPlano.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		RecLock("QI5",.F.)
			QI5->QI5_AGREG	:= "S"
			MsUnlock()
			dbCommit()
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao foi criado o plano filho, portanto:                  ³
			//³Altera o status para Sim ref. a geracao do plano auxiliar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QI2")
			dbSetOrder(2)
			If QI2->(MsSeek(xFilial("QI2")+QI9->QI9_FNC+QI9->QI9_REVFNC))
				aArea := GetArea()
				QNCGeraPlano(QI9->QI9_FNC,QI9->QI9_REVFNC,QI2->QI2_DESDEP,QI5->QI5_GRAGR,,,,,,.T.,QI9->QI9_CODIGO,QI9->QI9_REV)
 				lPendencia  := .T.
 			Endif
   	    Else
		   	cSeek:= (QI9->QI9_FILIAL+QI9->QI9_FNC+QI9->QI9_REVFNC)
		   	While !Eof() .And. xFilial("QI9")+QI9->QI9_FNC+QI9->QI9_REVFNC == cSeek
				nRegAnt := Recno()
				QI9->(dbSkip()) //Para posicionar no ultimo plano relacionado a FNC PAI.
			Enddo
            //Uma vez posicionado no ultimo plano filho, encontrar a ultima etapa deste plano na QI5
            DbGoTo(nRegAnt)
            QI5->(dBSetOrder(1))
            IF QI5->(MsSeek(xFilial("QI5") + QI9->QI9_CODIGO + QI9->QI9_REV ))
				While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == QI9->QI9_FILIAL + QI9->QI9_CODIGO + QI9->QI9_REV
					If QI5->QI5_PEND == "S"
						If !Empty(QI5->QI5_GRAGR) .And. Empty(QI5->QI5_AGREG)//Etapa possui plano agregado ainda nao gerado no caso de mais de uma FNC amarrado ao mesmo Plano
							RecLock("QI5",.F.)
							QI5->QI5_AGREG	:= "S"
							MsUnlock()
							dbCommit()

							dbSelectArea("QI2")
							dbSetOrder(2)
							If QI2->(MsSeek(xFilial("QI2")+QI9->QI9_FNC+QI9->QI9_REVFNC))
								QNCGeraPlano(QI9->QI9_FNC,QI9->QI9_REVFNC,QI2->QI2_DESDEP,QI5->QI5_GRAGR,,,,,,.T.,QI9->QI9_CODIGO,QI9->QI9_REV)
			 					lPendencia := .T.
			 				Endif
							Exit
						Else
		                    lPendencia := .F.//Essa condicao foi incluida para exibir msg de pendencia qdo mais de uma FNC estiver amarrado ao mesmo Plano e ao encerrar a primeira FNC nao exiba pendencia
	                    Endif
					Endif
					QI5->(dbSkip())
				Enddo
			Else
				//Se entrar nesse else e porque ainda nao foi criado o plano filho, portanto:
		   		//Altera o status para 'Sim ref. a geracao do plano auxiliar
		   		RecLock("QI5",.F.)
				QI5->QI5_AGREG	:= "S"
				MsUnlock()
				dbCommit()

				dbSelectArea("QI2")
				dbSetOrder(2)
				If QI2->(MsSeek(xFilial("QI2")+QI9->QI9_FNC+QI9->QI9_REVFNC))
					QNCGeraPlano(QI9->QI9_FNC,QI9->QI9_REVFNC,QI2->QI2_DESDEP,QI5->QI5_GRAGR,,,,,,.T.,QI9->QI9_CODIGO,QI9->QI9_REV)
					If !IsBlind()
						Aviso(STR0078,STR0081,{"ok"})//"Atencao"##"Essa etapa nao podera ser encerrada enquanto nao for encerrado o seu plano complementar!"
 					Endif
 					lPendencia := .T.
 				Endif
			Endif
		Endif
    Endif
Endif
END TRANSACTION
Return lPendencia

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC50BXPEND  ºAutor  ³Leandro          º Data ³  23/08/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Baixar as pendencias gerada atraves da integracao do		  º±±
±±º			 ³Quality com o TMK e/ou PMS            	                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  QNC50BXPEND                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNC50BXPEND(cPlano, cRev, cEtapa, cEtapaRobo, cDESDEP, cNEWQUO, cMemo)
Local aArea      := ()
Local aAreaQI5   := {}
Local aCntsObrig := {}
Local aLista     := {}
Local aTPACAO    := {}
Local cAcao      := ""
Local cArea      := ""
Local cChamado   := ""
Local cCODIGO    := ""
Local cDescEtapa := ""
Local cETPPRX    := ""
Local cFil       := ""
Local cFNC       := ""
Local cOrigem    := ""
Local cProjet	 := ""
Local cRecurs	 := ""
Local cRespons   := ""
Local cREVFNC    := ""
Local cSeek      := ""
Local cTPACAO    := ""
Local dPrazo     := CTOD(" / / ")
Local dRealizado := CTOD(" / / ")
Local lPendencia := .F.
Local lRev       := .F.
Local lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.) //Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local nX         := 0

Default cDESDEP    := ""
Default cEtapaRobo := ""
Default cMemo      := ""
Default cNEWQUO    := ""

DbselectArea("QI5")
QI5->(dbSetOrder(4))

If QI5->(MsSeek(xFilial("QI5")+cPlano+cRev+cEtapa))

	aArea   := GetArea()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa tela para selecionar o passo/etapa que devera gerar a revisao ou reprovar/encerrar toda a FNC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cEtapaRobo)
		cAcao   := QApontaRej(QI5->QI5_TPACAO,@cDESDEP,@cNEWQUO)
		cETPPRX := cAcao
	Else
		cAcao   := cEtapaRobo
		cETPPRX := cEtapaRobo
	Endif

	If Empty(cAcao) .and. Empty(cNEWQUO)
		If !IsBlind()
			Aviso(STR0078,STR0083, {"ok"})//"Atencao"##"Processo de Rejeicao cancelado, por falta de Cadastro de Permissao entre etapa ou por cancelamento normal. "
		Endif
		lPendencia :=  .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obsoleta a revisão do plano ATUAL o qual pertence a etapa que foi rejeitado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction

	If ExistBlock("QNAGRVREJ")
		lBLKPend := ExecBlock("QNAGRVREJ",.F.,.F.,{lPendencia,QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,cAcao,cAcao=="5",cNEWQUO})
		If ValType(lBLKPend) == "L"
			lPendencia := lBLKPend
		EndIf
	Endif

	If !lPendencia
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Baixa a pendencia/etapa ATUAL rejeitada e as subsequentes PERTENCENTES AO PLANO ATUAL. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("QI5",.F.)
		QI5->QI5_PEND   := "N"
		QI5->QI5_REJEIT := "S"
		QI5->QI5_REALIZ := dDataBase
		QI5->QI5_STATUS := "5"
		MsUnlock()
		FKCOMMIT()

		cFil      := QI5->QI5_FILIAL
		cCodigo   := QI5->QI5_CODIGO
		cRev      := QI5->QI5_REV
		cTPACAO	  := QI5->QI5_TPACAO //Tipo de acao rejeitada
		dPrazo 	  := QI5->QI5_PRAZO
		dRealizado:= QI5->QI5_REALIZ
	    cRespons:=  RDZRETENT("QAA",xFilial("QAA")+QI5->QI5_MAT,"SU7",,,.T.,.F.)

	    RestArea(aArea)

		DbSelectArea("QAA")
		QAA->(dbSetOrder(1))
		QAA->(dbSeek(xFilial("QAA")+QI5->QI5_MAT))
		cProjet := QI5->QI5_PROJET
		cRecurs := QAA->QAA_RECUR

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Buscar a etapa o qual o processo de pendências deverá votlar, para gerar revisao das etapas.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QI9")
	   	QI9->(dBSetOrder(1))
		If QI9->(MsSeek(xFilial("QI9")+QI5->QI5_CODIGO+QI5->QI5_REV))

			IF !Empty(QI9_PLAGRE)
				cCodigo   := QI9->QI9_PLAGRE
				cRev      := QI9->QI9_REVPL
			Endif

			///INDICA QUE O PLANO FOI GERADO A PARTIR DE FNC

			dbSelectArea("QI2")
			dbSetOrder(2)
			If QI2->(MsSeek(xFilial("QI2")+QI9->QI9_FNC+QI9->QI9_REVFNC))	//buscando a FNC
			  	If Empty(cDESDEP)//caso nao esteja e porque foi alterado o depto destino atraves da funcao QApontaRej.
			  	 cDESDEP := QI2->QI2_DESDEP
			  	Endif
			  	cArea   := QI2->QI2_DESDEP
	  	   		cChamado:= QI2->QI2_NCHAMA
	  	  		cOrigem := QI2->QI2_ORIGEM
	  	  		cKeyQI9 := xFilial("QI9")+QI2->QI2_FNC+QI2->QI2_REV
	  	  	Else
				cKeyQI9 := xFilial("QI9")+QI9->QI9_FNC+QI9->QI9_REVFNC
				cFNC	:= QI9->QI9_FNC
				cREVFNC := QI9->QI9_REVFNC
	  	  	EndIf

			dbSelectArea("QI9")
	        QI9->(dBSetOrder(2))

			While QI9->(!Eof()) .And. QI9->QI9_FILIAL+QI9->QI9_FNC+QI9->QI9_REVFNC == cKeyQI9

				dbSelectArea("QI5")
				QI5->(dBSetOrder(4))//Criado esse indice para gerar revisao das etapas apartir da etapa encontrada na QUS.
				If cAcao == "5"
					cSeek := xFilial("QI5")+QI9->QI9_CODIGO+QI9->QI9_REV+cTPACAO
				Else
					cSeek := xFilial("QI5")+QI9->QI9_CODIGO+QI9->QI9_REV//+AllTrim(cAcao)
				Endif

				cFNC    := QI9->QI9_FNC
				cREVFNC := QI9->QI9_REVFNC

				If QI5->(MsSeek(cSeek,.F.))

					While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV
						//Eliminando todas as pendencias que estao abaixo da etapa rejeitada para em seguida recria-las atraves de uma nova revisao
						If Empty(QI5->QI5_REALIZ)   //Mesma logica para etapas paralelas
							RecLock("QI5",.F.)
							QI5->QI5_STATUS := "5"
							QI5->QI5_PEND   := "N"
							QI5->QI5_REJEIT := "S"
							QI5->QI5_REALIZ := dDataBase
							MsUnlock()
							FKCOMMIT()
						Endif
						QI5->(dbSkip())
					Enddo
			    	/// BAIXA O PLANO DE ACAO QUE SERA REVISADO POR MOTIVO "OBSOLETO"
					QNCQI3Obso(QI9->QI9_CODIGO,QI9->QI9_REV,cAcao,cMemo,cEtapa)
					If !Empty(QI9->QI9_PLAGRE)
						QNCQI3Obso(QI9->QI9_PLAGRE,QI9->QI9_REVPL,cAcao,cMemo,cEtapa)
					EndIf
				Else
					//Adicionado 22/07/08
					//Nao encontrou a etapa de rejeite no plano atual que e o filho
					//portanto deve-se localizar/encontrar no plano pai
					If ALLTRIM(cAcao) == "5"
						If QI5->(dbSeek(xFilial("QI5")+QI9->QI9_PLAGRE+QI9->QI9_REVPL+AllTrim(cAcao)))
							cCodigo   := QI5->QI5_CODIGO
							cRev      := QI5->QI5_REV
							lRev      := .T.
							While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI9->QI9_FILIAL+QI9->QI9_PLAGRE+QI9->QI9_REVPL
								//Eliminando todas as pendencias que estao abaixo da etapa rejeitada para em seguida recria-las atraves de uma nova revisao
								If Empty(QI5->QI5_REALIZ)
									RecLock("QI5",.F.)
									QI5->QI5_STATUS := "5"
									QI5->QI5_PEND   := "N"
									QI5->QI5_REJEIT := "S"
									QI5->QI5_REALIZ := dDataBase
									MsUnlock()
									FKCOMMIT()
								Endif
								QI5->(dbSkip())
							Enddo
					    	/// BAIXA O PLANO DE ACAO QUE SERA REVISADO POR MOTIVO "OBSOLETO"
							QNCQI3Obso(QI9->QI9_PLAGRE,QI9->QI9_REVPL,cAcao,cMemo,cEtapa)
						Endif
					Endif
				Endif

				dbSelectArea("QI5")
				QI5->(dBSetOrder(4))
				cSeek 	:= xFilial("QI5")+QI9->QI9_CODIGO+QI9->QI9_REV//+AllTrim(cAcao)//**
				If QI5->(MsSeek(cSeek,.F.))
					While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV
						aAreaQI5 := QI5->( GetArea() )
						DbSelectArea("QI5")
						// Obtem a lista de contatos envolvidos na tarefa
						If QI5->QI5_SEQ <= Q50SEQPL(QI5->QI5_FILIAL,QI5->QI5_CODIGO,QI5->QI5_REV)
							aAreaQAA := QAA->( GetArea() )
							DbSelectArea( "QAA" )
							QAA->( DbSetOrder( 1 ) )
							If QAA->( DbSeek( xFilial( "QAA" ) + QI5->QI5_MAT ) )
								DbSelectArea( "AE8" )
								AE8->( DbSetOrder( 1 ) )
								If AE8->( DbSeek( xFilial( "AE8" ) + QAA->QAA_RECUR ) )
									If aScan( aLista, { |x| x[2] == AllTrim( Lower( AE8->AE8_EMAIL ) ) } ) == 0
										aAdd( aLista, { AE8->AE8_DESCRI, AllTrim( Lower( AE8->AE8_EMAIL ) ) } )
									EndIf
								EndIf
							EndIf
							RestArea( aAreaQAA )
						EndIf
						RestArea(aAreaQI5)
						QI5->(dbSkip())
					End
				EndIf

				QI9->(dbSkip())
			Enddo

			// Realiza a notificacao da rejeicao
			// QNC50EML: Ponto de entrada para customizar a lita de contatos
			If ExistBlock( "QNC50EML" )
				aLista := ExecBlock( "QNC50EML", .F., .F., { aLista, cEtapa } )
			EndIf

			aCntsObrig := aClone(aLista)
			cStrEnvio := PmsSlEmail( aLista, aCntsObrig )

			If !Empty( cStrEnvio )
				cMsg	:= "Notificação de Evento - Rejeição de Tarefa" + chr(13) + chr(10)
				cMsg	+= "Projeto: " + AF9->AF9_PROJET + chr(13) + chr(10)
				cMsg	+= "Tarefa: " + AllTrim( AF9->AF9_TAREFA ) + "-" + AllTrim( AF9->AF9_DESCRI ) + chr(13) + chr(10)

				// PmsMonEml: Ponto de entrada para customizar o texto do email
				If ExistBlock( "PmsMonEml" )
					cMsg := ExecBlock( "PmsMonEml", .F., .F., { cMsg } )
				EndIf

				PMSSendMail(	"Notificação de Evento - Rejeição de Tarefa",;			// Assunto
								cMsg,;													// Mensagem
								cStrEnvio,;												// Destinatario
								"",;													// Destinatario - Copia
								.F. )													// Se requer dominio na autenticacao
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rejeicao completa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ALLTRIM(cAcao) == "5"
				QN030BxPla("5")
				//Cancelando o Plano Pai, inclusive a FNC
				If !Empty(cCodigo)
					QNCQI3Obso(cCodigo,cRev,"5",cMemo,cEtapa)
	       			QN030BxPla("5",cCodigo,cRev)
	       		Endif

				//****** Avisando o TMK que a etapa foi rejeitada ******
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³QI5->QI5_FILMAT  = Filial da etapa atual				³
				//³QI5->QI5_CODIGO  = Codigo da etapa atual 			³
				//³QI5->QI5_REV     = Revisao da etapa atual  			³
				//³cDescEtapa 		= Descricao da etapa atual  		³
				//³cTPACAO 			= Codigo da  etapa atual        	³
				//³cRespon			= Responsavel pela etapa atual  	³
				//³cArea			= Modulo/Depto q foi aberto a FNC  	³
				//³cStatus 			= Codigo da proxima etapa      		³
				//³dPrazo 			= Prazo da FNC atual            	³
				//³dRealiz 			= Dt da FNC atual              		³
				//³cChamado 		= Numero do chamado           		³
				//³aIncEtp	 		= Etapas Prls Inconsistente    		³
				//³cMemo	 		= Memo da Rejeicao		    		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTMKPMS
					If (GetMv("MV_QTMKPMS",.F.,1) == 2) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
						cDescEtapa := Posicione('QID',1,xFilial('QI5')+cTPACAO,'QID_DESCTP')
						QATUTMK(cFil,cCodigo,cRev,cDescEtapa,cTPACAO,cRespons,cArea,"5",dPrazo,dRealizado,cChamado,,cMemo)
					Endif
				Endif
			Else
				aArea := GetArea()
				If !IsBlind()
					MsgRun(STR0079,STR0078,{||QNCGeraPlano(cFNC,cREVFNC,cDESDEP,cNEWQUO,cCODIGO,cREV,cETPPRX,cTPACAO,lRev)})//"Gerando Revisao do Plano"##"Atencao"
				Else
					QNCGeraPlano(cFNC,cREVFNC,cDESDEP,cNEWQUO,cCODIGO,cREV,cETPPRX,cTPACAO,lRev)//"Gerando Revisao do Plano"##"Atencao"
				Endif
			    RestArea(aArea)
				dbSelectArea("QI9")
				dbSetOrder(2)
		  		If QI9->(MsSeek(xFilial("QI9")+cFNC+cREVFNC))
					dbSelectArea("QI5")
					dbSetOrder(1)
		            IF QI5->(MsSeek(QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV))
						aArea      := GetArea()
						lPendencia := QVALPLFILHO()
					    RestArea(aArea)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso a etapa possua Etapa filha, primeiramente estas deverao ser executadas , ³
						//³para apos sua conclusao a etapa pai poder ser executada.                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    IF lPendencia
					    	RecLock("QI5",.F.)
						    QI5->QI5_PEND := "N"
							MsUnlock()
							dbCommit()
						Endif
					Endif
				Endif
			Endif
	    Else
	    	///PLANO CADASTRADO MANUALMENTE SEM FNC.
	    	/// BAIXA O PLANO DE ACAO QUE SERÁ REVISADO COM MOTIVO "OBSOLETO"
			QNCQI3Obso(QI5->QI5_CODIGO,QI5->QI5_REV,,,cEtapa)
			/// Plano de ação manual, sem FNC de origem, fazendo integração com PMS (ou não).
			If (ALLTRIM(cAcao) <> "5") .Or. (ProcName(1) <> "QNCA050")   //AQUI LEANDRO
				If !IsBlind()
					MsgRun(STR0079,STR0078,{||QNCGeraPlano("","",/*cDESDEP*/,cNEWQUO,cCODIGO,cREV,cETPPRX,cTPACAO,		,		,		,)})//"Gerando Revisao do Plano"##"Atencao"
				Else
				   	QNCGeraPlano("" ,""	 ,/*cDESDEP*/,cNEWQUO	,cCODIGO,cREV		,cETPPRX,cTPACAO,		,		,		,	)//"Gerando Revisao do Plano"##"Atencao"
				Endif
			EndIf
	    Endif
			// Localiza o evento de notificacao do projeto
			DbSelectArea("AN6")
			AN6->( DbSetOrder(1) )
			AN6->( DbSeek( xFilial("AN6") + cProjet + "000000000000003" ) )
			Do While !AN6->(Eof()) .And. xFilial("AN6") + QI5->QI5_PROJET == AN6->( AN6_FILIAL + AN6_PROJET ) .And. AN6->AN6_EVENT == "000000000000003"
				// Se o campo funcao de usuario estiver preenchido deve Macroexecutar
				If !Empty( AN6->AN6_USRFUN )
					&(AN6->AN6_USRFUN)
				EndIf

				// Obtem o assunto da notificacao
				cAssunto := "Notificação de Evento - Rejeicao de Plano de Acao" // "Notificação de Evento - Rejeicao de Plano de Acao"
				If !Empty( AN6->AN6_ASSUNT )
					cAssunto := AN6->AN6_ASSUNT
				EndIf

				// macro executa para obter o titulo
				If Left( AllTrim( AN6->AN6_ASSUNT ), 1 ) = "="
					cAssunto := Right( cAssunto, Len( cAssunto ) -1 )
					cAssunto := &(cAssunto)
				EndIf

				// Obtem o destinatario
				cTo	:= PASeekPara( cRecurs, AN6->AN6_PARA )
				cCC	:= PASeekPara( cRecurs, AN6->AN6_COPIA )

				// Cria a mensagem
				cMsg := AN6->AN6_MSG

				// macro executa para obter a mensagem
				If Left( AllTrim( AN6->AN6_MSG ), 1 ) = "="
					cMsg := Right( cMsg, Len( cMsg ) -1 )
					cMsg := &(cMsg)
				EndIf

		        //Deve ser gerada uma notificação de evento do projeto encaminhando um e-mail para o superior do recurso;
				If !Empty( cTO )
					PMSSendMail(	cAssunto,; 						// Assunto
									cMsg,;							// Mensagem
									cTO,;							// Destinatario
									cCC,;							// Destinatario - Copia
									.T. )							// Se requer dominio na autenticacao
				EndIf

				AN6->( DbSkip() )

			EndDo
	Endif
	End Transaction
Endif

If lTMKPMS

	If (GetMv("MV_QTMKPMS") == 4)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao que Retorna as Etapas Paralelas juntamento com a Etapa Pai	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTPACAO	:= PMSQNCEtp(cPlano,cRev,cEtapa)

		If Len(aTPACAO) > 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico a Posição da Etapa Atual e Retira do Array					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//nPos:= aScan(aTPACAO,cEtapa)
			nPos := aScan(aTPACAO, { |x| AllTrim(x[1]) = AllTrim(cEtapa) })
			aDel(aTPACAO,nPos)
			aSize(aTPACAO,Len(aTPACAO)-1)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao que Envia E-mail das Etapas Paralelas 						   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    For nX := 1 To Len(aTPACAO)
		    	QNCPMSPrl(cPlano,cRev,aTPACAO[nX][1],cEtapa)
		    Next

		EndIf

	EndIf

EndIf

Return lPendencia

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q50BXTMKPMS³ Autor ³ Leandro de Souza     ³ Data ³ 23/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa a pendencia pela ordem cadastrada.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q50BXTMKPMS                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Filial                    						  ³±±
±±³          ³ ExpN2 = Codigo do Plano                                    ³±±
±±³          ³ ExpN3 = Codigo da Revisao do Plano                         ³±±
±±³          ³ ExpN4 = Etapa                                              ³±±
±±³          ³ ExpN5 = Alterna a obrigatoriedade de execucao de tarefa.   ³±±
±±³          ³ ExpN6 = Status da QI5 antes de cancelamento de execucao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q50BXTMKPMS(cFILIAL,cCODIGO,cREV,cEtapa,cHabilita,nStatusQI5,cMemo)

Local aArea       := ()
Local aIncEtp     := {}
LocaL aTPACAO     := {}
Local cArea       := ""
Local cCAcao      := ""
Local cCRev       := ""
Local cDescEtapa  := ""
Local cFAcao      := ""
Local cObservacao := ""
Local cOrigem     := ""
Local cRespon     := ""
Local cSeek       := ""
Local cSequencia  := 1
Local cStatus     := ""
Local cTPACAO     := QI5->QI5_TPACAO
Local dPRAZO      := CTOD(" / / ")
Local dREALIZ     := CTOD(" / / ")
Local lBaixa      := .F.
Local lEtpCompl   := .F.
Local lOK         := .T.
Local lParalela   := .F.
Local lRet        := .F.
Local lTMKPMS     := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.) //Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local nEmpAnt     := len(cEmpAnt)
Local nFilAnt     := 0
Local nFilFun     := 0
Local nIndexOrd   := 1
Local nX          := 0

Default cHabilita  := .T.
Default cMemo      := ""
Default nStatusQI5 := 0

aArea2 := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao que Retorna as Etapas Paralelas juntamento com a Etapa Pai	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTPACAO	:= PMSQNCEtp(cCODIGO,cREV,cEtapa)

If Len(aTPACAO) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao que Retorna as Inconsistência da Etapas Paralelas caso existam	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//³ 1-Plano/Revisão															³
	//³ 2-Etapa																	³
	//³ 3-Filial Responsavel													³
	//³ 4-Codigo Responsavel													³
	//³ 5-Departamento 															³
	//³ 6-Previsão SLA															³
	//³ 7-Motivo																³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aIncEtp := PMSQNCInc(cCODIGO,cREV,aTPACAO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tem Etapa Paralela e NÃO existem Inconsistências, gero a Tarefa com a Ultima Etapa	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aTPACAO) > 0 .And. Len(aIncEtp) == 0
		lEtpCompl := .T.
		lParalela := .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tem Etapa Paralela e Existem Inconsistências, NÃO gero a Tarefa com a Ultima Etapa	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aTPACAO) > 0 .And. Len(aIncEtp) > 0
		cStatus   := cEtapa
		lEtpCompl := .F.
		lParalela := .T.
	EndIf

	If Len(aIncEtp) > 0

		For nX := 1 To Len(aIncEtp)
			cAviso := STR0093 + aIncEtp[nX][1]												//"Plano/Revisão: "
			cAviso += CRLF+STR0094+FQNCDTPACAO(aIncEtp[nX][2])                              //"Etapa: "
			cAviso += CRLF+STR0095+QA_NUSR(aIncEtp[nX][3],aIncEtp[nX][4],.F.)               //"Recurso Alocado: "
			cAviso += CRLF+STR0096+aIncEtp[nX][5]                                  			//"Departamento: "
			cAviso += CRLF+STR0097+aIncEtp[nX][6]                                           //"Previsão SLA: "
			cAviso += CRLF+STR0098+ aIncEtp[nX][7]                                          //"Motivo: "
			cAviso += CRLF+STR0099+ STR0100              									//"Solução: " ### "Finalizar Todas as Etapas Paralelas!"
			Aviso(STR0101,cAviso,{"OK"},3,STR0102)              							//"Tarefas Paralelas" ###"Tarefas Paralelas Não Finalizadas"
		Next

	EndIf

EndIf

RestArea(aArea2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a etapa possua Etapa filha, primeiramente estas deverao ser executadas , ³
//³para apos sua conclusao a etapa pai poder ser executada.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//A execucao do trecho abaixo foi acrescentado para atender:
//a transacao na integração PMS -> QNC onde precisa ser feita a quebra da função em:
//1. Função que valida pendencias/documentos (executada antes / fora da transação do PMS) retornando .T./.F. para permitir a baixa da tarefa PMS com 100%.
//2. Função que grava a baixa pendencia/rejeição de etapa/plano e gera a próxima tarefa. (deve ser executada dentro da transação PMS).
aArea      := GetArea()
lPendencia := QVALPLFILHO()
RestArea(aArea)

If !lPendencia
	cFAcao  := QI5->QI5_FILIAL
	cCAcao  := QI5->QI5_CODIGO
	cCRev   := QI5->QI5_REV
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Plano de Acao no arquivo QI3			             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QI3->(dBSetOrder(2))
	If QI3->(MsSeek(QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV,.F.))
		lBaixa:= .T.
	Endif

	If lTMKPMS
		If (GetMv("MV_QTMKPMS",.F.,1) == 2) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
		    nIndexOrd  := IndexOrd()

		    QI9->(dBSetOrder(1))
			If QI9->(MsSeek(QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV))
				dbSelectArea("QI2")
				dbSetOrder(2)
				If QI2->(MsSeek(QI9->QI9_FILIAL+QI9->QI9_FNC))//Retirado revisao para considerar a primeira revisao
					cArea   := QI2->QI2_DESDEP
			   		cOrigem := QI2->QI2_ORIGEM
				Endif
			Endif

			cDescEtapa := FQNCDTPACAO(QI5->QI5_TPACAO)//Descricao da etapa
			cTPACAO    := QI5->QI5_TPACAO // Tipo de acao atual
			dPRAZO     := QI5->QI5_PRAZO  // Prazo da FNC atual
			dREALIZ    := QI5->QI5_REALIZ // Dt da FNC atual
			cStatus    := ""
			If GetMv("MV_QTMKPMS",.F.,1) == 2 .And. Empty(QI5->QI5_OBRIGA)
				QI5->QI5_OBRIGA   := "1"
			Endif
			nEmpAnt := len(cEmpAnt)
			nFilFun := len(cFilAnt)
			nFilAnt := len(cFilAnt)

		    If cOrigem == "TMK"
	            cRespon:= RDZRETENT("QAA",xFilial("QAA")+QI5->QI5_MAT,"SU7",,,.T.,.F.)
		    Else
			   	cRespon:= RDZRETENT("QAA",xFilial("QAA")+QI5->QI5_MAT,"AE8",,,.T.,.F.)
			Endif

		    If lParalela
				cRespon:= RDZRETENT("QAA",xFilial("QAA")+QI5->QI5_MAT,"AE8",,,.T.,.F.)
			EndIf

			dbSetOrder(nIndexOrd)
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O codigo abaixo foi inserido para baixar a pendência atual e como essa funcao e chamada³
	//³pelo PMS somente qdo efetuar 100 da etapa foi atribuido QI5_STATUS recebendo 4         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN TRANSACTION
		DbSelectArea("QI5")
		QI5->(dBSetOrder(4))
		IF QI5->(MsSeek(cFILIAL+cCODIGO+cREV+cEtapa))
			RecLock("QI5",.F.)
			QI5->QI5_REALIZ := dDataBase
			QI5->QI5_STATUS := "4"
			QI5->QI5_PEND   := "N"
			If !Empty(cMemo)
				cObservacao:= iIf( !Empty(QI5->QI5_DESCRE) ,QI5->QI5_DESCRE+CRLF,"")
				cObservacao+= cMemo
				MSMM(QI5_DESCCO,,,cObservacao,1,,,"QI5","QI5_DESCCO")
			Endif
			MsUnLock()
			FKCOMMIT()
		Else
			lRet := .T.
		Endif

		cSequencia := AllTrim(QI5->QI5_SEQ)

		//Reposicionamento na QI5 atraves da sequencia para nao gerar pendencia fora da sequencia
		dbSelectArea("QI5")
		QI5->(dBSetOrder(1))
		QI5->(MsSeek(cFILIAL+cCODIGO+cREV)) //QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_SEQ
		cSeek:= QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV
		cChave:=' '
		While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == cSeek
			cChave := QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV
			If Empty(QI5->QI5_PEND)
				Exit
			Else
				QI5->(DbSkip())
			Endif
		EndDo

//		cChave := QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se For Etapa Paralela Não pode dar o DbSkip() para não desposicionar a QI5	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lParalela
			If  !Empty(QI5->QI5_CODIGO).And. !Empty(QI5->QI5_REV) .And.GetMv("MV_QTMKPMS") == 2 .And. Empty(QI5->QI5_OBRIGA)
				RecLock("QI5",.F.)
					QI5->QI5_OBRIGA   := "1"
				MsUnLock()
				FKCOMMIT()
			Endif

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Permitir a obrigatoriedade ou nao de execucao de tarefa.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTMKPMS .And. cHabilita .And. !lParalela //SKIP
			If cChave == QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV
				If QI5->QI5_SEQ <> Q50SEQPL(QI5->QI5_FILIAL,QI5->QI5_CODIGO,QI5->QI5_REV)
				    aArea := GetArea()
					If !IsBlind()
			    		If !QAltObrigEtp(QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,.F.,,cSequencia)
			    			lOK := .F.
			    		Endif
			    	Endif
					RestArea(aArea)
				Endif
			Endif
		Endif

		IF lOK
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SO PODERA EXECUTAR/IR PARA PROXIMA ETAPA - SE O CAMPO QI5_OBRIGA ESTIVER COMO 1(OBRIGATORIO)   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTMKPMS
				If QI5->QI5_OBRIGA == "2" .Or. Empty(QI5->QI5_PEND) .And. !lParalela
					While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == cSeek
						If QI5->QI5_OBRIGA == "1" .AND. Empty(QI5->QI5_PEND)
							Exit
						Else
							QI5->(DbSkip())
						Endif
					EndDo
				Endif
			Endif

			If (cFAcao+cCAcao+cCRev == QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV) .And. Empty(QI5->QI5_REALIZ) .And. !lParalela  //SKIP
				DbSelectArea("QI5")//SKIP
				RecLock("QI5",.F.)
				If QI5->QI5_PEND <> "N" .or. Empty(QI5->QI5_PEND)
					QI5->QI5_PEND:= "S"
				Endif
				MsUnlock()
				FKCOMMIT()

				cStatus := QI5->QI5_TPACAO //Status da proxima acao //SKIP

				aArea      := GetArea()
				lPendencia := QVALPLFILHO()
				RestArea(aArea)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso a etapa possua Etapa filha, primeiramente estas deverao ser executadas , ³
				//³para apos sua conclusao a etapa pai poder ser executada.                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				IF lPendencia
				  	RecLock("QI5",.F.)
				    QI5->QI5_PEND := "N"
					MsUnlock()
					dbCommit()
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gerando tarefa no PMS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTMKPMS  .And. !lPendencia

					If QI9FindFNC(QI5->QI5_CODIGO,QI5->QI5_REV,.T.,.T.,.T.) > 0
						QNQI5xPMS({QI5->(Recno())},QI2->QI2_FNC ,QI2->QI2_REV)  //SKIP
					Else
						If GetMv("MV_QTMKPMS",.F.,1) == 3
							QNQI5xPMS({QI5->(Recno())},M->QI2_FNC ,M->QI2_REV) //SKIP
						Else
							QNQI5xPMS({QI5->(Recno())})	//SKIP
						Endif
					EndIf
				Endif

			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Baixa Plano de Acao					 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lBaixa  .And. !lParalela
					If lTMKPMS
						dbSelectArea("QI5")
						QI5->(DBSetOrder(1))
						IF QI5->(MsSeek( xFilial("QI5")+cCAcao+cCRev ))
						 	cSeek := QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV
							While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == cSeek
			                    If Empty(QI5->QI5_REALIZ) .And. QI5->QI5_STATUS <> "4" .And. QI5->QI5_OBRIGA <> "2"
			           				lBaixa := .F.//Pq ainda existe etapa pendente e o plano nao podera ser baixado
			           	        Endif
								QI5->(dbSkip())
							EndDo
						Endif
					Endif

		            If lBaixa
						QN030BxPla(,cCAcao,cCRev)	///Baixa o plano (encerramento normal, sem rejeição).
					Endif
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se tem Etapa Paralela e as Tarefas estão Completas, Gero Tarefa posicionando na QI5 com a Ultima Etapa Paralela  ³
			// para assim dar o Skip na próxima tarefa e Gravar como Pendente Sim												³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lEtpCompl
				QI5->(dBSetOrder(1))
		   		QI5->(MsSeek(cFILIAL+cCODIGO+cREV)) //QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_SEQ
				cSeek:= QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV

				While QI5->(!Eof()) .And. QI5->QI5_FILIAL == xFilial("QI5") .And. AllTrim(QI5->QI5_CODIGO) == AllTrim(cCAcao) .And.;
									AllTrim(QI5->QI5_REV) == AllTrim(cRev)
					If QI5->QI5_OBRIGA == "1" .AND. Empty(QI5->QI5_PEND)
						Exit
					Else
						QI5->(DbSkip())
					Endif
				EndDo

			    cStatus := QI5->QI5_TPACAO     //Status da proxima acao

			    If (cFAcao+cCAcao+cCRev == QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV) .And. Empty(QI5->QI5_REALIZ)
					DbSelectArea("QI5")
					RecLock("QI5",.F.)
					If QI5->QI5_PEND <> "N" .or. Empty(QI5->QI5_PEND)
						QI5->QI5_PEND:= "S"
					Endif
					MsUnlock()
					FKCOMMIT()
			    EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gerando tarefa no PMS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTMKPMS  .And. !lPendencia

					If QI9FindFNC(QI5->QI5_CODIGO,QI5->QI5_REV,.T.,.T.,.T.) > 0
 						QNQI5xPMS({QI5->(Recno())},QI2->QI2_FNC ,QI2->QI2_REV,@lRet)  //SKIP
					Else
						If GetMv("MV_QTMKPMS") == 3
							QNQI5xPMS({QI5->(Recno())},M->QI2_FNC ,M->QI2_REV,@lRet) //SKIP
						Else
							QNQI5xPMS({QI5->(Recno())})	//SKIP
						Endif
					EndIf
				Endif

			EndIf

			//Executa rotina de atualizacao no TMK
			If lTMKPMS
				If (GetMv("MV_QTMKPMS",.F.,1) == 2) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
					aArea := GetArea()
					dbSelectArea("QI9")
					QI9->(DBSetOrder(1))
					cSeek := ""
					If !Empty(QI5->QI5_CODIGO)
						If Alltrim(QI5->QI5_CODIGO) == Alltrim(cCODIGO)
							cSeek:= QI5->QI5_CODIGO+QI5->QI5_REV
						Else
							cSeek:= cCODIGO+cREV
						Endif
					Else
						cSeek:= cCODIGO+cREV
					Endif

					If QI9->(MsSeek(xFilial("QI9")+cSeek))
					   dbSelectArea("QI2")
					   QI2->(DBSetOrder(2))
					   If QI2->(MsSeek(xFilial("QI2")+QI9->QI9_FNC+QI9->QI9_REVFNC)) .and. !Empty(QI2->QI2_NCHAMA)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ 1- QI5->QI5_FILMAT    	= Filial da etapa atual				³
							//³ 2- QI5->QI5_CODIGO		= Codigo da etapa atual 			³
							//³ 3- QI5->QI5_REV 		= Revisao da etapa atual  			³
							//³ 4- cDescEtapa 			= Descricao da etapa atual  		³
							//³ 5- cTPACAO 				= Codigo da  etapa atual      		³
							//³ 6- cRespon				= Responsavel pela etapa atual  	³
							//³ 7- cArea				= Modulo/Depto q foi aberto a FNC  	³
							//³ 8- cStatus 				= Codigo da proxima etapa     		³
							//³ 9- dPrazo 				= Prazo da FNC atual            	³
							//³10- dRealiz 				= Dt da FNC atual              		³
							//³11- cChamado				= Numero do chamado          		³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If GetMv("MV_QTMKPMS",.F.,1) == 2
								QATUTMK(xFilial("QI5"),cCodigo,cRev,cDescEtapa,cTPACAO,cRespon,QI2->QI2_DESDEP,cStatus,dPrazo,dRealiz,QI2->QI2_NCHAMA,aIncEtp)
							Else
								If !Empty(cStatus)
									cMemo := STR0094 +cEtapa + " - " + AllTrim(Posicione("QID",1,xFilial("QID")+cEtapa,"QID_DESCTP")) +CRLF +cMemo
								EndIf
								QATUTMK(QI5->QI5_FILMAT,QI5->QI5_CODIGO,QI5->QI5_REV,cDescEtapa,cTPACAO,cRespon,QI2->QI2_DESDEP,cStatus,dPrazo,dRealiz,QI2->QI2_NCHAMA,aIncEtp,cMemo)
				            Endif
						EndIf
					Endif
					RestArea(aArea)
				Endif
			Endif

			If ExistBlock("QGRVBXETP")//Ponto de entrada para carregar
				ExecBlock("QGRVBXETP",.F.,.F., {cCodigo,cRev,cEtapa,lRet,cStatus} )
			EndIf
		Endif

		if ! lOK  //Operacao cancelada e retorna os status anteriores
			dbSelectArea("QI5")
			QI5->(dBSetOrder(4))
			IF QI5->(MsSeek(cFILIAL+cCODIGO+cREV+cEtapa))
				RecLock("QI5",.F.)
				QI5->QI5_REALIZ := CTOD("  /  /  ")
				QI5->QI5_STATUS := nStatusQI5
				QI5->QI5_PEND   := "S"
				MsUnLock()
				FKCOMMIT()
			Endif
		Endif
	END TRANSACTION
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q50SEQPL   ³ Autor ³ Leandro de Souza     ³ Data ³ 26/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima sequencia do plano 		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q50SEQPL                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Filial                    						  ³±±
±±³          ³ ExpN2 = Codigo do Plano                                    ³±±
±±³          ³ ExpN3 = Codigo da Revisao do Plano                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q50SEQPL(cFil,cCODIGO,cREV)
Local cSeq  := "0"
Local aArea := GetArea()

dbSelectArea("QI5")
QI5->(dBSetOrder(1))
IF QI5->(MsSeek(cFil+cCODIGO+cREV))
	cSeq := QI5->QI5_SEQ
	While !Eof() .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == cFil+cCODIGO+cREV
		cSeq := QI5->QI5_SEQ
		QI5->(DbSkip())
	Enddo
Endif

RestArea(aArea)

Return cSeq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCA050   ºAutor  ³Microsiga           º Data ³  07/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para validar os documentos obrigatórios da etapa de  º±±
±±º          ³um plano de ação, permite amarrar caso estejam faltando.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCVldDocs(cPlano,cEtapa,cRevPlan,lAsk1st)

Local lDocsOk 	 := .F.
Local aAreaOri	 := {}
Local cFilQUT	 := ""
Local nOpcX		 := 0
Local nFirstQUT  := 0
Local aColsQIE   := {}
Local cDescEtapa := ""
Local cDescDoc   := ""
Private aHeadAne  := {}

DEFAULT cRevPlan := "00"
DEFAULT lAsk1st	 := .T.		///Ask1st = .T. = Uso no "VALID" 100% de tarefa. / .F. = Uso no botão PMS.

If !Empty(cPlano) .and. !Empty(cEtapa)
	dbSelectArea("QUT")
	aAreaOri := GetArea()
	cFilQUT := xFilial("QUT")
	dbSetOrder(1)
	If QUT->( MsSeek(cFilQUT+cEtapa,.F.))
		nFirstQUT := QUT->(Recno())
		While QUT->(!Eof()) .and. QUT->QUT_FILIAL == cFilQUT .and. QUT->QUT_ETAPA == cEtapa .and. !lDocsOk
			If QUT->QUT_OBRIGA == "1"
			    dbSelectArea("QIE")
			    QIE->(dBSetOrder(3))
				If !QIE->(MsSeek(xFilial("QIE")+cPlano+cRevPlan+cEtapa+QUT->QUT_TIPODC,.F.)) .or. Empty(QIE->QIE_ANEXO)
					lDocsOk := .F.
					If !IsBlind()
						If lAsk1st
	                        cDescEtapa := Posicione('QID',1,xfilial('QID')+QUT->QUT_ETAPA,'QID_DESCTP')
	                        cDescDoc   := Posicione('QUU',1,xFilial('QUU')+QUT->QUT_TIPODC,'QUU_DESCDO')
							nOpcX := Aviso(STR0078,"Não foi associado o documento "+ cDescDoc+" que é obrigatório para a etapa "+cDescEtapa+CRLF+;//cEtapa
							"Deseja anexar os documentos agora ?",{"Sim","Nao"})//"Atencao"##"Nao foi cadastrado o Documento obrigatorio referente a esta etapa no Plano de Acao !!"
						Else
							nOpcX := 1
						EndIf
					EndIf

					If !IsBlind()
						If nOpcX == 1
							QI3->(DbSetOrder(2))
							If QI3->(MsSeek(xFilial("QI3")+cPlano+cRevPlan,.F.))
								aColsQIE   := FQNCANEXO("QIE",4,"3")
								cAliasAnex := "QIE"
								If !Empty(aColsQIE)
									If !Empty(aColsQIE[1][8]) .Or. !Empty(aColsQIE[1][9]) .Or. !Empty(aColsQIE[1][11])
										QNCGvAnexo(3,aColsQIE)
									Endif
									lDocsOk := .F.
								Else
									lDocsOk := .T.
								Endif
								QUT->(MsGoto(nFirstQUT))	///VOLTA PARA O PRIMEIRO DOCUMENTO AMARRADO À ETAPA (VAI VALIDAR TUDO NOVAMENTE)
							Endif
						Else
							MsgAlert(STR0092)
							lDocsOk := .T.
							Exit
						EndIf
					Else
						Exit
					lDocsOk := .F.	///Rotina automática apenas retorna .F. SE FALTAREM DOCS. s/ validacao de amarracao
					EndIf
				Else
					MsgAlert("Documento já incluído","Atenção")
					QUT->(dbSkip())
				Endif
			Else
				QUT->(dbSkip())
			Endif

			If QUT->(Eof()) .or. QUT->QUT_FILIAL <> cFilQUT .or. QUT->QUT_ETAPA <> cEtapa
				Exit
			EndIf
		EndDo
	Else
		lDocsOk := .F.
	Endif

	RestArea(aAreaOri)
Else
	lDocsOk := .F.
EndIf

Return(lDocsOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCA050   ºAutor  ³Microsiga           º Data ³  07/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCQI3Obso(cPlano,cRevPlan,cAcao,cMemo,cAcaoOrig)
Local cObservacao   := ""
Local lTMKPMS 		 := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)

Default cAcao := "5"
Default cMemo := ""
Default cAcaoOrig := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obsoleta a revisão do plano o qual pertence a etapa que foi rejeitado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAcao := Alltrim(cAcao)
dbSelectArea("QI3")
QI3->(dBSetOrder(2))
If QI3->(MsSeek(xFilial("QI3")+cPlano+cRevPlan,.F.)) .and. Empty(QI3->QI3_ENCREA)
	RecLock("QI3",.F.)
	QI3->QI3_ENCREA := dDataBase
	If Empty(QI3->QI3_ENCPRE)
		QI3->QI3_ENCPRE := dDataBase
	Endif
	If cAcao <> "5" //Acao rejeitada
		QI3->QI3_OBSOL  := "N"
		If QI3->QI3_STATUS < "3"
			QI3->QI3_STATUS := "3"
		Endif
	Else
		QI3->QI3_STATUS := "4"
		QI3->QI3_OBSOL  := "S"
	Endif
    If !Empty(cMemo)
	    cObservacao:= MSMM(QI3->QI3_PROBLE,80)
	    If !lTMKPMS
	    	cObservacao+= CRLF+cMemo
	    Endif
		MSMM(QI3_PROBLE,,,cObservacao,1,,,"QI3","QI3_PROBLE")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando rejeitar o plano, atualiza o plano e a etapa que ³
		//³esta sendo rejeitada.                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cAcaoOrig)
			dbSelectArea("QI5")
			QI5->(dBSetOrder(4))
			IF QI5->(MsSeek(xFilial("QI5")+cPlano+cRevPlan+cAcaoOrig))
				RecLock("QI5",.F.)
				QI5->QI5_REALIZ := dDataBase
				QI5->QI5_STATUS := "4"
				QI5->QI5_PEND   := "N"
				If !Empty(cMemo)
					cObservacao:= IIf( !Empty(QI5->QI5_DESCRE) ,QI5->QI5_DESCRE+CRLF,"")
					cObservacao+= cMemo
					MSMM(QI5_DESCCO,,,cObservacao,1,,,"QI5","QI5_DESCCO")
				Endif
				MsUnLock()
				FKCOMMIT()
	        Endif
	    Endif
	Endif
	QI3->(MsUnLock())
	FKCOMMIT()
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCAvisa  ºAutor  ³Microsiga           º Data ³  07/26/08   º±±
S±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manda mensagem de aviso de                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCAvisa(cAlias,nIndAli,cChave,cTPMsg,cMatFil,cMatCod)
Local aAreaALI := {}
Local aAreaOri := GetArea()
Local aAreaQAA := QAA->(GetArea())

DEFAULT cAlias  := "QI3"
DEFAULT cTPMsg  := "1" ///"1"=Plano Baixado.
DEFAULT nIndAli := 2

If Type("aUsuarios") != "A"
	Private aUsuarios := {}
EndIf

dbSelectArea(cAlias)
aAreaALI := (cAlias)->(GetArea())
(cAlias)->(dbSetOrder(nIndAli))
If (cAlias)->(MsSeek(cChave,.F.))

	If cTPMsg == "1"
		If cMatFil+cMatCod <> (cAlias)->(&(cAlias+"_FILMAT")+&(cAlias+"_MAT"))

			dbSelectArea("QAA")
			QAA->(dbSetOrder(1))
			If QAA->(dbSeek((cAlias)->(&(cAlias+"_FILMAT")+&(cAlias+"_MAT")) )) .And. QAA->QAA_RECMAI == "1"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envio de e-Mail para o responsavel do Plano de Acao                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(QAA->QAA_EMAIL)

					If Ascan(aUsuarios,{ |x| x[1] == QAA->QAA_LOGIN }) == 0

						cTpMail:= QAA->QAA_TPMAIL

						// ETAPAS DO PLANO DE ACAO
						If cTpMail == "1"
							cMail := AllTrim(QAA->QAA_EMAIL)
							cMsg := QNCSENDMAIL(2,OemToAnsi(STR0035))	// "Todas as Etapas foram Finalizadas, favor verificar Plano de Acao no Sistema."
						Else
							cMsg := OemToAnsi(STR0028)+DtoC(QI3->QI3_ABERTU)+Space(10)+OemToAnsi(STR0034)+DtoC(QI3->QI3_ENCPRE)+CHR(13)+CHR(10)	 // "Plano de Acao Iniciado em " ### " Data Prevista p/ Conclusao: "
							cMsg += CHR(13)+CHR(10)
							cMsg += OemToAnsi(STR0035)+CHR(13)+CHR(10)	// "Todas as Etapas foram Finalizadas, favor verificar Plano de Acao no Sistema."
							cMsg += Replicate("-",80)+CHR(13)+CHR(10)
							cMsg += OemToAnsi(STR0031)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
							cMsg += MSMM(QI3->QI3_PROBLE,80)+CHR(13)+CHR(10)
							cMsg += Replicate("-",80)+CHR(13)+CHR(10)
							cMsg += CHR(13)+CHR(10)
							cMsg += CHR(13)+CHR(10)
							cMsg += OemToAnsi(STR0032)+CHR(13)+CHR(10)	// "Atenciosamente "
							cMsg += QA_NUSR(cMatFil,cMatCod,.F.)+CHR(13)+CHR(10)
							cMsg += QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)
							cMsg += CHR(13)+CHR(10)
							cMsg += OemToAnsi(STR0036)	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
						Endif

						cAttach := ""
						aMsg:={{OemToAnsi(STR0033)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach } }	// "Plano de Acao No. "

						// Geracao de Mensagem para o Responsavel do Plano de Acao
						IF ExistBlock( "QNCRACAO" )
							aMsg := ExecBlock( "QNCRACAO", .f., .f., { OemToAnsi(STR0035),.F. } ) // "Todas as Etapas foram Finalizadas, favor verificar Plano de Acao no Sistema."
						Endif

						aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )
					EndIf
				EndIf
			EndIf
			QAA->(DbCloseArea())
		EndIf
	EndIf
EndIf

RestArea(aAreaQAA)
RestArea(aAreaALI)
RestArea(aAreaOri)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCA050   ºAutor  ³Microsiga           º Data ³  09/26/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QI9FindFNC(cPLANO,cPLAREV,lFNCAtiva,lPosiQI2,lPosiQI9)

Local nQi2Found	:= 0
Local aAreaQI2 := {}
Local aAreaQI9 := {}

DEFAULT lFNCAtiva	:= .T.
DEFAULT lPosiQI2 := .T.
DEFAULT lPosiQI9 := .T.

dbSelectArea("QI9")
aAreaQI9 := GetArea()
QI9->(DBSetOrder(1))
If QI9->(MsSeek(xFilial("QI9")+cPLANO+cPLARev,.F.) )
	While QI9->(!Eof()) .and. QI9->QI9_CODIGO == cPLANO .and. QI9->QI9_REV == cPLAREV
		dbSelectArea("QI2")
		aAreaQI2 := GetArea()
		dbSetOrder(2)
		If MsSeek(xFilial("QI2")+QI9->(QI9_FNC+QI9_REVFNC),.F.)
			If lFNCAtiva .and. QI2->QI2_OBSOL == "S"
				QI9->(dbSkip())
				Loop
			Else
				nQi2Found := QI2->(Recno())
				Exit
			EndIf
		EndIf
		QI9->(dbSkip())
	EndDo
EndIf

If !lPosiQI2
	RestArea(aAreaQI2)
EndIf

If !lPosiQI9
	RestArea(aAreaQI9)
EndIf

Return nQi2Found

//----------------------------------------------------------------------------------------------
//carrega array aQI3 - foi separado em outra função pois necessita ser chamada em outros pontos.

Static Function QNCA50QI3(aQI3,cMatFil,cMatCod,lQn050Lfil)

Default aQI3	:={}
Default cMatFil :=''
Default cMatCod :=""
Default lQn050Lfil := .F.

cQuery :=" SELECT QI3.QI3_FILMAT,QI3.QI3_MAT,QI3.QI3_CODIGO,QI3.QI3_REV,QI3.QI3_STATUS,QI3.QI3_ABERTU, "
cQuery +=" QI3.QI3_ENCPRE,QI3.QI3_TIPO,QI3.R_E_C_N_O_,QI3.QI3_FILIAL,QI3.QI3_PROBLE "
cQuery +=" FROM " + RetSqlName("QI3") + " QI3 "
cQuery +=" WHERE  "+Iif(!lQn050Lfil,"QI3.QI3_FILMAT='"+cMatFil+"' AND","")+" QI3.QI3_MAT='"+cMatCod+"' AND "
cQuery +=" QI3.QI3_ENCREA='"+SPACE(8)+"' AND  D_E_L_E_T_ <> '*'"

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2"
Else
	cQuery += " ORDER BY " + SqlOrder("QI3_FILMAT+QI3_MAT")
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNCFILPD")
	cQuery := ExecBlock("QNCFILPD", .f., .f.,{"QI3",cQuery})
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQI3",.T.,.T.)

TcSetField("TMPQI3","QI3_ABERTU","D")
TcSetField("TMPQI3","QI3_ENCPRE","D")

TMPQI3->(DbGoTop())
While TMPQI3->(!Eof())
	AADD( aQI3,{TMPQI3->QI3_CODIGO,;					// Codigo Plano de Acao
	TMPQI3->QI3_REV,;									// SIGA da Acao
	SubStr(MSMM(TMPQI3->QI3_PROBLE,80),0,40),;        	// Memo Descricao Detalhada
	Val(TMPQI3->QI3_STATUS),;		        			// Status da Acao
	TMPQI3->QI3_ABERTU,;								// Data Abertura
	TMPQI3->QI3_ENCPRE,;								// Encerramento Previsto
	Val(TMPQI3->QI3_TIPO),;          					// Tipo Acao
	TMPQI3->R_E_C_N_O_,;								// Registro para controle
	TMPQI3->QI3_FILIAL })				   				// Filial da Acao
	TMPQI3->(DbSkip())
Enddo
TMPQI3->(DBCLOSEAREA())

Return NIL


//----------------------------------------------------------------------------------------------
//carrega array aQI5 - foi separado em outra função pois necessita ser chamada em outros pontos.

Static Function QNCA50QI5(aQI5,cMatFil,cMatCod,lQn050Lfil)

Default aQI5	:={}
Default cMatFil :=''
Default cMatCod :=""
Default lQn050Lfil := .F. 

aQI5 :={}

If TcSrvType() <> "AS/400"
	cQuery :=" SELECT QI5.QI5_FILMAT,QI5.QI5_MAT,QI5.QI5_PEND,QI5.QI5_CODIGO,QI5.QI5_REV, "
	cQuery +=" QI5.QI5_STATUS,QI5.QI5_TPACAO,QI5.QI5_PRAZO,QI5.QI5_REALIZ,QI5.R_E_C_N_O_, "
	cQuery +=" QI5.QI5_DESCRE,QI5.QI5_DESCCO,QI5.QI5_DESCOB,QI5.QI5_FILIAL "
	cQuery +=" FROM " + RetSqlName("QI5")+" QI5 "
	cQuery +=" WHERE  "+Iif(!lQn050Lfil,"QI5.QI5_FILMAT='"+cMatFil+"' AND","")+" QI5.QI5_MAT='"+cMatCod+"' AND "
	cQuery +=" QI5.QI5_PEND='S'  AND  QI5.D_E_L_E_T_ <> '*'"

	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cQuery += " ORDER BY 1,2,3"
	Else
		cQuery += " ORDER BY " + SqlOrder("QI5_FILMAT+QI5_MAT+QI5_PEND")
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QNCFILPD")
		cQuery := ExecBlock("QNCFILPD", .f., .f.,{"QI5",cQuery})
		lExecQI5 := .T.
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQI5",.T.,.T.)

	TcSetField("TMPQI5","QI5_PRAZO" ,"D")
	TcSetField("TMPQI5","QI5_REALIZ","D")

	TMPQI5->(DbGoTop())
	While TMPQI5->(!Eof())
		AADD( aQI5,{TMPQI5->QI5_CODIGO,;			  // Codigo Plano de Acao
					TMPQI5->QI5_REV,;				  // Revisao da Acao
					TMPQI5->QI5_STATUS,;			  // Status da Acao
					FQNCDTPACAO(TMPQI5->QI5_TPACAO),; // Tipo da Acao
					TMPQI5->QI5_PRAZO,;				  // Prazo/Vecto da Acao
					TMPQI5->QI5_REALIZ,;			  // Data Realizacao/Baixa
					TMPQI5->R_E_C_N_O_,;			  // Registro para controle
					TMPQI5->QI5_DESCRE,;              // Descricao Resumida
					MSMM(TMPQI5->QI5_DESCCO,80),;     // memo Descricao
					MSMM(TMPQI5->QI5_DESCOB,80),;     // memo Obs
					TMPQI5->QI5_FILIAL})              // Filial do Plano
		TMPQI5->(DbSkip())
	Enddo
	TMPQI5->(DBCLOSEAREA())
EndIf

Return Nil
