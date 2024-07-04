#INCLUDE "protheus.ch"
#INCLUDE "OFIOR450.CH"
#INCLUDE "OFIXDEF.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "report.ch"

// Posicao da Matriz aAuxTT
#DEFINE ATT_TIPTEM		01 // Tipo de Tempo
#DEFINE ATT_LIBVOO 		02 // Numero da Liberacao do TT (VOO_LIBVOO)
#DEFINE ATT_CLIENTE 	03 // Cliente Faturar Para
#DEFINE ATT_LOJA 		04 // Loja Faturar Para
#DEFINE ATT_PRODUTIVO 	05 // Produtivo que fechou o TT
#DEFINE ATT_NUMNFI 		06 // Numero da Nota Fiscal
#DEFINE ATT_SERNFI 		07 // Serie da Nota Fiscal
#DEFINE ATT_TOTPECA 	08 // Total de Pecas
#DEFINE ATT_TEMPAD 		09 // Tempo Padrao
#DEFINE ATT_TEMTRA 		10 // Tempo Trabalhado
#DEFINE ATT_TEMCOB 		11 // Tempo Cobrado
#DEFINE ATT_TEMVEN 		12 // Tempo Vendido
#DEFINE ATT_TOTSRVC 	13 // Total Servicos
#DEFINE ATT_DEPINT 		14 // Departamento Interno
#DEFINE ATT_DEPGAR 		15 // Departamento Garantia
#DEFINE ATT_DATLIB 		16 // Data de Liberacao
#DEFINE ATT_DATFEC 		17 // Data de Fechamento
#DEFINE ATT_DATCAN 		18 // Data de Cancelamento
#DEFINE ATT_QTDPECA 	19 // Total de qtde de Pecas
#DEFINE ATT_NOME		20 // Nome do Cliente Faturar Para
#DEFINE ATT_SITTPO		21 // Situação do Tipo de Tempo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIOR450 º Autor ³ Rubens Takahashi   º Data ³ 27/12/12    º±±
±±ºPrograma  ³ OFIOR450 º Autor ³ Alecsandre Ferreira º Data ³ 10/12/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão de Ordens de Serviços                            º±±
±±ºDescricao2 ³ Adaptação da LGPD.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR450
	Local oReport
	Private lVO1DATSTA  := VO1->(FieldPos("VO1_DATSTA")) > 0
	Private aEmp      := FwLoadSM0()
	Private nEmp      := aScan(aEmp, {|i| i[1] == cEmpAnt .AND. i[2] == cFilAnt})

	Pergunte("OFR450", .F.)
	oReport := RptDefOS()
    oReport:nFontBody := 8
    oReport:oPage:nPaperSize := 9
    oReport:PrintDialog()
Return

Static Function RptDefOS()
	Local oReport
	Local cPerg			:= "OFR450"
	Local cDesc         := STR0226 // Este relatório tem por objetivo relacionar as ordens de serviços existentes no sistema por meio de diversos filtros, bem como exportar para planilha eletrônica. Desta forma, o usuário poderá configurar este relatório de acordo com suas necessidades e listar as ordens de serviço desejadas para realizar seus acompanhamentos e controles.
	Local oSection1
	Local oSection2
	Local oSection3
	Local oSection4
	Local oSection5
	Local oSection6
	Local oSection7
	Local oSection8
	Local oSection9

	Private cTitulo		:= STR0029 // Relatório de Ordens de Serviços
	Private cNomeRel	:= 'OFIOR450'

	oReport := TReport():New(;
        cNomeRel,;
        cTitulo,;
        cPerg,;
        {|oReport| RunRptOS(oReport)},;
        cDesc;
    )

	oReport:SetLineHeight(45)
	oReport:SetLandscape()
	oReport:DisableOrientation()

	// Dados da Empresa
	oSection1 := TRSection():New(oReport)
	TrCell():New(oSection1, "M0_NOMECOM", "SM0", STR0154,, 40) // Nome
	If !Empty(SM0->M0_ENDENT) // Endereço de Entrega
		TRCell():New(oSection1, "M0_ENDENT", "SM0", STR0155,, 30) // Endereço
	Endif
	If !Empty(SM0->M0_CIDENT) // Cidade de Entrega
		TRCell():New(oSection1, "M0_CIDENT", "SM0", STR0156,, 12) // Cidade
	Endif
	If !Empty(SM0->M0_ESTENT) // Estado de Entrega
		TRCell():New(oSection1, "M0_ESTENT", "SM0", STR0157,, 10) // Estado
	Endif
	If !Empty(SM0->M0_CEPENT) // CEP Entrega
		TRCell():New(oSection1, "M0_CEPENT", "SM0", STR0158,, 15) // CEP
	Endif
	TRCell():New(oSection1, "M0_TEL",  "SM0", STR0159,, 15) // Telefone
	TRCell():New(oSection1, "M0_CGC",  "SM0", STR0160,, 20) // CNPJ
	TRCell():New(oSection1, "M0_INSC", "SM0", STR0161,, 20) // IE
	If !Empty(SM0->M0_CODMUN)
		TRCell():New(oSection1, "M0_CODMUN", "SM0", STR0162,, 10) // Cód. Mun
	Endif
	oSection1:SetLinesBefore(1)

	// Titulo
	oSection2 := TRSection():New(oReport)
	TrCell():New(oSection2, "TIT1", "", "",, 40,,,  "CENTER")
	TrCell():New(oSection2, "TIT2", "", "",, 120,,, "CENTER")
	TrCell():New(oSection2, "TIT3", "", "",, 40,,,  "CENTER")
	oSection2:SetHeaderSection(.F.)

	// Resumo
	oSection3 := TRSection():New(oReport)
	TrCell():New(oSection3, "VOI_TIPTEM", "VOI", STR0163, "@!", 80,,,,,,,,,,, .T.) // Tipo de Tempo
	TrCell():New(oSection3, "VOI_DESTTE", "VOI", STR0164, "@!", 40) // Descrição
	TrCell():New(oSection3, "VO3_QTDREQ", "VO3", STR0165, "@!", 40,,, "RIGHT",, "RIGHT") // Qtde.
	TrCell():New(oSection3, "COUNT_PEC",  "",    STR0166, "@!", 40,,, "RIGHT") // Peças
	TrCell():New(oSection3, "VO4_TEMPAD", "VO4", STR0167, "@!", 40,,, "RIGHT") // Padrão
	TrCell():New(oSection3, "VO4_TEMTRA", "VO4", STR0168, "@!", 40,,, "RIGHT") // Trabal.
	TrCell():New(oSection3, "VO4_TEMCOB", "VO4", STR0169, "@!", 40,,, "RIGHT") // Cobrado
	TrCell():New(oSection3, "VO4_TEMVEN", "VO4", STR0170, "@!", 40,,, "RIGHT") // Vendido
	TrCell():New(oSection3, "VO4_VALSER",  "",   STR0171, "@!", 40,,, "RIGHT") // Serviços
	TrCell():New(oSection3, "COUNT_TT",   "",    STR0172, "@!", 40,,, "RIGHT") // Qtde. T.T.
	TrCell():New(oSection3, "COUNT_OS",   "",    STR0173, "@!", 40,,, "RIGHT",,,,,,,, .T.) //  Qtde. O.S.

	// Resumo Departamento
	oSection4 := TRSection():New(oReport)
	TrCell():New(oSection4, "VO4_DEPGAR", "VO4", STR0174, "@!", 80,,,,,,,,,,, .T.) // Departamento
	TrCell():New(oSection4, "VO3_QTDREQ", "VO3", STR0165, "@!", 40) // Qtde.
	TrCell():New(oSection4, "COUNT_PEC",  "",    STR0166, "@!", 40) // Peças
	TrCell():New(oSection4, "VO4_TEMPAD", "VO4", STR0167, "@!", 40) // Padrão
	TrCell():New(oSection4, "VO4_TEMTRA", "VO4", STR0168, "@!", 40) // Trabal.
	TrCell():New(oSection4, "VO4_TEMCOB", "VO4", STR0169, "@!", 40) // Cobrado
	TrCell():New(oSection4, "VO4_TEMVEN", "VO4", STR0170, "@!", 40) // Vendido
	TrCell():New(oSection4, "VO4_VALSER", "VO4", STR0171, "@!", 40) // Serviços
	TrCell():New(oSection4, "COUNT_OS",	  "",    STR0173, "@!", 40) // Qtde. O.S.

	// Resumo Tipo de Serviço
	oSection5 := TRSection():New(oReport)
	TrCell():New(oSection5, "VOK_TIPSER", "VOK", STR0175, "@!", 80,,,,,,,,,,, .T.) //
	TrCell():New(oSection5, "VOK_DESSER", "VOK", STR0164, "@!", 40) // Descrição
	TrCell():New(oSection5, "VO4_TEMPAD", "VO4", STR0167, "@!", 40) // Padrão
	TrCell():New(oSection5, "VO4_TEMVEN", "VO4", STR0170, "@!", 40) // Vendido
	TrCell():New(oSection5, "VO4_TEMTRA", "VO4", STR0168, "@!", 40) // Trabal.
	TrCell():New(oSection5, "VO4_TEMCOB", "VO4", STR0169, "@!", 40) // Cobrado
	TrCell():New(oSection5, "VO4_VALSER", "VO4", STR0176, "@!", 40) // Valor Serv.
	TrCell():New(oSection5, "COUNT_OS",   "",    STR0173, "@!", 40) // Qtde. O.S.

	// Cabecalho Sintético
	oSection6 := TRSection():New(oReport)
	TrCell():New(oSection6, "M0_FILIAL",  "SM0", STR0177,, 24) // Filial
	TrCell():New(oSection6, "VO1_NUMOSV", "VO1", STR0178,, 27) // Nro. O.S.
	TrCell():New(oSection6, "VO1_STATUS", "VO1", STR0179,, 30) // Status
	TrCell():New(oSection6, "VO1_DATABE", "VO1", STR0180,, 20) // Dt. Abert.
	TrCell():New(oSection6, "VO1_HORABE", "VO1", STR0181,, 26,,, "LEFT") // Hr. Abert.
	TrCell():New(oSection6, "VO1_FUNABE", "VO1", STR0182,, 40) // Consult. Abert.
	TrCell():New(oSection6, "A1_COD",     "SA1", STR0183,, 15) // Proprietário
	TrCell():New(oSection6, "A1_LOJA",    "SA1", STR0184,, 10) // Loja
	TrCell():New(oSection6, "A1_NOME",    "SA1", STR0154,, 40) // Nome
	TrCell():New(oSection6, "A1_CGC",     "SA1", STR0185, "@!", 30) // CPF/CNPJ
	TrCell():New(oSection6, "A1_END",     "SA1", STR0155,, 30) // Endereço
	TrCell():New(oSection6, "A1_MUN",     "SA1", STR0156,, 20) // Cidade
	TrCell():New(oSection6, "A1_EST",     "SA1", STR0076,, 10) // UF
	TrCell():New(oSection6, "A1_TEL",     "SA1", STR0159,, 30) // Telefone
	TrCell():New(oSection6, "VE1_CODMAR", "VE1", STR0186,, 15) // Marca
	TrCell():New(oSection6, "VE1_DESMAR", "VE1", STR0164,, 25) // Descrição
	TrCell():New(oSection6, "VV1_FABMOD", "VV1", STR0187,, 15) // Fab/Mod
	TrCell():New(oSection6, "VV1_MODVEI", "VV1", STR0188,, 15) // Modelo
	TrCell():New(oSection6, "VV2_DESMOD", "VV2", STR0189,, 25) // Desc. Mod.
	TrCell():New(oSection6, "VVC_DESCRI", "VVC", STR0190,, 15) // Cor
	TrCell():New(oSection6, "VV1_CHASSI", "VV1", STR0191,, 30) // Chassi
	TrCell():New(oSection6, "VV1_CHAINT", "VV1", STR0192,, 30) // Chassi Int.
	TrCell():New(oSection6, "VO1_KILOME", "VO1", STR0193,, 20,,, "LEFT") // Km.
	TrCell():New(oSection6, "VV1_PLAVEI", "VV1", STR0194,, 20) // Placa
	TrCell():New(oSection6, "VV1_CODFRO", "VV1", STR0195,, 30) // Cód. Frota
	oSection6:SetLineStyle()

	// Cabecalho Sintético OS
	oSection7 := TRSection():New(oReport)
	TrCell():New(oSection7, "VOI_TIPTEM", "VOI", STR0196,, 15) // Tp. Tempo
	TrCell():New(oSection7, "VOI_SITTPO", "VOI", STR0197,, 85) // Situação
	TrCell():New(oSection7, "A1_COD",	  "SA1", STR0198,, 15) // Cód. Cliente
	TrCell():New(oSection7, "A1_LOJA", 	  "SA1", STR0184,, 10) // Loja
	TrCell():New(oSection7, "A1_NOME", 	  "SA1", STR0154,, 75) // Nome
	TrCell():New(oSection7, "VO4_DEPGAR", "VO4", STR0199,, 15) // Dep. Garantia
	TrCell():New(oSection7, "VO4_DEPINT", "VO4", STR0200,, 85) // Dep. Interno
	TrCell():New(oSection7, "VO4_DATDIS", "VO4", STR0201,, 20) // Dt. Lib.
	TrCell():New(oSection7, "VO4_DATFEC", "VO4", STR0202,, 20) // Dt. Fechada
	TrCell():New(oSection7, "VO4_DATCAN", "VO4", STR0203,, 60) // Dt. Cancel.
	TrCell():New(oSection7, "VOO_LIBVOO", "VOO", STR0204,, 15) // Num. Lib.
	TrCell():New(oSection7, "VO4_FUNFEC", "VO4", STR0205,, 15) // Prdt. Fechou O.S.
	TrCell():New(oSection7, "F2_DOC", 	  "SF2", STR0206,, 25) // Num. NF
	TrCell():New(oSection7, "F2_SERIE",   "SF2", STR0207,, 35) // Série
	TrCell():New(oSection7, "VO4_TEMPAD", "VO4", STR0208,, 15,,, "LEFT") // Tp. Padrão
	TrCell():New(oSection7, "VO4_TEMTRA", "VO4", STR0209,, 15,,, "LEFT") // Tp. Trabalhado
	TrCell():New(oSection7, "VO4_TEMCOB", "VO4", STR0211,, 15,,, "LEFT") // Tp. Cobrado
	TrCell():New(oSection7, "VO4_TEMVEN", "VO4", STR0210,, 35,,, "LEFT") // Tp. Vendido
	TrCell():New(oSection7, "VO3_VALPEC", "VO3", STR0166, GetSX3Cache("F2_VALBRUT", "X3_PICTURE"), 60,,, "LEFT") // Peças
	TrCell():New(oSection7, "VO4_VALSER", "VO4", STR0171, GetSX3Cache("F2_VALBRUT", "X3_PICTURE"), 60,,, "LEFT") // Serviços
	oSection7:SetLineStyle()

	oSection8 := TRSection():New(oReport)
	TrCell():New(oSection8, "BM_GRUPO",   "SBM", STR0212,, 40) // Grupo
	TrCell():New(oSection8, "B1_CODITE",  "SB1", STR0213,, 40) // Cód. Peça
	TrCell():New(oSection8, "B1_DESC",    "SB1", STR0164,, 40) // Descrição
	TrCell():New(oSection8, "VO3_QTDREQ", "VO3", STR0214,, 40) // Quant.
	TrCell():New(oSection8, "VO3_PROREQ", "VO3", STR0215,, 40) // Prod. Req.
	TrCell():New(oSection8, "VO3_FORMUL", "VO3", STR0216,, 40) // Fórmula
	TrCell():New(oSection8, "VO3_VALPEC", "VO3", STR0217,, 40) // Valor Unit.
	TrCell():New(oSection8, "VO3_VALTOT", "",    STR0218, GetSX3Cache("VO3_VALPEC", "X3_PICTURE"), 40) // Valor Total

	oSection9 := TRSection():New(oReport,,,,,,, .T.)
	TrCell():New(oSection9, "VOK_TIPSER", "VOK", STR0175,"@!", 40) // Tipo Serv.
	TrCell():New(oSection9, "VOS_CODGRU", "VOS", STR0219,, 40) // Grupo Serv.
	TrCell():New(oSection9, "VO6_CODSER", "VO6", STR0220,, 40) // Cód Serv.
	TrCell():New(oSection9, "VO6_DESSER", "VO6", STR0164,, 40) // Descrição
	TrCell():New(oSection9, "VAI_CODTEC", "VAI", STR0221,, 40) // Cód. Prod.
	TrCell():New(oSection9, "VAI_NOMTEC", "VAI", STR0154,, 40) // Nome
	TrCell():New(oSection9, "VO4_KILROD", "VO4", STR0222, "@!", 40) // Kil. Rod.
	TrCell():New(oSection9, "VO4_TEMPAD", "VO4", STR0208,, 40) // Tp. Padrão    
	TrCell():New(oSection9, "VO4_TEMTRA", "VO4", STR0209,, 40) // Tp. Trabalhado
	TrCell():New(oSection9, "VO4_TEMCOB", "VO4", STR0211,, 40) // Tp. Cobrado   
	TrCell():New(oSection9, "VO4_TEMVEN", "VO4", STR0210,, 40) // Tp. Vendido   
	TrCell():New(oSection9, "VO4_VALSER", "VO4", STR0223,, 40) // Vlr. Tot. Serv.

