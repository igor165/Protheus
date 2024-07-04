// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 5      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI011.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXI011   | Autor | Thiago                | Data | 02/01/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exporta as informações do AUTOSERVICE para a montadora       |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXI011()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002

Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0006 // TODO - Titulo do Assunto (Vai no relatório e FormBatch)
Private cPerg := "OXI011" 	// TODO -Pergunte
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que serão apresentadas no relatorio
Private aValores310 := {}
Private aLayCK6011 := {}
Private aLayCK6021 := {}
Private aLayCK6031 := {}     
Private aLayCK6041 := {}     
Private aLayCK6042 := {}     
Private aLayCK7001 := {}     
Private aLayCK7002 := {}     
Private aLayCK7003 := {}     
Private aLayCK7004 := {}     
Private aLayCK3001 := {}     
Private aLayCK3002 := {}     
Private aLayCK3003 := {}   
Private aLayCK4001 := {}  
Private aLayCK5001 := {} 
Private aParamBox  := {}
Private cChaint    := ""   

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
//Pergunte(cPerg,.f.)
//
RptStatus( {|lEnd| ExportArq(@lEnd)},STR0032,STR0008)
//
//if !lErro
//	RptStatus({|lEnd| ImprimeRel(@lEnd) },"Aguarde...", "Imprimindo relatório.", .T. )
//endif
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
Local cQryAliasVO3 := "SQLVO3"
Local cQryAliasVO4 := "SQLVO4"
Local cQryAliasVEC := "SQLVEC"
Local cQryAliasVSC := "SQLVSC"
Local cQrySD2 := "SQLSD2"
//
Local nTotReg
//
Local aLayCHI    := {}
Local aLayCHF    := {}
Local aLayCKI    := {}
Local aLayCKF    := {}
Local i := 0 
Local nni    
Local aVetPecas := {}
Local aVetSRV := {}
Local cTipSer := ""
Local nSrvDes := 0  
Local aVetVeic := {} 
Local aVetCliente := {} 
Local nValDes := 0   
Local nSRVNF  := 0       
Local aBalcao := {}
Local aBalPec := {} 
Local aCancel := {}
Local aDadosCompl := {} 

Pergunte(cPerg,.f. )

c_mv_par01 := mv_par01
c_mv_par02 := mv_par02
c_mv_par03 := mv_par03
c_mv_par04 := mv_par04
c_mv_par05 := mv_par05
c_mv_par06 := mv_par06
c_mv_par07 := mv_par07
c_mv_par08 := mv_par08
c_mv_par09 := mv_par09
c_mv_par10 := mv_par10
c_mv_par11 := mv_par11
c_mv_par12 := mv_par12
c_mv_par13 := mv_par13
c_mv_par14 := mv_par14
c_mv_par15 := mv_par15
c_mv_par16 := mv_par16
c_mv_par17 := mv_par17
c_mv_par18 := mv_par18
c_mv_par19 := mv_par19
c_mv_par20 := mv_par20
c_mv_par21 := mv_par21
c_mv_par22 := mv_par22
c_mv_par23 := mv_par23
c_mv_par24 := mv_par24

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



aAdd(aLayCKI, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CKI)
aAdd(aLayCKI, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCKI, { "N", 3,	0,	5})     // IDENTIFICAÇÃO DO PROCESSO (000)
aAdd(aLayCKI, { "N", 1,	0,	8})     // VERSÃO DO PROCESSO (0)
aAdd(aLayCKI, { "N", 5,	0,	9})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCKI, { "N", 12, 0,	14})    // DATA DO MOVIMENTO (0000ddmmaaaa)
aAdd(aLayCKI, { "C", 14, 0,	26})    // IDENTIFICAÇÃO DO TRANSMISSOR (0NNNNBBB….B)
//  NNNN  = Código da Concessionária
//  BBB… = Brancos

aAdd(aLayCKI, { "N", 14, 0,	40})	// IDENTIFICAÇÃO DO RECEPTOR (00…0051)
aAdd(aLayCKI, { "C", 30, 0,	54})    // IDENTIFICAÇÃO DA SOFTWARE HOUSE
//  Razão Social
aAdd(aLayCKI, { "C", 110, 0, 84})   // BRANCOS


//
aAdd(aLayCKF, { "C", 3, 0, 1})		// TIPO DE REGISTRO (CKF)
aAdd(aLayCKF, { "N", 1, 0, 4})		// VERSÃO DO LAYOUT (1)
aAdd(aLayCKF, { "N", 5, 0, 5})		// CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCKF, { "N", 9, 0, 10})		// TOTAL DE REGISTROS TRANSMITIDOS
// "  Quantidade total de registros de uma transmissão, incluindo os registros CKI e CKF."
aAdd(aLayCKF, { "C", 175, 0, 19}) 	// BRANCOS

// CK6011
aAdd(aLayCK6011, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CK6)
aAdd(aLayCK6011, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=011)
aAdd(aLayCK6011, { "N", 3 , 0 , 7})    // DADOS GERAIS DA OS E ORÇAMENTO - SERVIÇOS GI (Fixo=998)
aAdd(aLayCK6011, { "N", 5 , 0 , 10})   // NÚMERO DO CONCESSIONÁRIO - DN
aAdd(aLayCK6011, { "N", 12, 0 , 15})   // DATA E HORA DO ORÇAMENTO
aAdd(aLayCK6011, { "N", 6 , 0 , 27})   // NÚMERO DO ORÇAMENTO
aAdd(aLayCK6011, { "N", 6 , 0 , 33})   // NÚMERO DA OS
aAdd(aLayCK6011, { "N", 12, 0 , 39})   // DATA E HORA DA ABERTURA DA OS
aAdd(aLayCK6011, { "N", 12, 0 , 51})   // DATA E HORA DO FECHAMENTO DA OS
aAdd(aLayCK6011, { "N", 2 , 0 , 63})   // FONTE PAGADORA
aAdd(aLayCK6011, { "N", 9 , 2 , 65})   // TOTAL DA OS (ORDEM DE SERVIÇO)
aAdd(aLayCK6011, { "N", 9 , 2 , 74})   // TOTAL ORÇAMENTO
aAdd(aLayCK6011, { "N", 9 , 2 , 83})   // TOTAL DE PEÇA NA OS
aAdd(aLayCK6011, { "N", 9 , 2 , 92})   // TOTAL DE MÃO-DE-OBRA NA OS
aAdd(aLayCK6011, { "N", 9 , 2 , 101})   // TOTAL DE PEÇA NO ORÇAMENTO
aAdd(aLayCK6011, { "N", 9 , 2 , 110})   // TOTAL DE MÃO-DE-OBRA NO ORÇAMENTO
aAdd(aLayCK6011, { "C", 1 , 2 , 119})   // CERTIFICAÇÃO DE USADOS VW
aAdd(aLayCK6011, { "C", 1 , 2 , 120})   // GERA NOTA FISCAL
aAdd(aLayCK6011, { "C", 67, 0 , 121})   // BRANCOS
aAdd(aLayCK6011, { "N", 6 , 0 , 188})   // DATA DA VERSÃO (Fixo=010607)

// CK6021
aAdd(aLayCK6021, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CK6)
aAdd(aLayCK6021, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=021)
aAdd(aLayCK6021, { "N", 3 , 0 , 7})    // DADOS DA PECA (Fixo=998)
aAdd(aLayCK6021, { "N", 5 , 0 , 10})   // NÚMERO DO CONCESSIONÁRIO - DN
aAdd(aLayCK6021, { "C", 20, 0 , 15})   // NÚMERO DA PEÇA APLICADA
aAdd(aLayCK6021, { "C", 25, 0 , 35})   // DESCRIÇÃO DA PEÇA
aAdd(aLayCK6021, { "N", 6 , 2 , 60})   // QUANTIDADE DE PEÇA
aAdd(aLayCK6021, { "N", 8 , 2 , 66})   // VALOR UNITÁRIO DA PEÇA
aAdd(aLayCK6021, { "N", 8 , 2 , 74})   // VALOR TOTAL DA PEÇA COM IMPOSTO
aAdd(aLayCK6021, { "N", 8 , 2 , 82})   // DESCONTO CONCEDIDO NA PEÇA
aAdd(aLayCK6021, { "N", 8 , 2 , 90})   // VALOR TOTAL LÍQUIDO NA PEÇA
aAdd(aLayCK6021, { "N", 5 , 2 , 98})   // ALÍQUOTA DE IMPOSTO ICMS DA PEÇA
aAdd(aLayCK6021, { "C", 20, 0 , 103})   // NÚMERO DA PEÇA APLICADA
aAdd(aLayCK6021, { "C", 25, 0 , 123})   // DESCRIÇÃO DA PEÇA
aAdd(aLayCK6021, { "N", 6 , 2 , 148})   // QUANTIDADE DE PEÇA
aAdd(aLayCK6021, { "N", 8 , 2 , 154})   // VALOR UNITÁRIO DA PEÇA
aAdd(aLayCK6021, { "N", 8 , 2 , 162})   // VALOR TOTAL DA PEÇA COM IMPOSTO
aAdd(aLayCK6021, { "N", 8 , 2 , 177})   // DESCONTO CONCEDIDO NA PEÇA
aAdd(aLayCK6021, { "N", 8 , 2 , 178})   // VALOR TOTAL LÍQUIDO NA PEÇA
aAdd(aLayCK6021, { "N", 5 , 2 , 186})   // ALÍQUOTA DE IMPOSTO ICMS DA PEÇA
aAdd(aLayCK6021, { "C", 3 , 2 , 191})   // BRANCOS

