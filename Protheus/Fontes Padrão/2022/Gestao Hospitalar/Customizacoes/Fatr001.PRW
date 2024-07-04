#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฑฑ
ฑฑบPrograma  ณ FATR001  ณAutor  ณWilson Keller       ณ Data ณ  12/04/2004 บฑฑ
ฑฑฬออออออออออุออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa de Emissao da Nota Fiscal Saida/Entrada           บฑฑ
ฑฑบ          ณ Para impressora EPSON                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบVersao    ณ 8.11 - Gestao Hospitalar                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Hospital Santa Helena                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FATR001(cNota,cSerie)

If Upper(FUNNAME()) == "LOJA701" // Venda ASSISTIDA
	Default cNota  := SL1->L1_DOC
	Default cSerie := SerieNfId('SL1',2,'L1_SERIE')
Endif

lContinua := .T.
nLin      := 0
nDesSufra := 0
If cNota == NIL
	_cPostagem:= ""
	CbTxt     := ""
	CbCont    := ""
	nOrdem    := 0
	Alfa      := 0
	Z         := 0
	M         := 0
	Tamanho   := "G"
	Limite    := 220
	Titulo    := Left("Impressao de Notas Fiscais - RFABR01",74)
	cDesc1    := Left("Este programa ira emitir a Nota Fiscal de Saida conforme",74)
	cDesc2    := Left("conforme os parametros especificados. Configure, os para-",74)
	cDesc3    := Left("metros desejados conforme sua necessidade.  Obrigado !!",74)
	cNatureza := ""
	aReturn   := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog  := "FATR001"
	cPerg     := "NFHOSP"
	nLastKey  := 0
	wnrel     := "FATR001"
	nTamNf    := 72
	cString   := "SF2"
	ValidPerg()
	Pergunte(cPerg,.F.)  // Pergunta no SX1
	
	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho)
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif
	
	VerImp()  // Verifica posicionamento de papel na Impressora
Else
	Pergunte(cPerg,.T.)  // Pergunta no SX1
	
	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho)
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif
	
	VerImp()  // Verifica posicionamento de papel na Impressora

	MV_PAR01 := cNota
	MV_PAR02 := cNota
	MV_PAR03 := cSerie

/*	cPortaImpr :=  GetMv("MV_PORTNOT") //"\\RENE\EPSON LQ-570"
	cNomeRelat := "NOTA FISCAL"
	MV_PAR01:=cNota
	MV_PAR02:=cNota
	MV_PAR03 := cSerie
	SET PRINTER TO cPortaImpr
	PrinterWin(.F.)                          // Impressao Dos/Windows
	PreparePrint(.F.,"", .F., (cPortaImpr)) // Prepara a impressao na porta especificada
	InitPrint(1,cNomeRelat,"080")            // Inicia Cliente/Servidor
	*/
Endif
	
RptStatus({|| RunProg(cNota) })

Return Nil

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function RunProg(cNota)
Local i
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Processamento para Notas Fiscais de Saida
DBSelectArea("SF2")                // Cabecalho da Nota Fiscal Saida
DBSetOrder(1)
DBSeek(xFilial("SF2")+MV_PAR01+MV_PAR03,.T.)

DBSelectArea("SD2")                // Itens de Venda da Nota Fiscal
DBSetOrder(3)
DBSeek(xFilial("SD2")+MV_PAR01+MV_PAR03)

SetRegua(Val(MV_PAR02)-Val(MV_PAR01))

cItemCg   := " "
xDESC_SC5 := 0

SetPrc(0, 0)

