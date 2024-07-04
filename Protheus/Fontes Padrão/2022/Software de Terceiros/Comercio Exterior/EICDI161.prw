#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWBROWSE.CH"
#Include "TOPCONN.CH"
#INCLUDE "EICDI161.CH"
#INCLUDE "AVERAGE.CH"
#Include "RWMAKE.CH"
#include "DBTREE.ch"
#INCLUDE "EEC.CH"


/*********************
Funcao      : EICDI161
Parâmetros  : nOpc (1-Visualizar, 2-Gerar, 3-Estornar)
Objetivos   : Efetuar a integração do complemento de valor no custo do produto no modulo SIGAEST
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
************************************************************************************************/
*----------------------------------*
Function EICDI161(cAlias,nReg,nOPC)
*----------------------------------*
Begin Sequence

	If !DI154CompValor(SW6->W6_HAWB)
		If SW6->W6_IMPCO == "1" .And. !EasyGParam("MV_PCOIMPO",,.T.)  //THTS - 01/02/2019 - Se conta e ordem Adquirente (MV_PCOIMPO = .F.)
			MsgInfo(STR0043+ENTER+STR0044,STR0001) //Não é possível utilizar a rotina Complemento de Valor para notas fiscais na modalidade Conta e Ordem.###Utilize a geração da Nota Fiscal Complementar.
		Else
			SYT->(DBSETORDER(1))
			SYT->(dBSeek(xFilial("SYT") + SW6->W6_IMPORT))
			MsgInfo(StrTran(STR0017,"XX",Alltrim(SYT->YT_ESTADO)),STR0001)
		EndIf
		Break
	EndIf

	If nOPC == 2
	   DI161Tela1(cAlias,nReg,nOPC)
	Else
	   DI161Tela2(cAlias,nReg,nOPC)
	EndIf

End Sequence
Return



/***********************
Funcao      : DI161Tela1
Objetivos   : Montar a tela de geração para efetuar a integração do complemento de valor
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
****************************************************************************************/
*-----------------------------------*
Function DI161Tela2(cAlias,nReg,nOpc)
*-----------------------------------*
Local nOP 		:= 0
Local bMarca	:= {|| DI161Mark(), oBrowseDoc:Refresh() }

Local bOK				:= {|| If(Len(aRecNoDC) > 0, (nOP := 1, oDlg:END()), oDlg:Refresh())  }
Local bCANCEL			:= {|| oDLG:END()}
Local aSeekDC		:= {}
Private aDocs		:= {}
Private aRecNoDC	:= {}
Private oBrowseDoc

Begin Sequence

	If Len( aDocs := DI161DocSD3(SW6->W6_HAWB) ) == 0
		MsgInfo( If(nOpc == 3, STR0031, STR0032), STR0001)
		Break
	EndIf

	If Len(aDocs) == 1
		DI161Tela1(cAlias,nReg,nOPC,aDocs[1][1])
		Break
	EndIf

	/** Variavel declarada no EICDI154...*/
	cCadastro := If( Type("cCadastro") == "C", If(nOpc == 3, STR0026, STR0027), "")

	//1-Visualizar, 2-Gerar, 3-Estornar
	DEFINE MSDIALOG oDlg TITLE If(nOpc == 3, STR0029, STR0030) FROM 5,5 TO 22,85 Of oMainWnd
		oPanelDOC:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
       oPanelDOC:Align:= CONTROL_ALIGN_ALLCLIENT
       aPos := PosDlg(oDlg)

		oBrowseDoc:= FWBrowse():New(oPanelDOC)

		   oBrowseDoc:SetProfileID("BRDOC")
		   oBrowseDoc:SetDataArray()
		   oBrowseDoc:SetArray(aDocs)
		   oBrowseDoc:DisableSeek()

		   ADD MARKCOLUMN oColumn DATA   { || If(aScan(aRecNoDC,aDocs[oBrowseDoc:nAT][4]) == 0, 'LBNO', 'LBOK') } DOUBLECLICK bMarca HEADERCLICK /*bMarcaTodos*/ OF oBrowseDoc

		   Add COLUMN oColumn Data &("{|| aDocs[oBrowseDoc:nAt][" + Str(1) + "]}") Title STR0023 Picture AvSx3("D3_DOC"    , AV_PICTURE) Of oBrowseDoc
		   Add COLUMN oColumn Data &("{|| aDocs[oBrowseDoc:nAt][" + Str(2) + "]}") Title STR0024 Picture AvSx3("D3_TM"     , AV_PICTURE) Of oBrowseDoc
		   Add COLUMN oColumn Data &("{|| aDocs[oBrowseDoc:nAt][" + Str(3) + "]}") Title STR0025 Picture AvSx3("D3_EMISSAO", AV_PICTURE) Of oBrowseDoc

		   AAdd(aSeekDC, {AvSx3("D3_DOC", AV_TITULO)    , {{"", AvSx3("D3_DOC", AV_TIPO)    , AvSx3("D3_DOC", AV_TAMANHO)    , AvSx3("D3_DOC", AV_DECIMAL)    , AvSx3("D3_DOC"    , AV_TITULO)}}})
		   oBrowseDoc:SetSeek(, aSeekDC)

		oBrowseDoc:DisableConfig()
		oBrowseDoc:DisableReport()
		oBrowseDoc:Activate()

	ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDlg,bOK,bCANCEL) CENTERED

	If nOP == 1
	   oBrowseDoc:GoTo(aRecNoDC[1],.F.)
	   DI161Tela1(cAlias,nReg,nOpc, aDocs[oBrowseDoc:nAT][1])
	EndIf

End Sequence

Return Nil



/**********************
Funcao      : DI161Mark
Objetivos   : Marca/Desmarca Tela2
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
****************************************************************************************/
*-----------------------------------*
Static Function DI161Mark()
*-----------------------------------*
If Len(aRecNoDC) == 0
	aAdd(aRecNoDC, aDocs[oBrowseDoc:nAT][4])
Else
	If (nPos := aScan(aRecNoDC,aDocs[oBrowseDoc:nAT][4]) ) > 0
		aRecNoDC := {}
	Else
		aRecNoDC := {}
		aAdd(aRecNoDC, aDocs[oBrowseDoc:nAT][4])
	EndIf
EndIf
Return Nil



/***********************
Funcao      : DI161Tela1
Objetivos   : Montar a tela de geração para efetuar a integração do complemento de valor
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
****************************************************************************************/
*-------------------------------------------*
Function DI161Tela1(cAlias,nReg,nOpc,cDocSD3)
*-------------------------------------------*
Local nInc
Local aButtons		:= {}
Local nTipoNF			:= 8 //COMPLEMENTO DE VALOR
Local nTotDesp		:= 0
Local nBTOP			:= 0
Local cTitulo			:= ""//STR0002 + AllTrim(SW6->W6_HAWB) + " - " + STR0028
Local cArmazem          := "" 
Local bGrava			:= {|| If(DI161Valid(), (DI161GrvTela(), oDlg:Refresh()), )}
Local bOK				:= {|| If(lWhen, (nBTOP := 1, Eval(bGrava) ), Eval(bCANCEL) )}
Local bCANCEL			:= {|| nBTOP := 0, oDLG:END()}

Local bMrk01			:= {|| If((nPos := aScan(aRecNo,aWork1[oBrowseWN:nAT][nATPos])) == 0, aAdd(aRecNo, aWork1[oBrowseWN:nAT][nATPos]), (aDel(aRecNo, nPos), aSize(aRecNo, Len(aRecNo)-1))) }
Local bMrk02			:= {|| If( Len(aRecNo) > 0, aRecNo:={}, aRecNo:=GetAllRecNo() ), oBrowseWN:Refresh(), oBrowseWN:GoTop(.T.) }
Local bMarca			:= {|| If(lWhen,Eval(bMrk01), oBrowseWN:Refresh() )}
Local bMarcaTodos		:= {|| If(lWhen,Eval(bMrk02),(oBrowseWN:Refresh(), oBrowseWN:GoTop(.T.)) )}

