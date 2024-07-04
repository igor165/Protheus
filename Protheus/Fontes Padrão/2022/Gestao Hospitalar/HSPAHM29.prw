#INCLUDE "HSPAHM29.CH"                
#INCLUDE "PROTHEUS.CH" 
#include "TopConn.ch"
#INCLUDE "VKEY.CH"
             
Static lExecFilt := .F.
Static lM29ChaExt := .T.
Static __RetProt  := ""

/*/         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ HSPAHM29 ³ Autor ³ Paulo Emidio de Barros³ data ³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Agenda Ambulatorial                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHM29()

Local bKeyF12
Local cCadastro  := OemToAnsi(STR0001) //"Agenda Ambulatorial"
Local aSitAtende := {}

Private aCpoUsu 	:= {}
Private bGrava     	:= {|| GM8REGGER := M->GM8_REGGER, GM8NOMPAC := M->GM8_NOMPAC, GM8MATRIC := M->GM8_MATRIC, GM8TELPAC := M->GM8_TELPAC, GM8CODPLA := M->GM8_CODPLA, GM8SQCATP := M->GM8_SQCATP }
Private bCopia     	:= {|| M->GM8_REGGER := GM8REGGER, M->GM8_NOMPAC := GM8NOMPAC, M->GM8_MATRIC := GM8MATRIC, M->GM8_TELPAC := GM8TELPAC, M->GM8_CODPLA := GM8CODPLA, M->GM8_SQCATP := GM8SQCATP }
Private lCopiar     := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao de Variaveis de Memoria para tecla copiar, utilizado nos fontes HSPAHM12, HSPAHM13, HSPAHM29, HSPAHM54, HSPAHM61      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private GM8REGGER  := Space( (TamSx3( "GM8_REGGER" )[1]) )
Private GM8NOMPAC  := Space( (TamSx3( "GM8_NOMPAC" )[1]) )
Private GM8MATRIC  := Space( (TamSx3( "GM8_MATRIC" )[1]) )
Private GM8TELPAC  := Space( (TamSx3( "GM8_TELPAC" )[1]) )
Private GM8CODPLA  := Space( (TamSx3( "GM8_CODPLA" )[1]) )
Private GM8SQCATP  := Space( (TamSx3( "GM8_SQCATP" )[1]) )  

Private lM29SimNao := .T. 
Private lFilGm1    := .T. 
Private cGcsCodLoc := "" //Setor selecionado 
Private cGD4RegGer := "" //Campo utilizado na consulta padrao GD4
Private cGcsTipLoc := "5" 
Private cFilM29 := ""   
Private oGetAte := Nil
Private nQtdEnc := 0 
Private aHorGer	:= {}

HS_ATXBGCS()
                                  
Aadd(aSitAtende,{"HSPAgeLiv()","BR_VERDE"   }) //Horario Livre
Aadd(aSitAtende,{"HSPAgeOcu()","BR_VERMELHO"}) //Horario Ocupado
Aadd(aSitAtende,{"HSPEncOcu()","BR_PRETO"   }) //Horario Ocupado
Aadd(aSitAtende,{"HSPAgePar()","BR_AMARELO" }) //Horario Bloqueado
Aadd(aSitAtende,{"HSPAgeAte()","BR_PINK"    }) //Horario Atendido
Aadd(aSitAtende,{"HSPAgeOcB()","BR_AZUL"    }) //Horario Bloqueado/Ocupado
Aadd(aSitAtende,{"HSPAgeAgC()","BR_LARANJA" }) //Horario Bloqueado/Ocupado
Aadd(aSitAtende,{"HSPAgeCon()","BR_VIOLETA" }) //Em Conferencia
Aadd(aSitAtende,{"HSPAgeTrs()","BR_BRANCO"  }) //Transferido

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//³    6 - Altera determinados campos sem incluir novos Regs     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()
If !Hs_ExisDic({{"C","GM8_CODREC","FNC 148152"}})              	
	Return(nil)
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Solicita e filtra os Setores validos para o Atendimento Amb. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( HSPM29Perg() )     
 
	lM29ChaExt := .F.

	bKeyF12 := SetKey(VK_F12,{||HSPM29Perg()})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia o Filtro no Browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HSPM29FilBrw(.F., .T.)
		
	dbSelectArea("GM8")
	dbSetOrder(2)	
	
	mBrowse(06, 01, 22, 75, "GM8",,,,,, aSitAtende,,,,,,,, cFilM29)
	
	dbSelectArea("GM8")
	dbClearFilter()
	
	SetKey(VK_F12, bKeyF12)

EndIf 

Return(NIL)                                 
                                                 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM29Atu³ Autor ³Paulo Emidio de Barros ³ Data ³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Agendamento Ambulatorial                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29Atu(EXPC1,EXPN1,EXPN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo                                   ³±±
±±³          ³ 3EXPN1 = Numero do registro                                 ³±±
±±³          ³ EXPN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSPM29Atu                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                 
Function HSPM29Atu(cAlias,nReg,nOpc)
Local lOk        := .F.                                                                                                                 
Local bOk        := {|| If(Obrigatorio(aGets,aTela) .And. HSPM29VerHorEnc(nFldAtu, @cSeqAge) .And. HS_VldM29(nOpc) .And. HSPM29SavAge(NIL,nFldAtu,NIL,nDiaAgeAtu) .And. HSPM29Grv(nOpc, @cSeqAge,aMeses), (lOk := .T., oDlg:End()), nil)}
Local bCancel    := {||FS_BCancel(), oDlg:End()}
Local aButtons   := {}
Local aCpoEnc    := {}
Local aTitulos   := {}
Local aPaginas   := {}
Local aAreaAnt   := {}
Local aCoordEnc  := {}
Local aMeses     := {}
Local nFld       := 0 
Local nCpoUsu    := 0
Local nFor       := 0
Local nUsadoGM8  := 0
Local nCodAge 	 := 0
Local lDataAtu   := .T.
Local lRegAtu    := .F. //Indica se o Filtro da Agenda sera acionado somente no registro corrente
Local lHelp      := .F.
Local lRes800	 := .F.
Local cSeqAge 	 := ""
Local cObsPlano  := " "
Local cMemPrep   := " "
Local cObsProc   := " " 
Local cObsProf   := " "
Local cCpoEnc    := " "      
Local cDisCons	 := ""
Local cMsgAge    := " "
Local aAltEnc
Local oSay
Local oVermelho
Local oAmarelo
Local oVerde
Local oBranco
Local oPanel2
Local oEnchoice
Local oDlg
Local oFont
Local oPanel1
Local aInfo
Local aPMemo
Local aPEnc
Local aResol
Local oObsPlano 
Local oObsProc
Local oObsProf
Local aPCal 		:= Array(1)
Local aSList 		:= Array(2)
Local bATipo    	:= {|A,B|IIf(A#B,cTipoAg:="A",cTipoAg:= "A") }
Local nOpcGd 		:=  IF(nOpc==3 .Or. nOpc==4, 0, GD_UPDATE + GD_INSERT + GD_DELETE)
Local aSize     	:= MsAdvSize() //Define as coordenadas da tela - passou para local 
Local oPnlBrw     	:= nil 
Local cCadastro  	:= OemToAnsi(STR0001) //"Agenda Ambulatorial"


Private aPnlGetDados 	:= {nil,nil}
Private lDataBase   := .T.//indica se o Filtro da Agenda sera acionado a partir da Data Base do Sistema
Private lCanUnic	:= .F.
Private aGets    	:= {}
Private aTela    	:= {}
Private aLocks  	:= {}
Private aAgenda  	:= {}
Private aHeaderGM8 	:= {} 
Private aColsGM8   := {}
Private aLastMar  	:= {}
Private aTrfHorAge 	:= {} //Vetor que armazena o Registro a ser Transferido
Private aVldFutDt 	:= {}
Private aVCposOld 	:= {} 
Private nFldAtu    	:= 1 //Folder Atual
Private nFldAnt    	:= 1 //Folder Anterior
Private nDiaAgeAnt 	:= 1 //Posicao do Dia Anterior no Vetor das Marcacoes
Private nDiaAgeAtu 	:= 1 //Posicao do Dia Atual no Vetor das Marcacoes
Private nStatus 	:= 0
Private nRegGer 	:= 0
Private nPosHor 	:= 0
Private nLastFld  	:= 0 //Ultimo Folder
Private nLastDay  	:= 0 //Ultimo Dia Agendado
Private nLastHour 	:= 0 //Ultima Hora
Private nLastRec  	:= 0
Private nGO4_CODPRO := 0
Private nGO4_DESPRO := 0
Private cGCM_CODCON	:= " "
Private cGczCodPla  := " "
Private cGfvPlano   := "" //Filtro de categoria do plano GFV VARIAVEL RECEBE CONTEUDO MAS NAO GRAVA 
Private cGm7OriCan  := " "      //Origem do Cancelamento
Private cGbjCodEsp  := " "
Private cGbhCodPac  := ""  // Variavel que recebe o retorno da consulta padrão GH1 (Pacientes)
Private cCodCrmAnt  := " "
Private cPriDia  	:= " "
Private cPriHor     := " "
Private cCodDis     := " "
Private cCodRec     := " "
Private cEncIni 	:= "" 
Private cEncFim 	:= ""
Private cMes   		:= " "
Private nOpcSav  	:= nOpc //Salva a opcao do aRotina
Private nOpcDef   	:= nOpc
Private aOBJETOS 	:= Array(2)
Private oPnlFolder  := nil
Private oFolder
Private cTipoAg  //pega tipo de agenda do parametro A=amb/P=PA
Private oCalend
Private cHorasRet		:= ""
Private oMeses
Private oGO4
Private oBrwTrf //e carregado uma vez e depois se perde
Private aCGO4 	 := {}
Private aHGO4 	 := {}
Private nUGO4 	 := 0
//Agendamento multiplo de sessoes (HSPAHM13)
Private lAgdmSes   := SuperGetMv("MV_AGDMSES",nil,.F.)
Private lHspahm13  := isInCallStack("HSPAHM13")
Private cCodSolGkb := ""
Private lGm8SolGbb := Hs_ExisDic({{"C","GM8_SOLGKB"}}, .F.)
Private nQtdSolGkb := 0
if lHspahm13
	cCodSolGkb := GKB->GKB_SOLICI
	nQtdSolGkb := GKB->GKB_QTDSOL
endif 

Eval( bATipo,TRIM(FunName()),"HSPAHM29" )

If	oMainWnd:nRight <= 1024
	lRes800 := .T.
Endif

If (nOpc==3 .Or. nOpc==4 .Or. nOpc==5) //Cancelar; Transferir; Alterar
	If GM8->GM8_STATUS == "3" //Horario Atendido
		cMsgAge := STR0063 //"O Horario selecionado ja foi atendido"
		lHelp   := .T.

	ElseIf GM8->GM8_STATUS == "8" //Transferido
	
		cMsgAge := STR0210 //"O Horario selecionado foi transferido"
		lHelp   := .T.
		
	Else
		cMsgAge := STR0050 + aRotina[nOpc, 1] + STR0051 //"Não será possível " ### " o Horario selecionado na Agenda"
		
		If !(GM8->GM8_STATUS $ "1/4/5")
			lHelp := .T.
		EndIf
		
		If GM8->GM8_DATAGE < dDataBase
			cMsgAge += STR0052 //", com Data retroativa"
			lHelp   := If(lHelp,lHelp,.T.)
		EndIf
		
		If (GM8->GM8_DATAGE == dDataBase) .And. (GM8->GM8_HORAGE < SubStr(Time(),1,5))
			cMsgAge += STR0053 //", pois o Horário já foi expirado"
			lHelp   := If(lHelp,lHelp,.T.)
		EndIf

	EndIf
		
	If lHelp
		HS_MsgInf(OemToAnsi(cMsgAge), STR0077, STR0073)  //"Atenção"###"Agendamento Ambulatorial"
		Return(NIL)
	EndIf
EndIf

If nOpc==3
	If !Fs_VerAgend (GM8->GM8_SEQAGE, GM8->GM8_REGGER,GM8->GM8_CODPLA)
		If !lCanUnic
			Return(nil)
		EndIf
	EndIf
EndIf
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos que deverao ser editados na Enchoice                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCpoEnc,"GM8_FILAGE")
Aadd(aCpoEnc,"GM8_MATRIC")
Aadd(aCpoEnc,"GM8_REGGER")
Aadd(aCpoEnc,"GM8_NOMPAC")
Aadd(aCpoEnc,"GM8_TELPAC")
Aadd(aCpoEnc,"GM8_CODPRO")
Aadd(aCpoEnc,"GM8_DESPRO")
Aadd(aCpoEnc,"GM8_CODPLA")
Aadd(aCpoEnc,"GM8_DESPLA")
Aadd(aCpoEnc,"GM8_CODSAL")
Aadd(aCpoEnc,"GM8_NOMSAL")
Aadd(aCpoEnc,"GM8_SQCATP")
Aadd(aCpoEnc,"GM8_DSCATP")
Aadd(aCpoEnc,"GM8_CODCRM")
Aadd(aCpoEnc,"GM8_NOMCRM")
Aadd(aCpoEnc,"GM8_OBSERV")
Aadd(aCpoEnc,"GM8_DURACA")
Aadd(aCpoEnc,"GM8_INTERV")
Aadd(aCpoEnc,"GM8_NUMSES")
Aadd(aCpoEnc,"GM8_PROTOC")

//Exibe o motivo somente nas opcoes: Cancelar e Transferir
If (nOpc==3 .Or. nOpc==4)
	Aadd(aCpoEnc,"GM8_MOTIVO")
	Aadd(aCpoEnc,"GM8_DESMOT")
	Aadd(aCpoEnc,"GM8_ORICAN")
EndIf	                      

//Define se edita o primeiro registro posicionado nas opcoes: Cancelar, Transferir e Alterar
If (nOpc==3 .Or. nOpc==4 .Or. nOpc==5 )
	lRegAtu := .T.	
	
	//Define a chave de pesquisa a ser utilizada nas opcoes: Transferir, Cancelar e Alterar
	cFilAtu    := GM8->GM8_FILIAL
	cFilAgeAtu := GM8->GM8_FILAGE
	cCrmAtu    := GM8->GM8_CODCRM
	cDatAgeAtu := dTos(GM8->GM8_DATAGE)
	cHorAgeAtu := GM8->GM8_HORAGE
	cStatAtu   := GM8->GM8_STATUS
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define quais os campos poderao ser editados na Enchoice con- ³
//³ forme a opcao selecionada.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3) //Cancelar
	aAltEnc := {"GM8_OBSERV","GM8_MOTIVO","GM8_ORICAN"}

ElseIf (nOpc == 4 )//Transferir
	aAltEnc := {"GM8_FILAGE","GM8_CODPRO","GM8_DESPRO","GM8_CODPLA","GM8_DESPLA","GM8_SQCATP","GM8_DSCATP",;
	"GM8_CODCRM","GM8_NOMCRM","GM8_OBSERV","GM8_MOTIVO","GM8_ORICAN","GM8_DURACA"}

ElseIf (nOpc == 5) //Alterar
	If Empty(GM8->GM8_REGGER)
		aAltEnc := {"GM8_MATRIC","GM8_TELPAC","GM8_OBSERV"}
	Else
		aAltEnc := {"GM8_TELPAC","GM8_OBSERV"}
	EndIf
EndIf

If Str(nOpc, 1) $ "3/4/5"
	GCM->(DbSetOrder(2)) //GCM_FILIAL + GCM_CODPLA
	GCM->(DbSeek(xFilial("GCM") + GM8->GM8_CODPLA))

	GA9->(dbSetOrder(1)) // GA9_FILIAL + GA9_CODCON
	GA9->(dbSeek(xFilial("GA9") + GCM->GCM_CODCON))
	cObsPlano  := GA9->GA9_OBSERV //Observacao do Plano
	cGczCodPla := GM8->GM8_CODPLA
	
	GA7->(dbSetOrder(1))	 // GA7_FILIAL + GA7_CODPRO
	GA7->(dbSeek(xFilial("GA7") + GM8->GM8_CODPRO))
	cObsProc   := GA7->GA7_OBSERV //Observacao do Procedimento
	cGbjCodEsp := GA7->GA7_CODESP
	
	GBJ->(dbSetOrder(1)) //GBJ_FILIAL + GBJ_CRM
	GBJ->(dbSeek(xFilial("GBJ") + GM8->GM8_CODCRM))
	cObsProf := GBJ->GBJ_OBSERV //Observacao do Profissional
	
	cMemPrep := FS_RetPrep(GM8->GM8_CODPRO)
EndIf

cCpoEnc := "GM8_FILAGEßGM8_TELPACßGM8_OBSERVßGM8_MOTIVO" //Define os campos que nao deverao ser editados na Getdados

aAreaAnt := If(nOpc<>2,GetArea(),aAreaAnt) //Salva a area do GM8, porque a HS_BDADOS nao salva a area corrente

HS_BDados("GM8",@aHeaderGM8,@aColsGM8,@nUsadoGM8,1," ",NIL,,"GM8_STATUS",,,cCpoEnc,.T.)

If(Len(aAreaAnt)>0,RestArea(aAreaAnt),NIL)

//Salva as posicoes dos campos editados na GetDados
nCodAge := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODAGE"}) //Codigo do agendamento
nStatus := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_STATUS"}) //Status
nRegGer := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_REGGER"}) //Prontuario
nMatric := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_MATRIC"}) //Matricula do plano
nDesPro := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DESPRO"}) //Descricao do Procedimento
nNomSal := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_NOMSAL"}) //Nome da Sala
nCodRec := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODREC"}) //Codigo Recurso
nDsCatP := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DSCATP"}) //Descricao da Categora do Plano

//Define o vetor com os meses para edicao do Calendario 
Aadd(aMeses,STR0008) //"Janeiro"
Aadd(aMeses,STR0009) //"Fevereiro"
Aadd(aMeses,STR0010) //"Marco"
Aadd(aMeses,STR0011) //"Abril"
Aadd(aMeses,STR0012) //"Maio"
Aadd(aMeses,STR0013) //"Junho"
Aadd(aMeses,STR0014) //"Julho"
Aadd(aMeses,STR0015) //"Agosto"
Aadd(aMeses,STR0016) //"Setembro"
Aadd(aMeses,STR0017) //"Outubro"
Aadd(aMeses,STR0018) //"Novembro"
Aadd(aMeses,STR0019) //"Dezembro"

//Define as Opcoes no Folder
Aadd(aTitulos,STR0020) //"Atendimento"
Aadd(aTitulos,STR0021) //"Encaixe"
Aadd(aTitulos,STR0022) //"Observacoes"
Aadd(aTitulos,"Procedimentos")
Aadd(aTitulos,"Preparo")

Aadd(aPaginas,STR0064) //"ATENDIMENTO"
Aadd(aPaginas,STR0065) //"ENCAIXE"
Aadd(aPaginas,STR0066) //"OBSERVACOES"
Aadd(aPaginas,"Procedimentos")
Aadd(aPaginas,"PREPARO")

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aObjects := {}
AAdd( aObjects, { 100, 045, .T., .T., .T. } )
If nOpc == 4 .OR. nOpc ==  2// transferir ou Agendar
	AAdd( aObjects, { 100, 055, .T., .T., .T. } )
Else
	AAdd( aObjects, { 100, 073, .T., .T., .T. } )
EndIf
aPObjs := MsObjSize( aInfo, aObjects, .T. )

aInfo    := { aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], 0, 0 }
aObjects := {}
AAdd( aObjects, { Iif(lRes800, 50, 55), 100, .T., .T.} )
AAdd( aObjects, { Iif(lRes800, 50, 45), 100, .T., .T., .T.} )
aPEnc := MsObjSize( aInfo, aObjects, .T., .T. )
	                      
aObjects := {}
AAdd( aObjects, { 033, 100, .T., .T., .T.} )
AAdd( aObjects, { 033, 100, .T., .T., .T.} )
AAdd( aObjects, { 033, 100, .T., .T., .T.} )
aInfo  := { aPObjs[1, 1]-08, aPObjs[1, 2]+20, aPObjs[1, 3], aPObjs[2, 4]-20, 0, 0 }
aPMemo := MsObjSize( aInfo, aObjects, .T., .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela principal da rotina	                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],000 To aSize[6],aSize[5] OF GetWndDefault() PIXEL
DEFINE FONT oFont NAME "Arial" SIZE 10,20 BOLD

oPanel1	:=	tPanel():New(aPObjs[1, 1],aPObjs[1, 2],,oDlg,,,,,,aPObjs[1, 3],aPObjs[1, 4])
oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

//Cria as variaveis para edicao na enchoice
RegToMemory("GM8",If(nOpc==2,.T.,.F.),.F.)

cCodDis := M->GM8_CODDIS
cCodRec := M->GM8_CODREC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Edicao do Agendamento                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc==4 .or. nOpc==2) //Transferir  ou Agendar
	aCoordEnc := {aPEnc[1, 1], aPEnc[1, 2], aPEnc[1, 3], aPEnc[1, 4]}//{015,003,095,280} //Define as coordenadas do cabecalho do Agendamento
Else
	aCoordEnc := aPEnc[1] //{015,003,150,280} //Define as coordenadas do cabecalho do Agendamento
EndIf

aCpoUsu := HS_CposUsu(@aCpoEnc, "GM8")

If StrZero(nOpc, 2) $ "04/05"
	For nCpoUsu := 1 to len(aCpoUsu)
		Aadd(aAltEnc,aCpoUsu[nCpoUsu])
	Next nCpoUsu
Endif

oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,aCpoEnc,aCoordEnc,aAltEnc,3,,,,oPanel1,,.T., lRes800,,,,,.T.)
oEnchoice:aEntryCtrls[aScan(oEnchoice:aGets, {|x| "GM8_CODCRM" $ x})]:bLostfocus := {|| If (!Empty(cCodDis).And. !Empty(cCodCrmAnt) .And. (If(FunName() <> "HSPAHMA7",cCodCrmAnt <> M->GM8_CODCRM,.F.)), cCodDis := "", cCodDis),If(FunName() == "HSPAHMA7" .AND. !Empty(M->GM8_CODCRM),HSPM29CONSFIL(                ,@cObsPlano,@cMemPrep,@cObsProc,@cObsProf,/*@aColsGM8*/,GM8->GM8_FILIAL ,GM8->GM8_FILAGE,GM8->GM8_CODCRM,dTos(GM8->GM8_DATAGE),GM8->GM8_HORAGE,GM8->GM8_STATUS,/*cPriDia*/,/*oPnlFolder*/,/*@aPnlGetDados*/,cCpoEnc,cDisCons),Nil) }
oEnchoice:aEntryCtrls[aScan(oEnchoice:aGets, {|x| "GM8_CODCRM" $ x})]:bGotfocus := {|| cDisCons := "" }
oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oPanel2	:=	tPanel():New(aPEnc[2, 1],aPEnc[2, 2],, oPanel1,,,,,,aPEnc[2, 3],aPEnc[2, 4],,.T.)
oPanel2:Align := CONTROL_ALIGN_RIGHT

If (nOpc==4 .or. nOpc==2) //Transferir  ou Agendar
	HSPM29IniTrf(.T.,nOpc,lRes800,@oPanel2,oFont)
EndIf

aSList[2] := 105                                

If lRes800
	aSList[1] := 45
	aPCal[1] := 50
Else
	aSList[1] := 70
	aPCal[1] := 75
Endif

//Selecao do Mes
If nOpc != 4 .AND. nOpc != 2 //transferir and Agendar
	@ 02,02 ListBox oMeses Var cMes Fields Header OemToAnsi(STR0023) Size aSList[1], aSList[2] NoScroll Of oPanel2 Pixel //"Mes Atual"
Else
	@ 02,02 ListBox oMeses Var cMes Fields Header OemToAnsi(STR0023) Size aSList[1], aSList[2]-25 NoScroll Of oPanel2 Pixel //"Mes Atual"
EndIf

oMeses:SetArray(aMeses)
oMeses:bLine   := {||{aMeses[oMeses:nAt]}}
oMeses:bChange := {||FS_UnLock(nFldAtu, nDiaAgeAtu), HSPM29Navega(NIL,"+",NIL,@lDataAtu),HSPM29Filtro(nOpc,lRegAtu,lRes800,oPanel2,oFont,/*aColsGM8*/,GM8->GM8_FILIAL,GM8->GM8_FILAGE, GM8->GM8_CODCRM,dTos(GM8->GM8_DATAGE),GM8->GM8_HORAGE,GM8->GM8_STATUS,/*cPriDia*/,/*oPnlFolder*/,/*@aPnlGetDados*/,cCpoEnc)}//FS_UNLOCK - Desbloqueia o registro sempre que se muda o mes
                    
If (nOpc==3 .Or. nOpc==5) //Se Cancelamento ou Alteracao', desabilita a navegacao dos Meses
	oMeses:Disable()
EndIf
                                 
//Selecao atraves do Calendario
oCalend            := MsCalend():New(02, aPCal[1], oPanel2)
oCalend:bChangeMes := {||FS_UnLock(nFldAtu, nDiaAgeAtu), HSPM29Navega(NIL,NIL,"+",@lDataAtu),HSPM29Filtro(nOpc,lRegAtu,lRes800,oPanel2,oFont,/*aColsGM8*/,GM8->GM8_FILIAL,GM8->GM8_FILAGE, GM8->GM8_CODCRM,dTos(GM8->GM8_DATAGE),GM8->GM8_HORAGE,GM8->GM8_STATUS,/*cPriDia*/,/*oPnlFolder*/,/*@aPnlGetDados*/,cCpoEnc)} //FS_UNLOCK - Desbloqueia o registro sempre que se muda o mes
oCalend:bChange    := {||HSPM29MkDia()}

If (nOpc==3 .Or. nOpc==5) //Se Cancelamento ou Alteracao, desabilita a navegacao no Calendario
	oCalend:Disable()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe a Legenda Padrao da Rotina                     							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 68,aPCal[1] 		BITMAP oVermelho RESOURCE "BR_VERMELHO" SIZE 008,008 OF oPanel2 ADJUST PIXEL NOBORDER When .F.
@ 68,aPCal[1]+10	Say OemToAnsi(STR0024) OF oPanel2 SIZE 030,010 Pixel  //"Ocupado"

@ 68,aPCal[1]+40	BITMAP oAmarelo  RESOURCE "BR_AZUL"     SIZE 008,008 OF oPanel2 ADJUST PIXEL NOBORDER When .F.
@ 68,aPCal[1]+50	Say OemToAnsi(STR0025) OF oPanel2 SIZE 030,010 Pixel  //"Parcial"

@ 68,aPCal[1]+80 	BITMAP oVerde    RESOURCE "BR_VERDE"    SIZE 008,008 OF oPanel2 ADJUST PIXEL NOBORDER When .F.
@ 68,aPCal[1]+90	Say OemToAnsi(STR0026) OF oPanel2 SIZE 030,010 Pixel  //"Livre"

@ 68,aPCal[1]+120 	BITMAP oBranco   RESOURCE "BR_BRANCO"   SIZE 008,008 OF oPanel2 ADJUST PIXEL NOBORDER When .F.
@ 68,aPCal[1]+130	Say OemToAnsi(STR0209) OF oPanel2 SIZE 030,010 Pixel  //"Transferido"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Edicao do Atendimento/Encaixe                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder := TFolder():New(aPObjs[2, 1],aPObjs[2, 2],aTitulos,aPaginas,oDlg,,,,.T.,.F.,aPObjs[2, 3],aPObjs[2, 4])
oFolder:Align := CONTROL_ALIGN_BOTTOM
                                        
oFolder:bSetOption := {|nAt|HSPM29SavAge(nFldAtu:=nAt,nFldAnt:=oFolder:nOption,;         //Salva a Marcacao Atual
nDiaAgeAtu:=If(nFldAtu< 3,aOBJETOS[nFldAtu,1]:nAt,nDiaAgeAtu),;  //Define as novas posicoes no aAgenda
nDiaAgeAnt:=If(nFldAnt< 3,aOBJETOS[nFldAnt,1]:nAt,nDiaAgeAnt)),;
If(nFldAtu< 3,HSPM29PaintCalend(),NIL)}                           // Atualizacao do Agendamento
						
oFolder:bChange := {|| If(!HSPM29VerHorEnc(nFldAnt),(oFolder:SetOption(nFldAnt),oFolder:Refresh()),.T.)} //Verifica se o Horario foi informado, caso seja um Encaixe

//Monta os 	browse referentes a Ocupacao e Agenda
aOBJETOS[1] := HSPM29Brw(oFolder:aDialogs[1],1,/*oPnlFolder*/,@oPnlBrw,cCpoEnc,/*@aPnlGetDados*/)
aOBJETOS[2] := HSPM29Brw(oFolder:aDialogs[2],2,/*oPnlFolder*/,@oPnlBrw,cCpoEnc,/*@aPnlGetDados*/)

For nFld := 1 to Len(oFolder:aDialogs)
	DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nFld]
Next nFld

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Edicao das Observacoes: Plano/Procedimento/Profissional      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 005,aPMemo[1, 2]+5 Say OemToAnsi(STR0027) Of oFolder:aDialogs[03] Pixel Font oFont COLOR CLR_BLUE //"Plano"
@ aPMemo[1, 1],aPMemo[1, 2] Get oObsPlano Var cObsPlano MEMO SIZE aPMemo[1, 3]-5,aPMemo[1, 4] OF oFolder:aDialogs[03] Pixel
oObsPlano:lReadOnly := .T.

@ 005,aPMemo[2, 2]+5 Say OemToAnsi(STR0028) Of oFolder:aDialogs[03] Pixel Font oFont COLOR CLR_BLUE //"Procedimento"
@ aPMemo[2, 1],aPMemo[2, 2] Get oObsProc  Var cObsProc MEMO SIZE aPMemo[2, 3]-5,aPMemo[2, 4] OF oFolder:aDialogs[03] Pixel
oObsProc:lReadOnly := .T.

@ 005,aPMemo[3, 2]+5 Say OemToAnsi(STR0029) Of oFolder:aDialogs[03] Pixel Font oFont COLOR CLR_BLUE //"Profissional"
@ aPMemo[3, 1],aPMemo[3, 2] Get oObsProf  Var cObsProf MEMO SIZE aPMemo[3, 3]-5,aPMemo[3, 4] OF oFolder:aDialogs[03] Pixel
oObsProf:lReadOnly := .T.
	
@ 0,0 GET oMemPrep  VAR cMemPrep MEMO READONLY SIZE aPObjs[2, 1], aPObjs[2, 4] OF oFolder:aDialogs[05] PIXEL
oMemPrep:Align := CONTROL_ALIGN_ALLCLIENT


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procedimentos Agendados oFolder:aDialogs[4]                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HS_BDados("GO4", @aHGO4, @aCGO4, @nUGO4, 1,, " GO4_CODAGE = '"+M->GM8_CODAGE+"'")//, .T.)

nGO4_CODPRO := aScan(aHGO4, {| aVet | aVet[2] == "GO4_CODPRO"})
nGO4_DESPRO := aScan(aHGO4, {| aVet | aVet[2] == "GO4_DESPRO"})
oGO4 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nOpcGd,"HS_DuplAC(oGO4:oBrowse:nAt, oGO4:aCols, {nGO4_CODPRO},, .T.)",, "+GO4_CODITE",,, 99999,,,, oFolder:aDialogs[4], aHGO4, aCGO4)
oGO4:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

Aadd(aButtons	, {"edit_ocean", {||HS_ConsAge("A")}, STR0074}) //"Consultar"

If Type("lCopiar") <> "U" .And. lCopiar
	// se teclado copia entao preenche as variaveis
	Eval(bCopia)
	lCopiar := .F.
EndIf
  
If Type("lCopiar") <> "U" .And. aRotina[nOpc,4] == 3
	Aadd(aButtons	, {"SduRepl"   , {|| lCopiar := .T., Eval(bGrava), nOpc := 2, Eval(bOk)}, "Copiar"})
EndIf

If nOpc == 2 .And. Type("__aCpAuM29") <> "U" .And. !Empty(__aCpAuM29)
	oDlg:bStart := { || IIf( !FS_M29CpAu(nOpc, @oEnchoice), oDlg:End(), Nil) } // Se retorna falso.. sai da agenda.
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) VALID .T.
 
If !Empty(aLocks)
	//Caso houve alguma falha que deixou "registros presos" (nao prende o registro eh apenas um semáforo)
	//eles serao liberados aqui
	While Len(aLocks) > 0
		FS_UByName(aLocks[1])
	EndDO
EndIf
		
If nOpc == 2 .And. lOk
	HS_RelM29()
	MBrChgLoop(.T.)