Return oReport

/* /
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  27/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/ */

Static Function RunRptOS(oReport)
	Local nI
	Local nCont
	Local nContTT
	Local nCntFil
	Local nContApon
	Local nTemCobApo		:= 0
	Local nAuxTemCob		:= 0
	Local nAuxTemTra		:= 0
	Local nAuxTemVen		:= 0
	Local nPassagens		:= 0
	Local nAuxValorSrvc		:= 0
	Local nTamVV2TipVei		:= GetSX3Cache("VV2_TIPVEI", "X3_TAMANHO")
	Local nCntFor			:= 0
	Local cFilTT
	Local cFilDe
	Local cFilAte
	Local cFilBkp			:= cFilAnt
	Local cQuery
	Local cQueryVO3			:= ""
	Local cQueryVO4			:= ""
	Local cFilSA1			:= ""
	Local cFilSB1			:= ""
	Local cFilVOD			:= ""
	Local cFilVOI			:= ""
	Local cFilVOK			:= ""
	Local cFilSX5			:= ""
	Local cFilVS1			:= ""
	Local cFilVV8			:= ""
	Local cFilVX5			:= ""
	Local cProcTIPSER
	Local cProcTIPTEM
	Local cProcSITTPO
	Local cAuxProdutivo
	Local cQueryVO4DTCanc	:= ""
	Local lFilVO3VO4
	Local lConsVenda		:= .F.
	Local lReqZerada
	Local lA1_IBGE			:= SA1->(FieldPos("A1_IBGE")) <> 0
	Local lFirstS6 			:= .T.
	Local aSM0				:= FWLoadSM0()
	Local aAuxApon
	Local aResDepto			:= {}	// Resumo por Departamento
	Local aResTipSer		:= {}	// Resumo por Tipo de Servico
	Local aResTipTem		:= {}	// Resumo por Tipo de Tempo
	Local aResSitTpo		:= {}	// Resumo por Situacao do Tempo do Tipo de Tempo
	Local aAuxLinPeca
	Local aAuxLinSrvc
	Local aAuxResumo		:= {}
	Local lPrimLinha
	Local oExcel 			:= FWMSEXCEL():New()
	Local oSection1			:= oReport:Section(1)
	Local oSection2			:= oReport:Section(2)
	Local oSection3			:= oReport:Section(3)
	Local oSection4			:= oReport:Section(4)
	Local oSection5			:= oReport:Section(5)
	Local oSection6			:= oReport:Section(6)
	Local oSection7			:= oReport:Section(7)
	Local oSection8			:= oReport:Section(8)
	Local oSection9			:= oReport:Section(9)
	Private nCbCont     	:= 00
	Private nContFl     	:= 01
	Private nPosicao 		:= 0
	Private CbTxt       	:= Space(10)
	Private cString     	:= ""
	Private cTamanho    	:= "G"
	Private lEnd        	:= .F.
	Private lAbortPrint 	:= .F.
	Private lVO1DATSTA  	:= VO1->(FieldPos("VO1_DATSTA")) > 0
	Private aAuxTT
	Private aImpXls			:= {}
	lFilVO3VO4 := .F. // Filtra o VO1 de acordo com o VO3 e VO4

	If Empty(MV_PAR18) .AND. Upper(MV_PAR19) == "ZZZ"
		MsgInfo(STR0143 + STR0019 + STR0144, STR0045) //  "Se deseja verificar TODOS os TIPOS DE SERVIÇOS a pergunta " # " deverá estar com conteúdo VAZIO!" # "Atenção"
		Return
	Endif

	// Filtro por Tipo de Tempo
	If !Empty(Left(MV_PAR01, 1))
		// Monta string de filtro de tipo de tempo
		cFilTT := ""
		For nCont := 1 to Len(MV_PAR01) Step (GetSX3Cache("VOO_TIPTEM", "X3_TAMANHO") + 1)
			If !Empty(SubStr(MV_PAR01, nCont, GetSX3Cache("VOO_TIPTEM", "X3_TAMANHO")))
				cFilTT += SubStr(MV_PAR01, nCont, GetSX3Cache("VOO_TIPTEM", "X3_TAMANHO")) + ","
			EndIf
		Next
		If !Empty(cFilTT)
			cFilTT := FormatIN(Left(cFilTT, Len(cFilTT) - 1 ), ",")
		EndIf
		
		cQueryVO3 += " AND VO3.VO3_TIPTEM IN " + cFilTT
		cQueryVO4 += " AND VO4.VO4_TIPTEM IN " + cFilTT
	EndIf

	Do Case // Filtro por Status do Tipo de Tempo
		Case MV_PAR02 == 2 // Tipo de Tempo Aberto
			cQueryVO3 += " AND VO3.VO3_DATDIS = ' ' "
			cQueryVO3 += " AND VO3.VO3_DATFEC = ' ' " 
			cQueryVO3 += " AND VO3.VO3_DATCAN = ' ' "

			cQueryVO4 += " AND VO4.VO4_DATDIS = ' ' "
			cQueryVO4 += " AND VO4.VO4_DATFEC = ' ' " 
			cQueryVO4 += " AND VO4.VO4_DATCAN = ' ' "
		Case MV_PAR02 == 3 // Tipo de Tempo Liberado
			cQueryVO3 += " AND VO3.VO3_DATDIS <> ' ' "
			cQueryVO3 += " AND VO3.VO3_DATFEC = ' ' "
			cQueryVO3 += " AND VO3.VO3_DATCAN = ' ' "

			cQueryVO4 += " AND VO4.VO4_DATDIS <> ' ' "
			cQueryVO4 += " AND VO4.VO4_DATFEC = ' ' " 
			cQueryVO4 += " AND VO4.VO4_DATCAN = ' ' "
		Case MV_PAR02 == 4 // Tipo de Tempo Fechado
			cQueryVO3 += " AND VO3.VO3_DATDIS <> ' ' "
			cQueryVO3 += " AND VO3.VO3_DATFEC <> ' ' " 
			cQueryVO3 += " AND VO3.VO3_DATCAN = ' ' "

			cQueryVO4 += " AND VO4.VO4_DATDIS <> ' ' "
			cQueryVO4 += " AND VO4.VO4_DATFEC <> ' ' "
			cQueryVO4 += " AND VO4.VO4_DATCAN = ' ' "
		Case MV_PAR02 == 5 // Tipo de Tempo Cancelado
			cQueryVO3 += " AND VO3.VO3_DATCAN <> ' ' "
			cQueryVO4 += " AND VO4.VO4_DATCAN <> ' ' "
	End Case

	// Filtro por Data a Ser Considerada
	Do Case
		Case MV_PAR04 == 2 // Data de Liberacao
			cQueryVO3 += " AND VO3.VO3_DATDIS >= '" + DtoS(MV_PAR05) + "' "
			cQueryVO3 += " AND VO3.VO3_DATDIS <= '" + DtoS(MV_PAR06) + "' "

			cQueryVO4 += " AND VO4.VO4_DATDIS >= '" + DtoS(MV_PAR05) + "' "
			cQueryVO4 += " AND VO4.VO4_DATDIS <= '" + DtoS(MV_PAR06) + "' "
		Case MV_PAR04 == 3 // Data de Fechamento
			cQueryVO3 += " AND VO3.VO3_DATFEC >= '" + DtoS(MV_PAR05) + "' "
			cQueryVO3 += " AND VO3.VO3_DATFEC <= '" + DtoS(MV_PAR06) + "' "

			cQueryVO4 += " AND VO4.VO4_DATFEC >= '" + DtoS(MV_PAR05) + "' "
			cQueryVO4 += " AND VO4.VO4_DATFEC <= '" + DtoS(MV_PAR06) + "' "
		Case MV_PAR04 == 4 // Data de Cancelamento
			cQueryVO3 += " AND VO3.VO3_DATCAN >= '" + DtoS(MV_PAR05) + "' "
			cQueryVO3 += " AND VO3.VO3_DATCAN <= '" + DtoS(MV_PAR06) + "' "

			cQueryVO4 += " AND VO4.VO4_DATCAN >= '" + DtoS(MV_PAR05) + "' "
			cQueryVO4 += " AND VO4.VO4_DATCAN <= '" + DtoS(MV_PAR06) + "' "
			If lVO1DATSTA
				cQueryVO4DTCanc := " OR ( "
				cQueryVO4DTCanc += " 	VO4.VO4_DATCAN IS NULL "
				cQueryVO4DTCanc += " 	AND ( "
				cQueryVO4DTCanc += " 		VO1.VO1_DATSTA >= '" + DtoS(MV_PAR05) + "' "
				cQueryVO4DTCanc += " 		AND VO1.VO1_DATSTA <= '" + DtoS(MV_PAR06) + "' "
				cQueryVO4DTCanc += " 	) "
				cQueryVO4DTCanc += " ) "
			EndIf
	End Case

	If !Empty(MV_PAR09) .or. !Empty(MV_PAR10) // Filtro por Faturar Para
		cQueryVO3 += " AND VO3.VO3_FATPAR = '" + MV_PAR09 + "' "
		cQueryVO3 += IIf(!Empty(MV_PAR10), " AND VO3.VO3_LOJA = '" + MV_PAR10 + "' ", " ")

		cQueryVO4 += " AND VO4.VO4_FATPAR = '" + MV_PAR09 + "' "
		cQueryVO4 += IIf(!Empty(MV_PAR10), " AND VO4.VO4_LOJA = '" + MV_PAR10 + "' ", " ")
	EndIf
	If !Empty(MV_PAR15) // Filtro por Consultor de Fechamento
		cQueryVO3 += " AND VO3.VO3_FUNFEC = '" + MV_PAR15 + "' "
		cQueryVO4 += " AND VO4.VO4_FUNFEC = '" + MV_PAR15 + "' "
	EndIf
	If !Empty(MV_PAR16) // Filtro por Produtivo
		cQueryVO3 += " AND VO3.VO3_PROREQ = '" + MV_PAR16 + "' "
		cQueryVO4 += " AND VO4.VO4_CODPRO = '" + MV_PAR16 + "' "
	EndIf
	If !Empty(MV_PAR18) .or. !Empty(MV_PAR19) // Filtro por Tipo de Servico
		cQueryVO4 += " AND VO4.VO4_TIPSER >= '" + MV_PAR18 + "' "
		cQueryVO4 += " AND VO4.VO4_TIPSER <= '" + MV_PAR19 + "' "
	EndIf
	If !Empty(MV_PAR21) // Filtro por departamento interno
		cQueryVO3 += " AND VO3.VO3_DEPINT = '" + MV_PAR21 + "' "
		cQueryVO4 += " AND VO4.VO4_DEPINT = '" + MV_PAR21 + "' "
	EndIf
	If !Empty(MV_PAR22) // Filtro por departamento de garantia
		cQueryVO3 += " AND VO3.VO3_DEPGAR = '" + MV_PAR22 + "'"
		cQueryVO4 += " AND VO4.VO4_DEPGAR = '" + MV_PAR22 + "'"
	EndIf
	If !Empty(cQueryVO3) .AND. MV_PAR30 <> 3 // Criou algum filtro de Peca ...
		cQueryVO3 := SubStr(cQueryVO3, 5)
		lFilVO3VO4 := .T.
	Else
		cQueryVO3 := " "
	EndIf

	If !Empty(cQueryVO4) .AND. MV_PAR30 <> 2 // Criou algum filtro de Servico ...
		cQueryVO4 := SubStr(cQueryVO4, 5)
		lFilVO3VO4 := .T.
	Else
		cQueryVO4 := " "
	EndIf

	If !Empty(MV_PAR24) .OR. !Empty(MV_PAR25) // Filtro de Filial
		cFilDe  := MV_PAR24
		cFilAte := MV_PAR25
	Else
		cFilDe  := cFilAnt
		cFilAte := cFilAnt
	EndIf

	// Dados da Empresa
	oSection1:Init()
	oSection1:Cell("M0_NOMECOM"):SetValue(aEmp[nEmp, SM0_NOMECOM]) // Nome Comercial 
	If !Empty(SM0->M0_ENDENT)
		oSection1:Cell("M0_ENDENT"):SetValue(SM0->M0_ENDENT) 
	Endif
	If !Empty(SM0->M0_CIDENT)
		oSection1:Cell("M0_CIDENT"):SetValue(SM0->M0_CIDENT) //Cidade de Entrega
	Endif
	If !Empty(SM0->M0_ESTENT)
		oSection1:Cell("M0_ESTENT"):SetValue(SM0->M0_ESTENT) // Estado de Entrega
	Endif
	If !Empty(SM0->M0_CEPENT)
		oSection1:Cell("M0_CEPENT"):SetValue(SM0->M0_CEPENT) // CEP Entrega
	Endif
	oSection1:Cell("M0_TEL"):SetValue(SM0->M0_TEL) //Telefone
	oSection1:Cell("M0_CGC"):SetValue(aEmp[nEmp, SM0_CGC])
	oSection1:Cell("M0_INSC"):SetValue(SM0->M0_INSC)
	If !Empty(SM0->M0_CODMUN)
		oSection1:Cell("M0_CODMUN"):SetValue(SM0->M0_CODMUN)
	Endif
	oSection1:PrintLine()
	oSection1:Finish()

	// Gera Planilha
	If MV_PAR26 == 2
		oExcel:AddWorkSheet(STR0124)
		oExcel:AddTable(STR0124, STR0064)
		oExcel:AddColumn(STR0124, STR0064, STR0063, 1, 1) 				 // 01 - "FILIAL"
		oExcel:AddColumn(STR0124, STR0064, STR0065, 1, 1) 				 // 02 - "NRO_OS"
		oExcel:AddColumn(STR0124, STR0064, STR0138, 1, 1) 				 // 03 - "TP_ATEND"
		oExcel:AddColumn(STR0124, STR0064, STR0066, 1, 1) 				 // 04 - "DT_ABERT"
		oExcel:AddColumn(STR0124, STR0064, STR0067, 1, 1) 				 // 05 - "HR_ABERT"
		oExcel:AddColumn(STR0124, STR0064, STR0068, 1, 1) 				 // 06 - "CONS_ABE"
		oExcel:AddColumn(STR0124, STR0064, STR0069, 1, 2) 				 // 07 - "KM"
		oExcel:AddColumn(STR0124, STR0064, STR0070, 1, 1) 				 // 08 - "PROPRIETAR"
		oExcel:AddColumn(STR0124, STR0064, STR0071, 1, 1) 				 // 09 - "LOJA"
		oExcel:AddColumn(STR0124, STR0064, STR0072, 1, 1) 				 // 10 - "NOME_CLIEN"
		oExcel:AddColumn(STR0124, STR0064, STR0145, 1, 1) 				 // 11 - "CGC_CLI
		oExcel:AddColumn(STR0124, STR0064, STR0073, 1, 1) 				 // 12 - "ORÇAMENTO"
		oExcel:AddColumn(STR0124, STR0064, STR0074, 1, 1) 				 // 13 - "ENDEREÇO"
		oExcel:AddColumn(STR0124, STR0064, STR0075, 1, 1) 				 // 14 - "CIDADE"
		oExcel:AddColumn(STR0124, STR0064, STR0076, 1, 1) 				 // 15 - "UF"
		oExcel:AddColumn(STR0124, STR0064, STR0077, 1, 1) 				 // 16 - "TELEFONE"
		oExcel:AddColumn(STR0124, STR0064, STR0078, 1, 1) 				 // 17 - "MARCA"
		oExcel:AddColumn(STR0124, STR0064, STR0079, 1, 1) 				 // 18 - "MODELO"
		oExcel:AddColumn(STR0124, STR0064, STR0080, 1, 1) 				 // 19 - "FAB_MOD"
		oExcel:AddColumn(STR0124, STR0064, STR0081, 1, 1) 				 // 20 - "COR"
		oExcel:AddColumn(STR0124, STR0064, STR0082, 1, 1) 				 // 21 - "CHASSI_INT"
		oExcel:AddColumn(STR0124, STR0064, STR0083, 1, 1) 				 // 22 - "CHASSI"
		oExcel:AddColumn(STR0124, STR0064, STR0084, 1, 1) 				 // 23 - "PLACA"
		oExcel:AddColumn(STR0124, STR0064, STR0085, 1, 1) 				 // 24 - "COD_FROTA"
		oExcel:AddColumn(STR0124, STR0064, STR0128, 1, 1) 				 // 25 - "SEQ_INCON"
		oExcel:AddColumn(STR0124, STR0064, STR0129, 1, 1) 				 // 26 - "GRP_INCON"
		oExcel:AddColumn(STR0124, STR0064, STR0130, 1, 1) 				 // 27 - "COD_INCON"
		oExcel:AddColumn(STR0124, STR0064, STR0131, 1, 1) 				 // 28 - "DES_INCON"
		oExcel:AddColumn(STR0124, STR0064, STR0086, 1, 1) 				 // 29 - "TP"
		oExcel:AddColumn(STR0124, STR0064, STR0087, 1, 1) 				 // 30 - "LIB_VOO"
		oExcel:AddColumn(STR0124, STR0064, STR0088, 1, 1) 				 // 31 - "FAT_PAR"
		oExcel:AddColumn(STR0124, STR0064, STR0089, 1, 1) 				 // 32 - "LJ_PAR"
		oExcel:AddColumn(STR0124, STR0064, STR0090, 1, 1) 				 // 33 - "NOME_PAR"
		oExcel:AddColumn(STR0124, STR0064, STR0091, 1, 1) 				 // 34 - "DEPTO_GAR"
		oExcel:AddColumn(STR0124, STR0064, STR0092, 1, 1) 				 // 35 - "DEPTO_INT"
		oExcel:AddColumn(STR0124, STR0064, STR0093, 1, 1) 				 // 36 - "CONS_FEC"
		oExcel:AddColumn(STR0124, STR0064, STR0094, 1, 1) 				 // 37 - "DT_LIB"
		oExcel:AddColumn(STR0124, STR0064, STR0095, 1, 1) 				 // 38 - "DT_FEC"
		oExcel:AddColumn(STR0124, STR0064, STR0096, 1, 1) 				 // 39 - "DT_CAN"
		oExcel:AddColumn(STR0124, STR0064, STR0097, 1, 1) 				 // 40 - "NRO_NF"
		oExcel:AddColumn(STR0124, STR0064, STR0227, 1, 1)             	 // 41 - SERIE_NF
		oExcel:AddColumn(STR0124, STR0064, STR0098, 1, 1) 				 // 42 - "PECAS_TT"
		oExcel:AddColumn(STR0124, STR0064, STR0099, 1, 1) 				 // 43 - "TPOPAD_TT"
		oExcel:AddColumn(STR0124, STR0064, STR0100, 1, 1) 				 // 44 - "TPOTRA_TT"
		oExcel:AddColumn(STR0124, STR0064, STR0101, 1, 1) 				 // 45 - "TPOCOB_TT"
		oExcel:AddColumn(STR0124, STR0064, STR0102, 1, 1) 				 // 46 - "TPOVEN_TT"
		oExcel:AddColumn(STR0124, STR0064, STR0103, 1, 1) 				 // 47 - "SERVICO_TT"
		oExcel:AddColumn(STR0124, STR0064, STR0104, 1, 1) 				 // 48 - "RELACAO"
		oExcel:AddColumn(STR0124, STR0064, STR0105, 1, 1) 				 // 49 - "GRUPO"
		oExcel:AddColumn(STR0124, STR0064, STR0106, 1, 1) 				 // 50 - "COD_ITEM"
		oExcel:AddColumn(STR0124, STR0064, STR0107, 1, 1) 				 // 51 - "DES_ITEM"
		oExcel:AddColumn(STR0124, STR0064, STR0108, 1, 2) 				 // 52 - "QTDADE"
		oExcel:AddColumn(STR0124, STR0064, STR0109, 1, 1) 				 // 53 - "PROD_REQ"
		oExcel:AddColumn(STR0124, STR0064, STR0110, 1, 1) 				 // 54 - "FORMULA"
		oExcel:AddColumn(STR0124, STR0064, STR0111, 1, 1) 				 // 55 - "VLR_UNIT"
		oExcel:AddColumn(STR0124, STR0064, STR0112, 1, 1) 				 // 56 - "VLR_TOTAL"
		oExcel:AddColumn(STR0124, STR0064, STR0113, 1, 1) 				 // 57 - "TIPO_SRV"
		oExcel:AddColumn(STR0124, STR0064, STR0114, 1, 1) 				 // 58 - "GRUPO_SRV"
		oExcel:AddColumn(STR0124, STR0064, STR0115, 1, 1) 				 // 59 - "COD_SRV"
		oExcel:AddColumn(STR0124, STR0064, STR0116, 1, 1) 				 // 60 - "DES_SRV"
		oExcel:AddColumn(STR0124, STR0064, STR0117, 1, 1) 				 // 61 - "PRODUTIVO"
		oExcel:AddColumn(STR0124, STR0064, STR0118, 1, 1) 				 // 62 - "NOME_PROD"
		oExcel:AddColumn(STR0124, STR0064, STR0119, 1, 1) 				 // 63 - "TPOPAD"
		oExcel:AddColumn(STR0124, STR0064, STR0120, 1, 1) 				 // 64 - "TPOTRA"
		oExcel:AddColumn(STR0124, STR0064, STR0121, 1, 1) 				 // 65 - "TPOCOB"
		oExcel:AddColumn(STR0124, STR0064, STR0122, 1, 1) 				 // 66 - "TPOVEN"
		oExcel:AddColumn(STR0124, STR0064, STR0123, 1, 1) 				 // 67 - "SERVIÇO"
		oExcel:AddColumn(STR0124, STR0064, RetTitle("VO4_KILROD"), 1, 2) // 68 - KM Rodado
		oExcel:AddColumn(STR0124, STR0064, STR0225, 1, 1) 			 	 // 69 - Ori/Par
	EndIf

	For nCntFil := 1 to Len(aSM0)
		// Filtro de Filial
		If !(aSM0[nCntFil, 1] == cEmpAnt .and. (aSM0[nCntFil, 2] >= cFilDe .and. aSM0[nCntFil, 2] <= cFilAte))
			Loop
		EndIf

		// Altera filial corrente...
		cFilAnt := aSM0[nCntFil, 2]
		nPassagens += FMX_OFIPASS(MV_PAR05, MV_PAR06, .F.)[1, 2]

		cFilSA1 := xFilial("SA1")
		cFilSB1 := xFilial("SB1")
		cFilVOK := xFilial("VOK")
		cFilSX5 := xFilial("SX5")
		cFilVOI := xFilial("VOI")
		cFilVOD := xFilial("VOD")
		cFilVV8 := xFilial("VV8")
		cFilVX5 := xFilial("VX5")
		cFilVS1 := xFilial("VS1")

		cQuery := " SELECT "
		cQuery += "		* "
		cQuery += " FROM ( "
		cQuery += " 	SELECT "
		cQuery += "			VO1.VO1_FILIAL, "
		cQuery += "			VO1.VO1_NUMOSV, "
		cQuery += "			VO1.VO1_TPATEN, "
		cQuery += "			VO1.VO1_PROVEI, "
		cQuery += "			VO1.VO1_LOJPRO, "
		cQuery += "			VO1.VO1_DATABE, "
		cQuery += "			VO1.VO1_FUNABE, "
		cQuery += "			VO1.VO1_HORABE, "
		cQuery += "			VO1.VO1_NUMORC, "
		cQuery += "			VO1.VO1_KILOME, "
		cQuery += "			VO1.VO1_NUMAGE, "
		cQuery += "			VO1.R_E_C_N_O_ RECVO1, "
		cQuery += " 		COUNT(VO2.VO2_NOSNUM) COUNTVO2, "
		cQuery += " 		A1_NOME, "
		cQuery += "			A1_TEL, "
		cQuery += "			A1_END, "
		cQuery += "			A1_CGC, "
		cQuery += " 		A1_PESSOA, "
		If lA1_IBGE
			cQuery += " 	VAM.VAM_DESCID CIDADE, "
			cQuery += " 	VAM.VAM_ESTADO UF, "
		Else
			cQuery += " 	SA1.A1_MUN CIDADE, "
			cQuery += " 	SA1.A1_EST UF, "
		EndIf
		cQuery += " 		VV1.VV1_CODMAR, "
		cQuery += " 		VV1.VV1_MODVEI, "
		cQuery += " 		VV1.VV1_CHAINT, "
		cQuery += " 		VV1.VV1_FABMOD, "
		cQuery += " 		VV1.VV1_CHASSI, "
		cQuery += " 		VV1.VV1_PLAVEI, "
		cQuery += " 		VV1.VV1_CODFRO, "
		cQuery += " 		VV1.VV1_PROATU, "
		cQuery += " 		VV1.VV1_LJPATU, "
		cQuery += " 		VV2.VV2_DESMOD, "
		cQuery += " 		VV2.VV2_TIPVEI, "
		cQuery += " 		VVC.VVC_DESCRI, "
		/* If MV_PAR28 == 2 .AND. MV_PAR26 == 2 // Causa Duplicação na Impressão. Só era utilizado na impressão da planilha, desta forma, a consulta é feita somente no preenchimento da planilha
			cQuery += " 	VST.VST_CODIGO, "
			cQuery += " 	VST.VST_SEQINC, "
			cQuery += " 	VST.VST_GRUINC, "
			cQuery += " 	VST.VST_CODINC, "
			cQuery += " 	VST.VST_DESINC, "
		Endif */
		If MV_PAR04 == 4 // Considera pela data de Cancelamento
			cQuery += " 	VO3_DATCAN, "
			cQuery += " 	VO4_DATCAN, "
		EndIf
		If lVO1DATSTA
			cQuery += "		VO1_DATSTA, "
		EndIf
		cQuery += " 		VO1_STATUS "
		cQuery += " 	FROM "
		cQuery += " 		" + RetSQLName("VO1") + " VO1 "
		cQuery += " 		LEFT JOIN " + RetSQLName("SA1") + " A1 "
		cQuery += "			ON "
		cQuery += "				A1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += "				AND A1.A1_COD = VO1.VO1_PROVEI "
		cQuery += "				AND A1.A1_LOJA = VO1.VO1_LOJPRO "
		cQuery += "				AND A1.D_E_L_E_T_ = ' ' "
		If lA1_IBGE
			cQuery += "		LEFT JOIN " + RetSQLName("VAM") + " VAM "
			cQuery += "		ON "
			cQuery += "			VAM.VAM_FILIAL = '" + xFilial("VAM") + "' "
			cQuery += "			AND VAM.VAM_IBGE = A1.A1_IBGE "
			cQuery += "			AND VAM.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += " 		LEFT JOIN " + RetSqlName("VV1") + " VV1 "
		cQuery += "			ON "
		cQuery += "				VV1.VV1_FILIAL = '" + xFilial("VV1") + "' "
		cQuery += "				AND VV1.VV1_CHAINT = VO1.VO1_CHAINT "
		cQuery += "				AND VO1.D_E_L_E_T_ = ' ' "
		cQuery += " 		LEFT JOIN " + RetSqlName("VV2") + " VV2 "
		cQuery += "			ON "
		cQuery += "				VV2.VV2_FILIAL = '" + xFilial("VV2") + "' "
		cQuery += "				AND VV2.VV2_CODMAR = VV1.VV1_CODMAR "
		cQuery += "				AND VV2.VV2_MODVEI = VV1.VV1_MODVEI "
		cQuery += "				AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD "
		cQuery += "				AND VV2.D_E_L_E_T_ = ' ' "
		cQuery += " 		LEFT JOIN " + RetSqlName("VVC") + " VVC "
		cQuery += "			ON "
		cQuery += "				VVC.VVC_FILIAL = '" + xFilial("VVC") + "' "
		cQuery += "				AND VVC.VVC_CODMAR = VV1.VV1_CODMAR "
		cQuery += "				AND VVC.VVC_CORVEI = VV1.VV1_CORVEI "
		cQuery += "				AND VVC.D_E_L_E_T_ = ' ' "
		If MV_PAR20 == 2 .AND. (MV_PAR04 == 1 .OR. (MV_PAR04 == 4 .AND. lVO1DATSTA)) // Lista OS Sem Requisicao e (Filtra Data de Abertura ou Data de Cancelamento e Existe o Campo VO1_DATSTA)
			cQuery += "		LEFT "
		EndIf
		cQuery += " 		JOIN " + RetSqlName("VO2") + " VO2 "
		cQuery += "			ON "
		cQuery += "				VO2_FILIAL = '" + xFilial("VO2") + "' "
		cQuery += "				AND VO2_NUMOSV = VO1_NUMOSV "
		cQuery += "				AND VO2.D_E_L_E_T_ = ' ' "
		If lFilVO3VO4 .OR. (MV_PAR28 == 2 .AND. MV_PAR26 == 2) // Utiliza requisicao de peca/servico para filtrar...
			cQuery += " 	LEFT JOIN " + RetSqlName("VO3") + " VO3 "
			cQuery += "		ON "
			cQuery += "			VO3_FILIAL = '" + xFilial("VO3") + "' "
			cQuery += "			AND VO2_TIPREQ = 'P' "
			cQuery += "			AND VO3_NOSNUM = VO2_NOSNUM "
			cQuery += "			AND VO3.D_E_L_E_T_ = ' ' "
			cQuery += " 	LEFT JOIN " + RetSqlName("VO4") + " VO4 "
			cQuery += "		ON "
			cQuery += "			VO4_FILIAL = '" + xFilial("VO4") + "' "
			cQuery += "			AND VO2_TIPREQ = 'S' "
			cQuery += "			AND VO4_NOSNUM = VO2_NOSNUM "
			cQuery += "			AND VO4.D_E_L_E_T_ = ' ' "
		EndIf
		/*IF MV_PAR28 == 2 .AND. MV_PAR26 == 2 // Causa Duplicação na Impressão. Só era utilizado na impressão da planilha, desta forma, a consulta é feita somente no preenchimento da planilha
			cQuery += " 	LEFT JOIN " + RetSqlName("VST") + " VST "
			cQuery += "		ON "
			cQuery += "			VST.VST_FILIAL = '" + xFilial("VO3") + "' "
			cQuery += "			AND VO1.VO1_NUMOSV = VST.VST_CODIGO "
			cQuery += "			AND (VO4.VO4_SEQINC = VST.VST_SEQINC "
			cQuery += "				OR VO3.VO3_SEQINC = VST.VST_SEQINC) "
			cQuery += "			AND VST.D_E_L_E_T_ = ' ' "
		Endif*/
		cQuery += " 	WHERE "
		cQuery += " 		VO1.VO1_FILIAL = '" + xFilial("VO1") + "' "
		If !Empty(MV_PAR07)
			cQuery += " 	AND VO1.VO1_NUMOSV >= '" + MV_PAR07 + "' "
		EndIf
		If !Empty(MV_PAR08)
			cQuery += " 	AND VO1.VO1_NUMOSV <= '" + MV_PAR08 + "' "
		EndIf
		If MV_PAR04 == 1 // Considera pela data de Abertura
			cQuery += " 	AND VO1.VO1_DATABE >= '" + DtoS(MV_PAR05) + "' "
			cQuery += "		AND VO1.VO1_DATABE <= '" + DtoS(MV_PAR06) + "' "
		EndIf
		If !Empty(MV_PAR13)
			cQuery += " 	AND VO1.VO1_CHAINT = '" + MV_PAR13 + "' "
		EndIf
		If !Empty(MV_PAR14)
			cQuery += " 	AND VO1.VO1_FUNABE = '" + MV_PAR14 + "' "
		EndIf
		If !Empty(MV_PAR29)
			cQuery += " 	AND VO1.VO1_TPATEN = '" + MV_PAR29 + "' "
		EndIf
		If MV_PAR31 == 2 // Verifica status da O.S.
			cQuery += " 	AND VO1.VO1_STATUS = 'A' "
		Elseif MV_PAR31 == 3
			cQuery += " 	AND VO1.VO1_STATUS = 'D' "
		Elseif MV_PAR31 == 4
			cQuery += " 	AND VO1.VO1_STATUS = 'F' "
		Elseif MV_PAR31 == 5
			cQuery += " 	AND VO1.VO1_STATUS = 'C' "
		EndIf
		cQuery += " 		AND VO1.D_E_L_E_T_ = ' ' "		
		If !Empty(MV_PAR11) // Filtro por Marca de Veiculo
			cQuery += " 	AND VV1.VV1_CODMAR = '" + MV_PAR11 + "' "
		EndIf
		If !Empty(MV_PAR12) // Filtro por Modelo do Veiculo
			cQuery += " 	AND VV1.VV1_MODVEI = '" + MV_PAR12 + "' "
		EndIf
		If lFilVO3VO4 // Utiliza requisicao de peca/servico para filtrar ...
			cQuery += " 	AND ( "
			if !Empty(cQueryVO3) //  Filtro de Pecas
				cQuery += " 	(VO2.VO2_TIPREQ = 'P' "
				cQuery += "		AND " + cQueryVO3 + ") "
				cQuery += "     " + IIf(!Empty(cQueryVO4)," OR", "") + " "
			Endif
			if !Empty(cQueryVO4) //  Filtro de Servicos
				cQuery += " 	( "
				cQuery += "			(VO2.VO2_TIPREQ = 'S' "
				cQuery += " 		AND " + cQueryVO4 + ") "
				If !Empty(cQueryVO4DTCanc)
					cQuery += cQueryVO4DTCanc + " "
				EndIf
				cQuery += " 	) "
			Endif
			If MV_PAR20 == 2 .AND. MV_PAR04 == 1 // Lista OS's sem requisicao
				cQuery += " 	OR ( "
				cQuery += "			VO2_FILIAL IS NULL "
				///////////////////////////////////////////////////////////////////////////
				// ATENCAO: Quando NAO existir Requisicoes para a OS e o usuario filtrou //
				// um Tipo de Tempo especifico, a rotina deverá verificar o Status da OS //
				//                                                                       //
				// Exemplo: Se o usuario filtrar somente o Tipo de Tempo "Disponivel"    //
				//          NÂO serão listadas as OS sem requisição que estao com Status //
				//          de OS Cancelada                                              //
				///////////////////////////////////////////////////////////////////////////
				Do Case
					Case MV_PAR02 == 2 // Tipo de Tempo Aberto
						cQuery += " AND VO1.VO1_STATUS = 'A' "
					Case MV_PAR02 == 3 // Tipo de Tempo Liberado
						cQuery += " AND VO1.VO1_STATUS = 'D' "
				EndCase
				cQuery += " 	) "
			EndIf
			cQuery += " 	) "
		EndIf
		cQuery += " 	GROUP BY "
		cQuery += " 		VO1.VO1_FILIAL, "
		cQuery += " 		VO1.VO1_NUMOSV, "
		cQuery += " 		VO1.VO1_TPATEN, "
		cQuery += " 		VO1.VO1_PROVEI, "
		cQuery += " 		VO1.VO1_LOJPRO, "
		cQuery += " 		VO1_DATABE, "
		cQuery += " 		VO1_FUNABE, "
		cQuery += " 		VO1_HORABE, "
		cQuery += " 		VO1_NUMORC, "
		cQuery += " 		VO1_KILOME, "
		cQuery += " 		VO1_NUMAGE, "
		cQuery += " 		VO1.R_E_C_N_O_, "
		cQuery += " 		A1_NOME, "
		cQuery += " 		A1_TEL, "
		cQuery += " 		A1_END, "
		cQuery += " 		A1_CGC, "
		cQuery += " 		A1_PESSOA, "
		If lA1_IBGE
			cQuery += " 	VAM.VAM_DESCID, "
			cQuery += " 	VAM.VAM_ESTADO, "
		Else
			cQuery += " 	SA1.A1_MUN, "
			cQuery += " 	SA1.A1_EST, "
		EndIf
		cQuery += " 		VV1.VV1_CODMAR, "
		cQuery += " 		VV1.VV1_MODVEI, "
		cQuery += " 		VV1.VV1_CHAINT, "
		cQuery += " 		VV1.VV1_FABMOD, "
		cQuery += " 		VV1.VV1_CHASSI, "
		cQuery += " 		VV1.VV1_PLAVEI, " 
		cQuery += " 		VV1.VV1_CODFRO, "
		cQuery += " 		VV1.VV1_PROATU, " 
		cQuery += " 		VV1.VV1_LJPATU, "
		cQuery += " 		VV2.VV2_DESMOD, "
		cQuery += " 		VV2.VV2_TIPVEI, "
		cQuery += " 		VVC.VVC_DESCRI, "
		/*If MV_PAR28 == 2 .AND. MV_PAR26 == 2 // Causa Duplicação na Impressão. Só era utilizado na impressão da planilha, desta forma, a consulta é feita somente no preenchimento da planilha
			cQuery += "		VST.VST_CODIGO, "
			cQuery += "		VST.VST_SEQINC, "
			cQuery += "		VST.VST_GRUINC, "
			cQuery += " 	VST.VST_CODINC, "
			cQuery += " 	VST.VST_DESINC, "
		Endif*/
		If MV_PAR04 == 4 // Considera pela data de Cancelamento
			cQuery += " 	VO3_DATCAN, "
			cQuery += " 	VO4_DATCAN, "
		EndIf
		If lVO1DATSTA
			cQuery += " 	VO1_DATSTA, "
		EndIf
		cQuery += "			VO1_STATUS "
		cQuery += " 	) TMP"
		If MV_PAR04 == 4 // Considera pela data de Cancelamento
			cQuery += " WHERE "
			cQuery += " 	VO3_DATCAN IS NOT NULL "
			cQuery += " 	OR VO4_DATCAN IS NOT NULL "
			If lVO1DATSTA
				cQuery += " OR ( "
				cQuery += " 	VO1_DATSTA >= '" + DtoS(MV_PAR05) + "' "
				cQuery += " 	AND VO1_DATSTA <= '" + DtoS(MV_PAR06) + "' "
				cQuery += " ) "
			EndIf
		EndIf
		cQuery += " ORDER BY "
		cQuery += "		TMP.VO1_NUMOSV "
		TcQuery cQuery New Alias "QRYOS"

		While !QRYOS->(Eof())
			// Valida Segmento do Cliente
			If !Empty(MV_PAR23)
				cQuery := " SELECT "
				cQuery += " 	A1_SATIV1"
				cQuery += " FROM "
				cQuery += " 	" + RetSqlName("SA1") + " "
				cQuery += " WHERE "
				cQuery += " 	A1_FILIAL = '" + cFilSA1 + "' "
				If !Empty(QRYOS->VV1_PROATU)
					cQuery += " AND A1_COD = '" + QRYOS->VV1_PROATU + "' "
					cQuery += " AND A1_LOJA = '" + QRYOS->VV1_LJPATU + "' "
				Else
					cQuery += " AND A1_COD = '" + QRYOS->VO1_PROVEI + "' "
					cQuery += " AND A1_LOJA = '" + QRYOS->VO1_LOJPRO + "' "
				Endif
				cQuery += " 	AND D_E_L_E_T_ = ' ' "

				If FM_SQL(cQuery) != MV_PAR23
					QRYOS->(dbSkip())
					Loop
				Endif
			EndIf

			If MV_PAR20 == 1
				lReqZerada := .T.
			Else
				lReqZerada := .F.
			endif

			If MV_PAR32 == 2 // Verifica se OS tem Agendamento 
				If Empty(QRYOS->VO1_NUMAGE)
					cQuery := " SELECT "
					cQuery += "		VS1_NUMAGE "
					cQuery += " FROM "
					cQuery += " 	" + RetSqlName("VS1") + " "
					cQuery += " WHERE "
					cQuery += "		VS1_FILIAL = '" + cFilVS1 + "' "
					cQuery += " 	AND VS1_NUMOSV = '" + QRYOS->VO1_NUMOSV + "' "
					cQuery += " 	AND D_E_L_E_T_ = ' ' "
					If Empty(FM_SQL(cQuery))
						QRYOS->(dbSkip())
						Loop
					EndIf
				EndIf
			Endif

			aCalPeca := {}
			aCalSrvc := {}

			If MV_PAR30 <> 3 // Levanta as peças somente se o parametro for diferente de SO SERVICOS
				aCalPeca :=;
					FMX_CALPEC(;
						QRYOS->VO1_NUMOSV,; // cNumOS
	 					,;            		// cTipTem
	 					,;            		// cGruIte
	 					,;            		// cCodIte
	 					.T.,;        		// lMov
	 					.T.,;        		// lNegoc
	 					lReqZerada,; 		// lReqZerada
	 					.T.,;        		// lRetAbe
	 					.T.,;        		// lRetLib
	 					.T.,;        		// lRetFec
	 					.T.,;        		// lRetCan
	 					,;            		// cLibVOO
	 					cQueryVO3;    		// cFiltroSQL
					)
			EndIf

			If MV_PAR30 <> 2 // Levanta os servicos somente se o parametro for diferente de SO PECAS
				aCalSrvc :=;
					FMX_CALSER(;
						QRYOS->VO1_NUMOSV,; // cNumOS
						,;            		// cTipTem
						,;           		// cGruSer
						,;           		// cCodSer
						.T.,;        		// lApont
						.T.,;        		// lNegoc
						.T.,;        		// lRetAbe
						.T.,;        		// lRetLib
						.T.,;        		// lRetFec
						.T.,;        		// lRetCan
						,;           		// cLibVOO
						cQueryVO4;   		// cFiltroSQL
				)
			EndIf

			If MV_PAR20 == 1 .and. Len(aCalPeca) == 0 .and. Len(aCalSrvc) == 0 // Nao lista OS sem Requisicao
				QRYOS->(dbSkip())
				Loop
			Endif

			If MV_PAR03 <> 1 // Impressao diferente de resumida
				cDesModFab := Space(nTamVV2TipVei)
				VV8->(DbSeek(cFilVV8+QRYOS->(VV2_TIPVEI)))
				If VV8->(FieldPos("VV8_TPVFAB")) > 0
					VX5->(DbSeek(cFilVX5+"053"+VV8->VV8_TPVFAB)) // Tipo de Veículo - EDI
					cDesModFab := VX5->VX5_DESCRI
				EndIf
				If !lFirstS6
					For nCntFor := 1 to 3
						oReport:IncRow()
					Next
				Endif
				oSection6:Init()
				oSection6:Cell("M0_FILIAL"):SetValue(QRYOS->VO1_FILIAL)
				oSection6:Cell("VO1_NUMOSV"):SetValue(QRYOS->VO1_NUMOSV)
				If lVO1DATSTA
					oSection6:Cell("VO1_STATUS"):SetValue(X3CBOXDESC("VO1_STATUS", QRYOS->VO1_STATUS) + " - " + Dtoc(Stod(QRYOS->VO1_DATSTA)))
				Else
					oSection6:Cell("VO1_STATUS"):SetValue(X3CBOXDESC("VO1_STATUS", QRYOS->VO1_STATUS))
				Endif
				oSection6:Cell("VO1_DATABE"):SetValue(/*OR450FDATA(*/StoD(QRYOS->VO1_DATABE)/*)*/)
				oSection6:Cell("VO1_HORABE"):SetValue(/*Transform(*/QRYOS->VO1_HORABE/*, GetSX3Cache("VO1_HORABE", "X3_PICTURE"))*/)
				oSection6:Cell("VO1_FUNABE"):SetValue(QRYOS->VO1_FUNABE)
				oSection6:Cell("A1_COD"):SetValue(QRYOS->VO1_PROVEI)
				oSection6:Cell("A1_LOJA"):SetValue(QRYOS->VO1_LOJPRO)
				oSection6:Cell("A1_NOME"):SetValue(QRYOS->A1_NOME)
				oSection6:Cell("A1_CGC"):SetValue(IIF(QRYOS->A1_PESSOA == 'J', Transform(QRYOS->A1_CGC, "@R 99.999.999/9999-99"), Transform(QRYOS->A1_CGC, "@R 999.999.999-99")))
				oSection6:Cell("A1_END"):SetValue(QRYOS->A1_END)
				oSection6:Cell("A1_MUN"):SetValue(QRYOS->CIDADE)
				oSection6:Cell("A1_EST"):SetValue(QRYOS->UF)
				oSection6:Cell("A1_TEL"):SetValue(QRYOS->A1_TEL)
				oSection6:Cell("VE1_CODMAR"):SetValue(QRYOS->VV1_CODMAR)
				oSection6:Cell("VE1_DESMAR"):SetValue(cDesModFab)
				oSection6:Cell("VV1_FABMOD"):SetValue(/*Transform(*/QRYOS->VV1_FABMOD/*, GetSX3Cache("VV1_FABMOD", "X3_PICTURE"))*/)
				oSection6:Cell("VV1_MODVEI"):SetValue(QRYOS->VV1_MODVEI)
				oSection6:Cell("VV2_DESMOD"):SetValue(QRYOS->VV2_DESMOD)
				oSection6:Cell("VVC_DESCRI"):SetValue(QRYOS->VVC_DESCRI)
				oSection6:Cell("VV1_CHASSI"):SetValue(QRYOS->VV1_CHASSI)
				oSection6:Cell("VV1_CHAINT"):SetValue(QRYOS->VV1_CHAINT)
				oSection6:Cell("VO1_KILOME"):SetValue(/*Transform(*/QRYOS->VO1_KILOME/*, GetSX3Cache("VO1_KILOME", "X3_PICTURE"))*/)
				oSection6:Cell("VV1_PLAVEI"):SetValue(/*Transform(*/QRYOS->VV1_PLAVEI/*, GetSX3Cache("VV1_PLAVEI", "X3_PICTURE"))*/)
				oSection6:Cell("VV1_CODFRO"):SetValue(QRYOS->VV1_CODFRO)
				oSection6:PrintLine()
				oSection6:Finish()
				lFirstS6 := .F.
			EndIf

			SA1->(DbSetOrder(1))
			VOI->(dbSetOrder(1))

			aAuxTT := {}
			For nI := 1 to Len(aCalPeca)
				If aScan(aAuxTT, {|y| y[1] == aCalPeca[nI, 3] .and. y[2] == aCalPeca[nI, 25]}) == 0
					SA1->(DbSeek(cFilSA1+aCalPeca[nI, 15]+aCalPeca[nI, 16]))
					VOI->(DbSeek(cFilVOI+aCalPeca[nI, 3]))

					AADD(aAuxTT, {;
						aCalPeca[nI, 3],;							// 01 - Tipo de Tempo
						aCalPeca[nI, 25],;							// 02 - Numero da Liberacao do TT (VOO_LIBVOO)
						aCalPeca[nI, 15],;							// 03 - Cliente Faturar Para
						aCalPeca[nI, 16],;							// 04 - Loja Faturar Para
						"",;										// 05 - Produtivo que fechou o TT
						"",;										// 06 - Numero da Nota Fiscal
						"",;										// 07 - Série da Nota Fiscal
						0,;											// 08 - Total de Pecas
						0,;											// 09 - Tempo Padrao
						0,;											// 10 - Tempo Trabalhado
						0,;											// 11 - Tempo Cobrado
						0,;											// 12 - Tempo Vendido
						0,;											// 13 - Total Servicos
						"",;										// 14 - Departamento Interno
						"",;										// 15 - Departamento Garantia
						aCalPeca[nI, 17],;							// 16 - Data de Liberacao
						aCalPeca[nI, 19],;							// 17 - Data de Fechamento
						aCalPeca[nI, 18],;							// 18 - Data de Cancelamento
						0,;											// 19 - Total de qtde de Pecas
						SA1->A1_NOME,;								// 20 - Nome do Cliente Faturar Para
						X3CBOXDESC("VOI_SITTPO", VOI->VOI_SITTPO)}; // 21 - Situação do Tipo de Tempo
					)
				EndIf
			Next

			For nI := 1 to Len(aCalSrvc)
				If aScan(aAuxTT, {|y| y[1] == aCalSrvc[nI, 4] .AND. y[2] == aCalSrvc[nI, 38]}) == 0
					SA1->(DbSeek(cFilSA1+aCalSrvc[nI, 20]+aCalSrvc[nI, 21]))
					VOI->(DbSeek(cFilVOI+aCalSrvc[nI, 4]))

					AADD(aAuxTT, {;
						aCalSrvc[nI, 4],;							// 01 - Tipo de Tempo
						aCalSrvc[nI, 38],;							// 02 - Numero da Liberacao do TT (VOO_LIBVOO)
						aCalSrvc[nI, 20],;							// 03 - Cliente Faturar Para
						aCalSrvc[nI, 21],;							// 04 - Loja Faturar Para
						"",;										// 05 - Produtivo que fechou o TT
						"",;										// 06 - Numero da Nota Fiscal
						"",;										// 07 - Serie da NF
						0,;											// 08 - Total de Pecas
						0,;											// 09 - Tempo Padrao
						0,;											// 10 - Tempo Trabalhado
						0,;											// 11 - Tempo Cobrado
						0,;											// 12 - Tempo Vendido
						0,;											// 13 - Total Servicos
						"",;										// 14 - Departamento Interno
						"",;										// 15 - Departamento Garantia
						aCalSrvc[nI, 22],;							// 16 - Data de Liberacao
						aCalSrvc[nI, 24],;							// 17 - Data de Fechamento
						aCalSrvc[nI, 23],;							// 18 - Data de Cancelamento
						0,;											// 19 - Total de qtde de Pecas
						SA1->A1_NOME,;								// 20 - Nome do Cliente Faturar Para
						X3CBOXDESC("VOI_SITTPO", VOI->VOI_SITTPO)}; // 21 - Situação do Tipo de Tempo
					)
				EndIf
			Next

			// Ordena por tipo de tempo e liberacao da VOO
			aSort(aAuxTT,,, {|x, y| x[ATT_TIPTEM] + x[ATT_LIBVOO] < y[ATT_TIPTEM] + y[ATT_LIBVOO]})

			If MV_PAR26 == 2 .and. Len(aAuxTT) == 0 // Gera Planilha, se nao houver requisicao, cria uma linha so com informacoes da OS
				OR450APPEND(0)
			EndIf

			// Processa Tipo de Tempo ...
			cProcTIPSER := " "
			For nContTT := 1 to Len(aAuxTT)
				aAuxLinPeca := {}
				aAuxLinSrvc := {}
				SB1->(DbSetOrder(7))
				VOK->(DbSetOrder(1))
				VOI->(DbSetOrder(1))
				VOI->(DbSeek(cFilVOI+aAuxTT[nContTT, ATT_TIPTEM]))

				For nCont := 1 to Len(aCalPeca) // Processa Requisicao de Pecas
					If !(aCalPeca[nCont, 3] == aAuxTT[nContTT, ATT_TIPTEM] .AND. aCalPeca[nCont, 25] == aAuxTT[nContTT, ATT_LIBVOO]) // Compara tipo de tempo e liberacao do VOO
						Loop
					EndIf
					If aCalPeca[nCont, 05] == 0 // Se a quantidade for maior que 0 não considera o item
						Loop
					EndIf

					VO3->(DbGoTo(aCalPeca[nCont, 14, 01, 05]))
					SB1->(DbSeek(cFilSB1+aCalPeca[nCont, 01]+aCalPeca[nCont, 02]))
					SBM->(DbSetOrder(1))
					SBM->(DbSeek(xFilial("SBM")+aCalPeca[nCont, 01]))
					if SBM->BM_PROORI == "1"
						cParOri := STR0151 // "Original"
					Else
						cParOri := STR0152 // "Paralelo"
					Endif
					aAuxTT[nContTT, ATT_PRODUTIVO] := VO3->VO3_FUNFEC
					aAuxTT[nContTT, ATT_NUMNFI]    := VO3->VO3_NUMNFI
					aAuxTT[nContTT, ATT_SERNFI]	   := VO3->VO3_SERNFI
					aAuxTT[nContTT, ATT_DEPINT]    := VO3->VO3_DEPINT
					aAuxTT[nContTT, ATT_DEPGAR]    := VO3->VO3_DEPGAR
					aAuxTT[nContTT, ATT_QTDPECA]   += aCalPeca[nCont, 05]
					aAuxTT[nContTT, ATT_TOTPECA]   += aCalPeca[nCont, 10] - aCalPeca[nCont, 07]

					// Impressao analitica
					If MV_PAR03 == 3
						AADD(aAuxLinPeca, {;
							VO3->VO3_NOSNUM,;							// 01 - Numero da Requisicao
							aCalPeca[nCont, 01],;						// 02 - Grupo da Peca
							aCalPeca[nCont, 02],;						// 03 - Codigo da Peca
							SB1->B1_DESC,;								// 04 - Descricao da Peca
							aCalPeca[nCont, 05],;						// 05 - Quantidade
							VO3->VO3_PROREQ,;							// 06 - Produtivo que Requisitou
							aCalPeca[nCont, 27],;						// 07 - Formula
							aCalPeca[nCont, 09] - (aCalPeca[nCont, 07] / aCalPeca[nCont, 05]),;	// 08 - Valor Unitario
							aCalPeca[nCont, 10] - aCalPeca[nCont, 07],;	// 09 - Valor Total
							cParOri};  									// 10 - Original ou paralelo
						)
					EndIf
				Next
				
				For nCont := 1 to Len(aCalSrvc) // Processa Requisicao de Servicos
					// Compara tipo de tempo e liberacao do VOO
					If !(aCalSrvc[nCont, 4] == aAuxTT[nContTT, ATT_TIPTEM] .and. aCalSrvc[nCont, 38] == aAuxTT[nContTT, ATT_LIBVOO])
						Loop
					EndIf

					VO4->(DbGoTo(aCalSrvc[nCont, 14, 01, 08]))
					aAuxTT[nContTT, ATT_PRODUTIVO] := VO4->VO4_FUNFEC
					aAuxTT[nContTT, ATT_NUMNFI]    := VO4->VO4_NUMNFI
					aAuxTT[nContTT, ATT_SERNFI]    := VO4->VO4_SERNFI
					aAuxTT[nContTT, ATT_DEPINT]    := VO4->VO4_DEPINT
					aAuxTT[nContTT, ATT_DEPGAR]    := VO4->VO4_DEPGAR
					aAuxTT[nContTT, ATT_TEMPAD]    += aCalSrvc[nCont, 10]	// [08] - Tempo Padrao
					aAuxTT[nContTT, ATT_TEMTRA]    += aCalSrvc[nCont, 11]	// [09] - Tempo Trabalhado
					
					lConsVenda := (VOI->VOI_SITTPO <> "3" .OR. (VOI->VOI_SITTPO == "3" .AND. MV_PAR17 == 2))
					If lConsVenda // Nao é TT interno ou é interno deve exibir valores (MV_PAR17)
						nAuxTemCob := aCalSrvc[nCont, 12]
						nAuxTemVen := aCalSrvc[nCont, 13]
						aAuxTT[nContTT, ATT_TOTSRVC] += aCalSrvc[nCont, 09]	// [12] - Total Servicos
					Else
						nAuxTemCob := 0
						nAuxTemVen := 0
					Endif

					aAuxTT[nContTT, ATT_TEMCOB] += nAuxTemCob				// [10] - Tempo Cobrado
					aAuxTT[nContTT, ATT_TEMVEN] += nAuxTemVen				// [11] - Tempo Vendido

					VOD->(DbSetOrder(1))
					If MV_PAR03 == 3 // Impressao analitica
						// Totaliza por apontamento
						aAuxApon      := {}
						nAuxTemTra    := 0
						nTemCobApo    := 0
						nTemVenApo    := 0
						nAuxValorSrvc := 0
						cAuxProdutivo := aCalSrvc[nCont, 14, 01, 01]
						lPrimLinha    := .T.

						For nContApon := 1 to Len(aCalSrvc[nCont, 14])
							nAuxTemTra += aCalSrvc[nCont, 14, nContApon, 06]					// Tempo Trabalhado
							If lConsVenda // Nao é TT interno ou é interno deve exibir valores (MV_PAR17)
								If aCalSrvc[nCont, 6] == "2"
									nAuxValorSrvc := aCalSrvc[nCont, 14, nContApon, 10]
								Else
									VOK->(DbSeek(cFilVOK+aCalSrvc[nCont, 05]))									
									If Empty(aCalSrvc[nCont, 24]) .AND. VOK->VOK_INCTEM <> "3"	// Se nao estiver faturado, exibe o valor total do servico
										// nAuxValorSrvc := aCalSrvc[nCont,09]
										nAuxValorSrvc += aCalSrvc[nCont, 14, nContApon, 10]		// Valor do Servico
									EndIf
									If !Empty(aCalSrvc[nCont, 24]) .OR. VOK->VOK_INCTEM == "3"  // Se estiver faturado, exibe o valor por apontamento
										nAuxValorSrvc += aCalSrvc[nCont, 14, nContApon, 10]		// Valor do Servico
									EndIf
									nTemCobApo += aCalSrvc[nCont, 14, nContApon, 13]			// Tempo Cobrado
									nTemVenApo += aCalSrvc[nCont, 14, nContApon, 27]			// Tempo Vendido
								EndIf
							EndIf
							
							If (nContApon == Len(aCalSrvc[nCont, 14]) .OR. cAuxProdutivo <> aCalSrvc[nCont, 14, (nContApon + 1), 01] .OR.; // É o ultimo registro de apontamento ou mudou o produtivo ...
							aCalSrvc[nCont, 6] == "2")
								VOD->(DbSeek(cFilVOD+aCalSrvc[nCont, SRVC_CODSEC]))
								AADD(aAuxLinSrvc, {;
									aCalSrvc[nCont, 05],;                          // 01 - Tipo de Servico
									aCalSrvc[nCont, 01],;                          // 02 - Grupo do Servico
									aCalSrvc[nCont, 02],;                          // 03 - Codigo do Servico
									aCalSrvc[nCont, 15],;                          // 04 - Descricao do Servico
									cAuxProdutivo,;                                // 05 - Codigo do Produtivo
									Left(aCalSrvc[nCont, 14, nContApon, 12], 19),; // 06 - Nome do Produtivo
									IIf(lPrimLinha, aCalSrvc[nCont, 10], 0),;      // 07 - Tempo Padrao
									nAuxTemTra,;                                   // 08 - Tempo Trabalhado
									nTemCobApo,;                                   // 09 - Tempo Cobrado
									nTemVenApo,;                                   // 10 - Tempo Vendido
									nAuxValorSrvc,;                                // 11 - Valor do Servico (Liquido)
									aCalSrvc[nCont, SRVC_KILROD],;                 // 12 - Kilometragem rodada
									aCalSrvc[nCont, SRVC_INCMOB],;                 // 13 - Tipo de Cobranca
									VOD->VOD_DESSEC};                              // 14 - Codigo da Secao
								)
								
								If nContApon < Len(aCalSrvc[nCont,14]) // Zera contadores ...
									nAuxTemTra := 0
									nTemCobApo := 0
									nTemVenApo := 0
									nAuxValorSrvc := 0
									cAuxProdutivo := aCalSrvc[nCont, 14, (nContApon + 1), 01]
								EndIf
								lPrimLinha := .f.
							Endif
						Next

						If lConsVenda // .AND. Len(aCalSrvc[nCont, 14]) > 1
							// Totalizador do Serviço
							AADD(aAuxLinSrvc, {;
								" ",;                      // 01 - Tipo de Servico
								" ",;                      // 02 - Grupo do Servico
								" ",;                      // 03 - Codigo do Servico
								" ",;                      // 04 - Descricao do Servico
								" ",;                      // 05 - Codigo do Produtivo
								STR0038,; 		           // 06 - Nome do Produtivo
								aCalSrvc[nCont, 10],;      // 07 - Tempo Padrao
								aCalSrvc[nCont, 11],;      // 08 - Tempo Trabalhado
								aCalSrvc[nCont, 12],;      // 09 - Tempo Cobrado
								aCalSrvc[nCont, 13],;      // 10 - Tempo Vendido
								aCalSrvc[nCont, 09],;      // 11 - Valor do Servico (Liquido)
								aCalSrvc[1, SRVC_KILROD],; // 12 - Kilometragem rodada
								aCalSrvc[1, SRVC_INCMOB],; // 13 - Tipo de Cobranca
								VOD->VOD_DESSEC};          // 14 - Codigo da Secao
							)
						Endif
					Endif

					// Gera Resumo por Tipo de Servico
					If (nPosTipSer := aScan(aResTipSer, {|x| x[01] == QRYOS->VO1_FILIAL .AND. x[02] == aCalSrvc[nCont, 05]})) == 0
						VOK->(DbSeek(cFilVOK+aCalSrvc[nCont, 05]))
						AADD(aResTipSer, {QRYOS->VO1_FILIAL, aCalSrvc[nCont, 05], VOK->VOK_DESSER, VOK->VOK_TIPHOR, 0, 0, 0, 0, 0, 0})
						nPosTipSer := Len(aResTipSer)
					EndIf
					aResTipSer[nPosTipSer, 05] += aCalSrvc[nCont, 10] 		// [08] - Tempo Padrao
					aResTipSer[nPosTipSer, 07] += aCalSrvc[nCont, 11] 		// [09] - Tempo Trabalhado
					If lConsVenda // Nao é TT interno ou é interno deve exibir valores (MV_PAR17)
						aResTipSer[nPosTipSer, 08] += aCalSrvc[nCont, 12] 	// [10] - Tempo Cobrado
						aResTipSer[nPosTipSer, 06] += aCalSrvc[nCont, 13] 	// [11] - Tempo Vendido
						aResTipSer[nPosTipSer, 09] += aCalSrvc[nCont, 09] 	// [12] - Total Servicos
					Endif
					If !( aCalSrvc[nCont, 05] $ cProcTIPSER) // Soma a qtde de OS por Tipo de Servico
						aResTipSer[nPosTipSer, 10]++
					EndIf
					cProcTIPSER += aCalSrvc[nCont, 05] + "/" // Atualiza para nao calcular duplicado a qtde de tipo de servico na OS
				Next

				// Impressao sintetica ou impressao analitica
				If MV_PAR03 == 2 .OR. MV_PAR03 == 3
					oSection7:init()
					oSection7:Cell("VOI_TIPTEM"):SetValue(aAuxTT[nContTT, ATT_TIPTEM]) 																// Tipo de Tempo
					oSection7:Cell("VOI_SITTPO"):SetValue(aAuxTT[nContTT, ATT_SITTPO])																// Situação do Tipo de Tempo
					oSection7:Cell("A1_COD"):SetValue(aAuxTT[nContTT, ATT_CLIENTE])																	// Cliente Faturar Para
					oSection7:Cell("A1_LOJA"):SetValue(aAuxTT[nContTT, ATT_LOJA])																	// Loja Faturar Para
					oSection7:Cell("A1_NOME"):SetValue(aAuxTT[nContTT, ATT_NOME])																	// Nome Cliente
					oSection7:Cell("VO4_DEPGAR"):SetValue(aAuxTT[nContTT, ATT_DEPGAR])																// Departamento Garantia
					oSection7:Cell("VO4_DEPINT"):SetValue(aAuxTT[nContTT, ATT_DEPINT])																// Departamento Interno
					oSection7:Cell("VO4_FUNFEC"):SetValue(aAuxTT[nContTT, ATT_PRODUTIVO])															// Produtivo que fechou a OS
					oSection7:Cell("VO4_DATDIS"):SetValue(OR450FDATA(aAuxTT[nContTT, ATT_DATLIB]))				 									// Data de Liberacao
					oSection7:Cell("VO4_DATFEC"):SetValue(OR450FDATA(aAuxTT[nContTT, ATT_DATFEC]))				 									// Data de Fechamento
					oSection7:Cell("VO4_DATCAN"):SetValue(OR450FDATA(aAuxTT[nContTT, ATT_DATCAN]))				 									// Data de Cancelamento
					oSection7:Cell("VOO_LIBVOO"):SetValue(aAuxTT[nContTT, ATT_LIBVOO])																// Liberacao do VOO
					oSection7:Cell("F2_DOC"):SetValue(aAuxTT[nContTT, ATT_NUMNFI])																	// Numero da Nota Fiscal
					oSection7:Cell("F2_SERIE"):SetValue(aAuxTT[nContTT, ATT_SERNFI])																// Série da Nota Fiscal
					oSection7:Cell("VO4_TEMPAD"):SetValue(/*Transform(*/aAuxTT[nContTT, ATT_TEMPAD]/*, GetSX3Cache("VO4_TEMPAD", "X3_PICTURE"))*/)	// Tempo Padrao
					oSection7:Cell("VO4_TEMTRA"):SetValue(/*Transform(*/aAuxTT[nContTT, ATT_TEMTRA]/*, GetSX3Cache("VO4_TEMTRA", "X3_PICTURE"))*/)	// Tempo Trabalhado
					oSection7:Cell("VO4_TEMCOB"):SetValue(/*Transform(*/aAuxTT[nContTT, ATT_TEMCOB]/*, GetSX3Cache("VO4_TEMCOB", "X3_PICTURE"))*/)	// Tempo Cobrado
					oSection7:Cell("VO4_TEMVEN"):SetValue(/*Transform(*/aAuxTT[nContTT, ATT_TEMVEN]/*, GetSX3Cache("VO4_TEMVEN", "X3_PICTURE"))*/)	// Tempo Vendido
					oSection7:Cell("VO4_VALSER"):SetValue(/*Transform(*/aAuxTT[nContTT, ATT_TOTSRVC]/*, GetSX3Cache("F2_VALBRUT", "X3_PICTURE"))*/)	// Total Servicos
					oSection7:Cell("VO3_VALPEC"):SetValue(/*Transform(*/aAuxTT[nContTT, ATT_TOTPECA]/*, GetSX3Cache("F2_VALBRUT", "X3_PICTURE"))*/) // Total de Pecas
					oSection7:PrintLine()
					oSection7:Finish()
				EndIf

				If MV_PAR03 == 3 // Impressao analitica
					// Imprime pecas
					If Len(aAuxLinPeca) > 0
						oSection8:Init()
						For nCont := 1 to Len(aAuxLinPeca)
							oSection8:Cell("BM_GRUPO"):SetValue(aAuxLinPeca[nCont,02])																  // Grupo da Peca
							oSection8:Cell("B1_CODITE"):SetValue(aAuxLinPeca[nCont,03])																  // Codigo da Peca
							oSection8:Cell("B1_DESC"):SetValue(aAuxLinPeca[nCont, 04])																  // Descricao da Peca
							oSection8:Cell("VO3_QTDREQ"):SetValue(/*Transform(*/aAuxLinPeca[nCont, 05]/*, GetSX3Cache("VO3_QTDREQ", "X3_PICTURE")*/)  // Quantidade
							oSection8:Cell("VO3_PROREQ"):SetValue(aAuxLinPeca[nCont, 06])															  // Produtivo que Requisitou
							oSection8:Cell("VO3_FORMUL"):SetValue(aAuxLinPeca[nCont, 07])															  // Formula
							oSection8:Cell("VO3_VALPEC"):SetValue(/*Transform(*/aAuxLinPeca[nCont, 08]/*, GetSX3Cache("VO3_VALPEC", "X3_PICTURE"))*/) // Valor Unitario
							oSection8:Cell("VO3_VALTOT"):SetValue(/*Transform(*/aAuxLinPeca[nCont, 09]/*, GetSX3Cache("VO3_VALPEC", "X3_PICTURE"))*/) // Valor Total
							oSection8:PrintLine()
						Next
						oSection8:Finish()
					Endif

					// Imprime Servicos
					If Len(aAuxLinSrvc) > 0
						oSection9:Init()
						For nCont := 1 to Len(aAuxLinSrvc)
							oSection9:Cell("VOK_TIPSER"):SetValue(aAuxLinSrvc[nCont, 01]) 																// Tipo de Servico
							oSection9:Cell("VOS_CODGRU"):SetValue(aAuxLinSrvc[nCont, 02]) 																// Grupo do Servico
							oSection9:Cell("VO6_CODSER"):SetValue(aAuxLinSrvc[nCont, 03]) 																// Codigo do Servico
							oSection9:Cell("VO6_DESSER"):SetValue(aAuxLinSrvc[nCont, 04]) 																// Descricao do Servico
							oSection9:Cell("VAI_CODTEC"):SetValue(aAuxLinSrvc[nCont, 05]) 																// Codigo do Produtivo
							if Alltrim(aAuxLinSrvc[nCont, 06]) == "TOTAL"
								oReport:IncRow()
							Endif
							oSection9:Cell("VAI_NOMTEC"):SetValue(aAuxLinSrvc[nCont, 06]) 																// Nome do Produtivo
							oSection9:Cell("VO4_KILROD"):SetValue(IIF(aAuxLinSrvc[nCont, 13] == "5",;													// Quilometragem Rodada
								Transform(aAuxLinSrvc[nCont, 12], GetSX3Cache("VO4_KILROD", "X3_PICTURE")), " "))
							oSection9:Cell("VO4_TEMPAD"):SetValue(/*Transform(*/aAuxLinSrvc[nCont, 07]/*, GetSX3Cache("VO4_TEMPAD", "X3_PICTURE"))*/) 	// Tempo Padrao
							oSection9:Cell("VO4_TEMTRA"):SetValue(/*Transform(*/aAuxLinSrvc[nCont, 08]/*, GetSX3Cache("VO4_TEMTRA", "X3_PICTURE"))*/) 	// Tempo Trabalhado
							oSection9:Cell("VO4_TEMCOB"):SetValue(/*Transform(*/aAuxLinSrvc[nCont, 09]/*, GetSX3Cache("VO4_TEMCOB", "X3_PICTURE"))*/) 	// Tempo Cobrado
							oSection9:Cell("VO4_TEMVEN"):SetValue(/*Transform(*/aAuxLinSrvc[nCont, 10]/*, GetSX3Cache("VO4_TEMVEN", "X3_PICTURE"))*/) 	// Tempo Vendido
							oSection9:Cell("VO4_VALSER"):SetValue(/*Transform(*/aAuxLinSrvc[nCont, 11]/*, GetSX3Cache("VO4_VALSER", "X3_PICTURE"))*/) 	// Valor do Servico (Liquido)
							oSection9:PrintLine()
							if Alltrim(aAuxLinSrvc[nCont, 06]) == "TOTAL"
								oReport:IncRow()
							Endif
						Next
						oSection9:Finish()
					EndIf

					If MV_PAR26 == 2 // Gera Planilha
						If Len(aAuxTT) == 0 .OR. (Len(aAuxLinPeca) == 0 .AND. Len(aAuxLinSrvc) == 0) // Gera Planilha, se nao houver requisicao, cria uma linha so com informacoes da OS
							OR450APPEND(0)
						EndIf

						For nCont := 1 to Len(aAuxLinPeca) // Adiciona Pecas
							OR450APPEND(nContTT)
							aImpXls[nPosicao, 48] := aAuxLinPeca[nCont, 01] // 01 - Numero da Requisicao
							aImpXls[nPosicao, 49] := aAuxLinPeca[nCont, 02] // 02 - Grupo da Peca
							aImpXls[nPosicao, 50] := aAuxLinPeca[nCont, 03] // 03 - Codigo da Peca
							aImpXls[nPosicao, 51] := aAuxLinPeca[nCont, 04] // 04 - Descricao da Peca
							aImpXls[nPosicao, 52] := aAuxLinPeca[nCont, 05] // 05 - Quantidade
							aImpXls[nPosicao, 53] := aAuxLinPeca[nCont, 06] // 06 - Produtivo que Requisitou
							aImpXls[nPosicao, 54] := aAuxLinPeca[nCont, 07] // 07 - Formula
							aImpXls[nPosicao, 55] := aAuxLinPeca[nCont, 08] // 08 - Valor Unitario
							aImpXls[nPosicao, 56] := aAuxLinPeca[nCont, 09] // 09 - Valor Total
							aImpXls[nPosicao, 69] := aAuxLinPeca[nCont, 10] // 10 - Original ou Paralelo
						Next

						For nCont := 1 to Len(aAuxLinSrvc) // Adiciona Servicos
							If Alltrim(aAuxLinSrvc[nCont, 06]) == STR0038
								Loop
							Endif

							OR450APPEND(nContTT)
							aImpXls[nPosicao, 57] := aAuxLinSrvc[nCont, 01]	// 01 - Tipo de Servico
							aImpXls[nPosicao, 58] := aAuxLinSrvc[nCont, 02]	// 02 - Grupo do Servico
							aImpXls[nPosicao, 59] := aAuxLinSrvc[nCont, 03]	// 03 - Codigo do Servico
							aImpXls[nPosicao, 60] := aAuxLinSrvc[nCont, 04]	// 04 - Descricao do Servico
							aImpXls[nPosicao, 61] := aAuxLinSrvc[nCont, 05]	// 05 - Codigo do Produtivo
							aImpXls[nPosicao, 62] := aAuxLinSrvc[nCont, 06]	// 06 - Nome do Produtivo
							aImpXls[nPosicao, 63] := Transform(aAuxLinSrvc[nCont, 07], "@E 99999:99")	// 07 - Tempo Padrao
							aImpXls[nPosicao, 64] := Transform(aAuxLinSrvc[nCont, 08], "@E 99999:99")	// 08 - Tempo Trabalhado
							aImpXls[nPosicao, 65] := aAuxLinSrvc[nCont, 10]	// 10 - Tempo Vendido
							aImpXls[nPosicao, 66] := aAuxLinSrvc[nCont, 09]	// 09 - Tempo Cobrado
							aImpXls[nPosicao, 67] := aAuxLinSrvc[nCont, 11]	// 11 - Valor do Servico (Liquido)
							aImpXls[nPosicao, 68] := aAuxLinSrvc[nCont, 12]	// 12 - KM Rodado
						Next
					EndIf
				EndIf
			Next

			// Atualizando RESUMO
			cProcSITTPO := "" // Controla a Situacao do Tempo que ja foi calculada no resumo
			cProcTIPTEM := ""
			For nCont := 1 to Len(aAuxTT)
				VOI->(DbSetOrder(1))
				VOI->(DbSeek(xFilial("VOI") + aAuxTT[nCont, ATT_TIPTEM]))
				// Gera Resumo de Tipo de Tempo
				If (nPos := aScan(aResTipTem, {|x| x[01] == aAuxTT[nCont, ATT_TIPTEM]})) == 0
					AADD(aResTipTem, {aAuxTT[nCont, ATT_TIPTEM], VOI->VOI_SITTPO, VOI->VOI_DESTTE, 0, 0, 0, 0, 0, 0, 0, 0})
					nPos := Len(aResTipTem)
				EndIf
				aResTipTem[nPos, 04] += aAuxTT[nCont, ATT_QTDPECA]	// Qtde de Pecas
				aResTipTem[nPos, 05] += aAuxTT[nCont, ATT_TOTPECA]	// Total de Pecas
				aResTipTem[nPos, 06] += aAuxTT[nCont, ATT_TEMPAD]	// Tempo Padrao
				aResTipTem[nPos, 07] += aAuxTT[nCont, ATT_TEMTRA]	// Tempo Trabalhado
				aResTipTem[nPos, 08] += aAuxTT[nCont, ATT_TEMCOB]	// Tempo Cobrado
				aResTipTem[nPos, 09] += aAuxTT[nCont, ATT_TEMVEN]	// Tempo Vendido
				aResTipTem[nPos, 10] += aAuxTT[nCont, ATT_TOTSRVC]	// Total de Servicos

				If !(aAuxTT[nCont, ATT_TIPTEM] $ cProcTIPTEM) // Soma a qtde de OS por Tipo de Tempo
					aResTipTem[nPos, 11]++ // Total de Tipo de Tempo
				EndIf

				If !(aResTipTem[nPos, 02] $ cProcSITTPO) // Soma a qtde de OS por Situacao do Tempo
					If (nPos2 := aScan(aResSitTpo, {|x| x[01] == aResTipTem[nPos, 02]})) == 0 // Verifica se existe registro na matriz de resumo de situacao do tempo do tipo de tempo
						AADD(aResSitTpo, {aResTipTem[nPos, 02], 0})
						nPos2 := Len(aResSitTpo)
					EndIf
					cProcSITTPO += aResTipTem[nPos, 02] + "/"
					++aResSitTpo[nPos2, 2]
				EndIf

				Do Case // Gera Resumo por Departamento
					Case !Empty(aAuxTT[nCont, ATT_DEPINT])
						cAuxTabX5 := "VD"
						cAuxDepto := aAuxTT[nCont, ATT_DEPINT]
					Case !Empty(aAuxTT[nCont, ATT_DEPGAR])
						cAuxTabX5 := "VF"
						cAuxDepto := aAuxTT[nCont, ATT_DEPGAR]
					Otherwise
						cAuxDepto := " "
				End Case

				If (nPos := aScan(aResDepto, {|x| x[01] == VOI->VOI_SITTPO .AND. x[02] == cAuxDepto})) == 0
					If !Empty(cAuxDepto)
						SX5->(DbSetOrder(1))
						SX5->(DbSeek(cFilSX5+cAuxTabX5+cAuxDepto))
					EndIf
					AADD(aResDepto, {;
						VOI->VOI_SITTPO,;
						cAuxDepto,;
						Iif(!Empty(cAuxDepto), Substr(SX5->X5_DESCRI, 1, 20), STR0224),; // SEM DEPARTAMENTO
						0,;
						0,;
						0,;
						0,;
						0,;
						0,;
						0,;
						0};
					)
					nPos := Len(aResDepto)
				EndIf
				aResDepto[nPos, 04] += aAuxTT[nCont, ATT_QTDPECA] // Qtde de Pecas
				aResDepto[nPos, 05] += aAuxTT[nCont, ATT_TOTPECA] // Total de Pecas
				aResDepto[nPos, 06] += aAuxTT[nCont, ATT_TEMPAD]  // Tempo Padrao
				aResDepto[nPos, 07] += aAuxTT[nCont, ATT_TEMTRA]  // Tempo Trabalhado
				aResDepto[nPos, 08] += aAuxTT[nCont, ATT_TEMCOB]  // Tempo Cobrado
				aResDepto[nPos, 09] += aAuxTT[nCont, ATT_TEMVEN]  // Tempo Vendido
				aResDepto[nPos, 10] += aAuxTT[nCont, ATT_TOTSRVC] // Total de Servicos

				If !(aAuxTT[nCont, ATT_TIPTEM] $ cProcTIPTEM) // Soma a qtde de OS por Tipo de Tempo
					aResDepto[nPos, 11]++ // Total de Tipo de Tempo
				EndIf

				// Atualiza para nao calcular duplicado quando o Tipo de Tempo possui varias liberacoes (VOO_LIBVOO)
				cProcTIPTEM += aAuxTT[nCont, ATT_TIPTEM] + "/"
			Next
			QRYOS->(DbSkip())
		EndDo
		QRYOS->(DbCloseArea())
	Next

	If MV_PAR26 == 2 // Gera Planilha
		For ni := 1 to Len(aImpXls)
			oExcel:AddRow(; // Impressao Excel
				STR0124,;
				STR0064,;
				{;
			 		aImpXls[ni, 01],;
					aImpXls[ni, 02],;
					aImpXls[ni, 03],;
					DtoC(aImpXls[ni, 04]),;
					aImpXls[ni, 05],;
					aImpXls[ni, 06],;
					aImpXls[ni, 07],;
					aImpXls[ni, 08],;
			    	aImpXls[ni, 09],;
					aImpXls[ni, 10],;
					aImpXls[ni, 11],;
					aImpXls[ni, 12],;
					aImpXls[ni, 13],;
					aImpXls[ni, 14],;
					aImpXls[ni, 15],;
			    	aImpXls[ni, 16],;
					aImpXls[ni, 17],;
					aImpXls[ni, 18],;
					aImpXls[ni, 19],;
					aImpXls[ni, 20],;
					aImpXls[ni, 21],;
					aImpXls[ni, 22],;
					aImpXls[ni, 23],;
					aImpXls[ni, 24],;
					aImpXls[ni, 25],;
					aImpXls[ni, 26],;
					aImpXls[ni, 27],;
					aImpXls[ni, 28],;
					aImpXls[ni, 29],;
					aImpXls[ni, 30],;
					aImpXls[ni, 31],;
	 				aImpXls[ni, 32],;
					aImpXls[ni, 33],;
					aImpXls[ni, 34],;
					aImpXls[ni, 35],;
					aImpXls[ni, 36],;
					DtoC(aImpXls[ni, 37]),;
					DtoC(aImpXls[ni, 38]),;
					DtoC(aImpXls[ni, 39]),;
					aImpXls[ni, 40],;
					aImpXls[ni, 41],;
					aImpXls[ni, 42],;
					aImpXls[ni, 43],;
					aImpXls[ni, 44],;
					aImpXls[ni, 45],;
					aImpXls[ni, 46],;
					aImpXls[ni, 47],;
					aImpXls[ni, 48],;
					aImpXls[ni, 49],;
					aImpXls[ni, 50],;
					aImpXls[ni, 51],;
					aImpXls[ni, 52],;
					aImpXls[ni, 53],;
					aImpXls[ni, 54],;
					aImpXls[ni, 55],;
					aImpXls[ni, 56],;
					aImpXls[ni, 57],;
					aImpXls[ni, 58],;
					aImpXls[ni, 59],;
					aImpXls[ni, 60],;
					aImpXls[ni, 61],;
					aImpXls[ni, 62],;
					aImpXls[ni, 63],;
					aImpXls[ni, 64],;
					aImpXls[ni, 65],;
					aImpXls[ni, 66],;
					aImpXls[ni, 67],;
					aImpXls[ni, 68],;
					aImpXls[ni, 69];
				}; 
			)
		Next
	Endif

	If Len(aResTipTem) > 0 // Imprime resumo
		If MV_PAR03 <> 1
			oReport:EndPage()
			oReport:StartPage()
		Endif
		oSection2:Init()
		oSection2:Cell("TIT1"):SetValue("")
		oSection2:Cell("TIT2"):SetValue("******** " + STR0035 + " ********") // Resumo
		oSection2:Cell("TIT3"):SetValue("")
		oSection2:PrintLine()
		oSection2:Cell("TIT2"):SetValue("******** " + STR0036 + " ********") // TEMPO
		oSection2:PrintLine()
		oSection2:Finish()

		aAuxResumo := Array(08)
		aFill(aAuxResumo, 0)

		aSort(aResTipTem,,, {|x, y| x[2] + x[1] < y[2] + y[1] } )
		cProcSITTPO := " "
		oSection3:Init()
		For nCont := 1 to Len(aResTipTem)
			If cProcSITTPO <> aResTipTem[nCont, 02]
				nPos := aScan(aResSitTpo, {|x| x[1] == aResTipTem[nCont, 02]})
				oSection3:Cell("VOI_TIPTEM"):SetValue("<< " + X3CBOXDESC("VOI_SITTPO", aResSitTpo[nPos, 01]) + " >>")
				oSection3:Cell("VOI_DESTTE"):SetValue("")
				oSection3:Cell("VO3_QTDREQ"):SetValue("")
				oSection3:Cell("COUNT_PEC"):SetValue("")
				oSection3:Cell("VO4_TEMPAD"):SetValue("")
				oSection3:Cell("VO4_TEMTRA"):SetValue("")
				oSection3:Cell("VO4_TEMCOB"):SetValue("")
				oSection3:Cell("VO4_TEMVEN"):SetValue("")
				oSection3:Cell("VO4_VALSER"):SetValue("")
				oSection3:Cell("COUNT_TT"):SetValue("")
				oSection3:Cell("COUNT_OS"):SetValue(Transform(aResSitTpo[nPos, 02], "@E 999,999,999"))
				oSection3:PrintLine()
				oSection3:Cell("COUNT_OS"):SetValue("")
				cProcSITTPO := aResTipTem[nCont, 02]
				aAuxResumo[08] += aResSitTpo[nPos, 02]
			EndIf

			// Resumo
			oSection3:Cell("VOI_TIPTEM"):SetValue(aResTipTem[nCont, 01])
			oSection3:Cell("VOI_DESTTE"):SetValue(aResTipTem[nCont, 03])
			oSection3:Cell("VO3_QTDREQ"):SetValue(Transform(aResTipTem[nCont, 04], GetSX3Cache("VO3_QTDREQ", "X3_PICTURE")))
			oSection3:Cell("COUNT_PEC"):SetValue(Transform(aResTipTem[nCont, 05], "@E 99,999,999.99"))
			oSection3:Cell("VO4_TEMPAD"):SetValue(Transform(aResTipTem[nCont, 06], GetSX3Cache("VO4_TEMPAD", "X3_PICTURE")))
			oSection3:Cell("VO4_TEMTRA"):SetValue(Transform(aResTipTem[nCont, 07], GetSX3Cache("VO4_TEMTRA", "X3_PICTURE")))
			oSection3:Cell("VO4_TEMCOB"):SetValue(Transform(aResTipTem[nCont, 08], GetSX3Cache("VO4_TEMCOB", "X3_PICTURE")))
			oSection3:Cell("VO4_TEMVEN"):SetValue(Transform(aResTipTem[nCont, 09], GetSX3Cache("VO4_TEMVEN", "X3_PICTURE")))
			oSection3:Cell("VO4_VALSER"):SetValue(Transform(aResTipTem[nCont, 10], GetSX3Cache("VO4_VALSER", "X3_PICTURE")))
			oSection3:Cell("COUNT_TT"):SetValue(Transform(aResTipTem[nCont, 11], "@E 99,999,99"))
			oSection3:PrintLine()

			aAuxResumo[01] += aResTipTem[nCont, 04]	// Qtde de Pecas
			aAuxResumo[02] += aResTipTem[nCont, 05]	// Total de Pecas
			aAuxResumo[03] += aResTipTem[nCont, 06]	// Tempo Padrao
			aAuxResumo[04] += aResTipTem[nCont, 07]	// Tempo Trabalhado
			aAuxResumo[05] += aResTipTem[nCont, 08]	// Tempo Cobrado
			aAuxResumo[06] += aResTipTem[nCont, 09]	// Tempo Vendido
			aAuxResumo[07] += aResTipTem[nCont, 10]	// Total de Servico
		Next
		oReport:IncRow()

		//Totais
		oSection3:Cell("VOI_TIPTEM"):SetValue(STR0038)
		oSection3:Cell("VOI_DESTTE"):SetValue("")
		oSection3:Cell("VO3_QTDREQ"):SetValue(Transform(aAuxResumo[01], GetSX3Cache("VO3_QTDREQ", "X3_PICTURE")))
		oSection3:Cell("COUNT_PEC"):SetValue(Transform(aAuxResumo[02], "@E 99,999,999.99"))
		oSection3:Cell("VO4_TEMPAD"):SetValue(Transform(aAuxResumo[03], GetSX3Cache("VO4_TEMPAD", "X3_PICTURE")))
		oSection3:Cell("VO4_TEMTRA"):SetValue(Transform(aAuxResumo[04], GetSX3Cache("VO4_TEMTRA", "X3_PICTURE")))
		oSection3:Cell("VO4_TEMCOB"):SetValue(Transform(aAuxResumo[05], GetSX3Cache("VO4_TEMCOB", "X3_PICTURE")))
		oSection3:Cell("VO4_TEMVEN"):SetValue(Transform(aAuxResumo[06], GetSX3Cache("VO4_TEMVEN", "X3_PICTURE")))
		oSection3:Cell("VO4_VALSER"):SetValue(Transform(aAuxResumo[07], GetSX3Cache("VO4_VALSER", "X3_PICTURE")))
		oSection3:Cell("COUNT_OS"):SetValue(Transform(aAuxResumo[08], "@E 999,999,999"))
		oSection3:PrintLine()
		oReport:IncRow()
		oSection3:Cell("VOI_TIPTEM"):SetValue(STR0039 + ": ") // "Qtd.Passagem Chassi"
		oSection3:Cell("VOI_DESTTE"):SetValue(Transform(nPassagens, "@E 999,999,999"))
		oSection3:Cell("VO3_QTDREQ"):SetValue("")
		oSection3:Cell("COUNT_PEC"):SetValue("")
		oSection3:Cell("VO4_TEMPAD"):SetValue("")
		oSection3:Cell("VO4_TEMTRA"):SetValue("")
		oSection3:Cell("VO4_TEMCOB"):SetValue("")
		oSection3:Cell("VO4_TEMVEN"):SetValue("")
		oSection3:Cell("VO4_VALSER"):SetValue("")
		oSection3:Cell("COUNT_TT"):SetValue("")
		oSection3:Cell("COUNT_OS"):SetValue("")
		oSection3:PrintLine()
		oSection3:Finish()
	EndIf

	If Len(aResDepto) <> 0
		aFill(aAuxResumo,0)

		// Resumo por Departamento
		oSection2:Init()
		oSection2:Cell("TIT1"):SetValue("")
		oSection2:Cell("TIT2"):SetValue("******** " + STR0040 + " ********") // DEPARTAMENTO
		oSection2:Cell("TIT3"):SetValue("")
		oSection2:PrintLine()
		oSection2:Cell("TIT2"):SetValue("******** " + STR0036 + " ********") // TEMPO
		oSection2:PrintLine()
		oSection2:Finish()
		oSection4:Init()
		aSort(aResDepto,,, {|x, y| x[1] + x[2] < y[1] + y[2]})
		cProcSITTPO := ""
		For nCont := 1 to Len(aResDepto)
			If cProcSITTPO <> aResDepto[nCont, 01]
				oSection4:Cell("VO4_DEPGAR"):SetValue("<< " + X3CBOXDESC("VOI_SITTPO", aResDepto[nCont, 01]) + " >>")
				oSection4:Cell("VO3_QTDREQ"):SetValue("")
				oSection4:Cell("COUNT_PEC"):SetValue("")
				oSection4:Cell("VO4_TEMPAD"):SetValue("")
				oSection4:Cell("VO4_TEMTRA"):SetValue("")
				oSection4:Cell("VO4_TEMCOB"):SetValue("")
				oSection4:Cell("VO4_TEMVEN"):SetValue("")
				oSection4:Cell("VO4_VALSER"):SetValue("")
				oSection4:Cell("COUNT_OS"):SetValue("")
				oSection4:PrintLine()
				cProcSITTPO := aResDepto[nCont, 01]
			EndIf
			oSection4:Cell("VO4_DEPGAR"):SetValue(aResDepto[nCont, 02] + " - " + aResDepto[nCont, 03])
			oSection4:Cell("VO3_QTDREQ"):SetValue(Transform(aResDepto[nCont, 04], GetSX3Cache("VO3_QTDREQ", "X3_PICTURE")))
			oSection4:Cell("COUNT_PEC"):SetValue(Transform(aResDepto[nCont, 05], "@E 99,999,999.99"))
			oSection4:Cell("VO4_TEMPAD"):SetValue(Transform(aResDepto[nCont, 06], GetSX3Cache("VO4_TEMPAD", "X3_PICTURE")))
			oSection4:Cell("VO4_TEMTRA"):SetValue(Transform(aResDepto[nCont, 07], GetSX3Cache("VO4_TEMTRA", "X3_PICTURE")))
			oSection4:Cell("VO4_TEMCOB"):SetValue(Transform(aResDepto[nCont, 08], GetSX3Cache("VO4_TEMCOB", "X3_PICTURE")))
			oSection4:Cell("VO4_TEMVEN"):SetValue(Transform(aResDepto[nCont, 09], GetSX3Cache("VO4_TEMVEN", "X3_PICTURE")))
			oSection4:Cell("VO4_VALSER"):SetValue(Transform(aResDepto[nCont, 10], GetSX3Cache("VO4_VALSER", "X3_PICTURE")))
			oSection4:Cell("COUNT_OS"):SetValue(Transform(aResDepto[nCont, 11], "@E 999,999,999"))
			oSection4:PrintLine()

			aAuxResumo[01] += aResDepto[nCont, 04] // Qtde de Pecas
			aAuxResumo[02] += aResDepto[nCont, 05] // Total de Pecas
			aAuxResumo[03] += aResDepto[nCont, 06] // Tempo Padrao
			aAuxResumo[04] += aResDepto[nCont, 07] // Tempo Trabalhado
			aAuxResumo[05] += aResDepto[nCont, 08] // Tempo Cobrado
			aAuxResumo[06] += aResDepto[nCont, 09] // Tempo Vendido
			aAuxResumo[07] += aResDepto[nCont, 10] // Total de Servico
			aAuxResumo[08] += aResDepto[nCont, 11] // Total de OS
		Next
		oReport:IncRow()

		//Totais
		oSection4:Cell("VO4_DEPGAR"):SetValue(STR0038)
		oSection4:Cell("VO3_QTDREQ"):SetValue(Transform(aAuxResumo[01], "@E 99999999.99"))
		oSection4:Cell("COUNT_PEC"):SetValue(Transform(aAuxResumo[02], "@E 99,999,999.99"))
		oSection4:Cell("VO4_TEMPAD"):SetValue(Transform(aAuxResumo[03], "@R 999999:99"))
		oSection4:Cell("VO4_TEMTRA"):SetValue(Transform(aAuxResumo[04], "@R 999999:99"))
		oSection4:Cell("VO4_TEMCOB"):SetValue(Transform(aAuxResumo[05], "@R 999999:99"))
		oSection4:Cell("VO4_TEMVEN"):SetValue(Transform(aAuxResumo[06], "@R 999999:99"))
		oSection4:Cell("VO4_VALSER"):SetValue(Transform(aAuxResumo[07], "@E 99,999,999.99"))
		oSection4:Cell("COUNT_OS"):SetValue(Transform(aAuxResumo[08], "@E 999,999,999"))
		oSection4:PrintLine()
	EndIf

	If Len(aResTipSer) <> 0
		aFill(aAuxResumo, 0)

		// Resumo por Tipo de Servico
		oSection2:Init()
		oSection2:Cell("TIT1"):SetValue("")
		oSection2:Cell("TIT2"):SetValue("******** " + STR0042 + " ********") // "TIPO DE SERVIÇO"
		oSection2:Cell("TIT3"):SetValue("")
		oSection2:PrintLine()
		oSection2:Cell("TIT2"):SetValue("******** " + STR0036 + " ********") // "TEMPO"
		oSection2:PrintLine()
		oSection2:Finish()
		oSection5:Init()
		aSort(aResTipSer,,, {|x, y| x[4] + x[1] + x[2] < y[4] + y[1] + y[2]})
		cProcSITTPO := ""
		For nCont := 1 to Len(aResTipSer)
			If cProcSITTPO <> aResTipSer[nCont, 04]
				oSection5:Cell("VOK_TIPSER"):SetValue("<< " + X3CBOXDESC("VOK_TIPHOR", aResTipSer[nCont, 04]) + " >>")
				oSection5:Cell("VOK_DESSER"):SetValue("")
				oSection5:Cell("VO4_TEMPAD"):SetValue("")
				oSection5:Cell("VO4_TEMVEN"):SetValue("")
				oSection5:Cell("VO4_TEMTRA"):SetValue("")
				oSection5:Cell("VO4_TEMCOB"):SetValue("")
				oSection5:Cell("VO4_VALSER"):SetValue("")
				oSection5:Cell("COUNT_OS"):SetValue("")
				oSection5:PrintLine()
				cProcSITTPO := aResTipSer[nCont, 04]
			EndIf
			oSection5:Cell("VOK_TIPSER"):SetValue(aResTipSer[nCont, 01] + " - " + aResTipSer[nCont, 02])
			oSection5:Cell("VOK_DESSER"):SetValue(aResTipSer[nCont, 03])
			oSection5:Cell("VO4_TEMPAD"):SetValue(Transform(aResTipSer[nCont, 05], GetSX3Cache("VO4_TEMPAD", "X3_PICTURE")))
			oSection5:Cell("VO4_TEMVEN"):SetValue(Transform(aResTipSer[nCont, 06], GetSX3Cache("VO4_TEMVEN", "X3_PICTURE")))
			oSection5:Cell("VO4_TEMTRA"):SetValue(Transform(aResTipSer[nCont, 07], GetSX3Cache("VO4_TEMTRA", "X3_PICTURE")))
			oSection5:Cell("VO4_TEMCOB"):SetValue(Transform(aResTipSer[nCont, 08], GetSX3Cache("VO4_TEMCOB", "X3_PICTURE")))
			oSection5:Cell("VO4_VALSER"):SetValue(Transform(aResTipSer[nCont, 09], GetSX3Cache("VO4_VALSER", "X3_PICTURE")))
			oSection5:Cell("COUNT_OS"):SetValue(Transform(aResTipSer[nCont, 10], "@E 9999,999"))
			oSection5:PrintLine()

			aAuxResumo[01] += aResTipSer[nCont, 05]	// Tempo Padrao
			aAuxResumo[02] += aResTipSer[nCont, 06]	// Tempo Trabalhado
			aAuxResumo[03] += aResTipSer[nCont, 07]	// Tempo Cobrado
			aAuxResumo[04] += aResTipSer[nCont, 08]	// Tempo Vendido
			aAuxResumo[05] += aResTipSer[nCont, 09]	// Total de Strervico
			aAuxResumo[06] += aResTipSer[nCont, 10]	// Total de OS
		Next
		oReport:IncRow()
		oSection5:Cell("VOK_TIPSER"):SetValue(STR0038)
		oSection5:Cell("VOK_DESSER"):SetValue("")
		oSection5:Cell("VO4_TEMPAD"):SetValue(Transform(aAuxResumo[01], GetSX3Cache("VO4_TEMPAD", "X3_PICTURE")))
		oSection5:Cell("VO4_TEMVEN"):SetValue(Transform(aAuxResumo[02], GetSX3Cache("VO4_TEMVEN", "X3_PICTURE")))
		oSection5:Cell("VO4_TEMTRA"):SetValue(Transform(aAuxResumo[03], GetSX3Cache("VO4_TEMTRA", "X3_PICTURE")))
		oSection5:Cell("VO4_TEMCOB"):SetValue(Transform(aAuxResumo[04], GetSX3Cache("VO4_TEMCOB", "X3_PICTURE")))
		oSection5:Cell("VO4_VALSER"):SetValue(Transform(aAuxResumo[05], GetSX3Cache("VO4_VALSER", "X3_PICTURE")))
		oSection5:Cell("COUNT_OS"):SetValue(Transform(aAuxResumo[06], "@E 9999,999"))
		oSection5:PrintLine()
		oSection5:Finish()
	EndIf

	cFilAnt := cFilBkp
	If MV_PAR26 == 2 // Gera Planilha //
		If ExistBlock("OR450XLS")
			ExecBlock("OR450XLS", .f., .f., {aImpXls})
		EndIf

		If MV_PAR03 == 3
			cNomeArq := Alltrim(MV_PAR27) + "OFIOR450.xls"
			oExcel:Activate()
			oExcel:GetXMLFile(cNomeArq)
			oExcel:DeActivate()
			MsgInfo(STR0044 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cNomeArq, STR0045)	// "Planilha gerada com sucesso!" # "Atenção"
		ElseIf MV_PAR03 == 1 .or. MV_PAR03 == 2
			MsgInfo(STR0126)
		Endif
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OR450FDATA ºAutor  ³ Takahashi          º Data ³  27/12/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formata data para impressão do relatorio                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ dData - Data a ser formatada                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OR450FDATA(dData)
	Local cRetorno := ""
	If Empty(dData)
		cRetorno := "  /  /  "
	Else
		cRetorno := StrZero(Day(dData), 2) + "/" + StrZero(Month(dData), 2) + "/" + Right(Str(Year(dData), 4), 2)
	EndIf
