#INCLUDE "CTBS002.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "ECD.CH"

//Compatibiliza็ใo de fontes 30/05/2018

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWizarValid 	 บAutor  ณElton C. Santana	  บ Data ณ  25/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o controle de pagina ao voltar, apoดs ser efetuado a 	   บฑฑ
ฑฑบ          ณPr้ Valida็ใo                                               	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  		                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBS002(cEmp, cFil)
Local 	cEmpVld		:= cEmp
Local 	aPerg		:= ParamPerguntas()[1]
Local 	aResp		:= ParamPerguntas()[2]

Private oWzrdValid	:= Nil 
Private aHeaderErr	:= {}
Private aErrEcd 	:= {{STR0014}}
Private oErr		:= Nil

Default cEmp		:= ""
Default cFil		:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o aheader de Erro ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeaderErr 				:= Array(NUM_COL_ERR)
aHeaderErr[ERRO_DESC]	:= STR0014

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem da Interface                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// P1
DEFINE WIZARD oWzrdValid;
	TITLE STR0001 + cEmp; //"Assistente de Importa็ใo de Dados de Escritura็ใo Contแbil - Empresa: "
	HEADER STR0002;		 //"Aten็ใo"
	MESSAGE STR0003 ; //"Pr้-valida็ใo dos principais cadastros"
	TEXT STR0004 ; //"Essa rotina tem como objetivo efetuar a Pr้-valida็ใo dos principais cadastros das filiais desta empresa"
	NEXT {|| .T.} ;
	FINISH {||.T.}

// P2       
CREATE PANEL oWzrdValid  ;
	HEADER STR0005+CRLF+STR0006; //"Informe neste passo, a data inicial e final da escritura็ใo."###"Clique em avan็ar para iniciar a pr้-valida็ใo"
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| PreValidacao(cEmpVld,aPerg,aResp,cFil)};
	PANEL                                                                                           

	ParamBox(aPerg,"", @aResp,,,,,,oWzrdValid:GetPanel(2)) 

// P3
CREATE PANEL oWzrdValid  ;
	HEADER "";
	MESSAGE STR0007; //"Resultado da pr้-valida็ใo"
	BACK {|| .T.} ;
	NEXT {|| PreValidNext(,.T.)} ;
	PANEL
	
	@ 030,010 SAY STR0008 SIZE 270,020 PIXEL OF oWzrdValid:GetPanel(3) //"Nenhum erro encontrato..."

// P4
CREATE PANEL oWzrdValid  ;
	HEADER "";
	MESSAGE STR0007; //"Resultado da pr้-valida็ใo"
	BACK {|| PreValidBack()} ;
	NEXT {|| .T. } ;
	PANEL
	
	oErr := TWBrowse():New( 0.5, 0.5 , 280, 100,Nil,aHeaderErr, Nil, oWzrdValid:GetPanel(4), Nil, Nil, Nil,Nil )      
	oErr:SetArray( aErrEcd ) 
    oErr:bLine := {||{aErrEcd[oErr:nAt,ERRO_DESC]}}
	
	@ 110,005 BUTTON STR0009 SIZE 070,010 ACTION {|| Processa({||ImpErroECD(aErrEcd)})} PIXEL OF oWzrdValid:GetPanel(4) WHEN .T. //"Imprim. Erro"
	
// P5
CREATE PANEL oWzrdValid  ;
	HEADER "";
	MESSAGE STR0010; //"Finaliza็ใo"
	BACK {|| PreValidBack()} ;
	FINISH {|| .T.} ;
	PANEL
	
	@ 030,010 SAY STR0011 SIZE 270,020 PIXEL OF oWzrdValid:GetPanel(5) //"Processo de pr้-valida็ใo efetuado com sucesso..."
	
ACTIVATE WIZARD oWzrdValid CENTERED 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPreValidacao บAutor  ณElton da C. Santana บ Data ณ28/01/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a pr้valida็ใo da escritura็ใo, dos principais camposบฑฑ
ฑฑบ          ณ                        									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PreValidacao(cEmp,aPerg,aResp,cFil)

Local aEmp	:= GetEmpEcd( cEmp )
Local lRet		:= .F.
Local oProcess	:= Nil //indicador de processamento. 

Default aPerg	:= {}
Default aResp	:= {}
Default cFil	:= "" 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEfetua a valida็ใo da data inicial e final, .T. OU .F.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValidaParam(aPerg,aResp)
 
	lRet := .T.

	aErrEcd := RetPreValid(oProcess, aResp[1], aResp[2], aResp[3], aResp[4], aResp[5])
	IF Len( aErrEcd ) <= 0
		aErrEcd:= {{STR0014}}
	Endif

	If oErr <> Nil
		oErr:SetArray( aErrEcd )
		oErr:bLine := {||{aErrEcd[oErr:nAt][ERRO_DESC]}}
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFun็ใo utilizada para apresentar o painel correto,		 ณ
	//ณde acordo com o resultado da valida็ใo da base de dados 	 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PreValidNext()
