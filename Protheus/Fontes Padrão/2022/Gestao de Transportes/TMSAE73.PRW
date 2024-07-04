#INCLUDE "Tmsae73.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TOTVS.CH"

#DEFINE CTMARCA  1
#DEFINE CTCORBRW 2
#DEFINE CTDATMAN 3
#DEFINE CTHORMAN 4
#DEFINE CTFILMAN 5
#DEFINE CTMANIFE 6
#DEFINE CTSERMAN 7
#DEFINE CTFILORI 8
#DEFINE CTVIAGEM 9 // Utilizado no Serie Prothues T
#DEFINE CTNUMROM 9 // Utilizado no Serie Prothues 3
#DEFINE CTRTIMDF 10
#DEFINE CTRTFMDF 11
#DEFINE CTFIMP   12
#DEFINE CTDTXREC 13
#DEFINE CTSTIMDF 14
#DEFINE CTSTFMDF 15
#DEFINE CTCODEVE 16
#DEFINE CTRTCOND 17
#DEFINE CTCODMOT 18
#DEFINE CTNOMMOT 19
#DEFINE CTPRMACO 20
#DEFINE CTDESEVE 21
#DEFINE CTNUMCTC 22

#DEFINE TAMMAXXML 400000 //- Tamanho maximo do XML em  bytes

#DEFINE cCDEVECAN '110111'  //- Codigo do Evento de Cancelamento
#DEFINE cCDEVEENC '110112'  //- Codigo do Evento de Encerramento
#DEFINE cCDEVINCO '110114'  //- Codigo do Evento de Inclusao de Condutor
#DEFINE cCDEVPGTO '110116'	//- Codigo do Evento de Pagamento de Frete

#DEFINE nPOSNOMFOR 1 //--Nome do Fornecedor
#DEFINE nPOSTIPFOR 2 //--Tipo de Fornecedor (Operador de Frete) Fisico,Juridco ou Estrangerio
#DEFINE nPOSCNPJOP 3
#DEFINE nPOSAGENCI 4
#DEFINE nPOSBANCO  5
#DEFINE nPOSVALFRE 6
#DEFINE nPOSADIFRE 7
#DEFINE nPOSIRRF   8
#DEFINE nPOSSEST   9	
#DEFINE nPOSINSS   10
#DEFINE nPOSISS	   11
#DEFINE nPOSPIS    12
#DEFINE nPosCOFINS 13
#DEFINE nPosCSLL   14	
#DEFINE nPOSDADPAG 15

#DEFINE nCmpTIPO   1
#DEFINE nCmpCODPAS 2
#DEFINE nCmpDESCRI 3
#DEFINE nCmpVALPAS 4

#DEFINE nBANCNPJOP 3
#DEFINE nBANAGENCI 4
#DEFINE nBANCODIGO 5

Static lTME73ENC:= ExistBlock("TME73ENC")
Static lTME73ALT:= ExistBlock("TME73ALT")
Static cTpEvento:= ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSAE73   ³ Autor ³Katia                  ³ Data ³04.04.2013|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento do MDFe, painel contendo os Manif.  ³±±
±±³          ³de acordo com os parametros selecionados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Numero, origem da funcao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE73(cFilOri,cViagem,cTipo,cFilMan,cManife,cSerman,nOper,aDocs)

	Local cIdEnt    := ""
	Local aPerg     := {}
	Local aSize     := {}
	Local aObjects  := {}
	Local aListBox  := {}
	Local aInfo     := {}
	Local aPosObj   := {}
	Local nCntFor   := 0
	Local nPosBut   := 0	
	Local lTmsae73C := IIf(ExistFunc('TmsChekSX1'),TmsChekSX1('TMSAE73C'),.F.)
	Local cPerg     := If(!IsInCallStack("TMSAE73B"), (IIf(lTmsae73C,'TMSAE73C','TMSAE73')),'TMSAE73B')
	Local oOk       := LoadBitMap(GetResources(),"LBOK")
	Local oNo       := LoadBitMap(GetResources(),"LBNO")
	Local oBtn01
	Local oBtn02
	Local oBtn03
	Local oBtn05
	Local oBtn06
	Local oBtn07
	Local oBtn08
	Local oBtn09
	Local oBtn10
	Local oBtn11
	Local oBtn12
	Local oBtn13
	Local oBtnUser
	Local oDlg     := Nil
	Local lPergunte:= .T.
	Local lMarcaUm := .F.
	Local cDescTit1:= ""
	Local cDescTit2:= ""
	Local cDescTit3:= ""
	Local nMilissegundos
	Local oTimer
	Local aSetKey	:= {}
	Local lMDFEAUT 	:= SuperGetMv('MV_MDFEAUT',,.F.) .And. ExistFunc("TmsMDFeAut") //--MDFe Automático 
	Local lRotAut  	:= IsInCallStack("TmsMDFeAut")
    Local lVisual   := If(IsInCallStack("TMSAE73B"), .T., .F.)
    Local lBtnUser  := Iif(lVisual,.F.,ExistBlock("TME73BUT")) //Ponto de Entrada para criação de botões adicionais no Painel do MDF-e
	Local cLine     := ""
	Local cLineDef	:= ""
	Local nCountPE  := 0

	Local aAreas    := {}

	Default cFilOri := ""
	Default cViagem := ""
	Default cTipo   := "" //2-Encerramento, 3-Cancelamento
	Default cFilMan := ""
	Default cManife := ""
	Default cSerman := ""
	Default nOper   := 1
	Default aDocs := {}

	Private oListBox  := Nil
	Private oQtdDoc   := Nil
	Private oQtdMrk   := Nil
	Private nQtdDoc   := 0
	Private nQtdMrk   := 0
	Private lExecAuto := .F.
	Private cCadastro := STR0041
//-- Checkbox
	Private lAllMark := .F.	// Usado para o controle da marca de todos os documentos
	Private aDocMark := {}	//-- Doctos Marcados

	Private lEncerra 	:= .F.
	Private lCancela 	:= .F.
	Private lEnvia   	:= .F.
	Private lInCond  	:= .F.
	Private lUsaColab 	:= .F.
	Private lConsNE		:= .F.
	Private lPagFrete	:= .F.
	Private MV_PAR01TM 	:= 0
	Private MV_PAR02TM	
	Private aHeaders   := {}

	lUsaColab := UsaColaboracao("5")
	If lUsaColab
		//-- TOTVS Colaboracao 2.0
		lUsaColab := ColCheckUpd()
		If !lUsaColab
			MsgInfo(STR0099)	//-- "UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0"
		EndIf
	EndIf

	//Estas colunas aparecem em qualquer visualização do MDFe
	cLineDef := " { If(!lVisual,Iif( aListBox[ oListBox:nAT, " + AllTrim(Str(CTMARCA)) + " ] == '1',oOk,oNo),''),"
	cLineDef += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTCORBRW)) + " ], " 
	cLineDef += " Iif(aListBox[ oListBox:nAT, " + AllTrim(Str(CTFIMP)) + "] == '1','Impresso','Não Impresso'), "
	cLineDef +=	" aListBox[ oListBox:nAT, " + AllTrim(Str(CTDATMAN)) + "], "
	cLineDef +=	" aListBox[ oListBox:nAT, " + AllTrim(Str(CTHORMAN)) + "], "
	cLineDef +=	" aListBox[ oListBox:nAT, " + AllTrim(Str(CTFILMAN)) + "], "
	cLineDef +=	" aListBox[ oListBox:nAT, " + AllTrim(Str(CTMANIFE)) + "], "
	cLineDef +=	" aListBox[ oListBox:nAT, " + AllTrim(Str(CTSERMAN)) + "], "
	cLineDef += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTFILORI)) + "], "

	If ExistFunc("TmsAutViag") .And. DTQ->(ColumnPos("DTQ_CODAUT")) > 0
		aAreas := {DTQ->(GetArea()),GetArea()}
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("") + cFilOri + cViagem))
			If TmsAutViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA190")
				lMDFeAut := .T.
			EndIf
		EndIf
		AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	EndIf

	If lMDFEAUT .And. lRotAut .And. (nOper == 2 .Or. nOper == 1)//--MDFE Automático/ Encerramento/ Envio
		Pergunte(cPerg,.F.)		
		Mv_Par01 := aDocs[1][2]  //--Manifesto De:
		Mv_Par02 := aDocs[Len(aDocs),3] //--Manifesto Até:
		Mv_Par05 := dDataBase

        If !lVisual
            If nOper == 2 
                Mv_Par06 := IIf(cPerg=="TMSAE73C",cValToChar(nOper),nOper)	  //--Encerramento			
            ElseIf nOper == 1 
                Mv_Par06 := IIf(cPerg=="TMSAE73C",cValToChar(nOper),nOper)	 //--Envio	
            EndIf
        
            If Empty(cTipo)
                cTipo := MV_PAR07
            EndIf
            
            Aadd(aPerg,{Mv_Par01, Mv_Par02, Mv_Par03, Dtos(Mv_Par04), Dtos(Mv_Par05), Mv_Par06,cTipo,Mv_Par08})
        Else
            Aadd(aPerg,{Mv_Par01, Mv_Par02, Mv_Par03, Dtos(Mv_Par04), Dtos(Mv_Par05)})
        EndIf
	Else
        If !lVisual
            lPergunte:= Pergunte(cPerg,Iif(!Empty(cTipo),.F.,.T.) )

            If !lPergunte
                Return (Nil)
            EndIf

            If Empty(cTipo)
                cTipo := MV_PAR07
            EndIf		
            
            Aadd(aPerg,{Mv_Par01, Mv_Par02, Mv_Par03, Dtos(Mv_Par04), Dtos(Mv_Par05),Mv_Par06,cTipo,Mv_Par08})
        Else
            lPergunte:= Pergunte(cPerg,.T.)

            If !lPergunte
                Return (Nil)
            EndIf
            Aadd(aPerg,{Mv_Par01, Mv_Par02, Mv_Par03, Dtos(Mv_Par04), Dtos(Mv_Par05)})
        EndIf
	EndIf
	//-- Teclas de Atalhos
	AAdd(aSetKey, { VK_F12 , { || Pergunte('TMSAE73A',.T.,,,,.T.), TMSAE73TMR() } } )

	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)

    If lVisual
        cDescTit1 := STR0009
        cDescTit2 := STR0107
    ElseIf aPerg[1][6] = IIf(cPerg=="TMSAE73C",'2',2)   	//Encerramento
        lEncerra  := .T.
        lCancela  := .F.
        lEnvia    := .F.
        lInCond   := .F.
        cTpEvento := cCDEVEENC
        cDescTit1 := STR0010
        cDescTit2 := STR0009
    ElseIf aPerg[1][6] = IIf(cPerg=="TMSAE73C",'3',3)  //Cancelamento
        lEncerra  := .F.
        lCancela  := .T.
        lEnvia    := .F.
        lInCond   := .F.
        cTpEvento := cCDEVECAN
        cDescTit1 := STR0063
        cDescTit2 := STR0009
    ElseIf aPerg[1][6]= IIf(cPerg=="TMSAE73C",'4',4)  //Consulta MDF-e não encerrado
        lEncerra  := .F.
        lCancela  := .F.
        lEnvia    := .F.
        lInCond   := .F.
        lConsNE	:= .T.
        cTpEvento := ""
    ElseIf aPerg[1][6]= IIf(cPerg=="TMSAE73C",'5',5)  //Inclusao de Condutor
        lEncerra  := .F.
        lCancela  := .F.
        lEnvia    := .F.
        lInCond   := .T.
        cTpEvento := cCDEVINCO
        cDescTit1 := STR0072 //Motorista
        cDescTit2 := STR0073 //Nome Motorista
        cDescTit3 := STR0065 //Retorno SEFAZ Inc. Condutor
	Elseif aPerg[1][6]= IIf(cPerg=="TMSAE73C",'6',5)  //Pagamento de Frete
		lEncerra  := .F.
        lCancela  := .F.
        lInCond   := .F.
        lEnvia    := .F.
		lPagFrete := IIf (DLI->(ColumnPos('DLI_STAEVE')) > 0,.T.,.F.)
        cTpEvento := cCDEVPGTO
        cDescTit1 := STR0108 //"Contrato Carreteiro"
        cDescTit2 := STR0109 //"Retorno do Evento  Pagamento SEFAZ"
	Else              //Envio
        lEncerra  := .F.
        lCancela  := .F.
        lInCond   := .F.
        lEnvia    := .T.
        cTpEvento := ""
        cDescTit1 := STR0009
        cDescTit2 := STR0010
    EndIf

	If lConsNE
		TME73CONSE()
	Else
		If CTIsReady(,,,lUsaColab)
			cIdEnt := RetIdEnti(lUsaColab)
		EndIf
	EndIf

	CursorWait()
	TME73LST(@aListBox, aPerg, Iif(lMDFEAUT,aDocs,Nil),lVisual)
    If lVisual
        lCancela := .T.
        TME73LST(@aListBox, aPerg, Iif(lMDFEAUT,aDocs,Nil),lVisual)
        aSort(aListBox,,, {|x,y| !Empty(x[CTDATMAN]) .AND. !Empty(y[CTDATMAN]) .AND. DTOS(x[CTDATMAN])+x[CTHORMAN] < DTOS(y[CTDATMAN])+y[CTHORMAN]})
        lCancela := .F.
    EndIf
   
	CursorArrow()

	aSize    := MsAdvSize(.F. )
	aObjects := {}

	AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 020, .F., .F. } )
	If lBtnUser
		AAdd( aObjects, { 100, 020, .F., .F. } )
	EndIf

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL	//-- "Monitor - (MDF-e) Manifesto Eletronico"

	oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)

    If !lVisual
        @ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0002 SIZE 168, 08; //-- Marca/Desmarca Todos
            ON CLICK(TME73All(aListBox,lMarcaUm)) OF oPanel PIXEL
    EndIf

	@ 007,090 SAY STR0101 OF oPanel PIXEL	//-- "Qtde. Total de Documentos: "

	If Len(aListBox) > 0 .AND. !Empty(aListBox[1,CTMANIFE])
		nQtdDoc := Len(aListBox)
	EndIf

	@ 005,157 MSGET oQtdDoc VAR nQtdDoc OF oPanel PIXEL PICTURE '@E 999,999,999'
    If !lVisual
        @ 007,230 SAY STR0100  OF oPanel PIXEL	//-- "Qtde. de Documentos Marcados: "
        @ 005,311 MSGET oQtdMrk VAR nQtdMrk OF oPanel PIXEL PICTURE '@E 999,999,999'
    EndIf
    
	If __lPyme
			//-- Cabecalho dos campos do Monitor.
		@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields;			
		SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL 

		aHeaders := { "","",STR0011,STR0003,STR0004,STR0005,STR0006,STR0064,STR0007,"Num. Rom.",cDescTit1,cDescTit2} //--Dt Manifesto - Hr Manifesto - Fil Man - Manifesto - Fil Ori - Viagem - Ret SEFAZ
	Else
			//-- Cabecalho dos campos do Monitor.
		@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields ;			
		SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL

		aHeaders := { "","",STR0011,STR0003,STR0004,STR0005,STR0006,STR0064,STR0007,STR0008,cDescTit1, cDescTit2 } //--Dt Manifesto - Hr Manifesto - Fil Man - Manifesto - Fil Ori - Viagem - Ret SEFAZ
	EndIf

 	If __lPyme  // Para Geração do MDFe no Serie 3
		If lEnvia .OR. lVisual
			cLine := cLineDef
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTNUMROM)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTIMDF)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTFMDF)) + "] "
		Else
			cLine := cLineDef
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTNUMROM)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTFMDF)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTIMDF)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTSTFMDF)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTSTIMDF)) + "]"
		EndIf
	Else
		If lEnvia .OR. lVisual
			cLine := cLineDef
			cLine += "	aListBox[ oListBox:nAT, " + AllTrim(Str(CTVIAGEM)) + "], "
			cLine += "	aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTIMDF)) + "], "
			cLine += "	aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTFMDF)) + "]"
	ElseIf lInCond
			aAdd(aHeaders, cDescTit3) 
			cLine := cLineDef
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTVIAGEM)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTCODMOT)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTNOMMOT)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTCOND)) + "]"
	ElseIf lPagFrete			
			cLine := cLineDef
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTVIAGEM)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTNUMCTC)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTDESEVE)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTCODEVE)) + "]"
		Else
			cLine := cLineDef
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTVIAGEM)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTFMDF)) + "], "
			cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(CTRTIMDF)) + "] "
		EndIf
	EndIf

	If ExistBlock("TME73CAB")
		aRetPE := ExecBlock("TME73CAB",.F.,.F., {aListBox, lEnvia, lVisual, lInCond, lPagFrete })
		If	ValType(aRetPE) == "A"			
			For nCountPE := 1 To Len(aRetPE)
				cLine := cLine + ", " 
				aAdd(aHeaders, aRetPE[nCountPE]) 
				cLine += " aListBox[ oListBox:nAT, " + AllTrim(Str(22+nCountPE)) + "]"
			Next nCountPE
		EndIf
	EndIf
	cLine += "}" 

	oListBox:aHeaders := aHeaders
	oListBox:SetArray( aListBox )
	oListBox:bLDblClick := { || If (!lVisual,TME73Mrk(aListBox,,,,,lMarcaUm),.F.) }	
	oListBox:bLine 	  := { || &cLine }

	//-- Botoes da tela do monitor.
    If !lVisual
        @ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 PROMPT STR0012 ACTION TME73Leg()										OF oDlg PIXEL SIZE 035,011	//-- "Legenda"
        @ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn02 PROMPT STR0013 ACTION TME73Mon(aListBox,aPerg,cTpEvento,aDocs)	    	OF oDlg PIXEL SIZE 035,011	//-- "Monitor"
        @ aPosObj[3,1],aPosObj[3,4] - 020 BUTTON oBtn03 PROMPT STR0011 ACTION TmsVerMDFe(aDocs)									OF oDlg PIXEL SIZE 035,011	//-- "Damdfe"
        @ aPosObj[3,1],aPosObj[3,4] + 020 BUTTON oBtn05 PROMPT STR0015 ACTION TME73Env(aListBox, aPerg,,aDocs)					OF oDlg PIXEL SIZE 035,011	//-- "Transmitir"
        @ aPosObj[3,1],aPosObj[3,4] + 060 BUTTON oBtn06 PROMPT STR0016 ACTION TME73STA(aListBox, aPerg, cIdent, aDocs)			OF oDlg PIXEL SIZE 035,011	//-- "Status"
        @ aPosObj[3,1],aPosObj[3,4] + 100 BUTTON oBtn07 PROMPT STR0019 ACTION TME73Rfs(@aListBox,aPerg,aDocs)				 	OF oDlg PIXEL SIZE 035,011	//-- "Refresh"
        @ aPosObj[3,1],aPosObj[3,4] + 140 BUTTON oBtn08 PROMPT STR0017 ACTION TME73Psq(aListBox)								OF oDlg PIXEL SIZE 035,011	//-- "Pesquisar"
        @ aPosObj[3,1],aPosObj[3,4] + 180 BUTTON oBtn09 PROMPT STR0018 ACTION TMS73Vis(aListBox)								OF oDlg PIXEL SIZE 035,011	//-- "Visualizar"
        @ aPosObj[3,1],aPosObj[3,4] + 220 BUTTON oBtn10 PROMPT STR0020 ACTION TME73Par()										OF oDlg PIXEL SIZE 035,011	//-- "Parametros"
        @ aPosObj[3,1],aPosObj[3,4] + 260 BUTTON oBtn11 PROMPT STR0088 ACTION SpedExport(4)										OF oDlg PIXEL SIZE 035,011	//-- "Exportar"
        @ aPosObj[3,1],aPosObj[3,4] + 300 BUTTON oBtn13 PROMPT STR0106 ACTION SpedExport(5)										OF oDlg PIXEL SIZE 050,011	//-- "Exportar Antigos"
    Else
        @ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 PROMPT STR0012 ACTION TME73Leg()										OF oDlg PIXEL SIZE 035,011	//-- "Legenda"
        @ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn03 PROMPT STR0011 ACTION TmsVerMDFe(aDocs)									OF oDlg PIXEL SIZE 035,011	//-- "Damdfe"
        @ aPosObj[3,1],aPosObj[3,4] - 020 BUTTON oBtn08 PROMPT STR0017 ACTION TME73Psq(aListBox)								OF oDlg PIXEL SIZE 035,011	//-- "Pesquisar"
        @ aPosObj[3,1],aPosObj[3,4] + 020 BUTTON oBtn09 PROMPT STR0018 ACTION TMS73Vis(aListBox)								OF oDlg PIXEL SIZE 035,011	//-- "Visualizar"
        @ aPosObj[3,1],aPosObj[3,4] + 060 BUTTON oBtn11 PROMPT STR0088 ACTION SpedExport(4)										OF oDlg PIXEL SIZE 035,011	//-- "Exportar"
    EndIf

	If lBtnUser
		If !lUsaColab
            If !lVisual
			    nPosBut := 300
            Else
                nPosBut := 060
            EndIf
		Else
			nPosBut := 220
		EndIf
		aBtnUser := ExecBlock("TME73BUT",.F.,.F.)
		If	ValType(aBtnUser) == "A" .And. Len(aBtnUser) > 0
			For nCntFor:=1 To Len(aBtnUser) //Atraves do ponto de entrada só é possivel adicionar 6 botões
				If nCntFor = 1
					nPosBut += 40
					@ aPosObj[3,1],aPosObj[3,4] + nPosBut BUTTON oBtnUser PROMPT aBtnUser[nCntFor,1] ACTION Eval(aBtnUser[1,2],aListBox[oListBox:nAT,CTFILMAN],aListBox[ oListBox:nAT,CTMANIFE],aListBox[ oListBox:nAT,CTSERMAN], oListBox:nAT) OF oDlg PIXEL SIZE 035,011	//-- "Descricao do Usuario"
				ElseIf nCntFor = 2
					nPosBut += 40
					@ aPosObj[3,1],aPosObj[3,4] + nPosBut BUTTON oBtnUser PROMPT aBtnUser[nCntFor,1] ACTION Eval(aBtnUser[2,2],aListBox[oListBox:nAT,CTFILMAN],aListBox[ oListBox:nAT,CTMANIFE],aListBox[ oListBox:nAT,CTSERMAN], oListBox:nAT) OF oDlg PIXEL SIZE 035,011	//-- "Descricao do Usuario"
				ElseIf nCntFor = 3
					nPosBut += 40
					@ aPosObj[3,1],aPosObj[3,4] + nPosBut BUTTON oBtnUser PROMPT aBtnUser[nCntFor,1] ACTION Eval(aBtnUser[3,2],aListBox[oListBox:nAT,CTFILMAN],aListBox[ oListBox:nAT,CTMANIFE],aListBox[ oListBox:nAT,CTSERMAN], oListBox:nAT) OF oDlg PIXEL SIZE 035,011	//-- "Descricao do Usuario"
				ElseIf nCntFor = 4
					nPosBut += 40
					@ aPosObj[3,1],aPosObj[3,4] + nPosBut BUTTON oBtnUser PROMPT aBtnUser[nCntFor,1] ACTION Eval(aBtnUser[4,2],aListBox[oListBox:nAT,CTFILMAN],aListBox[ oListBox:nAT,CTMANIFE],aListBox[ oListBox:nAT,CTSERMAN], oListBox:nAT) OF oDlg PIXEL SIZE 035,011	//-- "Descricao do Usuario"
				ElseIf nCntFor = 5
					nPosBut += 40
					@ aPosObj[3,1],aPosObj[3,4] + nPosBut BUTTON oBtnUser PROMPT aBtnUser[nCntFor,1] ACTION Eval(aBtnUser[5,2],aListBox[oListBox:nAT,CTFILMAN],aListBox[ oListBox:nAT,CTMANIFE],aListBox[ oListBox:nAT,CTSERMAN], oListBox:nAT) OF oDlg PIXEL SIZE 035,011	//-- "Descricao do Usuario"
				ElseIf nCntFor = 6
					nPosBut += 40
					@ aPosObj[3,1],aPosObj[3,4] + nPosBut BUTTON oBtnUser PROMPT aBtnUser[nCntFor,1] ACTION Eval(aBtnUser[6,2],aListBox[oListBox:nAT,CTFILMAN],aListBox[ oListBox:nAT,CTMANIFE],aListBox[ oListBox:nAT,CTSERMAN], oListBox:nAT) OF oDlg PIXEL SIZE 035,011	//-- "Descricao do Usuario"
				EndIf
			Next nCntFor
		EndIf
		nPosBut += 40
		@ aPosObj[3,1],aPosObj[3,4] + nPosBut BUTTON oBtn12 PROMPT STR0021 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011	//-- "Sair"
	Else
        If !lVisual
		    @ aPosObj[3,1],aPosObj[3,4] + 355 BUTTON oBtn12 PROMPT STR0021 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011	//-- "Sair"
        Else
            @ aPosObj[3,1],aPosObj[3,4] + 100 BUTTON oBtn12 PROMPT STR0021 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011	//-- "Sair"
        EndIf
	EndIf

	//-- Resfresh - TMSAE73A
	TMSAE73TMR()

	// Sistema executa a solicitacao de status para os manifestos pendentes
	// de acordo com os parametros do pergunte TMSAE73A
	If !Empty(MV_PAR01TM) .and. MV_PAR01TM > 0
		nMilissegundos := (MV_PAR01TM*60*1000) // Disparo sera de X em X minutos

		oTimer := TTimer():New(nMilissegundos, {|| TME73STATM(aListBox, aPerg, cIdent, aDocs) }, oDlg )
		oTimer:Activate()
	End

	ACTIVATE MSDIALOG oDlg

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73LST  ³ Autor ³Katia                  ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel por selecionar os MDF's do monitor       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Array que carrega os doc. da tela.               ³±±
±±³          ³Param[2] - Parametros Pergunte                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73LST(aListBox, aPerg, aDocs, lVisual)
	Local cQuery    := ''
	Local cAliasDTX := GetNextAlias()
	Local lRet      := .T.
	Local oVerde    := LoadBitmap( GetResources(),'BR_VERDE'	)
	Local oAmarelo  := LoadBitmap( GetResources(),'BR_AMARELO'	)
	Local oVermelho := LoadBitmap( GetResources(),'BR_VERMELHO'	)
	Local oAzul     := LoadBitmap( GetResources(),'BR_AZUL'		)
	Local oPreto    := LoadBitmap( GetResources(),'BR_PRETO'	)
	Local oMarron   := LoadBitmap( GetResources(),'BR_MARRON'	)
	Local oBranco     	:= LoadBitmap( GetResources(),'BR_BRANCO'	) /* Utilizado apenas quando nao existe manifestos no monitor */
	Local oCor         := {}
	Local nPosMrk      := 0
	Local lDTX_PRMACO  := DTX->(FieldPos("DTX_PRMACO")) > 0
	Local cPerg		   := 'TMSAE73'
	Local lOk		   := .T.
	Local lListaReg    := .F.
    Local aAreaDTW     := DTW->(GetArea())
	Local cSTMDFE	   := ""
	Local nRetPE	   := 0
	Local aRetPE	   := {}
	Local lTME73LST    := ExistBlock("TME73LST") 
        
	Default aDocs := {}
    Default lVisual     := .F.

	Pergunte(cPerg,.F.)
	nQtdMrk := 0

