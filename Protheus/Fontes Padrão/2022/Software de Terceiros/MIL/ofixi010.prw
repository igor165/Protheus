// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 6      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI010.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXI010   | Autor | Thiago                | Data | 11/12/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exporta as informações do AUTOPART para a montadora          |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXI010()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002

Local cDesc3  := STR0028
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0031 // TODO - Titulo do Assunto (Vai no relatório e FormBatch)
Private cPerg := "OXI010" 	// TODO -Pergunte
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que serão apresentadas no relatorio
Private aValores310 := {}
//
CriaSX1()
//
aAdd( aSay, cDesc1 ) // Um para cada cDescN
aAdd( aSay, cDesc2 ) // Um para cada cDescN
aAdd( aSay, cDesc3 ) // Um para cada cDescN
//
nOpc := 0
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//
Pergunte(cPerg,.f.)
//
RptStatus( {|lEnd| ExportArq(@lEnd)},STR0003,STR0004)
//
if !lErro
	RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0003, STR0005, .T. )
endif
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ExportArq  | Autor | Thiago                | Data | 11/12/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exporta arquivo.										        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq()
//
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
//
Local nTotReg
//
Local aLayCHI    := {}
Local aLayCHF    := {}
Local aLayCAI    := {}
Local aLayCAF    := {}
Local aLayCA10   := {}
Local aLayCA1011 := {}
Local aLayCA1012 := {}
Local aLayCA1015 := {}
Local aLayCA1099 := {}
Local aLayCA1101 := {}
Local aLayCA1102 := {}
Local aLayCA1104 := {}
Local aLayCA1105 := {}
Local aLayCA1120 := {}
Local aLayCA1310 := {}
Local aLayCA1777 := {} 
Local aValores15 := {}
Local aValor99   := {}   
Local aValor101  := {}
Local aValor102  := {}
Local aValor104  := {}
Local aValor105  := {}
Local aValor777  := {}
Local aValor120  := {}
Local i := 0 
Local nni    
Local nQtdReg := 0 
//
aAdd(aLayCHI, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CHI)
aAdd(aLayCHI, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCHI, { "N", 3,	0,	5})     // IDENTIFICAÇÃO DO PROCESSO (000)
aAdd(aLayCHI, { "N", 1,	0,	8})     // VERSÃO DO PROCESSO (0)
aAdd(aLayCHI, { "N", 5,	0,	9})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCHI, { "N", 12, 0,	14})    // DATA DA GERAÇÃO (0000ddmmaaaa)
aAdd(aLayCHI, { "C", 14, 0,	26})    // IDENTIFICAÇÃO DO TRANSMISSOR (0NNNNBBB….B)
//  NNNN  = Código da Concessionária
//  BBB… = Brancos

aAdd(aLayCHI, { "N", 14, 0,	40})	// IDENTIFICAÇÃO DO RECEPTOR (00…0051)
aAdd(aLayCHI, { "C", 30, 0,	54})    // IDENTIFICAÇÃO DA SOFTWARE HOUSE
//  Razão Social
aAdd(aLayCHI, { "C", 110, 0, 84})   // BRANCOS
//
aAdd(aLayCHF, { "C", 3, 0, 1})		// TIPO DE REGISTRO (CHF)
aAdd(aLayCHF, { "N", 1, 0, 4})		// VERSÃO DO LAYOUT (1)
aAdd(aLayCHF, { "N", 5, 0, 5})		// CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCHF, { "N", 9, 0, 10})		// TOTAL DE REGISTROS TRANSMITIDOS
// "  Quantidade total de registros de uma transmissão, incluindo os registros CHI e CHF."
aAdd(aLayCHF, { "C", 175, 0, 19}) 	// BRANCOS



// CAI - LAYOUT DO REGISTRO DE INICIO DE TRANSMISSÃO DO PROCESSO

aAdd(aLayCAI, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CAI)
aAdd(aLayCAI, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCAI, { "N", 3,	0,	5})     // IDENTIFICAÇÃO DO PROCESSO (000)
aAdd(aLayCAI, { "N", 1,	0,	8})     // VERSÃO DO PROCESSO (0)
aAdd(aLayCAI, { "N", 5,	0,	9})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCAI, { "N", 12, 0,	14})    // DATA DO MOVIMENTO (0000ddmmaaaa)
aAdd(aLayCAI, { "C", 14, 0,	26})    // IDENTIFICAÇÃO DO TRANSMISSOR (0NNNNBBB….B)
aAdd(aLayCAI, { "N", 14, 0,	40})    // IDENTIFICAÇÃO DO RECEPTOR (00…0051)
aAdd(aLayCAI, { "C", 30, 0,	54})    // IDENTIFICAÇÃO DA SOFTWARE HOUSE
aAdd(aLayCAI, { "C", 110, 0,	84})    // BRANCOS

// CAF - LAYOUT DO REGISTRO DE FIM DE TRANSMISSÃO DO PROCESSO
aAdd(aLayCAF, { "C", 3, 0, 1})		// TIPO DE REGISTRO (CAF)
aAdd(aLayCAF, { "N", 1, 0, 4})		// VERSÃO DO LAYOUT (1)
aAdd(aLayCAF, { "N", 5, 0, 5})		// CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCAF, { "N", 9, 0, 10})		// TOTAL DE REGISTROS TRANSMITIDOS
// "  Quantidade total de registros de uma transmissão, incluindo os registros CAI e CAF."
aAdd(aLayCAF, { "C", 175, 0, 19}) 	// BRANCOS


// CA1000
aAdd(aLayCA10, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA10, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=000)
aAdd(aLayCA10, { "N", 8 , 0 , 7})    // DATA DA GERAÇÃO DO ARQUIVO AUTOPART
aAdd(aLayCA10, { "C", 8 , 0 , 15})   // NÚMERO DO DEALER
aAdd(aLayCA10, { "C", 1 , 0 , 23})   // FÁBRICA (Fixo: V = Volkswagen)
aAdd(aLayCA10, { "N", 5 , 0 , 24})   // QUANTIDADE DE REGISTROS GERADOS
aAdd(aLayCA10, { "C", 10 , 0 , 29})  // CONTROLE INTERNO DO DEALER
aAdd(aLayCA10, { "C", 8 , 0 , 39})   // FIXO: AUTOPART
aAdd(aLayCA10, { "C", 1 , 0 , 47})   // MOEDA (Fixo: R = Real)
aAdd(aLayCA10, { "N", 6 , 0 , 48})   // HORA DA GERAÇÃO DO ARQUIVO AUTOPART
aAdd(aLayCA10, { "C", 134 , 0 , 54}) // BRANCOS
aAdd(aLayCA10, { "N", 6 , 0 , 188})  // VERSÃO DO LAYOUT (Fixo: 010109)