// CK6031
aAdd(aLayCK6031, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CK6)
aAdd(aLayCK6031, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=031)
aAdd(aLayCK6031, { "N", 3 , 0 , 7})    // DADOS DA PECA (Fixo=998)
aAdd(aLayCK6031, { "N", 5 , 0 , 10})   // NÚMERO DO CONCESSIONÁRIO - DN
aAdd(aLayCK6031, { "C", 8 , 0 , 15})   // COS (CÓDIGO DE OPERAÇÃO DE SERVIÇO)
aAdd(aLayCK6031, { "C", 25, 0 , 23})   // DESCRIÇÃO DO SERVIÇO
aAdd(aLayCK6031, { "N", 1 , 0 , 48})   // TIPO DE SERVIÇO
aAdd(aLayCK6031, { "N", 5 , 2 , 49})   // HORA VENDIDA
aAdd(aLayCK6031, { "N", 9 , 2 , 54})   // VALOR TOTAL DA MÃO-DE-OBRA
aAdd(aLayCK6031, { "N", 9 , 2 , 63})   // DESCONTO CONCEDIDO NA MÃO DE OBRA
aAdd(aLayCK6031, { "N", 9 , 2 , 72})   // VALOR TOTAL LÍQUIDO DA MÃO DE OBRA
aAdd(aLayCK6031, { "N", 5 , 2 , 81})   // ALÍQUOTA DE IMPOSTO ISS DA MÃO-DE-OBRA
aAdd(aLayCK6031, { "C", 8 , 0 , 86})   // COS (CÓDIGO DE OPERAÇÃO DE SERVIÇO)
aAdd(aLayCK6031, { "C", 25, 0 , 94})   // DESCRIÇÃO DO SERVIÇO
aAdd(aLayCK6031, { "N", 1 , 0 , 119})   // TIPO DE SERVIÇO
aAdd(aLayCK6031, { "N", 5 , 2 , 120})   // HORA VENDIDA
aAdd(aLayCK6031, { "N", 9 , 2 , 125})   // VALOR TOTAL DA MÃO-DE-OBRA
aAdd(aLayCK6031, { "N", 9 , 2 , 134})   // DESCONTO CONCEDIDO NA MÃO DE OBRA
aAdd(aLayCK6031, { "N", 9 , 2 , 143})   // VALOR TOTAL LÍQUIDO DA MÃO DE OBRA
aAdd(aLayCK6031, { "N", 5 , 2 , 152})   // ALÍQUOTA DE IMPOSTO ISS DA MÃO-DE-OBRA
aAdd(aLayCK6031, { "C", 31, 0 , 157})   // BRANCOS  
aAdd(aLayCK6031, { "N", 6 , 0 , 188})   // DATA DA VERSÃO (Fixo=010607)  

// CK6041
aAdd(aLayCK6041, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CK6)
aAdd(aLayCK6041, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=041)
aAdd(aLayCK6041, { "N", 3 , 0 , 7})    // DADOS DO VEÍCULO (Fixo=998)
aAdd(aLayCK6041, { "N", 5 , 0 , 10})   // NÚMERO DO CONCESSIONÁRIO - DN
aAdd(aLayCK6041, { "C", 17, 0 , 15})   // NÚMERO DO CHASSI DO VEÍCULO
aAdd(aLayCK6041, { "C", 7 , 0 , 32})   // PLACA DO VEÍCULO
aAdd(aLayCK6041, { "N", 6 , 0 , 39})   // KM - QUILOMETRAGEM DO VEÍCULO
aAdd(aLayCK6041, { "C", 40, 0 , 45})   // NOME DO CLIENTE
aAdd(aLayCK6041, { "C", 1 , 0 , 85})   // INDICADOR
aAdd(aLayCK6041, { "N", 14, 0 , 86})   // CPF, CNPJ
aAdd(aLayCK6041, { "C", 40, 0 ,100})   // ENDEREÇO
aAdd(aLayCK6041, { "C", 5 , 0 ,140})   // NÚMERO
aAdd(aLayCK6041, { "C", 10, 0 ,145})   // COMPLEMENTO
aAdd(aLayCK6041, { "C", 20, 0 ,155})   // BAIRRO
aAdd(aLayCK6041, { "C", 13, 0 ,175})   // BRANCOS
aAdd(aLayCK6041, { "N", 6 , 0 ,188})   // DATA DA VERSÃO (Fixo=010607)

// CK6042
aAdd(aLayCK6042, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CK6)
aAdd(aLayCK6042, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=042)
aAdd(aLayCK6042, { "N", 3 , 0 , 7})    // DADOS DO CLIENTE (Fixo=998)
aAdd(aLayCK6042, { "N", 5 , 0 , 10})   // NÚMERO DO CONCESSIONÁRIO - DN
aAdd(aLayCK6042, { "C", 40, 0 , 15})   // MUNICÍPIO
aAdd(aLayCK6042, { "C", 2 , 0 , 55})   // UF
aAdd(aLayCK6042, { "N", 8 , 0 , 57})   // CEP
aAdd(aLayCK6042, { "C", 11, 0 , 65})   // TELEFONE RESIDENCIAL
aAdd(aLayCK6042, { "C", 11, 0 , 76})   // CELULAR
aAdd(aLayCK6042, { "C", 50, 0 , 87})   // EMAIL
aAdd(aLayCK6042, { "C", 11, 0 ,137})   // TELEFONE COMERCIAL
aAdd(aLayCK6042, { "C", 40, 0 ,148})   // BRANCOS
aAdd(aLayCK6042, { "N", 6 , 0 ,188})   // DATA DA VERSÃO (Fixo=010607)
                                     
// CK7001
aAdd(aLayCK7001, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CK7)
aAdd(aLayCK7001, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=001)
aAdd(aLayCK7001, { "N", 9 , 0 , 7})    // NÚMERO DA NOTA FISCAL
aAdd(aLayCK7001, { "C", 4 , 0 , 16})   // SÉRIE DA NOTA FISCAL
aAdd(aLayCK7001, { "N", 12, 0 , 20})   // DATA DE EMISSÃO DA NOTA FISCAL
aAdd(aLayCK7001, { "N", 6 , 0 , 32})   // NÚMERO DA OS
aAdd(aLayCK7001, { "N", 12, 0 , 38})   // DATA / HORA DE ABERTURA DA OS
aAdd(aLayCK7001, { "N", 2 , 0 , 50})   // FONTE PAGADORA
aAdd(aLayCK7001, { "N", 9 , 2 , 52})   // TOTAL DA NOTA FISCAL 
aAdd(aLayCK7001, { "N", 9 , 2 , 61})   // TOTAL DE PEÇAS NA NOTA FISCAL
aAdd(aLayCK7001, { "N", 9 , 2 , 70})   // DESCONTO GERAL DE PEÇAS NA NOTA FISCAL
aAdd(aLayCK7001, { "N", 9 , 2 , 79})   // TOTAL DE MÃO-DE-OBRA NA NOTA FISCAL
aAdd(aLayCK7001, { "N", 9 , 2 , 88})   // DESCONTO GERAL DE MÃO-DE-OBRA NA NOTA FISCAL
aAdd(aLayCK7001, { "C", 40, 0 , 97})   // NOME DO CLIENTE
aAdd(aLayCK7001, { "C", 40, 0 ,137})   // ENDEREÇO
aAdd(aLayCK7001, { "C", 1 , 0 ,177})   // SERVIÇO APLICADO EM VEÍCULO NOVO
aAdd(aLayCK7001, { "C", 10, 0 ,178})   // BRANCOS
aAdd(aLayCK7001, { "N", 6 , 0 ,188})   // DATA DA VERSÃO (Fixo=010607)

// CK7002
aAdd(aLayCK7002, { "C", 3 , 0 , 1})    // TIPO DE REGISTRO (CK7)
aAdd(aLayCK7002, { "N", 3 , 0 , 4})    // SUB-CÓDIGO DO REGISTRO (Fixo=002)
aAdd(aLayCK7002, { "C", 1 , 0 , 7})    // INDICADOR
aAdd(aLayCK7002, { "N", 14, 0 , 8})    // CPF, CNPJ
aAdd(aLayCK7002, { "C", 5 , 0 , 22})   // NÚMERO
aAdd(aLayCK7002, { "C", 10, 0 , 27})   // COMPLEMENTO
aAdd(aLayCK7002, { "C", 20, 0 , 37})   // BAIRRO
aAdd(aLayCK7002, { "C", 40, 0 , 57})   // MUNICÍPIO
aAdd(aLayCK7002, { "C", 2 , 0 , 97})   // UF
aAdd(aLayCK7002, { "N", 8 , 0 , 99})   // CEP
aAdd(aLayCK7002, { "C", 11, 0 ,107})   // TELEFONE RESIDENCIAL
aAdd(aLayCK7002, { "C", 50, 0 ,118})   // EMAIL
aAdd(aLayCK7002, { "C", 11, 0 ,168})   // TELEFONE CELULAR
aAdd(aLayCK7002, { "C", 11, 0 ,179})   // TELEFONE COMERCIAL
aAdd(aLayCK7002, { "N", 1 , 0 ,190})   // CÓDIGO PREFERENCIAL DE CONTATO TELEFÔNICO
aAdd(aLayCK7002, { "C", 3 , 0 ,191})   // BRANCOS
                  
// CK7003
aAdd(aLayCK7003, { "C", 3 , 0 ,  1})    // TIPO DE REGISTRO (CK7)
aAdd(aLayCK7003, { "N", 3 , 0 ,  4})    // SUB-CÓDIGO DO REGISTRO (Fixo=003)
aAdd(aLayCK7003, { "C", 20, 0 ,  7})    // NÚMERO DA PEÇA APLICADA
aAdd(aLayCK7003, { "C", 25, 0 , 27})    // DESCRIÇÃO DA PEÇA
aAdd(aLayCK7003, { "N", 6 , 2 , 52})   // QUANTIDADE DE PEÇA NA NF
aAdd(aLayCK7003, { "N", 8 , 2 , 58})   // VALOR UNITÁRIO DA PEÇA NA NF
aAdd(aLayCK7003, { "N", 8 , 2 , 66})   // VALOR TOTAL DA PEÇA COM IMPOSTO NA NF
aAdd(aLayCK7003, { "N", 8 , 2 , 74})   // DESCONTO CONCEDIDO NO TOTAL DA PEÇA
aAdd(aLayCK7003, { "N", 8 , 2 , 82})   // VALOR TOTAL LÍQUIDO DA PEÇA
aAdd(aLayCK7003, { "N", 5 , 2 , 90})   // ALÍQUOTA DE IMPOSTO ICMS DA PEÇA
aAdd(aLayCK7003, { "N", 5 , 2 , 95})   // ALÍQUOTA DE IMPOSTO PIS/COFINS DA PEÇA
aAdd(aLayCK7003, { "C", 20, 0 ,100})   // NÚMERO DA PEÇA APLICADA
aAdd(aLayCK7003, { "C", 25, 0 ,120})    // DESCRIÇÃO DA PEÇA
aAdd(aLayCK7003, { "N", 6 , 2 ,145})   // QUANTIDADE DE PEÇA NA NF
aAdd(aLayCK7003, { "N", 8 , 2 ,151})   // VALOR UNITÁRIO DA PEÇA NA NF
aAdd(aLayCK7003, { "N", 8 , 2 ,159})   // VALOR TOTAL DA PEÇA COM IMPOSTO NA NF
aAdd(aLayCK7003, { "N", 8 , 2 ,164})   // DESCONTO CONCEDIDO NO TOTAL DA PEÇA
aAdd(aLayCK7003, { "N", 8 , 2 ,175})   // VALOR TOTAL LÍQUIDO DA PEÇA
aAdd(aLayCK7003, { "N", 5 , 2 ,183})   // ALÍQUOTA DE IMPOSTO ICMS DA PEÇA
aAdd(aLayCK7003, { "N", 5 , 2 ,188})   // ALÍQUOTA DE IMPOSTO PIS/COFINS DA PEÇA
aAdd(aLayCK7003, { "C", 1 , 0 ,193})   // BRANCOS

