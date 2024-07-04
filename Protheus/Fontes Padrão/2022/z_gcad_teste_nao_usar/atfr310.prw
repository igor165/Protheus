#INCLUDE "protheus.ch"
#INCLUDE "ATFR310.ch"

// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFR310   º Autor ³ Marcos S. Lobo.    º Data ³  14/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Apolices de Seguro x Bens.					        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFR310(cApolIni,cApolFim,cSegIni,cSegFim)
Local oReport

If TRepInUse()
	oReport:=ReportDef(cApolIni,cApolFim,cSegIni,cSegFim)
	oReport:PrintDialog()
Else
   Return ATFR310R3(cApolIni,cApolFim,cSegIni,cSegFim) // Executa versão anterior do relatorio
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Claudio D. de Souza    ³ Data ³23/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(cApolIni,cApolFim,cSegIni,cSegFim)
Local oReport,oSection1, oSection2
Local cReport := "ATFR310"
Local cAlias1 := "SNB"
Local cAlias2 := "SN1"
Local cTitulo := STR0002 //"Apólices de Seguro x Bens"
Local cDescri := STR0001 // "Este programa emite o relatório Apólice de Seguro x Bens."
Local bReport := { |oReport|	ReportPrint( oReport, cApolIni,cApolFim,cSegIni,cSegFim ) }
Local aOrd := {}

dbSelectArea("SIX")
dbSetOrder(1)
If MsSeek("SNB",.F.)
	While !SIX->(Eof()) .and. SIX->INDICE == "SNB" .and. SIX->ORDEM <= "2"
		#IFDEF SPANISH
			aAdd(aOrd,SIX->DESCSPA)
		#ELSE
			#IFDEF ENGLISH
				aAdd(aOrd,SIX->DESCENG)
			#ELSE
				aAdd(aOrd,SIX->DESCRICAO)
			#ENDIF
		#ENDIF
		SIX->(dbSkip())
	EndDo
Else
	aOrd 	:= {STR0005,STR0006}	///"Número da Apólice + Cod. Cia. Seguro"#"Cod. Cia. Seguro + Número da Apólice"
Endif

Pergunte( "AFR310" , .F. )
oReport  := TReport():New( cReport, cTitulo, "AFR310" , bReport, cDescri )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 1a. secao do relatorio Valores nas Moedas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New( oReport, STR0010, {cAlias1,cAlias2}, aOrd )		//"Dados da Apólice"

TRCell():New( oSection1, "NB_APOLICE" , cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_DESCRIC" , cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_CODSEG"  , cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_CSEGURO" , cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "VIGENCIA"   , cAlias1 ,STR0009     ,/*Picture*/,21/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_VLRSEG"  , cAlias1 ,/*X3Titulo*/,""/*Picture*/, 27 /*Tamanho*/,/*lPixel*/, /*{|| code-block de impressao }*/)
oSection1:SetHeaderPage()

