#INCLUDE "plsa772.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TCBROWSE.CH"
#Include "RwMake.ch"
#Include "MsOle.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define CRLF	Chr(13) + Chr(10)
#define WDFORMATPDF    "17" // Formato PDF

STATIC cWebFam	:= "" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ PLSA772 ณ Autor ณ Totvs                  ณ Data ณ 15.05.13 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Rotina para gera็ใo de Declara็ใo de Quita็ใo Anual de     ณฑฑฑ
ฑฑณ          ณ D้bitos.                                                   ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณSintaxe   ณ PLSA772()                                                  ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Uso      ณ PLS                                                        ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Alteracoes desde sua construcao inicial.                              ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Data     ณ BOPS ณ Programador ณ Breve Descricao                       ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ          ณ      ณ             ณ                                       ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSA772()

Local cPerg := "PLA772"
Local aParam := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ajusta perguntas                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CriaSX1(cPerg,1)

If !Pergunte(cPerg,.T.)
	Return(.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros cadastrais                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aParam := { mv_par01,    mv_par02,    mv_par03,    mv_par04,    mv_par05,     mv_par06,;
            mv_par07,    mv_par08,    mv_par09,    mv_par10,    mv_par11==1,  mv_par12==1,;
            mv_par13==1 } 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Executa funcao que ira bloquear os contratos...                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Processa( {|| A772Acao(aParam) }, STR0001) // "Processando..."

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A772Acao บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a acao da rotina                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A772Acao(aParam, lPortal, cWebOut)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis dos parametros...                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nTpCont	:= 0
Local cIntDe	:= ""
Local cIntAte	:= ""
Local cGruDe	:= ""
Local cGruAte	:= ""
Local cConDe	:= ""
Local cConAte	:= ""
Local cSubDe	:= ""
Local cSubAte	:= ""
Local cAnoRef	:= ""
Local lSoQuit	:= .F.
Local lImpVal	:= .T.
Local nTpAcao	:= 1

Local lUsaDot	:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis locais...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRet      := {.F.,'',''}
Local lAllPaid  := .T.
Local nRecBA3   := BA3->( Recno() )
Local aRetFin   := {}
Local aGrupoFin := {}
Local aLinMark  := {}
Local aCabSA1   := {}
Local aCpoAdic  := {}
Local cCpoBrw   := ""
Local nI        := 0
Local nGrupo    := 0

Default lPortal := .F.
Default cWebOut := ""
//Atribuir o valor das variแveis aqui, pois se vem do remote, nใo hแ lPortal
// e o Default nใo pode ser declarado antes das variแveis Locais
If lPortal
	nTpcont 	:= val(aParam[01])
	cIntDe		:= PLSINTPAD()
	cIntAte		:= PLSINTPAD()
	cGruDe		:= aParam[02]
	cGruAte		:= aParam[02]
	cConDe		:= aParam[03]
	cConAte		:= aParam[03]
	cSubDe		:= aParam[04]
	cSubAte		:= aParam[04]
	cAnoRef		:= aParam[06]
	lSoQuit		:= .T.
	lImpVal		:= .T.
	nTpAcao		:= 1
	lUsaDot 	:= .F.
	cWebFam		:= AllTrim(aParam[05])
else
	nTpCont		:= aParam[01]
	cIntDe		:= aParam[02]
	cIntAte		:= aParam[03]
	cGruDe		:= aParam[04]
	cGruAte		:= aParam[05]
	cConDe		:= aParam[06]
	cConAte		:= aParam[07]
	cSubDe		:= aParam[08]
	cSubAte		:= aParam[09]
	cAnoRef		:= aParam[10]
	lSoQuit		:= aParam[11]
	lImpVal		:= aParam[12]
	nTpAcao		:= 1	
	lUsaDot 	:= aParam[13] 
	
EndIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define ordem default no arquivo de contas a receber...              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRetFin := PLA772FIN(nTpCont,cIntDe,cIntAte,cGruDe,cGruAte,cConDe,cConAte,cSubDe,cSubAte,cAnoRef,lSoQuit,lPortal)

If nTpAcao == 1 // Gera Declaracao de Quita็ใo Anual de Debitos
	For nGrupo:= 1 To Len(aRetFin)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona na familia pelo primeiro registro do Grupo...             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nTpCont == 1
			BA3->(DbSetOrder(1))   // BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
			If !BA3->( dbSeek(xFilial("BA3")+aRetFin[nGrupo,01,01]+aRetFin[nGrupo,01,02]+aRetFin[nGrupo,01,03]) )
				Loop
			EndIf
 		Else
			If aRetFin[nGrupo,01,10] $ '4/5' // Nivel dae Cobran็a
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		  		//ณ Pessoa Juridica com nivel na Familia, mas gravou apenas                      ณ
		  		//ณ BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC                                  ณ
		  		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		 		BA3->(DbSetOrder(1))   // BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
				If !BA3->( dbSeek(xFilial("BA3")+aRetFin[nGrupo,01,01]+aRetFin[nGrupo,01,02]+aRetFin[nGrupo,01,03]) )
					Loop
				EndIf		
			ElseIf aRetFin[nGrupo,01,10] $ '3' // Nivel dae Cobran็a Subcontrato
		  		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		  		//ณ Pessoa Juridica com nivel de subcontrato para cima e gravou                  ณ
		  		//ณ BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONeEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUBณ
		  		//ณ sem a matricula                                                              ณ
		  		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	 		
	 			BA3->(DbSetOrder(7))   // BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_MATRIC
				If !BA3->( dbSeek(xFilial("BA3")+aRetFin[nGrupo,01,01]+aRetFin[nGrupo,01,02]+aRetFin[nGrupo,01,04]+ ;
							aRetFin[nGrupo,01,05]+aRetFin[nGrupo,01,06]+aRetFin[nGrupo,01,07]) ) // Nunca uso a Matricula do SE1 pois nunca ้ gravado neste sentido.
					Loop
				EndIf
			ElseIf aRetFin[nGrupo,01,10] $ '2' // Nivel dae Cobran็a Contrato	 		
	 			BA3->(DbSetOrder(7))   // BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_MATRIC
				If !BA3->( dbSeek(xFilial("BA3")+aRetFin[nGrupo,01,01]+aRetFin[nGrupo,01,02]+aRetFin[nGrupo,01,04]+ ;
							aRetFin[nGrupo,01,05]) )
					Loop
				EndIf
			ElseIf aRetFin[nGrupo,01,10] $ '1' // Nivel dae Cobran็a Empresa		
	 			BA3->(DbSetOrder(7))   // BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_MATRIC
				If !BA3->( dbSeek(xFilial("BA3")+aRetFin[nGrupo,01,01]+aRetFin[nGrupo,01,02]) )
					Loop
				EndIf
			EndIf
 		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ IncProc                                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !lPortal
			IncProc( Transform(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB),"@R !.!!!.!!!!.!!!!!!.!!!!!!!!!!!!!!!.!!!!!!!!!!!!" ) ) // "CHAVE-"
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona o titular da familia...                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BA1->(DbSetOrder(2))
		BA1->( dbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona o grupo empresa...                                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BG9->(DbSetOrder(1))
		BG9->(DbSeek(xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP))
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciono o contrato...                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nTpCont == 2 .AND. !Empty(BA3->BA3_CONEMP)
			BT5->( dbSetorder(01) )
			BT5->( dbSeek(xFilial("BT5")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON) )
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciono o sub contrato...                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nTpCont == 2 .AND. !Empty(BA3->BA3_SUBCON)
			BQC->( dbSetorder(01) )
			BQC->( dbSeek(xFilial("BT5")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB) )
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Ajusta o Cliente para quando for alterado o cadastro apos a geracao ณ
		//ณ dos titulos, atualize corretamente...                               ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aGrupoFin := PLAjusCli(aRetFin[nGrupo])
      		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Avalia se todas as parcelas no periodo estใo quitadas.              ณ
		//ณ Apresenta ao usuario do sistema os pagadores que tem todos debitos  ณ
		//ณ quitados ou se o usuแrio selecionou a opcao "So Quitado" como NAO.  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lAllPaid := PA772Paid(aGrupoFin)		
		If lAllPaid .OR. !lSoQuit
			If LEN(aGrupoFin) > 0
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Posiciona no primeiro cliente de cobran็a do grupo...               ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1")+aGrupoFin[01,08]+aGrupoFin[01,09]))
				
				aAdd( aLinMark, ;
				{ ; 
					IIF( SA1->(A1_PESSOA=="F"),BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)), ;    //01
					SA1->(A1_COD), ;                                                                           //02
					SA1->(A1_LOJA), ;                                                                          //03
					SA1->(A1_NOME), ;                                                                          //04
					SA1->(A1_EST), ;                                                                           //05
					SA1->(A1_MUN), ;                                                                           //06
					SA1->(A1_CGC), ;                                                                           //07
					IIF( SA1->(A1_PESSOA=="F"),"FISICA",IIF(LEN(AllTrim(SA1->(A1_CGC)))<=11,"FISICA","JURIDICA") ), ; //08
					IIF(lAllPaid,"SIM","NรO"), ;                                                             	//09
					aGrupoFin, ;                                                                              	//10
					BA3->(Recno()), ;                                                                        	//11
					.F. ;                                                                                     	//12
				} )							
				aCpoAdic := {{"Todos Quitados","C"}}	
			EndIf
		
		EndIf

	Next nGrupo
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abre MarkBrowse para escolha da impressใo dos Clientes...           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTpAcao == 1	// Gera Declaracao de Quita็ใo Anual de Debitos
	If Len(aLinMark) > 0 .AND. !lPortal
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Carrega tabela BA1                                                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cCpoBrw := "A1_COD    ,A1_LOJA   ,A1_NOME   ,A1_PESSOA ,A1_EST    ,A1_MUN    ,A1_CGC    " // Nao retirar os espacos
		Store Header "SA1" TO aCabSA1 For ( AllTrim(SX3->X3_CAMPO) $ cCpoBrw )
		aCabSA1 := fAddCBrw(aCabSA1,aCpoAdic,cCpoBrw)
		aRet := MarkBPag(aLinMark,aCabSA1,nTpAcao,cAnoRef,lImpVal,020,015,040,015,490,175, lPortal, cWebOut, lUsaDot)
	ElseIf lPortal

		cCpoBrw := "A1_COD    ,A1_LOJA   ,A1_NOME   ,A1_PESSOA ,A1_EST    ,A1_MUN    ,A1_CGC    " // Nao retirar os espacos
		Store Header "SA1" TO aCabSA1 For ( AllTrim(SX3->X3_CAMPO) $ cCpoBrw )
		aCabSA1 := fAddCBrw(aCabSA1,aCpoAdic,cCpoBrw)
		aRet := MarkBPag(aLinMark,aCabSA1,nTpAcao,cAnoRef,lImpVal,020,015,040,015,490,175, lPortal, cWebOut, lUsaDot)
	Else
		MsgAlert(STR0003) // "Nใo encontrado tํtulos pelo filtro selecionado !!!"
	EndIf
