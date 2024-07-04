
/*
Programa        : EECFATCP
Objetivo        : Nota Fiscal Despesa/Nota Complemento Embarque
Autor           : Cristiano A. Ferreira `
Data/Hora       : 23/06/2000 14:50
Obs.            :
 Define Array contendo as Rotinas a executar do programa  
 ----------- Elementos contidos por dimensao ------------ 
 1. Nome a aparecer no cabecalho                          
 2. Nome da Rotina associada                              
 3. Usado pela rotina                                     
 4. Tipo de Transacao a ser efetuada                      
    1 - Pesquisa e Posiciona em um Banco de Dados         
    2 - Simplesmente Mostra os Campos                     
    3 - Inclui registros no Bancos de Dados               
    4 - Altera o registro corrente                        
    5 - Remove o registro corrente do Banco de Dados      
    6 - Altera determinados campos sem incluir novos Regs 
*/
*--------------------------------------------------------------------
#INCLUDE "EECFATCP.ch"
#include "EECRDM.CH"
#include "EEC.CH"

#define TITULO STR0001 //"Solicitação de N.F. Complementar"
*--------------------------------------------------------------------
FUNCTION EECFATCC
	LOCAL aCORES  := {{"EMPTY(EEC_DTEMBA)  .OR.  EEC_STATUS =  '"+ST_PC+"'","DISABLE" },;  //PROCESSO NAO EMBARCADO OU CANCELADO
	{"!EMPTY(EEC_DTEMBA) .AND. EEC_STATUS <> '"+ST_PC+"'","ENABLE"}}     //PROCESSO EMBARCADO

	If EasyEntryPoint("EECFATCP")
		ExecBlock("EECFATCP",.F.,.F.)
  /*
		If FindFunction("U_EECFATCP")
      U_EECFATCP()
      */
		Else

			PRIVATE cCADASTRO := STR0030 //"Nota Fiscal Complementar"
			Private aRotina := MenuDef()

			PRIVATE aCab,aReg,aItens,aDados // By JPP - 29/09/2005 - 15:40

			//THTS - 27/06/2017 - Nao executa a rotina se o ambiente nao estiver integrado ao faturamento do protheus
			If EasyGParam("MV_EECFAT",,.F.) == .T.
				DBSELECTAREA("EEC")
				EEC->(DBSETORDER(1))
				MBROWSE(6,01,22,75,"EEC",,,,,,aCORES)
			Else
				EasyHelp(STR0056 + ENTER + STR0057 ,STR0034)////"Esta rotina só poderá ser utilizada com ambientes integrados ao faturamento do Protheus."###"Para utilizar a rotina, habilite o parâmetro MV_EECFAT."####Atenção
      /* Funcao comentada para ser utilizada no proximo Release 12.1.18, quando os dicionarios ja estiverem em banco de dados.
      Help(" ",1,"EECFATCP01") //Esta rotina só poderá ser utilizada com ambientes integrados ao faturamento do  Protheus (MV_EECFAT).####Para utilizar a rotina, habilite o parâmetro MV_EECFAT.
      */
			EndIf
		EndIf

		RETURN(NIL)

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 30/01/07 - 10:51
*/
Static Function MenuDef()
	Local aRotAdic := {}
	Local aRotina  := {}

//AMS - 10/01/2006. Tratamento para apresentar a opção de NFC Câmbio, quando existir os campos.

	aRotina := {{STR0031        ,"AxPesqui"  , 0, 1},; //"Pesquisar"
	{"NFC &Despesas","FATCPNFC", 0, 2},; //Nota Fiscal Complementar de Despesa
	{"NFC Embarque ","FATCPNFC", 0, 2},; //Nota Fiscal Complementar de Embarque
	{"NFC C&ambio  ","NFCAMBIO", 0, 4},; //Nota Fiscal Complementar de Câmbio
	{STR0019        ,"FATCPLEG", 0, 2,,.F.}}  //"Legenda"


// P.E. utilizado para adicionar itens no Menu da mBrowse
	If EasyEntryPoint("EFATCPMNU")
		aRotAdic := ExecBlock("EFATCPMNU",.f.,.f.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf

Return aRotina
//nP_OPC = 4: câmbio; nP_OPC = 2: despesas; nP_OPC = 3: embarque
	*--------------------------------------------------------------------
FUNCTION FATCPNFC(cP_ALIAS,nP_REG,nP_OPC)
	LOCAL oDLG,oBTNOK,oBTNCANCEL,I,;
		aORDANT := SaveOrd({"EE9","SA1","SA2","EEM","EE7","SD2"}),;
		cTITULO := cCADASTRO+IF(nP_OPC=3," - Embarque",STR0032),; //" - Despesas"
	bOK     := {||IIF(ValidOK(nP_OPC),(nOpc:=1,oDlg:End()),)},;
		bCANCEL := {||nOpc:=0,oDlg:End()},;
		nOPC    := 0
	Local aIensComplemtar:= {}
	Local aNFsGeradas:= {}, cNFsGeradas:= "", cNFsEstorn := ""
	Local nCont:= 0, nCont2:= 0, cChavPedVen
	Private cTMPDESP
//PRIVATE aCab,aReg,aItens,;
	Private lEstEmb     := .f., lEstDes  := .f., lEstorna := .f.,;
		cTIPOOPC    := STR(nP_OPC-1,1,0),;
		INCLUI      := .T.,;
		lMSErroAuto := .F.,;
		lMSHelpAuto := .F.,;  // para mostrar os erros na tela
	cPedFat     := "",;
		cMSGCONF    := ""
	*
	BEGIN SEQUENCE
		EEC->(RECLOCK("EEC",.F.))
		FOR I := 1 TO EEC->(FCOUNT())
			M->&(EEC->(FIELDNAME(I))) := EEC->(FIELDGET(I))
		NEXT
		If EasyGParam("MV_AVG0196",,.f.)
			cTMPDESP := CriaTmpDesp()
		EndIf
		IF M->EEC_STATUS = ST_PC
			MSGINFO(STR0038 ,STR0034) //"O processo está cancelado."###"Atenção"
			BREAK
		ELSEIF FATCVLDESP() = 0 .AND. nP_OPC # 3  //3.embarque
			If EasyGParam("MV_AVG0196",,.f.)
				EasyHelp(STR0035,STR0034,STR0061)//"Verifique se o Embarque possui Despesas Internacionais (EXL)."
			Else
				MSGINFO(STR0035,STR0034) //"Processo não possui despesas."###"Atenção"
			EndIf
			BREAK
		ELSEIF FATCVLDESP() > 0 .AND. nP_OPC # 3
			If Empty(EEC->EEC_PEDDES) .And. !lEstorna
				SYJ->(DbSetorder(1))
				SYJ->(DbSeek(xFilial("SYJ")+EEC->EEC_INCOTE))
				If (SYJ->YJ_CLFRETE = "1" .And. Empty(EEC->EEC_FRPREV) ) .Or. (SYJ->YJ_CLSEGUR = "1" .And. Empty(EEC->EEC_SEGPRE))
					If !MsgYesNo(STR0039 +; //"O INCOTERMS utilizado prevê lançamento de Despesas que ainda não foram lançadas no processo."
						STR0040,; //"Deseja prosseguir com a geração da Nota Fiscal Complementar de Embarque?"
						STR0009)
						Break
					EndIf
				EndIf
		    EndIf

		ELSEIF FATCVLDESP() < 0 .AND. nP_OPC = 2  //2.DESPESA
			MSGINFO(STR0036,STR0009) //"Processo com variação de despesas negativa."###"Aviso"
			BREAK
		ENDIF
		EE9->(dbSetOrder(2))
		SA1->(dbSetOrder(1))
		SA2->(dbSetOrder(1))
		EEM->(dbSetOrder(1))
		EE7->(dbSetOrder(1))
		LOADGETS()
		nColSayGets := 115
		DEFINE MSDIALOG oDLG TITLE cTITULO FROM 0,0 TO 300,700 OF oMainWnd PIXEL

		oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop))

		@ 05,02+nColSayGets TO 100,123+nColSayGets PIXEL of oPanel
		*
		@ 15,05+nColSayGets SAY AVSX3("EEC_PREEMB",AV_TITULO) PIXEL of oPanel
		@ 15,50+nColSayGets MSGET EEC->EEC_PREEMB PICTURE AVSX3("EEC_PREEMB",AV_PICTURE) WHEN(.F.) SIZE /*53*/70,08 PIXEL of oPanel
		*
		@ 26,05+nColSayGets SAY AVSX3("EEC_DTEMBA",AV_TITULO) PIXEL of oPanel
		@ 26,50+nColSayGets MSGET EEC->EEC_DTEMBA PICTURE AVSX3("EEC_DTEMBA",AV_PICTURE) WHEN(.F.) SIZE 50,08 PIXEL of oPanel HASBUTTON
		*
		@ 37,05+nColSayGets SAY AVSX3("EEC_SEGPRE",AV_TITULO) PIXEL of oPanel
		@ 37,50+nColSayGets MSGET GetVlComp("SEGURO") PICTURE AVSX3("EEC_SEGPRE",AV_PICTURE) WHEN(.F.) SIZE 50,08 PIXEL of oPanel HASBUTTON
		*
		If EasyGParam("MV_AVG0196",,.f.) //Com o parametro habilitado, sera exibido o valor do frete e frete adicional em um unico campo
			@ 48,05+nColSayGets SAY AVSX3("EEC_FRPREV",AV_TITULO) PIXEL of oPanel 
			@ 48,50+nColSayGets MSGET GetVlComp("FRETE_TOTAL") PICTURE AVSX3("EEC_FRPREV",AV_PICTURE) WHEN(.F.) SIZE 50,08 PIXEL of oPanel HASBUTTON
			
			@ 59,05+nColSayGets SAY AVSX3("EEC_DESPIN",AV_TITULO) PIXEL of oPanel
			@ 59,50+nColSayGets MSGET GetVlComp("DESPESA_INTERNA") PICTURE AVSX3("EEC_DESPIN",AV_PICTURE) WHEN(.F.) SIZE 50,08 PIXEL of oPanel HASBUTTON
		Else
			@ 48,05+nColSayGets SAY AVSX3("EEC_FRPREV",AV_TITULO) PIXEL of oPanel
			@ 48,50+nColSayGets MSGET GetVlComp("FRETE") PICTURE AVSX3("EEC_FRPREV",AV_PICTURE) WHEN(.F.) SIZE 50,08 PIXEL of oPanel HASBUTTON
			*
			@ 59,05+nColSayGets SAY AVSX3("EEC_FRPCOM",AV_TITULO) PIXEL of oPanel
			@ 59,50+nColSayGets MSGET GetVlComp("FRETE_ADICIONAL") PICTURE AVSX3("EEC_FRPCOM",AV_PICTURE) WHEN(.F.) SIZE 50,08 PIXEL of oPanel HASBUTTON
			*
			@ 70,05+nColSayGets SAY AVSX3("EEC_DESPIN",AV_TITULO) PIXEL of oPanel
			@ 70,50+nColSayGets MSGET GetVlComp("DESPESA_INTERNA") PICTURE AVSX3("EEC_DESPIN",AV_PICTURE) WHEN(.F.) SIZE 50,08 PIXEL of oPanel HASBUTTON
		EndIf

		// @ 81,05 SAY AVSX3("EEC_DESCON",AV_TITULO) PIXEL  // By JPP - 07/07/2005 - 15:55
		// @ 81,50 MSGET EEC->EEC_DESCON PICTURE AVSX3("EEC_DESCON",AV_PICTURE) WHEN(.F.) SIZE 50,08 PIXEL
		*
		@ 103,05+nColSayGets SAY cMSGCONF PIXEL of oPanel
		//DEFINE SBUTTON oBtnOk     FROM 113,040 TYPE 1 ACTION Eval(bOk)     ENABLE  of oPanel//OF oDlg
		//DEFINE SBUTTON oBtnCancel FROM 113,080 TYPE 2 ACTION Eval(bCancel) ENABLE  of oPanel//OF oDlg
		*
		oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,)  CENTERED
		IF nOPC = 0
			BREAK
		ENDIF
		// processamento principal
		Begin Transaction
			if Left(cTipoOpc,1) == "1"
				lEstorna := lEstDes
				IF lEstorna
					cPedFat := EEC->EEC_PEDDES
				Endif
				bAction := {|| lRet := GrvNF_Desp() }
				cTitle  := STR0002 //"N.Fiscal Despesa"
			elseif Left(cTipoOpc,1) == "2"
				lEstorna := lEstEmb
				IF lEstorna
					cPedFat := EEC->EEC_PEDEMB
				Endif
				bAction := {|| lRet := GrvComplEmbarq() }
				cTitle  := STR0003 //"N.F. Compl. Cambial"
			endif
			IF lEstorna
				SD2->(dbSetOrder(8))
				cChavPedVen := xFilial("SD2") + AvKey(cPedFat,"D2_PEDIDO")
				Do While SD2->(dbSeek(cChavPedVen))
					aDados := {}
					aAdd(aDados,{"EEM_TIPOCA","N"            ,nil}) // Nota Fiscal (obrigatorio)
					aAdd(aDados,{"EEM_PREEMB",EEC->EEC_PREEMB,nil}) // Nro.do Embarque (obrigatorio)
					aAdd(aDados,{"EEM_TIPONF","2"            ,nil}) // Tipo de Nota 2-Complementar (obrigatorio)
					aAdd(aDados,{"EEM_NRNF"  ,SD2->D2_DOC    ,nil}) // (obrigatorio)
					aAdd(aDados,{"EEM_SERIE" ,SD2->D2_SERIE  ,nil})
					EECFATNF({aDados,5})
					aCab := {}
					aAdd(aCab,{"F2_DOC"  ,SD2->D2_DOC  ,nil})
					aAdd(aCab,{"F2_SERIE",SD2->D2_SERIE,nil})
					Mata520(aCab)
					cNFsEstorn += "Nota: "+ SD2->D2_DOC +" Série:"+ SD2->D2_SERIE + Chr(13) + Chr(10)
				EndDo
			Endif
			MsAguarde(bAction,cTitle)
			IF ! lMSErroAuto .AND. ! lEstorna

				aIensComplemtar:= AgrupaNFs()

				cSerieNF := EasyGParam("MV_EECSERI")
				SF2->(DBSETORDER(1))
				For nCont:= 1 to Len(aIensComplemtar)

					aNFsGeradas:= {}
					EECIncNFC(aCAB[1,2],cSerieNF,EEC->EEC_PREEMB, @aNFsGeradas, aIensComplemtar[nCont][2])

					For nCont2:= 1 to Len(aNFsGeradas)
						SF2->(DBSEEK(XFILIAL("SF2") + AVKEY(aNFsGeradas[nCont2][2], "F2_DOC") + AVKEY(aNFsGeradas[nCont2][1], "F2_SERIE")))
						aDados := {}
						aAdd(aDados,{"EEM_TIPOCA","N"            ,nil}) // Nota Fiscal (obrigatorio)
						aAdd(aDados,{"EEM_PREEMB",EEC->EEC_PREEMB,nil}) // Nro.do Embarque (obrigatorio)
						aAdd(aDados,{"EEM_TIPONF","2"            ,nil}) // Tipo de Nota 2-Complementar (obrigatorio)
						aAdd(aDados,{"EEM_NRNF"  ,SF2->F2_DOC    ,nil}) // (obrigatorio)
						aAdd(aDados,{"EEM_SERIE" ,SF2->F2_SERIE  ,nil})
						aAdd(aDados,{"EEM_DTNF"  ,SF2->F2_EMISSAO,nil})
						aAdd(aDados,{"EEM_VLNF"  ,SF2->F2_VALBRUT,nil}) // (obrigatorio)
						aAdd(aDados,{"EEM_VLMERC",SF2->F2_VALMERC,nil}) // (obrigatorio)
						aAdd(aDados,{"EEM_VLFRET",SF2->F2_FRETE  ,nil})
						aAdd(aDados,{"EEM_VLSEGU",SF2->F2_SEGURO ,nil})
						aAdd(aDados,{"EEM_OUTROS",SF2->F2_DESPESA,nil})
						EECFATNF({aDados,3})

						cNFsGeradas += aNFsGeradas[nCont2][2] + Chr(13) + Chr(10)
					Next
				Next
				MsgInfo(STR0008 + Chr(13) + Chr(10) + cNFsGeradas, STR0009) //"Número da Nota Fiscal de Complemento de Preço: "###"Aviso"
			Endif
		End Transaction
	End Sequence
	If Select("cTMPDESP") > 0
		(cTMPDESP)->(dbCloseArea())
	EndIf
	RestOrd(aORDANT)
	DBSELECTAREA("EEC")