//-- Select para listar todos os Manifestos do Monitor
	If !lCancela
		If lDTX_PRMACO .And. Len(aDocs) == 0
			cQuery := "SELECT * FROM ( "
		EndIf	

		cQuery += TM73QryDTX(aPerg,aDocs,1,lVisual)
		
		If lDTX_PRMACO .And. Len(aDocs) == 0
			cQuery += "UNION  "

			cQuery += TM73QryDTX(aPerg,aDocs,2,lVisual)  
			cQuery += " GROUP BY "
			
			If !__lPyme
				cQuery += " DTQ.DTQ_STATUS,"
			EndIf				
			cQuery += " DTX1.DTX_FILIAL, DTX1.DTX_FILMAN, DTX1.DTX_MANIFE, DTX1.DTX_DATMAN, DTX1.DTX_HORMAN, DTX1.DTX_RTIMDF, DTX1.DTX_STIMDF,  "
			cQuery += " DTX1.DTX_RTFMDF, DTX1.DTX_STFMDF, DTX1.DTX_FIMP,   DTX1.R_E_C_N_O_, DTX1.DTX_FILORI, DTX1.DTX_VIAGEM, DTX1.DTX_CODEVE, DTX1.DTX_STATUS,  "
			cQuery += " DTX1.DTX_SERMAN, DTX1.DTX_NUMROM, DTX1.DTX_PRMACO "
		Else
			If !__lPyme
				cQuery += " GROUP BY DTQ.DTQ_STATUS,"
			Else
				cQuery += " GROUP BY DTQ_STATUS,"
			EndIf	
			cQuery += "  DTX.DTX_FILIAL, DTX.DTX_FILMAN, DTX.DTX_MANIFE, DTX.DTX_DATMAN, DTX.DTX_HORMAN, DTX.DTX_RTIMDF, DTX.DTX_STIMDF, "
			cQuery += "  DTX.DTX_RTFMDF, DTX.DTX_STFMDF, DTX.DTX_FIMP,   DTX.R_E_C_N_O_, DTX.DTX_FILORI, DTX.DTX_VIAGEM, DTX.DTX_CODEVE, DTX.DTX_STATUS,  "
			cQuery += "  DTX.DTX_SERMAN, DTX.DTX_NUMROM "
			If lDTX_PRMACO 
				cQuery += " , DTX.DTX_PRMACO "
			EndIf
		EndIf	

		If lInCond
			cQuery += ", DUP_RTMDFE, DUP_CODMOT,DUP_STMDFE "
		ElseIf lPagFrete
			cQuery += ", DTX1.DTX_NUMCTC, DLI_CODEVE, DLI_DESEVE, DLI_STAEVE "
		EndIf
			
		If lDTX_PRMACO .And. Len(aDocs) == 0
			cQuery += ") QRY1 "
        	cQuery += " WHERE DTX_MANIFE > ' ' OR DTX_PRMACO > ' ' "
			cQuery += " ORDER BY DTX_FILMAN, DTX_DATMAN , DTX_MANIFE, DTX_PRMACO "
		Else
			cQuery += " ORDER BY DTX_FILMAN, DTX_DATMAN , DTX_MANIFE "
			If lDTX_PRMACO
				cQuery += " , DTX_PRMACO "
			EndIf
		EndIf	
		cQuery := ChangeQuery(cQuery)

	Else  //CANCELAMENTO

		If lDTX_PRMACO .And. Len(aDocs) == 0
			cQuery := "SELECT * FROM ( "
		EndIf	

		cQuery += TM73QryDYN(aPerg,aDocs,1)  
		
		If lDTX_PRMACO .And. Len(aDocs) == 0
			cQuery += "UNION  "

			cQuery += TM73QryDYN(aPerg,aDocs,2)  
			
			cQuery += ")  QRY1 "
	
			cQuery += " WHERE DTX_MANIFE > ' ' OR DTX_PRMACO > ' ' "
			cQuery += " ORDER BY DTX_FILMAN, DTX_DATMAN , DTX_MANIFE, DTX_PRMACO "
		Else
			cQuery += " ORDER BY DTX_FILMAN, DTX_DATMAN , DTX_MANIFE "
			If lDTX_PRMACO
				cQuery += " , DTX_PRMACO "
			EndIf	
		EndIf

		cQuery := ChangeQuery(cQuery)
	EndIf
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDTX, .F., .T.)
	TcSetField(cAliasDTX,"DTX_DATMAN", "D", 8, 0)

    dbSelectArea("DTW")
    DTW->(dbSetOrder(3)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_STATUS+DTW_SEQUEN

	If !(cAliasDTX)->(Eof())
		While (!(cAliasDTX)->(Eof()))
			cSTMDFE := ""
			lOk := .T.
			If !lInCond   //Inclusão de Condutor é permitido transmissao com a viagem em transito, independente da operação
                If (cAliasDTX)->DTQ_STATUS == "2" .AND. !lVisual
					lOk:= TM73OpeCli( (cAliasDTX)->DTX_FILORI,(cAliasDTX)->DTX_VIAGEM )  
                EndIf
			EndIf	
			If lOk
				lListaReg:= .T.
				If lEnvia .Or. lInCond .OR. (lVisual .AND. !lCancela)
					Do Case
					Case (cAliasDTX)->DTX_STIMDF == StrZero(1,Len(DTX->DTX_STIMDF))	//-- 1 Mdf-e Aguardando
						oCor := oVerde
					Case (cAliasDTX)->DTX_STIMDF == StrZero(0,Len(DTX->DTX_STIMDF))	//-- 0 Nao Transmitido
						oCor := oAmarelo
					Case (cAliasDTX)->DTX_STIMDF == StrZero(3,Len(DTX->DTX_STIMDF))	//-- 3 Mdf-e Nao Autorizado
						oCor := oVermelho
					Case (cAliasDTX)->DTX_STIMDF == StrZero(2,Len(DTX->DTX_STIMDF)) .And. (cAliasDTX)->DTX_STFMDF <> StrZero(2,Len(DTX->DTX_STFMDF)) //-- 2 Mdf-e Autorizado
						If lInCond
							cSTMDFE := (cAliasDTX)->DUP_STMDFE
						EndIf
						oCor := TME73LIC( lEnvia ,lVisual, lCancela, lInCond, cSTMDFE, oAzul, oAmarelo, oVerde, oVermelho )
					Case (cAliasDTX)->DTX_STIMDF == StrZero(5,Len(DTX->DTX_STIMDF))	//-- 5 Mdf-e com Falha na Comunicacao
						oCor := oPreto
					Case (cAliasDTX)->DTX_STFMDF == StrZero(2,Len(DTX->DTX_STFMDF))	//-- Encerrado
						oCor := oMarron
					OtherWise
						oCor := oAmarelo
					EndCase
				ElseIf lEncerra
					Do Case
					Case (cAliasDTX)->DTX_STFMDF == StrZero(1,Len(DTX->DTX_STFMDF))	//-- 1 Mdf-e Aguardando
						oCor := oVerde
					Case (cAliasDTX)->DTX_STFMDF == StrZero(0,Len(DTX->DTX_STFMDF))	//-- 0 Nao Transmitido
						oCor := oAmarelo
					Case (cAliasDTX)->DTX_STFMDF == StrZero(3,Len(DTX->DTX_STFMDF))	//-- 3 Mdf-e Nao Autorizado
						oCor := oVermelho
					Case (cAliasDTX)->DTX_STFMDF == StrZero(2,Len(DTX->DTX_STFMDF))	//-- 2 Mdf-e Autorizado
						oCor := oMarron  //oAzul
					Case (cAliasDTX)->DTX_STFMDF == StrZero(5,Len(DTX->DTX_STFMDF))	//-- 5 Mdf-e com Falha na Comunicacao
						oCor	:= oPreto
					//Case (cAliasDTX)->DTX_STATUS == StrZero(3,Len(DTX->DTX_STATUS))	//-- Encerrado
					//	oCor := oMarron
					OtherWise
						oCor := oAmarelo
					EndCase
				ElseIf lCancela
					Do Case
					Case (cAliasDTX)->DTX_STFMDF == StrZero(1,Len(DTX->DTX_STFMDF))	//-- 1 Mdf-e Aguardando
						oCor := oVerde
					Case (cAliasDTX)->DTX_STFMDF == StrZero(0,Len(DTX->DTX_STFMDF))	//-- 0 Nao Transmitido
						oCor := oAmarelo
					Case (cAliasDTX)->DTX_STFMDF == StrZero(3,Len(DTX->DTX_STFMDF))	//-- 3 Mdf-e Nao Autorizado
						oCor := oVermelho
					Case (cAliasDTX)->DTX_STFMDF == StrZero(2,Len(DTX->DTX_STFMDF))	//-- 2 Mdf-e Autorizado
						oCor := oAzul
					Case (cAliasDTX)->DTX_STFMDF == StrZero(5,Len(DTX->DTX_STFMDF))	//-- 5 Mdf-e com Falha na Comunicacao
						oCor := oPreto
					OtherWise
						oCor := oAmarelo
					EndCase
				ElseIf lPagFrete
					Do Case
					//--;1=Envio Evento realizado;2=Evento vinculado com sucesso;3=Evento rejeitado
					Case (cAliasDTX)->DLI_STAEVE == StrZero(0,Len(DLI->DLI_STAEVE))	//0=Preparado para Transmissão
						oCor := oVerde
					Case (cAliasDTX)->DLI_STAEVE == StrZero(1,Len(DLI->DLI_STAEVE))	//-- 1 - Envio Evento Realizado
						oCor := oAmarelo
					Case (cAliasDTX)->DLI_STAEVE == StrZero(2,Len(DLI->DLI_STAEVE))	//-- 2 - Evento Vinculado com sucesso
						oCor := oAzul
					Case (cAliasDTX)->DLI_STAEVE == StrZero(3,Len(DLI->DLI_STAEVE))	//-- 3 - Evento rejeitado
						oCor := oVermelho
					OtherWise
						oCor := oPreto
					EndCase	
				EndIf

				Aadd(aListBox,Array(22))
				If !Empty((cAliasDTX)->DTX_SERMAN)
					nPosMrk := Ascan(aDocMark,{ | e | e[1]+e[2]+e[3] == (cAliasDTX)->DTX_FILMAN+(cAliasDTX)->DTX_MANIFE+(cAliasDTX)->DTX_SERMAN })
				Else
					nPosMrk := Ascan(aDocMark,{ | e | e[1]+e[2]+e[3] == (cAliasDTX)->DTX_FILMAN+(cAliasDTX)->DTX_MANIFE+"0" })
				EndIf
				If lEnvia .Or. lInCond .Or. lPagFrete 
					aListBox[Len(aListBox),CTMARCA ] := Iif(nPosMrk == 0 .Or. AllTrim((cAliasDTX)->DTX_STIMDF) == "2" ,'2',aDocMark[nPosMrk,4])
				ElseIf lEncerra
					aListBox[Len(aListBox),CTMARCA ] := Iif(nPosMrk == 0 .Or. AllTrim((cAliasDTX)->DTX_STFMDF) == "2" ,'2',aDocMark[nPosMrk,4])
				ElseIf lCancela
					aListBox[Len(aListBox),CTMARCA ] := Iif(nPosMrk == 0 .Or. AllTrim((cAliasDTX)->DTX_STCMDF) == "2" ,'2',aDocMark[nPosMrk,4])
				EndIf
				aListBox[Len(aListBox),CTCORBRW] := oCor
				aListBox[Len(aListBox),CTDATMAN] := (cAliasDTX)->DTX_DATMAN
				aListBox[Len(aListBox),CTHORMAN] := Transform((cAliasDTX)->DTX_HORMAN,X3Picture("DTX_HORMAN"))
				aListBox[Len(aListBox),CTFILMAN] := (cAliasDTX)->DTX_FILMAN
				aListBox[Len(aListBox),CTMANIFE] := (cAliasDTX)->DTX_MANIFE
				If !Empty((cAliasDTX)->DTX_SERMAN)
					aListBox[Len(aListBox),CTSERMAN] := (cAliasDTX)->DTX_SERMAN
				Else
					aListBox[Len(aListBox),CTSERMAN] := '0'
				EndIf
				If __lPyme
					aListBox[Len(aListBox),CTFILORI] := (cAliasDTX)->DTX_FILORI
					aListBox[Len(aListBox),CTNUMROM] := (cAliasDTX)->DTX_NUMROM
				Else
					aListBox[Len(aListBox),CTFILORI] := (cAliasDTX)->DTX_FILORI
					aListBox[Len(aListBox),CTVIAGEM] := (cAliasDTX)->DTX_VIAGEM
				EndIf

				If lInCond
					aListBox[Len(aListBox),CTRTCOND] := (cAliasDTX)->DUP_RTMDFE
					aListBox[Len(aListBox),CTCODMOT] := (cAliasDTX)->DUP_CODMOT
					aListBox[Len(aListBox),CTNOMMOT] := Alltrim((cAliasDTX)->DA4_NOME)
				elseif lPagFrete
					aListBox[Len(aListBox),CTDESEVE] := Alltrim((cAliasDTX)->DLI_DESEVE)
					aListBox[Len(aListBox),CTNUMCTC] := Alltrim((cAliasDTX)->DTX_NUMCTC)
				EndIf

				If lEnvia
					aListBox[Len(aListBox),CTRTIMDF] := AllTrim((cAliasDTX)->DTX_RTIMDF)
					aListBox[Len(aListBox),CTRTFMDF] := AllTrim((cAliasDTX)->DTX_RTFMDF)
					aListBox[Len(aListBox),CTSTIMDF] := AllTrim((cAliasDTX)->DTX_STIMDF)
					aListBox[Len(aListBox),CTSTFMDF] := AllTrim((cAliasDTX)->DTX_STFMDF)
				Else
					aListBox[Len(aListBox),CTRTFMDF] := AllTrim((cAliasDTX)->DTX_RTFMDF)
					aListBox[Len(aListBox),CTRTIMDF] := AllTrim((cAliasDTX)->DTX_RTIMDF)
					aListBox[Len(aListBox),CTSTFMDF] := AllTrim((cAliasDTX)->DTX_STFMDF)
					aListBox[Len(aListBox),CTSTIMDF] := AllTrim((cAliasDTX)->DTX_STIMDF)
				EndIf
				aListBox[Len(aListBox),CTFIMP  ] := (cAliasDTX)->DTX_FIMP
				aListBox[Len(aListBox),CTDTXREC] := (cAliasDTX)->DTXRECNO
				aListBox[Len(aListBox),CTCODEVE] := AllTrim((cAliasDTX)->DTX_CODEVE)

				If lDTX_PRMACO
					aListBox[Len(aListBox),CTPRMACO] := (cAliasDTX)->DTX_PRMACO
				EndIf

				If Len(aListBox) >= 32600
					MsgAlert (STR0022)
					Exit
				EndIf
			EndIf

			If lTME73LST
				aRetPE := ExecBlock("TME73LST",.F.,.F., { cAliasDTX, lEnvia, lVisual, lInCond, lPagFrete })
				If	ValType(aRetPE) == "A" 
					For nRetPE := 1 To Len(aRetPE)
						aAdd(aListBox[Len(aListBox)], aRetPE[nRetPE])
					Next nRetPE
				EndIf
			EndIf

			(cAliasDTX)->(DbSkip())

		EndDo
	Else
		lListaReg:= .F.
	EndIf

    //---- Consulta MDF-e (lConsulta) para que não seja exibido uma linha em branco na primeira query
    //---- pois será executada em seguida a segunda query do cancelamento 
    If !lListaReg .And. lVisual .And. (!lCancela .OR. (lCancela .AND. Len(aListBox) > 0))
        lListaReg := .T.
    EndIf

	If !lListaReg
		If __lPyme
			Aadd(aListBox,Array(22))
			aListBox[Len(aListBox),CTMARCA ] := '2'
			aListBox[Len(aListBox),CTCORBRW] := oBranco
			aListBox[Len(aListBox),CTDATMAN] := ''
			aListBox[Len(aListBox),CTHORMAN] := ''
			aListBox[Len(aListBox),CTFILMAN] := ''
			aListBox[Len(aListBox),CTMANIFE] := ''
			aListBox[Len(aListBox),CTSERMAN] := '0'
			aListBox[Len(aListBox),CTFILORI] := ''
			aListBox[Len(aListBox),CTNUMROM] := ''
			aListBox[Len(aListBox),CTRTIMDF] := ''
			aListBox[Len(aListBox),CTRTFMDF] := ''
			aListBox[Len(aListBox),CTSTIMDF] := ''
			aListBox[Len(aListBox),CTSTFMDF] := ''
			aListBox[Len(aListBox),CTFIMP  ] := ''
			aListBox[Len(aListBox),CTDTXREC] := 0
			aListBox[Len(aListBox),CTCODEVE] := ''
			aListBox[Len(aListBox),CTRTCOND] := ''
			aListBox[Len(aListBox),CTCODMOT] := ''
			aListBox[Len(aListBox),CTNOMMOT] := ''
			aListBox[Len(aListBox),CTPRMACO] := ''
			aListBox[Len(aListBox),CTDESEVE] := ''
			aListBox[Len(aListBox),CTNUMCTC] := ''

		Else
			Aadd(aListBox,Array(22))
			aListBox[Len(aListBox),CTMARCA ] := '2'
			aListBox[Len(aListBox),CTCORBRW] := oBranco
			aListBox[Len(aListBox),CTDATMAN] := ''
			aListBox[Len(aListBox),CTHORMAN] := ''
			aListBox[Len(aListBox),CTFILMAN] := ''
			aListBox[Len(aListBox),CTMANIFE] := ''
			aListBox[Len(aListBox),CTSERMAN] := '0'
			aListBox[Len(aListBox),CTFILORI] := ''
			aListBox[Len(aListBox),CTVIAGEM] := ''
			aListBox[Len(aListBox),CTRTIMDF] := ''
			aListBox[Len(aListBox),CTRTFMDF] := ''
			aListBox[Len(aListBox),CTSTIMDF] := ''
			aListBox[Len(aListBox),CTSTFMDF] := ''
			aListBox[Len(aListBox),CTFIMP  ] := ''
			aListBox[Len(aListBox),CTDTXREC] := 0
			aListBox[Len(aListBox),CTCODEVE] := ''
			aListBox[Len(aListBox),CTRTCOND] := ''
			aListBox[Len(aListBox),CTCODMOT] := ''
			aListBox[Len(aListBox),CTNOMMOT] := ''
			aListBox[Len(aListBox),CTPRMACO] := ''
			aListBox[Len(aListBox),CTNUMCTC] := ''
			aListBox[Len(aListBox),CTDESEVE] := ''
		EndIf
		
		If lTME73LST
			aRetPE := ExecBlock("TME73LST",.F.,.F., { cAliasDTX, lEnvia, lVisual, lInCond, lPagFrete })
			If	ValType(aRetPE) == "A" 
				For nRetPE := 1 To Len(aRetPE)
					aAdd(aListBox[Len(aListBox)], '')
				Next nRetPE
			EndIf
		EndIf
	EndIf
	(cAliasDTX)->(dbCloseArea())

	dbSelectArea("DTX") //nao retirar
    RestArea(aAreaDTW)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73ENV  ³ Autor ³Katia                  ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel por Retransmitir os MDFs ao TSS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Array contendo os doc. da tela.                  ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73Env(aListBox,aPerg,lRefresh,aDocs)
	Local aDoctosTra  := {}

	Default aListBox  := {}
	Default aPerg     := {}
	Default lRefresh  := .T.
	Default aDocs     := {}
	
	//Verifica o Status da SEFAZ antes de Enviar o MDF-e
	If ExistFunc('TMSMonSEF') .And. !TMSMonSEF('58')
		Return
	EndIf
	
	If !lExecAuto
		If Ascan( aListBox, { | e | e[CTMARCA] == '1' } ) == 0
			Return
		EndIf
	EndIf
	
	//-- Obtem documentos para transmissao junto com a ação ( 1 = Transmitir; 2 = Solicitar Status)
	aDoctosTra := TME73Doc( aListBox, '1' )

	FwMsgRun(, {|oSay| TMS73PrEnv(aDoctosTra, oSay) } , STR0070 , STR0102 ) //"Processando"  /  "Transmitindo documentos..."

	If lRefresh
	//-- Retira marca dos documentos autorizados
		TME73Ret(aListBox)
	//-- Realiza refresh no BROWSE
		TME73Rfs(@aListBox, aPerg, aDocs)
	EndIf

Return( Nil )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73Doc  ³ Autor ³ Katia                 ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparar documentos para transmissao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array dos documentos                                       ³±±
±±³          ³ [1] - Filial                                               ³±±
±±³          ³ [2] - Documento Inicial                                    ³±±
±±³          ³ [3] - Documento Final                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73Doc(aListBox,cAcao)

	Local   nI         := 0
	Local   aDoctos    := {}
	Local   aDoctosTra := {}
	Local   aDoctosCnt := {}
	Local   nQtdDoc    := 1
	Local   aAreaDTX   := {}

	Default cAcao      := '1'

//-- Fil.Docto + Docto + Serie
	aDoctos := AClone(aListBox)
	ASort( aDoctos,,,{|x,y| x[ CTMARCA ] + x[ CTFILMAN ] + x[ CTMANIFE ] < y[ CTMARCA] + y[ CTFILMAN ] + y[ CTMANIFE ] + y[ CTSERMAN ] })

	For nI := 1 To Len(aDoctos)
		If aDoctos[nI,CTMARCA] == '2'
			Exit
		EndIf
		If cAcao == '2'
			If (lEnvia .And. aDoctos[nI,CTSTIMDF] == '0')  //-- Tentativa de Solicitar Status para Documentos ainda não transmitidos
				Loop
			EndIf
		EndIf
		If cAcao == '1'
			aAreaDTX := DTX->(GetArea())
			dbSelectArea("DTX")
			DTX->(dbGoTop())
			DTX->(dbSetOrder(1)) //DTX_FILIAL+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN
			If DTX->(dbSeek(xFilial("DTX")+aDoctos[nI,CTFILMAN ]+aDoctos[nI,CTMANIFE   ]+aDoctos[nI,CTSERMAN ]))
				If !Empty(DTX->DTX_CTGMDF)
					Loop
				EndIf
			EndIf
			RestArea(aAreaDTX)
		EndIf
		If !Empty(aDoctosCnt)
			If aDoctos[nI,CTFILMAN]+AllTrim(aDoctos[nI,CTMANIFE]) <> aDoctosCnt[1]+Soma1(AllTrim(aDoctosCnt[2])) .Or. nQtdDoc > 50
				aDoctosTra[Len(aDoctosTra),3] := Padr(aDoctosCnt[2],Len(DTX->DTX_MANIFE))
				aDoctosCnt := {}
				nQtdDoc := 1
			Else
				aDoctosCnt[2] := Soma1(AllTrim(aDoctosCnt[2]))
				nQtdDoc += 1
			EndIf
		EndIf
		If Empty(aDoctosCnt)
			Aadd(aDoctosTra,Array(5))
			aDoctosTra[Len(aDoctosTra),1] := aDoctos[nI,CTFILMAN ]
			aDoctosTra[Len(aDoctosTra),2] := Padr(aDoctos[nI,CTMANIFE ],Len(DTX->DTX_MANIFE))
			aDoctosTra[Len(aDoctosTra),3] := ''
			aDoctosTra[Len(aDoctosTra),4] := Padr(aDoctos[nI,CTSERMAN],Len(DT6->DT6_SERIE))

			If lInCond
				aDoctosTra[Len(aDoctosTra),5] := aDoctos[nI,CTCODMOT]
			EndIf

			aDoctosCnt := Array(3)
			aDoctosCnt[1] := aDoctos[nI,CTFILMAN]
			aDoctosCnt[2] := aDoctos[nI,CTMANIFE]
			aDoctosCnt[3] := aDoctos[nI,CTSERMAN]
			nQtdDoc += 1
		EndIf
	Next nI
	If Len(aDoctosTra) > 0 .And. Empty(aDoctosTra[Len(aDoctosTra),3])
		aDoctosTra[Len(aDoctosTra),3] := Padr(aDoctosCnt[2],Len(DTX->DTX_MANIFE))
	EndIf
Return( aDoctosTra )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73STA  ³ Autor ³Katia                  ³ Data ³23.05.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel por solicitar o Status dos MDF's.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Array contendo os doc. da tela.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73STA(aListBox,aPerg,cIdent,aDocs)

	Local aDoctosTra := {}
	Local lEnd       := .F.

	Default aListBox := {}
	Default cIdent   := ""
	Default aDocs    := {}

	If lUsaColab
		Aviso("TOTVS Colaboração",STR0104,{"Ok"},3) //-- "Utilizar opção Monitor para TOTVS Colaboração."
		Return Nil
	EndIf
	If Empty(cIdent)
		If CTIsReady(,,,lUsaColab)
			cIdEnt := RetIdEnti(lUsaColab)
		EndIf
	EndIf

	If Ascan( aListBox, { | e | e[CTMARCA] == '1' } ) == 0
		MsgAlert(STR0027,STR0024)	// -- "Não existem documentos marcados para solicitar status!", "ATENÇÃO"
		Return
	Else
		If !MsgYesNo(STR0029)		// -- ""Confirma solicitação de status dos documentos marcados?"
			Return
		EndIf
	EndIf

	//-- Obtem documentos para transmissao
	aDoctosTra := TME73Doc( aListBox, '2' )

	Processa( { |lEnd| TME73PSt(aDoctosTra,lEnd, cIdent) }, , STR0103 , .T. ) //-- 'Solicitando status dos documentos...'

	//-- Retira marca dos documentos autorizados
	TME73Ret(@aListBox)

	//-- Realiza refresh no BROWSE
	TME73Rfs(@aListBox, aPerg, aDocs)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73PST  ³ Autor ³ Katia                 ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Processamento do status dos MDF's para o TSS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Array contendo os doc. da tela.                  ³±±
±±³          ³lExp1    - Controle para interromper o processamento        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73PSt(aDoctosTra,lEnd,cIdent)

	Local cManIni    := ''
	Local cManFin    := ''
	Local cFilMan    := ''
	Local cSerie     := ''
	Local nI         := 0

	Default cIdent   := ""

	ProcRegua(Len(aDoctosTra))

	For nI := 1 To Len(aDoctosTra)
		IncProc()
		If lEnd
			If MsgYesNo(STR0105)	//-- "Deseja interromper o processamento?"
				Exit
			EndIf
			lEnd := .F.
		EndIf
		cFilMan := aDoctosTra[nI,1]
		cManIni := aDoctosTra[nI,2]
		cManFin := aDoctosTra[nI,3]
		cSerie  := aDoctosTra[nI,4]
		//-- Funcao responsavel por solicitar o Status do Doc ao TSS
		If Empty(MV_PAR01TM) .or. MV_PAR01TM <= 0
			Sleep(8000)
		End
		WsMDFeMnt(cIdent, cSerie, cManIni, cManFin, .F.)
	Next nI

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73LEG  ³ Autor ³Katia                  ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina das Legendas dos Status dos Documentos, no monitor   ³±±
±±³          ³do MDFe                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TME73Leg()

If Type('lPagFrete') <> "L"
	If Type('cCDEVPGTO') == "C"  
		lPagFrete:= IIf (DLI->(ColumnPos('DLI_STAEVE')) > 0,.T.,.F.) .And.  cTpEvento == cCDEVPGTO
	Else
		lPagFrete:= .F.
	EndIf	
EndIf

If lPagFrete

	BrwLegenda( STR0110, STR0016, {;			//-- Status do MDFe /  Status
		{'BR_AMARELO'  , STR0111 },;	//-- Evento Vinculado com sucesso
		{'BR_VERDE'    , STR0112 },;	//-- Preparado para Transmissão
		{'BR_AZUL'     , STR0113 },;	//-- Envio Evento Realizado
		{'BR_VERMELHO' , STR0114 }})	//-- Evento rejeitado
		
Else
	
	BrwLegenda( STR0014, STR0016, {;			//-- Status do MDFe /  Status
	{'BR_AMARELO'  , STR0030 },;	//-- Não Transmitido
	{'BR_VERDE'    , STR0031 },;	//-- Documento Aguardando
	{'BR_AZUL'     , STR0032 },;	//-- MDF. Autorizado
	{'BR_VERMELHO' , STR0033 },;	//-- MDF. Não Autorizado
	{'BR_PRETO'    , STR0034 },;	//-- MDF. com Falha na Comunicação
	{'BR_MARRON'   , STR0062 }})	//-- MDF. Encerrado

EndIf
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TME73ASt   ³ Autor ³ Katia                ³ Data ³05/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizar Situacao do MDF na tabela de dctos dos Campos    ³±±
±±³          ³ (DTX_STIMDF, DTX_RTIMDF, DTX_STFMDF, DTX_RTFMDF)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSJOBSTAT {cFilDoc,cDocMin,cDocMax,cSerman,cStatus}        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Filial do Manifesto                                  ³±±
±±³          ³ExpC2: Numero do Manifesto Inicial                          ³±±
±±³          ³ExpC3: Numero do Manifesto Final                            ³±±
±±³          ³ExpC4: Situacao do Documento                                ³±±
±±³          ³        0 - Nao Transmitido                                 ³±±
±±³          ³        1 - Doc Aguardando                                  ³±±
±±³          ³        2 - Doc Autorizado                                  ³±±
±±³          ³        3 - Doc Nao Autorizado                              ³±±
±±³          ³        4 - Doc em Contingencia                             ³±±
±±³          ³        5 - Doc com Falha na Comunicacao                    ³±±
±±³          ³ExpC5: Descricao do Codigo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TME73ASt(cFilMan,cManMin,cManMax,cStatus,cDesc,cSerie)
	Local cQuery := ''
	Local cDescCol	:= '002 - O MDF-e foi transmitido, aguarde o processamento.'

	Default cDesc  := ''
	Default cSerie := ''

	If lEnvia
		cQuery := " UPDATE " + RetSqlName("DTX") + " SET DTX_STIMDF = '" + cStatus + "' "
		If lUsaColab
			If cStatus == "1"
				cQuery += " ,DTX_RTIMDF = '" + cDescCol + "' "
			EndIf
		Else
			If !Empty(cDesc)
				cQuery += " ,DTX_RTIMDF = '" + cDesc + "' "
			EndIf
		EndIf
		cQuery += " WHERE DTX_FILIAL = '" + xFilial("DTX") + "'"
		cQuery += "   AND DTX_FILMAN = '" + cFilMan + "' "
		cQuery += "   AND DTX_MANIFE BETWEEN '" + cManMin + "' AND '" + cManMax + "' "
		If !(Alltrim(cSerie) == '0')
			cQuery += "   AND DTX_SERMAN = '" + cSerie + "' "
		EndIf
		cQuery += "   AND DTX_STIMDF <> '2'"
		cQuery += "   AND D_E_L_E_T_ =  ' '"
	ElseIf lEncerra
		cQuery := " UPDATE " + RetSqlName("DTX") + " SET DTX_STFMDF = '" + cStatus + "' "
		If !Empty(cDesc)
			cQuery += " ,DTX_RTFMDF = '" + cDesc + "' "
		EndIf
		cQuery += " WHERE DTX_FILIAL = '" + xFilial("DTX") + "'"
		cQuery += "   AND DTX_FILMAN = '" + cFilMan + "' "
		cQuery += "   AND DTX_MANIFE BETWEEN '" + cManMin + "' AND '" + cManMax + "' "
		If !(Alltrim(cSerie) == '0')
			cQuery += "   AND DTX_SERMAN = '" + cSerie + "' "
		EndIf
		cQuery += "   AND DTX_STFMDF <> '2'"
		cQuery += "   AND D_E_L_E_T_ =  ' '"
	ElseIf lCancela
		cQuery := " UPDATE " + RetSqlName("DYN") + " SET DYN_STCMDF = '" + cStatus + "' "
		If !Empty(cDesc)
			cQuery += " ,DYN_RTCMDF = '" + cDesc + "' "
		EndIf
		cQuery += " WHERE DYN_FILIAL = '" + xFilial("DTX") + "'"
		cQuery += "   AND DYN_FILMAN = '" + cFilMan + "' "
		cQuery += "   AND DYN_MANIFE BETWEEN '" + cManMin + "' AND '" + cManMax + "' "
		If !(Alltrim(cSerie) == '0')
			cQuery += "   AND DTX_SERMAN = '" + cSerie + "' "
		EndIf
		cQuery += "   AND DYN_STCMDF <> '2'"
		cQuery += "   AND D_E_L_E_T_ =  ' '"
	EndIf

	TCSqlExec( cQuery )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TME73Psq ³  Autor³ Katia                 ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa documentos no monitor                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TME73Psq()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE73                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73Psq(aListBox)

	Local aCbx		:= {}
	Local cCampo	:= ''
	Local cOrd
	Local cData		:= ''
	Local lSeek		:= .F.
	Local nOrdem	:= 1
	Local nSeek		:= 0
	Local oCbx
	Local oDlg
	Local oPsqGet

	cCampo := AllTrim(FWX3Titulo('DTX_FILMAN')) + ' + ' + AllTrim(FWX3Titulo('DTX_MANIFE'))
	Aadd( aCbx, cCampo )

	cCampo := AllTrim(FWX3Titulo('DTX_DATMAN'))
	Aadd( aCbx, cCampo )

	cCampo := AllTrim(FWX3Titulo('DTX_FILORI')) + ' + ' + AllTrim(FWX3Titulo('DTX_VIAGEM'))
	Aadd( aCbx, cCampo )

	Aadd( aCbx, 'Marca/Desmarca Doctos.' )

	Aadd( aCbx, 'Impressão do DAMDFE' )

	cCampo := Space( 40 )

	DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0035	// -- "Pesquisa"

	@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

	@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

	If lSeek
		cCampo := AllTrim( cCampo )
		If nOrdem == 1
		//-- Fil.Manifesto + Manifesto
			ASort( aListBox,,,{|x,y| x[ CTFILMAN ] + x[ CTMANIFE ] < y[ CTFILMAN ] + y[ CTMANIFE ] })
			nSeek := Ascan( aListBox,{ | x | PadR( x[ CTFILMAN ] + x[ CTMANIFE ] , Len( cCampo ) ) == cCampo } )
		ElseIf nOrdem == 2
		//-- Data de Manifesto
			ASort( aListBox,,,{|x,y| DtoS(x[ CTDATMAN ]) < DtoS(y[ CTDATMAN ]) } )

			cData := Left( cCampo, 6 )
			cData := DtoS( CtoD(Left(cData,2)+'/'+Subs(cData,3,2)+'/'+Right(cData,2)) )

			If Len( cCampo ) > 6
				cCampo := cData + Subs( cCampo, 7, Len( cCampo ) )
			Else
				cCampo := cData
			EndIf

			nSeek := Ascan( aListBox,{ | x | PadR( DtoS( x[ CTDATMAN ] ), Len( cCampo ) ) == cCampo  } )
		ElseIf nOrdem == 3
		//-- Fil.Origem + Viagem
			ASort( aListBox,,,{|x,y| x[ CTFILORI ] + x[ CTVIAGEM ] < y[ CTFILORI ] + y[ CTVIAGEM ] })
			nSeek := Ascan( aListBox,{ | x | PadR( x[ CTFILORI ] + x[ CTVIAGEM ] , Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 4
		//-- Marca/Desmarca
			ASort( aListBox,,,{|x,y| x[CTMARCA] < y[CTMARCA] } )
			nSeek := Ascan( aListBox,{ | x | PadR( x[ CTMARCA ], Len( cCampo ) ) == cCampo } )

		ElseIf nOrdem == 5
		//-- Impressao do DAMDFE
			ASort( aListBox,,,{|x,y| x[CTFIMP  ] < y[CTFIMP  ] } )
			nSeek := Ascan( aListBox,{ | x | PadR( x[ CTFIMP ], Len( cCampo ) ) == cCampo } )

		EndIf
	EndIf

	If nSeek > 0
		oListBox:nAT := nSeek
		oListBox:Refresh()
	EndIf
	oListBox:SetFocus()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TME73Mrk ³  Autor³ Katia                 ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca documentos no listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TME73Mrk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73Mrk(aListBox,nItem,lRefresh,lUmItem,lRetMark,lMarcaUm)

	Local nPosMrk := 0
	Local lRet    := .T.
	Local aAreaAnt  := GetArea()
	Local cQuery    := ""
	Local cAliasQry := ""
	Local lDTX_PRMACO := DTX->(FieldPos("DTX_PRMACO")) > 0
	Local nPosPRMACO := 0
	Local nAux := 0
	Local lMsgExib := .F.

	Local oAmarelo  	:= LoadBitmap( GetResources(),'BR_AMARELO')  //-- 0 Nao Transmitido
	//Local oVerde    	:= LoadBitmap( GetResources(),'BR_VERDE')    //-- 1 Mdf-e Aguardando
	//Local oAzul     	:= LoadBitmap( GetResources(),'BR_AZUL')     //-- 2 Mdf-e Autorizado
	Local oVermelho 	:= LoadBitmap( GetResources(),'BR_VERMELHO') //-- 3 Mdf-e Nao Autorizado
	Local oPreto    	:= LoadBitmap( GetResources(),'BR_PRETO')    //-- 5 Mdf-e com Falha na Comunicacao
	//Local oMarron  	:= LoadBitmap( GetResources(),'BR_MARRON')   //-- Encerrado

	Default nItem   := oListBox:nAt
	Default lRefresh:= .T.
	Default lUmItem := .T.
	Default lRetMark:= .F.
	Default lMarcaUm:= .T.

	If aListBox[nItem,CTDTXREC] > 0
		lRet:=  (lEnvia .And. Iif(lRetMark,.T.,aListBox[nItem,CTSTIMDF] <> '2')) .Or. (lEncerra .And. Iif(lRetMark,.T.,aListBox[nItem,CTSTFMDF] <> '2' .And. (!AllTrim(aListBox[nItem,CTCODEVE]) $ "3") )); //-- Doc. Autorizado
		.Or. (lCancela .And. Iif(lRetMark,.T.,aListBox[nItem,CTSTFMDF] <> '2')) .Or. (lInCond .And. Iif(lRetMark,.T.,aListBox[nItem,CTSTIMDF] = '2') .And. (Iif(lRetMark,.T.,aListBox[nItem,CTSTFMDF] = '0');
		.Or. Iif(lRetMark,.T.,Empty(aListBox[nItem,CTSTFMDF])))) .Or. (lPagFrete .And. Iif(lRetMark,.T.,aListBox[nItem,CTSTIMDF] <> '2')) 

		If lInCond
		  	cQuery := "SELECT COUNT(*) AS DUP_CONT "
			cQuery +=  " FROM "+RetSqlName("DUP")
			cQuery += " WHERE DUP_FILIAL = '" + xFilial("DUP") + "'"
			cQuery += " AND DUP_VIAGEM = '" + aListBox[nItem, 9]+ "'"
			cQuery += " AND DUP_FILORI = '" + aListBox[nItem, 8]+ "'"
			cQuery += " AND DUP_CODMOT = '" + aListBox[nItem, 18]+ "'"
     		cQuery += " AND DUP_STMDFE <> '3' AND D_E_L_E_T_ =  ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->DUP_CONT = 0
				lRet:= .F.
			EndIf
			(cAliasQry)->( DbCloseArea() )
		EndIf
		RestArea(aAreaAnt)

		If lPagFrete
			lRet := TMAE73DLI(aListBox,nItem)
		EndIf
		If lRet .And. !lInCond
			If !lEnvia .And. lMarcaUm
				If lAllMark
					If Ascan( aListBox,{ | x |  x[ CTMARCA ] == '1' } ) > 0
						lRet:= .F.
					EndIf
				ElseIf nQtdMrk <> 0 .And. aListBox[nItem,CTMARCA] <> '1'
					lRet:= .F.
				EndIf
			EndIf
		EndIf
		If lRet
			If lUmItem
				aListBox[nItem,CTMARCA] := Iif(aListBox[nItem,CTMARCA] == '1','2','1')
				If(aListBox[nItem,CTMARCA]) == '1'
					nQtdMrk += 1
					If lDTX_PRMACO
						//Marcar o Primeiro Manifesto do Comboio, de acordo com o Manifesto clicado.
						nPosPRMACO := Ascan(aListBox, { | e | e[CTMANIFE] == aListBox[nItem,CTPRMACO] } )
						If nPosPRMACO > 0 .And. ;
						   ((lEnvia   .And. (aListBox[nPosPRMACO,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oPreto:CNAME)) .Or.;
						    (lEncerra .And. (aListBox[nPosPRMACO,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oPreto:CNAME)) .Or.;
						    (lCancela .And. (aListBox[nPosPRMACO,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oPreto:CNAME)) )
							aListBox[nPosPRMACO,CTMARCA] := aListBox[nItem,CTMARCA]
							nQtdMrk += 1
							If !lMsgExib
								MsgAlert("O Manifesto marcado faz parte de um comboio. Por conta disso, os outros Manifestos que fazem parte deste comboio serão marcados automaticamente.")
								lMsgExib := .T.
							EndIf
						EndIf
						//Marcar os demais Manifestos do Comboio, de acordo com o Manifesto clicado.
						For nAux := 1 To Len(aListBox)
							If aListBox[nAux,CTMANIFE] <> aListBox[nItem,CTMANIFE] .And. ;
							   ((lEnvia   .And. (aListBox[nAux,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oPreto:CNAME)) .Or.;
							    (lEncerra .And. (aListBox[nAux,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oPreto:CNAME)) .Or.;
							    (lCancela .And. (aListBox[nAux,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oPreto:CNAME)) )
								If !Empty(aListBox[nAux,CTPRMACO]) .And.;
							   		(aListBox[nAux,CTPRMACO] == aListBox[nItem,CTPRMACO] .Or. aListBox[nAux,CTPRMACO] == aListBox[nItem,CTMANIFE])
									aListBox[nAux,CTMARCA] := aListBox[nItem,CTMARCA]
									nQtdMrk += 1
									If !lMsgExib
										MsgAlert("O Manifesto marcado faz parte de um comboio. Por conta disso, os outros Manifestos que fazem parte deste comboio serão marcados automaticamente.")
										lMsgExib := .T.
									EndIf
								EndIf
							EndIf
						Next nAux
					EndIf
				ElseIf(aListBox[nItem,CTMARCA]) == '2'
					nQtdMrk -= 1
					If lDTX_PRMACO
						//Desmarcar o Primeiro Manifesto do Comboio, de acordo com o Manifesto clicado.
						nPosPRMACO := Ascan(aListBox, { | e | e[CTMANIFE] == aListBox[nItem,CTPRMACO] } )
						If nPosPRMACO > 0 .And. ;
						   ((lEnvia   .And. (aListBox[nPosPRMACO,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oPreto:CNAME)) .Or.;
						    (lEncerra .And. (aListBox[nPosPRMACO,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oPreto:CNAME)) .Or.;
						    (lCancela .And. (aListBox[nPosPRMACO,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nPosPRMACO,CTCORBRW]:CNAME == oPreto:CNAME)) )
							aListBox[nPosPRMACO,CTMARCA] := aListBox[nItem,CTMARCA]
							nQtdMrk -= 1
							If !lMsgExib
								MsgAlert("O Manifesto desmarcado faz parte de um comboio. Por conta disso, os outros Manifestos que fazem parte deste comboio serão desmarcados automaticamente.")
								lMsgExib := .T.
							EndIf
						EndIf
						//Desmarcar os demais Manifestos do Comboio, de acordo com o Manifesto clicado.
						For nAux := 1 To Len(aListBox)
							If aListBox[nAux,CTMANIFE] <> aListBox[nItem,CTMANIFE] .And. ;
							   ((lEnvia   .And. (aListBox[nAux,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oPreto:CNAME)) .Or.;
							    (lEncerra .And. (aListBox[nAux,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oPreto:CNAME)) .Or.;
							    (lCancela .And. (aListBox[nAux,CTCORBRW]:CNAME == oAmarelo:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oVermelho:CNAME .Or. aListBox[nAux,CTCORBRW]:CNAME == oPreto:CNAME)) )
							   If !Empty(aListBox[nAux,CTPRMACO]) .And.;
							   		(aListBox[nAux,CTPRMACO] == aListBox[nItem,CTPRMACO] .Or. aListBox[nAux,CTPRMACO] == aListBox[nItem,CTMANIFE])
									aListBox[nAux,CTMARCA] := aListBox[nItem,CTMARCA]
									nQtdMrk -= 1
									If !lMsgExib
										MsgAlert("O Manifesto desmarcado faz parte de um comboio. Por conta disso, os outros Manifestos que fazem parte deste comboio serão desmarcados automaticamente.")
										lMsgExib := .T.
									EndIf
								EndIf
							EndIf
						Next nAux
					EndIf
				EndIf
			Else
				If lAllMark
					aListBox[nItem,CTMARCA] := '1'
					nQtdMrk += 1
				Else
					aListBox[nItem,CTMARCA] := '2'
					nQtdMrk := 0
				EndIf
			EndIf
			If aListBox[nItem,CTMARCA] == "1"
				If !TMSAVerAge("7",,,,,,,,,,,,"2",.T.,Iif(IsInCallStack("TME73All"),.F.,.T.),,,,,aListBox[nItem,CTMANIFE])
					aListBox[nItem,CTMARCA] := "2"
				Else
					nPosMrk := Ascan(aDocMark,{ | e | e[1]+e[2]+e[3] == aListBox[nItem,CTMANIFE]+aListBox[nItem,CTFILMAN]+aListBox[nItem,CTSERMAN] })
					If nPosMrk == 0
						Aadd(aDocMark,{ aListBox[nItem,CTMANIFE], aListBox[nItem,CTFILMAN], aListBox[nItem,CTSERMAN], '' })
						nPosMrk := Len(aDocMark)
					EndIf
					aDocMark[nPosMrk,3] := aListBox[nItem,CTMARCA]
				EndIf
			EndIf
			If lRefresh
				oListBox:Refresh()
				oQtdMrk:Refresh()
			EndIf
		EndIf
	EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TME73All ³ Autor ³ Katia                 ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos os Manifesto                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TME73All()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE73                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73All(aListBox,lMarcaUm)

	Local nI      := 0
	Local lRefresh:= .T.
	Local lUmItem := .F.

	Default lMarcaUm:= .T.
	CursorWait()
	nQtdMrk := 0

	For nI := 1 To Len(aListBox)
		TME73Mrk(aListBox,nI,lRefresh,lUmItem,,lMarcaUm)
	Next nI

	CursorArrow()

	oListBox:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TME73Rfs ³ Autor ³ Katia                 ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza refresh do BROWSE independente do TIMER            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TME73Rfs()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE70                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73Rfs(aListBox, aPerg, aDocs)

	Local bLineBkp     := oListBox:bLine
	Local aListBoxBkp  := {}
	Local nI           := 0
	Local nScanList    := 0

	Default aDocs := {}

	aListBoxBkp := aListBox

	aListBox := {}

	TME73LST(@aListBox, aPerg, aDocs)

	// Re-marca os manifestos que estavam marcados antes da solicitacao de status
	For nI := 1 To len(aListBox)
		If !Empty(aListBox[nI,2])
			If (aListBox[nI,2]:CNAME != 'BR_AZUL') .and. (aListBox[nI,2]:CNAME != 'BR_MARRON')

				nScanList := aScan( aListBoxBkp,{|x| x[CTMANIFE] == aListBox[nI,CTMANIFE] })

				If nScanList > 0
					If aListBoxBkp[nScanList,CTMARCA] == '1'
						aListBox[nI,CTMARCA] := aListBoxBkp[nScanList,CTMARCA]
					End
				End
			End
		End
	Next nI

	oListBox:SetArray( aListBox )
	oListBox:bLine := bLineBkp
	oListBox:Refresh()

	If !Empty(aListBox[1,CTMANIFE])
		nQtdDoc := Len(aListBox)
	Else
		nQtdDoc := 0
	EndIf

	oQtdDoc :Refresh()
	oListBox:SetFocus()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TME73Ret³  Autor ³ Katia                 ³ Data ³05.04.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retira marca dos documentos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TME73Ret()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE73                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73Ret(aListBox)

	Local nI       := 0
	Local aDoctos  := {}
	Local lRefresh := .T.

//-- Retira a marca dos doctos autorizados
	aDoctos:= ASort( aListBox,,,{|x,y| x[ CTMARCA ] + x[ CTFILMAN ] + x[ CTMANIFE ]+ X[ CTSERMAN ] < y[ CTMARCA] + y[ CTFILMAN ] + y[ CTMANIFE ]+ y[ CTSERMAN ] })
	For nI := 1 To Len(aDoctos)
		If aDoctos[nI,CTMARCA] == '2'
			Exit
		EndIf
		If lEnvia
			If aDoctos[nI,CTSTIMDF] == '2' //-- Doc.Autorizado
				TME73Mrk(aListBox,nI,lRefresh,,.T.,.F.)
			EndIf
		ElseIf lEncerra
			If aDoctos[nI,CTSTFMDF] == '2' //-- Doc.Autorizado
				TME73Mrk(aListBox,nI,lRefresh,,.T.,.F.)
			EndIf
		EndIf
	Next nI

	oListBox:Refresh()
	oQtdDoc:Refresh()
	oQtdMrk:Refresh()

Return( Nil )

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³TME73Mon  ³ Autor ³Katia                  ³ Data ³05.04.2013³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Chama Rotina Monitor e Realiza Refresh no BROWSE            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function TME73Mon(aListBox,aPerg,cTpEvento,aDocs)
	Local   cManIni    := ''
	Local   cManFin    := ''
	Local   cSerie     := ''
	Local   aArea	   := GetArea()
	

	Default aListBox   := {}
	Default aPerg      := {}
	Default cTpEvento  := ""
	Default aDocs      := {}

	If lEnvia .Or. lUsaColab
		SpedNFe6Mnt(@cSerie,@cManIni,@cManFin,.F.,.T.,,.T.,,,,,lInCond) //-- "Monitor"
	Else
		TME73MtEve(@cSerie,@cManIni,@cManFin,cTpEvento,'58')
	EndIf
	If !lUsaColab
		WsMDFeMnt(,cSerie, cManIni, cManFin, .F.) //-- Funcao responsavel por solicitar o Status do Doc ao TSS
	EndIf
	TME73Rfs(@aListBox, aPerg, aDocs) //-- "Refresh"

	RestArea(aArea)
Return Nil

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³TME73Sped ³ Autor ³Katia                  ³ Data ³05.04.2013³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Rotina de Processamento do Envio dos Mdf's  para o TSS      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Logico                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³Param[1] - Array contendo os doc. da tela.                  ³±±
	±±³          ³lExp1    - Controle para interromper o processamento        ³±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function TME73Sped(cSerie,cManIni,cManFin,lUsacolab, aDocs)

	Local aXML        := {}
	Local cModel      := '58'  //MDFe
	Local cIdEnt      := ""
	Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cAmbiente   := ""
	Local cModalidade := ""
	Local cVerLayEven := ""
	Local cVerLayout  := ""
	Local cVersaoMDFE := ""
	Local aRet        := {}
	Local lRet        := .T.
	Local nXmlSize2   := 0
	Local cDesc       := ''
	Local aArea       := GetArea()
	Local aRetNotas   := {}
	Local aRetCol     := {}
	Local aErro       := {}
	Local cErro       := ""
	Local lRetorno    := .T.
	Local nX          := 0
	Local nY          := 0
	Local nNFes       := 0
	Local nXmlSize    := 0
	Local oWs
	Local cXML        := ""
	Local cSeek       := ""
	Local cMun        := ""
	Local cJustific   := Space(255)
	Local cChvMDF     := ""
	Local lGeraXML    := .F.
	Local aDoctos     := {}
	Local cAliasQry   := ""
	Local aAreaDTX    := {}
	Local aAreaDYN    := {}
	Local lProcXML    := .F.
	Local lHVerao     := SuperGetMV("MV_TMSHRVR",.F.,.F.) //-- Define se encontra-se no periodo de horario de verao.
	Local cHVerFil    := SuperGetMV("MV_TMSHRFL",.F.,"" ) //-- Define Filiais que nao aderiram ao horario de verao e/ou possuem diferenca de fuso.
	Local cUF         := SuperGetMV("MV_ESTADO" ,.F.,"" ) //-- Define o estado da filial
	Local aDataBase   := {}
	Local dDatMan     := ""
	Local cGrupo      := FWGrpCompany() //Retorna o grupo
	Local cFil        := FWCodFil()     //Retorna o código da filial
	Local cAviso      := ""
	Local cMsgErr     := ""
	Local cChavesMsg  := ""
	Local cMsgManif   := ""
	Local cIdEven     := ""
	Local aNfe        := {}
	Local lRetOk      := .F.
	Local cCondut     := ""
	Local nIncCond    := 0
	Local cProt       := ""
	Local cNomeDA4    := ""
	Local cCGCDA4     := ""
	Local aComp       := {}
	Local nTamComp	  := 0
	Local aDadosPag	  := {}
	Local cSeekDLI	  := ''
	Local cDocFor	  := ''
	Local lXMLIncCond := ExistFunc("XMLIncCond")
	Local cXMLIncCond := ''
	Local lSchdMon	  := "58" $ SuperGetMV( 'MV_MODTAUT' ) .And. !Empty(FWSchdByFunction('AUTONFEMON')) // Schedule Monitoramento
	
	Default cSerie    := ""
	Default cManIni   := ""
	Default cManFin   := ""
	Default lUsacolab := UsaColaboracao("5")

	If Type('lPagFrete') <> "L"
		If Type('cCDEVPGTO') == "C"  
			lPagFrete:= IIf (DLI->(ColumnPos('DLI_STAEVE')) > 0,.T.,.F.) .And.  cTpEvento == cCDEVPGTO
		Else
			lPagFrete:= .F.
		EndIf	
	EndIf

	If !lCancela
		aAreaDTX  := DTX->(GetArea())
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DTX_FILMAN, DTX_MANIFE, DTX_STIMDF, DTX_STFMDF "
		cQuery += " , DTX_SERMAN "
		If lInCond
			cQuery += " , DTX_VIAGEM, DTX_FILORI, DUP_CODMOT "
		EndIf
		If lPagFrete
			cQuery += " , DLI_SEQEVE "
		EndIf

		cQuery += " FROM " + RetSqlName('DTX') + " DTX "

		If lInCond
			cQuery += " INNER JOIN " + RetSqlName('DUP') + " DUP ON "
			cQuery += "  DUP_FILIAL = '"+ xFilial("DUP") +"'"
			cQuery += "  AND DUP_VIAGEM = DTX_VIAGEM "
			cQuery += "  AND DUP_FILORI = DTX_FILMAN "
		EndIf

		If lPagFrete
			cQuery += " INNER JOIN " + RetSqlName('DLI') + " DLI ON "
			cQuery += "  DLI.DLI_FILIAL = '"+ xFilial("DLI") +"'"
			cQuery += "  AND DLI.DLI_FILMAN = DTX_FILMAN "
			cQuery += "  AND DLI.DLI_MANIFE = DTX_MANIFE "
			cQuery += "  AND DLI.DLI_SERMAN = DTX_SERMAN "
		EndIf

		cQuery += " WHERE DTX.DTX_FILIAL = '" + xFilial('DTX') + "'"
		cQuery += "   AND DTX.DTX_FILMAN = '" + cFilAnt + "' "		
		cQuery += "   AND DTX_MANIFE BETWEEN '" + cManIni + "' AND '" + cManFin + "' "
		If !(Alltrim(cSerie) == '0')
			cQuery += " AND DTX.DTX_SERMAN = '" + cSerie + "'"
		EndIf
		cQuery += "   AND DTX.DTX_TIPMAN = '" + StrZero(2,Len(DTX->DTX_TIPMAN)) + "' "
		If lEnvia
			cQuery += "   AND DTX_STIMDF <> '2' "	
		ElseIf lPagFrete
			cQuery += "   AND DTX_STIMDF = '2' "
		Else
			cQuery += "   AND DTX_STIMDF = '2' AND DTX_STFMDF <> '2' "
		EndIf

		If lInCond
			For nIncCond := 1 to Len(aDocs)
				cCondut += "'" + aDocs[nIncCond, 5] + "', "
			Next
			cCondut := Substr(cCondut, 1, Len(AllTrim(cCondut))-1)

			cQuery += " AND DUP.D_E_L_E_T_ = ' ' AND DUP.DUP_STMDFE NOT IN ('2','3') " //2-Enviado, 3-Vinculado
			cQuery += " AND DUP.DUP_CODMOT IN (" + cCondut + ")"
		EndIf
		cQuery += "   AND DTX.D_E_L_E_T_ = ' '"
		
		If lPagFrete
			cQuery += "   AND DLI.DLI_CODEVE = '116' " 
			cQuery += "   AND DLI.DLI_STAEVE NOT IN ('1','2') "
			cQuery += "   AND DLI.D_E_L_E_T_ = ' '"
		EndIf

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		While (cAliasQry)->(!Eof())
			aadd(aDoctos,{})
			nX := Len(aDoctos)
			aadd(aDoctos[nX],(cAliasQry)->DTX_FILMAN)
			aadd(aDoctos[nX],(cAliasQry)->DTX_MANIFE)
			aadd(aDoctos[nX],"")
			If !Empty((cAliasQry)->DTX_SERMAN)
				aadd(aDoctos[nX],(cAliasQry)->DTX_SERMAN)
			Else
				aadd(aDoctos[nX],Padr(cSerie,Len(DT6->DT6_SERIE)) )
			EndIf
			If lInCond
			   aadd(aDoctos[nX],(cAliasQry)->DTX_VIAGEM)
			   aadd(aDoctos[nX],(cAliasQry)->DTX_FILORI)
			   aadd(aDoctos[nX],(cAliasQry)->DUP_CODMOT)
			EndIf

			If lPagFrete
				aadd(aDoctos[nX],(cAliasQry)->DLI_SEQEVE)
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		RestArea(aAreaDTX)
	Else
		aAreaDYN  := DYN->(GetArea())
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DYN_FILMAN, DYN_MANIFE"
		cQuery += " , DYN_SERMAN "
		cQuery += " FROM " + RetSqlName('DYN') + " DYN "
		cQuery += " WHERE DYN.DYN_FILIAL = '" + xFilial('DYN') + "'"
		cQuery += "   AND DYN.DYN_FILMAN = '" + cFilAnt + "' "
		cQuery += "   AND DYN_MANIFE BETWEEN '" + cManIni + "' AND '" + cManFin + "' "
		If !(Alltrim(cSerie) == '0')
			cQuery += " AND DYN.DYN_SERMAN = '" + cSerie + "'"
		EndIf
		cQuery += "   AND DYN.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		While (cAliasQry)->(!Eof())
			aadd(aDoctos,{})
			nX := Len(aDoctos)
			aadd(aDoctos[nX],(cAliasQry)->DYN_FILMAN)
			aadd(aDoctos[nX],(cAliasQry)->DYN_MANIFE)
			aadd(aDoctos[nX],"")
			If !Empty((cAliasQry)->DYN_SERMAN)
				aadd(aDoctos[nX],(cAliasQry)->DYN_SERMAN )
			Else
				aadd(aDoctos[nX],Padr(cSerie,Len(DT6->DT6_SERIE)) )
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		RestArea(aAreaDYN)
	EndIf

	If Len(aDoctos) > 0 .And. CTIsReady(,,,lUsaColab)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cIdEnt := RetIdEnti(lUsaColab)
		
		If lUsaColab

			cAmbiente   := ColGetPar("MV_AMBMDF","")
			cModalidade := ColGetPar("MV_MODMDF","")
			cVerLayout  := ColGetPar("MV_VLAYMDF","")
			cVerLayEven := ColGetPar("MV_EVENMDF","")
			cVersaoMDFE := ColGetPar("MV_VERMDF","")

			oDoc:cIdErp	:= aDoctos[nX][4]+aDoctos[nX][2]+cGrupo+cFil
			lErro := .F.

			lRetCons := oDoc:consultar()

			If lRetCons
				If !Empty(oDoc:cXMLRet)
					cXml := oDoc:cXMLRet
				Else
					cXml := oDoc:cXml
				EndIf
				aDados := ColDadosNf(1,"58")
				aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)

				If len(aDadosXml) > 0

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Validacao para verificar se a MDF ja foi autorizada e nao permitir retransmissao  ³
					//³ OU a MDF foi retornada que a operacao esta em contingencia                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If  ( ColMsgSefaz(oDoc:cModelo,aDadosXml[1]) .And. !Empty(aDadosXml[3]) ) .OR. ( aDadosXml[1]="1" .And. Empty(aDadosXml[3]) )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valida se o documento tem Protocolo, caso nao tenha significa que eh Contingencia³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty( aDadosXml[3] )
							cMsgErr := ColGetErro(21)[2]
						Else
							cMsgErr := ColGetErro(22)[2]
						EndIf
						lErro := .T.

					ElseIf oDoc:cCdStatDoc == "1"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valida se o documento ja foi Enviado   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cMsgErr := ColGetErro(4)[2]
						lErro := .T.
					EndIf

					If lErro
						aAdd( aErro , {} )
						aAdd( aErro[nX] , .T. )	           	//Tem erro
						aAdd( aErro[nX] , aDoctos[nX][4] )	//MDF
						aAdd( aErro[nX] , aDoctos[nX][3] )	//Serie
						aAdd( aErro[nX] , cMsgErr ) 		//Motivo
					EndIf

				EndIf
			EndIf

		Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o ambiente de execucao do Totvs Services SPED                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cIdEnt)
				oWS :=  WsSpedCfgNFe():New()
				oWS:cUSERTOKEN      := "TOTVS"
				oWS:cID_ENT         := cIdEnt
				oWS:nAmbienteMDFE   := 0 //Val(SubStr(cAmbiente,1,1))
				oWS:cVersaoMDFE     := "0.00"
				oWS:nModalidadeMDFE := 0
				oWS:cVERMDFELAYOUT  := "0.00"
				oWS:cVERMDFELAYEVEN := "0.00"
				oWS:nSEQLOTEMDFE    := 0
				oWS:cHORAVERAOMDFE  := '0'
				oWS:cHORARIOMDFE    := '0'
				oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				oWS:cModelo         := cModel
				lRet := oWS:CFGMDFE()

				If lRet 
					cAmbiente  := oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
					cModalidade:= oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE
					cVerLayEven:= oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN
					cVerLayout := oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT
					cVersaoMDFE:= oWS:OWSCFGMDFERESULT:CVERSAOMDFE
					If cModalidade <> NIL
						cModalidade    := SubStr(cModalidade,1,1)
					Else
						cModalidade    := ""
					EndIf  
				EndIf

			Else
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
				lRet:= .F.
			EndIf
		EndIf
	Else
	    If Len(aDoctos) > 0
			Aviso("SPED",STR0039,{STR0036},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
		EndIf	
		lRet:= .F.
	EndIf

	If lRet

		If lTME73ALT
			ExecBlock("TME73ALT",.F.,.F.,{aDoctos,cTpEvento})
		EndIf

		If Empty(cTpEvento)   //Envio MDF
			If !lUsaColab
				oWs:= WsNFeSBra():New()
				oWs:cUserToken := "TOTVS"
				oWs:cID_ENT    := cIdEnt
				oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cModelo    := '58'
				oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
			EndIf

			For nX := 1 To Len(aDoctos)

				aXml := ExecBlock("MdfeSf30",.F.,.F.,{aDoctos[nX][1], aDoctos[nX][2], SubStr(cAmbiente,1,1), cVersaoMDFE, cModalidade, 'I', aDoctos[nX][4], TZoneUTC(cIdEnt)})
				nXmlSize2 := Len(aXML[2])

				If !Empty(aXML[2]) .And. nXmlSize2 <= TAMMAXXML
					If nXmlSize + Len(aXML[2]) <= TAMMAXXML
						nY++
						nNFes++
						nXmlSize += Len(aXML[2])
						If lUsaColab			//   ID ERP(Serie+NF+Emp+Fil)      Erro     XML		 Entr/Saida	    Serie				NF				Cliente		   Loja							 Retorno da Transmissao
							lRetorno := XMLRemCol("MDF"+aXml[4]+aXml[3]+cGrupo+cFil , @cErro , aXml[2] , aDoctos[nX][1] , aDoctos[nX][3] , aDoctos[nX][2] , /*aDoctos[nX][5]*/ , /*aDoctos[nX][6]*/ , @nXmlSize , nY , @aRetCol)
						Else
							aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())
							aadd(aRetNotas,aDoctos[nX])
							oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cID := '58' + aDoctos[nX][4]+aDoctos[nX][2]    //Serie + Manifesto
							oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cXML:= aXML[2]
						EndIf
					Else
						If lUsaColab			//   ID ERP(Serie+NF+Emp+Fil)      Erro     XML		 Entr/Saida	    Serie				NF				Cliente		   Loja							 Retorno da Transmissao
							lRetorno := XMLRemCol("MDF"+aXml[4]+aXml[3]+cGrupo+cFil , @cErro , aXml[2] , aDoctos[nY][1] , aDoctos[nY][3] , aDoctos[nY][2] , /*aDoctos[nY][5]*/ , /*aDoctos[nY][6]*/ , @nXmlSize , nY , @aRetCol)
						Else
							lRetorno := XMLRemMDF(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL)
						EndIf
						If !lRetorno
							Exit
						EndIf
						nX -- //- Diminui o contador para que seja pego a nota corrente
						Loop
					EndIf
				ElseIf !Empty(aXML[2]) .And. nXmlSize2 > TAMMAXXML
					If !lAuto
						Aviso("SPED",STR0037+CRLF+CRLF+STR0038+aDoctos[nX][1]+" / "+aDoctos[nX][2],{STR0036},3)
					EndIf
					nXmlSize2 := 0
				EndIf
				If ((nY >=50 .Or. nX == Len(aDoctos) .Or. nXmlSize>=TAMMAXXML) .And. nNFes > 0) .And. !lUsaColab
					lRetorno:= XMLRemMDF(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL)
				EndIf
			Next nX

			//---------- Gravacao dos Dados do retorno da SEFAZ --------
			If lRetorno
				If lUsaColab
					TME73ASt(cFilAnt, cManIni, cManFin, "1", "", cSerie)
				Else
					//-- Resfresh - TMSAE73A
					TMSAE73TMR()
					If (Empty(MV_PAR01TM) .Or. MV_PAR01TM <= 9) .And. !lSchdMon
						Sleep(8000)
					ElseIf MV_PAR01TM >= 10 .And. !lSchdMon  
						Sleep( MV_PAR01TM * 1000 )
					EndIf 
					WsMDFeMnt(cIdent, cSerie, cManIni, cManFin, .F.)
				EndIf
			Else
			//-- Rotina responsavel por gravar o status e descricao do doc. " Nao Transmitido, falha de comunicacao."
				If Empty(cErro)
					cDesc := STR0026 // -- "Documento com Falha na Comunicação"
					TME73ASt(cFilAnt, cManIni, cManFin, "5", cDesc, cSerie)
				Else
					cDesc := cErro
					TME73ASt(cFilAnt, cManIni, cManFin, "1", cDesc, cSerie)
				EndIf
				lRet:= .F.
			EndIf

		ElseIf cTpEvento == cCDEVECAN .Or. cTpEvento == cCDEVEENC .Or. cTpEvento == cCDEVINCO .Or. cTpEvento == cCDEVPGTO //Encerramento ou Cancelamento ou Inclusao de Condutor
			lProcXML:= .F.

 			For nX := 1 To Len(aDoctos)
				lGeraXML:= .F.

				If !lCancela				
					If !(Alltrim(aDoctos[nX][4]) == '0')
						cSeek 	 := xFilial("DTX")+aDoctos[nX][1]+aDoctos[nX][2]+aDoctos[nX][4]						
					Else
						cSeek 	 := xFilial("DTX")+aDoctos[nX][1]+aDoctos[nX][2]						
					EndIf					
					DTX->(DbSetOrder(2))
					If DTX->(MsSeek(cSeek))
						If !lInCond .And. !lPagFrete
							If (!AllTrim(DTX->DTX_CODEVE) $ "2,3")
								If (AllTrim(DTX->DTX_IDIMDF) == "100" .Or. !Empty(DTX->DTX_CTGMDF))   //2-Enviado, 3-Vinculado
									lGeraXML := .T.
								EndIf
							Else
								If AllTrim(DTX->DTX_CODEVE) == "2" .And. DTX->DTX_IDFMDF > "200"  //Evento Rejeitado
									lGeraXML := .T.
								EndIf
							EndIf
						ElseIf lInCond
							DUP->(DbSetOrder(2))
							If DUP->(MsSeek(xFilial("DUP")+aDoctos[nX][1]+DTX->DTX_VIAGEM+aDoctos[nX][7]))
								If (!AllTrim(DUP->DUP_STMDFE) $ "2,3") //2-Enviado, 3-Vinculado
									lGeraXML := .T.
								EndIf
							EndIf
						ElseIf lPagFrete //--Tratar para verificar se o evento da DLI, está com status 1=Aguardando. (DLI_STAEVE)							
							If aDoctos[nX][4] == Padr(0,Len(DT6->DT6_SERIE))
								cSeekDLI := xFilial("DLI")+aDoctos[nX][1]+aDoctos[nX][2]+Space(Len(DT6->DT6_SERIE))+Right(cCDEVPGTO,3)+aDoctos[nX][5]
							Else
								cSeekDLI := xFilial("DLI")+aDoctos[nX][1]+aDoctos[nX][2]+aDoctos[nX][4]+Right(cCDEVPGTO,3)+aDoctos[nX][5]						
							EndIf		
							DLI->(dbSetorder(1))
							If DLI->(MsSeek(cSeekDLI)) .And. DLI->DLI_STAEVE $ "0,3" //0=Preparado para Transmissão;1=Envio Evento realizado;2=Evento vinculado com sucesso;3=Evento rejeitado
								lGeraXML := .T.	
							EndIf	
						EndIf

						If lGeraXML
							cChvMDF := Alltrim(DTX->DTX_CHVMDF)
						EndIf
					EndIf
				Else
					If !(Alltrim(aDoctos[nX][4]) == '0')
						DYN->(DbSetOrder(3))
						If DYN->(MsSeek(xFilial("DYN")+aDoctos[nX][1]+aDoctos[nX][2]+aDoctos[nX][4]))
							If AllTrim(DYN->DYN_CODEVE) $ "2,3"    //2-Enviado, 3-Vinculado
								If AllTrim(DYN->DYN_CODEVE) == "2" .And. (Empty(DYN->DYN_IDCMDF) .Or. DYN->DYN_IDCMDF > "200")   //Evento Rejeitado
									lGeraXML := .T.
								EndIf
							Else
								lGeraXML := .T.
							EndIf

							If lGeraXML
								cJustific:= NoAcentoCte( StrTran(MsMM(DYN->DYN_CODOBS),Chr(13),"") )
								cChvMDF := Alltrim(DYN->DYN_CHVMDF)
							EndIf
						EndIf
					Else
						DYN->(DbSetOrder(1))
						If DYN->(MsSeek(xFilial("DYN")+aDoctos[nX][1]+aDoctos[nX][2]))
							If AllTrim(DYN->DYN_CODEVE) $ "2,3"    //2-Enviado, 3-Vinculado
								If AllTrim(DYN->DYN_CODEVE) == "2" .And. DYN->DYN_IDCMDF > "200"   //Evento Rejeitado
									lGeraXML := .T.
								EndIf
							Else
								lGeraXML := .T.
							EndIf
							If lGeraXML
								cJustific:= NoAcentoCte( StrTran(MsMM(DYN->DYN_CODOBS),Chr(13),"") )
								cChvMDF := Alltrim(DYN->DYN_CHVMDF)
							EndIf
						EndIf
					EndIf
				EndIf
				If lGeraXML
					If lUsaColab
						//-- dados da NF-e. [1] - Chave [2] - Recno [3] - Serie [4] - Numero
						aNfe := {"MDF"+aDoctos[nX][4]+aDoctos[nX][2]+cGrupo+cFil,0,aDoctos[nX][4],aDoctos[nX][2],cTpEvento}
						cIdEven := ""
						If cTpEvento == '110112'
							cProt := DTX->DTX_PRIMDF
						ElseIf  cTpEvento == '110111'
							cProt := DYN->DYN_PRIMDF
						EndIf
						If cTpEvento == cCDEVINCO
							cXMLIncCond := XMLIncCond(aDoctos[nX][5], aDoctos[nX][6], aDoctos[nX][7],lUsaColab) //nViagem, nFilOri, mCodMot
						EndIf
						cMun		:= NoAcentoCte( SM0->M0_CODMUN )
						cXml 		:= SpedCCeXml(aNfe,cJustific,cTpEvento,cProt,"MDF",cChvMDF,cMun,.F.,cXMLIncCond)
						//-- Adiciona a CHAVE da nota para solicitar o envio.
						If cTpEvento == cCDEVINCO  
							lRetOk := ColEnvEvento("ICC",aNfe,cXml,@cIdEven,@cErro,lCancela,,,.T.)
						Else
							lRetOk := ColEnvEvento("MDF",aNfe,cXml,@cIdEven,@cErro,lCancela,,,.T.)
						EndIf
						If	lRetOk == .T.
							aadd(aRet,cIdEven)
						Else
							Aviso("MD-e TOTVS Colaboração 2.0",cErro,{STR0036},3) //"Ok"
						EndIf
						
						If lRetOk .And. Len(aRet) > 0
							For nX := 1 To Len(aRet)
							    aRet[nX]:= Substr(aRet[nX],9,44)
							    cChavesMsg += aRet[nX] + Chr(10) + Chr(13)
							Next nX
							cMsgManif := "Transmissão da Manifestação concluída com sucesso!"+ Chr(10) + Chr(13)
							cMsgManif += "Chave(s): "+ Chr(10) + Chr(13)
							cMsgManif += cChavesMsg
							Aviso("Envio Manifesto",Alltrim(cMsgManif),{"OK"},3)
						EndIf
						//-- Atualizacao do Status do registro de saida //0-Nao se aplica; 1-Em aberto; 2-Enviado, 3-Encerrado
//						Se Status "3" ou "5" ->	4 - Evento rejeitado +msg rejeiçao
//						Se Status "6"        -> 3 - Evento vinculado com sucesso
//						Se Status "1"        -> 2 - Envio de Evento realizado - Aguardando processamento
						If cTpEvento == '110112'
							DTX->(DbSetOrder(7))
							If DTX->(DbSeek(xFilial("DTX")+cFilAnt+AllTrim(cChvMDF)))
								RecLock("DTX")
								DTX->DTX_CODEVE := "2"  //Envio de Evento realizado - Aguardando processamento
								MsUnlock()
							EndIf
						Else
							DYN->(DbSetOrder(2))
							If DYN->(DbSeek(xFilial("DYN")+cFilAnt+AllTrim(cChvMDF)))
								RecLock("DYN")
								DYN->DYN_CODEVE := "2"  //Envio de Evento realizado - Aguardando processamento
								MsUnlock()
							EndIf
						EndIf

					Else
						//-- Busca a data e hora de emissao - Tratamento horário de verão
						If	!Empty(cHVerFil) .And. cFilAnt $ cHVerFil
							If	FindFunction("FwTimeUF")
							//-- Depois de oito anos sem adota-lo, o estado da Bahia, no Nordeste, o adotou em 2011.
							//-- Em 2012, no entanto, a Bahia voltou atras nessa decisao.
								cUF := IIF(cUF == "BA", "PE", cUF)
								aDataBase := FwTimeUF(cUF,,lHVerao)
								dDatMan   := Stod(aDataBase[1])
							EndIf
						Else
							dDatMan := dDataBase
						EndIf
						
						//Busca Motoristas para Inclusão
						If !lXMLIncCond
							If 	cTpEvento == cCDEVINCO
								cAliasQry := GetNextAlias()
								cQuery := " SELECT DUP.DUP_CODMOT, DA4.DA4_NOME, DA4.DA4_CGC "
								cQuery += " FROM " + RetSqlName('DUP') + " DUP "
								cQuery += " INNER JOIN " + RetSqlName('DA4') + " DA4 "
								cQuery += " ON DA4_FILIAL = '" + xFilial('DA4') + "'"
								cQuery += " AND DA4.DA4_COD = DUP.DUP_CODMOT "
								cQuery += " WHERE DUP.DUP_FILIAL = '" + xFilial('DUP') + "'"
								cQuery += " AND DUP.DUP_VIAGEM = '" + aDoctos[nX][5] + "' "
								cQuery += " AND DUP.DUP_STMDFE <> '3' " //Somente Motorista nao transmitido.
								cQuery += " AND DUP.DUP_FILORI = '" + aDoctos[nX][6] + "' "
								cQuery += " AND DUP.DUP_CODMOT = '" + aDoctos[nX][7] + "' "
								cQuery += " AND DUP.D_E_L_E_T_ = ' '"
								cQuery := ChangeQuery(cQuery)
								DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
								If (cAliasQry)->(!Eof())
									cNomeDA4:= (cAliasQry)->DA4_NOME
									cCGCDA4 := (cAliasQry)->DA4_CGC
								EndIf
								(cAliasQry)->(dbCloseArea())
							EndIf
						EndIf
						If (nX == 1 .Or. cTpEvento == cCDEVINCO .Or. cTpEvento == cCDEVPGTO) .Or. (nX > 1 .And. At('<envEvento>', cXml) == 0 .And. lGeraXML)
							cXml+='<envEvento>'
							cXml+='<eventos>'
						EndIf
						cXml+='<detEvento>'
						cXml+='<tpEvento>'+cTpEvento+'</tpEvento>' 
						cXml+='<chNFe>'+cChvMDF+'</chNFe>'
						If cTpEvento <> cCDEVPGTO
							cXml+='<ambiente>'+SubStr(cAmbiente,1,1)+'</ambiente>'
						EndIf	
						If cTpEvento == cCDEVEENC
							cXml+='<dtEnc>'+SubStr(DtoS(dDatMan),1,4) + '-' + SubStr(DtoS(dDatMan),5,2) + '-' + SubStr(DtoS(dDatMan),7,2) +'</dtEnc>'
							cXml+='<cUF>'+NoAcentoCte( SM0->M0_ESTENT )+'</cUF>'
							cXml+='<cMun>'+NoAcentoCte( SM0->M0_CODMUN )+'</cMun>'						
						ElseIf cTpEvento == cCDEVINCO
							If lXMLIncCond
								cXml+= XMLIncCond(aDoctos[nX][5], aDoctos[nX][6], aDoctos[nX][7]) //nViagem, nFilOri, mCodMot
							Else
								cXml+='<NOMECONDUTOR>'+AllTrim(NoAcentoCte(cNomeDA4))+'</NOMECONDUTOR>'
								cXml+='<CPFCONDUTOR>'+AllTrim(cCGCDA4)+'</CPFCONDUTOR>'	
							EndIf
						ElseIf cTpEvento == cCDEVPGTO .And. lPagFrete
							
							//Rotina para retornar os dados do evento
							If Len( aDadosPag := T73RetEvPg(DTX->DTX_FILMAN, DTX->DTX_MANIFE)		) > 0
							
							
								cXml+= 			'<qtdViagens>' 	+'00001'+ 	'</qtdViagens>'
								cXml+=			'<nroViagem>' 	+'00001'+	'</nroViagem>'							
								
								cXml+= 		'<infPag>'
								cXml+= 			'<xNome>' 	+ AllTrim(NoAcentoCte(aDadosPag[1,nPOSNOMFOR])) + '</xNome>'							
								If aDadosPag[1,nPOSTIPFOR] == 'J'
									cDocFor := 'CNPJ' 
								ElseIf aDadosPag[1,nPOSTIPFOR] == 'F'
									cDocFor := 'CPF'
								ElseIf aDadosPag[1,nPOSTIPFOR] == 'X'
									cDocFor := 'idEstrangeiro'
								EndIf
								cXml+= 			'<'+cDocFor+'>' 	+ aDadosPag[1,nPOSCNPJOP] + '</'+cDocFor+'>'
								If Len(aDadosPag[1]) >= nPOSDADPAG
									aComp := (aDadosPag[1,nPOSDADPAG])
								EndIf	
								If Empty(aComp)
									cXml+= 		'<Comp>' 								
									cXml+= 				'<tpComp>' 	+ '99' + '</tpComp>'
									cXml+= 				'<vComp>' 	+ allTrim(Str(aDadosPag[1,nPOSVALFRE] ,13,2))  +	'</vComp>'																																				
									cXml+= 		'</Comp>'								
								Else
									For nTamComp := 1 To Len(aComp)
										cXml+= 		'<Comp>' 								
										cXml+= 				'<tpComp>' 	+ aComp[nTamComp][nCmpTIPO]+	'</tpComp>'
										cXml+= 				'<vComp>' 	+ AllTrim(STR(aComp[nTamComp][nCmpVALPAS], 13,2)) +	'</vComp>'									
										cXml+= 				'<xComp>'	+ aComp[nTamComp][nCmpDESCRI]+	'</xComp>'								
										cXml+= 		'</Comp>'								
									Next nTamComp
								EndIf	
								
								cXml+= 			'<vContrato>'	+ AllTrim(Str(aDadosPag[1,nPOSVALFRE] ,13,2)) +	'</vContrato>'
								cXml+= 			'<indPag>'		+'0'+	'</indPag>'
								
								cXml+= 			'<infBanc>'			
								If !Empty(aDadosPag[1,nPOSCNPJOP])
									cXml+=				'<CNPJIPEF>'	+aDadosPag[1,nBANCNPJOP] +	'</CNPJIPEF>'
								Else									
									cXml+=				'<codBanco>'  + aDadosPag[1,nBANCODIGO] + '</codBanco>'
									cXml+=				'<codAgencia>'	+ aDadosPag[1,nBANAGENCI] +	'</codAgencia>'
								EndIf	
								cXml+= 			'</infBanc>'
								cXml+= 		'</infPag>'
							EndIf
						Else
							cXml+='<xJust>'+Alltrim(cJustific)+'</xJust>'
						EndIf
						cXml+='</detEvento>'

						lProcXML:= .T.
						
						If cTpEvento == cCDEVINCO 
							cXml+='</eventos>'
							cXml+='</envEvento>'
							lProcXML:= .F.
							AADD(aXml, cXml)
							cXml := ""
						EndIf
					EndIf
				EndIf
			Next nX

			If lProcXML
				cXml+='</eventos>'
				cXml+='</envEvento>'
			EndIf

			//-- Envio do Evento
			If !lUsaColab
				If !Empty(cXml) .Or. cTpEvento == cCDEVINCO
				   //Gravar dados de update na tabela de condutor
				   If cTpEvento == cCDEVINCO
				   		For nX := 1 To Len(aDoctos)
				   			TMS73UPENC(aDoctos[nX][5], aDoctos[nX][6], aDoctos[nX][7], cChvMDF, nX)
				   			lRetorno:= RetEnvManif(aXml[nX],cIdEnt,cUrl,@aRet,'58')    //SPEDMANIFE
				   		Next nX
				   	Else
				   		lRetorno:= RetEnvManif(cXml,cIdEnt,cUrl,@aRet,'58')    //SPEDMANIFE
				   EndIf
					If (Empty(MV_PAR01TM) .or. MV_PAR01TM <= 0) 
						Sleep(8000)
					End
					//-- Retorno do Envio do Evento
					If lRetorno .And. Len(aRet) > 0
						aRetEven:= RetMonEven(Substr(aRet[1],9,44),SubStr(aRet[Len(aRet)],9,44),cTpEvento,'58',lUsaColab)   //SPEDMANIFE
					EndIf
					//-- Chamada Monitor para gravacao do DTX
					WsMDFeMnt(cIdent,cSerie, cManIni, cManFin,.F.)
				EndIf
			EndIf
        EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³XMLRemMDF ³ Autor ³ Gustavo. G. Rueda     ³ Data ³24.03.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel pela envio do XML ao TSS                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function XMLRemMDF(oWs,cErro,aRetNotas,nTotNf,nXmlSize,cIdEnt,cURL)
	Local nY
	Local lRetorno := .T.

	If nXmlSize>0 .And. oWs:Remessa()
		If Len(oWs:oWsRemessaResult:oWSID:cString) <> nTotNF
			cErro := STR0040+CRLF+CRLF //"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
		Else
			For nY := 1 To Len(aRetNotas)
				If Len(oWs:oWsRemessaResult:oWSID:cString) <> nY
					If aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][4]+aRetNotas[nY][2])==0
						cErro += "MDFe: "+aRetNotas[nY][4]+aRetNotas[nY][2]+CRLF
					EndIf
				EndIf
			Next nY
		EndIf

		oWs:= WsNFeSBra():New()
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
		oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
		nTotNF := 0
		nXmlSize := 0
		aRetNotas := {}
	Else
		cErro := GetWscError(3)
		DEFAULT cErro := STR0025 //"Erro indeterminado"
		lRetorno := .F.
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WsMDFeMnt ³ Autor ³ Katia                 ³ Data ³10.05.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que solicita o status do documento ao TSS e grava os ³±±
±±³          ³retornos na tabela DX e DYN - TMS                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WsMDFeMnt(cIdent, cSerie, cMdfMin, cMdfMax, lMonitor,lConsulta)

	Local aAreaDTX := DTX->(GetArea())
	Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local lOk      := .T.
	Local oWS
	Local oRetorno
	Local nTamserie := TamSx3("DT6_SERIE")[1]
	Local nTamanif  := TamSx3("DTX_MANIFE")[1]
	Local cNrSerie := ''
	Local cNrManif := ''
	Local dMDFeEmis:= CtoD("")
	Local cSitMDF  := ''
	Local cNrProt  := ''
	Local cModelo  := '58'
	Local aListBox := {}
	Local aListBox2 := {}
	Local aMsg     := {}
	Local aXML     := {}
	Local nAmbien  := 0
	Local nX       := 0
	Local nY       := 0
	Local nZ       := 0
	Local nRange   := Val(cMdfMax) - Val(cMdfMin)
	Local nLastXml := 0
	
	Local oOk      := LoadBitMap(GetResources(), "ENABLE")
	Local oNo      := LoadBitMap(GetResources(), "DISABLE")
	Local nTamRet  := TamSx3("DTX_RTIMDF")[1] 
	
	Default lMonitor := .T.
	Default cIdent   := ""
	Default lConsulta := .F.

	Private oXml
	
	If Type('lPagFrete') <> "L" 
		If Type('cCDEVPGTO') == "C"  
			lPagFrete:= IIf (DLI->(ColumnPos('DLI_STAEVE')) > 0,.T.,.F.) .And.  cTpEvento == cCDEVPGTO
		Else
			lPagFrete:= .F.
		EndIf	
	EndIf

	If Empty(cIdent)
		If (CTIsReady(,,,lUsaColab))
			cIdEnt := RetIdEnti(lUsaColab)
		EndIf
	EndIf

	If (lInCond .Or. lPagFrete) .And. !lUsaColab
		// Executa o metodo NfeRetornaEvento()
		oWS:= WSNFeSBRA():New()
		oWS	:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
		
		If lPagFrete
			oWS:cEVENTO	:= cCDEVPGTO
		Else
			oWS:cEVENTO	:= cCDEVINCO
		EndIf
		oWS:cMODELO			:= '58'

		If !(Alltrim(cSerie) == '0')
			cSeek := xFilial('DTX')+cFilAnt+PadR(cMdfMin, Len(DTX->DTX_MANIFE))+PadR(cSerie, Len(DTX->DTX_SERMAN))
		Else
			cSeek := xFilial('DTX')+cFilAnt+PadR(cMdfMin, Len(DTX->DTX_MANIFE))
		EndIf
		DTX->(dbSetOrder(2))
		If	DTX->(MsSeek(cSeek))
		    oWS:cCHVINICIAL := DTX->DTX_CHVMDF
		EndIf

		If !(Alltrim(cSerie) == '0')
			cSeek := xFilial('DTX')+cFilAnt+PadR(cMdfMax, Len(DTX->DTX_MANIFE))+PadR(cSerie, Len(DTX->DTX_SERMAN))
		Else
			cSeek := xFilial('DTX')+cFilAnt+PadR(cMdfMax, Len(DTX->DTX_MANIFE))
		EndIf
		DTX->(dbSetOrder(2))
		If	DTX->(MsSeek(cSeek))
		    oWS:cCHVFINAL	:= DTX->DTX_CHVMDF
		EndIf

		lOk:=oWS:NFEMONITORLOTEEVENTO()
		If lOk
			If Valtype(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "A"
				aMonitor := {oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento}
			Else
				aMonitor := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
			EndIF

			For nX:=1 To Len(aMonitor)
				AADD( aListBox, {	If(aMonitor[nX]:nStatus <> 6 .And. aMonitor[nX]:nStatus <> 7 ,oNo,oOk),;
					If(aMonitor[nX]:nProtocolo <> 0 ,Alltrim(Str(aMonitor[nX]:nProtocolo)),""),;
					aMonitor[nX]:cId_Evento,;
					Alltrim(Str(aMonitor[nX]:nAmbiente)),;
					Alltrim(Str(aMonitor[nX]:nStatus)),;
					If(!Empty(aMonitor[nX]:cCMotEven),Alltrim(aMonitor[nX]:cCMotEven),Alltrim(aMonitor[nX]:cMensagem)),;
					AllTrim(Str(aMonitor[nX]:NCSTATENV)) })
			Next
			If lPagFrete
				TME73UpdPT(aListBox)
			Else
				TME73UpdIC(aListBox)
			EndIf
       EndIf

	ElseIf !lUsaColab
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN    := "TOTVS"
		oWS:cID_ENT       := cIdEnt
		oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
		If lConsulta
			oWS:cIdInicial    := cSerie + cMdfMin
			oWS:cIdFinal      := cSerie + cMdfMax
		Else
			oWS:cIdInicial    := "58"+cSerie + cMdfMin
			oWS:cIdFinal      := "58"+cSerie + cMdfMax
		EndIf
		oWS:cModelo       := cModelo
		lOk := oWS:MONITORFAIXA()
		oRetorno := oWS:oWsMonitorFaixaResult

		For nX := 1 To Len(oRetorno:oWSMONITORNFE)

			If lMonitor
				aMsg := {}
				oXml := oRetorno:oWSMONITORNFE[nX]
				If Type("oXml:OWSERRO:OWSLOTENFE")<>"U"
					nLastRet := Len(oXml:OWSERRO:OWSLOTENFE)
					For nY := 1 To Len(	oXml:OWSERRO:OWSLOTENFE)
						If oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE<>0
							aadd(aMsg,{oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE,oXml:OWSERRO:OWSLOTENFE[nY]:DDATALOTE,oXml:OWSERRO:OWSLOTENFE[nY]:CHORALOTE,;
								oXml:OWSERRO:OWSLOTENFE[nY]:NRECIBOSEFAZ,;
								oXml:OWSERRO:OWSLOTENFE[nY]:CCODENVLOTE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGENVLOTE,50),;
								oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETRECIBO,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETRECIBO,50),;
								oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE,5000)})
						EndIf
					Next nY
				EndIf
			EndIf

			If Len(AllTrim(cMdfMin)) < 9
				nY       := Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)
				cNrSerie := Substr(oRetorno:OWSMONITORNFE[nX]:CID,Len(oRetorno:OWSMONITORNFE[nX]:CID)- (nTamserie+Len(AllTrim(cMdfMin))-1),(nTamserie))
				cNrManif := SubStr(oRetorno:OWSMONITORNFE[nX]:CID,Len(oRetorno:OWSMONITORNFE[nX]:CID)- (Len(AllTrim(cMdfMin))-1))
			Else
				nY       := Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)
				cNrSerie := Substr(oRetorno:OWSMONITORNFE[nX]:CID,Len(oRetorno:OWSMONITORNFE[nX]:CID)- (nTamserie+nTamanif-1),(nTamserie))
				cNrManif := SubStr(oRetorno:OWSMONITORNFE[nX]:CID,Len(oRetorno:OWSMONITORNFE[nX]:CID)- (nTamanif-1))
			EndIf

	/*
		100 Autorizado o uso do MDF-e
		101 Cancelamento de MDF-e homologado
		103 Arquivo recebido com sucesso
		104 Arquivo processado
		105 Arquivo em processamento
		106 Arquivo não localizado
		107 Serviço em Operação
		108 Serviço Paralisado Momentaneamente (curto prazo)
		109 Serviço Paralisado sem Previsão
		111 Consulta cadastro com uma ocorrência
		112 Consulta cadastro com mais de uma ocorrência
		132 Encerramento de MDF-e homologado
		135 Evento registrado e vinculado a MDF-e
		136 Evento registrado, mas não vinculado a MDF-e

			0 - Nao Transmitido
			1 - MDF-e Aguardando
			2 - MDF-e Autorizado
			3 - MDF-e Nao Autorizado
			4 - MDF-e em Contingencia
			5 - MDF-e com Falha na Comunicacao

	*/
			If !lMonitor
				If (!Empty(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO))		//-- Mensagem do TSS.
					cSitMDF := oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE
					cCodRet := Substr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,3)
					cNrProt := oRetorno:OWSMONITORNFE[nX]:CPROTOCOLO
					nAmbien := oRetorno:OWSMONITORNFE[nX]:NAMBIENTE
					cRecome := oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO
					cMsgRet := SubStr(	oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CCODRETNFE;
										+ " - " + ;
										oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE,1,nTamRet )
					//--> Atualizar status dos manifestos
					dMDFeEmis:= oRetorno:OWSMONITORNFE[nx]:owserro:owslotenfe[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:DDATALOTE

					TME73Upd(cNrManif,cNrSerie,cSitMDF,cCodRet,cNrProt,nAmbien,cRecome,cMsgRet,,dMDFeEmis)


				EndIf
			EndIf

			If lMonitor
				aadd(aListBox,{ IIf(Empty(oXml:cPROTOCOLO),oNo,oOk),;
					oXml:cID,;
					IIf(oXml:nAMBIENTE==1,STR0042,STR0043),; //"Produção"###"Homologação"
					IIf(oXml:nMODALIDADE==1 .Or. oXml:nMODALIDADE==4 .Or. oXml:nModalidade==6,STR0044,STR0045),; //"Normal"###"Contingência"
					oXml:cPROTOCOLO,;
					PadR(oXml:cRECOMENDACAO,250),;
					oXml:cTEMPODEESPERA,;
					oXml:nTEMPOMEDIOSEF,;
					aMsg})

				aXml     := {}
				nLastXml := 0
			EndIf

		Next nX
		If Len(oRetorno:oWSMONITORNFE) <> nRange .And. !lConsulta
			aListBox2 := WsMDFeMnt(cIdent, cSerie, cMdfMin, cMdfMax, lMonitor,.T.)
			For nZ := 1 To Len(aListBox2)
				aadd(aListBox,aListBox2[nZ])
			Next nZ
			aSort(aListBox,,,{|x,y| x[2] < y[2]})
		EndIf
	EndIf
	RestArea(aAreaDTX)

Return(Iif(lMonitor .Or. lConsulta, aListBox, Nil))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TME73UpdIC  ³ Autor ³ Manutencao DL       ³ Data ³19.01.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função de atualizacao do status dos inclusao Condutor       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TME73UpdIC(aListBox)
Local cSeek       := ''
Local nI := 0
Local cQuery 	:= ""
Local cMsg 	:= ""
Local cStat 	:= ""
Local aDTXArea := DTX->(GetArea())

If lUsaColab
	DTX->(dbSetOrder(1))
Else
	DTX->(dbSetOrder(7))
EndIf

	For nI := 1 To Len(aListBox)
		cMsg  := ""
		cStat := ""
		If lUsaColab
			cSeek := xFilial('DTX')+aListBox[nI][3]+aListBox[nI][2]
		Else
			cSeek := xFilial('DTX')+cFilAnt+Substr(aListBox[nI][3],9,44)
		EndIf

		If	DTX->(MsSeek(cSeek))
			If lUsaColab
				cMsg := aListBox[nI][5] + ' - ' + aListBox[nI][6]
			Else
				If aListBox[nI][5] == "1"
					cMsg := "Envio de Evento realizado - Aguardando processamento"
				Else
					cMsg := aListBox[nI][7] + ' - ' + aListBox[nI][6]
				EndIf
			EndIf

			If lUsaColab
				If aListBox[nI][5] == "135"
					cStat := "3"  //Evento vinculado com sucesso
				EndIf
			Else
				If aListBox[nI][5] == "3" .Or. aListBox[nI][5] == "5"
					cStat := "4"  //Evento rejeitado +msg rejeiçao
				ElseIf aListBox[nI][5] == "6"
					cStat := "3"  //Evento vinculado com sucesso
				ElseIf aListBox[nI][5] == "1"
					cStat := "2"  //Envio de Evento realizado - Aguardando processamento
				EndIF
			EndIf

	   		cQuery := " UPDATE " + RetSqlName("DUP") + " SET DUP_STMDFE = '" + cStat + "', "
	   		cQuery += " DUP_RTMDFE = '" + cMsg + "'"
			cQuery += " WHERE DUP_FILIAL = '" + xFilial("DUP") + "'"
			cQuery += " AND DUP_VIAGEM = '" + DTX->DTX_VIAGEM + "'"
			cQuery += " AND DUP_FILORI = '" + DTX->DTX_FILORI + "'"
			cQuery += " AND DUP_SEQEVE = '" + Substr(aListBox[nI][3],53,2) + "'"
			cQuery += " AND DUP_STMDFE <> '3' AND D_E_L_E_T_ =  ' '"
			TCSqlExec( cQuery )
		
			If !lUsaColab
				//--Grava os eventos do MDFe - Inclusao do Condutor
				If ExistFunc("TmsAvbeM") .And. TableIndic("DLI")
					If cStat == "3" //--Evento vinculado
						TmsAvbeM(DTX->DTX_FILMAN, DTX->DTX_MANIFE, DTX->DTX_SERMAN, DTX->DTX_DATMAN,StrZero(Val(cStat),3),Substr(aListBox[nI][3],53,2))
					EndIf
				EndIf
			EndIf

	    EndIf
	Next nI
	
RestArea(aDTXArea)

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TME73Upd    ³ Autor ³ Manutencao DL       ³ Data ³30.09.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função de atualizacao do status dos manifestos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

	CODIGOS RETORNO TSS

 	001 - Emissão de DAMDFE autorizada
	002 - Não foi possível assinar o MDFe - entre em contato com o responsavel
	003 - O MDFe ainda não foi assinado - aguarde a assinatura.
	004 - Lote ainda não transmitido, verifique o status da SEFAZ
	005 - Lote recusado, verifique o motivo da SEFAZ
	006 -
	007 - Autorizada operacao em contigencia
	008 - Autorizada manutencao da operacao em contigencia
	009 - Aguardar processamento do lote
	010 - Lote nao autorizado. Corrija o problema e retransmita os manifestos de documentos fiscais eletronicos
	011 - Entre em contato com a SEFAZ, verifique a versão de layout suportada e atualize os parametros do sistema
	012 - Lote nao autorizado. Verifique os motivos junto a SEFAZ
	013 - MDFe nao autorizado - Verifique os motivos junto a SEFAZ
	014 - MDFe nao autorizado - Corrija o problema e retransmita os manifestos de documentos fiscais eletronicos
	015 - Cancelamento do MDF-e autorizado
	016 - Cancelamento do MDF-e nao transmitido, verifique o status da SEFAZ
	017 - Cancelamento do MDF-e nao autorizado. Verifique os motivos junto a SEFAZ
	018 - Dpec autorizado. Emissão de DANFE autorizada
	019 - Emissao do RPS autorizado
	020 - Lote ainda nao transmitido
	021 - RPS ainda nao foi assinado - aguarde a assinatura
	022 - Nao foi possivel assinar o RPS - entre em contato com o responsavel
	023 - Lote ainda nao transmitido
	024 - Lote recusado
	025 - Cancelamento nao transmitido
	026 - Cancelamento nao autorizado
	027 - RPS Inutilizado
	028 - Certificado digital Ausente.
	029 - Falha no Schema do XML.
	030 - Inutilizacao de numeracao autorizada.
	031 - Inutilizacao nao transmitida, verifique o status da SEFAZ.
	032 - Inutilização nao autorizada. Verifique os motivos junto a SEFAZ.
	033 - Encerramento do MDFe nao transmitido.
	034 - Encerramento do MDFe nao autorizado. Verifique os motivos junto a SEFAZ.
	035 - Encerramento do MDFe autorizado.
	036 - Cancelamento autorizado fora do prazo.
*/

Function TME73Upd(cNrManif,cNrSerie,cSitMDF,cCodRet,cNrProt,nAmbien,cRecome,cMsgRet,nModalidade,dMDFEEmis)
	Local cSeek       := ''
	Local lMdfeCan    := SuperGetMv("MV_MDFECAN",,.F.) == .T.
	
	Default nModalidade := 0
	Default dMDFEEmis   := CtoD("")

	If !lCancela
		If !(Alltrim(cNrSerie) == '0')
			cSeek := xFilial('DTX')+cFilAnt+PadR(cNrManif, Len(DTX->DTX_MANIFE))+PadR(cNrSerie, Len(DTX->DTX_SERMAN))
		Else
			cSeek := xFilial('DTX')+cFilAnt+PadR(cNrManif, Len(DTX->DTX_MANIFE))
		EndIf
		DTX->(dbSetOrder(2))
		If	DTX->(MsSeek(cSeek))
			RecLock('DTX',.F.)
			//-- Status TOTVS Colaboracao 2.0.
			If lUsaColab
				If !Empty(cCodRet)
					//-- Mensagem retorno SEFAZ
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_RTIMDF := cRecome //Retorno Env SEFAZ
					ElseIf !DTX->DTX_IDFMDF $ '102/132'
						DTX->DTX_RTFMDF := cRecome //Retorno Enc SEFAZ
					EndIf
				ElseIf !Empty(cSitMDF)
					//-- Recomensacao
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_RTIMDF := cMsgRet //Retorno Env SEFAZ
					ElseIf !DTX->DTX_IDFMDF $ '102/132'
						DTX->DTX_RTFMDF := cMsgRet //Retorno Enc SEFAZ
					EndIf
				EndIf
				If !Empty(cCodRet) .And. cCodRet < '200'
					If lEnvia
						If !(cCodRet $ '002/003')
							If nModalidade == 1
								DTX->DTX_STIMDF := StrZero(2,Len(DTX->DTX_STIMDF))	//-- Autorizado o uso do MDFe
							Else
								DTX->DTX_STIMDF := StrZero(4,Len(DTX->DTX_STIMDF))	//-- Autorizado Contingencia
							EndIf
						Else
							If cCodRet = '002'
								DTX->DTX_STIMDF := StrZero(1,Len(DTX->DTX_STIMDF))	//-- Aguardando o processamento
							ElseIf cCodRet = '003'
								DTX->DTX_STIMDF := StrZero(3,Len(DTX->DTX_STIMDF))	//-- Nao Autorizado
							EndIf
						EndIf
					ElseIf cCodRet $ '102/132/013'
						If nModalidade == 1
							DTX->DTX_STFMDF := StrZero(2,Len(DTX->DTX_STFMDF))	//-- Autorizado o uso do MDFe
						ElseIf cCodRet $ '102/132'
							DTX->DTX_STFMDF := StrZero(4,Len(DTX->DTX_STFMDF))	//-- Autorizado Contingencia
						EndIf
					ElseIf cCodRet $ '011'
						DTX->DTX_STFMDF := StrZero(1,Len(DTX->DTX_STFMDF))	//-- Aguardando o processamento
					EndIf
				ElseIf cCodRet > '200'
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_STIMDF := StrZero(3,Len(DTX->DTX_STIMDF))		//-- Nao Autorizado
					ElseIf !DTX->DTX_IDFMDF $ '102/132''
						DTX->DTX_STFMDF := StrZero(3,Len(DTX->DTX_STFMDF))		//-- Nao Autorizado
					EndIf
				EndIf
			Else
				//-- TOTVS TSS
				If !Empty(cCodRet) .And. !(cCodRet $ '003/002/004/009/016/033')
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_RTIMDF := cMsgRet
					ElseIf !Empty(DTX->DTX_CODEVE) .And. DTX->DTX_IDFMDF <> '132'
						DTX->DTX_RTFMDF := cMsgRet
					EndIf
				Else
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_RTIMDF := cRecome
					ElseIf !Empty(DTX->DTX_CODEVE) .And. DTX->DTX_IDFMDF <> '132'
						DTX->DTX_RTFMDF := cRecome
					EndIf
				EndIf

				If cCodRet $ '002/016'
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_STIMDF := StrZero(0,Len(DTX->DTX_STIMDF))		//-- Nao Transmitido
					ElseIf !Empty(DTX->DTX_CODEVE) .And. DTX->DTX_IDFMDF <> '132'
						DTX->DTX_STFMDF := StrZero(0,Len(DTX->DTX_STFMDF))		//-- Nao Transmitido
					EndIf

				ElseIf cCodRet $ '003/004/009/033'
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_STIMDF := StrZero(1,Len(DTX->DTX_STIMDF))		//-- Aguardando.....
					ElseIf !Empty(DTX->DTX_CODEVE) .And. DTX->DTX_IDFMDF <> '132'
						DTX->DTX_STFMDF := StrZero(1,Len(DTX->DTX_STFMDF))		//-- Aguardando.....
					EndIf

				ElseIf cCodRet $ '001/015/035'
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_STIMDF := StrZero(2,Len(DTX->DTX_STIMDF))		//-- Autorizado o uso do MDFe
						cQuery := " UPDATE " + RetSqlName("DUP") + " SET DUP_STMDFE = '3' "
						cQuery += " WHERE DUP_FILIAL = '" + xFilial("DUP") + "'"
						cQuery += " AND DUP_VIAGEM = '" + DTX->DTX_VIAGEM + "' AND DUP_FILORI = '" + cFilAnt + "'"
						cQuery += " AND DUP_STMDFE <> '3'  AND D_E_L_E_T_ = ' ' "
						TCSqlExec( cQuery )
					ElseIf !Empty(DTX->DTX_CODEVE) .And. DTX->DTX_IDFMDF <> '132'
						DTX->DTX_STFMDF := StrZero(2,Len(DTX->DTX_STFMDF))		//-- Autorizado o uso do MDFe
					EndIf

				ElseIf cCodRet $ '005/010/011/012/013/014/017/034'
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_STIMDF := StrZero(3,Len(DTX->DTX_STIMDF))		//-- Nao Autorizado
					ElseIf !Empty(DTX->DTX_CODEVE) .And. DTX->DTX_IDFMDF <> '132'
						DTX->DTX_STFMDF := StrZero(3,Len(DTX->DTX_STFMDF))		//-- Nao Autorizado
					EndIf

				ElseIf cCodRet $ '007/008'
					If lEnvia .And. DTX->DTX_IDIMDF <> "100"
						DTX->DTX_STIMDF := StrZero(4,Len(DTX->DTX_STFMDF))		//-- Autorizado Contingencia
					ElseIf !Empty(DTX->DTX_CODEVE) .And. DTX->DTX_IDFMDF <> '132'
						DTX->DTX_STFMDF := StrZero(4,Len(DTX->DTX_STFMDF))		//-- Autorizado Contingencia
					EndIf
				EndIf
            EndIf

			If lEnvia .And. (DTX->DTX_IDIMDF <> "100") .Or. (Empty(DTX->DTX_PRIMDF) .And. DTX->DTX_IDIMDF = "100")
				DTX->DTX_IDIMDF := cSitMDF
				DTX->DTX_AMBIEN := nAmbien
				If !Empty(cNrProt)
					DTX->DTX_PRIMDF := cNrProt
				EndIf
				If cSitMDF == "100"  //Autorizado Envio
					DTX->DTX_STATUS := '2'  //Enviado
				EndIf
			ElseIf !Empty(DTX->DTX_CODEVE) .And. DTX->DTX_IDFMDF <> '132' .And. cSitMDF <> "100"
				If cSitMDF == '132' .And. cCodRet == '035'  //Autorizado Encerramento
					If !Empty(cNrProt)
						DTX->DTX_PRFMDF := cNrProt
					EndIf
					DTX->DTX_STATUS:= '3'  //Encerrado
					DTX->DTX_IDFMDF := cSitMDF
				ElseIf cSitMDF <> '132''
					DTX->DTX_IDFMDF := cSitMDF
				EndIf
			EndIf


			MsUnLock()
			//--Grava os eventos do MDFe - Autorizacao/Encerramento
			If ExistFunc("TmsAvbeM") .And. TableIndic("DLI")
				If cCodRet == "001" .Or. cCodRet == "035" //--Autorizacao ou encerramento
					TmsAvbeM(DTX->DTX_FILMAN, DTX->DTX_MANIFE, DTX->DTX_SERMAN, Iif(Empty(dMDFEEmis),DTX->DTX_DATMAN,dMDFEEmis), cCodRet)
				EndIf
			EndIf
		EndIf
	Else
		//---- Cancelamento
		If !(Alltrim(cNrSerie) == '0')
			DYN->(dbSetOrder(3))
			cSeek := xFilial('DYN')+cFilAnt+PadR(cNrManif, Len(DYN->DYN_MANIFE))+PadR(cNrSerie, Len(DYN->DYN_SERMAN))
		Else
			DYN->(dbSetOrder(1))
			cSeek := xFilial('DYN')+cFilAnt+PadR(cNrManif, Len(DYN->DYN_MANIFE))
		EndIf
		If DYN->(MsSeek(cSeek))
			RecLock('DYN',.F.)
			//-- Status TOTVS Colaboracao 2.0.
			If lUsaColab
				If !Empty(cCodRet)
					DYN->DYN_RTCMDF := cRecome
				ElseIf !Empty(cSitMDF)
					DYN->DYN_RTCMDF := cMsgRet
				EndIf
				If cCodRet < '200'
					If nModalidade == 1
						DYN->DYN_STCMDF := StrZero(2,Len(DYN->DYN_STCMDF))	//-- Autorizado o uso do MDFe
					Else
						DYN->DYN_STCMDF := StrZero(4,Len(DYN->DYN_STCMDF))	//-- Autorizado Contingencia
					EndIf
				ElseIf cCodRet > '200' .And. DYN->DYN_IDCMDF <> '101'
					DYN->DYN_STCMDF := StrZero(3,Len(DYN->DYN_STCMDF))		//-- Nao Autorizado
				EndIf
				If cCodRet == '100'
					DYN->DYN_STATUS := '2'	//--Enviado
				ElseIf cCodRet $ '132|135'
					DYN->DYN_IDCMDF := cSitMDF
					DYN->DYN_PRCMDF := cNrProt
				EndIf
				//-- TOTVS TSS
			Else
				If !Empty(cCodRet) .And. !(cCodRet $ '003/002/004/009/016/033')
					If !Empty(DYN->DYN_CODEVE) .And. DYN->DYN_IDCMDF <> '101' .And. cSitMDF <> '100'
						DYN->DYN_RTCMDF := cMsgRet
					EndIf
				Else
					If !Empty(DYN->DYN_CODEVE) .And. DYN->DYN_IDCMDF <> '101' .And. cSitMDF <> '100'
						DYN->DYN_RTCMDF := cRecome
					EndIf
				EndIf

				If cCodRet $ '002/016/033'
					If !Empty(DYN->DYN_CODEVE) .And. DYN->DYN_IDCMDF <> '101'
						DYN->DYN_STCMDF := StrZero(0,Len(DYN->DYN_STCMDF))		//-- Nao Transmitido
					EndIf

				ElseIf cCodRet $ '003/004/009/025'
					If !Empty(DYN->DYN_CODEVE) .And. DYN->DYN_IDCMDF <> '101'
						DYN->DYN_STCMDF := StrZero(1,Len(DYN->DYN_STCMDF))		//-- Aguardando.....
					EndIf

				ElseIf cCodRet $ '001/015/035'
					If !Empty(DYN->DYN_CODEVE) .And. DYN->DYN_IDCMDF <> '101'
						DYN->DYN_STCMDF := StrZero(2,Len(DYN->DYN_STCMDF))		//-- Autorizado o uso do MDFe
					EndIf

				ElseIf cCodRet $ '005/010/011/012/013/014/017/034'
					If !Empty(DYN->DYN_CODEVE) .And. DYN->DYN_IDCMDF <> '101'
						DYN->DYN_STCMDF := StrZero(3,Len(DYN->DYN_STCMDF))		//-- Nao Autorizado
					EndIf

				ElseIf cCodRet $ '007/008'
					If !Empty(DYN->DYN_CODEVE) .And. DYN->DYN_IDCMDF <> '101'
						DYN->DYN_STCMDF := StrZero(4,Len(DYN->DYN_STCMDF))		//-- Autorizado Contingencia
					EndIf
				EndIf
			EndIf

			If !Empty(DYN->DYN_CODEVE) .And. DYN->DYN_IDCMDF <> '101' .And. !Empty(cSitMDF) .And. cSitMDF <> '100'
				If cSitMDF == '101' .And. cCodRet $ '001/015/035'  //Autorizado Encerramento
					If !Empty(cNrProt)
						DYN->DYN_PRCMDF := cNrProt
					EndIf
					DYN->DYN_IDCMDF := cSitMDF
				ElseIf cSitMDF <> '101''
					DYN->DYN_IDCMDF := cSitMDF
				EndIf
			EndIf
			MsUnLock()
			//--Grava os eventos do MDFe - Cancelamento
			If ExistFunc("AvbGrvMdf") .And. TableIndic("DLI")
				If DYN->DYN_STCMDF == "2" //--Autorizado o cancelamento
					TmsAvbeM(DYN->DYN_FILMAN, DYN->DYN_MANIFE, DYN->DYN_SERMAN, DYN->DYN_DATMAN, cCodRet)
				EndIf
			EndIf
			If DYN->DYN_STCMDF == "2" .And. lMdfeCan //--Autorizado o cancelamento
				If (DYN->DYN_MANIFE <> DTX->DTX_MANIFE)
					//Necessário posicionar a DTX em casos específicos durante a utilização do parâmetro MV_MDFCAN, a tabela DTX fica desposicionada em relação a tabela DYN
					DTX->(dbSetOrder(2)) //DTX_FILIAL+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN                                                                                                                     
					DTX->(DbSeek(xFilial('DTX')+DYN->DYN_FILMAN+DYN->DYN_MANIFE+DYN->DYN_SERMAN))
				EndIf
				Processa({|| TmsA190Proc(.T., DTX->DTX_FILORI, DTX->DTX_VIAGEM, STR0115  )}, STR0116)   //"Excluindo Manifesto. Por favor aguarde..."
			EndIf
		EndIf
	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TME73Par    ³ Autor ³ Katia               ³ Data ³10.05.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que parametriza o Protheus para o MDFe               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TME73Par()

	Local oWs
	Local aPerg1    := {}
	Local aParam    := {"","","","",""}

	Local aCombo1   := {} //Ambiente
	Local aCombo2   := {} //Versao do leiaute
	Local aCombo3   := {} //Versao do leiaute do evento
	Local aCombo4   := {} //Versão do Manifesto
	Local aCombo5   := {} //Modalidade
	Local aCombo6   := {} //Horario de Verao
	Local aCombo7   := {} //UTC

	Local cCombo1   := ""
	Local cCombo2   := "" //"1"
	Local cCombo3   := "1.00"
	Local cCombo4   := "1.00"
	Local cCombo5   := "1.00"
	Local cCombo6   := ""
	Local cCombo7   := ""

	Local cIdEnt     := ""
	Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cParMANPar := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDMANPAR"
	Local cModel     := "58"
	Local lAdminNfe  := GetNewPar("MV_ADMNFE",.T.)
	Local lUsaColab  := UsaColaboracao("5")

// Ambiente
	aadd(aCombo1,STR0048) //"1-Producao"
	aadd(aCombo1,STR0049) //"2-Homologacao"

// Modalidade do Manifesto
	aadd(aCombo2,STR0053) //"1-Normal"
	aadd(aCombo2,STR0054) //"2-Contingência"

// Versao do leiaute
	aadd(aCombo3,"1.00")
	aadd(aCombo3,"3.00")

// Versao do leiaute do evento
	aadd(aCombo4,"1.00")
	aadd(aCombo4,"3.00")

// Versao da Manifesto
	aadd(aCombo5,"1.00")
	aadd(aCombo5,"3.00")

	// Horario de verao
	AADD(aCombo6,STR0092)
	AADD(aCombo6,STR0093)

	// Horario UTC
	AADD(aCombo7,STR0094)
	AADD(aCombo7,STR0095)
	AADD(aCombo7,STR0096)
	AADD(aCombo7,STR0097)

If lUsaColab
	//REALIZA A CONFIGURAÇÃO DOS PARAMETRO DO TOTVS COLABORAÇÃO 3.0
	If ( lAdminNfe .And. PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0 ) .Or. !lAdminNfe
		ColParametros( "MDF" )
	Else
		Help( "", 1, "SEMPERM" )
	EndIf
Else
	If lAdminNfe
		If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0
			If CTIsReady()

			// Obtem o codigo da entidade
				cIdEnt := RetIdEnti(lUsaColab)

			// Obtem o ambiente de configuracao
				oWS :=  WsSpedCfgNFe():New()
				oWS:cUSERTOKEN      := "TOTVS"
				oWS:cID_ENT         := cIdEnt
				oWS:nAmbienteMDFE   := 0
				oWS:cVersaoMDFE     := "0.00"
				oWS:nModalidadeMDFE := 0
				oWS:cVERMDFELAYOUT  := "0.00"
				oWS:cVERMDFELAYEVEN := "0.00"
				oWS:nSEQLOTEMDFE    := 0
				oWS:cHORAVERAOMDFE  := '0'
				oWS:cHORARIOMDFE    := '0'
				oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				oWS:cModelo         := cModel
				lOk:= oWS:CFGMDFE()

				If lOk

					If Valtype(oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE) <> "U"
						cCombo1 := oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
					Else
						cCombo1 := STR0049	//"2-Homologacao"
					EndIf
				// Modalidade
					If ValType(oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE) <> "U"
						cCombo2	:= oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE
					Else
						cCombo2 := "1"
					EndIF
				// Versao do leiaute
					If ValType(oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT) <> "U"
						cCombo3	:= oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT
					Else
						cCombo3 := "1.00"
					EndIf
				// Versao do leiaute do evento
					If ValType(oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN) <> "U"
						cCombo4 := oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN
					Else
						cCombo4 := "1.00"
					EndIf
				// Versao do Manifesto
					If ValType(oWS:OWSCFGMDFERESULT:CVERSAOMDFE) <> "U"
						cCombo5 := oWS:OWSCFGMDFERESULT:CVERSAOMDFE
					Else
						cCombo5 := "1.00"
					EndIf

					// Horario de verao
					If ValType(oWS:OWSCFGMDFERESULT:cHORAVERAOMDFE) <> "U"
						cCombo6 := oWS:OWSCFGMDFERESULT:cHORAVERAOMDFE
					EndIf

					// UTC
					If ValType(oWS:OWSCFGMDFERESULT:cHORARIOMDFE) <> "U"
						cCombo7 := oWS:OWSCFGMDFERESULT:cHORARIOMDFE
					EndIf

				EndIf

				AADD(aPerg1,{2,STR0055,cCombo1,aCombo1,120,".T.",.T.,".T."}) //"Ambiente"
				AADD(aPerg1,{2,STR0056,cCombo2,aCombo2,120,".T.",.T.,".T."}) //"Modalidade
				AADD(aPerg1,{2,STR0050,cCombo3,aCombo3,120,".T.",.T.,".T."}) //"Versao do leiaute"
				AADD(aPerg1,{2,STR0051,cCombo4,aCombo4,120,".T.",.T.,".T."}) //"Versao do leiaute do evento"
				AADD(aPerg1,{2,STR0089,cCombo5,aCombo5,120,".T.",.T.,".T."}) //"Versao da manisfestacao"
				AADD(aPerg1,{2,STR0090,cCombo6,aCombo6,120,".T.",.T.,".T."}) //"Horario de Verao (1/2)"
				AADD(aPerg1,{2,STR0091,cCombo7,aCombo7,120,".T.",.T.,".T."}) //"Horario de Verao (1/2)"

				aParam := {cCombo1,cCombo2,cCombo3,cCombo4,cCombo5, cCombo6, cCombo7}

				If ParamBox(aPerg1,"Eventos",aParam,,,,,,,cParMANPar,.T.,.F.)

					oWS :=  WsSpedCfgNFe():New()
					oWS:cUSERTOKEN      := "TOTVS"
					oWS:cID_ENT         := cIdEnt
					oWS:nAmbienteMDFE   := Val(Substr(aParam[1],1,1))
					oWS:cVersaoMDFE     := aParam[5]
					oWS:nModalidadeMDFE := Val(aParam[2])
					oWS:cVERMDFELAYOUT  := aParam[3]
					oWS:cVERMDFELAYEVEN := aParam[4]
					oWS:nSEQLOTEMDFE    := 0
					oWS:cHORAVERAOMDFE  := Substr(aParam[6],1,1)
					oWS:cHORARIOMDFE    := Substr(aParam[7],1,1)
					oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
					oWS:cModelo         := cModel
					lOk:= oWS:CFGMDFE()

					If lOk
						Aviso("Eventos",STR0046,{STR0036},3)	//"Configuração efetuada com sucesso"
					Else
						Aviso("Eventos",STR0047,{STR0036},3)	//"Houve um erro durante a configuracão"
					EndIf
				EndIf

			Else
				Aviso("SPED",STR0057,{STR0036},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
			EndIf
		Else
			Help( "", 1, "SEMPERM" )
		EndIf
	Else
		If CTIsReady()

			// Obtem o codigo da entidade
				cIdEnt := RetIdEnti(lUsaColab)

			// Obtem o ambiente de configuracao
				oWS :=  WsSpedCfgNFe():New()
				oWS:cUSERTOKEN      := "TOTVS"
				oWS:cID_ENT         := cIdEnt
				oWS:nAmbienteMDFE   := 0
				oWS:cVersaoMDFE     := "0.00"
				oWS:nModalidadeMDFE := 0
				oWS:cVERMDFELAYOUT  := "0.00"
				oWS:cVERMDFELAYEVEN := "0.00"
				oWS:nSEQLOTEMDFE    := 0
				oWS:cHORAVERAOMDFE  := '0'
				oWS:cHORARIOMDFE    := '0'
				oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
				oWS:cModelo         := cModel
				lOk:= oWS:CFGMDFE()

				If lOk

					If Valtype(oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE) <> "U"
						cCombo1 := oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
					Else
						cCombo1 := STR0049	//"2-Homologacao"
					EndIf
				// Modalidade
					If ValType(oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE) <> "U"
						cCombo2	:= oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE
					Else
						cCombo2 := "1"
					EndIF
				// Versao do leiaute
					If ValType(oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT) <> "U"
						cCombo3	:= oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT
					Else
						cCombo3 := "1.00"
					EndIf
				// Versao do leiaute do evento
					If ValType(oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN) <> "U"
						cCombo4 := oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN
					Else
						cCombo4 := "1.00"
					EndIf
				// Versao do Manifesto
					If ValType(oWS:OWSCFGMDFERESULT:CVERSAOMDFE) <> "U"
						cCombo5 := oWS:OWSCFGMDFERESULT:CVERSAOMDFE
					Else
						cCombo5 := "1.00"
					EndIf

					// Horario de verao
					If ValType(oWS:OWSCFGMDFERESULT:cHORAVERAOMDFE) <> "U"
						cCombo6 := oWS:OWSCFGMDFERESULT:cHORAVERAOMDFE
					EndIf

					// UTC
					If ValType(oWS:OWSCFGMDFERESULT:cHORARIOMDFE) <> "U"
						cCombo7 := oWS:OWSCFGMDFERESULT:cHORARIOMDFE
					EndIf
				EndIf

				AADD(aPerg1,{2,STR0055,cCombo1,aCombo1,120,".T.",.T.,".T."}) //"Ambiente"
				AADD(aPerg1,{2,STR0056,cCombo2,aCombo2,120,".T.",.T.,".T."}) //"Modalidade
				AADD(aPerg1,{2,STR0050,cCombo3,aCombo3,120,".T.",.T.,".T."}) //"Versao do leiaute"
				AADD(aPerg1,{2,STR0051,cCombo4,aCombo4,120,".T.",.T.,".T."}) //"Versao do leiaute do evento"
				AADD(aPerg1,{2,STR0089,cCombo5,aCombo5,120,".T.",.T.,".T."}) //"Versao da manisfestacao"
				AADD(aPerg1,{2,STR0090,cCombo6,aCombo6,120,".T.",.T.,".T."}) //"Horario de Verao (1/2)"
				AADD(aPerg1,{2,STR0091,cCombo7,aCombo7,120,".T.",.T.,".T."}) //"Horario de Verao (1/2)"

				aParam := {cCombo1,cCombo2,cCombo3,cCombo4,cCombo5, cCombo6, cCombo7}

				If ParamBox(aPerg1,"Eventos",aParam,,,,,,,cParMANPar,.T.,.F.)

					oWS :=  WsSpedCfgNFe():New()
					oWS:cUSERTOKEN      := "TOTVS"
					oWS:cID_ENT         := cIdEnt
					oWS:nAmbienteMDFE   := Val(Substr(aParam[1],1,1))
					oWS:cVersaoMDFE     := aParam[5]
					oWS:nModalidadeMDFE := Val(aParam[2])
					oWS:cVERMDFELAYOUT  := aParam[3]
					oWS:cVERMDFELAYEVEN := aParam[4]
					oWS:nSEQLOTEMDFE    := 0
					oWS:cHORAVERAOMDFE  := Substr(aParam[6],1,1)
					oWS:cHORARIOMDFE    := Substr(aParam[7],1,1)
					oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
					oWS:cModelo         := cModel
					lOk:= oWS:CFGMDFE()

					If lOk
						Aviso("Eventos",STR0046,{STR0036},3)	//"Configuração efetuada com sucesso"
					Else
						Aviso("Eventos",STR0047,{STR0036},3)	//"Houve um erro durante a configuracão"
					EndIf
				EndIf

		Else
			Aviso("SPED",STR0057,{STR0036},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TME73MtEve  ³ Autor ³ Katia               ³ Data ³10.05.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monitor do Evento de Cancelamento e Encerramento do MDF-e   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TME73MtEve(cSerie,cManIni,cManFin,cTipoEve,cModelo)

	Local aPerg1	:= {}
	Local aListBox	:= {}
	Local aParam	:= {Space(3),Space(09),Space(09),Space(01)}
	Local aSize		:= MsAdvSize()
	Local aObjects	:= {}
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local aArea		:= GetArea()
	Local cParManif	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"MonitManif"
	Local cWhere	:= ""
	Local cAliasTemp:= GetNextAlias()
	Local cChvIni	:= ""
	Local cChvFin	:= ""
	Local cCodEve	:= ""
		
	Local oDlg
	Local oListBox
	Local oBtn1
	Local oBtn2
	Local oBtn3
	Local oBtn4

	Default cSerie := ""
	Default cManIni:= ""
	Default cManFin:= ""
	Default cTipoEve:= ""     //Encerramento ou Cancelamento
	Default cModelo:= "58"

	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParManif,aPerg1,1,aParam[01]),Len(DT6->DT6_SERIE))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParManif,aPerg1,2,aParam[02]),Len(DTX->DTX_MANIFE))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParManif,aPerg1,3,aParam[03]),Len(DTX->DTX_MANIFE))

	aadd(aPerg1,{1,STR0058,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
	aadd(aPerg1,{1,STR0059,aParam[02],"",,"",".T.",30,.F.})	//"Documento Inicial"
	aadd(aPerg1,{1,STR0060,aParam[03],"",,"",".T.",30,.F.}) 	//"Documento Final"

	cCodEve:= cTipoEve

	If RetRdTSS()
		If ParamBox(aPerg1,"Monitor Manifesto",aParam,,,,,,,cParManif,.T.,.T.)

			If cTipoEve <> '110111'
				If Alltrim(MV_PAR01) <> '0'
					cWhere += "%DTX_FILIAL='"+xFilial("DTX")+"' AND DTX_FILMAN = '"+cFilAnt+"' AND DTX_MANIFE BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND DTX_SERMAN = '"+MV_PAR01+"' AND DTX_TIPMAN = '2'%"
				Else
					cWhere += "%DTX_FILIAL='"+xFilial("DTX")+"' AND DTX_FILMAN = '"+cFilAnt+"' AND DTX_MANIFE BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND DTX_TIPMAN = '2'%"
				EndIf
				BeginSql Alias cAliasTemp
					SELECT	MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
					FROM %Table:DTX%
					WHERE %Exp:cWhere% AND
					%notdel%
				EndSql

				(cAliasTemp)->(dbGotop())

				If (cAliasTemp)->(Eof())
					MsgInfo(STR0061)//"Nenhum registro à monitorar "
				Return nil
				EndIf

				DTX->(dbGoTo((cAliasTemp)->RECINI))
				cChvIni := DTX->DTX_CHVMDF
				DTX->(dbGoTo((cAliasTemp)->RECFIN))
				cChvFin := DTX->DTX_CHVMDF
			Else
				If Alltrim(MV_PAR01) <> '0'
					cWhere += "%DYN_FILIAL='"+xFilial("DYN")+"' AND DYN_FILMAN = '"+cFilAnt+"' AND DYN_MANIFE BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND DYN_SERMAN = '"+MV_PAR01+"'%"
				Else
					cWhere += "%DYN_FILIAL='"+xFilial("DYN")+"' AND DYN_FILMAN = '"+cFilAnt+"' AND DYN_MANIFE BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'%"
				EndIf
				BeginSql Alias cAliasTemp
					SELECT	MIN(DYN_CHVMDF) AS RECINI, MAX(DYN_CHVMDF) AS RECFIN
					FROM %Table:DYN%
					WHERE %Exp:cWhere% AND
					%notdel%
				EndSql

				(cAliasTemp)->(dbGotop())

				If (cAliasTemp)->(Eof())
					MsgInfo(STR0061)//"Nenhum registro à monitorar "
				Return nil
				EndIf

				cChvIni := (cAliasTemp)->RECINI
				cChvFin := (cAliasTemp)->RECFIN
			EndIf
			cSerie := mv_par01
			cManIni:= mv_par02
			cManFin:= mv_par03

			(cAliasTemp)->(dbCloseArea())
			RestArea(aArea)

			aListBox:= RetMonEven(cChvIni,cChvFin,cCodEve,cModelo,lUsaColab)

			If !Empty(aListBox)
				AAdd( aObjects, { 100, 100, .t., .t. } )
				AAdd( aObjects, { 100, 015, .t., .f. } )
				aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
				aPosObj := MsObjSize( aInfo, aObjects )

				DEFINE FONT oBold BOLD
				DEFINE MSDIALOG oDlg TITLE "Monitoramento da Manifestação" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

				@aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox 	FIELDS HEADER "","Protocolo","ID","Ambiente","Mensagem" ;
					SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
				oListBox:SetArray(aListBox)
				oListBox:bLine:={||	{	aListBox[oListBox:nAt][01],;
					Alltrim(aListBox[oListBox:nAt][02]),;
					Alltrim(aListBox[oListBox:nAt][03]),;
					Alltrim(aListBox[oListBox:nAt][04]),;
					Alltrim(aListBox[oListBox:nAt][06])}}

				@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn1 PROMPT STR0019		ACTION (aListBox := RetMonEven(cChvIni,cChvFin,cCodEve,cModelo,lUsaColab),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
				@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn2 PROMPT STR0021	ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"Sair"
				@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT STR0012	ACTION RetLegMon(cModelo) OF oDlg PIXEL SIZE 035,011 //"Legenda"
				@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT "Vis. XML"	ACTION RetVisuXml(Alltrim(aListBox[oListBox:nAt][03])) OF oDlg PIXEL SIZE 035,011

				ACTIVATE MSDIALOG oDLg CENTERED
			EndIf
		EndIf
	Else
		Aviso("SPED",STR0038,{STR0036},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS73PrEnv³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Processamento do Envio dos Doctos para o TSS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Array contendo os doc. da tela.                  ³±±
±±³          ³lExp1    - Controle para interromper o processamento        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS73PrEnv(aDoctosTra, oSay)

Local cDocIni  := ''
Local cDocFin  := ''
Local cSerie   := ''
Local nI       := 0
Local nTotMDFe := 0

Private cPChvCtg   := ""  //-- private para resgatar a chave de contingencia

Default aDoctosTra := {}

nTotMDFe := Len(aDoctosTra)

If lUsaColab
	oDoc := ColaboracaoDocumentos():new()
	oDoc:cModelo 	:= "MDF"
	oDoc:cTipoMov	:= "1"
EndIf

For nI := 1 To nTotMDFe

	cDocIni := aDoctosTra[nI,2]
	cDocFin := aDoctosTra[nI,3]
	cSerie  := aDoctosTra[nI,4]
	
	//-- Funcao responsavel por enviar os Doc. para o TSS.
	TME73Sped(cSerie, cDocIni, cDocFin, lUsaColab, aDoctosTra)
Next nI

nQtdMrk:= 0

Return( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73CONSE  ³ Autor ³Felipe Barbieri      ³ Data ³13.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçao ³Rotina para consultar MDF-e não encerrados   				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73CONSE()
Local oDlg
Local oListBox
Local oRetorno
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local nAT			:= 0
Local cQuery		:= ""
Local aListBox  	:= {}
Local cAliasQry 	:= GetNextAlias()
Local lUsaColab	:= UsaColaboracao("5")
Local aCabec		:= {}
Local lOK  		:= .F.

aAdd(aCabec,STR0118) // FiL. Origem
aAdd(aCabec,STR0119) // Viagem
aAdd(aCabec,STR0120) // Data Viagem
aAdd(aCabec,STR0121) // Manifesto
aAdd(aCabec,STR0122) // Dt Manifesto
aAdd(aCabec,STR0123) // St Viagem
aAdd(aCabec,STR0124) // Placa
aAdd(aCabec,STR0125) //Chave de Acesso
aAdd(aCabec,STR0126) // Protocolo

If CTIsReady(,,,lUsaColab)
	If lUsaColab
		TM73CONSEC()
	Else
		DTX->( DbSetOrder( 1 ) )

		// Obtem o codigo da entidade
		cIdEnt := RetIdEnti(lUsaColab)

		oWS :=  WsSpedCfgNFe():New()
		oWS:cUSERTOKEN      := "TOTVS"
		oWS:cID_ENT         := cIdEnt
		oWS:nAmbienteMDFE   := 0
		oWS:cVersaoMDFE     := "0.00"
		oWS:nModalidadeMDFE := 1
		oWS:cVERMDFELAYOUT  := "0.00"
		oWS:cVERMDFELAYEVEN := "0.00"
		oWS:nSEQLOTEMDFE    := 0
		oWS:cHORAVERAOMDFE  := '0'
		oWS:cHORARIOMDFE    := '0'
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		lOk:= oWS:CFGMDFE()

		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN   	:= "TOTVS"
		oWS:cID_ENT      	:= cIdEnt
		oWS:_URL         	:= AllTrim(cURL)+"/NFeSBRA.apw"

		MsgRun(STR0069,STR0070,{||lOK := oWS:CONSULTAMDFEENC()})
		oRetorno 	:= oWS:oWsCONSULTAMDFEENCRESULT

		If lOk .And. Len(oRetorno:OWSINFMDFE:OWSINFMDFES) > 0
			For nAT := 1 to Len(oRetorno:OWSINFMDFE:OWSINFMDFES)
				cQuery := " SELECT DTX.DTX_VIAGEM, DTX.DTX_FILMAN, DTX.DTX_MANIFE, DTX.DTX_DATMAN, DTQ.DTQ_FILORI, DTQ.DTQ_DATGER, DA3.DA3_PLACA, "
				cQuery += " CASE DTQ.DTQ_STATUS WHEN '1' THEN 'Em aberto'"
				cQuery += " WHEN '2' THEN 'Em trânsito' "
				cQuery += " WHEN '3' THEN 'Encerrada' "
				cQuery += " WHEN '4' THEN 'Chegada em Filial' "
				cQuery += " WHEN '5' THEN 'Fechada' "
				cQuery += " WHEN '9' THEN 'Cancelada' "
				cQuery += " ELSE 'Sem Status' END as DTQ_STATUS "
				cQuery += " FROM " + RetSqlName("DTX") + " DTX "
				cQuery += " INNER JOIN " + RetSqlName("DTQ") + " DTQ ON "
				cQuery += " DTQ_FILIAL = '"+ FWxFilial("DTQ") +"'"
				cQuery += " AND DTQ_VIAGEM = DTX.DTX_VIAGEM "
				cQuery += " INNER JOIN " + RetSqlName("DA3") + " DA3 ON "
				cQuery += " DA3_FILIAL = '"+ FWxFilial("DA3") + "'"
				cQuery += " AND DTX.DTX_CODVEI = DA3.DA3_COD "
				cQuery += " WHERE DTX.DTX_CHVMDF = '" + AllTrim(oRetorno:OWSINFMDFE:OWSINFMDFES[nAT]:CCHVMDFE) + "' "
				cQuery += " AND DTX.D_E_L_E_T_  = ' ' AND DTQ.D_E_L_E_T_  = ' ' AND DA3.D_E_L_E_T_  = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

				If !Empty((cAliasQry)->DTQ_FILORI)
					Aadd(aListBox, Array(9))
					aListBox[Len(aListBox),1] := (cAliasQry)->DTQ_FILORI
					aListBox[Len(aListBox),2] := (cAliasQry)->DTX_VIAGEM
					aListBox[Len(aListBox),3] := Stod((cAliasQry)->DTQ_DATGER)
					aListBox[Len(aListBox),4] := (cAliasQry)->DTX_MANIFE
					aListBox[Len(aListBox),5] := Stod((cAliasQry)->DTX_DATMAN)
					aListBox[Len(aListBox),6] := (cAliasQry)->DTQ_STATUS
					aListBox[Len(aListBox),7] := (cAliasQry)->DA3_PLACA
					aListBox[Len(aListBox),8] := oRetorno:OWSINFMDFE:OWSINFMDFES[nAT]:CCHVMDFE
					aListBox[Len(aListBox),9] := AllTrim(Str(oRetorno:OWSINFMDFE:OWSINFMDFES[nAT]:NPROTOCOLO))
				Else
					Aadd(aListBox, Array(9))
					aListBox[Len(aListBox),8] := oRetorno:OWSINFMDFE:OWSINFMDFES[nAT]:CCHVMDFE
					aListBox[Len(aListBox),9] := AllTrim(Str(oRetorno:OWSINFMDFE:OWSINFMDFES[nAT]:NPROTOCOLO))
				EndIf
				(cAliasQry)->( DbCloseArea() )
			Next

			DEFINE MSDIALOG oDlg TITLE STR0068 From 10,10 TO 450,1012 OF oMainWnd PIXEL

			@010,010 LISTBOX oListBox FIELDS HEADER aCabec[1], aCabec[2], aCabec[3], aCabec[4], aCabec[5], aCabec[6], aCabec[7], aCabec[8], aCabec[9] SIZE 480,190 PIXEL OF oDlg

			oListBox:SetArray(aListBox)
			oListBox:bLine:={|| {aListBox[oListBox:nAt][01],;
									aListBox[oListBox:nAt][02],;
									aListBox[oListBox:nAt][03],;
									aListBox[oListBox:nAt][04],;
									aListBox[oListBox:nAt][05],;
									aListBox[oListBox:nAt][06],;
									aListBox[oListBox:nAt][07],;
									aListBox[oListBox:nAt][08],;
									aListBox[oListBox:nAt][09]}}

			@ 205,400 BUTTON oBtn1 PROMPT STR0067 ACTION TME73EXCEL(aCabec, aListBox) OF oDlg PIXEL SIZE 045,011 //"Exportar Excel"
			@ 205,455 BUTTON oBtn2 PROMPT STR0066 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"Sair"

			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			Aviso("SPED", AllTrim(oRetorno:CXMOTIVO),{STR0066},3)	//Motivo do Retorno
		EndIf
	EndIf
Else
   Aviso("SPED",STR0057,{STR0066},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!"
EndIf

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73EXCEL  ³ Autor ³Felipe Barbieri      ³ Data ³13.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçao ³Rotina para exportar dados da consulta para o Excel		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73EXCEL(aCabec, aDados)
Local oExcel := FWMSEXCEL():New()
Local nY := 0
Local cPath		:= AllTrim(GetTempPath())
Local oExcelApp 	:= Nil
Local cArquivo  	:= "MDFe_ENC_" + FsDateConv(dDataBase,"YYYYMMDD") + ".XML"

oExcel:AddworkSheet("MDF-e")
oExcel:AddTable ("MDF-e","MDF-e não encerrados")
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[1],1,1)
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[2],1,1)
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[3],1,1)
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[4],1,1)
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[5],1,1)
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[6],1,1)
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[7],1,1)
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[8],1,1)
oExcel:AddColumn("MDF-e","MDF-e não encerrados",aCabec[9],1,1)

	For ny := 1 to Len(aDados)
		oExcel:AddRow("MDF-e","MDF-e não encerrados",{aDados[nY][1], aDados[nY][2], aDados[nY][3], aDados[nY][4], aDados[nY][5], aDados[nY][6], aDados[nY][7], aDados[nY][8], aDados[nY][9]})
	Next

	oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArquivo)

	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath + cArquivo)
	oExcelApp:SetVisible(.T.)
Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73EXCEL  ³ Autor ³Felipe Barbieri      ³ Data ³13.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçao ³Rotina para exportar dados da consulta para o Excel		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS73UPENC(cViagem, cFilOri, cMot, cChave, i)
Local cQuery := ""
Local lOk := .F.
Local oWS
Local cIdent := ""
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cSeqEven	:= "01"

