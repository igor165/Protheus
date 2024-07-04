// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "OFIOR100.CH"
#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OFIOR100 ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 04.05.92  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Notas Fiscais                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ OFIOR100(void)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marcello     ³23/08/00³oooooo³Impressao da relacao em outras moedas    ³±±
±±³              ³        ³      ³funcao c550impint                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR100()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbTxt
LOCAL CbCont,wnrel
LOCAL nOrdem,cFiltro := ""
LOCAL tamanho:= "G"
LOCAL limite := 220
LOCAL titulo := OemToAnsi(STR0001)	//"Relacao de Notas Fiscais"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Este programa ira emitir a relacao de notas fiscais."
LOCAL cDesc2 := ""
LOCAL cDesc3 := ""
LOCAL cString:= "SF2"

PRIVATE aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="OFIOR100"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="OFR100"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt 	:= SPACE(10)
cbcont 	:= 0
li 		:= 80
m_pag 	:= 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // De Nota                              ³
//³ mv_par02             // Ate a Nota                           ³
//³ mv_par03             // De Data                              ³
//³ mv_par04             // Ate a Data                           ³
//³ mv_par05             // De Produto                           ³
//³ mv_par06             // Ate o Produto                        ³
//³ mv_par07             // Da Serie                             ³
//³ mv_par08             // Da Serie                             ³
//³ mv_par09             // Mascara para codigo do produto       ³
//³ mv_par10             // Aglutina itens grade                 ³
//³ mv_par11             // De  Grupo                            ³
//³ mv_par12             // Ate Grupo                            ³
//³ mv_par13             // De  Tipo                             ³
//³ mv_par14             // Ate Tipo                             ³
//³ mv_par15             // Utiliza Descricao -Produto ProdxCli  ³
//³ mv_par16             // Qual Moeda                           ³
//³ mv_par17             // Outras moedas                        ³
//³ mv_par18             // Lista Dev. Compras ?                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="OFIOR100"

ValidPerg()
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey==27
	Set Filter to
	Return
Endif

pergunte("OFR100",.F.)

SetDefault(aReturn,cString)

If nLastKey==27
	Set Filter to
	Return
Endif

