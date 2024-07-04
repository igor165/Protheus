#INCLUDE "hspahm54.ch"
#INCLUDE "HSPAHM29.CH"
#INCLUDE "PROTHEUS.CH"
#include "TopConn.ch"
#INCLUDE "VKEY.CH"
#INCLUDE "plsmccr.ch"

Static lExecFilt := .F.
Static lM29ChaExt := .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ HSPAHM54 ³ Autor ³ Saude                 ³ data ³ 27/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Agenda Clinicas		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHM54()
Local bKeyF12
Local __cOldFil  := cFilAnt
Local aSitAtende := {}
Local cFilM29 	 := ""
Private lFilGm1     := .T.
Private lM29SimNao  := .T.
Private lTemPln	    := .F.
Private lCopiar     := .F.
Private cGD4RegGer  := "" //Campo utilizado na consulta padrao GD4
Private cCodDenPln  := "" //usado no ajusta SX3
Private cCodFacPln  := ""//usado no ajusta SX3
Private cNumOrc     := ""
Private cIteOrc     := ""
Private cGcsCodLoc  := "" //Setor selecionado
Private cVersao	    := GetVersao()
Private aRotina 	:= {}
Private aCpoUsu := {} //variavel usada em HSPM54Grv e como local essa funcao nao visualiza seu conteudo
Private cGcsTipLoc := "I" // usado na rotina HS_FilGm8
Private cVldLocX1 := "I"
                              
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
Aadd(aRotina,{OemToAnsi(STR0002), "AxPesqui"   		, 0, 1}) //"Pesquisar"
Aadd(aRotina,{OemToAnsi(STR0004), "HSPM54Atu"  		, 0, 3}) //"A&gendar"
Aadd(aRotina,{OemToAnsi(STR0003), "HSPM54Atu"  		, 0, 4}) //"Cancelar"
Aadd(aRotina,{OemToAnsi(STR0006), "HSPM54Atu"  		, 0, 4}) //"Transferir"
Aadd(aRotina,{OemToAnsi(STR0005), "HSPM54Atu"  		, 0, 4}) //"Alterar"
Aadd(aRotina,{OemToAnsi(STR0074), "HS_ConsAge('A')"	, 0, 1}) //"Consultar"
Aadd(aRotina,{OemToAnsi(STR0079), "HS_M54CFM"  		, 0, 4}) //"Confirmar"
Aadd(aRotina,{OemToAnsi(STR0090), "HS_M54Pac"  		, 0, 2}) //"Paciente"
Aadd(aRotina,{OemToAnsi(STR0078), "HS_M29EXT"  		, 0, 2}) //"Extrato"
Aadd(aRotina,{OemtoAnsi(STR0115), "HS_RelM29"  		, 0, 2}) //"Docs/Relat."
Aadd(aRotina,{OemToAnsi(STR0007), "HSPAHM54Leg"		, 0, 3}) //"Legenda"
Aadd(aRotina,{OemToAnsi(STR0128), "HS_CONDIS"  		, 0, 3}) //"Consulta Medicos"
Aadd(aRotina,{OemToAnsi(STR0177), "HS_AGEFREE" 		, 0, 3}) //"Agenda Livre"
Aadd(aRotina,{OemToAnsi(STR0178), "HS_AGECANC" 		, 0, 3}) //"Agendamentos Cancelados"
Aadd(aRotina,{OemToAnsi("Agend. Paciente"), "HS_AGENPAC(GM8->GM8_REGGER)" 		, 0, 3}) //"Agendamentos Cancelados"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar novas opcoes ao menu           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If ExistBlock("HSM54ADBT")
	aBtAdd := ExecBlock("HSM54ADBT",.F.,.F.)
	If ValType(aBtAdd) == "A"
		AEval(aBtAdd,{|x| AAdd(aRotina,x)})
	EndIf
EndIf



AjustaSx1()

If ( HSPM29Perg() )

 lM29ChaExt := .F.

	bKeyF12 := SetKey(VK_F12,{||HSPM29Perg()})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia o Filtro no Browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HSPM29FilBrw(.F., .T.,@cFilM29)

	mBrowse(06, 01, 22, 75, "GM8",,,,,15, aSitAtende,,,,,,,, cFilM29)

	dbSelectArea("GM8")
	dbClearFilter()

	SetKey(VK_F12, bKeyF12)

EndIf

cFilAnt := __cOldFil