Return cRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OR450APPEND ºAutor  ³ Takahashi         º Data ³  27/12/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona uma linha na tabela utilizada na ger. de planilha º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nPosTT - Posicao da matriz de Tipo de Tempo                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OR450APPEND(nPosTT)
	Local cQryInc := " "
	Local cSeqInc := " "
	Local cGruInc := " "
	Local cCodInc := " "
	Local cDesInc := " "

	if MV_PAR28 == 2 .AND. nPosTT > 0
		cQryInc := " SELECT "
		cQryInc += " DISTINCT VST_SEQINC, "
		cQryInc += " VST_GRUINC, "
		cQryInc += " VST_CODINC, "
		cQryInc += " VST_DESINC "
		cQryInc += " FROM "
		cQryInc += " 	" + RetSqlName("VST") + " VST "
		cQryInc += " WHERE "
		cQryInc += " 	VST_FILIAL = '" + xFilial("VST") + "' "
		cQryInc += " 	AND VST_CODIGO = '" + QRYOS->VO1_NUMOSV + "' "
		cQryInc += " 	AND VST_SEQINC IN ("
		cQryInc += 			"'" + Iif(Len(aCalPeca) >= nPosTT, aCalPeca[nPosTT, PECA_INCONV_SEQ], "") + "', "
		cQryInc += 			"'" + Iif(Len(aCalSrvc) >= nPosTT, aCalSrvc[nPosTT, SRVC_INCONV_SEQ], "") + "') "
		cQryInc += " 	AND VST.D_E_L_E_T_ = ' '  "
		TcQuery cQryInc New Alias "QRYINC"

		cSeqInc := QRYINC->VST_SEQINC
		cGruInc := QRYINC->VST_GRUINC
		cCodInc := QRYINC->VST_CODINC
		cDesInc := QRYINC->VST_DESINC
		QRYINC->(DbCloseArea())
	Endif

	AADD(;
		aImpXls,;
		{;
			QRYOS->VO1_FILIAL,; 														// 01 - "FILIAL"
			QRYOS->VO1_NUMOSV,; 														// 02 - "NRO_OS"
			UPPER(X3COMBO("VO1_TPATEN", QRYOS->VO1_TPATEN)),;							// 03 - "TP_ATEND"
			StoD(QRYOS->VO1_DATABE),; 													// 04 - "DT_ABERT"
			transform(QRYOS->VO1_HORABE, "@E 999:99"),; 								// 05 - "HR_ABERT"
			QRYOS->VO1_FUNABE,; 														// 06 - "CONS_ABE"
			QRYOS->VO1_KILOME,; 														// 07 - "KM"
			QRYOS->VO1_PROVEI,; 														// 08 - "PROPRIETAR"
			QRYOS->VO1_LOJPRO,; 														// 09 - "LOJA"
			QRYOS->A1_NOME,; 															// 10 - "NOME_CLIEN"
			QRYOS->A1_CGC,; 															// 11 - "CGC_CLI
			QRYOS->VO1_NUMORC,; 														// 12 - "ORÇAMENTO"
			QRYOS->A1_END,; 															// 13 - "ENDEREÇO"
			QRYOS->CIDADE,; 															// 14 - "CIDADE"
			QRYOS->UF,; 																// 15 - "UF"
			QRYOS->A1_TEL,; 															// 16 - "TELEFONE"
			QRYOS->VV1_CODMAR,; 														// 17 - "MARCA"
			Left(Alltrim(QRYOS->VV1_MODVEI) + " - " + Alltrim(QRYOS->VV2_DESMOD), 30),; // 18 - "MODELO"
			Transform(QRYOS->VV1_FABMOD, "@R 9999/9999"),; 								// 19 - "FAB_MOD"
			QRYOS->VVC_DESCRI,; 														// 20 - "COR"
			QRYOS->VV1_CHAINT,; 														// 21 - "CHASSI_INT"
			QRYOS->VV1_CHASSI,; 														// 22 - "CHASSI"
			Transform(QRYOS->VV1_PLAVEI, X3Picture("VV1_PLAVEI")),; 					// 23 - "PLACA"
			QRYOS->VV1_CODFRO,; 														// 24 - "COD_FROTA"
			cSeqInc,; 																	// 25 - "SEQ_INCON"
			cGruInc,; 																	// 26 - "GRP_INCON"
			cCodInc,; 																	// 27 - "COD_INCON"
			cDesInc,; 																	// 28 - "DES_INCON"
			"",;																		// 29 - "TP"
			"",;																		// 30 - "LIB_VOO"
			"",;																		// 31 - "FAT_PAR"
			"",;																		// 32 - "LJ_PAR"
			"",;																		// 33 - "NOME_PAR"
			"",;																		// 34 - "DEPTO_GAR"
			"",;																		// 35 - "DEPTO_INT"
			"",;																		// 36 - "CONS_FEC"
			ctod("  /  /  "),;															// 37 - "DT_LIB"
			ctod("  /  /  "),;															// 38 - "DT_FEC"
			ctod("  /  /  "),;															// 39 - "DT_CAN"
			"",;																		// 40 - "NRO_NF"
			"",;																		// 41 - SERIE_NF
			0,;																			// 42 - "PECAS_TT"
			0,;																			// 43 - "TPOPAD_TT"
			0,;																			// 44 - "TPOTRA_TT"
			0,;																			// 45 - "TPOCOB_TT"
			0,;																			// 46 - "TPOVEN_TT"
			"",;																		// 47 - "SERVICO_TT"
			"",;																		// 48 - "RELACAO"
			"",;																		// 49 - "GRUPO"
			"",;																		// 50 - "COD_ITEM"
			"",;																		// 51 - "DES_ITEM"
			0,;																			// 52 - "QTDADE"
			"",;																		// 53 - "PROD_REQ"
			"",;																		// 54 - "FORMULA"
			0,;																			// 55 - "VLR_UNIT"
			0,;																			// 56 - "VLR_TOTAL"
			"",;																		// 57 - "TIPO_SRV"
			"",;																		// 58 - "GRUPO_SRV"
			"",;																		// 59 - "COD_SRV"
			"",;																		// 60 - "DES_SRV"
			"",;																		// 61 - "PRODUTIVO"
			"",;																		// 62 - "NOME_PROD"
			0,;																			// 63 - "TPOPAD"
			0,;																			// 64 - "TPOTRA"
			0,;																			// 65 - "TPOCOB"
			0,;																			// 66 - "TPOVEN"
			"",;																		// 67 - "SERVIÇO"
			0,; 																		// 68 - KM Rodado
			"";																			// 69 - Ori/Par
		};
	)
	nPosicao := Len(aImpXls)

	If nPosTT <> 0
		aImpXls[nPosicao, 29] := aAuxTT[nPosTT, ATT_TIPTEM]
		aImpXls[nPosicao, 30] := aAuxTT[nPosTT, ATT_LIBVOO]
		aImpXls[nPosicao, 31] := aAuxTT[nPosTT, ATT_CLIENTE]
		aImpXls[nPosicao, 32] := aAuxTT[nPosTT, ATT_LOJA]
		aImpXls[nPosicao, 33] := aAuxTT[nPosTT, ATT_NOME]
		aImpXls[nPosicao, 34] := aAuxTT[nPosTT, ATT_DEPGAR]
		aImpXls[nPosicao, 35] := aAuxTT[nPosTT, ATT_DEPINT]
		aImpXls[nPosicao, 36] := aAuxTT[nPosTT, ATT_PRODUTIVO]
		aImpXls[nPosicao, 37] := aAuxTT[nPosTT, ATT_DATLIB]
		aImpXls[nPosicao, 38] := aAuxTT[nPosTT, ATT_DATFEC]
		aImpXls[nPosicao, 39] := aAuxTT[nPosTT, ATT_DATCAN]
		aImpXls[nPosicao, 40] := aAuxTT[nPosTT, ATT_NUMNFI]
		aImpXls[nPosicao, 41] := aAuxTT[nPosTT, ATT_SERNFI]
		aImpXls[nPosicao, 42] := aAuxTT[nPosTT, ATT_TOTPECA]
		aImpXls[nPosicao, 43] := Transform(aAuxTT[nPosTT, ATT_TEMPAD], "@E 99999:99")
		aImpXls[nPosicao, 44] := Transform(aAuxTT[nPosTT, ATT_TEMTRA], "@E 99999:99")
		aImpXls[nPosicao, 45] := Transform(aAuxTT[nPosTT, ATT_TEMCOB], "@E 99999:99")
		aImpXls[nPosicao, 46] := Transform(aAuxTT[nPosTT, ATT_TEMVEN], "@E 99999:99")
		aImpXls[nPosicao, 47] := aAuxTT[nPosTT, ATT_TOTSRVC] 
	EndIf