RETURN(NIL)
	*--------------------------------------------------------------------
FUNCTION FATCPLEG(cP_ALIAS,nP_REG,nP_OPC)
	BRWLEGENDA(cCADASTRO,STR0019,{{"ENABLE" ,STR0020},; //"Legenda"###"Processos embarcados"
	{"DISABLE",STR0021}}) //"Processos não embarcados"
RETURN(NIL)
	*--------------------------------------------------------------------
Static Function LoadGets()
	Local lRet := .t.,WVLDES := 0
	WVLDES := FATCVLDESP()
	*** CONFIGURA BOTAO DA NFC CAMBIO ***
	IF cTIPOOPC = "2"
		IF ! Empty(M->EEC_PEDEMB)
			cMSGCONF := STR0059 //"Confirma o estorno da NFC de Embarque ?"
			lEstEmb  := .t.
		Else
			cMSGCONF := STR0058 //"Confirma a geração da NFC de Embarque ?"
			lEstEmb  := .f.
		Endif
	ENDIF
	*** CONFIGURA BOTAO DA NFC DESPESAS ***
	IF cTIPOOPC = "1"
		IF EMPTY(M->EEC_PEDDES)
			cMSGCONF := STR0024 //"Confirma a geração da NFC de despesas ?"
			lEstDes  := .F.
		ELSE
			cMSGCONF := STR0025 //"Confirma o estorno da NFC de despesas ?"
			lEstDes  := .T.
		ENDIF
	ENDIF
Return(lRet)
	*--------------------------------------------------------------------
/*
Funcao      : GrvNF_Desp
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Gravacao da Nota Fiscal de Despesa
Autor       : Cristiano A. Ferreira
Data/Hora   : 03/03/2000 10:20
Revisao     :
Obs.        :
*/
Static Function GrvNF_Desp
	Local nDespTot := FATCVLDESP(),;
		nTotal   := nDesp := 0,;
		cItem, cCondPag, nLen, nPosRec, nPosTot,;
		nTxDesp, lConvUnid // By JPP - 04/07/2005 - 11:15

	Local aOrd := SaveOrd({"EE8"})

	MsProcTxt(STR0016) //"Em Processamento ..."
