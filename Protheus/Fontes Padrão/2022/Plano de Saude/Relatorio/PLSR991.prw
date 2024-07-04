#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "PLSMGER.CH"
#include "PLSR991.CH"

#define COL02 000 //NºReembolso
#define COL04 024 //Data Liquição
#define COL05 035 //Data Solicitação
#define COL06 048 //Matricula
#define COL07 070 //Nome
#define COL08 102 //Valor Solic
#define COL09 114 //Valor Pago
#define COL10 126 //Status
#define COL11 150 //Titulo
#define COL12 172 //Operador
#define COL13 188 //Data

Static objCENFUNLGP := CENFUNLGP():New()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR991 ³ Autor ³ Angelo Sperandio       ³ Data ³ 03.02.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Extrato de Movimentacao da RDA                             ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR991()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR991(cProtoc,lAuto)
Local lCentury      := __setcentury()
LOCAL aSx1Stru      := SX1->( DbStruct() )
LOCAL nTamPerg      := aSx1Stru[1,3]
PRIVATE nQtdLin	    := 68
PRIVATE cNomeProg   := "PLSR991"
PRIVATE nCaracter   := 15
PRIVATE nLimite     := 220
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := FunDesc() //"Protocolo de Reembolso"
PRIVATE cDesc1      := STR0002 //"Emite o protocolo de reembolso"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BOW"
PRIVATE cPerg       := "PLR991"
PRIVATE cRel        := "PLSR991"
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {"Protocolo"}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.

//PRIVATE cCabec1     := "Gerência  NºReembolso   Tipo          Data Liq.  Data Solicitação  Matricula             Nome                            Valor Solic     Valor Pago  Status        "
PRIVATE cCabec1 := "NºReembolso             Data Liq.  Data Solic.  Matricula             Nome                            Valor Sol.  Valor Pago  Status                  Titulo                Operadora       Data"
PRIVATE cCabec2     := "" // "Titulo                  Operador      Responsável                      Data atesto           Hora Atesto"
PRIVATE nColuna     := 00
PRIVATE nLi         := 0
PRIVATE nLinPag     := 68
PRIVATE pMoeda1     := "@E 999,999.99"
PRIVATE pMoeda2     := "@E 999,999,999.99"
PRIVATE nTamDes     := 35
PRIVATE lImpZero
PRIVATE aRet 			:= {.T.,""}
PRIVATE aLog  		:= {}
PRIVATE b991Err 		:= .T.
//Variaveis p retorno do pergunte
PRIVATE dDataDe		:= 0
PRIVATE dDataAte		:= 0
PRIVATE cStatus		:= 0

If !(PLSALIASEXI("BOW") .AND. PLSALIASEXI("BOX"))
	MsgAlert(STR0003)//"As tabelas BOW e BOX não existem. Execute o UPDPLSB0!"
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaSX1()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acessa parametros do relatorio...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,{},lCompres,cTamanho,{},lFiltro,lCrystal)

	aAlias := {"BOW","BA1","BOX","B44"}
	objCENFUNLGP:setAlias(aAlias)

dDataDe	:= MV_PAR01
dDataAte	:= MV_PAR02
cStatus	:= MV_PAR03

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
If !lAuto
	SetDefault(aReturn,cAlias)
Endif	

nTipQbc := aReturn[8]

MsAguarde({|| R991Imp() }, cTitulo, "", .T.)
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
±±³Programa   ³ R991Imp  ³ Autor ³ Angelo Sperandio      ³ Data ³ 03.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime o extrato mensal dos servicos prestados            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function R991Imp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL cNomeCli	:= ""
LOCAL dData		:= ""
LOCAL nVlrPag	:= 0
LOCAL nTotSol	:= 0
LOCAL nTotPag 	:= 0
LOCAL cCabec3		:= ""
LOCAL nBoxRec		:= 0
LOCAL cStDesc		:= PadR(Posicione("SX5",1,xFilial("SX5")+"DW"+cStatus,"X5_DESCRI"),15)
Local cMvCOMP      := GetMv("MV_COMP")
Local cMvNORM      := GetMv("MV_NORM")

