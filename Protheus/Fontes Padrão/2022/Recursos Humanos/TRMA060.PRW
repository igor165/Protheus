#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TRMA060.CH"
#INCLUDE "COLORS.CH"

Static cVision  := SuperGetMv("MV_APDVIS") 				// visão utilizada
Static cTypeOrg := SuperGetMV("MV_ORGCFG",,"0") 			// Configuração do modo de uso do SIGAORG.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ TRMA060  ³ Autor ³ Cristina Ogura        ³ Data ³ 12.11.98         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Reserva de Treinamentos                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ TRMA060                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS         ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car. ³21.07.14³TPZSOX        ³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³             ³        ³              ³a limpeza.                                  ³±±
±±³Cícero Alves ³21/10/15³TTPJMJ        ³Alterações para que a rotina possa ser 	 ³±±
±±³             ³        ³              ³executada via execauto                      ³±±
±±³Isabel N.    ³08/02/17³MRH-3233      ³ Ajuste no nome do campo RA2_REALIZA para   ³±±
±±³             ³        ³              ³ RA2_REALIZ, conforme cadastrado no Atusx.  ³±±
±±³Oswaldo L.   ³03/04/17³DRHPONTP-9    ³Projeto cTree                               ³±±
±±³Willian U.   ³09/08/17³DRHPONTP-1168 ³Ajuste para validar o parâmetro criado      ³±±
±±³             ³        ³              ³MV_TRMMAIL para verificar se enviará email  ³±±
±±³             ³        ³              ³aos funcionários ao realizar uma baixa de   ³±±
±±³             ³        ³              ³treinamento.                                ³±±
±±³Oswaldo L.   ³08/09/17³DRHPONTP-1686 ³Ajuste para Pesquisar por semelhança        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMA060(aCab, aItens, nOpc)

LOCAL cFiltra	:= ""	//Variavel para filtro
LOCAL aIndFil	:= {}	//Variavel Para Filtro
Local aCores    := {}
Local aAuxCor   := {}
Local _nX       := 0

Default aCab		:= {}
Default aItens		:= {}
Private lEmail		:= .F.
Private lAutoExec	:= Len(aCab) > 0 .AND. Len(aItens) > 0 .AND. vldAuto(aCab, aItens) .AND. nOpc > 0

Private aAvFields	:= {} //campos exibidos em tela a serem avaliados pelo gerenciamento de dados sensiveis
Private aPDFields	:= {} //campos que estao classificados como dados sensiveis
Private aOfuscaCpo	:= {}
Private aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Private nX			:= 0
Private nPos		:= 0

Private bFiltraBrw	:= {|| Nil}		//Variavel para Filtro
Private aLegenda	:={}
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
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0004)		//"Reserva de Treinamentos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA2")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA2","1")
bFiltraBrw 	:= {|| FilBrowse("RA2",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

aAdd(aCores, {'RA2->RA2_REALIZ != "S"', "ENABLE"	  , ""}) //"Em Aberto"
aAdd(aCores, {'RA2->RA2_REALIZ == "S"', "BR_VERMELHO", ""}) //"Encerrado"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definiao de cores por usuarios      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TRM060LEG")
	aAuxCor := ExecBlock("TRM060LEG",.F.,.F.,{aCores} )
	If ValType(aAuxCor) == "A" .AnD. Len(aAuxCor) > 0
		aCores    := {}
		aLegenda  := {}
		For _nX := 1 To Len(aAuxCor)
			aAdd(aCores,   {aAuxCor[_nX,1], aAuxCor[_nX,2]})
			aAdd(aLegenda, {aAuxCor[_nX,2], If(Empty(aAuxCor[_nX,3]), "-", aAuxCor[_nX,3])})
		Next _nX
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA2")
dbGoTop()

If !lAutoExec
	mBrowse(6, 1, 22, 75, "RA2",,,,,,aCores)
Else
	Tr060Rot(, , , aCab, aItens, nOpc)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA2",aIndFil)

dbSelectArea("RA3")
dbSetOrder(1)

dbSelectArea("RA2")
dbSetOrder(1)

dbSelectArea("SRA")
dbSetOrder(1)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr060Rot  ³ Autor ³ Cristina Ogura       ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a Reserva de treinamentos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA060       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060Rot(cAlias, nReg, nOpcx, aCab, aItens, nOpc)

Local oDlgMain, oGroup, oGroup1, oGroup2, oGroup3, oGroup4
Local oBtn1, oBtn2, oBtn3, oSay1
Local oReserva, oLista, oSolic
Local oOk, oNo, o1Ok
Local nx, nI		:= 0
Local aAux			:= {}
Local cCurso		:= ""
Local cTurma		:= ""
Local cCalend 		:= ""
Local cDescCalend	:= ""
Local cDescCurso	:= CriaVar("RA1_CURSO")
Local cPerg
Local lReserva		:= .F.
Local lLista		:= .F.
Local lSolic		:= .F.
Local oSelFunc, oSelSolic
Local lSelFunc 		:= .F.
Local lSelSolic 	:= .F.
Local c1Lbx			:= ""
Local c2Lbx			:= ""
Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local aSaveArea		:= GetArea()
Local cFiltro		:= ""
Local oBmp1, oBmp2, oBmp3
Local oVerde, oAmarelo, oVermelho, oAzul, oMarrom
Local oFont

// Variaveis de Pesquisa
Local oFilial, oNome
Local oMatr
Local cFilPesq	:= xFilial("SRA")
Local cNomPesq	:= Space(TamSx3("RA_NOME")[1])
Local cMatrPesq	:= Space(TamSx3("RA_MAT")[1])
Local lRet		:= .F.
Local RA2Filial := ""

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAdv22Size	:= {}
Local aInfo22AdvSize:= {}
Local aObj22Size	:= {}
Local aObj22Coords	:= {}

Local aAdv23Size	:= {}
Local aInfo23AdvSize:= {}
Local aObj23Size	:= {}
Local aObj23Coords	:= {}

Local aAdv24Size	:= {}
Local aInfo24AdvSize:= {}
Local aObj24Size	:= {}
Local aObj24Coords	:= {}

Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords	:= {}

Local aAdv41Size	:= {}
Local aInfo41AdvSize:= {}
Local aObj41Size	:= {}
Local aObj41Coords	:= {}

Local aAdv32Size	:= {}
Local aInfo32AdvSize:= {}
Local aObj32Size	:= {}
Local aObj32Coords	:= {}

Private cLista	:= ""
Private cSolic	:= ""
Private cArq1	:= ""
Private cArq2	:= ""
Private cArq3	:= ""
Private cArq4	:= ""

Private cArqNtx	:= ""
Private cReserv	:= StrZero(RA2->RA2_RESERV,4)
Private cVagas	:= StrZero(RA2->RA2_VAGAS,4)
Private a2Lbx	:= {}
Private aVerif 	:= {}
Private aRecRA3 := {}
Private oSay2, oSay3, oSay4
Private o1Lbx, o2Lbx

// Perguntas
Private cFilDe	:= ""
Private cFilAte	:= ""
Private cMatDe	:= ""
Private cMatAte	:= ""
Private cCCDe	:= ""
Private cCCAte	:= ""
Private cFunDe	:= ""
Private cFunAte	:= ""
Private nOrdem	:= 1
Private cGruDe	:= ""
Private cGruAte	:= ""
Private cDepDe	:= ""
Private cDepAte	:= ""
Private cEmail	:= ""
Private cObs1	:= ""
Private cObs2	:= ""
Private cObs3	:= ""
Private cObs4	:= ""
Private cObs5	:= ""
Private cObs6	:= ""
Private cSituacao := ""
Private cTurnoDe:= ""
Private cTurnoAt:= ""
Private nSolFunc:= 0

Private lMantem := .F. //Mantem a reserva efetuada anteriormente em caso de RA2 compartilhado, conforme decisao do usuario
Private oTmpTR1

If ! lAutoExec

	cCurso		:= RA2->RA2_CURSO
	cTurma		:= RA2->RA2_TURMA
	cCalend 	:= RA2->RA2_CALEND
	cDescCalend	:= RA2->RA2_DESC

	If RA2->RA2_REALIZ == "S"
		Help("",1,"TRA070BAIX")			// Este curso ja foi baixado
		RestArea(aSaveArea)
		Return
	EndIf
Else
	cCurso		:= aCab[aScan( aCab, { |x| AllTrim(x[1]) == "RA2_CURSO"  })][2]
	cTurma		:= aCab[aScan( aCab, { |x| AllTrim(x[1]) == "RA2_TURMA"  })][2]
	cCalend 	:= aCab[aScan( aCab, { |x| AllTrim(x[1]) == "RA2_CALEND" })][2]
	lEmail		:= aCab[aScan( aCab, { |x| AllTrim(x[1]) == "RA2_MAIL" 	 })][2]
	RA2Filial	:= aCab[aScan( aCab, { |x| AllTrim(x[1]) == "RA2_FILIAL" })][2]
	dbSelectArea("RA2")
	dbSetOrder(1)

	If dbSeek( RA2Filial + cCalend + cCurso + cTurma)
		If RA2->RA2_REALIZ == "S"
			Help("",1,"TRA070BAIX")			// Este curso ja foi baixado
			lMsErroAuto := .T.
		EndIf
	Else
		lMsErroAuto := .T.
		Help("",1,"TRMA060CURSO") // Curso não cadastrado
	EndIf

	cReserv	:= StrZero(RA2->RA2_RESERV,4)
	cVagas	:= StrZero(RA2->RA2_VAGAS,4)

EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// MV_PAR01		- Filial De
// MV_PAR02		- Filial Ate
// MV_PAR03		- Matricula de
// MV_PAR04		- Matricula ate
// MV_PAR05		- Centro Custo de
// MV_PAR06		- Centro Custo ate
// MV_PAR07		- Funcao de
// MV_PAR08		- Funcao ate
// MV_PAR09     - Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
// MV_PAR10		- Grupo De
// MV_PAR11     - Grupo Ate
// MV_PAR12		- Depto De
// MV_PAR13		- Depto Ate
// MV_PAR14		- Email Confirmacao
// MV_PAR15		- Obs 1
// MV_PAR16		- Obs 2
// MV_PAR17		- Obs 3
// MV_PAR18		- Obs 4
// MV_PAR19		- Obs 5
// MV_PAR20		- Obs 6
// MV_PAR21     - Situacoes
// MV_PAR22     - Ferias Programadas
// MV_PAR23		- Turno de
// MV_PAR24 	- Turno ate

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Treinamento esta exclusivo e nao permite a selecao de funcionario³
//³ de outra filial.															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FWModeAccess("RA2",1) == "C" .or. FWModeAccess("RA2",2) == "C" .or. FWModeAccess("RA2",3) == "C"
	cPerg:= "TRM060"
Else
	cPerg:= "TRM06001"
Endif

Pergunte(cPerg,.F.)

AADD(aSays,OemToAnsi(STR0060) )  //"Este programa permite a Reserva de funcionarios"
AADD(aSays,OemToAnsi(STR0061) )  //"para participacao de Treinamento."

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, {17,.T.,{|| cFiltro := BuildExpr("SRA",,cFiltro)}} ) //Filtro
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}} )
AADD(aButtons, { 2,.T.,{|o| nOpca := 0,FechaBatch()}} )

If ! lAutoExec
	FormBatch( cCadastro, aSays, aButtons )
EndIf

If nOpca == 0 .AND. ! lAutoExec
	RestArea(aSaveArea)
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Treinamento esta exclusivo e nao permite a selecao de funcionario³
//³ de outra filial. Sera assumida a filial do calendario						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FWModeAccess("RA2",3) == "E" .AND. ! lAutoExec
	cFilAte		:= RA2->RA2_FILIAL
	cFilDe		:= RA2->RA2_FILIAL
	cMatDe		:= MV_PAR01
	cMatAte		:= MV_PAR02
	cCCDe		:= MV_PAR03
	cCCAte		:= MV_PAR04
	cFunDe		:= MV_PAR05
	cFunAte		:= MV_PAR06
	nOrdem		:= MV_PAR07
	cGruDe		:= MV_PAR08
	cGruAte		:= MV_PAR09
	cDepDe		:= MV_PAR10
	cDepAte		:= MV_PAR11
	cEmail		:= MV_PAR12
	cObs1		:= MV_PAR13
	cObs2		:= MV_PAR14
	cObs3		:= MV_PAR15
	cObs4		:= MV_PAR16
	cObs5		:= MV_PAR17
	cObs6		:= MV_PAR18
	cSituacao	:= MV_PAR19
	nFerProg 	:= MV_PAR20
	cSitFol  	:= ""
	cTurnoDe	:= MV_PAR21
	cTurnoAt	:= MV_PAR22
	nSolFunc	:= MV_PAR23

	//Retirar posteriormente, junto com a retirada do COLUMNPOS
	If len(TamSX1(cPerg,"23")) == 0
		nSolFunc	:= 0
	EndIf

ELseIf lAutoExec

	If FWModeAccess("RA2",3) == "E"
		cFilAte		:= RA2->RA2_FILIAL
		cFilDe		:= RA2->RA2_FILIAL
	Else
	 	cFilAte		:= Replicate("Z", 11)
		cFilDe		:= Space(11)
	EndIf

	cMatDe		:= Space(6)
	cMatAte		:= Replicate("Z", 6)
	cCCDe		:= space(9)
	cCCAte		:= Replicate("Z", 9)
	cFunDe		:= Space(5)
	cFunAte		:= Replicate("Z", 5)
	nOrdem		:= 2
	cGruDe		:= Space(2)
	cGruAte		:= Replicate("Z", 2)
	cDepDe		:= Space(9)
	cDepAte		:= Replicate("Z", 9)
	cEmail		:= Iif(lEmail, "LRS", "***")
	cObs1		:= ""
	cObs2		:= ""
	cObs3		:= ""
	cObs4		:= ""
	cObs5		:= ""
	cObs6		:= ""
	cSituacao	:= " ADFT"
	nFerProg 	:= 1
	cSitFol  	:= ""
	cTurnoDe	:= Space(3)
	cTurnoAt	:= Replicate("Z", 3)

ELse
	cFilDe		:= MV_PAR01
	cFilAte		:= MV_PAR02
	cMatDe		:= MV_PAR03
	cMatAte		:= MV_PAR04
	cCCDe		:= MV_PAR05
	cCCAte		:= MV_PAR06
	cFunDe		:= MV_PAR07
	cFunAte		:= MV_PAR08
	nOrdem		:= MV_PAR09
	cGruDe		:= MV_PAR10
	cGruAte		:= MV_PAR11
	cDepDe		:= MV_PAR12
	cDepAte		:= MV_PAR13
	cEmail		:= MV_PAR14
	cObs1		:= MV_PAR15
	cObs2		:= MV_PAR16
	cObs3		:= MV_PAR17
	cObs4		:= MV_PAR18
	cObs5		:= MV_PAR19
	cObs6		:= MV_PAR20
	cSituacao	:= MV_PAR21
	nFerProg 	:= MV_PAR22
	cSitFol  	:= ""
	cTurnoDe	:= MV_PAR23
	cTurnoAt	:= MV_PAR24
	nSolFunc	:= MV_PAR25

	//Retirar posteriormente, junto com a retirada do COLUMNPOS
	If len(TamSX1(cPerg,"25")) == 0
		nSolFunc	:= 0
	EndIf
Endif

