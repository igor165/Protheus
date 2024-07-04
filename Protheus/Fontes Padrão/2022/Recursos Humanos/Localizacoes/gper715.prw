#Include "PROTHEUS.CH"
#INCLUDE "GPER715.CH"
#DEFINE   nColMax	3050
#DEFINE   nLinMax  2900

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออออัอออออออออออออออออออออออออหอออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณGPER715    บAutor   ณLuis Trombini            บ Data  ณ  21/06/2011   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออออฯอออออออออออออออออออออออออสอออออออฯอออออออออออออออนฑฑ
ฑฑบDesc.     ณGera็ใo da Planilla de Aportes Fondo Solidario                        บฑฑ
ฑฑบ          ณ                                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 11                                                                บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.         		       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ FNC            ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณClaudinei S.ณ29/03/12ณ00000008111/2012ณAjuste em GPER715 para corrigir o titulo  ณฑฑ
ฑฑณ            ณ        ณ          TET108ณdo relatorio conforme legislacao.         ณฑฑ
ฑฑณFabio G.    ณ02/05/12ณ          TEXKFTณAjuste Calculo p/ Aportes Fundo Solidario.ณฑฑ
ฑฑณM. Silveira ณ22/04/13ณ          TGWCE6|Foram acionados campos para composicao do ณฑฑ
ฑฑณ            ณ        ณ                |nome e informacoes da empresa no cabecalhoณฑฑ
ฑฑณA.Shibao    ณ11/09/13ณTHOVNB          |Ajuste no layout conforme modelo legal    ณฑฑ
ฑฑณ            ณ        ณ                |Adicionado novo campos SR8/RCM e perguntesณฑฑ
ฑฑณ            ณ        ณ                ณ                                          ณฑฑ
ฑฑณJonathan Glzณ06/05/15ณ      PCREQ-4256ณSe elimina funcion AjustaSX1T y AjustaHlp ณฑฑ
ฑฑณ            ณ        ณ                ณla cual realiza la modificacion a diccio- ณฑฑ
ฑฑณ            ณ        ณ                ณnario de datos(SX1) por motivo de adecua- ณฑฑ
ฑฑณ            ณ        ณ                ณcion  nueva estructura de SXs para V12    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function GPER715()

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Define Variaveis Locais (Basicas)                            ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Local cDesc1 		:= STR0024		//"Planilla de Aportes AFPดs"
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//"Obs.: Debe imprimirse un Formulario Mensual para cada Filial."
Local cString		:= "SRA"        // alias do arquivo principal (Base)
Local aOrd      	:= {STR0004,STR0005,STR0006}		//"Sucursal + Matricula"###"Sucursal + C. Costo"###"Sucural + Nombre"


/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Define Variaveis Private(Basicas)                            ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Private nomeprog	:= "GPER715"
Private aReturn 	:={ , 1,, 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg   	:= "GPR715"
Private aInfo 		:= {}

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis Utilizadas na funcao IMPR                          ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Private Titulo	    := STR0024		//"Planilla de Aportes AFPดs"
Private nTamanho    := "G"
Private nTipo		:= 1
Private cFilialDe   := ""
Private cFilialAte  := ""
Private cMes 		:= ""
Private cAno		:= ""
Private cMatDe      := ""
Private cMatAte     := ""
Private cCustoDe    := ""
Private cCustoAte   := ""
Private cNomeDe     := ""
Private cNomeAte    := ""
Private cSit        := ""
Private cCat        := ""
Private nQtdDias	:= 0
Private oPrint


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos para Impressao Grafica - Declaracao das Fontes Utilizadas.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private  oFont06, oFont07, oFont08, oFont10, oFont12n

oFont06 := TFont():New("Courier New",6.5,6.5,,.F.,,,,.T.,.F.)
oFont06n:= TFont():New("Courier New",6.5,6.5,,.T.,,,,.T.,.F.)
oFont07 := TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
oFont07n:= TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.)
oFont08 := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
oFont08n:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)
oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont12n:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)     //Negrito

//Checa se o campo RA_NRNUA existe no dicionario de dados
If !fValDic()
	Return()
EndIf

pergunte("GPR715",.F.)
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Envia controle para a funcao SETPRINT                        ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
wnrel:="GPER715"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis utilizadas para parametros                         ณ
ณ mv_par01        //  Tipo de Relatorio(AFP Prevision ou Futuroณ
ณ mv_par02        //  Filial De						           ณ
ณ mv_par03        //  Filial Ate					           ณ
ณ mv_par04        //  Mes/Ano Competencia Inicial?             |
ณ mv_par05        //  Matricula De                             ณ
ณ mv_par06        //  Matricula Ate                            ณ
ณ mv_par07        //  Centro de Custo De                       ณ
ณ mv_par08        //  Centro de Custo Ate                      ณ
ณ mv_par09        //  Nome De                                  ณ
ณ mv_par10        //  Nome Ate                                 ณ
ณ mv_par11        //  Situa็๕es a imp?                         ณ
ณ mv_par12        //  Categorias a imp?                        ณ
ณ mv_par13        //  Processos ?              				   ณ
ณ mv_par14        //  Roteiro ?                          	   ณ
ณ mv_par15        //  Data de Pagamento ?                      ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carregando variaveis mv_par?? para Variaveis do Sistema.     ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
nOrdem   := aReturn[8]

nTipo 		:= mv_par01
cFilialDe 	:= mv_par02
cFilialAte  := mv_par03
cMes	 	:= Left(mv_par04,02)
cAno		:= Right(mv_par04,04)
cMatDe		:= mv_par05
cMatAte     := mv_par06
cCustoDe    := mv_par07
cCustoAte   := mv_par08
cNomeDe     := mv_par09
cNomeAte    := mv_par10
cSit        := mv_par11
cCat        := mv_par12
cAnoMes		:= cAno+cMes
cProcessos	:= If( Empty(mv_par13),"", ConvQry(alltrim(mv_par13),"RA_PROCES"))
cProcedi	:= If( Empty(mv_par14),"'FOL'", ConvQry(AllTrim(mv_par14),"RD_ROTEIR"))
cFechaPgt	:= If( Empty(mv_par15),"", substr(dtos(mv_par15),7,2)+"/"+substr(dtos(mv_par15),5,2)+"/"+substr(dtos(mv_par15),1,4))

