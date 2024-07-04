#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "PLSMGER.CH"
#include "PLSR992.CH"



#define COL01 000 //UF CRM
#define COL02 008 //CRM
#define COL03 020 //Nome do solicitante

#define COL04 000 //Matricula Beneficiario
#define COL05 023 //Nomes
#define COL06 054 //Data procedimento
#define COL07 067 //Des. Tab.
#define COL08 086 //Cod. Procedimento
#define COL09 103 //Descrição do Procedimento
#define COL10 126 //Quant

#define COL12 000 //Numero do protocolo
#define COL13 011 //Data Vencimento
#define COL14 020 //Nota Fiscal
#define COL15 040 //Vlr Apresentado
#define COL16 059 //Vlr Calculado
#define COL17 075 //Vlr glosado
#define COL18 094 //Vlr Total Reembolso

Static objCENFUNLGP := CENFUNLGP():New()
Static lautoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR992 ³ Autor ³ Angelo Sperandio       ³ Data ³ 03.02.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Extrato de Movimentacao da RDA                             ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR992()                                                  ³±±±
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
Function PLSR992(cProtoc)
Local lCentury      := __setcentury()
LOCAL aSx1Stru      := SX1->( DbStruct() )
LOCAL nTamPerg      := aSx1Stru[1,3]
PRIVATE nQtdLin	    := 68
PRIVATE cNomeProg   := "PLSR992"
PRIVATE nCaracter   := 15
PRIVATE nLimite     := 85
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := FunDesc()//"Reembolso por Solicitação"
PRIVATE cDesc1      := FunDesc()//"Reembolso por Solicitação"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BD6"
PRIVATE cPerg       := "PLR992"
PRIVATE cRel        := "PLSR992"
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {"Protocolo"}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "Reembolsos por Solicitante"
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 00
PRIVATE nLi         := 0
PRIVATE nLinPag     := 68
PRIVATE pMoeda1     := "@E 9,999.99"
PRIVATE pMoeda2     := "@E 999,999,999.99"
PRIVATE nTamDes     := 35
PRIVATE lImpZero
PRIVATE aRet 			:= {.T.,""}
PRIVATE aLog  		:= {}
PRIVATE b991Err 		:= .T.
//Variaveis p retorno do pergunte
PRIVATE dDataDe		:= 0
PRIVATE dDataAte		:= 0
PRIVATE cRdaDe		:= 0
PRIVATE cRdaAte		:= 0


If !lautoSt .AND. !(PLSALIASEXI("BOW") .AND. PLSALIASEXI("BOX"))
	MsgAlert(STR0003)//"As tabelas BOW e BOX não existem. Execute o UPDPLSB0!"
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄzzzzzzÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaSX1()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acessa parametros do relatorio...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lautoSt
	cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,{},lCompres,cTamanho,{},lFiltro,lCrystal)
endif

	aAlias := {"BB0","B44","B45","BR4","BR8","SE1","BD6"}
	objCENFUNLGP:setAlias(aAlias)

dDataDe	:= MV_PAR01
dDataAte	:= MV_PAR02
cRdaDe		:= MV_PAR03
cRdaAte	:= IIF(ISALPHA(MV_PAR04), "", MV_PAR04)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lautoSt .AND. nLastKey  == 27
	If  lCentury
		set century on
	Endif
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lautoSt
	SetDefault(aReturn,cAlias)
endif

if !lautoSt
	MsAguarde({|| R992Imp() }, cTitulo, "", .T.)
else
	R992Imp()
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera filtro do BD7                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lautoSt
	ms_flush()
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lautoSt .ANd. lCentury
	set century on
Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R992Imp  ³ Autor ³ Angelo Sperandio      ³ Data ³ 03.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime o extrato mensal dos servicos prestados            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function R992Imp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL nTotApr		:= 0
LOCAL nTotCal		:= 0
LOCAL nTotGlo		:= 0
LOCAL nTotReemb	:= 0

LOCAL nTotGApr	:= 0
LOCAL nTotGCal	:= 0
LOCAL nTotGGlo	:= 0
LOCAL nTotGReemb	:= 0

LOCAL nPag			:= 0
LOCAL cCabec3		:= ""
LOCAL cCabec4		:= ""
LOCAL cCabec5		:= ""

LOCAL cSql 		:=	""
Local cMvCOMP      := GetMv("MV_COMP")
Local cMvNORM      := GetMv("MV_NORM")