EndIf
Return(cSeqAge)

 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fs_VerAgend  ºAutor  ³Microsiga           º Data ³  05/29/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fs_VerAgend(cSeqAgen, cRegGer, cCodPla)
Local cSql    := ""
Local aArea   := getArea()
Local lCanc   := .F.
Local lAteSUS := (GetMV("MV_ATESUS", , "N") == "S")
Local cCodApc := GetMV("MV_PSUSPAC")
Local cUsuAut := ""

Private cAliasGm8 := "TMPGKA"

DbSelectArea("GM1")
DbSetOrder(1) // GM1_FILIAL + GM1_CODLOC + GM1_CODUSU
DbSeek(xFilial("GM1") + cGcsCodLoc)
While !EOF() .And. xFilial("GM1") == GM1->GM1_FILIAL .And. GM1->GM1_CODLOC == cGcsCodLoc
	If GM1->GM1_AUTORI == "1"
		cUsuAut += IIF(!EMPTY(cUsuAut), "/", "") + UPPER(ALLTRIM(GM1->GM1_CODUSU))
	EndIf
	DbSkip()
EndDo

cSql := " SELECT COUNT (*) QTD, GM8_STATUS "
cSql += " FROM "+RetSqlName("GM8") "
cSql += " WHERE GM8_FILIAL = '"+xFilial("GM8")+"' AND D_E_L_E_T_ <> '*'  "
cSql += " AND GM8_SEQAGE = '"+cSeqAgen+"' AND GM8_REGGER = '"+cRegGer+"' "
cSql += " GROUP BY GM8_STATUS "
cSql += " ORDER BY GM8_STATUS DESC "

TCQuery cSql New Alias "TMPGKA"

While TMPGKA->(!Eof())
	If TMPGKA->GM8_STATUS == '3'
		lCanc := MsgYesNo("Paciente possui sessoes atendidas, deseja cancelar tratamento ?", STR0077)
		If lCanc
			If !(UPPER(ALLTRIM(SubStr(cUsuario, 7, 15))) $ cUsuAut)
				HS_MsgInf("Usuario nao possui permissao para cancelar tratamento, verifique no cadastro do Setor o Usuario Autorizador.", STR0077, STR0123)
				lCanc := .F.
				Exit
			EndIf
			
			If !(lAtesus .And. cCodPla $ cCodApc)
				DbSelectArea("GKB")
				DbSetOrder(5)
				DbSeek(xFilial("GKB") + cRegGer + cSeqAgen)
				If GKB->(!Eof())
					Fs_ExbAgSe(GKB->GKB_SOLICI)
				EndIF
			EndIf
		EndIf
		Exit
	ElseIf TMPGKA->QTD >1
		If MsgYesNo("Deseja cancelar somente este agendamento?", STR0077)
			lCanUnic := .T.
			Exit
		Else
			lCanc := MsgYesNo("Deseja realmente cancelar todos os agendamentos do paciente?", STR0077)
			If lCanc
				If !(lAtesus .And.  cCodPla $ cCodApc)
					DbSelectArea("GKB")
					DbSetOrder(5)
					DbSeek(xFilial("GKB") + cRegGer + cSeqAgen)
					If GKB->(!Eof())
						Fs_ExbAgSe(GKB->GKB_SOLICI)
					EndIF
				EndIf
			EndIf
		EndIf
	Else
		lCanc := .T.
	EndIf
	
	TMPGKA->(DbSkip())
EndDo

DbSelectArea("TMPGKA")
DbCloseArea()

RestArea(aArea)
return(lCanc)

//Salva valor das variaveis de memoria para restaurar no final
Static Function FS_SaveMem(cAlias)
Local aVCposOld := {} // Guarda variaveis de memoria

DbSelectArea("SX3")
DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
DbSeek(cAlias)
While SX3->X3_ARQUIVO == cAlias
	If ValType("M->" + SX3->X3_CAMPO ) <> "U"
		aAdd(aVCposOld, {"M->" + SX3->X3_CAMPO , &("M->" + SX3->X3_CAMPO) })
	EndIf
	SX3->(DbSkip())
End
Return(Nil)
	
// Recupera as variaveis de memória
Static Function FS_RestMem()
Local nCposOld := 0
For nCposOld := 1 To Len(aVCposOld)
	&(aVCposOld[nCposOld, 1]) := aVCposOld[nCposOld, 2]
Next
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM29  ºAutor  ³Luiz Pereira S. Jr. º Data ³  27/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os campos automaticamente na chamada da agenda atra-º±±
±±º          ³ves de outras rotinas.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_M29CpAu(nOpc, oEnc)
Local nFor      := 0
Local aAreaSX3  := {}, cAliasOld := "", cReadVarOld := "", cVar := ""
Local cValid    := ""
 
If nOpc == 2 .And. Type("__aCpAuM29") <> "U" .And. !Empty(__aCpAuM29) // Campos que serao preeenchidos na agenda {campo, conteudo, executa valid}
 
	cReadVarOld := __ReadVar
	cAliasOld := Alias()
	aAreaSX3  := SX3->(GetArea())
 
	For nFor := 1 To Len(__aCpAuM29)

		If __aCpAuM29[nFor, 1] == "M->GM8_CODCRM"
			oEnc:aEntryCtrls[aScan(oEnc:aGets, {|x| "GM8_CODCRM" $ x}) ]:lReadOnly := .T.
		EndIf
   
		__ReadVar := __aCpAuM29[nFor, 1]
		&(__aCpAuM29[nFor, 1]) := __aCpAuM29[nFor, 2] // Coloca o conteudo no campo
   
		cVar := StrTran(__aCpAuM29[nFor, 1], "M->", "") // Retira o "M->" p/ buscar o campo no dicionario
   
		If __aCpAuM29[nFor, 3] //Posicao 3 do array diz se o valid deve ser executado ou nao
			SX3->(DbSetOrder(2))
			SX3->(DbSeek(cVar)) 
    
			cValid := IIf(!Empty(SX3->X3_VALID)  , SX3->X3_VALID  , "")
			cValid += IIf(!Empty(SX3->X3_VLDUSER), ".And. " + SX3->X3_VLDUSER, "")
    
			If !Empty(cValid) .And. !&(cValid)// Se o Valid retornar Falso... retorna
				Return(.F.)
			EndIf
		EndIf
	End              
  
	__ReadVar := cReadVarOld
	RestArea(aAreaSX3)
	DbSelectArea(cAliasOld)
EndIf
 
oEnc:Refresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29Brw ³ Autor ³Paulo Emidio de Barros ³ Data ³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta a edicao para Ocupacao/Atendimento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29Brw(EXPO1,EXPN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do Folder                                   ³±±
±±³			 ³ EXPN1 = Fero do Folder                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPA1 = Objetos: Ocupacao/Atendimento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPM029Brw                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                 
Function HSPM29Brw(oTela,nFolder,oXPTO,oPnlBrw,cCpoEnc)//,aPnlGetDados)
Local aCampos := {}
Local aSize   := {}
Local bBlock
Local oBrwOcu
Local oGetAte

//Panel
oPnlFolder	       :=	tPanel():New(000,000,,oTela,,,,,,300,300)
oPnlBrw	           :=	tPanel():New(000,000,,oPnlFolder,,,,,,496,058)

oPnlFolder:Align   := CONTROL_ALIGN_ALLCLIENT
oPnlBrw:Align      := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a Ocupacao na Agenda                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {STR0030,STR0031,STR0026,STR0032,STR0033,STR0034,STR0035,STR0036,"Transferidos"} //"Dia" ### "Total" ### "Livre" ### "%Livre" ### "Hora" ### "Ocupada" ### "%Ocupada" #### "Indisponivel"
aSize   := {50,30,30,30,30,30,30,30}
bBlock  := {||Afill(Array(Len(aSize))," ")}
oBrwOcu := TwBrowse():New(000.3,000.4,496,058.5,bBlock,aCampos,aSize,oPnlBrw)
oBrwOcu:Align := CONTROL_ALIGN_ALLCLIENT
oBrwOcu:blDblClick:= {||FS_RestMem(),HSPM29Marca("1",oFolder,,@oBrwOcu)} //Marca o Agendamento pela Ocupacao
oBrwOcu:bChange:={||If(HSPM29VerHorEnc(nFldAtu),; //Verifica se o Horario foi informado, caso seja um Encaixe
					HSPM29SavAge(nFldAtu,nFldAtu,nDiaAgeAtu:=aOBJETOS[nFldAtu,1]:nAt,nDiaAgeAnt),; //Salva a marcacao Atual
					(aOBJETOS[nFldAtu,1]:nAt:=nDiaAgeAtu,aOBJETOS[nFldAtu,1]:Refresh())),;        //Define as novas posicoes no Vetor aAgenda
					HSPM29PaintCalend()}       

					
// Desabilita SX3 Obrigat
aHeaderGM8[5][17]:=.F.  // GM8_NOMPAC
aHeaderGM8[7][17]:=.F.  // GM8_CODPLA
aHeaderGM8[13][17]:=.F. // GM8_CODCRM
aHeaderGM8[15][17]:=.F. // GM8_CODPRO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os Horarios na Agenda                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetAte := Fs_MntGetD(@oPnlFolder, nFolder, , , , ,/*@aPnlGetDados*/,cCpoEnc)

Return({oBrwOcu,oGetAte})

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
Function HSPAHM29LEG()
Local aLegenda   := {}
Local cCadastro  := OemToAnsi(STR0001) //"Agenda Ambulatorial"

Aadd(aLegenda,{"BR_VERDE"   ,OemToAnsi(STR0026)}) //"Livre"
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0037)}) //"Agenda Ocupada"
Aadd(aLegenda,{"BR_PRETO"   ,OemToAnsi(STR0067)}) //"Encaixe Ocupado"
Aadd(aLegenda,{"BR_AMARELO" ,OemToAnsi(STR0038)}) //"Bloqueado"
Aadd(aLegenda,{"BR_PINK"    ,OemToAnsi(STR0062)}) //"Atendido"
Aadd(aLegenda,{"BR_AZUL"    ,OemToAnsi(STR0075)}) //"Ocupado/Bloqueado"
Aadd(aLegenda,{"BR_LARANJA" ,OemToAnsi(STR0080)}) //"Confirmado"
Aadd(aLegenda,{"BR_VIOLETA" ,OemToAnsi(STR0208)}) //"Em Conferencia"
Aadd(aLegenda,{"BR_BRANCO"  ,OemToAnsi(STR0209)}) //"Transferido"

BrwLegenda(cCadastro,STR0039,aLegenda)  //"Agendamento"

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29Navega³ Autor ³Paulo Emidio de Barros ³Data³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a Edicao da Agenda no Calendario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29Navega(EXPC1,EXPC2,EXPC3,EXPL1)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Incremento do Ano                                  ³±±
±±³          ³ EXPC2 = Incremento do Mes                                  ³±±
±±³          ³ EXPC3 = Incremento do Mes+Ano                              ³±±
±±³          ³ EXPL1 = Indica se o inicio ocorrera com a Data Base        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = .T. = Verdadeiro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM029                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                 
Static Function HSPM29Navega(cNavAno,cNavMesLst,cNavMesCal,lDataAtu,cObj)
Local cAno   := StrZero(Year(dDataBase),4)

Default cObj := "oMeses"

If cObj == "oMeses"
	If lDataAtu
		oCalend:dDiaAtu := dDataBase
		
		oMeses:nAt := Month(oCalend:dDiaAtu)
		oMeses:Refresh()
	
		cAno := StrZero(Year(oCalend:dDiaAtu),4)
	Else
	
		If cNavMesCal == "+"
			oMeses:nAt      := Month(oCalend:dDiaAtu)
			oMeses:Refresh()
			
			If Val(cAno) <> Year(oCalend:dDiaAtu)
				cAno := StrZero(Year(oCalend:dDiaAtu),4)
			EndIf
			
			oCalend:dDiaAtu := Ctod("01/"+StrZero(oMeses:nAt,2)+"/"+cAno)
		EndIf
		
		If cNavMesLst == "+"
			oCalend:dDiaAtu := Ctod("01/"+StrZero(oMeses:nAt,2)+"/"+cAno)
			oCalend:Refresh()
		EndIf
		                 
		If cNavAno <> NIL
			If cNavAno == "+"
				cAno := StrZero(Val(cAno)+1,4)
			ElseIf cNavAno == "-"
				cAno := StrZero(Val(cAno)-1,4)
			EndIf
			
			oCalend:dDiaAtu := Ctod("01/"+StrZero(oMeses:nAt,2)+"/"+cAno)
			oCalend:Refresh()
		EndIf
	EndIf
Else
	If lDataAtu
		oCalend:dDiaAtu := dDataBase
		oCal:dDiaAtu := dDataBase
	
		oMeses:nAt := Month(oCalend:dDiaAtu)
		oMeses:Refresh()
			
		oMesAno:nAt := Month(oCal:dDiaAtu)
		oMesAno:Refresh()
	    
		cAno := StrZero(Year(oCal:dDiaAtu),4)
	Else
	
		If cNavMesCal == "+"
			oMeses:nAt      := Month(oCalend:dDiaAtu)
			oMeses:Refresh()
			                
			oMesAno:nAt      := Month(oCal:dDiaAtu)
			oMesAno:Refresh()
			
			If Val(cAno) <> Year(oCal:dDiaAtu)
				cAno := StrZero(Year(oCal:dDiaAtu),4)
			EndIf
			     
			If oMeses:nAt == Month(dDataBase)
				oCalend:dDiaAtu := dDataBase
			Else
				oCalend:dDiaAtu := Ctod("01/"+StrZero(oMeses:nAt,2)+"/"+cAno)
			EndIf
			If oMesAno:nAt == Month(dDataBase)
				oCal:dDiaAtu := dDataBase
			Else
				oCal:dDiaAtu := Ctod("01/"+StrZero(oMesAno:nAt,2)+"/"+cAno)
			EndIf

		EndIf
		
		If cNavMesLst == "+"
			If oMeses:nAt == Month(dDataBase)
				oCalend:dDiaAtu := dDataBase
				oCalend:Refresh()
			Else
				oCalend:dDiaAtu := Ctod("01/"+StrZero(oMeses:nAt,2)+"/"+cAno)
				oCalend:Refresh()
			EndIf
			If oMesAno:nAt == Month(dDataBase)
				oCal:dDiaAtu := dDataBase
				oCal:Refresh()
			Else
				oCal:dDiaAtu := Ctod("01/"+StrZero(oMesAno:nAt,2)+"/"+cAno)
				oCal:Refresh()
			EndIf
		EndIf
		                 
		If cNavAno <> NIL
			If cNavAno == "+"
				cAno := StrZero(Val(cAno)+1,4)
			ElseIf cNavAno == "-"
				cAno := StrZero(Val(cAno)-1,4)
			EndIf
            
			If oMeses:nAt == Month(dDataBase)
				oCalend:dDiaAtu := dDataBase
				oCalend:Refresh()
			Else
				oCalend:dDiaAtu := Ctod("01/"+StrZero(oMeses:nAt,2)+"/"+cAno)
				oCalend:Refresh()
			EndIf
			If oMesAno:nAt == Month(dDataBase)
				oCal:dDiaAtu := dDataBase
				oCal:Refresh()
			Else
				oCal:dDiaAtu := Ctod("01/"+StrZero(oMesAno:nAt,2)+"/"+cAno)
				oCal:Refresh()
			EndIf

		EndIf
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a faixa de dias para o Agendamento                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lDataAtu := .F.

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29ConsFil³ Autor ³Paulo Emidio de Barros³Data³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza as consistencias necessarias para o Filtro         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29ConsFil()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = .T. = Verdadeiro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       | HSPAHM029                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                 
Function HSPM29ConsFil(cReadVar,cObsPlano ,cMemPrep  ,cObsProc,cObsProf ,aGM8,cFilAtu ,cFilAgeAtu,cCrmAtu,cDatAgeAtu,cHorAgeAtu ,cStatAtu ,cPri,oXPTO ,aPnl,cCpoEnc,cDisCons)
Local lRetorno  := .T., aRVldVig, cTpAgeEsc, cSQL := ""
//definicoes para chamar o extrato caso retorno Esteje na Carencia.
Local bCampoDia 	:= {|U| IIf(U == "A", aRVldVig	:= {{0, "GC1_NDIASR"},{"","GC1_HORRTA"}}, aRVldVig	:= {{0, "GC1_NDIASP"},{"","GC1_HORRTP"}})}
Local bTipoAgen 	:= {|U| IIf(U == "A", cTpAgeEsc := STR0093, cTpAgeEsc := STR0094)} //"Ambulatorio"###"Pronto Atendimento"
Local bSetaTpAg 	:= {|| Eval( bCampoDia, cTipoAg ), Eval( bTipoAgen, cTipoAg ) }
Local cQDisp    	:= ""  , lQDisp := .F.
Local cAliasOld 	:= ""

Local cGD4RegGer 	:= "" //Campo utilizado na consulta padrao GD4
Local nDiasRet 		:= 0 
Local nContDisp 	:= 0
Local aDispEx		:= {}

//Defaults necessarios porque a HSPM29ConsFil e chamada via X3_valid do campo GM8_NOMPAC
Default cReadVar 	 := ReadVar()
Default cObsPlano    := " "
Default cMemPrep     := " "
Default cObsProc     := " " 
Default cObsProf     := " "
Default cDisCons	 := ""
Default cCpoEnc      := "GM8_FILAGEßGM8_TELPACßGM8_OBSERVßGM8_MOTIVO"
Default	cFilAtu      := GM8->GM8_FILIAL
Default	cFilAgeAtu   := GM8->GM8_FILAGE
Default	cCrmAtu      := GM8->GM8_CODCRM
Default	cDatAgeAtu   := dTos(GM8->GM8_DATAGE)
Default	cHorAgeAtu   := GM8->GM8_HORAGE
Default	cStatAtu     := GM8->GM8_STATUS

Eval( bSetaTpAg )

If cReadVar == "M->GM8_CODPLA"
	GCM->(dbSetOrder(2)) // GCM_FILIAL + GCM_CODPLA
	
	If GCM->(lRetorno := dbSeek(xFilial("GCM")+M->GM8_CODPLA))
		M->GM8_DESPLA	:= GCM->GCM_DESPLA //Descricao do Plano
		cGCM_CODCON  	:= GCM->GCM_CODCON //Codigo do Convenio
		
		If !HS_FilPla()
			HS_MsgInf(STR0086, STR0077, STR0095) //"Plano Invalido!"###"Atenção"###"Consistencias necessarias para o Filtro"
			Return lRetorno := .F.
		Endif
		
		GCY->(DbSetOrder(2)) // GCY_FILIAL + GCY_REGGER + GCY_TPALTA
		If GCY->(DbSeek(xFilial("GCY") + M->GM8_REGGER))
			
			If !HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + M->GM8_CODPLA + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
				
				HS_MsgInf(STR0087, STR0077, STR0095) //"Nao existe data de vigencia para o plano"###"Atenção"###"Consistencias necessarias para o Filtro"
				Return lRetorno := .F.
				
			Endif
			
			nDiasRet := aRVldVig[1][1]
			cHorasRet := aRVldVig[2][1]
		Endif
		
		If !HS_VMatPla(M->GM8_MATRIC, M->GM8_CODPLA)
			Return lRetorno := .F.
		Endif
		
		GA9->(dbSetOrder(1)) // GA9_FILIAL + GA9_CODCON
		GA9->(dbSeek(xFilial("GA9")+GCM->GCM_CODCON))
		cObsPlano  := GA9->GA9_OBSERV //Observacao do Plano
		cGczCodPla := M->GM8_CODPLA
		
	Else
		HS_MsgInf(OemToAnsi(STR0068), STR0077, STR0095)   //"Plano não encontrado"###"Consistencias necessarias para o Filtro"
	EndIf
	
	If lRet := HS_VldPac(M->GM8_REGGER, M->GM8_CODPLA)
		M->GM8_SQCATP := GD4->GD4_SQCATP
		M->GM8_DSCATP := HS_IniPadr("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT",,.F.)
	Else
		Return(.F.)
	EndIf
	
	cGfvPlano := M->GM8_CODPLA
	
ElseIf cReadVar == "M->GM8_SQCATP"
	
	If !(lRet := HS_SeekRet("GFV","M->GM8_CODPLA + M->GM8_SQCATP", 1, .F., "GM8_DSCATP", "GFV_NOMCAT",,, .T.))
		HS_MsgInf(STR0113, STR0077, STR0095) //"Categoria não encontrada"###"Atenção"###"Consistencias necessarias para o Filtro"
		Return(.F.)
	ElseIf GFV->GFV_STATUS == "0"
		HS_MsgInf(STR0114, STR0077, STR0095) //"Categoria desativada para o plano" ###"Atenção"###"Consistencias necessarias para o Filtro"
		Return(.F.)
	EndIf
	  
ElseIf cReadVar == "M->GM8_MATRIC"
	lRetorno := HS_VMatPla(M->GM8_MATRIC, M->GM8_CODPLA)
	
ElseIf cReadVar == "M->GM8_CODSAL" .And. !Empty(M->GM8_CODSAL)
	If !(lRetorno := HS_SEEKRET('GF3', 'M->GM8_CODSAL', 1, .F., 'GM8_NOMSAL', 'GF3_DESCRI'))
		HS_MsgInf(STR0133, STR0077, STR0134) //"Atenção" //"Sala não encontrada"###"Validação da sala"
		
	ElseIf IIf(!Empty(M->GM8_CODPRO), !(lRetorno := HS_SEEKRET('GNC', 'M->GM8_CODSAL+M->GM8_CODPRO', 1, .F.,,)), .F.)
		HS_MsgInf(STR0135 + AllTrim(M->GM8_CODPRO) + "]", STR0077, STR0134) //"Atenção" //"A sala informada não permite a execução do procedimento ["###"Validação da sala"
		
	EndIf
	
ElseIf cReadVar == "M->GM8_CODPRO"	.And. !Empty(M->GM8_CODPRO)
	
	If !(lRetorno := !HS_LDesExc(HS_INIPADR("GCM", 2, M->GM8_CODPLA , "GCM_CODCON",, .F. ), M->GM8_CODPLA, "1", M->GM8_CODPRO, oCalend:dDiaAtu)[1])
		HS_MsgInf("Procedimento não possui cobertura do convênio.", STR0077, STR0095)   //"Atenção"###"Consistencias necessarias para o Filtro"
		
	ElseIf !(lRetorno := HS_SEEKRET('GA7', 'M->GM8_CODPRO', 1, .F., {'GM8_DESPRO','GM8_DURACA'}, {'GA7_DESC','GA7_TEMPRO'}))
		HS_MsgInf(OemToAnsi(STR0069), STR0077, STR0095)   //"Procedimento não encontrado"###"Atenção"###"Consistencias necessarias para o Filtro"
		
	ElseIf IIf(!Empty(M->GM8_CODSAL), !(lRetorno := HS_SEEKRET('GNC', 'M->GM8_CODSAL+M->GM8_CODPRO', 1, .F.,,)), .F.)
		HS_MsgInf(STR0136 + AllTrim(M->GM8_CODSAL) + "]", STR0077, STR0137) //"Atenção" //"O Procedimento informado não é permitido na sala ["###"Validação do procedimento"
		
	ElseIf IIf(!Empty(M->GM8_REGGER), !(lRetorno := HS_SEEKRET('GBH', 'M->GM8_REGGER', 1, .F.,,)), .F.)
		HS_MsgInf(STR0138 + AllTrim(M->GM8_REGGER) + STR0139, STR0077, STR0137) //"Atenção" //"Prontuário ["###"] não encontrado"###"Validação do procedimento"
		
	ElseIf IIf(!Empty(M->GM8_REGGER), !(lRetorno := HS_VldISPr(M->GM8_CODPRO, GBH->GBH_DTNASC, GBH->GBH_SEXO)), .F.)
		//Valida o Procedimento de acordo com a Idade/Sexo
		
	ElseIf !(lRetorno := HS_SEEKRET('GCS', 'cGcsCodLoc + M->GM8_CODPRO', 1, .F.,,))
		HS_MsgInf(STR0140 + cGcsCodLoc + "]", STR0077, STR0095) //"Atenção"###"Consistencias necessarias para o Filtro" //"Procedimento não permitido no setor ["
		
	EndIf
	
	If !Empty(M->GM8_CODCRM)
		HSPM29ConsFil("M->GM8_CODCRM",@cObsPlano,@cMemPrep,@cObsProc,@cObsProf,/*@aColsGM8*/ ,cFilAtu         ,cFilAgeAtu      ,cCrmAtu        ,cDatAgeAtu           ,cHorAgeAtu      ,cStatAtu       ,/*cPriDia*/,/*oPnlFolder*/,/*@aPnlGetDados*/,cCpoEnc,cDisCons)
	EndIf
	
	
	//EXECUTAR A FUNCAO QUE VALIDA SE E UMA NOVA CONSULTA OU UM RETORNO
	FS_HorAge()
	M->GM8_DESPRO	:=	GA7->GA7_DESC
	cObsProc      	:= GA7->GA7_OBSERV //Observacao do Procedimento
	cMemPrep 		:= 	FS_RetPrep(M->GM8_CODPRO)
	cGbjCodEsp	   	:=	GA7->GA7_CODESP //Especialidade do Procedimento
	
ElseIf cReadVar == "M->GM8_REGGER"
	
	GBH->(dbSetOrder(1)) //GBH_FILIAL + GBH_CODPAC
	If GBH->(lRetorno := dbSeek(xFilial("GBH")+M->GM8_REGGER))
		M->GM8_TELPAC := GBH->GBH_TEL  //Telefone do Usuario
		M->GM8_NOMPAC := GBH->GBH_NOME //Nome do Paciente
		M->GM8_CODPRO := SPACE(LEN(GM8->GM8_CODPRO))
		cGD4RegGer    := M->GM8_REGGER
		
		//Retorna o Codigo do Convenio Principal no Plano
		GD4->(dbSetOrder(2)) // GD4_FILIAL + GD4_REGGER + GD4_IDPADR
		GD4->(dbSeek(xFilial("GD4")+M->GM8_REGGER+"1"))
		
		If GD4->(!Eof())
			M->GM8_CODPLA := GD4->GD4_CODPLA
			cGczCodPla    := M->GM8_CODPLA
			
			If HS_VldPac(M->GM8_REGGER)
				M->GM8_SQCATP := GD4->GD4_SQCATP
				M->GM8_DSCATP := HS_IniPadr("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT",,.F.)
			Else
				Return(.F.)
			EndIf
			
			M->GM8_MATRIC := GD4->GD4_MATRIC
			GCM->(dbSetOrder(2)) // GCM_FILIAL + GCM_CODPLA
			GCM->(dbSeek(xFilial("GCM")+M->GM8_CODPLA))
			M->GM8_DESPLA := GCM->GCM_DESPLA //Descricao do Plano
			cGCM_CODCON  	:= GCM->GCM_CODCON //Codigo do Convenio
			
			HSPM29ConsFil("M->GM8_CODPLA",@cObsPlano,@cMemPrep,@cObsProc,@cObsProf,/*@aColsGM8*/ ,cFilAtu         ,cFilAgeAtu      ,cCrmAtu        ,cDatAgeAtu           ,cHorAgeAtu      ,cStatAtu       ,/*cPriDia*/,/*oPnlFolder*/,/*@aPnlGetDados*/,cCpoEnc,cDisCons)
		EndIf
		
		HSPM29Filtro(2,,,,,/*@aColsGM8*/,cFilAtu,cFilAgeAtu,cCrmAtu,cDatAgeAtu,cHorAgeAtu,cStatAtu,/*cPriDia*/,/*oPnlFolder*/,/*@aPnlGetDados*/,cCpoEnc) //chama a rotina para preencher os horarios agendados futuros

	Else
		HS_MsgInf(OemToAnsi(STR0070), STR0077, STR0095)   //"Prontuário não encontrado."###"Atenção"###"Consistencias necessarias para o Filtro"
	EndIf
	/* validacao referente a prontuarios externos SAME-SPP */
	GSB->(DbSetOrder(1)) //GSB_FILIAL + GSB_REGGER + GSB_CODEND
	GSB->(DbSeek(xFilial("GSB") + M->GM8_REGGER))
	WHILE GSB->(!Eof()) .And. GSB->(GSB_FILIAL) == xFilial("GSB") .And. GSB->(GSB_REGGER) == M->GM8_REGGER
		GSD->(DbSetOrder(1)) // GSD_FILIAL + GSD_CODEND + GSD_TIPEND
		If GSD->(DbSeek(xFilial("GSD") + GSB->(GSB_CODEND))  )
			If GSD->(GSD_ARQEXT) == "1"
				HS_MsgInf(STR0096 + GSB->(GSB_CODEND) + STR0097 + Str(GSD->(GSD_DIASEN), 2, 0) + STR0098, STR0077, STR0099) //"O Paciente possui Prontuario com Endereco "###" Externo, o prazo para entrega das fichas e de: "###" dias."###"Atenção"###"SPP-SERVICO DE PROTECAO AO PRONTUARIO"
			EndIf
		EndIf
		GSB->(DBSKIP())
	END
	
Elseif cReadVar == "M->GM8_NOMPAC"
	
	If !Empty(cGbhCodPac)
		M->GM8_REGGER := cGbhCodPac
		HSPM29ConsFil("M->GM8_REGGER",@cObsPlano,@cMemPrep,@cObsProc,@cObsProf,/*@aColsGM8*/ ,cFilAtu         ,cFilAgeAtu      ,cCrmAtu        ,cDatAgeAtu           ,cHorAgeAtu      ,cStatAtu       ,/*cPriDia*/,/*oPnlFolder*/,/*@aPnlGetDados*/,cCpoEnc,cDisCons)
	EndIf
	
ElseIf cReadVar == "M->GM8_CODCRM"

	If Empty(cGbjCodEsp) .AND. FunName() == "HSPAHMA7"
		cGbjCodEsp :=	HS_IniPadr("GA7", 1, M->GM8_CODPRO, "GA7_CODESP",, .F.)//GA7->GA7_CODESP
	EndIf
	
	DbSelectArea("GBJ")
	DbGoTop()
	dbSetOrder(1) // GBJ_FILIAL + GBJ_CRM
	If (lRetorno := dbSeek(xFilial("GBJ")+M->GM8_CODCRM))
		cObsProf := GBJ->GBJ_OBSERV //Observacao do Profissional

		If HS_IniPadr("GBJ", 1, M->GM8_CODCRM, "GBJ_IDAGEN",, .F.) $ " /1"     //NENHUM/CIRUR.
			HS_MsgInf(STR0084, STR0077,STR0100)   //"CRM do Medico Invalido! Médico não habilitado para incluir uma disponibilidade."###"Atencao"###"Disponibilidade Medica"
			Return lRetorno := .F.
			
		ElseIf !Empty(M->GM8_CODPRO) .And. !(cGbjCodEsp $ HS_REspMed(M->GM8_CODCRM))
			HS_MsgInf(STR0085, STR0077, STR0101) //"Médico Inválido! Verifique a especialidade do médico e do procedimento."###"Atenção"###"Especialidade Medica"
			Return lRetorno := .F.
			
		Endif
		
		cCodCrmAnt :=M->GM8_CODCRM
		
		If lQDisp
			dbSelectArea("TMPDISP")
			dbCloseArea()
		EndIf
		
		
		If Empty(cCodDis)
			cAliasOld := Alias()
			lQDisp := .T.
			cQDisp := "SELECT DISTINCT GM6_CODDIS,GM6_DESDIS FROM    "+RetSqlName("GM6") + " GM6 "
			cQdisp += " JOIN "+RetSqlName("GM8") + " GM8 ON GM8.GM8_CODDIS = GM6.GM6_CODDIS AND "
			cQdisp += " GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND GM8.GM8_FILAGE = '"+M->GM8_FILAGE+"' AND "
			cQdisp += " GM8.GM8_STATUS != '2' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_DATAGE >= '" +dTos(dDataBase) + "' "
			cQDisp += " WHERE GM6.GM6_FILIAL = '"+xFilial("GM6")+"' AND GM6.GM6_CODCRM = '"+M->GM8_CODCRM+"' AND "
			cQDisp += " GM6.D_E_L_E_T_ <> '*' "
			cQDisp := ChangeQuery(cQDisp)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDisp),"TMPDISP",.F.,.T.)
			
			dbSelectArea("TMPDISP")
			
			While TMPDISP->(!Eof())
				nContDisp +=  1
				AADD(aDispEx,{TMPDISP->GM6_CODDIS,TMPDISP->GM6_DESDIS})
				TMPDISP->(DbSkip())
			End
			
			DbGoTop()
			If TMPDISP->(!Eof())
				If nContDisp > 1
					If FunName() <> "HSPAHMA7" .AND.  Type("cDisCons") <> "U" .AND. !Empty(cDisCons)
						cCodDis := cDisCons
					Else
						cDisp := ""
						If MsgYesNo(STR0149, STR0077)  // "Profissional possui mais de uma disponibilidade, deseja seleciona-la? " HS_MsgInf(STR0148,STR0077, STR0095)
							cCodDis := FS_SelDisp(aDispEx)
						Else
							dbCloseArea()
							dbSelectArea(cAliasOld)
							Return lRetorno := .F.
						EndIf
					EndIf
				Else
					cCodDis := TMPDISP->GM6_CODDIS
				EndIf
			EndIf
			dbCloseArea()
			dbSelectArea(cAliasOld)   
		EndIf
		SRA->(DbSetOrder(11)) // RA_FILIAL + RA_CODIGO
		If SRA->(DbSeek(xFilial("SRA")+M->GM8_CODCRM))
			M->GM8_NOMCRM := SRA->RA_NOME
		EndIf
		
		lRetorno := HS_ProMed(M->GM8_CODCRM, M->GM8_CODPRO, M->GM8_REGGER, nDiasRet,,cHorasRet, GM8->GM8_CODLOC) 
		
		If ValType(lRetorno) == "A" 
			lRetorno := lRetorno[2]
		Endif 
		
	Else
		HS_MsgInf(OemToAnsi(STR0071), STR0077, STR0095)   //"CRM não encontrado"###"Atenção"###"Consistencias necessarias para o Filtro"
	Endif
