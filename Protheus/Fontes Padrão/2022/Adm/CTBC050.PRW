#Include "CTBC050.CH"
#INCLUDE "PROTHEUS.CH"

// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ CTBC050  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Financeira -> p/ Rastrear Lancto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBC050()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBBaixapg³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Baixa a Pagar                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBBaixaPg                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbBaixaPg()

Local aSaveArea		:= GetArea()
Local aMotBx		:= ReadMotBx()
Local cMoeda
Local cHist070
Local cMotBx
Local cBanco
Local cAgencia
Local cConta
Local cDescrMo
Local cNumCheq  
Local cBenef    
Local cSeqSE5
Local oDlg          
Local nOpca
Local nTotAbat		:= 0
Local nValPgto		:= 0
Local nCorrec		:= 0
Local nDescont		:= 0
Local nMulta		:= 0
Local nJuros		:= 0
Local nValEstrang	:= 0
Local nPagtoParc	:= 0

***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao: 530
* Chave Busca: E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA
* Ordem Busca: 2
* Descricao : Baixas a Pagar
* Rot Executar: CTBBAIXAPG()
* Alias Arq: SE5
***********************************************************************

//OBS: A construcao desta consulta, deve se basear no registro do SE5 -> Chave 2 do SE5

// Carrega variaveis referentes aos dados do titulo -> SE2
dbSelectArea("SE2")
dbSetOrder(1)
dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+;
	SE5->E5_CLIFOR+SE5->E5_LOJA)
	
cTitulo		:= SE2->E2_PREFIXO + " " + SE2->E2_NUM
nPagtoParc	:= SE2->E2_VALOR-SE2->E2_SALDO
cMoeda		:= IIF(Empty(SE2->E2_MOEDA),"1",AllTrim(Str(SE2->E2_MOEDA,2)))
nTotAbat	:= 	SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,;
			SE2->E2_MOEDA,"V",SE2->E2_BAIXA,SE2->E2_LOJA)

// Carrega valores baixados a partir do TipoDoc = "VL" -> SE5
dbSelectArea("SE5")
dbSetOrder(2)
nCorrec		:= SE5->E5_VLCORRE
nDescont	:= SE5->E5_VLDESCO
nMulta		:= SE5->E5_VLMULTA
nJuros		:= SE5->E5_VLJUROS
nValPgto	:= SE5->E5_VALOR
cHist070 	:= SE5->E5_HISTOR
cMotBx   	:= SE5->E5_MOTBX
cNumBor  	:= SubStr(SE5->E5_DOCUMEN,1,6)
nValestrang := SE5->E5_VLMOED2
cBanco		:= SE5->E5_BANCO
cAgencia	:= SE5->E5_AGENCIA
cConta		:= SE5->E5_CONTA

nI :=  Ascan(aMotBx, {|x| Substr(x,1,3) == Upper(cMotbx) })
cDescrMo := if( nI > 0,Substr(aMotBx[nI],07,10),"" )

// carrega os dados do banco
dbSelectArea("SA6")
dbSetOrder(1)
If !DbSeek( xFilial('SA6') + cBanco + cAgencia + cConta )
	ConoutR( 'CTBC050: Banco, Agencia, Conta não encontrado!|' + Str(ThreadId())  )
Endif

// Carrega o nome do fornecedor na tela
dbSelectArea("SA2")
dbSetOrder(1)
If dbseek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
	cNomeFor	:= SE2->E2_FORNECE + " " + SA2->A2_NOME
Else
	cNomeFor 	:= SE2->E2_FORNECE
EndIf		

// Carrega informacoes do Cheque
dbSelectArea("SEF")
dbSetOrder(3)
If SEF->(dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_NUMCHEQ))
	cSeqSe5 := SE5->E5_SEQ
	While SEF->( !Eof()) .and. EF_FILIAL == xFilial() .and. ;
		EF_TITULO == SE5->E5_NUMERO	.and. ;
		EF_PARCELA== SE5->E5_PARCELA 	.and. ;
		EF_PREFIXO== SE5->E5_PREFIXO 	.and. ;
		EF_TIPO   == SE5->E5_TIPO		.and. ;
		EF_NUM    == SE5->E5_NUMCHEQ
		If SEF->EF_SEQUENC == cSeqSe5 .and. SE5->E5_CLIFOR == SEF->EF_FORNECE
			IF SEF->EF_IMPRESS # "C"
				cNumCheq:= SEF->EF_NUM
				cBenef  := SEF->EF_BENEF
			Endif
			Exit
		Endif
		SEF->( dbSkip() )
	Enddo
EndIf
dbSelectArea("SEF")
dbSetOrder(1)

nOpca := 0
DEFINE MSDIALOG oDlg FROM	31,15 TO 375,574 TITLE OemToAnsi(STR0027) PIXEL OF oMainWnd //  "Baixas a Pagar"
@ 37, 001 TO 167, 137 LABEL OemToAnsi(STR0001)OF oDlg  PIXEL //"Dados Gerais"
@ 38, 143 TO 168, 278 LABEL OemToAnsi(STR0002)OF oDlg  PIXEL // "Valores da Baixa"
@ 01, 002 TO 035, 278 LABEL OemToAnsi(STR0003)OF oDlg  PIXEL // "Principal"