EndIf

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLA772FIN บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se usuario tem movimentacao no financeiro em      บฑฑ
ฑฑบ          ณ atraso.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLA772FIN(nTpCont,cIntDe,cIntAte,cGruDe,cGruAte,cConDe,cConAte,cSubDe,cSubAte,cAnoRef,lSoQuit, lPortal)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis da rotina...                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
LOCAL aRet      := {}
LOCAL aAux      := {}
LOCAL aRetDatas := fDtIniFim(cAnoRef)

LOCAL cChvAnte	:= ""
LOCAL cChvAtua	:= ""
LOCAL cSql		:= ""
LOCAL cAlias	:= GetNextAlias()

Default lPortal := .F.

cSql := "SELECT " + CRLF	
cSql += "	SE1.E1_CODINT, SE1.E1_CODEMP, SE1.E1_MATRIC, SE1.E1_CONEMP, SE1.E1_VERCON, SE1.E1_SUBCON, SE1.E1_VERSUB, SE1.E1_CLIENTE, " + CRLF
cSql += "	SE1.E1_LOJA, BBT.BBT_NIVEL, SE1.E1_EMISSAO, SE1.E1_VENCREA, SE1.E1_SALDO,  SE1.E1_VALOR,  SE1.E1_STATUS " + CRLF
cSql += "FROM "+ RetSqlName("SE1") +" SE1 " + CRLF

cSql += "	LEFT JOIN "+ RetSqlName("BBT") +" BBT " + CRLF
cSql += "	ON    BBT.BBT_FILIAL	   = '"+ xFilial("BBT") +"' " + CRLF
cSql += "	AND BBT.BBT_CODOPE      = SE1.E1_CODINT " + CRLF
cSql += "	AND BBT.BBT_CODEMP      = SE1.E1_CODEMP " + CRLF
cSql += "	AND BBT.BBT_CONEMP      = SE1.E1_CONEMP " + CRLF
cSql += "	AND BBT.BBT_VERCON      = SE1.E1_VERCON " + CRLF
cSql += "	AND BBT.BBT_SUBCON      = SE1.E1_SUBCON " + CRLF
cSql += "	AND BBT.BBT_VERSUB      = SE1.E1_VERSUB " + CRLF
cSql += "	AND BBT.BBT_MATRIC      = SE1.E1_MATRIC " + CRLF
cSql += "	AND BBT.BBT_PREFIX      = SE1.E1_PREFIXO " + CRLF
cSql += "	AND BBT.BBT_NUMTIT      = SE1.E1_NUM " + CRLF
cSql += "	AND BBT.BBT_PARCEL      = SE1.E1_PARCELA " + CRLF
cSql += "	AND BBT.BBT_TIPTIT      = SE1.E1_TIPO " + CRLF
cSql += "	AND BBT.D_E_L_E_T_      = ' ' " + CRLF