// aCab por dimensao:
// aCab[n][1] := Nome do Campo
// aCab[n][2] := Valor a ser gravado no campo
// aCab[n][3] := Regra de Validacao, se NIL considera do dicionario
	aCab   := {}
	aItens := {}
	aReg   := {}
	Begin Sequence
		If lEstorna  // By JPP - 04/07/2005 - 11:15
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+EEC->EEC_PEDDES))
				nTxDesp  := BuscaTaxa(EEC->EEC_MOEDA,SC5->C5_EMISSAO)
			Else
				nTxDesp  := BuscaTaxa(EEC->EEC_MOEDA,dDataBase)
			EndIf
		Else
			nTxDesp  := BuscaTaxa(EEC->EEC_MOEDA,dDataBase)
		EndIf
		lConvUnid := (EEC->(FieldPos("EEC_UNIDAD")) # 0) .And. (EE9->(FieldPos("EE9_UNPES")) # 0) .And.;
			(EE9->(FieldPos("EE9_UNPRC"))  # 0)
		If EasyGParam("MV_AVG0196",,.f.)
			nDespTot := GetVlComp("FRETE_TOTAL") + GetVlComp("SEGURO") + GetVlComp("DESPESA_INTERNA")
		EndIf
		IF nDespTot <= 0
			HELP(" ",1,"AVG0005027") //MsgInfo("Não há despesas cadastradas !","Aviso")
			lMSErroAuto := .t.
			Break
		Endif
		SD2->(dbSetOrder(8))
		IF ! lEstorna
			aAdd(aCab,{"C5_NUM",GetSXENum("SC5"),nil}) // Nro.do Pedido
		Else
			IF SD2->(dbSeek(xFilial()+AvKey(EEC->EEC_PEDDES,"D2_PEDIDO")))
				MsgInfo(STR0017+Transf(EEC->EEC_PEDDES,AVSX3("C6_NUM",6))+STR0018,STR0009) //"Pedido Nro. "###" já Faturado !"###"Aviso"
				lMSErroAuto := .t.
				Break
			Endif
			aAdd(aCab,{"C5_NUM",EEC->EEC_PEDDES,nil})
		Endif
		aAdd(aCab,{"C5_PEDEXP",EEC->EEC_PREEMB,nil}) // Nro.Embarque
		aAdd(aCab,{"C5_TIPO","C",nil}) //Tipo de Pedido - "C"-Compl.Preco
		aAdd(aCab,{"C5_TPCOMPL","1",nil})//1-Preco #### THTS - 27/06/2017 - TE-6014 - Campo obrigatorio para nota complementar.
		IF ! SA1->(dbSeek(xFilial()+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))
			HELP(" ",1,"AVG0005023") //MsgInfo("Importador não cadastrado !","Aviso")
			lMSErroAuto := .t.
			Break
		Endif
		aAdd(aCab,{"C5_CLIENTE",SA1->A1_COD,nil})  //Cod. Cliente
		aAdd(aCab,{"C5_LOJACLI",SA1->A1_LOJA,nil}) //Loja Cliente
		aAdd(aCab,{"C5_TIPOCLI","X",nil}) //Tipo Cliente
		cCondPag := Posicione("SY6",1,xFilial("SY6")+EEC->EEC_CONDPA+AvKey(EEC->EEC_DIASPA,"Y6_DIAS_PA"),"Y6_SIGSE4")
		IF Empty(cCondPag)
			HELP(" ",1,"AVG0005028") //MsgInfo("O campo Cond.Pagto no SIGAFAT não foi preenchido !","Aviso")
			lMSErroAuto := .t.
			Break
		Endif
		aAdd(aCab,{"C5_CONDPAG",cCondPag,nil})
		///aAdd(aCab,{"C5_TABELA","1",nil}) // Tabela de preco - Tabela 1
		//aAdd(aCab,{"C5_MOEDA",POSICIONE("SYF",1,XFILIAL("SYF")+EEC->EEC_MOEDA,"YF_MOEFAT"),nil}) // By JPP - 04/07/2005 - 11:15 - Será passado valores convertidos em Reais.
		aItens := {}
		cItem  := "01"
		//efetuar rateio da despesa total
		EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))
		DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And.;
				EE9->EE9_PREEMB == EEC->EEC_PREEMB
			*
			If lConvUnid // By JPP - 04/07/2005 - 11:15 - Efetuar a Conversão de unidade de medida.
				nTotal :=nTotal + (AvTransUnid(EE9->EE9_UNIDAD,EE9->EE9_UNPRC,EE9->EE9_COD_I,;
					EE9->EE9_SLDINI,.F.) * EE9->EE9_PRECO)
			Else
				nTotal := nTotal + (EE9->EE9_SLDINI * EE9->EE9_PRECO)
			EndIf
			//nTotal := nTotal+(EE9->EE9_SLDINI*EE9->EE9_PRECO)
			EE9->(dbSkip())
		Enddo

		nDespTot := nDespTot * nTxDesp  // By JPP - 04/07/2005 - 11:15 - Conversão dos valores para reais.
		nTotal := nTotal * nTxDesp

		EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))
		DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And.;
				EE9->EE9_PREEMB == EEC->EEC_PREEMB
			*
			If lConvUnid // By JPP - 04/07/2005 - 11:15 - Efetuar a Conversão de unidade de medida, antes de calcular o fator.
				nFator := (nTxDesp * (AvTransUnid(EE9->EE9_UNIDAD,EE9->EE9_UNPRC,EE9->EE9_COD_I,;
					EE9->EE9_SLDINI,.F.) * EE9->EE9_PRECO)) / nTotal
			Else
				nFator := (nTxDesp * (EE9->EE9_SLDINI*EE9->EE9_PRECO))/nTotal // CALCULA PERCENTUAL DO PRODUTO EM RELACAO A DESPESA
			EndIf
			nValorIt := nFator*nDespTot                         // CALCULA O VALOR EM DOLAR DO PRODUTO
			nDesp    := nDesp+nValorIt                          // TOTAL DAS DESPESAS EM DOLAR
			If ( EasyGParam("MV_ARREFAT")=="S" )
				nVALORIT := ROUND(nVALORIT,AVSX3("C6_VALOR",AV_DECIMAL))
			Else
				nVALORIT := NOROUND(nVALORIT,AVSX3("C6_VALOR",AV_DECIMAL))
			EndIf
			IF SB1->(dbSeek(xFilial()+EE9->EE9_COD_I)) .AND. ! SB2->(dbSeek(xFilial()+SB1->B1_COD+SB1->B1_LOCPAD))
				CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
			Endif
			aReg := {}
			aAdd(aReg,{"C6_NUM"    ,aCab[1][2],nil}) // Pedido
			aAdd(aReg,{"C6_ITEM"   ,cItem,nil}) // Item sequencial
			aAdd(aReg,{"C6_PRODUTO",EE9->EE9_COD_I ,nil}) // Cod.Item
			aAdd(aReg,{"C6_UM"     ,EE9->EE9_UNIDAD,nil}) // Unidade
			aAdd(aReg,{"C6_QTDVEN" ,1              ,nil}) // Quantidade
			aAdd(aReg,{"C6_PRCVEN" ,nValorIt       ,nil}) // Preco Unit.
			aAdd(aReg,{"C6_PRUNIT" ,nValorIt       ,nil}) // Preco Unit.
			aAdd(aReg,{"C6_VALOR"  ,nValorIt       ,nil}) // Valor Tot.

			// ** JBJ 08/10/01 - Gravação dos campos Tipo de Saida e Codigo Fiscal ... (Inicio)

			EE8->(DbSetOrder(1))
			EE8->(Dbseek(xFilial()+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
			If EE8->(FieldPos("EE8_OPER")) > 0 .And. !Empty(EE8->EE8_OPER)    
				aAdd(aReg,{"C6_OPER",EE8->EE8_OPER,nil})  //Tipo de Operação(Tes Inteligente)
			Else
				aAdd(aReg,{"C6_TES",EE8->EE8_TES,nil}) // Tipo de Saida 
				aAdd(aReg,{"C6_CF",EE8->EE8_CF,nil})  // Classificacao Fiscal 
			EndIf
			// aAdd(aReg,{"C6_TES"    ,"501"          ,nil}) // Tipo de Saida
			// aAdd(aReg,{"C6_CF"     ,"663"          ,nil})  // Classificacao Fiscal
			// ** (Fim)

			aAdd(aReg,{"C6_LOCAL"   ,SB1->B1_LOCPAD ,nil})  // Almoxarifado
			aAdd(aReg,{"C6_ENTREG"  ,dDataBase      ,nil})  // Dt.Entrega
			aAdd(aReg,{"C6_NFORI"   ,EE9->EE9_NF   ,nil})    // NF. Origem.
			aAdd(aReg,{"C6_SERIORI" ,EE9->EE9_SERIE,nil})    // Serie Origem.
			aAdd(aItens,aClone(aReg))

			cItem := SomaIt(cItem)

			IF cItem > "Z9"
				HELP(" ",1,"AVG0005026") //MsgStop("Excedeu o limite de itens do SIGAFAT !")
				Exit
			Endif

			EE9->(dbSkip())
		Enddo

		IF nDesp <> nDespTot
			IF !Empty(aItens)
				nLen    := Len(aItens)
				nPosPrc := aScan(aItens[nLen],{|x| x[1] == "C6_PRCVEN"})
				nPosTot := aScan(aItens[nLen],{|x| x[1] == "C6_VALOR"})
				nPOSPRU := aScan(aItens[nLen],{|x| x[1] == "C6_PRUNIT"})

				aItens[nLen][nPosPrc][2] := aItens[nLen][nPosPrc][2]+(nDespTot-nDesp)
				aItens[nLen][nPosTot][2] := aItens[nLen][nPosPrc][2]
				aItens[nLen][nPosPrU][2] := aItens[nLen][nPosPrU][2]+(nDespTot-nDesp)
			Endif
		Endif

		lMSErroAuto := .f.
		lMSHelpAuto := .F. // para mostrar os erros na tela

		ASORT(aItens,,, { |x, y| x[2,2] < y[2,2] })

		IF lEstorna
			Estorna_PV(EEC->EEC_PEDDES,aCab,aItens)
			MsgInfo(STR0037,STR0029)  //"Nota Fiscal Complementar de Despesa estornada !"###"Aviso !" // ** BY JBJ - 06/09/01 - 16:40
		Else
			//MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,3)
			lMSErroAuto := ! AVMata410(aCab, aItens, 3)
		Endif

		IF !lMSErroAuto
			IF !lEstorna
				EEC->(RecLock("EEC",.F.))
				EEC->EEC_PEDDES := aCAB[1,2]  // PEDIDO NO FAT
				// LCS - 20/09/2002 - SUBSTITUIDO PELA LINHA ACIMA
				//EEC->EEC_PEDDES := SC5->C5_NUM
				EEC->(MsUnlock())
			Else
				EEC->(RecLock("EEC",.F.))
				EEC->EEC_PEDDES := " "
				EEC->(MsUnlock())
			Endif
		Endif

		IF !lEstorna
			cPedFat := EEC->EEC_PEDDES
		Endif

	End Sequence

	RestOrd(aOrd)

Return(NIL)
	*--------------------------------------------------------------------
/*
Funcao      : GrvComplEmbarq
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Gravacao do Complemento de Embarque
Autor       : Cristiano A. Ferreira
Data/Hora   : 03/03/2000 10:23
*/
Static Function GrvComplEmbarq
	Local nTxEmb := BuscaTaxa(EEC->EEC_MOEDA,M->EEC_DTEMBA),;
		cCondPag, nTaxaNF, nValorIT, cItem,;
		nTxDesp := nTotDesp := nTotal := 0,;
		lTEVEVAR := .F.,;
		lConvUnid, nVarDesp := 0, nValTotal := 0, nFator // By JPP - 05/07/2005 - 08:45

	Local aOrd := SaveOrd({"EE8"})

	Local nDifPrcPed, nTxDia//RMD - 28/08/12

	MsProcTxt(STR0016) //"Em Processamento ..."
// aCab por dimensao:
// aCab[n][1] := Nome do Campo
// aCab[n][2] := Valor a ser gravado no campo
// aCab[n][3] := Regra de Validacao, se NIL considera do dicionario
	aCab   := {}
	aItens := {}
	aReg   := {}
	Begin Sequence
		lConvUnid := (EEC->(FieldPos("EEC_UNIDAD")) # 0) .And. (EE9->(FieldPos("EE9_UNPES")) # 0) .And.; // By JPP - 05/07/2005 - 08:45
		(EE9->(FieldPos("EE9_UNPRC"))  # 0)
		SD2->(dbSetOrder(8))
		IF ! lEstorna
			aAdd(aCab,{"C5_NUM",GetSXENum("SC5"),nil}) // Nro.do Pedido
		ELSEIF SD2->(dbSeek(xFilial()+AvKey(EEC->EEC_PEDEMB,"D2_PEDIDO")))
			MsgInfo(STR0017+Transf(EEC->EEC_PEDEMB,AVSX3("C6_NUM",6))+STR0018,STR0009) //"Pedido Nro. "###" já Faturado !"###"Aviso"
			lMSErroAuto := .t.
			Break
		ELSE
			AAdd(aCab,{"C5_NUM",EEC->EEC_PEDEMB,nil})
		Endif
		aAdd(aCab,{"C5_PEDEXP",EEC->EEC_PREEMB,nil})  // Nro.Embarque
		aAdd(aCab,{"C5_TIPO"  ,"C"            ,nil})  //Tipo de Pedido - "C"-Compl.Preco
		aAdd(aCab,{"C5_TPCOMPL", "1"          ,nil})  //Tipo de Complemento - "C"- 1: Preço 2: Qtde
		IF !SA1->(dbSeek(xFilial()+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))
			HELP(" ",1,"AVG0005023") //MsgInfo("Importador não cadastrado !","Aviso")
			lMSErroAuto := .t.
			Break
		Endif
		aAdd(aCab,{"C5_CLIENTE",SA1->A1_COD, nil}) //Cod. Cliente
		aAdd(aCab,{"C5_LOJACLI",SA1->A1_LOJA,nil}) //Loja Cliente
		aAdd(aCab,{"C5_TIPOCLI","X"         ,nil}) //Tipo Cliente
		cCondPag := Posicione("SY6",1,xFilial("SY6")+EEC->EEC_CONDPA+AvKey(EEC->EEC_DIASPA,"Y6_DIAS_PA"),"Y6_SIGSE4")
		IF Empty(cCondPag)
			HELP(" ",1,"AVG0005028") //MsgInfo("O campo Cond.Pagto no SIGAFAT não foi preenchido !","Aviso")
			lMSErroAuto := .t.
			BREAK
		Endif
		aAdd(aCab,{"C5_CONDPAG",cCondPag,nil})
		///aAdd(aCab,{"C5_TABELA" ,"1"     ,nil}) // Tabela de preco - Tabela 1
		If ! Empty(EEC->EEC_PEDDES) // By JPP - 05/07/2005 - 08:45
			nVarDesp := CalcDespCp() 
		EndIf
		EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB)) //efetuar rateio da variação cambial da despesa
		DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And.;
				EE9->EE9_PREEMB == EEC->EEC_PREEMB

			If lConvUnid
				nValTotal :=nValTotal + (AvTransUnid(EE9->EE9_UNIDAD,EE9->EE9_UNPRC,EE9->EE9_COD_I,;
					EE9->EE9_SLDINI,.F.) * EE9->EE9_PRECO)
			Else
				nValTotal := nValTotal + (EE9->EE9_SLDINI * EE9->EE9_PRECO)
			EndIf
			EE9->(dbSkip())
		Enddo

		aItens := {}
		cItem := "01"
		lMSErroAuto := .f.
		lMSHelpAuto := .F. // para mostrar os erros na tela
		EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))
		DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB
			SD2->(dbSetOrder(3))
			SD2->(dbSeek(xFilial()+AvKey(EE9->EE9_NF,"D2_DOC")+AvKey(EE9->EE9_SERIE,"D2_SERIE") + EEC->EEC_IMPORT + EEC->EEC_IMLOJA )) //aqui Mau
			nTaxaNF := BuscaTaxa(EEC->EEC_MOEDA,SD2->D2_EMISSAO)

			//RMD - 28/08/12
			//*** Tratamento de diferença entre o preço faturado e embarcado
			If Empty(EEC->EEC_DTEMBA)
				nTxEmb := nTaxaNF////Caso não tenha data de embarque considera a mesma taxa na NF na data de embarque para não identificar diferenças.
			EndIf
			If !lEstorna .And. Empty(EEC->EEC_DTEMBA) .And. EE9->EE9_PRECO > (nDifPrcPed := Posicione("EE8", 1, xFilial("EE8")+EE9->(EE9_PEDIDO+EE9_SEQUEN), "EE8_PRECO"))
				nDifPrcPed := (AvTransUnid(EE9->EE9_UNIDAD,EE9->EE9_UNPRC,EE9->EE9_COD_I,EE9->EE9_SLDINI,.F.) * (EE9->EE9_PRECO - nDifPrcPed))
				nTxDia := BuscaTaxa(EEC->EEC_MOEDA,dDataBase)
				cMsg := "O Item 'XXX'-'YYY' possui uma diferença de 'ZZZ' entre o preço informado no pedido e o informado no embarque." + ENTER +;
					"Deseja incluir esta diferença de preço na Nota Fiscal Complementar (considerando a taxa de 'TTT')?"
				cMsg := StrTran(cMsg, "XXX", AllTrim(EE9->EE9_SEQEMB))
				cMsg := StrTran(cMsg, "YYY", AllTrim(EE9->EE9_COD_I))
				cMsg := StrTran(cMsg, "ZZZ", EEC->EEC_MOEDA + " " + AllTrim(TransForm(nDifPrcPed, AvSx3("EE9_PRCTOT", 6))))
				cMsg := StrTran(cMsg, "TTT", AllTrim(TransForm(nTxDia, AvSx3("EEQ_TX", 6))))
				If !MsgNoYes(cMsg, "Aviso")
					nDifPrcPed := 0
				Else
					nDifPrcPed *= nTxDia
				EndIf
			Else
				nDifPrcPed := 0
			EndIf
			//***

			IF !lEstorna .And. (nTxEmb-nTaxaNF) <= 0 .And. nVarDesp = 0 .And. nDifPrcPed == 0
				EE9->(dbSkip())
				Loop
			Endif
			// lTEVEVAR := .T. // By JPP - 08/07/2005 - 10:50
			If lConvUnid // By JPP - 05/07/2005 - 09:00 - Efetuar a Conversão de unidade de medida, antes de calcular o valor FOB do item.
				nValorIt := (AvTransUnid(EE9->EE9_UNIDAD,EE9->EE9_UNPRC,EE9->EE9_COD_I,;
					EE9->EE9_SLDINI,.F.) * EE9->EE9_PRECO)
			Else
				NVALORIT := EE9->(EE9_SLDINI*EE9_PRECO)  // VALOR FOB DO ITEM
			EndIf
			nFator := (nValorIt / nValTotal) // By JPP - 05/07/2005 - 09:00 - Calcula o percentual de despesa por item

			NVALORIT := (NVALORIT*NTXEMB)-(NVALORIT*NTAXANF)  // VALOR DA DIF. POR ITEM

			nValorIt := nValorIt + (nFator * nVarDesp * nTxEmb ) // By JPP - 05/07/2005 - 09:00
			IF !lEstorna .And. nValorIt <= 0  .And. nDifPrcPed == 0//RMD - 28/08/12
				EE9->(dbSkip())
				Loop
			Endif

			//RMD - 28/08/12
			If nValorIt < 0
				nValorIt := 0
			EndIf

			nValorIt += nDifPrcPed

			lTEVEVAR := .T. // By JPP - 08/07/2005 - 10:50

			If ( EasyGParam("MV_ARREFAT")=="S" )
				nVALORIT := ROUND(nVALORIT,AVSX3("C6_VALOR",AV_DECIMAL))
			Else
				nVALORIT := NOROUND(nVALORIT,AVSX3("C6_VALOR",AV_DECIMAL))
			EndIf
			IF SB1->(dbSeek(xFilial()+EE9->EE9_COD_I)) .AND. ! SB2->(dbSeek(xFilial()+SB1->B1_COD+SB1->B1_LOCPAD))
				CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
			Endif
			aReg := {}
			aAdd(aReg,{"C6_NUM"    ,aCab[1][2]     ,NIL}) // Pedido
			aAdd(aReg,{"C6_ITEM"   ,cItem          ,NIL}) // Item sequencial
			aAdd(aReg,{"C6_PRODUTO",EE9->EE9_COD_I ,nil})    // Cod.Item
			aAdd(aReg,{"C6_UM"     ,EE9->EE9_UNIDAD,nil})    // Unidade
			aAdd(aReg,{"C6_QTDVEN" ,1,nil})                  // Quantidade
			aAdd(aReg,{"C6_PRCVEN" ,nValorIt       ,nil})    // Preco Unit.
			aAdd(aReg,{"C6_PRUNIT" ,nValorIt       ,nil})    // Preco Unit.
			aAdd(aReg,{"C6_VALOR"  ,nValorIt       ,nil})    // Valor Tot.

			// ** JBJ 08/10/01 - Gravação dos campos Tipo de Saida e Codigo Fiscal ... (Inicio)
			EE8->(DbSetOrder(1))
			EE8->(Dbseek(xFilial()+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
			If EE8->(FieldPos("EE8_OPER")) > 0 .And. !Empty(EE8->EE8_OPER)    
				aAdd(aReg,{"C6_OPER",EE8->EE8_OPER,nil})  //Tipo de Operação (Tes Inteligente)
			Else
				aAdd(aReg,{"C6_TES",EE8->EE8_TES,nil}) // Tipo de Saida 
				aAdd(aReg,{"C6_CF",EE8->EE8_CF,nil})  // Classificacao Fiscal 
			EndIf
			// aAdd(aReg,{"C6_TES"    ,"501"          ,nil})    // Tipo de Saida
			// aAdd(aReg,{"C6_CF"     ,"663"          ,nil})    // Classificacao Fiscal
			// ** (Fim)

			aAdd(aReg,{"C6_LOCAL"   ,SB1->B1_LOCPAD,nil}) // Almoxarifado
			aAdd(aReg,{"C6_ENTREG"  ,dDataBase     ,nil}) // Dt.Entrega
			aAdd(aReg,{"C6_NFORI"   ,EE9->EE9_NF   ,nil}) // NF. Origem.
			aAdd(aReg,{"C6_SERIORI" ,EE9->EE9_SERIE,nil}) // Serie Origem.

			aAdd(aItens,aClone(aReg))
			cItem := SomaIt(cItem)
			IF cItem > "Z9"
				HELP(" ",1,"AVG0005026") //MsgStop("Excedeu o limite de itens do SIGAFAT !")
				lMSErroAuto := .T.
				Exit
			Endif
			EE9->(dbSkip())
		Enddo

		// ** JBJ - 06/09/01 - 15:56
		If ! lTEVEVAR .And. (nTxEmb-nTaxaNF) < 0
			MsgInfo(STR0026+ENTER+STR0027,STR0009)  //"Variação Cambial negativa !"###"Nota Fiscal Complementar não pode ser gerada!"###"Aviso"
			lMSErroAuto := .T.
			Break
		EndIf
		// **

		IF ! lTEVEVAR
			HELP(" ",1,"AVG0005029") //MsgInfo("Não Houve Diferença Cambial !","Aviso")
			lMSErroAuto := .T.
		ELSEIF Empty(aItens)
			lMSErroAuto := .T.
		Endif

		ASORT(aItens,,, { |x, y| x[2,2] < y[2,2] })

		IF lMSErroAuto
			Break
		ELSEIF lEstorna
			Estorna_PV(EEC->EEC_PEDEMB,aCab,aItens)
			MsgInfo (STR0028,STR0029)    //"Nota Fiscal Estornada !"###"Aviso !"  // BY JBJ 06/09/01 - 16:04
		Else
			//MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,3)
			lMSErroAuto := ! AVMata410(aCab, aItens, 3)
		Endif
		IF !lMSErroAuto
			EEC->(RecLock("EEC",.F.))
			EEC->EEC_PEDEMB := IF(!LESTORNA,aCAB[1,2]," ")
			// LCS - 20/09/2002 -SUBSTITUIDO PELA LINHA ACIMA
			//EEC->EEC_PEDEMB := IF(!LESTORNA,SC5->C5_NUM," ")
			EEC->(MsUnlock())
		Endif
		IF ! lEstorna
			cPedFat := EEC->EEC_PEDEMB
		Endif
	End Sequence

	RestOrd(aOrd)

Return(NIL)
	*--------------------------------------------------------------------
STATIC FUNCTION FATCVLDESP()
Local nRet := 0

If EasyGParam("MV_AVG0196",,.f.)
	nRet := TotalDesp("FRETE") + TotalDesp("SEGURO") + TotalDesp("FRETE_ADICIONAL") + TotalDesp("DESPESA_INTERNA") + AvGetCpo("EEC->EEC_DESP1") + AvGetCpo("EEC->EEC_DESP2")
Else
	//RETURN(EEC->((EEC_FRPREV+EEC_FRPCOM+EEC_SEGPRE+EEC_DESPIN+AvGetCpo("EEC->EEC_DESP1")+AvGetCpo("EEC->EEC_DESP2"))-EEC_DESCON))  // By JPP - 05/07/2005 - 08:45 
	nRet := (EEC->(EEC_FRPREV+EEC_FRPCOM+EEC_SEGPRE+EEC_DESPIN+AvGetCpo("EEC->EEC_DESP1")+AvGetCpo("EEC->EEC_DESP2")))
EndIf

RETURN nRet 
	*--------------------------------------------------------------------
/*
Funcao      : CalcDespCp
Parametros  : Nenhum
Retorno     : Valor da variação cambial da Nota Fiscal Complementar de Despesas
Objetivos   : Calcular o valor da variação cambial da Nota Fiscal Complementar de Despesas
Autor       : Julio de Paula Paz
Data/Hora   : 05/07/2005 - 09:20
*/
Static Function CalcDespCp()
Local nSomaNFCDes :=0, 	nDespTot := FATCVLDESP(), nDifDesp := 0
SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SC5")+EEC->EEC_PEDDES))
nTxDesp  := BuscaTaxa(EEC->EEC_MOEDA,SC5->C5_EMISSAO)
Begin Sequence
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+EEC->EEC_PEDDES))
	Do While SC6->(!Eof() .and. C6_FILIAL == xFilial() .and. C6_NUM == EEC->EEC_PEDDES)
		nSomaNFCDes += SC6->C6_VALOR
		SC6->(DbSkip())
	EndDo
	nSomaNFCDes := Round(nSomaNFCDes / nTxDesp, AVSX3("EEC_FRPREV", AV_DECIMAL))
	nDifDesp := nDespTot - nSomaNFCDes