EndIf

//Verifica o preenchimento dos campos utilizados no filtro
If cReadVar <> "M->GM8_REGGER" .And. !Empty(M->GM8_FILAGE) .And. !Empty(M->GM8_CODPLA) .And. !Empty(M->GM8_CODPRO) .And. !Empty(M->GM8_CODCRM) .And. nOpcSav <> 5
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso tenha algum horario marcado Desbloqueia                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cReadVar == "M->GM8_CODCRM"
		FS_UnLock(nFldAtu, nDiaAgeAtu)
	EndIf
	
	//Filtra o Agendamento e passa o nOpc como nOpcSav, porque a funcao possui chamada no SX3
	HSPM29Filtro(nOpcSav,.F.    ,       ,       ,         ,/*@aColsGM8*/,cFilAtu,cFilAgeAtu     , cCrmAtu,        cDatAgeAtu,             cHorAgeAtu,     cStatAtu,/*cPriDia*/,/*oPnlFolder*/,/*@aPnlGetDados*/,cCpoEnc)
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29Filtro ³ Autor ³Paulo Emidio de Barros³Data³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra o Agendamento                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29Filtro(EXPN1,EXPL1)                                  ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina                                   ³±±
±±³          ³ EXPL1 = Indica se o Filtro sera acionado somente no regis- ³±±
±±³          ³         tro corrente.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM029                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29Filtro(nOpc   ,lRegAtu,lRes800,oPanel2,oFont   ,aGM8,cFilAtu        ,cFilAgeAtu      ,cCrmAtu         ,cDatAgeAtu            ,cHorAgeAtu     ,cStatAtu       ,cPri,oXPTO         ,aPnl,cCpoEnc)
Local aAreaAnt   := GetArea()
Local aAreaGM8   := GM8->(GetArea())
Local nPosAge    := 0, nIteAge := 0
Local nIteRec    := 0
Local nPosCpo    := 0
Local nPosDia    := 0
Local nPosAgeAnt := 0
Local nPosGD1    :=0
Local lContinua  := .T.
Local lQuery     := .F.
Local lRecEnc    := .F.      
Local cChave     := " "
Local cQuery     := " "
Local cRecurso   := ""
Local bWhile 
Local dInicio    := FirstDay(IIf(!Empty(cPriDia), cPriDia, oCalend:dDiaAtu))
Local dFinal     := LastDay(dInicio)
Local aRecursos  := Hs_RetRec(cCodDis,,,.T.)     
Local lTemRec    := !Empty(aRecursos[1])
Local aColsAux   := {}
Local aStruGM8   := {}
Local aCRec      := {{},{}} //Array com com agendamentos por recurso                            

Private cAliasGM8 := "GM8"
                       
// Essa condição serve para impedir que essa função seja executada mais de uma vez ao mesmo tempo
If lExecFilt
 Return(Nil)
Else
 lExecFilt := .T. 
EndIf   

CursorWait()
                 
If !Empty(cPriDia)
 oCalend:dDiaAtu := cPriDia
 oMeses:nAt      := Month(cPriDia)
EndIf
                
aAgenda := Array(2) //Inicia o vetor para a Agenda
Aeval(aAgenda,{|x,y|aAgenda[y]:={{},{}}})                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera os Controles referentes a ultima marcacao de Horario ou ³
//³ Encaixe.													                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLastFld  := 0 
nLastDay  := 0 
nLastHour := 0  
nLastRec  := 0
aLastMar  := {}

If nOpc == 2 //Agendar
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Inicia o Browse com oS registros da Agenda Futuras          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 aTrfHorAge := {} //zera o vetor de dados agendados para preencher novamente
 HSPM29IniTrf(.F.,nOpc,lRes800,@oPanel2,oFont) 
EndIf 

If !Empty(M->GM8_FILAGE) .And. !Empty(M->GM8_CODPLA) .And. !Empty(M->GM8_CODPRO) .And. !Empty(M->GM8_CODCRM)
                                            
	If nOpc == 2 //Agendar se ja tem campos preenchidos
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³ Inicia o Browse com oS registros da Agenda Futuras          ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  aTrfHorAge := {} 
  HSPM29IniTrf(.F.,nOpc,lRes800,@oPanel2,oFont) 
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Inicia o Browse com o registro da Agenda a ser transferido   ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf (lRegAtu .And. nOpc==4 ) 
		HSPM29IniTrf(.F.,nOpc,lRes800,@oPanel2,oFont)
		lRegAtu := .F.
	EndIf                       

	//Executa o Filtro somente no registro posicionado
	If lRegAtu 
		cChave := ( cFilAtu+cFilAgeAtu+cCrmAtu+cDatAgeAtu+cHorAgeAtu+cStatAtu )
		bWhile := {||GM8->(GM8_FILIAL+GM8_FILAGE+GM8_CODCRM+dTos(GM8_DATAGE)+GM8_HORAGE+GM8_STATUS) == cChave .And. GM8->(!Eof())}
	Else
		cChave := xFilial("GM8")+M->GM8_FILAGE+M->GM8_CODCRM+dTos(dInicio)
		bWhile := {||GM8->(GM8_FILIAL+GM8_FILAGE+GM8_CODCRM) == (xFilial("GM8")+M->GM8_FILAGE+M->GM8_CODCRM) .And. ;
		           		     (GM8->GM8_DATAGE >= dInicio .And. GM8->GM8_DATAGE <= dFinal) .And. GM8->(!Eof())}
	EndIf
	
	#IFDEF TOP
	 If TCSrvType() <> "AS/400"
	 	bWhile := {||!Eof()}                             
		 cAliasGM8 := "QRYGM8"
		 // Incluir neste array todos os campos do tipo data contidos na select
		 aStruGM8  := {"GM8_DATAGE"}
		 lQuery    := .T.
		 dbSelectArea("GM8")
		 //dbSetOrder(4)   // GM8_FILIAL + GM8_FILAGE + GM8_CODCRM + GM8_DATAGE + GM8_HORAGE + GM8_STATUS
        dbSetOrder(5)
		
		 cQuery := "SELECT "
		 cQuery += "GM8.GM8_FILIAL GM8_FILIAL, "
		 cQuery += "GM8.GM8_DATAGE GM8_DATAGE, "
		 cQuery += "GM8.GM8_HORAGE GM8_HORAGE, "
		 cQuery += "GM8.GM8_FILAGE GM8_FILAGE, "
		 cQuery += "GM8.GM8_REGGER GM8_REGGER, "
		 cQuery += "GM8.GM8_MATRIC GM8_MATRIC, "
		 cQuery += "GM8.GM8_NOMPAC GM8_NOMPAC, "
		 cQuery += "GM8.GM8_TELPAC GM8_TELPAC, " 
		 cQuery += "GM8.GM8_CODPLA GM8_CODPLA, "
		 cQuery += "GCM.GCM_DESPLA GM8_DESPLA, "
		 cQuery += "GM8.GM8_SQCATP GM8_SQCATP, "
		 cQuery += "GFV.GFV_NOMCAT GM8_DSCATP, "
		 cQuery += "GM8.GM8_CODPRO GM8_CODPRO, "
		 cQuery += "GA7.GA7_DESC   GM8_DESPRO, "
		 cQuery += "GM8.GM8_CODCRM GM8_CODCRM, "
		 cQuery += "SRA.RA_NOME    GM8_NOMCRM, "
		 cQuery += "GM8.GM8_STATUS GM8_STATUS, "
		 cQuery += "GM8.GM8_CODLOC GM8_CODLOC, "
		 cQuery += "GM8.GM8_CODDIS GM8_CODDIS, "
		 cQuery += "GM6.GM6_DESDIS GM8_DESDIS, "
		 cQuery += "GM6.GM6_HORINI GM8_HORINI, "
         cQuery += "GM6.GM6_HORFIM GM8_HORFIN, "
		 cQuery += "GM8.GM8_CODAGE GM8_CODAGE, "
		 cQuery += "GM8.GM8_CODCON GM8_CODCON, "
		 cQuery += "GM8.GM8_MOTIVO GM8_MOTIVO, "
		 cQuery += "GM8.GM8_TIPAGE GM8_TIPAGE, "
		 cQuery += "GM8.GM8_ORICAN GM8_ORICAN, "
		 cQuery += "GM8.GM8_CODSAL GM8_CODSAL, "		                                               
		 cQuery += "GM8.GM8_CODREC GM8_CODREC, "
		 cQuery += "GM6.GM6_INTMAR GM6_INTMAR, " 		                                               		 
		 cQuery += "GM6.GM6_QTENCX GM6_QTENCX  " 		                                               		 
		 cQuery += "FROM       "+RetSqlName("GM8") + " GM8 " 
		 cQuery += " JOIN      "+RetSqlName("GM6") + " GM6 ON GM8.GM8_CODDIS = GM6.GM6_CODDIS AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.D_E_L_E_T_ <> '*' "
		 cQuery += " JOIN      "+RetSqlName("SRA") + " SRA ON GM8.GM8_CODCRM = SRA.RA_CODIGO AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
		 cQuery += " JOIN      "+RetSqlName("GM3") + " GM3 ON GM3.GM3_FILIAL = '" + xFilial("GM3") + "' AND GM3.D_E_L_E_T_ <> '*' AND GM8.GM8_CODDIS = GM3.GM3_CODDIS AND GM3.GM3_CODPRO = '" + M->GM8_CODPRO + "' "
		 cQuery += " JOIN      "+RetSqlName("GM2") + " GM2 ON GM2.GM2_FILIAL = '" + xFilial("GM2") + "' AND GM2.D_E_L_E_T_ <> '*' AND GM8.GM8_CODLOC = GM2.GM2_CODLOC AND GM2.GM2_CODPRO = '" + M->GM8_CODPRO + "' "
		 cQuery += " LEFT JOIN "+RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GM8.GM8_CODPLA = GCM.GCM_CODPLA "
		 cQuery += " LEFT JOIN "+RetSqlName("GFV") + " GFV ON GFV.GFV_FILIAL = '" + xFilial("GFV") + "' AND GFV.D_E_L_E_T_ <> '*' AND GM8.GM8_SQCATP = GFV.GFV_ITEPLA AND GM8.GM8_CODPLA = GFV.GFV_CODPLA "
		 cQuery += " LEFT JOIN "+RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GM8.GM8_CODPRO = GA7.GA7_CODPRO "
		 cQuery += " WHERE "
		  cQuery += "NOT EXISTS (SELECT GM4.GM4_CODDIS FROM " + RetSqlName("GM4") + " GM4 WHERE GM4.GM4_FILIAL = '" + xFilial("GM4") + "' AND GM4.D_E_L_E_T_ <> '*' AND GM4.GM4_CODDIS = GM8.GM8_CODDIS AND GM4.GM4_CODPLA = '" + M->GM8_CODPLA + "') AND "
			cQuery += "NOT EXISTS (SELECT GM0.GM0_CODLOC FROM " + RetSqlName("GM0") + " GM0 WHERE GM0.GM0_FILIAL = '" + xFilial("GM2") + "' AND GM0.D_E_L_E_T_ <> '*' AND GM0.GM0_CODLOC = GM8.GM8_CODLOC AND GM0.GM0_CODPLA = '" + M->GM8_CODPLA + "') AND "
			If lRegAtu              
			 cQuery += "GM8.GM8_FILIAL = '"+cFilAtu+"' AND "    
			 cQuery += "GM8.GM8_FILAGE = '"+cFilAgeAtu+"' AND "
			 cQuery += "GM8.GM8_CODCRM = '"+cCrmAtu+"' AND "
			 cQuery += "GM8.GM8_DATAGE = '"+cDatAgeAtu+"' AND "
			 cQuery += "(GM8.GM8_CODAGE = '"+M->GM8_CODAGE+"' OR GM8.GM8_AGDPRC = '"+M->GM8_CODAGE+"') AND "
			 cQuery += "GM8.GM8_STATUS = '"+cStatAtu+"' " 
   		 	 cQuery += "AND GM8.GM8_CODDIS = '"+ cCodDis +"' "   
		 Else
			 cQuery += "GM8.GM8_FILIAL = '"+xFilial("GM8")+"' AND "
			 cQuery += "GM8.GM8_FILAGE = '"+M->GM8_FILAGE+"' AND "
			 cQuery += "GM8.GM8_CODCRM = '"+M->GM8_CODCRM+"' AND "
			 If dInicio <= dDataBase
			  dInicio := dDataBase
			 EndIf                                                                                   
			 cQuery += "GM8.GM8_STATUS != '2' AND " 
			 cQuery += "GM8.GM8_DATAGE >= '" +dTos(dInicio)+"' AND "
			 cQuery += "GM8.GM8_DATAGE <= '" +dTos(dFinal)+"' "
			 cQuery += "AND GM8.GM8_CODDIS = '"+ cCodDis +"' "   
		 EndIf
		 cQuery    += "AND GM8.D_E_L_E_T_ <> '*' "
//   		 cQuery    += " ORDER BY "+SqlOrder(GM8->(IndexKey()))
		 cQuery    += " ORDER BY GM8_FILIAL,GM8_FILAGE,GM8_DATAGE,GM8_CODDIS,GM8_CODSAL,GM8_TIPAGE,GM8_CODREC,GM8_CODAGE "
		 cQuery    := ChangeQuery(cQuery)

		 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGM8,.F.,.T.)
		 For nPosCpo := 1 To Len(aStruGM8)
			 TcSetField(cAliasGM8, aStruGM8[nPosCpo], "D", 8, 0)
		 Next nPosCpo
		 dbSelectArea(cAliasGM8)    
	 Else
	#ENDIF                 
   cAliasGM8 := "GM8"
 	 dbSelectArea("GM8")
		 dbSetOrder(4)  //// GM8_FILIAL + GM8_FILAGE + GM8_CODCRM + GM8_DATAGE + GM8_HORAGE + GM8_STATUS   
		 dbSeek(cChave,.T.) 
	#IFDEF TOP  
	 EndIf
	#ENDIF

	While (cAliasGm8)->(Eval(bWhile))
	        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contabiliza a Ocupacao                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    lTemRec   := IIF(lTemRec, lTemRec .And. !Empty((cAliasGm8)->GM8_CODREC), !Empty((cAliasGm8)->GM8_CODREC))	 
		aRecursos := IIF( Empty(IIF(Empty(cCodRec).And. lTemRec ,cCodRec := SubStr(aRecursos[1],1,6), SubStr(aRecursos[1],1,6))), Hs_RetRec(cCodDis := (cAliasGm8)->GM8_CODDIS,,,.T.), aRecursos)  
		If lContinua
  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtro do Tipo da Agenda                                     ³
			//³ 0 = Agenda Normal 1 = Encaixe                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosAge := If((cAliasGm8)->GM8_TIPAGE=="0",1,2)

			If (nIteAge := aScan(aAgenda[nPosAge, 1], {| aVet | aVet[1] == (cAliasGm8)->GM8_DATAGE})) == 0 //lAgenda
				
	   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena o ultimo registro do agendamento, quando a opcao for³
				//³ igual a: Cancelar, Transferir ou Alterar.                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nOpc==3 .Or. nOpc==5)//(nOpc==3 .Or. nOpc==4 .Or. nOpc==5)
					nLastFld  := nPosAge 
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ aAgenda[1,x,1] = Data da Ocupacao							 ³
				//³ 	   [1,x,2] = Total                                       ³
				//³ 	   [1,x,3] = Quantidade Livre                            ³
				//³ 	   [1,x,4] = Porcentagem Quantidade Livre                ³
				//³ 	   [1,x,5] = Primeiro Horario Disponivel                 ³
				//³ 	   [1,x,6] = Quantidade Ocupada                          ³
				//³ 	   [1,x,7] = Porcentagem da Quantidade Ocupada           ³
				//³ 	   [1,x,8] = Quantidade Indisponivel                     ³
				//³ 	   [1,x,9] = Quantidade Transferida                      ³
				//³ 	   [2,x,n] = GetDados do Agendamento no GM8              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Aadd(aAgenda[nPosAge,1],{Ctod(""), 0, 0, 0, " ", 0, 0, 0, 0})
				Aadd(aAgenda[nPosAge,2],{})
					
				nIteAge := Len(aAgenda[nPosAge,1])
	   			aAdd(aCRec[nPosAge],{})         
			    cRecurso := ""
			    lRecEnc  := .F.
			    nIteRec := Len(aCRec[nPosAge])  
			    nPosAgeAnt := nPosAge
	  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena o ultimo registro do agendamento, quando a opcao for³
				//³ igual a: Cancelar, Transferir ou Alterar.                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nOpc==3 .Or. nOpc==5)//(nOpc==3 .Or. nOpc==4 .Or. nOpc==5)
					nLastDay  := Len(aAgenda[nPosAge,1]) 
				EndIf
					
			EndIf
				
			//Dia para o Agendamento
			aAgenda[nPosAge,1,nIteAge,1] := (cAliasGm8)->GM8_DATAGE 
		
			//Quantidade Total
			aAgenda[nPosAge,1,nIteAge,2]++
				
		 	//Horario Disponivel
			aAgenda[nPosAge,1,nIteAge,3] += If((cAliasGm8)->GM8_STATUS $ "0/8",1,0) 
			
			//Primeiro Horario Disponivel
			aAgenda[nPosAge,1,nIteAge,5] := If(Empty(aAgenda[nPosAge,1,nIteAge,5]) .And. (cAliasGm8)->GM8_STATUS=="0",(cAliasGm8)->GM8_HORAGE,aAgenda[nPosAge,1,nIteAge,5]) 
					
		 	//Quantidade Ocupada
			aAgenda[nPosAge,1,nIteAge,6] += If((cAliasGm8)->GM8_STATUS $ "1/3/4/5",1,0) 
			
		 	//Quantidade Indisponivel
			aAgenda[nPosAge,1,nIteAge,8] += If((cAliasGm8)->GM8_STATUS=="2",1,0) 

		 	//Quantidade Transferida
			aAgenda[nPosAge,1,nIteAge,9] += If((cAliasGm8)->GM8_STATUS=="8",1,0) 
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preenche a Agenda a ser exibida na GetDados.                 ³
			//³ Cria os campos virtuais sem atualizar as variaveis publicas, ³
			//³ pois existem campos que sao editados na Enchoice e Getdados. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If lTemRec    
				If nPosAgeAnt <> nPosAge
			   		cRecurso := ""
			 	EndIf
			 	
				//Grid Recurso   //
	   			If (cRecurso # (cAliasGm8)->GM8_CODREC) .Or. (!lRecEnc .And. (cAliasGm8)->GM8_HORAGE = "  :  " .And. nPosAgeAnt <> nPosAge .And. aScan(aCRec[nPosAge][1][len(aCRec[nPosAge])],{|aVet|   Substr(aVet,1,TamSx3("GNZ_CODREC")[1]) == (cAliasGm8)->GM8_CODREC})== 0 )  
	   			   	nPosGD1 := aScan(aRecursos   , {| aVet |  Substr(aVet,1,TamSx3("GNZ_CODREC")[1]) == (cAliasGm8)->GM8_CODREC})
	   			   	If nPosGD1 >0 	   			   
	    				aAdd(aCRec[nPosAge, nIteRec], {aRecursos[aScan(aRecursos,{|aVet|   Substr(aVet,1,TamSx3("GNZ_CODREC")[1]) == (cAliasGm8)->GM8_CODREC})]})
	    			Else
	    					aAdd(aRecursos,(cAliasGm8)->GM8_CODREC +"-" + HS_IniPadr("GNZ", 1, (cAliasGm8)->GM8_CODREC, "GNZ_DESREC",, .F.))
	    					aAdd(aCRec[nPosAge, nIteRec], {aRecursos[aScan(aRecursos,{|aVet|   Substr(aVet,1,TamSx3("GNZ_CODREC")[1]) == (cAliasGm8)->GM8_CODREC})]})
	    			Endif
     				nLastRec := Len(aCRec[nPosAge, nIteRec])//aScan(aRecursos,{|aVet|   Substr(aVet,1,TamSx3("GNZ_CODREC")[1]) == (cAliasGm8)->GM8_CODREC})
     				cRecurso := (cAliasGm8)->GM8_CODREC            
	    		   	lRecEnc  := IIF((cAliasGm8)->GM8_HORAGE = "  :  ",.T.,.F.)
	    		   	nPosAgeAnt := nPosAge
	   			EndIf                                   
	     
	   			aAdd(aCRec[nPosAge, nIteRec, len(aCRec[nPosAge, nIteRec])],HSPM29SitAge())      //Status Agenda
	   			aAdd(aCRec[nPosAge, nIteRec, len(aCRec[nPosAge, nIteRec])], (cAliasGm8)->GM8_HORAGE)
			Else			
		   		aColsAux := {}				
		   		#IfDEF TOP
  					aEval(aHeaderGM8, {|x, y| aAdd(aColsAux, &(FieldName(FieldPos(aHeaderGM8[y,2]))))})
				#ELSE 
		   			aEval(aHeaderGM8, {|x, y| Aadd(aColsAux, IIf(aHeaderGM8[y,10] <> "V", &(FieldName(FieldPos(aHeaderGM8[y,2]))), CriaVar(AllTrim(aHeaderGM8[y,2]), .T.,, .F.)))})
				#ENDIF
		 		Aadd(aColsAux,.F.)                                                
		 		aColsAux[nStatus]:= HSPM29SitAge()
				Aadd(aAgenda[nPosAge,2,Len(aAgenda[nPosAge,2])],aClone(aColsAux))
			EndIf                                       
				
  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena o ultimo registro do agendamento, quando a opcao for³
			//³ igual a: Cancelar, Transferir ou Alterar.                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nOpc==3 .Or. nOpc==5)//(nOpc==3 .Or. nOpc==4 .Or. nOpc==5)
				If lTemRec
			  		nLastHour := Len(aCRec[nPosAge, nIteRec, len(aCRec[nPosAge, nIteRec])])
				Else 
					nLastHour := Len(aAgenda[nPosAge,2,Len(aAgenda[nPosAge,2])])
				EndIf
				
				If HSPM29SitAge() # "BR_CINZA"
     				aAdd(aLastMar, {(cAliasGm8)->GM8_CODAGE, nLastFld, nLastDay, nLastHour, nLastRec})
    			EndIf 
			EndIf
				
			If nPosAge > 0	             
			   	//Porcentagem da Quantidade Livre
    			aAgenda[nPosAge,1,nIteAge,4] := Round((aAgenda[nPosAge,1,nIteAge,3]/aAgenda[nPosAge,1,nIteAge,2])*100,2)
			    
				//Porcentagem da Quantidade Ocupada    
				aAgenda[nPosAge,1,nIteAge,7] := Round((aAgenda[nPosAge,1,nIteAge,6]/aAgenda[nPosAge,1,nIteAge,2])*100,2)
			EndIf
		EndIf 
		
		DbSkip()			
	EndDo
EndIf

If lTemRec  
	aAgenda[1][2] := aClone(aCRec[1])      
	aAgenda[2][2] := aClone(aCRec[2])   
EndIf
 
// Posicion a no folder principal ou no folder de Encaixe se for um encaixe
If cPriHor == "  :  " 
	oFolder:nOption := 2
	nFldAtu := 2
Else
	oFolder:nOption := 1
	nFldAtu := 1
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a Visualizacao das Ocupacoes e Agendamentos         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval(aAgenda,{|x,y| If(Len(x[2]) == 0,(Aadd(x[1],{Ctod(""),0,0,0," ",0,0,0,0}), Aadd(x[2],IIF(lTemRec,{{"","","  :  ", .F.}},aClone(aColsGM8)))),NIL)})
Aeval(aOBJETOS,{|x,y|aOBJETOS[y,1]:SetArray(aAgenda[y,1])})

Aeval(aOBJETOS[nFldAtu],{|x|x:nAt:=1})   
                            
If !Empty(cPriDia) .And. (nPosDia := aScan(aAgenda[1,1],{|aVet| aVet[1] == cPriDia})) > 0//(nPosDia := aScan(aAgenda[1][2], {| aVet1 | aScan(aVet1, {| aVet2 | aVet2[2] == cPriDia}) > 0})) > 0
		aOBJETOS[nFldAtu,1]:nAt := nPosDia  
EndIf 

//Monta GetDados  
aOBJETOS[1,2] := Fs_MntGetD(oPnlFolder, 1, @aAgenda[1][2][IIF(nPosDia # 0, nPosDia, 1)], cCodDis, lTemRec, nOpc,/*@aPnlGetDados*/,cCpoEnc)//, cHorIni, cHorFim, cIntMar, nQtdEnc, lTemRec)
aOBJETOS[2,2] := Fs_MntGetD(oPnlFolder, 2, @aAgenda[2][2][IIF(nPosDia # 0, IIF(Len(aAgenda[2][2]) < nPosDia, Len(aAgenda[2][2]), nPosDia), 1)], cCodDis, lTemRec, nOpc,/*@aPnlGetDados*/,cCpoEnc)//cHorIni, cHorFim, cIntMar, nQtdEnc, lTemRec)

Aeval(aOBJETOS,{|x|x[1]:bLine:={||{aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,1],;
									aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,2],;
									aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,3],;
									aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,4],;
									aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,5],;
									aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,6],;
									aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,7],;
									aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,8],;
									aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,9]}}})

Aeval(aOBJETOS,{|x|x[1]:Refresh()})
Aeval(aOBJETOS,{|x|IIF(x[2]:oBrowse <> nil,x[2]:Refresh(),nil)})       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca a Atualizacao da Agenda                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDiaAgeAtu := IIf(nPosDia > 0, nPosDia, 1)
HSPM29SavAge(nFldAtu,NIL,nDiaAgeAtu,NIL)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o Calendario do Agendamento                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HSPM29PaintCalend() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a marcacao do primeiro horario disponivel, quando a  ³
//³ consulta for via F3.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty(cPriDia) .And. !Empty(cPriHor)  
	HSPM29Marca("1",oFolder)                            

	cPriDia := " "
	cPriHor := " "

EndIf

If lQuery
	dbSelectArea(cAliasGM8)
	dbCloseArea()
EndIf
                                   
RestArea(aAreaGM8)
RestArea(aAreaAnt)

CursorArrow()

lExecFilt := .F.

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAgeLiv ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Horarios Livres                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAgeLiv()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.	ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAgeLiv()
Local lRetorno := .F.
If GM8->GM8_STATUS == "0"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAgeOcu ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Horarios Ocupados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAgeOcu()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.	ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAgeOcu()
Local lRetorno := .F.
If GM8->GM8_TIPAGE == "0" .And. GM8->GM8_STATUS == "1"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAgeOcu ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Horarios Ocupados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAgeOcu()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.	ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPEncOcu()
Local lRetorno := .F.
If GM8->GM8_TIPAGE == "1" .And. GM8->GM8_STATUS == "1"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAgePar ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Horarios Parciais                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe 	 ³ HSPAgePar()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	  ³ .T.	ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAgePar()
Local lRetorno := .F.
If GM8->GM8_STATUS == "2"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAgeAte ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Horarios Atendidos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAgeAte()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.	ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    		 ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAgeAte()
Local lRetorno := .F.
If GM8->GM8_STATUS == "3"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)     
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAgeOcB ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Horarios Ocupado/Bloqueados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAgeOcB()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.	ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    		 ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAgeOcB()
Local lRetorno := .F.
If GM8->GM8_STATUS == "4"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAgeAgC ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Horarios Confirmados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAgeAgC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.	ou .F.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAgeAgC()
Local lRetorno := .F.
If GM8->GM8_STATUS == "5"
	lRetorno := .T.
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPageCon ºAutor  ³Microsiga           º Data ³  10/24/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Legenda para os Agendamentos Em Conferencia.    º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAgeCon()
Local lRetorno := .F.
If GM8->GM8_STATUS == "7"
	lRetorno := .T.
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPageTrs ºAutor  ³Microsiga           º Data ³  10/24/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Legenda para os Agendamentos Trasnferidos.      º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAgeTrs()
Local lRetorno := .F.
If GM8->GM8_STATUS == "8"
	lRetorno := .T.
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29SavAge³ Autor ³Paulo Emidio de Barros ³Data³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controla a Navegacao dos Folders                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29SavAge(EXPN1,EXPN2,EXPN3,EXPN4)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Folder Atual                                       ³±±
±±³			 ³ EXPN2 = Folder Anterior                                    ³±±
±±³			 ³ EXPN3 = Dia Atual                                          ³±±
±±³			 ³ EXPN4 = Dia Anterior                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NULO                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29SavAge(nFldAtu,nFldAnt,nDiaAtu,nDiaAnt)
                                                           
Local aRecursos := Hs_RetRec(cCodDis,,,.T.)
Local lTemRec   := !Empty(aRecursos[1])

If (nFldAnt <> NIL) .And. (nFldAnt < 3)
	aAgenda[nFldAnt,2,nDiaAnt]	:= aClone(aOBJETOS[nFldAnt,2]:aCols) //Salva as Marcacoes na Agenda
EndIf

If (nFldAtu <> NIL) .And. (nFldAtu < 3)
                        
	aOBJETOS[nFldAtu,1]:nAt := nDiaAtu
	aOBJETOS[nFldAtu,1]:Refresh() //Atualiza as Ocupacoes
	If lTemRec .And. !Empty(cCodRec)
		Fs_MntHead(nFldAtu, @aAgenda[nFldAtu,2,nDiaAtu], cCodDis)
	EndIf
	aOBJETOS[nFldAtu,2]:aCols       := aClone(aAgenda[nFldAtu,2,nDiaAtu]) //Recupera as Marcacoes na Agenda
	aOBJETOS[nFldAtu,2]:nAt         := 1
	aOBJETOS[nFldAtu,2]:oBrowse:nAt := 1
	aOBJETOS[nFldAtu,2]:oBrowse:Refresh()
	
	nDiaAgeAnt := aOBJETOS[nFldAtu,1]:nAt //Atualiza o Dia Anterior Selecionado no Agendamento
	
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29SitAge³ Autor ³Paulo Emidio de Barros ³Data³06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Devolve a Legenda da Situacao da Marcacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29SitAge()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPC1 = Cor de acordo com a Situacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM29SitAge()
Local cRetorno := " "

If (cAliasGm8)->GM8_STATUS == "0"     //Livre 
	cRetorno := "BR_CINZA"
	
ElseIf (cAliasGm8)->GM8_STATUS == "1" //Ocupado 
	cRetorno := "BR_VERMELHO"
	
ElseIf (cAliasGm8)->GM8_STATUS == "2" //Bloqueado 
	cRetorno := "BR_AMARELO"
	
ElseIf (cAliasGm8)->GM8_STATUS == "3" //Atendido
	cRetorno := "BR_PINK"

ElseIf (cAliasGm8)->GM8_STATUS == "4" //Bloqueado/Ocupado
	cRetorno := "BR_AZUL"

ElseIf (cAliasGm8)->GM8_STATUS == "5" //Confirmado
	cRetorno := "BR_LARANJA"

ElseIf (cAliasGm8)->GM8_STATUS == "6" //Retorno
	cRetorno := "BR_CINZA"

ElseIf (cAliasGm8)->GM8_STATUS == "7" //Conferencia
	cRetorno := "BR_VIOLETA"