Return

/*
	// Cria Perguntas
	AADD(aRegs, {STR0001, STR0001, STR0001, 'MV_CH1', 'C', 40,             0, 0, 'G', '', 'MV_PAR01', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VOI','','','','!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/!!!!/',{},{},{}})
	AADD(aRegs, {STR0002, STR0002, STR0002, 'MV_CH2', 'N', 01,             0, 0, 'C', '', 'MV_PAR02', STR0046, STR0046, STR0046, '', '', STR0047, STR0047, STR0047,'', '', STR0048, STR0048, STR0048,'','',STR0049,STR0049,STR0049,'','',STR0050,STR0050,STR0050,'','','','','','', {}, {}, {}})
	AADD(aRegs, {STR0003, STR0003, STR0003, 'MV_CH3', 'N', 01,             0, 0, 'C', '', 'MV_PAR03', STR0051, STR0051, STR0051, '', '', STR0052, STR0052, STR0052,'', '', STR0053, STR0053, STR0053,'','','',     '',     '',     '','','','','','','','','','','',{},{},{}}) // "Tipo de relatório ?"
	AADD(aRegs, {STR0004, STR0004, STR0004, 'MV_CH4', 'N', 01,             0, 0, 'C', '', 'MV_PAR04', STR0054, STR0054, STR0054, '', '', STR0055, STR0055, STR0055,'', '', STR0056, STR0056, STR0056,'','',STR0057,STR0057,STR0057,'','','','','','','','','','','',{},{},{}}) // "Data ser considerad ?"
	AADD(aRegs, {STR0005, STR0005, STR0005, 'MV_CH5', 'D', 08,             0, 0, 'G', '', 'MV_PAR05', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0006, STR0006, STR0006, 'MV_CH6', 'D', 08,             0, 0, 'G', '', 'MV_PAR06', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0007, STR0007, STR0007, 'MV_CH7', 'C', 08,             0, 0, 'G', '', 'MV_PAR07', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VO1','','','','',{},{},{}})
	AADD(aRegs, {STR0008, STR0008, STR0008, 'MV_CH8', 'C', 08,             0, 0, 'G', '', 'MV_PAR08', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VO1','','','','',{},{},{}})
	AADD(aRegs, {STR0010, STR0010, STR0010, 'MV_CHA', 'C', 02,             0, 0, 'G', '', 'MV_PAR10', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0011, STR0011, STR0011, 'MV_CHB', 'C', 03,             0, 0, 'G', '', 'MV_PAR11', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VE1','','','','',{},{},{}})
	AADD(aRegs, {STR0012, STR0012, STR0012, 'MV_CHC', 'C', 30,             0, 0, 'G', '', 'MV_PAR12', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VX7','','','','',{},{},{}})
	AADD(aRegs, {STR0009, STR0009, STR0009, 'MV_CH9', 'C', 06,             0, 0, 'G', '', 'MV_PAR09', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VSC','','','','',{},{},{}})
	AADD(aRegs, {STR0013, STR0013, STR0013, 'MV_CHD', 'C', 25,             0, 0, 'G', '', 'MV_PAR13', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0014, STR0014, STR0014, 'MV_CHE', 'C', 06,             0, 0, 'G', '', 'MV_PAR14', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VAI','','','','',{},{},{}})
	AADD(aRegs, {STR0015, STR0015, STR0015, 'MV_CHF', 'C', 06,             0, 0, 'G', '', 'MV_PAR15', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VAI','','','','',{},{},{}})
	AADD(aRegs, {STR0016, STR0016, STR0016, 'MV_CHG', 'C', 06,             0, 0, 'G', '', 'MV_PAR16', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VAI','','','','',{},{},{}})
	AADD(aRegs, {STR0017, STR0017, STR0017, 'MV_CHH', 'N', 01,             0, 0, 'C', '', 'MV_PAR17', STR0058, STR0058, STR0058, '', '', STR0059, STR0059, STR0059,'', '', '','','','','','','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0018, STR0018, STR0018, 'MV_CHI', 'C', 03,             0, 0, 'G', '', 'MV_PAR18', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VOK','','','','',{},{},{}})
	AADD(aRegs, {STR0019, STR0019, STR0019, 'MV_CHJ', 'C', 03,             0, 0, 'G', '', 'MV_PAR19', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VOK','','','','',{},{},{}})
	AADD(aRegs, {STR0020, STR0020, STR0020, 'MV_CHK', 'N', 01,             0, 0, 'C', '', 'MV_PAR20', STR0058, STR0058, STR0058, '', '', STR0059, STR0059, STR0059,'', '', '','','','','','','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0021, STR0021, STR0021, 'MV_CHL', 'C', 01,             0, 0, 'G', '', 'MV_PAR21', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VD','','','','',{},{},{}})
	AADD(aRegs, {STR0022, STR0022, STR0022, 'MV_CHM', 'C', 01,             0, 0, 'G', '', 'MV_PAR22', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VF','','','','',{},{},{}})
	AADD(aRegs, {STR0023, STR0023, STR0023, 'MV_CHN', 'C', 06,             0, 0, 'G', '', 'MV_PAR23', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0024, STR0024, STR0024, 'MV_CHO', 'C', FWSizeFilial(), 0, 0, 'G', '', 'MV_PAR24', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','SM0_01','033','','','',{},{},{}})
	AADD(aRegs, {STR0025, STR0025, STR0025, 'MV_CHP', 'C', FWSizeFilial(), 0, 0, 'G', '', 'MV_PAR25', '',     '',     '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','SM0_01','033','','','',{},{},{}})
	AADD(aRegs, {STR0026, STR0026, STR0026, 'MV_CHQ', 'N', 01,             0, 0, 'C', '', 'MV_PAR26', STR0058, STR0058 ,STR0058, '', '', STR0059, STR0059, STR0059,'', '', '','','','','','','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0125, STR0125, STR0125, 'MV_CHR', 'C', 99,             0, 0, 'G', "!Vazio().or.(Mv_Par27:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))", 'MV_PAR27', STR0058,STR0058,STR0058, '', '', STR0059,STR0059,STR0059,' ','', '','','','','','','','','','','','','','','','','','','',{},{},{}})
	AADD(aRegs, {STR0127, STR0127, STR0127, 'MV_CHS', 'N', 01,             0, 0, 'C', '', 'MV_PAR28', STR0058, STR0058, STR0058, '', '', STR0059, STR0059, STR0059,'', '', '','','','','','','','','','','','','','','','','','','',{},{},{}}) // "Mostra Inconveniente?"
	AADD(aRegs, {STR0137, STR0137, STR0137, 'MV_CHT', 'C', 01,             0, 0, 'G', '', 'MV_PAR29', '',    '',      '',      '', '', '',     '',     '',     '', '', '','','', '','' ,'','','','','','','','','','VX5','','','','',{},{},{}}) // "Tipo de Atendimento"
	AADD(aRegs, {STR0139, STR0139, STR0139, 'MV_CHU', 'N', 01,             0, 0, 'C', '', 'MV_PAR30', STR0140, STR0140, STR0140, '', '', STR0141, STR0141, STR0141,'', '', STR0142,STR0142,STR0142,'','','','','','','','','','','','','','','','',{},{},{}}) // "Imprimir"
	AADD(aRegs, {STR0132, STR0132, STR0132, 'MV_CHV', 'N', 01,             0, 0, 'C', '', 'MV_PAR31', STR0046, STR0046, STR0046, '', '', STR0133, STR0133, STR0133,'', '', STR0134, STR0134, STR0134, '', '', STR0135, STR0135, STR0135, '', '', STR0136, STR0136, STR0136, '', '', '', '', '', '', {}, {}, {}}) // "Status OS"
	AADD(aRegs, {STR0150, STR0150, STR0150, 'MV_CHW', 'N', 01,             0, 0, 'C', '', 'MV_PAR32', STR0058, STR0058, STR0058, '', '', STR0059, STR0059, STR0059,'', '', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', {}, {}, {}})
*/