If EMPTY(dDataDe)
	 msgAlert('O campo "data de" deve ser preenchido.')
	 return 

ElseIf EMPTY(dDataAte)
	msgAlert('O campo "data ate" deve ser preenchido.')
	return 
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mensagem de processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsProcTxt(STR0004 + Left(xFilial("BOW")+STR0005+cStatus + ' - ' + cStDesc,30)) //"Verificando... " //" Protoc. Status "
ProcessMessages()

//Realiza a busca
DbSelectArea("BOW")
BOW->(DbSetOrder(4))
If !BOW->(DbSeek(xFilial("BOW")+cStatus) )
	MsgAlert(STR0014)//"Nenhum registro encontrado."
	Return()
Endif

nLi := 500 // Para forçar a a impressão do cabeçalho na primeira pagina.

While !BOW->(Eof()) .AND. BOW->BOW_FILIAL == xFilial("BOW") .AND. BOW->BOW_STATUS == AllTrim(cStatus) 
	//Recupera a data da última operação
	DbSelectArea("BOX")
	BOX->(DbSetOrder(1))
	If BOX->(DbSeek(xFilial("BOX")+BOW->(BOW_OPEUSR+BOW_PROTOC),.T.))
		While !BOX->(Eof()) .AND. BOX->(BOX_FILIAL+BOX_CODOPE+BOX_PROTOC) == xFilial("BOW")+BOW->(BOW_OPEUSR+BOW_PROTOC) ;
								.AND. IIF(!Empty(dDataDe) ,BOX->BOX_DATA >= dDataDe ,.T.) ;
								.AND. IIF(!Empty(dDataAte),BOX->BOX_DATA <= dDataAte,.T.)
			dData := BOX->BOX_DATA
			nBoxRec := BOX->(Recno())
			BOX->(DbSkip())
		EndDo
	EndIf
	// Posiciona as demais tabelas.
	//Reposiciona a tabela BOX
	If nBoxRec > 0
		BOX->(DbGoTo(nBoxRec))
	EndIf
	//Posiciona no usuário
	/*/
	BA1->(dbSetorder(02))
	If !BA1->(dbSeek(xFilial("BA1")+BOW->BOW_USUARI))
		MsgAlert(STR0006)//"O usuário não foi localizado"
		Return()
	Endif
/*/
	//Retorna o valor pago
	B44->(dbSetorder(04))
	If B44->(dbSeek(xFilial("BOW")+BOW->BOW_PROTOC))
		nVlrPag := B44->B44_VLRPAG
	Endif

	//Recupera nome cliente
	SA1->(dbSetorder(01))
	If SA1->(dbSeek(xFilial("SA1")+BOW->BOW_CODCLI+BOW->BOW_LOJA))
		cNomeCli := Alltrim(SA1->A1_NOME)

	Else
		cNomeCli := STR0007//"Não informado"

	Endif

	//Controle de mudança de página
	If nLi > nQtdLin
		nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
		nLi++
	Endif

/*
         10        20        30        40        50        60        70        80        90        100       110       120       130      140        150       160       170       180       190       200
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
NºReembolso   Data Liq.  Data Solic.  Matricula             Nome                            Valor Sol.  Valor Pago  Status                 Titulo           Operadora       Data"
              01/01/2001              0001.0001.000000.00-1                                 99,999.99   99,999.99   Lib. Financeiro        PLS 000000 TP    Administrador
*/

