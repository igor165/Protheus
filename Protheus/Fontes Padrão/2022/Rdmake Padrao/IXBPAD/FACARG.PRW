#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 17/04/00

User Function fac()        // incluido pelo assistente de conversao do AP5 IDE em 17/04/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CPERG,ADRIVER,CSTRING,CBTXT,CBCONT,TAMANHO")
SetPrvt("LIMITE,TITULO,CDESC1,CDESC2,CDESC3,ARETURN")
SetPrvt("NOMEPROG,NLIN,WNREL,CTIPODOC,CDOC,CSERIE")
SetPrvt("DDATA,CVEND,CCLIENTE,CLOJA,CCOND,NTOTAL")
SetPrvt("CRAZAO,CEND,CMUN,CEST,CCEP,CENDE")
SetPrvt("CMUNE,CESTE,CCEPE,CCUIT,CDESC,DVENC")
SetPrvt("APROD,ADESC,ALOTE,AQUANT,APRECO,ADIANT,ATOTIT")
SetPrvt("APEDIDO,AIMP1,AIMP2,AIMP3,AIMP4,AIMP5")
SetPrvt("AIMP6,AALQ1,AALQ2,AALQ3,AALQ4,AALQ5")
SetPrvt("AALQ6,AREMITO,AMSG,CPEDIDO,NMOEDA,CMENSNOTA")
SetPrvt("CTIPOCL,CTIPODES,NSUBTOT,NIMP1,NIMP2,NIMP3")
SetPrvt("NIMP4,NIMP5,NIMP6,NTOTQT,cLINHAS")
SetPrvt("NOPC,CCOR,LCONTINUA,_SALIAS,AREGS,I")
SetPrvt("J,")

