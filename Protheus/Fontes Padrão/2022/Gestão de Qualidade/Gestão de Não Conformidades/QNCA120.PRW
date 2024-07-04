#include "PROTHEUS.CH"
#include "QNCA120.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QNCA120	³ Autor ³ Leandro		        ³ Data ³ 20/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Grupo de Etapas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³  			                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()
Local aRotina := { {OemToAnsi(STR0001)   , "AxPesqui", 0, 1,,.F.},;  //"Pesquisar"	
					{OemToAnsi(STR0002)   , "QN120Eta", 0, 2},; 	   //"Visualizar"	
					{OemToAnsi(STR0003)   , "QN120Eta", 0, 3},;       //"Incluir"		
					{OemToAnsi(STR0004)   , "QN120Eta", 0, 4},;       //"Alterar"		
					{OemToAnsi(STR0005)   , "QN120Eta", 0, 5, 3},;    //"Excluir"
					{OemToAnsi(STR0015)   , "q120CpEt", 0, 3}} 	   		//"Copia"

Return aRotina

Function QNCA120

Private cCadastro := OemtoAnsi(STR0006)  //"Grupo de Etapas"
Private aRotina   := MenuDef()

Private aRecList   := {}	// vetor de recursos adicionais utilizada na funcao QAlocPMS no fonte QNCXFUN

If !QNCHECK()
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"QUO")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QN120Eta ³ Autor ³ Leandro               ³ Data ³ 20/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prog.de atualizacao de Grupo de Etapas -Inclusao/Alteracao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNCA120(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QNCA120													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION QN120Eta(cAlias,nReg,nOpc)
Local nOpcA:=0  
Local oDlg
Local oFont
Local oGrupo
Local oGroup1
Local oTexto  
Local aAltera    := {} 
Local nSeq       := QA_SXESXF("QUO","QUO_GRUPO",,1)

Private oGetEtapas
Private cTexto     := "" 
Private nPosEtapa  := 0
Private nPosDEtapa := 0
Private nPosDResp  := 0
Private nPosSeq    := 0
Private nPosPRJ    := 0
Private nSaveSX8   := GetSX8Len()
Private aUsrMat	   := QNCUSUARIO()
Private cFilOrig   := aUsrMat[2]
Private cMatCod    := aUsrMat[3]
Private nPosPerc   := 0
Private cRespons   := ""
Private nPosResp   := 0
Private nPosParal  := 0	
Private nPosEtPrl  := 0	
Private nPosObrig  := 0	  
Private nPosParSeq := 0	
Private nPosResp2  := 0
Private lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) <= 2,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Private QNA120OPC  := nOpc  // variavel que sera utilizada na alocacao de recursos adicionais

RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)            	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]
Private aHeader := {}
Private aCols	:= {}

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 46,120 OF oMainWnd //"Grupo de Etapas"
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
                                                            
oGrupo  := MsMGet():New(cAlias,nReg,nOpc,,,,,{035,003,095,470},,,,,,oDlg,,.T.,,,,,,,.T.)
cWhile  := Alltrim(RetSIX("QUP","1",.T.,{"QUP_TPACAO"}))
cSeek 	:= RetSIX("QUO","1",.T.)

FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QUP",;       					// area a ser utilizada;
               	2,;      						// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpc == 3),"",&cSeek),;  	// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usuário;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpc == 3),.T.,.F.),;  	// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeadAux p/ posterior consistencia	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosSeq    := Ascan(aHeader,{|x| x[2] = "QUP_SEQUEN"})
nPosEtapa  := Ascan(aHeader,{|x| x[2] = "QUP_TPACAO"})
nPosDEtapa := Ascan(aHeader,{|x| x[2] = "QUP_DESETA"})
nPosDResp  := Ascan(aHeader,{|x| x[2] = "QUP_NOMERE"})    
nPosPRJ    := Ascan(aHeader,{|x| x[2] = "QUP_PROJET"})    
nPosPerc   := Ascan(aHeader,{|x| x[2] = "QUP_PERC"})    
cRespons   := Ascan(aHeader,{|x| x[2] = "QUP_RESP"})    
nPosResp   := Ascan(aHeader,{|x| x[2] = "QUP_RESP"})
nPosParal  := Ascan(aHeader,{|x| x[2] = "QUP_ETAPRL"})    
nPosEtPrl  := Ascan(aHeader,{|x| x[2] = "QUP_ETAPAP"})    
nPosObrig  := Ascan(aHeader,{|x| x[2] = "QUP_OBRIGA"}) 
nPosParSeq := Ascan(aHeader,{|x| x[2] = "QUP_PARSEQ"}) 
nPosTrfact := Ascan(aHeader,{|x| x[2] = "QUP_TRFACT"})
nPosResp2  := Ascan(aHeader,{|x| x[2] = "QUP_RESP2"})  // campo de recursos adicionais

QN120AfCols(aHeader,@aCols,nOpc,nSeq)

@ 095,003 GROUP oGroup1 TO 270,470	 LABEL STR0007  OF oDlg PIXEL  //"Etapa/Acoes"  
oGroup1:oFont:= oFont