//-- Objeto para impressao grafica
oPrint 	:= TMSPrinter():New( If(nTipo=1, "Fondo Solidario AFPดs Previsi๓n", "Fondo Solidario AFPดs Futuro de Bolํvia") ) //"Planilla de Aportes AFPดs Previsi๓n" str0022,str0021
	  																							                          //ou "Planilla de Aportes AFPดs Futuro de Bolivia"
oPrint:SetLandscape()	//Imprimir Somente Paisagem


Titulo := If(nTipo=1, "Fondo Solidario AFPดs Previsi๓n", "Fondo Solidario AFPดs Futuro de Bolํvia")//"Planilla de Aportes AFPดs Previsi๓n"
					        																		//ou "Planilla de Aportes AFPดs Futuro de Bolivia"

RptStatus({|lEnd| IMPFUT(@lEnd,wnRel,cString,.F. )},Capital(Titulo))

	oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPFUT    บAutor  ณErika Kanamori      บ Data ณ  03/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IMPFUT(lEnd,wnRel,cString )

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPERFUT" , "SRA" , "2" ) + " } " )
Local cInicio		:= ""
Local cFim 			:= ""
Local nSavRec
Local nSavOrdem
Local nLin  		:= 680
Local aPerAberto 	:= {}
Local aPerFechado	:= {}
Local aPerTodos		:= {}
Local aCodFol		:= {}
Local cFilAnt 		:= ""
Local cFilAux
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis para controle em ambientes TOP.                    ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Local cQuery
Local aStruct  	:= {}
Local lQuery  	:= .F.
Local cQryOrd 	:= ""
Local cCateg  	:= ""
Local cSitu   	:= ""
Local nAux
Local cPeriodos
Local nDiasProp := 0
Local nDias 	:= 0
Local nTotDias	:= 0
Local dAdmissa	:= ""
Local dDemissa	:= ""
Local cAliasSR9 := "QSR9"
Local cProcS  	:= ""
Local cProcD  	:= ""

Local cQuerySra := ""
Local cSitQuery	:= ""
Local cCatQuery	:= ""

Local aAfast    := {}

Local dDtaini   := ctod("//")
Local dDtafim   := ctod("//")

Local cMnProces	:= ""
Local cMxProces	:= "ZZZZZ"

//-- Logico
Local lAllProCs		:= .F.

Private cAlias   := "SRA"
Private cAliasSra:= ""
Private cQrySRD	 := "SRD"

//Private nBaseCot	:= 0 Mudan็a de Layout gravado por coluna
//Private nTotBaseCot := 0  Mudan็a de Layout gravado por coluna

//variaveis para impressใo
Private nFunc 		:= 0
Private cIRLS 		:= ""
Private cFechNovedad:= ""
Private cTipoCI		:= ""
Private cNumNua		:= ""
Private nVCol21     := 0
Private nVCol22     := 0
Private nVCol23     := 0
Private nVCol24     := 0
Private nVCol25     := 0
Private nVCol26     := 0
Private nVCol27     := 0
Private nVCol28     := 0
Private nCol21Tot   := 0
Private nCol22Tot   := 0
Private nCol23Tot   := 0
Private nCol24Tot   := 0
Private NVDESAP1    := 0
Private NVDESAP2    := 0
Private NVDESAP3    := 0

Private	lReg		:= .F.
Private aSR9    	:= {}  // Centro de Custo

Private nTabS011	:= 0
Private nVPriPor	:= 0
Private nVPriVal	:= 0
Private nVPriCon	:= 0

Private nVSegPor	:= 0
Private nVSegVal	:= 0
Private nVSegCon	:= 0

Private nVTerPor	:= 0
Private	nVTerVal	:= 0
Private nVTerCon	:= 0

Private nTabS007	:= 0
Private cACTIVI		:= ""
Private cCORREO		:= ""
Private cREPLEG		:= ""
Private cIDREPLEG	:= ""
Private cDOCREPLEG	:= ""
Private cCASILLA	:= ""

Private cTime		:= Time()
Private nPag		:= 0

//Inicializa o mnemonico que ira armazenar as verbas de faltas a serem consideradas no tratamento.
SetMnemonicos(NIL,NIL,.T.,"P_DESCFALT")


If nOrdem == 1
	cQueryOrd := "RA_FILIAL, RA_MAT"
	dbSetOrder(1)
	SRA->( dbSeek( cFilialDe + cMatDe, .T. ) )
	cInicio   := "(cAliasSra)->RA_FILIAL + (cAliasSra)->RA_MAT"
	cFim      := cFilialAte + cMatAte
Else
	If nOrdem == 2
		cQueryOrd := "RA_FILIAL, RA_CC, RA_MAT"
		dbSetOrder(2)
		SRA->( dbSeek( cFilialDe + cCustoDe + cMatDe, .T. ) )
		cInicio   := "(cAliasSra)->RA_FILIAL + (cAliasSra)->RA_CC + (cAliasSra)->RA_MAT"
		cFim      := cFilialAte + cCustoAte + cMatAte

	Elseif nOrdem == 3
		cQueryOrd := "RA_FILIAL + RA_NOME + RA_MAT"
		dbSetOrder(3)
		SRA->( dbSeek( cFilialDe + cNomeDe + cMatDe, .T.) )
		cInicio	  := "(cAliasSra)->RA_FILIAL + (cAliasSra)->RA_NOME + (cAliasSra)->RA_MAT"
		cFim	  := cFilialAte + cNomeAte + cMatAte
	Endif
Endif


// Tabela S001 - Fondo Solidario
nTabS011	:= FPOSTAB("S011",'001',"=",3)                   // linea 1 = 13.000
NVDESAP1 	:= IF(nTabS011>0, FTABELA("S011",nTabS011,6),0)
nVPriPor	:= IF(nTabS011>0, FTABELA("S011",nTabS011,5),0)
nVPriVal	:= IF(nTabS011>0, FTABELA("S011",nTabS011,6),0)
nVPriCon	:= IF(nTabS011>0, FTABELA("S011",nTabS011,7),0)


