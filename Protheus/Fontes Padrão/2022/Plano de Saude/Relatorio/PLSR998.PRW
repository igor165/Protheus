#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "PLSMGER.CH"
#INCLUDE "RPTDEF.CH"
#include "PLSR998.CH"

#DEFINE	 IMP_PDF 6
#DEFINE PLSMONEY "@E 99,999,999,999.99"
#DEFINE __RELIMP PLSMUDSIS(getWebDir() + getSkinPls() + "\relatorios\")

#define COL1 0
#define COL2 45  
 Static objCENFUNLGP := CENFUNLGP():New() 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR998 ³ Autor ³ Angelo Sperandio       ³ Data ³ 03.02.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Extrato de Movimentacao da RDA                             ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR998()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR998(cProtoc)
Local lCentury      := __setcentury()
LOCAL aSx1Stru      := SX1->( DbStruct() )
LOCAL nTamPerg      := aSx1Stru[1,3]
Local aAlias		:= {}
PRIVATE nQtdLin	    := 68
PRIVATE cNomeProg   := "PLSR998"
PRIVATE nCaracter   := 15
PRIVATE nLimite     := 80
PRIVATE cTamanho    := "P"
PRIVATE cTitulo     := "PROTOCOLO DE REEMBOLSO"
PRIVATE cDesc1      := "Emite o protocolo de reembolso"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BOW"
PRIVATE cPerg       := ""// "PLR673" + space(nTamPerg - 6)
PRIVATE cRel        := "PLSR998"
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {"Protocolo"}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 00
PRIVATE nLi         := 0
PRIVATE nLinPag     := 68
PRIVATE pMoeda1     := "@E 999,999.99"
PRIVATE pMoeda2     := "@E 999,999,999.99"
PRIVATE nTamDes     := 35
PRIVATE lImpZero
PRIVATE aRet := {.T.,""}
PRIVATE aLog  := {}
Private b998Err := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o UPD foi executado                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(PLSALIASEXI("BOW") .AND. PLSALIASEXI("BOX"))
	MsgAlert("As tabelas BOW e BOX não existem. Execute o UPDPLSB0!")
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,{},lCompres,cTamanho,{},lFiltro,lCrystal)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nLastKey  == 27
	If  lCentury
		set century on
	Endif
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cAlias)

nTipQbc := aReturn[8]

aAlias := {"BOW","BA1","BI3"} 
objCENFUNLGP:setAlias(aAlias) 

