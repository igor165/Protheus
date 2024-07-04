#INCLUDE "protheus.ch"
#INCLUDE "ATFR300.ch"

// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFR300   บ Autor ณ Marcos S. Lobo.    บ Data ณ  14/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de Cadastro das apolices de seguro.		      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function ATFR300 (cApolIni,cApolFim,cCodSegIni,cCodSegFim) 
Local oReport
Pergunte( "AFR300" , .F. )
If TRepInUse()
	oReport:=ReportDef(cApolIni,cApolFim,cCodSegIni,cCodSegFim)
	oReport:PrintDialog()
Else
   Return ATFR300R3(cApolIni,cApolFim,cCodSegIni,cCodSegFim) // Executa versใo anterior do relatorio
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณReportDef ณ Autor ณClaudio D. de Souza    ณ Data ณ23/06/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณA funcao estatica ReportDef devera ser criada para todos os ณฑฑ
ฑฑณ          ณrelatorios que poderao ser agendados pelo usuario.          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpO1: Objeto do relat๓rio                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ReportDef(cApolIni,cApolFim,cCodSegIni,cCodSegFim)
Local oReport,oSection1, oSection2, oSection3, oSection4, oSection5
Local cReport := "ATFR300"
Local cAlias1 := "SNB"
Local cTitulo := STR0003 //"Ap๓lice de Seguro"
Local cDescri :=	STR0001 + " " +;	// "Este programa emite o relat๓rio de cadastro das Ap๓lices de Seguro."
					  	STR0002 + " " +;	// "Utilize o dicionario de dados para mudar a ordem/campos na impressao,"
					  	STR0018				// "exceto os campos Apolice/Cia.Seguradora/Vigencia do cabecalho."
					  	
Local bReport := { |oReport|	ReportPrint( oReport, cApolIni,cApolFim,cCodSegIni,cCodSegFim ) }
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
	aOrd 	:= {STR0008,STR0009}	///"N๚mero da Ap๓lice + Cod. Cia. Seguro"#"Cod. Cia. Seguro + N๚mero da Ap๓lice"
Endif