oOk 	 := LoadBitmap( GetResources(), "Enable" )
oNo 	 := LoadBitmap( GetResources(), "LBNO" )
o1Ok 	 := LoadBitmap( GetResources(), "LBOK" )

oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
oAmarelo := LoadBitmap( GetResources(), "BR_AMARELO" )
oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
oAzul	 := LoadBitmap( GetResources(), "BR_AZUL" )
oMarrom  := LoadBitmap( GetResources(), "BR_MARROM" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Curso                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA1")
dbSetOrder(1)
If dbSeek(xFilial("RA1")+cCurso)
	cDescCurso := RA1->RA1_DESC
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria arquivos temporarios para o Listbox                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tr060CriaArq()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta os dados dos ListBox                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lAutoExec

	Processa({||lRet:=Tr060Monta(cAlias,cCurso,cTurma,cCalend,cFiltro, RA2->RA2_FILIAL)},OemToAnsi(STR0050)+OemToAnsi(STR0049)) //"Aguarde..."###" Montando tela de Reserva"


	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta as Dimensoes dos Objetos         					     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= {aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 5}
		aAdd( aObjCoords , { 000, 022 , .T. , .F. } )
		aAdd( aObjCoords , { 000, 000 , .T. , .T. } )
		aAdd( aObjCoords , { 000, 024 , .T. , .F. } )
		aAdd( aObjCoords , { 000, 024 , .T. , .F. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		//Divisão em 3 colunas a linha 1
		aAdv1Size		:= aClone(aObjSize[1])
		aInfo1AdvSize	:= {aAdv1Size[2], aAdv1Size[1], aAdv1Size[4], aAdv1Size[3], 1, 1}
		aAdd( aObj1Coords , { 120, 000 , .F. , .T. } )		//1-Curso
		aAdd( aObj1Coords , { 000, 000 , .T. , .T. } )		//2-Calendario
		aAdd( aObj1Coords , { 040, 000 , .F. , .T. } )		//3-Turma
		aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

		//Divisão em 2 colunas a linha 2
		aAdv2Size		:= aClone(aObjSize[2])
		aInfo2AdvSize	:= {aAdv2Size[2], aAdv2Size[1], aAdv2Size[4], aAdv2Size[3], 1, 1}
		aAdd( aObj2Coords , { 000, 000 , .T. , .T. , .T. } )	//1-Funcionarios a realizar Curso
		aAdd( aObj2Coords , { 000, 000 , .T. , .T. } )			//2-Vagas / Funcionarios Reservados p/ Curso
		aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

		//Divisão Coluna 2 da Linha 2-Vagas Funcionarios Reservados p/ Curso
		aAdv22Size		:= aClone(aObj2Size[2])
		aInfo22AdvSize	:= {aAdv22Size[2], aAdv22Size[1], aAdv22Size[4], aAdv22Size[3], 1, 0}
		aAdd( aObj22Coords , { 000, 030 , .T. , .F. } )			//1-Vagas
		aAdd( aObj22Coords , { 000, 005 , .T. , .F. } )			//2-Espaco
		aAdd( aObj22Coords , { 000, 000 , .T. , .T. , .T. } )		//3-Funcionarios Reservados p/ Curso
		aObj22Size		:= MsObjSize( aInfo22AdvSize , aObj22Coords )

		//Divisão da Linha 1-Vagas em 2 linhas
		aAdv23Size		:= aClone(aObj22Size[1])
		aInfo23AdvSize	:= {aAdv23Size[2], aAdv23Size[1], aAdv23Size[4], aAdv23Size[3], 1, 10}
		aAdd( aObj23Coords , { 000, 000 , .T. , .T. } )		//1-Linha 1 Vaga
		aAdd( aObj23Coords , { 000, 000 , .T. , .T. } )		//2-Linha 2 Vaga
		aObj23Size		:= MsObjSize( aInfo23AdvSize , aObj23Coords )

		//Divisão da Linha 1-Vagas em 5 colunas
		aAdv24Size		:= aClone(aObj23Size[1])
		aInfo24AdvSize	:= {aAdv24Size[2], aAdv24Size[1], aAdv24Size[4], aAdv24Size[3], 5, 10}
		aAdd( aObj24Coords , { 037, 000 , .F. , .T. } )		//1-Say Descricao
		aAdd( aObj24Coords , { 035, 000 , .F. , .T. } )		//2-Say Total
		aAdd( aObj24Coords , { 010, 000 , .F. , .T. } )		//3-Espaco
		aAdd( aObj24Coords , { 037, 000 , .F. , .T. } )		//2-Say Descricao
		aAdd( aObj24Coords , { 035, 000 , .F. , .T. } )		//2-Say Total
		aObj24Size		:= MsObjSize( aInfo24AdvSize , aObj24Coords,, .T. )


		//Divisão em 2 colunas a linha 3 - Coord usada tb na linha 4
		aAdv3Size		:= aClone(aObjSize[3])
		aInfo3AdvSize	:= {aAdv3Size[2], aAdv3Size[1], aAdv3Size[4], aAdv3Size[3], 5, 5}
		aAdd( aObj3Coords , { 000, 000 , .T. , .T.  } )		//1-
		aAdd( aObj3Coords , { 000, 000 , .T. , .T. } )			//2-
		aObj3Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords,,.T. )

		//Divisão Linha 4 - Coluna 1 - Em 2 checkboxes
		aAdv41Size		:= aClone(aObj3Size[1])
		aInfo41AdvSize	:= {aAdv41Size[2], aAdv41Size[1], aAdv41Size[4], aAdv41Size[3], 5, 5}
		aAdd( aObj41Coords , { 000, 000 , .T. , .T. , .T. } )		//1- Sem Solicitacao
		aAdd( aObj41Coords , { 000, 000 , .T. , .T. , .T. } )		//2- Com Solicitacao
		aObj41Size		:= MsObjSize( aInfo41AdvSize , aObj41Coords,,.T. )

		//Divisão Linha 3 - Coluna 2 - Em 3 checkboxes
		aAdv32Size		:= aClone(aObj3Size[2])
		aInfo32AdvSize	:= {aAdv32Size[2], aAdv32Size[1], aAdv32Size[4], aAdv32Size[3], 5, 5}
		aAdd( aObj32Coords , { 000, 000 , .T. , .T. , .T. } )		//1- Reservar
		aAdd( aObj32Coords , { 000, 000 , .T. , .T. , .T. } )		//2- Lista Espera
		aAdd( aObj32Coords , { 000, 000 , .T. , .T. , .T. } )		//3- Solicitar
		aObj32Size		:= MsObjSize( aInfo32AdvSize , aObj32Coords,,.T. )

		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

		DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL
			@ aObj1Size[1,1], aObj1Size[1,2]		GROUP oGroup	TO aObj1Size[1,3], aObj1Size[1,4] PROMPT OemToAnsi(STR0005)	OF oDlgMain	PIXEL			//"Calend rio: "
			@ aObj1Size[1,1]+10, aObj1Size[1,2]+5	SAY cCalend + " - " + cDescCalend PIXEL
			oGroup:oFont:= oFont

			@ aObj1Size[2,1], aObj1Size[2,2]		GROUP oGroup	TO aObj1Size[2,3], aObj1Size[2,4] PROMPT OemToAnsi(STR0006)	OF oDlgMain	PIXEL			//Curso: "
			@ aObj1Size[2,1]+10, aObj1Size[2,2]+5	SAY cCurso + " - " + Subst(cDescCurso,1,20) PIXEL
			oGroup:oFont:= oFont

			@ aObj1Size[3,1], aObj1Size[3,2]		GROUP oGroup 	TO aObj1Size[3,3], aObj1Size[3,4] PROMPT OemToAnsi(STR0007) OF oDlgMain PIXEL			//Turma: "
			@ aObj1Size[3,1]+8, aObj1Size[3,2]+5	SAY cTurma PIXEL
			oGroup:oFont:= oFont


			@ aObj22Size[1,1], aObj22Size[1,2]		GROUP oGroup	TO aObj22Size[1,3], aObj22Size[1,4] PROMPT OemToAnsi(STR0008) OF oDlgMain PIXEL		//"Vagas:"
			oGroup:oFont:= oFont

			@ aObj23Size[1,1], aObj24Size[1,2] SAY OemToAnsi(STR0077)		PIXEL			//"Disponível:"
			@ aObj23Size[1,1], aObj24Size[2,2] SAY oSay1 PROMPT cVagas	PIXEL

			@ aObj23Size[2,1], aObj24Size[1,2] SAY OemToAnsi(STR0009)		PIXEL			//"R=Reservas:"
			@ aObj23Size[2,1], aObj24Size[2,2] SAY oSay2 PROMPT cReserv	PIXEL

			@ aObj23Size[1,1], aObj24Size[4,2] SAY OemToAnsi(STR0010)		PIXEL			//"L=Lista Esp:"
			@ aObj23Size[1,1], aObj24Size[5,2] SAY oSay3 PROMPT cLista	PIXEL

			@ aObj23Size[2,1], aObj24Size[4,2] SAY OemToAnsi(STR0011)		PIXEL			//"S=Solicitar:"
			@ aObj23Size[2,1], aObj24Size[5,2] SAY oSay4 PROMPT cSolic	PIXEL


			@ aObj2Size[1,1], aObj2Size[1,2] LISTBOX o1Lbx VAR c1Lbx FIELDS;
				 	 HEADER 	"",;
				 	            	OemtoAnsi(STR0066),;			//"Sit."
									OemtoAnsi(STR0012),;			//"R"
									OemtoAnsi(STR0013),;			//"L"
									OemtoAnsi(STR0014),;			//"S"
									OemtoAnsi(STR0088),;			//"P"
									OemtoAnsi(STR0089),;			//"G"
									OemtoAnsi(STR0015),;			//"C"
									OemtoAnsi(STR0016),;			//"Fil."
									OemtoAnsi(STR0017),;			//"Nome"
									OemtoAnsi(STR0018),;			//"Matricula"
									OemtoAnsi(STR0019),;			//"Centro Custo"
									OemtoAnsi(STR0020),;			//"Descr. Centro Custo"
									OemtoAnsi(STR0021),;			//"Fun‡„o "
									OemtoAnsi(STR0022);				//"Descr. Fun‡„o"
						COLSIZES GetTextWidth(0,"W"),;
									GetTextWidth(0,"W"),;
									GetTextWidth(0,"W"),;
									GetTextWidth(0,"W"),;
									GetTextWidth(0,"W"),;
									GetTextWidth(0,"W"),;
									GetTextWidth(0,"W"),;
									GetTextWidth(0,"W"),;
									GetTextWidth(0, Replicate("B", FWGETTAMFILIAL)),;
									GetTextWidth(0, Replicate("B", 30)),;
									GetTextWidth(0, Replicate("B", 6)),;
									GetTextWidth(0, Replicate("B", 9)),;
									GetTextWidth(0, Replicate("B", 30)),;
									GetTextWidth(0, Replicate("B", 4)),;
									GetTextWidth(0, Replicate("B", 30)),;
						SIZE aObj2Size[1,3], aObj2Size[1,4];
						OF oDlgMain PIXEL;
						ON DBLCLICK (Tr060L1())

			o1Lbx:nFreeze := 2

			o1Lbx:bLine   := {||{If(TR1->TR1_MARCA==2,o1Ok,oNo),;
									If( TR1->TR1_SITFOL==" ",oVerde, (Iif(TR1->TR1_SITFOL=="D",oVermelho,(Iif(TR1->TR1_SITFOL=="A", oAmarelo,(Iif(TR1->TR1_SITFOL=="F",oAzul,oMarrom))))))),;
									If(TR1->TR1_RESERV==2,oOk,oNo),;
									If(TR1->TR1_LISTA==2,oOk,oNo),;
									If(TR1->TR1_SOLIC==2,oOk,oNo),;
									If(TR1->(ColumnPos("TR1_PORTAL")) > 0 .and. TR1->TR1_PORTAL$"G*F",oOk,oNo),;
									If(TR1->(ColumnPos("TR1_PORTAL")) > 0 .and. TR1->TR1_PORTAL=="G",oOk,oNo),;
									If(TR1->TR1_CONCL==2,oOk,oNo),;
										TR1->TR1_FILIAL,;
										TR1->TR1_NOME,;
										TR1->TR1_MAT,;
										TR1->TR1_CC,;
										TR1->TR1_DESCCC,;
										TR1->TR1_FUNCAO,;
										TR1->TR1_DESCFUN}}

			//Proteção de Dados Sensíveis
			If aOfusca[2]
				aOfuscaCpo := {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}
				aAvFields  := {" "," "," "," "," "," "," "," ","RA_FILIAL","RA_NOME","RA_MAT","RA_CC","RA_DESCCC","RA_CODFUNC","RA_DESCFUN"}
				aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList( aAvFields )
				o1Lbx:lObfuscate := .T.
				For nX := 1 to Len(aPDFields)
					nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
					aOfuscaCpo[nPos] := .T.
				Next nX
				o1Lbx:aObfuscatedCols := aOfuscaCpo
			EndIf

			@ aObj22Size[3,1], aObj22Size[3,2] LISTBOX o2Lbx FIELDS;
						HEADER	OemtoAnsi(STR0025),;	  					//"R"
								OemtoAnsi(STR0026),;						//"L"
								OemtoAnsi(STR0027),;						//"S"
								OemtoAnsi(STR0066),;						//"Sit.
								OemtoAnsi(STR0028),;						//"Nome"
								OemtoAnsi(STR0029),;						//"Matricula"
								OemtoAnsi(STR0030),;						//"Filial"
								OemtoAnsi(STR0031);							//"Lista Espera"
				 		SIZE aObj22Size[3,3], aObj22Size[3,4];
						OF oDlgMain PIXEL

			o2Lbx:bldblclick :={|nRow, nCol| Tr060Cl2(o2Lbx:nAt,o2Lbx:nRowPos,o2Lbx:nColPos)}
			o2Lbx:SetArray(a2Lbx)
			o2Lbx:nFreeze := 4
			o2Lbx:bLine:= {||{ 	If(a2Lbx[o2Lbx:nAt,1],o1Ok,oNo),;
										If(a2Lbx[o2Lbx:nAt,2],o1Ok,oNo),;
										If(a2Lbx[o2Lbx:nAt,3],o1Ok,oNo),;
										If(a2Lbx[o2Lbx:nAt,4]==" ",oVerde, (Iif(a2Lbx[o2Lbx:nAt,4]=="D" .Or. a2Lbx[o2Lbx:nAt,4]=="T",oVermelho,(Iif(a2Lbx[o2Lbx:nAt,4]=="A", oAmarelo,(Iif(a2Lbx[o2Lbx:nAt,4]=="F",oAzul,oMarrom))))))),;
											a2Lbx[o2Lbx:nAt,5],;
											a2Lbx[o2Lbx:nAt,6],;
											a2Lbx[o2Lbx:nAt,7],;
											a2Lbx[o2Lbx:nAt,8]}}

			//Proteção de Dados Sensíveis
			If aOfusca[2]
				aOfuscaCpo := {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}
				aAvFields  := {" "," "," "," ","RA_NOME","RA_MAT","RA_FILIAL"," "}
				aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList( aAvFields )
				o2Lbx:lObfuscate := .T.
				For nX := 1 to Len(aPDFields)
					nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
					aOfuscaCpo[nPos] := .T.
				Next nX
				o2Lbx:aObfuscatedCols := aOfuscaCpo
			EndIf


			@  aObjSize[3,1] , aObjSize[3,2] GROUP oGroup TO aObjSize[3,3] , aObj3Size[1,4] PROMPT OemtoAnsi(STR0023) OF oDlgMain	PIXEL	//" Seleciona / Nao Seleciona "
			@  aObjSize[3,1]+10 , aObjSize[3,2]+7 SAY OemtoAnsi(STR0024) SIZE 236,7 PIXEL	//"R=Reservado L=Lista Espera S=Solicitação P=Portal G=Gestor C=Concluido"
			oGroup:oFont:= oFont

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Selecao para Reserva de Func. p/ Treinamento com Solicitacao ou nao. 		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@  aObjSize[4,1] , aObjSize[4,2] GROUP oGroup TO aObjSize[4,3] , aObj3Size[1,4] PROMPT OemtoAnsi(STR0048) OF oDlgMain	PIXEL	//" Selecionar todos funcionarios: "
			oGroup:oFont:= oFont

			@  aObjSize[4,1]+12 , aObj41Size[1,2] CHECKBOX oSelFunc VAR lSelFunc PROMPT OemtoAnsi(STR0044) SIZE aObj41Size[1,3] , aObj41Size[1,4] OF oDlgMain PIXEL;	//" Sem Solicitacao "
				ON CLICK (If(MsgYesNo(OemtoAnsi(STR0046),OemtoAnsi(STR0035)),Tr060Sel(1),),;		//"Reservar todos funcionarios para o curso"###"Aten‡„o"
						lSelFunc:=.F.,oSelFunc:Refresh(.T.))

			@  aObjSize[4,1]+12 , aObj41Size[2,2] CHECKBOX oSelSolic VAR lSelSolic	PROMPT OemtoAnsi(STR0045) SIZE aObj41Size[2,3] , aObj41Size[2,4] OF oDlgMain PIXEL;	//" Com S-Solicitacao "
				ON CLICK (If(MsgYesNo(OemtoAnsi(STR0047),OemtoAnsi(STR0035)),Tr060Sel(2),),;		//"Reservar todos funcionarios para o curso"###"Aten‡„o"
						lSelSolic:=.F.,oSelSolic:Refresh(.T.))



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Marcar selecionados como:                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@  aObjSize[3,1] , aObj3Size[2,2] GROUP oGroup TO aObjSize[3,3], aObjSize[3,4] PROMPT OemtoAnsi(STR0032) OF oDlgMain PIXEL	//" Marcar todos os funcionarios selecionados como "
			@  aObj32Size[1,1],	aObj32Size[1,2] CHECKBOX oReserva VAR lReserva 	PROMPT OemtoAnsi(STR0033) SIZE aObj32Size[1,3],	aObj32Size[1,4] OF oDlgMain PIXEL;	//" Reservar "
			ON CLICK (If(MsgYesNo(OemtoAnsi(STR0034),OemtoAnsi(STR0035)),Tr060Marca(3,2,1),),;		//"Reservar todos os funcion rios selecionados para o curso"###"Aten‡„o"
						lReserva:=.F.,oReserva:Refresh(.T.),lLista:= .F.,oLista:Refresh(.T.),lSolic:= .F.,oSolic:Refresh(.T.))
			oReserva:oFont :=	oDlgMain:oFont
			oGroup:oFont:= oFont

			@  aObj32Size[2,1],	aObj32Size[2,2] CHECKBOX oLista   VAR lLista 	PROMPT OemtoAnsi(STR0036)  SIZE aObj32Size[2,3],	aObj32Size[2,4] OF oDlgMain PIXEL;	//" Lista Espera "
			ON CLICK (If(MsgYesNo(OemtoAnsi(STR0037),OemtoAnsi(STR0035)),Tr060Marca(3,1,2),),;		//"Colocar todos os funcion rios na Lista de espera do curso "###"Aten‡„o"
						lReserva:= .F.,oReserva:Refresh(.T.),lLista:=.F.,oLista:Refresh(.T.),lSolic:= .F.,oSolic:Refresh(.T.))
			oLista:oFont :=	oDlgMain:oFont
			oGroup:oFont:= oFont

			@  aObj32Size[3,1],	aObj32Size[3,2] CHECKBOX oSolic   VAR lSolic 	PROMPT OemtoAnsi(STR0039) SIZE aObj32Size[3,3],	aObj32Size[3,4] OF oDlgMain PIXEL;	//" Solicitar "
			ON CLICK (If(MsgYesNo(OemtoAnsi(STR0040),OemtoAnsi(STR0035)),Tr060Marca(1,2,3),),;	//"Solicitar vagas para todos os funcion rios selecionados"###"Aten‡„o"
						lReserva:= .F.,oReserva:Refresh(.T.),lLista:= .F.,oLista:Refresh(.T.),lSolic:=.F.,oSolic:Refresh(.T.))
			oSolic:oFont :=	oDlgMain:oFont
			oGroup:oFont:= oFont


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa de Nome                                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@  aObjSize[4,1] , aObj3Size[2,2] GROUP oGroup TO aObjSize[4,3], aObjSize[4,4] PROMPT OemtoAnsi(STR0001) OF oDlgMain PIXEL	//"Pesquisar"
			oGroup:oFont:= oFont

			@ aObjSize[4,1]+10, aObj3Size[2,2]+5 SAY OemToAnsi(STR0075) SIZE 15,8 PIXEL		//"Filial:"
			@ aObjSize[4,1]+10, aObj3Size[2,2]+25 MSGET oFilial	VAR cFilPesq SIZE 010 , 008 OF oDlgMain PICTURE PesqPict("SRA","RA_FILIAL") PIXEL
			@ aObjSize[4,1]+10, aObj3Size[2,2]+74 SAY OemToAnsi(STR0076) SIZE 15,8 PIXEL		//"Nome:"
			@ aObjSize[4,1]+10, aObj3Size[2,2]+95 MSGET oNome 	VAR cNomPesq SIZE 090 , 008 OF oDlgMain PICTURE PesqPict("SRA","RA_NOME") 	PIXEL

			oNome:bLostFocus	:= { ||   Tr060Busca(cFilPesq , RTrim(cNomPesq) , ,"1")     }

			@ aObjSize[4,1]+10, aObj3Size[2,2]+200 SAY OemToAnsi("Matricula") SIZE 22,8 PIXEL	//"Matricula:"
			@ aObjSize[4,1]+10, aObj3Size[2,2]+240 MSGET oMatr 	VAR cMatrPesq SIZE 40 , 008 OF oDlgMain PICTURE PesqPict("SRA","RA_MAT") 	PIXEL

			oMatr:bLostFocus	:= { ||   Tr060Busca(cFilPesq , ,RTrim(cMatrPesq ),"2" )     }

		ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{||nOpca:=1,If(Tr060PEGrv(cAlias,nReg,nOpcx,cCalend,Ccurso,cTurma)==1,If(Tr060Grava(cAlias,nReg,nOpcx,cCalend,cCurso,cTurma),oDlgMain:End(),),) },{|| nOpca := 2,oDlgMain:End()},,;
																	 {{"SDUSETDEL",{||Tr060Func() },;
		            						                OemToAnsi(STR0065),OemToAnsi(STR0051)}})) //"Situacao do Funcionario"#"Legenda"


    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   Ponto de Entrada Apos Confirmacao de Reserva de Treinamento     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca == 1

		If ExistBlock("TRM060DG")
	  		ExecBlock("TRM060DG",.F.,.F.)
	 	EndIF
	EndIf