MsAguarde({|| R998Imp(cProtoc) }, cTitulo, "", .T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera filtro do BD7                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ms_flush()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lCentury
	set century on
Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R998Imp  ³ Autor ³ Angelo Sperandio      ³ Data ³ 03.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime o extrato mensal dos servicos prestados            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function R998Imp(cProtoc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCdOper	:= RETCODUSR()
Local cNomOpe	:= USRRETNAME(cCdOper)
Local cOBS		:= ""
Local cObsAux	:= ""
Local nLinhas	:= 0
Local nLin		:= 0
Local nI		:= 0
Local nPos		:= 0
Local nLen		:= 0
LOCAL cCodPla 	:= ""
LOCAL cVerPla 	:= ""
LOCAL cDesPla		:= ""
LOCAL cNomeEmp	:= ""
LOCAL cNomeFil	:= ""
LOCAL nCnt			:= ""
LOCAL cCodiGer 	:= ""
LOCAL cTipReemb	:= ""
LOCAL aRet 		:= {}
LOCAL cNomeCli	:= ""
LOCAL nRecSM0	:= 0
Local cMvCOMP      := GetMv("MV_COMP")
Local cMvNORM      := GetMv("MV_NORM")

// Integridade referencial.
If BOW->(Eof())
	MsgAlert("Selecione um procotolo de reembolso para fazer a impressão.")
	Return()
Endif

// Garante que o protocolo estará posicionado.
If BOW->BOW_PROTOC <> cProtoc
	BOW->(dbSetorder(01))
	If !BOW->(dbSeek(xFilial("BOW")+cProtoc))
		MsgAlert("Não foi possivel localizar o protocolo informado.")
		Return()
	Endif
Endif

// Posiciona as demais tabelas.
BA1->(dbSetorder(02))
If !BA1->(dbSeek(xFilial("BA1")+BOW->BOW_USUARI))
	MsgAlert("O usuário não foi localizado")
	Return()
Endif

BA3->(dbSetorder(01))
If !BA3->(dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
	MsgAlert("A família não foi localizada")
	Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mensagem de processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsProcTxt("Verificando... " + Left(AllTrim(cProtoc),30))
ProcessMessages()

// Obtem o código/nome da empresa.
nRecSM0 := SM0->(Recno())
	SM0->(dbSetOrder(01))
	If SM0->(dbSeek(BOW->BOW_EMPMOV))
		cNomeEmp := FWCompany()//SM0->M0_NOMECOM
		cNomeFil := FWFilialName()//SM0->M0_FILIAL
	Endif

	cCodiGer := cFilAnt

SM0->(dbGoto(nRecSM0))

// Registra o codigo do produto do usu'ario
If !Empty(BA1->BA1_CODPLA)
	cCodPla := BA1->BA1_CODPLA
	cVerPla := BA1->BA1_VERSAO
Else
	cCodPla := BA3->BA3_CODPLA
	cVerPla := BA3->BA3_VERSAO
Endif
cDesPla := Posicione("BI3",1,xFilial("BI3")+BA1->BA1_CODINT+cCodPla+cVerPla,"BI3_DESCRI")

// CAMPO CUSTOMIZADO - RETIRAR ANTES DE SUBIR.
// - Lista de opções: 1=Procedimento;2=Medicamento;3=Med Quimeoterapicos
If BOW->(FieldPos("BOW_XTIPRE")) > 0 .and. !Empty(BOW->BOW_XTIPRE)
	aRet := RetSx3Box( X3CBox( Posicione('SX3',2,"BOW_XTIPRE",'X3_CBOX') ),,,1 )
	If Val(BOW->BOW_XTIPRE) <= Len(aRet)
		cTipReemb := aRet[Val(BOW->BOW_XTIPRE)][3]
	Endif
Endif

If Empty(cTipReemb)
	cTipReemb := "Não informado."
Endif

SA1->(dbSetorder(01))
If SA1->(dbSeek(xFilial("SA1")+BOW->BOW_CODCLI+BOW->BOW_LOJA))
	cNomeCli := Alltrim(SA1->A1_NOME)

Else
	cNomeCli := "Não informado"

Endif

// Campo de observacao
cObs := BOW->BOW_OBS

// Imprime o cabecalho do relatorio.
nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
nLi++

For nCnt := 1 to 2

	If nLi > nQtdLin
		nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
	Endif

	@ nLi, COL1 pSay Padc(Alltrim(cNomeEmp) + "-" + Alltrim(cNomeFil),80)
	nLi++

	/*
	CAMPO CUSTOMIZADO - Retirar antes de subir.
	*/
	@ nLi, COL1 pSay "Filial:   " + cCodiGer
	nLi ++

	@ nLi, COL1 pSay "SOLICITACAO DE REEMBOLSO  Nr." + objCENFUNLGP:verCamNPR( "BOW_PROTOC", cProtoc )
	nLi++

	@ nLi, COL1 pSay Replicate("=", 80)
	nLi++

	@ nLi, COL1 pSay "Nome do Contratante: "+ objCENFUNLGP:verCamNPR( "BOW_NOMCLI", Alltrim(BOW->BOW_NOMCLI) )
	nLi++

	@ nLi, COL1 pSay "Codigo Contratante : "+ objCENFUNLGP:verCamNPR( "BOW_CODCLI)", Alltrim(BOW->BOW_CODCLI) )
	nLi++

	@ nLi, COL1 pSay "Termo de Adesao    : "+ objCENFUNLGP:verCamNPR( "BA1_MATRIC", BA1->BA1_MATRIC )
	@ nLi, COL2 pSay "Filial : "+ cFilAnt
	nLi++

	@ nLi, COL1 pSay "CPF                : "+objCENFUNLGP:verCamNPR( "BA1_CPFUSR", TRansform(BA1->BA1_CPFUSR, X3Picture("BA1_CPFUSR")) )
	@ nLi, COL2 pSay "Plano    :" + objCENFUNLGP:verCamNPR( "BI3_DESCRI", cDesPla )
	nLi++

	@ nLi, COL1 pSay "Tipo de Reembolso  : "+objCENFUNLGP:verCamNPR( "BOW_XTIPRE", cTipReemb )
	@ nLi, COL2 pSay "Banco    :" +objCENFUNLGP:verCamNPR( "BOW_NROBCO", BOW->BOW_NROBCO )
	nLi++

	@ nLi, COL1 pSay "Data do Pedido     : "+ objCENFUNLGP:verCamNPR( "BOW_DTDIGI", dToc(BOW->BOW_DTDIGI) )
	@ nLi, COL2 pSay "Agencia  :" + objCENFUNLGP:verCamNPR( "BOW_NROAGE", BOW->BOW_NROAGE )
	nLi ++
	
	If TamSx3("B1N_VLRAPR")[2] ==  3
		@ nLi, COL1 pSay "Valor Apresentado  : " + objCENFUNLGP:verCamNPR( "BOW_VLRAPR", TransForm(BOW->BOW_VLRAPR,"@E 999,999.999") )
	Else
		@ nLi, COL1 pSay "Valor Apresentado  : " + objCENFUNLGP:verCamNPR( "BOW_VLRAPR", TransForm(BOW->BOW_VLRAPR,"@E 999,999.99") )
	Endif	
	@ nLi, COL2 PsAY "Conta    :" + objCENFUNLGP:verCamNPR( "BOW_NROCTA", BOW->BOW_NROCTA )
	nLi++

	@ nLi, COL1 pSay "Tipo de Protocolo  : Reembolso Normal"
	@ nLi, COL2 pSay "Nota Fiscal:" + objCENFUNLGP:verCamNPR( "BOW_NF", IIF(B45->(FieldPos("B45_NF")) > 0,BOW->BOW_NF,"") )
	nLi ++

	@ nLi, COL1 pSay Replicate("-", 80)
	nLi++

	@ nLi, COL1 pSay "Solicitado por     : " + Transform(	objCENFUNLGP:verCamNPR( "BA1_CODINT", BA1->BA1_CODINT )+;
															objCENFUNLGP:verCamNPR( "BA1_CODEMP", BA1->BA1_CODEMP )+;
															objCENFUNLGP:verCamNPR( "BA1_MATRIC", BA1->BA1_MATRIC )+;
															objCENFUNLGP:verCamNPR( "BA1_TIPREG", BA1->BA1_TIPREG )+;
															objCENFUNLGP:verCamNPR( "BA1_DIGITO", BA1->BA1_DIGITO ),;
															__cPictUsr)+;
	"  -  "+objCENFUNLGP:verCamNPR( "BA1_NOMUSR", Alltrim(BA1->BA1_NOMUSR) )
	nLi ++

	@ nLi, COL1 pSay Replicate("-", 80)
	nLi ++

	@ nLi, COL1 pSay "OBS: " //+ IIF (At(CRLF,cO=bsAux) > 75, SubStr(cObsAux,1,75), "")

	nLinhas := MLCount(BOW->BOW_OBS,70)
	For ni:= 1 To nLinhas
        cTxtLinha := MemoLine(BOW->BOW_OBS,70,ni)
        If ! Empty(cTxtLinha)
        	@ nLI, COL1 pSay "     " +objCENFUNLGP:verCamNPR( "BOW_OBS", cTxtLinha )
		nLi ++
			EndIf
	Next ni

	// Controle de salto de página.
	If nLi > nQtdLin
		nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
	Endif

	@ nLi, COL1 pSay "Emitido por: " + cCdOper + " - " + cNomOpe
	nLi +=3

	@ nLi, COL1 pSay "         Assinatura:    --------------------------------------------"
	nLi++

	@ nLi, COL1 pSay "                                      Data:"+ dToc(Date())
	nLi ++

	@ nLi, COL1 pSay "                        AFIRMO TER RECEBIDO UMA VIA DE IGUAL TEOR "
	nLi += 2

	@ nLi, COL1 pSay Replicate("=",80)
	nLi ++
Next

//	R998Linha(cLinha,0,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Printer To
OurSpool(crel)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³PLSRPROT  ³Autor  ³ Totvs				          ³ Data ³ 29.11.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio capa de lote PEG										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRPROT(cChave,cPathDest,lWeb,nRecno,lView)

STATIC oRel := nil

LOCAL nPixLin := 40
LOCAL nIniBox := 90
LOCAL nPixCol := 40
LOCAL nPixFin := 550
LOCAL nValTot := 0
LOCAL cRelName := "ProtocReemb"+CriaTrab(NIL,.F.)
LOCAL nquantlin := 780
LOCAL cRelArq:=""
LOCAL cRelArq1:=""
LOCAL nLinTotal:=0
LOCAL nCont1 := 0
LOCAL lEntrou := .F.
LOCAL nPosI :=  0
LOCAL nPosII :=  0
LOCAL nPosIII :=  0
LOCAL nPosIIII :=  0
LOCAL nPosSequen :=  0
LOCAl nVlrDsp		:= 0
LOCAL cRdaNRef := ""
LOCAL aRdaNaoR := {}
LOCAL nCnt := 0
LOCAL nSomaTot := 0
LOCAL cCodInt := PLSINTPAD()
LOCAL cSequen := ""
LOCAL nI :=0
LOCAL nAL := 0.25
LOCAL nAC := 0.24
LOCAL nLinIni := 0
LOCAL cDescPla := ""
LOCAL cMsgEntga := GETNEWPAR("MV_MSGREMB","")
LOCAL cMatric   := "" 
LOCAL cEndTit	:= ''



DEFAULT cChave := ""
DEFAULT cPathDest := lower(GETMV("MV_RELT"))
DEFAULT nRecno := 0
DEFAULT lWeb := .F.
DEFAULT lView    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Posiciona no PROTOCOLO
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BOW->( dbSetOrder(1) )
lFound := BOW->( MsSeek(xFilial("BOW") + cChave ))

If lWeb
	oRel := FWMSPrinter():New(cRelName, 6, .F., nil, .T., nil, @oRel, nil, nil, .F., ,.F.)
Else
	oRel := FWMsPrinter():New(cRelName, 6, .F., cPathDest, .T./*disable setup*/,,,, .F./*server*/,/*lPDFAsPNG*/,, lView/*no Preview*/)
EndIf

oRel:cPathPDF := cPathDest

If lFound
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ POSICIONA NA REDE NAO REFERENCIADA
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	BK6->( dbSetOrder(3) ) //BK6_FILIAL, BK6_CODIGO
	BK6->( msSeek(xFilial("BK6")+BOW->BOW_CODREF) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ POSICIONA NO BENEFICIARIO
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	BA1->(DbSetOrder(2))
	BA1->(MsSeek(xFilial("BA1")+SubStr(BOW->BOW_USUARI,1,16)))
	BA3->(DbSetOrder(1))
	BA3->(MsSeek(xFilial("BA3")+SubStr(BOW->BOW_USUARI,1,14)))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Instancia os objetos de fonte antes da pintura do relatorio
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oFont8   := TFont():New( "Arial",, 08,,.F.)
	oFont9   := TFont():New( "Arial",, 09,,.F.)
	oFont10  := TFont():New( "Arial",, 10,,.F.)
	oFont10N := TFont():New( "Arial",, 10,,.T.)
	oFont12  := TFont():New( "Arial",, 12,,.F.)
	oFont12N := TFont():New( "Arial",, 12,,.T.)
	oFont14  := TFont():New( "Arial",, 14,,.F.)
	oFont14N := TFont():New( "Arial",, 14,,.T.)
	oFont16  := TFont():New( "Arial",, 16,,.F.)
	oFont16N := TFont():New( "Arial",, 16,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Obj
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	oRel:setResolution(72)
	//se esta habilitado para mostrar, e foi chamado a partir da 'CONSULTA DE PROTOCOLO' gerado pelo Portal (nRecno > 0)

	oRel:setPortrait()
	//Endif
	oRel:setPaperSize(DMPAPER_A4)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ nEsquerda, nSuperior, nDireita, nInferior
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oRel:setMargin(05,05,05,05)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ setup da impressora
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !lWeb .And. lView 
		oRel:Setup()
		lMarc := .F.

		If oRel:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return{"",""}
		EndIf
	EndIf
	nColIni := 065
	If     oRel:nPaperSize == 9 // Papél A4
		nLinMax := 1754
		nColMax := 2335
		nLayout := 2
	Elseif oRel:nPaperSize == 1 // Papel Carta
		nLinMax := 1545
		nColMax := 2400
		nLayout := 3
	Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		nLinMax := 1764
		nColMax := 2400
		nLayout := 1
	Endif

	// Descrição do plano
	cDescPla	:= ALLTRIM(Posicione("BI3",1,xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO),"BI3_NREDUZ"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Inicializa uma pagina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oRel:StartPage()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ insere logo no relatorio
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//INI
	aBMP  := {"lgesq.bmp"}
	aBMP2 := {"lgdir.bmp"}
	If File("lgesq" + FWGrpCompany() + FWCodFil() + ".bmp")
		aBMP := { "lgesq" + FWGrpCompany() + FWCodFil() + ".bmp" }
	ElseIf File("lgesq" + FWGrpCompany() + ".bmp")
		aBMP := { "lgesq" + FWGrpCompany() + ".bmp" }
	EndIf
	If File("lgdir" + FWGrpCompany() + FWCodFil() + ".bmp")
		aBMP2 := { "lgdir" + FWGrpCompany() + FWCodFil() + ".bmp" }
	ElseIf File("lgdir" + FWGrpCompany() + ".bmp")
		aBMP2 := { "lgdir" + FWGrpCompany() + ".bmp" }
	EndIf
	If !Empty(aBMP[1])
		oRel:SayBitmap(10,10, aBMP[1],50,50) 		//-- Tem que estar abaixo do RootPath -- esta no SYSTEM
	Endif
	If !Empty(aBMP2[1])
		oRel:SayBitmap(10,530, aBMP2[1],50,50) 		//-- Tem que estar abaixo do RootPath
	Endif
	//FIM

	nPixLin += 25

	//======== VARIAVEIS DAS COLUNAS =======================
	nColTot := 500 * IIf(oRel:nPaperSize == 9, 0.97, 1) //	Se for A4 irá diminuir esse valor
	nCol1 := nPixCol - 20
	nCol2 := (nCol1 + (nColTot * 0.075))
	nCol3 := (nCol2 + (nColTot * 0.113))
	nCol4 := (nCol3 + (nColTot * 0.093))
	nCol5 := (nCol4 + (nColTot * 0.050)) 
	nCol6 := (nCol5 + (nColTot * 0.09)) 
	nCol7 := (nCol6 + (nColTot * 0.09))
	nCol8 := (nCol7 + (nColTot * 0.26))
	nCol9 := (nCol8 + (nColTot * 0.27))
	//======================================================

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Imprime cabeçalho
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oRel:say(nPixLin,nColTot*0.25,ALLTRIM(SM0->M0_NOMECOM),oFont16n)
	nPixLin += 30
	oRel:say(nPixLin,nPixCol,STR0010 + alltrim(SM0->M0_ENDCOB) + " - " + alltrim(SM0->M0_BAIRCOB) +", " +; //"Endereço: "
	alltrim(SM0->M0_CIDCOB) + " - " + alltrim(SM0->M0_ESTCOB) + " - CEP: " + alltrim(SM0->M0_CEPCOB),oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,STR0011 + alltrim(SM0->M0_TEL) + " / Fax: " + alltrim(SM0->M0_FAX),oFont12) //"Fone: "
	nPixLin += 20

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Imprime o Box principal
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oRel:Box(nPixLin,(nColIni + 0000)*nAC,820,(nColIni + nColMax)*nAC)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,STR0012,oFont16n) //"SOLICITAÇÃO DE REEMBOLSO"
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,"Número",oFont14n)
	oRel:say(nPixLin,nColTot*0.65,"Data", oFont14n)

	// Num. Protoc e data
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,alltrim(BOW->BOW_PROTOC),oFont12)
	oRel:say(nPixLin,nColTot*0.65,DTOC(BOW->BOW_DTDIGI),oFont12)//"Data:"
	nPixLin += 30
	oRel:say(nPixLin,nPixCol,STR0013,oFont14n) //"Solicitante - Matrícula"
	nPixLin += 15
	//nome e matricula do beneficiário.
	
	
	If FindFunction("PLSMATBEN") 
		//Retorna a matrícula antiga caso não tenha gerado carteirinha
		cMatric := PLSMATBEN (BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),)
	Else
		cMatric := Transform(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),__cPictUsr)
	EndIf 
	
	oRel:say(nPixLin,nPixCol,Alltrim(BA1->BA1_NOMUSR) + " - " + cMatric,oFont12) 
	
	nPixLin += 30
	
	oRel:say(nPixLin,nPixCol,STR0014,oFont14n) //"Unid. Organ."
	oRel:say(nPixLin,nColTot*0.65,STR0015,oFont14n) //"Telefone"
	nPixLin += 15
	//unidade organizacional(setor de trabalho)
	dbSetOrder(1)
	BBZ->(dbSeek(xFilial("BBZ") + BA3->BA3_UNDORG))
	oRel:say(nPixLin,nPixCol, IIF( !EMPTY(BBZ->BBZ_SIGLA), alltrim(BBZ->BBZ_SIGLA), STR0016),oFont12) //"Sem Cadastro"
	//telefone
	oRel:say(nPixLin,nColTot*0.65,"(" + SUBSTR(BOW->BOW_TELCON,1,2) + ") " + IIf(LEN(ALLTRIM(BOW->BOW_TELCON)) > 10,;
		Transform(SUBSTR(BOW->BOW_TELCON,3),"@R 9-9999-9999"), Transform(SUBSTR(BOW->BOW_TELCON,3),"@R 9999-9999")),oFont12)
	nPixLin += 30
	
	//Endereço - Plano
	oRel:say(nPixLin,nPixCol,STR0017,oFont14n) //"Endereço"
	oRel:say(nPixLin,nColTot*0.80,STR0018,oFont14n) //"Plano" 
	
	If BA3->BA3_ENDCOB <> '1' 
		//rua, numero e bairro
		nPixLin += 15

		//Vamos veriricar quantos caracteres o endereco e o bairro possuem
		cEndTit := ALLTRIM(BA3->BA3_END) + ", " + ALLTRIM(BA3->BA3_NUMERO) + " - " + ALLTRIM(BA3->BA3_BAIRRO)
		If len(cEndTit) > 56
			If len(ALLTRIM(BA3->BA3_END)) > 54
				oRel:say(nPixLin,nPixCol,ALLTRIM(SubStr(BA3->BA3_END,1,54)) + ", " + ALLTRIM(BA3->BA3_NUMERO),oFont12)
			Else
				oRel:say(nPixLin,nPixCol,ALLTRIM(BA3->BA3_END) + ", " + ALLTRIM(BA3->BA3_NUMERO),oFont12)
			EndIf
			oRel:say(nPixLin+15,nPixCol,ALLTRIM(BA3->BA3_BAIRRO),oFont12)
			//plano do beneficiario
			oRel:say(nPixLin,nColTot*0.80, cDescPla,oFont12)
			nPixLin += 15
		Else
			oRel:say(nPixLin,nPixCol,ALLTRIM(BA3->BA3_END) + ", " + ALLTRIM(BA3->BA3_NUMERO) + " - " + ALLTRIM(BA3->BA3_BAIRRO),oFont12)
			//plano do beneficiario
			oRel:say(nPixLin,nColTot*0.80, cDescPla,oFont12)
		EndIf
	
		//cidade, estado e CEP
		nPixLin += 15
		oRel:say(nPixLin,nPixCol,ALLTRIM(BA3->BA3_MUN) + " - " + ALLTRIM(BA3->BA3_ESTADO) + "  CEP: " + Transform(ALLTRIM(BA3->BA3_CEP),"@R 99999-999"),oFont12)
	Else

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+BA3->BA3_CODCLI))
			//rua, numero e bairro
			nPixLin += 15
			oRel:say(nPixLin,nPixCol,ALLTRIM(SA1->A1_END) + " - " + ALLTRIM(SA1->A1_BAIRRO),oFont12)
	
			//plano do beneficiario
			oRel:say(nPixLin,nColTot*0.80, cDescPla,oFont12)
	
			//cidade, estado e CEP
			nPixLin += 15
			oRel:say(nPixLin,nPixCol,ALLTRIM(SA1->A1_MUN) + " - " + ALLTRIM(SA1->A1_EST) + "  CEP: " + Transform(ALLTRIM(SA1->A1_CEP),"@R 99999-999"),oFont12)
		Else
			//rua, numero e bairro
			nPixLin += 15

			//Vamos veriricar quantos caracteres o endereco e o bairro possuem
			cEndTit := ALLTRIM(BA3->BA3_END) + ", " + ALLTRIM(BA3->BA3_NUMERO) + " - " + ALLTRIM(BA3->BA3_BAIRRO)
			If len(cEndTit) > 56
				If len(ALLTRIM(BA3->BA3_END)) > 54
					oRel:say(nPixLin,nPixCol,ALLTRIM(SubStr(BA3->BA3_END,1,54)) + ", " + ALLTRIM(BA3->BA3_NUMERO),oFont12)
				Else
					oRel:say(nPixLin,nPixCol,ALLTRIM(BA3->BA3_END) + ", " + ALLTRIM(BA3->BA3_NUMERO),oFont12)
				EndIf
				oRel:say(nPixLin+15,nPixCol,ALLTRIM(BA3->BA3_BAIRRO),oFont12)
				//plano do beneficiario
				oRel:say(nPixLin,nColTot*0.80, cDescPla,oFont12)
				nPixLin += 15
			Else
				oRel:say(nPixLin,nPixCol,ALLTRIM(BA3->BA3_END) + ", " + ALLTRIM(BA3->BA3_NUMERO) + " - " + ALLTRIM(BA3->BA3_BAIRRO),oFont12)
				//plano do beneficiario
				oRel:say(nPixLin,nColTot*0.80, cDescPla,oFont12)
			EndIf
	
			//cidade, estado e CEP
			nPixLin += 15
			oRel:say(nPixLin,nPixCol,ALLTRIM(BA3->BA3_MUN) + " - " + ALLTRIM(BA3->BA3_ESTADO) + "  CEP: " + Transform(ALLTRIM(BA3->BA3_CEP),"@R 99999-999"),oFont12)
		Endif	
	Endif

	//linha divisoria
	nPixLin += 15
	oRel:Line( nPixLin, nPixCol-24, nPixLin, nPixCol+535)

	nPixLin += 20
	oRel:say(nPixLin,nPixCol,STR0019,oFont12n) //"Comprovantes Encaminhados:"
	nPixLin += 30

	//retorna todos os prestadores de serviço do protocolo
	B1N->(DbSetOrder(1))
	B1N->(MsSeek(xFilial("B1N") + BOW->BOW_PROTOC))
	While !B1N->(Eof()) .AND. xFilial("B1N")+B1N->B1N_PROTOC == xFilial("BOW")+BOW->BOW_PROTOC
		If !B1N->B1N_CODREF $ cRdaNRef
			cRdaNRef += B1N->B1N_CODREF + ", "
			AADD(aRdaNaoR, {B1N->B1N_NOMREF, B1N->B1N_CODREF})
		EndIf
		B1N->(dbSkip())
	EndDo
	nRDAs := LEN(aRdaNaoR)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Imprime os itens de acordo com a RDA
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	For nCnt := 1 to nRDAs
		oRel:say(nPixLin,nPixCol,STR0035,oFont14N) //"CPF/CNPJ"
		If LEN(ALLTRIM(aRdaNaoR[nCnt,2])) == 11
			oRel:say(nPixLin,nPixCol + 068,PADR(Alltrim(TransForm(aRdaNaoR[nCnt,2],"@R 999.999.999-99")),30),oFont14N)
		ElseIf LEN(ALLTRIM(aRdaNaoR[nCnt,2])) > 11
			oRel:say(nPixLin,nPixCol + 068,PADR(Alltrim(TransForm(aRdaNaoR[nCnt,2],"@R 99.999.999/9999-99")),30),oFont14N)
		EndIf
		nPixLin += 15
		oRel:say(nPixLin,nPixCol,STR0020,oFont14N) //"Prestador de Serviço:"
		oRel:say(nPixLin,nPixCol + 120,PADR(Alltrim(aRdaNaoR[nCnt,1]),30),oFont14N)
		nPixLin += 30

		//Cria nova pagina
		If nPixLin >= nquantlin
			GeraPg(nPixCol, cMsgEntga)
			nPixLin := 95
			nPixCol := 40
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Titulos da coluna
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oRel:say(nPixLin,nCol1,STR0021,oFont12n) //"Data:"
		oRel:say(nPixLin,nCol2,STR0022,oFont12n) //"Comp.:"
		oRel:say(nPixLin,nCol3,STR0023,oFont12n) //"Número:"
		oRel:say(nPixLin,nCol4,STR0024,oFont12n) //"Qtd.:"
		oRel:say(nPixLin,nCol5,STR0036,oFont12n) //"V. Unit." 
		oRel:say(nPixLin,nCol6,STR0037,oFont12n) //"V. Total" 
		oRel:say(nPixLin,nCol7,STR0026,oFont12n) //"Beneficiário:"
		oRel:say(nPixLin,nCol8,STR0027,oFont12n) //"Despesa - Cod. Proc.:"
		oRel:say(nPixLin,nCol9,STR0033,oFont12n) //"Uso Continuo"
		nPixLin += 15

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Cria uma nova pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If nPixLin >= nquantlin
			GeraPg(nPixCol, cMsgEntga)
			nPixLin := 95
			nPixCol := 40
		EndIf

		B1N->(DbSetOrder(3))
		B1N->(MsSeek(xFilial("B1N") + BOW->BOW_PROTOC + aRdaNaoR[nCnt,2]))
		While !B1N->(Eof()) .AND. xFilial("B1N")+B1N->B1N_PROTOC == xFilial("BOW")+BOW->BOW_PROTOC .AND. B1N->B1N_CODREF == aRdaNaoR[nCnt, 2]
			oRel:say(nPixLin,nCol1,DTOC(B1N->B1N_DATDOC),oFont9) //"Data:"
			oRel:say(nPixLin,nCol2,SUBSTR(Alltrim(B1N->B1N_TIPDOC),1,12),oFont8) //"Comp.:"
			oRel:say(nPixLin,nCol3,SUBSTR(Alltrim(B1N->B1N_NUMDOC),1,10),oFont9) //"Número:"
			oRel:say(nPixLin,nCol4 +(nColTot * 0.01),SUBSTR(ALLTRIM(Str(B1N->B1N_QTDPRO)),1,5),oFont9) //"Qtd.:"
			
			If TamSx3("B1N_VLRAPR")[2] ==  3
				oRel:say(nPixLin,nCol5,"R$ " + Alltrim(TransForm(B1N->B1N_VLRAPR,"@E 99,999,999,999.999")),oFont9) //"V. Unit."
			Else
				oRel:say(nPixLin,nCol5,"R$ " + Alltrim(TransForm(B1N->B1N_VLRAPR,"@E 99,999,999,999.99")),oFont9) //"V. Unit."
			Endif	 
			
			oRel:say(nPixLin,nCol6,"R$ " + Alltrim(TransForm(B1N->B1N_VLRTOT,"@E 99,999,999,999.99")),oFont9) //"V. Total"  
			oRel:say(nPixLin,nCol7,SUBSTR(PADR(Alltrim(Posicione("BA1",2,xFilial("BA1")+B1N->B1N_MATRIC,"BA1_NOMUSR")),25),1,26),oFont9) //"Beneficiário:"
			oRel:say(nPixLin,nCol8,PADR(SUBSTR(Alltrim(Posicione("BR8",1,xFilial("BR8")+B1N->B1N_CODPAD+B1N->B1N_CODPRO ,"BR8_DESCRI")),1,22) +" - "+ B1N->B1N_CODPRO,33),oFont9) //"Despesa - Cod. Proc.:"
			oRel:say(nPixLin,(nCol9 + 12),IIF(B1N->B1N_USOCON == "0", "Não", "Sim"),oFont9) //"Uso Continuo:" 
			nValTot += B1N->B1N_VLRTOT //Valor total 
			B1N->(DbSkip())
			nPixLin += 15

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Cria uma nova pagina
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If nPixLin >= nquantlin
				GeraPg(nPixCol, cMsgEntga)
				nPixLin := 95
				nPixCol := 40
			EndIf
		EndDo
		nPixLin += 15

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Cria uma nova pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If nPixLin >= nquantlin
			GeraPg(nPixCol, cMsgEntga)
			nPixLin := 95
			nPixCol := 40
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Imprime total por fornecedor
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oRel:say(nPixLin,nCol3,STR0028 + Alltrim(TransForm(nValTot,"@E 99,999,999,999.99")),oFont12) //"Total Prestador de Serviço: R$ "
		nSomaTot += nValTot
		nValTot := 0
		nPixLin += 50
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Cria uma nova pagina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nPixLin >= nquantlin
		GeraPg(nPixCol, cMsgEntga)
		nPixLin := 95
		nPixCol := 40
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Soma o total de todos os fornecedores
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oRel:say(nPixLin,nCol3,STR0029 + Alltrim(TransForm(nSomaTot,"@E 99,999,999,999.99")),oFont14n) //"Despesa Total: R$ "
	nPixLin += 45

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Cria uma nova pagina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nPixLin >= nquantlin
		GeraPg(nPixCol, cMsgEntga)
		nPixLin := 95
		nPixCol := 40
	EndIf
	oRel:say(nPixLin,nCol2 - 20,STR0032,oFont10n) //"Ass. Beneficiário:   ------------------------------------------"
	nPixLin += 30
	
	// Imprimir o campo Obervação caso indeferido e cancelamento
	If BOW->BOW_STATUS $ '4,D'
	   	cRelArq := AllTrim(BOW->BOW_OBS)
	 	nLinTotal := MlCount(cRelArq,147)
		oRel:Say(nPixLin, nCol2 - 20, "Observação: ", oFont10n) //"Observação 
		nPixLin += 15  
			For nCont1 := 1 To nLinTotal
				cRelArq1:= MemoLine(cRelArq,147, nCont1)
				oRel:Say(nPixLin, nCol2 - 20," "+ AllTrim(cRelArq1),oFont10)
				nPixLin += 10
				If nPixLin >= nquantlin
					GeraPg(nPixCol, cMsgEntga)
					nPixLin := 95
					nPixCol := 40	
					oRel:Say(nPixLin, nCol2 - 20, "Observação: ", oFont10n) //"Observação 
					nPixLin += 15  		
				Endif		
			Next nCont1
		nPixLin += 30
	EndIf
	oRel:say(nPixLin,nCol2 - 20,STR0030,oFont10n) //"Processado por:   ------------------------------------------"
	oRel:say(nPixLin,nCol5 + 70,STR0031,oFont10n) //"Conferido por:    ------------------------------------------"
	oRel:Line(790, nPixCol-24, 790, nPixCol+535)
	oRel:say(810,40,cMsgEntga,TFont():New("Arial",, 11,, .F.))
	oRel:EndPage()	// Finaliza a pagina