nTabS011	:= FPOSTAB("S011",'002',"=",3)                   // linea 2 = 25.000
NVDESAP2 	:= IF(nTabS011>0,FTABELA("S011",nTabS011,6),0)
nVSegPor	:= IF(nTabS011>0,FTABELA("S011",nTabS011,5),0)
nVSegVal	:= IF(nTabS011>0,FTABELA("S011",nTabS011,6),0)
nVSegCon	:= IF(nTabS011>0,FTABELA("S011",nTabS011,7),0)


nTabS011	:= FPOSTAB("S011",'003',"=",3)                    // linea 3 = 35.000
NVDESAP3 	:= IF(nTabS011>0,FTABELA("S011",nTabS011,6),0)
nVTerPor	:= IF(nTabS011>0,FTABELA("S011",nTabS011,5), 0)
nVTerVal	:= IF(nTabS011>0,FTABELA("S011",nTabS011,6), 0)
nVTerCon	:= IF(nTabS011>0,FTABELA("S011",nTabS011,7), 0)


// Tabela S007 - Informaciones Legales
nTabS007 := FPOSTAB("S007",'001',"=",3)

cActivi		:= IF (nTabS007>0, FTABELA("S007",nTabS007,8), "")
cCorreo		:= IF (nTabS007>0, FTABELA("S007",nTabS007,9), "")
cRepleg		:= IF (nTabS007>0, FTABELA("S007",nTabS007,10),"")
cIdRepleg	:= IF (nTabS007>0, FTABELA("S007",nTabS007,11),"")
cDocRepleg	:= IF (nTabS007>0, FTABELA("S007",nTabS007,13),"")
cCasilla	:= IF (nTabS007>0, FTABELA("S007",nTabS007,14),"")


	//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria e situacoes, Processos, Roteiros
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Buscar Situacao/Categoria/Proceso/Roteiro em formato para SQLณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	For nAux := 1 to Len(cSit)
		cSitQuery += "'"+Subs(cSit,nAux,1)+"'"
		If ( nAux+1 ) <= Len(cSit)
			cSitQuery += ","
		Endif
	Next nAux

	For nAux := 1 to Len(cCat)
		cCatQuery += "'"+Subs(cCat,nAux,1)+"'"
		If ( nAux+1 ) <= Len(cCat)
			cCatQuery += ","
		Endif
	Next nAux

    // Verifica el Proceso
	lAllProCs 	:= Iif(AllTrim( cProcessos ) == "*" .Or. Empty(cProcessos), .F., .T.)

	// Montagem da query
	cAliasSra 	:= "QrySRA"
	cQuerySra	:= "SELECT * FROM "	+ RetSqlName( "SRA" ) + " SRA1 "
	cQuerySra	+= " Where RA_FILIAL>= '"	+ cFilialDe	+"' "
	cQuerySra	+= "AND   RA_FILIAL	<= '"	+ cFilialAte+"' "
	cQuerySra	+= "AND   RA_MAT	>= '"	+ cMatDe	+"' "
	cQuerySra	+= "AND   RA_MAT	<= '"	+ cMatAte	+"' "
	cQuerySra	+= "AND   RA_CC		>= '"	+ cCustoDe 	+"' "
	cQuerySra	+= "AND   RA_CC		<= '"	+ cCustoAte	+"' "
	cQuerySra	+= "AND   RA_SITFOLH IN ("	+ cSitQuery	+") "
	cQuerySra	+= "AND   RA_CATFUNC IN ("	+ cCatQuery	+") "
	If !(lAllProCs)
		cQuerySra 	+= "AND RA_PROCES BETWEEN '" + cMnProces + "' AND '" + cMxProces + "'"
	Else
		cQuerySra	+= "AND   RA_PROCES  IN ("	+ cProcessos+") "
	Endif
	cQuerySra   += "AND RA_TPAFP = '" + If(nTipo = 1, "1", "2") + "'"
	cQuerySra   += "AND D_E_L_E_T_ <> '*'
	cQuerySra   += " ORDER BY " + cQueryOrd


	IF Select(cAliasSra) > 0
		(cAliasSra)->( dbCloseArea() )
	Endif

	cQuerySra	:= ChangeQuery(cQuerySra)