Return(NIL)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM54Atu³ Autor ³Paulo Emidio de Barros ³ Data ³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Agendamento Ambulatorial                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM54Atu(EXPC1,EXPN1,EXPN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo                                   ³±±
±±³          ³ EXPN1 = Numero do registro                                 ³±±
±±³          ³ EXPN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSPM54Atu                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM54Atu(cAlias,nReg,nOpc)
Local aButtons  := {}
Local aCpoEnc   := {}
Local aTitulos  := {}
Local aPaginas  := {}
Local aAreaAnt  := {}
Local aCoordEnc := {}
Local aM54Fol 	:= {} // variavel utilizada para receber o retorno do PE HSM54FOL
Local aHeadGEB  := {}, aColsGEB := {}
Local aHeadGET  := {}, aColsGET := {}
Local lDataAtu  := .T.
Local lOk     	:= .F.
Local lRegAtu   := .F. //Indica se o Filtro da Agenda sera acionado somente no registro corrente
Local lHelp     := .F.
Local oSay,oVermelho ,oAmarelo,oVerde ,oPanel1, oDlgM54
Local bOk       := {|| If(!Obrigatorio(aGets,aTela).Or.!HSPM29VerHorEnc(nFldAtu).Or.!HS_VldM54(nOpc) .OR. !FS_VLDPLS(oCalend:dDiaAtu, nOpcSav) ,NIL,iIf(nOpc<>3  .and. iIf(nOpc <>5,(!FS_findCri(M->GM8_REGGER,M->GM8_CODPRO)),.F.) ,NIL,(HSPM29SavAge(NIL,nFldAtu,NIL,nDiaAgeAtu),HSPM54Grv(nOpc,@nGO4_CODPRO,@nGO4_NUMORC,@nGO4_ITEORC,nGebItem,nGebQtdMat,nGebNumOrc,NGEBITEORC,oGetGEB), HSM54GRV(nOpc,@nGO4_CODPRO,@nGO4_NUMORC,@nGO4_ITEORC,nGebItem,nGebQtdMat,nGebNumOrc,NGEBITEORC,oGetGEB),lOk := .T., oDlgM54:End())))}
Local bCancel   := {||FS_BCancel(aSize)/*,oDlgM54:End()*/ .and. IIF(ExistBlock("HSM54CAN"),IIF(ExecBlock("HSM54CAN",.F.,.F.),oDlgM54:End(),),oDlgM54:End())}
Local nFld      := 0, nCpoUsu := 0  , nFor      := 0
Local nGetCodEqp:= 0, nGetDesEqp:= 0, nGetDatAge:= 0, nGetHorAge:= 0, nGetDatFin:= 0, nGetHoraFi:= 0
Local aCpoVisGeb:= {"GEB_ITEM  ", "GEB_DESCMA", "GEB_QTDAUT"}
//definicoes para identificar o tipo de agenda *** Programador: Marcelo Jose 21/07/2005
Local bATipo    := {|A,B|IIf(A#B,cTipoAg:="A",cTipoAg:= "A") }
local lOriPac   := Hs_ExisDic({{"C","GM8_ORIPAC"}},.F.)   // Verifica se o campo GM8_ORIPAC foi criado
Local bKeyF6
Local lPromo 	:= GETNEWPAR("MV_PROSAUD",.F.)
Local cCpoEnc   := " "
Local cMsgAge   := " "
Local cCadastro := OemToAnsi(STR0152) //"Agenda Clinica"
Local aPCal 	:= Array(1)
Local aSList 	:= Array(2)
Local aAltEnc,aInfo,aPMemo,aPEnc, aResol
Local GM8REGGER  := Space( (TamSx3( "GM8_REGGER" )[1]) )
Local GM8NOMPAC  := Space( (TamSx3( "GM8_NOMPAC" )[1]) )
Local GM8MATRIC  := Space( (TamSx3( "GM8_MATRIC" )[1]) )
Local GM8TELPAC  := Space( (TamSx3( "GM8_TELPAC" )[1]) )
Local GM8CODPLA  := Space( (TamSx3( "GM8_CODPLA" )[1]) )
Local GM8SQCATP  := Space( (TamSx3( "GM8_SQCATP" )[1]) )
Local bGrava     := {|| GM8REGGER := M->GM8_REGGER, GM8NOMPAC := M->GM8_NOMPAC, GM8MATRIC := M->GM8_MATRIC, GM8TELPAC := M->GM8_TELPAC, GM8CODPLA := M->GM8_CODPLA, GM8SQCATP := M->GM8_SQCATP }
Local bCopia     := {|| M->GM8_REGGER := GM8REGGER, M->GM8_NOMPAC := GM8NOMPAC, M->GM8_MATRIC := GM8MATRIC, M->GM8_TELPAC := GM8TELPAC, M->GM8_CODPLA := GM8CODPLA, M->GM8_SQCATP := GM8SQCATP }
Local  oObsPlano,  oObsProc, oObsProf
Local nUsadoGM8  := 0
Local aHGO4 := {}, aCGO4 := {}, nUGO4 := 0
Local oTxtPend
Local cPend	      := '"P"'

local cCodAge 	:= GM8->GM8_CODAGE
local nUGM8 	:= 0
local cSeq  	:= ""
Local aCpoGM8   := {"GM8_DATAGE","GM8_HORAGE","GM8_CODCRM","GM8_NOMCRM","GM8_CODLOC", "GM8_LOCDES","GM8_CODDIS","GM8_DESDIS", "GM8_CODREC", "GM8_CODSAL","GM8_NOMSAL"}
Local aLegCam   := {{"GM8_STATUS == '0'", "BR_VERDE"},; //0=Orc. Pendente;1=Pend.Fin.\Nao Autoriz;2=Aprovado;3=Liberado;4=Cancelado;5=Em tratamento;6=Finalizado
					{"GM8_STATUS == '1'", "BR_VERMELHO"},;
					{"GM8_STATUS == '2'", "BR_AMARELO"},;
					{"GM8_STATUS == '3'", "BR_PINK"},;
					{"GM8_STATUS == '4'", "BR_AZUL"},;
					{"GM8_STATUS == '5'", "BR_LARANJA"},;
					{"GM8_STATUS == '7'", "BR_VIOLETA"}}

Private nFldAtu    := 1 //Folder Atual
Private nFldAnt    := 1 //Folder Anterior
Private nDiaAgeAnt := 1 //Posicao do Dia Anterior no Vetor das Marcacoes
Private nDiaAgeAtu := 1 //Posicao do Dia Atual no Vetor das Marcacoes
Private cCodDis    := " "
Private cCodRec    := " "
Private cObsPlano  := " "
Private cObsProc   := " "
Private cObsProf   := " "
Private cMes   	   := " "
Private lRes800	   := .F.
Private aLocks     := {}
Private aGets      := {}
Private aAgenda    := {}
Private aMeses 	   := {}
Private aHeaderGM8 := {}
Private aColsGM8   := {}
Private cTipoAg    //pega tipo de agenda do parametro A=amb/P=PA
Private nOpcSav    := nOpc //Salva a opcao do aRotina
Private aSize      := MsAdvSize() //Define as coordenadas da tela
Private aOBJETOS   := Array(2)
Private cAno       := StrZero(Year(dDataBase),4)
//Objetos principais do Agendamento
Private oCalend
Private oAno
Private oMeses
Private oPanel2
Private oFolder
//variaveis usadas na funcao HSPM29Marca que e chamada na funcao HSPM54ConsFil que nao pode receber parametro
Private nCodAge := 0
Private nStatus := 0
Private nRegGer := 0
Private nMatric := 0
Private nNomPac := 0
Private nCodPla := 0
Private nDesPla := 0
Private nCodPro := 0
Private nDesPro := 0
Private nCodSal := 0
Private nOriPac := 0
Private nCodCRM := 0
Private nNomCRM := 0
Private nAgenda := 0
Private nHorAge := 0
Private nCodLoc := 0
Private nLocDes := 0
Private nDesDis := 0
Private nHorIni := 0
Private nHorFin := 0
Private nSqCatP := 0
Private nDsCatP := 0
Private nLastFld  := 0 //Ultimo Folder
Private nLastDay  := 0 //Ultimo Dia Agendado
Private nLastHour := 0 //Ultima Hora
Private	nEvento :=0
Private	nDsEven :=0
Private	nPromo  :=0
Private	nProgra :=0
//as variaveis abaixo sao usadas em HSPM29Filtro que nAO PODE RECEBER PARAMETRO PQ E CHAMADA PELA FUNCAO HSPM54ConsFil QUE TAMBEM nao pode receber parametro por ser chamada do X3_VALID
Private aTrfHorAge := {} //Vetor que armazena o Registro a ser Transferido
Private oBrwTrf
Private cFilAtu    	:= " "
Private cFilAgeAtu 	:= " "
Private cCrmAtu    	:= " "
Private cDatAgeAtu 	:= " "
Private cHorAgeAtu 	:= " "
Private cStatAtu   	:= " "
Private cStatus    	:= GM8->GM8_STATUS
Private cGCM_CODCON	:= " " //usada em HSPM54ConsFil que NAO PODER RECEBER PARAMETRO
//Variaveis utilizadas nos filtros HSPM54ConsFil que nao poder receber parametro por ser chamada de valid de X3_VALID
Private cGczCodPla 	:= " "
Private cGf3CodSal 	:= " "
Private cGm7OriCan 	:= " "      //Origem do Cancelamento
Private lDataBase  	:= .T.      //indica se o Filtro da Agenda sera acionado a partir da Data Base do Sistema
Private cGbjCodEsp 	:= " "
Private cGbhCodPac 	:= ""  // Variavel que recebe o retorno da consulta padrão GH1 (Pacientes)
Private cGfvPlano  	:= "" //Filtro de categoria do plano GFV
//Define as variaveis utilizadas na consulta SXB "GM8" para retorno do primeiro horario disponivel
Private cPriDia  	:= " "
Private cPriHor  	:= " "
Private nDiasRet 	:= 0
Private cHorasRet	:= ""
Private oTimerPend //usado em HSPM54ConsFil(cReadVar)//FUNCAO NAO PODER RECEBER PARAMETRO
Private oFont
Private lEstatAge	:= SuperGetMV("MV_ESTAGEN", NIL, .F.)  // Alta após confirmar o atendimento-- passou para local
Private oGetGEB
Private aVCposOld := {} // Guarda variaveis de memoria - usado no ajustasx3 que nao recebe parametro
Private aTela    := {} //usado em outra rotina no momento de cancelar
Private nGebCodMat  := 0// usado na rotina FSVldPrevChd
Private oGO4 // objeto usado em HS_GrvGo4 que nao visualiza com local
Private cProcDoPln := ""
Private cMatVid    := ""
Private cItemAg    := ""
//Variaveis para posicionamento do aCols da GO4
Private nGO4_CodPro := 0
Private nGO4_DESPRO	:= 0
Private nGo4_NumOrc := 0
Private nGo4_IteOrc := 0
//Variaveis para posicionamento do aCols da GEB
Private nGebDescMa  := 0
Private nGebItem	:= 0
Private nGebQtdMat  := 0
Private nGebIteOrc  := 0

Private aRetPro	:={}
Private lacssEnc	:= .T.
Private lConsProm	:= .F.
Private lConsEve 	:= .F.
Eval( bATipo,TRIM(FunName()),"HSPAHM54" )
If GM1->( FieldPos('GM1_USPROM') ) > 0 .and. lPromo
	aRetPro	:=FS_VldUsPr(cGcsCodLoc)
	lacssEnc	:= aRetPro[2]
	lConsProm	:= aRetPro[1]
	lConsEve 	:= aRetPro[3]
Endif

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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos que deverao ser editados na Enchoice                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCpoEnc,"GM8_FILAGE")
Aadd(aCpoEnc,"GM8_MATRIC")
Aadd(aCpoEnc,"GM8_REGGER")
Aadd(aCpoEnc,"GM8_NOMPAC")
Aadd(aCpoEnc,"GM8_TELPAC")
Aadd(aCpoEnc,"GM8_DURACA")
Aadd(aCpoEnc,"GM8_CODPRO")
Aadd(aCpoEnc,"GM8_DESPRO")
Aadd(aCpoEnc,"GM8_CODPLA")
Aadd(aCpoEnc,"GM8_DESPLA")
//
if lOriPac
	Aadd(aCpoEnc,"GM8_ORIPAC")
	Aadd(aCpoEnc,"GM8_DORIPA")
endif
Aadd(aCpoEnc,"GM8_CODSAL")
Aadd(aCpoEnc,"GM8_NOMSAL")
Aadd(aCpoEnc,"GM8_SQCATP")
Aadd(aCpoEnc,"GM8_DSCATP")
Aadd(aCpoEnc,"GM8_CODCRM")
Aadd(aCpoEnc,"GM8_NOMCRM")
Aadd(aCpoEnc,"GM8_OBSERV")
//Aadd(aCpoEnc,"GM8_NUMORC")


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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desliga o Filtro do Status da Agenda                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//HSPM29FilBrw(.T., .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define quais os campos poderao ser editados na Enchoice con- ³
//³ forme a opcao selecionada.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3) //Cancelar
	aAltEnc := {"GM8_OBSERV","GM8_MOTIVO","GM8_ORICAN"}

ElseIf (nOpc == 4 )//Transferir
	aAltEnc := {"GM8_FILAGE","GM8_CODPRO","GM8_DESPRO","GM8_CODPLA","GM8_DESPLA","GM8_SQCATP","GM8_DSCATP",;
	"GM8_CODCRM","GM8_NOMCRM","GM8_OBSERV","GM8_MOTIVO","GM8_ORICAN", "GM8_CODSAL"}

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
nNomPac := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_NOMPAC"}) //Nome do Paciente
nCodPla := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODPLA"}) //Codigo do Plano
nDesPla := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DESPLA"}) //Descricao do Plano
if lOriPac
	nOriPac := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_ORIPAC"}) //Codigo da origem do paciente
	nDoriPa := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DORIPA"}) //Descricao da origem do paciente
endif
//
nCodPro := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODPRO"}) //Codigo do procedimento
nDesPro := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DESPRO"}) //Descricao do Procedimento
nCodSal := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODSAL"}) //Codigo da Sala
nNomSal := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_NOMSAL"}) //Nome da Sala
nCodCRM := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODCRM"}) //CRM
nNomCRM := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_NOMCRM"}) //Nome do Profissional
nAgenda := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DATAGE"}) //Data da Agenda
nHorAge := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_HORAGE"}) //Hora da Agenda
nCodLoc := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_CODLOC"}) //Setor
nLocDes := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_LOCDES"}) //Descricao Setor
If GM8->( FieldPos('GM8_PROMO') ) > 0 .And. GM8->( FieldPos('GM8_PROGRA') ) > 0 .And. GM8->( FieldPos("GM8_EVENTO") ) > 0
	nEvento := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_EVENTO"}) //Evento
	nDsEven := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DSEVEN"}) //Descricao Evento
	nPromo  := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_PROMO"}) //Promoção?
	nProgra := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_PROGRA"}) //Código do Programa
EndIf

nDesDis := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_DESDIS"}) //Descricao da Disponibilidade
nHorIni := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_HORINI"}) //Hora Inicial
nHorFin := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_HORFIN"}) //Hora Final
nSqCatP := Ascan(aHeaderGM8,{|x|AllTrim(x[2])=="GM8_SQCATP"}) //Sequencial da Categoria do Plano
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
Aadd(aTitulos,STR0020) //"&Atendimento"
Aadd(aTitulos,STR0021) //"&Encaixe"
Aadd(aTitulos,STR0022) //"&Observacoes"
Aadd(aTitulos,"&" + STR0179) //"Solicitação de Materiais"
Aadd(aTitulos,"&" + STR0129) //"Procedimentos"
//Aadd(aTitulos,"&Equipamentos") //"&Equipamentos"

Aadd(aPaginas,STR0064) //"ATENDIMENTO"
Aadd(aPaginas,STR0065) //"ENCAIXE"
Aadd(aPaginas,STR0066) //"OBSERVACOES"
Aadd(aPaginas,STR0179) //"SOLICITACAO DE MATERIAIS"
Aadd(apaginas,STR0129)//"Procedimentos"
//Aadd(aPaginas,"EQUIPAMENTOS") //"EQUIPAMENTOS"

/*(#ALTERADO PONTO DE ENTRADA#)
If ExistBlock("HSM54FOL")
	aM54Fol := ExecBlock("HSM54FOL", .F., .F., {1, aTitulos, aPaginas})[1]
	If ValType(aM54Fol) == "A"
	 aTitulos := aClone(aM54Fol[1])
	 aPaginas := aClone(aM54Fol[2])
	EndIf
EndIf
*/
If lEstatAge
	aM54Fol := Hsm54Fol(1, aTitulos, aPaginas)[1]
	If ValType(aM54Fol) == "A"
		aTitulos := aClone(aM54Fol[1])
		aPaginas := aClone(aM54Fol[2])
	endif
EndIf

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ7ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela principal da rotina	                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgM54 TITLE OemToAnsi(cCadastro) From aSize[7],000 To aSize[6],aSize[5] OF GetWndDefault() PIXEL
DEFINE FONT oFont NAME "Arial" SIZE 10,20 BOLD

oPanel1	:=	tPanel():New(aPObjs[1, 1],aPObjs[1, 2],,oDlgM54,,,,,,aPObjs[1, 3],aPObjs[1, 4])
oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

//Cria as variaveis para edicao na enchoice
RegToMemory("GM8",If(nOpc==2,.T.,.F.),.F.)


HS_BDados("GEB", @aHeadGEB, @aColsGEB,, 1,, IIF(!Empty(M->GM8_CODAGE), "GEB->GEB_CODAGE == '" + M->GM8_CODAGE + "'", Nil),,,,,,,,,,,,,,,,,,,aCpoVisGeb,)

nGebItem   := aScan(aHeadGEB, {| aVet | aVet[2] == "GEB_ITEM  "})
nGebCodMat	:= aScan(aHeadGEB, {| aVet | aVet[2] == "GEB_CODMAT"})
nGebDescMa	:= aScan(aHeadGEB, {| aVet | aVet[2] == "GEB_DESCMA"})
nGebQtdMat	:= aScan(aHeadGEB, {| aVet | aVet[2] == "GEB_QTDMAT"})
nGebNumOrc := aScan(aHeadGEB, {| aVet | aVet[2] == "GEB_NUMORC"})
nGebIteOrc := aScan(aHeadGEB, {| aVet | aVet[2] == "GEB_ITEORC"})

If Empty(aColsGEB[1, nGebItem])
	aColsGEB[1, nGebItem] := StrZero(1, Len(GEB->GEB_ITEM))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procedimentos Agendados oFolder:aDialogs[5]                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HS_BDados("GO4", @aHGO4, @aCGO4, @nUGO4, 1,, " GO4_CODAGE = '" + M->GM8_CODAGE + "'")//, .T.)

nGO4_CODPRO := aScan(aHGO4, {| aVet | aVet[2] == "GO4_CODPRO"})
nGO4_DESPRO := aScan(aHGO4, {| aVet | aVet[2] == "GO4_DESPRO"})
nGo4_NumOrc := aScan(aHGO4, {| aVet | aVet[2] == "GO4_NUMORC"})
nGo4_IteOrc := aScan(aHGO4, {| aVet | aVet[2] == "GO4_ITEORC"})

If Type("lCopiar") <> "U" .And. lCopiar
	// se teclado copia entao preenche as variaveis
	Eval(bCopia)
	lCopiar := .F.
EndIf

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
oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oPanel2	:=	tPanel():New(aPEnc[2, 1],aPEnc[2, 2],, oPanel1,,,,,,aPEnc[2, 3],aPEnc[2, 4],,.T.)
oPanel2:Align := CONTROL_ALIGN_RIGHT

If (nOpc==4 .or. nOpc==2) //Transferir  ou Agendar
	HSPM29IniTrf(.T.,nOpc)
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
oMeses:bChange := {||FS_UnLock(nFldAtu, nDiaAgeAtu), HSPM29Navega(NIL,"+",NIL,@lDataAtu,@cAno),HSPM29Filtro(nOpc,lRegAtu)}//FS_UNLOCK - Desbloqueia o registro sempre que se muda o mes

If (nOpc==3 .Or. nOpc==5) //Se Cancelamento ou Alteracao, desabilita a navegacao dos Meses
	oMeses:Disable()
EndIf

DEFINE FONT oFontPen NAME "Arial" SIZE 12,24 BOLD
@ 080,175 + IIF(!lRes800, 25, 0) SAY oTxtPend PROMPT OemToAnsi("") Of oPanel2 SIZE 20, 010 FONT oFontPen Pixel COLOR Rgb(255,100,0)
oTimerPend := TTimer():New(1000, {|| FS_INFPEND(@oTxtPend,@cPend) }, oDlgM54 )   //Atualiza e posiciona grid de pacientes
oTimerPend:DeActivate()

//Selecao atraves do Calendario
oCalend            := MsCalend():New(02, aPCal[1], oPanel2)
oCalend:bChangeMes := {||FS_UnLock(nFldAtu, nDiaAgeAtu), HSPM29Navega(NIL,NIL,"+",@lDataAtu,@cAno),HSPM29Filtro(nOpc,lRegAtu)} //FS_UNLOCK - Desbloqueia o registro sempre que se muda o mes
oCalend:bChange    := {||HSPM29MkDia()}

If (nOpc==3 .Or. nOpc==5) //Se Cancelamento ou Alteracao, desabilita a navegacao no Calendario
	oCalend:Disable()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe a Legenda Padrao da Rotina                     							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 68,aPCal[1] 				BITMAP oVermelho RESOURCE "BR_VERMELHO" SIZE 008,008 OF oPanel2 ADJUST PIXEL NOBORDER When .F.
@ 68,aPCal[1]+10		Say OemToAnsi(STR0024) OF oPanel2 SIZE 030,010 Pixel  //"Ocupado"

@ 68,aPCal[1]+40		BITMAP oAmarelo  RESOURCE "BR_AZUL"     SIZE 008,008 OF oPanel2 ADJUST PIXEL NOBORDER When .F.
@ 68,aPCal[1]+50		Say OemToAnsi(STR0025) OF oPanel2 SIZE 030,010 Pixel  //"Parcial"

@ 68,aPCal[1]+80 	BITMAP oVerde    RESOURCE "BR_VERDE"    SIZE 008,008 OF oPanel2 ADJUST PIXEL NOBORDER When .F.
@ 68,aPCal[1]+90	 Say OemToAnsi(STR0026) OF oPanel2 SIZE 030,010 Pixel  //"Livre"

@ 68,aPCal[1]+120 	BITMAP oBranco   RESOURCE "BR_BRANCO"   SIZE 008,008 OF oPanel2 ADJUST PIXEL NOBORDER When .F.
@ 68,aPCal[1]+130	Say OemToAnsi(STR0209) OF oPanel2 SIZE 030,010 Pixel  //"Transferido"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Edicao do Atendimento/Encaixe                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder := TFolder():New(aPObjs[2, 1],aPObjs[2, 2],aTitulos,aPaginas,oDlgM54,,,,.T.,.F.,aPObjs[2, 3],aPObjs[2, 4])
oFolder:Align := CONTROL_ALIGN_BOTTOM

/*(#ALTERADO PONTO DE ENTRADA#)
If ExistBlock("HSM54FOL")
	ExecBlock("HSM54FOL", .F., .F., {2, aPMemo, nOpc})
EndIf*/
If lEstatAge
	Hsm54Fol(2, aPMemo, nOpc)
EndIf

oFolder:bSetOption := {|nAt| nFldAtu    := nAt, ;
                             nFldAnt    := oFolder:nOption, ;
                             nDiaAgeAtu := IIf(nFldAtu <= Len(aObjetos), aObjetos[nFldAtu][1]:nAt, nDiaAgeAtu), ; //Define as novas posicoes no aAgenda
                             nDiaAgeAnt := IIf(nFldAnt <= Len(aObjetos), aObjetos[nFldAnt][1]:nAt, nDiaAgeAnt), ;
                             HSPM29SavAge(nFldAtu, nFldAnt, nDiaAgeAtu, nDiaAgeAnt), ; // Salva a Marcacao Atual
                             HSPM29PaintCalend()} // Atualizacao do Agendamento

oFolder:bChange := {|| IIf(!HSPM29VerHorEnc(nFldAnt), (oFolder:SetOption(nFldAnt) , oFolder:Refresh()), .T.)} //Verifica se o Horario foi informado, caso seja um Encaixe

Aeval(aOBJETOS,{|x,y|aOBJETOS[y]:=HSPM54Brw(oFolder:aDialogs[y],y)})       //Monta os 	browse referentes a Ocupacao e Agenda

Aeval(aOBJETOS,{|x|x[1]:blDblClick:={||FS_RestMem(),HSPM29Marca("1",oFolder)}})         //Marca o Agendamento pela Ocupacao
Aeval(aOBJETOS,{|x|x[2]:oBrowse:blDblClick:={||FS_RestMem(),HSPM29Marca("2",oFolder)}}) //Marca o Agendamento pela Disponibilidade

Aeval(aOBJETOS,{|x|x[2]:oBrowse:bGotFocus:={||nFldAtu := oFolder:nOption, FS_SaveMem(cAlias)}})
Aeval(aOBJETOS,{|x|x[2]:oBrowse:bChange:={||HSPM29Marca("1",oFolder)}})

Aeval(aOBJETOS,{|x|x[1]:bChange:={||If(HSPM29VerHorEnc(nFldAtu),; //Verifica se o Horario foi informado, caso seja um Encaixe
HSPM29SavAge(nFldAtu,nFldAtu,nDiaAgeAtu:=aOBJETOS[nFldAtu,1]:nAt,nDiaAgeAnt),; //Salva a marcacao Atual
(aOBJETOS[nFldAtu,1]:nAt:=nDiaAgeAtu,aOBJETOS[nFldAtu,1]:Refresh())),;        //Define as novas posicoes no Vetor aAgenda
HSPM29PaintCalend()}})                                                          //Atualizacao do Agendamento

Aeval(aOBJETOS,{|x|x[2]:oBrowse:bLostFocus:={||HSPM29SavAge(NIL,nFldAtu,NIL,nDiaAgeAtu),FS_RestMem()}})
aObjetos[1, 1]:Align         := CONTROL_ALIGN_TOP
aObjetos[1, 2]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
aObjetos[2, 1]:Align         := CONTROL_ALIGN_TOP
aObjetos[2, 2]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

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

// Solicitação de materiais e medicamentos
oGetGEB := MsNewGetDados():New(aPMemo[1, 1],aPMemo[1, 2], aPMemo[1, 3], aPMemo[1, 4], nOpc,,,"+GEB_ITEM",,,,,,, oFolder:aDialogs[4], aHeadGEB, aColsGEB)
oGetGEB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetGEB:bLinhaOk := {|| HS_DuplAC(oGetGEB:oBrowse:nAt, oGetGEB:aCols, {nGebCodMat})}

/*// Equipamentos
oGetGET := MsNewGetDados():New(aPMemo[1, 1],aPMemo[1, 2], aPMemo[1, 3], aPMemo[1, 4], nOpc,,,"+GET_ITEAGE",,,,,,, oFolder:aDialogs[5], aHeadGET, aColsGET)
oGetGET:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetGET:oBrowse:bdelete  := {|| Iif(FS_DelGET(nOpc), oGetGET:DelLine(), .F.)} */

// Procedimentos
oGO4 := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nOpc,,, /*"+GO4_CODITE"*/,,, 99999,,,, oFolder:aDialogs[5], aHGO4, aCGO4)
oGO4:bLinhaOk := {|| HS_DuplAC(oGO4:oBrowse:nAt, oGO4:aCols, {nGO4_CODPRO},, .T.)}
oGO4:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

Aadd(aButtons	, {"edit_ocean", {||HS_ConsAge("A")}, STR0074}) //"Consultar"
Aadd(aButtons	, {"edit_ocean", {||fs_perfCli(1 , M->GM8_REGGER)}, STR0181}) //"Perfil Financeiro"
Aadd(aButtons	, {"edit_ocean", {||fs_perfCli(2 , M->GM8_REGGER)}, STR0182}) //"Banco de Conhecimentos"
Aadd(aButtons	, {"edit_ocean", {||fs_perfCli(3 , M->GM8_REGGER)}, STR0183}) //"Ficha de Tratamento"

If Type("lCopiar") <> "U" .And. aRotina[nOpc,4] == 3
	Aadd(aButtons	, {"SduRepl"   , {|| lCopiar := .T., Eval(bGrava), nOpc := 2, Eval(bOk)}, STR0184}) //"Copiar"
EndIf

If nOpc == 2 .And. Type("__aCpAuM29") <> "U" .And. !Empty(__aCpAuM29)
	oDlgM54:bStart := { || IIf( !FS_M29CpAu(nOpc, @oEnchoice), oDlgM54:End(), Nil) } // Se retorna falso.. sai da agenda.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a rotina que irá listar os agendamentos sugeridos  ³
//³que foram selecinados logo após a geração de Horários.   ³
//³para visualização da tela é necessario clicar F6.        ³
//³Funcionalidade da Promoção Saude.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lPromo
	bKeyF6 := SetKey(VK_F6,{||PlsPreAg(CTOD(""),CTOD(""),"", "",@cItemAg,@cMatVid)})
EndIf

Aadd(aButtons	, {"edit_ocean", {||HS_AGENPAC(M->GM8_REGGER)}, STR0001}) //"Confirmar / Cancelar" //"Confirmar / Cancelar "

///Ponto de entrada para exclusão inclusão dos Botões na Agenda
iF !lacssEnc
	oFolder:aDialogs[02]:disable()
Else	
	oFolder:aDialogs[02]:enable()	
endif

If ExistBlock("HSM54BOT")
	aButtons := ExecBlock("HSM54BOT", .F., .F., {aButtons})
	If ValType(aButtons) == "A"
	 	aButtons := aClone(aButtons)
	EndIf
EndIf


ACTIVATE MSDIALOG oDlgM54 ON INIT EnchoiceBar(oDlgM54, bOk, bCancel,,aButtons) VALID .T.

If !Empty(aLocks)
	//Caso houve alguma falha que deixou "registros presos" (nao prende o registro eh apenas um semáforo)
	//eles serao liberados aqui
	For nFor := 1 To Len(aLocks)
		If Len(aLocks) >= nFor
			FS_UByName(aLocks[nFor])
		EndIf
	Next
EndIf
If nOpc == 2 .And. lOk
	HS_RelM29()
	MBrChgLoop(.T.)
elseif nOpc==3 .and. lOk //Cancelar
	
	DbSelectArea("GM8")
	DbSetOrder(1)
	// posiciona no registro selecionado da tabela
	If GM8->(MsSeek(xFilial("GM8") + cCodAge))
		If GM8->GM8_STATUS == "3" //Horario Atendido
			cMsgAge := STR0063 //"O Horario selecionado ja foi atendido"
			lHelp   := .T.
			
		Else
			cMsgAge := STR0050 + aRotina[nOpc, 1] + STR0051 //"Não será possível " ### " o Horario selecionado na Agenda"
			
			If !(GM8->GM8_STATUS $ "1/4/5")
				lHelp := .T.
			EndIf
			
			If GM8->GM8_DATAGE < dDataBase
				cMsgAge += STR0052 //", com Data retroativa "
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

		
		M54CAgd(GM8->GM8_CODAGE,GM8->GM8_MOTIVO,@cSeq)
		MsgInfo := cSeq

		aColsGM8 := {}
		nUGM8 := 0

		HS_BDados("GM8", @aHeaderGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_REGGER == '" + M->GM8_REGGER + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_DATAGE >= '" + DTOS(dDataBase) + "' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' ",,"GM8_STATUS",/*"GM9_DATAGE/GM9_HORAGE/GM9_CODCRM/GM9_NOMCRM/GM9_CODLOC/GM9_LOCDES/GM9_CODDIS/GM9_DESDIS/GM9_CODREC/GM9_CODSAL/GM9_NOMSAL"*/,,,,,,.F.,aLegCam,,,,, aCpoGM8,)

		HS_MsgInf(OemToAnsi("Agendamento Cancelado"), STR0077, STR0073)
	endif

EndIf

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM54  ºAutor  ³Microsiga           º Data ³  09/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Salva valor das variaveis de memoria para restaurar no final
Static Function FS_SaveMem(cAlias)
	DbSelectArea("SX3")
	DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
	DbSeek(cAlias)
	While SX3->X3_ARQUIVO == cAlias
	 	If Type("M->" + SX3->X3_CAMPO ) <> "U"
	  	aAdd(aVCposOld, {"M->" + SX3->X3_CAMPO , &("M->" + SX3->X3_CAMPO) })
	 	EndIf
	 	SX3->(DbSkip())
	End
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_RestMemº Autor ³Microsiga           º Data ³  10/25/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Recupera Variaveis de Memoria.			                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RestMem()

Local nCposOld := 0
For nCposOld := 1 To Len(aVCposOld)

	&(aVCposOld[nCposOld, 1]) := aVCposOld[nCposOld, 2]

Next nCposOld

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_perfCliºAutor  ³                    º Data ³  03/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que exibe o historico financeiro, Banco de Conheci   º±±
±±º          ³mentos do cliente para o paciente selecionado               º±±
±±º          ³                                                            º±±
±±º          ³Parametros:												  º±±
±±º          ³nOpc    = informa a funcao que devera ser executada         º±±
±±º          ³          1 - Perfil Financeiro                             º±±
±±º          ³          2 - Banco de Conhecimentos                        º±±
±±º          ³cCodPac = codigo do paciente                                º±±
±±º          ³Retorno:	     											  º±±
±±º          ³null                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fs_perfCli(nOpc,cCodPac,nPosArotina)
Local cArea    := getArea()
Local aCposPac := {}
Local nRecSA1  := 0

Private aParam := {}

Private cCadastro	:=	STR0005 	  // "Consulta Posi‡ao Clientes"

//Se o código do paciente nao foi informado
if alltrim(cCodPac)==""
	Hs_MsgInf(STR0185,STR0077, STR0186) //"Informe o código do paciente!" ### "Atenção" ### "Pesquisa paciente"
	restArea(cArea)
	return
endif

//Perfil Financeiro
If nOpc == 1
	//Posicionando no registro do cliente na SA1
	DbSelectArea("SA1")
	DbSetOrder(1)
	if !DbSeek(xFilial("SA1")  + fs_getCodC(cCodPac))
		Hs_MsgInf(STR0187, STR0077, STR0188) //"Paciente não localizado no cadastro de clientes!" ### "Atenção" ### "Pesquisa histórico financeiro"
		DbCloseArea()
		restArea(cArea)
		return
	else
		nRecSA1 := RECNO()
	endif

	If Pergunte("FIC010",.T.)
		aadd(aParam,MV_PAR01)
		aadd(aParam,MV_PAR02)
		aadd(aParam,MV_PAR03)
		aadd(aParam,MV_PAR04)
		aadd(aParam,MV_PAR05)
		aadd(aParam,MV_PAR06)
		aadd(aParam,MV_PAR07)
		aadd(aParam,MV_PAR08)
		aadd(aParam,MV_PAR09)
		aadd(aParam,MV_PAR10)
		aadd(aParam,MV_PAR11)
		aadd(aParam,MV_PAR12)
		aadd(aParam,MV_PAR13)
		aadd(aParam,MV_PAR14)
		aadd(aParam,MV_PAR15)
	Else
		Return()
	endif

	//Exibe funcao do historico financeiro do cliente
	//Fc010Con("SA1",nRecSA1,3)
	SA1->(dbGoTo(nRecSA1))
	Finc010(2)


//Banco de Conhecimentos
elseif nOpc == 2

	DbSelectArea("GBH")
	DbSetOrder(1)
	if !DbSeek(xFilial("GBH")  + cCodPac)
		Hs_MsgInf(STR0189, STR0077, STR0190) //"Paciente não localizado!" ### "Atenção" ### "Pesquisa banco de conhecimentos"
		DbCloseArea()
		restArea(cArea)
		return
	else
		//Obtem os campos que serao exibidos no banco de conhecimentos
		FS_ADX3COLM54("GBH", @aCposPac, .T., {"GBH_SEXO"})
		HSPGBHBco(cCodPac,aCposPac)
	endif

elseif nOpc == 3
	HSPAHM61(fs_getCodC(cCodPac), cCodPac)
endif

restArea(cArea)
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_getCodCºAutor  ³                    º Data ³  03/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para retornar o codigo do cliente SA1->A1_CODCLI/    º±±
±±º          ³GBH->GBH_CODCLI a partir do codigo do paciente GBH_CODPAC   º±±
±±º          ³                                                            º±±
±±º          ³Parametros:												  º±±
±±º          ³cGbhCodPac  = codigo do paciente                            º±±
±±º          ³Retorno:	     											  º±±
±±º          ³GBH->GBH_CODCLI : Caracter                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

function fs_getCodC(cGbhCodPac)
Local cArea := getArea()
Local cCodigo := "______"

DbSelectArea("GBH")
DbSetOrder(1)
If DbSeek(xFilial("GBH")  + cGbhCodPac)
	cCodigo := GBH->GBH_CODCLI
Endif

restArea(cArea)

return cCodigo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM54  ºAutor  ³Luiz Pereira S. Jr. º Data ³  27/06/07   º±±
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
	Next nFor

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
±±³Fun‡ao    ³HSPM54Brw ³ Autor ³Paulo Emidio de Barros ³ Data ³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta a edicao para Ocupacao/Atendimento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM54Brw(EXPO1,EXPN1)                                     ³±±
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
Function HSPM54Brw(oTela,nFolder)
Local aCampos := {}
Local aSize   := {}
Local bBlock
Local oBrwOcu
Local oGetAte
Local aOpcNGD := {}
Local aAltera := {}
Local aM54Brw := {}

Aadd(aOpcNGD,0)
Aadd(aOpcNGD,GD_UPDATE)

Aadd(aAltera,{})
Aadd(aAltera,{"GM8_HORAGE"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a Ocupacao na Agenda                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {STR0030,STR0031,STR0026,STR0032,STR0033,STR0034,STR0035,STR0036,STR0221} //"Dia" ### "Total" ### "Livre" ### "%Livre" ### "Hora" ### "Ocupada" ### "%Ocupada" #### "Indisponivel" #### "Transferidos"
aSize   := {50,30,30,30,30,30,30,30}
bBlock  := {||Afill(Array(Len(aSize))," ")}

/*(#ALTERADO PONTO DE ENTRADA#)
If ExistBlock("HSM54BRW")
	aM54Brw := ExecBlock("HSM54BRW", .F., .F., {1, nFolder, aCampos, aSize})
	If ValType(aM54Brw) == "A"
	 aCampos := aClone(aM54Brw[1])
	 aSize   := aClone(aM54Brw[2])
	EndIf
EndIf
*/
aM54Brw := HSM54BRW(1, nFolder, aCampos, aSize)
If ValType(aM54Brw) == "A"
	aCampos := aClone(aM54Brw[1])
	aSize   := aClone(aM54Brw[2])
EndIf

oBrwOcu := TwBrowse():New(000.3,000.4,496,058.5,bBlock,aCampos,aSize,oTela)

// Desabilita SX3 Obrigat
aHeaderGM8[5][17]:=.F.  // GM8_NOMPAC
aHeaderGM8[7][17]:=.F.  // GM8_CODPLA
aHeaderGM8[13][17]:=.F. // GM8_CODCRM
aHeaderGM8[15][17]:=.F. // GM8_CODPRO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os Horarios na Agenda                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetAte := MsNewGetDados():New(065,003.5,126.5,499.5,aOpcNGD[nFolder],"AllwaysTrue()","AllwaysTrue()","",aAltera[nFolder],,,,,,oTela,aHeaderGM8,aColsGM8)

Return({oBrwOcu,oGetAte})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPAHMLEG ³ Autor ³Paulo Emidio de Barros ³ Data ³02/12/2004³±±
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
Function HSPAHM54LEG()
Local aLegenda := {}
Local cCadastro  := OemToAnsi(STR0152) //"Agenda Clinica"

Aadd(aLegenda,{"BR_VERDE"   ,OemToAnsi(STR0026)}) //"Livre"
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0037)}) //"Agenda Ocupada"
Aadd(aLegenda,{"BR_PRETO"   ,OemToAnsi(STR0067)}) //"Encaixe Ocupado"
Aadd(aLegenda,{"BR_AMARELO" ,OemToAnsi(STR0038)}) //"Bloqueado"
Aadd(aLegenda,{"BR_PINK"    ,OemToAnsi(STR0062)}) //"Atendido"
Aadd(aLegenda,{"BR_AZUL"    ,OemToAnsi(STR0075)}) //"Ocupado/Bloqueado"
Aadd(aLegenda,{"BR_LARANJA"  ,OemToAnsi(STR0080)}) //Confirmado //"Confirmado"
Aadd(aLegenda,{"BR_VIOLETA"  ,OemToAnsi("Em conferência")})
Aadd(aLegenda,{"BR_BRANCO"		,OemToAnsi(STR0209)}) //"Transferido"

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
Static Function HSPM29Navega(cNavAno,cNavMesLst,cNavMesCal,lDataAtu,cAno)

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a faixa de dias para o Agendamento                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lDataAtu := .F.

/*(#ALTERADO PONTO DE ENTRADA#)
If ExistBlock("HSM54FOL")
 ExecBlock("HSM54FOL", .F., .F., {4})
EndIf*/
If lEstatAge
	Hsm54Fol(4)
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM54ConsFil³ Autor ³Paulo Emidio de Barros³Data³02/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza as consistencias necessarias para o Filtro         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM54ConsFil()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = .T. = Verdadeiro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       | HSPAHM029                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM54ConsFil(cReadVar)//FUNCAO NAO PODER RECEBER PARAMETRO
Local lRetorno  := .T., aRVldVig, cTpAgeEsc, cSQL := ""
Local aM54Fin := {}
Local nMaxTit	:= 0
Local aVldPFin	:= {}
Local lRetCodPl	:= .T.

//definicoes para chamar o extrato caso retorno Esteje na Carencia.         ***programador: Marcelo Jose 21/07/2005
Local bCampoDia := {|U| IIf(U == "A", aRVldVig	:= {{0, "GC1_NDIASR"},{"","GC1_HORRTA"}}, aRVldVig	:= {{0, "GC1_NDIASP"},{"","GC1_HORRTP"}})}
Local bTipoAgen := {|U| IIf(U == "A", cTpAgeEsc := STR0093, cTpAgeEsc := STR0094)} //"Ambulatorio"###"Pronto Atendimento"
Local bSetaTpAg := {|| Eval( bCampoDia, cTipoAg ), Eval( bTipoAgen, cTipoAg ) }
local lVal:=.f.
Local lPromo := GETNEWPAR("MV_PROSAUD",.F.)
Local lPlanProm:=.T.  
Local lAvisoProm:=.T. 
Local lFicTrat := .T.

Default cReadVar := ReadVar()

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
	/*(#ALTERADO PONTO DE ENTRADA#)
	If ExistBlock("HSM54FIN") .And. !ExecBlock("HSM54FIN", .F., .F.)
	 	Return(.F.)
	EndIf*/
	IF (FSPlaTrat(GBH->GBH_CODCLI, GBH->GBH_CODPAC)  ) .and. VldAgend(.F.,.F.)
			
		If  Aviso(	STR0077, STR0222  + Alltrim(GBH->GBH_NOME) + STR0223,{ STR0224, STR0225}, 2 ) == 1 //"Atenção"###" O Paciente "##" possui Ficha de Tratamento e Planejamento da Promoção da Saúde.Selecione qual agendamento deseja Realizar.   "##"Ficha Trat" ##"Planejamento"
    		lPlanProm:=.F.
			lAvisoProm:=.T.
			If !Hsm54Fin()
				Return(.F.)
			Endif	
		Else
			lPlanProm:=.T.
			lAvisoProm:=.F.
		Endif
    Else
    	//Ponto de Entrada para apresentar na tela a Ficha de Tratamento
    	If ExistBlock("HSM54FCTRA") 
	 		lFicTrat := ExecBlock("HSM54FCTRA", .F., .F.)
		EndIf
		
		If lFicTrat .AND. !Hsm54Fin() 
			Return(.F.)
		Endif	
		lAvisoProm:=.T.
 	If lPromo
 		If GA7->( FieldPos('GA7_PROMOC') ) > 0
 			If !(lRetorno := FS_VldProc(M->GM8_CODPRO,M->GM8_REGGER))
				HS_MsgInf(STR0228 , STR0077, STR0137) //"Atenção"###"Consistencias necessarias para o Filtro" //"Procedimento Permitido somente  para Paciente da Promoção da Saude"
			Endif
		EndIf
 	Endif
 
	Endif
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
	//If !(lRetorno := HS_SEEKRET('GA7', 'M->GM8_CODPRO', 1, .F., 'GM8_DESPRO', 'GA7_DESC'))
	If !(lRetorno := HS_SEEKRET('GA7', 'M->GM8_CODPRO', 1, .F., {'GM8_DESPRO','GM8_DURACA'}, {'GA7_DESC','GA7_TEMPRO'}))
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

	//EXECUTAR A FUNCAO QUE VALIDA SE E UMA NOVA CONSULTA OU UM RETORNO
	FS_HorAge()
	M->GM8_DESPRO	:=	GA7->GA7_DESC
	cObsProc      := GA7->GA7_OBSERV //Observacao do Procedimento
	cGbjCodEsp	   :=	GA7->GA7_CODESP //Especialidade do Procedimento

	/*(#ALTERADO PONTO DE ENTRADA#)
	If lRetorno .And. ExistBlock("HSM54FOL")
		lRetorno := ExecBlock("HSM54FOL", .F., .F., {3})[2]
 	EndIf*/
	If lRetorno .AND. lEstatAge
		lRetorno := Hsm54Fol(3)[2]
 	EndIf

 If lPromo
 	If GA7->( FieldPos('GA7_PROMOC') ) > 0
 		If !(lRetorno := FS_VldProc(M->GM8_CODPRO,M->GM8_REGGER))
			HS_MsgInf(STR0228 , STR0077, STR0137) //"Atenção"###"Consistencias necessarias para o Filtro" //"Procedimento Permitido somente  para Paciente da Promoção da Saude"
		Endif
	EndIf
 Endif
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
		If !(lVal:=HS_VAltPac(GBH->GBH_CODPAC,.T.))
			 Return(.f.)
		Endif

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

			If !HSPM54ConsFil("M->GM8_CODPLA",cGcsCodLoc)
			 	Return(.F.)
			Else
				lRetCodPl := .F.
			EndIf
		EndIf

		//----------------------------------------------------------------------------------
		// Função criada para validar se o paceinte é participante de algum programa saúde
		// e se possui planejamento ativo
		//----------------------------------------------------------------------------------
		If lPromo 
			VldAgend(lPlanProm,lAvisoProm)
		Endif	
		HSPM29Filtro(2) //chama a rotina para preencher os horarios agendados futuros
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

 	If lRetorno
 		DbSelectArea("GBH")
 		DbSetOrder(1)
 		If DbSeek(xFilial("GBH") + M->GM8_REGGER)
			aVldPFin := HS_VLDPFIN(GBH->GBH_CODCLI, GBH->GBH_LOJA)
 			If aVldPFin[1] > 0
 				oTimerPend:Activate()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso lRetCodP igual a false, indica que já foram validados os parâmetros³
				//³ MV_MAXAGE e MV_MAXATE na função HSM54Fin								³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRetCodPl
					nMaxTit  := IIf(FunName() == "HSPAHM54", SuperGetMV("MV_MAXAGE",, 0), SuperGetMV("MV_MAXATE",, 0))
					If aVldPFin[1] > nMaxTit
						lRetorno := HSMsgVFin(aVldPFin)
						lRetorno := HSVldSup(lRetorno)
					EndIf
				EndIf
 			Else
 				oTimerPend:DeActivate()
 			EndIf
 		Else
 			oTimerPend:DeActivate()
 		EndIF
 	EndIf

Elseif cReadVar == "M->GM8_NOMPAC"

	If !Empty(cGbhCodPac)
		M->GM8_REGGER := cGbhCodPac
		If !HSPM54ConsFil("M->GM8_REGGER",cGcsCodLoc)
			FS_LIMPM54()
			Return(.F.)
		EndIf
	EndIf

	//----------------------------------------------------------------------------------
	// Função criada para validar se o paceinte é participante de algum programa saúde
	// e se possui planejamento ativo
	//----------------------------------------------------------------------------------
	If lPromo 
		VldAgend(lPlanProm,lAvisoProm) 
	Endif	

  	If !lVal
  		If !Empty(GBH->GBH_CODPAC)
	  		IF !(HS_VAltPac(GBH->GBH_CODPAC,.T.))
				Return(.F.)
			EndIf
		Else
			Return(.F.)
		EndIf
	EndIf

ElseIf cReadVar == "M->GM8_CODCRM"

	cFilAnt := M->GM8_FILAGE
	cGbjCodEsp	   :=	GA7->GA7_CODESP //Especialidade do Procedimento

	GBJ->(dbSetOrder(1)) // GBJ_FILIAL + GBJ_CRM
	If GBJ->(lRetorno := dbSeek(xFilial("GBJ")+M->GM8_CODCRM))
		cObsProf := GBJ->GBJ_OBSERV //Observacao do Profissional

		If HS_IniPadr("GBJ", 1, M->GM8_CODCRM, "GBJ_IDAGEN",, .F.) $ " /1"     //NENHUM/CIRUR.
			HS_MsgInf(STR0084, STR0077,STR0100)   //"CRM do Medico Invalido! Médico não habilitado para incluir uma disponibilidade."###"Atencao"###"Disponibilidade Medica"
			Return lRetorno := .F.

		ElseIf !Empty(M->GM8_CODPRO) .And. !(cGbjCodEsp $ HS_REspMed(M->GM8_CODCRM))
			HS_MsgInf(STR0085, STR0077, STR0101) //"Médico Inválido! Verifique a especialidade do médico e do procedimento."###"Atenção"###"Especialidade Medica"
			Return lRetorno := .F.
		Endif

		SRA->(DbSetOrder(11)) // RA_FILIAL + RA_CODIGO
		If SRA->(DbSeek(xFilial("SRA")+M->GM8_CODCRM))
			M->GM8_NOMCRM := SRA->RA_NOME
		EndIf

		lRetorno := HS_ProMed(M->GM8_CODCRM, M->GM8_CODPRO, M->GM8_REGGER, nDiasRet,,cHorasRet, GM8->GM8_CODLOC)[2]


	Else
		HS_MsgInf(OemToAnsi(STR0071), STR0077, STR0095)   //"CRM não encontrado"###"Atenção"###"Consistencias necessarias para o Filtro"
	Endif
elseif cReadVar == "M->GM8_ORIPAC"
	GD0->(DbSetOrder(1))
	if !empty(M->GM8_ORIPAC) .and. !dbSeek(xFilial("GD0") + M->GM8_ORIPAC)
		HS_MSGINF(STR0191,STR0077, STR0108) //"Origem não localizada!"
		return .F.
	endif
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
	HSPM29Filtro(nOpcSav,.F.)
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
Static Function HSPM29Filtro(nOpc,lRegAtu)// NAO PODE RECEBER PARAMETRO PQ E CHAMADA PELA FUNCAO HSPM54ConsFil QUE TAMBEM nao pode receber parametro
Local aAreaAnt  := GetArea()
Local aAreaGM8  := GM8->(GetArea())
Local lContinua := .T.
Local nPosAge   := 0, nIteAge := 0
Local aColsAux  := {}
Local cChave    := " "
Local bWhile
Local lQuery    := .F.
Local cQuery    := " "
Local aStruGM8  := {}
Local nPosCpo   := 0
Local dInicio   := FirstDay(IIf(!Empty(cPriDia), cPriDia, oCalend:dDiaAtu))
Local dFinal    := LastDay(dInicio)
Local nPosDia   := 0
Local aM54Brw   := {} // Usada no retorno do PE HSM54Brw

Private cAliasGM8 := "GM8"

//ConOut("lExecFilt [" + IIf(lExecFilt, "True", "False") + "]")

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

If nOpc == 2 //Agendar
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia o Browse com oS registros da Agenda Futuras          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 aTrfHorAge := {} //zera o vetor de dados agendados para preencher novamente
 HSPM29IniTrf(.F.,nOpc)
EndIf

If !Empty(M->GM8_FILAGE) .And. !Empty(M->GM8_CODPLA) .And. !Empty(M->GM8_CODPRO) .And. !Empty(M->GM8_CODCRM)

	If nOpc == 2 //Agendar se ja tem campos preenchidos
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³ Inicia o Browse com oS registros da Agenda Futuras          ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  aTrfHorAge := {}
  HSPM29IniTrf(.F.,nOpc)
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³ Inicia o Browse com o registro da Agenda a ser transferido   ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ElseIf (lRegAtu .And. nOpc==4 )
		HSPM29IniTrf(.F.,nOpc)
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
		 dbSetOrder(4)   // GM8_FILIAL + GM8_FILAGE + GM8_CODCRM + GM8_DATAGE + GM8_HORAGE + GM8_STATUS

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
		 cQuery += "GCS.GCS_NOMLOC GM8_LOCDES, "

		 If GM8->( FieldPos("GM8_EVENTO") ) > 0
			 cQuery += "GM8.GM8_EVENTO GM8_EVENTO, "
			 cQuery += "SX5.X5_DESCRI GM8_DSEVEN, "
		 EndIf

		 cQuery += "GM8.GM8_CODDIS GM8_CODDIS, "
		 cQuery += "GM6.GM6_DESDIS GM8_DESDIS, "
		 cQuery += "GM6.GM6_HORINI GM8_HORINI, "
	     cQuery += "GM6.GM6_HORFIM GM8_HORFIN, "
		 cQuery += "GM8.GM8_CODAGE GM8_CODAGE, "
		 cQuery += "GM8.GM8_CODCON GM8_CODCON, "
		 cQuery += "GM8.GM8_MOTIVO GM8_MOTIVO, "
		 cQuery += "GM8.GM8_TIPAGE GM8_TIPAGE, "
		 cQuery += "GM8.GM8_ORICAN GM8_ORICAN, "
		 cQuery += "GM8.GM8_CODSAL GM8_CODSAL  "
		 cQuery += "FROM       "+RetSqlName("GM8") + " GM8 "
		 cQuery += " JOIN      "+RetSqlName("GM6") + " GM6 ON GM8.GM8_CODDIS = GM6.GM6_CODDIS AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6.D_E_L_E_T_ <> '*' "
		 cQuery += " JOIN      "+RetSqlName("SRA") + " SRA ON RTRIM(GM8.GM8_CODCRM) = RTRIM(SRA.RA_CODIGO) AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
		 cQuery += " JOIN      "+RetSqlName("GCS") + " GCS ON GM8.GM8_CODLOC = GCS.GCS_CODLOC AND GCS.GCS_FILIAL  = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
		 cQuery += " JOIN      "+RetSqlName("GM3") + " GM3 ON GM3.GM3_FILIAL = '" + xFilial("GM3") + "' AND GM3.D_E_L_E_T_ <> '*' AND GM8.GM8_CODDIS = GM3.GM3_CODDIS AND GM3.GM3_CODPRO = '" + M->GM8_CODPRO + "' "
		 cQuery += " JOIN      "+RetSqlName("GM2") + " GM2 ON GM2.GM2_FILIAL = '" + xFilial("GM2") + "' AND GM2.D_E_L_E_T_ <> '*' AND GM8.GM8_CODLOC = GM2.GM2_CODLOC AND GM2.GM2_CODPRO = '" + M->GM8_CODPRO + "' "
		 cQuery += " LEFT JOIN "+RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GM8.GM8_CODPLA = GCM.GCM_CODPLA "
		 cQuery += " LEFT JOIN "+RetSqlName("GFV") + " GFV ON GFV.GFV_FILIAL = '" + xFilial("GFV") + "' AND GFV.D_E_L_E_T_ <> '*' AND GM8.GM8_SQCATP = GFV.GFV_ITEPLA AND GM8.GM8_CODPLA = GFV.GFV_CODPLA "
		 cQuery += " LEFT JOIN "+RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GM8.GM8_CODPRO = GA7.GA7_CODPRO "
		 cQuery += " LEFT JOIN "+RetSqlName("SX5") + " SX5 ON SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND SX5.D_E_L_E_T_ <> '*'  AND SX5.X5_TABELA = 'ZS'  "

	     If GM8->( FieldPos("GM8_EVENTO") ) > 0
			 cQuery += " AND SX5.X5_CHAVE = GM8.GM8_EVENTO "
		 EndIf

		 cQuery += " WHERE "
	 	 cQuery += "NOT EXISTS (SELECT GM4.GM4_CODDIS FROM " + RetSqlName("GM4") + " GM4 WHERE GM4.GM4_FILIAL = '" + xFilial("GM4") + "' AND GM4.D_E_L_E_T_ <> '*' AND GM4.GM4_CODDIS = GM8.GM8_CODDIS AND GM4.GM4_CODPLA = '" + M->GM8_CODPLA + "') AND "
	  	 cQuery += "NOT EXISTS (SELECT GM0.GM0_CODLOC FROM " + RetSqlName("GM0") + " GM0 WHERE GM0.GM0_FILIAL = '" + xFilial("GM2") + "' AND GM0.D_E_L_E_T_ <> '*' AND GM0.GM0_CODLOC = GM8.GM8_CODLOC AND GM0.GM0_CODPLA = '" + M->GM8_CODPLA + "') AND "
		 If lRegAtu
			/*(#ALTERADO PONTO DE ENTRADA#)
			If ExistBlock("HSM54BRW")
				cQuery += ExecBlock("HSM54BRW", .F., .F., {2, nOpc, lRegAtu})
			*/
			cQuery += HSM54BRW(2, nOpc,, lRegAtu)
			/*(#ALTERADO PONTO DE ENTRADA#)
			Else
				cQuery += "GM8.GM8_FILIAL = '"+cFilAtu+"' AND "
				cQuery += "GM8.GM8_FILAGE = '"+cFilAgeAtu+"' AND "
				cQuery += "GM8.GM8_CODCRM = '"+cCrmAtu+"' AND "
				cQuery += "GM8.GM8_DATAGE = '"+cDatAgeAtu+"' AND "
				cQuery += "GM8.GM8_HORAGE = '"+cHorAgeAtu+"' AND "
				cQuery += "GM8.GM8_STATUS = '"+cStatAtu+"' "
			EndIf
			*/
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
		 EndIf
		 cQuery    += "AND GM8.D_E_L_E_T_ <> '*' "
   cQuery    += " ORDER BY "+SqlOrder(GM8->(IndexKey()))
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
				If (nOpc==3 .Or. nOpc==4 .Or. nOpc==5)
					nLastFld  := nPosAge
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ aAgenda[1,x,1] = Data da Ocupacao						     ³
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

			  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena o ultimo registro do agendamento, quando a opcao for³
				//³ igual a: Cancelar, Transferir ou Alterar.                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nOpc==3 .Or. nOpc==4 .Or. nOpc==5)
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
			aAgenda[nPosAge,1,nIteAge,5] := If(Empty(aAgenda[nPosAge,1,nIteAge,5]) .And. (cAliasGm8)->GM8_STATUS$"0,8",(cAliasGm8)->GM8_HORAGE,aAgenda[nPosAge,1,nIteAge,5])

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
			aColsAux := {}
			#IfDEF TOP
  			aEval(aHeaderGM8, {|x, y| aAdd(aColsAux, &(FieldName(FieldPos(aHeaderGM8[y,2]))))})
			#ELSE
		   aEval(aHeaderGM8, {|x, y| Aadd(aColsAux, IIf(aHeaderGM8[y,10] <> "V", &(FieldName(FieldPos(aHeaderGM8[y,2]))), CriaVar(AllTrim(aHeaderGM8[y,2]), .T.,, .F.)))})
			#ENDIF
		 Aadd(aColsAux,.F.)
		 aColsAux[nStatus]:= HSPM54SitAge()

			Aadd(aAgenda[nPosAge,2,Len(aAgenda[nPosAge,2])],aClone(aColsAux))

  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena o ultimo registro do agendamento, quando a opcao for³
			//³ igual a: Cancelar, Transferir ou Alterar.                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nOpc==3 .Or. nOpc==4 .Or. nOpc==5)
				nLastHour := Len(aAgenda[nPosAge,2,Len(aAgenda[nPosAge,2])])
			EndIf

			If nPosAge > 0
   	//Porcentagem da Quantidade Livre
    aAgenda[nPosAge,1,nIteAge,4] := Round((aAgenda[nPosAge,1,nIteAge,3]/aAgenda[nPosAge,1,nIteAge,2])*100,2)

				//Porcentagem da Quantidade Ocupada
				aAgenda[nPosAge,1,nIteAge,7] := Round((aAgenda[nPosAge,1,nIteAge,6]/aAgenda[nPosAge,1,nIteAge,2])*100,2)
			EndIf
			/*(#ALTERADO PONTO DE ENTRADA#)
			If ExistBlock("HSM54BRW")
				aM54Brw := ExecBlock("HSM54BRW", .F., .F., {3, nPosAge, aAgenda[nPosAge][1][nIteAge], nOpc, lRegAtu})
				If ValType(aM54Brw) == "A"
					aAgenda[nPosAge][1][nIteAge] := aClone(aM54Brw)
				EndIf
			EndIf*/
			aM54Brw := HSM54BRW(3, nPosAge, aAgenda[nPosAge][1][nIteAge], nOpc, lRegAtu)
			If ValType(aM54Brw) == "A"
				aAgenda[nPosAge][1][nIteAge] := aClone(aM54Brw)
			EndIf
		EndIf

		DbSkip()
	EndDo
EndIf

// Posiciona no folder principal ou no folder de Encaixe se for um encaixe//
If cPriHor == "  :  " .and. lacssEnc
	oFolder:nOption := 2
	nFldAtu := 2
Else
	oFolder:nOption := 1
	nFldAtu := 1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a Visualizacao das Ocupacoes e Agendamentos         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval(aAgenda,{|x,y|If(Len(x[2])==0,(Aadd(x[1],{Ctod(""),0,0,0," ",0,0,0,0}),Aadd(x[2],aClone(aColsGM8))),NIL)})
Aeval(aOBJETOS,{|x,y|aOBJETOS[y,1]:SetArray(aAgenda[y,1])})

Aeval(aOBJETOS[nFldAtu],{|x|x:nAt:=1})

If !Empty(cPriDia) .And. (nPosDia := aScan(aAgenda[1][2], {| aVet1 | aScan(aVet1, {| aVet2 | aVet2[2] == cPriDia}) > 0})) > 0
	aOBJETOS[nFldAtu,1]:nAt := nPosDia
EndIf

Aeval(aOBJETOS,{|x|x[1]:bLine := {|| {aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,1],;
aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,2],;
aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,3],;
aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,4],;
aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,5],;
aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,6],;
aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,7],;
aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,8],;
aAgenda[nFldAtu,1,aOBJETOS[nFldAtu,1]:nAt,9]}}})