If ( cPaisLoc#"BRA" )
	RptStatus({|lEnd| C550ImpInt(@lEnd,wnRel,cString)},Titulo)
Else
	RptStatus({|lEnd| C550Imp(@lEnd,wnRel,cString)},Titulo)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C550IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR100			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C550Imp(lEnd,WnRel,cString)

LOCAL nCt := 0
LOCAL nAcD1  := 0, nAcD2 := 0, nAcD3 := 0, nAcD4 := 0, nAcD5 := 0, nAcD6:= 0, nAcD7 := 0
LOCAL nAcN1  := 0, nAcN2 := 0, nAcN3 := 0, nAcN4 := 0, nAcN5 := 0
LOCAL nAcN6  := 0, nAcG1 := 0, nAcG2 := 0, nAcG3 := 0, nAcG4 := 0
LOCAL nAcG5  := 0, nAcG6 := 0, nAcG7 := 0, nVlrISS := 0,nCompIcm := 0
LOCAL lContinua	:= .T., dEmisAnt
LOCAL cCondicao
LOCAL nReg     	:=0
LOCAL nTotQuant	:=0
LOCAL nTotal   	:=0
LOCAL nTotIcm  	:=0
LOCAL nTotIPI  	:=0
LOCAL cCf      	:=""
LOCAL cTes    	:=""
LOCAL cLocal   	:=""
LOCAL cItemPv  	:=""
LOCAL cNumPed  	:=""
LOCAL nPrcVen  	:=0
LOCAL cMascara 	:=GetMv("MV_MASCGRD")
LOCAL nTamRef  	:=Val(Substr(cMascara,1,2))
LOCAL tamanho	:= "G"
LOCAL nICMDesp 	:= 0 , nIPIDesp:= 0
LOCAL cabec1,cabec2
Local dEmiDia := dDataBase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Imporessao do Cabecalho e Rodape   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := STR0005	//"RELACAO DAS NOTAS FISCAIS  "
Cabec1 := STR0006	//"PRODUTO          DESCRICAO                       QUANTIDADE        VALOR UNITARIO VALOR MERCADORIA ALMOX CFO TES PEDIDO/IT        VALOR IPI         VALOR ICM        VALOR ISS          DESP. ACESSORIAS               TOTAL"
// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
Cabec2 := " "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice de Trabalho                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SF2")
cIndex := CriaTrab("",.F.)
cKey := 'F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE'

cCondicao := 'F2_FILIAL=="'+xFilial("SF2")+'".And.F2_DOC>="'+mv_par01+'"'
cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par07+'".And.F2_SERIE<= "'+mv_par08+'"'
If mv_par18 == 2
	cCondicao += '.And.F2_TIPO<>"D"'
EndIf
#IFDEF TOP
	IF !Empty(aReturn[7])   // Coloca expressao do filtro
		cCondicao += '.And.'+aReturn[7]
	Endif
#ENDIF
IndRegua("SF2",cIndex,cKey,,cCondicao)
nIndex := RetIndex("SF2")

#IFNDEF TOP
	IF !Empty(aReturn[7])   // Coloca expressao do filtro
		Set Filter to &( aReturn[7] )
	Endif
#ENDIF

dbSelectArea("SF2")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

SetRegua(RecCount())		// Total de Elementos da regua

While !Eof() .and. lContinua
	
	IF lEnd
		@Prow()+1,001 PSAY STR0007		//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	Endif
	
	IncRegua()
	
	dEmisAnt := F2_EMISSAO
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(cFilial+SF2->F2_DOC+SF2->F2_SERIE)
	
	nCt := 1
	While !Eof() .and. D2_DOC+D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE
		
		If D2_COD < mv_par05 .Or. D2_COD > mv_par06 .Or. D2_GRUPO < mv_par11 .Or. ;
			D2_GRUPO > mv_par12 .Or. D2_TP < mv_par13 .Or. D2_TP > mv_par14 .Or. ;
			D2_SERIE < mv_par07 .Or. D2_SERIE > mv_par08
			dbSkip()
			Loop
		Endif
		if !Empty(mv_par19)
			dbSelectArea("ACV")
			dbSetOrder(5)
			dbSeek(xFilial("ACV")+SD2->D2_COD)
			if ACV->ACV_CODPRO <> mv_par19
				dbSelectArea("SD2")
				dbSkip()
				Loop
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida o produto conforme a mascara         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet:=ValidMasc(SD2->D2_COD,MV_PAR09)
		
		If !lRet
			dbSkip()
			Loop
		Endif
		
		If li > 52
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		EndIf
		
		If nCt == 1
			@ li,000 PSay ""
			@ li,pcol()+1 PSay substr(alltrim(SB1->B1_GRUPO),1,4)
			@ li,pcol()+1 pSay SB1->B1_CODITE
			If SD2->D2_TIPO $ "BD"
				dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+SD2->D2_COD)
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial()+SD2->D2_CLIENTE+SD2->D2_LOJA)
				@Li ,pcol()+1 PSAY STR0008+A2_COD+" "+A2_LOJA+" - "+A2_NOME+" "+STR0009+DTOC(SF2->F2_EMISSAO)+STR0010+SD2->D2_TIPO     //"FORNECEDOR : "###"EMISSAO : "###" TIPO DA NOTA : "
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial()+SD2->D2_CLIENTE+SD2->D2_LOJA)
				@Li , pcol()+1  PSAY STR0011+A1_COD+" "+A1_LOJA+" - "+A1_NOME+" "+STR0009+DTOC(SF2->F2_EMISSAO)+STR0010+SD2->D2_TIPO     //"CLIENTE    : "###"EMISSAO : "###" TIPO DA NOTA : "
			EndIf
			nCt++
			Li++
			dbSelectArea("SD2")
		EndIf
		@ li, 000 psay " "
		@Li , pcol()+32 PSAY IIF(D2_GRADE == "S".And. MV_PAR10 == 1,Substr(D2_COD,1,nTamRef),D2_COD)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza Descricao conforme mv_par15         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF mv_par15 == 1
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+SD2->D2_COD)
			@li , pcol()+1  PSAY Substr(B1_DESC,1,29)
		Else
			dbSelectArea("SA7");dbSetOrder(2)
			If dbSeek(xFilial()+SD2->D2_COD+SD2->D2_CLIENTE+SD2->D2_LOJA)
				@li , pcol()+1 PSAY Substr(A7_DESCCLI,1,29)
			Else
				dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+SD2->D2_COD)
				@li , pcol()+1 PSAY Substr(B1_DESC,1,29)
			Endif
		Endif
		
		dbSelectArea("SD2")
		cCf      :=D2_CF
		cTes     :=D2_TES
		cLocal   :=D2_LOCAL
		cItemPv  :=D2_ITEMPV
		cNumPed  :=D2_PEDIDO
		nTotQuant:=0
		nTotal   :=0
		nTotICM  :=0
		nTotIPI  :=0
		nPrcVen  :=D2_PRCVEN
		
		If SD2->D2_GRADE == "S" .And. MV_PAR10 == 1
			cProdRef:= Substr(SD2->D2_COD,1,nTamRef)
			While !Eof() .And. cProdRef == Substr(SD2->D2_COD,1,nTamRef) ;
				.And. SD2->D2_GRADE == "S" .And. cNumPed == D2_PEDIDO
				nTotQuant+= D2_QUANT
				nTotal   += IIF(!(SF2->F2_TIPO $ "IP"),D2_TOTAL,0)
				If SF2->F2_TIPO == "I"
					nCompIcm+=xMoeda(D2_TOTAL,1,MV_PAR16,SD2->D2_EMISSAO)
				EndIf
				If Empty(D2_CODISS) // ISS
					nTotIcm  += D2_VALICM
					nTotIPI  += D2_VALIPI
				EndIf
				nReg     := Recno()
				dbSkip()
				If SD2->D2_COD < mv_par05 .Or. SD2->D2_COD > mv_par06 .Or.;
					SD2->D2_GRUPO	< mv_par11 .Or. SD2->D2_GRUPO > mv_par12
					dbSkip()
					Loop
				Endif
				if !Empty(mv_par19)
					dbSelectArea("ACV")
					dbSetOrder(5)
					dbSeek(xFilial("ACV")+SD2->D2_COD)
					if ACV->ACV_CODPRO <> mv_par19
						dbSkip()
						Loop
					Endif
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida o produto conforme a mascara       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lRet:=ValidMasc(SD2->D2_COD,MV_PAR09)
				If !lRet
					dbSkip()
					Loop
				Endif
			End
			If nReg > 0
				dbGoto(nReg)
				nReg:=0
			Endif
			
			@ Li ,pcol()+1 PSAY nTotQuant      PICTURE PESQPICTQT("D2_QUANT",11)
			@ Li ,pcol()+1 PSAY xMoeda(nPrcVen    ,1,MV_PAR16,SD2->D2_EMISSAO) PICTURE PESQPICT("SD2","D2_PRCVEN",16)
			@ Li ,pcol()+1 PSAY xMoeda(nTotal     ,1,MV_PAR16,SD2->D2_EMISSAO) PICTURE TM((D2_TOTAL),16)
			@ Li ,pcol()+1 PSAY cLocal
			@ Li ,pcol()+1 PSAY cCF
			@ Li ,pcol()+1 PSAY cTes
			@ Li ,pcol()+1 PSAY cNumPed
			@ Li ,pcol()+1 PSAY cItemPV
			@ Li ,pcol()+1 PSAY xMoeda(nTotIPI	,1,MV_PAR16,SD2->D2_EMISSAO) PICTURE TM(D2_VALIPI,16)
			@ Li ,pcol()+1 PSAY xMoeda(nTotICM	,1,MV_PAR16,SD2->D2_EMISSAO) PICTURE TM(D2_VALICM,16)
			nAcN1 += nTotQuant
			nAcN2 += xMoeda(nTotal	,1,MV_PAR16,SD2->D2_EMISSAO)
			nAcN4 += xMoeda(nTotICM,1,MV_PAR16,SD2->D2_EMISSAO)
			nAcN5 += xMoeda(nTotIPI,1,MV_PAR16,SD2->D2_EMISSAO)
		Else
			
			@Li , pcol()+1 PSAY D2_QUANT       PICTURE PESQPICTQT("D2_QUANT",11)
			@Li , pcol()+1 PSAY xMoeda(D2_PRCVEN  ,1,MV_PAR16,SD2->D2_EMISSAO)    PICTURE PESQPICT("SD2","D2_PRCVEN",16)
			@Li , pcol()+1 PSAY xMoeda(D2_TOTAL   ,1,MV_PAR16,SD2->D2_EMISSAO)    PICTURE TM((D2_TOTAL),16)
			@Li , pcol()+4 PSAY D2_LOCAL
			@Li , pcol()+1 PSAY D2_CF
			@Li , pcol()+1 PSAY D2_TES
			@Li , pcol()+1 PSAY D2_PEDIDO
			@Li , pcol()+1 PSAY D2_ITEMPV
			
			If Empty(D2_CODISS) // ISS
				@Li ,pcol()+1 PSAY xMoeda(D2_VALIPI,1,MV_PAR16,SD2->D2_EMISSAO)	PICTURE TM(D2_VALIPI,16)
				@Li ,pcol()+1 PSAY xMoeda(D2_VALICM,1,MV_PAR16,SD2->D2_EMISSAO)	PICTURE TM(D2_VALICM,10)
			Endif
			nAcN1 += D2_QUANT
			nAcN2 += IIF(!(SF2->F2_TIPO $ "IP"),xMoeda(D2_TOTAL,1,MV_PAR16,SD2->D2_EMISSAO),0)
			If SF2->F2_TIPO == "I"
				nCompIcm+=xMoeda(D2_TOTAL,1,MV_PAR16,SD2->D2_EMISSAO)
			EndIf
			If Empty(D2_CODISS) // ISS
				nAcN4 += xMoeda(D2_VALICM,1,MV_PAR16,SD2->D2_EMISSAO)
				nAcN5 += xMoeda(D2_VALIPI,1,MV_PAR16,SD2->D2_EMISSAO)
			EndIf
		Endif
		Li++
		dEmiDia := SD2->D2_EMISSAO
		dbSkip()
	End // Nota
	
	If (nAcN2+nAcN4+nAcN5) # 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nota tem ICMS Solidario, imprime.			                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF2->F2_ICMSRET > 0
			@Li , 0   PSAY STR0012	//"ICMS SOLIDARIO ------------> "
			@Li , 204 PSAY SF2->F2_ICMSRET	Picture PesqPict("SF2","F2_ICMSRET",16)
			Li++
		EndIf
		
		nAcN3 := xMoeda(SF2->F2_FRETE+SF2->F2_SEGURO+SF2->F2_DESPESA,1,MV_PAR16,dEmiDia)
		If nAcN3 != 0
			nIPIDesp := xMoeda(SF2->F2_VALIPI,1,MV_PAR16,dEmiDia) - nAcN5
			nICMDesp := xMoeda(SF2->F2_VALICM,1,MV_PAR16,dEmiDia) - nAcN4
			nAcN5 := xMoeda(SF2->F2_VALIPI,1,MV_PAR16,dEmiDia)
			nAcN4 := xMoeda(SF2->F2_VALICM,1,MV_PAR16,dEmiDia)
			@Li ,  0 PSAY STR0013	//"DESPESAS ACESSORIAS -------> "
			@Li ,123 PSAY nIPIDesp      PICTURE TM(D2_VALIPI	,16)
			@Li ,141 PSAY nICMDesp      PICTURE TM(D2_VALICM	,16)
			@Li ,184 PSAY nAcN3         PICTURE TM(nAcN3		,16)
			Li++
		EndIf
		nAcN6 := nAcN2 + nAcN3 + nAcN5 + xMoeda(SF2->F2_ICMSRET,1,MV_PAR16,dEmiDia) +IIF(SF2->F2_TIPO == "I",nCompIcm,0)
		nVlrISS:= xMoeda(SF2->F2_VALISS,1,MV_PAR16,dEmiDia)
		@li ,  000       PSAY " "
		@Li ,  pcol()+32 PSAY STR0014+SF2->F2_DOC+" / "+SF2->F2_SERIE+" ---->"		//"TOTAL DA NOTA - "
		@Li ,  pcol()+12 PSAY nAcN1    PICTURE PESQPICTQT("D2_QUANT",11)
		@Li ,  pcol()+18 PSAY nAcN2    PICTURE TM(nAcN2    ,16)
		@Li ,  pcol()+27 PSAY nAcN5    PICTURE TM(nAcN5	,16)
		@Li ,  pcol()+1 PSAY nAcN4    PICTURE TM(nAcN4	,10)
		@Li ,  pcol()+1 PSAY nVlrISS  PICTURE TM(nVlrISS	,11)
		@Li ,  pcol()+1 PSAY nAcN3    PICTURE TM(nAcN3	,10)
		@Li ,  pcol()+1 PSAY nAcN6    PICTURE TM(nAcN6	,16)
		Li++
		@Li ,  0 PSAY __PrtThinLine()
		Li++
		nAcG1 += nAcN1
		nAcG2 += nAcN2
		nAcG3 += nAcN3
		nAcG4 += nAcN4
		nAcG5 += nAcN5
		nAcG6 += nAcN6
		nAcG7 += nVlrISS
	EndIf
	
	nAcD1 += nAcN1
	nAcD2 += nAcN2
	nAcD3 += nAcN3
	nAcD4 += nAcN4
	nAcD5 += nAcN5
	nAcD6 += nAcN6
	nAcD7 += nVlrISS
	
	nAcn1 := 0
	nAcn2 := 0
	nAcn3 := 0
	nAcn4 := 0
	nAcn5 := 0
	nAcn6 := 0
	nCompIcm := 0
	
	dbSelectArea("SF2")
	dbSkip()
	
	If nAcd1+nAcD4+nAcD5 > 0 .And. ( dEmisAnt != F2_EMISSAO .Or. Eof() )
		Li++
		@Li ,  0 PSAY STR0015+dtoc(dEmisAnt)		//"TOTAL DO DIA  ----> "
		@Li , pcol()+51 PSAY nAcD1 PICTURE PESQPICTQT("D2_QUANT",11)
		@Li , pcol()+18 PSAY nAcD2 PICTURE TM(nAcD2,16)
		@Li , pcol()+33 PSAY nAcD5 		PICTURE TM(nAcD5,10)
		@Li , pcol()+2 PSAY nAcD4     PICTURE TM(nAcD4     ,10)
		@Li , pcol()+1 PSAY nAcD7 		PICTURE TM(nAcD7		,10)
		@Li , pcol()+1 PSAY nAcD3 		PICTURE TM(nAcD3		,10)
		@Li , pcol()+1 PSAY nAcD6 		PICTURE TM(nAcD6		,16)
		Li+=2
		nAcD1 := 0
		nAcD2 := 0
		nAcD3 := 0
		nAcD4 := 0
		nAcD5 := 0
		nAcD6 := 0
		nAcD7 := 0
	Endif
	