If CTIsReady(,,,lUsaColab)
	cIdEnt := RetIdEnti(lUsaColab)

	// Executa o metodo NfeRetornaEvento()
	oWS:= WSNFeSBRA():New()
	oWS	:cUSERTOKEN	:= "TOTVS"
	oWS:cID_ENT		:= cIdEnt
	oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:cCHVNFE		:= cChave
	lOk:=oWS:NFERETORNASEQEVENTO()

	If lOk
		cSeqEven := StrZero((oWs:nNfeRetornaSeqEventoResult + (i-1)),2)
	Endif

	cQuery := " UPDATE " + RetSqlName("DUP") + " SET DUP_STMDFE = '1', DUP_SEQEVE = '" + cSeqEven + "' "
	cQuery += " WHERE DUP_FILIAL = '" + xFilial("DUP") + "'"
	cQuery += " AND DUP_VIAGEM = '" + cViagem + "' AND DUP_FILORI = '" + cFilOri + "'"
	cQuery += " AND DUP_STMDFE <> '3' AND DUP_SEQEVE = ' ' AND DUP_CODMOT =  '" + cMot + "' AND D_E_L_E_T_ = ' ' "
	TCSqlExec( cQuery )
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMS73Vis³  Autor ³ Rafael Souza          ³ Data ³22.07.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza manifesto no monitor                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS73Vis()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE73                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMS73Vis(aListBox)