Local aCamposDP 		:= {	"YB_DESP", "YB_DESCR", "YB_VALOR", "YB_RATPESO" 	}
Local aPosScr,nAltScr,nLarScr
Local aCordsObj         := {}
Local aSeekDP           := {} , aSeekWN := {}
Private aCamposWN 		:= {	"$STATUS","B1_COD","B1_DESC","WN_QUANT","WN_UNI",;
								"WN_PRUNI","WN_VALOR","WN_PESOL","W8_PESO_BR",;
								"WN_PO_EIC","W3_CTCUSTO","WN_ADICAO","WN_SEQ_ADI","D3_LOCAL"}
Private cNaoIntegra	:= STR0018 //'Não Integrar', 'Integrar'
Private cIntegra		:= STR0019
Private lEstornar    := If(nOpc == 3, .F., .T.)
Private nATPos		 :=len(aCamposWN)+1 //posição do recno no array/ objeto
Private aWork1		:= {}
Private aWork4		:= {}
Private oBrowseDP,;
        oBrowseWN,;
        oColumn,;
        oDLG
Private lWhen			:= .T.
Private lEnvCcItem	:= .F.
Private aLocExecAuto	:= {.T.,.F.,{},.T.,.F.}
Private lExecAuto		:= .T.
Private aRecNo		:= {}
Private bSeekWk1, bSeekWk2, bWhileWk