End // Documento, Serie

IF li != 80
	
	@Li ,  0 PSAY STR0016	//"TOTAL GERAL            ---->"
	@Li , pcol()+51 PSAY nAcG1 PICTURE PESQPICTQT("D2_QUANT",11)
	@Li , pcol()+24 PSAY nAcG2 PICTURE TM(nAcG2,10)
	@Li , pcol()+30 PSAY nAcG5	PICTURE TM(nAcG5,10)
	@Li , pcol()+1 PSAY nAcG4	PICTURE TM(nAcG4,10)
	@Li , pcol()+1 PSAY nAcG7	PICTURE TM(nAcG7,10)
	@Li , pcol()+1 PSAY nAcG3	PICTURE TM(nAcG3,10)
	@Li , pcol()+1 PSAY nAcG6	PICTURE TM(nAcG6,16)
	Li++
	roda(cbcont,cbtxt,tamanho)
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve condicao original ao SF2 e apaga arquivo de trabalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SF2")
dbSelectArea("SF2")
Set Filter To
dbSetOrder(1)

#IFNDEF TOP
	cIndex += OrdBagExt()
	If File(cIndex)
		Ferase(cIndex)
	Endif
#ENDIF

dbSelectArea("SD2")
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C550ImpInt³ Autor ³ Bruno Sobieski        ³ Data ³ 13.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C550ImpInt(lEnd,WnRel,cString)