// CA1011
aAdd(aLayCA1011, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1011, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=011)
aAdd(aLayCA1011, { "C", 14 , 0 , 7})    // NÚMERO DA PEÇA ORIGINAL VW / NÃO ORIGINAL
aAdd(aLayCA1011, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1011, { "C", 168 , 0 , 26}) // BRANCOS

// CA1012
aAdd(aLayCA1012, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1012, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=012)
aAdd(aLayCA1012, { "C", 14 , 0 , 7})    // NÚMERO DA PEÇA ORIGINAL VW / NÃO ORIGINAL
aAdd(aLayCA1012, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1012, { "C", 168 , 0 , 26}) // BRANCOS

// CA1015 - DEVOLUÇÃO (TAKE BACK)
aAdd(aLayCA1015, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1015, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=015)
aAdd(aLayCA1015, { "C", 14 , 0 , 7})    // NÚMERO DA PEÇA ORIGINAL VW / NÃO ORIGINAL
aAdd(aLayCA1015, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1015, { "C", 168 , 0 , 26}) // BRANCOS

// CA1099 - RECEBIMENTO - PEDIDOS RECEBIDOS DA VOLKSWAGEN - MANUAL
aAdd(aLayCA1099, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1099, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=099)
aAdd(aLayCA1099, { "C", 14 , 0 , 7})    // NÚMERO DA PEÇA ORIGINAL VW
aAdd(aLayCA1099, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1099, { "C", 1 , 0 , 26}) // SINAL
aAdd(aLayCA1099, { "N", 10 , 0 , 27}) // NÚMERO DA NOTA FISCAL
aAdd(aLayCA1099, { "C", 157 , 0 , 37}) // BRANCOS

// CA1101 - RECEBIMENTO - PEDIDOS RECEBIDOS DA VOLKSWAGEN - AUTOPART
aAdd(aLayCA1101, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1101, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=101)
aAdd(aLayCA1101, { "C", 14 , 0 , 7})    // NÚMERO DA PEÇA ORIGINAL VW
aAdd(aLayCA1101, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1101, { "C", 1 , 0 , 26}) // SINAL
aAdd(aLayCA1101, { "N", 10 , 0 , 27}) // NÚMERO DA NOTA FISCAL
aAdd(aLayCA1101, { "C", 157 , 0 , 37}) // BRANCOS


// CA1102 - RECEBIMENTO - PEDIDOS RECEBIDOS DA VOLKSWAGEN - CARRO PARADO"

aAdd(aLayCA1102, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1102, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=102)
aAdd(aLayCA1102, { "C", 14 , 0 , 7})    // NÚMERO DA PEÇA ORIGINAL VW
aAdd(aLayCA1102, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1102, { "C", 1 , 0 , 26}) // SINAL
aAdd(aLayCA1102, { "N", 10 , 0 , 27}) // NÚMERO DA NOTA FISCAL
aAdd(aLayCA1102, { "C", 157 , 0 , 37}) // BRANCOS

// CA1104 - RECEBIMENTO - PEDIDOS NORMAIS DE OUTROS FORNECEDORES E PEÇAS VW"

aAdd(aLayCA1104, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1104, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=104)
aAdd(aLayCA1104, { "C", 14 , 0 , 7})    // NÚMERO DA PEÇA ORIGINAL VW / NÃO ORIGINAL
aAdd(aLayCA1104, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1104, { "C", 168 , 0 , 26}) // BRANCOS


// CA1105 - DADOS DE CONSUMO - VENDA NORMAL / ANORMAL / ESTORNO DE VENDA

aAdd(aLayCA1105, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1105, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=105)
aAdd(aLayCA1105, { "C", 14 , 0 , 7})   // NÚMERO DA PEÇA ORIGINAL VW / NÃO ORIGINAL
aAdd(aLayCA1105, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1105, { "C", 1 , 0 , 26})   // SINAL
aAdd(aLayCA1105, { "N", 1 , 0 , 27})   // TIPO DE CONSUMO / VENDA
aAdd(aLayCA1105, { "N", 1 , 0 , 28})   // CASAS DECIMAIS (Fixo: 0)
aAdd(aLayCA1105, { "C", 1 , 0 , 29})   // INDICADOR DE VENDA
aAdd(aLayCA1105, { "C", 164 , 0 , 30}) // BRANCOS


// CA1120 - PEÇAS ESCRAPEADAS PELO DEALER

aAdd(aLayCA1120, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1120, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=120)
aAdd(aLayCA1120, { "C", 14 , 0 , 7})   // NÚMERO DA PEÇA ORIGINAL VW / NÃO ORIGINAL
aAdd(aLayCA1120, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1120, { "C", 168 , 0 , 26}) // BRANCOS


// CA1310 - POSIÇÃO DO ESTOQUE APÓS MOVIMENTAÇÃO / INVENTÁRIO DA PEÇA

aAdd(aLayCA1310, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1310, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=310)
aAdd(aLayCA1310, { "C", 14 , 0 , 7})   // NÚMERO DA PEÇA ORIGINAL VW / NÃO ORIGINAL
aAdd(aLayCA1310, { "N", 5 , 0 , 21})   // QUANTIDADE
aAdd(aLayCA1310, { "C", 168 , 0 , 26}) // BRANCOS


// CA1777 - CARGA INICIAL - PEÇAS ORIGINAIS VW