/** PRIVATES MATA241
********************/
Private l240 :=.F.,l250:=.F.,l241 :=.T.,l242:=.F.,l261 := .F.,l185:=.F.
/*************
 As variaveis cDocumento, cCC, cTM, cF3 - foram implementadas conforme a regra existente no fonte MATA241
 A manutenção dessas variáveis deve seguir a regra existente no fonte de referência.
**********************************************************************************************************/
Private cDocumento  := CriaVar("D3_DOC")
Private cCC         := CriaVar("D3_CC")
Private cTM         := CriaVar("D3_TM")
Private cF3         := If(CtbInUse(), 'CTT', If(EasyGParam('MV_SIGAGSP', .F., '0')=='1', 'NI3', 'SI3')) //-- MV_SIGAGSP = "0"-Nao integra/ "1"-Integra
Private oPanelNF, nLin, nCol1, nCol2
PRIVATE lCposNFDesp := (SWD->(FIELDPOS("WD_B1_COD")) # 0 .And. SWD->(FIELDPOS("WD_DOC")) # 0 .And. SWD->(FIELDPOS("WD_SERIE")) # 0;                   //NCF - Campos da Nota Fiscal de Despesas
                       .And. SWD->(FIELDPOS("WD_ESPECIE")) # 0 .And. SWD->(FIELDPOS("WD_EMISSAO")) # 0 .AND. SWD->(FIELDPOS("WD_B1_QTDE")) # 0;
                       .And. SWD->(FIELDPOS("WD_TIPONFD")) # 0)
Private cArmazDE := cArmazPARA := Space(TamSX3("D3_LOCAL")[1])
Default cDocSD3     := ""
Begin Sequence

	If nOpc == 2 //1-Visualizar, 2-Gerar, 3-Estornar
		/** Processa Work1 e Work4 utilizadas como referencia para as informações na tela de complemento de valor.*/
		If !DI154NFE("SW6" ,SW6->(RECNO()),nTipoNF,     ,     ,aLocExecAuto)//Chama calculando os impostos
			Break
		EndIf
	Else

		cTitulo := If(nOpc == 3, STR0029, STR0030)
		SD3->(DbSetOrder(2))
		SD3->(DbSeek(xFilial("SD3")+AvKey(cDocSD3,"D3_DOC")))
		cDocumento		:= 	SD3->D3_DOC
		cCC				:= 	SD3->D3_CC
		cTM				:= 	SD3->D3_TM
		cArmazem        :=  If(!Empty(SD3->D3_LOCAL),SD3->D3_LOCAL,DI154BuscLoc())
		aCamposWN		:=	{"$STATUS", "D3_NUMSEQ", "B1_COD", "B1_DESC", "WN_QUANT", "WN_UNI", "WN_PRUNI",;
							 "WN_VALOR", "WN_PESOL", "W8_PESO_BR", "WN_PO_EIC","W3_CTCUSTO","WN_ADICAO","WN_SEQ_ADI","D3_LOCAL" }
		nATPos			:= 	len(aCamposWN)+1 //posição do recno no array/ objeto
		lWhen			:= 	.F.
		cNaoIntegra	:= STR0020
		cIntegra		:= STR0021
		bMarca			:= 	{|| oBrowseWN:Refresh(), oBrowseWN:GoTop(.T.) }
		bMarcaTodos	:= 	{|| oBrowseWN:Refresh(), oBrowseWN:GoTop(.T.) }
		bOk				:=	{|| If(lEstornar, (nBTOP := 0, oDLG:END() ), (DI161Estorno(),((oBrowseWN:Refresh(), oBrowseWN:GoTop(.T.)) ) )) }
		
	EndIf

	cTitulo	:= If(nOpc == 2, STR0028, If(nOpc == 3, STR0029, STR0030))

	/** Variavel declarada no EICDI154...*/
	cCadastro	:= If( Type("cCadastro") == "C", STR0002 + AllTrim(SW6->W6_HAWB) + " - " + If(nOpc == 2, STR0028, If(nOpc == 3, STR0029, STR0030)), "")

	aWork1 := CompVlrDados("Work1", nOpc, cDocSD3, If(!Empty(cArmazem),cArmazem,DI154BuscLoc()))
	aWork4 := CompVlrDados("Work4", nOpc, cDocSD3)

	nLin :=010
	nCoL1:=035
	nCoL2:=085
	nCoL3:=162
	nCoL4:=217
	nCol5:=295

	For nInc := 1 To Len(aWork4)
	    nTotDesp += aWork4[nInc][3]
	Next

	DEFINE MSDIALOG oDLG TITLE  cTitulo;
	       FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

		aPos     := PosDlgDown(oDlg)
		nAltura  := int((oDLG:nBottom-oDLG:nTop)/2)
		nLargura := int((oDLG:nRight-oDLG:nLeft)/2)

        // Cria objeto Scroll
        oScroll := TScrollArea():New(oDlg,0,aPos[2]-20,(nLargura/2)-20 ,(nAltura/2))
        oScroll:Align := CONTROL_ALIGN_ALLCLIENT
        oPanelNF := TPanel():New(0 ,0 ,"",oScroll,,.F.,.F.,,,oScroll:nRight,oScroll:nBottom,,)
        oPanelNF:align:= CONTROL_ALIGN_LEFT

		aPosScr := PosDlgDown(oScroll)
		nAltScr := int((oScroll:nBottom-oScroll:nTop)/2)
		nLarScr := int((oScroll:nRight-oScroll:nLeft)/2)

		//oPanelNF := TPanel():New(0  ,aPos[2]-20             ,"",oDLG,,.F.,.F.,,,(nLargura/2)-20 ,(nAltura/2),,)
		//oPanelNF:align:= CONTROL_ALIGN_LEFT

		oPanelDP := TPanel():New(0  ,aPos[2]+(nLargura/2)-10,"",oDLG,,.F.,.F.,, ,(nLargura/2)+10,(nAltura/2),,)
		oPanelDP:align:= CONTROL_ALIGN_RIGHT

		oPanelWN := TPanel():New(130,aPos[2]+4              ,"",oDLG,,.F.,.F.,,,(nLargura-4)   ,(nAltura/2),,)
		oPanelWN:align:= CONTROL_ALIGN_BOTTOM

        // Define objeto painel como filho do scroll
        oScroll:SetFrame( oPanelNF )
        
		/******
		Painel esquerdo, informações do processo e movimentação interna
		********/
		//nLin+=04
		//* Informações do processo
		aCordsObj := { 000 , 004 , 080 , aPosScr[2] }
		@ aCordsObj[1],aCordsObj[2] GROUP oGroup1 TO aCordsObj[3], aCordsObj[4] PROMPT STR0003 OF oPanelNF PIXEL
		oGroup1:align:= CONTROL_ALIGN_TOP

		@ nLin,nCoL1 SAY STR0004 SIZE 58,7 OF oPanelNF PIXEL
		@ nLin,nCoL2 MSGET SW6->W6_HAWB     WHEN .F. SIZE 58,8 OF oPanelNF PIXEL //Processo

		@ nLin,nCoL3 SAY STR0005 SIZE 58,7 OF oPanelNF PIXEL //"Dt.Desembaraço"
		@ nLin,nCoL4 MSGET SW6->W6_DT_DESE     WHEN .F. SIZE 58,8 OF oPanelNF PIXEL

		nLin+=15
		@ nLin,nCoL1 SAY STR0006 SIZE 58,7 OF oPanelNF PIXEL //"Importador"
		@ nLin,nCoL2 MSGET SYT->YT_NOME WHEN .F. SIZE 190,8 OF oPanelNF PIXEL

		nLin+=15
		@ nLin,nCoL1 SAY STR0007 SIZE 58,7 OF oGroup1 PIXEL //"Nº D.I."
		@ nLin,nCoL2 MSGET SW6->W6_DI_NUM PICTURE AVSX3("W6_DI_NUM",AV_PICTURE)    WHEN .F. SIZE 58,8 OF oPanelNF PIXEL

		@ nLin,nCoL3 SAY STR0008 SIZE 58,7 OF oPanelNF PIXEL //Data registro DI
		@ nLin,nCoL4 MSGET SW6->W6_DTREG_D     WHEN .F. SIZE 58,8 OF oPanelNF PIXEL

		nLin+=15
		@ nLin,nCoL1 SAY STR0009 SIZE 58,7 OF oPanelNF PIXEL //"Total Despesas(R$)"
		@ nLin,nCoL2 MSGET nTotDesp  PICTURE '@E 999,999,999,999.99' SIZE 58, 7 OF oPanelNF WHEN .F. RIGHT PIXEL


		//* Movimento Interno
		cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)

		//@ 105,010 GROUP oGroup2 TO (nAltScr/2), aPosScr[2] PROMPT STR0010 OF oPanelNF PIXEL  //NCF - 19/10/2020
		aCordsObj := { 105 , 010 , 185 , aPosScr[2] }
		@ aCordsObj[1],aCordsObj[2] GROUP oGroup2 TO aCordsObj[3], aCordsObj[4] PROMPT STR0010 OF oPanelNF PIXEL
		oGroup2:align:= CONTROL_ALIGN_TOP

		nLin+=40
		@ nLin,nCoL1 SAY STR0011 SIZE 58,7 OF oPanelNF PIXEL //"Número Documento"
		@ nLin,nCoL2 MSGET cDocumento SIZE 58, 7 Valid NaoVazio() .And. CheckSX3("D3_DOC") .And.;
		                                               VldUser('D3_DOC') WHEN lWhen OF oPanelNF PIXEL

		nLin+=15
		@ nLin,nCoL1 SAY STR0012 SIZE 58,7 OF oPanelNF PIXEL //"Tipo de Movimento"
		@ nLin,nCoL2 MSGET cTM  SIZE 58, 7 F3 "SF5" Valid NaoVazio() .And. DI161Valid("SF5") .And.;
		                                                  VldUser('D3_TM') WHEN lWhen OF oPanelNF PIXEL

		@ nLin,nCoL3 SAY STR0013 SIZE 58,7 OF oPanelNF PIXEL //"Centro de Custo"
		@ nLin,nCoL4 MSGET cCC   SIZE 58, 7 F3 cF3 Valid CheckSX3("D3_CC") .And. VldUser('D3_CC') WHEN lWhen OF oPanelNF PIXEL

		nLin+=15

        IF(EasyEntryPoint("EICDI161"),Execblock("EICDI161",.F.,.F.,"ADD_CPO_PANEL_MOVI_INT"),)
        
		//Alteração de Armazém
        aCordsObj := { 210 , 010 , 290 , aPosScr[2] }
		@ aCordsObj[1],aCordsObj[2] GROUP oGroup3 TO aCordsObj[3] , aCordsObj[4] PROMPT 'Alteração de Armazém' OF oPanelNF PIXEL
		oGroup3:align:= CONTROL_ALIGN_TOP

		nLin+=50
		@ nLin,nCoL1+37 SAY STR0045 SIZE 58,7 OF oPanelNF PIXEL //DE:
		@ nLin,nCoL2 MSGET cArmazDE     SIZE 58, 7 F3 'NNR' VALID Vazio() .Or. ExistCpo("NNR",cArmazDE)   WHEN lWhen OF oPanelNF PIXEL

		@ nLin,nCoL3+25 SAY STR0046 SIZE 58,7 OF oPanelNF PIXEL //PARA:
		@ nLin,nCoL4 MSGET cArmazPARA   SIZE 58, 7 F3 'NNR' VALID Vazio() .Or. ExistCpo("NNR",cArmazPARA) WHEN lWhen OF oPanelNF PIXEL

		@ nLin,nCoL5 BUTTON STR0047 SIZE 58,10 ACTION ( AlteraArmz( cArmazDE,cArmazPARA ), oBrowseWN:Refresh() ) WHEN lWhen OF oPanelNF PIXEL //Alterar

		/******
		Painel direito, informações das despesas do processo
		********/
		aCordsObj := { 000 , 004 , 223 , aPosScr[2] }
		@ aCordsObj[1],aCordsObj[2] GROUP oGroup4 TO aCordsObj[3] , aCordsObj[4] PROMPT STR0048 OF oPanelDP PIXEL //"Despesas Complementares"
		oGroup4:align:= CONTROL_ALIGN_TOP                                                            // NCF - 19/10/2020
		oBrowseDP:= FWBrowse():New( oGroup4 /*oPanelDP*/)

		   oBrowseDP:SetProfileID("BRDSP")
		   oBrowseDP:SetDataArray()
		   oBrowseDP:SetArray(aWork4)
		   oBrowseDP:DisableSeek()
		   oBrowseDP:DisableFilter()
			oBrowseDP:DisableConfig()
			oBrowseDP:DisableReport()

		   For nInc:= 1 To Len(aCamposDP)
		     Add COLUMN oColumn Data &("{|| aWork4[oBrowseDP:nAt][" + Str(nInc) + "]}") Title AvSx3(aCamposDP[nInc], AV_TITULO) Size AvSx3(aCamposDP[nInc], AV_TAMANHO) Picture AvSx3(aCamposDP[nInc], AV_PICTURE) Of oBrowseDP
		   Next

		   AAdd(aSeekDP, {AvSx3("YB_DESP", AV_TITULO)    , {{"", AvSx3("YB_DESP", AV_TIPO)    , AvSx3("YB_DESP", AV_TAMANHO)    , AvSx3("YB_DESP", AV_DECIMAL)    , AvSx3("YB_DESP"    , AV_TITULO)}}})
		   oBrowseDP:SetSeek(, aSeekDP)
			oBrowseDP:Activate()

		/******
		Painel inferior, informações dos itens
		********/
		aCordsObj := { 000 , 004 , 200 , aPosScr[2] }
		@ 000,004 GROUP oGroup5 TO 200/*080*/, aPosScr[2] PROMPT STR0049 OF oPanelWN PIXEL //Itens
		oGroup5:align:= CONTROL_ALIGN_TOP                                                            // NCF - 19/10/2020
		oBrowseWN:= FWBrowse():New( oGroup5 /*oPanelWN*/)

		   oBrowseWN:SetProfileID("BRINF")
		   oBrowseWN:SetDataArray()
		   oBrowseWN:SetArray(aWork1)
		   oBrowseWN:DisableSeek()
		   oBrowseWN:DisableFilter()
			oBrowseWN:DisableConfig()
			oBrowseWN:DisableReport()

          If nOpc == 2 //1-Visualizar, 2-Gerar, 3-Estornar
		      ADD MARKCOLUMN oColumn DATA   { || If(aScan(aRecNo,aWork1[oBrowseWN:nAT][nATPos]) == 0, 'LBNO', 'LBOK') } DOUBLECLICK bMarca HEADERCLICK bMarcaTodos OF oBrowseWN
		   EndIf

		   ADD STATUSCOLUMN oColumn DATA { || DI161Status() } DOUBLECLICK { |bMarca| } OF oBrowseWN

		   For nInc:= 1 To Len(aCamposWN)
		     If Left(aCamposWN[nInc], 1) == "$"
		        //Add COLUMN oColumn Data &("{|| aWork1[oBrowseWN:nAt][" + Str(nInc) + "]}") Title "Status" Size 15 Of oBrowseWN
              oBrowseWN:AddColumn({"Status", &("{|| aWork1[oBrowseWN:nAt][" + Str(nInc) + "]}"), "C",,, 15})
		     ElseIf aCamposWN[nInc] == "D3_LOCAL" .AND. EasyGParam("MV_EASY",,"N") == "S"
		        oBrowseWN:AddColumn({AvSx3(aCamposWN[nInc], AV_TITULO), &("{|| aWork1[oBrowseWN:nAt][" + Str(nInc) + "]}"), AvSx3(aCamposWN[nInc], AV_TIPO),,, AvSx3(aCamposWN[nInc], AV_TAMANHO), AvSx3(aCamposWN[nInc], AV_DECIMAL), .T., {||.T.}, .F., {|o| DI161SetLoc(o), oBrowseWN:Refresh(.T.)}, CriaVar("D3_LOCAL") })
		     Else
		        //Add COLUMN oColumn Data &("{|| cValToChar(aWork1[oBrowseWN:nAt][" + Str(nInc) + "])}") Title AvSx3(aCamposWN[nInc], AV_TITULO) Size AvSx3(aCamposWN[nInc], AV_TAMANHO) Picture AvSx3(aCamposWN[nInc], AV_PICTURE) Of oBrowseWN
              oBrowseWN:AddColumn({AvSx3(aCamposWN[nInc], AV_TITULO), &("{|| aWork1[oBrowseWN:nAt][" + Str(nInc) + "]}"), AvSx3(aCamposWN[nInc], AV_TIPO), AvSx3(aCamposWN[nInc], AV_PICTURE),, AvSx3(aCamposWN[nInc], AV_TAMANHO), AvSx3(aCamposWN[nInc], AV_DECIMAL)})
		     EndIf
		   Next

		   AAdd(aSeekWN, {AvSx3("WN_ADICAO" , AV_TITULO)    , {{"", AvSx3("WN_ADICAO" , AV_TIPO)    , AvSx3("WN_ADICAO" , AV_TAMANHO)    , AvSx3("WN_ADICAO" , AV_DECIMAL)    , AvSx3("WN_ADICAO"     , AV_TITULO)}}})
		   AAdd(aSeekWN, {AvSx3("WN_SEQ_ADI", AV_TITULO)    , {{"", AvSx3("WN_SEQ_ADI", AV_TIPO)    , AvSx3("WN_SEQ_ADI", AV_TAMANHO)    , AvSx3("WN_SEQ_ADI", AV_DECIMAL)    , AvSx3("WN_SEQ_ADI"    , AV_TITULO)}}})
		   oBrowseWN:SetSeek(, aSeekWN)

		oBrowseWN:Activate()
		oDlg:lMaximized := .T.

		// Antigo botão de imprimir browse dentro de outras ações "Imprimir Itens" e "Imprimir Despesas Complementares"
		Aadd( aButtons, {"HISTORIC", {|| oBrowseDP:Report()}, STR0054+"...", STR0054 , {|| .T.}} ) //"Imprimir Despesas Complementares"
		Aadd( aButtons, {"HISTORIC", {|| oBrowseWN:Report()}, STR0055+"...", STR0055 , {|| .T.}} ) // "Imprimir Itens"

	ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)

	If nOpc == 2 .And. nBTOP == 0 //1-Visualizar, 2-Gerar, 3-Estornar
	   DI154RESET_AREA()
	EndIF

