#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FINR085M.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍ'ÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR085M   º Autor ³ WAGNER MONTENEGRO º Data ³  17/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Carta de Retenção - ITBIS                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FINR085M - Republica Dominicana                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINR085M
Local cPerg	:= "FI085M"
Local nValorNF	:=0
Local nValorITBs:=0
Local nValorITVr:=0
Local nAliqITB	:=0
Local dDataNF
Local cFornec := ""
Private oFont06,oFont08, oFont08n,oFont09, oFont09n,oFont10,oFont10n, oFont14n, oFont16n
Private oPrint
//*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Ordem de Pago - Numero da Ordem de Pago            ³
//³ mv_par02 - Vecto Carta 	- Data de vencimento da carta       ³
//³ mv_par03 - Destinatario	- Nome do destinatario da carta     ³
//³ mv_par04 - Remetente   	- Nome do remetente                 ³
//³ mv_par05 - Cargo         - Cargo do remetente                	³
//*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

If Pergunte(cPerg)
	oFont10 	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont12  := TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	oFont14  := TFont():New("Courier New",14,14,,.F.,,,,.T.,.F.)
	oFont10n	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
	oFont12n := TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
	oFont14n := TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)
	DbSelectArea("SE2")
	DbSetOrder(1)
	DbSelectarea("SFE")
	DbSetOrder(2)
	If DbSeek(xFilial("SFE")+MV_PAR01)
		oPrint:= TNewMSPrinter():New( "" )
		oPrint:SetPortrait()
		While !SFE->(EOF()) .and. SFE->FE_FILIAL+SFE->FE_ORDPAGO==xFilial("SFE")+MV_PAR01
			If SFE->FE_TPTIMP=="IT-"
			   If SE2->(DbSeek(xFilial("SE2")+SFE->FE_SERIE+SFE->FE_NFISCAL+SFE->FE_PARCELA+SFE->FE_TPTPAI+SFE->FE_FORNECE+SFE->FE_LOJA) )
				   nValorNF		:=SE2->E2_VALOR
					dDataNF		:=SFE->FE_EMISSAO
					nValorITVr	:=SFE->FE_RETENC
					nValorITBs	:=SFE->FE_VALBASE
					nAliqITB		:=SFE->FE_ALIQ
					cFornec := RetForn(SFE->FE_FORNECE+SFE->FE_LOJA)
					FINProc(nValorNF,nValorITBs,nValorITVr,nAliqITB,dDataNF,cFornec)
			   Endif
     		Endif
     		SFE->(DbSkip())
		Enddo
		oPrint:Preview()
	Else
		MSGALERT(STR0050) //"Nenhum registro foi encontrado para impressão"
	Endif