oGetEtapas := MsNewGetDados():New(105,005,267,467,Iif(nOpc==3 .Or. nOpc==4, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"QNC120LOk","QNC120TOk","",,,,,,,oDlg,aHeader,aCols)
if nPosResp2 > 0 // ativa o controle de recursos adicionais caso o campo QUP_RESP2 esteja no browse
	// Projeto TDI - TEGJGS Mais de um recurso no grupo de etapas
	oGetEtapas:oBrowse:blDblClick := {|| QN120Resp() }
Endif

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela) .And. QNC120LOk() .And. QNC120TOk(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| nOpcA:=0,oDlg:End()}) CENTERED
If nOpcA==1 .and. nOpc==5
	If !ADelGrupo()//Rotina de exlusao 
		MSGAlert(STR0008)//"Este grupo nao pode ser excluido, pois existe etapas amarradas."
	Endif
Else
	If nOpcA==1 .and. nOpc<>2
		BEGIN TRANSACTION
			QN120GrvAll(nOpc)
		END TRANSACTION

		While (GetSX8Len() > nSaveSx8)
		    RollBackSX8()
		Enddo
	Endif
Endif	

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QN120AfCols ºAutor  ³Leandro             º Data ³  20/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que carrega o aHeader e aCols da GetDados.            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com o Cabecalho da GetDados				    ³±±
±±³			 ³ ExpA2 = Array com as linhas da GetDados					    ³±±
±±³			 ³ ExpN1 = Opcao selecionada								    ³±±
±±³			 ³ ExpN2 = Sequencia do Ensaio								    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ QNCA120                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QN120AfCols( aHeader, aCols, nOpc, nSeq )
Local nLinha := 0

For nLinha := 1 to Len(aCols)
	aCols[nLinha,nPosDEtapa] := Iif(!Empty(aCols[nLinha,nPosEtapa]),A120DEtapa(aCols[nLinha,nPosEtapa]),"")
Next

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QNC120LOk ³ Autor ³ Leandro		        ³ Data ³ 20/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QNCA120													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNC120LOk(o)
Local lRet     := .T.
Local nAchou   := 0
Local aCols    := oGetEtapas:aCols
Local cProcura := ""
Local cSequen  := ""
Local nDel     := Len(oGetEtapas:aHeader)+1
Local n        := oGetEtapas:nAT 
Local nTmkPms  := GetMv("MV_QTMKPMS",.F.,1) 
Local nX       := 0

If Empty(nPosEtapa) .or. Empty(nPosSeq)
	Return(.F.)
Else	
	cProcura := aCols[n,nPosEtapa]
	cSequen  := aCols[n,nPosSeq]  
Endif	
                      
If !(aCols[n,nDel])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campo Etapa esta' preenchido    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCols[n,nPosEtapa])
		Help(" ",1,"QA_CPOOBR")
		lRet:=.F.	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campo projeto esta' preenchido  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nTmkPms > 2 .AND. Empty(aCols[n,nPosPRJ])
		MsgAlert(STR0014)//"Devido à integraçaõ com o PMS, é necessário cadastrao o Projeto"
	    lRet:= .F. 
	EndIf

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a Etapa ja' existe          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAchou := Ascan(aCols,{|x| x[nPosEtapa] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			MsgAlert(STR0009)//"Etapa j'a realacionada a este Grupo"
			lRet:=.F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Etapa esta' cadastrada        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If ! ExistCpo("QID",aCols[n,nPosEtapa])
			aCols[n,nPosEtapa] := Space(TamSX3("QID_TPACAO")[1])
			lRet := .f.
		EndIf
	EndIf

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a Sequencia nao esta duplicada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAchou := Ascan(aCols,{|x| x[nPosSeq] == cSequen .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			MsgAlert(STR0010)//"Sequencia duplicada neste Grupo")
			lRet:=.F.
		EndIf
	EndIf  

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Campo Et. Paralela esta Como '1-Sim'  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCols[n][nPosParal] == "1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Campo Etapa esta Preenchido           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aCols[n][nPosEtPrl])
				MsgAlert(STR0020) //"Favor Informar a Etapa, pois o campo 'Et. Paralela' está sendo informado como Sim"
				lRet := .F.
			EndIf
	        
		EndIf
	
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QNC120TOk ³ Autor ³ Leandro               ³ Data ³ 20/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QNCA120													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNC120TOk(o)
Local nI, lRet := .t.
Local nDel     := Len(oGetEtapas:aHeader)+1
Local nTotal   := 0
Local cValPerc := GetMv("MV_QVALPER") //1-Habilita e 2-Desabilita
Local nQupRe   := Ascan(oGetEtapas:aHeader,{|x| x[2] = "QUP_RESP"})  
Local nProjet  := Ascan(oGetEtapas:aHeader,{|x| x[2] = "QUP_PROJET"}) 
Local nTmkPms  := GetMv("MV_QTMKPMS",.F.,1)

If ValType(cValPerc) == "N"
	cValPerc := AllTrim(Str(cValPerc))
EndIf

For nI := 1 to Len(oGetEtapas:aCols)
	If !oGetEtapas:acols[nI,nDel]
		If Empty(oGetEtapas:acols[nI,nQupRe])
			lRet := .F.
			MessageDlg(STR0012)//"Campo Codigo do Responsavel nao preenchido."
			Exit
		Endif  
		
		If nTmkPms > 2 .AND. Empty(oGetEtapas:acols[nI,nProjet])
			MessageDlg(STR0014)//"Devido à integraçaõ com o PMS, é necessário cadastrao o Projeto")
    		lRet:= .F. 
    		Exit
		EndIf
	
	Endif	
	
	If !oGetEtapas:acols[nI,nDel]
		nTotal := nTotal + Val(oGetEtapas:aCols[nI][nPosPerc])
	Endif	
	
Next 

If lRet 
	If nTotal == 0
		Messagedlg(STR0019) //"Nao existem etapas cadastradas e/ou todas estao deletadas."
		lRet := .f.
	Endif
Endif

If cValPerc == "1"
	If nTotal > 100 
		MsgAlert(STR0013)//"A somatoria da porcentagem de alocacao ultrapassa 100%"
		lRet := .F.
	EndIf
Endif  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada criado para validacao de permissao de usuario executar etapa - PRICE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If ExistBlock("Q120RESP")
	lRet := ExecBlock("Q120RESP",.F.,.F., {cRespons})	
EndIf

		
Return(lRet)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QN120GrvAll ºAutor  ³Leandro           º Data ³  20/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de gravação do Grupo e suas Etapas/Acoes.			  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao selecionada								  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QN120GrvAll(nOpc)       
Local nX      := 0 
Local nY      := 0
Local cVar    := ""
Local nDel    := Len(oGetEtapas:aHeader)+1
Local aCols   := oGetEtapas:aCols
Local aHeader := oGetEtapas:aHeader  
Local cChave  := "" 
Local cProdut := M->QUO_PRODUT
Local cCodQad := M->QUO_DEPTO
Local aStruQUO := FWFormStruct(3, "QUO")[3]

dbSelectArea("QUO")
dbSetOrder(1)

If nOpc <> 3
	If dbSeek(xFilial("QUO")+QUO->QUO_GRUPO)
		RecLock("QUO",.F.)
	Endif	
Else
	RecLock("QUO",.T.)
	QUO->QUO_FILIAL := xFilial("QUO")
Endif        
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os dados referentes ao Grupo     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3 .Or. nOpc == 4) //Inclusao ou Alteracao
	For nX := 1 To Len(aStruQUO)
		If GetSx3Cache(aStruQUO[nX,1], "X3_CONTEXT") <> "V"
			FieldPut(FieldPos(AllTrim(aStruQUO[nX,1])),Alltrim(&("M->"+aStruQUO[nX,1])))
		EndIf
	Next nX
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()   // Atualiza o ultimo roteiro em SX8
	Enddo
	DbSelectArea("SB1")
	DbSetOrder(1)
	If (SB1->(DbSeek(xFilial("SB1")+AllTrim(cProdut))).AND.Empty(SB1->B1_CODQAD))
		RecLock("SB1",.F.)
		SB1->B1_CODQAD := cCodQad
		SB1->(MsUnLock())
	EndIf
EndIf 


QUO->(MsUnlock())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as Etapas relacionadas ao Grupo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
For nX := 1 to Len(oGetEtapas:aCols)
	If !Empty(aCols[nX,nPosEtapa]) 
		If !Acols[nX,nDel] .and. (nOpc==3 .or. nOpc==4)
			dbSelectArea("QUP")
			dbSetOrder(1)
			If QUP->(MsSeek(xFilial("QUP")+QUO->QUO_GRUPO+aCols[nX,nPosEtapa]))         
				RecLock("QUP",.F.)   
			Else
				RecLock("QUP",.T.)   
				QUP->QUP_FILIAL := xFilial("QUP")
				QUP->QUP_GRUPO  := QUO->QUO_GRUPO
			Endif
			For nY := 1 to Len(aHeader)
				If aHeader[ny,10] # "V"
					cVar := Trim(aHeader[ny,2])
					Replace &cVar. With aCols[nx,ny]
				Endif
			Next nY
			MsUnlock() 
			dbCommit()								   		
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela a Etapa no Qup  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QUP")
			dbSetOrder(1)
			If dbSeek(xFilial("QUP") + QUP->QUP_GRUPO + aCols[nX,nPosEtapa])         
				RecLock("QUP",.F.)
				dbDelete()
				MsUnlock() 
				dbCommit()								   		
			EndIf
		EndIf
	EndIf
Next nX        
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QNC120VlEtapa³ Autor ³ Leandro            ³ Data ³ 20/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Etapa           							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNC120VlEtapa(ExpC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Etapa          						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico - E' chamada no X3_VALID do cpo. QUP_TPACAO       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNC120VlEtapa(cNEtapa)
Local lRetu  := .t., nI,	cVar := &(readvar()) 
Local nAchou := 0

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Etapa esta' cadastrada            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[n][nPosEtapa] := cNEtapa
	
	QID->(dbSetOrder(1))
	If QID->(dbSeek(xFilial("QID")+cNEtapa))
		aCols[n][nPosEtapa] := QID->QID_TPACAO
	Else
		aCols[n][nPosEtapa] := Space(2)
		lRetu := .F.
	EndIf
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Etapa ja' existe    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetu
	For nI := 1 to len(aCols)
		nAchou := Len(aCols[nI])
		If cVar == acols[nI][nPosEtapa]
			If !(aCols[nI][nAchou]).and. nI <> n
				MsgAlert(STR0011)//"Tipo de acao ja relacionada ao grupo."
				lRetu := .f. 
				Exit
			Endif	
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche a Descricao da Etapa    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetu
	aCols[n][nPosDEtapa] := A120DEtapa(aCols[n][nPosEtapa])
EndIf

Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QNC120NOME   ³ Autor ³ Leandro            ³ Data ³ 28/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche a Descricao do nome do usuario.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNC120NOME(ExpC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Usuario          						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico - E' chamada no X3_VALID do cpo. QUP_RESP         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNC120NOME(cResp)
Local lRet := .T.
DbSelectArea("QAA")
QAA->(dbSetOrder(1))
If QAA->(dbSeek(xFilial("QAA")+cResp)) 
	aCols[n][nPosDResp] := QAA->QAA_NOME
Else
	aCols[n][nPosDResp] := ""
Endif		

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A120DEtapa ³ Autor ³ Leandro			    ³ Data ³ 20/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a descricao da Etapa								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A120DEtapa(cCodEtapa)
QID->(dbSetOrder(1))
QID->(dbSeek(xFilial("QID")+cCodEtapa)) // Etapa posicionada na getdados
Return(QID->QID_DESCTP)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ADelGrupo  ³ Autor ³ Leandro			    ³ Data ³ 31/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a delecao do grupo de etapa						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ADelGrupo()
Local lRet 	  := .T.
Local cIndQI3 := ""
Local cKey    := ""
Local cQuery  := ""


//Validando se nao existe grupo agregado
dbSelectArea("QI5")
dbSetOrder(5)
If dbSeek(xFilial("QI5")+M->QUO_GRUPO)
	lRet := .F.
Endif
   cQuery := " SELECT COUNT(*) TOTAL FROM " + RetSqlName("QI3")+" QI3,"+RetSqlName('QUO')+" QUO," + RetSqlName('QI5')+" QI5 " 
   cQuery += " WHERE QI3.QI3_FILIAL = '" + xFilial('QI3') + "' "
   cQuery += " AND QI5.QI5_FILIAL = '" + xFilial('QI5') + "'"
   cQuery += " AND QUO.QUO_FILIAL = '" + xFilial('QUO') + "'"
   cQuery += " AND QI3.QI3_MODELO = '"+ M->QUO_GRUPO +"'"
   cQuery += " AND QI5.QI5_CODIGO = QI3.QI3_CODIGO"
   cQuery += " AND QI5.QI5_REV = QI3.QI3_REV"
   cQuery += " AND QI5.QI5_PROJET <> ''   
   cQuery += " AND QI3.D_E_L_E_T_ = ' ' "
   cQuery += " AND QUO.D_E_L_E_T_ = ' ' "
   cQuery += " AND QI5.D_E_L_E_T_ = ' ' "
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TopConn",TCGenQry(,,cQuery),"TRBQI3",.F.,.F.)
   If TRBQI3->TOTAL > 0
   		lRet := .F.
   EndIF
   TRBQI3->(DbCloseArea())
	
If lRet
	//Validando amarracao do grupo com alguma etapa 
	dbSelectArea("QUP")
	dbSetOrder(1)
	If dbSeek(xFilial("QUP")+M->QUO_GRUPO)
	   	While QUP->(!Eof() .And. xFilial("QUP")+QUP->QUP_GRUPO == M->QUO_FILIAL+M->QUO_GRUPO )
			RecLock("QUP",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
	    Enddo
		//Excluindo o Grupo
		RecLock("QUO",.F.)
		QUO->(dbDelete())
		MsUnLock()
		FKCOMMIT()
	Endif	
Endif

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QValidPer  ºAutor  ³Leandro           º Data ³  04/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida as casas decimais da porcentagem                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QValidPer(cCampo)
Local nTotal := 0
Local cPercent := ""   

If Len(alltrim(cCampo)) <> 4 
	nTotal 		:= Val(cCampo) 		 
	M->QUP_PERC	:= StrZero(nTotal,5,2)
Else
	cPercent := Transform(M->QUP_PERC, PesqPict("QUP","QUP_PERC"))
	M->QUP_PERC	:= cPercent
Endif	
	
Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QValDep    ºAutor  ³Sandra Ribeiro    º Data ³  14/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca o departamento de correção cadastrado para o produto.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QValDep(cProdut)

Local cDepto  := " "
Local cCodQad := " "

DbSelectArea("SB1")
DbSetOrder(1)
If SB1->(DbSeek(xFilial("SB1")+AllTrim(cProdut)))
	cCodQad := SB1->B1_CODQAD
	If !Empty(SB1->B1_CODQAD)
		cDepto := cCodQad
	
	Else
		MsgAlert("Não há departamento de correção cadastrado para este produto. Informe um departamento válido que preencherá o cadastro do produto")
	EndIf	
EndIf	
	
Return cDepto 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QValProd   ºAutor  ³Sandra Ribeiro    º Data ³  14/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o produto pode ser utilizado.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QValProduto(cProdut)

Local lRet := .T.

DbSelectArea("QUO")
DbSetOrder(4)
If QUO->(DbSeek(xFilial("QUO")+AllTrim(cProdut)))
	MsgAlert("Já existe grupo de etapas para este produto.")
	lRet := .F.
Else
	DbSelectArea("SB1")
	DbSetOrder(1)
	If SB1->(!DbSeek(xFilial("SB1")+AllTrim(cProdut)))
		MsgAlert("Produto nao cadastrado!")
		lRet := .F.
	EndIf
	
EndIf	
	
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³q120CpEt  ºAutor  ³Denis Martins		 º Data ³  05/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Responsavel pela copia de Grupo de Etapas					  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function q120CpEt()
Local aFldsQUO := {} 
Local aFldsQUP := {}
Local nx 	   := 1 	
Local ny 	   := 1 	
Local cVar
Local aFldsQt  := {}

If Pergunte("QNR120CO  ",.T.)
	If !Empty(mv_par03)
		
		dbSelectArea("QUO")
		dbSetOrder(1)
		If !dbSeek(xFilial("QUO")+mv_par02) //Verifico a existencia do Destino...
			If dbSeek(xFilial("QUO")+mv_par01)  
				aFldsQUO :=	QUO->(dbStruct())					
				For nx := 1 To Len(aFldsQUO)
					Aadd(aFldsQUO[nx],&(aFldsQUO[nx,1]))		
				Next nx
				dbSelectArea("QUP")
				dbSetOrder(1)
				If dbSeek(xFilial("QUP")+mv_par01)
					While QUP->(!Eof()) .and. QUP->QUP_FILIAL+QUP->QUP_GRUPO == xFilial("QUP")+mv_par01
						aFldsQUP :=	QUP->(dbStruct())					
						For nx := 1 To Len(aFldsQUP)
							Aadd(aFldsQUP[nx],&(aFldsQUP[nx,1]))		
						Next nx
		                Aadd(aFldsQt,aFldsQUP)
		                QUP->(dbSkip())
					Enddo			
					If Len(aFldsQUO) > 0
						aFldsQUP := aClone(aFldsQt)
						RecLock("QUO",.T.)
						For nx := 1 To Len(aFldsQUO)
							cVar := aFldsQUO[nx,1]
							If Alltrim(aFldsQUO[nx,1]) == "QUO_GRUPO"
								Replace &cVar. With MV_PAR02 //Conteudo do Destino...
							ElseIf Alltrim(aFldsQUO[nx,1]) == "QUO_PRODUT" 				
								Replace &cVar. With MV_PAR03 //Conteudo do Produto Destino...						
							Else
								Replace &cVar. With aFldsQUO[nx,Len(aFldsQUO[nx])]
							Endif
						Next nx	
						MsUnLock()		
		
						For nx := 1 To Len(aFldsQUP) 
							RecLock("QUP",.T.)
							For ny := 1 To Len(aFldsQUP[nx])
								cVar := aFldsQUP[nx,ny,1]
								If Alltrim(aFldsQUP[nx,ny,1]) == "QUP_GRUPO"
									Replace &cVar. With MV_PAR02 //Conteudo do Destino...
								Else
									Replace &cVar. With aFldsQUP[nx,ny,Len(aFldsQUP[nx,ny])]
								Endif
							Next ny
							MsUnlock()
						Next nx	    
					Endif	
				Else
					MessageDlg(STR0016) //"Problemas com integridade de dados. Tabela QUP sem respectivo registro na QUO."
				Endif
				
			Else
				MessageDlg(STR0017) //"Nao existe grupo de etapa cadastrada com este codigo Origem!"
			Endif
	    Else
			MessageDlg(STR0018) //"Codigo do Grupo de Etapa Destino ja existe!."   
	    Endif
	Else
		MessageDlg(STR0029) //"Codigo do Produto deve ser infomado."   		
	Endif    
Endif
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q120VlDestºAutor  ³Denis Martins		 º Data ³  05/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se foi preenchido o grupo de etapa destino			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q120VlDest()
Local lRet := .t.

If Empty(mv_par02) //Grupo de Etapa Destino...
	lRet := .f.
Endif

Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QNC120PRL³    Autor ³ Adriano da Silva   ³ Data ³ 09.06.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Etapa Paralela na GetDados   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNC120PRL(ExpC1)	    									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo das Etapas Paralelas 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do campo QUP_ETAPAP       						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC120PRL(cEtapaPrl)

Local lRet     	:= .T.
Local aEtaPrls 	:= {}
Local aEtpAux 	:= {}
Local nPos	   	:= 0
Local nPos2	   	:= 0
Local nPos3	   	:= 0
Local nX		:= 0
Local nY		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o campo QUP_ETAPRL e QUP_ETAPAP existem no dicionario de dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cEtapaPrl) 

	aEtaPrls := StrTokarr(AllTrim(cEtapaPrl),";")
	
	If Len(aEtaPrls) == 0
		
		MsgAlert(STR0021)	//"Favor informar uma etapa cadastrada no Grupo de Etapas."
		lRet := .F.	                             
	
	Else
		
		For nX := 1 To Len(aEtaPrls)
			
			If AllTrim(aCols[n][nPosEtapa]) == AllTrim(aEtaPrls[nX])
				MsgAlert(STR0022 + AllTrim(aEtaPrls[nX]) + STR0023)	//"A Etapa paralela " ### " não poderá ser a mesma da etapa principal do Grupo de Etapas."
				lRet := .F.	                             			
			EndIf
			
			nPos := Ascan(aCols,{|x| AllTrim(x[nPosEtapa]) == AllTrim(aEtaPrls[nX]) })
			If nPos == 0
				MsgAlert(STR0024 + AllTrim(aEtaPrls[nX]) + STR0025)	//"A Etapa " ### " não está cadastrada no Grupo de Etapas. Nesse caso, não poderá ser utilizada como Etapa Paralela."
				lRet := .F.
			Else
			 	If Val(AllTrim(aCols[nPos][nPosSeq])) < Val(AllTrim(aCols[n][nPosSeq])) .And. Val(AllTrim(aCols[n][nPosSeq])) > 1
				    MsgAlert(STR0024 + AllTrim(aEtaPrls[nX]) + STR0026)	//"A Etapa " ### " não poderá ser utilizada como etapa paralela, pois a sequência da etapa é menor que a etapa principal."
					lRet := .F.
				EndIf
			EndIf
			
			nPos2 := aScan(aEtaPrls, aEtaPrls[nX] )
	        If nPos2 > 0
				nPos3 := aScan(aEtpAux, aEtaPrls[nX] )			
				If nPos3 == 0
					Aadd(aEtpAux, aEtaPrls[nX])
				Else
					nPos4 := aScan(aEtpAux, aEtaPrls[nX] ) 
					If nPos4 > 0
						MsgAlert(STR0024 + AllTrim(aEtpAux[nPos4]) + STR0027)	//"A Etapa " ### " já está sendo informada no campo 'Etapa'."
						lRet := .F.
					EndIf
				EndIf
			EndIf
	
		Next
	
	EndIf

EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QNC120ETP³     Autor ³ Adriano da Silva   ³ Data ³ 09.06.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo o Combo da Etapa Paralela					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNC120ETP(ExpC1)	    									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Combo da Etapa Paralela (1-Sim/2-Nao) 	 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do campo QUP_ETAPRL       						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC120ETP(cComboPrl)

Local lRet     	:= .T.
Local cReadVar 	:= ReadVar()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o campo QUP_ETAPRL e QUP_ETAPAP existem no dicionario de dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

If AllTrim(cReadVar) == "M->QUP_ETAPRL"
	cCombo := M->QUP_ETAPRL
	If cComboPrl == "2"
		If !Empty(aCols[n][nPosEtPrl])
			If MsgYesNo(STR0028)
				aCols[n][nPosEtPrl] := Space(TamSX3("QUP_ETAPAP")[1])
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QNC120WHEP³    Autor ³ Adriano da Silva   ³ Data ³ 09.06.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a edição do campo Etapa Paralela					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNC120WHEP()		    									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN do campo QUP_ETAPAP       						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC120WHEP()

Local lRet := .T.

If aCols[n][nPosParal] == "1"
	lRet := .T.
Else
	lRet :=	.F.
EndIf	


Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCA120   ºAutor  ³Leonardo Quintania  º Data ³  07/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Valida a edicao do campo Etapa Sequencial      			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso		 ³ X3_VALID do campo QUP_PARSEQ                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q120VldSeq(nEvento)
Local lRet 		:= .T.
Local lAchou    := .F.
Local nX   		:= 0      
Local n    		:= oGetEtapas:nAT  
Local cResp     := If(ReadVar() == "M->QUP_RESP"  ,M->QUP_RESP  ,aCols[n,cRespons])
Local cTpAloc   := If(ReadVar() == "M->QUP_TRFACT",M->QUP_TRFACT,aCols[n,nPosTrfact])
Local cParSeq   := If(ReadVar() == "M->QUP_PARSEQ",M->QUP_PARSEQ,aCols[n,nPosParSeq])
                            
If cParSeq == "1"
	For nX := 1 To Len(aCols)   
	    If aCols[n,nPosEtapa] $ aCols[nx,nPosEtPrl]
	    	lAchou:= .T.
		    If aCols[nX,cRespons] # cResp .Or. cTpAloc # "1" 
				If nEvento == 1
			    	If MsgYesNo(STR0031)//Para utilizar esta opção, o responsável desta etapa deve ser o mesmo responsável da etapa pai do paralelismo e o tipo de alocação deve ser 'Força Recurso'. Deseja ajustar?
			      		aCols[n,nPosTrfact]:= '1' 
					    aCols[n,cRespons]:= aCols[nx,cRespons]  
					    QNC120NOME(aCols[n,cRespons])  //Atualiza descrição do campo de responsavel
					Else
						lRet := .F.
					EndIf
				Else
					Help(" ",1,"Q120PSEQ")
					lRet := .F.
				EndIf
				Exit
			EndIf
		EndIf
	Next nX		
	If !lAchou
		MsgInfo(STR0032,STR0033)//Não foi encontrado registro dessa etapa com paralelismo, Para utilização desse recurso é necessario que essa etapa faça parte de um grupo de paralelismo.","Paralelismo Sequencial"
		lRet:= .F.
	EndIf
EndIf

Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QN120Resp   ºAutor³Aldo Barbosa dos Santosº Data ³  25/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento de campos para permitir abrir janela de selecao de  º±±
±±º          ³recursos adicionais                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QN120Resp()  
Local nLin := oGetEtapas:nAt
Local nCol := oGetEtapas:oBrowse:colPos
Local cRet := oGetEtapas:aCols[nLin,nCol]
Local nResp := Ascan(aHeader,{|x| x[2] = "QUP_RESP"})    

if nCol == nPosResp2
	if Empty(oGetEtapas:aCols[nLin, nResp])
		MsgInfo("Para incluir recursos adicionais, e necessario que o recurso responsavel seja incluido primeiro." )
	Else	
		// se esta clicando exatamente no campo QUP_RESP2, deve abrir uma janela
		oGetEtapas:aCols[nLin, nPosResp2] := QN120Resp2(.T.,oGetEtapas:aCols[nLin,nCol],oGetEtapas:aCols[nLin,nResp])// MsgStop("Teste duplo clique - Linha "+Str(nLin)+" Col "+Str(nCol))
	Endif	
Else                  	
	// se editar o campo QUP_RESP apaga a selecao do campo QUP_RESP2
	if nCol == nResp .and. ! Empty(oGetEtapas:aCols[nLin,nPosResp2])
		if MsgYesNo("Os recursos adicionais serao apagados. Deseja alterar o recurso principal mesmo assim?")
			oGetEtapas:aCols[nLin,nPosResp2] := Space(Len(QUP->QUP_RESP2))
			oGetEtapas:editCell()
		Endif
	Else	
		oGetEtapas:editCell()
	Endif		
Endif
Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QN120Resp2  ºAutor³Aldo Barbosa dos Santosº Data ³  25/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite a selecao de recursos adicionaid para a etapa          º±±
±±º          ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QN120Resp2(lModo, cResp2, cResp)
// lModo  -> .T. Chamado do cadastro; .F. Chamado da alocacao semi-automatica
// cResp2 -> lista de recursos adicionais (QUP_RESP2 ou QI5_MAT2)
// cResp  -> responsavel pela tarefa (QUP_RESP ou QI5_MAT)

// vetores com as coordenadas da tela e de seus componentes
Local aVetDiag  := {345, 253, 784, 887}		// coordanadas da janela
Local aVetTxt   := {	003, 008}			  		// coordenadas do texto 'Pesquisa'
Local aVetList  := {025, 003, 307, 167}		// coordenadas do LISTBOX
Local aVetGet   := {003,115,128,011}			// coordenadas do get de perquisa
Local aVetCbo   := {003,040,064,012}			// cordenadas do combo de pesquisa
Local aColSize  := {006,006,019,038}			// tamanhos das colunas do LISTBOX
Local aVetBut   := {	{001,262,047,015},;		// botao Pesquisa
							{199,200,047,015},;		// botao Confirma
							{199,261,047,015},;		// botao Cancela
							{198,007,047,015} }		// botao Desmarca

Local cRet		 := cResp2

DEFAULT lModo  := .T. // .T. = Edicao   .F. = exibicao 
DEFAULT cResp  := ""  // campo contendo o responsavel 
DEFAULT cResp2 := ""  // campo contendo os recursos adicionais

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal

// variaveis da pesquisa
Private aCboPesq 		:= {"Codigo","Nome"}
Private cCboPesq
Private cTxtPesq 	:= Space(50)
Private oTxtPesq
Private lCheckBox1	 := .T.
Private oCheckBox1

// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

// Privates das ListBoxes
Private aListBox1 := {}
Private oListBox1

Private nPosFlag   := 1
Private nPosFilial := 2
Private nPosCodigo := 3
Private nPosNome   := 4

// controla o posicionamento apos a pesquisa
Private nPosAtual  := 1

// icones de marcacao do listbox
Private oMarca  := LoadBitmap( GetResources(), "LBTIK" )
Private oNada   := LoadBitmap( GetResources(), "nada")

DEFINE MSDIALOG _oDlg TITLE "Recursos da Etapa" FROM aVetDiag[1],aVetDiag[2] TO aVetDiag[3],aVetDiag[4] PIXEL

	// Cria Componentes Padroes do Sistema
	@ aVetTxt[1],aVetTxt[2] Say "Pesquisa" Size 029,010 COLOR CLR_BLACK PIXEL OF _oDlg

	@ aVetCbo[1],aVetCbo[2] ComboBox cCboPesq Items aCboPesq Size aVetCbo[3],aVetCbo[4] PIXEL OF _oDlg
	@ aVetGet[1],aVetGet[2] MsGet oTxtPesq Var cTxtPesq Size aVetGet[3],aVetGet[4] COLOR CLR_BLACK PIXEL OF _oDlg
	@ aVetBut[1,1],aVetBut[1,2] Button "Pesquisa" Size aVetBut[1,3],aVetBut[1,4] PIXEL OF _oDlg Action(PesqCampo())

	// Chamadas das ListBox do Sistema
	Processa({|| GetListBox1(cResp2,cResp)},"Aguarde ... Carregando recursos..." )

	@ aVetList[1],aVetList[2] LISTBOX oListBox1 FIELDS ;
							HEADER "  ","Filial","Codigo","Nome" ;
							SIZE aVetList[3],aVetList[4] PIXEL OF _oDlg ;
							COLSIZES aColSize[1],aColSize[2],aColSize[3],aColSize[4] ;
				ON DBLCLICK ( DuploClique(lModo), oListBox1:Refresh() )

	oListBox1:SetArray(aListBox1)

	oListBox1:bLine := {|| {;
		aListBox1[oListBox1:nAT,01],;
		aListBox1[oListBox1:nAT,02],;
		aListBox1[oListBox1:nAT,03],;
		aListBox1[oListBox1:nAT,04]}}

	@ aVetBut[4,1],aVetBut[4,2] Button "Desmarca" Size aVetBut[4,3],aVetBut[4,4] PIXEL OF _oDlg Action(DesmarcaItens(lModo),_oDlg:refresh())
	@ aVetBut[2,1],aVetBut[2,2] Button "Confirma" Size aVetBut[2,3],aVetBut[2,4] PIXEL OF _oDlg Action(cRet := ConfirmaForm(lModo),_oDlg:end())
	@ aVetBut[3,1],aVetBut[3,2] Button "Cancela"  Size aVetBut[3,3],aVetBut[3,4] PIXEL OF _oDlg Action(_oDlg:end())

ACTIVATE MSDIALOG _oDlg CENTERED 

Return( cRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³GetListBox1 ³ Autor ³ Aldo Barbosa dos Sant ³ Data ³25/06/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da ListBox                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetListBox1(cResp2, cResp)
// cResp2 -> campo contendo os recursos adicionais
// cResp  -> campo contendo o responsavel
Local aVetResp2 := {}
Local nPos      := 0
Local aVet      := {}  // vetor temporario dos recursos
Local nA        := 0
Local lQ120FIL  := ExistBlock("Q120FIL")
Local lRet      := .T.

DEFAULT cResp   := Space(Len(QUP->QUP_RESP))
DEFAULT cResp2  := Space(Len(QUP->QUP_RESP2))

// vetor contendo os recursos contidos no campo QUP_RESP2
aVetResp2 := STRTOKARR(AllTrim(cResp2), ';') 

// cria o vetor com todos os recursos apenas na primeira chamada
if Type("aRecList") <> "A" .or. Len(aRecList) == 0
	aRecList := {}
	QAA->( Dbsetorder(1))  // QAA_FILIAL+QAA_MAT
	if Empty(xFilial("QAA"))
		QAA->( Dbgotop())
	Else 	
		QAA->( Dbseek( cFilAnt ))
	Endif	

	// cria o vetor contendo todos os recursos da filial	
	aRecList := {}
	Do While QAA->( ! Eof()) .and. if(Empty(xFilial("QAA")),.T., QAA->QAA_FILIAL == xFilial("QI5"))
		Aadd(aRecList,{oNada, QAA->QAA_FILIAL, QAA->QAA_MAT, QAA->QAA_NOME})
   
		QAA->( Dbskip())
	Enddo
Endif

// mantem o vetor original e trabalha com uma copia
aVet := Aclone(aRecList)

// elimina da lista o item contido na QUP_RESP / QI5_MAT caso esteja preenchido
if ! Empty(cResp)
	cCodMat := Substr(RDZRetEnt("AE8",xFilial("AE8")+cResp,"QAA",,,.F.,.T.),3,Len(QAA->QAA_MAT))
	nPos := Ascan(aVet, {|e|  Alltrim(e[3]) == Alltrim(cCodMat) } )
	if nPos > 0
		Adel(aVet,nPos)
		Asize(aVet,Len(aVet)-1)
	Endif
Endif			

// marca os itens marcados anteriormente
For nA := 1 to Len(aVetResp2)
	nPos := Ascan(aVet, {|e| e[3] == aVetResp2[nA] } )
	if nPos > 0
		aVet[nPos,1] := oMarca
   Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEGJGS ponto de entrada para manipular o vetor de recursos                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
if lQ120FIL
	aRecList := ExecBlock("Q120FIL",.F.,.F., {aVet, cResp, cResp2})	
	if ValType(aRecList) <> "A"
		aRecList := Aclone(aVet)
	Endif	
EndIf

aListBox1 := Aclone(aVet)

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³PesqCampo   ³ Autor ³ Aldo Barbosa dos Sant ³ Data ³27/06/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Efetua a pesquisa no listbox                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PesqCampo()
Local cIndice := Upper(Alltrim(cCboPesq))
Local cChave  := Upper(Alltrim(cTxtPesq))
Local nPos    := oListBox1:nAt

if QNA120OPC == 3 .or. QNA120OPC == 4  // Inclusao / Alteracao
	if cIndice == "CODIGO" // pesquisa por codigo
		nPos := Ascan( oListBox1:Aarray,{ |e| Upper(e[nPosCodigo]) = cChave } )
	Else
		nPos := Ascan( oListBox1:Aarray,{ |e| Upper(e[nPosNome]) = cChave } )
	Endif
	
	if nPos > 0 .and. nPos <= Len(oListBox1:Aarray) .and. nPos <> oListBox1:nAt
		nPosAtual := nPos
		oListBox1:nAt := nPosAtual
		oListBox1:Refresh()
	Endif	
Endif

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³DesmarcaItens³ Autor ³ Aldo Barbosa dos Sant ³ Data ³27/06/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Desmarca todos os itens da listbox                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DesmarcaItens(lModo)
Local nA    := 0

if ! lModo .or. (lModo .and. (QNA120OPC == 3 .or. QNA120OPC == 4 ))  // Inclusao / Alteracao
	For nA := 1 to Len(oListBox1:Aarray)
		if oListBox1:Aarray[nA,1] == oMarca
			oListBox1:Aarray[nA,1] := oNada
		Endif	
	Next	
Endif

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ConfirmaForm³ Autor ³ Aldo Barbosa dos Sant ³ Data ³27/06/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Monta o campo QUP_RESP2 utilizando os dados do listbox       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConfirmaForm(lModo)
Local cRet := ""

// concatena os codigos
Aeval(oListBox1:Aarray, {|e| cRet += if( e[1] == oMarca, e[nPosCodigo]+";", "") } )

if ! lModo .or. (lModo .and. (QNA120OPC == 3 .or. QNA120OPC == 4 ))  // Inclusao / Alteracao
	cRet := Padr(cRet,Len(QUP->QUP_RESP2))
Endif

Return( cRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³DuploClique ³ Autor ³ Aldo Barbosa dos Sant ³ Data ³27/06/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Controla a marcacao/desmarcacao de registro do listbox        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DuploClique(lModo)
Local nQtd    := 0   // quantidade de recursos marcados
Local nQtdMax := Int(Abs((Len(QUP->QUP_RESP2)/(Len(QUP->QUP_RESP)+1))))

if ! lModo .or. (lModo .and. (QNA120OPC == 3 .or. QNA120OPC == 4 ))  // Inclusao / Alteracao
	// conta os marcados
	aEval(oListBox1:Aarray, {|e| if(e[1]==oMarca,nQtd++,Nil) })

	if nQtd > nQtdMax
		MsgInfo("O limite de 22 recursos no Cadastro de Etapas foi atingido. " )
	Else
		oListBox1:Aarray[oListBox1:nAt,1] := if(oListBox1:Aarray[oListBox1:nAt,1]==oNada,oMarca,oNada)
	Endif
Endif

Return Nil