Local aArea := {}

If aListBox[oListBox:nAt,CTDTXREC] > 0
	aArea := GetArea()
	dbSelectArea('DTX')
	dbGoTo(aListBox[oListBox:nAt,CTDTXREC])
	TmsA190Mnt('DTX',DTX->(Recno()),2)
	RestArea(aArea)
	oListBox:SetFocus()
EndIf

Return
Static Function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TM73CONSEC  ³ Autor³Fabio Marchiori Sampaio Data ³28.07.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçao ³Rotina para consulta MDFe nao encerrados via TOTVS COlob 2.0³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TM73CONSEC()

local cXml			:= ""
local cDirOut		:= AllTrim(GetNewPar("MV_NGOUT",""))
local nHandle		:= 0
local cName		:= ""
local cNomeArq 	:=  Alltrim( "530" + "_"	) + FWTimeStamp() + StrZero( Randomize(0,999),3 ) + "_0001.xml"
local cBarra		:= If(isSrvUnix(),"/","\")
local cMsg			:= ""

	cName := cDirOut+cBarra+cNomeArq
	cXml := XmlMdfEnc()

	nHandle := FCreate(cName)

	if nHandle < 0
		cMsg := Alltrim( Str(Ferror()) )
		MsgAlert(cMsg)
	else
		FWrite( nHandle, cXml )
		FClose(nHandle)
	endif

	MsgRun(STR0069,STR0070,{||If((Empty(MV_PAR01TM) .or. MV_PAR01TM <= 0), Sleep(30000), Nil)})
	XmlMdfRet(cNomeArq)

return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³XmlMdfEnc  ³ Autor³Fabio Marchiori Sampaio Data ³28.07.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçao ³Rotina para Xml do   MDFe nao encerrados via TOTVS COlob 2.0³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function XmlMdfEnc()

local cXmlDados	:= ""
local cAmbiente  	:= ""
local cModalidade	:= ""
local cVerLayout 	:= ""
local cVerLayEven	:= ""
local cVersaoMDFE	:= ""


	cAmbiente   := ColGetPar("MV_AMBMDF","")
	cModalidade := ColGetPar("MV_MODMDF","")
	cVerLayout  := ColGetPar("MV_VLAYMDF","")
	cVerLayEven := ColGetPar("MV_EVENMDF","")
	cVersaoMDFE := ColGetPar("MV_VERMDF","")

cXmlDados += '<consMDFeNaoEnc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="'+cVersaoMDFE+'">'
cXmlDados += 	'<tpAmb>'+cAmbiente+'</tpAmb>'
cXmlDados += 	'<xServ>CONSULTAR N&#195;O ENCERRADOS</xServ>'
cXmlDados += 	'<CNPJ>'+AllTrim(SM0->M0_CGC)+'</CNPJ>'
cXmlDados += '</consMDFeNaoEnc>'

return cXmlDados

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³XmlMdfRet  ³ Autor³Fabio Marchiori Sampaio Data ³28.07.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçao³Retorno do Xml com os MDFe nao encerrados via TOTVS Colob 2.0³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function XmlMdfRet(cNomeArq)

local oColab		:= NIL
local cXml			:= ''
local oXml			:= NIL
local cErro		:= ''
local aDados		:= {}
local cAviso		:= ''
local aCabec		:= {}
local nAT			:= 0
Local cQuery		:= ""
local aListBox  	:= {}
local cAliasQry 	:= GetNextAlias()
local lOk			:= .T.
local oXmlEnc 	:= NIL

	aAdd(aCabec,"Fl. Orig.")
	aAdd(aCabec,"Viagem")
	aAdd(aCabec,"Dt. Viagem")
	aAdd(aCabec,"Manifesto")
	aAdd(aCabec,"Dt.Manif")
	aAdd(aCabec,"St. Viagem")
	aAdd(aCabec,"Chave Acesso")
	aAdd(aCabec,"Protocolo")

	oColab				:= ColaboracaoDocumentos():New()
	oColab:cQueue		:= '530'
	oColab:cModelo	:= 'MDFE'
	oColab:cTipoMov	:= '2'
	oColab:cFlag		:= '0'
	oColab:cFilProc	:= cFilAnt
	oColab:cNomeArq	:= cNomeArq

	While lOk
		If oColab:Consultar()
			cXml	:= oColab:cXmlRet
			aDados	:= ColDadosNf(4, "58", .T.)
			oXml	:= ColDadosXMl(cXml, aDados, @cErro, @cAviso)
			If oXmlEnc == nil
				oXmlEnc := XmlParser(cXml,"_",@cAviso,@cErro)
			EndIf
			Exit
		Else
			If MsgYesNo(STR0074)
				MsgRun(STR0069,STR0070,{||If((Empty(MV_PAR01TM) .or. MV_PAR01TM <= 0), Sleep(10000), Nil)})
				lOk := .T.
			Else
				lOk := .F.
			EndIf
		EndIf
	EndDo

	If lOk
		If 	Empty(oXml[3])
			If ValType(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE) == 'A'
				For nAT := 1 to Len(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE)
					cQuery := " SELECT DTX.DTX_VIAGEM, DTX.DTX_FILMAN, DTX.DTX_MANIFE, DTX.DTX_DATMAN, DTQ.DTQ_FILORI, DTQ.DTQ_DATGER, "
					cQuery += " CASE DTQ.DTQ_STATUS WHEN '1' THEN 'Em aberto'"
					cQuery += " WHEN '2' THEN 'Em trânsito' "
					cQuery += " WHEN '3' THEN 'Encerrada' "
					cQuery += " WHEN '4' THEN 'Chegada em Filial' "
					cQuery += " WHEN '5' THEN 'Fechada' "
					cQuery += " WHEN '9' THEN 'Cancelada' "
					cQuery += " ELSE 'Sem Status' END as DTQ_STATUS "
					cQuery += " FROM " + RetSqlName("DTX") + " DTX INNER JOIN " + RetSqlName("DTQ") + " DTQ ON DTQ.DTQ_VIAGEM = DTX.DTX_VIAGEM " // AND DTQ.DTQ_FILORI = DTX.DTX_FILORI "
					cQuery += " WHERE DTX.DTX_CHVMDF = '" + AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE[nAT]:_CHMDFE:TEXT) + "' "
					cQuery += " AND DTX.D_E_L_E_T_  = ' ' AND DTQ.D_E_L_E_T_  = ' '"
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

					If !Empty((cAliasQry)->DTQ_FILORI)
						Aadd(aListBox, Array(8))
						aListBox[Len(aListBox),1] := (cAliasQry)->DTQ_FILORI
						aListBox[Len(aListBox),2] := (cAliasQry)->DTX_VIAGEM
						aListBox[Len(aListBox),3] := Stod((cAliasQry)->DTQ_DATGER)
						aListBox[Len(aListBox),4] := (cAliasQry)->DTX_MANIFE
						aListBox[Len(aListBox),5] := Stod((cAliasQry)->DTX_DATMAN)
						aListBox[Len(aListBox),6] := (cAliasQry)->DTQ_STATUS
						aListBox[Len(aListBox),7] := AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE[nAT]:_CHMDFE:TEXT)
						aListBox[Len(aListBox),8] := AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE[nAT]:_NPROT:TEXT)
					Else
						Aadd(aListBox, Array(8))
						aListBox[Len(aListBox),7] := AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE[nAT]:_CHMDFE:TEXT)
						aListBox[Len(aListBox),8] := AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE[nAT]:_NPROT:TEXT)
					EndIf
					(cAliasQry)->( DbCloseArea() )
				Next
			Else
				cQuery := " SELECT DTX.DTX_VIAGEM, DTX.DTX_FILMAN, DTX.DTX_MANIFE, DTX.DTX_DATMAN, DTQ.DTQ_FILORI, DTQ.DTQ_DATGER, "
				cQuery += " CASE DTQ.DTQ_STATUS WHEN '1' THEN 'Em aberto'"
				cQuery += " WHEN '2' THEN 'Em trânsito' "
				cQuery += " WHEN '3' THEN 'Encerrada' "
				cQuery += " WHEN '4' THEN 'Chegada em Filial' "
				cQuery += " WHEN '5' THEN 'Fechada' "
				cQuery += " WHEN '9' THEN 'Cancelada' "
				cQuery += " ELSE 'Sem Status' END as DTQ_STATUS "
				cQuery += " FROM " + RetSqlName("DTX") + " DTX INNER JOIN " + RetSqlName("DTQ") + " DTQ ON DTQ.DTQ_VIAGEM = DTX.DTX_VIAGEM " // AND DTQ.DTQ_FILORI = DTX.DTX_FILORI "
				cQuery += " WHERE DTX.DTX_CHVMDF = '" + AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE:_CHMDFE:TEXT) + "' "
				cQuery += " AND DTX.D_E_L_E_T_  = ' ' AND DTQ.D_E_L_E_T_  = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

				If !Empty((cAliasQry)->DTQ_FILORI)
					Aadd(aListBox, Array(8))
					aListBox[Len(aListBox),1] := (cAliasQry)->DTQ_FILORI
					aListBox[Len(aListBox),2] := (cAliasQry)->DTX_VIAGEM
					aListBox[Len(aListBox),3] := Stod((cAliasQry)->DTQ_DATGER)
					aListBox[Len(aListBox),4] := (cAliasQry)->DTX_MANIFE
					aListBox[Len(aListBox),5] := Stod((cAliasQry)->DTX_DATMAN)
					aListBox[Len(aListBox),6] := (cAliasQry)->DTQ_STATUS
					aListBox[Len(aListBox),7] := AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE:_CHMDFE:TEXT)
					aListBox[Len(aListBox),8] := AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE:_NPROT:TEXT)
				Else
					Aadd(aListBox, Array(8))
					aListBox[Len(aListBox),7] := AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE:_CHMDFE:TEXT)
					aListBox[Len(aListBox),8] := AllTrim(OXMLENC:_RETCONSMDFENAOENC:_INFMDFE:_NPROT:TEXT)
				EndIf
				(cAliasQry)->( DbCloseArea() )
			EndIf
			DEFINE MSDIALOG oDlg TITLE STR0068 From 10,10 TO 450,1012 OF oMainWnd PIXEL

			@010,010 LISTBOX oListBox FIELDS HEADER aCabec[1], aCabec[2], aCabec[3], aCabec[4], aCabec[5], aCabec[6], aCabec[7], aCabec[8] SIZE 480,190 PIXEL OF oDlg

			oListBox:SetArray(aListBox)
			oListBox:bLine:={|| {aListBox[oListBox:nAt][01],;
									aListBox[oListBox:nAt][02],;
									aListBox[oListBox:nAt][03],;
									aListBox[oListBox:nAt][04],;
									aListBox[oListBox:nAt][05],;
									aListBox[oListBox:nAt][06],;
									aListBox[oListBox:nAt][07],;
									aListBox[oListBox:nAt][08]}}

			@ 205,400 BUTTON oBtn1 PROMPT STR0067 ACTION TME73EXCEL(aCabec, aListBox) OF oDlg PIXEL SIZE 045,011 //"Exportar Excel"
			@ 205,455 BUTTON oBtn2 PROMPT STR0066 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"Sair"

			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			Aviso("SPED", AllTrim(oXml[3]),{STR0066},3)	//Motivo do Retorno
		EndIf
	Else
		Aviso("SPED", AllTrim(STR0075),{STR0066},3)	//Motivo do Retorno
	EndIf