//Monta as colunas do Cabecalho
cCabec3 := "UF      CRM         Nome Solicitante"
cCabec4 := "Matricula              Nome                           Data Proc.   Des. Tab.          Cod. Proc.       Des. Proc.                Qtd.     "
cCabec5 := "Protocolo  Data Vencto Nota Fiscal          Vlr Apresentado    Vlr Calculado     Vlr glosado     Vlr Total Reemb"

// Imprime o cabecalho do relatorio.
nPag++
nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
nLi++
//Dados do solicitante
@ nLi , COL01 pSay cCabec3
nLi++
//Dados do usuário, procedimento, reembolso e financeiro
@ nLi , COL01 pSay cCabec4
nLi++
@ nLi , COL01 pSay cCabec5
nLi++


//Seleciona Tabelas
DbSelectArea("BOW")
BOW->(DbSetOrder(1))

DbSelectArea("BB0")
BB0->(DbSetOrder(7))

DbSelectArea("SE1")
SE1->(DbSetOrder(1))

DbSelectArea("BD6")
BD6->(DbSetOrder(6))

cSql := "SELECT B45_DATPRO, B45_CODPAD, B45_CODPRO, B45_QTDPRO, B45_NF,B45_CRM,"
cSql += "B45_OPEMOV, B45_CODLDP, B45_CODPEG, B45_NUMERO, B45_ORIMOV, B45_CODPAD, B45_CODPRO,"
cSql += "B44_PREFIX, B44_NUM, B44_PARCEL, B44_TIPO,"
cSql += "B44_OPEUSR, B44_CODEMP, B44_MATRIC, B44_TIPREG, B44_DIGITO,"
cSql += "B44_NOMCLI,	B44_PROTOC"

cSql += " FROM " + RetSQLName("B45") +  " INNER JOIN "
cSql +=  RetSQLName("B44") + " ON "
cSql +=" B45_FILIAL = B44_FILIAL "
cSql += " AND B45_OPEMOV = B44_OPEMOV "
cSql += " AND B45_ANOAUT = B44_ANOAUT "
cSql += " AND B45_MESAUT = B44_MESAUT "
cSql += " AND B45_NUMAUT = B44_NUMAUT "
cSql += " WHERE "
cSql += RetSqlName("B45")+".D_E_L_E_T_ = '' "
cSql += "AND "+RetSqlName("B44")+".D_E_L_E_T_ = '' "
cSql += "AND "+RetSqlName("B44")+".B44_PROTOC <> '' "
cSql += "AND "+RetSqlName("B45")+".B45_FILIAL = '" + xFilial("B45") + "' "
cSql += "AND "+RetSqlName("B45")+".B45_DATPRO >= '" + DTOS(dDataDe) + "' AND " + RetSqlName("B45")+".B45_DATPRO <= '" + DTOS(dDataAte) + "' "

If !EMPTY(cRdaDe) .AND. !EMPTY(cRdaAte)
	
	If cRdaDe <= cRdaAte
		cSql += " AND "+RetSqlName("B45")+".B45_CRM BETWEEN '" + cRdaDe + "' AND '" + cRdaAte + "' "
	
	ElseIf cRdaDe > cRdaAte
		cSql += " AND "+RetSqlName("B45")+".B45_CRM BETWEEN '" + cRdaAte + "' AND '" + cRdaDe + "' "
	EndIf
ElseIf !EMPTY(cRdaDe) .AND. EMPTY(cRdaAte)
	cSql += " AND "+RetSqlName("B45")+".B45_CRM >= '" + cRdaDe + "'"

ElseIf EMPTY(cRdaDe) .AND. !EMPTY(cRdaAte)
	cSql += " AND "+RetSqlName("B45")+".B45_CRM <= '" + cRdaAte + "'"

EndIf

cSql += " ORDER BY B45_CRM,B45_DATPRO " 

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbB45",.F.,.T.)

//Indica que deve imprimir o cabeçalho do solicitante
lFirst := .T.