DBSelectArea("SF2")
While !eof() .and. SF2->F2_FILIAL == xFilial("SF2") .and. SF2->F2_DOC <= MV_PAR02 .and. lContinua
	
	If SerieNfId('SF2',2,'F2_SERIE') <> MV_PAR03
		DBSkip()
		Loop
	Endif
	
	DBSelectArea("SD2")
	DBSetOrder(3)
	DBSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
	//    Verifica se foi gerada pelo Caixa
	IF SF2->F2_ECF=="S"
		DBSelectArea("SL1")
		DBSetOrder(1)
		DBSeek(xFilial("SL1")+SD2->D2_PEDIDO)
		DBSelectArea("SL2")
		DBSetOrder(1)
		DBSeek(xFilial("SL2")+SD2->D2_PEDIDO)
		_TES:= SL2->L2_TES
	ELSE
		DBSelectArea("SC5")
		DBSetOrder(1)
		DBSeek(xFilial("SC5")+SD2->D2_PEDIDO)
		DBSelectArea("SC6")
		DBSetOrder(1)
		DBSeek(xFilial("SC6")+SD2->D2_PEDIDO)
		_TES:= SC6->C6_TES
	Endif
	
	DBSelectArea("SF4")
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+_TES)
	
	IF lAbortPrint
		@ 00,01 PSay "** CANCELADO PELO OPERADOR **"
		lContinua := .F.
		Exit
	Endif
	
	nLinIni     := nLin                   // Linha Inicial da Impressao
	xCLIENTE    := SF2->F2_CLIENTE    // Codigo do Cliente
	xTIPO_CLI   := SF2->F2_TIPOCLI    // Tipo de Cliente
	xCONDPAG    := SF2->F2_COND    // Condicao de Pagamento
	xNUM_NF     := SF2->F2_DOC            // Numero
	xSERIE      := SF2->F2_SERIE          // Serie
	xSERIEAPR	:= SerieNfId('SF2',2,'F2_SERIE')	// Serie para apresenta็ใo - projeto chave ๚nica
	xEMISSAO    := SF2->F2_EMISSAO        // Data de Emissao
	xTOT_FAT    := SF2->F2_VALBRUT        // Valor Total da Nota
	xLOJA       := SF2->F2_LOJA           // Loja do Cliente
	xDESPACESS  := SF2->F2_DESPESA        // Despesa Acessorias
	xFRETE      := SF2->F2_FRETE          // Frete
	xSEGURO     := SF2->F2_SEGURO         // Seguro
	xBASE_ICMS  := SF2->F2_BASEICM        // Base   do ICMS
	xBASE_IPI   := SF2->F2_BASEIPI        // Base   do IPI
	xVALOR_ICMS := SF2->F2_VALICM         // Valor  do ICMS
	xICMS_RET   := SF2->F2_ICMSRET        // Valor  do ICMS Retido
	xBSICMRET   := SF2->F2_BRICMS         // Base   do ICMS Retido
	xVALOR_IPI  := SF2->F2_VALIPI         // Valor  do IPI
	xVALOR_MERC := SF2->F2_VALMERC        // Valor  da Mercadoria
	xNUM_DUPLIC := SF2->F2_DUPL           // Numero da Duplicata
	xCOND_PAG   := SF2->F2_COND           // Condicao de Pagamento
	xDESCONTONF := SF2->F2_DESCONT        // Valor  da Mercadoria
	
	xBASEISS    := SF2->F2_BASEISS        // BASE DE ISS
	xALIQISS    := 0                      // Aliquota de ISS
	xVALISS     := SF2->F2_VALISS          // Valor de ISS
	xVALDEP     := 0                       // Valor do Deposito
	
	DBSelectArea("SD2")
	DBSetOrder(3)
	DBSeek(xFilial("SD2")+xNUM_NF+xSERIE)
	
	cPedAtu   := SD2->D2_PEDIDO
	cItemAtu  := SD2->D2_ITEMPV
	xPED_VEND := {}                       // Numero do Pedido de Venda
	xITEM_PED := {}                       // Numero do Item do Pedido de Venda
	xNUM_NFDV := {}                       // nUMERO QUANDO HOUVER DEVOLUCAO
	xPREF_DV  := {}                       // Serie  quando houver devolucao
	xICMS     := {}                       // Porcentagem do ICMS
	xCOD_PRO  := {}                       // Codigo  do Produto
	xQTD_PRO  := {}                       // Peso/Quantidade do Produto
	xPRE_UNI  := {}                       // Preco Unitario de Venda
	xIPI      := {}                       // Porcentagem do IPI
	xVAL_IPI  := {}                       // Valor do IPI
	xDESCONT  := {}                       // Desconto por Item
	xVAL_DESC := {}                       // Valor do Desconto
	xVAL_MERC := {}                       // Valor da Mercadoria
	xTES      := {}                       // TES
	xCF       := {}                       // Classificacao quanto natureza da Operacao
	xTESCFOP  := {}                       // Amarracao de TES e CFOP
	xVAL_ICM  := {}                       // Valor do ICMS do item
	xBASEICMS := {}                       // Base do ICMS do item
	xICMSOL   := {}                       // Base do ICMS Solidario
	xCompICMS := {}                       // ICMS do componente {Aliquota, Base, Valor ICMS}
	
	While !eof() .and. SD2->D2_FILIAL == xFilial("SD2") .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
		
		If SerieNfId('SD2',2,'D2_SERIE') <> MV_PAR03
			DBSkip()
			Loop
		Endif
		
		lAddItem := .T.
		nPos     := Ascan(xCOD_PRO, SD2->D2_COD)
		
		If nPos <> 0
			If xPRE_UNI[nPos] == SD2->D2_PRUNIT .and. xTES[nPos] == SD2->D2_TES
				xQTD_PRO[nPos]  += SD2->D2_QUANT
				xVAL_MERC[nPos] += noRound(SD2->D2_TOTAL,2) //noRound(SD2->D2_PRUNIT * SD2->D2_QUANT,2)
				xDESCONT[nPos]  += noRound(SD2->D2_DESCON,2)
				xVAL_IPI[nPos]  += noRound(SD2->D2_VALIPI,2)
				lAddItem         := .F.
			Endif
		Endif
		If lAddItem
			AADD(xPED_VEND ,SD2->D2_PEDIDO)
			AADD(xITEM_PED ,SD2->D2_ITEMPV)
			AADD(xNUM_NFDV ,SD2->D2_NFORI)
			AADD(xPREF_DV  , SerieNfId('SD2',2,'D2_SERIORI') )
			AADD(xICMS     ,SD2->D2_PICM)
			AADD(xCOD_PRO  ,SD2->D2_COD)
			AADD(xQTD_PRO  ,SD2->D2_QUANT)
			AADD(xPRE_UNI  ,SD2->D2_PRUNIT)
			AADD(xIPI      ,SD2->D2_IPI)
			AADD(xVAL_IPI  ,SD2->D2_VALIPI)
			AADD(xDESCONT  ,SD2->D2_DESCON)
			
			//fOI Mudado pelo analista Hevaldo
			//Esta tendo diferenca de calculo.
			AADD(xVAL_MERC ,noRound(SD2->D2_TOTAL,2)) //SD2->D2_PRUNIT * SD2->D2_QUANT)
			AADD(xTES      ,SD2->D2_TES)
			AADD(xCF       ,SD2->D2_CF)
			AADD(xTESCFOP  ,{SD2->D2_TES,SD2->D2_CF})
			AADD(xBASEICMS ,SD2->D2_BASEICM)
			AADD(xVAL_ICM  ,SD2->D2_VALICM)
		Endif
		
		nDesSufra := nDesSufra + SD2->D2_DESCZFR
		DBSelectArea("SD2")
		DBskip()
		
	Enddo
	
	//  Desc. Generica do Produto
	DBSelectArea("SB1")
	DBSetOrder(1)
	xDESCRICAO := {}  // Descricao do Produto
	xUNID_PRO  := {}  // Unidade do Produto
	x2UNID_PRO := {}  // 2a. Unidade Medida do Produto
	xFTCONV    := {}  // Fator de conversฦo
	xTIPCONV   := {}  // Tipo de conversฦo de D ou M
	xCOD_TRIB  := {}  // Codigo de Tributacao
	xMEN_TRIB  := {}  // Mensagens de Tributacao
	xCLAS_FIS  := {}  // Classificacao Fiscal
	xISS       := {}  // Aliquota de ISS
	xTIPO_PRO  := {}  // Tipo do Produto
	xLUCRO     := {}  // Margem de Lucro p/ ICMS Solidario
	xCLFISCAL  := {}
	xCL_FISCAL := {}  // Cogigo Fiscal
	xPESO_LIQ  := 0
	xCONDPAG   := ''
	xREC_CLI   := ''  // Endereco de Entrega
	I          := 1
	
	For I:=1 to Len(xCOD_PRO)
		DBSeek(xFilial("SB1")+xCOD_PRO[I])
		// 2a. Unidade Medida do Produto e fatores de conversao
		AADD(xUNID_PRO  ,SB1->B1_UM)
		AADD(x2UNID_PRO ,SB1->B1_SEGUM)
		AADD(xFTCONV    ,SB1->B1_CONV)     // Fator de conversฦo
		AADD(xTIPCONV   ,SB1->B1_TIPCONV)  // Tipo de conversฦo de D ou M
		AADD(xDESCRICAO ,SB1->B1_DESC)
		AADD(xCOD_TRIB  ,SB1->B1_ORIGEM)
		If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
			AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
		Endif
		
		If Ascan(xCLAS_FIS,SB1->B1_POSIPI) == 0
			AADD(xCLAS_FIS, SB1->B1_POSIPI)
		Endif
		
		If Ascan(xCLFISCAL,SB1->B1_CLASFIS) == 0
			AADD(xCLFISCAL ,SB1->B1_CLASFIS)
		Endif
		AADD(xCL_FISCAL,SB1->B1_CLASFIS)
		If SB1->B1_ALIQISS > 0
			AADD(xISS   ,SB1->B1_ALIQISS)
		Endif
		AADD(xTIPO_PRO ,SB1->B1_TIPO)
		AADD(xLUCRO    ,SB1->B1_PICMRET)
	Next
	
	// Pesquisa da Condicao de Pagto
	DBSelectArea("SE4")
	DBSetOrder(1)
	DBSeek(xFilial("SE4")+xCONDPAG)
	xDESC_PAG := SE4->E4_DESCRI
	
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+xCLIENTE+xLOJA)
	xCOD_CLI  := SA1->A1_COD      // Codigo do Cliente
	xNOME_CLI := SA1->A1_NOME     // Nome
	xEND_CLI  := SA1->A1_END      // Endereco
	xBAIRRO   := SA1->A1_BAIRRO   // Bairro
	xCEP_CLI  := SA1->A1_CEP      // CEP
	xENT_CLI  := SA1->A1_ENDENT   // Endereco de Entrega
	xENT_BAIR := SA1->A1_BAIRROE  // Bairro de Entrega
	xENT_MUN  := SA1->A1_MUNE     // Cidade da Entrega
	xENT_EST  := SA1->A1_ESTE     // Estado de Entrega
	xENT_CEP  := SA1->A1_CEPE     // Cep de Entrega
	xMUN_CLI  := SA1->A1_MUN      // Municipio
	xEST_CLI  := SA1->A1_EST      // Estado
	xCGC_CLI  := SA1->A1_CGC      // CGC
	xINSC_CLI := SA1->A1_INSCR    // Inscricao estadual
	xTRAN_CLI := SA1->A1_TRANSP   // Transportadora
	xTEL_CLI  := SA1->A1_TEL      // Telefone
	xFAX_CLI  := SA1->A1_FAX      // Fax
	xSUFRAMA  := SA1->A1_SUFRAMA  // Codigo Suframa
	xNUMSUFRA := SA1->A1_SUFRAMA
	xCALCSUF  := SA1->A1_CALCSUF  // Calcula Suframa
	
	// Alteracao p/ Calculo de Suframa
	If !Empty(xSUFRAMA) .and. xCALCSUF =="S"
		IF XTIPO == 'D' .OR. XTIPO == 'B'
			zFranca := .F.
		Else
			zFranca := .T.
		Endif
	Else
		zfranca:= .F.
	Endif
	
	DBSelectArea("SE1")
	xPARC_DUP  :={}                  // Parcela
	xVENC_DUP  :={}                  // Vencimento
	xVALOR_DUP :={}                  // Valor
	DBSetOrder(1)
	xDUPLICATAS := IIF(DBSeek(xFilial("SE1")+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
	While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_NUM==xNUM_DUPLIC
		IF E1_TIPO == "NF "
			AADD(xPARC_DUP ,SE1->E1_PARCELA)
			AADD(xVENC_DUP ,SE1->E1_VENCTO)
			AADD(xVALOR_DUP,SE1->E1_VALOR)
		ENDIF
		DBSkip()
	Enddo
	
	xITE_ICMS := ""
	xMEN_ICMS := ""
	XITE_IPI  := ""
	xMEN_IPI  := ""
	cItemCg   := " "
	
	Imprime()  // Imprime a NF
	
	IncRegua() // Termometro de Impressao
	
	//nLin:=0
	DBSelectArea("SF2")
	DBSkip()
	
Enddo

DBSelectArea("SF2")
Retindex("SF2")
DBSelectArea("SD2")
Retindex("SD2")
DBSelectArea("SC5")
Retindex("SC5")
DBSelectArea("SC6")
Retindex("SC6")
DBSelectArea("SL1")
Retindex("SL1")
DBSelectArea("SL2")
Retindex("SL2")




If cNota == NIL
	SET DEVICE TO SCREEN
	If aReturn[5] == 1
		SET PRINTER TO
		DBcommitAll()
		ourspool(wnrel)
	Endif
Else
	SET PRINTER TO
	SET DEVICE TO SCREEN
	DBcommitAll()
Endif

SetPgEject(.F.)
MS_FLUSH()

Return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function VerImp()   // Verifica posicionamento de papel na Impressora
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
nLin    := 0
nLinIni := 0
If aReturn[5]==2
	nOpc := 1
	While .T.
		SetPrc(0,0)
		DBCommitAll()
		@ nLin ,000 PSay " "
		@ nLin ,004 PSay "*"
		@ nLin ,022 PSay "."
		IF MsgYesNo("Fomulario esta posicionado ? ")
			nOpc := 1
		ElseIF MsgYesNo("Tenta Novamente ? ")
			nOpc := 2
		Else
			nOpc := 3
		Endif
		Do Case
			Case nOpc==1
				lContinua:=.T.
				Exit
			Case nOpc==2
				Loop
			Case nOpc==3
				lContinua:=.F.
				Return
		EndCase
	Enddo
Endif
Return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Imprime()   // Imprime a Nota Fiscal de Entrada e de Saida
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
nLin := 00

@ nLin,001 PSay Chr(27) + Chr(70)                     // Desativa Negrito
@ nLin,002 PSay CHR(018)                            // Cancela Impressao comprimida

nLin += 05
@ nLin,063 PSay Chr(27) + Chr(69) + xSerieApr+" / "+xNUM_NF + Chr(27) + Chr(70)

//nLin += 06
//@ nLin,065 	 PSay xEMISSAO
//@ nLin,067 PSay StrZero(Month(xEMISSAO),2)
//@ nLin,071 PSay Year(xEMISSAO)

@ nLin, 001 PSay CHR(027)+CHR(049)                  // Impressao 1/8"
nLin += 11
@ nLin, 011 PSay Chr(27) + Chr(69) + xNOME_CLI + Chr(27) + Chr(70)       // Nome do Cliente
@ nLin, 069	PSay xEMISSAO
nLin += 2
@ nLin,011 PSay xEND_CLI                           // Endereco
@ nLin,040 PSay Substr(xBAIRRO,1,18)               // Bairro

nLin += 2
@ nLin,011 PSay xMUN_CLI                           // Municipio
@ nLin,040 PSay xEST_CLI                           // U.F.
@ nLin,049 PSay xCEP_CLI Picture "@R 99999-999"    // CEP
@ nLin,061 PSay " Prest.de Servicos"
nLin += 2
If Len(Alltrim(xCGC_CLI))>= 14
	@ nLin, 011 PSay Chr(27) + Chr(69) + xCGC_CLI Picture "@R 99.999.999/9999-99" + Chr(27) + Chr(70)
Else
	@ nLin, 011 PSay Chr(27) + Chr(69) + xCGC_CLI Picture "@R 999.999.999-99" + Chr(27) + Chr(70)
Endif
@ nLin, 040 PSay xINSC_CLI                          // Insc. Estadual
nLin += 1
@ nLin,064 PSay " Hospitalares"
@ nLin, 001 PSay CHR(18)+CHR(027)+CHR(050)                  // Impressao 1/6"

nLin += 4

ImpDetalhe()      // Detalhe da NF

If xDESC_SC5<>0
	@ nLin, 002  PSay xMENNOTA
	@ nLin, 067  PSay xDESC_SC5  Picture "@E (999,999.99)"
Endif

// Imprime o valor por extenso
// Gera o extenso do valor, formatando a variแvel com 200 caracteres preenchendo os espa็os em branco com *
cExtenso := PADR(Extenso(xTOT_FAT),148,"*")
// Imprime o extenso em duas linhas (174 caracteres em
// cada):
nLin := 54
@ nLin,01  PSay Chr(27) + Chr(69)						// Ativa Negrito
@nLin,10 PSay Substr(cExtenso,001,48)
nLin += 1
@nLin,10 PSay Substr(cExtenso,049,48)
nLin += 1
@nLin,10 PSay Substr(cExtenso,098,48)

@ nLin,01  PSay Chr(27) + Chr(69)						// Ativa Negrito
@ nLin,060 PSay xTOT_FAT Picture "@E 99,999,999.99"    // Total da Nota
@ nLin,001 PSay Chr(27) + Chr(70)                     // Desativa Negrito

nLin += 5
@nLin,04 PSay " Base ISS           Aliquota ISS        Valor ISS            Total da Nota"
nLin += 1
@nLin,04 PSay xBASEISS Picture "@E 99,999,999.99"    // BASE DE ISS
@nLin,21 PSay xALIQISS Picture "@E 99,999,999.99"    // ALIQUOTA ISS
@nLin,42 PSay xVALISS Picture "@E 99,999,999.99"     // VALOR ISS
@nLin,63 PSay xTOT_FAT Picture "@E 99,999,999.99"    // Total da Nota
nLin += 1
@nLin,04 PSay " Valor da Conta    Valor desconto       Valor deposito       Valor Liquido"
nLin += 1
@nLin,03 PSay xVALOR_MERC Picture "@E 99,999,999.99"    // VALOR DA CONTA
@nLin,21 PSay xDESCONTONF Picture "@E 99,999,999.99"    // DESCONTO NF
@nLin,42 PSay xVALDEP Picture "@E 99,999,999.99"     // VALOR DEPOSITO
@nLin,63 PSay xVALOR_MERC-(xDESCONTONF+xVALDEP) Picture "@E 99,999,999.99"    // Total da Nota


@ nLin,001 PSay CHR(018)                        		// Impressao comprimida
nLin := 0
@ nLin,001 PSay " "

SetPrc(0,0)

Return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function ImpDetalhe()   // Impressao de Linhas de Detalhe da Nota Fiscal
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local i
xB_ICMS_SOL := 0          // Base  do ICMS Solidario
xV_ICMS_SOL := 0          // Valor do ICMS Solidario

For I := 1 To Len(xCOD_PRO)
	
	DBSelectArea("SD2")
	DBSetOrder(1)
	DBSeek(xFilial("SD2")+xPED_VEND[I]+xITEM_PED[I])
	
	DBSelectArea("SF4")
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+xTES[I])
	_Linha01:= SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+xCOD_PRO[I],"SB1->B1_DESC"), 1,55)
	_Linha02:= SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+xCOD_PRO[I],"SB1->B1_DESC"),56,24)
	If Empty(_Linha02)
		@ nLin, 014  PSay Alltrim(_Linha01)+IIF(xTES[I]=="566"," - CCM","")
	Else
		@ nLin, 014  PSay ALLtrim(_linha01)
		nLin ++
		@ nLin, 014  PSay ALLtrim(_linha02)+IIF(xTES[I]=="566"," - CCM","")
	Endif
	@ nLin, 065  PSay xVAL_MERC[I]+xDESCONT[I]  Picture "@E 99,999,999.99"
	
	nLin ++
	