Aeval(aOBJETOS,{|x|x[1]:Refresh()})
Aeval(aOBJETOS,{|x|x[2]:Refresh()})

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
±±³Uso	     ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29SavAge(nFldAtu, nFldAnt, nDiaAtu, nDiaAnt)

If (nFldAnt <> Nil) .And. (nFldAnt <= Len(aAgenda))
	aAgenda[nFldAnt][2][nDiaAnt]	:= aClone(aObjetos[nFldAnt][2]:aCols) //Salva as Marcacoes na Agenda
EndIf

If (nFldAtu <> Nil) .And. nFldAtu <= Len(aObjetos)

	aObjetos[nFldAtu][1]:nAt := nDiaAtu
	aObjetos[nFldAtu][1]:Refresh() //Atualiza as Ocupacoes

	aObjetos[nFldAtu][2]:aCols       := aClone(aAgenda[nFldAtu][2][nDiaAtu]) //Recupera as Marcacoes na Agenda
	aObjetos[nFldAtu][2]:nAt         := 1
	aObjetos[nFldAtu][2]:oBrowse:nAt := 1
	aObjetos[nFldAtu][2]:oBrowse:Refresh()

	nDiaAgeAnt := aObjetos[nFldAtu][1]:nAt //Atualiza o Dia Anterior Selecionado no Agendamento

EndIf

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSPM54SitAge³ Autor ³Paulo Emidio de Barros ³Data³06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Devolve a Legenda da Situacao da Marcacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM54SitAge()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPC1 = Cor de acordo com a Situacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM54SitAge()
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

ElseIf (cAliasGm8)->GM8_STATUS == "7" //Em conferência
	cRetorno := "BR_VIOLETA"
ElseIf (cAliasGm8)->GM8_STATUS == "8" //Transferido
	cRetorno := "BR_BRANCO"
EndIf