aAdd(aLayCA1777, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CA1)
aAdd(aLayCA1777, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=777)
aAdd(aLayCA1777, { "C", 14 , 0 , 7})   // NÚMERO DA PEÇA ORIGINAL VW
aAdd(aLayCA1777, { "C", 7 , 0 , 21})   // LOCAÇÃO DA PEÇA NO DEALER
aAdd(aLayCA1777, { "N", 5 , 0 , 28})   // QUANTIDADE DE PEÇAS NO ESTOQUE
aAdd(aLayCA1777, { "N", 5 , 0 , 33})   // QUANTIDADE DE PEÇAS EM PEDIDOS PENDENTES
aAdd(aLayCA1777, { "N", 5 , 0 , 38})   // DEMANDA1
aAdd(aLayCA1777, { "N", 5 , 0 , 43})   // DEMANDA2
aAdd(aLayCA1777, { "N", 5 , 0 , 48})   // DEMANDA3
aAdd(aLayCA1777, { "N", 5 , 0 , 53})   // DEMANDA4
aAdd(aLayCA1777, { "N", 5 , 0 , 58})   // DEMANDA5
aAdd(aLayCA1777, { "N", 5 , 0 , 63})   // DEMANDA6
aAdd(aLayCA1777, { "C", 1 , 0 , 68})   // TIPO DE VENDA DA PEÇA
aAdd(aLayCA1777, { "C", 125 , 0 , 69})   // BRANCOS


// Monta CHI
aValCHI := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno
aAdd(aValCHI,{"CHI",1, 0,0,0,nData, "0"+Alltrim(strzero(MV_PAR05,4)),51,"TOTVS S/A"," " } )
cLinhaCHI := MontaEDI(aLayCHI,aValCHI[1])


// Monta CAI
aValCAI := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno
aAdd(aValCAI,{"CAI",1, 0,0,0,nData, "0"+Alltrim(strzero(MV_PAR05,4)),51,"TOTVS S/A"," " } )
cLinhaCAI := MontaEDI(aLayCAI,aValCAI[1])


//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
cArquivo := "OFIXI010.TXT"
//
if aDir( Alltrim(MV_PAR11)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
	if !MsgYesNo(STR0006,STR0007)
		lErro := .t.
		return
	endif
endif
//
nHnd := FCREATE(Alltrim(MV_PAR11)+Alltrim(cArquivo),0)
//
cQryAliasSD3 := GetNextAlias()

// CA1011 - CORREÇÃO DE ESTOQUE - AJUSTE POSITIVO
cQuery := "SELECT SB1.B1_CODITE,SD3.D3_QUANT, SD3.D3_DOC "
cQuery += " FROM " + RetSQLName("SD3") + " SD3 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD3.D3_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF5")+" SF5 ON SF5.F5_FILIAL = '" + xFilial("SF5") + "' AND SF5.F5_CODIGO = SD3.D3_TM AND SF5.F5_TIPO = 'D' AND SF5.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' AND SD3.D3_EMISSAO >= '"+dtos(MV_PAR01)+"' AND SD3.D3_EMISSAO <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "SD3.D3_LOCAL >= '01' AND SD3.D3_LOCAL <= '99' AND "
cQuery += "SD3.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD3, .F., .T. )
//
nTotReg := Contar(cQryAliasSD3, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSD3)->(DBGoTop())
//
fwrite(nHnd,cLinhaCHI)
fwrite(nHnd,cLinhaCAI)
//
aVetAjusP := {}
aVetAjusN := {}
//
While  !(cQryAliasSD3)->(Eof())

	if !((cQryAliasSD3)->(D3_DOC) $ MV_PAR13)
		(cQryAliasSD3)->(DBSkip())
		loop
	endif

	vPos := aScan(aVetAjusP,{|x| x[1] == (cQryAliasSD3)->(B1_CODITE)})
	
	if  vPos == 0
		aAdd(aVetAjusP,{(cQryAliasSD3)->(B1_CODITE),(cQryAliasSD3)->(D3_QUANT)}) 
		nQtdReg += 1
	else
		aVetAjusP[vPos,2] := aVetAjusP[vPos,2] + (cQryAliasSD3)->(D3_QUANT)
	endif
	(cQryAliasSD3)->(DBSkip())
Enddo

(cQryAliasSD3)->(dbCloseArea())

// CA1012 - CORREÇÃO DE ESTOQUE - AJUSTE NEGATIVO
cQuery := "SELECT SB1.B1_CODITE,SD3.D3_QUANT, SD3.D3_DOC "
cQuery += " FROM " + RetSQLName("SD3") + " SD3 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD3.D3_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF5")+" SF5 ON SF5.F5_FILIAL = '" + xFilial("SF5") + "' AND SF5.F5_CODIGO = SD3.D3_TM AND SF5.F5_TIPO = 'R' AND SF5.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' AND SD3.D3_EMISSAO >= '"+dtos(MV_PAR01)+"' AND SD3.D3_EMISSAO <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "SD3.D3_LOCAL >= '01' AND SD3.D3_LOCAL <= '99' AND "
cQuery += "SD3.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD3, .F., .T. )
//
nTotReg := Contar(cQryAliasSD3, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSD3)->(DBGoTop())
//
//
While  !(cQryAliasSD3)->(Eof())

	if !((cQryAliasSD3)->(D3_DOC) $ MV_PAR13)
		(cQryAliasSD3)->(DBSkip())
		loop
	endif

	vPos := aScan(aVetAjusN,{|x| x[1] == (cQryAliasSD3)->(B1_CODITE)})
	
	if  vPos == 0
		aAdd(aVetAjusN,{(cQryAliasSD3)->(B1_CODITE),(cQryAliasSD3)->(D3_QUANT)}) 
		nQtdReg += 1
	else
		aVetAjusN[vPos,2] := aVetAjusN[vPos,2] + (cQryAliasSD3)->(D3_QUANT)
	endif
	(cQryAliasSD3)->(DBSkip())
Enddo

(cQryAliasSD3)->(dbCloseArea())


cQryAliasSD2 := GetNextAlias()

// CA1015 - DEVOLUÇÃO (TAKE BACK)
cQuery := "SELECT SB1.B1_CODITE,SD2.D2_QUANT "
cQuery += " FROM " + RetSQLName("SD2") + " SD2 "
cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VE4")+" VE4 ON VE4.VE4_FILIAL = '" + xFilial("VE4") + "' AND SA1.A1_CGC = VE4.VE4_CGCFAB  AND VE4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD2.D2_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV = '09' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_EMISSAO >= '"+dtos(MV_PAR01)+"' AND SD2.D2_EMISSAO <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "SD2.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD2, .F., .T. )
//
nTotReg := Contar(cQryAliasSD2, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSD2)->(DBGoTop())
//
While  !(cQryAliasSD2)->(Eof())
	//
	nLinhArq++
	
	//
	nQtdReg += 1
	aAdd(aValores15,{"CA1",15,substr((cQryAliasSD2)->(B1_CODITE),1,14),(cQryAliasSD2)->(D2_QUANT),""})
	//
	aAdd(aLinhasRel,{"CA1",transform(15,"999"),(cQryAliasSD2)->(B1_CODITE),transform((cQryAliasSD2)->(D2_QUANT),"99999")})
	//
	(cQryAliasSD2)->(DBSkip())
	