End Sequence
Return nDifDesp

/*
Função de Usuário : NFCambio( cAlias_Browse, nRecno_Browse, nOpcao_Menu )
Parametros        : cAlias_Browse = Alias da tabela utilizada pelo browse.
                    nRecno_Browse = Numero do registro posicionado no browse.
                    nOpcao_Menu   = Numero da opcão de menu selecionada.
Retorno           : Nenhum
Objetivo          : Nota Fiscal de fechamento de cambio.
Autor             : Alexsander Martins dos Santos
Data/Hora         : 16/12/2003 às 18:44
Revisão           : Julio de Paula Paz
Data/Hora         : 29/09/2005 - 14:10
*/

Function NFCambio( cAlias_Browse, nRecno_Browse, nOpcao_Menu )

	Local aSaveOrd   := SaveOrd({"EE9", "SA1", "SA2", "EEM", "EE7", "EEQ"})
	Local lRet       := .T.
	Local aCampos    := {}
	Local aWorkEEQ, nCont

//RMD - 30/10/13 - Permite marcar todas as parcelas para inclusão do valor em uma única NF
	Private lMarcaTodos := .F.
	Private lExecEstorn := .F.

	Begin Sequence

		If Empty(EEC->EEC_DTEMBA) .or. EEC->EEC_STATUS = ST_PC
			MsgInfo(STR0033,STR0034) //"Processo não foi embarcado ou está cancelado." ## "Atenção"
			Break
		EndIf

		bAction := {|| lMSAReturn := GeraNFCambial() }

		//LGS-27/02/2014 - Cria WorkSC6 para apresentar os itens que iram ser utilizados na geração da NF Cambio
		aWorkSC6 := {{ "C6_NUM",     "C", AVSX3( "C6_NUM",     AV_TAMANHO ), AVSX3( "C6_NUM",     AV_DECIMAL ) },;
			{ "C6_ITEM",    "C", AVSX3( "C6_ITEM",    AV_TAMANHO ), AVSX3( "C6_ITEM",    AV_DECIMAL ) },;
			{ "C6_PRODUTO", "C", AVSX3( "C6_PRODUTO", AV_TAMANHO ), AVSX3( "C6_PRODUTO", AV_DECIMAL ) },;
			{ "C6_UM",    	"C", AVSX3( "C6_UM",      AV_TAMANHO ), AVSX3( "C6_UM",      AV_DECIMAL ) },;
			{ "C6_QTDVEN",  "N", AVSX3( "C6_QTDVEN",  AV_TAMANHO ), AVSX3( "C6_QTDVEN",  AV_DECIMAL ) },;
			{ "C6_PRCVEN",  "N", AVSX3( "C6_PRCVEN",  AV_TAMANHO ), AVSX3( "C6_PRCVEN",  AV_DECIMAL ) },;
			{ "C6_VALOR",   "N", AVSX3( "C6_VALOR",   AV_TAMANHO ), AVSX3( "C6_VALOR",   AV_DECIMAL ) },;
			{ "B1_DESC",    "C", AVSX3( "B1_DESC",    AV_TAMANHO ), AVSX3( "B1_DESC",    AV_DECIMAL ) },;
			{ "C6_FLAG",    "C",                                 2,                                  0}}


		cWorkFile := E_CriaTrab( , aWorkSC6, "WorkSC6" )
		IndRegua( "WorkSC6", cWorkFile+TEOrdBagExt(), "C6_ITEM" )

		aWorkEEQ := {{ "EEQ_PARC",   "C", AVSX3( "EEQ_PARC",   AV_TAMANHO ), AVSX3( "EEQ_PARC",   AV_DECIMAL ) },;
			{ "EEQ_VCT",    "D", AVSX3( "EEQ_VCT",    AV_TAMANHO ), AVSX3( "EEQ_VCT",    AV_DECIMAL ) },;
			{ "EEQ_VL",     "N", AVSX3( "EEQ_VL",     AV_TAMANHO ), AVSX3( "EEQ_VL",     AV_DECIMAL ) },;
			{ "EEQ_EQVL",   "N", AVSX3( "EEQ_EQVL",   AV_TAMANHO ), AVSX3( "EEQ_EQVL",   AV_DECIMAL ) },;
			{ "EEQ_MOEDA",  "C", AVSX3( "EEQ_MOEDA",  AV_TAMANHO ), AVSX3( "EEQ_MOEDA",  AV_DECIMAL ) },;
			{ "EEQ_DESCON", "N", AVSX3( "EEQ_DESCON", AV_TAMANHO ), AVSX3( "EEQ_DESCON", AV_DECIMAL ) },;
			{ "EEQ_DTCE",   "D", AVSX3( "EEQ_DTCE",   AV_TAMANHO ), AVSX3( "EEQ_DTCE",   AV_DECIMAL ) },;
			{ "EEQ_SOL",    "D", AVSX3( "EEQ_SOL",    AV_TAMANHO ), AVSX3( "EEQ_SOL",    AV_DECIMAL ) },;
			{ "EEQ_DTNEGO", "D", AVSX3( "EEQ_DTNEGO", AV_TAMANHO ), AVSX3( "EEQ_DTNEGO", AV_DECIMAL ) },;
			{ "EEQ_PGT",    "D", AVSX3( "EEQ_PGT",    AV_TAMANHO ), AVSX3( "EEQ_PGT",    AV_DECIMAL ) },;
			{ "EEQ_TX",     "N", AVSX3( "EEQ_TX" ,    AV_TAMANHO ), AVSX3( "EEQ_TX",    AV_DECIMAL )  },;
			{ "EEQ_PEDCAM", "C", AVSX3( "EEQ_PEDCAM", AV_TAMANHO ), AVSX3( "EEQ_PEDCAM", AV_DECIMAL ) }}

		//GFP 25/10/2010
		aWorkEEQ := AddWkCpoUser(aWorkEEQ,"EEQ")

		aADD(aWorkEEQ,{"EEQ_RECNO",  "N", 7,                                 00})
		aADD(aWorkEEQ,{"EEQ_FLAG",   "C", 2, 								00})

		cWorkFile := E_CriaTrab( , aWorkEEQ, "WorkEEQ" )
		IndRegua( "WorkEEQ", cWorkFile+TEOrdBagExt(), "EEQ_PARC" )

		EEQ->(dbSetOrder(1))
		EEQ->(dbSeek(xFilial("EEQ")+EEC->EEC_PREEMB))

		While EEQ->(!Eof() .and. EEQ_FILIAL == xFilial("EEQ")) .and. EEQ->EEQ_PREEMB == EEC->EEC_PREEMB

			WorkEEQ->(dbAppend())

			For nCont := 1 To Len(aWorkEEQ)-2
				WorkEEQ->(&(aWorkEEQ[nCont][1])) := EEQ->(&(aWorkEEQ[nCont][1]))
			Next

			WorkEEQ->(&(aWorkEEQ[nCont][1])) := EEQ->(Recno())

			EEQ->(dbSkip())

		End

		If !TelaGetsCamb()
			lRet := .F.
			Break
		EndIf

		MsAguarde( bAction, STR0044 ) // "Gerando NFC Cambial"

	End Sequence

	If Select("WorkSC6") > 0
		WorkSC6->(__dbZap())
		WorkSC6->(dbCloseArea())
	EndIf
	If Select("WorkEEQ") > 0
		WorkEEQ->(__dbZap())
		WorkEEQ->(dbCloseArea())
	EndIf

	RestOrd(aSaveOrd)
	dbSelectArea("EEC")

Return(Nil)

/*
Função     : TelaGetsCamb()
Parametros : Nenhum
Retorno    : .T. / .F.
Objetivo   : Apresentar tela de dialogo, solicitando o preenchimento de informações ao usuário.
Autor      : Alexsander Martins dos Santos
Data/Hora  : 17/12/2003 às 10:40.
Revisão    : Julio de Paula Paz
Data/Hora  : 29/09/2005 - 14:10
*/

Static Function TelaGetsCamb(lCambio)

	Local lRet     := .T.
	Local nOpcao   := 0

	Local lInverte := .F.
	Local bOk
	Local bCancel  := { || nOpcao:=0, oDlg:End() }

	Local aSelFieldsSC6 := {{"C6_NUM",     AVSX3("C6_NUM",     AV_PICTURE), AVSX3("C6_NUM",     AV_TITULO)},;
		{"C6_ITEM",    AVSX3("C6_ITEM",    AV_PICTURE), AVSX3("C6_ITEM",    AV_TITULO)},;
		{"C6_PRODUTO", AVSX3("C6_PRODUTO", AV_PICTURE), AVSX3("C6_PRODUTO", AV_TITULO)},;
		{"B1_DESC",    AVSX3("B1_DESC",    AV_PICTURE), AVSX3("B1_DESC",    AV_TITULO)},;
		{"C6_UM",      AVSX3("C6_UM",      AV_PICTURE), AVSX3("C6_UM",      AV_TITULO)},;
		{"C6_QTDVEN",  AVSX3("C6_QTDVEN",  AV_PICTURE), AVSX3("C6_QTDVEN",  AV_TITULO)},;
		{"C6_PRCVEN",  AVSX3("C6_PRCVEN",  AV_PICTURE), AVSX3("C6_PRCVEN",  AV_TITULO)},;
		{"C6_VALOR",   AVSX3("C6_VALOR",   AV_PICTURE), AVSX3("C6_VALOR",   AV_TITULO)}}

	Local aSelectFields := {{"EEQ_FLAG",   "XX",                            ""},;
		{"EEQ_PARC",   AVSX3("EEQ_PARC",   AV_PICTURE), "Parcela"},;
		{"EEQ_PEDCAM", AVSX3("EEQ_PEDCAM", AV_PICTURE), "Ped. Compl."},;
		{"EEQ_VCT",    AVSX3("EEQ_VCT",    AV_PICTURE), "Data Vencto."},;
		{"EEQ_VL",     AVSX3("EEQ_VL",     AV_PICTURE), "Vl.da Parc."},;
		{"EEQ_DESCON", AVSX3("EEQ_DESCON", AV_PICTURE), "Desconto"},;
		{"EEQ_DTCE",   AVSX3("EEQ_DTCE",   AV_PICTURE), "Fech.Créd.Ext."},;
		{"EEQ_SOL",    AVSX3("EEQ_SOL",    AV_PICTURE), "Sol.Cambio"},;
		{"EEQ_DTNEGO", AVSX3("EEQ_DTNEGO", AV_PICTURE), "Dt.Negociac."},;
		{"EEQ_PGT",    AVSX3("EEQ_PGT",    AV_PICTURE), "Dt.Fechamento"}}

	Local aButtons

	Private cMarca := GetMark(), oMsSelect
	Private aTela[0][0], aGets[0], nUsado:=0

	Private aCampos:={}, aHeader:={}, lALTERA:=.T., lSITUACAO:=.T.

	Private aApropria := {}
	Private oSayPesBru,oSayPesLiq

	DEFAULT lCambio:= .F.

	aButtons := {{"NOTE", {|| If(lMarcaTodos := MarcaTodas( If(lCambio,"WorkSC6","WorkEEQ") , 3), ( lExecEstorn := .F. , Eval(bOK) ), ) },"Marca Todas para geração da NFC"},  ;
		{"NOTE", {|| If(lMarcaTodos := MarcaTodas( If(lCambio,"WorkSC6","WorkEEQ") , 5), ( lExecEstorn := .T. , Eval(bOK) ), ) },"Marca Todas para estorno da NFC"}   }

	bOk      := {|| If(!CampoNaoSel(If(lCambio,"WorkSC6","WorkEEQ")),(nOpcao:=1, oDlg:End()),) }

	Begin Sequence

		//LGS-27/02/2014 - VERIFICA SE DEVE APRESENTAR AS PARCELAS DO CAMBIO OU OS ITENS QUE IRãO COMPOR A NF CAMBIO
		If !lCambio
			WorkEEQ->(dbGoTop())
			Define MSDialog oDlg Title STR0045 From 0, 0 To 455, 740 Of oMainWnd Pixel  // "Geração de Nota Fiscal Complementar Cambial"
			aPos := PosDlg(oDlg)
			//GFP 25/10/2010
			aSelectFields := AddCpoUser(aSelectFields,"EEQ","2")
			oMark := MsSelect():New("WorkEEQ", "EEQ_FLAG",, aSelectFields, @lInverte, @cMarca, aPos)
			oMark:bAval := { || TelaGetsValid("EEQ_FLAG") .and. Eval(bOk) }
			Activate MSDialog oDlg Centered On Init (EnchoiceBar( oDlg, bOk, bCancel,, aButtons))

			If nOpcao = 0
				lRet := .F.
				Break
			EndIf

		Else
			WorkSC6->(dbGoTop())
			Define MSDialog oDlg Title "Itens da Nota Fiscal" From 0, 0 To 400, 900 Of oMainWnd Pixel
			aPos := PosDlg(oDlg)
			MsSelect():New("WorkSC6", "C6_FLAG",, aSelFieldsSC6, @lInverte, @cMarca, aPos)
			Activate MSDialog oDlg Centered On Init;
				(EnchoiceBar( oDlg, {||nOpcao:=1,oDlg:End()}, bCancel,, /*aButtons*/))
			If nOpcao = 0
				lRet := .F.
			EndIf

		EndIf
	End Sequence