Return(cRetorno)

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
±±³			       ³ EXPO1 = Objeto do Folder                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29Marca(cEvento,oFolder,lEncaixe)
Local nPosDia := 0, nPosHor := 0, cIntSal := 0
Local cSQL := ""
Local aAreaOld := GetArea()
Local nPosCol := 0
Local lPromo 	:= GETNEWPAR("MV_PROSAUD",.F.)
Local lCriEnc	:=.F.
Default lEncaixe := .F.
lCriEnc:=.F. //Variavel para Limpar a Grid da marcação de Horario caso der Critica de Permissão

If cEvento == "1" //Primeiro Horario Disponivel no Dia
	If oFolder:nOption == 2 //Encaixes
		nPosHor := Ascan(aOBJETOS[nFldAtu,2]:aCols,{|x|x[nHorAge]==cPriHor .Or. Empty(x[nHorAge])}) //Localiza o primeiro encaixe disponivel no dia
	Else
		nPosHor := Ascan(aOBJETOS[nFldAtu,2]:aCols,{|x|x[nHorAge]==cPriHor}) //Localiza o primeiro horario disponivel no dia
	EndIf
ElseIf cEvento == "2" //Escolha do Horario aleatoriamente
	nPosCol := aOBJETOS[nFldAtu,2]:oBrowse:nColPos
	nPosHor := aOBJETOS[nFldAtu,2]:oBrowse:nAt
EndIf

// Verifica se já tem um horário cadastrado (encaixe)
If oFolder:nOption == 2 .And. nPosHor != 0 .And. !(Posicione("GM8", 8, xFilial("GM8")+M->GM8_CODCRM+DTOS(aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda])+M->GM8_HORAGE, "GM8_STATUS") $ "0/8 ") //Encaixes em horário já cadastrado
	HS_MsgInf(STR0131+Alltrim(M->GM8_NOMCRM)+" ("+DTOC(aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda])+"-"+M->GM8_HORAGE+")",STR0077,STR0102)  //"Já existe agenda para o médico: "###"Atencao"###"Marca o Horario na Agenda"
	Return (.F.)
Endif