return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TZoneUTC  ³ Autor ³Marcelo Nunes          |Data  ³15.02.2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao para retornar Time Zone UTC de Acordo com            ³±±
±±³          ³o especificado nos parametros do CT-e                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet - Time Zone                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cIdEnt - Codigo da entidade                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TZoneUTC(cIdEnt)
Local cError	:= ""
Local cRet 	:= ""
If !lUsaColab
	If !Empty(cIdEnt)
		cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		oWS :=  WsSpedCfgNFe():New()
		oWS:cUSERTOKEN      := "TOTVS"
		oWS:cID_ENT         := cIdEnt
		oWS:nAmbienteMDFE   := 0
		oWS:cVersaoMDFE     := "0.00"
		oWS:nModalidadeMDFE := 0
		oWS:cVERMDFELAYOUT  := "0.00"
		oWS:cVERMDFELAYEVEN := "0.00"
		oWS:nSEQLOTEMDFE    := 0
		oWS:cHORAVERAOMDFE  := '0'
		oWS:cHORARIOMDFE    := '0'
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cModelo         := '58'
		oWS:CFGMDFE()

		If Empty(cError) .And. Valtype(oWS:OWSCFGMDFERESULT:CHORAVERAOMDFE) <> "U"
			If Left(oWS:OWSCFGMDFERESULT:CHORAVERAOMDFE,1) == "1"				//Horario de Verao -> 1-Sim ### 2-Nao
				If Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "1"		//Fernando de Noronha
					cRet := "-01:00"
				ElseIf Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "2"	//Brasilia
					cRet := "-02:00"
				ElseIf	Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "4"	//Acre
					cRet := "-04:00"
				Else
					cRet := "-03:00"						//Manaus
				Endif
			Else
				If Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "1"		//Fernando de Noronha
					cRet := "-02:00"
				ElseIf Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "2"	//Brasilia
					cRet := "-03:00"
				ElseIf	Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "4"	//Acre
					cRet := "-05:00"
				Else
					cRet := "-04:00"						//Manaus
				Endif
			Endif
		EndIf
	EndIf