oSection2 := TRSection():New( oSection1, STR0011, {cAlias2} )		//"Dados dos bens"
TRCell():New( oSection2, "N1_CBASE"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_ITEM"   , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_DESCRIC", cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_CHAPA"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_LOCAL"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_AQUISIC", cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection2, "N1_BAIXA"  , cAlias2 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintºAutor  ³Claudio D. de Souza º Data ³  23/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Query de impressao do relatorio                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport, cApolIni,cApolFim,cSegIni,cSegFim )
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cQuery 	:= "SNB"
Local cChave 	:= SNB->(IndexKey(oSection1:GetOrder()))
Local cKeySN1

If !Empty(cApolIni) .or. !Empty(cApolFim)
	mv_par01 := cApolIni
	mv_par02 := cApolFim
Endif

If !Empty(cSegIni) .or. !Empty(cSegFim)
	mv_par03 := cSegIni
	mv_par04 := cSegFim
Endif

If mv_par06==2
	oSection2:SetLineCondition( { || .F. } )
Endif

cQuery 	:= GetNextAlias()
cChave 	:= "%"+SqlOrder(SNB->(IndexKey(oSection1:GetOrder())))+"%"

oSection1:BeginQuery()

BeginSql Alias cQuery
	SELECT
		NB_APOLICE, NB_DESCRIC, NB_CODSEG, NB_CSEGURO, NB_DTINI, NB_DTVENC,
		NB_MOEDA, NB_VLRSEG
	FROM
		%table:SNB% SNB
	WHERE
		SNB.NB_FILIAL = %xfilial:SNB% AND
		SNB.NB_APOLICE >= %Exp:mv_par01% AND
		SNB.NB_APOLICE <= %Exp:mv_par02% AND
		SNB.NB_CODSEG  >= %Exp:mv_par03% AND
		SNB.NB_CODSEG  <= %Exp:mv_par04% AND
		SNB.%notDel%
	ORDER BY %Exp:cChave%
EndSql

oSection1:EndQuery()

oSection1:Cell("VIGENCIA"):SetBlock( {|| DTOC((cQuery)->NB_DTINI)+"-"+DTOC((cQuery)->NB_DTVENC) })
oSection1:Cell("NB_VLRSEG"):SetBlock( {|| GetMv("MV_SIMB"+ALLTRIM((cQuery)->NB_MOEDA)) + " " + Transform((cQuery)->NB_VLRSEG, PesqPict("SNB", "NB_VLRSEG")) })

// Verifica tambem se imprime bens baixados.
If mv_par06==1
	oSection2:SetLineCondition({||	mv_par07==1 .Or. Empty(SN1->N1_BAIXA) } )
	If mv_par07 == 2
		oSection2:Cell("N1_BAIXA"):Disable()
	Else
		oSection2:Cell("N1_BAIXA"):SetBlock( {|| If(!Empty(SN1->N1_BAIXA), SN1->N1_BAIXA, "")})
	Endif
Else
	oSection2:SetLineCondition( { || .F. } )
Endif

oReport:SetMeter((cQuery)->(LastRec()))
oSection1:Init()

While (cQuery)->(!EOF()) .And. !oReport:Cancel()

	oReport:IncMeter()
	cKeySN1 := xFilial("SN1")+(cQuery)->(NB_APOLICE+NB_CODSEG)

	SN1->(dbSetOrder(5))
	If SN1->(!MsSeek(cKeySN1))		//// SE NAO ENCONTRAR BEM ASSOCIADO A ESTA APOLICE
		If mv_par05 == 1				//// EMITE APOLICE SEM BENS ? = SIM
			oSection1:PrintLine()
		Endif
		(cQuery)->(dbSkip())
		Loop								//// PASSA PARA A PROXIMA APOLICE
	Endif
	oSection1:PrintLine()
	If mv_par06 == 1					/// SE O PARAMETRO 6 ESTIVER PARA IMPRIMIR OS BENS
		oSection2:Init()
		While SN1->(!Eof()) .and. cKeySN1 == SN1->(N1_FILIAL+N1_APOLICE+N1_CODSEG) .And. ! oReport:Cancel()
			oSection2:PrintLine()
			SN1->(dbSkip())
		EndDo
		oSection2:Finish()
		oReport:ThinLine()
		oReport:SkipLine()
	Endif
	(cQuery)->(dbSkip())
EndDo
oSection1:Finish()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFR310   º Autor ³ Marcos S. Lobo.    º Data ³  14/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Apolices de Seguro x Bens.					      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ATFR310R3(cApolIni,cApolFim,cSegIni,cSegFim)

Local cDesc1        := STR0001///"Este programa emite o relatório Apólice de Seguro x Bens."
Local cDesc2        := ""
Local cDesc3        := ""
Local titulo       	:= STR0002///"Apólices de Seguro x Bens"
Local nLin         	:= 80
Local Cabec1		:= ""
Local Cabec2		:= ""

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "ATFR310" // Nome para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { STR0003, 1, STR0004, 2, 2, 1, "", 1}	///"Zebrado"#"Administracao"
Private nLastKey    := 0
Private cPerg       := "AFR310"
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 1
Private wnrel       := "ATFR310" // Nome do arquivo usado para impressao em disco
Private aOrd	    := {}			//// ARRAY COM O TEXTO DAS ORDENS DE IMPRESSAO

Private cString := "SNB"

dbSelectArea("SIX")
dbSetOrder(1)
If MsSeek("SNB",.F.)
	While !SIX->(Eof()) .and. SIX->INDICE == "SNB" .and. SIX->ORDEM <= "2"
		#IFDEF SPANISH
			aAdd(aOrd,SIX->DESCSPA)
		#ELSE
			#IFDEF ENGLISH
				aAdd(aOrd,SIX->DESCENG)
			#ELSE
				aAdd(aOrd,SIX->DESCRICAO)
			#ENDIF
		#ENDIF
		SIX->(dbSkip())
	EndDo
Else
	aOrd 	:= {STR0005,STR0006}	///"Número da Apólice + Cod. Cia. Seguro"#"Cod. Cia. Seguro + Número da Apólice"
Endif

pergunte(cPerg,.F.)

If !Empty(cApolIni) .or. !Empty(cApolFim)
	mv_par01 := cApolIni
	mv_par02 := cApolFim
Endif

If !Empty(cSegIni) .or. !Empty(cSegFim)
	mv_par03 := cSegIni
	mv_par04 := cSegFim
Endif

If !Pergunte(cPerg,.T.)
	Return
Endif

If mv_par08 == 2															/// SE O FILTRO DE USUARIO FOR PARA O CADASTRO DE BENS
	cString := "SN1"														/// USA O cString NO CADASTRO DE BENS
Endif																		/// CASO CONTRARIO O SNB (Apolices) E O DEFAULT.

dbSelectArea("SNB")
dbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)	/// SO FILTRO DE USUARIO E ORDENS DE IMPRESSAO

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| AFR310Run(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ATFR310   º Autor ³ Marcos S. Lobo     º Data ³  14/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AFR310Run(Cabec1,Cabec2,Titulo,nLin)

Local cNBAPOLICE	:= RetTitle("NB_APOLICE")
Local cNBDESCRIC	:= RetTitle("NB_DESCRIC")
Local cNBCODSEG		:= RetTitle("NB_CODSEG")
Local cNBCSEGURO	:= RetTitle("NB_CSEGURO")
Local cVIGENCIA		:= STR0009
Local cNBMOEDA		:= ""
Local cNBVLRSEG		:= RetTitle("NB_VLRSEG")
Local cN1CBASE		:= RetTitle("N1_CBASE")
Local cN1ITEM		:= RetTitle("N1_ITEM")
Local cN1DESCRIC	:= RetTitle("N1_DESCRIC")
Local cN1CHAPA		:= RetTitle("N1_CHAPA")
Local cN1LOCAL		:= RetTitle("N1_LOCAL")
Local cN1AQUISIC	:= RetTitle("N1_AQUISIC")
Local cN1BAIXA		:= RetTitle("N1_BAIXA")


Local nLenCol1		:= Len(CriaVar("NB_APOLICE"))
Local nLenCol2		:= Len(Pad(CriaVar("NB_DESCRIC"),If(Len(DTOC(SNB->NB_DTINI))>8,29,33)))

Local nLenCol3		:= Len(CriaVar("NB_CODSEG"))
Local nLenCol4		:= Len(CriaVar("NB_CSEGURO"))
Local nLenCol5		:= 17
Local nLenCol6 	:= 3
Local nLenCol7		:= 17
Local nLN1CBASE		:= Len(CriaVar("N1_CBASE"))
Local nLN1ITEM		:= Len(CriaVar("N1_ITEM"))
Local nLN1DESCRIC	:= Len(CriaVar("N1_DESCRIC"))
Local nLN1CHAPA		:= Len(CriaVar("N1_CHAPA"))
Local nLN1LOCAL		:= Len(CriaVar("N1_LOCAL"))
Local nLN1AQUISIC	:= 8								/// CAMPO DATA FIXO 8
Local nLN1BAIXA		:= 8								/// CAMPO DATA FIXO 8

Local nCol1 		:= 0					/// COLUNA PARA IMPRESSAO DO NUMERO DA APOLICE
Local nCol2 		:= 17					/// COLUNA PARA IMPRESSAO DA DESCRICAO DA APOLICE
Local nCol3 		:= 60					/// COLUNA PARA IMPRESSAO DO CODIGO DA SEGURADORA
Local nCol4 		:= 70					/// COLUNA PARA IMPRESSAO DO NOME DA SEGURADORA
Local nCol5 		:= 95					/// COLUNA PARA IMPRESSAO DA VIGENCIA (DATA INICIAL E FINAL)
Local nCol6			:= 113					/// COLUNA PARA IMPRESSAO DO SIMBOLO DE MOEDA
Local nCol7			:= 116					/// COLUNA PARA IMPRESSAO DO VALOR DO SEGURO
Local nColCBASE		:= 0
Local nColITEM		:= nColCBASE+nLN1CBASE+1
Local nColDESCRIC	:= nColITEM+nLN1ITEM+1
Local nColCHAPA		:= nColDESCRIC+nLN1DESCRIC+1
Local nColLOCAL		:= nColCHAPA+nLN1CHAPA+1
Local nColAQUISIC	:= nColLOCAL+nLN1LOCAL+1
Local nColBAIXA		:= nColAQUISIC+nLN1AQUISIC+1

Local cLstMoeda 	:= "1"
Local cSmbMoeda 	:= GetMv("MV_SIMB"+ALLTRIM(cLstMoeda))
Local n1St9			:= 4

dbSelectArea("SX3")
dbSetOrder(2)
If MsSeek("NB_VLRSEG",.F.)
	cPicVLRSEG	:= ALLTRIM(SX3->X3_PICTURE)
	n1St9		:= At("9",cPicVLRSEG)
	If n1St9 <= 0
		n1St9 := 4
	Endif
	nLenCol7	:= Len(ALLTRIM(SUBSTR(cPicVLRSEG,n1St9,Len(cPicVLRSEG))))

Else
	nLenCol7	:= Len("99,999,999,999.99")
Endif


//// TRATAMENTO PARA AS COLUNAS (PREVALECE PARA A COLUNA O TAMANHO MAIOR ENTRE O TITULO E O TAMANHO DO CAMPO)
nLenCol1 		:= If(Len(cNBAPOLICE)	>nLenCOL1	,Len(cNBAPOLICE)	,nLenCol1)
nLenCol2 		:= If(Len(cNBDESCRIC)	>nLenCOL2	,Len(cNBDESCRIC)	,nLenCol2)
nLenCol3 		:= If(Len(cNBCODSEG)	>nLenCOL3	,Len(cNBCODSEG)		,nLenCol3)
nLenCol4 		:= If(Len(cNBCSEGURO)	>nLenCOL4	,Len(cNBCSEGURO)	,nLenCol4)
nLenCol5			:= If(Len(cVIGENCIA)	>nLenCoL5	,Len(cVIGENCIA)		,nLenCol5)
nLenCol6 		:= If(Len(cNBMOEDA)		>nLenCoL6	,Len(cNBMOEDA)		,nLenCol6)
nLenCol7 		:= If(Len(cNBVLRSEG)	>nLenCOL7	,Len(cNBVLRSEG)		,nLenCol7)
nLN1CBASE		:= If(Len(cN1CBASE)		>nLN1CBASE	,Len(cN1CBASE)		,nLN1CBASE)
nLN1ITEM			:= If(Len(cN1ITEM)		>nLN1ITEM	,Len(cN1ITEM)		,nLN1ITEM)
nLN1DESCRIC		:= If(Len(cN1DESCRIC)	>nLN1DESCRIC,Len(cN1DESCRIC)	,nLN1DESCRIC)
nLN1CHAPA		:= If(Len(cN1CHAPA)		>nLN1CHAPA	,Len(cN1CHAPA)		,nLN1CHAPA)
nLN1LOCAL		:= If(Len(cN1LOCAL)		>nLN1LOCAL	,Len(cN1LOCAL)		,nLN1LOCAL)
nLN1AQUISIC		:= If(Len(cN1AQUISIC)	>nLN1AQUISIC,Len(cN1AQUISIC)	,nLN1AQUISIC)
nLN1BAIXA		:= If(Len(cN1BAIXA)		>nLN1BAIXA	,Len(cN1BAIXA)		,nLN1BAIXA)

dbSelectArea("SNB")

If mv_par08 == 2											//// SE O FILTRO ESTIVER INDICADO PARA O CADASTRO DE BENS
	dbSelectArea("SN1")										//// ABRE O ALIAS
	If !Empty(aReturn[7])
		SET FILTER TO &(aReturn[7])							//// EFETUA O FILTRO
	Endif
	dbSelectArea("SNB")
Else														//// CASO CONTRARIO TRATA O FILTRO DEFAULT SOBRE O CADASTRO DE APOLICES
	If !Empty(aReturn[7])
		SET FILTER TO &(aReturn[7])
	Endif
Endif

SetRegua(RecCount())

dbSetOrder(aReturn[8])

If aReturn[8] == 1
	MsSeek(xFilial("SNB")+mv_par01,.T.)
Else
	MsSeek(xFilial("SNB")+mv_par03+mv_par01,.T.)
Endif

//// DEFINE A POSICAO DAS COLUNAS PARA IMPRESSAO
nCol1		:= 0								/// COLUNA PARA IMPRESSAO DO NUMERO DA APOLICE
nCol2		:= nCol1+nLenCol1+1					/// COLUNA PARA IMPRESSAO DA DESCRICAO DA APOLICE
nCol3		:= nCol2+nLenCol2+1					/// COLUNA PARA IMPRESSAO DO CODIGO DA SEGURADORA
nCol4 	:= nCol3+nLenCol3+1					/// COLUNA PARA IMPRESSAO DO NOME DA SEGURADORA
nCol5 	:= nCol4+nLenCol4+1					/// COLUNA PARA IMPRESSAO DA VIGENCIA (DATA INICIAL E FINAL)
nCol6		:= nCol5+nLenCol5+If(Len(DTOC(SNB->NB_DTINI))>8,5,1)					/// COLUNA PARA IMPRESSAO DO SIMBOLO DA MOEDA
nCol7		:= nCol6+nLenCol6					/// COLUNA PARA IMPRESSAO DO VALOR DO SEGURO

nColCBASE	:= 3                    			/// COLUNA PARA IMPRESSAO DO CODIGO BASE DO BEM
nColITEM	:= nColCBASE+nLN1CBASE+1			/// COLUNA PARA IMPRESSAO DO ITEM BASE DO BEM
nColDESCRIC	:= nColITEM+nLN1ITEM+1				/// COLUNA PARA IMPRESSAO DA DESCRICAO DO BEM
nColCHAPA	:= nColDESCRIC+nLN1DESCRIC+1		/// COLUNA PARA IMPRESSAO DO NUMERO DE CHAPA DO BEM
nColLOCAL	:= nColCHAPA+nLN1CHAPA+1			/// COLUNA PARA IMPRESSAO DA LOCALIZACAO DO BEM
nColAQUISIC	:= nColLOCAL+nLN1LOCAL+1			/// COLUNA PARA IMPRESSAO DA DATA DE AQUISICAO DO BEM
nColBAIXA	:= nColAQUISIC+nLN1AQUISIC+1		/// COLUNA PARA IMPRESSAO DA DATA DE BAIXA DO BEM

Cabec1 := PADR(cNBAPOLICE,nLenCol1)+" "+PADR(cNBDESCRIC,nLenCol2)+" "+PADR(cNBCODSEG,nLenCol3)+" "+PADR(cNBCSEGURO,nLenCol4)+" "+PADC(cVIGENCIA,nLenCol5)+PAD("",nLenCol6)+PADL(cNBVLRSEG,nLenCol7)

While SNB->(!EOF()) .and. SNB->NB_APOLICE <= mv_par02 .and. SNB->NB_CODSEG <= mv_par04

	If lAbortPrint
		@nLin,00 PSAY STR0007
		Exit
	Endif

	IncRegua(STR0008+SNB->NB_APOLICE)

	If aReturn[8] == 1
		If SNB->NB_CODSEG < mv_par03 .or. SNB->NB_CODSEG > mv_par04
			SNB->(dbSkip())
			Loop
		Endif
	Else
		If SNB->NB_APOLICE < mv_par01 .or. SNB->NB_APOLICE > mv_par02
			SNB->(dbSkip())
			Loop
		Endif
	Endif

	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)						//// SEMPRE DEVE QUEBRAR O CABECALHO PARA CADA APOLICE
		nLin := 8
	Endif

	cKeySN1 := xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG)

	dbSelectArea("SN1")
	dbSetOrder(5)
	If !MsSeek(cKeySN1)					//// SE NAO ENCONTRAR BEM ASSOCIADO A ESTA APOLICE
		If mv_par05 == 1				//// EMITE APOLICE SEM BENS ? = SIM
			@nLin,000 PSAY __PrtThinLine()
			nLin++

			@nLin,nCol1 PSAY SNB->NB_APOLICE
			@nLin,nCol2 PSAY Pad(SNB->NB_DESCRIC,If(Len(DTOC(SNB->NB_DTINI))>8,29,33))
			@nLin,nCol3 PSAY SNB->NB_CODSEG
			@nLin,nCol4 PSAY SNB->NB_CSEGURO
			@nLin,nCol5 PSAY DTOC(SNB->NB_DTINI)+"-"+DTOC(SNB->NB_DTVENC)

			If cLstMoeda <> SNB->NB_MOEDA
				cLstMoeda := SNB->NB_MOEDA
				cSmbMoeda := GetMv("MV_SIMB"+ALLTRIM(cLstMoeda))
			Endif

			@nLin,nCol6 PSAY cSmbMoeda
			@nLin,nCol7 PSAY SNB->NB_VLRSEG PICTURE cPicVLRSEG
			nLin++
		Endif
		SNB->(dbSkip())
		Loop							//// PASSA PARA A PROXIMA APOLICE
	Endif

	@nLin,000 PSAY __PrtThinLine()
	nLin++

	@nLin,nCol1 PSAY SNB->NB_APOLICE
	@nLin,nCol2 PSAY Pad(SNB->NB_DESCRIC,If(Len(DTOC(SNB->NB_DTINI))>8,29,33))
	@nLin,nCol3 PSAY SNB->NB_CODSEG
	@nLin,nCol4 PSAY SNB->NB_CSEGURO
	@nLin,nCol5 PSAY DTOC(SNB->NB_DTINI)+"-"+DTOC(SNB->NB_DTVENC)

	If cLstMoeda <> SNB->NB_MOEDA
		cLstMoeda := SNB->NB_MOEDA
		cSmbMoeda := GetMv("MV_SIMB"+ALLTRIM(cLstMoeda))
	Endif

	@nLin,nCol6 PSAY PADR(cSmbMoeda,3)
	@nLin,nCol7 PSAY SNB->NB_VLRSEG PICTURE cPicVLRSEG
	nLin++

	If mv_par06 == 1																	/// SE O PARAMETRO 6 ESTIVER PARA IMPRIMIR OS BENS

		nLin++
		//// CABECALHO DOS BENS ASSOCIADOS A ESTA APOLICE
		@nLin,nColCBASE		PSAY cN1CBASE
		@nLin,nColITEM		PSAY cN1ITEM
		@nLin,nColDESCRIC	PSAY cN1DESCRIC
		@nLin,nColCHAPA		PSAY cN1CHAPA
		@nLin,nColLOCAL		PSAY cN1LOCAL
		@nLin,nColAQUISIC	PSAY cN1AQUISIC
		@nLin,nColBAIXA		PSAY cN1BAIXA
		nLin++

		While SN1->(!Eof()) .and. cKeySN1 == SN1->(N1_FILIAL+N1_APOLICE+N1_CODSEG)

			If lAbortPrint
				@nLin,00 PSAY STR0007
				Exit
			Endif

			If mv_par07 == 2															//// SE O PARAMETRO IMPR. BAIXADOS == "NAO"
				If !Empty(SN1->N1_BAIXA)
					SN1->(dbSkip())
					Loop
				Endif
			Endif

			If nLin > 55
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)						//// SEMPRE DEVE QUEBRAR O CABECALHO PARA CADA APOLICE
				nLin := 8
			Endif

			@nLin,nColCBASE		PSAY SN1->N1_CBASE
			@nLin,nColITEM		PSAY SN1->N1_ITEM
			@nLin,nColDESCRIC	PSAY SN1->N1_DESCRIC
			@nLin,nColCHAPA		PSAY SN1->N1_CHAPA
			@nLin,nColLOCAL		PSAY SN1->N1_LOCAL
			@nLin,nColAQUISIC	PSAY DTOC(SN1->N1_AQUISIC)
			If !Empty(SN1->N1_BAIXA)
				@nLin,nColBAIXA		PSAY DTOC(SN1->N1_BAIXA)
			Endif
			nLin++

			SN1->(dbSkip())
		EndDo

	Endif

	SNB->(dbSkip())
EndDo

If mv_par08 == 2											//// SE O FILTRO ESTIVER INDICADO PARA O CADASTRO DE BENS
	dbSelectArea("SN1")										//// ABRE O ALIAS
	If !Empty(aReturn[7])
		SET FILTER TO
	Endif
	dbSelectArea("SNB")
Else														//// CASO CONTRARIO TRATA O FILTRO DEFAULT SOBRE O CADASTRO DE APOLICES
	dbSelectArea("SNB")
	If !Empty(aReturn[7])
		SET FILTER TO
	Endif
Endif

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return