End Sequence

Return Nil



/************************
Funcao      : GetAllRecNo
Objetivos   : Popular o array de controle aRecNo utilizado na ação marca/desmarca do item
Retorno     : Array de dados
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
*****************************************************************************************/
*---------------------------------*
Static Function GetAllRecNo()
*---------------------------------*
Local aRet := {}, i
	For i := 1 To Len(aWork1)
		oBrowseWN:GoTo(i,.F.)
		aAdd(aRet, aWork1[oBrowseWN:nAT][nATPos])
	Next
Return aRet



/************************
Funcao      : DI161Status
Objetivos   : Atualizar o status do item na ação do marca/desmarca de cada linha
Retorno     : 'BR_VERMELHO','BR_VERDE'
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
****************************************************************************************/
*---------------------------------*
Static Function DI161Status()
*---------------------------------*
Local lRet := aScan(aRecNo,aWork1[oBrowseWN:nAT][nATPos]) == 0

   aWork1[oBrowseWN:nAt][1] := If(lRet, cNaoIntegra, cIntegra)

   If nATPos == Len(aWork1[oBrowseWN:nAt]) .And. lRet //o recno é a última posição do array
      aWork1[oBrowseWN:nAt][2] := ""
   EndIf

Return If(lRet,'BR_VERMELHO','BR_VERDE')



/*************************
Funcao      : DI161GrvTela
Objetivos   : Efetuar a gravação dos dados na SWN e efetuar a integração via rotina automatica MATA241
Retorno     : Lógico (.T./.F.)
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
******************************************************************************************************/
*---------------------------------*
Static Function DI161GrvTela()
*---------------------------------*
Local aOrd    := SaveOrd({"SD3"})
Local lRet		:= .F.
Local aCab		:= {}
Local aItem	:= {}
Local _aRet	:= {}

/** PRIVATES EICDI154
********************/
Private dDtNFE, nTipoNF, bDDIFor, bDDIWhi, lGerouNFE, lMV_EASYSIM, lGrvItem, lTemDespBaseICM, lMV_PIS_EIC, lCposCofMj
Private lCposPisMj, lLote, lExisteSEQ_ADI, lMV_GRCPNF, lAcresDeduc, lICMS_Dif, lICMS_Dif2, lTemCposOri, lTipoCompl
Private lAtuSW6NFE, lGravaSWW, lGravaWorks, lMV_NF_MAE, lCposNFDesp, lTemYB_ICM_UF, lNfeCompVL

SYT->(DBSETORDER(1))
SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
Private cCpoBasICMS:="YB_ICMS_"+Alltrim(SYT->YT_ESTADO)


Begin Sequence
	If lRet := (Len(aRecNo) > 0 )

		If Empty(cCC)
		   lEnvCcItem := MsgYesNo(STR0034,STR0001)
		EndIf

		DI161LoadVar()

		If Len(_aRet := DI161DadosGrv(2,aRecNo)) > 0 //1-Visualizar, 2-Gerar, 3-Estornar

			Begin Transaction

				nPos := aScan(_aRet[1], {|x| x[1] == "aCab" })
				aCab := _aRet[1][nPos][2]
				nPos := aScan(_aRet[1], {|x| x[1] == "aItem"})
				aItem:= _aRet[1][nPos][2]

				bProc := {|| lRet := DI161ExecAuto(aCab,aItem,3) }
				Processa(bProc,STR0035,STR0036,.F.)

				If	lRet
					lWhen := .F.
				Else
					DisarmTransaction()
				EndIf
			End Transaction

			If lRet
				SD3->(DbSetOrder(2))
				Work1->(DbGoTop())

				Do While Work1->(!Eof())

					RecLock("Work1",.F.)

					If aScan(aRecNo, Work1->(RecNo()) ) == 0
						Work1->WK_NFE   := SD3->D3_DOC
						Work1->WK_DT_NFE:= dDataBase
					Else

						SD3->(DbSeek(xFilial("SD3")+AvKey(cDocumento,"D3_DOC")+AvKey(Work1->WKCOD_I,"D3_COD"))) //D3_FILIAL+D3_DOC+D3_COD
						Do While SD3->(!Eof())
							If SD3->D3_ITEMSWN == StrZero(Work1->WKLINHA, AvSx3("D3_ITEMSWN",AV_TAMANHO))
								Work1->WKNUMSEQ := SD3->D3_NUMSEQ
								Work1->WK_NFE   := SD3->D3_DOC
								Work1->WK_DT_NFE:= dDataBase
								Exit
							EndIf
							SD3->(DbSkip())
						EndDo
					EndIf

					Work1->(MsUnlock())
					Work1->(DbSkip())
				EndDo
			EndIf

			DI154GerNF(@lGerouNFE,bDDIFor,bDDIWhi)

			MsgInfo(STR0037,STR0001)
		EndIf

	Else
	   MsgAlert(STR0038,STR0001)
	EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet



/*************************
Funcao      : DI161Estorno
Objetivos   : Efetuar o estorno da integração com o MATA241
Retorno     : Lógico (.T./.F.)
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
****************************************************************************************/
Static Function DI161Estorno()
Local lRet := .F.

Begin Sequence

	If !(lEstornar := MsgYesNo(StrTran(STR0022,"XXXX",cDocumento),STR0001))
		Break
	EndIf

	If Len(_aRet := DI161DadosGrv(3,aRecNo)) > 0 //1-Visualizar, 2-Gerar, 3-Estornar
		SD3->(DbSetOrder(2))
		SD3->(DbSeek(xFilial("SD3") + AvKey(cDocumento,"D3_DOC") ))

		Begin Transaction
			nPos := aScan(_aRet[1], {|x| x[1] == "aCab" })
			aCab := _aRet[1][nPos][2]
			nPos := aScan(_aRet[1], {|x| x[1] == "aItem"})
			aItem:= _aRet[1][nPos][2]

			bProc := {|| lRet := DI161ExecAuto(aCab,aItem,6) }
			Processa(bProc,STR0035,STR0039,.F.)

			If	!lRet
				DisarmTransaction()
			EndIf
		End	Transaction

		If lRet
			SWN->(DbSetOrder(3))
			If SWN->(DbSeek(xFilial("SWN") + SW6->W6_HAWB + '7'))
				Do While SWN->(!Eof())
					If SWN->WN_DOC == AvKey(cDocumento,"WN_DOC")
					   SWN->(RecLock("SWN",.F.,.T.))
					   SWN->(DBDELETE())
					   SWN->(MsUnlock())
					EndIf
					SWN->(DbSkip())
				EndDo
			EndIf

			SWW->(DbSetOrder(2))
			If SWW->(DbSeek(xFilial("SWW") + SW6->W6_HAWB + '7'))
				Do While SWW->(!Eof())
					If SWW->WW_NF_COMP == AvKey(cDocumento,"WW_NF_COMP")
					   SWW->(RecLock("SWN",.F.,.T.))
					   SWW->(DBDELETE())
					   SWW->(MsUnlock())
					EndIf
					SWW->(DbSkip())
				EndDo
			EndIf

			SWD->(DbSetOrder(1))
			If SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
				Do While SWD->(!Eof())
					If SWD->WD_NF_COMP == AvKey(cDocumento,"WD_NF_COMP")
					   SWD->(RecLock("SWD",.F.,.T.))
					   SWD->WD_NF_COMP := ""
					   SWD->WD_DT_NFC  := CTOD("")
					   SWD->(MsUnlock())
					EndIf
					SWD->(DbSkip())
				EndDo
			EndIf
			aRecNo := {}
			MsgInfo(STR0040,STR0001)
		EndIf

	EndIf
End Begin

Return lRet



/***********************
Funcao      : DI161Valid
Parâmetros  : cAlias - SF5/Vazio
Objetivos   : Efetuar a validação do campo Tipo de Movimento
Retorno     : Lógico (.T./.F.)
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
****************************************************************************************/
*---------------------------------*
Static Function DI161Valid(cAlias)
*---------------------------------*
Local lRet := .T., cMsg := ""
Default cAlias := ""

Begin Sequence

   If !Empty(cAlias)
      SF5->(DbSeek(xFilial("SF5")+AvKey(cTM,"F5_CODIGO")))
      If SF5->F5_TIPO <> "D"
         cMsg += STR0014
      EndIf
      If SF5->F5_VAL <> "S"
         cMsg += If(!Empty(cMsg),ENTER+ENTER,"") + STR0015
      EndIf
      If SF5->F5_VAL <> "S"
         cMsg += If(!Empty(cMsg),ENTER+ENTER,"") + STR0016
      EndIf
   Else
      If Empty(cTM)
         cMsg += STR0041
      EndIf
   EndIf

   If !Empty(cMsg)
      MsgStop(cMsg,STR0001)
      lRet := .F.
   EndIf


End Sequence
Return lRet



/**************************
Funcao      : DI161ExecAuto
Parâmetros  : aAutoCab	- array de cabeçalho
				aAutoItens	- array de itens
				nOpc		- opção para efetuar chamada via rotina automatica (3-Incluir/6-Estorno)
Objetivos   : Validar os arrays aCab/aItens/nOpc e disparar a execução da rotina automatica MATA241
Retorno     : Lógico (.T./.F.)
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
***************************************************************************************************/
*----------------------------------------------*
Function DI161ExecAuto(aAutoCabP,aAutoItensP,nOpcP)
*----------------------------------------------*
Local lCab, lItem

Private lMsHelpAuto := .T. // se .t. direciona as mensagens de help
Private lMsErroAuto := .F. //necessario a criacao
Private _acod := {"1","MP1"}

Default aAutoCabP   := {}
Default aAutoItensP := {}
Default nOpcP       := 0

Private aAutoCab   := aAutoCabP
Private aAutoItens := aAutoItensP
Private nOpc       := nOpcP

Begin Sequence

	IF(EasyEntryPoint("EICDI161"),Execblock("EICDI161",.F.,.F.,"DI161EXECAUTO"),)

	lCab   := !Empty(aAutoCab)
	lItem  := !Empty(aAutoItens)

	If !lCab .Or. !lItem .Or. nOpc == 0
	   MsgStop(STR0042,STR0001)
	   Break
	EndIf

	MSExecAuto({|x,y,z| Mata241(x,y,z)},aAutoCab,aAutoItens,nOpc)

	If lMsErroAuto
	   Mostraerro()
	   Break
	EndIf

End Sequence

Return !lMsErroAuto



/*************************
Funcao      : CompVlrDados
Parâmetros  : cAlias - (Work1/Work4)
Objetivos   : Montar os arrays utilizados nos objetos de tela oBrowseDP/oBrowseWN
Retorno     : Array de dados
Autor       : Laércio G Souza Jr
Data/Hora   : 30/03/2016 - 14:04
****************************************************************************************/
*-------------------------------------------------------------*
Static Function CompVlrDados(cAlias, nOp, cDocSD3, cArmazem)
*-------------------------------------------------------------*
Local aRet			:= {}
Local cRatPeso	:= ""
Default cDocSD3	:= "", cArmazem := ""
Begin Sequence

	Do Case
	Case cAlias == "Work1"
		If nOp == 2 //Gerar
			Work1->(DbGoTop())
			SW3->(DbSetOrder(8))

			Do While Work1->(!Eof())
				SB1->(DbSeek(xFilial("SB1")+AvKey(Work1->WKCOD_I,"B1_COD")))
				SW3->(DbSeek(xFilial() + Work1->WKPO_NUM + Work1->WKPOSICAO))
				nPesoB  := If (Work1->(FieldPos("WKPESOBR")) > 0, Work1->WKPESOBR, 0)

				AAdd(aRet,{ cIntegra,	SB1->B1_COD, SB1->B1_DESC, Work1->WKQTDE, Work1->WKUNI,;
											Work1->WKPRUNI, Work1->WKVALMERC, Work1->WKPESOL, nPesoB,;
											Work1->WKPO_NUM, SW3->W3_CTCUSTO	, Work1->WKADICAO, Work1->WKSEQ_ADI, DI154BuscLoc()/*cArmazem*/, Work1->(Recno())})
				AAdd(aRecNo, Work1->(Recno()) )
				Work1->(DbSkip())
			EndDo

			If Len(aRet) > 1
			   nATPos:= Len(aRet[1]) //redefinição do nAtPos, conforme posição do Recno no array
			EndIf
			Work1->(DbGoTop())

		Else
			SWN->(DbSetOrder(3))
			SW8->(DbSetOrder(6))
			SW3->(DbSetOrder(8))
         SD3->(DBSetOrder(8)) //D3_FILIAL+D3_DOC+D3_NUMSEQ
			If SWN->(DbSeek(xFilial("SWN") + SW6->W6_HAWB + '7')) //COMPLEMENTO_VL
				Do While SWN->(!Eof()) .And. SWN->WN_HAWB+SWN->WN_TIPO_NF == SW6->W6_HAWB + AvKey('7',"WN_TIPO_NF")
					If SWN->WN_DOC == AvKey(cDocSD3,"WN_DOC")

						SW8->(DbSeek(xFilial("SW8") + SWN->(WN_HAWB+WN_INVOICE+WN_PO_EIC+WN_ITEM+WN_PGI_NUM) ))
						SW3->(DbSeek(xFilial() + SWN->WN_PO_EIC + SWN->WN_ITEM ))
						SB1->(DbSeek(xFilial("SB1") + SWN->WN_PRODUTO ))
                  SD3->(DBSeek(xFilial() + cDocSD3 + SWN->WN_NUMSEQ))
                  cArmazem:= SD3->D3_LOCAL

						cStatus := If (!Empty(SWN->WN_NUMSEQ), cIntegra, cNaoIntegra)
						nPesoB  := If (SW8->(FieldPos("W8_PESO_BR")) > 0, SW8->W8_QTDE * SW8->W8_PESO_BR, 0)

						AAdd(aRet,{	cStatus, SWN->WN_NUMSEQ, SB1->B1_COD, SB1->B1_DESC, SWN->WN_QUANT, SWN->WN_UNI,;
										SWN->WN_PRUNI, SWN->WN_VALOR, SWN->WN_PESOL, nPesoB,;
										SWN->WN_PO_EIC, SW3->W3_CTCUSTO, SWN->WN_ADICAO, SWN->WN_SEQ_ADI, cArmazem, SWN->(Recno()) })

						If !Empty(SWN->WN_NUMSEQ)
						   AAdd(aRecNo, SWN->(Recno()) )
						EndIf

					EndIf
					SWN->(DbSkip())
				EndDo
				If Len(aRet) > 1
               nATPos:= Len(aRet[1]) //redefinição do nAtPos, conforme posição do Recno no array
				EndIf
			EndIf
		EndIf

	Case cAlias == "Work4"
		If nOp == 2 //Gerar
			Work4->(DbGoTop())

			Do While Work4->(!Eof())
				If !(Left(Work4->WKDESP,1) $ "129") .And. Empty(Work4->WKNOTA)
					SYB->(DbSeek(xFilial("SYB") + Left(Work4->WKDESP,3)) )
					If !SYB->YB_BASECUS $ cNao .And. !SYB->YB_BASEIMP $ cSim .And. !(SYB->YB_BASEICM $ cSim .And. DspBsIcmUF())
						cRatPeso := If(SYB->YB_RATPESO $ cSim, "S","N")
						AAdd(aRet,{ SYB->YB_DESP, SYB->YB_DESCR, Work4->WKVALOR, cRatPeso})
					EndIf
				EndIf
				Work4->(DbSkip())

			EndDo

			Work4->(DbGoTop())

		Else
			SWD->(DbSetOrder(1))

			If SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))

				Do While SWD->(!Eof())
					If SWD->WD_NF_COMP == AvKey(cDocSD3,"WD_NF_COMP")
						SYB->(DbSeek(xFilial("SYB") + SWD->WD_DESPESA) )
						cRatPeso := If(SYB->YB_RATPESO $ cSim, "S","N")
						AAdd(aRet,{ SYB->YB_DESP, SYB->YB_DESCR, SWD->WD_VALOR_R, cRatPeso})
					EndIF
					SWD->(DbSkip())
				EndDo

			EndIf
		EndIf

	OtherWise
		Break
	EndCase

End Sequence
Return aRet



/**************************
Funcao      : DI161DadosGrv
Parâmetros  : Arrays com os RecNo dos itens marcados para integração
Objetivos   : Posicionar na Work1 e retornar os array's aCab/aItem utilizados na integração MATA241
Retorno     : Array de dados
Autor       : Laércio G Souza Jr
Data/Hora   : 15/04/2016 - 14:04
***************************************************************************************************/
*----------------------------------------------*
Static Function DI161DadosGrv(nOp,aRecNo)
*----------------------------------------------*
Local _aDados		:= {}
Local _aCab		:= {}
Local _aTotItens	:= {}
Local nCont		:= 0
Local cMoedaCM := ""
Local cMoeCaract := ""
Local nTamcMoeda := 0
Local nX			:= 1

Default aRecNo	:= {}
Default nOp		:= 0 //1-Visualizar, 2-Gerar, 3-Estornar

Begin Sequence

	If nOp == 0 .Or. (lRet := Len(aRecNo)) == 0
		Break
	EndIf

	/*********
	Montagem do array _aCab
	************************/
	If !Empty(cDocumento)
		aAdd(_aCab, {"D3_DOC"	,cDocumento	,Nil} )
	EndIf
	aAdd(_aCab, {"D3_TM"			,cTM			,NIL} )
	If !Empty(cCC)
		aAdd(_aCab, {"D3_CC"		,cCC			,NIL} )
	EndIf
	aAdd(_aCab, {"D3_EMISSAO"	,dDataBase		,NIL} )

	If nOp == 2
		/*********
		Montagem do array _aItem
		************************/
		For nCont	:= 1 To Len(aRecNo)
			_aItem	:= {}
			Work1->(DbGoTo( aRecNo[nCont] ) )
			RecLock("Work1",.F.)
			Work1->WKLINHA := nCont
			Work1->(MsUnlock())

			cPosIt	:= StrZero(nCont, AvSx3("D3_ITEMSWN",AV_TAMANHO))
			SB1->(DbSeek(xFilial("SB1")+AvKey(Work1->WKCOD_I,"B1_COD")))

			aAdd(_aItem, {"D3_COD"		, SB1->B1_COD			,Nil} )
			aAdd(_aItem, {"D3_UM"		, SB1->B1_UM			,Nil} )
			aAdd(_aItem, {"D3_QUANT"		, 0						,Nil} ) //(sempre 0 - zero)
			aAdd(_aItem, {"D3_CUSTO1"	, Work1->WKVALMERC	,Nil} )
			
			cMoedaCM := Alltrim(EasyGParam('MV_MOEDACM',.F.,"2345"))
			nTamcMoeda := Len(Alltrim(cMoedaCM))
			For nX := 1 to nTamcMoeda
				cMoeCaract := LEFT(cMoedaCM, 1)								
				If SD3->( FieldPos("D3_CUSTO"+cMoeCaract) ) > 0
					aAdd(_aItem, {"D3_CUSTO"+cMoeCaract	, xMoeda(Work1->WKVALMERC, 1, Val(cMoeCaract), dDataBase)	,Nil} )
				EndIf	
				cMoedaCM := RIGHT(cMoedaCM, nTamcMoeda-nX)
			Next nX

			//aAdd(_aItem, {"D3_LOCAL"	, If(EasyGParam("MV_EASY",,"N") == "S",aWork1[oBrowseWN:nAt][14],DI154BuscLoc())		,Nil} ) //(usar a função BuscaLocPNota)
			aAdd(_aItem, {"D3_LOCAL"	, If(EasyGParam("MV_EASY",,"N") == "S",aWork1[AScan(aWork1, {|x| x[nATPos] == aRecNo[nCont]})][AScan(aCamposWN, "D3_LOCAL")],DI154BuscLoc())		,Nil} ) //(usar a função BuscaLocPNota)
			aAdd(_aItem, {"D3_USUARIO"	, cUserName			,Nil} )
			aAdd(_aItem, {"D3_HAWB"		, SW6->W6_HAWB		,Nil} )
			aAdd(_aItem, {"D3_ITEMSWN"	, cPosIt				,Nil} )

			If lEnvCcItem
				SW3->(DbSetOrder(8))
				SW3->(DbSeek(xFilial() + Work1->WKPO_NUM + Work1->WKPOSICAO))
				aAdd(_aItem, {"D3_CC"	, SW3->W3_CTCUSTO		,Nil} )
			EndIf

			IF lLote .AND. SD1->(FIELDPOS("D3_LOTECTL")) # 0 .AND. SD1->(FIELDPOS("D3_DTVALID")) # 0
			   SB1->(DBSEEK(xFilial("SB1")+Work1->WKCOD_I))
			   IF SB1->B1_RASTRO $ "SL" .AND. !EMPTY(Work1->WK_LOTE)
			      AADD(_aItem,{"D3_LOTECTL",Work1->WK_LOTE  ,})
			      IF !EMPTY(Work1->WKDTVALID)
			         AADD(_aItem,{"D3_DTVALID",Work1->WKDTVALID,})
			      ENDIF
			   ENDIF
			ENDIF
			aAdd(_aTotItens,_aItem)
		Next
	EndIf

	If nOp == 3
		/*********
		Montagem do array _aItem
		************************/
		For nCont	:= 1 To Len(aRecNo)
			oBrowseWN:GoTo(aRecNo[nCont],.F.)
			_aItem	:=	{}
			_aItem	:=	{{"D3_COD" , aWork1[oBrowseWN:nAt][3] ,NIL}}
			aAdd(_aTotItens,_aItem)
		Next
	EndIf

	aAdd(_aDados,{ {"aCab",_aCab} , {"aItem",_aTotItens} })

End Sequence

Return _aDados



/************************
Funcao      : DI161DocSD3
Parâmetros  : Processo(W6_HAWB)
Objetivos   : Posicionar a SD3 e filtrar todos os documentos gerados para o processo
Retorno     : Array de dados
Autor       : Laércio G Souza Jr
Data/Hora   : 19/04/2016 - 14:04
****************************************************************************************/
*----------------------------------------------*
Static Function DI161DocSD3(cHawb)
*----------------------------------------------*
Local aRet		:= {}
Local cQuery1	:= ""
Local cWhere1	:= ""

	If TcSrvType() <> "AS/400"
		cWhere1:= RetSqlCond("SD3")
	Else
		cWhere1:= "SD3.D3_FILIAL = '" + SD3->(xFilial()) + "'"
	EndIf

	cQuery1:=	"Select Distinct D3_DOC , D3_TM, "+;
	              " D3_EMISSAO From " +;
					RetSqlName("SD3") + " SD3 " +;
					" Where " + cWhere1 +;
						" And SD3.D3_HAWB = '" + cHawb + "'"+;
						" And SD3.D3_ESTORNO <> 'S'" +;
						" And SD3.D_E_L_E_T_ <> '*'"

	//Montagem da Query
	cQuery1:= ChangeQuery(cQuery1)
	TcQuery cQuery1 Alias "TMPDOC" New

	EasyTCFields("TMPDOC")

	If !TMPDOC->(Bof()) .Or. !TMPDOC->(Eof())
		Do While TMPDOC->(!Eof())
			aAdd(aRet, {TMPDOC->D3_DOC, TMPDOC->D3_TM, TMPDOC->D3_EMISSAO, TMPDOC->(RecNo()) } )
			TMPDOC->(DbSkip())
		EndDo
	EndIf
	TMPDOC->(DBCloseArea())
Return aRet



/*************************
Funcao      : DI161LoadVar
Objetivos   : Carregar as variavies do EICDI154 para gravar a SWN na função DI154GerNF
****************************************************************************************/
*----------------------------------------------*
Static Function DI161LoadVar()
*----------------------------------------------*
//EICDI154
/** PRIVATES EICDI154
********************/
nTipoNF 			:=	7 //COMPLEMENTO_VL
bDDIFor			:=	{||At(SWD->(Left(SWD->WD_DESPESA,1)),"129") = 0 .AND. If(!lGravaWorks, Empty(SWD->WD_NF_COMP), SWD->WD_NF_COMP+SWD->WD_SE_NFC=cNota) }
bDDIWhi			:=	{||xFILIAL("SWD")==SWD->WD_FILIAL .AND. SWD->WD_HAWB == SW6->W6_HAWB}
lGerouNFE			:=	.F.
lMV_EASYSIM		:= 	EasyGParam("MV_EASY",,"N") $ cSim
lTemDespBaseICM	:= 	SX3->(DBSEEK("WN_DESPICM"))
lMV_PIS_EIC		:= 	EasyGParam("MV_PIS_EIC",,.F.) .AND. SWN->(FIELDPOS("WN_VLRPIS")) # 0 .AND. SYD->(FIELDPOS("YD_PER_PIS")) # 0 .AND. FindFunction("DI500PISCalc")
lCposCofMj			:=	SYD->(FieldPos("YD_MAJ_COF")) > 0 .And. SYT->(FieldPos("YT_MJCOF")) 	> 0 .And. SWN->(FieldPos("WN_VLCOFM")) 	> 0 .And.;                                                    //NCF - 20/07/2012 - Majoração PIS/COFINS
						SWN->(FieldPos("WN_ALCOFM"))  > 0 .And. SWZ->(FieldPos("WZ_TPCMCOF")) > 0 .And. SWZ->(FieldPos("WZ_ALCOFM")) 	> 0 .And.;
						EIJ->(FieldPos("EIJ_ALCOFM")) > 0 .And. SW8->(FieldPos("W8_VLCOFM")) 	> 0 .And. EI2->(FieldPos("EI2_VLCOFM")) 	> 0 .And.;
						SWN->(FieldPos("WN_VLCOFM"))  > 0 .And. SWN->(FieldPos("WN_ALCOFM")) 	> 0