Else

	Processa({||lRet:=Tr060Monta(cAlias,cCurso,cTurma,cCalend,cFiltro, RA2->RA2_FILIAL)}) //"Aguarde..."###" Montando tela de Reserva"

	IF nOpc == 3
		For nx := 1 To Len(aItens)
			aAux 	:= {"", "", "", "", "", "", "", "", ""}

			If aItens[nx][aScan( aItens[nx], { |x| AllTrim(x[1]) == "RA3_RESERV" })][2] == "S"
				aAux[1]	:= .F.
				aAux[2]	:= .F.
				aAux[3]	:= .T.
				cSolic	:= StrZero(Val(cSolic) + 1, 4)
			ElseIF aItens[nx][aScan( aItens[nx], { |x| AllTrim(x[1]) == "RA3_RESERV" })][2] == "R"
				aAux[1]	:= .T.
				aAux[2]	:= .F.
				aAux[3]	:= .F.
				cReserv	:= StrZero(Val(cReserv) + 1, 4)
			ElseIF aItens[nx][aScan( aItens[nx], { |x| AllTrim(x[1]) == "RA3_RESERV" })][2] == "L"
				aAux[1]	:= .F.
				aAux[2]	:= .T.
				aAux[3]	:= .F.
				cLista	:= StrZero(Val(cLista) + 1, 4)
			EndIf

			aAux[6] 	:=  aItens[nx][aScan( aItens[nx], { |x| AllTrim(x[1]) == "RA3_MAT" })][2]
			aAux[7] 	:=  aItens[nx][aScan( aItens[nx], { |x| AllTrim(x[1]) == "RA3_FILIAL" })][2]

			aadd(a2Lbx, aAux)
		Next

		dbSelectArea("TR1")
		TR1->(dbSetOrder(2))
		TR1->(dbGoTop())


		For nx := 1 To Len(a2Lbx)
			If ! PsqTR1  (a2Lbx[nx][7] , a2Lbx[nx][6], 2)
				Help("",1,"TRMA060FUNC")	// Funcionário informado não está cadastrado ou não está apto a realização do treinamento
				lMsErroAuto := .T.
			EndIf
		Next


	ElseIf nOpc == 5
		For nx := 1 To Len(aItens)

			For nI := 1 To Len(a2Lbx)
				If a2Lbx[nI][6] == aItens[nx][aScan( aItens[nx], { |x| AllTrim(x[1]) == "RA3_MAT" })][2] .AND. ;
					a2Lbx[nI][7] == aItens[nx][aScan( aItens[nx], { |x| AllTrim(x[1]) == "RA3_FILIAL" })][2]

					Aadd(aVerif,{a2Lbx[nI][7],a2Lbx[nI][6]})
					Adel(a2Lbx, nI)
					aSize(a2Lbx, ( Len(a2Lbx) - 1 ) )
					EXIT

				EndIf
			Next
		Next
	EndIf



	Tr060Grava(cAlias, nReg, nOpcx, cCalend, cCurso, cTurma)

Endif

dbSelectArea("TR1")
dbCloseArea()

If oTmpTR1 <> Nil
	oTmpTR1:Delete()
	Freeobj(oTmpTR1)
EndIf

DeleteObject(oOk)
DeleteObject(oNo)
DeleteObject(o1Ok)

RestArea(aSaveArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr060Monta³ Autor ³ Cristina Ogura       ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os listbox da reserva dos treinamentos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr060Monta(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpC2 : Codigo do Curso                                    ³±±
±±³          ³ ExpC3 : Codigo da Turma                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA060       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060Monta(cAlias,cCurso,cTurma,cCalend,cFiltro, cFilRA2,lVisual)

Local cIndCond 	:= ""
Local cFor		:= ""
Local cDescCC	:= ""
Local cDescFunc	:= ""
Local cSeq		:= ""
Local nBMarca	:= 0
Local nBRes		:= 0
Local nBFila	:= 0
Local nBSol		:= 0
Local nBConcl	:= 0
Local nReserv	:= 0
Local nSolic	:= 0
Local nLista	:= 0
Local nIndex	:= 0
Local nTotReg	:= 0
Local cGrupo	:= ""
Local cDepto	:= ""
Local cArqRA3	:= ""
Local cBPortal:= ""
Local nx		:= 0
Local aStruRA3:= {}
Local aStruSRA:= {}
Local cCargo	:= ""
Local cTurno	:= ""
Local cModRA2	:= ""
Local lRet		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para tratamento de log de inconsistencias                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aLog			:= {}
Local aLogTitle 	:= {}
Local lGeraLog		:= .F.
Local aCpo			:= {"RA_FILIAL","RA_MAT" ,"RA_NOME","RA_CODFUNC","RA_DESCFUN" }
Local aTitCpo		:= {}
Local aTamCpo		:= {}
Local lOfuscaNom	:= Len( If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {}) ) > 0
Local lVldCargo		:= SuperGetMv("MV_VLDCARG", .F., .T.)

DEFAULT lVisual		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza Tratamento de titulo e espacamento dos campos listados no  Log.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CpoSpace(aCpo,aTitCpo,aTamCpo)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Verifica o modo de acesso da tabela RA2 - Caso compartilha solicita ao usuário ³
  ³ em caso de existencia de reservas ja efetuadas, se o mesmo deseja manter estas ³
  ³ reservas ja efetuadas														   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Sx2ChkModo( "RA2", NIL, .F., @cModRA2, NIL )
If !( cModRA2 == "E" )

	//Reservas
	fChkResPre( cFilDe, cFilAte, cCalend, cCurso, cTurma, @nTotReg, "R",lVisual )

	If ( lMantem )
		nReserv := nTotReg
	EndIf

	nTotReg	:= 0

	//Lista de Espera
	fChkResPre( cFilDe, cFilAte, cCalend, cCurso, cTurma, @nTotReg, "L",lVisual )
	nLista := nTotReg

	nTotReg := 0

	//Solicitacao
	fChkResPre( cFilDe, cFilAte, cCalend, cCurso, cTurma, @nTotReg, "S" ,lVisual)
	nSolic := nTotReg

EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando o listbox 2 com todos os funcionarios do calendario, curso e turma    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA3")
dbSetOrder(2)

aStruRA3 := RA3->(dbStruct())

cQuery := "SELECT * "
cQuery += "  FROM "+RetSqlName("RA3")+" RA3 "
cQuery += " WHERE RA3.RA3_FILIAL  >= '" + cFilDe + "' AND RA3.RA3_FILIAL  <= '" + cFilAte + "'"
cQuery += "  AND RA3.RA3_CALEND = '" + cCalend + "'"
cQuery += "  AND RA3.RA3_CURSO = '" + cCurso + "'"
cQuery += "  AND RA3.RA3_TURMA = '" + cTurma + "'"
cQuery += "	 AND RA3.D_E_L_E_T_=' ' "
cQuery += "ORDER BY "+SqlOrder( RA3->( IndexKey() ) )
cQuery := ChangeQuery(cQuery)

dbSelectArea("RA3") ; dbCloseArea() //Fecha o SRA para uso da Query
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "RA3", .T., .T.)

For nX := 1 To Len(aStruRA3)
	If ( aStruRA3[nX][2] <> "C" )
		TcSetField("RA3",aStruRA3[nX][1],aStruRA3[nX][2],aStruRA3[nX][3],aStruRA3[nX][4])
	EndIf
Next nX

If lVisual
	RA3->(dbGoTop() )
	ProcRegua(RA3->(Reccount()))
EndIf

While !Eof()

	If RA3->RA3_RESERV = "R"
		nReserv ++
	ElseIf RA3->RA3_RESERV == "L"
		nLista ++
	ElseIf RA3->RA3_RESERV == "S"
		nSolic ++
	EndIf

	cSeq := STRZERO(RA3->RA3_SEQ,4)

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(RA3->RA3_FILIAL+RA3->RA3_MAT)

	If lVisual
		IncProc(STR0030+" / "+STR0028+": "+SRA->RA_FILIAL+" / "+ If(lOfuscaNom, Replicate('*',25), Left(SRA->RA_NOME,25)) )// Filial / Nome
	EndIf

	// Situacao do Funcionario
	cSitFol		:= TrmSitFol()
	cDescCC		:= FDesc("CTT",SRA->RA_CC,"CTT->CTT_DESC01",30)
	cDescFunc	:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)

	If ( cSitfol $ cSituacao ) .Or. ( cSitfol == "P" .And. ( IsInCallStack("TR060VIS") .Or. nFerProg == 1 ) ) .Or. lVisual
		Aadd(a2Lbx,{IIf(RA3->RA3_RESERV=="R",.T.,.F.),;		// Reservado
		IIf(RA3->RA3_RESERV=="L",.T.,.F.),;	// Em Lista de Espera
		IIf(RA3->RA3_RESERV=="S",.T.,.F.),;	// Solicitado
		cSitFol,;										//	Situacao do Funcionario
		SRA->RA_NOME,;                   		// Nome do funcionario
		SRA->RA_MAT,;                         	// Matricula
		SRA->RA_FILIAL,;                      	// Filial
		cSeq,;                                	// Sequencia
		SRA->RA_CC,;                            // Centro de Custo
		cDescCC,;                               // Descr. Centro de Custo
		SRA->RA_CODFUNC,;                       // Função
		cDescFunc,;                             // Descr. Função
		.T.})
	EndIf

	dbSelectArea("RA3")
	dbSkip()
EndDo

dbSelectArea("RA3")
dbCloseArea()
ChkFile("RA3") //Restaura o RA3 Padrao

If !lVisual
	aStruSRA := SRA->(dbStruct())

	cQuery := "SELECT * "
	cQuery += "  FROM "+	RetSqlName("SRA")+" SRA "
	cQuery += " WHERE SRA.RA_FILIAL  >= '" + cFilDe + "' AND SRA.RA_FILIAL  <= '" + cFilAte + "'"
	cQuery += "   AND SRA.RA_MAT     >= '" + cMatDe + "' AND SRA.RA_MAT     <= '" + cMatAte + "'"
	cQuery += "   AND SRA.RA_CC      >= '" + cCcDe  + "' AND SRA.RA_CC      <= '" + cCcate  + "'"
	cQuery += "   AND SRA.RA_CODFUNC >= '" + cFunDe + "' AND SRA.RA_CODFUNC <= '" + cFunAte + "'"
	cQuery += "   AND SRA.D_E_L_E_T_=' ' "

	If nOrdem == 1 .Or. nOrdem == 2
		cQuery += "ORDER BY RA_FILIAL, RA_MAT, RA_CC, RA_CODFUNC"
	ElseIf nOrdem == 3
		cQuery += "ORDER BY RA_FILIAL, RA_CC, RA_MAT, RA_CODFUNC"
	ElseIf nOrdem == 4
		cQuery += "ORDER BY RA_FILIAL, RA_CODFUNC, RA_MAT, RA_CC"
	EndIf
	cQuery := ChangeQuery(cQuery)

	dbSelectArea("SRA") ; dbCloseArea() //Fecha o SRA para uso da Query
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SRA", .T., .T.)

	For nX := 1 To Len(aStruSRA)
		If ( aStruSRA[nX][2] <> "C" )
			TcSetField("SRA",aStruSRA[nX][1],aStruSRA[nX][2],aStruSRA[nX][3],aStruSRA[nX][4])
		EndIf
	Next nX

	dbGoTop()
	ProcRegua(SRA->(Reccount()))

	While !Eof()

		IncProc(STR0030+" / "+STR0028+": "+SRA->RA_FILIAL+" / "+ If(lOfuscaNom, Replicate('*',25), Left(SRA->RA_NOME,25)) )// Filial / Nome

	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Treinamento(RA2) esta exclusivo e nao permite a selecao de       ³
		//³ funcionario de outra filial.												   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FWModeAccess("RA2",3) == "E"
	        IF (cFilRA2 != SRA->RA_FILIAL)
		    	dbSkip()
				Loop
	    	Endif
	    Endif

		cGrupo := Space(GetSx3Cache("Q3_GRUPO", "X3_TAMANHO"))
		cDepto := SRA->RA_DEPTO

	    cCargo := fGetCargo(SRA->RA_MAT)
	    cTurno := SRA->RA_TNOTRAB

		dbSelectArea("SQ3")
		dbSetOrder(1)
		If dbSeek(xFilial("SQ3")+cCargo+SRA->RA_CC) .Or. dbSeek(xFilial("SQ3")+cCargo)
			cGrupo := SQ3->Q3_GRUPO
			If Empty(cDepto)
				cDepto := SQ3->Q3_DEPTO
			EndIf
		EndIf

		dbSelectArea("SRA")
		If 	cGrupo < cGruDe .Or. cGrupo > cGruAte .Or.;
			cDepto < cDepDe .Or. cDepto > cDepAte .Or.;
			cTurno < cTurnoDe .Or. cTurno > cTurnoAt
			dbSkip()
			Loop
		EndIf

		If !Empty(cFiltro) .And. !(&cFiltro)
			dbSkip()
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Funcionario e tambem Instrutor do curso selecionado e nesse caso ³
		//³ ele nao sera apresentado para realizacao de reservas						   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	    dbSelectArea("RA2")
		dbSetOrder(1)
		If dbSeek(xFilial("RA2")+cCalend+cCurso+cTurma) .and. !empty(RA2->RA2_INSTRU)

		    dbSelectArea("RA7")
			dbSetOrder(1)
			If dbSeek(xFilial("RA7")+RA2->RA2_INSTRU) .and. (RA7->RA7_MAT == SRA->RA_MAT)
			   dbSelectArea("SRA")
			   dbSkip()
			   Loop
			Endif

		Endif

		nBMarca 	:= 1
		nBRes		:= 1
		nBFila		:= 1
		nBSol		:= 1
		nBConcl	:= 1
		cBPortal	:= "N"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montando o Listbox 2                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("RA3")
		dbSetOrder(1)
		If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cCurso)
			If nSolFunc == 2 //Apenas exibirá funcionários sem solicitação
				dbSelectArea("SRA")
				dbSkip()
				Loop
			EndIf

			While !Eof() .And.	SRA->RA_FILIAL+SRA->RA_MAT+cCurso ==;
								RA3->RA3_FILIAL+RA3->RA3_MAT+RA3->RA3_CURSO

				If RA3->RA3_TURMA == cTurma .And. RA3->RA3_CALEND == cCalend
					// Marca no Listbox 1
					nBMarca	:= 2
				Else
					// Verifica a situacao em outra calendario
					If RA3->RA3_RESERV == "R"
						nBRes	:= 2
					ElseIf RA3->RA3_RESERV == "S"
						nBSol	:= 2
					ElseIf RA3->RA3_RESERV == "L"
						nBFila	:= 2
					EndIf
				EndIf

				If RA3->(ColumnPos("RA3_PORTAL")) > 0
					cBPortal := RA3->RA3_PORTAL
				EndIf

				dbSelectArea("RA3")
				dbSkip()
			EndDo
		Else
			If nSolFunc == 1 //Se não existir solicitação, não exibe
				dbSelectArea("SRA")
				dbSkip()
				Loop
			EndIf
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificando se ja fez o curso                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("RA4")
		dbSetOrder(1)
		If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cCurso)
			nBConcl:= 2
		EndIf

		DbSelectArea("RA2")
		dbSetOrder(1)

		dbSelectArea("SRA")

		// Montando o ListBox 1
		cDescCC	 := FDesc("CTT",SRA->RA_CC,"CTT->CTT_DESC01",30)
		cDescFunc:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)

		// Situacao do Funcionario
		cSitFol:= TrmSitFol()

		If (cSitfol $ cSituacao) .Or. (cSitfol == "P" .And. nFerProg == 1)

		    //-- Verifica se existe cargo para o funcionario
		    IF fExistCargo() .Or. !lVldCargo

				RecLock("TR1",.T.)
				TR1->TR1_MARCA		:= nBMarca
				TR1->TR1_SITFOL  		:= cSitFol
				TR1->TR1_RESERV		:= nBRes
				TR1->TR1_LISTA		:= nBFila
				TR1->TR1_SOLIC		:= nBSol
				If TR1->(ColumnPos("TR1_PORTAL")) > 0
					TR1->TR1_PORTAL	:= cBPortal
				EndIf
				TR1->TR1_CONCL		:= nBConcl
				TR1->TR1_FILIAL		:= SRA->RA_FILIAL
				TR1->TR1_NOME			:= SRA->RA_NOME
				TR1->TR1_MAT			:= SRA->RA_MAT
				TR1->TR1_CC			:= SRA->RA_CC
				TR1->TR1_DESCCC		:= cDescCC
				TR1->TR1_FUNCAO		:= SRA->RA_CODFUNC
				TR1->TR1_DESCFUN		:= cDescFunc
				MsUnlock()
			Else
				lGeraLog:= .T.
				aAdd( aLog , SRA->RA_FILIAL 	+ 	aTamCpo[1] + Space(2) +	 ;
							 SRA->RA_MAT 		+  	aTamCpo[2] + Space(2) + ;
							 If( lOfuscaNom, Replicate('*',30), SRA->RA_NOME) + aTamCpo[3] + Space(2) + ;
							 SRA->RA_CODFUNC   	+   aTamCpo[4] + Space(2) + ;
							 FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",aTitCpo[5]) ;
					)
			EndIf
		EndIf

		dbSelectArea("SRA")
		dbSkip()
	EndDo
EndIf

If Len(a2Lbx) == 0  .AND. ! lAutoExec
	Aadd(a2Lbx,{.F.,.F.,.F.,;
				CriaVar("RA_SITFOLH"),;
				CriaVar("RA_NOME"),;
				CriaVar("RA3_MAT"),;
				CriaVar("RA_FILIAL"),;
				CriaVar("RA3_SEQ"),;
				CriaVar("RA_CC"),;
				"",;
				"",;
				"",;
				.F.})
EndIf

cReserv	:= StrZero(nReserv,4)
cSolic	:= StrZero(nSolic,4)
cLista	:= StrZero(nLista,4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena o Array por ordem de Nome                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

a2Lbx := aSort(a2Lbx,,,{|x,y| x[5] < y[5] })

If !lVisual
	dbSelectArea( "SRA" ) ; dbCloseArea() ; ChkFile( "SRA" ) //Restaura o SRA Padrao
EndIf

//-- Gera Log de inconsistencia
IF lGeraLog .AND. ! lAutoExec
	IF MsgYesNo( OemToAnsi( STR0079 ), OemToAnsi( STR0035 )  ) //"Foram Encontradas Inconsistências no Vínculo Função X Cargo. Deseja Criar Log?"###//"Aten‡„o"

		aAdd( aLogTitle ,	aTitCpo[1] + Space(2) + ;
					 	  	aTitCpo[2] + Space(2) + ;
					 	  	aTitCpo[3] + Space(2) + ;
						  	aTitCpo[4] + Space(2) + ;
						  	aTitCpo[5] + Space(2)  ;
			)
		aAdd( aLogTitle , STR0078 )	//"Funcionario ou funcao sem cargo"
		MsAguarde( { || fMakeLog( { aLog } , aLogTitle , NIL , NIL , FunName() , STR0080 ) } , STR0080 ) //"Log de Ocorrências"
	Endif
Endif


If !lVisual
	dbSelectArea("TR1")
	dbGotop()
	IF TR1->(Eof())
		Aviso(STR0035, STR0074, {"Ok"})	//"Atencao"###	#define STR0074  "Não foram encontrados funcionários para a parametrização informada. Verifique os parâmetros e o filtro."
		lRet:= .F.
	EndIF
EndIf

Return (lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fExistCargo³ Autor ³ Mauricio MR          ³ Data ³ 28.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a existencia de cargo para o funcionario           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fExistCargo()
Local aSRJArea := SRJ->(GetArea())
Local lRet:= .T.

If Empty(SRA->RA_CARGO)
	SRJ->(dbSetOrder(1))
	If ( lRet:= SRJ->(dbSeek( xFilial("SRJ") + SRA->RA_CODFUNC ) ) )
	   lRet:= !Empty(SRJ->RJ_CARGO)
    Endif
Endif

RestArea(aSRJArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr060Grava³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±³          ³ ExpC2 : Codigo calendario                                  ³±±
±±³          ³ ExpC3 : Codigo curso                                       ³±±
±±³          ³ ExpC4 : Codigo turma                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr060Grava(cAlias, nReg, nOpcx, cCalend, cCurso, cTurma)

	Local nx     		:= 0
	Local cSX5			:= Space(01)
	Local lFound 		:= .T.
	Local lEPMCanc		:= .T.
	Local aSaveArea		:= GetArea()
	Local lRealizado	:= .F.

	If Val(cVagas) < Val(cReserv)
		Help("",1,"TRA060MENO")
		lMsErroAuto := .T.
		RestArea(aSaveArea)
		Return .F.
	EndIf

	If !lMantem

		dbSelectArea("RA3")
		dbSetOrder(1)
		For nx := 1 To Len(aRecRA3)
			RA3->(dbGoTo(aRecRA3[nx]))
			RecLock("RA3",.F.)
				RA3->RA3_RESERV := ""

				// Atualiza integracao Datasul EPM
				TRMA060EPMInt()

				RA3->(dbDelete())
			RA3->(MsUnlock())
		Next
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga as Solicitacoes de Treinamento que foram desmarcadas              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx := 1 To Len(aVerif)

		dbSelectArea("RA3")
		dbSetOrder(1)
		If dbSeek(aVerif[nx, 1] + aVerif[nx, 2] + cCurso)
			While !Eof() .And. (aVerif[nx, 1] + aVerif[nx, 2] + cCurso) == (RA3->RA3_FILIAL + RA3->RA3_MAT + RA3->RA3_CURSO)
				If Alltrim(cTurma) == Alltrim(RA3->RA3_TURMA)

					//Verifica se existe o curso e avaliacoes no Protheus, elimina os mesmas
					//pois o treinamento sera realizado novamente e o historico estara registrado no EPM/AMS
					lEPMCanc := .T.

					dbSelectArea("RAI")
					dbSetOrder(1)
					If dbSeek(aVerif[nx, 1] + RA2->RA2_CALEND + cCurso + RA2->RA2_TURMA + aVerif[nx, 2])
						
						// VERIFICA SE O TREINAMENTO JÁ FOI BAIXADO.
						lRealizado	:= RA2->RA2_REALIZ == "S"

						While !Eof() .And. RA2->RA2_CALEND + cCurso + RA2->RA2_TURMA + aVerif[nx,2] == RAI->RAI_CALEND + RAI->RAI_CURSO + RAI->RAI_TURMA + RAI->RAI_MAT
							RecLock("RAI",.F.)
								dbDelete()
							MsUnlock()

							dbSkip()
						EndDo
					EndIf

					dbSelectArea("RA4")
					dbSetOrder(3)// RA4_FILIAL + RA4_CALEND + RA4_CURSO + RA4_TURMA + RA4_MAT
					If dbSeek(aVerif[nx, 1] + RA4->RA4_CALEND + cCurso + RA4->RA4_TURMA + aVerif[nx, 2])
						
						lEPMCanc	:= .F.

						// DELETA APENAS INFORMAÇÕES DE CURSOS NÃO REALIZADOS
						If !lRealizado
							RecLock("RA4",.F.)
								dbDelete()
							MsUnlock()
						EndIf
					EndIf


					dbSelectArea("RA3")
					RecLock("RA3",.F.)
						RA3->RA3_RESERV := ""

						If lEPMCanc
							// Atualiza integracao(metodo deleteMatricula) Datasul EPM
							TRMA060EPMInt()
						EndIF

						dbDelete()
					MsUnlock()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Envia e-mail de Cancelamento de reserva de Treinamento para funcionario.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( RA3_EMAIL == "S" .AND. ! lAutoExec) .OR. (lAutoExec .AND. lEmail)  //Verifica se foi enviado e-mail de confirmacao
						Tr060Email(aVerif[nx,1], aVerif[nx,2],cCalend,cCurso,cTurma," ",STR0069,.F.,"1") //"Cancelamento de Treinamento"
					EndIf

					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
	Next nx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava as Solicitacoes de Treinamento                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx:=1 To Len(a2Lbx)
		lFound := .T.
		dbSelectArea("RA3")
		dbSetOrder(1)
		If dbSeek(a2Lbx[nx,7]+a2Lbx[nx,6]+cCurso)
			While (a2Lbx[nx,7]+a2Lbx[nx,6]+cCurso) ==;
					RA3->RA3_FILIAL+RA3->RA3_MAT+RA3->RA3_CURSO
				If Empty(RA3->RA3_CALEND) .Or.;
					(AllTrim(RA3->RA3_CALEND) == Alltrim(cCalend) .And. AllTrim(RA3->RA3_TURMA) == Alltrim(cTurma))
					lFound := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf

		RecLock("RA3",lFound)
			If lFound
				RA3->RA3_FILIAL	:= a2Lbx[nx, 7]
				RA3->RA3_MAT	:= a2Lbx[nx, 6]
			EndIf

			If a2Lbx[nx,1]
				cSx5 := "R"
			ElseIf a2Lbx[nx,2]
				cSx5 := "L"
			ElseIf a2Lbx[nx,3]
				cSx5 := "S"
			EndIf

			IF !Empty(a2Lbx[nx, 6])
				RA3->RA3_CALEND	:= cCalend
				RA3->RA3_CURSO	:= cCurso
				RA3->RA3_TURMA	:= cTurma
				RA3->RA3_RESERV	:= cSx5
				RA3->RA3_DATA	:= dDataBase
			Endif
		MsUnlock()

		// Atualiza integracao Datasul EPM
		TRMA060EPMInt()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia e-mail de confirmação de reserva de Treinamento para funcionario. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If (cSx5 $ cEmail  .AND. ! lAutoExec) .OR. (lAutoExec .AND. lEmail)// Se selecionar (R,L,S) envia e-mail
			If RA3_EMAIL != "S"
				If ExistBlock("TR060WF")
					ExecBlock("TR060WF",.F.,.F.,{a2Lbx[nx,7], a2Lbx[nx,6],cCalend,cCurso,cTurma,cSX5,cObs1,cObs2,cObs3,cObs4,cObs5,cObs6,OemToAnsi(STR0038)}) //"Confirmacao de Treinamento"
				Else
					Tr060Email(a2Lbx[nx,7], a2Lbx[nx,6],cCalend,cCurso,cTurma,cSX5,STR0038,.F.,"1") //"Confirmacao de Treinamento"
				Endif
			EndIf
		EndIf

	Next nx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla o numero de vagas reservadas                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("RA2")
	dbSetOrder(2)
	If dbSeek(xFilial("RA2") + cCurso + cTurma)
		While !Eof() .And. xFilial("RA2") + cCurso + cTurma == RA2_FILIAL + RA2_CURSO + RA2_TURMA
			If RA2_CALEND == cCalend
				RecLock("RA2",.F.,.T.)
					RA2->RA2_RESERV	:= Val(cReserv)
				MsUnlock()
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf

	RestArea(aSaveArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr060L1   ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no on click do listbox 1                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 : .T. - Marca todos    .F. - Individual     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060L1(lTodos)

Local cFil		:= TR1->TR1_FILIAL
Local cNome		:= TR1->TR1_NOME
Local cMat		:= TR1->TR1_MAT
Local cSit     	:= TR1->TR1_SITFOL
Local nPos		:= 0
Local nBReser	:= 0
Local nBFila	:= 0
Local cSeq 		:= ""
Local lAtu 		:= .T.
Local nx		:= 0

lTodos := If(empty(lTodos),.F.,lTodos)

If lTodos .and. TR1->TR1_MARCA == 2 // Sai se for "Marcar todos" e ja tiver sido marcado.
	Return
EndIf

//Check box desmarcado
If !(lTodos) .And. TR1->TR1_MARCA <> 2
	If !(TrmSitMsg())   //Validacao da Situacao do Funcionario
		Return
	EndIf

	If !(Tr060FunCar())   //Validacao se a Funcao esta devidamente amarrada ao Cargo
		Return
	EndIf

EndIf

RecLock("TR1",.F.,.T.)
	TR1->TR1_MARCA := IIF(TR1->TR1_MARCA==1,2,1)
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Marcado o funcionario para o curso                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TR1->TR1_MARCA == 2
	If Len(a2Lbx) == 1 .And. Empty(a2Lbx[1][5])
		aDel(a2Lbx,1)
		aSize(a2Lbx,Len(a2Lbx)-1)
	EndIf
	If Val(cVagas) > Val(cReserv)
		nBReser := .T.
		nBFila  := .F.
		cReserv := StrZero(Val(cReserv)+1,4)
	Else
		nBReser := .F.
		nBFila  := .T.
		cLista  := StrZero(Val(cLista)+1,4)
	EndIf
	cSeq := StrZero(Len(a2Lbx)+1,4)

	// Existe uma solicitacao para este curso
	IF TR1->TR1_SOLIC == 2
		lAtu := .T.
	Else
		lAtu := .F.
	EndIf

	Aadd(a2Lbx,{nBReser, nBFila, .F.,cSit, cNome, cMat, cFil, cSeq, lAtu})

Else

	// Verifica se ja existe avaliacao para o curso, antes do cancelamento da reserva
	dbSelectArea("RAI")
	dbSetOrder(1)

	If dbSeek(xFilial("RAI")+RA2->RA2_CALEND+RA2->RA2_CURSO+RA2->RA2_TURMA+TR1->TR1_MAT)
		cMens := OemToAnsi(STR0083) +cNome +chr(13) 		//"Este curso ja foi realizado para: "
		cMens += OemToAnsi(STR0084) +chr(13) +chr(13)		//"O cancelamento dessa matricula eliminará as avaliações registradas no Protheus."
	    If 	RA1->RA1_TIPO = "L"	.and. SuperGetMv("MV_TRMINTG", NIL, .F.)
			cMens += OemToAnsi(STR0086) +chr(13)			//"Como existe integracao com o modulo e-learning, todo"
			cMens += OemToAnsi(STR0087) +chr(13) +chr(13)	//"historico desse treinamento estara registrado no EPM / AMS !"
        EndIf
		cMens += OemToAnsi(STR0085)					 		//"Deseja continuar?"

		If !MsgYesNo(cMens,STR0082)
			TR1->TR1_MARCA := IIF(TR1->TR1_MARCA==2,1,2)
	    	Return
	 	EndIf
 	EndIf


	nPos:= Ascan(a2Lbx,{|x| Alltrim(x[7]+x[6]) == Alltrim(cFil+cMat)})
	If nPos > 0
		If a2Lbx[nPos,1]
			cReserv := StrZero(Val(cReserv)-1,4)
		ElseIf a2Lbx[nPos,2]
			cLista := StrZero(Val(cLista)-1,4)
		ElseIf a2Lbx[nPos,3]
			cSolic := StrZero(Val(cSolic)-1,4)
		EndIf
		Aadd(aVerif,{a2Lbx[nPos][7],a2Lbx[nPos][6]})
		aDel(a2Lbx,nPos)
		aSize(a2Lbx,Len(a2Lbx)-1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Qdo for desmarcado um funcionario de reserva, automaticamente          ³
//³ um funcionario como lista de espera vira reserva.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Val(cLista) > 0
			// Colocar o array em ordem de sequencia
			a2Lbx := aSort(a2Lbx,,,{|x,y| VAL(x[8])< VAL(y[8]) })

			For nx := 1 To Len(a2Lbx)
				// Se for lista de espera e nao estiver reservada
				If a2Lbx[nx][2] .And. !a2Lbx[nx][1]
					If Val(cVagas) < Val(cReserv)
						a2Lbx[nx][1]:= .T.
						a2Lbx[nx][2]:= .F.
						a2Lbx[nx][3]:= .F.
						// Tiro 1 da lista de espera e somo nas reservas
						cLista	:= StrZero(Val(cLista)-1,4)
						cReserv	:= StrZero(Val(cReserv)+1,4)
						Exit
					EndIf
				EndIf
			Next nx
		EndIf
	EndIf
EndIf

oSay2:Refresh(.T.)
oSay3:Refresh(.T.)
oSay4:Refresh(.T.)
o2Lbx:Refresh(.T.)
o1Lbx:DrawSelect()

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr060Cl2  ³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no on click do listbox 2                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Posicao do nAt no listbox                          ³±±
±±³          ³ ExpN2 : Posicao na linha do listbox                        ³±±
±±³          ³ ExpN3 : Posicao na coluna do listbox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060Cl2(nAuxRow,nRow,nCol)

If Len(a2Lbx) == 1 .And. Empty(a2Lbx[1,5])
	Help("",1,"TRA060VAZI")
	Return .T.
EndIf

cReserv	:= Val(cReserv)
cLista	:= Val(cLista)
cSolic	:= Val(cSolic)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devido ListBox nao retornar a coluna, a cada click posiciona em uma coluna. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If a2lbx[nAuxRow][1]
	nCol := 2
ElseIf a2lbx[nAuxRow][2]
	nCol := 3
Else
	nCol := 1
EndIf

If nCol == 1					// Todos reservados
	If !a2Lbx[nAuxRow,1]
		If a2Lbx[nAuxRow,2]
			cLista -= 1
		ElseIf a2Lbx[nAuxRow,3]
			cSolic -= 1
		EndIf
		a2Lbx[nAuxRow,1] := .T.
		a2Lbx[nAuxRow,2] := .F.
		a2Lbx[nAuxRow,3] := .F.
		cReserv += 1
	EndIf
ElseIf nCol == 2				// Todos na Lista de espera
	If !a2Lbx[nAuxRow,2]
		If a2Lbx[nAuxRow,3]
			cSolic -= 1
		ElseIf a2Lbx[nAuxRow,1]
			cReserv -= 1
		EndIf
		a2Lbx[nAuxRow,1] := .F.
		a2Lbx[nAuxRow,2] := .T.
		a2Lbx[nAuxRow,3] := .F.
		cLista += 1
	EndIf
ElseIf nCol == 3   		// Todos como solicitacao
	If !a2Lbx[nAuxRow,3]
		If a2Lbx[nAuxRow,1]
			cReserv -= 1
		ElseIf a2Lbx[nAuxRow,2]
			cLista -= 1
		EndIf
		a2Lbx[nAuxRow,1] := .F.
		a2Lbx[nAuxRow,2] := .F.
		a2Lbx[nAuxRow,3] := .T.
		cSolic += 1
	EndIf
EndIf

cReserv := StrZero(cReserv,4)
cLista	:= StrZero(cLista,4)
cSolic	:= StrZero(cSolic,4)

o2Lbx:DrawSelect()
oSay2:Refresh(.T.)
oSay3:Refresh(.T.)
oSay4:Refresh(.T.)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr060Marca³ Autor ³ Cristina Ogura        ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que marca todos os funcionarios selecionados         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Posicao nao marcada                                ³±±
±±³          ³ ExpN2 : Posicao nao marcada                                ³±±
±±³          ³ ExpN3 : Posicao marcada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060Marca(nF1,nF2,nT)
Local nx	:= 0
Local nCont	:= 0

If Len(a2Lbx) == 1 .And. Empty(a2Lbx[1,5])
	Help("",1,"TRA060VAZI")						// Nao existe funcionario selecionado
	Return .T.
EndIf

For nx:=1 To Len(a2Lbx)
	a2Lbx[nx, nF1]	:= .F.
	a2Lbx[nx, nF2]	:= .F.
	a2Lbx[nx, nT] 	:= .T.
	nCont++
Next nx

If nT == 1			// Reserva
	cReserv := StrZero(nCont,4)
	cLista	:= "0000"
	cSolic	:= "0000"
ElseIf nT == 2		// Lista
	cReserv	:= "0000"
	cLista	:= StrZero(nCont,4)
	cSolic	:= "0000"
ElseIf nT == 3		// Solicitacao
	cReserv	:= "0000"
	cLista	:= "0000"
	cSolic	:= StrZero(nCont,4)
EndIf

o2Lbx:Refresh(.T.)
oSay2:Refresh(.T.)
oSay3:Refresh(.T.)
oSay4:Refresh(.T.)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr060CriaArq³ Autor ³ Cristina Ogura      ³ Data ³ 20.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria arquivo para gravar os dados do listbox 2              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060CriaArq()
Local aLista      := {}
Local aLstIndices := {}

Local a1Stru:= {}
Local cCond	:= ""
Aadd(a1Stru,{"TR1_MARCA",    "N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_SITFOL",   "C", 1,                       0                       } )
Aadd(a1Stru,{"TR1_RESERV",   "N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_LISTA",    "N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_SOLIC",    "N", 1,                       0                       } )
If RA3->(ColumnPos("RA3_PORTAL")) > 0
	Aadd(a1Stru,{"TR1_PORTAL","C", 1,                       0                       } )
EndIf
Aadd(a1Stru,{"TR1_CONCL",    "N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_FILIAL",   "C", FWGETTAMFILIAL,          0                       } )
Aadd(a1Stru,{"TR1_NOME",     "C", TamSx3("RA_NOME")[1],    TamSx3("RA_NOME")[2]    } )
Aadd(a1Stru,{"TR1_MAT",      "C", TamSx3("RA_MAT")[1],     TamSx3("RA_MAT")[2]     } )
Aadd(a1Stru,{"TR1_CC",       "C", TamSx3("RA_CC")[1],      TamSx3("RA_CC")[2]      } )
Aadd(a1Stru,{"TR1_DESCCC",   "C", TamSx3("CTT_DESC01")[1], TamSx3("CTT_DESC01")[2] } )
Aadd(a1Stru,{"TR1_FUNCAO",   "C", TamSx3("RA_CODFUNC")[1], TamSx3("RA_CODFUNC")[2] } )
Aadd(a1Stru,{"TR1_DESCFU",   "C", TamSx3("RJ_DESC")[1],    TamSx3("RJ_DESC")[2]    } )

aLista := {"TR1_FILIAL","TR1_NOME"}
AAdd( aLstIndices, aLista)
aLista := {"TR1_FILIAL","TR1_MAT"}
AAdd( aLstIndices, aLista)
aLista := {"TR1_FILIAL","TR1_CC"}
AAdd( aLstIndices, aLista)
aLista := {"TR1_FILIAL","TR1_FUNCAO"}
AAdd( aLstIndices, aLista)

oTmpTR1 := RhCriaTrab("TR1", a1Stru, aLstIndices)
dbSetOrder(nOrdem)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr060Sel	³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 06.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona todos funcionarios para o treinamento.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : 1-Todos Funcionarios 	2-Func. c/ S-Solicitacao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060Sel(nOp)

dbSelectArea("TR1")
dbGoTop()

While ! eof()

   If nOp == 1 .And. TR1->TR1_SOLIC == 2
      dbSkip()
      Loop
   ElseIf nOp == 2 .And. TR1->TR1_SOLIC == 1
      dbSkip()
      Loop
   EndIf

	Tr060L1(.T.) // Atualiza os 2 listbox

	dbSkip()
EndDo
dbGoTop()
o1Lbx:Refresh(.T.)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr060Func     ³ Autor ³Eduardo Ju        ³ Data ³ 28.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aciona Legenda de cores Situacao do Funcionario         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr060Func()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060Func()

TrmLegenda(5,,, aLegenda)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr060Leg      ³ Autor ³Emerson Grassi    ³ Data ³ 01.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aciona Legenda de cores da Mbrowse.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr060Leg()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060Leg()

TrmLegenda(2,,, aLegenda)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tr060Email    ³ Autor ³Emerson Grassi    ³ Data ³ 28/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envia e-mail de Confirmacao para funcionarios.   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr060Email()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilAux	: Filial do Funcionario                           ³±±
±±³			 ³ cMat		: Matricula do participante                       ³±±
±±³			 ³ cCalend	: Codigo do Calendario do treinamento             ³±±
±±³			 ³ cCurso  	: Codigo do Curso a ser realizado                 ³±±
±±³			 ³ cTurma	: Turma do treinamento                            ³±±
±±³			 ³ cSX5	    : Situacao do participante (RLS)                  ³±±
±±³			 ³ cAssunto	: Assunto do email (Confirmacao ou Cancelamento)  ³±±
±±³			 ³ lAutomatico : Se a rotina esta sendo acessada por Workflow ³±±
±±³			 ³ cTipo	: "1"-Reserva(TRMA060) "2"-Envio de Aviso(TRMM060)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060Email(cFilAux,cMat,cCalend,cCurso,cTurma,cSX5,cAssunto,lAutomatico,cTipo)
 // cTipo			:= PARAMIXB[9]	// Tipo 1-Reserva(Trma060)   2-Envio Aviso(Trmm060) 3=Baixa treinamento
Local aSaveArea := GetArea()
Local cMensagem	:= ""
Local cFil		:= ""
Local cNome		:= ""
Local cDCurso	:= ""
Local cDCalend	:= ""
Local cLocal	:= ""
Local cDInicio	:= ""
Local cDFim		:= ""
Local cHorario	:= ""
Local cEntidade	:= ""
Local cInstrut	:= ""
Local cSituac	:= Iif(cSx5 == "R",STR0067,(Iif(cSx5 == "S",STR0068,(Iif(cSx5 == "L",STR0031,STR0070))))) //"Reservado"###"Solicitacao"###"Lista de Espera"###"Cancelado"
Local nErro		:= 0
Local cTipomail := ""
Local aCampos	:= {}
Local cEmailSup	:= ""
Local lSup		:= .F.
Local lMailBaixa := Iif(cTipo <> '3', .T., SuperGetMV("MV_TRMMAIL",.F.,.T.))
Local nRecno	:= 0
Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lOfuscaNom:= Len(aFldRel) > 0

If lMailBaixa
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nome do Funcionario                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SRA")
	cFil:= xFilial("SRA", cFilAux)
	dbSeek(cFil+cMat)
	cNome	:= If( lOfuscaNom, Replicate('*',30), SRA->RA_NOME )
	cTipomail := SRA->RA_TPMAIL

	lSup := MailSup(xFilial("SRA", cFilAux),cMat,SRA->RA_DEPTO,@cEmailSup)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Curso                                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("RA1")
	cFil:= xFilial("RA1", cFilAux)
	dbSeek(cFil+cCurso)
	cDCurso	:= RA1->RA1_DESC

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calendario                                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("RA2")
	cFil:= xFilial("RA2", cFilAux)
	dbSeek(cFil+cCalend+cCurso+cTurma)
	cDCalend	:= RA2->RA2_DESC
	cLocal		:= RA2->RA2_LOCAL
	cDInicio	:= Dtoc(RA2->RA2_DATAIN)
	cDFim		:= Dtoc(RA2->RA2_DATAFI)
	cHorario	:= RA2->RA2_HORARI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Instrutor                                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("RA7")
	cFil:= xFilial("RA7", cFilAux)
	dbSeek(cFil+RA2->RA2_INSTRU)
	cInstrut	:= RA7->RA7_NOME

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Entidade                                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("RA0")
	cFil:= xFilial("RA0", cFilAux)
	dbSeek(cFil+RA2->RA2_ENTIDA)
	cEntidade	:= RA0->RA0_DESC

	aCampos 	:= {cFilAux,cMat,cCalend,cCurso,cTurma,cSX5,cAssunto,lAutomatico,cTipo}
	If ExistBlock("TR060EMAIL")  .And. cTipo <> '3'
		cMensagem := ExecBlock("TR060EMAIL",.F.,.F.,aCampos)

		/*

		//Exemplo do ponto de entrada

		User Function TR060EMAIL()

		//Parametros recebidos
		Local cFilAux		:= PARAMIXB[1]	// Filial corrente
		Local cMat 			:= PARAMIXB[2] 	// Matricula
		Local cCalend 		:= PARAMIXB[3]	// Codigo do Calendario
		Local cCurso  		:= PARAMIXB[4]	// Codigo do Curso
		Local cTurma 		:= PARAMIXB[5]	// Turma
		Local cSx5			:= PARAMIXB[6]	// Situacao ("R"-Reservado, "S"-Solicitacao, "L"-Lista Espera, " " - Cancelado)
		Local cAssunto		:= PARAMIXB[7]	// Assunto do Email
		Local lAutomatico	:= PARAMIXB[8]	// Automatico
		Local cTipo			:= PARAMIXB[9]	// Tipo 1-Reserva(Trma060)   2-Envio Aviso(Trmm060) 3=Baixa treinamento

		Local cTipoMail := ""
		Local cNome 	:= ""
		Local cDCurso 	:= ""
		Local cDCalend 	:= ""
		Local cInstrut 	:= ""
		Local cDInicio 	:= ""
		Local cDfim		:= ""
		Local cHorario	:= ""
		Local cEntidade	:= ""
		Local cLocal	:= ""
		Local cSituac	:= 	(Iif(cSx5 == "R",	"Reservado",;		//"Reservado"
							(Iif(cSx5 == "S",	"Solicitacao",;		//"Solicitacao"
							(Iif(cSx5 == "L",	"Lista de Espera",;	//"Lista de Espera"
												"Cancelado")))))) 	//"Cancelado"

		Local cMensagem := ""	// Conteudo de Retorno

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nome do Funcionario                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SRA")
		cFil:= xFilial("SRA", cFilAux)
		dbSeek(cFil+cMat)
		cNome	:= SRA->RA_NOME
		cTipomail := SRA->RA_TPMAIL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Curso                                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("RA1")
		cFil:= xFilial("RA1", cFilAux)
		dbSeek(cFil+cCurso)
		cDCurso	:= RA1->RA1_DESC

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calendario                                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("RA2")
		cFil:= xFilial("RA2", cFilAux)
		dbSeek(cFil+cCalend+cCurso+cTurma)
		cDCalend	:= RA2->RA2_DESC
		cLocal		:= RA2->RA2_LOCAL
		cDInicio	:= Dtoc(RA2->RA2_DATAIN)
		cDFim		:= Dtoc(RA2->RA2_DATAFI)
		cHorario	:= RA2->RA2_HORARI

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Instrutor                                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("RA7")
		cFil:= xFilial("RA7", cFilAux)
		dbSeek(cFil+RA2->RA2_INSTRU)
		cInstrut	:= RA7->RA7_NOME

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Entidade                                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("RA0")
		cFil:= xFilial("RA0", cFilAux)
		dbSeek(cFil+RA2->RA2_ENTIDA)
		cEntidade	:= RA0->RA0_DESC

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia e-mail: cTipoMail = "1" (Formato Html) ou = "2" (Formato Texto)       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipoMail == "2"
			cMensagem := Upper(cAssunto) + CHR(13)+CHR(10) 	+CHR(13)+CHR(10)//"CONFIRMACAO DE TREINAMENTO" ou "CANCELAMENTO DE TREINAMENTO"
			cMensagem += "Funcionario: " + cMat + " - " + cNome 		+CHR(13)+CHR(10)
			cMensagem += "Calendario: " + cCalend + " - " + cDCalend 	+CHR(13)+CHR(10)
			cMensagem += "Curso: " + cCurso + " - " + cDCurso 	+CHR(13)+CHR(10)
			cMensagem += "Turma: " + cTurma 						+CHR(13)+CHR(10)
			cMensagem += "Instrutor: " + cInstrut 					+CHR(13)+CHR(10)
			cMensagem += "Periodo: " + cDInicio + " a " + cDFim	+CHR(13)+CHR(10)
			cMensagem += "Horario: " + cHorario 					+CHR(13)+CHR(10)
			cMensagem += "Entidade: " + cEntidade 					+CHR(13)+CHR(10)
			cMensagem += "Local: " + cLocal       				+CHR(13)+CHR(10)
			cMensagem += "Situacao: " + cSituac						+CHR(13)+CHR(10)
			cMensagem += CHR(13)+CHR(10)

			cMensagem += "Observacoes: " 								+CHR(13)+CHR(10)
			cMensagem += cObs1									+CHR(13)+CHR(10)
			cMensagem += cObs2									+CHR(13)+CHR(10)
			cMensagem += cObs3									+CHR(13)+CHR(10)
			cMensagem += cObs4									+CHR(13)+CHR(10)
			cMensagem += cObs5									+CHR(13)+CHR(10)
			cMensagem += cObs6									+CHR(13)+CHR(10)
		Else
			cMensagem := '<html><title>'+cAssunto+'</title><body>'
			cMensagem += '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
			cMensagem += '<tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
			cMensagem += 'borderColorDark=v bgColor="#0099cc" height="1">'
			cMensagem += '<p align="center"><FONT face="Arial" color="#ffffff" size="4">'
			cMensagem += '<b>'+OemToAnsi(cAssunto)+'</b></font></p></td></tr>'
			cMensagem += '<tr><td align="left" width="606" height="32">'+'<br>'+'<p align="left">'+' <b>' + '<FONT face="Arial" color="#0099cc" size="2">' + OemtoAnsi("Funcionario: ") + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cMat + " - " + cNome + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Calendario: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cCalend + " - " + cDCalend + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Curso: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cCurso + " - " + cDCurso + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Turma: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cTurma + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Instrutor: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cInstrut + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Periodo: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cDInicio + '<b>' +" a " +'</b>'+ cDFim + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Horario: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cHorario + '</FONT>' +'<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Entidade: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cEntidade + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Local: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cLocal  + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + "Situacao: " + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cSituac + '</FONT>' +'<br>'
			cMensagem += '<br>'
			cMensagem += '<b> '+ '<FONT face="Arial" color="#0099cc" size="2">' + "Observacoes: " + '</font>'+'</b>'+'<br>'
			cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs1 + '</FONT>' +'<br>'
			cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs2 + '</FONT>' +'<br>'
			cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs3 + '</FONT>' +'<br>'
			cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs4 + '</FONT>' +'<br>'
			cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs5 + '</FONT>' +'<br>'
			cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs6 + '</FONT>' +'<br>'
			cMensagem += +'</p></td></tr>'
		EndIf

		Return cMensagem

		*/

	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia e-mail: cTipoMail = "1" (Formato Html) ou = "2" (Formato Texto)       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipoMail == "2"
			cMensagem := Upper(cAssunto) + CHR(13)+CHR(10) 	+CHR(13)+CHR(10)//"CONFIRMACAO DE TREINAMENTO" ou "CANCELAMENTO DE TREINAMENTO"
			cMensagem += STR0052 + cMat + " - " + cNome 		+CHR(13)+CHR(10)//"Funcionario: "
			cMensagem += STR0005 + cCalend + " - " + cDCalend 	+CHR(13)+CHR(10)//"Calendario: "
			cMensagem += STR0006 + cCurso + " - " + cDCurso 	+CHR(13)+CHR(10)//"Curso: "
			cMensagem += STR0007 + cTurma 						+CHR(13)+CHR(10)//"Turma: "
			cMensagem += STR0058 + cInstrut 					+CHR(13)+CHR(10)//"Instrutor: "
			cMensagem += STR0053 + cDInicio + STR0054 + cDFim	+CHR(13)+CHR(10)//"Periodo: "###" a "
			cMensagem += STR0055 + cHorario 					+CHR(13)+CHR(10)//"Horario: "
			cMensagem += STR0056 + cEntidade 					+CHR(13)+CHR(10)//"Entidade: "
			cMensagem += STR0057 + cLocal       				+CHR(13)+CHR(10)//"Local: "
			If cTipo <> '3'
				cMensagem += STR0041 + cSituac						+CHR(13)+CHR(10)//"Situacao: "
				cMensagem += CHR(13)+CHR(10)
				cMensagem += STR0062 								+CHR(13)+CHR(10)//"Observacoes: "
				cMensagem += cObs1									+CHR(13)+CHR(10)
				cMensagem += cObs2									+CHR(13)+CHR(10)
				cMensagem += cObs3									+CHR(13)+CHR(10)
				cMensagem += cObs4									+CHR(13)+CHR(10)
				cMensagem += cObs5									+CHR(13)+CHR(10)
				cMensagem += cObs6									+CHR(13)+CHR(10)
			EndIf
		Else
			cMensagem := '<html><title>'+cAssunto+'</title><body>'
			cMensagem += '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
			cMensagem += '<tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
			cMensagem += 'borderColorDark=v bgColor="#0099cc" height="1">'
			cMensagem += '<p align="center"><FONT face="Arial" color="#ffffff" size="4">'
			cMensagem += '<b>'+OemToAnsi(cAssunto)+'</b></font></p></td></tr>'
			cMensagem += '<tr><td align="left" width="606" height="32">'+'<br>'+'<p align="left">'+' <b>' + '<FONT face="Arial" color="#0099cc" size="2">' + OemtoAnsi(STR0052) + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cMat + " - " + cNome + '</FONT>' + '<br>'
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0005 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cCalend + " - " + cDCalend + '</FONT>' + '<br>'  //"Calendario: "
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0006 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cCurso + " - " + cDCurso + '</FONT>' + '<br>' 	//"Curso: "
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0007 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cTurma + '</FONT>' + '<br>'							   //"Turma: "
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0058 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cInstrut + '</FONT>' + '<br>' 							//"Instrutor: "
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0053 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cDInicio + '<b>' +STR0054 +'</b>'+ cDFim + '</FONT>' + '<br>'	//"Periodo: "###" a "
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0055 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cHorario + '</FONT>' +'<br>'							//"Horario: "
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0056 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cEntidade + '</FONT>' + '<br>' 						//"Entidade: "
			cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0057 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cLocal  + '</FONT>' + '<br>'     					   //"Local: "
			If cTipo <> '3'
				cMensagem += '<b>' + '<FONT face="Arial" color="#0099cc" size="2">' + STR0041 + '</FONT>' + '</b>' + '<FONT face="Arial" color="#666666" size="2">' + cSituac + '</FONT>' +'<br>'							   //"Situacao: "
				cMensagem += '<br>'
				cMensagem += '<b> '+ '<FONT face="Arial" color="#0099cc" size="2">' + STR0062 + '</font>'+'</b>'+'<br>'//"Observacoes: "
				cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs1 + '</FONT>' +'<br>'
				cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs2 + '</FONT>' +'<br>'
				cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs3 + '</FONT>' +'<br>'
				cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs4 + '</FONT>' +'<br>'
				cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs5 + '</FONT>' +'<br>'
				cMensagem += '<FONT face="Arial" color="#666666" size="2">' + cObs6 + '</FONT>' +'<br>'
			EndIf
			cMensagem += +'</p></td></tr>'
		EndIf
	EndIf

	dbSelectArea("RA3")

	If !lAutomatico
		MsgRun( OemToAnsi(STR0059),"",;	//"Aguarde. Enviando Email..."
				{||nErro := Rh_Email(NIL, cEmailSup, cAssunto, cMensagem, NIL, cFilAux+cMat)})
		RH_ErroMail(nErro,cNome)
	Else
		nErro := Rh_Email(,cEmailSup,cAssunto,cMensagem,,cFilAux+cMat)
	EndIf

	If nErro == 0
		If cTipo <> '3'
			RecLock("RA3",.F.)
				RA3->RA3_EMAIL := "S"				//Email enviado
				RA3->RA3_DTAVIS := dDataBase 	//Data do ultimo envio de e-mail
			RA3->( MsUnlock() )
		EndIf
	EndIf
EndIf

//verifica se tem checklist ativado e o atualiza
If !Empty(RA1->RA1_CJETAP)
	If cTipo == '1'
		nRecno := GetChkList(RA3->RA3_FILIAL,RA3->RA3_MAT,RA1->RA1_CJETAP,"2",RA3->RA3_CURSO)
	ElseIf cTipo == '3'
		nRecno := GetChkList(RA4->RA4_FILIAL,RA4->RA4_MAT,RA1->RA1_CJETAP,"3",RA4->RA4_CURSO)
	EndIf
	If nRecno > 0
		UpdEtapa(nRecno,If(cTipo <> '3',RA2->RA2_DATAIN,))
	EndIf
EndIf

RestArea(aSaveArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr060Busca³ Autor ³ Emerson Grassi Rocha ³ Data ³ 19/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca funcionario atraves de nome informado 		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr060Busca()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trma060       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr060Busca(cFil, cNome, cMatr, cTipo)

Local cPesqFun	:= ""
Local nOrdFun	:= 1
Default cMatr 	:= ""
Default cNome   := ""
Default cTipo   := "1"

cPesqFun	:= cNome

If Empty(cNome) .And. Empty(cMatr)
	RETURN
Endif

dbSelectArea("TR1")

If cTipo == "1"
	dbSetOrder(1) 	//Nome
else
	dbSetOrder(2) 	//Matricula
	cPesqFun:= cMatr
	nOrdFun	:= 2
Endif

If PsqTR1 (cFil, cPesqFun, nOrdFun)
	o1Lbx:Refresh()
	o1Lbx:SetFocus()
Else
	dbGoTop()
	o1Lbx:Refresh()
EndIf

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Ra2AvisVld³ Autor ³ Emerson Grassi Rocha ³ Data ³ 06/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo RA2_AVISO.					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ra2AvisVld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trma060       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ra2AvisVld()

Local lRet 	:= .T.
Local nX	:= 0

cDias := Alltrim(M->RA2_AVISO)

For nX := 1 To Len(cDias)
	cChar := Subst(cDias,nX,1)
	If ! (Asc(cChar) >= 48 .And. Asc(cChar) <= 57 .Or. cChar == ",")
		lRet := .F.
		Aviso(STR0035, STR0071, {"Ok"})	//"Atencao"###"Deve ser informados apenas numeros separados por virgula(,)"
		Exit
	Endif
Next nX

Return lRet


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³22/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMA060                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

Local aRotina :=   {	{ STR0001,'PesqBrw'			, 0,1,,.F.},;	//"Pesquisar"
						{ STR0003,'Tr060Rot'		, 0,4},;		//"Reservar"
						{ STR0090,'TR060VIS'		, 0,2},;		//"Visualizar"
						{ STR0051,'Tr060Leg'		, 0,2,,.F.}}	//"Legenda"


Return aRotina


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr060FunCar³ Autor ³Eduardo Ju            ³ Data ³12.07.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verificacao da amarracao da Funcao ao Cargo.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr060FunCar()

Local aSaveArea	:= GetArea()
Local lRet := .T.
Local lMsg := .T.

dbSelectArea("SRJ")
dbSetOrder(1)
If dbSeek( xFilial("SRJ") + TR1->TR1_FUNCAO )
	If Empty(SRJ->RJ_CARGO)

		dbSelectArea("SRA")
		dbSetOrder(1)

		If dbSeek( xFilial("SRA") + TR1->TR1_MAT )
			If Empty(SRA->RA_CARGO)
				lMsg := .F.
				MsgAlert(STR0072,STR0073)	//"Para efetuar a Reserva de Treinamento, primeiramente, defina o cargo ao funcionário ou à função.","Integridadade da Informações na Reserva de Treinamento")
				lRet := .F.
			Else
				lMsg := .F.
				lRet := .T.
			EndIf
		EndIf

		If lMsg
			MsgAlert(STR0072,STR0073)	//"Para efetuar a Reserva de Treinamento, primeiramente, defina o cargo ao funcionário ou à função.","Integridadade da Informações na Reserva de Treinamento")
			lRet := .F.
		EndIf

	EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tr060PEGrv ³ Autor ³Leandro Dr.           ³ Data ³18.11.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verificacao da amarracao da Funcao ao Cargo.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr060PEGrv(cAlias,nReg,nOpcx,cCalend,cCurso,cTurma)
Local aList  := aClone(a2Lbx)
Local aItens := {cAlias,nReg,nOpcx,cCalend,cCurso,cTurma}
LOcal nRet   := 1

If ExistBlock("TRM06001")
	nRet := ExecBlock("TRM06001",.F.,.F.,{aItens,aList})
EndIF

Return nRet

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³CpoSpace     	³Autor³Mauricio MR         ³ Data ³29/07/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Funcao utilizada, por exemplo, em Log para calculo do tamanho³
³          ³dos titulos e espacamento entre os Campos informados. Dessa  ³
³          ³forma nao eh preciso traducao e contagem de espacamento entre³
³          ³as informacoes a serem listadas.							 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                             	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³TRMA060					                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function CpoSpace(	aCpos	,;  //01 - Campos informados
							aTitCpo	,;  //02 - Titulo posicionamento ajustado
							aTamCpo	;   //03 - espacamento para posicionar os campos
						 )
Local aSvAlias	:= GetArea()
Local nOrderSX3	:= SX3->(IndexOrd())

Local cTitulo
Local cSpcCpo
Local nTamanho
Local nMaxTam
Local nX

SX3->(DbSetOrder(2))

For nX:= 1 to  Len(aCpos)
    SX3->(Dbseek( aCpos[nx] ))

    cTitulo := Alltrim(X3TITULO(SX3->X3_TITULO))
    nTamanho:= Len(cTitulo)
    nMaxtam	:= Max( Len(cTitulo		), TamSx3(aCpos[nx]	)[1] )
    cSpcCpo	:= Space(nMaxTam 	- TamSx3(aCpos[nx] 	)[1] )
    Aadd(aTitCpo,Padr(cTitulo,nMaxTam) )
    Aadd(aTamCpo,cSpcCpo)
Next nX

SX3->(DbSetOrder(nOrderSX3))
RestArea(aSvAlias)
Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} TRMA060EPMInt

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TRMA060EPMInt()
	Local cTreinamento := ''
	Local oWSMatricula, oMatricula

	If SuperGetMv("MV_TRMINTG", NIL, .F.)
		If Empty(RA1->RA1_FILIAL)
			cTreinamento := alltrim(RA3->RA3_CURSO)
		Else
			cTreinamento := ltrim(xFilial("RA1", RA3->RA3_FILIAL) + alltrim(RA3->RA3_CURSO))
		EndIf

		oWSMatricula:= EPMWSNew("Matricula")

		If RA3->RA3_RESERV == "R"
			oMatricula:= MatriculaWSService_MatriculaWSHolder():New()
			oMatricula:cCdExterno			 := cTreinamento + alltrim(RA3->RA3_MAT) + alltrim(Str(RA3->(RECNO()))) + DTOS(RA3->RA3_DATA)
			oMatricula:cCdTreinamentoExterno := cTreinamento
			oMatricula:cCdUsuarioExterno	 := RA3->RA3_FILIAL + alltrim(RA3->RA3_MAT)
			oMatricula:nSituacao			 := 2				//0=INATIVO; 1=PENDENTE; 2=MATRICULADO; 3=INICIADO; 4=CANCELADO, 5=FINALIZADO; 6=FINALIZADO_NOPRETESTE; 7=ACONFIRMAR
			oMatricula:nStatusAprovacao		 := 0				//0=INDEFINIDO; 1=COM_EXITO; 2=SEM_EXITO; 3=APROVADO; 4=REPROVADO; 5=SEM_EXITO_EXPIRADO
			oMatricula:cDataMatricula 		 := fFormatDate(RA3->RA3_DATA)
			oMatricula:cDataFim				 := ""
			oMatricula:cDataInicio 			 := ""
			oMatricula:cTipoMatricula		 := "TREINAMENTO"
			oMatricula:cCdUnidadePaiExterno	 := cEmpAnt
			oMatricula:cCdUnidadeExterno	 := FWCodFil()
			oMatricula:nScorePreTeste		 := NIL
			oMatricula:nScorePosTeste		 := NIL
			oMatricula:nScoreAvaliacaoReacao := NIL
			oMatricula:cCodigoPreTeste		 := ""
			oMatricula:cCodigoPosTeste		 := ""
			oMatricula:cCodigoAvaliacaoReacao:= ""

			If !oWSMatricula:InsertMatricula(oMatricula)
				Alert("Nao foi possivel gravar a reserva de treinamento no EPM!")
			EndIF
		Else
			If  Empty(RA3->RA3_RESERV)
				If !oWSMatricula:deleteMatricula(xFilial("RA1", RA3->RA3_FILIAL) + alltrim(RA3->RA3_CURSO) + alltrim(RA3->RA3_MAT) + alltrim(Str(RA3->(RECNO()))) + DTOS(RA3->RA3_DATA))
					Alert("Nao foi possivel deletar a reserva de treinamento no EPM!")
				EndIf
			Endif
		EndIf
	EndIf
Return

Static Function fFormatDate(dData)
	Local cRet:= Day2Str(dData) + "/" + Month2Str(dData) + "/" + Year2Str(dData)
Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} fChkResPre

@author Igor Franzoi
@since 16/07/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fChkResPre( cFilDe, cFilAte, cCalend, cCurso, cTurma, nTotReg, cType ,lVisual)

Local aArea		:= GetArea()

Local cAliasQry	:= "RA3"
Local cFilterAux:= ""

Local nTotRes	:= 0

DEFAULT cType	:= "R"
DEFAULT lMantem := .F.

cAliasQry  := GetNextAlias()

cFilterAux := "% ( RA3.RA3_FILIAL < '" + cFilDe +"' OR RA3.RA3_FILIAL > '" + cFilAte +"' ) "
cFilterAux += "  AND RA3.RA3_CALEND = '" + cCalend	+ "' "
cFilterAux += "  AND RA3.RA3_CURSO	= '" + cCurso	+ "' "
cFilterAux += "  AND RA3.RA3_TURMA	= '" + cTurma	+ "' "
cFilterAux += "  AND RA3.RA3_RESERV	= '" + cType	+ "' %"

BeginSql alias cAliasQry

	SELECT COUNT(*) TOTREG
	FROM 	%table:RA3% RA3
	WHERE 	%exp:cFilterAux%
			AND RA3.%NotDel%

EndSql

nTotRes := (cAliasQry)->(TOTREG)
(cAliasQry)->(dbCloseArea())

If ! lAutoExec .And. !lVisual
	If ( (nTotRes > 0) .and. (cType == "R") )
		If MsgNoYes( OemToAnsi(STR0081), OemToAnsi(STR0035) ) //"Já existem reservas para este Treinamento! Deseja Mante-las?" "Atençäo"
			lMantem := .T.
			nTotReg := nTotRes
		Else
			BeginSql alias cAliasQry

				SELECT RA3.R_E_C_N_O_
				FROM 	%table:RA3% RA3
				WHERE 	%exp:cFilterAux%
						AND RA3.%NotDel%

			EndSql

			While ( (cAliasQry)->(!Eof()) )
				aAdd( aRecRA3, (cAliasQry)->(Recno()) )
				(cAliasQry)->(dbSkip())
			EndDo

			(cAliasQry)->(dbCloseArea())

		EndIf

	ElseIf ( nTotRes > 0 ) .and. ( (cType == "L") .or. (cType == "S" ) )
		nTotReg := nTotRes
	EndIf
Else
	lMantem := .T.
	nTotReg := nTotRes
EndIf



RestArea(aArea)

Return (Nil)



/*/{Protheus.doc} vldAuto
Verifica os campos enviados para a rotina automática
@author Cícero Alves
@since 20/10/2015
@version P12
@param aCab, Array, Campos do cabeçalho
@param aItens, Array, Campos do grid
/*/
Static Function vldAuto(aCab, aItens)

	Local lCabOk	:= .F.
	Local lItensOk	:= .T.
	Local lRet		:= .F.
	Local nI		:= 0

	If aScan( aCab, { |x| AllTrim(x[1]) == "RA2_FILIAL" }) > 0
		If aScan( aCab, { |x| AllTrim(x[1]) == "RA2_CURSO" }) > 0
			If aScan( aCab, { |x| AllTrim(x[1]) == "RA2_TURMA" }) > 0
				If aScan( aCab, { |x| AllTrim(x[1]) == "RA2_CALEND" }) > 0
					If aScan( aCab, { |x| AllTrim(x[1]) == "RA2_MAIL" }) > 0
						lCabOk	:= .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	For nI := 1 To Len(aItens)
		If ! aScan( aItens[nI], { |x| AllTrim(x[1]) == "RA3_FILIAL" }) > 0
			lItensOk	:= .F.
			Exit
		EndIf
		If ! aScan( aItens[nI], { |x| AllTrim(x[1]) == "RA3_MAT" }) > 0
			lItensOk	:= .F.
			Exit
		EndIf
		If ! aScan( aItens[nI], { |x| AllTrim(x[1]) == "RA3_RESERV" }) > 0
			lItensOk	:= .F.
			Exit
		EndIf
	Next

	If lItensOk .AND. lCabOk
		lRet := .T.
	Else
		Help(" ",1,"OBRIGAT")
		lMsErroAuto := .T.
		Return
	EndIf

return lRet

Static function MailSup(cFilfun,cMatFun,cDepto,cEmailSup)
Local aArea := GetArea()
Local aSuperior := {}
Local aDeptos 	:= {}
Local lRet		:= .F.
DEFAULT cEmailSup := ""
If cTypeOrg == "0"
	aDeptos := fEstrutDepto( cFilfun )
EndIf
aSuperior := fBuscaSuperior(cFilfun, cMatFun, cDepto, aDeptos, cTypeOrg, cVision)
If Len(aSuperior) > 0 .AND. aSuperior[1][4] != 99
	lRet := .T.
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(dbSeek(aSuperior[1][1]+ aSuperior[1][2]))
		cEmailSup := ALLTRIM(SRA->RA_EMAIL)
	EndIf
EndIf

If Empty(cEmailSup) //email default de superior caso esteja em branco
	cEmailSup := SuperGetMv("MV_EMAILDE")
EndIf
RestArea(aArea)

Return lRet

Function TR060VIS(cAlias, nReg, nOpcx)

Local oDlgMain, oGroup, oGroup1, oGroup2, oGroup3, oGroup4
Local oBtn1, oBtn2, oBtn3, oSay1
Local oReserva, oLista, oSolic
Local oOk, oNo, o1Ok
Local nx, nI		:= 0
Local aAux			:= {}
Local cCurso		:= ""
Local cTurma		:= ""
Local cCalend 		:= ""
Local cDescCalend	:= ""
Local cDescCurso	:= CriaVar("RA1_CURSO")
Local cPerg
Local lReserva		:= .F.
Local lLista		:= .F.
Local lSolic		:= .F.
Local oSelFunc, oSelSolic
Local lSelFunc 		:= .F.
Local lSelSolic 	:= .F.
Local c1Lbx			:= ""
Local c2Lbx			:= ""
Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local aSaveArea		:= GetArea()
Local cFiltro		:= ""
Local oBmp1, oBmp2, oBmp3
Local oVerde, oAmarelo, oVermelho, oAzul, oMarrom
Local oFont
Local lVisual 		:= .T.
Local lRet		:= .F.

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAdv22Size	:= {}
Local aInfo22AdvSize:= {}
Local aObj22Size	:= {}
Local aObj22Coords	:= {}

Local aAdv23Size	:= {}
Local aInfo23AdvSize:= {}
Local aObj23Size	:= {}
Local aObj23Coords	:= {}

Local aAdv24Size	:= {}
Local aInfo24AdvSize:= {}
Local aObj24Size	:= {}
Local aObj24Coords	:= {}

Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords	:= {}

Local aAdv41Size	:= {}
Local aInfo41AdvSize:= {}
Local aObj41Size	:= {}
Local aObj41Coords	:= {}

Local aAdv32Size	:= {}
Local aInfo32AdvSize:= {}
Local aObj32Size	:= {}
Local aObj32Coords	:= {}

Private cLista	:= ""
Private cSolic	:= ""
Private cArqNtx	:= ""
Private cReserv	:= StrZero(RA2->RA2_RESERV,4)
Private cVagas	:= StrZero(RA2->RA2_VAGAS,4)
Private a2Lbx	:= {}
Private aRecRA3 := {}
Private oSay2, oSay3, oSay4
Private o2Lbx
Private cFilDe	:= rTrim(xFilial("RA2"))
Private cFilAte	:=  cFilDe + Replicate("Z",FWGETTAMFILIAL-Len(cFilDe))
Private cSituacao := ""

Private lMantem := .T. //Mantem a reserva efetuada anteriormente em caso de RA2 compartilhado, conforme decisao do usuario

cCurso		:= RA2->RA2_CURSO
cTurma		:= RA2->RA2_TURMA
cCalend 	:= RA2->RA2_CALEND
cDescCalend	:= RA2->RA2_DESC

If RA2->RA2_REALIZ == "S"
	Help("",1,"TRA070BAIX")			// Este curso ja foi baixado
	RestArea(aSaveArea)
	Return
EndIf

oOk 	 := LoadBitmap( GetResources(), "Enable" )
oNo 	 := LoadBitmap( GetResources(), "LBNO" )
o1Ok 	 := LoadBitmap( GetResources(), "LBOK" )

oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
oAmarelo := LoadBitmap( GetResources(), "BR_AMARELO" )
oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
oAzul	 := LoadBitmap( GetResources(), "BR_AZUL" )
oMarrom  := LoadBitmap( GetResources(), "BR_MARROM" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Curso                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA1")
dbSetOrder(1)
If dbSeek(xFilial("RA1")+cCurso)
	cDescCurso := RA1->RA1_DESC
EndIf

	Processa({||lRet:=Tr060Monta(cAlias,cCurso,cTurma,cCalend,cFiltro, RA2->RA2_FILIAL,lVisual)},OemToAnsi(STR0050)+OemToAnsi(STR0049)) //"Aguarde..."###" Montando tela de Reserva"


	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta as Dimensoes dos Objetos         					     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= {aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 5}
		aAdd( aObjCoords , { 000, 022 , .T. , .F. } )
		aAdd( aObjCoords , { 000, 000 , .T. , .T. } )
		aAdd( aObjCoords , { 000, 024 , .T. , .F. } )
		aAdd( aObjCoords , { 000, 024 , .T. , .F. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		//Divisão em 3 colunas a linha 1
		aAdv1Size		:= aClone(aObjSize[1])
		aInfo1AdvSize	:= {aAdv1Size[2], aAdv1Size[1], aAdv1Size[4], aAdv1Size[3], 1, 1}
		aAdd( aObj1Coords , { 120, 000 , .F. , .T. } )		//1-Curso
		aAdd( aObj1Coords , { 000, 000 , .T. , .T. } )		//2-Calendario
		aAdd( aObj1Coords , { 040, 000 , .F. , .T. } )		//3-Turma
		aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

		//Divisão em 2 colunas a linha 2
		aAdv2Size		:= aClone(aObjSize[2])
		aInfo2AdvSize	:= {aAdv2Size[2], aAdv2Size[1], aAdv2Size[4], aAdv2Size[3], 1, 1}
		aAdd( aObj2Coords , { 000, 000 , .T. , .T. , .T. } )	//1-Funcionarios a realizar Curso
		aAdd( aObj2Coords , { 000, 000 , .T. , .T. } )			//2-Vagas / Funcionarios Reservados p/ Curso
		aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

		aAdv22Size		:= aClone(aObjSize[2])
		aInfo22AdvSize	:= {aAdv22Size[2], aAdv22Size[1], aAdv22Size[4], aAdv22Size[3], 1, 0}
		aAdd( aObj22Coords , { 000, 000 , .T. , .F. } )			//1-Vagas
		aAdd( aObj22Coords , { 000, 000 , .T. , .F. } )			//2-Espaco
		aAdd( aObj22Coords , { 000, 000 , .T. , .T. , .T. } )		//3-Funcionarios Reservados p/ Curso
		aObj22Size		:= MsObjSize( aInfo22AdvSize , aObj22Coords )

				//Divisão em 2 colunas a linha 3 - Coord usada tb na linha 4
		aAdv3Size		:= aClone(aObjSize[3])
		aInfo3AdvSize	:= {aAdv3Size[2], aAdv3Size[1], aAdv3Size[4], aAdv3Size[3], 5, 5}
		aAdd( aObj3Coords , { 000, 000 , .T. , .T.  } )		//1-
		aAdd( aObj3Coords , { 000, 000 , .T. , .T. } )			//2-
		aObj3Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords,,.T. )

		//Divisão da Linha 1-Vagas em 2 linhas
		aAdv23Size		:= aClone(aObj3Size[2])
		aInfo23AdvSize	:= {aAdv23Size[2], aAdv23Size[1], aAdv23Size[4], aAdv23Size[3], 5, 10}
		aAdd( aObj23Coords , { 000, 000 , .T. , .T. } )		//1-Linha 1 Vaga
		aAdd( aObj23Coords , { 000, 000 , .T. , .T. } )		//2-Linha 2 Vaga
		aObj23Size		:= MsObjSize( aInfo23AdvSize , aObj23Coords )

		//Divisão da Linha 1-Vagas em 5 colunas
		aAdv24Size		:= aClone(aObj3Size[2])
		aInfo24AdvSize	:= {aAdv24Size[2], aAdv24Size[1], aAdv24Size[4], aAdv24Size[3], 15, 10}
		aAdd( aObj24Coords , { 037, 000 , .F. , .T. } )		//1-Say Descricao
		aAdd( aObj24Coords , { 035, 000 , .F. , .T. } )		//2-Say Total
		aAdd( aObj24Coords , { 010, 000 , .F. , .T. } )		//3-Espaco
		aAdd( aObj24Coords , { 037, 000 , .F. , .T. } )		//2-Say Descricao
		aAdd( aObj24Coords , { 035, 000 , .F. , .T. } )		//2-Say Total
		aObj24Size		:= MsObjSize( aInfo24AdvSize , aObj24Coords,, .T. )



		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

		DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL
			@ aObj1Size[1,1], aObj1Size[1,2]		GROUP oGroup	TO aObj1Size[1,3], aObj1Size[1,4] PROMPT OemToAnsi(STR0005)	OF oDlgMain	PIXEL			//"Calend rio: "
			@ aObj1Size[1,1]+10, aObj1Size[1,2]+5	SAY cCalend + " - " + cDescCalend PIXEL
			oGroup:oFont:= oFont

			@ aObj1Size[2,1], aObj1Size[2,2]		GROUP oGroup	TO aObj1Size[2,3], aObj1Size[2,4] PROMPT OemToAnsi(STR0006)	OF oDlgMain	PIXEL			//Curso: "
			@ aObj1Size[2,1]+10, aObj1Size[2,2]+5	SAY cCurso + " - " + Subst(cDescCurso,1,20) PIXEL
			oGroup:oFont:= oFont

			@ aObj1Size[3,1], aObj1Size[3,2]		GROUP oGroup 	TO aObj1Size[3,3], aObj1Size[3,4] PROMPT OemToAnsi(STR0007) OF oDlgMain PIXEL			//Turma: "
			@ aObj1Size[3,1]+8, aObj1Size[3,2]+5	SAY cTurma PIXEL
			oGroup:oFont:= oFont

			@ aObj22Size[3,1], aObj22Size[3,2] LISTBOX o2Lbx FIELDS;
						HEADER	OemtoAnsi(STR0025),;	  					//"R"
								OemtoAnsi(STR0026),;						//"L"
								OemtoAnsi(STR0027),;						//"S"
								OemtoAnsi(STR0066),;						//"Sit.
								OemtoAnsi(STR0028),;						//"Nome"
								OemtoAnsi(STR0029),;						//"Matricula"
								OemtoAnsi(STR0030),;						//"Filial"
								OemtoAnsi(STR0031),;						//"Lista Espera"
								OemtoAnsi(STR0091),;						//"Centro Custo"
								OemtoAnsi(STR0092),;						//"Descr. Centro Custo"
								OemtoAnsi(STR0093),;						//"Função"
								OemtoAnsi(STR0094)	;						//"Descr. Função"
				 		SIZE aObj22Size[3,3], aObj22Size[3,4];
						OF oDlgMain PIXEL


			o2Lbx:SetArray(a2Lbx)
			o2Lbx:nFreeze := 4

			o2Lbx:bLine:= {||{ 	If(a2Lbx[o2Lbx:nAt,1],o1Ok,oNo),;
										If(a2Lbx[o2Lbx:nAt,2],o1Ok,oNo),;
										If(a2Lbx[o2Lbx:nAt,3],o1Ok,oNo),;
										If(a2Lbx[o2Lbx:nAt,4]==" ",oVerde, (Iif(a2Lbx[o2Lbx:nAt,4]=="D" .Or. a2Lbx[o2Lbx:nAt,4]=="T",oVermelho,(Iif(a2Lbx[o2Lbx:nAt,4]=="A", oAmarelo,(Iif(a2Lbx[o2Lbx:nAt,4]=="F",oAzul,oMarrom))))))),;
											a2Lbx[o2Lbx:nAt,5],;
											a2Lbx[o2Lbx:nAt,6],;
											a2Lbx[o2Lbx:nAt,7],;
											a2Lbx[o2Lbx:nAt,8],;
											a2Lbx[o2Lbx:nAt,9],;
											a2Lbx[o2Lbx:nAt,10],;
											a2Lbx[o2Lbx:nAt,11],;
											a2Lbx[o2Lbx:nAt,12]}}

			//Proteção de Dados Sensíveis
			If aOfusca[2]
				aOfuscaCpo := {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}
				aAvFields  := {" "," "," "," ","RA_NOME","RA_MAT","RA_FILIAL"," ","RA_CC","RA_DESCCC","RA_CODFUNC","RA_DESCFUN"}
				aPDFields := FwProtectedDataUtil():UsrNoAccessFieldsInList( aAvFields )
				o2Lbx:lObfuscate := .T.
				For nX := 1 to Len(aPDFields)
					nPos := aScan(aAvFields, {|x| x == aPDFields[nX]:cField})
					aOfuscaCpo[nPos] := .T.
				Next nX
				o2Lbx:aObfuscatedCols := aOfuscaCpo
			EndIf


			@  aObjSize[3,1] , aObjSize[3,2] GROUP oGroup TO aObjSize[3,3] , aObj3Size[1,4] PROMPT OemtoAnsi(STR0023) OF oDlgMain	PIXEL	//" Seleciona / Nao Seleciona "
			@  aObjSize[3,1]+10 , aObjSize[3,2]+7 SAY OemtoAnsi(STR0024) SIZE 236,7 PIXEL	//"R=Reservado L=Lista Espera S=Solicitação P=Portal G=Gestor C=Concluido"
			oGroup:oFont:= oFont


			@ aObjSize[3,1] , aObj3Size[2,2] GROUP oGroup TO aObjSize[4,3], aObjSize[4,4] PROMPT OemToAnsi(STR0008) OF oDlgMain PIXEL		//"Vagas:"
			oGroup:oFont:= oFont

			@ aObj23Size[1,1], aObj24Size[1,2] SAY OemToAnsi(STR0077)		PIXEL			//"Disponível:"
			@ aObj23Size[1,1], aObj24Size[2,2] SAY oSay1 PROMPT cVagas	PIXEL

			@ aObj23Size[2,1] +15, aObj24Size[1,2] SAY OemToAnsi(STR0009)		PIXEL			//"R=Reservas:"
			@ aObj23Size[2,1] +15, aObj24Size[2,2] SAY oSay2 PROMPT cReserv	PIXEL

			@ aObj23Size[1,1], aObj24Size[4,2] SAY OemToAnsi(STR0010)		PIXEL			//"L=Lista Esp:"
			@ aObj23Size[1,1], aObj24Size[5,2] SAY oSay3 PROMPT cLista	PIXEL

			@ aObj23Size[2,1]+15, aObj24Size[4,2] SAY OemToAnsi(STR0011)		PIXEL			//"S=Solicitar:"
			@ aObj23Size[2,1]+15, aObj24Size[5,2] SAY oSay4 PROMPT cSolic	PIXEL

		ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{|| oDlgMain:End()},{|| oDlgMain:End()} ))


    EndIf



DeleteObject(oOk)
DeleteObject(oNo)
DeleteObject(o1Ok)

RestArea(aSaveArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PsqTR1

@author Oswaldo L.
@since 16/04/2017
@version 12.1.17
/*/
Static Function PsqTR1(cFil, cDado, nIndice)
Local lRet       := .F.
local cPesquisa  := cFil + cDado

dbSelectArea("TR1")
dbGoTop()

If nIndice == 1
	dbSetOrder(1) 	//FILIAL+NOME
else
	dbSetOrder(2) 	//FILIAL+MATRICULA
endif

If dbSeek(cPesquisa)
	lRet := .T.
EndIf

return lRet