Enddo
//
(cQryAliasSD2)->(dbCloseArea())

cQryAliasSD1 := GetNextAlias()

// CA1099 - RECEBIMENTO - PEDIDOS RECEBIDOS DA VOLKSWAGEN - MANUAL
cQuery := "SELECT SB1.B1_CODITE,SD1.D1_QUANT,SD1.D1_DOC,SB2.B2_QATU "
cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD1.D1_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV = '01' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VE4")+" VE4 ON VE4.VE4_FILIAL = '" + xFilial("VE4") + "' AND SA2.A2_CGC = VE4.VE4_CGCFAB  AND VE4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SD1.D1_COD AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SD1.D1_DTDIGIT >= '"+dtos(MV_PAR01)+"' AND SD1.D1_DTDIGIT <= '"+dtos(MV_PAR02)+"' AND SD1.D1_PEDIDO =  '' AND "
cQuery += "SD1.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD1, .F., .T. )
//
nTotReg := Contar(cQryAliasSD1, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSD1)->(DBGoTop())
//
While  !(cQryAliasSD1)->(Eof())
	//
	nLinhArq++
	
	cSinal := ""
	if (cQryAliasSD1)->(D1_QUANT) < 0
		cSinal := "-"
	Endif
	
	//
	nQtdReg += 1
	aAdd(aValor99,{"CA1",99,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(D1_QUANT),cSinal, (cQryAliasSD1)->D1_DOC , "" })
	//
	aAdd(aLinhasRel,{"CA1",transform(99,"999"),(cQryAliasSD1)->(B1_CODITE),transform((cQryAliasSD1)->(D1_QUANT),"99999")})
	//
	
	if MV_PAR04 == 1
	
	//	aAdd(aValores310,"CA1",310,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(B2_QATU),"")
	    nPos := 0
        nPos := aScan(aValores310,{|x| x[1]+str(x[2],3)+x[3] == "CA1"+"310"+substr((cQryAliasSD1)->(B1_CODITE),1,14) }) 
		if nPos == 0
			aAdd(aValores310,{"CA1",310,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(B2_QATU),""})
			nQtdReg += 1
		Endif	
		aAdd(aLinhasRel,{"CA1",transform(310,"999"),(cQryAliasSD1)->(B1_CODITE),transform((cQryAliasSD1)->(B2_QATU),"99999")})
    Endif
	//
	
	(cQryAliasSD1)->(DBSkip())
	
Enddo
//
(cQryAliasSD1)->(dbCloseArea())


cQryAliasSD1 := GetNextAlias()

// CA1101 - RECEBIMENTO - PEDIDOS RECEBIDOS DA VOLKSWAGEN - AUTOPART
cQuery := "SELECT SB1.B1_CODITE,SD1.D1_QUANT,SD1.D1_DOC,SB2.B2_QATU "
cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD1.D1_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV = '01' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VE4")+" VE4 ON VE4.VE4_FILIAL = '" + xFilial("VE4") + "' AND SA2.A2_CGC = VE4.VE4_CGCFAB  AND VE4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VEI")+" VEI ON VEI.VEI_FILIAL = '" + xFilial("VEI") + "' AND VEI.VEI_NUM = SD1.D1_PEDIDO AND VEI.VEI_TIPPED IN "+FormatIN(ALLTRIM(MV_PAR06),"/")+" AND VEI.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SD1.D1_COD  AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SD1.D1_DTDIGIT >= '"+dtos(MV_PAR01)+"' AND SD1.D1_DTDIGIT <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "SD1.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD1, .F., .T. )
//
nTotReg := Contar(cQryAliasSD1, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSD1)->(DBGoTop())
//
While  !(cQryAliasSD1)->(Eof())
	//
	nLinhArq++
	
	cSinal := ""
	if (cQryAliasSD1)->(D1_QUANT) < 0
		cSinal := "-"
	Endif
	//
	nQtdReg += 1
	aAdd(aValor101,{"CA1",101,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(D1_QUANT),cSinal,(cQryAliasSD1)->D1_DOC,"" })

	//
	aAdd(aLinhasRel,{"CA1",transform(101,"999"),(cQryAliasSD1)->(B1_CODITE),transform((cQryAliasSD1)->(D1_QUANT),"99999")})
	//
	
	if MV_PAR04 == 1
	    nPos := 0
        nPos := aScan(aValores310,{|x| x[1]+str(x[2],3)+x[3] == "CA1"+"310"+substr((cQryAliasSD1)->(B1_CODITE),1,14) }) 
		if nPos == 0
			aAdd(aValores310,{"CA1",310,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(B2_QATU),""})
			nQtdReg += 1
		Endif	
		aAdd(aLinhasRel,{"CA1",transform(310,"999"),(cQryAliasSD1)->(B1_CODITE),transform((cQryAliasSD1)->(D1_QUANT),"99999")})
    Endif
	//
	
	(cQryAliasSD1)->(DBSkip())
	
Enddo
//
(cQryAliasSD1)->(dbCloseArea())


cQryAliasSD1 := GetNextAlias()