If nPosHor <> 0
	if nPosCol == nStatus
		HSM54LEGGM8()
		Return(.T.)
	endif

	If !Empty(aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda]) .And. If(oFolder:nOption==2,.T.,!Empty(aOBJETOS[nFldAtu,2]:aCols[nPosHor,nHorAge]))
		if !Empty(M->GM8_CODSAL)
			cIntSal := HS_IniPadr("GF3", 1, M->GM8_CODSAL, "GF3_INTERV",, .F.)
			aRetCalc := HS_CalcDat(aOBJETOS[nFldAtu, 2]:aCols[nPosHor, nAgenda], aOBJETOS[nFldAtu,2]:aCols[nPosHor, nHorAge], "-", cIntSal)
			dDatIni  := aRetCalc[1]
			cHorIni  := aRetCalc[2]

			aRetCalc := HS_CalcDat(aOBJETOS[nFldAtu, 2]:aCols[nPosHor, nAgenda], aOBJETOS[nFldAtu,2]:aCols[nPosHor, nHorAge], "+", cIntSal)
			dDatFin  := aRetCalc[1]
			cHorFin  := aRetCalc[2]

			cSql := "SELECT GM8_REGGER, GM8_NOMPAC, GM8_CODCRM "
			cSql += "FROM "+ RetSQLName("GM8") +" GM8 "
			cSql += "WHERE GM8.GM8_DATAGE || GM8.GM8_HORAGE >= '" + DTOS(dDatIni) + cHorIni + "' "
			cSql +=   "AND GM8.GM8_DATAGE || GM8.GM8_HORAGE <= '" + DTOS(dDatFin) + cHorFin + "' "
			cSql += "AND GM8.GM8_CODSAL = '" + M->GM8_CODSAL + "' "
			cSql += "AND GM8.D_E_L_E_T_ <> '*' "
			cSql += "AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' "

			cSql := ChangeQuery(cSql)

			DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPGM8", .F., .F.)

			DbSelectArea("TMPGM8")

			If !TMPGM8->(Eof())
				HS_MsgInf(OemToAnsi(STR0092+chr(13)+chr(10)+"Paciente: "+TMPGM8->GM8_REGGER+"-"+TMPGM8->GM8_NOMPAC+chr(13)+chr(10)+STR0002+TMPGM8->GM8_CODCRM),STR0077,STR0102)  //"O horário selecionado já está em uso "###"Atencao"###"Marca o Horario na Agenda" //"Cód. Profissional "
				DbCloseArea()
				RestArea(aAreaOld)
				Return(.F.)
			EndIf
			DbCloseArea()
			RestArea(aAreaOld)
		EndIf
		aOBJETOS[nFldAtu,2]:oBrowse:nAt := nPosHor
		aOBJETOS[nFldAtu,2]:oBrowse:Refresh()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Marca a Consulta em Horarios Livres                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aOBJETOS[nFldAtu,2]:aCols[nPosHor,nStatus] $ "BR_CINZA/BR_BRANCO"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a Marcacao foi efetuada em uma data retroativa   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda] < dDataBase
				HS_MsgInf(OemToAnsi(STR0054),STR0077,STR0102) //"Não será possível selecionar o Horário em uma Data Retroativa."###"Atencao"###"Marca o Horario na Agenda"

			ElseIf (aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda] == dDataBase) .And. (IIf(oFolder:nOption == 2, .F., aOBJETOS[nFldAtu,2]:aCols[nPosHor,nHorAge] < Time()))
				HS_MsgInf(OemToAnsi(STR0055),STR0077,STR0102)  //"Não será possível selecionar um Horário retroativo no mesmo dia."###"Atencao"###"Marca o Horario na Agenda"

			ElseIf !( Posicione("GM8", 1, xFilial("GM8") + aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodAge], "GM8_STATUS") $ "0,8" )
				HS_MsgInf(OemToAnsi(STR0092),STR0077,STR0102)  //"O horário selecionado está em uso por outro usuário"###"Atencao"###"Marca o Horario na Agenda"

			ElseIf oFolder:nOption == 1 .And. !Empty( Posicione("GM8",4, xFilial("GM8")+M->GM8_FILAGE+aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodCRM]+DTOS(aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda])+aOBJETOS[nFldAtu,2]:aCols[nPosHor,nHorAge]+"1","GM8_STATUS") ) .And. !( GM8->GM8_STATUS == "8" )
				HS_MsgInf(OemToAnsi(STR0092),STR0077,STR0102)  //"O horário selecionado está em uso por outro usuário"###"Atencao"###"Marca o Horario na Agenda"

			ElseIf !EMPTY(M->GM8_REGGER) .And. !FS_VldItv(aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda], aOBJETOS[nFldAtu,2]:aCols[nPosHor,nHorAge])
				HS_MsgInf(STR0116, STR0077, STR0102) //"Não será possivel selecionar o horário. Existe agendamento desse paciente no intervalo cadastrado no Convenio"###"Atenção"###"Marca o Horario na Agenda"

			ElseIf !FS_LByName("M29GM8"+aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodAge]) //Verifica se o horario escolhido ja nao esta sendo utilizado por outro usuario
				HS_MsgInf(OemToAnsi(STR0092),STR0077,STR0102)  //"O horário selecionado está em uso por outro usuário"###"Atencao"###"Marca o Horario na Agenda"

				
			/* (#ALTERADO PONTO DE ENTRADA#)
			ElseIf IIf(ExistBlock("HSM54VLD"), ExecBlock("HSM54VLD", .F., .F.), .T.)
			*/
			elseif Hsm54Vld(oGetGEB)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe alguma marcacao efetuada anteriormente que³
				//³ nao foi confirmada, se a mesma existir sera excluida do aCols³
				//³ e do vetor aAgenda.                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nLastFld > 0)  .And. (nLastDay > 0) .And. (nLastHour > 0)

					//Verifica os dados gravados no aAgenda
					If aAgenda[nLastFld,2,nLastDay,nLastHour,nStatus] == "BR_LARANJA" //Status de Agendamento Marcado e Nao-Confirmado

						//Verifica se o Agendamento foi marcado como Encaixe
						If nLastFld == 2
							aAgenda[nLastFld,2,nLastDay,nLastHour,nHorAge] := CriaVar("GM8_HORAGE",.T.,,.F.)
						EndIf

						aAgenda[nLastFld,2,nLastDay,nLastHour,nStatus] := "BR_CINZA"
						aAgenda[nLastFld,2,nLastDay,nLastHour,nRegGer] := CriaVar("GM8_REGGER",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nMatric] := CriaVar("GM8_MATRIC",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nNomPac] := CriaVar("GM8_NOMPAC",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nCodPla] := CriaVar("GM8_CODPLA",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nDesPla] := CriaVar("GM8_DESPLA",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nSqCatP] := CriaVar("GM8_SQCATP",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nDsCatP] := CriaVar("GM8_DSCATP",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nCodPro] := CriaVar("GM8_CODPRO",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nDesPro] := CriaVar("GM8_DESPRO",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nCodSal] := CriaVar("GM8_CODSAL",.T.,,.F.)
						aAgenda[nLastFld,2,nLastDay,nLastHour,nNomSal] := CriaVar("GM8_NOMSAL",.T.,,.F.)

					EndIf

					//Verifica os dados gravados no aCols
					If (nLastFld == nFldAtu) .And. (nLastDay == aOBJETOS[nFldAtu,1]:nAt)

						If aOBJETOS[nLastFld,2]:aCols[nLastHour,nStatus] == "BR_LARANJA" //Status de Agendamento Marcado e Nao-Confirmado

							//Verifica se o Agendamento foi marcado como Encaixe
							If nLastFld == 2
								aOBJETOS[nLastFld,2]:aCols[nLastHour,nHorAge] := aAgenda[nLastFld,2,nLastDay,nLastHour,nHorAge]
							EndIf

							aOBJETOS[nLastFld,2]:aCols[nLastHour,nStatus] := aAgenda[nLastFld,2,nLastDay,nLastHour,nStatus]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nRegGer] := aAgenda[nLastFld,2,nLastDay,nLastHour,nRegGer]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nMatric] := aAgenda[nLastFld,2,nLastDay,nLastHour,nMatric]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nNomPac] := aAgenda[nLastFld,2,nLastDay,nLastHour,nNomPac]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nCodPla] := aAgenda[nLastFld,2,nLastDay,nLastHour,nCodPla]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nDesPla] := aAgenda[nLastFld,2,nLastDay,nLastHour,nDesPla]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nSqCatP] := aAgenda[nLastFld,2,nLastDay,nLastHour,nSqCatP]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nDsCatP] := aAgenda[nLastFld,2,nLastDay,nLastHour,nDsCatP]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nCodPro] := aAgenda[nLastFld,2,nLastDay,nLastHour,nCodPro]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nDesPro] := aAgenda[nLastFld,2,nLastDay,nLastHour,nDesPro]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nCodSal] := aAgenda[nLastFld,2,nLastDay,nLastHour,nCodSal]
							aOBJETOS[nLastFld,2]:aCols[nLastHour,nNomSal] := aAgenda[nLastFld,2,nLastDay,nLastHour,nNomSal]

						EndIf
					EndIf

					FS_UByName("M29GM8"+aAgenda[nLastFld,2,nLastDay,nLastHour,nCodAge])
					/*(#ALTERADO PONTO DE ENTRADA#)
					If ExistBlock("HSM54DES")
						ExecBlock("HSM54DES", .F., .F., {aObjetos, nLastHour, nStatus, nLastFld, nLastDay})
					EndIf
					*/
					HSM54DES(aObjetos, nLastHour, nStatus, nLastFld, nLastDay)

				EndIf
				//

				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nStatus] := "BR_LARANJA"  //Status de Agendamento Marcado e Nao-Confirmado
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nRegGer] := M->GM8_REGGER //Prontuario
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nMatric] := M->GM8_MATRIC //Matricula do plano
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nNomPac] := M->GM8_NOMPAC //Nome do Paciente
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodPla] := M->GM8_CODPLA //Codigo do Plano
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDesPla] := M->GM8_DESPLA //Descricao do Plano
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nSqCatP] := M->GM8_SQCATP // Sequencial da Categoria do Plano
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDsCatP] := M->GM8_DSCATP // Descricao da Categoria do Plano
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodPro] := M->GM8_CODPRO //Codigo do procedimento
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDesPro] := M->GM8_DESPRO //Descricao do Procedimento
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodSal] := M->GM8_CODSAL //Codigo da sala
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nNomSal] := M->GM8_NOMSAL //Descricao do sala
				aOBJETOS[nFldAtu,2]:oBrowse:Refresh()

				nLastFld  := nFldAtu                  //Ultimo Folder
				nLastDay  := aOBJETOS[nFldAtu,1]:nAt  //Ultimo Dia Agendado
				nLastHour := nPosHor                  //Ultima Hora

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja um encaixe no Agendamento, forca o foco para que o ³
				//³ usuario informe a hora do encaixe.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEvento == "1") .And. (nFldAtu == 2)
					aOBJETOS[nFldAtu,2]:oBrowse:SetFocus()
				EndIf
				/*(#ALTERADO PONTO DE ENTRADA#)
				If ExistBlock("HSM54MAR")
					ExecBlock("HSM54MAR", .F., .F., {cEvento, aObjetos, nLastHour, nStatus, nLastFld, nLastDay})
				EndIf
				*/
				IF  lPromo
					lCriEnc:=.F.
					
					IF(aOBJETOS[nFldAtu,2]:aCols[nPosHor,nPromo]) =='1' .And. !lConsProm
						HS_MsgInf(OemToAnsi(STR0226),STR0077,STR0102)  //"O horário selecionado está Reservado para Promoção a Saúde"###"Atencao"###"Marca o Horario na Agenda"
						lCriEnc:=.T.						
					Elseif !EMPTY(aOBJETOS[nFldAtu,2]:aCols[nPosHor,nEvento]) .And. !lConsEve
						HS_MsgInf(OemToAnsi(STR0227),STR0077,STR0102)  //"O horário selecionado está Reservado para Eventos"###"Atencao"###"Marca o Horario na Agenda"
						lCriEnc:=.T.
					Endif 
					
					If lCriEnc
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nStatus]:= "BR_CINZA"				
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nRegGer]:= CriaVar("GM8_REGGER",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nMatric]:= CriaVar("GM8_MATRIC",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nNomPac]:= CriaVar("GM8_NOMPAC",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodPla]:= CriaVar("GM8_CODPLA",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDesPla]:= CriaVar("GM8_DESPLA",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nSqCatP]:= CriaVar("GM8_SQCATP",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDsCatP]:= CriaVar("GM8_DSCATP",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodPro]:= CriaVar("GM8_CODPRO",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDesPro]:= CriaVar("GM8_DESPRO",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodSal]:= CriaVar("GM8_CODSAL",.T.,,.F.)
						aOBJETOS[nFldAtu,2]:aCols[nPosHor,nNomSal]:= CriaVar("GM8_NOMSAL",.T.,,.F.)					
					Endif	
				Endif	
				HSM54MAR(cEvento, aObjetos, nLastHour, nStatus, nLastFld, nLastDay)
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desmarca a Consulta Agendada e Nao-Confirmada                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf aOBJETOS[nFldAtu,2]:aCols[nPosHor,nStatus] == "BR_LARANJA" .And. !lEncaixe //Agendamento Marcado e Nao-Confirmado e não tenha sido digitado a data no encaixe
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nStatus] := "BR_CINZA"

			//Verifica se o Agendamento foi marcado como Encaixe
			If nFldAtu == 2
				aOBJETOS[nFldAtu,2]:aCols[nPosHor,nHorAge] := CriaVar("GM8_HORAGE",.T.,,.F.)
			EndIf

			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nRegGer] := CriaVar("GM8_REGGER",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nMatric] := CriaVar("GM8_MATRIC",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nNomPac] := CriaVar("GM8_NOMPAC",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodPla] := CriaVar("GM8_CODPLA",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDesPla] := CriaVar("GM8_DESPLA",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nSqCatP] := CriaVar("GM8_SQCATP",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDsCatP] := CriaVar("GM8_DSCATP",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodPro] := CriaVar("GM8_CODPRO",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nDesPro] := CriaVar("GM8_DESPRO",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodSal] := CriaVar("GM8_CODSAL",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:aCols[nPosHor,nNomSal] := CriaVar("GM8_NOMSAL",.T.,,.F.)
			aOBJETOS[nFldAtu,2]:oBrowse:Refresh()

			/*(#ALTERADO PONTO DE ENTRADA#)
			If ExistBlock("HSM54DES")
				ExecBlock("HSM54DES", .F., .F., {aObjetos, nLastHour, nStatus, nLastFld, nLastDay})
			EndIf
			*/
			HSM54DES(aObjetos, nLastHour, nStatus, nLastFld, nLastDay)

			FS_UByName("M29GM8"+aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodAge])

			nLastFld  := 0 //Ultimo Folder
			nLastDay  := 0 //Ultimo Dia Agendado
			nLastHour := 0 //Ultima Hora

			
		EndIf
	EndIf
	
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  	 ³HSPM54Grv ³ Autor ³Paulo Emidio de Barros ³ Data ³10/12/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao do Agendamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM54Grv(EXPN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM54Grv(nOpc,nGO4_CODPRO,nGO4_NUMORC,nGO4_ITEORC,nGebItem,nGebQtdMat,nGebNumOrc,NGEBITEORC)
Local cPesquisa := " "
Local nOrder    := 0
Local cNovAge   := " "
Local lBloqueia := .F.
Local nCont     := 0
Local lOriPac   := Hs_ExisDic({{"C","GM8_ORIPAC"}},.F.)
Local lPromo 	:= GETNEWPAR("MV_PROSAUD",.F.)
Local cProCodage:= ""
Local cproProgra:= ""
Local cProRegger:= ""

If (nLastFld > 0) .And. (nLastDay > 0) .And. (nLastHour > 0)

	//Define a chave de pesquisa
	If nOpc == 2 .Or. nOpc == 4 //Agendar ou Transferir
		cPesquisa := aAgenda[nLastFld,2,nLastDay,nLastHour,nCodAge]
		nOrder := 1
	Else//Cancelar
		cPesquisa := M->GM8_CODAGE  //busca pela chave PRIMARIA e nao pelo horario pois pode cadastrar encaixes com o mesmo horarios
		nOrder := 1
	EndIf

	DbSelectArea("GM8")
	DbSetOrder(nOrder)
	If DbSeek(xFilial("GM8") + cPesquisa)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se a opcao for igual a Cancelamento ou Transferencia, o moti-³
		//³ vo sera verificado para definicao do bloqueio do Horario.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nOpc == 3 .Or. nOpc == 4)
			DbSelectArea("GM7")
			DbSetOrder(1) // GM7_FILIAL + GM7_CODCAN
			If DbSeek(xFilial("GM7")+M->GM8_MOTIVO)
				lBloqueia := If(GM7->GM7_IDEBLO=="0",.F.,.T.)
			EndIf
		EndIf

		If ! Empty( GM8->GM8_REGGER ) .and. GM8->GM8_REGGER <> M->GM8_REGGER .AND. !( GM8->GM8_STATUS == "8" )
			HS_MsgInf(STR0072, STR0077, STR0103) //"Este horário já está agendado."###"Atenção"###"Atualizacao do Agendamento"
			Return(.f.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Registro do Agendamento/Encaixe, caso a opcao seja:  ³
		//³ Agendar ou Transferir.										                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPromo
			If Empty(M->GM8_DESPRO)
				MsgInfo("Este Procedimento não possui vinculo com a Tabela padrão do Plano de Saude.")
				Return .F.
			EndIf
		EndIf
		If aAgenda[nLastFld,2,nLastDay,nLastHour,nStatus] == "BR_LARANJA" .And. (nOpc==2 .Or. nOpc==4) //Status de Agendamento Marcado e Nao-Confirmado

			RecLock("GM8",.F.)
			If GM8->GM8_TIPAGE == "1" //Encaixe
				GM8->GM8_HORAGE := aAgenda[nLastFld,2,nLastDay,nLastHour,nHorAge]
			EndIf
			GM8->GM8_REGGER := M->GM8_REGGER
			GM8->GM8_MATRIC := M->GM8_MATRIC
			GM8->GM8_NOMPAC := M->GM8_NOMPAC
			GM8->GM8_TELPAC := M->GM8_TELPAC
			GM8->GM8_CODPLA := M->GM8_CODPLA
			GM8->GM8_SQCATP := M->GM8_SQCATP
			GM8->GM8_CODCON := cGCM_CODCON    //GRAVA O CODIGO DO CONVENIO
			GM8->GM8_CODPRO := M->GM8_CODPRO
			GM8->GM8_OBSERV := M->GM8_OBSERV
			GM8->GM8_STATUS := "1" //Status para definir o Agendamento
			GM8->GM8_DATCAD := dDataBase
			GM8->GM8_HORCAD := SubStr(Time(),1,5)
			GM8->GM8_CODUSU := SubStr(cUsuario, 7, 15)
			GM8->GM8_LOCAGE := cGcsCodLoc
			GM8->GM8_LOGARQ := HS_LogArq()
			GM8->GM8_CODSAL := M->GM8_CODSAL
			GM8->GM8_AGDPRC := GM8->GM8_CODAGE
			GM8->GM8_ORICAN := M->GM8_ORICAN
			GM8->GM8_MOTIVO := M->GM8_MOTIVO
			GM8->GM8_NUMORC := M->GM8_NUMORC
			GM8->GM8_ITEORC := M->GM8_ITEORC
			If GM8->( FieldPos('GM8_PROMO') ) > 0 .And. GM8->( FieldPos('GM8_PROGRA') ) > 0
				GM8->GM8_PROMO  := M->GM8_PROMO
				GM8->GM8_PROGRA  := M->GM8_PROGRA
			EndIf
			if lOriPac
				GM8->GM8_ORIPAC := M->GM8_ORIPAC
			endif


			For nCont:= 1 To Len(aCpoUsu)
				If Type("M->" + aCpoUsu[nCont]) != "U"
					GM8->&(aCpoUsu[nCont]) := M->&(aCpoUsu[nCont])
				EndIf
			Next

			MsUnLock()

			FS_UByName("M29GM8"+GM8->GM8_CODAGE)
	        //PE CONFIRMAÇÃO DO AGENDAMENTO
			If ExistBlock("HSM54CNF")
				ExecBlock("HSM54CNF", .F., .F., {cPesquisa})
			EndIf

		EndIf

	 	HS_GrvGo4(GM8->GM8_CODAGE, nOpc,nGO4_CODPRO,nGO4_NUMORC,nGO4_ITEORC)
	 	HS_GrvGeb(GM8->GM8_CODAGE, nOpc,nGebItem,nGebQtdMat,nGebNumOrc,nGebIteOrc)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Disponibiliza ou Bloqueia o Horario Transferido e grava o His³
		//³ torico da Transferencia.				                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nOpc==4)

			cNovAge		:= GM8->GM8_CODAGE						//Salva o Codigo do Novo Agendamento
			cFilAge		:= GM8->GM8_FILIAL 						//Salva Filial do Antigo Agendamento
			cPesquisa	:= M->( GM8_FILIAL + GM8_CODAGE )		//Posiciona no horario antigo da transferencia

			DbSelectArea("GM8")
			GM8->( DbSetOrder(1) ) //GM8_FILIAL + GM8_CODAGE
			If GM8->( DbSeek( cPesquisa ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Checar se existe campo para release 4 (transferir/alterar)    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If GMA->(FieldPos("GMA_SEQREG")) > 0
					M->GMA_SEQREG := HS_VSxeNum( "GMA" , "M->GMA_SEQREG" , 4 )
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
				GMA->GMA_NOVAGE := cNovAge
				GMA->GMA_DESCFM := GM8->GM8_DESCFM
				GMA->GMA_DATCFM := GM8->GM8_DATCFM
				GMA->GMA_HORCFM := GM8->GM8_HORCFM
				GMA->GMA_USUCFM := GM8->GM8_USUCFM
				GMA->GMA_LOGARQ := HS_LOGARQ()
				GMA->GMA_LOCAGE := GM8->GM8_LOCAGE
				GMA->GMA_CODSAL := GM8->GM8_CODSAL
				if lOriPac
					GMA->GMA_ORIPAC := GM8->GM8_ORIPAC
				endif


				If GMA->(FieldPos("GMA_SEQREG")) > 0                   //Checar se existe campo para release 4 (transferir/alterar)
					GMA->GMA_SEQREG := M->GMA_SEQREG
				EndIf
				MsUnLock()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Disponibiliza o Horario ou Encaixe para novas marcacoes ou   ³
				//³ bloqueia os mesmos.                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("GM8",.F.)

				If GM8->GM8_EXCTRA

					DbDelete()

				Else

					For nCont:= 1 To Len(aCpoUsu)

						If Type("M->" + aCpoUsu[nCont]) != "U"
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
					If lBloqueia

   				   		If lPromo .And. GM8->( FieldPos('GM8_PROMO') ) > 0 .And. GM8->( FieldPos('GM8_PROGRA') ) > 0 
		   			   		cProCodage:= GM8->GM8_CODAGE
					   		cproProgra:= GM8->GM8_PROGRA
		   			   		cProRegger:= GM8->GM8_REGGER
   				   		Endif
						GM8->GM8_STATUS := "2"				//Bloqueado
						GM8->GM8_ORICAN := M->GM8_ORICAN	//Grava o Tipo de Cancelamento somente no Bloqueio
						GM8->GM8_REGGER := " "
						GM8->GM8_MATRIC := " "
						GM8->GM8_NOMPAC := " "
						GM8->GM8_TELPAC := " "
						GM8->GM8_CODPLA := " "
						GM8->GM8_SQCATP := " "
						GM8->GM8_CODCON := " "  //LIMPA O CODIGO DO CONVENIO
						GM8->GM8_CODPRO := " "
						GM8->GM8_OBSERV := " "
						GM8->GM8_CODUSU := " "
						GM8->GM8_LOCAGE := " "
						if lOriPac
							GM8->GM8_ORIPAC := " "
						endif

					If lPromo .And. GM8->( FieldPos('GM8_PROMO') ) > 0 .And. GM8->( FieldPos('GM8_PROGRA') ) > 0 
						GM8->GM8_PROMO	:=""
						GM8->GM8_PROGRA	:=""
					EndIf

					Else
						If GM8->GM8_TIPAGE == "1" //Encaixe
							GM8->GM8_HORAGE := "  :  "
						EndIf
						/*
						GM8->GM8_REGGER := " "
						GM8->GM8_MATRIC := " "
						GM8->GM8_NOMPAC := " "
						GM8->GM8_TELPAC := " "
						GM8->GM8_CODPLA := " "
						GM8->GM8_CODCON := " "  //lIMPA O CODIGO DO CONVENIO
						GM8->GM8_CODPRO := " "
						GM8->GM8_OBSERV := " "
						GM8->GM8_CODUSU := " "
						*/
						if GM8->GM8_STATUS == "4"
							GM8->GM8_STATUS := "2"
						else
							GM8->GM8_STATUS := "8"
						endif
						/*
						GM8->GM8_DATCAD := Ctod(" ")
						GM8->GM8_HORCAD := " "
						GM8->GM8_DESCFM := " "
						GM8->GM8_DATCFM := Ctod(" ")
						GM8->GM8_HORCFM := " "
						GM8->GM8_USUCFM := " "
						GM8->GM8_LOCAGE := " "
						*/
						if lOriPac
							GM8->GM8_ORIPAC := " "
						endif


					EndIf
				EndIf
				GM8->GM8_LOGARQ := HS_LogArq()
				MsUnLock()

			EndIf

            // Devo neste final atualizar todos os status de tranferido para o seguinte cenario:
            // Origem com 2 horarios disponiveis utilizados (maior) para destino com 1 horário disponivel utilizado (menor).
			cAgdPrc := GM8->GM8_AGDPRC
			GM8->( DbSetOrder(12) )
			GM8->(DBSeek(M->GM8_FILIAL + cAgdPrc))
			Do While GM8->(!Eof()) .And. GM8->GM8_FILIAL == M->GM8_FILIAL .And. GM8->GM8_AGDPRC == cAgdPrc
				If nOpc<>4 
					RecLock("GM8",.F.)
						GM8->GM8_STATUS := "8"
					MsUnLock()
				EndIf
				dbSkip()	
 			EndDo

			// Posiciona novamente no novo registro do GM8
			cPesquisa	:= cFilAge + cNovAge
			GM8->( DbSetOrder(1) )
			If !EMPTY(cPesquisa)
				GM8->( DbSeek( cPesquisa ) )
            EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Disponibiliza ou Bloqueia o Horario Cancelado e grava o His- ³
		//³ torico do Cancelamento.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aAgenda[nLastFld,2,nLastDay,nLastHour,nStatus] $ "BR_VERMELHO/BR_AZUL/BR_LARANJA" .And. nOpc==3)

			//Cancelamento
			If GM9->(FieldPos("GM9_SEQREG")) > 0                   //Checar se existe campo para release 4  (cancelar)
				M->GM9_SEQREG   := HS_VSxeNum("GM9", "M->GM9_SEQREG", 4)
				ConfirmSX8()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registra Historico de Cancelamento.						     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSelectArea("GM9")
			
			GM9->( DBSetOrder(5) ) //GM9_FILIAL+GM9_CODAGE+ GM9_HORCAD+GM9_REGGER
			
			If !Empty(GM8->GM8_REGGER) .And. !GM9->( DBSeek( xFilial("GM9") + GM8->GM8_CODAGE + GM8_HORCAD + GM8_REGGER) )

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
					
					If lOriPac
					GM9->GM9_ORIPAC := GM8->GM8_ORIPAC
					EndIf
	
	
				If GM9->(FieldPos("GM9_SEQREG")) > 0                   //Checar se existe campo para release 4  (cancelar)
					GM9->GM9_SEQREG := M->GM9_SEQREG
				EndIf
				MsUnLock()
	
				If GM9->(FieldPos("GM9_SEQREG")) > 0
					HS_MsgInf(STR0109 + GM9->GM9_SEQREG, STR0077 ,STR0110) //"Registro Sequencial Nr: "###"Atenção"###"Histórico do Cancelamento"
				Endif
			Endif //Moura

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Disponibiliza o Horario ou Encaixe para novas marcacoes ou   ³
			//³ bloqueia os mesmos.                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("GM8",.F.)
			If lBloqueia
		   		If lPromo .And. GM8->( FieldPos('GM8_PROMO') ) > 0 .And. GM8->( FieldPos('GM8_PROGRA') ) > 0 
			   		cProCodage:= GM8->GM8_CODAGE
			   		cproProgra:= GM8->GM8_PROGRA
		   	   		cProRegger:= GM8->GM8_REGGER
   				Endif
				GM8->GM8_STATUS := "2"           //Bloqueado
				GM8->GM8_ORICAN := M->GM8_ORICAN //Grava o Tipo de Cancelamento somente no Bloqueio
				GM8->GM8_REGGER := " "
				GM8->GM8_MATRIC := " "
				GM8->GM8_NOMPAC := " "
				GM8->GM8_TELPAC := " "
				GM8->GM8_CODPLA := " "
				GM8->GM8_SQCATP := " "
				GM8->GM8_CODCON := " "  //lIMPA O CODIGO DO CONVENIO
				GM8->GM8_CODPRO := " "
				GM8->GM8_OBSERV := " "
				GM8->GM8_CODUSU := " "
				GM8->GM8_LOCAGE := " "
				If lOriPac
					GM8->GM8_ORIPAC := " "
				EndIf

				If GM8->( FieldPos('GM8_PROMO') ) > 0 .And. GM8->( FieldPos('GM8_PROGRA') ) > 0 
					GM8->GM8_PROMO	:=""
					GM8->GM8_PROGRA	:=""
				EndIf

			Else
				If GM8->GM8_TIPAGE == "1" //Encaixe
					GM8->GM8_HORAGE := "  :  "
				EndIf
		   		If lPromo .And. GM8->( FieldPos('GM8_PROMO') ) > 0 .And. GM8->( FieldPos('GM8_PROGRA') ) > 0 
  			   		cProCodage:= GM8->GM8_CODAGE
			   		cproProgra:= GM8->GM8_PROGRA
   			   		cProRegger:= GM8->GM8_REGGER
		   		Endif
				GM8->GM8_REGGER := " "
				GM8->GM8_MATRIC := " "
				GM8->GM8_NOMPAC := " "
				GM8->GM8_TELPAC := " "
				GM8->GM8_CODPLA := " "
				GM8->GM8_CODCON := " "
				GM8->GM8_CODPRO := " "
				GM8->GM8_OBSERV := " "
				If GM8->GM8_STATUS == "4"
					GM8->GM8_STATUS := "2"
				Else
					GM8->GM8_STATUS := "0"
				EndIf
				GM8->GM8_DATCAD := Ctod("")
				GM8->GM8_HORCAD := " "
				GM8->GM8_CODUSU := " "
				GM8->GM8_DESCFM := " "
				GM8->GM8_DATCFM := Ctod("")
				GM8->GM8_HORCFM := " "
				GM8->GM8_USUCFM := " "
				GM8->GM8_LOCAGE := " "
				if lOriPac
					GM8->GM8_ORIPAC := " "
				endif

					If GM8->( FieldPos('GM8_PROMO') ) > 0 .And. GM8->( FieldPos('GM8_PROGRA') ) > 0 
						GM8->GM8_PROMO	:=""
						GM8->GM8_PROGRA	:=""
					EndIf
			EndIf

			For nCont:= 1 To Len(aCpoUsu)
				If Type("M->" + aCpoUsu[nCont]) != "U"
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
			GM8->GM8_LOGARQ := HS_LogArq()
			MsUnLock()

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera os dados permitidos em um Agendamento.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aAgenda[nLastFld,2,nLastDay,nLastHour,nStatus] $ "BR_VERMELHO/BR_LARANJA" .And. nOpc==5)
			RecLock("GM8",.F.)
			GM8->GM8_MATRIC := M->GM8_MATRIC
			GM8->GM8_TELPAC := M->GM8_TELPAC
			GM8->GM8_OBSERV := M->GM8_OBSERV
			GM8->GM8_LOGARQ := HS_LogArq()

			For nCont:= 1 To Len(aCpoUsu)
				If Type("M->" + aCpoUsu[nCont]) != "U"
					GM8->&(aCpoUsu[nCont]) := M->&(aCpoUsu[nCont])
				EndIf
			Next

			MsUnLock()
		EndIf

	EndIf

	If FunName() == "HSPM24AA" //so chama fichas se vier do atendimento
		HS_RelM29() //Imprime as fichas
	EndIf

EndIf

While __lSx8
	ConfirmSx8()
End
If lPromo
	PlsGrvPAg(GM8->GM8_DATAGE,GM8->GM8_HORAGE,IIF(Empty(GM8->GM8_CODAGE),cProCodage,GM8->GM8_CODAGE),IIF(Empty(GM8->GM8_PROGRA),cproProgra,GM8->GM8_PROGRA),nOpc,iif(Empty(GM8->GM8_REGGER),cProReggeR,GM8->GM8_REGGER)) 
	/*dbSelectArea("BOQ")
	dbSetOrder(1)//BOQ_FILIAL, BOQ_ITEM, BOQ_VIDA, BOQ_ELEGIB, BOQ_CODTAB, BOQ_PROCED, BOQ_DATSUG, BOQ_CODAGE
	If dbSeek( xFilial("BOQ") + GM8->GM8_PROGRA )
		RecLock("BOQ",.F.)  
			BOQ->BOQ_STATUS := '2'
		BOQ->( MsUnlock() )
	EndIf*/	
EndIf

FS_UByName("M29GM8"+GM8->GM8_CODAGE)

Return(NIL)

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
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29VerHorEnc(nFolder)
Local lRetorno 	:= .T.
Local nCont     := 0

If nFolder == 2 //verifica se a Hora marcada e encaixe

	For nCont := 1 To Len(aOBJETOS[nFolder,2]:aCols)
		If aOBJETOS[nFolder,2]:aCols[nCont,nStatus] == "BR_LARANJA" //Status de Agendamento Marcado e Nao-Confirmado
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
±±³Fun‡ao    ³ HS_VldM54     ³Autor³Eduardo Alves         ³Data³18/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Executada no Botao Confirma da Marcacao (bOk), Utili³±±
±±³          ³ zada para validar o Modulo de Marcacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_VldM54() 			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldM54(nOpc)
Local lRet 					:= .T.
Local nAgenda 		:= 0
Local nEncaixe 	:= 0
Local lPromo 	:= GETNEWPAR("MV_PROSAUD",.F.)

If nOpc == 2 .Or. nOpc == 4 /* Opcao AGENDAR ou TRANSFERIR */

	/* Valida se foi Marcado algum horario para o Paciente */
	nAgenda 		:= Ascan(aOBJETOS[1,2]:aCols,{|x|AllTrim(x[1])=="BR_LARANJA"})
	nEncaixe 	:= Ascan(aOBJETOS[2,2]:aCols,{|x|AllTrim(x[1])=="BR_LARANJA"})

	If nAgenda = 0 .And. nEncaixe = 0
		HS_MsgInf(STR0112, STR0077, STR0111) // "Não foi selecionado nenhum horário para o paciente, dê um duplo clique sobre o horário desejado antes de confirmar a marcação!"###"Atenção"###"Confirmação da Marcação"
		lRet := .F.
	EndIf
	If lPromo .AND. lRet
		If GM8->( FieldPos('GM8_PROMO') ) > 0
			If M->GM8_PROMO == '0' .AND. !Empty(M->GM8_CODPRO)
				cMatVid :=	PLSRTVID(M->GM8_REGGER)

				dbSelectArea("BOQ")
				dbSetOrder(4)//BOQ_FILIAL, BOQ_VIDA
				If BOQ->(dbSeek(xFilial("BOQ")+cMatVid + "1")) //.And. BOQ->BOQ_STATUS == "1" //0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
					If HS_CountTB("BOQ", "BOQ_VIDA  = '" + cMatVid + "' AND BOQ_STATUS = '1' AND BOQ_PROCED = '" + M->GM8_CODPRO + "' ")  > 0
						HS_MsgInf("Paciente possui planejamento aberto para este procedimento, é necessário agendar através do planejamento!", STR0077, STR0073)  //"Atenção"###"Agendamento Ambulatorial"
						lRet := .F.
					EndIf
				EndIf
			ElseIf M->GM8_PROMO == '1' .AND. !Empty(M->GM8_CODPRO)
				cMatVid :=	PLSRTVID(M->GM8_REGGER)
				DbSelectArea("GA7")
				DbSetOrder(1)
				MsSeek(xFilial("GA7") + M->GM8_CODPRO)
			
				dbSelectArea("BOQ")
				dbSetOrder(3)//BOQ_FILIAL, BOQ_VIDA
				If ValType("M->GM8_PROGRA") <> "C"
					If BOQ->(dbSeek(xFilial("BOQ")+ M->GM8_PROGRA)) 
						If Alltrim(BOQ->BOQ_PROCED) <> Alltrim(GA7->GA7_PROPLS) // Se o procedimento agendado e diferente do selecionado no planejamento nao deixa
							HS_MsgInf("O procedimento agendado esta diferente do selecionado no planejamento!", STR0077, STR0073)  //"Atenção"###"Agendamento Ambulatorial"
							lRet := .F.
						EndIf
					EndIf
				EndIf			
			EndIf
		EndIf
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entra para customizacaoes de validacao da tela de agenda clinica³
//³Retorno .T. ou .F. - Incluído em 02/04/2014                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. ExistBlock("HSM54OK")    
	lRet := ExecBlock("HSM54OK", .F., .F., {nOpc})
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
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29IniTrf(lIniBrw,nOpc)
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
			aTrfHorAge := HSM54BRW(5, GM8->GM8_AGDPRC)
		Else
			FS_AgenFut()
		EndIf
		oBrwTrf:SetArray(aTrfHorAge)
		oBrwTrf:bLine:= {|| {aTrfHorAge[oBrwTrf:nAt, 01], aTrfHorAge[oBrwTrf:nAt, 02], aTrfHorAge[oBrwTrf:nAt, 03], ;
		aTrfHorAge[oBrwTrf:nAt, 04], aTrfHorAge[oBrwTrf:nAt, 05], aTrfHorAge[oBrwTrf:nAt, 06], ;
		aTrfHorAge[oBrwTrf:nAt, 07], aTrfHorAge[oBrwTrf:nAt, 08], aTrfHorAge[oBrwTrf:nAt, 09], ;
		aTrfHorAge[oBrwTrf:nAt, 10], aTrfHorAge[oBrwTrf:nAt, 11], aTrfHorAge[oBrwTrf:nAt, 12]}}
		oBrwTrf:Refresh()
	EndIf
EndIf

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM54MotDes  ³Autor³Paulo Emidio de Barros³Data³06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a Descricao do Motivo do Cancelamento/Transferencia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM54MotDes()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T ou F                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM54MotDes()
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

Function HSPM54OriCan()
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
±±³Uso       ³ HSPAHM54                                                   ³±±
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

If nFldAtu <= Len(aAgenda)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Controla a pintura do Calendario na Agenda                   ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 For nDia := 1 To Day(dFinal) //Ultimo dia do Mes Selecionado

 	dDiaAge := CToD(Stuff(DToC(dFinal), 1, 2, StrZero(nDia, 2)))
 	nPosDia := aScan(aAgenda[nFldAtu][1], {| x | x[1] == dDiaAge})

 	If (nPosDia > 0)

 		If (aAgenda[nFldAtu][1][nPosDia][3] == 0) //Ocupado
 			nCor1 := CLR_HRED
 			nCor2 := CLR_HRED

 		ElseIf (aAgenda[nFldAtu][1][nPosDia][2] > aAgenda[nFldAtu][1][nPosDia][6]) .And.; //Parcial
 			      (aAgenda[nFldAtu][1][nPosDia][6] > 0)
 			nCor1 := CLR_BLUE
 			nCor2 := CLR_BLUE

 		ElseIf (aAgenda[nFldAtu][1][nPosDia][6] == 0) //Livre
 			nCor1 := CLR_GREEN
 			nCor2 := CLR_GREEN

 		EndIf

 	Else
 		nCor1 := CLR_BLACK
 		nCor2 := CLR_WHITE

 	EndIf

 	oCalend:AddRestri(Day(dDiaAge), nCor1, nCor2)

 Next nDia

 //Sincroniza o dia selecionado com o Calendario
 oCalend:dDiaAtu := If(Empty(aAgenda[nFldAtu][1][nDiaAgeAtu][1]), oCalend:dDiaAtu, aAgenda[nFldAtu][1][nDiaAgeAtu][1]) //Dia Atual
 oCalend:Refresh()

 oMeses:nAt := Month(oCalend:dDiaAtu)
 oMeses:Refresh()

EndIf

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
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29MkDia()
Local nPosDia  := 0
Local lRetorno := .T.

If Len(aAgenda) > 0 .And. nFldAtu <= Len(aAgenda) .And. nFldAtu <= Len(aObjetos)

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
±±³Fun‡ao    ³ HSPM54VldHor  ³Autor³Paulo Emidio de Barros³Data³26/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a Hora informada para o Encaixe no Agendamento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM54VldHor()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ T ou F                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM54VldHor()
Local cHora    := &(ReadVar())
Local lRetorno := .T., cAliasOld := Alias()
DbSelectArea("GM6")
DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
DbSeek(xFilial("GM6") + GM8->GM8_CODDIS)

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
ElseIf !Empty(GM6->GM6_HORENC) .And. cHora >= GM6->GM6_HORENC
	HS_MsgInf(STR0125 + " [" + GM6->GM6_HORENC + "]" , STR0077, STR0106) //"O horário não pode ser maior/igual ao horário limite para encaixe"###"Atenção"###"Valida a Hora informada para o Encaixe no Agendamento"
	lRetorno  := .F.
EndIf

DbSelectArea(cAliasOld)
If lRetorno // Somente se for hora valida
	FS_RestMem() // Restaura as variaveis de memória
	&(ReadVar()) = cHora // Recupera a hora digitada
	If oFolder:nOption == 2 .And. !empty(cHora)
		lRetorno := HSPM29Marca("2",oFolder,.T.) // Simula o duplo click
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
±±³	         ³  	   .F. Desliga o Filtro                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54		                                    		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29FilBrw(lSetFilter, lFiltro,cFilM29)
Local oObjMBrw

If lM29ChaExt
	Return(Nil)
EndIf

oObjMBrw := GetObjBrow()

cFilM29 := "GM8_FILIAL = '" + xFilial("GM8") + "' And GM8_DATAGE >= '" + DToS(dDataBase) + "'"

If lFiltro
	cFilM29 += " And GM8_STATUS IN ( '1', '4', '5' , '8' )"
EndIf

If ExistBlock("HSPAFLM54")
	cFilM29 := ExecBlock("HSPAFLM54",.F.,.F.,{cFilM29} )
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
±±³			 ³         .F. Nao aciona o Filtro                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL2 = T ou F                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HSPM29Perg()
Local lRetorno
Local aHelpPor := {}
Local aHelpEsp := {}
Local aHelpIng := {}
Local aVarDef := {{"cGcsArmSet", "GCS->GCS_ARMSET"}, ;
                  {"cGcsArmFar", "GCS->GCS_ARMFAR"}}

Aadd(aHelpPor,STR0059) //'Informe o Setor definido para o '
Aadd(aHelpPor,STR0060) //'Atendimento Ambulatorial, ou consulte '
Aadd(aHelpPor,STR0061) //'os Setores disponiveis via Tecla F3'

Aadd(aHelpEsp,STR0059) //'Informe o Setor definido para o '
Aadd(aHelpEsp,STR0060) //'Atendimento Ambulatorial, ou consulte '
Aadd(aHelpEsp,STR0061) //'os Setores disponiveis via Tecla F3'

Aadd(aHelpIng,STR0059) //'Informe o Setor definido para o '
Aadd(aHelpIng,STR0060) //'Atendimento Ambulatorial, ou consulte '
Aadd(aHelpIng,STR0061) //'os Setores disponiveis via Tecla F3'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aciona o Filtro de acordo com o Novo Setor informado 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRetorno := Pergunte("HSPM29",.T.) )

	cGcsCodLoc := MV_PAR01

 HS_DefVar("GCS", 1, cGcsCodLoc, aVarDef)
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSPM54VerDis  ³Autor³Paulo Emidio de Barros³Data³01/02/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica a disponibilidade de Horario para Atendimento no  ³±±
±±³          ³ Agendamento Ambulatorial. (Obs. o registro a ser analisado ³±±
±±³          ³ no GM8, devera estar posicionado.)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPM54VerDis()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = T ou F                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPM54VerDis(cAliasGm8)
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
±±ºPrograma  |HS_VlM54Coº Autor ³ PAULO JOSE DE OLIVEIRA º Data ³ 11.03.2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida as Perguntas da Consulta                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar - funcao de consulta HS_M29CONS()            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VlM54Co(cCpoVld)
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M54CFM º Autor ³PAULO JOSE DE OLIVEIRA  º Data ³  16.03.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ TELA DE CONFIRMACAO DA CONSULTA                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar M29                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M54CFM(cAlias,nReg,nOpc)

Local oDlgCfm   := nil
Local oEnc      := nil
Local lRet      := .T.
Local aArea     := GetArea()
Local cTitulo   := STR0082 //"Cornfirma horario agendado."
Local aCpoEnc   := {}
Local aCpoEdita := {}
Local nOp 		:= 0
//Define as coordenadas e tamanho dos itens da MsDialog
Local aCoordEnc := {003,003,87,250}
Local nIniY 	:= 010
Local nIniX 	:= 000
Local nFinY 	:= 200
Local nFinX 	:= 500

aGets    := {}
aTela    := {}

if GM8->GM8_STATUS $ "4/5"
	RestArea(aArea)
	HS_MsgInf(STR0083 , STR0077, STR0107) //"Este horário não pode ser confirmado."###"Atenção"###"PLANO E PROCEDIMENTO"
	Return()
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

DEFINE MSDIALOG oDlgCfm TITLE OemToAnsi(cTitulo)  From nIniY,nIniX to nFinY,nFinX of oMainWnd PIXEL

oEnc  := MsMGet():New(cAlias, nReg, GD_UPDATE,,,, aCpoEnc, aCoordEnc, aCpoEdita, 3,,,, oDlgCfm,, .T.,,,,,,.T.)

ACTIVATE MSDIALOG oDlgCfm CENTERED ON INIT EnchoiceBar(oDlgCfm, {|| nOp := 1, oDlgCfm:End()}, {|| nOp := 0, oDlgCfm:End()},,/*aButtons*/ )

If nOp == 1
	RecLock("GM8",.F.)
	GM8->GM8_STATUS := "5"      //Status para definir o Agendamento CONFIRMADO
	GM8->GM8_DESCFM := M->GM8_DESCFM
	GM8->GM8_DATCFM := dDataBase
	GM8->GM8_HORCFM := SubStr(Time(),1,5)
	GM8->GM8_USUCFM := SubStr(cUsuario, 7, 15)
	GM8->GM8_LOGARQ := HS_LogArq()
	MsUnLock()
EndIf

RestArea(aArea)

Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_HorAge()³ Autor ³ Paulo jose de Oliveira³ Data ³ 07.04.05³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se o paciente ja usou o porcedimento e mostra os    |±±
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
Local cFiltro 		:= ""
Local lAchou		:= .F.
Local lDatRetOk  	:= .F.
Local cSQL      	:= ""
Local oDlg			:= Nil
Local aListCpo
Local cChave
Local aSize 		:= MsAdvSize()
Local nTamT			:=30

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

		oGet := HS_MBrow(oDlg, "GM8", {aSize[7]+nTamT, 001, aSize[3], aSize[4]-15}, ,,,,,,, cChave, , .F.,, .T. ,aLstCpo, ,, aLstCpo)

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
Static Function FS_AgenFut()
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

Static Function FS_BCancel()
If (nLastFld > 0)  .And. (nLastDay > 0) .And. (nLastHour > 0)
	FS_UByName("M29GM8"+aAgenda[nLastFld,2,nLastDay,nLastHour,nCodAge])
Endif

While __lSx8
	RollBackSxe()
End

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M54Pac ºAutor  ³ Cibele Peria       º Data ³  05/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe paciente do agendamento, caso haja.                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_M54Pac(cAlias, nReg, nOpc)
Local aArea      := GetArea()
Local cCodPac    := ""

DbSelectArea("SX1")
DbSetOrder(1)  // X1_GRUPO + X1_ORDEM
If DbSeek("HSP29A")
	DbSeek(PADR("HSP29A", Len(SX1->X1_GRUPO)) + "01")
	RecLock("SX1", .F.)
	SX1->X1_CNT01 := GM8->GM8_REGGER
	MsUnLock()

	If !Pergunte("HSP29A", .T.)
		Return()
	EndIf

	If !Empty(MV_PAR01) .and. MV_PAR01 <> GM8->GM8_REGGER
		cCodPac := MV_PAR01
	Endif

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
Local nPosHor := 0

If nFldAtu <= Len(aObjetos)

 If (nPosHor := aScan(aOBJETOS[nFldAtu][2]:aCols, {|aVet| aVet[nStatus] == "BR_LARANJA"})) > 0
 	FS_UByName("M29GM8"+aAgenda[nFldAtu,2,aOBJETOS[nFldAtu,1]:nAt,nPosHor,nCodAge])
 EndIf

EndIf

Return(Nil)


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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VPACPLSºAutor  ³Rogerio Tabosa      º Data ³  21/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a existencia do paciente no cadastro de benef      º±±
±±º          ³do Plano de Saúde                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VPACPLS(cChvP)
Local aArea		:= GetArea()
Local aRet		:= {0,0} //Recno BA1 , Recno BA3
Local cQryBA1	:= ""
Local cEmpTrab	:= GetNewPar("MV_EMPRPLS", "99")	// Pega a empresa de trabalho do PLS
Local cFilTrab	:= PADR(GetNewPar("MV_FILIPLS", " "),FWSizeFilial())	// Pega a filial de trabalho do PLS

Hs_TabPLS("A",cFilTrab)	// Abre as tabelas da empresa referente ao PLS
// Faz verificacao do usuario dentro do PLS e retorna o nome do mesmo
cQryBA1 := " SELECT BA1.R_E_C_N_O_ REGBA1,BA3.R_E_C_N_O_ REGBA3 "
cQryBA1 += " FROM BA1" + cEmpTrab + "0 BA1, BA3" + cEmpTrab + "0 BA3 "
cQryBA1 += " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
cQryBA1 += "  AND BA3.BA3_FILIAL = '" + xFilial("BA3") + "' "
cQryBA1 += "  AND BA1.D_E_L_E_T_ <> '*' "
cQryBA1 += "  AND BA3.D_E_L_E_T_ <> '*' "
cQryBA1 += "  AND BA1.BA1_CODINT = BA3.BA3_CODINT "
cQryBA1 += "  AND BA1.BA1_CODEMP = BA3.BA3_CODEMP "
cQryBA1 += "  AND BA1.BA1_MATRIC = BA3.BA3_MATRIC "
cQryBA1 += "  AND BA1_CODINT = '" + SubStr(cChvP,1,4) + "' "
cQryBA1 += "  AND BA1_CODEMP = '" + SubStr(cChvP,5,4) + "' "
cQryBA1 += "  AND BA1_MATRIC = '" + SubStr(cChvP,9,6) + "' "
cQryBA1 += "  AND BA1_TIPREG = '" + SubStr(cChvP,15,2) + "' "
cQryBA1 += "  AND BA1_DIGITO = '" + SubStr(cChvP,17,1) + "' "
cQryBA1 += "  OR BA1_MATANT = '" + cChvP + "' "
cQryBA1 += "ORDER BY BA1_NOMUSR"

cQryBA1 := ChangeQuery(cQryBA1)
TCQUERY cQryBA1 NEW ALIAS "BA1USR"

DbSelectArea("BA1USR")
If !Eof()
	aRet[1] :=  BA1USR->REGBA1
	aRet[2]	:=  BA1USR->REGBA3
EndIf

DbSelectArea("BA1USR")
DbCloseArea()

Hs_TabPLS("F",cFilTrab)	// Fecha as tabelas referente ao PLS

RestArea(aArea)
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VPROPLSºAutor  ³Rogerio Tabosa      º Data ³  21/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a autorização do procedimento no plano de saude    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VPROPLS(cRegGer, cCodPla, cCodCrm, cCodPro, dDatAut,lMsg, aCriticas, lMsgCri)
Local aArea		:= GetArea()
Local aAreaGM8  := GM8->(GetArea())
Local aRecPls	:= {}
Local aRet		:= {}
Local aRetFun	:= {}
Local aDadRda	:= {}
Local aDadUsr	:= {}
Local aHisCri	:= {}
Local lRet := .T.
Local cFilTrab	:= PADR(GetNewPar("MV_FILIPLS", " "),FWSizeFilial())	// Pega a filial de trabalho do PLS

Local nPosCODAGE := ""
Local nPosReg    := ""
Local cCodAgePE  := ""
Local lFlag		:= .F.
LOCAL cCodGloAud  := __aCdCri051[1]  // Critica de auditoria do Plano de Saude
Local nFor		:= 0

Default dDatAut := dDataBase
Default aCriticas 	:= {}
Default lMsg		:= .F.
Default lMsgCri		:= .T.

If Empty(cFilTrab)
	HS_MSGINF(STR0003,STR0077, STR0095) //"Necessário atribuir a Rede de Atendimento do Plano de Saúde no cadastro de profissionais!" //"Necessário atribuir o parametro MV_FILIPLS!"
	Return(.F.)
EndIf

DbSelectArea("GA7")
DbSetOrder(1)
DbGoTop()
If !DbSeek(xFilial("GA7") + cCodPro)
	Return(lRet)
EndIf

DbSelectArea("GCM")
DbSetOrder(2)
DbGoTop()
If !DbSeek(xFilial("GCM") + cCodPla)
	Return(lRet)
EndIf

DbSelectArea("GA9")
DbSetOrder(1)
DbGoTop()
If !DbSeek(xFilial("GA9") + GCM->GCM_CODCON)
	Return(lRet)
EndIf

DbSelectArea("GBJ")
DbSetOrder(1)
DbGoTop()
If !DbSeek(xFilial("GBJ") + cCodCrm)
	Return(lRet)
EndIf

If GA9->GA9_REDPRO == "1" .AND. !Empty(GA7->GA7_TABPLS)	.AND. !Empty(GA7->GA7_PROPLS)
	If Empty(GBJ->GBJ_RDAPLS) //    Convenio proprio / Rede Propria
		HS_MSGINF(STR0153,STR0077, STR0095) //"Necessário atribuir a Rede de Atendimento do Plano de Saúde no cadastro de profissionais!"
		Return(.F.)
	EndIf

	lRet := .F.
	DbSelectArea("GD4")
	DbSetOrder(1)
	DbSeek(xFilial("GD4") + cRegGer + cCodPla)

     if !(GD4->GD4_IDEATI = '1' .AND. GD4->GD4_DTVALI > dDataBase)
     	lRet := .F.    	
		HS_MSGINF(STR0154,STR0077, STR0095) //"Paciente não cadastrado no modulo de Plano de Saude!"
    Endif

	aRecPls := HS_VPACPLS(GD4->GD4_MATRIC) //[Recno BA1 , Recno BA3]
	If aRecPls[1] == 0
		lRet := .F.
		HS_MSGINF(STR0154,STR0077, STR0095) //"Paciente não cadastrado no modulo de Plano de Saude!"
	Else
		Hs_TabPLS("A",cFilTrab)	// abre as tabelas referente ao PLS

		DbSelectArea("BA1")
		DbGoto(aRecPls[1])

		DbSelectArea("BI3")
		DbSetOrder(1)
		DbSeek(xFilial("BI3") + SubStr(GD4->GD4_MATRIC,1,4) + BA1->BA1_CODPLA)

		DbSelectArea("BR8")
		DbSetOrder(1) // BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
		DbSeek(xFilial("BR8") + GA7->GA7_TABPLS + GA7->GA7_PROPLS)

		aDadUsr := PLSA090USR(GD4->GD4_MATRIC,dDatAut,Time(),Alias(),.F.,.T.,.F.) //PLSA260


		lRet := aDadUsr[1]
		If !lRet
			aHisCri 		:= aClone( aDadUsr[2] )
			aCriticas		:= aClone( aDadUsr[2] ) // Array para utilização passando por parametro de alteração @
		Else
			aDadUsr := PLSGETUsr()

			aDadRda	:= PLSDADRDA(SubStr(GD4->GD4_MATRIC,1,4),GBJ->GBJ_RDAPLS,"1",dDatAut, GBJ->GBJ_RDALOC, GBJ->GBJ_RDAESP, GA7->GA7_TABPLS, GA7->GA7_PROPLS )//,cCodLoc,cCodEsp,cCodPad,cCodPro,aBD6,lLoadRda)

			lRet := aDadRda[1]
			If !lRet
				aHisCri 		:= aClone( aDadRda[2] )
				aCriticas		:= aClone( aDadRda[2] ) // Array para utilização passando por parametro de alteração @
			else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ plsautp																	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetFun := PLSAUTP(	dDatAut,;
				Time(),;
				GA7->GA7_TABPLS,;
				GA7->GA7_PROPLS,;
				1,;
				aDadUsr,;
				0,;
				aDadRda,;
				"1",;
				IIf(GetNewPar("MV_PLSMODA","1")=="0",.F.,.T.),;
				"",;
				.T.,;
				"1",;
				.T.,;//lTrarSolic
				PLSINTPAD(),; //SubStr(GD4->GD4_MATRIC,1,4)
				GBJ->GBJ_RDAPLS,;
				str(Year(dDatAut),),;
				Padl(month(dDatAut),2,"0"),;
				"",;
				"",;
				"",;
				.T.,;
				"",;
				"",; //cProRel
				0,;
				SubStr(GD4->GD4_MATRIC,1,4),;
				{},;
				"0",;
				"",;
				"",;
				"",;
				nil,;
				nil,;
				"1",;
				"",; //cFaces
				NIL,;
				NIL,;
				"",; //cTipPreGui
				"",;         //cGrpInt
				nil,;
				"",;
				"",;
				BI3->BI3_ABRANG,;
				nil,;
				nil,;
				nil,;
				nil,;
				nil,;
				.T.,; //lTratExe
				nil,;
				"",; //cTipoProc
				nil,;
				{}) //aQtdBrow
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ aret																	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRet := aClone(aRetFun)
				lRet := aRet[1]
				If !lRet
					aHisCri 		:= aClone( aRet[2] )
					aCriticas		:= aClone( aRet[2] ) // Array para utilização passando por parametro de alteração @
				EndIf
			endif
		endif

		//lRet := aRet[1]
		If !lRet
			//aHisCri 		:= aClone( aRet[2] )
			//aCriticas		:= aClone( aRet[2] ) // Array para utilização passando por parametro de alteração @
			DbSelectArea("BCT")
			DbSetOrder(1)
			For nFor := 1 To Len(aHisCri)
				If aHisCri[nFor][1] <> cCodGloAud
					If ! Empty(aHisCri[nFor][1])
						If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aHisCri[nFor][1])) .And. BCT->BCT_PERFOR == "1"
							lFlag := .T.
							Exit
						Else
							lFlag := .F.
						Endif
					Endif
				Endif
			Next nFor

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se existe pelo menos uma critica que pode forcar entra nessa regra de forcar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFlag
				lRet := PLSMOVCRI("1",{GA7->GA7_TABPLS,GA7->GA7_PROPLS,BR8->BR8_DESCRI,""},aHisCri,.T.)
			Else

			If lMsgCri
				If ExistBlock("HS54CRIOK")
				    If PLSMOVCRI("1",{GA7->GA7_TABPLS,GA7->GA7_PROPLS,BR8->BR8_DESCRI,""},aHisCri,.T.)
				        If Type("aOBJETOS[1][2]") <> 'U'
				        	nPosCODAGE := aScan(aOBJETOS[1][2]:aHeader, {|x|x[2]=="GM8_CODAGE"})
                        	nPosReg    := aOBJETOS[1][2]:nAt
				        	cCodAgePE  := aOBJETOS[1][2]:aCols[nPosReg][nPosCODAGE]
				        EndIf
				        lRet := ExecBlock("HS54CRIOK", .F., .F.,{aHisCri,cCodAgePE})
				    EndIf
				Else
					//PLSMOVCRI("1",{GA7->GA7_TABPLS,GA7->GA7_PROPLS,BR8->BR8_DESCRI,""},aHisCri)
					lRet := PLSMOVCRI("1",{GA7->GA7_TABPLS,GA7->GA7_PROPLS,BR8->BR8_DESCRI,""},aHisCri, .T.)
				EndIf
			EndIf
			//EndIf
		EndIf
	endif
		Hs_TabPLS("F",cFilTrab)	// Fecha as tabelas referente ao PLS
	EndIf
Else
	If lMsg
		HS_MSGINF(STR0203,STR0077, STR0095) //"As configurações para Rede Propria estão incorretas!"
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaGM8)
RestArea(aArea)
Return(lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³Saúde                  ³ Data ³27/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ajuste no grupo de perguntas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSx1()
Local aArea := GetArea()
Local cPerg	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR("HSPM29", Len(SX1->X1_GRUPO))
If SX1->(DbSeek(cPerg + "01"))
	If !("HS_M54LOC" $ X1_VALID)
		RecLock("SX1",.F.)
		Replace SX1->X1_VALID With 'HS_VldCSet(mv_par01,NIL,HS_M54LOC(),"' + STR0152 + '")'
		MsUnlock()
	Endif
Endif

RestArea(aArea)
Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M54LOC ºAutor  ³Rogerio Tabosa      º Data ³  24/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o tipo do local para a o valid do SX1               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_M54LOC()
Return(IIf(Type("cVldLocX1") # "U",cVldLocX1, "5"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_AGEFREEºAutor  ³Rogerio Tabosa      º Data ³  24/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta agendas livres por data e profissional             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_AGEFREE()
Local aArea		:= GetArea()
Local cTitulo := STR0155 //"Agendas Disponiveis"
Local nOpca := 0, nX := 0, nI := 0
Local dDatIni := dDataBase
Local dDatFim := dDataBase
Local cCodCrm := SPACE(TamSx3("GM8_CODCRM")[1])
Local cNomMed := SPACE(TamSx3("RA_NOME")[1])
Local oBtnFil, oDatIni, oDatFim, oCodCrm
Local aHeadAux := {}
Local aSize		:= {}
Local aInfo		:= {}
Local aObjects	:= {}

Local aCpoGM8  := {"GM8_DATAGE","GM8_HORAGE","GM8_CODCRM","GM8_NOMCRM","GM8_CODLOC", "GM8_LOCDES","GM8_CODDIS","GM8_DESDIS", "GM8_CODREC", "GM8_CODSAL","GM8_NOMSAL"}
Local aJoinGM8 := {{" JOIN " + RetSqlName("SRA") + " SRA", "" , "GM8.GM8_CODCRM  = SRA.RA_CODIGO AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_FILIAL = '" + xFilial("SRA") + "'", ""}}
Local aHeadGM8 := {}, aColsGM8 := {}, nUGM8 := 0
Local nCodCrm	 := 0
Local nGM8CodSal	 := 0
Local nGM8NomSal	 := 0
Local oGDGM8, oSay
Local nTam		:=23

Inclui := .F.
aSize := MsAdvSize(.F.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_DATAGE = '" + DTOS(dDatIni) + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.GM8_STATUS = '0' ",,,/*"GM8_DATAGE/GM8_HORAGE/GM8_CODCRM/GM8_NOMCRM/GM8_CODLOC/GM8_LOCDES/GM8_CODDIS/GM8_DESDIS/GM8_CODREC/GM8_CODSAL/GM8_NOMSAL"*/,,,,,,.F.,,,,,, aCpoGM8, aJoinGM8)
nCodCrm := Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_CODCRM"}) //CRM
nNomCrm := Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_NOMCRM"}) //CRM
nGM8CodSal := Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_CODSAL"}) //CRM
nGM8NomSal := Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_NOMSAL"}) //CRM

For nI := 1 To Len(aColsGM8)
	If Empty(aColsGM8[nI, nGM8CodSal])
		aColsGM8[nI, nGM8NomSal] := Space( (TamSx3( "GM8_NOMSAL" )[1]) )
	EndIf
Next nI
For nI := 1 To Len(aHeadGM8)
	If !(aScan(aCpoGM8, aHeadGM8[nI,2]) == 0)
		AADD(aHeadAux, aHeadGM8[nI])
	EndIf
Next nI
aHeadGM8 := aClone(aHeadAux)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7], 000 To (aSize[6]/1.52) +nTam, aSize[5]/1.75 Of oMainWnd Pixel   //000 000 400 600


@015+nTam, 005 TO 055+nTam, 345 Label STR0156 OF oDlg PIXEL //"Filtros"

@025+nTam, 010 Say STR0157 Of oDlg Pixel COLOR CLR_BLUE // "Data Agenda De:"
@035+nTam, 010 MSGet oDatIni Var dDatIni Picture "@D" Size 50, 010 Of oDlg Pixel Color CLR_BLACK
@025+nTam, 070 Say STR0158 Of oDlg Pixel COLOR CLR_BLUE //"Data Agenda Ate:"
@035+nTam, 070 MSGet oDatFim Var dDatFim Picture "@D" Size 50, 010 Of oDlg Pixel Color CLR_BLACK
@025+nTam, 130 Say STR0159 Of oDlg Pixel COLOR CLR_BLUE // "Cod.CRM:"
@035+nTam, 130 MSGet oCodCrm Var cCodCrm F3 "GBJ   " Picture "@!" Size 50, 010 Of oDlg Pixel Color CLR_BLACK
@025+nTam, 190 Say STR0160 Of oDlg Pixel COLOR CLR_BLUE //"Nome do Profissional:"
@035+nTam, 190 MSGet oNomMed Var cNomMed Size 100, 010 Of oDlg Pixel Color CLR_BLACK

oBtnFil := tButton():New(035+nTam, 300,STR0161, oDlg, {|| MsgRun(STR0162,, {||FS_LISTGM8(dDatIni,dDatFim, cCodCrm, cNomMed,@aCpoGM8,@aJoinGM8,@aHeadGM8,@nCodCrm,@nNomCrm,@nGM8CodSal,@oGDGM8,@oSay,@nGM8NomSal )})}, 030, 012,,,, .T.) // "Filtrar""Buscando horários..."

oGDGM8 := MsNewGetDados():New(060+nTam, 005, 200, 345,0,,,,,,,,,, oDlg, aHeadGM8, aColsGM8)    // 000 000 300 500
@235,005 SAY oSay PROMPT OemToAnsi(STR0163) SIZE 060,009 OF oDlg PIXEL COLOR CLR_HRED //"Total de horários: "

If Empty(aColsGM8[1,nCodCrm])
	oSay:SetText(STR0163 + " 0")
Else
	oSay:SetText(STR0163 + Alltrim(Str(Len(aColsGM8))))
EndIf

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{ || nOpca := 1, oDlg:End() },{|| nOpca := 0, oDlg:End()})


RestArea(aArea)
Return()


Static Function FS_LISTGM8(dDatIni,dDatFim, cCodCrm, cNomMed,aCpoGM8,aJoinGM8,aHeadGM8,nCodCrm,nNomCrm,nGM8CodSal,oGDGM8,oSay,nGM8NomSal )
Local aArea := GetArea()
Local cCond := IIf(!Empty(cCodCrm), " AND GM8.GM8_CODCRM = '" + cCodCrm + "'", "")
Local nI := 0

If Empty(dDatIni) .OR. Empty(dDatFim)
	HS_MSGINF(STR0164, STR0077,STR0095)//"Informe os filtros de Data Inicial e Final!"
	Return
EndIf
If dDatIni > dDatFim
	HS_MSGINF(STR0165, STR0077,STR0095) //"Inconsistências na Data Inicial e Final!"
	Return
EndIf
//

If !Empty(cNomMed)
	cCond += " AND SRA.RA_NOME LIKE '" + Alltrim(cNomMed) + "%' "
EndIf

aColsGM8 := {}
nUGM8 := 0
HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_DATAGE >= '" + DTOS(dDatIni) + "' AND GM8.GM8_DATAGE <= '" + DTOS(dDatFim) + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.GM8_STATUS = '0' " + cCond,,,,,,,,,.F.,,,,,, aCpoGM8, aJoinGM8)

If Empty(aColsGM8[1,nCodCrm])
	aColsGM8[1,nNomCrm] := SPACE(TamSx3("GM8_NOMCRM")[1])
	oSay:SetText(STR0163 + " 0")//"Total de horários: "
Else
	oSay:SetText(STR0163 + Alltrim(Str(Len(aColsGM8))))//"Total de horários: "
	For nI := 1 To Len(aColsGM8)
		If Empty(aColsGM8[nI, nGM8CodSal])
			aColsGM8[nI, nGM8NomSal] := Space( (TamSx3( "GM8_NOMSAL" )[1]) )
		EndIf
	Next nI
EndIf

oGDGM8:SetArray(aColsGM8)
oGDGM8:oBrowse:Refresh()

RestArea(aArea)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLDPLS ºAutor  ³Rogerio Tabosa      º Data ³  24/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada para a validação da autorização no PLS              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_VLDPLS(dDatAge, nOpcAge)
Local aArea := GetArea()
Local aAreaGM8  := GM8->(GetArea())
Local lRet := .T.
Local lIntegr	:= GetMv("MV_HSPPLS")

If nOpcAge <> 2 .AND.  nOpcAge <> 4// Se não for inclusão   ou transferencia
	Return(lRet)
EndIf

//========================= VALIDAÇÃO INTEGRAÇÃO PLSAUTP ==============================================//
If lIntegr .AND. !Empty(M->GM8_CODPRO) .AND. !Empty(M->GM8_CODPLA) .AND. !Empty(M->GM8_REGGER) .AND.  !Empty(M->GM8_CODCRM)
	lRet := HS_VPROPLS(	M->GM8_REGGER, M->GM8_CODPLA, M->GM8_CODCRM, M->GM8_CODPRO, dDatAge)
EndIf
//=====================================================================================================//

RestArea(aAreaGM8)
RestArea(aArea)
Return(lRet)

Function HS_GrvGo4(cCodAge, nOpc,nGO4_CODPRO,nGO4_NUMORC,nGO4_ITEORC)
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

	If (oGO4:aCols[nI, len(oGO4:aHeader)+1] .Or. nOpc == 3) .And. lAchou
		RecLock("GO4", !lAchou)
		 DbDelete()
		MsUnLock()
	Else
		RecLock("GO4", !lAchou)
		 GO4->GO4_FILIAL := xFilial("GO4")
		 GO4->GO4_CODAGE := cCodAge
		 GO4->GO4_CODPRO := oGO4:aCols[nI,nGO4_CODPRO]
		 GO4->GO4_NUMORC := oGO4:aCols[nI,nGO4_NUMORC]
		 GO4->GO4_ITEORC := oGO4:aCols[nI,nGO4_ITEORC]
		MsUnLock()
	EndIf

Next nI

//ajusta o status do procedimento agendado e dos procedimentos secundarios (GO4) na tabela GTJ (se houver)
fs_atuStaGtj(M->GM8_NUMORC + M->GM8_ITEORC , oGO4, nOpc,nGO4_NUMORC,nGO4_ITEORC )

oGO4:aCols := {}

RestArea(aArea)
Return(lRet)

Function HS_GrvGeb(cCodAge, nOpc,nGebItem,nGebQtdMat,nGebNumOrc,nGebIteOrc)
 Local aArea   := GetArea()
 Local lRet    := .F.
 Local nForGrv := 0
 Local lAchou  := .F.

 For nForGrv := 1 to len(oGetGeb:aCols)

	 If Empty(oGetGeb:aCols[nForGrv][nGebCodMat])
	 	Loop
	 EndIf

	 DbSelectArea("GEB")
	 DbSetOrder(1)
	 lAchou := DbSeek(xFilial("GEB") + cCodAge + oGetGeb:aCols[nForGrv][nGebCodMat])

	 If (oGetGeb:aCols[nForGrv][Len(oGetGeb:aHeader) + 1] .Or. nOpc == 3) .And. lAchou
	 	RecLock("GEB", !lAchou)
	  	DbDelete()
	 	MsUnLock()

	 Else
	 	RecLock("GEB", !lAchou)
  		GEB->GEB_FILIAL := xFilial("GEB")
  		GEB->GEB_CODAGE := cCodAge
  		GEB->GEB_ITEM   := oGetGeb:aCols[nForGrv][nGebItem  ]
	    GEB->GEB_CODMAT := oGetGeb:aCols[nForGrv][nGebCodMat]
    	GEB->GEB_QTDMAT := oGetGeb:aCols[nForGrv][nGebQtdMat]
	    GEB->GEB_NUMORC := oGetGeb:aCols[nForGrv][nGebNumOrc]
    	GEB->GEB_ITEORC := oGetGeb:aCols[nForGrv][nGebIteOrc]
	 	MsUnLock()
	 EndIf

 Next nForGrv

 oGetGeb:aCols := {}

 RestArea(aArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_findCriºAutor  ³ Saude              º Data ³  05/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se exite(m) critica(s) para o paciente e/ou        º±±
±±º          ³para o(s) procedimento(s)selecionados na agenda clinica     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function FS_findCri(cCodPac, cCodProc)
local aArea    := getArea()
local aProc    := {}
local aCritPro := {}
local aCritEsp := {}
local aCritPac := {}
local lRet     := .T.
local nI
local nIa
local aTemp
local aCritica

If Empty(M->GM8_REGGER)
	Return(.T.)
EndIf

//Verifica se o paciente possui critica cadastrada
aTemp := HS_RCRIPAC(cCodPac, cCodProc)
if len(aTemp) > 0
	for nIa:=1 to len(aTemp)
		aAdd(aCritPac, {aTemp[nIa,1],aTemp[nIa,2],aTemp[nIa,3],aTemp[nIa,4],aTemp[nIa,5]})
	next nIa
EndIf

//Verifica se o procedimento inserido esta cadastrado
DbSelectArea("GA7")
DbSetOrder(1)
if DbSeek(xFilial("GA7")+cCodProc)
	//Verifica se existe pacote para o procedimento
	aProc := fs_pacProc(cCodProc)
	if len(aProc) > 0
		for nI := 1 to len(aProc)
			//Verifica se o procedimento possui critica cadastrada
			aTemp := HS_RCRIPRO(aProc[nI,1])
			for nIa:=1 to len(aTemp)
				aAdd(aCritPro, {aTemp[nIa,1],aTemp[nIa,2],aTemp[nIa,3],aTemp[nIa,4],aTemp[nIa,5],aTemp[nIa,6],aTemp[nIa,7]})
			next nIa
			//verifica especialidade
			if len(aTemp) == 0
				aCritEsp := HS_RCRIESP(cCodProc, )
			endif
		next nI
	else
		//se nao existe pacote, pesquisa diretamente na GTL (Criticas por Procedimento)
		aTemp := HS_RCRIPRO(cCodProc)
		if len(aTemp) > 0
			for nIa:=1 to len(aTemp)
				aAdd(aCritPro, {aTemp[nIa,1],aTemp[nIa,2],aTemp[nIa,3],aTemp[nIa,4],aTemp[nIa,5],aTemp[nIa,6],aTemp[nIa,7]})
			next nIa
		else
			//Se nao ha criticas, verifica a especialidade
			aCritEsp := HS_RCRIESP(cCodProc, )
		endif
	endif
else
	HS_MsgInf(STR0004 + cCodPro + STR0005,STR0077,STR0102)  //"Procedimento (XXXXXXXXXX) não encontrado!"###"Atencao"###"Marca o Horario na Agenda" //"Procedimento ("###") não encontrado!"
	lRet := .F.
endif

//Verifica se o cadastro de criticas é utilizado
if SuperGetMV("MV_CRITCLI", NIL, .F.)
	if len(aCritPro)>=1 .or. len(aCritEsp)>=1 .or. len(aCritPac)>=1
		//Valida as criticas encontradas
		aCritica:= HS_verCrit(aCritPro, aCritEsp, aCritPac, oCalend:dDiaAtu, M->GM8_REGGER)
		if len(aCritica)>=1
			//Chama a tela de exibicao critica (FS_viewCri) passando as criticas localizadas
			lRet := FS_viewCri(aCritica)
		endif
	endif
endif


restArea(aArea)
return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_pacProcºAutor  ³ Saude              º Data ³  05/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os procedimentos que compoem o pacote de um determi º±±
±±º          ³nado procedimento                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function fs_pacProc(cCodProc)
local aArea    := getArea()
local aProc    := {}
local cCodPct

aAdd(aProc, {cCodProc})

//Loaliza o pacote
dbSelectArea("GA1")
dbSetOrder(3)
if dbSeek(xFilial("GA1")+cCodProc)
	cCodPct := GA1->GA1_CODPCT
	dbSelectArea("GA2")
	dbSetOrder(1)
	if dbSeek(xFilial("GA2") + cCodPct)
		While  GA2->GA2_CODPCT == cCodPct
		 	aAdd(aProc, {GA2->GA2_CODCPC})
		 	skip
		End
	endif

endif

dbCloseArea()
restArea(aArea)
return aProc



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_viewCriºAutor  ³ Saude              º Data ³  05/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe as criticas localizadas para o(s) procedimento(s)     º±±
±±º          ³selecionados na agenda clinica                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

static Function FS_viewCri(aProCri)

Local cCoJust  := Space(TamSx3("GT7_CODMTV")[1])
Local oCodJus,oSol
Local cComent  :=Space(TamSx3("GT7_DESMTV")[1])
LOCAL cTitulo  := STR0192 //"Críticas para os procedimentos selecionados"
local nOpcI    := 2
Local aGrv     := {}
local aCritica := {}
local nI,nJ
local cCodPrEs

aSort(aProCri)

for nI:=1 to len(aProCri)
	if nI>1
		if aProCri[nI,1] == aProCri[nI-1,1]
			aAdd(aCritica,{"","     " + aProCri[nI,3] + "  -  " + aProCri[nI,4]})
		else
			aAdd(aCritica,{aProCri[nI,1],aProCri[nI,2]})
			aAdd(aCritica,{"","     " + aProCri[nI,3] + "  -  " + aProCri[nI,4]})
		endif
	else
		aAdd(aCritica,{aProCri[nI,1],aProCri[nI,2]})
		aAdd(aCritica,{"","     " + aProCri[nI,3] + "  - "  + aProCri[nI,4]})
	endif
next nI



DEFINE MSDIALOG oDlgCri TITLE cTitulo FROM 008,010 TO 420,800 PIXEL
@ 10,10 LISTBOX oLbx FIELDS HEADER 	STR0193,STR0194 SIZE 380,130 OF oDlgCri PIXEL  //"Cód. Proced./Especialidade" ### "Descrição / Crítica"


oLbx:SetArray( aCritica )
  oLbx:bLine := {|| {aCritica[oLbx:nAt, 01], ;
                     aCritica[oLbx:nAt, 02]}}
oLbx:refresh()

@ 140, 010 TO 180, 390 Label STR0195 OF oDlgCri PIXEL //" Forçar Crítica "

@ 160, 020 Say STR0196 Of oDlgCri Pixel COLOR CLR_BLUE // "Cod. Justificativa"
@ 160, 070 MSGet oCodjus Var cCoJust F3 "GT7   " Valid  Hs_vldJust(cCoJust) Picture "@!" Size 50, 010 Of oDlgCri Pixel Color CLR_BLACK

@ 160, 130 Say STR0197  Of oDlgCri Pixel COLOR CLR_BLUE    // "Descrição "
@ 160, 170 MsGet oSol VAR cComent:=HS_IniPadr("GT7", 1, cCoJust, "GT7_DESMTV",, .F.) WHEN .F. Size 140, 009 OF oDlgCri Pixel COLOR CLR_BLACK

DEFINE SBUTTON FROM 160,350 TYPE 1 ACTION {|| nOpcI := 1, IIf(!Empty(cCoJust), oDlgCri:End(), nIL)} ENABLE OF oDlgCri//Ok

DEFINE SBUTTON FROM 190,350 TYPE 2 ACTION {|| nOpcI := 2, oDlgCri:End()} ENABLE OF oDlgCri	//Cancelar


ACTIVATE MSDIALOG oDlgCri CENTERED


If nOpcI == 1
	aGrv := HS_RetSup()
	M->GM8_MTVAGE := cCoJust
	M->GM8_USUFOR := aGrv[2]
	Return aGrv[1]
EndIf

Return .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_AGECANCºAutor  ³Rogerio Tabosa      º Data ³  24/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta agendas livres por data e profissional             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_AGECANC()
Local aArea		:= GetArea()
Local cTitulo := STR0178 //"Agendamentos Cancelados"
Local nOpca := 0, nX := 0, nI := 0
Local dDatIni := dDataBase
Local dDatFim := dDataBase
Local cCodCrm := SPACE(TamSx3("GM9_CODCRM")[1])
Local cNomMed := SPACE(TamSx3("RA_NOME")[1])
Local oBtnFil, oDatIni, oDatFim, oCodCrm
Local aHeadAux := {}
Local cMCAuto	:= SuperGetMV("MV_MCAUTO", NIL, "")
Local aObjects  := {}
local aInfo     := {}
local aSize     := {}
local aPPanel   := {}
local nLargura  := 0
local nAltura   := 0
local aSizeini  := {}
local aLegGM9 	:= {{"GM9_CODCAN == '" +  cMCAuto + "'", "BR_LARANJA"},{"GM9_CODCAN <> '" +  cMCAuto + "'", "BR_VERMELHO"}}
local aCpoGM9  	:= {"GM9_REGGER","GM9_NOMPAC" ,"GM9_DATCAN","GM9_CODCAN" , "GM9_DESCAN","GM9_DATAGE","GM9_HORAGE","GM9_CODCRM","GM9_NOMCRM","GM9_CODLOC", "GM9_CODDIS","GM9_CODSAL"}
local aJoinGM9 	:= {{" JOIN " + RetSqlName("SRA") + " SRA", "" , "GM9.GM9_CODCRM  = SRA.RA_CODIGO AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_FILIAL = '" + xFilial("SRA") + "'", ""}}
local aHeadGM9 	:= {}, aColsGM9 := {}, nUGM9 := 0
local nCodCrm	:= 0
local oGDGM9, oSay
Local nTam		:=15

Inclui := .F.

HS_BDados("GM9", @aHeadGM9, @aColsGM9,@nUGM9, 1,, " GM9.GM9_DATAGE = '" + DTOS(dDatIni) + "' AND GM9.D_E_L_E_T_ <> '*' AND GM9.GM9_FILIAL = '" + xFilial("GM9") + "' ",.T.,"HSP_STAREG",/*"GM9_DATAGE/GM9_HORAGE/GM9_CODCRM/GM9_NOMCRM/GM9_CODLOC/GM9_LOCDES/GM9_CODDIS/GM9_DESDIS/GM9_CODREC/GM9_CODSAL/GM9_NOMSAL"*/,,,,,,.F.,aLegGM9,,,,, aCpoGM9, aJoinGM9)
nCodCrm := Ascan(aHeadGM9,{|x|AllTrim(x[2])=="GM9_CODCRM"}) //CRM
nNomCrm := Ascan(aHeadGM9,{|x|AllTrim(x[2])=="GM9_NOMCRM"}) //CRM

aSize	:= MsAdvSize(.T.)
aAdd( aObjects, { 100, 020, .T., .T.} )
aAdd( aObjects, { 100, 070, .T., .T.} )
aAdd( aObjects, { 100, 010, .T., .T.} )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE cTitulo From 000, 000 To 540, 700 Of oMainWnd Pixel   //000 000 400 600

@015+nTam, 005 TO 055+nTam, 345 Label STR0156 OF oDlg PIXEL //"Filtros"
@025+nTam, 010 Say STR0157 Of oDlg Pixel COLOR CLR_BLUE // "Data Agenda De:"
@035+nTam, 010 MSGet oDatIni Var dDatIni Picture "@D" Size 50, 010 Of oDlg Pixel Color CLR_BLACK
@025+nTam, 070 Say STR0158 Of oDlg Pixel COLOR CLR_BLUE //"Data Agenda Ate:"
@035+nTam, 070 MSGet oDatFim Var dDatFim Picture "@D" Size 50, 010 Of oDlg Pixel Color CLR_BLACK
@025+nTam, 130 Say STR0159 Of oDlg Pixel COLOR CLR_BLUE // "Cod.CRM:"
@035+nTam, 130 MSGet oCodCrm Var cCodCrm F3 "MED   " Picture "@!" Size 50, 010 Of oDlg Pixel Color CLR_BLACK
@025+nTam, 190 Say STR0160 Of oDlg Pixel COLOR CLR_BLUE //"Nome do Profissional:"
@035+nTam, 190 MSGet oNomMed Var cNomMed Size 100, 010 Of oDlg Pixel Color CLR_BLACK
@ 235, 100 BitMap NAME "BR_VERMELHO" SIZE 8, 8 NOBORDER Of  oDlg PIXEL
@ 235, 110 Say STR0198 Of  oDlg PIXEL //"Cancelado"
@ 235, 200 BitMap NAME "BR_LARANJA" SIZE 8, 8 NOBORDER Of  oDlg PIXEL
@ 235, 210 Say STR0199 Of  oDlg PIXEL // "Cancelado Automaticamente"

oBtnFil := tButton():New(035, 300,STR0161, oDlg, {|| MsgRun(STR0162,, {||FS_LISTGM9(dDatIni,dDatFim, cCodCrm, cNomMed,@aLegGM9,@aCpoGM9,@aJoinGM9,@aHeadGM9,@nCodCrm,@oGDGM9,@oSay)})}, 030, 012,,,, .T.) // "Filtrar""Buscando horários..."
oGDGM9 := MsNewGetDados():New(060+nTam, 005, 230, 345,0,,,,,,,,,, oDlg, aHeadGM9, aColsGM9)    // 000 000 300 500
@235,005 SAY oSay PROMPT OemToAnsi(STR0163) SIZE 060,009 OF oDlg PIXEL COLOR CLR_HRED //"Total de horários: "

If Empty(aColsGM9[1,nCodCrm])
	oSay:SetText(STR0163 + " 0")
Else
	oSay:SetText(STR0163 + Alltrim(Str(Len(aColsGM9))))
EndIf

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{ || nOpca := 1, oDlg:End() },{|| nOpca := 0, oDlg:End()})


RestArea(aArea)
Return()




Static Function FS_LISTGM9(dDatIni,dDatFim, cCodCrm, cNomMed,aLegGM9,aCpoGM9 ,aJoinGM9, aHeadGM9, nCodCrm, oGDGM9, oSay)
Local aArea := GetArea()
Local cCond := IIf(!Empty(cCodCrm), " AND GM9.GM9_CODCRM = '" + cCodCrm + "'", "")

If Empty(dDatIni) .OR. Empty(dDatFim)
	HS_MSGINF(STR0164, STR0077,STR0095)//"Informe os filtros de Data Inicial e Final!"
	Return
EndIf
If dDatIni > dDatFim
	HS_MSGINF(STR0165, STR0077,STR0095) //"Inconsistências na Data Inicial e Final!"
	Return
EndIf
//

If !Empty(cNomMed)
	cCond += " AND SRA.RA_NOME LIKE '" + Alltrim(cNomMed) + "%' "
EndIf

aColsGM9 := {}
nUGM9 := 0
HS_BDados("GM9", @aHeadGM9, @aColsGM9,@nUGM9, 1,, " GM9.GM9_DATAGE >= '" + DTOS(dDatIni) + "' AND GM9.GM9_DATAGE <= '" + DTOS(dDatFim) + "' AND GM9.D_E_L_E_T_ <> '*' AND GM9.GM9_FILIAL = '" + xFilial("GM9") + "' " + cCond,.T.,"HSP_STAREG",,,,,,,.F.,aLegGM9,,,,, aCpoGM9, aJoinGM9)

If Empty(aColsGM9[1,nCodCrm])
	aColsGM9[1,nNomCrm] := SPACE(TamSx3("GM9_NOMCRM")[1])
	oSay:SetText(STR0200 + " 0")//"Total de registros:"
Else
	oSay:SetText(STR0200 + Alltrim(Str(Len(aColsGM9))))//"Total de registros:"
EndIf

oGDGM9:SetArray(aColsGM9)
oGDGM9:oBrowse:Refresh()

RestArea(aArea)
Return

Static Function FS_INFPEND(oTxtPend,cPend)
//CoNout("Foi")
cPend := IIf(Empty(cPend),'(P)',"")
oTxtPend:SetText(cPend)
oTxtPend:Refresh()
Return




//Atualiza o status do prcedimento na GTJ (se fizer parte de um plano de tratamento)
static function fs_atuStaGtj(cOrcItem, oGetGO4, nOpc,nGO4_NUMORC,nGO4_ITEORC )
//lCancela = Indica se o agendamento esta sendo cancelado
local aArea   := getArea()
local nI      := 0
local cStatus := ""

Default cOrcItem := ""
Default nOpc     := 1

if nOpc == 2 .or. nOpc == 4 .or. nOpc == 5
	cStatus := "3"
elseif nOpc == 3
	cStatus := "0"
endif

//Atualiza o status do item principal da agenda
DbSelectArea("GTJ")
dbGoTop()
DbSetOrder(1)
if DbSeek(xFilial("GTJ") +  cOrcItem )
	RecLock("GTJ", .F.)
	GTJ->GTJ_STATUS := cStatus
	msUnlock()
endif


if len(oGetGO4:aCols) == 0
	return .T.
endif
//atualiza o status dos procedimentos secundarios (GO4)
for nI := 1 to len(oGetGO4:aCols)
	//se a linha nao foi deletada
	if !oGetGO4:aCols[nI,len(oGetGO4:aCols[nI])]
		dbGoTop()
		DbSetOrder(1)
		if DbSeek(xFilial("GTJ") + oGetGO4:aCols[nI,nGO4_NUMORC] + oGetGO4:aCols[nI,nGO4_ITEORC] )
			//Atualiza o status do procedimento
			RecLock("GTJ", .F.)
			GTJ->GTJ_STATUS := cStatus
			msUnlock()
		endif
	endif
next nI

dbCloseArea()

restArea(aArea)
return .T.

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

Static Function FS_ADX3COLM54(cAlias, aCampos, lAjustaOrdem, aColsHid)
Local aArea := GetArea()
DbSelectArea("SX3")
DbSetOrder(1) // X3_ARQUIVO
DbGoTop()
DbSeek(cAlias)
While !Eof() .And. SX3->X3_ARQUIVO == cAlias
	If 	X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE = "S" .AND. !("FILIAL" $ SX3->X3_CAMPO) .and. aScan(aColsHid, {|aVet| aVet == Alltrim(SX3->X3_CAMPO)}) == 0 ;
	.and. SX3->X3_CONTEXT <> "V"
		If aScan(aCampos, {|aVet| aVet[1] == Alltrim(SX3->X3_CAMPO)}) == 0
			aAdd(aCampos, {SX3->X3_CAMPO, SX3->X3_PICTURE,SX3->X3_TITULO,SX3->X3_TAMANHO})
		EndIf
	EndIf
	DbSkip()
EndDo
RestArea(aArea)
Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HSM54LEGGM8 ³ Autor ³Saude                ³ Data ³28/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas na tela de Agendamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSM54LEGGM8()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHM54                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSM54LEGGM8()
Local aLegenda := {}
Local cCadastro  := OemToAnsi(STR0152) //"Agenda Clinica"

//Adicionar core conforme funcao HSPM54SitAge() - Excecao BR_LARANJA / BR_VERMELHO

Aadd(aLegenda,{"BR_VERDE"   ,OemToAnsi(STR0026)}) //"Livre"
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0024)}) //"Ocupado"
Aadd(aLegenda,{"BR_AMARELO" ,OemToAnsi(STR0038)}) //"Bloqueado"
Aadd(aLegenda,{"BR_PINK"    ,OemToAnsi(STR0062)}) //"Atendido"
Aadd(aLegenda,{"BR_AZUL"    ,OemToAnsi(STR0075)}) //"Bloqueado/Ocupado"
Aadd(aLegenda,{"BR_LARANJA" ,OemToAnsi(STR0204)}) //"Marcado - Não Confirmado"
Aadd(aLegenda,{"BR_VIOLETA" ,OemToAnsi(STR0208)}) //"Em Conferencia"
Aadd(aLegenda,{"BR_BRANCO"  ,OemToAnsi(STR0209)}) //"Transferido"