Next

Return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fItemCg()   // Busca o numero do ITEM dos produtos de notas fiscais compl. preco de consignacao
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DBSelectArea("SD2")
DBSetOrder(3)
DBseek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
IF SD2->D2_TES <> '573'  // TES de NF compl preco consignacao
	Return(.T.)
Endif
DBSelectArea("SB6")
DBSetOrder(4)
DBseek(xFilial("SB6")+SD2->D2_SERIORI+SD2->D2_NFORI)
While !Eof() .and. SD2->D2_FILIAL+SD2->D2_SERIORI+SD2->D2_NFORI ==;
	SB6->B6_FILIAL+SB6->B6_SERIE+SB6->B6_DOC
	cItemCg := cItemCg + If(Len(cItemCg)>1,', '+SB6->B6_ITEMPV,SB6->B6_ITEMPV)
	DBskip()
Enddo
Return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function CST()   // Codigo de Situacao Tributaria
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tabela A - Origem da Mercadoria
cTabA := "0"

If SB1->B1_IMPORT == "S"  // Produto Importado
	cTabA := "1"
Endif

// Tabela B - Tributacao pelo ICMS
cTabB := "99"

IF     SF4->F4_ICM == "S" .and. SF4->F4_LFICM == "T"
	cTabB := "00"