Return(lRet)

//RMD - 30/10/13 - Marca todas as parcelas para inclusão em uma única NF
Static Function MarcaTodas(cAlias,nOpc)
	Local lRet := .F.
	Local bCondMark,cFieldMark, cBCondMark, nRec
	Default cAlias := ""

	nRec       := (cAlias)->(recno())
	cBCondMark := If( cAlias == "WorkEEQ", "{|| Empty((cAlias)->EEQ_FLAG) .And. !Empty((cAlias)->EEQ_PGT) .And. " + If(nOpc == 3,"","!") + "Empty((cAlias)->EEQ_PEDCAM)}" , "{|| Empty((cAlias)->C6_FLAG) }" )
	bCondMark  := &(cBCondMark)
	cFieldMark := If(cAlias == "WorkEEQ", "EEQ_FLAG", "C6_FLAG")

	If !Empty(cAlias)
		(cAlias)->(DbGoTop())
		While ((cAlias)->(!Eof()))
			If eval(bCondMark)
				(cAlias)->&(cFieldMark) := cMarca
				nRec := (cAlias)->(recno())
				lRet := .T.
			EndIf
			(cAlias)->(DbSkip())
		EndDo
	EndIf
	(cAlias)->(DbGoTo(nRec))
	If !lRet
		MsgInfo("Não há itens que atendam aos critérios para esta seleção!")
	EndIf
Return lRet

/*
Função     : TelaGetsValid(cCampo)
Parametros : cCampo = Nome do campo utilizado como base na validação
Retorno    : .T. / .F.
Objetivo   : Validação para os campos da função TelaGets.
Autor      : Alexsander Martins dos Santos
Data/Hora  : 18/12/2003 às 11:50.
Revisão    : Julio de Paula Paz
Data/Hora  : 29/09/2005 - 14:10
*/                              

Static Function TelaGetsValid( cCampo )

	Local lRet := .F.

	Begin Sequence

		Do Case
		Case cCampo == "EEQ_FLAG"
			If Empty(WorkEEQ->EEQ_PGT)
				MsgInfo(STR0046, STR0034) // "Nota Fiscal Cambial não pode ser gerada para parcela não liquidada !", "Atenção"
				Break
			EndIf
		EndCase

		lRet := .T.

	End Sequence

	If lRet .and. cCampo == "EEQ_FLAG"
		If Empty(WorkEEQ->EEQ_FLAG)
			WorkEEQ->EEQ_FLAG := cMarca
		Else
			WorkEEQ->EEQ_FLAG := ""
		End If
		If IsMemVar("lExecEstorn")
			lExecEstorn := !Empty(WorkEEQ->EEQ_PEDCAM)
		EndIf
	End IF

Return(lRet)

/*
Função     : CarrgaIteNf
Parametros : Nenhum
Retorno    : Nenhum 
Objetivo   : Carregar itens da nota fiscal de saída para a geração da nota fiscal complementar
Autor      : Maurício Frison
Data/Hora  : 04/04/2021 às 11:35
Revisão    : 
Data/Hora  : 
*/
Static Function CarregaIteNf()
	Local nQtd, nCont
	BeginSql Alias "QRYSF2"
	Select distinct 
      F2_DOC, F2_SERIE, F2_VALBRUT
      From
         %table:EE9% EE9 inner join %table:SF2% SF2 on F2_FILIAL = %XFilial:SF2% AND EE9_NF = F2_DOC AND EE9_SERIE = F2_SERIE
      Where
         EE9_FILIAL 		= %XFilial:EE9%
         And EE9_PREEMB 	= %exp:EEC->EEC_PREEMB%
		 AND F2_CLIENTE    = %exp:EEC->EEC_IMPORT% 
		 AND F2_LOJA    = %exp:EEC->EEC_IMLOJA%
         AND EE9.%NotDel%
         AND SF2.%NotDel%
	EndSql

	cMensagem := "Notas Fiscais do Processo "+EEC->EEC_PREEMB+ENTER
	cMensagem += ENTER

	nQTD := 0 //LGS-27/02/2014
	While QRYSF2->(!Eof())
		nQTD++
		QRYSF2->(DbSkip())
	EndDo

	nValorNF := 0
	aNFVenda := ARRAY(nQTD,5)
	nCont    := 1

	QRYSF2->(DbGoTop())
	While QRYSF2->(!Eof())
		cMensagem += "DOC: "+QRYSF2->F2_DOC+" SÉRIE: "+Transform(QRYSF2->F2_SERIE, AvSx3("F2_SERIE", AV_PICTURE))+" VALOR: "+Transform(QRYSF2->F2_VALBRUT,AvSX3("EEQ_VL",AV_PICTURE))+ENTER
		nValorNF  += QRYSF2->F2_VALBRUT
		aNFVenda[nCont][1] := QRYSF2->F2_DOC
		aNFVenda[nCont][2] := QRYSF2->F2_SERIE
		aNFVenda[nCont][3] := QRYSF2->F2_VALBRUT
		nCont++
		QRYSF2->(DbSkip())
	EndDo
	QRYSF2->(DbCloseArea())
RETURN

/*
Função     : GeraNFCambial
Parametros : Nenhum
Retorno    : Nenhum 
Objetivo   : Gerar Nota Fiscal Cambial.
Autor      : Alexsander Martins dos Santos
Data/Hora  : 18/12/2003 às 14:46.
Revisão    : Julio de Paula Paz
Data/Hora  : 29/09/2005 - 14:10
*/

Static Function GeraNFCambial()

	Local lRet           := .F.
	Local lTEVEVAR       := .F.
	Local lEstorna       := .F.
	Local nValorTotIt    := 0
	Local cCondPag
	Local lRetTES        := .F.
	Local bOk            := {|| If(ValidaTes(cTes),(SetMV("MV_AVG0106",cTes),lRetTES := .T.,oDlg:End()),)}
	Local bCancel        := {|| oDlg:End()}
	Local cMsgTES        := ""
	Local aLocks		 := {} //LRS-12/03/2015
	Local j := 1