@ 010, 010 SAY OemToAnsi(STR0004)		SIZE 18,07 OF oDlg PIXEL //"T¡tulo"
@ 008, 030 MSGET oTitulo	VAR cTitulo	F3 "SE2RDO"	SIZE 57,10 OF oDlg PIXEL READONLY 
oTitulo:cSx1Hlp := "CTITULO"
@ 010, 095 SAY OemToAnsi(STR0005)		SIZE 31,07 OF oDlg PIXEL //"Emiss„o"
@ 008, 127 MSGET oEmissao	VAR SE2->E2_EMISSAO SIZE 35,10 OF oDlg PIXEL When .F.
oEmissao:cSx1Hlp := "E2_EMISSAO"
@ 010, 169 SAY OemToAnsi(STR0006)	 	SIZE 39,07 OF oDlg PIXEL //"Vencto.Atual"
@ 008, 210 MSGET oVencRea	VAR SE2->E2_VENCREA SIZE 31,10 OF oDlg PIXEL When .F.
oVencRea:cSx1Hlp := "E2_VENCREA"
@ 022, 005 SAY OemToAnsi(STR0007)		SIZE 22,07 OF oDlg PIXEL //"Fornec."
@ 020, 030 MSGET oNomeFor	VAR cNomeFor F3 "SA2" SIZE 211,9 OF oDlg PIXEL READONLY
oNomeFor:cSx1Hlp := "A2_NOME"
@ 046, 007 SAY OemToAnsi(STR0008)	 	SIZE 38,07 OF oDlg PIXEL //"Hist.Emiss„o"
@ 043, 050 MSGET oHist		VAR SE2->E2_HIST SIZE 79,10 OF oDlg PIXEL When .F.
oHist:cSx1Hlp := "E2_HIST"
@ 057, 007 SAY OemToAnsi(STR0009)		SIZE 39,07 OF oDlg PIXEL //"Portador"
@ 056, 050 MSGET oPortado	VAR SE2->E2_PORTADO	SIZE 66,10 OF oDlg PIXEL When .F.
oPortado:cSx1Hlp := "E2_PORTADO"
@ 069, 007 SAY OemToAnsi(STR0010)		SIZE 40,07 OF oDlg PIXEL //"Banco"
@ 068, 050 MSGET oBanco		VAR cBanco	SIZE 22,10 OF oDlg PIXEL When .F.
oBanco:cSx1Hlp := "E5_BANCO"
@ 081, 007 SAY OemToAnsi(STR0011)		SIZE 39,07 OF oDlg PIXEL //"Agˆncia"
@ 080, 050 MSGET oAgencia	VAR cAgencia SIZE 35,10 OF oDlg PIXEL When .F.
oAgencia:cSx1Hlp := "E5_AGENCIA"
@ 093, 007 SAY OemToAnsi(STR0012)		SIZE 41,07 OF oDlg PIXEL //"Conta"	
@ 092, 050 MSGET oConta		VAR cConta	F3 "SA6" SIZE 66,10 OF oDlg PIXEL READONLY
oConta:cSx1Hlp := "E5_CONTA"
@ 106, 007 SAY OemToAnsi(STR0013) 		SIZE 38,07 OF oDlg PIXEL //"Data Receb."
@ 104, 050 MSGET oBAIXA		VAR SE2->E2_BAIXA SIZE 39,10 OF oDlg PIXEL When .F.
oBAIXA:cSx1Hlp := "E2_BAIXA"
@ 118, 007 SAY OemToAnsi(STR0014)	  	SIZE 39,07 OF oDlg PIXEL //"Hist.Baixa"
@ 117, 050 MSGET oHistBX 	VAR cHist070 SIZE 83,10 OF oDlg PIXEL When .F.
oHistBX:cSx1Hlp := "E5_HISTOR"
@ 130, 007 SAY OemToAnsi(STR0015)	  	SIZE 40,07 OF oDlg PIXEL //"Cheque No."
@ 128, 050 MSGET oNumCheq	VAR cNumCheq SIZE 38,10 OF oDlg PIXEL When .F.
oNumCheq:cSx1Hlp := "EF_NUMCHEQ"
@ 142, 007 SAY OemToAnsi(STR0016)		SIZE 36,07 OF oDlg PIXEL //"Beneficiário"
@ 140, 050 MSGET oBenef		VAR cBenef 	SIZE 84,10 OF oDlg PIXEL When .F.
oBenef:cSx1Hlp := "EF_BENEF"
@ 155, 007 SAY OemToAnsi(STR0017)		SIZE 37,07 OF oDlg PIXEL //"Mot.Baixa"
@ 153, 050 MSGET oDescrmo VAR cDescrMo 	SIZE 83,10 OF oDlg PIXEL When .F.
oDescrmo:cSx1Hlp := "CDESCRMOT"
@ 047, 151 SAY OemToAnsi(STR0018)  	SIZE 53,07 OF oDlg PIXEL //"Valor Original"
@ 044, 208 MSGET oValor		VAR SE2->E2_VALOR SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_VALOR")
oValor:cSx1Hlp := "E2_VALOR"
@ 058, 151 SAY OemToAnsi(STR0019)		SIZE 53,07 OF oDlg PIXEL //"- Abatimentos"
@ 056, 208 MSGET oTotAbat	VAR nTotAbat				SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_VALOR")
oTotAbat:cSx1Hlp := "FINTOTABAT"
@ 070, 151 SAY OemToAnsi(STR0020)  	SIZE 53,07 OF oDlg PIXEL //"- Pagtos.Parciais"
@ 069, 208 MSGET oPagtoParc	VAR nPagtoParc				SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_VALOR")
oPagtoParc:cSx1Hlp := "FINPAGPARC"
@ 082, 151 SAY OemToAnsi(STR0021)	 	SIZE 53,07 OF oDlg PIXEL //"- Descontos"
@ 081, 208 MSGET oDescont	VAR nDescont				SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_DESCONT")
oDescont:cSx1Hlp := "E2_DESCONT"
@ 095, 151 SAY OemToAnsi(STR0022)		SIZE 53,07 OF oDlg PIXEL //"+ Multa"
@ 093, 208 MSGET oMulta		VAR nMulta 				SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_MULTA")
oMulta:cSx1Hlp := "E2_MULTA"
@ 107, 151 SAY OemToAnsi(STR0023) 		SIZE 53,07 OF oDlg PIXEL //"+ Tx.Permanenc."
@ 105, 208 MSGET oJuros		VAR nJuros 				SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_JUROS")
oJuros:cSx1Hlp := "E2_JUROS"
@ 119, 151 SAY OemToAnsi(STR0024)  	SIZE 53,07 OF oDlg PIXEL //"= Valor Pago"
@ 117, 208 MSGET oValPagto	VAR nValPgto				SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_VALLIQ")
oValPagto:cSx1Hlp := "E2_VALLIQ"
IF SE2->E2_MOEDA > 1
	@ 131, 151 SAY OemToAnsi(STR0025)  + SubStr(GetMV("MV_SIMB"+cMoeda),1,3)    SIZE 53,07 OF oDlg PIXEL //"Valor "
	@ 129, 208 MSGET oValEstrang	VAR nValEstrang		SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_VALOR")
	oValEstrang:cSx1Hlp := "VALMOEDAES"
	@ 144, 151 SAY OemToAnsi(STR0026)  SIZE 53,07 OF oDlg PIXEL //"+ Corr.Monet ria"
	@ 142, 208 MSGET oCorrec 		VAR nCorrec			SIZE 66,10 OF oDlg PIXEL When .F. Picture PesqPict("SE2","E2_CORREC")
	oCorrec:cSx1Hlp := "E2_CORREC"
ENDIF

DEFINE SBUTTON FROM 06, 246 TYPE 1 ENABLE OF oDlg ACTION ( nOpca := 1,oDlg:End() )
DEFINE SBUTTON FROM 20, 246 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBBaixaRc³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Baixa a Receber                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBBaixaRc                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbBaixaRc()

Local aSaveArea		:= GetArea()
Local aMotBx		:= ReadMotBx()
Local cMoeda
Local cTitulo
Local cSituacao
Local cBanco
Local cAgencia
Local cConta
Local cHist070
Local cMot070
Local cDescrMo
Local cNomeCli
Local dBaixa
Local nTotAbat		:= 0
Local nValorM1		:= 0
Local nCorrec		:= 0
Local nDescont		:= 0
Local nMulta		:= 0
Local nJuros		:= 0
Local nValRec		:= 0
Local nValorM2		:= 0
Local nI
Local nOpca
Local oDlg

***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao: 520
* Chave Busca: E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA
* Ordem Busca: 2
* Descricao : Baixas a Receber
* Rot Executar: CTBBAIXARC()
* Alias Arq: SE5
***********************************************************************

//OBS: A construcao desta consulta, deve se basear no registro do SE5 -> Chave 2 do SE5