BrwLegenda(cCadastro,STR0039,aLegenda)  //"Agendamento"

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_AGECANCºAutor  ³Rogerio Tabosa      º Data ³  24/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta agendas livres por data e profissional             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_AGENPAC(cCodPac,cAlias,nReg)
Local aArea		:= GetArea()
Local cTitulo := STR0006 //"Agendamentos Cancelados" //"Agendamentos por Paciente"
Local nOpca := 0, nX := 0, nI := 0
Local dDatIni := dDataBase
Local dDatFim := dDataBase
Local cNomPac := SPACE(TamSx3("GBH_NOME")[1])
Local oBtnFil, oDatIni, oDatFim, oCodPac, oBtnCon, oBtnCan
Local aObjects  := {}
local aInfo     := {}
local aSize     := {}
local aPPanel   := {}
local nLargura  := 0
local nAltura   := 0
local aSizeini  := {}
Local aButtons  := {}
Local cCodAge	:= ""
Local aLegGM8  := {}

Local aCpoGM8   := {"GM8_DATAGE","GM8_HORAGE","GM8_CODCRM","GM8_NOMCRM","GM8_CODLOC", "GM8_LOCDES","GM8_CODDIS","GM8_DESDIS", "GM8_CODREC", "GM8_CODSAL","GM8_NOMSAL"}
Local aHeadGM8  := {}, aColsGM8 := {}, nUGM8 := 0
Local nCodCrm	:= 0
Local oGDGM8, oSay
Local nTam		:=15   