cSql += "	LEFT JOIN "+ RetSqlName("BG9") +" BG9 " + CRLF
cSql += "		ON BG9.BG9_FILIAL = '"+ xFilial("BG9") +"' " + CRLF
cSql += "		AND BG9.BG9_CODINT = SE1.E1_CODINT " + CRLF 
cSql += "		AND BG9.BG9_CODIGO = SE1.E1_CODEMP " + CRLF
If nTpCont == 2
	cSql += "		AND BG9.BG9_TIPO = '"+ IIF (nTpCont == 1,"1","2") +"' "
Endif	
cSql += "		AND BG9.D_E_L_E_T_ = ' ' " + CRLF

cSql += "WHERE" + CRLF
cSql += "	SE1.D_E_L_E_T_ = ' ' "   + CRLF
cSql += "	AND SE1.E1_FILIAL  = '"  + xFilial("SE1") + "' " + CRLF
cSql += "	AND SE1.E1_CODINT >= '"  + cIntDe  + "' " + CRLF
cSql += "	AND SE1.E1_CODINT <= '"  + cIntAte + "' " + CRLF
cSql += "	AND SE1.E1_CODEMP >= '"  + cGruDe  + "' " + CRLF
cSql += "	AND SE1.E1_CODEMP <= '"  + cGruAte + "' " + CRLF
cSql += "	AND SE1.E1_VENCREA >= '" + DToS(aRetDatas[1]) + "' " + CRLF
cSql += "	AND SE1.E1_VENCREA <= '" + DToS(aRetDatas[2]) + "' " + CRLF

If nTpCont == 1
	// Somente para Pessoa Fisica
	cSql += "	AND SE1.E1_MATRIC  =  '"+SUBSTR(cWebFam,9,6) +"' " + CRLF
ElseIf nTpCont == 2
	// Somente para Pessoa Juridica
	cSql += "	AND ("
	cSql += "  		(SE1.E1_CONEMP =  '"   + Space(TamSx3("E1_CONEMP")[1]) +"' " 	+ CRLF
	cSql += " 		AND SE1.E1_SUBCON =  '"+ Space(TamSx3("E1_SUBCON")[1]) +"' " 	+ CRLF
	cSql += "  		AND SE1.E1_MATRIC =  '"+ Space(TamSx3("E1_MATRIC")[1]) +"' "	+ CRLF
	cSql += "  		AND BBT.BBT_NIVEL <= '1') " 												+ CRLF
	cSql += "  		OR "	 																			+ CRLF
	cSql += "  		(SE1.E1_CONEMP >= '"   + cConDe  +"' " 								+ CRLF
	cSql += "  		AND SE1.E1_CONEMP <= '"+ cConAte +"' " 								+ CRLF
	cSql += " 		AND SE1.E1_SUBCON =  '"+ Space(TamSx3("E1_SUBCON")[1]) +"' " 	+ CRLF
	cSql += "  		AND SE1.E1_MATRIC =  '"+ Space(TamSx3("E1_MATRIC")[1]) +"' "	+ CRLF
	cSql += "  		AND BBT.BBT_NIVEL <= '2') " 												+ CRLF
	cSql += "  		OR "	 																			+ CRLF
	cSql += "  		(SE1.E1_CONEMP >= '"   + cConDe  +"' " 								+ CRLF
	cSql += "  		AND SE1.E1_CONEMP <= '"+ cConAte +"' " 								+ CRLF
	cSql += " 		AND SE1.E1_SUBCON >= '"+ cSubDe  +"' " 			  					+ CRLF
	cSql += " 		AND SE1.E1_SUBCON <= '"+ cSubAte +"' " 			  					+ CRLF
	cSql += "  		AND SE1.E1_MATRIC =  '"+ Space(TamSx3("E1_MATRIC")[1]) +"' "	+ CRLF
	cSql += "  		AND BBT.BBT_NIVEL <= '3') " 												+ CRLF
	cSql += "  		OR "	 											  								+ CRLF
	cSql += " 		(SE1.E1_CONEMP = '"    + Space(TamSx3("E1_CONEMP")[1]) +"' "	+ CRLF
	cSql += " 		AND SE1.E1_VERCON  = '"+ Space(TamSx3("E1_VERCON")[1]) +"' " 	+ CRLF
	cSql += "		AND SE1.E1_SUBCON  = '"+ Space(TamSx3("E1_SUBCON")[1]) +"' " 	+ CRLF
	cSql += "		AND SE1.E1_VERSUB  = '"+ Space(TamSx3("E1_VERSUB")[1]) +"' " 	+ CRLF
	cSql += "		AND SE1.E1_MATRIC <> '"+ Space(TamSx3("E1_MATRIC")[1]) +"' " 	+ CRLF
	cSql += "		AND BBT.BBT_NIVEL >= '4') "
	cSql += "	) "
EndIf

cSql += "ORDER BY SE1.E1_CODINT,SE1.E1_CODEMP,SE1.E1_MATRIC,SE1.E1_CONEMP,SE1.E1_VERCON,SE1.E1_SUBCON,SE1.E1_VERSUB,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_VENCREA  "

If ExistBlock("PL772QRY")
	cSql := ExecBlock("PL772QRY",.F.,.F.,{cSql, nTpCont,cIntDe,cIntAte,cGruDe,cGruAte,cConDe,cConAte,cSubDe,cSubAte,aRetDatas})
Endif

cSql := ChangeQuery(cSql)

DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , cAlias , .F. , .T. )

DBSelectArea(cAlias)
(cAlias)->(DBGoTop())