// Carrega variaveis referentes aos dados do titulo -> SE1
dbSelectArea("SE1")
dbSetOrder(1)
dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+;
	SE5->E5_CLIFOR+SE5->E5_LOJA)
	
cMoeda   	:= IIF(Empty(SE1->E1_MOEDA),"1",AllTrim(Str(SE1->E1_MOEDA,2)))
cTitulo     := SE1->E1_PREFIXO + " " + SE1->E1_NUM
cSituacao   := Transform( SE1->E1_SITUACA,"9" ) + " " + fa070situa()
cDescMoeda  := SubStr(GetMV("MV_SIMB"+cMoeda),1,3)
nTotAbat 	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA, SE1->E1_MOEDA, "V" )
nValorM1 	:= SE1->E1_VALOR-SE1->E1_SALDO

dbSelectArea("SE5")
dbSetOrder(2)
cBanco		:= SE5->E5_BANCO
cAgencia	:= SE5->E5_AGENCIA
cConta		:= SE5->E5_CONTA
cHist070	:= SE5->E5_HISTOR
cMot070		:= SE5->E5_MOTBX
dBaixa		:= SE5->E5_DATA
nCorrec		:= SE5->E5_VLCORRE
nDescont	:= SE5->E5_VLDESCO
nMulta		:= SE5->E5_VLMULTA
nJuros		:= SE5->E5_VLJUROS
nValRec		:= SE5->E5_VALOR
nValorM2 	:= SE5->E5_VLMOED2

nI 			:=  Ascan(aMotBx, {|x| Substr(x,1,3) == Upper(cMot070) })
cDescrMo 	:= if( nI > 0,Substr(aMotBx[nI],07,10),"" )

// Carrega nome do cliente
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)

cNomeCli    := SE1->E1_CLIENTE + " - " + Subst(SA1->A1_NOME,1,40)

nOpca := 0
DEFINE MSDIALOG oDlg FROM  69,33 TO 387,581 TITLE OemToAnsi(STR0028) PIXEL OF oMainWnd //"Baixa a Receber"
@ 001, 002 TO 036, 272 LABEL OemToAnsi(STR0003) OF oDlg  PIXEL //"Principal"
@ 038, 002 TO 155, 133 LABEL OemToAnsi(STR0001) OF oDlg  PIXEL //"Dados Gerais"
@ 038, 139 TO 155, 272 LABEL OemToAnsi(STR0002) OF oDlg  PIXEL //"Valores da Baixa"

@ 011, 007 SAY OemToAnsi(STR0004)		SIZE 18, 07 OF oDlg PIXEL //"T¡tulo"
@ 010, 027 MSGET oTitulo VAR cTitulo	F3 "SE1RDO"		SIZE 57, 10 OF oDlg PIXEL READONLY
oTitulo:cSx1Hlp := "CTITULO"
@ 011, 091 SAY OemToAnsi(STR0005)		SIZE 31, 07 OF oDlg PIXEL //"Emiss„o"
@ 010, 124 MSGET oEmissao VAR SE1->E1_EMISSAO		SIZE 35, 10 OF oDlg PIXEL When .F.
oEmissao:cSx1Hlp := "E1_EMISSAO"
@ 011, 166 SAY OemToAnsi(STR0006)		SIZE 39, 07 OF oDlg PIXEL //"Vencto.Atual"
@ 010, 207 MSGET oVencRea VAR SE1->E1_VENCREA		SIZE 31, 10 OF oDlg PIXEL When .F.
oVencRea:cSx1Hlp := "E1_VENCREA"
@ 024, 004 SAY OemToAnsi(STR0029)		SIZE 22, 07 OF oDlg PIXEL //"Cliente"
@ 022, 027 MSGET oNomeCli VAR cNomeCli	F3	"SA1"		SIZE 211,09 OF oDlg PIXEL READONLY
oNomeCli:cSX1Hlp := "A1_NOME"
@ 047, 005 SAY OemToAnsi(STR0008)		SIZE 39, 07 OF oDlg PIXEL //"Hist.Emiss„o"
@ 045, 046 MSGET oHist VAR SE1->E1_HIST			SIZE 79, 10 OF oDlg PIXEL When .F.
oHist:cSx1Hlp := "E1_HIST"
@ 058, 005 SAY OemToAnsi(STR0030)		SIZE 35, 07 OF oDlg PIXEL //"Situa‡„o"
@ 057, 046 MSGET oSituaca VAR cSituacao				SIZE 66, 10 OF oDlg PIXEL When .F.
oSituaca:cSx1Hlp := "E1_SITUACA"
@ 070, 005 SAY OemToAnsi(STR0017)		SIZE 32, 07 OF oDlg PIXEL //"Mot.Baixa"
@ 069, 046 MSGET oDescmo VAR cDescrMo	SIZE 83, 10 OF oDlg PIXEL When .F.
oDescmo:cSX1Hlp := "CDESCRMOT"
@ 082, 005 SAY OemToAnsi(STR0010)		SIZE 32, 07 OF oDlg PIXEL //"Banco"
@ 082, 046 MSGET oBanco VAR cBanco					SIZE 22, 10 OF oDlg PIXEL When .F.
oBanco:cSx1Hlp := "E5_BANCO"
@ 095, 005 SAY OemToAnsi(STR0011)		SIZE 32, 07 OF oDlg PIXEL //"Agˆncia"
@ 094, 046 MSGET oAgencia VAR cAgencia				SIZE 35, 10 OF oDlg PIXEL When .F.
oAgencia:cSx1Hlp := "E5_AGENCIA"
@ 108, 005 SAY OemToAnsi(STR0012)		SIZE 28, 07 OF oDlg PIXEL //"Conta"
@ 106, 046 MSGET oConta  VAR cConta		F3 "SA6"		SIZE 66, 10 OF oDlg PIXEL READONLY
oConta:cSx1Hlp := "E5_CONTA"
@ 120, 005 SAY OemToAnsi(STR0013)		SIZE 39, 07 OF oDlg PIXEL //"Data Receb."
@ 118, 046 MSGET oBaixa VAR dBaixa					SIZE 39, 10 OF oDlg PIXEL When .F.
oBaixa:cSx1Hlp := "E5_DATA"
@ 133, 005 SAY OemToAnsi(STR0014)		SIZE 32, 07 OF oDlg PIXEL //"Hist.Baixa"
@ 131, 046 MSGET oHistBX VAR cHist070				SIZE 83, 10 OF oDlg PIXEL When .F.
oHistBX:cSx1Hlp := "E5_HISTOR"
@ 047, 144 SAY OemToAnsi(STR0018) + cDescMoeda SIZE 53, 10 OF oDlg PIXEL //"Valor Original "
@ 044, 204 MSGET oValor VAR SE1->E1_VALOR			SIZE 66, 10 OF oDlg PIXEL When .F.    Picture PesqPict("SE1","E1_VALOR") //"@E 999,999,999,999.99"
oValor:cSx1Hlp := "E1_VALOR"
@ 059, 144 SAY OemToAnsi(STR0019)		SIZE 53, 07 OF oDlg PIXEL //"- Abatimentos"
@ 056, 204 MSGET oTotAbat VAR nTotAbat				SIZE 66, 10 OF oDlg PIXEL When .F.    Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"
oTotAbat:cSx1Hlp := "FINTOTABAT"
@ 071, 144 SAY OemToAnsi(STR0020)		SIZE 53, 07 OF oDlg PIXEL //"- Pagtos Parciais"
@ 069, 204 MSGET oValorM1 VAR nValorM1				SIZE 66, 10 OF oDlg PIXEL When .F.    PicTure PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"
oValorM1:cSx1Hlp := "FINPAGPARC"
@ 082, 144 SAY OemToAnsi(STR0021)		SIZE 53, 07 OF oDlg PIXEL //"- Descontos"
@ 081, 204 MSGET oDescont VAR nDescont				SIZE 66, 10 OF oDlg PIXEL When .F.    Picture PesqPict( "SE1","E1_DESCONT" )  //"@E 999,999,999,999.99"
oDescont:cSx1Hlp := "E1_DESCONT"
@ 094, 144 SAY OemToAnsi(STR0022)		SIZE 53, 07 OF oDlg PIXEL //"+ Multa"
@ 093, 204 MSGET oMulta VAR nMulta					SIZE 66, 10 OF oDlg PIXEL When .F.    Picture PesqPict( "SE1","E1_MULTA" )  //"@E 999,999,999,999.99"
oMulta:cSx1Hlp := "E1_MULTA"
@ 106, 144 SAY OemToAnsi(STR0023)		SIZE 53, 07 OF oDlg PIXEL //"+ Tx.Permanenc."
@ 105, 204 MSGET oJuros VAR nJuros					SIZE 66, 10 OF oDlg PIXEL When .F.    Picture PesqPict( "SE1","E1_JUROS" )  //"@E 999,999,999,999.99"
oJuros:cSx1Hlp := "E1_JUROS"
@ 119, 144 SAY OemToAnsi(STR0031)		SIZE 53, 7 OF oDlg PIXEL //"= Valor Recebido"
@ 118, 204 MSGET oValRec VAR nValRec				SIZE 66,10 OF oDlg PIXEL  When .F.   Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"
oValRec:cSx1Hlp := "E1_VALOR"
If SE1->E1_MOEDA > 1
	@ 131, 144 SAY OemToAnsi(STR0025) + SubStr(GetMV("MV_SIMB"+cMoeda),1,3) SIZE 53,07 OF oDlg PIXEL //"Valor "
	@ 130, 204 MSGET  oValorM2 VAR nValorM2			SIZE 66,10 OF oDlg PIXEL  When .F. Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"
	oValorM2:cSx1Hlp := "VALMOEDAES"
	@ 144, 144 SAY OemToAnsi(STR0026)	SIZE 53,07 OF oDlg PIXEL //"+ Corr.Monet ria"
	@ 142, 204 MSGET  oCorrec VAR nCorrec 			SIZE 66,10 OF oDlg PIXEL  When .F.   Picture PesqPict( "SE1","E1_CORREC" )  //"@E 999,999,999,999.99"
	oCorrec:cSx1Hlp := "E1_CORREC"