// CA1102 - RECEBIMENTO - PEDIDOS RECEBIDOS DA VOLKSWAGEN - CARRO PARADO
cQuery := "SELECT SB1.B1_CODITE,SD1.D1_QUANT,SD1.D1_DOC,SB2.B2_QATU "
cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD1.D1_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV = '01' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VE4")+" VE4 ON VE4.VE4_FILIAL = '" + xFilial("VE4") + "' AND SA2.A2_CGC = VE4.VE4_CGCFAB  AND VE4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VEI")+" VEI ON VEI.VEI_FILIAL = '" + xFilial("VEI") + "' AND VEI.VEI_NUM = SD1.D1_PEDIDO AND VEI.VEI_TIPPED IN "+FormatIN(ALLTRIM(MV_PAR07),"/")+" AND VEI.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SD1.D1_COD  AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SD1.D1_DTDIGIT >= '"+dtos(MV_PAR01)+"' AND SD1.D1_DTDIGIT <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "SD1.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD1, .F., .T. )
//
nTotReg := Contar(cQryAliasSD1, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSD1)->(DBGoTop())
//
While  !(cQryAliasSD1)->(Eof())
	//
	nLinhArq++
	
	cSinal := ""
	if (cQryAliasSD1)->(D1_QUANT) < 0
		cSinal := "-"
	Endif
	//
	nQtdReg += 1
	aAdd(aValor102,{"CA1",102,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(D1_QUANT),cSinal,(cQryAliasSD1)->D1_DOC,"" })
	//
	aAdd(aLinhasRel,{"CA1",transform(102,"999"),(cQryAliasSD1)->(B1_CODITE),transform((cQryAliasSD1)->(D1_QUANT),"99999")})
	//
	
	if MV_PAR04 == 1
	    nPos := 0
        nPos := aScan(aValores310,{|x| x[1]+str(x[2],3)+x[3] == "CA1"+"310"+substr((cQryAliasSD1)->(B1_CODITE),1,14) }) 
		if nPos == 0
			aAdd(aValores310,{"CA1",310,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(B2_QATU),""})
			nQtdReg += 1
	    Endif
		//
		aAdd(aLinhasRel,{"CA1",transform(310,"999"),(cQryAliasSD1)->(B1_CODITE),transform((cQryAliasSD1)->(D1_QUANT),"99999")})
	Endif
	(cQryAliasSD1)->(DBSkip())
	
Enddo
//
(cQryAliasSD1)->(dbCloseArea())

cQryAliasSD1 := GetNextAlias()

// CA1104 - RECEBIMENTO - PEDIDOS NORMAIS DE OUTROS FORNECEDORES E PEÇAS VW

cQuery := "SELECT DISTINCT SB1.B1_CODITE,SD1.D1_QUANT,SD1.D1_DOC,SB2.B2_QATU "
cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD1.D1_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV = '01' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VE4")+" VE4 ON VE4.VE4_FILIAL = '" + xFilial("VE4") + "' AND SA2.A2_CGC <> VE4.VE4_CGCFAB AND VE4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SD1.D1_COD  AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SD1.D1_DTDIGIT >= '"+dtos(MV_PAR01)+"' AND SD1.D1_DTDIGIT <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "SD1.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD1, .F., .T. )
//
nTotReg := Contar(cQryAliasSD1, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0                                                                            '
(cQryAliasSD1)->(DBGoTop())
//
While  !(cQryAliasSD1)->(Eof())
	//
	nLinhArq++
	
	cSinal := ""
	if (cQryAliasSD1)->(D1_QUANT) < 0
		cSinal := "-"
	Endif
	//
	nQtdReg += 1
	aAdd(aValor104,{"CA1",104,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(D1_QUANT),	""  })
	//
	aAdd(aLinhasRel,{"CA1",transform(104,"999"),(cQryAliasSD1)->(B1_CODITE),transform((cQryAliasSD1)->(D1_QUANT),"99999")})
	//
	
	if MV_PAR04 == 1
	    nPos := 0
        nPos := aScan(aValores310,{|x| x[1]+str(x[2],3)+x[3] == "CA1"+"310"+substr((cQryAliasSD1)->(B1_CODITE),1,14) }) 
		if nPos == 0
			nQtdReg += 1
			aAdd(aValores310,{"CA1",310,substr((cQryAliasSD1)->(B1_CODITE),1,14),(cQryAliasSD1)->(B2_QATU),""})
	    Endif
		//
		aAdd(aLinhasRel,{"CA1",transform(310,"999"),(cQryAliasSD1)->(B1_CODITE),transform((cQryAliasSD1)->(D1_QUANT),"99999")})
	Endif
	(cQryAliasSD1)->(DBSkip())
	
Enddo
//
(cQryAliasSD1)->(dbCloseArea())


// CA1105 - DADOS DE CONSUMO - VENDA NORMAL / ANORMAL / ESTORNO DE VENDA

// VENDAS DE BALCÃO
cQryAliasSD2 := GetNextAlias()
cQuery := "SELECT SB1.B1_CODITE,SD2.D2_QUANT,SD2.D2_DOC,SA1.A1_SATIV1,VS3.VS3_CODSIT,SF2.F2_PREFORI  "
cQuery += " FROM " + RetSQLName("SD2") + " SD2 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD2.D2_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV = '05' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_PREFORI = '"+Alltrim(GetNewPar("MV_PREFBAL","BAL"))+"' AND SF2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VS1")+" VS1 ON VS1.VS1_FILIAL = '" + xFilial("VS1") + "' AND VS1.VS1_NUMNFI = SD2.D2_DOC AND VS1.VS1_SERNFI = SD2.D2_SERIE AND VS1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VS3")+" VS3 ON VS3.VS3_FILIAL = '" + xFilial("VS3") + "' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND (VS3.VS3_CODSIT = '01' OR VS3.VS3_CODSIT = '02' OR VS3.VS3_CODSIT = ' ' ) AND VS3.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_EMISSAO >= '"+dtos(MV_PAR01)+"' AND SD2.D2_EMISSAO <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "SD2.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD2, .F., .T. )
//
nTotReg := Contar(cQryAliasSD2, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSD2)->(DBGoTop())
//
While  !(cQryAliasSD2)->(Eof())
	//
	nLinhArq++
	
	cSinal := ""
	if (cQryAliasSD2)->(D2_QUANT) < 0
		cSinal := "-"
	Endif
	//
	if (cQryAliasSD2)->A1_SATIV1 $ Alltrim(MV_PAR08)
		nTipCon := 7
	Elseif (cQryAliasSD2)->A1_SATIV1 $ Alltrim(MV_PAR09)
		nTipCon := 9
	Elseif (cQryAliasSD2)->A1_SATIV1 $ Alltrim(MV_PAR10)
		nTipCon := 6
	Else
		nTipCon := 8
	Endif
	
	if (cQryAliasSD2)->VS3_CODSIT == "01" .or. (cQryAliasSD2)->VS3_CODSIT == "  "
		cIndVda := " "
	Else
		cIndVda := "1"
	Endif
	
	nQtdReg += 1
	aAdd(aValor105,{"CA1",105,substr((cQryAliasSD2)->(B1_CODITE),1,14),(cQryAliasSD2)->(D2_QUANT),cSinal ,nTipCon,0,cIndVda,"",(cQryAliasSD2)->F2_PREFORI })
	//
	aAdd(aLinhasRel,{"CA1",transform(105,"999"),(cQryAliasSD2)->(B1_CODITE),transform((cQryAliasSD2)->(D2_QUANT),"99999")})
	//
	(cQryAliasSD2)->(DBSkip())
	