Endif
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINProc   ³ Autor ³ WAGNER MONTENEGRO    ³ Data | 17/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressão do relatorio.						         		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINProc( ExpN1,ExpN2,ExpN3,ExpN4,ExpD1)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Valor do Título                                     ³±±
±±³          ³ExpN2 = Valor da Base do ITBIS                              ³±±
±±³          ³ExpN3 = Valor do ITBIS                                      ³±±
±±³          ³ExpN4 = Aliquota do ITBIS                                   ³±±
±±³          ³ExpD1 = Data de emissão da Retenção                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FINProc( nValorNF,nValorITBs,nValorITVr,nAliqITB,dDataNF,cFornec )
Local cSacado01		:= mv_par03
Local cSacado02		:= STR0001
Local cSacado03		:= STR0002
Local cSacado04		:= STR0003
Local cSacado05		:= STR0004
Local cSacado06		:= STR0005
Local cCedente01		:= mv_par04
Local cCedente02		:= mv_par05
Local nL	:=400 //Linha Inicial
Local nS:= 75  //Salto de Linha
Local nC:= 150 //Margem Esquerda
oPrint:STARTPAGE()
oPrint:say (nL,nC,cSacado01, oFont14n)
nL+=nS
oPrint:say (nL,nC,cSacado02, oFont12)
nL+=nS
oPrint:say (nL,nC,cSacado03, oFont12)
nL+=nS
oPrint:say (nL,nC,cSacado04, oFont12)
nL+=nS
oPrint:say (nL,nC,cSacado05, oFont12)
nL+=nS
nL+=nS
nL+=nS
nL+=nS
oPrint:say (nL,nC,cSacado06, oFont12)
nL+=nS
nL+=nS
oPrint:say (nL,nC,STR0006, oFont10)
oPrint:say (nL,nC,Space(Len(STR0006)+1)+cFornec+",", oFont10n)
nL+=nS
oPrint:say (nL,nC,STR0007+SA2->A2_CGC, oFont10n)
oPrint:say (nL,nC,Space(Len(STR0007)+Len(SA2->A2_CGC))+STR0008, oFont10)
oPrint:say (nL,nC,Space(Len(STR0007)+Len(SA2->A2_CGC))+Space(Len(STR0008)+1)+FINAMES(dDataNF), oFont10n)
oPrint:say (nL,nC,Space(Len(STR0007)+Len(SA2->A2_CGC))+Space(Len(STR0008)+1)+Space(Len(FINAMES(dDataNF)))+STR0009,oFont10)
oPrint:say (nL,nC,Space(Len(STR0007)+Len(SA2->A2_CGC))+Space(Len(STR0008)+1)+Space(Len(FINAMES(dDataNF)))+Space(Len(STR0009))+AllTrim(STR(Year(dDataNF))),oFont10n)
oPrint:say (nL,nC,Space(Len(STR0007)+Len(SA2->A2_CGC))+Space(Len(STR0008)+1)+Space(Len(FINAMES(dDataNF)))+Space(Len(STR0009))+Space(Len(AllTrim(STR(Year(dDataNF)))))+STR0010,oFont10)
nL+=nS
oPrint:say (nL,nC,STR0011, oFont10)
oPrint:say (nL,nC,Space(Len(STR0011))+STR0012+TransForm(nValorNF,"@E 999,999,999,999.99"), oFont10n)
oPrint:say (nL,nC,Space(Len(STR0011))+Space(Len(STR0012))+Space(Len(TransForm(nValorNF,"@E 999,999,999,999.99")))+STR0013, oFont10)
oPrint:say (nL,nC,Space(Len(STR0011))+Space(Len(STR0012))+Space(Len(TransForm(nValorNF,"@E 999,999,999,999.99")))+Space(Len(STR0013))+STR0014+TransForm(nValorITBs,"@E 999,999,999,999.99"), oFont10n)
oPrint:say (nL,nC,Space(Len(STR0011))+Space(Len(STR0012))+Space(Len(TransForm(nValorNF,"@E 999,999,999,999.99")))+Space(Len(STR0013))+Space(Len(STR0014))+Space(Len(TransForm(nValorITBs,"@E 999,999,999,999.99")))+STR0015, oFont10)
nL+=nS
oPrint:say (nL,nC,STR0016, oFont10)
oPrint:say (nL,nC,Space(Len(STR0016))+STR0014+TransForm(nValorITVr,"@E 999,999,999,999.99"), oFont10n)
oPrint:say (nL,nC,Space(Len(STR0016))+Space(Len(STR0014))+Space(Len(TransForm(nValorITVr,"@E 999,999,999,999.99")))+STR0017, oFont10)
oPrint:say (nL,nC,Space(Len(STR0016))+Space(Len(STR0014))+Space(Len(TransForm(nValorITVr,"@E 999,999,999,999.99")))+Space(Len(STR0017))+Transform(nAliqITB,"@E 999.99")+"%", oFont10n)
oPrint:say (nL,nC,Space(Len(STR0016))+Space(Len(STR0014))+Space(Len(TransForm(nValorITVr,"@E 999,999,999,999.99")))+Space(Len(STR0017))+Space(Len(Transform(nAliqITB,"@E 999.99"))+1)+STR0018, oFont10)
nL+=nS
oPrint:say (nL,nC,STR0019, oFont10)
nL+=nS
oPrint:say (nL,nC,STR0020, oFont10)
oPrint:say (nL,nC,Space(Len(STR0020)+1)+FINAMES(dDataNF), oFont10n)
oPrint:say (nL,nC,Space(Len(STR0020)+1)+Space(Len(FINAMES(dDataNF)))+STR0009, oFont10)
oPrint:say (nL,nC,Space(Len(STR0020)+1)+Space(Len(FINAMES(dDataNF)))+Space(Len(STR0009))+AllTrim(STR(Year(dDataNF))), oFont10n)
nL+=nS
oPrint:say (nL,nC,STR0021, oFont10)
nL+=nS
oPrint:say (nL,nC,STR0022, oFont10)
oPrint:say (nL,nC,Space(Len(STR0022))+StrZero(Day(MV_PAR02),2), oFont10n)
oPrint:say (nL,nC,Space(Len(STR0022))+Space(Len(StrZero(Day(MV_PAR02),2)))+STR0009, oFont10)
oPrint:say (nL,nC,Space(Len(STR0022))+Space(Len(StrZero(Day(MV_PAR02),2)))+Space(Len(STR0009))+FINAMES(MV_PAR02), oFont10n)
oPrint:say (nL,nC,Space(Len(STR0022))+Space(Len(StrZero(Day(MV_PAR02),2)))+Space(Len(STR0009))+Space(Len(FINAMES(MV_PAR02)))+STR0023, oFont10)
nL+=nS
nL+=nS
oPrint:say (nL,nC,STR0024, oFont10)
nL+=nS
oPrint:say (nL,nC,STR0025+Rtrim(SM0->M0_CIDCOB)+STR0026+AllTrim(STR(Day(dDataBase)))+STR0027+FINAMES(dDataNF)+STR0009+AllTrim(STR(Year(dDataNF)))+".", oFont10)
nL+=nS
nL+=nS
nL+=nS
nL+=nS
oPrint:say (nL,nC,cCedente01, oFont14n)
nL+=nS
oPrint:say (nL,nC,cCedente02, oFont12)
oPrint:EndPage()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FINAMES ºAutor  ³ WAGNER MONTENEGRO     ³     17/05/2011   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retornar o mês por extenso                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rep.Dominicana                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function FINAMES(dDtEmissao)
Local cDataEmissao := ""
Local aMes := {}

AADD(aMes,STR0038)
AADD(aMes,STR0039)
AADD(aMes,STR0040)
AADD(aMes,STR0041)
AADD(aMes,STR0042)
AADD(aMes,STR0043)
AADD(aMes,STR0044)
AADD(aMes,STR0045)
AADD(aMes,STR0046)
AADD(aMes,STR0047)
AADD(aMes,STR0048)
AADD(aMes,STR0049)
If !Empty(dDtEmissao)
	cDataEmissao := aMes[Month(dDtEmissao)]
EndIf
Return( cDataEmissao )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RetForn ºAutor  ³                       ³     17/05/2011   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o nome completo do fornecedor informado na chave   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rep.Dominicana                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetForn(cChave)

Local aArea := GetArea()

Local cNome := ""

dbSelectArea("SA2")
SA2->(dbSetOrder(1))
If SA2->(dbSeek(xFilial("SA2")+cChave))
	cNome:= RTRIM(SA2->A2_NOME)
EndIf
RestArea(aArea)
Return(cNome)