//RMD - 30/10/13 - Controle de Variação Cambial de parcela de Cambio a partir da NF
	Local nTotalItens := 0
	Local aItEmb := {}
	Local nVRateio := nTRateio := 0   //LGS-24/02/2014
	Local nCont, nCont2, cNFsGeradas := "", cNFsEstorn := ""
	Local cChavPedVen
	Local nRec
	Local nValorCamb
	Local lTemNota
	Local nRecEEQ

	Private nTaxaEmbarque  := BuscaTaxa(EEC->EEC_MOEDA, EEC->EEC_DTEMBA)
	Private nTaxaParcCabio := WorkEEQ->EEQ_TX
	Private aNFVenda := {}
	Private cMensagem := ""
	Private nVariacao := 0
	Private nValorNf := 0
	Private nValorIt := 0

	Begin Sequence

		IF lExecEstorn .And. !Empty(WorkEEQ->EEQ_PEDCAM)
			lEstorna := .t.
		Endif

		IF ! lEstorna
			IF ! MsgYesNo(STR0023) // "Confirma a geração da NFC Cambial ?"
				Break
			Endif
		Else
			IF ! MsgYesNo(STR0022) // "Confirma o estorno da NFC Cambial ?"
				Break
			Endif
		Endif

		IF !SA1->(dbSeek(xFilial()+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))
			MsgInfo(STR0050,STR0009) //"Importador não cadastrado !"###"Aviso"
			Break
		Endif

		aCab   := {}
		aItens := {}

		IF !lEstorna
			aAdd(aCab, {"C5_NUM",     GetSXENum("SC5"), Nil})  // Nro.do Pedido
			aAdd(aCab, {"C5_PEDEXP",  EEC->EEC_PREEMB,  Nil})  // Nro.Embarque
			aAdd(aCab, {"C5_TIPO"  ,  "C",              Nil})  // Tipo de Pedido - "C"-Compl.Preco
			aAdd(aCab, {"C5_CLIENTE", SA1->A1_COD,      Nil})  // Cod. Cliente
			aAdd(aCab, {"C5_LOJACLI", SA1->A1_LOJA,     Nil})  // Loja Cliente
			aAdd(aCab, {"C5_TIPOCLI", "X",              Nil})  // Tipo Cliente
			aAdd(aCab,{"C5_TPCOMPL","1",nil})//1-Preco

			cCondPag := Posicione("SY6",1,xFilial("SY6")+EEC->EEC_CONDPA+AvKey(EEC->EEC_DIASPA,"Y6_DIAS_PA"),"Y6_SIGSE4")

			If Empty(cCondPag)
				MsgInfo(STR0051,STR0009)//"O campo Cond.Pagto no SIGAFAT não foi preenchido!"###"Aviso"
				Break
			Endif

			aAdd(aCab, {"C5_CONDPAG", cCondPag, Nil})

			lMSErroAuto := .F.
			lMSHelpAuto := .F. // para mostrar os erros na tela

         /*
      	RMD - 30/10/13
      	Permite avaliar a variação cambial a partir das Notas Fiscais quando a Nota Fiscal de Variação Cambial de Embarque não tiver sido gerada
         */

			//*** Reune informações sobre os itens do embarque
			//MFR 07/04/2021 OSSME-5752
			CarregaIteNf()


			If Empty(EEC->EEC_PEDEMB) .And. MsgYesNo("Não foi identificada Nota Fiscal de Variação Cambial de Embarque para este processo." + ENTER + "Deseja considerar as taxas das Notas Fiscais do Embarque para calculo da variação cambial?", "Aviso")
				lTemNota := .F.
			    nRecEEQ := 	Workeeq->(Recno())
				Workeeq->(DBEval({||lTemNota:=.T.,!Empty(EEQ_PEDCAM), !lTemNota}))
				If EEC->EEC_STATUS <> ST_CO .or. lTemNota
					//*** Reune informações sobre os itens do embarque
					//MFR 07/04/2021 OSSME-5752 RETIRADO DAQUI E MOVIDO PARA ANTES DOS DOIS IF´S INICIO
					BeginSql Alias "QRYEE9"
               			Select 
                  		  EE9_SEQEMB, EE9_UNIDAD, EE9_UNPRC, EE9_COD_I, EE9_SLDINI, EE9_PRECO, EE9_NF, EE9_SERIE
               			From
                  		%table:EE9% EE9
               			Where
                  		EE9_FILIAL 		= %XFilial:EE9%
                  		And EE9_PREEMB 	= %exp:EEC->EEC_PREEMB%
                  		AND %NotDel%
					EndSql

					While QRYEE9->(!Eof())

						SD2->(dbSetOrder(3))
						If SD2->(dbSeek(xFilial()+AvKey(QRYEE9->EE9_NF,"D2_DOC")+AvKey(QRYEE9->EE9_SERIE,"D2_SERIE")))
							QRYEE9->(aAdd(aItEmb, {EE9_SEQEMB, EE9_COD_I, EE9_NF, EE9_SERIE, AvTransUnid(EE9_UNIDAD,EE9_UNPRC,EE9_COD_I, EE9_SLDINI,.F.) * EE9_PRECO, BuscaTaxa(EEC->EEC_MOEDA, SD2->D2_EMISSAO), 0, 0}))
						Else
							//MsgInfo("Nota Fiscal "+QRYEE9->EE9_NF+" série "+QRYEE9->EE9_SERIE+" não encontrada no faturamento. Operação cancelada.", "Aviso") //RMD - 24/02/15 - Projeto Chave NF
							MsgInfo("Nota Fiscal "+QRYEE9->EE9_NF+" série "+Transform(QRYEE9->EE9_SERIE, AvSx3("EE9_SERIE", AV_PICTURE))+" não encontrada no faturamento. Operação cancelada.", "Aviso")
							Break
						EndIf
						nTotalItens += aItEmb[Len(aItEmb)][5]

						QRYEE9->(DbSkip())

					EndDo
					QRYEE9->(DbCloseArea())

					//***
					// MFR 07/04/2021 INICIO GERA TELA VARIACAO AQUI 1
					cMensagem := "Relação de itens para controle de variação cambial:" + ENTER + ENTER

					//*** Avalia a variação cambial para cada parcela, detalhando os itens/Nfs relacionados
					//O valor da variação cambial total é acumulado na private nValorIt
					If !lMarcaTodos
					    WorkEEQ->(DBGOTO(nRecEEQ)) //MFR 07/12/2021
						cMensagem += GetInfoParc(aItEmb, nTotalItens)
					Else
						WorkEEQ->(DbGoTop())
						While WorkEEQ->(!Eof())
							if !Empty(WorkEEQ->EEQ_FLAG)
								cMensagem += GetInfoParc(aItEmb, nTotalItens)
							EndIf
							WorkEEQ->(DbSkip())
						EndDo
					EndIf
					//***

					cMensagem += StrTran("Confirma a geração de nota fiscal de variação cambial no valor total de R$ XXX?", "XXX", AllTrim(Transform(nValorIt, AvSx3("C6_VALOR", AV_PICTURE)))) + ENTER
					// MFR 07/04/2021 FIM GERA TELA VARIACAO
				Else

					cMensagem += ENTER
					cMensagem += "TOTAL NOTAS FISCAIS: "+Transform(nValorNF,AvSX3("EEQ_VL",AV_PICTURE))+ENTER+ENTER
					cMensagem += "Parcelas de câmbio do Processo "+EEC->EEC_PREEMB+ENTER+ENTER

					nValorCamb := 0
					WorkEEQ->(DbGoTop())
					While WorkEEQ->(!Eof())
						cMensagem   += "Parcela: " + WorkEEQ->EEQ_PARC + " Valor "+WorkEEQ->EEQ_MOEDA+": " + AllTrim(Transform(WorkEEQ->EEQ_VL, AvSx3("EEQ_VL", AV_PICTURE))) + " Taxa: " + TransForm(WorkEEQ->EEQ_TX, AvSx3("EEQ_TX", AV_PICTURE)) + " Valor R$: " + TransForm(WorkEEQ->EEQ_EQVL, AvSx3("EEQ_EQVL", AV_PICTURE)) + ENTER
						nValorCamb  += WorkEEQ->EEQ_EQVL
						WorkEEQ->(DbSkip())
					EndDo

					nValorIt    := nValorCamb - nValorNF
					cMensagem += ENTER+"TOTAL RECEBIDO R$: "+Transform(nValorCamb,AvSX3("EEQ_VL",AV_PICTURE))+ENTER
					cMensagem += "VARIAÇÃO CAMBIAL : "+Transform(nValorIt,AvSX3("EEQ_VL",AV_PICTURE))
					nVariacao := nValorIt
				EndIf
			Else

				If !lMarcaTodos
					nDiferenca  := WorkEEQ->( nTaxaParcCabio * EEQ_VL ) - ( nTaxaEmbarque * WorkEEQ->EEQ_VL )
					nValorIt    := nDiferenca

				Else
					WorkEEQ->(DbGoTop())
					While WorkEEQ->(!Eof())
						If !Empty(WorkEEQ->EEQ_FLAG)
							nTaxaParcCabio := WorkEEQ->EEQ_TX
							nDiferenca  := WorkEEQ->( nTaxaParcCabio * EEQ_VL ) - ( nTaxaEmbarque * WorkEEQ->EEQ_VL )
							nValorIt    += nDiferenca
						EndIf
						WorkEEQ->(DbSkip())
					EndDo
				EndIf
				cMensagem += StrTran("Confirma a geração de nota fiscal de variação cambial no valor total de R$ XXX?", "XXX", AllTrim(Transform(nValorIt, AvSx3("C6_VALOR", AV_PICTURE)))) + ENTER
			EndIf

			IF nValorIt > 0
				//MFR 07/04/2021 OSSME-5752
				If !EECView(cMensagem, "Aviso",,,,.f.)
					MsgInfo("Operação cancelada", "Aviso")
					Break
				EndIf
				lTEVEVAR := .T.
				//*** MV_AVG0105
				//*** UTILIZADO PARA INFORMAR O CODIGO DO ITEN PADRãO PARA GERAR A NF CAMBIO, COM O PARAMETRO VAZIO ASSUME
				//*** GERAR A NF COM TODOS OS ITENS QUE COMPõE A NOTA FISCAL DE VENDA. - LGS-27/02/2014
				If Empty(EasyGParam("MV_AVG0105"))
					SD2->(dbSetOrder(3))
					nTotRateio:= 0
					nSequen   := 0
					For j:=1 To Len(aNFVenda)
						SD2->(dbSeek(xFilial() + aNFVenda[j][1] + aNFVenda[j][2] ) )
						While SD2->(!Eof()) .And. SD2->D2_DOC = aNFVenda[j][1] .And. SD2->D2_SERIE = aNFVenda[j][2]
							nSequen  ++
							nVRateio := 0
							nVRateio := ( ( nVALORIT/nValorNF ) * SD2->D2_TOTAL )

							If ( EasyGParam("MV_ARREFAT")=="S" )
								nVRateio := ROUND(nVRateio,AVSX3("C6_VALOR",AV_DECIMAL))
							Else
								nVRateio := NOROUND(nVRateio,AVSX3("C6_VALOR",AV_DECIMAL))
							EndIf
							IF SB1->(dbSeek(xFilial()+SD2->D2_COD)) .AND. ! SB2->(dbSeek(xFilial()+SB1->B1_COD+SB1->B1_LOCPAD))
								CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
							Endif
							nTotRateio += nVRateio
							nSQTrda := IF(nSequen < 10, PADL('0' + Trans(nSequen,'@E9') ,2) ,nSequen)
							aReg := {}
							aAdd(aReg,{"C6_NUM",     aCab[1][2],      NiL}) // Pedido
							aAdd(aReg,{"C6_ITEM",    nSQTrda,         NiL}) // Item sequencial
							aAdd(aReg,{"C6_PRODUTO", SD2->D2_COD,     Nil}) // Cod.Item
							aAdd(aReg,{"C6_UM",      "UN",            Nil}) // Unidade
							aAdd(aReg,{"C6_QTDVEN",  1,               Nil}) // Quantidade
							aAdd(aReg,{"C6_PRCVEN",  nVRateio,        Nil}) // Preco Unit.
							aAdd(aReg,{"C6_PRUNIT",  nVRateio,        Nil}) // Preco Unit.
							aAdd(aReg,{"C6_VALOR",   nVRateio,        Nil}) // Valor Tot.
							aAdd(aReg,{"C6_TES",     SD2->D2_TES,     Nil}) // Tipo de Saida ...
							aAdd(aReg,{"C6_CF"   ,   SD2->D2_CF,      Nil}) // Codigo Fiscal ...
							aAdd(aReg,{"C6_LOCAL",   SB1->B1_LOCPAD,  Nil}) // Almoxarifado
							aAdd(aReg,{"C6_ENTREG",  dDataBase,       Nil}) // Dt.Entrega
							aAdd(aReg,{"C6_NFORI",   SD2->D2_DOC,     nil}) // NF. Origem.   GFP - 21/01/2014
							aAdd(aReg,{"C6_SERIORI", SD2->D2_SERIE,   nil}) // Serie Origem. GFP - 21/01/2014
							aAdd(aItens, aClone(aReg))

							RecLock("WorkSC6",.T.)
							WorkSC6->C6_NUM	     :=	aCab[1][2]
							WorkSC6->C6_ITEM	 := nSQTrda
							WorkSC6->C6_PRODUTO  := SD2->D2_COD
							WorkSC6->B1_DESC     := SB1->B1_DESC
							WorkSC6->C6_UM		 := "UN"
							WorkSC6->C6_QTDVEN	 := 1
							WorkSC6->C6_PRCVEN	 := nVRateio
							WorkSC6->C6_VALOR	 := nVRateio
							MsunLock()
							SD2->(DbSkip())
						EndDo
					Next

					//*** O VALOR DA DIFERENÇA DO RATEIO É TIRADO SEMPRE DO PRIMEIRO ITEM
					If nTotRateio <> 0 .And. nTotRateio != nVALORIT
						aItens[1][6][2] := aItens[1][6][2] + ( nVALORIT - nTotRateio )
						aItens[1][7][2] := aItens[1][7][2] + ( nVALORIT - nTotRateio )
						aItens[1][8][2] := aItens[1][8][2] + ( nVALORIT - nTotRateio )
					EndIf

				Else
					If Empty(cCodItem := GetCodItem())
						Break
					EndIf
					If Empty(cCF := GetClasFiscal())
						Break
					EndIf
         			/* ER - 18/09/2006 - Caso o parametro MV_AVG0106 esteja vazio, 
         	   			exibe tela de seleção para o usuário,e grava a TES selecionada no parametro.*/   
            		cTES     := AvKey(EasyGParam("MV_AVG0106"),"C6_TES") // TES
					If Empty(cTES)
            			cMsgTES := STR0052 +; //"Por favor, selecione a TES que será utilizada para a "
                        	   STR0053    //"geração de todas notas fiscais complementares de câmbio"
            			Define MSDialog oDlg Title STR0054 From 0, 0 To 170, 346 Of oMainWnd Pixel  //"Seleção da TES"
               			@ 016,004 To 070,170 Label Pixel Of oDlg
               			@ 038,029 Say cMsgTES Size 138,022 Pixel Of oDlg
               			@ 052,058 MsGet cTes  Size 033,009 F3 "SF4" Valid (NaoVazio() .And. ExistCpo("SF4")) Picture "999" Pixel Of oDlg
            			Activate MSDialog oDlg Centered On Init (EnchoiceBar( oDlg, bOk, bCancel ))
            
						If !lRetTES
               				cTes := ""
               				Break
						EndIf
					EndIf
		
					IF SB1->(dbSeek(xFilial()+cCodItem)) .AND. ! SB2->(dbSeek(xFilial()+SB1->B1_COD+SB1->B1_LOCPAD))
            			CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
					Endif

            		nTotRateio:= 0
					nSequen   := 0
            		//MFR 09/04/2021 OSSME-5752 ESTAVA GERANDO UMA ÚNICA NOTA COMPLEMENTAR E O CORRETO É GERAR UMA COMPLEMENTR PRA CADA NOTA DE SAÍDA
					For j:=1 To Len(aNFVenda)
            			nSequen  ++
               			nVRateio := 0
               			nSQTrda := IF(nSequen < 10, PADL('0' + Trans(nSequen,'@E9') ,2) ,nSequen)
						nVRateio := ( ( nVALORIT/nValorNF ) * aNFVenda[j][3] )

						If ( EasyGParam("MV_ARREFAT")=="S" )
							nVRateio := ROUND(nVRateio,AVSX3("C6_VALOR",AV_DECIMAL))
						Else
							nVRateio := NOROUND(nVRateio,AVSX3("C6_VALOR",AV_DECIMAL))
						EndIf
               			nTotRateio += nVRateio

               			aReg := {}
               			aAdd(aReg,{"C6_NUM",     aCab[1][2],      NiL}) // Pedido
               			aAdd(aReg,{"C6_ITEM",    nSQTrda,            NiL}) // Item sequencial
               			aAdd(aReg,{"C6_PRODUTO", cCodItem,        Nil}) // Cod.Item
               			aAdd(aReg,{"C6_UM",      "UN",			  Nil}) // Unidade
               			aAdd(aReg,{"C6_QTDVEN",  1,               Nil}) // Quantidade
               			aAdd(aReg,{"C6_PRCVEN",  nVRateio,        Nil}) // Preco Unit.
               			aAdd(aReg,{"C6_PRUNIT",  nVRateio,        Nil}) // Preco Unit.
               			aAdd(aReg,{"C6_VALOR",   nVRateio,        Nil}) // Valor Tot.                                          
               			aAdd(aReg,{"C6_TES",     cTES       ,     Nil}) // Tipo de Saida ...      
               			aAdd(aReg,{"C6_CF"   ,   cCF         ,    Nil}) // Codigo Fiscal ...                  
               			aAdd(aReg,{"C6_LOCAL",   SB1->B1_LOCPAD,  Nil}) // Almoxarifado
               			aAdd(aReg,{"C6_ENTREG",  dDataBase,       Nil}) // Dt.Entrega
               			aAdd(aReg,{"C6_NFORI",   aNFVenda[j][1]  /*"01"*/,nil}) // NF. Origem.   GFP - 21/01/2014
               			aAdd(aReg,{"C6_SERIORI", aNFVenda[j][2] /*"A"*/,nil}) // Serie Origem. GFP - 21/01/2014
               			aAdd(aItens, aClone(aReg))
                     
		               RecLock("WorkSC6",.T.)
        		       WorkSC6->C6_NUM	     :=	aCab[1][2]
               			WorkSC6->C6_ITEM	 := "01"
               			WorkSC6->C6_PRODUTO  := cCodItem
               			WorkSC6->B1_DESC     := SB1->B1_DESC
               			WorkSC6->C6_UM		 := "UN"
               			WorkSC6->C6_QTDVEN	 := 1
               			WorkSC6->C6_PRCVEN	 := nVRateio
               			WorkSC6->C6_VALOR	 := nVRateio
               			MsunLock()
					Next
						//*** O VALOR DA DIFERENÇA DO RATEIO É TIRADO SEMPRE DO PRIMEIRO ITEM
					If nTotRateio <> 0 .And. nTotRateio != nVALORIT
						aItens[1][6][2] := aItens[1][6][2] + ( nVALORIT - nTotRateio )
						aItens[1][7][2] := aItens[1][7][2] + ( nVALORIT - nTotRateio )
						aItens[1][8][2] := aItens[1][8][2] + ( nVALORIT - nTotRateio )
					EndIf

				EndIf
			Else
                //MFR 06/04/2021 OSSME-5752
                easyhelp(STR0026+ENTER+STR0027,STR0009) // "Variação Cambial negativa !"###"Nota Fiscal Complementar não pode ser gerada!"###"Aviso"
                break         
			Endif
      
      //LGS-27/02/2014 - Chama Função Para Apresentar os Itens que Estão Sendo Utilizados na Geração da NF.
			If !TelaGetsCamb(.T.)
				If Select("WorkSC6") > 0
      	 	WorkSC6->(__dbZap())
      	 	WorkSC6->(dbCloseArea())
				EndIf
				If Select("WorkSC6") > 0
      	 	WorkEEQ->(__dbZap())
      	 	WorkEEQ->(dbCloseArea())
				Endif
      	 Break
			EndIf

      //RMD - 30/10/13 - Se lTEVEVAR for .T. a variação já é positiva
      /*
			If !lTEVEVAR .And. (nTaxaParcCabio-nTaxaEmbarque) < 0
         MsgInfo(STR0026+ENTER+STR0027,STR0009)  //"Variação Cambial negativa !"###"Nota Fiscal Complementar não pode ser gerada!"###"Aviso"
         lMSErroAuto := .T.                                                                                 
         Break
			EndIf
      */

			If !lTEVEVAR
				MsgInfo(STR0048,STR0009) // "Não Houve Diferença Cambial!"###"Aviso"
				lMSErroAuto := .T.
			ElseIf Empty(aItens)
				lMSErroAuto := .T.
			Endif
		Else

			//MFR 08/04/2021 OSSME-5752 NÃO ESTORNAVA TODAS AS NOTAS QUANDO MARCAVA TODOS
			WorkEEQ->(DbGoTop())
			While WorkEEQ->(!Eof())
				If !Empty(WorkEEQ->EEQ_FLAG)

					SD2->(dbSetOrder(8))
					cChavPedVen := xFilial("SD2") + AvKey(WorkEEQ->EEQ_PEDCAM,"D2_PEDIDO")
					Do While SD2->(dbSeek(cChavPedVen))
						aDados := {}
						aAdd(aDados,{"EEM_TIPOCA","N"            ,nil}) // Nota Fiscal (obrigatorio)
						aAdd(aDados,{"EEM_PREEMB",EEC->EEC_PREEMB,nil}) // Nro.do Embarque (obrigatorio)
						aAdd(aDados,{"EEM_TIPONF","2"            ,nil}) // Tipo de Nota 2-Complementar (obrigatorio)
						aAdd(aDados,{"EEM_NRNF"  ,SD2->D2_DOC    ,nil}) // (obrigatorio)
						aAdd(aDados,{"EEM_SERIE" ,SD2->D2_SERIE  ,nil})
						EECFATNF({aDados,5})
						aCab := {}
						aAdd(aCab,{"F2_DOC"  ,SD2->D2_DOC  ,nil})
						aAdd(aCab,{"F2_SERIE",SD2->D2_SERIE,nil})
						Mata520(aCab)
						cNFsEstorn += "Nota: "+ SD2->D2_DOC +" Série:"+ SD2->D2_SERIE + Chr(13) + Chr(10)
					EndDo


					SC5->(dbSetOrder(1))
					SC5->(dbSeek(xFilial()+WorkEEQ->EEQ_PEDCAM))

					aAdd(aCab, {"C5_NUM",     SC5->C5_NUM     , Nil})  // Nro.do Pedido
					aAdd(aCab, {"C5_PEDEXP",  EEC->EEC_PREEMB,  Nil})  // Nro.Embarque
					aAdd(aCab, {"C5_TIPO"  ,  "C",              Nil})  // Tipo de Pedido - "C"-Compl.Preco
					aAdd(aCab, {"C5_CLIENTE", SC5->C5_CLIENTE,  Nil})  // Cod. Cliente
					aAdd(aCab, {"C5_LOJACLI", SC5->C5_LOJACLI,  Nil})  // Loja Cliente
					aAdd(aCab, {"C5_TIPOCLI", "X",              Nil})  // Tipo Cliente

					cCondPag := Posicione("SY6",1,xFilial("SY6")+EEC->EEC_CONDPA+AvKey(EEC->EEC_DIASPA,"Y6_DIAS_PA"),"Y6_SIGSE4")

					If Empty(cCondPag)
						Msginfo(STR0051,STR0009) //"O campo Cond.Pagto no SIGAFAT não foi preenchido !"
						Break
					Endif

					aAdd(aCab, {"C5_CONDPAG", SC5->C5_CONDPAG, Nil})

					lMSErroAuto := .F.
					lMSHelpAuto := .F. // para mostrar os erros na tela

					SC6->(dbSetOrder(1))
					SC6->(dbSeek(xFilial()+SC5->C5_NUM))

					aReg := {}
					aAdd(aReg,{"C6_NUM",     aCab[1][2],      NiL}) // Pedido
					//Add(aReg,{"C6_ITEM",    "01",            NiL}) // Item sequencial
					aAdd(aReg,{"C6_PRODUTO", SC6->C6_PRODUTO, Nil}) // Cod.Item
					aAdd(aReg,{"C6_UM",      "UN"           , Nil}) // Unidade
					aAdd(aReg,{"C6_QTDVEN",  1,               Nil}) // Quantidade
					aAdd(aReg,{"C6_PRCVEN",  SC6->C6_PRCVEN,  Nil}) // Preco Unit.
					aAdd(aReg,{"C6_PRUNIT",  SC6->C6_PRUNIT,  Nil}) // Preco Unit.
					aAdd(aReg,{"C6_VALOR",   SC6->C6_VALOR,   Nil}) // Valor Tot.
					aAdd(aReg,{"C6_TES",     SC6->C6_TES,     Nil}) // Tipo de Saida ...
					aAdd(aReg,{"C6_CF"   ,  ""         ,      Nil}) // Codigo Fiscal ...
					aAdd(aReg,{"C6_LOCAL",  SC6->C6_LOCAL,    Nil}) // Almoxarifado
					aAdd(aReg,{"C6_ENTREG", SC6->C6_ENTREG,   Nil}) // Dt.Entrega
         /*
         aAdd(aReg,{"C6_NFORI",   EE9->EE9_NF   ,  nil}) // NF. Origem.   ER - 07/08/2006
         aAdd(aReg,{"C6_SERIORI", EE9->EE9_SERIE,  nil}) // Serie Origem. ER - 07/08/2006
      */   
					aAdd(aItens, aClone(aReg))
					If lMSErroAuto
						Break
					Else
						cPedCam := WorkEEQ->EEQ_PEDCAM
						nRec := WorkEEQ->EEQ_RECNO
						Estorna_PV(WorkEEQ->EEQ_PEDCAM,aCab,aItens)

						If ! lMSErroAuto
							EEQ->(DbGoTo(nRec))
							If EEQ->(RecLock("EEQ", .F.))
								EEQ->EEQ_PEDCAM := ""
								EEQ->(MsUnlock())
							Else
								MsgInfo("Erro ao atualizar a parcela de câmbio", "Aviso")
								Break
							EndIf

						Else
							MostraErro()
						EndIf
					EndIf
				EndIf
				WorkEEQ->(DbSkip())
			Enddo
			MsgInfo (STR0028 + Chr(13) + Chr(10) + cNFsEstorn ,STR0009) //Nota Fiscal Estornada !.

		Endif // fim do if do !lEstorno

		If lMSErroAuto
			Break
		Else
			// inclusao
			if !lEstorna
				MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,3)

				SC6->(dbSetOrder(1))
				IF ! SC6->(dbSeek(xFilial()+aCab[1,2]))
					//MsgInfo("Problema na  geração do pedido de complemento de preço. Verifique o arquivo SC??????.log")
					If lMSErroAuto
						MostraErro()
					EndIf
					Break
				Endif

				aItensNFC:= AgrupaNFs()                 //NCF - 01/10/2019
				cSerieNF := EasyGParam("MV_EECSERI")
				SD2->(DBSETORDER(8))
				SF2->(DBSETORDER(1))
				For nCont:= 1 to Len(aItensNFC)
					aNFsGeradas:= {}
					EECIncNFC(aCab[1,2],cSerieNF,EEC->EEC_PREEMB,@aNFsGeradas, aItensNFC[nCont][2])

					For nCont2:= 1 to Len(aNFsGeradas)
						SF2->(DBSEEK(XFILIAL("SF2") + AVKEY(aNFsGeradas[nCont2][2], "F2_DOC") + AVKEY(aNFsGeradas[nCont2][1], "F2_SERIE")))
						SD2->(DBSEEK(XFILIAL("SD2") + AVKEY(aCab[1,2],"D2_PEDIDO")))
						aDados := {}
						aAdd(aDados,{"EEM_TIPOCA","N"            ,nil}) // Nota Fiscal (obrigatorio)
						aAdd(aDados,{"EEM_PREEMB",EEC->EEC_PREEMB,nil}) // Nro.do Embarque (obrigatorio)
						aAdd(aDados,{"EEM_TIPONF","2"            ,nil}) // Tipo de Nota 2-Complementar (obrigatorio)
						aAdd(aDados,{"EEM_NRNF"  ,SF2->F2_DOC    ,nil}) // (obrigatorio)
						aAdd(aDados,{"EEM_SERIE" ,SF2->F2_SERIE  ,nil})
						aAdd(aDados,{"EEM_DTNF"  ,SF2->F2_EMISSAO,nil})
						aAdd(aDados,{"EEM_VLNF"  ,SF2->F2_VALBRUT,nil}) // (obrigatorio)
						aAdd(aDados,{"EEM_VLMERC",SF2->F2_VALMERC,nil}) // (obrigatorio)
						aAdd(aDados,{"EEM_VLFRET",SF2->F2_FRETE  ,nil})
						aAdd(aDados,{"EEM_VLSEGU",SF2->F2_SEGURO ,nil})
						aAdd(aDados,{"EEM_OUTROS",SF2->F2_DESPESA,nil})
						EECFATNF({aDados,3})
						cNFsGeradas += aNFsGeradas[nCont2][2] + Chr(13) + Chr(10)

						WorkEEQ->(DbGoTop())
						While WorkEEQ->(!Eof())
							If !Empty(WorkEEQ->EEQ_FLAG)
								EEQ->(DbGoTo(WorkEEQ->EEQ_RECNO))
								If EEQ->(RecLock("EEQ", .F.))
									EEQ->EEQ_PEDCAM := aCAB[1,2]
									EEQ->(MsUnlock())
								Else
									MsgInfo("Erro ao atualizar a parcela de câmbio", "Aviso")
									Break
								EndIf
							EndIf
							WorkEEQ->(DbSkip())
						EndDo
					Next nCont2
				Next nCont
				MsgInfo(STR0008 + Chr(13) + Chr(10) + cNFsGeradas,STR0009) //"Número da Nota Fiscal de Complemento de Preço: "###"Aviso"
			EndIf
		Endif

	End Sequence