Enddo
//
(cQryAliasSD2)->(dbCloseArea())


// VENDAS OFICINA
cQryAliasVO2 := GetNextAlias()
cQuery := "SELECT SB1.B1_CODITE,VO3.VO3_QTDREQ,VOI.VOI_SITTPO,SA1.A1_SATIV1,VO2.VO2_DEVOLU,SF2.F2_PREFORI "
cQuery += " FROM " + RetSQLName("VO2") + " VO2 "
cQuery += " INNER JOIN "+RetSqlName("VO3")+" VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.VO3_DATCAN = '' AND VO3.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_GRUPO = VO3.VO3_GRUITE AND SB1.B1_CODITE = VO3.VO3_CODITE AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_DOC = VO3.VO3_NUMNFI AND SF2.F2_SERIE = VO3.VO3_SERNFI AND SF2.F2_PREFORI = '"+Alltrim(GetNewPar("MV_PREFOFI","OFI"))+"' AND SF2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VEC")+" VEC ON VEC.VEC_FILIAL = '" + xFilial("VEC") + "' AND VEC.VEC_NUMNFI = VO3.VO3_NUMNFI AND VEC.VEC_SERNFI = VO3.VO3_SERNFI AND VEC.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VOI")+" VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VEC.VEC_TIPTEM AND VOI.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "' AND VO2.VO2_DATREQ >= '"+dtos(MV_PAR01)+"' AND VO2.VO2_DATREQ <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "VO2.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasVO2, .F., .T. )
//
nTotReg := Contar(cQryAliasVO2, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasVO2)->(DBGoTop())
//
While  !(cQryAliasVO2)->(Eof())
	//
	nLinhArq++
	
	cSinal := ""
	if (cQryAliasVO2)->(VO3_QTDREQ) < 0
		cSinal := "-"
	Endif
	//
	if (cQryAliasVO2)->VOI_SITTPO == "2"
		nTipCon := 3
	Elseif (cQryAliasVO2)->VOI_SITTPO == "1"
		if (cQryAliasVO2)->A1_SATIV1 $ Alltrim(MV_PAR08)
			nTipCon := 2
		Else
			nTipCon := 1
		Endif
	Endif
	cIndVda := ""
	if (cQryAliasVO2)->VO2_DEVOLU == "0"
       nPos := 0
       nPos := aScan(aValor105,{|x| x[1]+str(x[2],3)+x[3]+x[10] == "CA1"+"105"+substr((cQryAliasVO2)->(B1_CODITE),1,14)+(cQryAliasVO2)->F2_PREFORI  }) 
       if nPos > 0 
	       aValor105[nPos,4] -= (cQryAliasVO2)->(VO3_QTDREQ)
	   	   nQtdReg -= 1
       Endif
	Else
		nQtdReg += 1
		aAdd(aValor105,{"CA1",105,substr((cQryAliasVO2)->(B1_CODITE),1,14),(cQryAliasVO2)->(VO3_QTDREQ),cSinal ,nTipCon,0,cIndVda,"",(cQryAliasVO2)->F2_PREFORI })
		//
		aAdd(aLinhasRel,{"CA1",transform(105,"999"),(cQryAliasVO2)->(B1_CODITE),transform((cQryAliasVO2)->(VO3_QTDREQ),"99999")})
		//
	Endif	
	(cQryAliasVO2)->(DBSkip())
	
Enddo
//
(cQryAliasVO2)->(dbCloseArea())


// CA1120 - PEÇAS ESCRAPEADAS PELO DEALER
cQryAliasSD2 := GetNextAlias()
cQuery := "SELECT SB1.B1_CODITE,SD2.D2_QUANT,SD2.D2_DOC,VS3.VS3_CODSIT,SB2.B2_QATU  "
cQuery += " FROM " + RetSQLName("SD2") + " SD2 "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD2.D2_COD AND SB1.B1_TIPO = 'ME' AND  SB1.B1_GRUPO <> '"+GETMV("MV_GRUVEI")+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV = '05' AND SF4.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_PREFORI = '"+Alltrim(GetNewPar("MV_PREFBAL","BAL"))+"' AND SF2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VS1")+" VS1 ON VS1.VS1_FILIAL = '" + xFilial("VS1") + "' AND VS1.VS1_NUMNFI = SD2.D2_DOC AND VS1.VS1_SERNFI = SD2.D2_SERIE AND VS1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VS3")+" VS3 ON VS3.VS3_FILIAL = '" + xFilial("VS3") + "' AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS3.VS3_CODSIT = '03' AND VS3.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SD2.D2_COD AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_EMISSAO >= '"+dtos(MV_PAR01)+"' AND SD2.D2_EMISSAO <= '"+dtos(MV_PAR02)+"' AND "
cQuery += "SD2.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSD2, .F., .T. )
//
nTotReg := Contar(cQryAliasSD2, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSD2)->(DBGoTop())
//
While  !(cQryAliasSD2)->(Eof())
	//
	nLinhArq++
	
	cSinal := ""
	if (cQryAliasSD2)->(D2_QUANT) < 0
		cSinal := "-"
	Endif
	//
	
	nQtdReg += 1

	aAdd(aValor120,{"CA1",120,substr((cQryAliasSD2)->(B1_CODITE),1,14),(cQryAliasSD2)->(D2_QUANT),"" })
	//
	aAdd(aLinhasRel,{"CA1",transform(120,"999"),(cQryAliasSD2)->(B1_CODITE),transform((cQryAliasSD2)->(D2_QUANT),"99999")})
	//
	
	if MV_PAR04 == 1
	    nPos := 0
        nPos := aScan(aValores310,{|x| x[1]+str(x[2],3)+x[3] == "CA1"+"310"+substr((cQryAliasSD2)->(B1_CODITE),1,14) }) 
		if nPos == 0
			aAdd(aValores310,{"CA1",310,substr((cQryAliasSD2)->(B1_CODITE),1,14),(cQryAliasSD2)->(B2_QATU),""})
			nQtdReg += 1
	    Endif
		//
		aAdd(aLinhasRel,{"CA1",transform(310,"999"),(cQryAliasSD2)->(B1_CODITE),transform((cQryAliasSD2)->(B2_QATU),"99999")})
	Endif
	(cQryAliasSD2)->(DBSkip())
	