/*
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncion   � FAC      � Autor � Jose Lucas	        � Data � 26.02.99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escripcion Impresion de Facturas.                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Modelo de impresion para Argentina                         낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

cPerg:="FAC010"
PERGUNTE(cPerg,.F.)

aDRIVER := READDRIVER()

cString:="SF2"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variables utilizadas para parametros                         �
//� mv_par01             // Del Factura                          �
//� mv_par02             // Hasta el Factura                     �
//� mv_par03             // Serie                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
CbTxt:=""
CbCont:=""
tamanho:="G"
limite :=220
titulo :=PADC("Emisi줻 de las Facturas." ,74)
cDesc1 :=PADC("Ser� solicitado el Intervalo para la emisi줻 de las",74)
cDesc2 :=PADC("Facturas generadas",74)
cDesc3 :=""
aReturn := { OemToAnsi("Especial"), 1,OemToAnsi("Administraci줻"), 1, 2, 1,"",1 }
nomeprog:="FAC"
nLin:=0
wnrel    := "FAC"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia control a funcion SETPRINT                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,"",.T.,"G","",.F.)

If nLastKey == 27
	Return
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica Posicion del Formulario en la Impresora             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

VerImp()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//�                                                              �
//� Inicio de Procesamiento del Factura                          �
//�                                                              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
RptStatus({|| RptNota()})// Substituido pelo assistente de conversao do AP5 IDE em 17/04/00 ==>         RptStatus({|| Execute(RptNota)})
Return


// Substituido pelo assistente de conversao do AP5 IDE em 17/04/00 ==> Function RptNota
Static Function RptNota()
               
Local nCont	:= 0
Local lValadi	:= cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 //  Adiantamentos Mexico
Local nTamCart:= Iif(AliasInDic("FR3") .AND. FR3->(FieldPos("FR3_CART")) > 0,TamSX3("FR3_CART")[1],0)
Local nLinha	:= 0

SetRegua(Val(mv_par02)-Val(mv_par01))
dbSelectArea("SF2")
dbSetOrder(1)
dbSeek(xFilial("SF2")+mv_par01,.T.)


WHILE SF2->F2_DOC >= MV_PAR01 .AND. SF2->F2_DOC <= MV_PAR02 .AND. .NOT. EOF()
	INCREGUA()
	IF SF2->F2_SERIE <> MV_PAR03
		SELECT SF2
		SKIP
		LOOP
	END
	cTIPODOC  :=       SF2->F2_TIPO
	cDOC      :=       SF2->F2_DOC       // FACTURA
	cSERIE    :=       SF2->F2_SERIE     // SERIE
	dDATA     :=       SF2->F2_EMISSAO   // EMISSAO
	cVEND     :=       SF2->F2_VEND1     // COD VENDEDOR
	cCLIENTE  :=       SF2->F2_CLIENTE   // COD CLIENTE
	cLOJA     :=       SF2->F2_LOJA      // LOJA
	cCOND     :=       SF2->F2_COND      // CONDICAO DE PAGAMENTO
	nTOTAL    :=       SF2->F2_VALBRUT   // TOTAL DA FACTURA

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿙o Equador, para Nota de Venta, � necess�rio a impress�o        �
	//쿭o consumidor final e c�dula gravados no SF2. N�o se pode       �
	//퀅tilizar o SA1, pois a venda pode ser feita para cliente padr�o.�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	IF cPaisLoc == "EQU" .And. AllTrim(SF2->F2_ESPECIE) == "NV" .AND. (SF2->(FieldPos("F2_RG")) > 0 .AND. SF2->(FieldPos("F2_NOMCLI")) > 0)
		cRAZAO	:= SF2->F2_NOMCLI
		cCUIT	:= SF2->F2_RG
		cMUN	:= ""
		cEST	:= ""
		cCEP	:= ""
		cENDE	:= ""
		cMUNE	:= ""
		cESTE	:= ""
		cCEPE	:= ""
	Else
		SELECT SA1  // CLIENTES
		SEEK xFILIAL("SA1")+cCLIENTE+cLOJA
		
		cRAZAO    :=       SA1->A1_NOME      // NOME
		cEND      :=       SA1->A1_END       // ENDERECO
		cMUN      :=       SA1->A1_MUN       // MUNICIPIO
		cEST      :=       SA1->A1_EST       // ESTADO
		cCEP      :=       SA1->A1_CEP       // CEP
		cENDE     :=       SA1->A1_ENDENT    // ENDERECO DE ENTREGA
		cMUNE     :=       SA1->A1_MUNE      // MUNICIPIO DE ENTREGA
		cESTE     :=       SA1->A1_ESTE      // ESTADO DE ENTREGA
		cCEPE     :=       SA1->A1_CEP       // CEP
		cCUIT     :=       SA1->A1_CGC       // CUIT
	EndIf	
	
	SELECT SE4   // CONDICAO DE PAGAMENTO
	SEEK xFILIAL("SE4")+cCOND
	cDESC := SE4->E4_DESCRI
	
	SELECT SE1  // CONTAS A RECEBER
	SET ORDER TO 2
	SEEK xFILIAL("SE1")+cCLIENTE+cLOJA+cSERIE+cDOC
	IF FOUND()
		dVENC := SE1->E1_VENCTO
	ELSE
		dVENC := CTOD("")
	END
	
	aPROD   := {}
	aDESC   := {}
	aLOTE   := {}
	aQUANT  := {}
	aPRECO  := {}
	aADIANT := {}
	aTOTIT  := {}
	aPEDIDO := {}
	aIMP1   := {}
	aIMP2   := {}
	aIMP3   := {}
	aIMP4   := {}
	aIMP5   := {}
	aIMP6   := {}
	aALQ1   := {}
	aALQ2   := {}
	aALQ3   := {}
	aALQ4   := {}
	aALQ5   := {}
	aALQ6   := {}
	aREMITO := {}
	aMSG    := {}
	
	SELECT SD2
	SET ORDER TO 3
	SEEK xFILIAL("SD2")+cDOC+cSERIE+cCLIENTE+cLOJA
	cPEDIDO := SD2->D2_PEDIDO
	
	WHILE SD2->D2_DOC == cDOC .AND. SD2->D2_SERIE == cSERIE .AND. SD2->D2_CLIENTE == cCLIENTE .AND. SD2->D2_LOJA == cLOJA .AND. .NOT. EOF()
		AADD(aPROD,SD2->D2_COD)                // PRODUTO
		AADD(aLOTE,SD2->D2_LOTECTL)            // LOTE CONTROLE
		AADD(aQUANT,SD2->D2_QUANT)             // QUANTIDADE
		AADD(aPRECO,SD2->D2_PRCVEN)            // PRECO UNITARIO PRATICADO
		If lValadi
			AADD(aADIANT,SD2->D2_VALADI)            // ADIANTAMENTO
		EndIf
		AADD(aTOTIT,SD2->D2_TOTAL)             // TOTAL DO ITEM
		AADD(aIMP1,SD2->D2_VALIMP1)            // IVA
		AADD(aIMP2,SD2->D2_VALIMP2)            // IVA RNI
		AADD(aIMP3,SD2->D2_VALIMP3)            // IVA Percepcion
		AADD(aIMP4,SD2->D2_VALIMP4)            // IB
		AADD(aIMP5,SD2->D2_VALIMP5)            // Imposto 5
		AADD(aIMP6,SD2->D2_VALIMP6)            // Imposto 6
		AADD(aALQ1,SD2->D2_ALQIMP1)            // ALIQUOTA IVA
		AADD(aALQ2,SD2->D2_ALQIMP2)            // ALIQUOTA IVA RNI
		AADD(aALQ3,SD2->D2_ALQIMP3)            // ALIQUOTA IVA Percepcion
		AADD(aALQ4,SD2->D2_ALQIMP4)            // ALIQUOTA IB
		AADD(aALQ5,SD2->D2_ALQIMP5)            // ALIQUOTA Imposto 5
		AADD(aALQ6,SD2->D2_ALQIMP6)            // ALIQUOTA Imposto 6
		AADD(aPEDIDO,SD2->D2_PEDIDO+D2_ITEMPV) // PEDIDO DE VENDA
		AADD(aREMITO,SD2->D2_REMITO)           // NUMERO DO REMITO
		
		SELECT SC6
		SEEK xFILIAL("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV
		AADD(aDESC,SC6->C6_DESCRI)             // DESCRICAO DO PRODUTO
		//AADD(aMSG,SC6->C6_ALMSG)             // MENSAGEM PARA O ITEM
		
		
		SELECT SD2
		SKIP
	END
	
	SELECT SC5
	SEEK xFILIAL("SC5")+cPEDIDO
	nMOEDA     := Iif(ValType(SC5->C5_MOEDA)<>"N",SC5->C5_MOEDA,SF2->F2_MOEDA)    // MOEDA DE FATURAMENTO
	cMENSNOTA  := SC5->C5_MENNOTA              									// MENSAGEM NO FINAL DO CORPO DA NOTA
	cTIPOCL    := SC5->C5_TIPOCLI              									// TIPO DO CLIENTE
	
	cTIPODES := ""
	IF cTIPOCL =="I"
		cTIPODES := "Responsable Inscripto"
	ELSEIF cTIPOCL =="N"
		cTIPODES := "Responsable No Inscripto"
	ELSEIF cTIPOCL =="L"
		cTIPODES := "Alquileres"
	ELSEIF cTIPOCL =="P"
		cTIPODES := "Servicios Publicos"
	ELSEIF cTIPOCL =="X"
		cTIPODES := "Exento Subjeto"
	ELSEIF cTIPOCL =="F"
		cTIPODES := "Consumidor Final"
	ELSEIF cTIPOCL =="M"
		cTIPODES := "Monotributista"
	ELSEIF cTIPOCL =="O"
		cTIPODES := "Exento Objeto"
	ELSEIF cTIPOCL =="S"
		cTIPODES := "No Sujeto"
	ELSEIF cTIPOCL =="Z"
		cTIPODES := "Suj No Categorizado"
	ELSEIF cTIPOCL =="E"
		cTIPODES := "Exportacion"
	ENDIF
	
	@ 01,000 PSAY CHR(27)+CHR(67)+CHR(72)                     // 72 LINHAS
	@ 01,000 PSAY CHR(15)
	@ 01,067 PSAY "SERIE:  "+cSERIE
	@ 01,105 PSAY "F A C T U R A"
	@ 03,103 PSAY cDOC           PICTURE "@R 9999-99999999"
	@ 06,108 PSAY dDATA
	@ 13,005 PSAY "CODIGO CLIENTE:"
	@ 13,022 PSAY cCLIENTE+"-"+CLOJA
	@ 13,115 PSAY "VENDEDOR:"
	@ 13,130 PSAY cVEND
	@ 14,005 PSAY cRAZAO
	@ 14,055 PSAY cEND
	@ 14,100 PSAY cEST
	If cPaisLoc == "ARG"
		@ 18,120 PSAY "REMITO"
	Else
		@ 18,120 PSAY GetDescRem()
	EndIf
	@ 21,015 PSAY cTIPODES
	@ 21,075 PSAY cCUIT PICTURE "@R 99-99999999-9"
	@ 21,118 PSAY "X"
	If Len(aREMITO) > 0
		@ 21,120 PSAY aREMITO[1] PICTURE "@R 9999-99999999"  // IMPRIME O PRIMEIRO REMITO; NAO HA VARIOS REMITOS NA MESMA FACTURA
    EndIf
	@ 23,028 PSAY cCOND+" - "+cDESC
	@ 23,065 PSAY "FECHA DE VENCIMENTO:"
	@ 23,088 PSAY dVENC
	@ 25,005 PSAY "DIRECCION DE ENVIO:"
	@ 25,030 PSAY IF(EMPTY(cENDE),cEND,cENDE)
	@ 25,080 PSAY IF(EMPTY(cMUNE),cMUN,cMUNE)
	@ 25,105 PSAY IF(EMPTY(cESTE),cEST,cESTE)
	@ 25,115 PSAY IF(EMPTY(cCEPE),cCEP,cCEPE)
	IF nMOEDA == 1	
		If lValadi
			@ 27,005 PSAY "  ARTICULO            DESCRIPCION                            LOTE             CANTIDAD         ADIANTAMENTO      PRECIO UNIT PES      IMPORTE PES"
		Else				
			@ 27,005 PSAY "  ARTICULO            DESCRIPCION                            LOTE             CANTIDAD      PRECIO UNIT PES      IMPORTE PES"		
		EndIf
	ELSE
		If lValadi
			@ 27,005 PSAY "  ARTICULO            DESCRIPCION                            LOTE             CANTIDAD         ADIANTAMENTO      PRECIO UNIT US$      IMPORTE US$"
		Else
			@ 27,005 PSAY "  ARTICULO            DESCRIPCION                            LOTE             CANTIDAD      PRECIO UNIT US$      IMPORTE US$"
		EndIf
	END
	nLIN := 29
	
	nSUBTOT := 0
	nIMP1   := 0
	nIMP2   := 0
	nIMP3   := 0
	nIMP4   := 0
	nIMP5   := 0
	nIMP6   := 0
	nTOTQT  := 0
	
	FOR nCont := 1 TO LEN(aPROD)
		@ nLIN,005 PSAY aPROD[nCont]
		@ nLIN,025 PSAY aDESC[nCont]
		@ nLIN,065 PSAY aLOTE[nCont]
		@ nLIN,080 PSAY aQUANT[nCont] PICTURE PesqPict("SD2","D2_QUANT")		
		If lValadi
			@ nLIN,095 PSAY aADIANT[nCont] PICTURE PesqPict("SD2","D2_VALADI")					
			@ nLIN,119 PSAY aPRECO[nCont] PICTURE PesqPict("SD2","D2_PRCVEN")
			@ nLIN,136 PSAY aTOTIT[nCont] +  aIMP1[nCont]+ aIMP2[nCont]                                 PICTURE PesqPict("SD2","D2_TOTAL")
		Else
			@ nLIN,095 PSAY aPRECO[nCont] PICTURE PesqPict("SD2","D2_PRCVEN")
			@ nLIN,115 PSAY aTOTIT[nCont] +  aIMP1[nCont]+ aIMP2[nCont]                                 PICTURE PesqPict("SD2","D2_TOTAL")
		EndIf
		
		nSUBTOT := nSUBTOT + aTOTIT[nCont]
		nIMP1   := nIMP1   + aIMP1[nCont]
		nIMP2   := nIMP2   + aIMP2[nCont]
		nIMP3   := nIMP3   + aIMP3[nCont]
		nIMP4   := nIMP4   + aIMP4[nCont]
		nIMP5   := nIMP5   + aIMP5[nCont]
		nIMP6   := nIMP6   + aIMP6[nCont]
		nTOTQT  := nTOTQT  + aQUANT[nCont]
		
		nLIN := nLIN + 1
		
		IF Len( aMSG ) > 0
			IF !EMPTY(aMSG[nCont])
				@ nLIN,003 PSAY aMSG[nCont]
				nLIN := nLIN + 1
			END
		END
		
	NEXT
	
	@ 55,005 PSAY cMENSNOTA
	@ 59,082 PSAY aALQ1[1] PICTURE "999.99"
	@ 59,105 PSAY aALQ2[1] PICTURE "999.99"
	@ 61,010 PSAY nSUBTOT                                      PICTURE "999,999,999.99"
	@ 61,032 PSAY nIMP1+nIMP2+nIMP3+nIMP4+nIMP5+nIMP6          PICTURE "999,999,999.99"
	@ 61,057 PSAY nSUBTOT+nIMP1+nIMP2+nIMP3+nIMP4+nIMP5+nIMP6  PICTURE "999,999,999.99"
	@ 61,080 PSAY nIMP1                                        PICTURE "999,999,999.99"
	@ 61,103 PSAY nIMP2                                        PICTURE "999,999,999.99"
	@ 61,127 PSAY nTOTAL                                       PICTURE PesqPict("SD2","D2_QUANT")
	
	cLINHAS:= " "
	cLinhas := Extenso( nTOTAL, .F.,,IF(nMOEDA=1,"A","D"))
	@ 64,005 PSAY cLINHAS
	
	@ 65,005 PSAY "CANTIDAD DE UNIDADES:"
	@ 65,030 PSAY nTOTQT PICTURE PesqPict("SD2","D2_QUANT")
	@ 66,005 PSAY 'CHEQUES: "ESTA LINEA DEBE SER ALTERADA POR ANALISTA DE SOPORTE" NO A LA ORDEN'
	If lValadi .AND. AliasInDic("FR3") .AND. FR3->(FieldPos("FR3_CART")) > 0
		
		nLinha := 67
		
		DbSelectArea("FR3")
		DbSetOrder(1)
		If MsSeek(XFilial("FR3")+PadR("R",nTamCart)+cDOC+cSERIE)
			While FR3->FR3_FILIAL+FR3->FR3_CART+FR3->FR3_DOC+FR3->FR3_SERIE == XFilial("FR3")+PadR("R",nTamCart)+cDOC+cSERIE		
				@ nLinha++,005 PSAY "ANTICIPO RECIBIDO FACTURA: "+FR3->FR3_PREFIX+" "+FR3->FR3_NUM+" "+Transform(FR3->FR3_VALOR,PesqPict("FR3","FR3_VALOR"))
			DbSkip()
			End
		EndIf
	EndIf
	//@ 67,005 PSAY "NO ES VALIDO EL RECIBO OUTORGADO EN ESTA  F A C T U R A "
	nLIN := 0
	SELECT SF2
	SKIP
END
@ nLIN,00 PSAY CHR(27)+CHR(67)+CHR(66)
@ nLIN,00 PSAY CHR(18)

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()
Return

// Substituido pelo assistente de conversao do AP5 IDE em 17/04/00 ==> Function VerImp
Static Function VerImp()

nLin:= 0                // Contador de Linhas
If aReturn[5]==2
	
	nOpc       := 1
	While .T.
		Eject
		dbCommitAll()
		SETPRC(0,0)
		IF MsgYesNo("Fomulario esta posicionado ? ")
			nOpc := 1
		ElseIF MsgYesNo("Intenta Nuevamente ? ")
			nOpc := 2
		Else
			nOpc := 3
		Endif
		
		Do Case
			Case nOpc==1
				lContinua:=.T.
				IF UPPER(ALLTRIM(aDRIVER[5])) <> "CHR(32)"
					@ PROW(),000 PSAY aDRIVER[5]
				END
				Exit
			Case nOpc==2
				Loop
			Case nOpc==3
				lContinua:=.F.
				Return
		EndCase
	End
Endif
Return