Else
	cRet := Substr(colDtHrUTC(),20 ,6)
EndIf
Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TmsVerMDFeºAutor: Marcelo Nunes        º Data ³  08/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada Impressao do DAMDFE                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsVerMDFe(aDocs)
Local lRTMSR28   := ExistBlock("RTMSR28",,.T.)
Local lRTMSR32   := ExistBlock("RTMSR32",,.T.)
Local lRTMSR34   := ExistBlock("RTMSR34",,.T.)
Local cVersMdfe  := ""
Local cError     := ""
Local lUsaColab  := UsaColaboracao("5")
Local oWS
Local cURL
Local cAmbiente	 := ''
If !lUsaColab
	cIdEnt := getCfgEntidade(@cError)
	If !Empty(cIdEnt)
		cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		oWS :=  WsSpedCfgNFe():New()
		oWS:cUSERTOKEN      := "TOTVS"
		oWS:cID_ENT         := cIdEnt
		oWS:nAmbienteMDFE   := 0 
		oWS:cVersaoMDFE     := "0.00"
		oWS:nModalidadeMDFE := 0
		oWS:cVERMDFELAYOUT  := "0.00"
		oWS:cVERMDFELAYEVEN := "0.00"
		oWS:nSEQLOTEMDFE    := 0
		oWS:cHORAVERAOMDFE  := '0'
		oWS:cHORARIOMDFE    := '0'
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cModelo         := '58'
		oWS:CFGMDFE()
				
		cVersMdfe  := oWS:OWSCFGMDFERESULT:CVERSAOMDFE
		cAmbiente  := oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
		
		If cVersMdfe = "3.00" 
			If lRTMSR34 
				ExecBlock("RTMSR34",.F.,.F.,aDocs)						
			ElseIf lRTMSR32
				ExecBlock("RTMSR32",.F.,.F.,aDocs)
			EndIf	
		ElseIf cVersMdfe <= "2.00" .And. lRTMSR28
		   ExecBlock("RTMSR28",.F.,.F.)
		EndIf
	EndIf