ElseIF SF4->F4_ICM == "S" .and. SF4->F4_LFICM == "T" .and. SF4->F4_INCSOL == "S"
	cTabB := "10"
ElseIF SF4->F4_ICM == "S" .and. SF4->F4_BASEICM > 0
	cTabB := "20"
ElseIF (SF4->F4_ICM == "S" .and. SF4->F4_LFICM == "I" .and. SF4->F4_INCSOL == "S") .or. (SF4->F4_ICM <> "S" .and. SF4->F4_INCSOL == "S")
	cTabB := "30"
ElseIF (SF4->F4_ICM == "S" .and. SF4->F4_LFICM == "I") .or. SF4->F4_ICM <> "S"
	cTabB := "40"
ElseIF SF4->F4_ICM == "S" .and. SF4->F4_LFICM == "T" .and. SF4->F4_INCSOL == "S" .and. SF4->F4_BASEICM > 0
	cTabB := "70"
Endif
Return (cTabA+cTabB)


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function CVF()   // Codigo
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
cCVF := ""

IF     SF4->F4_LFICM == "T"  // Tributado
	cCVF := "1"
ElseIF SF4->F4_LFICM == "I"  // Isento
	cCVF := "2"
ElseIF SF4->F4_LFICM == "O"  // Outros
	cCVF := "3"
Endif

IF SF4->F4_LFIPI == "T"  // Tributado
	cCVF := cCVF + "1"
ElseIF SF4->F4_LFIPI == "I"  // Isento
	cCVF := cCVF + "2"
ElseIF SF4->F4_LFIPI == "O"  // Outros
	cCVF := cCVF + "3"
Endif
Return (cCVF)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณVALIDPERG ณ Autor ณ  Marcio Costa         ณ Data ณ 26/10/00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica as perguntas incluกndo-as caso no existam        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especกfico para clientes Microsiga                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ValidPerg
Local i,j
_sAlias := Alias()
DBSelectArea("SX1")
DBSetOrder(1)
cPerg := PADR(cPerg,6)
aRegs := {}

//AAdd(aRegs,{cPerg,"00","Descricao.............?","","","mv_ch?","?",01,0,3,"C","","mv_par??","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"01","Da Nota Fiscal        ?","","","mv_ch1","C",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ate a Nota Fiscal     ?","","","mv_ch2","C",06,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Da Serie              ?","","","mv_ch3","C",03,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For I:=1 to Len(aRegs)
	If !DBSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to Max(FCount(), Len(aRegs[i]))
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
	Endif
Next

DBSelectArea(_sAlias)

Return