//	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySra),cAliasSra)

	If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuerySra),cAliasSra,.T.,.T.)
		For nAux := 1 To Len(aStruct)
			If ( aStruct[nAux][2] <> "C" )
				TcSetField(cQuerySra,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
			EndIf
		Next nAux                                   '
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega Regua de Processamento                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	(cAliasSra)->( SetRegua(RecCount()) )
	SetPrc(0,0)

	dbSelectArea(cAliasSra)
	(cAliasSra)->( dbgotop() )


	While (cAliasSra)->( !eof()  .And. &cInicio <= cFim )

	    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Movimenta Regua de Processamento                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IncRegua()//IncProc()//(cAliasSra)->RA_FILIAL+" - "+(cAliasSra)->RA_MAT+" - "+(cAliasSra)->RA_NOME)

		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
		Endif

		cFil	 := (cAliasSra)->RA_FILIAL
		cMat	 := (cAliasSra)->RA_MAT
   		dAdmissa := stod((cAliasSra)->RA_ADMISSA)
   		dDemissa := stod((cAliasSra)->RA_DEMISSA)

		IF (cAliasSra)->RA_SITFOLH == "D"
           	dDtaini := Max( SToD((cAliasSra)->RA_ADMISSA) , CTOD( "01/"+Substr(cAnoMes,5,2) + "/" + Substr(cAnoMes,1,4) ) )
           	dDtafim := SToD( (cAliasSra)->RA_DEMISSA )
        ELSE
          	dDtaini := Max( SToD((cAliasSra)->RA_ADMISSA ), CTOD( "01/"+Substr(cAnoMes,5,2) + '/' + Substr(cAnoMes,1,4) ) )
          	dDtafim := CTOD( Alltrim(STR(f_UltDia(dDtaini))) + '/' +Substr(cAnoMes,5,2) + '/' + Substr(cAnoMes,1,4) )
        Endif

		//zera variaveis para cada funcionario
		nDiasProp	:= 0
		nTotDias	:= 0

		//-- Buscar a maior data caso alterada La data de admision
		cDelet := Iif(TcSrvType() != "AS/400", "%D_E_L_E_T_ = ' '%", "%@DELETED@ = ' '%" )
		BeginSql ALIAS cAliasSR9
			SELECT R9_FILIAL, R9_MAT, R9_CAMPO, R9_DESC
			FROM %table:SR9%
			WHERE R9_FILIAL = %exp:cFil%
			  AND R9_MAT = %exp:cMat%
			  AND ( R9_CAMPO = 'RA_ADMISSA' OR R9_CAMPO = 'RA_DEMISSA')
			  AND %exp:cDelet%

		EndSql

   		aSR9 := {}
		While (cAliasSR9)-> (!EOF())
			rFil	:= (cAliasSR9)->R9_FILIAL
			rMat	:= (cAliasSR9)->R9_MAT
			dCampo	:= (cAliasSR9)->R9_CAMPO
   		 	dData	:= cTod(Substr((cAliasSR9)->R9_DESC,1,2)+"/"+Substr((cAliasSR9)->R9_DESC,4,2)+"/"+Substr((cAliasSR9)->R9_DESC,7,4))
	    	Aadd (aSR9,{rFil,rMat,dCampo,dData})

		(cAliasSR9)-> (dbSkip())
		Enddo
		(cAliasSR9)->(DbCloseArea())

		For nAux = 1 to Len(aSR9)
   			If MesAno(aSR9[nAux][4]) == cAno+cMes
				If aSR9[nAux][3] == "RA_ADMISSA"
					dAdmissa := (aSR9[nAux][4])
  				Endif
				If aSR9[nAux][3] == "RA_DEMISSA"
					dDemissa := (aSR9[nAux][4])
				Else
					dDemissa := ctod("  /  /    ")
				Endif

           	Endif
   		Next nAux


		//quantidade de dias padrao para todos os funcionarios
		nQtdDias:= 30

		// Busca no acumulado
		cAlias := fBuscaDesc( (cAliasSra)->RA_FILIAL , (cAliasSra)->RA_MAT , cAnoMes , cProcedi )

		If Select(cAlias) > 0
				(cAlias)->( dbgotop() )

			fInfo(@aInfo,SRA->RA_FILIAL)				//Carrega array com informacoes da Filial

			nVCol21     := 0
			nVCol22     := 0
			nVCol23     := 0
			nVCol24     := 0

			While (cAlias)->( !eof() )

					IF (cAlias)->RD_PD == FGETCODFOL("1227")  //Base Fondo Solidario

						nVCol21 := (cAlias)->RD_VALOR
						nVCol24 := nVCol21 - NVDESAP1         //  - 13.000
						nVCol23 := nVCol21 - NVDESAP2         //  - 25.000
						nVCol22 := nVCol21 - NVDESAP3         //  - 35.000
						If nVCol24 < 0
							nVCol24 := 0
						Endif
						If nVCol23 < 0
							nVCol23 := 0
						Endif
						If nVCol22 < 0
							nVCol22 := 0
						Endif

						cAnoMes := (cAlias)->RD_DATARQ

						lReg	:= .T.
					Endif

					If  Month(dAdmissa) == Val(cMes) .OR. Month(dDemissa)== Val(cMes)  .And. Year(dAdmissa) == Val(cAno) .Or. Year(dDemissa) == Val(cAno)
						If (cAlias)->RD_PD == FGETCODFOL("0031")   //=Tratamento para mensalistas admissao
							nDiasProp := (cAlias)->RD_HORAS
						Elseif (cAlias)->RD_PD == FGETCODFOL("0032") //=Tratamento para horistas admissao
							nDias:= (cAliasSra)->RA_HRSMES / 30
							nDiasProp := (cAlias)->RD_HORAS / nDias
						Elseif (cAlias)->RD_PD == FGETCODFOL("0048") //=Tratamento para mensalistas e horistas na rescisao
							nDiasProp := (cAlias)->RD_HORAS
						Elseif (cAlias)->RD_PD == FGETCODFOL("0165") .OR. (cAliasSra)->RA_CATFUNC == "C"  //=Tratamento para comissionados admissao e rescisao
							If Month(dAdmissa) == Val(cMes)
								nDiasProp := ( f_UltDia(dAdmissa) -  Day(dAdmissa) + 1 )
							Else
								nDiasProp := Day( dDemissa)
							Endif
						Endif
					Endif

					//Verifica se a verba esta contida no mnemonico que armazena as verbas de Falta
					If (cAlias)->RD_PD $ P_DESCFALT
						If  (cAlias)->RD_TIPO1 $ "VD"
							nTotDias :=  (cAlias)->RD_HORAS
							nQtdDias := 30 - nTotDias
						Else
							nDias:= (cAliasSra)->RA_HRSMES / 30
							nTotDias := ((cAlias)->RD_HORAS / nDias )
							nQtdDias := 30 - nTotDias
						Endif
						If nDiasProp > 0
							nQtdDias := nDiasProp - nTotDias
						Endif
					Endif
			(cAlias)->(dbSkip())
			End
        Endif

        (cAlias)->(dbCloseArea())

    	If nVcol21 < NVDESAP1
	      lReg := .f.
    	Endif

		If lReg
			nFunc+=1
			nCol21Tot +=  nVCol21
			nCol22Tot +=  nVCol22
			nCol23Tot +=  nVCol23
			nCol24Tot +=  nVCol24
			cIRLS	  := ""

			cTipoCI := If( Empty((cAliasSra)->RA_TIPODOC) .Or. (cAliasSra)->RA_TIPODOC=="1", "CI", "PAS" )
			cNumNua := (cAliasSra)->RA_NRNUA

			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤe
			//ณBusca las ausencias                                                                                                               ณ
			//ณColumna 11                                                                                                                        ณ
			//ณSi RA_ADMISSA estแ en el mes reportado, colocar "I"                                                                               ณ
			//ณSi RA_DEMISSA estแ en el mes reportado, colocar "R"                                                                               ณ
			//ณSi tiene un ausentismo no remunerado (SR8) que abarque todo el periodo (R8_DTINI y R8_DTFIM) colocar 'L'                          ณ
			//ณSi tiene un ausentismo (SR8) autorizado de accidente de trabajo, o enfermedad profesional, o enfermedad 							 ณ
			//ณcon (RCM_TPIMSS IN ('CAP')) en el mes (R8_DTBLEG se encuentre en el mes) colocar un "S".                                          ณ
			//ณ				                                                                                                                     ณ
			//ณColumna 12                                                                                                                        ณ
			//ณSi tiene novedad "I" colocar RA_ADMISSA                                                                                           ณ
			//ณSi tiene novedad "R" colocar RA_DEMISSA                                                                                           ณ
			//ณSi tiene novedad "L" colocar el primer dia del mes                                                                                ณ
			//ณSi tiene novedad "S" colocar la fecha de inicio de la incapacidad o el primer dํa del mes en caso de que esta sea anterior al mes.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤe
			ENDDOC*/

			//Retorna os afastamentos para o relatorio
		   	fBuscaAutrz(cFil, cMat , dDtaini, dDtafim, cAnoMes )

		  	//Funcionarios demitidos no Mes/Ano de referencia
	 		If ( Month(dDemissa)== Val(cMes) .And.  Year(dDemissa) == Val(cAno) )
				cIRLS		:= "R"
				cFechNovedad:= DtoC(dDemissa)
				nQtdDias 	:= nDiasProp
			//Funcionarios admitidos no Mes/Ano de referencia
			ElseIf Month(dAdmissa) == Val(cMes) .And. Year(dAdmissa) == Val(cAno)
				cIRLS 		:= "I"
			   	cFechNovedad:= DtoC(dAdmissa)
				nQtdDias 	:= nDiasProp
            // Busca Afastamentos
			ElseIf empty(cIRLS)
			   cIRLS 		:= ""
			   cFechNovedad:= ""
		    Endif

			//controle de impressao
			If nLin == 0680
				nPag += 1
				ImpCabec()
			Endif

			ImpInfFunc(@nLin)
			nLin+= 30
			lReg:= .F.

			If nLin > 2800
				ImpRodape(@nLin)
				nLin := 0680
			Endif
		Endif

	(cAliasSra)->(dbSkip())

	End

	If nLin <> 0680
		ImpRodape(@nLin)
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Zera Variaveis para a prox. geracao                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nCol21Tot   := 0
	nCol22Tot   := 0
	nCol23Tot   := 0
	nCol24Tot   := 0
	nCol25Tot   := 0
	nFunc		:= 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Retorna o alias padrao                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF SELECT(cAlias) > 0
		(cAlias)->( dbclosearea() )
	Endif

	IF SELECT(cAliasSra) > 0
  		(cAliasSra)->( dbCloseArea() )
 	Endif

	Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpCabec  บAutor  ณErika Kanamori      บ Data ณ  03/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpCabec()

oPrint:say ( 0055, 0050, "SIGA/"+ wnRel, 				oFont08)
oPrint:say ( 0055, 3100, "Pagina "+alltrim(str(nPag))+" de " + alltrim(str(nPag)),oFont08)

oPrint:say ( 0080, 0050, cTime, 	oFont08)
oPrint:say ( 0055, 1300, STR0023, 	oFont12n)
oPrint:say ( 0095, 1550, STR0025, 	oFont12n)
oPrint:say ( 0080, 3150, cMes+" / "+cAno, 	oFont08)

// I. DATOS GENERALES
oPrint:say ( 0200, 0360, "I. DATOS GENERALES",		  	oFont08n)
oPrint:say ( 0250, 0050, "(1) Periodo de Cotizaci๓n", 	oFont07n)
oPrint:say ( 0340, 0050, "(2) Fecha de Pago",			oFont07n)
oPrint:say ( 0430, 0050, "(3) Documentos Presentados",	oFont07n)
oPrint:say ( 0250, 0600, "(4) Nบ de Hojas Adjuntas",	oFont07n)
oPrint:say ( 0340, 0600, "(5) Nบ de Asegurados",		oFont07n)
oPrint:say ( 0430, 0600, "(6) Tipo de Pago",			oFont07n)

// I. DETALLE DE LOS DATOS GENERALES
oPrint:say ( 0280, 0100, cAno + " / " + cMes,		oFont07)		//(1)
oPrint:say ( 0370, 0100, cFechaPgt          ,   	oFont07)		//(2)
oPrint:say ( 0460, 0100, "Medio Magnetico"  ,		oFont07)        //(3)
oPrint:say ( 0280, 0700, alltrim(str(nPag)),		oFont07)		//(4)
oPrint:say ( 0460, 0650, "Normal"			, 		oFont07)        //(6)

// II. DATOS DE LA EMPRESA
oPrint:say ( 0200, 2200, "II. DATOS DE LA EMPRESA",		oFont08n)
oPrint:say ( 0250, 1050, "(7) Tipo de Identificaci๓n", 	oFont07n)
oPrint:say ( 0340, 1050, "(9) Nombre o Raz๓n Social",	oFont07n)
oPrint:say ( 0440, 1050, "(11) Nombre y Apellido del Representante Legal",oFont07n)
oPrint:say ( 0250, 1850, "(8) Nบ de Identificaci๓n",	oFont07n)
oPrint:say ( 0340, 1850, "(10) Actividad Econ๓mica",	oFont07n)
oPrint:say ( 0250, 2430, "(12) Direcci๓n",				oFont07n)
oPrint:say ( 0270, 2300, "Zona",						oFont07n) //(13)
oPrint:say ( 0270, 2800, "Calle/Av.",					oFont07n) //(14)
oPrint:say ( 0340, 2300, "Casilla",						oFont07n) //(15)
oPrint:say ( 0340, 2450, "Tel้fono",					oFont07n) //(16)
oPrint:say ( 0340, 2650, "Fax",							oFont07n) //(17)
oPrint:say ( 0340, 2900, "Email",						oFont07n) //(18)
oPrint:say ( 0440, 2300, "Departamento",				oFont07n) //(19)
oPrint:say ( 0440, 2750, "Provincia",					oFont07n) //(20)
oPrint:say ( 0440, 2950, "Secci๓n",						oFont07n) //(21)
oPrint:say ( 0440, 1850, "Nบ Identificacion",			oFont07n) //(22)
oPrint:say ( 0440, 2150, "Tp. Doc",						oFont07n) //(23)


// II. DETALLE DE LOS DATOS DE LA EMPRESA
oPrint:say ( 0280, 1050, "NIT(x) GOB( ) SUP( )",  	oFont07)	//(7)
oPrint:say ( 0370, 1050, substr(aInfo[3],1,50),	oFont07)    //(9)
oPrint:say ( 0470, 1050, substr(cRepleg,1,50) ,    oFont07)	//(11)
oPrint:say ( 0280, 1850, cIdRepleg	           ,	oFont07)	//(8)
oPrint:say ( 0370, 1850, cActivi			   ,	oFont07)	//(10)
oPrint:say ( 0290, 2720, substr(aInfo[4],1,50),	oFont06)	//(12)
oPrint:say ( 0290, 2300, substr(aInfo[5],1,30),	oFont06) 	//(13)
oPrint:say ( 0370, 2300, cCasilla			   ,	oFont06) 	//(15)
oPrint:say ( 0370, 2450, aInfo[10]            ,		oFont06) 	//(16)
oPrint:say ( 0370, 2650, aInfo[11] 			   ,    oFont06) 	//(17)
oPrint:say ( 0370, 2900, cCorreo			   ,	oFont06) 	//(18)
oPrint:say ( 0470, 2300, substr(aInfo[5],1,30),    oFont06) 	//(19)
oPrint:say ( 0470, 2750, aInfo[6]		       ,    oFont06) 	//(20)
oPrint:say ( 0470, 2950, substr(aInfo[13],1,30),	oFont06) 	//(21)
oPrint:say ( 0470, 1850, cIdRepleg				,	oFont07) 	//(22)
oPrint:say ( 0470, 2170, cDocRepleg				,	oFont07) 	//(23)

// Detalle ---------
oPrint:say ( 0485, 0050, Replicate("-",155), oFont10)

oPrint:say ( 0575, 0050, STR0008,	oFont07)	//"ITEM"
oPrint:say ( 0575, 0140, STR0009,	oFont07)	//"TIPO"
oPrint:say ( 0575, 0210, STR0010, 	oFont07)	//"NUMERO"
oPrint:say ( 0575, 0360, "EXT.",	oFont07)	//"EXT"
oPrint:say ( 0575, 0430, "NUA/CUA",	oFont07)	//"NUA/CUA"

oPrint:say ( 0555, 0600, "APELLIDO", 	oFont07)
oPrint:say ( 0595, 0600, "PATERNO" ,	oFont07)
oPrint:say ( 0555, 0800, "APELLIDO", 	oFont07)
oPrint:say ( 0595, 0800, "MATERNO" ,	oFont07)
oPrint:say ( 0555, 1000, "APELLIDO", 	oFont07)
oPrint:say ( 0595, 1000, "CASADA"  , 	oFont07)

oPrint:say ( 0555, 1200, "PRIMER", 	oFont07)	//"PRIMER NOMBRE"
oPrint:say ( 0595, 1200, "NOMBRE",	oFont07)	//"PRIMER NOMBRE"

oPrint:say ( 0555, 1400, "SEGUNDO", oFont07)	//"SEGUNDO NOMBRE"
oPrint:say ( 0595, 1400, "NOMBRE", 	 oFont07)	//"SEGUNDO NOMBRE"

oPrint:say ( 0575, 1600, "DEPARTARMENTO",	oFont07)	//"DEPARTAMENTO"
oPrint:say ( 0575, 1830, "NOVEDAD", 	    oFont06)	//"I/R/L/S"
//oPrint:say ( 0595, 1850, "L/S",		oFont07)	    //"I/R/L/S"

oPrint:say ( 0555, 1960, STR0015,	oFont06)	//"FECH-NOVEDAD" STR0015
oPrint:say ( 0595, 1960, STR0027,	oFont06)	//"FECH-NOVEDAD" STR0015
oPrint:say ( 0555, 2100, STR0016,	oFont06)	//"DIAS" STR0016
oPrint:say ( 0595, 2100, STR0028,	oFont06)	//"COTIZ." STR0028
oPrint:say ( 0515, 2260, STR0018,	oFont06)	//"TOTAL GANADO"
oPrint:say ( 0555, 2250, STR0019,	oFont06) 	//"SOLIDARIO SIN"
oPrint:say ( 0595, 2250, STR0022,  oFont06)    //"CONSIDERAR TOP"
oPrint:say ( 0635, 2290, STR0032,  oFont06)    //"DE 60 SMN"
oPrint:say ( 0545, 2560, STR0018,	oFont06) 	//"TOTAL GANADO"
oPrint:say ( 0585, 2530, STR0020,  oFont06)    //"SOLIDARIO MENOS"
oPrint:say ( 0625, 2570, STR0021 + Transform(nVPriVal, "999999.99"),	oFont06)  	//"COTATIZACIำN (22)"
oPrint:say ( 0545, 2860, STR0018,	oFont06) 	//"TOTAL GANADO"
oPrint:say ( 0585, 2840, STR0020,  oFont06)    //"SOLIDARIO MENOS"
oPrint:say ( 0625, 2870, STR0021 + Transform(nVSegVal, "999999.99"),	oFont06) 	//"COTATIZACIำN (23)"
oPrint:say ( 0545, 3190, STR0018,	oFont06) 	//"TOTAL GANADO"
oPrint:say ( 0585, 3170, STR0020,  oFont06)    //"SOLIDARIO MENOS"
oPrint:say ( 0625, 3200, STR0021 + Transform(nVTerVal, "999999.99"), 	oFont06) 	//"COTATIZACIำN (24)"

oPrint:say ( 0650, 0050, Replicate("-",155), oFont10)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpInfFuncบAutor  ณErika Kanamori      บ Data ณ  03/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpInfFunc(nLin)

Local cApelPat	:= SubStr((cAliasSra)->RA_PRISOBR,1,15)
Local cApelMat	:= SubStr((cAliasSra)->RA_SECSOBR,1,15)
Local cApelCas	:= SubStr((cAliasSra)->RA_APELIDO,1,15)
Local cPriNom	:= SubStr((cAliasSra)->RA_PRINOME,1,15)
Local cSegNom	:= SubStr((cAliasSra)->RA_SECNOME,1,15)

oPrint:say( nLin, 0050, Transform(nFunc,"99999"),			oFont06)	//ITEM
oPrint:say( nLin, 0140, cTipoCI,							oFont06)	//"TIPO"
oPrint:say( nLin, 0210, (cAliasSra)->RA_RG,				oFont06)	//"NUMERO"
oPrint:say( nLin, 0360, (cAliasSra)->RA_NATURAL,			oFont06)	//"EXT"
oPrint:say( nLin, 0430, cNumNua,							oFont06)	//"NUA/CUA"

oPrint:say( nLin, 0600, cApelPat,							oFont06)	//"APELLIDO PATERNO"
oPrint:say( nLin, 0800, cApelMat,							oFont06)	//"APELLIDO MATERNO"
oPrint:say( nLin, 1000, cApelCas,							oFont06)	//"APELLIDO DE CASADA"
oPrint:say( nLin, 1200, cPriNom,							oFont06)	//"PRIMEIRO NOME"
oPrint:say( nLin, 1400, cSegNom,							oFont06)	//"SEGUNDO NOME"

oPrint:say( nLin, 1600, SubStr(aInfo[5],1,10),				oFont06)	//"DEPARTAMENTO"

oPrint:say( nLin, 1850, cIRLS, 								oFont06)	//"I/R/L/S"
oPrint:say( nLin, 1960, cFechNovedad, 						oFont06)	//"FECH-NOVEDAD"
oPrint:say( nLin, 2120, Transform(nQtdDias,"99"), 			oFont06)	//"DIAS-COT"

oPrint:say( nLin, 2280, Transform(nVCol21, "999,999.99"),	oFont06)	//Tot. Gan. Solidario sin Considerar Top 60 SMN
If nVCol24 >= 0
  oPrint:say(nLin, 2550, Transform(nVCol24, "999,999.99"),	oFont06)	//Tot. Gan. Solidario menos Bs. 13000
EndIf
If nVCol23 >= 0
  oPrint:say(nLin, 2890, Transform(nVCol23, "999,999.99"),	oFont06)	//Tot. Gan. Solidario menos Bs. 25000
EndIf
If nVCol22 >= 0
  oPrint:say(nLin, 3200, Transform(nVCol22, "999,999.99"),	oFont06)	//Tot. Gan. Solidario menos Bs. 35000
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpRodape บAutor  ณErika Kanamori      บ Data ณ  03/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpRodape(nLin)

// Imprime el total de asegurados
oPrint:say ( 0370, 0650, Transform(nFunc,"99999"),	oFont07)		//(5)

nLin+= 30

oPrint:say ( nLin, 0050, STR0029+Transform(nFunc, "99999"), oFont08) //"TOTAL GENERAL: "
oPrint:say ( nLin, 2230, Transform(nCol21Tot, "99,999,999.99"), oFont07)
oPrint:say ( nLin, 2500, Transform(nCol24Tot, "99,999,999.99"), oFont07)
oPrint:say ( nLin, 2840, Transform(nCol23Tot, "99,999,999.99"), oFont07)
oPrint:say ( nLin, 3150, Transform(nCol22Tot, "99,999,999.99"), oFont07)

oPrint:Endpage()

Return

/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณ ValidDic  		ณAutorณMarcelo Silveira   ณ Data ณ12/01/2012ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณValidacao de Dicionarios Atualizados por UPDATE             ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ< Vide Parametros Formais >									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Uso      ณGPER715                                                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Retorno  ณaRotina														ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ< Vide Parametros Formais >									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static Function fValDic()

	Local aAreaSX3	:= SX3->( GetArea() )
	Local lRet		:= .T.

	dbSelectArea("SX3")
	dbSetOrder(2)

    IF SX3->(!dbSeek("RA_NRNUA"))
		Aviso(OemToAnsi(STR0031), OemToAnsi(STR0030), {"OK"})	//"Atencao!"##"Antes de prosseguir, ้ necessแrio executar a atualiza็ใo 'Cแlculo de Cota Sindical - Portugal', disponํvel para o m๓dulo SIGAGPE no compatibilizador RHUPDMOD."
    	lRet := .F.
	Else
	    If SX3->(!dbSeek("R8_DTBLEG")) .Or. SX3->(!dbSeek("RCM_TPIMSS")) .or. SX3->(!dbSeek("R8_RESINC"))
			Aviso(OemToAnsi(STR0031), OemToAnsi(STR0033), {"OK"})	//"Antes de continuar, es necesario ejecutar la actualizacion '229' disponible para el modulo SIGAGPE en el compatibilizador RHUPDMOD."
    		lRet := .F.
    	Endif
	Endif

	RestArea(aAreaSX3)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfBuscaDesc บAutor ณTiago Malta         บ Data ณ  03/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que busca valores do acumulado                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fBuscaDesc( cFil , cMat ,  cPer , cRot )

Local cQuery	:= ""
Local cAliasSRD := ""

	cAliasSRD 	:= "QrySRD"
	cQuery 		:= "SELECT RD_DATARQ, RD_MAT,RD_PD, RD_VALOR, RD_HORAS"
	cQuery 		+= "FROM "	+ RetSqlName( "SRD" )	+ " SRD1 "
	cQuery 		+= "Where RD_FILIAL	= '"	+ cFil	+"' "
	cQuery 		+= "AND   RD_MAT	= '"	+ cMat	+"' "
	cQuery 		+= "AND   RD_PERIODO= '"	+ cPer	+"' "
	cQuery 		+= "AND   RD_ROTEIR	IN ("	+ cRot  +") "

	If TcSrvType() == "AS/400"
		cQuery += "AND SRD1.@DELETED@ = ' ' "
	Else
		cQuery += "AND SRD1.D_E_L_E_T_ = ' ' "
	Endif
	IF Select(cAliasSRD) > 0
		(cAliasSRD)->( dbCloseArea() )
	Endif
	cQuery 		:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD)

	dbSelectArea(cAliasSRD)
	(cAliasSRD)->(dbgotop())