ElseIf (cAliasGm8)->GM8_STATUS == "8" //Transferido
	cRetorno := "BR_BRANCO"
	
EndIf

Return(cRetorno)

Static Function Fs_MarcAgd(cCodAge, dDatAgd, cHorAgd, cStatus,nPosHor, nPosRec,lSeqMar, lEncaixe, lLimpAgd, oObj, nPosDia)
Local aArea   := getArea()
Local lTemRec := !Empty(cCodRec)
Local lRet    := .T.
Local nI      := 0
Local nCodAge := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODAGE"}) //Codigo do agendamento

Default nPosRec  := 0
Default lSeqMar  := .F.
Default lLimpAgd := .T.

Default oObj     := nil 
Default nPosDia  := 0 

If !Fs_VldSala(M->GM8_CODSAL, dDatAgd, cHorAgd)
	Return(.F.)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Marca a Consulta em Horarios Livres                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cStatus $ "BR_CINZA/BR_BRANCO" .Or. lTemRec
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Marcacao foi efetuada em uma data retroativa   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//Se o agendamento foi chamado pela tela de solicitação de Sessões (HSPAHM13)
	if lHspahm13
		//Se a data selecionada for maior que a data de validade da solicitacao de sessões
		if	dDatAgd > GKB->GKB_DTFIVL
			//HS_MsgInf(STR0206,STR0077,STR0102)  //"A data selecionada é maior que a validade da solicitação de sessão."###"Atencao"###"Marca o Horario na Agenda"
			HS_MsgInf(STR0206 + " (" + dToC(dDatAgd) + ") " +  STR0207 + " (" + dToC(GKB->GKB_DTFIVL) + "). " +  STR0172 + "!",STR0077,STR0102)  //"A data selecionada" ### "é maior que a validade da solicitação de sessões" ###  ###"Atencao"###"Marca o Horario na Agenda"
			return .F.
		endif
	endif
	
	If !(lRet := dDatAgd >= dDataBase	)
		HS_MsgInf(OemToAnsi(STR0054),STR0077,STR0102) //"Não será possível selecionar o Horário em uma Data Retroativa."###"Atencao"###"Marca o Horario na Agenda"
	ElseIf (dDatAgd == dDataBase) .And. (IIf(oFolder:nOption == 2, .F., cHorAgd < Time()))
		HS_MsgInf(OemToAnsi(STR0055),STR0077,STR0102)  //"Não será possível selecionar um Horário retroativo no mesmo dia."###"Atencao"###"Marca o Horario na Agenda"
		lRet := .F.
	ElseIf oFolder:nOption == 1 .And. !Empty(Posicione("GM8", 4, xFilial("GM8")+M->GM8_FILAGE+M->GM8_CODCRM+DTOS(dDatAgd)+cHorAgd+"1"+cCodRec, "GM8_STATUS")) .AND. GM8->GM8_TIPAGE == "0"
		HS_MsgInf(OemToAnsi(STR0092),STR0077,STR0102)  //"O horário selecionado está em uso por outro usuário"###"Atencao"###"Marca o Horario na Agenda"
		lRet := .F.
	ElseIf !EMPTY(M->GM8_REGGER) .And. !FS_VldItv(dDatAgd, cHorAgd)
		HS_MsgInf(STR0116, STR0077, STR0102) //"Não será possivel selecionar o horário. Existe agendamento desse paciente no intervalo cadastrado no Convenio"###"Atenção"###"Marca o Horario na Agenda"
		lRet := .F.
	Else
		
		If !lSeqMar .And. len(aLastMar) > 0
			
			For nI := 1 to Len(aLastMar)
				nLastFld  := aLastMar[nI][2]
				nLastDay  := aLastMar[nI][3]                                                                             
				nLastHour := aLastMar[nI][4]
				nLastRec  := aLastMar[nI][5]
				
				oObj      := IIF(oObj == nil,aOBJETOS[nLastFld, 2], oObj)
				nPosDia   := IIF(nPosDia == 0,aOBJETOS[nFldAtu,1]:nAt, nPosDia)
				
				If lLimpAgd
					Fs_ApgMarc(,lTemRec)
				EndiF
				
				If (nLastFld == nFldAtu) .And. (nLastDay == nPosDia)
					Fs_ApgMarc(oObj:aCols,lTemRec)
					oObj:Refresh()
				EndIf
				
				FS_UByName("M29GM8"+aLastMar[nI][1])
			Next
			aLastMar := {}
		EndIf                                               

		Fs_MarcHor(nPosHor, lTemRec, nPosRec, oObj)
		
		nLastFld  := nFldAtu                  //Ultimo Folder
		nLastDay  := IIF(nPosDia # 0, nPosDia,aOBJETOS[nFldAtu,1]:nAt)  //Ultimo Dia Agendado
		nLastHour := nPosHor                  //Ultima Hora
		nLastRec  := nPosRec
		
		aAdd(aLastMar,	{cCodAge, nLastFld, nLastDay, nLastHour, nLastRec})
	EndIf
	
ElseIf cStatus == "BR_LARANJA" .And. !lEncaixe //Agendamento Marcado e Nao-Confirmado e não tenha sido digitado a data no encaixe
	For nI := 1 to Len(aLastMar)
		nLastFld  := aLastMar[nI][2]
		nLastDay  := aLastMar[nI][3]
		nLastHour := aLastMar[nI][4]
		nLastRec  := aLastMar[nI][5]
		
		oObj      := IIF(oObj == nil,aOBJETOS[nLastFld, 2], oObj)
		Fs_ApgMarc(oObj:aCols, nLastRec # 0)
		
		FS_UByName("M29GM8"+aLastMar[nI][1])
	Next
	
	aLastMar := {}
	nLastFld  := 0 //Ultimo Folder
	nLastDay  := 0 //Ultimo Dia Agendado
	nLastHour := 0 //Ultima Hora
	nLastRec  := 0
EndIf

RestArea(aArea)
Return(lRet)

Static Function Fs_MarcHor(nPosHor, lTemRec,nPosRec, oObj)
Local nMatric := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_MATRIC"}) //Matricula do plano
Local nNomPac := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_NOMPAC"}) //Nome do Paciente
Local nCodPla := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODPLA"}) //Codigo do Plano
Local nDesPla := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DESPLA"}) //Descricao do Plano
Local nCodPro := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODPRO"}) //Codigo do procedimento
Local nDesPro := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DESPRO"}) //Descricao do Procedimento
Local nCodSal := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODSAL"}) //Codigo da Sala
Local nSqCatP := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_SQCATP"}) //Sequencial da Categoria do Plano
Local nDsCatP := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DSCATP"}) //Descricao da Categora do Plano
Local nCodRec := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODREC"}) //Codigo Recurso

Default lTemRec := .F., nPosRec := 0
Default oObj := aOBJETOS[nFldAtu,2]
                                                                              
If !lTemRec
	oObj:aCols[nPosHor,nStatus] := "BR_LARANJA"  //Status de Agendamento Marcado e Nao-Confirmado
	oObj:aCols[nPosHor,nRegGer] := M->GM8_REGGER //Prontuario
	oObj:aCols[nPosHor,nMatric] := M->GM8_MATRIC //Matricula do plano
	oObj:aCols[nPosHor,nNomPac] := M->GM8_NOMPAC //Nome do Paciente
	oObj:aCols[nPosHor,nCodPla] := M->GM8_CODPLA //Codigo do Plano
	oObj:aCols[nPosHor,nDesPla] := M->GM8_DESPLA //Descricao do Plano
	oObj:aCols[nPosHor,nSqCatP] := M->GM8_SQCATP //Sequencial da Categoria do Plano
	oObj:aCols[nPosHor,nDsCatP] := M->GM8_DSCATP //Descricao da Categoria do Plano
	oObj:aCols[nPosHor,nCodPro] := M->GM8_CODPRO //Codigo do procedimento
	oObj:aCols[nPosHor,nDesPro] := M->GM8_DESPRO //Descricao do Procedimento
	oObj:aCols[nPosHor,nCodSal] := M->GM8_CODSAL //Codigo da sala
	oObj:aCols[nPosHor,nNomSal] := M->GM8_NOMSAL //Descricao do sala
	oObj:aCols[nPosHor,nCodRec] := M->GM8_CODREC //Código Recurso
Else
	oObj:aCols[nPosRec, nPosHor - 1] := "BR_LARANJA"  
EndIf

oObj:oBrowse:Refresh()

Return(nil)

                                          
Static Function Fs_ApgMarc(oObj, lTemRec)
Local nMatric := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_MATRIC"}) //Matricula do plano
Local nNomPac := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_NOMPAC"}) //Nome do Paciente
Local nCodPla := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODPLA"}) //Codigo do Plano
Local nDesPla := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DESPLA"}) //Descricao do Plano
Local nCodPro := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODPRO"}) //Codigo do procedimento
Local nDesPro := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DESPRO"}) //Descricao do Procedimento
Local nCodSal := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODSAL"}) //Codigo da Sala
Local nHorAge := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_HORAGE"}) //Hora da Agenda
Local nSqCatP := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_SQCATP"}) //Sequencial da Categoria do Plano
Local nDsCatP := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DSCATP"}) //Descricao da Categora do Plano
Local nCodRec := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODREC"}) //Codigo Recurso

Default oObj := aAgenda[nLastFld,2,nLastDay]

If !lTemRec
	
	If oObj[nLastHour,nStatus] # "BR_LARANJA"
		Return(nil)
	EndIf
	
	If nLastFld == 2
		oObj[nLastHour,nHorAge] := Iif(CriaVar("GM8_HORAGE",.T.,,.F.) == "     ", "  :  ",CriaVar("GM8_HORAGE",.T.,,.F.)	)
	EndIf
	
	oObj[nLastHour,nStatus] := "BR_CINZA"
	oObj[nLastHour,nRegGer] := CriaVar("GM8_REGGER",.T.,,.F.)
	oObj[nLastHour,nMatric] := CriaVar("GM8_MATRIC",.T.,,.F.)
	oObj[nLastHour,nNomPac] := CriaVar("GM8_NOMPAC",.T.,,.F.)
	oObj[nLastHour,nCodPla] := CriaVar("GM8_CODPLA",.T.,,.F.)
	oObj[nLastHour,nDesPla] := CriaVar("GM8_DESPLA",.T.,,.F.)
	oObj[nLastHour,nSqCatP] := CriaVar("GM8_SQCATP",.T.,,.F.)
	oObj[nLastHour,nDsCatP] := CriaVar("GM8_DSCATP",.T.,,.F.)
	oObj[nLastHour,nCodPro] := CriaVar("GM8_CODPRO",.T.,,.F.)
	oObj[nLastHour,nDesPro] := CriaVar("GM8_DESPRO",.T.,,.F.)
	oObj[nLastHour,nCodSal] := CriaVar("GM8_CODSAL",.T.,,.F.)
	oObj[nLastHour,nNomSal] := CriaVar("GM8_NOMSAL",.T.,,.F.)
	oObj[nLastHour,nCodRec] := CriaVar("GM8_CODREC",.T.,,.F.)
	
Else
	
	If oObj[nLastRec][nLastHour -1] # "BR_LARANJA"
		Return(nil)
	EndIf
	
	If nLastFld == 2
		oObj[nLastRec][nLastHour] := Iif(CriaVar("GM8_HORAGE",.T.,,.F.) == "     ", "  :  ", 	CriaVar("GM8_HORAGE",.T.,,.F.))
	EndIf
	
	oObj[nLastRec][nLastHour-1] := "BR_CINZA"
	
EndIf
Return(nil)
		
Static Function Fs_VldSala(cSala, dData, cHora)
Local lRet     := .F.
Local aArea    := getArea()
Local cIntSal  := HS_IniPadr("GF3", 1, cSala, "GF3_INTERV",, .F.)
Local aRetCalc := {}, dDatIni  := CtoD(""), cHorIni  := ""
Local dDatFin  := CtoD(""), cHorFin  := ""
Local cSql := ""
				
aRetCalc := HS_CalcDat(dData, cHora, "-", cIntSal)
dDatIni  := aRetCalc[1]
cHorIni  := aRetCalc[2]
		    
aRetCalc := HS_CalcDat(dData, cHora, "+", cIntSal)
dDatFin  := aRetCalc[1]
cHorFin  := aRetCalc[2]
		    
cSql := "SELECT GM8_REGGER, GM8_NOMPAC, GM8_CODCRM "
cSql += "FROM "+ RetSQLName("GM8") +" GM8 "
cSql += "WHERE GM8.GM8_DATAGE = '" + DTOS(dData) + "' "
cSql += "AND GM8.GM8_HORAGE = '" + cHora + "' "
cSql += "AND GM8.GM8_CODSAL = '" + M->GM8_CODSAL + "' "
cSql += "AND GM8.GM8_REGGER <> '"+Space(TamSx3("GM8_REGGER")[1])+"' "
cSql += "AND GM8.D_E_L_E_T_ <> '*' "
cSql += "AND GM8.GM8_CODCRM = '" + M->GM8_CODCRM + "' "
cSql += "AND GM8.GM8_CODREC <> '" + M->GM8_CODREC + "' "
cSql += "AND GM8.GM8_REGGER = '" + M->GM8_REGGER + "' "
cSql += "AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' "

cSql := ChangeQuery(cSql)
   
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPGM8", .F., .F.)
			
DbSelectArea("TMPGM8")
	
If !(lRet := TMPGM8->(Eof()))
	HS_MsgInf(OemToAnsi(STR0092+chr(13)+chr(10)+"Paciente: "+TMPGM8->GM8_REGGER+"-"+TMPGM8->GM8_NOMPAC+chr(13)+chr(10)+"Cód. Profissional "+TMPGM8->GM8_CODCRM),STR0077,STR0102)  //"O horário selecionado já está em uso "###"Atencao"###"Marca o Horario na Agenda"
EndIf

DbCloseArea()
RestArea(aArea)
return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29Marca ³ Autor ³Paulo Emidio de Barros ³Data³06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Marca o Horario na Agenda                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29Marca(EXPC1,EXPO1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Evento acionado                                    ³±±
±±³			       ³ EXPO1 = Objeto do Folder                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HSPM29Marca(cEvento,oFolder,lEncaixe, oObj, dDatAgd, lLimpAgd, nPosDia, cHoraEnc)
Local nPosHor 	:= 0, cIntSal := 0, nPosRec := 0 ,nPosEnc := 0,nPosAnt := "",nPosPri := 0//nPosDia := 0,
Local nQtdInt 	:= 0, nI := 0
Local cSQL 		:= ""
Local cIntMar 	:= "", cHorFim := ""
Local cHorIni   := ""
Local cHoraApoio:= ""
Local cTipAge 	:= "0"// Tipo de agendamento 0 - Agendamento / 1 - Encaixe
Local lRet      := .T.
Local aCodAge 	:= {}
Local aOldLocks := {}
Local aAreaOld 	:= GetArea()
Local lTemRec  	:= !Empty(cCodRec)
Local nAgenda 	:= Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DATAGE"}) //Data da Agenda
Local nHorAge 	:= Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_HORAGE"}) //Hora da Agenda

Local cNovAge   := " "
Local cFilAge   := " "
Local cPesquisa := " "

Default lEncaixe  := .F.
Default lLimpAgd  := .T.
Default nPosDia   := 0
Default cHoraEnc  := ""
Default oObj      := nil 
Default dDatAgd   := aAgenda[nFldAtu, 1,	aOBJETOS[nFldAtu,1]:nAt, 1]

If !ProcName(2) == '{|| FS_VLREAGD("2") }'//conflito de objetos, causando desposicionamento 
	oObj := aOBJETOS[nFldAtu,2]
Endif

If lTemRec
	If cEvento == "1"
		If oFolder:nOption == 2 //Encaixes
			//nPosRec := Ascan(oObj:aCols,{|x| SubStr(x[1],1,6) == SubStr(cCodRec,1,6)})
			nPosRec  := oObj:nAt
			cCodRec  := SubStr(oObj:aCols[nPosRec, 1], 1, TamSx3("GNZ_CODREC")[1]) //Atualizando codigo do recurso
			If  oObj:aCols[nPosRec, oObj:oBrowse:ColPos] $ "BR_VERMELHO"  .Or.  oObj:aCols[nPosRec,Iif(oObj:oBrowse:ColPos > 1, oObj:oBrowse:ColPos -1,1)]  $ "BR_VERMELHO"
				HS_MsgInf("O horário do recurso "+ cCodRec + " está em uso por outro usuário",STR0077,STR0102)
			Else
				If oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "BR_VERDE/BR_LARANJA/BR_AMARELO/BR_CINZA"
					nPosHor := oObj:oBrowse:ColPos + 1
				Else
					nPosHor := oObj:oBrowse:ColPos
				EndIf
				If nPosRec # 0
					nPosPri := Ascan(oObj:aCols[nPosRec],{|x| IIF(oFolder:nOption == 2 , IIf(ValType(x) = "C" .AND. x == "  :  ",.T.,.F.), .F.)})
					nPosAnt := Iif ( nPosPri > 3 , oObj:aCols[nPosRec,nPosPri - 3],Iif(nPosPri>0 ,oObj:aCols[nPosRec,nPosPri-1],0))
				EndIf
			Endif
		Else
			nPosRec := Ascan(oObj:aCols,{|x| SubStr(x[1],1,6) == SubStr(cCodRec,1,6)})
			If nPosRec # 0
				nPosHor := Ascan(oObj:aCols[nPosRec],{|x| IIF(valType(x) # "C",.F., x  == cPriHor)  .Or. IIF(oFolder:nOption == 2, x == "  :  ", .F.)})
			EndIf
		EndIf
	Else
		nPosRec  := oObj:nAt
		cCodRec  := SubStr(oObj:aCols[nPosRec, 1], 1, TamSx3("GNZ_CODREC")[1]) //Atualizando codigo do recurso
		If  oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "BR_VERMELHO"  .Or.  oObj:aCols[oObj:nAt,Iif(oObj:oBrowse:ColPos > 1, oObj:oBrowse:ColPos -1,1)]  $ "BR_VERMELHO"
			HS_MsgInf("O horário do recurso "+ cCodRec + " está em uso por outro usuário",STR0077,STR0102)
		Else
			If nPosRec # 0
				nPosPri := Ascan(oObj:aCols[nPosRec],{|x|  IIF(valType(x) # "C",.F., x  == cPriHor)  .Or. IIF(oFolder:nOption == 2, IIf(ValType(x) = "C" .AND. x == "  :  ",.T.,.F.), .F.)})
				nPosAnt := Iif(oFolder:nOption == 2,Iif ( nPosPri > 3 , oObj:aCols[nPosRec,nPosPri - 3],Iif(nPosPri>0 ,oObj:aCols[nPosRec,nPosPri-1],0)),"")
			EndIf
			If oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "BR_VERDE/BR_LARANJA/BR_AMARELO/BR_CINZA/BR_BRANCO"
				nPosHor := oObj:oBrowse:ColPos + 1
			Else
				nPosHor := oObj:oBrowse:ColPos 
			EndIf
		EndIf
	EndIf
	
ElseIf cEvento == "1" //Primeiro Horario Disponivel no Dia
	If oFolder:nOption == 2 //Encaixes
		nPosHor := Ascan(oObj:aCols,{|x|x[nHorAge]==cPriHor .Or. Empty(x[nHorAge])}) //Localiza o primeiro encaixe disponivel no dia
	Else
		nPosHor := Ascan(oObj:aCols,{|x|x[nHorAge]==cPriHor}) //Localiza o primeiro horario disponivel no dia
	EndIf
ElseIf cEvento == "2" //Escolha do Horario aleatoriamente
	nPosHor := oObj:oBrowse:nAt
EndIf

// Verifica se já tem um horário cadastrado (encaixe)
If oFolder:nOption == 2 .And. nPosHor > 1 .And.!(Posicione("GM8", 8, xFilial("GM8")+M->GM8_CODCRM+DTOS(dDatAgd)+M->GM8_HORAGE, "GM8_STATUS") $ "0 ") .And.nPosRec > 1  //Encaixes em horário já cadastrado
	HS_MsgInf(STR0131+Alltrim(M->GM8_NOMCRM)+" ("+DTOC(oObj:aCols[nPosHor,nAgenda])+"-"+M->GM8_HORAGE+")",STR0077,STR0102)  //"Já existe agenda para o médico: "###"Atencao"###"Marca o Horario na Agenda"
	Return (.F.)
Endif

If nPosHor <> 0
	
	If !lTemRec
		If oFolder:nOption == 2 //Encaixes
			cHoraApoio := cHoraEnc
			cTipAge := "1"
		Else
			cHoraApoio := oObj:aCols[nPosHor,nHorAge]
			cTipAge := "0"
		EndIf
		If Hs_VldMarc(@aCodAge, cCodDis, /*cCodRec*/, oObj:aCols[nPosHor,nAgenda], cHoraApoio, , , , , , , ,cTipAge)
			Fs_MarcAgd(aCodAge[1, 1, 1], aCodAge[1, 1, 2], aCodAge[1, 1, 3], oObj:aCols[nPosHor,nStatus],nPosHor ,,,lEncaixe,,oObj,nPosDia)
		
			oObj:oBrowse:nAt := nPosHor
			oObj:oBrowse:Refresh()
		EndIf
	Else
		cHorIni   := oObj:aCols[nPosRec, nPosHor]
		
		aOldLocks := aLocks
		//Destravando todos os registros
		While Len(aLocks) > 0
			FS_UByName(aLocks[1])
		EndDO
		
		cIntMar   := Hs_IniPadr("GM6", 1, cCodDis, "GM6_INTMAR",,.F.)
		If oFolder:nOption == 2
			If (nPosHor>0 .And. nPosHor > nPosPri)  .Or. (nPosAnt $ "BR_LARANJA")
				HS_MsgInf("Os Encaixes devem ser preenchido em ordem ",STR0077,STR0102)
				Return (.F.)
			EndIf
		EndIf
		If lRet := Hs_VldMarc(@aCodAge, cCodDis, cCodRec, dDatAgd, cHorIni, cIntMar, M->GM8_DURACA,  /*lMsg*/, /*lBlqReg*/, /*dProxDat*/, /*cProxHor*/, /*lVldPriDat*/,Iif(oFolder:nOption == 2,"1",""))
			nPosEnc := Val(Substr(oObj:aHeader[oObj:oBrowse:ColPos,2],9,2))
			If oFolder:nOption == 2
				If nPosEnc >0  .And. !Empty(cHoraEnc)
					lRet := Fs_MarcAgd(aCodAge[1, nPosEnc, 1],aCodAge[1, nPosEnc, 2], aCodAge[1, nPosEnc, 3], oObj:aCols[nPosRec, nPosHor - 1], nPosHor, nPosRec, , lEncaixe, lLimpAgd, oObj, nPOsDia)				
				Else                                                                                          
					lRet := .F.
				EndIf
			Else
				For nI := 1 to Len(aCodAge[1])
					If !(lRet := Fs_MarcAgd(aCodAge[1, nI, 1],aCodAge[1, nI, 2], aCodAge[1, nI, 3], oObj:aCols[nPosRec, nPosHor - 1], nPosHor, nPosRec, nI # 1, lEncaixe, lLimpAgd, oObj,  nPOsDia) )
						Exit
					EndIf
					nPosHor += 2
				Next
			EndIf
		Else
			For nI := 1 to Len(aOldLocks)
				FS_LByName(aOldLocks[nI])
			Next
		EndIf
		
	EndIf     
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso seja um encaixe no Agendamento, forca o foco para que o ³
	//³ usuario informe a hora do encaixe.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cEvento == "1") .And. (nFldAtu == 2)
		oObj:oBrowse:SetFocus()
	EndIf
	
EndIf
	
Return(lRet)

Static Function Fs_GrvCpoU()
Local nCont := 0

For nCont:= 1 To Len(aCpoUsu)
	If ValType("M->" + aCpoUsu[nCont]) != "U"
		GM8->&(aCpoUsu[nCont]) := M->&(aCpoUsu[nCont])
	EndIf
Next
Return(nil)

Static Function Fs_GrvMarc(cCodAge, cStatus, nOpc, cAgePrinc, cHorEnc, cSeqAge)
Local lRet      := .F. , 	lExcl := .T.
Local aArea     := getArea()
Local lBloqueia := Hs_IniPadr("GM7", 1, M->GM8_MOTIVO, "GM7_IDEBLO",,.F.) # "0"
Local cSql 		:= ""
Local cCodPla 	:= ""
Local lAteSUS 	:= (GetMV("MV_ATESUS", , "N") == "S")
Local cCodApc 	:= GetMV("MV_PSUSPAC")
//Solicitacao de Sessoes (HSPAHM13)
Local lAgdmSes   := SuperGetMv("MV_AGDMSES",nil,.F.)
Local lGm8SolGbb := Hs_ExisDic({{"C","GM8_SOLGKB"}}, .F.)
Local cCodSolGkb := ""
Local nQtdSolGkb := 0
Local nQtdAgeGkb := 0

IIF(Alias() <> 'GM8', DbSelectArea("GM8"),Nil)
IIF(IndexOrd() # 1  , DbSetOrder(1), Nil)
lRet := IIF(GM8->GM8_CODAGE # cCodAge, DbSeek(xFilial("GM8") + cCodAge), .T.)

If !lRet
	Return(lRet)
EndIf

If (nOpc == 2 .Or. nOpc == 4) .And. cStatus == "BR_LARANJA"
	RecLock("GM8",.F.)
	GM8->GM8_REGGER := M->GM8_REGGER
	GM8->GM8_MATRIC := M->GM8_MATRIC
	GM8->GM8_NOMPAC := M->GM8_NOMPAC
	GM8->GM8_TELPAC := M->GM8_TELPAC
	GM8->GM8_CODPLA := M->GM8_CODPLA
	GM8->GM8_SQCATP := M->GM8_SQCATP
	GM8->GM8_CODPRO := M->GM8_CODPRO
	GM8->GM8_OBSERV := M->GM8_OBSERV
	//GM8->GM8_CODSAL := M->GM8_CODSAL
	GM8->GM8_DURACA := M->GM8_DURACA
	GM8->GM8_INTERV := M->GM8_INTERV
	GM8->GM8_NUMSES := M->GM8_NUMSES
	GM8->GM8_PROTOC := M->GM8_PROTOC
	
	If GM8->GM8_TIPAGE == "1" //Encaixe
		GM8->GM8_HORAGE := cHorEnc
	EndIf
	
	GM8->GM8_CODCON := cGCM_CODCON    //GRAVA O CODIGO DO CONVENIO
	GM8->GM8_STATUS := "1" //Status para definir o Agendamento
	GM8->GM8_DATCAD := dDataBase
	GM8->GM8_HORCAD := SubStr(Time(),1,5)
	GM8->GM8_CODUSU := SubStr(cUsuario, 7, 15)
	GM8->GM8_LOCAGE := cGcsCodLoc
	GM8->GM8_LOGARQ := HS_LogArq()
	GM8->GM8_AGDPRC := cAgePrinc
	GM8->GM8_SEQAGE := cSeqAge //Relaciona Primeira Agenda do Tratamento
	
	if isInCallStack("HSPAHM13") .and. lAgdmSes
	    GM8->GM8_SOLGKB := GKB->GKB_SOLICI
		if !empty(GKB->GKB_SEQAGE)
			GM8->GM8_SEQAGE := GKB->GKB_SEQAGE
		endif
	endif	
	
	Fs_GrvCpoU()
	
	MsUnLock()
	
	FS_UByName("M29GM8"+cCodAge)
	if cAgePrinc == cCodAge
		Fs_GrvProc(cAgePrinc, 3)
	EndIf
	If (nOpc==4)


		cNovAge		:= GM8->GM8_CODAGE						//Salva o Codigo do Novo Agendamento			
		cFilAge		:= M->GM8_FILIAL						//Salva Filial do Antigo Agendamento
		cPesquisa	:= M->( GM8_FILIAL + GM8_CODAGE )		//Posiciona no horario antigo da transferencia
			
		DbSelectArea("GM8")
		GM8->( DbSetOrder(1) ) //GM8_FILIAL + GM8_CODAGE
		
		If GM8->( DbSeek( cPesquisa ) )
			If GMA->(FieldPos("GMA_SEQREG")) > 0
				M->GMA_SEQREG := HS_VSxeNum("GMA", "M->GMA_SEQREG", 4)
				ConfirmSX8()
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava Historico da Transferencia								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("GMA",.T.)
			
			GMA->GMA_FILIAL := xFilial("GMA")
			GMA->GMA_FILAGE := cFilAge
			GMA->GMA_CODPLA := GM8->GM8_CODPLA
			GMA->GMA_SQCATP := GM8->GM8_SQCATP
			GMA->GMA_CODCRM := GM8->GM8_CODCRM
			GMA->GMA_CODLOC := GM8->GM8_CODLOC
			GMA->GMA_CODDIS := GM8->GM8_CODDIS
			GMA->GMA_REGGER := GM8->GM8_REGGER
			GMA->GMA_MATRIC := GM8->GM8_MATRIC
			GMA->GMA_CODAGE := GM8->GM8_CODAGE
			GMA->GMA_NOMPAC := GM8->GM8_NOMPAC
			GMA->GMA_TELPAC := GM8->GM8_TELPAC
			GMA->GMA_CODPRO := GM8->GM8_CODPRO
			GMA->GMA_DATAGE := GM8->GM8_DATAGE
			GMA->GMA_HORAGE := GM8->GM8_HORAGE
			GMA->GMA_DATCAD := GM8->GM8_DATCAD
			GMA->GMA_HORCAD := GM8->GM8_HORCAD
			GMA->GMA_USUCAD := GM8->GM8_CODUSU
			GMA->GMA_CODCAN := M->GM8_MOTIVO
			GMA->GMA_DATCAN := dDataBase
			GMA->GMA_HORCAN := SubStr(Time(),1,5)
			GMA->GMA_USUCAN := SubStr(cUsuario,7,15)
			GMA->GMA_NOVAGE := cCodAge
			GMA->GMA_DESCFM := GM8->GM8_DESCFM
			GMA->GMA_DATCFM := GM8->GM8_DATCFM
			GMA->GMA_HORCFM := GM8->GM8_HORCFM
			GMA->GMA_USUCFM := GM8->GM8_USUCFM
			GMA->GMA_LOGARQ := HS_LOGARQ()
			GMA->GMA_LOCAGE := GM8->GM8_LOCAGE
			GMA->GMA_CODSAL := GM8->GM8_CODSAL
			
			If GMA->(FieldPos("GMA_SEQREG")) > 0                   //Checar se existe campo para release 4 (transferir/alterar)
				GMA->GMA_SEQREG := M->GMA_SEQREG
			EndIf
			MsUnLock()
			
			If GM8->GM8_EXCTRA
				RecLock("GM8",.F.)
				DbDelete()
				MsUnLock()
			Else
				Fs_BloqGM8(M->GM8_CODAGE, lBloqueia)
			EndIf
			Fs_GrvProc(M->GM8_CODAGE, 5)
		EndIf
	EndIf
	
ElseIf nOpc == 3 .And. cStatus $ "BR_VERMELHO/BR_AZUL/BR_LARANJA"
	
	cSql := "SELECT * "
	cSql += "FROM "+ RetSQLName("GM8") +" GM8 "
	cSql += "WHERE GM8.GM8_FILIAL = '" + xFilial("GM8") + "' "
	cSql += "AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' "
	cSql += "AND GM8.GM8_REGGER = '"+M->GM8_REGGER+"' "
	cSql += "AND GM8.GM8_SEQAGE = '"+M->GM8_SEQAGE+"' "
	If lCanUnic .AND. !Empty(cAgePrinc)
		cSql += "AND GM8.GM8_AGDPRC = '"+cAgePrinc+"' "
	EndIf
	cSql += "AND GM8.GM8_STATUS IN ('1', '3') "
	cSql += "AND GM8.D_E_L_E_T_ <> '*' "
	
	cSql := ChangeQuery(cSql)
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TBEGM8", .F., .F.)
	
	If TBEGM8->(!Eof())
		
		While TBEGM8->(!Eof())
			If  !(TBEGM8->GM8_DATAGE > Dtos(dDataBase))  .And.  TBEGM8->GM8_STATUS == '3'
				lExcl := .F.
				TBEGM8->(dbSkip())
			Else
				If GM9->(FieldPos("GM9_SEQREG")) > 0                   //Checar se existe campo para release 4  (cancelar)
					M->GM9_SEQREG   := HS_VSxeNum("GM9", "M->GM9_SEQREG", 4)
					ConfirmSX8()
				EndIf
				
				RecLock("GM9",.T.)
				GM9->GM9_FILIAL := xFilial("GM9")
				GM9->GM9_FILAGE := TBEGM8->GM8_FILAGE
				GM9->GM9_CODPLA := TBEGM8->GM8_CODPLA
				GM9->GM9_SQCATP := TBEGM8->GM8_SQCATP
				GM9->GM9_CODCRM := TBEGM8->GM8_CODCRM
				GM9->GM9_CODLOC := TBEGM8->GM8_CODLOC
				GM9->GM9_CODDIS := TBEGM8->GM8_CODDIS
				GM9->GM9_REGGER := TBEGM8->GM8_REGGER
				GM9->GM9_MATRIC := TBEGM8->GM8_MATRIC
				GM9->GM9_CODAGE := TBEGM8->GM8_CODAGE
				GM9->GM9_NOMPAC := TBEGM8->GM8_NOMPAC
				GM9->GM9_TELPAC := TBEGM8->GM8_TELPAC
				GM9->GM9_CODPRO := TBEGM8->GM8_CODPRO
				GM9->GM9_DATAGE := sTod(TBEGM8->GM8_DATAGE)
				GM9->GM9_HORAGE := TBEGM8->GM8_HORAGE
				GM9->GM9_DATCAD := sTod(TBEGM8->GM8_DATCAD)
				GM9->GM9_HORCAD := TBEGM8->GM8_HORCAD
				GM9->GM9_USUCAD := TBEGM8->GM8_CODUSU
				GM9->GM9_CODCAN := M->GM8_MOTIVO
				GM9->GM9_DATCAN := dDataBase
				GM9->GM9_HORCAN := SubStr(Time(),1,5)
				GM9->GM9_USUCAN := SubStr(cUsuario,7,15)
				GM9->GM9_DESCFM := TBEGM8->GM8_DESCFM
				GM9->GM9_DATCFM := stod(TBEGM8->GM8_DATCFM)
				GM9->GM9_HORCFM := TBEGM8->GM8_HORCFM
				GM9->GM9_USUCFM := TBEGM8->GM8_USUCFM
				GM9->GM9_LOCAGE := TBEGM8->GM8_LOCAGE
				GM9->GM9_CODSAL := TBEGM8->GM8_CODSAL
				
				If GM9->(FieldPos("GM9_SEQREG")) > 0                   //Checar se existe campo para release 4  (cancelar)
					GM9->GM9_SEQREG := M->GM9_SEQREG
				EndIf
				MsUnLock()
				if lAgdmSes .and. lGm8SolGbb
					cCodSolGkb := TBEGM8->GM8_SOLGKB
				endif
				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Disponibiliza o Horario ou Encaixe para novas marcacoes ou   ³
				//³ bloqueia os mesmos.                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Fs_BloqGM8(TBEGM8->GM8_CODAGE, lBloqueia)
				Fs_GrvProc(TBEGM8->GM8_AGDPRC, 5)
				
				If !(lAtesus .And. cCodPla $ cCodApc)
					DbSelectArea("GKB")
					DbSetOrder(5)
					DbSeek(xFilial("GKB") +  TBEGM8->GM8_REGGER + TBEGM8->GM8_SEQAGE)
					If GKB->(!Eof())
						If lExcl
							RecLock("GKB",.F.)
							if lAgdmSes .and. lGm8SolGbb
								if !empty(cCodSolGkb)
									//Qtde solicitada
									nQtdSolGkb := GKB->GKB_QTDSOL
									//Qtde agendada para essa solicitacao
									nQtdAgeGkb := hs_qtProAg( cCodSolGkb, GKB->GKB_CODPRO, "S")
									//se a qtd de procedimentos agendados para a solicitacao de ssesao é menor que a qtd permitida
									if  nQtdAgeGkb < nQtdSolGkb .and. nQtdAgeGkb > 0
										GKB->GKB_STATUS :='6'
									else
										GKB->GKB_STATUS :='0'										
									endif
								else
									GKB->GKB_STATUS :='2'
								endif
							else 
								GKB->GKB_STATUS :='2'
						endif
							GKB->GKB_SEQAGE := ""
							MsUnLock()
						EndIf
					EndIF
				EndIf
				
				TBEGM8->(dbSkip())
			EndIf
		End
		
		DbSelectArea("TBEGM8")
		DbCloseArea()
		
	Else
		If Alias()=="TBEGM8"
			TBEGM8->(DbCloseArea() )
		Endif
		If GM9->(FieldPos("GM9_SEQREG")) > 0                   //Checar se existe campo para release 4  (cancelar)
			M->GM9_SEQREG   := HS_VSxeNum("GM9", "M->GM9_SEQREG", 4)
			ConfirmSX8()
		EndIf
		
		RecLock("GM9",.T.)
		GM9->GM9_FILIAL := xFilial("GM9")
		GM9->GM9_FILAGE := GM8->GM8_FILAGE
		GM9->GM9_CODPLA := GM8->GM8_CODPLA
		GM9->GM9_SQCATP := GM8->GM8_SQCATP
		GM9->GM9_CODCRM := GM8->GM8_CODCRM
		GM9->GM9_CODLOC := GM8->GM8_CODLOC
		GM9->GM9_CODDIS := GM8->GM8_CODDIS
		GM9->GM9_REGGER := GM8->GM8_REGGER
		GM9->GM9_MATRIC := GM8->GM8_MATRIC
		GM9->GM9_CODAGE := GM8->GM8_CODAGE
		GM9->GM9_NOMPAC := GM8->GM8_NOMPAC
		GM9->GM9_TELPAC := GM8->GM8_TELPAC
		GM9->GM9_CODPRO := GM8->GM8_CODPRO
		GM9->GM9_DATAGE := GM8->GM8_DATAGE
		GM9->GM9_HORAGE := GM8->GM8_HORAGE
		GM9->GM9_DATCAD := GM8->GM8_DATCAD
		GM9->GM9_HORCAD := GM8->GM8_HORCAD
		GM9->GM9_USUCAD := GM8->GM8_CODUSU
		GM9->GM9_CODCAN := M->GM8_MOTIVO
		GM9->GM9_DATCAN := dDataBase
		GM9->GM9_HORCAN := SubStr(Time(),1,5)
		GM9->GM9_USUCAN := SubStr(cUsuario,7,15)
		GM9->GM9_DESCFM := GM8->GM8_DESCFM
		GM9->GM9_DATCFM := GM8->GM8_DATCFM
		GM9->GM9_HORCFM := GM8->GM8_HORCFM
		GM9->GM9_USUCFM := GM8->GM8_USUCFM
		GM9->GM9_LOCAGE := GM8->GM8_LOCAGE
		GM9->GM9_CODSAL := GM8->GM8_CODSAL
		
		If GM9->(FieldPos("GM9_SEQREG")) > 0                   //Checar se existe campo para release 4  (cancelar)
			GM9->GM9_SEQREG := M->GM9_SEQREG
			HS_MsgInf(STR0109 + GM9->GM9_SEQREG, STR0077 ,STR0110) //"Registro Sequencial Nr: "###"Atenção"###"Histórico do Cancelamento"
		EndIf
		MsUnLock()
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Disponibiliza o Horario ou Encaixe para novas marcacoes ou   ³
		//³ bloqueia os mesmos.                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Fs_BloqGM8(cAgePrinc, lBloqueia)
		Fs_GrvProc(cAgePrinc, 5)
	EndIf
	
ElseIf nOpc == 5 .And. cStatus $  "BR_VERMELHO/BR_LARANJA"
	RecLock("GM8",.F.)
	GM8->GM8_MATRIC := M->GM8_MATRIC
	GM8->GM8_TELPAC := M->GM8_TELPAC
	GM8->GM8_OBSERV := M->GM8_OBSERV
	GM8->GM8_LOGARQ := HS_LogArq()
	
	Fs_GrvCpoU()
	MsUnLock()
	Fs_GrvProc(cAgePrinc, 4) //Verificar como fica isso
EndIf

RestArea(aArea)
Return(lRet)

Static Function Fs_BloqGM8(cCodPrinc, lBloqueia)
Local aArea := getArea()
Local nCont

DbSelectArea("GM8")
DbSetOrder(12)

While DbSeek(xFilial("GM8")+cCodPrinc)

	//Ajusta Status da solicitacao de sessao (HSPAHM13) antes de eliminar o agendamento 
  	If lAgdmSes .and. !Empty(GM8->GM8_SOLGKB)
  		HS_sStSess(GM8->GM8_SOLGKB, GM8->GM8_CODPRO, GM8->GM8_SEQAGE, "E")    
	Endif
	
	RecLock("GM8",.F.)
	
	If lBloqueia
		GM8->GM8_STATUS := "2"           //Bloqueado
		GM8->GM8_ORICAN := M->GM8_ORICAN //Grava o Tipo de Cancelamento somente no Bloqueio
		GM8->GM8_REGGER := " "
		GM8->GM8_MATRIC := " "
		GM8->GM8_NOMPAC := " "
		GM8->GM8_TELPAC := " "
		GM8->GM8_CODPLA := " "
		GM8->GM8_SQCATP := " "
		GM8->GM8_CODCON := " "
		GM8->GM8_CODPRO := " "
		GM8->GM8_OBSERV := " "
		GM8->GM8_CODUSU := " "
		GM8->GM8_LOCAGE := " "
		
		If lGm8SolGbb 
			GM8->GM8_SOLGKB := " "
		Endif
		
	Elseif nOpcSav == 4//Transferir
		
		If GM8->GM8_TIPAGE == "1" //Encaixe
			GM8->GM8_HORAGE := "  :  "
		EndIf
		
		GM8->GM8_STATUS := "8"

		If lGm8SolGbb 
			GM8->GM8_SOLGKB := " "
		Endif
		
	Else
		
		If GM8->GM8_TIPAGE == "1" //Encaixe
			GM8->GM8_HORAGE := "  :  "
		EndIf
		
		GM8->GM8_REGGER := " "
		GM8->GM8_MATRIC := " "
		GM8->GM8_NOMPAC := " "
		GM8->GM8_TELPAC := " "
		GM8->GM8_CODPLA := " "
		GM8->GM8_CODCON := " "
		GM8->GM8_CODPRO := " "
		GM8->GM8_OBSERV := " "
		GM8->GM8_CODUSU := " "
		
		If GM8->GM8_STATUS == "4"
			GM8->GM8_STATUS := "2"
		Else
			GM8->GM8_STATUS := "0"
		Endif
		
		GM8->GM8_DATCAD := Ctod("")
		GM8->GM8_HORCAD := " "
		GM8->GM8_CODUSU := " "
		GM8->GM8_DESCFM := " "
		GM8->GM8_DATCFM := Ctod("")
		GM8->GM8_HORCFM := " "
		GM8->GM8_USUCFM := " "
		GM8->GM8_LOCAGE := " "
		
		If lGm8SolGbb 
			GM8->GM8_SOLGKB := " "
		Endif
		
	EndIf
	
	GM8->GM8_DURACA := SPACE(TamSx3("GM8_DURACA")[1])
	GM8->GM8_INTERV := 0
	GM8->GM8_NUMSES := 0
	GM8->GM8_PROTOC := SPACE(TamSx3("GM8_PROTOC")[1])
	GM8->GM8_AGDPRC := SPACE(TamSx3("GM8_AGDPRC")[1])
	GM8->GM8_LOGARQ := HS_LogArq()
	For nCont:= 1 To Len(aCpoUsu)
		If ValType("M->" + aCpoUsu[nCont]) != "U"
			If ValType(&("M->" + aCpoUsu[nCont]))=="C"
				GM8->&(aCpoUsu[nCont]) := " "
			ElseIf ValType(&("M->" + aCpoUsu[nCont]))=="N"
				GM8->&(aCpoUsu[nCont]) := 0
			ElseIf ValType(&("M->" + aCpoUsu[nCont]))=="D"
				GM8->&(aCpoUsu[nCont]) := CTOD("  /  /  ")
			ElseIf ValType(&("M->" + aCpoUsu[nCont]))== "L"
				GM8->&(aCpoUsu[nCont]) := .F.
			EndIf
		EndIf
	Next
	MsUnLock()
EndDo

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  	 ³HSPM29Grv ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao do Agendamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29Grv(EXPN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29Grv(nOpc, cSeqAge,aMeses)
Local nCont     := 0
Local cStatus   := ""
Local cCodAge   := 0
Local cAgePrinc := IIf(!Empty(cSeqAge),cSeqAge,Iif(Len(aLastMar) > 0,aLastMar[1,1],""))
Local cHorIni   := ""
Local dDatIni   := CtoD("")
Local lSesOk	:= .F.
Local nHorAge   := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_HORAGE"}) //Hora da Agenda
Local lHspAhm12 := isInCallStack("HSPAHM12")
Local lOk       := .T.
//Se foi chamada pela solicitacao de Sessoes (HSPAHM13) e se ha agendamento multiplo
if lHspAhm13 .and. lAgdmSes
	//Antes de gravar, verifica se a quantidade de sessoes+quantidade ja agendada ultrapassa a quantidade maxima permitida para o procedimento definida na solicitacao                           
	If iIf(M->GM8_NUMSES == 0, 1 , M->GM8_NUMSES ) + hs_qtProAg( cCodSolGkb, M->GM8_CODPRO, "S") > nQtdSolGkb
		HS_MsgInf(OemToAnsi(STR0169+" (" + cValToChar(iIf(M->GM8_NUMSES == 0, 1, M->GM8_NUMSES)) + ") + " + STR0170 + " (" + cValToChar( hs_qtProAg(cCodSolGkb, M->GM8_CODPRO, "S")) ;
		  + ") " + STR0171 + " (" + cValToChar(nQtdSolGkb) + ") " + STR0205 + " (HSPAHM13: GKB_QTDSOL - " + Posicione("SX3", 2, "GKB_QTDSOL", "X3Titulo()") + "). " +  chr(10) + chr(13) + STR0172 + "!"),STR0077,STR0102)  //"O numero de sessoes definido (n) + a quantidade já agendada (n) deste procedimento ultrapassa a quantidade máxima permitida (XXXXXXXXXX) definida na solicitação de sessões  (HSPAHM13: GKB_QTDSOL - Qtd Solicita). ". Verifique!"###"Atencao"###"Marca o Horario na Agenda"
		return .F.
	EndIf
endif 

Begin Transaction

For nCont := 1 to Len(aLastMar)
	If Empty(cSeqAge)
		cCodAge := IIF(nOpc == 2 .Or. nOpc == 4,  aLastMar[nCont,1], M->GM8_CODAGE)
	Else
		cCodAge := cSeqAge
	EndIf
	
	lTemRec := !Empty(aLastMar[nCont,5])
	nLastFld  := aLastMar[nCont, 2]
	nLastDay  := aLastMar[nCont, 3]
	nLastHour := aLastMar[nCont, 4]
	nLastRec  := aLastMar[nCont, 5]
	
	DbSelectArea("GM8")
	DbSetOrder(1)
	
	If !DbSeek(xFilial("GM8")+cCodAge)
		DisarmTransaction()
		lOk := .F.
		Exit
	EndIf
	
	If nOpc <> 3 .and. nOpc <> 5 //Se for diferente de cancelamento, faz a verificacao de horario
		If ! Empty( GM8->GM8_REGGER ) .AND. GM8->GM8_REGGER == M->GM8_REGGER .AND. GM8->GM8_HORAGE == M->GM8_HORAGE .AND. !( GM8->GM8_STATUS == "8" )
			HS_MsgInf(STR0072, STR0077, STR0103) //"Este horário já está agendado."###"Atenção"###"Atualizacao do Agendamento"
			DisarmTransaction()
			lOk := .F.
			Exit
		EndIf
	EndIf
	
	If lTemRec
		cStatus := aAgenda[nLastFld,2,nLastDay, nLastRec, nLastHour-1]
		cHorEnc := aAgenda[nLastFld,2,nLastDay, nLastRec, nLastHour]
		cHorIni := IIF(nCont == 1, aAgenda[nLastFld,2,nLastDay, nLastRec, nLastHour], cHorIni)
		dDatIni := IIF(nCont == 1, aAgenda[nLastFld, 1,	aOBJETOS[nLastFld,1]:nAt, 1], dDatIni)
	Else
		cStatus := aAgenda[nLastFld,2,nLastDay,nLastHour,nStatus]
		cHorEnc := aAgenda[nLastFld,2,nLastDay,nLastHour,nHorAge]
		cHorIni := IIF(nCont == 1, aAgenda[nLastFld,2,nLastDay,nLastHour,nHorAge] , cHorIni)
		dDatIni := IIF(nCont == 1, aAgenda[nLastFld,1,aOBJETOS[nLastFld,1]:nAt, 1], dDatIni)
	EndIf
	
	Fs_GrvMarc(cCodAge, cStatus, nOpc, cAgePrinc, cHorEnc, cAgePrinc)
Next
If lOk
	//Verifica se a funcao chamadora eh "HSPAHM12 e se o parametro ja existe ou se foi ajustado para .T., caso nao exista, retorna .F.
	if FunName() $ "HSPAHM12" .and. SuperGetMv("MV_ALTDTSO",nil,.F.)
		//Grava a menor data agendada na GK7
		RecLock("GK7", .F.)
		GK7->GK7_DATSOC := dDatIni 
		GK7->GK7_DTINVL := dDatini
		GK7->GK7_DTFIVL := dDatini+getMv("MV_VLDGUIA")
		MsUnLock()
	endif

	If nOpc == 2
		If !Fs_GSessao(dDatIni, cHorIni, cAgePrinc, !Empty(M->GM8_PROTOC),aMeses)
			lSesOk := .F.
			DisarmTransaction()
			lOk := .F.
		Else
			lSesOk := .T.
		EndIf
	EndIf
EndIf
End Transaction
If lOk
	If lSesOk .AND. Hs_ExisDic({{"C","GM8_SEQQTD"}}, .F.) .AND. !Empty(cAgePrinc)
		if lHspAhm12 .and. !empty(GK7->GK7_SEQAGE)
			FS_ATSESAM(GK7->GK7_SEQAGE)
		elseif lHspAhm13 .and. !empty(GKB->GKB_SEQAGE)
			FS_ATSESAM(GKB->GKB_SEQAGE)		
		else
		FS_ATRBSES(cAgePrinc)
		endif
	EndIf


	dbSelectArea("GM8")
	dbSetOrder(1)
	DbSeek(xFilial("GM8")+cAgePrinc)

	dbSetOrder(2)

	If FunName() == "HSPM24AA" //so chama fichas se vier do atendimento
		HS_RelM29() //Imprime as fichas
	EndIf

	While __lSx8
		ConfirmSx8()
	End
	If Empty(cSeqAge)
		cSeqAge := cAgePrinc
	EndIf
EndIf
Return(.T.)
  
Static Function Fs_GrvProc(cCodAge, nOpc)
Local aArea  := GetArea()
Local lRet   := .F.
Local nI     := 0
Local lAchou := .F.

For nI := 1 to len(oGO4:aCols)
	
	If Empty(oGO4:aCols[nI,nGO4_CODPRO])
		Loop
	EndIf
	
	DbSelectArea("GO4")
	DbSetOrder(1)
	lAchou := DbSeek(xFilial("GO4")+cCodAge+oGO4:aCols[nI,nGO4_CODPRO])
	
	If (oGO4:aCols[nI, len(oGO4:aHeader)+1] .Or. nOpc == 5) .And. lAchou
		RecLock("GO4", !lAchou)
		DbDelete()
		MsUnLock()
	Else
		RecLock("GO4", !lAchou)
		GO4->GO4_FILIAL := xFilial("GO4")
		GO4->GO4_CODAGE := cCodAge
		GO4->GO4_CODPRO := oGO4:aCols[nI,nGO4_CODPRO]
		MsUnLock()
	EndIf
	
Next nI

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29VerHorEnc³Autor³Paulo Emidio de Barros³Data³06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se a Hora foi preenchida, caso o agendamento seja ³±±
±±³          ³ um Encaixe.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29VerHorEnc(EXPN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Numero do Folder                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T ou F                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29VerHorEnc(nFolder, cSeqAge)
Local lRetorno 	:= .T.
Local nCont     := 0
Local nHorAge := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_HORAGE"}) //Hora da Agenda
Local nCodAge := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODAGE"}) //Cod. Age.

If nFolder == 2 //verifica se a Hora marcada e encaixe
	
	For nCont := 1 To Len(aOBJETOS[nFolder,2]:aCols)
		If aOBJETOS[nFolder,2]:aCols[nCont,nStatus] == "BR_LARANJA" //Status de Agendamento Marcado e Nao-Confirmado
			cSeqAge := aOBJETOS[nFolder,2]:aCols[nCont,nCodAge]
			If Empty(aOBJETOS[nFolder,2]:aCols[nCont,nHorAge]) .Or. aOBJETOS[nFolder,2]:aCols[nCont,nHorAge] == "  :  "
				HS_MsgInf(OemToAnsi(STR0040),STR0077,STR0104) //"Não foi informado o Horário para o Encaixe."###"Atenção"###"Verifica se a Hora foi preenchida"
				aOBJETOS[nFolder,2]:oBrowse:SetFocus()
				lRetorno := .F.
				Exit
			EndIf
			
		EndIf
	Next

EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HS_VldM29     ³Autor³Eduardo Alves         ³Data³18/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Executada no Botao Confirma da Marcacao (bOk), Utili³±±
±±³          ³ zada para validar o Modulo de Marcacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_VldM29()       			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldM29(nOpc)
Local lRet 					:= .T.
//	Local nAgenda 		:= 0
//	Local nEncaixe 	:= 0
	
If nOpc == 2 .Or. nOpc == 4 /* Opcao AGENDAR ou TRANSFERIR */
	If len(aLastMar) == 0//If nAgenda = 0 .And. nEncaixe = 0
		HS_MsgInf(STR0112, STR0077, STR0111) // "Não foi selecionado nenhum horário para o paciente, dê um duplo clique sobre o horário desejado antes de confirmar a marcação!"###"Atenção"###"Confirmação da Marcação"
		lRet := .F.
	EndIf
	
	If nOpc == 2 .And. !Empty(cCodRec) .And. !Empty(M->GM8_PROTOC) .And. oFolder:nOption == 2
		Hs_MsgInf("O Agendamento por Encaixe nao pode ser feito pelo Protocolo",STR0077, STR0111,)
		lRet := .F.
	ElseIf nOpc == 2 .And. !Empty(cCodRec) .And. oFolder:nOption == 2 .And. (!Empty(M->GM8_INTERV) .Or. !Empty(M->GM8_NUMSES))
		If  M->GM8_INTERV > 1 .Or. M->GM8_NUMSES > 1
			Hs_MsgInf("O Agendamento por Encaixe nao pode ser feito com Numero de Sessoes ou Intervalo maior que 1(um) !",STR0077,STR0111,)
			lRet := .F.
		EndIf
	ElseIf nOpc == 2 .And. !Empty(cCodRec) .And. ((Empty(M->GM8_INTERV) .Or. Empty(M->GM8_NUMSES)) .And. Empty(M->GM8_PROTOC))
		If oFolder:nOption == 2
			M->GM8_NUMSES := 1
			M->GM8_INTERV := 1
		Else
			Hs_MsgInf("Obrigatório a informação dos campos "+HS_CfgSx3("GM8_INTERV")[SX3->(FieldPos("X3_TITULO"))]+"(GM8_INTERV) "+;
			"e "+HS_CfgSx3("GM8_NUMSES")[SX3->(FieldPos("X3_TITULO"))]+"(GM8_NUMSES)"+;
			"ou somente "+HS_CfgSx3("GM8_PROTOC")[SX3->(FieldPos("X3_TITULO"))]+"(GM8_PROTOC)"+;
			" em agendamento com recursos.","Atenção","Validação Sessão")
			lRet := .F.
		EndIf
	EndIf
EndIf
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM29IniTrf  ³Autor³Paulo Emidio de Barros³Data³06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inicia o browse com o registro a ser transferido pela ro-  ³±±
±±³          ³ tina de Transferencia                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29IniTrf(EXPL1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = Indica se o browse sera iniciado                   ³±±
±±³          ³ EXPL2 = Opção escolhida                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29IniTrf(lIniBrw,nOpc,lRes800,oPanel2,oFont)
Local oTxtTrf
Local aTitTrf := {}
Local aTamTrf := {}
Local bBlkTrf
Local cTitulo := IIF(nOpc == 4,STR0042,STR0126) //"Horário a ser Transferido"###"Horarios ja Agendados"

lIniBrw := IIf(lIniBrw == NIL, .F., lIniBrw)

If Len(aTrfHorAge) == 0 //Executa somente se o vetor estiver vazio
	If lIniBrw
		@ 080,60 + IIF(!lRes800, 25, 0) SAY oTxtTrf PROMPT OemToAnsi(cTitulo) Of oPanel2 SIZE 180, 010 FONT oFont Pixel COLOR CLR_RED
		aTitTrf := {STR0041, STR0043, STR0033, STR0044, STR0045, STR0046, STR0047, STR0028, STR0048, STR0029, STR0049} //"Filial Agenda" ### "Data" ### "Hora" ### "Prontuario" ### "Nome" ### "Plano" ### "Descricao Plano" ### "Procedimento" ### "Descricao Procedimento" ### "Profissional" ### "Nome Profissional"
		aTamTrf := {40, 30, 30, 30, 100, 30, 100, 30, 100, 30, 100}
		bBlkTrf := {|| aFill(Array(Len(aTamTrf)), " ")}
		oBrwTrf := TwBrowse():New(10, 20, 30, 40, bBlkTrf, aTitTrf, aTamTrf, oPanel2)
		oBrwTrf:nTop   := 180
		oBrwTrf:nLeft  := 02
		oBrwTrf:nWidth := 435
		oBrwTrf:nHeight:= 85
		
		
	Else
		If nOpc == 4  //transferencia
			Aadd(aTrfHorAge, {GM8->GM8_FILAGE, GM8->GM8_DATAGE, GM8->GM8_HORAGE, GM8->GM8_REGGER, GM8->GM8_NOMPAC, ;
			GM8->GM8_CODPLA, HS_IniPadr("GCM", 02, GM8->GM8_CODPLA, "GCM_DESPLA",, .F.), ;
			GM8->GM8_CODPRO, HS_IniPadr("GA7", 01, GM8->GM8_CODPRO, "GA7_DESC"  ,, .F.), ;
			GM8->GM8_CODCRM, HS_IniPadr("SRA", 11, GM8->GM8_CODCRM, "RA_NOME"   ,, .F.), ;
			GM8->GM8_MATRIC, GM8->GM8_CODSAL})
		Else
			FS_AgenFut()
		EndIf
		If !Empty(aTrfHorAge)
			oBrwTrf:SetArray(aTrfHorAge)
			oBrwTrf:bLine:= {|| {aTrfHorAge[oBrwTrf:nAt, 01], aTrfHorAge[oBrwTrf:nAt, 02], aTrfHorAge[oBrwTrf:nAt, 03], aTrfHorAge[oBrwTrf:nAt, 04], aTrfHorAge[oBrwTrf:nAt, 05], aTrfHorAge[oBrwTrf:nAt, 06],aTrfHorAge[oBrwTrf:nAt, 07], aTrfHorAge[oBrwTrf:nAt, 08], aTrfHorAge[oBrwTrf:nAt, 09], aTrfHorAge[oBrwTrf:nAt, 10], aTrfHorAge[oBrwTrf:nAt, 11], aTrfHorAge[oBrwTrf:nAt, 12]}}
			oBrwTrf:Refresh()
		EndIf
	EndIf
EndIf

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM29MotDes  ³Autor³Paulo Emidio de Barros³Data³06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a Descricao do Motivo do Cancelamento/Transferencia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29MotDes()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T ou F                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM29MotDes()
Local lRetorno := .T.
                
If NaoVazio()
	GM7->(dbSetOrder(1)) // GM7_FILIAL + GM7_CODCAN
	GM7->(dbSeek(xFilial("GM7")+M->GM8_MOTIVO))
	If GM7->(!Eof())
		M->GM8_DESMOT := GM7->GM7_DESCAN
	Else
		HS_MsgInf("RECNO", STR0077, STR0105)  //"Atenção"###"Retorna a Descricao do Motivo do Cancelamento/Transferencia"
		lRetorno   := .F.
	EndIf
Else
	M->GM8_DESMOT := CriaVar("GM8_DESMOT",.T.,,.F.)
	lRetorno := .F.
EndIf

Return(lRetorno)

Function HSPM29OriCan()
cGm7OriCan := M->GM8_ORICAN
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM29PaintCalend³Autor³Paulo Emidio de Barros³Data³06/01/05³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controle da Pintura do Calendario da Agenda                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29PaintCalend()                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29PaintCalend()
Local nDia    := 0
Local nCor1   := 0
Local nCor2   := 0
Local dDiaAge := Ctod("")
Local nPosDia := 0
Local dFinal  := LastDay(oCalend:dDiaAtu)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controla a pintura do Calendario na Agenda                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nDia := 1 To Day(dFinal) //Ultimo dia do Mes Selecionado

	dDiaAge := Ctod(Stuff(Dtoc(dFinal),1,2,StrZero(nDia,2)))
	nPosDia := Ascan(aAgenda[nFldAtu,1],{|x|x[1]==dDiaAge})
             
	If (nPosDia > 0)
	
		If (aAgenda[nFldAtu,1,nPosDia,3] == 0) //Ocupado
			nCor1 := CLR_HRED
			nCor2 := CLR_HRED
		ElseIf (aAgenda[nFldAtu,1,nPosDia,2] > aAgenda[nFldAtu,1,nPosDia,6]) .And.; //Parcial
			(aAgenda[nFldAtu,1,nPosDia,6] > 0)
			nCor1 := CLR_BLUE
			nCor2 := CLR_BLUE
		ElseIf (aAgenda[nFldAtu,1,nPosDia,6] == 0) //Livre
			nCor1 := CLR_GREEN
			nCor2 := CLR_GREEN
		EndIf
		
	Else
		nCor1 := CLR_BLACK
		nCor2 := CLR_WHITE
	EndIf
	
	oCalend:AddRestri(Day(dDiaAge),nCor1,nCor2)
	
Next nDia

//Sincroniza o dia selecionado com o Calendario
oCalend:dDiaAtu := If(Empty(aAgenda[nFldAtu,1,nDiaAgeAtu,1]),oCalend:dDiaAtu,aAgenda[nFldAtu,1,nDiaAgeAtu,1]) //Dia Atual
oCalend:Refresh()

oMeses:nAt := Month(oCalend:dDiaAtu)
oMeses:Refresh()

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM29MkDia   ³Autor³Paulo Emidio de Barros³Data³24/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Marca e Posiciona o dia a ser Agendado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29MkDia()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ T ou F                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29MkDia()
Local nPosDia  := 0
Local lRetorno := .T.

If Len(aAgenda) > 0
	
	nPosDia := Ascan(aAgenda[nFldAtu,1],{|x|x[1]==oCalend:dDiaAtu})
	
	If (nPosDia == 0)
		lRetorno := .F.
	Else
		
		//Verifica se o Horario foi preeenchido, caso seja um Encaixe
		If HSPM29VerHorEnc(nFldAtu)
			nDiaAgeAnt := aOBJETOS[nFldAtu,1]:nAt
			nDiaAgeAtu := nPosDia //Define a selecao do dia Atual
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva a Marcacao efetuada anteriormente                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HSPM29SavAge(nFldAtu,nFldAtu,nDiaAgeAtu,nDiaAgeAnt)
		EndIf
		
	EndIf
	
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM29VldHor  ³Autor³Paulo Emidio de Barros³Data³26/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a Hora informada para o Encaixe no Agendamento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29VldHor()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ T ou F                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM29VldHor()
Local cHora    := &(ReadVar())
Local lRetorno := .T., cAliasOld := Alias()
Local lTemRec  := !Empty(cCodRec)

DbSelectArea("GM6")
DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
DbSeek(xFilial("GM6") + cCodDis)

If !lTemRec
	If (cHora < GDFieldGet("GM8_HORINI") .Or. cHora > GDFieldGet("GM8_HORFIN"))
		HS_MsgInf(OemToAnsi(STR0056), STR0077, STR0106) //"Hora Invalida"###"Atenção"###"Valida a Hora informada para o Encaixe no Agendamento"
		lRetorno  := .F.
	ElseIf GDFieldGet("GM8_DATAGE") <= dDataBase .And. ;
		(Val(Left(cHora,2)) < 0 .Or. Val(Left(cHora,2)) > 23 .Or.;
		Val(Right(cHora,2)) < 0 .Or. Val(Right(cHora,2)) > 59 .Or.;
		Empty(Right(cHora,2)) .Or. Empty(Left(cHora,2)) .Or.;
		cHora < SubStr(Time(), 1, 5))
		HS_MsgInf(OemToAnsi(STR0056), STR0077, STR0106) //"Hora Invalida"###"Atenção"###"Valida a Hora informada para o Encaixe no Agendamento"
		lRetorno  := .F.
	ElseIf !Empty(Substr(GM6->GM6_HORENC,1,2))  .And. cHora >= GM6->GM6_HORENC
		HS_MsgInf(STR0125 + " [" + GM6->GM6_HORENC + "]" , STR0077, STR0106) //"O horário não pode ser maior/igual ao horário limite para encaixe"###"Atenção"###"Valida a Hora informada para o Encaixe no Agendamento"
		lRetorno  := .F.
	EndIf
Else
	If (cHora < cEncIni .Or. cHora > cEncFim)
		HS_MsgInf(OemToAnsi(STR0056), STR0077, STR0106) //"Hora Invalida"###"Atenção"###"Valida a Hora informada para o Encaixe no Agendamento"
		lRetorno  := .F.
	ElseIf (Val(Left(cHora,2)) < 0 .Or. Val(Left(cHora,2)) > 23 .Or.Val(Right(cHora,2)) < 0 .Or. Val(Right(cHora,2)) > 59 .Or. Empty(Right(cHora,2)) .Or. Empty(Left(cHora,2)))
		HS_MsgInf(OemToAnsi(STR0056), STR0077, STR0106) //"Hora Invalida"###"Atenção"###"Valida a Hora informada para o Encaixe no Agendamento"
		lRetorno  := .F.
	ElseIf !Empty(Substr(GM6->GM6_HORENC,1,2)) .And. cHora >= GM6->GM6_HORENC
		HS_MsgInf(STR0125 + " [" + GM6->GM6_HORENC + "]" , STR0077, STR0106) //"O horário não pode ser maior/igual ao horário limite para encaixe"###"Atenção"###"Valida a Hora informada para o Encaixe no Agendamento"
		lRetorno  := .F.
	EndIf
EndIf
DbSelectArea(cAliasOld)
If lRetorno // Somente se for hora valida
	FS_RestMem() // Restaura as variaveis de memória
	&(ReadVar()) = cHora // Recupera a hora digitada
	If oFolder:nOption == 2 .And. !empty(cHora)
		lRetorno := HSPM29Marca("2",oFolder,.T.,/*oObj*/, /*dDatAgd*/, /*lLimpAgd*/,/* nPosDia*/,cHora) // Simula o duplo click
	Endif
Endif
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM29FilBrw  ³Autor³Paulo Emidio de Barros³Data³26/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra o Agendamento de acordo com a Situacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29FilBrw(EXPL1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = .T. Liga o Filtro                                  ³±±
±±³		     ³  	   .F. Desliga o Filtro                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ HSPAHM29		                                 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29FilBrw(lSetFilter, lFiltro)
Local oObjMBrw
If lM29ChaExt
	Return(Nil)
EndIf

oObjMBrw := GetObjBrow()

cFilM29 := "GM8_FILIAL = '" + xFilial("GM8") + "' And GM8_DATAGE >= '" + DToS(dDataBase) + "'"

If lFiltro
	cFilM29 += " And GM8_STATUS IN ( '1', '4', '5', '8' )"
EndIf

If Hs_ExisDic({{"C","GM8_AGDPRC"}}, .F.)
	cFilM29 += " And (GM8_CODAGE = GM8_AGDPRC Or GM8_STATUS = '8' )"
EndIf

If ExistBlock("HSPAFILAG")
	cFilM29 := ExecBlock("HSPAFILAG",.F.,.F.,{cFilM29} )
EndIf

If lSetFilter
	MsgRun(STR0057,STR0058,{||SetMBTopFilter("GM8", cFilM29), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando os Agendamentos..." ### "Aguarde..."
EndIf
                
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM29Perg    ³Autor³Paulo Emidio de Barros³Data³26/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe a pergunta para informar o Setor a ser filtrado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29Perg(EXPL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = .T. aciona o Filtro                                ³±±
±±³			       ³         .F. Nao aciona o Filtro                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL2 = T ou F                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM29Perg()
Local lRetorno

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aciona o Filtro de acordo com o Novo Setor informado 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRetorno := Pergunte("HSPM29",.T.) )
	
	cGcsCodLoc := MV_PAR01
	
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM29VerDis  ³Autor³Paulo Emidio de Barros³Data³01/02/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica a disponibilidade de Horario para Atendimento no  ³±±
±±³          ³ Agendamento Ambulatorial. (Obs. o registro a ser analisado ³±±
±±³          ³ no GM8, devera estar posicionado.)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM29VerDis()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T ou F                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSPAHM29                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM29VerDis(cAliasGm8)
Local lRetorno := .T.
   
//Verifica a existencia do procedimento vinculado a Disponibilidade
GM3->(dbSetOrder(1)) // GM3_FILIAL + GM3_CODDIS + GM3_CODPRO
GM3->(DbSeek(xFilial("GM3")+(cAliasGm8)->GM8_CODDIS+M->GM8_CODPRO))
If GM3->(Eof())
	lRetorno := .F.
EndIf
		       
//Verifica a existencia de Local de Atendimento x Procedimento
If lRetorno
	GM2->(dbSetorder(1)) // GM2_FILIAL + GM2_CODLOC + GM2_CODPRO
	GM2->(DbSeek(xFilial("GM2")+(cAliasGm8)->GM8_CODLOC+M->GM8_CODPRO))
	If GM2->(Eof())
		lRetorno := .F.
	EndIf
EndIf
			
//Verifica a existencia de Disponibilidade para Convenio Nao Atendido
If lRetorno
	GM4->(dbSetorder(1)) // GM4_FILIAL + GM4_CODDIS + GM4_CODPLA
	GM4->(DbSeek(xFilial("GM4")+(cAliasGm8)->GM8_CODDIS+M->GM8_CODPLA))
	If GM4->(!Eof())
		lRetorno := .F.
	EndIf
EndIf
			      
//Verifica a existencia do Local de Atendimento x Convenio Nao Atendido
If lRetorno
	GM0->(dbSetOrder(1)) // GM0_FILIAL + GM0_CODLOC + GM0_CODPLA
	GM0->(DbSeek(xFilial("GM0")+(cAliasGm8)->GM8_CODLOC+M->GM8_CODPLA))
	If GM0->(!Eof())
		lRetorno := .F.
	EndIf
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |HS_VlM29Coº Autor ³ PAULO JOSE DE OLIVEIRA º Data ³ 11.03.2005  º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida as Perguntas da Consulta                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar - funcao de consulta HS_M29CONS()            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VlM29Co(cCpoVld)
Local lRet      := .T.

Default cCpoVld := ReadVar()

PswOrder(2)  // Nome do usuario (tam=15)

If cCpoVld == "MV_PAR11"
	If !Empty(MV_PAR11) .And. !(lRet := PswSeek(MV_PAR11, .T.))
		HS_MsgInf(STR0081, STR0077, STR0107) //"Usuario invalido"###"Atenção"###"PLANO E PROCEDIMENTO"
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_M29EXT ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 17.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Extrato do paciente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M39EXT                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M29EXT(cAlias, nReg, nOpc)
Local cCodPac := ""
	
If !Pergunte("HSP29A", .T.)
	Return()
EndIf

If !Empty(MV_PAR01) .and. MV_PAR01 <> GM8->GM8_REGGER
	cCodPac := MV_PAR01
Endif
	
If Empty(cCodPac)
	cCodPac := GM8->GM8_REGGER
Endif

HS_EXTM24C(cCodPac, "P", nOpc)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M29CFM º Autor ³PAULO JOSE DE OLIVEIRA  º Data ³  16.03.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ TELA DE CONFIRMACAO DA CONSULTA                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar M29                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M29CFM(cAlias,nReg,nOpc)

Local oDlgCfm   := nil
Local oEnc      := nil
Local lRet      := .T.
Local aArea     := GetArea()
Local cTitulo   := STR0082 //"Cornfirma horario agendado."
Local aCpoEnc   := {}
Local aCpoEdita := {}
Local	aCoordEnc := {015,003,65,280} //Define as coordenadas do cabecalho do Agendamento
Local nOp := 0
 
if GM8->GM8_STATUS $ "4/5/8"
	RestArea(aArea)
	HS_MsgInf(STR0083 , STR0077, STR0107) //"Este horário não pode ser confirmado."###"Atenção"###"PLANO E PROCEDIMENTO"
	return
endif

DbSelectArea("SX3")
DbSetOrder(1) // X3_TABELA
DbSeek("GM8")
While !Eof() .And. (x3_arquivo == "GM8")
	If cNivel >= SX3->X3_NIVEL .And. alltrim(x3_campo) $ "GM8_REGGER/GM8_NOMPAC/GM8_DESCFM"
		AADD(aCpoEnc, x3_campo)
		if x3_campo $ "GM8_DESCFM"
			AADD(aCpoEdita, x3_campo)
		endif
	Endif
	wVar := "M->" + SX3->X3_CAMPO
	&wVar:= IIf(SX3->X3_CONTEXT == "V", CriaVar(SX3->X3_CAMPO), GM8->(FieldGet(FieldPos(SX3->X3_CAMPO))))
	dbSkip()
End

dbSelectArea("GM8")

DEFINE MSDIALOG oDlgCfm TITLE OemToAnsi(cTitulo)  From 002,000 to 130,560 of oMainWnd PIXEL

oEnc  := MsMGet():New(cAlias, nReg, GD_UPDATE,,,, aCpoEnc, aCoordEnc, aCpoEdita, 3,,,, oDlgCfm,, .T.,,,,,,.T.)


ACTIVATE MSDIALOG oDlgCfm CENTERED ON INIT EnchoiceBar(oDlgCfm, {|| nOp := 1, oDlgCfm:End()}, {|| nOp := 0, oDlgCfm:End()},,/*aButtons*/ )

If nOp == 1
	RecLock("GM8",.F.)
	GM8->GM8_STATUS := "5"      //Status para definir o Agendamento CONFIRMADO
	GM8->GM8_DESCFM := M->GM8_DESCFM
	GM8->GM8_DATCFM := dDataBase
	GM8->GM8_HORCFM := SubStr(Time(),1,5)
	GM8->GM8_USUCFM := cUserName
	GM8->GM8_LOGARQ := HS_LogArq()
	MsUnLock()
EndIf

RestArea(aArea)
 
Return(Nil)                  			

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_HorAge()³ Autor ³ Paulo jose de Oliveira³ Data ³ 07.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se o paciente ja usou o porcedimento e mostra os     ±±
±±³          ³ agendamentos com data > que atual                          |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_M39EXT                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_HorAge()

Local aArea 		:= GetArea()
Local cFiltro := ""
Local lAchou	:= .F.
Local lDatRetOk  := .F.
Local cSQL      := ""

Local oDlg	:= Nil

Local aListCpo
Local cChave

Local aSize := MsAdvSize()

If !Empty(M->GM8_REGGER)
	DbSelectArea("GM8")
	DbSetOrder(10) // GM8_FILIAL + GM8_REGGER + GM8_CODPRO + GM8_DATAGE + GM8_STATUS
	
	DbSeek(xFilial("GM8") + M->GM8_REGGER + M->GM8_CODPRO + DtoS(dDataBase), .T.) // SoftSeek ligado
	Do While !Eof() .and. xFilial("GM8") + M->GM8_REGGER + M->GM8_CODPRO == GM8->GM8_FILIAL + GM8->GM8_REGGER + GM8->GM8_CODPRO
		If GM8->GM8_DATAGE >= dDataBase .and. GM8->GM8_STATUS $ "1/4/5"
			lAchou := .T.
			Exit
		Else
			DbSkip()
		Endif
	Enddo
	
	If lAchou
		cFiltro := "GM8->GM8_FILIAL == '" + xFilial("GM8")	+ "' .and. "
		cFiltro += "GM8->GM8_REGGER == '" + M->GM8_REGGER 	+ "' .and. "
		cFiltro += "GM8->GM8_CODPRO == '" + M->GM8_CODPRO 	+ "' .and. "
		cFiltro += "DtoS(GM8->GM8_DATAGE) >= '" + DtoS(dDataBase) 	+ "'"
		
		aLstCpo  := {"GM8_FILAGE","GM8_DATAGE","GM8_HORAGE","GM8_REGGER","GM8_NOMPAC", ;
		"GM8_DESPRO","GM8_CODCRM","GM8_NOMCRM","GM8_DESPLA","GM8_DATCAD","GM8_HORCAD","GM8_CODUSU","GM8_CODSAL","GM8_NOMSAL"}
		
		cChave   := "GM8_REGGER"
		
		MsgRun(OemToAnsi(STR0057), OemToAnsi(STR0058), {||DbSetFilter({|| &cFiltro}, cFiltro)})  //"Selecionando os Agendamentos..." //"Aguarde..."
		
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0076) From aSize[7],000 To aSize[6],aSize[5] Of GetWndDefault() PIXEL  // "Consulta Horários Agendados"
		
		oGet := HS_MBrow(oDlg, "GM8", {aSize[7], 001, aSize[3], aSize[4]-15}, ,,,,,,, cChave, , .F.,, .T. ,aLstCpo, ,, aLstCpo)
		
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()} )
		
		DbClearFilter()
		
	EndIf
Endif

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_PROMED ºAutor  ³Daniel Peixoto      º Data ³  18/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna todos os procedimentos(GD7) realizados dentro do   º±±
±±º          ³ periodo de retorno para o mesmo Paciente e Medico          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ProMed(cCodCrm       , cCodPro        , cRegGer      , nDiaRet, cCodTpg, cHorRet, cCodLoc)
Local lRet     	 := .T.
Local aJoin    	 := {}
Local aAux     	 := {}
Local aCGD7  	 := {}
Local aHGD7 	 := {}
Local nGDOpc   	 := 0 //só visualização
Local nNroDsp  	 := 0
Local nGD7DatDes := 0
Local nPObjs 	 := 0
Local nNroTela 	 := 0
Local i        	 := 0
Local nProced  	 := 0
Local nUGD7 	 := 0
Local nAtOldGcz  := 0
Local cLstCpo  	 := ""
Local cCond    	 := ""
Local cUsuAut  	 := ""
Local cCondGCZ 	 := ""
Local cMsgGuia 	 := ""
Local cMsgGNova  := ""
Local cMsgNGcz   := ""
Local cCodPla  	 := ""
Local cNrSegG  	 := ""
Local dPerRet  	 := dDataBase - nDiaRet
Local dUltDat  	 := CTOD("  /  /  ")
Local cSenha   	 := Space(15)
Local cUsu     	 := Space(Len(GM1->GM1_CODUSU))
Local cProcRet 	 := GetMV("MV_PROCRET",, "0")
Local aSize    	 := MsAdvSize()
Local oGD7
Local oDlg

Private lIsCaixa := IsCaixaLoja(xNumCaixa())
Private nAtNewGcz  := 0
Private lCalRet := .F.   //Definindo váriavel para que não seja calculado
Private cObj := ""
 
Default cCodTpg := ""
Default cHorRet := ""

aAux := Hs_CalcDat(dPerRet, time(), "-", cHorRet)
dPerRet := aAux[1]
cHorRet := aAux[2]

aJoin := {{" JOIN " + RetSqlName("GCY") + " GCY", "GCY.GCY_REGGER", "GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GD7.GD7_REGATE", "GD7_REGGER"}}

cCond := "     GD7_CODDES = '" + cCodPro + "'"+;
" AND (GD7_DATDES = '" +DTOS(dPerRet) + "' AND GD7_HORDES >= '"+cHorRet+"' OR GD7_DATDES > '" +DTOS(dPerRet) + "')"+;
" AND GD7_DATDES <= '" +DTOS(dDataBase)+ "' AND GCY_REGGER = '" + cRegGer + "'"

If cProcRet <> "1"
	cCond += " AND GD7_CODCRM = '" + cCodCrm +"' "
Endif

cLstCpo := "GD7_REGATE/GD7_CODDES/GD7_DDESPE/GD7_DATDES/GD7_HORDES/GD7_CODCRM/GD7_NOMMED"

If (nNroDsp := HS_BDados("GD7", @aHGD7, @aCGD7, @nUGD7, 4, , cCond,,,cLstCpo,,,,,,.T.,,,,,,, aJoin)) > 0
	
	If HS_INIPADR("GCS", 1, cCodLoc, "GCS_PERRET",, .F.) == "0"
		HS_MSGINF(STR0141+cCodPro+"] - "+Hs_inipadr("GA7", 1, cCodPro, "GA7_DESC",,.F.)+; //"O procedimento ["
		STR0142+cCodLoc+"] - "+HS_IniPadR("GCS", 1, cGcsCodLoc, "GCS_NOMLOC",, .F.)+; //" está em período de retorno, mas o Setor ["
		STR0143,STR0077,STR0144) //" não permite retorno"###"Validação Retorno"
		Return({0, .F.})
	EndIf
	
	If nDiaRet > 0 .And. FunName() == "HSPAHM29"
		nGD7DatDes := aScan(aHGD7, {|aVet| aVet[2] == "GD7_DATDES"})
		dUltDat := aCGD7[len(aCGD7), nGD7DatDes]+ nDiaRet
	Endif
	
	DbSelectArea("GM1")
	DbSetOrder(1) // GM1_FILIAL + GM1_CODLOC + GM1_CODUSU
	DbSeek(xFilial("GM1") + cGcsCodLoc)
	While !EOF() .And. xFilial("GM1") == GM1->GM1_FILIAL .And. GM1->GM1_CODLOC == cGcsCodLoc
		If GM1->GM1_AUTORI == "1"
			cUsuAut += IIF(!EMPTY(cUsuAut), "/", "") + UPPER(ALLTRIM(GM1->GM1_CODUSU))
		EndIf
		DbSkip()
	EndDo
	
	nNroTela := IIF(EMPTY(cUsuAut), 1, IIF( UPPER(AllTrim(cUserName)) $ cUsuAut,1, 2))
	If nNroTela == 1
		nNroTela := IIF(nDiaRet > 0, IIF(FunName() == "HSPAHM29",3 , 1 ), 1)
	Endif
	aSize := MsAdvSize(.T.)
	aObjects := {}
	
	If nNroTela == 1
		AAdd( aObjects, { 100, 100, .T., .T. } )
		nPObjs := nNroTela
	ElseIf nNroTela == 2
		AAdd( aObjects, { 100, 020, .T., .T. } )
		AAdd( aObjects, { 100, 080, .T., .T. } )
		nPObjs := nNroTela
	Else
		AAdd( aObjects, { 100, 005, .T., .T. } )
		AAdd( aObjects, { 100, 095, .T., .T. } )
		nPObjs := 2
	EndIf
	
	aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
	aPObjs := MsObjSize(aInfo, aObjects, .T.)
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0089) From aSize[7],000 To aSize[6],aSize[5] Of GetWndDefault() PIXEL   //"Consulta Procedimentos Realizados"
	
	If nNroTela == 2
		@ 15, 010 SAY OemToAnsi(STR0117) OF oDlg PIXEL COLOR CLR_BLUE  //"Usuario:"
		@ 15, 035 MSGET oUsuario VAR cUsu SIZE 060, 4 OF oDlg PIXEL COLOR CLR_BLACK
		@ 30, 010 SAY OemToAnsi(STR0118) OF oDlg PIXEL COLOR CLR_BLUE  //"Senha:"
		@ 30, 035 MSGET oSenha VAR cSenha SIZE 040, 4 PASSWORD OF oDlg PIXEL COLOR CLR_BLACK
		If nDiaRet > 0 .And. FunName() == "HSPAHM29"
			@ 50, 010 SAY OemToAnsi(STR0127 + DTOC(dUltDat)) OF oDlg PIXEL COLOR CLR_RED //"A data limite para retorno é : "
		Endif
	ElseIf nNroTela == 3
		@ 15, 010 SAY OemToAnsi(STR0127 + DTOC(dUltDat)) OF oDlg PIXEL COLOR CLR_RED  //"A data limite para retorno é : "
	EndIf
	
	oGD7 := MsNewGetDados():New(aPObjs[nPObjs, 1], aPObjs[nPObjs, 2], aPObjs[nPObjs, 3], aPObjs[nPObjs, 4], nGDOpc,,,,,,99999,,,, oDlg, aHGD7, aCGD7)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIF(nNroTela == 2, IIF(lRet := FS_VldSen(@cUsu, cUsuAut, cSenha), oDlg:End(), Nil), oDlg:End()) }, ;
	{|| lRet := .F., oDlg:End()} )
	
	If lRet
		If Type("oGDGcz") <> "U"	.And. Type("M->GCY_REGATE") <> "U"
			cCondGCZ := " GCZ_REGATE = '"+M->GCY_REGATE+"' AND GCZ_STATUS = '0' "+;
						" AND GCZ_CODTPG IN (SELECT GCU_CODTPG "+;
						"                      FROM "+RetSqlName("GCU")+" GCU "+;
						"                     WHERE GCU.GCU_FILIAL = '"+xFilial("GCU")+"' "+;
						"                       AND GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_TPGUIA = '7' ) "
			
			cMsgGuia  := STR0145 //"Há Guia(s) de Retorno em aberto no Atendimento. Deseja Selecionar uma dessas guias para lançamento da despesa ?"
			cMsgGNova := STR0146 //"Deseja lançar nova guia de Retorno no Atendimento?"
			cMsgNGcz  := STR0147  //"Não foi encontrado guia de Retorno em aberto no Atendimento. Deseja lançar nova guia com a despesa ?"
			
			cCodPla := HS_INIPADR("GD4",1, M->GCY_REGGER, "GD4_CODPLA",,.T.)
			cNrSeqG := Hs_RetGuia(M->GCY_REGATE, M->GCY_REGGER, M->GCY_ATENDI, M->GCY_DATATE, M->GCY_LOCATE, ;
			cCodPla, cCondGCZ, cMsgGuia, cMsgGNova, cMsgNGcz, cCodTpg, {|| "ret"} )
			
			nAtOldGcz := oGDGcz:nAt
			If Empty(cNrSeqG)
				Return({nNroDsp, lRet})
			ElseIf cNrSeqG # "ret"
				nAtNewGcz := IIF( aScan(oGDGcz:aCols, {|aVet| aVet[nGCZNRSEQG] ==  cNrSeqG}) > 0, aScan(oGDGcz:aCols, {|aVet| aVet[nGCZNRSEQG] ==  cNrSeqG}), 1)
			Else
				If !(Len(oGDGcz:aCols) == 1 .And. Empty(oGDGcz:aCols[oGDGcz:nAt, nGczNrSeqG]) .And. Len(oGDPR:aCols) == 1)
					If Len(aGczGd) == 0
						aAdd(aGczGd, {oGDGcz:nAt, {}, {}, {}, {}, {}, {}})
					EndIf
					
					oGDGcz:AddLine(.T., .F.)
					oGDGcz:lNewLine := .F.
				EndIf
				
				aAdd(aGczGd, {oGDGcz:nAt, {}, {}, {}, {}, {}, {}})
				nAtNewGcz := oGDGcz:nAt
				
				HS_VldM24(,4,,,,,.T.)
			EndIf
			
			If Len(oGDPR:aCols) # 1
				oGDPR:DelLine()
			EndIf
			
			//Carregando linhas de despesas para guia Criada
			aAdd(aGczGd[nAtNewGcz][2], {})
			nUltDesp  := Len(aGczGd[nAtNewGcz][2])
			cObj := "aGczGd[nAtNewGcz][2][nUltDesp]"
			For i := 1 to Len(oGDMM:aHeader)
				If oGDMM:aHeader[i, 2] == "HSP_STAREG"
					aAdd(&(cObj), "BR_VERMELHO")

				Else
					aAdd(&(cObj), CriaVar(oGDMM:aHeader[i, 2]))
				EndIf
			Next
			aAdd(&(cObj), .F.)
			
			aAdd(aGczGd[nAtNewGcz][3], {})
			nUltDesp  := Len(aGczGd[nAtNewGcz][3])
			cObj := "aGczGd[nAtNewGcz][3][nUltDesp]"
			For i := 1 to Len(oGDTD:aHeader)
				If oGDTD:aHeader[i, 2] == "HSP_STAREG"
					aAdd(&(cObj), "BR_VERMELHO")
				Else
					aAdd(&(cObj), CriaVar(oGDTD:aHeader[i, 2]))
				EndIf
			Next
			aAdd(&(cObj), .F.)
			
			aAdd(aGczGd[nAtNewGcz][4], {})
			nUltDesp  := Len(aGczGd[nAtNewGcz][4])
			cObj := "aGczGd[nAtNewGcz][4][nUltDesp]"
			For i := 1 to Len(oGDPR:aHeader)
				If oGDPR:aHeader[i, 2] == "HSP_STAREG"
					aAdd(&(cObj), "BR_VERMELHO")
				Else
					aAdd(&(cObj), CriaVar(oGDPR:aHeader[i, 2]))
				EndIf
			Next
			aAdd(&(cObj), .F.)
			
			&(cObj+"[nPRCodDes]") := cCodPro
			&(cObj+"[nPRDDespe]") := Hs_IniPadr("GA7", 1, cCodPro,"GA7_DESC",, .F.)
			&(cObj+"[nPRCodCrm]") := cCodCrm
			&(cObj+"[nPRNomMed]") := Posicione("SRA",11,xFilial("SRA")+cCodCrm,"RA_NOME")
			&(cObj+"[nPRCodEsp]") := Hs_IniPadr("GA7", 1, cCodPro,"GA7_CODESP",, .F.)
			&(cObj+"[nPRStaReg]") := "BR_VERMELHO"
			
			If lIsCaixa
				&(cObj+"[nPRValDes]") := oGDPR:aCols[oGDPR:nAt, nPRVALDES]
				&(cObj+"[nPRDesPer]") := oGDPR:aCols[oGDPR:nAt, nPRDesPer]
			    &(cObj+"[nPRDesVal]") := oGDPR:aCols[oGDPR:nAt, nPRDesVal]
			    &(cObj+"[nPRValTot]") := oGDPR:aCols[oGDPR:nAt, nPRValTot]
			    &(cObj+"[nPRPgtMed]") := oGDPR:aCols[oGDPR:nAt, nPRPgtMed]
			EndIf
					
			If lGFR
				&(cObj+"[nPRNomEsp]") := HS_IniPadr("GFR", 1, &(cObj+"[nPRCodEsp]"), "GFR_DSESPE",,.F.)
			Else
				&(cObj+"[nPRNomEsp]") := HS_IniPadr("SX5", 1, "EM" + &(cObj+"[nPRCodEsp]"), "X5_DESCRI",,.F.)
			Endif
			
			aLaudo     := HS_IsLaudo(cGcsCodLoc, cCodPro)
			lGd7SLaudo := aLaudo[2]
			&(cObj+"[nPRSLaudo]") := IIf(aLaudo[1], "1", "0")
			&(cObj+"[nPRCrmLau]") := IIf(!Empty(oGDGcz:aCols[nAtNewGcz, nGczCodCrm]), oGDGcz:aCols[nAtNewGcz, nGczCodCrm], &(cObj+"[nPRCrmLau]"))
			&(cObj+"[nPRNMeLau]") := IIf(!Empty(oGDGcz:aCols[nAtNewGcz, nGczNomMed]), oGDGcz:aCols[nAtNewGcz, nGczNomMed], &(cObj+"[nPRNMeLau]"))
			
			If Len(oGDPR:aCols) == 1
				oGdPr:SetArray(aGczGd[nAtNewGcz][4])
			EndIf
			
			oGDGcz:nAt := nAtOldGcz
			oGDGcz:Refresh()
			oGDPR:Refresh()
			oGDMM:Refresh()
			oGDTD:Refresh()
			
		EndIf
	EndIf
EndIf
 
Return({nNroDsp, lRet})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AgenFutºAutor  ³Daniel Peixoto      º Data ³  08/15/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche os dados dos agendados futuros para o paciente    º±±
±±º          ³ digitado(Tela - Agendamentos Futuros)                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_AgenFut()
Local aOldArea

If !Empty(M->GM8_REGGER)
	aOldArea  := GetArea()
	
	DbSelectArea("GM8") 
	DbSetOrder(10)  // GM8_FILIAL + GM8_REGGER + GM8_CODPRO + GM8_DATAGE + GM8_STATUS
	                                        
	DbSeek(xFilial("GM8") + M->GM8_REGGER + M->GM8_CODPRO + DtoS(dDataBase), .T.) // SoftSeek ligado
	Do While !Eof() .and. xFilial("GM8") + M->GM8_REGGER  == GM8->GM8_FILIAL + GM8->GM8_REGGER
		If (GM8->GM8_DATAGE = dDataBase .and. GM8->GM8_HORAGE > SubStr(Time(),1,5) .and. GM8->GM8_STATUS $ "1/4/5") .OR.;
			(GM8->GM8_DATAGE > dDataBase .and. GM8->GM8_STATUS $ "1/4/5")
			Aadd(aTrfHorAge, {GM8_FILAGE, GM8_DATAGE, GM8_HORAGE, GM8_REGGER, GM8_NOMPAC, GM8_CODPLA, ;
			HS_IniPadr("GCM",  2, GM8->GM8_CODPLA, "GCM_DESPLA",, .F.), GM8_CODPRO, ;
			HS_IniPadr("GA7",  1, GM8->GM8_CODPRO, "GA7_DESC"  ,, .F.), GM8_CODCRM, ;
			HS_IniPadr("SRA", 11, GM8->GM8_CODCRM, "RA_NOME"   ,, .F.), GM8_MATRIC})
		EndIF
		DbSkip()
	Enddo
	
	RestArea(aOldArea)
EndIf
Return()


Function HS_M29Disp()
 
Return(Nil)

Static Function FS_BCancel()
Local nI := 0
For nI := 1 to len(aLastMar)
	
	//If (nLastFld > 0)  .And. (nLastDay > 0) .And. (nLastHour > 0)
	FS_UByName("M29GM8"+aLastMar[nI, 1])
	//Endif
	
Next
While __lSx8
	RollBackSxe()
End

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M29Pac ºAutor  ³ Cibele Peria       º Data ³  05/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe paciente do agendamento, caso haja.                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_M29Pac(cAlias, nReg, nOpc)
Local aArea      := GetArea()
Local cCodPac    := ""

If !Pergunte("HSP29A", .T.)
	Return()
EndIf

If !Empty(MV_PAR01) .and. MV_PAR01 <> GM8->GM8_REGGER
	cCodPac := MV_PAR01
Endif
	
If Empty(cCodPac)
	cCodPac := GM8->GM8_REGGER
Endif

If Empty(cCodPac)
	HS_MsgInf(STR0091, STR0077, STR0108) //"Agendamento sem paciente identificado!"###"Atenção"###"Agendamento do Paciente"
Else
	DbSelectArea("GBH")
	DbSetOrder(1) // GBH_FILIAL + GBH_CODPAC
	DbSeek(xFilial("GBH") + cCodPac)
	HS_A58("GBH", RecNo(), nOpc)
	RestArea(aArea)
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M29Pac ºAutor  ³ Cibele Peria       º Data ³  05/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe paciente do agendamento, caso haja.                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VMatPla(cMatric, cCodPla, lMsgYesNo)

Local lRet := .T.

Default lMsgYesNo := .T.

If !Empty(cMatric) .And. !Empty(cCodPla)
	M->GD4_MATRIC := cMatric // A variavel de memoria eh utilizada na funcao HS_VldMatP
	lRet := HS_VldMatP(cCodPla, lMsgYesNo)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VldItv ºAutor  ³Daniel Peixoto      º Data ³  06/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o horario esta dentro do intervalo cadastrado   º±±
±±º          ³no Convenio(Periodo de horas retroativas e futuras)         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VldItv(dDatAge, cHorAge)
Local lRet     := .T.
Local aAreaOld := GetArea()
Local cSql     := ""
Local cCodCon  := HS_INIPADR("GCM", 2, M->GM8_CODPLA , "GCM_CODCON",, .F. )
Local cQtdHor  := HS_INIPADR("GA9", 1, cCodCon , "GA9_INTAGE",, .F. )
Local aRetCalc := {}
Local dDatIni  := ""
Local cHorIni  := ""
Local dDatFin  := ""
Local cHorFin  := ""

If !EMPTY(cQtdHor)
	aRetCalc := HS_CalcDat(dDatAge, cHorAge, "-", cQtdHor)
	dDatIni  := aRetCalc[1]
	cHorIni  := aRetCalc[2]
	aRetCalc := HS_CalcDat(dDatAge, cHorAge, "+", cQtdHor)
	dDatFin  := aRetCalc[1]
	cHorFin  := aRetCalc[2]
	
	DbSelectArea("GM8")
	DbSelectArea("GAQ")
	DbSelectArea("GA7")
	
	cSql := "SELECT COUNT(GM8_CODAGE) QTDAGE "
	cSql += "FROM " + RetSqlName("GM8") + " GM8 "
	If GAQ->(FieldPos("GAQ_CTRINT")) > 0
		cSql +=   "JOIN " + RetSqlName("GA7") + " GA7 ON GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND "
		cSql +=          "GA7.GA7_CODPRO = '" + M->GM8_CODPRO + "' "
		cSql +=   "JOIN " + RetSqlName("GAQ") + " GAQ ON GAQ.D_E_L_E_T_ <> '*' AND GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND "
		cSql +=          "GAQ.GAQ_GRUPRO = GA7.GA7_CODGPP AND GAQ.GAQ_CTRINT = '1' "
	EndIf
	cSql += "WHERE GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
	cSql += "AND GM8.GM8_REGGER = '" + M->GM8_REGGER + "' "
	cSql += "AND GM8.GM8_CODCON = '" + cCodCon + "' "
	cSql += "AND GM8.GM8_DATAGE||GM8.GM8_HORAGE BETWEEN '" + DTOS(dDatIni) + cHorIni + "' AND '" + DTOS(dDatFin) + cHorFin + "' "
	
	cSql := ChangeQuery(cSql)
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPGM8", .F., .F.)
	
	DbSelectArea("TMPGM8")
	
	lRet := TMPGM8->QTDAGE == 0
	
	DbCloseArea()
	
	RestArea(aAreaOld)
	
EndIf

Return(lRet)

/****************************************************************************************************************/
Function HS_RelM29(cAlias, nReg, nOpc)
GDN->(dbSetOrder(1))  // GDN_FILIAL + GDN_CODLOC + GDN_CODFIC
If GDN->(DbSeek(xFilial("GDN") + cGcsCodLoc))
	HSPAHP44(.F., cGcsCodLoc)
 EndIf 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_UnLock ºAutor  ³Daniel Peixoto      º Data ³  10/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se já existe algum horário já marcado e desbloqueiaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_UnLock(nFldAtu, nDiaAgeAtu)
Local nCont := 0

For nCont := 1 to len(aLastMar)
	FS_UByName("M29GM8"+aLastMar[nCont, 1])
	
Next

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VldSen ºAutor  ³Daniel Peixoto      º Data ³  24/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o usuario é autorizador e sua senha               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VldSen(cUsu, cUsuAut, cSenha)
Local aAreaOld := GetArea()
Local lRet     := .F.
 
If !(lRet := UPPER(ALLTRIM(cUsu)) $ cUsuAut)
	HS_MsgInf(STR0119 + CHR(10) + ; //"O usuário informado não possui autorização para liberar um retorno."
	STR0120 + cGcsCodLoc + "] - " + HS_IniPadR("GCS", 1, cGcsCodLoc, "GCS_NOMLOC",, .F.), ; //"Verifique o cadastro de Usuários permitidos do Setor ["
	STR0077, STR0121) //###"Atenção"###"Validação de Usuário"
Else
	PswOrder(2)
	If PswSeek(cUsu, .T.)
		If PswName(cSenha)
			lRet := .T.
		Else
			HS_MsgInf(STR0122, STR0077, STR0123) //"Senha Inválida."###"Atenção"###"Validação de Senha"
			lRet := .F.
		EndIf
	Else
		HS_MsgInf(STR0124, STR0077, STR0121) //"Usuário não cadastrado"###"Atenção"###"Validação de Usuário"
		lRet := .F.
	EndIf
EndIf
 
RestArea(aAreaOld)
 
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 10/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
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
Local aRotina :=	{{OemToAnsi(STR0002), "AxPesqui"   		, 0, 1, 0, nil},; //"Pesquisar" 
					 {OemToAnsi(STR0004), "HSPM29Atu"  		, 0, 3, 0, nil},; //"Agendar"
					 {OemToAnsi(STR0003), "HSPM29Atu"  		, 0, 4, 0, nil},; //"Cancelar"
					 {OemToAnsi(STR0006), "HSPM29Atu"  		, 0, 4, 0, nil},; //"Transferir"
					 {OemToAnsi(STR0005), "HSPM29Atu"  		, 0, 4, 0, nil},; //"Alterar"
					 {OemToAnsi(STR0074), "HS_ConsAge('A')"	, 0, 1, 0, nil},; //"Consultar"
					 {OemToAnsi(STR0079), "HS_M29CFM"  		, 0, 4, 0, nil},; //"Confirmar"
					 {OemToAnsi(STR0090), "HS_M29Pac"  		, 0, 2, 0, nil},; //"Paciente"
					 {OemToAnsi(STR0078), "HS_M29EXT"  		, 0, 2, 0, nil},; //"Extrato"
					 {OemtoAnsi(STR0115), "HS_RelM29"  		, 0, 2, 0, nil},; //"Docs/Relat."
					 {OemToAnsi(STR0007), "HSPAHM29Leg"		, 0, 3, 0, nil},; //"Legenda"
				     {OemToAnsi(STR0128), "HS_CONDIS"       , 0, 3, 0, nil}}  //"Consulta Médicos
Return(aRotina)               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |HS_CONDIS ºAutor  ³Bruno S. P. Santos  º Data ³  22/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que exibe a disponibilidade do profissional,         º±±
±±º          ³juntamente com os planos não atendidos e com os             º±±
±±º          ³procedimentos disponiveis para aquela disponibilidade       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_CONDIS(cAlias,nReg,nOpc)
Local  aArea      	:= GetArea()
Local  cCodCrm    	:= ""
Local  cDisponib 	:= ""
Local  aCpoIniGM5 	:= {"GM5_DIASEM","GM5_HORINI","GM5_HORFIM","GM5_CODLOC","GM5_NOMLOC","GM5_CODDIS"}
Local  aCpoCrm 		:= {"GBJ_CRM","GBJ_NOMMED"}
Local  aJoin 		:= {}
Local  aDisponib	:= {}
Local  aHGM5 		:= {} 
Local  aColGM5 		:= {}
Local  aHGM4 		:= {} 
Local  aColGM4 		:= {}
Local  aHGM3 		:= {}
Local  aColGM3 		:= {}
Local  aGrdPlan  	:= {}
Local  aGrdProc 	:= {}
Local  nCont     	:= 0
Local  nUsadoGM5 	:= 0
Local  nUsadoGM4 	:= 0
Local  nUsadoGM3 	:= 0
Local  nCodDis   	:= 0

If !Empty(GM6->GM6_CODCRM)
	HS_PosSX1({{"HSM29B", "01", GM6->GM6_CODCRM}})
EndiF

If !Pergunte("HSM29B", .T.)
	RestArea(aArea)
	Return()
EndIf

If !Empty(MV_PAR01) .and. MV_PAR01 <> GM6->GM6_CODCRM
	cCodCrm := MV_PAR01
Else
	cCodCrm := GM6->GM6_CODCRM
Endif

DbSelectArea("GBJ")
DbSetOrder(1)

If !DbSeek(xFilial("GBJ")+cCodCrm)
	RestArea(aArea)
	Return()
EndIf

//Carrega Dados Profissional
RegToMemory("GBJ",.F.)

M->GBJ_NOMMED := HS_IniPadr("SRA", 11, GBJ->GBJ_CRM, "RA_NOME",,.F.)

aSize 			:= MsAdvSize(.T.)

aObjects := {}
aAdd( aObjects, { 100, 010, .T., .T.} )
aAdd( aObjects, { 100, 045, .T., .T.,.T.} )
aAdd( aObjects, { 100, 045, .T., .T.} )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
aAdd( aObjects, { 050, 100, .T.,.T.,.T.} )
aAdd( aObjects, { 050, 100, .T.,.T.,.T.} )

aInfo  := { aPPanel[3, 2], aPPanel[3, 1], aPPanel[3, 4], aPPanel[3, 3], 0, 0 }
aPInfo := MsObjSize( aInfo, aObjects, .T., .T.)

aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GM6") + " GM6","GM6.GM6_HORINI","GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.D_E_L_E_T_ <> '*' AND GM6.GM6_CODDIS = GM5.GM5_CODDIS","GM5_HORINI"})
aAdd(aJoin,{"","GM6.GM6_HORFIM","","GM5_HORFIM"})
aAdd(aJoin,{"","GM6.GM6_CODLOC","","GM5_CODLOC"})
aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GCS") + " GCS","GCS.GCS_NOMLOC","GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GM6.GM6_CODLOC","GM5_NOMLOC"})

HS_BDados("GM5", @aHGM5, @aColGM5,@nUsadoGM5, 1,," GM6_CODCRM = '"+cCodCrm+"' ",,,,,,,,,,,,,,, aCpoIniGM5, aJoin)
nCodDis := aScan(aHGM5, {|aVet| aVet[2] == "GM5_CODDIS"})

For nCont := 1 to Len(aColGM5)
	If aColGM5[nCont, nCodDis] # cDisponib
		
		/* DISP. AMBULATORIAL X PLANO */
		aHGM4     := {}
		aColGM4   := {}
		nUsadoGM4 := 0
		aJoin := {{" LEFT JOIN " + RetSqlName("GCM") + " GCM","GCM.GCM_DESPLA","GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GM4.GM4_CODPLA","GM4_DESPLA"}}
		HS_BDados("GM4", @aHGM4, @aColGM4,@nUsadoGM4, 1,," GM4_CODDIS = '"+aColGM5[nCont, nCodDis]+"' ",,,,,,,,,,,,,,,,aJoin)
		aAdd(aGrdPlan, aClone(aColGM4))
		
		/* DISPONIBILIDADE X PROCEDIMENTO */
		aHGM3     := {}
		aColGM3   := {}
		nUsadoGM3 := 0
		aJoin := {{" LEFT JOIN " + RetSqlName("GA7") + " GA7","GA7.GA7_DESC","GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GM3.GM3_CODPRO","GM3_DESPRO"}}
		HS_BDados("GM3", @aHGM3, @aColGM3,@nUsadoGM3, 1,," GM3_CODDIS = '"+aColGM5[nCont, nCodDis]+"' ",,,,,,,,,,,,,,,,aJoin)
		aAdd(aGrdProc, aClone(aColGM3))
		
		cDisponib := aColGM5[nCont, nCodDis]
		aAdd(aDisponib,{nCont , cDisponib})
	EndIf
Next nCont

DEFINE MSDIALOG oDlg TITLE STR0128 From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd

oGBJ := MsMGet():New("GBJ", GBJ->(RecNo()),nOpc,,,,aCpoCrm, {aPPanel[1, 1], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4]},,,,,, oDlg)
oGBJ:oBox:align:= CONTROL_ALIGN_TOP

@ aPPanel[2, 1], aPPanel[2, 2] FOLDER oFolder SIZE aPPanel[2, 3], aPPanel[2, 4] Pixel Of oDlg Prompts STR0100
// oFolder:Align := CONTROL_ALIGN_TOP

oGM5         := MsNewGetDados():New(aPPanel[2, 1], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4],,,,,,,,,,, oFolder:aDialogs[1], aHGM5, aColGM5)
oGM5:bChange := {|| FS_ChgCols(aDisponib,nCodDis,aGrdPlan,aGrdProc)}
oGM5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

@ aPInfo[1, 1], aPInfo[1, 2] FOLDER oFolder1 SIZE aPInfo[1, 3], aPInfo[1, 4] Pixel Of oDlg Prompts STR0129
// oFolder2:Align := CONTROL_ALIGN_RIGHT
oGM3 := MsNewGetDados():New(aPInfo[1, 1], aPInfo[1, 2], aPInfo[1, 3], aPInfo[1, 4],,,,,,,,,,, oFolder1:aDialogs[1], aHGM3, aColGM3)
oGM3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

@ aPInfo[2, 1], aPInfo[2, 2] FOLDER oFolder2 SIZE aPInfo[2, 3], aPInfo[2, 4] Pixel Of oDlg Prompts STR0130
// oFolder1:Align := CONTROL_ALIGN_LEFT
oGM4 := MsNewGetDados():New(aPInfo[2, 1], aPInfo[2, 2], aPInfo[2, 3], aPInfo[2, 4],,,,,,,,,,, oFolder2:aDialogs[1], aHGM4, aColGM4)
oGM4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg,	{|| oDlg:End()},	{|| oDlg:End()})

MBrChgLoop(.F.)
Return(nil)

Static Function FS_ChgCols(aDisponib,nCodDis,aGrdPlan,aGrdProc)
Local nId := aScan(aDisponib,{|aVet| aVet[2] == oGM5:aCols[oGM5:oBrowse:nAt, nCodDis]})

oGM4:SetArray(aGrdPlan[nId])
oGM4:oBrowse:Refresh()

oGM3:SetArray(aGrdProc[nId])
oGM3:oBrowse:Refresh()
  
Return(nil)

Static Function FS_LByName(cChave)
Local lRet := .F.

If lRet := LockByName(cChave, .T., .T., .F.)
	aAdd(aLocks, cChave)
EndIf

Return(lRet)

Static Function FS_UByName(cChave)
Local nPos := 0
 
If UnLockByName(cChave, .T., .T., .F.)
	If (nPos := aScan(aLocks, {|x| x == cChave })) > 0
		aDel(aLocks, nPos)
		aSize(aLocks,Len(aLocks)-1)
	EndIf
EndIf
 
Return()

Function Hs_M29Vld()
Local aArea  := getArea()
Local lRet   := .T.
Local cCampo := Substr(ReadVar(),4)

If(cCampo == "GO4_CODPRO")
	If !(lRet := !HS_LDesExc(HS_INIPADR("GCM", 2, M->GM8_CODPLA , "GCM_CODCON",, .F. ), M->GM8_CODPLA, "1", oGO4:aCols[oGO4:nAt, nGO4_CODPRO], oCalend:dDiaAtu)[1])
		HS_MsgInf("Procedimento não possui cobertura do convênio.", STR0077, STR0095)   //"Atenção"###"Consistencias necessarias para o Filtro"
	ElseIf !(lRet := M->GO4_CODPRO # M->GM8_CODPRO)
		HS_MsgInf("Verifique duplicidade do procedimento", STR0077, STR0137)   //"Procedimento não encontrado"###"Atenção"###"Consistencias necessarias para o Filtro"
	ElseIf !(lRet := HS_SEEKRET('GA7', 'M->GO4_CODPRO', 1, .F., "oGO4:aCols[oGO4:nAt, nGO4_DESPRO]", 'GA7_DESC'))
		HS_MsgInf(OemToAnsi(STR0069), STR0077, STR0137)   //"Procedimento não encontrado"###"Atenção"###"Consistencias necessarias para o Filtro"
	EndiF
EndIf

RestArea(aArea)
Return(lRet)

Static Function Fs_MntGetD(oDlg, nFolder, aCols, cDispon, lTemRec, nOpc,aPnl,cCpoEnc)

Local aOpcNGD := {}
Local aAltera := {}, aAlteraT := {}
Local aHGM8   := {}, aCGM8 := {}, nUGM8 := 0
Local cAltera := ""  
Local nAltera := 0
Local nI 	  := 0
Local oGetAte

Private nQtdEnc := 0 
Private cDisp := cDispon 

Default aCols := {}, lTemRec := .F.

Aadd(aOpcNGD,0)
Aadd(aOpcNGD,GD_UPDATE)

Aadd(aAltera,{})
If lTemRec .And. nFolder == 2
	If nQtdEnc == 0
		HS_SeekRet("GM6", "cDisp", 1, .F., {"nQtdEnc"}, {"GM6_QTENCX"})
	EndIf
	
	For nI := 1 to nQtdEnc
		Aadd(aAlteraT,"HORARIO" + StrZero(nI, 3))
	Next
	
	Aadd(aAltera,{aAlteraT})
	
Else
	
	Aadd(aAltera,{"GM8_HORAGE"})
EndIf

If aPnlGetDados[nFolder] == nil     
	oPnlGetDados	      := tPanel():New(000,000,,oDlg,,,,,,150,150)
	oPnlGetDados:Align    := CONTROL_ALIGN_ALLCLIENT
	aPnlGetDados[nFolder] := oPnlGetDados
Else
	aPnlGetDados[nFolder]:FreeChildren()
EndIF

If lTemRec
	aHGM8 := Fs_MntHead(nFolder, @aCols, cDispon, nOpc)
	aCGM8 := aClone(aCols)
Else
	HS_BDados("GM8",@aHGM8,@aCGM8,@nUGM8,1," ",NIL,,"GM8_STATUS",,,cCpoEnc,.T.)
EndIf

oGetAte := MsNewGetDados():New(065,003.5,126.5,499.5,aOpcNGD[nFolder],"AllwaysTrue()","AllwaysTrue()","",Iif(lTemRec .And. nFolder == 2, aAltera[nFolder][1], aAltera[nFolder]),,,,,,aPnlGetDados[nFolder],aHGM8,aCGM8)
oGetAte:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetAte:oBrowse:blDblClick:={||FS_RestMem(),HSPM29Marca("2",oFolder)} //Marca o Agendamento pela Disponibilidade
oGetAte:oBrowse:bGotFocus:={||FS_SaveMem("GM8")}
oGetAte:oBrowse:bChange:={||HSPM29Marca("1",oFolder)}
oGetAte:oBrowse:bLostFocus:={||HSPM29SavAge(NIL,nFldAtu,NIL,nDiaAgeAtu),FS_RestMem()}      
oGetAte:Refresh()
oDlg:Refresh()
Return(oGetAte)

Static Function Fs_MntHead(nFolder, aCols, cDispon, nOpc)
Local aArea    := getArea()
Local aHeader  := {}
Local aStruct  := HS_CfgSx3("GM8_CODREC")
Local nCont    := 1
Local aAux     := {}
Local nI       := 0
Local nPos     := 0
 

Default nOpc := nOpcDef
//manter as variaveis abaixo como private
Private  cHorIni := "", cHorFim := "", cIntMar := "",cDisp := cDispon , nQtdEnc := 0 


HS_SeekRet("GM6", "cDisp", 1, .F., {"cHorIni", "cHorFim", "cIntMar", "nQtdEnc"}, {"GM6_HORINI", "GM6_HORFIM","GM6_INTMAR","GM6_QTENCX"})

aAdd(aHeader,	{"Recurso", "Recurso", aStruct[Sx3->(FieldPos("X3_PICTURE"))], aStruct[Sx3->(FieldPos("X3_TAMANHO"))], aStruct[Sx3->(FieldPos("X3_DECIMAL"))], aStruct[Sx3->(FieldPos("X3_VALID"))], aStruct[Sx3->(FieldPos("X3_USADO"))], aStruct[Sx3->(FieldPos("X3_TIPO"))], "", aStruct[Sx3->(FieldPos("X3_CONTEXT"))], aStruct[Sx3->(FieldPos("X3_CBOX"))], "", ""}) //"Recurso"###"Recurso"

aStruct := HS_CfgSx3("GM8_HORAGE")

cEncIni := cHorIni
cEncFim := cHorFim

If nFolder == 1
	If (nOpc # 3) .And. (nOpc # 5)
		For nI := 1 to len(aCols)
			aAdd(aAux,{aCols[nI, 1]})
		Next
		
		While cHorIni <= cHorFim
			aAdd(aHeader,	{"", "LEGENDA" + StrZero(nCont, 3), "@BMP", 3, aStruct[Sx3->(FieldPos("X3_DECIMAL"))], aStruct[Sx3->(FieldPos("X3_VALID"))], aStruct[Sx3->(FieldPos("X3_USADO"))], aStruct[Sx3->(FieldPos("X3_TIPO"))], "", aStruct[Sx3->(FieldPos("X3_CONTEXT"))], aStruct[Sx3->(FieldPos("X3_CBOX"))], "", ""}) //"LEGENDA"
			aAdd(aHeader,	{IIF(nCont == 1, "HORARIO", ""), "HORARIO" + StrZero(nCont, 3), aStruct[Sx3->(FieldPos("X3_PICTURE"))], aStruct[Sx3->(FieldPos("X3_TAMANHO"))], aStruct[Sx3->(FieldPos("X3_DECIMAL"))], aStruct[Sx3->(FieldPos("X3_VALID"))], aStruct[Sx3->(FieldPos("X3_USADO"))], aStruct[Sx3->(FieldPos("X3_TIPO"))], "", aStruct[Sx3->(FieldPos("X3_CONTEXT"))], aStruct[Sx3->(FieldPos("X3_CBOX"))], "", ""}) //"HORARIOS"
			
			For nI := 1 to len(aCols)
				If (nPos := aScan(aCols[nI], {|aVet| IIF(valType(aVet) # "C",.F., aVet == cHorIni)})) > 0
					aAdd(aAux[nI], aCols[nI, nPos-1])
					aAdd(aAux[nI], aCols[nI, nPos  ])
				Else
					aAdd(aAux[nI], "")
					aAdd(aAux[nI], "")
				EndIf
			Next
			
			cHorIni := HS_SOMAHOR(cHorIni, cIntMar)
			nCont++
		End
		
		For nI := 1 to len(aCols)
			aAdd(aAux[nI],.F.)
		Next
		
	Else
		For nCont := 1 to len(aLastMar)
			aAdd(aHeader,	{"", "LEGENDA" + StrZero(nCont, 3), "@BMP", 3, aStruct[Sx3->(FieldPos("X3_DECIMAL"))], aStruct[Sx3->(FieldPos("X3_VALID"))], aStruct[Sx3->(FieldPos("X3_USADO"))], aStruct[Sx3->(FieldPos("X3_TIPO"))], "", aStruct[Sx3->(FieldPos("X3_CONTEXT"))], aStruct[Sx3->(FieldPos("X3_CBOX"))], "", ""}) //"LEGENDA"
			aAdd(aHeader,	{IIF(nCont == 1, "HORARIO", ""), "HORARIO" + StrZero(nCont, 3), aStruct[Sx3->(FieldPos("X3_PICTURE"))], aStruct[Sx3->(FieldPos("X3_TAMANHO"))], aStruct[Sx3->(FieldPos("X3_DECIMAL"))], aStruct[Sx3->(FieldPos("X3_VALID"))], aStruct[Sx3->(FieldPos("X3_USADO"))], aStruct[Sx3->(FieldPos("X3_TIPO"))], "", aStruct[Sx3->(FieldPos("X3_CONTEXT"))], aStruct[Sx3->(FieldPos("X3_CBOX"))], "", ""}) //"HORARIOS"
		Next
		
		For nCont := 1 to len(aCols)
			aAdd(aCols[nCont], .F.)
		Next
	EndIf
Else
	If nOpc == 5 .And. nQtdEnc > 1
		nQtdEnc := 1
	EndIf
	
	For nCont := 1 to nQtdEnc
		aAdd(aHeader,	{"", "LEGENDA" + StrZero(nCont, 3), "@BMP", 3, aStruct[Sx3->(FieldPos("X3_DECIMAL"))], aStruct[Sx3->(FieldPos("X3_VALID"))], aStruct[Sx3->(FieldPos("X3_USADO"))], aStruct[Sx3->(FieldPos("X3_TIPO"))], "", aStruct[Sx3->(FieldPos("X3_CONTEXT"))], aStruct[Sx3->(FieldPos("X3_CBOX"))], "", ""}) //"LEGENDA"
		aAdd(aHeader,	{Iif(nQtdEnc == 1,"Encaixe","Encaixe"+ StrZero(nCont, 2)) , "HORARIO" + StrZero(nCont, 3), aStruct[Sx3->(FieldPos("X3_PICTURE"))], aStruct[Sx3->(FieldPos("X3_TAMANHO"))], aStruct[Sx3->(FieldPos("X3_DECIMAL"))], aStruct[Sx3->(FieldPos("X3_VALID"))], aStruct[Sx3->(FieldPos("X3_USADO"))], aStruct[Sx3->(FieldPos("X3_TIPO"))], "", aStruct[Sx3->(FieldPos("X3_CONTEXT"))], aStruct[Sx3->(FieldPos("X3_CBOX"))], "", ""}) //"HORARIOS"
	Next
	
	For nCont := 1 to Len(aCols)
		aAdd(aAux, {})
		For nI := 1 to (nQtdEnc*2)+1
			If nI > Len(aCols[nCont]) .Or.  ValType(aCols[nCont, nI]) == "L"
				aAdd(aAux[nCont], "")
			Else
				aAdd(aAux[nCont], aCols[nCont, nI])
			EndIf
		Next
		aAdd(aAux[nCont] , .F.)
	Next
	
EndIf

If !Empty(aAux)
	aCols := aAux
EndIf

RestArea(aArea)
return(aHeader)

Function Hs_VldMarc(aCodAge, cCodDis, cCodRec, dData, cHorIni, cIntMar, cDuracao, lMsg, lBlqReg, dProxDat, cProxHor, lVldPriDat, cTipAge)
Local aArea     := getArea()
Local lRet      := .T.
Local cHorFim   := ""
Local nQtdInt   := 1
Local cSql      := ""
Local nI        := 0, nX := 0
Local cDatAux   := ""
Local cWhereDat := ""
Local lEnc    	:= .F.
Local aVerif	:= {}
Local nPos		:= 0

Default cCodRec    := SPACE(TamSx3("GM8_CODREC")[1])
Default cIntMar    := "00:00"
Default cDuracao   := "00:00"
Default lMsg       := .T.
Default lBlqReg    := .T.
Default lVldPriDat := .T.
Default cTipAge    := ""
 
cHorFim   := Hs_IniPadr("GM6", 1, cCodDis, "GM6_HORFIM",,.F.)

If HS_TotHoras(cHorIni, cDuracao) > Hs_SomaHor(cHorFim, cIntMar)
	dProxDat := dData + 1
	cProxHor := '00:00'
	If lMsg
		Hs_MsgInf("Não há horários disponíveis para a duração do procedimento ", "Atenção", "Validação")
	EndIf
	Return(.F.)
EndIf

cHorFim := HS_TotHoras(cHorIni, cDuracao)
If cIntMar # "00:00"
	nQtdInt := HS_HTOM(cDuracao) / HS_HTOM(cIntMar)
EndIf


cSql := "   SELECT GM8.GM8_STATUS, GM8.GM8_CODAGE, GM8.GM8_DATAGE, GM8.GM8_HORAGE, GM8.GM8_TIPAGE " +;
		"    FROM "+RetSqlName("GM8")+" GM8 " +;
		"   WHERE GM8_FILIAL = '"+xFilial("GM8")+"' AND D_E_L_E_T_ <> '*' " +;
		"     AND GM8_CODDIS = '"+cCodDis+"' AND GM8_CODREC = '"+cCodRec+"' "

If cTipAge # "1"
	If cDuracao # "00:00"
		cSql +=	"     AND GM8_HORAGE >= '"+cHorIni+"' AND GM8_HORAGE < '"+cHorFim+"' "
	Else
		cSql +=	"     AND GM8_HORAGE = '"+cHorIni+"'"
	EndIf
	cSql +=	"     AND GM8_TIPAGE = '0'
Else
	cSql +=	"     AND GM8_TIPAGE = '1'
EndIF
cSql += "     AND ( "
If Type("aVldFutDt") == "A" .And. !Empty(aVldFutDt)
	If lVldPriDat
		cWhereDat += " GM8_DATAGE = '"+DTOS(dData)+"' "
	EndIf
	
	For nI := 1 To Len(aVldFutDt)
		cWhereDat += IIF(!Empty(cWhereDat)," OR ","")+" GM8_DATAGE = '"+DTOS(dData + aVldFutDt[nI])+"' "
	Next
Else
	cWhereDat +=	"  GM8_DATAGE = '"+DTOS(dData)+"' "
EndIf
cSql += cWhereDat
cSql += " )"
cSql += " ORDER BY GM8.GM8_CODAGE"

TCQuery cSql New Alias "TMPAGD"

DbGoTop()

If !TMPAGD->(Eof())
	While TMPAGD->(!Eof())
		AADD(aVerif,{TMPAGD->GM8_STATUS,TMPAGD->GM8_DATAGE, TMPAGD->GM8_HORAGE, TMPAGD->GM8_TIPAGE})
		TMPAGD->(DbSkip())
	EndDo
EndIf

DbGoTop()

While TMPAGD->(!Eof())
	
	If TMPAGD->GM8_STATUS $ "0/8" .And. (!lBlqReg .Or. FS_LByName("M29GM8"+TMPAGD->GM8_CODAGE))
	    lRet := .T.
	EndIf
	
	If !(TMPAGD->GM8_STATUS $ "0/8" .And. (!lBlqReg .Or. FS_LByName("M29GM8"+TMPAGD->GM8_CODAGE))) .And. cTipAge # "1"
		If lMsg
			HS_MsgInf("O horário "+TMPAGD->GM8_HORAGE+" do dia "+DtoC(StoD(TMPAGD->GM8_DATAGE))+;
			IIF(!Empty(cCodRec)," do recurso "+cCodRec,"")+;
			" está em uso por outro usuário",STR0077,STR0102)  //"O horário selecionado está em uso por outro usuário"###"Atencao"###"Marca o Horario na Agenda"
		EndIf
		
		dProxDat := StoD(TMPAGD->GM8_DATAGE)
		cProxHor := TMPAGD->GM8_HORAGE
		Exit
	Else
		If TMPAGD->GM8_HORAGE <> "  :  "  .AND. (nPos := aScan(aVerif, {|aVet| aVet[2] == TMPAGD->GM8_DATAGE .AND. aVet[4] == TMPAGD->GM8_TIPAGE .AND. aVet[3] == TMPAGD->GM8_HORAGE .AND. aVet[1] <> TMPAGD->GM8_STATUS})) > 0
			Final("Existe inconsistencia nos horarios para a data: [" + TMPAGD->GM8_DATAGE + "], " , "disponibilidade: [" + cCodDis + "] e Recurso: [" + cCodRec + "]")
		EndIf
		
		If cDatAux # TMPAGD->GM8_DATAGE
			aAdd(aCodAge, {})
			cDatAux := TMPAGD->GM8_DATAGE
		EndIf
		
		aAdd(aCodAge[len(aCodAge)], {TMPAGD->GM8_CODAGE, StoD(TMPAGD->GM8_DATAGE), TMPAGD->GM8_HORAGE})
		
	EndIf
	
	TMPAGD->(DbSkip())
EndDo

DbSelectArea("TMPAGD")
DbCloseArea()

If oFolder:nOption == 2
	lEnc := .T.
Else
	lEnc := .F.
EndIf
If !Empty(aCodAge)
	For nI := 1 to Len(aCodAge)
		If lRet .And. Len(aCodAge[nI]) # nQtdInt .And. !lEnc
			If lMsg
				HS_MsgInf("Intervalo insuficiente para agendar um procedimento com duração de [" + M->GM8_DURACA + "] ", "Atenção", "Valida Marcação")
			EndIf
			lRet := .F.
			dProxDat := aCodAge[1][1][2]
			cProxHor := Hs_SomaHor(aCodAge[1][1][3], cIntMar)
		EndIf
	Next
Else
	If lMsg  .And. !lEnc
		HS_MsgInf("Intervalo insuficiente para agendar um procedimento com duração de [" + M->GM8_DURACA + "] ", "Atenção", "Valida Marcação")
	EndIf
	lRet := .F.
	dProxDat := dData
	cProxHor := Hs_SomaHor(cHorIni, cIntMar)
EndIf

If lRet .And. Type("aVldFutDt") == "A" .And. !Empty(aVldFutDt) .And.  Len(aVldFutDt)+IIF(lVldPriDat,1,0) # Len(aCodAge)
	lRet := .F.
	dProxDat := aCodAge[1][1][2]
	cProxHor := Hs_SomaHor(aCodAge[1][1][3], cIntMar)
EndIf

If !lRet .And. lBlqReg
	For nI := 1 To Len(aCodAge)
		
		For nX := 1 to Len(aCodAge[nI])
			FS_UByName("M29GM8"+aCodAge[nI][nX][1])
		Next
		
	Next
	aCodAge := {}
EndIf

RestArea(aArea)

Return(lRet)

Static Function Fs_GSessao(dDatIni, cHorIni, cSeqAge, lQuimio,aMeses)
Local aArea    := GetArea()
Local nCont    := 0, nI := 0
Local dDatAtu  := CtoD("")
Local aAgendas := {}
Local aCodAge  := {}
Local lAjusta  := .F.
Local lRet     := .T.
Local aDatas   := {}
Local nJ

aAdd(aDatas, {.T., dDatIni})
cIntMar   := Hs_IniPadr("GM6", 1, cCodDis, "GM6_INTMAR",,.F.)

If !lQuimio
	If M->GM8_NUMSES > 1
		
		For nCont := 1 to M->GM8_NUMSES - 1 //A primeira sessão já foi gravada
			aCodAge := {}
			dDatAtu := dDatIni + (M->GM8_INTERV * nCont)
			
			If Hs_VldMarc(@aCodAge, cCodDis, cCodRec, dDatAtu, cHorIni, cIntMar, M->GM8_DURACA,.F.)
				aAdd(aAgendas, aCodAge[1])
				aAdd(aDatas, {.T., dDatAtu})
			Else
				lAjusta  := .T.
				aAdd(aDatas, {.F., dDatAtu})
			EndIf
			
		Next

	if isInCallStack("HSPAHM13")
			//Verifica se nas datas selecionadas, ha alguma que ultrapassa a data de validade da solicitacao de sessao (HSPAHM13)  (coluna 2 do array)
			for nI:=1 to len(aDatas)
				for nJ:=1 to len(aDatas[1])
					if aDatas[nI,2] > GKB->GKB_DTFIVL .and. aDatas[nI,1] == .T. //Se a data é maior que a validade da solictacao de Sessao
						HS_MsgInf(OemToAnsi(STR0166 + " " + dToC(aDatas[nI,2]) + STR0207 + " ("+dToC(GKB->GKB_DTFIVL)+")"),STR0077,STR0102)  //"A data de agendamento para o procedimento em XX/XX/XXXX é maior que a validade da solicitação de APAC (XX/XX/XXXX)"###"Atencao"###"Marca o Horario na Agenda"
						return .F.
					endif
				next nJ
			next nI
		endif
		nI := 0	
		
	EndIf
Else
	If lRet := Hs_VldMarc(@aCodAge, cCodDis, cCodRec, dDatIni, cHorIni, cIntMar, M->GM8_DURACA,.F.,.F.,,,.F.)
		For nCont := 1 to Len(aCodAge)
			aAdd(aAgendas, aCodAge[nCont])
			aAdd(aDatas, {.T., aCodAge[nCont, 1, 2]})
		Next
		lAjusta  := .T.
	EndIf
Endif

For nCont := 1 to len(aAgendas)
	For nI := 1 to Len(aAgendas[nCont])
		Fs_GrvMarc(aAgendas[nCont][nI][1], "BR_LARANJA", 2, aAgendas[nCont, 1, 1], aAgendas[nCont][nI][3], cSeqAge)
	Next
Next

If lAjusta
	lRet := Fs_ReAgd(aDatas, cHorIni, cSeqAge,aMeses)
EndIf

RestArea(aArea)
Return(lRet)     


Static Function Fs_ReAgd(aDatas, cHorIni, cSeqAge,aMeses)
Local oDatas  := nil
Local dDatAtu := CtoD("")
Local aCols   := {}
Local aHeader := {}
Local nI      := 0

Local aHGM8     := {}, aCGM8 := {}, nUGM8 := 0
Local aCpoGM8   := {"GM8_DATAGE","GM8_HORINI","GM8_HORFIN"}
Local oGetDados := nil
Local lDataAtu  := .T.
Local nOpc      := 0
Local nHorAge   := 0

Private oMesAno  := nil
Private oCal := nil
Private aLeg := {	{"GM8_STATUS == '0' ","BR_CINZA"},;
					{"GM8_STATUS == '1' ","BR_VERMELHO"},;
					{"GM8_STATUS == '2' ","BR_AMARELO" },;
					{"GM8_STATUS == '3' ","BR_PINK" },;
					{"GM8_STATUS == '4' ","BR_AZUL" },;
					{"GM8_STATUS == '5' ","BR_LARANJA" },;
					{"GM8_STATUS == '6' ","BR_CINZA" },;
					{"GM8_STATUS == '7' ","BR_VIOLETA" },;
					{"GM8_STATUS == '8' ","BR_BRANCO" }}
Private oPnlGrd := nil, oPanel := nil
Private nPosDatAgd := 0, nPosStaReg  := 0
Private oGdHor := nil                



Private aMarcacao := {}

HS_BDados("GM8" , @aHGM8 , @aCGM8 , @nUGM8 , 1   ,        ,"1 = 0",        ,"GM8_STATUS","/"     ,         ,        ,        ,{"GM8_IDMARC"}             , {"'LBNO'"}                                          ,.T.    , aLeg,        ,         ,           ,         , aCpoGM8)

nPosStaReg := Ascan(aHGM8,{|x|AllTrim(x[2])=="GM8_STATUS"})
nPosDatAgd := Ascan(aHGM8,{|x|AllTrim(x[2])=="GM8_DATAGE"}) //Codigo do agendamento
nPosMark   := Ascan(aHGM8,{|x|AllTrim(x[2])=="GM8_IDMARC"})

aCGM8 := {}
For nI := 1 to Len(aDatas)
	aAdd(aCGM8, {IIF(aDatas[nI, 1],"BR_VERDE","BR_VERMELHO"), IIF(nI == 1,"LBTIK","LBNO"), aDatas[nI][2], cHorIni, HS_TotHoras(cHorIni, M->GM8_DURACA), .F.})
	
	aAdd(aMarcacao, {aDatas[nI][2], CtoD(""), {}, {}})
Next

oDlgReAgd := MSDialog():New(0,0,550,750,"Ajuste Agendamento",,,,,,,, oMainWnd,.T.)

oPanel	 :=	tPanel():New(000,000,,oDlgReAgd,,,,,,300,065)
oPanel:Align := CONTROL_ALIGN_TOP

oPnlGrd	:=	tPanel():New(065,000,,oDlgReAgd,,,,,,300,050)
oPnlGrd:Align := CONTROL_ALIGN_ALLCLIENT

//@ 000,000 ListBox oDatas Var dDatAtu Fields Header "Dias Não Gerados" Size 080, 065 NoScroll Of oPanel Pixel
oGetDat := MsNewGetDados():New(000,000,080,150,0,"AllwaysTrue()","AllwaysTrue()","",,,,,,,oPanel,aHGM8,aCGM8)
oGetDat:oBrowse:Align := CONTROL_ALIGN_LEFT
oGetDat:oBrowse:BlDblClick := {|| FS_DbClik(oGetDat, nPosStaReg)}
oGetDat:oBrowse:nAt := 1

//Selecao do Mes
@ 000,150 ListBox oMesAno Var cMes Fields Header OemToAnsi(STR0023) Size 080, 065 NoScroll Of oPanel Pixel //"Mes Atual"

oMesAno:SetArray(aMeses)
oMesAno:bLine   := {||{aMeses[oMesAno:nAt]}}
oMesAno:bChange := {||HSPM29Navega(NIL,"+",NIL,@lDataAtu,"oMesAno"), Fs_MkReAgd()}//FS_UNLOCK - Desbloqueia o registro sempre que se muda o mes
oMesAno:nAt :=Month(oGetDat:aCols[oGetDat:oBrowse:nAt, nPosDatAgd])

//Selecao atraves do Calendario
oCal            := MsCalend():New(000, 230, oPanel)
oCal:bChangeMes := {|| HSPM29Navega(NIL,NIL,"+",@lDataAtu,"oMesAno"), Fs_MkReAgd()} //FS_UNLOCK - Desbloqueia o registro sempre que se muda o mes
oCal:bChange    := {|| Fs_MkReAgd()}
oCal:dDiaAtu    := oGetDat:aCols[oGetDat:oBrowse:nAt, nPosDatAgd] //aCGM8[aScan(aCGM8,{|aVet| aVet[nPosStaReg] == "BR_VERMELHO"}),nPosDatAgd]
oCal:Refresh()

Fs_MkReAgd()

ACTIVATE MSDIALOG oDlgReAgd ON INIT EnchoiceBar(oDlgReAgd,{|| nOpc := 1, IIF(Fs_GrReAgd(cSeqAge), oDlgReAgd:End(),nil)},{|| nOpc := 0, oDlgReAgd:End()})
Return(nOpc == 1)

//-------------------------------------------------------------------------------------------------------------------------------------------------


Static Function Fs_ChgRAgd(oObj)
Local nPos := 0

nPos := aScan(aMarcacao, {|aVet| aVet[1] == oObj:aCols[oObj:oBrowse:nAt, nPosDatAgd]})

If Len(aMarcacao[nPos, 3]) > 0
	Fs_AtuCal(aMarcacao[nPos, 2], .F.,@oMesAno,,nPosDatAgd,nPosStaReg)
	
	oGDHor:SetArray(aMarcacao[nPos, 3])
	oGDHor:Refresh()
	aLastMar := aMarcacao[nPos, 4]
Else
	Fs_AtuCal(oObj:aCols[oObj:nAt, nPosDatAgd],,@oMesAno)//,@oCal),nPosDatAgd,nPosStaReg)
EndIf

Return(nil)


//---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function Fs_MntCols(dData)

Local cSql      := ""
Local aRecursos := Hs_RetRec(cCodDis,,,.T.)
Local cRecurso  := ""
Local aCols     := {}
Local nPos		:= 0

Private cAliasGm8 := "TMPCOL"

cSql := "   SELECT GM8.GM8_STATUS, GM8.GM8_CODAGE, GM8.GM8_DATAGE, GM8.GM8_HORAGE, GM8.GM8_CODREC " +;
		"    FROM "+RetSqlName("GM8")+" GM8 " +;
		"   WHERE GM8_FILIAL = '"+xFilial("GM8")+"' AND D_E_L_E_T_ <> '*' " +;
		"     AND GM8_DATAGE = '"+DTOS(dData)+"' " +;
		"     AND GM8_CODDIS = '"+cCodDis+"' "+;
		"     AND GM8_HORAGE <> '  :  ' "+;
		" ORDER BY GM8_DATAGE, GM8_CODREC, GM8_HORAGE "


TCQuery cSql New Alias "TMPCOL"

While TMPCOL->(!Eof())
	
	If Substr(cRecurso,1,TamSx3("GNZ_CODREC")[1]) # TMPCOL->GM8_CODREC
		If LEN(aRecursos) > 0
			nPos := aScan(aRecursos,{|aVet| Substr(aVet,1,TamSx3("GNZ_CODREC")[1]) == TMPCOL->GM8_CODREC})
			If nPos > 0
				cRecurso := aRecursos[nPos]
		aAdd(aCols,{cRecurso})
	EndIf
		EndIf
	EndIf
	If Len(aCols) > 0
	aAdd(aCols[len(aCols)], HSPM29SitAge())
	aAdd(aCols[len(aCols)], TMPCOL->GM8_HORAGE)
	EndIf
	
	TMPCOL->(DbSkip())
EndDo

DbSelectArea("TMPCOL")
DbCloseArea()
Return(aCols)
//-------------------------------------------------------------------------------------------------------------------------------------------
Static Function FS_DbClik(oObj, nPosStaReg)
    
If ValType(oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos]) # "C"
	Return(Nil)
EndIf

If oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "LBTIK/LBNO"
	If(oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] == "LBTIK")
		oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := "LBNO"
	Else
		If (nPos := aScan(oObj:aCols, {|aVet| aVet[oObj:oBrowse:ColPos] == "LBTIK"})) > 0
			oObj:aCols[nPos, oObj:oBrowse:ColPos] := "LBNO"
		EndIf
		
		oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := "LBTIK"
		Fs_ChgRAgd(oObj)
		aLastMar := {}
	EndIf
	oObj:Refresh()
EndIf
Return(Nil)

//-------------------------------------------------------------------------------------------------------------------------------------------
Static Function Fs_AtuCal(dDatAgd, lAtuGrd,oMesAno)//,oCal)
Default lAtuGrd := .T.

oCal:dDiaAtu := dDatAgd
oCal:Refresh()

oMesAno:nAt := Month(oCal:dDiaAtu)
oMesAno:Refresh()

If lAtuGrd
	Fs_MkReAgd()
EndIf

Return(Nil)

//---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function Fs_MkReAgd()
Local aCols   := {}
Local aHeader := {}

aCols := Fs_MntCols(oCal:dDiaAtu)
aHeader := Fs_MntHead(1, @aCols, cCodDis, 2)

oGdHor := MsNewGetDados():New(065,003.5,126.5,499.5,0,"AllwaysTrue()","AllwaysTrue()","",{},,,,,,oPnlGrd,aHeader,aCols)
oGdHor:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdHor:oBrowse:blDblClick:= {|| Fs_VlReAgd("2") } //Marca o Agendamento pela Disponibilidade


oGdHor:Refresh() 
Return()

//---------------------------------------------------------------------------------------------------------------------------------------------------

Static Function Fs_VlReAgd(cOpc)//essas 2 variaveis(nDatAgd,nStaReg)nao recebem valor,mesmo passando por ref 
Local lRet 		:= .F.
Local cSeqAge	:= GM8->GM8_SEQAGE
Local aAreaGM8 := GM8->(GetArea())
Local cSmf 		:= "GM8"+cSeqAge
//Coloquei o semaforo pois se o usuário do sistema der varios cliques seguidos na linha de marcação, ocorre error.log de estouro de array
nHSeqAge   := PLSAbreSem(cSmf+".SMF")

IF GETNEWPAR("MV_HSPPASE","0") == "0"
	If !(lRet := oGetDat:aCols[oGetDat:nAt, nPosStaReg]  # "BR_VERDE")
		HS_MsgInf("Agendamento já está confirmado.","Atenção","Validação Agenda")
	EndIf
Else                                          
	If !Empty(oGdHor:aCols[oGdHor:oBrowse:nAt, 1]) .And. HSPM29Marca(cOpc, oFolder, .F., @oGdHor, oCal:dDiaAtu, .F., oGetDat:oBrowse:nAt)
		If GETNEWPAR("MV_HSPPASE","0") == "1"
			Fs_GM8AJU(oGetDat:aCols[oGetDat:nAt],cSeqAge)
		EndIf
		Fs_SavRAgd()
	EndIf
EndIf

RestArea(aAreaGM8)

PLSFechaSem(nHSeqAge,cSmf+".SMF")   
 
Return(lRet)

Static Function Fs_SavRAgd()
Local nPos := aScan(oGetDat:aCols, {| aVet | aVet[nPosMark] == "LBTIK"})

If nPos > 0
	nPos := aScan(aMarcacao, {|aVet| aVet[1] == oGetDat:aCols[nPos, nPosDatAgd] })
	
	If GETNEWPAR("MV_HSPPASE","0")=="1"
		If nPos == 0
			//Retorna a posição inicial
			nPos := aScan(oGetDat:aCols, {| aVet | aVet[nPosMark] == "LBTIK"})
			nPos := aScan(aMarcacao, {|aVet| aVet[2] == oGetDat:aCols[nPos, nPosDatAgd] })
		EndIf
		If nPos > 0
			oGetDat:aCols[nPos, nPosDatAgd]:= oCal:dDiaAtu
		EndIf
    EndIf	
	
	aMarcacao[nPos, 2] := oCal:dDiaAtu
	aMarcacao[nPos, 3] := aClone(oGdHor:aCols)
	aMarcacao[nPos, 4] := aLastMar
	
	If GETNEWPAR("MV_HSPPASE","0")=="1"
		Fs_GM8DEL()
	EndIf
	
	oGetDat:aCols[nPos, nPosStaReg] := "BR_LARANJA"
	oGetDat:oBrowse:Refresh()
EndIf
Return()

//---------------------------------------------------------------------------------------------------------------------------------------------------      

Static Function Fs_GrReAgd(cSeqAge)
Local nCont := 0
Local nI    := 0

If aScan(oGetDat:aCols, {| aVet | aVet[nPosStaReg] == "BR_VERMELHO"}) > 0
	Hs_MsgInf("Há agendamentos que não foram ajustados","Atenção","Validação Agenda")
	Return(.F.)
EndIf

For nCont := 1 to len(aMarcacao)
	For nI := 1 to Len(aMarcacao[nCont, 4])
		cAgePrinc := aMarcacao[nCont, 4, 1 ][1]
		cCodAge   := aMarcacao[nCont, 4, nI][1]
		nLastFld  := aMarcacao[nCont, 4, nI][2]
		nLastDay  := aMarcacao[nCont, 4, nI][3]
		nLastHour := aMarcacao[nCont, 4, nI][4]
		nLastRec  := aMarcacao[nCont, 4, nI][5]
		cHorEnc   := aMarcacao[nCont, 3][nLastRec, nLastHour]
		Fs_GrvMarc(cCodAge, "BR_LARANJA", 2, cAgePrinc, cHorEnc, cSeqAge)
	Next
Next

Return(.T.)

Function HS_FilProt()
Local aArea   := getArea()

Local cRet    := &(ReadVar())

Local aVet    := {"D1","D2","D3","D4","D5","D8","D15","D22","D29"}
Local aHDados := {}
Local aCDados := {{}}
Local nCont   := 0
Local nOpca   := 0

for nCont := 1 to len(aVet)
	Aadd(aHDados, {aVet[nCont], "c"+aVet[nCont]     , "@BMP" , 5, 0, ".F.", "", "C", "", "V" ,"" , "","","V"})
	aAdd(aCDados[1],IIF(aVet[nCont] $ cRet,"BR_AMARELO","BR_VERDE"))
next

aAdd(aCDados[1], .F.)

DEFINE MSDIALOG oDlgProt TITLE "Protocolo" From 000, 000 To 100, 350 Of oMainWnd Pixel

oGdProt := MsNewGetDados():New(000, 000, 200, 200,0,,,,,,,,,, oDlgProt, aHDados, aCDados)
oGdProt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdProt:oBrowse:blDblClick:= {|| Fs_DClProt(oGdProt) } //Marca o Agendamento pela Ocupacao

ACTIVATE MSDIALOG oDlgProt CENTERED ON INIT EnchoiceBar(oDlgProt, {||nOpca := 1, oDlgProt:End()}, {|| nOpca := 0, oDlgProt:End()})

aVldFutDt := {}
If nOpca == 1
	cRet := ""
	For nCont := 1 to Len(oGdProt:aCols[1])
		If IIF(ValType(oGdProt:aCols[1][nCont])== "C", oGdProt:aCols[1][nCont] == "BR_AMARELO", .F.)
			cRet += IIF(!Empty(cRet), "+", "")+oGdProt:aHeader[nCont][1]
			If "D1" # oGdProt:aHeader[nCont][1]
				aAdd(aVldFutDt, Val(Substr(oGdProt:aHeader[nCont][1], 2))-1)
			EndIf
		EndIf
	Next
EndIf

__RetProt := cRet
RestArea(aArea)
return(.T.)

Function HS_RetProt()
&(Readvar()) := __RetProt
Return(.T.)

Static Function Fs_DClProt(oObj)

If oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] == "BR_VERDE"
	oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := "BR_AMARELO"
ElseIf oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] == "BR_AMARELO"
	oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := "BR_VERDE"
EndIf

Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_RetPrepºAutor  ³Rogerio Tabosa      º Data ³  23/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna as precaucoes/preparos do procedimento              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RetPrep(cProced)
Local aArea := getArea()
Local cPrec := ""
Local cSql	:= ""
 
DbSelectArea("GNJ")
 
cSql := " Select GCK.R_E_C_N_O_ REG" +;
		" From "+RetSqlName("GA7")+" GA7 " +;
		" Join "+RetSqlName("GCJ")+" GCJ " +;
		" on GCJ.GCJ_GRPPRE = GA7.GA7_GRPPRE AND GCJ.GCJ_FILIAL = '"+xFilial("GCJ")+"' AND GCJ.D_E_L_E_T_ <> '*' "+;
		" Join "+RetSqlName("GCI")+" GCI " +;
		" on GCI.GCI_GRPPRE = GCJ.GCJ_GRPPRE AND GCI.GCI_FILIAL = '"+xFilial("GCI")+"' AND GCI.D_E_L_E_T_ <> '*' "+;
		" Join "+RetSqlName("GCK")+" GCK " +;
		" on GCK.GCK_CODPRE = GCI.GCI_CODPRE AND GCK.GCK_TIPPRE = '0' " +;
       	" AND GCK.GCK_FILIAL = '"+xFilial("GCK")+"' AND GCK.D_E_L_E_T_ <> '*' "+;
		" Where GA7.GA7_CODPRO = '"+cProced+"' "+;
		" AND GA7.GA7_FILIAL = '"+xFilial("GA7")+"' AND GA7.D_E_L_E_T_ <> '*' "

cSql := ChangeQuery(cSql)	

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()		
 	
While !Eof()   	
	DbSelectArea("GCK")
 	DbGoTo(QRY->REG)								
	cPrec += 	GCK->GCK_PRECAU+chr(10)+chr(13)   	 
	DbSelectArea("QRY")
	DbSkip()
End
	 
DbSelectArea("QRY")
DbCloseArea()
	
RestArea(aArea)								
Return(cPrec)   

Static Function FS_SelDisp(aDisp)
Local cCodDis 	:= ""
Local cNomDis 	:= ""
Local aHDados	:= {}
Local aCDados	:= {}
Local nI		:= 0
Local oDlgDis	:= Nil 
Local oGDGM6	:= Nil 
Local nOpcA		:= 0

/* Aadd(aHDados, {" "             , "cRetSetor", "@BMP"  , 2                        , 0, ".F.", ""    , "C", "", "V" , "" , "","","V"})                          
 Aadd(aHDados, {"Cod Setor"     , "cCodLoc"  , "@!"    , TamSx3("GCS_CODLOC")[1] , 0, ".F.", ""    , "C", "", "V" , "" , "", "", "V"})*/
 Aadd(aHDados, {"Cod Dispo"     , "cCodDis"  , "@!"    , TamSx3("GM6_CODDIS")[1] , 0, ".F.", ""    , "C", "", "V" , "" , "", "", "V"}) 
 Aadd(aHDados, {"Nome Dis "     , "cNomDis"  , "@!"    , TamSx3("GM6_DESDIS")[1] , 0, ".F.", ""    , "C", "", "V" , "" , "", "", "V"})

 //Criando aCols
For nI := 1 to Len(aDisp)
	aAdd(aCDados, {aDisp[nI,1], aDisp[nI,2], .F.})
Next nI
 
  
DEFINE MSDIALOG oDlgDis TITLE STR0150 From 000, 000 To 300, 500 Of oMainWnd Pixel   // "Selecione a disponibilidade desejada"

	oGDGM6 := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlgDis, aHDados, aCDados)
	oGDGM6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT    
	oGDGM6:oBrowse:BlDblClick := { || cCodDis := oGDGM6:aCols[oGDGM6:oBrowse:nAt, 1], oDlgDis:End()}
 		
ACTIVATE MSDIALOG oDlgDis CENTERED ON INIT EnchoiceBar(oDlgDis, {|| nOpcA := 1, oDlgDis:End()}, {|| nOpcA := 0})
	 
If nOpcA == 1
	cCodDis := oGDGM6:aCols[oGDGM6:nAt, 1]
EndIf  

Return(cCodDis)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATRBSESºAutor  ³Microsiga           º Data ³  06/26/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para atribuir e controlar a quantidade atual  º±±
±±º          ³x a quantidade total de sessoes.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATRBSES(cSeqAge)
Local cSql			:= "" 
Local nI			:= 0  
Local nSesAtu		:= 0
Local aUpdate		:= {}
Local dDataApoio	:= ""

cSql := "SELECT GM8_DATAGE, GM8_CODAGE, GM8_SEQAGE, GM8_NUMSES "
cSql += "FROM " + RetSqlName("GM8") + " GM8  "
cSql += "WHERE GM8_SEQAGE = '" + cSeqAge + "' AND GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*'"
cSql += " ORDER BY 1 " 

cSql := ChangeQuery(cSql)	

TCQUERY cSQL NEW ALIAS "QRYSES"

DbSelectArea("QRYSES")

While !Eof()
	If nSesAtu == 0
		nSesAtu := nSesAtu + 1
	Else
		If QRYSES->GM8_DATAGE <> dDataApoio
			nSesAtu := nSesAtu + 1
		EndIf
	EndIf
	AADD(aUpdate, {QRYSES->GM8_DATAGE, QRYSES->GM8_CODAGE, PADL(nSesAtu, 2, "0") + "/" + PADL(QRYSES->GM8_NUMSES, 2, "0")})	
	dDataApoio := QRYSES->GM8_DATAGE
	DbSkip()
End  

DbSelectArea("QRYSES")
DbCloseArea() 

For nI := 1 To Len(aUpdate)
	DbSelectArea("GM8")
	DbGoTop()
	DbSetOrder(1)
	If DbSeek(xFilial("GM8") + aUpdate[nI,2])
		RecLock("GM8",.F.)
			GM8->GM8_SEQQTD := aUpdate[nI,3]
		MsUnLock()
		//AADD(aUpdate, {GM8_DATAGE, GM8_CODAGE, PADL(nCount, 2, "0") + "/" + PADL(QRYSES->GM8_NUMSES, 2, "0")})
	EndIf  
Next nI

Return()

Function HS_RTSQSES(cRegAte)
Local aArea		:= GetArea()
Local cSeqSes 	:= ""
TCQUERY ChangeQuery("SELECT GM8_SEQQTD FROM " + RetSqlName("GM8") + " GM8 WHERE GM8_REGATE = '" + cRegAte + "' AND GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*'") NEW ALIAS "TMPSES"
DbSelectArea("TMPSES")
If !Eof()
	cSeqSes := TMPSES->GM8_SEQQTD
EndIf
DbSelectArea("TMPSES")
TMPSES->(DbCloseArea())             

DbSelectArea("GCZ")
DbSetOrder(2)
If DbSeek(xFilial("GCZ") + cRegAte) .AND. Empty(GCZ->GCZ_SEQSES)
	RecLock("GCZ",.F.)
		GCZ->GCZ_SEQSES := cSeqSes
	MsUnLock()
EndIf
RestArea(aArea)
Return(cSeqSes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ATSESAMºAutor  ³Microsiga           º Data ³  03/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para atribuir e controlar a quantidade atual  º±±
±±º          ³x a quantidade total de sessoes.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATSESAM(cSeqAge)
Local cSql			:= "" 
Local nI			:= 0  
Local nSesAtu		:= 0
Local aUpdate		:= {}
//Local dDataApoio	:= ""
local nQtdSes       := 0 
cSql := "SELECT GM8_DATAGE, GM8_CODAGE, GM8_SEQAGE, GM8_NUMSES "
cSql := "SELECT GM8_DATAGE, GM8_CODAGE, GM8_SEQAGE, GM8_NUMSES, GM8_HORAGE "
cSql += "FROM " + RetSqlName("GM8") + " GM8  "
cSql += "WHERE GM8_SEQAGE = '" + cSeqAge + "' AND GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*'"
cSql += " ORDER BY 1,5 " 

cSql := ChangeQuery(cSql)	

TCQUERY cSQL NEW ALIAS "QRYSES"

DbSelectArea("QRYSES")
nQtdSes := Contar("QRYSES","!Eof()")
QRYSES->(DbGoTop())

While !Eof()

	nSesAtu++
	AADD(aUpdate, {QRYSES->GM8_DATAGE, QRYSES->GM8_CODAGE, PADL(nSesAtu, 2, "0") + "/" + PADL(nQtdSes, 2, "0")})	
	DbSkip()
End  

DbSelectArea("QRYSES")
DbCloseArea() 

For nI := 1 To Len(aUpdate)
	DbSelectArea("GM8")
	DbGoTop()
	DbSetOrder(1)
	If DbSeek(xFilial("GM8") + aUpdate[nI,2])
		RecLock("GM8",.F.)
			GM8->GM8_NUMSES := nQtdSes
			GM8->GM8_SEQQTD := aUpdate[nI,3]
		MsUnLock()
		//AADD(aUpdate, {GM8_DATAGE, GM8_CODAGE, PADL(nCount, 2, "0") + "/" + PADL(QRYSES->GM8_NUMSES, 2, "0")})
	EndIf  
Next nI

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_sStSessºAutor  ³ Saude              º Data ³  05/11/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta o status da solicitacao de Sessao (HSPAHM13) no      º±±
±±º          ³momento do cancelamento/agendamento do procedimento         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCodSolici = Codigo da solicitacao - GK7_SOLICI             º±±
±±º          ³cCodProc   = Codigo do Procedimento - GK7_CODPRO            º±±
±±º          ³cSeqAge    = Sequencia do Agendamento - GK7_SEQAGE          º±±
±±º          ³cOper      = Tipo da operacao ("E" - Exclusao de Agenda     º±±
±±º          ³           = - Contagem realizada antes da exclusao /       º±±
±±º          ³           = "A" - Atualizacao / Insercao de agendamentos   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ NIL                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function HS_sStSess(cCodSolGkb, cCodProc, cSeqAge, cOper)
local aArea      := getArea()               
local nQtd       := 0
local cStatus    := ""
local nQtdMaxGkb := 0

Default cOper    := "A"

if !SuperGetMv("MV_AGDMSES",nil,.F.)
	return NIL
endif

//Verificando qtde solicitada na GKB
nQtdMaxGkb := Posicione("GKB", 1, cCodSolGkb, "GKB_QTDSOL")

//Quantidade de procedimentos agendados para essa solicitacao de Sessao
nQtd   := hs_qtProAg(cCodSolGkb, cCodProc, "S")
if cOper == "E"
	nQtd--
endif

if nQtd < nQtdMaxGkb .AND. nQtd >= 1
	cStatus  := "6"
elseif nQtd < nQtdMaxGkb .AND. nQtd == 0
	cStatus  := "0"
	cSeqAge  := ""
endif        

//Localiza a solicitacao de Sessao
dbSelectArea("GKB")
dbSetOrder(1)
if DbSeek(xFilial("GKB") + GM8->GM8_SOLGKB)
	if GKB->GKB_STATUS $ "36"
		RecLock("GKB",.F.)
		GKB->GKB_STATUS := cStatus
		GKB->GKB_SEQAGE := cSeqAge
		MsUnlock()
	endif
endif

restArea(aArea)
return NIL    



Function Fs_GM8AJU(aHor,cSeqAge)

Local aAreaGM8 	:= GM8->(GetArea())
Default cSeqAge	:= ""

aHorGer := {}

If aHor[1] <> "BR_VERMELHO"

	DbSelectArea("GM8")
	DbSetOrder(13)
	DbSeek(xFilial("GM8")+cSeqAge)
	
	While GM8->(!Eof()) .And. GM8->GM8_SEQAGE == cSeqAge
	
		If DtoS(GM8->GM8_DATAGE) + (GM8->GM8_HORAGE) == DtoS(aHor[3])+aHor[4]
			aAdd(aHorGer,GM8->(RecNo()))
		Endif
	    
		GM8->(DbSkip())
		
	EndDo

Endif

RestArea(aAreaGM8)

Return

Function Fs_GM8DEL()
Local nFor		:= 0
Local aAreaGM8 := GM8->(GetArea())

If Len(aHorGer) > 0
	For nFor:= 1 to Len(aHorGer)
		
		DbGoTo(aHorGer[nFor])
		RecLock("GM8",.F.)
				GM8->GM8_REGGER := Space((TamSx3("GM8_REGGER")[1]))
				GM8->GM8_NOMPAC := Space((TamSx3("GM8_NOMPAC")[1]))
				GM8->GM8_MATRIC := Space((TamSx3("GM8_MATRIC")[1]))
				GM8->GM8_TELPAC := Space((TamSx3("GM8_TELPAC")[1]))
				GM8->GM8_CODPLA := Space((TamSx3("GM8_CODPLA")[1]))
				GM8->GM8_SQCATP := Space((TamSx3("GM8_SQCATP")[1]))
				GM8->GM8_CODPRO := Space((TamSx3("GM8_CODPRO")[1]))
				GM8->GM8_OBSERV := Space((TamSx3("GM8_OBSERV")[1]))
				GM8->GM8_DURACA := Space((TamSx3("GM8_DURACA")[1]))
	    		GM8->GM8_INTERV := 0
				GM8->GM8_NUMSES := 0
				GM8->GM8_PROTOC := Space((TamSx3("GM8_PROTOC")[1]))		
				GM8->GM8_CODCON := Space((TamSx3("GM8_CODCON")[1]))
				GM8->GM8_STATUS := "0"
				GM8->GM8_DATCAD := cTod(Space((TamSx3("GM8_DATCAD")[1])))
				GM8->GM8_HORCAD := Space((TamSx3("GM8_HORCAD")[1]))
				GM8->GM8_CODUSU := Space((TamSx3("GM8_CODUSU")[1]))
				GM8->GM8_LOCAGE := Space((TamSx3("GM8_LOCAGE")[1]))
				GM8->GM8_LOGARQ := HS_LogArq()
				GM8->GM8_AGDPRC := Space((TamSx3("GM8_AGDPRC")[1]))
				GM8->GM8_SEQAGE := Space((TamSx3("GM8_SEQAGE")[1]))
					
		MsUnLock()
		
	Next nFor
Endif

RestArea(aAreaGM8)

Return