// CK7004
aAdd(aLayCK7004, { "C", 3 , 0 ,  1})    // TIPO DE REGISTRO (CK7)
aAdd(aLayCK7004, { "N", 3 , 0 ,  4})    // SUB-CÓDIGO DO REGISTRO (Fixo=004)
aAdd(aLayCK7004, { "C", 8 , 0 ,  7})    // COS (CÓDIGO DE OPERAÇÃO DE SERVIÇO)
aAdd(aLayCK7004, { "C", 25, 0 , 15})    // DESCRIÇÃO DO SERVIÇO
aAdd(aLayCK7004, { "N", 5 , 2 , 40})    // HORA VENDIDA NA NF
aAdd(aLayCK7004, { "N", 9 , 2 , 45})   // VALOR TOTAL DA MÃO-DE-OBRA NA NF
aAdd(aLayCK7004, { "N", 9 , 2 , 54})   // DESCONTO CONCEDIDO SOBRE A MÃO-DE-OBRA
aAdd(aLayCK7004, { "N", 9 , 2 , 63})   // VALOR TOTAL LÍQUIDO DA MÃO DE OBRA
aAdd(aLayCK7004, { "N", 5 , 2 , 72})   // ALÍQUOTA DE IMPOSTO ISS DA MÃO-DE-OBRA
aAdd(aLayCK7004, { "N", 5 , 2 , 77})   // ALÍQUOTA DE IMPOSTO PIS/COFINS DA MÃO-DE-OBRA    
aAdd(aLayCK7004, { "C", 8 , 0 , 82})    // COS (CÓDIGO DE OPERAÇÃO DE SERVIÇO)
aAdd(aLayCK7004, { "C", 25, 0 , 90})    // DESCRIÇÃO DO SERVIÇO
aAdd(aLayCK7004, { "N", 5 , 2 ,115})    // HORA VENDIDA NA NF
aAdd(aLayCK7004, { "N", 9 , 2 ,120})   // VALOR TOTAL DA MÃO-DE-OBRA NA NF
aAdd(aLayCK7004, { "N", 9 , 2 ,129})   // DESCONTO CONCEDIDO SOBRE A MÃO-DE-OBRA
aAdd(aLayCK7004, { "N", 9 , 2 ,138})   // VALOR TOTAL LÍQUIDO DA MÃO DE OBRA
aAdd(aLayCK7004, { "N", 5 , 2 ,147})   // ALÍQUOTA DE IMPOSTO ISS DA MÃO-DE-OBRA
aAdd(aLayCK7004, { "N", 5 , 2 ,152})   // ALÍQUOTA DE IMPOSTO PIS/COFINS DA MÃO-DE-OBRA
aAdd(aLayCK7004, { "C", 31, 0 ,157})   // BRANCOS
aAdd(aLayCK7004, { "N", 6 , 0 ,188})   // DATA DA VERSÃO (Fixo=010607)

// CK3001
aAdd(aLayCK3001, { "C", 3 , 0 ,  1})   // TIPO DE REGISTRO (CK3)
aAdd(aLayCK3001, { "N", 3 , 0 ,  4})   // SUB-CÓDIGO DO REGISTRO (Fixo=001)
aAdd(aLayCK3001, { "N", 5 , 0 ,  7})   // NÚMERO DO DN
aAdd(aLayCK3001, { "N", 9 , 0 , 12})   // NÚMERO DA NOTA FISCAL
aAdd(aLayCK3001, { "C", 4 , 0 , 21})   // SÉRIE DA NOTA FISCAL
aAdd(aLayCK3001, { "N", 12, 0 , 25})   // DATA E HORA DE EMISSÃO DA NOTA FISCAL
aAdd(aLayCK3001, { "N", 2 , 0 , 37})   // CLASSIFICAÇÃO DO CLIENTE
aAdd(aLayCK3001, { "N", 11, 2 , 39})   // TOTAL DA NOTA FISCAL
aAdd(aLayCK3001, { "N", 9 , 2 , 50})   // TOTAL DE PEÇAS NA NOTA FISCAL
aAdd(aLayCK3001, { "N", 9 , 2 , 59})   // DESCONTO GERAL DE PEÇAS NA NOTA FISCAL
aAdd(aLayCK3001, { "C", 40, 0 , 68})   // NOME DO CLIENTE
aAdd(aLayCK3001, { "C", 1 , 0 ,108})   // INDICADOR
aAdd(aLayCK3001, { "N", 14, 0 ,109})   // CPF, CNPJ
aAdd(aLayCK3001, { "C", 40, 0 ,123})   // ENDEREÇO
aAdd(aLayCK3001, { "C", 5 , 0 ,163})   // NÚMERO
aAdd(aLayCK3001, { "C", 10, 0 ,168})   // COMPLEMENTO
aAdd(aLayCK3001, { "C", 10, 0 ,178})   // BRANCOS
aAdd(aLayCK3001, { "N", 6 , 0 ,188})   // DATA DA VERSÃO (Fixo=010607)

// CK3002
aAdd(aLayCK3002, { "C", 3 , 0 ,  1})   // TIPO DE REGISTRO (CK3)
aAdd(aLayCK3002, { "N", 3 , 0 ,  4})   // SUB-CÓDIGO DO REGISTRO (Fixo=002)
aAdd(aLayCK3002, { "C", 20, 0 ,  7})   // BAIRRO
aAdd(aLayCK3002, { "C", 40, 0 , 27})   // MUNICÍPIO
aAdd(aLayCK3002, { "C", 2 , 0 , 67})   // UF
aAdd(aLayCK3002, { "N", 8 , 0 , 69})   // CEP
aAdd(aLayCK3002, { "C", 11, 0 , 77})   // TELEFONE RESIDENCIAL
aAdd(aLayCK3002, { "C", 50, 0 , 88})   // EMAIL
aAdd(aLayCK3002, { "C", 11, 0 ,138})   // TELEFONE CELULAR
aAdd(aLayCK3002, { "C", 11, 0 ,138})   // TELEFONE COMERCIAL
aAdd(aLayCK3002, { "C", 28, 0 ,160})   // BRANCOS
aAdd(aLayCK3002, { "N", 6 , 0 ,188})   // DATA DA VERSÃO (Fixo=010607)

// CK3003
aAdd(aLayCK3003, { "C", 3 , 0 ,  1})   // TIPO DE REGISTRO (CK3)
aAdd(aLayCK3003, { "N", 3 , 0 ,  4})   // SUB-CÓDIGO DO REGISTRO (Fixo=003)
aAdd(aLayCK3003, { "C", 20, 0 ,  7})   // NÚMERO DA PEÇA APLICADA
aAdd(aLayCK3003, { "C", 25, 0 , 27})   // DESCRIÇÃO DA PEÇA
aAdd(aLayCK3003, { "N", 6 , 2 , 52})   // QUANTIDADE DE PEÇA
aAdd(aLayCK3003, { "N", 8 , 2 , 58})   // VALOR UNITÁRIO DA PEÇA NA NF
aAdd(aLayCK3003, { "N", 8 , 2 , 66})   // VALOR TOTAL DA PEÇA COM IMPOSTO NA NF
aAdd(aLayCK3003, { "N", 8 , 2 , 74})   // DESCONTO CONCEDIDO NO TOTAL DA PEÇA NA NF
aAdd(aLayCK3003, { "N", 8 , 2 , 82})   // VALOR TOTAL LÍQUIDO DA PEÇA
aAdd(aLayCK3003, { "N", 5 , 2 , 90})   // ALÍQUOTA DE IMPOSTO ICMS DA PEÇA
aAdd(aLayCK3003, { "N", 5 , 2 , 90})   // ALÍQUOTA DE IMPOSTO ICMS DA PEÇA
aAdd(aLayCK3003, { "C", 20, 0 ,100})   // NÚMERO DA PEÇA APLICADA
aAdd(aLayCK3003, { "C", 25, 0 ,120})   // DESCRIÇÃO DA PEÇA
aAdd(aLayCK3003, { "N", 6 , 2 ,145})   // QUANTIDADE DE PEÇA
aAdd(aLayCK3003, { "N", 8 , 2 ,151})   // VALOR UNITÁRIO DA PEÇA NA NF
aAdd(aLayCK3003, { "N", 8 , 2 ,159})   // VALOR TOTAL DA PEÇA COM IMPOSTO NA NF
aAdd(aLayCK3003, { "N", 8 , 2 ,167})   // DESCONTO CONCEDIDO NO TOTAL DA PEÇA NA NF
aAdd(aLayCK3003, { "N", 8 , 2 ,175})   // VALOR TOTAL LÍQUIDO DA PEÇA
aAdd(aLayCK3003, { "N", 5 , 2 ,183})   // ALÍQUOTA DE IMPOSTO ICMS DA PEÇA
aAdd(aLayCK3003, { "N", 5 , 2 ,188})   // ALÍQUOTA DE IMPOSTO PIS/COFINS DA PEÇA
aAdd(aLayCK3003, { "C", 1 , 0 ,193})   // BRANCOS