Return(cAliasSRD)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณConvQry   บAutor  ณMicrosiga           บ Data ณ  27/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrio ณConvertir a expreci๓n sql un campo informado con un listbox ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ   ConvQry(cExp,cExp1)                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ    cExp: Cadena de caracteres que retorna el litbox        ณฑฑ
ฑฑณ          ณ    cExp1: Campo del diccionario de datos                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ  GPEM005COS                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ConvQry(cLista,cCampo)
Local cTxt:=''
Local nTamReg := TamSX3(cCampo)[1]
Local nCont:=0
/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGenera texto para usar  para usar despues en Query             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
cLista:=alltrim(cLista)


For nCont := 1 To Len( cLista ) Step nTamReg
    cTxt+="'"+SubStr( cLista , nCont , nTamReg )+"',"
NEXT
cTxt:=substr(cTxt,1,len(cTxt)-1)
Return ( cTxt )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณfBuscaAutrzณ Autor ณ A.Shibao      		ณ Data ณ 17.09.13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna os afastamentos de acordo com a data de autorizacaoณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                    					 	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ fBuscaAutrz												  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Genrico 												  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fBuscaAutrz(cFil, cMat ,  dDtaini, dDtafim, cAnoMes )

Local cAliasAnt  := Alias()
Local cQuery8	:= ""
Local cAliasSr8	 := "SR8"
Local cDtaIni	:= dtos(dDtaini)
Local cDtaFim	:= dtos(dDtafim)