Default cCodPac := SPACE(TamSx3("GM8_REGGER")[1])

Private oDlgCA
Private aLegCam := {{"GM8_STATUS == '0'", "BR_VERDE"},; //0=Orc. Pendente;1=Pend.Fin.\Nao Autoriz;2=Aprovado;3=Liberado;4=Cancelado;5=Em tratamento;6=Finalizado
					{"GM8_STATUS == '1'", "BR_VERMELHO"},;
					{"GM8_STATUS == '2'", "BR_AMARELO"},;
					{"GM8_STATUS == '3'", "BR_PINK"},;
					{"GM8_STATUS == '4'", "BR_AZUL"},;
					{"GM8_STATUS == '5'", "BR_LARANJA"},;
					{"GM8_STATUS == '7'", "BR_VIOLETA"}}

Inclui := .F.

If !Empty(cCodPac)
	HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_REGGER == '" + cCodPac + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_DATAGE >= '" + DTOS(dDataBase) + "' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' ",,"GM8_STATUS",/*"GM9_DATAGE/GM9_HORAGE/GM9_CODCRM/GM9_NOMCRM/GM9_CODLOC/GM9_LOCDES/GM9_CODDIS/GM9_DESDIS/GM9_CODREC/GM9_CODSAL/GM9_NOMSAL"*/,,,,,,.F.,aLegCam,,,,, aCpoGM8,)