// CK4001
aAdd(aLayCK4001, { "C", 3 , 0 ,  1})   // TIPO DE REGISTRO (CK4)
aAdd(aLayCK4001, { "N", 3 , 0 ,  4})   // SUB-CÓDIGO DO REGISTRO (Fixo=001)
aAdd(aLayCK4001, { "C", 2 , 0 ,  7})   // TIPO DO CANCELAMENTO
aAdd(aLayCK4001, { "N", 5 , 0 ,  9})   // NÚMERO DO DN
aAdd(aLayCK4001, { "N", 9 , 0 , 14})   // NÚMERO DA NOTA FISCAL
aAdd(aLayCK4001, { "C", 4 , 0 , 23})   // SÉRIE DA NOTA FISCAL
aAdd(aLayCK4001, { "N", 12, 0 , 27})   // DATA / HORA DE EMISSÃO DA NOTA FISCAL
aAdd(aLayCK4001, { "N", 6 , 0 , 39})   // NÚMERO DA OS
aAdd(aLayCK4001, { "N", 12, 0 , 45})   // DATA/HORA DE ABERTURA DA OS
aAdd(aLayCK4001, { "N", 2 , 0 , 57})   // FONTE PAGADORA
aAdd(aLayCK4001, { "N", 8 , 0 , 59})   // DATA DE CANCELAMENTO DO DOCUMENTO
aAdd(aLayCK4001, { "C",121, 0 , 67})   // BRANCOS
aAdd(aLayCK4001, { "N", 6 , 0 ,188})   // DATA DA VERSÃO (Fixo=010607)
                                
if c_mv_par03 == 2 
    
	// CK5001 - AUTOSERVICE - DADOS COMPLEMENTARES - Envio Mensal
	aAdd(aParamBox,{1,STR0009,ctod(""),"@D","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0010,0,"@E 999999:99","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0011,0,"@E 999999:99","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0012,0,"@E 999999:99","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0013,0,"@E 999999:99","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0014,0,"@E 999999:99","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0015,0,"@E 9999999:99","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0016,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0017,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0018,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0019,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0020,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0021,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0022,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0023,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0024,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0025,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0026,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0027,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0028,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0029,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0030,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0031,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0032,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0033,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0034,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0035,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0036,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0037,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0038,0,"999","","","",60,.f.}) 
	aAdd(aParamBox,{1,STR0039,0,"@R 99/9999","","","",60,.f.}) 
	If !(ParamBox(aParamBox,"Dados Complementares",,,,,,,,,.t.,.t.))
		return .f.
	endif
	// CK5001
	aAdd(aLayCK5001, { "C", 3 , 0 ,  1})   // TIPO DE REGISTRO (CK5)
	aAdd(aLayCK5001, { "N", 3 , 0 ,  4})   // SUB-CÓDIGO DO REGISTRO (Fixo=001)
	aAdd(aLayCK5001, { "N", 3 , 0 ,  7})   // DADOS COMPLEMENTARES GI (Fixo=998)
	aAdd(aLayCK5001, { "N", 5 , 0 , 10})   // NÚMERO DO CONCESSIONÁRIO - DN
	aAdd(aLayCK5001, { "N", 8 , 0 , 15})   // DATA DO MOVIMENTO
	aAdd(aLayCK5001, { "N", 8 , 2 , 23})   // TEMPO REMUNERADO
	aAdd(aLayCK5001, { "N", 8 , 2 , 31})   // TEMPO DISPONIVEL - SERVIÇOS GERAIS - PRODUTIVOS
	aAdd(aLayCK5001, { "N", 8 , 2 , 39})   // TEMPO DISPONIVEL- SERVIÇOS RÁPIDO - PRODUTIVOS
	aAdd(aLayCK5001, { "N", 8 , 2 , 47})   // TEMPO DISPONIVEL - SERVIÇOS CARROCERIA - PRODUTIVOS - FUNILEIROS
	aAdd(aLayCK5001, { "N", 8 , 2 , 55})   // TEMPO DISPONIVEL - SERVIÇOS CARROCERIA - PRODUTIVOS - PINTORES
	aAdd(aLayCK5001, { "N", 9 , 2 , 63})   // TAXA DE MÃO DE OBRA PUBLICO
	aAdd(aLayCK5001, { "N", 3 , 0 , 72})   // SERVIÇOS - GERENTE
	aAdd(aLayCK5001, { "N", 3 , 0 , 75})   // SERVIÇOS - CHEFE DE OFICINA
	aAdd(aLayCK5001, { "N", 3 , 0 , 78})   // SERVIÇOS - CONSULTOR TÉCNICO
	aAdd(aLayCK5001, { "N", 3 , 0 , 81})   // SERVIÇOS - APRENDIZ
	aAdd(aLayCK5001, { "N", 3 , 0 , 84})   // SERVIÇOS - SUPORTE (APOIO)
	aAdd(aLayCK5001, { "N", 3 , 0 , 87})   // SERVIÇOS GERAIS - PRODUTIVOS
	aAdd(aLayCK5001, { "N", 3 , 0 , 90})   // SERVIÇOS RÁPIDO - PRODUTIVOS
	aAdd(aLayCK5001, { "N", 3 , 0 , 93})   // SERVIÇOS CARROCERIA - PRODUTIVOS - FUNILEIROS
	aAdd(aLayCK5001, { "N", 3 , 0 , 96})   // SERVIÇOS CARROCERIA - PRODUTIVOS - PINTORES
	aAdd(aLayCK5001, { "N", 3 , 0 , 99})   // SERVIÇOS - LAVADORES / LUBRIFICADORES
	aAdd(aLayCK5001, { "N", 3 , 0 ,102})   // SERVIÇOS - TERCEIROS
	aAdd(aLayCK5001, { "N", 3 , 0 ,105})   // PEÇAS - GERENTE
	aAdd(aLayCK5001, { "N", 3 , 0 ,108})   // PEÇAS - SUPORTE ( APOIO)
	aAdd(aLayCK5001, { "N", 3 , 0 ,111})   // PEÇAS - BALCONISTA - VAREJO
	aAdd(aLayCK5001, { "N", 3 , 0 ,114})   // PEÇAS - BALCONISTA - OFICINA
	aAdd(aLayCK5001, { "N", 3 , 0 ,117})   // PEÇAS - VENDEDOR ATACADO
	aAdd(aLayCK5001, { "N", 3 , 0 ,120})   // PEÇAS - VENDEDOR ACESSÓRIOS
	aAdd(aLayCK5001, { "N", 3 , 0 ,123})   // LOCAIS DE TRABALHO - SERVIÇOS GERAIS
	aAdd(aLayCK5001, { "N", 3 , 0 ,126})   // LOCAIS DE TRABALHO - SERVIÇO RÁPIDO
	aAdd(aLayCK5001, { "N", 3 , 0 ,129})   // LOCAIS DE TRABALHO - SERVIÇOS DE FUNILARIA
	aAdd(aLayCK5001, { "N", 3 , 0 ,132})   // LOCAIS DE TRABALHO - SERVIÇOS DE PINTURA
	aAdd(aLayCK5001, { "N", 3 , 0 ,135})   // LOCAIS DE TRABALHO - LAVAGEM E LUBRIFICAÇÃO
	aAdd(aLayCK5001, { "N", 3 , 0 ,138})   // LOCAIS DE TRABALHO - UTILIZADOS POR TERCEIROS
	aAdd(aLayCK5001, { "N", 6 , 0 ,141})   // MÊS E ANO DE REFERÊNCIA
	aAdd(aLayCK5001, { "C", 41, 0 ,147})   // BRANCOS
	aAdd(aLayCK5001, { "N", 6 , 0 ,188})   // DATA DA VERSÃO (Fixo=010607)
                     
Endif

// Monta CHI
aValCHI := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno
aAdd(aValCHI,{"CHI",1, 0,0,0,nData, "0"+Alltrim(strzero(c_MV_PAR04,4)),51,STR0040," " } )
cLinhaCHI := MontaEDI(aLayCHI,aValCHI[1])

// Monta CKI
aValCKI := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno
aAdd(aValCKI,{"CKI",1, 0,0,0,nData, "0"+Alltrim(strzero(c_MV_PAR04,4)),51,STR0040," " } )
cLinhaCKI := MontaEDI(aLayCKI,aValCKI[1])



//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
cArquivo := "OFIXI011.TXT"
//
if aDir( Alltrim(c_MV_PAR23)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
	if !MsgYesNo(STR0041,STR0042)
		lErro := .t.
		return
	endif
endif
//
nHnd := FCREATE(Alltrim(c_MV_PAR23)+Alltrim(cArquivo),0)
//
cQryAliasSF2 := GetNextAlias()

// CK6011 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA

cQuery := "SELECT SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_VALBRUT,VS1.VS1_DATORC,VS1.VS1_HORORC,VS1_NUMORC,SD2.D2_ALQPIS,SD2.D2_ALQCOF,VS1.VS1_VTOTNF,VO1.VO1_CHAINT,VS1.VS1_CHAINT,VO1.VO1_KILOME,SF2.F2_HORA "
cQuery += " FROM " + RetSQLName("SF2") + " SF2 "
cQuery += " INNER JOIN "+RetSqlName("VOO")+" VOO ON VOO.VOO_FILIAL = '" + xFilial("VOO") + "' AND VOO.VOO_NUMNFI = SF2.F2_DOC AND VOO.VOO_SERNFI = SF2.F2_SERIE AND VOO.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN "+RetSqlName("VS1")+" VS1 ON VS1.VS1_FILIAL = '" + xFilial("VS1") + "' AND VS1.VS1_NUMOSV = VOO.VOO_NUMOSV AND VS1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VO1")+" VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VOO.VOO_NUMOSV AND VO1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.VV1_CODMAR = '"+c_mv_par24+"' AND VV1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_EMISSAO >= '"+dtos(c_MV_PAR01)+"' AND SF2.F2_EMISSAO <= '"+dtos(c_MV_PAR02)+"' AND SF2.F2_PREFORI = '"+Alltrim(GetNewPar("MV_PREFOFI","OFI"))+"' AND "
cQuery += "SF2.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSF2, .F., .T. )
//
nTotReg := Contar(cQryAliasSF2, "!Eof()")
//
SetRegua(nTotReg)
nLinhArq := 0
(cQryAliasSF2)->(DBGoTop())
//
fwrite(nHnd,cLinhaCHI)
fwrite(nHnd,cLinhaCKI)
//
aVetAjus := {}
//
While  !(cQryAliasSF2)->(Eof())
    
	cTipTem := ""
    cChaint := (cQryAliasSF2)->VO1_CHAINT
	cQuery := "SELECT VEC.VEC_TIPTEM,VEC.VEC_NUMOSV,VEC.VEC_QTDITE,VEC.VEC_VALBRU,VEC.VEC_GRUITE,VEC.VEC_CODITE,VO3.VO3_DATFEC,VO3.VO3_HORFEC,VO3.VO3_VALPEC,VEC.VEC_VALDES,VEC.VEC_VALVDA,VEC.VEC_ALQICM,VEC.VEC_TIPTEM "
	cQuery += " FROM " + RetSQLName("VEC") + " VEC "
	cQuery += " LEFT JOIN "+RetSqlName("VO3")+" VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3.VO3_GRUITE = VEC.VEC_GRUITE AND VO3.VO3_CODITE = VEC.VEC_CODITE AND VO3.VO3_NUMOSV = VEC.VEC_NUMOSV AND VO3.VO3_TIPTEM = VEC.VEC_TIPTEM AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VEC.VEC_FILIAL = '" + xFilial("VEC") + "' AND VEC.VEC_NUMNFI = '"+(cQryAliasSF2)->F2_DOC+"' AND VEC.VEC_SERNFI = '"+(cQryAliasSF2)->F2_SERIE+"' AND "
	cQuery += "VEC.D_E_L_E_T_ = ' '"
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasVEC, .F., .T. )
	
	nTotOS  := 0
	nTotPec := 0
	dDatVen := stod("  /  /  ")
	cHorVen := 0 
	While  !(cQryAliasVEC)->(Eof())     
	                               
	   cNumOsv := (cQryAliasVEC)->VEC_NUMOSV
	   dDatVen := stod((cQryAliasVEC)->VO3_DATFEC)
	   cHorVen := (cQryAliasVEC)->VO3_HORFEC
	   nTotPec += (cQryAliasVEC)->VEC_VALVDA
	   nTotOS  += (cQryAliasVEC)->VEC_VALVDA
	   nValDes += (cQryAliasVEC)->VEC_VALDES
       cTipTem := (cQryAliasVEC)->VEC_TIPTEM
	   DBSelectArea("SBM")
	   DbSetOrder(1)
	   DbSeek( xFilial("SBM")+(cQryAliasVEC)->VEC_GRUITE )
       if Alltrim(SBM->BM_TIPGRU) == "1"		
          cCodIte := (cQryAliasVEC)->VEC_CODITE
       Else
          cCodIte := "ZZZ"+(cQryAliasVEC)->VEC_CODITE
       Endif   
	   DBSelectArea("SB1")
	   DbSetOrder(7)
	   DbSeek( xFilial("SB1")+(cQryAliasVEC)->VEC_GRUITE+(cQryAliasVEC)->VEC_CODITE )
	   aAdd(aVetPecas,{(cQryAliasVEC)->VEC_NUMOSV,(cQryAliasVEC)->VEC_TIPTEM,cCodIte,SB1->B1_DESC,(cQryAliasVEC)->VEC_QTDITE,(cQryAliasVEC)->VO3_VALPEC,(cQryAliasVEC)->VEC_VALBRU,(cQryAliasVEC)->VEC_VALDES,(cQryAliasVEC)->VEC_VALVDA,(cQryAliasVEC)->VEC_ALQICM,(cQryAliasSF2)->D2_ALQPIS+(cQryAliasSF2)->D2_ALQCOF})

       dbSelectArea(cQryAliasVEC)
       (cQryAliasVEC)->(dbSkip())
    Enddo
	(cQryAliasVEC)->(dbCloseArea())
	cQuery := "SELECT VSC.VSC_NUMOSV,VSC.VSC_CODSER,VSC.VSC_VALSER,VSC.VSC_RECVO4,VO6.VO6_DESSER,VSC.VSC_TIPSER,VSC.VSC_TEMVEN,VSC.VSC_VALSER,VSC.VSC_VALDES,VSC.VSC_VALBRU,VOK.VOK_AGRTIP,VSC.VSC_TIPTEM,SD2.D2_ALIQISS "
	cQuery += " FROM " + RetSQLName("VSC") + " VSC "  
	cQuery += " LEFT JOIN "+RetSqlName("VO6")+" VO6 ON VO6.VO6_FILIAL = '" + xFilial("VO6") + "' AND VO6.VO6_CODSER = VSC.VSC_CODSER AND VO6.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+RetSqlName("VOK")+" VOK ON VOK.VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK.VOK_TIPSER = VSC.VSC_TIPSER AND VOK.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_DOC = VSC.VSC_NUMNFI AND SD2.D2_SERIE = VSC.VSC_SERNFI AND VOK.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "' AND VSC.VSC_NUMNFI = '"+(cQryAliasSF2)->F2_DOC+"' AND VSC.VSC_SERNFI = '"+(cQryAliasSF2)->F2_SERIE+"' AND "
	cQuery += "VSC.D_E_L_E_T_ = ' '"
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasVSC, .F., .T. )
     
    nTotSRV := 0 
	While  !(cQryAliasVSC)->(Eof())     
	
	   VO4->(DBGOTO(VAL((cQryAliasVSC)->VSC_RECVO4)))
	   cNumOsv := (cQryAliasVSC)->VSC_NUMOSV
	   dDatVen := VO4->VO4_DATFEC
	   cHorVen := VO4->VO4_HORFEC     
	   nTotSRV += (cQryAliasVSC)->VSC_VALSER
	   nTotOS  += (cQryAliasVSC)->VSC_VALSER  
	   nSRVNF  += (cQryAliasVSC)->VSC_VALSER  
       nSrvDes += (cQryAliasVSC)->VSC_VALDES
       cTipTem := (cQryAliasVSC)->VSC_TIPTEM
	   dbSelectArea("VOD")
	   dbSetOrder(1)    
	   dbSeek(xFilial("VOD")+VO4->VO4_CODSEC)
	   if Alltrim(VOD->VOD_CODSEC) $ c_mv_par21
	      cTipSer := 1
	   Elseif Alltrim(VOD->VOD_CODSEC) $ c_mv_par22
	      cTipSer := 2
	   Endif   
	   aAdd(aVetSRV,{(cQryAliasVSC)->VSC_CODSER,(cQryAliasVSC)->VO6_DESSER,cTipSer,(cQryAliasVSC)->VSC_TEMVEN,(cQryAliasVSC)->VSC_VALSER,(cQryAliasVSC)->VSC_VALDES,(cQryAliasVSC)->VSC_VALSER,(cQryAliasVSC)->D2_ALIQISS,(cQryAliasSF2)->D2_ALQPIS+(cQryAliasSF2)->D2_ALQCOF})
   	   dbSelectArea(cQryAliasVSC)
       (cQryAliasVSC)->(dbSkip())
   	Enddo
	(cQryAliasVSC)->(dbCloseArea())

	nTotSRVO := 0
	nTotPecO := 0
    if !Empty((cQryAliasSF2)->VS1_NUMORC)
        if Empty(cChaint)
	        cChaint := (cQryAliasSF2)->VS1_CHAINT
	    Endif    
		cQuery := "SELECT VS3.VS3_VALPEC "
		cQuery += " FROM " + RetSQLName("VS3") + " VS3 "
		cQuery += " WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' AND VS3.VS3_NUMORC = '"+(cQryAliasSF2)->VS1_NUMORC+"' AND "
		cQuery += "VS3.D_E_L_E_T_ = ' '"
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasVS3, .F., .T. )

		While  !(cQryAliasVS3)->(Eof())     
	
		   nTotPecO += (cQryAliasVS3)->VS3_VALPEC
    	   dbSelectArea(cQryAliasVS3)
	       (cQryAliasVS3)->(dbSkip())
    	Enddo
		(cQryAliasVS3)->(dbCloseArea())

		cQuery := "SELECT VS4.VS4_VALSER "
		cQuery += " FROM " + RetSQLName("VS4") + " VS4 "
		cQuery += " WHERE VS4.VS4_FILIAL = '" + xFilial("VS4") + "' AND VS4.VS4_NUMORC = '"+(cQryAliasSF2)->VS1_NUMORC+"' AND "
		cQuery += "VS4.D_E_L_E_T_ = ' '"
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasVS4, .F., .T. )
    	
		While  !(cQryAliasVS4)->(Eof())     
	
		   nTotSRVO += (cQryAliasVS4)->VS4_VALSER
    	   dbSelectArea(cQryAliasVS4)
	       (cQryAliasVS4)->(dbSkip())
    	Enddo
		(cQryAliasVS4)->(dbCloseArea())
    Endif                                                                    
    dbSelectArea("VV1")
    dbSetOrder(1)
    dbSeek(xFilial("VV1")+cChaint) 
    if VV1->VV1_ESTVEI == "0" 
       cEstVei := "S"
    Else
       cEstVei := "N"
    Endif   
    
    dbSelectArea("SA1")
    dbSetOrder(1)
    dbSeek(xFilial("SA1")+(cQryAliasSF2)->F2_CLIENTE+(cQryAliasSF2)->F2_LOJA)
    cFontPag := ""
    if cTipTem $ c_mv_par05 
       cFontPag := "01"
    Elseif cTipTem $ c_mv_par06
       cFontPag := "02"
    Elseif cTipTem $ c_mv_par07
       cFontPag := "03"
    Elseif cTipTem $ c_mv_par08
       cFontPag := "04"
    Elseif cTipTem $ c_mv_par09
       cFontPag := "05"
    Elseif cTipTem $ c_mv_par10
       cFontPag := "06"
    Elseif cTipTem $ c_mv_par11
       cFontPag := "07"
    Elseif cTipTem $ c_mv_par12
       cFontPag := "08"
    Elseif cTipTem $ c_mv_par13
       cFontPag := "09"
    Elseif cTipTem $ c_mv_par14
       cFontPag := "10"
    Elseif cTipTem $ c_mv_par15
       cFontPag := "11"
    Elseif cTipTem $ c_mv_par16
       cFontPag := "12"                                                     
    Elseif cTipTem $ c_mv_par17
       cFontPag := "13"
    Elseif cTipTem $ c_mv_par18
       cFontPag := "14"
    Elseif cTipTem $ c_mv_par19
       cFontPag := "15"
    Elseif cTipTem $ c_mv_par20
       cFontPag := "16"
    Endif
//    if !Empty((cQryAliasSF2)->(VS1_NUMORC)) .or. !Empty((cQryAliasSF2)->(VO1_NUMOSV))   
        dbSelectArea("VO1")
        dbSetOrder(1)
        dbSeek(xFilial("VO1")+cNumOsv)  
        
		aAdd(aVetAjus,{(cQryAliasSF2)->(VS1_DATORC),(cQryAliasSF2)->(VS1_HORORC),(cQryAliasSF2)->(VS1_NUMORC),cNumOsv,VO1->VO1_DATABE,VO1->VO1_HORABE,dDatVen,cHorVen,nTotOS,(cQryAliasSF2)->(VS1_VTOTNF),nTotPec,nTotSRV,nTotPecO,nTotSRVO,(cQryAliasSF2)->F2_DOC,(cQryAliasSF2)->F2_SERIE,(cQryAliasSF2)->F2_EMISSAO,VO1->VO1_NUMOSV,VO1->VO1_DATABE,cFontPag,(cQryAliasSF2)->F2_VALBRUT,nTotPec,nValDes,nSRVNF,nSrvDes,SA1->A1_NOME,SA1->A1_END,cEstVei,(cQryAliasSF2)->F2_HORA})
//    Endif 
	aAdd(aVetVeic,{VV1->VV1_CHASSI,VV1->VV1_PLAVEI,VO1->VO1_KILOME,SA1->A1_NOME,SA1->A1_PESSOA,SA1->A1_CGC,SA1->A1_END,"",SA1->A1_COMPLEM,SA1->A1_BAIRRO,SA1->A1_MUN,SA1->A1_EST,SA1->A1_CEP,SA1->A1_TEL,"",SA1->A1_EMAIL,SA1->A1_TEL})
	aAdd(aVetCliente,{SA1->A1_PESSOA,SA1->A1_CGC,"",SA1->A1_COMPLEM,SA1->A1_BAIRRO,SA1->A1_MUN,SA1->A1_EST,SA1->A1_CEP,SA1->A1_TEL,SA1->A1_EMAIL,"",SA1->A1_TEL,""})
    
    dbSelectArea(cQryAliasSF2)
	(cQryAliasSF2)->(DBSkip())
Enddo

(cQryAliasSF2)->(dbCloseArea())                                              


cQryAliasSF2 := GetNextAlias()

cQuery := "SELECT SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO,SF2.F2_VALBRUT,SF2.F2_VALFAT,SA1.A1_NOME,SA1.A1_COMPLEM,SA1.A1_PESSOA,SA1.A1_CGC,SA1.A1_END,SA1.A1_BAIRRO,SA1.A1_MUN,SA1.A1_EST,SA1.A1_CEP,SA1.A1_TEL,SA1.A1_EMAIL,SF2.F2_HORA "
cQuery += " FROM " + RetSQLName("SF2") + " SF2 "
cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_EMISSAO >= '"+dtos(c_MV_PAR01)+"' AND SF2.F2_EMISSAO <= '"+dtos(c_MV_PAR02)+"' AND SF2.F2_PREFORI = '"+Alltrim(GetNewPar("MV_PREFBAL","BAL"))+"' AND "
cQuery += "SF2.D_E_L_E_T_ = ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSF2, .F., .T. )

	nTotPec  := 0 
While  !(cQryAliasSF2)->(Eof())

	cQuery := "SELECT SD2.D2_COD,SD2.D2_TOTAL,SD2.D2_VALBRUT,SD2.D2_DESCON,SD2.D2_DESCON,SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_PICM,SD2.D2_ALQCOF,SD2.D2_ALQPIS "
	cQuery += " FROM " + RetSQLName("SD2") + " SD2 "
	cQuery += " LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV = '5' AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_DOC  = '"+(cQryAliasSF2)->F2_DOC+"' AND SD2.D2_SERIE <= '"+(cQryAliasSF2)->F2_SERIE+"' AND "
	cQuery += "SD2.D_E_L_E_T_ = ' '"   
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySD2, .F., .T. )
	
	nTotDesc := 0
    nTotPec  += (cQryAliasSF2)->F2_VALFAT  
	While  !(cQrySD2)->(Eof())

        nTotDesc += (cQrySD2)->D2_DESCON
        
		DBSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1")+(cQrySD2)->D2_COD )
		DBSelectArea("SBM")
		DbSetOrder(1)
		DbSeek( xFilial("SBM")+SB1->B1_GRUPO )
	    if Alltrim(SBM->BM_TIPGRU) == "1"		
	       cCodIte := SB1->B1_CODITE
	    Else
	       cCodIte := "ZZZ"+SB1->B1_CODITE
	    Endif                         
	    nValTot := (cQrySD2)->D2_TOTAL
	    nAPisCof  := (cQrySD2)->D2_ALQPIS+(cQrySD2)->D2_ALQCOF     
	    nPrcUnit := ((cQrySD2)->D2_VALBRUT+(cQrySD2)->D2_DESCON)/ (cQrySD2)->D2_QUANT
	    nPrcTot := (cQrySD2)->D2_VALBRUT+(cQrySD2)->D2_DESCON
		aAdd(aBalPec,{cCodIte,SB1->B1_DESC,(cQrySD2)->D2_QUANT,nPrcUnit,nPrcTot,(cQrySD2)->D2_DESCON,nValTot,(cQrySD2)->D2_PICM,nAPisCof})
    	dbSelectArea(cQrySD2)
    	(cQrySD2)->(dbSkip())
    Enddo
    (cQrySD2)->(dbCloseArea())
                          
	aAdd(aBalcao,{(cQryAliasSF2)->F2_DOC,(cQryAliasSF2)->F2_SERIE,(cQryAliasSF2)->F2_EMISSAO,"",(cQryAliasSF2)->F2_VALFAT,nTotPec,nTotDesc,(cQryAliasSF2)->A1_NOME,(cQryAliasSF2)->A1_PESSOA,(cQryAliasSF2)->A1_CGC,(cQryAliasSF2)->A1_END,"",(cQryAliasSF2)->A1_COMPLEM,(cQryAliasSF2)->A1_BAIRRO,(cQryAliasSF2)->A1_MUN,(cQryAliasSF2)->A1_EST,(cQryAliasSF2)->A1_CEP,(cQryAliasSF2)->A1_TEL,(cQryAliasSF2)->A1_EMAIL,"",(cQryAliasSF2)->A1_TEL,(cQryAliasSF2)->F2_HORA})

   	dbSelectArea(cQryAliasSF2)
   	(cQryAliasSF2)->(dbSkip())
Enddo    
(cQryAliasSF2)->(dbCloseArea())

cQuery := "SELECT DISTINCT SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO,SF3.F3_DTCANC,SF2.F2_PREFORI,VEC.VEC_NUMOSV,VEC.VEC_TIPTEM,VSC.VSC_NUMOSV,VSC.VSC_TIPTEM,SF2.F2_HORA "
cQuery += " FROM " + RetSQLName("SF2") + " SF2 "
cQuery += " INNER JOIN "+RetSqlName("SF3")+" SF3 ON SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND SF3.F3_NFISCAL = SF2.F2_DOC AND SF3.F3_SERIE = SF2.F2_SERIE AND SF3.F3_DTCANC >='"+dtos(c_MV_PAR01)+"' AND SF3.F3_DTCANC <= '"+dtos(c_MV_PAR02)+"' AND SF3.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN "+RetSqlName("VEC")+" VEC ON VEC.VEC_FILIAL = '" + xFilial("VEC") + "' AND VEC.VEC_NUMNFI = SF2.F2_DOC AND VEC.VEC_SERNFI = SF2.F2_SERIE AND VEC.D_E_L_E_T_ <> ' ' "
cQuery += " LEFT JOIN "+RetSqlName("VSC")+" VSC ON VSC.VSC_FILIAL = '" + xFilial("VSC") + "' AND VSC.VSC_NUMNFI = SF2.F2_DOC AND VSC.VSC_SERNFI = SF2.F2_SERIE AND VSC.D_E_L_E_T_ <> ' ' "
cQuery += " WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
cQuery += "SF2.D_E_L_E_T_ <> ' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasSF2, .F., .T. )

cTipCanc := ""
While  !(cQryAliasSF2)->(Eof())
                          
    
    if !Empty((cQryAliasSF2)->VEC_NUMOSV)
       cNumOsv := (cQryAliasSF2)->VEC_NUMOSV 
       cTipTem := (cQryAliasSF2)->VEC_TIPTEM
    Elseif !Empty((cQryAliasSF2)->VSC_NUMOSV)
       cNumOsv := (cQryAliasSF2)->VSC_NUMOSV
       cTipTem := (cQryAliasSF2)->VSC_TIPTEM
    Else   
       cNumOsv := ""
    Endif 
    dbSelectArea("VO1")
    dbSetOrder(1)
    dbSeek(xFilial("VO1")+cNumOsv)
    if VO1->VO1_STATUS == "C"
	    cTipCanc := "OS"
	Endif    
    if Empty(cTipCanc)
       if (cQryAliasSF2)->F2_PREFORI == Alltrim(GetNewPar("MV_PREFBAL","BAL"))
		    cTipCanc := "NB"
	   Else    
		    cTipCanc := "NS"
       Endif
    Endif
    cFontPag := ""
	if cTipCanc == "OS"
	    if cTipTem $ c_mv_par05 
	       cFontPag := "01"
	    Elseif cTipTem $ c_mv_par06
	       cFontPag := "02"
	    Elseif cTipTem $ c_mv_par07
	       cFontPag := "03"
	    Elseif cTipTem $ c_mv_par08
	       cFontPag := "04"
	    Elseif cTipTem $ c_mv_par09
	       cFontPag := "05"
	    Elseif cTipTem $ c_mv_par10
	       cFontPag := "06"
	    Elseif cTipTem $ c_mv_par11
	       cFontPag := "07"
	    Elseif cTipTem $ c_mv_par12
	       cFontPag := "08"
	    Elseif cTipTem $ c_mv_par13
	       cFontPag := "09"
	    Elseif cTipTem $ c_mv_par14
	       cFontPag := "10"
	    Elseif cTipTem $ c_mv_par15
	       cFontPag := "11"
	    Elseif cTipTem $ c_mv_par16
	       cFontPag := "12"
	    Elseif cTipTem $ c_mv_par17
	       cFontPag := "13"
	    Elseif cTipTem $ c_mv_par18
	       cFontPag := "14"
	    Elseif cTipTem $ c_mv_par19
	       cFontPag := "15"
	    Elseif cTipTem $ c_mv_par20
	       cFontPag := "16"
	    Endif
    Endif
	nAno := Year(stod((cQryAliasSF2)->F2_EMISSAO))
	nMes := Month(stod((cQryAliasSF2)->F2_EMISSAO))
	nDia := Day(stod((cQryAliasSF2)->F2_EMISSAO))
	nData = strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)
	cHora := substr((cQryAliasSF2)->F2_HORA,1,2)+substr((cQryAliasSF2)->F2_HORA,4,2)

	if cTipCanc == "NB" .or. cTipCanc == "NS"
	   cNumOsv := 0
       cDatAbe := ctod("  /  /  ")
       cHorAbe := 0
    Else
       cDatAbe := VO1->VO1_DATABE
       cHorAbe := VO1->VO1_HORABE
    Endif   

	nAno := Year(stod((cQryAliasSF2)->F3_DTCANC))
	nMes := Month(stod((cQryAliasSF2)->F3_DTCANC))
	nDia := Day(stod((cQryAliasSF2)->F3_DTCANC))
	nDtCanc := strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)
	   
	aAdd(aCancel,{cTipCanc,Alltrim(strzero(c_MV_PAR04,4)),(cQryAliasSF2)->F2_DOC,(cQryAliasSF2)->F2_SERIE,nData+cHora,cNumOsv,cDatAbe,cHorAbe,cFontPag,nDtCanc})

	cTipCanc := ""
    dbSelectArea(cQryAliasSF2)
    (cQryAliasSF2)->(dbSkip())
Enddo

// CK6011 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
for nni := 1 to Len(aVetAjus)
	//  
	nData := "00000000"  
	nDataOS := "00000000" 
	if !Empty(aVetAjus[nni,1])
		nAno := Year(stod(aVetAjus[nni,1]))
		nMes := Month(stod(aVetAjus[nni,1]))
		nDia := Day(stod(aVetAjus[nni,1]))
		nData = strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)
    Endif
    
	if !Empty(aVetAjus[nni,5])
		nAno := Year(aVetAjus[nni,5])
		nMes := Month(aVetAjus[nni,5])
		nDia := Day(aVetAjus[nni,5])
		nDataOS = strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)
    Endif
	nAno := Year(aVetAjus[nni,7])
	nMes := Month(aVetAjus[nni,7])
	nDia := Day(aVetAjus[nni,7])
	nDataFec = strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)

	aValores := {"CK6",11,;
	998,Alltrim(strzero(c_MV_PAR04,4)),;
    nData+Alltrim(strzero(aVetAjus[nni,2],4)),aVetAjus[nni,3],aVetAjus[nni,4],nDataOS+Alltrim(strzero(aVetAjus[nni,6],4)),nDataFec+Alltrim(strzero(aVetAjus[nni,8],4)),aVetAjus[nni,20],aVetAjus[nni,9],aVetAjus[nni,10],aVetAjus[nni,11],aVetAjus[nni,12],aVetAjus[nni,13],aVetAjus[nni,14],"S","S","",10607}

	cLinha := MontaEDI(aLayCK6011,aValores)
    
	//
	//
	fwrite(nHnd,cLinha)
	//
	nLinhArq++

//	aAdd(aLinhasRel,"CK6"+" "+"011"+Transform(aVetAjus[nni,7],"@D")+" "+aVetAjus[nni,4]+" "+transform(aVetAjus[nni,10],"@E 999,999.99"))

	//

next 

// CK6021 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
nCont := 1
For i:= 1 to Len(aVetPecas)

	if nCont == 1
	   aValPecas := {"CK6",21,;
		998,Alltrim(strzero(c_MV_PAR04,4)),aVetPecas[i,3],aVetPecas[i,4],aVetPecas[i,5],aVetPecas[i,6],aVetPecas[i,7],aVetPecas[i,8],aVetPecas[i,9],aVetPecas[i,10],"","",0,0,0,0,0,0,""}
		nLinhArq += 1
	    nCont := 2	
	Else                                                                
	    aValPecas[13] := aVetPecas[i,3]
	    aValPecas[14] := aVetPecas[i,4]
    	aValPecas[15] := aVetPecas[i,5]
	    aValPecas[16] := aVetPecas[i,6]
    	aValPecas[17] := aVetPecas[i,7]
	    aValPecas[18] := aVetPecas[i,8]
    	aValPecas[19] := aVetPecas[i,9]
	    aValPecas[20] := aVetPecas[i,10]
	    nCont := 1
     	cLinha := MontaEDI(aLayCK6021,aValPecas)
		fwrite(nHnd,cLinha)
//		aAdd(aLinhasRel,"CK6"+" "+"021")
	Endif                                                               
Next       
if nCont == 2
	cLinha := MontaEDI(aLayCK6021,aValPecas)
	fwrite(nHnd,cLinha)
Endif	

//CK6031 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
nCont := 1
For i:= 1 to Len(aVetSRV)

	if nCont == 1
	   aValSRV := {"CK6",31,;
		998,Alltrim(strzero(c_MV_PAR04,4)),;
		aVetSRV[i,1],aVetSRV[i,2],aVetSRV[i,3],aVetSRV[i,4],aVetSRV[i,5],aVetSRV[i,6],aVetSRV[i,7],aVetSRV[i,8],"","",0,0,0,0,0,0,"",10607}
		nLinhArq += 1

	    nCont := 2	
	Else                                                                
	    aValSRV[13] := aVetSRV[i,1]
	    aValSRV[14] := aVetSRV[i,2]
    	aValSRV[15] := aVetSRV[i,3]
	    aValSRV[16] := aVetSRV[i,4]
    	aValSRV[17] := aVetSRV[i,5]
	    aValSRV[18] := aVetSRV[i,6]
    	aValSRV[19] := aVetSRV[i,7]
	    aValSRV[20] := aVetSRV[i,8]
	    nCont := 1
     	cLinha := MontaEDI(aLayCK6031,aValSRV)
		fwrite(nHnd,cLinha)
//		aAdd(aLinhasRel,"CK6"+" "+"031")
	Endif                                                               
Next    
if nCont == 2
	cLinha := MontaEDI(aLayCK6031,aValSRV)
	fwrite(nHnd,cLinha)
Endif	

// CK6041 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
For i:= 1 to Len(aVetVeic)

	nLinhArq += 1
   aValVeic := {"CK6",41,;
	998,Alltrim(strzero(c_MV_PAR04,4)),;
	aVetVeic[i,1],aVetVeic[i,2],aVetVeic[i,3],aVetVeic[i,4],aVetVeic[i,5],aVetVeic[i,6],aVetVeic[i,7],aVetVeic[i,8],aVetVeic[i,9],aVetVeic[i,10],"",10607}

   	cLinha := MontaEDI(aLayCK6041,aValVeic)
	fwrite(nHnd,cLinha)    
//	aAdd(aLinhasRel,"CK6"+" "+"041")

Next    

// CK6042 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
For i:= 1 to Len(aVetVeic)

	nLinhArq += 1
    aValVeic1 := {"CK6",42,;
	998,Alltrim(strzero(c_MV_PAR04,4)),;
	aVetVeic[i,11],aVetVeic[i,12],aVetVeic[i,13],aVetVeic[i,14],aVetVeic[i,15],aVetVeic[i,16],aVetVeic[i,17],"",10607}

   	cLinha := MontaEDI(aLayCK6042,aValVeic1)
	fwrite(nHnd,cLinha)  
//	aAdd(aLinhasRel,"CK6"+" "+"042")

Next    

// CK7001 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
For i:= 1 to Len(aVetAjus)

	nLinhArq += 1
	nAno := Year(stod(aVetAjus[i,17]))
	nMes := Month(stod(aVetAjus[i,17]))
	nDia := Day(stod(aVetAjus[i,17]))
	nData = strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)
	
	cHora := substr(aVetAjus[i,29],1,2)+substr(aVetAjus[i,29],4,2)

	nAno := Year(aVetAjus[i,19])
	nMes := Month(aVetAjus[i,19])
	nDia := Day(aVetAjus[i,19])
	nDataOS = strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)
	
	

    aValNF := {"CK7",1,aVetAjus[i,15],aVetAjus[i,16],nData+cHora,aVetAjus[i,18],nDataOS+strzero(aVetAjus[i,6],4),aVetAjus[i,20],aVetAjus[i,21],aVetAjus[i,22],aVetAjus[i,23],aVetAjus[i,24],aVetAjus[i,25],aVetAjus[i,26],aVetAjus[i,27],aVetAjus[i,28],"",10607}

   	cLinha := MontaEDI(aLayCK7001,aValNF)
	fwrite(nHnd,cLinha)
//	aAdd(aLinhasRel,"CK7"+" "+"001")

Next    

// CK7002 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
For i:= 1 to Len(aVetCliente)

	nLinhArq += 1
    aValCli := {"CK7",2,aVetCliente[i,1],aVetCliente[i,2],aVetCliente[i,3],aVetCliente[i,4],aVetCliente[i,5],aVetCliente[i,6],aVetCliente[i,7],aVetCliente[i,8],aVetCliente[i,9],aVetCliente[i,10],aVetCliente[i,11],aVetCliente[i,12],4,""}

   	cLinha := MontaEDI(aLayCK7002,aValCli)
	fwrite(nHnd,cLinha)
//	aAdd(aLinhasRel,"CK7"+" "+"002")

Next    

// CK7003 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
nCont := 1
For i:= 1 to Len(aVetPecas)

//   aAdd(aVetPecas,{cCodIte,SB1->B1_DESC,(cQryAliasVEC)->VEC_QTDITE,(cQryAliasVEC)->VO3_VALPEC,(cQryAliasVEC)->VEC_VALBRU,(cQryAliasVEC)->VEC_VALDES,(cQryAliasVEC)->VEC_VALVDA,(cQryAliasVEC)->VEC_ALQICM,0})
	if nCont == 1
		nLinhArq += 1
	    aValPec := {"CK7",3,aVetPecas[i,3],aVetPecas[i,4],aVetPecas[i,5],aVetPecas[i,6],aVetPecas[i,7],aVetPecas[i,8],aVetPecas[i,9],aVetPecas[i,10],aVetPecas[i,11],"","",0,0,0,0,0,0,0,""}
	    nCont := 2	
    Else
	    aValPec[12] := aVetPecas[i,3]
	    aValPec[13] := aVetPecas[i,4]
    	aValPec[14] := aVetPecas[i,5]
	    aValPec[15] := aVetPecas[i,6]
    	aValPec[16] := aVetPecas[i,7]
	    aValPec[17] := aVetPecas[i,8]
    	aValPec[18] := aVetPecas[i,9]
	    aValPec[19] := aVetPecas[i,10]
	    aValPec[20] := aVetPecas[i,11]
	    nCont := 1
		cLinha := MontaEDI(aLayCK7003,aValPec)
		fwrite(nHnd,cLinha)
//		aAdd(aLinhasRel,"CK7"+" "+"003")
    Endif

Next    
if nCont == 2
	cLinha := MontaEDI(aLayCK7003,aValPec)
	fwrite(nHnd,cLinha)
Endif

// CK7004 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
nCont := 1
For i:= 1 to Len(aVetSRV)

	if nCont == 1
		nLinhArq += 1
	    aValSRVa := {"CK7",4,aVetSRV[i,1],aVetSRV[i,2],aVetSRV[i,4],aVetSRV[i,5],aVetSRV[i,6],aVetSRV[i,7],aVetSRV[i,8],aVetSRV[i,9],0,0,0,0,0,0,0,0,"",10607}
	    nCont := 2	
    Else
	    aValSRVa[11] := aVetSRV[i,1]
	    aValSRVa[12] := aVetSRV[i,2]
    	aValSRVa[13] := aVetSRV[i,4]
	    aValSRVa[14] := aVetSRV[i,5]
    	aValSRVa[15] := aVetSRV[i,6]
	    aValSRVa[16] := aVetSRV[i,7]
    	aValSRVa[17] := aVetSRV[i,8]
	    aValSRVa[18] := aVetSRV[i,9]
	    nCont := 1
		cLinha := MontaEDI(aLayCK7004,aValSRVa)
		fwrite(nHnd,cLinha)
//		aAdd(aLinhasRel,"CK7"+" "+"004")
    Endif

Next    
if nCont == 2
	cLinha := MontaEDI(aLayCK7003,aValPec)
	fwrite(nHnd,cLinha)
Endif

// CK3001 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
For i:= 1 to Len(aBalcao)
    
	nLinhArq += 1
	nAno := Year(stod(aBalcao[i,3]))
	nMes := Month(stod(aBalcao[i,3]))
	nDia := Day(stod(aBalcao[i,3]))
	nData = strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)  
	cHora := substr(aBalcao[i,22],1,2)+substr(aBalcao[i,22],4,2)


    aValBal := {"CK3",1,Alltrim(strzero(c_MV_PAR04,4)),aBalcao[i,1],aBalcao[i,2],nData+cHora,aBalcao[i,4],aBalcao[i,5],aBalcao[i,6],aBalcao[i,7],aBalcao[i,8],aBalcao[i,9],aBalcao[i,10],aBalcao[i,11],aBalcao[i,12],aBalcao[i,13],"",10607}

   	cLinha := MontaEDI(aLayCK3001,aValBal)
	fwrite(nHnd,cLinha)
//	aAdd(aLinhasRel,"CK3"+" "+"001")

Next    

// CK3002 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
For i:= 1 to Len(aBalcao)

	nLinhArq += 1
    aValCk3Cli := {"CK3",2,aBalcao[i,14],aBalcao[i,15],aBalcao[i,16],aBalcao[i,17],aBalcao[i,18],aBalcao[i,19],aBalcao[i,20],aBalcao[i,21],"",10607}

   	cLinha := MontaEDI(aLayCK3002,aValCk3Cli)
	fwrite(nHnd,cLinha)
//	aAdd(aLinhasRel,"CK3"+" "+"002")

Next    

// CK3003 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
nCont := 1
For i:= 1 to Len(aBalPec)

	if nCont == 1
	    aValCk3Pec := {"CK3",3,aBalPec[i,1],aBalPec[i,2],aBalPec[i,3],aBalPec[i,4],aBalPec[i,5],aBalPec[i,6],aBalPec[i,7],aBalPec[i,8],aBalPec[i,9],"","",0,0,0,0,0,0,0,"",10607}
		nLinhArq += 1
	    nCont := 2	
    Else
	    aValCk3Pec[12] := aBalPec[i,1]
	    aValCk3Pec[13] := aBalPec[i,2]
    	aValCk3Pec[14] := aBalPec[i,3]
	    aValCk3Pec[15] := aBalPec[i,4]
    	aValCk3Pec[16] := aBalPec[i,5]
	    aValCk3Pec[17] := aBalPec[i,6]
    	aValCk3Pec[18] := aBalPec[i,7]
	    aValCk3Pec[19] := aBalPec[i,8]
	    aValCk3Pec[20] := aBalPec[i,9]
	    nCont := 1
	   	cLinha := MontaEDI(aLayCK3003,aValCk3Pec)
		fwrite(nHnd,cLinha)
//		aAdd(aLinhasRel,"CK3"+" "+"003")
     Endif
Next    
if nCont == 2
   	cLinha := MontaEDI(aLayCK3003,aValCk3Pec)
	fwrite(nHnd,cLinha)
Endif


// CK4001 - AUTOSERVICE - ROTINA DE CONSISTÊNCIA
For i:= 1 to Len(aCancel)

	nAno := Year(aCancel[i,7])
	nMes := Month(aCancel[i,7])
	nDia := Day(aCancel[i,7])
	nData = nDia * 1000000 + nMes * 10000 + nAno     
	nDataOS = strzero(nDia,2) + strzero(nMes,2) + strzero(nAno,4)
  
	nLinhArq += 1
    aValCanc := {"CK4",1,aCancel[i,1],aCancel[i,2],aCancel[i,3],aCancel[i,4],aCancel[i,5],aCancel[i,6],nDataOS+Alltrim(strzero(aCancel[i,8],4)),aCancel[i,9],aCancel[i,10],"",10607}

   	cLinha := MontaEDI(aLayCK4001,aValCanc)
	fwrite(nHnd,cLinha)
//	aAdd(aLinhasRel,"CK4"+" "+"001")

Next    

if c_mv_par03 == 2
	// CK5001 - AUTOSERVICE - DADOS COMPLEMENTARES - Envio Mensal
	nAno := Year(mv_par01)
	nMes := Month(mv_par01)
	nDia := Day(mv_par01)
	nData = nDia * 1000000 + nMes * 10000 + nAno                     
	nLinhArq += 1
	aDadosCompl := {"CK5",1,998,Alltrim(strzero(c_MV_PAR04,4)),nData,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09,;
					mv_par10,mv_par11,mv_par12,mv_par13,mv_par14,mv_par15,mv_par16,mv_par17,mv_par18,mv_par19,mv_par20,mv_par21,mv_par22,mv_par23,;
					mv_par24,mv_par25,mv_par26,mv_par27,mv_par28,mv_par29,mv_par30,mv_par31,"",10607}

	cLinha := MontaEDI(aLayCK5001,aDadosCompl)
	fwrite(nHnd,cLinha)
//	aAdd(aLinhasRel,"CK5"+" "+"001")
Endif

// Monta CKF
aValCKF := {}
aAdd(aValCKF,{"CKF",1, 0,nLinhArq+2," " } )
cLinhaCKF := MontaEDI(aLayCKF,aValCKF[1])
fwrite(nHnd,cLinhaCKF)
//


// Monta CHF
aValCHF := {}
aAdd(aValCHF,{"CHF",1, 0,nLinhArq+2," " } )
cLinhaCHF := MontaEDI(aLayCHF,aValCHF[1])
fwrite(nHnd,cLinhaCHF)
//

fClose(nHnd)
//
if !lErro
	MsgInfo(STR0043,STR0042)
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

Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := STR0004 
Local cDesc2  := STR0030 
Local cDesc3  := ""

Private cString  := "VV1" // TODO
Private Tamanho  := "M"
Private aReturn  := { "Zebrado",2,"Administração",2,2,1,"",1 }
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
for nCntFor = 1 to Len(aLinhasRel)
	
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	//
	@ Li++, 1   PSay aLinhasRel[nCntFor]
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay "... ABORTADO PELO OPERADOR."
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
		if valType(aInfo[nCntFor]) == "D"
			ncValor = dtos(aInfo[nCntFor])
		Else
		    if ainfo[1] == "CK5"
				ncValor = Alltrim(strzero(aInfo[nCntFor],nTamanho))
		    Else                                
				ncValor = STRZERO(Round(aInfo[nCntFor] * (10 ^ nDecimal),0),nTamanho)
			Endif	
		Endif	
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


aAdd(aSX1,{cPerg,"01",STR0045,"","","MV_CH1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
aAdd(aSX1,{cPerg,"02",STR0046,"","","MV_CH2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"03",STR0047,"","","MV_CH3","N",1,0,0,"C","","mv_par03",STR0048,"","","","",STR0049,"","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})
aAdd(aSX1,{cPerg,"04",STR0050,"","","MV_CH4","N",4,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","9999"})
aAdd(aSX1,{cPerg,"05",STR0051,"","","MV_CH5","C",99,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"06",STR0052,"","","MV_CH6","C",99,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"07",STR0053,"","","MV_CH7","C",99,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"08",STR0054,"","","MV_CH8","C",99,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"09",STR0055,"","","MV_CHA","C",99,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"10",STR0056,"","","MV_CHB","C",99,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
aAdd(aSX1,{cPerg,"11",STR0057,"","","MV_CHC","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
aAdd(aSX1,{cPerg,"12",STR0058,"","","MV_CHD","C",99,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"13",STR0059,"","","MV_CHE","C",99,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"14",STR0060,"","","MV_CHF","C",99,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"15",STR0061,"","","MV_CHG","C",99,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"16",STR0062,"","","MV_CHH","C",99,0,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"17",STR0063,"","","MV_CHI","C",99,0,0,"G","","mv_par17","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"18",STR0064,"","","MV_CHJ","C",99,0,0,"G","","mv_par18","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"19",STR0065,"","","MV_CHK","C",99,0,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"20",STR0066,"","","MV_CHL","C",99,0,0,"G","","mv_par20","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"21",STR0067,"","","MV_CHM","C",99,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"22",STR0068,"","","MV_CHN","C",99,0,0,"G","","mv_par22","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"23",STR0069,"","","MV_CHO","C",99,0,0,"G","!Vazio().or.(Mv_Par23:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par23","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
aAdd(aSX1,{cPerg,"24",STR0071,"","","MV_CHP","C",3,0,0,"G","","mv_par24","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""	,"S"})


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
			IncProc(STR0070)
		EndIf
	EndIf
Next i

return