//Return(lRet)
Return(Nil)

//RMD - 30/10/13 - Avalia a variação cambial da parcela a partir das Notas Fiscais
Static Function GetInfoParc(aItens, nTotalItens)
	Local cMensagem := ""
	Local oRateio := EasyRateio():New(WorkEEQ->EEQ_VL, nTotalItens, Len(aItens), AvSx3("C6_PRCVEN", AV_DECIMAL))
	Local i

	Local nValorItem, nDiferenca
	Local nValorParc := 0

	Local aHeader := {	"EE9_SEQEMB",;
		"EE9_COD_I",;
		"EE9_NF",;
		"EE9_SERIE",;
		{,, "Valor",,, AvSx3("C6_VALOR", AV_PICTURE) },;
		"EEQ_TX",;
		{,, "Valor Rateado",,, AvSx3("C6_VALOR", AV_PICTURE) },;
		{,, "Variação",,, AvSx3("C6_VALOR", AV_PICTURE) } }

	cMensagem := "Parcela: " + WorkEEQ->EEQ_PARC + " Valor: " + AllTrim(Transform(WorkEEQ->EEQ_VL, AvSx3("EEQ_VL", AV_PICTURE))) + " Taxa: " + TransForm(WorkEEQ->EEQ_TX, AvSx3("EEQ_TX", AV_PICTURE)) + ENTER + ENTER
	oRateio := EasyRateio():New(WorkEEQ->EEQ_VL, nTotalItens, Len(aItens), AvSx3("C6_PRCVEN", AV_DECIMAL))
	For i := 1 To Len(aItens)

		nValorItem := oRateio:GetItemRateio(aItens[i][5])
		nDiferenca  := WorkEEQ->(WorkEEQ->EEQ_TX * nValorItem) - (aItens[i][6] * nValorItem)

		nValorParc  += nDiferenca

		aItens[i][7] := nValorItem
		aItens[i][8] := nDiferenca

		nValorIt    += nDiferenca

		//RMD - 24/02/15 - Projeto Chave NF
		aItens[i][4] := Transform(aItens[i][4], AvSx3("EEM_SERIE", AV_PICTURE))

	Next

	nVariacao := nValorParc
	cMensagem += "Relação de Itens x NFs para esta parcela:" + ENTER + ENTER
	cMensagem += EECMontaMsg(aHeader, aItens) + ENTER + ENTER
	cMensagem += "Variação cambial total para esta parcela: " + AllTrim(Transform(nValorParc, AvSx3("C6_VALOR", AV_PICTURE))) + ENTER
	cMensagem += Repl("-", 40) + ENTER + ENTER

Return cMensagem

/*
Função     : CampoNaoSel()
Parametros : Nenhum
Retorno    : .T. / .F.
Objetivo   : Verificar se exite pelo menos um campo selecionado.
Autor      : Julio de Paula Paz
Data/Hora  : 03/10/2005 - 16:45.
Revisão    : 
Data/Hora  : 
*/                              

Static Function CampoNaoSel(cAlias)

	Local lRet := .T., nRec := (cAlias)->(Recno())
	Local cFieldMark
	Default cAlias := ""
	cFieldMark := If(cAlias == "WorkEEQ", "EEQ_FLAG", "C6_FLAG")

	If !Empty(cAlias)
		Begin Sequence
			(cAlias)->(DbGoTop())
			Do While ! (cAlias)->(Eof())
				If !Empty( (cAlias)->&(cFieldMark) )
					lRet := .F.
					Exit
				EndIf
				(cAlias)->(DbSkip())
			EndDo
			(cAlias)->(DbGoTo(nRec))
		End Sequence
	EndIf

Return(lRet)

/*
Função     : ValidaTES
Parametros : cTes - TES Selecionada
Retorno    : lRet
Objetivo   : Valida a Tela de Seleção de TES
Autor      : Eduardo C. Romanini
Data/Hora  : 18/09/2006 às 15:25.
*/
Static Function ValidaTES(cTes)

	Local lRet := .F.
	Begin Sequence

		If !Empty(cTes)
			SF4->(DbSetOrder(1))
			If SF4->(DbSeek(xFilial("SF4")+AvKey(cTes,"EE8_TES")))
				If SF4->(F4_DUPLIC) == "S"
					If MsgYesNo(STR0055,STR0009)//"A TES selecionada, está configurada para gerar duplicata. Deseja continuar?"###"Aviso"
						lRet := .T.
					EndIf
				Else
					lRet := .T.
				EndIf
			EndIf
		EndIf

	End Sequence

Return lRet

/*
Função     : GetCodItem()
Parametros : Nenhum
Retorno    : cCod - Codigo do produto padrão para geração de NFC
Objetivo   : Obter o código do produto padrão utilizado na geração de NFC, quando este não estiver gravado no parãmetro MV_AVG0105 
             será exibida tela para que o usuário o informe e o parâmetro será atualizado.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 10/10/07
Revisão    : 
Data/Hora  : 
*/
	*===========================*