Else
	HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_REGGER <> '" + SPACE(TamSx3("GM8_REGGER")[1]) + "' AND GM8.GM8_DATAGE >= '" + DTOS(dDataBase) + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' ",,"GM8_STATUS",/*"GM9_DATAGE/GM9_HORAGE/GM9_CODCRM/GM9_NOMCRM/GM9_CODLOC/GM9_LOCDES/GM9_CODDIS/GM9_DESDIS/GM9_CODREC/GM9_CODSAL/GM9_NOMSAL"*/,,,,,,.F.,aLegCam,,,,, aCpoGM8,)
EndIf
nCodCrm 	:= Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_CODCRM"}) //CRM
nGM8CodSal	:= Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_CODSAL"}) //CRM
nGM8NomSal	:= Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_NOMSAL"}) //CRM
nNomCrm := Ascan(aHeadGM8,{|x|AllTrim(x[2])=="GM8_NOMCRM"}) //CRM    

aSize	:= MsAdvSize(.T.)

aAdd( aObjects, { 100, 020, .T., .T.} )
aAdd( aObjects, { 100, 070, .T., .T.} )
aAdd( aObjects, { 100, 010, .T., .T.} )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlgPAC TITLE cTitulo From 000, 000 To 525, 700 Of oMainWnd Pixel   //000 000 400 600

@015+nTam, 005 TO 055+nTam, 345 Label STR0156 OF oDlgPAC PIXEL //"Filtros"
@025+nTam, 010 Say STR0157 Of oDlgPAC Pixel COLOR CLR_BLUE // "Data Agenda De:"
@035+nTam, 010 MSGet oDatIni Var dDatIni Picture "@D" Size 50, 010 Of oDlgPAC Pixel Color CLR_BLACK
@025+nTam, 070 Say STR0158 Of oDlgPAC Pixel COLOR CLR_BLUE //"Data Agenda Ate:"
@035+nTam, 070 MSGet oDatFim Var dDatFim Picture "@D" Size 50, 010 Of oDlgPAC Pixel Color CLR_BLACK
@025+nTam, 130 Say "Cod. Pac." Of oDlgPAC Pixel COLOR CLR_BLUE // "Cod.CRM:"
@035+nTam, 130 MSGet oCodPac Var cCodPac F3 "GBH   " Picture "@!" Size 50, 010 Of oDlgPAC Pixel Color CLR_BLACK
@025+nTam, 190 Say STR0007 Of oDlgPAC Pixel COLOR CLR_BLUE //"Nome do Profissional: //"Nome do Paciente"
@035+nTam, 190 MSGet oNomPac Var cNomPac Size 100, 010 Of oDlgPAC Pixel Color CLR_BLACK

oGDGM8 := MsNewGetDados():New(060+nTam, 005, 230, 345,0,,,,,,,,,, oDlgPAC, aHeadGM8, aColsGM8)    // 000 000 300 500
@235,005 SAY oSay PROMPT OemToAnsi(STR0163) SIZE 060,009 OF oDlgPAC PIXEL COLOR CLR_HRED //"Total de horários: "

cCodAge := Ascan(oGDGM8:aHeader,{|x|AllTrim(x[2])=="GM8_CODAGE"})

oBtnFil := tButton():New(035+nTam, 300,STR0161, oDlgPAC, {|| MsgRun(STR0162,, {||FS_LISTPAC(dDatIni,dDatFim, cCodPac, cNomPac,@aCpoGM8,@aHeadGM8,@aColsGM8,@nUGM8,@nCodCrm,@oGDGM8,@oSay,@nGM8NomSal )})}, 030, 012,,,, .T.) // "Filtrar""Buscando horários..."
oBtnCon := tButton():New(235, 140, STR0212, oDlgPAC,{|| MsgRun(STR0212,, {||HS_M54CFM(Alias(),(oGDGM8:nAt),7)})}, 065, 012,,,, .T.) // "Confirmar" //"Confirmar Agenda"###"Confirmar Agendamento"
oBtnCan := tButton():New(235, 210, STR0214, oDlgPAC, {|| MsgRun(STR0214 ,, {||HS_M54CAN(Alias(),(oGDGM8:nAt),3,cCodPac, cCodAge, @aCpoGM8,@aHeadGM8,@aColsGM8,@nUGM8,@nCodCrm,@oGDGM8,@oSay,@nGM8NomSal)})}, 065, 012,,,, .T.) // "Cancelar" //"Cancelar Agenda"###"Cancelar Agendamento"
oBtnFec := tButton():New(235, 280, STR0216, oDlgPAC, {|| MsgRun(STR0216 ,, {||oDlgPAC:End()})}, 065, 012,,,, .T.) // "Fechar" //"Fechar"###"Fechar Agendamento"

If Empty(aColsGM8[1,nCodCrm])
	oSay:SetText(STR0163 + " 0")
Else
	oSay:SetText(STR0163 + Alltrim(Str(Len(aColsGM8))))
EndIf

ACTIVATE MSDIALOG oDlgPAC CENTERED ON INIT EnchoiceBar(oDlgPAC,{ || nOpca := 1, oDlgPAC:End() },{|| nOpca := 0, oDlgPAC:End()})
If Type("M->GM8_CODPLA ") # "U"
	If Empty(M->GM8_CODPLA) .And. Empty(M->GM8_CODPRO) .And. Empty(M->GM8_CODCRM)
		M->GM8_DESPLA := ""
		M->GM8_DESPRO := ""
		M->GM8_NOMCRM := ""
	EndIf
EndIf

RestArea(aArea)
Return()


Static Function FS_LISTPAC(dDatIni,dDatFim, cCodPac, cNomPac,aCpoGM8,aHeadGM8,aColsGM8,nUGM8,nCodCrm,oGDGM8, oSay,nGM8NomSal)
Local aArea := GetArea()
Local cCond := IIf(!Empty(cCodPac), " AND GM8.GM8_REGGER = '" + cCodPac + "'", "")
Local nI := 0
Local aLegFil :=  {{"GM8_STATUS == '0'", "BR_VERDE"},; //0=Orc. Pendente;1=Pend.Fin.\Nao Autoriz;2=Aprovado;3=Liberado;4=Cancelado;5=Em tratamento;6=Finalizado
					{"GM8_STATUS == '1'", "BR_VERMELHO"},;
					{"GM8_STATUS == '2'", "BR_AMARELO"},;
					{"GM8_STATUS == '3'", "BR_PINK"},;
					{"GM8_STATUS == '4'", "BR_AZUL"},;
					{"GM8_STATUS == '5'", "BR_LARANJA"},;
					{"GM8_STATUS == '7'", "BR_VIOLETA"}}

If Empty(dDatIni) .OR. Empty(dDatFim)
	HS_MSGINF(STR0164, STR0077,STR0095)//"Informe os filtros de Data Inicial e Final!"
	Return
EndIf
If dDatIni > dDatFim
	HS_MSGINF(STR0165, STR0077,STR0095) //"Inconsistências na Data Inicial e Final!"
	Return
EndIf
//

If !Empty(cNomPac)
	cCond += " AND GM8.GM8_NOMPAC LIKE '" + Alltrim(cNomPac) + "%' "
EndIf

aColsGM8 := {}
nUGM8 := 0
HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_REGGER <> '" + SPACE(TamSx3("GM8_REGGER")[1]) + "' AND GM8.GM8_DATAGE >= '" + DTOS(dDatIni) + "' AND GM8.GM8_DATAGE <= '" + DTOS(dDatFim) + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' " + cCond,,"GM8_STATUS",,,,,,,.F.,aLegFil,,,,, aCpoGM8, )

If Empty(aColsGM8[1,nCodCrm])
	aColsGM8[1,nNomCrm] := SPACE(TamSx3("GM8_NOMCRM")[1])
	oSay:SetText(STR0163 + " 0")//"Total de horários: "
Else
	oSay:SetText(STR0163 + Alltrim(Str(Len(aColsGM8))))//"Total de horários: "
	For nI := 1 To Len(aColsGM8)
		If Empty(aColsGM8[nI, nGM8CodSal])
			aColsGM8[nI, nGM8NomSal] := Space( (TamSx3( "GM8_NOMSAL" )[1]) )
		EndIf
	Next nI
EndIf

oGDGM8:SetArray(aColsGM8)
oGDGM8:oBrowse:Refresh()

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_LIMPM54³ Autor ³ Saude     			³ Data ³ 20/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpa as variaveis de tela					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SAUDE     		                        				  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_LIMPM54()

M->GM8_REGGER 	:= Space( (TamSx3( "GM8_REGGER" )[1]) )
cGbhCodPac		:= M->GM8_REGGER
M->GM8_MATRIC 	:= Space( (TamSx3( "GM8_MATRIC" )[1]) )
M->GM8_NOMPAC 	:= Space( (TamSx3( "GM8_NOMPAC" )[1]) )
M->GM8_TELPAC 	:= Space( (TamSx3( "GM8_TELPAC" )[1]) )
M->GM8_CODPLA 	:= Space( (TamSx3( "GM8_CODPLA" )[1]) )
M->GM8_DESPLA 	:= Space( (TamSx3( "GM8_DESPLA" )[1]) )

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M54CAN º Autor ³ANDREIA JOSEFA DA SILVA º Data ³  16.03.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ TELA DE CANCELAMENTO DE CONSULTA                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar M29                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_M54CAN(cAlias,nReg,nOpc,cCodPac,cCodAge,aCpoGM8,aHeadGM8,aColsGM8,nUGM8,nCodCrm,oGDGM8, oSay,nGM8NomSal)

Local oDlgCan   := nil
Local oEnc      := nil
Local lRet      := .T.
Local aArea     := GetArea()
Local cTitulo   := "Cancela horario agendado."
Local aCpoCan   := {}
Local aCoord    := {015,003,125,275} //L C A L Define as coordenadas do cabecalho do Agendamento
Local nOp       := 0
Local lHelp     := .F.
Local nPosAge   := 0, nIteAge := 0
Local cSeq		:= ""

Local cF3 		:= HS_CfgSx3("GM8_MOTIVO")[SX3->(FieldPos("X3_F3"))]
Local cValid :=	HS_CfgSx3("GM8_MOTIVO")[SX3->(FieldPos("X3_VALID"))]
Local cValidO :=	HS_CfgSx3("GM8_ORICAN")[SX3->(FieldPos("X3_VALID"))]
Local oMotivo
Local oNomMot
Local cNomMot
Local cOrigem :=HS_CfgSx3("GM8_ORICAN")[SX3->(FieldPos("X3_CBOX"))]
Local oOri

lOCAL oObsPlano
Local cDescMot:=""
Local nTam	:=20
Local  aGE5CBox :={"","0=Medico","1=Paciente","2=Empresa"}


RegToMemory("GM8",nOpc==3)

aGets    := {}
aTela    := {}

If Empty(oGDGM8:aCols[oGDGM8:nAt,nCodCrm])
	HS_MsgInf(OemToAnsi("Não existe registros para serem Processados"), STR0077, STR0073)  //"Atençã o"###"Agendamento Ambulatorial"
	Return()
Endif



DEFINE MSDIALOG oDlgCan TITLE OemToAnsi(cTitulo)  From 002,000 to 380,750 of oMainWnd PIXEL


@020+nTam, 20 Say "Origem Canc."   Of oDlgcAN Pixel COLOR CLR_BLUE
@020+nTam, 60 MsComboBox oOri VAR M->GM8_ORICAN VALID &cValidO ITEMS aGE5CBox SIZE 50, 050  PIXEL OF oDlgcAN

@035+nTam, 20 Say "Motivo" Of oDlgCan Pixel COLOR CLR_BLUE 
@035+nTam, 60 MSGet oMotivo Var M->GM8_MOTIVO VALID &cValid  F3 "GM7" Picture "@!" Size 50, 010 Of oDlgCan Pixel Color CLR_BLACK

@050+nTam, 20 Say "Desc Motivo"  Of oDlgCan Pixel COLOR CLR_BLUE 
@050+nTam, 60 MSGet oNomMot Var cDescMot:=If(!Empty(M->GM8_MOTIVO),Posicione("GM7",1,xFilial("GM7")+M->GM8_MOTIVO, "GM7_DESCAN")," ") when .F.   Size 150, 010 Of oDlgCan Pixel Color CLR_BLACK

@065+nTam,20 Say "Observação" Of oDlgcAN Pixel  COLOR CLR_BLUE 
@065+nTam,60 Get oObsPlano Var M->GM8_OBSERV MEMO SIZE 250 , 80 OF oDlgcAN Pixel





ACTIVATE MSDIALOG oDlgCan CENTERED ON INIT EnchoiceBar(oDlgCan, {|| nOp := 1, oDlgCan:End()}, {|| nOp := 0, oDlgCan:End()},,/*aButtons*/ )

If nOp == 0 //fechar
	RestArea(aArea)
	Return(NIL)
EndIf

If nOpc==3 //Cancelar
	
	DbSelectArea("GM8")
	DbSetOrder(1)

	If DbSeek(xFilial("GM8") + oGDGM8:aCols[oGDGM8:nAt,cCodAge])

	
	
	If GM8->GM8_STATUS == "3" //Horario Atendido
		cMsgAge := STR0063 //"O Horario selecionado ja foi atendido"
		lHelp   := .T.
		
	Else
		cMsgAge := STR0050 + aRotina[nOpc, 1] + STR0051 //"Não será possível " ### " o Horario selecionado na Agenda"
		
		If !(GM8->GM8_STATUS $ "1/4/5")
			lHelp := .T.
		EndIf
		
		If GM8->GM8_DATAGE < dDataBase
			cMsgAge += STR0052 //", com Data retroativa "
			lHelp   := If(lHelp,lHelp,.T.)
		EndIf
		
		If (GM8->GM8_DATAGE == dDataBase) .And. (GM8->GM8_HORAGE < SubStr(Time(),1,5))
			cMsgAge += STR0053 //", pois o Horário já foi expirado"
			lHelp   := If(lHelp,lHelp,.T.)
		EndIf
		
	EndIf
	
	If lHelp
		HS_MsgInf(OemToAnsi(cMsgAge), STR0077, STR0073)  //"Atenção"###"Agendamento Ambulatorial"
		RestArea(aArea)
		Return(NIL)
	EndIf
	
EndIf



If nOp == 1
	M54CAgd(oGDGM8:aCols[oGDGM8:nAt,cCodAge],M->GM8_MOTIVO,@cSeq)
	MsgInfo := cSeq
EndIf


aColsGM8 := {}
nUGM8 := 0

If !Empty(cCodPac)
	HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_REGGER == '" + cCodPac + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_DATAGE >= '" + DTOS(dDataBase) + "' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' ",,"GM8_STATUS",/*"GM9_DATAGE/GM9_HORAGE/GM9_CODCRM/GM9_NOMCRM/GM9_CODLOC/GM9_LOCDES/GM9_CODDIS/GM9_DESDIS/GM9_CODREC/GM9_CODSAL/GM9_NOMSAL"*/,,,,,,.F.,aLegCam,,,,, aCpoGM8,)
Else
	HS_BDados("GM8", @aHeadGM8, @aColsGM8,@nUGM8, 1,, " GM8.GM8_REGGER <> '" + SPACE(TamSx3("GM8_REGGER")[1]) + "' AND GM8.GM8_DATAGE >= '" + DTOS(dDataBase) + "' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILIAL = '" + xFilial("GM8") + "' ",,"GM8_STATUS",/*"GM9_DATAGE/GM9_HORAGE/GM9_CODCRM/GM9_NOMCRM/GM9_CODLOC/GM9_LOCDES/GM9_CODDIS/GM9_DESDIS/GM9_CODREC/GM9_CODSAL/GM9_NOMSAL"*/,,,,,,.F.,aLegCam,,,,, aCpoGM8,)
EndIf

oGDGM8:SetArray(aColsGM8)
oGDGM8:oBrowse:Refresh()

Endif
RestArea(aArea)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VldUsPrºAutor  ³Microsiga           º Data ³  17/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_VldUsPr(cCodLoc)
Local lRetPro    := .F.
Local lRetEnc    := .T.
Local lRetEve    := .F.
                                            
DbSelectArea("GM1")
DbSetOrder(1) 

If  DbSeek(xFilial("GM1") + cCodLoc + cUserName)
	If GM1->GM1_USPROM == "1"
		lRetPro := .T.
	Endif
	
	If (GM1->GM1_ENCAIX == "1" .or. Empty(GM1->GM1_ENCAIX))
		lRetEnc := .T.
	Else
		lRetEnc := .F.
	Endif

	If GM1->GM1_EVENTO == "1"
		lRetEve := .T.
	Endif
	
	
EndIf

Return({lRetPro,lRetEnc,lRetEve})
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_VldProc  ºAutor  ³Microsiga          º Data ³  11/09/2014º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o Procedimento que esta sendo agendado no HSP	 º±±
±±º          ³ é da promoção da Saude.								  			 º±±
±±º          ³ se o Procedimento for da Promoção da Saude o sistema 		 º±±
±±º          ³só irá permitir o agendamento para Paciente da Promoção		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FS_VldProc(cCodProc,cRegger)
Local cMatVid 		:= "" 
Local lRet			:=.F.
Local aArea 		:= GetArea()
DEFAULT cCodProc	:=""
DEFAULT cRegger	:=""


DbSelectArea("GA7")
DbSetOrder(1)
If DbSeek(xFilial("GA7") + cCodProc)
	If GA7->GA7_PROMOC == "1"
		cMatVid :=	PLSRTVID(cRegger)
		dbSelectArea("BOM")
		dbSetOrder(3)//BOM_FILIAL, BOM_VIDA, BOM_STATUS, R_E_C_N_O_, D_E_L_E_T_

		DbSeek(xFilial("BOM")+cMatVid)
		While BOM->(! EOF() .And. BOM->(BOM_FILIAL) + BOM->(BOM_VIDA) == ;
		xFilial("BOM")+cMatVid)		
			If (BOM->BOM_STATUS == "1" .OR. BOM->BOM_STATUS == "3")
				DbSelectArea("BOA")
				DbSetOrder(1)
				If DbSeek(xFilial("BOA")  + BOM->BOM_CODPRO)
					iF BOA->BOA_CONPAD== GA7->GA7_PROPLS
						lRet 	:= .T.
					Else
						lRet := .F.
					Endif
				Else
					lRet := .F.
				Endif          
			Endif				
		 BOM->(dbskip())
		Enddo	
	
	Else
	lRet := .T.	
	EndIf       
Else
	lRet := .T.	
Endif
	
restArea(aArea)
Return(lRet)