else
	if !lWeb
		msgAlert("Protocolo não encontrado!")
		Return()
	else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Protocolo nao encontrado:' + cChave , 0, 0, {})
		Return {cRelName+".pdf",""}
	Endif
Endif
IF lView
	oRel:Preview()
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return{cRelName+".pdf",""}


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GeraPg  ³Autor  ³ Thiago Guilherme		          ³ Data ³08.08.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera nova pagina															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GeraPg(nPixCol,cMsgEntga)

		oRel:Line(790, nPixCol-24, 790, nPixCol+535)
		oRel:say(810,40,cMsgEntga,TFont():New( "Arial",, 11,,.F.))

		oRel:StartPage()

		//insere logo na nova pagina
		aBMP	:= {"lgesq.bmp"}
		aBMP2  := {"lgdir.bmp"}

		If File("lgesq" + FWGrpCompany() + FWCodFil() + ".bmp")
			aBMP := { "lgesq" + FWGrpCompany() + FWCodFil() + ".bmp" }
		ElseIf File("lgesq" + FWGrpCompany() + ".bmp")
			aBMP := { "lgesq" + FWGrpCompany() + ".bmp" }
		EndIf

		If File("lgdir" + FWGrpCompany() + FWCodFil() + ".bmp")
			aBMP2 := { "lgdir" + FWGrpCompany() + FWCodFil() + ".bmp" }
		ElseIf File("lgdir" + FWGrpCompany() + ".bmp")
			aBMP2 := { "lgdir" + FWGrpCompany() + ".bmp" }
		EndIf

		If !Empty(aBMP[1])
			oRel:SayBitmap(10,10, aBMP[1],130,50) 		//-- Tem que estar abaixo do RootPath -- esta no SYSTEM
		Endif

		If !Empty(aBMP2[1])
			oRel:SayBitmap(10,450, aBMP2[1],130,50) 		//-- Tem que estar abaixo do RootPath
		Endif

		oRel:Box(80, 15.6, 820,576)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³TIPRELAT  ³Autor  ³ Thiago Guilherme		       ³ Data ³08.08.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tipo do relatório a ser gerado									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TIPRELAT()

LOCAL cProtoc := BOW->BOW_PROTOC

If PLSALIASEX("B1N")
	If Pergunte("PLSREPROT", .T.)

		If MV_PAR01 == 1 .or.  MV_PAR01 == 2
			MsgRun("Impressão em andamento, aguarde...","Protocolo de reembolso",{|| PLSRPROT(cProtoc)})
		EndIf
	EndIf
Else
	PLSR998(cProtoc)
EndIf

Return