While (cAlias)->(!Eof())
	cChvAtua :=	(cAlias)->E1_CODINT + ;
					(cAlias)->E1_CODEMP + ;
					(cAlias)->E1_MATRIC + ;
					(cAlias)->E1_CONEMP + ;
					(cAlias)->E1_VERCON + ;
					(cAlias)->E1_SUBCON + ;
					(cAlias)->E1_VERSUB
	If cChvAtua <> cChvAnte
		If Len(aAux) <> 0
			aAdd(aRet,aAux) // Guardo o Auxiliar Anterior e gero nova.
			aAux := {}
			aAdd(aAux,{ ;
				(cAlias)->E1_CODINT,    (cAlias)->E1_CODEMP,          (cAlias)->E1_MATRIC,			;
				(cAlias)->E1_CONEMP,    (cAlias)->E1_VERCON,          (cAlias)->E1_SUBCON,			;
				(cAlias)->E1_VERSUB,    (cAlias)->E1_CLIENTE,         (cAlias)->E1_LOJA,				;
				(cAlias)->BBT_NIVEL,    SToD((cAlias)->E1_EMISSAO),   SToD((cAlias)->E1_VENCREA),	;
				(cAlias)->E1_SALDO,     (cAlias)->E1_VALOR,           (cAlias)->E1_STATUS				;
			})
		Else
			aAdd(aAux,{ ;
				(cAlias)->E1_CODINT,    (cAlias)->E1_CODEMP,          (cAlias)->E1_MATRIC,			;
				(cAlias)->E1_CONEMP,    (cAlias)->E1_VERCON,          (cAlias)->E1_SUBCON,			;
				(cAlias)->E1_VERSUB,    (cAlias)->E1_CLIENTE,         (cAlias)->E1_LOJA,				;
				(cAlias)->BBT_NIVEL,    SToD((cAlias)->E1_EMISSAO),   SToD((cAlias)->E1_VENCREA),	;
				(cAlias)->E1_SALDO,     (cAlias)->E1_VALOR,           (cAlias)->E1_STATUS				;
			})
		EndIf
		cChvAnte :=	cChvAtua
	Else
		aAdd(aAux,{ ;
			(cAlias)->E1_CODINT,    (cAlias)->E1_CODEMP,          (cAlias)->E1_MATRIC,			;
			(cAlias)->E1_CONEMP,    (cAlias)->E1_VERCON,          (cAlias)->E1_SUBCON,			;
			(cAlias)->E1_VERSUB,    (cAlias)->E1_CLIENTE,         (cAlias)->E1_LOJA,				;
			(cAlias)->BBT_NIVEL,    SToD((cAlias)->E1_EMISSAO),   SToD((cAlias)->E1_VENCREA),	;
			(cAlias)->E1_SALDO,     (cAlias)->E1_VALOR,           (cAlias)->E1_STATUS				;
		})
	EndIf
	
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(DbCloseArea())

If Len(aAux) <> 0
	aAdd(aRet,aAux) // Guardo o ultimo auxiliar Restante
EndIf

Return(aRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDtIniFim บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna Data Inicial e Data Final de um Ano especํfico     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fDtIniFim(cAnoRef)

Local dDtIni := CToD("01/01/"+cAnoRef)
Local dDtFim := CToD("31/12/"+cAnoRef)

Return({dDtIni,dDtFim})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPA772Paid บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Avalia se todas as parcelas no periodo estใo quitadas.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PA772Paid(aDadosFin)

Local lRet := .T.
Local nFor := 0

For nFor := 1 To Len(aDadosFin)
	//   E1_SALDO                       E1_VALOR                      E1_STATUS
	If !(aDadosFin[nFor,13] == 0 .AND. aDadosFin[nFor,14] > 0 .AND. aDadosFin[nFor,15] == "B")
		lRet := .F.
		Exit
	EndIf
Next nFor

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLAjusCli บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o Cliente do array para quando for alterado o cadas_บฑฑ
ฑฑบ          ณ tro ap๓s a geracao dos titulos, atualize corretamente...   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLAjusCli(aGrpFin)

Local nFor := 0

For nFor := 1 To LEN(aGrpFin)
	If aGrpFin[nFor,10] == "1"
		aGrpFin[nFor,08] := BG9->BG9_CODCLI // Cliente
		aGrpFin[nFor,09] := BG9->BG9_LOJA   // Loja
	Elseif aGrpFin[nFor,10] == "2"
		aGrpFin[nFor,08] := BT5->BT5_CODCLI // Cliente
		aGrpFin[nFor,09] := BT5->BT5_LOJA   // Loja
	Elseif aGrpFin[nFor,10] == "3"
		aGrpFin[nFor,08] := BQC->BQC_CODCLI // Cliente
		aGrpFin[nFor,09] := BQC->BQC_LOJA   // Loja
	Elseif aGrpFin[nFor,10] == "4"
		aGrpFin[nFor,08] := BA3->BA3_CODCLI // Cliente
		aGrpFin[nFor,09] := BA3->BA3_LOJA   // Loja		
	Elseif aGrpFin[nFor,10] == "5"
		aGrpFin[nFor,08] := BA1->BA1_CODCLI // Cliente
		aGrpFin[nFor,09] := BA1->BA1_LOJA   // Loja	
	EndIf
Next nFor

Return(aGrpFin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MarkBPag บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apresenta o MarkBrowse                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MarkBPag(aLinha,aCabecalho,nTpAcao,cAnoRef,lImpVal,nCheLi,nCheCo,nPosLI,nPosCI,nPosCF,nPosLF, lPortal, cWebOut, lUsaDot)

	Static objCENFUNLGP := CENFUNLGP():New()

Local nFor     := 0
Local nOpca    := 0
Local nQtdSel  := 0
Local bOK      := { || nOpca := 1, oDlg:End() }
Local bCancel  := { || nOpca := 0, oDlg:End() }
Local aSels    := {}
Local aRet     := {.F.,'',''}
Local lCheck   := .T. 
Local bBlock
Local oCheck
Local oDlg
Local cTitulo	:= FunDesc() // "Declara็ใo Anual de D้bitos"
LOCAL aCampos	:= {}

PRIVATE oLista 
 
Default lPortal := .F.
Default lUsaDot := .T.

If !lPortal
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define dialogo...                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 030,020 TO 060 ,150 OF GetWndDefault()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Checkbox para marcar e desmarcar todos                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ nCheLi,nCheCo CHECKBOX oCheck VAR lCheck PROMPT STR0005 OF oDlg SIZE 100,8 // "Marca e Desmarca todos"
	oCheck:bChange := {|| MsAguarde( {|| MarcaLinha('',aLinha,lCheck),oLista:Refresh() } ) }   

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta o TcBrowse                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oLista := TcBrowse():New( nPosLI,nPosCI,nPosCF,nPosLF,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona o BitMap de marcado e desmarcado                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	add COLUMN To oLista BitMap Data { || LoadBitMap( GetResources(), Iif(!aLinha[oLista:nAt,Len(aLinha[oLista:nAt])] ,EVal({|| lCheck := .F.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 NOHILITE ALIGN CENTERED
	aadd(aCampos , .F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega o cabecalho                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nFor := 1 to Len(aCabecalho)
	     bBlock := "{ || aLinha[oLista:nAt, "+Str(nFor,4)+"] }"
	     bBlock := &bBlock
		 aadd(aCampos , aCabecalho[nFor,2])
	     oLista:AddColumn(TcColumn():New(aCabecalho[nFor,1],bBlock,aCabecalho[nFor,3],Nil,Nil,Nil,IiF(Len(aCabecalho[nFor,1]) > aCabecalho[nFor,4],Len(aCabecalho[nFor,1])*3.6,aCabecalho[nFor,4]*3.6),.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	Next

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oLista:aObfuscatedCols := aBls
	endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega os dados                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oLista:SetArray(aLinha)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Duploclick na linha                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    oLista:BLDBLCLICK := { || MarcaLinha(oLista:nAt,aLinha,lCheck) , oLista:Refresh() }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ativa a dialogo...                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER
EndIf

If IIF( lPortal, .T., nOpca = K_OK) 
	aSels := {}
	For nFor := 1 to Len(aLinha)	
		If aLinha[nFor,(Len(aCabecalho)+3)] .OR. (lPortal .AND. AllTrim(aLinha[nFor][1]) == cWebFam)	//LINHA MARCADA
			nQtdSel += 1
		EndIf
	Next nFor
	   
	If nQtdSel > 0	//Selecionada
		
		If nTpAcao == 1
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Impressใo das Declara็ใo(๕es) de Quita็ใo Anual de D้bitos...       ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If IIF(lPortal, .T., MsgYesNo(AllTrim(Str(nQtdSel)) + "  " + STR0006)) // "Declara็ใo(๕es) de Quita็ใo Anual de D้bitos serแ(ใo) gerado(s). Confirma ?"
				For nFor := 1 to Len(aLinha)				
					If aLinha[nFor,(Len(aCabecalho)+3)] .OR. (lPortal .AND. AllTrim(aLinha[nFor][1]) == cWebFam)	// Linha marcada
						
//						BA0->( DbSelectArea("BA0") )
						BA0->( DbSetOrder(1) )
						If ( BA0->( MsSeek(xFilial("BA0") + SUBSTR( aLinha[nFor,01],1,Len(BA3->(BA3_CODINT)) ))) )
						// Recno - NomeCli - AnoRef - CPFCNPJ - Pessoa - ArrayFinanceiro - ArrayOperadora - AllPaid
						aAdd(aSels,{aLinha[nFor,LEN(aLinha[nFor])-1],aLinha[nFor,04],cAnoRef,aLinha[nFor,07],aLinha[nFor,08], ;
							aLinha[nFor,10],{ BA0->(BA0_NOMINT),BA0->(BA0_CIDADE),BA0->(BA0_EST) },aLinha[nFor,09]})
					EndIf
					EndIf
				Next nFor
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava o Registro...                                                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				aRet := PL772Decl(aSels,lImpVal, lPortal, cWebOut, lUsaDot)
			EndIf
		EndIf
	ElseIf !lPortal
		MsgAlert(STR0007) // "Nenhum registro foi selecionado !!!"
	Else
		cArqName := ""
	EndIf

EndIf

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fAddCBrw บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta os campos que serใo apresentados no MarkBrowse      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fAddCBrw(aCabSA1,aCpoAdic,cCpoBrw)

Local nFor 		:= 0
Local nTamIni	:= 0
Local aCabAux	:= {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Exclui campos do Browse nใo necessใrios...                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
For nFor := 1 To Len(aCabSA1)
	If aCabSA1[nFor,2] $ cCpoBrw
		aAdd( aCabAux,aCabSA1[nFor])
	EndIf
Next nFor 
aCabSA1 := aCabAux

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ordena os Campos do Brawse...                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
aCabAux := {}

aAdd( aCabAux,aCabSA1[Ascan(aCabSA1,{ |x| AllTrim(x[2]) == "A1_COD"})   ])
aAdd( aCabAux,aCabSA1[Ascan(aCabSA1,{ |x| AllTrim(x[2]) == "A1_LOJA"})  ])
aAdd( aCabAux,aCabSA1[Ascan(aCabSA1,{ |x| AllTrim(x[2]) == "A1_NOME"})  ])
aAdd( aCabAux,aCabSA1[Ascan(aCabSA1,{ |x| AllTrim(x[2]) == "A1_EST"})   ])
aAdd( aCabAux,aCabSA1[Ascan(aCabSA1,{ |x| AllTrim(x[2]) == "A1_MUN"})   ])
aAdd( aCabAux,aCabSA1[Ascan(aCabSA1,{ |x| AllTrim(x[2]) == "A1_CGC"})   ])
aAdd( aCabAux,aCabSA1[Ascan(aCabSA1,{ |x| AllTrim(x[2]) == "A1_PESSOA"})])
aCabSA1 := aCabAux

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona campo no inํcio do Browse...                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCabAux := {}
aAdd( aCabAux, {STR0008,"","@!",17,00,"","€€€€€€€€€€€€€€ ","C",NIL,""}) // "Matrํcula"
For nFor := 1 To Len(aCabSA1)
	aAdd( aCabAux,aCabSA1[nFor])
Next nFor
aCabSA1 := aCabAux

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona campos no final do Browse...                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTamIni	:= Len(aCabSA1)
For nFor := 1 To Len(aCpoAdic)
	aAdd( aCabSA1, {"","","@!",10,00,"","€€€€€€€€€€€€€€ ","C",NIL,""})

	aCabSA1[nFor+nTamIni,01] := aCpoAdic[nFor,01]
	aCabSA1[nFor+nTamIni,04] := IIf(aCpoAdic[nFor,02] == "N",17,10)
	aCabSA1[nFor+nTamIni,05] := IIf(aCpoAdic[nFor,02] == "N",02,00)
	aCabSA1[nFor+nTamIni,08] := aCpoAdic[nFor,02]
Next nFor

Return(aCabSA1)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaSX1  บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta grupo de perguntas na tabela SX1                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CriaSX1(cPerg,nTipo)

Local aRegs	:=	{}

If nTipo == 1
	aAdd(aRegs, { cPerg,"01","Tipo Contrato ?               ","","","mv_ch1","C",01,0,0,"C","        ","mv_par01","Pessoa Fisica  ","","","","","Pessoa Jurํdica","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})
	aAdd(aRegs, { cPerg,"02","Operadora De                  ","","","mv_ch2","C",04,0,0,"G","        ","mv_par02","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B89PLS","N","",""})
	aAdd(aRegs, { cPerg,"03","Operadora Ate                 ","","","mv_ch3","C",04,0,0,"G","        ","mv_par03","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B89PLS","N","",""})
	aAdd(aRegs, { cPerg,"04","Grupo/Empresa De              ","","","mv_ch4","C",04,0,0,"G","        ","mv_par04","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7APLS","N","",""})
	aAdd(aRegs, { cPerg,"05","Grupo/Empresa Ate             ","","","mv_ch5","C",04,0,0,"G","        ","mv_par05","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7APLS","N","",""})
	aAdd(aRegs, { cPerg,"06","Contrato De                   ","","","mv_ch6","C",12,0,0,"G","        ","mv_par06","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7BPLS","N","",""})
	aAdd(aRegs, { cPerg,"07","Contrato Ate                  ","","","mv_ch7","C",12,0,0,"G","        ","mv_par07","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7BPLS","N","",""})
	aAdd(aRegs, { cPerg,"08","Sub-Contrato De               ","","","mv_ch8","C",09,0,0,"G","        ","mv_par08","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7CPLS","N","",""})
	aAdd(aRegs, { cPerg,"09","Sub-Contrato Ate              ","","","mv_ch9","C",09,0,0,"G","        ","mv_par09","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7CPLS","N","",""})	
	aAdd(aRegs, { cPerg,"10","Ano de Referencia ?           ","","","mv_cha","C",04,0,2,"G","naovazio","mv_par10","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})
	aAdd(aRegs, { cPerg,"11","Considera Apenas D้bitos Quit.","","","mv_chb","N",01,0,0,"C","        ","mv_par11","Sim            ","","","","","Nao            ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})	
	aAdd(aRegs, { cPerg,"12","Especifica Parcelas e Valores?","","","mv_chc","N",01,0,0,"C","        ","mv_par12","Sim            ","","","","","Nao            ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})
	aAdd(aRegs, { cPerg,"13","Gerar .dot?						","","","mv_chd","N",01,0,0,"C","        ","mv_par13","Sim            ","","","","","Nao            ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})
EndIf

PlsVldPerg( aRegs )
    
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL772Decl บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao das Declaracao de Quita็ใo Anual de Debitos      บฑฑ
ฑฑบ          ณ Via Microsoft Word                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function PL772Decl(aSels,lImpVal, lPortal, cWebOut, lUsaDot)

Local nI			:= 0
Local lCopy1		:= .F.
Local lCopy2		:= .F.
Local aProc			:= {.F.,'',''}
Local cArqAgl		:= ""
Local cMensag		:= ""
Local cPathTMP		:= ""
Local cPathArq		:= GetNewPar( "MV_PLDIDOT" , "\DOT" ) // Define o local de origem dos arquivos de modelo .DOT dentro da pasta system que serใo utilizados pelo SIGAPLS.
Local aProc			:= {.F.,'',''}

Private aWord		:= {}
Private hWord		:= Nil
Private nConDoc	:= 0
Private cArqDot	:= ""
Private cPathEst	:= GetNewPar( "MV_PLDIRDQ" , "C:\TEMP_DECL_DEBITO" ) // Path onde serao gravados os arquivos DOT na estacao de trabalho referentes แ Declaracao de Quita็ใo de D้bitos.

Default lPortal := .F.
Default cWebOut := ""
Default lUsaDot := .T.

If lUsaDot //Caso imprima pelo modelo .DOT
	If Empty(cPathArq)
		cPathArq := GetSrvProfString("StartPath", "")
	Else
		If !(Substr(cPathArq,1,1) == "\" .OR. Substr(cPathArq,1,1) == "/")
			cPathTMP := GetSrvProfString("StartPath", "")
			cPathArq := IIF( Substr(cPathTMP,Len(cPathTMP),1) $ "\/", cPathTMP, cPathTMP+"\" ) + cPathArq
		EndIf
	EndIf
	cPathArq := IIF( Substr(cPathArq,Len(cPathArq),1) $ "\/", cPathArq, cPathArq+"\" )
	
	If Empty(cPathEst)
		cPathEst := GetTempPath()
	EndIf
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Inicia a Integracao com o Word                                          บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	cArqDot  := "Declaracao_Anual_Debito.dot"
	cArqAgl  := "Declaracao_Anual_Debitos.dot"
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Se nao for alterado via parametro procura o arquivo na pasta "system"   บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	cPathDot := cPathArq + cArqDot
	cPathAgl := cPathArq + cArqAgl
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Verifica a Existencia dos Arquivos DOT no StartPath do Protheus         บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	If !File(cPathDot)
		Aviso( STR0009,STR0010 +CRLF+ cPathDot +CRLF+ STR0011,{"Fechar"} ) //"Aten็ใo" , "O arquivo de Configura็ใo:" , "nao foi encontrado pelo Servidor!!!"
		Return()
	EndIf
	
	If !File(cPathAgl)
		Aviso( STR0009,STR0010 +CRLF+ cPathAgl +CRLF+ STR0011,{"Fechar"} ) //"Aten็ใo" , "O arquivo de Configura็ใo:" , "nao foi encontrado pelo Servidor!!!"
		Return()
	EndIf
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Verifica Path do Temporแrio para grava็ใo na Estacao de Trabalho        บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	If Substr(cPathEst,1,1) == "\" .OR. Substr(cPathEst,1,1) == "/"
		cMensag := STR0012 +CRLF+ cPathEst +CRLF+ STR0013 +CRLF+ GetTempPath() //"Nใo foi validado o diret๓rio temporแrio da Esta็ใo:" , "Os arquivos temporแrios serใo gravados no diret๓rio:"
		Aviso( STR0009 , cMensag , {"Fechar"} ) // "Aten็ใo"
		cPathEst := GetTempPath()
	EndIf
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Verifica Path para Armazenamento na Estacao de Trabalho                 บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	MontaDir( cPathEst )
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Se ja existir arquivos no local, apaga para a nova geracao              บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	If File( Lower( cPathEst + "\" + cArqDot ) )
		Ferase( Lower( cPathEst + "\" + cArqDot ) )
	EndIf
	
	If File( Lower( cPathEst + "\" + cArqAgl ) )
		Ferase( Lower( cPathEst + "\" + cArqAgl ) )
	EndIf
	
	If File( Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ) )
		Ferase( Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ) )
	EndIf
EndIf

If !lPortal .AND. lUsaDot
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Faz a copia dos arquivos do Servidor para o Remote                      บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	lCopy1 := CpyS2T( cPathDot , cPathEst , .F. )
	lCopy2 := CpyS2T( cPathAgl , cPathEst , .F. )
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Verifica as Copias                                                      บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	If !lCopy1 .Or. !lCopy2
		Aviso( STR0014 , STR0015 + CRLF + cPathDot + CRLF + cPathEst , {"Fechar"} ) //"Processamento Cancelado" , "Houve um problema com a c๓pia dos arquivos de configura็ao:"
		Return()
	EndIf

	Processa( {|| aProc := GeraWord(aSels,lImpVal, lPortal, cWebOut, lUsaDot)} , STR0016 , STR0017 , .F. ) //"Iniciando o processamento..." , "Aguarde"
	
else

	aProc := GeraWord(aSels, lImpVal, .T., cWebOut, .F.)
	
EndIf

If  aProc[1] .AND. lUsaDot

	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Fecha os Documentos                                                     บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	For nI := 1 to nConDoc
		OLE_CloseFile( aWord[nConDoc] )
		OLE_CloseLink( aWord[nConDoc] )
	Next nI
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Cria Documento Unico para aglutinar os resultados                       บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	hWord := OLE_CreateLink()
	OLE_NewFile( hWord , cPathEst + "\" + cArqAgl )
	OLE_SetPropertie( hWord, oleWdVisible, .F. )
	
	OLE_SetDocumentVar(hWord , 'nQtArqs' , nConDoc )
	OLE_SetDocumentVar(hWord , 'nomeArquivo' , "\ImpCarta" )
	OLE_SetDocumentVar(hWord , 'pastaDocs' , cPathEst )
	
	OLE_UpdateFields( hWord )
	OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument )
	
	OLE_ExecuteMacro( hWord , "JuntaTudo" )
	OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument )
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Pergunta se imprime os resultados                                       บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	If MsgYesNo(STR0018+ AllTrim(Str(nConDoc)) +"."+ CRLF +STR0019) .AND. !lPortal// "Total de Declara็๕es Anual de D้bitos: " , "Deseja Imprimir o Arquivo ?"
		OLE_PrintFile( hWord , "PART" , 2 , nConDoc + 1 , 1 )
		Aviso( STR0009 , STR0020 , {"Ok"} ) // "Aten็ใo" , "Arquivo enviado para impressao..."
	Endif

	OLE_CloseFile( hWord )		// Fecha ultimo arquivo
	OLE_CloseLink( hWord )		// Fecha link com Word
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Apaga os Arquivos Temporarios                                           บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	For nI := 1 to nConDoc
		If File( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
//			FErase( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
		EndIf
	Next
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Exclui os Arquivos Temporarios apos a utilizacao.                       บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	If File( Lower( cPathEst + "\" + cArqDot ) )
		Ferase( Lower( cPathEst + "\" + cArqDot ) )
	EndIf
	
	If File( Lower( cPathEst + "\" + cArqAgl ) )
		Ferase( Lower( cPathEst + "\" + cArqAgl ) )
	EndIf
		
EndIf

Return(aProc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraWord บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que gera a pagina a ser impressa atraves do modelo. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GeraWord(aSels,lImpVal, lPortal, cWebOut, lUsaDot)

Local nFor		:= 0
Local cFilLog  	:= "PLS_DECLAR_DEBITO.LOG"
Local aRetGrv	:={.F.,'',''}

Default lPortal := .F.
Default lUsaDot := .T.

For nFor := 1 to Len(aSels)
	if !(lPortal) .AND. lUsaDot
		CriaNovo()
		ZeraCar()
	EndIf
	//Recno - NomeCli - AnoRef - CPFCNPJ - Pessoa - ArrayFinanceiro - ArrayOperadora - AllPaid
	aRetGrv := GravaCar( aSels[nFor,02], aSels[nFor,03], AllTrim(aSels[nFor,04]), aSels[nFor,05], IIF(lImpVal,aSels[nFor,06],{}), aSels[nFor,07], lPortal, nFor, lUsaDot, cWebOut )
	If ValType(aRetGrv) =='A' .and. Len(aRetGrv)>0
		If aRetGrv[1]
			PlsLogFil("PLSA772 - "	+ ;
				"Ano Ref:["			+ aSels[nFor,3] 			+"] - "+ ;
				"Data:["			+ DtoC(date())				+"] - "+ ;
				"Hora:["			+ Time() 		  			+"] - "+ ;
				"Cliente:["			+ aSels[nFor,6,1,08]+"-"+aSels[nFor,06,01,09]+"/"+aSels[nFor,02] +"] - "+ ;
				"CPF/CNPJ:["		+ aSels[nFor,4] 			+"] - "+ ;
				"Nivel:["			+ aSels[nFor,6,1,10] 		+"] - "+ ;
				"Chave:["			+ aSels[nFor,6,1,01]+aSels[nFor,6,1,02]+aSels[nFor,6,1,03]+aSels[nFor,6,1,04]+aSels[nFor,6,1,05]+aSels[nFor,6,1,06]+aSels[nFor,6,1,07]+"] " ; 
			,cFilLog)
		EndIf
	Endif
	if lUsaDot
		OLE_CloseFile( aWord[nConDoc] )
		OLE_CloseLink( aWord[nConDoc] )
	EndIF
	
Next nFor
PlsLogFil("",cFilLog)

Return aRetGrv

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaCar บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que grava os dados da Consulta na Carta.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function GravaCar( cNomeCli, cAnoRef, cCPFCNPJ, cPessoa, aFinan, aOperadora, lPortal, nI, lUsaDot, cWebOut )

Local aDados	:= Array(10)
Local cReferen	:= ""
Local cRefCNPJ 	:= ""
Local cTelCen	:= GetNewPar( "MV_PLSRTCA" , "" )	// Define o Telefone da Central de Atendimento a ser utilizado na impressใo de cartas do SIGAPLS
Local nFor
Local aArqLocal := {.T.,'',''}

Default lPortal := .F.
Default nI		  := 1
Default lUsaDot := .T.

cReferen := IIF(cPessoa=="FISICA", "Ao Sr.(a) ","ม Empresa ")
cRefCNPJ := IIF(cPessoa=="FISICA", "CPF/MF sob o nบ ","CNPJ/MF sob o nบ ")
cCPFCNPJ := IIF(cPessoa=="FISICA", Transform(cCPFCNPJ, "@R 999.999.999-99"), Transform(cCPFCNPJ, "@R 99.999.999/9999-99" ) )

aDados[01] := IIf( Empty(aOperadora[02])     ,"[Erro ao identificar a Operadora]"  ,AllTrim(aOperadora[02]) )
aDados[02] := IIf( Empty(aOperadora[03])     ,"[Erro ao identificar a Operadora]"  ,AllTrim(aOperadora[03]) )
aDados[03] := StrZero(Day(Date()),2) +" de "+ MesExtenso( Month(Date()))  +" de "+  Str(Year(Date()),4)
aDados[04] := IIf( Empty(cNomeCli)           ,"[Erro ao identificar o Nome]"       ,AllTrim(cNomeCli) )
aDados[05] := IIf( Empty(cNomeCli)           ,"[Erro ao identificar o Nome]"       ,cReferen + AllTrim(cNomeCli) )
aDados[06] := IIf( Empty(cCPFCNPJ)           ,"[Erro ao identificar o CPF/CNPJ]"   ,cRefCNPJ + cCPFCNPJ )
aDados[07] := IIf( Empty(cAnoRef)            ,"[Erro ao identificar o Ano]"        ,AllTrim(cAnoRef) )
aDados[08] := IIf( Empty(cTelCen)            ,"0800-000.0000"                      ,AllTrim(cTelCen) )
aDados[09] := IIf( Empty(aFinan)             ," "                                  ,"VENCTO:	VALOR:		SALDO:		SITUAวรO:" )
aDados[10] := IIf( Empty(aOperadora[01])     ,"[Erro ao identificar a Operadora]"  ,AllTrim(aOperadora[01]) )

if !(lPortal) .AND. lUsaDot
	OLE_SetDocumentVar( aWord[nConDoc], "MUNOPE"     ,aDados[01] )
	OLE_SetDocumentVar( aWord[nConDoc], "UFOPE"      ,aDados[02] )
	OLE_SetDocumentVar( aWord[nConDoc], "DATA"       ,aDados[03] )
	OLE_SetDocumentVar( aWord[nConDoc], "NOMECLI"    ,aDados[04] )
	OLE_SetDocumentVar( aWord[nConDoc], "NOMEREF"    ,aDados[05] )
	OLE_SetDocumentVar( aWord[nConDoc], "CPFCNPJ"    ,aDados[06] )
	OLE_SetDocumentVar( aWord[nConDoc], "ANOREF"     ,aDados[07] )
	OLE_SetDocumentVar( aWord[nConDoc], "TELCENTRAL" ,aDados[08] )
	OLE_SetDocumentVar( aWord[nConDoc], "CABECALHO"  ,aDados[09] )
	OLE_SetDocumentVar( aWord[nConDoc], "NOMEOPE"    ,aDados[10] )
	
	For nFor := 1 To LEN(aFinan)
		If nFor <= 20
			OLE_SetDocumentVar( aWord[nConDoc], "VENC" + STRZERO(nFor,02), DToC(aFinan[nFor,12]) )
			OLE_SetDocumentVar( aWord[nConDoc], "VAL"  + STRZERO(nFor,02), Transform(aFinan[nFor,14], "@E 999,999,999.99") )
			OLE_SetDocumentVar( aWord[nConDoc], "SALD" + STRZERO(nFor,02), Transform(aFinan[nFor,13], "@E 999,999,999.99") )
			OLE_SetDocumentVar( aWord[nConDoc], "STAT" + STRZERO(nFor,02), IIF(aFinan[nFor,15]=="B",STR0021,STR0022) ) //"TITULO PAGO" , "EM ABERTO"
		EndIf
	Next nFor
	
	OLE_UpdateFields( aWord[nConDoc] )
EndIf

if lPortal .OR. !(lUsaDot)

	If ExistBlock( "PLSQTDEB" ) //Ponto de entrada de usuแrio para customizar o relat๓rio --> Procure pelo fonte PLSRQUITDB
		aArqLocal := ExecBlock( "PLSQTDEB", .F., .F., {nI, lPortal, aDados, aFinan, cWebOut} )
	Else
		MsgAlert(STR0023 /*'A User Function PLSQTDEB, do RdMake PLSRQUITDB nใo estแ no RPO, por isso a funcionalidade estแ indisponํvel.'*/ + CRLF + ;
				STR0024 /*'Possibilidades para solu็ใo:'*/ + CRLF + CRLF +;
				STR0025 /*'- Utilizar a impressใo com o modelo .DOT'*/ + CRLF +;
				STR0026 /*'- Compilar a User Function PLSQTDEB'*/, STR0009 /*'Aten็ใo'*/)
	EndIF
else
	OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".DOC" ,,, .F. , oleWdFormatDocument )
EndIf

Return(aArqLocal)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ZeraCar  บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Zera os controladores para geracao de nova Carta.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ZeraCar()

Local nFor := 0

OLE_SetDocumentVar( aWord[nConDoc], "MUNOPE"     , "" )
OLE_SetDocumentVar( aWord[nConDoc], "UFOPE"      , "" )
OLE_SetDocumentVar( aWord[nConDoc], "DATA"       , "" )
OLE_SetDocumentVar( aWord[nConDoc], "NOMECLI"    , "" )
OLE_SetDocumentVar( aWord[nConDoc], "NOMEREF"    , "" )
OLE_SetDocumentVar( aWord[nConDoc], "CPFCNPJ"    , "" )
OLE_SetDocumentVar( aWord[nConDoc], "ANOREF"     , "" )
OLE_SetDocumentVar( aWord[nConDoc], "TELCENTRAL" , "" )
OLE_SetDocumentVar( aWord[nConDoc], "CABECALHO"  , "" )
OLE_SetDocumentVar( aWord[nConDoc], "NOMEOPE"    , "" )

For nFor := 1 To 20
	OLE_SetDocumentVar( aWord[nConDoc], "VENC" + STRZERO(nFor,02), "" )
	OLE_SetDocumentVar( aWord[nConDoc], "VAL"  + STRZERO(nFor,02), "" )
	OLE_SetDocumentVar( aWord[nConDoc], "SALD" + STRZERO(nFor,02), "" )
	OLE_SetDocumentVar( aWord[nConDoc], "STAT" + STRZERO(nFor,02), "" )
Next nFor

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaNovo บ Autor ณ Totvs              บ Data ณ 15/05/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o novo arquivo para gravacao.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function CriaNovo()

aAdd( aWord , 0 )
nConDoc++

aWord[nConDoc] := OLE_CreateLink()

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Cria o novo arquivo no Remote                                           บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_NewFile( aWord[nConDoc] , cPathEst + "\" + cArqDot )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Ajusta Propriedades do Arquivo                                          บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_SetPropertie( aWord[nConDoc] , oleWdVisible , .F. )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Salva o arquivo com o novo nome no Remote                               บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".doc" ,,, .F. , oleWdFormatDocument )

Return()