Local nCt 		:= 0
Local lContinua := .T., dEmisAnt
Local cCondicao
Local nTotNetoNota :=0
Local nTotNetoGeral:=0
Local nTotNetoDia  :=0
Local lNovoDia 	:= .F.
Local dDia

Private tamanho	:= "G"
Private limite 	:= 220
Private cabec1,cabec2,cabec3

Private nAcN1  := 0, nAcN2 := 0, nAcN3 := 0
Private nAcG1  := 0, nAcG2 := 0, nAcG3 := 0
Private nAcD1  := 0, nAcD2 := 0, nAcD3 := 0
Private aImpostos:={}
Private nAcImpInc  :=0,nAcDImpInc    :=0,nAcGimpInc    :=0
Private nAcImpNoInc:=0,nAcDImpNoInc  :=0,nAcGimpNoInc  :=0

Private nDecs:=MsDecimais(mv_par16)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Imporessao do Cabecalho e Rodape   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo	:= STR0005	//"RELACAO DAS NOTAS FISCAIS  "
Cabec1	:= STR0018 //"PRODUCTO         DESCRIPCIàN                      DEP. PEDIDO/IT  REMITO/ITEM        CANTIDAD    VALOR UNITARIO  VALOR MERCADERIA     GRAVAMENES NO        GRAVAMENES      OTROS GASTOS               TOTAL"

//                     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                               1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19
Cabec2	:= STR0019 //
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice de Trabalho                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SF2")
cIndex	:= CriaTrab("",.F.)
cKey 	:= 'F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE'

cCondicao := 'F2_FILIAL=="'+xFilial("SF2")+'".And.F2_DOC>="'+mv_par01+'"'
cCondicao += '.And.F2_DOC<="'+mv_par02+'".And.DTOS(F2_EMISSAO)>="'+DTOS(mv_par03)+'"'
cCondicao += '.And.DTOS(F2_EMISSAO)<="'+DTOS(mv_par04)+'".And. F2_SERIE>="'+mv_par07
cCondicao += '".And.F2_SERIE<= "'+mv_par08+'".And.F2_TIPO <> "C"'

if mv_par17==2   //nao imprimir notas com moeda diferente da escolhida
	cCondicao+=" .And. F2_MOEDA=="+str(mv_par16)
endif