Enddo
//
(cQryAliasSD2)->(dbCloseArea())


// CA1777 - CARGA INICIAL - PEÇAS ORIGINAIS VW
if MV_PAR03 == 1
	cQryAliasSB1 := GetNextAlias()
	cQuery := "SELECT SB1.B1_CODITE,SB2.B2_QATU,SC7.C7_QUANT,SC7.C7_EMISSAO,SC7.C7_NUM,SC7.C7_SEQUEN,SC7.C7_PRODUTO "
	cQuery += " FROM " + RetSQLName("SB1") + " SB1 "
	cQuery += " INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SB1.B1_COD  AND SB2.B2_LOCAL = SB1.B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '" + xFilial("SBM") + "' AND SBM.BM_GRUPO = '"+MV_PAR12+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_PROORI = '1' AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SC7")+" SC7 ON SC7.C7_FILIAL = '" + xFilial("SC7") + "' AND SC7.C7_PRODUTO = SB1.B1_COD AND (SC7.C7_RESIDUO <> ' ' OR SC7.C7_QUANT <= SC7.C7_QUJE) AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_TIPO = 'ME' AND SB1.B1_GRUPO != '"+GETMV("MV_GRUVEI")+"' AND "
	cQuery += "SB1.D_E_L_E_T_ = ' '"
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSB1, .F., .T. )
	//
	nTotReg := Contar(cQryAliasSB1, "!Eof()")
	//
	SetRegua(nTotReg)
	nLinhArq := 0
	(cQryAliasSB1)->(DBGoTop())
	//
	While  !(cQryAliasSB1)->(Eof())
		//
		nLinhArq++
		
		dbSelectArea("SC7")
		dbSetOrder(5)
		dbSeek(xFilial("SC7")+(cQryAliasSB1)->C7_EMISSAO+(cQryAliasSB1)->C7_NUM+(cQryAliasSB1)->C7_SEQUEN)
		nQtd := 1
		cDemanda1 := 0
		cDemanda2 := 0
		cDemanda3 := 0
		cDemanda4 := 0
		cDemanda5 := 0
		cDemanda6 := 0
		While !Eof() .and. xFilial("SC7") = SC7->C7_FILIAL .AND. (cQryAliasSB1)->C7_PRODUTO == SC7->C7_PRODUTO
			dbSkip(-1)
			if (cQryAliasSB1)->C7_PRODUTO == SC7->C7_PRODUTO
				if nQtd == 1
					cDemanda1 := SC7->C7_QUANT
				Elseif nQtd == 2
					cDemanda2 := SC7->C7_QUANT
				Elseif nQtd == 3
					cDemanda3 := SC7->C7_QUANT
				Elseif nQtd == 4
					cDemanda4 := SC7->C7_QUANT
				Elseif nQtd == 5
					cDemanda5 := SC7->C7_QUANT
				Else
					cDemanda6 := SC7->C7_QUANT
					Exit
				Endif
				dbSelectArea("SC7")
				dbSkip()
			Endif
		Enddo
		if cDemanda1 == 0
			cTipVda := "0"
		Elseif cDemanda1 > 0 .and. (cDemanda2+cDemanda3+cDemanda4+cDemanda5+cDemanda6) == 0
			cTipVda := "1"
		Else	
			cTipVda := " "
		Endif
	

	    nPos := 0
        nPos := aScan(aValor777,{|x| x[1]+str(x[2],3)+x[3] == "CA1"+"777"+substr((cQryAliasSB1)->(B1_CODITE),1,14) }) 
		if nPos == 0
		   aAdd(aValor777,{"CA1",777,substr((cQryAliasSB1)->(B1_CODITE),1,14),"",(cQryAliasSB1)->(B2_QATU),(cQryAliasSB1)->(C7_QUANT),cDemanda1,cDemanda2,cDemanda3,cDemanda4,cDemanda5,cDemanda6,cTipVda,"" })
			nQtdReg += 1
		Else
           aValor777[nPos,6] += (cQryAliasSB1)->(C7_QUANT)
		Endif
		//
		aAdd(aLinhasRel,{"CA1",transform(777,"999"),(cQryAliasSB1)->(B1_CODITE),transform((cQryAliasSB1)->(B2_QATU),"99999")})
		//
		(cQryAliasSB1)->(DBSkip())
	
	Enddo
	//
	(cQryAliasSB1)->(dbCloseArea())
Endif

// Monta CA1000
aValCA10 := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno            
nH := substr(time(),1,2)
nM := substr(time(),4,2)
nS := substr(time(),7,2)
nHora := val(nH+nM+nS)
aAdd(aValCA10,{"CA1", 0 , nData , "000"+Alltrim(strzero(MV_PAR05,4))+"0" , "V" , nQtdReg , " " , "AUTOPART" , "R" , nHora , " " , 010109 } )
cLinhaCA10 := MontaEDI(aLayCA10,aValCA10[1])
fwrite(nHnd,cLinhaCA10)

// CA1011
for nni := 1 to Len(aVetAjusP)
	if aVetAjusP[nni,2]>0
		//
		aValores := {"CA1",11,;
		substr(aVetAjusP[nni,1],1,14),;
		aVetAjusP[nni,2],;
		" " }
		//
		cLinha := MontaEDI(aLayCA1011,aValores)
		//
		fwrite(nHnd,cLinha)
		//
		nLinhArq++
		aAdd(aLinhasRel,{"CA1",transform(11,"999"),aVetAjusP[nni,1],transform(aVetAjusP[nni,2],"99999")})
		//
	endif
next

// CA1012
for nni := 1 to Len(aVetAjusN)
	if aVetAjusN[nni,2]>0
		//
		aValores := {"CA1",12,;
		substr(aVetAjusN[nni,1],1,14),;
		aVetAjusN[nni,2],;
		" " }
		//
		cLinha := MontaEDI(aLayCA1011,aValores)
		//
		fwrite(nHnd,cLinha)
		//
		nLinhArq++
		aAdd(aLinhasRel,{"CA1",transform(11,"999"),aVetAjusN[nni,1],transform(aVetAjusN[nni,2],"99999")})
		//
	endif
next

// CA1015

For i := 1 to Len(aValores15)	//
	//
	cLinha := MontaEDI(aLayCA1015,aValores15[i])
	//
	fwrite(nHnd,cLinha)
	//
Next

// CA1099