Pergunte( "AFR300" , .F. )
oReport  := TReport():New( cReport, cTitulo, "AFR300" , bReport, cDescri )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define as secoes do relatorio		 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport, STR0019 , {cAlias1}, aOrd )		//"Dados Cadastrais"
TRCell():New( oSection1, "NB_APOLICE"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_DESCRIC"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_DESCRIC"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_CODSEG"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_NOMESEG"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_DTINI"		, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_DTVENC"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_DTVENC"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_NMSEGUR"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_NMBENEF"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_NMBENEF"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_TIPOSEG"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_DCTPSEG"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_DCTPSEG"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_TIPOCOB"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_DCTPCOB"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_DCTPCOB"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_RENOVAC"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_RENOVAC"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_VLRSEG"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_VLRFRAN"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_VLRFRAN"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_VLRPREM"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_VLRDESC"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_VLRDESC"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_PARCELA"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_VLRPARC"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_VLRPARC"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_DIAVENC"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_DIAVENC"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_CODCORR"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "NB_CORRET"	, cAlias1 ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_CORRET"):SetCellBreak(.T.)

TRCell():New( oSection1, "NB_DADOS"		, cAlias1 ,/*X3Titulo*/,/*Picture*/, 80 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("NB_DADOS"):SetCellBreak(.T.)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportPrintบAutor  ณClaudio D. de Souza บ Data ณ  23/06/06   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuery de impressao do relatorio                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportPrint( oReport, cApolIni,cApolFim,cCodSegIni,cCodSegFim )
Local oSection1 := oReport:Section(1)
Local cQuery 	:= "SNB"
Local cChave 	:= SNB->(IndexKey(oSection1:GetOrder()))
Local oBreak

If !Empty(cApolIni) .or. !Empty(cApolFim)
	mv_par01 := cApolIni
	mv_par02 := cApolFim
Endif

If !Empty(cCodSegIni) .or. !Empty(cCodSegFim)
	mv_par01 := cCodSegIni
	mv_par02 := cCodSegFim
Endif

cQuery 	:= GetNextAlias()
cChave 	:= "%"+SqlOrder(cChave)+"%"

oSection1:BeginQuery()

BeginSql Alias cQuery
	SELECT *
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


oSection1:Cell("NB_NOMESEG"):SetBlock( { || Posicione("SX5",1,xFilial("SX5")+"AS"+(cQuery)->NB_CODSEG,"X5_DESCRI") } )
oSection1:Cell("NB_DCTPSEG"):SetBlock( { || Posicione("SX5",1,xFilial("SX5")+"AT"+(cQuery)->NB_CODSEG,"X5_DESCRI") } )
oSection1:Cell("NB_DCTPCOB"):SetBlock( { || Posicione("SX5",1,xFilial("SX5")+"AU"+(cQuery)->NB_CODSEG,"X5_DESCRI") } )
oSection1:Cell("NB_DADOS"):SetBlock( { || StrTran(MEUMEMO("SNE",(cQuery)->(NB_APOLICE+NB_CODSEG),"",2), Chr(13)+Chr(10), " " ) } )

oSection1:SetLineBreak()
oSection1:SetLineStyle()
oSection1:SetLeftMargin(5)

If oSection1:GetOrder() == 1
	oBreak := TRBreak():New( oSection1, { || (cQuery)->NB_CODSEG } )
Else
	oBreak := TRBreak():New( oSection1, { || (cQuery)->NB_APOLICE } )
Endif	

oBreak:SetPageBreak(.T.)
oSection1:Print()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFR300   บ Autor ณ Marcos S. Lobo.    บ Data ณ  14/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de Cadastro das apolices de seguro.		      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function ATFR300R3(cApolIni,cApolFim,cCodSegIni,cCodSegFim)

Local cDesc1        := STR0001///"Este programa emite o relat๓rio de cadastro das Ap๓lices de Seguro."
Local cDesc2        := STR0002///"Utilize o dicionario de dados para mudar a ordem/campos na impressao,"
Local cDesc3        := STR0018///"exceto os campos Apolice/Cia.Seguradora/Vigencia do cabecalho."
Local titulo       	:= STR0003///"Ap๓lice de Seguro"
Local nLin         	:= 80
Local Cabec1		:= STR0004 ///"N๚m. Ap๓lice: "
Local Cabec2		:= STR0005 ///"Cia.Seguradora: "
/// GRUPO 1 - CAMPOS PADROES (SEMPRE SAO IMPRESSOS)
Local aGrp2 := {}					/// GRUPO 2 - CAMPOS CADASTRAIS
Local aGrp3 := {}					/// GRUPO 3 - CAMPOS DE CLASSIFICACAO (TIPOS)
Local aGrp4 := {}					/// GRUPO 4 - CAMPOS VALORES / PARCELAS
Local aGrp5 := {}					/// GRUPO 5 - CAMPOS CORRETOR
Local aGrp6 := {}					/// GRUPO 6 - CAMPOS ADICIONAIS / ESPECIFICOS
Local lDADOS		:= .T.
Local cCposVLR 		:= "NB_VLRSEG#NB_VLRFRAN#NB_VLRPREM#NB_VLRDESC#NB_VLRPARC#"		/// CAMPOS DE VALOR (USAM PESQPICT)
Local lVlr			:= .F.
Local nD            := 0

Private aOrd	    := {}			//// ARRAY COM O TEXTO DAS ORDENS DE IMPRESSAO
Private aOrdIdx		:= {}			//// ARRAY COM AS CHAVES DAS ORDENS DE IMPRESSAO
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "ATFR300" // Nome para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { STR0006, 1, STR0007, 2, 2, 1, "", 1}	///"Zebrado"#"Administracao"
Private nLastKey    := 0
Private cPerg       := "AFR300"
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 1
Private wnrel       := "ATFR300" // Nome do arquivo usado para impressao em disco

Private cString := "SNB"

If ExistBlock("AFR300VLR")							/// PONTO DE ENTRADA PARA ADICIONAR CAMPOS COM MASCARA DE VALOR
	cCposVLR += ExecBlock("AFR300VLR",.F.,.F.)		/// RETORNO TEXTO (NOME DOs CAMPOs) P/ ADICIONAR NO CONTIDO
Endif

dbSelectArea("SIX")
dbSetOrder(1)
If MsSeek(cString,.F.)
	While !SIX->(Eof()) .and. SIX->INDICE == cString .and. SIX->ORDEM <= "2"
		#IFDEF SPANISH
			aAdd(aOrd,SIX->DESCSPA)
		#ELSE
			#IFDEF ENGLISH
				aAdd(aOrd,SIX->DESCENG)
			#ELSE
				aAdd(aOrd,SIX->DESCRICAO)
			#ENDIF
		#ENDIF
		aAdd(aOrdIdx,SIX->CHAVE)
		SIX->(dbSkip())
	EndDo
Else
	aOrd 	:= {STR0008,STR0009}	///"N๚mero da Ap๓lice + Cod. Cia. Seguro"#"Cod. Cia. Seguro + N๚mero da Ap๓lice"
	aOrdIdx := {"NB_FILIAL+NB_APOLICE+NB_CODSEG","NB_FILIAL+NB_CODSEG+NB_APOLICE"}
Endif

pergunte(cPerg,.F.)

If !Empty(cApolIni) .or. !Empty(cApolFim)
	mv_par01 := cApolIni
	mv_par02 := cApolFim
Endif

If !Empty(cCodSegIni) .or. !Empty(cCodSegFim)
	mv_par01 := cCodSegIni
	mv_par02 := cCodSegFim
Endif

dbSelectArea("SNB")
dbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

nLenRet	:= Len(aReturn)

If nLenRet > 8
	dbSelectArea("SX3")
	dbSetOrder(2)
	For nD := 9 to nLenRet
		If Substr(aReturn[nD],18,1) <> " "
			cCpo := Substr(aReturn[nD],65,10)
			If MsSeek(cCpo,.F.) .and. SX3->X3_FOLDER <> "1"
				If TRIM(SX3->X3_CAMPO)$(cCposVLR)
					lVlr	 := .T.
				Else
					lVlr	 := .F.
				Endif			

				If SX3->X3_TIPO == "N"
					aAdd(aGrp4,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,RetTitle(SX3->X3_CAMPO),lVlr,ALLTRIM(SX3->X3_CBOX)})		
				Else			
					aAdd(aGrp2,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,RetTitle(SX3->X3_CAMPO),ALLTRIM(SX3->X3_PICTURE),ALLTRIM(SX3->X3_CBOX)})		
				Endif
			Endif
		Endif
	Next
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek("NB_DADOS",.F.)	
		#IFDEF ENGLISH
			cAskMem := STR0010+ALLTRIM(SX3->X3_DESCENG)+" ?"
		#ELSE
			#IFDEF SPANISH
				cAskMem := STR0010+ALLTRIM(SX3->X3_DESCSPA)+" ?"		
			#ELSE
				cAskMem := STR0010+ALLTRIM(SX3->X3_DESCRIC)+" ?"		
			#ENDIF
		#ENDIF

		If X3Uso(SX3->X3_USADO) .and. MsgYesNo(cAskMem)	///"Imprime "
			lDADOS := .T.
		Else
			lDADOS := .F.
		Endif
	Else
		lDADOS := .F.
	Endif