EndIf

DEFINE SBUTTON FROM 07, 241 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1,oDlg:End())
DEFINE SBUTTON FROM 20, 241 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
	
ACTIVATE MSDIALOG oDlg

RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBComppg³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 18.03.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Compensacao a Pagar                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBCompPg                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbCompPg()

Local aSaveArea  := GetArea()
Local aTitulos   := {}
Local cPrefixo
Local cNum
Local cParcela
Local cTipoTit
Local cFornece
Local cLoja
Local cVarQ      := "  "
Local cDocument  := ""
Local cSeqSE5    := ""
Local bSE2DbSeek := { || }
Local bAddTitulo := { || }

Local nTamTit 	:= TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]
Local nTamTip	:= TamSX3("E2_TIPO")[1]

Local oDlg
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oTitulo
Local nTamChv	:= Len(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA))
***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao	: 597
* Chave Busca	: E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA
* Ordem Busca	: 2
* Descricao  	: Compensacao a Pagar
* Rot Executar	: CTBCOMPPG()
* Alias Arq		: SE5
***********************************************************************
//OBS: A construcao desta consulta, deve se basear no registro do SE5 -> Chave 2 do SE5

// Carrega variaveis referentes aos dados do titulo -> SE2

bSE2DbSeek := {||SE2->(dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO;
				+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA))}
bAddTitulo := {||Aadd(aTitulos,{SE5->E5_PREFIXO, SE5->E5_NUMERO    , SE5->E5_PARCELA,;
 				SE5->E5_TIPO   , DtoC(SE5->E5_DATA),;
				SubStr(SE5->E5_DOCUMEN,1,nTamTit+nTamTip),;
				SE5->E5_SEQ, Transform(SE2->E2_VALOR,"@E 9999,999,999.99"),;
				Transform(SE5->E5_VLMOED2,"@E 9999,999,999.99"),.T.,"SE2",SE2->(Recno())})}
				
dbSelectArea("SE2")
dbSetOrder(1)
Eval(bSE2DbSeek)
	
cPrefixo	:= SE2->E2_PREFIXO
cNum		:= SE2->E2_NUM
cParcela	:= SE2->E2_PARCELA
cTipoTit	:= SE2->E2_TIPO
cFornece	:= SE2->E2_FORNECE
cLoja		:= SE2->E2_LOJA
cSeqSE5	:= SE5->E5_SEQ
cDocument	:= SE5->E5_DOCUMEN

Eval(bAddTitulo) 

SE5->(dbSetOrder(7))

If SE5->(DbSeek(xFilial("SE5")+PadR(cDocument, nTamChv )+cSeqSE5))
	While !SE5->(Eof()) .And. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ);
		== PadR(cDocument, nTamChv ) + cSeqSE5
		
		If Eval(bSE2DbSeek)
			Eval(bAddTitulo)
		EndIf

		SE5->(dbSkip())
	EndDo
EndIf
	
DEFINE MSDIALOG oDlg FROM	88,31 TO 300,560 TITLE OemToAnsi(STR0032) PIXEL  //"Compensacao de Titulos a Pagar"

// Monta Informacoes com o Titulo Principal
@ 14, 006 MSGET oPrefixo VAR cPrefixo	When .F. SIZE 19, 10 OF oDlg PIXEL
oPrefixo:cSx1hlp := "E2_PREFIXO"
@ 14, 033 MSGET oNum	 VAR cNum     	When .F. SIZE 39, 10 OF oDlg PIXEL
oNum:cSx1hlp := "E2_NUM"
@ 14, 075 MSGET oParcela VAR cParcela	When .F. SIZE 20, 10 OF oDlg PIXEL
oParcela:cSx1hlp := "E2_PARCELA"
@ 14, 101 MSGET oTipoTit VAR cTipoTit 	F3 "SE2RDO" READONLY SIZE 16, 10 OF oDlg PIXEL
oTipoTit:cSx1hlp := "E2_TIPO"
@ 14, 128 MSGET oFornece VAR cFornece	When .F. SIZE 70, 10 OF oDlg PIXEL
oFornece:cSx1hlp := "E2_FORNECE"
@ 14, 199 MSGET oLoja	 VAR cLoja		F3 "SA2" READONLY SIZE 16, 10 OF oDlg PIXEL
oLoja:cSx1hlp := "E2_LOJA"

@ 06, 006 SAY OemToAnsi(STR0033)    SIZE 21, 7 OF oDlg PIXEL  //"Prefixo"
@ 06, 033 SAY OemToAnsi(STR0034)    SIZE 22, 7 OF oDlg PIXEL  //"Numero"
@ 05, 075 SAY OemToAnsi(STR0035)    SIZE 23, 7 OF oDlg PIXEL  //"Parcela"
@ 05, 101 SAY OemToAnsi(STR0036)    SIZE 14, 7 OF oDlg PIXEL  //"Tipo"
@ 05, 128 SAY OemToAnsi(STR0042)    SIZE 34, 7 OF oDlg PIXEL  //"Fornecedor"
@ 05, 199 SAY OemToAnsi(STR0043)    SIZE 14, 7 OF oDlg PIXEL  //"Loja"

@ 3.0,.9 LISTBOX oTitulo VAR cVarQ Fields;
	HEADER "", OemToAnsi(STR0033),;  	//"Prefixo"
	OemToAnsi(STR0034),;  				//"Numero"
	OemToAnsi(STR0035),;  				//"Parcela"
	OemToAnsi(STR0036),;  				//"Tipo"
	OemToAnsi(STR0037),;  				//"Data"
	OemToAnsi(STR0038),;  				//"Documento"
	OemToAnsi(STR0039),;  				//"Seq"
	OemToAnsi(STR0040),;  				//"Valor do titulo"
	OemToAnsi(STR0041) ;   				//"Valor compensado"
	COLSIZES 12, GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBBBBBBBBB"),;
	GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBB"),;
	GetTextWidth(0,"BBBBBB"),GetTextWidth(0,"BBBBBBBBBB"),;
	GetTextWidth(0,"BBB"),GetTextWidth(0,"BBBBBBBBBB"),;
	GetTextWidth(0,"BBBBBBBBBB");
	SIZE 250,54.5 NOSCROLL

	oTitulo:SetArray(aTitulos)
	oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,10],oOk,oNo),;
		aTitulos[oTitulo:nAt,1],aTitulos[oTitulo:nAt,2],;
		aTitulos[oTitulo:nAt,3],aTitulos[oTitulo:nAt,4],;
		aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
		aTitulos[oTitulo:nAt,7],aTitulos[oTitulo:nAt,8],;
		aTitulos[oTitulo:nAt,9]}}
		
	oTitulo:bLDblClick := {||SE2->(MsGoTo(aTitulos[oTitulo:nAt,12])),AxVisual(aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,12],2)}

ACTIVATE MSDIALOG oDlg  CENTERED

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBCompRc³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 18.03.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Compensacao a Receber                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBCompRc                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbCompRc()

Local aSaveArea  := GetArea()
Local aTitulos   := {}
Local cPrefixo
Local cNum
Local cParcela
Local cTipoTit
Local cFornece
Local cLoja
Local cVarQ      := "  "
Local cDocument  := ""
Local cSeqSE5    := ""
Local bSE1DbSeek := { || }
Local bAddTitulo := { || }

Local nTamTit 	:= TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]
Local nTamTip	:= TamSX3("E1_TIPO")[1]

Local oDlg
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oTitulo

***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao	: 596
* Chave Busca	: E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA
* Ordem Busca	: 2
* Descricao  	: Compensacao a Receber
* Rot Executar	: CTBCOMPRC()
* Alias Arq		: SE5
***********************************************************************
//OBS: A construcao desta consulta, deve se basear no registro do SE5 -> Chave 2 do SE5

bSE1DbSeek := {||SE1->(dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO;
				+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA))}
bAddTitulo := {||Aadd(aTitulos,{SE5->E5_PREFIXO, SE5->E5_NUMERO    , SE5->E5_PARCELA,;
 				SE5->E5_TIPO   , DtoC(SE5->E5_DATA),;
				SubStr(SE5->E5_DOCUMEN,1,nTamTit+nTamTip),;
				SE5->E5_SEQ, Transform(SE1->E1_VALOR,"@E 9999,999,999.99"),;
				Transform(SE5->E5_VLMOED2,"@E 9999,999,999.99"),.T.,"SE1",SE1->(Recno())})}

// Carrega variaveis referentes aos dados do titulo -> SE1
dbSelectArea("SE1")
dbSetOrder(1)
Eval(bSE1DbSeek)
	
cPrefixo	:= SE1->E1_PREFIXO
cNum		:= SE1->E1_NUM
cParcela	:= SE1->E1_PARCELA
cTipoTit	:= SE1->E1_TIPO
cFornece	:= SE1->E1_CLIENTE
cLoja		:= SE1->E1_LOJA
cSeqSE5	:= SE5->E5_SEQ
cDocument	:= SE5->E5_DOCUMEN

Eval(bAddTitulo)

SE5->(dbSetOrder(7))

If SE5->(DbSeek(xFilial("SE5")+Trim(cDocument)+cSeqSE5))
	While !SE5->(Eof()) .And. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ);
		== Trim( cDocument ) + cSeqSE5
		
		If Eval(bSE1DbSeek)
			Eval(bAddTitulo)
		EndIf

		SE5->(dbSkip())
	EndDo
EndIf
	
DEFINE MSDIALOG oDlg FROM	88,31 TO 300,560 TITLE OemToAnsi(STR0044) PIXEL  //"Compensacao de Titulos a Receber"

// Monta Informacoes com o Titulo Principal
@ 14, 006 MSGET oPrefixo VAR cPrefixo	When .F. SIZE 19, 10 OF oDlg PIXEL
oPrefixo:cSX1Hlp := "E1_PREFIXO"
@ 14, 033 MSGET oNum	 VAR cNum     	When .F. SIZE 39, 10 OF oDlg PIXEL
oNum:cSX1Hlp := "E1_NUM"
@ 14, 075 MSGET oParcela VAR cParcela	When .F. SIZE 20, 10 OF oDlg PIXEL
oParcela:cSX1Hlp := "E1_PARCELA"
@ 14, 101 MSGET oTipoTit VAR cTipoTit 	F3 "SE1RDO" READONLY SIZE 16, 10 OF oDlg PIXEL
oTipoTit:cSX1Hlp := "E1_TIPO"
@ 14, 128 MSGET oFornece VAR cFornece	When .F. SIZE 70, 10 OF oDlg PIXEL
oFornece:cSX1Hlp := "E1_FORNECE"
@ 14, 199 MSGET oLoja	 VAR cLoja		F3 "SA1" READONLY SIZE 16, 10 OF oDlg PIXEL
oLoja:cSX1Hlp := "E1_LOJA"
@ 06, 006 SAY OemToAnsi(STR0033)    SIZE 21, 7 OF oDlg PIXEL  //"Prefixo"
@ 06, 033 SAY OemToAnsi(STR0034)    SIZE 22, 7 OF oDlg PIXEL  //"Numero"
@ 05, 075 SAY OemToAnsi(STR0035)    SIZE 23, 7 OF oDlg PIXEL  //"Parcela"
@ 05, 101 SAY OemToAnsi(STR0036)    SIZE 14, 7 OF oDlg PIXEL  //"Tipo"
@ 05, 128 SAY OemToAnsi(STR0029)    SIZE 34, 7 OF oDlg PIXEL  //"Cliente"
@ 05, 199 SAY OemToAnsi(STR0043)    SIZE 14, 7 OF oDlg PIXEL  //"Loja"

@ 3.0,.9 LISTBOX oTitulo VAR cVarQ Fields;
	HEADER "", OemToAnsi(STR0033),;  	//"Prefixo"
	OemToAnsi(STR0034),;  				//"Numero"
	OemToAnsi(STR0035),;  				//"Parcela"
	OemToAnsi(STR0036),;  				//"Tipo"
	OemToAnsi(STR0037),;  				//"Data"
	OemToAnsi(STR0038),;  				//"Documento"
	OemToAnsi(STR0039),;  				//"Seq"
	OemToAnsi(STR0040),;  				//"Valor do titulo"
	OemToAnsi(STR0041) ;   				//"Valor compensado"
	COLSIZES 12, GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBBBBBBBBB"),;
	GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBB"),;
	GetTextWidth(0,"BBBBBB"),GetTextWidth(0,"BBBBBBBBBB"),;
	GetTextWidth(0,"BBB"),GetTextWidth(0,"BBBBBBBBBB"),;
	GetTextWidth(0,"BBBBBBBBBB");
	SIZE 250,54.5 NOSCROLL

	oTitulo:SetArray(aTitulos)
	oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,10],oOk,oNo),;
		aTitulos[oTitulo:nAt,1],aTitulos[oTitulo:nAt,2],;
		aTitulos[oTitulo:nAt,3],aTitulos[oTitulo:nAt,4],;
		aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
		aTitulos[oTitulo:nAt,7],aTitulos[oTitulo:nAt,8],;
		aTitulos[oTitulo:nAt,9]}}

	oTitulo:bLDblClick := {||SE1->(MsGoTo(aTitulos[oTitulo:nAt,12])),AxVisual(aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,12],2)}

ACTIVATE MSDIALOG oDlg  CENTERED

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBFatPg³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 18.03.01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Faturas a Pagar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBFatPg                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbFatPg()

Local aSaveArea := GetArea()

Local cFiltro
Local cFornecedor
Local cLoja
Local cFatura
Local cPrefixo
Local cTipo
Local cIndex
Local cChave

Local nValor	:= 0
Local nTitulos	:= 0
Local nIndex

***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao	: 587
* Chave Busca	: E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
* Ordem Busca	: 1
* Descricao  	: Faturas a Pagar
* Rot Executar	: CTBFatPg()
* Alias Arq		: SE2
***********************************************************************

// Carrega variaveis referentes aos dados do titulo -> SE2
cFornecedor	:= SE2->E2_FORNECE
cLoja	 	:= SE2->E2_LOJA
cFatura		:= SE2->E2_NUM
cPrefixo 	:= SE2->E2_PREFIXO
cTipo		:= SE2->E2_TIPO

// Cria indice para buscar informacoes da Fatura
dbSelectArea("SE2")
dbSetOrder( 6 )
cIndex	:= CriaTrab(nil,.f.)
cChave	:= IndexKey()
cFiltro := 'E2_FILIAL=="'  	+cFilial 	+ '".And.'
cFiltro += 'E2_FORNECE=="' 	+cFornecedor+ '".And.'
cFiltro += 'E2_FATURA=="'	+cFatura	+ '".And.'
cFiltro += 'E2_TIPOFAT=="'	+cTipo		+ '"'

IndRegua("SE2",cIndex,cChave,,cFiltro,OemToAnsi(STR0048))  //"Selecionando Registros..."

nIndex := RetIndex("SE2")
dbSelectArea("SE2")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()
If BOF() .and. EOF()
	dbSelectArea("SE2")
	Set Filter to
	dbSetOrder(1)
	RetIndex("SE2")
	Set Filter to
	dbGoTop()
	FErase(cIndex+OrdBagExt())
	dbSetOrder(1)
	Return
Endif

dbSelectArea("SE2")
While !Eof()
	If SE2->E2_TIPO $ MV_CPNEG+"/"+MVABATIM
		nValor -= IIF(E2_SALDO == 0 , E2_VALLIQ, 0)
	Else
		nValor += IIF(E2_SALDO == 0 , E2_VALLIQ, 0)
	Endif
	nTitulos+= IIF(!Empty(E2_TIPOFAT), 1, 0)
	dbSkip()
Enddo

// Monta tela da Fatura
DEFINE MSDIALOG oDlg FROM	15,6 TO 243,345 TITLE OemToAnsi(STR0045) PIXEL // "Faturas a Pagar"
@ 39, 11 TO 068, 126 OF oDlg	PIXEL
@ 72, 11 TO 104, 126 OF oDlg	PIXEL
@ 07, 11 TO 036, 126 OF oDlg	PIXEL
@ 22, 14 MSGET oFornece VAR cFornecedor 	F3 "SA2" READONLY SIZE 70, 08 OF oDlg PIXEL
oFornece:cSX1Hlp := "A2_FORNECE"
@ 22, 87 MSGET oLoja	VAR cLoja		When .F. SIZE 20, 08 OF oDlg PIXEL
oLoja:cSx1Hlp := "E2_LOJA"
@ 54, 14 MSGET oPrefixo VAR cPrefixo	When .F. SIZE 21, 08 OF oDlg PIXEL
oPrefixo:cSx1Hlp := "E2_PREFIXO"
@ 54, 40 MSGET oTipo	VAR cTipo		When .F. SIZE 12, 08 OF oDlg PIXEL 
oTipo:cSx1Hlp := "E2_TIPO"
@ 54, 67 MSGET oFatura	VAR cFatura		F3 "SE2RDO" READONLY SIZE 49, 08 OF oDlg PIXEL
oFatura:cSx1Hlp := "E2_FATURA"
@ 88, 14 MSGET oTitulos VAR nTitulos	When .F. SIZE 28, 08 OF oDlg PIXEL
oTitulos:cSx1Hlp := "NTITFAT"
@ 88, 53 MSGET oValor	VAR nValor		When .F. SIZE 63, 08 OF oDlg PIXEL
oValor:cSx1Hlp := "E2_VALOR"
@ 12, 14 SAY OemToAnsi(STR0042) SIZE 70, 7 OF oDlg PIXEL //"Fornecedor"
@ 12, 87 SAY OemToAnsi(STR0043) SIZE 20, 7 OF oDlg PIXEL //"Loja"
@ 44, 14 SAY OemToAnsi(STR0033) SIZE 21, 7 OF oDlg PIXEL //"Prefixo"
@ 44, 40 SAY OemToAnsi(STR0036) SIZE 12, 7 OF oDlg PIXEL //"Tipo"
@ 44, 67 SAY OemToAnsi(STR0034) SIZE 49, 7 OF oDlg PIXEL //"Numero Titulo"
@ 78, 14 SAY OemToAnsi(STR0046) SIZE 35, 7 OF oDlg PIXEL //"Total Notas"
@ 78, 53 SAY OemToAnsi(STR0047) SIZE 53, 7 OF oDlg PIXEL //"Valor da Fatura"

DEFINE SBUTTON FROM 10, 133 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 23, 133 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

dbSelectArea("SE2")
Set Filter to
RetIndex("SE2")
If	!Empty(cIndex)
	fErase(cIndex+OrdBagExt())
	cIndex := ""
Endif

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBFatRc³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 18.03.01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Faturas a Receber                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBFatRc                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbFatRc()

Local aSaveArea := GetArea()

Local cFiltro
Local cFatura
Local cPrefixo
Local cTipo
Local cIndex
Local cChave

Local nValor	:= 0
Local nTitulos	:= 0
Local nIndex

***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao	: 595
* Chave Busca	: E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
* Ordem Busca	: 1
* Descricao  	: Faturas a Receber
* Rot Executar	: CTBFatRc()
* Alias Arq		: SE1
***********************************************************************

// Carrega variaveis referentes aos dados do titulo -> SE1
cFatura		:= SE1->E1_NUM
cPrefixo 	:= SE1->E1_PREFIXO
cTipo		:= SE1->E1_TIPO

// Cria indice para buscar informacoes da Fatura
cIndex	:= CriaTrab(nil,.f.)
cChave	:= IndexKey()
cFiltro := 'E1_FILIAL=="'  	+cFilial + '".And.'
cFiltro += 'E1_FATURA=="'	+cFatura + '".And.'
cFiltro += 'E1_TIPOFAT=="'	+cTipo	 + '"'

IndRegua("SE1",cIndex,cChave,,cFiltro,OemToAnsi(STR0048))  //"Selecionando Registros..."

nIndex := RetIndex("SE1")
dbSelectArea("SE1")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()
If BOF() .and. EOF()
	dbSelectArea("SE1")
	Set Filter to
	dbSetOrder(1)
	RetIndex("SE1")
	Set Filter to
	dbGoTop()
	FErase(cIndex+OrdBagExt())
	dbSetOrder(1)
	Return
Endif

dbSelectArea("SE1")
While !Eof()
	If SE1->E1_TIPO $ MV_CRNEG+"/"+MVABATIM
		nValor -= IIF(E1_SALDO == 0 , E1_VALLIQ, 0)
	Else
		nValor += IIF(E1_SALDO == 0 , E1_VALLIQ, 0)
	Endif
	nTitulos+= IIF(!Empty(E1_TIPOFAT), 1, 0)
	dbSkip()
Enddo

// Monta tela da Fatura
DEFINE MSDIALOG oDlg FROM	20,1 TO 181,340 TITLE OemToAnsi(STR0049) PIXEL //"Faturas a Receber"

@ 06, 11 TO 34, 126 OF oDlg PIXEL
@ 39, 11 TO 70, 126 OF oDlg PIXEL
@ 21, 14 MSGET oPrefixo	VAR cPrefixo	When .F. SIZE 21, 08 OF oDlg PIXEL
oPrefixo:cSx1hlp := "E1_PREFIXO"
@ 21, 40 MSGET oTipo	VAR cTipo	When .F. SIZE 12, 08 OF oDlg PIXEL
oTipo:cSx1hlp := "E1_TIPO"
@ 21, 67 MSGET oFatura	VAR cFatura 	F3 "SE1RDO" READONLY SIZE 49, 08 OF oDlg PIXEL
oFatura:cSx1hlp := "E1_FATURA"
@ 56, 14 MSGET oTitulos	VAR nTitulos When .F. SIZE 28, 08 OF oDlg PIXEL
oTitulos:cSx1hlp := "NTITFAT"
@ 56, 53 MSGET oValor	VAR nValor	When .F. SIZE 63, 08 OF oDlg PIXEL
oValor:cSx1hlp := "E1_VALOR"
@ 11, 14 SAY OemToAnsi(STR0033) SIZE 21, 07 OF oDlg PIXEL //"Prefixo"
@ 11, 40 SAY OemToAnsi(STR0036) SIZE 12, 07 OF oDlg PIXEL //"Tipo"
@ 11, 67 SAY OemToAnsi(STR0034) SIZE 49, 07 OF oDlg PIXEL //"NUmero"
@ 46, 14 SAY OemToAnsi(STR0046) SIZE 35, 07 OF oDlg PIXEL //"Total Notas"
@ 46, 53 SAY OemToAnsi(STR0047) SIZE 53, 07 OF oDlg PIXEL //"Valor da Fatura"

DEFINE SBUTTON FROM 10, 133 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 23, 133 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

dbSelectArea("SE1")
Set Filter to
RetIndex("SE1")
If	!Empty(cIndex)
	fErase(cIndex+OrdBagExt())
	cIndex := ""
Endif

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBTransf³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 20.03.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Transferencia Contas a Receber                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBTransf                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbTransf()

Local aSaveArea := GetArea()
Local aSituacoes:= {}
Local cPort060
Local cAgen060
Local cConta060
Local cSituacao
Local cContrato
Local cNumBco
Local cCapital
Local cComboSit
Local cCliente
Local cTitulo
Local cPortador

Local nValor
                            
***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao	: 540/541/542/543/544/545/546/555
* Chave Busca	: E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
* Ordem Busca	: 1
* Descricao  	: Faturas a Receber
* Rot Executar	: CTBFatRc()
* Alias Arq		: SE1
***********************************************************************

cPort060 	:= SE1->E1_PORTADO
cAgen060 	:= SE1->E1_AGEDEP
cConta060	:= SE1->E1_CONTA
cSituacao	:= SE1->E1_SITUACA
cContrato	:= SE1->E1_CONTRAT
cNumBco		:= SE1->E1_NUMBCO
cTitulo		:= SE1->E1_PREFIXO + " "+ SE1->E1_NUM 	 + " "+ SE1->E1_PARCELA

// Monta ComboBox para exibir na tela
dbSelectArea("SX5")
dbSeek(cFilial+"07")
While SX5->X5_FILIAL+SX5->X5_tabela == cFilial+"07"
	cCapital := Capital(X5Descri())
	AADD( aSituacoes,;
		SubStr(SX5->X5_CHAVE,1,2)+;
		OemToAnsi(SubStr(cCapital,1,20)))
	dbSkip()
EndDo

nElemento	:= Val(SE1->E1_SITUACA)+1
cComboSit	:= aSituacoes[nElemento]

// Procura no Cadastro de Clientes informacoes
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
cCliente 	:= Substr( SE1->E1_CLIENTE+" "+ SE1->E1_LOJA	+" "+ SA1->A1_NOME,1,50)

// Procura no Cadastro de Bancos informacoes
dbSelectArea("SA6")
dbSetOrder(1)
If SE1->E1_SITUACA != "0"
	SA6->( dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP) )
Else
	SA6->( dbSeek(xFilial("SA6")))
EndIf

cPortador	:= SE1->E1_PORTADO + " " + SE1->E1_AGEDEP + " "+ SE1->E1_CONTA+ " "+IIf(SE1->E1_SITUACA!="0",Subs(SA6->A6_NOME,1,25),"")
nValor		:= SE1->E1_SALDO
                                                
DEFINE MSDIALOG oDlg FROM	15,6 TO 271,597 TITLE OemToAnsi(STR0050) PIXEL
@ 00,001 TO  60, 294 LABEL OemToAnsi(STR0051) 	OF oDlg PIXEL  // "Posicao Atual"
@ 64,001 TO 106, 294 LABEL OemToAnsi(STR0052) 	OF oDlg PIXEL  // "Transferir para"
@ 11,013 SAY	OemToAnsi(STR0029)	SIZE 021,07	OF oDlg PIXEL  // "Cliente"
@ 09,042 MSGET oCliente VAR cCliente F3 "SA1"	SIZE 149,10	OF oDlg PIXEL READONLY
oCliente:cSx1Hlp := "A1_CLIENTE"
@ 11,197 SAY	OemToAnsi(STR0004)	SIZE 021,07	OF oDlg PIXEL  // "Titulo"
@ 09,230 MSGET oTitulo	VAR cTitulo	F3 "SE1RDO"	SIZE 054,10	OF oDlg PIXEL READONLY
oTitulo:cSx1Hlp := "CTITULO"
@ 29,013 SAY	OemToAnsi(STR0030)	SIZE 026,07	OF oDlg PIXEL  // "Situacao"
@ 26,042 MSGET oSituaca VAR cSituacao			SIZE 149,10 OF oDlg PIXEL WHEN .F.
oSituaca:cSx1Hlp := "E1_SITUACA"
@ 29,197 SAY	OemToAnsi(STR0053)	SIZE 025,07 OF oDlg PIXEL  // "Contrato"
@ 27,230 MSGET oContrato VAR cContrato			SIZE 054,10 OF oDlg PIXEL WHEN .F.
@ 46,014 SAY	OemToAnsi(STR0054)	SIZE 025,07 OF oDlg PIXEL  // "Portador"               
@ 44,043 MSGET 	oPortador VAR cPortador			SIZE 149,10 OF oDlg PIXEL WHEN .F.
@ 75,013 SAY	OemToAnsi(STR0054)	SIZE 026,07 OF oDlg PIXEL  // "Portador"
@ 73,042 MSGET  oPort060 VAR cPort060 F3 "SA6"  SIZE 025,10 OF oDlg PIXEL READONLY
@ 75,078 SAY	OemToAnsi(STR0011)	SIZE 026,07 OF oDlg PIXEL  // "Agencia"
@ 73,102 MSGET 	oAgen060 VAR cAgen060			SIZE 035,10 OF oDlg PIXEL WHEN .F.
@ 75,145 SAY	OemToAnsi(STR0012)	SIZE 026,07 OF oDlg PIXEL  //"Conta"
@ 73,165 MSGET  oConta060 VAR cConta060	F3 "SA6"	SIZE 050,10 OF oDlg PIXEL READONLY
@ 93,013 SAY OemToAnsi(STR0030)		SIZE 026,07 OF oDlg PIXEL  // "Situacao"
@ 91,042 MSGET oComboSit VAR cComboSit 			SIZE 060,10 OF oDlg PIXEL WHEN .F.
oComboSit:cSx1Hlp := "CSITUACAO"
@ 93,130 SAY OemToAnsi(STR0053) 	SIZE 025,07 OF oDlg PIXEL  // "Contrato"
@ 91,157 MSGET oContrato VAR cContrato			SIZE 045,10 OF oDlg PIXEL WHEN .F.
oContrato:cSx1Hlp := "E1_CONTRAT"
@ 93,207 SAY OemToAnsi(STR0055)		SIZE 042,07 OF oDlg PIXEL  // "No. Portador"
@ 91,243 MSGET oNumBco VAR cNumBco 				SIZE 041,10 OF oDlg PIXEL WHEN .F.
oNumBco:cSx1Hlp := "E1_PORTADO"                                 

DEFINE SBUTTON FROM 112, 237 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 112, 265 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBRecibo ³ Autor ³ Fernando Machima      ³ Data ³ 05.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Recibo(Localizacoes)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBRecibo                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbRecibo()

***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao: 575
* Chave Busca: EL_FILIAL+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
* Ordem Busca: 1
* Descricao : Baixas a Receber(Localizacoes)
* Rot Executar: CTBRECIBO()
* Alias Arq: SEL
***********************************************************************

Finr087()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbOrdPago³ Autor ³ Fernando Machima      ³ Data ³ 05.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Ordem de Pago(Localizacoes)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbOrdPago                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbOrdPago()

***********************************************************************
* Como montar o Relacionamento -> CTL
* ----------------------------
* Lcto Padrao: 570
* Chave Busca: EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO
* Ordem Busca: 1
* Descricao : Baixas a Pagar(Localizacoes)
* Rot Executar: CTBORDPAGO()
* Alias Arq: SEK
***********************************************************************

Finr085A()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbDocSaid³ Autor ³ Fernando Machima      ³ Data ³ 05.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Documentos de Saida(NF, NCP e NDC)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbDocSaida()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbDocSaida()

Local nTipo  := 1
Local aPergs := {}

Private aCfgNF      := {}

***********************************************************************
* Como montar o Relacionamento -> CTL - Documentos de Saida
* ----------------------------
* Lcto Padrao: 610(Itens)/620(Total)
* Chave Busca: F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
* Ordem Busca: 2
* Descricao : Documentos de Saida(Nota Fiscal, NCP e NDC)
* Rot Executar: CtbDocSaida()
* Alias Arq: SF2
***********************************************************************

nTipo   := Val(SF2->F2_TIPODOC)
aCfgNF  := MontaCfgNf(nTipo,aPergs,.T.)
LocxDlgNF(aCfgNF,2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbDocEnt ³ Autor ³ Fernando Machima      ³ Data ³ 05.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Documentos de Entrada(NF, NCC e NDP)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbDocEnt()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbDocEnt()

Local nTipo  := 1
Local aPergs := {}

Private aCfgNF      := {}

***********************************************************************
* Como montar o Relacionamento -> CTL - Documentos de Entrada
* ----------------------------
* Lcto Padrao: 650(Itens)/660(Total)
* Chave Busca: F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO+F1_ESPECIE
* Ordem Busca: 1
* Descricao : Documentos de Entrada(Nota Fiscal, NDP, NCC)
* Rot Executar: CtbDocEnt()
* Alias Arq: SF1
***********************************************************************

nTipo   := Val(SF1->F1_TIPODOC)
/*
Na Argentina utiliza a contabilização da anulação da nota para fazer a contra partida da contabilização de inclusão. 
Porém a nota é excluida impossibilitando seu rastreamento.
*/ 
If cPaisLoc == "ARG" .And. nTipo == 0 //nTipo será igual a 0 quando o campo SF1->F1_TIPODOC estiver em branco, ou seja quando o registro da nota estiver excluido
	MSGAlert(STR0056,STR0057) 
	Return
EndIf

aCfgNF  := MontaCfgNf(nTipo,aPergs,.T.)
LocxDlgNF(aCfgNF,2)

Return