While TrbB45->(!Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensagem de processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRdaDe := TrbB45->B45_CRM
	if !lautoSt
		MsProcTxt("Verificando... CRM: "+ Left("Filial: " + xFilial("B45") + STR0005 + objCENFUNLGP:verCamNPR("B45_CRM",TrbB45->B45_CRM),30))
		ProcessMessages()
	endif

	If BOW->(DbSeek(xFilial("B44")+TrbB45->B44_PROTOC))
		//Valisa de o protocolo não foi negado
		If !BOW->BOW_STATUS $ "7"

			If lFirst

				If BB0->(DbSeek(xFilial("B45")+TrbB45->B45_CRM))
					nLi++
					@ nLi , COL01 pSay objCENFUNLGP:verCamNPR("BB0_ESTADO",Pad(BB0->BB0_ESTADO, 05)) //UF CRM
					@ nLi , COL02 pSay objCENFUNLGP:verCamNPR("BB0_NUMCR",Pad(BB0->BB0_NUMCR, 09)) //CRM
					@ nLi , COL03 pSay objCENFUNLGP:verCamNPR("BB0_NOME",Pad(BB0->BB0_NOME, 30)) //Nome do solicitante
					nLi++
				EndIf

				lFirst := .F.
			EndIf

			//Detalhes
			@ nLi , COL04 pSay Pad(	objCENFUNLGP:verCamNPR("B44_OPEUSR",TrbB45->B44_OPEUSR)+;
									objCENFUNLGP:verCamNPR("B44_CODEMP",TrbB45->B44_CODEMP)+;
									objCENFUNLGP:verCamNPR("B44_MATRIC",TrbB45->B44_MATRIC)+;
									objCENFUNLGP:verCamNPR("B44_TIPREG",TrbB45->B44_TIPREG)+;
									objCENFUNLGP:verCamNPR("B44_DIGITO",TrbB45->B44_DIGITO),18) //Matricula Beneficiario
			@ nLi , COL05 pSay objCENFUNLGP:verCamNPR("B44_NOMCLI",Pad(TrbB45->B44_NOMCLI,30)) //Nome
			@ nLi , COL06 pSay objCENFUNLGP:verCamNPR("B45_DATPRO",Pad(STOD(TrbB45->B45_DATPRO),10))//Data procedimento
			@ nLi , COL07 pSay objCENFUNLGP:verCamNPR("BR4_DESCRI",Pad(Posicione("BR4",1,xFilial("BR4")+TrbB45->B45_CODPAD,"BR4_DESCRI"),18)) //Descrição da TDE
			@ nLi , COL08 pSay objCENFUNLGP:verCamNPR("B45_CODPRO",Pad(TrbB45->B45_CODPRO,16)) //Cod. Procedimento
			@ nLi , COL09 pSay objCENFUNLGP:verCamNPR("BR8_DESCRI",Pad(Posicione("BR8",1,xFilial("B45")+TrbB45->(B45_CODPAD+B45_CODPRO),"BR8_DESCRI"),25)) //Descrição do Procedimento
			@ nLi , COL10 pSay objCENFUNLGP:verCamNPR("B45_QTDPRO",Pad(TransForm(TrbB45->B45_QTDPRO, pMoeda1),08)) //Quant
			nLi++

			//Dados Financeiros
			@ nLi , COL12 pSay objCENFUNLGP:verCamNPR("B44_PROTOC",Pad(TrbB45->B44_PROTOC,08)) //Numero do protocolo

			//Busca o vencimento do título
			If SE1->(DbSeek(xFilial("SE1") + TrbB45->(B44_PREFIX+B44_NUM+B44_PARCEL+B44_TIPO) ))
				@ nLi , COL13 pSay objCENFUNLGP:verCamNPR("E1_VENCTO",Pad(SE1->E1_VENCTO,10)) //Data Vencimento
			EndIf

			@ nLi , COL14 pSay objCENFUNLGP:verCamNPR("B45_NF",Pad(TrbB45->B45_NF		,20)) //Nota Fiscal
			//Busca os valores da Guia
			If BD6->(MsSeek(xFilial("BD6")+TrbB45->(B45_OPEMOV+B45_CODLDP+B45_CODPEG+B45_NUMERO+B45_ORIMOV+B45_CODPAD+B45_CODPRO)))

				@ nLi , COL15 pSay objCENFUNLGP:verCamNPR("BD6_VLRAPR",Pad(TransForm(BD6->BD6_VLRAPR, pMoeda2),14) ) //Vlr Apresentado
				@ nLi , COL16 pSay objCENFUNLGP:verCamNPR("BD6_VLRBPR",Pad(TransForm(BD6->BD6_VLRBPR, pMoeda2),14) ) //Vlr Calculado
				@ nLi , COL17 pSay objCENFUNLGP:verCamNPR("BD6_VLRGLO",Pad(TransForm(BD6->BD6_VLRGLO, pMoeda2),14) ) //Vlr glosado
				@ nLi , COL18 pSay objCENFUNLGP:verCamNPR("BD6_VLRPAG",Pad(TransForm(BD6->BD6_VLRPAG, pMoeda2),14) ) //Vlr Total Reembolso

				//Acumula total por RDA
				nTotApr += BD6->BD6_VLRAPR
				nTotCal += BD6->BD6_VLRBPR
				nTotGlo += BD6->BD6_VLRGLO
				nTotReemb += BD6->BD6_VLRPAG
				
				nTotGApr += BD6->BD6_VLRAPR
				nTotGCal += BD6->BD6_VLRBPR
				nTotGGlo += BD6->BD6_VLRGLO
				nTotGReemb += BD6->BD6_VLRPAG

			EndIf
			nLi++
			//Controle de mudança de página
			If nLi > nQtdLin
				nPag++
				nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
				nLi++
				//Dados do solicitante
				@ nLi , COL01 pSay cCabec3
				nLi++
				//Dados do usuário, procedimento, reembolso e financeiro
				@ nLi , COL01 pSay cCabec4
				nLi++
				@ nLi , COL01 pSay cCabec5
				nLi++

				nLi++
				@ nLi , COL01 pSay objCENFUNLGP:verCamNPR("BB0_ESTADO",Pad(BB0->BB0_ESTADO, 07)) //UF CRM
				@ nLi , COL02 pSay objCENFUNLGP:verCamNPR("BB0_CODSIG",Pad(BB0->BB0_CODSIG, 10)) //CRM
				@ nLi , COL03 pSay objCENFUNLGP:verCamNPR("BB0_NOME",Pad(BB0->BB0_NOME, 30)) //Nome do solicitante
				nLi++
			EndIf
		EndIf
	EndIf
	TrbB45->(DbSkip())
	
	//Indica se deve imprimir o cabeçalho do solicitante
	If cRdaDe <> TrbB45->B45_CRM

		//Imprime Rodapé com Totais por RDA
		@ nLi , COL14 pSay Replicate("-",095)
		nLi++
		@ nLi , COL14 pSay STR0006//"Total solicitante:"
		@ nLi , COL15 pSay Pad(TransForm(nTotApr  , pMoeda2),14 ) //Vlr Apresentado
		@ nLi , COL16 pSay Pad(TransForm(nTotCal  , pMoeda2),14 ) //Vlr Calculado
		@ nLi , COL17 pSay Pad(TransForm(nTotGlo  , pMoeda2),14 ) //Vlr glosado
		@ nLi , COL18 pSay Pad(TransForm(nTotReemb, pMoeda2),14 ) //Vlr Total Reembolso
		nLi++

		//Seta para imprimir o cabeçalho da próxima RDA
		lFirst := .T.

		//ZERA TOTAIS POR RDA
		nTotApr := 0
		nTotCal := 0
		nTotGlo := 0
		nTotReemb := 0
	EndIf
EndDo

//Acumula totais gerais

	
TrbB45->(DbCloseArea())
//Imprime Rodapé
//Imprime Rodapé com Totais por RDA
nLi++
@ nLi , COL14 pSay Replicate("-",095)
nLi++
@ nLi , COL14 pSay STR0007//"Total Geral:"
@ nLi , COL15 pSay Pad(TransForm(nTotGApr  , pMoeda2),14 ) //Vlr Apresentado
@ nLi , COL16 pSay Pad(TransForm(nTotGCal  , pMoeda2),14 ) //Vlr Calculado
@ nLi , COL17 pSay Pad(TransForm(nTotGGlo  , pMoeda2),14 ) //Vlr glosado
@ nLi , COL18 pSay Pad(TransForm(nTotGReemb, pMoeda2),14 ) //Vlr Total Reembolso
nLi++

nLi +=3


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lautoSt
	Set Printer To
	OurSpool(crel)
endif

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

aadd(aRegs,{cPerg,"01",STR0008		,"","","mv_ch1","D",08,0,0,"G","","mv_par01","" ,"","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data De"
aadd(aRegs,{cPerg,"02",STR0009		,"","","mv_ch2","D",08,0,0,"G","","mv_par02","" ,"","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data Ate"
aadd(aRegs,{cPerg,"03","CRM de"		,"","","mv_ch3","C",06,0,0,"G","","mv_par03","" ,"","","","","","","","","","","","","","","","","","","","","","","","BTYPLS","",""}) //"CRM De"
aadd(aRegs,{cPerg,"04","CRM ate"	,"","","mv_ch4","C",06,0,0,"G","","mv_par04","" ,"","","","","","","","","","","","","","","","","","","","","","","","BTYPLS","",""}) //"CRM Ate	"

PlsVldPerg( aRegs )

Return

function PLSR992ast(lValor)
lautoSt := lValor
return