Else
	dbSelectArea("SX3")
	dbSetOrder(1)
	If !MsSeek("SNB",.F.)
		MsgInfo(STR0011,STR0012) ///"Nใo hแ campos em uso para as apolices de seguro !" # "Cadastro SNB"
		Return
	Endif
	
	While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "SNB"
		If X3Uso(SX3->X3_USADO)
			If ALLTRIM(SX3->X3_CAMPO) == "NB_DADOS"
				#IFDEF ENGLISH
					cAskMem := STR0010+ALLTRIM(SX3->X3_DESCENG)+" ?"
				#ELSE
					#IFDEF SPANISH
						cAskMem := STR0010+ALLTRIM(SX3->X3_DESCSPA)+" ?"		
					#ELSE
						cAskMem := STR0010+ALLTRIM(SX3->X3_DESCRIC)+" ?"		
					#ENDIF
				#ENDIF
				If MsgYesNo(cAskMem)
					lDADOS := .T.
				Else
					lDADOS := .F.
				Endif
			ElseIf SX3->X3_CONTEXT <> "V"
				If TRIM(SX3->X3_CAMPO)$(cCposVLR)
					lVlr	 := .T.
				Else
					lVlr	 := .F.
				Endif			
		
				DO CASE
					CASE SX3->X3_FOLDER == "2"
						aAdd(aGrp2,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,RetTitle(SX3->X3_CAMPO),ALLTRIM(SX3->X3_PICTURE),ALLTRIM(SX3->X3_CBOX)})
					CASE SX3->X3_FOLDER == "3"
						aAdd(aGrp3,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,RetTitle(SX3->X3_CAMPO),ALLTRIM(SX3->X3_PICTURE),ALLTRIM(SX3->X3_CBOX)})
					CASE SX3->X3_FOLDER == "4"
						aAdd(aGrp4,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,RetTitle(SX3->X3_CAMPO),lVlr,ALLTRIM(SX3->X3_CBOX)})
					CASE SX3->X3_FOLDER == "5"
						aAdd(aGrp5,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,RetTitle(SX3->X3_CAMPO),ALLTRIM(SX3->X3_PICTURE),ALLTRIM(SX3->X3_CBOX)})
					CASE SX3->X3_FOLDER $ " 6"
						aAdd(aGrp6,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,RetTitle(SX3->X3_CAMPO),ALLTRIM(SX3->X3_PICTURE),ALLTRIM(SX3->X3_CBOX)})
				ENDCASE
			Endif
		Endif
		SX3->(dbSkip())
	EndDo