Else
	cVersMdfe		:= ColGetPar("MV_VLAYMDF","")
	If cVersMdfe = "3.00" 
		If lRTMSR34	
			ExecBlock("RTMSR34",.F.,.F.,aDocs)
		ElseIf lRTMSR32	
			ExecBlock("RTMSR32",.F.,.F.,aDocs)
		EndIf
	ElseIf cVersMdfe <= "2.00" .And. lRTMSR28
	   ExecBlock("RTMSR28",.F.,.F.)
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSAE73TMR³ Autor ³Ruan Salvador          ³ Data ³18.04.2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os MV_PAR do pergunte TMSAE73A utilizado no timer  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAE73TMR()

	Pergunte('TMSAE73A',.F.,,.F.,,.T.,)

	MV_PAR01TM := MV_PAR01
	MV_PAR02TM := MV_PAR02

   	Pergunte('TMSAE73', .F.)

Return(nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73STATM³ Autor ³Ruan Salvador          ³ Data ³18.04.2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel por solicitar o Status dos MDF'e         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73STATM(aListBox, aPerg, cIdent, aDocs)

	Default aListBox := {}
	Default cIdent   := ""
	Default aDocs    := {}

	If lUsaColab
		Return Nil
	EndIf
	If Empty(cIdent)
		If CTIsReady(,,,lUsaColab)
			cIdEnt := RetIdEnti(lUsaColab)
		EndIf
	EndIf

	If MV_PAR02TM == 1
		FWMsgRun(, {|oSay| TME73EXETM(aListBox, aPerg, cIdent, aDocs) }, STR0070,  STR0117) //Processando // "Atualizando Status dos Manifestos..."
	Else
		If aScan( aListBox,{|x| x[2]:CNAME == 'BR_VERDE' }) > 0
		   FWMsgRun(, {|oSay| TME73EXETM(aListBox, aPerg, cIdent, aDocs) }, STR0070,   STR0117) //Processando // "Atualizando Status dos Manifestos..."
		End
	End

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73DocTM³ Autor ³ Ruan Salvador         ³ Data ³18.04.2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o timer                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TME73EXETM(aListBox, aPerg, cIdent, aDocs)

	Local lEnd       := .F.

	Default aDocs := {}
	//-- Realiza refresh no BROWSE
	TME73Rfs(@aListBox, aPerg, aDocs)

	//-- Obtem documentos para transmissao
	aDoctosTra := TME73DocTM(aListBox)

	//-- Solicita o status
	TME73PSt(aDoctosTra,lEnd, cIdent)

	//-- Realiza refresh no BROWSE
	TME73Rfs(@aListBox, aPerg, aDocs)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TME73DocTM³ Autor ³ Ruan Salvador         ³ Data ³18.04.2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparar documentos para retornar o status                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TME73DocTM(aListBox)

	Local   nI         := 0
	Local   aDoctos    := {}
	Local   aDoctosTra := {}
	Local   aDoctosCnt := {}
	Local   nQtdDoc    := 1

	//-- Fil.Docto + Docto + Serie
	aDoctos := AClone(aListBox)
	ASort( aDoctos,,,{|x,y| x[ CTFILMAN ] + x[ CTMANIFE ] < y[ CTFILMAN ] + y[ CTMANIFE ] + y[ CTSERMAN ] })

	For nI := 1 To Len(aDoctos)
		If aDoctos[nI,2]:CNAME == 'BR_VERDE'
		If !Empty(aDoctosCnt)
			If aDoctos[nI,CTFILMAN]+AllTrim(aDoctos[nI,CTMANIFE]) <> aDoctosCnt[1]+Soma1(AllTrim(aDoctosCnt[2])) .Or. nQtdDoc > 50
				aDoctosTra[Len(aDoctosTra),3] := Padr(aDoctosCnt[2],Len(DTX->DTX_MANIFE))
				aDoctosCnt := {}
				nQtdDoc := 1
			Else
				aDoctosCnt[2] := Soma1(AllTrim(aDoctosCnt[2]))
				nQtdDoc += 1
			EndIf
		EndIf
		If Empty(aDoctosCnt)
			Aadd(aDoctosTra,Array(5))
			aDoctosTra[Len(aDoctosTra),1] := aDoctos[nI,CTFILMAN ]
			aDoctosTra[Len(aDoctosTra),2] := Padr(aDoctos[nI,CTMANIFE ],Len(DTX->DTX_MANIFE))
			aDoctosTra[Len(aDoctosTra),3] := ''
			aDoctosTra[Len(aDoctosTra),4] := Padr(aDoctos[nI,CTSERMAN],Len(DT6->DT6_SERIE))

			If lInCond
				aDoctosTra[Len(aDoctosTra),5] := aDoctos[nI,CTCODMOT]
			EndIf

			aDoctosCnt := Array(3)
			aDoctosCnt[1] := aDoctos[nI,CTFILMAN]
			aDoctosCnt[2] := aDoctos[nI,CTMANIFE]
			aDoctosCnt[3] := aDoctos[nI,CTSERMAN]
			nQtdDoc += 1
		EndIf
		EndIf
	Next nI
	If Len(aDoctosTra) > 0 .And. Empty(aDoctosTra[Len(aDoctosTra),3])
		aDoctosTra[Len(aDoctosTra),3] := Padr(aDoctosCnt[2],Len(DTX->DTX_MANIFE))
	EndIf
Return(aDoctosTra)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TmsMDFeAut³ Autor ³ Felipe Barbieri       ³ Data ³31.07.2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia documentos automaticamente para SEFAZ                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - aDocs: [1]-FilMan / [2]-Man Ini / [3] Man Fim     ±±
±±³                             [4]- Serie do Manifesto                    ±± 
±±³	nOperacao 1 - Envia / 2 - Encerra / 3 - Cancela / 4 - Incl. Condutor  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsMDFeAut(aDocs, nOper)
Local lEnd 	     := .F.
Local cIdent     := ""
Local lNTransmit := .F.
Local lRet       := .T.
Local cSeek      := ""
Local cQry,cAliasQry,aAreaAux,nCntFor // Variáveis só utilizadas no envio, por isso não são inicializadas, somente na opção utilizada
Local lRTMSR32   := ExistBlock("RTMSR32",,.T.)
Local lRTMSR34   := ExistBlock("RTMSR34",,.T.)
Local lTmsae73C  := IIf(ExistFunc('TmsChekSX1'),TmsChekSX1('TMSAE73C'),.F.)
Local cPerg      := If(!IsInCallStack("TMSAE73B"), (IIf(lTmsae73C,'TMSAE73C','TMSAE73')),'TMSAE73B')

Private lEnvia   	:= IIf(nOper == 1, .T., .F.)
Private lEncerra 	:= IIf(nOper == 2, .T., .F.)
Private lCancela 	:= IIf(nOper == 3, .T., .F.)
Private lInCond  	:= IIf(nOper == 4, .T., .F.)
Private lUsaColab 	:= UsaColaboracao("5")
Private MV_PAR01TM 	:= 0
Private cTpEvento   := 0

cTpEvento:= ""

//--Tratamento para MDFe Automático
If lEncerra
	cTpEvento := cCDEVEENC //- Codigo do Evento de Encerramento	
ElseIf lCancela
	cTpEvento := cCDEVECAN //- Codigo do Evento de Cancelamento
ElseIf lInCond
   cTpEvento := cCDEVINCO //- Codigo do Evento de Inclusao de Condutor
EndIf

Default aDocs := {}

If Len(aDocs) > 0 
	FwMsgRun(, {|oSay| TMS73PrEnv(aDocs, oSay) } , STR0070 , STR0102 ) //"Processando"  /  "Transmitindo documentos..."
Else
	Return Nil	
EndIf

If lEnvia // Envia
	
	//-- Valida se houve tentativa de transmissão automatica e se algum manifesto não foi autorizado, e, caso positivo, abre o monitor
	cAliasQry  := GetNextAlias()
	aAreaAux   := GetArea()
	lNTransmit := .F.
	For nCntFor := 1 To Len(aDocs)
		cQry := " SELECT COUNT(1) NREG "
		cQry += " FROM " + RetSqlName("DTX")
		cQry += " WHERE DTX_FILIAL  = '" + xFilial("DTX",aDocs[nCntFor][1]) + "'"
		cQry += "   AND D_E_L_E_T_  = ' '"
		cQry += "   AND DTX_FILMAN  = '" + aDocs[nCntFor][1] + "'"
		cQry += "   AND DTX_MANIFE >= '" + aDocs[nCntFor][2] + "'"
		cQry += "   AND DTX_MANIFE <= '" + aDocs[nCntFor][3] + "'"
		cQry += "   AND DTX_SERMAN  = '" + aDocs[nCntFor][4] + "'"
		cQry += "   AND DTX_VIAGEM  = '" + aDocs[nCntFor][5] + "'"
		cQry += "   AND DTX_TIPMAN  = '2' " //-- Eletronico
		cQry += "   AND DTX_STIMDF <> '2' " //-- não autorizado
		
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),cAliasQry,.F.,.T.)
		If !lNTransmit
			lNTransmit := (cAliasQry)->(!Eof() .And. !Empty((cAliasQry)->NREG))
		EndIf
		cSeek := xFilial('DTX')+aDocs[nCntFor][1]+aDocs[nCntFor][2]+aDocs[nCntFor][4]
		
		//--Tratamento para Impressão Automática do Manifesto
		Pergunte(cPerg,.F.)
		If mv_par08 == 3 
			AAdd(aDocs[nCntFor],.F.)
		Else
			AAdd(aDocs[nCntFor],.T.)
		EndIf

		(cAliasQry)->(DbCloseArea())

	Next nCntFor
	RestArea(aAreaAux)

	If lNTransmit .And. !IsBlind() //-- Se não for transmitido e não for Job (Interação sem tela)
		TMSAE73(,,,,,,nOper,aDocs) //-- Monitor do MDF-e caso encontre alguma inconsistência	
		lNTransmit := .F.
		//--Atualiza o cperg 
		SetMvValue(cPerg,"MV_PAR04",dDataBase)        
		SetMvValue(cPerg,"MV_PAR05",dDataBase)	
		SetMvValue(cPerg,"MV_PAR06","1") //--Envio 	

		Pergunte(cPerg,.F.)
	Else
		aAreaDTX := DTX->(GetArea())
		dbSelectArea("DTX")	
		DTX->(dbSetOrder(2)) //DTX_FILIAL+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN
		If DTX->(MsSeek(cSeek))	
			If DTX->DTX_STIMDF == '2' .And. mv_par08 <> 2 			
				If !lNTransmit .And. (lRTMSR32 .Or. lRTMSR34) .And. !IsBlind()  //-- Se for transmitido e não for Job (Interação sem tela)		
	
					For nCntFor := 1 To Len(aDocs)
						AAdd(aDocs[nCntFor],DTX->DTX_FILORI) // Incluida a Filial de Origem, Necessario para a impressão do MDFe quando o MV_MDFEAUT estiver .T.
					Next nCntFor
	
					TmsVerMDFe(aDocs)
				EndIf
			EndIf
		EndIf
		RestArea(aAreaDTX)		
	EndIf
	
ElseIf lEncerra 
	//--Obtem a Entidade
	cIdEnt := RetIdEnti(lUsaColab)
	//-- Solicita o status do monitor do MDF-e
	TME73PSt(aDocs,lEnd,cIdent)	
	
	cAliasQry  := GetNextAlias()
	aAreaAux   := GetArea()	
	lNTransmit := .F.
	For nCntFor := 1 To Len(aDocs)
		cQry := " SELECT COUNT(1) NREG "
		cQry += " FROM " + RetSqlName("DTX")
		cQry += " WHERE DTX_FILIAL  = '" + xFilial("DTX",aDocs[nCntFor][1]) + "'"
		cQry += "   AND D_E_L_E_T_  = ' '"
		cQry += "   AND DTX_FILMAN  = '" + aDocs[nCntFor][1] + "'"
		cQry += "   AND DTX_MANIFE >= '" + aDocs[nCntFor][2] + "'"
		cQry += "   AND DTX_MANIFE <= '" + aDocs[nCntFor][3] + "'"
		cQry += "   AND DTX_SERMAN  = '" + aDocs[nCntFor][4] + "'"
		cQry += "   AND DTX_VIAGEM  = '" + aDocs[nCntFor][5] + "'"
		cQry += "   AND DTX_TIPMAN  = '2' " //-- Eletronico

		cQry += "   AND DTX_STFMDF <> '2' " //-- não autorizado
		
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),cAliasQry,.F.,.T.)
		lNTransmit := (cAliasQry)->(!Eof() .And. !Empty((cAliasQry)->NREG))

		(cAliasQry)->(DbCloseArea())

		If lNTransmit
			Exit
		EndIf
	Next nCntFor
	RestArea(aAreaAux)	
		
	If lNTransmit .And. !IsBlind() //-- Se não for transmitido e não for Job (Interação sem tela)
		TMSAE73(,,,,,,nOper,aDocs) //-- Monitor do MDF-e caso encontre alguma inconsistência	
	EndIf

//-- Valida se houve tentativa de transmissao automatica sem sucesso do Cancelamento MDF-e e abre o monitor se encontrou falha na transmissao.
ElseIf lCancela
	cAliasQry  := GetNextAlias()
	aAreaAux   := GetArea()
	lNTransmit := .F.
	For nCntFor := 1 To Len(aDocs)
		cQry := " SELECT COUNT(1) NREG "
		cQry += " FROM " + RetSqlName("DYN")
		cQry += " WHERE DYN_FILIAL  = '" + xFilial("DTX",aDocs[nCntFor][1]) + "'"
		cQry += "   AND D_E_L_E_T_  = ' '"
		cQry += "   AND DYN_FILMAN  = '" + aDocs[nCntFor][1] + "'"
		cQry += "   AND DYN_MANIFE >= '" + aDocs[nCntFor][2] + "'"
		cQry += "   AND DYN_MANIFE <= '" + aDocs[nCntFor][3] + "'"
		cQry += "   AND DYN_SERMAN  = '" + aDocs[nCntFor][4] + "'"
		cQry += "   AND DYN_VIAGEM  = '" + aDocs[nCntFor][5] + "'"

		cQry += "   AND DYN_STCMDF <> '2' " //-- não autorizado ou nao transmitido
		
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),cAliasQry,.F.,.T.)
		lNTransmit := (cAliasQry)->(!Eof() .And. !Empty((cAliasQry)->NREG))

		(cAliasQry)->(DbCloseArea())

		If lNTransmit
			Exit
		EndIf
	Next nCntFor
	RestArea(aAreaAux)

	If lNTransmit .And. !IsBlind() //-- Se não for transmitido e não for Job (Interação sem tela)
		TMSAE73(,,,,,,nOper,aDocs) //-- Monitor do MDF-e caso encontre alguma inconsistência	
	EndIf

EndIf	

lRet := !lNTransmit

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM73QryDTX
Montagem dos campos para a execução da Query para Listar os Manifestos (DTX)
@type function
@author Katia
@version 12
@since 17/04/2019
@return cQuery
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM73QryDTX(aPerg, aDocs, nQuery, lVisual ) 
Local cQuery      := ""
Local lDTQ	      := .T.
Local cQryDTQ     := ""
Local nCntFor     := 0
Local cRetPE      := ""
Local lDTX_PRMACO := DTX->(FieldPos("DTX_PRMACO")) > 0
Local lRotAut     := IsInCallStack("TMSMDFeAut")

Default aPerg     := {}
Default aDocs     := {}
Default nQuery    := 1

	cQryDTQ		:= " INNER JOIN " + RetSqlName('DTQ') + " DTQ ON "
	cQryDTQ		+= " DTQ_FILIAL = '"+ xFilial("DTQ") +"'"
	cQryDTQ     	+=	" AND DTQ_FILORI = DTX.DTX_FILORI "
	cQryDTQ		+=	" AND DTQ_VIAGEM = DTX.DTX_VIAGEM "
	cQryDTQ		+=	" AND DTQ.D_E_L_E_T_ = ' ' "

    //----
	cQuery := " SELECT "
	If !__lPyme
		cQuery += "DTQ.DTQ_STATUS,"
	Else
		cQuery += "'' DTQ_STATUS,"
	EndIf

	If lDTX_PRMACO .And. Len(aDocs) == 0
		cQuery += "   DTX1.DTX_FILIAL, DTX1.DTX_FILMAN, COALESCE(DTX1.DTX_MANIFE, ' ') DTX_MANIFE, DTX1.DTX_DATMAN, DTX1.DTX_HORMAN, DTX1.DTX_RTIMDF, " 
		cQuery += "   DTX1.DTX_STIMDF, DTX1.DTX_RTFMDF, DTX1.DTX_STFMDF, DTX1.DTX_FIMP  , DTX1.R_E_C_N_O_ DTXRECNO, "
		cQuery += "   DTX1.DTX_FILORI, DTX1.DTX_VIAGEM, DTX1.DTX_CODEVE, DTX1.DTX_STATUS, DTX1.DTX_NUMROM, DTX1.DTX_SERMAN, COALESCE(DTX1.DTX_PRMACO,' ') DTX_PRMACO "
	Else
		cQuery += "   DTX.DTX_FILIAL, DTX.DTX_FILMAN, COALESCE(DTX.DTX_MANIFE, ' ') DTX_MANIFE, DTX.DTX_DATMAN, DTX.DTX_HORMAN, DTX.DTX_RTIMDF, " 
		cQuery += "   DTX.DTX_STIMDF, DTX.DTX_RTFMDF, DTX.DTX_STFMDF, DTX.DTX_FIMP  , DTX.R_E_C_N_O_ DTXRECNO, "
		cQuery += "   DTX.DTX_FILORI, DTX.DTX_VIAGEM, DTX.DTX_CODEVE, DTX.DTX_STATUS, DTX.DTX_NUMROM, DTX.DTX_SERMAN "
		If lDTX_PRMACO
			cQuery += " , COALESCE(DTX.DTX_PRMACO,' ') DTX_PRMACO "
		EndIf
	EndIf

	If lInCond
		cQuery += " , DUP_RTMDFE, DUP_CODMOT,DUP_STMDFE, "
		cQuery += "( SELECT DA4.DA4_NOME FROM " + RetSqlName('DA4') + " DA4 "
        cQuery += " WHERE DA4.DA4_FILIAL = '"+ xFilial("DA4") +"' "
        cQuery += " AND DA4.DA4_COD = DUP.DUP_CODMOT
        cQuery += " AND DA4.D_E_L_E_T_ = ' ' ) AS DA4_NOME "
	ElseIf lPagFrete
		cQuery += " , DTX1.DTX_NUMCTC, DLI_CODEVE,DLI_DESEVE, DLI_STAEVE "
	EndIf

	cQuery += " FROM " + RetSqlName('DTX') + " DTX "
	If lEncerra .And. !__lPyme .And. !lRotAut
	//-- Ponto de entrada ignora condicoes para verificacao do status da viagem.
		If !lTME73ENC
			cQuery += cQryDTQ
			cQuery += "AND DTQ.DTQ_STATUS IN ('4','3','9','2')"
			lDTQ := .F.
		EndIf
	EndIf
	If lEncerra .And. __lPyme
		cQuery += " INNER JOIN " + RetSqlName('DYB') + " DYB ON "
		cQuery += "       DYB_FILIAL = '"+ xFilial("DYB") +"'"
		cQuery += "   AND DYB_NUMROM = DTX.DTX_NUMROM "
		cQuery += "   AND DYB_STATUS = '3' "
	EndIf
	If lInCond .And. !__lPyme
		cQuery += " INNER JOIN " + RetSqlName('DUP') + " DUP ON "
		cQuery += "  DUP_FILIAL = '"+ xFilial("DUP") +"'"
		cQuery += "  AND DUP_VIAGEM = DTX.DTX_VIAGEM "
		cQuery += "  AND DUP_FILORI = DTX.DTX_FILMAN "
		cQuery += "  AND DUP.D_E_L_E_T_ = ' ' "
	ElseIf lPagFrete
		cQuery += " INNER JOIN " + RetSqlName('DLI') + " DLI ON "
		cQuery += "  DLI_FILIAL = '"+ xFilial("DLI") +"'"
		cQuery += "  AND DLI_FILMAN = DTX.DTX_FILMAN "
		cQuery += "  AND DLI_MANIFE = DTX.DTX_MANIFE "
		cQuery += "  AND DLI_SERMAN = DTX.DTX_SERMAN "
		cQuery += "  AND DLI_CODEVE = '" + '116' + "' "
		cQuery += "  AND DLI.D_E_L_E_T_ = ' ' "		
		If aPerg[1,3] == 1 // Não Transmitido
			cQuery += "AND DLI.DLI_STAEVE <> '2' "
		ElseIf aPerg[1,3] == 2 //Evento Vinculado
			cQuery += "AND DLI.DLI_STAEVE = '2' "
		EndIf
	EndIf
		
	If lEnvia .And. __lPyme
		cQuery += " INNER JOIN " + RetSqlName('DYB') + " DYB ON "
		cQuery += "       DYB_FILIAL = '"+ xFilial("DYB") +"'"
		cQuery += "   AND DYB_NUMROM = DTX.DTX_NUMROM "
		cQuery += "   AND DYB_STATUS IN ('1','2') "
		cQuery += "   AND DYB.D_E_L_E_T_ = ' ' "
	EndIf

	If lDTQ .And. !__lPyme
		cQuery += cQryDTQ
        If !lVisual
            If aPerg[1,7] == 1
                cQuery += "   AND DTQ.DTQ_SERTMS = '2' "
            ElseIf aPerg[1,7] == 2
                cQuery += "   AND DTQ.DTQ_SERTMS = '3' "
            EndIf
        EndIf
	EndIf	

	//---- LEFT com Manifesto COMBOIO 'Relacionados'
	If lDTX_PRMACO .And. Len(aDocs) == 0
		cQuery += " LEFT JOIN " + RetSqlName('DTX') + " DTX1  "
		cQuery += "        ON DTX1.DTX_FILIAL = '"+ xFilial("DTX") +"'"
		cQuery += "       AND DTX1.DTX_FILMAN = '" + cFilAnt + "' "
		cQuery += "       AND DTX1.DTX_DATMAN BETWEEN '" + aPerg[1,4] + "' AND '" + aPerg[1,5] + "' "
		cQuery += "       AND DTX1.DTX_TIPMAN = '" + StrZero(2,Len(DTX->DTX_TIPMAN)) + "' "
		If nQuery == 1
			cQuery += " 	  AND (DTX1.DTX_MANIFE = DTX.DTX_PRMACO OR DTX1.DTX_MANIFE = DTX.DTX_MANIFE) "
		Else
			cQuery += "       AND ( DTX1.DTX_PRMACO = DTX.DTX_MANIFE OR DTX1.DTX_PRMACO = DTX.DTX_PRMACO ) AND DTX1.DTX_PRMACO <> '' "
		EndIf
		cQuery += "       AND DTX1.DTX_SERMAN = DTX.DTX_SERMAN "
		cQuery += "       AND DTX1.D_E_L_E_T_ = ' ' " 
    EndIf
 
    //--------- CLAUSULA WHERE ------	
	cQuery += " WHERE DTX.DTX_FILIAL = '" + xFilial('DTX') + "' "

	If Len(aDocs) == 0
		cQuery += "   AND DTX.DTX_FILMAN = '" + cFilAnt + "' "
	EndIf

	If !lRotAut
		cQuery += "   AND DTX.DTX_DATMAN BETWEEN '" + aPerg[1,4] + "' AND '" + aPerg[1,5] + "' "
	EndIf
	cQuery += "   AND DTX.DTX_TIPMAN = '" + StrZero(2,Len(DTX->DTX_TIPMAN)) + "' "

	If Len(aDocs) == 0
		cQuery += " AND DTX.DTX_MANIFE BETWEEN '" + aPerg[1,1] + "' AND '" + aPerg[1,2] + "' "
	Else
		cQuery += " AND ("
		For nCntFor := 1 To Len(aDocs)
			cQuery += IIf(nCntFor > 1, " OR ","")
			cQuery += " (     DTX.DTX_FILMAN  = '" + aDocs[nCntFor][1] + "'"
			If aDocs[nCntFor][2] == aDocs[nCntFor][3]  
				cQuery += "   AND DTX.DTX_MANIFE  = '" + aDocs[nCntFor][2] + "'"
			Else
				cQuery += "   AND DTX.DTX_MANIFE >= '" + aDocs[nCntFor][2] + "'"
				cQuery += "   AND DTX.DTX_MANIFE <= '" + aDocs[nCntFor][3] + "'"
			EndIf
			cQuery += "   AND DTX.DTX_SERMAN  = '" + aDocs[nCntFor][4] + "'"
			cQuery += " ) "
		Next nCntFor
		cQuery += "   ) "
	EndIf
			
	//--- Transmissao 1- Envio, 2- Encerramento, 3- Cancelamento
	//--- Status do Manifesto 1- Nao Autorizado, 2- Autorizado, 3- Ambos
	If lEnvia .OR. lVisual    //Envio
		If aPerg[1,3] == 1
			cQuery += "AND DTX.DTX_STIMDF <> '2' "
		ElseIf aPerg[1,3] == 2
			cQuery += "AND DTX.DTX_STIMDF = '2' "
		EndIf
	ElseIf lEncerra   //Encerramento
		cQuery += "AND DTX.DTX_STIMDF = '2' "
		If aPerg[1,3] == 1
			cQuery += "AND DTX.DTX_STFMDF <> '2' "
		ElseIf aPerg[1,3] == 2
			cQuery += "AND DTX.DTX_STFMDF = '2' "
		EndIf
	EndIf
	cQuery += "   AND DTX.D_E_L_E_T_ = ' ' "

	//-- Ponto de entrada para incluir novas condicoes para verificacao do status da viagem.
	If lEncerra
		If lTME73ENC
			cRetPE := ExecBlock("TME73ENC",.F.,.F.)
			If ValType(cRetPE) == "C"
				cQuery += cRetPE
			EndIf
		EndIf
	EndIf

