#include "PLSMCOB2.CH"
#include "PLSMGER2.CH"
#include "PROTHEUS.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
#Define cCodigosPF "104,116,117,123,124,125,127,134,137,138,139,140,141,142,143,144,145,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,182,183"
#Define PLSVALOR "@E 99,999,999,999.99"

Static cCodDB := PLSRETLADC()
Static _aRecBSQ := {}
Static lPlAvaLan  	:= ExistBlock("PLAVALAN")
Static lPlCb2Mdf 	:= Existblock("PLCB2MDF")
Static lPlsTrlf		:= ExistBlock("PLSTRLF")
Static lPlsVlrFam	:= ExistBlock("PLSVLRFAM")
Static lPlsVlrFx	:= ExistBLock("PLSVLRFX")
Static lPlsVlrFm	:= ExistBlock("PLSVLRFM")
Static lPLSBSIDA    := ExistBlock("PLSBSIDA")
Static lPLSDSCMN    := ExistBlock("PLSDSCMN")
Static lPLSBA3DM    := ExistBlock("PLSBA3DM")
Static lPlsVlrOp	:= ExistBLock("PLSVLROP")
Static lPLDTRETRO   := ExistBlock("PLSDTRETRO")
Static lPlsLoau		:= ExistBlock("PLSLOADU")
Static lPtoEnt      := ExistBlock("PLSFCOV")
Static lPLSFTBZX    := ExistBlock("PLSFTBZX")
Static lPLSDSCOP    := ExistBlock("PLSDSCOP")
Static lPlsTrSld	:= ExistBlock("PLSTRSLD")
Static lPLSFILDC    := ExistBlock("PLSFILDC")
Static lPLSBSQES    := ExistBlock("PLSBSQES")
Static lPl627Per	:= ExistBlock("PL627PER")
Static lPlCobFat	:= ExistBlock("PLCOBFAT")
Static lPlDetCob	:= ExistBlock("PLDETCOB")
Static lPLSINTFOL	:= Existblock("PLSINTFOL")
Static lPLSOPCRG	:= ExistBlock("PLSOPCRG")
Static lPlsFimCb	:= ExistBlock("PLSFTMCB")
Static lPlsParFu	:= ExistBlock('PLSPARFI')
Static lPlsCbDr		:= ExistBlock("PLSCBDR")
Static lPlsFtOpc	:= ExistBlock("PLSFTOPC")
Static lPLVALAD1  	:= ExistBlock("PLVALAD1")                  
Static lPLVALAD2  	:= ExistBlock("PLVALAD2")      
Static lPlsDcFat	:= ExistBlock("PLSDCFAT")
Static lPlsVlr1c	:= ExistBlock("PLSVLRB1C")
Static lPLCBTXUS  	:= ExistBlock("PLCBTXUS")
Static lPlsLcToDif	:= ExistBlock("PLSLCTODIF")
Static lPlRetFcPf	:= ExistBlock("PLRETFCPF")
Static oPrepBK2A	:= nil
Static oPrepBK2B	:= nil
Static oPrepBK2C	:= nil
Static oPrepOpcA	:= nil
Static oPrepBZXA	:= nil
Static oPrepBDKA	:= nil
Static oPrepBBU		:= nil
Static oPrepBBY		:= nil
Static oPrepBDQ		:= nil
Static oPrepBDH		:= nil
Static oPrepBSQ 	:= nil
Static oPrepBRX 	:= nil
Static oPrepRHK 	:= nil
Static oPrepBF3 	:= nil
Static oPrepBIJ 	:= nil
Static oPrepBM1 	:= nil
Static objCENFUNLGP := CENFUNLGP():New()

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRFAM  ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o valor de cobranca de uma familia.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced 					                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Na versao 6.09 para traz ela tinha o nome de PLVALCONT     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³15.02.03³ XXXX ³  Reformulacao p a versao 8.11            ³±±
±±³Geraldo Jr. ³        ³      ³  Iterpretacao do reajuste.               ³±±
±±³Geraldo Jr. ³        ³      ³  Multiplos Faturamentos no mes...        ³±±
±±³Geraldo Jr  ³        ³      ³  Separacao em tela dos lanc. ja faturados³±±
±±³            ³        ³      ³  dos ainda nao faturados...              ³±±
±±³Geraldo Jr. ³        ³      ³  Demembramento dos lancamentos de debitos³±±
±±³            ³        ³      ³  e creditos em servicos medicos/acessorio³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
[01] - (C)redito (D)ebito.
[02] - Valor
[03] - Codigo do Lancamento (C 03)
[04] - Codigo do evento
[05] - Descricao Evento
[06] - Cargo (uso generico)
[07] - Matricula do usuario
[08] - Nome do usuario
[09] - Indice valido ou totalizador
[10] - Sexo do usuario
[11] - Grau de Parentesco
[12] - Numero do registro do Usuario (Recno do BA1)
[13] - Codigo da Faixa do lancamento utilizada
[14] - Nivel da faixa etaria utilizada
       1 - Valor Produto Produto/Plano (BB3)
       2 - Valor Produto Empresa  (BTN)
       3 - Valor Adesao  Produto (BRY)
       4 - Valor Adesao  Empresa (BR6)
       5 - Aumentos ANS Nivel Operadora Cabecalho (BH9)
       6 - Aumentos ANS Nivel Operadora Itens (BTX)
       7 - Valor dos opcionais Cabecalho (BT3)
       8 - Valor dos opcionais Itens (BCB)
       9 - Valor da Coparticipacao
[15] - Tipo de Usuario
[16] - Cliente do Lancamento
       1 Codigo do Cliente
       2 Loja do Cliente
       3 Codigo do Fornecedor
       4 Loja do Fornecedor
       5 Valor a Faturar  //Por Enquanto usado somente na Co-participacao

PENDENCIA URGENTE:

	Tratar a seguinte regra para cobranca retroativa:

		DIA RETROATIVO DA EMPRESA 	: 20
		DATA DE CADASTRO DA EMPRESA : 05/01/2005
		INCLUSAO DO USUARIO			: 22/01/2005 antes este usuario nao era cobrado, agora foi implentado
									  regra que analiza se o mes e ano do usuario eh o mesmo da empresa e ja fatura
									  o usuario.

									  Acontece que ao faturar o mes seguinte, ele cobra o usuario novamente como
									  retroativo. Ele nao pode fazer isso.
/*/
Function PLSVLRFAM(cMatric,cAno,cMes,aEventosCb,aCliente,lDireto,aUsuarios,lOnlyLook,lRetMov,dData,aFoCoPF,aLanUsu,cNumCob,lExecute,cReemb,dDatPagto,aCliente,nParAglut)
LOCAL nY		:= 0
LOCAL nX		:= 0
LOCAL nInd      := 0
LOCAL nPeriod 	:= 0
LOCAL nJaFat 	:= 0
LOCAL nValTot	:= 0
LOCAL pMoeda 	:= "@E 99,999,999,999.99"
LOCAL cTipoGru	:= ""
LOCAL cForPag	:= ""
LOCAL cRdmake   := ""
LOCAL cFatura 	:= ""
LOCAL cAnoMesAnt:= ""
LOCAL lPeriod 	:= .F.
LOCAL lBusFat 	:= .F.
LOCAL lFlagTit  := .T.
LOCAL cCritica  := ""
LOCAL lGerNFBRA := ( GetNewPar("MV_PLSNFBR","0") == "1" .Or. cPaisLOC <> 'BRA' )
LOCAL aAreaBa3	:= BA3->(GetArea())
LOCAL aAreaBa1	:= BA1->(GetArea())
LOCAL aAux   	:= {}
LOCAL aRet   	:= {}
LOCAL aJaFat 	:= {}
LOCAL aRetPto 	:= {}
LOCAL aRetAux	:= {}
LOCAL aRetPer   := {}
LOCAL aRetMov   := {}
LOCAL aRetAcu   := {}
LOCAL aRecBDH 	:= {}
LOCAL aRetAcF	:= {}
LOCAL aCritica  := {}
LOCAL lDatPagto := GetNewPar("MV_PLSDTPG",.F.)
LOCAL aFatBM1   := {}
LOCAL cCodOpe 	:= ""
LOCAL nPos      := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao seja especificado obtem o valor na DataBase...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cAno       	:= PLSSTRANO(dDataBase,.T.)
DEFAULT cMes       	:= PLSSTRMES(dDataBase)
DEFAULT cNumCob		:= ""
DEFAULT dData		:= dDataBase
DEFAULT lDireto		:= .F.
DEFAULT lOnlyLook	:= .F.
DEFAULT lRetMov     := .F.
DEFAULT aEventosCb  := {}
DEFAULT aUsuarios   := {}
DEFAULT aFoCoPF		:= {}
DEFAULT aLanUsu		:= {}
DEFAULT lExecute    := .T.
DEFAULT cReemb      := "2"
DEFAULT dDatPagto   := cTod("")
DEFAULT aCliente	:= {}
DEFAULT nParAglut   := 2
SetFrzFai()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no arquivo de contratos...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC) <> xFilial("BA3")+Left(cMatric,14)
 	If ! BA3->(MsSeek(xFilial("BA3")+Left(cMatric,14)))
		RestArea(aAreaBa3)
		RestArea(aAreaBa1) 
		Return(A627RetCri(@aCritica, '03', 0))
    EndIf
	aAreaBa3	:= BA3->(GetArea())
EndIf

If Len(aCliente) == 0
	aCliente := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,;
						  BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),;
						  BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
						  BA3->BA3_VERSUB,1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no grupo/empresa...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BG9->(DbSetOrder(1))
If BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) <> xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP) .And. !BG9->(MsSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
	RestArea(aAreaBa3)
	RestArea(aAreaBa1) 
	Return(A627RetCri(@aCritica, '13', 0))
Else
	cTipoGru := BG9->BG9_TIPO
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for pessoa juridica posiciono no contrato da empresa...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoGru == "2"
	BT5->(DbSetOrder(1))
	If BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <> xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON) .And. ;
		! BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)))
		RestArea(aAreaBa3)
		RestArea(aAreaBa1) 

		Return(A627RetCri(@aCritica, '08', 0))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for pessoa juridica posiciono no sub-contrato da empresa...      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BQC->(DbSetOrder(1))
	If  BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) .And. ;
		! BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))

		RestArea(aAreaBa3)
		RestArea(aAreaBa1) 

		Return(A627RetCri(@aCritica, '06', 0))
	EndIf

	If BT6->(BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO) <> ;
		xFilial("BT6")+BA3->(BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB+BA3->BA3_CODPLA+BA3->BA3_VERSAO) ;
		.And. ! BT6->(MsSeek(	xFilial("BT6") + BA3->BA3_CODINT +;
		BA3->BA3_CODEMP + BA3->BA3_CONEMP + BA3->BA3_VERCON + BA3->BA3_SUBCON+;
		BA3->BA3_VERSUB + BA3->BA3_CODPLA + BA3->BA3_VERSAO))

		RestArea(aAreaBa3)
		RestArea(aAreaBa1) 

		Return(A627RetCri(@aCritica, '16', 0))
	EndIf
EndIf

cForPag	:=BA3->BA3_FORPAG
cRdmake := AllTrim(BA3->BA3_ROTINA)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao seja encontrado a forma de pagto aborto...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cForPag)
	RestArea(aAreaBa3)
	RestArea(aAreaBa1) 
	Return(A627RetCri(@aCritica, '17', 0))

Elseif Empty(cRdmake)
	RestArea(aAreaBa3)
	RestArea(aAreaBa1) 

	Return(A627RetCri(@aCritica, '18', 0))

Elseif !Empty(cRdmake)
     If !(cRdMake == "PLSPORFAI" .OR. cRdMake == "PLSPORFSL")
    	If !ExistBlock(cRdmake)
			RestArea(aAreaBa3)
			RestArea(aAreaBa1) 
			Return(A627RetCri(@aCritica, '19', 0))
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se os eventos de cobranca estiver em branco eu releio...            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aEventosCb)
   aEventosCb := PLSINPBFQ(BA3->BA3_CODINT)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Como sera calculada a PF do beneficiario...           				|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aFoCoPF) == 0
	aFoCoPF := PLSRETFCPF(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
					  	  BA3->BA3_VERSUB,BA3->BA3_CODPLA,BA3->BA3_VERSAO,BA3->BA3_TIPOUS)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pego os tipos de lancamente de usuario...     						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aLanUsu) == 0
	aLanUsu := PLSRETLANU(BA3->BA3_CODINT)
EndIf

BDK->(DbSetOrder(1))
BFY->(DbSetOrder(1))
BDQ->(DbSetOrder(1))
SA1->(DbSetOrder(1))
BQC->(DbSetOrder(1))
BFZ->(DbSetOrder(1))
BG1->(DbSetOrder(1))

If cRdMake == "PLSPORFAI"
   aAux := PLSBUSFAI(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),cAno,cMes,cForPag,aEventosCB,aCliente,aUsuarios,lDireto,lOnlyLook,cRdMake,aFoCoPF,aLanUsu,cNumCob,cReemb,lDatPagto,dDatPagto)
ElseIf cRdMake == "PLSPORFSL"
   aAux := PLSBUSFSL(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),cAno,cMes,cForPag,aEventosCB,aCliente,aUsuarios,lDireto,lOnlyLook,cRdMake,aFoCoPF,aLanUsu,cNumCob,cReemb,lDatPagto,dDatPagto)
Else
	aAux := ExecBlock(cRdmake,.F.,.F.,{BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),cAno,cMes,cForPag,aEventosCB,aCliente,aUsuarios,lDireto,lOnlyLook,cRdMake,aFoCoPF,aLanUsu,cNumCob})
EndIf

//Tratativa para cenários com Aglutinação de cobranças (A FATURAR)
//Quando ocorre a aglutinação, deve-se obter a descrição
//que vem do Tipo de Lançamento de Faturamento (BFQ) 
For nPos := 1 To Len(aAux)
	If !Empty(aAux[nPos, 3]) .And. !Empty(aAux[nPos, 7])
		cCodOpe := SUBSTR(aAux[nPos, 7], 0, 4)

		If nParAglut == 1
			aAux[nPos, 5] := BFQ->(Posicione("BFQ",1,xFilial("BFQ")+cCodOpe+aAux[nPos, 3],"BFQ_DESCRI"))
		EndIf
	EndIf
Next

If GetNewPar("MV_PL9BPRA","0") == "1"  .And. Len(aAux) > 0
	CalcProRat(@aAux, cAno, cMes)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Clone																³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := aClone(aAux)



If lDireto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na primeira matricula e nao considera o mes e ano			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BM1->( DbSetOrder(1) ) //BM1_FILIAL + BM1_CODINT + BM1_CODEMP + BM1_MATRIC + BM1_ANO + BM1_MES + BM1_TIPREG + BM1_SEQ
	If BM1->( MsSeek( xFilial("BM1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+cAno+cMes) ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca a composicao de cobranca calculada...                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFatura := BM1->(BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT)
		aFatBM1 := {BM1->BM1_PREFIX,BM1->BM1_NUMTIT,BM1->BM1_PARCEL,BM1->BM1_TIPTIT}

		While ! BM1->( Eof() ) .And. BM1->(BM1_FILIAL+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES) == xFilial("BM1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAno+cMes

  			AaDd(aJaFat,{	BM1->BM1_TIPO,;	//01
							BM1->BM1_VALOR,;//02
							BM1->BM1_CODTIP,;//03
							IIF(nParAglut == 1, AllTrim(BM1->BM1_CODTIP), AllTrim(BM1->BM1_CODEVE)),;//04
							IIF(nParAglut == 1, AllTrim(BM1->BM1_DESTIP), AllTrim(BM1->BM1_DESEVE)),;//05
							BM1->BM1_CARGO,;//06
							BM1->BM1_MATUSU,;//07
							BM1->BM1_NOMUSR,;//08
							IIF(BM1->BM1_LTOTAL=="0",.T.,.F.),;//09
							BM1->BM1_SEXO,;//10
							BM1->BM1_GRAUPA,;//11
							0,;//12 - Filler
							BM1->BM1_CODFAI,;//13
							BM1->BM1_NIVFAI,;//14
							BM1->BM1_TIPUSU,;//15
							BM1->BM1_ALIAS,;//16
							BM1->BM1_ORIGEM,;//17
							BM1->BM1_BASEIR,;//18
							BM1->(BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT),;//19
							BM1->BM1_PLNUCO,;//20
							BM1->BM1_CODSB1,;//21
							BM1->BM1_CODTES,;//22
							BM1->(Recno())})//23
					BM1->(DbSkip())
		EndDo

		BK2->(DbSetOrder(2))
		If 	BK2->(MsSeek(xFilial("BK2")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+cAno+cMes)))

		   	While ! BK2->(Eof()) .And. BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES) == xFilial("BK2")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAno+cMes

 		   	    // Se for parcelamento nao precisa
 		   		If Iif(BK2->(FieldPos("BK2_LOTPAR")) > 0, Empty(BK2->BK2_LOTPAR), .T.)

		  		   	AaDd(aRetAcF, Array(26))

		  		   	aRetAcF[Len(aRetAcF)][3]  := BK2->(BK2_PROPRI+BK2_CODLAN)
		  		   	aRetAcF[Len(aRetAcF)][5]  := Posicione("BFQ",1,xFilial("BFQ")+BK2->(BK2_CODINT+BK2_PROPRI+BK2_CODLAN),"BFQ_DESCRI")
		  		   	aRetAcF[Len(aRetAcF)][24] := BK2->BK2_SALDO
		  		   	aRetAcF[Len(aRetAcF)][25] := BK2->BK2_SALDO2

  		   		EndIf

  				BK2->(DbSkip())
  			Enddo
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aRet vai estar com o BM1 cheio  									|
//| vou enxer mais ainda o BM1 com saldo do mes (BK2) anterior se       |
//| e somente se nao houve geracao de cobranca para aquela familia      ³
//| depois vou esvaziar conforme limite de desconto por tp lanceto se   |
//| o produto tiver														|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RestArea(aAreaBa3)


If  lPlsTrSld 
	aAuxRet := ExecBlock("PLSTRSLD",.F.,.F.,{aRet,cAno,cMes,BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,dData,BA3->BA3_CODPLA,BA3->BA3_VERSAO,aFoCoPF})
Else
	aAuxRet := PLSMONVER(aRet,cAno,cMes,BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,dData,BA3->BA3_CODPLA,BA3->BA3_VERSAO,aFoCoPF,aCliente)
Endif
aRet    := aClone(aAuxRet[1])
aRetAcu := aClone(aAuxRet[2])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula totais...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRet) > 0
	aRetAux := {}
	nValTot := 0
	For nY := 1 To Len(aRet)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Protege a matriz													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aRet[nY]) > 0
			nValorEve 	:= aRet[nY,2]
			nVlrMes		:= aRet[nY,23]
			nSaldo1		:= aRet[nY,24]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente os lancamentos com valor maior que 0						³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nValorEve > 0 .Or. ( Len( aRet[nY] ) >= 24 .And. nSaldo1+nVlrMes > 0 )
				AaDd(aRetAux,aRet[nY])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Debito																³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRet[nY][1] == "1"
					nValTot -= Round(aRet[nY,2], 2)
				Else
					nValTot += Round(aRet[nY,2], 2)
				EndIf
			EndIf
		EndIf
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Critico se o valor da familia for negativo							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == 'URU' .And. nValTot > 0 .And. !Empty(cNumCob) .And. !lDireto
	RestArea(aAreaBa3)
	RestArea(aAreaBa1) 
	Return(A627RetCri(@aCritica, "27", nValTot))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta a matriz														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet 	:= AClone(aRetAux)
aRetAux := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valores ja faturados                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nY := 1 To Len(aJaFat)
	If aJaFat[nY,2] > 0
		AaDd(aRetAux,aJaFat[nY])

		If aJaFat[nY,9]
			If aJaFat[nY,1] == "1"
				nJaFat -= Round(aJaFat[nY,2], 2)
			Else
				nJaFat += Round(aJaFat[nY,2], 2)
			EndIf
		EndIf
	EndIf
Next
aJaFat  := AClone(aRetAux)
aRetAux := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaBa3)
RestArea(aAreaBa1) 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Movimentos que fizeram parte do custo operacional...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRetMov
	If ExistBlock("PLCOBDAT")
		cAnoMesAnt := ExecBlock("PLCOBDAT", .F., .F., {cAno, cMes})
	Elseif aFoCoPF[1] == "1"
		cAnoMesAnt := cAno+cMes
	Else
		cAnoMesAnt := PLSDIMAM(cAno,cMes,"0")
	EndIf
   lBusFat 	  := !Empty(cFatura)
   aRetMov    := PLSVLRPF(cMatric,Subs(cAnoMesAnt,1,4),Subs(cAnoMesAnt,5,2),nil,nil,.T.,lBusFat,cFatura,nil,aFatBM1,.T.)

EndIf

If lPlsVlrFm 
	aRetPto := ExecBlock("PLSVLRFM",.F.,.F.,{aRet,cMatric,cAno,cMes,aJaFat,aRetMov,{},aRetAcF,aRetAcu,cForPag})
   aRet    := aRetPto[1]
   aJaFat  := aRetPto[2]
   aRetMov := aRetPto[3]
   aRetAcF := aRetPto[5]
   aRetAcu := aRetPto[6]
EndIf

If lGerNFBRA
	nInd := Ascan(aRet,{|x| AllTrim(x[38]) == ""}) //TES

	If nInd > 0
		RestArea(aAreaBa3)
		RestArea(aAreaBa1) 

		Return(A627RetCri(@aCritica, '24', 0))
	Else
		
		SF4->(DbSetOrder(1))//Tes
		For nInd := 1 To Len(aRet)

			If ! SF4->(DbSeek(xFilial("SF4") + aRet[nInd,38]))
		
				   lFlagTit := .F.
				   cCritica := "24"
				   Exit
		
			ElseIf SF4->F4_DUPLIC <> "S"
				   lFlagTit := .F.
				   cCritica := "25"
				   Exit
			EndIf
		
		Next
		If ! lFlagTit
	   		RestArea(aAreaBa3)
			RestArea(aAreaBa1) 

		   Return(A627RetCri(@aCritica, cCritica, 0))
		EndIf
	EndIf

	nInd := Ascan(aRet,{|x| AllTrim(x[37]) == ""}) //PRODUTO
	If nInd > 0
		RestArea(aAreaBa3)
		RestArea(aAreaBa1) 

		Return(A627RetCri(@aCritica, '23', 0))
    Else
		SB1->(DbSetOrder(1))
		For nInd := 1 To Len(aRet)
			If    ! SB1->(DbSeek(xFilial("SB1")+aRet[nInd,37]))
				  lFlagTit := .F.
				  Exit
			EndIf
		Next
		If ! lFlagTit
	   		RestArea(aAreaBa3)
			RestArea(aAreaBa1) 

		   Return(A627RetCri(@aCritica, '23', 0))
		EndIf
    EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 					## Ponto de Entrada da Periodicidade ##       				    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPl627Per .And. FunName()=="PLSA627" .And. lExecute
	aRetPer 	:= Execblock("PL627PER",.F.,.F.,{aRet,Substr(cMatric,1,4),Substr(cMatric,5,4),Substr(cMatric,9,6),cAno,cMes,aEventosCb,aLanUsu,cNumCob,nValTot})
	// Retorno
	lPeriod 	:= aRetPer[1]  			       // Se é Periodicidade.
	nPeriod 	:= aRetPer[2] 			       // Numero Periodo de faturacao.
	aRet     	:= aClone(aRetPer[3]) 	       // Todos os lançamentos inclusive com periodicidade.
	nValTot     := aRetPer[4]                 // Valor Total
	// Caso queira Retornar Critica
	If Len(aRet) ==0 .And. !Empty(aRetPer[5])// Codigo Critica
		Return(A627RetCri(@aCritica, aRetPer[5], 0))
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return({ { .T.,aRet,ABS(nValTot),IIF(nValTot<0,"D","C"),lPeriod,nPeriod},;
		 { Iif( Len(aJaFat)>0 ,.T.,.F. ),aJaFat,ABS(nJaFat),IIF(nJaFat<0,"D","C") },;
		 aRetMov,;	// Retorna a movimentacao
		 aRetAcu,;	// Acumulados
		 {},;		// aCriticas
		 {},;		// Obsoleto - Esta informacao esta no corpo da composicao da cobranca.
		 aRetAcF} )	// Acumulados jah faturados

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRCOB  ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o valor de cobranca de uma familia.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Na versao 6.09 para traz ela tinha o nome de PLVALCOB      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³08.03.02³ 7.10 ³  Novas Funcionalidades                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRCOB(cAno,cMes,lDireto,lAutomato)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aArea		:= GetArea()
Local i
LOCAL aValor
LOCAL oDlg
LOCAL nRegBA1 		:= BA1->(Recno())
LOCAL nOrdBA1 		:= BA1->(IndexOrd())
LOCAL bRest   		:= { || BA1->(DbSetOrder(nOrdBA1)), BA1->(DbGoTo(nRegBA1)) }
LOCAL oTree
LOCAL nInd
LOCAL nAux
LOCAL cQuebra 		:= ""
LOCAL bOK     		:= { || oDlg:End() }
LOCAL oGrupo
LOCAL oSay
LOCAL oSayTot
LOCAL bMatric 		:= { || BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) }
LOCAL cMatric 		:= Eval(bMatric)
LOCAL nTotCre 		:= 0
LOCAL nTotDeb 		:= 0
LOCAL nTotal  		:= 0
LOCAL nTotFam  		:= 0
LOCAL nTotPat  		:= 0
LOCAL cTipo

LOCAL nTJaCre 		:= 0
LOCAL nTJaDeb 		:= 0
LOCAL nTotJa  		:= 0
LOCAL cTipJa  		:= ''

LOCAL aVerbas 		:= {}
LOCAL aAux    		:= {}
LOCAL aJaFat  		:= {}
LOCAL aRecnosBD6 	:= {}
LOCAL aButtons 		:= {{"RELATORIO",{|| If(Len(aRecnosBD6)>0,PLHISMOV(cMatric,nil,nil,.T.,aRecnosBD6),MsgStop(STR0001)) },STR0002,STR0003}} //"Nao existem movimentos a serem exibidos"###"Movimentacao da Co-Participacao/Custo Operacional"###"Co-Part."
LOCAL cBmp
LOCAL cLastCargo 	:= "00"
LOCAL aAglutina  	:= {}, nItem, nAglutina, nPosAglu
LOCAL cOperadora 	:= ""
LOCAL cEmpresa   	:= ""
LOCAL cNumero	  	:= ""
LOCAL cLblMatric 	:= ""
LOCAL cTexto
LOCAL aEspBK2   	:= {}
LOCAL cDado		 	:= ""
LOCAL aDados    	:= {}
LOCAL nFor		 	:= 0
LOCAL nValUsr		:= 0
LOCAL nParAglut		:= 2
LOCAL aTotLan	 	:= {}
LOCAL aRetAcu   	:= {}
LOCAL aRetAcF	 	:= {}
LOCAL cSubCon		:= ''
LOCAL cNumTit		:= ''
LOCAL cNumLot		:= ''
LOCAL oFont
LOCAL aCabCri  		:= { {STR0004,"@!",45},{STR0005,"@!",300}} //"Código"###"Critica"
LOCAL aDadCri		:= {}
LOCAL lValT1        := .F.
LOCAL lValT2        := .F.
LOCAL lGerNFBRA 	:= ( GetNewPar("MV_PLSNFBR","0") == "1" .Or. cPaisLOC <> 'BRA' )
LOCAL oTreeJa
// Patronal a cobrar.
LOCAL nTotPatCd1 	:= 0
LOCAL nTotPatDb1 	:= 0
Local aCredPatronal := {}

// Patronal cobrado.
LOCAL nTotPatCd2 	:= 0
LOCAL nTotPatDb2 	:= 0

LOCAL nI			:= 0

PRIVATE oBrwRDS
PRIVATE oBrwRDF

DEFAULT cAno   		:= ""
DEFAULT cMes 		:= ""
DEFAULT lDireto 	:= .F.
DEFAULT lAutomato   := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca dados dos parametros pelo usuario...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cAno) .Or. Empty(cMes)
	If ! Pergunte("PLA730",.T.)
		Return
	EndIf

	cAno       	:= mv_par01
	cMes		:= mv_par02
	nParAglut	:= mv_par03
else
   	nParAglut 	:= 2
EndIf

If !lAutomato
    aSize := MsAdvSize()
    aObjects := {}
    AAdd( aObjects, { 100, 200, .T., .T. } )

    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
    aPosObj := MsObjSize( aInfo, aObjects )
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Define fontes utilizadas somente nesta funcao...                         ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Define FONT oFont NAME "Courier New" Size 0,-10 BOLD
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Posiciona nos arquivos utilizados...                                ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndIF

BA1->(DbSetOrder(2))
If ! BA1->(MsSeek(xFilial("BA1")+Eval(bMatric)))
	Eval(bRest)
EndIf

BA0->(DbSetOrder(1))
BA0->(MsSeek(xFilial("BA0")+BA1->BA1_CODINT))

BG9->(DbSetOrder(1))
BG9->(MsSeek(xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP)))

BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

If BG9->BG9_TIPO == "2"
	BT5->(DbSetOrder(1))
	BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP)))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa funcao que retornara composicao de cobranca...              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := PLSVLRFAM(Eval(bMatric),cAno,cMes,NIL,NIL,lDireto,Nil,NIL,.T., , , , , , , , ,nParAglut)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se houve critica na apuracao do valor de cobranca...		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aAux) == 1 .and. !aAux[1][1] .AND. !lAutomato
	aDadCri := {{aAux[1][2], aAux[1][3]}}
	PLSCRIGEN(aDadCri,aCabCri,STR0006) //"Critica de faturamento."
	Return()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valores a faturar.													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aValor := aAux[1]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valores faturados.													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aAux) >= 2
	aJaFat := aAux[2]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para tratar o aValor, pois com Periodicidade pode ter registros ja Faturados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aJaFat) > 1 .And. Len(aJaFat[2]) > 0 .And.  lPlCobFat 
   	aValor:= ExecBlock("PLCOBFAT",.F.,.F.,{ aValor, aJaFat, cAno, cMes, BA3->(Recno()) })
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Movimentacao da participacao financeira.													  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aAux) >= 3
   For nFor := 1 To Len(aAux[3])
       aadd(aRecnosBD6,aAux[3,nFor,1])
   Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acumulado mensal.																			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aAux) >= 4
	aRetAcu:= aAux[4]
EndIf

If Len(aAux) >= 7
	aRetAcF:= aAux[7]
EndIf

If !lAutomato
    Aadd( aButtons, {"SIMULACAO",{|| PLSHISTREA(oTree)},STR0007,STR0008}) //"Historico de Reajuste do produto"###"Reajuste"
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Ponto de Entrada para customização de detalhamento da Cobrança 								  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndIF
If  lPlDetCob 
   	Aadd( aButtons, {"Relatorio",{|| ExecBlock("PLDETCOB",.F.,.F.,{aValor[2],aJaFat[2]}) },STR0010,STR0011})     //"Detalhamento de Cobrança"###"Detalhe"
EndIf                                                                                         `

If ValType(nParAglut) = "C"
	nParAglut := 2
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata aglutinacao de valores a faturar...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aValor[1] .And. nParAglut = 1
	aAglutina := AClone(aValor[2])
	aValor := {.T.,{},0}
	For nItem := 1 To Len(aAglutina)
		If aAglutina[nItem][2] # 0
			Aadd(aValor[2], AClone(aAglutina[nItem]))
			If ! Empty(aAglutina[nItem][3])
				For nAglutina := nItem + 1 To Len(aAglutina)
					If (nPosAglu := (Ascan(aAglutina, {|x| 	x[1] == aAglutina[nItem][1] .And.;
															aAglutina[nItem][2] > 0 .And.;
															x[3] == aAglutina[nItem][3] .And.;
															x[7] == aAglutina[nItem][7] }, nAglutina ))) > 0
						aValor[2][Len(aValor[2])][2] += aAglutina[nPosAglu][2]
						aAglutina[nPosAglu][2] := 0
					EndIf
				Next
			EndIf
		EndIf
	Next
ElseIf ! aValor[1]
	eval(bRest)
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata aglutinacao de valores ja faturados...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAglutina := {}
If aJaFat[1] .And. nParAglut = 1
	aAglutina := AClone(aJaFat[2])
	aJaFat := {.T.,{},0}
	For nItem := 1 To Len(aAglutina)
		If aAglutina[nItem][2] # 0
			Aadd(aJaFat[2], AClone(aAglutina[nItem]))
			If ! Empty(aAglutina[nItem][3])
				For nAglutina := nItem + 1 To Len(aAglutina)
					If (nPosAglu := (Ascan(aAglutina, {|x| 	x[1] == aAglutina[nItem][1] .And.;
															aAglutina[nItem][2] > 0 .And.;
															x[3] == aAglutina[nItem][3] .And.;
															x[7] == aAglutina[nItem][7] }, nAglutina ))) > 0
						aJaFat[2][Len(aJaFat[2])][2] += aAglutina[nPosAglu][2]
						aAglutina[nPosAglu][2] := 0
					EndIf
				Next
			EndIf
		EndIf
	Next
EndIf

// Calcula o credito para familia baseado na cobranca patronal quando o modo de cobranca for = COMPARTILHADA.
aCredPatronal := GetVlrCredPatronal(aValor)

If Len(aCredPatronal) >= 2
	nTotPatCd1 := aCredPatronal[1]
	nTotCre := aCredPatronal[2]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata uma possivel nao-conformidade na rotina... itens a faturar    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aValor[1]
	For nI := 1 To Len(aValor[2])
		If !aValor[2][nI][9]
			If aValor[2][nI][3] $ "186,187,188"	// Referente a parcela patronal.
				If aValor[2][nI][1] == "2"
					nTotPatCd1 += aValor[2][nI][2]

				Else
					nTotPatDb1 += aValor[2][nI][2]

				Endif
			Else
				If aValor[2][nI][1] == "2"
					nTotCre += aValor[2][nI][2]

				Else
					nTotDeb += aValor[2][nI][2]

				Endif
			Endif
		Endif
	Next

	If (nTotDeb+nTotPatDb1) >= (nTotCre+nTotPatCd1)
		cTipo  := "D"
		nTotal := (nTotDeb+nTotPatDb1) - (nTotCre+nTotPatCd1)
		nTotFam:= (nTotDeb) - (nTotCre)
		nTotPat:= (nTotPatDb1) - (nTotPatCd1)
	Else
		cTipo  := "C"
		nTotal := (nTotCre+nTotPatCd1) - (nTotDeb+nTotPatDb1)
		nTotFam := (nTotCre) - (nTotDeb)
		nTotPat := (nTotPatCd1) - (nTotPatDb1)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata uma possivel nao-conformidade na rotina... itens ja faturados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aJaFat[1]
	// aEval(aJaFat[2], { |x| If(x[1]=="2",nTJaCre := nTJaCre + x[2],nTJaDeb := nTJaDeb + x[2]) })

	For nI := 1 to Len(aJaFat[2])
		If aJaFat[2][nI][3] $ "186,187,188"	// Referente a parcela patronal.
			If aJaFat[2][nI][1] == "2"
				nTotPatCd2 += aJaFat[2][nI][2]

			Else
				nTotPatDb2 += aJaFat[2][nI][2]

			Endif
		Else
			If aJaFat[2][nI][1] == "2"
				nTJaCre += aJaFat[2][nI][2]
			Else
				nTJaDeb += aJaFat[2][nI][2]
			Endif
		Endif
	Next

	If (nTJaDeb+nTotPatDb2) >= (nTJaCre+nTotPatCd2)
		cTipJa  := "D"
		nTotJa 	:= (nTJaDeb+nTotPatDb2) - (nTJaCre+nTotPatCd2)
	Else
		cTipJa  := "C"
		nTotJa 	:= (nTJaCre+nTotPatCd2) - (nTJaDeb+nTotPatDb2)
	EndIf

	If Len(aJaFat[2]) > 0
		cNumTit := aJaFat[2][1][19]
		cNumLot := aJaFat[2][1][20]
	EndIf
EndIf

If !lAutomato
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta dialogo com usuario...                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE DIALOG oDlg TITLE STR0051 + "  -   "+cAno+" / "+cMes+ "   ..."   FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta folders...                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aJaFat[2]) > 0 .or. (aScan(aRetAcF,{|x| x[24] > 0 .or. x[25] > 0}) > 0)
		@ aPosObj[1][1],aPosObj[1][2] FOLDER oFolder SIZE aPosObj[1][4],aPosObj[1][3] OF oDlg PIXEL	PROMPTS	STR0013,STR0014 //"A Faturar <F4>"###"Faturados <F5>"
		SetKey( VK_F4 , { || oFolder:SetOption(1) } )
		SetKey( VK_F5 , { || oFolder:SetOption(2) } )
	Else
		@ aPosObj[1][1],aPosObj[1][2] FOLDER oFolder SIZE aPosObj[1][4],aPosObj[1][3]  OF oDlg PIXEL	PROMPTS	STR0015 //"A Faturar"
	EndIf
	aPosObj[1][1] := 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta says...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPosObj[1][1]+3,aPosObj[1][2]+2 BITMAP oBmp RESNAME "BR_VERDE_OCEAN" 				OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+17 Say oSay PROMPT STR0016 			  				SIZE 070,010 OF oFolder:aDialogs[1] PIXEL //"Débito"

	@ aPosObj[1][1]+3,aPosObj[1][2]+67 BITMAP oBmp RESNAME "BR_VERMELHO_OCEAN"			OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+77 Say oSay PROMPT STR0017 						SIZE 070,010 OF oFolder:aDialogs[1] PIXEL //"Crédito"

	@ aPosObj[1][1]+3,aPosObj[1][2]+127 BITMAP oBmp RESNAME "BR_AZUL_OCEAN"				OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+137 Say oSay PROMPT STR0018 				SIZE 070,010 OF oFolder:aDialogs[1] PIXEL //"Total do usuário"

	cOperadora := TransForm(BA1->BA1_CODINT,"@R !.!!!")+ "  -  "+subs(BA0->BA0_NOMINT,1,35)
	@ (aPosObj[1][3]/2.5)+20, 200 GROUP oGrupo TO (aPosObj[1][3]/2.5)+41, 400 PIXEL OF oFolder:aDialogs[1] LABEL STR0019  COLOR CLR_HBLUE, CLR_HRED //" Operadora "
		PLSSAYESP((aPosObj[1][3]/2.5)+30,205,{ || cOperadora },;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	cEmpresa := TransForm(BA1->BA1_CODEMP,"!!!!")+ "  -  "+subs(BG9->BG9_DESCRI,1,36)
	@ (aPosObj[1][3]/2.5)+45, 200 GROUP oGrupo TO (aPosObj[1][3]/2.5)+66, 400 PIXEL OF oFolder:aDialogs[1] LABEL STR0020  COLOR CLR_HBLUE, CLR_HRED //" Grupo Empresa "
		PLSSAYESP((aPosObj[1][3]/2.5)+56,205,{ || cEmpresa },;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	cNumero 	:= If(BG9->BG9_TIPO=="2", TransForm(BA1->BA1_CONEMP,"!!!!!!!!!!!!"), BA1->BA1_NUMCON)
	@ (aPosObj[1][3]/2.5)+71, 200 GROUP oGrupo TO (aPosObj[1][3]/2.5)+92, 255 PIXEL OF oFolder:aDialogs[1] LABEL If(BG9->BG9_TIPO=="2",STR0021,STR0022)  COLOR CLR_HBLUE, CLR_HRED //" Contrato Empresa "###"Numero Contrato"
		PLSSAYESP((aPosObj[1][3]/2.5)+82,205,{ || cNumero },;
					200,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	cSubCon 	:= If(BG9->BG9_TIPO=="2", TransForm(BA1->BA1_SUBCON,"!!!!!!!!!"), BA1->BA1_SUBCON)
	@ (aPosObj[1][3]/2.5)+71, 260 GROUP oGrupo TO (aPosObj[1][3]/2.5)+92, 300 PIXEL OF oFolder:aDialogs[1] LABEL STR0023  COLOR CLR_HBLUE, CLR_HRED //"Subcontrato"
		PLSSAYESP((aPosObj[1][3]/2.5)+82,265,{ || cSubCon },;
					200,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	cLblMatric 	:= BA1->BA1_MATRIC
	@ (aPosObj[1][3]/2.5)+71, 305 GROUP oGrupo TO (aPosObj[1][3]/2.5)+92, 340 PIXEL OF oFolder:aDialogs[1] LABEL STR0024  COLOR CLR_HBLUE, CLR_HRED //" Matricula "
	PLSSAYESP((aPosObj[1][3]/2.5)+82,310,{ || cLblMatric },;
				150,;
				006,;
				oFolder:aDialogs[1],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta autogestao...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nInd := 1 to Len(aRetAcu)
	If (nAux := aScan(aTotLan, {|x| x[1] == aRetAcu[nInd][3]})) == 0
 		aadd(aTotLan,{aRetAcu[nInd][3],aRetAcu[nInd][24],aRetAcu[nInd][5],aRetAcu[nInd][25]})
 	Else
 		aTotLan[nAux][2] += aRetAcu[nInd][24]
 		aTotLan[nAux][4] += aRetAcu[nInd][25]
   EndIf
Next

For nInd := 1 to Len(aTotLan)
	cDado := "["+aTotLan[nInd][1]+"] - " + aTotLan[nInd][3]
	aadd(aDados,{cDado,;
				 AllTrim(Transform(aTotLan[nInd][2],"@R 999,999.99")),;
				 AllTrim(Transform(aTotLan[nInd][4],"@R 999,999.99")) })
Next

If !lAutomato

	@ (aPosObj[1][3]/2.5)+25, aPosObj[1][2]+2 GROUP oGrupo TO aPosObj[1][3]-20, 195 PIXEL OF oFolder:aDialogs[1] LABEL STR0052 COLOR CLR_HBLUE, CLR_HRED //"Acumulado"
	oBrwRDS := TcBrowse():New((aPosObj[1][3]/2.5)+35, aPosObj[1][2]+8, 180, 80,,,, oFolder:aDialogs[1],,,,,,,,,,,, .F.,, .T.,, .F., )
		oBrwRDS:AddColumn(TcColumn():New(STR0025,{|| aDados[oBrwRDS:nAt,1]},"@!",nil,nil,nil,75,.F.,.F.,nil,nil,nil,.F.,nil)) //"Tipo Lancamento"
		oBrwRDS:AddColumn(TcColumn():New(STR0026,{|| aDados[oBrwRDS:nAt,2]},"@!",nil,nil,nil,32,.F.,.F.,nil,nil,nil,.F.,nil))   //"Saldo 1"
		oBrwRDS:AddColumn(TcColumn():New(STR0027,{|| aDados[oBrwRDS:nAt,3]},"@!",nil,nil,nil,32,.F.,.F.,nil,nil,nil,.F.,nil))   //"Saldo 2"
	oBrwRDS:SetArray(aDados)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta autogestao jah faturados...                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(oFolder:aDialogs) >= 2
		aDadosAut  := {}
		aTotLanAut :={}
		For nInd := 1 to Len(aRetAcF)
			If aRetAcF[nInd][24] > 0 .or. aRetAcF[nInd][25] >0
				If (nAux := aScan(aTotLanAut, {|x| x[1] == aRetAcF[nInd][3]})) == 0
					aadd(aTotLanAut,{aRetAcF[nInd][3],aRetAcF[nInd][24],aRetAcF[nInd][5],aRetAcF[nInd][25]})
				Else
					aTotLanAut[nAux][2] += aRetAcF[nInd][24]
					aTotLanAut[nAux][4] += aRetAcF[nInd][25]
			EndIf
			EndIf
		Next

		For nInd := 1 to Len(aTotLanAut)
			cDado := "["+aTotLanAut[nInd][1]+"] - " + aTotLanAut[nInd][3]
			aadd(aDadosAut,{cDado,;
						AllTrim(Transform(aTotLanAut[nInd][2],"@R 999,999.99")),;
						AllTrim(Transform(aTotLanAut[nInd][4],"@R 999,999.99")) })
		Next

		@ (aPosObj[1][3]/2.5)+25, aPosObj[1][2]+2 GROUP oGrupo TO aPosObj[1][3]-20, 195 PIXEL OF oFolder:aDialogs[2] LABEL STR0052 COLOR CLR_HBLUE, CLR_HRED //"Acumulado"
		oBrwRDF := TcBrowse():New( (aPosObj[1][3]/2.5)+35, aPosObj[1][2]+8, 180, 80,,,, oFolder:aDialogs[2],,,,,,,,,,,, .F.,, .T.,, .F., )
		oBrwRDF:AddColumn(TcColumn():New(STR0025,{|| aDadosAut[oBrwRDF:nAt,1]},"@!",nil,nil,nil,75,.F.,.F.,nil,nil,nil,.F.,nil)) //"Tipo Lancamento"
		oBrwRDF:AddColumn(TcColumn():New(STR0026,{|| aDadosAut[oBrwRDF:nAt,2]},"@!",nil,nil,nil,25,.F.,.F.,nil,nil,nil,.F.,nil))   //"Saldo 1"
		oBrwRDF:AddColumn(TcColumn():New(STR0027,{|| aDadosAut[oBrwRDF:nAt,3]},"@!",nil,nil,nil,25,.F.,.F.,nil,nil,nil,.F.,nil))   //"Saldo 2"
		oBrwRDF:SetArray(aDadosAut)
EndIf

EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto tree...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutomato
    oTree := DbTree():New(aPosObj[1][1]+15,aPosObj[1][2]+2,(aPosObj[1][3]/2.5)+20,aPosObj[1][4]-10,oFolder:aDialogs[1],nil,nil,.T.,nil)
    oTree:BuildTrb(400, 2)
    oTree:BeginUpdate()
    oTree:SetEnable()
    oTree:oFont := oFont
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados da composicao de cobranca...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aValor[2]) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena por ordem de usuario + tipo de lancamento...                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet := aSort(aValor[2],,, { |x, y| x[7]+x[19] < y[7]+y[19] })

	For nInd := 1 To Len(aValor[2])
		If aValor[2,nInd,2] = 0
			Loop
		EndIf

		cQuebra := aValor[2,nInd, 7]
        If !lAutomato
		    oTree:AddTree(Space(01)+TransForm(aValor[2,nInd,7],__cPictUsr)+"   "+aValor[2,nInd,8]+Space(100),Nil,"BMPUSER","BMPUSER",nil,nil,"")
        EndIF
		nValUsr := 0

		For nAux := nInd To Len(aValor[2])
			If aValor[2,nAux,2] = 0
				Loop
			EndIf

			If cQuebra <> aValor[2,nAux,7]
				Exit
			Else
				IF aValor[2,nAux,1] == '1'
					cBmp := "BR_VERDE_OCEAN"
					nValUsr += aValor[2,nAux,2]
				Else
					cBmp := "BR_VERMELHO_OCEAN"
					nValUsr -= aValor[2,nAux,2]

				EndIf

				cLastCargo := StrZero(Val(cLastCargo)+1,2)
				lValT1   := .T.

				If Empty(aValor[2,nAux,4])
					cTexto := aValor[2,nAux,5]
				Else
					cTexto := " (" + aValor[2,nAux,3] + ") - " + Substr(Upper(aValor[2,nAux,5]),1,25) + " - [" + Space(4-Len(aValor[2,nAux,4]))+aValor[2,nAux,4] + "]"
				EndIf

				If (aValor[2,nAux,3] $ '118, 146' .or. aValor[2,nAux,4] $ '118, 146')
					cTexto += " - Ret"
				Else
					cTexto += " - " + Space(03)
				EndIf

				cTexto += "- "
				cTexto += TransForm(aValor[2,nAux,2],PLSVALOR)

				If lGerNFBRA
				   cTexto += " ["+aValor[2,nAux,37]+"] ["+aValor[2,nAux,38]+"]"
				EndIf

				If !Empty(aValor[2,nAux,6])
					cTexto += " - " + aValor[2,nAux,6]
				EndIf
                If !lAutomato
				    oTree:AddTreeItem(cTexto,cBmp,cBmp,cLastCargo)
				    oTree:TreeSeek(cLastCargo)
                EndIF
			EndIf
		Next
		If nValUsr > 0
			cLastCargo := StrZero(Val(cLastCargo)+1,2)
            If !lAutomato
			    oTree:AddTreeItem(STR0018 + " - "+TransForm(nValUsr,PLSVALOR),"BR_AZUL_OCEAN","BR_AZUL_OCEAN",cLastCargo) //"Total do usuário"
			    oTree:TreeSeek(cLastCargo)
            EndIF
			lValT1     := .T.
		EndIf
        If !lAutomato
		    oTree:EndTree()
        EndIf
		nInd := nAux-1
	Next
    If !lAutomato
	    oTree:EndUpdate()
    EndIF
Else
    If !lAutomato
	    oTree:EndTree()
	    PLSSAYESP(050,015,{ || STR0053},; //"Nao ha lancamentos a faturar nesta competencia"
				    150,;
				    006,;
				    oTree,;
				    AdvFont,;
				    CLR_HBLUE,;
				    "oSay")
    EndIF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta totalizadores...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutomato

	@ (aPosObj[1][3]/2.5)+71, 345 GROUP oGrupo TO (aPosObj[1][3]/2.5)+92, 390 PIXEL OF oFolder:aDialogs[1] LABEL STR0029 COLOR CLR_HBLUE, CLR_HRED //" Creditos "
		PLSSAYESP((aPosObj[1][3]/2.5)+82,345,{ || TransForm(nTotCre,PLSVALOR)},;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	@ (aPosObj[1][3]/2.5)+71, 395 GROUP oGrupo TO (aPosObj[1][3]/2.5)+92, 440 PIXEL OF oFolder:aDialogs[1] LABEL STR0030  COLOR CLR_HBLUE, CLR_HRED //" Debitos "
		PLSSAYESP((aPosObj[1][3]/2.5)+82,395,{ || TransForm(nTotDeb,PLSVALOR)},;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	@ (aPosObj[1][3]/2.5)+95, 345 GROUP oGrupo TO (aPosObj[1][3]/2.5)+117, 390 PIXEL OF oFolder:aDialogs[1] LABEL STR0076 COLOR CLR_HBLUE, CLR_HRED //" Cred Patronal "
		PLSSAYESP((aPosObj[1][3]/2.5)+107,345,{ || TransForm(nTotPatCd1,PLSVALOR)},;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	@ (aPosObj[1][3]/2.5)+95, 395 GROUP oGrupo TO (aPosObj[1][3]/2.5)+117, 440 PIXEL OF oFolder:aDialogs[1] LABEL STR0077  COLOR CLR_HBLUE, CLR_HRED //" Deb Patronal "
		PLSSAYESP((aPosObj[1][3]/2.5)+107,395,{ || TransForm(nTotPatDb1,PLSVALOR)},;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	@ (aPosObj[1][3]/2.5)+71, 445 GROUP oGrupo TO (aPosObj[1][3]/2.5)+92, 490 PIXEL OF oFolder:aDialogs[1] LABEL STR0078  COLOR CLR_HBLUE, CLR_HBLUE //" Tot Familia "
		PLSSAYESP((aPosObj[1][3]/2.5)+82,435,{ || TransForm(nTotFam,PLSVALOR)+" - ("+cTipo+")"  },;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	@ (aPosObj[1][3]/2.5)+95, 445 GROUP oGrupo TO (aPosObj[1][3]/2.5)+117, 490 PIXEL OF oFolder:aDialogs[1] LABEL STR0079  COLOR CLR_HBLUE, CLR_HBLUE //" Tot Patronal "
		PLSSAYESP((aPosObj[1][3]/2.5)+107,435,{ || TransForm(nTotPat,PLSVALOR)+" - ("+cTipo+")"  },;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")

	@ (aPosObj[1][3]/2.5)+95, 495 GROUP oGrupo TO (aPosObj[1][3]/2.5)+117, 540 PIXEL OF oFolder:aDialogs[1] LABEL STR0031  COLOR CLR_HBLUE, CLR_HBLUE //" TITULO "
		PLSSAYESP((aPosObj[1][3]/2.5)+107,485,{ || TransForm(nTotal,PLSVALOR)+" - ("+cTipo+")"  },;
					150,;
					006,;
					oFolder:aDialogs[1],;
					AdvFont,;
					CLR_HBLUE,;
					"oSay")
EndIF                

// outra etapa!!
If Len(aJaFat[2]) > 0 .and. !lAutomato
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta says...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPosObj[1][1]+3,aPosObj[1][2]+2 BITMAP oBmp RESNAME "BR_VERDE_OCEAN" 		OF oFolder:aDialogs[2] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+17 Say oSay PROMPT STR0016 			  		SIZE 070,010 OF oFolder:aDialogs[2] PIXEL //"Débito"

	@ aPosObj[1][1]+3,aPosObj[1][2]+67 BITMAP oBmp RESNAME "BR_VERMELHO_OCEAN"		OF oFolder:aDialogs[2] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+77 Say oSay PROMPT STR0017 					SIZE 070,010 OF oFolder:aDialogs[2] PIXEL //"Crédito"

	@ aPosObj[1][1]+3,aPosObj[1][2]+127 BITMAP oBmp RESNAME "BR_AZUL_OCEAN"		OF oFolder:aDialogs[2] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+3,aPosObj[1][2]+137 Say oSay PROMPT STR0018 					SIZE 070,010 OF oFolder:aDialogs[2] PIXEL //"Total do usuário"

	@ (aPosObj[1][3]/2.5)+25, 200 GROUP oGrupo TO (aPosObj[1][3]/2.5)+51, 350 PIXEL OF oFolder:aDialogs[2] LABEL STR0019  COLOR CLR_HBLUE, CLR_HRED //" Operadora "
	PLSSAYESP((aPosObj[1][3]/2.5)+40,205,{ || cOperadora },;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	cEmpresa := TransForm(BA1->BA1_CODEMP,"!!!!")+ "  -  "+subs(BG9->BG9_DESCRI,1,36)
	@ (aPosObj[1][3]/2.5)+57, 200 GROUP oGrupo TO (aPosObj[1][3]/2.5)+81, 350 PIXEL OF oFolder:aDialogs[2] LABEL STR0020  COLOR CLR_HBLUE, CLR_HRED //" Grupo Empresa "
	PLSSAYESP((aPosObj[1][3]/2.5)+70,205,{ || cEmpresa },;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	cNumero := If(BG9->BG9_TIPO=="2", TransForm(BA1->BA1_CONEMP,"!!!!!!!!!!!!"), BA3->BA3_NUMCON)
	@ (aPosObj[1][3]/2.5)+85, 200 GROUP oGrupo TO (aPosObj[1][3]/2.5)+108, 255 PIXEL OF oFolder:aDialogs[2] LABEL If(BG9->BG9_TIPO=="2",STR0021,STR0022)  COLOR CLR_HBLUE, CLR_HRED //" Contrato Empresa "###"Numero Contrato"
	PLSSAYESP((aPosObj[1][3]/2.5)+98,205,{ || cNumero },;
				200,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	cSubCon 	:= If(BG9->BG9_TIPO=="2", TransForm(BA1->BA1_SUBCON,"!!!!!!!!!"), BA1->BA1_SUBCON)
	@ (aPosObj[1][3]/2.5)+85, 260 GROUP oGrupo TO (aPosObj[1][3]/2.5)+108, 300  PIXEL OF oFolder:aDialogs[2] LABEL STR0023  COLOR CLR_HBLUE, CLR_HRED //"Subcontrato"
	PLSSAYESP((aPosObj[1][3]/2.5)+98,265,{ || cSubCon },;
				200,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	cLblMatric := BA1->BA1_MATRIC
	@ (aPosObj[1][3]/2.5)+85, 305 GROUP oGrupo TO (aPosObj[1][3]/2.5)+108, 340 PIXEL OF oFolder:aDialogs[2] LABEL STR0024  COLOR CLR_HBLUE, CLR_HRED //" Matricula "
	PLSSAYESP((aPosObj[1][3]/2.5)+98,310,{ || cLblMatric },;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta objeto tree...                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTreeJaP := DbTree():New(aPosObj[1][1]+15,aPosObj[1][2]+2,(aPosObj[1][3]/2.5)+20,aPosObj[1][4]-10,oFolder:aDialogs[2],nil,nil,.T.,nil)
	oTreeJaP:BuildTrb(400, 2)
	oTreeJaP:BeginUpdate()
	oTreeJaP:SetEnable()
	oTreeJaP:oFont := 	oFont
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta dados da composicao de cobranca...                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nInd := 1 To Len(aJaFat[2])
		If aJaFat[2,nInd,2] = 0
			Loop
		EndIf

		cQuebra := aJaFat[2,nInd, 7]
		oTreeJaP:AddTree(TransForm(aJaFat[2,nInd,7],__cPictUsr)+"   "+aJaFat[2,nInd,8]+Space(100),Nil,"BMPGROUP","BMPGROUP",nil,nil,"")
		nValUsr := 0
		For nAux := nInd To Len(aJaFat[2])
			If aJaFat[2,nAux,2] = 0
				Loop
			EndIf

			If cQuebra <> aJaFat[2,nAux,7]
				Exit
			Else
				IF aJaFat[2,nAux,1] == '1'
					cBmp := "BR_VERDE_OCEAN"
					nValUsr += aJaFat[2,nAux,2]
				Else
					cBmp := "BR_VERMELHO_OCEAN"
					nValUsr -= aJaFat[2,nAux,2]

				EndIf

				cLastCargo := StrZero(Val(cLastCargo)+1,2)
				lValT2   := .T.

				If Empty(aJaFat[2,nAux,4])
					cTexto := aJaFat[2,nAux,5]
				Else
					cTexto := " (" + aJaFat[2,nAux,3]+") - " + Substr(Upper((aJaFat[2,nAux,5]+Space(25-Len(aJaFat[2,nAux,5])))),1,25) + " - [" + Space(04-Len(aJaFat[2,nAux,4]))+aJaFat[2,nAux,4]+"]"
				EndIf

				cTexto += " - " + Space(03)


				cTexto += " - "
				cTexto += TransForm(aJaFat[2,nAux,2],PLSVALOR)
				If lGerNFBRA
					cTexto += " ["+aJaFat[2,nAux,21]+"] ["+aJaFat[2,nAux,22]+"]"
				EndIf

				If ! Empty(aJaFat[2,nAux,6])
					cTexto += " - " + AllTrim(aJaFat[2,nAux,6])
				EndIf

				oTreeJaP:AddTreeItem(cTexto,cBmp,cBmp,cLastCargo)
				oTreeJaP:TreeSeek(cLastCargo)

			EndIf
		Next
		If nValUsr > 0
			cLastCargo := StrZero(Val(cLastCargo)+1,2)
			oTreeJaP:AddTreeItem(STR0018 + " - "+TransForm(nValUsr,PLSVALOR),"BR_AZUL_OCEAN","BR_AZUL_OCEAN",cLastCargo) //"Total do usuário"
			oTreeJaP:TreeSeek(cLastCargo)
			lValT2   := .T.
		EndIf

		oTreeJaP:EndTree()
		nInd := nAux-1
	Next
	oTreeJaP:EndUpdate()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o nomero do titulo...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ (aPosObj[1][3]/2.5)+57, 355 GROUP oGrupo TO (aPosObj[1][3]/2.5)+81, 415 PIXEL OF oFolder:aDialogs[2] LABEL STR0032 COLOR CLR_HBLUE, CLR_HRED //" Lote de Cobranca "
	PLSSAYESP((aPosObj[1][3]/2.5)+68,360,{ || Substr(cNumLot,5)},;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ (aPosObj[1][3]/2.5)+57, 422 GROUP oGrupo TO (aPosObj[1][3]/2.5)+81, 502 PIXEL OF oFolder:aDialogs[2] LABEL STR0033 COLOR CLR_HBLUE, CLR_HRED //" Titulo "
	PLSSAYESP((aPosObj[1][3]/2.5)+68,427,{ || cNumTit},;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta totalizadores...                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ (aPosObj[1][3]/2.5)+85, 345 GROUP oGrupo TO (aPosObj[1][3]/2.5)+108, 390 PIXEL OF oFolder:aDialogs[2] LABEL STR0029 COLOR CLR_HBLUE, CLR_HRED //" Creditos "
	PLSSAYESP((aPosObj[1][3]/2.5)+98,345,{ || TransForm(nTJaCre,PLSVALOR)},;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ (aPosObj[1][3]/2.5)+85, 395 GROUP oGrupo TO (aPosObj[1][3]/2.5)+108, 440 PIXEL OF oFolder:aDialogs[2] LABEL STR0030  COLOR CLR_HBLUE, CLR_HRED //" Debitos "
	PLSSAYESP((aPosObj[1][3]/2.5)+98,395,{ || TransForm(nTJaDeb,PLSVALOR)},;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ (aPosObj[1][3]/2.5)+110, 345 GROUP oGrupo TO (aPosObj[1][3]/2.5)+133, 390 PIXEL OF oFolder:aDialogs[2] LABEL " Cred Patronal " COLOR CLR_HBLUE, CLR_HRED
	PLSSAYESP((aPosObj[1][3]/2.5)+123,345,{ || TransForm(nTotPatCd2,PLSVALOR)},;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ (aPosObj[1][3]/2.5)+110, 395 GROUP oGrupo TO (aPosObj[1][3]/2.5)+133, 440 PIXEL OF oFolder:aDialogs[2] LABEL " Deb Patronal "  COLOR CLR_HBLUE, CLR_HRED
	PLSSAYESP((aPosObj[1][3]/2.5)+123,395,{ || TransForm(nTotPatDb1,PLSVALOR)},;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ (aPosObj[1][3]/2.5)+85, 445 GROUP oGrupo TO (aPosObj[1][3]/2.5)+108, 502 PIXEL OF oFolder:aDialogs[2] LABEL STR0031  COLOR CLR_HBLUE, CLR_HBLUE //" TOTAL "
	PLSSAYESP((aPosObj[1][3]/2.5)+98,445,{ || TransForm(nTotJa,PLSVALOR)+" - ("+cTipo+")"  },;
				150,;
				006,;
				oFolder:aDialogs[2],;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

EndIf

If ! lValT1 .And. ValType(oTree) == "O" .and. !lAutomato
   oTree:lVisible := .F.
EndIf

If ! lValT2 .And. ValType(oTreeJa) == "O" .and. !lAutomato
   oTreeJa:lVisible := .F.
EndIf

If  !lAutomato
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
		objCENFUNLGP:useLogUser()

	ACTIVATE DIALOG oDlg CENTERED ON INIT Eval( { || oTree:TreeSeek(cLastCargo), oTree:Refresh(), EnchoiceBar(oDlg,bOK,bOK,.F.,aButtons) } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura dados...                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SET KEY VK_F4 TO
	SET KEY VK_F5 TO
EndIF
Eval(bRest)
RestArea(aArea)

If lAutomato
    nValorRet := nValUsr
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSTAXAD   ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna se a taxa de adesao ja foi cobrada e respectivo vlr³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSTAXAD(cCodInt,cCodEmp,cMatric,cTipReg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lRet    := .F.
LOCAL aRet
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL nRecBA1 := BA1->(Recno())
LOCAL bRest   := { || BA1->(DbGoTo(nRecBA1)), BA1->(DbSetorder(nOrdBA1)) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona primeiro no usuario...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) <> xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg
   BA1->(DbSetOrder(2))
   BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg))
EndIf

lRet := ( BA1->BA1_CBTXAD == "1" )
aRet := {lRet,BA1->BA1_VLTXAD}

Eval(bRest)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSBUSFAI  ³ Autor ³ Tulio Cesar       ³ Data ³ 15.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Trata a forma de cobranca por faixa etaria                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Geraldo Jr. ³        ³      ³  Correcao do retorno do LTOTAL           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBUSFAI(cMatricFam,cAno,cMes,cForPag,aEventosCB,aCliente,aUsuarios,lDireto,lOnlyLook,cRdMake,aFoCoPF,aLanUsu,cNumCob,cReemb,lDatPagto,dDatPagto)
LOCAL i
LOCAL nCnt
LOCAL nFor
LOCAL nAux
LOCAL aRet 		:= {}
LOCAL aRetFun 	:= {}
LOCAL aRetOpc 	:= {}
LOCAL nValor2Via
LOCAL aValorRet
LOCAL cTipEve
LOCAL nValorEve
LOCAL cCodEve
LOCAL cCodEveOri
LOCAL cDesEveOri
LOCAL cCargo
LOCAL cMatUsu
LOCAL cNomUsr
LOCAL lTotal
LOCAL cSexo
LOCAL cGrauPa
LOCAL cFiller
LOCAL cCodFai
LOCAL cNivFai
LOCAL cTipUsu
LOCAL cAlias
LOCAL cOrigem
LOCAL cBaseIr
LOCAL nIdaIni    := 0
LOCAL nIdaFin    := 0
LOCAL cOpeFam    := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp    := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric    := Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL _cChave	 := ''
LOCAL lPulaPF    := .F.
LOCAL lByPassDC	 := .F.
LOCAL lFatura    := .F.
LOCAL lCusOpe    := .F.
LOCAL nSeq       := 0
LOCAL nVlrMes	 := 0
LOCAL cVerba	 := ""
LOCAL _cNivel 	 := ''
LOCAL nRecno	 := 0
LOCAL nSaldo1    := 0
LOCAL nSaldo2    := 0
LOCAL nTotSal	 := 0
LOCAL aRetAux	 := {}
LOCAL nValDes	 := 0
LOCAL nValAcre	 := 0
LOCAL cCodSeq	 := ''
LOCAL cAnoMesAnt := ""
LOCAL cTpPlan    := ""
LOCAL cTpForn    := ""
LOCAL cSeqDep    := ""
LOCAL cPlanGPE   := ""
Local cCodFor    := ""
Local cBanco	 := allTrim( TCGetDB() )
Local lPatroDif  := .f.
Local lDirf11 	 := .T. 
Local _cWhile	 := ''
Local aDadGPE  	 := {}
Local aEvAux     := {}
Local cOpPad 	 := PLSIntPad()
Local Ix		 := 0
Local nNumFor 	 := 0
Local cSql    	 := ""
Local cFunNa     := FunName()
Local nPosEve 	 := 0
Local ddatDe   	 := ctod('')
Local dDatAte	 := ctod('')
Local lExistUsr  := .F. 
Local lExistBFY  := .F. 
Local lExistBDQ  := .F.

DEFAULT aCliente  := {}
DEFAULT aUsuarios := {}
DEFAULT cRdMake   := "PLSPORFAI"
DEFAULT aFoCoPF	  := {"0","2"}
DEFAULT aLanUsu	  := {}
DEFAULT cNumCob	  := ""
DEFAULT cReemb    := "2" 
DEFAULT lDatPagto := .F.
DEFAULT dDatPagto := cTod("")

If cReemb == "0"
   cReemb := "2"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuario																³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aUsuarios) == 0

	aUsuarios  := PLSLOADUSR(cOpeFam,cCodEmp,cMatric,cAno,cMes,,lOnlyLook)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna caso nao encontre usuario valido na familia...              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aUsuarios) == 0
		Return(aRet)
	EndIf

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o nivel de cobranca e o cliente...		                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCliente) == 0
	aCliente := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,;
						  BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),;
						  BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
						  BA3->BA3_VERSUB,1)
EndIf

If Len(aCliente) > 0

	_cNivel := aCliente[1][18]

	If _cNivel == "1" // Empresa
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP
		_cWhile := "BBT->(BBT_CODOPE + BBT_CODEMP)"
	ElseIf _cNivel == "2" //Nivel contrato
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON
		_cWhile := "BBT->(BBT_CODOPE + BBT_CODEMP+BBT_CONEMP+BBT_VERCON)"
	ElseIf _cNivel == "3"  //Nivel subcontrato
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB
		_cWhile := "BBT->(BBT_CODOPE + BBT_CODEMP+BBT_CONEMP+BBT_VERCON+BBT_SUBCON+BBT_VERSUB)"
	ElseIf _cNivel == "4" //Nivel familia
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
		_cWhile := "BBT->(BBT_CODOPE + BBT_CODEMP+BBT_MATRIC)"
	ElseIf _cNivel == "5" //Usuario
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
		_cWhile := "BBT->(BBT_CODOPE + BBT_CODEMP+BBT_MATRIC)"
	EndIf

	//!lOnlyLook inserido, porque em casos de relatorio de valores, nao eh nescessario saber se   
	//ja foi faturado ou nao... quero saber somente o valor do usuario!

	If ! lOnlyLook

		//Verifica se houve faturas no mes... atualiza o valor do flag...     
	    If ! lPlsFimCb 

	    	//Verifica se ja foi rodada cobrança pra alguns dos níveis. 
	    	//Busco do mais específico para o mais genérico pois o beneficiario pode ter mudado o nivel
	    	//da cobrança no mesmo mes
			

			If  oPrepBM1 	== nil 			  

				cSql := " SELECT COUNT(1) CONTADOR  FROM "+RetSqlName("BM1")+" BM1 "
				
				cSql += " INNER JOIN "+RetSqlName("SE1")+" SE1 "
				cSql += "    ON E1_FILIAL  = '"+xFilial("SE1")+"' "
				cSql += "   AND E1_PREFIXO = BM1_PREFIX "
				cSql += "   AND E1_NUM     = BM1_NUMTIT "
				cSql += "   AND E1_PARCELA = BM1_PARCEL "
				cSql += "   AND E1_TIPO    = BM1_TIPTIT "
				cSql += "   AND E1_ORIGEM <> 'PLSA090' "

				// nao pode considerar NCC
				cSql += "   AND E1_TIPO    <> '" + MV_CRNEG + "' " 
				cSql += "   AND SE1.D_E_L_E_T_ = ' ' " 
			
				cSql += " LEFT JOIN "+RetSqlName("BDC")+" BDC "
				cSql += "   ON BDC_FILIAL = '" + xFilial("BDC") + "' "
				cSql += "  AND BDC_CODOPE = BM1_CODINT "
				//cSql += "  AND BDC_NUMERO = BM1_PLNUCO "
				
				If cBanco $ "ORACLE|DB2|POSTGRES|INFORMIX"
					cSql += "  AND BDC.BDC_CODOPE||BDC.BDC_NUMERO = BM1_PLNUCO "
				Else
					cSql += "  AND BDC.BDC_CODOPE+BDC.BDC_NUMERO = BM1_PLNUCO "
				EndIf

				cSql += "  AND BDC_REEMB <> '1' "
				cSql += "  AND BDC.D_E_L_E_T_ = ' ' "
			
				cSql += " WHERE BM1_FILIAL 	= '" + xFilial("BM1") + "' "
				cSql += " AND ((BM1_NIVCOB  = '5' "
				cSql += " AND BM1_CODINT 	= ?  "
				cSql += " AND BM1_CODEMP 	= ?  "
				cSql += " AND BM1_MATRIC 	= ? "
				cSql += " AND BM1_ANO   	= ? "
				cSql += " AND BM1_MES 		= ? ) "
			
				cSql += " OR (BM1_NIVCOB  = '4' "
				cSql += " AND BM1_CODINT = ?  "
				cSql += " AND BM1_CODEMP = ?  "
				cSql += " AND BM1_MATRIC = ?  "
				cSql += " AND BM1_ANO 	 =  ?  "
				cSql += " AND BM1_MES 	 = ? ) "
			
				cSql += " OR (BM1_NIVCOB  = '3' "
				cSql += " AND BM1_CODINT = ? "
				cSql += " AND BM1_CODEMP = ? "
				cSql += " AND BM1_CONEMP = ? "
				cSql += " AND BM1_VERCON = ? "
				cSql += " AND BM1_SUBCON = ? "
				cSql += " AND BM1_VERSUB = ? "
				cSql += " AND BM1_MATRIC = ? "
				cSql += " AND BM1_ANO 	 = ? "
				cSql += " AND BM1_MES 	 = ? ) "
			
				cSql += " OR (BM1_NIVCOB  = '2' "
				cSql += " AND BM1_CODINT = ?  "
				cSql += " AND BM1_CODEMP = ?  "
				cSql += " AND BM1_CONEMP = ?  "
				cSql += " AND BM1_VERCON = ?  "
				cSql += " AND BM1_MATRIC = ?  "
				cSql += " AND BM1_ANO 	 = ?  "
				cSql += " AND BM1_MES = ? ) "
			
				cSql += " OR (BM1_NIVCOB  	= '1' "
				cSql += " AND BM1_CODINT	= ?  "
				cSql += " AND BM1_CODEMP 	= ?  "
				cSql += " AND BM1_MATRIC 	= ?  "
				cSql += " AND BM1_ANO 		= ?  "
				cSql += " AND BM1_MES 		= ? ) ) "
			
				cSql += " AND ( BM1_PLNUCO <> ' ' "
				If GetNewPar("MV_PLSNFBR","0")=="1"
					cSql += " OR ( BM1_PLNUCO = ' ' AND BM1_PREFIX <> '"+GetNewPar("MV_PLSPRCP","CPP") +"')) "
				Else 
					cSql += " )"	
				EndIf
				cSql += " AND BM1.D_E_L_E_T_ = ' ' "	    

				oPrepBM1 :=FWPreparedStatement():New(cSQL)
		
			Endif	

			
			nParamLin:=1
			oPrepBM1:SetString(nParamLin,BA3->BA3_CODINT)
			nParamLin++
			oPrepBM1:SetString(nParamLin,BA3->BA3_CODEMP)
			nParamLin++
			oPrepBM1:SetString(nParamLin,BA3->BA3_MATRIC )
			nParamLin++
			oPrepBM1:SetString(nParamLin,cAno )
			nParamLin++
			oPrepBM1:SetString(nParamLin,cMes )
		
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_CODINT )
			nParamLin++
			oPrepBM1:SetString(nParamLin,BA3->BA3_CODEMP )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_MATRIC )
			nParamLin++
			oPrepBM1:SetString(nParamLin,cAno )
			nParamLin++
			oPrepBM1:SetString(nParamLin, cMes )
		
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_CODINT )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_CODEMP )
			nParamLin++
			oPrepBM1:SetString(nParamLin,BA3->BA3_CONEMP )
			nParamLin++
			oPrepBM1:SetString(nParamLin,BA3->BA3_VERCON )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_SUBCON )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_VERSUB )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_MATRIC )
			nParamLin++
			oPrepBM1:SetString(nParamLin,cAno )
			nParamLin++
			oPrepBM1:SetString(nParamLin, cMes )

			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_CODINT )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_CODEMP )
			nParamLin++
			oPrepBM1:SetString(nParamLin,BA3->BA3_CONEMP )
			nParamLin++
			oPrepBM1:SetString(nParamLin,BA3->BA3_VERCON )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_MATRIC )
			nParamLin++
			oPrepBM1:SetString(nParamLin,cAno )
			nParamLin++
			oPrepBM1:SetString(nParamLin, cMes )

			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_CODINT )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_CODEMP )
			nParamLin++
			oPrepBM1:SetString(nParamLin, BA3->BA3_MATRIC )
			nParamLin++
			oPrepBM1:SetString(nParamLin,cAno )
			nParamLin++
			oPrepBM1:SetString(nParamLin, cMes )


			cSQL 	:= oPrepBM1:GetFixQuery()
			BM1TMP 	:= MpSysOpenQuery(cSQL)

	    	lFatura := IIF( ( (BM1TMP)->CONTADOR > 0 ) , .t., .f.)
	    	(BM1TMP)->(DbCloseArea())
	    
	    Else
	       lFatura := execBlock( "PLSFTMCB", .f., .f., { _cNivel, _cChave, cAno, cMes } )
	    EndIf

	EndIf

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa um for para todos os eventos que devem ser calculados...    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEvAux := aClone(aEventosCB)

For nFor := 1 To Len(aEventosCB)

 	ddatDe  := Ctod("")
 	dDatAte := Ctod("")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os codigos definidos em cCodigosPF so sao processados uma unica vez ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if empty(aEventosCB[nFor,1]) .or. (aEventosCB[nFor,1] $ cCodigosPF .and. lPulaPF)
		loop
	endIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os codigos definidos em cCodDB so sao processados uma unica vez 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if aEventosCB[nFor,1] $ cCodDB	.and. lByPassDC
		loop
	endIf

	lPatroDif := .f. //Patronal diferenciado (Acordo ANS CApesesp)

	//Mensalidade...                                                      
	if aEventosCB[nFor,1] == "101" .and. (! lFatura .Or. aEventosCB[nFor,5] $ '2')   .and. cReemb <> "1"
		
		If !CheckFatMensal(cMatricFam, cAno, cMes, "101")
			
			aRetFun := PLSVLRFAI(cMatricFam,cAno,cMes,cForPag,aUsuarios,lOnlyLook,_cNivel,_cChave,nil,nil,@lExistUsr,@lExistBFY,@lExistBDQ)
		
			For nAux := 1 To Len(aRetFun)

				cCodEve := Iif(aRetFun[nAux,24] $ "191/189",aRetFun[nAux,24],aEventosCB[nFor,1]) //Codigo do Lancamento
				npos    := Ascan(aEventosCB,{|X| X[1] == cCodeve})
				If npos > 0
					cTipEve    := aEventosCB[npos,3] //Debito/Credito
				Else
					cTipEve    := aEventosCB[nFor,3] //Debito/Credito
				EndIf

				nValorEve  := aRetFun[nAux,2]
				
				If !(aRetFun[nAux,24] $ "191/189")
					cCodEveOri := aRetFun[nAux,11]
					cDesEveOri := aRetFun[nAux,12]
				Else
					If npos > 0
						cCodEveOri := aEventosCB[npos,1]
						cDesEveOri := aEventosCB[npos,2]
					Else
						cCodEveOri := aEventosCB[nFor,1]
						cDesEveOri := aEventosCB[nFor,2]
					EndIf
				EndIf            

				If aRetFun[nAux,13] == 0
					cCargo := aRetFun[nAux,3]
				Else
					cCargo := STR0034+Str(aRetFun[nAux,14],2)+STR0035 //"Cobranca Pro-Rata de "###" Dia(s)"
				EndIf

				cMatUsu    := aRetFun[nAux,1]
				cNomUsr    := aRetFun[nAux,4]
				lTotal     := .F.
				cSexo      := aRetFun[nAux,5]
				cGrauPa    := aRetFun[nAux,6]
				cFiller    := ""
				cCodFai    := aRetFun[nAux,8]
				cNivFai    := aRetFun[nAux,9]
				cTipUsu    := aRetFun[nAux,10]
				cAlias     := ""
				cOrigem    := ""
				cBaseIr    := aEventosCB[nFor,4]
				nIdaIni    := aRetFun[nAux,15]
				nIdaFin    := aRetFun[nAux,16]
				nVlrMes    := nValorEve
				nSaldo1    := 0
				nSaldo2    := 0
				nTotSal    := 0
				nRecno     := 0
				nValDes	   := aRetFun[nAux,17]
				nValAcre   := aRetFun[nAux,18]
				cCodSeq	   := ''
				If Len(aRetFun[nAux]) > 18
					cCompRea	:= aRetFun[nAux,19]
					nValAtual	:= aRetFun[nAux,20]
					nValAnter	:= aRetFun[nAux,21]
				EndIf
				cCodPla := aRetFun[nAux,11]
				cVerPla := aRetFun[nAux,22]
				cDesPla := aRetFun[nAux,12]
				cCodSB1 := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
				cCodTES := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
				cTpForn  := aRetFun[nAux,23]

				npos := Ascan(aEventosCB,{|X| X[1] == cCodeve})

				If npos > 0
					cVerba := if(len(aEventosCB[npos]) >= 18,aEventosCB[npos,18],"")
				Else
					PLSCRIABFQ()
					cVerba := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")
				EndIf

				If lDirf11 

					aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
					
					If Len(aDadGPE)>0

						cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )

						cTpPlan  := aDadGPE[2]
						cCodFor  := aDadGPE[3]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]

					Endif

				Endif

				If lPLSINTFOL

					aDadGpe := Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
					
					If Len(aDadGpe)>0

						cVerba	 := aDadgpe[1]
						cTpPlan  := aDadGPE[2]
						cCodFor  := aDadGPE[3]
						cTpForn  := aDadGPE[6]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]

					Endif

				Endif
				
				If Len(aRetFun[nAux]) > 24
					dDatDe :=aRetFun[nAux,25]
					dDatAte:=aRetFun[nAux,26]
				endif

				PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
							cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
							lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

			Next
		EndIf
	//Opcionais ...                                                       
	ElseIf aEventosCB[nFor,1] == "102" .And. ( ! lFatura .or. aEventosCB[nFor,5] $ '1' ) .and. cReemb <> "1"
		
		aRetOpc := PLSVALOPC(cMatricFam,cAno,cMes,aUsuarios,cRdMake,lOnlyLook,_cNivel,_cChave,aEventosCB[nFor,3],aEventosCB[nFor,1])

		For nAux := 1 To Len(aRetOpc)

			cTipEve    := aRetOpc[nAux,26] //Debito/Credito
			cCodEve    := aRetOpc[nAux,27] //Codigo do Lancamento

			nValorEve  := aRetOpc[nAux,2]
	        cCodEveOri := aRetOpc[nAux,11] //Produto PLS - Opcional
			cDesEveOri := aRetOpc[nAux,12] //Descricao do Produto

			If aRetOpc[nAux,15] == 0
			   cCargo := aRetOpc[nAux,3]
			Else
			   cCargo := STR0034+Str(aRetOpc[nAux,16],2)+STR0035 //"Cobranca Pro-Rata de "###" Dia(s)"
			EndIf

			If lPLSOPCRG
				cCargo := ExecBlock("PLSOPCRG", .F., .f., {cCargo,aRetOpc[nAux]})
			EndIf

			cMatUsu    	:= aRetOpc[nAux,1]
			cNomUsr    	:= aRetOpc[nAux,4]
			lTotal     	:= .F.
			cSexo      	:= aRetOpc[nAux,5]
			cGrauPa    	:= aRetOpc[nAux,6]
			cFiller    	:= ""
			cCodFai    	:= aRetOpc[nAux,8]
			cNivFai    	:= aRetOpc[nAux,9]
			cTipUsu    	:= aRetOpc[nAux,10]
			cAlias     	:= ""
			cOrigem    	:= ""
			cBaseIr    	:= aEventosCB[nFor,4]
			nIdaIni    	:= aRetOpc[nAux,13]
			nIdaFin    	:= aRetOpc[nAux,14]
			nVlrMes    	:= nValorEve
			nSaldo1    	:= 0
			nSaldo2    	:= 0
			nTotSal    	:= 0
			nRecno     	:= 0
			nValDes	   	:= aRetOpc[nAux,19]
			nValAcre   	:= 0
			cCodSeq	   	:= ''
			cCompRea	:= aRetOpc[nAux,23]
			nValAtual	:= aRetOpc[nAux,24]
			nValAnter	:= aRetOpc[nAux,25]
			cCodPla 	:= aRetOpc[nAux,20]
			cDesPla 	:= aRetOpc[nAux,21]
			cVerPla 	:= aRetOpc[nAux,22]
			cCodSB1 	:= MontaSB1(aEventosCB,nFor,cCodEve,cCodEveOri,cOpeFam,cMatUsu,_cNivel)
			cCodTES 	:= MontaTES(aEventosCB,nFor,cCodSB1,cCodEveOri,cCodEve,cOpeFam,cMatUsu,_cNivel)
			cTpForn     := aRetOpc[nAux,29]
			cVerba      := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")

			if lDirf11

				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif

			If lPLSINTFOL
				aDadGpe := Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba   := aDadGPE[1]
					cTpPlan  := aDadGPE[2]
					cCodFor  := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif
			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)


		Next
	//Taxa de Inscricao/Adesao...                                         
	ElseIf (aEventosCB[nFor,1] == "103" .And. (! lFatura .Or. aEventosCB[nFor,5] $ '1') .and. cReemb <> "1") .or. (BA3->BA3_TXUSU = "1" .and. aEventosCB[nFor,1] == "103" .And. cFunNa == "PLSA174" .and. cReemb <> "1")
		
		aRetFun := PLSVALADE(cMatricFam,cAno,cMes,aUsuarios,aRet,lOnlyLook)

		For nAux := 1 To Len(aRetFun)

			cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

			nValorEve  := aRetFun[nAux,2]
			cCodEveOri := aEventosCB[nFor,1] //Codigo do Lancamento
			cDesEveOri := aEventosCB[nFor,2] //Descricao do Lancamento

			cCargo     := aRetFun[nAux,3]
			cMatUsu    := aRetFun[nAux,1]
			cNomUsr    := aRetFun[nAux,4]
			lTotal     := .F.
			cSexo      := aRetFun[nAux,5]
			cGrauPa    := aRetFun[nAux,6]
			cFiller    := ""
			cCodFai    := aRetFun[nAux,8]
			cNivFai    := aRetFun[nAux,9]
			cTipUsu    := aRetFun[nAux,10]
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := aEventosCB[nFor,4]
			nIdaIni    := aRetFun[nAux][13]
			nIdaFin    := aRetFun[nAux][14]
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := aRetFun[nAux][15]
			nValAcre   := aRetFun[nAux][16]
			cCodSeq	   := ''
			cCompRea	:= ''
			nValAtual	:= 0
			nValAnter	:= 0
			cCodPla		:= aRetFun[nAux][11]
			cDesPla		:= aRetFun[nAux][12]
			cVerPla		:= aRetFun[nAux][17]
			cCodSB1 	:= MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES 	:= MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
			cTpForn  	:= if(len(aRetFun[nAux]	) >= 18, aRetFun[nAux,18],"")
	        cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")

			if lDirf11
				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif

			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif


			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

		Next
	//Custo operacional, taxa admnistrativa, fator modedador, etc         
	//Somente para estes lancamentos que tera retorno do BDH			    
	ElseIf aEventosCB[nFor,1] $ cCodigosPF .and. ( ! lFatura .Or. aEventosCB[nFor,5] $ '1' ) .and. cReemb <> "1"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ cAnoMesAnt															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PLCOBDAT")
			cAnoMesAnt := ExecBlock("PLCOBDAT", .F., .F., {cAno, cMes})
		ElseIf aFoCoPF[1] == "1"
			cAnoMesAnt := cAno+cMes
		Else
			cAnoMesAnt := PLSDIMAM(cAno,cMes,"0")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apura a participacao financeira do usuario...                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !CheckFatMensal(cMatricFam, Subs(cAnoMesAnt,1,4), Subs(cAnoMesAnt,5,2),  aEventosCB[nFor,1])
			aRetAux	:= PLSVLRPF(cMatricFam,Subs(cAnoMesAnt,1,4),Subs(cAnoMesAnt,5,2),aUsuarios,aEventosCB)
			aRetFun	:= aClone(aRetAux[1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena os numeros de registros para marcar como faturada ao logo do processo...  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lPulaPF    := .T.
			For nAux := 1 To Len(aRetFun)

				cTipEve    	:= aRetFun[nAux,3] //Debito/Credito
				cCodEve    	:= aRetFun[nAux,1] //Codigo do Lancamento

				nValorEve  	:= aRetFun[nAux,5]
				cCodEveOri 	:= aRetFun[nAux,1] //Codigo do Lancamento
				cDesEveOri 	:= aRetFun[nAux,2] //Descricao do Lancamento

				cCargo     	:= ""
				cMatUsu    	:= aRetFun[nAux,6]
				cNomUsr    	:= aRetFun[nAux,7]
				lTotal     	:= .F.
				cSexo      	:= ""
				cGrauPa    	:= ""
				cFiller    	:= ""
				cCodFai    	:= ""
				cNivFai    	:= ""
				cTipUsu    	:= aRetFun[nAux,12]
				cAlias     	:= ""
				cOrigem    	:= ""
				cBaseIr    	:= aEventosCB[nFor,4]
				nIdaIni    	:= 0
				nIdaFin    	:= 0
				nVlrMes    	:= nValorEve
				nSaldo1    	:= 0
				nSaldo2    	:= 0
				nTotSal    	:= 0
				nRecno     	:= aRetFun[nAux,11]
				nValDes	   	:= 0
				nValAcre   	:= 0
				cCodSeq	   	:= ''
				cCompRea	:= ''
				nValAtual	:= 0
				nValAnter	:= 0
				cCodPla 	:= aRetFun[nAux,08]
				cDesPla 	:= aRetFun[nAux,09]
				cVerPla	 	:= aRetFun[nAux,10]
				cCodSB1 	:= MontaSB1(aEventosCB,nFor,cCodEve,cCodPla,cOpeFam,cMatUsu,_cNivel)
				cCodTES 	:= MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
				cTpForn  := aRetFun[nAux,13]

				BFQ->(DbSetorder(1))
				BFQ->(DbSeek(Xfilial("BFQ")+cOpPad+cCodEve))

				//npos:=Ascan(aEvAux,{|x| Alltrim(x[1]) == Alltrim(cCodeve)})

				cVerba     := BFQ->BFQ_VERBA
				if lDirf11
					aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
					If Len(aDadGPE)>0
						cVerba:= If(BFQ->BFQ_TPLAN <>'1',cVerba,aDadGPE[1] )
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]
					Endif
				Endif

				If lPLSINTFOL
					aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
					If Len(aDadGpe)>0
						cVerba:=aDadgpe[1]
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cTpForn  := aDadGPE[6]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]

					Endif
				Endif

				PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
							cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
							lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)
			Next
		Endif	
	//Valor da via de carteirinha...                                      
	ElseIf aEventosCB[nFor,1] == "107" .and. ( ! lFatura .or. aEventosCB[nFor,5] $ '1' )  .and. cReemb <> "1"
		
		For nCnt := 1 To Len(aUsuarios)
	 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se pode cobrar o opcional    do usuario.. vai existir casos³
			//³ em que so podera ser cobrado o fator moderador / custo do usuario.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !aUsuarios[nCnt][25]
				Loop
			EndIf

			aValor2Via := PLSVLRCIDU(aUsuarios[nCnt,13])

			If len(aValor2Via)> 0 .And. Len(aUsuarios) > 0
				For nAux:=1 to len(aValor2Via)
				
					nPosEve:= Ascan(aEventosCB,{|x| AllTrim(x[1]) == aValor2Via[nAux,1]})
					
					cTipEve    := aEventosCB[nPosEve,3] //Debito/Credito
					cCodEve    := aValor2Via[nAux,1] //Codigo do Lancamento

					nValorEve  := aValor2Via[nAux,2]
					cCodEveOri := aEventosCB[nPosEve,1] //Codigo do Lancamento
					cDesEveOri := aEventosCB[nPosEve,2] //Descricao do Lancamento

					cCargo     := ""
					cMatUsu    := aUsuarios[nCnt,13] //como e por familia, pego o primeiro usuario
					cNomUsr    := aUsuarios[nCnt,3]  //como e por familia, pego o primeiro usuario
					lTotal     := .F.
					cSexo      := ""
					cGrauPa    := ""
					cFiller    := ""
					cCodFai    := ""
					cNivFai    := ""
					cTipUsu    := aUsuarios[nCnt,7]
					cAlias     := ""
					cOrigem    := ""
					cBaseIr    := ""
					nIdaIni    := 0
					nIdaFin    := 0
					nVlrMes    := nValorEve
					nSaldo1    := 0
					nSaldo2    := 0
					nTotSal    := 0
					nRecno     := 0
					nValDes	   := 0
					nValAcre   := 0
					cCodSeq	   := ''
					cCompRea   := ''
					nValAtual  := 0
					nValAnter  := 0
					cCodPla	   := aUsuarios[nCnt,08]
					cDesPla	   := aUsuarios[nCnt,09]
					cVerPla	   := aUsuarios[nCnt,29]
					cCodSB1    := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
					cCodTES    := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
					cTpForn  := aUsuarios[nCnt,31]

					cVerba     := if(len(aEventosCB[nPosEve]) >= 18,aEventosCB[nPosEve,18],"")

					If lDirf11
						aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
						If Len(aDadGPE)>0
							cVerba:= If(aEventosCB[nPosEve,25] <>'1',cVerba,aDadGPE[1] )
							cTpPlan := aDadGPE[2]
							cCodFor := aDadGPE[3]
							cSeqDep  := aDadGPE[4]
							cPlanGPE := aDadGPE[5]
						Endif
					Endif



					If lPLSINTFOL
						aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
						If Len(aDadGpe)>0
							cVerba:=aDadgpe[1]
							cTpPlan := aDadGPE[2]
							cCodFor := aDadGPE[3]
							cTpForn  := aDadGPE[6]
							cSeqDep  := aDadGPE[4]
							cPlanGPE := aDadGPE[5]

						Endif
					Endif

					PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

				Next
			EndIf
		Next
	//Reembolso livre escolha	...                                   		
	ElseIf aEventosCB[nFor,1] == "108" .and. ! lFatura .and. cReemb <> "0"

		aRetFun := PLSVLREMB(aUsuarios,cAno,cMes,cReemb,lDatPagto,dDatPagto)

		For i:=1 to len(aRetFun)

			cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

			nValorEve  := aRetFun[i,1]
			cCodEveOri := aEventosCB[nFor,1] //Codigo do Lancamento
			cDesEveOri := aEventosCB[nFor,2] //Descricao do Lancamento

			cCargo     := ""
			cMatUsu    := aRetFun[i,2]
			cNomUsr    := aRetFun[i,3]
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := ""
			cNivFai    := ""
			cTipUsu    := aRetFun[i,7]
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := ""
			nIdaIni    := 0
			nIdaFin    := 0
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := 0
			nValAcre   := 0
			cCodSeq	   := ''
			cCompRea   := ''
			nValAtual  := 0
			nValAnter  := 0
			cCodPla    := aRetFun[i,4]
			cDesPla    := aRetFun[i,5]
			cVerPla    := aRetFun[i,6]
			cCodSB1    := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES    := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
			cTpForn  	:= aRetFun[i,8]
	        cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")


			If lDirf11
				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif


			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif
			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

		Next
	//Valor da segunda via de boleto...                                   
	ElseIf aEventosCB[nFor,1] == "109" .and. ( ! lFatura .or. aEventosCB[nFor,5] $ '1' )  .and. cReemb <> "1"

		nValor2Via := PLSVLRCVBL(cMatricFam)

		If nValor2Via > 0 .And. Len(aUsuarios) > 0

			cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

			nValorEve  := nValor2Via
			cCodEveOri := aEventosCB[nFor,3] //Codigo do Lancamento
			cDesEveOri := aEventosCB[nFor,2] //Descricao do Lancamento

			cCargo     := ""
			cMatUsu    := aUsuarios[1,13] //como e por familia, pego o primeiro usuario
			cNomUsr    := aUsuarios[1,3]  //como e por familia, pego o primeiro usuario
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := ""
			cNivFai    := ""
			cTipUsu    := aUsuarios[1,7]
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := ""
			nIdaIni    := 0
			nIdaFin    := 0
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],'')
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := 0
			nValAcre   := 0
			cCodSeq	   := ''
			cCompRea   := ''
			nValAtual  := 0
 			nValAnter  := 0
 			cTpForn  := aUsuarios[1,31]
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")

			If lDirf11
				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif


 			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif

			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

		EndIf
	//Valor do agravo...
	ElseIf aEventosCB[nFor,1] == "110" .and. ( ! lFatura .or. aEventosCB[nFor,5] $ '1' ) .and. cReemb <> "1"
		
		aRetFun := PLSRETAGR(cMatricFam,cAno,cMes,aUsuarios,aRet)

		For nAux := 1 To Len(aRetFun)

			cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

			nValorEve  := aRetFun[nAux,1]
			cCodEveOri := aEventosCB[nFor,3] //Codigo do Lancamento
			cDesEveOri := aEventosCB[nFor,2] //Descricao do Lancamento

			cCargo     := ""
			cMatUsu    := aRetFun[nAux,2]
			cNomUsr    := aRetFun[nAux,3]
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := ""
			cNivFai    := ""
			cTipUsu    := aRetFun[nAux,7]
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := ""
			nIdaIni    := 0
			nIdaFin    := 0
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := 0
			nValAcre   := 0
			cCodSeq	   := ''
			cCompRea   := ''
			nValAtual  := 0
			nValAnter  := 0
			cCodPla    := aRetFun[nAux,4]
			cDesPla    := aRetFun[nAux,5]
			cVerPla    := aRetFun[nAux,6]
			cCodSB1    := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES    := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
			cTpForn    := aRetFun[nAux,8]
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")

			If lDirf11
				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif


			 If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif

			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

		Next
	//Debito / Creditos...                                                
	ElseIf aEventosCB[nFor,1] $ cCodDB .and. ( ! lFatura .or. aEventosCB[nFor,5] $ '1' ) .and. cReemb <> "1"

		If aEventosCB[nFor,1] $ cCodDB

			//Semaforo criado para que o sistema não se perca ao realizar a geração do lote de cobrança em Grid.
			nH := PLSAbreSem("PLSSLDDCF.SMF")
			
			aRetFun := PLSSLDDCF(cMatricFam,cAno,cMes,aClone(aUsuarios),aEventosCB[nFor,1],lOnlyLook,_cNivel,_cChave,cNumCob,Iif(cFunNa $ 'PLSA730,PLSA174',.F.,.T.))
			
			PLSFechaSem(nH,"PLSSLDDCF.SMF")
				
			lByPassDC := .T.
			For nAux := 1 To Len(aRetFun)

				cTipEve    := aRetFun[nAux,5] 	//Debito/Credito
				cCodEve    := aRetFun[nAux,10] //Codigo do Lancamento

				nValorEve  := aRetFun[nAux,6]
				cCodEveOri := IIf(Empty(aRetFun[nAux,14]),aRetFun[nAux,3],aRetFun[nAux,14])//Codigo do Lancamento
				cDesEveOri := IIf(Empty(aRetFun[nAux,15]),aRetFun[nAux,4],aRetFun[nAux,15])//Descricao do Lancamento

				cCargo     := ""
				cMatUsu    := aRetFun[nAux,1]
				cNomUsr    := aRetFun[nAux,2]
				lTotal     := .F.
				cSexo      := ""
				cGrauPa    := ""
				cFiller    := ""
				cCodFai    := ""
				cNivFai    := ""
				cTipUsu    := aRetFun[nAux,16]
				cAlias     := "BSQ"
				cOrigem    := aRetFun[nAux,7]
				cBaseIr    := ""
				nIdaIni    := 0
				nIdaFin    := 0
				nVlrMes    := nValorEve
				nSaldo1    := 0
				nSaldo2    := 0
				nTotSal    := 0
				nRecno     := aRetFun[nAux,8]
				nValDes	   := 0
				nValAcre   := 0
				cCodSeq	   := aRetFun[nAux,9]
				cCompRea   := ''
				nValAtual  := 0
				nValAnter  := 0
				cCodPla    := aRetFun[nAux,11]
				cDesPla    := aRetFun[nAux,12]
				cVerPla    := aRetFun[nAux,13]
			    cCodSB1    := MontaSB1(aEventosCB,nFor,cCodEve,cCodPla,cOpeFam,cMatUsu,_cNivel)
			    cCodTES    := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
		    	cTpForn    := aRetFun[nAux,17]
				npos       := Ascan(aEventosCB,{|X| X[1] ==cCodeve})
				BFQ->(DbSetorder(1))
				BFQ->(DbSeek(Xfilial("BFQ")+cOpPad+cCodEve))


				cVerba     := BFQ->BFQ_VERBA
				if lDirf11
					aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
					If Len(aDadGPE)>0
						cVerba:= If(BFQ->BFQ_TPLAN <>'1',cVerba,aDadGPE[1] )
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]
					Endif
				Endif
			    If lPLSINTFOL
					aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
					If Len(aDadGpe)>0
						cVerba:=aDadgpe[1]
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cTpForn  := aDadGPE[6]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]

					Endif
				Endif
	
				PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

			Next
		EndIf
	//Mensalidade Retroativa...                                           
	ElseIf aEventosCB[nFor,1] == "118" .and. ! lFatura  .and. cReemb <> "1"
		
		aValorRet := PLSCOBRETM(cMatricFam,aUsuarios,cAno,cMes,aRet,@lExistBFY,@lExistBDQ)
		
        nNumFor := nFor
		For nAux := 1 To Len(aValorRet)
			
			cCodEve    := Iif(aValorRet[nAux,4] $ "191/189", aValorRet[nAux,4], aEventosCB[nFor,1]) //Codigo do Lancamento
			
			npos := Ascan(aEventosCB,{|X| X[1] == cCodeve})
			If npos > 0
				cTipEve    := aEventosCB[npos,3] //Debito/Credito
			Else
				cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			EndIf
			
			If !(aValorRet[nAux,4] $ "191/189")
				nValorEve  := aValorRet[nAux,3]//ESTE PARAMETRO DEVE SER TRATADO PARA MUDANCA DE FAIXA APENAS IIf(nValAnter<>0,IIf(GetNewPar("MV_PLSBASI","1")=="1",nValAtual,aValorRet[nAux,3]),aValorRet[nAux,3]) // Como se trata de cobranca retroativa tem que preencher com valor antigo
			  	cCodEveOri := aValorRet[nAux,4] //Produto PLS
				cDesEveOri := aValorRet[nAux,5] //Descricao do Produto
			Else
				// Se estiver adicionando a linha referente ao desconto / acrescimo da mensalidade retroativa, 
				// o código de origem do evento será sempre 118 para diferenciar do desconto aplicado à mensalidade 101.
				cCodEveOri := aEventosCB[nFor,1]
				cDesEveOri := aValorRet[nAux,5]

				nValorEve := aValorRet[nAux,3]
				//nFor := 2 
			EndIf

			cCargo     := ""
			cMatUsu    := aValorRet[nAux,1]
			cNomUsr    := aValorRet[nAux,2]
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := ""
			cNivFai    := ""
			cTipUsu    := ""
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := ""
			nIdaIni    := 0
			nIdaFin    := 0
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],'')
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := aValorRet[nAux,6]
			nValAcre   := aValorRet[nAux,7]
			cCodSeq	   := ''
			cCompRea   := ''
			nValAtual  := 0
			nValAnter  := 0
			cCodPla    := aValorRet[nAux,4]
			cDesPla    := aValorRet[nAux,5]
			cVerPla    := aValorRet[nAux,8]
			cCodSB1    := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES    := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
			 
			cTpForn  := aValorRet[nAux,10]
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")
			
			If lDirf11
				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba   := If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan  := aDadGPE[2]
					cCodFor  := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif

			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba	 := aDadgpe[1]
					cTpPlan  := aDadGPE[2]
					cCodFor  := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif
			nFor := nNumFor
	
			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

		Next
	//Taxa de adesao do opcional...                                       
	ElseIf aEventosCB[nFor,1] == "133" .and. !lFatura .and. cReemb <> "1"
		
		nValorEve := 0
		aValorRet := PLSTXADOP(cMatricFam,aUsuarios,cAno,cMes,aRetOpc)

		For nAux := 1 To Len(aValorRet)

			cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

			nValorEve  := aValorRet[nAux,3]
			cCodEveOri := aValorRet[nAux,4] //Produto PLS
			cDesEveOri := aEventosCB[nFor,2] //Descricao do Produto

			cCargo     := ""
			cMatUsu    := aValorRet[nAux,1]
			cNomUsr    := aValorRet[nAux,2]
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := ""
			cNivFai    := ""
			cTipUsu    := aValorRet[nAux,9]
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := ""
			nIdaIni    := 0
			nIdaFin    := 0
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := 0
			nValAcre   := 0
			cCodSeq	   := ''
			cCompRea   := ''
			nValAtual  := 0
			nValAnter  := 0
			cCodPla    := aValorRet[nAux,4]
			cDesPla    := aValorRet[nAux,5]
			cVerPla    := aValorRet[nAux,8]
			cCodSB1    := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES    := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
			cTpForn  := aValorRet[nAux,10]
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")

  			If lDirf11
				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif

			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif
	
			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

		Next
	//Pego o lancamento de usuario...                                     
	//Este ponto de entrada tem 2 momentos, o primeiro eh quando eu estou 
	//apurando os valores o segundo eh qando eu estou gravando o BM1		
	//o que diferencia estes momentos eh o parametro de numero 10			
	//'1' - ESTOU APURANDO                                                
	//'2' - ESTOU GRAVANDO O BM1											
	ElseIf (aScan(aLanUsu,{|x| x[1] == aEventosCB[nFor,1]}) > 0)  .And. ! lFatura .and. cReemb <> "1"

		If ! Empty(aEventosCB[nFor,21]) .And. ExistBlock(aEventosCB[nFor,21])

			aRetFun := Execblock(aEventosCB[nFor,21],,.F.,.F.,{cMatricFam,cAno,cMes,cForPag,aUsuarios,lDireto,_cNivel,_cChave,aEventosCB,'1'})

			For nAux := 1 To Len(aRetFun)

				cTipEve    := aEventosCB[nFor,3] //Debito/Credito
				cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

				nValorEve  := aRetFun[nAux,2]
				cCodEveOri := aRetFun[nAux,11] //Produto PLS
				cDesEveOri := aRetFun[nAux,12] //Descricao do Produto

				cCargo 	   := aRetFun[nAux,3]
				cMatUsu    := aRetFun[nAux,1]
				cNomUsr    := aRetFun[nAux,4]
				lTotal     := .F.
				cSexo      := aRetFun[nAux,5]
				cGrauPa    := aRetFun[nAux,6]
				cFiller    := ""
				cCodFai    := aRetFun[nAux,8]
				cNivFai    := aRetFun[nAux,9]
				cTipUsu    := aRetFun[nAux,10]
				cAlias     := ""
				cOrigem    := aRetFun[nAux,7]
				cBaseIr    := aEventosCB[nFor,4]
				nIdaIni    := aRetFun[nAux,15]
				nIdaFin    := aRetFun[nAux,16]
				cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")
				nVlrMes    := nValorEve
				nSaldo1    := 0
				nSaldo2    := 0
				nTotSal    := 0
				nRecno     := 0
				nValDes	   := 0
				nValAcre   := 0
				cCodSeq	   := ''
				cCompRea   := ''
				nValAtual  := 0
				nValAnter  := 0



				PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

			Next
        EndIf
	//Gratuidade...                                                       
    ElseIf aEventosCB[nFor,1] == "184" .and. ! lFatura .and. cReemb <> "1"
  
    	aValorRet := PLSVLRGRA(cMatricFam,aUsuarios,cAno,cMes,aRet)

		For nAux := 1 To Len(aValorRet)

			cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

			nValorEve  := aValorRet[nAux,3]
			cCodEveOri := aValorRet[nAux,4]
			cDesEveOri := aValorRet[nAux,5]

			cCargo     := ""
			cMatUsu    := aValorRet[nAux,1]
			cNomUsr    := aValorRet[nAux,2]
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := ""
			cNivFai    := ""
			cTipUsu    := aValorRet[nAux,10]
			cAlias     := aValorRet[nAux,9]
			cOrigem    := ""
			cBaseIr    := ""
			nIdaIni    := 0
			nIdaFin    := 0
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := 0
			nValAcre   := 0
			cCodSeq	   := ''
			cCompRea   := ''
			nValAtual  := 0
			nValAnter  := 0
			cCodPla    := aValorRet[nAux,6]
			cDesPla    := aValorRet[nAux,7]
			cVerPla    := aValorRet[nAux,8]
			cTpForn    := aValorRet[nAux,11]
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")

			If lDirf11
				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif


			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif

			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
						lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

		Next

	//Opcionais ...                                                       
	Elseif aEventosCB[nFor,1] == "186" .and. ( ! lFatura .or. aEventosCB[nFor,5] $ '1' )

		If !CheckFatMensal(cMatricFam, cAno, cMes, "186")

			aRetFun := PLSVLRRP(cMatricFam,cAno,cMes,cForPag,aUsuarios,nil, lDireto)
			
			For Ix:=1 to Len(aRetFun)
				If aRetFun[Ix,21] > 0 // existe a patronal diferenciada acordo Ans
					lPatroDif:=.T.    //Patronal diferenciado (Acordo ANS CApesesp)
					Exit
				Endif
			next

			For nAux := 1 To Len(aRetFun)

				cTipEve    	:= aEventosCB[nFor,3]
				nValorEve  	:= aRetFun[nAux,2]
				cCodEve    	:= aEventosCB[nFor,1]
				cCodEveOri 	:= aRetFun[nAux,11]
				cDesEveOri 	:= upper(aEventosCB[nFor,2])

				If aRetFun[nAux,13] == 0
					cCargo := ""
				Else
					cCargo := STR0034 + Str(aRetFun[nAux,14],2) + STR0035 //"Cobranca Pro-Rata de "###" Dia(s)"
				EndIf

				cMatUsu    	:= aRetFun[nAux,1]
				cNomUsr    	:= aRetFun[nAux,4]
				lTotal     	:= .f.
				cSexo      	:= ""
				cGrauPa    	:= ""
				cFiller    	:= ""
				cCodFai    	:= aRetFun[nAux,8]
				cNivFai    	:= aRetFun[nAux,9]
				cTipUsu    	:= ""
				cAlias     	:= ""
				cOrigem    	:= ""
				cBaseIr    	:= aEventosCB[nFor,4]
				nFxaIni    	:= 0
				nFxaFin    	:= 0
				cVerba     	:= if(len(aEventosCB[nFor]) >= 18, aEventosCB[nFor,18], '')
				nVlrMes    	:= nValorEve
				nSaldo1    	:= 0
				nSaldo2    	:= 0
				nTotSal    	:= 0
				cCompRea	:= ''
				cCodPla 	:= aRetFun[nAux,11]
				cVerPla 	:= aRetFun[nAux,19]
				cDesPla 	:= aRetFun[nAux,12]
				cCodSB1 	:= MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
				cCodTES 	:= MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
				cTpForn  	:= aRetFun[nAux,20]
				cVerba     	:= if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")

				If lDirf11
					
					aDadGPE	:=	MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
					
					If Len(aDadGPE) > 0
						
						cVerba	:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cSeqDep := aDadGPE[4]
						cPlanGPE:= aDadGPE[5]

					Endif

				Endif

				If lPLSINTFOL

					aDadGpe := Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				
					If Len(aDadGpe) > 0

						cVerba	:= aDadgpe[1]
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cTpForn := aDadGPE[6]
						cSeqDep := aDadGPE[4]
						cPlanGPE:= aDadGPE[5]

					Endif

				Endif

				nValAtual := 0
				nValAnter := 0

				PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
							cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
							lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

			Next

		EndIf

	//Co-Participação não Considerada no Reembolso...                		
	ElseIf aEventosCB[nFor,1] == "185" .and. aEventosCB[nFor,20] == "1" .And.;
			( ! lFatura .or. aEventosCB[nFor,5] $ '1' ) .And. B45->(fieldPos("B45_VLRTPF")) > 0;
			 .And. cReemb == "2"

		aRetFun := PLSVLCORE(aUsuarios,cAno,cMes)

		For i := 1 to len(aRetFun)

			cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

			nValorEve  := aRetFun[i,1]
			cCodEveOri := aEventosCB[nFor,1] //Codigo do Lancamento
			cDesEveOri := aEventosCB[nFor,2] //Descricao do Lancamento

			cCargo     := ""
			cMatUsu    := aRetFun[i,2]
			cNomUsr    := aRetFun[i,3]
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := ""
			cNivFai    := ""
			cTipUsu    := ""
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := ""
			nIdaIni    := 0
			nIdaFin    := 0
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := 0
			nValAcre   := 0
			cCodSeq	   := ''
			cCompRea   := ''
			nValAtual  := 0
			nValAnter  := 0
			cCodPla    := aRetFun[i,4]
			cDesPla    := aRetFun[i,5]
			cVerPla    := aRetFun[i,6]
			cCodSB1    := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES    := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
			cTpForn    := aRetFun[i,7]
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")

			If lDirf11

				aDadGPE := MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
		
				If Len(aDadGPE) > 0

					cVerba   := If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan  := aDadGPE[2]
					cCodFor  := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
		
			Endif

			If lPLSINTFOL
				
				aDadGpe := Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				
				If Len(aDadGpe) > 0

					cVerba   := aDadgpe[1]
					cTpPlan  := aDadGPE[2]
					cCodFor  := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif

			Endif

			PLSMACOBAR(@nSeq,@aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
						cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,;
						cPlanGPE,lPatroDif,dDatDe,dDatAte,cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)

		Next

	EndIf

Next

If lPlsVlrFam 
   aRet := ExecBlock("PLSVLRFAM",.F.,.F.,{aRet,cMatricFam,cAno,cMes})
EndIf

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRFAI  ³ Autor ³ Tulio Cesar       ³ Data ³ 15.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Calcula o valor da faixa etaria de todos os usuarios de uma³±±
±±³          ³ familia com seu respectivo valor de cobranca neste ano/mes ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRFAI(cMatricFam,cAno,cMes,cForPag,aUsuarios,lOnlyLook,_cNivel,_cChave,lRecursive,nIdaRec,lExistUsr,lExistBFY,lExistBDQ)
LOCAL nVlrInd		:= 0
LOCAL nValorFam		:= 0
LOCAL nUltima		:= 0
LOCAL nSoma			:= 0
LOCAL nFor			:= 0
LOCAL nForFam		:= 0
LOCAL nPos			:= 0
LOCAL nPosFam		:= 0
LOCAL nIdade       	:= 0
LOCAL nValorFaixa	:= 0
LOCAL nDiasUtil     := 0
LOCAL nPercDias     := 0
LOCAL nValorRat     := 0

LOCAL nIdaIni		:= 0
LOCAL nIdaFin      	:= 0
LOCAL nQtdFam		:= 0
LOCAL nQtdUsr		:= 0
LOCAL nValDes  		:= 0
LOCAL nValAcre 		:= 0
LOCAL nValOri  		:= 0
LOCAL nDesMen  		:= 0
LOCAL nValAtual		:= 0
LOCAL nValAnter		:= 0
LOCAL nQtFam		:= 0
LOCAL cTipReg		:= ''
LOCAL cSexo         := ''
LOCAL cGrauPa       := ''
LOCAL cTipUsu       := ''
LOCAL cFaixaUtil    := ''
LOCAL cNivelUtil    := ''
LOCAL cFaiCob       := ''
LOCAL cSQL 			:= ''
LOCAL cCompRea		:= ''
LOCAL dDatInc       := CToD("")
LOCAL dDatBasIda 	:= CToD("01/"+cMes+"/"+cAno)
LOCAL lDesconto		:= .T.
LOCAL lMudFai       := .F.
LOCAL cOpeFam  		:= Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp  		:= Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric  		:= Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL cFilBBU  		:= xFilial("BBU")
LOCAL cNameBBU 		:= BBU->(RetSQLName("BBU"))
LOCAL cNameBFY 		:= BFY->(RetSQLName("BFY"))
LOCAL cNameBDQ 		:= BDQ->(RetSQLName("BDQ"))
LOCAL cFilBDQ  		:= xFilial("BDQ")
LOCAL cFilBDK  		:= xFilial("BDK")
LOCAL cNameBDK 		:= BDK->(RetSQLName("BDK"))
LOCAL aFaixas  		:= {}
LOCAL aValores 		:= {}
LOCAL aFaixasUsr 	:= {}
LOCAL aDescontos 	:= {}
LOCAL lBDKTabVld	:= BDK->(FieldPos("BDK_TABVLD")) > 0
LOCAL lMvPlsDBM1	:= GetNewPar("MV_PLSDBM1","0") == "1" // Define quando houver desconto ou acrécimo configu_rado pela tabela BFY ou BDQ, o sistema gera novo registro á parte na BM1 relacionado. (1=Gera BM1)
LOCAL aAuxValDes	:= {}
LOCAL nForDesc		:= 0
LOCAL nVerPRat      := 0
LOCAL aRetAux		:= {}
LOCAL aFrzFai		:= {}
LOCAL oObjFrz		:= nil
LOCAL nAnoLimite 	:= GetNewPar("MV_PLSILIM",60)
LOCAL nIdaFrz		:= 0
LOCAL lCont			:= .T.
LOCAL lLeiAnt		:= .F.
LOCAL lRetroFx		:= GetNewPar("MV_PLSFXRT",.F.)
LOCAL nSeqFrz		:= 1
Local lConsDtCanc   := GetNewPar("MV_PRODTCA",.F.)

DEFAULT aUsuarios 	:= {}
DEFAULT lOnlyLook 	:= .F.
DEFAULT lRecursive	:= .F.
DEFAULT nIdaRec		:= 0
DEFAULT lExistUsr	:= .F.
DEFAULT lExistBFY	:= .F.
DEFAULT lExistBDQ	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se existe faixa no usuario ja le todas essas faixas...              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BDK->(MsSeek(xFilial("BDK")+cMatricFam)) 
	lExistUsr  	:= .T. 
	If oPrepBDKA == nil
		cSQL := "SELECT BDK_TIPREG, BDK_CODFAI, BDK_IDAINI, BDK_IDAFIN, BDK_VALOR, BDK_ANOMES, BDK_VLRANT "
		If lBDKTabVld
			cSQL += ", BDK_TABVLD "
		EndIf
		cSQL += "FROM "+cNameBDK+" WHERE "
		cSQL += "BDK_FILIAL = ? AND "
		cSQL += "BDK_CODINT = ? AND "
		cSQL += "BDK_CODEMP = ? AND "
		cSQL += "BDK_MATRIC = ? AND "
		cSQL += "BDK_VALOR > 0 AND "
		cSQL += "D_E_L_E_T_ = ' '"
		oPrepBDKA:=FWPreparedStatement():New(cSQL)
	EndIf

	oPrepBDKA:SetString(1,cFilBDK)
	oPrepBDKA:SetString(2,cOpeFam)
	oPrepBDKA:SetString(3,cCodEmp)
	oPrepBDKA:SetString(4,cMatric)

	cSQL := oPrepBDKA:GetFixQuery()
	PLSBUSFAI := MpSysOpenQuery(cSQL)

	If !lBDKTabVld
		(PLSBUSFAI)->(DBEval( { | | aadd(aFaixasUsr, {BDK_TIPREG,BDK_CODFAI,BDK_IDAINI,BDK_IDAFIN,BDK_VALOR,BDK_ANOMES,BDK_VLRANT}) }))
	Else
		(PLSBUSFAI)->(DBEval( { | | aadd(aFaixasUsr, {BDK_TIPREG,BDK_CODFAI,BDK_IDAINI,BDK_IDAFIN,BDK_VALOR,BDK_ANOMES,BDK_VLRANT,Stod((PLSBUSFAI)->(BDK_TABVLD))}) }))
	EndIf

	(PLSBUSFAI)->(DbCloseArea())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca as faixas etarias desta familia...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If oPrepBBU == nil
	cSQL := "SELECT BBU_CODFAI,BBU_TIPUSR,BBU_GRAUPA,BBU_SEXO,BBU_IDAINI,BBU_IDAFIN,"
	cSQL += "BBU_VALFAI,BBU_ANOMES,BBU_VLRANT,BBU_TABVLD,BBU_QTDMIN,BBU_QTDMAX "
	cSQL += "FROM "+cNameBBU+" WHERE "
	cSQL += "BBU_FILIAL = ? AND "
	cSQL += "BBU_CODOPE = ? AND "
	cSQL += "BBU_CODEMP = ? AND "
	cSQL += "BBU_MATRIC = ? AND "
	cSQL += "BBU_CODFOR = ? AND "
	cSQL += "BBU_VALFAI > 0 AND "
	cSQL += "D_E_L_E_T_ = ' '"

	oPrepBBU:=FWPreparedStatement():New(cSQL)
endIf

oPrepBBU:SetString(1,cFilBBU)
oPrepBBU:SetString(2,cOpeFam)
oPrepBBU:SetString(3,cCodEmp)
oPrepBBU:SetString(4,cMatric)
oPrepBBU:SetString(5,cForPag)

cSQL := oPrepBBU:GetFixQuery()
PLSBUSFAI := MpSysOpenQuery(cSQL)

(PLSBUSFAI)->(DBEval( { | | aadd(aFaixas, {BBU_CODFAI,BBU_TIPUSR,BBU_GRAUPA,BBU_SEXO,BBU_IDAINI,BBU_IDAFIN,BBU_VALFAI,BBU_ANOMES,BBU_VLRANT,STod(BBU_TABVLD),BBU_QTDMIN,BBU_QTDMAX}) }))
(PLSBUSFAI)->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analiso cada usuario...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aUsuarios) == 0
	aUsuarios := PLSLOADUSR(cOpeFam,cCodEmp,cMatric,cAno,cMes,,lOnlyLook)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem a quantidade de usuarios na familia...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nQtFam := 1 to len(aUsuarios)
	If Len(aUsuarios[nQtFam]) > 33
		If (Empty(aUsuarios[nQtFam][34]) .Or. aUsuarios[nQtFam][34] > dDatabase)
			nQtdFam++ 
		EndIf
	Else
		nQtdFam := len(aUsuarios)
		exit
	EndIf
Next nQtFam

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso haja desconto leio esses dados p a matriz a descontos...       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BFY->(MsSeek(xFilial("BFY")+cMatricFam)) 

	lExistBFY  	:= .T. 
	If oPrepBBY == nil
		cSQL := "SELECT BFY_CODFAI, BFY_TIPUSR, BFY_GRAUPA, BFY_QTDDE, BFY_QTDATE, BFY_TIPO, "
		cSQL += "BFY_VALOR, BFY_PERCEN, BFY_DATDE, BFY_DATATE FROM "+cNameBFY+" WHERE "
		cSQL += "BFY_FILIAL = ? AND "
		cSQL += "BFY_CODOPE = ? AND "
		cSQL += "BFY_CODEMP = ? AND "
		cSQL += "BFY_MATRIC = ? AND "
		cSQL += "BFY_CODFOR = ? AND "
		cSQL += "(BFY_VALOR > 0 OR BFY_PERCEN > 0) AND "
		cSQL += "D_E_L_E_T_ = ' '"
		oPrepBBY:=FWPreparedStatement():New(cSQL)
	endIf

	oPrepBBY:SetString(1,cFilBBU)
	oPrepBBY:SetString(2,cOpeFam)
	oPrepBBY:SetString(3,cCodEmp)
	oPrepBBY:SetString(4,cMatric)
	oPrepBBY:SetString(5,cForPag)

	cSQL := oPrepBBY:GetFixQuery()
	PLSBUSFAI := MpSysOpenQuery(cSQL)

	TCSetField( (PLSBUSFAI), "BFY_DATDE", "D" )
	TCSetField( (PLSBUSFAI), "BFY_DATATE", "D" )

	(PLSBUSFAI)->( DBEval( { | | aadd(aDescontos, {BFY_CODFAI, BFY_TIPUSR, BFY_GRAUPA, BFY_QTDDE, BFY_QTDATE,;
			BFY_TIPO, BFY_VALOR,BFY_PERCEN,'BBU', '',BFY_DATDE,BFY_DATATE})},;
			{|| ( cAno+cMes >= SUBSTR(dTos(BFY_DATDE) ,1,6) .and.;
				  cAno+cMes <= SUBSTR(dTos(BFY_DATATE),1,6)) .or.;
			(Empty(dTos(BFY_DATATE)) .or. (Empty(dTos(BFY_DATDE)) .and.;
			Empty(dTos(BFY_DATATE)))) }))

	(PLSBUSFAI)->(DbCloseArea())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso haja desconto para a faixa especifica do usuario...            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BDQ->(MsSeek(xFilial("BDQ")+cMatricFam)) 

	lExistBDQ  	:= .T. 

	If oPrepBDQ == nil
		cSQL := "SELECT BDQ_CODFAI, BDQ_DATDE, BDQ_DATATE, BDQ_TIPO, "
		If BDQ->( FieldPos("BDQ_QTDMIN") ) > 0 .and. BDQ->( FieldPos("BDQ_QTDMAX") ) > 0
			cSql += "BDQ_QTDMIN, BDQ_QTDMAX, "
		EndIf
		cSQL += "BDQ_VALOR, BDQ_PERCEN, BDQ_TIPREG FROM "+cNameBDQ+" WHERE "
		cSQL += "BDQ_FILIAL = ? AND "
		cSQL += "BDQ_CODINT = ? AND "
		cSQL += "BDQ_CODEMP = ? AND "
		cSQL += "BDQ_MATRIC = ? AND "
		cSQL += "(BDQ_VALOR > 0 OR BDQ_PERCEN > 0) AND "
		cSQL += "D_E_L_E_T_ = ' '"
		oPrepBDQ:=FWPreparedStatement():New(cSQL)
	endIf

	oPrepBDQ:SetString(1,cFilBDQ)
	oPrepBDQ:SetString(2,cOpeFam)
	oPrepBDQ:SetString(3,cCodEmp)
	oPrepBDQ:SetString(4,cMatric)
	

	cSQL := oPrepBDQ:GetFixQuery()
	PLSBUSFAI := MpSysOpenQuery(cSQL)		

	TCSetField( (PLSBUSFAI), "BDQ_DATDE", "D" )
	TCSetField( (PLSBUSFAI), "BDQ_DATATE", "D" )

	If BDQ->( FieldPos("BDQ_QTDMIN") ) > 0 .and. BDQ->( FieldPos("BDQ_QTDMAX") ) > 0
		(PLSBUSFAI)->( DBEval(	{|| aadd(aDescontos, {BDQ_CODFAI, '', '', BDQ_QTDMIN, BDQ_QTDMAX,BDQ_TIPO, BDQ_VALOR,BDQ_PERCEN, 'BDK', BDQ_TIPREG,BDQ_DATDE,BDQ_DATATE})},;
								{|| ( cAno+cMes >= SUBSTR(dTos(BDQ_DATDE) ,1,6) .and. cAno+cMes <= SUBSTR(dTos(BDQ_DATATE),1,6)) .or. ( Empty(dTos(BDQ_DATATE)) .or. ( Empty(dTos(BDQ_DATDE)) .and. Empty( dTos(BDQ_DATATE) )) )  }))
	Else
		(PLSBUSFAI)->( DBEval(	{|| aadd(aDescontos, {BDQ_CODFAI, '', '', 0, 999, BDQ_TIPO, BDQ_VALOR,BDQ_PERCEN, 'BDK', BDQ_TIPREG,BDQ_DATDE,BDQ_DATATE})},;
								{|| ( cAno+cMes >= SUBSTR(dTos(BDQ_DATDE) ,1,6) .and. cAno+cMes <= SUBSTR(dTos(BDQ_DATATE),1,6)) .or. (Empty(dTos(BDQ_DATATE)) .or. (Empty(dTos(BDQ_DATDE)) .and. Empty(dTos(BDQ_DATATE)))) }))
	EndIf
	(PLSBUSFAI)->(DbCloseArea())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mes subsequente, com conteudo = 2.									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLSBASI","1")=="2"
	dDatBasIda := dDatBasIda - 1
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para cada usuario pego seu valor de faixa etaria...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 To Len(aUsuarios)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se pode cobrar a mensalidade do usuario.. vai existir casos³
	//³ em que so podera ser cobrado o fator moderador / custo do usuario.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aUsuarios[nFor][25]
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca o valor da faixa de acordo com o usuario atual...             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lRecursive
		// Busca o valor da faixa de acordo com o usuario atual...
	    If lPLSBSIDA
       	    dDatBasIda := ExecBlock("PLSBSIDA",.F.,.F.,{"1",dDatBasIda,aUsuarios[nFor],cMes,cAno,cMatricFam})
    	EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula idade														³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nIdade      := Calc_Idade(dDatBasIda,aUsuarios[nFor,2])
		nIdade		:= Iif(nIdade < 0,0,nIdade)
	else
		nIdade		:= nIdaRec
	endif
	cSexo       := aUsuarios[nFor,5]
	cGrauPa     := aUsuarios[nFor,6]
	cTipUsu     := aUsuarios[nFor,7]
	cTipReg     := aUsuarios[nFor,1]
	dDatInc     := dtos(aUsuarios[nFor,14])
	nPos        := 0
	nPosUsr		:= 0
	nValorFaixa := 0
	cNivelUtil  := "BBU"
	cFaixaUtil  := ""
	lMudFai     := aUsuarios[nFor,19]=="1"
	cFaiCob     := aUsuarios[nFor,20]
	nValDes     := 0
	lDesconto   := .T.
	ddataRef    := Ctod("01"+"/"+cMes+"/"+cAno)
	aAuxValDes := {}
	if 	FindFunction("RetFai627")  .And. lMudFai .And.;
		nIdade >= nAnoLimite .And. !lRecursive .And. cForPag == "101"
		
		//Verifica se entra na regra de planos anteriores ao estatuto do idoso
		lCont := AnaReg10y(aUsuarios[nFor,13],nIdade,nAnoLimite,cAno,cMes,@nIdaFrz,@lLeiAnt)
		
		if lCont
			//Verifica se a idade localizada é inferior ao ano limite
			if nIdaFrz < nAnoLimite
				nIdaFrz := nAnoLimite
			endif

			//Regra para atender clientes que desejam que a faixa seja congelada antes do usuario completar 60 anos
			if lLeiAnt
				//Verifica se deve manter na faixa de 59 anos
				if nIdaFrz == nAnoLimite .And. lRetroFx
					nIdaFrz := nAnoLimite - 1
				endif
			else
				//Verifica se deve manter na faixa de 59 anos
				if nIdaFrz == nAnoLimite .And. lRetroFx
					nIdaFrz := nAnoLimite - 1
				endif
			endif

			//Faz a chamada recursiva pra verificar qual faixa sera congelada
			aRetAux := PLSVLRFAI(cMatricFam,cAno,cMes,cForPag,{aUsuarios[nFor]},lOnlyLook,_cNivel,_cChave,.T.,nIdaFrz)
		
		endif

		nPosAux := aScan(aRetAux, { |x| x[24] == "101"})
		if nPosAux > 0
			//preenche as informacoes da faixa que sera congelada
			aAdd(aFrzFai,.T.)
			aAdd(aFrzFai,aRetAux[nPosAux,1])
			aAdd(aFrzFai,aRetAux[nPosAux,8])

			cFaiCob := aRetAux[nPosAux,8]
			lMudFai := .F.

			PlsFreArr(@aRetAux)
		endif

		//Inicializa e preenche o objeto
		oObjFrz := RetFai627()
		PLSetHash(nSeqFrz,aFrzFai,@oObjFrz)
		PlsFreArr(@aFrzFai)
		nSeqFrz++

	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se existe faixa por usuario, pesquisa neste caso...                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lExistUsr
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca o valor da faixa de acordo com o usuario atual...             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMudFai //busca a faixa etaria normalmente...
			If !lBDKTabVld
				nPosUsr := Ascan(aFaixasUsr, { |x| cTipReg == x[1] .And. nIdade>=x[3] .And. nIdade<= x[4] })
         Else
				nPosUsr := Ascan(aFaixasUsr, { |x| cTipReg == x[1] .And. nIdade>=x[3] .And. nIdade<= x[4] .AND. (Empty(x[8]).Or. ddataref <= x[8]) })
			EndIf
		Else //busca a ultima faixa dele contida no BA1_FAICOB porque ele nao muda mais a faixa...
			nPosUsr := Ascan(aFaixasUsr, { |x| cTipReg == x[1] .And. x[2] == cFaiCob  })
		EndIf

		If nPosUsr > 0
			cNivelUtil  := "BDK"
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se para o usuario atual ainda pode ser alterada sua faixa..³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!lExistUsr .Or. nPosUsr == 0)
		If lMudFai
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chaves                                                              ³
			//³                                                                     ³
			//³ SEXO, GRAU DE PARANTESCO E TIPO DE USUARIO...                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aFaixas, { |x| x[2]==cTipUsu .And. x[4]==cSexo .And. cGraupa==x[3] .And. nIdade>=x[5] .And. nIdade<= x[6] .And.(Empty(x[10]).Or. ddataref<= x[10])})
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chaves                                                              ³
			//³                                                                     ³
			//³ TIPO DE USUARIO E GRAU DE PARANTESCO...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aFaixas, { |x| x[2]==cTipUsu .And. cGraupa==x[3] .And. x[4] $ "3, " .And. nIdade>=x[5] .And. nIdade<= x[6] .And.(Empty(x[10]).Or. ddataref<= x[10])})
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chaves                                                              ³
			//³                                                                     ³
			//³ TIPO DE USUARIO E SEXO...                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aFaixas, { |x| x[2]==cTipUsu .And. x[4]==cSexo .And. Empty(x[3])  .And. nIdade>=x[5] .And. nIdade<= x[6] .And.(Empty(x[10]).Or. ddataref<= x[10])})
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chaves                                                              ³
			//³                                                                     ³
			//³ GRAU DE PARENTESCO E SEXO...                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aFaixas, { |x| cGraupa==x[3] .And. x[4]==cSexo .And. Empty(x[2]) .And. nIdade>=x[5] .And. nIdade<= x[6] .And.(Empty(x[10]).Or. ddataref<= x[10])})
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chaves                                                              ³
			//³                                                                     ³
			//³ TIPO DE USUARIO SOZINHO...                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aFaixas, { |x| x[2]==cTipUsu .And. empty(x[3]) .And. x[4] $ "3, " .And. nIdade >= x[5] .And. nIdade <=x[6] .And.(Empty(x[10]).Or. ddataref<= x[10]) })
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chaves                                                              ³
			//³                                                                     ³
			//³ SEXO SOZINHO...                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aFaixas, { |x| x[4]== cSexo .And. Empty(x[2]) .And. empty(x[3]) .And. nIdade >= x[5] .And. nIdade <=x[6] .And.(Empty(x[10]).Or. ddataref<= x[10])  })
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chaves                                                              ³
			//³                                                                     ³
			//³ GRAU DE PARENTESCO SOZINHO...                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aFaixas, { |x| cGraupa==x[3] .And. x[4] $ "3, " .And. Empty(x[2]) .And.  nIdade >= x[5] .And. nIdade <=x[6] .And.(Empty(x[10]).Or. ddataref<= x[10]) })
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chaves                                                              ³
			//³                                                                     ³
			//³ TODAS EM BRANCAS...                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aFaixas, { |x|	nIdade >= x[5] .And.;
												nIdade <= x[6] .And.;
												AllTrim(x[2]) == '' .And.;
												AllTrim(x[3]) == '' .And.;
												(AllTrim(x[4]) == ''.or. x[4] == '3') .and. ;
											    (Empty(x[10]).Or. ddataref <= x[10] )})
			EndIf
		Else
			//busca a faixa BA1_FAICOB
			nPos := Ascan(aFaixas, { |x| x[1] == cFaiCob })
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se foi localizada o valor busca os mesmos...                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPos + nPosUsr) > 0

		If cNivelUtil == "BDK"

			nValorFaixa := Iif((cAno+cMes>=aFaixasUsr[nPosUsr,6]), aFaixasUsr[nPosUsr,5], aFaixasUsr[nPosUsr,7])
			nVerPRat    := nValorFaixa
			cFaixaUtil  := aFaixasUsr[nPosUsr,2]
			nIdaIni     := aFaixasUsr[nPosUsr,3]
			nIdaFin     := aFaixasUsr[nPosUsr,4]

			cCompRea	:= aFaixasUsr[nPosUsr,6]
			nValAtual	:= aFaixasUsr[nPosUsr,5]
			nValAnter	:= aFaixasUsr[nPosUsr,7]

		ElseIf cNivelUtil == "BBU"

			nValorFaixa := Iif((cAno+cMes>=aFaixas[nPos,8]), aFaixas[nPos,7], aFaixas[nPos,9])
			nVerPRat    := nValorFaixa
			cFaixaUtil  := aFaixas[nPos,1]
			nIdaIni     := aFaixas[nPos,5]
			nIdaFin     := aFaixas[nPos,6]

			cCompRea	:= aFaixas[nPos,8]
			nValAtual	:= aFaixas[nPos,7]
			nValAnter	:= aFaixas[nPos,9]

		EndIf

		If lPLSDSCMN .And. !lRecursive
			lDesconto := ExecBlock("PLSDSCMN", .F., .F., {_cNivel,_cChave,aUsuarios[nFor]})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso haja desconto realiza o calculo desses descontos...            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lExistBDQ .Or. lExistBFY) .and. lDesconto .And. !lRecursive
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa o desconto por                                             ³
			//³ GRAU DE PARANTESCO E TIPO DE USUARIO...                       		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos := Ascan(aDescontos,{ |x| 	x[2] == cTipUsu 	.And. cGraupa == x[3] .And.;
											x[1] == cFaixaUtil 	.And. nQtdFam >= x[4] .And. nQtdFam <= x[5] .And.;
											x[9] == cNivelUtil 	.And. x[10] == Iif(cNivelUtil== 'BDK',cTipReg,'') })
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa o desconto por                                             ³
			//³ GRAU DE PARANTESCO                                            		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aDescontos,{ |x| AllTrim(x[2]) == '' .And. x[3] == cGraupa .And.;
														x[1] == cFaixaUtil .And. nQtdFam >= x[4] .And. nQtdFam <= x[5] .And.;
														x[9] == cNivelUtil .And. x[10] == Iif(cNivelUtil== 'BDK',cTipReg,'') })
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa o desconto por                                             ³
			//³ tipo de usuario                                               		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aDescontos,{ |x| x[2] == cTipUsu 	.And. AllTrim(x[3]) == '' .And.;
												x[1] == cFaixaUtil	.And. nQtdFam >= x[4] .And. nQtdFam <= x[5] .And.;
												x[9] == cNivelUtil 	.And. x[10] == Iif(cNivelUtil== 'BDK',cTipReg,'') })
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa o desconto por                                             ³
			//³ todos os tipo...                                              		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos == 0
				nPos := Ascan(aDescontos,{ |x| AllTrim(x[2]) == '' .And. AllTrim(x[3]) == '' .And.;
											x[1] == cFaixaUtil .And. nQtdFam >= x[4] .And. nQtdFam <= x[5] .And.;
											x[9] == cNivelUtil .And. x[10] == Iif(cNivelUtil== 'BDK',cTipReg,'') })
			EndIf

			If nPos > 0

				If aDescontos[nPos,6] == "1" //Desconto
					
					//Desconto em Percentual.
					If aDescontos[nPos,8] > 0 
					
						// Calcula o desconto e aplico ao valor da mensalidade...
						If lMvPlsDBM1
							aAdd(aAuxValDes, {"1",Round( ((nValorFaixa*aDescontos[nPos,8])/100),2 ),aDescontos[nPos,8],aDescontos[nPos,7]})
							nValDes := aAuxValDes[1,2]
						Else
							nValDes := Round( ((nValorFaixa*aDescontos[nPos,8])/100),2 )
							// Chamado TQKEVI - O desconto só pode ser aplicado sobre o valor quando o 
							// parametro MV_PLSDBM1 <> "1"						
							nValorFaixa := nValorFaixa - nValDes							
						EndIf

					//Desconto em Valor.
					ElseIf aDescontos[nPos,7] > 0 

						// Obtem o valor do desconto...
						If lMvPlsDBM1
							// Desconto em cascata.  												
							aAdd(aAuxValDes, {"1",Round( aDescontos[nPos,7] ,2 ),aDescontos[nPos,8],aDescontos[nPos,7],aDescontos[nPos,11],aDescontos[nPos,12]})
							nValDes := aAuxValDes[1,2]
						Else
							nValDes := Round( aDescontos[nPos,7] ,2 )														
							// Chamado TQKEVI - O desconto só pode ser aplicado sobre o valor quando o 
							// parametro MV_PLSDBM1 <> "1"						
							nValorFaixa := nValorFaixa-nValDes
							
						EndIf

					EndIf
				
				//Acrescimo
				ElseIf aDescontos[nPos,6] == "2" 
					
					//Perc
					If aDescontos[nPos,8] > 0 

						// Calcula o acrescimo e aplico ao valor da mensalidade...
						If lMvPlsDBM1
							aAdd(aAuxValDes, {"2",Round( ((nValorFaixa*aDescontos[nPos,8])/100),2 ),aDescontos[nPos,8],aDescontos[nPos,7],aDescontos[nPos,11],aDescontos[nPos,12]})
							nValAcre := aAuxValDes[1,2]							
						Else
							nValAcre := Round( ((nValorFaixa*aDescontos[nPos,8])/100),2 )
							
							// Chamado TQKEVI - O acrescimo só pode ser aplicado sobre o valor quando o 
							// parametro MV_PLSDBM1 <> "1"														
							nValorFaixa := nValorFaixa+nValAcre
						EndIf
 					//Valor
					ElseIf aDescontos[nPos,7] > 0

						// Obtem o valor do Acrescimo...
						If lMvPlsDBM1
							// acrescimo em cascata.  						
							aAdd(aAuxValDes, {"2",Round( aDescontos[nPos,7] ,2 ),aDescontos[nPos,8],aDescontos[nPos,7],aDescontos[nPos,11],aDescontos[nPos,12]})
							nValAcre := aAuxValDes[1,2]							
						Else
							nValAcre := Round( aDescontos[nPos,7] ,2 )

							// Chamado TQKEVI - O acrescimo só pode ser aplicado sobre o valor quando o 
							// parametro MV_PLSDBM1 <> "1"	
							nValorFaixa := nValorFaixa+nValAcre
							
						EndIf

					EndIf
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aplica o desconto geral da familia...                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPLSBA3DM .And. !lRecursive 
			lDesconto := ExecBlock("PLSBA3DM", .F., .F., {_cNivel,_cChave,aUsuarios[nFor],lDesconto})
		EndIf

		// Aplica o desconto fixo no nivel do subcontrato, (fieldpos retirado pois se trata de campos antigos e ganho de performance)
		If  BQC->BQC_PERCON > 0 .and. lDesconto
			
			// Armazena valor original...
			nValOri := nValorFaixa

			// Calcula o desconto e aplica ao valor da mensalidade...
			nValorFaixa := Round(nValorFaixa-((nValorFaixa*BQC->BQC_PERCON)/100),2)

			// Obtem o valor do desconto...
			nDesMen := (nValOri-nValorFaixa)

			// Valor total do desconto.
			nValDes += nDesMen

		EndIf

		// Aplica o desconto fixo no nivel da familia. (fieldpos retirado pois se trata de campos antigos e ganho de performance)
		If BA3->BA3_DESMEN > 0 .and. lDesconto
			
			// Armazena valor original...
			nValOri := nValorFaixa

			// Calcula o desconto e aplica ao valor da mensalidade...
			nValorFaixa := Round(nValorFaixa-((nValorFaixa*BA3->BA3_DESMEN)/100),2)

			// Obtem o valor do desconto...
			nDesMen := (nValOri-nValorFaixa)

			// Valor total do desconto.
			nValDes += nDesMen

		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ irei analisar agora a cobranca pro rata...                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aUsuarios[nFor,16] .or. aUsuarios[nFor,23]

			If aUsuarios[nFor,16]

				nPercDias   := plRPerPR(aUsuarios[nFor,14], nil, @nDiasUtil, Nil, PLDayVencCob(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))

				nValorRat   := Round( ( ( nValorFaixa * nPercDias ) / 100 ), 2 )
				nValorFaixa := nValorRat
				
				If nValorFaixa == nVerPRat 
					nPercDias := 0
					nValorRat := 0
					nDiasUtil := 0
					aUsuarios[nFor,16] := .F.
				EndIf	
				
			Else
				
				nPercDias   := plRPerPR(aUsuarios[nFor,24], lConsDtCanc, @nDiasUtil, .T., PLDayVencCob(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
				nValorRat   := Round( ( ( nValorFaixa * nPercDias )/100 ), 2 )

				// Quando o Bloqueio RN 412 estiver ativo, o valor do pro-rata será calculado na função CalcProRat
				If GetNewPar("MV_PL9BPRA", "0") == "0" 
					nValorFaixa := nValorRat
				EndIf
			EndIf

		Else
			nValorRat   := 0
			nDiasUtil   := 0
			nPercDias   := plRPerPR(aUsuarios[nFor,24], lConsDtCanc)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valor da mensalidade pro-rata referente ao mes anterior...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aValores,{ aUsuarios[nFor,13],;//01 - Matricula do beneficiario
						nValorFaixa,;		//02 - Valor da faixa etaria 
						Str(nIdade,3),;	   	//03 - Idade
						aUsuarios[nFor,3],;	//04 - Nome
						aUsuarios[nFor,5],;	//05
						aUsuarios[nFor,6],;	//06
						aUsuarios[nFor,4],;	//07
						cFaixaUtil,;		//08
						cNivelUtil,;		//09
						aUsuarios[nFor,7],;	//10
						aUsuarios[nFor,8],;	//11 - Codigo do produto / plano
						aUsuarios[nFor,9],;	//12 - Descricao do produto / plano
						nValorRat,;			//13 - Valor calculado da pro rata
						nDiasUtil,;			//14 - Quantidade de dias utilizado
						nIdaIni,;			//15 - Idade inicial da faixa etaria
						nIdaFin,;			//16 - Idade final da faixa etaria
						nValDes,;			//17 - Valor de desconto apurado
						nValAcre,;			//18 - Valor de acrescimo apurado
						cCompRea,;			//19 - Competencia de reajuste
						nValAtual,;			//20 - Valor atual da mensalidade
						nValAnter,;			//21 - Valor anterior da mensalidade (so tem depois que teve algum reajuste)
						aUsuarios[nFor,29],;//22
						aUsuarios[nFor,31],;//23
						cForPag,;			//24 - Forma de cobranca / pagamento 101 - Plano, 102 - Taxa de adesao, 103 - Opcional, etc
						0,; 				//25
						0})         		//26 	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Descontos ou Acrécimos configurados na BFY ou BDQ...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !lRecursive
			
			For nForDesc := 1 To LEN(aAuxValDes)

				aadd(aValores,{	aUsuarios[nFor,13],;     //01
								IIF( nValorRat == 0 , Round(aAuxValDes[nForDesc,2], 2), Round(((nValAtual*nPercDias)/100), 2) ),;//02
								Str(nIdade,3),;             //03
								aUsuarios[nFor,3],;         //04
								aUsuarios[nFor,5],;         //05
								aUsuarios[nFor,6],;         //06
								aUsuarios[nFor,4],;         //07
								cFaixaUtil,;                //08
								cNivelUtil,;                //09
								aUsuarios[nFor,7],;         //10
								aUsuarios[nFor,8],;         //11
								aUsuarios[nFor,9],;         //12
								nValorRat,;                 //13
								nDiasUtil,;                 //14
								nIdaIni,;                   //15
								nIdaFin,;                   //16
								Round(((nValAtual*nPercDias)/100), 2),;                   //17
								nValAcre,;                  //18
								cCompRea,;                  //19
								nValAtual,;                 //20
								nValAnter,;                 //21
								aUsuarios[nFor,29],;        //22
								aUsuarios[nFor,31],;        //23
								IIf(aAuxValDes[nForDesc,1]=="1", "191", "189"),;//24
								aDescontos[nPos,11],; 		//25
								aDescontos[nPos,12]})       //26  
			Next nForDesc

		endif

	EndIf

Next nFor

If lPlsVlrFx  .And. !lRecursive
   aValores := ExecBlock("PLSVLRFX",.F.,.F.,{aValores,cMatricFam,cAno,cMes,cForPag})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para forma de cobrança por Faixa Familiar (106)...       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cForPag == "106" .And. !lRecursive

	For nForFam := 1 To Len(aValores)
		If aValores[nForFam,24] == cForPag
			nQtdUsr ++
		Endif
	Next nForFam

	nPosFam := Ascan(aFaixas,{|x| nQtdUsr >= x[11] .And. nQtdUsr <= x[12]})

	If nPosFam > 0

		nValorFam := aFaixas[nPosFam,7]
		nVlrInd   := nValorFam/nQtdUsr

		For nForFam := 1 To Len(aValores)

			If aValores[nForFam,24] == cForPag
				aValores[nForFam,2] := nVlrInd
				nSoma += nVlrInd
				nUltima := nForFam
			Endif

		Next

		If nUltima > 0
			aValores[nUltima,2] := aValores[nUltima,2]+(nValorFam-nSoma)
		Endif

	Endif

Endif

Return(aValores)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSINPBFQ  ³ Autor ³ Tulio Cesar       ³ Data ³ 15.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Inclui os registros para uma determinada operadora no BFQ  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Geraldo Jr. ³        ³      ³ Contemplar campos de trat. de impostos...³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSINPBFQ(cCodOpe,bRegras)
LOCAL aEventos := {{'','','','','','','','','','','','','','','','','','','','','',''}}
DEFAULT bRegras:= {|| .T.}

DbSelectArea("BFQ")
BFQ->(DbSetOrder(3)) //BFQ_FILIAL + BFQ_SEQUEN
If BFQ->(MsSeek(xFilial("BFQ")))
	BFQ->(DBEval( {|| AaDd(aEventos, {	BFQ_PROPRI+BFQ_CODLAN,;										// 01
										BFQ_DESCRI,;												// 02
										BFQ_DEBCRE,;                                               	// 03
										BFQ_INCIR,;													// 04
										BFQ_TIPFAT,;												// 05
										BFQ_REGCIR,;			                                    // 06
										BFQ_INCISS,;			                                    // 07
										BFQ_REGCIS,;		                                    	// 08
										BFQ_INCCON,;		                                    	// 09
										BFQ_REGCCO,;	                                    		// 10
										BFQ_INCPIS,;	                                    		// 11
										BFQ_REGCPI,;	                                    		// 12
										BFQ_INCCSL,;	                                    		// 13
										BFQ_REGCCS,;	                                    		// 14
										BFQ_INCINS,;	                                    		// 15
										BFQ_REGCIN,;	                                    		// 16
										BFQ_REGCI1,;	                                    		// 17
										BFQ_VERBA ,;	                                    		// 18
										BFQ_ATOCOO,;	                                    		// 19
										BFQ_ATIVO ,;                                                // 20
										BFQ_FORUSU,;                                                // 21
										BFQ_CODSB1,;                                                // 22
										BFQ_CODTES,;                                                // 23
										BFQ_LANACE,;                                                // 24
										BFQ_TPLAN		})}, {||BFQ->BFQ_CODINT == cCodOpe .and. Eval(bRegras) .And.	BFQ->BFQ_FILIAL == 	xFilial("BFQ") .And. AvaliaLanc()} ))

EndIf

Return(aEventos)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRPF   ³ Autor ³ Tulio Cesar       ³ Data ³ 15.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna os valores de participacao financeira de uma fam.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	BDH_VALOR  -> Co-Participacao
	BDH_VLRCOP -> Custo Operacional Servicos Medicos
	BDH_VLRCP2 -> Custo Operacional Servicos Acessorios
	BDH_VLRCP3 -> Custo Operacional Outros Servicos
	BDH_VLRTAX -> Taxa Adm

	BDH_VALCPF -> Co-Participacao Pagar Proxima Fatura
	BDH_VALCOF -> Custo pagar proxima fatura
	BDH_VALTCF -> Taxa Adm Pagar Proxima Fatura

	Codigos lancamento 104,116,117,123,124,125,127, 134

/*/
Function PLSVLRPF(cMatricFam,cAno,cMes,aUsuarios,aEventosCB,lRetMovCob,lFaturados,cFatura,cUsr,aFatBM1,lAmbos)
LOCAL cSQL
LOCAL cFilBDH  := xFilial("BDH")
LOCAL cNameBDH := BDH->(RetSQLName("BDH"))
LOCAL cOpeFam  := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp  := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric  := Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL aRetPF   := {}
LOCAL cMatricUsr
LOCAL cNomeUsr
LOCAL nPos2
LOCAL nFor
LOCAL aMovtos   := {}
LOCAL aDadosBDH := {}
LOCAL cCodPla	:= ''
LOCAL cDesPla	:= ''
LOCAL cVerPla	:= ''
LOCAL cTipoUsr	:= ''
LOCAL cTpForn   := ' '
local cBanco	:= allTrim( TCGetDB() )
LOCAL lSNCGR    := GetNewPar("MV_PLSNCGR","1") == "0"

DEFAULT lRetMovCob	:= .F.
DEFAULT lFaturados	:= .F.
DEFAULT cFatura		:= ''
DEFAULT cUsr		:= ''
DEFAULT aFatBM1     := {}
DEFAULT lAmbos		:= .F.

If ! lRetMovCob
	cSQL := "SELECT BDH_TIPREG,BDH_VALOR,BDH_VLRTAX,BDH_VALCOM,BDH_VALCOF,BDH_VLRCOP,BDH_ANOFT,BDH_MESFT,"
	cSQL += "BDH_VALCOC,BDH_VALCOT,BDH_VALCPF,BDH_VALTCF, R_E_C_N_O_ "
	cSql += ", BDH_VLRCP2, BDH_VLRCP3, BDH_VLRCP4, BDH_VLRCP5, BDH_VLRCP6, BDH_VLRCP7, BDH_VLRCP8, BDH_VLRCP9 "
	cSql += ", BDH_VLRCPA, BDH_VLRCPB, BDH_VLRCPC, BDH_VALOR1, BDH_VALOR2, BDH_VALOR3, BDH_VALOR4, BDH_VALOR5, BDH_VALOR6, BDH_VALOR7, BDH_VALOR8, BDH_VALOR9, BDH_VLRT11 " 
	cSql += ", BDH_VLRT12, BDH_VLRT13, BDH_VLRT14, BDH_VLRT15, BDH_VLRT16, BDH_VLRT17, BDH_VLRT18, BDH_VLRT19 " 
	cSql += ", BDH_VLRT1A, BDH_VLRT1B, BDH_VLRT1C " 
	cSql += ", BDH_VLRT21, BDH_VLRT24, BDH_VLRT25, BDH_VLRT26, BDH_VLRT27, BDH_VLRT28, BDH_VLRT29 " 
	cSql += ", BDH_VLRT2A, BDH_VLRT2B, BDH_VLRT2C " 
	If BDH->(FieldPos("BDH_VLRTIM")) > 0 ; cSql += ", BDH_VLRTIM " ; EndIf
	If BDH->(FieldPos("BDH_VLRPES")) > 0 ; cSql += ", BDH_VLRPES " ; EndIf
	If BDH->(FieldPos("BDH_VLRPAR")) > 0 ; cSql += ", BDH_VLRPAR " ; EndIf
Else
	cSQL := "SELECT BDH_CODINT, BDH_CODEMP, BDH_MATRIC, BDH_TIPREG, BDH_ANOFT, BDH_MESFT, BDH_SEQPF, R_E_C_N_O_ AS REGBDH "
EndIf
cSQL += "FROM "+cNameBDH+" WHERE "
cSQL += "BDH_FILIAL = '"+cFilBDH+"' AND "
cSQL += "BDH_CODINT = '"+cOpeFam+"' AND "
cSQL += "BDH_CODEMP = '"+cCodEmp+"' AND "
cSQL += "BDH_MATRIC = '"+cMatric+"' AND "
If !Empty(cUsr) .And. lRetMovCob
	cSql += "BDH_TIPREG = '"+cUsr+"' AND "
EndIf
If lAmbos
	If lFaturados
		If len(aFatBM1) > 0
			cSQL += "( ((BDH_NUMSE1 = '"+cFatura+"' AND BDH_STATUS <> '1') "
			cSQL += " OR (BDH_PREFIX = '" + aFatBM1[1] +"' "
			cSQL += " AND BDH_NUMTIT = '" + aFatBM1[2] +"' "
			cSQL += " AND BDH_PARCEL = '" + aFatBM1[3] +"' "
			cSQL += " AND BDH_TIPTIT = '" + aFatBM1[4] +"' "
			cSQL += " AND BDH_STATUS <> '1')) OR "
		Else
			cSQL += "( (BDH_NUMSE1 = '"+cFatura+"' AND BDH_STATUS <> '1') OR "
		EndIf
		cSQL += "( (BDH_ANOFT < '" + cAno + "' OR ( BDH_ANOFT = '" + cAno + "' AND BDH_MESFT  <= '" + cMes + "' )) AND "
		cSQL += "BDH_STATUS = '1' ) ) AND "
	Else
		cSQL += "( (BDH_ANOFT < '" + cAno + "' OR ( BDH_ANOFT = '" + cAno + "' AND BDH_MESFT  <= '" + cMes + "' )) AND "
		cSQL += "BDH_STATUS = '1' ) AND "
	EndIf	
Else
	If lFaturados .And. lRetMovCob
		If len(aFatBM1) > 0
			cSQL += "((BDH_NUMSE1 = '"+cFatura+"' AND BDH_STATUS <> '1') "
			cSQL += " OR (BDH_PREFIX = '" + aFatBM1[1] +"' "
			cSQL += " AND BDH_NUMTIT = '" + aFatBM1[2] +"' "
			cSQL += " AND BDH_PARCEL = '" + aFatBM1[3] +"' "
			cSQL += " AND BDH_TIPTIT = '" + aFatBM1[4] +"' "
			cSQL += " AND BDH_STATUS <> '1')) AND "
		Else
			cSQL += "(BDH_NUMSE1 = '"+cFatura+"' AND BDH_STATUS <> '1') AND "
		EndIf
	Else
		cSQL += "(BDH_ANOFT < '" + cAno + "' OR ( BDH_ANOFT = '" + cAno + "' AND BDH_MESFT  <= '" + cMes + "' )) AND "
		cSQL += "BDH_STATUS = '1' AND "
	EndIf
EndIf
cSQL += "D_E_L_E_T_ = ' ' "
IF ExistBlock('PLSPARFI')	//	P.E. na Participação Financeira
	cSQL += Execblock('PLSPARFI', .F., .F.)
ENDIF
//Como se trata de uma QUERY simples e que roda em todos os bancos dados não precisamos utilizar ChangeQuery assim ganhando performance
//cSQL := ChangeQuery(cSQL)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSVLRPF",.F.,.T.)

While !PLSVLRPF->( Eof() )

	If lSNCGR // Não cobrar co-participação retroativa referente a período de gratuidade da família ou usuário 0=Não, 1=Sim (padrão)

		aRetGra := PLSPERGRA(cMatricFam,PLSVLRPF->BDH_TIPREG) // Periodos de gratuidade da familia/usuario
		nPos 	:= aScan(aRetGra,{|x| PLSVLRPF->(BDH_ANOFT+BDH_MESFT) >= x[2] .And. PLSVLRPF->(BDH_ANOFT+BDH_MESFT) <= x[3]})

		If nPos > 0 // Atualizo a participacao para gratuidade, nunca mais sera considerada a faturar ou faturada

			cUpd := " UPDATE " + RetSqlName("BDH") 
			cUpd += "    SET BDH_STATUS = '2' "
			cUpd += "  WHERE R_E_C_N_O_ = " + Iif(!lRetMovCob, allTrim(str(PLSVLRPF->R_E_C_N_O_)),AllTrim(Str(PLSVLRPF->REGBDH)))

			if TCSQLExec(cUpd) < 0
	
	    		FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})
	
			elseIf cBanco == "ORACLE"
	
				TCSQLExec("COMMIT")
	
			endIf
			
			PLSVLRPF->(DbSkip())
			
		EndIf
		
	EndIf
	If !lRetMovCob
		nPos := Ascan(aUsuarios,{|x| x[1] == PLSVLRPF->BDH_TIPREG})
		If nPos > 0
			cMatricUsr 	:= aUsuarios[nPos,13]
			cNomeUsr   	:= aUsuarios[nPos,03]
			cCodPla		:= aUsuarios[nPos,08]
			cDesPla		:= aUsuarios[nPos,09]
			cVerPla		:= aUsuarios[nPos,29]
			cTipoUsr    := aUsuarios[nPos,7]
			cTpForn     := aUsuarios[nPos,31]
			// Tratamento para parcelamento
			nValPar := 0
			If BDH->(FieldPos("BDH_VLRPAR")) > 0 .And. PLSVLRPF->BDH_VLRPAR > 0
				nValPar := PLSVLRPF->BDH_VLRPAR
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fator moderador / co-participacao...                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLSVLRPF->BDH_VALOR > 0

				PLRETPF("116",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR1 > 0

				PLRETPF("147",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR1,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR2 > 0

				PLRETPF("148",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR2,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR3 > 0

				PLRETPF("149",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR3,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR4 > 0

				PLRETPF("150",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR4,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR5 > 0

				PLRETPF("151",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR5,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR6 > 0

				PLRETPF("152",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR6,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR7 > 0

				PLRETPF("153",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR7,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR8 > 0

				PLRETPF("154",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR8,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALOR9 > 0

				PLRETPF("155",aEventosCB,aRetPF,PLSVLRPF->BDH_VALOR9,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT21 > 0

				PLRETPF("168",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT21,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT24 > 0

				PLRETPF("169",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT24,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT25 > 0

				PLRETPF("170",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT25,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT26 > 0

				PLRETPF("171",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT26,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT27 > 0

				PLRETPF("172",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT27,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT28 > 0

				PLRETPF("173",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT28,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT29 > 0

				PLRETPF("174",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT29,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT2A > 0

				PLRETPF("175",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT2A,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT2B > 0

				PLRETPF("176",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT2B,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT2C > 0

				PLRETPF("177",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT2C,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Custo Operacional...                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PLSVLRPF->BDH_VLRCOP > 0

				PLRETPF("104",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCOP,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRTAX > 0

				PLRETPF("117",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRTAX,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALCPF > 0

				PLRETPF("124",aEventosCB,aRetPF,PLSVLRPF->BDH_VALCPF,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALCOF > 0

				PLRETPF("123",aEventosCB,aRetPF,PLSVLRPF->BDH_VALCOF,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VALTCF > 0

				PLRETPF("125",aEventosCB,aRetPF,PLSVLRPF->BDH_VALTCF,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCP2 > 0

				PLRETPF("127",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCP2,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCP3 > 0

				PLRETPF("134",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCP3,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCP4 > 0

				PLRETPF("137",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCP4,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCP5 > 0

				PLRETPF("138",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCP5,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCP6 > 0

				PLRETPF("139",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCP6,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCP7 > 0

				PLRETPF("140",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCP7,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCP8 > 0

				PLRETPF("141",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCP8,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCP9 > 0

				PLRETPF("142",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCP9,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCPA > 0

				PLRETPF("143",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCPA,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCPB > 0

				PLRETPF("144",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCPB,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRCPC > 0

				PLRETPF("145",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRCPC,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT11 > 0

				PLRETPF("156",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT11,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)
				nPos2 := Ascan(aEventosCB,{|x| x[1] == "156"})

			EndIf

			If PLSVLRPF->BDH_VLRT12 > 0

				PLRETPF("157",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT12,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT13 > 0

				PLRETPF("158",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT13,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT14 > 0

				PLRETPF("159",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT14,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT15 > 0

				PLRETPF("160",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT15,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT16 > 0

				PLRETPF("161",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT16,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf


			If PLSVLRPF->BDH_VLRT17 > 0

				PLRETPF("162",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT17,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT18 > 0

				PLRETPF("163",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT18,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT19 > 0

				PLRETPF("164",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT19,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT1A > 0

				PLRETPF("165",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT1A,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT1B > 0

				PLRETPF("166",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT1B,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If PLSVLRPF->BDH_VLRT1C > 0

				PLRETPF("167",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRT1C,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If BDH->(FieldPos("BDH_VLRTIM")) > 0 .And. PLSVLRPF->BDH_VLRTIM > 0 .And. cPaisLoc == "URU"

				PLRETPF("182",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRTIM,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf

			If BDH->(FieldPos("BDH_VLRPES")) > 0 .And. PLSVLRPF->BDH_VLRPES > 0 .And. cPaisLoc == "URU"

				PLRETPF("183",aEventosCB,aRetPF,PLSVLRPF->BDH_VLRPES,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,PLSVLRPF->R_E_C_N_O_,nValPar,cTipoUsr,cTpForn)

			EndIf
		EndIf
	Else
		AaDd(aDadosBDH,{PLSVLRPF->BDH_CODINT,;
			PLSVLRPF->BDH_CODEMP,;
			PLSVLRPF->BDH_MATRIC,;
			PLSVLRPF->BDH_TIPREG,;
			PLSVLRPF->BDH_ANOFT,;
			PLSVLRPF->BDH_MESFT,;
			PLSVLRPF->BDH_SEQPF,;
			PLSVLRPF->REGBDH})
	EndIf

	PLSVLRPF->(DbSkip())
Enddo

PLSVLRPF->(DbCloseArea())

If lRetMovCob
	For nFor := 1 To Len(aDadosBDH)
		BD6->(DbSetOrder(12))
		If BD6->(DbSeek(xFilial("BD6")+aDadosBDH[nFor,1]+aDadosBDH[nFor,2]+aDadosBDH[nFor,3]+aDadosBDH[nFor,4]+;
				aDadosBDH[nFor,5]+aDadosBDH[nFor,6]+aDadosBDH[nFor,7]))
			While ! BD6->(Eof()) .And. ;
					BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF) == ;
					xFilial("BD6")+aDadosBDH[nFor,1]+aDadosBDH[nFor,2]+aDadosBDH[nFor,3]+aDadosBDH[nFor,4]+aDadosBDH[nFor,5]+aDadosBDH[nFor,6]+aDadosBDH[nFor,7]
				AaDd(aMovtos,{BD6->(Recno()),BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO),BD6->BD6_DATPRO})
				BD6->(DbSkip())
			Enddo
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( If(!lRetMovCob, {aRetPF, {} },aMovtos) )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLRETPF    ³ Autor ³ Alexander Santos  ³ Data ³ 14.12.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Monta matriz de retorno									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLRETPF(cLanc,aEventosCB,aRetPF,nValor,cMatricUsr,cNomeUsr,cCodPla,cDesPla,cVerPla,nRecno,nValPar,cTipoUsr,cTpforn)
LOCAL 	nPos2 	:= 0

Default nValPar := 0

If nValPar > 0
	nValor := nValPar
EndIf

If cLanc == "141" .and. nValPar > 0
	nValor := 0
EndIf

If ( nPos2 := Ascan( aEventosCB,{|x| x[1] == cLanc} ) ) > 0

	AaDd(aRetPF,{	aEventosCB[nPos2,1],;	//01
					aEventosCB[nPos2,2],;	//02
					aEventosCB[nPos2,3],;	//03
					aEventosCB[nPos2,4],;	//04
					nValor,;				//05
					cMatricUsr,;			//06
					cNomeUsr,;				//07
					cCodPla,;				//08
					cDesPla,;				//09
					cVerPla,;				//10
					nRecno,;            //11
					cTipoUsr,;				//12
					cTpForn }) //13
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSLOADUSR ³ Autor ³ Tulio Cesar       ³ Data ³ 15.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Le todos os usuarios de uma familia...                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLOADUSR(cOpeFam,cCodEmp,cMatric,cAno,cMes,cTipReg,lOnlyLook)
LOCAL cSQL			:= ''
LOCAL cFilBA1   	:= xFilial("BA1")
LOCAL cNameBA1  	:= BA1->(RetSQLName("BA1"))
LOCAL aUsuarios 	:= {}
LOCAL dDatAux		:= ctod('')
LOCAL lCobProRat	:= .F.
LOCAL lCobRet   	:= .F.
LOCAL lCobRatRet	:= .F.
LOCAL lCobRatSai	:= .F.
LOCAL lBA1_CB1AM	:= .T.
LOCAL nDiaRet   	:= 0
LOCAL cAnoMesAnt	:= ""
LOCAL lCobPorComp 	:= .T.
LOCAL aPlano	  	:= {}
LOCAL aAreaBA3	 	:= BA3->(GetArea())
LOCAL aAreaBI3	 	:= BI3->(GetArea())
LOCAL aAreaBA0	 	:= BA0->(GetArea())
LOCAL aAreaBQC	 	:= BQC->(GetArea())
LOCAL aAreaBT6	 	:= BT6->(GetArea())
LOCAL cCodPat	 	:= ""
LOCAL lRet    	 	:= .F.
LOCAL lCobAll 	 	:= .T.
LOCAL lCobBT5 	 	:= .F.
LOCAL lCobBQC 	 	:= .F.
LOCAL aAnalizUsr 	:= {}

DEFAULT cTipReg 	:= ''
DEFAULT lOnlyLook 	:= .F.

BA3->( msSeek( xFilial("BA3") + cOpeFam + cCodEmp + cMatric ) )

plsPRUSU(cOpeFam, lPlsCbDr, @cCodPat, @nDiaRet, @lCobProRat, @lCobRatSai, @lCobRet, @lCobRatRet)

cSQL := "SELECT BA1_DATBLO,BA1_MUDFAI, BA1_DATINC, BA1_CODEMP,BA1_MATRIC,BA1_CODINT,BA1_DIGITO,BA1_CBTXAD,"
cSQL += "BA1_TIPUSU, BA1_NOMUSR, BA1_TIPREG,BA1_DATNAS, R_E_C_N_O_ REG, BA1_SEXO, BA1_GRAUPA, BA1_MOTBLO, "
cSQL += "BA1_CONSID, BA1_CODPLA, BA1_VERSAO , BA1_FAICOB , BA1_BLOFAT , BA1_COBRET , BA1_TXADOP , BA1_CB1AMS, "
cSQL += "BA1_COBINI, BA1_MATVID "

cSQL += "FROM " + cNameBA1 + " WHERE "
cSQL += "BA1_FILIAL = '" + cFilBA1 + "' AND "
cSQL += "BA1_CODINT = '" + cOpeFam + "' AND "
cSQL += "BA1_CODEMP = '" + cCodEmp + "' AND "
cSQL += "BA1_MATRIC = '" + cMatric + "' AND "

// Tratamento por usuario...                                           
If !Empty(cTipReg)
	cSQL += "BA1_TIPREG = '" + cTipReg + "' AND "
EndIf

lBA1_CB1AM := .T.

//Conceito de fechamento na PJ
//???_CobRet define se cobra retroativo ou nao... indepedente do campo ???_DiaRet
//Se ???_CobRet por Sim, serao cobrados os usuarios que entraram ate o dia definido no ???_DiaRet no mes anterior ao pedido na fatura
//Somente no proximo mes e em duplicidade, ou seja, a cobranca do mes e a cobranca retroativa
//
// exemplo: cobranca retroativa SIM
//          data de corte 20 (???_DiaRet)
// usuario A entrou no dia 18/08/2005
// usuario B entrou no dia 21/08/2005
// vamos faturar competencia 2005/09
// sera cobrado somente o usuario A, porque ele entrou antes do dia 20/08/2005 (mes anterioe da fat + dia de corte)
// na fatura de 2005/10, sera cobrado normalmente o usuario B ref comp mes 09, mais o usuario A do mes 09 mais o retroativo dele ref ao mes 08

// exemplo: cobranca retroativa NAO
//          data de corte 0 (???_DiaRet)
// usuario A entrou no dia 18/08/2005
// usuario B entrou no dia 21/08/2005
// vamos faturar competencia 2005/09
// vamos cobrar os dois usuarios ref ao mes 09/2005, porque eles entraram antes do dia 31/08/2005 porque quando o ???_DiaRet e zero ele considera
// todos que entraram ate o mes anterior

// exemplo: cobranca retroativa NAO
//          data de corte 0 (???_DiaRet)
//          NOVO CAMPO CRIADO BQC_CONCON "Cons.Compet?" como NAO
// usuario A entrou no dia 18/08/2005
// usuario B entrou no dia 21/08/2005
// vamos faturar competencia 2005/09
// vamos cobrar os dois usuarios ref ao mes 09/2005, NAO IMPORTANDO O DIA QUE ELE ENTROU, somente o fato dele estar ATIVO no dia
// ele ja vai entrar no pre-pagamento do mes 09/2005

//a regra do retroativo e somente para PJ...							
If BA3->BA3_TIPOUS == "2"

	lCobPorComp := .t.

	//Nao existe o novo campo fazer como era antes do novo conceito		
   	If BQC->BQC_CONCON == "0"
      	lCobPorComp := .f.
   	EndIf

	If lCobPorComp .and. !lOnlyLook
	
	   cAnoMesAnt := PLSDIMAM(cAno,cMes,"0")
	   dDatAux    := cAnoMesAnt + strZero(nDiaRet,2)

	   cSQL += " BA1_DATINC <= '" + dDatAux + "' AND "
	
	EndIf

EndIf

cSQL += "D_E_L_E_T_ = ' ' "

cSQL += "ORDER BY BA1_FILIAL,BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO"
//Como se trata de uma QUERY simples e que roda em todos os bancos dados não precisamos utilizar ChangeQuery assim ganhando performance
//cSQL := ChangeQuery(cSQL)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSFAI",.F.,.T.)
TCSetField( "PLSBUSFAI", "BA1_DATINC", "D" )
TCSetField( "PLSBUSFAI", "BA1_DATNAS", "D" )
TCSetField( "PLSBUSFAI", "BA1_DATBLO", "D" )


//Avalia os usuarios da familia, um por um...                         
While !PLSBUSFAI->( Eof() )

   //Posiciona o cadastro de usuario...                                        
   BA1->( dbGoto(PLSBUSFAI->REG) )
   
   // Verifica o nível do usuário se está habilitado ou não a cobrança retroativa
   lCobRet := (BA1->BA1_COBRET == "1")

   	//Analiza o usuario quanto a bloqueio, cobranca antecipada e custo a cobrar.
  	aAnalizUsr := AnalisaUsr(cAno,cMes,lBA1_CB1AM, BA3->BA3_TIPOUS,lOnlyLook)

   	//Avalia de o usuario pode ou nao ser cobrado e alimenta a matriz.           
	If cAno + cMes >= Subs(DtoS(PLSBUSFAI->(BA1_DATINC)),1,6) .And. aAnalizUsr[1]

		aPlano := PLPROUSR(cOpeFam)

		aadd(aUsuarios,{PLSBUSFAI->BA1_TIPREG,;	//01
						PLSBUSFAI->BA1_DATNAS,;	//02
						PLSBUSFAI->BA1_NOMUSR,;	//03
						PLSBUSFAI->REG,;		//04
						PLSBUSFAI->BA1_SEXO,;	//05
						PLSBUSFAI->BA1_GRAUPA,;	//06
						PLSBUSFAI->BA1_TIPUSU,;	//07
						aPlano[1],;				//08
						aPlano[2],;				//09
						aPlano[3],;				//10
						PLSBUSFAI->BA1_CBTXAD,;	//11
						PLSBUSFAI->BA1_DIGITO,;	//12
						PLSBUSFAI->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;	//13
						PLSBUSFAI->BA1_DATINC,;	//14
						lCobProRat,;			//15
						Iif(lCobProRat .or. lCobRatRet,Subs(dtos(PLSBUSFAI->BA1_DATINC),1,6)==cAno+cMes,lCobProRat),;	//16
						lCobRet,;				//17
						nDiaRet,;				//18
						PLSBUSFAI->BA1_MUDFAI,;	//19
						PLSBUSFAI->BA1_FAICOB,;	//20
						PLSBUSFAI->BA1_COBRET,;	//21
						lCobRatSai,;			//22
						Iif(lCobRatSai,Subs(DtoS(PLSBUSFAI->BA1_DATBLO),1,6)==cAno+cMes,.F.),;	//23
						PLSBUSFAI->BA1_DATBLO,;	//24
						aAnalizUsr[2],;			//25
						PLSBUSFAI->BA1_TXADOP,;	//26
						BA3->BA3_VALSAL,;		//27
						lCobRatRet,;			//28
						aPlano[4],;    			//29
						cCodPat,;				//30 - Codigo da tabela patronal.
						aPlano[5],;  			//31- Tipo de fornecedor
						PLSBUSFAI->BA1_COBINI,; //32-
						lCobPorComp,;			//33- cobranca por competencia
						PLSBUSFAI->BA1_DATBLO,; //34 - Status do usuário
						PLSBUSFAI->BA1_MATVID})	//35 - Matricula Vida		
		EndIf

	PLSBUSFAI->( dbSkip() )

EndDo

//Fecha arquivo temporario...                                               
PLSBUSFAI->( DbCloseArea() )

If BT5->(DbSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)))
	lCobBT5 := BT5->BT5_COBNIV == '1'
Endif

If	BQC->(DbSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
	lCobBQC := BQC->BQC_COBNIV == '1'
Endif

If BA3->BA3_TIPOUS == "2" .and.  Len(aUsuarios)==0 .and. (lCobBT5 .or. lCobBQC)

	//³ Usuario bloqueado, verifico agora se tem Debitos a cobrar nos níveis contrato e subcontrato.                                                                           |
	cSQL := "SELECT R_E_C_N_O_ FROM "+RetSqlName("BSQ")+" WHERE "
	cSQL += "BSQ_FILIAL = '"+xFilial("BSQ")+"' AND "

	If lCobBT5
		cSQL += " BSQ_CODINT = '"+ BA3->BA3_CODINT +"' "
		cSQL += " AND BSQ_CODEMP = '"+ BA3->BA3_CODEMP+"' "
		cSQL += " AND BSQ_CONEMP = '"+ BA3->BA3_CONEMP+"' "
		cSQL += " AND BSQ_VERCON = '"+ BA3->BA3_VERCON+"' AND "
	Elseif lCobBQC
		cSQL += " BSQ_CODINT = '"+ BA3->BA3_CODINT+"' "
		cSQL += " AND BSQ_CODEMP = '"+ BA3->BA3_CODEMP+"' "
		cSQL += " AND BSQ_CONEMP = '"+ BA3->BA3_CONEMP+"' "
		cSQL += " AND BSQ_VERCON = '"+ BA3->BA3_VERCON+"' "
		cSQL += " AND BSQ_SUBCON = '"+ BA3->BA3_SUBCON+"' "
		cSQL += " AND BSQ_VERSUB = '"+ BA3->BA3_VERSUB+"' AND "
	Endif

	cSQL += "(BSQ_COBNIV = '2' or BSQ_COBNIV = '3') AND "

	cSQL += "BSQ_ANO || BSQ_MES <= '"+cAno+cMes+"' AND "
	cSQL += "D_E_L_E_T_ = ' ' AND "
	cSql += "BSQ_NUMCOB = ' ' "
	
	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBA1",.F.,.T.)

	If !TRBA1->( Eof() )
		lRet := PLSBLQDC(BA1->BA1_DATBLO, BA1->BA1_MOTBLO, BA1->BA1_CONSID)
		lCobAll	:= .F.
	EndIf

	TRBA1->( dbCloseArea() )

	If lRet
		if BA1->( msSeek( xFilial("BA1") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+cTipReg) ) )

			nRecBA1 := BA1->(Recno())

			aadd(aUsuarios,{BA1->BA1_TIPREG,;	//01
							BA1->BA1_DATNAS,;	//02
							BA1->BA1_NOMUSR,;	//03
							nRecBA1,;			//04
							BA1->BA1_SEXO,;		//05
							BA1->BA1_GRAUPA,;	//06
							"T",;	//07
							" ",;		//08
							" ",;		//09
							" ",;		//10
							BA1->BA1_CBTXAD,;	//11
							BA1->BA1_DIGITO,;	//12
							BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;	//13
							BA1->(BA1_DATINC),;	//14
							.F.,;	//15
							.F.,;	//16
							.F.,;		//17
							0,;		//18
							BA1->BA1_MUDFAI,;	//19
							BA1->BA1_FAICOB,;	//20
							BA1->BA1_COBRET,;	//21
							.F.,;	//22
							.F.,;	//23
							BA1->BA1_DATBLO,;	//24
							lCobAll,;	//25
							BA1->BA1_TXADOP,;	//26
							BA3->BA3_VALSAL,;	//27
							.F.,;	//28
							" ",; //29
							"",;  //30
							"",;  //31
							"",;  //32
							.F.,; //33
							BA1->BA1_DATBLO}) //34
		Endif

	Endif

Endif

If lPlsLoau 
   aUsuarios := ExecBlock("PLSLOADU",.F.,.F.,{aUsuarios,cOpeFam,cCodEmp,cMatric,cAno,cMes})
EndIf

RestArea(aAreaBA3)
RestArea(aAreaBI3)
RestArea(aAreaBA0)
RestArea(aAreaBQC)
RestArea(aAreaBT6) 

Return(aUsuarios)

/*/{Protheus.doc} plsPRUSU
verifica pelo nivel se e retroativa/prorata

@author  PLS TEAM
@version P12
@since   25/05/04
/*/
function plsPRUSU(cOpeFam, lPlsCbDr, cCodPat, nDiaRet, lCobProRat, lCobRatSai, lCobRet, lCobRatRet)
default cCodPat 	:= ''
default nDiaRet	 	:= 0
default lCobProRat 	:= .f.
default lCobRatSai 	:= .f.
default lCobRet	 	:= .f.
default lPlsCbDr 	:= .f.
default lCobRatRet	:= .f.

BA0->( msSeek( xFilial("BA0") + cOpeFam ) )

//pessoa juridica
if BA3->BA3_TIPOUS == "2" 

	BT6->( msSeek( xFilial("BT6") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA) ) )
	BQC->( msSeek( xFilial("BQC") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) ) )

	// Pega o código da tabela patronal.
	cCodPat 	:= BT6->BT6_CODPAT

	lCobProRat 	:= (BT6->BT6_COBRAT == '1')

	if ! empty(BQC->BQC_COBRAT)
		lCobProRat := (BQC->BQC_COBRAT == '1')
	endIf

	if ! empty(BI3->BI3_COBRAT)
		lCobProRat := (BI3->BI3_COBRAT == '1')
	endIf

	if ! empty(BA3->BA3_COBRAT)
		lCobProRat := (BA3->BA3_COBRAT == '1')
	endIf	

	nDiaRet := BA0->BA0_DIARET

	if ! empty(BQC->BQC_DIARET)  
		nDiaRet := BQC->BQC_DIARET
	endIf	

	if ! empty(BA3->BA3_DIARET)  
		nDiaRet := BA3->BA3_DIARET
	endIf

	if ! empty(BQC->BQC_COBRET)
		lCobRet := (BQC->BQC_COBRET == '1')
	endIf

	if ! empty(BA3->BA3_COBRET)
		lCobRet := (BA3->BA3_COBRET == '1')
	endIf
	
	//Cobranca retroativa na saida do usuario... 
	lCobRatSai := .t.

	if BA3->BA3_RATSAI <> "1"
		lCobRatSai := BT6->(found()) .and. BT6->BT6_RATSAI == "1"
	endIf

	if BQC->( msSeek( xFilial("BQC") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) ) )

		// Pega o código da tabela patronal.
		if empty(cCodPat)
			cCodPat := BQC->BQC_CODPAT
		endif

	endif

	if lPlsCbDr 
	   	nDiaRet := execBlock("PLSCBDR", .f.,.f., { BA3->BA3_CODINT, BA3->BA3_GRPCOB, cAno, cMes, right(dTos(dDataBase),2), nDiaRet } )
	endIf
	
else

	lCobProRat	:= (BI3->BI3_COBRAT == '1')

	if ! empty(BA3->BA3_COBRAT)
		lCobProRat 	:= (BA3->BA3_COBRAT == '1')
	endIf	

	lCobRet := (BA3->BA3_COBRET == '1')

	nDiaRet := BA0->BA0_DIARET

	if ! empty(BA3->BA3_DIARET)
		nDiaRet := BA3->BA3_DIARET	
	endIf	

	// Cobranca retroativa na saida do usuario...      
	lCobRatSai := .t.                    

	if BA3->BA3_RATSAI <> "1"
		lCobRatSai := BI3->BI3_RATSAI == "1"
	endIf

endIf

//Cobranca pro rata retroativa...                                     
if lCobProRat .and. lCobRet
	lCobRatRet	:= .t.
	lCobProRat	:= .f.
	lCobRet 	:= .f.
endIf

//se nao for parametrizado, o corte e o ultimo dia do mes				
if nDiaRet == 0
	nDiaRet := 31
endIf

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVALOPC  ³ Autor ³ Tulio Cesar       ³ Data ³ 15.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Valoriza os opcionais de um usuario                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
BF4 - Opcionais do usuario
BYX - Formas de cobranca dos opcionais do usuario
BZX - Faixas etarias x opcionais do usuario
/*/
//cForCob = '01' // veio da faixa etaria
//cForCob = '02' // veio da faixa salarial
Function PLSVALOPC(cMatricFam,cAno,cMes,aUsuarios,cRdMake,lOnlyLook,_cNivel,_cChave,cTipEve,cCodEve)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aFaixas     := {}
LOCAL aValores    := {}
LOCAL nValorFaixa
LOCAL nIdade
LOCAL cTipReg
LOCAL cSexo
LOCAL cGrauPa
LOCAL cTipUsu
LOCAL cFaixaUtil
LOCAL cNivelUtil
LOCAL dDatBasIda  := ctod("01/"+cMes+"/"+cAno)
LOCAL nPos
LOCAL nPosUsr
LOCAL lBlqFatur	  := .F.
LOCAL lVlrAde	  := ( BZX->( FieldPos("BZX_VLRADE") ) > 0 )

LOCAL nDiasUtil	  := 0
LOCAL nPercDias	  := 0
LOCAL nValorRat	  := 0
LOCAL nSalario	  := 0

LOCAL cOpeFam     := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp     := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric     := Subs(cMatricFam,atMatric[1],atMatric[2])

LOCAL cSQL

LOCAL cFilBF4     := xFilial("BF4")
LOCAL cNameBF4    := BF4->(RetSQLName("BF4"))

LOCAL cFilBI3     := xFilial("BI3")
LOCAL cNameBI3    := BI3->(RetSQLName("BI3"))

LOCAL cFilBYX     := xFilial("BYX")
LOCAL cNameBYX    := BYX->(RetSQLName("BYX"))

LOCAL cFilBZX     := xFilial("BZX")
LOCAL cNameBZX    := BZX->(RetSQLName("BZX"))

LOCAL lDesconto   := .T.
LOCAL nValDes	  := 0
LOCAL nValAcre	  := 0
LOCAL nValOri	  := 0
LOCAL nCntFor     := 0
LOCAL aStruct     := {}
LOCAL nRegSX3     := 0
LOCAL nOrdSX3     := 0
LOCAL aStruBZX    := {}
LOCAL aRetPto     := {}
LOCAL bVldOpcPad  := { || (PLSOPCUSR)->BYX_CODFOR == "104" }
LOCAL cCompRea	  := ''
LOCAL nValAtual	  := 0
LOCAL nValAnter	  := 0
LOCAL lContCalc   := .F.
LOCAL cDataBase   := dDatBasIda 
DEFAULT aUsuarios := {}
DEFAULT cRdMake   := "PLSPORFAI"
DEFAULT lOnlyLook := .F.
DEFAULT _cNivel   := ""
DEFAULT _cChave   := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso os usuarios nao tenham sido carregados carrega via rotina gen  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aUsuarios) == 0
   aUsuarios := PLSLOADUSR(cOpeFam,cCodEmp,cMatric,cAno,cMes,,lOnlyLook)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloqueios de opcionais...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BG3->( dbSetorder(01) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os opcionais e respectivas formas de cobranca...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If oPrepOpcA == nil
	cSQL := "SELECT BI3_CODIGO,BI3_DESCRI,BF4_FILIAL,BF4_CODINT,BF4_CODEMP,BF4_MATRIC,"
	cSql += "BF4_CODPRO,BF4_VERSAO,BF4_TIPREG,BF4_DATBAS,BF4_DATBLO,BF4_MOTBLO, "
	cSql += "BYX_CODFOR, "+cNameBF4+".R_E_C_N_O_ REGBF4 "
	cSQL += " FROM "+cNameBF4+", "+cNameBYX+", "+cNameBI3+" WHERE "
	cSQL += "BF4_FILIAL = ? AND "
	cSQL += "BF4_CODINT = ? AND "
	cSQL += "BF4_CODEMP = ? AND "
	cSQL += "BF4_MATRIC = ? AND "
	cSQL += cNameBF4+".D_E_L_E_T_ = ' ' AND "
	cSQL += "BYX_FILIAL = ? AND "
	cSQL += "BYX_CODOPE = BF4_CODINT    AND "
	cSQL += "BYX_CODEMP = BF4_CODEMP    AND "
	cSQL += "BYX_MATRIC = BF4_MATRIC    AND "
	cSQL += "BYX_TIPREG = BF4_TIPREG	AND "
	cSQL += "BYX_CODOPC = BF4_CODPRO	AND "
	cSQL += "BYX_VEROPC = BF4_VERSAO	AND "
	cSQL += cNameBYX+".D_E_L_E_T_ = ' ' AND "
	cSQL += "BI3_FILIAL = ?				AND "
	cSQL += "BI3_CODINT = BF4_CODINT    AND "
	cSQL += "BI3_CODIGO = BF4_CODPRO    AND "
	cSQL += "BI3_VERSAO = BF4_VERSAO    AND "
	cSQL += cNameBI3+".D_E_L_E_T_ = ' ' "
	If  lPlsFtOpc 
		aRetPto := ExecBlock("PLSFTOPC",.F.,.F.,{cSQL})
		cSQL += aRetPto[1]
	EndIf

	cSQL += " GROUP BY BI3_CODIGO, BI3_DESCRI, BF4_FILIAL, BF4_CODINT, BF4_CODEMP, BF4_MATRIC, " 
	cSQL += "BF4_CODPRO, BF4_VERSAO, BF4_TIPREG, BF4_DATBAS, BF4_DATBLO, BF4_MOTBLO, BYX_CODFOR, "+cNameBF4+".R_E_C_N_O_ "
	cSQL += "ORDER BY BF4_FILIAL,BF4_CODINT,BF4_CODEMP,BF4_MATRIC,BF4_TIPREG,BF4_CODPRO,BF4_VERSAO" 


	oPrepOpcA:=FWPreparedStatement():New(cSQL)
EndIF

oPrepOpcA:SetString(1,cFilBF4)
oPrepOpcA:SetString(2,cOpeFam)
oPrepOpcA:SetString(3,cCodEmp)
oPrepOpcA:SetString(4,cMatric)
oPrepOpcA:SetString(5,cFilBYX)
oPrepOpcA:SetString(6,cFilBI3)


cSQL := oPrepOpcA:GetFixQuery()
PLSOPCUSR := MpSysOpenQuery(cSQL)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mes subsequente, com conteudo = 2.									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLSBASI","1")=="2"
	dDatBasIda := dDatBasIda - 1
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para cada opcional x forma de cobranca busco suas faixas etarias... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !(PLSOPCUSR)->( Eof() )
	//Não calcula o valor do opcional se a Data base não estiver antes ou dentro do mês
	If Stod((PLSOPCUSR)->BF4_DATBAS) > LastDay(cDataBase) 
		(PLSOPCUSR)->( dbSkip() )
		Loop
	EndIf 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso estaja bloqueado, analiza se o bloqueio permite faturamento... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty((PLSOPCUSR)->BF4_MOTBLO) .Or. !Empty(Stod((PLSOPCUSR)->BF4_DATBLO))
		If BG3->( dbSeek(xFilial("BG3")+(PLSOPCUSR)->BF4_MOTBLO) )
			lBlqFatur := PlsBlqFat(Stod((PLSOPCUSR)->BF4_DATBLO), (PLSOPCUSR)->BF4_MOTBLO, "U")
			If BG3->BG3_TIPBLO == '0'
				If Empty(Stod((PLSOPCUSR)->BF4_DATBLO)) .Or. Subs((PLSOPCUSR)->BF4_DATBLO,1,6) >= cAno+cMes .Or. lBlqFatur

				Else
					(PLSOPCUSR)->( dbSkip() )
					Loop
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Para o desbloqueio.													³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Elseif BG3->BG3_TIPBLO == '1'
				If Empty(Stod((PLSOPCUSR)->BF4_DATBLO)) .Or. Subs((PLSOPCUSR)->BF4_DATBLO,1,6) <= cAno+cMes .Or. lBlqFatur

				Else
					(PLSOPCUSR)->( dbSkip() )
					Loop
				EndIf
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa a forma de cobranca...                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPtoEnt
	   bVldOpcPad := ExecBlock("PLSFCOV",.F.,.F.,{(PLSOPCUSR)->REGBF4,cAno,cMes})
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Forma de cobranca dos opcionais do usuario...						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Eval(bVldOpcPad)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera a matriz de faixas, por se tratar de um outro opcional...      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFaixas := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca as respectivas faixas etarias para este opcional e forma cob  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oPrepBZXA == nil
			cSQL := "SELECT BZX_IDAINI, BZX_IDAFIN, BZX_VALFAI, BZX_ANOMES, BZX_VLRANT, BZX_CODFAI "
			if BZX->(FieldPos("BZX_VLSLFN")) > 0 .and. BZX->(FieldPos("BZX_VLSLIN")) > 0
				cSQL += ", BZX_VLSLIN, BZX_VLSLFN "
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor da taxa da adesao...											³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVlrAde
				cSQl += ", BZX_VLRADE "
			EndIf

			cSQL += "FROM "+cNameBZX+" WHERE "
			cSQL += "BZX_FILIAL = ?  AND "
			cSQL += "BZX_CODOPE = ? AND "
			cSQL += "BZX_CODEMP = ? AND "
			cSQL += "BZX_MATRIC = ? AND "
			cSQL += "BZX_TIPREG = ? AND "
			cSQL += "BZX_CODOPC = ? AND "
			cSQL += "BZX_VEROPC = ? AND "
			cSQL += "BZX_CODFOR = ? AND "
			cSQL += "D_E_L_E_T_ = ' '"

			If lPLSFTBZX
				aRetPto := ExecBlock("PLSFTBZX",.F.,.F.,{cSQL})
				cSQL += aRetPto[1]
			EndIf

			oPrepBZXA:=FWPreparedStatement():New(cSQL)
		EndIf
		
		oPrepBZXA:SetString(1,cFilBZX)
		oPrepBZXA:SetString(2,cOpeFam)
		oPrepBZXA:SetString(3,cCodEmp)
		oPrepBZXA:SetString(4,cMatric)
		oPrepBZXA:SetString(5,(PLSOPCUSR)->BF4_TIPREG)
		oPrepBZXA:SetString(6,(PLSOPCUSR)->BF4_CODPRO)
		oPrepBZXA:SetString(7,(PLSOPCUSR)->BF4_VERSAO)
		oPrepBZXA:SetString(8,(PLSOPCUSR)->BYX_CODFOR)


		cSQL := oPrepBZXA:GetFixQuery()
		PLSBUSFAI := MpSysOpenQuery(cSQL)


		(PLSBUSFAI)->(DBEval( { | | AaDd(aFaixas, {BZX_IDAINI,;
												   BZX_IDAFIN,;
												   Round(BZX_VALFAI,2),;
											  	   BZX_ANOMES,;
											  	   Round(BZX_VLRANT,2),;
											  	   Iif(lVlrAde, Round(BZX_VLRADE,2), 0),;
											  	   Iif(FieldPos("BZX_VLSLIN") > 0,BZX_VLSLIN,0),;
											  	   Iif(FieldPos("BZX_VLSLFN") > 0,BZX_VLSLFN,0),BZX_CODFAI  }) }))
		(PLSBUSFAI)->(DbCloseArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no usuario atual, do opcional corrente...                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosUsr := Ascan(aUsuarios,{|x| x[1] == (PLSOPCUSR)->BF4_TIPREG })

		If nPosUsr > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se pode cobrar o opcional    do usuario.. vai existir casos³
			//³ em que so podera ser cobrado o fator moderador / custo do usuario.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !aUsuarios[nPosUsr][25]
				(PLSOPCUSR)->(DbSkip())
				Loop
			EndIf

            If lPLSBSIDA
               dDatBasIda := ExecBlock("PLSBSIDA",.F.,.F.,{"2",dDatBasIda,aUsuarios[nPosUsr],cMes,cAno,cMatricFam})
            EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula idade														³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nIdade 	:= Calc_Idade(dDatBasIda,aUsuarios[nPosUsr,2])
			nIdade	:= Iif(nIdade < 0,0,nIdade)

			if len(aUsuarios[nPosUsr]) >= 27
				nSalario    := aUsuarios[nPosUsr,27]
			EndIf
			cSexo       := aUsuarios[nPosUsr,5]
			cGrauPa     := aUsuarios[nPosUsr,6]
			cTipUsu     := aUsuarios[nPosUsr,7]
			cTipReg     := aUsuarios[nPosUsr,1]
			nValorFaixa := 0
			cNivelUtil  := "BZX"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca o valor da faixa de acordo com o usuario atual...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if cRdMake == "PLSPORFSL"
				nPos := Ascan(aFaixas, { |x| nSalario>=x[7] .And. nSalario<= x[8]})

				// Se não achar por faixa salarial, pesquisa por faixa etaria. Eh possivel parametrizar
				// opcional por faixa etaria mesmo calculando forma de cobranca por faixa salarial.
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| nIdade>=x[1] .And. nIdade<= x[2]})
				Endif

			else
				nPos := Ascan(aFaixas, { |x| nIdade>=x[1] .And. nIdade<= x[2]})
			EndIf

			If nPos > 0
				nValorFaixa := Iif((cAno+cMes>=aFaixas[nPos,4]), aFaixas[nPos,3], aFaixas[nPos,5])
				cFaixaUtil  := aFaixas[nPos,9]
                cCompRea	:= aFaixas[nPos,4]
                nValAtual	:= aFaixas[nPos,3]
                nValAnter	:= aFaixas[nPos,5]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ irei analisar agora a cobranca pro rata...                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aUsuarios[nPosUsr,16]

					nPercDias   := plRPerPR(aUsuarios[nPosUsr,14], nil, @nDiasUtil, Nil, PLDayVencCob(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))

					nValorRat   := Round((nValorFaixa*nPercDias)/100,2)
					nValorFaixa := nValorRat

				Else
					nValorRat   := 0
					nDiasUtil   := 0
				EndIf


				If lPLSDSCMN
					lDesconto := ExecBlock("PLSDSCMN", .F., .F., {_cNivel,_cChave,aUsuarios[nPosUsr]})
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica o desconto geral da familia...                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If BA3->( FieldPos("BA3_DESMEN") ) > 0 .And. BA3->BA3_DESMEN > 0 .And. lDesconto
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aramazena o valor original.											³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nValOri := nValorFaixa
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula e aplica o desconto ao valor da mensalidade.				³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nValorFaixa := Round(nValorFaixa-((nValorFaixa*BA3->BA3_DESMEN)/100),2)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Obtem o valor do desconto...										³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nValDes := (nValOri - nValorFaixa)
				EndIf

				lContCalc := .T.
				If lPLSDSCOP
					aDescEspc := ExecBlock("PLSDSCOP", .F., .F., {_cNivel,_cChave,aUsuarios[nPosUsr],;
																	cAno, cMes, dDatBasIda, (PLSOPCUSR)->REGBF4, (PLSOPCUSR)->BYX_CODFOR, nValorFaixa,;
																	cFaixaUtil,cTipUsu,cGraupa,aUsuarios,aValores,nPosUsr,nIdade,cNivelUtil,;
																	(PLSOPCUSR)->BI3_CODIGO,(PLSOPCUSR)->BI3_DESCRI,aFaixas,nValorRat,nDiasUtil,nPos,cCompRea,;
																	nValAtual,nValAnter,cTipEve,cCodEve})

					If Len(aDescEspc) > 0 .And. ((aDescEspc[1]+aDescEspc[2]) > 0) .And. aDescEspc[2] > 0
						nValorFaixa := aDescEspc[1]
						nValDes 	:= aDescEspc[2]
					EndIf

					If Len(aDescEspc) >= 4 .And. aDescEspc[3]
					   aValores := aClone(aDescEspc[4])
					EndIf

					If Len(aDescEspc) >= 5
   					   lContCalc := aDescEspc[5]
   					EndIf
				EndIf

				// Cobra o valor do opcional
				If lContCalc
				   AaDd(aValores,{ aUsuarios[nPosUsr,13],;		//01 Matricula do beneficiario
								   nValorFaixa,;				//02 Valor da faixa
								   Str(nIdade,3),;				//03 Idade
								   aUsuarios[nPosUsr,3],;		//04 Nome
								   aUsuarios[nPosUsr,5],;		//05
								   aUsuarios[nPosUsr,6],;		//06
								   aUsuarios[nPosUsr,4],;		//07
								   cFaixaUtil,;					//08 Codigo da faixa utilizada
								   cNivelUtil,;					//09 Tabela / Nivel da tabela 
								   aUsuarios[nPosUsr,7],;		//10 Tipo de usuario
								   (PLSOPCUSR)->BI3_CODIGO,;	//11 codigo do plano / produto
								   (PLSOPCUSR)->BI3_DESCRI,;	//12 descricao do plano / produto
								   aFaixas[nPos][1],;			//13 Idade inicial
								   aFaixas[nPos][2],;			//14 Idade final
								   nValorRat,;					//15 Valor pro rata
								   nDiasUtil,;					//16 Dias pro rata
								   aFaixas[nPos][3],;			//17 Valor da faixa
								   (PLSOPCUSR)->REGBF4,;		//18 recno BF4
								   nValDes,;					//19 valor de desconto
								   aUsuarios[nPosUsr,08],;  	//20 Plano do usuario
								   aUsuarios[nPosUsr,09],;	    //21 Descricao do plano
								   aUsuarios[nPosUsr,29],;	   	//22 Versao do plano
				                   cCompRea,;              		//23 Ano/Mes
				                   nValAtual,;             		//24 Valor Atual
				                   nValAnter,;             		//25 Valor Antigo
				                   cTipEve,;               		//26 Debito ou credito
				                   cCodEve,;					//27 codigo do lancamento
				                   "",;                   		//28 Cargo
								   aUsuarios[nPosUsr,31],;  	//29 Tipo de fornecedor
								   aFaixas[nPos][6]})		  	//30 Tipo de fornecedor
                EndIf

			EndIf
		EndIf
	EndIf
	(PLSOPCUSR)->(DbSkip())
Enddo

(PLSOPCUSR)->(DbCloseArea())

If lPlsVlrOp 
   aValores := ExecBlock("PLSVLROP",.F.,.F.,{aValores,cMatricFam,cAno,cMes})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aValores)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVALADE  ³ Autor ³ Tulio Cesar       ³ Data ³ 15.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Valoriza a taxa de adesao do plano, para uma familia       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
BJL - Forma de cobranca da taxa de adesao da familia
BRX - Faixas etarias dos valores de adesao da familia
/*/
Function PLSVALADE(cMatricFam,cAno,cMes,aUsuarios,aVlParcial,lOnlyLook)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aFaixas     := {}
LOCAL nFor
LOCAL aValores    := {}
LOCAL nValorFaixa
LOCAL nIdade
LOCAL cTipReg
LOCAL cSexo
LOCAL cGrauPa
LOCAL cTipUsu
LOCAL cFaixaUtil
LOCAL cNivelUtil
LOCAL dDatBasIda  := ctod("01/"+cMes+"/"+cAno)
LOCAL nPos
LOCAL nPosDes := 0
LOCAL nPosVal
LOCAL aOpcionais  := {}
LOCAL lEspecifico := .F.
LOCAL aEspecifico := {}

LOCAL cOpeFam     := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp     := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric     := Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL cDigito

LOCAL cSQL

LOCAL cFilBRX     := xFilial("BRX")
LOCAL cNameBRX    := BRX->(RetSQLName("BRX"))

LOCAL cFilBFZ     := xFilial("BFZ")
LOCAL cNameBFZ    := BFZ->(RetSQLName("BFZ"))
LOCAL lExistBFZ  := .F.

LOCAL aDescontos := {}
LOCAL nQtdFam 	 := 0

LOCAL nValOri	 := 0
LOCAL nValDes	 := 0
LOCAL nValAcre	 := 0
LOCAL aStruBRX   := BRX->(dbStruct())
LOCAL aStruBFZ   := {}
LOCAL nCntFor    := 0

DEFAULT aUsuarios := {}
DEFAULT lOnlyLook	  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso os usuarios nao tenham sido carregados carrega via rotina gen  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aUsuarios) == 0
   aUsuarios := PLSLOADUSR(cOpeFam,cCodEmp,cMatric,cAno,cMes,,lOnlyLook)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem a quantidade de pessoas da familia...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nQtdFam := Len(aUsuarios)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca as taxas de adesao desta familia...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If oPrepBRX == nil
	cSQL := "SELECT BRX_CODFOR, BRX_CODFAI, BRX_TIPUSR, BRX_GRAUPA, BRX_SEXO, BRX_IDAINI, BRX_IDAFIN, BRX_VLRADE, "
	cSQL += "BRX_PERADE, BRX_ANOMES, BRX_VLRANT FROM "+cNameBRX+" WHERE "
	cSQL += "BRX_FILIAL =  ?  AND "
	cSQL += "BRX_CODOPE =  ?  AND "
	cSQL += "BRX_CODEMP =  ?  AND "
	cSQL += "BRX_MATRIC =  ?  AND "
	cSQL += "D_E_L_E_T_ = ' '"

	oPrepBRX:=FWPreparedStatement():New(cSQL)

EndIF


nParamLin:=1
oPrepBRX:SetString(nParamLin,cFilBRX)
nParamLin++
oPrepBRX:SetString(nParamLin,cOpeFam)
nParamLin++
oPrepBRX:SetString(nParamLin,cCodEmp)
nParamLin++
oPrepBRX:SetString(nParamLin,cMatric)


cSQL := oPrepBRX:GetFixQuery()
PLSBUSFAI := MpSysOpenQuery(cSQL)


(PLSBUSFAI)->(DBEval( { | | aadd(aFaixas, {BRX_CODFAI,BRX_TIPUSR,BRX_GRAUPA,BRX_SEXO,BRX_IDAINI,BRX_IDAFIN,;
                                          BRX_VLRADE,BRX_PERADE,BRX_CODFOR,BRX_ANOMES,BRX_VLRANT}) }))
(PLSBUSFAI)->(DbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso haja desconto leio esses dados p a matriz a descontos...       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  BFZ->(MsSeek(xFilial("BFZ")+cMatricFam)) 
	lExistBFZ:= .T.
	cSQL := "SELECT BFZ_CODFAI, BFZ_TIPUSR, BFZ_GRAUPA, BFZ_QTDDE, BFZ_QTDATE, BFZ_TIPO, "
	cSQL += "BFZ_VALOR, BFZ_PERCEN  FROM "+cNameBFZ+" WHERE "
	cSQL += "BFZ_FILIAL = '"+cFilBFZ+"' AND "
	cSQL += "BFZ_CODOPE = '"+cOpeFam+"' AND "
	cSQL += "BFZ_CODEMP = '"+cCodEmp+"' AND "
	cSQL += "BFZ_MATRIC = '"+cMatric+"' AND "
	cSQL += "(BFZ_VALOR > 0 OR BFZ_PERCEN > 0) AND "
	cSQL += "D_E_L_E_T_ = ' '"
//  Como se trata de uma QUERY simples e que roda em todos os bancos dados não precisamos utilizar ChangeQuery assim ganhando performance
//	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSFAI",.F.,.T.)

	PLSBUSFAI->( DBEval( { | | aadd(aDescontos, {BFZ_CODFAI, BFZ_TIPUSR, BFZ_GRAUPA, BFZ_QTDDE, BFZ_QTDATE,;
				BFZ_TIPO, BFZ_VALOR, BFZ_PERCEN,'', ''})} ))

	PLSBUSFAI->(DbCloseArea())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mes subsequente, com conteudo = 2.									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLSBASI","1")=="2"
	dDatBasIda := dDatBasIda - 1
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a forma de cobranca da taxa de adesao para esta familia   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 To Len(aUsuarios)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se pode cobrar o opcional    do usuario.. vai existir casos³
	//³ em que so podera ser cobrado o fator moderador / custo do usuario.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aUsuarios[nFor,25]
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a taxa da adesao foi cobrada no ato						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aUsuarios[nFor,11] == '1'
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para analize especifica da cobranca de taxa de adesao.   ³
	//³ Exemplo, a taxa parcelada... 											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPLVALAD1
		aEspecifico := ExecBlock("PLVALAD1", .F., .F., {cOpeFam+cCodEmp+cMatric+aUsuarios[nFor,01], cAno, cMes})
		lEspecifico := aEspecifico[1]
	EndIf

	If aUsuarios[nFor,11] $ "0, " .Or. lEspecifico
		BJL->(DbSetOrder(1))
		If BJL->(MsSeek(xFilial("BJL")+cOpeFam+cCodEmp+cMatric+aUsuarios[nFor,10]))

			If BJL->BJL_CODFOR == "103"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Busca o valor da taxa de acordo com o usuario atual...              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If lPLSBSIDA
                   dDatBasIda := ExecBlock("PLSBSIDA",.F.,.F.,{"3",dDatBasIda,aUsuarios[nFor],cMes,cAno,cMatricFam})
                EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula idade														³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nIdade      := Calc_Idade(dDatBasIda,aUsuarios[nFor,2])
				nIdade		:= Iif(nIdade < 0,0,nIdade)
				cSexo       := aUsuarios[nFor,5]
				cGrauPa     := aUsuarios[nFor,6]
				cTipUsu     := aUsuarios[nFor,7]
				cTipReg     := aUsuarios[nFor,1]
				cDigito     := aUsuarios[nFor,12]
				nPos        := 0
				nValorFaixa := 0
				cNivelUtil  := "BRX"
				cFaixaUtil  := ""
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chaves                                                              ³
				//³                                                                     ³
				//³ SEXO, GRAU DE PARANTESCO E TIPO DE USUARIO...                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| x[2]==cTipUsu .And. x[4]==cSexo .And. cGraupa==x[3] .And. ;
					                             nIdade>=x[5] .And. nIdade<= x[6] .And. x[9] == BJL->BJL_CODFOR })
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chaves                                                              ³
				//³                                                                     ³
				//³ TIPO DE USUARIO E GRAU DE PARANTESCO...                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| x[2]==cTipUsu .And. cGraupa==x[3] .And. x[4] $ "3, " .And. ;
					                             nIdade>=x[5] .And. nIdade<= x[6] .And. x[9] == BJL->BJL_CODFOR })
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chaves                                                              ³
				//³                                                                     ³
				//³ TIPO DE USUARIO E SEXO...                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| x[2]==cTipUsu .And. x[4]==cSexo .And. Empty(x[3])  .And. ;
					                             nIdade>=x[5] .And. nIdade<= x[6] .And. x[9] == BJL->BJL_CODFOR })
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chaves                                                              ³
				//³                                                                     ³
				//³ GRAU DE PARENTESCO E SEXO...                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| cGraupa==x[3] .And. x[4]==cSexo .And. Empty(x[2]) .And. ;
					                             nIdade>=x[5] .And. nIdade<= x[6] .And. x[9] == BJL->BJL_CODFOR })
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chaves                                                              ³
				//³                                                                     ³
				//³ TIPO DE USUARIO SOZINHO...                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| x[2]==cTipUsu .And. empty(x[3]) .And. x[4] $ "3, " .And. ;
					                             nIdade >= x[5] .And. nIdade <=x[6] .And. x[9] == BJL->BJL_CODFOR })
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chaves                                                              ³
				//³                                                                     ³
				//³ SEXO SOZINHO...                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| x[4]== cSexo .And. Empty(x[2]) .And. empty(x[3]) .And. ;
					                             nIdade >= x[5] .And. nIdade <=x[6] .And. x[9] == BJL->BJL_CODFOR })
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chaves                                                              ³
				//³                                                                     ³
				//³ GRAU DE PARENTESCO SOZINHO...                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| cGraupa==x[3] .And. x[4] $ "3, " .And. Empty(x[2]) .And.  ;
					                             nIdade >= x[5] .And. nIdade <=x[6] .And. x[9] == BJL->BJL_CODFOR })
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chaves                                                              ³
				//³                                                                     ³
				//³ TODAS EM BRANCAS...                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos == 0
					nPos := Ascan(aFaixas, { |x| Empty(x[3]) .And. x[4] $ "3, " .And. Empty(x[2]) .And. ;
					                             nIdade >= x[5] .And. nIdade <=x[6] .And. x[9] == BJL->BJL_CODFOR })
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se foi localizada o valor busca os mesmos...                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o codigo da faixa da taxa de adesao...                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cFaixaUtil  := aFaixas[nPos,1]

					If     aFaixas[nPos,7] > 0
						nValorFaixa += Iif((cAno+cMes >= aFaixas[nPos,10]), aFaixas[nPos,7], aFaixas[nPos,11])
					ElseIf aFaixas[nPos,8] > 0
						nPosVal := Ascan(aVlParcial,{|x| x[3] = "101" .And. x[7] ==cOpeFam+cCodEmp+cMatric+cTipReg+cDigito})
						If nPosVal > 0
							nValorFaixa += Round((aVlParcial[nPosVal,2]*aFaixas[nPos,8])/100,2)
						EndIf

					EndIf
			 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso haja desconto realiza o calculo desses descontos...            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lExistBFZ
						nPosDes := Ascan(aDescontos,{ |x| x[1] == cFaixaUtil .and.;
							nQtdFam >= x[4] .and. nQtdFam <= x[5] })

						If nPosDes > 0
							If     aDescontos[nPosDes,6] == "1" //Desconto
								If     aDescontos[nPosDes,8] > 0 // Desconto em Percentual
									// Grava o valor original...
									nValOri := nValorFaixa

									// Calcula e aplica o desconto...
									nValorFaixa := Round(nValorFaixa-((nValorFaixa*aDescontos[nPosDes,8])/100),2)

									// Obtem o valor do desconto...
									nValDes := (nValOri-nValorFaixa)

								ElseIf aDescontos[nPosDes,7] > 0 // Desconto em Valor
									// Obtem o valor do desconto...
									nValDes := aDescontos[nPosDes,7]

									// Calcula e aplica o desconto...
									nValorFaixa := nValorFaixa-aDescontos[nPosDes,7]
								EndIf

							ElseIf aDescontos[nPosDes,6] == "2" //Acrescimo
								If     aDescontos[nPosDes,8] > 0 // Acrescimo em Percentual
									// Grava o valor original...
									nValOri := nValorFaixa

									// Calcula e aplica o desconto...
									nValorFaixa := Round(nValorFaixa+((nValorFaixa*aDescontos[nPosDes,8])/100),2)

									// Obtem o valor do acrescimo...
									nValAcre := (nValorFaixa-nValOri)

								ElseIf aDescontos[nPosDes,7] > 0 // Acrescimo em Valor
									nValAcre := aDescontos[nPosDes,7]

									nValorFaixa := nValorFaixa+aDescontos[nPosDes,7]
								EndIf
							EndIf
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada para calculo especifico do valor da taxa de adesao.³
					//³ Exemplo, a taxa parcelada...										³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lPLVALAD2
						nValorFaixa := ExecBlock("PLVALAD2", .F., .F., {cOpeFam+cCodEmp+cMatric+aUsuarios[nFor,01], nValorFaixa, aEspecifico})
						If Valtype(nValorFaixa) == 'N'
							nValorFaixa := Round(nValorFaixa, 2)
						EndIf
					EndIf

					AaDd(aValores,{aUsuarios[nFor,13],;	//01
									nValorFaixa,;			//02
									Str(nIdade,3),;			//03
									aUsuarios[nFor,3],;		//04
									aUsuarios[nFor,5],;		//05
									aUsuarios[nFor,6],;		//06
									aUsuarios[nFor,4],;		//07
									cFaixaUtil,;			//08
									cNivelUtil,;			//09
									aUsuarios[nFor,7],;		//10
									aUsuarios[nFor,8],;		//11
									aUsuarios[nFor,9],;		//12
									aFaixas[nPos][5],;		//13
									aFaixas[nPos][6],;		//14
									nValDes,;				//15
									nValAcre,;				//16
									aUsuarios[nFor,29],;	//17
									aUsuarios[nFor,31]})	//18
				EndIf
			EndIf
		EndIf
	EndIf
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aValores)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSSLDDCF  ³ Autor ³ Tulio Cesar       ³ Data ³ 16.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o Saldo de Debitos e Creditos p faturamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Geraldo Jr. ³        ³      ³ Desmembramento dos deb/cred em servicos  ³±±
±±³            ³        ³      ³ medicos/acessorios...                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSSLDDCF(cMatricFam,cAno,cMes,aUsuarios,cCodLan,lOnlyLook,cNivel,cChave,cNumCob,lConsNiv)
LOCAL nFor          := 0
LOCAL cOpeFam  		:= Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp  		:= Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric  		:= Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL cFilBSQ  		:= xFilial("BSQ")
LOCAL cNameBSQ 		:= BSQ->(RetSQLName("BSQ"))
LOCAL cFilBSP  		:= xFilial("BSP")
LOCAL cNameBSP 		:= BSP->(RetSQLName("BSP"))
LOCAL cSQL          := ''
LOCAL cCodPla 		:= ''
LOCAL cDesPla 		:= ''
LOCAL cVerPla 		:= ''
LOCAL cCodEve 		:= ''
LOCAL cDesEve  		:= ''
LOCAL cTipoUsu 		:= ''
LOCAL cTpForn 		:= ''
LOCAL nCntFor   	:= 0
LOCAL nRegSX3   	:= 0
LOCAL nOrdSX3   	:= 0
LOCAL aStruct   	:= {}
LOCAL aValores 		:= {}
LOCAL lBSQCODPRO	:= BSQ->(FieldPos("BSQ_CODPRO")) > 0 .And. BSQ->(FieldPos("BSQ_CODOPC")) > 0
LOCAL cPLCdTit      := GetNewPar("MV_PLCDTIT","")
LOCAL vConsad := "C" 
LOCAL cConsad := "1"
LOCAL cFunNa        := FunName()
LOCAL lConSad       := BDC->( FieldPos('BDC_CONSAD') ) > 0

DEFAULT lOnlyLook 	:= .F.
DEFAULT cNivel  	:= ''
DEFAULT cChave		:= ''
DEFAULT aUsuarios   := {}
DEFAULT cNumCob		:= ""
DEFAULT lConsNiv	:= .T.

If !Empty(M->BDC_CONSAD)
	vConsad := ValType(M->BDC_CONSAD) 
	cConsad := M->BDC_CONSAD
EndIf
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Verifico se preciso refazer a QAuery

If oPrepBSQ <> nil
	nParamLin:=3
	If cPaisLOC == 'BRA' .Or. lOnlyLook
		If cNivel == '2'
			nParamLin:= nParamLin +2
		ElseIf cNivel == '3'

			nParamLin:= nParamLin +5
		ElseIf cNivel $ '4,5'
			nParamLin++
		Endif

		If cFunNa $ 'PLSA174, PLSA730' .And. cNivel $ '1,2,3' //chamado SCTML7
			nParamLin++
		Endif

	Else
		nParamLin++
	Endif
	nParamLin:= nParamLin + 4
	If Len(oPrepBSQ:Avalues) <> nParamLin
		oPrepBSQ := nil
	Endif
Endif


If oPrepBSQ == nil
	cSQL := "SELECT BSQ_USUARI,BSQ_VALOR,BSQ_CODLAN, BSQ_TIPO, BSP_DESCRI,BSP_TIPSER, BSP_CODLAN, BSP_CODSER, "

	If lBSQCODPRO
	cSQL += "BSQ_CODPRO, BSQ_CODOPC, "
	EndIf

	cSQL += "BSQ_CODSEQ, "+cNameBSQ+".R_E_C_N_O_, BSQ_NUMCOB FROM "+cNameBSQ+","+cNameBSP+" WHERE "
	cSQL += "BSQ_FILIAL = ? AND "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aqui e o nivel 1 como estes campos estao em todas as chaves nao precisa checar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL += "BSQ_CODINT = ?  AND "
	cSQL += "BSQ_CODEMP = ?  AND "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Conforme o conforme o nivel											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLOC == 'BRA' .Or. lOnlyLook

		If cNivel == '2'
			cSql += "BSQ_CONEMP = ?	AND "
			cSql += "BSQ_VERCON = ?	AND "
			cSql += "BSQ_COBNIV = '2' AND "
			If cFunNa $ "PLSA174" .And. lConsNiv

				cSql += "BSQ_USUARI = ' ' AND "
			EndIf

		ElseIf cNivel == '3'
			
			cSql += "BSQ_CONEMP = ?	AND "
			cSql += "BSQ_VERCON = ? AND "
			cSql += "BSQ_SUBCON = ? AND "
			cSql += "BSQ_VERSUB = ?	AND "
			cSql += "BSQ_COBNIV = '3' AND "

			If cFunNa == "PLSR256" .And. lConsNiv
				cSql += "BSQ_MATRIC = ?	AND "
			Else
				cSql += "(BSQ_MATRIC = ?  OR "
				cSql += " BSQ_MATRIC = ' ') AND "
			EndIf

		ElseIf cNivel $ '4,5'
			cSql += "BSQ_MATRIC = ? 	AND "
			cSQL += "(BSQ_COBNIV = '4' Or BSQ_COBNIV = '5') AND "
		EndIf

		//Tratamento do extrato do valor de cobranca no nivel da familia.
		If cFunNa $ 'PLSA174, PLSA730' .And. cNivel $ '1,2,3' //chamado SCTML7
			cSql += "BSQ_MATRIC = ?  AND "
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando e diferente de BRA sempre tem que entrar aqui pq o campo de matricula e obrigatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		cSql += "BSQ_MATRIC = ?  AND "
		cSQL += "(BSQ_COBNIV = '4' Or BSQ_COBNIV = '5') AND "
	EndIf

	cSQL += "((BSQ_ANO <= ?  AND "
	cSQL += "BSQ_MES <= ? ) OR "
	cSQL += "BSQ_ANO < ? ) AND "
	cSQL += "BSP_FILIAL = ?  AND "
	cSQL += "BSP_CODSER = BSQ_CODLAN    AND "
	cSQL += "BSQ_PREFIX = ' ' AND "
	cSQL += "BSQ_NUMTIT = ' ' AND "
	cSQL += "BSQ_PARCEL = ' ' AND "
	cSQL += "BSQ_TIPTIT = ' ' AND BSQ_NUMCOB = ' ' AND "
	cSQL += cNameBSQ + ".D_E_L_E_T_ = ' ' AND "
	cSQL += cNameBSP + ".D_E_L_E_T_ = ' '"

	If lPlsDcFat
		cSQL += Execblock("PLSDCFAT",.f.,.f.,{cCodLan})
	EndIf

	oPrepBSQ:=FWPreparedStatement():New(cSQL)

EndIF


nParamLin:=1
oPrepBSQ:SetString(nParamLin,cFilBSQ)
nParamLin++
oPrepBSQ:SetString(nParamLin,cOpeFam)
nParamLin++
oPrepBSQ:SetString(nParamLin,cCodEmp)
If cPaisLOC == 'BRA' .Or. lOnlyLook
	If cNivel == '2'
		nParamLin++
		oPrepBSQ:SetString(nParamLin,Substr(cChave,09, 12))
		nParamLin++
		oPrepBSQ:SetString(nParamLin,Substr(cChave,21, 03))
	ElseIf cNivel == '3'

		nParamLin++
		oPrepBSQ:SetString(nParamLin,Substr(cChave,09, 12))
		nParamLin++
		oPrepBSQ:SetString(nParamLin,Substr(cChave,21, 03))
		nParamLin++
		oPrepBSQ:SetString(nParamLin,Substr(cChave,24, 09))
		nParamLin++
		oPrepBSQ:SetString(nParamLin,Substr(cChave,33, 03))
		nParamLin++
		oPrepBSQ:SetString(nParamLin,cMatric)

	ElseIf cNivel $ '4,5'
		nParamLin++
		oPrepBSQ:SetString(nParamLin,cMatric)
	Endif

	If cFunNa $ 'PLSA174, PLSA730' .And. cNivel $ '1,2,3' //chamado SCTML7
		nParamLin++
		oPrepBSQ:SetString(nParamLin,cMatric)
	Endif

Else
	nParamLin++
	oPrepBSQ:SetString(nParamLin,cMatric)
Endif
nParamLin++
oPrepBSQ:SetString(nParamLin,cAno)
nParamLin++
oPrepBSQ:SetString(nParamLin,cMes)
nParamLin++
oPrepBSQ:SetString(nParamLin,cAno)
nParamLin++
oPrepBSQ:SetString(nParamLin,cFilBSP)

cSQL := oPrepBSQ:GetFixQuery()
PLSSLDDCF := MpSysOpenQuery(cSQL)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ While																		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ! (PLSSLDDCF)->( Eof() )

	If lPLSFILDC
		lSkip := ExecBlock("PLSFILDC",.F.,.F.,{(PLSSLDDCF)->BSQ_CODLAN,(PLSSLDDCF)->BSQ_USUARI,(PLSSLDDCF)->R_E_C_N_O_})
		If lSkip
			(PLSSLDDCF)->(dbSkip())
			Loop
		EndIf
	EndIf
	If (!lConsNiv .And. Empty((PLSSLDDCF)->BSQ_USUARI) .And. cNivel < '4')
		(PLSSLDDCF)->(dbSkip())
		Loop
	EndIf
	If cNivel=='2' .and. !Empty((PLSSLDDCF)->BSQ_USUARI) .and. Substr((PLSSLDDCF)->BSQ_USUARI,1,14)<> alltrim(cMatricfam)
		(PLSSLDDCF)->(dbSkip())
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para que considere (posicione) no usuario do BSQ.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aUsuarios) == 0 .Or. !Empty((PLSSLDDCF)->BSQ_USUARI)
		aUsuarios := PLSLOADUSR(cOpeFam,cCodEmp,Substr((PLSSLDDCF)->BSQ_USUARI,9,6),cAno,cMes, Substr((PLSSLDDCF)->BSQ_USUARI,15,2))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Usuarios da familia															  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aUsuarios) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura o usuario															  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty((PLSSLDDCF)->BSQ_USUARI) .Or. ( nPos := Ascan(aUsuarios,{|x| x[13] == (PLSSLDDCF)->BSQ_USUARI}) ) == 0
			nPos := Ascan(aUsuarios, {|x| x[7] == cPLCdTit})
			If nPos > 0
				cMat	:= aUsuarios[nPos,13]
				cNomUsr := aUsuarios[nPos,3]
				cTipoUsu := aUsuarios[nPos,7]
				cTpForn  := aUsuarios[nPos,31]
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados do lancamento															  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPos > 0
			cMat	:= aUsuarios[nPos,13]
			cNomUsr := aUsuarios[nPos,3]
			cTipoUsu := aUsuarios[nPos,7]
			cTpForn  := aUsuarios[nPos,31]
			If !lBSQCODPRO
			   cCodPla := aUsuarios[nPos,08]
			   cDesPla := aUsuarios[nPos,09]
			Else
			   cCodPla := (PLSSLDDCF)->BSQ_CODPRO
			   If BI3->(BI3_CODINT+BI3_CODIGO) == cOpeFam+cCodPla
			      cDesPla := BI3->BI3_DESCRI
			   Else
			      cDesPla := BI3->(Posicione("BI3",1,xFilial("BI3")+cOpeFam+cCodPla,"BI3_DESCRI"))
			   EndIf
			   cCodEve := (PLSSLDDCF)->BSQ_CODOPC
			   cDesEve := BI3->(Posicione("BI3",1,xFilial("BI3")+cOpeFam+cCodEve,"BI3_DESCRI"))
			   If Empty(cCodEve)
			   		cCodEve := cCodPla
			   		cDesEve := cDesPla
			   Endif
			EndIf
			cVerPla := aUsuarios[nPos,29]
		EndIf
	Else
		nPos	:= 1
		cMat	:= cChave
		cNomUsr := 'NIVEL DE COBRANCA'
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Matriz de retorno															  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPos > 0      
		If lConSad .and. !IsInCallStack("PLSA260VCB") .and. !IsInCallStack("PLSVLRCOB") // determina se os debitos e creditos da BSQ irão entrar na cobrança corrente			
			
			If vConsad == "C"	.And.  cConsad $ "1, "			

				AaDd(aValores,{ cMat,;					//01
								cNomUsr,;					//02
								(PLSSLDDCF)->BSP_CODSER,;	//03
								(PLSSLDDCF)->BSP_DESCRI,;	//04
								(PLSSLDDCF)->BSP_TIPSER,;	//05
								(PLSSLDDCF)->BSQ_VALOR ,;	//06
								(PLSSLDDCF)->BSQ_CODSEQ,;	//07
								(PLSSLDDCF)->R_E_C_N_O_,;	//08
								(PLSSLDDCF)->BSQ_CODSEQ,;	//09
								(PLSSLDDCF)->BSP_CODLAN,;	//10
								cCodPla,;				//11
								cDesPla,;				//12
								cVerPla,;				//13
								cCodEve,;				//14
								cDesEve,;				//15
								cTipoUsu,;				//16
								cTpForn }) // 17
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o lancamento para que nao seja cobrando novamente					  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If !Empty(cNumCob)
					BSQ->( DbGoto((PLSSLDDCF)->R_E_C_N_O_) )
					BSQ->( RecLock("BSQ",.F.) )
					BSQ->BSQ_NUMCOB := Subs(cChave,1,4)+cNumCob
					BSQ->( MsUnLock() )

					//Inclui o recno do débito/crédito para alterar após gerar o lote para não gerar inconsistência. 
					AADD(_aRecBSQ, (PLSSLDDCF)->R_E_C_N_O_) 
				EndIf
			Endif
	
		Else
			AaDd(aValores,{ cMat,;					//01
							cNomUsr,;				//02
							(PLSSLDDCF)->BSP_CODSER,;	//03
							(PLSSLDDCF)->BSP_DESCRI,;	//04
							(PLSSLDDCF)->BSP_TIPSER,;	//05
							(PLSSLDDCF)->BSQ_VALOR ,;	//06
							(PLSSLDDCF)->BSQ_CODSEQ,;	//07
							(PLSSLDDCF)->R_E_C_N_O_,;	//08
							(PLSSLDDCF)->BSQ_CODSEQ,;	//09
							(PLSSLDDCF)->BSP_CODLAN,;	//10
							cCodPla,;				//11
							cDesPla,;				//12
							cVerPla,;				//13
							cCodEve,;				//14
							cDesEve,;				//15
							cTipoUsu,;				//16
							cTpForn }) // 17
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o lancamento para que nao seja cobrando novamente					  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If !Empty(cNumCob)
				BSQ->( DbGoto((PLSSLDDCF)->R_E_C_N_O_) )
				BSQ->( RecLock("BSQ",.F.) )
				BSQ->BSQ_NUMCOB := Subs(cChave,1,4)+cNumCob
				BSQ->( MsUnLock() )

				//Inclui o recno do débito/crédito para alterar após gerar o lote para não gerar inconsistência. 
				AADD(_aRecBSQ, (PLSSLDDCF)->R_E_C_N_O_) 
			EndIf
	
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ RdMake																		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPLSBSQES
	   aValores := ExecBlock("PLSBSQES",.F.,.F.,{aValores,cOpeFam})
	EndIf

	(PLSSLDDCF)->( DbSkip() )
EndDo

(PLSSLDDCF)->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao																  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aValores)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSRETAGR  ³ Autor ³ Tulio Cesar       ³ Data ³ 16.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o Valor do Agravo de um Usuario...                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRETAGR(cMatricFam,cAno,cMes,aUsuarios,aVlParcial)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSQL
LOCAL nFor
LOCAL cFilBF3  := xFilial("BF3")
LOCAL cNameBF3 := BF3->(RetSQLName("BF3"))
LOCAL aAgravos := {}
LOCAL nPos
LOCAL dDatInc
LOCAL dDatLim
LOCAL cOpeFam  := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp  := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric  := Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL lField   := BF3->(FieldPos("BF3_PERAGR")) > 0
LOCAL nPosVal
LOCAL nValorAgr:= 0
LOCAL nCntFor  := 0
LOCAL aStruBF3 := {}

DEFAULT aVlParcial := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca os pagamentos de agravo para esta familia...                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If oPrepBF3 = nil
	cSQL := "SELECT BF3_TIPREG, BF3_VALAGR, BF3_MESAGR "

	If lField
	cSQL += ", BF3_PERAGR "
	EndIf

	cSQL += "FROM "+cNameBF3+" WHERE "
	cSQL += "BF3_FILIAL = ?	AND "
	cSQL += "BF3_CODINT = ?	AND "
	cSQL += "BF3_CODEMP = ?	AND "
	cSQL += "BF3_MATRIC = ?	AND "
	cSQL += "BF3_PAGAGR = '1' AND "
	cSQL += "D_E_L_E_T_ = ' '"

	oPrepBF3:=FWPreparedStatement():New(cSQL)

Endif

nParamLin:=1
oPrepBF3:SetString(nParamLin,cFilBF3)
nParamLin++
oPrepBF3:SetString(nParamLin,cOpeFam)
nParamLin++
oPrepBF3:SetString(nParamLin,cCodEmp)
nParamLin++
oPrepBF3:SetString(nParamLin,cMatric)



cSQL := oPrepBF3:GetFixQuery()
PLSRETAGR := MpSysOpenQuery(cSQL)


While ! (PLSRETAGR)->(Eof())

      nValorAgr   := 0
      nPos        := Ascan(aUsuarios,{|x| x[1] == (PLSRETAGR)->BF3_TIPREG})
      If nPos > 0
 		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Verifica se pode cobrar o opcional    do usuario.. vai existir casos³
		 //³ em que so podera ser cobrado o fator moderador / custo do usuario.  ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 If !aUsuarios[nPos][25]
		 	(PLSRETAGR)->( dbSkip() )
		 	Loop
		 EndIf

         dDatInc := aUsuarios[nPos,14]
         dDatLim := dDatInc+(30*(PLSRETAGR)->BF3_MESAGR)
         If cAno+cMes <= subs(dtos(dDatLim),1,6)

            If lField .And. (PLSRETAGR)->BF3_PERAGR > 0
               nPosVal := Ascan(aVlParcial,{|x| x[3] = "101" .And. x[7] ==cOpeFam+cCodEmp+cMatric+(PLSRETAGR)->BF3_TIPREG+aUsuarios[nPos,12]})
               If nPosVal > 0
                  nValorAgr := Round((aVlParcial[nPosVal,2]*(PLSRETAGR)->BF3_PERAGR)/100,2)
               EndIf
            Else
               nValorAgr := (PLSRETAGR)->BF3_VALAGR
            EndIf

            AaDd(aAgravos,{nValorAgr,;			//01
                           aUsuarios[nPos,13],;//02
                           aUsuarios[nPos,03],;//03
                           aUsuarios[nPos,08],;//04
                           aUsuarios[nPos,09],;//05
                           aUsuarios[nPos,29],;//06
                           aUsuarios[nPos,07],; //07
                           aUsuarios[nPos,31]}) //08
         EndIf
      EndIf

(PLSRETAGR)->(DbSkip())
Enddo
(PLSRETAGR)->(DbCloseArea())

Return(aAgravos)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLR2BOL ³ Autor ³ Tulio Cesar       ³ Data ³ 17.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o Valor da segunda via de boleto de uma familia... ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLR2BOL(cMatricFam)
LOCAL nValor2Bol := 0
LOCAL nOrdBI3    := BI3->(IndexOrd())
LOCAL nRecBI3    := BI3->(Recno())
LOCAL nOrdBQC    := BQC->(IndexOrd())
LOCAL nRecBQC    := BQC->(Recno())
LOCAL nOrdBA0    := BA0->(IndexOrd())
LOCAL nRecBA0    := BA0->(Recno())
LOCAL bRest      := { || BI3->(DbSetOrder(nOrdBI3)), BI3->(DbGoTo(nRecBI3)), ;
                         BQC->(DbSetOrder(nOrdBQC)), BQC->(DbGoTo(nRecBQC)), ;
                         BA0->(DbSetOrder(nOrdBA0)), BA0->(DbGoTo(nRecBA0)) }
BA3->(DbSetOrder(1))
If BA3->(MsSeek(xFilial("BA3")+cMatricFam))
   If BA3->BA3_TIPOUS == "1" //PF
      BI3->(DbSetorder(1))
      If BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO))) .And. BI3->BI3_VL2BOL > 0
         nValor2Bol := BI3->BI3_VL2BOL
      EndIf
   Else //PJ
      BQC->(DbSetOrder(1))
      If BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB))) .And. ;
         BQC->BQC_VL2BOL > 0
         nValor2Bol := BQC->BQC_VL2BOL
      EndIf
   EndIf
EndIf

If nValor2Bol == 0 .And. BA3->(Found())
   BA0->(DbSetOrder(1))
   If BA0->(MsSeek(xFilial("BA0")+BA3->BA3_CODINT))
      nValor2Bol := BA0->BA0_VL2BOL
   EndIf
EndIf

Return(nValor2Bol)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSUPT2BOL ³ Autor ³ Tulio Cesar       ³ Data ³ 17.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Atualiza um lancamento de cobranca de 2 via de boleto.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSUPT2BOL(cMatric,dData,nVia, lFatur)
LOCAL   nValor := PLSVLR2BOL(cMatric)
DEFAULT dData  := dDataBase
DEFAULT nVia   := 2
DEFAULT lFatur := .F.

If nValor > 0
   BEE->(RecLock("BEE",.T.))
   BEE->BEE_FILIAL := xFilial("BEE")
   BEE->BEE_CODINT := Subs(cMatric,atCodOpe[1],atCodOpe[2])
   BEE->BEE_CODEMP := Subs(cMatric,atCodEmp[1],atCodEmp[2])
   BEE->BEE_MATRIC := Subs(cMatric,atMatric[1],atMatric[2])
   BEE->BEE_VIABOL := nVia
   BEE->BEE_DTSOLI := dData
   BEE->BEE_ANMSFT := ""
   BEE->BEE_FATUR  := Iif(!lFatur,"0","1")
   BEE->BEE_VALOR  := nValor
   BEE->(MsUnLock())
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRCIDU ³ Autor ³ Tulio Cesar       ³ Data ³ 22.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o valor de via de cartao magnetico                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRCIDU(cMatricFam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nValor    := 0
LOCAL aRetorno := {}
LOCAL nPos:=0
LOCAL nPosEve:=0
LOCAL cDescri:=""
LOCAL cDebCre :="" 
   		  
BED->(DbSetOrder(1))
If BED->(MsSeek(xFilial("BED")+cMatricFam))
	While ! BED->(Eof()) .And. BED->(BED_FILIAL+BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO) == ;
		xFilial("BED")+cMatricFam

		If BPX->(Dbseek(xfilial('BPX')+BED->BED_CODINT+BED->BED_MOTIVO)).AND. !EMPTY(BPX->BPX_TIPLAN )
		 	cTpLanc := BPX->BPX_TIPLAN  
		else
			cTpLanc :='107'
		Endif
		
		If BED->BED_COBRAR == "1" .And. BED->BED_VALOR > 0 .and. empty(BED->BED_NUMTIT)
   		  nPos:=Ascan(aRetorno,{|x| AllTrim(x[1]) == cTplanc}) //TES
   		  
   		  
   		  If nPos >0
   		  
   		  	aRetorno[nPos,2]+=BED->BED_VALOR
   		  
   		  Else
   		   	
   		   	aadd(aRetorno,{cTplanc,BED->BED_VALOR})
   	
	   	  Endif  
   		EndIf

		BED->(DbSkip())
	Enddo
EndIf

Return(aRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVJURFAM ³ Autor ³ Tulio Cesar       ³ Data ³ 22.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna o valor ou % de juros para gravar no titulo        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVJURFAM(cMatricFam, _cNivel, cTipo)
LOCAL nOrdBI3 := BI3->(IndexOrd())
LOCAL nRecBI3 := BI3->(Recno())
LOCAL nOrdBT6 := BT6->(IndexOrd())
LOCAL nRecBT6 := BT6->(Recno())
LOCAL nJuros  := 0
LOCAL nTaxa   := 0
LOCAL lJuros  := .F.
LOCAL bRest      := { || BT6->(DbSetOrder(nOrdBT6)), BT6->(DbGoTo(nRecBT6)),;
                         BI3->(DbSetOrder(nOrdBI3)), BI3->(DbGoTo(nRecBI3)) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida familia...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC) == cMatricFam
   BA3->(DbSetOrder(1))
   BA3->(MsSeek(xFilial("BA3")+cMatricFam))
EndIf

Default cTipo := BA3->BA3_TIPOUS
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa pessoa fisica...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "1"
	BI3->(DbSetOrder(1))
	If BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
		lJuros := BI3->BI3_COBJUR == "1"
		nJuros := BI3->BI3_JURDIA
		nTaxa  := BI3->BI3_TAXDIA
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa pessoa juridica...                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _cNivel == '1' // Empresa...
		If BG9->( FieldPos("BG9_COBJUR") ) > 0
			lJuros := BG9->BG9_COBJUR == '1'
			nJuros := BG9->BG9_JURDIA
			nTaxa  := BG9->BG9_TAXDIA
		EndIf

	Elseif _cNivel == '2' // Contrato...
		If BT5->( FieldPos("BT5_COBJUR") ) > 0
			lJuros := BT5->BT5_COBJUR == '1'
			nJuros := BT5->BT5_JURDIA
			nTaxa  := BT5->BT5_TAXDIA
		EndIf

	Elseif _cNivel == '3'  // Sub contrato...
		If BQC->( FieldPos("BQC_COBJUR") ) > 0
			lJuros := BQC->BQC_COBJUR == '1'
			nJuros := BQC->BQC_JURDIA
			nTaxa  := BQC->BQC_TAXDIA
		EndIf
	Elseif _cNivel == '4'  // Familia...
		BT6->(DbSetOrder(1))
		If BT6->(MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)))
			lJuros := BT6->BT6_COBJUR == "1"
			nJuros := BT6->BT6_JURDIA
			nTaxa  := BT6->BT6_TAXDIA
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bRest)

Return({lJuros,nJuros,nTaxa})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVCALJUR ³ Autor ³ Tulio Cesar       ³ Data ³ 22.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna para a rotina generica de cobranca o valor do      ³±±
±±³          ³ juros que deve ser cobrado no proximo mes.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVCALJUR(cMatricFam)
LOCAL nValorJuros := 0
Return(nValorJuros)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCOBRETM ³ Autor ³ Tulio Cesar       ³ Data ³ 22.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Cobranca retroativa ou pro rata de mensalidade             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSCOBRETM(cMatricFam,aUsuarios,cAno,cMes,aVlParcial,lExistBFY,lExistBDQ)
local nFor			:= 0
local nPosVal		:= 0
local nValorMens	:= 0
local nValProRat	:= 0
local nPercDias		:= 0
local nValDes		:= 0
local nValAcre		:= 0
local nQtdMes		:= 0
local cAnoMesAnt 	:= ""
local cProdJaCalc	:= ""
local cTipReg		:= ""
local cDigito		:= ""
local cTPLanRet		:= getNewPar("MV_PLSCDCB","101")
local cOpeFam		:= subs(cMatricFam,atCodOpe[1],atCodOpe[2])
local cCodEmp		:= subs(cMatricFam,atCodEmp[1],atCodEmp[2])
local cMatric		:= subs(cMatricFam,atMatric[1],atMatric[2])
local dDatBasIda	:= ctod("01/"+cMes+"/"+cAno)
local dDatBasInc	:= ctod("01/"+cMes+"/"+cAno)
local dDatInc		:= ctod('')
local dDatAux1		:= ctod('')
local dDatAux2		:= ctod('')
local aEvent101		:= {}
local aVlParUsr		:= {}
local aRetFun		:= {}
local nForMens		:= {}
local lMvPlsDBM1	:= getNewPar("MV_PLSDBM1","0") == "1" // Define quando houver desconto ou acrécimo configu_rado pela tabela BFY ou BDQ, o sistema gera novo registro á parte na BM1 relacionado. (1=Gera BM1)
local lCobRet 		:= .f.
local lCobRat 		:= .f.

private nDiasUtil	:= 0

default lExistBFY  	:= .f.
default lExistBDQ  	:= .f.

if lPlsVlrFam 
   aVlParcial := execBlock("PLSVLRFAM", .f., .f., { aVlParcial, cMatricFam, cAno, cMes } )
endIf

//Considera mudanca de Idade no Mes subsequente, com conteudo = 2.   
if getNewPar("MV_PLSBASI","1") == "2"
	dDatBasIda := dDatBasIda - 1
endIf

//Usuarios															
for nFor := 1 to Len(aUsuarios)

	//Verifica se pode cobrar o opcional do usuario.. vai existir casos
	//em que so podera ser cobrado o fator moderador / custo do usuario.  
	if ! aUsuarios[nFor][25]
		loop
	endIf

	//o que vem na matriz para validacao do usuario
	//aUsuarios[nFor,15] == lCobProRat
	//aUsuarios[nFor,17] == lCobRet
	//aUsuarios[nFor,28] == lCobRatRet

	lCobRet := aUsuarios[nFor,17]
	lCobRat := ( aUsuarios[nFor,15] .and. aUsuarios[nFor,17] ) .or. aUsuarios[nFor,28]

	if ( lCobRet .or. lCobRat ) .and. empty(aUsuarios[nFor,32])
	
		dDatInc    := aUsuarios[nFor,14]

		cAnoMesAnt := PLSDIMAM(cAno,cMes,"0")
		dDatAux2   := cAnoMesAnt+StrZero(aUsuarios[nFor,18],2)

		cAnoMesAnt := PLSDIMAM(Subs(cAnoMesAnt,1,4),Subs(cAnoMesAnt,5,2),"0")
		dDatAux1   := cAnoMesAnt+StrZero(aUsuarios[nFor,18],2)

		if lPLDTRETRO
			dDatAux1 := ExecBlock("PLSDTRETRO", .f., .f., { cMes, cAno, dDatAux2, aUsuarios[nFor] } )
		endIf

		cTipReg    	:= aUsuarios[nFor,1]
		cDigito    	:= aUsuarios[nFor,12]
		cProdJaCalc	:= ""


		If ( (aUsuarios[nFor,17] .And. aUsuarios[nFor,21] <> '0'	.And. dDatAux1 <= dtos(dDatInc) .And. dDatAux2 >= dtos(dDatInc)) .Or.;
			 (!aUsuarios[nFor,17] .And. aUsuarios[nFor,21] == '1')	.And. dDatAux1 <= dtos(dDatInc) .And. dDatAux2 >= dtos(dDatInc) ) .Or.;
			 ( aUsuarios[nFor,28] .And. aUsuarios[nFor,21] <> '0' .And. ( (dDatAux1 <= dtos(dDatInc) .And. dDatAux2 >= dtos(dDatInc) ) .OR.;
			 															   (Len(aUsuarios[nFor]) > 31 .And. dtos(dDatInc) <= dDatAux2 .and. Empty(aUsuarios[nFor,32]))) )

			//Se no mes anterior ele ainda nao tinha feito aniversario, a pro-rata / retroativo deve...  
			//ser baseada na faixa da idade anterior...                                                  
		    if lPLSBSIDA
		       dDatBasIda := execBlock("PLSBSIDA", .f., .f., { "1",dDatBasIda,aUsuarios[nFor],cMes,cAno,cMatricFam})
		    endIf
			
			//Calcula idade														
			nIdade := calc_Idade(dDatBasIda, aUsuarios[nFor,2])
	      	nIdade := Iif(nIdade < 0, 0, nIdade)

			// Idade no mes anterior, quando ele entrou no plano...										
			// Mes subsequente, com conteudo = 2.									
			if getNewPar("MV_PLSBASI","1") == "2"
				dDatBasInc := ctod('01/' + strZero( month(dDatInc), 2) + '/' + strZero( year(dDatInc), 4) )
				dDatBasInc := dDatBasInc - 1
			endIf

	      	nIdadeAnt := calc_Idade(dDatBasInc, aUsuarios[nFor,2])
			nIdadeAnt := Iif(nIdadeAnt < 0, 0, nIdadeAnt)

	      	for nForMens := 1 to Len(aVlParcial)

	      		dIniDes	:= ctod("")
	      		dFimDes	:= ctod("")
	      		cTpEve 	:= ""
	      		lAchou	:= .f.

	      		//ao processar aVlParcial é preciso ignorar os beneficiários que não são os da vez 
	      		if aVlParcial[nForMens][7] <> (cOpeFam + cCodEmp + cMatric + cTipReg + cDigito)
	      			loop
	      		endIf
	      		
				//Obtem o valor da mensalidade na faixa anterior, de acordo com a idade que ele tinha quando entrou no plano no mes anterior.
				//Passar como parametro somente o lancamento de faturamento 101																
				aEvent101 := PLSINPBFQ(BA3->BA3_CODINT, {|| BFQ->(BFQ_PROPRI+BFQ_CODLAN) $ cTPLanRet } )
				aVlParUsr := PLSVLRFAM(cMatricFam,subStr(dDatAux2,1,4), subStr(dDatAux2,5,2),aEvent101,nil,.T.,aUsuarios,.T.,.F.,dDatInc,nil,nil)[1][2]
				   
				//verificando se foi retornado um array, se nao, foi gerada crítica 14-09
				if valType(aVlParUsr) != "A"
					aVlParUsr := {} 
				endIf

				if aVlParcial[nForMens][3] $ "191/189" .and. aScan(aVlParUsr,{|x| (x[3] $ "191" .or. x[3] $ "189") .and. x[7] == cOpeFam+cCodEmp+cMatric+cTipReg+cDigito }) == 0
					loop 
				else

					nPosVal := aScan(aVlParcial,{|x| !x[4] $ cProdJaCalc .and. x[3] $ cTPLanRet .and. x[7] == cOpeFam+cCodEmp+cMatric+cTipReg+cDigito })
			               
					if nPosVal <= 0 
						nPosVal := aScan(aVlParcial,{|x| (x[3] $ "191" .or. x[3] $ "189") .and. !x[4] $ cProdJaCalc .and. x[7] == cOpeFam+cCodEmp+cMatric+cTipReg+cDigito  })
					endIf

				endIf

				//aplica regra de cobranca pro-rata/retroativa...																			    
				if nPosVal > 0

					if empty(cProdJaCalc)
						cProdJaCalc := aVlParcial[nPosVal,4]
					else
						cProdJaCalc += "," + IIF(lAchou,aVlParUsr[nPosVal,3] ,aVlParcial[nPosVal,4])
					endIf
			    	    			       
					//Verifica se usuario sofreu reajuste entre de inclusao e o mes da primeira cobranca...										|
					if nPosVal <= len(aVlParUsr)

						nValorMens 	:= iIf(aVlParUsr[nPosVal,3] $ "189/191", aVlParUsr[nPosVal,2],iif(substr(dDatAux2,1,6) >= aVlParUsr[nPosVal,31], aVlParUsr[nPosVal,32], aVlParUsr[nPosVal,33])) //quando desconto pegar a posição 2
						nValDes  	:= aVlParUsr[nPosVal,28]
						nValAcre 	:= aVlParUsr[nPosVal,29]
						DIniDes 	:= aVlParUsr[nPosVal,51]
						DFimDes		:= aVlParUsr[nPosVal,52]
						cTpEve		:= aVlParUsr[nPosVal,3]
						
					elseIf nPosVal <= Len(aVlParcial)

						nValorMens 	:= iIf(((substr(dDatAux2,1,6) >= aVlParcial[nPosVal,31]) .and. ! lExistBFY .and. !lExistBDQ) .or. empty(aVlParcial[nPosVal,31]), aVlParcial[nPosVal,32], IIf(Substr(DToS(aUsuarios[nFor][14]),1,6)>=aVlParcial[nPosVal,31],aVlParcial[nPosVal,32], aVlParcial[nPosVal,33]))
						nValDes  	:= aVlParcial[nPosVal,28]
						nValAcre 	:= aVlParcial[nPosVal,29]
						DIniDes 	:= aVlParcial[nPosVal,51]
						DFimDes		:= aVlParcial[nPosVal,52]
						cTpEve		:= aVlParcial[nPosVal,3]

					endIf

					nQtdMes := plRRetQM(cMes, cAno, dDatInc)
				
					if ! lMvPlsDBM1
						nValorMens 	:= nValorMens - nValDes
					endIf
		
					//pro rata
					if lCobRat
						
						nPercDias  := plRPerPR(aUsuarios[nFor,14], Nil, Nil, Nil, PLDayVencCob(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
						nValProRat := round( ( nValorMens * nPercDias ) / 100, 2)
						
						//se estamos falando de desconto em que a validade é posterior a inclusao do beneficiario, vou zerar 
						if cTpEve $ "189/191" .and. ! empty(dIniDes) .and. (aUsuarios[nFor,14] < dIniDes)
					  		nValProRat := 0
						endIf

						nValorMens := ( nValorMens * nQtdMes ) + nValProRat

					else
						
						nValorMens += ( nValorMens * nQtdMes )

					endIf
				   
			   		AaDd(aRetFun,{  aUsuarios[nFor,13],; //01
                                    aUsuarios[nFor,3],;  //02
                                    nValorMens,; 		 //03
                                    iIf( ! ( aVlParcial[nPosVal,3] $ "191/189"), aUsuarios[nFor,8], aVlParcial[nPosVal,4]),; 	//04
                                    iIf( ! ( aVlParcial[nPosVal,3] $ "191/189"), aUsuarios[nFor,9], aVlParcial[nPosVal,5]),; 	//05
                                    nValDes,; 			//06
                                    nValAcre,; 			//07
                                    aUsuarios[nFor,29],;//08
                                    aUsuarios[nFor,07],;//09
                                    aUsuarios[nFor,31]})//10
				endIf	

			next

			//verificar se no array de cobrança antiga teve cobrança de 191
			for nPosVal := 1 to Len(aVlParUsr)
	      		
	      		// ao processar aVlParcial é preciso ignorar os beneficiários que não são os da vez 
	      		if ( ( aVlParUsr[nPosVal][3] $ cProdJaCalc .or. aVlParUsr[nPosVal][4] $ cProdJaCalc) .or. (!aVlParUsr[nPosVal][3] $"191/189") .or. ( aVlParUsr[nPosVal][7] <> cOpeFam + cCodEmp + cMatric + cTipReg + cDigito ) ) 
	      			loop
	      		endIf
				   
				//verificando se foi retornado um array, se nao, foi gerada crítica 14-09
				cProdJaCalc += "," + aVlParUsr[nPosVal,3] 
	
				//Verifica se usuario sofreu reajuste entre de inclusao e o mes da primeira cobranca...										|
				nValorMens	:= aVlParUsr[nPosVal,2]
				nValDes  	:= aVlParUsr[nPosVal,28]
				nValAcre 	:= aVlParUsr[nPosVal,29]
				nQtdMes     := plRRetQM(cMes, cAno, dDatInc)

				if ! lMvPlsDBM1
					nValorMens 	:= nValorMens - nValDes
			    endIf
	
				//pro rata
				if lCobRat
					  
					nPercDias  := plRPerPR(aUsuarios[nFor,14])
					nValProRat := round( ( nValorMens * nPercDias ) / 100, 2)

					nValorMens := ( nValorMens * nQtdMes ) + nValProRat

				elseIf nQtdMes > 0
					
					nValorMens := ( nValorMens * nQtdMes )

				endIf

			    AaDd(aRetFun, { aUsuarios[nFor,13],;   	//01
								aUsuarios[nFor,3],; 	//02
								nValorMens,; 		  	//03
								aVlParUsr[nPosVal,3],; 	//04
								POSICIONE("BFQ",1, xfilial("BFQ") + cOpeFam + aVlParUsr[nPosVal,3],"BFQ_DESCRI"),; 	//05
								nValDes,; 			  	//06
								nValAcre,; 			  	//07
								aUsuarios[nFor,29],;	//08
								aUsuarios[nFor,07],;	//09
								aUsuarios[nFor,31]})   	//10
			next 

		endIf

	endIf

next

return(aRetFun)

/*/{Protheus.doc} plRRetQM
retorna quantidade de mes para retroativo

@author  PLS TEAM
@version P12
@since   25/05/04
/*/
function plRRetQM(cMes, cAno, dDatInc)
local nP		:= 0
local nJ		:= 0
local nMeses   	:= 12
local nQtdMes  	:= 0
local nMesIncl 	:= month(dDatInc) + 1
local nMesGera 	:= val(cMes)          

if val(cAno) <> year(dDatInc)

	//neste for aqui vou contar quantos meses tem de um ano para o outro
	for nP := year(dDatInc) to val(cAno)

		for nJ := nMesIncl to nMeses
			nQtdMes += 1
		next

		nMesIncl := 1 

		//se chegou no ano da geracao so vou contar ate o mes da geracao 
		if ( val(cAno) - year(dDatInc) ) == 1
			nMeses := nMesGera
		endIf

	next

else

	nQtdMes := val(cMes) - month(dDatInc) 

endIf

return( ( nQtdMes - 1 ))

/*/{Protheus.doc} plRPerPR
retorna o percentual para calculo da prorata

@author  PLS TEAM
@version P12
@since   25/05/04
/*/
Function plRPerPR(dDtInc, lConsDtCanc, nDiasUtil, lBloqueio, nDiaVencto)

	Local nPercDias := 0
	Local nDiasMes := 0
	Local nDay := 0
	Local aDadosProRata := {}

	Default lConsDtCanc := .F.
	Default nDiasUtil	:= 0
	Default lBloqueio := .F.
	Default nDiaVencto := 0

	// Ponto de Entrada para realizar o calculo do percutal e dias utilizados do Pro-rata
	If ExistBlock("PLPRORAT") .And. !Empty(dDtInc)
		aDadosProRata := ExecBlock("PLPRORAT", .F., .F., {dDtInc, nDiaVencto, lBloqueio})

		nPercDias := aDadosProRata[1]
		nDiasUtil := aDadosProRata[2]
	Else
		if ! empty(dDtInc)

			nDiasMes  := day( lastDay(dDtInc) )
			nDay	  := day(dDtInc)

			if lBloqueio
				nDiasUtil := IIf(lConsDtCanc, nDay - 1, nDay)
			else
				nDiasUtil  := ( nDiasMes - nDay ) + 1
			endif

			nPercDias := ( nDiasUtil * 100 ) / nDiasMes

		endIf
	EndIf

return (nPercDias) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  PLSDIMAM  ³ Autor ³ Tulio Cesar       ³ Data ³ 22.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Aumenta ou diminui um ano/mes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSDIMAM(cAno,cMes,cTipo)
//cTipo "1" adicionar, "0" diminuir
LOCAL cRetMes
LOCAL cRetAno

If cTipo == "0"
   If cMes <> "01"
      cRetAno := cAno
      cRetMes := StrZero(Val(cMes)-1,2)
   Else
      cRetAno := StrZero(Val(cAno)-1,4)
      cRetMes := "12"
   EndIf
Else
   If cMes == "12"
      cRetAno := StrZero(Val(cAno)+1,4)
      cRetMes := "01"
   Else
      cRetAno := cAno
      cRetMes := StrZero(Val(cMes)+1,2)
   EndIf
EndIf

Return(cRetAno+cRetMes)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCBADINC ³ Autor ³ Tulio Cesar       ³ Data ³ 15.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Trata a cobranca da adesao no ato da inclusao da familia   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCBADINC()
LOCAL nOrdBA1    := BA1->(IndexOrd())
LOCAL nRecBA1    := BA1->(Recno())
LOCAL nFor		 := 0
LOCAL nVlrAdesao := 0
LOCAL cTipTit    := GetNewPar("MV_PLSTPTA","FT")
LOCAL cPrefixo   := GetNewPar("MV_PLSPRTA","TAX")
LOCAL __cCodigo  := GetSx8Num("BBT","BBT_CODIGO")
LOCAL cNumCob    := GetSx8Num("BDC","BDC_NUMERO")
LOCAL cSeq		 := ''
LOCAL cNumero	 := ''
LOCAL cMatricFam := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
LOCAL cAno       := Subs(dtos(BA3->BA3_DATBAS),1,4)
LOCAL cMes       := Subs(dtos(BA3->BA3_DATBAS),5,2)
LOCAL cCodAdesao := "103" //o codigo para taxa de adesao e 103
LOCAL bRest      := { || BA1->(DbGoto(nRecBA1)), BA1->(DbSetOrder(nOrdBA1)) }
LOCAL lOk		 := .f.
LOCAL aVlrFam    := {}
LOCAL aVlrCob	 := {}
local aVetor	 := {}
LOCAL aRet		 := {}
LOCAL aUsrXAde   := {}
Local lHabMetric := IIf(GetNewPar('MV_PHBMETR', '1') == "0", .F., .T.)

private lMsErroAuto 	:= .f.
private lMsHelpAuto		:= .t.
private lAutoErrNofile	:= .t.

//Busca o valor da familia... vai trazer tudo (mens, opc, adesao) mais
//somente sera lido a taxa de adesao (se existir)...                  
aVlrFam := PLSVLRFAM(cMatricFam,cAno,cMes)

lOk := aVlrFam[1][1]

If lOK

	aVlrCob := aVlrFam[1][2]

	If Len(aVlrCob) > 0
		If  Len(aVlrCob[1,12]) > 0
			aVlrCob[1,12] := "103"
		EndIf
	Endif

	//³ Apura dentro da composicao os valores de adesao para a familia...   
	aEval(aVlrCob,{ |x| nVlrAdesao += If(x[3] == cCodAdesao,x[2],0)  })

	//³ Caso tenha valor gero titulo a receber no valor da adesao...        
	If nVlrAdesao > 0

		lOk := .t.

		//³ Grava respectivo titulo a receber...                                

		SA1->(DbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+BA3->(BA3_CODCLI+BA3_LOJA)))

			cNumero := PLSE1NUM(cPrefixo)

			aVetor := { {"E1_PREFIXO", cPrefixo,Nil},;
						{"E1_NUM", cNumero,Nil},;
						{"E1_PARCELA", Space(Len(SE1->E1_PARCELA)),Nil},;
						{"E1_TIPO", cTipTit,Nil},;
						{"E1_CLIENTE", SA1->A1_COD,Nil},;
						{"E1_LOJA", SA1->A1_LOJA,Nil},;
						{"E1_VENCTO"   ,dDataBase,Nil},;
						{"E1_VENCREA"   ,DataValida(dDataBase),Nil},;
						{"E1_EMISSAO"  ,dDataBase,Nil},;
						{"E1_NATUREZ"  ,SA1->A1_NATUREZ,Nil},;
						{"E1_VALOR"    ,nVlrAdesao,Nil},;
						{"E1_SALDO"    ,nVlrAdesao,Nil},;
						{"E1_ORIGEM"   ,'PLSA260',Nil},;
						{"E1_CODINT"   ,BA3->BA3_CODINT,Nil},;
						{"E1_CODEMP"   ,BA3->BA3_CODEMP,Nil},;
						{"E1_MATRIC"   ,BA3->BA3_MATRIC,Nil},;
						{"E1_CODCOR"   ,BA3->BA3_CODVEN,Nil},;
						{"E1_ANOBASE"  ,cAno,Nil},;
						{"E1_MESBASE"  ,cMes,Nil},;
						{"E1_MULTNAT"  ,'2',Nil},;
						{"E1_PLNUCOB"  ,ALLTRIM(ALLTRIM(BA3->BA3_CODINT) + ALLTRIM(cNumCob)),Nil} }

						If SE1->( Fieldpos("E1_PLORIG") ) > 0
							Aadd( aVetor, {"E1_PLORIG",'6',Nil})
						Endif

			MSExecAuto({|x,y| Fina040(x,y)}, aVetor, 3)

			If lMsErroAuto

				lOk := .f.
				SE1->( rollBackSX8() )
				mostraErro()

			endIf

			if lOk 

				//Atualiza os usuarios informando que ja foi cobrado adesao...        
				BFQ->(DbSetOrder(1))
				BFQ->(MsSeek(xFilial("BFQ")+(BA3->BA3_CODINT)+cCodAdesao))

				For nFor := 1 To Len(aVlrCob)

					If aVlrCob[nFor,3] == cCodAdesao

						BA1->(DbSetOrder(2))
					
						If BA1->(MsSeek(xFilial("BA1")+aVlrCob[nFor,7]))
							BA1->(RecLock("BA1",.F.))
								BA1->BA1_CBTXAD := "1"
								BA1->BA1_VLTXAD := aVlrCob[nFor,2]
							BA1->(MsUnLock())
						EndIf

						AaDd(aUsrXAde,{BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG,BA1->BA1_NOMUSR,aVlrCob[nFor,2]})

						//Grava bm1 para este item da composicao de cobranca....              ³
						cSeq := PLSA625Cd("BM1_SEQ","BM1",1,"BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES+BM1_TIPREG)",;
										BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+cAno+cMes+BA1->BA1_TIPREG)

						BM1->(RecLock("BM1",.T.))
							BM1->BM1_FILIAL := xFilial("BM1")
							BM1->BM1_CODINT := BA1->BA1_CODINT
							BM1->BM1_CODEMP := BA1->BA1_CODEMP
							BM1->BM1_MATRIC := BA1->BA1_MATRIC
							BM1->BM1_TIPREG := BA1->BA1_TIPREG
							BM1->BM1_DIGITO := BA1->BA1_DIGITO
							BM1->BM1_NOMUSR := PLNOMUSR(BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG)
							BM1->BM1_SEQ    := cSeq
							BM1->BM1_CONEMP := BA1->BA1_CONEMP
							BM1->BM1_VERCON := BA1->BA1_VERCON
							BM1->BM1_SUBCON := BA1->BA1_SUBCON
							BM1->BM1_VERSUB := BA1->BA1_VERSUB
							BM1->BM1_ANO    := cAno
							BM1->BM1_MES    := cMes
							BM1->BM1_TIPO   := BFQ->BFQ_DEBCRE
							BM1->BM1_VALOR  := aVlrCob[nFor,2]
							BM1->BM1_CODTIP := BFQ->(BFQ_PROPRI+BFQ_CODLAN)
							BM1->BM1_DESTIP := BFQ->BFQ_DESCRI
							BM1->BM1_CODEVE := ""
							BM1->BM1_DESEVE := ""
							BM1->BM1_ALIAS  := ""
							BM1->BM1_ORIGEM := ""
							BM1->BM1_BASEIR := 0
							BM1->BM1_MATUSU := BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG
							BM1->BM1_PLNUCO := BA1->BA1_CODINT + cNumCob
							BM1->BM1_LTOTAL := "1"
							BM1->BM1_SEXO   := BA1->BA1_SEXO
							BM1->BM1_GRAUPA := BA1->BA1_GRAUPA
							BM1->BM1_CODFAI := ""
							BM1->BM1_NIVFAI := ""
							BM1->BM1_TIPUSU := BA3->BA3_TIPOUS
							BM1->BM1_CARGO  := STR0054 //"TAXA DE INSCRICAO PAGA NO ATO"
							BM1->BM1_PREFIX := cPrefixo
							BM1->BM1_NUMTIT := cNumero
							BM1->BM1_TIPTIT := cTipTit
							BM1->BM1_NIVCOB := "7"
							BM1->BM1_INTERC := "0"
							BM1->BM1_NUMPAR := "001"
						BM1->(MsUnLock())

					EndIf

				Next
				BBT->( ConfirmSx8() )
				
				If !EMPTY(cPrefixo) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava Cabecalho do Historico...                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BBT->( RecLock("BBT",.T.) )
						BBT->BBT_FILIAL := xFilial("BBT")
						BBT->BBT_CODIGO := __cCodigo
						BBT->BBT_CODOPE := BA1->BA1_CODINT
						BBT->BBT_CODEMP := BA1->BA1_CODEMP
						BBT->BBT_CONEMP := BA1->BA1_CONEMP
						BBT->BBT_VERCON := BA1->BA1_VERCON
						BBT->BBT_SUBCON := BA1->BA1_SUBCON
						BBT->BBT_VERSUB := BA1->BA1_SUBCON
						BBT->BBT_MATRIC := BA1->BA1_MATRIC
						BBT->BBT_TIPREG := BA1->BA1_TIPREG
						//BBT->BBT_CODPRO := Substr(_cChave,17,4)
						BBT->BBT_CLIFOR := SA1->A1_COD
						BBT->BBT_LOJA   := SA1->A1_LOJA
						BBT->BBT_VALOR  := BM1->BM1_VALOR
						BBT->BBT_NIVEL  := ""
						BBT->BBT_ANOTIT := cAno
						BBT->BBT_MESTIT := cMes
						BBT->BBT_PREFIX := cPrefixo
						BBT->BBT_NUMTIT := cNumero
						BBT->BBT_TIPTIT := cTipTit

						BBT->BBT_NUMCOB := BA1->BA1_CODINT + cNumCob
						BBT->BBT_RECPAG := "0"
						BBT->BBT_CODPLA := BA3->BA3_CODPLA
						BBT->BBT_VERSAO := BA3->BA3_VERSAO
						BBT->BBT_INTERC := "0"
					BBT->(MsUnlock())
					
					//Métrica do PLS
					/*Atenção:
					1) Para a métrica funcionar com a classe FwMetrics, a lib deve estar na versão igual ou maior que 20200727;
					2) Além de verificar a versão da Lib, existe o parâmetro "secreto" MV_PHBMETR, que vai ficar ativo como default. Caso ocorra lentidão em 
					algum cliente em produção - visto que até 05/2021, nenhum cliente da base tem os requisitos para rodar a métrica e testar em produção - basta
					citar a criação deste parâmetro (Métrica PLS Ativa? 0 - Não / 1 - Sim) e colocar o valor como "0" (desligado).
					3) No futuro, vamos usar o FwCustomMetrics, mas demanda lib superior e outros requisitos...
					4) As variáveis estão declaradas como estáticas no fonte:*/
					if lHabMetric .and. lLibSupFw .and. lVrsAppSw
						
						FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_modelo-pagamento-de-reembolso_total", 1 }} )

					endif

				EndIf 

			EndIf

		Else
			lOk := .f.
		EndIf

	endIf

EndIf

Eval(bRest)

aRet := {lOK, aUsrXAde}

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSREGRAMF ³ Autor ³ Tulio Cesar       ³ Data ³ 13.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Trata as regras da mudanca de fase apos a geracao de titulo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSREGRAMF(cAno,cMes,aVlrCob)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBA1    := BA1->(IndexOrd())
LOCAL nRecBA1    := BA1->(Recno())
LOCAL nOrdBA3    := BA3->(IndexOrd())
LOCAL nRecBA3    := BA3->(Recno())
LOCAL bRest      := { || BA3->(DbSetOrder(nOrdBA3)), BA3->(DbGoTo(nOrdBA3)), BA1->(DbSetOrder(nOrdBA1)), BA1->(DbGoTo(nOrdBA1)) }
local nIdade		:= 0
local nIdadePla		:= 0
local dDatTrb    	:= CtoD("01/"+cMes+"/"+cAno)
local lMudaFaixa 	:= .T.
local J				:= 1
local nSeqFrz		:= 1
local aSeqFrz		:= {}
local cCodInt		:= ""
local cCodEmp		:= ""
local cMatric		:= ""
local oObj			:= nil
local nPos		    := 0 

If GetNewPar("MV_PLSBASI","1")=="2"
	dDatTrb := dDatTrb - 1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Situacao 1 - Planos regulalemntados incluidos DEPOIS   de 01/01/2004³
//³              01/01/2004 e o parametro MV_PLSDINL                    ³
//³              A data da familia deve ser maior que essa data acima...³
//³              Devo testar se o produto ou subcontrato muda a faixa...³
//³                                                                     ³
//³ Casos as condicoes acima sejam verdadeiras...                       ³
//³                                                                     ³
//³ Caso no momento do faturamento (esta funcao) e ele completar 60 anos³
//³ iremos atualizar o BA1_MUDFAI para zero a guardar a sua ultima faixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Situacao 2 - Planos regulalemntados incluidos ANTES    de 01/01/2004³
//³              01/01/2004 e o parametro MV_PLSDINL                    ³
//³              A data da familia deve ser MENOR que essa data acima...³
//³              Devo testar se o produto ou subcontrato muda a faixa...³
//³                                                                     ³
//³ Casos as condicoes acima sejam verdadeiras...                       ³
//³                                                                     ³
//³ Caso no momento do faturamento (esta funcao) e ele completar 60 anos³
//³ e tiver MAIS de 10 anos de plano iremos atualizar o BA1_MUDFAI para ³
//³ zero a guardar a sua ultima faixa                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa cada usuario da familia...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRecBA3 := 0

if Type("oObj") <> "U"
	while PLGetHash(nSeqFrz,@aSeqFrz,oObj)
		
		if aSeqFrz[1]
			//Posiciona no usuario
			BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
			if BA1->(MsSeek(xFilial("BA1") + aSeqFrz[2]))
				//Armazena a faixa
				cFaiCob := aSeqFrz[3]
				
				//Inicializa a idade do beneficiario
				nIdade		:= Calc_Idade(dDatTrb,BA1->BA1_DATNAS)

				// Calcula a idade do plano
				nIdadePla 	:= PLSDIFANOS(PLSSTRANO(BA1->BA1_DATINC,.T.),PLSSTRMES(BA1->BA1_DATINC),cAno,cMes,"A")

				cCodInt	:= Subs(aSeqFrz[2],atCodOpe[1],atCodOpe[2])
				cCodEmp	:= Subs(aSeqFrz[2],atCodEmp[1],atCodEmp[2])
				cMatric	:= Subs(aSeqFrz[2],atMatric[1],atMatric[2])

				if BA3->(MsSeek(xFilial("BA3") + cCodInt + cCodEmp + cMatric))
					//Verifica se deve congelar a faixa
					AnaReajId(nIdade,nIdadePla,@lMudaFaixa)

					// Atualiza os campos de mudanca de faixa no  usuario de  acordo com as regras acima...
					If !lMudaFaixa
						AnaUsrFaixa({},.T.,nIdadePla >= 10,cFaiCob)
					EndIf
				endif

			endif
			
			//Marca a primeira opcao como falsa para nao entrar nas demais ocorrencias
			aSeqFrz := {.F.}

			PLSetHash(nSeqFrz,aSeqFrz,@oObj)
		endif

		nSeqFrz++
	enddo

else
	For J:=1 to len(aVlrCob)

		If Len(aVlrCob[j])>52
			If nRecBA3 == aVlrCob[j,53]
				Loop
			Endif
			nRecBA3 := aVlrCob[j,53]
		EndIf

		BA1->(DbSetOrder(2))
		If BA1->(MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
			While ! BA1->(Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)

				// Calcula a sua idade em meses...
				nIdade    := Calc_Idade(dDatTrb,BA1->BA1_DATNAS)
				nIdade	  := Iif(nIdade < 0,0,nIdade)
				nIdadePla := PLSDIFANOS(PLSSTRANO(BA1->BA1_DATINC,.T.),PLSSTRMES(BA1->BA1_DATINC),cAno,cMes,"A")

				//Verifica se deve congelar a faixa
				AnaReajId(nIdade,nIdadePla,@lMudaFaixa)

				// Atualiza os campos de mudanca de faixa no  usuario de  acordo com as regras acima...
				If !lMudaFaixa

					AnaUsrFaixa(aVlrCob,.T.,nIdadePla >= 10)
				else 
					
					nPos := Ascan(aVlrCob,{ |x| x[7] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) .And. x[3] == "101"	}) 

					If nPos > 0
						
						BA1->(RecLock("BA1",.F.))
						BA1->BA1_FAICOB := aVlrCob[nPos,13] //A faixa que devera ser cobrada...
						BA1->(MsUnLock())
					EndIf
				EndIf
				
				lMudaFaixa := .T.
				
				// Se o usuario tiver mais de 10 anos de plano nao muda mais a faixa...
				BA1->(DbSkip())
			Enddo
		EndIf
	Next
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AnaReajId
Verifica se o contrato da familia foi firmado antes de 01/01/2004
*Precisa estar posicionado na BA3
@author  victor.silva
@since   20170801
@version p118
/*/
//-------------------------------------------------------------------
function AnaReajId(nIdade,nIdadePla,lMudaFaixa)
local nAnoLimite	:= GetNewPar("MV_PLSILIM",60)
local dDatLei		:= GetNewPar("MV_PLSDINL",ctod("01/01/2004"))
local cCodInt		:= ""
local cCodPla		:= ""
local cVerPla		:= ""
local lPlaMudFai	:= .F.

default nIdade		:= 0
default nIdadePla	:= 0
default lMudaFaixa	:= .T.

//Identifica o plano do beneficiario
if empty(BA1->BA1_CODPLA)
	cCodInt := BA3->BA3_CODINT
	cCodPla := BA3->BA3_CODPLA
	cVerPla := BA3->BA3_VERSAO
else
	cCodInt := BA1->BA1_CODINT
	cCodPla := BA1->BA1_CODPLA
	cVerPla := BA1->BA1_VERSAO
endif

//Verifica se o plano esta dentro da regra
lPlaMudFai := BI3->(Posicione("BI3",1,xFilial("BI3") + cCodInt + cCodPla + cVerPla,"BI3_MUDFAI")) == "1"

//Plano regulamentado incluidos ANTES de 01/01/2004
if BA3->BA3_APLEI $ "1, " .and. dtos(BA3->BA3_DATBAS) < dtos(dDatLei) .And. lPlaMudFai

	//Verifica se atende aos requisitos
	if nIdade >= nAnoLimite .And. nIdadePla >= 10
		//Indica que a mudanca de faixa deve ser congelada
		lMudaFaixa  := .F.
	endif

	//Regra definida por meio de ponto de entrada
	if lPlCb2Mdf 
		lMudaFaixa := ExecBlock("PLCB2MDF", .F., .F., {nIdade,lMudaFaixa,.T.,nIdadePla})
	endif

//Plano regulamentado incluidos DEPOIS de 01/01/2004
elseif BA3->BA3_APLEI $ "1, " .and. dtos(BA3->BA3_DATBAS) >= dtos(dDatLei) .And. lPlaMudFai

	//Verifica se atende aos requisitos
	if nIdade >= nAnoLimite
		lMudaFaixa := .F.
	endif

	//Regra definida por meio de ponto de entrada
	if lPlCb2Mdf 
		lMudaFaixa := ExecBlock("PLCB2MDF", .F., .F., {nIdade,lMudaFaixa,.F.,nIdadePla})
	endif

// Se o plano nao for regulamentado, a regra definida por meio de ponto de entrada
elseif BA3->BA3_APLEI == "0"

	if lPlCb2Mdf 
		lMudaFaixa := ExecBlock("PLCB2MDF", .F., .F., {nIdade,.T.,.F.,nIdadePla})
	endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} AnaReg10y
Verifica se o beneficiario deve ser submetido a regra de 10 anos de plano
@author  victor.silva
@since   20170803
@version p11
/*/
//-------------------------------------------------------------------

Static Function AnaReg10y(cMatric,nIdade,nAnoLimite,cAno,cMes,nIdaFrz,lLeiAnt)
local lRet			:= .T.
LOCAL aAreaBA1		:= BA1->(GetArea())
LOCAL aAreaBA3		:= BA3->(GetArea())
local dDatLei		:= GetNewPar("MV_PLSDINL",ctod("01/01/2004"))
local cCodInt		:= ""
local cCodPla		:= ""
local cVerPla		:= ""
local cCodEmp		:= ""
local cMatFam		:= ""

default cMatric		:= ""
default nIdade		:= 0
default cAno		:= ""
default cMes		:= ""
default nIdaFrz		:= ""
default lLeiAnt		:= .F.

//Posiciona no usuario
BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
if BA1->(MsSeek(xFilial("BA1") + cMatric))
	cCodInt	:= Subs(cMatric,atCodOpe[1],atCodOpe[2])
	cCodEmp	:= Subs(cMatric,atCodEmp[1],atCodEmp[2])
	cMatFam	:= Subs(cMatric,atMatric[1],atMatric[2])

	BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
	if BA3->(MsSeek(xFilial("BA3") + cCodInt + cCodEmp + cMatFam))

		//Identifica o plano do beneficiario
		if empty(BA1->BA1_CODPLA)
			cCodInt := BA3->BA3_CODINT
			cCodPla := BA3->BA3_CODPLA
			cVerPla := BA3->BA3_VERSAO
		else
			cCodInt := BA1->BA1_CODINT
			cCodPla := BA1->BA1_CODPLA
			cVerPla := BA1->BA1_VERSAO
		endif

		//Verifica se o plano esta dentro da regra
		lPlaMudFai := BI3->(Posicione("BI3",1,xFilial("BI3") + cCodInt + cCodPla + cVerPla,"BI3_MUDFAI")) == "1"

		//Plano regulamentado incluidos ANTES de 01/01/2004
		if BA3->BA3_APLEI $ "1, " .and. dtos(BA3->BA3_DATBAS) < dtos(dDatLei) .And. lPlaMudFai
			// Calcula a idade do plano
			nIdadePla := PLSDIFANOS(PLSSTRANO(BA1->BA1_DATINC,.T.),PLSSTRMES(BA1->BA1_DATINC),cAno,cMes,"A")
			
			if nIdadePla >= 10
				//Marca que refere-se a planos regulamentados antes da lei
				lLeiAnt		:= .T.

				//Verifica com que idade o usuario completou 10 anos de plano
				xVarAux 	:= Val(SubStr(DtoS(BA1->BA1_DATINC),1,4))
				xVarAux 	:= AllTrim(Str(xVarAux + 10)) + SubStr(DtoS(BA1->BA1_DATINC),5,4)
				dDat10Anos	:= StoD(xVarAux)

				//Calcula a idade ao qual o usuario deveria comgelar caso o faturamento tenha sido gerado após o usuário aderir a regra
				nIdaFrz 	:= Calc_Idade(dDat10Anos,BA1->BA1_DATNAS)
			else
				lRet := .F.
			endif
		else
			//Caso for apos a lei, devo considerar a data de inclusao do beneficiario
			nIdaFrz 	:= Calc_Idade(dDataBase,BA1->BA1_DATNAS)// calculando a idade do usuario de maneira correta

			//Se a inclusao foi antes do usuario completar 60 anos, devo considerar a data informada na lei
			if nIdaFrz < nAnoLimite
				nIdaFrz := nAnoLimite
			endif

			lRet := .T.
		endif
	endif
endif

//Recupera os registros posicionados antes da chamada
RestArea(aAreaBA1)
RestArea(aAreaBA3)

return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ AnaUsrFaixa³ Autor ³ Tulio Cesar       ³ Data ³ 13.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Funcao de apoio a funcao principal PLSREGRAMF              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AnaUsrFaixa(aVlrCob,lMudFai,l10Anos,cFaiCob)
local nPos		:= 0
local cCdLan	:= "101" //Codigo que identifica o lancto de mensalidade...

default cFaiCob	:= ""

if !empty(cFaiCob)
	BA1->(RecLock("BA1",.F.))
		BA1->BA1_MUDFAI := iif(lMudFai,"0","1")		//Nao muda mais a faixa...
		BA1->BA1_FAICOB := iif(lMudFai,cFaiCob,"") 	//A faixa que devera ser cobrada...
		BA1->BA1_10ANOS := iif(l10Anos,"1","")		//Indica que ja completou 10 anos de plano
	BA1->(MsUnLock())
else
	nPos := Ascan(aVlrCob,{ |x| x[7] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) .And. x[3] == cCdLan	})

	If nPos > 0
		cFaiCob := aVlrCob[nPos,13]

		BA1->(RecLock("BA1",.F.))

		If lMudFai
			BA1->BA1_MUDFAI := "0" //Nao muda mais a faixa...
			BA1->BA1_FAICOB := cFaiCob //A faixa que devera ser cobrada...
		EndIf

		If l10Anos
			BA1->BA1_10ANOS := "1" //ele tem mais de 10 anos...
		EndIf

		BA1->(MsUnLock())
	EndIf
endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSHISFAI ºAutor  ³Geraldo Felix Juniorº Data ³  13/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao generica para mostrar historico das tabelas de precosº±±
±±º          ³em todos os niveis...                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSHISFAI(cAlias,cChave,cWhile,nOrdem, cTxtCap)
LOCAL aDadHis 	:= {}
LOCAL aCabHis 	:= {}
LOCAL aTrbHis 	:= {}
LOCAL oBrwHis 	:= {}
LOCAL oDlgHis
LOCAL aArea		:= GetArea()
LOCAL bOk 		:= { || oDlgHis:End() }
LOCAL bCancel	:= { || oDlgHis:End() }
LOCAL cCadastro := STR0055 //"Históricos"

DEFAULT cTxtCap := cCadastro

dbSelectArea(cAlias)
dbSetOrder(nOrdem)

Store Header cAlias TO aCabHis For .T.
If !MsSeek(xFilial(cAlias)+cChave)
	Store COLS Blank cAlias TO aDadHis FROM aCabHis
Else
	Store COLS cAlias TO aDadHis FROM aCabHis VETTRAB aTrbHis While xFilial(cAlias)+cChave == &(cWhile)
EndIf

DEFINE MSDIALOG oDlgHis TITLE cCadastro FROM ndLinIni,000 TO ndLinFin,ndColFin OF GetWndDefault()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Getdados para mostrar o historico...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	aDifSize:= {,,,,35,3,,}
	oBrwHis  := TPLSBrw():New(060,003,392,190,NIL  ,oDlgHis,nil   , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabHis   ,aDadHis ,.F.      ,cAlias ,K_Visualizar,cCadastro,nil,nil,nil,aTrbHis,,,,,,,,,,,,,aDifSize)
Else
	oBrwHis  := TPLSBrw():New(015,003,392,190,NIL  ,oDlgHis,nil   , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabHis   ,aDadHis ,.F.      ,cAlias ,K_Visualizar,cCadastro,nil,nil,nil,aTrbHis)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgHis ON INIT EnchoiceBar(oDlgHis,bOK,bCancel,.F.,{})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a area de trabalho...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCOMPFINºAutor  ³Geraldo Felix Juniorº Data ³  05/23/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a composicao de um titulo financeiro gerado pelo    º±±
±±º          ³SIGAPLS                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCOMPFIN(cPrefix, cNumTit, cParcela, cTipTit, cNumCob, lAberto, lDireto)
LOCAL cSql 		:= ''
LOCAL cValor	:= ''
LOCAL cCliente	:= ''
LOCAL nCnt 		:= 0
LOCAL nPos		:= 0
LOCAL cBM1Name 	:= BM1->(RetSqlName("BM1"))
LOCAL aLancBM1  := {}
LOCAL aLancBBT  := {}
LOCAL lCpoBM1	:= .F.
LOCAL lCpoBBT	:= .F.
LOCAL nFieldPos := 0
LOCAL nValor	:= 0
LOCAL nQuant	:= 0
LOCAL nValFai	:= 0
LOCAL oDlg
LOCAL oTree
LOCAL nIdaIni := 0
LOCAL nIdaFin := 0
LOCAL aButtons:= {}
LOCAL nCntFor := 0
LOCAL aStruBM1 := BM1->(dbStruct())

DEFAULT lAberto := .F.
DEFAULT lDireto := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o titulo...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SE1->( dbSetorder(01) )
If !SE1->( MsSeek(xFilial("SE1")+cPrefix+cNumTit+cParcela+cTipTit ) ) .Or. Empty(cPrefix)
	MsgAlert(STR0036) //"Titulo nao encontrado!"
	Return({.F.,{}})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define botao de impressao de boleto...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aButtons := {{'RELATORIO',{|| PLSA629BOL(SE1->(Recno()))},STR0037}}   //"Imprimir Boleto"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra o BM1...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSql := "SELECT  BM1_CODTIP, BM1_DESTIP, BM1_CODEVE, BM1_DESEVE, BM1_CODINT,  "
cSql += "BM1_CODEMP, BM1_MATRIC, BM1_TIPREG, BM1_DIGITO, BM1_CONEMP, BM1_VERCON, "
cSql += "BM1_SUBCON, BM1_VERSUB, BM1_NOMUSR, BM1_ANO, BM1_MES, BM1_TIPO, BM1_VALOR, "
cSql += "BM1_LTOTAL, BM1_SEXO  , BM1_GRAUPA, BM1_NIVFAI, BM1_TIPUSU, BM1_CODFAI, "
cSql += "BM1_NIVCOB, BM1_IDAINI, BM1_IDAFIN "
cSql += "FROM "+cBM1Name+" BM1 WHERE BM1_PREFIX = '"+cPrefix+"' "
cSql += "AND BM1_NUMTIT = '"+cNumTit+"' AND BM1_PARCEL  = '"+cParcela+"' "
cSql += "AND BM1_TIPTIT = '"+cTipTit+"' AND BM1_PLNUCO  = '"+cNumCob+"' "
cSql += "AND D_E_L_E_T_ <> '*' ORDER BY BM1_CODTIP, BM1_CODEVE, BM1_IDAINI, BM1_IDAFIN, BM1_VALOR "
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)


TRB->( dbGotop() )
While !TRB->( Eof() )
	nPos := Ascan(aLancBM1, {|x| x[1] == TRB->BM1_CODTIP .and. x[3] == TRB->BM1_CODEVE})

	If nPos == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona item ao array...                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd( aLancBM1, Array(TRB->(fCount())) )

		For nCnt := 1 To TRB->(fCount())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ignora o campo filial...                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TRB->(Field(nCnt)) == "BM1_FILIAL"
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega a matriz com a composicao da cobranca...                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aLancBM1[Len(aLancBM1)][nCnt] := TRB->( FieldGet(nCnt) )
		next
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega a matriz com a composicao da cobranca...                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nFieldPos := TRB->( FieldPos("BM1_VALOR") )
		If nFieldPos == 0
			MsgAlert(STR0038) //"O campo BM1_VALOR e obrigatorio na lista de campos informados no parametro!"
			Return({.F.,{}})
		EndIf

		aLancBM1[nPos][nFieldPos] += TRB->BM1_VALOR
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acessa o proximo registro...                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRB->( dbSkip() )
Enddo

If !lDireto
	DEFINE MSDIALOG oDlg TITLE STR0039 FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault() //"Composicao da cobranca"

	cCliente := SE1->E1_CLIENTE+" - "+AllTrim(SE1->E1_NOMCLI)
	@ 035, 185 GROUP oGrupo TO 051, 350 PIXEL OF oDlg LABEL STR0040  COLOR CLR_HBLUE, CLR_HRED //" Cliente "
	PLSSAYESP(041,190,{ || cCliente },;
				179,;
				016,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ 055, 185 GROUP oGrupo TO 071, 220 PIXEL OF oDlg LABEL STR0041  COLOR CLR_HBLUE, CLR_HRED //" Prefixo "
	PLSSAYESP(061,197,{ || SE1->E1_PREFIXO },;
				229,;
				016,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ 055, 222 GROUP oGrupo TO 071, 300 PIXEL OF oDlg LABEL " " + STR0058 + " / " + STR0059 + " / " + STR0060  COLOR CLR_HBLUE, CLR_HRED //"Titulo"###"Parcela"###"Tipo"
	PLSSAYESP(061,227,{ || SE1->E1_NUM+" / "+SE1->E1_PARCELA+" / "+SE1->E1_TIPO },;
				229,;
				016,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ 055, 302 GROUP oGrupo TO 071, 350 PIXEL OF oDlg LABEL STR0043  COLOR CLR_HBLUE, CLR_HRED //" Lote "
	PLSSAYESP(061,307,{ || Substr(SE1->E1_PLNUCOB,5,8) },;
				229,;
				016,;                                                                       
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o objeto arvore...                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree := DbTree():New(035,005,195,180,oDlg,nil,nil,.T.,nil)
	oTree:BuildTrb(100, 2)
	oTree:BeginUpdate()
	oTree:SetEnable()

	TRB->( dbGotop() )
	While !TRB->( Eof() )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define a arvore do grupo empresa...                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodTip := TRB->BM1_CODTIP
		While !TRB->( Eof() ) .and. TRB->BM1_CODTIP == cCodTip
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva o codigo do evento...                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodEve := TRB->BM1_CODEVE
			cDesEve := TRB->BM1_DESEVE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa separadamente aqueles que devem ser apresentado por faixa etaria³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cCodTip $ "101,102,106,103"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Define a arvore do evento principal...                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCodTip <> '103'
					cValor := AllTrim(TRB->BM1_DESEVE)
				Else
					cValor := AllTrim(TRB->BM1_DESTIP)
				EndIf
				oTree:AddTree(cValor+Space(100),"BR_VERDE","BR_VERDE",NIL,NIL,NIL,"EVE"+TRB->BM1_CODEVE)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o registro e processa valores por faixa etaria...            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				nValor := 0
				nQuant := 0
				While !TRB->( Eof() ) .and. TRB->BM1_CODEVE == cCodEve .and. TRB->BM1_CODTIP == cCodTip
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Salva idade inicia / final e valor...                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nIdaIni := TRB->BM1_IDAINI
					nIdaFin := TRB->BM1_IDAFIN
					nValFai := TRB->BM1_VALOR

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Sumariza...                                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While !TRB->( Eof() ) .and. TRB->BM1_CODTIP == cCodTip .and. TRB->BM1_CODEVE == cCodEve .and.;
						TRB->BM1_IDAINI == nIdaIni .and. TRB->BM1_IDAFIN == nIdaFin .and. nValFai == TRB->BM1_VALOR
						nValor += TRB->BM1_VALOR
						nQuant ++
						TRB->( dbSkip() )
					Enddo

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta o texto da linha do sub intem da arvore...                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cValor := STR0044+StrZero(nIdaIni,3)+STR0045+StrZero(nIdaFin,3)+STR0056 + " - "+; //"De "###" a "###" Anos"
					StrZero(nQuant,4)+" x "+Transform(nValFai,PLSVALOR)+" = "+;
					Transform(nValor,PLSVALOR)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Define a arvore do sub item...                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oTree:AddTree(cValor,NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
					oTree:EndTree()
					nValor := 0
					nQuant := 0
				Enddo
			Else
				oTree:AddTree(AllTrim(TRB->BM1_DESTIP),"BR_VERDE","BR_VERDE",NIL,NIL,NIL,"EVE"+TRB->BM1_CODEVE)

				While !TRB->( Eof() ) .And. TRB->BM1_CODEVE == cCodEve .and. TRB->BM1_CODTIP == cCodTip
					nValor += TRB->BM1_VALOR
					TRB->( dbSkip() )
				Enddo
				cValor := AllTrim(cDesEve)+" - "+Transform(nValor,PLSVALOR)
				oTree:AddTree(cValor+Space(100),NIL,"LJPRECO","LJPRECO",NIL,NIL,"VLR")
				oTree:EndTree()
				nValor := 0
			EndIf
		Enddo
		oTree:EndTree()
	Enddo
	oTree:EndUpdate()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta totalizadores...                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 175, 185 GROUP oGrupo TO 192, 224 PIXEL OF oDlg LABEL STR0047 COLOR CLR_HBLUE, CLR_HRED //" Emissao "
	PLSSAYESP(182,189,{ || dToc(SE1->E1_EMISSAO) },;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ 175, 226 GROUP oGrupo TO 192, 262 PIXEL OF oDlg LABEL STR0048 COLOR CLR_HBLUE, CLR_HRED //" Vencimento "
	PLSSAYESP(182,230,{ || dToc(SE1->E1_EMISSAO) },;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ 175, 264 GROUP oGrupo TO 192, 313 PIXEL OF oDlg LABEL STR0049 COLOR CLR_HBLUE, CLR_HRED //" Valor "
	PLSSAYESP(182,269,{ || TransForm(SE1->E1_VALOR,PLSVALOR)},;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	@ 175, 315 GROUP oGrupo TO 192, 350 PIXEL OF oDlg LABEL STR0050  COLOR CLR_HBLUE, CLR_HRED //" Saldo "
	PLSSAYESP(182,317,{ || TransForm(SE1->E1_SALDO,PLSVALOR)},;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")

	ACTIVATE MSDIALOG oDlg center ON INIT Eval({ ||  EnChoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},.F.,aButtons) })
EndIf

TRB->( dbCloseArea() )

Return({.T.,aLancBM1})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSRECCALC ³ Autor ³Geraldo Felix Jr.  ³ Data ³ 13.01.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Retorna a receita de uma empresa/familia/usuario           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
cTipoCon == "0" - Operadora
            "1" - Operadora + Grupo Empresa
            "2" - Operadora + Grupo Empresa + Numero do Contrato + Versao
            "3" - Operadora + Grupo Empresa + Numero do Contrato + Versao + SubContrato + Versao
            "4" - Operadora + Grupo Empresa + Familia
            "5" - Operadora + Grupo Empresa + Familia + Usuario
/*/
Function PLSRECCALC(cTipoCon,cCodOpe,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cMatric,cTipReg,cAnoIni,cMesIni,;
                    cAnoFin,cMesFin,nTipo,lAutomato)
LOCAL cSql 		:= ''
LOCAL nValorRec	:= 0
LOCAL cPrefix	:= ''
LOCAL cNumtit	:= ''
LOCAL cParcel	:= ''
LOCAL cTiptit	:= ''
LOCAL lSeek		:= .T.
LOCAL aStruBM1  := BM1->(dbStruct())
LOCAL lBFQ_CONSIN := BFQ->( FieldPos("BFQ_CONSIN") ) > 0
DEFAULT lAutomato := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o inicio da query, identico a qualquer cTipoCon                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT Sum(BM1_VALOR) AS VALOR, BM1_TIPO AS TIPO, BM1_PREFIX, BM1_NUMTIT, "
cSQL += "BM1_PARCEL, BM1_TIPTIT, BM1_CODTIP, BM1_CODINT FROM "+BM1->(RetSQLName("BM1"))+" WHERE "

cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' AND "
cSQL += "BM1_CODINT = '"+cCodOpe+"' "
If cTipoCon <> "0"
   cSQL += "AND BM1_CODEMP = '"+cCodEmp+"' "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se cTipoCon for igual a 2 ou 3 adiciona a query abaixo...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If     cTipoCon $ "2,3"
       cSQL += "AND BM1_CONEMP = '"+cNumCon+"' AND "
       cSQL += "BM1_VERCON = '"+cVerCon+"'"

       If cTipoCon == "3"
          cSQL += "AND BM1_SUBCON = '"+cSubCon+"' AND "

          cSQL += "BM1_VERSUB = '"+cVerSub+"'"
       EndIf
ElseIf cTipoCon $ "4,5"
       cSQL += "AND BM1_MATRIC = '"+cMatric+"' "

       If cTipoCon == "5"
          cSQL += "AND BM1_TIPREG = '"+cTipReg+"'"
       EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o final da query, identico a qualquer cTipoCon                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "AND ( BM1_ANO >= '"+cAnoIni+"' AND BM1_ANO <= '"+cAnoFin+"' ) "
cSQL += "AND ( BM1_MES >= '"+cMesIni+"' AND BM1_MES <= '"+cMesFin+"' ) "
cSQL += "AND D_E_L_E_T_ = '' "

cSQL += "GROUP BY BM1_CODINT, BM1_TIPO, BM1_CODTIP, BM1_PREFIX, BM1_NUMTIT, BM1_PARCEL, BM1_TIPTIT "
cSQL += "ORDER BY BM1_PREFIX, BM1_NUMTIT, BM1_PARCEL, BM1_TIPTIT "
//Retirei ChangeQuery devido a questões de performance e pela query não necessitar
//transformações para funcionar em bancos diferentes.
//cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSRECEITA",.F.,.T.)


If PLSRECEITA->(Eof())
	nValorRec := 0
Else
	SE1->( dbSetorder(01) )
	BFQ->( dbSetorder(01) )
	While !PLSRECEITA->(Eof())
		cPrefix := PLSRECEITA->BM1_PREFIX
		cNumtit	:= PLSRECEITA->BM1_NUMTIT
		cParcel	:= PLSRECEITA->BM1_PARCEL
		cTiptit	:= PLSRECEITA->BM1_TIPTIT

		lSeek := .T.
		While !PLSRECEITA->( Eof() ) .and. cPrefix == PLSRECEITA->BM1_PREFIX .and.;
											cNumtit	== PLSRECEITA->BM1_NUMTIT .and.;
											cParcel	== PLSRECEITA->BM1_PARCEL .and.;
											cTiptit	== PLSRECEITA->BM1_TIPTIT

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Testa se o lancamento de faturamento existe.                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !BFQ->( dbSeek(xFilial("BFQ")+PLSRECEITA->(BM1_CODINT+BM1_CODTIP)) )
				PLSRECEITA->( dbSkip() )
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o lancamento podera entrar para o calculo da sinistralidade..³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBFQ_CONSIN .and. BFQ->BFQ_CONSIN <> '1'
				PLSRECEITA->( dbSkip() )
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no SE1 caso seja para considerar a baixa do titulo...          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lSeek .and. nTipo == 2
				SE1->( dbSeek(xFilial("SE1")+cPrefix+cNumTit+cParcel+cTipTit) )
				lSeek := .F.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incementa variavel totalizadora...                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTipo == 1 .or. (!SE1->( Eof() ) .and. SE1->E1_SALDO == 0)

				Iif(PLSRECEITA->TIPO == '1',nValorRec += PLSRECEITA->VALOR, nValorRec -= PLSRECEITA->VALOR)

			EndIf
			PLSRECEITA->( dbSkip() )
		Enddo
	Enddo
EndIf
PLSRECEITA->( dbClosearea() )

If lAutomato
    nValorRet2 := nValorRec
EndIF

Return({nValorRec})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSHISTREAºAutor  ³Geraldo Felix Juniorº Data ³  03/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra historico do reajuste de acordo com o item           º±±
±±º          ³posicionado no oTree.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSHISTREA(oTree)
LOCAL cArqTmp	:= ''
LOCAL lResult 	:= .T.
LOCAL cCodLanc  := ''
LOCAL cVerOpc 	:= '001'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem nome do arquivo temporario gerado pelo objeto TREE...              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqTmp := oTree:cArqTree

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona arquivo temporario do objeto no registro equivalente ao selecionado pelo usuario |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
&(cArqTmp)->( dbSetorder(03) )
&(cArqTmp)->( MsSeek(oTree:CurrentNodeId) )

If !&(cArqTmp)->( Eof() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Optem codigo do lancamento de faturamento e o codigo do produto...                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLancFat := Substr(AllTrim(&(cArqTmp+"->T_PROMPT")),2,3)
	cCodLanc := Substr(AllTrim(&(cArqTmp+"->T_PROMPT")),(At(AllTrim(&(cArqTmp+"->T_PROMPT")),'[')+2),3)

	If cLancFat == "101" // Historicos das faixas etarias...
		PLSHISFAI("BP7",(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)),;
                                                          "BP7->(BP7_FILIAL+BP7_CODOPE+BP7_CODEMP+BP7_MATRIC)",1, STR0061) //"Valores das faixas etarias"

  	Elseif cLancFat == "102" // Historicos dos opcionais...
		PLSHISFAI("BYH",(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+;
                                                          cCodLanc+cVerOpc),;
                                                          "BYH->(BYH_FILIAL+BYH_CODOPE+BYH_CODEMP+BYH_MATRIC"+;
                                                          "BYH_CODOPC+BYH_VEROPC)",3, STR0062) //"Valores de opcionais"

 	Elseif cLancFat == "103" // Historicos da taxa de adesao...
		PLSHISFAI("BYG",(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)),;
                                                          "BYG->(BYG_FILIAL+BYG_CODOPE+BYG_CODEMP+BYG_MATRIC)",1, STR0063) //"Valores da taxa de adesao"
	Else

		lResult := .F.
 	EndIf
 Else
 	lResult := .F.
 EndIf

If !lResult
	MsgAlert(STR0064) //"Nao existe historico de reajuste para este lancamento de faturamento. Posicione sobre um produto ou opcional ou taxa de adesao!"
EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AnalisaUsrºAutor  ³Geraldo Felix Juniorº Data ³  05/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Analiza as regras do usuario.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ A funcao foi ajustada para ser utilizada genericamente,    º±±
±±ºUso       ³ por isso a tabela BA1 devera esta posicionada antes de     º±±
±±ºUso       ³ chamar por ela.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AnalisaUsr(cAno,cMes,lBA1_CB1AM, cTipCon,lOnlyLook)
LOCAL lRet 		   	:= .F.
LOCAL cAnoMesAnt   	:= PLSDIMAM(cAno,cMes,"0")
LOCAL lCobAll	   	:= .T.
LOCAL cFirstDay
LOCAL cModCobExc	:= GetNewPar("MV_PLSMCBL","1")
LOCAL lConsidDB	:= GetNewPar("MV_PLSCDBR",.F.)
LOCAL cAnoMesComp	:= cAno+cMes
LOCAL aRetCO		:= {}
LOCAL aArea			:= GetArea()
LOCAL aFoCoPF		:= {"0","2"}
DEFAULT lBA1_CB1AM 	:= .F.
DEFAULT lOnlyLook	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuario sem nenhum tipo de bloqueio... autorizado para cobranca...                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(BA1->BA1_DATBLO) .OR. (Subs(dtos(BA1->BA1_DATBLO),1,6) > cAnoMesComp) //Se o bloqueio é futuro, ainda vai cobrar
	lRet := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analise completa do usuario caso ele tenha sofrido Bloqueio.                        			   |
//|                                                                                                  |
//| Primeira analize: Verifica se o tipo do bloqueio do usuario permite faturamento 				   |
//| -Removida a Primeira Análise- 17/03/16  Nova verificação abaixo:               					   |											   |
//| Devido à possibilidade de bloqueio futuro, o sistema irá verificar a data do bloqueio, se a data |
//| for anterior ao ano/mês competência, irá permitir o faturamento, pois o bloqueio não ocorreu     |
//| ainda (lRet sai .T.), caso não, daí cai nas validações do mês de bloqueio (regras 2 e 3)		   |
//|                                                                                                  |
//³ Segunda analisa :MV_PLSMCBL == '1' - O usuario sera cobrado no mes que for bloqueado, desde que  |
//| a data de bloqueio nao seja o primeiro dia da competencia faturada.                              |
//| Exemplo: Faturamento do mes 10/2007.                                                             |
//|	Se a data do bloqueio for dia 01/10/2007, o usuario nao sera cobrado. 							   |
//| Se a data do bloqueio for dia 02/10/2007, o usuario sera cobrado normalmente.                    |
//|                                                                                                  |
//³ Terceira analisa: MV_PLSMCBL <> '1' - O usuario nao sera  cobrado no mes em que for bloqueado.   |
//| Exemplo: Faturamento do mes 10/2007.                                                             |
//|	Se a data do bloqueio for dia 01/10/2007, o usuario nao sera cobrado. 							   |
//| Se a data do bloqueio for dia 02/10/2007, o usuario nao sera cobrado.							   	   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet 
	If BA1->(FieldPos("BA1_BLOFAT")) > 0
		lRet := BA1->BA1_BLOFAT <> "1"
	Else
		lRet := PlsBlqFat(BA1->BA1_DATBLO, BA1->BA1_MOTBLO, BA1->BA1_CONSID)
	EndIf
EndIf

// Se nao tiver Bloqueado e esteja Desligado, verificar se Bloqueia Cobrança
//MV_PBLCATE == 1 Bloqueia Cobranças usuario desligado
If lRet .And. GetNewPar("MV_PBLCATE","0") == "1" .And.;
 	!Empty(BA3->BA3_DATDES) .And. Subs(dtos(BA3->BA3_DATDES),1,6) <= cAno+cMes
   	lRet := .F.
Endif

If !lRet
	If BA1->BA1_DATBLO == BA1->BA1_DATINC .And. !Empty(BA1->BA1_DATBLO)
		lRet := .F.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Segunda analise: MV_PLSMCBL == '1' 																 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/ÄÄÄÄÄÄÙ
		If cModCobExc == "1"
			cAnoMesComp := cAno+cMes
			cFirstDay   := cAno+cMes+'01'

			If 	( (Subs(dtos(BA1->BA1_DATBLO),1,6) >= cAnoMesComp .and. dtos(BA1->BA1_DATBLO) >= cFirstDay) ) 
				If dtos(BA1->BA1_DATBLO) == cFirstDay //para que o sistema nao cobre caso seja o primeiro dia, mas cobre caso seja o segundo dia da competencia 
					lRet := .F.
				Else
					lRet := .T.
				EndIf
			Else
				lRet := .F.
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Terceira analise: MV_PLSMCBL <> '1' 															 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAnoMesComp := PLSDIMAM(cAno,cMes,"1")
			cFirstDay   := cAnoMesComp+'01'
			If 	(Subs(dtos(BA1->BA1_DATBLO),1,6) >= cAnoMesComp)
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuario bloqueado, verifico agora se tem fator moderador ou CO para cobrar.                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet
	SIX->( dbSetorder(01) )
	If SIX->( dbSeek("BDH9") )
		BDH->(DbSetOrder(9))
		If BDH->(MsSeek(xFilial("BDH")+"1"+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			lRet 	:= .T.
			lCobAll	:= .F.
		EndIf
	Else
		aFoCoPF := PLSRETFCPF(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
							  BA3->BA3_VERSUB,BA3->BA3_CODPLA,BA3->BA3_VERSAO,BA3->BA3_TIPOUS)
							  
		If ExistBlock("PLCOBDAT")
			cAnoMesAnt := ExecBlock("PLCOBDAT", .F., .F., {cAno, cMes})
		ElseIf aFoCoPF[1] == "1"
			cAnoMesAnt := cAno+cMes
		Else
			cAnoMesAnt := PLSDIMAM(cAno,cMes,"0")
		EndIf

		aRetCO := PLSVLRPF(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),;
		Subs(cAnoMesAnt,1,4),Subs(cAnoMesAnt,5,2),{},{},.T.,.F.,nil,BA1->BA1_TIPREG)

		If Len(aRetCO) > 0
			lRet := .T.
			lCobAll	:= .F.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Usuario bloqueado, verifico agora se tem  Debitos a cobrar nos níveis de cobrança na família e no usuário .                                                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cSQL := "SELECT R_E_C_N_O_ FROM "+RetSqlName("BSQ")+" WHERE "
	cSQL += "BSQ_FILIAL = '"+xFilial("BSQ")+"' AND "
	cSQL += "BSQ_USUARI = '"+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)+"' AND "
	If BSQ->(FieldPos("BSQ_COBNIV")) > 0
			cSQL += "(BSQ_COBNIV = '3' or BSQ_COBNIV = '4' or BSQ_COBNIV = '5') AND "
	EndIf

	cSQL += "BSQ_ANO || BSQ_MES <= '"+cAno+cMes+"' AND "
	cSQL += "D_E_L_E_T_ = ' ' AND "
	cSql += "BSQ_NUMCOB = ' ' "
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBA1",.F.,.T.)

	If !TRBA1->( Eof() )
		lRet := PlsBlqDC(BA1->BA1_DATBLO, BA1->BA1_MOTBLO, BA1->BA1_CONSID) 
		lCobAll	:= .F.
	EndIf

	TRBA1->( dbCloseArea() )
EndIf

RestArea(aArea)
If lRet //Trata se ja foi cobrado na rotina que cobra o dependente no ato da inclusao
   If BA1->BA1_CB1AMS == "1" .And. Subs(dtos(BA1->BA1_DATINC),1,6) == cAno+cMes
      lRet := .F.
   EndIf
EndIf

If !lRet .And. lConsidDB .And. FunName()=="PLSA101" .And. !Empty (BA1->BA1_MOTBLO) .And. lOnlyLook
	lRet:= .T.
EndIF

Return({lRet,lCobAll})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRFSL  ³ Autor ³ Daher		      ³ Data ³ 1.02.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Calcula o valor da faixa salarial  todos os usuarios de uma³±±
±±³          ³ familia com seu respectivo valor de cobranca neste ano/mes ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRFSL(cMatricFam,cAno,cMes,cForPag,aUsuarios,nSalrio,lOnlyLook)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cOpeFam  		:= Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp  		:= Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric  		:= Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL cFilB1C  		:= xFilial("B1C")
LOCAL cNameB1C 		:= B1C->(RetSQLName("B1C"))
LOCAL nSalIni  		:= 0
LOCAL nSalFin  		:= 0
LOCAL nVlrFxa  		:= 0
LOCAL nSalario 		:= 0
LOCAL nPos	   		:= 0
LOCAL cSQL     		:= ""
LOCAL aFaixas  		:= {}
LOCAL aValores 		:= {}
LOCAL cFxaUtil 		:= ""
LOCAL nFor     		:= 1
LOCAL dDatBasIda	:= CtoD("01/"+cMes+"/"+cAno)
LOCAL nFatDep  		:= 0
LOCAL nCntFor  		:= 0
LOCAL aStruB1C 		:= B1C->(dbStruct())
LOCAL lB1HExi		:= .F.
LOCAL cFilB1H  		:= xFilial("B1H") 			//Iif(PLSALIASEX("B1H"), xFilial("B1H"), "")
LOCAL cNameB1H 		:= B1H->(RetSQLName("B1H"))	//Iif(PLSALIASEX("B1H"), B1H->(RetSQLName("B1H")), "")
LOCAL aStruB1H 		:= B1H->(dbStruct())		//Iif(PLSALIASEX("B1H"), B1H->(dbStruct()), {})
LOCAL aFxQtd		:= {}
LOCAL nPosQtd		:= 0
LOCAL cFxaQtd     	:= ""
LOCAL nQtdIni     	:= 0
LOCAL nQtdFin     	:= 0
LOCAL nVlrQtd     	:= 0
LOCAL nVlrUsado		:= 0
LOCAL lFaixaFamil	:=.F.
DEFAULT aUsuarios 	:= {}
DEFAULT lOnlyLook	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca a faixa salarial desta familia...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT B1C_CODFAI,B1C_VLSLIN,B1C_VLSLFN,B1C_VALOR,B1C_TIPUSR,B1C_VLSLIN,B1C_VLSLFN "
cSQL += "FROM "+cNameB1C+" WHERE "
cSQL += "B1C_FILIAL  = '"+cFilB1C+"' AND "
cSQL += "B1C_CODOPE  = '"+cOpeFam+"' AND "
cSQL += "B1C_CODEMP  = '"+cCodEmp+"' AND "
cSQL += "B1C_MATRIC  = '"+cMatric+"' AND "
cSQL += "B1C_CODFOR  = '"+cForPag+"' AND "
cSQL += "D_E_L_E_T_ = ' '"
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSFAI",.F.,.T.)


PLSBUSFAI->(DBEval( { | | aadd(aFaixas, {B1C_CODFAI,B1C_VLSLIN,B1C_VLSLFN,B1C_VALOR,B1C_TIPUSR,B1C_VLSLIN,B1C_VLSLFN} ) }))
PLSBUSFAI->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analiso cada usuario...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aUsuarios) == 0
   aUsuarios := PLSLOADUSR(cOpeFam,cCodEmp,cMatric,cAno,cMes,,lOnlyLook)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mes subsequente, com conteudo = 2.									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLSBASI","1")=="2"
	dDatBasIda := dDatBasIda - 1
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ For aUsuarios														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 To Len(aUsuarios)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array com a mesma faixa de acordo com o usuario atual...      ³
	//³ Busca o valor da taxa de acordo com o usuario atual...              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lPLSBSIDA
       dDatBasIda := ExecBlock("PLSBSIDA",.F.,.F.,{"4",dDatBasIda,aUsuarios[nFor],cMes,cAno,cMatricFam})
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula idade														³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nIdade      := Calc_Idade(dDatBasIda,aUsuarios[nFor,2])
    nIdade		:= Iif(nIdade < 0,0,nIdade)
    cNivelUtil  := "B1C"
    cFaixaUtil  := ""
    nSalario    := aUsuarios[nFor,27]
    cTipUsu     := aUsuarios[nFor,7]
	nPos 		:= 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chave 				                                                ³
	//³ TIPO DE USUARIO...                       							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPos == 0
		nPos := Ascan(aFaixas, { |x| nSalario>=x[2] .And. nSalario<= x[3] .And. x[5] == cTipUsu})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chave 				                                                ³
	//³ Verificacao generico...                   							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nPos == 0
		nPos := Ascan(aFaixas, { |x| nSalario>=x[2] .And. nSalario<= x[3] .and. x[5] == Space(Len(BA1->BA1_TIPUSU))})
	EndIf

	// Achou a faixa. Agora verifica se existe faixa de quantidade para a faixa salarial.
	If nPos > 0

		If B1H->(FieldPos("B1H_FAIFAM")) > 0
			cSQL := "SELECT B1H_CODFAI,B1H_QTDINI,B1H_QTDFIN,B1H_VALOR,B1H_FAIFAM "
		Else
			cSQL := "SELECT B1H_CODFAI,B1H_QTDINI,B1H_QTDFIN,B1H_VALOR  "
		Endif
		cSQL += "FROM "+cNameB1H+" WHERE "
		cSQL += "B1H_FILIAL  = '"+cFilB1H+"' AND "
		cSQL += "B1H_CODOPE  = '"+cOpeFam+"' AND "
		cSQL += "B1H_CODEMP  = '"+cCodEmp+"' AND "
		cSQL += "B1H_MATRIC  = '"+cMatric+"' AND "
		cSQL += "B1H_CODFOR  = '"+cForPag+"' AND "
		CSQL += "B1H_CODFAI  = '"+aFaixas[nPos][1]+"' AND "
		cSQL += "D_E_L_E_T_ = ' '"

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSFAI",.F.,.T.)

		If B1H->(FieldPos("B1H_FAIFAM")) > 0
			PLSBUSFAI->(DBEval( { | | aadd(aFxQtd, {B1H_CODFAI,B1H_QTDINI,B1H_QTDFIN,B1H_VALOR,B1H_FAIFAM} ) }))
		Else
			PLSBUSFAI->(DBEval( { | | aadd(aFxQtd, {B1H_CODFAI,B1H_QTDINI,B1H_QTDFIN,B1H_VALOR} ) }))
		Endif
		PLSBUSFAI->(DbCloseArea())

		// Quantidade de pessoas na familia.
		nQtdUsr := Len(aUsuarios)

		// Procura por uma faixa de quantidade
		nPosQtd := Ascan(aFxQtd, { |x| nQtdUsr >= x[2] .And. nQtdUsr <= x[3] })

		// Se encontrar uma faixa de quantidade, valoriza por ela.
		If nPosQtd > 0 .and. aFxQtd[nPosQtd,4] > 0
			// Obtem os dados de uma faixa de quantidade.
			cFxaQtd     := aFxQtd[nPosQtd,1]
			nQtdIni     := aFxQtd[nPosQtd,2]
			nQtdFin     := aFxQtd[nPosQtd,3]
			nVlrQtd     := aFxQtd[nPosQtd,4]
	
			If B1H->(FieldPos("B1H_FAIFAM")) > 0
				lFaixaFamil:=(aFxQtd[nPosQtd,5]=="1") //determina se aplicarei para todos os usuarios quando conteudo for <> 1 o valor ou somente o valor ao tilutar caso seja conteudo 1
			Endif

			lB1HExi := .T.
		Endif
	
		cFxaUtil    := aFaixas[nPos,1]
		nSalIni     := aFaixas[nPos,2]
		nSalFin     := aFaixas[nPos,3]
		nVlrFxa     := aFaixas[nPos,4]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valor da mensalidade para este usuario ... 						    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aValores,{aUsuarios[nFor,13],;						// 01
		                  Iif(lB1HExi, nVlrQtd, nVlrFxa),;		// 02
		                  str(nIdade,3),;						// 03
		                  aUsuarios[nFor,3],;					// 04
		                  aUsuarios[nFor,5],;					// 05 cSexo
		                  aUsuarios[nFor,6],;					// 06 cGrauPa
		                  aUsuarios[nFor,4],;					// 07
		                  cFxaUtil,;                            // 08
		                  cNivelUtil,;                          // 09
		                  aUsuarios[nFor,7],;					// 10 cTipUsu
		                  aUsuarios[nFor,8],;                   // 11
		                  aUsuarios[nFor,9],;                   // 12
		                  ,;									// 13 nValorRat
		                  ,;									// 14 nDiasUtil
		                  ,;									// 15
		                  ,;									// 16
		                  nSalIni,;								// 17
		                  nSalFin,;								// 18
						  aUsuarios[nFor,29],;					// 19 - Versao do plano
    					  aUsuarios[nFor,31]})	                // 20- Tipo de fornecedor

    	If lFaixaFamil	//determina se aplicarei para todos os usuarios quando conteudo for <> 1 o valor ou somente o valor ao tilutar caso seja conteudo 1
    	   exit
    	Endif

    EndIf
Next

If lPlsVlr1c 
	aRetPto := ExecBlock("PLSVLRB1C",.F.,.F.,aValores)

	If ValType(aRetPto) == "A"
		aValores := aClone(aRetPto)
	EndIf
EndIf

Return(aValores)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSBUSFSL  ³ Autor ³ Daher		      ³ Data ³ 30.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Trata a forma de cobranca por faixa salarial               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBUSFSL(cMatricFam,cAno,cMes,cForPag,aEventosCB,aCliente,aUsuarios,lDireto ,lOnlyLook,cRdMake,aFoCoPF,aLanUsu,cNumCob,cReemb,lDatPagto,dDatPagto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nFor
LOCAL nAux
LOCAL nValor2Via
LOCAL aValorRet
LOCAL cTipEve
LOCAL nValorEve
LOCAL nValorJur
LOCAL cCodEve
LOCAL cCodEveOri
LOCAL cDesEveOri
LOCAL cCargo
LOCAL cMatUsu
LOCAL cNomUsr
LOCAL lTotal
LOCAL cSexo
LOCAL cGrauPa
LOCAL cFiller
LOCAL cCodFai
LOCAL cNivFai
LOCAL cTipUsu
LOCAL cAlias
LOCAL cOrigem
LOCAL cBaseIr
LOCAL nIdaIni    := 0
LOCAL nIdaFin    := 0
LOCAL cOpeFam    := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp    := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric    := Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL _cChave	 := ''
LOCAL lPulaPF    := .F.
LOCAL lByPassDC	 := .F.
LOCAL lFatura    := .F.
LOCAL cTitular   := ""
LOCAL cVerba     := ""
LOCAL nSeq       := 0
LOCAL nFxaIni	 := 0
LOCAL nFxaFin    := 0
LOCAL nSaldo1	 := 0
LOCAL nSaldo2    := 0
LOCAL nVlrMes	 := 0
LOCAL nTotSal	 := 0
LOCAL aVerFun    := {}
LOCAL aRet 		 := {}
LOCAL aRetFun 	 := {}
LOCAL _cChavFun	 := ""
LOCAL cCodDB     := PLSRETLADC()
LOCAL nRecno	 := 0
LOCAL cAnoMesAnt := ""
LOCAL lCusOpe    := .F.
LOCAL bAdVet     := { || nSeq ++, AaDd( aRet,{	cTipEve,;
			                                    nValorEve,;
			                                    cCodEve,;
			                                    cCodEveOri,;
			                                    cDesEveOri,;
			                                    cCargo,;
			                                    cMatUsu,;
			                                    cNomUsr,;
			                                    lTotal,;
			                                    cSexo,;
			                                    cGrauPa,;
			                                    cFiller,;
			                                    cCodFai,;
			                                    cNivFai,;
			                                    cTipUsu,;
			                                    cAlias,;
			                                    cOrigem,;
			                                    cBaseIr,;
			                                    StrZero(nSeq,4),;
			                                    nFxaIni,;
			                                    nFxaFin,;
			                                    cVerba,;
			                                    nVlrMes,;           //23
			                                    nSaldo1,;           //24
			                                    nSaldo2,;           //25
			                                    nTotSal,;           //26
			                                    nRecno,;            //27
			                                    0,;					//28
			                                    0,;					//29
			                                    "",;				//30
			                            		"",;				//31
												0,;					//32
												0,;					//33
												cCodPla,;				//34 - Codigo do plano
												cVerPla,;				//35 - Versao do plano
												cDesPla,;				//36 - Descricao do plano
												cCodSB1,;				//37 - Codigo do Produto SB1 ERP
												cCodTES,;               //38 - Codigo da TES SB1 ERP
												0,;						//39 - Recno do BM1 para uso generico
												0,;         			//40 - Total do desconto aglutinado para o item - integracao com a nota de saida.
												cAno,;                  //41 - Ano de Competencia do lançamento - Para utilizar Periodicidade
												cMes,;					//42 - Mes de Competencia do lançamento - Para utilizar Periodicidade
												lCusOpe,;              //43 - Se e lancamento de custo operacional ou nao
												.F.,;          			//44-PARCELAMENTO (reservado)
												cTpPlan,;               //45- Tipo do Plano no modulo Gestão de Pessoal
												cTpforn ,;              //46- Tipo de fornecedor do plano (1-Ass. Medica; 2 =Ass. Odontologica
												cCodFor,;               //47- Codigo do fornecedor do plano
												cSeqDep,; 				//48- codigo do dependente
												cPlanGPE,;				//49-codigo do plano do GPE
												lPatroDif})} 			//50-Patronal diferenciado (Acordo ANS CApesesp)


Local lDirf11 := (SRB->(FieldPos("RB_VBDESAM"))>0 .and. SRB->(FieldPos("RB_VBDESAO"))>0 .and. BA1->(FieldPos("BA1_CODDEP"))>0 )
Local Ix:=0
Local _cNivel := "1"
Local cFunNa  := FunName()

DEFAULT aCliente  := {}
DEFAULT aUsuarios := {}
DEFAULT cRdMake   := "PLSPORFAI"
DEFAULT aFoCoPF	  := {"0","2"}
DEFAULT aLanUsu	  := {}
DEFAULT lDireto	  := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aUsuario															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aUsuarios) == 0
   aUsuarios  := PLSLOADUSR(cOpeFam,cCodEmp,cMatric,cAno,cMes,,lDireto)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o nivel de cobranca e o cliente...		                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCliente) == 0
	aCliente := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,;
						  BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),;
						  BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
						  BA3->BA3_VERSUB,1)
EndIf

If Len(aCliente) > 0 .and. !lOnlyLook 	// !lOnlyLook inserido, porque em casos de relatorio de valores, nao eh nescessario saber se
										// ja foi faturado ou nao... quero saber somente o valor do usuario!
	_cNivel := aCliente[1][18]
	If _cNivel == "1" // Empresa
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP

	Elseif _cNivel == "2" //Nivel contrato
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON

	Elseif _cNivel == "3"  //Nivel subcontrato
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB

	Elseif _cNivel == "4" //Nivel familia
		_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC

	Elseif _cNivel == "5" //Usuario
		// encontrar uma chave para o usuario...
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se houve faturas no mes... atualiza o valor do flag...     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! lPlsFimCb
	   BBT->(DbSetOrder(Val(_cNivel)))
	   If BBT->(MsSeek(xFilial("BBT")+_cNivel+_cChave+cAno+cMes))
	      lFatura := .T.
	   EndIf
	Else
	   lFatura := ExecBlock("PLSFTMCB",.F.,.F.,{_cNivel,_cChave,cAno,cMes})
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa um for para todos os eventos que devem ser calculados...    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 To Len(aEventosCB)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os codigos definidos em cCodigosPF so sao processados uma unica vez ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aEventosCB[nFor,1] $ cCodigosPF .And. lPulaPF
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os codigos definidos em cCodDB so sao processados uma unica vez 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aEventosCB[nFor,1] $ cCodDB	.and. lByPassDC
		Loop
	EndIf
	lPatroDif:=.f.    //Patronal diferenciado (Acordo ANS CApesesp)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensalidade...                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  aEventosCB[nFor,1] == "101" .and. !lFatura
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| esse aRetFun retorna o valor das faixas salariais de todos usuarios |
		//| de uma familia incluidos na database da familia                     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetFun := PLSVLRFSL(cMatricFam,cAno,cMes,cForPag,aUsuarios,nil, lDireto)
		For nAux := 1 To Len(aRetFun)
			cTipEve    := aEventosCB[nFor,3]
			nValorEve  := aRetFun[nAux,2]
			cCodEve    := aEventosCB[nFor,1]
			cCodEveOri := aRetFun[nAux,11]
			cDesEveOri := upper(aRetFun[nAux,12])
			cCargo     := ""
			cMatUsu    := aRetFun[nAux,1]
			cNomUsr    := aRetFun[nAux,4]
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := aRetFun[nAux,8]
			cNivFai    := aRetFun[nAux,9]
			cTipUsu    := ""
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := aEventosCB[nFor,4]
			nFxaIni    := 0
			nFxaFin    := 0
			// ATENCAO AQUI NO FUTURO EU VOU PASSAR AS FAIXAS QUE VAO LA PRO BM1 POIS HJ NO BM1 NAO TEM O CAMPO FAIXA SALARIAL INICIAL
			// nFxaIni    := aRetFun[nAux,17]
			// nFxaFin    := aRetFun[nAux,18]
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],'')
			nVlrMes    := If(Len(aRetFun[nAux])>20,If(aRetFun[nAux,21]>0,aRetFun[nAux,21],nValorEve),nValorEve) //nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			cCodPla := aRetFun[nAux,11]
			cVerPla := aRetFun[nAux,19]
			cDesPla := aRetFun[nAux,12]
			cCodSB1 := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
			cTpForn  := aRetFun[nAux,20]

            If lDirf11 

				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif


			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif

			Eval(bAdVet)
		Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcionais ...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Elseif aEventosCB[nFor,1] == "102" .and. ( !lFatura .or. aEventosCB[nFor,5]$'1' )
		aRetOpc := PLSVALOPC(cMatricFam,cAno,cMes,aUsuarios,cRdMake)
		For nAux := 1 To Len(aRetOpc)
			cTipEve    := aEventosCB[nFor,3]
			nValorEve  := aRetOpc[nAux,2]
			cCodEve    := aEventosCB[nFor,1]
			cCodEveOri := aRetOpc[nAux,11]
			cDesEveOri := upper(aRetOpc[nAux,12])
			If aRetOpc[nAux,15] == 0
				cCargo := aRetOpc[nAux,3]
			Else
				cCargo := STR0034+Str(aRetOpc[nAux,16],2)+STR0035 //"Cobranca Pro-Rata de "###" Dia(s)"
			EndIf
			cMatUsu    := aRetOpc[nAux,1]
			cNomUsr    := aRetOpc[nAux,4]
			lTotal     := .F.
			cSexo      := aRetOpc[nAux,5]
			cGrauPa    := aRetOpc[nAux,6]
			cFiller    := ""
			cCodFai    := aRetOpc[nAux,8]
			cNivFai    := aRetOpc[nAux,9]
			cTipUsu    := aRetOpc[nAux,10]
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := aEventosCB[nFor,4]
			nFxaIni    := 0
			nFxaFin    := 0
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],'')
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0

			cCodPla 	:= aRetOpc[nAux,20]
			cDesPla 	:= aRetOpc[nAux,21]
			cVerPla 	:= aRetOpc[nAux,22]
			cCodSB1 	:= MontaSB1(aEventosCB,nFor,cCodEve,cCodEveOri,cOpeFam,cMatUsu,_cNivel)
			cCodTES 	:= MontaTES(aEventosCB,nFor,cCodSB1,cCodEveOri,cCodEve,cOpeFam,cMatUsu,_cNivel)

			cTpForn  := aRetOpc[nAux,29]

            If lDirf11 

				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif


			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif



			Eval(bAdVet)
		Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Taxa de Inscricao/Adesao...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf aEventosCB[nFor,1] == "103" .And. !lFatura .and. cReemb <> "1"
		aRetFun := PLSVALADE(cMatricFam,cAno,cMes,aUsuarios,aRet,lOnlyLook)

		For nAux := 1 To Len(aRetFun)

			cTipEve    := aEventosCB[nFor,3] //Debito/Credito
			cCodEve    := aEventosCB[nFor,1] //Codigo do Lancamento

			nValorEve  := aRetFun[nAux,2]
			cCodEveOri := aEventosCB[nFor,1] //Codigo do Lancamento
			cDesEveOri := aEventosCB[nFor,2] //Descricao do Lancamento

			cCargo     := aRetFun[nAux,3]
			cMatUsu    := aRetFun[nAux,1]
			cNomUsr    := aRetFun[nAux,4]
			lTotal     := .F.
			cSexo      := aRetFun[nAux,5]
			cGrauPa    := aRetFun[nAux,6]
			cFiller    := ""
			cCodFai    := aRetFun[nAux,8]
			cNivFai    := aRetFun[nAux,9]
			cTipUsu    := aRetFun[nAux,10]
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := aEventosCB[nFor,4]
			nIdaIni    := aRetFun[nAux][13]
			nIdaFin    := aRetFun[nAux][14]
			nVlrMes    := nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0
			nRecno     := 0
			nValDes	   := aRetFun[nAux][15]
			nValAcre   := aRetFun[nAux][16]
			cCodSeq	   := ''
			cCompRea	:= ''
			nValAtual	:= 0
			nValAnter	:= 0
			cCodPla		:= aRetFun[nAux][11]
			cDesPla		:= aRetFun[nAux][12]
			cVerPla		:= aRetFun[nAux][17]
			cCodSB1 	:= MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES 	:= MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
			If ctipUsu =="T".OR. !lDirf11
				cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")
			else
				cVerba:= MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,aRetFun[nAux][18])
		    endif
		    cTpForn  := aRetFun[nAux,18]

            If lDirf11 //.OR. aEventosCB[nFor,25] <>'1'

				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif


			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif
			Eval(bAdVet)
		Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Debito / Creditos...                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf aEventosCB[nFor,1] $ cCodDB .And. ( !lFatura .Or. aEventosCB[nFor,5] $ '1' ) .and. cReemb <> "1"

		If aEventosCB[nFor,1] $ cCodDB .And. BSP->(FieldPos("BSP_CODLAN")) > 0

			aRetFun := PLSSLDDCF(cMatricFam,cAno,cMes,aUsuarios,aEventosCB[nFor,1],lOnlyLook,_cNivel,_cChave,cNumCob,Iif(cFunNa $ 'PLSA730,PLSA174',.F.,.T.))

			lByPassDC := .T.
			For nAux := 1 To Len(aRetFun)

				cTipEve    := aRetFun[nAux,5] 	//Debito/Credito
				cCodEve    := aRetFun[nAux,10] //Codigo do Lancamento

				nValorEve  := aRetFun[nAux,6]
				cCodEveOri := IIf(Empty(aRetFun[nAux,14]),aRetFun[nAux,3],aRetFun[nAux,14])//Codigo do Lancamento
				cDesEveOri := IIf(Empty(aRetFun[nAux,15]),aRetFun[nAux,4],aRetFun[nAux,15])//Descricao do Lancamento

				cCargo     := ""
				cMatUsu    := aRetFun[nAux,1]
				cNomUsr    := aRetFun[nAux,2]
				lTotal     := .F.
				cSexo      := ""
				cGrauPa    := ""
				cFiller    := ""
				cCodFai    := ""
				cNivFai    := ""
				cTipUsu    := aRetFun[nAux,16]
				cAlias     := "BSQ"
				cOrigem    := aRetFun[nAux,7]
				cBaseIr    := ""
				nIdaIni    := 0
				nIdaFin    := 0
				nVlrMes    := nValorEve
				nSaldo1    := 0
				nSaldo2    := 0
				nTotSal    := 0
				nRecno     := aRetFun[nAux,8]
				nValDes	   := 0
				nValAcre   := 0
				cCodSeq	   := aRetFun[nAux,9]
				cCompRea   := ''
				nValAtual  := 0
				nValAnter  := 0
				cCodPla    := aRetFun[nAux,11]
				cDesPla    := aRetFun[nAux,12]
				cVerPla    := aRetFun[nAux,13]
			    cCodSB1    := MontaSB1(aEventosCB,nFor,cCodEve,cCodPla,cOpeFam,cMatUsu,_cNivel)
			    cCodTES    := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)

		    	If ctipUsu =="T".OR. !lDirf11
					npos:=Ascan(aEventosCB,{|X| X[1] ==cCodeve})
					cVerba     := if(len(aEventosCB[npos]) >= 18,aEventosCB[npos,18],"")
		   		else
					cVerba:= MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,aRetFun[nAux,17])
				Endif

		   		cTpForn  := aRetFun[nAux,17]

	            If lDirf11 //.OR. aEventosCB[nFor,25] <>'1'

					aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
					If Len(aDadGPE)>0
						cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]
					Endif
				Endif


				If lPLSINTFOL
					aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
					If Len(aDadGpe)>0
						cVerba:=aDadgpe[1]
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cTpForn  := aDadGPE[6]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]

					Endif
				Endif


				Eval(bAdVet)
			Next
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcionais ...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Elseif aEventosCB[nFor,1] == "186" .and. ( !lFatura .or. aEventosCB[nFor,5]$'1' )

		aRetFun := PLSVLRRP(cMatricFam,cAno,cMes,cForPag,aUsuarios,nil, lDireto)

		For Ix:=1 to Len(aRetFun)
			If aRetFun[Ix,21] > 0 // existe a patronal diferenciada acordo Ans
				lPatroDif:=.T.    //Patronal diferenciado (Acordo ANS CApesesp)
            	Exit
			Endif
		Next

		For nAux := 1 To Len(aRetFun)
			cTipEve    := aEventosCB[nFor,3]
			nValorEve  := aRetFun[nAux,2]
			cCodEve    := aEventosCB[nFor,1]
			cCodEveOri := aRetFun[nAux,11]
			cDesEveOri := upper(aEventosCB[nFor,2])
			cCargo     := ""
			cMatUsu    := aRetFun[nAux,1]
			cNomUsr    := aRetFun[nAux,4]
			lTotal     := .F.
			cSexo      := ""
			cGrauPa    := ""
			cFiller    := ""
			cCodFai    := aRetFun[nAux,8]
			cNivFai    := aRetFun[nAux,9]
			cTipUsu    := ""
			cAlias     := ""
			cOrigem    := ""
			cBaseIr    := aEventosCB[nFor,4]
			nFxaIni    := 0
			nFxaFin    := 0
			// ATENCAO AQUI NO FUTURO EU VOU PASSAR AS FAIXAS QUE VAO LA PRO BM1 POIS HJ NO BM1 NAO TEM O CAMPO FAIXA SALARIAL INICIAL
			// nFxaIni    := aRetFun[nAux,17]
			// nFxaFin    := aRetFun[nAux,18]
			cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],'')
			nVlrMes    := If(Len(aRetFun[nAux])>20,If(aRetFun[nAux,21]>0,aRetFun[nAux,21],nValorEve),nValorEve) //nValorEve
			nSaldo1    := 0
			nSaldo2    := 0
			nTotSal    := 0

			cCodPla := aRetFun[nAux,11]
			cVerPla := aRetFun[nAux,19]
			cDesPla := aRetFun[nAux,12]
			cCodSB1 := MontaSB1(aEventosCB,nFor,nil,cCodPla,cOpeFam,cMatUsu,_cNivel)
			cCodTES := MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)

			cTpForn  := aRetFun[nAux,20]

	        If lDirf11 //.OR. aEventosCB[nFor,25] <>'1'

				aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
				If Len(aDadGPE)>0
					cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]
				Endif
			Endif


			If lPLSINTFOL
				aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
				If Len(aDadGpe)>0
					cVerba:=aDadgpe[1]
					cTpPlan := aDadGPE[2]
					cCodFor := aDadGPE[3]
					cTpForn  := aDadGPE[6]
					cSeqDep  := aDadGPE[4]
					cPlanGPE := aDadGPE[5]

				Endif
			Endif

			Eval(bAdVet)
		Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Custo operacional, taxa admnistrativa, fator modedador, etc         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf aEventosCB[nFor,1] $ cCodigosPF .and. ( !lFatura .or. aEventosCB[nFor,5] $ '1' )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ cAnoMesAnt															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PLCOBDAT")
			cAnoMesAnt := ExecBlock("PLCOBDAT", .F., .F., {cAno, cMes})
		ElseIf aFoCoPF[1] == "1"
			cAnoMesAnt := cAno+cMes
		Else
			cAnoMesAnt := PLSDIMAM(cAno,cMes,"0")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PLSVLRPF															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetFun := PLSVLRPF(cMatricFam,Subs(cAnoMesAnt,1,4),Subs(cAnoMesAnt,5,2),aUsuarios,aEventosCB)
		aRetFun	:= aClone(aRetFun[1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena os numeros de registros para marcar como faturada ao logo do processo...  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lPulaPF    := .T.
		If !ValType(aRetFun) == 'U'
			For nAux := 1 To Len(aRetFun)

				cTipEve    	:= aRetFun[nAux,3] //Debito/Credito
				cCodEve    	:= aRetFun[nAux,1] //Codigo do Lancamento

				nValorEve  	:= aRetFun[nAux,5]
				cCodEveOri 	:= aRetFun[nAux,1] //Codigo do Lancamento
				cDesEveOri 	:= aRetFun[nAux,2] //Descricao do Lancamento

				cCargo     	:= ""
				cMatUsu    	:= aRetFun[nAux,6]
				cNomUsr    	:= aRetFun[nAux,7]
				lTotal     	:= .F.
				cSexo      	:= ""
				cGrauPa    	:= ""
				cFiller    	:= ""
				cCodFai    	:= ""
				cNivFai    	:= ""
				cTipUsu    	:= aRetFun[nAux,12]
				cAlias     	:= ""
				cOrigem    	:= ""
				cBaseIr    	:= aEventosCB[nFor,4]
				nIdaIni    	:= 0
				nIdaFin    	:= 0
				nVlrMes    	:= nValorEve
				nSaldo1    	:= 0
				nSaldo2    	:= 0
				nTotSal    	:= 0
				nRecno     	:= aRetFun[nAux,11]
				nValDes	   	:= 0
				nValAcre   	:= 0
				cCodSeq	   	:= ''
				cCompRea	:= ''
				nValAtual	:= 0
				nValAnter	:= 0
				cCodPla 	:= aRetFun[nAux,08]
				cDesPla 	:= aRetFun[nAux,09]
				cVerPla	 	:= aRetFun[nAux,10]
				cCodSB1 	:= MontaSB1(aEventosCB,nFor,cCodEve,cCodPla,cOpeFam,cMatUsu,_cNivel)
				cCodTES 	:= MontaTES(aEventosCB,nFor,cCodSB1,cCodPla,cCodEve,cOpeFam,cMatUsu,_cNivel)
				If ctipUsu =="T".OR. !lDirf11
					 cVerba     	:= if(len(aEventosCB[nFor]) >= 18,If( (nI:=aScan(aEventosCB,{|x| x[1] == aRetFun[nAux,1]})) > 0 ,aEventosCB[nI,18],''),'')
				else
					cVerba:= MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,aRetFun[nAux,13])
                endif

				cTpForn  := aRetFun[nAux,13]

		        If lDirf11 //.OR. aEventosCB[nFor,25] <>'1'

					aDadGPE:=MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,,cTpForn)
					If Len(aDadGPE)>0
						cVerba:= If(aEventosCB[nFor,25] <>'1',cVerba,aDadGPE[1] )
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]
					Endif
				Endif


				If lPLSINTFOL
					aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{cCodEve,cMatUsu,cCodPla,cVerPla,cOpeFam,cTpPlan,cCodFor,cTpForn,cSeqDep,cPlanGpe,cVerba})
					If Len(aDadGpe)>0
						cVerba:=aDadgpe[1]
						cTpPlan := aDadGPE[2]
						cCodFor := aDadGPE[3]
						cTpForn  := aDadGPE[6]
						cSeqDep  := aDadGPE[4]
						cPlanGPE := aDadGPE[5]

					Endif
				Endif


				Eval(bAdVet)
			Next
    	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pego o lancamento de usuario...                                     ³
	//| Este ponto de entrada tem 2 momentos, o primeiro eh quando eu estou |
	//| apurando os valores o segundo eh qando eu estou gravando o BM1		|
	//| o que diferencia estes momentos eh o parametro de numero 10			|
	//| '1' - ESTOU APURANDO                                                |
	//| '2' - ESTOU GRAVANDO O BM1											|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf (aScan(aLanUsu,{|x| x[1] == aEventosCB[nFor,1]}) > 0)  .and. !lFatura

		If ExistBlock(aEventosCB[nFor,21])
			aRetFun := Execblock(aEventosCB[nFor,21],.F.,.F.,{cMatricFam,cAno,cMes,cForPag,aUsuarios,lDireto,_cNivel,_cChave,aEventosCB,'1'})
            If !ValType(aRetFun) == 'U'
				For nAux := 1 To Len(aRetFun)
					If Len(aRetFun[nAux]) >= 16
						cTipEve    := aEventosCB[nFor,3]
						nValorEve  := aRetFun[nAux,2]
						cCodEve    := aEventosCB[nFor,1]
						cCodEveOri := aRetFun[nAux,11]
						cDesEveOri := aRetFun[nAux,12]
						cCargo 	   := aRetFun[nAux,3]
						cMatUsu    := aRetFun[nAux,1]
						cNomUsr    := aRetFun[nAux,4]
						lTotal     := .F.
						cSexo      := aRetFun[nAux,5]
						cGrauPa    := aRetFun[nAux,6]
						cFiller    := ""
						cCodFai    := aRetFun[nAux,8]
						cNivFai    := aRetFun[nAux,9]
						cTipUsu    := aRetFun[nAux,10]
						cAlias     := ""
						cOrigem    := aRetFun[nAux,7]
						cBaseIr    := aEventosCB[nFor,4]
						nIdaIni    := aRetFun[nAux,15]
						nIdaFin    := aRetFun[nAux,16]
						cVerba     := if(len(aEventosCB[nFor]) >= 18,aEventosCB[nFor,18],"")
						nVlrMes    := nValorEve
						nSaldo1    := 0
						nSaldo2    := 0
						nTotSal    := 0


						Eval(bAdVet)




					EndIf
				Next
			EndIf
        EndIf
	EndIf
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao com a matriz com o valor a ser cobrado...         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( aRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pls260Blq ºAutor  ³Thiago Machado      º Data ³  10/25/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se o motivo do bloq. do usr. permite faturamento... º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BA1 deve estar posicionado.                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSBLQFAT(dDatBlo, cMotBlo, cOrigBlo)
LOCAL cPermFat := ''

If dDatBlo <> ctod("")

	If cOrigBlo == "U"
		cPermFat := Posicione("BG3",1,xFilial("BG3")+cMotBlo,"BG3_BLOFAT")
	Elseif cOrigBlo == "F"
		cPermFat := Posicione("BG1",1,xFilial("BG1")+cMotBlo,"BG1_BLOFAT")
	Elseif cOrigBlo == "S"
		cPermFat := Posicione("BQU",1,xFilial("BQU")+cMotBlo,"BQU_BLOFAT")
	EndIf

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cPermFat=='0')
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSMCOB2  ºAutor  ³Microsiga           º Data ³  04/26/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLPROUSR(cOpeFam)
LOCAL cCodPla := ''
LOCAL cVersao := ''
LOCAL cForTax := ''
LOCAL cTpFor  := ''

If !Empty(BA1->BA1_CODPLA)
	cCodPla := BA1->BA1_CODPLA
	cVersao := BA1->BA1_VERSAO
Else
	cCodPla := BA3->BA3_CODPLA
	cVersao := BA3->BA3_VERSAO
EndIf

BI3->(DbSetOrder(1))
BI3->(MsSeek(xFilial("BI3")+cOpeFam+cCodPla+cVersao))

If BI3->(Found())
   cCodPla := BI3->BI3_CODIGO
   cDesPla := BI3->BI3_DESCRI
   cForTax := BA3->BA3_FORCTX
   cTpFor  := If(BI3->(Fieldpos("BI3_TPFORN"))>0,BI3->BI3_TPFORN,'')
Else
   cCodPla := "???"
   cDesPla := STR0065 //"Produto nao encontrado no cadastro"
   cForTax := "???"
   cTpFor  := "?"
EndIf

Return({cCodPla,cDespla,cForTax,cVersao,cTpfor})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCBMSINC ³ Autor ³ Tulio Cesar       ³ Data ³ 02.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Cobra mensalidade para novos depedentes.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCBMSINC(aMatricsCob,lMsgInf,cChavCob,cNivCob, cAno, cMes)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aVlrFam    := {}
LOCAL aVlrCob
LOCAL cMatricFam := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
LOCAL nFor
LOCAL nVlr       := 0
LOCAL nOrdBA1    := BA1->(IndexOrd())
LOCAL nRecBA1    := BA1->(Recno())
LOCAL bRest      := { || BA1->(DbGoto(nRecBA1)), BA1->(DbSetOrder(nOrdBA1)) }
LOCAL lOk
LOCAL aRet
LOCAL cSeq
LOCAL cTipTit    := GetNewPar("MV_PLSTPTA","FT")
LOCAL cPrefixo   := GetNewPar("MV_PLPFE18","PLS")
LOCAL cNumero
LOCAL nSize
LOCAL aAux       := {}
LOCAL nPos
LOCAL aMsgGer    := {}
LOCAL aNumTit	 := {}
LOCAL lExibMat
LOCAL aVlrAux	 := {}
DEFAULT lMsgInf  := .T.
DEFAULT cChavCob := ''
DEFAULT cNivCob  := ''
DEFAULT cAno     := PLSSTRANO(dDataBase,.T.)
DEFAULT cMes     := PLSSTRMES(dDataBase)

If BA1->(FieldPos("BA1_CB1AMS")) == 0
   MsgInfo(STR0066) //"Campo BA1_CB1AMS fundamental para a utilizacao desta rotina. Favor atualizar a versao."
   Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja foi cobrado p nao cobrar de novo...                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BA1->( FieldPos("BA1_CB1AMS") ) > 0
	For nFor := 1 To Len(aMatricsCob)
		BA1->(DbSetOrder(2))
		If BA1->(DbSeek(xFilial("BA1")+aMatricsCob[nFor])) .And. BA1->BA1_CB1AMS <> "1"
			aadd(aAux,aMatricsCob[nFor])
		EndIf
	Next
EndIf

If Len(aAux) == 0
   MsgInfo(STR0067) //"Nao existem usuario(s) a ser(em) cobrado(s)."
   Eval(bRest)
   Return
Else
   aMatricsCob := aClone(aAux)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca o valor da familia...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aVlrFam := PLSVLRFAM(cMatricFam,,,,,,,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa correto retorno da funcao que devolve o valor de cobranca...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aVlrFam[1,1]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta matriz com estrutura basica para armazenar a composicao de cobranca... |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aVlrAux := {{.T.,{},0,"C"},{},{},{},{},{},{}}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Resume a matriz de valor de cobranca para melhorar a performance...          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aVlrCob := Aclone(aVlrFam[1,2])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca os valores de cada usuario...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(aVlrCob)
		If Ascan(aMatricsCob,aVlrCob[nFor,7]) > 0
			Aadd(aVlrAux[1][2], aVlrCob[nFor])
			nVlr += aVlrCob[nFor,2]
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso tenha valor gero titulo a receber...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVlr > 0
		lOk := .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava respectivo titulo a receber...                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA1->(DbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+BA3->(BA3_CODCLI+BA3_LOJA)))

	  		If PLSA760(	BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC,;
  						cAno,;
  						cMes,;
  						.F.,;
  						BA3->BA3_BCOCLI,;
  						"3",;
  						"4",;
  						dDataBase,;
  						dDataBase,;
  						aVlrAux,;
  						NIL,;
  						NIL,;
  						NIL,;
  						NIL,;
  						'0')

				For nFor := 1 To Len(aVlrCob)
					nPos := Ascan(aMatricsCob,aVlrCob[nFor,7])
					If nPos > 0
						BA1->(DbSetOrder(2))
				   		If BA1->(MsSeek(xFilial("BA1")+aVlrCob[nFor,7]))
							BA1->(RecLock("BA1",.F.))
								BA1->BA1_CB1AMS := "1"
								BA1->BA1_CBTXAD := "1"
							BA1->(MsUnLock())
							lExibMat := Ascan(aMsgGer,{|x| x[1] == aVlrCob[nFor,7] }) == 0
							BFQ->(DbSetOrder(1))
							BFQ->(DbSeek(xFilial("BFQ")+BA3->BA3_CODINT+aVlrCob[nFor,3]))

							If lExibMat
								aadd(aMsgGer,{aVlrCob[nFor,7],BA1->BA1_NOMUSR,BFQ->(BFQ_PROPRI+BFQ_CODLAN),BFQ->BFQ_DESCRI,aVlrCob[nFor,2]})
							Else
								aadd(aMsgGer,{"","",BFQ->(BFQ_PROPRI+BFQ_CODLAN),BFQ->BFQ_DESCRI,aVlrCob[nFor,2]})
							EndIf
						EndIf
					EndIf
				Next
			EndIf
        EndIf
	Else
		lOk := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ restaura dados...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bRest)

If lMsgInf
   PLSCRIGEN(aMsgGer,{ {STR0068,__cPictUsr,80} , {STR0069,"@C",200 } , {STR0070,"@C",40 }, {STR0071,"@C",200 },{STR0072,"@E 999,999.999",80 } },STR0073,.T.,STR0074+ SE1->(E1_PREFIXO+" "+E1_NUM+" "+E1_PARCELA+" "+E1_TIPO)+STR0075+AllTrim(TransForm(SE1->E1_VALOR,"@E 999,999.99"))) //"Matricula Usuario"###"Nome do Usuario"###"Cod.Lanc."###"Desc.Lanc."###"Valor"###"Valores cobrados para novo(s) dependente(s) incluido(s)."###"Titulo Gerado: "###"   Valor: "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ fim da rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := {lOK,aMsgGer}

Return(aRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSTXADOP  ³ Autor ³ Geraldo Felix Jr. ³ Data ³ 22.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Cobranca da taxa de adesao do opcional.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSTXADOP(cMatricFam,aUsuarios,cAno,cMes,aRetOpc)
LOCAL aRetFun := {}
LOCAL nFor
LOCAL dDatInc
LOCAL nPosVal
LOCAL cOpeFam    := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp    := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric    := Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL cTipReg
LOCAL cDigito
LOCAL nValTxAde	 := 0
LOCAL lEspecifico:= .T.
LOCAL nForOpc := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa a integridade da matriz...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(aUsuarios) == 0 .or. Len(aUsuarios[1]) == 0 .or. Len(aUsuarios[1]) < 26)
	Return(aRetFun)
EndIf

For nFor := 1 To Len(aUsuarios)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se pode cobrar o opcional    do usuario.. vai existir casos³
	//³ em que so podera ser cobrado o fator moderador / custo do usuario.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aUsuarios[nFor][25]
		Loop
	EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis para controle de usuarios...                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTipReg    := aUsuarios[nFor,1]
		cDigito    := aUsuarios[nFor,12]
	 For nForOpc := 1 TO Len(aRetOpc)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o usuario possui opcional a ser cobrado...              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosVal := Ascan(aRetOpc,{|x| x[1] = cOpeFam+cCodEmp+cMatric+cTipReg+cDigito })
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento especifico para cobranca de adesao do opcional...        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If lPLCBTXUS
    		lEspecifico := ExecBlock("PLCBTXUS", .F., .F., {aRetOpc,cOpeFam+cCodEmp+cMatric+cTipReg+cDigito, nPosVal} )
	    EndIf

		If nPosVal > 0 .and. lEspecifico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a faixa do opcional possui taxa de adesao...            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Posiciona na tabela BZX, se o campo BZX_NUMCOB estiver preenchido, já foi cobrada a taxa de adesão. 
			DbSelectArea("BZX")
			BZX->(DbSetOrder(1))//BZX_FILIAL + BZX_CODOPE + BZX_CODEMP + BZX_MATRIC + BZX_TIPREG + BZX_CODOPC
			If BZX->(DbSeek(xFilial("BZX") + Substr(aRetOpc[nForOpc][1],1,14) + cTipReg + aRetOpc[nForOpc][11] ))
				If aRetOpc[nForOpc][30] > 0 .And. (aScan(aRetFun,{|x| x[1] == aUsuarios[nFor,13] .And. x[4] == aRetOpc[nForOpc][11]}) == 0) .and. aRetOpc[nForOpc][1] == aUsuarios[nFor,13]  
					If ("BZX")->(FieldPos("BZX_NUMCOB")) > 0 .and. Empty(BZX->BZX_NUMCOB)
						AaDd(aRetFun,{ aUsuarios[nFor,13],; 	//01 - Matricula do beneficiario
									aUsuarios[nFor,3],; 	//02 - Nome do beneficiario
									aRetOpc[nForOpc][30],; 	//03 - Valor da faixa do opcional
									aRetOpc[nForOpc][11],; 	//04 - Codigo do plano opcional
									aRetOpc[nForOpc][12],;	//05 - Descricao do plano
									aUsuarios[nFor,08],; 	//06 - Codigo do plano / produto principal
									aUsuarios[nFor,09],;	//07 - Descricao do plano / produto principal
									aUsuarios[nFor,29],; 	//08
									aUsuarios[nFor,07],; 	//09
									aUsuarios[nFor,31]})	//10	
					EndIf				
				EndIf
			EndIf	
		EndIf
	 Next nForOpc
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna com os valores...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRetFun)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSMONVER  ³ Autor ³ Daher		      ³ Data ³ 02.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Monta os acumulados/descontos		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSMONVER(aRet,cAno,cMes,cCodInt,cCodEmp,cMatric,dData,cCodPla,cVerPla,aFoCoPF,aCliente)

Local k		  		:= 0
Local j		  		:= 0
Local i		  		:= 0
Local nPos	  		:= 0
Local nFor	  		:= 0
Local nValDes	 	:= 0
Local cChave  		:= ""
Local cMesAnt 		:= ""
Local cAnoAnt 		:= ""
Local cRdmake 		:= ""
Local aRetAcu 		:= {}
Local aEspBK2 		:= {}
Local aRetAux 		:= {}
Local aTotLan 		:= {}
Local aCliente		:= {}
Local _cNivel		:= ""
Local _cChave 		:= ""
Local lOk	  		:= .T.
Local lParcelamento	:= .F.
Local nCntFor 		:= 0
Local aStruBK2		:= {}
Local lAllDeb       := Getnewpar("MV_PLSTOTD","0")=="1"
Local lDirf11 	    := .T. 
Local aRetLct       := If(lPlsLcToDif,Execblock("PLSLCTODIF",.F.,.F.),{})

Default aCliente	:={}
If cMes == "01"
	cMesAnt := "12"
	cAnoAnt := StrZero(Val(cAno)-1,4)
Else
	cMesAnt := StrZero(Val(cMes)-1,2)
	cAnoAnt := cAno
EndIf


If Len(aCliente) = 0
	aCliente := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,;
								BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),;
								BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
							    BA3->BA3_VERSUB,1)
Endif							


If Len(aCliente) > 0

		_cNivel := aCliente[1][18]
		If _cNivel == "1" // Empresa
			_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP

		Elseif _cNivel == "2" //Nivel contrato
			_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON

		Elseif _cNivel == "3"  //Nivel subcontrato
			_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB

		Elseif _cNivel == "4" //Nivel familia
			_cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC

		Elseif _cNivel == "5" //Usuario
			// encontrar uma chave para o usuario...
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento do parcelamento.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("BK2")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pego o valor para compor a cobranca.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oPrepBK2A == nil
			cSQL := "SELECT BK2_CODINT,BK2_CODEMP,BK2_MATRIC,BK2_TIPREG,BK2_PROPRI,"
			cSQL += "BK2_DIGITO,BK2_TIPLAN,BK2_CODLAN,BK2_SALDO,BK2_SALDO2 "
			cSQL += Iif(BK2->(FieldPos("BK2_PARCEL")) > 0, ",BK2_PARCEL", "")
			cSQL += " FROM "+RetSqlName("BK2")+" WHERE "
			cSQL += "BK2_FILIAL = ?  AND "
			cSQL += "BK2_CODINT = ?  AND "
			cSQL += "BK2_CODEMP = ?  AND "
			cSQL += "BK2_MATRIC = ?  AND "
			cSQL += "BK2_ANO   <= ?  AND "
			cSQL += "BK2_MES   <= ?  AND "
			cSQL += "(BK2_SALDO	> 0 OR BK2_SALDO2	> 0) AND "
			If BK2->(FieldPos("BK2_PARCEL")) > 0
				cSQL += "BK2_PARCEL IN ('S','N') AND " // Indica que nao utiliza a rotina de parcelamento
			Endif
			cSQL += "BK2_LOTPAR <> 'S' AND " // Indica se ja foi faturado
			cSQL += "D_E_L_E_T_ = ' '"
			//cSQL := ChangeQuery(cSQL)

			oPrepBK2A:=FWPreparedStatement():New(cSQL)

		Endif

		oPrepBK2A:SetString(1,xFilial("BK2"))
		oPrepBK2A:SetString(2,cCodInt)
		oPrepBK2A:SetString(3,cCodEmp)
		oPrepBK2A:SetString(4,cMatric)
		oPrepBK2A:SetString(5,cAno)
		oPrepBK2A:SetString(6,cMes)

		cSQL := oPrepBK2A:GetFixQuery()
		PLSBUSBK2 := MpSysOpenQuery(cSQL)

		// Vrifica se é originado do parcelamento
		If BK2->(FieldPos("BK2_PARCEL")) > 0 .And. (PLSBUSBK2)->BK2_PARCEL $ "S/N"
			lParcelamento := .T.
		EndIf

		(PLSBUSBK2)->(DBEval( { | | aadd(aEspBK2, {BK2_CODINT,;
													   BK2_CODEMP,;
													   BK2_MATRIC,;
													   BK2_TIPREG,;
													   BK2_TIPLAN,;//D-DEBITO,C-CREDITO
													   BK2_CODLAN,;
													   BK2_SALDO ,;
													   BK2_DIGITO,;
													   BK2_SALDO2,;
													   BK2_PROPRI}) }))//SE USUARIO OU SISTEMA
  		(PLSBUSBK2)->(DbCloseArea())

		For nFor := 1 to Len(aEspBK2)
			lParcelamento := .T.
			cMatUsr  := aEspBK2[nFor][1]+aEspBK2[nFor][2]+aEspBK2[nFor][3]+aEspBK2[nFor][4]+aEspBK2[nFor][8]
			If (nPos := aScan(aRet,{|x|  x[3] == aEspBK2[nFor][10]+aEspBK2[nFor][6] .And.;
								          x[7] == cMatUsr})) == 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria nova linha na matriz...										³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AaDd(aRet, Array(50))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posicionamento necessario											³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BFQ->(DbSetOrder(1))
				BFQ->(MsSeek(xFilial("BFQ")+PLSIntPad()+aEspBK2[nFor][10]+aEspBK2[nFor][6]))
				BA1->(DbSetOrder(2))
				BA1->(MsSeek(xFilial("BA1")+cMatUsr))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Preenche a nova linha 												³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := Len(aRet)
				aRet[nPos][01]	:= BFQ->BFQ_DEBCRE
				aRet[nPos][02]	:= aEspBK2[nFor][7]
				aRet[nPos][03]	:= aEspBK2[nFor][10]+aEspBK2[nFor][6]
				aRet[nPos][04]	:= aEspBK2[nFor][10]+aEspBK2[nFor][6]
				aRet[nPos][05]	:= BFQ->BFQ_DESCRI //essa linha aqui nao esta 100%
		    	aRet[nPos][06]	:= ""
				aRet[nPos][07]	:= cMatUsr
				aRet[nPos][08]	:= BA1->BA1_NOMUSR
				aRet[nPos][09]	:= .F.
				aRet[nPos][10]	:= ""
				aRet[nPos][12]	:= ""
				aRet[nPos][13]	:= ""
				aRet[nPos][14]	:= ""
				aRet[nPos][15]	:= BA1->BA1_TIPUSU
				aRet[nPos][16]	:= ""
				aRet[nPos][17]	:= "BK2"
				aRet[nPos][18]	:= ""
				aRet[nPos][19]	:= StrZero(nPos,4)
				aRet[nPos][20]	:= 0
				aRet[nPos][21]	:= 0
				aRet[nPos][22]	:= BFQ->BFQ_VERBA
				aRet[nPos][23]	:= 0
				aRet[nPos][24]	:= 0
				aRet[nPos][25]	:= 0
				//aRet[nPos][26] saldo total (preenchido no próximo For)
				aRet[nPos][27]  := 0
				aRet[nPos][28]  := 0
				aRet[nPos][29]  := 0
				aRet[nPos][30]  := ""
				aRet[nPos][31]  := ""
				aRet[nPos][32]  := 0
				aRet[nPos][33]  := 0
				aRet[nPos][34]  := ""
				aRet[nPos][35]  := ""
				aRet[nPos][36]  := ""
				aRet[nPos][37]  := IIF(BFQ->(FieldPos("BFQ_CODSB1"))> 0,BFQ->BFQ_CODSB1,"")
				aRet[nPos][38]  := IIF(BFQ->(FieldPos("BFQ_CODTES"))> 0,BFQ->BFQ_CODTES,"")
				aRet[nPos][39]  := 0
				aRet[nPos][40]  := 0
			Else
				aRet[nPos][02]	+= aEspBK2[nFor][7]
			EndIf
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pego o valor de acumulados diretamento no BK2.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oPrepBK2B == nil
			cSQL := "SELECT BK2_CODINT,BK2_CODEMP,BK2_MATRIC,BK2_TIPREG,BK2_PROPRI,"
			cSQL += "BK2_DIGITO,BK2_TIPLAN,BK2_CODLAN,BK2_SALDO,BK2_SALDO2 "
			cSQL += Iif(BK2->(FieldPos("BK2_PARCEL")) > 0, ",BK2_PARCEL", "")
			cSQL += " FROM "+RetSqlName("BK2")+" WHERE "
			cSQL += "BK2_FILIAL = '"+xFilial("BK2")+"' AND "
			cSQL += "BK2_CODINT = ? AND "
			cSQL += "BK2_CODEMP = ? AND "
			cSQL += "BK2_MATRIC = ? AND "
			cSQL += "BK2_ANO   >= ? AND " // Ano corrente
			cSQL += "BK2_MES   >  ? AND " // Mes corrente
			cSQL += "(BK2_SALDO	> 0 OR BK2_SALDO2 > 0) AND "
			If BK2->(FieldPos("BK2_PARCEL")) > 0
				cSQL += "BK2_PARCEL IN ('S','N') AND " // Indica que nao utiliza a rotina de parcelamento
			Endif
			cSQL += "BK2_LOTPAR <> 'S' AND " 	// Indica se ja foi faturado
			cSQL += "D_E_L_E_T_ = ' '"
			//cSQL := ChangeQuery(cSQL)

			oPrepBK2B:=FWPreparedStatement():New(cSQL)
			//dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSBK2",.F.,.T.)
		EndIF

		oPrepBK2B:SetString(1,cCodInt)
		oPrepBK2B:SetString(2,cCodEmp)
		oPrepBK2B:SetString(3,cMatric)
		oPrepBK2B:SetString(4,cAno)
		oPrepBK2B:SetString(5,cMes)

		cSQL := oPrepBK2B:GetFixQuery()
		PLSBUSBK2 := MpSysOpenQuery(cSQL)



		aEspBK2	 := {}

		(PLSBUSBK2)->(DBEval( { | | aadd(aEspBK2, {BK2_CODINT,;
													   BK2_CODEMP,;
													   BK2_MATRIC,;
													   BK2_TIPREG,;
													   BK2_TIPLAN,;//D-DEBITO,C-CREDITO
													   BK2_CODLAN,;
													   BK2_SALDO ,;
													   BK2_DIGITO,;
													   BK2_SALDO2,;
													   BK2_PROPRI}) }))//SE USUARIO OU SISTEMA
  		(PLSBUSBK2)->(DbCloseArea())

		For nFor := 1 to Len(aEspBK2)
			lParcelamento := .T.
			cMatUsr  := aEspBK2[nFor][1]+aEspBK2[nFor][2]+aEspBK2[nFor][3]+aEspBK2[nFor][4]+aEspBK2[nFor][8]
			If (nPos := aScan(aRet,{|x|  x[3] == aEspBK2[nFor][10]+aEspBK2[nFor][6] .And.;
								          x[7] == cMatUsr})) == 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria nova linha na matriz...										³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AaDd(aRet, Array(50))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posicionamento necessario											³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BFQ->(DbSetOrder(1))
				BFQ->(MsSeek(xFilial("BFQ")+PLSIntPad()+aEspBK2[nFor][10]+aEspBK2[nFor][6]))
				BA1->(DbSetOrder(2))
				BA1->(MsSeek(xFilial("BA1")+cMatUsr))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Preenche a nova linha 												³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := Len(aRet)
				aRet[nPos][01]	:= BFQ->BFQ_DEBCRE
				aRet[nPos][02]	:= 0
				aRet[nPos][03]	:= aEspBK2[nFor][10]+aEspBK2[nFor][6]
				aRet[nPos][04]	:= aEspBK2[nFor][10]+aEspBK2[nFor][6]
				aRet[nPos][05]	:= BFQ->BFQ_DESCRI //essa linha aqui nao esta 100%
		    	aRet[nPos][06]	:= ""
				aRet[nPos][07]	:= cMatUsr
				aRet[nPos][08]	:= BA1->BA1_NOMUSR
				aRet[nPos][09]	:= .F.
				aRet[nPos][10]	:= ""
				aRet[nPos][12]	:= ""
				aRet[nPos][13]	:= ""
				aRet[nPos][14]	:= ""
				aRet[nPos][15]	:= BA1->BA1_TIPUSU
				aRet[nPos][16]	:= ""
				aRet[nPos][17]	:= "BK2"
				aRet[nPos][18]	:= ""
				aRet[nPos][19]	:= StrZero(nPos,4)
				aRet[nPos][20]	:= 0
				aRet[nPos][21]	:= 0
				aRet[nPos][22]	:= BFQ->BFQ_VERBA
				aRet[nPos][23]	:= 0
				aRet[nPos][24]	:= aEspBK2[nFor][7]
				aRet[nPos][25]	:= aEspBK2[nFor][9]
				//aRet[nPos][26] saldo total (preenchido no próximo For)
				aRet[nPos][27]  := 0
				aRet[nPos][28]  := 0
				aRet[nPos][29]  := 0
				aRet[nPos][30]  := ""
				aRet[nPos][31]  := ""
				aRet[nPos][32]  := 0
				aRet[nPos][33]  := 0
				aRet[nPos][34]  := ""
				aRet[nPos][35]  := ""
				aRet[nPos][36]  := ""
				aRet[nPos][37]  := IIF(BFQ->(FieldPos("BFQ_CODSB1"))> 0,BFQ->BFQ_CODSB1,"")
				aRet[nPos][38]  := IIF(BFQ->(FieldPos("BFQ_CODTES"))> 0,BFQ->BFQ_CODTES,"")
				aRet[nPos][39]  := 0
				aRet[nPos][40]  := 0
				aRet[nPos][41]  := Nil
				aRet[nPos][42]  := Nil
				aRet[nPos][43]  := Nil
				aRet[nPos][44]  := .T.
			Else
				aRet[nPos][24]	+= aEspBK2[nFor][7]
				aRet[nPos][25]	+= aEspBK2[nFor][9]
				// Irei usar a posicao 44 para nao cobrar este acumulado pois ele ja foi parcelado
				If 		Len(aRet[nPos]) == 43
					AaDd(aRet[nPos],.T.)
				ElseIf	Len(aRet[nPos]) < 43
					lAjusta := .T.
					While lAjusta
					 	AaDd(aRet[nPos],Nil)
					 	If 	Len(aRet[nPos]) == 44
					 	 	aRet[nPos][44] := .T.
					 	 	lAjusta := .F.
					 	EndIf
					EndDo
				EndIf
			EndIf
		Next

		For j := 1 to Len(aRet)
			If aRet[j][24] != 0 .Or. aRet[j][25] != 0
		    	aadd(aRetAcu,aRet[j])
		    EndIf
		Next j

		If 	aFoCoPF[2] == "3" .And. lOk /*.And. PLSALIASEX("BKJ") .And. PLSALIASEX("BK2") .And. SIX->(MsSeek("BKJ2")) .And. SIX->(MsSeek("BK22"))*/ .And. !lParcelamento

			If oPrepBK2C == nil

				cSQL := "SELECT BK2_CODINT,BK2_CODEMP,BK2_MATRIC,BK2_TIPREG,BK2_PROPRI,"
				cSQL += "BK2_DIGITO,BK2_TIPLAN,BK2_CODLAN,BK2_SALDO,BK2_SALDO2 "
				cSQL += Iif(BK2->(FieldPos("BK2_PARCEL")) > 0, ",BK2_PARCEL", "")
				cSQL += " FROM "+RetSqlName("BK2")+" WHERE "
				cSQL += "BK2_FILIAL = '"+xFilial("BK2")+"' AND "
				cSQL += "BK2_CODINT = ? AND "
				cSQL += "BK2_CODEMP = ? AND "
				cSQL += "BK2_MATRIC = ? AND "
				cSQL += "BK2_ANO 	= ? AND "
				cSQL += "BK2_MES	= ? AND "
				cSQL += "(BK2_SALDO	> 0 OR BK2_SALDO2	> 0) AND "
				If BK2->(FieldPos("BK2_PARCEL")) > 0
					cSQL += "BK2_PARCEL = '' AND " // Indica que nao utiliza a rotina de parcelamento
				Endif
				cSQL += "D_E_L_E_T_ = ' '"
				oPrepBK2C:=FWPreparedStatement():New(cSQL)

			EndIf

			oPrepBK2C:SetString(1,cCodInt)
			oPrepBK2C:SetString(2,cCodEmp)
			oPrepBK2C:SetString(3,cMatric)
			oPrepBK2C:SetString(4,cAnoAnt)
			oPrepBK2C:SetString(5,cMesAnt)

			cSQL := oPrepBK2C:GetFixQuery()
			PLSBUSBK2 := MpSysOpenQuery(cSQL)


			(PLSBUSBK2)->(DBEval( { | | aadd(aEspBK2, {BK2_CODINT,;
														   BK2_CODEMP,;
														   BK2_MATRIC,;
														   BK2_TIPREG,;
														   BK2_TIPLAN,;//D-DEBITO,C-CREDITO
														   BK2_CODLAN,;
														   BK2_SALDO ,;
														   BK2_DIGITO,;
														   BK2_SALDO2,;
														   BK2_PROPRI}) }))//SE USUARIO OU SISTEMA
	  		(PLSBUSBK2)->(DbCloseArea())

			For nFor := 1 to Len(aEspBK2)
				cMatUsr  := aEspBK2[nFor][1]+aEspBK2[nFor][2]+aEspBK2[nFor][3]+aEspBK2[nFor][4]+aEspBK2[nFor][8]
				If (nPos := aScan(aRet,{|x|  x[3] == aEspBK2[nFor][10]+aEspBK2[nFor][6] .And.;
										          x[7] == cMatUsr})) == 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cria nova linha na matriz...										³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AaDd(aRet, Array(50))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posicionamento necessario											³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BFQ->(DbSetOrder(1))
					BFQ->(MsSeek(xFilial("BFQ")+PLSIntPad()+aEspBK2[nFor][10]+aEspBK2[nFor][6]))
					BA1->(DbSetOrder(2))
					BA1->(MsSeek(xFilial("BA1")+cMatUsr))
					BA3->(DbSetOrder(1))
					BA3->(MsSeek(xFilial("BA1")+Substr(cMatUsr,1,14)))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preenche a nova linha 												³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPos := Len(aRet)
					aRet[nPos][01]	:= BFQ->BFQ_DEBCRE
					aRet[nPos][02]	:= 0
					aRet[nPos][03]	:= aEspBK2[nFor][10]+aEspBK2[nFor][6]
					aRet[nPos][04]	:= aEspBK2[nFor][10]+aEspBK2[nFor][6]
					aRet[nPos][05]	:= BFQ->BFQ_DESCRI //essa linha aqui nao esta 100%
			    	aRet[nPos][06]	:= ""
					aRet[nPos][07]	:= cMatUsr
					aRet[nPos][08]	:= BA1->BA1_NOMUSR
					aRet[nPos][09]	:= .F.
					aRet[nPos][10]	:= ""
					aRet[nPos][12]	:= ""
					aRet[nPos][13]	:= ""
					aRet[nPos][14]	:= ""
					aRet[nPos][15]	:= BA1->BA1_TIPUSU
					aRet[nPos][16]	:= ""
					aRet[nPos][17]	:= "BK2"
					aRet[nPos][18]	:= ""
					aRet[nPos][19]	:= StrZero(nPos,4)
					aRet[nPos][20]	:= 0
					aRet[nPos][21]	:= 0
					aRet[nPos][22]	:= BFQ->BFQ_VERBA
					aRet[nPos][23]	:= 0
					aRet[nPos][24]	:= aEspBK2[nFor][7]
					aRet[nPos][25]	:= aEspBK2[nFor][9]
					//aRet[nPos][26] saldo total (preenchido no próximo For)
					aRet[nPos][27]  := 0
					aRet[nPos][28]  := 0
					aRet[nPos][29]  := 0
					aRet[nPos][30]  := ""
					aRet[nPos][31]  := ""
					aRet[nPos][32]  := 0
					aRet[nPos][33]  := 0
					aRet[nPos][34]  := ""
					aRet[nPos][35]  := ""
					aRet[nPos][36]  := ""
					aRet[nPos][37]  := BFQ->BFQ_CODSB1
					aRet[nPos][38]  := BFQ->BFQ_CODTES
					aRet[nPos][39]  := 0
					aRet[nPos][40]  := 0
					aRet[nPos][41]  := ""
					aRet[nPos][42]  := ""
					aRet[nPos][43]  := .F.
					aRet[nPos][44]  := .F.

					BI3->(Dbseek(xfilial("BI3")+PLSINTPAD()+BA3->BA3_CODPLA+BA3->BA3_VERSAO))
					aDadGPE:=MontaVer(cMatUsr,BA3->BA3_CODPLA,BA3->BA3_VERSAO,BA3->BA3_CODINT,,BI3->BI3_TPFORN)

					If !lDirf11 .OR. BFQ->BFQ_TPLAN <>'1'
						aRet[nPos][22]	:= BFQ->BFQ_VERBA
					else
						aRet[nPos][22]:= aDadGPE[1]
					Endif

					aRet[nPos][45] := aDadGPE[2]
					aRet[nPos][46]  := If(BI3->(Fieldpos("BI3_TPFORN"))>0,BI3->BI3_TPFORN,'')
					aRet[nPos][47]:= aDadGPE[3]
					aRet[nPos][48]:= aDadGPE[4]
					aRet[nPos][49]:= aDadGPE[5]
					If lPLSINTFOL
						aDadGpe:=Execblock("PLSINTFOL",.F.,.F.,{aEspBK2[nFor][10]+aEspBK2[nFor][6],cMatUsr,BA3->BA3_CODPLA,BA3->BA3_VERSAO,BA3->BA3_CODINT,aRet[nPos][45],aRet[nPos][47],aRet[nPos][46],aRet[nPos][48],aRet[nPos][49],aRet[nPos][22]})
						If Len(aDadGpe)>0
							aRet[nPos][22]  := aDadgpe[1]
							aRet[nPos][45]  := aDadGPE[2]
							aRet[nPos][47]  := aDadGPE[3]
							aRet[nPos][46]  := aDadGPE[6]
							aRet[nPos][48]  := aDadGPE[4]
							aRet[nPos][49]  := aDadGPE[5]

						Endif
					Endif
				Else
					aRet[nPos][24]	+= aEspBK2[nFor][7]
					aRet[nPos][25]	+= aEspBK2[nFor][9]
				EndIf
			Next

	  		For i := 1 to Len(aRet)

	   			aRet[i][26]  := aRet[i][2] + aRet[i][24] + aRet[i][25]
	   			If !lallDeb .or. (Len(aRetLct) > 0 .and. ascan(aRetLct, {|x| x == aRet[i][3]}) > 0)
					j := ascan(aTotLan, {|x| x[1] == aRet[i][3]})
				Else
					j := ascan(aTotLan, {|x| x[1] == aRet[i][1]})
		   		Endif
	   		    If j == 0
		   		     	AaDd(aTotLan,{IIF(!lallDeb .or. (Len(aRetLct) > 0 .and. ascan(aRetLct, {|x| x == aRet[i][3]}) > 0),aRet[i][3],aRet[i][1]),;
		   		     				  aRet[i][2],;
		   		     				  aRet[i][24],;
		   		     				  aRet[i][25],;
		   		     				  aRet[i][26],;
		   		     				  aRet[i][1],;
		   		     				  .T.})
	   		    Else
	   		    	aTotLan[j][2] += aRet[i][2]
	   		    	aTotLan[j][3] += aRet[i][24]
	   		    	aTotLan[j][4] += aRet[i][25]
	   		    	aTotLan[j][5] += aRet[i][26]
	   		    EndIf
		   Next

	   	   For i := 1 to Len(aTotLan)
				nTotal:=0
				For j := 1 to Len(aRet)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Operadora + Plano + Versao + TipLan									³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lAllDeb.or. (Len(aRetLct) > 0 .and. ascan(aRetLct, {|x| x == aRet[j][3]}) > 0)
						cChave := cCodInt+cCodPla+cVerPla+aRet[j][3]
					Else
						cChave := cCodInt+cCodPla+cVerPla
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faixa de desconto do produto da familia								³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BKJ->(DbSetOrder(2))//BKJ_FILIAL + BKJ_CODIGO + BKJ_VERSAO + BKJ_TIPLAN + BKJ_FAIDES
					If BKJ->(MsSeek(xFilial("BKJ")+cChave))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Esvaziei com valor do a ser descontado de fato						³
						//| importante o aRet[nItem][2] eh o que eu estou cobrando				|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cRdmake   := BKJ->BKJ_FORCAL
						If !Empty(cRdmake)
							If 	AllTrim(cRdmake) == "PLSVLRACU"
								aRetAux := PLSVLRACU(dData,cAno,cMes,BKJ->BKJ_FAIDES,aTotLan,i)
		      				Else
								aRetAux := ExecBlock(cRdmake,.F.,.F.,{dData,cAno,cMes,BKJ->BKJ_FAIDES,aTotLan,i})
							EndIf
						Endif
						If Len(aRetAux) > 0
							nPercent := aRet[j][26]/aTotLan[i][5]
							If !lAllDeb.or. (Len(aRetLct) > 0 .and. ascan(aRetLct, {|x| x == aRet[j][3]}) > 0)
								cRet:=	aRet[j][3]
							Else
								cRet:=	aRet[j][1]
							Endif

							If cRet == aTotLan[i][1]
								aRet[j][2]  :=nPercent * aRetAux[1][1]
								aRet[j][24] :=nPercent * aRetAux[1][2]
								aRet[j][25] :=nPercent * aRetAux[1][3]

								aRet[j][26] := aRet[j][2] + aRet[j][24] + aRet[j][25]

								If aRet[j][24] != 0 .Or. aRet[j][25] != 0
									aadd(aRetAcu,aRet[j])
								EndIf
								nTotal+=  Round(nPercent * aRetAux[1][1],2)

							EndIf

						EndIf
					Endif
				Next
		    Next
		EndIf
EndIf

Return({aRet,aRetAcu})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  PLSFAIDE  ³ Autor ³ Daher		        ³ Data ³ 11.09.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pega a taxa de desconto baseado no codigo da faixa         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSFAIDE(cCodFai,nSalario,dDatPro)
LOCAL nTaxa   := 0
LOCAL nFaiIni := 0
LOCAL nFaiFin := 0
DEFAULT dDatPro := dDataBase

BK4->(DbSetOrder(1))
If BK4->(DbSeek(xFilial("BK4")+cCodFai))
   While ! BK4->(Eof()) .And. BK4->(BK4_FILIAL+BK4_CODIGO) == xFilial("BK4")+cCodFai
            If ( dtos(dDatPro) >= dtos(BK4->BK4_DATDE) ) .And. ;
               ( dtos(dDatPro) <= dtos(BK4->BK4_DATATE) .Or. Empty(BK4->BK4_DATATE) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Salarios Minimos													³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		         If BK4->BK4_UNIDAD == "1"
		            nFaiIni := GetNewPar("MV_PLSALMI",300)*BK4->BK4_FAIINI
		            nFaiFin := GetNewPar("MV_PLSALMI",300)*BK4->BK4_FAIFIN
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valor																³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		         Else
		            nFaiIni := BK4->BK4_FAIINI
		            nFaiFin := BK4->BK4_FAIFIN
		         EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega a Taxa															³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nSalario >= nFaiIni .And. nSalario <= nFaiFin
				      nTaxa := BK4->BK4_PERDES
				      exit
				EndIf
            EndIf
   			BK4->(DbSkip())
   Enddo
EndIf

Return(nTaxa)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  PLSVLREMB ³ Autor ³ Daher               ³ Data ³ 16.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pega o vlr do reembolso de livre escolha			          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLREMB(aUsuarios,cAno,cMes,cReemb,lDatPagto,dDatPagto)
Local nValor   		:= 0
Local aRet     		:= {}
Local nFor     		:= 0
Default lDatPagto 	:= .F.
Default cReemb      :="2"
Default dDatPagto   := cTod("")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ rotina nova de reembolso
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nFor:= 1 to Len(aUsuarios)

	dbSelectArea("B44")
	dbSetOrder(2)
	If	dbSeek(xFilial('B44')+subs(aUsuarios[nFor][13],1,4)+subs(aUsuarios[nFor][13],5,4)+subs(aUsuarios[nFor][13],9,6)+ ;
		subs(aUsuarios[nFor][13],15,2))

		cSQL := "SELECT B44_FORPAG,B44_PREFIX, B44_NUM, B44_PARCEL, B44_TIPO,B44_VLRPAG, " + ;
		"B44_OPERDA, B44_CODRDA, B44_OPEUSR, B44_CODLDP, B44_CODPEG,B44_NUMGUI " + ;
		"FROM " + retSQLName('B44') + " B44 " + ;
		"INNER JOIN " + retSQLName('BOW') + " BOW " + ;
		"ON B44.B44_PROTOC = BOW.BOW_PROTOC " + ;
		"WHERE B44.B44_FILIAL = '" + xFilial('B44') + "' " + ;
		"AND B44.B44_OPEUSR = '" + subs(aUsuarios[nFor][13],1,4) + "' " + ;
		"AND B44.B44_CODEMP = '" + subs(aUsuarios[nFor][13],5,4) + "' " + ;
		"AND B44.B44_MATRIC = '" + subs(aUsuarios[nFor][13],9,6) + "' " + ;
		"AND B44.B44_TIPREG = '" + subs(aUsuarios[nFor][13],15,2) + "' " + ;
		"AND B44.B44_ANOPAG <= '" + cAno + "' " + ;
		"AND B44.B44_MESPAG <= '" + cMes +"' " + ;
		"AND B44.B44_NUM = ' ' " + ;
		"AND B44.D_E_L_E_T_ = ' ' " + ;
		"AND BOW.BOW_STATUS = '6' " + ;
		"AND BOW.D_E_L_E_T_ = ''"

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"B44QRY",.F.,.T.)

		While !B44QRY->(Eof())
				// Ainda nao foi faturado
			If B44QRY->B44_FORPAG == '0' .and. Empty(B44QRY->(B44_PREFIX+B44_NUM+B44_PARCEL+B44_TIPO))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ Verificar Reembolso CAMED
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				If lDatPagto .And. cReemb == "1" // Somente Reembolso
					BCI->(DbSetOrder(5))//BCI_FILIAL, BCI_OPERDA, BCI_CODRDA, BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI_FASE, BCI_SITUAC    BCI_DATPAG
					If BCI->(MsSeek(xFilial("BCI")+B44->(B44_OPERDA+B44_CODRDA+B44_OPEUSR+B44_CODLDP+B44_CODPEG))) .And. BCI->BCI_FASE <> "4" .And. BCI->BCI_DATPAG == dDatPagto

						BD5->(DbSetOrder(1))//BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA
						If BD5->(MsSeek(xFilial("BD5")+BCI->(BCI_OPERDA+BCI_CODLDP+BCI_CODPEG) +B44->B44_NUMGUI+ BCI->(BCI_SITUAC+BCI_FASE)))
							nValor += BD5->BD5_VLRPAG
						Endif
					Endif
				Else
					nValor += B44QRY->B44_VLRPAG
				Endif
			Endif
			B44QRY->(DbSkip())
		EndDo

		B44QRY->(DbCloseArea())
	endIf

	If nValor > 0
		aadd(aRet,{nValor,;
	    	      aUsuarios[nFor][13],;
	  	 	      aUsuarios[nFor][03],;
	  	 	      aUsuarios[nFor][08],;
	  	 	      aUsuarios[nFor][09],;
	  	 	      aUsuarios[nFor][29],;
	  	 	      aUsuarios[nFor][07],;
	  	 	      aUsuarios[nFor][31]})
	EndIf
	nValor := 0
Next


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ rotina velha de reembolso
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nFor:= 1 to len(aUsuarios)

	cChave := xFilial("BKD")+subs(aUsuarios[nFor][13],1,16)+cAno+cMes
	BKD->(DbSetOrder(4))

	If BKD->(MsSeek(cChave))

		While !BKD->(Eof()) .and. BKD->(BKD_FILIAL+BKD_CODINT+BKD_CODEMP+BKD_MATRIC+BKD_TIPREG+BKD_ANOBAS+BKD_MESBAS) == cChave

			If BKD->BKD_FORPAG == '0' .and. Empty(BKD->BKD_CHVSE1)
				nValor += BKD->BKD_VLRREM
			EndIf

			BKD->(DbSkip())
		Enddo
	EndIf

	If nValor > 0
		AaDd(aRet,{nValor,;					//01
	    	      aUsuarios[nFor][13],;    //02
	  	 	      aUsuarios[nFor][03],;		//03
	  	 	      aUsuarios[nFor][08],;		//04
	  	 	      aUsuarios[nFor][09],;		//05
	  	 	      aUsuarios[nFor][29],; 	//06
	  	 	      aUsuarios[nFor][07],; 	//07
	  	 	      aUsuarios[nFor][31]}) //08
	EndIf
	nValor := 0
Next

return aRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  PLSRETFCPF³ Autor ³ Daher               ³ Data ³ 16.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Indica como deve ser a cobranca da PF			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³essa funcao de fato, define como o BDH deve ser lido, ou seja 		  ³±±
±±³qual ano e mes ele deve considerar			          				  ³±±
±±³[1] - indica como deve ser a cobranca da participacao financeira		  ³±±
±±³[2] - indica como deve ser o faturamento (2-financeiro,3-folha pgto)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRETFCPF(cCodInt,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cCodPla,cVerPla,cTipoUs)
LOCAL aRet 		 := {"0","2"}
LOCAL aReturn	 := {"0","2"}
LOCAL aAreaBI3		:= BI3->(GetArea())
LOCAL aAreaBT6		:= BT6->(GetArea())

If cTipoUS == "1"
	If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+cVerPla))
		If BI3->BI3_COBCPF == "1"
			aRet[1] := "1"
		EndIf
		If BI3->BI3_FORFAT == "3"
			aRet[2] := BI3->BI3_FORFAT
		EndIf
	EndIf
Else
	If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+cVerPla))
		If BT6->(MsSeek(xFilial("BT6")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub+cCodPla+cVerPla))
			If BT6->BT6_COBCPF == "1"
	            aRet[1] := "1"
			EndIf
		EndIf
		If BI3->BI3_FORFAT == "3" // pelo menos por enquanto nao precisa ter ele no subcont
			aRet[2] := BI3->BI3_FORFAT
		EndIf
	EndIf
EndIf

If  lPlRetFcPf 
   	aReturn := ExecBlock("PLRETFCPF",.F.,.F.,{cCodInt,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cCodPla,cVerPla,cTipoUs,aRet})
   	aRet[1] := aReturn[1]
   	aRet[2] := aReturn[2]
EndIf


RestArea(aAreaBI3)
RestArea(aAreaBT6) 


Return aRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  PLSRETLANU³ Autor ³ Daher               ³ Data ³ 16.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os lancamento de faturamento de usuario            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRETLANU(cCodOpe,bRegras)
LOCAL aRet := {{'','','','','','','','','','','','','','','','','','','','','',''}}
DEFAULT bRegras :={ || .T.}
DbSelectArea("BFQ")
BFQ->(DbSetOrder(3))
If BFQ->(MsSeek(xFilial("BFQ")))
	BFQ->(DBEval( {|| aadd(aRet, 	{	BFQ_PROPRI+BFQ_CODLAN,;										// 01
										BFQ_DESCRI,;												// 02
										BFQ_DEBCRE,;                                               	// 03
										BFQ_INCIR ,;												// 04
										BFQ_TIPFAT,; 												// 05
										BFQ_REGCIR,;	  											// 06
										BFQ_INCISS,;  												// 07
										BFQ_REGCIS,;												// 08
										BFQ_INCCON,;												// 09
										BFQ_REGCCO,;												// 10
										BFQ_INCPIS,;  												// 11
										BFQ_REGCPI,;												// 12
										BFQ_INCCSL,;												// 13
										BFQ_REGCCS,;												// 14
										BFQ_INCINS,;		  										// 15
										Iif(FieldPos("BFQ_REGCIN") > 0, BFQ_REGCIN, ''),;			// 16
										Iif(FieldPos("BFQ_REGCI1") > 0, BFQ_REGCI1, ''),;			// 17
										BFQ_VERBA ,; 												// 18
										BFQ_ATOCOO,;												// 19
										BFQ_ATIVO ,;
										Iif(FieldPos("BFQ_FORUSU") > 0, AllTrim(BFQ_FORUSU), ''),;
										Iif(FieldPos("BFQ_LANACE") > 0, BFQ_LANACE, '')})}, {||BFQ->BFQ_CODINT == cCodOpe .and. BFQ->BFQ_PROPRI == '9' .and. Eval(bRegras) .And. AvaliaLanc() } ))

EndIf
Return aRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  PLSRETLADC³ Autor ³ Daher               ³ Data ³ 16.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os tipo de lanc de debito credito				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRETLADC()
// Lancamentos de debito / credito padroes do sistema.
LOCAL cSistema  := "111,113,128,129,130,131,132,135,136,180,181,188,190,"

// Lacamentos de debito / credito especificos do usuario.
LOCAL cUsuario := GetNewPar("MV_PLCODDC","")

Return(cSistema + cUsuario)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLLastFat  ³ Autor ³ Geraldo Felix Junior³ Data ³ 08.01.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a ultima competencia faturada para o nivel de      ³±±±
±±³          ³ cobranca informado.                                        ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Parametros³ cNivel = Nivel de cobranca / cChave = Chave do nivel cob.  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Nivel 6 - Operadora(Intercambio)
Nivel 5 - Usuario
Nivel 4 - Familia
Nivel 3 - SubCon
Nivel 2 - Contr
Nivel 1 - Empresa
/*/

Function PLLastFat(cNivel,cChave)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva area de trabalho...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aArea := GetArea()
LOCAL cAno := ''
LOCAL cMes := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca o ultimo faturamento...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("BBT")
DbSetOrder(Val(cNivel))
BBT->( MsSeek(xFilial("BBT")+cNivel+cChave+Replicate("9",6),.T.) )
BBT->( DbSkip(-1) )

cAno := BBT->BBT_ANOTIT
cMes := BBT->BBT_MESTIT
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area de trabalho...											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return({cAno, cMes})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  MontaSB1  ³ Autor ³ Tulio               ³ Data ³ 16.05.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o SB1 vinculado ao PLS para integracao NFS           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MontaSB1(aEventosCB,nFor,cCodEve,cCodPro,cOpeFam,cMatUsu,_cNivel)
LOCAL cCodSB1 	:= ""
LOCAL nPos      := 0
LOCAL aAreaBI3	:= BI3->(GetArea())
DEFAULT cCodEve := ""
DEFAULT cCodPro := ""

If lPlsTrlf 
   cCodEve := ExecBlock("PLSTRLF",.F.,.F.,{cCodEve,cCodPro,cOpeFam})
EndIf

nPos := nFor

If ! Empty(cCodEve)
	nPos := Ascan(aEventosCB,{|x| x[1] == cCodEve})
EndIf

if nPos > 0 .And. Len(aEventosCB[nPos]) >= 22 .And. ! Empty(aEventosCB[nPos,22])

	cCodSB1 := aEventosCB[nPos,22]

elseIf BI3->(FieldPos("BI3_CODSB1")) > 0 
		
	If empty(cCodPro) .and. ! Empty(BI3->BI3_CODSB1)
		cCodSB1 := BI3->BI3_CODSB1
	else

		BI3->( DbSetOrder(1) )
		BI3->( DbSeek(xFilial("BI3") + cOpeFam + cCodPro) )

		cCodSB1 := BI3->BI3_CODSB1

	endIf

endIf

//Busca no nivel de cobrança
if empty(cCodSB1)

	If _cNivel == "1"

		If BG9->(DbSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP))).and. ( BG9->(FieldPos("BG9_CODSB1"))>0 .and. !Empty(BG9->BG9_CODSB1))
			cCodSB1 := BG9->BG9_CODSB1
		Endif

	Elseif _cNivel == "2"

		If BT5->(DbSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON))).and. ( BT5->(FieldPos("BT5_CODSB1"))>0 .and. !Empty(BT5->BT5_CODSB1))
			cCodSB1 := BT5->BT5_CODSB1
		Endif

	Elseif _cNivel == "3"

		If	BQC->(DbSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB))).and. ( BQC->(FieldPos("BQC_CODSB1"))>0 .and. !Empty(BQC->BQC_CODSB1))
			cCodSB1 := BQC->BQC_CODSB1
		Endif

	Elseif _cNivel =="4" .and. ( BA3->(FieldPos("BA3_CODSB1"))>0 .and. !Empty(BA3->BA3_CODSB1))
		
		cCodSB1 := BA3->BA3_CODSB1

	Elseif _cNivel =="5".and.  ( BA1->(FieldPos("BA1_CODSB1"))>0 .and. !Empty(BA1->BA1_CODSB1))
		
		cCodSB1 := BA1->BA1_CODSB1

	Endif

endIf

RestArea(aAreaBI3)

Return(cCodSB1)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  MontaTES  ³ Autor ³ Tulio               ³ Data ³ 16.05.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o TES vinculado ao PLS para integracao NFS           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MontaTES(aEventosCB,nFor,cCodSB1,cCodProPLS,cCodEve,cOpeFam,cMatUsu,_cNivel)
LOCAL cCodTES 		:= ""
LOCAL nPos          := 0
LOCAL aAreaBI3		:= BI3->(GetArea())
DEFAULT cCodSB1    	:= ""
DEFAULT cCodProPLS 	:= ""
DEFAULT cCodEve    	:= ""
DEFAULT cOpeFam    	:= ""

If lPlsTrlf 
   cCodEve := ExecBlock("PLSTRLF",.F.,.F.,{cCodEve,cCodProPLS,cOpeFam})
EndIf

nPos := nFor

If ! empty(cCodEve)
	nPos := Ascan(aEventosCB,{|x| x[1] == cCodEve})
EndIf

If nPos > 0 .And. Len(aEventosCB[nPos]) >= 23 .And. ! Empty(aEventosCB[nPos,23])

	cCodTES := aEventosCB[nPos,23]

ElseIf BI3->(FieldPos("BI3_CODTES")) > 0

	BI3->(DbSetOrder(1)) //BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
	If BI3->(DbSeek(xFilial("BI3") + cOpeFam + cCodProPLS)) .and. ! Empty(BI3->BI3_CODTES)
		cCodTES := BI3->BI3_CODTES
	EndIf

EndIf

//Se nao tiver pega o do produto do ERP (SB1)								 
If empty(cCodTes)
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cCodSB1))
	cCodTes := SB1->B1_TS
EndIf

if empty(cCodTES)

	//Busca no nivel de cobrança
	If _cNivel == "1"
		
		If BG9->(DbSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP))).and. ( BG9->(FieldPos("BG9_CODTES"))>0 .and. !Empty(BG9->BG9_CODTES))
			cCodTES := BG9->BG9_CODTES
		Endif

	Elseif _cNivel == "2"
		
		If BT5->(DbSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON))).and. ( BT5->(FieldPos("BT5_CODTES"))>0 .and. !Empty(BT5->BT5_CODTES))
			cCodTES := BT5->BT5_CODTES
		Endif

	Elseif _cNivel == "3"
		
		If	BQC->(DbSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB))).and. ( BQC->(FieldPos("BQC_CODTES"))>0 .and. !Empty(BQC->BQC_CODTES))
			cCodTES:= BQC->BQC_CODTES
		Endif

	Elseif _cNivel =="4" .and. ( BA3->(FieldPos("BA3_CODTES"))>0 .and. !Empty(BA3->BA3_CODTES))
		
		cCodTes:= BA3->BA3_CODTES

	Elseif _cNivel =="5".and.  ( BA1->(FieldPos("BA1_CODTES"))>0 .and. !Empty(BA1->BA1_CODTES))

		cCodTes:= BA1->BA1_CODTES

	Endif

endIf

RestArea(aAreaBI3)

Return(cCodTES)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRGRA  ³ Autor ³ SIGAPLS           ³ Data ³ 11.06.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Verificação de Gratuidade do Usuário                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRGRA(cMatricFam,aUsuarios,cAno,cMes,aVlParcial)
LOCAL aRetFun 	:= {}
LOCAL nFor		:= 0
LOCAL nPosVal	:= 0
LOCAL nPosUsu	:= 0
LOCAL nValRet	:= 0
LOCAL cOpeFam   := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp   := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
LOCAL cMatric   := Subs(cMatricFam,atMatric[1],atMatric[2])
LOCAL cTipReg	:= ""
LOCAL cDigito	:= ""
LOCAL lOk		:= .F.

If (Len(aUsuarios) == 0 .or. Len(aUsuarios[1]) == 0 .or. Len(aUsuarios[1]) < 26)
	Return(aRetFun)
EndIf

For nFor := 1 To Len(aUsuarios)

	cTipReg    := aUsuarios[nFor,1]
	cDigito    := aUsuarios[nFor,12]
	lOk		   := .F.
	//Nível de Usuário
	If BH6->(MsSeek(xFilial("BH6")+cOpeFam+cCodEmp+cMatric+cTipReg))

		While !BH6->(EoF()) .and. BH6->(BH6_FILIAL + BH6_CODINT + BH6_CODEMP + BH6_MATRIC + BH6_TIPREG)	== xFilial("BH6")+cOpeFam+cCodEmp+cMatric+cTipReg

			If cAno+cMes >= BH6->(BH6_ANOINI+BH6_MESINI) .AND. cAno+cMes <= BH6->(BH6_ANOFIM+BH6_MESFIM)

		    	aEval(aVlParcial, { |x| If(x[3] $ "101,102" .and. x[7] == cOpeFam+cCodEmp+cMatric+cTipReg+cDigito, nValRet += x[2], nil ) })

			    If nValRet > 0 .AND. !lOk
			    	AaDd(aRetFun,{aUsuarios[nFor,13],;
								  aUsuarios[nFor,3],;
								  nValRet,;
								  BH6->BH6_CODGRA,;
								  FDesc("SX5","BB"+BH6->BH6_CODGRA,"X5_DESCRI"),;
								  aUsuarios[nFor,08],;
								  aUsuarios[nFor,09],;
								  aUsuarios[nFor,29],;
								  "BH6",;
								  aUsuarios[nFor,07],;
								  aUsuarios[nFor,31]})//tp do plano
					nValRet := 0
					lOk := .T.
			    EndIf

			EndIf
			BH6->(DbSkip())
		EndDo
	EndIf
	//Nível de Família
	If !lOk .AND. BH5->(MsSeek(xFilial("BH5")+cOpeFam+cCodEmp+cMatric))

		While !BH5->(EoF()) .and. BH5->(BH5_FILIAL + BH5_CODINT + BH5_CODEMP + BH5_MATRIC)	== xFilial("BH5")+cOpeFam+cCodEmp+cMatric

			If cAno+cMes >= BH5->(BH5_ANOINI+BH5_MESINI) .AND. cAno+cMes <= BH5->(BH5_ANOFIM+BH5_MESFIM)

		    	aEval(aVlParcial, { |x| If(x[3] $ "101,102" .and. x[7] == cOpeFam+cCodEmp+cMatric+cTipReg+cDigito, nValRet += x[2], nil ) })

			    If nValRet > 0
			    	AaDd(aRetFun,{aUsuarios[nFor,13],;	//01
								  aUsuarios[nFor,3],;	//02
								  nValRet,;				//03
								  BH5->BH5_CODGRA,;		//04
								  FDesc("SX5","BB"+BH5->BH5_CODGRA,"X5_DESCRI"),;//05
								  aUsuarios[nFor,08],;	//06
								  aUsuarios[nFor,09],;	//07
								  aUsuarios[nFor,29],;	//08
								  "BH5",;				//09
								  aUsuarios[nFor,07],;   //10
								  aUsuarios[nFor,31]}) //11
					nValRet := 0
			    EndIf

			EndIf
			BH5->(DbSkip())
		EndDo
	EndIf
Next

Return(aRetFun)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVLCORE	  ³ Autor ³ Totvs               ³ Data ³ 14.04.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pega o vlr da Co Participacao reembolso			          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLCORE(aUsuarios,cAno,cMes)
Local nValor   		:= 0
Local aRet     		:= {}
Local nFor     		:= 0
Local cSQL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ rotina nova de reembolso
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nFor:= 1 to Len(aUsuarios)
	cChave := xFilial("B44")+subs(aUsuarios[nFor][13],1,16)+cAno+cMes
	B44->( DbSetOrder(2) )//B44_FILIAL, B44_OPEUSR, B44_CODEMP, B44_MATRIC, B44_TIPREG, B44_ANOAUT, B44_MESAUT

	If B44->(MsSeek(cChave))

		If	PLSALIASEXI("BOW")
			If !EMPTY(B44->B44_PROTOC)
				cSQL := "SELECT * FROM " + retSQLName('B44') + " B44 " + ;
				"INNER JOIN " + retSQLName('BOW') + " BOW " + ;
				"ON B44.B44_PROTOC = BOW.BOW_PROTOC " + ;
				"WHERE B44.B44_FILIAL = '" + xFilial('B44') + "' " + ;
				"AND B44.B44_OPEUSR = '" + subs(aUsuarios[nFor][13],1,4) + "' " + ;
				"AND B44.B44_CODEMP = '" + subs(aUsuarios[nFor][13],5,4) + "' " + ;
				"AND B44.B44_MATRIC = '" + subs(aUsuarios[nFor][13],9,6) + "' " + ;
				"AND B44.B44_TIPREG = '" + subs(aUsuarios[nFor][13],15,2) + "' " + ;
				"AND B44.B44_ANOPAG <= '" + cAno + "' " + ;
				"AND B44.B44_MESPAG <= '" + cMes +"' " + ;
				"AND B44.D_E_L_E_T_ = ' ' " + ;
				"AND BOW.BOW_STATUS = '6'" + ;
				"AND BOW.D_E_L_E_T_ = ''"

				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"B44QRZ",.F.,.T.)

				If !B44QRZ->(EOF())

					While !B44->(Eof()) .and. B44->(B44_FILIAL+B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG+B44_ANOPAG+B44_MESPAG) == cChave

						// Ja foi faturado
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³ Verifica Co-Participacao no Rembolso calculado e nao cobrado
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						B45->(DbSetOrder(1)) //B45_FILIAL, B45_OPEMOV, B45_ANOAUT, B45_MESAUT, B45_NUMAUT, B45_SEQUEN
						If B45->(MsSeek(xFilial("B45")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)))
							While !B45->(EOF()) .And. B44->(B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT) == ;
									B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT)
					
								If B45->B45_ABATPF =="0" .And. !Empty(B45->B45_VLRTPF)
									nValor += B45->B45_VLRTPF
								Endif
								B45->(DbSkip())
							EndDo
			   			Endif

						B44->(DbSkip())
					 EndDo
				EndIf

				B44QRZ->(DbCloseArea())
			Else
			 	   While !B44->(Eof()) .and. B44->(B44_FILIAL+B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG+B44_ANOPAG+B44_MESPAG) == cChave

						// Ja foi faturado
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³ Verifica Co-Participacao no Rembolso calculado e nao cobrado
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						B45->(DbSetOrder(1)) //B45_FILIAL, B45_OPEMOV, B45_ANOAUT, B45_MESAUT, B45_NUMAUT, B45_SEQUEN
						If B45->(MsSeek(xFilial("B45")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)))
							While !B45->(EOF()) .And. B44->(B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT) == ;
								B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT)
								If B45->B45_ABATPF =="0" .And. !Empty(B45->B45_VLRTPF)
									nValor += B45->B45_VLRTPF
								Endif
				   				B45->(DbSkip())
				   			EndDo
			   			Endif

						B44->(DbSkip())
					EndDo
		    EndIf
	    Else
			 	   While !B44->(Eof()) .and. B44->(B44_FILIAL+B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG+B44_ANOPAG+B44_MESPAG) == cChave

						// Ja foi faturado
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³ Verifica Co-Participacao no Rembolso calculado e nao cobrado
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						B45->(DbSetOrder(1)) //B45_FILIAL, B45_OPEMOV, B45_ANOAUT, B45_MESAUT, B45_NUMAUT, B45_SEQUEN
						If B45->(MsSeek(xFilial("B45")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)))
							While !B45->(EOF()) .And. B44->(B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT) == ;
									B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT)
								If B45->B45_ABATPF =="0" .And. !Empty(B45->B45_VLRTPF)
									nValor += B45->B45_VLRTPF
								Endif
								B45->(DbSkip())
				   			EndDo
				   		Endif

						B44->(DbSkip())
					EndDo
		 EndIf
	EndIf

	If nValor > 0
		aadd(aRet,{nValor,;
	    	      aUsuarios[nFor][13],;
	  	 	      aUsuarios[nFor][03],;
	  	 	      aUsuarios[nFor][08],;
	  	 	      aUsuarios[nFor][09],;
	  	 	      aUsuarios[nFor][29],;
	  	 	      aUsuarios[nFor][31]})//07
	EndIf
	nValor := 0
Next

return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSTCFILD  ³ Autor ³ Alexander         ³ Data ³ 15.10.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ TcSetField do Campo										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSTCFILD(aStruct,cVar)
LOCAL nI := 1


Iif( SX3->( IndexOrd() ) <> 2 , SX3->( DbSetOrder(2) ) ,NIL )//X3_CAMPO

For nI := 1 To Len(aStruct)

    If SX3->( MsSeek(aStruct[nI,1]) ) .And. SX3->X3_TIPO <> "C"
       TCSETField(cVar,SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL)
    EndIf

Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSPERGRA ºAutor  ³ TOTVS S/A          º Data ³  07/12/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os periodos de gratuidade do usuario / familia para º±±
±±º          ³desconsiderar as participacoes referente aos periodos       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPLS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSPERGRA(cMatricFam,cTipReg)
Local aRetGra := {} // Periodo de gratuidade

BH5->(DbSetOrder(1)) // Gratuidade na familia

If BH5->(dbSeek(xFilial("BH5")+cMatricFam))

	While BH5->(BH5_CODINT+BH5_CODEMP+BH5_MATRIC) == cMatricFam

		aAdd(aRetGra,{cMatricFam,;
			BH5->BH5_ANOINI+BH5->BH5_MESINI,;
			BH5->BH5_ANOFIM+BH5->BH5_MESFIM})

		BH5->(dbSkip())

	EndDo

EndIf

BH6->(DbSetOrder(1)) // Gratuidade no usuario

If BH6->(dbSeek(xFilial("BH6")+cMatricFam+cTipReg))

	While BH6->(BH6_CODINT+BH6_CODEMP+BH6_MATRIC+BH6_TIPREG) == cMatricFam+cTipReg

		aAdd(aRetGra,{cMatricFam+cTipReg,;
			BH6->BH6_ANOINI+BH6->BH6_MESINI,;
			BH6->BH6_ANOFIM+BH6->BH6_MESFIM})

		BH6->(dbSkip())

	EndDo

EndIf

Return aRetGra
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaVer  ºAutor  ³Microsiga           º Data ³  04/13/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca a verba do usuário dependente                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MontaVer(cMatUsu,cCodPla,cVerPla,cOpeFam,ddata,cTpForn)
//aDadGPE:=MontaVer(cMatUsu,TRBBM1->BA3_CODPLA,TRBBM1->BA3_VERSAO,TRBBM1->BA3_CODINT,TRBBM1->BM1_ANO+TRBBM1->BM1_MES+"01",BI3->BI3_TPFORN)
Local cVerba := ""
Local cSQL   := ""
Local cTipUsu := ""
//Local cRef := " "
Local cTpPlan:=  " "
Local cCodFor := " "
Local cCodDep := " "
local cCodPlano := " "
LOCAL aAreaBA1		:= BA1->(GetArea())
LOCAL aAreaBA3		:= BA3->(GetArea())
DEFAULT dData  := ddatabase
DEFAULT cTpForn := " "

BI3->(DbSeek(xFilial("BI3")+cOpeFam+cCodPla+cVerpla))

BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+cMatUsu))

cCodDep:=BA1->BA1_CODDEP
cTipUsu:= BA1->BA1_TIPUSU

BA3->(DbSeek(xFilial("BA3")+Substr(cMatUsu,1,14)))
cFilfunc := BA3->BA3_AGFTFU
cMatFunc := BA3->BA3_AGMTFU


iF oPrepRHK == nil
	cSQL:= "SELECT RHK_PD PD,RHK_PDDAGR PDDAGR, RHK_TPPLAN TPPLAN, RHK_CODFOR CODFOR, RHK_PLANO PLANO,RHK_PERINI PERINI, RHK_PERFIM PERFIM  FROM "+RetSqlName('RHK')
	cSQL+= " WHERE RHK_FILIAL= ?  AND "
	cSQL+= " RHK_MAT= ?  AND "
	cSQL+= " RHK_TPFORN= ?  AND "
	cSQL+=" D_E_L_E_T_<>'*' "
	oPrepRHK := FWPreparedStatement():New(cSQL)
Endif

nParamLin:=1
oPrepRHK:SetString(nParamLin,cFilFunc)
nParamLin++
oPrepRHK:SetString(nParamLin,cMatFunc)
nParamLin++
oPrepRHK:SetString(nParamLin,cTpForn)


cSQL := oPrepRHK:GetFixQuery()
PLSVERBA := MpSysOpenQuery(cSQL)


While (PLSVERBA)->(!EOF())

	dPerIni:=CTOD('01'+"/"+Substr((PLSVERBA)->PERINI,1,2)+"/"+Substr((PLSVERBA)->PERINI,3,4))
	cPerFim:=Substr((PLSVERBA)->PERFIM,3,4)+Substr((PLSVERBA)->PERFIM,1,2)
	If dData < dPerini .or. (Substr(Dtos(dData),1,6) >= cPerfim .And. !Empty(cPerfim))

		(PLSVERBA)->(Dbskip())
		Loop
	Endif


	cVerba:=Iif(cTipUsu=='T',(PLSVERBA)->PD,(PLSVERBA)->PDDAGR)
	cTpPlan:=  (PLSVERBA)->TPPLAN
	cCodFor := (PLSVERBA)->CODFOR
	cCodPlano := (PLSVERBA)->PLANO

	(PLSVERBA)->(Dbskip())

Enddo



(PLSVERBA)->(DbClosearea())

RestArea(aAreaBA1)
RestArea(aAreaBA3)
Return({cVerba,ctpplan,ccodfor,cCodDep,cCodPlano})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRRP  ³ Autor ³ Geraldo Felix Junior³Data ³ 1.02.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Calcula o valor da faixa salarial  todos os usuarios de uma³±±
±±³          ³ familia com seu respectivo valor de cobranca neste ano/mes ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRRP(cMatricFam,cAno,cMes,cForPag,aUsuarios,nSalrio,lOnlyLook,aComposicao,cTipo,aRegrasPatronal)

	Local cOpeFam := Subs(cMatricFam,atCodOpe[1],atCodOpe[2])
	Local cCodEmp := Subs(cMatricFam,atCodEmp[1],atCodEmp[2])
	Local cMatric := Subs(cMatricFam,atMatric[1],atMatric[2])
	Local cSQL := ""
	Local aFxSl	:= {}
	Local nIdade := 0
	Local cNivelUtil := "B1J"
	Local nSalario := 0
	Local nPos := 0
	Local nPosSl := 0
	Local dDatBasIda := CToD("01/"+cMes+"/"+cAno)
	Local nFor := 0
	Local cFaixa := ""
	Local nIdaIni := ""
	Local nIdaFin := ""
	Local nValor := 0
	Local aValores := {}
	Local aFaixas := {}
	Local cTipUsu := ""
	Local cTpForn := ""
	Local nPercDias := 0
	Local nValorRat := 0
	Local nDiasUtil := 0
	Local lConsDtCanc := GetNewPar("MV_PRODTCA",.F.)

	Default aUsuarios := {}
	Default lOnlyLook:= .F.
	Default aRegrasPatronal := {}

	DbSelectArea("B1L")

	// Analiso cada usuario...                                             
	If Len(aUsuarios) == 0
		aUsuarios := PLSLOADUSR(cOpeFam,cCodEmp,cMatric,cAno,cMes,,lOnlyLook)
	EndIf

	// Re-teste.
	If Len(aUsuarios) == 0
		Return(aValores)

	Elseif Len(aUsuarios[1]) < 30	// Posicao 30 guarda o codigo da tabela. Se nao existir, retorna.
		Return(aValores)

	Endif

	// Busca a faixa salarial desta familia...                             
	If oPrepBIJ == nil
		cSQL := "SELECT * "
		cSQL += "FROM "+RetSqlName("B1J")+" WHERE "
		cSQL += "B1J_FILIAL  = ?  AND "
		cSQL += "B1J_CODOPE  = ?  AND "
		cSQL += "B1J_CODIGO  = ?  AND " // A tabela patronal é unica para toda familia, por isso utilizo a do titular.
		cSQL += "D_E_L_E_T_ = ' '"

		oPrepBIJ:=FWPreparedStatement():New(cSQL)
	EndIF

	nParamLin:=1
	oPrepBIJ:SetString(nParamLin,xFilial("B1J"))
	nParamLin++
	oPrepBIJ:SetString(nParamLin,cOpeFam)
	nParamLin++
	oPrepBIJ:SetString(nParamLin,aUsuarios[1][30])

	cSQL := oPrepBIJ:GetFixQuery()
	PLSBUSFAI := MpSysOpenQuery(cSQL)

	(PLSBUSFAI)->(DBEval( { | | aadd(aFxSl, {B1J_CODFAI,B1J_VLSLIN,B1J_VLSLFN,B1J_CODIGO} ) }))
	(PLSBUSFAI)->(DbCloseArea())

	// Mes subsequente, com conteudo = 2.									
	If GetNewPar("MV_PLSBASI","1") == "2"
		dDatBasIda := dDatBasIda - 1
	EndIf

	If Len(aRegrasPatronal) == 0
		aRegrasPatronal := RegrasCobPatronal(cOpeFam, aUsuarios[1][30])
	EndIf

	For nFor := 1 To Len(aUsuarios)

		// Valida que tem direito ao valor patronal
		If Len(aRegrasPatronal) >= 6 .And. !ChckBenefPatronal(aRegrasPatronal, aUsuarios[nFor], CToD("01/"+cMes+"/"+cAno))
			Loop
		EndIf

		// Monta array com a mesma faixa de acordo com o usuario atual...      	
		If lPLSBSIDA
			dDatBasIda := ExecBlock("PLSBSIDA",.F.,.F.,{"4",dDatBasIda,aUsuarios[nFor],cMes,cAno,cMatricFam})
		EndIf

		nIdade := Calc_Idade(dDatBasIda,aUsuarios[nFor,2])
		nIdade	:= Iif(nIdade < 0,0,nIdade)
		nSalario := aUsuarios[nFor,27]
		cTipUsu := aUsuarios[nFor,7]
		cTpForn := aUsuarios[nFor,31]
		nPosSl := 0
		nPos := 0
	
		cNivelUtil := "B1I"

		// Chave 				                                                
		// TIPO DE USUARIO...                       							
		If nPosSl == 0
			nPosSl := Ascan(aFxSl, { |x| nSalario >= x[2] .And. nSalario <= x[3]})
		EndIf

		// Achou a faixa. Agora verifica se existe faixa de quantidade para a faixa salarial.
		If nPosSl > 0

			cSQL := "SELECT * "
			cSQL += "FROM "+RetSqlName("B1L")+" WHERE "
			cSQL += "B1L_FILIAL  = '"+xFilial("B1L")+"' AND "
			cSQL += "B1L_CODOPE  = '"+cOpeFam+"' AND "
			cSQL += "B1L_CODTAB  = '"+aFxSl[nPosSl][4]+"' AND "
			cSQL += "B1L_CDFXSL  = '"+aFxSl[nPosSl][1]+"' AND "
			cSQL += "D_E_L_E_T_ = ' '"

			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSFAI",.F.,.T.)

			TCSetField( "PLSBUSFAI", "B1L_VIGINI", "D" )
			TCSetField( "PLSBUSFAI", "B1L_VIGFIN", "D" )
		
			PLSBUSFAI->(DBEval({|| aadd(aFaixas, {B1L_CODFAI, B1L_IDAINI, B1L_IDAFIN, B1L_VALOR, B1L_VIGINI, B1L_VIGFIN, If(B1L->(FieldPos("B1L_PERPAT")) == 0, 0, B1L_PERPAT)}) }))
			PLSBUSFAI->(DbCloseArea())

			// Pesquisa Faixa Etaria.
			If nPos == 0
				nPos := Ascan(aFaixas, { |x| nIdade >= x[2] .And. nIdade<= x[3] .and. ctod("01/"+cMes+"/"+cAno) >=x[5] .and.( ctod("01/"+cMes+"/"+cAno) <= x[6] .or. empty(x[6])) })
			EndIf

			// Se encontrar uma faixa de quantidade, valoriza por ela.
			If nPos > 0 .and. aFaixas[nPos,4] > 0
				// Obtem os dados de uma faixa de quantidade.
				cFaixa := aFaixas[nPos,1]
				nIdaIni := aFaixas[nPos,2]
				nIdaFin := aFaixas[nPos,3]
				nValor := aFaixas[nPos,4]
			Endif

			// Dados da faixa utilizada.
			cFxaUtil := aFxSl[nPosSl,1]
			nSalIni := aFxSl[nPosSl,2]
			nSalFin := aFxSl[nPosSl,3]

			nValor2 := 0

			If nPos > 0 .And. B1L->(FieldPos("B1L_PERPAT"))>0
				If aFaixas[nPos,7] > 0
					nValor     	:= ((aFaixas[nPos,4]-(aFaixas[nPos,4]*aFaixas[nPos,7])/100))
					nValor2    	:= (aFaixas[nPos,4]*aFaixas[nPos,7])/100
				Endif
			Endif

			// Calculo valor de Pro-rata (Entrada ou Saida)
			If aUsuarios[nFor,16] .Or. aUsuarios[nFor,23]

				If aUsuarios[nFor,16] // Entrada
					nPercDias := plRPerPR(aUsuarios[nFor,14], Nil, @nDiasUtil, Nil, PLDayVencCob(cMatricFam))
					nValorRat := Round(((nValor * nPercDias) / 100), 2)
					nValor := nValorRat	

				Else // Saida				
					nPercDias := plRPerPR(aUsuarios[nFor,24], lConsDtCanc, @nDiasUtil, .T., PLDayVencCob(cMatricFam))
					nValorRat := Round(((nValor * nPercDias) / 100), 2)

					// Quando o Bloqueio RN 412 estiver ativo, o valor do pro-rata será calculado na função CalcProRat
					If GetNewPar("MV_PL9BPRA", "0") == "0"
						nValor := nValorRat
					EndIf			
				EndIf

			EndIf

			// Valor da mensalidade para este usuario ... 						    
			If nValor > 0
				aadd(aValores,{ aUsuarios[nFor,13],; // 01
								nValor,;			 // 02
								str(nIdade,3),;		 // 03
								aUsuarios[nFor,3],;	 // 04
								aUsuarios[nFor,5],;	 // 05 - cSexo
								aUsuarios[nFor,6],;	 // 06 - cGrauPa
								aUsuarios[nFor,4],;	 // 07
								cFaixa,;			 // 08
								cNivelUtil,;		 // 09
								aUsuarios[nFor,7],;	 // 10 - cTipUsu
								aUsuarios[nFor,8],;	 // 11 - Plano
								aUsuarios[nFor,9],;	 // 12 - descricao do plano
								nValorRat,;			 // 13 - Valor calculado da pro rata
								nDiasUtil,;			 // 14 - Quantidade de dias utilizado
								,;					 // 15
								,;					 // 16
								nSalIni,;			 // 17
								nSalFin,;			 // 18
								aUsuarios[nFor,29],; // 19 - Versao do plano
								aUsuarios[nFor,31],; // 20 -
								nValor2})            // 21 - Valor da Patroval   para os casos em que o campo B1J_PERPAT estiver preenchido com pa porcentagem
			EndIf
		Endif
	Next

Return(aValores)


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} GetVlrCredPatronal
Retorna crédito de desconto para o beneficiário com o valor da parcela 
patrocinada como o modo de cobrança for COMPARTILHADA

@author Vinicius Queiros Teixeira
@since 12/05/2022
@version Protheus 12
@obs
	Parcela Patronal Compartilhada: são gerados dois títulos para cada família do subcontrato. 
	A parcela patrocinada é gerada para a empresa e revertida em desconto na mensalidade da 
	família. Portanto, ao gerar o titulo da família, um desconto na mensalidade é concedido, 
	referente à parcela patrocinada. Para conceder o desconto para a família, um lançamento 
	de crédito é gerado (NCC).
/*/
//---------------------------------------------------------------------------------------
Static Function GetVlrCredPatronal(aValor)

	Local nFor := 0
	Local nValorProduto := 0
	Local nValorPatronal := 0
	Local nVlrCredPatronal := 0
	Local nVlrCredito := 0
	Local lPatronalAtivo := .F.
	Local lPatronalDiferencial := .F.

	Default aValor := {}

	If BA3->BA3_TIPOUS == "2" .and. BT6->(FieldPos("BT6_CODPAT")) > 0 .and. BT6->(FieldPos("BT6_MDFTPT")) > 0

		BT6->(DbSetOrder(1))
		BQC->(DbSetOrder(1))

		If BT6->(MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)))		
			lPatronalAtivo := !Empty(BT6->BT6_CODPAT) .and. BT6->BT6_MDFTPT == "3" // 3 = Modo Compartilhada
		EndIf

		If !lPatronalAtivo .And. BQC->(FieldPos("BQC_CODPAT")) > 0 .And. BQC->(FieldPos("BQC_MDFTPT")) > 0
			If BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
				lPatronalAtivo := !Empty(BQC->BQC_CODPAT) .and. BQC->BQC_MDFTPT == "3" // 3 = Modo Compartilhada
			EndIf
		EndIf

		If lPatronalAtivo .And. Len(aValor) >= 2 .And. Valtype(aValor[2]) == "A"
			For nFor := 1 To Len(aValor[2])
				Do Case
					Case aValor[2][nFor][3] == "101" // Mensalidade
						nValorProduto += aValor[2][nFor][2]
						
					Case aValor[2][nFor][3] == "186" // Parcela patrocinada pela Empresa
						nValorPatronal += aValor[2][nFor][2]

						If Len(aValor[2][nFor]) >= 50
							lPatronalDiferencial := aValor[2][nFor][50] 
						EndIf
				EndCase
			Next

			If nValorPatronal > 0
				// O valor do crédito da parcela patronal está limitado ao valor total da mensalidade da família
				Do Case
					Case nValorProduto > nValorPatronal
						nVlrCredPatronal := nValorPatronal

					Case nValorProduto < nValorPatronal
						nVlrCredPatronal := nValorProduto

					Case nValorProduto == nValorPatronal
						nVlrCredPatronal := nValorProduto			
				EndCase	
			EndIf
		EndIf

	Endif

	// Patronal diferencial não gera o crédito para a familia, o desconto é feito direto na mensalidade
	If lPatronalDiferencial .And. nVlrCredPatronal > 0
		nVlrCredito := nVlrCredPatronal
		nVlrCredPatronal := 0 
	EndIf

Return {nVlrCredPatronal, nVlrCredito}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AvaliaLanc  ºAutor  ³ Túlio Cesar      º Data ³  17/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Avalia se um lancamento de faturamento esta ativo ou não   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Na definição dos lançamentos que serao avaliados no fatur. º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AvaliaLanc()
LOCAL lRet := .T.

If BFQ->(FieldPos("BFQ_ATIVO")) > 0 .And. BFQ->BFQ_ATIVO == "0"
   lRet := .F.
Endif

If lPlAvaLan
	lRet := ExecBlock('PLAVALAN',.F.,.F.)  //Retorno .F. para nao AVALIAR o recurso informado
	If ValType(lRet)<> "L"
		lRet := .T.
	EndIf
EndIf
Return(lRet)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CalcProRat
Calcula o pró-rata do bloqueio originado pela RN 412

@author	 Lucas Nonato
@since	 16/05/2017
@version P11 
/*/
//---------------------------------------------------------------------------------------
Static Function CalcProRat(aAux, cPano, cPmes)
	Local nI		:= 1
	Local nDiasMes 	:= 0
	Local nPercMes 	:= 0
	Local cMes		:= cPmes
	Local cAno		:= cPano
	Local cDia		:= ""
	Local cFinal	:= ""

	BA1->(dbSetOrder(2)) // BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO
	For nI := 1 To Len(aAux)

		If aAux[nI][3] $ GetNewPar("MV_PL9BLAN","101/102")

			If BA1->(MsSeek(xFilial("BA1") + aAux[nI][7])) .And. !Empty(BA1->(BA1_DATBLO)) .And. Substr(Dtos(BA1->(BA1_DATBLO)),5,2) == cPmes .And. Substr(Dtos(BA1->(BA1_DATBLO)),1,4) == cPano
				
				cMes := Substr(Dtos(BA1->(BA1_DATBLO)),5,2)
				cAno := Substr(Dtos(BA1->(BA1_DATBLO)),1,4)
				cDia := Substr(Dtos(BA1->(BA1_DATBLO)),7,2)
				
				//Verifica a quantidade de dias no mes
				If cMes $ "01/03/05/07/08/10/12"

					nDiasMes := 31

				ElseIf cMes $ "04/06/09/11"

					nDiasMes := 30

				ElseIf cMes == "02"     

					cFinal  := SubStr(cAno,3,2)
					nResult := 0
				
					If cFinal == "00"
						nResult := Mod(Val(cAno),400)
					Else
						nResult := Mod(Val(cAno),4)
					EndIf
				
					IIf(nResult == 0,nDiasMes := 29,nDiasMes := 28)

				EndIf
						
				
				If aAux[nI][2] > 0

					// Ponto de Entrada para realizar o calculo do percutal e dias utilizados do Pro-rata
					If ExistBlock("PLPRORAT") 
						nPercMes := ExecBlock("PLPRORAT", .F., .F., {BA1->BA1_DATBLO, PLDayVencCob(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)), .T.})[1]
					Else
						nPercMes 	 := (Val(cDia) * 100 / nDiasMes)
					EndIf
					  
					aAux[nI][2]  := aAux[nI][2] * (nPercMes/100)
					aAux[nI][23] := aAux[nI][23] * (nPercMes/100)
					aAux[nI][2]  := Round(aAux[nI][2],2)
					aAux[nI][23] := Round(aAux[nI][23],2)

				EndIf

			EndIf

		EndIf

	Next

Return
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLRETBSQ
Retorna o array contendo os registros relacionados da BSQ para que sejam alterados
após a geração do lote

@author	 Thiago Ribas
@since	 17/05/2018
@version P12 
/*/
//---------------------------------------------------------------------------------------
Function PLRETBSQ(lLimpa)
Default lLimpa := .F.

If lLimpa 
	_aRecBSQ := {}	
EndIf

Return _aRecBSQ



Function PLSBLQDC(dDatBlo, cMotBlo, cOrigBlo)
LOCAL cPermDC := ''

If dDatBlo <> ctod("")

	If cOrigBlo == "U" .And. BG3->(Fieldpos("BG3_BLOQDC")) > 0
		cPermDC := Posicione("BG3",1,xFilial("BG3")+cMotBlo,"BG3_BLOQDC")
	Elseif cOrigBlo == "F" .And. BG1->(Fieldpos("BG1_BLOQDC")) > 0
		cPermDC := Posicione("BG1",1,xFilial("BG1")+cMotBlo,"BG1_BLOQDC")
	Elseif cOrigBlo == "S" .And. BQU->(Fieldpos("BQU_BLOQDC")) > 0
		cPermDC := Posicione("BQU",1,xFilial("BQU")+cMotBlo,"BQU_BLOQDC")
	EndIf

EndIf
Return(cPermDC!='1')



//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMACOBAR
Retorna o array contendo informaç?es de cobrança para geraç?o do lote de cobrança
após a geração do lote

@author	 Team Totvs
@since	 27/05/2019
@version P12 
/*/
//---------------------------------------------------------------------------------------
Function PLSMACOBAR(nSeq,aRet,cTipEve,nValorEve,cCodEve,cCodEveOri,cDesEveOri,cCargo,cMatUsu,cNomUsr,lTotal,cSexo,cGrauPa,cFiller,cCodFai,cNivFai,cTipUsu,cAlias,cOrigem,;
					cBaseIr,nIdaIni,nIdaFin,cVerba,nVlrMes,nSaldo1,nSaldo2,nTotSal,nRecno,nValDes,;
					nValAcre,cCodSeq,cAno,cMes,lCusOpe,cTpPlan,cTpforn ,cCodFor,cSeqDep,cPlanGPE,;
					lPatroDif,dDatDe,dDatAte, cCodSB1, cCodTES, cCompRea, nValAtual, nValAnter, cCodPla, cVerPla, cDesPla)
	
nSeq ++

 AaDd(aRet,{   cTipEve,;			//01
               nValorEve,;			//02
               cCodEve,;            //03
               cCodEveOri,;			//04 
               cDesEveOri,;			//05
               cCargo,;				//06
               cMatUsu,;			//07
               cNomUsr,;			//08
               lTotal,;				//09
               cSexo,;				//10
               cGrauPa,;			//11
               cFiller,;			//12
               cCodFai,;			//13
               cNivFai,;			//14
               cTipUsu,;			//15
               cAlias,;				//16
               cOrigem,;			//17
               cBaseIr,;			//18
               StrZero(nSeq,4),;	//19
               nIdaIni,;			//20
               nIdaFin,;			//21
               cVerba,;				//22
               nVlrMes,;			//23
               nSaldo1,;			//24
               nSaldo2,;			//25
               nTotSal,;			//26
               nRecno,;				//27
               nValDes,;			//28
               nValAcre,;			//29
               cCodSeq,;			//30
               cCompRea,;			//31
               nValAtual,;			//32
               nValAnter,;			//33
               cCodPla,;			//34 - Codigo do plano
               cVerPla,;			//35 - Versao do plano
               cDesPla,;			//36 - Descricao do plano
               cCodSB1,;			//37 - Codigo do Produto SB1 ERP
               cCodTES,;            //38 - Codigo da TES SB1 ERP
               0,;					//39 - Recno do BM1 para uso generico
               0,;         			//40 - Total do desconto aglutinado para o item - integracao com a nota de saida.
               cAno,; 				//41 - Ano de Competencia do lançamento - Para utilizar Periodicidade
               cMes,;				//42 - Mes de Competencia do lançamento - Para utilizar Periodicidade
               lCusOpe,;			//43 - Se e lancamento de custo operacional ou nao
               .F.,;          		//44-PARCELAMENTO (reservado)
               cTpPlan,;            //45- Tipo do Plano no modulo Gestão de Pessoal
               cTpforn ,;           //46- Tipo de fornecedor do plano (1-Ass. Medica; 2 =Ass. Odontologica
               cCodFor,;            //47- Codigo do fornecedor do plano
               cSeqDep,; 			//48- codigo do dependente
               cPlanGPE,;			//49-codigo do plano do GPE
               lPatroDif,; 			//50-Patronal diferenciado (Acordo ANS CApesesp)
			   dDatDe,; 			//51- data inicio descongo
			   dDatAte		})		//52- data fim desconto 



return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckFatMensal
Verifica se a mensalidade já foi faturada

@author	 Victor Alves
@since	 16/06/2021
@version P11 
/*/
//---------------------------------------------------------------------------------------
Static Function CheckFatMensal(cMatricFam, cAno, cMes, cCodTip)

	Local cSql := ""
	Local nQuant := 0
	Local lRetorno := .F.
	
	Default cMatricFam := ""
	Default cAno := ""
	Default cMes := ""
	Default cCodTip := ""

	cSql := "SELECT COUNT(BM1_CODTIP) CONTADOR FROM " + RetSQLName("BM1") + " BM1"
	cSql += " WHERE BM1_FILIAL = '" + xFilial("BM1") + "'"
	cSql += " 	AND BM1.BM1_CODINT = '" + Substr(cMatricFam,1,4) + "'"
	cSql += " 	AND BM1.BM1_CODEMP = '" + Substr(cMatricFam,5,4) + "'"
	cSql += " 	AND BM1.BM1_MATRIC = '" + Substr(cMatricFam,9,6) + "'"
	cSql += " 	AND BM1.BM1_MES = '" + cMes + "'"
	cSql += " 	AND BM1.BM1_ANO = '" + cAno + "'"
	cSql += " 	AND BM1.BM1_CODTIP = '" + cCodTip + "'"
	cSql += " 	AND D_E_L_E_T_ = ' ' "

	nQuant := MPSysExecScalar(cSql, "CONTADOR")

	lRetorno := IIF(nQuant > 0, .T., .F.)

Return lRetorno


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLDayVencCob
Retorna o dia de vencimento da cobrança da familia informada

@author Vinicius Queiros Teixeira
@since 06/05/2022
@version Protheus 12
/*/
//---------------------------------------------------------------------------------------
Function PLDayVencCob(cMatricFamilia)

	Local nDayVencto := 0
	Local aAreaBA3 := BA3->(GetArea())
	Local aAreaBQC := BQC->(GetArea())
	Local aAreaBT5 := BT5->(GetArea())
	Local aAreaBG9 := BG9->(GetArea())

	Default cMatricFamilia := ""

	If !Empty(cMatricFamilia)

		BA3->(DbSetOrder(1))
		If BA3->(MsSeek(xFilial("BA3")+cMatricFamilia))

			If BA3->BA3_TIPOUS == "1" // Contrato Pessoa Física
				nDayVencto := BA3->BA3_VENCTO 

			Else // Contrato Pessoa Juridica
				If BA3->BA3_COBNIV == "1" 
					nDayVencto := BA3->BA3_VENCTO
				Else
					BQC->(DbSetOrder(1))
					If BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB))) .And. BQC->BQC_COBNIV == "1"
						nDayVencto := BQC->BQC_VENCTO
					Else
						BT5->(DbSetOrder(1))
						If BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON))) .And. BT5->BT5_COBNIV == "1"
							nDayVencto := BT5->BT5_VENCTO
						Else
							BG9->(DbSetOrder(1))
							If BG9->(MsSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
								nDayVencto := BG9->BG9_VENCTO
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf

	RestArea(aAreaBA3)
	RestArea(aAreaBQC)
	RestArea(aAreaBT5)
	RestArea(aAreaBG9)
	
Return nDayVencto


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} RegrasCobPatronal
Retorna as configurações da tabela patronal informada.

@author Vinicius Queiros Teixeira
@since 30/06/2022
@version Protheus 12
/*/
//---------------------------------------------------------------------------------------
Static Function RegrasCobPatronal(cOperadora, cCodTabPatronal)

	Local aRegras := {}
	Local lNewCampos := B1I->(FieldPos("B1I_GRAUTI")) > 0 .And. B1I->(FieldPos("B1I_GRAUCO")) > 0 .And. B1I->(FieldPos("B1I_IDAMAX")) > 0 .And.;
						B1I->(FieldPos("B1I_IDAEST")) > 0 .And. B1I->(FieldPos("B1I_GRAUDE")) > 0 .And. B1I->(FieldPos("B1I_TPAGRE")) > 0

	Default cOperadora := ""
	Default cCodTabPatronal := ""
	
	If lNewCampos
		B1I->(DbSetOrder(1))
		If B1I->(MsSeek(xFilial("B1I")+cOperadora+cCodTabPatronal))

			If !Empty(B1I->B1I_GRAUTI) .And. !Empty(B1I->B1I_GRAUCO) .And. B1I->B1I_IDAMAX > 0 .And. B1I->B1I_IDAEST > 0
				aAdd(aRegras, B1I->B1I_GRAUTI) // Grau Parentesco Titular
				aAdd(aRegras, B1I->B1I_GRAUCO) // Grau Parentesco Conjuge
				aAdd(aRegras, B1I->B1I_IDAMAX) // Idade Maxima do Dependente
				aAdd(aRegras, B1I->B1I_IDAEST) // Idade Maxima do Estudante  
				aAdd(aRegras, Alltrim(B1I->B1I_GRAUDE)) // Dependentes que tem direito 
				aAdd(aRegras, B1I->B1I_TPAGRE) // Beneficiários Agregados
			EndIf 

		EndIf
	EndIf

Return aRegras


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ChckBenefPatronal
Valida se o beneficiário tem direito a receber o valor patronal da Empresa

@author Vinicius Queiros Teixeira
@since 30/06/2022
@version Protheus 12
/*/
//---------------------------------------------------------------------------------------
Static Function ChckBenefPatronal(aRegrasPatronal, aDadosUsuario, dDtCobranca)

	Local lDireitoPatronal := .F.
	Local nMesCobranca := Month(dDtCobranca)
	Local aDadosPE := {}
	Local lDireitoPE := .T.
	// Dados do Beneficiário 
	Local cMatricVida := ""
	Local cMatricBeneficiaro := aDadosUsuario[13]
	Local nMesNascBeneficiario := Month(aDadosUsuario[2])
	Local nIdade := Calc_Idade(dDtCobranca, aDadosUsuario[2])
	Local cGrauBeneficiario := aDadosUsuario[6]
	Local cTipoUsuario := aDadosUsuario[7]
	Local lEstudante := .F.
	Local lDeficiente := .F.
	// Dados da Regra Patronal
	Local cGrauTitular := aRegrasPatronal[1]
	Local cGrauConjuge := aRegrasPatronal[2]
	Local nIdaMaxDependente := aRegrasPatronal[3]
	Local nIdaMaxEstudante := aRegrasPatronal[4]
	Local cDependentesDireito := aRegrasPatronal[5]
	Local lDireitoAgregado := aRegrasPatronal[6] == "1" // Sim

	If ExistBlock("PLCPATRO")
		aDadosPE := ExecBlock("PLCPATRO", .F., .F., {cMatricBeneficiaro})

		If ValType(aDadosPE) == "A" .And. Len(aDadosPE) >= 3
			cGrauBeneficiario := aDadosPE[1]
			cTipoUsuario := aDadosPE[2]
			lDireitoPE := aDadosPE[3]

			If !lDireitoPE
				Return .F.
			EndIf
		EndIf
	EndIf

	If Len(aDadosUsuario) >= 35
		cMatricVida := aDadosUsuario[35]

		BTS->(DbSetOrder(1))
		If BTS->(MsSeek(xFilial("BTS")+cMatricVida))
			lEstudante := BTS->BTS_UNIVER == "1" // 1 = Sim
			lDeficiente := BTS->BTS_DEFFIS == "1" // 1 = Sim
		EndIf
	EndIf
	
	Do Case
		Case Alltrim(cTipoUsuario) == "A" .And. !lDireitoAgregado // Beneficiário Agregado não tem direito
			lDireitoPatronal := .F.
		
		Case cGrauBeneficiario == cGrauTitular .Or. cGrauBeneficiario == cGrauConjuge // Beneficiario Titular e Conjuge tem direito
			lDireitoPatronal := .T.

		Case !(cGrauBeneficiario $ cDependentesDireito) // Dependentes que não estão na lista não tem direito
			lDireitoPatronal := .F.
		
		Case nIdade < nIdaMaxDependente .Or. (nIdade == nIdaMaxDependente .And. nMesCobranca == nMesNascBeneficiario) // Dependente que completar [nIdaMaxDependente] anos para de receber no mês subsequente ao aniversario
			lDireitoPatronal := .T.
		
		Case lEstudante .And. nIdade <= nIdaMaxEstudante // Dependente que completar [nIdaMaxDependente] anos que apresentar declaração de estudante recebe até aos [nIdaMaxEstudante] anos
			lDireitoPatronal := .T.
		
		Case lDeficiente // Dependente que completar 21 anos e que tem necessidades especiais tem que receber o per-capita até terminar o tratamento
			lDireitoPatronal := .T.
	EndCase

Return lDireitoPatronal