lCposPisMj			:= 	SYD->(FieldPos("YD_MAJ_PIS")) > 0 .And. SYT->(FieldPos("YT_MJPIS")) 	> 0 .And. SWN->(FieldPos("WN_VLPISM")) 	> 0 .And.;                                                    //NCF - 20/07/2012 - Majoração PIS/COFINS
						SWN->(FieldPos("WN_ALPISM"))  > 0 .And. SWZ->(FieldPos("WZ_TPCMPIS")) > 0 .And. SWZ->(FieldPos("WZ_ALPISM")) 	> 0 .And.;
						EIJ->(FieldPos("EIJ_ALPISM")) > 0 .And. SW8->(FieldPos("W8_VLPISM")) 	> 0 .And. EI2->(FieldPos("EI2_VLPISM")) 	> 0 .And.;
						SWN->(FieldPos("WN_VLPISM"))  > 0 .And. SWN->(FieldPos("WN_ALPISM")) 	> 0
lLote				:=	EasyGParam("MV_LOTEEIC",,"N") $ cSim
lExisteSEQ_ADI	:=	SW8->(FIELDPOS("W8_SEQ_ADI")) # 0 .AND.;
                    	SWN->(FIELDPOS("WN_SEQ_ADI")) # 0 .AND.;
                    	SW8->(FIELDPOS("W8_GRUPORT")) # 0 //AWR - 18/09/08 NFE
lMV_GRCPNFE		:=	EasyGParam("MV_GRCPNFE",,.F.) .AND.; //AWR - 04/11/08 - Indica se integracao vai gravar (T) ou não (F) os campos novos da NFE
						SWN->(FIELDPOS("WN_PREDICM")) # 0 .AND. SWN->(FIELDPOS("WN_DESCONI")) # 0 .AND.;
   						SWN->(FIELDPOS("WN_VLRIOF"))  # 0 .AND. SWN->(FIELDPOS("WN_DESPADU")) # 0 .AND.;
  						SWN->(FIELDPOS("WN_ALUIPI"))  # 0 .AND. SWN->(FIELDPOS("WN_QTUIPI"))  # 0 .AND.;
   						SWN->(FIELDPOS("WN_QTUPIS"))  # 0 .AND. SWN->(FIELDPOS("WN_QTUCOF"))  # 0
lAcresDeduc		:=	SWN->(FIELDPOS("WN_VLACRES")) # 0 .AND. SWN->(FIELDPOS("WN_VLDEDUC")) # 0 .AND. ;// Bete - 24/07/04 - Inclusao de Acrescimos e deducoes na base de impostos
						EI2->(FIELDPOS("EI2_VACRES")) # 0 .AND. EI2->(FIELDPOS("EI2_VDEDUC")) # 0 .AND. SX3->(dbSeek("EIU"))
lICMS_Dif			:=	SWZ->( FieldPos("WZ_ICMSUSP") > 0 .AND. FieldPos("WZ_ICMSDIF") > 0  .AND.  FieldPos("WZ_ICMS_CP") > 0  .AND.  FieldPos("WZ_ICMS_PD") > 0  )  ;
						.AND.  SWN->( FieldPos("WN_VICM_PD") > 0  .AND.  FieldPos("WN_VICMDIF") > 0  .AND.  FieldPos("WN_VICM_CP") > 0 )
// EOB - 16/02/09
lICMS_Dif2			:=	SWZ->( FieldPos("WZ_PCREPRE") ) > 0 .AND. SWN->( FieldPos("WN_PICM_PD") > 0  .AND.  FieldPos("WN_PICMDIF") > 0  .AND.  FieldPos("WN_PICM_CP") > 0 .AND. FieldPos("WN_PLIM_CP") > 0 )
lTemCposOri		:=	SWN->( FIELDPOS("WN_DOCORI")) # 0 .AND. SWN->(FIELDPOS("WN_SERORI")) # 0//AWF - 31/07/2014
lTipoCompl			:=	.T.
lAtuSW6NFE			:=	.F.
lGravaSWW			:= 	.F.
lGravaWorks		:=	.F.
lMV_NF_MAE			:=	EasyGParam("MV_NF_MAE",,.F.)
lCposNFDesp		:=	(SWD->(FIELDPOS("WD_B1_COD")) # 0 .And. SWD->(FIELDPOS("WD_DOC")) # 0 .And. SWD->(FIELDPOS("WD_SERIE")) # 0;                   //NCF - Campos da Nota Fiscal de Despesas
						.And. SWD->(FIELDPOS("WD_ESPECIE")) # 0 .And. SWD->(FIELDPOS("WD_EMISSAO")) # 0 .AND. SWD->(FIELDPOS("WD_B1_QTDE")) # 0;
						.And. SWD->(FIELDPOS("WD_TIPONFD")) # 0)
lTemYB_ICM_UF		:=	SYB->(FIELDPOS(cCpoBasICMS)) # 0
lNfeCompVL			:= .T.
lGrvItem			:= .T.
Return Nil

*----------------------------------------------*
Static Function DI161SetLoc(o)
*----------------------------------------------*
Local cLocal := aWork1[o:nAt][14]

//If ConPad1(,,, "SBF",,, .F.)
If ConPad1(,,, "NNR",,, .F.)
   cLocal := NNR->NNR_CODIGO //SBE->BE_LOCAL
   If !Empty(cLocal) .AND. aWork1[o:nAt][14] <> cLocal
      aWork1[o:nAt][14] := cLocal
   EndIf
EndIf

Return .T.

*----------------------------------------------*
Static Function DspBsIcmUF(lMsg)
*----------------------------------------------*
Local lRet   := .F.
Local cCpoBasICMS
Default lMsg := .F.

SYT->(DBSETORDER(1))
SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
cCpoBasICMS:="YB_ICMS_"+Alltrim(SYT->YT_ESTADO)
lTemYB_ICM_UF:=SYB->(FIELDPOS(cCpoBasICMS)) # 0

If lTemYB_ICM_UF .AND. SYB->(FIELDGET(FIELDPOS(cCpoBasICMS))) $ cSim
   lRet := .T.
EndIf

Return lRet


Static Function AlteraArmz(cArmDe,cArmPara)
Local lRet := .F.
Local lChangeArm := .F.
Do Case 
	Case Empty(cArmDe) .Or. Empty(cArmPara)
   		MsgStop(STR0050) //"Um dos armazéns (de origem ou de destino) não foi informado !"
   		lRet := .F.
	Case cArmDE == cArmPara
		MSgStop(STR0051)//"Deve ser informado um armazém diferente da origem para que ocorra a alteração!"
	    lRet := .F.
	OtherWise
		Work1->(DbGoTop())
		Do While Work1->(!Eof())
			If (nPos := aScan( aWork1 , {|x|x[15] == Work1->(recno())} ) ) > 0 .And. aWork1[nPos][14] == cArmDe .And. aScan(aRecno,Work1->(recno())) > 0  //Listado, com o mesmo armazem do campo "DE" e Marcado.
			   	lChangeArm := .T.
				aWork1[nPos][14] := cArmPara
			EndIf
			Work1->(DbSkip())
		EndDo
		If !lChangeArm
			MsgStop(STR0052)//"Não existem itens marcados que possuam o armazém informado para a troca no campo 'DE:'."
		Else
			MsgInfo(STR0053)//"Armazém alterado com sucesso para os itens selecionados!"
			lRet := .T.
		EndIf
EndCase

Return lRet

*--------------------------------------------------------------------------------------*
*                             FIM DO PROGRAMA EICDI161.PRW                             *
*--------------------------------------------------------------------------------------*