Return cQuery

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM73QryDYN
Montagem dos campos para a execução da Query para Listar os Manifestos Cancelados (DYN)
@type function
@author Katia
@version 12
@since 17/04/2019
@return cQuery
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM73QryDYN(aPerg, aDocs, nQuery) 
Local cQuery      := ""
Local nCntFor     := 0
Local lDTX_PRMACO := DTX->(FieldPos("DTX_PRMACO")) > 0

Default aPerg     := {}
Default aDocs     := {}
Default nQuery    := 1

	cQuery := " SELECT '' DTQ_STATUS,"
	If lDTX_PRMACO .And. Len(aDocs) == 0
		cQuery += "   DYN1.DYN_FILIAL DTX_FILIAL , DYN1.DYN_FILMAN DTX_FILMAN, COALESCE(DYN1.DYN_MANIFE, ' ')  DTX_MANIFE, DYN1.DYN_DATMAN DTX_DATMAN, "
		cQuery += "   DYN1.DYN_HORMAN DTX_HORMAN , DYN1.DYN_RTIMDF DTX_RTIMDF, DYN1.DYN_STIMDF DTX_STIMDF, DYN1.DYN_RTCMDF DTX_RTFMDF, "
		cQuery += "   DYN1.DYN_STCMDF DTX_STFMDF , ''       DTX_FIMP    , DYN1.R_E_C_N_O_ DTXRECNO, "
		cQuery += "   DYN1.DYN_FILORI DTX_FILORI , DYN1.DYN_VIAGEM DTX_VIAGEM, DYN1.DYN_CODEVE DTX_CODEVE, '' DTX_STATUS, DYN1.DYN_SERMAN DTX_SERMAN, DYN1.DYN_NUMROM DTX_NUMROM  "
		cQuery += " , COALESCE(DYN1.DYN_PRMACO, ' ') DTX_PRMACO "
	Else
		cQuery += "   DYN.DYN_FILIAL DTX_FILIAL , DYN.DYN_FILMAN DTX_FILMAN, COALESCE(DYN.DYN_MANIFE, ' ') DTX_MANIFE, DYN.DYN_DATMAN DTX_DATMAN, "
		cQuery += "   DYN.DYN_HORMAN DTX_HORMAN , DYN.DYN_RTIMDF DTX_RTIMDF, DYN.DYN_STIMDF DTX_STIMDF, DYN.DYN_RTCMDF DTX_RTFMDF, "
		cQuery += "   DYN.DYN_STCMDF DTX_STFMDF , ''       DTX_FIMP    , DYN.R_E_C_N_O_ DTXRECNO, "
		cQuery += "   DYN.DYN_FILORI DTX_FILORI , DYN.DYN_VIAGEM DTX_VIAGEM, DYN.DYN_CODEVE DTX_CODEVE, '' DTX_STATUS, DYN.DYN_SERMAN DTX_SERMAN, DYN.DYN_NUMROM DTX_NUMROM  "
		If lDTX_PRMACO 
			cQuery += " , COALESCE(DYN.DYN_PRMACO, ' ') DTX_PRMACO "
		EndIf
	EndIf
	cQuery += " FROM " + RetSqlName('DYN') + " DYN "

	//---- LEFT com Manifesto COMBOIO 'Relacionados'
	If lDTX_PRMACO .And. Len(aDocs) == 0
		cQuery += " LEFT JOIN " + RetSqlName('DYN') + " DYN1  "
		cQuery += "        ON DYN1.DYN_FILIAL = '"+ xFilial("DYN") +"'"
		cQuery += "       AND DYN1.DYN_FILMAN = '" + cFilAnt + "' "
		cQuery += "       AND DYN1.DYN_DATMAN BETWEEN '" + aPerg[1,4] + "' AND '" + aPerg[1,5] + "' "
		If nQuery == 1
			cQuery += " 	  AND (DYN1.DYN_MANIFE = DYN.DYN_PRMACO OR DYN1.DYN_MANIFE = DYN.DYN_MANIFE) "
		Else
			cQuery += "       AND ( DYN1.DYN_PRMACO = DYN.DYN_MANIFE OR DYN1.DYN_PRMACO = DYN.DYN_PRMACO ) AND DYN1.DYN_PRMACO <> '' "
		EndIf
		cQuery += "       AND DYN1.DYN_SERMAN = DYN.DYN_SERMAN "
		cQuery += "       AND DYN1.D_E_L_E_T_ = ' ' " 
    EndIf

	//---- CLAUSULA WHERE --- 
	cQuery += " WHERE DYN.DYN_FILIAL = '" + xFilial('DYN') + "'"
	cQuery += "   AND DYN.DYN_DATMAN BETWEEN '" + aPerg[1,4] + "' AND '" + aPerg[1,5] + "' "

	If Len(aDocs) == 0
		cQuery += "   AND DYN.DYN_FILMAN = '" + cFilAnt + "' "
	EndIf

	If Len(aDocs) == 0
		cQuery += " AND DYN.DYN_MANIFE BETWEEN '" + aPerg[1,1] + "' AND '" + aPerg[1,2] + "' "
	Else
		cQuery += " AND ("
		For nCntFor := 1 To Len(aDocs)
			cQuery += IIf(nCntFor > 1, " OR ","")
			cQuery += " (     DYN.DYN_FILMAN  = '" + aDocs[nCntFor][1] + "'"
			If aDocs[nCntFor][2] == aDocs[nCntFor][3]  
				cQuery += "   AND DYN.DYN_MANIFE  = '" + aDocs[nCntFor][2] + "'"
			Else
				cQuery += "   AND DYN.DYN_MANIFE >= '" + aDocs[nCntFor][2] + "'"
				cQuery += "   AND DYN.DYN_MANIFE <= '" + aDocs[nCntFor][3] + "'"
			EndIf
			cQuery += " ) "
		Next nCntFor
		cQuery += "   ) "
	EndIf

	//--- Transmissao 1- Envio, 2- Encerramento, 3- Cancelamento
	//--- Status do Manifesto 1- Nao Autorizado, 2- Autorizado, 3- Ambos
	If aPerg[1,3] == 1
		cQuery += "AND DYN.DYN_STCMDF <> '2' "
	ElseIf aPerg[1,3] == 2
		cQuery += "AND DYN.DYN_STCMDF = '2' "
	EndIf
	cQuery += "   AND DYN.D_E_L_E_T_ = ' '"

Return cQuery

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM73OpeCli
Retorna as operações apontadas para validar se os pares das operações estão apontadas.
@type function
@author Alexandre Arume
@version 12
@since 28/09/2018
@return cQuery
/*/
//-------------------------------------------------------------------------------------------------
Function TM73OpeCli(cFilOri, cViagem)

Local lOk       := .T.
Local nCount    := 0
Local cSeekDTW  := ""
Local cAtivSai 	:= SuperGetMV('MV_ATIVSAI',,'')
Local cAtivChg 	:= SuperGetMv("MV_ATIVCHG",,'')
Local aAreaDTW  := DTW->(GetArea())
Local cAtvSaiApo:= SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local cAtvChgApo:= SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio

Default cFilOri:= ""
Default cViagem:= ""
					
// Retorna as operações apontadas para validar se os pares das operações estão apontadas.
cSeekDTW := xFilial("DTW")+cFilOri+cViagem+StrZero(2,Len(DTW->DTW_STATUS))
DTW->(DbClearFilter())
DTW->(DbCloseArea())

DTW->(dbSetOrder(3))
DTW->(dbSeek(cSeekDTW))
While DTW->(!Eof()) .AND. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_STATUS) == cSeekDTW
// Soma se for uma atividade de cliente.
	If !Empty(DTW->DTW_CODCLI) .AND. !Empty(DTW->DTW_LOJCLI)
    	nCount++
    Else
        // Soma se for atividade de saida de viagem ou chegada de viagem.
		If !Empty(cAtvSaiApo) .And. !Empty(cAtvChgApo)
			If DTW->DTW_ATIVID $ cAtivSai+","+cAtivChg+","+cAtvSaiApo+","+cAtvChgApo
	            nCount++
    	    EndIf
		Else
        	If DTW->DTW_ATIVID $ cAtivSai+","+cAtivChg
	            nCount++
    	    EndIf
		EndIf	
    EndIf
    DTW->(dbSkip())
EndDo
                    
If nCount > 0 .AND. Mod(nCount, 2) <> 0
    lOk := .F.
EndIf

RestArea(aAreaDTW)

Return lOk



//-----------------------------------------------------------------------------------
/*/{Protheus.doc} TMAE73DLI
Retorna a quantidade de registros da DLI que estão aptos a serem transmitidos
@type function
@author Leandro Paulino
@version 12
@since 12/03/2020
@return cQuery
/*/
//-----------------------------------------------------------------------------------
Static Function TMAE73DLI(aListBox, nItem)

Local cQuery	:= ''
Local cAliasQry := ''
Local lRet 		:= .T.

Default aListBox 	:= {}
Default nItem		:= 1

If DLI->(ColumnPos('DLI_STAEVE')) > 0

	cQuery := "SELECT COUNT(*) AS DLI_CONT "
	cQuery += " 	FROM "+RetSqlName("DLI")
	cQuery += "			WHERE 	DLI_FILIAL = '" + FwxFilial("DLI") + "'"
	cQuery += " 			AND DLI_FILMAN = '" + aListBox[nItem, CTFILMAN]+ "'"
	cQuery += " 			AND DLI_MANIFE = '" + aListBox[nItem, CTMANIFE]+ "'"	
	cQuery += " 			AND DLI_CODEVE = '" + '116' + "'"
	cQuery += " 			AND DLI_STAEVE IN ('0', '3') AND D_E_L_E_T_ =  ' '"	// 0=Preparado para Transmissão;1=Envio Evento realizado;2=Evento vinculado com sucesso;3=Evento rejeitado
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->DLI_CONT = 0
		lRet:= .F.
	EndIf
	(cAliasQry)->( DbCloseArea() )
	
EndIf

Return lRet


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} T73RetEvPg
	(Retorna os dados necessários para o envio do evento de pagamento de frete)
	@type  Static Function
	@author Leandro Paulino
	@since 12/03/2020
	@version 1.0
	@param cFilManife, cManifesto
	@return aDadosPgFr, Array contendo os dados para envio do envento de 
			pgto.frete
/----------------------------------------------------------------------------------*/
Static Function T73RetEvPg(cFilManife,cManifesto)

Local cQuery 		:= ''
Local cAliasQry		:= GetNextAlias()
Local adadosPgFr	:= {}
Local nQtdINf		:= 0
lOCAL cCnpjOpe		:= ''
Local cAgencia		:= ''
Local cBanco 		:= ''

Default cFilManife	:= ''
Default cManifesto	:= ''

cQuery := "	SELECT 	 DTX.DTX_MANIFE, DTX.DTX_PRIMDF , DEG.DEG_CNPJOP, DEG.DEG_AGENCI, DEG.DEG_BANCO  ,DVP.DVP_VALPAS "
cQuery += "			,DVP.DVP_CODPAS, DT3.DT3_DESCRI , DTY.DTY_VALFRE, DTY.DTY_ADIFRE, DTY.DTY_IRRF   ,DTY.DTY_SEST   "
cQuery += "			,DTY.DTY_INSS  , DTY.DTY_ISS	, DTY.DTY_PIS   , DTY.DTY_COFINS, DTY.DTY_CSLL   ,DTY.DTY_VALPDG " 
cQuery += "			,DTY.DTY_TAXBAN , SA2.A2_NOME DEG_NOME	, SA2.A2_TIPO DEG_TIPO  , SA21.A2_NOME  , SA21.A2_CGC    "
cQuery += "			,SA21.A2_AGENCIA, SA21.A2_BANCO , SA21.A2_NOME A2_NOME	, SA21.A2_TIPO A2_TIPO					 "
If DTR->(ColumnPos('DTR_FOROPE')) > 0 .And. DTR->(ColumnPos('DTR_LOJOPE')) > 0
	cQuery += "		,	DTR.DTR_FOROPE, DTR.DTR_LOJOPE	 															 " 
EndIf
cQuery += "		FROM " 			+ RetSqlName('DTX') + " DTX "
cQuery += "		INNER JOIN " 	+ RetSqlName('DTR') + " DTR "
cQuery += "			ON	DTR.DTR_FILIAL = '" 	+ FwxFilial('DTR') +	"' "
cQuery += "			AND DTR.DTR_FILORI = DTX.DTX_FILORI "
cQuery += "			AND DTR.DTR_VIAGEM = DTX.DTX_VIAGEM "
cQuery += "			AND DTR.D_E_L_E_T_ = ' ' "
cQuery += "		LEFT JOIN " 	+ RetSqlName('DEG') + " DEG "
cQuery += "			ON 	DEG.DEG_FILIAL	= '" 	+ FwxFilial('DEG') +	"' "
cQuery += "			AND DEG.DEG_CODOPE	= DTR.DTR_CODOPE "
cQuery += "			AND DEG.D_E_L_E_T_	= ' '	"
cQuery += "		LEFT JOIN "		+ RetSqlName('SA2') + " SA21 " 
cQuery += "			ON  SA21.A2_FILIAL 	= '" 	+ FwxFilial('DEG') +	"' "
cQuery += "			AND SA21.A2_COD 	= DTR.DTR_FOROPE "
cQuery += "			AND SA21.A2_LOJA 	= DTR.DTR_LOJOPE "
cqUery += "			AND SA21.D_E_L_E_T_ = ' ' 	"
cQuery += "		LEFT JOIN " 	+ RetSqlName('SA2') + " SA2 "
cQuery += "			ON 	SA2.A2_FILIAL	= '" 	+ FwxFilial('SA2') +	"' "
cQuery += "			AND SA2.A2_COD		= DEG.DEG_CODFOR "
cQuery += "			AND SA2.A2_LOJA		= DEG.DEG_LOJFOR "
cQuery += "			AND SA2.D_E_L_E_T_	= ' '	"
cQuery += "		INNER JOIN " 	+ RetSqlname('DTY') + " DTY "
cQuery += "			ON DTY.DTY_FILIAL	= '" 	+ FwxFilial('DTY') +	"' "
cQuery += "			AND DTY.DTY_FILORI	= DTX.DTX_FILORI "
cQuery += "			AND DTY.DTY_VIAGEM	= DTX.DTX_VIAGEM "
cQuery += "			AND DTY.DTY_NUMCTC	= DTX.DTX_NUMCTC "
cQuery += "			AND DTY.D_E_L_E_T_	= ' ' "
cQuery += "		LEFT JOIN "		+ RetSqlname('DVP')	+ " DVP "
cQuery += "			ON	DVP.DVP_FILIAL = '" 	+ FwxFilial('DVP') +	"' "
cQuery += "			AND DVP.DVP_FILORI = DTY.DTY_FILORI "		
cQuery += "			AND DVP.DVP_VIAGEM = DTY.DTY_VIAGEM "	
cQuery += "			AND DVP.DVP_NUMCTC = DTY.DTY_NUMCTC "
cQuery += "			AND DVP.DVP_CODPAS <> '" + 'TF'		+  "'"
cQuery += "			AND DVP.D_E_L_E_T_ = ' ' "
cQuery += "		LEFT JOIN "		+ RetSqlName('DT3') + " DT3 "
cQuery += "			ON	DT3.DT3_FILIAL = '" 	+ FwxFilial('DT3') + 	"' "
cQuery += "			AND DT3.DT3_CODPAS = DVP.DVP_CODPAS "
cQuery += "			AND DT3.D_E_L_E_T_ = ' ' "	
cQuery += "		WHERE 	DTX.D_E_L_E_T_ = ' ' "		
cQuery += "		AND 	DTX.DTX_FILMAN = '" + cFilManife + 	"' "
cQuery += "		AND 	DTX.DTX_MANIFE = '" + cManifesto + 	"' "
cQuery := ChangeQuery(cQuery)

DBUseArea(.T.,'TOPCONN', TcGenqry(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->(!Eof()) 
	If !Empty((caliasQry)->DEG_CNPJOP)
		cCnpjOpe := (caliasQry)->DEG_CNPJOP
		cAgencia := (caliasQry)->DEG_AGENCIA
		cBanco 	 := (caliasQry)->DEG_BANCO
		cTipo    := (cAliasQry)->DEG_TIPO
		cNome 	 := (cAliasQry)->DEG_NOME
	Else
		cCnpjOpe := (caliasQry)->A2_CGC
		cAgencia := (caliasQry)->A2_AGENCIA
		cBanco 	 := (caliasQry)->A2_BANCO	
		cTipo    := (cAliasQry)->A2_TIPO
		cNome 	 := (cAliasQry)->A2_NOME
	EndIf	
	If Len(aDadosPgFr) = 0
		AADD(aDadosPgFr,{ cNome, cTipo, cCnpjOpe, cAgencia, cBanco, ;
						 (cAliasQry)->DTY_VALFRE, (cAliasQry)->DTY_ADIFRE, (cAliasQry)->DTY_IRRF    , (caliasQry)->DTY_SEST , ; 
						 (cAliasQry)->DTY_INSS  , (cAliasQry)->DTY_ISS	 , (cAliasQry)->DTY_PIS		, (cAliasQry)->DTY_COFINS, (cAliasQry)->DTY_CSLL })
		nQtdINf := Len(aDadosPgFr[1])
	EndIf		
	If Len(aDadosPgFr[1]) == nQtdInf
		If (cAliasQry)->DTY_VALPDG > 0
			AADD(aDadosPgFr[Len(aDadosPgFr)],{{'01', , Alltrim(NoAcentoCte(FWX3Titulo('DTY_VALPDG'))),(cAliasQry)->DTY_VALPDG}}) //--"Vale Pedágio"			
		EndIf
		
		If (cAliasQry)->DTY_IRRF > 0
			If Len(aDadosPgFr[1]) == nQtdInf
				AADD(aDadosPgFr[Len(aDadosPgFr)],{{'02', , AllTrim(NoacentoCte(FWX3Titulo('DTY_IRRF'))),(cAliasQry)->DTY_IRRF}}) //--"IRRF"			
			Else
				AADD(aDadosPgFr[Len(aDadosPgFr),nQtdInf+1],{'02', , Alltrim(NoacentoCte(FWX3Titulo('DTY_IRRF'))) ,(cAliasQry)->DTY_IRRF})	
			EndIf	
		EndIf	

		If (cAliasQry)->DTY_SEST > 0
			If Len(aDadosPgFr[1]) == nQtdInf
				AADD(aDadosPgFr[Len(aDadosPgFr)],{{'02', , Alltrim(NoacentoCte(FWX3Titulo('DTY_SEST'))),(cAliasQry)->DTY_SEST}}) //--"SEST"			
			Else	
				AADD(aDadosPgFr[Len(aDadosPgFr),nQtdInf+1],{'02', , AllTrim(NoacentoCte(FWX3Titulo('DTY_SEST'))) ,(cAliasQry)->DTY_SEST})	
			Endif	
		EndIf	
		
		If (cAliasQry)->DTY_INSS > 0
			If Len(aDadosPgFr[1]) == nQtdInf
				AADD(aDadosPgFr[Len(aDadosPgFr)],{{'02', , AllTrim(NoacentoCte(FWX3Titulo('DTY_INSS'))),(cAliasQry)->DTY_INSS}}) //--"INSS"
			Else	
				AADD(aDadosPgFr[Len(aDadosPgFr),nQtdInf+1],{'02', , AllTrim(NoacentoCte(FWX3Titulo('DTY_INSS'))) ,(cAliasQry)->DTY_INSS})	
			EndIf	
		EndIf	
		
		If (cAliasQry)->DTY_ISS > 0
			If Len(aDadosPgFr[1]) == nQtdInf
				AADD(aDadosPgFr[Len(aDadosPgFr)],{{'02', , AllTrim(NoacentoCte(FWX3Titulo('DTY_ISS'))),(cAliasQry)->DTY_ISS}}) //--"ISS"							
			Else	
				AADD(aDadosPgFr[Len(aDadosPgFr),nQtdInf+1],{'02', , AllTrim(NoacentoCte(FWX3Titulo('DTY_ISS'))) ,(cAliasQry)->DTY_ISS})	
			EndIf	
		EndIf	
		
		If (cAliasQry)->DTY_TAXBAN > 0
			If Len(aDadosPgFr[1]) == nQtdInf
				AADD(aDadosPgFr[Len(aDadosPgFr)],{{'03', , AllTrim(NoacentoCte(FWX3Titulo('DTY_TAXBAN'))),(cAliasQry)->DTY_TAXBAN}}) //--"Taxa Bancaria"							
			Else	
				AADD(aDadosPgFr[Len(aDadosPgFr),nQtdInf+1],{'03', , AllTrim(NoacentoCte(FWX3Titulo('DTY_TAXBAN'))) ,(cAliasQry)->DTY_TAXBAN})	
			EndIf	
		EndIf				
		
		If (cAliasQry)->DVP_VALPAS > 0
			If Len(aDadosPgFr[1]) == nQtdInf
				AADD(aDadosPgFr[Len(aDadosPgFr)],{{'99', (cAliasQry)->DVP_CODPAS, AllTrim(NoacentoCte((cAliasQry)->(DT3_DESCRI))),(cAliasQry)->DVP_VALPAS}}) //--"Valor Componente
			Else	
				AADD(aDadosPgFr[Len(aDadosPgFr),nQtdInf+1],{'99',(cAliasQry)->DVP_CODPAS, AllTrim(NoacentoCte((cAliasQry)->(DT3_DESCRI))),(cAliasQry)->DVP_VALPAS})	
			EndIf	
		EndIf					
	Else
		AADD(aDadosPgFr[Len(aDadosPgFr),nQtdInf+1],{'99',(cAliasQry)->DVP_CODPAS, AllTrim(NoacentoCte((cAliasQry)->(DT3_DESCRI))),(cAliasQry)->DVP_VALPAS})
	EndIf	

	(cAliasQry)->(dbSkip())	

EndDo	

(cAliasQry)->(dbCloseArea())

Return aDadosPgFr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TME73UpdPT  ³ Autor ³ Felipe Barbiere     ³ Data ³27.03.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualizacao do Evento de Pagamento da Operação de Transporte³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TME73UpdPT(aListBox)
Local cSeek       := ''
Local nI := 0
Local cQuery 	:= ""
Local cMsg 	:= ""
Local cStat 	:= ""
Local aDTXArea := DTX->(GetArea())

DTX->(dbSetOrder(7))
	For nI := 1 To Len(aListBox)
		cMsg  := ""
		cStat := ""
		cSeek := xFilial('DTX')+cFilAnt+Substr(aListBox[nI][3],9,44)
		
		If	DTX->(MsSeek(cSeek))
	   		If aListBox[nI][5] == "1"
	   			cMsg := "Envio de Evento realizado - Aguardando processamento"
	   		Else
	   			cMsg := aListBox[nI][7] + ' - ' + aListBox[nI][6]
	   		EndIf

	   		If aListBox[nI][5] == "3" .Or. aListBox[nI][5] == "5"
				cStat := "3"  //Evento rejeitado +msg rejeiçao 
			ElseIf aListBox[nI][5] == "6"
				cStat := "2"  //Evento vinculado com sucesso
			ElseIf aListBox[nI][5] == "1"
				cStat := "1"  //Envio de Evento realizado - Aguardando processamento
			EndIF

	   		cQuery := " UPDATE " + RetSqlName("DLI") + " SET DLI_STAEVE = '" + cStat + "', "
	   		cQuery += " DLI_DESEVE = '" + cMsg + "'"
			If cStat == '2' //Evento vinculado com sucesso
				cQuery += ", DLI_DTEVEN = '" + DToS(dDataBase) + "', "
				cQuery += " DLI_HREVEN = '" + StrTran(Left(Time(),5),':','') + "'"
			EndIf
			cQuery += " WHERE DLI_FILIAL = '" + xFilial("DLI") + "'"
			cQuery += " AND DLI_MANIFE = '" + DTX->DTX_MANIFE + "'"
			cQuery += " AND DLI_SERMAN = '" + DTX->DTX_SERMAN + "'"
			cQuery += " AND DLI_FILMAN = '" + DTX->DTX_FILMAN + "'"
			cQuery += " AND DLI_CODEVE = '" + '116' + "'"			
			cQuery += " AND DLI_SEQEVE = '" + Substr(aListBox[nI][3],53,2) + "'"
			cQuery += " AND DLI_STAEVE <> '2' AND D_E_L_E_T_ =  ' '"
			TCSqlExec( cQuery )
	    EndIf
	Next nI
	
RestArea(aDTXArea)

Return nil

/*/-----------------------------------------------------------
{Protheus.doc} TME73LIC
Função para retornar a cor da legenda de acordo o tipo de 
transmissão a ser realizada.

Uso: TMSAE73

@author Rodrigo.Pirolo 
@since 24/09/2020
@version 1.0
-----------------------------------------------------------/*/

Static Function TME73LIC( lEnvia ,lVisual, lCancela, lInCond, cSTMDFE, oAzul, oAmarelo, oVerde, oVermelho )

Local oRetCor		:= {}

DEFAULT lEnvia		:= .F.
DEFAULT lVisual		:= .F.
DEFAULT lCancela	:= .F.
DEFAULT lInCond		:= .F.
DEFAULT cSTMDFE		:= ""
DEFAULT oAzul		:= LoadBitmap( GetResources( ), 'BR_AZUL'	)
DEFAULT oAmarelo	:= LoadBitmap( GetResources( ), 'BR_AMARELO')
DEFAULT oVerde		:= LoadBitmap( GetResources( ), 'BR_VERDE'	)
DEFAULT oVermelho	:= LoadBitmap( GetResources( ), 'BR_VERMELHO')

If lEnvia .OR. ( lVisual .AND. !lCancela )
	oRetCor := oAzul

// Se for Inclusão de Condutor é necessario olhar o status no campo DUP_STMDFE na tabela DUP
ElseIf lInCond
	If cSTMDFE == StrZero( 0, Len(DUP->DUP_STMDFE) )	//0=Nao Transmitido
		oRetCor := oAmarelo
	ElseIf cSTMDFE == StrZero( 1, Len(DUP->DUP_STMDFE) ) .OR. cSTMDFE == StrZero(2,Len(DUP->DUP_STMDFE))//1=Enviado para Transmissão 2=Envio Evento realizado
		oRetCor := oVerde
	ElseIf cSTMDFE == StrZero( 3, Len(DUP->DUP_STMDFE) )//3=Evento vinculado com sucesso
		oRetCor := oAzul
	ElseIf cSTMDFE == StrZero( 4, Len(DUP->DUP_STMDFE) )//4=Evento rejeitado
		oRetCor := oVermelho
	EndIf
EndIf

Return oRetCor