IF !Empty(aReturn[7])   // Coloca expressao do filtro
	cCondicao += '.And.'+aReturn[7]
Endif
IndRegua("SF2",cIndex,cKey,,cCondicao)
nIndex := RetIndex("SF2")
dbSelectArea("SF2")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()


dbSelectArea("SF2")
cIndex1  := CriaTrab("",.F.)
cKey     := 'F1_FILIAL+DTOS(F1_DTDIGIT)+F1_DOC+F1_SERIE'

cCondicao := 'F1_FILIAL=="'+xFilial("SF1")+'".And.F1_DOC>="'+mv_par01+'"'
cCondicao += '.And.F1_DOC<="'+mv_par02+'".And.DTOS(F1_DTDIGIT)>="'+DTOS(mv_par03)+'"'
cCondicao += '.And.DTOS(F1_DTDIGIT)<="'+DTOS(mv_par04)+'".And. F1_SERIE>="'+mv_par07
cCondicao += '".And.F1_SERIE<= "'+mv_par08+'".And.F1_TIPO == "D"'

if mv_par17==2  //nao imprimir notas com moeda diferente da escolhida
	cCondicao+=" .And. F1_MOEDA=="+str(mv_par16)
endif

//IF !Empty(aReturn[7])   // Coloca expressao do filtro
//	cCondicao += '.And.'+aReturn[7]
//Endif
IndRegua("SF1",cIndex1,cKey,,cCondicao)
nIndex := RetIndex("SF1")
dbSelectArea("SF1")
#IFNDEF TOP
	dbSetIndex(cIndex1+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

dbSelectArea("SF2")

SetRegua(RecCount())    // Total de Elementos da regua

While (!SF1->(Eof()) .Or. !SF2->(Eof()) ).And. lContinua
	
	IF lEnd
		@Prow()+1,001 PSAY STR0007		//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	Endif
	
	IncRegua()
	
	nCt := 1
	
	If ! SF1->(eof()) .And. If(!SF2->(EOF()),SF2->F2_EMISSAO > SF1->F1_DTDIGIT,.T.)
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(cFilial+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		cAliasPrt   := "SF1"
		dEmisAnt    := SF1->F1_DTDIGIT
		PrintSD1(@nCt)
	ElseIf  !SF2->(Eof())
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(cFilial+SF2->F2_DOC+SF2->F2_SERIE)
		cAliasPrt   := "SF2"
		dEmisAnt    := SF2->F2_EMISSAO
		PrintSD2(@nCt)
	Endif
	
	If nAcN2 > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nota tem ICMS Solidario, imprime.			                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cAliasPrt  == "SF2"
			nAcN3 := xmoeda(SF2->F2_FRETE+SF2->F2_SEGURO+SF2->F2_DESPESA,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
		Else
			nAcN3 := xmoeda(SF1->F1_FRETE+SF1->F1_SEGURO+SF1->F1_DESPESA,SF1->F1_MOEDA,mv_par16,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
		Endif
		If nAcN3 != 0
			@Li ,  0 PSAY STR0013	//"DESPESAS ACESSORIAS -------> "
			@Li ,167 PSAY nAcN3         PICTURE TM(nAcN3,16,nDecs)
			
			Li++
		EndIf
		
		If cAliasPrt  == "SF2"
			@Li ,   0 PSAY STR0014+SF2->F2_DOC+" / "+SF2->F2_SERIE+" ---->"      //"TOTAL DA NOTA - "
		Else
			@Li ,   0 PSAY STR0014+SF1->F1_DOC+" / "+SF1->F1_SERIE+" ---->"      //"TOTAL DA NOTA - "
		Endif
		@Li, 81 PSAY nAcN1          PICTURE PESQPICT("SD2","D2_QUANT",11,mv_par16)
		@Li,113 PSAY nAcN2 			PICTURE tm(nAcN2		,16,nDecs)
		@Li,132 PSAY nAcImpInc 		PICTURE tm(nAcImpInc	,16, nDecs)
		@Li,150 PSAY nAcImpNoInc 	PICTURE tm(nAcImpNoInc	,16, nDecs)
		@Li,167 PSAY nAcN3 			PICTURE TM(nAcN3		,17,nDecs)
		
		Li++
		
		nTotNetoNota:=nAcN2+nAcN3+nAcImpInc
		
		@Li , 21 PSAY STR0017 //"Total Neto Factura ---->"
		//      @Li , 54 PSAY xMoeda(nTotNetoNota,1,MV_PAR16,IIf(cAliasPrt=="SF2",SD2->D2_EMISSAO,SD1->D1_DTDIGIT)) PICTURE TM(nTotNetoDia,16)
		@Li , 53 PSAY nTotNetoNota PICTURE TM(nTotNetoDia,16,nDecs)
		Li++
		@Li ,  0 PSAY __PrtThinLine()
		Li++
		
		If cAliasPrt   == "SF2"
			nAcGImpInc  += nAcImpInc
			nAcGImpNoInc+= nAcImpNoInc
			nAcG1 += nAcN1
			nAcG2 += nAcN2
			nAcG3 += nAcN3
		Else
			nAcGImpInc  -= nAcImpInc
			nAcGImpNoInc-= nAcImpNoInc
			nAcG1 -= nAcN1
			nAcG2 -= nAcN2
			nAcG3 -= nAcN3
		Endif
	EndIf
	
	nAcDImpInc  += nAcImpInc
	nAcDImpNoInc+= nAcImpNoInc
	
	nAcD1 += nAcN1
	nAcD2 += nAcN2
	nAcD3 += nAcN3
	
	nAcImpInc   := 0
	nAcImpNoInc := 0
	
	nAcn1 := 0
	nAcn2 := 0
	nAcn3 := 0
	
	dbSelectArea(cAliasPrt)
	dbSkip()
	If cAliasPrt   == "SF1"
		lNovoDia := ( nAcd1 > 0 .And. ( dEmisAnt != F1_DTDIGIT .Or. Eof() ))
		dDia     := SD1->D1_DTDIGIT
	Else
		lNovoDia := ( nAcd1 > 0 .And. ( dEmisAnt != F2_EMISSAO .Or. Eof() ))
		dDia     := SD2->D2_EMISSAO
	Endif
	
	If lNovoDia
		Li++
		@Li ,  0 PSAY STR0015+dtoc(dEmisAnt)		//"TOTAL DO DIA  ----> "
		@Li , 81 PSAY nAcD1             PICTURE PESQPICT("SD2","D2_QUANT",11,mv_par16)
		@Li ,113 PSAY nAcD2 			PICTURE TM(nAcD2		,16,nDecs)
		@Li ,132 PSAY nAcDimpInc 		PICTURE TM(nAcDImpInc	,16,nDecs)
		@Li ,150 PSAY nAcDimpNoInc 		PICTURE TM(nAcDImpNoInc	,16,nDecs)
		@Li ,167 PSAY nAcD3 			PICTURE TM(nAcD3		,17,nDecs)
		
		Li++
		nTotNetoDia:=nAcD2+nAcD3+nAcDImpInc
		
		@Li , 21 PSAY STR0020 //"Total Neto Dia      ---->"
		//@Li , 54 PSAY xMoeda(nTotNetoDia,1,MV_PAR16,dDia)  PICTURE TM(nTotNetoDia,16,nDecs)
		@Li , 53 PSAY nTotNetoDia  PICTURE TM(nTotNetoDia,16,nDecs)
		
		Li+=2
		
		nAcDImpInc  := 0
		nAcDImpNoInc:= 0
		nAcD1 := 0
		nAcD2 := 0
		nAcD3 := 0
		
	Endif
	
End // Documento, Serie

IF li != 80
	
	If cAliasPrt   == "SF2"
		dDia     := SD2->D2_EMISSAO
	Else
		dDia     := SD1->D1_DTDIGIT
	Endif
	
	Li++
	@Li ,  0 PSAY STR0016	//"TOTAL GERAL            ---->"
	@Li , 81 PSAY nAcG1 PICTURE PESQPICT("SD2","D2_QUANT",11,mv_par16)
	@Li ,113 PSAY nAcG2 PICTURE TM(nAcG2,16,nDecs)
	@Li ,167 PSAY nAcG3 PICTURE TM(nAcG3,16,nDecs)
	Li++
	
	nTotNetoGeral:=nAcG2+nAcG3+nAcGImpInc
	
	@Li , 21 PSAY STR0021 //"Total Neto General ---->"
	@Li , 53 PSAY nTotNetoGeral PICTURE TM(nTotNetoGeral,18,nDecs)
	Li++
	roda(cbcont,cbtxt,tamanho)
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve condicao original ao SF2 e apaga arquivo de trabalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SF2")
dbSelectArea("SF2")
Set Filter To
dbSetOrder(1)

RetIndex("SF1")
dbSelectArea("SF1")
Set Filter To
dbSetOrder(1)

#IFNDEF TOP
	cIndex += OrdBagExt()
	If File(cIndex)
		Ferase(cIndex)
	Endif
	cIndex1 += OrdBagExt()
	If File(cIndex1)
		Ferase(cIndex1)
	Endif
#ENDIF

dbSelectArea("SD2")
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrintSD2 ³ Autor ³ Bruno Sobieski Chavez ³ Data ³ 28.04.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime itens do SD2 (Localizacoes).                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR100			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC Function PRINTSD2(nCt)
Local nTotImpInc  := 0
Local nTotImpNoInc:= 0
Local nImpInc:=0,nImpNoInc:=0
Local cLocal   :=""
Local cItemPv  :=""
Local cNumPed  :=""
Local nPrcVen  :=0
Local cMascara :=GetMv("MV_MASCGRD")
Local nTamRef  :=Val(Substr(cMascara,1,2))
Local nTamLin  :=Val(Substr(cMascara,4,2))
Local nTamCol  :=Val(Substr(cMascara,7,2))
Local cNumRem, cItemRem
Local nY 	   := 0

While !Eof() .and. D2_DOC+D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE
	
	If D2_COD < mv_par05 .Or. D2_COD > mv_par06 .Or. D2_GRUPO < mv_par11 .Or. ;
		D2_GRUPO > mv_par12 .Or. D2_TP < mv_par13 .Or. D2_TP > mv_par14 .Or. ;
		D2_SERIE < mv_par07 .Or. D2_SERIE > mv_par08 .Or. TRIM(D2_ESPECIE) <> TRIM(SF2->F2_ESPECIE)
		dbSkip()
		Loop
	Endif
	if !Empty(mv_par19)
		dbSelectArea("ACV")
		dbSetOrder(5)
		dbSeek(xFilial("ACV")+SD2->D2_COD)
		if ACV->ACV_CODPRO <> mv_par19
			dbSkip()
			Loop
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o produto conforme a mascara         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet:=ValidMasc(SD2->D2_COD,MV_PAR09)
	
	If !lRet
		dbSkip()
		Loop
	Endif
	
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	
	If nCt == 1
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+SD2->D2_CLIENTE+SD2->D2_LOJA)
		@Li ,   0 PSAY STR0011+A1_COD+" "+A1_LOJA+" - "+A1_NOME+" "+STR0009+DTOC(SF2->F2_EMISSAO)+STR0010+If(SD2->D2_TIPO=="C",STR0023,STR0024)  //"CLIENTE    : "###"EMISSAO : "###" TIPO DA NOTA : "###"Devolucion"###"Debito"###"Factura"
		nCt++
		Li++
		dbSelectArea("SD2")
	EndIf
	
	@Li , 0 PSAY IIF(D2_GRADE == "S".And. MV_PAR10 == 1,Substr(D2_COD,1,nTamRef),D2_COD)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utiliza Descricao conforme mv_par15         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF mv_par15 == 1
		dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+SD2->D2_COD)
		@li , 16 PSAY Substr(B1_DESC,1,30)
	Else
		dbSelectArea("SA7");dbSetOrder(2)
		If dbSeek(xFilial()+SD2->D2_COD+SD2->D2_CLIENTE+SD2->D2_LOJA)
			@li , 16 PSAY Substr(A7_DESCCLI,1,30)
		Else
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+SD2->D2_COD)
			@li , 16 PSAY Substr(B1_DESC,1,30)
		Endif
	Endif
	
	dbSelectArea("SD2")
	cCf         := D2_CF
	cTes        := D2_TES
	cLocal      := D2_LOCAL
	cItemPv     := D2_ITEMPV
	cNumPed     := D2_PEDIDO
	cNumRem     := D2_REMITO
	cItemRem    := D2_ITEMREM
	nTotQuant   := 0
	nTotal      := 0
	nTotImpInc  := 0
	nTotImpNoInc:= 0
	nPrcVen     := xmoeda(D2_PRCVEN,SF2->F2_MOEDA,mv_par16,,nDecs+1,SF2->F2_TXMOEDA)
	
	If SD2->D2_GRADE == "S" .And. MV_PAR10 == 1
		cProdRef:= Substr(SD2->D2_COD,1,nTamRef)
		While !Eof() .And. cProdRef == Substr(SD2->D2_COD,1,nTamRef) ;
			.And. SD2->D2_GRADE == "S" .And. cNumPed == D2_PEDIDO
			nTotQuant+= D2_QUANT
			nTotal   += IIF(!(SF2->F2_TIPO $ "IP"),xmoeda(D2_TOTAL,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),0)
			
			If SF2->F2_TIPO == "I"
				nCompIcm+=xmoeda(D2_TOTAL,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
			EndIf
			
			nImpInc  := 0
			nImpNoInc:= 0
			
			aImpostos:=TesImpInf(SD2->D2_TES)
			
			For nY:=1 to Len(aImpostos)
				cCampImp:="SD2->"+(aImpostos[nY][2])
				If ( aImpostos[nY][3]=="1" )
					nImpInc     += xmoeda(&cCampImp,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
				Else
					nImpNoInc   += xmoeda(&cCampImp,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
				EndIf
			Next
			
			nTotImpInc     += nImpInc
			nTotImpNoInc   += nImpNoInc
			
			nReg     := Recno()
			
			dbSkip()
			
			If SD2->D2_COD < mv_par05 .Or. SD2->D2_COD > mv_par06 .Or.;
				SD2->D2_GRUPO < mv_par11 .Or. SD2->D2_GRUPO > mv_par12
				dbSkip()
				Loop
			Endif
			if !Empty(mv_par19)
				dbSelectArea("ACV")
				dbSetOrder(5)
				dbSeek(xFilial("ACV")+SD2->D2_COD)
				if ACV->ACV_CODPRO <> mv_par19
					dbSkip()
					Loop
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida o produto conforme a mascara       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet:=ValidMasc(SD2->D2_COD,MV_PAR09)
			If !lRet
				dbSkip()
				Loop
			Endif
		End
		
		If nReg > 0
			dbGoto(nReg)
			nReg:=0
		Endif
		@Li ,049 PSAY cLocal
		@Li ,054 PSAY cNumPed
		@Li ,061 PSAY cItemPV
		@Li ,065 PSAY cNumRem
		@Li ,078 PSAY cItemRem
		@Li , 81 PSAY nTotQuant             PICTURE PESQPICT("SD2","D2_QUANT"   ,11,mv_par16)
		@Li , 94 PSAY nPrcVen               PICTURE PESQPICT("SD2","D2_PRCVEN"  ,16,mv_par16)
		@Li ,113 PSAY nTotal         		PICTURE TM((D2_TOTAL)	,16,nDecs)
		@Li ,132 PSAY nTotImpInc     		PICTURE TM(nTotImpNoInc	,16,nDecs)
		@Li ,150 PSAY nTotImpNoInc   		PICTURE TM(nTotImpInc  	,16,ndecs)
		@Li ,187 PSAY (nTotal+nTotImpInc) 	PICTURE TM(nTOTAL		,18,nDecs)
		
		nAcN1       += nTotQuant
		nAcN2       += nTotal
		nAcImpInc   += nTotImpInc
		nAcImpNoInc += nTotImpNoInc
		
	Else
		nImpInc  := 0
		nImpNoInc:= 0
		
		aImpostos:=TesImpInf(SD2->D2_TES)
		
		For nY:=1 to Len(aImpostos)
			cCampImp:="SD2->"+(aImpostos[nY][2])
			If ( aImpostos[nY][3]=="S" )
				nImpInc     += xmoeda(&cCampImp,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
			Else
				nImpNoInc   += xmoeda(&cCampImp,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
			EndIf
		Next
		
		@Li ,049 PSAY D2_LOCAL
		@Li ,054 PSAY D2_PEDIDO
		@Li ,061 PSAY D2_ITEMPV
		@Li ,065 PSAY D2_REMITO
		@Li ,078 PSAY D2_ITEMREM
		@Li , 81 PSAY D2_QUANT       PICTURE PESQPICT("SD2","D2_QUANT",11,mv_par16)
		@Li , 94 PSAY xMoeda(D2_PRCVEN  ,SF2->F2_MOEDA,MV_PAR16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA) PICTURE PESQPICT("SD2","D2_PRCVEN",16,mv_par16)
		@Li ,113 PSAY xMoeda(D2_TOTAL	,SF2->F2_MOEDA,MV_PAR16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA) PICTURE TM((D2_TOTAL),16,nDecs)
		@Li ,132 PSAY nImpInc 		PICTURE TM(nImpNoInc	, 16,nDecs)
		@Li ,150 PSAY nImpNoInc 	PICTURE TM(nImpInc		, 16,nDecs)
		@Li ,187 PSAY nImpInc+xMoeda(D2_TOTAL,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA) PICTURE TM(D2_TOTAL,18,nDecs)
		
		nAcImpInc   += nImpInc
		nAcImpNoInc += nImpNoInc
		
		nAcN1  += D2_QUANT
		nAcN2  += xmoeda(D2_TOTAL,SF2->F2_MOEDA,mv_par16,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
		
	Endif
	Li++
	dbSkip()
End // Nota
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrintSD1 ³ Autor ³ Bruno Sobieski Chavez ³ Data ³ 28.04.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime itens do SD1 (Localizacoes).                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR100			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC Function PRINTSD1(nCt)
Local nImpInc:=0,nImpNoInc:=0
Local ny := 0

While !Eof() .and. D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	
	If D1_COD < mv_par05 .Or. D1_COD > mv_par06 .Or. D1_GRUPO < mv_par11 .Or. ;
		D1_GRUPO > mv_par12 .Or. D1_TP < mv_par13 .Or. D1_TP > mv_par14 .Or. ;
		D1_SERIE < mv_par07 .Or. D1_SERIE > mv_par08 .Or. TRIM(D1_ESPECIE) <> TRIM(SF1->F1_ESPECIE)
		//      D1_SERIE < mv_par07 .Or. D1_SERIE > mv_par08 .Or. TRIM(D1_ESPECIE) <> TRIM(SF2->F2_ESPECIE)
		dbSkip()
		Loop
	Endif
	if !Empty(mv_par19)
		dbSelectArea("ACV")
		dbSetOrder(5)
		dbSeek(xFilial("ACV")+SD2->D2_COD)
		if ACV->ACV_CODPRO <> mv_par19
			dbSkip()
			Loop
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o produto conforme a mascara         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet:=ValidMasc(SD1->D1_COD,MV_PAR09)
	
	If !lRet
		dbSkip()
		Loop
	Endif
	
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	
	If nCt == 1
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+SD1->D1_FORNECE+SD1->D1_LOJA)
		@Li ,   0 PSAY STR0011+A1_COD+" "+A1_LOJA+" - "+A1_NOME+"  "+STR0009+DTOC(SF1->F1_DTDIGIT)+STR0010+STR0022   //"CLIENTE    : "###"EMISSAO : "###" TIPO DA NOTA : "
		
		nCt++
		Li++
		dbSelectArea("SD1")
	EndIf
	
	@Li , 0 PSAY left(D1_COD,30)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utiliza Descricao conforme mv_par15         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF mv_par15 == 1
		dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+SD1->D1_COD)
		@li , 31 PSAY left(B1_DESC,17)
	Else
		dbSelectArea("SA7");dbSetOrder(2)
		If dbSeek(xFilial()+SD1->D1_COD+SD1->D1_FORNECE+SD1->D1_LOJA)
			@li , 31 PSAY left(A7_DESCCLI,17)
		Else
			dbSelectArea("SB1");dbSetOrder(1);dbSeek(xFilial()+SD1->D1_COD)
			@li , 31 PSAY left(B1_DESC,17)
		Endif
	Endif
	
	dbSelectArea("SD1")
	
	nTotQuant   := 0
	nTotal      := 0
	nImpInc  := 0
	nImpNoInc:= 0
	
	aImpostos:=TesImpInf(SD1->D1_TES)
	
	For nY:=1 to Len(aImpostos)
		cCampImp:="SD1->"+(aImpostos[nY][2])
		If ( aImpostos[nY][3]=="1" )
			nImpInc   += xmoeda(&cCampImp,SF1->F1_MOEDA,mv_par16,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
		Else
			nImpNoInc += xmoeda(&cCampImp,SF1->F1_MOEDA,mv_par16,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
		EndIf
	Next
	
	@Li ,049 PSAY D1_LOCAL
	@Li ,054 PSAY D1_NUMPV
	@Li ,061 PSAY D1_ITEMPV
	@Li ,065 PSAY D1_REMITO
	@Li ,078 PSAY D1_ITEMREM
	@Li ,081 PSAY D1_QUANT  PICTURE PESQPICT("SD1","D1_QUANT",11,mv_par16)
	@Li ,094 PSAY xMoeda(D1_VUNIT,SF1->F1_MOEDA,mv_par16,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA) PICTURE PESQPICT("SD1","D1_VUNIT",16,mv_par16)
	@Li ,113 PSAY xMoeda(D1_TOTAL,SF1->F1_MOEDA,mv_par16,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA) PICTURE TM((D1_TOTAL),16,nDecs)
	@Li ,132 PSAY nImpInc   PICTURE TM(nImpNoInc,16,nDecs)
	@Li ,150 PSAY nImpNoInc PICTURE TM(nImpInc  ,16,nDecs)
	@Li ,187 PSAY nImpInc+xmoeda(D1_TOTAL,SF1->F1_MOEDA,mv_par16,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA) PICTURE TM(D1_TOTAL ,18,nDecs)
	
	nAcImpInc   += nImpInc
	nAcImpNoInc += nImpNoInc
	
	nAcN1  += D1_QUANT
	nAcN2  += xmoeda(D1_TOTAL,SF1->F1_MOEDA,mv_par16,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
	Li++
	dbSkip()
End // Nota
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValidPerg ³ Autor ³ Thiago			    ³ Data ³ 01.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da pergunte.    			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

aAdd(aRegs,{cPerg,"19",STR0028,"","","mv_chj","C", 06,0,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","","ACV1",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return