EndIf


Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณRetPreValid บAutor  ณElton da C. Santana บ Data ณ10/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณPreenche o array com as mensagens de Erro e Advertencia	  บฑฑ
ฑฑบ          ณ                        									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetPreValid(oProcess,dDataIni,dDataFim,cCalend,cContaIni,cContaFim)

Local aPreVld := {}
Local aResVld := {}
Local nX	  := 0
Local nY	  := 0

DEFAULT dDataIni 	:= cTod(" / / ")
DEFAULT dDataFim 	:= cTod(" / / ")
DEFAULT cContaIni 	:= Space(20)
DEFAULT cContaFim 	:= Replicate( "Z" , 20 )                       

oProcess:= MsNewProcess():New( {|| aPreVld := PreValdEcd(oProcess,dDataIni,dDataFim,cCalend,cContaIni,cContaFim)} )
oProcess:Activate()

If !Empty(aPreVld)
	For nX := 1 To Len(aPreVld) 
		Aadd(aResVld ,Array(ERRO_DESC) )
		aResVld[Len(aResVld)][ERRO_DESC] := aPreVld[nX]
	Next
EndIf  

Return aResVld  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpErroECD     บAutor  ณElton C. Santana	  บ Data ณ  03/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o controle de pagina ao voltar, apoดs ser efetuado a 	   บฑฑ
ฑฑบ          ณPr้ Valida็ใo                                               	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  		                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpErroECD(aErrEcd)

Local aConoutr	:= {}
Local nX		:= 0
If Len(aErrEcd)>= 1.And. aErrEcd[1][1]!= STR0014
	For nX := 1 To Len(aErrEcd)
	    aAdd(aConoutr,aErrEcd[nX][1])
	Next 
	CtRConOut(aConoutr)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPreValidBack 	 บAutor  ณElton C. Santana	  บ Data ณ  03/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o controle de pagina ao voltar, apoดs ser efetuado a 	   บฑฑ
ฑฑบ          ณPr้ Valida็ใo                                               	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  		                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PreValidBack(nPos)

Local lRet	:= .T.
Default nPos := oWzrdValid:nPanel
//oErr:Refresh()
nPos++

If Len(aErrEcd)>= 1.And. aErrEcd[1][1]!= STR0014
	nPos := 2
Else
	nPos := 3
EndIf

oWzrdValid:nPanel := nPos + 1

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPreValidNext 	 บAutor  ณElton C. Santana	  บ Data ณ03/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o controle de pagina ao avan็ar, apoดs ser efetuado a   บฑฑ
ฑฑบ          ณPr้ Valida็ใo                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  		                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PreValidNext(nPos,lFim)

Local lRet	:= .T.
Default nPos := oWzrdValid:nPanel
Default lFim    := .F.

nPos++

If lFim
	nPos := 5
ElseIf Len(aErrEcd)>= 1 .And. aErrEcd[1][1]!= STR0014
	nPos := 4
Else
	nPos := 3
EndIf

oWzrdValid:nPanel := nPos - 1

Return lRet


Static Function ParamPerguntas()
	
Local aPerguntas := {}
Local aRespostas := {}
Local aRet		 := {}

aAdd(aPerguntas,{1,STR0012		,CTOD(""),"","","",,50,.T.}) //"Periodo Inicial da Escritura็ใo: "
aAdd(aPerguntas,{1,STR0013		,CTOD(""),"","","",,50,.T.}) //"Periodo Final da Escritura็ใo: "
aAdd(aPerguntas,{1,"Calendario"	,Space(CTG->(TamSx3("CTG_CALEND")[1])),"@!","CTG->( vazio() .or. ExistCpo('CTG') )","CTG",,03,.F.}) 
aAdd(aPerguntas,{1,"Conta De"	,Space(CT1->(TamSx3("CT1_CONTA")[1])),"@!","","CT1",,60,.F.})
aAdd(aPerguntas,{1,"Conta Ate"  ,Space(CT1->(TamSx3("CT1_CONTA")[1])),"@!","","CT1",,60,.F.})

aRespostas := {CTOD(""),CTOD(""),Space(CTG->(TamSx3("CTG_CALEND")[1])),Space(CT1->(TamSx3("CT1_CONTA")[1])),Space(CT1->(TamSx3("CT1_CONTA")[1]))}

AaDD(aRet,aPerguntas)
AaDD(aRet,aRespostas)
	
Return aRet