Static cFilSrm

DEFAULT cFilSrm	 := FwxFilial("RCM")

	cAliasSr8 	:= "QrySR8"
	cQuery8 	:= "SELECT * "
	cQuery8 	+= "FROM "+RetSqlName("SR8")+" SR8 "
	cQuery8 	+= "WHERE SR8.R8_FILIAL='"+(cAliasSra)->RA_FILIAL+"' AND "
	cQuery8 	+= "SR8.R8_MAT='"+(cAliasSra)->RA_MAT+"' AND "
//	cQuery8 	+= "SR8.R8_DTBLEG BETWEEN '" + cDtaIni + "' AND '" + cDtaFim + "'"
	cQuery8 	+= " SR8.D_E_L_E_T_ = ' ' "
	cQuery8 	+= "ORDER BY "+SqlOrder(SR8->(IndexKey()))

	If Select(cAliasSr8) > 0
		(cAliasSr8)->( dbCloseArea() )
	Endif

	cQuery8 		:= ChangeQuery(cQuery8)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery8),cAliasSr8)



	dbSelectArea(cAliasSr8)
	(cAliasSr8)->(dbgotop())

	dbSelectArea( "SR8" )
	dbSeek( (cAliasSra)->RA_FILIAL + (cAliasSra)->RA_MAT)


	While !Eof() .And. (cAliasSr8)->( R8_FILIAL + R8_MAT ) = (cAliasSra)->( RA_FILIAL + RA_MAT )

        DbSelectArea( "RCM" )
        DbSetOrder( RetOrder( "RCM", "RCM_FILIAL+RCM_TIPO" ) )
        DbSeek( cFilSrm + (cAliasSr8)->R8_TIPOAFA, .F. )

        If RCM->RCM_TPIMSS $ "C/A/P"
		/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		  | La clave para hacer la busca en las ausencias es el campo R8_DTBLEG, el importante es la  |
		  | fecha en el mes selecionado. Ej: caso tenga una ausencia con fecha inicio y fecha fin     |
		  | dentro del mes 02, pero la fecha de autori. es en mes 03, esa ausencia debera salir en el |
		  | 03.																						  ณ
		  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
    		If (cAliasSr8)->R8_DTBLEG >= Dtos(dDtaini) .And. (cAliasSr8)->R8_DTBLEG <= Dtos(dDtaFim)
	           	// Qdo la Ausencia esta com fecha anterior al mes buscado informa el primero dia del mes
	           	If (cAliasSr8)->R8_DATAINI < DtoS(dDtaini)
				 	cFechNovedad:= DtoC(dDtaini)
				 	nQtdDias    := 30
		           	cIRLS		:= "S"
		 		Else
		 			cFechNovedad:= DtoC(dDtaini)
					nQtdDias    := 30 - (day(dDtaini))
		           	cIRLS		:="S"
				Endif
	        Endif
	    Else//verifica se posui Ausencia No Remunerada durante todo el periodo pesquisado
	    	   	If RCM->RCM_TPIMSS == "L"
	        			If (cAliasSr8)->R8_DATAFIM >= DtoS(dDtafim) .And. (cAliasSr8)->R8_DATAINI <= DtoS(dDtaini)
	        				cIRLS		:="L"
						 	cFechNovedad:= DtoC(dDtaini)
						 	nQtdDias	:= ""
						EndIf
	         	EndIf
	    Endif

	dbSelectArea(cAliasSr8)
	dbSkip()

	Enddo

	If Select(cAliasSr8) > 0
	 	(cAliasSr8)->( dbCloseArea() )
	Endif


	If !EMPTY(cAliasAnt)
		dbSelectArea(cAliasAnt)
	EndIf

	Return()