For i:= 1 to Len(aValor99)
	//
	//
	cLinha := MontaEDI(aLayCA1099,aValor99[i])
	//
	fwrite(nHnd,cLinha)
Next

// CA1101

For i:= 1 to Len(aValor101)

	//
	cLinha := MontaEDI(aLayCA1101,aValor101[i])
	//
	fwrite(nHnd,cLinha)
Next

// CA1102

For i:= 1 to Len(aValor102)
	//
	cLinha := MontaEDI(aLayCA1102,aValor102[i])
	//
	fwrite(nHnd,cLinha)
Next

// CA1104

For i:= 1 to Len(aValor104)

	//
	cLinha := MontaEDI(aLayCA1104,aValor104[i])
	//
	fwrite(nHnd,cLinha)
Next

// CA1105

For i:= 1 to Len(aValor105)
      
	//
	if aValor105[i,4] <> 0
		cLinha := MontaEDI(aLayCA1105,aValor105[i])
	//
		fwrite(nHnd,cLinha)
	Endif	

Next

// CA1120

For i:= 1 to Len(aValor120)

	//
	cLinha := MontaEDI(aLayCA1120,aValor120[i])
	//
	fwrite(nHnd,cLinha)

Next     

// CA1310

if MV_PAR04 == 1
	For i := 1 to len(aValores310)
		cLinha310 := MontaEDI(aLayCA1310,aValores310[i])
		//
		fwrite(nHnd,cLinha310)
	Next
Endif


// CA1777

For i:= 1 to Len(aValor777)

	//
	cLinha := MontaEDI(aLayCA1777,aValor777[i])
	//
	fwrite(nHnd,cLinha)

Next

// Monta CAF
aValCAF := {}
aAdd(aValCAF,{"CAF",1, 0,nQtdReg+3," " } )
cLinhaCAF := MontaEDI(aLayCAF,aValCAF[1])
fwrite(nHnd,cLinhaCAF)

//
// Monta CHF
aValCHF := {}
aAdd(aValCHF,{"CHF",1, 0,nQtdReg+3," " } )
cLinhaCHF := MontaEDI(aLayCHF,aValCHF[1])
fwrite(nHnd,cLinhaCHF)
//

fClose(nHnd)
//
if !lErro
	MsgInfo(STR0008,STR0007)
endif
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | ImprimeRel | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Imprime o resultado da importação                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := STR0029 
Local cDesc2  := STR0030 
Local cDesc3  := ""

Private cString  := "VV1" // TODO
Private Tamanho  := "M"
Private aReturn  := { STR0009,2,STR0010,2,2,1,"",1 }
Private wnrel    := "AUTOPARTVW" // TODO
Private NomeProg := "AUTOPARTVW" // TODO
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := cTitulo+" ("+cArquivo+")"+" - " + dtoc(ddatabase)
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := " "  // TODO
Private Cabec2   := " "  // TODO
Private cPerg := ""
//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)
//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------    
         
li := 1
li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
Li++
@ Li++, 1   PSay STR0033     
                   
if Len(aLinhasRel) > 0 
	aSort(aLinhasRel,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })
Endif
for nCntFor = 1 to Len(aLinhasRel)
	
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	//
	@ Li++, 1   PSay aLinhasRel[nCntFor,1]+" "+aLinhasRel[nCntFor,2]+" "+aLinhasRel[nCntFor,3]+" "+aLinhasRel[nCntFor,4]
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay STR0011
		exit
	Endif
next
//
If Li <> 80
	Roda(cbCont,cbTxt,Tamanho)
Endif
//
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf
//
Ms_Flush()
//
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXN003   | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Monta layout.                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MontaEDI(aLayout, aInfo)
Local nCntFor
Local cLinha := ""
for nCntFor = 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	//
	ncValor := ""
	if Alltrim(cTipo) == "N"
		if valType(aInfo[nCntFor]) == "C"
			aInfo[nCntFor] = val(aInfo[nCntFor])
		endif
		ncValor = STRZERO(Round(aInfo[nCntFor] * (10 ^ nDecimal),0),nTamanho)
	else
		ncValor := LEFT(aInfo[nCntFor]+SPACE(nTamanho),nTamanho)
	endif
	cLinha += ncValor
next
cLinha += CHR(13) + CHR(10)
return cLinha

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME" ,"X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aAdd a Pergunta                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
"	MV_PAR01 - Data Inicial - DATE
"	MV_PAR02 - Data Final - DATE
"	MV_PAR03 - Envia Saldo Inicial? - Sim/Não
"	MV_PAR04 - Envia Inventário? - Sim/Não
"	MV_PAR05 - DN da concessionária - Numérico 4
"	MV_PAR06 - Tipos de Pedido Autopart - Caractere 200
"	MV_PAR07 - Tipos de Pedido Carro Parado - Caractere 200
"	MV_PAR08 - Atividade Oficina Frotista - Caractere 200
"	MV_PAR09 - Atividade Outro Dealer - Caractere 200
"	MV_PAR11 - Diretório de Geração do Arquivo - Caractere 200
"	MV_PAR12 - Marca
*/

aAdd(aSX1,{cPerg,"01",STR0013,"","","MV_CH1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
aAdd(aSX1,{cPerg,"02",STR0014,"","","MV_CH2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"03",STR0015,"","","MV_CH3","N",1,0,0,"C","","mv_par03",STR0024,"","","","",STR0025,"","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})
aAdd(aSX1,{cPerg,"04",STR0016,"","","MV_CH4","N",1,0,0,"C","","mv_par04",STR0024,"","","","",STR0025,"","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})
aAdd(aSX1,{cPerg,"05",STR0017,"","","MV_CH5","N",4,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","9999"})
aAdd(aSX1,{cPerg,"06",STR0018,"","","MV_CH6","C",99,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"07",STR0019,"","","MV_CH7","C",99,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"08",STR0020,"","","MV_CH8","C",99,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"09",STR0021,"","","MV_CHA","C",99,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"10",STR0032,"","","MV_CHB","C",99,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"11",STR0022,"","","MV_CHC","C",99,0,0,"G","!Vazio().or.(Mv_Par11:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"12",STR0023,"","","MV_CHD","C",4,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","S","","",""})
aAdd(aSX1,{cPerg,"13",STR0027,"","","MV_CHE","C",99,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})


ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
			IncProc(STR0026)
		EndIf
	EndIf
Next i

return