If BOW->BOW_DTDIGI >= dDataDe .AND. BOW->BOW_DTDIGI <= dDataAte 

	@ nLi , COL02 pSay objCENFUNLGP:verCamNPR("BOW_PROTOC",Alltrim(BOW->BOW_PROTOC))
	@ nLi , COL04 pSay objCENFUNLGP:verCamNPR("BOX_DTBAIX",dToc(BOX->BOX_DTBAIX))
	@ nLi , COL05 pSay objCENFUNLGP:verCamNPR("BOW_DTDIGI",dToc(BOW->BOW_DTDIGI))
	@ nLi , COL06 pSay Transform(objCENFUNLGP:verCamNPR("BA1_CODINT",BA1->BA1_CODINT)+;
								objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1->BA1_CODEMP)+;
								objCENFUNLGP:verCamNPR("BA1_MATRIC",BA1->BA1_MATRIC)+;
								objCENFUNLGP:verCamNPR("BA1_TIPREG",BA1->BA1_TIPREG)+;
								objCENFUNLGP:verCamNPR("BA1_DIGITO",BA1->BA1_DIGITO),__cPictUsr)
	@ nLi , COL07 pSay objCENFUNLGP:verCamNPR("BOW_NOMCLI",Substr(BOW->BOW_NOMCLI, 1, 30))
	@ nLi , COL08 pSay objCENFUNLGP:verCamNPR("BOW_VLRAPR",Transform(BOW->BOW_VLRAPR,"@E 99,999.99"))
	@ nLi , COL09 pSay Transform(nVlrPag,"@E 99,999.99")
	@ nLi , COL10 pSay cStDesc
	@ nLi , COL11 pSay 	objCENFUNLGP:verCamNPR("BOW_PREFIX",BOW->BOW_PREFIX)+;
						objCENFUNLGP:verCamNPR("BOW_NUM",BOW->BOW_NUM)+;
						objCENFUNLGP:verCamNPR("BOW_PARCEL",BOW->BOW_PARCEL)+;
						objCENFUNLGP:verCamNPR("BOW_TIPO",BOW->BOW_TIPO)
	@ nLi , COL12 pSay objCENFUNLGP:verCamNPR("BOX_NOMUSR",Substr(BOX->BOX_NOMUSR,1,15))
	@ nLi , COL13 pSay objCENFUNLGP:verCamNPR("BOX_DATA",dToc(BOX->BOX_DATA))
	nLi++

	nTotSol += BOW->BOW_VLRAPR
	nTotPag += nVlrPag
EndIf	

	BOW->(DbSkip())
EndDo

nLi +=3
If nLi > nQtdLin
	nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
	nLi++
	@ nLi , COL01 pSay cCabec3
	nLi+= 2
Endif


@ nLi, 005 pSay  Space(20) + STR0008 + AllTrim(cStatus) + ' - ' + cStDesc //"Relatorio do status "
nLi++

@ nLi, 005 pSay  Space(20) + STR0009 + objCENFUNLGP:verCamNPR("BOW_VLRAPR",Transform(nTotSol,pMoeda2)) //"Valor total Solicitado: "
nLi++

@ nLi, 005 pSay  Space(20) + STR0010 + objCENFUNLGP:verCamNPR("B44_VLRPAG",Transform(nTotPag,pMoeda2)) //"Valor total Pago      : "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Printer To
OurSpool(crel)


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ CriaSX1   ³ Autor ³ Angelo Sperandio     ³ Data ³ 03.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Atualiza SX1                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function CriaSX1()

Local aRegs	:=	{}

/*DbSelectArea("SX1")
SX1->(DbSetOrder(1))

If SX1->(msSeek(cPerg))

	While !SX1->(Eof()) .AND. AllTrim(SX1->X1_GRUPO) == cPerg
		SX1->(Reclock("SX1",.F.))
			SX1->(DbDelete())
		SX1->(MsUnlock())
		SX1->(DbSkip())
	EndDo

EndIf*/

aadd(aRegs,{cPerg,"01",STR0011       ,"","","mv_ch1","D",08,0,0,"G","","mv_par01","" ,"","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data De"
aadd(aRegs,{cPerg,"02",STR0012       ,"","","mv_ch2","D",08,0,0,"G","","mv_par02","" ,"","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data Ate"
aadd(aRegs,{cPerg,"03",STR0013       ,"","","mv_ch3","G",01,0,0,"G","","mv_par03","" ,"","","","","","","","","","","","","","","","","","","","","","","","DW",""}) //"Status"

PlsVldPerg( aRegs )

Return