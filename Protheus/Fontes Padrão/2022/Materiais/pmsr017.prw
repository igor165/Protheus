#INCLUDE "PMSR017.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSR017   ºAutor  ³ Totvs              º Data ³  16/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Demonstrativo de Rejeicoes                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSR017(cAlias,nReg,nOpcx)
Private lAE2_Produt
Private nQtdRec		:= 0
Private nQtdTpTrf	:= 0
Private nQtdPrj		:= 0
Private cItem
Private cRetSX1		// Nao remover, utilizado pelo F3 AN4SL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW,R3 SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !PMSBLKINT()//nao permitir manipulacao pelo Sigapms quando pms integrado
           
	PMSR017R4(cAlias,nReg,nOpcx)
	
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMSR017R4 ³ Autor ³ Totvs                 ³ Data ³ 16/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Demonstrativo de Rejeicoes                                  º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSR017R4(cAlias,nReg,nOpcx)
Local oReport

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()
If !Empty( oReport:uParam )
	Pergunte( oReport:uParam, .F. )
EndIf	

oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Totvs                 ³ Data ³17/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport
Local oProjeto
Local oTpTrf
Local oRecurso
Local oTarefas
Local oTotalRec
Local cAlias 	:= GetNextAlias()
Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")        

Private nCustD 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New( 	"PMSR017", STR0001, "PMR017", ;
							{|oReport| ReportPrint( oReport, @cAlias ) },;
							STR0002 + STR0003 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oProjeto := TRSection():New( oReport, STR0001, { cAlias }, {}, .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oProjeto := TRSection():New( oReport, STR0004, { cAlias }, {}, .F., .F. ) //"Projeto"
TRCell():New( oProjeto, "AF8_PROJET", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->PROJET } )
TRCell():New( oProjeto, "AF8_DESC", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->DESCRI } )

oTpTrf := TRSection():New( oReport, STR0005, { cAlias }, /*aOrdem*/, .F., .F. ) //"Tipo de Tarefa"
TRCell():New( oTpTrf, "AN4_TIPO"	, cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->TPTRF } )
TRCell():New( oTpTrf, "AN4_DESCRI", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->DESCTPTRF } )

oRecurso := TRSection():New( oReport, STR0006, { cAlias }, 	/*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oRecurso	, "AE8_RECURS",	cAlias, /*Titulo*/,	/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->EXECU } )
TRCell():New( oRecurso	, "AE8_DESCRI",	cAlias, /*Titulo*/,	/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| IIF(Empty(cObfNRecur),(cAlias)->DESCREC,cObfNRecur) } )   

oTarefas := TRSection():New( oReport, STR0008, { cAlias }, 	/*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oTarefas, "ANA_CODIGO"	, cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->TPERR } )
TRCell():New( oTarefas, "ANA_DESCRI", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->DESCERR } )
TRCell():New( oTarefas, "AF9_EDTPAI", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->EDTPAI } )
TRCell():New( oTarefas, "AF9_TAREFA", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->TAREFA } )
TRCell():New( oTarefas, "AF9_DESCRI", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->DESCTRF } )
TRCell():New( oTarefas, "ANB_REJEIT", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->REJEIT } )
TRCell():New( oTarefas, "ANB_EXEC", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->EXECU } )
TRCell():New( oTarefas, "ANB_DATA", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| StoD( (cAlias)->DATAR ) } )
TRCell():New( oTarefas, "ANB_CICLO", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->CICLO } )
TRCell():New( oTarefas, "ANB_ETPREJ", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->ETPREJ } )
TRCell():New( oTarefas, "ANB_ETPEXE", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->ETPEXE } )
TRCell():New( oTarefas, "ANB_QUANT", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->QUANT } )

oTotalRec := TRSection():New( oReport, STR0009, {}, /*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oTotalRec, "ANB_QUANT",, STR0009/*Titulo*/, PesqPict( "ANB", "ANB_QUANT" )/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| nQtdRec } )

oTotalTpTrf := TRSection():New( oReport, STR0010, {}, /*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oTotalTpTrf, "ANB_QUANT",, STR0010/*Titulo*/, PesqPict( "ANB", "ANB_QUANT" )/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| nQtdTpTrf } )

oTotalPrj := TRSection():New( oReport, STR0011, {}, /*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oTotalPrj,"ANB_QUANT",, STR0011/*Titulo*/, PesqPict( "ANB", "ANB_QUANT" )/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| nQtdPrj } )

oTpTrf:SetLinesBefore(0)
oRecurso:SetLinesBefore(0)
oProjeto:SetLinesBefore(0)

Return(oReport)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Totvs                ³ Data ³17/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³que faz a chamada desta funcao ReportPrint()                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³ExpC1: Alias da tabela de composicoes (AJT)                 ³±±
±±³          ³ExpC2: Alias da tabela de projetos (AF8)                    ³±±
±±³          ³ExpC3: Alias da tabela de tarefas (AF9)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport, cAlias )
Local cRecurso		:= ""
Local cOldRec		:= ""
Local cTrf			:= ""
Local cOldTrf		:= ""
Local cPrj			:= ""
Local cOldPrj		:= ""
Local oProjeto		:= oReport:Section(1)
Local oTpTrf		:= oReport:Section(2)
Local oRecurso		:= oReport:Section(3)
Local oTarefas		:= oReport:Section(4)
Local oTotalRec		:= oReport:Section(5)
Local oTotalTpTrf	:= oReport:Section(6)
Local oTotalPrj		:= oReport:Section(7)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//MakeSqlExpr(oReport:uParam/*Nome da Pergunte*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oProjeto:BeginQuery()	

cAlias := GetNextAlias()

	BeginSql Alias cAlias
		SELECT	ANB_FILIAL AS FILIAL,
				ANB_PROJET AS PROJET,
				ANB_REVISA AS REVISA,
				AF8_DESCRI AS DESCRI,
				AF9_DESCRI AS DESCTRF,
				AF9_TIPPAR AS TPTRF,
				AF9_EDTPAI AS EDTPAI,
				AN4_DESCRI AS DESCTPTRF,
				AE8_DESCRI AS DESCREC,
				ANB_TIPERR AS TPERR,
				ANA_DESCRI AS DESCERR,
				ANB_TAREFA AS TAREFA,
				ANB_REJEIT AS REJEIT,
				ANB_EXEC AS EXECU,
				ANB_DATA AS DATAR,
				ANB_CICLO AS CICLO,
				ANB_ETPREJ AS ETPREJ,
				ANB_ETPEXE AS ETPEXE,
				ANB_QUANT AS QUANT
		FROM %table:ANB% ANB
		LEFT JOIN %table:AF8% AF8 ON AF8_FILIAL = ANB_FILIAL AND AF8_PROJET = ANB_PROJET AND AF8.%NotDel%
		LEFT JOIN %table:AF9% AF9 ON AF9_FILIAL = ANB_FILIAL AND AF9_PROJET = ANB_PROJET AND AF9_REVISA = ANB_REVISA AND AF9_TAREFA = ANB_TAREFA AND AF9.%NotDel%
		LEFT JOIN %table:AN4% AN4 ON AN4_FILIAL = ANB_FILIAL AND AN4_TIPO = AF9_TIPPAR AND AN4.%NotDel%
		LEFT JOIN %table:ANA% ANA ON ANA_FILIAL = ANB_FILIAL AND ANA_CODIGO = ANB_TIPERR AND ANA.%NotDel%
		LEFT JOIN %table:AE8% AE8 ON AE8_FILIAL = ANB_FILIAL AND AE8_RECURS = ANB_EXEC AND AE8.%NotDel% AND AE8.AE8_EQUIP >= %Exp:mv_par03% AND AE8.AE8_EQUIP <= %Exp:mv_par04%
		WHERE 	ANB.ANB_FILIAL = %xFilial:ANB% AND 
				ANB.ANB_REJEIT >= %Exp:mv_par01% AND 
				ANB.ANB_REJEIT <= %Exp:mv_par02% AND 
				ANB.ANB_PROJET >= %Exp:mv_par05% AND 
				ANB.ANB_PROJET <= %Exp:mv_par06% AND 
				ANB.ANB_DATA >= %Exp:mv_par08% AND 
				ANB.ANB_DATA <= %Exp:mv_par09% AND 
				ANB.%NotDel%
		UNION
		SELECT	ANC_FILIAL AS FILIAL,
				ANC_PROJET AS PROJET,
				ANC_REVISA AS REVISA,
				AF8_DESCRI AS DESCRI,
				AF9_DESCRI AS DESCTRF,
				AF9_TIPPAR AS TPTRF,
				AF9_EDTPAI AS EDTPAI,
				AN4_DESCRI AS DESCTPTRF,
				AE8_DESCRI AS DESCREC,
				ANC_TIPERR AS TPERR,
				ANA_DESCRI AS DESCERR,
				ANC_TAREFA AS TAREFA,
				ANC_REJEIT AS REJEIT,
				ANC_EXEC AS EXECU,
				ANC_DATA AS DATAR,
				ANC_CICLO AS CICLO,
				ANC_ETPREJ AS ETPREJ,
				ANC_ETPEXE AS ETPEXE,
				ANC_QUANT AS QUANT
		FROM %table:ANC% ANC
		LEFT JOIN %table:AF8% AF8 ON AF8_FILIAL = ANC_FILIAL AND AF8_PROJET = ANC_PROJET AND AF8.%NotDel%
		LEFT JOIN %table:AF9% AF9 ON AF9_FILIAL = ANC_FILIAL AND AF9_PROJET = ANC_PROJET AND AF9_REVISA = ANC_REVISA AND AF9_TAREFA = ANC_TAREFA AND AF9.%NotDel%
		LEFT JOIN %table:AN4% AN4 ON AN4_FILIAL = ANC_FILIAL AND AN4_TIPO = AF9_TIPPAR AND AN4.%NotDel%
		LEFT JOIN %table:ANA% ANA ON ANA_FILIAL = ANC_FILIAL AND ANA_CODIGO = ANC_TIPERR AND ANA.%NotDel%
		LEFT JOIN %table:AE8% AE8 ON AE8_FILIAL = ANC_FILIAL AND AE8_RECURS = ANC_EXEC AND AE8.%NotDel% AND AE8.AE8_EQUIP >= %Exp:mv_par03% AND AE8.AE8_EQUIP <= %Exp:mv_par04%
		WHERE 	ANC.ANC_FILIAL = %xFilial:ANC% AND 
				ANC.ANC_REJEIT >= %Exp:mv_par01% AND 
				ANC.ANC_REJEIT <= %Exp:mv_par02% AND 
				ANC.ANC_PROJET >= %Exp:mv_par05% AND 
				ANC.ANC_PROJET <= %Exp:mv_par06% AND 
				ANC.ANC_DATA >= %Exp:mv_par08% AND 
				ANC.ANC_DATA <= %Exp:mv_par09% AND 
				ANC.%NotDel%
		ORDER BY FILIAL, EXECU, TPERR, PROJET, REVISA, TAREFA, DATAR
	EndSql 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³                                                                        ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³                                                                        ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oProjeto:EndQuery(/*ExpA1*/)

oReport:SetMeter( (cAlias)->( LastRec() ) )
	
DbSelectArea( cAlias )
While (cAlias)->( !Eof() ) .And. !oReport:Cancel()	
	// Filtra os tipos de tarefa
	If !Empty( MV_PAR07 ) .AND. !( (cAlias)->TPTRF $ MV_PAR07 )
		(cAlias)->( DbSkip() )
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³inicializa as secoes e a impressao do relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oProjeto:Init()
	oTpTrf:Init()
	oRecurso:Init()
	oTarefas:Init()

	If cOldPrj <> (cAlias)->PROJET
		oProjeto:PrintLine()
	EndIf

	If cOldTrf <> (cAlias)->TPTRF
		oTpTrf:PrintLine()
	EndIf

	If cOldRec <> (cAlias)->EXECU
		oRecurso:PrintLine()
	EndIf

	oTarefas:PrintLine()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³armazena em variaveis para realizar a quebra   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPrj := (cAlias)->PROJET
	If cOldPrj <> cPrj
		cOldPrj := cPrj
		oProjeto:Finish()
	EndIf

	cTrf := (cAlias)->TPTRF
	If cOldTrf <> cTrf
		cOldTrf := cTrf
		oTpTrf:Finish()
	EndIf

	cRecurso := (cAlias)->EXECU
	If cOldRec <> cRecurso
		cOldRec := cRecurso
		oRecurso:Finish()
	EndIf

	// Atualiza as quantidades
	nQtdRec		+= (cAlias)->QUANT
	nQtdTpTrf	+= (cAlias)->QUANT
	nQtdPrj		+= (cAlias)->QUANT

	(cAlias)->( DbSkip() )
	oReport:IncMeter()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ realizar a quebra  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOldRec <> (cAlias)->EXECU .OR. (cAlias)->( Eof() )
		oTarefas:Finish()
		oTarefas:Init()

		If nQtdRec > 0
			oTotalRec:Init()
			oTotalRec:PrintLine()
			oTotalRec:Finish()
		EndIf

		nQtdRec		:= 0

		oReport:SkipLine()
	EndIf

	If cTrf <> (cAlias)->TPTRF .OR. (cAlias)->( Eof() )
		oTpTrf:Finish()
		oTpTrf:Init()

		If nQtdTpTrf > 0
			oTotalTpTrf:Init()
			oTotalTpTrf:PrintLine()
			oTotalTpTrf:Finish()
		EndIf

		nQtdTpTrf	:= 0

		oReport:SkipLine()
	EndIf

	If cOldPrj <> (cAlias)->PROJET .OR. (cAlias)->( Eof() )
		oTarefas:Finish()
		oTarefas:Init()

		oTpTrf:Finish()
		oTpTrf:Init()

		oRecurso:Finish()
		oRecurso:Init()

		oProjeto:Finish()
		oProjeto:Init()

		// Apresenta o totalizador para o recurso
		If nQtdRec > 0
			oTotalRec:Init()
			oTotalRec:PrintLine()
			oTotalRec:Finish()
		EndIf

		nQtdRec		:= 0

		// Apresenta o totalizador para o tipo de tarefa
		If nQtdTpTrf > 0
			oTotalTpTrf:Init()
			oTotalTpTrf:PrintLine()
			oTotalTpTrf:Finish()
		EndIf

		nQtdTpTrf	:= 0

		// Apresenta o totalizador para o projeto
		If nQtdPrj > 0
			oTotalPrj:Init()
			oTotalPrj:PrintLine()
			oTotalPrj:Finish()
		EndIf

		nQtdPrj		:= 0

		oReport:SkipLine()
		oReport:SkipLine()
	EndIf
End

If oReport:Cancel()
	oReport:Say( oReport:Row()+1 ,10, STR0007 )
EndIf

Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