Static Function GetCodItem()
	*===========================*
	Local cMsg, lOk := .F.
	Local cCod := AvKey(EasyGParam("MV_AVG0105"),"EE9_COD_I")

	If Empty(cCod)
		cMsg := "Por favor, selecione o produto padrão que será utilizado para a geração de todas notas fiscais complementares de câmbio"

		Define MSDialog oDlg Title "Seleção do Produto Padrão" From 0, 0 To 135, 346 Of oMainWnd Pixel

		@ 016,004 To 066,170 Label Pixel Of oDlg

		@ 022,029 Say cMsg Size 125,300 Pixel Of oDlg
		@ 050,072 MsGet cCod  Size 033,009 F3 "EB1" Valid (NaoVazio(cCod) .And. ExistCpo("SB1", cCod)) Pixel Of oDlg

		Activate MSDialog oDlg Centered On Init (EnchoiceBar( oDlg, {|| If(ExistCpo("SB1", cCod), (lOk := .T., oDlg:End()),) }, {|| oDlg:End() } ))
		If lOk
			SetMV("MV_AVG0105", cCod)
		Else
			cCod := ""
		EndIf
	EndIf

Return cCod

/*
Função     : GetClasFiscal()
Parametros : Nenhum
Retorno    : cCF - Código fiscal padrão para geração de NFC
Objetivo   : Obter o código fiscal padrão utilizado na geração de NFC, quando este não estiver gravado no parãmetro MV_AVG0107
             será exibida tela para que o usuário o informe e o parâmetro será atualizado.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 10/10/07
Revisão    : 
Data/Hora  : 
*/
	*=============================*
Static Function GetClasFiscal()
	*=============================*
	Local cMsg, lOk := .F.
	Local cCF := AvKey(EasyGParam("MV_AVG0107"),"C6_CF")

	If Empty(cCF)
		cMsg := "Por favor, selecione o código fiscal que será utilizado para a geração de todas notas fiscais complementares de câmbio"

		Define MSDialog oDlg Title "Seleção do Código Fiscal" From 0, 0 To 170, 346 Of oMainWnd Pixel

		@ 016,004 To 080,170 Label Pixel Of oDlg

		@ 37,029 Say cMsg Size 130,300 Pixel Of oDlg
		@ 050,100 MsGet cCF  Size 033,009 F3 "13" Valid (NaoVazio(cCF) .And. ExistCpo("SX5","13" + cCF)) Pixel Of oDlg

		Activate MSDialog oDlg Centered On Init (EnchoiceBar( oDlg, {|| If(ExistCpo("SX5","13" + cCF), (lOk := .T., oDlg:End()),) }, {|| oDlg:End() } ))
		If lOk
			SetMV("MV_AVG0107",cCF)
		Else
			cCF := ""
		EndIf
	EndIf

Return cCF


/*
Função     : AgrupaNFs
Parametros : Nenhum
Retorno    : Array com os itens do pedido agrupados por nota fiscal de origem
Objetivo   : Agrupar os itens do pedido de venda por nota fiscal de origem
Autor      : Wilsimar Fabricio da Silva
Data/Hora  : jul/2019
Revisão    : 
Data/Hora  : 
*/
Static Function AgrupaNFs()
	Local aNfs:= {}
	Local nCont:= {}
	Local nPos:= 0
	Local nPosC6_ITEM:= 0
	Local nPosC6_NFORI:= 0

	Begin Sequence

		For nCont:= 1 to Len(aItens)

			If nCont == 1 .or. aItens[nCont][nPosC6_ITEM][1] != "C6_ITEM" .or. aItens[nCont][nPosC6_NFORI][1] != "C6_NFORI" 
				nPosC6_ITEM:= AScan(aItens[nCont], {|x| x[1] == "C6_ITEM"})
				nPosC6_NFORI:= AScan(aItens[nCont], {|x| x[1] == "C6_NFORI"})
			EndIf

      /* Se a nota de origem não constar no array aNfs, adiciona-a juntamente com o item do pedido de venda */
			If (nPos:= AScan(aNfs, {|y| y[1] == aItens[nCont][nPosC6_NFORI][2]})) == 0
				AAdd(aNfs, {aItens[nCont][nPosC6_NFORI][2], {aItens[nCont][nPosC6_ITEM][2]}})
			Else
         /* Se a nota de origem constar no array, adiciona apenas o iten do pedio de venda */
				AAdd(aNfs[nPos][2], aItens[nCont][nPosC6_ITEM][2])
			EndIf

		Next

	End Sequence

Return AClone(aNfs)


/*
Função     : EECIncNFC
Parametros : cC5Num,cSerie,cEmbExp,aNotas,aItens
Retorno    : Nenhum
Objetivo   : Gerar as notas fiscais complementares
Autor      : Wilsimar Fabricio da Silva
Data/Hora  : Out/2019
Revisão    : NCF - Out/2019 - Migrada do fonte fatxfun.prx onde tinha o nome "incnota"
Data/Hora  : 
*/
Static Function EECIncNFC(cC5Num,cSerie,cEmbExp,aNotas,aItens)
	Local aPvlNfs := {}
	Local nItemNf := a460NumIt(cSerie)
	Local nCont:= 0
	Local nPosItLib

	Default cEmbExp := ""
	Default aNotas := {}
	Default aItens := {}

	Begin Sequence

		SC5->(DbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+cC5Num))

		SC6->(dbSetOrder(1))
		SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))


	/*
		Quando for a geração da nota fiscal complementar originada pelo módulo SIGAEEC, serão efetuadas as liberações apenas
	dos itens do pedido que constarem na lista.
	*/
	If !Empty(cEmbExp) .And. Len(aItens) > 0

		For nCont:= 1 to Len(aItens)

			SC6->(MsSeek(xFilial("SC6") + SC5->C5_NUM + aItens[nCont]))
			   /* Carregar o array aPvlNfs com os itens de devem ser liberados e usados na geração do documento de saída */
			EECLiberPV(@aPvlNfs)

			If ( Len(aPvlNfs) >= nItemNf )
				cNota := MaPvlNfs(aPvlNfs,cserie , .F.    , .F.    , .F.     , .T.    , .F.    , 0      , 0          , .T.  ,.F.,cEmbExp)
				aPvlNfs := {}
				AAdd( aNotas, { cSerie, cNota } )
			EndIf
		Next

		Break
	EndIf


	While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And.;
			SC6->C6_NUM == SC5->C5_NUM

		/* Carregar o array aPvlNfs com os itens de devem ser liberados e usados na geração do documento de saída */
		EECLiberPV(@aPvlNfs)

		If ( Len(aPvlNfs) >= nItemNf )
			cNota := MaPvlNfs(aPvlNfs,cserie , .F.    , .F.    , .F.     , .T.    , .F.    , 0      , 0          , .T.  ,.F.,cEmbExp)
			aPvlNfs := {}
			AAdd( aNotas, { cSerie, cNota } )
		EndIf

		SC6->(DbSkip())
	EndDo

End Sequence

If Len(aPvlNfs) > 0
	cNota := MaPvlNfs(aPvlNfs,cserie, .F.    , .F.    , .F.     , .T.    , .F.    , 0      , 0          , .T.  ,.F.,cEmbExp)
	AAdd( aNotas, { cSerie, cNota } )
EndIf

Return

/*
Função     : EECLiberPV
Parametros : Array de itens para liberação (recebido por referência)
Retorno    : Nenhum
Objetivo   : Montar array com os itens do pedido de venda que serão liberados e faturados pela função MaPvlNfs
Autor      : Wilsimar Fabricio da Silva
Data/Hora  : jul/2019
Revisão    : 
Data/Hora  : 
*/
Static Function EECLiberPV(aPvlNfs)
	Local nPrcVen := 0

	SC9->(DbSetOrder(1))
	SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM

	SE4->(DbSetOrder(1))
	SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

	SB2->(DbSetOrder(1))
	SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

	SF4->(DbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

	nPrcVen := SC9->C9_PRCVEN
	If ( SC5->C5_MOEDA <> 1 )
		nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
	EndIf

	AAdd(aPvlNfs,{ SC9->C9_PEDIDO,;
		SC9->C9_ITEM,;
		SC9->C9_SEQUEN,;
		SC9->C9_QTDLIB,;
		nPrcVen,;
		SC9->C9_PRODUTO,;
		.f.,;
		SC9->(RecNo()),;
		SC5->(RecNo()),;
		SC6->(RecNo()),;
		SE4->(RecNo()),;
		SB1->(RecNo()),;
		SB2->(RecNo()),;
		SF4->(RecNo())})

Return

Static Function ExistEXL(cTipo)
Local lRet := .T.

If EasyGParam("MV_AVG0196",,.f.) //Se habilitado, considerar apenas o frete adicional, pois os valores de frete, seguro e desp. interna já foram faturados junto ao pedido de venda
	EXL->(dbSetOrder(1)) //EXL_FILIAL, EXL_PREEMB
	If EXL->(dbSeek(xFilial("EXL") + EEC->EEC_PREEMB))
		Do Case
			Case cTipo == "SEGURO"
				If EXL->EXL_VDSE == 0
					lRet := .F.
				EndIf

			Case cTipo == "FRETE"
				If EXL->EXL_VDFR == 0
					lRet := .F.
				EndIf

			Case cTipo == "FRETE_ADICIONAL"
				If EXL->EXL_VDFA == 0
					lRet := .F.
				EndIf


			Case cTipo == "DESPESA_INTERNA"
				If EXL->EXL_VDDI == 0
					lRet := .F.
				EndIf

		EndCase
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet


Static Function TotalDesp(cTipo)
Local nRet := 0

If EasyGParam("MV_AVG0196",,.f.) 
	If ExistEXL(cTipo)
		Do Case
			Case cTipo == "SEGURO"
				nRet := EEC->EEC_SEGPRE

			Case cTipo == "FRETE"
				nRet := EEC->EEC_FRPREV

			Case cTipo == "FRETE_ADICIONAL"
				nRet := EEC->EEC_FRPCOM

			Case cTipo == "DESPESA_INTERNA"
				nRet := EEC->EEC_DESPIN

		EndCase
		
	EndIf
Else
	Do Case
		Case cTipo == "SEGURO"
			nRet := EEC->EEC_SEGPRE

		Case cTipo == "FRETE"
			nRet := EEC->EEC_FRPREV

		Case cTipo == "FRETE_ADICIONAL"
			nRet := EEC->EEC_FRPCOM

		Case cTipo == "DESPESA_INTERNA"
			nRet := EEC->EEC_DESPIN

	EndCase
EndIf

Return nRet

/*
Função     : GetVlComp
Parametros : cTipo - Despesa a ser considerada para o retorno do valor
Retorno    : nRet - Valor da Despesa
Objetivo   : Retornar o valor da despesa para a geracao da NF Complementar, considerando o parâmetro MV_AVG0196;
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 04/01/2022
*/
Static Function GetVlComp(cTipo)
Local nRet := 0

Do Case
	Case cTipo == "SEGURO"
		If EasyGParam("MV_AVG0196",,.f.)
			nRet := IIF((cTMPDESP)->EEC_SEGPRE - (cTMPDESP)->EEM_VLSEGU > 0, (cTMPDESP)->EEC_SEGPRE - (cTMPDESP)->EEM_VLSEGU, 0)
		Else
			nRet := EEC->EEC_SEGPRE
		EndIf

	Case cTipo == "FRETE"
		nRet := EEC->EEC_FRPREV

	Case cTipo == "FRETE_ADICIONAL"
		nRet := EEC->EEC_FRPCOM

	Case cTipo == "DESPESA_INTERNA"
		If EasyGParam("MV_AVG0196",,.f.)
			nRet := IIF((cTMPDESP)->EEC_DESPIN - (cTMPDESP)->EEM_OUTROS > 0, (cTMPDESP)->EEC_DESPIN - (cTMPDESP)->EEM_OUTROS, 0)
		Else
			nRet := EEC->EEC_DESPIN
		EndIf
	Case cTipo == "FRETE_TOTAL"
		nRet := IIF((cTMPDESP)->EEC_FRPREV + (cTMPDESP)->EEC_FRPCOM - (cTMPDESP)->EEM_VLFRET > 0, (cTMPDESP)->EEC_FRPREV + (cTMPDESP)->EEC_FRPCOM - (cTMPDESP)->EEM_VLFRET, 0)

EndCase

Return nRet

Static Function CriaTmpDesp()
Local cQuery
Local cTmpDesp := GetNextAlias()

cQuery := "SELECT "
cQuery += "  EEC_FRPREV, "
cQuery += "  EEC_FRPCOM, "
cQuery += "  EEC_SEGPRE, "
cQuery += "  EEC_DESPIN, "
cQuery += "  SUM(EEM_VLFRET) EEM_VLFRET, "
cQuery += "  SUM(EEM_VLSEGU) EEM_VLSEGU, "
cQuery += "  SUM(EEM_OUTROS) EEM_OUTROS "
cQuery += "FROM "
cQuery += RetSqlName("EEC") + " EEC "
cQuery += "  INNER JOIN " + RetSqlName("EEM") +" EEM ON (EEC_PREEMB = EEM_PREEMB) "
cQuery += "WHERE "
cQuery += "  EEC_FILIAL 	= '" + xFilial("EEC")  + "' "
cQuery += "  AND EEM_FILIAL = '" + xFilial("EEM")  + "' "
cQuery += "  AND EEC_PREEMB = '" + EEC->EEC_PREEMB + "' "
cQuery += "  AND EEM_TIPOCA = 'N' "
cQuery += "  AND EEC.D_E_L_E_T_ = ' ' "
cQuery += "  AND EEm.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY "
cQuery += "  EEC_FRPREV, EEC_FRPCOM, EEC_SEGPRE, EEC_DESPIN "

EasyWkQuery(cQuery,cTmpDesp)

Return cTmpDesp


Static Function ValidOK(nP_OPC)
Local lRet := .T.


If nP_OPC ==  2
	If EasyGParam("MV_AVG0196",,.f.)
		If GetVlComp("FRETE_TOTAL") + GetVlComp("SEGURO") + GetVlComp("DESPESA_INTERNA") <= 0
			EasyHelp(STR0060,STR0034) //"Não existem valores de Frete, Seguro ou Despesas Internas para a geração da Nota Complementar."
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet