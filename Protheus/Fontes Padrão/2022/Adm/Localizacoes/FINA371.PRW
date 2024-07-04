#include "FINA371.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ FINA371  ³ AUTOR ³ Bruno Sobieski        ³ DATA ³ 24.02.99   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Contabilizacion Off-Line Modulo financiero, Argentina        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico - Localizacoes   | Complemento de FINA370           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Oscar G.      ³08/01/19³DMINA-³En fun. OrdPagProc, cuando MV_PAR14 = 2,se³±±
±±³              ³        ³5125  ³filtra solo por recibo y cliente.  MEX    ³±±
±±³Alf Medrano.  ³20/01/20³DMINA-³En fun. FA371Processa, cuando MV_PAR07 = 1³±±
±±³              ³        ³8258  ³se toma la filia cFilAnt. MEX             ³±±
±±³Eduardo Prz.  ³03/09/20³DMINA-³En fun. OrdPagProc, cuando MV_PAR14 = 2,se³±±
±±³              ³        ³9484  ³filtra solo por recibo.  MEX              ³±±
±±³Oscar G.      ³14/10/20³DMINA-³En fun. FinA371 se añade la funcionalidad ³±±
±±³              ³        ³10358 ³de Bloqueo Contable.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinA371(lDireto)

Local cPerg			:= "COFA01"
LOCAL nOpca			:= 0
LOCAL oDlg
Local aSays			:={}
Local aButtons		:={}

DEFAULT lDireto		:= .F.
PRIVATE aFilAdm		:= AdmAbreSM0()
PRIVATE cCadastro	:= STR0015 //"Contabiliza‡„o Off Line"
PRIVATE aAreaSEK	:= {}
PRIVATE aAreaSEL	:= {}
PRIVATE aAreaSFR	:= {}
Private lCabecalho	:= .F.
Private aFlagCTB	:= {}
Private lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Private cIndexSFR
Private cChaveSFR
Private cForSFR
Private nIndSFR
Private lLancPad7A
Private lLancPad7B
Private lLancPad7C
Private lLancPad7D

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("CARQUIVO,NHDLPRV,NTOTALLANC,CLOTE,NLINHA,AROTINA")
SetPrvt("LDIGITA,LAGLUTINA,CINDEXSEK,CCHAVESEK,CFORSEK,NINDSEK")
SetPrvt("CINDEXSEL,CCHAVESEL,CFORSEL,NINDSEL,DDATAANT,NPERIODO")
SetPrvt("DDATAINI,NTOTAL,MV_PAR04,MV_PAR05")
SetPrvt("LLANCPAD70,CORDPAGO,CFORNECE,CLOJA,NRECANT,LLANCTOK")
SetPrvt("CRECIBO,CSERREC,CCLIENTE,_SALIAS,CPERG,AREGS,I")
SetPrvt("J,LSERREC")

cArquivo 	:= ""
nHdlPrv 	:= 1
nTotalLanc 	:= 0
cLote		:= ""
nLinha 		:= 2
// Obs: este array aRotina foi inserido apenas para permitir o
// funcionamento das rotinas internas do advanced.
Private aRotina := GeraARot()

If cPaisLoc $ "ANG|COL|MEX|PER" .And. SFR->(FieldPos("FR_LA")) == 0
	Help(" ",1,"FINA371UPDATE",,STR0021+CRLF+STR0022+CRLF+STR0023+CRLF+STR0024,1,0)
	Return .F.
EndIf

//+--------------------------------------------------------------+
//¦ Variaveis utilizadas para parametros (vem de FINA370).		 ¦
//¦ mv_par01 // Mostra Lançamentos Contábeis 					 ¦
//¦ mv_par02 // Aglutina Lançamentos Contábeis					 ¦
//¦ mv_par03 // Emissao / Data Base 							 ¦
//¦ mv_par04 // Data Inicio										 ¦
//¦ mv_par05 // Data Fim										 ¦
//¦ mv_par06 // Carteira : Receber / Pagar / Ambas 		 		 ¦
//¦ mv_par07 // Considera os parametros abaixo					 ¦
//¦ mv_par08 // De Orden de PAgo     							 ¦
//¦ mv_par09 // A Orden de Pago      							 ¦
//¦ mv_par10 // De Recibo										 ¦
//¦ mv_par11 // A Recibo                             	 		 ¦
//¦ mv_par12 // De Serie										 ¦
//¦ mv_par13 // A Serie                             	 		 ¦
//³ mv_par14 // Separa por ? (Periodo,Documento,Processo)        ³
//¦ mv_par15 // De Filial                            	 		 ¦
//¦ mv_par16 // Ate Filial                           	 		 ¦
//+--------------------------------------------------------------+

AjustaCVA()

If IsBlind() .Or. lDireto
	BatchProcess( 	cCadastro, 	STR0016 + Chr(13) + Chr(10) ,cPerg,; // "Rotina de Contabilizacao Off-Line  para os titulo de recibos e ordem de pago"
					{ || FA371Processa(.T.) }, { || .F. })
	Return .T.
Endif

AcertaSXD(lDireto)

pergunte(cPerg,.F.)

AADD(aSays,STR0016) //"  Este programa tem como objetivo gerar Lan‡amentos Cont beis Off para t¡tulos" //"  Este programa tem como objetivo gerar Lan‡amentos Cont beis Off para t¡tulos"

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons )

If nOpcA == 1
	If CanProcItvl(mv_par04, mv_par05,aFilAdm[1][2],aFilAdm[Len(aFilAdm)][2],"FINA371")
		Processa({|lEnd| FA371Processa()})  // Chamada da funcao de Contabilizacao Off-Line
		FreeProcItvl("FINA371")
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FA370Proc ³ Autor ³ Wagner Xavier 		³ Data ³ 24/08/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Lan‡amentos Cont beis Off-Line				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA370()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA371Processa(lBat)

Local cCond     := ""
Local cFilAtu	:= cFilAnt
Local aAreaAtu  := GetArea()
Local lCpoSEK  := cPaisLoc <> "BRA"
Local lCpoSEL  := .t.
Local nInc		:= 0
Local aSM0		:= aFilAdm
Local cForAux	:= ""

dDataAnt	:=	dDataBase

Conout(STR0017) //"Inicializando Contabilizacao "

cFilDe := cFilAnt
cFilAte:= cFilAnt

lDigita   := If( mv_par01==1,.T.,.F.)
lAglutina := If( mv_par02==1,.T.,.F.)
lSerRec		:= GetNewPar("MV_SERREC",.F.)

dbSelectArea("SEK")
aAreaSEK := GetArea()

dbSelectArea("SEL")
aAreaSEL := GetArea()

If cPaisLoc $ "ANG|COL|MEX|PER"
	dbSelectArea("SFR")
	aAreaSFR := GetArea()
EndIF

For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. aSM0[nInc][2] >= cFilDe .AND. aSM0[nInc][2] <= cFilAte
		cFilAnt := aSM0[nInc][2]
		cFilX	:= cFilAnt

		If mv_par06	==	2 .or. mv_par06	==	3
			// +-----------------------------------------------------------+
			// ¦ Ordenes de Pago.                                          ¦
			// +-----------------------------------------------------------+
			cIndexSEK:= CriaTrab(Nil,.f.)
	   		If lCpoSEK
	   			cChaveSEK:= "EK_FILIAL+DTOS(EK_DTDIGIT)+EK_ORDPAGO+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_FORNEPG+EK_LOJAPG+EK_SEQ"
	   		Else
					cChaveSEK:= "EK_FILIAL+DTOS(EK_DTDIGIT)+EK_ORDPAGO+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_FORNECE+EK_LOJA+EK_SEQ"
	   		EndIf
		  	cForSEK  := 'DTOS(EK_DTDIGIT) >= "'+dtos(mv_par04)+'" .and. DTOS(EK_DTDIGIT) <= "'+dtos(mv_par05)+'" .And. '
			cForSEK  := cForSEK + 'Substr(EK_LA,1,1) #"S" .And. EK_FILIAL == "'+xFilial("SEK")+'"
			cForSEK  :=	Iif (mv_par07==1 , cForSEK + ' .And. EK_ORDPAGO >= "'+mv_par08+'" .And. EK_ORDPAGO <= "'+mv_par09+'"',cForSEK)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada executado apos a criacao da expressao de filtragem dos dados       ³
			//|   Primeiro parametro contem o alias que sera filtrado                              ³
			//|   O Retorno esperado e uma string com expressão advpl para filtro                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FA371FIL")
				cForAux := ExecBlock( "FA371FIL", .F., .F., {"SEK"} )
				If ValType(cForAux) == "C" .And. !Empty(cForAux)
					cForSEK += " .And. ( " + cForAux + " ) "
				EndIf
			EndIf
			dbSelectArea("SEK")
			IndRegua("SEK",cIndexSEK,cChaveSEK,,cForSEK,OemToAnsi(STR0001)) // "Selecionando Registros..."
				nIndSEK	:=	Retindex("SEK")
			#IFNDEF TOP
				DbSetIndex(cIndexSEK+OrdBagExt())
			#ENDIF
			dbSetOrder(nIndSEK+1)
			dbGoTop()
		Endif

		If mv_par06	==	1 .or. mv_par06	==	3
			// +-----------------------------------------------------------+
			// ¦ Recibos de Cobro.                                         ¦
			// +-----------------------------------------------------------+
			cIndexSEL := CriaTrab(Nil,.f.)
			If lCpoSEL
				cChaveSEL := "EL_FILIAL+DTOS(EL_DTDIGIT)+EL_RECIBO+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_CLIORIG+EL_LOJORIG"
			Else
				cChaveSEL := "EL_FILIAL+DTOS(EL_DTDIGIT)+EL_RECIBO+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_CLIENTE+EL_LOJA"
			EndIf
			cForSEL := 'DTOS(EL_DTDIGIT) >= "'+dtos(mv_par04)+'" .And. DTOS(EL_DTDIGIT) <= "'+dtos(mv_par05)+'" .And. '
			cForSEL := cForSEL + 'Substr(EL_LA,1,1) #"S" .And. EL_FILIAL == "'+xFilial("SEL")+'"
			cForSEL := Iif (mv_par07==1, cForSEL + ' .And. EL_RECIBO >= "'+mv_par10+'" .And. EL_RECIBO <= "'+mv_par11+'"',cForSEL)
			cForSEL :=Iif(mv_par07==1 .And. lSerRec,cForSEL+' .And. '+SerieNfId('SEL',3,'EL_SERIE')+' >= "'+mv_par12+'" .And. '+SerieNfId('SEL',3,'EL_SERIE')+' <= "'+mv_par13+'"',cForSel)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada executado apos a criacao da expressao de filtragem dos dados       ³
			//|   Primeiro parametro contem o alias que sera filtrado                              ³
			//|   O Retorno esperado e uma string com expressão advpl para filtro                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FA371FIL")
				cForAux := ExecBlock( "FA371FIL", .F., .F., {"SEL"} )
				If ValType(cForAux) == "C" .And. !Empty(cForAux)
					cForSEL += " .And. ( " + cForAux + " ) "
				EndIf
			EndIf

			dbSelectArea("SEL")
			IndRegua("SEL",cIndexSEL,cChaveSEL,,cForSEL,OemToAnsi(STR0001)) // "Selecionando Registros..."

			nIndSEL	:=	Retindex("SEL")
			#IFNDEF TOP
				DbSetIndex(cIndexSEL+OrdBagExt())
			#ENDIF
			dbSetOrder(nIndSEL+1)
			dbGoTop()

		Endif

		If cPaisLoc $ "ANG|COL|MEX|PER"
			// +-----------------------------------------------------------+
			// ¦ Diferencas de cambio                                      ¦
			// +-----------------------------------------------------------+
			cIndexSFR := CriaTrab(Nil,.f.)
	   		cChaveSFR:= "FR_CARTEI+FR_FILIAL+DTOS(FR_DATADI)+FR_ORDPAG+FR_RECIBO+FR_CHAVDE"
		  	cForSFR  := 'DTOS(FR_DATADI) >= "'+dtos(mv_par04)+'" .and. DTOS(FR_DATADI) <= "'+dtos(mv_par05)+'" .And. '
			cForSFR  := cForSFR + 'Substr(FR_LA,1,1) #"S" .And. FR_FILIAL == "'+xFilial("SFR")+'"
			cForSFR  := IIf (mv_par07==1, cForSFR + ' .And. ( ( FR_CARTEI == "2" .And. FR_ORDPAG >= "'+mv_par08+'" .And. FR_ORDPAG <= "'+mv_par09+'" ) .Or. ( FR_CARTEI == "1" .And. FR_RECIBO >= "'+mv_par10+'" .And. FR_RECIBO <= "'+mv_par11+'" ) )',cForSFR)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada executado apos a criacao da expressao de filtragem dos dados       ³
			//|   Primeiro parametro contem o alias que sera filtrado                              ³
			//|   O Retorno esperado e uma string com expressão advpl para filtro                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FA371FIL")
				cForAux := ExecBlock( "FA371FIL", .F., .F., {"SFR"} )
				If ValType(cForAux) == "C" .And. !Empty(cForAux)
					cForSFR += " .And. ( " + cForAux + " ) "
				EndIf
			EndIf
			dbSelectArea("SFR")
			IndRegua("SFR",cIndexSFR,cChaveSFR,,cForSFR,OemToAnsi(STR0001)) // "Selecionando Registros..."

			nIndSFR	:=	Retindex("SFR")
			#IFNDEF TOP
				DbSetIndex(cIndexSFR+OrdBagExt())
			#ENDIF
			dbSetOrder(nIndSFR+1)
			dbGoTop()
		EndIf

		If (!SEK->(EOF().And.BOF()).And. Alltrim(STR(mv_par06))$ "23") .or. (!SEL->(EOF().And.BOF()).And. Alltrim(STR(mv_par06))	$ "13") .or. ( cPaisLoc $ "ANG|COL|MEX|PER" .And. !SFR->(EOF().And.BOF()) )
			Processa({|lEnd| OrdPagProc(lBat)})
		EndIf
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Data inicial precisa ser "resetada"                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dDataBase := dDataAnt

Conout(STR0018) //"Termino da Contabilizacao "

//Restaura a area original da entrada da rotina...
RestArea(aAreaAtu)

//Restaura filial posicionada antes do processamento
cFilAnt := cFilAtu

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³OrdPagProc³ Autor ³     					³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Lan‡amentos Cont beis Off-Line				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINA371()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OrdPagProc(lBat)

Local nLaco
Local lProcSEK := .f.
Local lProcSEL := .f.
Local lCpoSEK  := cPaisLoc <> "BRA"
Local lCpoSEL  := .t.
Local aRegSEK  := {}
Local aRegSEL  := {}
Local aRegSFR  := {}
Local nX := 0
Local nTotDoc  := 0
Local nTotProc := 0
Local lAchou	:=.F.
//Variaveis para gravação do código de correlativo
Local aDiario	:= {}
Local lSeqCorr	:= UsaSeqCor("SE1/SE2/SE5/SEH/SEK/SEL/SET/SEU")
Local cPadrao570:= ""
Local cPadrao575:= ""     
Local aFormasPgto:= {} 
Local nC := 0
Local nTotVl := 0
Private cDebMed		:= ""
Private aDebMed		:= {}
Private cDebInm		:= {}
Private aDebInm		:= {}
/*
Verifica as formas de pagamento*/
aDebMed := {}
aDebInm := {}
aTipoTerc := {}
aTipoDocto := {"Todos"}
cTipoDocto  := aTipoDocto[1]
cDocPg := ""
aFormasPgto := Fin025Tipo()
For nC := 1 To Len(aFormasPgto)
	If aFormasPgto[nC,5] $ "13" .And. aFormasPgto[nC,7]		//documentos de terceiros 
		Aadd(aTipoTerc,Aclone(aFormasPgtop[nC]))
		Aadd(aTipoDocto,aFormasPgto[nC,3])
	Endif
	If aFormasPgto[nC,5] $ "23"
		If aFormasPgto[nC,4] == "1"		
			Aadd(aDebMed,aFormasPgto[nC,1])
		Else  //gera movimento bancario
			Aadd(aDebInm,aFormasPgto[nC,1])
		Endif
		If !Empty(cDocPg)
			cDocPg += ";"
		Endif
		cDocPg += (AllTrim(aFormasPgto[nC,1]) + "=" + Alltrim(aFormasPgto[nC,3]))
	Endif
Next
If Len(aDebMed) ==	0
	aDebMed	:=	{MVCHEQUE}
Endif
cDebMed	:=	aDebMed[1]
If Len(aDebInm) ==	0
	If Ascan(aDebmed,"TF") = 0
		AAdd(aDebInm,"TF")
	EndIf
	If Ascan(aDebMed,"EF") = 0
		AAdd(aDebInm,"EF")
	EndIf
	If Len(aDebInm) ==	0
		AAdd(aDebInm,"")
	EndIf
Endif
cDebInm	:=	aDebInm[1]+"|"+aDebInm[2]
     
//+--------------------------------------------------------------+
//¦ Laço da contabilizaçäo dia a dia, pela emissäo (mv_par03 = 1)¦
//¦ ou pela database.											 ¦
//+--------------------------------------------------------------+
If mv_par03 == 1
	nPeriodo := mv_par05 - mv_par04 + 1           // Data Final - Data inicial
	nPeriodo := Iif( nPeriodo == 0, 1, nPeriodo )
Else
	nPeriodo := 1
Endif

dDataIni := mv_par04

If ! lBat
	ProcRegua(nPeriodo)
EndIf

BEGIN SEQUENCE

For nLaco := 1 to nPeriodo
	If ! lBat
		IncProc()
	EndIf
	nTotalLanc := 0
	nHdlPrv:=0
	lCabecalho := .F.
 	//+--------------------------------------------------------------+
	//¦ Se a contabilizaçäo for pela data de emissäo, altera o valor ¦
	//¦ da data-base e dos parâmetros, para efetuar a contabilizaçäo ¦
	//¦ e a seleçäo dos registros respectivamente.				    ¦
	//+--------------------------------------------------------------+
 	If mv_par03 == 1
   	  	dDataBase := dDataIni + nLaco - 1
	  	mv_par04 := dDataBase
	  	mv_par05 := dDataBase
    Endif
   	//+--------------------------------------------------------------+
   	//¦ Verifica o Número do Lote 											  ¦
   	//+--------------------------------------------------------------+

	dbSelectArea("SX5")
	dbSeek(xFilial()+"09FIN")
	If Found()
		If At(UPPER("EXEC"),SX5->X5_DESCRI) > 0
			cLote := &(SX5->X5_DESCRI)
		Else
			cLote := SX5->X5_DESCRI
		Endif
	Else
		cLote := "FIN"
	Endif

	//Ordem de Pago ou Ambos
	If Mv_par06==2 .Or.mv_par06==3

		aRegSEK := {}
		//+--------------------------------------------------+
		//¦ Gera Lancamento Contab. para Orden de Pago.      ¦
		//+--------------------------------------------------+
		DbSelectArea("SEK")
		cOrdPAgo	:=	""
		cFornece	:= ""
		cLoja		:= ""
		Do while !SEK->(EOF()).And.( SEK->EK_DTDIGIT >= mv_par04 .And. SEK->EK_DTDIGIT <= mv_par05 )
			If !SEK->EK_CANCEL
			
				Do Case
					Case SEK->EK_TIPODOC == "TB" .And. SEK->EK_TIPO $ MV_CPNEG+"/"+MVPAGANT .And. VerPadrao("5B9")
						lLancPad70 := .T. 
						cPadrao570 := "5B9"
					Case SEK->EK_TIPODOC == "TB" .And. !(SEK->EK_TIPO $ MV_CPNEG+"/"+MVPAGANT) .And. VerPadrao("5BA")
						lLancPad70 := .T. 			
						cPadrao570 := "5BA"	
					Case SEK->EK_TIPODOC == "PA" .And. VerPadrao("5BB")
						lLancPad70 := .T.
						cPadrao570 := "5BB"		
					Case SEK->EK_TIPODOC == "CP" .And. SEK->EK_TIPO $ cDebMed .And. VerPadrao("5BC")
						lLancPad70 := .T.
						cPadrao570 := "5BC"		
					Case SEK->EK_TIPODOC == "CP" .and. SEK->EK_TIPO $ cDebInm .And. VerPadrao("5BD")
						lLancPad70 := .T.
						cPadrao570 := "5BD"		
					Case SEK->EK_TIPODOC == "CT" .And. VerPadrao("5BE")
						lLancPad70 := .T.
						cPadrao570 := "5BE"		
					Case SEK->EK_TIPODOC == "RG" .And. VerPadrao("5BF")
						lLancPad70 := .T.
						cPadrao570 := "5BF"		
					Otherwise
						lLancPad70 := VerPadrao("570")
						cPadrao570 := "570"		
			    EndCase
				If lLancPad70
					If !lCabecalho
						If !a371Cabecalho(@nHdlPrv,@cArquivo,lBat)
							Exit
						EndIf
					Endif
					lProcSEK := .t.
					//+--------------------------------------------------+
					//¦ Posiciona Archivo Proveedores si necesario.      ¦
					//+--------------------------------------------------+
					If cOrdPago+cFornece+cLoja#SEK->EK_ORDPAGO+Iif(lCpoSEK,SEK->EK_FORNEPG+SEK->EK_LOJAPG,SEK->EK_FORNECE+SEK->EK_LOJA)
						SA2->(DbSetOrder(1))
						SA2->(DbSeek(xFilial("SA2")+Iif(lCpoSEK,SEK->EK_FORNEPG+SEK->EK_LOJAPG,SEK->EK_FORNECE+SEK->EK_LOJA),.F.))
						cOrdPAgo :=	SEK->EK_ORDPAGO
						cFornece :=	Iif(lCpoSEK,SEK->EK_FORNEPG,SEK->EK_FORNECE)
						cLoja	 :=	Iif(lCpoSEK,SEK->EK_LOJAPG,SEK->EK_LOJA)
					Endif
					//+--------------------------------------------------+
					//¦ Posiciona Archivo Bancos si necesario.  		     ¦
					//+--------------------------------------------------+
					If ( SEK->EK_TIPODOC=="CP" )
						SA6->(DbsetOrder(1))
						SA6->(DbSeek(xFilial("SA6")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA,.F.))
					EndIf
					nTotVl := DetProva( nHdlPrv,;
			                     	cPadrao570,;
				                     "COFFA01",;
				                     cLote,;
				                     @nLinha,;
				                     /*lExecuta*/,;
				                     /*cCriterio*/,;
				                     /*lRateio*/,;
				                     /*cChaveBusca*/,;
				                     /*aCT5*/,;
				                     /*lPosiciona*/,;
				                     @aFlagCTB,;
				                     /*aTabRecOri*/,;
				                     /*aDadosProva*/ )	
					nTotDoc:= nTotDoc + nTotVl  				 				
                    nTotalLanc += nTotDoc
                   	nTotProc   += nTotDoc
                   	Aadd(aRegSEK,SEK->(Recno()))
					If lSeqCorr
						aAdd(aDiario, { "SEK", SEK->(recno()),SEK->EK_DIACTB,"EK_NODIA","EK_DIACTB"} )
					EndIf					
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"EK_LA", "S", "SEK", SEK->( RecNo() ), 0, 0, 0} )
					EndIf	
					 If nTotVl == 0 .and. cPaisLoc == "ARG" 
						aFlagCTB[Len(aFlagCTB)][2]:= ""
					EndiF				
				EndIf
			EndIf
			SEK->(DbSkip())
			If (mv_par14 == 2 .And. nTotalLanc > 0)  .And.;
			   (cOrdPago+cFornece+cLoja#SEK->EK_ORDPAGO+Iif(lCpoSEK,SEK->EK_FORNEPG+SEK->EK_LOJAPG,SEK->EK_FORNECE+SEK->EK_LOJA)  .Or.  Eof())// Por documento
				Ca371Incl(cArquivo,nHdlPrv,cLote,nTotalLanc,@aRegSEK,"SEK",aDiario)
				nTotalLanc := 0
			Endif
		EndDo

		If mv_par14 == 3 .And. nTotProc > 0 // Por processo
			Ca371Incl(cArquivo,nHdlPrv,cLote,nTotalLanc,@aRegSEK,"SEK")
			nTotProc := 0
		Endif
	Endif

	//Recibo ou Ambos
   	If Mv_par06==1 .Or.mv_par06==3
		aRegSEL:={}
		//+--------------------------------------------------+
		//¦ Gera Lancamento Contab. para o Recibo            ¦
		//+--------------------------------------------------+
		DbSelectArea("SEL")
		If cPaisLoc == "BOL"
			SEL->(DbSetOrder(1))
			SEL->(DbGotop())
		EndIf
		cSerRec 	:= ""
		cRecibo		:= ""
		cCliente	:= ""
		cLoja		:= ""
		dbSelectArea("SX1")
		dbSetOrder(1)
		Do while !SEL->(EOF()).And.SEL->EL_DTDIGIT >= mv_par04 .And. SEL->EL_DTDIGIT <= mv_par05
			If cPaisLoc == "BOL"
				cRecibo:= SEL->EL_RECIBO
			Endif	

			If SX1->(MsSeek('FIN87A    '+ '03'))
				If cPaisloc == 'ARG' .AND. SX1->X1_PRESEL == 2 .AND. SEL->EL_CANCEL .AND. Empty(SEL->EL_LA)                                                                              	
						Do Case 
							Case SEL->EL_TIPODOC == "TB" .And. SEL->EL_TIPO $ MV_CPNEG+"/"+MVPAGANT .And. VerPadrao("5BN")
								lLancPad75 := .T.
								cPadrao575 := "5BN"
							Case SEL->EL_TIPODOC == "TB" .And. !(SEL->EL_TIPO $ MV_CPNEG+"/"+MVPAGANT) .And. VerPadrao("5BO")			
								lLancPad75 := .T.
								cPadrao575 := "5BO"
							Case SEL->EL_TIPODOC == "RA" .And. VerPadrao("5BP")
								lLancPad75 := .T.
								cPadrao575 := "5BP"
							Case SEL->EL_TIPODOC == "CH" .And. VerPadrao("5BQ")
								lLancPad75 := .T.
								cPadrao575 := "5BQ"
							Case SEL->EL_TIPODOC == "DC" .And. VerPadrao("5BR")
								lLancPad75 := .T.
								cPadrao575 := "5BR"
							Case SEL->EL_TIPODOC == "EF" .And. VerPadrao("5BS")
								lLancPad75 := .T.
								cPadrao575 := "5BS"
							Case SEL->EL_TIPODOC == "TF" .And. VerPadrao("5BT")
								lLancPad75 := .T.
								cPadrao575 := "5BT"
							Case SEL->EL_TIPODOC $ "RS/RL/RB/RI/RG/RR" .And. VerPadrao("5BU")
								lLancPad75 := .T.
								cPadrao575 := "5BU"
							Otherwise
								lLancPad75 := VerPadrao("575")
								cPadrao575 := "575"
						EndCase 						
						If lLancPad75
							If !lCabecalho
								If !a371Cabecalho(@nHdlPrv,@cArquivo,lBat)
									Exit
								EndIf
							Endif
							lProcSEL := .t.
							//+--------------------------------------------------+
							//¦ Posiciona Archivo Proveedores si necesario.      ¦
							//+--------------------------------------------------+
							If cRecibo+cCliente+cLoja#SEL->EL_RECIBO+Iif(lCpoSEL,SEL->EL_CLIORIG+SEL->EL_LOJORIG,SEL->EL_CLIENTE+SEL->EL_LOJA)
								SA1->(DbSetOrder(1))
								SA1->(DbSeek(xFilial("SA1")+Iif(lCpoSEL,SEL->EL_CLIORIG+SEL->EL_LOJORIG,SEL->EL_CLIENTE+SEL->EL_LOJA),.F.))
								cSerREc	    :=  SEL->EL_SERIE
								cRecibo		:=	SEL->EL_RECIBO
								cCliente :=	Iif(lCpoSEL,SEL->EL_CLIORIG,SEL->EL_CLIENTE)
								cLoja	 :=	Iif(lCpoSEL,SEL->EL_LOJORIG,SEL->EL_LOJA)
							Endif

							// Posicionando o banco qdo. nao for vazio - Sergio Fuzinaka ( 14/12/01 )
							If !Empty(SEL->EL_BANCO)
								SA6->(DbsetOrder(1))
								SA6->(DbSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))
							Endif
							lAchou:=.F.
							SE5->(DbSetOrder(2))
							//Nos casos de baixas parciais pelo recibo gera registros com a mesma chave.
							//A diferenca estah no campo E5_ORDREC(numero do recibo)
							If SE5->(DbSeek(xFilial("SE5")+"BA"+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
								While xFilial("SE5") == SE5->E5_FILIAL .And. SEL->EL_PREFIXO == SE5->E5_PREFIXO .And.;
									SEL->EL_NUMERO == SE5->E5_NUMERO .And. SEL->EL_PARCELA == SE5->E5_PARCELA .And.;
									SEL->EL_TIPO == SE5->E5_TIPO .And. SE5->E5_TIPODOC == "BA" .And.!SE5->(Eof()) .And. !lAchou
									If SE5->E5_ORDREC == SEL->EL_RECIBO .And. SE5->E5_SERREC==  SEL->EL_SERIE
										lAchou:=.T.
									Else
										SE5->(DbSkip())
									EndIf
								EndDo
							EndIf

							nTotDoc += DetProva( nHdlPrv,;
											cPadrao575,;
											"COFFA01",;
											cLote,;
											@nLinha,;
											/*lExecuta*/,;
											/*cCriterio*/,;
											/*lRateio*/,;
											/*cChaveBusca*/,;
											/*aCT5*/,;
											/*lPosiciona*/,;
											@aFlagCTB,;
											/*aTabRecOri*/,;
											/*aDadosProva*/ )
							nTotalLanc += nTotDoc
							nTotProc   += nTotDoc
							Aadd(aRegSEL,SEL->(Recno()))
							If lSeqCorr
								aAdd(aDiario, {"SEL",SEL->(recno()),SEL->EL_DIACTB,"EL_NODIA","EL_DIACTB"} )
							EndIf
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, {"EL_LA", "S", "SEL", SEL->( RecNo() ), 0, 0, 0} )
							EndIf
						EndIf
				Else
					If !SEL->EL_CANCEL																						
						Do Case 
							Case SEL->EL_TIPODOC == "TB" .And. SEL->EL_TIPO $ MV_CPNEG+"/"+MVPAGANT .And. VerPadrao("5BN")
								lLancPad75 := .T.
								cPadrao575 := "5BN"
							Case SEL->EL_TIPODOC == "TB" .And. !(SEL->EL_TIPO $ MV_CPNEG+"/"+MVPAGANT) .And. VerPadrao("5BO")			
								lLancPad75 := .T.
								cPadrao575 := "5BO"
							Case SEL->EL_TIPODOC == "RA" .And. VerPadrao("5BP")
								lLancPad75 := .T.
								cPadrao575 := "5BP"
							Case SEL->EL_TIPODOC == "CH" .And. VerPadrao("5BQ")
								lLancPad75 := .T.
								cPadrao575 := "5BQ"
							Case SEL->EL_TIPODOC == "DC" .And. VerPadrao("5BR")
								lLancPad75 := .T.
								cPadrao575 := "5BR"
							Case SEL->EL_TIPODOC == "EF" .And. VerPadrao("5BS")
								lLancPad75 := .T.
								cPadrao575 := "5BS"
							Case SEL->EL_TIPODOC == "TF" .And. VerPadrao("5BT")
								lLancPad75 := .T.
								cPadrao575 := "5BT"
							Case SEL->EL_TIPODOC $ "RS/RL/RB/RI/RG/RR" .And. VerPadrao("5BU")
								lLancPad75 := .T.
								cPadrao575 := "5BU"
							Otherwise
								lLancPad75 := VerPadrao("575")
								cPadrao575 := "575"
						EndCase 						
						If lLancPad75
							If !lCabecalho
								If !a371Cabecalho(@nHdlPrv,@cArquivo,lBat)
									Exit
								EndIf
							Endif
							lProcSEL := .t.
							//+--------------------------------------------------+
							//¦ Posiciona Archivo Proveedores si necesario.      ¦
							//+--------------------------------------------------+
							If cRecibo+cCliente+cLoja#SEL->EL_RECIBO+Iif(lCpoSEL,SEL->EL_CLIORIG+SEL->EL_LOJORIG,SEL->EL_CLIENTE+SEL->EL_LOJA)
								SA1->(DbSetOrder(1))
								SA1->(DbSeek(xFilial("SA1")+Iif(lCpoSEL,SEL->EL_CLIORIG+SEL->EL_LOJORIG,SEL->EL_CLIENTE+SEL->EL_LOJA),.F.))
								cSerREc	    :=  SEL->EL_SERIE
								cRecibo		:=	SEL->EL_RECIBO
								cCliente :=	Iif(lCpoSEL,SEL->EL_CLIORIG,SEL->EL_CLIENTE)
								cLoja	 :=	Iif(lCpoSEL,SEL->EL_LOJORIG,SEL->EL_LOJA)
							Endif

							// Posicionando o banco qdo. nao for vazio - Sergio Fuzinaka ( 14/12/01 )
							If !Empty(SEL->EL_BANCO)
								SA6->(DbsetOrder(1))
								SA6->(DbSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))
							Endif
							lAchou:=.F.
							SE5->(DbSetOrder(2))
							//Nos casos de baixas parciais pelo recibo gera registros com a mesma chave.
							//A diferenca estah no campo E5_ORDREC(numero do recibo)
							If SE5->(DbSeek(xFilial("SE5")+"BA"+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
								While xFilial("SE5") == SE5->E5_FILIAL .And. SEL->EL_PREFIXO == SE5->E5_PREFIXO .And.;
									SEL->EL_NUMERO == SE5->E5_NUMERO .And. SEL->EL_PARCELA == SE5->E5_PARCELA .And.;
									SEL->EL_TIPO == SE5->E5_TIPO .And. SE5->E5_TIPODOC == "BA" .And.!SE5->(Eof()) .And. !lAchou
									If SE5->E5_ORDREC == SEL->EL_RECIBO .And. SE5->E5_SERREC==  SEL->EL_SERIE
										lAchou:=.T.
									Else
										SE5->(DbSkip())
									EndIf
								EndDo
							EndIf

							nTotDoc += DetProva( nHdlPrv,;
											cPadrao575,;
											"COFFA01",;
											cLote,;
											@nLinha,;
											/*lExecuta*/,;
											/*cCriterio*/,;
											/*lRateio*/,;
											/*cChaveBusca*/,;
											/*aCT5*/,;
											/*lPosiciona*/,;
											@aFlagCTB,;
											/*aTabRecOri*/,;
											/*aDadosProva*/ )
							nTotalLanc += nTotDoc
							nTotProc   += nTotDoc
							Aadd(aRegSEL,SEL->(Recno()))
							If lSeqCorr
								aAdd(aDiario, {"SEL",SEL->(recno()),SEL->EL_DIACTB,"EL_NODIA","EL_DIACTB"} )
							EndIf
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, {"EL_LA", "S", "SEL", SEL->( RecNo() ), 0, 0, 0} )
							EndIf
						EndIf
					Endif
				EndIf
			Endif
			
			
			SEL->(DbSkip())
			If cPaisLoc == "BOL"
				If ((mv_par14 == 2 .And. nTotalLanc > 0)  .And.	(cRecibo#SEL->EL_RECIBO))  .Or.  SEL->(Eof())// Por documento
					Ca371Incl(cArquivo,nHdlPrv,cLote,nTotalLanc,@aRegSEL,"SEL",aDiario)
					nTotalLanc := 0
				Endif
			Else
				If (mv_par14 == 2 .And. nTotalLanc > 0)  .And.;
				 (Iif(cPaisLoc $ "MEX",cRecibo+cSerREc#SEL->EL_RECIBO+SEL->EL_SERIE, cRecibo+cCliente+cLoja#SEL->EL_RECIBO+Iif(lCpoSEL,SEL->EL_CLIORIG+SEL->EL_LOJORIG,SEL->EL_CLIENTE+SEL->EL_LOJA))  .Or.  Eof())// Por documento
					Ca371Incl(cArquivo,nHdlPrv,cLote,nTotalLanc,@aRegSEL,"SEL",aDiario)
					nTotalLanc := 0
				Endif
			EndIF			
		EndDo
		
		If mv_par14 == 3 .And. nTotProc > 0 // Por processo
			Ca371Incl(cArquivo,nHdlPrv,cLote,nTotalLanc,@aRegSEL,"SEL")
			nTotProc := 0
		Endif
   	EndIf

	//Diferenca de Cambio
	If cPaisLoc $ "ANG|COL|MEX|PER"

		lLancPad7A := VerPadrao("57A")
		lLancPad7B := VerPadrao("57B")
		lLancPad7C := VerPadrao("57C")
		lLancPad7D := VerPadrao("57D")
		aRegSFR := {}

		//+--------------------------------------------------+
		//¦ Gera Lancamento Contab. para Diferenca de Cambio ¦
		//+--------------------------------------------------+
		DbSelectArea("SFR")

		cOrdPAgo	:= ""
		cRecibo		:= ""
		Do while !SFR->(EOF()).And.( SFR->FR_DATADI >= mv_par04 .And. SFR->FR_DATADI <= mv_par05 )
			If !lCabecalho
				If !a371Cabecalho(@nHdlPrv,@cArquivo,lBat)
					Exit
				EndIf
			EndIf
			If cRecibo#SFR->FR_RECIBO .Or. cOrdPago#SFR->FR_ORDPAG
				cOrdPago	:= SFR->FR_ORDPAG
				cRecibo		:= SFR->FR_RECIBO
			Endif

			nTotDoc += DetProva( nHdlPrv,;
			                     IIf(SFR->FR_CARTEI=="1","57A","57C"),;
			                     "COFFA01",;
			                     cLote,;
			                     @nLinha,;
			                     /*lExecuta*/,;
			                     /*cCriterio*/,;
			                     /*lRateio*/,;
			                     /*cChaveBusca*/,;
			                     /*aCT5*/,;
			                     /*lPosiciona*/,;
			                     @aFlagCTB,;
			                     /*aTabRecOri*/,;
			                     /*aDadosProva*/ )

			nTotalLanc += nTotDoc
			nTotProc   += nTotDoc
			Aadd(aRegSFR,SFR->(Recno()))

			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"FR_LA", "S", "SFR", SFR->( RecNo() ), 0, 0, 0} )
			EndIf

			SFR->(DbSkip())
			If (mv_par14 == 2 .And. nTotalLanc > 0)  .And.;
			   ( cRecibo#SFR->FR_RECIBO .Or. cOrdPago#SFR->FR_ORDPAG .Or.  Eof())// Por documento
				Ca371Incl(cArquivo,nHdlPrv,cLote,nTotalLanc,@aRegSFR,"SFR")
				nTotalLanc := 0
			Endif
		EndDo

		If mv_par14 == 3 .And. nTotProc > 0 // Por processo
			Ca371Incl(cArquivo,nHdlPrv,cLote,nTotalLanc,@aRegSFR,"SFR")
			nTotProc := 0
		Endif

    EndIf

	If lCabecalho .And. nTotalLanc > 0 .And. mv_par14 == 1 // Por periodo
		//+-----------------------------------------------------+
		//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
		//+-----------------------------------------------------+
		RodaProva(  nHdlPrv,;
					nTotalLanc)

		//+-----------------------------------------------------+
		//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
		//+-----------------------------------------------------+
		lLanctOk := cA100Incl( cArquivo,;
					           nHdlPrv,;
					           3,;
					           cLote,;
					           lDigita,;
					           lAglutina,;
					           /*cOnLine*/,;
					           /*dData*/,;
					           /*dReproc*/,;
					           @aFlagCTB,;
					           /*aDadosProva*/,;
					           /*aDiario*/ )
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

		If lLanctOk .AND. !lUsaFlag
			If Len(aRegSEK) > 0
				nRecAnt:=SEK->(Recno())
				For nX := 1 To Len(aRegSEK)
					SEK->(DbGoTo(aRegSEK[nX]))
           			RecLock("SEK",.F.)
					SEK->EK_LA := "S"
					MsUnLock()
				Next
				SEK->(DbGoTo(nRecAnt))
			EndIf

			If Len(aRegSEL) > 0
				nRecAnt := SEL->(Recno())
				For nX := 1 To Len(aRegSEL)
					SEL->(DbGoTo(aRegSEL[nX]))
           			RecLock("SEL",.F.)
					SEL->EL_LA := "S"
					MsUnLock()
				Next
				SEL->(DbGoTo(nRecAnt))
			EndIf

			If cPaisLoc $ "ANG|COL|MEX|PER" .And. Len(aRegSFR) > 0
				nRecAnt := SFR->(Recno())
				For nX := 1 To Len(aRegSFR)
					SFR->(DbGoTo(aRegSFR[nX]))
           			RecLock("SFR",.F.)
					SFR->FR_LA := "S"
					MsUnLock()
				Next
				SFR->(DbGoTo(nRecAnt))
			EndIf

		EndIf
	EndIf
Next
END SEQUENCE

//Restaura parametro de data inicial
mv_par04 := dDataIni

//Restaura a area original do arquivo SEK...
If mv_par06	==	2 .or. mv_par06	==	3
	Retindex("SEK")
	Ferase(cIndexSEK+OrdBagExt())
	RestArea(aAreaSEK)
EndIf

//Restaura a area original do arquivo SEL...
If mv_par06	==	1 .or. mv_par06	==	3
	Retindex("SEL")
	Ferase(cIndexSEL+OrdBagExt())
	RestArea(aAreaSEL)
Endif

//Restaura a area original do arquivo SFR...
If cPaisLoc $ "ANG|COL|MEX|PER"
	Retindex("SFR")
	Ferase(cIndexSFR+OrdBagExt())
	RestArea(aAreaSFR)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Ca370Incl ³ Autor ³ Claudio D. de Souza		³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Envia lancamentos para contabilizade.                     	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Ca370Incl 																   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³FINA370																	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ca371Incl(cArquivo,nHdlPrv,cLote,nTotalLanc,aRegCont,cAlias,aDiario)

Local lLanctOk := .F.
Local nX       := 0
Local cCpoLA   := SubStr(cAlias,2,2)+"_LA"
Local nCpoLA   := (cAlias)->(ColumnPos(cCpoLA))
Local aArea		:= (cAlias)->(getArea())

Default aDiario := {}

//+-----------------------------------------------------+
//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
//+-----------------------------------------------------+
RodaProva(  nHdlPrv,;
			nTotalLanc)

//+-----------------------------------------------------+
//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
//+-----------------------------------------------------+
lLanctOk := cA100Incl( cArquivo,;
			           nHdlPrv,;
			           3,;
			           cLote,;
			           lDigita,;
			           lAglutina,;
			           /*cOnLine*/,;
			           /*dData*/,;
			           /*dReproc*/,;
			           @aFlagCTB,;
			           /*aDadosProva*/,;
			           aDiario )
RestArea(aArea)
aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
aDiario	:= {}

If lLanctOk .And. Len(aRegCont)>0 .AND. !lUsaFlag
	nRecAnt := (cAlias)->(Recno())
	For nX:=1 To Len(aRegCont)
		(cAlias)->(DbGoTo(aRegCont[nX]))
   		RecLock(cAlias,.F.)
		FieldPut(nCpoLA,"S") //SEK->EK_LA := "S"
		MsUnLock()
	Next
	(cAlias)->(DbGoTo(nRecAnt))
	aRegCont := {}
EndIf

lCabecalho := .F.

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³a370Cabeca³ Autor ³ Wagner Xavier 		  ³ Data ³ 24/08/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o arquivo de Contra Prova (Lancamentos off line) 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³a370Cabeca																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGAFIN																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a371Cabecalho(nHdlPrv,cArquivo,lAut)

Local lRet := .T.
DEFAULT lAut	:= .F.

nHdlPrv := HeadProva( cLote,;
                      "COFFA01",;
                      Substr( cUsuario, 7, 6 ),;
                      @cArquivo )
If nHdlPrv <= 0
	If !lAut
		Help(" ",1,"A100NOPROV")
	EndIf
	lRet := .F.
Else
	lCabecalho := .T.
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AcertaSXD ³ Autor ³ Paulo Augusto		 	³ Data ³ 26/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria registro no Arq. SXD para execucao do Schedule   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AcertaSXD(lAuto)
Local aArea	:= GetArea()

If !lAuto
	SXD->(DbSetOrder(1))
	If !SXD->(DbSeek("FINA371"))
		DbSelectArea("SXD")
  		RecLock("SXD",.T.)
		Replace XD_TIPO 	with "P"
		Replace XD_FUNCAO 	with "FINA371"
		Replace XD_PERGUNT 	with "COFA01"
		Replace XD_PROPRI 	with "S"
		Replace XD_TITBRZ 	with "Contabilizacao Off-Line  Recibo/Ordem de Pago"
		Replace XD_TITSPA 	with "Contabilizacion off-line  Recibo/Orden de Pago"
		Replace XD_TITENG 	with "Off-line accounting  Receipt/Payment order"
		Replace XD_DESCBRZ 	with "Rotina de Contabilizacao Off-Line  para os titulo de recibos e ordem de pago"
		Replace XD_DESCSPA 	with "Rutina de Contabilizacion Off-Line para los titulo de recibos y orden de pago"
		Replace XD_DESCENG 	with "Off-line accounting routine for bills included in the receipts and payment order"
		MsUnLock()
	EndIf
EndIf
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ AjustaCVA ³ Autor ³ Marcelo Akama           ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para atualizar a tabela pontos de lancamento padrao CVA³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATUALIZACAO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaCVA()
Local aCVA		:= {}
Local aEstrut	:= {}
Local nInc		:= 0
Local nCol		:= 0
Local cCodFil	:= xFilial( "CVA" )
Local aArea		:= GetArea()
Local aAreaCVA	:= CVA->(GetArea())

aEstrut := { "CVA_FILIAL", "CVA_CODIGO", "CVA_DESCRI", "CVA_CFGLAN", "CVA_MODULO", "CVA_PROCES" }

// Codigo, Modulo, Processo
// Itens a serem incluidos
//			  FILIAL,	COD	, DESCRI,																				CVG	, MOD , PROCES

aAdd( aCVA, { cCodFil, "57A", "Contas a Receber - Diferenca de Cambio a Receber"									,"2", "06", "200" } ) // 06-CTB
aAdd( aCVA, { cCodFil, "57B", "Contas a Receber - Estorno de Diferenca de Cambio a Receber"							,"2", "06", "200" } )
aAdd( aCVA, { cCodFil, "57C", "Contas a Pagar - Diferenca de Cambio a Pagar"										,"2", "06", "300" } )
aAdd( aCVA, { cCodFil, "57D", "Contas a Pagar - Estorno de Diferenca de Cambio a Pagar"								,"2", "06", "300" } )


DbSelectArea( "CVA" )
DbSetOrder( 1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³inclusao dos novos itens na tabela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua( Len( aCVA ) )
For nInc := 1 To Len( aCVA )
	If !CVA->( DbSeek( aCVA[nInc][1] + aCVA[nInc][2] ) )
		RecLock( "CVA", .T. )
		For nCol := 1 To Len( aCVA[nInc] )
			If FieldPos( aEstrut[nCol] ) > 0
				FieldPut( FieldPos( aEstrut[nCol] ), aCVA[nInc][nCol] )
			EndIf
		Next

		DbCommit()
		MsUnLock()

	EndIf
Next

RestArea(aAreaCVA)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraARot  ³ Autor ³ Ana Paula N. Silva     ³ Data ³23/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraARot()
Local aRotina:={{ "STR0012","AxPesqui" , 0 , 1},;             //"Localizar"
		  { "OemToAnsi(STR0013)","fA100Pag" , 0 , 3},;  //"Pagar"
		  { "OemToAnsi(STR0014)","fA100Rec" , 0 , 3},;  //"Receber"
		  { "OemToAnsi(STR0015)","fA100Can" , 0 , 5},;  //"Excluir"
		  { "OemToAnsi(STR0016)","fA100Tran", 0 , 3},;  //"Transferir"
		  { "OemToAnsi(STR0017)","fA100Clas", 0 , 5} }  //"Classificar"
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 	:= .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0