Endif

If (Len(aGrp2) + Len(aGrp3) + Len(aGrp4) + Len(aGrp5) + Len(aGrp6)) <= 0 .and. !lDADOS
	MsgInfo(STR0011,STR0012) ///"Nใo hแ campos em uso para as apolices de seguro !" # "Cadastro SNB"
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| AFR300Run(Cabec1,Cabec2,Titulo,nLin,aGrp2,aGrp3,aGrp4,aGrp5,aGrp6,lDADOS) },Titulo)

Return

/*/                                                                       
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณATFR300   บ Autor ณ Marcos S. Lobo     บ Data ณ  14/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AFR300Run(Cabec1,Cabec2,Titulo,nLin,aGrp2,aGrp3,aGrp4,aGrp5,aGrp6,lDADOS)

Local nOrdem

Local nTNBAPOLICE	:= Len(CriaVar("NB_APOLICE"))
Local nTNBCODSEG	:= Len(CriaVar("NB_CODSEG"))
Local cTITDADOS		:= RetTitle("NB_DADOS")
Local cNBTPSEG		:= ""
Local cNBTPCOB		:= ""
Local cPictCpo		:= ""
Local nDic          := 0

mv_par01 := PADR(mv_par01,nTNBAPOLICE)						//// CODIGO DA APOLICE INICIAL
mv_par02 := PADR(mv_par02,nTNBAPOLICE)						//// CODIGO DA APOLICE FINAL
mv_par03 := PADR(mv_par03,nTNBCODSEG)						//// CODIGO DA SEGURADORA INICIAL
mv_par04 := PADR(mv_par04,nTNBCODSEG)						//// CODIGO DA SEGURADORA FINAL

dbSelectArea(cString)

SetRegua(RecCount())

If !Empty(aReturn[7])
	SET FILTER TO &(aReturn[7])
Endif

nOrdem := aReturn[8]
dbSetOrder(nOrdem)

If aReturn[8] == 1
	MsSeek(xFilial("SNB")+mv_par01,.T.)
Else
	MsSeek(xFilial("SNB")+mv_par03,.T.)
Endif  

cTitCab1	:= Cabec1
cTitCab2	:= Cabec2
cChaveATU   := ""
cUltMoeda := ""
cTxtMoeda := ""

While SNB->(!EOF()).and. SNB->NB_FILIAL == xFilial("SNB") .And. SNB->NB_APOLICE <= mv_par02 .and. SNB->NB_CODSEG <= mv_par04
	
	If lAbortPrint
		@nLin,00 PSAY STR0013
		Exit
	Endif
	
	IncRegua(STR0014+SNB->NB_APOLICE)
	
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
	                   
	If cChaveATU <> SNB->(NB_APOLICE+NB_CODSEG)
		Cabec1 := cTitCab1 + SNB->NB_APOLICE + " " + SNB->NB_DESCRIC
		Cabec2 := cTitCab2 + SNB->NB_CODSEG + " " + SNB->NB_CSEGURO 
		Cabec2 += PADL(STR0015+DTOC(SNB->NB_DTINI) + STR0016 + DTOC(SNB->NB_DTVENC),LIMITE-LEN(Cabec2))
		cChaveATU   := SNB->(NB_APOLICE+NB_CODSEG)
		nLin := 80
	Endif
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)						//// SEMPRE DEVE QUEBRAR O CABECALHO PARA CADA APOLICE
	nLin := 8
	
	nLin++
	
	If Len(aGrp2) > 0											//// GRUPO DE CAMPOS 2 (CADASTRAIS)
		@nLin,000 PSAY __PrtThinLine()
		//nLin++
		For nDic := 1 to Len(aGrp2)
			@nLin,000 PSAY aGrp2[nDic,4]
			cTxtPrt := &("SNB->"+aGrp2[nDic,1])
			If !Empty(aGrp2[nDic,6])							//// SE A RELACAO DOS COMBOS ESTIVER DEFINIDA
				cTxtPrt := RetTxtBox(cTxtPrt,aGrp2[nDic,6])
				aGrp2[nDic,5] := ""
			Endif	
			@nLin,014 PSAY cTxtPrt PICTURE aGrp2[nDic,5]

			If aGrp2[nDic,1] == "NB_TIPOSEG"
				If cNBTPSEG <> cTxtPrt
					cNBTPSEG := cTxtPrt
					cTxtTPSEG := Posicione("SX5",1,xFilial("SX5")+"AT"+cTxtPrt,"X5_DESCRI")
				Endif
				@nLin,(14+aGrp2[nDic,3]+1) PSAY cTxtTPSEG
			ElseIf aGrp2[nDic,1] == "NB_TIPOCOB"
				If cNBTPCOB <> cTxtPrt
					cNBTPCOB := cTxtPrt
					cTxtTPCOB := Posicione("SX5",1,xFilial("SX5")+"AU"+cTxtPrt,"X5_DESCRI")
				Endif
				@nLin,(14+aGrp2[nDic,3]+1) PSAY cTxtTPCOB
			Endif

			nLin++
		Next
		@nLin,000 PSAY __PrtThinLine()
		nLin++
	Endif
	
	If Len(aGrp3) > 0											///// GRUPO DE CAMPOS 3 (CLASSIFICACAO/TIPOS)
		@nLin,000 PSAY __PrtThinLine()
		//nLin++
		For nDic := 1 to Len(aGrp3)
			@nLin,000 PSAY aGrp3[nDic,4]

			cTxtPrt := &("SNB->"+aGrp3[nDic,1])
			If !Empty(aGrp3[nDic,6])							//// SE A RELACAO DOS COMBOS ESTIVER DEFINIDA
				cTxtPrt := RetTxtBox(cTxtPrt,aGrp3[nDic,6])
				aGrp3[nDic,5] := ""
			Endif
			@nLin,014 PSAY cTxtPrt PICTURE aGrp3[nDic,5]
						
			If aGrp3[nDic,1] == "NB_TIPOSEG"
				If cNBTPSEG <> cTxtPrt
					cNBTPSEG := cTxtPrt
					cTxtTPSEG := Posicione("SX5",1,xFilial("SX5")+"AT"+cTxtPrt,"X5_DESCRI")
				Endif
				@nLin,(14+aGrp3[nDic,3]+1) PSAY cTxtTPSEG
			ElseIf aGrp3[nDic,1] == "NB_TIPOCOB"
				If cNBTPCOB <> cTxtPrt
					cNBTPCOB := cTxtPrt
					cTxtTPCOB := Posicione("SX5",1,xFilial("SX5")+"AU"+cTxtPrt,"X5_DESCRI")
				Endif
				@nLin,(14+aGrp3[nDic,3]+1) PSAY cTxtTPCOB
			Endif

			nLin++

		Next
		@nLin,000 PSAY __PrtThinLine()
		nLin++
	Endif
	
	If Len(aGrp4) > 0											//// GRUPO DE CAMPOS 4 (VALORES/PARCELAS)
		@nLin,000 PSAY __PrtThinLine()
		//nLin++

		If cUltMoeda <> SNB->NB_MOEDA
			cUltMoeda := ALLTRIM(SNB->NB_MOEDA)
			cTxtMoeda := GetNewPar("MV_MOEDAP"+cUltMoeda,"Moeda "+cUltMoeda)
		Endif
		
		@nLin,000 PSAY PADC(STR0017+cTxtMoeda,LIMITE)
		nLin++
		
		@nLin,000 PSAY __PrtThinLine()
		//nLin++
		
		lCol2 := .F.
		lFirst := .T.
		For nDic := 1 to Len(aGrp4)
			If lFirst							//// NA PRIMEIRA EXECUCAO IMPRIME NA COLUNA 1
				nCol1	:= 000
				nCol2	:= 014
				nLimit  := 38
				lCol2 := .F.
				lFirst := .F.
			Else
				If nDic%2 == 0					//// SE FOR COLUNA PAR (COLUNA 2)
					nCol1	:= 039
					nCol2	:= 054
					nLimit	:= 80
					lCol2 := .T.
				Else							//// SE FOR COLUNA IMPAR (COLUNA1)
					nCol1	:= 000
					nCol2	:= 014
					nLimit	:= 38
					lCol2 := .F.
				Endif
			Endif
			                     
			@nLin,nCol1 PSAY aGrp4[nDic,4]
			cTxtPrt := &("SNB->"+aGrp4[nDic,1])
			If !Empty(aGrp4[nDic,6])							//// SE A RELACAO DOS COMBOS ESTIVER DEFINIDA
				cTxtPrt  := RetTxtBox(cTxtPrt,aGrp4[nDic,6])
				cPictCpo := ""
			Else
				If  aGrp4[nDic,5]
					cPictCpo := PesqPict("SNB",aGrp4[nDic,1],,Val(SNB->NB_MOEDA))
				Else
					cPictCpo := PesqPict("SNB",aGrp4[nDic,1])
				Endif
			Endif
			@nLin,nCol2 PSAY cTxtPrt PICTURE cPictCpo
			
			If lCol2
				nLin++
			Endif
		Next
		
		If !lCol2			/// SE NรO TERMINOU EM COLUNAR PAR (COLUNA 2) FORCA A QUEBRA DE LINHA
			nLin++
		Endif
		
		@nLin,000 PSAY __PrtThinLine()
		nLin++
	Endif
	
	If Len(aGrp5) > 0											//// GRUPO DE CAMPOS 5 (DADOS DO CORRETOR)
		@nLin,000 PSAY __PrtThinLine()
		//nLin++
		For nDic := 1 to Len(aGrp5)
			@nLin,000 PSAY aGrp5[nDic,4]

			cTxtPrt := &("SNB->"+aGrp5[nDic,1])
			If !Empty(aGrp5[nDic,6])							//// SE A RELACAO DOS COMBOS ESTIVER DEFINIDA
				cTxtPrt := RetTxtBox(cTxtPrt,aGrp5[nDic,6])
				aGrp5[nDic,5] := ""
			Endif
			@nLin,014 PSAY cTxtPrt PICTURE aGrp5[nDic,5]

			If aGrp5[nDic,1] == "NB_TIPOSEG"
				If cNBTPSEG <> cTxtPrt
					cNBTPSEG := cTxtPrt
					cTxtTPSEG := Posicione("SX5",1,xFilial("SX5")+"AT"+cTxtPrt,"X5_DESCRI")
				Endif
				@nLin,(14+aGrp5[nDic,3]+1) PSAY cTxtTPSEG
			ElseIf aGrp5[nDic,1] == "NB_TIPOCOB"
				If cNBTPCOB <> cTxtPrt
					cNBTPCOB := cTxtPrt
					cTxtTPCOB := Posicione("SX5",1,xFilial("SX5")+"AU"+cTxtPrt,"X5_DESCRI")
				Endif
				@nLin,(14+aGrp5[nDic,3]+1) PSAY cTxtTPCOB
			Endif

			nLin++

		Next
		@nLin,000 PSAY __PrtThinLine()
		nLin++
	Endif
	    
	If Len(aGrp6) > 0											//// GRUPO DE CAMPOS 6 (DADOS ADICIONAIS/ESPECIFICOS)
		@nLin,000 PSAY __PrtThinLine()
		//nLin++
		For nDic := 1 to Len(aGrp6)
			@nLin,000 PSAY aGrp6[nDic,4]
		
			cTxtPrt := &("SNB->"+aGrp6[nDic,1])
			If !Empty(aGrp6[nDic,6])							//// SE A RELACAO DOS COMBOS ESTIVER DEFINIDA
				cTxtPrt := RetTxtBox(cTxtPrt,aGrp6[nDic,6])
				aGrp6[nDic,5] := ""
			Endif
			@nLin,014 PSAY cTxtPrt PICTURE aGrp6[nDic,5]

			If aGrp6[nDic,1] == "NB_TIPOSEG"
				If cNBTPSEG <> cTxtPrt
					cNBTPSEG := cTxtPrt
					cTxtTPSEG := Posicione("SX5",1,xFilial("SX5")+"AT"+cTxtPrt,"X5_DESCRI")
				Endif
				@nLin,(14+aGrp6[nDic,3]+1) PSAY cTxtTPSEG
			ElseIf aGrp6[nDic,1] == "NB_TIPOCOB"
				If cNBTPCOB <> cTxtPrt
					cNBTPCOB := cTxtPrt
					cTxtTPCOB := Posicione("SX5",1,xFilial("SX5")+"AU"+cTxtPrt,"X5_DESCRI")
				Endif
				@nLin,(14+aGrp6[nDic,3]+1) PSAY cTxtTPCOB
			Endif
						
			nLin++
		Next
		@nLin,000 PSAY __PrtThinLine()
		nLin++
	Endif
	
	If lDADOS
		@nLin,000 PSAY __PrtThinLine()
		//nLin++
		@nLin,000 PSAY cTITDADOS
		nLin := RPTMEUMEMO("SNE",SNB->(NB_APOLICE+NB_CODSEG),nLin,14,66,Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) //// FUNCAO PARA IMPRIMIR O CONTEUDO DO CAMPO MEMO
		@nLin,000 PSAY __PrtThinLine()
		nLin++
	Endif
	
	SNB->(dbSkip())
EndDo

dbSelectArea(cString)
If !Empty(aReturn[7])				/// LIMPA O FILTRO DE USUARIO DO ARQUIVO
	SET FILTER TO
Endif


SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRPTMEUMEMOบAutor  ณMarcos S. Lobo      บ Data ณ  10/15/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a impressao de todo o conteudo de campo MEMO padrao  บฑฑ
ฑฑบ          ณMEUMEMO() com linha/coluna/tamanho pre-definidos            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RPTMEUMEMO(cAliasMEM,cKeyMEM,nLinMEM,nColMEM,nTamMEM,Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

Local cNBDADOS	:= ""
Local aAreaMEM	:= GetArea()
Local cChQb		:= CHR(10)									//// CARACTER PARA FORCAR A QUEBRA DE LINHA NO CAMPO MEMO
Local cSegCont	:= ""										//// VARIAVEL PARA LEITURA CARACTER A CARACTER
Local cSeg2Qb 	:= ""										//// SEGMENTO DE TEXTO DO MEMO ATE A QUEBRA.
Local nD        := 0   

DEFAULT cAliasMEM	:= Alias()
DEFAULT nLinMEM		:= PLin()
DEFAULT nColMEM		:= PCol()

If ValType(cKeyMEM) == "U"									//// SE NAO HOUVER CHAVE DE PESQUISA DEFINIDA
	RestArea(aAreaMEM)
	Return(nLinMEM)											//// ABORTA IMPRESSAO
Endif

If Empty(nTamMEM)    										//// SE O TAMANHO PARA IMPRESSAO NAO ESTIVER DEFINIDO
	cPrefMEM := PrefCpo(cAlias)
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(cPrefMEM+"_MEMO",.F.)							//// BUSCA NO SX3 O TAMANHO DO CAMPO
		nTamMEM := SX3->X3_TAMANHO
	Else
		RestArea(aAreaMEM)									//// CASO CONTRARIO ABORTA IMPRESSAO
		Return(nLinMEM)
	Endif
Endif

dbSelectArea(cAliasMEM)
cNBDADOS := MEUMEMO(cAliasMEM,cKeyMEM,"",2)
If !Empty(cNBDADOS)
	nLenDADOS:= Len(cNBDADOS)
	For nD := 1 to nLenDADOS
		cSegCont := Substr(cNBDADOS,nD,1)
		If cSegCont == cChQb .or. Len(cSeg2Qb) == nTamMEM		//// SE FOR CARACTER DE QUEBRA OU COMPLETOU O TAMANHO DO MEMO PARA IMPRESSAO
			If cSegCont <> cChQb
				cSeg2Qb += cSegCont								/// SE NAO FOI QUEBRA FORCADA INCLUI O ULTIMO CARACTER NESTA LINHA
			Endif

			If nLinMEM > 54
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLinMEM := 9
			Endif

			@ nLinMEM,nColMEM PSAY cSeg2Qb						//// IMPRIME O SEGMENTO ATE A QUEBRA OU TODO SEGMENTO DE TEXTO ACUMULADO
			nLinMEM++
			cSeg2Qb := ""
		Else
			cSeg2Qb += cSegCont
		Endif
	Next nD
	
	If !Empty(cSeg2Qb)
		If nLinMEM > 54
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLinMEM := 9
		Endif
		@ nLinMEM,nColMEM PSAY cSeg2Qb					//// IMPRIME O SEGMENTO ATE A QUEBRA
		nLinMEM++
		cSeg2Qb := ""
	Endif
Endif

RestArea(aAreaMEM)

Return(nLinMEM)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณRetTxtBox ณ Autor ณ Marcos S. Lobo        ณ Data ณ 15/10/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPesquisa o Conteudo na ComboBox (TXT) e retorna o Texto corrณฑฑ
ฑฑณ          ณespondente ao codigo solicitado                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณRetTxtBox(cSeek,cTxtBox)                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ							                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Static Function RetTxtBox(cSeek,cTxtBox)

Local cTextoBox := cSeek  
Local cCol1		:= ""
Local lCol1		:= .F.
Local cCol2		:= ""
Local lCol2		:= .F.
Local cSegTxt	:= ""
Local cInSeg	:= ""
Local aCBox		:= {}             
Local nBox

For nBox := 1 to Len(cTxtBox)             
	cInSeg := Substr(cTxtBox,nBox,1)
	If cInSeg == "="
		cCol1 := cSegTxt
		cSegTxt := ""
		lCol1 := .T.
	ElseIf cInSeg == ";" .or. nBox == Len(cTxtBox)
		If cInSeg <> ";"
			cCol2 := cSegTxt+cInSeg							/// SE ACABOU O TEXTO ADICIONA O ULTIMO CARACTER PENDENTE AO TEXTO
		Else
			cCol2 := cSegTxt
		Endif
		cSegTxt := ""
		lCol2 := .T.
	Else
		cSegTxt += cInSeg
	Endif
	If lCol1 .and. lCol2
		aAdd(aCBox,{cCol1,cCol2})
		lCol1 := .F.
		lCol2 := .F.
	Endif
Next

If ValType(aCBOx[Len(aCBOX),2]) == "U"					//// CASO SEJA UM COMBOBOX DE APENAS UMA OPCAO (1=Texto1) POR EXEMPLO
	aCBOx[Len(aCBOX),2] := cSegTxt
Endif

nInCBox := Ascan(aCBox,{|x| x[1] == cSeek })

If nInCBox > 0
	If !Empty(aCBox[nInCBox,2])
		cTextoBox := aCBox[nInCBox,2]
	Endif
Endif

Return cTextoBox
