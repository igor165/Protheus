#include "Protheus.ch"
#include "OFIXX100.ch"
#include "OFIXDEF.ch"
#include "TOPCONN.ch"

Static lChkLoja   := FindFunction("FMX_CHKLOJA")
Static cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca da Filial
Static lMVMIL0058 := GetNewPar("MV_MIL0058",.f.) // Permite fechamento Agrupado de Tipo de Tempo de Garantia/Revisao
Static lMVMIL0059 := GetNewPar("MV_MIL0059",.f.) // Permite fechamento Agrupado com Tipo de Tempo de Publicos Diferentes em uma nota fiscal
Static lMVMIL0084 := GetNewPar("MV_MIL0084",.f.) // Fecha Pecas e Servicos na Mesma Nota Fiscal
Static lLJPRDSV   := (GetNewPar("MV_LJPRDSV",.f.) .or. lMVMIL0084 )// Indica se a Venda Direta permite peca e servico junto (FATA701)
Static lFEXPGA    := FindFunction("FMX_FEXPGA")
Static lCtrlLote  := GetNewPar("MV_RASTRO","N") == "S"
Static lFGXSC5BLQ := FindFunction("FGX_SC5BLQ")
Static lOFJD15009 := FindFunction("OFNJD15009_GarantiaEspecial") // Verifica็ใo especํfica por Marca (Garantia Especial)

//Static lDebug := .t.

// Posicao da Matriz aVetTTP
#DEFINE ATT_VETSEL      01  // Controle para Marcar o TT para Fechamento
#DEFINE ATT_NUMOSV      02  // OS
#DEFINE ATT_TIPTEM      03  // Tipo de Tempo
#DEFINE ATT_CLIENTE     04  // Faturar Para
#DEFINE ATT_NOME        05  // Nome
#DEFINE ATT_TOTPEC      06  // Total de Pecas
#DEFINE ATT_HORASPAD    07  // Horas Padrao
#DEFINE ATT_HORASTRA    08  // Horas Trabalhada
#DEFINE ATT_TOTSER      09  // Total de Servicos
#DEFINE ATT_LOJA        10  // Loja do Cliente Faturar Para
#DEFINE ATT_CHAINT      11  // Chassi Interno
#DEFINE ATT_FUNABE      12  // Equipe Tecnica - Abertura da OS
#DEFINE ATT_CODVEN      13  // Vendedor
#DEFINE ATT_CHASSI      14  // Chassi do Veiculo
#DEFINE ATT_A1BLOQ      15  // Cliente Bloqueado
#DEFINE ATT_ORCLOJA     16  // Numero do Orcamento no Loja
#DEFINE ATT_NUMNFI      17  // Numero da Nota Fiscal
#DEFINE ATT_SERNFI      18  // Serie da Nota Fiscal
#DEFINE ATT_FECHADO     19  // Indica se o TT ja foi fechado
#DEFINE ATT_LIBVOO      20  // Numero da Liberacao (VOO_LIBVOO)
#DEFINE ATT_CODMAR      21  // Codigo da Marca do Veiculo para Tratamento de Garantia ...
#DEFINE ATT_SITTPO      22  // Publico do Tipo de Tempo

// Posicao da Matriz aAuxVO3 - Requisicao de Pecas do Fechamento ...
#DEFINE AP_NUMOSV       01  // Numero da Ordem de Servico
#DEFINE AP_GRUITE       02  // Grupo do Item
#DEFINE AP_CODITE       03  // Codigo do Item
#DEFINE AP_VALPECREQ    04  // Valor Peca da Requisicao (VO3)
#DEFINE AP_VALPECGET    05  // Valor Peca da GetDados (Dependendo do VOI_VALPEC
#DEFINE AP_TIPTEM       06  // Tipo de Tempo
#DEFINE AP_QTDREQ       07  // Quantidade Requisitada
#DEFINE AP_VALBRU       08  // Valor Bruto
#DEFINE AP_PERCENT      09  // Percentual da requisicao em relacao ao total da Mesma Peca no Fechamento
#DEFINE AP_ITTOTFISC    10  // Total fiscal do Item ja Rateado
#DEFINE AP_DEPINT       11  // Departamento Interno
#DEFINE AP_DEGGAR       12  // Departamento de Garantia
#DEFINE AP_PERDES       13  // Percentual de Desconto
#DEFINE AP_VALDES       14  // Valor do Desconto
#DEFINE AP_ITBASEDUP    15  // Valor Base Duplicata do Item ja Rateado
#DEFINE AP_LIBVOO       16  // Numero da Liberacao (VOO_LIBVOO)
#DEFINE AP_FORMUL       17  // Formula da Peca (VO3_FORMUL)
#DEFINE AP_MOV          18  // Matriz com movimentacoes das pecas
#DEFINE AP_VALCUS       19  // Valor do Custo da Peca
#DEFINE AP_ITFISCAL     20  // Matriz com campos fiscais das pecas rateado
//           [01] -> Pis
//           [02] -> Cofins
//           [03] -> ICMS
//           [04] -> ICMS Solidario
#DEFINE AP_ITTES	     21  // TES da Peca
#DEFINE AP_ACRESC	     22  // Valor do Acrescimo
#DEFINE AP_LOTECT	     23  // Lote
#DEFINE AP_NUMLOT	     24  // Sub-Lote
#DEFINE AP_SEQFEC	     25  // Controle Interno para o Fechamento
#DEFINE AP_RECVO3	     26  // Recno do VO3

// Posicao da Matriz aAuxVO4 - Requisicao de Servicos do Fechamento
#DEFINE AS_NUMOSV                 01  // Numero da Ordem de Servico
#DEFINE AS_TIPSER                 02  // Tipo de Servico
#DEFINE AS_GRUSER                 03  // Grupo de Servico
#DEFINE AS_CODSER                 04  // Codigo do Servico
#DEFINE AS_VALBRU                 05  // Valor Bruto
#DEFINE AS_TIPTEM                 06  // Tipo de Tempo
#DEFINE AS_PERDES                 07  // Percentual de Desconto
#DEFINE AS_VALDES                 08  // Valor do Desconto
#DEFINE AS_INCMOB                 09  // Tipo de Cobranca
#DEFINE AS_TEMPAD                 10  // Tempo Padrao
#DEFINE AS_TEMTRA                 11  // Tempo Trabalhado
#DEFINE AS_TEMCOB                 12  // Tempo de Cobranca
#DEFINE AS_TEMVEN                 13  // Tempo Vendido
#DEFINE AS_SERINT                 14  // Codigo Interno do Servico
#DEFINE AS_SECAO                  15  // Secao
#DEFINE AS_KILROD                 16  // Km rodada
#DEFINE AS_APONTA                 17  // Matriz de Apontamentos do Servico
#DEFINE AS_APONTA_CODPRO  /*17,*/ 01  // Codigo do Produtivo
#DEFINE AS_APONTA_DATINI  /*17,*/ 02  // Data Inicial
#DEFINE AS_APONTA_HORINI  /*17,*/ 03  // Hora Inicial
#DEFINE AS_APONTA_DATFIN  /*17,*/ 04  // Data Final
#DEFINE AS_APONTA_HORFIN  /*17,*/ 05  // Hora Final
#DEFINE AS_APONTA_TEMTRA  /*17,*/ 06  // Tempo Trabalhado
#DEFINE AS_APONTA_SEQUEN  /*17,*/ 07  // Sequencia (VO4_SEQUEN)
#DEFINE AS_APONTA_RECNO   /*17,*/ 08  // Recno da VO4
#DEFINE AS_APONTA_PERCEN  /*17,*/ 09  // Percentual do Apontamento em Relacao ao Total de Apontamentos do Servico
#DEFINE AS_PERCVLB                18  // Percentual do Servico em relacao ao Total do Mesmo Servico (VALOR BRUTO)
#DEFINE AS_PERCVLL                19  // Percentual do Servico em relacao ao Total do Mesmo Servico (VALOR LIQUIDO)
#DEFINE AS_ITTOTFISC              20  // Total fiscal do Item ja Rateado
#DEFINE AS_ITBASEDUP              21  // Valor Base Duplicata do Item ja Rateado
#DEFINE AS_LIBVOO                 22  // Numero da Liberacao (VOO_LIBVOO)
#DEFINE AS_INCTEM                 23  // Tempo Para Cobranca
#DEFINE AS_SEQINC                 24  // Inconveniente
#DEFINE AS_CENCUS                 25  // Centro de Custo
#DEFINE AS_CONTA                  26  // Conta
#DEFINE AS_ITEMCT                 27  // Item Conta
#DEFINE AS_CLVL                   28  // Classe Valor

// Posicao da Matriz aTipTem - Utilizada no processamento do fechamento
#DEFINE FTT_TIPTEM   01 // 01 - Tipo de Tempo
#DEFINE FTT_CLIENTE  02 // 02 - Codigo do Cliente
#DEFINE FTT_LOJA     03 // 03 - Loja do Cliente
#DEFINE FTT_QTDE     04 // 04 - Qtde de TT Selecionado
#DEFINE FTT_SERNFI   05 // 05 - Serie da NF Gerada
#DEFINE FTT_NUMNFI   06 // 06 - Numero da NF Gerada
#DEFINE FTT_CODVEN   07 // 07 - Codigo do Vendedor
#DEFINE FTT_TIPFEC   08 // 08 - Indica o Tipo de Fechamento ( "P" = Pecas / "S" = Servicos ), Pecas sempre sobrepoe Servicos ...
#DEFINE FTT_VS9WHERE 09 // 09 - Condicao para selecao dos registros do VS9 para condicao negociada
#DEFINE FTT_NFSRVC   10 // 10 - Quando for faturamento de Servico, indica se vai ser gerado NF
#DEFINE FTT_CODBCO   11 // 11 - Banco selecionado na condicao de pagamento
#DEFINE FTT_ORCLOJA  12 // 12 - Numero do Orcamento no SIGALOJA
#DEFINE FTT_NUMOSV   13 // 13 - Numero da OS (utilizado somente para integracao com LOJA )
#DEFINE FTT_PEDFAT   14 // 14 - Numero do Pedido de Venda Gerado

// Posicao da Matriz aAuxProb
#DEFINE APROB_NUMOSV        01 // 01 - Numero da Ordem de Servico
#DEFINE APROB_LISTA_PECA    02 // 02 - Lista de Pecas Processadas
#DEFINE APROB_LISTA_SRVC    03 // 03 - Lista de Servicos Processados
#DEFINE APROB_NUM_LIB_PECA  04 // 04 - Numero da Liberacao de Pecas (VS6)
#DEFINE APROB_NUM_LIB_SRVC  05 // 05 - Numero da Liberacao de Servicos (VS6)
#DEFINE APROB_PROBLEMA_PECA 06 // 06 - Indica se tem problema de Pecas
#DEFINE APROB_PROBLEMA_SRVC 07 // 07 - Indica se tem problema de Servi็os
#DEFINE APROB_TIPTEM        08 // 08 - Tipo de tempo
#DEFINE APROB_LIBVOO        09 // 09 - Liberacao VOO
#DEFINE APROB_TEM_PECA      10 // 10 - Indica se tem pecas para este tipo de tempo
#DEFINE APROB_TEM_SRVC      11 // 11 - Indica se tem servicos para este tipo de tempo

/*/{Protheus.doc} mil_ver()
Versao do fonte modelo novo

@author Andre Luis Almeida
@since  20/10/2017
/*/
Static Function mil_ver()
If .F.
	mil_ver()
EndIf
Return "007586_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIXX100 บAutor  ณ Takahashi          บ Data ณ  11/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fechamento de OS                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIXX100(nOpc)

Private lFECOFI      := VAI->(FieldPos("VAI_FECOFI")) > 0
Private lFORMUL      := VZ1->(FieldPos("VZ1_FORMUL")) > 0
Private lVOOCFNF     := VOO->(FieldPos("VOO_CFNF")) > 0
Private lVOOOBSMNF   := VOO->(FieldPos("VOO_OBSMNF")) > 0
Private lVOOOBSMNS   := VOO->(FieldPos("VOO_OBSMNS")) > 0
Private lAliqISS     := ( SC6->(FieldPos("C6_ALIQISS")) <> 0 .AND. VOO->(FieLdPos("VOO_ALIISS") <> 0) )
Private nVerParFat   := 1
Private cCondGar     := ""
Private cUsaAcres    := GETNEWPAR('MV_MIL0036', 'N')
Private nOrdListPeca := 1

Private aLockVOO := {}
Private aSemafVOO := {}

Private aTempoProc := {}

AjustaHelp()

SX1->(dbSetOrder(1))
If SX1->(dbSeek("OXA100"))
	Pergunte("OXA100",.f.,,,,.f.)
	nVerParFat   := MV_PAR01
	cCondGar     := MV_PAR02
	nOrdListPeca := IIf( SX1->(dbSeek("OXA100    03")) , MV_PAR03 , 1 )
EndIf

//#############################################################################
//# Chama a tela contendo os dados do orcamento                               #
//#############################################################################
DBSelectArea("VO1")
dbClearFilter()
lRet := OX100EXEC(alias(),Recno(),nOpc,VO1->VO1_NUMOSV)
//
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ OX100EXEC บAutor  ณ Takahashi          บ Data ณ  11/10/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Fechamento de OS                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cPNumOsv = Numero da OS a ser Fechada                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100EXEC(cAlias,nReg,nOpc,cPNumOsv)

Local aObjects      := {} // Objetos Principal da Tela
Local aObjSup       := {}
Local aObjFilTT     := {}
Local aObjGetDados  := {}
Local aObjOutInf    := {}
Local aObjTotal     := {}
Local aObjOIEnc     := {}
Local aObjOICR      := {}
Local aObjOICRInt   := {}
Local aObjOICRI2    := {}

Local aPOPri        := {} // Divisao Principal da Tela
Local aPOSup        := {}
Local aPOFilTT      := {}
Local aPOGetDados   := {}
Local aPOTotal      := {}
Local aPOOutInf     := {}
Local aPOOIEnc      := {}
Local aPOOICR       := {}
Local aPOOICRInt    := {}
Local aPOOICRI2     := {}

Local aSizeAut      := MsAdvSize(.t.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da Enchoice ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nModelo       := 3
Local cTudoOk       := ".T."
Local lF3           := .F.
Local lMemoria      := .T.
Local lColumn       := .F.
Local cATela        := ""
Local lNoFolder     := .T.
Local lProperty     := .F.
//

Local nCntFor

Local lMarca := .t.

Local lVOOTRANSP := VOO->(FieldPos("VOO_TRANSP")) > 0

Default cPNumOsv  := ""

Private oTik      := LoadBitmap( GetResources(), "LBTIK" )
Private oNo       := LoadBitmap( GetResources(), "LBNO" )
Private oVerm     := LoadBitmap( GetResources(), "BR_VERMELHO" ) // Nao Selecionado

Private aVetTTP   := {}               // Contem os TT da OS
Private lCanSel   := .t.              // Indica se pode filtrar e selecionar OS para Fechamento

Private aAuxTiPTem := {}              // Tipo de tempo selecionados para fechamento ...

Private lGarPeca  := .t.              // Controla se ้ fechamento de Garantia de Peca

Private aResFisc  := {}               // Resumo com Inf. Fiscais
Private N := 1                        // Variavel necessaria ao MAFISREF
Private bRefresh  := { || .t. }       // Variavel necessaria ao MAFISREF
Private aHeader   := {}, aCols := {}  // Variavel necessaria ao MAFISREF

Private aAuxVO3   := {}               // Contem Todos os Registros do VO3 Selecionados para Fechamento ...
Private aAuxVO4   := {}               // Contem Todos os Registros do VO4 Selecionados para Fechamento ...

Private aAuxVO4Resumo := {}           // Grava informa็๕es da GetDados de Resumo de Servico  ...

Private aNPecaFis := {}               // Controle do Fiscal para aCols de Pecas
Private aNSrvcFis := {}               // Controle do Fiscal para aCols de Servicos
Private nTotFis   := 0                // Numero total de itens do Fiscal (pecas + servicos)

Private aIteParc

Private lCliPeriod := .f.             // Cliente ้ Periodico ?
Private cFechCli   := ""                // Faturar para (Cliente) selecionado para Fechamento
Private cFechLoj   := ""                // Faturar para (Loja   ) selecionado para Fechamento

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis para Criacao/Controle das Enchoices ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cVOOnMostra := "" // Campos a nao serem exibidos
Private aCpoVOO     := {}   // Array de campos da Enchoice VOO
Private oEnchVOO      // Enchoice VOO
Private cVOOnAltera := "" // Campos da VOO que nใo podem sofrer alteracao no momento de SALVAR A NEGOCIACAO

Private oDlgFech      // Dialog Principal

Private nFolderP    := 1   // Numero da Folder de Pecas
Private nFolderS    := 2   // Numero da Folder de Servicos
Private nFolderO    := 3   // Numero da Folder de Outras Informacoes

Private nTotPeca    := 0   // Total Liquido de Pecas
Private nTotDPeca   := 0   // Total Liquido de Desconto de Pecas
Private nTotSrvc    := 0   // Total Liquido de Servicos
Private nTotDSrvc   := 0   // Total Liquido de Desconto de Servicos
Private nTotOS      := 0   // Total Liquido da OS
Private nTotnFiscal := 0   // Total da Nota Fiscal
Private nAcresFin   := 0   // Acrescimo Financeiro
Private nTotFinanc  := 0   // Total Financeiro

Private cVO3RMostra := ""
Private cVO3RnEdit  := ""
Private cVO3DMostra := ""
Private cVO3DnEdit  := ""
Private lVO3Pec     := ExistBlock("OX100PEC")
Private aVO3CPec    := {}

Private cVO4RMostra := ""
Private cVO4RnEdit  := ""
Private cVO4DMostra := ""
Private cVO4DnEdit  := ""
Private lVO4Ser     := ExistBlock("OX100SER")
Private aVO4CSer    := {}

Private cVS9nMostra := ""
Private cVS9nEdit

Private aHVS9     := {}
Private aCVS9     := {}
Private aHVS9AAlt := {}

Private lFormaID := VS9->(FieldPos("VS9_FORMID")) > 0 .and. GetNewPar("MV_TEFMULT","F") == .t.

Private aHVO3Res  := {} // aHeader VO3 - Resumo
Private aHVO3RAlt := {} // aHeader VO3 - Resumo
Private aCVO3Res  := {} // aCols VO3   - Resumo
Private aHVO3Det  := {} // aHeader VO3 - Detalhado
Private aHVO3DAlt := {} // aHeader VO3 - Resumo
Private aCVO3Det  := {} // aCols VO3   - Detalhado

Private aHVO4Res  := {} // aHeader VO4 - Resumo
Private aHVO4RAlt := {} // aHeader VO4 - Resumo
Private aCVO4Res  := {} // aCols VO4   - Resumo
Private aHVO4Det  := {} // aHeader VO4 - Detalhado
Private aHVO4AAlt := {} // aHeader VO4 - Detalhado
Private aCVO4Det  := {} // aCols VO4   - Detalhado

// Variaveis de Outras informacoes - Contas a Receber
Private dCRDataIni  := CtoD("00/00/00")   // Data inicial para Financiamento
Private nCRDias     := 0                    // Dias para Financiamento
Private nCRParc     := 0                    // Parcelas para Financiamento
Private nCRInter    := 0                    // Intervalo para Financiamento
Private nCRTotal    := 0                    // Total Financeiro (Pode ser Diferente do Total Fiscal, dependedo da TES)
Private nCRSaldo    := 0                    // Saldo a ser distribuido
Private lSE4TipoA   := .f.

Private aVOOSC5 := {}

/* Posi็๕es do array aVOO_DEPARA
[1] Campo na tabela VOO
[2] Tabela referenciada
[3] Campo referenciado
[4] Em qual situa็ใo serแ gravado (S-Servi็o; P-Pe็as; T-Todos )
*/
Private aVOO_DEPARA := {;
{ "VOO_ESTPRE","SC5","C5_ESTPRES","S"} ,;
{ "VOO_MUNPRE","SC5","C5_MUNPRES","S"} ,;
{ "VOO_NFSUBS","SC5","C5_NFSUBST","S"} ,;
{ "VOO_SERSUB","SC5","C5_SERSUBS","S"} ,;
{ "VOO_FRETE ","SC5","C5_FRETE"  ,"P"} ,;
{ "VOO_DESACE","SC5","C5_DESPESA","P"} ,;
{ "VOO_SEGURO","SC5","C5_SEGURO" ,"P"} ,;
{ "VOO_TPFRET","SC5","C5_TPFRETE","P"} ,;
{ "VOO_ENDPRE","SC5","C5_ENDPRES","S"} ,;
{ "VOO_NUMPRE","SC5","C5_NUMPRES","S"} ,;
{ "VOO_COMPPR","SC5","C5_COMPPRE","S"} ,;
{ "VOO_BAIPRE","SC5","C5_BAIPRES","S"} ,;
{ "VOO_CEPPRE","SC5","C5_CEPPRES","S"} ,;
{ "VOO_FORNIS","SC5","C5_FORNISS","S"} }

If SC5->(FieldPos("C5_NTEMPEN")) > 0 .And. VOO->(FieldPos("VOO_NTEMPE")) > 0
	aAdd(aVOO_DEPARA, { "VOO_NTEMPE","SC5","C5_NTEMPEN","T"}) // Nt Empenho
EndIf

If SC5->(FieldPos("C5_CODA1U")) > 0 .And. VOO->(FieldPos("VOO_CODA1U")) > 0
	aAdd(aVOO_DEPARA, { "VOO_CODA1U","SC5","C5_CODA1U","T"})
EndIf


// Variaveis dos Filtros para Consultar OS
Private cFilNumOsv  := Space(TamSX3("VO1_NUMOSV")[1])
Private cFilClie    := Space(TamSX3("A1_COD")[1])
Private cFilLoja    := Space(TamSX3("A1_LOJA")[1])
Private cFilChassi  := Space(TamSX3("VV1_CHASSI")[1])
Private cFilTTP     := Space(TamSX3("VOI_TIPTEM")[1])
Private aPecSom     := {} // Array para analise de margem/desconto agrupado por peca (independente a requisicao) para criacao do VS7
//

Private aBoqPec := {} // Matriz com Funcionarios que receberao comissao sobre as pecas ...

Private nQtdINF  := GetNewPar("MV_NUMITEN",9999999) // Numero maximo de Itens por NF

Private lVS7LOTECT := VS7->(FieldPos("VS7_LOTECT")) > 0

M->C5_ESTPRES := ""

// Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If !AMIIn(14)
	Return
EndIf

VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI")+__cUserID))
If lFECOFI .and. !VAI->VAI_FECOFI $ "123"
	Help(" ",1,"OX100SEMPER")
	Return .f.
EndIf

If !FM_SQL("SELECT VO1_STATUS FROM " + RetSQLName("VO1") + " WHERE VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1_NUMOSV = '" + cPNumOsv + "' AND D_E_L_E_T_ = ' '") $ "F,C"
	cFilNumOsv := cPNumOsv
EndIf

// Monta Variaveis para a GetDados de Pecas
// TT
cVO3RMostra := "VO3_TIPTEM/VO3_GRUITE/VO3_DESGRU/VO3_VALBRU/VO3_PERDES/VO3_VALDES/VO3_VALTOT"
cVO3RnEdit  := "VO3_TIPTEM/VO3_GRUITE/VO3_DESGRU/VO3_VALBRU"

// Itens/Pe็as
cVO3DMostra := "VO3_TIPTEM/VO3_GRUITE/VO3_CODITE/VO3_DESITE/VO3_QTDREQ/VO3_VALPEC/VO3_OPER/VO3_CODTES/VO3_VALBRU/VO3_PERDES/VO3_VALDES/VO3_VALTOT/VO3_PEDXML/VO3_ITEXML/VO3_MARLUC"
cVO3DMostra += "/VO3_CENCUS/VO3_CONTA/VO3_ITEMCT/VO3_CLVL  /" + IIf( lCtrlLote , "VO3_LOTECT/VO3_NUMLOT/" , "")
cVO3DnEdit  := "VO3_TIPTEM/VO3_GRUITE/VO3_DESGRU/VO3_CODITE/VO3_DESITE/VO3_QTDREQ/VO3_VALPEC/VO3_VALBRU/VO3_MARLUC/VO3_LOTECT/VO3_NUMLOT"

If cUsaAcres == 'S' // Se trabalha com acr้scimo
	//	cVO3RnEdit  += "/VO3_PERDES/VO3_VALDES/VO3_ACRESC" // nao e permitido alterar os descontos e acresc. no grid de TT
	cVO3RnEdit  += "/VO3_ACRESC" // adiciona campo acrescimo do grid de TT
	cVO3RMostra += "/VO3_ACRESC" // adiciona campo acrescimo do grid de TT
	cVO3DMostra += "/VO3_ACRESC" // adiciona campo acrescimo do grid de TT
EndIf

// Ponto de entrada para:
// 0 - Cria็ใo    (X)
// 1 - Ret. Dados ( )
// de campos customizแveis da gridbox de Pe็as
If lVO3Pec
	aVO3CPec := ExecBlock("OX100PEC", .f., .f., {"0", "", ""})

	If !Empty(aVO3CPec)
		For nCntFor := 1 To Len(aVO3CPec[nCntFor])
			cVO3DMostra += "/" + aVO3CPec[1, nCntFor]
		Next
	EndIf
EndIf

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VO3")
While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "VO3")
	
	&("M->"+AllTrim(SX3->X3_CAMPO)) := CriaVar(SX3->X3_CAMPO,.f.)
	
	If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL
		
		// aHeader da GetDados de Pecas - RESUMO
		If (AllTrim(SX3->X3_CAMPO) $ cVO3RMostra)
			Aadd(aHVO3Res, {AllTrim(X3Titulo()), SX3->X3_CAMPO,   SX3->X3_PICTURE,  SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,     SX3->X3_VALID,   SX3->X3_USADO,    SX3->X3_TIPO,;
			SX3->X3_F3,      SX3->X3_CONTEXT, X3CBOX(),       SX3->X3_RELACAO })
			
			IF SX3->X3_VISUAL <> "V" .and. !(AllTrim(SX3->X3_CAMPO) $ cVO3RnEdit)
				Aadd(aHVO3RAlt,SX3->X3_CAMPO)
			ENDIF
		Endif
		
		// aHeader da GetDados de Pecas - Detalhado
		If (AllTrim(SX3->X3_CAMPO) $ cVO3DMostra)
			Aadd(aHVO3Det, {AllTrim(X3Titulo()), SX3->X3_CAMPO,   SX3->X3_PICTURE,  SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,     SX3->X3_VALID,   SX3->X3_USADO,    SX3->X3_TIPO,;
			SX3->X3_F3,      SX3->X3_CONTEXT, X3CBOX(),       SX3->X3_RELACAO })
			
			IF SX3->X3_VISUAL <> "V" .and. !(AllTrim(SX3->X3_CAMPO) $ cVO3DnEdit)
				Aadd(aHVO3DAlt,SX3->X3_CAMPO)
			ENDIF
		Endif
	Endif
	SX3->(dbSkip())
End
SX3->(dbSetOrder(2))
SX3->(dbSeek("VO3_CODITE"))
Aadd(aHVO3Det, {"Seq. Int", "SEQFEC",  "999",  3,;
0,     "",   SX3->X3_USADO,    "N",;
"",      SX3->X3_CONTEXT, "", "" })


// Cria uma matriz com uma linha em branco para Inicializar aCols Posteriormente
aCVO3Res := { Array(Len(aHVO3Res)+1) }
aCVO3Res[1,Len(aHVO3Res)+1] := .f.
For nCntFor := 1 to Len(aHVO3Res)
	aCVO3Res[1,nCntFor] := CriaVar(aHVO3Res[nCntFor,2],.f.)
Next nCntFor
aCVO3Det := { Array(Len(aHVO3Det)+1) }
aCVO3Det[1,Len(aHVO3Det)+1] := .f.
For nCntFor := 1 to Len(aHVO3Det)-1
	aCVO3Det[1,nCntFor] := CriaVar(aHVO3Det[nCntFor,2],.f.)
Next nCntFor
aCVO3Det[1,Len(aHVO3Det)] := 0

// Monta Variaveis para a GetDados de Servicos
cVO4RMostra := "VO4_TIPTEM/VO4_TIPSER/VO4_DESTPS/VO4_TEMPAD/VO4_TEMTRA/VO4_OPER/VO4_CODTES/VO4_VALBRU/VO4_PERDES/VO4_VALDES/VO4_VALTOT"
cVO4RMostra += "/VO4_PEDXML/VO4_ITEXML/VO4_CENCUS/VO4_CONTA/VO4_ITEMCT/VO4_CLVL"
cVO4RnEdit  := "VO4_TIPTEM/VO4_TIPSER/VO4_DESTPS/VO4_TEMPAD/VO4_TEMTRA"
cVO4DMostra := "VO4_TIPTEM/VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_TIPSER/VO4_DESTPS/VO4_KILROD/VO4_VALBRU/VO4_PERDES/VO4_VALDES/VO4_VALTOT/VO4_TEMPAD/VO4_TEMTRA/VO4_TEMCOB/VO4_TEMVEN"
cVO4DnEdit  := "VO4_TIPTEM/VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_TIPSER/VO4_DESTPS/VO4_TEMPAD/VO4_TEMTRA/VO4_TEMCOB/VO4_TEMVEN/VO4_PREKIL/VO4_KILROD/VO4_VALSER"

// Ponto de entrada para:
// 0 - Cria็ใo    (X)
// 1 - Ret. Dados ( )
// de campos customizแveis da gridbox de Servi็os
If lVO4Ser
	aVO4CSer := ExecBlock("OX100SER", .f., .f., {"0", ""})

	If !Empty(aVO4CSer)
		For nCntFor := 1 To Len(aVO4CSer[nCntFor])
			cVO4DMostra += "/" + aVO4CSer[1, nCntFor]
		Next
	EndIf
EndIf

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VO4")

While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "VO4")
	
	&("M->"+AllTrim(SX3->X3_CAMPO)) := CriaVar(SX3->X3_CAMPO,.f.)
	
	If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL
		
		// aHeader da GetDados de Servicos - RESUMO
		If (AllTrim(SX3->X3_CAMPO) $ cVO4RMostra)
			Aadd(aHVO4Res, {AllTrim(X3Titulo()), SX3->X3_CAMPO,   SX3->X3_PICTURE,  SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,     SX3->X3_VALID,   SX3->X3_USADO,    SX3->X3_TIPO,;
			SX3->X3_F3,      SX3->X3_CONTEXT, X3CBOX(),       SX3->X3_RELACAO })
			
			IF SX3->X3_VISUAL <> "V" .and. !(AllTrim(SX3->X3_CAMPO) $ cVO4RnEdit)
				Aadd(aHVO4RAlt,SX3->X3_CAMPO)
			ENDIF
		Endif
		
		// aHeader da GetDados de Servicos - Detalhado
		If (AllTrim(SX3->X3_CAMPO) $ cVO4DMostra)
			Aadd(aHVO4Det, {AllTrim(X3Titulo()), SX3->X3_CAMPO,   SX3->X3_PICTURE,  SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,     SX3->X3_VALID,   SX3->X3_USADO,    SX3->X3_TIPO,;
			SX3->X3_F3,      SX3->X3_CONTEXT, X3CBOX(),       SX3->X3_RELACAO })
			
			IF SX3->X3_VISUAL <> "V" .and. !(AllTrim(SX3->X3_CAMPO) $ cVO4DnEdit)
				Aadd(aHVO4AAlt,SX3->X3_CAMPO)
			ENDIF
		Endif
	Endif
	SX3->(dbSkip())
End
// Cria uma matriz com uma linha em branco para Inicializar aCols Posteriormente
aCVO4Res := { Array(Len(aHVO4Res)+1) }
aCVO4Res[1,Len(aHVO4Res)+1] := .f.
For nCntFor := 1 to Len(aHVO4Res)
	aCVO4Res[1,nCntFor] := CriaVar(aHVO4Res[nCntFor,2],.f.)
Next nCntFor
aCVO4Det := { Array(Len(aHVO4Det)+1) }
aCVO4Det[1,Len(aHVO4Det)+1] := .f.
For nCntFor := 1 to Len(aHVO4Det)
	aCVO4Det[1,nCntFor] := CriaVar(aHVO4Det[nCntFor,2],.f.)
Next nCntFor


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta matriz utilizada para fazer o Resumo Fiscal ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aResFisc,{'MaFisRet(,"NF_VALICM")'   , STR0106 , 0 }) // "ICMS Calculado"
aAdd(aResFisc,{'MaFisRet(,"NF_VALSOL")'   , STR0113 , 0 }) // "ICMS ST"
aAdd(aResFisc,{'MaFisRet(,"NF_VALISS")'   , STR0111 , 0 }) // "ISS"
aAdd(aResFisc,{'MaFisRet(,"NF_VALCMP")'   , RetTitle("VEC_VALCMP") , 0 }) //
aAdd(aResFisc,{'OXX100FIS("IT_DIFAL")'    , RetTitle("VEC_DIFAL") , 0 }) //
aAdd(aResFisc,{'MaFisRet(,"NF_DESCONTO")' , STR0107 , 0 }) // "Desconto"
aAdd(aResFisc,{'MaFisRet(,"NF_SEGURO")'   , STR0108 , 0 }) // "Seguro"
aAdd(aResFisc,{'MaFisRet(,"NF_DESPESA")'  , STR0109 , 0 }) // "Despesa"
aAdd(aResFisc,{'MaFisRet(,"NF_FRETE")'    , STR0110 , 0 }) // "Frete"
aAdd(aResFisc,{'MaFisRet(,"NF_VALIPI")'   , RetTitle("VEC_VALIPI"), 0}) // Valor do IPI
aAdd(aResFisc,{'MaFisRet(,"NF_VALIRR")'   , RetTitle("D2_VALIRRF"), 0}) // Valor IRRF
aAdd(aResFisc,{'MaFisRet(,"NF_VALCSL")'   , RetTitle("D2_VALCSL") , 0}) // Valor CSLL
aAdd(aResFisc,{'MaFisRet(,"NF_VALPIS")'   , RetTitle("D2_VALPIS"), 0}) // Valor PIS
aAdd(aResFisc,{'MaFisRet(,"NF_VALCOF")'   , RetTitle("D2_VALCOF") , 0}) // Valor COFINS
//
// PONTO DE ENTRADA PARA ALTERACAO DO VETOR aResFisc
If ExistBlock("OX100MF1")
	ExecBlock("OX100MF1",.f.,.f.)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria Variaveis de Memoria para a VOO ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VOO")
//
cVOOnMostra := "VOO_FILIAL,VOO_NUMOSV,VOO_TIPTEM,VOO_FATPAR,VOO_LOJA,VOO_NOMCLI,VOO_TOTPEC,VOO_HRSPAD,"
cVOOnMostra += "VOO_HRSAPL,VOO_TOTSRV,VOO_SERNFI,VOO_NUMNFI,VOO_CONTCD,VOO_OK,VOO_PESQLJ,VOO_OBSMNF,VOO_LIBVOO,VOO_OBSMNS"
//
While !SX3->(Eof()) .and. (SX3->X3_ARQUIVO=="VOO")
	If X3USO(SX3->X3_USADO) .and. cNivel>=SX3->X3_NIVEL .and. !(Alltrim(SX3->X3_CAMPO) $ cVOOnMostra) .and. OX100CPVOO(SX3->X3_CAMPO)
		AADD(aCpoVOO,SX3->X3_CAMPO)
	EndIf
	&("M->"+AllTrim(SX3->X3_CAMPO)) := CriaVar(AllTrim(SX3->X3_CAMPO))
	SX3->(DbSkip())
Enddo
//

// PE deve retornar os nomes dos campos que nใo serใo alterados no momento que a negociacao ้ salva ...
If ExistBlock("OX100NVO")
	cVOOnAltera := AllTrim(ExecBlock("OX100NVO",.F.,.F.,))
EndIf
cVOOnAltera += "/" + cVOOnMostra + "/VOO_OBSENF/VOO_OBSENS"
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Variaveis para a GetDados de Contas a Receber ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cVS9nMostra := "VS9_FILIAL,VS9_NUMIDE,VS9_TIPOPE,VS9_OBSERV,VS9_OBSMEM,VS9_SEQUEN,VS9_DATBAI,VS9_TIPFEC,VS9_TIPTIT,VS9_SEQPRO,VS9_TIPTEM,VS9_SEQTAR,VS9_PARCEL,VS9_CARTEI,VS9_LIBVOO"
cVS9nMostra += ",VS9_NATURE,VS9_CARTEI,VS9_NATSRV,VS9_PORTAD,VS9_DESPOR"

If !lFormaID
	cVS9nMostra += ",VS9_FORMID"
EndIf

cVS9nEdit := "VS9_ENTRAD,"

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS9")

While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "VS9")
	
	&("M->"+AllTrim(SX3->X3_CAMPO)) := CriaVar(SX3->X3_CAMPO,.f.)
	
	If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL .and. !(AllTrim(SX3->X3_CAMPO) $ cVS9nMostra)
		
		Aadd(aHVS9, {AllTrim(X3Titulo()), SX3->X3_CAMPO,    SX3->X3_PICTURE,  SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,     SX3->X3_VALID,   SX3->X3_USADO,    SX3->X3_TIPO,;
		SX3->X3_F3,      SX3->X3_CONTEXT, X3CBOX(),       SX3->X3_RELACAO })
		
		IF SX3->X3_VISUAL <> "V" .and. !(AllTrim(SX3->X3_CAMPO) $ cVS9nEdit)
			Aadd(aHVS9AAlt,SX3->X3_CAMPO)
		ENDIF
	Endif
	
	SX3->(dbSkip())
End
aCVS9 := { Array(Len(aHVS9)+1) }
aCVS9[1,Len(aHVS9)+1] := .f.
For nCntFor := 1 to Len(aHVS9)
	aCVS9[1,nCntFor] := CriaVar(aHVS9[nCntFor,2],.f.)
Next nCntFor


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Zera qualquer montagem previa do fiscal ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MaFisEnd()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Dialog Principal ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oDlgFech := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,128,,,,,.t.)
oDlgFech:lEscClose := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta Variaveis para Configuracao da Janela Principalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// 1 - Largura em pontos
// 2 - Altura em pontos
// 3 - Uso da largura: .T. = ocupa todo o espaco disponivel; .F. = respeita o parametro 1
// 4 - Uso da altura: .T. = ocupa todo o espaco disponivel; .F. = respeita o parametro 1
AADD( aObjects, { 100,  093, .T., .F. } )     // Filtro / Listbox TT / Listbox Resumo Fiscal
AADD( aObjects, { 100,  100, .T., .T. } )     // TFolder
AADD( aObjects, { 100,  016, .T., .F. } )     // Total

AADD( aObjSup,  { 050,  100, .T., .T. } )     // Filtro / Listbox TT
AADD( aObjSup,  { 110,  100, .F., .T. } )     // Listbox Resumo Fiscal

AADD( aObjFilTT,{ 100,  016, .T., .F. } )     // Filtro
AADD( aObjFilTT,{ 100,  040, .T., .T. } )     // Listbox TT
AADD( aObjFilTT,{ 100,  012, .T., .F. } )     // Botoes de Selecao

AADD( aObjTotal,{ 015,  010, .T., .T. } )     // Divisao Interna da Parte de Total - "Pe็as"
AADD( aObjTotal,{ 015,  010, .T., .T. } )     // Divisao Interna da Parte de Total - "Desc. Pe็as"
AADD( aObjTotal,{ 015,  010, .T., .T. } )     // Divisao Interna da Parte de Total - "Servi็os"
AADD( aObjTotal,{ 015,  010, .T., .T. } )     // Divisao Interna da Parte de Total - "Desc. Servi็os"
AADD( aObjTotal,{ 015,  010, .T., .T. } )     // Divisao Interna da Parte de Total - "Total O.S."
AADD( aObjTotal,{ 015,  010, .T., .T. } )     // Divisao Interna da Parte de Total - "Total N.Fiscal"
AADD( aObjTotal,{ 015,  010, .T., .T. } )     // Divisao Interna da Parte de Total - "Acrescimo Financeiro"
AADD( aObjTotal,{ 080,  010, .F., .T. } )     // Divisao Interna da Parte de Total - "Total Financeiro (com Acresc. Financeiro)"

AADD( aObjGetDados, { 050,  040, .T., .T. } )   // GetDados Resumo
AADD( aObjGetDados, { 050,  060, .T., .T. } )   // GetDados Detalhado

AADD( aObjOutInf, { 230,  010, .F., .T. } )   // Outras Informacoes - Enchoice
AADD( aObjOutInf, { 010,  010, .T., .T. } )   // Outras Informacoes - Parcelas

AADD( aObjOIEnc, { 010,  070, .T., .T. } )    // Enchoice VOO

AADD( aObjOICR , { 010,  030, .T., .T. } )    // TScroll com o Contas a Receber ...

AADD( aObjOICRInt , { 010,  030, .T., .T. } ) // Divisao interna do TScroll com o Contas a Receber ...
AADD( aObjOICRInt , { 030,  026, .T., .F. } ) // Divisao interna do TScroll com o Contas a Receber ...

AADD( aObjOICRI2, { 040,  010, .T., .T. } )   // Parametros para Calcular Financiamento ( Data Inicial e Dias 1ช Parc.) ...
AADD( aObjOICRI2, { 022,  010, .T., .T. } )   // Parametros para Calcular Financiamento ( Parcelas e Intervalo ) ...
AADD( aObjOICRI2, { 035,  010, .T., .T. } )   // Parametros para Calcular Financiamento ( Saldo ) ...
AADD( aObjOICRI2, { 040,  010, .F., .T. } )   // Parametros para Calcular Financiamento ( Botoes Calcular e Desfazer ) ...

// Divisao principal da Tela
aPOPri   := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 2 , 2 } , aObjects , .T. )

// Posicao Enchoices (VO1) / Listbox TT / Listbox Resumo Fiscal
aPOSup   := MsObjSize( { aPOPri[1,2] , aPOPri[1,1] , aPOPri[1,4] , aPOPri[1,3] , 1, 1 } , aObjSup , .T. , .T. )

// Posicao Filtro da Rotina e Listbox de TT
aPOFilTT := MsObjSize( { aPOSup[1,2] , aPOSup[1,1] , aPOSup[1,4] , aPOSup[1,3] , 1, 1 } , aObjFilTT , .T. )

// Posicao MSGET - Totais
aPOTotal := MsObjSize( { aPOPri[3,2] , aPOPri[3,1] , aPOPri[3,4] , aPOPri[3,3] , 5, 1 } , aObjTotal , .T. , .T.)

// Monta Get com Param. de Filtro e ListBox das OS
oGrFiltro := TGroup():New( aPOFilTT[1,1],aPOFilTT[1,2],aPOFilTT[1,3],aPOFilTT[1,4],,oDlgFech,,,.t.,)

nAuxCol := 08
nAuxWidth := CalcFieldSize( "C" ,Len(cFilNumOsv),,PesqPict("VO1","VO1_NUMOSV"),"")
@ aPOFilTT[1,1]+04, nAuxCol SAY RetTitle("VO1_NUMOSV") OF oDlgFech PIXEL
nAuxCol += 25
@ aPOFilTT[1,1]+03, nAuxCol MSGET oFilNumOsv VAR cFilNumOsv PICTURE PesqPict("VO1","VO1_NUMOSV") VALID OX100FILTRO() SIZE nAuxWidth,01 OF oDlgFech F3 "VO1FE2" PIXEL COLOR CLR_BLACK HASBUTTON WHEN lCanSel

nAuxCol += 50
nAuxWidth := CalcFieldSize( "C" ,Len(cFilClie),,PesqPict("SA1","A1_COD"),"")
@ aPOFilTT[1,1]+04, nAuxCol SAY RetTitle("VO3_FATPAR") OF oDlgFech PIXEL
nAuxCol += 35
@ aPOFilTT[1,1]+03, nAuxCol MSGET oFilClie   VAR cFilClie   PICTURE PesqPict("SA1","A1_COD") VALID OX100FILTRO() SIZE nAuxWidth,01 OF oDlgFech F3 "SA1" PIXEL COLOR CLR_BLACK HASBUTTON WHEN lCanSel

nAuxCol += 38
nAuxWidth := CalcFieldSize( "C" ,Len(cFilLoja),,PesqPict("SA1","A1_LOJA"),AllTrim(RetTitle("VO3_LOJA")))
@ aPOFilTT[1,1]+04, nAuxCol SAY RetTitle("VO3_LOJA") OF oDlgFech PIXEL
nAuxCol += 15
@ aPOFilTT[1,1]+03, nAuxCol MSGET oFilLoja   VAR cFilLoja   PICTURE PesqPict("SA1","A1_LOJA") VALID OX100FILTRO() SIZE nAuxWidth,01 OF oDlgFech PIXEL COLOR CLR_BLACK WHEN lCanSel

nAuxCol += 25
nAuxWidth := CalcFieldSize( "C" ,Len(cFilTTP),,PesqPict("VOI","VOI_TIPTEM"),"")
@ aPOFilTT[1,1]+04, nAuxCol SAY RetTitle("VOI_TIPTEM") OF oDlgFech PIXEL
nAuxCol += 30
@ aPOFilTT[1,1]+03, nAuxCol MSGET oFilTTP    VAR cFilTTP    PICTURE PesqPict("VOI","VOI_TIPTEM") VALID OX100FILTRO() SIZE nAuxWidth,01 OF oDlgFech F3 "VOI" PIXEL COLOR CLR_BLACK HASBUTTON WHEN lCanSel


// Listbox com TT da OS
OX100ATLB(cFilNumOsv, cFilClie, cFilLoja, cFilTTP, cFilChassi) // Atualiza Listbox com os TT da OS
oLbTTP := TWBrowse():New(aPOFilTT[2,1]+2,aPOFilTT[2,2]+2,(aPOFilTT[2,4]-aPOFilTT[2,2]-4),(aPOFilTT[2,3]-aPOFilTT[2,1]-4),,,,oDlgFech,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbTTP:nAT := 1
oLbTTP:SetArray(aVetTTP)
oLbTTP:addColumn( TCColumn():New( "" , { || IIf(aVetTTP[oLbTTP:nAt, ATT_FECHADO], oVerm, If(aVetTTP[oLbTTP:nAt,ATT_VETSEL],oTik,oNo)) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Marcacao do Item
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_NUMOSV")  , { || aVetTTP[oLbTTP:nAt,ATT_NUMOSV] }  ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // 01 - Nro da OS
oLbTTP:addColumn( TCColumn():New( STR0006                 , { || aVetTTP[oLbTTP:nAt,ATT_TIPTEM] }  ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // 02 - TT
oLbTTP:addColumn( TCColumn():New(RetTitle("VOO_LIBVOO"), { || aVetTTP[oLbTTP:nAt,ATT_LIBVOO] }  ,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) // 20 - Numero da Liberacao (VOO_LIBVOO)
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_FATPAR")  , { || aVetTTP[oLbTTP:nAt,ATT_CLIENTE]+"-"+aVetTTP[oLbTTP:nAt,ATT_LOJA] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // 03 - Faturar para
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_NOMCLI")  , { || aVetTTP[oLbTTP:nAt,ATT_NOME] }    ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // 04 - Nome
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_TOTPEC")  , { || Transform(aVetTTP[oLbTTP:nAt,ATT_TOTPEC]  ,"@E 9,999,999.99") } ,,,,"RIGHT",45,.F.,.F.,,,,.F.,) ) // 05 - Tot. Pecas
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_HRSPAD")  , { || Transform(aVetTTP[oLbTTP:nAt,ATT_HORASPAD],"@R 999:99") }       ,,,,"RIGHT",25,.F.,.F.,,,,.F.,) ) // 06 - Hrs Pad
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_HRSAPL")  , { || Transform(aVetTTP[oLbTTP:nAt,ATT_HORASTRA],"@R 999:99") }       ,,,,"RIGHT",25,.F.,.F.,,,,.F.,) ) // 07 - Hrs Apl
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_TOTSRV")  , { || Transform(aVetTTP[oLbTTP:nAt,ATT_TOTSER]  ,"@E 9,999,999.99") } ,,,,"RIGHT",40,.F.,.F.,,,,.F.,) ) // 08 - Tot. Srvcs
oLbTTP:addColumn( TCColumn():New( RetTitle("VO1_FUNABE")  , { || aVetTTP[oLbTTP:nAt,ATT_FUNABE] }  ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // 09 - Consultor
oLbTTP:addColumn( TCColumn():New( RetTitle("VAI_CODVEN")  , { || aVetTTP[oLbTTP:nAt,ATT_CODVEN] }  ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // 10 - Cod Vendedor
oLbTTP:addColumn( TCColumn():New( RetTitle("VO1_CHASSI")  , { || aVetTTP[oLbTTP:nAt,ATT_CHASSI] }  ,,,,"LEFT" ,50,.F.,.F.,,,,.F.,) ) // 11 - Chassi Veic
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_SERNFI")  , { || aVetTTP[oLbTTP:nAt,ATT_SERNFI] }  ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // 12 - Serie da NF
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_NUMNFI")  , { || aVetTTP[oLbTTP:nAt,ATT_NUMNFI] }  ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // 13 - Nro da NF
oLbTTP:addColumn( TCColumn():New( RetTitle("VOO_PESQLJ")  , { || aVetTTP[oLbTTP:nAt,ATT_ORCLOJA] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // 14 - Orcamento Lj

If ExistBlock("OX100CLB")
	ExecBlock("OX100CLB",.F.,.F., { @oLbTTP } )
EndIf

oLbTTP:bLDblClick := { || OX100LBOXS(.f.) }
oLbTTP:bHeaderClick := { |oObj,nCol| If( nCol==1, (OX100LBOXS(.t.,lMarca), lMarca := !lMarca) , Nil ) }
oLbTTP:Refresh()
If Len(aVetTTP) == 1 .and. Empty(aVetTTP[1,ATT_NUMOSV])
	cFilNumOsv := Space(TamSX3("VO1_NUMOSV")[1])
	oFilNumOsv:Refresh()
EndIf

// Botoes de Selecao
@ aPOFilTT[3,1] , aPOFilTT[3,2]+002 BUTTON oBtnSel PROMPT STR0096 OF oDlgFech SIZE 100,10 PIXEL WHEN lCanSel ACTION OX100SEL() // "Selecionar para Fechamento"
@ aPOFilTT[3,1] , aPOFilTT[3,4]-102 BUTTON oBtnCan PROMPT STR0097 OF oDlgFech SIZE 100,10 PIXEL WHEN !lCanSel ACTION OX100CSEL() // "Cancelar Sele็ใo"

oGrLBoxTT := TGroup():New( aPOFilTT[2,1],aPOFilTT[2,2],aPOFilTT[3,3],aPOFilTT[3,4],,oDlgFech,,,.t.,)

// Listbox com Resumo Fiscal
oLbResFisc := TWBrowse():New(aPOSup[2,1],aPOSup[2,2]+2,(aPOSup[2,4]-aPOSup[2,2]),(aPOSup[2,3]-aPOSup[2,1]),,{ STR0098 , STR0099 },,oDlgFech,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // "Descri็ใo","Valor"
oLbResFisc:aColSizes := {50,30}

// Folder
oFolder100 := TFolder():New(aPOPri[2,1], aPOPri[2,2], { STR0100 , STR0101 , STR0102 }, , oDlgFech, , , , .t. , , aPOPri[2,4], aPOPri[2,3]-aPOPri[2,1] ) // "Negociar Pecas","Negociar Servicos","Outras Inf."

// Posicao GetDados - Resumo / Analitico
aPOGetDados := MsObjSize( { 2 , 2 , (oFolder100:nClientWidth / 2 ) - 4 , ( oFolder100:nClientHeight / 2 ) - 15 , 0, 2 } , aObjGetDados , .T. )

// Posicao Outras Informacoes - Enchoice e Como Pagar
aPOOutInf := MsObjSize( { 2 , 2 , (oFolder100:nClientWidth / 2 ) - 04 , ( oFolder100:nClientHeight / 2 ) - 15 , 2, 0 } , aObjOutInf , .T. , .T. )

// Posicao Enchoice VOO ( Outras Informacoes )
aPOOIEnc := MsObjSize( { aPOOutInf[1,2] , aPOOutInf[1,1] , aPOOutInf[1,4] , aPOOutInf[1,3] , 0, 2 } , aObjOIEnc , .T. )

// Posicao TScroll com o Contas a Receber
aPOOICR := MsObjSize( { aPOOutInf[2,2] , aPOOutInf[2,1] , aPOOutInf[2,4] , aPOOutInf[2,3] , 0, 2 } , aObjOICR , .T. )

// Posicao da Divisao Interna do TScroll com o Contas a Receber
aPOOICRInt := MsObjSize( { 0 , 0 , aPOOICR[1,4] - aPOOICR[1,2] , aPOOICR[1,3] - aPOOICR[1,1] , 2, 2 } , aObjOICRInt , .T. )
aPOOICRI2  := MsObjSize( { aPOOICRInt[2,2] , aPOOICRInt[2,1]+2 , aPOOICRInt[2,4] , aPOOICRInt[2,3]-2 , 0, 0 } , aObjOICRI2 , .T. , .T. )


// GetDados de Pecas
cPRLinOk   := "AlwaysTrue()"  // Linha OK da GetDados de Resumo
cPRFieldOk := "OX100PRFOK()"  // Field OK da GetDados de Resumo
cPRTudoOk  := "AlwaysTrue()"  // Tudo  OK da GetDados de Resumo
cPDLinOk   := "OX100PDLOK()"  // Linha OK da GetDados de Detalhade
cPDFieldOk := "OX100PDFOK()"  // Field OK da GetDados de Detalhade
cPDTudoOk  := "AlwaysTrue()"  // Tudo  OK da GetDados de Detalhade

oGetResVO3 := MsNewGetDados():New(aPOGetDados[1,1],aPOGetDados[1,2],aPOGetDados[1,3],aPOGetDados[1,4],;
											(GD_UPDATE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
											cPRLinOk,cPRTudoOk,;
											,;    // Nome dos campos do tipo caracter que utilizacao incremento automatico
											aHVO3RAlt ,;  // Campos alteraveis da GetDados
											/* nFreeze */,; // Campos estaticos da GetDados
											999,;
											cPRFieldOk,;
											/* cSuperDel */,;   // Funcao executada quando pressionado <Ctrl>+<Del>
											/* cDelOk */,;    // Funcao executada para validar a exclusao de uma linha
											oFolder100:aDialogs[1],;
											aHVO3Res,;
											aCVO3Res)
oGetResVO3:oBrowse:bChange   := { || FG_MEMVAR( oGetResVO3:aHeader, oGetResVO3:aCols, oGetResVO3:nAt) }
oGetResVO3:oBrowse:bGotFocus := { || FG_MEMVAR( oGetResVO3:aHeader, oGetResVO3:aCols, oGetResVO3:nAt) }

oGetDetVO3 := MsNewGetDados():New(aPOGetDados[2,1],aPOGetDados[2,2],aPOGetDados[2,3],aPOGetDados[2,4],;
											(GD_UPDATE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
											cPDLinOk,cPDTudoOk,;
											,;    // Nome dos campos do tipo caracter que utilizacao incremento automatico
											aHVO3DAlt ,;  // Campos alteraveis da GetDados
											/* nFreeze */,; // Campos estaticos da GetDados
											9999,;
											cPDFieldOk,;
											/* cSuperDel */,;   // Funcao executada quando pressionado <Ctrl>+<Del>
											/* cDelOk */,;    // Funcao executada para validar a exclusao de uma linha
											oFolder100:aDialogs[1],;
											aHVO3Det,;
											aCVO3Det)
oGetDetVO3:oBrowse:bChange   := { || FG_MEMVAR( oGetDetVO3:aHeader , oGetDetVO3:aCols , oGetDetVO3:nAt) }
oGetDetVO3:oBrowse:bGotFocus := { || FG_MEMVAR( oGetDetVO3:aHeader , oGetDetVO3:aCols , oGetDetVO3:nAt) }

// GetDados de Servicos
cSRLinOk   := "OX100SRLOK()"  // Linha OK da GetDados de Resumo
cSRFieldOk := "OX100SRFOK()"  // Field OK da GetDados de Resumo
cSRTudoOk  := "AlwaysTrue()"  // Tudo  OK da GetDados de Resumo
cSDLinOk   := "AlwaysTrue()"  // Linha OK da GetDados de Detalhade
cSDFieldOk := "OX100SDFOK()"  // Field OK da GetDados de Detalhade
cSDTudoOk  := "AlwaysTrue()"  // Tudo  OK da GetDados de Detalhade

oGetResVO4 := MsNewGetDados():New(aPOGetDados[1,1],aPOGetDados[1,2],aPOGetDados[1,3],aPOGetDados[1,4],;
(GD_UPDATE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
cSRLinOk,cSRTudoOk,;
,;    // Nome dos campos do tipo caracter que utilizacao incremento automatico
aHVO4RAlt ,;  // Campos alteraveis da GetDados
/* nFreeze */,; // Campos estaticos da GetDados
999,;
cSRFieldOk,;
/* cSuperDel */,;   // Funcao executada quando pressionado <Ctrl>+<Del>
/* cDelOk */,;    // Funcao executada para validar a exclusao de uma linha
oFolder100:aDialogs[2],;
aHVO4Res,;
aCVO4Res)
oGetResVO4:oBrowse:bChange   := {|| FG_MEMVAR( oGetResVO4:aHeader, oGetResVO4:aCols, oGetResVO4:nAt) }
oGetResVO4:oBrowse:bGotFocus := {|| FG_MEMVAR( oGetResVO4:aHeader, oGetResVO4:aCols, oGetResVO4:nAt) }

oGetDetVO4 := MsNewGetDados():New(aPOGetDados[2,1],aPOGetDados[2,2],aPOGetDados[2,3],aPOGetDados[2,4],;
(GD_UPDATE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
cSDLinOk,cSDTudoOk,;
,;    // Nome dos campos do tipo caracter que utilizacao incremento automatico
aHVO4AAlt ,;  // Campos alteraveis da GetDados
/* nFreeze */,; // Campos estaticos da GetDados
9999,;
cSDFieldOk,;
/* cSuperDel */,;   // Funcao executada quando pressionado <Ctrl>+<Del>
/* cDelOk */,;    // Funcao executada para validar a exclusao de uma linha
oFolder100:aDialogs[2],;
aHVO4Det,;
aCVO4Det)
oGetDetVO4:oBrowse:bChange   := {|| FG_MEMVAR( oGetDetVO4:aHeader , oGetDetVO4:aCols , oGetDetVO4:nAt) }
oGetDetVO4:oBrowse:bGotFocus := {|| FG_MEMVAR( oGetDetVO4:aHeader , oGetDetVO4:aCols , oGetDetVO4:nAt) }

// Aba de OUTRAS INFORMACOES
oEnchVOO := MSMGet():New("VOO", 1 , 3,;
/* aCRA */, /* cLetra */, /* cTexto */, aCpoVOO, aPOOIEnc[1], aCpoVOO , nModelo,;
/* nColMens */, /* cMensagem */, cTudoOk , oFolder100:aDialogs[3], lF3, lMemoria, .T. /* lColumn */ ,;
caTela, !lVOOTRANSP /* lNoFolder */, lProperty)

oScroCR := TScrollBox():New( oFolder100:aDialogs[3] , ;
aPOOICR[1,1] , aPOOICR[1,2] , aPOOICR[1,3] - aPOOICR[1,1] ,aPOOICR[1,4] - aPOOICR[1,2] , .t. , , .t. )

cCRLinOk  := "AlwaysTrue()"
cCRFieldOk  := "OX100FOVS9()"
cCRTudoOk   := "AlwaysTrue()"
oGetVS9 := MsNewGetDados():New(aPOOICRInt[1,1],aPOOICRInt[1,2],aPOOICRInt[1,3],aPOOICRInt[1,4],;
(GD_INSERT+GD_DELETE+GD_UPDATE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
cCRLinOk,cCRTudoOk,;
,;    // Nome dos campos do tipo caracter que utilizacao incremento automatico
aHVS9AAlt ,;  // Campos alteraveis da GetDados
/* nFreeze */,; // Campos estaticos da GetDados
9999,;
cCRFieldOk,;
/* cSuperDel */,;   // Funcao executada quando pressionado <Ctrl>+<Del>
/* cDelOk */,;    // Funcao executada para validar a exclusao de uma linha
oScroCR,;
aHVS9,;
aCVS9)
oGetVS9:oBrowse:bChange := {|| FG_MEMVAR( oGetVS9:aHeader , oGetVS9:aCols , oGetVS9:nAt) }
oGetVS9:oBrowse:bDelete := {|| OX100DLVS9(),oGetVS9:oBrowse:Refresh() }

@ aPOOICRI2[1,1]+1  , aPOOICRI2[1,2] SAY STR0079 OF oScroCR PIXEL   // "Data Inicial"
@ aPOOICRI2[1,1]+11 , aPOOICRI2[1,2] SAY STR0080 OF oScroCR PIXEL   // "Dias 1a Parc"

@ aPOOICRI2[2,1]+1  , aPOOICRI2[2,2] SAY STR0081 OF oScroCR PIXEL // "Parcelas"
@ aPOOICRI2[2,1]+11 , aPOOICRI2[2,2] SAY STR0082 OF oScroCR PIXEL // "Intervalo"

@ aPOOICRI2[3,1]+1  , aPOOICRI2[3,2] SAY STR0083 OF oScroCR PIXEL // "Total Fin."
@ aPOOICRI2[3,1]+11 , aPOOICRI2[3,2] SAY STR0084 OF oScroCR PIXEL // "Saldo"

@ aPOOICRI2[1,1]  , aPOOICRI2[1,2]+35 MSGET oCRDataIni  VAR dCRDataIni  PICTURE "@D"        SIZE 45,01 OF oScroCR WHEN lSE4TipoA VALID ( dCRDataIni >= dDataBase ) PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOOICRI2[1,1]+11 , aPOOICRI2[1,2]+35 MSGET oCRDias   VAR nCRDias   PICTURE "@E 999"      SIZE 20,01 OF oScroCR WHEN lSE4TipoA VALID ( nCRDias >= 0 ) PIXEL COLOR CLR_BLACK HASBUTTON

@ aPOOICRI2[2,1]  , aPOOICRI2[2,2]+25 MSGET oCRParc   VAR nCRParc   PICTURE "@E 999"      SIZE 20,01 OF oScroCR WHEN lSE4TipoA VALID ( nCRParc >= 0 .and. nCRParc <= GetMV("MV_NUMPARC") ) PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOOICRI2[2,1]+11 , aPOOICRI2[2,2]+25 MSGET oCRInter    VAR nCRInter  PICTURE "@E 999"      SIZE 20,01 OF oScroCR WHEN lSE4TipoA VALID ( nCRInter >= 0 ) PIXEL COLOR CLR_BLACK HASBUTTON

@ aPOOICRI2[3,1]  , aPOOICRI2[3,2]+22 MSGET oCRTotal    VAR nCRTotal  PICTURE "@E 9,999,999.99" SIZE 45,01 OF oScroCR WHEN .F.     PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOOICRI2[3,1]+11 , aPOOICRI2[3,2]+22 MSGET oCRSaldo    VAR nCRSaldo  PICTURE "@E 9,999,999.99" SIZE 45,01 OF oScroCR WHEN .F.     PIXEL COLOR CLR_BLACK HASBUTTON

@ aPOOICRI2[4,1]  , aPOOICRI2[4,2] BUTTON oBtn1 PROMPT STR0094 OF oScroCR SIZE 35,10 PIXEL ACTION OX100FCALC() WHEN lSE4TipoA // "Calcular"
@ aPOOICRI2[4,1]+11 , aPOOICRI2[4,2] BUTTON oBtn2 PROMPT STR0095 OF oScroCR SIZE 35,10 PIXEL ACTION OX100FDESF() WHEN lSE4TipoA // "Desfazer"

// Totais Liquidos
TGroup():New( aPOPri[3,1],aPOPri[3,2],aPOPri[3,3],aPOPri[3,4]+2, , oDlgFech,,,.t., )

@ aPOTotal[1,1]+3 , aPOTotal[1,2]   SAY STR0085 OF oDlgFech PIXEL // "Pe็as"
@ aPOTotal[2,1]+3 , aPOTotal[2,2]-3 SAY STR0086 OF oDlgFech PIXEL // "Desc Pe็as"
@ aPOTotal[3,1]+3 , aPOTotal[3,2]   SAY STR0087 OF oDlgFech PIXEL // "Servi็os"
@ aPOTotal[4,1]+3 , aPOTotal[4,2]-2 SAY STR0088 OF oDlgFech PIXEL // "Desc Servs"
@ aPOTotal[5,1]+3 , aPOTotal[5,2]   SAY STR0089 OF oDlgFech PIXEL // "Total O.S."
@ aPOTotal[6,1]+3 , aPOTotal[6,2]   SAY STR0090 OF oDlgFech PIXEL COLOR CLR_HBLUE // "Total N.Fiscal"
@ aPOTotal[7,1]+3 , aPOTotal[7,2]+5 SAY STR0166 OF oDlgFech PIXEL // "Acr้scFin"
@ aPOTotal[8,1]+3 , aPOTotal[8,2]   SAY STR0083 OF oDlgFech PIXEL COLOR CLR_HBLUE // "Total Fin."

@ aPOTotal[1,1]+2 , aPOTotal[1,2]+20 MSGET oTotPecas   VAR nTotPeca     PICTURE "@E 9,999,999.99" SIZE 53,01 OF oDlgFech WHEN .F. PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOTotal[2,1]+2 , aPOTotal[2,2]+29 MSGET oTotDPecas  VAR nTotDPeca    PICTURE "@E 99,999.99"    SIZE 43,01 OF oDlgFech WHEN .F. PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOTotal[3,1]+2 , aPOTotal[3,2]+25 MSGET oTotSrvc    VAR nTotSrvc     PICTURE "@E 9,999,999.99" SIZE 53,01 OF oDlgFech WHEN .F. PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOTotal[4,1]+2 , aPOTotal[4,2]+35 MSGET oTotDSrvc   VAR nTotDSrvc    PICTURE "@E 99,999.99"    SIZE 43,01 OF oDlgFech WHEN .F. PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOTotal[5,1]+2 , aPOTotal[5,2]+25 MSGET oTotOS      VAR nTotOS       PICTURE "@E 9,999,999.99" SIZE 53,01 OF oDlgFech WHEN .F. PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOTotal[6,1]+2 , aPOTotal[6,2]+33 MSGET oTotnFiscal VAR nTotnFiscal  PICTURE "@E 9,999,999.99" SIZE 53,01 OF oDlgFech WHEN .F. PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOTotal[7,1]+2 , aPOTotal[7,2]+34 MSGET oAcresFin   VAR nAcresFin    PICTURE "@E 9,999.99"     SIZE 40,01 OF oDlgFech WHEN .F. PIXEL COLOR CLR_BLACK HASBUTTON
@ aPOTotal[8,1]+2 , aPOTotal[8,2]+31 MSGET oTotFinanc  VAR nTotFinanc   PICTURE "@E 9,999,999.99" SIZE 53,01 OF oDlgFech WHEN .F. PIXEL COLOR CLR_BLACK HASBUTTON

OX100ATRES(.t.) // Atualiza o Resumo ..
OX100CSEL()   // Desabilita controles
// Se o Listbox de TT Tiver somente uma linha ja vem marcado ...
If !Empty(aVetTTP[1,ATT_NUMOSV])
	If Len(aVetTTP) == 1 .and. !aVetTTP[1, ATT_FECHADO]
		oLbTTP:nAt := 1
		oLbTTP:SetFocus()
		OX100LBOXS(.f.)
	Else
		oLbTTP:SetFocus()
	EndIf
EndIf
//

aBotEncFec := {}
AADD(aBotEncFec, { "PMSCOLOR",{ || BrwLegenda(STR0114,STR0115,{ {"BR_VERMELHO",STR0116} } ) } , STR0115 })
AADD(aBotEncFec, { "SALVAR" ,{ || OX100SNEG(.t.)  }, "<F4> " + STR0091 } ) // "Salvar Negocia็ใo"
AADD(aBotEncFec, { "E5"   ,{ || OX100OPCOES() },("<F10> " + STR0092 )} ) // Op็๕es
AADD(aBotEncFec, { "PRECO"   ,{ || OX100AVAL() },( STR0148 )} ) // "Avalia็ใo de Resultado"

If ExistBlock("PREFECT2")
	AADD(aBotEncFec, { "IMPRESSAO" ,{ || OX100IMPPF() },( STR0104 )} ) // Formulario de Pre-Fechamento
EndIf

SetKey(VK_F4, {|| OX100SNEG(.t.) })
If ExistBlock("OX100F8")
	SetKey(VK_F8, {|| OX100F8() })
EndIf
SetKey(VK_F10,{|| OX100OPCOES() })


ACTIVATE MSDIALOG oDlgFech ON INIT ( EnchoiceBar(oDlgFech, { || IIf(OX100FECHA(),oDlgFech:End(),NIL) }, { || oDlgFech:End() },, aBotEncFec ) )

OX100002_LiberaSemaforo()

SetKey(VK_F4, Nil )
SetKey(VK_F8, Nil )
SetKey(VK_F10, Nil )

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100LBOXS บAutor  ณ Takahashi          บ Data ณ  15/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Marca linha do list box, fazendo validacoes necessarias    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lTodos = Indica se deve marcar todos os itens              บฑฑ
ฑฑบ          ณ lMarca = Controla se marca ou desmarca todos os itens      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100LBOXS(lTodos, lMarca)

Local nPosSel // Posicao da primeira linha ja selecionada anteriormente ...
Local nPos
Local cSQL
Local lAuxSitTpo
Local lVAI_VOSFER := (VAI->(FieldPos("VAI_VOSFER")) <> 0)

If !lCanSel
	Return
EndIf

// Matriz do Listbox esta vazia
If Empty(aVetTTP[1,ATT_NUMOSV])
	Return
EndIf

// Verifica se o TT ja esta fechado
If !lTodos .and. aVetTTP[oLbTTP:nAt, ATT_FECHADO]
	Return
EndIf

// Antes de Marcar o TT, verifica a situacao do cliente ...
If !aVetTTP[oLbTTP:nAt,ATT_VETSEL] .and. aVetTTP[oLbTTP:nAt,ATT_A1BLOQ] == "1"
	HELP(" ",1,"REGBLOQ")
	Return
EndIf

// Posiciona na primeira linha jแ marcada
nPosSel := AScan( aVetTTP , { |x| x[ATT_VETSEL] == .t. } )

// Se ja tiver algum TT selecionado
If nPosSel <> 0 .and. (nPosSel <> oLbTTP:nAt .or. lTodos)
	
	VOI->(dbSetOrder(1))
	VOI->(MsSeek(xFilial("VOI") + aVetTTP[nPosSel, ATT_TIPTEM ] ))
	
	// Se tiver uma linha selecionada, verifica se ้ de TT de Seguradora ...
	If VOI->VOI_SEGURO == "1"
		MsgAlert(STR0032,STR0004) // Para tipo de tempo de seguradora, s๓ ้ possํvel fazer fechamento individual!
		Return
	EndIf
	//
	
	// Verifica se o Tipo de Tempo ้ de Garantia
	If OX100TTGAR( VOI->VOI_TIPTEM , VOI->VOI_SITTPO ) .and. !lMVMIL0058
		MsgAlert(STR0125,STR0004) // "Para tipo de tempo de garantia s๓ ้ possํvel fazer fechamento individual."
		Return
	EndIf
	//
	
	// Se for outro TT
	If VOI->VOI_TIPTEM <> aVetTTP[oLbTTP:nAt, ATT_TIPTEM ]
		lAuxSitTpo := VOI->VOI_SITTPO
		VOI->(MsSeek(xFilial("VOI") + aVetTTP[oLbTTP:nAt, ATT_TIPTEM ] ))
		If VOI->VOI_SITTPO <> lAuxSitTpo .and. !lMVMIL0059
			MsgAlert(STR0103,STR0004) // S๓ ้ possํvel selecionar Tipo de Tempo de mesma situa็ใo (VOI_SITTPO)
			Return
		EndIf
	EndIf
	//
EndIf
//

// Nao Marca todos
If !lTodos
	
	// Valida se o Item selecionado ้ do mesmo Faturar Para e TTP
	If nPosSel <> 0
		If aVetTTP[nPosSel,ATT_CLIENTE] <> aVetTTP[oLbTTP:nAt,ATT_CLIENTE] .or. aVetTTP[nPosSel,ATT_LOJA] <> aVetTTP[oLbTTP:nAt,ATT_LOJA]
			MsgAlert(STR0014 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
			STR0015 + aVetTTP[nPosSel,ATT_TIPTEM] + CHR(13) + CHR(10) + ;
			STR0016 + aVetTTP[nPosSel,ATT_CLIENTE] + "-" + aVetTTP[nPosSel,ATT_LOJA] + " " + aVetTTP[nPosSel,ATT_NOME],STR0004)
			Return
		EndIf
	Else
		nPosSel := oLbTTP:nAt
	EndIf
	
	// Valida Tipo de Tempo de Garantia ...
	If !aVetTTP[oLbTTP:nAt,ATT_VETSEL]
		If !OX100VALGAR(aVetTTP[oLbTTP:nAt,ATT_NUMOSV], aVetTTP[oLbTTP:nAt,ATT_TIPTEM], aVetTTP[oLbTTP:nAt,ATT_LIBVOO], aVetTTP[oLbTTP:nAt,ATT_TOTPEC] , aVetTTP[oLbTTP:nAt,ATT_TOTSER] , aVetTTP[oLbTTP:nAt, ATT_CODMAR] )
			Return
		EndIf
	EndIf
	//
	
	// Validar Ferramentas requisitadas para a OS e Tp.Tempo
	If !aVetTTP[oLbTTP:nAt,ATT_VETSEL] .and. lVAI_VOSFER
		If !OM450VFER( aVetTTP[oLbTTP:nAt,ATT_NUMOSV] , aVetTTP[oLbTTP:nAt,ATT_TIPTEM] , "2" ) // 2 - Fechamento de OS
			Return
		EndIf
	EndIf
	//
	
	aVetTTP[oLbTTP:nAt,ATT_VETSEL] := !aVetTTP[oLbTTP:nAt,ATT_VETSEL]
	oLbTTP:DrawSelect()
	
	// Marca todos os registros
Else
	
	If nPosSel == 0
		// Procura algum tipo de tempo aberto ...
		nPosSel := AScan( aVetTTP , { |x| x[ATT_FECHADO] == .F. } )
		If nPosSel == 0
			Return
		EndIf
		//
		oLbTTP:nAt := nPosSel
	Else
		oLbTTP:nAt := nPosSel
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se ja existe algum item selecionado,ณ
	//ณ se tiver, marca todos "iguais"               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nPos := 1 to Len(aVetTTP)
		
		If !aVetTTP[nPos,ATT_FECHADO] .and. aVetTTP[nPos,ATT_TIPTEM] == aVetTTP[oLbTTP:nAt,ATT_TIPTEM] .and. aVetTTP[nPos,ATT_CLIENTE] == aVetTTP[oLbTTP:nAt,ATT_CLIENTE] .and. aVetTTP[nPos,ATT_LOJA] == aVetTTP[oLbTTP:nAt,ATT_LOJA]
			
			// Valida Tipo de Tempo de Garantia ...
			If !OX100VALGAR(aVetTTP[nPos,ATT_NUMOSV], aVetTTP[nPos,ATT_TIPTEM], aVetTTP[nPos,ATT_LIBVOO], aVetTTP[nPos,ATT_TOTPEC] , aVetTTP[nPos,ATT_TOTSER] , aVetTTP[nPos, ATT_CODMAR] )
				Loop
			EndIf
			//
			
			//			If aVetTTP[nPos,ATT_TOTSER] == 0
			//				lGarPeca := OX100TTGAR( aVetTTP[nPos,ATT_TIPTEM] )
			//			EndIf
			
			aVetTTP[nPos,ATT_VETSEL] := lMarca
			
			// Validar Ferramentas requisitadas para a OS e Tp.Tempo
			If aVetTTP[nPos,ATT_VETSEL] .and. lVAI_VOSFER
				If !OM450VFER( aVetTTP[nPos,ATT_NUMOSV] , aVetTTP[nPos,ATT_TIPTEM] , "2" ) // 2 - Fechamento de OS
					aVetTTP[nPos,ATT_VETSEL] := .f. // Desmarcar TIK
				EndIf
			EndIf
			//
			
		EndIf
		
	Next nPos
	
	oLbTTP:Refresh()
	
EndIf
//

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100CSEL  บAutor  ณ Takahashi          บ Data ณ  20/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Cancela selecao dos TT para fechamento e limpa tela        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100CSEL()

lCanSel := .t.
oGetResVO3:Disable()
oGetDetVO3:Disable()
oGetResVO4:Disable()
oGetDetVO4:Disable()
oEnchVOO:Disable()
oGetVS9:Disable()
lSE4TipoA := .f.

OX100FILTRO()
MsUnlockAll()

OX100002_LiberaSemaforo()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100SEL   บAutor  ณ Takahashi          บ Data ณ  20/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Confirma selecao dos TT para fechamento e carrega pecas e  บฑฑ
ฑฑบ          ณ servicos                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100SEL()

Local cSB1NEnc := "" // SB1 nao encontrados
Local nPos     := 0
Local cQuery   := ""
Local cQAlias  := "SQLVO3"

Local lSelOk   := .t.

Local aAuxSel // Matriz auxiliar para conter as linhas selecionadas ...
Local nCntFor

Local cOrcTpFre := "" // Tipo de Frete vindo do Orcamento
Local nOrcFrete := 0  // Valor Total de Frete vindo do Orcamento

Local oOficina   := DMS_Oficina():New()

If aScan( aVetTTP , { |x| x[ATT_VETSEL] == .t. } ) == 0
	MsgAlert(STR0053,STR0004) // "Selecionar um registro para faturamento"
	Return .f.
EndIf

For nCntFor := 1 to Len(aVetTTP)
	If aVetTTP[nCntFor,ATT_VETSEL]

		If oOficina:TipoTempoBloqueado(aVetTTP[nCntFor, ATT_TIPTEM],.t.) // Valida se Tipo de Tempo esta BLOQUEADO
			OX100CSEL()
			Return .f.
		EndIf

		If nPos <= 5
			// Verifica se existe os itens no cadastro de produtos ( SB1 )
			cQuery := "SELECT DISTINCT SB1.R_E_C_N_O_ RECSB1 , VO3.VO3_GRUITE , VO3.VO3_CODITE "
			cQuery += "FROM " + RetSQLName("VO2") + " VO2 "
			cQuery += "JOIN " + RetSQLName("VO3") + " VO3 ON ( VO3.VO3_FILIAL=VO2.VO2_FILIAL AND VO3.VO3_NOSNUM=VO2.VO2_NOSNUM AND VO3.VO3_TIPTEM='"+aVetTTP[nCntFor, ATT_TIPTEM]+"' AND VO3.VO3_LIBVOO='"+aVetTTP[nCntFor, ATT_LIBVOO]+"' AND VO3.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN " + RetSQLName("SB1") + " SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VO3.VO3_GRUITE AND SB1.B1_CODITE=VO3.VO3_CODITE AND SB1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_NUMOSV='"+aVetTTP[nCntFor, ATT_NUMOSV]+"' AND VO2.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
			Do While !( cQAlias )->( Eof() )
				If ( cQAlias )->( RECSB1 ) <= 0
					If nPos <= 5
						cSB1NEnc += ( cQAlias )->( VO3_GRUITE )+" "+( cQAlias )->( VO3_CODITE )+CHR(13)+CHR(10)
						nPos++
					Else
						cSB1NEnc += "..."
						Exit
					EndIf
				EndIf
				( cQAlias )->( DbSkip() )
			EndDo
			( cQAlias )->( dbCloseArea() )
			//
		EndIf
		// Verifica se existe FRETE / TIPO FRETE no Orcamento para trazer no Fechamento
		cQuery := "SELECT VS1_PGTFRE , VS1_VALFRE "
		cQuery += "  FROM " + RetSQLName("VS1")
		cQuery += " WHERE VS1_FILIAL='"+xFilial("VS1")+"'"
		cQuery += "   AND VS1_NUMOSV='"+aVetTTP[nCntFor, ATT_NUMOSV]+"'"
		cQuery += "   AND VS1_TIPTEM='"+aVetTTP[nCntFor, ATT_TIPTEM]+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		Do While !( cQAlias )->( Eof() )
			cOrcTpFre := ( cQAlias )->( VS1_PGTFRE )
			nOrcFrete += ( cQAlias )->( VS1_VALFRE )
			( cQAlias )->( DbSkip() )
		EndDo
		( cQAlias )->( dbCloseArea() )
		//
	EndIf
Next nCntFor
//
dbSelectArea("VO1")
dbSetOrder(1)
If !Empty(cSB1NEnc)
	MsgAlert(STR0137+CHR(13)+CHR(10)+cSB1NEnc,STR0004) // Item(ns) nใo encontrado(s) no cadastro de produtos (SB1).
	Return .f.
EndIf
//
// Valida os Tipos de Tempos selecionados no Fechamento da OS
//
If ExistBlock("OX100SEL")
	If !ExecBlock("OX100SEL",.f.,.f.,{aVetTTP})
		Return .f.
	Endif
EndIf
// Exibe somente os TT Selecionados para faturamento
aAuxSel  := {}
aLockVOO := {}
For nCntFor := 1 to Len(aVetTTP)
	If aVetTTP[nCntFor,ATT_VETSEL]
		AADD( aAuxSel, aClone(aVetTTP[nCntFor]) )
		
		// Adiciona na matriz para bloquear o registro ...
		AADD( aLockVOO , aVetTTP[nCntFor, ATT_NUMOSV] + aVetTTP[nCntFor, ATT_TIPTEM] + aVetTTP[nCntFor, ATT_LIBVOO] )
		//
		
	EndIf
Next nCntFor
aVetTTP := aClone( aAuxSel)
oLbTTP:nAt := 1
oLbTTP:SetArray(aVetTTP)
oLbTTP:DrawSelect()
oLbTTP:Refresh()
//
If !OX100001_CriaSemaforo()
	OX100CSEL()
	Return .f.
EndIf
//
If !OX100VOOBLQ()
	OX100CSEL()
	Return .f.
EndIf
// Depois de bloqueado os registros, verifica se ainda nใo foram faturados por outro usuario ...
VOO->(dbSetOrder(1))
For nCntFor := 1 to Len(aLockVOO)
	VOO->(dbSeek(xFilial("VOO") + aLockVOO[nCntFor]))
	If !Empty(VOO->VOO_NUMNFI) .or. !Empty(VOO->VOO_SERNFI)
		MsgInfo(STR0130,STR0004) // "Tipo de tempo jแ foi faturado."
		OX100CSEL()
		Return .f.
	EndIf
Next nCntFor
//

// Carrega as pecas e servicos das liberacoes selecionadas
oProcTTP := MsNewProcess():New({ |lEnd| lSelOk := OX100SLPRC() }," " + STR0093 + " ...","",.T.)
oProcTTP:Activate()
//

// Usuario so tem permissao para alterar a OS...
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
If lFECOFI .and. VAI->VAI_FECOFI == "2"
	oGetResVO3:Disable()
	oGetDetVO3:Disable()
	oGetResVO4:Disable()
	oGetDetVO4:Disable()
	oEnchVOO:Disable()
	oGetVS9:Disable()
	lSE4TipoA := .f.
Else
	
	If Len(oGetResVO3:aCols) > 1 .or. ( Len(oGetResVO3:aCols) == 1 .and. !Empty(oGetResVO3:aCols[1,FG_POSVAR("VO3_GRUITE","aHVO3Res")]) )
		oGetResVO3:Enable()
		oGetDetVO3:Enable()
	EndIf
	
	If Len(oGetResVO4:aCols) > 1 .or. ( Len(oGetResVO4:aCols) == 1 .and. !Empty(oGetResVO4:aCols[1,FG_POSVAR("VO4_TIPSER","aHVO4Res")]) )
		oGetResVO4:Enable()
		oGetDetVO4:Enable()
	EndIf
	
	oEnchVOO:Enable()
	oGetVS9:Enable()
EndIf

If !Empty(cOrcTpFre)
	M->VOO_TPFRET := cOrcTpFre // Tipo de Frete vindo do Orcamento
	OX100VOO("M->VOO_TPFRET")
EndIf
If nOrcFrete > 0
	M->VOO_FRETE := nOrcFrete // Valor Total de Frete vindo do Orcamento
	OX100VOO("M->VOO_FRETE")
EndIf

If lSelOk
	lCanSel := .f.
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100SLPRC บAutor  ณ Takahashi          บ Data ณ  20/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Processa o carregamento de pecas/servicos dos tipos de     บฑฑ
ฑฑบ          ณ tempos selecionados                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100SLPRC()
Local nQtdSel  := 0
Local nIdx     := 1
Local nFor     := 1

Local nCntFor, nCntSel, nPos, aTamVlrBru
Local cAuxTESSrvc, cAuxTESVZ1
Local cAuxOS
Local cCodMar
Local cSQL
Local cAliasVO4 := "TVO4"

Local DSEQFEC    := FG_POSVAR("SEQFEC","aHVO3Det")

Local DVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Det")
Local DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")
Local DVO3QTDREQ := FG_POSVAR("VO3_QTDREQ","aHVO3Det")
Local DVO3CODTES := FG_POSVAR("VO3_CODTES","aHVO3Det")
Local DVO3VALPEC := FG_POSVAR("VO3_VALPEC","aHVO3Det")
Local DVO3PERDES := FG_POSVAR("VO3_PERDES","aHVO3Det")
Local DVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Det")
Local DVO3VALTOT := FG_POSVAR("VO3_VALTOT","aHVO3Det")
Local DVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Det")
Local DVO3ACRESC := FG_POSVAR("VO3_ACRESC","aHVO3Det")

Local RVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Res")
Local RVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Res")
Local RVO3DESGRU := FG_POSVAR("VO3_DESGRU","aHVO3Res")
Local RVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Res")
Local RVO3PERDES := FG_POSVAR("VO3_PERDES","aHVO3Res")
Local RVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Res")
Local RVO3VALTOT := FG_POSVAR("VO3_VALTOT","aHVO3Res")
Local RVO3ACRESC := FG_POSVAR("VO3_ACRESC","aHVO3Res")

Local DVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Det")
Local DVO4GRUSER := FG_POSVAR("VO4_GRUSER","aHVO4Det")
Local DVO4CODSER := FG_POSVAR("VO4_CODSER","aHVO4Det")
Local DVO4DESTPS := FG_POSVAR("VO4_DESTPS","aHVO4Det")
Local DVO4PERDES := FG_POSVAR("VO4_PERDES","aHVO4Det")
Local DVO4TEMPAD := FG_POSVAR("VO4_TEMPAD","aHVO4Det")
Local DVO4TEMTRA := FG_POSVAR("VO4_TEMTRA","aHVO4Det")
Local DVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Det")
Local DVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Det")
Local DVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Det")
Local DVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Det")

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local RVO4CODTES := FG_POSVAR("VO4_CODTES","aHVO4Res")
Local RVO4DESTPS := FG_POSVAR("VO4_DESTPS","aHVO4Res")
Local RVO4PERDES := FG_POSVAR("VO4_PERDES","aHVO4Res")
Local RVO4TEMPAD := FG_POSVAR("VO4_TEMPAD","aHVO4Res")
Local RVO4TEMTRA := FG_POSVAR("VO4_TEMTRA","aHVO4Res")
Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")
Local RVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Res")
Local RVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Res")
Local RVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Res")
Local RVO4PEDXML := FG_POSVAR("VO4_PEDXML","aHVO4Res")
Local RVO4ITEXML := FG_POSVAR("VO4_ITEXML","aHVO4Res")

Local RVO4CENCUS := FG_POSVAR("VO4_CENCUS","aHVO4Res")
Local RVO4CONTA  := FG_POSVAR("VO4_CONTA","aHVO4Res")
Local RVO4ITEMCT := FG_POSVAR("VO4_ITEMCT","aHVO4Res")
Local RVO4CLVL   := FG_POSVAR("VO4_CLVL","aHVO4Res")

Local aAuxCCS    := {}
Local nRecVZ1    := 0
Local nPosAux    := 0

oProcTTP:SetRegua1(4)

// Conta Quantos Itens da Listbox estao marcados ...
nCntSel := 0
aEval( aVetTTP, {|x| IIF( x[ATT_VETSEL] , nCntSel++ , NIL ) } )

// Limpa todas as variaveis e GetDados ...
OX100LIMPA()

// Posiciona no primeiro item selecionado para Inicializar o Fiscal
If ( nCntFor := aScan( aVetTTP , { |x| x[1] == .t. } ) ) <> 0
	// Incializa o Fiscal com o Cliente Selecionado
	If !OX100INIFIS(aVetTTP[nCntFor,ATT_CLIENTE] , aVetTTP[nCntFor,ATT_LOJA])
		Return(.f.)
	EndIf
Else
	Return(.f.)
EndIf

// Inicaliza as aCols de Pecas ...
oGetDetVO3:aCols := {}
aAuxVO3 := {}
// Inicaliza as aCols de Servicos ...
oGetDetVO4:aCols := {}
aAuxVO4 := {}
aAuxVO4Resumo := {}
// Inicializa as aCols de Parcelas ...
oGetVS9:aCols := {}
//

cAuxOS := ""
aAuxTipTem := {}
lGarPeca := .t.


// Faz Levantamento de Pecas e Servicos
oProcTTP:IncRegua1( STR0049 ) // "Levantando Pecas / Servicos ..."

oProcTTP:SetRegua2(nCntSel)
For nCntFor := 1 to Len(aVetTTP)
	
	// Procura o TTP Marcado para Fechamento
	If !aVetTTP[nCntFor,ATT_VETSEL]
		Loop
	EndIf
	//
	
	cAuxOS  += aVetTTP[nCntFor,ATT_NUMOSV] + "," // Contem Todas as OS's Selecionadas para Fechamento ...
	
	oProcTTP:IncRegua2( aVetTTP[nCntFor,ATT_NUMOSV])
	
	// Posiciona no Tipo de Tempo
	VOI->(DbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + aVetTTP[nCntFor,ATT_TIPTEM] ))
	//
	
	// Procura Negociacao
	OX100LNEG(aVetTTP[nCntFor,ATT_NUMOSV], aVetTTP[nCntFor,ATT_TIPTEM], aVetTTP[nCntFor,ATT_LIBVOO])
	// Levanta todas as pecas requisitadas de uma OS/Tipo de Tempo
	OX100PECA(aVetTTP[nCntFor,ATT_NUMOSV], aVetTTP[nCntFor,ATT_TIPTEM], aVetTTP[nCntFor,ATT_LIBVOO])
	// Levanta todos os servicos requisitados de uma OS/Tipo de Tempo
	OX100SRVC(aVetTTP[nCntFor,ATT_NUMOSV], aVetTTP[nCntFor,ATT_TIPTEM] , aVetTTP[nCntFor,ATT_LIBVOO])
	// Cria matriz com os TT Selecionados para Fechamento
	OX100TIPTEM( nCntFor , @aAuxTipTem , .f. )
	// Controla se ้ fechamento de tipo de tempo de garantia de peca...
	OX100GARPECA( nCntFor , cCodMar )
	//
	
Next nCntFor
cAuxOS := Left(cAuxOS,Len(cAuxOS) - 1 )

If Len(oGetVS9:aCols) == 0
	AADD(oGetVS9:aCols, Array(Len(aCVS9[1])) )
	oGetVS9:aCols[Len(oGetVS9:aCols)] := aClone(aCVS9[1])
EndIf

// ----------------------------------------------------- //
//                                                       //
//       T R A T A M E N T O    D E    P E C A S         //
//                                                       //
// ----------------------------------------------------- //
If nOrdListPeca == 1
	aSort( oGetDetVO3:aCols ,,,{|x,y| x[DVO3GRUITE] + x[DVO3CODITE] + x[DVO3CODTES] < y[DVO3GRUITE] + y[DVO3CODITE] + y[DVO3CODTES] })
Else
	aSort( oGetDetVO3:aCols ,,,{|x,y| x[DVO3CODITE] + x[DVO3CODTES] < y[DVO3CODITE] + y[DVO3CODTES] })
EndIf

If cUsaAcres == 'S' // Se trabalha com acr้scimo
	// Verifica se existe alguma peca com Acrescimo e Desconto ...
	For nCntFor := 1 to Len( oGetDetVO3:aCols )
		// Verifica se existe alguma peca com Acrescimo e Desconto ...
		If oGetDetVO3:aCols[nCntFor, DVO3VALDES ] <> 0 .and. oGetDetVO3:aCols[ nCntFor , DVO3ACRESC ] <> 0
			// Zera coluna de desconto da matriz aAuxVO3
			aEval(aAuxVO3,{ |x| IIf( x[AP_TIPTEM] == oGetDetVO3:aCols[ nCntFor , DVO3TIPTEM ] .and. x[AP_GRUITE] == oGetDetVO3:aCols[ nCntFor , DVO3GRUITE ] .and. x[AP_CODITE] == oGetDetVO3:aCols[ nCntFor , DVO3CODITE ] .and. x[AP_VALPECGET] == oGetDetVO3:aCols[ nCntFor , DVO3VALPEC ] , ( x[ AP_VALDES ] := 0 , x[ AP_PERDES ] := 0 ) , NIL ) })
			oGetDetVO3:aCols[nCntFor, DVO3VALDES ] := 0
			oGetDetVO3:aCols[nCntFor, DVO3VALTOT ] := ( oGetDetVO3:aCols[nCntFor, DVO3VALPEC] * oGetDetVO3:aCols[nCntFor,DVO3QTDREQ] ) + oGetDetVO3:aCols[nCntFor, DVO3ACRESC]
		EndIf
		//
		If oGetDetVO3:aCols[ nCntFor , DVO3ACRESC ] > 0 .and. ( nRest := OX100ModDec( oGetDetVO3:aCols[ nCntFor , DVO3ACRESC ] , oGetDetVO3:aCols[ nCntFor , DVO3QTDREQ ] ) ) > 0.0
			oGetDetVO3:aCols[nCntFor , DVO3ACRESC] -= nRest
			oGetDetVO3:aCols[nCntFor , DVO3VALTOT] := ( oGetDetVO3:aCols[nCntFor, DVO3VALPEC] * oGetDetVO3:aCols[nCntFor,DVO3QTDREQ] ) + oGetDetVO3:aCols[nCntFor, DVO3ACRESC]
			oGetDetVO3:aCols[nCntFor , DVO3VALBRU] := oGetDetVO3:aCols[nCntFor, DVO3VALTOT]
		EndIf
	Next nCntFor
	//
EndIf


// Recalcula os Valores e Percentuais de Descontos das Pecas - DETALHADO
oProcTTP:IncRegua1( STR0050 ) // "Calculando Descontos de Pecas ..."
oProcTTP:SetRegua2(Len(oGetDetVO3:aCols))
For nCntFor := 1 to Len(oGetDetVO3:aCols)
	
	oProcTTP:IncRegua2()
	
	oGetDetVO3:nAt := nCntFor
	FG_MEMVAR(oGetDetVO3:aHeader,oGetDetVO3:aCols,oGetDetVO3:nAt)
	
	// Calcula desconto por Valor
	If M->VO3_VALDES <> 0
		OX100DESC(2, @M->VO3_VALPEC, M->VO3_QTDREQ, @M->VO3_VALTOT, @M->VO3_PERDES, @M->VO3_VALDES )
		
		oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3VALDES ] := M->VO3_VALDES
		oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3VALTOT ] := M->VO3_VALTOT
		
		//
		M->VO3_PERDES := round( ( M->VO3_VALDES / ( M->VO3_VALTOT + M->VO3_VALDES ) ) * 100 , 2 ) // Calcular corretamente o Percentual de Desconto
		oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3PERDES ] := M->VO3_PERDES
		//
	EndIf
	
Next nCntFor
//

// Gera aCols com o Resumo das Pecas Levantadas
oGetResVO3:aCols := {}
For nCntFor := 1 to Len(oGetDetVO3:aCols)
	
	nPos := aScan( oGetResVO3:aCols, { |x| x[RVO3TIPTEM] == oGetDetVO3:aCols[nCntFor,DVO3TIPTEM] .and. x[RVO3GRUITE] == oGetDetVO3:aCols[nCntFor,DVO3GRUITE] } )
	
	// Cria linha em branco na aCols de Pecas Resumida
	If nPos == 0
		AADD( oGetResVO3:aCols, ARRAY( Len(aCVO3Res[1]) ) )
		nPos := Len(oGetResVO3:aCols)
		oGetResVO3:aCols[nPos] := aClone(aCVO3Res[1])
		
		oGetResVO3:aCols[nPos,RVO3TIPTEM] := oGetDetVO3:aCols[nCntFor,DVO3TIPTEM]
		oGetResVO3:aCols[nPos,RVO3GRUITE] := oGetDetVO3:aCols[nCntFor,DVO3GRUITE]
		oGetResVO3:aCols[nPos,RVO3DESGRU] := FM_SQL("SELECT BM_DESC FROM "+RetSQLName("SBM")+ " BM WHERE BM_FILIAL ='"+xFilial("SBM")+"' AND BM_GRUPO = '"+oGetDetVO3:aCols[nCntFor,DVO3GRUITE]+"' AND BM.D_E_L_E_T_=' '")
	Endif
	//
	
	oGetResVO3:aCols[nPos,RVO3VALBRU] += oGetDetVO3:aCols[nCntFor,DVO3VALBRU]
	oGetResVO3:aCols[nPos,RVO3VALDES] += oGetDetVO3:aCols[nCntFor,DVO3VALDES]
	oGetResVO3:aCols[nPos,RVO3VALTOT] += oGetDetVO3:aCols[nCntFor,DVO3VALTOT]
	
	If cUsaAcres == "S"
		oGetResVO3:aCols[nPos,RVO3ACRESC] += oGetDetVO3:aCols[nCntFor,DVO3ACRESC]
	EndIf
	
Next nCntFor
//

// Recalcula os Valores e Percentuais de Descontos das Pecas - RESUMO
For nCntFor := 1 to Len(oGetResVO3:aCols)
	
	If oGetResVO3:aCols[nCntFor, RVO3VALDES] == 0
		Loop
	EndIf
	
	oGetResVO3:nAt := nCntFor
	FG_MEMVAR(oGetResVO3:aHeader,oGetResVO3:aCols,oGetResVO3:nAt)
	
	If M->VO3_VALDES <> 0
		// Calcula desconto por Valor
		OX100DESC(2, oGetResVO3:aCols[oGetResVO3:nAt,RVO3VALBRU] , 1 , @oGetResVO3:aCols[oGetResVO3:nAt, RVO3VALTOT ], @oGetResVO3:aCols[oGetResVO3:nAt, RVO3PERDES ], @oGetResVO3:aCols[oGetResVO3:nAt, RVO3VALDES ] )
	EndIf
	
Next nCntFor
//

// ----------------------------------------------------- //
//                                                       //
//     T R A T A M E N T O    D E    S E R V I C O S     //
//                                                       //
// ----------------------------------------------------- //
aTamVlrBru := TamSX3("VO4_VALBRU")
aSort( aAuxVO4 ,,,{|x,y| x[AS_GRUSER]+x[AS_CODSER]+StrZero(x[AS_VALBRU],aTamVlrBru[1],aTamVlrBru[2]) < y[AS_GRUSER]+y[AS_CODSER]+StrZero(y[AS_VALBRU],aTamVlrBru[1],aTamVlrBru[2]) }) // Grupo + Codigo + Valor Bruto
aSort( oGetDetVO4:aCols ,,,{|x,y| x[DVO4GRUSER] + x[DVO4CODSER] + x[DVO4TIPSER] < y[DVO4GRUSER] + y[DVO4CODSER] + y[DVO4TIPSER] })

// Recalcula os Valores e Percentuais de Descontos dos Servicos - DETALHADO
oProcTTP:IncRegua1( STR0051 ) // "Calculando Descontos de Servicos ..."
oProcTTP:SetRegua2(Len(oGetDetVO4:aCols))
For nCntFor := 1 to Len(oGetDetVO4:aCols)
	
	oProcTTP:IncRegua2()
	
	If oGetDetVO4:aCols[nCntFor, DVO4VALDES ] == 0
		Loop
	EndIf
	
	oGetDetVO4:nAt := nCntFor
	FG_MEMVAR(oGetDetVO4:aHeader,oGetDetVO4:aCols,oGetDetVO4:nAt)
	M->VO4_VALBRU := oGetDetVO4:aCols[nCntFor, DVO4VALBRU ]
	
	// Calcula desconto por Valor
	OX100DESC(2, @M->VO4_VALBRU, 1 , @M->VO4_VALTOT, @M->VO4_PERDES, @M->VO4_VALDES )
	
	oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4PERDES ] := M->VO4_PERDES
	oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4VALDES ] := M->VO4_VALDES
	oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4VALTOT ] := M->VO4_VALTOT
	
Next nCntFor
//

// Gera aCols com o Resumo dos Servicos Levantados
nPos := aScan( aVetTTP , { |x| x[ATT_VETSEL] } )

oGetResVO4:aCols := {}
For nCntFor := 1 to Len(oGetDetVO4:aCols)
	
	nPos := aScan( oGetResVO4:aCols, { |x| x[RVO4TIPTEM] == oGetDetVO4:aCols[nCntFor,DVO4TIPTEM] .and. x[RVO4TIPSER] == oGetDetVO4:aCols[nCntFor,DVO4TIPSER] } )
	
	// Cria linha em branco na aCols de Servicos Resumida
	If nPos == 0
		AADD( oGetResVO4:aCols, ARRAY( Len(aCVO4Res[1]) ) )
		nPos := Len(oGetResVO4:aCols)
		oGetResVO4:aCols[nPos] := aClone(aCVO4Res[1])
		
		oGetResVO4:aCols[nPos,RVO4TIPTEM] := oGetDetVO4:aCols[nCntFor,DVO4TIPTEM]
		oGetResVO4:aCols[nPos,RVO4TIPSER] := oGetDetVO4:aCols[nCntFor,DVO4TIPSER]
		oGetResVO4:aCols[nPos,RVO4DESTPS] := oGetDetVO4:aCols[nCntFor,DVO4DESTPS]
		
		nPosAux := aScan( aAuxVO4 , { |x| ;
		x[AS_TIPTEM] == oGetDetVO4:aCols[nPos,DVO4TIPTEM] .and. ;
		x[AS_TIPSER] == oGetDetVO4:aCols[nPos,DVO4TIPSER] .and. ;
		x[AS_GRUSER] == oGetDetVO4:aCols[nPos,DVO4GRUSER] .and. ;
		x[AS_CODSER] == oGetDetVO4:aCols[nPos,DVO4CODSER] } )
		
		// Procura a TES de Servico da Negociacao Salva ...
		cAuxTESVZ1 := FM_SQL("SELECT VZ1_CODTES "+;
		"FROM " + RetSQLName("VZ1") + " VZ1 "+;
		"WHERE VZ1.VZ1_FILIAL = '" + xFilial("VZ1") + "' AND "+;
		"  VZ1.VZ1_NUMOSV IN " + FormatIN(cAuxOS,",") + " AND "+;
		"  VZ1.VZ1_TIPSER = '" + oGetDetVO4:aCols[nCntFor,DVO4TIPSER] + "' AND "+;
		"  VZ1.VZ1_LIBVOO = '" + aAuxVO4[nPosAux,AS_LIBVOO] + "' AND "+;
		"  VZ1.VZ1_PECSER = 'S' AND VZ1.D_E_L_E_T_ = ' '")
		If !Empty(cAuxTESVZ1)
			oGetResVO4:aCols[nPos,RVO4CODTES] := cAuxTESVZ1
		Else
			VOI->(DbSetOrder(1))
			VOI->(MsSeek(xFilial("VOI") + oGetDetVO4:aCols[nCntFor,DVO4TIPTEM] ))
			oGetResVO4:aCols[nPos,RVO4CODTES] := VOI->VOI_CODTES
		EndIf
		//
		
		If RVO4PEDXML > 0 .And. Empty(oGetResVO4:aCols[ nPos, RVO4PEDXML ])

			If Select(cAliasVO4) > 0
				(cAliasVO4)->(dbCloseArea())
			EndIf			
			
			cSQL := "SELECT VO4_PEDXML, VO4_ITEXML"
			cSQL += " FROM " + RetSQLName("VO4") + " VO4"
			cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
			cSQL +=   " AND VO4.VO4_NUMOSV = '" + aAuxVO4[nPosAux,AS_NUMOSV] + "'"
			cSQL +=   " AND VO4.VO4_TIPSER = '" + oGetDetVO4:aCols[nCntFor,DVO4TIPSER] + "'"
			cSQL +=   " AND VO4.VO4_TIPTEM = '" + oGetDetVO4:aCols[nCntFor,DVO4TIPTEM] + "'"
			cSQL +=   " AND VO4.VO4_LIBVOO = '" + aAuxVO4[nPosAux,AS_LIBVOO] + "'"
			cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVO4 , .F., .T. )

			If !(cAliasVO4)->(Eof())
				oGetResVO4:aCols[ nPos, RVO4PEDXML ] := (cAliasVO4)->(VO4_PEDXML)
				oGetResVO4:aCols[ nPos, RVO4ITEXML ] := (cAliasVO4)->(VO4_ITEXML)
			EndIf

			(cAliasVO4)->(dbCloseArea())
		EndIf

		If RVO4CENCUS <> 0 .and. RVO4CONTA <> 0 .and. RVO4ITEMCT <> 0 .and. RVO4CLVL <> 0
			nPosAux := aScan( aAuxVO4 , { |x| ;
			x[AS_TIPTEM] == oGetDetVO4:aCols[nCntFor,DVO4TIPTEM] .and. ;
			x[AS_TIPSER] == oGetDetVO4:aCols[nCntFor,DVO4TIPSER] .and. ;
			x[AS_GRUSER] == oGetDetVO4:aCols[nCntFor,DVO4GRUSER] .and. ;
			x[AS_CODSER] == oGetDetVO4:aCols[nCntFor,DVO4CODSER] } )
			If nPosAux <> 0
				oGetResVO4:aCols[ nPos , RVO4CENCUS ] := aAuxVO4[ nPosAux , AS_CENCUS ]
				oGetResVO4:aCols[ nPos , RVO4CONTA  ] := aAuxVO4[ nPosAux , AS_CONTA  ]
				oGetResVO4:aCols[ nPos , RVO4ITEMCT ] := aAuxVO4[ nPosAux , AS_ITEMCT ]
				oGetResVO4:aCols[ nPos , RVO4CLVL   ] := aAuxVO4[ nPosAux , AS_CLVL   ]
			EndIf
		EndIf
	Endif
	//
	
	oGetResVO4:aCols[nPos,RVO4TEMPAD] += oGetDetVO4:aCols[nCntFor,DVO4TEMPAD]
	oGetResVO4:aCols[nPos,RVO4TEMTRA] += oGetDetVO4:aCols[nCntFor,DVO4TEMTRA]
	oGetResVO4:aCols[nPos,RVO4VALBRU] += oGetDetVO4:aCols[nCntFor,DVO4VALBRU]
	oGetResVO4:aCols[nPos,RVO4VALDES] += oGetDetVO4:aCols[nCntFor,DVO4VALDES]
	oGetResVO4:aCols[nPos,RVO4VALTOT] += oGetDetVO4:aCols[nCntFor,DVO4VALTOT]
	
	If ExistBlock("OX100CCS") // PE utilizado para manipular o conteudo dos campos de Centro de Custo - Servi็os
		
		aAuxCCS := {}
		aAdd(aAuxCCS,{"VO4_CENCUS",oGetResVO4:aCols[ nPos , RVO4CENCUS ]}) // 1
		aAdd(aAuxCCS,{"VO4_CONTA" ,oGetResVO4:aCols[ nPos , RVO4CONTA  ]}) // 2
		aAdd(aAuxCCS,{"VO4_ITEMCT",oGetResVO4:aCols[ nPos , RVO4ITEMCT ]}) // 3
		aAdd(aAuxCCS,{"VO4_CLVL"  ,oGetResVO4:aCols[ nPos , RVO4CLVL   ]}) // 4
		
		aAuxCCS :=  ExecBlock("OX100CCS",.f.,.f.,{ oGetDetVO4:aCols[nCntFor,DVO4TIPTEM] , oGetDetVO4:aCols[nCntFor,DVO4TIPSER] , aAuxCCS })
		
		oGetResVO4:aCols[ nPos , RVO4CENCUS ] := aAuxCCS[01,02]
		oGetResVO4:aCols[ nPos , RVO4CONTA  ] := aAuxCCS[02,02]
		oGetResVO4:aCols[ nPos , RVO4ITEMCT ] := aAuxCCS[03,02]
		oGetResVO4:aCols[ nPos , RVO4CLVL   ] := aAuxCCS[04,02]
		
	EndIf
	
Next nCntFor
aSort( oGetResVO4:aCols ,,,{|x,y| x[RVO4TIPSER] < y[RVO4TIPSER] })
//

// Recalcula os Valores e Percentuais de Descontos RESUMO
For nCntFor := 1 to Len(oGetResVO4:aCols)
	
	If oGetResVO4:aCols[nCntFor, RVO4VALDES] == 0
		Loop
	EndIf
	
	oGetResVO4:nAt := nCntFor
	FG_MEMVAR(oGetResVO4:aHeader,oGetResVO4:aCols,oGetResVO4:nAt)
	
	// Calcula desconto por Valor
	OX100DESC(2, oGetResVO4:aCols[oGetResVO4:nAt,RVO4VALBRU] , 1 , @oGetResVO4:aCols[oGetResVO4:nAt, RVO4VALTOT ], @oGetResVO4:aCols[oGetResVO4:nAt, RVO4PERDES ], @oGetResVO4:aCols[oGetResVO4:nAt, RVO4VALDES ] )
	
Next nCntFor
//

// Atualiza Fiscal com Todos as Pecas e Servicos
oProcTTP:IncRegua1( STR0052 ) // "Atualizando Fiscal ..."

n := 0
aNPecaFis := {}
aNSrvcFis := {}
nTotFis   := 0

SB1->(DBSetOrder(7))
SF4->(DBSetOrder(1))

oProcTTP:SetRegua2( (Len(oGetDetVO3:aCols) * 2 )+Len(oGetResVO4:aCols))
For nCntFor := 1 to Len(oGetDetVO3:aCols)
	
	oProcTTP:IncRegua2( oGetDetVO3:aCols[nCntFor,DVO3GRUITE] + "-" + oGetDetVO3:aCols[nCntFor,DVO3CODITE] )
	
	// Controle Interno do Fiscal
	OX100PECFIS(nCntFor)
	//
	
	DBSelectArea("SB1")
	SB1->(DBSeek(xFilial("SB1")+oGetDetVO3:aCols[nCntFor,DVO3GRUITE] + oGetDetVO3:aCols[nCntFor,DVO3CODITE]))
	
	SF4->(MsSeek(xFilial("SF4")+oGetDetVO3:aCols[nCntFor,DVO3CODTES]))
	
	MaFisIniLoad(n,{SB1->B1_COD,;
	oGetDetVO3:aCols[nCntFor,DVO3CODTES],;
	" "  ,;
	oGetDetVO3:aCols[nCntFor,DVO3QTDREQ],;
	"",;
	"",;
	SB1->(RecNo()),;  //IT_RECNOSB1
	SF4->(RecNo()),;  //IT_RECNOSF4
	0 })        //IT_RECORI
	
	MaFisLoad("IT_PRODUTO"  , SB1->B1_COD,n)
	MaFisLoad("IT_QUANT"    , oGetDetVO3:aCols[nCntFor,DVO3QTDREQ] ,n)
	MaFisLoad("IT_TES"      , oGetDetVO3:aCols[nCntFor,DVO3CODTES] ,n)
	MaFisLoad("IT_PRCUNI"   , oGetDetVO3:aCols[nCntFor,DVO3VALPEC] + ( (IIF(cUsaAcres == 'S', oGetDetVO3:aCols[nCntFor,DVO3ACRESC], 0) / oGetDetVO3:aCols[nCntFor,DVO3QTDREQ]) ) ,n)
	MaFisLoad("IT_VALMERC"  , Round( (oGetDetVO3:aCols[nCntFor,DVO3QTDREQ] * oGetDetVO3:aCols[nCntFor,DVO3VALPEC] ) + IIF(cUsaAcres == 'S', oGetDetVO3:aCols[nCntFor,DVO3ACRESC], 0) ,2),n)
	MaFisLoad("IT_DESCONTO" , oGetDetVO3:aCols[nCntFor,DVO3VALDES],n)
	MaFisRecal("",n)
	MaFisEndLoad(n,1)
	
Next nCntFor
SB1->(DBSetOrder(1))

VOK->(dbSetOrder(1))
SB1->(DBSetOrder(7))
For nCntFor := 1 to Len(oGetResVO4:aCols)
	
	oProcTTP:IncRegua2( oGetResVO4:aCols[nCntFor,RVO4TIPSER] + "-" + oGetResVO4:aCols[nCntFor,RVO4DESTPS] )
	
	// Controle Interno do Fiscal
	OX100SRVFIS(nCntFor)
	//
	
	IF !VOK->(dbSeek(xFilial("VOK") + oGetResVO4:aCols[nCntFor,RVO4TIPSER] ))
		OX100FILTRO()
		Return(.f.)
	ENDIF
	
	DBSelectArea("SB1")
	SB1->(DBSeek(xFilial("SB1")+ VOK->VOK_GRUITE + VOK->VOK_CODITE ))
	
	// Verifica se o produto esta bloqueado ...
	If SB1->B1_MSBLQL == "1"
		HELP(" ",1,"REGBLOQ",,"SB1",3,1)
		OX100FILTRO()
		Return(.f.)
	EndIf
	//
	
	SF4->(MsSeek(xFilial("SF4")+oGetResVO4:aCols[nCntFor,RVO4CODTES]))
	
	MaFisIniLoad(n,{SB1->B1_COD,;
	oGetResVO4:aCols[nCntFor,RVO4CODTES],;
	" "  ,;
	1,; // Quantidade
	"",;
	"",;
	SB1->(RecNo()),;  //IT_RECNOSB1
	SF4->(RecNo()),;  //IT_RECNOSF4
	0 })        //IT_RECORI
	
	MaFisLoad("IT_PRODUTO"  ,SB1->B1_COD,n)
	MaFisLoad("IT_QUANT"  ,1,n)
	MaFisLoad("IT_TES"    ,oGetResVO4:aCols[nCntFor,RVO4CODTES],n)
	MaFisLoad("IT_PRCUNI" ,oGetResVO4:aCols[nCntFor,RVO4VALBRU],n)
	MaFisLoad("IT_VALMERC"  ,oGetResVO4:aCols[nCntFor,RVO4VALBRU],n)
	MaFisLoad("IT_DESCONTO" ,oGetResVO4:aCols[nCntFor,RVO4VALDES],n)
	MaFisRecal("",n)
	MaFisEndLoad(n,1)
	
	AADD( aAuxVO4Resumo , { n , MaFisRet(n,"IT_ALIQISS") })
	
Next nCntFor
SB1->(DBSetOrder(1))
//

// Acerta coluna de Percentual de Rateio das Matrizes Auxiliares (VO3 e VO4)
OX100PAVO3()
OX100PAVO4()
//

MaFisRef("NF_DESPESA",,M->VOO_DESACE)
If VOO->(FieldPos("VOO_FRETE")) > 0
	MaFisRef("NF_FRETE"  ,,M->VOO_FRETE)
	MaFisRef("NF_SEGURO" ,,M->VOO_SEGURO)
EndIf

M->VOO_NATPEC := space( GeTSX3Cache("VOO_NATPEC","X3_TAMANHO") )
M->VOO_NATSRV := space( GeTSX3Cache("VOO_NATSRV","X3_TAMANHO") )
// Usado para preencher a natureza de peca e servi็o
For nIdx := 1 To Len(aVetTTP)
	VOI->(dbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + aVetTTP[nIdx, ATT_TIPTEM]))
	If aVetTTP[nIdx, ATT_TOTPEC] > 0 .AND. Empty(M->VOO_NATPEC)
		M->VOO_NATPEC := VOI->VOI_NATPEC
	EndIf
	If aVetTTP[nIdx, ATT_TOTSER] > 0  .AND. Empty(M->VOO_NATSRV)
		M->VOO_NATSRV := VOI->VOI_NATSRV
	EndIf
Next
If !Empty(M->VOO_NATPEC) // Setar a Natureza de Pe็as caso estiver preenchida
	MaFisRef("NF_NATUREZA",,M->VOO_NATPEC)
ElseIf !Empty(M->VOO_NATSRV)
	MaFisRef("NF_NATUREZA",,M->VOO_NATSRV)
EndIf

// Inicializa do campo RECISS
If VOO->(FieldPos("VOO_RECISS")) <> 0
	If Empty(M->VOO_RECISS) .and. SA1->(FieldPos("A1_RECISS")) <> 0
		M->VOO_RECISS := SA1->A1_RECISS
	EndIf
	OX100VOO("M->VOO_RECISS")
EndIf
If VOO->(FieldPos("VOO_TIPOCL")) <> 0 .and. !Empty(M->VOO_TIPOCL)
	OX100VOO("M->VOO_TIPOCL")
EndIf
If VOO->(FieldPos("VOO_TPFRET")) <> 0 .and. !Empty(M->VOO_TPFRET)
	OX100VOO("M->VOO_TPFRET")
EndIf
If VOO->(FieldPos("VOO_ALIISS")) <> 0 .and. M->VOO_ALIISS > 0
	OX100VOO("M->VOO_ALIISS")
EndIf

// Incializa o campo de condicao de pagamento (PERIODICO)
If Empty(M->VOO_CONDPG)
	// Se nใo hแ Negocia็ใo salva, retornar a condi็ใo informada no Or็amento
	For nFor := 1 to Len(aAuxTipTem)
		cQuery := "SELECT VS1_FORPAG                                           "
		cQuery += "FROM " + RetSQLName("VS1") + "                              "
		cQuery += "WHERE VS1_FILIAL  = '" + xFilial("VS1") + "'                "
		cQuery += "  AND VS1_FORPAG <> ' '                                     "
		cQuery += "  AND VS1_NUMOSV  = '" + aAuxTipTem[nFor, FTT_NUMOSV] + "'  "
		cQuery += "  AND (VS1_TIPTEM = '" + aAuxTipTem[nFor, FTT_TIPTEM] + "'  "
		cQuery += "  OR VS1_TIPTSV   = '" + aAuxTipTem[nFor, FTT_TIPTEM] + "') "
		cQuery += "  AND D_E_L_E_T_  = ' '                                     "
		M->VOO_CONDPG := FM_SQL(cQuery)

		If !Empty(M->VOO_CONDPG)
			Exit
		EndIf
	Next

	// Se nใo foi informada condi็ใo no Or็amento, retornar a condi็ใo informada no cadastro do Cliente
	If Empty(M->VOO_CONDPG)
		M->VOO_CONDPG := SA1->A1_COND
	EndIf
EndIf

nQtdSel := len(oGetDetVO3:aCols)+len(oGetDetVO4:aCols)

// Se nao tiver peca, cria uma linha em branco na aCols
If Len(oGetDetVO3:aCols) == 0
	AADD( oGetResVO3:aCols, ARRAY( Len(aCVO3Res[1]) ) )
	oGetResVO3:aCols[Len(oGetResVO3:aCols)] := aClone(aCVO3Res[1])
	AADD( oGetDetVO3:aCols, ARRAY( Len(aCVO3Det[1]) ) )
	oGetDetVO3:aCols[Len(oGetDetVO3:aCols)] := aClone(aCVO3Det[1])
EndIf
// Se nao tiver servico, cria uma linha em branco na aCols
If Len(oGetDetVO4:aCols) == 0
	AADD( oGetResVO4:aCols, ARRAY( Len(aCVO4Res[1]) ) )
	oGetResVO4:aCols[Len(oGetResVO4:aCols)] := aClone(aCVO4Res[1])
	AADD( oGetDetVO4:aCols, ARRAY( Len(aCVO4Det[1]) ) )
	oGetDetVO4:aCols[Len(oGetDetVO4:aCols)] := aClone(aCVO4Det[1])
EndIf
//

// Atualiza Resumo
OX100ATRES(.f.)

// Fechamento de OS de Seguradora, aplica o desconto da franquia
// Posiciona pela primeira linha da matriz, pq nao sera permitido ter mais de um TT quando for fechamento de seguradora ...
nPos := AScan( aVetTTP , { |x| x[ATT_VETSEL] == .t. } )
VOI->(dbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + aVetTTP[nPos,ATT_TIPTEM]))
If VOI->VOI_SEGURO == "1" // Tipo de Tempo de Seguradora ...
	OX100DFRAN(aVetTTP[nPos,ATT_NUMOSV],aVetTTP[nPos,ATT_TIPTEM])
EndIf
//

// Se tiver condicao de pagamento informada, simular o FieldOK
If !Empty(M->VOO_CONDPG)
	OX100VOO("M->VOO_CONDPG", .f.)
EndIf
//

oGetResVO3:nAt := 1
oGetResVO3:oBrowse:Refresh()
oGetDetVO3:nAt := 1
oGetDetVO3:oBrowse:Refresh()
oGetResVO4:nAt := 1
oGetResVO4:oBrowse:Refresh()
oGetDetVO4:nAt := 1
oGetDetVO4:oBrowse:Refresh()
oGetVS9:nAt := 1
oGetVS9:oBrowse:Refresh()
oEnchVOO:Refresh()

// Verifica se a qtde de Itens eh maior que qtde permitida por NF
If nQtdSel > nQtdINF
	MsgAlert(STR0138+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
	STR0139+": "+Alltrim(str(nQtdSel))+" "+STR0140+CHR(13)+CHR(10)+;
	STR0141+" MV_NUMITEN: "+Alltrim(str(nQtdINF))+" "+STR0140,STR0004) // Quantidade selecionada de itens ้ maior que a quantidade permitida na NF. / Selecionados / itens / Parametro / itens / Atencao
	OX100CSEL()
	Return(.f.)
EndIf

For nFor := 1 To Len(oGetDetVO3:aCols)
	// Linha em branco ...
	If Len(oGetDetVO3:aCols) == 1 .and. Empty(oGetDetVO3:aCols[nFor,DVO3TIPTEM])
		Loop
	EndIf
	//
	oProcTTP:IncRegua2( oGetDetVO3:aCols[nFor,DVO3GRUITE] + "-" + oGetDetVO3:aCols[nFor,DVO3CODITE] )
	//
	oGetDetVO3:nAt := nFor
	//
	nPosAux := aScan( aAuxVO3, { |x| x[AP_SEQFEC] == oGetDetVO3:aCols[oGetDetVO3:nAt][DSEQFEC] } )
	If nPosAux > 0
		nRecVZ1 := OX100VZ1( ;
									aAuxVO3[nPosAux, AP_NUMOSV ] ,;
									aAuxVO3[nPosAux, AP_TIPTEM ] ,;
									aAuxVO3[nPosAux, AP_GRUITE ] ,;
									aAuxVO3[nPosAux, AP_CODITE ] ,;
									aAuxVO3[nPosAux, AP_LIBVOO ] ,;
									aAuxVO3[nPosAux, AP_FORMUL ] ,;
									oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3VALPEC ] ,;
									.F.)
		If nRecVZ1 == 0 // Se NAO existir VZ1
			FG_MEMVAR( oGetDetVO3:aHeader, oGetDetVO3:aCols, oGetDetVO3:nAt )
			OX100UPDMrg((nFor == Len(oGetDetVO3:aCols))) // Chama calculo de % da Margem de Lucro Oficina
		EndIf
	EndIf

Next

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100PAVO3 บAutor  ณ Takahashi          บ Data ณ  02/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Acerta coluna de percentual de rateio da peca em relacao aoบฑฑ
ฑฑบ          ณ total da peca. Percentual ้ necessario pois em fechamento  บฑฑ
ฑฑบ          ณ agrupado, pode repetir a peca                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100PAVO3()

Local nCntFor, nPosGET, nBkpN, nITTotal, nITBasDupl, nItemPerc

Local DVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Det")
Local DVO3CODTES := FG_POSVAR("VO3_CODTES","aHVO3Det")
Local DVO3ACRESC := FG_POSVAR("VO3_ACRESC","aHVO3Det")

nBkpN := n

For nCntFor := 1 to Len(aAuxVO3)
	
	// Procura a Posicao da GetDados que contem os dados do Fechamento
	If ( nPosGet := OX100POSPECA( aAuxVO3[nCntFor,AP_SEQFEC] )) == 0
		Loop
	EndIf
	
	// Procura valor total do Fiscal ...
	OX100PECFIS( nPosGET )
	nITTotal   := MaFisRet(n,"IT_TOTAL")
	nITBasDupl := MaFisRet(n,"IT_BASEDUP")
	
	// Percentual da Peca em Relacao ao Total da Mesma Peca (Valor Bruto)
	nItemPerc := aAuxVO3[nCntFor,AP_PERCENT] := ( aAuxVO3[nCntFor, AP_VALBRU ] / ( oGetDetVO3:aCols[nPosGet, DVO3VALBRU] - IIf(cUsaAcres == 'S',oGetDetVO3:aCols[nPosGet, DVO3ACRESC],0) ) )
	
	// Valor Total Rateado (IT_TOTAL)
	aAuxVO3[nCntFor,AP_ITTOTFISC] := ( nITTotal * nItemPerc )
	
	// Valor de Base da Duplicata Rateada (IT_BASEDUP)
	aAuxVO3[nCntFor,AP_ITBASEDUP] := ( nITBasDupl * nItemPerc )
	
	// Matriz com campos fiscais das pecas rateado
	aAuxVO3[nCntFor,AP_ITFISCAL] := {  ( ( MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2") ) * nItemPerc ) ,;		// Pis
	( ( MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2") ) * nItemPerc ) ,;	// Cofins
	( MaFisRet(n,"IT_VALICM") * nItemPerc ) ,;									// ICMS
	( MaFisRet(n,"IT_VALSOL") * nItemPerc ) }									// ICMS Solidario
	
	// TES da Peca
	aAuxVO3[nCntFor,AP_ITTES] := oGetDetVO3:aCols[nPosGet,DVO3CODTES]
	
Next nCntFor

n := nBkpN

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100PAVO4 บAutor  ณ Takahashi          บ Data ณ  02/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Acerta coluna de percentual de rateio do servico em relacaoบฑฑ
ฑฑบ          ณ ao total por tipo de servico de cada OS. Percentual ้      บฑฑ
ฑฑบ          ณ utilizado na geracao do VSC                                บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบParametrosณ cTipSer = Tipo de Servico a ser atualizado                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100PAVO4(cTipTem, cTipSer)

Local nCntFor, nPosGET, nBkpN, nITTotal, nITBasDupl

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")
Local RVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Res")
Local RVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Res")

Default cTipTem := ""
Default cTipSer := ""

nBkpN := n
For nCntFor := 1 to Len(aAuxVO4)
	
	If !Empty(cTipSer) .and. aAuxVO4[nCntFor,AS_TIPSER] <> cTipSer
		Loop
	EndIf
	
	nPosGET := aScan( oGetResVO4:aCols , { |x| x[RVO4TIPTEM] == aAuxVO4[nCntFor,AS_TIPTEM] .and. x[RVO4TIPSER] == aAuxVO4[nCntFor,AS_TIPSER] } )
	
	// Percentual do Servico em Relacao ao Total do Tipo de Servico (Valor Bruto)
	aAuxVO4[nCntFor, AS_PERCVLB] := aAuxVO4[nCntFor,AS_VALBRU] / oGetResVO4:aCols[nPosGET, RVO4VALBRU]
	// Percentual do Servico em Relacao ao Total do Tipo de Servico (Valor Liquido)
	aAuxVO4[nCntFor, AS_PERCVLL] := (aAuxVO4[nCntFor,AS_VALBRU]-aAuxVO4[nCntFor,AS_VALDES]) / oGetResVO4:aCols[nPosGET, RVO4VALTOT]
	
	// Procura valor total do Fiscal ...
	OX100SRVFIS( nPosGET ) // Set o N para a Posicao Correspondente no Fiscal
	nITTotal   := MaFisRet(n,"IT_TOTAL")
	nITBasDupl := MaFisRet(n,"IT_BASEDUP")
	//
	
	// Valor Total Rateado (IT_TOTAL)
	aAuxVO4[nCntFor, AS_ITTOTFISC] := nITTotal * aAuxVO4[nCntFor, AS_PERCVLB]
	
	// Valor de Base da Duplicata Rateada (IT_BASEDUP)
	aAuxVO4[nCntFor, AS_ITBASEDUP] := nITBasDupl * aAuxVO4[nCntFor, AS_PERCVLB]
	
	// Calcula o tempo cobrado, considerando o desconto
	// Tempo para Calculo - 1=Fabrica / 2=Concessionaria / 4=Informado
	If aAuxVO4[nCntFor,AS_INCTEM] $ "124" .and. aAuxVO4[nCntFor,AS_TEMPAD] <> 0
		aAuxVO4[nCntFor,AS_TEMCOB] := Round(aAuxVO4[nCntFor,AS_TEMPAD] * (1 - (aAuxVO4[nCntFor,AS_VALDES] / aAuxVO4[nCntFor,AS_VALBRU])),0)
	EndIf
	//
	
Next nCntFor
n := nBkpN

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100PECA  บAutor  ณ Takahashi          บ Data ณ  15/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Faz o Levantamento das Pecas do TT a ser Fechado           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100PECA(cNumOS, cTipTem, cLibVOO)

Local aAuxValPec := {}
Local nCntFor := 0
Local nPosAux := 0

Local lAtuVal := .f.
Local nTotalPeca := 0
Local nPos
Local nRecPecMov := 0

Local DVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Det")
Local DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")
Local DVO3DESITE := FG_POSVAR("VO3_DESITE","aHVO3Det")
Local DVO3QTDREQ := FG_POSVAR("VO3_QTDREQ","aHVO3Det")
Local DVO3CODTES := FG_POSVAR("VO3_CODTES","aHVO3Det")
Local DVO3VALPEC := FG_POSVAR("VO3_VALPEC","aHVO3Det")
Local DVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Det")
Local DVO3PERDES := FG_POSVAR("VO3_PERDES","aHVO3Det")
Local DVO3VALTOT := FG_POSVAR("VO3_VALTOT","aHVO3Det")
Local DVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Det")
Local DVO3OPER   := FG_POSVAR("VO3_OPER"  ,"aHVO3Det")
Local DVO3CENCUS := FG_POSVAR("VO3_CENCUS","aHVO3Det")
Local DVO3CONTA  := FG_POSVAR("VO3_CONTA","aHVO3Det")
Local DVO3ITEMCT := FG_POSVAR("VO3_ITEMCT","aHVO3Det")
Local DVO3CLVL   := FG_POSVAR("VO3_CLVL","aHVO3Det")
Local DVO3PEDXML := FG_POSVAR("VO3_PEDXML","aHVO3Det")
Local DVO3ITEXML := FG_POSVAR("VO3_ITEXML","aHVO3Det")
Local DVO3ACRESC := FG_POSVAR("VO3_ACRESC","aHVO3Det")
Local DVO3LOTECT := FG_POSVAR("VO3_LOTECT","aHVO3Det")
Local DVO3NUMLOT := FG_POSVAR("VO3_NUMLOT","aHVO3Det")
Local DVO3MARLUC := FG_POSVAR("VO3_MARLUC","aHVO3Det")
Local DSEQFEC    := FG_POSVAR("SEQFEC","aHVO3Det")

Local aAuxCCP    := {}

Local aVO3DPec := {}
Local nCntAux  := 0

aBoqPec := {}

// Calcula o valor de todas as pecas da OS e TT Informados ...
aAuxValPec := FMX_CALPEC( cNumOS,;
cTipTem, ;
/* cGruIte*/ ,;
/* cCodIte */ ,;
.t. /* lMov */ ,;
.t. /* lNegoc */ ,;
.t. /* lReqZerada */ ,;
.f. /* lRetAbe */ ,;
.t. /* lRetLib */ ,;
.f. /* lRetFec */ ,;
.f. /* lRetCan */ ,;
cLibVOO ,;
,;
,;
.f. )
VOI->(dbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + cTipTem ) )

lAtuVal := (VOI->VOI_VLPCAC == "2") // Verifica se considera valor de peca atual

For nCntFor := 1 to Len(aAuxValPec)
	
	SB1->(DbSetOrder(7))
	SB1->(DbSeek(xFilial("SB1") + aAuxValPec[nCntFor,01] + aAuxValPec[nCntFor,02] ))
	SB1->(DbSetOrder(1))
	
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + VOI->VOI_CODALM ))
	
	If BlqInvent( SB1->B1_COD, SB2->B2_LOCAL)
		MsgInfo(STR0151+SB1->B1_COD +" - "+ SB1->B1_DESC +STR0152,STR0004)
	Endif
	
	// Verifica se ja existe o produto na aCols
	nPos := aScan( oGetDetVO3:aCols , { |x| x[DVO3TIPTEM] == aAuxValPec[nCntFor,03] .and.;
	x[DVO3GRUITE] == aAuxValPec[nCntFor,01] .and.;
	x[DVO3CODITE] == aAuxValPec[nCntFor,02] .and.;
	x[DVO3CODTES] == aAuxValPec[nCntFor,PECA_TES] .and.;
	x[DVO3VALPEC] == aAuxValPec[nCntFor,06] .and.;
	( !lCtrlLote .or. (x[DVO3LOTECT] == aAuxValPec[nCntFor,PECA_LOTECT] .and. x[DVO3NUMLOT] == aAuxValPec[nCntFor,PECA_NUMLOT] )) } )
	IF nPos == 0
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Cria uma linha em branco na aCols ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AADD( oGetDetVO3:aCols, Array( Len(aCVO3Det[1])) )
		nPos := Len(oGetDetVO3:aCols)
		oGetDetVO3:aCols[nPos] := aClone(aCVO3Det[1])
		//
		oGetDetVO3:aCols[nPos, DVO3TIPTEM ] := aAuxValPec[nCntFor,03]
		oGetDetVO3:aCols[nPos, DVO3GRUITE ] := aAuxValPec[nCntFor,01]
		oGetDetVO3:aCols[nPos, DVO3CODITE ] := aAuxValPec[nCntFor,02]
		oGetDetVO3:aCols[nPos, DVO3DESITE ] := aAuxValPec[nCntFor,13]
		oGetDetVO3:aCols[nPos, DVO3CODTES ] := aAuxValPec[nCntFor,PECA_TES]
		If lCtrlLote
			oGetDetVO3:aCols[nPos, DVO3LOTECT ] := aAuxValPec[nCntFor,PECA_LOTECT]
			oGetDetVO3:aCols[nPos, DVO3NUMLOT ] := aAuxValPec[nCntFor,PECA_NUMLOT]
		EndIf
		If Len(aAuxValPec[nCntFor]) > 24
			oGetDetVO3:aCols[nPos, DVO3OPER   ] := aAuxValPec[nCntFor,PECA_OPER]
		EndIf
		
		If DVO3CENCUS <> 0 .and. DVO3CONTA <> 0 .and. DVO3ITEMCT <> 0 .and. DVO3CLVL <> 0
			oGetDetVO3:aCols[nPos, DVO3CENCUS ] := aAuxValPec[nCntFor,PECA_CENCUS]
			oGetDetVO3:aCols[nPos, DVO3CONTA ]  := aAuxValPec[nCntFor,PECA_CONTA]
			oGetDetVO3:aCols[nPos, DVO3ITEMCT ] := aAuxValPec[nCntFor,PECA_ITEMCTA]
			oGetDetVO3:aCols[nPos, DVO3CLVL ]   := aAuxValPec[nCntFor,PECA_CLVL]
		EndIf
		
		If DVO3MARLUC <> 0
			oGetDetVO3:aCols[nPos, DVO3MARLUC ] := aAuxValPec[nCntFor,PECA_MARLUC]
		EndIf
		
		oGetDetVO3:aCols[ nPos, DSEQFEC] := nPos
		
	EndIf
	//
	
	oGetDetVO3:aCols[nPos, DVO3QTDREQ ] += aAuxValPec[nCntFor,05]
	oGetDetVO3:aCols[nPos, DVO3VALPEC ] := aAuxValPec[nCntFor,09]
	oGetDetVO3:aCols[nPos, DVO3VALDES ] += aAuxValPec[nCntFor,07]
	If cUsaAcres == 'S'
		oGetDetVO3:aCols[nPos, DVO3ACRESC ] += aAuxValPec[nCntFor, 35]
	EndIf
	
	oGetDetVO3:aCols[nPos, DVO3VALBRU ] := Round((oGetDetVO3:aCols[nPos, DVO3QTDREQ ] *  oGetDetVO3:aCols[nPos, DVO3VALPEC ]) + IIf( cUsaAcres == 'S' , oGetDetVO3:aCols[nPos, DVO3ACRESC ] , 0 ),2)
	oGetDetVO3:aCols[nPos, DVO3VALTOT ] := oGetDetVO3:aCols[nPos, DVO3VALBRU ]
	
	If DVO3PEDXML > 0
		VO3->(DbGoTo(aAuxValPec[nCntFor,14,1,5]))
		oGetDetVO3:aCols[nPos, DVO3PEDXML ] := VO3->VO3_PEDXML
		oGetDetVO3:aCols[nPos, DVO3ITEXML ] := VO3->VO3_ITEXML
	EndIf
	
	If ExistBlock("OX100CCP") // PE utilizado para manipular o conteudo dos campos de Centro de Custo - Pe็as
		
		aAuxCCP := {}
		aAdd(aAuxCCP,{"VO3_CENCUS",oGetDetVO3:aCols[nPos, DVO3CENCUS ]}) // 1
		aAdd(aAuxCCP,{"VO3_CONTA" ,oGetDetVO3:aCols[nPos, DVO3CONTA  ]}) // 2
		aAdd(aAuxCCP,{"VO3_ITEMCT",oGetDetVO3:aCols[nPos, DVO3ITEMCT ]}) // 3
		aAdd(aAuxCCP,{"VO3_CLVL"  ,oGetDetVO3:aCols[nPos, DVO3CLVL   ]}) // 4
		
		aAuxCCP :=  ExecBlock("OX100CCP",.f.,.f.,{ cTipTem, oGetDetVO3:aCols[nPos, DVO3GRUITE ] , oGetDetVO3:aCols[nPos, DVO3CODITE ] , aAuxCCP, cNumOS })
		
		oGetDetVO3:aCols[nPos, DVO3CENCUS ] := aAuxCCP[01,02]
		oGetDetVO3:aCols[nPos, DVO3CONTA  ] := aAuxCCP[02,02]
		oGetDetVO3:aCols[nPos, DVO3ITEMCT ] := aAuxCCP[03,02]
		oGetDetVO3:aCols[nPos, DVO3CLVL   ] := aAuxCCP[04,02]
		
	EndIf
	
	// Cria matriz auxiliar que sera utilizado na gravacao da negociacao ...
	AADD( aAuxVO3, Array(26) )
	nPosAux := Len( aAuxVO3 )
	aAuxVO3[nPosAux, AP_NUMOSV     ] := cNumOS							// 01 - Numero da OS
	aAuxVO3[nPosAux, AP_GRUITE     ] := aAuxValPec[nCntFor,01]			// 02 - Grupo do Item
	aAuxVO3[nPosAux, AP_CODITE     ] := aAuxValPec[nCntFor,02]			// 03 - Codigo do Item
	aAuxVO3[nPosAux, AP_VALPECREQ  ] := aAuxValPec[nCntFor,06]			// 04 - Valor do Item Gravado na VO3
	aAuxVO3[nPosAux, AP_VALPECGET  ] := aAuxValPec[nCntFor,09]			// 05 - Valor do Item no Fechamento (Pode ser diferente do VO3 dependendo do Tipo de Tempo )
	aAuxVO3[nPosAux, AP_TIPTEM     ] := aAuxValPec[nCntFor,03]			// 06 - Tipo de Tempo
	aAuxVO3[nPosAux, AP_QTDREQ     ] := aAuxValPec[nCntFor,05]			// 07 - Qtde da Peca Requisitada
	aAuxVO3[nPosAux, AP_VALBRU     ] := Round( aAuxValPec[nCntFor,05] * aAuxValPec[nCntFor,09] ,2)	// 08 - Valor Bruto Total do Item
	aAuxVO3[nPosAux, AP_PERCENT    ] := 0								// 09 - Percentual da Peca em Relacao ao Total de Pecas (Valor Bruto) (Fechamento Agrupado)
	aAuxVO3[nPosAux, AP_ITTOTFISC  ] := 0								// 10 - Total Fiscal (IT_TOTAL) jแ Rateado ...
	aAuxVO3[nPosAux, AP_DEPINT     ] := aAuxValPec[nCntFor,11]			// 11 - Departamento Interno
	aAuxVO3[nPosAux, AP_DEGGAR     ] := aAuxValPec[nCntFor,12]			// 12 - Departamento Garantia
	aAuxVO3[nPosAux, AP_PERDES     ] := aAuxValPec[nCntFor,08]			// 13 - Percentual de Desconto
	aAuxVO3[nPosAux, AP_VALDES     ] := aAuxValPec[nCntFor,07]			// 14 - Valor do Desconto
	aAuxVO3[nPosAux, AP_ITBASEDUP  ] := 0								// 15 - Valor Base Duplicata do Item ja Rateado
	aAuxVO3[nPosAux, AP_LIBVOO     ] := aAuxValPec[nCntFor,25]			// 16 - Numero da Liberacao (VOO_LIBVOO)
	If lFORMUL
		aAuxVO3[nPosAux, AP_FORMUL ] := aAuxValPec[nCntFor,27]			// 17 - Formula da Peca (VO3_FORMUL)
	Else
		aAuxVO3[nPosAux, AP_FORMUL ] := ""								// 17 - Formula da Peca (VO3_FORMUL)
	EndIf
	aAuxVO3[nPosAux, AP_MOV        ] := aAuxValPec[nCntFor,PECA_MOV]	// 18 - Matriz com movimentacoes das pecas ...
	aAuxVO3[nPosAux, AP_VALCUS     ] := SB2->B2_CM1						// 19 - Valor do Custo da Peca
	aAuxVO3[nPosAux, AP_ITFISCAL   ] := {}								// 20 - Matriz com campos fiscais das pecas rateado
	aAuxVO3[nPosAux, AP_ITTES      ] := aAuxValPec[nCntFor,PECA_TES]	// 21 - TES da Peca
	aAuxVO3[nPosAux, AP_ACRESC     ] := aAuxValPec[nCntFor,PECA_ACRESC]	// 22 - Valor do Acrescimo
	aAuxVO3[nPosAux, AP_LOTECT     ] := IIf( lCtrlLote , aAuxValPec[nCntFor,PECA_LOTECT] , "" )	// 23 - Lote
	aAuxVO3[nPosAux, AP_NUMLOT     ] := IIf( lCtrlLote , aAuxValPec[nCntFor,PECA_NUMLOT] , "" )	// 24 - Sub-Lote
	aAuxVO3[nPosAux, AP_SEQFEC     ] := oGetDetVO3:aCols[nPos,DSEQFEC]// 25 - Sequencia do Fechamento
	
	aAuxVO3[nPosAux, AP_RECVO3     ] := {}	// 26 - Recno do VO3
	for nRecPecMov := 1 to Len(aAuxValPec[nCntFor,PECA_MOV])
		aadd( aAuxVO3[nPosAux, AP_RECVO3], { aAuxValPec[nCntFor,PECA_MOV,nRecPecMov,PECA_MOV_RECVO3] })
	Next

	// Ponto de entrada para:
	// 0 - Cria็ใo    ( )
	// 1 - Ret. Dados (X)
	// de campos customizแveis da gridbox de Pe็as
	If lVO3Pec .And. !Empty(aVO3CPec)
		aVO3DPec := ExecBlock("OX100PEC", .f., .f., {"1", aAuxValPec[nCntFor, 01], aAuxValPec[nCntFor, 02]}) // VO3_GRUITE / VO3_CODITE

		If !Empty(aVO3DPec)
			For nCntAux := 1 To Len(aVO3DPec[nCntAux])
				If FG_POSVAR(aVO3CPec[1, nCntAux], "aHVO3Det") > 0
					oGetDetVO3:aCols[nPos , FG_POSVAR(aVO3CPec[1, nCntAux], "aHVO3Det")] := aVO3DPec[1, nCntAux]
				EndIf
			Next
		EndIf
	EndIf

	//
	If lAtuVal
		nTotalPeca += Round(aAuxValPec[nCntFor,PECA_VALOR] * aAuxValPec[nCntFor,PECA_QTDREQ],2)
	EndIf
	
	// Monta array para gerar VSG
	OX100BOQ(aAuxValPec[nCntFor,PECA_MOV])
	//
	
Next nCntFor

// Se TT utiliza valor de peca atual, atualiza a listbox de TT
If lAtuVal
	nPos := aScan( aVetTTP , { |x| x[ATT_VETSEL] .and. x[ATT_NUMOSV] == cNumOS .and. x[ATT_TIPTEM] == cTipTem .and. x[ATT_LIBVOO] == cLibVOO} )
	If nPos > 0
		aVetTTP[nPos,ATT_TOTPEC] := nTotalPeca
		oLbTTP:Refresh()
	EndIf
EndIf
//

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100BOQ   บAutor  ณ Takahashi          บ Data ณ  25/11/14 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Faz Levantamento de Produtivos para gerar comissao de pecasบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100BOQ( aAuxReq )

Local nCont
Local nPos

For nCont := 1 to Len(aAuxReq)
	
	If (nPos := aScan(aBoqPec,{ |x| x[1] == aAuxReq[nCont,PECA_MOV_FUNREQ] })) == 0
		AADD( aBoqPec , { aAuxReq[nCont,PECA_MOV_FUNREQ] , 0 } )
		nPos := Len(aBoqPec)
	EndIf
	aBoqPec[nPos,2] += IIF( aAuxReq[nCont,PECA_MOV_REQDEV] == "1" , aAuxReq[nCont,PECA_MOV_QTDREQ] , aAuxReq[nCont,PECA_MOV_QTDREQ] * -1 )
	
	// Se o produtivo que requisitou for diferente do produtivo que requisitou
	If aAuxReq[nCont,PECA_MOV_PROREQ] <> aAuxReq[nCont,PECA_MOV_FUNREQ]
		If (nPos := aScan(aBoqPec,{ |x| x[1] == aAuxReq[nCont,PECA_MOV_PROREQ] })) == 0
			AADD( aBoqPec , { aAuxReq[nCont,PECA_MOV_PROREQ] , 0 } )
			nPos := Len(aBoqPec)
		EndIf
		aBoqPec[nPos,2] += IIF( aAuxReq[nCont,PECA_MOV_REQDEV] == "1" , aAuxReq[nCont,PECA_MOV_QTDREQ] , aAuxReq[nCont,PECA_MOV_QTDREQ] * -1 )
	EndIf
	
Next nCont

// Remove as requisicoes zeradas ...
nCont := 1
While nCont <= Len(aBoqPec)
	If aBoqPec[nCont,2] <= 0
		ADEL(aBoqPec,nCont)
		aSize(aBoqPec,Len(aBoqPec)-1)
	Else
		nCont++
	EndIf
End
//

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100SRVC  บAutor  ณ Takahashi          บ Data ณ  15/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Faz o Levantamento dos Servicos do TT a ser Fechado        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100SRVC(cNumOS, cTipTem, cLibVOO)

Local aAuxValSer := {}
Local nPosAux    := 0
Local nCntFor    := 0
Local nCntApont  := 0
Local nValTotSrv := 0

Local DVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Det")
Local DVO4GRUSER := FG_POSVAR("VO4_GRUSER","aHVO4Det")
Local DVO4CODSER := FG_POSVAR("VO4_CODSER","aHVO4Det")
Local DVO4DESSER := FG_POSVAR("VO4_DESSER","aHVO4Det")
Local DVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Det")
Local DVO4DESTPS := FG_POSVAR("VO4_DESTPS","aHVO4Det")
Local DVO4KILROD := FG_POSVAR("VO4_KILROD","aHVO4Det")
Local DVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Det")
Local DVO4PERDES := FG_POSVAR("VO4_PERDES","aHVO4Det")
Local DVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Det")
Local DVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Det")
Local DVO4TEMPAD := FG_POSVAR("VO4_TEMPAD","aHVO4Det")
Local DVO4TEMTRA := FG_POSVAR("VO4_TEMTRA","aHVO4Det")
Local DVO4TEMCOB := FG_POSVAR("VO4_TEMCOB","aHVO4Det")
Local DVO4TEMVEN := FG_POSVAR("VO4_TEMVEN","aHVO4Det")

Local RVO4CENCUS := FG_POSVAR("VO4_CENCUS","aHVO4Res")
Local RVO4CONTA  := FG_POSVAR("VO4_CONTA","aHVO4Res")
Local RVO4ITEMCT := FG_POSVAR("VO4_ITEMCT","aHVO4Res")
Local RVO4CLVL   := FG_POSVAR("VO4_CLVL","aHVO4Res")

Local aVO4DSer := {}
Local nCntAux  := 0

// Calcula o valor de todos os servicos da OS e TT Informados ...
aAuxValSer := FMX_CALSER(cNumOS,;
cTipTem,;
/* cGruSer */,;
/* cCodSer */ ,;
.t. /* lApont */ ,;
.t. /* lNegoc */ ,;
.f. /* lRetAbe */ ,;
.t. /* lRetLib */ ,;
.f. /* lRetFec */ ,;
.f. /* lRetCan */ ,;
cLibVOO )

VOI->(dbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + cTipTem ) )

For nCntFor := 1 to Len(aAuxValSer)
	
	nAuxTemCob := 0
	nAuxTemVen := 0
	
	// Verifica se ja existe o servico na aCols
	nPos := aScan( oGetDetVO4:aCols , { |x| x[DVO4TIPTEM] == aAuxValSer[nCntFor,04] .and. ;
	x[DVO4TIPSER] == aAuxValSer[nCntFor,05] .and. ;
	x[DVO4GRUSER] == aAuxValSer[nCntFor,01] .and. ;
	x[DVO4CODSER] == aAuxValSer[nCntFor,02] } )
	IF nPos == 0
		
		// Cria uma linha em branco na aCols
		AADD( oGetDetVO4:aCols, Array( Len(aCVO4Det[1])) )
		nPos := Len(oGetDetVO4:aCols)
		oGetDetVO4:aCols[nPos] := aClone(aCVO4Det[1])
		//
		
		oGetDetVO4:aCols[nPos, DVO4TIPTEM ] := aAuxValSer[nCntFor,04]
		oGetDetVO4:aCols[nPos, DVO4GRUSER ] := aAuxValSer[nCntFor,01]
		oGetDetVO4:aCols[nPos, DVO4CODSER ] := aAuxValSer[nCntFor,02]
		oGetDetVO4:aCols[nPos, DVO4DESSER ] := aAuxValSer[nCntFor,15]
		oGetDetVO4:aCols[nPos, DVO4TIPSER ] := aAuxValSer[nCntFor,05]
		oGetDetVO4:aCols[nPos, DVO4DESTPS ] := aAuxValSer[nCntFor,16]
		
	EndIf
	//
	
	oGetDetVO4:aCols[nPos, DVO4TEMPAD] += aAuxValSer[nCntFor,10]
	oGetDetVO4:aCols[nPos, DVO4TEMTRA] += aAuxValSer[nCntFor,11]
	oGetDetVO4:aCols[nPos, DVO4TEMCOB] += aAuxValSer[nCntFor,12]
	oGetDetVO4:aCols[nPos, DVO4TEMVEN] += aAuxValSer[nCntFor,13]
	oGetDetVO4:aCols[nPos, DVO4KILROD] += aAuxValSer[nCntFor,19]
	
	nAuxTemCob += aAuxValSer[nCntFor,12]
	nAuxTemVen += aAuxValSer[nCntFor,13]
	
	nVlrSrvc := aAuxValSer[nCntFor,07]
	nPerDes  := aAuxValSer[nCntFor,17]
	nValDes  := aAuxValSer[nCntFor,08]
	
	// Grava o Valor do Servico quando NรO ้ Tipo de Tempo INTERNO ...
	If VOI->VOI_SITTPO <> "3"
		oGetDetVO4:aCols[nPos, DVO4VALBRU ] += nVlrSrvc
		oGetDetVO4:aCols[nPos, DVO4VALTOT ] += nVlrSrvc
		oGetDetVO4:aCols[nPos, DVO4VALDES ] += nValDes
	Else
		oGetDetVO4:aCols[nPos, DVO4TEMCOB ] := 0
	EndIf
	//
	
	// Cria matriz auxiliar que sera utilizado na gravacao da negociacao ...
	// ATENCAO: se a chave de pesquisa na matriz for alterada, deve alterar outros pontos do FONTE
	nPerApont := 0
	nPosAux := aScan( aAuxVO4, { |x| ;
	x[ AS_NUMOSV ] == cNumOS .and. ;
	x[ AS_TIPTEM ] == aAuxValSer[nCntFor,04] .and. ;
	x[ AS_TIPSER ] == aAuxValSer[nCntFor,05] .and. ;
	x[ AS_GRUSER ] == aAuxValSer[nCntFor,01] .and. ;
	x[ AS_CODSER ] == aAuxValSer[nCntFor,02] .and. ;
	x[ AS_LIBVOO ] == aAuxValSer[nCntFor,38] .and. ;
	x[ AS_SEQINC ] == aAuxValSer[nCntFor,SRVC_INCONV_SEQ] } )
	IF nPosAux == 0
		
		VOK->(MsSeek( xFilial("VOK") + aAuxValSer[nCntFor,05] ))
		
		AADD( aAuxVO4, Array(28) )
		nPosAux := Len(aAuxVO4)
		aAuxVO4[ nPosAux , AS_NUMOSV    ] := cNumOS         // 01 - Numero da OS
		aAuxVO4[ nPosAux , AS_TIPSER    ] := aAuxValSer[nCntFor,05] // 02 - Tipo do Servico
		aAuxVO4[ nPosAux , AS_GRUSER    ] := aAuxValSer[nCntFor,01] // 03 - Grupo do Servico
		aAuxVO4[ nPosAux , AS_CODSER    ] := aAuxValSer[nCntFor,02] // 04 - Codigo do Servico
		aAuxVO4[ nPosAux , AS_VALBRU    ] := 0            // 05 - Valor Bruto
		aAuxVO4[ nPosAux , AS_TIPTEM    ] := aAuxValSer[nCntFor,04] // 06 - Tipo de Tempo
		aAuxVO4[ nPosAux , AS_PERDES    ] := 0            // 07 - Percentual de Desconto
		aAuxVO4[ nPosAux , AS_VALDES    ] := 0            // 08 - Valor do Desconto
		aAuxVO4[ nPosAux , AS_INCMOB    ] := aAuxValSer[nCntFor,06] // 09 - Tipo de Cobranca
		aAuxVO4[ nPosAux , AS_TEMPAD    ] := aAuxValSer[nCntFor,10] // 10 - Tempo Padrao
		aAuxVO4[ nPosAux , AS_TEMTRA    ] := aAuxValSer[nCntFor,11] // 11 - Tempo Trabalhado
		aAuxVO4[ nPosAux , AS_TEMCOB    ] := nAuxTemCob       // 12 - Tempo Cobrado
		aAuxVO4[ nPosAux , AS_TEMVEN    ] := nAuxTemVen       // 13 - Tempo Vendido
		aAuxVO4[ nPosAux , AS_SERINT    ] := aAuxValSer[nCntFor,37] // 14 - Codigo Interno do Servico
		aAuxVO4[ nPosAux , AS_SECAO     ] := aAuxValSer[nCntFor,18] // 15 - Codigo da Secao
		aAuxVO4[ nPosAux , AS_KILROD    ] := aAuxValSer[nCntFor,19] // 16 - Km Rodados
		aAuxVO4[ nPosAux , AS_APONTA    ] := {}           // 17 - Contem todos os apontamentos do servico
		aAuxVO4[ nPosAux , AS_PERCVLB   ] := 0            // 18 - Percentual do Servico em Relacao ao Tipo de Tempo (Valor Bruto)
		aAuxVO4[ nPosAux , AS_PERCVLL   ] := 0            // 19 - Percentual do Servico em Relacao ao Tipo de Tempo (Valor Liquido)
		aAuxVO4[ nPosAux , AS_ITTOTFISC ] := 0            // 20 - Total Fiscal (IT_TOTAL) jแ Rateado ...
		aAuxVO4[ nPosAux , AS_ITBASEDUP ] := 0            // 21 - Valor Base Duplicata do Item ja Rateado
		aAuxVO4[ nPosAux , AS_LIBVOO    ] := aAuxValSer[nCntFor,38] // 22 - Numero da Liberacao (VOO_LIBVOO)
		aAuxVO4[ nPosAux , AS_INCTEM    ] := VOK->VOK_INCTEM    // 23 - Tempo para Calculo
		aAuxVO4[ nPosAux , AS_SEQINC    ] := aAuxValSer[nCntFor,SRVC_INCONV_SEQ]
		
		if RVO4CENCUS <> 0 .and. RVO4CONTA <> 0 .and. RVO4ITEMCT <> 0 .and. RVO4CLVL <> 0
			aAuxVO4[ nPosAux , AS_CENCUS    ] := aAuxValSer[nCntFor,SRVC_CENCUS]
			aAuxVO4[ nPosAux , AS_CONTA     ] := aAuxValSer[nCntFor,SRVC_CONTA]
			aAuxVO4[ nPosAux , AS_ITEMCT    ] := aAuxValSer[nCntFor,SRVC_ITEMCTA]
			aAuxVO4[ nPosAux , AS_CLVL      ] := aAuxValSer[nCntFor,SRVC_CLVL]
		Endif
		For nCntApont := 1 to Len(aAuxValSer[nCntFor, 14])
			
			AADD( aAuxVO4[nPosAux,AS_APONTA] , Array(09) )
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_CODPRO] := aAuxValSer[nCntFor, 14, nCntApont, 01] // 17,01 - Codigo do Produtivo
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_DATINI] := aAuxValSer[nCntFor, 14, nCntApont, 02] // 17,02 - Data de Inicio do Apontamento
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_HORINI] := aAuxValSer[nCntFor, 14, nCntApont, 03] // 17,03 - Hora de Inicio do Apontamento
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_DATFIN] := aAuxValSer[nCntFor, 14, nCntApont, 04] // 17,04 - Data de Fim do Apontamento
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_HORFIN] := aAuxValSer[nCntFor, 14, nCntApont, 05] // 17,05 - Hora de Inicio do Apontamento
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_TEMTRA] := aAuxValSer[nCntFor, 14, nCntApont, 06] // 17,06 - Tempo Trabalhado
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_SEQUEN] := aAuxValSer[nCntFor, 14, nCntApont, 07] // 17,07 - Sequencia
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_RECNO ] := aAuxValSer[nCntFor, 14, nCntApont, 08] // 17,08 - RECNO do VO4
			aAuxVO4[nPosAux, AS_APONTA, nCntApont,AS_APONTA_PERCEN] := 1                    // 17,09 - Percentual do Apontamento no Total do Tempo Trabalhado */
			
			
			// 2-Servico de Terceiros
			If aAuxValSer[nCntFor,06] $ "2"
				aAuxVO4[nPosAux, AS_APONTA, nCntApont, AS_APONTA_PERCEN] := aAuxValSer[nCntFor, SRVC_APONT, nCntApont, SRVC_APONT_VALVEN] / aAuxValSer[nCntFor,SRVC_VALBRU]
				
				// 0=Mao-de-Obra Gratuita / 1=Mao-de-Obra / 3=Vlr Livre c/Base na Tabela / 4=Retorno de Srv
			ElseIf aAuxValSer[nCntFor,06] $ "0/1/3/4"
				aAuxVO4[nPosAux, AS_APONTA, nCntApont, AS_APONTA_PERCEN] := aAuxValSer[nCntFor, SRVC_APONT, nCntApont, SRVC_APONT_TEMTRA] / aAuxVO4[nPosAux,AS_TEMTRA]
			EndIf
			//
			
			nPerApont += aAuxVO4[nPosAux, AS_APONTA, nCntApont, AS_APONTA_PERCEN]
			
		Next nCntApont
		
		//    If (nPerApont - 1) <> 0
		//      Alert("Percentual de apontamento com problema" + CHR(13) + CHR(10) + Str(nPerApont,10,9))
		//      aAuxVO4[nPosAux, 17, nCntApont, 09] += (nPerApont - 1)
		//    EndIf
		//
		
	EndIf
	aAuxVO4[nPosAux,AS_VALBRU] += nVlrSrvc
	aAuxVO4[nPosAux,AS_VALDES] += nValDes
	//
	// Ponto de entrada para:
	// 0 - Cria็ใo    ( )
	// 1 - Ret. Dados (X)
	// de campos customizแveis da gridbox de Pe็as
	If lVO4Ser .And. !Empty(aVO4CSer)
		aVO4DSer := ExecBlock("OX100SER", .f., .f., {"1", aAuxValSer[nCntFor, 37]}) // VO4_SERINT

		If !Empty(aVO4DSer)
			For nCntAux := 1 To Len(aVO4DSer[nCntAux])
				If FG_POSVAR(aVO4CSer[1, nCntAux], "aHVO4Det") > 0
					oGetDetVO4:aCols[nCntFor, FG_POSVAR(aVO4CSer[1, nCntAux], "aHVO4Det")] := aVO4DSer[1, nCntAux]
				EndIf
			Next
		EndIf
	EndIf

Next nCntFor

// Acerta o Percentual de Desconto da Matriz Auxiliar
For nCntFor := 1 to Len(aAuxVO4)
	If aAuxVO4[nCntFor,AS_VALDES] <> 0
		OX100DESC(2, aAuxVO4[nCntFor,AS_VALBRU], 1 , nValTotSrv, @aAuxVO4[nCntFor,AS_PERDES], aAuxVO4[nCntFor,AS_VALDES] )
		
		// Tempo para Calculo - 1=Fabrica / 2=Concessionaria / 4=Informado
		// Calcula o tempo cobrado considerando algum desconto que foi dado no servico ...
		If aAuxVO4[nCntFor,AS_INCTEM] $ "124" .and. aAuxVO4[nCntFor,AS_TEMPAD] <> 0
			aAuxVO4[nCntFor,AS_TEMCOB] := Round(aAuxVO4[nCntFor,AS_TEMPAD] * (1 - (aAuxVO4[nCntFor,AS_VALDES] / aAuxVO4[nCntFor,AS_VALBRU])),0)
		EndIf
		//
	EndIf
Next nCntFor
//

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณOX100INIFISบAutor  ณ Rubens             บ Data ณ  15/10/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Inicializa Fiscal                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodigo = Codigo do Cliente                                บฑฑ
ฑฑบ          ณ cLoja = Loja do Cliente                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100INIFIS(cCodigo , cLoja)

SA1->(dbSetOrder(1))
If !SA1->(dbSeek(xFilial("SA1") + cCodigo + cLoja))
	MsgAlert(STR0013,STR0004) // Cliente nใo encontrado
	Return .f.
EndIf

If SA1->A1_MSBLQL == "1"
	HELP(" ",1,"REGBLOQ")
	Return .f.
Endif

cFechCli := SA1->A1_COD
cFechLoj := SA1->A1_LOJA
lCliPeriod := .f.
If !Empty(SA1->A1_TIPPER) .and. !Empty(SA1->A1_COND)
	lCliPeriod := .t.
EndIf

If MaFisFound('NF')
	MaFisClear()
EndIf
MaFisIni(cCodigo,cLoja,'C','N')
MaFisRef("NF_NATUREZA",,SA1->A1_NATUREZ)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100DESC   บAutor  ณ Takahashi         บ Data ณ  20/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula Desconto                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTipDes = Tipo do Desconto (1 % OU 2 R$)                   บฑฑ
ฑฑบ          ณ nValorUni = Valor unitario                                 บฑฑ
ฑฑบ          ณ nQtde = Qtde Vendida                                       บฑฑ
ฑฑบ          ณ nValorTot = Valor total do Item                            บฑฑ
ฑฑบ          ณ nPerDes = Percentual de Desconto                           บฑฑ
ฑฑบ          ณ nValDes = Valor do Desconto                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100DESC(nTipDes, nValorUni, nQtde, nValorTot, nPerDes, nValDes)

Local nValItem

Default nTipDes := 1

nValItem := FtDescItem( @nValorUni,;  //ExpN1: Preco de lista aplicado o desconto de cabecalho
@nValorUni,;  //ExpN2: Preco de Venda
nQtde,;     //ExpN3: Quantidade vendida
@nValorTot,;  //ExpN4: Valor Total (do item)
@nPerDes,;    //ExpN5: Percentual de desconto
@nValDes,;    //ExpN6: Valor do desconto
@nValDes,;    //ExpN7: Valor do desconto original
nTipDes)    //ExpN8: Tipo de Desconto (1 % OU 2 R$)

Return nValItem


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100ATRES  บAutor  ณ Takahashi         บ Data ณ  11/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza Resumo (Fiscal e Liquido)                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ lZerar = Zera a Matriz com Resumo Fiscal                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100ATRES(lZerar)

Local nCntFor
Local lIniFis := MaFisFound('NF')

Local DVO3VALTOT := FG_POSVAR("VO3_VALTOT","aHVO3Det")
Local DVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Det")
Local DVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Det")
Local DVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Det")

Local aAuxResFisc:= {}

Default lZerar := .f.

If lIniFis
	nTotNFiscal := MaFisRet(,"NF_TOTAL")
	nCTTotal    := OX100TFIN()
	nCRSaldo    := nCTTotal
	nTotFinanc  := nCTTotal
EndIf

nTotPeca  := 0
nTotDPeca := 0
nTotSrvc  := 0
nTotDSrvc := 0
aEval( oGetDetVO3:aCols, {|x| nTotPeca  += x[DVO3VALTOT], nTotDPeca += x[DVO3VALDES] } )
aEval( oGetDetVO4:aCols, {|x| nTotSrvc  += x[DVO4VALTOT], nTotDSrvc += x[DVO4VALDES] } )

nTotOS := nTotPeca + nTotSrvc

oTotPecas:Refresh()
oTotDPecas:Refresh()
oTotSrvc:Refresh()
oTotDSrvc:Refresh()
oTotOS:Refresh()
oTotNFiscal:Refresh()
oTotFinanc:Refresh()

aEval(oGetVS9:aCols , {|x| nCRSaldo -= IIF( !x[Len(x)] , x[FG_POSVAR("VS9_VALPAG","aHVS9")] , 0 ) } )

oCRDataIni:Refresh()
oCRDias:Refresh()
oCRParc:Refresh()
oCRInter:Refresh()
oCRTotal:Refresh()
oCRSaldo:Refresh()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza Matriz com Resumo Fiscal ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if lZerar
	aEval( aResFisc, {|x| x[3] := 0 } )
Elseif lIniFis
	aAuxResFisc := OX1000015_MostraImposto(aResFisc)
	aResFisc := aClone(aAuxResFisc)
	for nCntFor := 1 to Len(aResFisc)
		aResFisc[nCntFor,3] := &(aResFisc[nCntFor,1])
	next
endif
//
oLbResFisc:nAt := 1
oLbResFisc:SetArray(aResFisc)
oLbResFisc:bLine := { || { aResFisc[oLbResFisc:nAt,2], FG_AlinVlrs(Transform(aResFisc[oLbResFisc:nAt,3],"@E 999,999,999.99")) }}
oLbResFisc:Refresh()
//
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100RESS  บAutor  ณ Takahashi          บ Data ณ  16/11/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza aCols de Resumo de Servicos                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipTem = Tipo de Tempo para Atualizacao ou Branco para    บฑฑ
ฑฑบ          ณ           atualizar todos os Tipos                         บฑฑ
ฑฑบ          ณ cTipSer = Tipo do Servico para Atualizacao ou Branco para  บฑฑ
ฑฑบ          ณ           atualizar todos os Tipos                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100RESS(cTipTem, cTipSer)

Local nPosRes := 0
Local nPosDet := 0
Local nBkpN

Local DVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Det")
Local DVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Det")
Local DVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Det")
Local DVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Det")

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")
Local RVO4PERDES := FG_POSVAR("VO4_PERDES","aHVO4Res")
Local RVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Res")
Local RVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Res")
Local RVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Res")

For nPosRes := 1 to Len(oGetResVO4:aCols)
	
	If oGetResVO4:aCols[nPosRes, RVO4TIPTEM] <> cTipTem .or. oGetResVO4:aCols[nPosRes, RVO4TIPSER] <> cTipSer
		Loop
	EndIf
	
	// Atualiza GetDados Resumida
	oGetResVO4:aCols[nPosRes, RVO4VALBRU] := 0
	oGetResVO4:aCols[nPosRes, RVO4VALDES] := 0
	For nPosDet := 1 to Len(oGetDetVO4:aCols)
		If oGetDetVO4:aCols[nPosDet, DVO4TIPTEM] == oGetResVO4:aCols[nPosRes, RVO4TIPTEM] .and. oGetDetVO4:aCols[nPosDet, DVO4TIPSER] == oGetResVO4:aCols[nPosRes, RVO4TIPSER]
			oGetResVO4:aCols[nPosRes, RVO4VALBRU] += oGetDetVO4:aCols[nPosDet, DVO4VALBRU]
			oGetResVO4:aCols[nPosRes, RVO4VALDES] += oGetDetVO4:aCols[nPosDet, DVO4VALDES]
		EndIf
	Next nPosDet
	//
	
	// Recalcula Descontos (Por Valor)
	OX100DESC(2, oGetResVO4:aCols[nPosRes,RVO4VALBRU] , 1 , @oGetResVO4:aCols[nPosRes, RVO4VALTOT ], @oGetResVO4:aCols[nPosRes, RVO4PERDES ], @oGetResVO4:aCols[nPosRes, RVO4VALDES ] )
	
	// Atualiza Fiscal ...
	nBkpN := n
	OX100SRVFIS( nPosRes ) // Set o N para a Posicao Correspondente no Fiscal
	MaFisRef("IT_PRCUNI"  ,"VO300", oGetResVO4:aCols[nPosRes, RVO4VALBRU ])
	MaFisRef("IT_VALMERC" ,"VO300", oGetResVO4:aCols[nPosRes, RVO4VALBRU ])
	MaFisRef("IT_DESCONTO","VO300", oGetResVO4:aCols[nPosRes, RVO4VALDES ])
	n := nBkpN
	//
	
Next nPosRes

oGetResVO4:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100FILTRO บAutor  ณ Takahashi         บ Data ณ  11/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Listbox de acordo com o Filtro                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100FILTRO()

OX100LIMPA()
OX100ATLB(cFilNumOsv , cFilClie , cFilLoja , cFilTTP , cFilChassi )

oLbTTP:nAT := 1
oLbTTP:SetArray(aVetTTP)
oLbTTP:DrawSelect()
oLbTTP:Refresh()

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100LIMPA  บAutor  ณ Takahashi         บ Data ณ  11/10/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Limpa Tela                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100LIMPA()

Local nCntFor

If MaFisFound('NF')
	MaFisClear()
EndIf

oGetResVO3:nAt := 1
oGetResVO3:aCols := AClone(aCVO3Res)  // Resumo
oGetResVO3:oBrowse:Refresh()

oGetDetVO3:nAt := 1
oGetDetVO3:aCols := AClone(aCVO3Det)  // Detalhado
oGetDetVO3:oBrowse:Refresh()

oGetResVO4:nAt := 1
oGetResVO4:aCols := AClone(aCVO4Res)  // Resumo
oGetResVO4:oBrowse:Refresh()

oGetDetVO4:nAt := 1
oGetDetVO4:aCols := AClone(aCVO4Det)  // Detalhado
oGetDetVO4:oBrowse:Refresh()

oGetVS9:nAt := 1
oGetVS9:aCols := AClone(aCVS9)      // Condicao de Pagamento
oGetVS9:oBrowse:Refresh()

For nCntFor := 1 to Len(aCpoVOO)
	&("M->"+AllTrim(aCpoVOO[nCntFor])) := CriaVar(AllTrim(aCpoVOO[nCntFor]),.t.)
Next nCntFor
oEnchVOO:Refresh()

lCliPeriod  := .f.
cFechCli    := ""
cFechLoj    := ""

nTotPeca    := 0  // Total Liquido de Pecas
nTotDPeca   := 0  // Total Liquido de Desconto de Pecas
nTotSrvc    := 0  // Total Liquido de Servicos
nTotDSrvc   := 0  // Total Liquido de Desconto de Servicos
nTotOS      := 0  // Total Liquido da OS
nTotNFiscal := 0  // Total da Nota Fiscal
nAcresFin   := 0  // Acrescimo Financeiro
nTotFinanc  := 0  // Total Financeiro

dCRDataIni  := CtoD("00/00/00") // Data inicial para Financiamento
nCRDias     := 0        // Dias para Financiamento
nCRParc     := 0        // Parcelas para Financiamento
nCRInter    := 0        // Intervalo para Financiamento
nCRSaldo    := 0        // Saldo a ser distribuido
nCRTotal    := 0        // Total Financeiro
lSE4TipoA   := .f.

OX100ATRES(.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100ATLB บAutor  ณ Takahashi          บ Data ณ  11/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza listbox dos TT para Fechamento                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cPNumOsv = Numero da Ordem de Servico                      บฑฑ
ฑฑบ          ณ cPCliente = Cliente para Filtro                            บฑฑ
ฑฑบ          ณ cPLoja = Loja para Filtro                                  บฑฑ
ฑฑบ          ณ cPTipTem = Tipo de Tempo para Filtro                       บฑฑ
ฑฑบ          ณ cPChassi = Chassi para Filtro                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100ATLB(cPNumOsv, cPClie, cPLoja, cPTipTem, cPChassi)

Local cAliasVOO := "TSQLVOO"
Local cSQL := ""
Local nPos := 0

Default cPNumOsv := ""
Default cPClie   := ""
Default cPLoja   := ""
Default cPTipTem := ""
Default cPChassi := ""

aVetTTP := {}

If !( Empty(cPNumOsv) .and. Empty(cPClie) .and. Empty(cPChassi) )
	cSQL := "SELECT VOO_NUMOSV, VOO_TIPTEM, VOO_FATPAR, VOO_LOJA, VOO_TOTPEC, VOO_HRSPAD, VOO_HRSAPL, VOO_TOTSRV, VOO_PESQLJ, VOO_NUMNFI, VOO_SERNFI"
	cSQL += " , VOO_LIBVOO "
	cSQL +=   " , A1_NOME, A1_MSBLQL"
	cSQL +=   " , VO1.VO1_CHAINT , VO1.VO1_FUNABE, VAI.VAI_CODVEN"
	cSQL +=   " , VV1.VV1_CHASSI , VV1.VV1_CODMAR, VO1.VO1_CODMAR"
	cSQL +=   " , VOI.VOI_SITTPO "
	cSQL +=  " FROM " + RetSQLName("VOO") + " VOO JOIN " + RetSQLName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = VOO_FATPAR AND SA1.A1_LOJA = VOO.VOO_LOJA AND SA1.D_E_L_E_T_ = ' '"
	cSQL +=     " JOIN " + RetSQLName("VO1") + " VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VOO.VOO_NUMOSV AND VO1.D_E_L_E_T_ = ' '"
	cSQL +=     " JOIN " + RetSQLName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.D_E_L_E_T_ = ' '"
	cSQL +=     " JOIN " + RetSQLName("VAI") + " VAI ON VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_CODTEC = VO1.VO1_FUNABE AND VAI.D_E_L_E_T_ = ' '"
	cSQL +=     " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VOO.VOO_TIPTEM AND VOI.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VOO.VOO_FILIAL = '" + xFilial("VOO") + "'"
	if !Empty(cPNumOsv)
		cSQL +=   " AND VOO.VOO_NUMOSV = '" + cPNumOsv + "'"
	Endif
	if !Empty(cPClie)
		cSQL +=   " AND VOO.VOO_FATPAR = '" + cPClie + "'"
		if !Empty(cPLoja)
			cSQL +=   " AND VOO.VOO_LOJA = '" + cPLoja + "'"
		Endif
	Endif
	if !Empty(cPTipTem)
		cSQL +=   " AND VOO.VOO_TIPTEM = '" + cPTipTem + "'"
	Endif
	if !Empty(cPChassi)
	EndIf
	cSQL +=   " AND VOO.VOO_NUMNFI = '" + Space(TamSX3("VOO_NUMNFI")[1]) + "'" // TT nao faturados
	// Nao deve existir VSC, pois servico interno nao gera nota fiscal
	cSQL +=   " AND NOT EXISTS(SELECT VSC_NUMOSV "
	cSQL +=            " FROM " + RetSQLName("VSC") + " VSC "
	cSQL +=           " WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "'"
	cSQL +=           " AND VSC.VSC_NUMOSV = VOO.VOO_NUMOSV "
	cSQL +=           " AND VSC.VSC_TIPTEM = VOO.VOO_TIPTEM "
	cSQL +=           " AND VSC.VSC_LIBVOO = VOO.VOO_LIBVOO "
	cSQL +=           " AND VSC.D_E_L_E_T_ = ' ')"
	//
	cSQL +=   " AND VOO.D_E_L_E_T_ = ' '"
	//cSQL += " ORDER BY VOO_NUMOSV, VOO_TIPTEM, VOO_FATPAR, VOO_LOJA"
	cSQL += " ORDER BY VOO_TIPTEM, VOO_NUMOSV, "
	cSQL += " VOO_LIBVOO, "
	cSQL += " VOO_FATPAR, VOO_LOJA"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVOO , .F., .T. )
	While !(cAliasVOO)->(Eof())
		
		AADD( aVetTTP, Array(22) )
		nPos := Len(aVetTTP)
		aVetTTP[ nPos , ATT_VETSEL   ] := .f.             // 01 - Controle para Marcar o TT para Fechamento
		aVetTTP[ nPos , ATT_NUMOSV   ] := (cAliasVOO)->VOO_NUMOSV   // 02 - OS
		aVetTTP[ nPos , ATT_TIPTEM   ] := (cAliasVOO)->VOO_TIPTEM   // 03 - Tipo de Tempo
		aVetTTP[ nPos , ATT_CLIENTE  ] := (cAliasVOO)->VOO_FATPAR   // 04 - Faturar Para
		aVetTTP[ nPos , ATT_NOME     ] := Left((cAliasVOO)->A1_NOME,30) // 05 - Nome
		aVetTTP[ nPos , ATT_TOTPEC   ] := (cAliasVOO)->VOO_TOTPEC   // 06 - Total de Pecas
		aVetTTP[ nPos , ATT_HORASPAD ] := (cAliasVOO)->VOO_HRSPAD   // 07 - Horas Padrao
		aVetTTP[ nPos , ATT_HORASTRA ] := (cAliasVOO)->VOO_HRSAPL   // 08 - Horas Trabalhada
		aVetTTP[ nPos , ATT_TOTSER   ] := (cAliasVOO)->VOO_TOTSRV   // 09 - Total de Servicos
		aVetTTP[ nPos , ATT_LOJA     ] := (cAliasVOO)->VOO_LOJA     // 10 - Loja do Cliente Faturar Para
		aVetTTP[ nPos , ATT_CHAINT   ] := (cAliasVOO)->VO1_CHAINT   // 11 - Chassi Interno
		aVetTTP[ nPos , ATT_FUNABE   ] := (cAliasVOO)->VO1_FUNABE   // 12 - Equipe Tecnica - Abertura da OS
		aVetTTP[ nPos , ATT_CODVEN   ] := (cAliasVOO)->VAI_CODVEN   // 13 - Vendedor
		aVetTTP[ nPos , ATT_CHASSI   ] := (cAliasVOO)->VV1_CHASSI   // 14 - Chassi do Veiculo
		aVetTTP[ nPos , ATT_A1BLOQ   ] := (cAliasVOO)->A1_MSBLQL    // 15 - Cliente Bloqueado
		aVetTTP[ nPos , ATT_ORCLOJA  ] := (cAliasVOO)->VOO_PESQLJ   // 16 - Numero do Orcamento no Loja
		aVetTTP[ nPos , ATT_NUMNFI   ] := (cAliasVOO)->VOO_NUMNFI   // 17 - Numero da Nota Fiscal
		aVetTTP[ nPos , ATT_SERNFI   ] := (cAliasVOO)->VOO_SERNFI     // 18 - Serie da Nota Fiscal
		aVetTTP[ nPos , ATT_FECHADO  ] := .f.               // 19 - Indica se o TT ja foi fechado
		aVetTTP[ nPos , ATT_LIBVOO   ] := (cAliasVOO)->VOO_LIBVOO   // 20 - Numero da Liberacao (VOO_LIBVOO)
		aVetTTP[ nPos , ATT_CODMAR   ] := IIf( cMVMIL0006 == "JD" , OFNJD15011_RetornaMarca((cAliasVOO)->VO1_CODMAR) , (cAliasVOO)->VV1_CODMAR )  // 21 - Codigo da Marca do Veiculo
		aVetTTP[ nPos , ATT_SITTPO   ] := (cAliasVOO)->VOI_SITTPO   // 22 - Situacao do tipo de tempo
		
		If !Empty((cAliasVOO)->VOO_PESQLJ) .or. !Empty((cAliasVOO)->VOO_NUMNFI)
			aVetTTP[Len(aVetTTP), ATT_FECHADO] := .t.
		Else
			// Se nao tiver Nota e Orcamento no Loja, verifica se existe VSC,
			// pois se TT de servico e Interno, o fechamento nao gera nota e so gera VSC
			cSQL := "SELECT DISTINCT VSC_NUMOSV "
			cSQL +=  " FROM " + RetSQLName("VSC") + " VSC "
			cSQL += " WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "'"
			cSQL +=   " AND VSC.VSC_NUMOSV = '" + (cAliasVOO)->VOO_NUMOSV + "'"
			cSQL +=   " AND VSC.VSC_TIPTEM = '" + (cAliasVOO)->VOO_TIPTEM + "'"
			cSQL +=   " AND VSC.VSC_LIBVOO = '" + (cAliasVOO)->VOO_LIBVOO + "'"
			cSQL +=   " AND VSC.D_E_L_E_T_ = ' '"
			If !Empty(FM_SQL( cSQL ))
				aVetTTP[Len(aVetTTP), ATT_FECHADO] := .t.
			EndIf
		EndIf
		
		(cAliasVOO)->(dbSkip())
	End
	(cAliasVOO)->(dbCloseArea())
	dbSelectArea("VO1")
	
	//	aSort( aVetTTP ,,,{|x,y| x[ATT_TIPTEM] + x[ATT_NUMOSV] + x[ATT_LIBVOO] < y[ATT_TIPTEM] + y[ATT_NUMOSV] + y[ATT_LIBVOO] })
	
EndIf

If Len(aVetTTP) == 0
	aAdd(aVetTTP,{.f.,"","","","",0,0,0,0,"","","","","","","","","",.f.,""})
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100PDFOK บAutor  ณ Takahashi          บ Data ณ  03/11/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ FieldOk da GetDados de Pecas - DETALHADA                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100PDFOK(cReadVar,lAtuAcres)

Local nTipDes
Local cAuxTES
Local lAtu := .f.

Local DVO3CODTES  := FG_POSVAR("VO3_CODTES", "aHVO3Det")
Local DVO3OPER    := FG_POSVAR("VO3_OPER"  , "aHVO3Det")
Local DVO3ACRESC  := FG_POSVAR("VO3_ACRESC", "aHVO3Det")
Local DVO3VALTOT  := FG_POSVAR("VO3_VALTOT", "aHVO3Det")
Local DVO3VALBRU  := FG_POSVAR("VO3_VALBRU", "aHVO3Det")

Default cReadVar  := ReadVar()
Default lAtuAcres := .f.

//
//  PE que Valida digita็๕es das GetDados dos Grupos de Pe็as ou C๓digos de Pe็as
//  1o Parโmetro  - Indica se a alteracao foi feita na GetDados dos Grupos de Pe็as(Resumida) ou dos C๓digos de Pe็as(Detalhada)
//     D - GetDados de Pe็as
//     R - GetDados de Grupos de Pe็as
//  2o Parโmetro - cReadVar ( utilizar sempre este parโmetro e nunca ReadVar() )
//
If ExistBlock("OX100VLP")
	If !ExecBlock("OX100VLP",.f.,.f.,{"D",cReadVar})
		Return .f.
	Endif
EndIf


If cReadVar $ "M->VO3_VALDES,M->VO3_PERDES"
	
	If cUsaAcres == 'S' .and. M->VO3_ACRESC > 0
		Help( ,, 'Help',, STR0143, 1, 0 ) // "Para adicionar desconto por favor remova o acr้scimo"
		Return .f.
	EndIf
	
	If cReadVar == "M->VO3_PERDES"
		If M->VO3_PERDES > 99.99
			Help(" ",1,"OX100PERDES")
			Return .f.
		EndIf
		nTipDes := 1 // Calcula por Percentual
	Else
		If M->VO3_VALDES >= M->VO3_VALBRU
			Help(" ",1,"OX100VALDES")
			Return .f.
		EndIf
		nTipDes := 2 // Calcula por Valor
	EndIf
	OX100DPECA( 1 , oGetDetVO3:nAt , nTipDes , M->VO3_PERDES , M->VO3_VALDES )
	
ElseIf cReadVar == "M->VO3_CODTES"
	
	// Validacao da TES com relacao a movimentacao de estoque ...
	If !OX100CMPTES( oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3CODTES] , M->VO3_CODTES )
		Return .f.
	EndIf
	//
	
	// Atualiza Fiscal ...
	OX100PECFIS(oGetDetVO3:nAt)
	// Altera o RECNO do TES no MATXFIS, pois ele posiciona na tabela de TES pelo RECNO
	// e quando a TES ้ alterada atrav้s do MaFisRef, o RECNO nใo ้ atualizado
	MaFisLoad("IT_RECNOSF4",SF4->(Recno()), n)
	MaFisRef("IT_TES","VO300",M->VO3_CODTES)
	OX100FISPEC(oGetDetVO3:nAt)
	//
	
	// Atualiza Resumo ...
	OX100ATRES(.f.)
	
	// Se tiver condicao de pagamento informada, simular o FieldOK
	// para recalcular valor das parcelas ...
	If !Empty(M->VOO_CONDPG)
		OX100VOO("M->VOO_CONDPG", .f.)
	EndIf
	//
	
ElseIf cReadVar == "M->VO3_OPER"
	
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1") + M->VO3_GRUITE + M->VO3_CODITE )
	dbSetOrder(1)
	cAuxTES := MaTesInt(2,M->VO3_OPER,MaFisRet(,"NF_CODCLIFOR"),MaFisRet(,"NF_LOJA"),"C",SB1->B1_COD,,MaFisRet(,"NF_TPCLIFOR"))
	If Empty(cAuxTES)
		cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
	Endif
	
	If !Empty(cAuxTES)
		
		// Validacao da TES com relacao a movimentacao de estoque ...
		If !OX100CMPTES( oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3CODTES] , cAuxTES )
			Return .f.
		EndIf
		//
		
		SF4->(dbSetOrder(1))
		If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
			Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + cAuxTES ,4,1)
			Return .f.
		EndIf
		oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3CODTES] := M->VO3_CODTES := cAuxTES
		oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3OPER  ] := M->VO3_OPER
		
		OX100PDFOK("M->VO3_CODTES")
	EndIf
	
ElseIf (cUsaAcres == 'S' .AND. cReadVar == "M->VO3_ACRESC") .or. lAtuAcres
	
	If cUsaAcres == 'S' .and. ( M->VO3_ACRESC > 0.0 )
		If( M->VO3_VALDES <> 0.0 )
			Help( ,, 'Help',, STR0142, 1, 0 ) // "Para adicionar acr้scimo deve-se zerar o desconto."
			Return .f.
		EndIf
		// Validacao de resto da divisao que nใo pode ser 0
		nRest := OX100ModDec( M->VO3_ACRESC, M->VO3_QTDREQ )
		If nRest > 0.0
			M->VO3_ACRESC := M->VO3_ACRESC - nRest
		EndIf
		// ---
		lAtu := .t.
	Else
		// Caso tenha zerado o acresc
		If( M->VO3_VALDES == 0.0 ) // Nao recalcular caso tenha valor de desconto informado
			lAtu := .t.
		Endif
	EndIf
	If lAtu
		M->VO3_VALTOT := (( M->VO3_VALPEC * M->VO3_QTDREQ ) - M->VO3_VALDES) + M->VO3_ACRESC
		If cUsaAcres == 'S'
			oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3ACRESC] := M->VO3_ACRESC
		Endif
		oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3VALTOT] := ( M->VO3_VALPEC * M->VO3_QTDREQ ) - M->VO3_VALDES + IIf( cUsaAcres == 'S',M->VO3_ACRESC,0)
		oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3VALBRU] := oGetDetVO3:aCols[oGetDetVO3:nAt, DVO3VALTOT]
		OX100UPDAcres(DVO3ACRESC,DVO3VALTOT)
	EndIf
	//
	OX100UPDMrg() // Recalcular o % da Margem de Lucro Oficina
	//
	// Se tiver condicao de pagamento informada, simular o FieldOK
	// para recalcular valor das parcelas ...
	If !Empty(M->VOO_CONDPG)
		OX100VOO("M->VOO_CONDPG", .f.)
	EndIf
	//
	
EndIf

If cReadVar $ "M->VO3_VALDES,M->VO3_PERDES,M->VO3_OPER,M->VO3_CODTES,"
	OX100UPDMrg() // Recalcular o % da Margem de Lucro Oficina
EndIf

If ExistBlock("OX100FOP")
	ExecBlock("OX100FOP",.f.,.f.,{"D",cReadVar})
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100PDLOK บAutor  ณ Takahashi          บ Data ณ  16/11/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Linha OK da GetDados de Pecas - DETALHADA                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100PDLOK()

Local DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")

Local nCntFor

// Ponto de Entrada na chamada do linok do aCols detalhado no fechamento de OS.
If ExistBlock("OX100LOK")
	If !ExecBlock("OX100LOK",.f.,.f.)
		Return .f.
	Endif
EndIf


// Linha em Branco
If Len(oGetDetVO3:aCols) == 1 .and. Empty(oGetDetVO3:aCols[1, DVO3GRUITE]) .and. Empty(oGetDetVO3:aCols[1, DVO3CODITE])
	Return .t.
EndIf

For nCntFor:=1 to Len(oGetDetVO3:aHeader)
	If X3Obrigat(oGetDetVO3:aHeader[nCntFor,2])  .and. (Empty(oGetDetVO3:aCols[oGetDetVO3:nAt,nCntFor]))
		Help(" ",1,"OBRIGAT2",,STR0100 + CHR(13) + CHR(10) + RetTitle(oGetDetVO3:aHeader[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100PRFOK บAutor  ณ Takahashi          บ Data ณ  03/11/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ FieldOK da GetDados de Pecas - RESUMIDA                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100PRFOK(cReadVar)

Local nBkpN
Local cAuxGruIte

Default cReadVar := ReadVar()

//
//  PE que Valida digita็๕es das GetDados dos Grupos de Pe็as ou C๓digos de Pe็as
//  1o Parโmetro  - Indica se a alteracao foi feita na GetDados dos Grupos de Pe็as(Resumida) ou dos C๓digos de Pe็as(Detalhada)
//     D - GetDados de Pe็as
//     R - GetDados de Grupos de Pe็as
//  2o Parโmetro - cReadVar ( utilizar sempre este parโmetro e nunca ReadVar() )
//
If ExistBlock("OX100VLP")
	If !ExecBlock("OX100VLP",.f.,.f.,{"R",cReadVar})
		Return .f.
	Endif
EndIf
//

If cReadVar $ "M->VO3_VALDES,M->VO3_PERDES"
	
	nBkpN := n
	cAuxGruIte := M->VO3_GRUITE
	
	If cUsaAcres == "S" .and. M->VO3_ACRESC > 0 .and. (&(cReadVar) <> 0)
		Help( ,, 'Help',, STR0143, 1, 0 ) // "Para adicionar desconto por favor remova o acr้scimo"
		Return .f.
	EndIf
	
	If cReadVar == "M->VO3_PERDES"
		If M->VO3_PERDES > 99.99
			Help(" ",1,"OX100PERDES")
			Return .f.
		EndIf
		nTipDes := 1 // Calcula por Percentual
	Else
		If M->VO3_VALDES >= M->VO3_VALBRU
			Help(" ",1,"OX100VALDES")
			Return .f.
		EndIf
		nTipDes := 2 // Calcula por Valor
	EndIf
	
	OX100DPECA( 2 , oGetResVO3:nAt , nTipDes , M->VO3_PERDES , M->VO3_VALDES )
	
EndIf

If ExistBlock("OX100FOP")
	ExecBlock("OX100FOP",.f.,.f.,{"R",cReadVar})
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100SDFOK บAutor  ณ Takahashi          บ Data ณ 16/11/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ FieldOk da GetDados de Servicos - DETALHADA                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100SDFOK(cReadVar)

Local DVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Det")
Local DVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Det")
Local DVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Det")
Local DVO4PERDES := FG_POSVAR("VO4_PERDES","aHVO4Det")
Local DVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Det")
Local DVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Det")

Local nTipDes
Local aBkpAuxVO4 := {}  // Backup da Matriz aAuxVO4

Default cReadVar := ReadVar()

//
//  PE que Valida digita็๕es das GetDados dos Grupos de Servi็os ou C๓digos de Servi็os
//  1o Parโmetro  - Indica se a alteracao foi feita na GetDados dos Grupos de Servi็os(Resumida) ou dos C๓digos de Servi็os(Detalhada)
//     D - GetDados de Servi็os
//     R - GetDados de Grupos Servi็os
//  2o Parโmetro - cReadVar ( utilizar sempre este parโmetro e nunca ReadVar() )
//
If ExistBlock("OX100VLS")
	If !ExecBlock("OX100VLS",.f.,.f.,{"D",cReadVar})
		Return .f.
	Endif
EndIf
//

If cReadVar $ "M->VO4_VALDES,M->VO4_PERDES"
	If cReadVar == "M->VO4_PERDES"
		If M->VO4_PERDES > 99.99
			Help(" ",1,"OX100PERDES")
			Return .f.
		EndIf
		If M->VO4_VALBRU == 0
			Help(" ",1,"OX100VALDES")
			Return .f.
		EndIf
		nTipDes := 1 // Calcula por Percentual
	Else
		If M->VO4_VALDES >= M->VO4_VALBRU
			Help(" ",1,"OX100VALDES")
			Return .f.
		EndIf
		nTipDes := 2 // Calcula por Valor
	EndIf
	
	// Calcula o Desconto ...
	OX100DSRVC( nTipDes, @M->VO4_VALBRU, @M->VO4_VALTOT, @M->VO4_PERDES, @M->VO4_VALDES, M->VO4_TIPTEM, M->VO4_TIPSER , M->VO4_GRUSER , M->VO4_CODSER )
	//
	
	oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4VALBRU ] := M->VO4_VALBRU
	oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4PERDES ] := M->VO4_PERDES
	oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4VALDES ] := M->VO4_VALDES
	oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4VALTOT ] := M->VO4_VALTOT
	
	// Atualiza aCols com Resumo de Servicos
	OX100RESS( oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4TIPTEM] , oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4TIPSER] )
	
	// Atualiza Resumo ...
	OX100ATRES(.f.)
	
EndIf

If cReadVar == "M->VO4_VALBRU"
	
	// Verifica se ้ possivel alterar o valor bruto ...
	If !OX100VBRUS( "D" , oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4TIPTEM] , oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4TIPSER] , M->VO4_VALBRU , M->VO4_VALDES )
		Return .f.
	EndIf
	
	// Faz Backup para voltar se alguma retornar .F., volta o que era antes ...
	aBkpAuxVO4 := aClone(aAuxVO4)
	//
	
	OX100RAVO4( "D" , , , oGetDetVO4:nAt , M->VO4_VALBRU )
	
	// Se tiver informado algum valor de desconto, recalcula o mesmo (por VALOR)
	If M->VO4_VALDES <> 0
		If !OX100SDFOK("M->VO4_VALDES")
			aAuxVO4 := aClone(aBkpAuxVO4)
			Return .f.
		EndIf
		// Se nao tiver desconto chama as rotinas para atualiza็ใo dos Resumos
	Else
		oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4VALBRU ] := M->VO4_VALBRU
		oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4VALTOT ] := M->VO4_VALBRU
		
		// Atualiza aCols com Resumo de Servicos
		OX100RESS( oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4TIPTEM] , oGetDetVO4:aCols[oGetDetVO4:nAt, DVO4TIPSER] )
		
		// Atualiza Resumo ...
		OX100ATRES(.f.)
	EndIf
	//
EndIf

// Atualiza os Percentuais de Rateio da Matriz Aux. de Servicos
If cReadVar $ "M->VO4_VALDES,M->VO4_PERDES,M->VO4_VALBRU"
	OX100PAVO4(oGetDetVO4:aCols[ oGetDetVO4:nAt, DVO4TIPTEM], oGetDetVO4:aCols[ oGetDetVO4:nAt, DVO4TIPSER])
EndIf
//

// Se tiver condicao de pagamento informada, simular o FieldOK
If cReadVar $ "M->VO4_VALDES,M->VO4_PERDES,M->VO4_VALBRU,M->VO4_CODTES" .and. !Empty(M->VOO_CONDPG)
	OX100VOO("M->VOO_CONDPG", .f.)
EndIf
//
If ExistBlock("OX100FOS")
	ExecBlock("OX100FOS",.f.,.f.,{"D",cReadVar})
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100SRLOK บAutor  ณ Takahashi          บ Data ณ  15/03/16 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Linha OK da GetDados de Servicos - RESUMO                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100SRLOK()

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local nCntFor

// Linha em Branco
If Len(oGetResVO4:aCols) == 1 .and. Empty(oGetResVO4:aCols[1, RVO4TIPTEM])
	Return .t.
EndIf

For nCntFor:=1 to Len(oGetResVO4:aHeader)
	If X3Obrigat(oGetResVO4:aHeader[nCntFor,2])  .and. (Empty(oGetResVO4:aCols[oGetResVO4:nAt,nCntFor]))
		Help(" ",1,"OBRIGAT2",,STR0101 + CHR(13) + CHR(10) + " " + RetTitle(oGetResVO4:aHeader[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100SRFOK บAutor  ณ Takahashi          บ Data ณ 16/11/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ FieldOk da GetDados de Servicos - RESUMO                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100SRFOK(cReadVar)

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")
Local RVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Res")
Local RVO4PERDES := FG_POSVAR("VO4_PERDES","aHVO4Res")
Local RVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Res")
Local RVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Res")
Local RVO4CODTES := FG_POSVAR("VO4_CODTES","aHVO4Res")
Local RVO4OPER   := FG_POSVAR("VO4_OPER"  ,"aHVO4Res")

Local DVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Det")
Local DVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Det")
Local DVO4GRUSER := FG_POSVAR("VO4_GRUSER","aHVO4Det")
Local DVO4CODSER := FG_POSVAR("VO4_CODSER","aHVO4Det")
Local DVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Det")
Local DVO4PERDES := FG_POSVAR("VO4_PERDES","aHVO4Det")
Local DVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Det")
Local DVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Det")

Local nTipDes
Local nCntFor
Local nPerDes := 0    // Percentual de Desconto que serแ aplicado em todos os servicos
Local nValDesPre := 0   // Valor do Desconto Pretendido
Local nValDesAtu := 0   // Valor do Desconto Ja Aplicados nas Pecas
Local nValDesDif := 0   // Valor da Diferenca entre os Descontos Pretendido e Aplicado
Local aAuxDesc := {}
Local nPosDet := 0
Local nAuxValTot := 0
Local nAuxPerDes := 0
Local nAuxValDes := 0
Local aBkpAuxVO4 := {}  // Backup da Matriz aAuxVO4
Local nAuxCont := 0
Local nBkpN
Local cAuxTES

Default cReadVar := ReadVar()

//
//  PE que Valida digita็๕es das GetDados dos Grupos de Servi็os ou C๓digos de Servi็os
//  1o Parโmetro  - Indica se a alteracao foi feita na GetDados dos Grupos de Servi็os(Resumida) ou dos C๓digos de Servi็os(Detalhada)
//     D - GetDados de Servi็os
//     R - GetDados de Grupos Servi็os
//  2o Parโmetro - cReadVar ( utilizar sempre este parโmetro e nunca ReadVar() )
//
If ExistBlock("OX100VLS")
	If !ExecBlock("OX100VLS",.f.,.f.,{"R",cReadVar})
		Return .f.
	Endif
EndIf
//

If cReadVar $ "M->VO4_VALDES,M->VO4_PERDES"
	If cReadVar == "M->VO4_PERDES"
		If M->VO4_PERDES > 99.99
			Help(" ",1,"OX100PERDES")
			Return .f.
		EndIf
		If M->VO4_VALBRU == 0
			Help(" ",1,"OX100VALDES")
			Return .f.
		EndIf
		nTipDes := 1 // Calcula por Percentual
	Else
		If M->VO4_VALDES >= M->VO4_VALBRU
			Help(" ",1,"OX100VALDES")
			Return .f.
		EndIf
		nTipDes := 2 // Calcula por Valor
	EndIf
	
	// Calcula desconto
	OX100DESC(nTipDes, @M->VO4_VALBRU, 1 , @M->VO4_VALTOT, @M->VO4_PERDES, @M->VO4_VALDES )
	nPerDes := M->VO4_PERDES
	nValDesPre := M->VO4_VALDES
	//
	
	// Aplica os Descontos em Todos os Servicos com o Mesmo Tipo de Servico
	nValDesAtu := 0
	For nCntFor := 1 to Len(oGetDetVO4:aCols)
		
		If oGetDetVO4:aCols[nCntFor, DVO4TIPSER] <> M->VO4_TIPSER
			Loop
		EndIf
		oGetDetVO4:aCols[nCntFor, DVO4PERDES] := nPerDes
		// Calcula o Desconto ...
		OX100DSRVC( 1, ;
						@oGetDetVO4:aCols[nCntFor, DVO4VALBRU],;
						@oGetDetVO4:aCols[nCntFor, DVO4VALTOT],;
						@oGetDetVO4:aCols[nCntFor, DVO4PERDES],;
						@oGetDetVO4:aCols[nCntFor, DVO4VALDES],;
						oGetDetVO4:aCols[nCntFor, DVO4TIPTEM],;
						oGetDetVO4:aCols[nCntFor, DVO4TIPSER],;
						oGetDetVO4:aCols[nCntFor, DVO4GRUSER],;
						oGetDetVO4:aCols[nCntFor, DVO4CODSER] )
		//
		nValDesAtu += oGetDetVO4:aCols[nCntFor, DVO4VALDES]
		
	Next nCntFor
	//
	
	// Se der Diferenca entre o DESCONTO pretendido e o calculado,
	// tenta jogar a diferenca em algum servico ...
	If nValDesAtu <> nValDesPre
		//    Alert("Valor de desconto Pretendido: " + Str(nValDesPre,10,2) + CHR(13) + CHR(10) + ;
		//        "Valor de desconto Atual: " + Str(nValDesAtu,10,2) )
		nValDesDif := nValDesPre - nValDesAtu
		
		// Cria uma Matriz Auxiliar para Aplicar a Diferenca de Desconto
		// Primeiro nos servicos mais caros ...
		aAuxDesc := {}
		For nPosDet := 1 to Len(oGetDetVO4:aCols)
			If oGetDetVO4:aCols[nPosDet, DVO4TIPSER] == M->VO4_TIPSER
				AADD( aAuxDesc, { nPosDet , oGetDetVO4:aCols[nPosDet, DVO4VALBRU] } )
			EndIf
		Next nPosDet
		aSort(aAuxDesc,,,{|x,y| x[2] > y[2] })
		//
		
		For nCntFor := 1 to Len(aAuxDesc)
			
			nPosDet := aAuxDesc[nCntFor,1]
			
			nAuxValTot := oGetDetVO4:aCols[nPosDet, DVO4VALTOT ]
			nAuxPerDes := oGetDetVO4:aCols[nPosDet, DVO4PERDES ]
			nAuxValDes := oGetDetVO4:aCols[nPosDet, DVO4VALDES ] + nValDesDif
			
			// Aplica desconto por valor ...
			OX100DSRVC( 2, ;
							oGetDetVO4:aCols[nPosDet,DVO4VALBRU], ;
							@nAuxValTot, ;
							@nAuxPerDes, ;
							@nAuxValDes, ;
							oGetDetVO4:aCols[nPosDet, DVO4TIPTEM], ;
							oGetDetVO4:aCols[nPosDet, DVO4TIPSER], ;
							oGetDetVO4:aCols[nPosDet, DVO4GRUSER], ;
							oGetDetVO4:aCols[nPosDet, DVO4CODSER])
			
			// Conseguiu aplicar a diferenca em algum produto ...
			If nAuxValDes == (oGetDetVO4:aCols[nPosDet, DVO4VALDES ] + nValDesDif)
				oGetDetVO4:aCols[nPosDet, DVO4VALTOT ] := nAuxValTot
				oGetDetVO4:aCols[nPosDet, DVO4PERDES ] := nAuxPerDes
				oGetDetVO4:aCols[nPosDet, DVO4VALDES ] := nAuxValDes
				nValDesDif := 0
				Exit
			EndIf
			//
		Next nCntFor
		
		If nValDesDif <> 0
			M->VO4_VALDES += nValDesDif
			OX100DESC(2, @M->VO4_VALBRU, 1, @M->VO4_VALTOT, @M->VO4_PERDES, @M->VO4_VALDES )
		EndIf
		
	EndIf
	
	oGetDetVO4:oBrowse:Refresh()
	
	oGetResVO4:aCols[oGetResVO4:nAt, RVO4VALBRU ] := M->VO4_VALBRU
	oGetResVO4:aCols[oGetResVO4:nAt, RVO4PERDES ] := M->VO4_PERDES
	oGetResVO4:aCols[oGetResVO4:nAt, RVO4VALDES ] := M->VO4_VALDES
	oGetResVO4:aCols[oGetResVO4:nAt, RVO4VALTOT ] := M->VO4_VALTOT
	
	// Atualiza aCols com Resumo de Servicos
	OX100RESS( oGetResVO4:aCols[oGetResVO4:nAt, RVO4TIPTEM] , oGetResVO4:aCols[oGetResVO4:nAt, RVO4TIPSER] )
	
	// Atualiza Resumo ...
	OX100ATRES(.f.)
	
ElseIf cReadVar == "M->VO4_VALBRU"
	
	// Verifica se ้ possivel alterar o valor bruto ...
	If !OX100VBRUS( "R" , oGetResVO4:aCols[oGetResVO4:nAt, RVO4TIPTEM] , oGetResVO4:aCols[oGetResVO4:nAt, RVO4TIPSER] , M->VO4_VALBRU , M->VO4_VALDES )
		Return .f.
	EndIf
	
	// Faz Backup para voltar se alguma retornar .F., volta o que era antes ...
	aBkpAuxVO4 := aClone(aAuxVO4)
	aBkpDetVO4 := aClone(oGetDetVO4:aCols)
	//
	
	// Rateia valor bruto
	If !OX100RVLB(oGetResVO4:aCols[oGetResVO4:nAt, RVO4TIPTEM], oGetResVO4:aCols[oGetResVO4:nAt, RVO4TIPSER] , M->VO4_VALBRU )
		aAuxVO4 := aClone(aBkpAuxVO4)
		oGetDetVO4:aCols := aClone(aBkpDetVO4)
		Return .f.
	EndIf
	//
	
	// Se tiver informado algum valor de desconto, recalcula o mesmo (por VALOR)
	If M->VO4_VALDES <> 0
		If !OX100SRFOK("M->VO4_VALDES")
			aAuxVO4 := aClone(aBkpAuxVO4)
			oGetDetVO4:aCols := aClone(aBkpDetVO4)
			Return .f.
		EndIf
		// Se nao tiver desconto chama as rotinas para atualiza็ใo dos Resumos
	Else
		
		// Atualiza aCols com Resumo de Servicos
		OX100RESS( oGetResVO4:aCols[oGetResVO4:nAt, RVO4TIPTEM] , oGetResVO4:aCols[oGetResVO4:nAt, RVO4TIPSER] )
		
		// Atualiza Resumo ...
		OX100ATRES(.f.)
		
		oGetDetVO4:oBrowse:Refresh()
	EndIf
	//
	
ElseIf cReadVar == "M->VO4_CODTES"
	
	// Atualiza Fiscal ...
	nBkpN := n
	OX100SRVFIS( oGetResVO4:nAt )
	// Altera o RECNO do TES no MATXFIS, pois ele posiciona na tabela de TES pelo RECNO
	// e quando a TES ้ alterada atrav้s do MaFisRef, o RECNO nใo ้ atualizado
	MaFisLoad("IT_RECNOSF4",SF4->(Recno()), n)
	MaFisRef("IT_TES","VO300",M->VO4_CODTES)
	n := nBkpN
	//
	
	// Atualiza Resumo ...
	OX100ATRES(.f.)
	
ElseIf cReadVar == "M->VO4_OPER"
	
	VOK->(dbSetOrder(1))
	If !VOK->(dbSeek(xFilial("VOK")+M->VO4_TIPSER))
		return .t.
	EndIf
	
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1") + VOK->VOK_GRUITE + VOK->VOK_CODITE)
	dbSetOrder(1)
	cAuxTES := MaTesInt(2,M->VO4_OPER,MaFisRet(,"NF_CODCLIFOR"),MaFisRet(,"NF_LOJA"),"C",SB1->B1_COD,,MaFisRet(,"NF_TPCLIFOR"))
	If Empty(cAuxTES)
		cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
	Endif
	
	If !Empty(cAuxTES)
		SF4->(dbSetOrder(1))
		If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
			Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + cAuxTES ,4,1)
			Return .f.
		EndIf
		oGetResVO4:aCols[oGetResVO4:nAt, RVO4CODTES] := M->VO4_CODTES := cAuxTES
		oGetResVO4:aCols[oGetResVO4:nAt, RVO4OPER  ] := M->VO4_OPER
		
		OX100SRFOK("M->VO4_CODTES")
	EndIf
	
EndIf

// Atualiza os Percentuais de Rateio da Matriz Aux. de Servicos
If cReadVar $ "M->VO4_VALDES,M->VO4_PERDES,M->VO4_VALBRU"
	OX100PAVO4( oGetResVO4:aCols[ oGetResVO4:nAt, RVO4TIPTEM] , oGetResVO4:aCols[ oGetResVO4:nAt, RVO4TIPSER] )
EndIf

// Se tiver condicao de pagamento informada, simular o FieldOK
If cReadVar $ "M->VO4_VALDES,M->VO4_PERDES,M->VO4_VALBRU,M->VO4_CODTES" .and. !Empty(M->VOO_CONDPG)
	OX100VOO("M->VOO_CONDPG", .f.)
EndIf
//
If ExistBlock("OX100FOS")
	ExecBlock("OX100FOS",.f.,.f.,{"R",cReadVar})
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VBRUS บAutor  ณ Takahashi          บ Data ณ  18/07/14 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se ้ possํvel alterar o valor bruto                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOrigem = Indica se parte da GetDados do Resumo ou Detalhe บฑฑ
ฑฑบ          ณ cTipTem = Tipo de tempo para filtro no processamento       บฑฑ
ฑฑบ          ณ cTipSer = Tipo de servico para filtro no processamento     บฑฑ
ฑฑบ          ณ nValBru = Valor bruto                                      บฑฑ
ฑฑบ          ณ nValDes = Valor de desconto                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100VBRUS( cOrigem , cTipTem , cTipSer , nValBru , nValDes )

Local nAuxCont := 0

VOK->(dbSetOrder(1))
VOK->(dbSeek( xFilial("VOK") + cTipSer ))
// Para estes tipos de servicos nao sera possivel alterar o valor bruto.
// 0=Por Mao-de-Obra Gratuita;1=Por Mao-de-Obra;2=Srv de Terceiro
// ATENCAO: se essa regra for alterada, verificar a rotina de rateio de valor bruto ...
If VOK->VOK_INCMOB $ "0/1/2"
	Help(" ",1,"OX100ALTVLB")
	return .f.
EndIf

If nValBru <= 0
	Help(" ",1,"POSIT")
	return .f.
EndIf

// Se for tipo de tempo interno, so pode alterar valor bruto na getdados
// de resumo quando possui somente um servico ...
If cOrigem == "R"
	VOI->(dbSetOrder(1))
	VOI->(MsSeek(xFilial("VOI") + cTipTem))
	If VOI->VOI_SITTPO == "3" .and. VOK->VOK_INCMOB <> "3"
		nAuxCont := 0
		aEval(oGetDetVO4:aCols,{ |x| IIf( (x[FG_POSVAR("VO4_TIPTEM","aHVO4Det")] == cTipTem .and. x[FG_POSVAR("VO4_TIPSER","aHVO4Det")] == cTipSer) , ++nAuxCont , NIL ) })
		If nAuxCont > 1
			Help(" ",1,"OX100SRVVLB")
			Return .f.
		EndIf
	EndIf
EndIf

If nValDes >= nValBru
	Help(" ",1,"OX100VALDES")
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100DPECA บAutor  ณ Takahashi          บ Data ณ 12/05/11  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Tenta aplicar desconto na Peca                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nPAplic = Indica se aplicarแ o Desconto no Item ou Grupo   บฑฑ
ฑฑบ          ณ           1 = Item / 2 = Grupo do Item                     บฑฑ
ฑฑบ          ณ nPLinGD = Linha do GetDados que foi digitado o Desconto    บฑฑ
ฑฑบ          ณ nPTipDes = Tipo do Desconto (1 % OU 2 R$)                  บฑฑ
ฑฑบ          ณ nPPerDes = Percentual de Desconto                          บฑฑ
ฑฑบ          ณ nPValDes = Valor do Desconto                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRetorno = Indica se foi possivel aplicar o desconto       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100DPECA( nPAplic, nPLinGD, nPTipDes, nPPerDes, nPValDes )

Local DVO3TIPTEM  := FG_POSVAR("VO3_TIPTEM","aHVO3Det")
Local DVO3GRUITE  := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3CODITE  := FG_POSVAR("VO3_CODITE","aHVO3Det")
Local DVO3PERDES  := FG_POSVAR("VO3_PERDES","aHVO3Det")
Local DVO3VALDES  := FG_POSVAR("VO3_VALDES","aHVO3Det")
Local DVO3VALPEC  := FG_POSVAR("VO3_VALPEC","aHVO3Det")
Local DVO3VALTOT  := FG_POSVAR("VO3_VALTOT","aHVO3Det")
Local DVO3QTDREQ  := FG_POSVAR("VO3_QTDREQ","aHVO3Det")

Local RVO3TIPTEM  := FG_POSVAR("VO3_TIPTEM","aHVO3Res")
Local RVO3GRUITE  := FG_POSVAR("VO3_GRUITE","aHVO3Res")
Local RVO3PERDES  := FG_POSVAR("VO3_PERDES","aHVO3Res")
Local RVO3VALBRU  := FG_POSVAR("VO3_VALBRU","aHVO3Res")
Local RVO3VALDES  := FG_POSVAR("VO3_VALDES","aHVO3Res")
Local RVO3VALTOT  := FG_POSVAR("VO3_VALTOT","aHVO3Res")

Local lRetorno    := .t.
Local nQtdReq     := 0
Local nValPecCalc := 0
Local nValTotCalc := 0
Local nPerDesCalc := 0
Local nValDesCalc := 0

Local nValDesDet  := 0 // Soma todos os descontos no detalhe para verificacao quando aplicado desconto no GRUPO
Local nValDesDif  := 0 // Diferenca entre o desconto calculado no Grupo e o aplicado nos ITENS
Local aAuxDesc    := {}
Local nPosDet     := 0
Local nCntFor     := 0
Local nBkpN       := 0
Local nBkpNDet    := 0
Local nBkpValDes  := 0

Local nXDesc      := 0
Local nX          := 0

Local cTipTemResumo := ""
Local cGruIteResumo := ""

aTempoProc := {}

If nPAplic == 1 // Aplica o Desconto no Item ...
	
	nQtdReq     := M->VO3_QTDREQ
	nValPecCalc := M->VO3_VALPEC
	nPerDesCalc := M->VO3_PERDES
	nValDesCalc := M->VO3_VALDES
	nValTotCalc := M->VO3_VALTOT
	
	// Calcula o Desconto
	OX100DESC(nPTipDes,;
				@nValPecCalc,;
				nQtdReq,;
				@nValTotCalc,;
				@nPerDesCalc,;
				@nValDesCalc )
	
	If nPTipDes == 1
		// Calcula o Desconto por Valor ...
		OX100DESC(2,;
					@nValPecCalc,;
					nQtdReq,;
					@nValTotCalc,;
					@nPerDesCalc,;
					@nValDesCalc )
	EndIf
	
	//
	nPerDesCalc := round( ( nValDesCalc / ( nValTotCalc + nValDesCalc ) ) * 100 , 2 ) // Calcular corretamente o Percentual de Desconto
	//
	
	oGetDetVO3:aCols[nPLinGD, DVO3VALPEC] := M->VO3_VALPEC := nValPecCalc
	oGetDetVO3:aCols[nPLinGD, DVO3PERDES] := M->VO3_PERDES := nPerDesCalc
	oGetDetVO3:aCols[nPLinGD, DVO3VALDES] := M->VO3_VALDES := nValDesCalc
	oGetDetVO3:aCols[nPLinGD, DVO3VALTOT] := M->VO3_VALTOT := nValTotCalc  + IIF( cUsaAcres == 'S', M->VO3_ACRESC, 0 )
	
	// Atualiza o Fiscal do Item
	OX100PECFIS( nPLinGD )
	MaFisRef("IT_DESCONTO","VO300",oGetDetVO3:aCols[nPLinGD , DVO3VALDES])
	OX100FISPEC( nPLinGD )
	//
	
	nValPecCalc := 0
	nPerDesCalc := 0
	nValDesCalc := 0
	nValTotCalc := 0
	// Calcula o Valor Total e Total de Desconto do Grupo ...
	nPosResumo := aScan( oGetResVO3:aCols , { |x| x[RVO3TIPTEM] == oGetDetVO3:aCols[nPLinGD,DVO3TIPTEM] .and. x[RVO3GRUITE] == oGetDetVO3:aCols[nPLinGD, DVO3GRUITE] } )
	oGetResVO3:aCols[nPosResumo, RVO3VALDES ] := 0
	//
	
	// Recalcula o Valor do Desconto (Por Valor) do Grupo na GetDados de Resumo ...
	aEval( oGetDetVO3:aCols, {|x| IIF ( (x[DVO3TIPTEM] == oGetDetVO3:aCols[nPLinGD,DVO3TIPTEM] .and. x[DVO3GRUITE] == oGetDetVO3:aCols[nPLinGD, DVO3GRUITE]) , oGetResVO3:aCols[nPosResumo, RVO3VALDES ] += x[DVO3VALDES] , ) } )
	OX100DESC(2, ;
				oGetResVO3:aCols[nPosResumo,RVO3VALBRU],;
				1,;
				@oGetResVO3:aCols[nPosResumo, RVO3VALTOT ], ;
				@oGetResVO3:aCols[nPosResumo, RVO3PERDES ], ;
				@oGetResVO3:aCols[nPosResumo, RVO3VALDES ] )
	//
	
ElseIf nPAplic == 2 // Aplica o Desconto no Grupo ...
	
	//OX100TempoProc()
	
	nQtdReq := 1
	nValPecCalc := M->VO3_VALBRU
	nPerDesCalc := M->VO3_PERDES
	nValDesCalc := M->VO3_VALDES
	nValTotCalc := M->VO3_VALTOT
	
	// Calcula o Desconto para o Grupo
	OX100DESC(nPTipDes,;
				@nValPecCalc,;
				nQtdReq,;
				@nValTotCalc,;
				@nPerDesCalc,;
				@nValDesCalc )
	//
	
	//OX100TempoProc("Calculo do Desconto do Grupo")
	
	cTipTemResumo := oGetResVO3:aCols[nPLinGD, RVO3TIPTEM]
	cGruIteResumo := oGetResVO3:aCols[nPLinGD, RVO3GRUITE]
	
	// Aplica o Desconto em Todos os Itens ...
	For nPosDet := 1 to Len(oGetDetVO3:aCols)
		If oGetDetVO3:aCols[nPosDet, DVO3TIPTEM] == cTipTemResumo .and. oGetDetVO3:aCols[nPosDet, DVO3GRUITE] == cGruIteResumo
			
			//OX100TempoProc()
			
			// Utilizar percentual de Desconto do Grupo, zerar caso o valor total de desconto ja foi atingido
			oGetDetVO3:aCols[nPosDet, DVO3PERDES] := IIf(nValDesDet<>nValDesCalc,nPerDesCalc,0)
			
			// Calcula o Desconto por Percentual ...
			OX100DESC(1, ;
						oGetDetVO3:aCols[nPosDet, DVO3VALPEC],;
						oGetDetVO3:aCols[nPosDet, DVO3QTDREQ],;
						@oGetDetVO3:aCols[nPosDet, DVO3VALTOT],;
						@oGetDetVO3:aCols[nPosDet, DVO3PERDES],;
						@oGetDetVO3:aCols[nPosDet, DVO3VALDES] )
			
			// Calcula o Desconto por Valor ...
			OX100DESC(2, ;
						oGetDetVO3:aCols[nPosDet, DVO3VALPEC],;
						oGetDetVO3:aCols[nPosDet, DVO3QTDREQ],;
						@oGetDetVO3:aCols[nPosDet, DVO3VALTOT],;
						@oGetDetVO3:aCols[nPosDet, DVO3PERDES],;
						@oGetDetVO3:aCols[nPosDet, DVO3VALDES] )
			
			//OX100TempoProc( oGetDetVO3:aCols[nPosDet, DVO3GRUITE] + " - " + oGetDetVO3:aCols[nPosDet, DVO3CODITE])
			
			// Caso o desconto da PECA + o Desconto acumulado eh maior que o Desconto Total do Grupo
			If ( oGetDetVO3:aCols[nPosDet,DVO3VALDES] + nValDesDet ) > nValDesCalc
				
				//OX100TempoProc()
				
				nXDesc := ( oGetDetVO3:aCols[nPosDet, DVO3VALDES] * 100 ) // utilizar decimal
				For nX := 1 to nXDesc
					//
					oGetDetVO3:aCols[nPosDet, DVO3VALDES] := ( ( nXDesc - nx ) / 100 ) // voltar decimal
					// Calcula o Desconto por Valor ...
					OX100DESC(2, ;
								oGetDetVO3:aCols[nPosDet, DVO3VALPEC],;
								oGetDetVO3:aCols[nPosDet, DVO3QTDREQ],;
								@oGetDetVO3:aCols[nPosDet, DVO3VALTOT],;
								@oGetDetVO3:aCols[nPosDet, DVO3PERDES],;
								@oGetDetVO3:aCols[nPosDet, DVO3VALDES] )
					// Caso o Valor do Desconto Calculado + o Desconto acumulado eh menor que o Desconto Total
					If ( oGetDetVO3:aCols[nPosDet, DVO3VALDES] + nValDesDet) <= nValDesCalc
						Exit
					EndIf
				Next
				
				//OX100TempoProc("Desconto aplicado maior do que desconto do grupo")
				
			EndIf
			
			// Calcular corretamente o Percentual de Desconto
			oGetDetVO3:aCols[nPosDet, DVO3PERDES] := round( ( oGetDetVO3:aCols[nPosDet, DVO3VALDES] / ( oGetDetVO3:aCols[nPosDet, DVO3VALTOT] + oGetDetVO3:aCols[nPosDet, DVO3VALDES] ) ) * 100 , 2 )
			//
			
			nValDesDet += oGetDetVO3:aCols[nPosDet, DVO3VALDES] // Somar Descontos
			
			If oGetDetVO3:aCols[nPosDet, DVO3VALDES] == 0
				oGetDetVO3:aCols[nPosDet, DVO3PERDES] := 0 // Zerar percentual de desconto caso o valor do desconto for zero
			EndIf
			
		EndIf
	Next nPosDet
	//
	
	// Se der Diferenca entre o pretendido e o calculado,
	// tenta jogar a diferenca em algum produto ...
	If nValDesDet <> nValDesCalc
		
		//OX100TempoProc()
		
		nValDesDif := nValDesCalc - nValDesDet
		
		// Cria uma Matriz Auxiliar para Aplicar a Diferenca de Desconto
		aAuxDesc := {}
		For nPosDet := 1 to Len(oGetDetVO3:aCols)
			If oGetDetVO3:aCols[nPosDet, DVO3TIPTEM] == cTipTemResumo .and. oGetDetVO3:aCols[nPosDet, DVO3GRUITE] == cGruIteResumo
				AADD( aAuxDesc, { nPosDet , ;
										oGetDetVO3:aCols[nPosDet, DVO3QTDREQ] , ;
										oGetDetVO3:aCols[nPosDet, DVO3VALPEC] , ;
										oGetDetVO3:aCols[nPosDet, DVO3VALTOT] ,;
										oGetDetVO3:aCols[nPosDet, DVO3VALDES] } )
			EndIf
		Next nPosDet
		
		// Primeiro nos produtos com maior desconto ...
		aSort(aAuxDesc,,,{|x,y| x[5] > y[5] })
		//
		For nCntFor := 1 to Len(aAuxDesc)
			
			If ( round((aAuxDesc[nCntFor,5]+nValDesDif)/aAuxDesc[nCntFor,2],2) == ((aAuxDesc[nCntFor,5]+nValDesDif)/aAuxDesc[nCntFor,2]) )
				
				nPosDet := aAuxDesc[nCntFor,1]
				
				nAuxValTot := oGetDetVO3:aCols[nPosDet, DVO3VALTOT ]
				nAuxPerDes := oGetDetVO3:aCols[nPosDet, DVO3PERDES ]
				nAuxValDes := oGetDetVO3:aCols[nPosDet, DVO3VALDES ] + nValDesDif
				OX100DESC(2,;
							oGetDetVO3:aCols[nPosDet, DVO3VALPEC],;
							oGetDetVO3:aCols[nPosDet, DVO3QTDREQ],;
							@nAuxValTot,;
							@nAuxPerDes,;
							@nAuxValDes )
				
				// Conseguiu aplicar a diferenca em algum produto ...
				If nAuxValDes == (oGetDetVO3:aCols[nPosDet, DVO3VALDES ] + nValDesDif)
					oGetDetVO3:aCols[nPosDet, DVO3VALTOT ] := nAuxValTot// TODO:  + IIF( cUsaAcres == 'S', M->VO3_ACRESC, 0 )
					oGetDetVO3:aCols[nPosDet, DVO3PERDES ] := nAuxPerDes
					oGetDetVO3:aCols[nPosDet, DVO3VALDES ] := nAuxValDes
					nValDesDif := 0
					Exit
				EndIf
				
			EndIf
			//
		Next
		
		// Recalcula o desconto do grupo, considerando a Diferenca que nao foi possivel
		// ratear entre os itens ...
		If nValDesDif <> 0
			//      Alert("Nao foi possivel acertar o desconto")
			nValDesCalc := nValDesDet
			
			// Calcula o Desconto para o Grupo
			OX100DESC(2,;
						@nValPecCalc,;
						nQtdReq,;
						@nValTotCalc,;
						@nPerDesCalc,;
						@nValDesCalc )
			//
		EndIf
		
		//OX100TempoProc("Ajuste final dos descontos")
		
	EndIf
	
	oGetResVO3:aCols[nPLinGD, RVO3VALBRU] := M->VO3_VALBRU := nValPecCalc
	oGetResVO3:aCols[nPLinGD, RVO3PERDES] := M->VO3_PERDES := nPerDesCalc
	oGetResVO3:aCols[nPLinGD, RVO3VALDES] := M->VO3_VALDES := nValDesCalc
	oGetResVO3:aCols[nPLinGD, RVO3VALTOT] := M->VO3_VALTOT := nValTotCalc
	
	// Atualiza o Fiscal ...
	nBkpN      := n
	nBkpNDet   := oGetDetVO3:nAt
	nBkpValDes := M->VO3_VALDES
	//
	For nPosDet := 1 to Len(oGetDetVO3:aCols)
		If oGetDetVO3:aCols[nPosDet, DVO3TIPTEM] == cTipTemResumo .and. oGetDetVO3:aCols[nPosDet, DVO3GRUITE] == cGruIteResumo
			
			//OX100TempoProc()
			//
			OX100PECFIS( nPosDet )
			MaFisRef("IT_DESCONTO","VO300",oGetDetVO3:aCols[nPosDet , DVO3VALDES])
			//
			oGetDetVO3:nAt := nPosDet
			FG_MEMVAR( oGetDetVO3:aHeader, oGetDetVO3:aCols, oGetDetVO3:nAt )
			//
			M->VO3_VALDES := oGetDetVO3:aCols[nPosDet , DVO3VALDES] // Carregar Valor de Desconto por Item ( variavel pode ser utilizada na Formula da Margem de Lucro Oficina )
			//
			OX100UPDMrg() // Recalcular o % da Margem de Lucro Oficina
			//
			//OX100TempoProc("Atualizando Fiscal " + M->VO3_TIPTEM + "-" + M->VO3_GRUITE + "-" + M->VO3_CODITE)
		EndIf
	Next nPosDet
	//
	n              := nBkpN
	oGetDetVO3:nAt := nBkpNDet
	M->VO3_VALDES  := nBkpValDes
	//
	
	FG_MEMVAR( oGetResVO3:aHeader, oGetResVO3:aCols, nPLinGD)
	
EndIf

oGetResVO3:oBrowse:Refresh()
oGetDetVO3:oBrowse:Refresh()
OX100ATRES(.f.)

// Se tiver condicao de pagamento informada, simular o FieldOK
// para recalcular valor das parcelas ...
If !Empty(M->VOO_CONDPG)
	OX100VOO("M->VOO_CONDPG", .f.)
EndIf
//
//OX100VisualizaTempoProc()

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100DSRVC บAutor  ณ Takahashi          บ Data ณ 16/11/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Tenta aplicar desconto no Servico                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTipDes = Forma de Calc. de desconto (1=Valor/2=Percentual)บฑฑ
ฑฑบ          ณ nValBru = Valor total por Tipo/Grupo e Codigo do Servico   บฑฑ
ฑฑบ          ณ nValTot = Tipo de Servico                                  บฑฑ
ฑฑบ          ณ nPerDes = Percentual de Desconto                           บฑฑ
ฑฑบ          ณ nValDes = Valor do Desconto                                บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑบ          ณ cTipSer = Tipo de Servico                                  บฑฑ
ฑฑบ          ณ cGruSer = Grupo de Servico                                 บฑฑ
ฑฑบ          ณ cCodSer = Codigo do Servico                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRetorno = Indica se foi possivel aplicar o desconto       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100DSRVC( nTipDes, nValBru, nValTot, nPerDes, nValDes, cTipTem, cTipSer, cGruSer, cCodSer )

Local nRatValDes := 0 // Valor do Desconto Rateado entre Todos os Servicos
Local nAuxValDes := 0
Local lRetorno := .t.

// Calcula desconto
OX100DESC(nTipDes, @nValBru, 1 , @nValTot, @nPerDes, @nValDes )

// Aplica o Desconto na Matriz Auxiliar
nRatValDes := OX100RATDE(nTipDes, cTipTem, cTipSer , cGruSer , cCodSer , nPerDes, nValDes , nValBru )

// Recalcula Desconto por VALOR
If nRatValDes <> nValDes
	nAuxValDes := nValDes
	OX100DESC(1, @nValBru, 1 , @nValTot, @nPerDes, @nValDes )
	If nAuxValDes <> nValDes
		lRetorno := .f.
	EndIf
EndIf
//

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100RATDE บAutor  ณ Takahashi          บ Data ณ 16/11/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rateia o valor do desconto na matriz auxiliar com todos    บฑฑ
ฑฑบ          ณ os servicos carregados para o fechamento                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTipDes = Forma de Calc. de desconto (1=Valor/2=Percentual)บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑบ          ณ cTipSer = Tipo de Servico                                  บฑฑ
ฑฑบ          ณ cGruSer = Grupo de Servico                                 บฑฑ
ฑฑบ          ณ cCodSer = Codigo do Servico                                บฑฑ
ฑฑบ          ณ nPerDes = Percentual de Desconto                           บฑฑ
ฑฑบ          ณ nValDes = Valor do Desconto                                บฑฑ
ฑฑบ          ณ nValBru = Valor total por Tipo/Grupo e Codigo do Servico   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100RATDE( nTipDes , cTipTem, cTipSer , cGruSer , cCodSer , nPerDes , nValDes , nValBru)

Local nValDesPre := 0 // Valor do Desconto Pretendido
Local nValDesAtu := 0 // Valor do Desconto Ja Aplicados nos Servicos
Local nValDesDif := 0 // Valor da Diferenca dos Descontos
Local nValDesSrv := 0 // Valor do Desconto do Servico na Posicao Atual ...
Local nPerDesSrv := 0 // Percentual do Desconto do Servico na Posicao Atual ...
Local nValTotSrv := 0 // Valor Total do Servico na Posicao Atual ...
Local nPosAux := 0

nValDesPre := nValDes

For nPosAux := 1 to Len(aAuxVO4)
	If !(aAuxVO4[nPosAux,AS_TIPTEM] == cTipTem .and.;
		aAuxVO4[nPosAux,AS_TIPSER] == cTipSer .and. ;
		aAuxVO4[nPosAux,AS_GRUSER] == cGruSer .and. ;
		aAuxVO4[nPosAux,AS_CODSER] == cCodSer)
		Loop
	EndIf
	
	// Calcula o valor do desconto para o Servico (Rateio)
	nValDesSrv := aAuxVO4[nPosAux,AS_VALBRU] / nValBru  // Valor Bruto do Servico / Valor Bruto de Todos os Servicos Iguais ...
	nValDesSrv := A410Arred( nValDes * nValDesSrv , "VZ1_VALDES" )
	//
	
	nPerDesSrv := 0
	nValTotSrv := 0
	
	// Calcula Desconto do Servico
	OX100DESC(2, aAuxVO4[nPosAux,AS_VALBRU], 1 , nValTotSrv, @nPerDesSrv, @nValDesSrv )
	
	aAuxVO4[nPosAux,AS_PERDES] := nPerDesSrv
	aAuxVO4[nPosAux,AS_VALDES] := nValDesSrv
	nValDesAtu += nValDesSrv
	
Next nPosAux

// Se der Diferenca entre o pretendido e o calculado,
// tenta jogar a diferenca em algum servico ...
If nValDesAtu <> nValDesPre
	//  Alert("Valor de desconto Pretendido: " + Str(nValDesPre,10,2) + CHR(13) + CHR(10) + ;
	//      "Valor de desconto Atual: " + Str(nValDesAtu,10,2) )
	
	nValDesDif := nValDesPre - nValDesAtu
	
	For nPosAux := 1 to Len(aAuxVO4)
		
		If !(aAuxVO4[nPosAux,AS_TIPTEM] == cTipTem .and.;
			aAuxVO4[nPosAux,AS_TIPSER] == cTipSer .and. ;
			aAuxVO4[nPosAux,AS_GRUSER] == cGruSer .and. ;
			aAuxVO4[nPosAux,AS_CODSER] == cCodSer)
			Loop
		EndIf
		
		nPerDesSrv := 0
		nValTotSrv := 0
		nValDesSrv := aAuxVO4[nPosAux,AS_VALDES] + nValDesDif
		
		OX100DESC(2, aAuxVO4[nPosAux,AS_VALBRU] , 1 , @nValTotSrv, @nPerDesSrv, @nValDesSrv )
		
		// Conseguiu aplicar a diferenca em algum produto ...
		If nValDesSrv == (aAuxVO4[nPosAux,AS_VALDES] + nValDesDif)
			aAuxVO4[nPosAux,AS_PERDES] := nPerDesSrv
			aAuxVO4[nPosAux,AS_VALDES] := nValDesSrv
			nValDesAtu += nValDesDif
			Exit
		EndIf
		//
	Next nPosAux
	
EndIf

Return nValDesAtu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100SNEG  บAutor  ณ Takahashi          บ Data ณ  11/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Salva Negociacao Atual                                     บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบParametrosณ lPergunta = Indica se exibe msg para salvar a negociacao   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100SNEG(lPergunta)

Local nCntFor
Local nPosGet
Local nXi
Local nForVS9
Local nForHVS9

Local cAliasVZ1 := "TVZ1"
Local lSeekVZ1
Local nRecVZ1

Local nValTot
Local nPerdes
Local nValDes
Local cSQL
Local nCntOS      // Contador de OS Selecionadas para Fechamento
Local nVOODESACE
Local nVOOFRETE
Local nVOOSEGURO

Local aVZ1RecAtu := {}  // Contem os Recno (VZ1) ja gravados
Local aVZ1RecAlt := {}  // Contem os Recno (VZ1) novos/alterados

Local nTotOS  // Total da OS
Local nPerOS  // Percentual da OS em Relacao ao Total (Fechamento Agrupado)
Local nPerPec // Percentual da OS em pe็as com Relacao ao Total (Fechamento Agrupado)

Local aAuxParcel := {} // Matriz auxiliar para gerar VS9 e VOO

Local lOX100VOO := ExistBlock("OX100VOO")
Local lOX100DGN := ExistBlock("OX100DGN")

Local DVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Det")
Local DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")
Local DVO3PERDES := FG_POSVAR("VO3_PERDES","aHVO3Det")
Local DVO3QTDREQ := FG_POSVAR("VO3_QTDREQ","aHVO3Det")
Local DVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Det")
Local DVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Det")
Local DVO3CODTES := FG_POSVAR("VO3_CODTES","aHVO3Det")
Local DVO3VALPEC := FG_POSVAR("VO3_VALPEC","aHVO3Det")
Local DVO3PEDXML := FG_POSVAR("VO3_PEDXML","aHVO3Det")
Local DVO3ITEXML := FG_POSVAR("VO3_ITEXML","aHVO3Det")
Local DVO3MARLUC := FG_POSVAR("VO3_MARLUC","aHVO3Det")
Local DVO3ACRESC := FG_POSVAR("VO3_ACRESC","aHVO3Det")
Local DVO3CENCUS := FG_POSVAR("VO3_CENCUS","aHVO3Det")
Local DVO3CONTA  := FG_POSVAR("VO3_CONTA","aHVO3Det")
Local DVO3ITEMCT := FG_POSVAR("VO3_ITEMCT","aHVO3Det")
Local DVO3CLVL   := FG_POSVAR("VO3_CLVL","aHVO3Det")
Local DVO3LOTECT := FG_POSVAR("VO3_LOTECT","aHVO3Det")
Local DVO3NUMLOT := FG_POSVAR("VO3_NUMLOT","aHVO3Det")
Local DSEQFEC    := FG_POSVAR("SEQFEC","aHVO3Det")

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")
Local RVO4PEDXML := FG_POSVAR("VO4_PEDXML","aHVO4Res")
Local RVO4ITEXML := FG_POSVAR("VO4_ITEXML","aHVO4Res")
Local RVO4CODTES := FG_POSVAR("VO4_CODTES","aHVO4Res")
Local RVO4CENCUS := FG_POSVAR("VO4_CENCUS","aHVO4Res")
Local RVO4CONTA  := FG_POSVAR("VO4_CONTA","aHVO4Res")
Local RVO4ITEMCT := FG_POSVAR("VO4_ITEMCT","aHVO4Res")
Local RVO4CLVL   := FG_POSVAR("VO4_CLVL","aHVO4Res")
Local lVZ1Contab := VZ1->(FieldPos("VZ1_CENCUS")) > 0 .and. VZ1->(FieldPos("VZ1_CONTA")) > 0 .and. VZ1->(FieldPos("VZ1_ITEMCT")) > 0 .and. VZ1->(FieldPos("VZ1_CLVL")) > 0


Local PVS9TIPPAG := FG_POSVAR("VS9_TIPPAG","aHVS9")
Local PVS9VALPAG := FG_POSVAR("VS9_VALPAG","aHVS9")

Local cAliasVO3 := "TVO3"
Local cAliasVO4 := "TVO4"
Local cAliasVS9 := "TVS9"

Default lPergunta := .t.

SetKey(VK_F4,{|| Nil })

If aScan( aVetTTP , { |x| x[ATT_VETSEL] == .t. } ) == 0 .or. lCanSel
	MsgAlert(STR0053,STR0004) // "Selecionar um registro para faturamento"
	SetKey(VK_F4,{|| OX100SNEG(.t.) })
	Return .f.
EndIf

If !OX100TUDOK()
	SetKey(VK_F4,{|| OX100SNEG(.t.) })
	Return .f.
EndIf

// Verifica se o usuario tem permissao a salvar a negociacao
VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI")+__cUserID))
If lFECOFI .and. !(VAI->VAI_FECOFI $ "13")
	Help(" ",1,"OX100NAONEG")
	SetKey(VK_F4,{|| OX100SNEG(.t.) })
	Return .f.
EndIf

If nCRSaldo <> 0
	MsgAlert(STR0055,STR0004) // O saldo das parcelas nใo confere com o total da Nota Fiscal!
	SetKey(VK_F4,{|| OX100SNEG(.t.) })
	Return .f.
EndIf

If lPergunta .and. !MsgYesNo(STR0017 , STR0004) // Confirma grava็ใo dos Descontos ?
	SetKey(VK_F4,{|| OX100SNEG(.t.) })
	Return .f.
EndIf

// Acerta coluna de Percentual de Rateio das Matrizes Auxiliares (VO3 e VO4)
OX100PAVO3()
OX100PAVO4()
//

// Atualiza Resumo
OX100ATRES(.f.)
//

// Conta quantas OS's Foram Selecionadas para Fechamento
nCntOS := 0
aEval( aVetTTP , {|x| nCntOS += IIF( x[1] , 1 , 0 ) } )
//

// Grava o valor informado nas despesas para ratear, entre os TT selecionados para faturamento
nVOODESACE := M->VOO_DESACE

If VOO->(FieldPos("VOO_FRETE")) > 0
	//Grava o valor informado no frete para ratear, entre os TT selecionados para faturamento
	nVOOFRETE := M->VOO_FRETE
	//Grava o valor informado no seguro para ratear, entre os TT selecionados para faturamento
	nVOOSEGURO := M->VOO_SEGURO
EndIf
//
Begin Transaction

// Rateia valores de Despesa acessoria e parcelas ...
For nCntFor := 1 to Len(aVetTTP)
	
	// Procura o TTP Marcado para Fechamento
	If !aVetTTP[nCntFor,ATT_VETSEL]
		Loop
	EndIf
	//
	
	// Verifica se o TT utiliza o valor de peca atual e o valor da peca sofreu altera็ใo
	VOI->(dbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + aVetTTP[nCntFor,ATT_TIPTEM] ) )
	If VOI->VOI_VLPCAC == "2" // Considera valor de peca atual
		VOO->(dbSetOrder(1))
		If VOO->(dbSeek(xFilial("VOO") + aVetTTP[nCntFor, ATT_NUMOSV] + aVetTTP[nCntFor, ATT_TIPTEM] + aVetTTP[nCntFor, ATT_LIBVOO] ))
			
			If aVetTTP[ nCntFor , ATT_TOTPEC ] <> VOO->VOO_TOTPEC
				dbSelectArea("VOO")
				Reclock("VOO",.f.)
				VOO->VOO_TOTPEC := aVetTTP[ nCntFor , ATT_TOTPEC ]
				VOO->(MSUnlock())
			EndIf
		EndIf
	EndIf
	//
	
	// Calcula o Total da OS e o Percentual dessa OS em relacao
	// a todas as OS's selecionadas para fechamento
	If nCntOS == 1
		nPerPec := nPerOS := 1
	Else
		nPerPec := nTotVO3 := nTotVO4 := 0
		aEval(aAuxVO3 , {|x| nTotVO3 += IIF( x[AP_NUMOSV] == aVetTTP[nCntFor,ATT_NUMOSV] .and. x[AP_TIPTEM] == aVetTTP[nCntFor,ATT_TIPTEM] .and. x[AP_LIBVOO] == aVetTTP[nCntFor,ATT_LIBVOO] , x[AP_ITTOTFISC] , 0 ) } )
		aEval(aAuxVO4 , {|x| nTotVO4 += IIF( x[AS_NUMOSV] == aVetTTP[nCntFor,ATT_NUMOSV] .and. x[AS_TIPTEM] == aVetTTP[nCntFor,ATT_TIPTEM] .and. x[AS_LIBVOO] == aVetTTP[nCntFor,ATT_LIBVOO] , x[AS_ITTOTFISC] , 0 ) } )
		nPerOS := (nTotVO3 + nTotVO4) / nTotnFiscal
		nPerPec:= nTotVO3 / nTotnFiscal
	EndIf
	//
	
	AADD( aAuxParcel , { aVetTTP[nCntFor,ATT_NUMOSV] ,; // 01 - Num. OS
	aVetTTP[nCntFor,ATT_TIPTEM] ,; // 02 - Tipo de Tempo
	0 ,;             // 03 - Valor de Despesa Acessoria
	{} ,;              // 04 - Matriz com valores de VS9 (Nao executar ASORT nessa matriz )
	aVetTTP[nCntFor,ATT_LIBVOO],; // 05 - Num. Liberacao VOO
	0,; // 06 - Frete
	0 }) // 07 - Seguro
	
	aAuxParcel[ nCntFor , 03 ] := Round(nVOODESACE * nPerPec,2)
	
	If VOO->(FieldPos("VOO_FRETE")) > 0
		aAuxParcel[ nCntFor , 06 ] := Round(nVOOFRETE  * nPerPec,2)
		aAuxParcel[ nCntFor , 07 ] := Round(nVOOSEGURO * nPerPec,2)
	EndIf
	
	// Gera matriz de forma de pagamento (VS9)
	For nForVS9 := 1 to Len(oGetVS9:aCols)
		if !oGetVS9:aCols[nForVS9,len(oGetVS9:aCols[nForVS9])] .and. !Empty(oGetVS9:aCols[nForVS9, PVS9TIPPAG ])
			AADD( aAuxParcel[ nCntFor , 04 ] , { nForVS9 , Round( oGetVS9:aCols[nForVS9,PVS9VALPAG] * nPerOS , 2 ) } )
		endif
	Next
	//
Next nCntFor

// Recalcula totais para verificar se teve problema com casas decimais ...
nValTot := 0
aEval( aAuxParcel , {|x| nValTot += x[3] } )
If nValTot <> nVOODESACE
	aSort(aAuxParcel,,,{|x,y| x[3] > y[3] })
	aAuxParcel[1,3] += nVOODESACE - nValTot
EndIf

If VOO->(FieldPos("VOO_FRETE")) > 0
	// Recalcula totais para verificar se teve problema com casas decimais ...
	nValTot := 0
	aEval( aAuxParcel , {|x| nValTot += x[6] } )
	If nValTot <> nVOOFRETE
		aSort(aAuxParcel,,,{|x,y| x[6] > y[6] })
		aAuxParcel[1,6] += nVOOFRETE - nValTot
	EndIf
	// Recalcula totais para verificar se teve problema com casas decimais ...
	nValTot := 0
	aEval( aAuxParcel , {|x| nValTot += x[7] } )
	If nValTot <> nVOOSEGURO
		aSort(aAuxParcel,,,{|x,y| x[7] > y[7] })
		aAuxParcel[1,7] += nVOOSEGURO - nValTot
	EndIf
EndIf

SE4->(dbSetOrder(1))
SE4->(dbSeek( xFilial("SE4") + M->VOO_CONDPG ))

For nCntFor := 1 to Len(aAuxParcel)
	// Valor total das parcelas da OS
	nValTot := 0
	aEval( aAuxParcel[nCntFor,4] , {|x| nValTot += x[2] } )
	//
	
	// Valor total das parcelas da OS, calculado pelo fiscal ...
	nTotOS := 0
	aEval(aAuxVO3 , {|x| nTotOS += IIF( x[AP_NUMOSV] == aAuxParcel[nCntFor,1] .and. x[AP_TIPTEM] == aAuxParcel[nCntFor,2] .and. x[AP_LIBVOO] == aAuxParcel[nCntFor,5] , x[AP_ITBASEDUP] , 0 ) } )
	aEval(aAuxVO4 , {|x| nTotOS += IIF( x[AS_NUMOSV] == aAuxParcel[nCntFor,1] .and. x[AS_TIPTEM] == aAuxParcel[nCntFor,2] .and. x[AS_LIBVOO] == aAuxParcel[nCntFor,5] , x[AS_ITBASEDUP] , 0 ) } )
	//
	If nValTot <> nTotOS .and. !OX1000061_Condicao_Negociada()
		aAuxParcel[nCntFor,4,Len(aAuxParcel[nCntFor,4]),2] += nTotOS - nValTot
	EndIf
Next nCntFor
//

VOO->(dbSetOrder(1))

For nCntFor := 1 to Len(aAuxParcel)
	
	// Atualiza Arquivo de Numero de Notas Fiscais - VOO
	dbSelectArea("VOO")
	VOO->(dbSeek( xFilial("VOO") + aAuxParcel[nCntFor,1] + aAuxParcel[nCntFor,2] + aAuxParcel[nCntFor,5] ))
	If !VOO->(Found())
		DisarmTransaction()
		SetKey(VK_F4,{|| OX100SNEG(.t.) })
		Return .f.
	EndIf
	RecLock("VOO",.f.)
	For nXi:=1 to FCount()
		cAuxCpo := AllTrim(FieldName(nXi))
		If !(cAuxCpo $ cVOOnAltera) .and. Type("M->"+(cAuxCpo)) != "U"
			&(cAuxCpo) := M->&(cAuxCpo)
		EndIf
	Next
	VOO->VOO_DESACE := aAuxParcel[nCntFor,3]
	
	If VOO->(FieldPos("VOO_FRETE")) > 0
		VOO->VOO_FRETE  := aAuxParcel[nCntFor,6]
		VOO->VOO_SEGURO := aAuxParcel[nCntFor,7]
	EndIf
	
	If lVOOOBSMNF .and. (VOO->VOO_TOTPEC <> 0 .or. Len(aAuxParcel) == 1)
		MSMM(VOO->VOO_OBSMNF,TamSx3("VOO_OBSENF")[1],,M->VOO_OBSENF,1,,,"VOO","VOO_OBSMNF")
	EndIf
	If lVOOOBSMNS .and. (VOO->VOO_TOTSRV <> 0 .or. Len(aAuxParcel) == 1)
		MSMM(VOO->VOO_OBSMNS,TamSx3("VOO_OBSENS")[1],,M->VOO_OBSENS,1,,,"VOO","VOO_OBSMNS")
	EndIf
	// PE para que o usuario altere algum campo especifico da VOO
	If lOX100VOO
		ExecBlock("OX100VOO",.F.,.F.,)
	EndIf
	//
	VOO->(MsUnLock())
	//

	If Select(cAliasVS9) > 0
		(cAliasVS9)->(dbCloseArea())
	EndIf	

	// Parcelas - VS9
	cSQL := "SELECT R_E_C_N_O_ NRECNO"
	cSQL += " FROM " + RetSQLName("VS9") + " VS9"
	cSQL += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
	cSQL +=   " AND VS9.VS9_NUMIDE = '" + aAuxParcel[nCntFor,1] + "'"
	cSQL +=   " AND VS9.VS9_TIPOPE = 'O'"
	cSQL +=   " AND VS9.VS9_TIPTEM = '" + aAuxParcel[nCntFor,2] + "'"
	cSQL += " AND VS9.VS9_LIBVOO = '" + aAuxParcel[nCntFor,5] + "'"
	cSQL +=   " AND VS9.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS9 , .F., .T. )
	While !(cAliasVS9)->(Eof())
		VS9->(dbGoTo( (cAliasVS9)->NRECNO ))
		RecLock("VS9",.F.,.T.)
		VS9->(dbDelete())
		VS9->(MsUnlock())
		(cAliasVS9)->(dbSkip())
	End
	(cAliasVS9)->(dbCloseArea())
	DBSelectArea("VS9")
	nVS9Seq := 0
	For nForVS9 := 1 to Len(aAuxParcel[nCntFor,4])
		nVS9Seq++
		Reclock("VS9",.t.)
		VS9->VS9_FILIAL := xFilial("VS9")
		VS9->VS9_NUMIDE := aAuxParcel[nCntFor,1]
		VS9->VS9_TIPOPE := "O"
		VS9->VS9_TIPTEM := aAuxParcel[nCntFor,2]
		VS9->VS9_LIBVOO := aAuxParcel[nCntFor,5]
		VS9->VS9_SEQUEN := STRZERO(nVS9Seq,TamSX3("VS9_SEQUEN")[1])
		For nForHVS9 := 1 to Len(aHVS9)
			if aHVS9[nForHVS9,10] <> "V"
				&("VS9->"+aHVS9[nForHVS9,2]) := oGetVS9:aCols[aAuxParcel[nCntFor,4,nForVS9,1] ,nForHVS9]
			endif
		Next
		VS9->VS9_VALPAG := aAuxParcel[nCntFor,4,nForVS9,2]
		VS9->(MSUnlock())
	Next nForVS9
	//
	
	If Select(cAliasVZ1) > 0
		(cAliasVZ1)->(dbCloseArea())
	EndIf			

	// Gera uma matriz com os Recnos atuais utilizada no final para verifica
	// quais registros da VZ1 devem ser excluidos ...
	cSQL := "SELECT R_E_C_N_O_ NRECNO"
	cSQL +=  " FROM " + RetSQLName("VZ1") + " VZ1"
	cSQL += " WHERE VZ1.VZ1_FILIAL = '" + xFilial("VZ1") + "'"
	cSQL +=   " AND VZ1.VZ1_NUMOSV = '" + aAuxParcel[nCntFor,1] + "'"
	cSQL +=   " AND VZ1.VZ1_TIPTEM = '" + aAuxParcel[nCntFor,2] + "'"
	cSQL += " AND VZ1.VZ1_LIBVOO = '" + aAuxParcel[nCntFor,5] + "'"
	cSQL +=   " AND VZ1.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVZ1 , .F., .T. )
	While !(cAliasVZ1)->(Eof())
		AADD( aVZ1RecAtu , (cAliasVZ1)->NRECNO )
		(cAliasVZ1)->(dbSkip())
	End
	(cAliasVZ1)->(dbCloseArea())
	//
	
Next nCntFor

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava Negociacao com base na Matriz que foi salva no momento que o GetDados foi Carregado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// P E C A S
dbSelectArea("VZ1")
dbSetOrder(3)
For nCntFor := 1 to Len(aAuxVO3)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Procura a Posicao da GetDados que contem os dados do Fechamento ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPosGet := aScan( oGetDetVO3:aCols, { |x| x[DSEQFEC] == aAuxVO3[nCntFor,AP_SEQFEC] } )
	If nPosGet == 0
		Help(" ",1,"OX100GDMA",,STR0046+CHR(13)+CHR(10)+"OX100SNEG",4,1)
		Loop
	EndIf
	//
	
	VOI->(dbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + oGetDetVO3:aCols[nPosGet,DVO3TIPTEM] ) )
	
	// Posiciona VZ1
	nRecVZ1 := OX100VZ1( aAuxVO3[nCntFor,AP_NUMOSV], ;
	aAuxVO3[nCntFor,AP_TIPTEM], ;
	aAuxVO3[nCntFor,AP_GRUITE], ;
	aAuxVO3[nCntFor,AP_CODITE], ;
	aAuxVO3[nCntFor,AP_LIBVOO], ;
	aAuxVO3[nCntFor,AP_FORMUL], ;
	oGetDetVO3:aCols[nPosGet, DVO3VALPEC ] ,;
	.F.)
	
	If nRecVZ1 > 0
		//
		VZ1->(DbGoTo(nRecVZ1))
		//
		lSeekVZ1 := .t.
		AADD( aVZ1RecAlt , VZ1->(Recno()) )
		//
	Else
		lSeekVZ1 := .f.
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Recalcula o percentual e valor de desconto para a Peca, pois se for ณ
	//ณ fechamento agrupado mesma peca poderia estar em mais de uma OS.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nValTot := 0
	nPerdes := 0
	// Descobre o valor do desconto unitario
	nValDesUni := A410Arred( oGetDetVO3:aCols[nPosGet, DVO3VALDES ] / oGetDetVO3:aCols[nPosGet, DVO3QTDREQ ] , "C6_PRCVEN" )
	// Descobre o valor do desconto total para a peca nesta OS
	nValDesTot := A410Arred( aAuxVO3[nCntFor,AP_QTDREQ] * nValDesUni , "C6_VALOR" )
	
	If oGetDetVO3:aCols[nPosGet, DVO3PERDES ] <> nPerdes .and. oGetDetVO3:aCols[nPosGet, DVO3VALDES ] == nValDesTot //Diverg๊ncia de resultados entre o retorno da fun็ใo OX100DESC() e a fun็ใo de rateio OX100PAVO3().
		aAuxVO3[nCntFor, AP_PERDES] := oGetDetVO3:aCols[nPosGet, DVO3PERDES ]
		nPerdes := oGetDetVO3:aCols[nPosGet, DVO3PERDES ]
	Else
		aAuxVO3[nCntFor, AP_PERDES] := nPerdes
	EndIf
	
	aAuxVO3[nCntFor, AP_VALDES] := nValDesTot
	
	//
	RecLock("VZ1",!lSeekVZ1)
	VZ1->VZ1_FILIAL := xFilial("VZ1")
	VZ1->VZ1_NUMOSV := aAuxVO3[nCntFor,AP_NUMOSV]
	VZ1->VZ1_LIBVOO := aAuxVO3[nCntFor,AP_LIBVOO]
	VZ1->VZ1_TIPTEM := aAuxVO3[nCntFor,AP_TIPTEM]
	VZ1->VZ1_PECSER := "P"  // Pecas
	VZ1->VZ1_TIPFEC := IIF(nCntOS == 1 , "1" , "2" )
	VZ1->VZ1_GRUITE := oGetDetVO3:aCols[nPosGet, DVO3GRUITE ]
	VZ1->VZ1_CODITE := oGetDetVO3:aCols[nPosGet, DVO3CODITE ]
	VZ1->VZ1_PERDES := nPerDes
	VZ1->VZ1_VALDES := nValDesTot
	VZ1->VZ1_VALBRU := A410Arred( aAuxVO3[nCntFor,AP_QTDREQ] * oGetDetVO3:aCols[nPosGet, DVO3VALPEC ] , "C6_VALOR" )
	VZ1->VZ1_CODTES := oGetDetVO3:aCols[nPosGet, DVO3CODTES ]
	VZ1->VZ1_VALUNI := oGetDetVO3:aCols[nPosGet, DVO3VALPEC ]
	
	If cUsaAcres == 'S'
		VZ1->VZ1_ACRESC := Round(oGetDetVO3:aCols[nPosGet, DVO3ACRESC ] * aAuxVO3[nCntFor,AP_PERCENT],2) //'VO3_ACRESC'
	EndIf
	VZ1->VZ1_MARLUC := oGetDetVO3:aCols[nPosGet, DVO3MARLUC ] //'VO3_MARLUC'
	
	If lFORMUL
		VZ1->VZ1_FORMUL := aAuxVO3[nCntFor,AP_FORMUL]
	EndIf
	if DVO3CENCUS <> 0 .and. DVO3CONTA <> 0 .and. DVO3ITEMCT <> 0 .and. DVO3CLVL <> 0 .and. lVZ1Contab
		VZ1->VZ1_CENCUS := oGetDetVO3:aCols[nPosGet, DVO3CENCUS ]
		VZ1->VZ1_CONTA  := oGetDetVO3:aCols[nPosGet, DVO3CONTA  ]
		VZ1->VZ1_ITEMCT := oGetDetVO3:aCols[nPosGet, DVO3ITEMCT ]
		VZ1->VZ1_CLVL   := oGetDetVO3:aCols[nPosGet, DVO3CLVL   ]
	Endif
	VZ1->(MsUnlock())
	
	//
	
	If DVO3PEDXML > 0
		
		If Select(cAliasVO3) > 0
			(cAliasVO3)->(dbCloseArea())
		EndIf			

		cSQL := "SELECT R_E_C_N_O_ NRECNO"
		cSQL += " FROM " + RetSQLName("VO3") + " VO3"
		cSQL += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
		cSQL +=   " AND VO3.VO3_NUMOSV = '" + aAuxVO3[nCntFor,AP_NUMOSV] + "'"
		cSQL +=   " AND VO3.VO3_GRUITE = '" + aAuxVO3[nCntFor,AP_GRUITE] + "'"
		cSQL +=   " AND VO3.VO3_CODITE = '" + aAuxVO3[nCntFor,AP_CODITE] + "'"
		cSQL +=   " AND VO3.VO3_VALPEC = " + Alltrim(str(aAuxVO3[nCntFor,AP_VALPECREQ]))
		cSQL +=   " AND VO3.VO3_LIBVOO = '" + aAuxVO3[nCntFor,AP_LIBVOO] + "'"
		cSQL +=   " AND VO3.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVO3 , .F., .T. )
		While !(cAliasVO3)->(Eof())
			VO3->(dbGoTo( (cAliasVO3)->NRECNO ))
			RecLock("VO3",.f.)
			VO3->VO3_PEDXML := oGetDetVO3:aCols[nPosGet, DVO3PEDXML ]
			VO3->VO3_ITEXML := oGetDetVO3:aCols[nPosGet, DVO3ITEXML ]
			VO3->(MsUnLock())
			(cAliasVO3)->(dbSkip())
		End
		(cAliasVO3)->(dbCloseArea())
		
	EndIf
	
	//
	
Next nCntFor

// S E R V I C O S
dbSelectArea("VZ1")
dbSetOrder(4)

For nCntFor := 1 to Len(aAuxVO4)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Procura a Posicao da GetDados que contem os dados do Fechamento ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPosGet := aScan( oGetResVO4:aCols, { |x| x[RVO4TIPTEM] == aAuxVO4[nCntFor,AS_TIPTEM] .and. x[RVO4TIPSER] == aAuxVO4[nCntFor,AS_TIPSER] } )
	If nPosGet == 0
		Help(" ",1,"OX100GDMA",,STR0047+CHR(13)+CHR(10)+"OX100SNEG",4,1)
		Loop
	EndIf
	//
	lSeekVZ1 := VZ1->(dbSeek( xFilial("VZ1") + aAuxVO4[nCntFor,AS_NUMOSV] + aAuxVO4[nCntFor,AS_TIPTEM] + 'S' + aAuxVO4[nCntFor,AS_GRUSER] + aAuxVO4[nCntFor,AS_CODSER] + aAuxVO4[nCntFor,AS_TIPSER] + aAuxVO4[nCntFor,AS_LIBVOO] ) )
	
	If lSeekVZ1
		AADD( aVZ1RecAlt , VZ1->(Recno()) )
	EndIf
	
	RecLock("VZ1",!lSeekVZ1)
	VZ1->VZ1_FILIAL := xFilial("VZ1")
	VZ1->VZ1_NUMOSV := aAuxVO4[nCntFor,AS_NUMOSV]
	VZ1->VZ1_LIBVOO := aAuxVO4[nCntFor,AS_LIBVOO]
	VZ1->VZ1_TIPTEM := aAuxVO4[nCntFor,AS_TIPTEM]
	VZ1->VZ1_PECSER := "S"  // Servicos
	VZ1->VZ1_TIPFEC := IIF(nCntOS == 1 , "1" , "2" )
	VZ1->VZ1_TIPSER := aAuxVO4[nCntFor,AS_TIPSER]
	VZ1->VZ1_GRUSER := aAuxVO4[nCntFor,AS_GRUSER]
	VZ1->VZ1_CODSER := aAuxVO4[nCntFor,AS_CODSER]
	VZ1->VZ1_PERDES := aAuxVO4[nCntFor,AS_PERDES]
	VZ1->VZ1_VALDES := aAuxVO4[nCntFor,AS_VALDES]
	VZ1->VZ1_VALBRU := aAuxVO4[nCntFor,AS_VALBRU]
	VZ1->VZ1_CODTES := oGetResVO4:aCols[nPosGet, RVO4CODTES ]
	VZ1->VZ1_VALUNI := aAuxVO4[nCntFor,AS_VALBRU]
	if RVO4CENCUS <> 0 .and. RVO4CONTA <> 0 .and. RVO4ITEMCT <> 0 .and. RVO4CLVL <> 0 .and. lVZ1Contab
		VZ1->VZ1_CENCUS := oGetResVO4:aCols[nPosGet, RVO4CENCUS ]
		VZ1->VZ1_CONTA  := oGetResVO4:aCols[nPosGet, RVO4CONTA ]
		VZ1->VZ1_ITEMCT := oGetResVO4:aCols[nPosGet, RVO4ITEMCT ]
		VZ1->VZ1_CLVL   := oGetResVO4:aCols[nPosGet, RVO4CLVL ]
	Endif
	VZ1->(MsUnlock())
	
	If RVO4PEDXML > 0

		If Select(cAliasVO4) > 0
			(cAliasVO4)->(dbCloseArea())
		EndIf	

		cSQL := "SELECT R_E_C_N_O_ NRECNO"
		cSQL += " FROM " + RetSQLName("VO4") + " VO4"
		cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
		cSQL +=   " AND VO4.VO4_NUMOSV = '" + aAuxVO4[nCntFor,AS_NUMOSV] + "'"
		cSQL +=   " AND VO4.VO4_TIPSER = '" + aAuxVO4[nCntFor,AS_TIPSER] + "'"
		cSQL +=   " AND VO4.VO4_TIPTEM = '" + aAuxVO4[nCntFor,AS_TIPTEM] + "'"
		cSQL +=   " AND VO4.VO4_LIBVOO = '" + aAuxVO4[nCntFor,AS_LIBVOO] + "'"
		cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVO4 , .F., .T. )

		While !(cAliasVO4)->(Eof())
			VO4->(dbGoTo( (cAliasVO4)->NRECNO ))
			RecLock("VO4",.f.)
			VO4->VO4_PEDXML := oGetResVO4:aCols[nPosGet, RVO4PEDXML ]
			VO4->VO4_ITEXML := oGetResVO4:aCols[nPosGet, RVO4ITEXML ]
			VO4->(MsUnLock())
			(cAliasVO4)->(dbSkip())
		End

		(cAliasVO4)->(dbCloseArea())
	EndIf
Next nCntFor
//

// Exclui registros nao alterados da VZ1
For nCntFor := 1 to Len(aVZ1RecAtu)
	If (nPos := aScan( aVZ1RecAlt , aVZ1RecAtu[nCntFor]) ) == 0
		dbSelectArea("VZ1")
		VZ1->(dbGoTo(aVZ1RecAtu[nCntFor]))
		RecLock("VZ1",.F.,.T.)
		VZ1->(dbDelete())
		VZ1->(MsUnlock())
	EndIf
Next nCntFor
//

If lOX100DGN
	ExecBlock("OX100DGN",.F.,.F.)
Endif

End Transaction

// Bloqueia registros da VOO novamente...
// Bloqueio ้ necessแrio, pois os registros foram alterados e no final da transacao os registros eram desbloqueados automaticamente
OX100VOOBLQ()

If lPergunta
	MsgAlert(STR0075,STR0004) // "Negociacao Salva"
EndIf

SetKey(VK_F4,{|| OX100SNEG(.t.) })

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100LNEG  บAutor  ณ Takahashi          บ Data ณ  11/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega Negociacao Salva                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da Ordem de Servico                       บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100LNEG(cNumOsv, cTiptem, cLibVOO)

Local nCntFor, cAuxCpo
Local cSQL
Local cAliasVS9 := "TVS9"
Local nPosVS9

Local PVS9TIPPAG := FG_POSVAR("VS9_TIPPAG","aHVS9")
Local PVS9DATPAG := FG_POSVAR("VS9_DATPAG","aHVS9")
Local PVS9VALPAG := FG_POSVAR("VS9_VALPAG","aHVS9")

dbSelectArea("VOO")
VOO->(dbSetOrder(1))
VOO->(dbSeek(xFilial("VOO") + cNumOsv + cTiptem + cLibVOO))
If VOO->(Found())
	For nCntFor := 1 to VOO->(FCount())
		cAuxCpo := AllTrim(VOO->(FieldName(nCntFor)))
		If cAuxCpo == "VOO_CONDPG"
			If Empty(M->VOO_CONDPG)
				&("M->" + cAuxCpo) := &("VOO->" + cAuxCpo)
			EndIf
		ElseIf cAuxCpo == "VOO_DESACE"
			M->VOO_DESACE += VOO->VOO_DESACE
		ElseIf cAuxCpo == "VOO_FRETE"
			M->VOO_FRETE += VOO->VOO_FRETE
		ElseIf cAuxCpo == "VOO_SEGURO"
			M->VOO_SEGURO += VOO->VOO_SEGURO
		ElseIf (aScan( aCpoVOO , cAuxCpo ) ) <> 0 .OR. cAuxCPO $ "VOO_OBSMNF/VOO_OBSMNS"
			&("M->" + cAuxCpo) := &("VOO->" + cAuxCpo)
		EndIf
	Next nCntFor
	
	If lVOOOBSMNF .AND. VOO->VOO_TOTPEC <> 0
		M->VOO_OBSENF := MSMM(M->VOO_OBSMNF,TamSx3("VOO_OBSENF")[1])
	EndIf
	
	If lVOOOBSMNS .AND. VOO->VOO_TOTSRV <> 0
		M->VOO_OBSENS := MSMM(M->VOO_OBSMNS,TamSx3("VOO_OBSENS")[1])
	EndIf
	
	If !Empty(M->VOO_CONDPG)
		SE4->(dbSetOrder(1))
		If SE4->(dbSeek( xFilial("SE4") + M->VOO_CONDPG ))
			lSE4TipoA := OX1000061_Condicao_Negociada()
		EndIf
	EndIf
	
EndIf

If !Empty(M->VOO_CONDPG)
	
	SE4->(dbSetOrder(1))
	If !SE4->(dbSeek( xFilial("SE4") + M->VOO_CONDPG ))
		MsgAlert(STR0054,STR0004) // "Condicao de pagamento nใo encontrada"
		Return .f.
	EndIf
	
	If SE4->E4_TIPO $ "9/A"
		
		Inclui := .f. // Utilizado na Relacao de alguns campos ...
		
		cSQL := "SELECT R_E_C_N_O_ NRECNO"
		cSQL += " FROM " + RetSQLName("VS9") + " VS9"
		cSQL += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
		cSQL +=   " AND VS9.VS9_NUMIDE = '" + cNumOsv + "'"
		cSQL +=   " AND VS9.VS9_TIPOPE = 'O'"
		cSQL +=   " AND VS9.VS9_TIPTEM = '" + cTiptem + "'"
		cSQL +=   " AND VS9.VS9_LIBVOO = '" + cLibVOO + "'"
		cSQL +=   " AND VS9.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS9 , .F., .T. )
		While !(cAliasVS9)->(Eof())
			VS9->(dbGoTo( (cAliasVS9)->NRECNO ))
			//      RegToMemory("VS9" , .f. , .t. , .t. ) // lInc , lDic , lInitPad
			
			nPosVS9 := aScan( oGetVS9:aCols , { |x| x[PVS9TIPPAG] == VS9->VS9_TIPPAG .and. x[PVS9DATPAG] == VS9->VS9_DATPAG } )
			If nPosVS9 == 0
				AADD(oGetVS9:aCols, Array(Len(aCVS9[1])) )
				oGetVS9:aCols[Len(oGetVS9:aCols)] := aClone(aCVS9[1])
				nPosVS9 := Len(oGetVS9:aCols)
				
				For nCntFor := 1 to Len(aHVS9)
					If aHVS9[nCntFor,10] == "V"
						oGetVS9:aCols[nPosVS9,nCntFor] := &(aHVS9[nCntFor,12])  // Executa o X3_RELACAO
					Else
						oGetVS9:aCols[nPosVS9,nCntFor] := VS9->(FieldGet(FieldPos(aHVS9[nCntFor,2])))
					EndIf
					&("M->" + AllTrim(aHVS9[nCntFor,2])) := oGetVS9:aCols[nPosVS9,nCntFor]
				Next nCntFor
			Else
				oGetVS9:aCols[nPosVS9,PVS9VALPAG] += VS9->VS9_VALPAG
			EndIf
			
			(cAliasVS9)->(dbSkip())
			
		End
		(cAliasVS9)->(dbCloseArea())
		DbSelectArea("VS9")
		
	EndIf
	
EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VOO   บAutor  ณ Takahashi          บ Data ณ  07/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da Digitacao da Enchoice do VOO                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cReadVar = ReadVar()                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100VOO(cReadVar, lValPer)

Local lRetorno := .t.
Local nUsadoVOO
Local cSQL

Default cReadVar := ReadVar()
Default lValPer := .t.

If cReadVar == "M->VOO_CONDPG"
	
	If Empty(M->VOO_CONDPG)
		Return .t.
	EndIf
	
	if lCliPeriod .and. lValPer
		SA1->(dbSetOrder(1))
		SA1->(MsSeek( xFilial("SA1") + cFechCli + cFechLoj))
		If !Empty(SA1->A1_COND) .and. SA1->A1_COND <> M->VOO_CONDPG
			If Aviso( STR0028 , STR0029  , { STR0030 , STR0031 } ) <> 1 //Cliente Periodico # Este e um cliente periodico, mudando a condicao de pagamento o sistema nao gerara titulos provisorios...! # OK # Cancela
				Return .f.
			Endif
		Endif
	Endif
	
	SE4->(dbSetOrder(1))
	If !SE4->(dbSeek( xFilial("SE4") + M->VOO_CONDPG ))
		MsgAlert(STR0054,STR0004) // "Condicao de pagamento nใo encontrada"
		Return .f.
	EndIf
	
	If SE4->E4_TIPO == "9" .or. SE4->E4_TIPO == "A"
		
		// Valida se ้ possํvel utilizar condicao tipo 9 ou A
		lCupom := OX100LOJA()
		If !OX100CONDNEG( aAuxTipTem , lCupom , !lCupom )
			Return .f.
		EndIf
		
		lSE4TipoA := .t.
		
		nCRTotal   := OX100TFIN()
		nCRSaldo   := nCRTotal
		nTotFinanc := nCRTotal
		
		If SE4->E4_TIPO == "A" .and. !Empty(cCondGar)
			// Atualiza GetDados de Pagamentos ...
			OX100GDVS9( nCRTotal, cCondGar )
		Else
			aEval(oGetVS9:aCols , {|x| nCRSaldo -= IIF( !x[Len(x)] , x[FG_POSVAR("VS9_VALPAG","aHVS9")] , 0 ) } )
		EndIf
		
	Else
		
		// Limpar variaveis utilizadas no calculo das parcelas, quando SE4->E4_TIPO <> '9'
		dCRDataIni := CtoD("00/00/00")  // Data inicial para Financiamento
		nCRDias    := 0         // Dias para Financiamento
		nCRParc    := 0         // Parcelas para Financiamento
		nCRInter   := 0         // Intervalo para Financiamento
		
		lSE4TipoA := .f.
		
		nCRTotal   := OX100TFIN(M->VOO_CONDPG)
		nCRSaldo   := nCRTotal
		nTotFinanc := nCRTotal
		
		
		// Atualiza GetDados de Pagamentos ...
		OX100GDVS9( nCRTotal, M->VOO_CONDPG )
		
	EndIf
	
	M->VOO_DCONPG := SE4->E4_DESCRI
	
	oCRTotal:Refresh()
	oCRSaldo:Refresh()
	oGetVS9:oBrowse:Refresh()
EndIf

If cReadVar == "M->VOO_RECISS"
	MaFisRef("NF_RECISS",,M->VOO_RECISS)
	OX100ATRES()
	OX100VOO("M->VOO_CONDPG", .f.)
EndIf

If cReadVar == "M->VOO_FRETE"
	MaFisRef("NF_FRETE",,M->VOO_FRETE)
	OX100ATRES()
	OX100VOO("M->VOO_CONDPG", .f.)
EndIf

If cReadVar == "M->VOO_SEGURO"
	MaFisRef("NF_SEGURO",,M->VOO_SEGURO)
	OX100ATRES()
	OX100VOO("M->VOO_CONDPG", .f.)
EndIf

If cReadVar == "M->VOO_TPFRET"
	MaFisRef("NF_TPFRETE",,M->VOO_TPFRET)
	OX100ATRES()
EndIf

If cReadVar == "M->VOO_DESACE"
	MaFisRef("NF_DESPESA",,M->VOO_DESACE)
	OX100ATRES()
	// Recalcula as parcelas ...
	OX100VOO("M->VOO_CONDPG", .f.)
	//
EndIf

If cReadVar == "M->VOO_TIPOCL"
	If Empty(M->VOO_TIPOCL)
		SA1->(dbSetOrder(1))
		SA1->(MsSeek( xFilial("SA1") + cFechCli + cFechLoj))
		MaFisRef("NF_TPCLIFOR",,SA1->A1_TIPO)
	Else
		MaFisRef("NF_TPCLIFOR",,M->VOO_TIPOCL)
	EndIf
	OX100ATRES()
EndIf

If cReadVar == "M->VOO_ESTPRE"
	If !Empty(M->VOO_ESTPRE) .and. !ExistCpo("SX5","12"+M->VOO_ESTPRE)
		lRetorno := .f.
	EndIf
	M->C5_ESTPRES := M->VOO_ESTPRE // Utilizado na consulta padrใo
EndIf

If cReadVar == "M->VOO_ALIISS"
	If nTotSrvc <= 0
		lRetorno := .f.
	Else
		If lAliqISS
			OX100ISS(M->VOO_ALIISS)
		Else
			MsgInfo(STR0153,STR0004) // "Nใo ้ possํvel informar valor de alํquota. Para informa uma alํquota de ISS por fechamento, ้ necessแrio que exista o campo C6_ALIQISS na base de dados."
			lRetorno := .f.
		EndIf
	EndIf
EndIf

If cReadVar == "M->VOO_NATPEC" .or. cReadVar == "M->VOO_NATSRV"
	If !Empty(M->VOO_NATPEC) .and. aScan( oGetDetVO3:aCols , { |x| !Empty(x[ FG_POSVAR("VO3_CODITE","aHVO3Det") ]) } ) <> 0 // Setar NATUREZA somente se existir PEวAS
		MaFisRef("NF_NATUREZA",,M->VOO_NATPEC)
	ElseIf !Empty(M->VOO_NATSRV) .and. aScan( oGetDetVO4:aCols , { |x| !Empty(x[ FG_POSVAR("VO4_CODSER","aHVO4Det") ]) } ) <> 0 // Setar NATUREZA somente se existir SERVIวOS
		MaFisRef("NF_NATUREZA",,M->VOO_NATSRV)
	Else // Caso nใo for informada a Natureza de Pe็as e Servi็os, utilizar a Natureza do Cliente SA1
		SA1->(dbSetOrder(1))
		SA1->(MsSeek( xFilial("SA1") + cFechCli + cFechLoj))
		MaFisRef("NF_NATUREZA",,SA1->A1_NATUREZ)
	EndIf
	OX100ATRES()
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100GDVS9 บAutor  ณ Takahashi          บ Data ณ  15/09/14 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Gera parcelas a partir da condicao de pagamento            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro,,,,nAcresFinsณ nAuxTotal = Valor total para geracao das parcelas          บฑฑ
ฑฑบ          ณ cCondPgto = Codigo da Condicao de Pagamento                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100GDVS9( nAuxTotal, cCondPgto , aParIteParc , aTipPag )

Local nUsadoVOO
Local cDescPag := PadR(POSICIONE("VSA",1,xFilial("VSA")+"DP","VSA_DESPAG"),TamSX3("VSA_DESPAG")[1])
Local nCntFor, nCntFor2

Default aParIteParc := {}
Default aTipPag  := {}

If Empty(aParIteParc)
	aIteParc := Condicao( nAuxTotal ,cCondPgto,,dDataBase,,,,nAcresFin)
Else
	aIteParc := aClone(aParIteParc)
Endif
oGetVS9:aCols := {}
nUsadoVOO := Len(aHVS9)

For nCntFor := 1 to Len(aIteParc)
	AADD(oGetVS9:aCols,Array(nUsadoVOO+1))
	oGetVS9:aCols[Len(oGetVS9:aCols),nUsadoVOO+1] := .f.
	If Len(aTipPag) > 0 .and. !Empty(aTipPag[nCntFor])
		cDescPag := PadR(POSICIONE("VSA",1,xFilial("VSA")+aTipPag[nCntFor],"VSA_DESPAG"),TamSX3("VSA_DESPAG")[1])
	Endif
	For nCntFor2:=1 to nUsadoVOO
		If aHVS9[nCntFor2,2]  == "VS9_TIPPAG"
			oGetVS9:aCols[Len(oGetVS9:aCols),nCntFor2] := IIf( Len(aTipPag) > 0 , aTipPag[nCntFor] , "DP" )
		elseif aHVS9[nCntFor2,2]  == "VS9_DATPAG"
			oGetVS9:aCols[Len(oGetVS9:aCols),nCntFor2] := aIteParc[nCntFor,1]
		elseif aHVS9[nCntFor2,2]  == "VS9_VALPAG"
			oGetVS9:aCols[Len(oGetVS9:aCols),nCntFor2] := aIteParc[nCntFor,2]
		elseif aHVS9[nCntFor2,2]  == "VS9_DESPAG"
			oGetVS9:aCols[Len(oGetVS9:aCols),nCntFor2] := cDescPag
		elseif aHVS9[nCntFor2,2]  == "VS9_ENTRAD"
			oGetVS9:aCols[Len(oGetVS9:aCols),nCntFor2] := "N"
		else
			oGetVS9:aCols[Len(oGetVS9:aCols),nCntFor2] := CriaVar(aHVS9[nCntFor2,2])
		endif
	Next
	
	nCRSaldo -= aIteParc[nCntFor,2]
	
Next

If Len(oGetVS9:aCols) == 0
	AADD(oGetVS9:aCols, Array(Len(aCVS9[1])) )
	oGetVS9:aCols[Len(oGetVS9:aCols)] := aClone(aCVS9[1])
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100FOVS9 บAutor  ณ Takahashi          บ Data ณ  07/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ FieldOK da GetDados de Parcelas (VS9)                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100FOVS9(cReadVar)

Default cReadVar := ReadVar()

// se o usuario nao possui permissao de alterar retorna .f.
If !(VAI->VAI_ALTPAR =="1")
	MsgStop(STR0127,STR0004) // "Usuแrio sem permissใo para alterar a data e/ou valor da parcela."
	Return .f.
EndIf
//
If Empty(M->VOO_CONDPG)
	MsgStop(STR0128,STR0004) // "Preencha uma condi็ใo de pagamento antes."
	Return .f.
EndIf
//
DBSelectArea("SE4")
DBSetOrder(1)
If !(MsSeek(xFilial("SE4")+M->VOO_CONDPG))
	Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VOO_CONDPG")) + ": " + M->VOO_CONDPG ,4,1)
	Return .f.
Endif

// Melhoria para condi็ใo de pagamento
If ExistBlock("OX100SE4")
	If !ExecBlock("OX100SE4",.f.,.f.)
		Return(.f.)
	EndIf
EndIf


If cReadVar $ "M->VS9_TIPPAG/M->VS9_VALPAG/M->VS9_DATPAG" .and. !Alltrim(SE4->E4_TIPO) $ "9/A"
	MsgStop(STR0129,STR0004) // "Nใo ้ possํvel alterar campo para condi็ใo de pagamento diferente de Negociada."
	Return .f.
EndIf

//###############################################################################
If cReadVar=="M->VS9_TIPPAG"
	DBSelectArea("VSA")
	DBSetOrder(1)
	If !dbSeek(xFilial("VSA")+M->VS9_TIPPAG)
		return .f.
	endif
	oGetVS9:aCols[oGetVS9:nAt,FG_POSVAR("VS9_DESPAG","aHVS9")] := M->VS9_DESPAG := VSA->VSA_DESPAG
EndIf
//###############################################################################
If cReadVar=="M->VS9_PORTAD"
	//###############################################################################
	DBSelectArea("SA6")
	DBSetOrder(1)
	if !dbSeek(xFilial("SA6")+M->VS9_PORTAD)
		return .f.
	endif
	oGetVS9:aCols[oGetVS9:nAt,FG_POSVAR("VS9_DESPOR","aHVS9")] := M->VS9_DESPOR := SA6->A6_NOME
EndIf
//###############################################################################
If cReadVar=="M->VS9_VALPAG"
	nCRSaldo := nCRTotal
	oGetVS9:aCols[oGetVS9:nAt,FG_POSVAR("VS9_VALPAG","aHVS9")] := M->VS9_VALPAG
	aEval(oGetVS9:aCols , {|x| nCRSaldo -= IIF( !x[Len(x)] , x[FG_POSVAR("VS9_VALPAG","aHVS9")] , 0 ) } )
	oCRSaldo:Refresh()
EndIf
//###############################################################################
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100DLVS9 บAutor  ณ Takahashi          บ Data ณ  07/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Deleta Linha da GetDados de Parcelas (VS9)                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100DLVS9()
Local nCntFor

Local PVS9ENTRAD := FG_POSVAR("VS9_ENTRAD","aHVS9")
Local PVS9VALPAG := FG_POSVAR("VS9_VALPAG","aHVS9")

// Nao permite delecao em linha de parcela calculada
if oGetVS9:aCols[oGetVS9:nAt,PVS9ENTRAD]=="N"
	return .f.
endif
//
If oGetVS9:aCols[oGetVS9:nAt,Len(oGetVS9:aCols[oGetVS9:nAt])]
	oGetVS9:aCols[oGetVS9:nAt,Len(oGetVS9:aCols[oGetVS9:nAt])] := .f.
Else
	oGetVS9:aCols[oGetVS9:nAt,Len(oGetVS9:aCols[oGetVS9:nAt])] := .t.
EndIf
// Calcula saldo remanescente apos a delecao
nCRSaldo := nCRTotal
aEval(oGetVS9:aCols , {|x| nCRSaldo -= IIF( !x[Len(x)] , x[PVS9VALPAG] , 0 ) } )
oCRSaldo:Refresh()
//
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100TUDOK บAutor  ณ Takahashi          บ Data ณ  16/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao para Fechamento                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100TUDOK()

Local nCntFor
Local nAuxNAt
Local lRetFech
Local nCntVS9
Local aVS9Obrigat
Local cGrp
Local cCodIte
Local oPeca      := DMS_Peca():New()
Local lAnyBlq    := .F.
Local DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")

nAuxNAt := oGetDetVO3:nAt
For nCntFor := 1 to Len(oGetDetVO3:aCols)
	oGetDetVO3:nAt := nCntFor
	If !OX100PDLOK()
		oGetDetVO3:nAt := nAuxNAt
		Return .f.
	EndIf
	
	cGrp    := oGetDetVO3:aCols[nCntFor, DVO3GRUITE]
	cCodIte := oGetDetVO3:aCols[nCntFor, DVO3CODITE]
	if oPeca:Bloqueado(/*cB1Cod*/, cCodIte, cGrp)
		lAnyBlq := .T.
	end
Next nCntFor
oGetDetVO3:nAt := nAuxNAt
if lAnyBlq
	return .F.
end

nAuxNAt := oGetResVO4:nAt
For nCntFor := 1 to Len(oGetResVO4:aCols)
	oGetResVO4:nAt := nCntFor
	If !OX100SRLOK()
		oGetResVO4:nAt := nAuxNAt
		Return .f.
	EndIf
Next nCntFor

For nCntFor:=1 to Len(aCpoVOO)
	If X3Obrigat(aCpoVOO[nCntFor]) .and. Empty( &("M->" + aCpoVOO[nCntFor]) )
		Help(" ",1,"OBRIGAT2",,RetTitle(aCpoVOO[nCntFor]),4,1)
		Return .f.
	EndIf
Next

// Se for integrar com o Loja, verifica se os campos estใo marcados como usados...
If OX100LOJA()
	If lChkLoja .and. !FMX_CHKLOJA()
		Return .f.
	EndIf
	// Controla marcas que nใo podem integrar com o loja quando o tipo de tempo ้ de garantia
	If cMVMIL0006 == "JD"
		For nCntFor := 1 to Len(aVetTTP)
			If aVetTTP[nCntFor,ATT_VETSEL] .and. OX100TTGAR( aVetTTP[nCntFor,ATT_TIPTEM] )
				Help(" ",1,"OX100LJGAR")
				Return .f.
			EndIf
		Next nCntFor
	EndIf
EndIf
//

// Se for condicao negociada verifica se existe os campos obrigatorios ...
SE4->(dbSetOrder(1))
SE4->(MsSeek( xFilial("SE4") + M->VOO_CONDPG ))
If SE4->E4_TIPO $ "9/A"
	
	aVS9Obrigat := {}
	For nCntFor := 1 to Len(oGetVS9:aHeader)
		If AllTrim(oGetVS9:aHeader[nCntFor,2]) $ "VS9_TIPPAG/VS9_DATPAG/VS9_VALPAG"
			AADD( aVS9Obrigat , nCntFor )
		EndIf
	Next
	For nCntVS9 := 1 to Len(oGetVS9:aCols)
		For nCntFor := 1 to Len(aVS9Obrigat)
			If !oGetVS9:aCols[nCntVS9,Len(oGetVS9:aCols[nCntVS9])] .and. Empty(oGetVS9:aCols[nCntVS9,aVS9Obrigat[nCntFor]])
				Help(" ",1,"OBRIGAT2",,RetTitle(oGetVS9:aHeader[aVS9Obrigat[nCntFor],2]),4,1)
				Return .f.
			EndIf
		Next
	Next
EndIf
//

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100FECHA บAutor  ณ Takahashi          บ Data ณ  16/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Fechamento da O.S.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100FECHA()

Local lRetorno   := .f.
Local nCntFor    := 0
Local nPosTTPFec := 0
Local lTopou     := .f.
Local nCntTipTem := 0
Local cAuxTipTem := ""

VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI")+__cUserID))

If lCanSel
	Return .f.
EndIf

// Verificar se existe(m) PECAS e/ou SERVICOS
If len(aAuxVO3) <= 0 .and. len(aAuxVO4) <= 0
	MsgAlert(STR0053,STR0004) // "Selecionar um registro para faturamento"
	Return .f.
EndIf

// Posiciona na Primeira OS a Ser Fechada ...
nPosTTPFec := aScan( aVetTTP , { |x| x[ATT_VETSEL] == .t. } )
If nPosTTPFec == 0
	MsgAlert(STR0053,STR0004) // "Selecionar um registro para faturamento"
	Return .f.
EndIf
//

// Usuario tem permissao de Negociacar / Fechar
If !lFECOFI .or. ( lFECOFI .and. VAI->VAI_FECOFI $ "13" )
	// Salva Negociacao ...
	If !OX100SNEG(.f.)
		Return .F.
	EndIf
	// Gera Liberacao de Desconto ou Verifica se a liberacao foi aprovada
	If !OX100LBDES(.t.)
		Return .F.
	EndIf
	// Usuario somente faz a negociacao do fechamento ...
	If VAI->VAI_FECOFI == "1"
		Help(" ",1,"OX100NAOFAT")
		Return .f.
	EndIf
EndIf

// Usuario tem permissao de Fechar
If !lFECOFI .or. ( lFECOFI .and. VAI->VAI_FECOFI == "2" )
	
	If !OX100TUDOK()
		Return .f.
	EndIf
	
	// Acerta coluna de Percentual de Rateio das Matrizes Auxiliares (VO3 e VO4)
	OX100PAVO3()
	OX100PAVO4()
	// Atualiza Resumo
	OX100ATRES(.f.)
	
	// Verifica se tem problema de Desconto ou se a liberacao foi aprovada
	If !OX100LBDES(.f.)
		Return .F.
	EndIf
	//
EndIf
//
If nCRSaldo <> 0
	MsgAlert(STR0055,STR0004) // O saldo das parcelas nใo confere com o total da Nota Fiscal!
	Return .f.
EndIf
//
// Joga o focus na Listbox pois quando o foco esta na grid de pecas ou servicos, ao voltar a dar desconto, 
// a rotina estava com as variaveis M-> com conteudo errado...
oLbTTP:SetFocus() 
If !MsgYesNo(STR0020)
	Return .f.
EndIf
// Avaliacao de Credito ...
VOI->(dbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + aVetTTP[ nPosTTPFec , ATT_TIPTEM ] ) )
If VOI->VOI_SITTPO <> "2"
	if Empty(GetNewPar("MV_CPNCLC","")) .or. !AllTrim(M->VOO_CONDPG) $ GetMv("MV_CPNCLC") .or. Empty(M->VOO_CONDPG)
		If "F" $ GetMv("MV_CHKCRE")
			If !FGX_AVALCRED(aVetTTP[nPosTTPFec,ATT_CLIENTE],aVetTTP[nPosTTPFec,ATT_LOJA],0,.t.)
				If VSW->(FieldPos("VSW_LIBVOO")) == 0
					Help(" ",1,"LIMITECRED")
					Return .f.
				Else
					lTodosOK := .t.
					cTTLB := ""
					For nCntFor := 1 to Len(aVetTTP)
						if aVetTTP[nCntFor,ATT_VETSEL] == .t.
							cQryACre := GetNextAlias()
							cQueryAC := "SELECT VSW.VSW_DTHLIB FROM " + RetSQLName("VSW") + " VSW "
							cQueryAC += " WHERE VSW_NUMORC = 'OS"+aVetTTP[nCntFor,ATT_NUMOSV]+"' AND VSW_TIPTEM= '"+aVetTTP[nCntFor,ATT_TIPTEM]+"'"
							cQueryAC += " AND VSW_LIBVOO= '"+aVetTTP[nCntFor,ATT_LIBVOO]+"'"
							cQueryAC += " AND  D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryAC ), cQryACre, .F., .T. )
							if !((cQryACre)->(eof()))
								if Empty((cQryACre)->VSW_DTHLIB)
									lTodosOK := .f.
									cTTLB += Alltrim(aVetTTP[nCntFor,ATT_TIPTEM])+"/"+Alltrim(aVetTTP[nCntFor,ATT_LIBVOO])+CHR(10)+CHR(13)
									//
								endif
							else
								if lTopou .or. MsgYesNo(STR0123,STR0004)
									DBSelectArea("SA1")
									DBSetOrder(1)
									DBSeek(xFilial("SA1")+aVetTTP[nCntFor,ATT_CLIENTE]+aVetTTP[nCntFor,ATT_LOJA])
									DBSelectArea("VSW")
									reclock("VSW",.t.)
									VSW_FILIAL := xFilial("VSW")
									VSW_CODCLI := SA1->A1_COD
									VSW_LOJA   := SA1->A1_LOJA
									VSW_VALCRE := aVetTTP[nCntFor,ATT_TOTPEC] + aVetTTP[nCntFor,ATT_TOTSER]       // nTotnFiscal
									VSW_ORIGEM := "OFIXX100"
									VSW_RISANT := SA1->A1_RISCO
									VSW_LCANT  := SA1->A1_LC
									VSW_VLCANT := SA1->A1_VENCLC
									VSW_USUARI := VAI->VAI_NOMUSU
									VSW_DATHOR := Left(Dtoc(dDataBase),6)+Right(STR(Year(dDataBase)),2)+"-"+Left(Time(),5)
									VSW_NUMORC := "OS"+aVetTTP[nCntFor,ATT_NUMOSV]
									VSW_TIPTEM := aVetTTP[nCntFor,ATT_TIPTEM]
									VSW_LIBVOO := aVetTTP[nCntFor,ATT_LIBVOO]
									msunlock()
									If lTopou
										MsgInfo(STR0124,STR0004)
									EndIf
									lTopou := .t.
								endif
								if !lTopou
									Help(" ",1,"LIMITECRED")
									(cQryACre)->(dbCloseArea())
									Return .f.
								endif
							endif
							(cQryACre)->(dbCloseArea())
						endif
					next
					if lTopou
						return .f.
					endif
					if !lTodosOK .and. !lTopou
						MsgInfo(STR0122+CHR(10)+CHR(13)+cTTLB,STR0004)
						return .f.
					endif
				endif
			endif
		EndIf
	EndIf
Endif

// ANTIGO - Compatibilizacao com o OFIOM160, para novas implantacoes utilizar outro PE
If ExistBlock("OFM160A")
	If !ExecBlock("OFM160A",.f.,.f.)
		Return(.f.)
	EndIf
EndIf
If ExistBlock("OX100A") // Deve ser utilizado este ponto de entrada
	If !ExecBlock("OX100A",.f.,.f.)
		Return(.f.)
	EndIf
EndIf
//

Processa( {|| lRetorno := OX100PFECH(nPosTTPFec) }, STR0056 , STR0057 ,.F.)

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100PFECH บAutor  ณ Takahashi          บ Data ณ  16/12/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Processa o Fechamento da O.S.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100PFECH(nPosTTPFec)

Local lCupom     := .f.   // Gera Cupom Fiscal
Local lNF        := .f.   // Gera Nota Fiscal
Local aTipTem    := {}    // Contem os TT Selecionados para Fechamento
Local nAuxTot
Local nCntFor
Local nProc
Local nCntTipTem
Local nCntVO4
Local nCntVO4Apo
Local cNumPed
Local lRet
Local nPosAux
Local aAuxPeca        // Matriz Auxiliar para Verificar se tem Qtde Disponivel para Todos os Itens
Local aIteTempPV
Local cItemPed        // Sequencia do Item no Pedido de Venda
Local cAliasVO3    := "TVO3"
Local cAliasVO4    := "TVO4"
Local cAliasSE1    := "TSE1"
Local cGCFOCEV             // Utilizado para CEV
Local lNFSrvc      := .f.  // Gera Nota Fiscal de Servico ?
Local cPrefNF
Local nValAbat             // Total dos Titulos de Abatimento Financeiro

Local lAltSA1      := .f.  // Controla se Foi alterado o cliente para geracao de Titulo
Local cBkpNatSA1           // Backup da Natureza do cliente ...
Local nRecSA1      := 0

Local lFecPeca     := .f.  // Indica se tem peca no Fechamento
Local lFecSrvc     := .f.  // Indica se tem srvc no Fechamento
Local lFecAgru     := .f.  // Indica se ้ fechamento agrupado

Local lRegSaida    := .f.  // Registra saida do veiculo ...

Local dDatFec      := dDataBase
Local nHorFec      := Val(Left(Time(),2)+SubStr(Time(),4,2))

Local cNota        := ""
Local cSerie       := ""
Local cSeriePec    := "" // Serie para faturamento de NF de Peca
Local cSerieSer    := "" // Serie para faturamento de NF de Servico
Local cOrcLoja     := ""
Local aInfNF       := {}
Local nVlrInt
Local nAuxVlrInt   := 0  // Contem diferenca no momento da gravacao do VO4_VALINT para TT Interno

Local nVO4TEMCOB         // Utilizado para verificar problema de arredondamento

Local lPeriodico   := .f.// Indica se o Cliente ้ Periodico

Local nPosSel

Local lVCM510CEV   := FindFunction("VCM510CEV")
Local cObsCEV      := ""
Local ni           := 0
Local aCEV         := {}
Local cSQL         := ""

Local nQtdParc     := 0
Local nTotalFec    := 0

Local n_VALBRU     := 0 // Valor da Peca/Servico
Local n_PERDES     := 0 // Percentual de Desconto
Local n_VALDES     := 0 // Valor do Desconto

Local aFINA040     := {}

Local cParcela     := ""
Local nTamE1PARCELA:= 0
Local _nRecSA1

Local cBkpUserName

Local cTesNegoc // TES da negocia็ใo

Local aRetPE       := {.f.,""}

Local nPosSB0      := 0
Local aSB0         := {}

Local cCodMar      := ""
Local nPosRel      := 0
Local oPeca        := DMS_Peca():New()

Local lMVLJCNVDA   := GetNewPar("MV_LJCNVDA",.f.)
Local cMVTABPAD    := Alltrim(GetNewPar("MV_TABPAD","1"))

Local nVlrTotParc  := 0

Local cFormaID     := " "

Local lLJPRDSV  := (GetNewPar("MV_LJPRDSV",.f.) .and. lMVMIL0084 )

Private cDMSPrefOri:= GetNewPar("MV_PREFOFI","OFI")

Private cMVBXSER   := GetNewPar("MV_BXSER","N")
Private lESTNEG    := (GetMV("MV_ESTNEG") == "S")
Private c1DUPNAT   := Alltrim(GetMV("MV_1DUPNAT"))

Private aVS9SE1    := {}   // Contem os registros da VS9 quando for condicao negociada
Private nCntSE1    := 0

Private aRelFatOfi    // Matriz Auxiliar com o relacionamento de oGetDetVO3:aCols/oGetResVO4:aCols com o Item do Pedido de Venda (SC6)

Private aCabPV, aIte, aPvlNfs

Private cOX100Serie:= "" // Variavel para ser utilizada no ponto de entrada a funcao SX5NumNota para que o cliente possa saber se estamos solicitando a serie de [P]ecas ou [S]ervico

Private lVOOPESOL  := ( VOO->(FieldPos("VOO_PESOL")) > 0 )
Private lVOOPBRUTO := ( VOO->(FieldPos("VOO_PBRUTO")) > 0 )
Private lVOOVEICUL := ( VOO->(FieldPos("VOO_VEICUL")) > 0 )
Private lVOOVOLUM1 := ( VOO->(FieldPos("VOO_VOLUM1")) > 0 )
Private lVOOVOLUM2 := ( VOO->(FieldPos("VOO_VOLUM2")) > 0 )
Private lVOOVOLUM3 := ( VOO->(FieldPos("VOO_VOLUM3")) > 0 )
Private lVOOVOLUM4 := ( VOO->(FieldPos("VOO_VOLUM4")) > 0 )
Private lVOOESPEC1 := ( VOO->(FieldPos("VOO_ESPEC1")) > 0 )
Private lVOOESPEC2 := ( VOO->(FieldPos("VOO_ESPEC2")) > 0 )
Private lVOOESPEC3 := ( VOO->(FieldPos("VOO_ESPEC3")) > 0 )
Private lVOOESPEC4 := ( VOO->(FieldPos("VOO_ESPEC4")) > 0 )
Private lVOOVLBRNF := ( VOO->(FieldPos("VOO_VLBRNF")) > 0 )
Private lVOOTIPOCL := ( VOO->(FieldPos("VOO_TIPOCL")) > 0 )
Private lVSCITENFI := ( VSC->(FieldPos("VSC_ITENFI")) > 0 )

Private DVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Det")
Private DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")
Private DVO3DESITE := FG_POSVAR("VO3_DESITE","aHVO3Det")
Private DVO3CODTES := FG_POSVAR("VO3_CODTES","aHVO3Det")
Private DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Private DVO3QTDREQ := FG_POSVAR("VO3_QTDREQ","aHVO3Det")
Private DVO3VALPEC := FG_POSVAR("VO3_VALPEC","aHVO3Det")
Private DVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Det")
Private DVO3PERDES := FG_POSVAR("VO3_PERDES","aHVO3Det")
Private DVO3ACRESC := FG_POSVAR("VO3_ACRESC","aHVO3Det")
Private DVO3LOTECT := FG_POSVAR("VO3_LOTECT","aHVO3Det")
Private DVO3NUMLOT := FG_POSVAR("VO3_NUMLOT","aHVO3Det")
Private DVO3PEDXML := FG_POSVAR("VO3_PEDXML","aHVO3Det")
Private DVO3ITEXML := FG_POSVAR("VO3_ITEXML","aHVO3Det")

Private DVO3CENCUS := FG_POSVAR("VO3_CENCUS","aHVO3Det")
Private DVO3CONTA  := FG_POSVAR("VO3_CONTA" ,"aHVO3Det")
Private DVO3ITEMCT := FG_POSVAR("VO3_ITEMCT","aHVO3Det")
Private DVO3CLVL   := FG_POSVAR("VO3_CLVL"  ,"aHVO3Det")

Private DVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Det")
Private DVO4CODSER := FG_POSVAR("VO4_CODSER","aHVO4Det")
Private DVO4GRUSER := FG_POSVAR("VO4_GRUSER","aHVO4Det")
Private DVO4DESSER := FG_POSVAR("VO4_DESSER","aHVO4Det")

Private RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Private RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")
Private RVO4CODTES := FG_POSVAR("VO4_CODTES","aHVO4Res")
Private RVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Res")
Private RVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Res")
Private RVO4PERDES := FG_POSVAR("VO4_PERDES","aHVO4Res")
Private RVO4PEDXML := FG_POSVAR("VO4_PEDXML","aHVO4Res")
Private RVO4ITEXML := FG_POSVAR("VO4_ITEXML","aHVO4Res")

Private RVO4CENCUS := FG_POSVAR("VO4_CENCUS","aHVO4Res")
Private RVO4CONTA  := FG_POSVAR("VO4_CONTA" ,"aHVO4Res")
Private RVO4ITEMCT := FG_POSVAR("VO4_ITEMCT","aHVO4Res")
Private RVO4CLVL   := FG_POSVAR("VO4_CLVL"  ,"aHVO4Res")

Private PVS9VALPAG := FG_POSVAR("VS9_VALPAG","aHVS9")
Private PVS9DATPAG := FG_POSVAR("VS9_DATPAG","aHVS9")
Private PVS9TIPPAG := FG_POSVAR("VS9_TIPPAG","aHVS9")

Private PVS9FORMID := FG_POSVAR("VS9_FORMID","aHVS9")

Private lOX100AIP := ExistBlock("OX100AIP")

//////////
// VERIFICAR SE ALGUMA OS FOI ALTERADA ENTRE
// A SELECAO PARA FECHAMENTO E O FECHAMENTO EM SI
//////////

SE4->(dbSetOrder(1))
SE4->(dbSeek( xFilial("SE4") + M->VOO_CONDPG ))

// Condicao do Tipo "9" --> Verificar qtde maxima de parcelas ( padrao TOTVS: MV_NUMPARC )
If OX1000061_Condicao_Negociada()
	aEval(oGetVS9:aCols , {|x| nQtdParc += IIF( !x[Len(x)] , 1 , 0 ) } )
	If nQtdParc > GetMV("MV_NUMPARC")
		Help(" ",1,"OX100NPARC")
		Return .f.
	EndIf
EndIf
If FindFunction("FMX_VLDSE4")
	aEval(oGetVS9:aCols , {|x| nVlrTotParc += IIF( !x[Len(x)] , x[PVS9VALPAG] , 0 ) } )
	If !FMX_VLDSE4("",nVlrTotParc) // Verifica Valor SUPERIOR e INFERIOR para utilizar o SE4
		Return .f.
	EndIf
EndIf

lGarPeca := .t.
For nCntFor := 1 to Len(aVetTTP)
	If !aVetTTP[nCntFor, ATT_VETSEL]
		Loop
	EndIf
	// Cria matriz com os TT Selecionados para Fechamento
	OX100TIPTEM( nCntFor , @aTipTem , .t. )
	// Controla se ้ fechamento de tipo de tempo de garantia de peca...
	OX100GARPECA( nCntFor , @cCodMar )
	//
Next nCntFor

//
If OX100LOJA()
	lCupom := .t.
	// Pecas
	SF4->(dbSetOrder(1))
	For nCntFor := 1 to Len(oGetDetVO3:aCols)
		if !Empty(oGetDetVO3:aCols[nCntFor,DVO3CODTES])
			SF4->(MsSeek(xFilial("SF4") + oGetDetVO3:aCols[nCntFor,DVO3CODTES] ) )
			If SF4->F4_DUPLIC == "N"
				MsgStop(STR0131+ chr(13) + chr(10) + chr(13) + chr(10) +STR0132+oGetDetVO3:aCols[nCntFor, DVO3GRUITE ]+" - "+oGetDetVO3:aCols[nCntFor,DVO3CODITE]+"   "+oGetDetVO3:aCols[nCntFor,DVO3DESITE])
				Return(.f.)
			Endif
		Endif
	Next
	// Servicos
	SF4->(dbSetOrder(1))
	For nCntVO4 := 1 to Len(oGetResVO4:aCols)
		if !Empty(oGetResVO4:aCols[nCntVO4,RVO4CODTES])
			SF4->(MsSeek(xFilial("SF4") + oGetResVO4:aCols[nCntVO4,RVO4CODTES] ) )
			If SF4->F4_DUPLIC == "N"
				MsgStop(STR0131+ chr(13) + chr(10) + chr(13) + chr(10) +STR0133+oGetResVO4:aCols[nCntVO4,RVO4TIPTEM]+"  "+STR0144+oGetResVO4:aCols[nCntVO4,RVO4TIPSER]+"     "+STR0145+oGetResVO4:aCols[nCntVO4,RVO4CODTES])
				Return(.f.)
			Endif
		Endif
	Next
Else
	// Procura um tipo de tempo com pe็a ou com servico e que gera NF
	If aScan( aTipTem, { |x| x[FTT_TIPFEC] == "P" .or. ( x[FTT_TIPFEC] == "S" .and. x[FTT_NFSRVC] ) } ) <> 0
		lNF := .t.
	EndIf
EndIf

If !OX100CONDNEG( aTipTem , lCupom , lNF )
	Return .f.
EndIf

VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI") + __cUserID ))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se Estoque nao pode ser negativado, verifica se tem qtde disponivel para ณ
//ณ todas as pecas que movimentam estoque ...                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lESTNEG
	
	IncProc(STR0058) // "Verificando estoque"
	
	aAuxPeca := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gera uma matriz auxiliar pois o mesmo item pode aparecer ณ
	//ณ duas vezes na GetDados de Pecas ...                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SF4->(dbSetOrder(1))
	For nCntFor := 1 to Len(oGetDetVO3:aCols)
		SF4->(MsSeek(xFilial("SF4") + oGetDetVO3:aCols[nCntFor,DVO3CODTES] ) )
		If SF4->F4_ESTOQUE == "S"
			VOI->(dbSetOrder(1))
			VOI->(MsSeek(xFilial("VOI") + oGetDetVO3:aCols[nCntFor,DVO3TIPTEM] ) )
			If ( nPosAux := aScan( aAuxPeca, { |x| x[1] == oGetDetVO3:aCols[nCntFor, DVO3GRUITE ] .and. x[2] == oGetDetVO3:aCols[nCntFor,DVO3CODITE] .and. x[4] == VOI->VOI_CODALM } ) ) == 0
				AADD( aAuxPeca , { oGetDetVO3:aCols[nCntFor, DVO3GRUITE ], oGetDetVO3:aCols[nCntFor, DVO3CODITE ], 0 , VOI->VOI_CODALM} )
				nPosAux := Len(aAuxPeca)
			EndIf
			aAuxPeca[nPosAux,3] += oGetDetVO3:aCols[nCntFor,DVO3QTDREQ]
		EndIf
	Next nCntFor
	//
	
	For nCntFor := 1 to Len(aAuxPeca)
		SB1->(DbSetOrder(7))
		SB1->(MsSeek(xFilial("SB1") + aAuxPeca[nCntFor,1] + aAuxPeca[nCntFor,2]))
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek(xFilial("SB2") + SB1->B1_COD + aAuxPeca[nCntFor,4] )
		IF SaldoSB2() < aAuxPeca[nCntFor,3]
			MsgInfo(STR0018 + chr(13) + chr(10) + STR0019 + aAuxPeca[nCntFor,1] + " - " + aAuxPeca[nCntFor,2] ,STR0004) // "Quantidade em estoque nao disponivel para atender o pedido."
			Return .f.
		EndIf
	Next nCntFor
	//
EndIf
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se deve registrar a SAIDA do veiculo ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRegSaida := .f.
If VOI->(FieldPos("VOI_SAIVEI")) <> 0 .and. VOI->VOI_SAIVEI == "2"
	If MsgYesNo(STR0026, STR0004)
		lRegSaida := .t.
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                                        ณ
//ณ Selecionar Serie para Faturamento ...  ณ
//ณ                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lNF
	
	cSeriePec := ""
	cSerieSer := ""
	
	If lMVMIL0084
		cOX100Serie := "P"
		If !SX5NumNota(@cSeriePec, GetNewPar("MV_TPNRNFS","1"))
			Return .f.
		EndIf
		cSerieSer := cSeriePec
	Else
		For nCntFor := 1 to Len(aTipTem)
			// Faturamento de Pecas
			If aTipTem[nCntFor,FTT_TIPFEC] == "P" .and. Empty(cSeriePec)
				cOX100Serie := "P"
				If !SX5NumNota(@cSeriePec, GetNewPar("MV_TPNRNFS","1")," - " + STR0046)
					Return .f.
				EndIf
			EndIf
			
			// Faturamento de Servicos e Gera NF de Servicos
			If aTipTem[nCntFor,FTT_TIPFEC] == "S" .and. aTipTem[nCntFor,FTT_NFSRVC] .and. Empty(cSerieSer)
				cOX100Serie := "S"
				If !SX5NumNota(@cSerieSer, GetNewPar("MV_TPNRNFS","1")," - " + STR0047)
					Return .f.
				EndIf
			EndIf
			//
			
			If !Empty(cSeriePec) .and. !Empty(cSerieSer)
				Exit
			EndIf
			
		Next nCntFor
		
	EndIf
EndIf

aRelFatOfi := {}

If lNF
	If nVerParFat == 1 // NAO mostrar os Parametros do Faturamento no momento da geracao da NF
		PERGUNTE("MT460A",.f.)
	Else // nVerParFat == 2 // Mostrar os Parametros do Faturamento no momento da geracao da NF
		While .t.
			If PERGUNTE("MT460A",.t.)
				Exit
			EndIf
		EndDo
	EndIf
EndIf

Begin Transaction

// ANTIGO - Compatibilizacao com o OFIOM160, para novas implantacoes utilizar outro PE
If ExistBlock("O160ANGR")
	ExecBlock("O160ANGR",.f.,.f.)
EndIf
If ExistBlock("OX100AGR") // Deve ser utilizado este ponto de entrada
	ExecBlock("OX100AGR",.f.,.f.)
EndIf
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                                        ณ
//ณ Gera Pedido de Venda e Nota Fiscal ... ณ
//ณ                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lNF
	
	// Salva a Situacao atual do Fiscal
	MaFisSave()
	MaFisEnd()
	//
	
	lPeriodico  := .f.
	aVS9SE1 := {}
	//	nCntParcel := 0
	
	If lMVMIL0084
		aCabPV   := {}
		aIte     := {}
		aPvlNfs  := {}
		cAuxProc := " "
		cNumPed  := ""
		cItemPed := "00"
		cNota    := ""
		cCondVS9 := ""
		
		lFecPeca := aScan( oGetDetVO3:aCols , { |x| !Empty(x[DVO3CODITE]) } ) <> 0
		lFecSrvc := aScan( oGetDetVO4:aCols , { |x| !Empty(x[DVO4CODSER]) } ) <> 0
		lNFSrvc  := aScan( aTipTem , { |x| x[FTT_NFSRVC] } ) <> 0
		
		For nCntTipTem := 1 to Len(aTipTem)
			OX100PEDFAT( @aTipTem[nCntTipTem] , cAuxProc , @cNumPed , @cItemPed, @lPeriodico, lFecPeca, lFecSrvc, lNFSrvc , @cCondVS9 )
		Next nCntTipTem
		
		
		cSerie := cSeriePec
		
		cPedSC5 := cNumPed
		
		If !OX100GERNF( @cNumPed , @cSerie, @cNota , .t. , .t. , lPeriodico , cCodMar , cCondVS9 )
			Return .f.
		EndIf
		
		For nCntTipTem := 1 to Len(aTipTem)
			If aTipTem[nCntTiPTem,FTT_PEDFAT] == cPedSC5
				aTipTem[ nCntTipTem, FTT_SERNFI ] := cSerie
				aTipTem[ nCntTipTem, FTT_NUMNFI ] := cNota
				aTipTem[ nCntTipTem, FTT_CODBCO ] := M->VOO_BANCO
				aTipTem[ nCntTiPTem, FTT_PEDFAT ] := cNumPed
			EndIf
		Next nCntTipTem
		
	ElseIf lMVMIL0059
		
		
		For nProc := 1 to 2
			
			aCabPV   := {}
			aIte     := {}
			aPvlNfs  := {}
			cAuxProc := IIf( nProc == 1 , "P" , "S" )
			cNumPed  := ""
			cItemPed := "00"
			cNota    := ""
			cCondVS9 := ""
			
			For nCntTipTem := 1 to Len(aTipTem)
				OX100TPPROC(  aTipTem[nCntTipTem] , cAuxProc , @lFecPeca, @lFecSrvc, @lNFSrvc)
				OX100PEDFAT( @aTipTem[nCntTipTem] , cAuxProc , @cNumPed , @cItemPed, @lPeriodico, lFecPeca, lFecSrvc, lNFSrvc , @cCondVS9 )
			Next nCntTipTem
			
			If Empty(cNumPed) .or. Len(aIte) == 0
				Loop
			EndIf
			
			cSerie := IIf( nProc == 1 , cSeriePec , cSerieSer )
			
			cPedSC5 := cNumPed
			
			If !OX100GERNF( @cNumPed , @cSerie, @cNota , ( nProc == 1 ) , ( nProc == 2 ) , lPeriodico , cCodMar , cCondVS9 )
				Return .f.
			EndIf
			
			For nCntTipTem := 1 to Len(aTipTem)
				If aTipTem[nCntTiPTem,FTT_PEDFAT] == cPedSC5
					aTipTem[ nCntTipTem, FTT_SERNFI ] := cSerie
					aTipTem[ nCntTipTem, FTT_NUMNFI ] := cNota
					aTipTem[ nCntTipTem, FTT_CODBCO ] := M->VOO_BANCO
					aTipTem[ nCntTiPTem, FTT_PEDFAT ] := cNumPed
				EndIf
			Next nCntTipTem
			
		Next nProc
		
	Else
		
		For nCntTipTem := 1 to Len(aTipTem)
			
			aCabPV   := {}
			aIte     := {}
			aPvlNfs  := {}
			cNumPed  := ""
			cItemPed := "00"
			cNota    := ""
			cCondVS9 := ""
			
			OX100TPPROC(aTipTem[nCntTipTem], "", @lFecPeca, @lFecSrvc, @lNFSrvc)
			
			OX100PEDFAT( @aTipTem[nCntTipTem] , "" , @cNumPed, @cItemPed, @lPeriodico, lFecPeca, lFecSrvc, lNFSrvc, @cCondVS9 )
			If Empty(cNumPed) .or. Len(aIte) == 0
				Loop
			EndIf
			
			cSerie := IIf( lFecPeca , cSeriePec , cSerieSer )
			If !OX100GERNF( @cNumPed , @cSerie, @cNota , lFecPeca , lFecSrvc , lPeriodico , cCodMar , cCondVS9 )
				Return .f.
			EndIf
			
			aTipTem[ nCntTipTem, FTT_SERNFI ] := cSerie
			aTipTem[ nCntTipTem, FTT_NUMNFI ] := cNota
			aTipTem[ nCntTipTem, FTT_CODBCO ] := M->VOO_BANCO
			aTipTem[ nCntTiPTem, FTT_PEDFAT ] := cNumPed
			
		Next nCntTipTem
		
	EndIf
	
	// Restaura o Fiscal
	MaFisEnd()
	MaFisRestore()
	//
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                                        ณ
//ณ Gera CUPOM FISCAL                      ณ
//ณ                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lCupom
	
	aCabPV    := {}
	cTipTemOrc  := ""
	
	For nCntTipTem := 1 to Len(aTipTem)
		
		VOI->(dbSetOrder(1))
		VOI->(MsSeek( xFilial("VOI") + aTipTem[nCntTipTem,1] ))
		
		SA1->(dbSetOrder(1))
		SA1->(MsSeek( xFilial("SA1") + aTipTem[nCntTipTem,2] + aTipTem[nCntTipTem,3] ))
		
		SA3->(dbSetOrder(1))
		SA3->(dbSeek( xFilial("SA3") + aTipTem[nCntTipTem,FTT_CODVEN]))
		
		// Verifica se existe Peca / Servico no Fechamento ...
		lFecPeca := ( aScan( oGetDetVO3:aCols , { |x| x[DVO3TIPTEM] == aTipTem[nCntTipTem,1] .and. !Empty(x[DVO3CODITE]) } ) <> 0 )
		lFecSrvc := ( aScan( oGetDetVO4:aCols , { |x| x[DVO4TIPTEM] == aTipTem[nCntTipTem,1] .and. !Empty(x[DVO4CODSER]) } ) <> 0 )
		//
		
		lNFSrvc := aTipTem[nCntTipTem,10]
		
		// Nao deve gerar a NF de Peca/Servico
		If !( lFecPeca .or. (lFecSrvc .and. lNFSrvc) )
			Loop
		EndIf
		//
		
		IncProc( STR0119 )  // "Gerando or็amento"
		
		// Se gerar Pecas e Servicos junto, so gera um cabecalho de orcamento ...
		If (lLJPRDSV .and. Len(aCabPV) == 0) .or. !lLJPRDSV
			
			aCabPV   := {}
			aIte   := {}
			cTipTemOrc := ""
			cItemPed := Replicate("0",TamSX3("LR_ITEM")[1])
			
			cBkpUserName := cUserName // Armazena o usuario logado atualmente
			cUserName := ALlTrim(GetNewPar("MV_MIL0019",cUserName))
			
			aCabPV := Array(31)
			aCabPV[01] := {"LQ_VEND"    , VAI->VAI_CODVEN                                , NIL }
			aCabPV[02] := {"LQ_COMIS"   , 0                                              , NIL }
			aCabPV[03] := {"LQ_CLIENTE" , SA1->A1_COD                                    , NIL }
			aCabPV[04] := {"LQ_LOJA"    , SA1->A1_LOJA                                   , NIL }
			If lVOOTIPOCL .and. !Empty(M->VOO_TIPOCL)
				aCabPV[05] := {"LQ_TIPOCLI" , M->VOO_TIPOCL                               , NIL }
			Else
				aCabPV[05] := {"LQ_TIPOCLI" , SA1->A1_TIPO                                , NIL }
			EndIf
			aCabPV[06] := {"LQ_NROPCLI" , "         "                                    , NIL }
			aCabPV[07] := {"LQ_DTLIM"   , dDataBase                                      , NIL }
			aCabPV[08] := {"LQ_DOC"     , ""                                             , NIL }
			aCabPV[09] := {"LQ_SERIE"   , ""                                             , NIL }
			aCabPV[10] := {"LQ_PDV"     , "0001      "                                   , NIL }
			aCabPV[11] := {"LQ_EMISNF"  , dDatabase                                      , NIL }
			aCabPV[12] := {"LQ_TIPO"    , "V"                                            , NIL }
			aCabPV[13] := {"LQ_DESCNF"  , 0                                              , NIL }
			aCabPV[14] := {"LQ_OPERADO" , xNumCaixa()                                    , NIL }
			aCabPV[15] := {"LQ_PARCELA" , 0                                              , NIL }
			aCabPV[16] := {"LQ_FORMPG"  , "R$"                                           , NIL }
			aCabPV[17] := {"LQ_EMISSAO" , dDatabase                                      , NIL }
			aCabPV[18] := {"LQ_NUMCFIS" , ""                                             , NIL }
			aCabPV[19] := {"LQ_IMPRIME" , "1S        "                                   , NIL }
			aCabPV[20] := {"LQ_VLRDEBI" , 0                                              , NIL }
			aCabPV[21] := {"LQ_HORA"    , time()                                         , NIL }
			aCabPV[22] := {"LQ_NUMMOV"  ,"1 "                                            , NIL }
			aCabPV[23] := {"LQ_ORIGEM"  , "V"                                            , NIL }
			aCabPV[24] := {"LQ_COMIS"   , SA3->A3_COMIS                                  , NIL }
			aCabPV[25] := {"LQ_VEND2"   , ""                                             , NIL }
			aCabPV[26] := {"LQ_VEND3"   , ""                                             , NIL }
			aCabPV[27] := {"LQ_VEICTIP" , "2"                                            , NIL } // LQ_VEICTIP - Quem esta gravando - 2 = Oficina
			aCabPV[28] := {"LQ_VEIPESQ" , aTipTem[nCntTipTem,13] + aTipTem[nCntTipTem,1] , NIL } // LQ_VEIPESQ - Chave a pesquisar
			aCabPV[29] := {"LQ_RECISS"  , Iif(Empty(M->VOO_RECISS), "0", M->VOO_RECISS)  , NIL } // Recolhe ISS: 1 - Sim / 2 - Nใo
			aCabPV[30] := {"AUTRESERVA" ,"000001"                                        , NIL }

			If lFecPeca .and. ! Empty(M->VOO_MNNOTP)
				aCabPV[31] := {"LQ_MENNOTA", M->VOO_MNNOTP , Nil}
			ElseIf lFecSrvc .and. ! Empty(M->VOO_MNNOTS)
				aCabPV[31] := {"LQ_MENNOTA", M->VOO_MNNOTS , Nil}
			Else	
				aCabPV[31] := {"LQ_MENNOTA", "" , Nil}
			Endif		
			
			cUserName := cBkpUserName // Volta o usuario logado ...
			
		EndIf
		
		cTipTemOrc  += aTipTem[nCntTipTem,1] + "/"
		
		DBSelectArea("SB1")
		SF4->(dbSetOrder(1))
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Itens do Orcamento do Loja - P E C A S ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		If lFecPeca
			For nCntFor := 1 to Len(oGetDetVO3:aCols)
				
				If oGetDetVO3:aCols[nCntFor, DVO3TIPTEM] <> aTipTem[nCntTipTem,1]
					Loop
				EndIf
				SB1->(dbSetOrder(7))
				SB1->(DBSeek(xFilial("SB1") + oGetDetVO3:aCols[nCntFor,DVO3GRUITE] + oGetDetVO3:aCols[nCntFor,DVO3CODITE] ))
				SB1->(dbSetOrder(1))
				If lVOOVLBRNF .and. M->VOO_VLBRNF == "0" // Nao passar o Valor Bruto para NF/Loja
					n_VALBRU := ( oGetDetVO3:aCols[nCntFor, DVO3VALPEC] - ( oGetDetVO3:aCols[nCntFor, DVO3VALDES] / oGetDetVO3:aCols[nCntFor, DVO3QTDREQ] ) )
					n_PERDES := 0
					n_VALDES := 0
				Else // Passar Valor Bruto e Desconto para NF/Loja
					n_VALBRU := oGetDetVO3:aCols[nCntFor,DVO3VALPEC]
					n_PERDES := oGetDetVO3:aCols[nCntFor,DVO3PERDES]
					n_VALDES := oGetDetVO3:aCols[nCntFor,DVO3VALDES]
				EndIf
				
				If cUsaAcres == 'S'
					n_VALBRU += oGetDetVO3:aCols[nCntFor, DVO3ACRESC] / oGetDetVO3:aCols[nCntFor, DVO3QTDREQ]
				EndIf
				
				/////////////////////////////////////////////////////////////////////
				// Atualizar SB0 - Precos por Produto - Tabela OBRIGATORIA no Loja //
				/////////////////////////////////////////////////////////////////////
				If !lMVLJCNVDA // Quando o parametro MV_LJCNVDA for .T. o LOJA utilizara a tabela de preco da totvs (DA0)
					nPosSB0 := aScan( aSB0 , { |x| x[1] == SB1->B1_COD } )
					If nPosSB0 <= 0
						aAdd(aSB0,{SB1->B1_COD,"0"})
						nPosSB0 := len(aSB0)
					EndIf
					aSB0[nPosSB0,2] := strzero(val(aSB0[nPosSB0,2])+1,1)
					
					SB0->(DbSetOrder(1))
					SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
					dbSelectArea("SB0")
					RecLock("SB0",!SB0->(Found()))
					SB0->B0_FILIAL := xFilial("SB0")
					SB0->B0_COD    := SB1->B1_COD
					&("SB0->B0_PRV"+aSB0[nPosSB0,2]) := n_VALBRU
					MsUnLock()
					dbSelectArea("SB1")
				EndIf
				//
				
				cItemPed := Soma1( cItemPed , Len(cItemPed) )
				
				AADD(aIte,Array( IIf( (lCtrlLote .and. !Empty(oGetDetVO3:aCols[nCntFor,DVO3LOTECT])) , 19 , 16 ) ))
				aIte[Len(aIte),01] := { "LR_FILIAL"   , xFilial("SL2")                                       , NIL }
				aIte[Len(aIte),02] := { "LR_PRODUTO"  , SB1->B1_COD                                          , NIL }
				aIte[Len(aIte),03] := { "LR_LOCAL"    , VOI->VOI_CODALM                                      , NIL }
				aIte[Len(aIte),04] := { "LR_LOCALIZ"  , IIf(Localiza(SB1->B1_COD),VOI->VOI_LOCALI,Space(15)) , NIL }
				aIte[Len(aIte),05] := { "LR_TABELA"   , IIf( lMVLJCNVDA , "1" , aSB0[nPosSB0,2] )            , NIL }
				aIte[Len(aIte),06] := { "LR_ITEM"     , cItemPed                                             , NIL }
				aIte[Len(aIte),07] := { "LR_QUANT"    , oGetDetVO3:aCols[nCntFor,DVO3QTDREQ]                 , NIL }
				aIte[Len(aIte),08] := { "LR_UM"       , SB1->B1_UM                                           , NIL }
				aIte[Len(aIte),09] := { "LR_PRCTAB"   , n_VALBRU                                             , NIL }
				aIte[Len(aIte),10] := { "LR_VRUNIT"   , n_VALBRU                                             , NIL }
				aIte[Len(aIte),11] := { "LR_VALDESC"  , n_VALDES                                             , NIL }
				aIte[Len(aIte),12] := { "LR_TES"      , oGetDetVO3:aCols[nCntFor,DVO3CODTES]                 , NIL }
				aIte[Len(aIte),13] := { "LR_DOC"      , ""                                                   , NIL }
				aIte[Len(aIte),14] := { "LR_SERIE"    , ""                                                   , NIL }
				aIte[Len(aIte),15] := { "LR_PDV"      , "0001"                                               , NIL }
				aIte[Len(aIte),16] := { "LR_DESCPRO"  , 0                                                    , NIL }
				
				If (lCtrlLote .and. !Empty(oGetDetVO3:aCols[nCntFor,DVO3LOTECT]))
					oPeca:LoadB1()
					aIte[Len(aIte),17] := { "LR_LOTECTL" , oGetDetVO3:aCols[nCntFor,DVO3LOTECT]						,NIL }
					aIte[Len(aIte),18] := { "LR_NLOTE"   , oGetDetVO3:aCols[nCntFor,DVO3NUMLOT]						,NIL }
					aIte[Len(aIte),19] := { "LR_DTVALID" , oPeca:LoteDtValid(oGetDetVO3:aCols[nCntFor,DVO3LOTECT])	,NIL }
				EndIf

				// Adiciona na Matriz de Relacionamento do oGetDetVO3:aCols/oGetResVO4:aCols com o SC6,
				// utilizado depois para gerar VEC e VSC ...
				AADD( aRelFatOfi, { "VO3" , nCntFor , cItemPed , "" } )
				//
				
			Next
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Itens do Pedido de Venda - S E R V I C O S ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lFecSrvc .and. lNFSrvc
			
			VOK->(dbSetOrder(1))
			
			For nCntFor := 1 to Len(oGetResVO4:aCols)
				
				If oGetResVO4:aCols[nCntFor, RVO4TIPTEM ] <> aTipTem[nCntTipTem,1]
					Loop
				EndIf
				
				VOK->(dbSeek( xFilial("VOK") + oGetResVO4:aCols[nCntFor, RVO4TIPSER] ))
				
				// Servico de Mao de Obra Gratuita ...
				If VOK->VOK_INCMOB == "0"
					Loop
				EndIf
				
				cItemPed := Soma1( cItemPed , Len(cItemPed) )
				
				SB1->(dbSetOrder(7))
				SB1->(MsSeek(xFilial("SB1") + VOK->VOK_GRUITE + VOK->VOK_CODITE ))
				
				If lVOOVLBRNF .and. M->VOO_VLBRNF == "0" // Nao passar o Valor Bruto para NF/Loja
					n_VALBRU := oGetResVO4:aCols[nCntFor,RVO4VALBRU] - oGetResVO4:aCols[nCntFor,RVO4VALDES]
					n_PERDES := 0
					n_VALDES := 0
				Else // Passar Valor Bruto e Desconto para NF/Loja
					n_VALBRU := oGetResVO4:aCols[nCntFor,RVO4VALBRU]
					n_PERDES := oGetResVO4:aCols[nCntFor,RVO4PERDES]
					n_VALDES := oGetResVO4:aCols[nCntFor,RVO4VALDES]
				EndIf
				
				/////////////////////////////////////////////////////////////////////
				// Atualizar SB0 - Precos por Produto - Tabela OBRIGATORIA no Loja //
				/////////////////////////////////////////////////////////////////////
				If !lMVLJCNVDA // Quando o parametro MV_LJCNVDA for .T. o LOJA utilizara a tabela de preco da totvs (DA0)
					SB0->(DbSetOrder(1))
					SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD))
					dbSelectArea("SB0")
					RecLock("SB0",!SB0->(Found()))
					SB0->B0_FILIAL := xFilial("SB0")
					SB0->B0_COD    := SB1->B1_COD
					&("SB0->B0_PRV"+cMVTABPAD) := n_VALBRU
					MsUnLock()
					dbSelectArea("SB1")
				EndIf
				//
				
				Aadd(aIte,Array(17))
				aIte[Len(aIte),01] := { "LR_FILIAL"   , xFilial("SL2")                                      , NIL }
				aIte[Len(aIte),02] := { "LR_PRODUTO"  , SB1->B1_COD                                         , NIL }
				aIte[Len(aIte),03] := { "LR_LOCAL"    , VOI->VOI_CODALM                                     , NIL }
				aIte[Len(aIte),04] := { "LR_LOCALIZ"  , If(Localiza(SB1->B1_COD),VOI->VOI_LOCALI,Space(15)) , NIL }
				aIte[Len(aIte),05] := { "LR_TABELA"   , IIf( lMVLJCNVDA , "1" , cMVTABPAD )                 , NIL }
				aIte[Len(aIte),06] := { "LR_ITEM"     , cItemPed                                            , NIL }
				aIte[Len(aIte),07] := { "LR_QUANT"    , 1                                                   , NIL }
				aIte[Len(aIte),08] := { "LR_UM"       , SB1->B1_UM                                          , NIL }
				aIte[Len(aIte),09] := { "LR_VRUNIT"   , n_VALBRU                                            , NIL }
				aIte[Len(aIte),10] := { "LR_DESC"     , n_PERDES                                            , NIL }
				aIte[Len(aIte),11] := { "LR_VALDESC"  , n_VALDES                                            , NIL }
				aIte[Len(aIte),12] := { "LR_TES"      , oGetResVO4:aCols[nCntFor,RVO4CODTES]                , NIL }
				aIte[Len(aIte),13] := { "LR_DOC"      , ""                                                  , NIL }
				aIte[Len(aIte),14] := { "LR_SERIE"    , ""                                                  , NIL }
				aIte[Len(aIte),15] := { "LR_PDV"      , "0001"                                              , NIL }
				aIte[Len(aIte),16] := { "LR_PRCTAB"   , n_VALBRU                                            , NIL }
				aIte[Len(aIte),17] := { "LR_DESCPRO"  , 0                                                   , NIL }
				
				// Adiciona na Matriz de Relacionamento do oGetDetVO3:aCols/oGetResVO4:aCols com o SC6,
				// utilizado depois para gerar VEC e VSC ...
				AADD( aRelFatOfi, { "VO4" , nCntFor , cItemPed , "" } )
				//
				
			Next
		EndIf
		
		SB1->(dbSetOrder(1))
		
		If Len(aIte) > 0 .and. ( !lLJPRDSV  .or. (lLJPRDSV .and. nCntTipTem == Len(aTipTem)))
			
			// Pagamento
			aPagPV := {}
			//
			
			nAuxTot := 0
			nTotalFec := 0
			nBkpN := n
			// Calcula o total do tipo de tempo ...
			For nCntFor := 1 to Len(oGetDetVO3:aCols)
				If oGetDetVO3:aCols[nCntFor,DVO3TIPTEM] $ cTipTemOrc //  == aTipTem[nCntTipTem,1]
					// Procura valor total do Fiscal ...
					OX100PECFIS( nCntFor )
					nAuxTot += MaFisRet(n,"IT_TOTAL")
					//
				EndIf
			Next nCntFor
			For nCntFor := 1 to Len(oGetResVO4:aCols)
				If oGetResVO4:aCols[nCntFor,RVO4TIPTEM] $ cTipTemOrc  // == aTipTem[nCntTipTem,1]
					// Procura valor total do Fiscal ...
					OX100SRVFIS( nCntFor )
					nAuxTot += MaFisRet(n,"IT_TOTAL")
					//
				EndIf
			Next nCntFor
			//
			n := nBkpN
			nPerc := nAuxTot / nTotNFiscal
			/////////////////////////////////
			// Gerar Pedido/Venda no Loja  //
			/////////////////////////////////
			for nCntFor := 1 to Len(oGetVS9:aCols)
				if !oGetVS9:aCols[nCntFor,len(oGetVS9:aCols[nCntFor])] .and. !Empty(oGetVS9:aCols[nCntFor, PVS9TIPPAG ])
					
					If lFormaID
						cFormaID := oGetVS9:aCols[ nCntFor, PVS9FORMID ]
					EndIf

					nTotalFec += A410Arred( oGetVS9:aCols[nCntFor, PVS9VALPAG ] * nPerc , "L4_VALOR" )
					
					Aadd(aPagPV,Array(6))
					aPagPV[Len(aPagPV),01] := {"L4_DATA"  , oGetVS9:aCols[nCntFor, PVS9DATPAG ]                                   , NIL}
					aPagPV[Len(aPagPV),02] := {"L4_VALOR" , A410Arred( oGetVS9:aCols[nCntFor, PVS9VALPAG ] * nPerc , "L4_VALOR" ) , NIL}
					aPagPV[Len(aPagPV),03] := {"L4_FORMA" , oGetVS9:aCols[nCntFor, PVS9TIPPAG ]                                   , NIL}
					aPagPV[Len(aPagPV),04] := {"L4_ADMINIS" , " "                                                                 , NIL}
					aPagPV[Len(aPagPV),05] := {"L4_FORMAID" , cFormaID                                                            , NIL}
					aPagPV[Len(aPagPV),06] := {"L4_MOEDA" , 0                                                                     , NIL}
				endif
			next
			//
			
			// Acerta diferenca ...
			If nAuxTot > nTotalFec
				aPagPV[1,2,2] += nAuxTot - nTotalFec
			ElseIf nAuxTot < nTotalFec
				aPagPV[Len(aPagPV),2,2] += nAuxTot - nTotalFec
			EndIf
			//
			
			If ExistBlock("OX100AOR")
				ExecBlock("OX100AOR",.f.,.f.)
			Endif
			
			// Salva a Situacao atual do Fiscal
			MaFisSave()
			MaFisEnd()
			//
			
			lMsErroAuto := .f.
			////////////////////////////////////////////////
			// Salvar FUNNAME                             //
			////////////////////////////////////////////////
			cSFunName := FunName()
			nSModulo  := nModulo
			
			cBkpUserName := cUserName // Armazena o usuario logado atualmente
			////////////////////////////////////////////////
			// Mudar Usuario para Usuario do Caixa        //
			////////////////////////////////////////////////
			cUserName := ALlTrim(GetNewPar("MV_MIL0019",cUserName))
			
			////////////////////////////////////////////////
			// Mudar para Modulo 12 - Siga Loja           //
			////////////////////////////////////////////////
			nModulo := 12
			////////////////////////////////////////////////
			// Setar FunName LOJA701, para chamar LOJA701 //
			////////////////////////////////////////////////
			SetFunName("LOJA701")
			MSExecAuto({|a,b,c,d,e,f,g,h| LOJA701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aCabPV,aIte,aPagPV)
			
			cUserName := cBkpUserName // Volta o usuario logado ...
			
			////////////////////////////////////////////////
			// Voltar FunName salvo                       //
			////////////////////////////////////////////////
			SetFunName(cSFunName)
			////////////////////////////////////////////////
			// Voltar Modulo                              //
			////////////////////////////////////////////////
			nModulo := nSModulo
			
			// Restaura o Fiscal
			MaFisEnd()
			MaFisRestore()
			//
			
			If lMsErroAuto
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				MostraErro()
				Return(.f.)
			EndIf
			
			cOrcLoja := SL1->L1_NUM
			
			If Empty(cOrcLoja)
				MsgStop(STR0117,STR0004) //  "Problema ao gerar or็amento no loja"
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				Return(.f.)
			EndIf
			
			//aTipTem[ nCntTipTem, 12 ] := cOrcLoja
			aEval(aTipTem , { |x| IIf( x[1] $ cTipTemOrc , x[12] := cOrcLoja , ) } )
			
		EndIf
		
	Next nCntTipTem
	
EndIf

lMSHelpAuto := .f.

For nCntTipTem := 1 to Len(aTipTem)
	
	If lNF
		AADD( aInfNF , { (aTipTem[nCntTipTem,5]) , ;  // Serie da NF
		(aTipTem[nCntTipTem,6]) , ;  // Numero da NF
		(AllTrim(RetTitle("VOI_TIPTEM")) + "-" + aTipTem[nCntTipTem,1]) } )  // Tipo de Tempo
	Else
		AADD( aInfNF , { (aTipTem[nCntTipTem, FTT_ORCLOJA ]) , ;  // Numero do Orcamento
		(AllTrim(RetTitle("VOI_TIPTEM")) + "-" + aTipTem[nCntTipTem,1]) } )  // Tipo de Tempo
	EndIf
	
	For nCntFor := 1 to Len(aVetTTP)
		
		// Nao tiver sido selecionado no fechamento ...
		If !aVetTTP[nCntFor,ATT_VETSEL]
			Loop
		EndIf
		//
		
		// Se nao for do mesmo tipo de tempo
		If aVetTTP[nCntFor,ATT_TIPTEM] <> aTipTem[nCntTipTem,1]
			Loop
		EndIf
		//
		
		// Verifica se existe Peca / Servico no Fechamento ...
		lFecPeca := ( aScan( oGetDetVO3:aCols , { |x| x[DVO3TIPTEM] == aTipTem[nCntTipTem,1] .and. !Empty(x[DVO3CODITE]) } ) <> 0 )
		lFecSrvc := ( aScan( oGetDetVO4:aCols , { |x| x[DVO4TIPTEM] == aTipTem[nCntTipTem,1] .and. !Empty(x[DVO4CODSER]) } ) <> 0 )
		//
		
		cSerie   := aTipTem[nCntTipTem, FTT_SERNFI  ]
		cNota    := aTipTem[nCntTipTem, FTT_NUMNFI  ]
		cOrcLoja := aTipTem[nCntTipTem, FTT_ORCLOJA ]
		cNumPed  := aTipTem[nCntTipTem, FTT_PEDFAT  ]
		lNFSrvc  := aTipTem[nCntTipTem, FTT_NFSRVC  ]
		
		// Posiciona alguns arquivos ...
		VO1->(dbSetOrder(1) )
		VO1->(MsSeek(xFilial("VO1") + aVetTTP[nCntFor,ATT_NUMOSV] ) )
		
		VV1->(dbSetOrder(1))
		VV1->(MsSeek(xFilial("VV1") + aVetTTP[nCntFor,ATT_CHAINT]))
		
		VOI->(dbSetOrder(1))
		VOI->(MsSeek(xFilial("VOI") + aVetTTP[nCntFor,ATT_TIPTEM]))
		//
		
		//  Atualiza Orcamentos...
		If lFecPeca
			If !OX100ATORC( "P" , aVetTTP[nCntFor,ATT_TIPTEM] , aVetTTP[nCntFor,ATT_NUMOSV] , cNota , cSerie )
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				HELP(" ",1,"REGNLOCK",,"VS1 - PECA",4,1)
				Return(.f.)
			EndIf
		EndIf
		If lFecSrvc
			If !OX100ATORC( "S" , aVetTTP[nCntFor,ATT_TIPTEM] , aVetTTP[nCntFor,ATT_NUMOSV] , cNota , cSerie )
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				HELP(" ",1,"REGNLOCK",,"VS1 - SERVICO",4,1)
				Return(.f.)
			EndIf
		EndIf
		//
		
		// Atualiza Arquivo de Numero de Notas Fiscais - VOO
		DbSelectArea("VOO")
		dbSetOrder(1)
		VOO->(dbSeek( xFilial("VOO") + aVetTTP[nCntFor,ATT_NUMOSV] + aVetTTP[nCntFor,ATT_TIPTEM] + aVetTTP[nCntFor,ATT_LIBVOO]) )
		If !RecLock("VOO",.f.)
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			HELP(" ",1,"REGNLOCK",,"VOO - OX100PFECH",4,1)
			Return(.f.)
		EndIf
		VOO->VOO_NUMNFI := cNota
		VOO->VOO_SERNFI := cSerie
		VOO->VOO_PESQLJ := cOrcLoja
		If lFecPeca         // Fechamento de Peca
			nAuxTot := 0
			AEval(aAuxVO3 , {|x| nAuxTot += IIF( ( x[AP_NUMOSV] == aVetTTP[nCntFor,ATT_NUMOSV] .and. x[AP_TIPTEM] == aVetTTP[nCntFor,ATT_TIPTEM] .and. x[AP_LIBVOO] == aVetTTP[nCntFor,ATT_LIBVOO] ) , x[AP_ITTOTFISC] , 0 ) } )
			VOO->VOO_TOTPEC := nAuxTot
		EndIf
		If lFecSrvc         // Fechamento de Servico
			nAuxTot := 0
			AEval(aAuxVO4 , {|x| nAuxTot += IIF( ( x[AS_NUMOSV] == aVetTTP[nCntFor,ATT_NUMOSV] .and. x[AS_TIPTEM] == aVetTTP[nCntFor,ATT_TIPTEM] .and. x[AS_LIBVOO] == aVetTTP[nCntFor,ATT_LIBVOO] ), x[AS_ITTOTFISC] , 0 ) } )
			VOO->VOO_TOTSRV := nAuxTot
		EndIf
		VOO->(MsUnlock())
		
		// Atualiza matriz do Tipo de Tempo, utilizado para gerar CEV no Final ...
		aVetTTP[nCntFor, ATT_NUMNFI ] := cNota
		aVetTTP[nCntFor, ATT_SERNFI ] := cSerie
		aVetTTP[nCntFor, ATT_ORCLOJA] := cOrcLoja
		//
		
		// Atualiza Requisicao de Pecas ...
		cSQL := "SELECT VO3.R_E_C_N_O_ NRECNO "
		cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' '"
		cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
		cSQL +=   " AND VO2.VO2_NUMOSV = '" + aVetTTP[nCntFor,ATT_NUMOSV] + "'"
		cSQL +=   " AND VO2.VO2_TIPREQ = 'P'" // Requisicao de Pecas
		cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
		cSQL +=   " AND VO3.VO3_TIPTEM = '" + aVetTTP[nCntFor,ATT_TIPTEM] + "'"
		cSQL +=   " AND VO3.VO3_LIBVOO = '" + aVetTTP[nCntFor,ATT_LIBVOO] + "'"
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVO3 , .F., .T. )
		DbSelectArea("VO3")
		While !(cAliasVO3)->(Eof())
			VO3->(dbGoTo((cAliasVO3)->NRECNO))
			If !RecLock("VO3",.f.)
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				HELP(" ",1,"REGNLOCK",,"VO3 - OX100PFECH",4,1)
				Return(.f.)
			EndIf
			VO3->VO3_NUMNFI := cNota
			VO3->VO3_SERNFI := cSerie
			VO3->VO3_DATFEC := dDatFec
			VO3->VO3_HORFEC := nHorFec
			VO3->VO3_FUNFEC := VAI->VAI_CODTEC
			cTesNegoc := FM_SQL("SELECT VZ1_CODTES FROM " + RetSQLName("VZ1") + " VZ1 WHERE VZ1.VZ1_FILIAL = '" + xFilial("VZ1") + "' AND VZ1.VZ1_NUMOSV = '" + aVetTTP[nCntFor,02] + "' AND VZ1.VZ1_PECSER = 'P' AND VZ1.VZ1_GRUITE = '" + VO3->VO3_GRUITE + "' AND VZ1.VZ1_CODITE = '" + VO3->VO3_CODITE + "' AND VZ1.D_E_L_E_T_ = ' '")
			if !Empty(cTesNegoc)
				VO3->VO3_CODTES := cTesNegoc
			endif
			VO3->(MsUnlock())
			
			// Posiciona no mesmo RECNO para o TOP gravar os dados no banco ...
			VO3->(dbGoTo( VO3->(Recno()) ))
			//
			
			// Atualiza Ocorrencias do veiculo - VFB
			If !OX100VFB( "P" , VV1->VV1_PROATU , VV1->VV1_LJPATU , VV1->VV1_CHAINT , VO3->VO3_TIPTEM , VO3->VO3_NUMOSV , VO3_GRUITE , VO3_CODITE )
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				Help(" ",1,"REGNLOCK",,"VFB - PECA",4,1)
				Return(.f.)
			EndIf
			//
			
			(cAliasVO3)->(dbSkip())
			
		End
		(cAliasVO3)->(dbCloseArea())
		dbSelectArea("VO3")
		//
		
		// Atualiza Requisicao de Servicos ...
		For nCntVO4 := 1 to Len(aAuxVO4)
			// Se o Numero da OS for Diferente OU Tipo de Tempo for Diferente ...
			If aAuxVO4[nCntVO4,AS_NUMOSV] <> aVetTTP[nCntFor,ATT_NUMOSV] .or. aAuxVO4[nCntVO4,AS_TIPTEM] <> aVetTTP[nCntFor,ATT_TIPTEM] .or. aAuxVO4[nCntVO4,AS_LIBVOO] <> aVetTTP[nCntFor,ATT_LIBVOO]
				Loop
			EndIf
			//
			
			aSort(aAuxVO4[nCntVO4,AS_APONTA] , 1 , , { |x,y| x[AS_APONTA_PERCEN] <= y[AS_APONTA_PERCEN] } )
			
			// Valor Interno do Servico
			If VOI->VOI_SITTPO == "3"
				nVlrInt := aAuxVO4[nCntVO4,AS_VALBRU] - aAuxVO4[nCntVO4,AS_VALDES]
			EndIf
			//
			
			If lVSCITENFI
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Procura a Posicao da GetDados que contem os dados do Fechamento ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nPosGet := aScan( oGetResVO4:aCols, { |x| x[RVO4TIPTEM] == aAuxVO4[nCntVO4,AS_TIPTEM] .and. x[RVO4TIPSER] == aAuxVO4[nCntVO4,AS_TIPSER] } )
				If nPosGet == 0
					Help(" ",1,"OX100GDMA",,STR0047+chr(13)+chr(10)+"OX100VSC",4,1)
					Loop
				EndIf
				//
				
				// Descobre a linha na Matriz Auxiliar para pegar o Item do Pedido de Venda a qual se refere o produto ...
				nPosRel := aScan( aRelFatOfi , { |x| x[1] == "VO4" .and. x[2] == nPosGet } )
				//
			EndIf
			
			nAuxVlrInt := 0
			nVO4TEMCOB := 0
			
			// Percorre todos os Registros de VO4 (Apontamento)
			For nCntVO4Apo := 1 to Len(aAuxVO4[nCntVO4,AS_APONTA])
				
				VO4->(dbGoTo( aAuxVO4[nCntVO4,AS_APONTA,nCntVO4Apo,AS_APONTA_RECNO] ))
				If !RecLock("VO4",.f.)
					DisarmTransaction()
					RollbackSx8()
					MsUnlockAll()
					HELP(" ",1,"REGNLOCK",,"VO4 - OX100PFECH",4,1)
					Return(.f.)
				EndIf
				
				// Gera NF de Servico ...
				If lNFSrvc
					VO4->VO4_NUMNFI := cNota
					VO4->VO4_SERNFI := cSerie
				Endif
				//
				
				// Tipo de Tempo Interno
				If VOI->VOI_SITTPO == "3"
					If aAuxVO4[nCntVO4,AS_INCMOB] $ "1/3/4" // INCMOB - 1=Mao-de-Obra / 3=Vlr Livre c Base na Tabela / 4=Retorno de Srv
						// Multiplica o Valor Interno pelo Percentual do Apontamento em relacao ao total de horas trabalhadas no servico
						VO4->VO4_VALINT := A410Arred( nVlrInt * aAuxVO4[nCntVO4,AS_APONTA,nCntVO4Apo,AS_APONTA_PERCEN] , "VO4_VALINT" )
						//
						
						nAuxVlrInt += VO4->VO4_VALINT // Utilizado para garantir que sera rateado corretamente
						
						// Verifica se teve problema de arredondamento
						If nCntVO4Apo == Len(aAuxVO4[nCntVO4,AS_APONTA])
							If nAuxVlrInt <> nVlrInt
								VO4->VO4_VALINT += nVlrInt - nAuxVlrInt
							EndIf
						EndIf
						//
						
					ElseIf aAuxVO4[nCntVO4,AS_INCMOB] == "2"  // INCMOB - 2=Servicos de Terceiros
						VO4->VO4_VALINT := VO4->VO4_VALCUS
						
					ElseIf aAuxVO4[nCntVO4,AS_INCMOB] == "5"  // INCMOB - 5=Km Socorro
						VO4->VO4_VALINT := A410Arred( ( aAuxVO4[nCntVO4,AS_VALBRU] - aAuxVO4[nCntVO4,AS_VALDES] ), "VO4_VALINT" )
						
					EndIf
					
				EndIf
				//
				
				VO4->VO4_DATFEC := dDatFec
				VO4->VO4_HORFEC := nHorFec
				VO4->VO4_FUNFEC := VAI->VAI_CODTEC
				
				Do Case
					// Tempo para Calculo - 1=Fabrica / 2=Concessionaria / 4=Informado
					Case aAuxVO4[nCntVO4,AS_INCTEM] $ "124"
						VO4->VO4_TEMVEN := aAuxVO4[nCntVO4,AS_TEMPAD]
						VO4->VO4_TEMCOB := Round(aAuxVO4[nCntVO4,AS_APONTA,nCntVO4Apo,AS_APONTA_PERCEN] * aAuxVO4[nCntVO4,AS_TEMCOB] , 0 )
						
						nVO4TEMCOB += VO4->VO4_TEMCOB
						
						// Verifica se teve problema de arredondamento
						If nCntVO4Apo == Len(aAuxVO4[nCntVO4,AS_APONTA])
							If nVO4TEMCOB <> aAuxVO4[nCntVO4,AS_TEMCOB]
								VO4->VO4_TEMCOB += aAuxVO4[nCntVO4,AS_TEMCOB] - nVO4TEMCOB
							EndIf
						EndIf
						//
						
						// Tempo para Calculo - 3=Trabalhado
					Case aAuxVO4[nCntVO4,AS_INCTEM] == "3"
						VO4->VO4_TEMVEN := aAuxVO4[nCntVO4,AS_APONTA,nCntVO4Apo,AS_APONTA_TEMTRA]
						VO4->VO4_TEMCOB := aAuxVO4[nCntVO4,AS_APONTA,nCntVO4Apo,AS_APONTA_TEMTRA]
						
				EndCase
				
				If lVSCITENFI
					VO4->VO4_PEDNUM := IIf(lCupom,cOrcLoja,cNumPed)
					VO4->VO4_PEDITE := IIf( nPosRel <> 0 , aRelFatOfi[nPosRel,3] , "" )
				EndIf
				
				VO4->(MsUnlock())
				
			Next nCntVO4Apo
			//
			
			// Posiciona no mesmo RECNO para o TOP gravar os dados no banco ...
			VO4->(dbGoTo( VO4->(Recno()) ))
			
			// Atualiza Habilidade do Produtivo ...
			If !Empty(VO4->VO4_CODPRO)
				
				VOC->(dbSetOrder(1))
				If VOC->(dbSeek( xFilial("VOC") + VO4->VO4_CODPRO + VV1->VV1_CODMAR + VO4->VO4_CODSER ))
					dbSelectArea("VOC")
					If !RecLock("VOC",.f.)
						DisarmTransaction()
						RollbackSx8()
						MsUnlockAll()
						HELP(" ",1,"REGNLOCK",,"VOC - OX100PFECH",4,1)
						Return(.f.)
					EndIf
					VOC->VOC_QTDEXE := VOC->VOC_QTDEXE + 1
					MsUnlock()
				EndIf
			EndIf
			//
			
			// Atualiza Ocorrencias do veiculo - VFB
			If !OX100VFB( "S" , VV1->VV1_PROATU , VV1->VV1_LJPATU , VV1->VV1_CHAINT , VO4->VO4_TIPTEM , VO4->VO4_NUMOSV, VO4->VO4_GRUSER , VO4->VO4_CODSER )
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				HELP(" ",1,"REGNLOCK",,"VFB - SERVICO",4,1)
				Return(.f.)
			EndIf
			//
			
		Next nCntVO4
		//
		
		// Gera Avaliacao de Venda de Pecas ...
		IncProc(STR0063) // "Gerando Avaliacao de Peca"
		If !OX100VEC( aVetTTP[nCntFor,ATT_NUMOSV], aVetTTP[nCntFor,ATT_TIPTEM], lNF, lCupom, cNota, cSerie, aRelFatOfi, aVetTTP[nCntFor,ATT_LIBVOO], IIf(lCupom,cOrcLoja,cNumPed) )
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			HELP(" ",1,"REGNLOCK",,"VEC - OX100PFECH",4,1)
			Return .f.
		EndIf
		//
		
		// Gera Avaliacao de Venda de Servicos ...
		IncProc(STR0064) // "Gerando Avaliacao de Servicos"
		If !OX100VSC( aVetTTP[nCntFor,ATT_NUMOSV], aVetTTP[nCntFor,ATT_TIPTEM], lNF, lCupom, cNota, cSerie, aRelFatOfi, aVetTTP[nCntFor,ATT_LIBVOO], IIf(lCupom,cOrcLoja,cNumPed), lNFSrvc )
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			Return .f.
		EndIf
		//
		
		// Cria movimentacao de movimentacao de despesa de veiculo (CONTABIL)
		If !OX100DVEICON( aVetTTP[nCntFor,ATT_NUMOSV], aVetTTP[nCntFor,ATT_TIPTEM], aVetTTP[nCntFor,ATT_LIBVOO], VV1->VV1_CHAINT )
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			Return .f.
		EndIf
		//
		
		// Atualizando Ordem de Servico ...
		If !RecLock("VO1",.f.)
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			HELP(" ",1,"REGNLOCK",,"VO1 - OX100PFECH",4,1)
			Return .f.
		EndIf
		VO1->VO1_TEMFEC := "S"
		VO1->VO1_TEMLIB := IIF( FMX_TEMLIB( VO1->VO1_NUMOSV ) , "S" , "N" )
		VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV," ")
		// Registra Saida dos Veiculos ...
		If lRegSaida .and. Empty(VO1->VO1_DATSAI)
			VO1->VO1_DATSAI := dDatFec
			VO1->VO1_HORSAI := nHorFec
		EndIf
		//
		MsUnlock()
		
		// tratamento de controle de status de veiculos soh se estiver abrindo OS para um veiculo que esta no estoque
		If VO1->VO1_STATUS == "F" // somente para fechamento total da OS
			VV1->(DbsetOrder(1))
			VV1->(Dbseek(xFilial("VV1")+VO1->VO1_CHAINT))
			If FG_STATUS(,"X") .and. VV1->VV1_SITVEI $ "0 "
				FG_STATUS(VO1->VO1_CHAINT,"O")
			Endif
			
			// Finaliza Agendamento
			OX100FAGEN(VO1->VO1_NUMOSV)
			//
		Endif
		
		VO1->(dbGoTo( VO1->(Recno()) ))
		// Tratamento de Garantia ...
		If !OX100IMPGA( aVetTTP[nCntFor,ATT_NUMOSV] , aVetTTP[nCntFor,ATT_TIPTEM] , aVetTTP[nCntFor,ATT_LIBVOO] )
			DisarmTransaction()
			MsUnlockAll()
			Return .f.
		EndIf
		
		// Gera Relacionamento do Oficina com o SIGALOJA
		If lCupom
			dbSelectArea("VFE")
			RecLock("VFE",.t.)
			VFE->VFE_FILIAL := xFilial("VFE")
			VFE->VFE_NUMORC := aTipTem[nCntTipTem,12]
			VFE->VFE_NUMOSV := aVetTTP[nCntFor,ATT_NUMOSV]
			VFE->VFE_TIPTEM := aVetTTP[nCntFor,ATT_TIPTEM]
			VFE->VFE_LIBVOO := aVetTTP[nCntFor,ATT_LIBVOO]
			MsUnlock()
			//
		EndIf
		//
		
		If cMVMIL0006 == "SCA" .AND. FindFunction("OFINSC01")
			OFSC01(.f.,.t.,aVetTTP[nCntFor,ATT_NUMOSV] , aVetTTP[nCntFor,ATT_TIPTEM] , aVetTTP[nCntFor,ATT_LIBVOO])//lEnd, lAuto, cTipTem, cLibVOO
		EndIf
		
	Next nCntFor
	
Next nCntTipTem
//

// ANTIGO - Compatibilizacao com o OFIOM160, para novas implantacoes utilizar outro PE
If ExistBlock("O160DPGR")   // Ponto de Entrada Depois das Gravacoes
	ExecBlock("O160DPGR",.f.,.f.)
EndIf
If ExistBlock("OX100DGR")   // Deve ser utilizado este ponto de entrada
	ExecBlock("OX100DGR",.f.,.f.)
Endif
//

End Transaction

// Por algum motivo o cliente permanece bloqueado
SA1->(MsUnLock())
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX6")
MsRUnLock()
//

If cPaisLoc == "BRA" // Luis - 30/09/2009
	// ANTIGO - Compatibilizacao com o OFIOM160, para novas implantacoes utilizar outro PE
	If ExistBlock("O160DPTR")   // Ponto de Entrada Depois da Transacao
		ExecBlock("O160DPTR",.f.,.f.)
	EndIf
	If ExistBlock("OX100DTR") // Deve ser utilizado este ponto de entrada
		ExecBlock("OX100DTR",.f.,.f.)
	Endif
	//
Endif

// Abre Dialog com o Numero da Nota Fiscal / Orcamento Gerado ...
If lNF .and. !Empty(cNota)
	aSort( aInfNF ,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] })
	FMX_TELAINF( "1", aInfNF )
EndIf
If lCupom .and. !Empty(cOrcLoja)
	aSort( aInfNF ,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
	FMX_TELAINF( "3", aInfNF )
EndIf
//

For nCntTipTem := 1 to Len(aTipTem)
	
	// Posiciona na primeira linha jแ marcada
	nPosSel := AScan( aVetTTP , { |x| x[ATT_TIPTEM] == aTipTem[nCntTipTem,1] .and. x[ATT_VETSEL] == .t. } )
	
	// Gera CEV quando for fechamento de TT diferente de Interno ...
	// Agenda Contato - Satisfacao do Cliente
	VOI->(dbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + aVetTTP[nPosSel,ATT_TIPTEM] ))
	If lVCM510CEV
		aCEV := VCM510CEV("6","",VOI->VOI_SITTPO,IIf(lFecAgru," ",aVetTTP[nPosSel, ATT_NUMOSV ])) // 6 = Venda Servicos
	Else // Temporario
		cGCFOCEV := Alltrim(GetNewPar("MV_GCFOCEV",""))
		If !Empty(cGCFOCEV)
			aCEV := {{substr(cGCFOCEV,1,1),Val(substr(cGCFOCEV,2,3)),substr(cGCFOCEV,5,6),Val(substr(cGCFOCEV,11,3))}}
		EndIf
	EndIf
	
	For ni := 1 to len(aCEV)
		If Empty(aCEV[ni,3])
			aCEV[ni,3] := aVetTTP[nPosSel, ATT_CODVEN ] // Vendedor ( VAI->VAI_CODVEN )
		EndIf
		cGCFOCEV := "X"
		////////////////////////////////////////////////////////////////////////////////////////
		// CEV - Verificar se ja existe Agenda CEV para esta OS/Cliente                       //
		////////////////////////////////////////////////////////////////////////////////////////
		cSQL := "SELECT VC1.R_E_C_N_O_ AS RECVC1 FROM "+RetSQLName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
		cSQL += "VC1.VC1_TIPAGE='"+aCEV[ni,1]+"' AND "
		cSQL += "VC1.VC1_CODCLI='"+aVetTTP[nPosSel, ATT_CLIENTE ]+"' AND VC1.VC1_LOJA='"+aVetTTP[nPosSel, ATT_LOJA ]+"' AND "
		cSQL += "VC1.VC1_CODVEN='"+aCEV[ni,3]+"' AND "
		cSQL += "VC1.VC1_TIPORI='O' AND VC1.VC1_ORIGEM='"+IIf(lFecAgru," ",aVetTTP[nPosSel, ATT_NUMOSV ])+"' AND VC1.D_E_L_E_T_=' '"
		If FM_SQL(cSQL) > 0
			cGCFOCEV := "" // Nao Gerar Agenda na Finalizacao quando ja existe Agenda para a OS/Cliente
		Else
			If aCEV[ni,4] > 0 // Qtde minima de dias necessaria para criar nova Agenda
				/////////////////////////////////////////////////////////////////////////////////////////////
				// CEV - Verificar se ja existe Agenda CEV para este Cliente dentro da Qtde minima de dias //
				/////////////////////////////////////////////////////////////////////////////////////////////
				cSQL := "SELECT VC1.R_E_C_N_O_ AS RECVC1 FROM "+RetSQLName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
				cSQL += "VC1.VC1_TIPAGE='"+aCEV[ni,1]+"' AND "
				cSQL += "VC1.VC1_CODCLI='"+aVetTTP[nPosSel, ATT_CLIENTE ]+"' AND VC1.VC1_LOJA='"+aVetTTP[nPosSel, ATT_LOJA ]+"' AND "
				cSQL += "VC1.VC1_CODVEN='"+aCEV[ni,3]+"' AND "
				cSQL += "VC1.VC1_TIPORI='O' AND VC1.VC1_DATAGE>='"+dtos(dDataBase-aCEV[ni,4])+"' AND VC1.D_E_L_E_T_=' '"
				If FM_SQL(cSQL) > 0
					cGCFOCEV := "" // Nao Gerar Agenda na Finalizacao quando ja existe Agenda dentro da qtde minima de dias
				EndIf
			EndIf
		EndIf
		///////////////////////////////////////
		// GERAR CEV no FATURAMENTO          //
		///////////////////////////////////////
		If !Empty( cGCFOCEV )
			cObsCEV := STR0021+" "+IIf(lFecAgru,STR0022,aVetTTP[nPosSel, ATT_NUMOSV ])+" " // OS # Agrupada
			cObsCEV += IIf(VOI->VOI_SITTPO#"1",IIf(VOI->VOI_SITTPO=="2",STR0023,STR0024),"")+" " // Garantia # Revisao
			cSQL := "SELECT SA3.A3_NOME "
			cSQL += " FROM " + RetSQLName("SA3")+" SA3 "
			cSQL += " WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"'"
			cSQL += " AND SA3.A3_COD='"+aVetTTP[nPosSel, ATT_CODVEN ]+"'"
			cSQL += " AND SA3.D_E_L_E_T_=' '"
			cObsCEV += STR0025+": "+aVetTTP[nPosSel, ATT_NUMNFI ]+"-"+aVetTTP[nPosSel, ATT_SERNFI ] // FINALIZADA - NF
			cObsCEV += STR0078+": "+aVetTTP[nPosSel, ATT_CODVEN ]+" "+left(FM_SQL(cSQL),20) // Vendedor
			////////////////////////////////////
			// CEV - Geracao de Agenda        //
			////////////////////////////////////
			FS_AGENDA( aCEV[ni,1] , ;
			( dDataBase + aCEV[ni,2] ) , ;
			aCEV[ni,3] , ;
			aVetTTP[nPosSel, ATT_CLIENTE ] ,; // VOO->VOO_FATPAR
			aVetTTP[nPosSel, ATT_LOJA ] ,; // VOO->VOO_LOJA
			"" ,;
			IIf(lFecAgru,"",aVetTTP[nPosSel, ATT_NUMOSV ]) ,;
			"" ,;
			cObsCEV ,;
			"" ,;
			"" )
		EndIf
	Next
	
Next nCntTipTem

// IMPRESSAO DAS NOTAS FISCAIS E BOLETOS BANCARIOS ...
For nCntTipTem := 1 to Len(aTipTem)
	OX100IMPDOC( aTipTem[nCntTipTem,06] , aTipTem[nCntTipTem,05] , aTipTem[nCntTipTem,01] , aTipTem[nCntTipTem,11] )
Next nCntTipTem
//

Return .t.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VS9E1 บAutor  ณ Takahashi          บ Data ณ  16/03/12 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Acerta os titulos no financeiro no momento da geracao dos  บฑฑ
ฑฑบ          ณ mesmos atraves da rotina MAPVLNFS                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nRecSE1    - RECNO da tabela SE1                           บฑฑ
ฑฑบ          ณ cDMSPrefOri- Prefixo a ser gravado no campo E1_PREFORI     บฑฑ
ฑฑบ          ณ lSE4TipoA  - Indica se a condicao de pagamento ้ negociada บฑฑ
ฑฑบ          ณ lPeriodico - Indica se o cliente ้ periodico               บฑฑ
ฑฑบ          ณ cTipPer    - Tipo do Titulo quando o cliente for periodico บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออฯอออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100VS9E1(nRecSE1,cDMSPrefOri,lSE4TipoA,lPeriodico,cTipPer)

Default lSE4TipoA := .f.

nCntSE1++
SE1->( dbGoto( nRecSE1 ) )
RecLock("SE1",.f.)
SE1->E1_PREFORI := cDMSPrefOri
If AllTrim(SE1->E1_TIPO) == "NF"
	
	cE1TIPOorig := SE1->E1_TIPO
	
	If lSE4TipoA
		SE1->E1_TIPO := aVS9SE1[nCntSE1,2]
	Else
		If lPeriodico
			SE1->E1_TIPO := cTipPer
		Else
			SE1->E1_TIPO := "DP"
		EndIf
	EndIf
	
	AADD( aTitSE1, { SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + cE1TIPOorig + SE1->E1_CLIENTE + SE1->E1_LOJA , SE1->E1_TIPO} )
	
	SE1->(MsUnLock())
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100E1TITPAI บAutor  ณ Takahashi       บ Data ณ  09/05/14 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Acerta o tipo do titulo no E1_TITPAI                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aTitSE1    - Array com os titulos gerados no SE1           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100E1TITPAI(aTitSE1)

Local cAliasSE1 := "TE1TITPAI"
Local cAuxArea := GetArea()
Local nAuxPosPref := (TamSX3("E1_PREFIXO")[1] + TamSX3("E1_NUM")[1] + TamSX3("E1_PARCELA")[1]) + 1
Local nTamE1TIPO  := (TamSX3("E1_TIPO")[1])
Local nContSE1

For nContSE1 := 1 to Len(aTitSE1)
	
	cSQL := "SELECT SE1.R_E_C_N_O_ E1RECNO "
	cSQL +=  " FROM " + RetSQLName("SE1") + " SE1 "
	cSQL += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
	cSQL +=   " AND E1_TITPAI = '" + aTitSE1[nContSE1,1] + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasSE1 , .F., .T. )
	While !(cAliasSE1)->(Eof())
		SE1->(dbGoTo((cAliasSE1)->E1RECNO))
		SE1->(RecLock("SE1",.f.))
		SE1->E1_TITPAI := Stuff(SE1->E1_TITPAI,nAuxPosPref,nTamE1TIPO,PadR(aTitSE1[nContSE1,2],nTamE1TIPO))
		SE1->(MSUnlock())
		
		(cAliasSE1)->(dbSkip())
	End
	(cAliasSE1)->(dbCloseArea())
	
Next nContSE1

RestArea(cAuxArea)

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VFB   บAutor  ณ Takahashi          บ Data ณ  09/11/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza Ocorrencia do Veiculo                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipReg - Tipo do Registro                                 บฑฑ
ฑฑบ          ณ           "P" - Peca                                       บฑฑ
ฑฑบ          ณ           "S" - Servico                                    บฑฑ
ฑฑบ          ณ cCodCli - Codigo do Proprietario do Veiculo                บฑฑ
ฑฑบ          ณ cCodLoj - Loca do Proprietario do Veiculo                  บฑฑ
ฑฑบ          ณ cChaInt - Chassi Interno no Veiculo                        บฑฑ
ฑฑบ          ณ cTipTem - Tipo de Tempo                                    บฑฑ
ฑฑบ          ณ cNumOsv - Numero da Ordem de Servico                       บฑฑ
ฑฑบ          ณ cAuxGrupo  - Codigo do Grupo                               บฑฑ
ฑฑบ          ณ cAuxCodigo - Codigo da Peca/Servico                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออฯอออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100VFB(cTipReg,cCodCli,cCodLoj,cChaInt,cTipTem,cNumOsv,cAuxGrupo,cAuxCodigo)

Local cSQL := ""
Local cAliasVFB := "TVFB"
Local lRet := .t.

cSQL := "SELECT R_E_C_N_O_ NRECNO"
cSQL +=  " FROM " + RetSQLName("VFB") + " VFB"
cSQL += " WHERE VFB_FILIAL = '" + xFilial("VFB") + "'"
cSQL +=   " AND VFB_CODCLI = '" + cCodCli + "'"
cSQL +=   " AND VFB_LOJA = '" + cCodLoj + "'"
cSQL +=   " AND VFB_CHAINT = '" + cChaInt + "'"
cSQL +=   " AND VFB_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VFB_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND VFB_SERPEC = '" + cTipReg + "'"
If cTipReg == "P"
	cSQL += " AND VFB_GRUITE = '" + cAuxGrupo + "'"
	cSQL += " AND VFB_CODITE = '" + cAuxCodigo + "'"
ElseIf cTipReg = "S"
	cSQL += " AND VFB_CODSER = '" + cAuxCodigo + "'"
EndIf
cSQL +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVFB , .F., .T. )
(cAliasVFB)->(dbGoTop())
dbSelectArea("VFB")
While !(cAliasVFB)->(Eof())
	VFB->(dbGoTo( (cAliasVFB)->NRECNO ))
	If !RecLock("VFB",.f.)
		lRet := .f.
		Exit
	EndIf
	
	VFB->VFB_DATFEC := dDataBase
	
	(cAliasVFB)->(dbSkip())
End
(cAliasVFB)->(dbCloseArea())

dbSelectArea("VO1")

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100ATORC บAutor  ณ Takahashi          บ Data ณ  09/11/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza Orcamento com a Serie e Numero da Nota Fiscal     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipReg - Tipo do Registro                                 บฑฑ
ฑฑบ          ณ           "P" - Peca                                       บฑฑ
ฑฑบ          ณ           "S" - Servico                                    บฑฑ
ฑฑบ          ณ cTipTem - Tipo de Tempo                                    บฑฑ
ฑฑบ          ณ cNumOsv - Numero da Ordem de Servico                       บฑฑ
ฑฑบ          ณ cNota - Nota Fiscal Gerada                                 บฑฑ
ฑฑบ          ณ cSerie - Serie da Nota Fiscal Gerada                       บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100ATORC(cTipReg, cTipTem, cNumOsv, cNota, cSerie)

Local cSQL := ""
Local cAliasVS1 := "TVS1"
Local lRet := .t.

cSQL := "SELECT R_E_C_N_O_ NRECNO"
cSQL += " FROM " + RetSQLName("VS1") + " VS1"
cSQL += " WHERE VS1_FILIAL = '" + xFilial("VS1") + "'"
cSQL +=   " AND VS1_NUMOSV = '" + cNumOsv + "'"
// Pecas
If cTipReg == "P"
	cSQL += " AND VS1_TIPTEM = '" + cTipTem + "'"
	// Servicos
Else
	If VS1->(FieldPos("VS1_TIPTSV")) > 0
		cSQL += " AND VS1_TIPTSV = '" + cTipTem + "'"
	Else
		cSQL += " AND VS1_TIPTEM = '" + cTipTem + "'"
	EndIf
EndIf
cSQL +=   " AND VS1_NUMNFI = '" + Space(TamSX3("VS1_NUMNFI")[1]) + "'"
cSQL +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS1 , .F., .T. )
(cAliasVS1)->(dbGoTop())
dbSelectArea("VS1")
While !(cAliasVS1)->(Eof())
	VS1->(dbGoTo( (cAliasVS1)->NRECNO ))
	If !RecLock("VS1",.f.)
		lRet := .f.
		Exit
	EndIf
	
	VS1->VS1_NUMNFI := cNota
	VS1->VS1_SERNFI := cSerie
	
	(cAliasVS1)->(dbSkip())
End
(cAliasVS1)->(dbCloseArea())

dbSelectArea("VO1")

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100FAGEN บAutor  ณ Takahashi          บ Data ณ  09/11/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza Agendamento de Oficina                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv - Numero da Ordem de Servico                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100FAGEN(cNumOsv)

Local cSQL
Local cAliasVS1 := GetNextAlias()
Local oArea := GetArea()

If VS1->(FieldPos("VS1_NUMAGE")) <> 0 .and. FindFunction("OM350STATUS")
	
	cSQL := "SELECT VS1.VS1_NUMAGE "
	cSQL +=  " FROM "+RetSqlName("VS1")+" VS1 "
	cSQL += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
	cSQL +=   " AND VS1.VS1_NUMOSV = '"+cNumOsv+"'"
	cSQL +=   " AND VS1.VS1_NUMAGE <> ' '"
	cSQL +=   " AND VS1.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ),cAliasVS1, .F., .T. )
	While !( cAliasVS1 )->( Eof() )
		OM350STATUS(( cAliasVS1 )->( VS1_NUMAGE ),"1","3") // Finaliza Agendamento
		( cAliasVS1 )->( DbSkip() )
	EndDo
	( cAliasVS1 )->( dbCloseArea() )
	dbSelectArea("VS1")
	
EndIf

RestArea( oArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VEC   บAutor  ณ Takahashi          บ Data ณ  15/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Gera Registro de Avaliacao de Venda de Pecas               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100VEC(cNumOsv, cTipTem, lNF, lCupom, cNota, cSerie, aRelFatOfi, cLibVOO, cAuxPedOrc)

Local cComisCons  // Indica quem recebera comissao
Local nCntFor
Local nCntMov
Local lRetorno
Local nBkpN := n  // Salva conteudo do N atual
Local nPosGet   // Posicao da GetDados de Pecas
Local nPerc   := 1 // Percentual do Item ...
Local nPosRel := 0   // Posicao da matriz de relacionamento oGetDetVO3:aCols/oGetResVO4:aCols x SC6

Local nValPis     // Valor do PIS da Peca   ( FISCAL )
Local nValCof     // Valor do COFINS da Peca  ( FISCAL )
Local nValICM     // Valor do ICMS da Peca  ( LIVRO FISCAL )
Local nAliICM     // Aliquota do ICMS da Peca ( LIVRO FISCAL )
Local aLivroVEC   // Array contendo o Demonstrativo Fiscal do Item
Local nBaseIcm    // Valor da Base do ICMS da Peca ( FISCAL )
Local nValCMP     // Valor do ICMS Complementar da Peca  ( LIVRO FISCAL )
Local nDifal      // Valor do Diferencial de ICMS da Peca  ( LIVRO FISCAL )
Local nValIRR     // Valor IRRF
Local nValCSL     // Valor CSLL

Local aValCom

Local DVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Det")
Local DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")
Local DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3VALPEC := FG_POSVAR("VO3_VALPEC","aHVO3Det")
Local DVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Det")
Local DVO3PEDXML := FG_POSVAR("VO3_PEDXML","aHVO3Det")
Local DVO3ITEXML := FG_POSVAR("VO3_ITEXML","aHVO3Det")

Local DVO3CENCUS := FG_POSVAR("VO3_CENCUS","aHVO3Det")
Local DVO3CONTA  := FG_POSVAR("VO3_CONTA","aHVO3Det")
Local DVO3ITEMCT := FG_POSVAR("VO3_ITEMCT","aHVO3Det")
Local DVO3CLVL   := FG_POSVAR("VO3_CLVL","aHVO3Det")

Local lVECITENFI := (VEC->(FieldPos("VEC_ITENFI")) <> 0)
Local lVECDIFAL  := (VEC->(FieldPos("VEC_DIFAL" )) <> 0)
Local lVECVALCMP := (VEC->(FieldPos("VEC_VALCMP")) <> 0)
Local lVECDESACE := (VEC->(FieldPos("VEC_DESACE")) <> 0)
Local lVECICMSRT := (VEC->(FieldPos("VEC_ICMSRT")) <> 0)
Local lVECICMSST := (VEC->(FieldPos("VEC_ICMSST")) <> 0)
Local lVECVALIPI := (VEC->(FieldPos("VEC_VALIPI")) <> 0)
Local lVECDCLBST := (VEC->(FieldPos("VEC_DCLBST")) <> 0)
Local lVECCOPIST := (VEC->(FieldPos("VEC_COPIST")) <> 0)
Local lVECVALIRR := (VEC->(FieldPos("VEC_VALIRR")) <> 0)
Local lVECVALCSL := (VEC->(FieldPos("VEC_VALCSL")) <> 0)

For nCntFor := 1 to Len(aAuxVO3)
	
	If aAuxVO3[nCntFor,AP_NUMOSV] <> cNumOsv .or. aAuxVO3[nCntFor,AP_TIPTEM] <> cTipTem .or. aAuxVO3[nCntFor,AP_LIBVOO] <> cLibVOO
		Loop
	EndIf
	
	// Procura a Posicao da GetDados que contem os dados do Fechamento
	If ( nPosGet := OX100POSPECA( aAuxVO3[nCntFor,AP_SEQFEC] )) == 0
		Return .f.
	EndIf
	//
	
	VOI->(dbSetOrder(1))
	VOI->(MsSeek(xFilial("VOI") + cTipTem ))
	
	SB1->(DbSetOrder(7))
	SB1->(DbSeek(xFilial("SB1") + oGetDetVO3:aCols[nPosGet, DVO3GRUITE ] + oGetDetVO3:aCols[nPosGet, DVO3CODITE ] ))
	SB1->(DbSetOrder(1))
	
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + VOI->VOI_CODALM))
	
	// Posiciona a VZ1 da peca em questao
	OX100VZ1( aAuxVO3[nCntFor,AP_NUMOSV], ;
	aAuxVO3[nCntFor,AP_TIPTEM], ;
	aAuxVO3[nCntFor,AP_GRUITE], ;
	aAuxVO3[nCntFor,AP_CODITE], ;
	aAuxVO3[nCntFor,AP_LIBVOO], ;
	aAuxVO3[nCntFor,AP_FORMUL], ;
	oGetDetVO3:aCols[nPosGet, DVO3VALPEC ], ;
	.T. )
	//
	
	// Posiciona Fiscal ...
	//  n := aNPecaFis[ nPosGet ,2] // Set o N para a Posicao Correspondente no Fiscal
	OX100PECFIS( nPosGET )
	nValPis   := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
	nValCof   := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
	aLivroVEC := MaFisRet(n,"IT_LIVRO")
	if lVECVALCMP
		nValCmp := MaFisRet(n,"IT_VALCMP")
	Endif
	if lVECDIFAL
		nDifal  := MaFisRet(n,"IT_DIFAL")
	Endif
	nValICM   := aLivroVEC[5]
	nAliICM   := aLivroVEC[2]
	nBaseIcm  := MaFisRet(n,"IT_BASEICM")
	nValIRR   := MaFisRet(n,"IT_VALIRR")
	nValCSL   := MaFisRet(n,"IT_VALCSL")
	//
	DbSelectArea("VEC")
	If !RecLock("VEC",.t.)
		HELP(" ",1,"REGNLOCK",,"VEC - OX100VEC",4,1)
		Return .f.
	EndIf
	
	VEC_FILIAL := xFilial("VEC")
	VEC_NUMREL := GetSXENum("VEC","VEC_NUMREL")
	ConfirmSx8()
	VEC_NUMIDE := GetSXENum("VEC","VEC_NUMIDE")
	ConfirmSx8()
	
	VEC->VEC_NUMOSV := cNumOsv
	VEC->VEC_LIBVOO := cLibVOO
	VEC->VEC_PECINT := SB1->B1_COD
	VEC->VEC_CODMAR := VO1->VO1_CODMAR
	VEC->VEC_TIPTEM := VOI->VOI_TIPTEM
	VEC->VEC_MODVEI := VV1->VV1_MODVEI
	VEC->VEC_DATVEN := dDataBase
	VEC->VEC_GRUITE := oGetDetVO3:aCols[ nPosGet, DVO3GRUITE ]
	VEC->VEC_CODITE := oGetDetVO3:aCols[ nPosGet, DVO3CODITE ]
	VEC->VEC_QTDITE := aAuxVO3[nCntFor, AP_QTDREQ]
	VEC->VEC_VALDES := VZ1->VZ1_VALDES
	VEC->VEC_NUMNFI := cNota
	VEC->VEC_SERNFI := cSerie
	
	if DVO3CENCUS > 0 .and. DVO3CONTA > 0 .and. DVO3ITEMCT > 0 .and. DVO3CLVL > 0
		VEC->VEC_CENCUS := oGetDetVO3:aCols[ nPosGet, DVO3CENCUS ]
		VEC->VEC_CONTA  := oGetDetVO3:aCols[ nPosGet, DVO3CONTA ]
		VEC->VEC_ITEMCT := oGetDetVO3:aCols[ nPosGet, DVO3ITEMCT ]
		VEC->VEC_CLVL   := oGetDetVO3:aCols[ nPosGet, DVO3CLVL ]
	Endif
	
	If DVO3PEDXML > 0
		
		VEC->VEC_PEDXML := oGetDetVO3:aCols[nPosGet, DVO3PEDXML ]
		VEC->VEC_ITEXML := oGetDetVO3:aCols[nPosGet, DVO3ITEXML ]
		
	EndIf
	
	// Descobre a linha na Matriz Auxiliar para pegar o Item do Pedido de Venda a qual se refere o produto ...
	nPosRel := aScan( aRelFatOfi , { |x| x[1] == "VO3" .and. x[2] == nPosGet } )
	//
	
	// Grava o numero do pedido de venda/orcamento do loja...
	If lVECITENFI
		VEC->VEC_PEDNUM := cAuxPedOrc
		VEC->VEC_PEDITE := aRelFatOfi[nPosRel,3]
	EndIf
	//
	
	If lNF
		
		// Posiciona Nota Fiscal e Item da Nota Fiscal
		If !OX100SF2( cNota , cSerie , aRelFatOfi[ nPosRel , 3 ] )
			Return .f.
		EndIf
		
		// Grava o numero do item da nota fiscal para relacionamento ...
		If lVECITENFI
			VEC->VEC_ITENFI := SD2->D2_ITEM
		EndIf
		//
		
		aRelFatOfi[ nPosRel , 4 ] := SD2->D2_ITEM
		
		nQtd    := SD2->D2_QUANT
		nValPrinc   := SD2->D2_TOTAL + SD2->D2_VALFRE + SD2->D2_SEGURO + SD2->D2_DESPESA + SD2->D2_VALIPI + SD2->D2_ICMSRET
		nPerc   := VEC->VEC_QTDITE / SD2->D2_QUANT
		
		// Tipo de tempo de franquia, se tiver zerado considera 1
		// a franquia de pecas pode faturar com quantidade zerada, pois ้ so uma nota fiscal com o valor de franquia
		If VOI->VOI_SEGURO == "2" .and. nPerc == 0
			nPerc := 1
		EndIf
		
		VEC->VEC_CUSMED := SD2->D2_CUSTO1 * nPerc
		VEC->VEC_VALVDA := SD2->D2_TOTAL  * nPerc
		VEC->VEC_VALBRU := ( nValPrinc * nPerc ) + VEC->VEC_VALDES
		VEC->VEC_JUREST := 0
		VEC->VEC_CUSTOT := VEC->VEC_CUSMED + VEC->VEC_JUREST
		VEC->VEC_VALFRE := SD2->D2_VALFRE * nPerc
		VEC->VEC_VALSEG := SD2->D2_SEGURO * nPerc
		if lVECDESACE
			VEC->VEC_DESACE := SD2->D2_DESPESA * nPerc
		Endif
		if lVECICMSRT
			VEC->VEC_ICMSRT := SD2->D2_ICMSRET * nPerc
		Endif
		if lVECVALIPI
			VEC->VEC_VALIPI := SD2->D2_VALIPI * nPerc
		Endif
		
		VEC->VEC_VALICM := nValICM * nPerc
		VEC->VEC_ALQICM := nAliICM
		VEC->VEC_VALCOF := nValCof * nPerc
		VEC->VEC_VALPIS := nValPis * nPerc
		
		if lVECVALCMP
			VEC->VEC_VALCMP := nValCmp * nPerc
		Endif
		if lVECDIFAL
			VEC->VEC_DIFAL  := nDifal * nPerc
		Endif
		
	Else
		
		nRecSL2 := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSqlName("SL2")+" WHERE L2_FILIAL ='"+xFilial("SL2")+"' AND L2_NUM = '"+VOO->VOO_PESQLJ+"' AND L2_PRODUTO = '"+SB1->B1_COD+"' AND L2_ITEM = '" + aRelFatOfi[ nPosRel , 3 ] + "' AND D_E_L_E_T_ = ' '")
		If nRecSL2 > 0
			SL2->(dbGoto(nRecSL2))
			
			nQtd  := SL2->L2_QUANT
			nPerc := VEC->VEC_QTDITE / SL2->L2_QUANT
			
			VEC->VEC_CUSMED := (SB2->B2_CM1) * VEC->VEC_QTDITE
			VEC->VEC_VALVDA := aAuxVO3[nCntFor, AP_ITTOTFISC] // (aColsFEC[2,ixi,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)])
			VEC->VEC_VALBRU := (MaFisRet(n,"IT_TOTAL") * nPerc) + VEC->VEC_VALDES
			VEC->VEC_VALICM := nValICM * nPerc
			VEC->VEC_ALQICM := nAliICM
			VEC->VEC_VALCOF := nValCof * nPerc
			VEC->VEC_VALPIS := nValPis * nPerc
			VEC->VEC_JUREST := 0
			
		Endif
	Endif
	
	if lVECDIFAL
		VEC->VEC_TOTIMP := VEC->VEC_VALICM + VEC->VEC_VALCOF + VEC->VEC_VALPIS + VEC->VEC_DIFAL + VEC->VEC_VALCMP
	Else
		VEC->VEC_TOTIMP := VEC->VEC_VALICM + VEC->VEC_VALCOF + VEC->VEC_VALPIS
	Endif
	if lVECVALIRR // IRRF
		VEC->VEC_VALIRR := nValIRR * nPerc
		VEC->VEC_VMFIRR := FG_CALCMF( { {dDataBase,VEC->VEC_VALIRR} })
	Endif
	if lVECVALCSL // CSLL
		VEC->VEC_VALCSL := nValCSL * nPerc
		VEC->VEC_VMFCSL := FG_CALCMF( { {dDataBase,VEC->VEC_VALCSL} })
	Endif

	// Comissao
	aVetTra := aClone(aBoqPec)
	OX100VETCOM( VEC->VEC_TIPTEM , @aVetTra )
	
	aValCom := FG_COMISS("P",aVetTra,VEC->VEC_DATVEN,VEC->VEC_GRUITE,VEC->VEC_VALVDA,"T",VEC->VEC_NUMIDE)
	VEC->VEC_COMVEN := aValCom[1]
	VEC->VEC_COMGER := aValCom[2]
	aValCom := FG_COMISS("P",aVetTra,VEC->VEC_DATVEN,VEC->VEC_GRUITE,VEC->VEC_VALVDA,"D")
	VEC->VEC_CMFVEN := FG_CALCMF(aValCom[1])
	VEC->VEC_CMFGER := FG_CALCMF(aValCom[2])
	//
	
	VEC->VEC_DESVAR := VEC->VEC_COMVEN + VEC->VEC_COMGER
	VEC->VEC_DESFIX := 0
	VEC->VEC_CUSFIX := 0
	VEC->VEC_DESDEP := 0
	VEC->VEC_DESADM := 0
	VEC->VEC_BALOFI := "O" // Oficina
	If VOI->VOI_SITTPO == "3" // Tipo de Tempo Interno
		VEC->VEC_DEPVEN := aAuxVO3[nCntFor, AP_DEPINT] // aColsFEC[2,ixi,FS_POSVAR("VO3_DEPINT","aHeaderFEC",2)]
	EndIf
	If VOI->VOI_SITTPO == "2" // Tipo de Tempo de Garantia
		VEC->VEC_DEPVEN := aAuxVO3[nCntFor, AP_DEGGAR] // aColsFEC[2,ixi,FS_POSVAR("VO3_DEPGAR","aHeaderFEC",2)]
	EndIf
	
	VEC->VEC_LUCBRU := ( VEC->VEC_VALBRU - VEC->VEC_VALDES ) - VEC->VEC_TOTIMP - VEC->VEC_CUSMED - IIF( lVECICMSRT,VEC->VEC_ICMSRT,0) + IIF( lVECICMSST , VEC->VEC_ICMSST,0) + IIF( lVECDCLBST, VEC->VEC_DCLBST , 0 ) + IIF( lVECCOPIST , VEC->VEC_COPIST , 0 )
	VEC->VEC_LUCLIQ := VEC->VEC_LUCBRU - VEC->VEC_JUREST - VEC->VEC_DESVAR - VEC->VEC_DESDEP - VEC->VEC_DESADM - VEC->VEC_DESFIX  //LUCRO MARGINAL
	VEC->VEC_RESFIN := VEC->VEC_LUCLIQ - VEC->VEC_CUSFIX  //LAIR
	
	VEC->VEC_VMFBRU := FG_CALCMF( {{dDataBase , VEC->VEC_VALBRU}} )
	VEC->VEC_VMFVDA := VEC->VEC_VMFBRU - FG_CALCMF( {{dDataBase, VEC->VEC_VALDES} })
	VEC->VEC_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VEC->VEC_VALICM} })
	VEC->VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC->VEC_VALPIS} })
	VEC->VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC->VEC_VALCOF} })
	VEC->VEC_TMFIMP := VEC->VEC_VMFICM + VEC->VEC_VMFCOF + VEC->VEC_VMFPIS
	
	VEC->VEC_CMFMED := FG_CALCMF( { {dDataBase,SB2->B2_CM1} }) * VEC->VEC_QTDITE
	VEC->VEC_JMFEST := FG_CALCMF( { {dDataBase,VEC->VEC_JUREST} })
	VEC->VEC_CMFTOT := VEC->VEC_CMFMED + VEC->VEC_JMFEST
	VEC->VEC_LMFBRU := VEC->VEC_VMFVDA - VEC->VEC_TMFIMP - VEC->VEC_CMFTOT
	
	VEC->VEC_DMFVAR := VEC->VEC_CMFVEN + VEC->VEC_CMFGER
	VEC->VEC_LMFLIQ := VEC->VEC_LMFBRU - VEC->VEC_DMFVAR
	VEC->VEC_DMFFIX := 0
	VEC->VEC_CMFFIX := 0
	VEC->VEC_DMFDEP := 0
	VEC->VEC_DMFADM := 0
	VEC->VEC_RMFFIN := VEC->VEC_LMFLIQ - VEC->VEC_DMFFIX - VEC->VEC_CMFFIX - VEC->VEC_DMFDEP - VEC->VEC_DMFADM

	VEC->(MsUnlock())
	VEC->(dbGoTo(VEC->(Recno())))
	
	//Gravacao do VVD (Despesas com Veiculos no Estoque)
	OX100DESVEI(cNumOsv, VEC->VEC_VALVDA, cNota, cSerie, "P", VEC->VEC_GRUITE, VEC->VEC_CODITE, cTipTem, cLibVOO )
	//
	
	If lVECITENFI
		For nCntMov := 1 to Len(aAuxVO3[nCntFor,AP_MOV])
			VO3->(dbGoTo(aAuxVO3[nCntFor,AP_MOV,nCntMov,PECA_MOV_RECVO3]))
			VO3->VO3_ITENFI := aRelFatOfi[nPosRel,4]
			VO3->VO3_VECREL := VEC->VEC_NUMREL
			VO3->VO3_PEDNUM := cAuxPedOrc
			VO3->VO3_PEDITE := aRelFatOfi[nPosRel,3]
		Next nCntMov
	EndIf
	
Next

// Volta valor de N
n := nBkpN

if ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
	if FindFunction('OFAGVmi') .AND. !EMPTY(cNumOsv)
		oVmi := OFAGVmi():New()
		oVmi:Trigger({;
			{'EVENTO'   , oVmi:oVmiMovimentos:OS},;
			{'ORIGEM'   , "OFIXX100_DMS4_OS"    },;
			{'NUMERO_OS', cNumOsv               } ;
		})
	endif
endif

Return .t.




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VZ1   บAutor  ณ Takahashi          บ Data ณ  09/12/14 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Posiciona VZ1 de acordo com os parametros                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100VZ1(cNumOsv,cTipTem,cGruIte,cCodIte,cLibVOO,cFormul,nValPec,lPosiciona)

Local cSQL

cSQL := "SELECT R_E_C_N_O_ RECVZ1 "
cSQL +=  " FROM " + RetSQLName("VZ1")
cSQL += " WHERE VZ1_FILIAL = '" + xFilial("VZ1") + "' "
cSQL +=   " AND VZ1_NUMOSV = '" + cNumOsv + "' "
cSQL +=   " AND VZ1_TIPTEM = '" + cTipTem + "' "
cSQL +=   " AND VZ1_PECSER = 'P' "
cSQL +=   " AND VZ1_GRUITE = '" + cGruIte + "' "
cSQL +=   " AND VZ1_CODITE = '" + cCodIte + "' "
cSQL +=   " AND VZ1_LIBVOO = '" + cLibVOO + "' "

If lFORMUL
	cSQL += " AND VZ1_FORMUL = '" + cFormul + "' "
EndIf
// Utiliza o valor da peca da requisicao
IF VOI->VOI_VLPCAC == "1"
	cSQL +=   " AND VZ1_VALUNI = " + Alltrim(str(nValPec)) + " "
EndIf
cSQL +=   " AND D_E_L_E_T_ = ' '"

nRecVZ1 := FM_SQL(cSQL)
If lPosiciona
	VZ1->(DbGoTo(nRecVZ1))
EndIf

Return nRecVZ1

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VSC   บAutor  ณ Takahashi          บ Data ณ  15/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Gera Registro de Avaliacao de Venda de Servicos            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100VSC(cNumOsv, cTipTem, lNF, lCupom, cNota, cSerie, aRelFatOfi, cLibVOO, cAuxPedOrc, lNFSrvc )

Local nCntFor
Local nCntApon
Local nRazIte
Local nPosGet
Local aVetTra
Local nPosRel := 0
Local lVSCContab  := VSC->(FieldPos("VSC_CENCUS")) > 0 .and. VSC->(FieldPos("VSC_CONTA")) > 0 .and. VSC->(FieldPos("VSC_ITEMCT")) > 0 .and. VSC->(FieldPos("VSC_CLVL")) > 0
Local lVSCVALIRR  := VSC->(FieldPos("VSC_VALIRR")) > 0
Local lVSCVALCSL  := VSC->(FieldPos("VSC_VALCSL")) > 0

Local nValPis := 0  // Valor do PIS do Tipo de Servico    ( FISCAL )
Local nValCof := 0  // Valor do COFINS do Tipo de Servico ( FISCAL )
Local nValISS := 0  // Valor do ISS do Tipo de Servico    ( FISCAL )
Local nValIRR := 0  // Valor do IRRF
Local nValCSL := 0  // Valor do CSLL

Local nVSCVALBRU := 0
Local nVSCVALDES := 0
Local nVSCVALSER := 0
Local nVSCTEMCOB := 0
Local nVSCVALISS := 0
Local nVSCVALPIS := 0
Local nVSCVALCOF := 0
Local nVSCVALIRR := 0
Local nVSCVALCSL := 0

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")

Local lVSCITENFI := (VSC->(FieldPos("VSC_ITENFI")) <> 0)

Local nValDesVei := 0

For nCntFor := 1 to Len(aAuxVO4)
	
	If aAuxVO4[nCntFor,AS_NUMOSV] <> cNumOsv .or. aAuxVO4[nCntFor,AS_TIPTEM] <> cTipTem .or. aAuxVO4[nCntFor,AS_LIBVOO] <> cLibVOO
		Loop
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Procura a Posicao da GetDados que contem os dados do Fechamento ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPosGet := aScan( oGetResVO4:aCols, { |x| x[RVO4TIPTEM] == aAuxVO4[nCntFor,AS_TIPTEM] .and. x[RVO4TIPSER] == aAuxVO4[nCntFor,AS_TIPSER] } )
	If nPosGet == 0
		Help(" ",1,"OX100GDMA",,STR0047+chr(13)+chr(10)+"OX100VSC",4,1)
		Loop
	EndIf
	//
	
	// Descobre a linha na Matriz Auxiliar para pegar o Item do Pedido de Venda a qual se refere o produto ...
	nPosRel := aScan( aRelFatOfi , { |x| x[1] == "VO4" .and. x[2] == nPosGet } )
	//
	
	VOI->(dbSetOrder(1))
	VOI->(dbSeek(xFilial("VOI") + cTipTem ))
	
	VOK->(dbSetOrder(1))
	VOK->(dbSeek(xFilial("VOK") + aAuxVO4[nCntFor,AS_TIPSER] ))
	
	// Posiciona Fiscal ...
	If lNFSrvc
		OX100SRVFIS( nPosGet ) // Set o N para a Posicao Correspondente no Fiscal
		nValPis := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
		nValCof := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
		nValISS := MaFisRet(n,"IT_VALISS")
		nValIRR := MaFisRet(n,"IT_VALIRR")
		nValCSL := MaFisRet(n,"IT_VALCSL")
		
		// Do imposto, considera somente o percentual do VO4 em relacao ao total do Tipo de Servico (Fechamento)
		nValPis := A410Arred( nValPis * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALPIS" )
		nValCof := A410Arred( nValCof * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALCOF" )
		nValISS := A410Arred( nValISS * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALISS" )
		If lVSCVALIRR
			nValIRR := A410Arred( nValIRR * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALIRR" )
		EndIf
		If lVSCVALCSL
			nValCSL := A410Arred( nValCSL * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALCSL" )
		EndIf
		
	EndIf
	//
	
	aSort(aAuxVO4[nCntFor,AS_APONTA] , 1 , , { |x,y| x[AS_APONTA_PERCEN] <= y[AS_APONTA_PERCEN] } )
	
	nVSCVALBRU := 0
	nVSCVALDES := 0
	nVSCVALSER := 0
	nVSCTEMCOB := 0
	nVSCVALISS := 0
	nVSCVALPIS := 0
	nVSCVALCOF := 0
	nVSCVALIRR := 0
	nVSCVALCSL := 0

	nValDesVei := 0
	
	For nCntApon := 1 to Len(aAuxVO4[nCntFor,AS_APONTA])
		
		DbSelectArea("VSC")
		If !RecLock("VSC",.t.)
			HELP(" ",1,"REGNLOCK",,"VSC - OX100VSC",4,1)
			DisarmTransaction()
			Return .f.
		EndIf
		
		// Posiciona no VO4
		VO4->(dbGoTo( aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_RECNO] ))
		
		VSC->VSC_FILIAL := xFilial("VSC")
		VSC->VSC_NUMIDE := GetSXENum("VSC","VSC_NUMIDE")
		ConfirmSx8()
		VSC->VSC_SERINT := aAuxVO4[nCntFor,AS_SERINT]
		VSC->VSC_NUMOSV := aAuxVO4[nCntFor,AS_NUMOSV]
		VSC->VSC_LIBVOO := cLibVOO
		VSC->VSC_GRUSER := aAuxVO4[nCntFor,AS_GRUSER]
		VSC->VSC_CODSER := aAuxVO4[nCntFor,AS_CODSER]
		VSC->VSC_TIPSER := aAuxVO4[nCntFor,AS_TIPSER]
		VSC->VSC_TIPTEM := aAuxVO4[nCntFor,AS_TIPTEM]
		VSC->VSC_MODVEI := VV1->VV1_MODVEI
		VSC->VSC_TEMPAD := aAuxVO4[nCntFor,AS_TEMPAD]
		VSC->VSC_TEMTRA := aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_TEMTRA]
		
		Do Case
			// Tempo para Calculo - 1=Fabrica / 2=Concessionaria / 4=Informado
			Case aAuxVO4[nCntFor,AS_INCTEM] $ "124"
				VSC->VSC_TEMVEN := aAuxVO4[nCntFor,AS_TEMPAD]
				VSC->VSC_TEMCOB := Round(aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN] * aAuxVO4[nCntFor,AS_TEMCOB] , 0 )
				
				nVSCTEMCOB += VSC->VSC_TEMCOB
				
				// Verifica se teve problema de arredondamento
				If nCntApon == Len(aAuxVO4[nCntFor,AS_APONTA])
					If nVSCTEMCOB <> aAuxVO4[nCntFor,AS_TEMCOB]
						VSC->VSC_TEMCOB += aAuxVO4[nCntFor,AS_TEMCOB] - nVSCTEMCOB
					EndIf
				EndIf
				//
				
				// Tempo para Calculo - 3=Trabalhado
			Case aAuxVO4[nCntFor,AS_INCTEM] == "3"
				VSC->VSC_TEMVEN := aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_TEMTRA]
				VSC->VSC_TEMCOB := aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_TEMTRA]
		EndCase
		
		VSC->VSC_CODPRO := aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_CODPRO]
		VSC->VSC_CODSEC := aAuxVO4[nCntFor,AS_SECAO]
		VSC->VSC_DATVEN := dDataBase
		VSC->VSC_KILROD := aAuxVO4[nCntFor,AS_KILROD]
		VSC->VSC_RECVO4 := StrZero(aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_RECNO],9)
		
		if lVSCContab
			VSC->VSC_CENCUS := aAuxVO4[nCntFor,AS_CENCUS]
			VSC->VSC_CONTA  := aAuxVO4[nCntFor,AS_CONTA]
			VSC->VSC_ITEMCT := aAuxVO4[nCntFor,AS_ITEMCT]
			VSC->VSC_CLVL   := aAuxVO4[nCntFor,AS_CLVL]
		Endif
		
		VSC->VSC_VALBRU := 0
		VSC->VSC_VALDES := 0
		VSC->VSC_VALSER := 0
		VSC->VSC_CUSSER := 0
		
		// Tipo de Tempo Interno
		If VOI->VOI_SITTPO == "3"
			Do Case
				Case VOK->VOK_INCMOB == "2"   // 2=Srv de Terceiro
					VSC->VSC_CUSSER := VO4->VO4_VALCUS
				Case VOK->VOK_INCMOB == "6"   // 6=Franquia
					VSC->VSC_CUSSER := VO4->VO4_VALCUS
			EndCase
			
			// Tipo de Tempo NAO Interno
		Else
			If VOK->VOK_INCMOB $ "1,2,3,6"  // 1=Mao-de-Obra / 2=Srv de Terceiro / 3=Vlr Livre c/Base na Tabela / 6=Franquia
				VSC->VSC_VALBRU := A410Arred( aAuxVO4[nCntFor,AS_VALBRU] * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALBRU" )
				VSC->VSC_VALDES := A410Arred( aAuxVO4[nCntFor,AS_VALDES] * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALDES" )
				
				If VOK->VOK_INCMOB $ "2,6"  // 2=Srv de Terceiro / 6=Franquia
					VSC->VSC_CUSSER := VO4->VO4_VALCUS
				EndIf
				
			ElseIf VOK->VOK_INCMOB == "5" // 5=Km Socorro
				If VOI->VOI_TPOKLM <> "S" // NรO ้ Tp de Tempo de Kilometro
					VSC->VSC_VALBRU := A410Arred( aAuxVO4[nCntFor,AS_VALBRU] * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALBRU" )
					VSC->VSC_VALDES := A410Arred( aAuxVO4[nCntFor,AS_VALDES] * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALDES" )
				Endif
			EndIf
			
			VSC->VSC_VALSER := A410Arred(VSC->VSC_VALBRU - VSC->VSC_VALDES,"VSC_VALSER")
			
			nVSCVALBRU += VSC->VSC_VALBRU
			nVSCVALDES += VSC->VSC_VALDES
			nVSCVALSER += VSC->VSC_VALSER
			
			// Verifica se teve problema de arredondamento
			If nCntApon == Len(aAuxVO4[nCntFor,AS_APONTA])
				If nVSCVALDES <> aAuxVO4[nCntFor,AS_VALDES] .or. nVSCVALSER <> ( aAuxVO4[nCntFor,AS_VALBRU] - aAuxVO4[nCntFor,AS_VALDES] )
					VSC->VSC_VALBRU += aAuxVO4[nCntFor,AS_VALBRU] - nVSCVALBRU
					VSC->VSC_VALDES += aAuxVO4[nCntFor,AS_VALDES] - nVSCVALDES
					VSC->VSC_VALSER += ( aAuxVO4[nCntFor,AS_VALBRU] - aAuxVO4[nCntFor,AS_VALDES] ) - nVSCVALSER
				EndIf
			EndIf
			//
			
		EndIf
		
		VSC->VSC_VALISS := A410Arred(nValISS * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALISS" )
		VSC->VSC_VALPIS := A410Arred(nValPis * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALPIS" )
		VSC->VSC_VALCOF := A410Arred(nValCof * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALCOF" )

		nVSCVALISS += VSC->VSC_VALISS
		nVSCVALPIS += VSC->VSC_VALPIS
		nVSCVALCOF += VSC->VSC_VALCOF

		If lVSCVALIRR // IRRF
			VSC->VSC_VALIRR := A410Arred(nValIRR * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALIRR" )
			nVSCVALIRR += VSC->VSC_VALIRR
		EndIf
		If lVSCVALCSL // CSLL
			VSC->VSC_VALCSL := A410Arred(nValCSL * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSC_VALCSL" )
			nVSCVALCSL += VSC->VSC_VALCSL
		EndIf
		
		// Verifica se teve problema de arredondamento
		If nCntApon == Len(aAuxVO4[nCntFor,AS_APONTA])
			If nVSCVALISS <> nValISS
				VSC->VSC_VALISS += nValISS - nVSCVALISS
			EndIf
			If nVSCVALPIS <> nValPIS
				VSC->VSC_VALPIS += nValPIS - nVSCVALPIS
			EndIf
			If nVSCVALCOF <> nValCOF
				VSC->VSC_VALCOF += nValCOF - nVSCVALCOF
			EndIf
			If lVSCVALIRR .and. nVSCVALIRR <> nValIRR
				VSC->VSC_VALIRR += nValIRR - nVSCVALIRR
			EndIf
			If lVSCVALCSL .and. nVSCVALCSL <> nValCSL
				VSC->VSC_VALCSL += nValCSL - nVSCVALCSL
			EndIf
		EndIf
		//
		
		VSC->VSC_TOTIMP := VSC->VSC_VALISS + VSC->VSC_VALPIS + VSC->VSC_VALCOF
		
		VSC->VSC_CUSTOT := VSC->VSC_CUSSER
		VSC->VSC_DESVAR := VSC->VSC_COMVEN + VSC->VSC_COMGER
		
		VSC->VSC_LUCBRU := VSC->VSC_VALSER - VSC->VSC_TOTIMP - VSC->VSC_CUSTOT
		VSC->VSC_LUCLIQ := VSC->VSC_LUCBRU - VSC->VSC_DESVAR - VSC->VSC_DESFIX - VSC->VSC_DESDEP - VSC->VSC_DESADM
		VSC->VSC_RESFIN := VSC->VSC_LUCLIQ - VSC->VSC_CUSFIX
		
		VSC->VSC_DESFIX := 0
		VSC->VSC_CUSFIX := 0
		VSC->VSC_DESADM := 0
		VSC->VSC_DESDEP := 0
		
		If lNF
			// Gerou NF para Servico ...
			If lNFSrvc
				VSC->VSC_NUMNFI := cNota
				VSC->VSC_SERNFI := cSerie
				
				If lVSCITENFI .and. nPosRel <> 0
					
					// Posiciona Nota Fiscal e Item da Nota Fiscal
					If !OX100SF2( cNota , cSerie , aRelFatOfi[ nPosRel , 3 ] )
						Return .f.
					EndIf
					
					VSC->VSC_ITENFI := SD2->D2_ITEM
					
					aRelFatOfi[ nPosRel , 4 ] := SD2->D2_ITEM
				EndIf
				
			Endif
		EndIf
		
		VSC->VSC_CODMAR := VO1->VO1_CODMAR
		
		VSC->VSC_VMFBRU := FG_CALCMF( {{ dDataBase , VSC->VSC_VALBRU }} )
		
		VSC->VSC_VMFSER := VSC->VSC_VMFBRU - FG_CALCMF( {{dDataBase   , VSC->VSC_VALDES } })
		VSC->VSC_VMFISS := FG_CALCMF( { { FG_RTDTIMP("ISS",dDataBase) , VSC->VSC_VALISS } })
		VSC->VSC_VMFPIS := FG_CALCMF( { { FG_RTDTIMP("PIS",dDataBase) , VSC->VSC_VALPIS } })
		VSC->VSC_VMFCOF := FG_CALCMF( { { FG_RTDTIMP("COF",dDataBase) , VSC->VSC_VALCOF } })
		
		VSC->VSC_TMFIMP := VSC->VSC_VMFPIS + VSC->VSC_VMFISS + VSC->VSC_VMFCOF

		If lVSCVALIRR // IRRF
			VSC->VSC_VMFIRR := FG_CALCMF( {{ dDataBase , VSC->VSC_VALIRR }} )
		EndIf
		If lVSCVALCSL // CSLL
			VSC->VSC_VMFCSL := FG_CALCMF( {{ dDataBase , VSC->VSC_VALCSL }} )
		EndIf

		VSC->VSC_CMFSER := FG_CALCMF( { {dDataBase,VSC->VSC_CUSSER} })
		VSC->VSC_CMFTOT := VSC->VSC_CMFSER
		VSC->VSC_LMFBRU := VSC->VSC_VMFSER - VSC->VSC_TMFIMP - VSC->VSC_CMFSER
		
		VSC->VSC_DMFVAR := VSC->VSC_CMFVEN + VSC->VSC_CMFGER
		VSC->VSC_LMFLIQ := VSC->VSC_LMFBRU - VSC->VSC_DMFVAR
		VSC->VSC_CMFFIX := 0
		VSC->VSC_DMFFIX := 0
		VSC->VSC_DMFADM := 0
		VSC->VSC_DMFDEP := 0
		VSC->VSC_RMFFIN := VSC->VSC_LMFLIQ - VSC->VSC_CMFFIX - VSC->VSC_DMFFIX - VSC->VSC_DMFADM - VSC->VSC_DMFDEP
		VSC->VSC_DEPINT := VO4->VO4_DEPINT
		VSC->VSC_DEPGAR := VO4->VO4_DEPGAR
		
		// ------------------------ //
		// Parametros para comissao //
		// ------------------------ //
		lProcCom := .f.
		nValCom := VSC->VSC_VALSER
		xVetTra := VSC->VSC_CODPRO
		// Tipo de Tempo Interno
		If VOI->VOI_SITTPO == "3"
			
			// Mao-de-Obra Gratuita, Mao-de-Obra, Valor Livre com Base na Tabela
			If VOK->VOK_INCMOB $ "0/1/3"
				lProcCom := .t.
				nValCom := VO4->VO4_VALINT
			EndIf
			nValDesVei += VO4->VO4_VALINT
			
		Else
			// Mao-de-Obra Gratuita
			If VOK->VOK_INCMOB $ "0"
				lProcCom := .t.
				nValCom := VO4->VO4_VALINT
				
				// Mao-de-Obra, Valor Livre com Base na Tabela
			ElseIf VOK->VOK_INCMOB $ "1/3"
				lProcCom := .t.
				
				// Servico de Terceiro, Socorro
			ElseIf VOK->VOK_INCMOB $ "2/5" .and. VOK->VOK_CMSR3R == "1"
				
				lProcCom := .t.
				
				// Gerando informacao de comissao
				xVetTra := {}
				OX100VETCOM(VSC->VSC_TIPTEM, @xVetTra )
			EndIf
		EndIf
		//
		
		If lProcCom
			aValCom    := FG_COMISS("S",xVetTra,VSC->VSC_DATVEN,VSC->VSC_TIPTEM,nValCom,"T",VSC->VSC_NUMIDE)
			VSC->VSC_COMVEN := aValCom[1]
			VSC->VSC_COMGER := aValCom[2]
			aValCom    := FG_COMISS("S",xVetTra,VSC->VSC_DATVEN,VSC->VSC_TIPTEM,nValCom,"D",VSC->VSC_NUMIDE)
			VSC->VSC_CMFVEN := FG_CALCMF(aValCom[1])
			VSC->VSC_CMFGER := FG_CALCMF(aValCom[2])
		EndIf
		
		If lVSCITENFI
			
			VSC->VSC_PEDNUM := cAuxPedOrc
			VSC->VSC_PEDITE := IIf( nPosRel <> 0 , aRelFatOfi[nPosRel,3] , "" )
			
			RecLock("VO4",.f.)
			VO4->VO4_ITENFI := IIf( nPosRel <> 0 , aRelFatOfi[nPosRel,4] , "" )
			VO4->VO4_VSCIDE := VSC->VSC_NUMIDE
			VO4->(MsUnLock())
		EndIf
		
		VSC->(MsUnlock())
		VSC->(dbGoTo(VSC->(Recno())))
		
	Next nCntApon
	//
	
	//Gravacao do VVD (Despesas com Veiculos no Estoque)
	OX100DESVEI(cNumOsv, nValDesVei, cNota, cSerie, "S", VSC->VSC_GRUSER, VSC->VSC_CODSER, cTipTem, cLibVOO )
	
Next

Return .t.

Static Function OX100SF2( cNota, cSerie, cItemPed )

SF2->(DbSetOrder(1))
If SF2->(MsSeek(xFilial("SF2") + cNota + cSerie))
	
	// Procura item da NF
	cSQL := "SELECT R_E_C_N_O_ "
	cSQL +=  " FROM " + RetSQLName("SD2")
	cSQL += " WHERE D2_FILIAL = '" + xFilial("SD2") + "'"
	cSQL +=   " AND D2_SERIE = '" + cSerie + "'"
	cSQL +=   " AND D2_DOC = '" + cNota + "'"
	cSQL +=   " AND D2_CLIENTE = '" + SF2->F2_CLIENTE + "'"
	cSQL +=   " AND D2_LOJA = '" + SF2->F2_LOJA + "'"
	//cSQL +=   " AND D2_COD = '" + SB1->B1_COD + "'"
	cSQL +=   " AND D2_ITEMPV = '" + cItemPed + "'" // Item do Pedido de Venda ...
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	nRecSD2 := FM_SQL( cSQL )
	If nRecSD2 == 0
		HELP(" ",1,"OX100SF2",,STR0154 + cItemPed + STR0155 + cNota + " / " + cSerie,4,1)  // "Item "   " nใo Encontrado na NF / S้rie: "
		Return .f.
	EndIf
	SD2->(dbGoTo(nRecSD2))
Else
	HELP(" ",1,"OX100SF2",,STR0156 + cNota + " / " + cSerie,4,1) // "NF / S้rie nใo encontrada: "
	Return .f.
Endif
//

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VETCOM บAutor  ณ Takahashi         บ Data ณ  21/11/14 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Array com tecnicos que receberao comissao            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100VETCOM( cTipTem , aVetTra )

Local cComCon := ""
Local cSQL

cSQL := "SELECT VOJ_COMISS "
cSQL +=  " FROM " + RetSQLName("VOJ") + " VOJ "
cSQL += " WHERE VOJ.VOJ_FILIAL = '" + xFilial("VOJ") + "'"
cSQL +=   " AND VOJ.VOJ_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND VOJ.VOJ_DATVIG <= '" + DtoS(dDataBase) + "'"
cSQL +=   " AND VOJ.D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY VOJ_DATVIG DESC "
cComCon := FM_SQL(cSQL)

Do Case
	Case cComCon == "1"
		aAdd(aVetTra,{VO1->VO1_FUNABE,0})
	Case cComCon == "2"
		aAdd(aVetTra,{VAI->VAI_CODTEC,0})
	Case cComCon == "3"
		aAdd(aVetTra,{VO1->VO1_FUNABE,0})
		aAdd(aVetTra,{VAI->VAI_CODTEC,0})
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100DFRAN  บAutor  ณ Takahashi         บ Data ณ  16/12/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Aplica desconto de franquia no fechamento de Tipo de Tempo บฑฑ
ฑฑบ          ณ de Seguradora                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da OS                                     บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo de Seguradora                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100DFRAN(cNumOsv, cTipTem)

Local nAuxDesc
Local nDesconto
Local nCntFor
Local nAuxTotSrvc

Local RVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Res")
Local RVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Res")
Local RVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Res")

Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")
Local RVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Res")
Local RVO4VALDES := FG_POSVAR("VO4_VALDES","aHVO4Res")

VOI->(dbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + cTipTem))

VO1->(dbSetOrder(1))
VO1->(dbSeek( xFilial("VO1") + cNumOsv))

// Aplica desconto de Franquia de Servicos ...
If VOI->VOI_TPSEGU $ "1,3" .and. VO1->VO1_FRANQU <> 0 .and. nTotDSrvc == 0
	nAuxDesc := VO1->VO1_FRANQU
	nAuxTotSrvc := nTotSrvc
	If Len(oGetResVO4:aCols) > 1 .or. ( Len(oGetResVO4:aCols) == 1 .and. !Empty(oGetResVO4:aCols[1, RVO4TIPSER]) )
		For nCntFor := 1 to Len(oGetResVO4:aCols)
			
			// Valor desconto rateado pelo grupo de pecas ...
			nDesconto := VO1->VO1_FRANQU * ( oGetResVO4:aCols[nCntFor, RVO4VALBRU] / nAuxTotSrvc )
			
			oGetResVO4:aCols[nCntFor, RVO4VALDES ] := nDesconto
			oGetResVO4:nAt := nCntFor
			
			FG_MEMVAR( oGetResVO4:aHeader, oGetResVO4:aCols, nCntFor )
			// Tenta Aplicar o desconto ...
			If !OX100SRFOK("M->VO4_VALDES")
				oGetResVO4:aCols[nCntFor, RVO4VALDES ] := 0
				Loop
			EndIf
			
			// Grava o Desconto que foi aplicado
			nDesconto := oGetResVO4:aCols[nCntFor, RVO4VALDES ]
			
			nAuxDesc -= nDesconto
		Next nCntFor
		
		oGetResVO4:nAt := 1
		
		// Problema no momento de aplicar os descontos
		If nAuxDesc <> 0
			Alert(STR0076) // "Nใo foi possivel aplicar desconto de franquia de pecas."
		EndIf
	EndIf
EndIf
// Aplica desconto de Franquia de Pecas ...
If VOI->VOI_TPSEGU $ "2,3" .and. VO1->VO1_FRANQP <> 0 .and. nTotDPeca == 0
	nAuxDesc := VO1->VO1_FRANQP
	If Len(oGetResVO3:aCols) > 1 .or. ( Len(oGetResVO3:aCols) == 1 .and. !Empty(oGetResVO3:aCols[1, RVO3GRUITE]) )
		For nCntFor := 1 to Len(oGetResVO3:aCols)
			
			// Valor desconto rateado pelo grupo de pecas ...
			nDesconto := VO1->VO1_FRANQP * ( oGetResVO3:aCols[nCntFor, RVO3VALBRU] / nTotPeca )
			
			oGetResVO3:aCols[nCntFor, RVO3VALDES ] := nDesconto
			oGetResVO3:nAt := nCntFor
			
			FG_MEMVAR( oGetResVO3:aHeader, oGetResVO3:aCols, nCntFor )
			// Tenta Aplicar o desconto ...
			If !OX100PRFOK("M->VO3_VALDES")
				oGetResVO3:aCols[nCntFor, RVO3VALDES ] := 0
				Loop
			EndIf
			
			// Grava o Desconto que foi aplicado
			nDesconto := oGetResVO3:aCols[nCntFor, RVO3VALDES ]
			
			nAuxDesc -= nDesconto
		Next nCntFor
		
		oGetResVO3:nAt := 1
		
		// Problema no momento de aplicar os descontos
		If nAuxDesc <> 0
			Alert(STR0076) // "Nใo foi possivel aplicar desconto de franquia de pecas."
		EndIf
	EndIf
EndIf
//

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100IMPGA  บAutor  ณ Takahashi         บ Data ณ  17/12/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Importacao da Garantia                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da Ordem de Servico                       บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100IMPGA(cNumOsv, cTipTem, cLibVOO)

Local cFunExp := ""

VOI->(dbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + cTipTem ))

// Verifica se o tipo de tempo ้ de Garantia
If !OX100TTGAR( cTipTem , VOI->VOI_SITTPO )
	Return .t.
EndIf

// Controle de valor de Garantia por periodo (VPH/VPI)
If FindFunction("OFIOA510GRV")
	// "Controle de Valor de Garantia por periodo" - chamada da Funcao para (1-somar) o VPH/VPI. Andre Luis Almeida - 27/03/2009 //
	OFIOA510GRV(1, cNumOsv, cTipTem) // Nro OS / Tipo de Tempo
EndIf

IncProc( STR0033 ) //Atualizando Informacoes de Garantia

If lFEXPGA
	If cMVMIL0006 == "JD"
		cCodMarVV1 := FMX_RETMAR("JD ") + "/" + FMX_RETMAR("GRS") + "/" + FMX_RETMAR("PLA") + "/" + FMX_RETMAR("JDC") + "/" + FMX_RETMAR("HCM")
	Else
		cCodMarVV1 := VO1->VO1_CODMAR
	EndIf
	cFunExp := FMX_FEXPGA("2",cTipTem,cCodMarVV1)
	If Empty(cFunExp)
		Return .t.
	EndIf
Else
	// Verifica se exporta garantia no fechamento ...
	OX100VE4POSICIONA( VO1->VO1_CODMAR )
	If !(VE4->VE4_QDOIMP $ "2/3") // 2=Exporta no Fechamento da OS , 3=Abertura,Liberacao,Fechamento
		Return .t.
	EndIf
	//
	VEG->(dbSetOrder(1))
	If !VEG->(dbSeek( xFilial("VEG") + VE4->VE4_FOREXP ))
		Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VE4_FOREXP")) + ": " + VE4->VE4_FOREXP ,4,1)
		Return .t.
	EndIf
	cFunExp := Alltrim(VEG->VEG_FORMUL)
EndIf

cFunExp := OX100FORMUL( cFunExp , 'F' , cTipTem , cLibVOO )

If !Empty(cFunExp)
	// Funcao de Importacao para Garantia
	If !FG_VERFORGAR(cFunExp)
		Return .f.
	EndIf
EndIf

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100FORMUL บAutor  ณ Takahashi         บ Data ณ  17/12/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Monta string para executar funcao de garantia              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100FORMUL( cFuncao , cParFunc , cTipTem , cLibVOO , cArrParFunc )

Local nIni

Default cArrParFunc := ""

cFuncao := AllTrim(cFuncao)
nIni := At("(",cFuncao)
If nIni <> 0
	cFuncao := Left(cFuncao,nIni-1)
EndIf

cFuncao += "('" + cParFunc + "','" + cTipTem + "','" + cLibVOO + "'," + IIF( !Empty(cArrParFunc) , "," + cArrParFunc , "" ) + " )"

Return cFuncao


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100DESVEI บAutor  ณ Takahashi         บ Data ณ  17/12/10 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Despesa do Veiculo                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da Ordem de Servico                       บฑฑ
ฑฑบ          ณ nValor = Valor da Despesa                                  บฑฑ
ฑฑบ          ณ cNumNF = Numero da Nota Fiscal                             บฑฑ
ฑฑบ          ณ cSerNF = Serie da Nota Fiscal                              บฑฑ
ฑฑบ          ณ cTipo = Tipo de Despesas (P=Peca / S=Servico)              บฑฑ
ฑฑบ          ณ cGrupo = Grupo de Peca/Servico                             บฑฑ
ฑฑบ          ณ cCodigo = Codigo da Peca/Servico                           บฑฑ
ฑฑบ          ณ cTipSer = Tipo de Servico                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//Static Function OX100DESVEI(cNumOsv, nValor, cNumNF, cSerNF, cTipo, cGrupo, cCodigo, cTipSer, cTipTem, cLibVOO)
Static Function OX100DESVEI(cNumOsv, nValor, cNumNF, cSerNF, cTipo, cGrupo, cCodigo, cTipTem, cLibVOO)
Local lVVD_FILOSV := VVD->(FieldPos("VVD_FILOSV")) <> 0
Local lVVD_FILUCP := VVD->(FieldPos("VVD_FILUCP")) <> 0
Local aMovAux     := {}
Local cFilUCp     := "" // Filial da Ultima Entrada por Compra
Local cTraUCp     := "" // Tracpa da Ultima Entrada por Compra
//Local aItensNew := {}
//Local lRet      := .t.
//Gravacao do VVD (Despesas com Veiculos no Estoque)
If VOI->VOI_SITTPO == "3" .and. VOI->VOI_DESVEI == "1" //Interno
	If VV1->VV1_SITVEI == "0" //Estoque
		VV5->(dbSetOrder(1))
		If !VV5->(dbSeek(xFilial("VV5") + "0" + cGrupo + cCodigo ))
			SB1->(dbSetOrder(7))
			SB1->(dbSeek(xFilial("SB1") + cGrupo + cCodigo ))
			SB1->(dbSetOrder(1))
			dbSelectArea("VV5")
			RecLock("VV5",.t.)
			VV5->VV5_FILIAL := xFilial("VV5")
			VV5->VV5_TIPOPE := "0"  // Despesa
			VV5->VV5_CODIGO := cGrupo + cCodigo // VSC->VSC_GRUSER+VSC->VSC_CODSER
			VV5->VV5_DESCRI := SB1->B1_DESC
			VV5->VV5_PECINT := SB1->B1_COD
			VV5->(MsUnlock())
		Endif
		//
		cFilUCp := VV1->VV1_FILENT
		cTraUCp := VV1->VV1_TRACPA
		If lVVD_FILUCP
			aMovAux := FGX_VEIMOVS( VV1->VV1_CHASSI , "E" , "0" ) // Retorna a ultima Entrada por Compra do Veiculo
			If len(aMovAux) > 0
				cFilUCp := aMovAux[1,2] // Ultima Filial de Entrada por Compra
				cTraUCp := aMovAux[1,3] // Ultimo TraCpa de Entrada por Compra
			EndIf
		EndIf
		//		
		cSQL := "SELECT VVD.R_E_C_N_O_ RECVVD"
		cSQL +=  " FROM " + RetSQLName("VVD") + " VVD "
		cSQL += " WHERE VVD.VVD_FILIAL = '" + xFilial("VVD") + "'"
		If lVVD_FILOSV
			cSQL += " AND (   VVD.VVD_FILOSV = '" + xFilial("VOO") + "' " // novos registros
			cSQL += "     OR  VVD.VVD_FILOSV = ' ' ) "   // registro antigos
		Endif
		cSQL += " AND VVD.VVD_TIPOPE = '0'"
		cSQL += " AND VVD.VVD_TRACPA = '"+VV1->VV1_TRACPA+"'"
		cSQL += " AND VVD.VVD_CHAINT = '"+VV1->VV1_CHAINT+"'"
		cSQL += " AND VVD.VVD_DATADR = "+dtos(dDataBase)+""
		cSQL += " AND VVD.VVD_NUMNFI = '"+cNumNF+"'"
		cSQL += " AND VVD.VVD_SERNFI = '"+cSerNF+"'"
		cSQL += " AND VVD.VVD_NUMOSV = '"+cNumOsv+"'"
		cSQL += " AND VVD.VVD_CODIGO = '"+VV5->VV5_CODIGO+"'"
		cSQL += " AND VVD.VVD_DESCRI = '"+VV5->VV5_DESCRI+"'"
		cSQL += " AND VVD.VVD_ATUCUS = '0'"
		cSQL += " AND VVD.VVD_TIPTEM = '"+cTipTem+"'"
		cSQL += " AND VVD.VVD_LIBVOO = '"+cLibVOO+"'"
		cSQL += " AND VVD.D_E_L_E_T_ = ' '"
		
		nRecNo := FM_SQL(cSQL)
		dbSelectArea("VVD")
		if nRecNo == 0
			RecLock("VVD",.t.)
			VVD->VVD_FILIAL := xFilial("VVD")
			VVD->VVD_TIPOPE := "0" //Despesa
			VVD->VVD_TRACPA := VV1->VV1_TRACPA
			VVD->VVD_CHAINT := VV1->VV1_CHAINT
			VVD->VVD_DATADR := dDataBase
			VVD->VVD_DATVEN := dDataBase
			VVD->VVD_CODFOR := ""
			VVD->VVD_LOJA   := ""
			VVD->VVD_CODCLI := ""
			VVD->VVD_LOJACL := ""
			VVD->VVD_NUMNFI := cNumNF // VSC->VSC_NUMNFI
			VVD->VVD_SERNFI := cSerNF // VSC->VSC_SERNFI
			VVD->VVD_NUMTIT := ""
			VVD->VVD_TIPTIT := ""
			VVD->VVD_NATURE := ""
			VVD->VVD_NUMOSV := cNumOsv // VSC->VSC_NUMOSV
			VVD->VVD_CODIGO := VV5->VV5_CODIGO
			VVD->VVD_DESCRI := VV5->VV5_DESCRI
			VVD->VVD_VALOR  := nValor // VO4->VO4_VALINT // VSC->VSC_VALSER
			VVD->VVD_ATUCUS := "0"
			If VVD->(FieldPos("VVD_LIBVOO")) <> 0
				VVD->VVD_TIPTEM := cTipTem
				VVD->VVD_LIBVOO := cLibVOO
			EndIf
			If lVVD_FILOSV
				VVD->VVD_FILENT := VV1->VV1_FILENT
				VVD->VVD_FILOSV := xFilial("VOO")
			Endif
			If lVVD_FILUCP
				VVD->VVD_FILUCP := cFilUCp // Filial da ultima Entrada por Compra
				VVD->VVD_TRAUCP := cTraUCp // Tracpa da ultima Entrada por Compra
			EndIf
			MsUnlock()
			VVD->(dbGoTo(VVD->(Recno())))
		Else
			VVD->(DBGoTo(nRecNo))
			RecLock("VVD",.f.)
			VVD->VVD_VALOR  += nValor // VO4->VO4_VALINT // VSC->VSC_VALSER
			MsUnlock()
		Endif
		//
	Endif
Endif

Return .t. // lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100FCALC   บAutor  ณ Takahashi      บ Data ณ  23/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula Parcelas para Condicao Pgto de Tipo 9              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100FCALC()

Local nCntFor, nCntFor2
Local aColsTmp := {}
Local aParcelas
Local nValBase
Local nResto
Local nPosVS9
Local nValFixo := 0

Local PVS9TIPPAG := FG_POSVAR("VS9_TIPPAG","aHVS9")
Local PVS9ENTRAD := FG_POSVAR("VS9_ENTRAD","aHVS9")
Local PVS9VALPAG := FG_POSVAR("VS9_VALPAG","aHVS9")

If Empty(dCRDataIni) .or. nCRParc == 0
	MsgInfo(STR0077,STR0004)
	Return .f.
EndIf

// Copia os Registros de Entrada
For nCntFor := 1 to Len(oGetVS9:aCols)
	If !Empty(oGetVS9:aCols[nCntFor, PVS9TIPPAG ]) .and. oGetVS9:aCols[nCntFor, PVS9ENTRAD ] <> "N"
		If !oGetVS9:aCols[nCntFor, Len(oGetVS9:aCols[nCntFor])]
			nValFixo += oGetVS9:aCols[nCntFor, PVS9VALPAG ]
		EndIf
		aAdd(aColsTmp,oGetVS9:aCols[nCntFor])
	EndIf
Next nCntFor
// Verifica se existe valor a calcular ...
If nValFixo > nTotNFiscal
	MsgAlert(STR0035,STR0004)
	Return
EndIf
//
oGetVS9:aCols := aClone(aColsTmp)

// Calcula parcelas ...
aParcelas := {}
//nCRSaldo := nTotNFiscal - nValFixo
nCRSaldo := nCRTotal - nValFixo
nValBase := Round( (nTotNFiscal - nValFixo) / nCRParc ,2)
//
For nCntFor := 1 to nCRParc
	aAdd(aParcelas, {(dCRDataIni + nCRDias) + ( (nCntFor - 1) * nCRInter ) , nValBase} )
Next
//
nResto := nCRSaldo - (nValBase * nCRParc)
aParcelas[1,2] += nResto
//
For nCntFor := 1 to Len(aParcelas)
	AADD(oGetVS9:aCols, Array(Len(aCVS9[1])) )
	oGetVS9:aCols[Len(oGetVS9:aCols)] := aClone(aCVS9[1])
	nPosVS9 := Len(oGetVS9:aCols)
	
	nCRSaldo -= aParcelas[nCntFor,2]
	
	For nCntFor2:=1 to Len(aHVS9)
		If aHVS9[nCntFor2,2]  == "VS9_TIPPAG"
			oGetVS9:aCols[ nPosVS9 ,nCntFor2] := "DP"
			
		ElseIf aHVS9[nCntFor2,2]  == "VS9_DATPAG"
			oGetVS9:aCols[ nPosVS9 ,nCntFor2] := aParcelas[nCntFor,1]
			
		ElseIf aHVS9[nCntFor2,2]  == "VS9_VALPAG"
			oGetVS9:aCols[ nPosVS9 ,nCntFor2] := aParcelas[nCntFor,2]
			
		ElseIf aHVS9[nCntFor2,2]  == "VS9_DESPAG"
			oGetVS9:aCols[ nPosVS9 ,nCntFor2] := POSICIONE("VSA",1,xFilial("VSA")+VS9->VS9_TIPPAG,"VSA_DESPAG")
			
		ElseIf aHVS9[nCntFor2,2]  == "VS9_ENTRAD"
			oGetVS9:aCols[ nPosVS9 ,nCntFor2] := "N"
			
		Else
			oGetVS9:aCols[ nPosVS9 ,nCntFor2] := CriaVar(aHVS9[nCntFor2,2])
			
		EndIf
	Next nCntFor2
Next nCntFor

oCRSaldo:Refresh()
OX100REORD()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100REORD   บAutor  ณ Takahashi      บ Data ณ  23/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reordena aCols de Parcelas                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100REORD()

Local PVS9DATPAG := FG_POSVAR("VS9_DATPAG","aHVS9")
Local PVS9TIPPAG := FG_POSVAR("VS9_TIPPAG","aHVS9")
Local PVS9VALPAG := FG_POSVAR("VS9_VALPAG","aHVS9")

aSort( oGetVS9:aCols ,,,{|x,y| DtoS(x[PVS9DATPAG]) + x[PVS9TIPPAG] + Str(x[PVS9VALPAG],10,2) < DtoS(y[PVS9DATPAG]) + y[PVS9TIPPAG] + Str(y[PVS9VALPAG],10,2) })
//
oGetVS9:oBrowse:refresh()
//
return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100FDESF   บAutor  ณ Takahashi      บ Data ณ  23/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Desfaz Calculo de Parcelas para Condicao Pgto de Tipo 9    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100FDESF()

Local nCntFor
Local aColsTmp
Local nTotParc

Local PVS9TIPPAG := FG_POSVAR("VS9_TIPPAG","aHVS9")
Local PVS9ENTRAD := FG_POSVAR("VS9_ENTRAD","aHVS9")
Local PVS9VALPAG := FG_POSVAR("VS9_VALPAG","aHVS9")

aColsTmp := {}
For nCntFor := 1 to Len(oGetVS9:aCols)
	If !Empty(oGetVS9:aCols[nCntFor, PVS9TIPPAG ])
		If !(oGetVS9:aCols[nCntFor, PVS9ENTRAD ] $ "NA")
			aAdd(aColsTmp,oGetVS9:aCols[nCntFor])
		EndIf
	EndIf
Next nCntFor

If Len(aColsTmp) == 0
	oGetVS9:aCols := { Array(Len(aCVS9[1])) }
	oGetVS9:aCols[Len(oGetVS9:aCols)] := aClone(aCVS9[1])
	nPosVS9 := Len(oGetVS9:aCols)
Else
	oGetVS9:aCols :=aClone(aColsTmp)
EndIf
// Calcula o saldo
nTotParc := 0
for nCntFor := 1 to Len(oGetVS9:aCols)
	if !(oGetVS9:aCols[nCntFor,Len(oGetVS9:aCols[nCntFor])])
		nTotParc += oGetVS9:aCols[nCntFor, PVS9VALPAG ]
	endif
next
//nCRSaldo := nTotNFiscal - nTotParc
nCRSaldo := nCRTotal - nTotParc
oCRSaldo:Refresh()
OX100REORD()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100BXFIN   บAutor  ณ Takahashi      บ Data ณ  31/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Baixa titulos do Financeiro quando for a vista             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100BXFIN(cPrefixo, cDup, cCliente, cLoja, lFecPeca, lFecSrvc)

Local cSQL
Local cAliasSE1 := "TSE1"
Local aBaixa      // Parametro de Integracao com FINA070
Local cNatureza     // Natureza do titulo
Local lRetorno := .t.

cSQL := "SELECT SE1.E1_TIPO, SE1.R_E_C_N_O_ NRECNO"
cSQL += " FROM " + RetSqlName("SE1") + " SE1 "
cSQL += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
cSQL +=  " AND SE1.E1_PREFIXO = '" + cPrefixo + "'"
cSQL +=  " AND SE1.E1_NUM = '" + cDup + "'"
cSQL +=  " AND SE1.E1_CLIENTE = '" + cCliente + "'"
cSQL +=  " AND SE1.E1_LOJA = '" + cLoja + "'"
cSQL +=  " AND SE1.E1_VENCREA = '" + DTOS(dDataBase) + "'"
cSQL +=  " AND SE1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasSE1 , .F., .T. )

While !(cAliasSE1)->(Eof())
	
	If !(cAliasSE1)->E1_TIPO $ MVABATIM
		
		SE1->(dbGoTo( (cAliasSE1)->NRECNO ))
		
		// Soma titulos de abatimento para nใo considerar na baixa automatica
		nValAbat := OX100VLAB( SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_PARCELA, SE1->E1_CLIENTE , SE1->E1_LOJA )
		//
		
		aBaixa  := {{"E1_PREFIXO"   , SE1->E1_PREFIXO           ,Nil},;
		{"E1_CLIENTE"   , SE1->E1_CLIENTE           ,Nil},;
		{"E1_LOJA"      , SE1->E1_LOJA              ,Nil},;
		{"E1_NUM"       , SE1->E1_NUM               ,Nil},;
		{"E1_PARCELA"   , SE1->E1_PARCELA           ,Nil},;
		{"E1_TIPO"      , SE1->E1_TIPO              ,Nil},;
		{"AUTMOTBX"     , "NOR"                     ,Nil},;
		{"AUTDTBAIXA"   , dDataBase                 ,Nil},;
		{"AUTDTCREDITO" , dDataBase                 ,Nil},;
		{"AUTHIST"      , STR0043                   ,Nil},; //"Baixa Automatica"
		{"AUTVALREC"    , SE1->E1_VALOR - nValAbat  ,Nil} }
		
		//PE criado para passagem de parโmetros customizados no ExecAuto do FINA070, seguindo o parโmetro MV_BXSER
		If ExistBlock("OX100BXF")
			aBaixa := ExecBlock("OX100BXF", .F., .F., aBaixa)
		Endif

		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x| FINA070(x)},aBaixa)
		if lMsErroAuto
			( cAliasSE1 )->( dbCloseArea() )
			DbSelectArea("SE1")
			Return .f.
		Endif
	EndIf
	
	(cAliasSE1)->(dbSkip())
End

( cAliasSE1 )->( dbCloseArea() )
DbSelectArea("SE1")

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100TFIN    บAutor  ณ Takahashi      บ Data ณ  30/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula o Total Financeiro                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100TFIN(cCondPgto)

Local nRetorno := 0
Default cCondPgto := M->VOO_CONDPG

SE4->(dbSetOrder(1))
SE4->(dbSeek( xFilial("SE4") + cCondPgto ))

If MaFisFound('NF')
	If OX1000061_Condicao_Negociada() .and. MaFisRet(,"NF_VALISS") > 0 // Quando condi็ใo for tipo '9' e existir ISS deve retornar o Valor Total da NF
		nRetorno := MaFisRet(,"NF_TOTAL")
	Else
		nRetorno := MaFisRet(,"NF_BASEDUP")
	EndIf
Endif

nAcresFin := 0
If SE4->E4_ACRSFIN <> 0
	nAcresFin := nRetorno * (SE4->E4_ACRSFIN/100)
	nRetorno  := nRetorno + nAcresFin
EndIf

Return nRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100PECFIS  บAutor  ณ Takahashi      บ Data ณ  04/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle com o ambiente fiscal                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100PECFIS( nPosGet )
Local nPos

Default nPosGet := oGetDetVO3:nAt

nPos := aScan( aNPecaFis , { |x| x[1] == nPosGet} )
If nPos == 0
	++nTotFis
	aAdd(aNPecaFis,{ nPosGet, nTotFis })
	nPos := Len(aNPecaFis)
EndIf
n := aNPecaFis[nPos,2]
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100FISPEC  บAutor  ณ Takahashi      บ Data ณ  04/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle com o ambiente fiscal                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100FISPEC( nPosGet )
Default nPosGet := oGetDetVO3:nAt
n := nPosGet
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100SRVFIS  บAutor  ณ Takahashi      บ Data ณ  04/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle com o ambiente fiscal                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100SRVFIS( nPosGet )
Local nPos

Default nPosGet := oGetResVO4:nAt

nPos := aScan( aNSrvcFis , { |x| x[1] == nPosGet} )
If nPos == 0
	++nTotFis
	aAdd(aNSrvcFis,{ nPosGet, nTotFis })
	nPos := Len(aNSrvcFis)
EndIf
n := aNSrvcFis[nPos,2]
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100LBDES   บAutor  ณ Takahashi      บ Data ณ  27/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera Liberacao ou Verifica se a liberacao foi autorizada   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lGeraLib = Indica se vai gerar pedido de liberacao ou      บฑฑ
ฑฑบ          ณ            somente verifica se o pedido foi autorizado     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100LBDES(lGeraLib)

Local nCntFor, nCntFor2, nPecSer, nCntVS6

// Array com pecas / servicos com problemas
// Formato: [1] - Numero da OS
//          [2] - Matriz contendo a linha da matriz aAuxVO3 (peca) que esta com problema
//          [3] - Matriz contendo a linha da matriz aAuxVO4 (servico) que esta com problema
//          [4] - Numero da Liberacao de Peca Ou Geral quando gerar somente uma liberacao para peca e servicos
//          [5] - Numero da Liberacao de Servico quando gerar liberacao para peca e servicos SEPARADAS
//          [6] - Indica se deve alterar a Liberacao de Peca
//          [7] - Indica se deve alterar a Liberacao de Servico
//          [8] - Tipo de Tempo
//          [9] - Numero da Liberacao do Tipo de Tempo
Local aAuxProb  := {}
Local aDifNegoc := {} // Diferencas na Negociacao
Local aIntCab   := {} // Vetor utilizado no VISINT
//
Local aOSProb   := {}
Local nPosProb  := 0
Local lAltVS6   := .f.  // Controla se deve alterar alguma liberacao que ja estava gravada ...
Local aAuxVS6   := {}

Local cAliasVS6 := GetNextAlias()
Local cAliasVS7 := GetNextAlias()

Local lRetorno  := .t.

Local lGeraSep  := (GetNewPar("MV_GLIBVEN","N") == "S") // Gera liberacao de desconto separada de pecas e servicos ...

Local oArea := GetArea()

Local lTemProbDescMargem := .f. // ATENCAO - variavel NรO PODE SER inicializada durante processamento ...
Local lVS6Autorizado := .t. // ATENCAO - variavel NรO PODE SER inicializada durante processamento ...
Local lVS6JaGerada := .f. // ATENCAO - variavel NรO PODE SER inicializada durante processamento ...
Local lProbPeca := .f.
Local lProbSrvc := .f.

aPecSom := {} // Limpar VETOR

VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI")+__cUserID))

For nCntFor := 1 to Len(aVetTTP)
	
	If !aVetTTP[ nCntFor, ATT_VETSEL ]
		Loop
	EndIf
	
	VO1->(dbSetOrder(1))
	VO1->(MsSeek( xFilial("VO1") + aVetTTP[nCntFor, ATT_NUMOSV] ))
	
	// Procura Liberacao de Venda ...
	cSQL := "SELECT COUNT(*) QTDE"
	cSQL +=  " FROM " + RetSQLname("VS6") + " VS6"
	cSQL += " WHERE VS6_FILIAL = '" + xFilial("VS6") + "'"
	cSQL +=   " AND VS6_DOC IN ('Ind-" + aVetTTP[nCntFor, ATT_NUMOSV] + "','Agr-" + aVetTTP[nCntFor, ATT_NUMOSV] + "')"
	cSQL +=   " AND VS6_TIPTEM = '" + aVetTTP[nCntFor, ATT_TIPTEM ] + "'"
	cSQL +=   " AND VS6_LIBVOO = '" + aVetTTP[nCntFor, ATT_LIBVOO] + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	nCntVS6 := FM_SQL( cSQL )
	//
	
	// Verifica se existe problema de desconto
	aAuxProb := OX100CKDES( aVetTTP[nCntFor, ATT_NUMOSV] ,;
									aVetTTP[nCntFor, ATT_TIPTEM] ,;
									( nCntVS6 <= 0 )  ,;        // Exibe Help - Somente exibe Help quando ja tiver alguma liberacao ...
									aVetTTP[nCntFor, ATT_CLIENTE] ,;
									aVetTTP[nCntFor, ATT_LOJA] ,;
									aVetTTP[nCntFor, ATT_LIBVOO] )
	lProbPeca := .f.
	lProbSrvc := .f.
	If Len(aAuxProb) > 0

		// Verifica se existe problema com Pecas
		If aScan(aAuxProb[1,2], { |x| x[2] == .f. } ) <> 0
			lTemProbDescMargem := .t. // ATENCAO - variavel NรO PODE SER inicializada durante processamento ...
			lProbPeca := .t.
		EndIf

		// Verifica se existe problema com Servicos
		If aScan(aAuxProb[1,3], { |x| x[2] == .f. } ) <> 0
			lTemProbDescMargem := .t. // ATENCAO - variavel NรO PODE SER inicializada durante processamento ...
			lProbSrvc := .t.
		EndIf
		
	EndIf
	//

	
	// Ja Existe Liberacao de Desconto ...
	If nCntVS6 > 0
		
		// Nao tem mais problema de Desconto ...
		If ! lProbPeca .and. ! lProbSrvc
			
			cSQL := "SELECT VS6_NUMIDE"
			cSQL +=  " FROM " + RetSQLname("VS6") + " VS6"
			cSQL += " WHERE VS6_FILIAL = '" + xFilial("VS6") + "'"
			cSQL +=   " AND VS6_DOC IN ('Ind-" + aVetTTP[nCntFor, ATT_NUMOSV] + "','Agr-" + aVetTTP[nCntFor, ATT_NUMOSV] + "')"
			cSQL +=   " AND VS6_TIPTEM = '" + aVetTTP[nCntFor, ATT_TIPTEM ] + "'"
			cSQL +=   " AND VS6_LIBVOO = '" + aVetTTP[nCntFor, ATT_LIBVOO] + "'"
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS6 , .F., .T. )
			
			// Apaga todas as solicitacoes de liberacao de desconto ...
			While !(cAliasVS6)->(Eof())
				OX100DELLB((cAliasVS6)->VS6_NUMIDE)
				(cAliasVS6)->(dbSkip())
			End
			(cAliasVS6)->(dbCloseArea())
			dbSelectArea("VS6")
			//
			
		Else
			
			////////////////////////////////////////////////////////////
			// Recupera o Numero de liberacao de Pecas / Servicos ... //
			////////////////////////////////////////////////////////////
			cSQL := "SELECT VS6.VS6_NUMIDE,"
			cSQL +=  " SUM( CASE VS7_TIPAUT WHEN '1' THEN 1 ELSE 0 END ) PECA,"
			cSQL +=  " SUM( CASE VS7_TIPAUT WHEN '2' THEN 1 ELSE 0 END ) SRVC"
			cSQL +=  " FROM " + RetSQLName("VS6") + " VS6 JOIN " + RetSQLName("VS7") + " VS7 ON VS7_FILIAL = VS6_FILIAL AND VS7_NUMIDE = VS6_NUMIDE AND VS7.D_E_L_E_T_ = ' ' "
			cSQL += " WHERE VS6.VS6_FILIAL = '" + xFilial("VS6") + "'"
			cSQL +=   " AND VS6.VS6_DOC IN ('Ind-" + aVetTTP[nCntFor, ATT_NUMOSV] + "','Agr-" + aVetTTP[nCntFor, ATT_NUMOSV] + "')"
			cSQL +=   " AND VS6.VS6_TIPTEM = '" + aVetTTP[nCntFor, ATT_TIPTEM ] + "'"
			cSQL +=   " AND VS6.VS6_LIBVOO = '" + aVetTTP[nCntFor, ATT_LIBVOO] + "'"
			cSQL +=   " AND VS6.D_E_L_E_T_ = ' '"
			cSQL += " GROUP BY VS6.VS6_NUMIDE"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS7 , .F., .T. )
			
			While !(cAliasVS7)->(Eof())
				
				// Liberacao de Peca
				If (cAliasVS7)->PECA > 0
					aAuxProb[1,4] := (cAliasVS7)->VS6_NUMIDE
				EndIf
				
				// Liberacao de Servico
				If (cAliasVS7)->SRVC > 0
					aAuxProb[1,5] := (cAliasVS7)->VS6_NUMIDE
				EndIf
				
				(cAliasVS7)->(dbSkip())
			End
			(cAliasVS7)->(dbCloseArea())
			DbSelectArea("VS7")
			
			// Verifica se deve excluir alguma liberacao...
			// Quando ้ gerado separado, pode ser que seja necessario excluir umas das 2 liberacoes
			If aAuxProb[1,4] <> aAuxProb[1,5] .and. !Empty(aAuxProb[1,4]) .and. !Empty(aAuxProb[1,5])

				// Se tiver liberacao de peca e nao houver mais nenhuma peca com problema ...
				If ! Empty(aAuxProb[1,4]) .and. ! lProbPeca
					OX100DELLB(aAuxProb[1,4])
					aAuxProb[1,4] := "" // Limpa numero de Liberacao
					aAuxProb[1,6] := .f.  // Marca para nao ser alterado
				Endif

				// Se tiver liberacao de servico e nao houver mais nenhum servico com problema ...
				If ! Empty(aAuxProb[1,5]) .and. ! lProbSrvc
					OX100DELLB(aAuxProb[1,5])
					aAuxProb[1,5] := "" // Limpa numero de Liberacao
					aAuxProb[1,6] := .f.  // Marca para nao ser alterado
				EndIf

			EndIf
			//
			// Analisa se os valores da negociacao atual estao iguais aos valores gravados na liberacao
			If OX100LBALT( @aAuxProb , lGeraSep , @aDifNegoc , lProbPeca , lProbSrvc )
				
				If Aviso(STR0164+" "+aAuxProb[1,1],STR0157,{STR0165,STR0030},2) == 1
					
					aIntCab := {}
					aAdd(aIntCab,{ RetTitle("B1_GRUPO") , "C" , 20 , "@!" })
					aAdd(aIntCab,{ RetTitle("B1_CODITE"), "C" , 50 , "@!" })
					aAdd(aIntCab,{ STR0165              , "C" , 90 , "@!" }) // Alteracao
					aAdd(aIntCab,{ STR0158              , "C" , 90 , "@!" }) // De
					aAdd(aIntCab,{ STR0159              , "C" , 90 , "@!" }) // Para

					FGX_VISINT( aAuxProb[1,1] , STR0164 , aIntCab , aDifNegoc , .t. ) // Visualiza Diferen็as da Negocia็ใo

				EndIf

				lAltVS6 := .t.
				aEval( aAuxProb , {|x| AADD( aOSProb, aClone(x) ) } )

			// A negociacao se manteve igual ao gravado no pedido de liberacao
			Else

				If !Empty(aAuxProb[1,4])
					//lVS6JaGerada := .t.  // ATENCAO - variavel NรO PODE SER inicializada durante processamento ...
					OX1000043_VerLiberacaoVenda(aAuxProb[1,4], @lVS6Autorizado, aVetTTP[nCntFor])
				EndIf

				If ! Empty(aAuxProb[1,5]) .and. aAuxProb[1,4] <> aAuxProb[1,5]
					//lVS6JaGerada := .t.  // ATENCAO - variavel NรO PODE SER inicializada durante processamento ...
					OX1000043_VerLiberacaoVenda(aAuxProb[1,5], @lVS6Autorizado, aVetTTP[nCntFor])
				EndIf
				
			EndIf
			//
		EndIf
	Else
		aEval( aAuxProb , {|x| x[APROB_PROBLEMA_PECA] := lProbPeca } ) // Marca problema com pecas
		aEval( aAuxProb , {|x| x[APROB_PROBLEMA_SRVC] := lProbSrvc } ) // Marca problema com servicos
		aEval( aAuxProb , {|x| AADD( aOSProb, aClone(x) ) } )
	EndIf
	
Next nCntFor

If lTemProbDescMargem
	lVS6JaGerada := .t.
	For nCntFor := 1 to Len(aOSProb)
		If aOSProb[nCntFor, APROB_PROBLEMA_PECA] .AND. Empty(aOSProb[nCntFor, APROB_NUM_LIB_PECA])
			lVS6JaGerada := .f.
		EndIf
		If aOSProb[nCntFor, APROB_PROBLEMA_SRVC] .AND. Empty(aOSProb[nCntFor, APROB_NUM_LIB_SRVC])
			lVS6JaGerada := .f.
		EndIf
	Next nCntFor
EndIf

// MV_VMLOROF - Verifica margem de lucro na exporta็ใo do or็amento oficina
// MV_MIL0126 - Checa liberacao de desconto do orcamento no Fechamento de OS?
// Tenta liberar o fechamento da OS com base nas solicitacoes feitas nos or็amentos relacionados na ordem de Servico
If ! lVS6JaGerada .and. lTemProbDescMargem .and. (GetNewPar("MV_VMLOROF","N") == "S") .and. (GetNewPar("MV_MIL0126","N") == "S")
	if OX1000035_ValidaSolicitacaoLiberacaoDesconto(aOSProb) //Libera็ใo de desconto com base nos or็amentos
		MsgInfo(STR0168,STR0004) // "Venda liberada com base nas aprova็๕es de desconto nos or็amentos vinculados a esta ordem de servi็o." //"Aten็ใo"
		Return .t.
	EndIf
EndIf
//

// (Nao existe problema de Desconto / Margem ou Venda Autorizada) e Nao houve altera็ใo da Negociacao 
If (! lTemProbDescMargem .or. (lVS6JaGerada .and. lTemProbDescMargem .and. lVS6Autorizado)) .and. ! lAltVS6
	lRetorno := .t. 

// Se tiver algum problema ...
Else
	If lGeraLib
		lRetorno := .f.

		If lAltVS6
			lGeraLib := .t.
		ElseIf lVS6JaGerada
			lGeraLib := .f.
		ElseIf  Aviso(STR0004,STR0036,{STR0037,STR0038},2) == 1 // "Existem itens com margem/desconto nใo permitido!" - "&Cancela" - "&Pede Lib."
			lGeraLib := .f.
		EndIf

		If lGeraLib
			// Gera Liberacao de Desconto
			OX100GERLB(aOSProb, lGeraSep)
			If ExistBlock("OX100GLB")
				If ExecBlock("OX100GLB")
					lRetorno := OX100LBDES(.f.)
				EndIf
			EndIf
		EndIf
	Else
		lRetorno := .f.
	EndIf
EndIf
//

RestArea( oArea )

Return lRetorno


/*/{Protheus.doc} OX1000043_VerLiberacaoVenda
Verifica se a Venda foi liberada 

@author rubens.takahashi
@since 09/09/2019
@version 1.0
@return ${return}, ${return_description}
@param cNumLib, characters, description
@param lVS6Autorizado, logical, description
@param aAuxVetTTP, array, description
@type function
/*/
Static Function OX1000043_VerLiberacaoVenda(cNumLib, lVS6Autorizado, aAuxVetTTP)

	Local cSQL
	Local lMsgInfo := ""
	Local lMsgCab := STR0004

	cSQL := "SELECT VS6_DATAUT"
	cSQL +=  " FROM " + RetSQLName("VS6") + " VS6"
	cSQL += " WHERE VS6_FILIAL = '" + xFilial("VS6") + "'"
	cSQL +=   " AND VS6_NUMIDE = '" + cNumLib + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	
	cAuxDatAut := FM_SQL( cSQL )
	If Empty(cAuxDatAut)
		If VS6->(FieldPos("VS6_DATREJ")) > 0

			cSQL := "SELECT  R_E_C_N_O_  VS6RECNO"
			cSQL +=  " FROM " + RetSQLName("VS6") + " VS6"
			cSQL += " WHERE VS6_FILIAL = '" + xFilial("VS6") + "'"
			cSQL +=   " AND VS6_NUMIDE = '" + cNumLib + "'"
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			VS6->(DbGoto(FM_SQL( cSQL )))
			If ! Empty(VS6->VS6_DATREJ)

				lMsgInfo := STR0149 + CRLF + CRLF + ;
					VS6->VS6_MOTREJ + " - " + POSICIONE("VS0",1,xFilial("VS0")+"000016"+VS6->VS6_MOTREJ,"VS0_DESMOT")

				lVS6Autorizado := .f.
			Else

				lMsgInfo := STR0041
				lVS6Autorizado := .f.
			Endif
		Else
			lMsgInfo := STR0041 //"Venda ainda nao Liberada...","Atencao!")
			lVS6Autorizado := .f.
		Endif
	Else
		lMsgInfo := STR0042 //"Venda Liberada...","Ok"
		lMsgCab := STR0030
	EndIf

	If ! Empty(lMsgInfo)
		MsgInfo( lMsgInfo + CRLF + CRLF + ;
			RetTitle("VS6_NUMIDE") + ": " + cNumLib + CRLF + CRLF + ;
			RetTitle("VO1_NUMOSV") + ": " + aAuxVetTTP[ATT_NUMOSV] + CRLF + ;
			RetTitle("VO3_TIPTEM") + ": " + aAuxVetTTP[ATT_TIPTEM] + CRLF + ; 
			RetTitle("VOO_LIBVOO") + ": " + aAuxVetTTP[ATT_LIBVOO] , lMsgCab )
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100CKDES   บAutor  ณ Takahashi      บ Data ณ  27/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica desconto                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da Ordem de Servico                       บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑบ          ณ lHlp = Sera exibida uma HELP quando ha problema de descontoบฑฑ
ฑฑบ          ณ cCliente = Cliente                                         บฑฑ
ฑฑบ          ณ cLoja = Loja                                               บฑฑ
ฑฑบ          ณ cLibVOO = Numero da Liberacao do Tipo de Tempo             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Array com o Numero da OS e a Linha das Matrizes auxiliares บฑฑ
ฑฑบ          ณ de Pecas (aAuxVO3) e Servicos (aAuxVO4) que estใo com      บฑฑ
ฑฑบ          ณ problema de Descontos                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100CKDES(cNumOsv, cTipTem, lHlp, cCliente, cLoja, cLibVOO)
Local DVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Det")
Local DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")
Local DVO3QTDREQ := FG_POSVAR("VO3_QTDREQ","aHVO3Det")
Local DVO3VALPEC := FG_POSVAR("VO3_VALPEC","aHVO3Det")
Local DVO3PERDES := FG_POSVAR("VO3_PERDES","aHVO3Det")
Local DVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Det")
Local DVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Det")
Local DVO3LOTECT := FG_POSVAR("VO3_LOTECT","aHVO3Det")
Local DVO3NUMLOT := FG_POSVAR("VO3_NUMLOT","aHVO3Det")
Local DVO3MARLUC := FG_POSVAR("VO3_MARLUC","aHVO3Det")
Local DSEQFEC    := FG_POSVAR("SEQFEC","aHVO3Det")

Local nCntFor, nCntFor2, nPecSer
Local lDescMargPermitido
Local aAuxProb := {}  // Array com pecas / servicos com problemas
Local nPosProb := 0
Local nPecSom  := 0

Local lVS7SemProb := AllTrim(GetNewPar("MV_MIL0131", "0")) == "1" // Cria/Mostra VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto

Local cForPecOfi  := AllTrim(GetNewPar("MV_MIL0056", ""))

Local lConMrgLuc := OX100MRGLC(cNumOsv, cTipTem) // Considera ou nใo Margem de Lucro

Local lFazPergunta := .t. // utilizado na chamada da tela que permitir apresentar mensagem de Desconto/Margem apenas para um item
//
// Analisa descontos de pecas
For nPecSer := 1 to Len(aAuxVO3)
	If aAuxVO3[ nPecSer, AP_NUMOSV ] <> cNumOsv .or. aAuxVO3[ nPecSer, AP_TIPTEM ] <> cTipTem .or. aAuxVO3[ nPecSer, AP_LIBVOO ] <> cLibVOO
		Loop
	EndIf
	
	nPecSom := aScan( aPecSom, { |x| ;
		x[1] == cNumOsv .and.;
		x[2] == cTipTem .and.;
		x[3] == cLibVOO .and.;
		x[4] == aAuxVO3[nPecSer, AP_GRUITE ] .and. ;
		x[5] == aAuxVO3[nPecSer, AP_CODITE] .and. ;
		x[12] == aAuxVO3[nPecSer, AP_SEQFEC] .and. ;
		x[13] == aAuxVO3[nPecSer, AP_LOTECT ] .and. ;
		x[14] == aAuxVO3[nPecSer, AP_NUMLOT] } )
	
	If nPecSom <= 0
		
		aAdd(aPecSom,{ cNumOsv, ;								// 01 -
							cTipTem, ;								// 02 -
							cLibVOO, ;								// 03 -
							aAuxVO3[nPecSer, AP_GRUITE ],;	// 04 -
							aAuxVO3[nPecSer, AP_CODITE ],;	// 05 -
							0 , ;										// 06 - DVO3QTDREQ
							0 , ;										// 07 - DVO3PERDES
							0 , ;										// 08 - DVO3VALDES
							0 , ;										// 09 - DVO3VALBRU
							0 , ;										// 10 - DVO3VALPEC
							0 , ;										// 11 - DVO3MARLUC
							0 , ;										// 12 - DSEQFEC
							aAuxVO3[nPecSer, AP_LOTECT] , ;				// 13
							aAuxVO3[nPecSer, AP_NUMLOT] } )				// 14
		
		nPecSom := len(aPecSom)
		
		// Posicionar no aCols Detalhado de Pecas para trazer a Qtd, % e Vlr de desconto
		nPos := aScan( oGetDetVO3:aCols, { |x| x[DVO3TIPTEM] == cTipTem .and.;
															x[DVO3GRUITE] == aAuxVO3[nPecSer, AP_GRUITE ] .and.;
															x[DVO3CODITE] == aAuxVO3[nPecSer, AP_CODITE ] .and.;
															( !lCtrlLote .or. ( x[DVO3LOTECT] == aAuxVO3[nPecSer, AP_LOTECT] .and.;
															x[DVO3NUMLOT] == aAuxVO3[nPecSer, AP_NUMLOT] .and. ;
															x[DSEQFEC] == aAuxVO3[nPecSer, AP_SEQFEC] ) ) } )
		
		If nPos > 0
			//
			aPecSom[nPecSom,6]  := oGetDetVO3:aCols[nPos, DVO3QTDREQ]
			aPecSom[nPecSom,7]  := oGetDetVO3:aCols[nPos, DVO3PERDES]
			aPecSom[nPecSom,8]  := oGetDetVO3:aCols[nPos, DVO3VALDES]
			aPecSom[nPecSom,9]  := oGetDetVO3:aCols[nPos, DVO3VALBRU]
			aPecSom[nPecSom,10] := oGetDetVO3:aCols[nPos, DVO3VALPEC]
			aPecSom[nPecSom,11] := oGetDetVO3:aCols[nPos, DVO3MARLUC]
			aPecSom[nPecSom,12] := oGetDetVO3:aCols[nPos, DSEQFEC]
			//
			FG_MEMVAR( oGetDetVO3:aHeader, oGetDetVO3:aCols, nPos ) // Carregar M->VO3_ para utilizar na Formula da Margem			//
			//
		EndIf
		
		/* --------------------------------------------
		Conforme CI 007720 (337), foi analisado e decidido que a Marca da Pe็a deve ser diretamente
		comparada com a Marca do Grupo de Desconto ao inv้s da Marca do Veํculo (Chassi).
		-------------------------------------------- */
		// VO1->VO1_CODMAR
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek( xFilial("SBM") + aAuxVO3[nPecSer, AP_GRUITE ] ))
		SB1->(dbSetOrder(7))
		SB1->(DbSeek( xFilial("SB1") + aAuxVO3[nPecSer, AP_GRUITE ] + aAuxVO3[nPecSer, AP_CODITE ] ))
		SB1->(dbSetOrder(1))
		SB2->(DbSetOrder(1))
		SB2->(DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
		//
		If lConMrgLuc // Considera Desconto e Margem
			//
			OX100PECFIS(nPos) // posiciona para se usar os impostos
			//
			lDescMargPermitido := OX005PERDES( SBM->BM_CODMAR,;
											VAI->VAI_CC,;
											aAuxVO3[nPecSer, AP_GRUITE ],;
											aAuxVO3[nPecSer, AP_CODITE ],;
											aPecSom[nPecSom, 6],;
											aPecSom[nPecSom, 7],;
											lHlp,;
											cCliente,;
											cLoja,;
											"3",; // 1 = Varejo / 2 = Atacado / 3 = Oficina / 4 = Todos
											( aPecSom[nPecSom, 9] - aPecSom[nPecSom, 8] ) / aPecSom[nPecSom, 6],;
											1,;
											M->VOO_CONDPG,;
											cForPecOfi,;
											.t.,;
											.t. )
			//
			OX100FISPEC(oGetDetVO3:nAt)
			//
			If ! lDescMargPermitido
				If lHlp .and. lFazPergunta
					lFazPergunta := .f.
 					If ! MsgYesNo(STR0167,STR0004) // "Deseja exibir mensagem para cada item com desconto/margem al้m do permitido?"
						lHlp := .f.
					Endif
				Endif
			Endif
			//
			// Precisa criar o AAuxProb com todos os Itens para atender o Parโmetro que cria todos VS7 (inclusive os que nใo tem Problema)
			// Caso nenhum tenha problema, a Cria็ใo da Libera็ใo nใo ocorrerแ
			//
			If ! lDescMargPermitido .or. (lDescMargPermitido .and. lVS7SemProb)
				nPosProb := aScan( aAuxProb, { |x| x[1] == cNumOsv .and. x[8] == cTipTem .and. x[9] == cLibVOO } )
				If nPosProb == 0
					nPosProb := OX1000053_AddAuxProb(cNumOsv, cTipTem, cLibVOO, @aAuxProb)
				EndIf
				aAuxProb[nPosProb, APROB_TEM_PECA] := .t.
				AADD( aAuxProb[nPosProb, APROB_LISTA_PECA], { nPecSom , lDescMargPermitido } )
			EndIf
			//
		EndIf
		//
	EndIf
	//
Next nPecSer

// Analisa descontos de servicos
For nPecSer := 1 to Len(aAuxVO4)

	If aAuxVO4[ nPecSer, AS_NUMOSV ] <> cNumOsv .or. aAuxVO4[ nPecSer, AS_TIPTEM ] <> cTipTem .or. aAuxVO4[ nPecSer, AS_LIBVOO ] <> cLibVOO
		Loop
	EndIf
	
	VOK->(dbSetOrder(1))
	VOK->(dbSeek(xFilial("VOK") + aAuxVO4[ nPecSer, AS_TIPSER ] ))
	
	// Mao de Obra Gratuita
	If VOK->VOK_INCMOB == "0"
		Loop
	EndIf
	
	lDescMargPermitido := ( VOK->VOK_PERMAX >= aAuxVO4[ nPecSer, AS_PERDES ] )
	If ! lDescMargPermitido
		nPosProb := aScan( aAuxProb, { |x| x[1] == cNumOsv .and. x[8] == cTipTem .and. x[9] == cLibVOO } )
		If nPosProb == 0
			nPosProb := OX1000053_AddAuxProb(cNumOsv, cTipTem, cLibVOO, @aAuxProb)
		EndIf
		
		aAuxProb[nPosProb, APROB_TEM_SRVC] := .t.
		AADD( aAuxProb[nPosProb, APROB_LISTA_SRVC], { nPecSer , lDescMargPermitido} )

	Endif

Next nPecSer

Return aClone(aAuxProb)

/*/{Protheus.doc} OX1000053_AddAuxProb
Adiciona uma linha na matriz de problema de Desconto / Margem de Lucro de Peca ou Servico
@author rubens.takahashi
@since 09/09/2019
@version 1.0
@return ${return}, ${return_description}
@param cNumOsv, characters, description
@param cTipTem, characters, description
@param cLibVOO, characters, description
@param aAuxProb, array, description
@type function
/*/
Static Function OX1000053_AddAuxProb(cNumOsv, cTipTem, cLibVOO, aAuxProb)

	AADD( aAuxProb, {;
		cNumOsv,;                            // APROB_NUMOSV        - 01 - Numero da Ordem de Servico
		{} /* Pecas */,;                     // APROB_LISTA_PECA    - 02 - Lista de Pecas Processadas
		{} /* Servicos */,;                  // APROB_LISTA_SRVC    - 03 - Lista de Servicos Processados
		"" /* Num. Liberacao Peca/Geral */,; // APROB_NUM_LIB_PECA  - 04 - Numero da Liberacao de Pecas (VS6)
		"" /* Num. Liberacao Servico */,;    // APROB_NUM_LIB_SRVC  - 05 - Numero da Liberacao de Servicos (VS6)
		.f.,;                                // APROB_PROBLEMA_PECA - 06 - Indica se tem problema de Pecas
		.f.,;                                // APROB_PROBLEMA_SRVC - 07 - Indica se tem problema de Servi็os
		cTipTem,;                            // APROB_TIPTEM        - 08 - Tipo de tempo
		cLibVOO,;                            // APROB_LIBVOO        - 09 - Liberacao VOO
		.f. ,;                               // APROB_TEM_PECA      - 10 - Indica se tem pecas para este tipo de tempo
		.f. } )                              // APROB_TEM_SRVC      - 11 - Indica se tem servicos para este tipo de tempo

Return Len(aAuxProb)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100LBALT   บAutor  ณ Takahashi      บ Data ณ  29/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se ้ necessario alterar liberacao, comparando a   บฑฑ
ฑฑบ          ณ negociacao atual com os valores do pedido de liberacao     บฑฑ
ฑฑบ          ณ gravados anteriormente                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aAuxProb = Array com as OS's e Pecas/Servicos com problema บฑฑ
ฑฑบ          ณ            de Desconto                                     บฑฑ
ฑฑบ          ณ lGeraSep = Gera Liberacao Separada?                        บฑฑ
ฑฑบ          ณ aDifNegoc = Array com as Pe็as com diferenca na Negociacao บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100LBALT(aAuxProb, lGeraSep , aDifNegoc , lProbPeca , lProbSrvc )

Local lRetorno := .f.
Local nCntFor, nCntFor2
Local nPecSer
Local cSQL
Local cAliasVS7 := "TVS7"
Local oArea := GetArea()
Local nPecSom
Local lVS7SemProb := AllTrim(GetNewPar("MV_MIL0131", "0")) == "1" // Cria/Mostra VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto
Local nValDesAPecSom := 0
Default aDifNegoc := {}


For nCntFor := 1 to Len(aAuxProb)
	
	// Existe liberacao para a Peca, mas nao existe problema com a Peca
	If ! Empty(aAuxProb[nCntFor,4]) .and. ! lProbPeca
		lRetorno := .t.
		aAuxProb[nCntFor,6] := .t.
	EndIf
	
	// Existe liberacao para o Servico, mas nao existe problema com o Servico
	If ! Empty(aAuxProb[nCntFor,5]) .and. ! lProbSrvc
		lRetorno := .t.
		aAuxProb[nCntFor,7] := .t.
	EndIf
	
	// Se ainda nao tiver problema e gerar somente 1 liberacao, acerta o numero da liberacao na matriz
	If ! lGeraSep
		If Empty(aAuxProb[nCntFor ,4]) .AND. aAuxProb[nCntFor , APROB_TEM_PECA]
			aAuxProb[nCntFor ,4] := aAuxProb[nCntFor ,5]
		EndIf
		If Empty(aAuxProb[nCntFor ,5]) .and. aAuxProb[nCntFor , APROB_TEM_SRVC]
			aAuxProb[nCntFor ,5] := aAuxProb[nCntFor ,4]
		EndIf
	EndIf
	
	// Analisa Pecas ...
	For nCntFor2 := 1 to Len(aAuxProb[nCntFor,2])

		// Se a peca nao tem problema e o parametro esta configurado para NรO gerar VS7 de itens sem problema
		If aAuxProb[nCntFor,2,nCntFor2,2] .and. ! lVS7SemProb
			Loop
		EndIf
		
		nPecSom := aAuxProb[nCntFor,2,nCntFor2,1]
		
		cSQL := "SELECT VS7_DESDES , VS7_VALDES, VS7_QTDITE , VS7_MARLUC "
		cSQL +=  " FROM " + RetSQLName("VS7")
		cSQL +=  " WHERE VS7_FILIAL = '" + xFilial("VS7") + "'"
		cSQL +=    " AND VS7_NUMIDE = '" + aAuxProb[nCntFor,4] + "'"
		cSQL +=    " AND VS7_GRUITE = '" + aPecSom[nPecSom,4] + "'"
		cSQL +=    " AND VS7_CODITE = '" + aPecSom[nPecSom,5] + "'"

		If lVS7LOTECT
			cSQL +=    " AND VS7_LOTECT = '" + aPecSom[nPecSom,13] + "'"
			cSQL +=    " AND VS7_NUMLOT = '" + aPecSom[nPecSom,14] + "'"
		EndIf

		cSQL +=    " AND VS7_VALORI = " + Alltrim(str(aPecSom[nPecSom,10]))
		cSQL +=    " AND VS7_TIPAUT = '1'" // Pecas
		cSQL +=    " AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS7 , .F., .T. )
		If !(cAliasVS7)->(Eof())

			nValDesAPecSom := A410Arred(aPecSom[nPecSom,10] - ( aPecSom[nPecSom,8] / aPecSom[nPecSom,6] ),"VS7_VALDES")

			If (cAliasVS7)->VS7_VALDES <> nValDesAPecSom ;
				.OR. (cAliasVS7)->VS7_DESDES <> aPecSom[nPecSom,7] ;
				.OR. (cAliasVS7)->VS7_QTDITE <> aPecSom[nPecSom,6] ;
				.OR. (cAliasVS7)->VS7_MARLUC <> aPecSom[nPecSom,11]
				//
				If (cAliasVS7)->VS7_VALDES <> nValDesAPecSom // "Valor Desejado"
					aAdd(aDifNegoc,{	aPecSom[nPecSom,4] , aPecSom[nPecSom,5] ,;
											STR0160 ,;
											Alltrim(Transform( (cAliasVS7)->VS7_VALDES , x3Picture("VS7_VALDES") )) ,;
											Alltrim(Transform( nValDesAPecSom , x3Picture("VS7_VALDES") )) ,;
											aPecSom[nPecSom,13] ,;
											aPecSom[nPecSom,14] })
				EndIf
				If (cAliasVS7)->VS7_DESDES <> aPecSom[nPecSom,7] // "Desconto Desejado"
					aAdd(aDifNegoc,{	aPecSom[nPecSom,4] , aPecSom[nPecSom,5] ,;
											STR0161 ,;
											Alltrim(Transform( (cAliasVS7)->VS7_DESDES , x3Picture("VS7_DESDES") )) ,;
											Alltrim(Transform( aPecSom[nPecSom,7] , x3Picture("VS7_DESDES") )) ,;
											aPecSom[nPecSom,13] ,;
											aPecSom[nPecSom,14] })
				EndIf
				If (cAliasVS7)->VS7_QTDITE <> aPecSom[nPecSom,6] // "Quantidade"
					aAdd(aDifNegoc,{	aPecSom[nPecSom,4] , aPecSom[nPecSom,5] ,;
											STR0162 ,;
											Alltrim(Transform( (cAliasVS7)->VS7_QTDITE , x3Picture("VS7_QTDITE") )) ,;
											Alltrim(Transform( aPecSom[nPecSom,6] , x3Picture("VS7_QTDITE") )) ,;
											aPecSom[nPecSom,13] ,;
											aPecSom[nPecSom,14] })
				EndIf
				If (cAliasVS7)->VS7_MARLUC <> aPecSom[nPecSom,11] // "Margem de Lucro"
					aAdd(aDifNegoc,{	aPecSom[nPecSom,4] , aPecSom[nPecSom,5] ,;
											STR0163 ,;
											Alltrim(Transform( (cAliasVS7)->VS7_MARLUC, x3Picture("VS7_MARLUC") )) ,;
											Alltrim(Transform( aPecSom[nPecSom,11] , x3Picture("VS7_MARLUC") )) ,;
											aPecSom[nPecSom,13] ,;
											aPecSom[nPecSom,14] })
				EndIf
				//
				lRetorno := .t. // Houve alteracao na negociacao atual
				aAuxProb[nCntFor,6] := .t.
				//
			EndIf
		Else
			lRetorno := .t. // Nao encontrou o registro na VS7
			aAuxProb[nCntFor,6] := .t.
		EndIf
		
		(cAliasVS7)->(dbCloseArea())
		DbSelectArea("VS7")
		
	Next nCntFor2
	
	// Analisa Servicos ...
	For nCntFor2 := 1 to Len(aAuxProb[nCntFor,3])

		// Se o servico tem problema e o parametro esta configurado para NรO gerar VS7 de itens sem problema
		If aAuxProb[nCntFor,3,nCntFor2,2] .and. ! lVS7SemProb
			Loop
		EndIf
		
		nPecSer := aAuxProb[nCntFor,3,nCntFor2,1]
		
		cSQL := "SELECT VS7_DESDES , VS7_VALDES"
		cSQL +=  " FROM " + RetSQLName("VS7")
		cSQL +=  " WHERE VS7_FILIAL = '" + xFilial("VS7") + "'"
		cSQL +=    " AND VS7_NUMIDE = '" + aAuxProb[nCntFor,5] + "'"
		cSQL +=    " AND VS7_GRUSER = '" + aAuxVO4[ nPecSer, AS_GRUSER ] + "'"
		cSQL +=    " AND VS7_CODSER = '" + aAuxVO4[ nPecSer, AS_CODSER ] + "'"
		cSQL +=    " AND VS7_TIPAUT = '2'" // Servicos
		cSQL +=    " AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS7 , .F., .T. )
		If !(cAliasVS7)->(Eof())

			If (cAliasVS7)->VS7_VALDES <> ( aAuxVO4[ nPecSer, AS_VALBRU ] - aAuxVO4[ nPecSer, AS_VALDES ] ) ;
				.OR. (cAliasVS7)->VS7_DESDES <> aAuxVO4[ nPecSer, AS_PERDES ]
				
				lRetorno := .t. // Houve alteracao na negociacao atual
				aAuxProb[nCntFor,7] := .t.
				
			EndIf
		Else
			lRetorno := .t. // Nao encontrou o registro na VS7
			aAuxProb[nCntFor,7] := .t.
		EndIf
		
		(cAliasVS7)->(dbCloseArea())
		DbSelectArea("VS7")
		
	Next nCntFor2
	
Next nCntFor

RestArea( oArea )

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100GERLB   บAutor  ณ Takahashi      บ Data ณ  27/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera Liberacao de Desconto                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aAuxProb = Array com as OS's e Pecas/Servicos com problema บฑฑ
ฑฑบ          ณ            de Desconto                                     บฑฑ
ฑฑบ          ณ lGeraSep = Indica se deve gerar liberacao separada         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100GERLB(aAuxProb, lGeraSep)
Local nCntFor, nCntFor2
Local aRetDes
Local lConfLib, oFonteVS6, cObservVS6
Local lFecAgru    := .f. // Indica se ้ fechamento agrupado
Local cSQL        := ""
Local cAliasVS7   := "TVS7"
Local nRecVS7     := 0
Local cForPecOfi  := AllTrim(GetNewPar("MV_MIL0056", ""))
Local nPosVetTTP  := 0
Local nPos        := 0
Local DSEQFEC     := FG_POSVAR("SEQFEC","aHVO3Det")

Local aVS7RecAtu  := {}  // Contem os Recno (VS7) ja gravados
Local aVS7RecAlt  := {}  // Contem os Recno (VS7) novos/alterados
Local lVS7DIVERG  := VS7->(FieldPos("VS7_DIVERG")) > 0
Local lVS7SemProb := AllTrim(GetNewPar("MV_MIL0131", "0")) == "1" // Cria/Mostra VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto

Private aSeqItVS7 := {} // Controla o Numero sequencia do VS7

lConfLib    := .f.
oFonteVS6   := TFont():New( "Arial", 8, 14 )
cObservVS6  := space(TamSx3("VS6_OBSERV")[1])

DEFINE MSDIALOG oDlgVS6 TITLE STR0039 FROM 02,04 TO 14,56 OF oMainWnd // Pedido de Libera็ใo de Venda

DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (lConfLib := .t., oDlgVS6:End()) ENABLE OF oDlgVS6
DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (lConfLib := .f., oDlgVS6:End()) ENABLE OF oDlgVS6

@ 01,011 GET oObserv VAR cObservVS6 OF oDlgVS6 MEMO SIZE 182,67 PIXEL

oObserv:oFont := oFonteVS6
oObserv:bRClicked := {|| AllwaysTrue() }
oObserv:SetFocus()

ACTIVATE MSDIALOG oDlgVS6 CENTER

If !lConfLib
	return
EndIf

// Verifica se ้ fechamento agrupado
nCntFor  := 0

aEval(aVetTTP, {|x| Iif(x[ATT_VETSEL], nCntFor++, NIL) } )

lFecAgru := (nCntFor > 1)

Begin Transaction

For nCntFor := 1 to Len(aAuxProb)

	// Verifica se eh necessario alterar liberacao de pecas / servicos ...
	If ! aAuxProb[nCntFor, 6] .and. ! aAuxProb[nCntFor, 7]
		Loop
	EndIf
	
	aVS7RecAtu := {}
	aVS7RecAlt := {}
	
	nPosVetTTP := aScan( aVetTTP, { |x| x[ATT_NUMOSV] == aAuxProb[nCntFor, 1] .and.;
													x[ATT_TIPTEM] == aAuxProb[nCntFor, 8] .and. ;
													x[ATT_LIBVOO] == aAuxProb[nCntFor, 9] } )
	If nPosVetTTP == 0
		Help(" ", 1, "OX100GLBV")
		Return
	EndIf
	
	VO1->(dbSetOrder(1))
	VO1->(dbSeek( xFilial("VO1") + aVetTTP[nPosVetTTP, ATT_NUMOSV] ))
	
	// Gera uma liberacao so, com pecas e servicos ...
	If ! lGeraSep
		If Empty(aAuxProb[nCntFor, 4]) .and. Empty(aAuxProb[nCntFor, 5])
			// Cria uma liberacao nova ...
			aAuxProb[nCntFor, 4] := OX100NCBLB( lFecAgru,;
															aVetTTP[nPosVetTTP, ATT_NUMOSV ],;
															aVetTTP[nPosVetTTP, ATT_CLIENTE ],;
															aVetTTP[nPosVetTTP, ATT_LOJA ],;
															aVetTTP[nPosVetTTP, ATT_TIPTEM ],;
															cObservVS6,;
															aVetTTP[nPosVetTTP, ATT_LIBVOO ] )
															aAuxProb[nCntFor, 5] := aAuxProb[nCntFor, 4]
		Else
			// Altera o Cabecalho da Liberacao ...
			OX100ACBLB( aAuxProb[nCntFor, 4], cObservVS6, @aVS7RecAtu )
		EndIf
		
	// Gera liberacao separada para pecas e servicos
	Else
		// Existe problema de Desconto com Pecas ...
		If aAuxProb[nCntFor, 6]
			// Cria liberacao nova para PECAS
			If Empty(aAuxProb[nCntFor, 4])
				aAuxProb[nCntFor, 4] := OX100NCBLB( lFecAgru,;
																aVetTTP[nPosVetTTP, ATT_NUMOSV ],;
																aVetTTP[nPosVetTTP, ATT_CLIENTE ],;
																aVetTTP[nPosVetTTP, ATT_LOJA ],;
																aVetTTP[nPosVetTTP, ATT_TIPTEM ],;
																cObservVS6,;
																aVetTTP[nPosVetTTP, ATT_LIBVOO ] )
			Else
				// Altera Cabecalho da Liberacao ...
				OX100ACBLB( aAuxProb[nCntFor, 4], cObservVS6, @aVS7RecAtu )
			EndIf
		EndIf
		
		// Existe problema de Desconto com Servicos ...
		If aAuxProb[nCntFor, 7]
			// Cria liberacao nova para SERVICOS
			If Empty(aAuxProb[nCntFor, 5])
				aAuxProb[nCntFor, 5] := OX100NCBLB( lFecAgru,;
																aVetTTP[nPosVetTTP, ATT_NUMOSV ],;
																aVetTTP[nPosVetTTP, ATT_CLIENTE ],;
																aVetTTP[nPosVetTTP, ATT_LOJA ],;
																aVetTTP[nPosVetTTP, ATT_TIPTEM ],;
																cObservVS6,;
																aVetTTP[nPosVetTTP, ATT_LIBVOO ] )
			// Altera Cabecalho da Liberacao ...
			Else
				OX100ACBLB( aAuxProb[nCntFor, 5], cObservVS6, @aVS7RecAtu )
			EndIf
		EndIf
	EndIf
	
	// Liberacao de Pecas ...
	If aAuxProb[nCntFor, 6]
		
		For nCntFor2 := 1 to Len(aAuxProb[nCntFor, 2])

			// Posicao da Matriz aAuxVO3 com problema de desconto
			nPecSom := aAuxProb[nCntFor, 2, nCntFor2,1]
			
			// Se o Parametro MV_MIL00131 estiver DESATIVADO, nใo ้ criado VS7 dos Itens que nใo tiverem problema
			If ! lVS7SemProb .and. aAuxProb[nCntFor, 2, nCntFor2, 2] // O parโmetro estแ desativado e o item nใo tem problema de Margem ou Desconto
				Loop
			Endif
			
			/* --------------------------------------------
			Conforme CI 007720 (337), foi analisado e decidido que a Marca da Pe็a deve ser diretamente
			comparada com a Marca do Grupo de Desconto ao inv้s da Marca do Veํculo (Chassi).
			-------------------------------------------- */
			// VO1->VO1_CODMAR
			
			SBM->(dbSetOrder(1))
			SBM->(dbSeek( xFilial("SBM") + aPecSom[nPecSom, 4] ))
			//
			SB1->(dbSetOrder(7))
			SB1->(DbSeek( xFilial("SB1") + aPecSom[nPecSom, 4] + aPecSom[nPecSom, 5] ))
			SB1->(dbSetOrder(1))
			SB2->(DbSetOrder(1))
			SB2->(DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
			//
			nPos := aScan( oGetDetVO3:aCols, { |x| x[DSEQFEC] == aPecSom[nPecSom, 12] } )
			If nPos > 0
				FG_MEMVAR( oGetDetVO3:aHeader, oGetDetVO3:aCols, nPos ) // Carregar M->VO3_ para utilizar na Formula da Margem Lucro
			EndIf
			OX100PECFIS(nPos) // posiciona para se usar os impostos

			aRetDes := OX005PERDES( SBM->BM_CODMAR,;
											VAI->VAI_CC,;
											aPecSom[nPecSom, 4],;
											aPecSom[nPecSom, 5],;
											aPecSom[nPecSom, 6],;
											aPecSom[nPecSom, 7],;
											.f.,;
											aVetTTP[nPosVetTTP, ATT_CLIENTE ],;
											aVetTTP[nPosVetTTP, ATT_LOJA ],;
											"3",;
											( aPecSom[nPecSom, 9] - aPecSom[nPecSom, 8] ) / aPecSom[nPecSom, 6],;
											4,;
											M->VOO_CONDPG,;
											cForPecOfi,;
											.t. ,;
											.t. )
			
			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "FROM " + RetSQLName("VS7") + " "
			cSQL += "WHERE VS7_FILIAL = '" + xFilial("VS7") + "' "
			cSQL += "  AND VS7_NUMIDE = '" + aAuxProb[nCntFor, 4] + "' "
			cSQL += "  AND VS7_GRUITE = '" + aPecSom[nPecSom, 4] + "' "
			cSQL += "  AND VS7_CODITE = '" + aPecSom[nPecSom, 5] + "' "

			If lVS7LOTECT
				cSQL += "  AND VS7_LOTECT = '" + aPecSom[nPecSom,13] + "' "
				cSQL += "  AND VS7_NUMLOT = '" + aPecSom[nPecSom,14] + "' "
			EndIf

			cSQL += "  AND VS7_VALORI = " + Alltrim(str(aPecSom[nPecSom,10]))
			cSQL += "  AND VS7_TIPAUT = '1' " // Pecas
			cSQL += "  AND D_E_L_E_T_ = ' '"
			nRecVS7 := FM_SQL(cSQL)
			
			dbSelectArea("VS7")
			
			If nRecVS7 <> 0
				AADD( aVS7RecAlt, nRecVS7 ) // Adiciona na array utilizada posteriormente para definir os registros que foram alterados
				
				dbGoTo( nRecVS7 )
				
				RecLock("VS7", .f.)
			Else
				RecLock("VS7", .t.)
				
				VS7->VS7_FILIAL := xFilial("VS7")
				VS7->VS7_NUMIDE := aAuxProb[nCntFor, 4]
				VS7->VS7_SEQUEN := Strzero(OX100SQVS7( aAuxProb[nCntFor, 4] ), 4)
				VS7->VS7_TIPAUT := "1"                // Peca
				VS7->VS7_GRUITE := aPecSom[nPecSom, 4]
				VS7->VS7_CODITE := aPecSom[nPecSom, 5]
			EndIf
			
			VS7->VS7_DESPER := aRetDes[2]             // Desconto Permitido
			VS7->VS7_DESDES := aPecSom[nPecSom, 7]    // Desconto Desejado
			VS7->VS7_VALORI := aPecSom[nPecSom, 10]   // Valor Original
			
			VS7->VS7_VALPER := ( (1 - aRetDes[2] / 100) * aPecSom[nPecSom, 10] ) // Valor Permitido
			
			VS7->VS7_VALDES := A410Arred(aPecSom[nPecSom, 10] - ( aPecSom[nPecSom, 8] / aPecSom[nPecSom, 6] ), "VS7_VALDES") // Valor Desejado
			
			VS7->VS7_MARPER := aRetDes[3]
			//VS7->VS7_MARLUC := OX100FmlDef() // Retorna o % da Margem Lucro Oficina
			VS7->VS7_MARLUC := M->VO3_MARLUC // Retorna o % da Margem Lucro Oficina
			VS7->VS7_QTDITE := aPecSom[nPecSom, 6]
			If lVS7DIVERG
				VS7->VS7_DIVERG := IIf(aAuxProb[nCntFor, 2,nCntFor2,2],"0","1") // Se o elemento do Array estiver com .T. ้ porque nใo houve Divergencia de Desconto ou Margem
			Endif

			If lVS7LOTECT
				VS7->VS7_LOTECT := aPecSom[nPecSom,13]
				VS7->VS7_NUMLOT := aPecSom[nPecSom,14]
			EndIf

			VS7->(MsUnlock())
		Next nCntFor2

	Else
		// Adiciona os registro de liberacao de pecas na matriz aVS7RecAtu , para
		// que no final os registros NAO sejam excluidos
		cSQL := "SELECT R_E_C_N_O_ NRECNO "
		cSQL += "FROM " + RetSQLName("VS7") +" "
		cSQL += "WHERE VS7_FILIAL = '" + xFilial("VS7") + "' "
		cSQL += "  AND VS7_NUMIDE = '" + aAuxProb[nCntFor, 4] + "' "
		cSQL += "  AND VS7_TIPAUT = '1' " // Pecas
		cSQL += "  AND D_E_L_E_T_ = ' '"
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL), cAliasVS7, .F., .T. )
		
		(cAliasVS7)->(dbGoTop())
		
		While !(cAliasVS7)->(Eof())
			AADD( aVS7RecAlt, (cAliasVS7)->NRECNO )
			
			(cAliasVS7)->(dbSkip())
		EndDo
		
		(cAliasVS7)->(dbCloseArea())
		
		DbSelectArea("VS7")
	EndIf
	
	// Liberacao de Servicos ...
	If aAuxProb[nCntFor, 7]
		
		For nCntFor2 := 1 to Len(aAuxProb[nCntFor, 3])

			// Posicao da Matriz aAuxVO4 com problema de desconto
			nPecSer := aAuxProb[nCntFor, 3, nCntFor2,1]

			// Se o Parametro MV_MIL00131 estiver DESATIVADO, nใo ้ criado VS7 dos Itens que nใo tiverem problema
			If !lVS7SemProb .and. aAuxProb[nCntFor, 3, nCntFor2, 2] // O parโmetro estแ desativado e o item nใo tem problema de Margem ou Desconto
				Loop
			Endif
			
			VOK->(dbSetOrder(1))
			VOK->(dbSeek(xFilial("VOK") + aAuxVO4[nPecSer, AS_TIPSER]))
			
			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "FROM " + RetSQLName("VS7") + " "
			cSQL += "WHERE VS7_FILIAL = '" + xFilial("VS7") + "' "
			cSQL += "  AND VS7_NUMIDE = '" + aAuxProb[nCntFor, 5] + "' "
			cSQL += "  AND VS7_GRUSER = '" + aAuxVO4[ nPecSer, AS_GRUSER ] + "' "
			cSQL += "  AND VS7_CODSER = '" + aAuxVO4[ nPecSer, AS_CODSER ] + "' "
			cSQL += "  AND VS7_TIPAUT = '2' " // Servicos
			cSQL += "  AND D_E_L_E_T_ = ' '"
			nRecVS7 := FM_SQL(cSQL)
			
			dbSelectArea("VS7")
			
			If nRecVS7 <> 0
				AADD( aVS7RecAlt, nRecVS7 ) // Adiciona na array utilizada posteriormente para definir os registros que foram alterados
				
				dbGoTo( nRecVS7 )
				
				RecLock("VS7", .f.)
			Else
				RecLock("VS7", .t.)
				
				VS7->VS7_FILIAL := xFilial("VS7")
				VS7->VS7_NUMIDE := aAuxProb[nCntFor, 5]
				VS7->VS7_SEQUEN := Strzero(OX100SQVS7( aAuxProb[nCntFor, 5] ), 4)
				VS7->VS7_TIPAUT := "2" // Oficina
				VS7->VS7_GRUSER := aAuxVO4[ nPecSer, AS_GRUSER ]
				VS7->VS7_CODSER := aAuxVO4[ nPecSer, AS_CODSER ]
				VS7->VS7_TIPSER := aAuxVO4[ nPecSer, AS_TIPSER ]
				VS7->VS7_DESPER := VOK->VOK_PERMAX
			EndIf
			
			VS7->VS7_DESDES := aAuxVO4[ nPecSer, AS_PERDES ]
			VS7->VS7_VALORI := aAuxVO4[ nPecSer, AS_VALBRU ]
			VS7->VS7_VALPER := aAuxVO4[ nPecSer, AS_VALBRU ] * ((100 - VOK->VOK_PERMAX) / 100)
			VS7->VS7_VALDES := aAuxVO4[ nPecSer, AS_VALBRU ] - aAuxVO4[ nPecSer, AS_VALDES ]
			VS7->VS7_QTDITE := 1
			If lVS7DIVERG
				VS7->VS7_DIVERG := IIf(aAuxProb[nCntFor, 3,nCntFor2,2],"0","1") // Se o elemento do Array estiver com .T. ้ porque nใo houve Divergencia de Desconto ou Margem
			Endif
			
			VS7->(MsUnlock())
		Next nCntFor2
	Else
		// Adiciona os registro de liberacao de pecas na matriz aVS7RecAtu , para
		// que no final os registros NAO sejam excluidos
		cSQL := "SELECT R_E_C_N_O_ NRECNO "
		cSQL += "FROM " + RetSQLName("VS7") + " "
		cSQL += "WHERE VS7_FILIAL = '" + xFilial("VS7") + "' "
		cSQL += "  AND VS7_NUMIDE = '" + aAuxProb[nCntFor, 5] + "' "
		cSQL += "  AND VS7_TIPAUT = '2' " // Servicos
		cSQL += "  AND D_E_L_E_T_ = ' '"
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL), cAliasVS7, .F., .T. )
		
		(cAliasVS7)->(dbGoTop())
		
		While !(cAliasVS7)->(Eof())
			AADD( aVS7RecAlt, (cAliasVS7)->NRECNO)
			
			(cAliasVS7)->(dbSkip())
		EndDo
		
		(cAliasVS7)->(dbCloseArea())
		
		DbSelectArea("VS7")
	EndIf
	
	// Exclui registros nao alterados da VS7
	For nCntFor2 := 1 to Len(aVS7RecAtu)
		If (nPos := aScan( aVS7RecAlt, aVS7RecAtu[nCntFor2]) ) == 0
			dbSelectArea("VS7")
			
			VS7->(dbGoTo(aVS7RecAtu[nCntFor2]))
			
			RecLock("VS7", .F., .T.)
			
			VS7->(dbDelete())
			
			VS7->(MsUnlock())
		EndIf
	Next nCntFor2
	
	// Gera Tabela Intermediaria de Avalia็ใo de Resultado para Consulta de Libera็ใo de Venda ...
	If !Empty(aAuxProb[nCntFor, 4])
		OX100DELAVAL( aAuxProb[nCntFor, 1], aAuxProb[nCntFor, 4] )
		
		OX100VSY( aAuxProb[nCntFor, 4], aAuxProb[nCntFor, 1], aAuxProb[nCntFor, 8], aAuxProb[nCntFor, 9] ) // Peca
		
		OX100VSZ( aAuxProb[nCntFor, 4], aAuxProb[nCntFor, 1], aAuxProb[nCntFor, 8], aAuxProb[nCntFor, 9] ) // Servico
	EndIf
	
	If !Empty(aAuxProb[nCntFor, 5]) .and. aAuxProb[nCntFor, 4] <> aAuxProb[nCntFor, 5]
		OX100DELAVAL( aAuxProb[nCntFor, 1] , aAuxProb[nCntFor, 5] )
		
		OX100VSY( aAuxProb[nCntFor, 5], aAuxProb[nCntFor, 1], aAuxProb[nCntFor, 8], aAuxProb[nCntFor, 9] ) // Peca
		
		OX100VSZ( aAuxProb[nCntFor, 5], aAuxProb[nCntFor, 1], aAuxProb[nCntFor, 8], aAuxProb[nCntFor, 9] ) // Servico
	EndIf
Next nCntFor

End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100DELLB   บAutor  ณ Takahashi      บ Data ณ  08/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exclui uma liberacao de desconto                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumLib = Numero da liberacao a ser excluida               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100DELLB(cNumLib)

Local oArea := GetArea()

dbSelectArea("VS6")
dbSetOrder(1)
If !VS6->(dbSeek(xFilial("VS6") + cNumLib))
	Return
EndIf

Begin Transaction
dbSelectArea("VS7")
VS7->(dbSetOrder(1))
VS7->(dbSeek( xFilial("VS7") + VS6->VS6_NUMIDE ))
While !VS7->(Eof()) .and. VS7->VS7_FILIAL == xFilial("VS7") .and. VS7->VS7_NUMIDE == VS6->VS6_NUMIDE
	RecLock("VS7",.F.,.T.)
	VS7->(dbDelete())
	VS7->(MsUnlock())
	VS7->(dbSkip())
End

dbSelectArea("VS6")
RecLock("VS6",.f.,.t.)
VS6->(dbdelete())
VS6->(MsUnlock())

OX100DELAVAL( "" , cNumLib )

End Transaction
RestArea( oArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100NCBLB   บAutor  ณ Takahashi      บ Data ณ  08/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclui o cabecalho de uma liberacao de desconto            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lFecAgru   = Indica se ้ fachamento agrupado               บฑฑ
ฑฑบ          ณ cNumOsv    = Numero da Ordem de Servico                    บฑฑ
ฑฑบ          ณ cCliente   = Codigo do cliente (Faturar Para)              บฑฑ
ฑฑบ          ณ cLoja      = Loja do cliente (Faturar Para)                บฑฑ
ฑฑบ          ณ cTipTem    = Tipo de Tempo                                 บฑฑ
ฑฑบ          ณ cObservVS6 = Observacao da Liberacao de Desconto           บฑฑ
ฑฑบ          ณ cLibVOO    = Numero da Liberacao do Tipo de Tempo          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRetorno = Indica se foi possivel aplicar o desconto       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100NCBLB(lFecAgru, cNumOsv, cCliente, cLoja, cTipTem, cObservVS6, cLibVOO)

dbSelectArea("VS6")
RecLock("VS6",.t.)
VS6->VS6_FILIAL := xFilial("VS6")
VS6->VS6_NUMIDE := GetSxENum("VS6","VS6_NUMIDE")
ConfirmSx8()
VS6->VS6_DOC    := IIf( !lFecAgru , "Ind-" , "Agr-" ) + cNumOsv
VS6->VS6_TIPTEM := cTipTem
VS6->VS6_LIBVOO := cLibVOO
VS6->VS6_TIPAUT := "2"  // Autorizacao de Oficina
VS6->VS6_CODCLI := cCliente
VS6->VS6_LOJA   := cLoja
VS6->VS6_DATOCO := dDataBase
VS6->VS6_HOROCO := Val(SubStr(time(),1,2)+SubStr(time(),4,2))
VS6->VS6_TIPOCO := "000008"
VS6->VS6_DESOCO := STR0040
VS6->VS6_USUARI := substr(cUsuario,7,15)
MSMM(VS6->VS6_OBSMEM , TamSx3("VS6_OBSERV")[1],,cObservVS6,1,,,"VS6","VS6_OBSMEM")
MsUnlock()

// Necessario para controlar o numero sequencia do VS7
AADD( aSeqItVS7, { VS6->VS6_NUMIDE , 0 } )
//

Return VS6->VS6_NUMIDE


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100ACBLB   บAutor  ณ Takahashi      บ Data ณ  08/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alteracao do cabecalho de uma liberacao de desconto        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumLib    = Numero da Liberacao                           บฑฑ
ฑฑบ          ณ cObservVS6 = Observacao da Liberacao de Desconto           บฑฑ
ฑฑบ          ณ aAuxRecAtu = Matriz que recebera os Recnos dos itens da    บฑฑ
ฑฑบ          ณ              liberacao ja gravados na base                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100ACBLB( cNumLib, cObservVS6, aAuxRecAtu )

Local cAliasVS7 := GetNextAlias()
Local cSQL := ""
Local nPos := 0

dbSelectArea("VS6")
dbSetOrder(1)
dbSeek(xFilial("VS6") + cNumLib) //aAuxProb[nCntFor,4])

RecLock("VS6",.F.)
VS6->VS6_DATOCO := dDataBase
VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
VS6->VS6_LIBPRO := ""
VS6->VS6_DATAUT := ctod("00/00/00")
VS6->VS6_HORAUT := 0
MSMM(VS6->VS6_OBSMEM , TamSx3("VS6_OBSERV")[1],,cObservVS6,1,,,"VS6","VS6_OBSMEM")

If VS6->(FieldPos("VS6_DATREJ")) > 0 .and. !Empty(VS6->VS6_DATREJ)
	RecLock("VS6",.f.)
	VS6->VS6_USUREJ := ""
	VS6->VS6_DATREJ := Stod(" ")
	VS6->VS6_HORREJ := 0
	VS6->VS6_MOTREJ := ""
	MsUnLock()
EndIf

MsUnlock()

// Gera uma matriz com os Recnos atuais utilizada no final para verificar
// quais registros da VS7 devem ser excluidos ...
cSQL := "SELECT R_E_C_N_O_ NRECNO"
cSQL +=  " FROM " + RetSQLName("VS7")
cSQL +=  " WHERE VS7_FILIAL = '" + xFilial("VS7") + "'"
cSQL +=    " AND VS7_NUMIDE = '" + VS6->VS6_NUMIDE + "'"
cSQL +=    " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS7 , .F., .T. )
While !(cAliasVS7)->(Eof())
	AADD( aAuxRecAtu , (cAliasVS7)->NRECNO )
	(cAliasVS7)->(dbSkip())
End
(cAliasVS7)->(dbCloseArea())
DbSelectArea("VS7")
//

// Cria Matriz para Controlar o Sequencia da VS7
nPos := aScan( aSeqItVS7 , { |x| x[1] == cNumLib } )
If nPos == 0
	AADD( aSeqItVS7, { cNumLib , 0 } )
	nPos := Len(aSeqItVS7)
EndIf
cSQL := "SELECT MAX(VS7_SEQUEN)"
cSQL +=  " FROM " + RetSQLName("VS7")
cSQL +=  " WHERE VS7_FILIAL = '" + xFilial("VS7") + "'"
cSQL +=    " AND VS7_NUMIDE = '" + VS6->VS6_NUMIDE + "'"
//cSQL +=    " AND D_E_L_E_T_ = ' '"
aSeqItVS7[ nPos, 2 ] := Val(FM_SQL( cSQL ))
//

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100SQVS7   บAutor  ณ Takahashi      บ Data ณ  08/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controla o sequencia dos itens da liberacao (VS7_SEQUEN    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumLib    = Numero da Liberacao                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Proximo numero sequencial do item da liberacao             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100SQVS7( cNumLib )

Local nRetorno

nPos := aScan( aSeqItVS7 , { |x| x[1] == cNumLib } )
nRetorno := ++aSeqItVS7[ nPos,2 ]

Return nRetorno



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100NATFT   บAutor  ณ Takahashi      บ Data ณ  08/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna Natureza a ser utilizada                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lFecPeca = Indica se tem peca para fechamento              บฑฑ
ฑฑบ          ณ lFecSrvc = Indica se tem servico para fechamento           บฑฑ
ฑฑบ          ณ lPeriodico = Indica se ้ fechamento de cliente periodico   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Natureza de Pecas / Servicos                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100NATFT( lFecPeca , lFecSrvc , lPeriodico)

Local lVOONATSRV := VOO->(FieldPos("VOO_NATSRV")) > 0

Local cRetorno := ""
Local cMVNATPER := AllTrim(GetNewPar("MV_NATPER",""))
Local nPosVirg

// Cliente periodico
If lPeriodico .and. !Empty(cMVNATPER)
	nPosVirg := AT(",",cMVNATPER)
	If lFecPeca
		cRetorno := IIf( nPosVirg > 0 , Left( cMVNATPER , nPosVirg-1 ) , cMVNATPER)
	ElseIf lFecSrvc
		cRetorno := IIf( nPosVirg > 0 , SubStr( cMVNATPER , nPosVirg+1 ) , cMVNATPER)
	EndIf
	// Cliente "normal"
Else
	If lFecPeca
		cRetorno := M->VOO_NATPEC
	EndIf
	If lFecSrvc .and. Empty(cRetorno)
		If lVOONATSRV .and. !Empty(M->VOO_NATSRV)
			cRetorno := M->VOO_NATSRV
		Else
			cRetorno := M->VOO_NATPEC
		EndIf
	EndIf
EndIf

Return cRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100VLAB    บAutor  ณ Takahashi      บ Data ณ  30/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna valor de titulos de abatimento de PIS/COFINS/CSLL  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ _cPrefixo = Prefixo do Titulo                              บฑฑ
ฑฑบ          ณ _cNum = Numero do Titulo                                   บฑฑ
ฑฑบ          ณ _cParc = Parcela do Titulo                                 บฑฑ
ฑฑบ          ณ _cCliente = Cliente                                        บฑฑ
ฑฑบ          ณ _cLoja = Loja                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100VLAB( _cPrefixo, _cNum, _cParc, _cCliente, _cLoja)

Local nValAbat
Local cSQL

cSQL := "SELECT SUM(E1_VALOR)"
cSQL +=  " FROM " + RetSQLName("SE1") + " E1"
cSQL += " WHERE E1.E1_FILIAL = '" + xFilial("SE1") + "'"
cSQL +=   " AND E1.E1_PREFIXO = '" + _cPrefixo + "'"
cSQL +=   " AND E1.E1_NUM = '" + _cNum + "'"
cSQL +=   " AND E1.E1_PARCELA = '" + _cParc + "'"
cSQL +=   " AND E1.E1_CLIENTE = '" + _cCliente + "'"
cSQL +=   " AND E1.E1_LOJA = '" + _cLoja + "'"
cSQL +=   " AND E1.E1_TIPO IN ('" + MVCSABT + "','" + MVCFABT + "','" + MVPIABT + "','" + MVISABT + "')"
cSQL +=   " AND E1.D_E_L_E_T_ = ' '"
nValAbat := FM_SQL( cSQL )

Return nValAbat


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100OPCOES  บAutor  ณ Takahashi      บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem do Menu de Opcoes                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100OPCOES()

Local nQtdeBot, nLinha, nDist, nLargura, nAltura
Local nCntFor
Local aBotOpcoes

If aScan( aVetTTP , { |x| x[ATT_VETSEL] == .t. } ) == 0 .or. lCanSel
	MsgAlert(STR0053,STR0004) // "Selecionar um registro para faturamento"
	Return .f.
EndIf

aBotOpcoes := {}

AADD( aBotOpcoes , { STR0044 , 'OX100BOTOPC(01)' } ) // "Cliente"
AADD( aBotOpcoes , { STR0045 , 'OX100BOTOPC(02)' } ) // "Posicao Analitica dos Servicos"
//AADD( aBotOpcoes , { STR0048 , 'OX100BOTOPC(03)' } ) // "Libera Venda"

If ExistBlock("OX100BTO")
	aAuxBotParc := ExecBlock("OX100BTO",.f.,.f.)
	If ValType(aAuxBotParc) == "A"
		For nCntFor := 1 to Len(aAuxBotParc)
			AADD( aBotOpcoes , aClone(aAuxBotParc[nCntFor]) )
		Next nCntFor
	EndIf
EndIf

nQtdeBot := Len(aBotOpcoes) // Qtde de Botoes na Dialog
nDist    := 3 // Distancia entre os botoes
nAltura  := 12  // Altura de cada botao
nLinha   := 2 // Linha para atual para criar o botao
nLargura := 118 // Largura de cada botao

SetKey(VK_F10,{|| Nil })

DEFINE MSDIALOG oDlgOpcoes TITLE (STR0092+" - <F10>") From 0,0 TO ( nQtdeBot * (nDist+nAltura) * 2 ),( ( nLargura + 2 ) * 2 ) of oDlgFech PIXEL
oDlgOpcoes:lEscClose := .T.

For nCntFor := 1 to Len(aBotOpcoes)
	tButton():New(nLinha,02, aBotOpcoes[nCntFor,1] ,oDlgOpcoes, &('{ || ' + aBotOpcoes[nCntFor,2] + ' }') , nLargura , nAltura ,,,,.T.)
	nLinha += nALtura + nDist
Next nCntFor

ACTIVATE MSDIALOG oDlgOpcoes CENTER

SetKey(VK_F10,{|| OX100OPCOES() })

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOX100BOTOPCบAutorณ Rubens Takahashi    บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Clique no Menu de Opcoes da Tela                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100BOTOPC(nBot)

Local nPosTTPFec := aScan( aVetTTP , { |x| x[ATT_VETSEL] == .t. } )

Do Case
	Case nBot == 1 // Cliente
		If !lCanSel
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(dbSeek( xFilial("SA1") + aVetTTP[nPosTTPFec,04] + aVetTTP[nPosTTPFec,10] ))
			FC010CON() // Tela de Consulta -> Posicao do Cliente
		Else
			MsgAlert(STR0065,STR0004) // "Consulta s๓ ้ permitida quando algum TT estiver selecionado para faturamento"
		EndIf
	Case nBot == 2 // Posicao Analitica dos Servicos
		If !lCanSel
			OX100PSRVC()
		Else
			MsgAlert(STR0065,STR0004) // "Consulta s๓ ้ permitida quando algum TT estiver selecionado para faturamento"
		EndIf
EndCase

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OX100IMPPF บAutorณ Rubens Takahashi   บ Data ณ  25/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime Formulario Pr้-Fechamento                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100IMPPF()

Local aOSPreFec := {}
Local nCntFor

// Se a rotina esta com os TT para negociacao, salva a negociacao antes de imprimir ...
If !lCanSel
	If !OX100SNEG(.f.)
		Return .F.
	EndIf
EndIf
//

For nCntFor := 1 to Len(aVetTTP)
	// Procura o TTP Marcado para Fechamento
	If !aVetTTP[nCntFor,ATT_VETSEL]
		Loop
	EndIf
	//
	
	AADD( aOSPreFec , { aVetTTP[ nCntFor, ATT_NUMOSV ] , aVetTTP[nCntFor,ATT_TIPTEM] } )
	
Next nCntFor

If Len(aOSPreFec) > 0
	ExecBlock("PREFECT2",.F.,.F.,{aOSPreFec})
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOX100PSRVC บAutorณ Rubens Takahashi    บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta de Posicao Analitica dos Servicos                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100PSRVC()

Local aAuxCons := {}
Local aSizeAut
Local aColLBox
Local nAuxLin
Local nAuxCol1, nAuxCol2

Processa( {|| OX100PROCS(@aAuxCons) }, STR0056, STR0066 ,.F.)

If Len(aAuxCons) == 0
	Return
EndIf

aSizeAut := MsAdvSize(.t.)

DEFINE MSDIALOG oDlgPosSrv TITLE STR0045 From aSizeAut[7],00 to aSizeAut[6]*0.85,aSizeAut[5]*0.95 PIXEL OF oDlgFech STYLE DS_MODALFRAME //Posicao Analitica dos Servicos
oDlgPosSrv:lEscClose := .T.

oTPanelBOTTOM := TPanel():New(0,0,"",oDlgPosSrv,NIL,.T.,.F.,NIL,NIL,0,30 ,.T.,.F.)
oTPanelBOTTOM:Align := CONTROL_ALIGN_BOTTOM

nAuxLin  := 1
nAuxCol1 := 02
nAuxCol2 := 160

@ nAuxLin , nAuxCol1 SAY STR0067 OF oTPanelBOTTOM PIXEL // "01 - Total do Tempo Trabalhado deste Servico"
@ nAuxLin , nAuxCol2 SAY STR0071 OF oTPanelBOTTOM PIXEL // "05 - Valor Rateado do Servico COM Desconto"
nAuxLin += 07
@ nAuxLin , nAuxCol1 SAY STR0068 OF oTPanelBOTTOM PIXEL // "02 - Total do Tempo Trabalhado deste Tipo de Servico"
@ nAuxLin , nAuxCol2 SAY STR0072 OF oTPanelBOTTOM PIXEL // "06 - Valor Bruto Total do Servico"
nAuxLin += 07
@ nAuxLin , nAuxCol1 SAY STR0069 OF oTPanelBOTTOM PIXEL // "03 - Total do Tempo Trabalhado desta OS"
@ nAuxLin , nAuxCol2 SAY STR0073 OF oTPanelBOTTOM PIXEL // "07 - Valor Bruto Total do Tipo de Servico"
nAuxLin += 07
@ nAuxLin , nAuxCol1 SAY STR0070 OF oTPanelBOTTOM PIXEL // "04 - Valor Rateado do Servico SEM Desconto"
@ nAuxLin , nAuxCol2 SAY STR0074 OF oTPanelBOTTOM PIXEL // "08 - Valor Bruto Total da Ordem de Servico"

oLbCons := TWBrowse():New(00,00,10,10,,aColLBox,,oDlgPosSrv,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbCons:Align := CONTROL_ALIGN_ALLCLIENT
oLbCons:nAt := 1
oLbCons:SetArray(aAuxCons)
oLbCons:addColumn( TCColumn():New( RetTitle("VO1_NUMOSV") ,{ || aAuxCons[oLbCons:nAt,01] }              ,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) )
oLbCons:addColumn( TCColumn():New( RetTitle("VOK_TIPSER") ,{ || aAuxCons[oLbCons:nAt,02] }              ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
oLbCons:addColumn( TCColumn():New( RetTitle("VO6_GRUSER") ,{ || aAuxCons[oLbCons:nAt,03] }              ,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) )
oLbCons:addColumn( TCColumn():New( RetTitle("VO6_CODSER") ,{ || aAuxCons[oLbCons:nAt,04] }              ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
oLbCons:addColumn( TCColumn():New( RetTitle("VO4_CODPRO") ,{ || aAuxCons[oLbCons:nAt,05] }              ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
oLbCons:addColumn( TCColumn():New( RetTitle("VO4_TEMPAD") ,{ || Transform(aAuxCons[oLbCons:nAt,06],"@R 999:99") }   ,,,,"RIGHT",40,.F.,.F.,,,,.F.,) )
oLbCons:addColumn( TCColumn():New( RetTitle("VO4_TEMTRA") ,{ || Transform(aAuxCons[oLbCons:nAt,07],"@R 999:99") }   ,,,,"RIGHT",40,.F.,.F.,,,,.F.,) )
oLbCons:addColumn( TCColumn():New( "01"           ,{ || Transform(aAuxCons[oLbCons:nAt,08],"@R 999:99") }   ,,,,"RIGHT",20,.F.,.F.,,,,.F.,) ) // 08 - Total do Tempo Trabalhado deste Servico
oLbCons:addColumn( TCColumn():New( "01 (%)"       ,{ || Transform(aAuxCons[oLbCons:nAt,11],"@E 999.99") }   ,,,,"RIGHT",20,.F.,.F.,,,,.F.,) ) // 11 - % em Relacao a este Servico
oLbCons:addColumn( TCColumn():New( "02"           ,{ || Transform(aAuxCons[oLbCons:nAt,09],"@R 999:99") }   ,,,,"RIGHT",20,.F.,.F.,,,,.F.,) ) // 09 - Total do Tempo Trabalhado deste Tipo de Servico
oLbCons:addColumn( TCColumn():New( "02 (%)"       ,{ || Transform(aAuxCons[oLbCons:nAt,12],"@E 999.99") }   ,,,,"RIGHT",20,.F.,.F.,,,,.F.,) ) // 12 - % em Relacao a este Tipo de Servico
oLbCons:addColumn( TCColumn():New( "03"           ,{ || Transform(aAuxCons[oLbCons:nAt,10],"@R 999:99") }   ,,,,"RIGHT",20,.F.,.F.,,,,.F.,) ) // 10 - Total do Tempo Trabalhado desta OS
oLbCons:addColumn( TCColumn():New( "03 (%)"       ,{ || Transform(aAuxCons[oLbCons:nAt,13],"@E 999.99") }   ,,,,"RIGHT",20,.F.,.F.,,,,.F.,) ) // 13 - % em Relacao a esta OS
oLbCons:addColumn( TCColumn():New( "04"           ,{ || Transform(aAuxCons[oLbCons:nAt,14],"@E 999,999.99") } ,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // 14 - Valor Rateado do Servico SEM Desconto
oLbCons:addColumn( TCColumn():New( "05"           ,{ || Transform(aAuxCons[oLbCons:nAt,15],"@E 999,999.99") } ,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // 15 - Valor Rateado do Servico COM Desconto
oLbCons:addColumn( TCColumn():New( "06"           ,{ || Transform(aAuxCons[oLbCons:nAt,16],"@E 999,999.99") } ,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // 16 - Valor Bruto Total do Servico
oLbCons:addColumn( TCColumn():New( "07"           ,{ || Transform(aAuxCons[oLbCons:nAt,17],"@E 999,999.99") } ,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // 17 - Valor Bruto Total do Tipo de Servico
oLbCons:addColumn( TCColumn():New( "08"           ,{ || Transform(aAuxCons[oLbCons:nAt,18],"@E 999,999.99") } ,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // 18 - Valor Bruto Total da Ordem de Servico
oLbCons:Refresh()

ACTIVATE MSDIALOG oDlgPosSrv CENTER ON INIT EnchoiceBar(oDlgPosSrv, { || oDlgPosSrv:End() } , { || oDlgPosSrv:End() } )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOX100PROCS บAutorณ Rubens Takahashi    บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processa Consulta de Posicao Analitica dos Servicos        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100PROCS(aAuxCons)

Local nCntFor , nCntFor2 , nPosCons
Local aAuxTipSer := {} // Array utilizada para gerar os Resumos por Ordem de Servico e Tipo de Servico
Local aAuxNumOsv := {} // Array utilizada para gerar os Resumos por Ordem de Servico
Local nPosTipSer, nPosNumOsv

ProcRegua(Len(aAuxVO4))

For nCntFor := 1 to Len(aAuxVO4)
	
	IncProc(aAuxVO4[nCntFor, AS_NUMOSV])
	
	// Monta array para gerar o Resumo por Ordem de Servico e Tipo de Servico
	If ( nPosTipSer := aScan( aAuxTipSer , { |x| X[1] == aAuxVO4[nCntFor, AS_NUMOSV ] .and. x[2] == aAuxVO4[nCntFor, AS_TIPSER ] } ) ) == 0
		AADD( aAuxTipSer , { aAuxVO4[nCntFor, AS_NUMOSV] , aAuxVO4[nCntFor, AS_TIPSER ] , 0 , 0 } )
		nPosTipSer := Len(aAuxTipSer)
	EndIf
	aAuxTipSer[nPosTipSer,3] += aAuxVO4[nCntFor, AS_TEMTRA ]
	aAuxTipSer[nPosTipSer,4] += aAuxVO4[nCntFor, AS_VALBRU ]
	//
	
	// Monta array para gerar o Resumo por Ordem de Servico
	If ( nPosNumOsv := aScan( aAuxNumOsv , { |x| X[1] == aAuxVO4[nCntFor, AS_NUMOSV ] } ) ) == 0
		AADD( aAuxNumOsv , { aAuxVO4[nCntFor, AS_NUMOSV] , 0 , 0 } )
		nPosNumOsv := Len(aAuxNumOsv)
	EndIf
	aAuxNumOsv[nPosNumOsv,2] += aAuxVO4[nCntFor, AS_TEMTRA ]
	aAuxNumOsv[nPosNumOsv,3] += aAuxVO4[nCntFor, AS_VALBRU ]
	//
	
	For nCntFor2 := 1 to Len(aAuxVO4[nCntFor, AS_APONTA])
		
		AADD( aAuxCons , Array(19) )
		nPosCons := Len(aAuxCons)
		
		aAuxCons[nPosCons,01] := aAuxVO4[nCntFor, AS_NUMOSV]                // 01 - Num OS
		aAuxCons[nPosCons,02] := aAuxVO4[nCntFor, AS_TIPSER]                // 02 - Tipo de Servico
		aAuxCons[nPosCons,03] := aAuxVO4[nCntFor, AS_GRUSER]                // 03 - Grupo de Servico
		aAuxCons[nPosCons,04] := aAuxVO4[nCntFor, AS_CODSER]                // 04 - Codigo do Servico
		aAuxCons[nPosCons,05] := aAuxVO4[nCntFor, AS_APONTA, nCntFor2, AS_APONTA_CODPRO ] // 05 - Produtivo
		aAuxCons[nPosCons,06] := aAuxVO4[nCntFor, AS_TEMPAD]                // 06 - Tempo Padrao
		aAuxCons[nPosCons,07] := aAuxVO4[nCntFor, AS_APONTA, nCntFor2, AS_APONTA_TEMTRA]  // 07 - Tempo Trabalhado
		aAuxCons[nPosCons,08] := aAuxVO4[nCntFor, AS_TEMTRA]                // 08 - Total do Tempo Trabalhado deste Servico
		aAuxCons[nPosCons,09] := 0                              // 09 - Total do Tempo Trabalhado deste Tipo de Servico
		aAuxCons[nPosCons,10] := 0                              // 10 - Total do Tempo Trabalhado desta OS
		aAuxCons[nPosCons,11] := Round( aAuxVO4[nCntFor, AS_APONTA, nCntFor2, AS_APONTA_TEMTRA] / aAuxVO4[nCntFor, AS_TEMTRA ] * 100, 2 ) // 11 - % em Relacao a este Servico
		aAuxCons[nPosCons,12] := 0                              // 12 - % em Relacao a este Tipo de Servico
		aAuxCons[nPosCons,13] := 0                              // 13 - % em Relacao a esta OS
		aAuxCons[nPosCons,14] := 0                              // 14 - Valor Rateado do Servico SEM Desconto
		aAuxCons[nPosCons,15] := 0                              // 15 - Valor Rateado do Servico COM Desconto
		aAuxCons[nPosCons,16] := aAuxVO4[nCntFor, AS_VALBRU]                // 16 - Valor Bruto Total do Servico
		aAuxCons[nPosCons,17] := 0                              // 17 - Valor Bruto Total do Tipo de Servico
		aAuxCons[nPosCons,18] := 0                              // 18 - Valor Bruto Total da Ordem de Servico
		aAuxCons[nPosCons,19] := aAuxVO4[nCntFor, AS_VALBRU] - aAuxVO4[nCntFor, AS_VALDES]  // 19 - Valor Liquido Total do Servico
		
	Next nCntFor2
	
Next nCntFor

For nCntFor := 1 to Len(aAuxCons)
	
	nPosTipSer := aScan( aAuxTipSer , { |x| X[1] == aAuxCons[nCntFor, 01 ] .and. x[2] == aAuxCons[nCntFor, 02 ] } )
	
	nPosNumOsv := aScan( aAuxNumOsv , { |x| X[1] == aAuxCons[nCntFor, 01 ] } )
	
	aAuxCons[nCntFor , 09 ] := aAuxTipSer[nPosTipSer,03] // Total do Tempo Trabalhado deste Tipo de Servico
	aAuxCons[nCntFor , 10 ] := aAuxNumOsv[nPosNumOsv,02] // Total do Tempo Trabalhado desta OS
	aAuxCons[nCntFor , 12 ] := Round( aAuxCons[nCntFor,07] / aAuxTipSer[nPosTipSer,03] * 100 , 2 )// % em Relacao a este Tipo de Servico
	aAuxCons[nCntFor , 13 ] := Round( aAuxCons[nCntFor,07] / aAuxNumOsv[nPosNumOsv,02] * 100 , 2 )// % em Relacao a esta OS
	aAuxCons[nCntFor , 14 ] := Round( aAuxCons[nCntFor,07] / aAuxCons[nCntFor,08] * aAuxCons[nCntFor,16] , 2 ) // Valor Rateado do Servico SEM Desconto
	aAuxCons[nCntFor , 15 ] := Round( aAuxCons[nCntFor,07] / aAuxCons[nCntFor,08] * aAuxCons[nCntFor,19] , 2 ) // Valor Rateado do Servico COM Desconto
	aAuxCons[nCntFor , 17 ] := aAuxTipSer[nPosTipSer,04] // Valor Bruto Total do Tipo de Servico
	aAuxCons[nCntFor , 18 ] := aAuxNumOsv[nPosNumOsv,03] // Valor Bruto Total da Ordem de Servico
	
Next nCntFor

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100IMPDOC บAutor  ณ Takahashi         บ Data ณ  07/01/11 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao de Nota Fiscal e Boleto                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100IMPDOC(cNota, cSerie, cTipTem, cCodBco)

Local nCntFor

If !Empty(cNota) .and. ExistBlock("NFPECSER")
	
	ExecBlock("NFPECSER",.f.,.f.,{cNota,cSerie})
	
	SF2->(DbSetOrder(1))
	SF2->(MsSeek(xFilial("SF2") + cNota + cSerie))
	
	cObs1 := ""
	cObs2 := ""
	cObs3 := ""
	DbSelectArea("SA6")
	DbSetOrder(1)
	If DbSeek(xFilial("SA6")+cCodBco)
		If SA6->A6_BORD $ "1S"
			If ExistBlock("BLQCOB")
				ExecBlock("BLQCOB",.F.,.F.,{cNota,,,,SF2->F2_PREFIXO,"1",cObs1,cObs2,cObs3,cCodBco})
			EndIf
		Endif
	Endif
	
EndIf

If GetNewPar("MV_IOSVFEC","S") == "S"
	For nCntFor := 1 to Len(aVetTTP)
		If !aVetTTP[nCntFor, ATT_VETSEL] .OR. aVetTTP[nCntFor, ATT_TIPTEM] <> cTipTem
			Loop
		EndIf
		FG_PEDREL(aVetTTp[nCntFor, ATT_NUMOSV], aVetTTP[nCntFor, ATT_TIPTEM] ,"E")
	Next
	
	For nCntFor := 1 to Len(aVetTTP)
		If !aVetTTP[nCntFor, ATT_VETSEL] .OR. aVetTTP[nCntFor, ATT_TIPTEM] <> cTipTem
			Loop
		EndIf
		FG_PEDORD(aVetTTp[nCntFor, ATT_NUMOSV],"E",aVetTTP[nCntFor, ATT_TIPTEM])
	Next
Endif

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100CMPTES บAutor  ณ Takahashi         บ Data ณ  11/01/13 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da configuracao de movimentacao do estoque da TESบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100CMPTES( cTESOrig, cTESDest )

Local cMovTesAnt, cMovTesAtu

cMovTesAnt := FM_SQL("SELECT F4_ESTOQUE FROM " + RetSQLName("SF4") + " F4 WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = '" + cTESOrig + "' AND D_E_L_E_T_ = ' '")
cMovTesAtu := FM_SQL("SELECT F4_ESTOQUE FROM " + RetSQLName("SF4") + " F4 WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = '" + cTESDest + "' AND D_E_L_E_T_ = ' '")

If cMovTesAtu <> cMovTesAnt
	MsgStop(STR0120 + chr(13) + chr(10) + chr(13) + chr(10) + ; // "Diverg๊ncia na configura็ใo de movimenta็ใo de estoque das TES."
	"F4_ESTOQUE = '"+ cMovTesAnt +"' ( " + cTESOrig + " )"+CHR(13)+CHR(10)+;
	"F4_ESTOQUE = '"+ cMovTesAtu +"' ( " + cTESDest + " )" , STR0121 ) // "A Opera็ใo serแ cancelada!"
	Return .f.
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100VALGAR บAutor  ณ Takahashi         บ Data ณ  01/09/13 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da garantia                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100VALGAR(cNumOsv, cTipTem, cLibVOO, nValPecGar, nValSerGar, cCodMar)

Local lRetorno := .t.
Local cFormul := ""
Local cFunExp := ""

VO1->(dbSetOrder(1))
VO1->(MsSeek(xFilial("VO1") + cNumOsv ))

If cMVMIL0006 == "JD"
	cCodMarVV1 := FMX_RETMAR("JD ") + "/" + FMX_RETMAR("GRS") + "/" + FMX_RETMAR("PLA") + "/" + FMX_RETMAR("JDC") + "/" + FMX_RETMAR("HCM")
Else
	cCodMarVV1 := cCodMar
EndIf

// Tipo de tempo de Garantia...
If OX100TTGAR( cTipTem )
	If lFEXPGA
		cFormul := FMX_FEXPGA("",cTipTem,cCodMarVV1)
		If Empty(cFormul)
			Return .t.
		EndIf
	Else
		OX100VE4POSICIONA( cCodMar )
		VEG->(dbSetOrder(1))
		If !VEG->(dbSeek( xFilial("VEG") + VE4->VE4_FOREXP ))
			Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VE4_FOREXP")) + ": " + VE4->VE4_FOREXP ,4,1)
			Return .t.
		EndIf
		cFormul := Alltrim(VEG->VEG_FORMUL)
	EndIf
	
	cFunExp := OX100FORMUL( cFormul , 'VF' , cTipTem , cLibVOO , "{ '" + cCodMar + "' , " + Str(nValPecGar,10,2) + "," + Str(nValSerGar,10,2) + "}" )
	
Else
	// Para os casos em que nใo se trata de tipo de tempo de garantia
	// A marca pode exigir a transmissใo de um registro de solicita็ใo de garantia dependo da forma que foi aberta a OS.
	// EX: A John Deere nใo estแ reembolsando algumas revis๕es da linha 5000 mas ้ necessแrio a transmissใo do registro
	//     de solicita็ใo de garantia para ficar registrado no sistema da fแbrica que a Revisใo foi feita pelo cliente.
	//     Nesses casos, o sistema foi alterado para se comportar como uma Garantia mas com tipo de tempo interno ou cliente.
	If cMVMIL0006 == "JD"
		cFormul := FMX_FEXPGA("",cTipTem,cCodMarVV1)
		If Empty(cFormul)
			Return .t.
		EndIf
		cFunExp := OX100FORMUL( cFormul , 'SEMREEMB' , cTipTem , cLibVOO , "{ '" + cCodMar + "' , " + Str(nValPecGar,10,2) + "," + Str(nValSerGar,10,2) + "}" )
	EndIf
EndIf

If !Empty(cFunExp)
	// Funcao de Importacao para Garantia
	If !FG_VERFORGAR(cFunExp)
		Return .f.
	EndIf
EndIf


Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100TTGAR  บAutor  ณ Takahashi         บ Data ณ  01/09/13 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se o Tipo de Tempo ้ de Garantia/Revisao           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100TTGAR( cTipTem , cSitTpo , cSitTpoCompara )

Local cSQL

Default cSitTpo := ""
Default cSitTpoCompara := "2/4"

If Empty(cSitTpo)
	cSQL := "SELECT VOI_SITTPO "
	cSQL +=  " FROM " + RetSQLName("VOI")
	cSQL += " WHERE VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI_TIPTEM = '" + cTipTem + "' AND D_E_L_E_T_ = ' '"
	cSitTpo := FM_SQL(cSQL)
EndIf

If cSitTpo $ cSitTpoCompara
	Return .t.
EndIf

Return .f.

Static Function OX100GARPECA( nPosVetTTP , cCodMar )
If lGarPeca
	// Se houver algum tipo de tempo com valor de servico OU algum tipo de tempo que nใo ้ de garantia
	If aVetTTP[ nPosVetTTP ,ATT_TOTSER] <> 0 .or. !OX100TTGAR( aVetTTP[ nPosVetTTP , ATT_TIPTEM ] , aVetTTP[ nPosVetTTP , ATT_SITTPO ] , "2" )
		lGarPeca := .f.
	Else
		cCodMar := aVetTTP[ nPosVetTTP , ATT_CODMAR ]
	EndIf
EndIf
Return
//	If !OX100TTGAR(aVetTTP[nCntFor, ATT_TIPTEM], VOI->VOI_SITTPO, "2" ) .or. aVetTTP[nCntFor, ATT_TOTSER] <> 0
//		lGarPeca := .f.
//	EndIf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100UPDAcres บAutor  ณ Vinicius Gati   บ Data ณ  29/05/14 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza grid  de TT com os valores de acrescimo.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100UPDAcres(nColAcresIT,nColTotIT)
Local RVO3ACRESC := FG_POSVAR('VO3_ACRESC' ,'aHVO3Res')
Local oArrHelp   := Mil_ArrayHelper():New()

Local DVO3TIPTEM := FG_POSVAR('VO3_TIPTEM' ,'aHVO3Det')
Local DVO3GRUITE := FG_POSVAR('VO3_GRUITE' ,'aHVO3Det')
Local DVO3VALBRU := FG_POSVAR('VO3_VALBRU' ,'aHVO3Det')

//	Local IDXTTACRES := nColAcresIT
Local nITIdxRow  := oGetDetVO3:nAt // Grid de Itens
Local cSelTT     := oGetDetVO3:aCols[nITIdxRow][DVO3TIPTEM]
Local cSelGrp    := oGetDetVO3:aCols[nITIdxRow][DVO3GRUITE]

Local RVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Res")
Local RVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Res")
Local RVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Res")
Local RVO3VALTOT := FG_POSVAR("VO3_VALTOT","aHVO3Res")

Local nBkpN

If	nColAcresIT > 0
	nSumAcres := oArrHelp:Sum(nColAcresIT, oGetDetVO3:aCols, { |el| el[DVO3TIPTEM] == cSelTT .AND. el[DVO3GRUITE] == cSelGrp })
Endif
nSumVBru  := oArrHelp:Sum(DVO3VALBRU , oGetDetVO3:aCols, { |el| el[DVO3TIPTEM] == cSelTT .AND. el[DVO3GRUITE] == cSelGrp })
nSumVTot  := oArrHelp:Sum(nColTotIT, oGetDetVO3:aCols, { |el| el[DVO3TIPTEM] == cSelTT .AND. el[DVO3GRUITE] == cSelGrp })


nIdxTTRow := ASCAN(oGetResVO3:aCols, { |el| el[RVO3TIPTEM] == cSelTT .AND. el[RVO3GRUITE] == cSelGrp })
If cUsaAcres == 'S' // Se trabalha com acr้scimo
	oGetResVO3:aCols[nIdxTTRow][RVO3ACRESC] := nSumAcres
Endif
oGetResVO3:aCols[nIdxTTRow][RVO3VALBRU] := nSumVBru
oGetResVO3:aCols[nIdxTTRow][RVO3VALTOT] := nSumVTot

// posiciona no item para mudar recalcular os impostos com novos valores
nBkpN := N
OX100PECFIS(oGetDetVO3:nAt)
nValAcrescimo := IIf( cUsaAcres == 'S',M->VO3_ACRESC,0)
MaFisRef("IT_PRCUNI"  ,"VO300", (  M->VO3_VALPEC  + ( nValAcrescimo / M->VO3_QTDREQ ) - M->VO3_VALDES ))
MaFisRef("IT_VALMERC" ,"VO300", (( M->VO3_VALPEC * M->VO3_QTDREQ ) + nValAcrescimo - M->VO3_VALDES ))
N := nBkpN

oGetResVO3:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100UPDMrg บAutor  ณ Vinicius Gati     บ Data ณ  29/05/14 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o grid de Itens ( % da Margem de Lucro Oficina )  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100UPDMrg(lChamaAcre)
Local DSEQFEC    := FG_POSVAR("SEQFEC","aHVO3Det")
Local IDXB1COD   := FG_POSVAR('VO3_CODITE', 'aHVO3Det')
Local IDXB1GRU   := FG_POSVAR('VO3_GRUITE', 'aHVO3Det')
Local IDXMARLUC  := FG_POSVAR('VO3_MARLUC', 'aHVO3Det')

Default lChamaAcre := .t.

OX100PECFIS(oGetDetVO3:nAt) // posiciona para se usar os impostos
DBSelectArea("SB1")
SB1->(dbSetOrder(7))
SB1->(DbSeek( xFilial("SB1") + oGetDetVO3:aCols[oGetDetVO3:nAt][IDXB1GRU] + oGetDetVO3:aCols[oGetDetVO3:nAt][IDXB1COD] ))
SB1->(dbSetOrder(1))
DbSelectArea("SB2")
SB2->(DbSetOrder(1))
SB2->(DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
//
nValue := OX100FmlDef() // Retorna o % da Margem Lucro Oficina
oGetDetVO3:aCols[oGetDetVO3:nAt][IDXMARLUC] := NOROUND(nValue, 2)
If lChamaAcre
	OX100DACRE()
EndIf
Return
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100ModDec บAutor  ณ Vinicius Gati   บ Data ณ  29/05/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo MOD mas com precisใo decimal                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100ModDec(nVal1, nQtd)
Local nValDiv    := nVal1 / nQtd
Local nValDivTot := NOROUND(nValDiv, 2) * nQtd
Return nVal1 - nValDivTot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100FmlDef บAutor  ณ Vinicius Gati   บ Data ณ  29/05/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ % Margem de Lucro Oficina - Formula                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX100FmlDef()
Local cForPecOfi := AllTrim(GetNewPar("MV_MIL0056", "")) // Formula da Margem de Lucro Oficina
Local nRet := IIF( !Empty(cForPecOfi), FG_FORMULA(cForPecOfi), 0 ) // Execucao da Formula Padrao
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100COLRATบAutor  ณ Takahashi          บ Data ณ  18/07/14 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna coluna que sera utilizada para rateio do valor br. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTpRet = Indica se retorna coluna da get dados ou da matrizบฑฑ
ฑฑบ          ณ          auxiliar.                                         บฑฑ
ฑฑบ          ณ cTipSer = Tipo de servico para filtro no processamento     บฑฑ
ฑฑบ          ณ cNomHeader = Nome da Matriz de Cabecalho (aHeader)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100COLRAT( nTpRet , cTipSer , cNomHeader )

Local nColRateio

// Verifica como sera feito o rateio ...
VOK->(dbSetOrder(1))
VOK->(MsSeek( xFilial("VOK") + cTipSer))
If VOK->VOK_INCMOB $ "3/4" // Valor livre com base na tabela  /  Retorno de Servico
	nColRateio := IIF( nTpRet == 1 , FG_POSVAR("VO4_TEMPAD",cNomHeader) , AS_TEMPAD )
ElseIf VOK->VOK_INCMOB == "5" // KM Socorro
	nColRateio := IIF( nTpRet == 1 , FG_POSVAR("VO4_KILROD",cNomHeader) , AS_KILROD )
Else
	nColRateio := IIF( nTpRet == 1 , FG_POSVAR("VO4_VALBRU",cNomHeader) , AS_VALBRU )
EndIf
//

Return nColRateio


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100RVLB  บAutor  ณ Takahashi          บ Data ณ  18/07/14 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rateio do valor bruto do servico                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipTem = Tipo de tempo para filtro no processamento       บฑฑ
ฑฑบ          ณ cTipSer = Tipo de servico para filtro no processamento     บฑฑ
ฑฑบ          ณ nValBruto = Valor bruto                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100RVLB( cTipTem , cTipSer , nValBruto )

Local lRetorno := .t.
Local nColRateio
Local nAuxCont
Local nTAuxRateio
Local nValBruDif
Local aAuxSrvc := {}

Local DVO4CODSER := FG_POSVAR("VO4_CODSER","aHVO4Det")
Local DVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Det")
Local DVO4VALTOT := FG_POSVAR("VO4_VALTOT","aHVO4Det")
Local DVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Det")
Local DVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Det")

nTAuxRateio := 0
nAuxCont   := 0

nColRateio := OX100COLRAT( 1 , cTipSer , "aHVO4Det" )

// Calcula total da coluna de rateio ...
aEval(oGetDetVO4:aCols,{ |x| IIf( x[DVO4TIPTEM] == cTipTem .and. x[DVO4TIPSER] == cTipSer , (nTAuxRateio += x[nColRateio] , nAuxCont++ ) , NIL ) })

// Ajustar o valor bruto dos servicos da GetDados de Servicos Detalhada (oGetDetVO4)
If nAuxCont == 1
	nPosDet := aScan( oGetDetVO4:aCols , { |x| x[ DVO4TIPTEM ] == cTipTem .and. x[ DVO4TIPSER ] == cTipSer } )
	oGetDetVO4:aCols[nPosDet, DVO4VALBRU ] := nValBruto
	oGetDetVO4:aCols[nPosDet, DVO4VALTOT ] := nValBruto
Else
	aAuxSrvc := {}
	
	nValBruDif := nValBruto
	
	For nAuxCont := 1 to Len(oGetDetVO4:aCols)
		If oGetDetVO4:aCols[nAuxCont,DVO4TIPTEM] == cTipTem .and. oGetDetVO4:aCols[nAuxCont,DVO4TIPSER] == cTipSer
			
			// Grava valor bruto proporcional ...
			oGetDetVO4:aCols[nAuxCont,DVO4VALBRU] := Round(nValBruto * (oGetDetVO4:aCols[nAuxCont,nColRateio] / nTAuxRateio),0)
			oGetDetVO4:aCols[nAuxCont,DVO4VALTOT] := oGetDetVO4:aCols[nAuxCont,DVO4VALBRU]
			//
			
			If oGetDetVO4:aCols[nAuxCont,DVO4VALBRU] <= 0
				Help(" ",1,"OX100ALTVLB",,RetTitle("VO4_CODSER") + ": " + AllTrim(oGetDetVO4:aCols[nAuxCont,DVO4CODSER]) + CHR(13) + CHR(10) + RetTitle("VO4_VALBRU") + ": " + AllTrim(Str(oGetDetVO4:aCols[nAuxCont,DVO4VALBRU],10,2)),4,1)
				Return .f.
			EndIf
			
			// Utilizado para ajuste no final, se necessario
			nValBruDif -= oGetDetVO4:aCols[nAuxCont,DVO4VALBRU]
			AADD( aAuxSrvc , { nAuxCont , oGetDetVO4:aCols[nAuxCont,DVO4VALBRU] } )
			//
			
		EndIf
	Next nAuxCont
	// Ajusta valor bruto
	If nValBruDif <> 0
		aSort( aAuxSrvc ,,, { |x,y| x[2] > y[2] } )
		oGetDetVO4:aCols[aAuxSrvc[1,1],DVO4VALBRU] += nValBruDif
		oGetDetVO4:aCols[aAuxSrvc[1,1],DVO4VALTOT] := oGetDetVO4:aCols[aAuxSrvc[1,1],DVO4VALBRU]
	EndIf
	//
EndIf
//

OX100RAVO4("R", cTipTem , cTipSer)

// Ajusta a matriz Auxiliar ...
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100RAVO4 บAutor  ณ Takahashi          บ Data ณ  18/07/14 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Rateio do valor bruto do servico na matriz auxiliar        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOrigem = Indica se parte da GetDados do Resumo ou Detalhe บฑฑ
ฑฑบ          ณ cTipTem = Tipo de tempo para filtro no processamento       บฑฑ
ฑฑบ          ณ cTipSer = Tipo de servico para filtro no processamento     บฑฑ
ฑฑบ          ณ nPGetDVO4 = Linha da getdados de detalhe                   บฑฑ
ฑฑบ          ณ nValBruto = Valor bruto (utilizado no processamento da     บฑฑ
ฑฑบ          ณ             GetDados de Detalhes)                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100RAVO4(cOrigem, cTipTem, cTipSer ,nPGetDVO4, nValBruto )

Local nColRateio := 0
Local nTAuxRateio := 0
Local nTVBruCalc := 0

Local DVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Det")
Local DVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Det")
Local DVO4GRUSER := FG_POSVAR("VO4_GRUSER","aHVO4Det")
Local DVO4CODSER := FG_POSVAR("VO4_CODSER","aHVO4Det")
Local DVO4VALBRU := FG_POSVAR("VO4_VALBRU","aHVO4Det")

Local nCntWhile := 1
Local nFimWhile := Len(oGetDetVO4:aCols)

Default cTipTem := ""
Default cTipSer := ""

If cOrigem == "D"
	nCntWhile := nFimWhile := nPGetDVO4
EndIf

// Atualiza valor bruto ...
While nCntWhile <= nFimWhile
	
	If !Empty(cTipTem) .and. oGetDetVO4:aCols[nCntWhile,DVO4TIPTEM] <> cTipTem
		++nCntWhile
		Loop
	EndIf
	
	If !Empty(cTipSer) .and. oGetDetVO4:aCols[nCntWhile,DVO4TIPSER] <> cTipSer
		++nCntWhile
		Loop
	EndIf
	
	nColRateio := OX100COLRAT( 2 , oGetDetVO4:aCols[nCntWhile,DVO4TIPSER] )
	
	nTAuxRateio := 0
	nTVBruCalc := 0
	
	// Calcula total da coluna de rateio ...
	aEval(aAuxVO4,{ |x| IIf(x[AS_TIPTEM] == oGetDetVO4:aCols[nCntWhile,DVO4TIPTEM] .and. ;
	x[AS_TIPSER] == oGetDetVO4:aCols[nCntWhile,DVO4TIPSER] .and. ;
	x[AS_GRUSER] == oGetDetVO4:aCols[nCntWhile,DVO4GRUSER] .and. ;
	x[AS_CODSER] == oGetDetVO4:aCols[nCntWhile,DVO4CODSER] , nTAuxRateio += x[nColRateio] , NIL ) })
	//
	
	// Se for rateio do resumo, considera valor da GetDados de Detalhe
	If cOrigem == "R"
		nValBruto := oGetDetVO4:aCols[nCntWhile,DVO4VALBRU]
	EndIf
	//
	
	// Acerta o valor bruto ...
	aEval(aAuxVO4,{ |x| IIf(x[AS_TIPTEM] == oGetDetVO4:aCols[nCntWhile,DVO4TIPTEM] .and. ;
	x[AS_TIPSER] == oGetDetVO4:aCols[nCntWhile,DVO4TIPSER] .and. ;
	x[AS_GRUSER] == oGetDetVO4:aCols[nCntWhile,DVO4GRUSER] .and. ;
	x[AS_CODSER] == oGetDetVO4:aCols[nCntWhile,DVO4CODSER] , ( x[AS_VALBRU] := Round( nValBruto * ( x[nColRateio] / nTAuxRateio ) ,0) , nTVBruCalc += x[AS_VALBRU] ) , NIL ) })
	//
	
	If nTVBruCalc <> nValBruto
		nPosGet := aScan(aAuxVO4,{ |x| x[AS_TIPTEM] == oGetDetVO4:aCols[nCntWhile,DVO4TIPTEM] .and. ;
		x[AS_TIPSER] == oGetDetVO4:aCols[nCntWhile,DVO4TIPSER] .and. ;
		x[AS_GRUSER] == oGetDetVO4:aCols[nCntWhile,DVO4GRUSER] .and. ;
		x[AS_CODSER] == oGetDetVO4:aCols[nCntWhile,DVO4CODSER] })
		aAuxVO4[nPosGet,AS_VALBRU] += (nValBruto - nTVBruCalc)
	EndIf
	
	++nCntWhile
	
End

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OX100DACRE บAutor  ณ Thiago             บ Data ณ 02/10/14  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Tenta aplicar acrescimo na Peca.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRetorno = Indica se foi possivel aplicar o acrescimo      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100DACRE()
Local lRetorno    := .t.
oGetResVO3:oBrowse:Refresh()
oGetDetVO3:oBrowse:Refresh()
OX100ATRES(.f.)

Return lRetorno

/*/{Protheus.doc} OX100LOJA
Retorna se integra com o Loja/Venda Direta.

@author Rubens
@since 13/02/2015
@version 1.0
@return lOk, Retorna se integra com o Loja/Venda Direta

/*/
Static Function OX100LOJA()
If lVOOCFNF
	Return ( ( Empty(M->VOO_CFNF) .and. Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "S" ) .or. M->VOO_CFNF == "2" )
Else
	Return ( Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "S" )
EndIf
Return .t.


/*/{Protheus.doc} AjustaHelp

Cria mensagens de HELP

@author Rubens
@since 18/06/2015
@version 1.0

/*/
Static Function AjustaHelp()

Local aHelpEng, aHelpSpa, aHelpPor

aHelpPor := {"Nใo ้ possํvel fechar tipo de tempo de","garantia/revisใo integrado com o","loja/venda direta." }
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("POX100LJGAR",aHelpPor,aHelpEng,aHelpSpa,.f.)

Return

/*/{Protheus.doc} OX100TPPROC

Funcao responsavel por indicar esta sendo processado as pecas ou servicos do fechamento

@author Rubens
@since 17/07/2015
@version 1.0
@param aProcTipTem, array, (Descri็ใo do parโmetro)
@param cAuxProc, character, Indica se esta processando fechamento de [P]ecas / [S]ervicos / [ ] Vazio para Ambos ...
@param lFecPeca, booleano, Indica se deve processar as pecas do fechamento (Passar parametro por referencia)
@param lFecSrvc, booleano, Indica se deve processar os servicos do fechamento (Passar parametro por referencia)
@param lNFSrvc, booleano, Indica se deve gerar nota fiscal quando estiver processando os servicos (Passar parametro por referencia)

/*/
Static Function OX100TPPROC(aProcTipTem, cAuxProc, lFecPeca, lFecSrvc, lNFSrvc)

lFecSrvc := .f.
lFecPeca := .f.
lNFSrvc  := .f.

// Verifica se existe Peca / Servico no Fechamento ...
If cAuxProc == "P" .or. Empty(cAuxProc)
	lFecPeca := ( aScan( oGetDetVO3:aCols , { |x| x[DVO3TIPTEM] == aProcTipTem[FTT_TIPTEM] .and. !Empty(x[DVO3CODITE]) } ) <> 0 )
EndIf
If cAuxProc == "S" .or. Empty(cAuxProc)
	lFecSrvc := ( aScan( oGetDetVO4:aCols , { |x| x[DVO4TIPTEM] == aProcTipTem[FTT_TIPTEM] .and. !Empty(x[DVO4CODSER]) } ) <> 0 )
	lNFSrvc  := aProcTipTem[FTT_NFSRVC]
EndIf
//
Return


/*/{Protheus.doc} OX100PEDFAT

Funcao responsแvel por gerar a matriz do cabecalho do pedido de venda para integra็ใo com o faturamento

@author Rubens
@since 17/07/2015
@version 1.0
@param aProcTipTem, array, Matriz com tipos de tempos selecionados para fechamento
@param cAuxProc, character, Indica se esta processando fechamento de [P]ecas / [S]ervicos / [ ] Vazio para Ambos ...
@param cNumPed, character, Numero do pedido de venda que sera gerado
@param cItemPed, character, Numero do item do pedido de venda que sera gerado
@param lPeriodico, booleano, Controla se o cliente (Faturar para) em questใo ้ peri๓dico
@param lFecPeca  , booleano, Controla se esta sendo processado as pecas
@param lFecSrvc  , booleano, Controla se esta sendo processado os servicos
@param lNFSrvc   , booleano, Indica se gera NF quando for processamento de servicos
@param cCondVS9, character, Contem clausula para pesquisa quando utiliza condicao do tipo "A"

/*/
Static Function OX100PEDFAT(aProcTipTem, cAuxProc, cNumPed, cItemPed, lPeriodico, lFecPeca, lFecSrvc, lNFSrvc, cCondVS9 )

// Nao deve gerar a NF de Peca/Servico
If !( lFecPeca .or. (lFecSrvc .and. lNFSrvc) )
	Return
EndIf
//
If aProcTipTem[FTT_TIPFEC] <> cAuxProc .and. !Empty(cAuxProc)
	Return
EndIf
//
VOI->(dbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + aProcTipTem[FTT_TIPTEM] ))

SA1->(dbSetOrder(1))
SA1->(MsSeek( xFilial("SA1") + aProcTipTem[FTT_CLIENTE] + aProcTipTem[FTT_LOJA] ))

// Cliente Periodico
If lCliPeriod .and. !Empty(SA1->A1_COND) .and. SA1->A1_COND == M->VOO_CONDPG
	lPeriodico := .t.
EndIf
//
ProcRegua(6)

If !lMVMIL0059 .or. ((lMVMIL0059 .or. lMVMIL0084) .and. Empty(cNumPed))
	IncProc(STR0059) // "Gerando Pedido de Venda"
	OX100SC5(@cNumPed,@aProcTipTem, lFecPeca , lFecSrvc , lPeriodico)
EndIf

OX100SC5NEG(aProcTipTem, @cCondVS9) // Carrega negociacao quando condicao de pagamento do tipo 9

DBSelectArea("SB1")
DBSetOrder(7)

SF4->(dbSetOrder(1))

// Itens do Pedido de Venda - P E C A S
If lFecPeca
	OX100SC6PEC(cNumPed, @cItemPed, @aProcTipTem)
EndIf

// Itens do Pedido de Venda - S E R V I C O S
If lFecSrvc .and. lNFSrvc
	OX100SC6SER(cNumPed, @cItemPed, @aProcTipTem)
EndIf
//
SB1->(DBSetOrder(1))

Return .t.

/*/{Protheus.doc} OX100GERNF

Funcao responsavel por gerar nota fiscal

@author Rubens
@since 17/07/2015
@version 1.0
@param cNumPed, character, Numero do pedido de venda que sera faturado
@param cSerie, character, Serie da nota fiscal que serแ utilizada no fechamento
@param cNota, character, Numero da nota fiscal que foi gerada
@param lFecPeca  , booleano, Controla se esta sendo processado as pecas
@param lFecSrvc  , booleano, Controla se esta sendo processado os servicos
@param lPeriodico, booleano, Controla se o cliente (Faturar para) em questใo ้ peri๓dico
@param cCodMar, character, Codigo da Marca para tratamento de Garantia
@param cCondVS9, character, Contem clausula para pesquisa quando utiliza condicao do tipo "A"

/*/
Static Function OX100GERNF( cNumPed , cSerie , cNota , lFecPeca , lFecSrvc , lPeriodico , cCodMar , cCondVS9 )

Local lAltSA1     := .f.  // Controla se Foi alterado o cliente para geracao de Titulo
Local cBkpNatSA1          // Backup da Natureza do cliente ...
Local nRecSA1     := 0

Local cMsgSC9     := ""

Local lCredito := .t.
Local lEstoque := .t.
Local lLiber   := .t.
Local lTransf  := .f.

Local nModBkp
Local cModBkp

Local cAliasVS9:= "TVS9"

Local cTipPer  := PadR(Alltrim(GetNewPar("MV_TIPPER","TP")),TamSX3("E1_TIPO")[1]) // Tipo de Titulo Provisorio

Local cNatFat

Local nVlrSE1    := 0
Local cCodCliSE1 := ""
Local cLojCliSE1 := ""

// Se nao tiver item nao gera pedido nem nota fiscal ...
If Len(aIte) == 0
	Return
EndIf

// ANTIGO - Compatibilizacao com o OFIOM160, para novas implantacoes utilizar outro PE
If ExistBlock("PEOM160ANP")
	ExecBlock("PEOM160ANP",.f.,.f.)
Endif
If ExistBlock("OX100ANP") // Deve ser utilizado este ponto de entrada
	ExecBlock("OX100ANP",.f.,.f.)
Endif
//
// Verificar se a qtde de itens eh maior de a qtde permitida por NF
If len(aIte) > nQtdINF
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MaFisEnd()
	MaFisRestore()
	MsgAlert(STR0138+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
	STR0139+": "+Alltrim(str(len(aIte)))+" "+STR0140+CHR(13)+CHR(10)+;
	STR0141+" MV_NUMITEN: "+Alltrim(str(nQtdINF))+" "+STR0140,STR0004) // Quantidade selecionada de itens ้ maior que a quantidade permitida na NF. / Selecionados / itens / Parametro / itens / Atencao
	Return .f.
EndIf
// Altera natureza do Cliente para atender o caso do MV_1DUPNAT estar configurado com SA1->A1_NATUREZ
cNatFat := OX100NATFT( lFecPeca , lFecSrvc , lPeriodico )
If c1DUPNAT == "SA1->A1_NATUREZ" .and. !Empty(cNatFat) .and. SA1->A1_NATUREZ <> cNatFat
	lAltSA1 := .t.
	cBkpNatSA1 := SA1->A1_NATUREZ
	RecLock("SA1",.f.)
	SA1->A1_NATUREZ := cNatFat
	SA1->(MsUnLock())
EndIf
//
IncProc(STR0059) // "Gerando Pedido de Venda"
lMSHelpAuto := .t.
lMsErroAuto := .f.
MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aIte,3)

if lMsErroAuto
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MostraErro()
	MaFisEnd()
	MaFisRestore()
	Return .f.
Endif

If cNumPed == "_" // Numero do Pedido foi Gerado pelo MATA410
	cNumPed := SC5->C5_NUM
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ LIBERACAO do Pedido de Venda ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IncProc(STR0060) // "Liberando Pedido de Venda"

SC9->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SC6->(dbSeek(xFilial("SC6") + cNumPed + "01"))
While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
	If !SC9->(dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM))
		MaLibDoFat(SC6->(RecNo()),(SC6->C6_QTDVEN),@lCredito,@lEstoque,.F.,(!lESTNEG),lLiber,lTransf)
	EndIf
	SC6->(dbSkip())
Enddo
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Selecionando Itens para Faturamento ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SB1->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SB5->(dbSetOrder(1))
SB2->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SC5->(MsSeek( xFilial("SC5") + cNumPed ))
SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
	If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
		SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
		SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
		SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
		SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
		SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
		aAdd(aPvlNfs,{SC9->C9_PEDIDO,;
		SC9->C9_ITEM,;
		SC9->C9_SEQUEN,;
		SC9->C9_QTDLIB,;
		SC9->C9_PRCVEN,;
		SC9->C9_PRODUTO,;
		SF4->F4_ISS=="S",;
		SC9->(RecNo()),;
		SC5->(RecNo()),;
		SC6->(RecNo()),;
		SE4->(RecNo()),;
		SB1->(RecNo()),;
		SB2->(RecNo()),;
		SF4->(RecNo())})
	Else
		If !Empty(SC9->C9_BLCRED)
			cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLCRED"))+": "+SC9->C9_BLCRED+CHR(13)+CHR(10)
		EndIf
		If !Empty(SC9->C9_BLEST)
			cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST"))+": "+SC9->C9_BLEST+CHR(13)+CHR(10)
		EndIf
	EndIf
	SC9->(dbSkip())
Enddo

If !Empty(cMsgSC9) .or. (lFGXSC5BLQ .and. len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.t.)) // Verifica se SC9 ou SC5 ESTรO bloqueados
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MaFisEnd()
	MaFisRestore()
	If !Empty(cMsgSC9)
		MsgStop(STR0061+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9,STR0004) // Exite um ou mais item do pedido de venda (SC5) que nใo foi liberado! / Atencao
	EndIf
	Return(.f.)
EndIf

ConfirmSx8()

nRecSA1 := SA1->(Recno())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gerando Nota Fiscal de Saida ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IncProc(STR0062) // "Gerando Nota Fiscal"
PERGUNTE("MT460A",.f.)

SE4->(dbSetOrder(1))
SE4->(MsSeek( xFilial("SE4") + M->VOO_CONDPG ))

// Contem os titulos gerados ...
// Utilizado para atualizar o E1_TITPAI no final da geracao da NF
aTitSE1 := {}
//

nModBkp := nModulo
cModBkp := cModulo
nModulo := 5
cModulo := "FAT"
nCntSE1 := 0
cNota := MaPvlNfs(aPvlNfs,;           // 01
cSerie,;            // 02
(mv_par01 == 1),;   // 03
(mv_par02 == 1),;   // 04
(mv_par03 == 1),;   // 05
(mv_par04 == 1),;   // 06
.F.,;               // 07
0,;                 // 08
0,;                 // 09
.T.,;               // 10
.F.,;               // 11
,;          // 12
{ |x| OX100VS9E1(x,cDMSPrefOri,OX1000061_Condicao_Negociada(),lPeriodico,cTipPer) } ,;  // 13
,;          // 14
,;          // 15
,)          // 16
nModulo := nModBkp
cModulo := cModBkp
If lMsErroauto
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MaFisEnd()
	MaFisRestore()
	MostraErro()
	Return(.f.)
EndIf
ConfirmSx8()
//

// Acerta o tamanho da variavel ...
cNota := PadR(cNota,SF2->(TamSx3("F2_DOC")[1]))
//

SA1->(DbGoTo(nRecSA1))

// Restaura a Natureza do Cliente
If lAltSA1
	RecLock("SA1",.f.)
	SA1->A1_NATUREZ := cBkpNatSA1
	SA1->(MsUnLock())
EndIf
//

// Acerta E1_TITPAI para titulos gerados por condicao de pagamento padrao ...
If !OX100E1TITPAI(aTitSE1)
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MostraErro()
	MaFisEnd()
	MaFisRestore()
	Return(.f.)
EndIf
//

cCodCliSE1 := SF2->F2_CLIENTE
cLojCliSE1 := SF2->F2_LOJA

// Grava a observacao da nota fiscal
If SF2->(FieldPos("F2_OBSMEM")) # 0
	If lFecPeca .and. lVOOOBSMNF
		MSMM(,TamSx3("F2_OBSERV")[1],,M->VOO_OBSENF,1,,,"SF2","F2_OBSMEM")
	ElseIf lFecSrvc .and. lVOOOBSMNS
		MSMM(,TamSx3("F2_OBSERV")[1],,M->VOO_OBSENS,1,,,"SF2","F2_OBSMEM")
	EndIf
EndIf

If ExistBlock("OX100E4A")
	// aRetPE[1] := .t. / .f.
	// aRetPE[2] := COD.MARCA (VE1_MARFAB)
	aRetPE := ExecBlock("OX100E4A",.f.,.f.) // PE para verificar se ้ para criar titulos para a Fabrica.
EndIf

// Gera Titulo Manualmente para Fechamento de Pega de Garantia da John Deere
// Nesses casos a Nota Fiscal deve ser emitida em nome do cliente para o Financeiro em nome da Montadora
SE4->(DBSetOrder(1))
If SE4->(dbSeek(xFilial("SE4")+SF2->F2_COND)) .and. SE4->E4_TIPO == "A"
	
	If ( lGarPeca .or. aRetPE[1] )
		
		OX100VE4POSICIONA( IIf( lGarPeca , cCodMar , FMX_RETMAR( aRetPE[2] )) )
		
		DBSelectArea("SF2")
		RecLock("SF2",.f.)
		SF2->F2_PREFIXO := &(GetNewPar("MV_1DUPREF","cSerie"))
		SF2->(MsUnlock())
		
		aFINA040 := {}
		cParcela := ""
		nTamE1PARCELA := TamSx3("E1_PARCELA")[1]
		nCntFor := 0
		
		Pergunte("FIN040",.F.)
		_nRecSA1 := SA1->(Recno())
		
		cSQL := "SELECT VS9.VS9_TIPPAG, VS9.VS9_DATPAG , VS9.VS9_VALPAG , VS9.VS9_TIPPAG , VS9.VS9_NATURE , VS9.R_E_C_N_O_ AS RECVS9"
		cSQL += " FROM " + RetSQLName("VS9") + " VS9"
		cSQL += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
		cSQL +=   " AND VS9.VS9_TIPOPE = 'O'"
		cSQL +=   " AND ( " + cCondVS9 + " ) "
		cSQL +=   " AND VS9.D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY VS9.VS9_NUMIDE , VS9.VS9_DATPAG , VS9.VS9_SEQUEN"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS9 , .F., .T. )
		While !(cAliasVS9)->(Eof())
			
			If nTamE1PARCELA = 1
				cParcela := ConvPN2PC(nCntFor)
			Else
				cParcela := Soma1( StrZero(nCntFor,nTamE1PARCELA) )
			EndIf
			nCntFor++
			
			If !Empty((cAliasVS9)->VS9_NATURE)
				cNatureza := (cAliasVS9)->VS9_NATURE
			Else
				cNatureza := OX100NATFT( lFecPeca , lFecSrvc , .f. )
			EndIf
			
			aFINA040 := {;
			{"E1_PREFIXO",SF2->F2_PREFIXO                           , NIL },;
			{"E1_NUM"    ,SF2->F2_DOC                               , NIL },;
			{"E1_PARCELA",cParcela                                  , NIL },;
			{"E1_TIPO"   ,(cAliasVS9)->VS9_TIPPAG                   , NIL },;
			{"E1_NATUREZ",cNatureza                                 , NIL },;
			{"E1_CLIENTE",VE4->VE4_CODFAB                           , NIL },;
			{"E1_LOJA"   ,VE4->VE4_LOJA                             , NIL },;
			{"E1_EMISSAO",dDataBase                                 , NIL },;
			{"E1_VENCTO" ,StoD((cAliasVS9)->VS9_DATPAG)             , NIL },;
			{"E1_VENCREA",DataValida(StoD((cAliasVS9)->VS9_DATPAG)) , NIL },;
			{"E1_VALOR"  ,(cAliasVS9)->VS9_VALPAG                   , NIL },;
			{"E1_PREFORI",cDMSPrefOri                               , NIL },;
			{"E1_PEDIDO" ,cNumPed                                   , NIL },;
			{"E1_NUMNOTA",SF2->F2_DOC                               , NIL },;
			{"E1_SERIE"  ,SF2->F2_SERIE                             , NIL },;
			{"E1_ORIGEM" ,"MATA460"                                 , NIL },;
			{"E1_VEND1"  ,SF2->F2_VEND1                             , NIL }}
			
			//PE para permitir a manipula็ใo do vetor aFINA040
			If ExistBlock("OX100TIT")
				aFINA040 := ExecBlock("OX100TIT",.f.,.f.,{ aFINA040 , (cAliasVS9)->RECVS9 })
			EndIf

			MSExecAuto({|x| FINA040(x)},aFINA040)
			SA1->(Dbgoto(_nRecSA1))
			If lMsErroAuto
				DisarmTransaction()
				RollbackSx8()
				MsUnlockAll()
				MostraErro()
				MaFisEnd()
				MaFisRestore()
				Return .f.
			EndIf
			
			(cAliasVS9)->(dbSkip())
		End
		(cAliasVS9)->(dbCloseArea())
		
		cCodCliSE1 := VE4->VE4_CODFAB
		cLojCliSE1 := VE4->VE4_LOJA
		
	EndIf
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Acertando cabecalho da Nota Fiscal ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SE1->(Dbgoto(SE1->(RecNo()))) // Reposiciona no SE1 para ser considerado no SQL dentro da transacao
nVlrSE1 := FMX_VALFIN( SF2->F2_PREFIXO , SF2->F2_DOC , cCodCliSE1 , cLojCliSE1 )
DBSelectArea("SF2")
RecLock("SF2",.f.)
If nVlrSE1 <> 0
	SF2->F2_DUPL := cNota
	//////////////////////////////////////////////////////////////////////
	// Gravar o F2_VALFAT com a soma de todos os titulos referente a NF //
	//////////////////////////////////////////////////////////////////////
	SE4->(DBSetOrder(1))
	If SE4->(dbSeek(xFilial("SE4")+SF2->F2_COND)) .and. SE4->E4_TIPO == "A"
		SF2->F2_VALFAT := nVlrSE1
	EndIf
EndIf
SF2->F2_PREFORI:= cDMSPrefOri
SF2->(MsUnlock())

// Baixa titulos a Vista ...
If cMVBXSER == "S"
	If !OX100BXFIN(SF2->F2_PREFIXO, SF2->F2_DUPL, cCodCliSE1, cLojCliSE1, lFecPeca, lFecSrvc)
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		MostraErro()
		MaFisEnd()
		MaFisRestore()
		Return(.f.)
	EndIf
EndIf
//

Return .t.

/*/{Protheus.doc} OX100SC5

Funcao responsavel por montar o cabecalho do pedido de venda

@author Rubens
@since 17/07/2015
@version 1.0
@param cNumPed, character, Numero do pedido de venda que sera faturado
@param aProcTipTem, array, Matriz com os tipos de tempos selecionados para fechamento
@param lFecPeca  , booleano, Controla se esta sendo processado as pecas
@param lFecSrvc  , booleano, Controla se esta sendo processado os servicos
@param lPeriodico, booleano, Controla se o cliente (Faturar para) em questใo ้ peri๓dico

/*/
Static Function OX100SC5( cNumPed , aProcTipTem , lFecPeca , lFecSrvc , lPeriodico )

Local cCodVend := ""
Local nComisVend := 0
Local nAuxPos
Local cFilVOOSC5 := "T" //Todos - Grava็ใo do campo em ambos (Pe็as e Servi็os)

If !Empty(aProcTipTem[FTT_CODVEN])
	SA3->(dbSetOrder(1))
	If SA3->(MsSeek(xFilial("SA3") + aProcTipTem[7] ))
		cCodVend := SA3->A3_COD
		nComisVend := SA3->A3_COMIS
	EndIf
EndIf

SX3->(DbSetOrder(2))
SX3->(DbSeek("C5_NUM"))
If !("GetSXENum" $ SX3->X3_RELACAO)
	cNumPed  := CriaVar("C5_NUM")
	aAdd(aCabPV,{"C5_NUM"    , cNumPed          ,Nil}) // Numero do pedido
Else
	cNumPed := "_"
EndIf
aAdd(aCabPV,{"C5_TIPO"   , "N"              ,Nil}) // Tipo de pedido
aAdd(aCabPV,{"C5_CLIENTE", SA1->A1_COD      ,Nil}) // Codigo do cliente
aAdd(aCabPV,{"C5_LOJACLI", SA1->A1_LOJA     ,Nil}) // Loja do cliente

If lVOOTIPOCL .and. !Empty(M->VOO_TIPOCL)
	aAdd(aCabPV,{"C5_TIPOCLI", M->VOO_TIPOCL ,Nil}) // Tipo do Cliente
Else
	aAdd(aCabPV,{"C5_TIPOCLI", SA1->A1_TIPO  ,Nil}) // Tipo do Cliente
EndIf

If SC5->(FieldPos("C5_INDPRES")) > 0 .and. ( VOO->(FieldPos("VOO_INDPRE")) > 0 .and. !Empty(M->VOO_INDPRE) )
	aAdd(aCabPV,{"C5_INDPRES"  ,M->VOO_INDPRE 	,Nil}) 	// Presenca do Comprador
Endif

If ( VOO->(FieldPos("VOO_TRANSP")) > 0 .and. !Empty(M->VOO_TRANSP) )
	aAdd(aCabPV,{"C5_TRANSP"  ,M->VOO_TRANSP 	,Nil}) 	// Transportadora
Endif

aAdd(aCabPV,{"C5_EMISSAO", dDataBase        ,Nil}) // Data de emissao
aAdd(aCabPV,{"C5_CONDPAG", M->VOO_CONDPG    ,Nil}) // Codigo da condicao de pagamanto
aAdd(aCabPV,{"C5_DESC1"  , 0                ,Nil}) // Percentual do Desconto Geral
aAdd(aCabPV,{"C5_INCISS" , "S"              ,Nil}) // ISS Incluso
aAdd(aCabPV,{"C5_TIPLIB" , "2"              ,Nil}) // Tipo de Liberacao ( 2 - Libera por Pedido de Venda. )
aAdd(aCabPV,{"C5_MOEDA"  , 1                ,Nil}) // Moeda
aAdd(aCabPV,{"C5_LIBEROK", "S"              ,Nil}) // Liberacao Total
aAdd(aCabPV,{"C5_VEND1"  , cCodVend         ,Nil}) // Codigo do vendedor
aAdd(aCabPV,{"C5_COMIS1" , nComisVend       ,Nil}) // Percentual de Comissao

If VOO->(FieldPos("VOO_BANCO")) <> 0 .and. !Empty(M->VOO_BANCO)
	aAdd(aCabPV,{"C5_BANCO"  , M->VOO_BANCO ,Nil}) // Codigo do Banco
EndIf

If VOO->(FieldPos("VOO_RECISS")) <> 0 .and. !Empty(M->VOO_RECISS)
	aAdd(aCabPV,{"C5_RECISS" , M->VOO_RECISS  ,Nil}) // Cliente Recolhe ISS
EndIf

If SC5->(FieldPos("C5_NATUREZ")) <> 0
	aAdd(aCabPV,{"C5_NATUREZ" , OX100NATFT( lFecPeca , lFecSrvc , lPeriodico) , Nil } ) // Natureza no Pedido
EndIf

If lFecPeca
	if VOO->(FieldPos("VOO_MNNOTP")) > 0 .AND. !Empty(M->VOO_MNNOTP)
		aAdd(aCabPV,{"C5_MENNOTA", M->VOO_MNNOTP ,Nil})
	Endif
	if VOO->(FieldPos("VOO_MNPADP")) > 0 .AND. !Empty(M->VOO_MNPADP)
		aAdd(aCabPV,{"C5_MENPAD", M->VOO_MNPADP ,Nil})
	Endif
	cFilVOOSC5 += "P" //Pe็as - Grava็ใo do campo apenas para Pe็as
ElseIf lFecSrvc
	if VOO->(FieldPos("VOO_MNNOTS")) > 0 .AND. !Empty(M->VOO_MNNOTS)
		aAdd(aCabPV,{"C5_MENNOTA", M->VOO_MNNOTS ,Nil})
	Endif
	if VOO->(FieldPos("VOO_MNPADS")) > 0 .AND. !Empty(M->VOO_MNPADS)
		aAdd(aCabPV,{"C5_MENPAD", M->VOO_MNPADS ,Nil})
	Endif
	cFilVOOSC5 += "S" //Servi็os - Grava็ใo do campo apenas para Servi็os
Endif

If lVOOPESOL .and. !Empty(M->VOO_PESOL)
	aAdd(aCabPV,{"C5_PESOL", M->VOO_PESOL ,Nil}) // Peso Liquido
EndIf

If lVOOPBRUTO .and. !Empty(M->VOO_PBRUTO)
	aAdd(aCabPV,{"C5_PBRUTO", M->VOO_PBRUTO ,Nil}) // Peso Bruto
EndIf

If lVOOVEICUL .and. !Empty(M->VOO_VEICUL)
	aAdd(aCabPV,{"C5_VEICULO", M->VOO_VEICUL ,Nil}) // Veiculo do Transporte
EndIf

If lVOOVOLUM1 .and. !Empty(M->VOO_VOLUM1)
	aAdd(aCabPV,{"C5_VOLUME1", M->VOO_VOLUM1 ,Nil}) // Qtde de Volumes tipo 1
EndIf

If lVOOVOLUM2 .and. !Empty(M->VOO_VOLUM2)
	aAdd(aCabPV,{"C5_VOLUME2", M->VOO_VOLUM2 ,Nil}) // Qtde de Volumes tipo 2
EndIf

If lVOOVOLUM3 .and. !Empty(M->VOO_VOLUM3)
	aAdd(aCabPV,{"C5_VOLUME3", M->VOO_VOLUM3 ,Nil}) // Qtde de Volumes tipo 3
EndIf

If lVOOVOLUM4 .and. !Empty(M->VOO_VOLUM4)
	aAdd(aCabPV,{"C5_VOLUME4", M->VOO_VOLUM4 ,Nil}) // Qtde de Volumes tipo 4
EndIf

If lVOOESPEC1 .and. !Empty(M->VOO_ESPEC1)
	aAdd(aCabPV,{"C5_ESPECI1", M->VOO_ESPEC1 ,Nil}) // Especie do Volume tipo 1
EndIf

If lVOOESPEC2 .and. !Empty(M->VOO_ESPEC2)
	aAdd(aCabPV,{"C5_ESPECI2", M->VOO_ESPEC2 ,Nil}) // Especie do Volume tipo 2
EndIf

If lVOOESPEC3 .and. !Empty(M->VOO_ESPEC3)
	aAdd(aCabPV,{"C5_ESPECI3", M->VOO_ESPEC3 ,Nil}) // Especie do Volume tipo 3
EndIf

If lVOOESPEC4 .and. !Empty(M->VOO_ESPEC4)
	aAdd(aCabPV,{"C5_ESPECI4", M->VOO_ESPEC4 ,Nil}) // Especie do Volume tipo 4
EndIf

For nAuxPos := 1 to Len(aVOOSC5)
	If aVOOSC5[ nAuxPos , 1 ] $ cFilVOOSC5 .and. !Empty(&("M->" + aVOOSC5[ nAuxPos , 3 ]))
		AADD( aCabPV , { aVOOSC5[ nAuxPos , 2 ] , &("M->" + aVOOSC5[ nAuxPos , 3 ]) , NIL } )
	EndIf
Next nAuxPos


Return

/*/{Protheus.doc} OX100SC5NEG

Funcao responsavel por montar as parcelas  no cabecalho do pedido de venda quando utilizada uma condicao de pagamento do tipo '9'

@author Rubens
@since 17/07/2015
@version 1.0
@param aProcTipTem, array, Matriz com os tipos de tempos selecionados para fechamento
@param cCondVS9, character, Contem clausula para pesquisa quando utiliza condicao do tipo "A"

/*/
Static Function OX100SC5NEG(aProcTipTem, cCondVS9)

Local cAliasVS9 := "TVS9"
Local nPosSC5
Local nPosVS9SE1

SE4->(dbSetOrder(1))
SE4->(MsSeek( xFilial("SE4") + M->VOO_CONDPG ))

// Condicao negociada
If SE4->E4_TIPO == "9"
	cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0" // cParcela igual ao MATA410A, funcao A410Tipo9()
	cSQL := "SELECT VS9_TIPPAG, VS9_DATPAG , VS9_VALPAG , VS9_TIPPAG "
	cSQL += "  FROM " + RetSQLName("VS9") + " VS9"
	cSQL += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
	cSQL += "   AND VS9.VS9_TIPOPE = 'O'"
	cSQL += "   AND ( " + aProcTipTem[FTT_VS9WHERE] + " ) "
	cSQL += "   AND VS9.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VS9_NUMIDE , VS9_DATPAG , VS9_SEQUEN"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS9 , .F., .T. )
	While !(cAliasVS9)->(Eof())
		
		If (nPosVS9SE1 := aScan( aVS9SE1 ,{ |x| x[1] == (cAliasVS9)->VS9_DATPAG .and. x[2] == (cAliasVS9)->VS9_TIPPAG })) == 0
			AADD( aVS9SE1 , { (cAliasVS9)->VS9_DATPAG , (cAliasVS9)->VS9_TIPPAG , "" } )
			nPosVS9SE1 := Len(aVS9SE1)
			aVS9SE1[nPosVS9SE1,3] := SubStr(cParcela,nPosVS9SE1,1)
			
			aAdd(aCabPV,{"C5_DATA" + aVS9SE1[nPosVS9SE1,3] , StoD((cAliasVS9)->VS9_DATPAG)  , Nil }) // Data da Parcela
			aAdd(aCabPV,{"C5_PARC" + aVS9SE1[nPosVS9SE1,3] , (cAliasVS9)->VS9_VALPAG        , Nil }) // Valor da Parcela
		Else
			
			nPosSC5 := aScan(aCabPV,{ |x| x[1] == "C5_PARC" + aVS9SE1[nPosVS9SE1,3] })
			aCabPV[ nPosSC5 , 2 ] += (cAliasVS9)->VS9_VALPAG
		EndIf
		
		(cAliasVS9)->(dbSkip())
	End
	(cAliasVS9)->(dbCloseArea())
ElseIf SE4->E4_TIPO == "A"
	cCondVS9 += IIF( !Empty( cCondVS9 ) , " OR " , "" ) + "( " + aProcTipTem[FTT_VS9WHERE] + " ) "
EndIf
//
Return

/*/{Protheus.doc} OX100SC6PEC

Fun็ใo responsแvel por adicionar uma linha com a peca na matriz de integra็ใo com o Faturamento

@author Rubens
@since 17/07/2015
@version 1.0
@param cNumPed, character, Numero do Pedido de Venda que serแ criado
@param cItemPed, character, Numero Atual do Item do Pedido de Venda (Deve ser enviado por Referencia)
@param aProcTipTem, array, Matriz com os Tipos de Tempos Selecionados para Fechamento

/*/
Static Function OX100SC6PEC(cNumPed, cItemPed, aProcTipTem)

Local nCntFor
Local oPeca := DMS_Peca():New()

For nCntFor := 1 to Len(oGetDetVO3:aCols)
	
	If oGetDetVO3:aCols[nCntFor, DVO3TIPTEM] <> aProcTipTem[FTT_TIPTEM]
		Loop
	EndIf
	
	aProcTipTem[FTT_PEDFAT] := cNumPed
	
	cItemPed := Soma1( cItemPed , 2 )
	aIteTempPV := {}
	
	If lVOOVLBRNF .and. M->VOO_VLBRNF == "0" // Nao passar o Valor Bruto para NF/Loja
		n_VALBRU := ( oGetDetVO3:aCols[nCntFor,DVO3VALPEC] - ( oGetDetVO3:aCols[nCntFor,DVO3VALDES] / oGetDetVO3:aCols[nCntFor,DVO3QTDREQ] ) )
		n_VALDES := 0
	Else // Passar Valor Bruto e Desconto para NF/Loja
		n_VALBRU := oGetDetVO3:aCols[nCntFor,DVO3VALPEC]
		n_VALDES := oGetDetVO3:aCols[nCntFor,DVO3VALDES]
	EndIf
	
	If cUsaAcres == 'S'
		n_VALBRU += oGetDetVO3:aCols[nCntFor, DVO3ACRESC] / oGetDetVO3:aCols[nCntFor, DVO3QTDREQ]
	EndIf
	
	SB1->(DbSeek(xFilial("SB1") + oGetDetVO3:aCols[nCntFor,DVO3GRUITE] + oGetDetVO3:aCols[nCntFor,DVO3CODITE] ))
	SF4->(MsSeek(xFilial("SF4") + oGetDetVO3:aCols[nCntFor,DVO3CODTES] ))
	
	If cNumPed <> "_"
		aAdd(aIteTempPV,{"C6_NUM"    , cNumPed                   , Nil}) // Numero do Pedido
	EndIf
	aAdd(aIteTempPV,{"C6_ITEM"   , cItemPed                  , Nil}) // Numero do Item no Pedido
	aAdd(aIteTempPV,{"C6_PRODUTO", SB1->B1_COD               , Nil}) // Codigo do Produto
	aAdd(aIteTempPV,{"C6_TES"    , oGetDetVO3:aCols[nCntFor,DVO3CODTES] , Nil}) // Tipo de Saida do Item
	
	If VOI->VOI_SEGURO == "2"
		aAdd(aIteTempPV,{"C6_QTDVEN" , 0 ,Nil})
	Else
		aAdd(aIteTempPV,{"C6_QTDVEN" , oGetDetVO3:aCols[nCntFor,DVO3QTDREQ] , Nil}) // Qtde Vendida
	EndIf
	
	aAdd(aIteTempPV,{"C6_QTDLIB" , 0 ,Nil})
	aAdd(aIteTempPV,{"C6_PRUNIT" , n_VALBRU               , Nil}) // Preco de Lista (Valor Unitario da Peca sem Desconto)
	aAdd(aIteTempPV,{"C6_PRCVEN" , n_VALBRU               , Nil}) // Preco Unitario (Valor Unitario da Peca com Desconto )
	aAdd(aIteTempPV,{"C6_VALOR"  , A410Arred(oGetDetVO3:aCols[nCntFor,DVO3QTDREQ] * n_VALBRU , "C6_VALOR")  , Nil}) // Valor Total do Item
	If VOI->VOI_SEGURO <> "2"
		aAdd(aIteTempPV,{"C6_VALDESC", n_VALDES             , Nil}) // Valor do Desconto
	EndIf
	// Ticket: 1932063
	// ISSUE: MMIL-2426
	// O TES estแ sendo enviado novamente pois na base o cliente ocorria uma falha. O conteudo do TES na aCols (MATA410)
	// ficava com conte๚do VAZIO.
	// O problema nao foi reproduzido em base teste, mas verificamos que passando o TES novamente a falha nใo ocorria novamente
	// A mensagem de HELP disparada era A410VZ.
	aAdd(aIteTempPV,{"C6_TES"    , oGetDetVO3:aCols[nCntFor,DVO3CODTES] , Nil}) // Tipo de Saida do Item
	
	aAdd(aIteTempPV,{"C6_ENTREG" , dDataBase              , Nil}) // Data da Entrega
	aAdd(aIteTempPV,{"C6_UM"     , SB1->B1_UM             , Nil}) // Unidade de Medida Primaria
	
	// Nใo ้ Franquia ...
	If VOI->VOI_SEGURO <> "2" .and. SF4->F4_ESTOQUE <> "N"
		aAdd(aIteTempPV,{"C6_LOCAL", VOI->VOI_CODALM          , Nil}) // Almoxarifado
		
		if !Empty(VOI->VOI_LOCALI) .and. localiza(SB1->B1_COD)
			aAdd(aIteTempPV,{"C6_LOCALIZ", VOI->VOI_LOCALI        , Nil}) // Localizacao (ERP)
		Endif
		
	Endif
	
	aAdd(aIteTempPV,{"C6_CLI"    ,SA1->A1_COD   ,Nil})  // Cliente
	aAdd(aIteTempPV,{"C6_LOJA"   ,SA1->A1_LOJA  ,Nil})  // Loja do Cliente
	
	If SC6->(FieldPos("C6_CC"))>0 .and. DVO3CENCUS <> 0
		aAdd(aIteTempPV,{"C6_CC" , oGetDetVO3:aCols[nCntFor,DVO3CENCUS] , Nil})
	Endif
	
	If SC6->(FieldPos("C6_CONTA"))>0 .and. DVO3CONTA <> 0
		aAdd(aIteTempPV,{"C6_CONTA" , oGetDetVO3:aCols[nCntFor,DVO3CONTA] , Nil})
	Endif
	
	If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. DVO3ITEMCT <> 0
		aAdd(aIteTempPV,{"C6_ITEMCTA" , oGetDetVO3:aCols[nCntFor,DVO3ITEMCT] , Nil})
	Endif
	
	If SC6->(FieldPos("C6_CLVL"))>0 .and. DVO3CLVL <> 0
		aAdd(aIteTempPV,{"C6_CLVL" , oGetDetVO3:aCols[nCntFor,DVO3CLVL] , Nil})
	Endif
	//
	If SC6->(FieldPos("C6_NUMPCOM"))>0 .and. DVO3PEDXML <> 0
		aAdd(aIteTempPV,{"C6_NUMPCOM" , oGetDetVO3:aCols[nCntFor,DVO3PEDXML] , Nil})
	Endif
	If SC6->(FieldPos("C6_ITEMPC"))>0 .and. DVO3ITEXML <> 0
		aAdd(aIteTempPV,{"C6_ITEMPC" , oGetDetVO3:aCols[nCntFor,DVO3ITEXML] , Nil})
	Endif
	
	If lCtrlLote .and. !Empty(oGetDetVO3:aCols[nCntFor,DVO3LOTECT])
		oPeca:LoadB1()
		aAdd(aIteTempPV,{"C6_LOTECTL" , oGetDetVO3:aCols[nCntFor,DVO3LOTECT] , Nil})
		aAdd(aIteTempPV,{"C6_NUMLOT"  , oGetDetVO3:aCols[nCntFor,DVO3NUMLOT] , Nil})
		aAdd(aIteTempPV,{"C6_DTVALID" , oPeca:LoteDtValid(oGetDetVO3:aCols[nCntFor,DVO3LOTECT]) , Nil})
	EndIf
	If lOX100AIP
		aIteTempPV := ExecBlock("OX100AIP",.f.,.f.,{aIteTempPV})
	EndIf
	//
	aAdd(aIte,aClone(aIteTempPV))
	
	// Adiciona na Matriz de Relacionamento do oGetDetVO3:aCols/oGetResVO4:aCols com o SC6,
	// utilizado depois para gerar VEC e VSC ...
	AADD( aRelFatOfi, { "VO3" , nCntFor , cItemPed , "" } )
	//
	
Next nCntFor

Return

/*/{Protheus.doc} OX100SC6SER

Fun็ใo responsแvel por adicionar uma linha com o servico na matriz de integra็ใo com o Faturamento

@author Rubens
@since 17/07/2015
@version 1.0
@param cNumPed, character, Numero do Pedido de Venda que serแ criado
@param cItemPed, character, Numero Atual do Item do Pedido de Venda (Deve ser enviado por Referencia)
@param aProcTipTem, array, Matriz com os Tipos de Tempos Selecionados para Fechamento

/*/
Static Function OX100SC6SER(cNumPed, cItemPed, aProcTipTem)

Local nCntFor

For nCntFor := 1 to Len(oGetResVO4:aCols)
	
	If oGetResVO4:aCols[nCntFor, RVO4TIPTEM ] <> aProcTipTem[ FTT_TIPTEM ]
		Loop
	EndIf
	
	VOK->(dbSetOrder(1))
	VOK->(MsSeek( xFilial("VOK") + oGetResVO4:aCols[nCntFor, RVO4TIPSER] ))
	
	// Servico de Mao de Obra Gratuita ...
	If VOK->VOK_INCMOB == "0"
		Loop
	EndIf
	//
	
	aProcTipTem[FTT_PEDFAT] := cNumPed
	
	cItemPed := Soma1( cItemPed , 2 )
	aIteTempPV := {}
	
	If lVOOVLBRNF .AND. M->VOO_VLBRNF == "0" // Nao passar o Valor Bruto para NF/Loja
		n_VALBRU := ( oGetResVO4:aCols[nCntFor,RVO4VALBRU] - oGetResVO4:aCols[nCntFor,RVO4VALDES] )
		n_VALDES := 0
	Else // Passar Valor Bruto e Desconto para NF/Loja
		n_VALBRU := oGetResVO4:aCols[nCntFor,RVO4VALBRU]
		n_VALDES := oGetResVO4:aCols[nCntFor,RVO4VALDES]
	EndIf
	
	SB1->(DBSeek(xFilial("SB1") + VOK->VOK_GRUITE + VOK->VOK_CODITE ))
	
	If cNumPed <> "_"
		aAdd(aIteTempPV,{"C6_NUM"    , cNumPed                          , Nil}) // Numero do Pedido
	EndIf
	aAdd(aIteTempPV,{"C6_ITEM"   , cItemPed                            , Nil}) // Numero do Item no Pedido
	aAdd(aIteTempPV,{"C6_PRODUTO", SB1->B1_COD                         , Nil}) // Codigo do Produto
	aAdd(aIteTempPV,{"C6_QTDVEN" , 1                                   , Nil}) // Qtde Vendida
	aAdd(aIteTempPV,{"C6_QTDLIB" , 0                                   , Nil})
	aAdd(aIteTempPV,{"C6_TES"    , oGetResVO4:aCols[nCntFor,RVO4CODTES], Nil}) // Tipo de Saida do Item
	aAdd(aIteTempPV,{"C6_PRUNIT" , n_VALBRU                            , Nil}) // Preco de Lista (Valor do Servico sem Desconto)
	aAdd(aIteTempPV,{"C6_PRCVEN" , n_VALBRU                            , Nil}) // Preco Unitario (Valor do Servico com Desconto )
	aAdd(aIteTempPV,{"C6_VALOR"  , n_VALBRU                            , Nil}) // Valor Total do Item
	aAdd(aIteTempPV,{"C6_VALDESC", n_VALDES                            , Nil}) // Valor do Desconto
	// Ticket: 1932063
	// ISSUE: MMIL-2426
	// O TES estแ sendo enviado novamente pois na base o cliente ocorria uma falha. O conteudo do TES na aCols (MATA410)
	// ficava com conte๚do VAZIO.
	// O problema nao foi reproduzido em base teste, mas verificamos que passando o TES novamente a falha nใo ocorria novamente
	// A mensagem de HELP disparada era A410VZ.
	aAdd(aIteTempPV,{"C6_TES"    , oGetResVO4:aCols[nCntFor,RVO4CODTES], Nil}) // Tipo de Saida do Item
	aAdd(aIteTempPV,{"C6_ENTREG" , dDataBase                           , Nil}) // Data da Entrega
	aAdd(aIteTempPV,{"C6_UM"     , SB1->B1_UM                          , Nil}) // Unidade de Medida Primaria
	aAdd(aIteTempPV,{"C6_LOCAL"  , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") , Nil}) // Almoxarifado
	aAdd(aIteTempPV,{"C6_CLI"    , SA1->A1_COD                         , Nil}) // Cliente
	aAdd(aIteTempPV,{"C6_LOJA"   , SA1->A1_LOJA                        , Nil}) // Loja do Cliente
	
	If SC6->(FieldPos("C6_CC"))>0  .and. RVO4CENCUS <> 0
		aAdd(aIteTempPV,{"C6_CC" , oGetResVO4:aCols[nCntFor,RVO4CENCUS] , Nil})
	Endif
	
	If SC6->(FieldPos("C6_CONTA"))>0 .and. RVO4CONTA <> 0
		aAdd(aIteTempPV,{"C6_CONTA" , oGetResVO4:aCols[nCntFor,RVO4CONTA] , Nil})
	Endif
	
	If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. RVO4ITEMCT <> 0
		aAdd(aIteTempPV,{"C6_ITEMCTA" , oGetResVO4:aCols[nCntFor,RVO4ITEMCT] , Nil})
	Endif
	
	If SC6->(FieldPos("C6_CLVL"))>0  .and. RVO4CLVL <> 0
		aAdd(aIteTempPV,{"C6_CLVL" , oGetResVO4:aCols[nCntFor,RVO4CLVL] , Nil})
	Endif
	
	If SC6->(FieldPos("C6_NUMPCOM"))>0 .and. RVO4PEDXML <> 0
		aAdd(aIteTempPV,{"C6_NUMPCOM" , oGetResVO4:aCols[nCntFor,RVO4PEDXML] , Nil})
	Endif

	If SC6->(FieldPos("C6_ITEMPC"))>0 .and. RVO4ITEXML <> 0
		aAdd(aIteTempPV,{"C6_ITEMPC" , oGetResVO4:aCols[nCntFor,RVO4ITEXML] , Nil})
	Endif

	If lAliqISS .and. M->VOO_ALIISS > 0
		aAdd(aIteTempPV,{"C6_ALIQISS" , M->VOO_ALIISS , Nil})
	EndIf
	
	//
	If lOX100AIP
		aIteTempPV := ExecBlock("OX100AIP",.f.,.f.,{aIteTempPV})
	EndIf
	//
	
	aAdd(aIte,aClone(aIteTempPV))
	
	// Adiciona na Matriz de Relacionamento do oGetDetVO3:aCols/oGetResVO4:aCols com o SC6,
	// utilizado depois para gerar VEC e VSC ...
	AADD( aRelFatOfi, { "VO4" , nCntFor , cItemPed , "" } )
	//
	
Next nCntFor

Return


/*/{Protheus.doc} OX100CONDNEG

Valida se uma condi็ใo de pagamento pode ser utilizada no fechamento

@author Rubens
@since 17/07/2015
@version 1.0
@param aTipTem, array, Matriz com os tipos de tempos selecionados para fechamento
@param lCupom, booleano, Indica se gera Cupom
@param lNF, booleano, Indica se gera Nota Fiscal
@return lRetorno, Indica se a condi็ใo de pagamento pode ser utilizada no fechamento

/*/
Static Function OX100CONDNEG( aTipTem , lCupom , lNF )

Local lRetorno := .t.
Private lVldGarPeca := .t. // manter variavel Private

SE4->(dbSetOrder(1))
SE4->(MsSeek( xFilial("SE4") + M->VOO_CONDPG ))

If !SE4->E4_TIPO $ "9/A"
	Return .t.
EndIf

//PE para Valida็ใo da Condi็ใo de Pagamento no Fechamento
If ExistBlock("OX100VCP")
	If !ExecBlock("OX100VCP",.f.,.f.,{ SE4->E4_TIPO })
		Return .f.
	EndIf
EndIf

If lVldGarPeca .and. SE4->E4_TIPO == "A" .and. !lGarPeca //.and. !lNF
	MsgInfo(STR0105,STR0004) // "Favor selecionar uma condi็ใo de pagamento diferente de tipo 'A'"
	Return .f.
EndIf

If lNF
	If !lMVMIL0059 .and. Len(aTipTem) > 1
		lRetorno := .f.
		MsgAlert(STR0112,STR0004) // Impossํvel fechar dois ou mais tipos de tempo utilizando condi็ใo tipo '9'
	Else
		If !lMVMIL0084 .and. (aScan(aTipTem,{ |x| x[FTT_TIPFEC] == "P" }) <> 0) .and. (aScan(aTipTem,{ |x| x[FTT_TIPFEC] == "S" }) <> 0)
			lRetorno := .f.
			MsgAlert(STR0126,STR0004) // "Impossํvel fechar pe็as e servi็os juntos utilizando uma condi็ใo tipo '9'."
		EndIf
	EndIf
EndIf

If lCupom
	If (aScan(aTipTem,{ |x| x[FTT_TIPFEC] == "P" }) <> 0) .and. (aScan(aTipTem,{ |x| x[FTT_TIPFEC] == "S" }) <> 0)
		lRetorno := lLJPRDSV
		If !lRetorno
			MsgAlert(STR0126,STR0004) // "Impossํvel fechar pe็as e servi็os juntos utilizando uma condi็ใo tipo '9'."
		EndIf
	Endif
EndIf


Return lRetorno


/*/{Protheus.doc} OX100TIPTEM

Adiciona um Tipo de Tempo na matriz de tipo de tempos selecionados para fechamento.
Matriz difere da aVetTTP pois a aVetTTP possui todas as liberacoes (VOO) selecionadas para fechamento

@author Rubens
@since 17/07/2015
@version 1.0
@param nPosVetTTP, num้rico, Posicao da matriz aVetTTP que estแ sendo processado
@param aTipTem, array, Matriz de Tipo de Tempo selecionado para fechamento
@param lFecha, booleano, Inidica se a funcao esta sendo chamada na Confirmacao do Fechamento

/*/
Static Function OX100TIPTEM( nPosVetTTP, aTipTem , lFecha )

Local nCntVO4

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")

If lFecha
	SE4->(dbSetOrder(1))
	SE4->(dbSeek( xFilial("SE4") + M->VOO_CONDPG ))
EndIf

nPosAux := aScan( aTipTem , { |x| x[1] == aVetTTP[nPosVetTTP, ATT_TIPTEM] } )
If nPosAux == 0
	AADD( aTipTem , Array(14) )
	nPosAux := Len(aTipTem)
	aTipTem[ nPosAux , FTT_TIPTEM   ] := aVetTTP[nPosVetTTP, ATT_TIPTEM]  // 01 - Tipo de Tempo
	aTipTem[ nPosAux , FTT_CLIENTE  ] := aVetTTP[nPosVetTTP, ATT_CLIENTE] // 02 - Codigo do Cliente
	aTipTem[ nPosAux , FTT_LOJA     ] := aVetTTP[nPosVetTTP, ATT_LOJA]    // 03 - Loja do Cliente
	aTipTem[ nPosAux , FTT_QTDE     ] := 0                             // 04 - Qtde de TT Selecionado
	aTipTem[ nPosAux , FTT_SERNFI   ] := ""                            // 05 - Serie da NF Gerada
	aTipTem[ nPosAux , FTT_NUMNFI   ] := ""                            // 06 - Numero da NF Gerada
	aTipTem[ nPosAux , FTT_CODVEN   ] := aVetTTP[nPosVetTTP, ATT_CODVEN]  // 07 - Codigo do Vendedor
	aTipTem[ nPosAux , FTT_TIPFEC   ] := ""                            // 08 - Indica o Tipo de Fechamento ( "P" = Pecas / "S" = Servicos ), Pecas sempre sobrepoe Servicos ...
	aTipTem[ nPosAux , FTT_VS9WHERE ] := ""                            // 09 - Condicao para selecao dos registros do VS9 para condicao negociada
	aTipTem[ nPosAux , FTT_NFSRVC   ] := .f.                           // 10 - Quando for faturamento de Servico, indica se vai ser gerado NF
	aTipTem[ nPosAux , FTT_CODBCO   ] := ""                            // 11 - Banco selecionado na condicao de pagamento
	aTipTem[ nPosAux , FTT_ORCLOJA  ] := ""                            // 12 - Numero do Orcamento no SIGALOJA
	aTipTem[ nPosAux , FTT_NUMOSV   ] := aVetTTP[nPosVetTTP, ATT_NUMOSV]  // 13 - Numero da OS (utilizado somente para integracao com LOJA )
	aTipTem[ nPosAux , FTT_PEDFAT   ] := ""                            // 14 - Numero do Pedido de Venda Gerado
EndIf

aTipTem[nPosAux, FTT_QTDE]++

If aTipTEm[nPosAux,FTT_TIPFEC] <> "P"
	// Se tiver pecas
	If aVetTTP[nPosVetTTP, ATT_TOTPEC] > 0
		aTipTem[nPosAux,FTT_TIPFEC] := "P"
	EndIf
	
	// Se tiver servicos
	If aVetTTP[nPosVetTTP, ATT_TOTSER] > 0
		If Empty(aTipTem[nPosAux,FTT_TIPFEC])
			aTipTem[nPosAux,FTT_TIPFEC] := "S"
		EndIf
		
		// Tipo de Tempo Interno, nใo gera NF de Servico ...
		If aVetTTP[ nPosVetTTP , ATT_SITTPO ] == "3"
			aTipTem[nPosAux,FTT_NFSRVC] := .f.
			// Se nใo for TT Interno, verifica se existe pelo menos um tipo de cobranca diferente de Mao de Obra Gratuita ...
		Else
			VOK->(dbSetOrder(1))
			For nCntVO4 := 1 to Len(oGetResVO4:aCols)
				
				If oGetResVO4:aCols[nCntVO4, RVO4TIPTEM] <> aTipTem[nPosAux,FTT_TIPTEM]
					Loop
				EndIf
				
				VOK->(MsSeek( xFilial("VOK") + oGetResVO4:aCols[nCntVO4, RVO4TIPSER ] ))
				// Mใo de Obra diferente de Gratuita ...
				If VOK->VOK_INCMOB <> "0"
					aTipTem[nPosAux,FTT_NFSRVC] := .t.
					Exit
				EndIf
				//
			Next nCntVO4
		EndIf
		//
		
	EndIf
	//
EndIf

If lFecha .and. ( OX1000061_Condicao_Negociada() .or. (SE4->E4_TIPO == "A" .and. lGarPeca))
	If !Empty(aTipTem[nPosAux,FTT_VS9WHERE])
		aTipTem[nPosAux,FTT_VS9WHERE] += " OR "
	EndIf
	aTipTem[nPosAux,FTT_VS9WHERE] += " ( VS9.VS9_NUMIDE = '" + aVetTTP[nPosVetTTP, ATT_NUMOSV] + "' AND "
	aTipTem[nPosAux,FTT_VS9WHERE] +=   " VS9.VS9_TIPTEM = '" + aVetTTP[nPosVetTTP, ATT_TIPTEM] + "' "
	aTipTem[nPosAux,FTT_VS9WHERE] += " AND VS9.VS9_LIBVOO = '" + aVetTTP[nPosVetTTP,ATT_LIBVOO] + "'"
	aTipTem[nPosAux,FTT_VS9WHERE] +="  )"
EndIf

Return


/*/{Protheus.doc} OX100CPVOO

Faz uma relacao DE -> PARA dos campos da tabela VOO que serใo gravados na SC5

@author Rubens
@since 19/08/2015
@version 1.0
@param cCampo, caracter, Nome do campo da VOO

/*/
Static Function OX100CPVOO( cCampo )
Local nPos := 0
If (nPos := aScan(aVOO_DEPARA,{ |x| x[1] == cCampo })) > 0
	If &( aVOO_DEPARA[nPos,2] + "->(FieldPos('" + aVOO_DEPARA[nPos,3] + "'))" ) <> 0
		AADD( aVOOSC5 , { aVOO_DEPARA[nPos,4] , aVOO_DEPARA[nPos,3] , aVOO_DEPARA[nPos,1] } )
		Return .t.
	Else
		Return .f.
	EndIf
Endif
Return .t.

/*/{Protheus.doc} OX100AVAL

Avalia็ใo de Resultado

@author Rubens
@since 03/09/2015
@version 1.0
/*/
Static Function OX100AVAL()

Private cTipAva  := "4"
Private cParPro  := "1"
Private cContChv := "VEC_NUMORC"
Private cParTem  := ""
Private cSimVda  := "S"

If aScan(aVetTTP,{ |x| x[ATT_VETSEL] }) == 0 .or. lCanSel
	MsgAlert(STR0053,STR0004) // "Selecionar um registro para faturamento"
	Return .f.
EndIf

If !PERGUNTE("ATDOFI")
	Return .t.
EndIf

Private cMapPecas := MV_PAR01
Private cMapSrvcs := MV_PAR02
Private cMapOdSrv := MV_PAR03

cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))
aStruP := {}
aStruS := {}
aStruO := {}

MSGRUN( STR0146 , STR0056 ,{ || CursorWait() , OX100AVRES() , CursorArrow()}) //Aguarde... Processando Mapa de Avaliacao

VV1->(dbSetOrder(1))
VV1->(dbSeek(xFilial("VV1") + aVetTTP[ 1, ATT_CHAINT ] ))

FG_ResAva(cOutMoed,3,"S","","OFIXX100",{aStruP,aStruS,aStruO})

Return

/*/{Protheus.doc} OX100AVRES

Processa Avalia็ใo de Resultado

@author Rubens
@since 03/09/2015
@version 1.0

/*/
Static Function OX100AVRES()

Local nPosTTp
Local aNumIde := {}
Local cNumIde := ""
Local cProcOS := ""

Local aStruBase := {}
Local aSomaStruBase := {}
Local nPos

Local cCpoDiv := "    1"

Private lCalcTot := .f.
Private cCodMap

// Gerando Base para Avaliacao de Restuldado
For nPosTTp := 1 to Len(aVetTTP)
	If !aVetTTP[ nPosTTp , ATT_VETSEL ]
		Loop
	EndIf
	If !aVetTTP[nPosTTp, ATT_NUMOSV] $ cProcOS
		cNumIde := OX100IDEAVAL( aVetTTP[ nPosTTp , ATT_NUMOSV ] , cNumIde )
		OX100DELAVAL( aVetTTP[ nPosTTp, ATT_NUMOSV ] , "" )
		cProcOS += aVetTTP[ nPosTTp, ATT_NUMOSV ]
	EndIf
Next nPosTTp
OX100VSY( cNumIde , "" )
OX100VSZ( cNumIde , "" )
//

// Avaliacao de Pecas
If Len(aAuxVO3) > 0
	cCodMap := cMapPecas
	
	OX100LMAPA( cMapPecas , @aStruBase , @aSomaStruBase )
	aStruP := {}
	
	lCalcTot := .f.
	OX100VSYPROC( cNumIde , cMapPecas , @aStruP , @cCpoDiv , aStruBase , aSomaStruBase )
	If Len(aStruP) > 0
		// Inicializa informacoes para calculo do Total ...
		lCalcTot := .t.
		nPosVet := Len(aStruP)
		aEval(aStruBase,{ |x| AADD( aStruP , aClone(x) ) })
		aEval( aStruP ,{ |x| ( x[01] := NIL , x[03] := STR0147 )  } , nPosVet + 1 , Len(aStruBase) )
		
		cNumero := cNumIde
		aStruP := FG_CalcVlrs(aStruP,STR0147,cCpoDiv) // Nao deve enviar o numero da OS, pois ser calculado o total de pecas ...
		//
	EndIf
EndIf

// Avaliacao de Servicos
If Len(aAuxVO4) > 0
	cCodMap := cMapSrvcs
	
	OX100LMAPA( cMapSrvcs , @aStruBase , @aSomaStruBase )
	aStruS := {}
	cCpoDiv   := "    1"
	
	lCalcTot := .f.
	OX100VSZPROC( cNumIde , cMapSrvcs , @aStruS , @cCpoDiv , aStruBase , aSomaStruBase )
	If Len(aStruS) > 0
		// Inicializa informacoes para calculo do Total ...
		lCalcTot := .t.
		nPosVet := Len(aStruS)
		aEval( aStruBase,{ |x| AADD( aStruS , aClone(x) ) })
		aEval( aStruS ,{ |x| ( x[01] := NIL , x[03] := STR0147 )  } , nPosVet + 1 , Len(aStruBase) )
		
		cNumero := cNumIde
		aStruS := FG_CalcVlrs(aStruS,STR0147,cCpoDiv)
		//
	EndIf
EndIf

// Avaliacao da Ordem de Servico
cCodMap := cMapOdSrv

OX100LMAPA( cMapOdSrv , @aStruBase , @aSomaStruBase )

aStruO := {}
cCpoDiv := "    1"
lCalcTot := .t.
If Len(aStruP) > 0
	OX100VSYPROC( cNumIde , cMapOdSrv , @aStruO , @cCpoDiv , aStruBase , aSomaStruBase , .t. )
EndIf
If Len(aStruS) > 0
	OX100VSZPROC( cNumIde , cMapOdSrv , @aStruO , @cCpoDiv , aStruBase , aSomaStruBase , .t. )
EndIf
nPosVet := Len(aStruO)

aEval( aStruBase,{ |x| AADD( aStruO , aClone(x) ) })
aEval( aStruO   ,{ |x| ( x[01] := NIL , x[03] := STR0147 )  } , nPosVet + 1 , Len(aStruBase) )
//

cNumero := cNumIde
aStruO := FG_CalcVlrs(aStruO,STR0147,cCpoDiv)


Return


/*/{Protheus.doc} OX100VSY

Cria os registros bases de pecas para avaliacao do resultado (VSY)

@author Rubens
@since 03/09/2015
@version 1.0
@param cNumIde, character, N๚mero de Identificacao para identificacao do registro

/*/
Static Function OX100VSY( cNumIde , cNumOsv, cTipTem, cLibVOO )

Local nPerc
Local nCntFor
Local nPosGet
Local lOX001VEC := ExistBlock("OX001VEC")

Local lVSYVALIRR  := VSY->(FieldPos("VSY_VALIRR")) > 0
Local lVSYVALCSL  := VSY->(FieldPos("VSY_VALCSL")) > 0
Local nValIRR   := 0
Local nValCSL   := 0

Local DVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Det")
Local DVO3CODTES := FG_POSVAR("VO3_CODTES","aHVO3Det")
Local DVO3GRUITE := FG_POSVAR("VO3_GRUITE","aHVO3Det")
Local DVO3CODITE := FG_POSVAR("VO3_CODITE","aHVO3Det")
Local DVO3VALPEC := FG_POSVAR("VO3_VALPEC","aHVO3Det")
Local DVO3QTDREQ := FG_POSVAR("VO3_QTDREQ","aHVO3Det")
Local DVO3VALBRU := FG_POSVAR("VO3_VALBRU","aHVO3Det")
Local DVO3VALDES := FG_POSVAR("VO3_VALDES","aHVO3Det")
Local DVO3VALTOT := FG_POSVAR("VO3_VALTOT","aHVO3Det")
Local DVO3LOTECT := FG_POSVAR("VO3_LOTECT","aHVO3Det")
Local DVO3NUMLOT := FG_POSVAR("VO3_NUMLOT","aHVO3Det")
Local DSEQFEC    := FG_POSVAR("SEQFEC","aHVO3Det")

For nPosGet := 1 to Len(oGetDetVO3:aCols)
	
	// Linha em branco ...
	If Len(oGetDetVO3:aCols) == 1 .and. Empty(oGetDetVO3:aCols[nPosGet,DVO3TIPTEM])
		Loop
	EndIf
	//
	
	nCntFor := aScan(aAuxVO3,{ |x| ;
			x[AP_TIPTEM] == oGetDetVO3:aCols[nPosGet, DVO3TIPTEM] .and. ;
			x[AP_GRUITE] == oGetDetVO3:aCols[nPosGet, DVO3GRUITE] .and. ;
			x[AP_CODITE] == oGetDetVO3:aCols[nPosGet, DVO3CODITE] .and. ;
			x[AP_VALPECGET] == oGetDetVO3:aCols[nPosGet, DVO3VALPEC] .and. ;
			(!lCtrlLote .or. (x[AP_LOTECT] == oGetDetVO3:aCols[nPosGet, DVO3LOTECT] .and. x[AP_NUMLOT] == oGetDetVO3:aCols[nPosGet,DVO3NUMLOT] )) })
	
	If !Empty(cNumOsv) .and. ( cNumOsv <> aAuxVO3[nCntFor, AP_NUMOSV ] .or. cTipTem <> aAuxVO3[nCntFor, AP_TIPTEM] .or. cLibVOO <> aAuxVO3[nCntFor, AP_LIBVOO] )
		Loop
	EndIf
	
	VOI->(dbSetOrder(1))
	VOI->(MsSeek(xFilial("VOI") + oGetDetVO3:aCols[ nPosGet, DVO3TIPTEM ] ))
	
	SB1->(DbSetOrder(7))
	SB1->(DbSeek(xFilial("SB1") + oGetDetVO3:aCols[nPosGet, DVO3GRUITE ] + oGetDetVO3:aCols[nPosGet, DVO3CODITE ] ))
	SB1->(DbSetOrder(1))
	
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + VOI->VOI_CODALM))
	
	//
	OX100PECFIS( nPosGET )
	nValPis   := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
	nValCof   := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
	aLivroVEC := MaFisRet(n,"IT_LIVRO")
	nValICM   := aLivroVEC[5]
	nAliICM   := aLivroVEC[2]
	nBaseIcm  := MaFisRet(n,"IT_BASEICM")
	nValIRR   := MaFisRet(n,"IT_VALIRR")
	nValCSL   := MaFisRet(n,"IT_VALCSL")
	//
	
	nPerc := 1
	
	DbSelectArea("VSY")
	RecLock("VSY",.t.)
	VSY->VSY_FILIAL := xFilial("VSY")
	VSY->VSY_NUMIDE := cNumIde
	VSY->VSY_NUMOSV := aAuxVO3[nCntFor, AP_NUMOSV ]
	VSY->VSY_TIPTEM := VOI->VOI_TIPTEM
	VSY->VSY_LIBVOO := aAuxVO3[nCntFor, AP_LIBVOO ]
	VSY->VSY_DATVEN := dDataBase
	VSY->VSY_PECINT := SB1->B1_COD
	VSY->VSY_GRUITE := oGetDetVO3:aCols[ nPosGet , DVO3GRUITE ]
	VSY->VSY_CODITE := oGetDetVO3:aCols[ nPosGet , DVO3CODITE ]
	VSY->VSY_QTDITE := oGetDetVO3:aCols[ nPosGet , DVO3QTDREQ ]
	VSY->VSY_VALBRU := oGetDetVO3:aCols[ nPosGet , DVO3VALBRU ]
	VSY->VSY_VALDES := oGetDetVO3:aCols[ nPosGet , DVO3VALDES ]
	VSY->VSY_VALVDA := oGetDetVO3:aCols[ nPosGet , DVO3VALTOT ]
	VSY->VSY_VALICM := nValICM
	VSY->VSY_ALQICM := nAliICM
	VSY->VSY_VALCOF := nValPis
	VSY->VSY_VALPIS := nValCof
	VSY->VSY_TOTIMP := VSY->VSY_VALICM + VSY->VSY_VALCOF + VSY->VSY_VALPIS
	VSY->VSY_CUSMED := SB2->B2_CM1 * VSY->VSY_QTDITE
	VSY->VSY_JUREST := FG_JUREST(,SB1->B1_COD,SB1->B1_UCOM,dDataBase,"P")
	VSY->VSY_CUSTOT := VSY->VSY_CUSMED + VSY->VSY_JUREST
	VSY->VSY_LUCBRU := VSY->VSY_VALVDA - VSY->VSY_TOTIMP - VSY->VSY_CUSTOT
	
	// Comissao
	aVetTra := aClone(aBoqPec)
	OX100VETCOM( VOI->VOI_TIPTEM , @aVetTra )
	
	aValCom    := FG_COMISS("P",aVetTra,VSY->VSY_DATVEN,VSY->VSY_GRUITE,VSY->VSY_VALVDA,"T")
	VSY->VSY_COMVEN := aValCom[1]
	VSY->VSY_COMGER := aValCom[2]
	aValCom    := FG_COMISS("P",aVetTra,VSY->VSY_DATVEN,VSY->VSY_GRUITE,VSY->VSY_VALVDA,"D")
	VSY->VSY_CMFVEN := FG_CALCMF(aValCom[1])
	VSY->VSY_CMFGER := FG_CALCMF(aValCom[2])
	//
	
	VSY->VSY_DESVAR := VSY->VSY_COMVEN + VSY->VSY_COMGER
	VSY->VSY_LUCLIQ := VSY->VSY_LUCBRU - VSY->VSY_DESVAR
	VSY->VSY_DESFIX := 0
	VSY->VSY_CUSFIX := 0
	VSY->VSY_DESDEP := 0
	VSY->VSY_DESADM := 0
	VSY->VSY_RESFIN := VSY->VSY_LUCLIQ - VSY->VSY_DESFIX - VSY->VSY_CUSFIX - VSY->VSY_DESDEP - VSY->VSY_DESADM
	VSY->VSY_BALOFI := "O" && Oficina
	If VOI->VOI_SITTPO == "3"
		VSY->VSY_DEPVEN := aAuxVO3[nCntFor, AP_DEPINT] // aColsFEC[2,ixi,FS_POSVAR("VO3_DEPINT","aHeaderFEC",2)]
	EndIf
	If VOI->VOI_SITTPO == "2"
		VSY->VSY_DEPVEN := aAuxVO3[nCntFor, AP_DEGGAR] // aColsFEC[2,ixi,FS_POSVAR("VO3_DEPGAR","aHeaderFEC",2)]
	EndIf
	
	VSY->VSY_VMFBRU := FG_CALCMF( {{dDataBase , VSY->VSY_VALBRU}} )
	VSY->VSY_VMFVDA := VSY->VSY_VMFBRU - FG_CALCMF( {{dDataBase,VSY->VSY_VALDES}} )
	VSY->VSY_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VSY->VSY_VALICM} })
	VSY->VSY_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VSY->VSY_VALPIS} })
	VSY->VSY_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VSY->VSY_VALCOF} })
	VSY->VSY_TMFIMP := VSY->VSY_VMFICM + VSY->VSY_VMFCOF + VSY->VSY_VMFPIS

	If lVSYVALIRR // IRRF
		VSY->VSY_VALIRR := nValIRR
		VSY->VSY_VMFIRR := FG_CALCMF( {{dDataBase , VSY->VSY_VALIRR}} )
	EndIf
	If lVSYVALCSL // CSLL
		VSY->VSY_VALCSL := nValCSL
		VSY->VSY_VMFCSL := FG_CALCMF( {{dDataBase , VSY->VSY_VALCSL}} )
	EndIf

	VSY->VSY_CMFMED := FG_CALCMF( { {dDataBase,SB2->B2_CM1} }) * VSY->VSY_QTDITE
	VSY->VSY_JMFEST := FG_CALCMF( { {dDataBase,VSY->VSY_JUREST} })
	VSY->VSY_CMFTOT := VSY->VSY_CMFMED + VSY->VSY_JMFEST
	VSY->VSY_LMFBRU := VSY->VSY_VMFVDA - VSY->VSY_TMFIMP - VSY->VSY_CMFTOT
	
	VSY->VSY_DMFVAR := VSY->VSY_CMFVEN + VSY->VSY_CMFGER
	VSY->VSY_LMFLIQ := VSY->VSY_LMFBRU - VSY->VSY_DMFVAR
	VSY->VSY_DMFFIX := 0
	VSY->VSY_CMFFIX := 0
	VSY->VSY_DMFDEP := 0
	VSY->VSY_DMFADM := 0
	VSY->VSY_RMFFIN := VSY->VSY_LMFLIQ - VSY->VSY_DMFFIX - VSY->VSY_CMFFIX - VSY->VSY_DMFDEP - VSY->VSY_DMFADM
	
	VSY->(MsUnlock())
	
	If lOX001VEC
		ExecBlock("OX001VEC",.f.,.f.,{ VSY->VSY_PECINT , VSY->VSY_DATVEN , oGetDetVO3:aCols[ nPosGet , DVO3TIPTEM ] , 0 , VSY->VSY_QTDITE , "VSY" })
	EndIf
	
Next

Return


/*/{Protheus.doc} OX100LMAPA

Carrega o mapa de avaliacao

@author Rubens
@since 03/09/2015
@version 1.0
@param cCodMap, character, Codigo do Mapa de Avaliacao
@param aStruBase, array, Cria uma matriz auxiliar para adicionar no aStruP e aStruS
@param aSomaStruBase, array, Cria uma matriz auxiliar para adicionar no aSomaStru

/*/
Static Function OX100LMAPA( cCodMap , aStruBase , aSomaStruBase )

Local cAliasVOQ := "TVOQ"
Local cSQL := ""

aStruBase     := {}
aSomaStruBase := {}

cSQL := "SELECT VOQ_CLAAVA, VOQ_DESAVA, VOQ_ANASIN, VOQ_CODIGO, VOQ_SINFOR, VOQ_PRIFAI, VOQ_SEGFAI, VOQ_FUNADI, VOQ_CODIMF, VOQ_CTATOT"
cSQL +=  " FROM " + RetSQLName("VOQ") + " VOQ "
cSQL += " WHERE VOQ.VOQ_FILIAL = '" + xFilial("VOQ") + "'"
cSQL +=   " AND VOQ.VOQ_CODMAP = '" + cCodMap + "'"
cSQL +=   " AND VOQ.VOQ_INDATI = '1'"
cSQL +=   " AND VOQ.D_E_L_E_T_ = ' '"
cSQL +=  " ORDER BY VOQ_CLAAVA"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVOQ , .F., .T. )
While !(cAliasVOQ)->(Eof())
	AADD( aStruBase , {;
	,; // VSY->VSY_NUMOSV,;
	,;
	"",; // SB1->B1_COD,;
	(cAliasVOQ)->VOQ_CLAAVA,;
	IIf( (cAliasVOQ)->VOQ_ANASIN <> "0" , Space(7) ,"" ) + (cAliasVOQ)->VOQ_DESAVA ,;
	(cAliasVOQ)->VOQ_ANASIN,;
	(cAliasVOQ)->VOQ_CODIGO,;
	(cAliasVOQ)->VOQ_SINFOR,;
	0,;
	0,;
	,;// SB1->B1_GRUPO+" "+SB1->B1_CODITE,;
	0,;
	0,;
	.f.,;
	(cAliasVOQ)->VOQ_PRIFAI,;
	(cAliasVOQ)->VOQ_SEGFAI,;
	(cAliasVOQ)->VOQ_FUNADI,;
	(cAliasVOQ)->VOQ_CODIMF,;
	dDataBase,;
	0,;
	0,;
	(cAliasVOQ)->VOQ_CTATOT;
	})
	
	AADD(aSomaStruBase,{0,0,0,0,0,0})
	
	(cAliasVOQ)->(dbSkip())
End
(cAliasVOQ)->(dbCloseArea())

Return


/*/{Protheus.doc} OX100VSYPROC

Processa os registros da VSY para avaliacao de resultado

@author Rubens
@since 03/09/2015
@version 1.0
@param cNumIde, character, Numero de Identificacao da Avaliacao (VSY_NUMIDE)
@param cAuxMap, character, C๓digo do Mapara de Avaliacao
@param aAuxStru, array, Array que esta sendo utilizada para o acumulo dos valores da Avaliacao (aStruP)
@param cCpoDiv, character, Campo de controle para gravar o elemento inicial de cada peca
@param aStruBase, array, Array base para adicionar na matriz aAuxStru (aStruP)
@param aSomaStruBase, array, Array base para adicionar na matriz aSomaStru
@param lMapOS, booleano, Indica se a chamada ้ para o calculo do total da Ordem de Servico Inteira (Pe็as e Servi็os)

/*/
Static Function OX100VSYPROC( cNumIde , cAuxMap , aAuxStru , cCpoDiv , aStruBase , aSomaStruBase , lMapOS )

Local n_ := 0
Local cSQL
Local nPosVet
Local cAliasVSY := "TVSY"
Local aSomaStru := {}
Local lProc := .f.

Default lMapOS := .f.

cSQL := "SELECT VSY.R_E_C_N_O_ VSYRECNO, B1_COD"
cSQL +=  " FROM " + RetSQLName("VSY") + " VSY "
cSQL +=         " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_GRUPO = VSY.VSY_GRUITE AND SB1.B1_CODITE = VSY.VSY_CODITE AND SB1.D_E_L_E_T_ = ' '"
cSQL += " WHERE VSY.VSY_FILIAL = '" + xFilial("VSY") + "'"
cSQL +=   " AND VSY.VSY_NUMIDE = '" + cNumIde + "'"
cSQL +=   " AND VSY.D_E_L_E_T_ = ' '"
cSQL += " ORDER BY VSY.VSY_GRUITE, VSY.VSY_CODITE"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVSY , .F., .T. )
While !(cAliasVSY)->(Eof())
	
	lProc := .t.
	
	VSY->(dbGoTo( (cAliasVSY)->VSYRECNO ))
	
	If ( nPosVet := aScan(aAuxStru,{|x| x[1] == VSY->VSY_NUMOSV .and. x[3] == (cAliasVSY)->B1_COD }) ) == 0
		nPosVet := Len(aAuxStru) + 1
		aEval(aStruBase,{ |x| AADD( aAuxStru , aClone(x) ) })
		aEval(aSomaStruBase , { |x| AADD( aSomaStru , aClone(x) ) } )
	EndIf
	
	// Inicializa informacoes para calculo ...
	aEval( aAuxStru ,{ |x| ( ;
	x[01] := VSY->VSY_NUMOSV ,;
	x[03] := (cAliasVSY)->B1_COD ,;
	x[11] := VSY->VSY_GRUITE + " " + VSY->VSY_CODITE ,;
	x[09] := x[10] := x[12] := x[13] := x[20] := x[21] := 0 , ;
	x[14] := .f. ) } , nPosVet , Len(aStruBase) )
	//
	
	cNumero   := alltrim(cNumIde)
	aAuxStru := FG_CalcVlrs(aAuxStru , (cAliasVSY)->B1_COD , cCpoDiv ,,,, VSY->VSY_NUMOSV )
	
	cCpoDiv += "#" + str(len(aAuxStru)+1,5)
	
	If !lMapOS
		For n_ := nPosVet to Len(aSomaStru)
			aSomaStru[n_,1] += aAuxStru[n_,9]
			aSomaStru[n_,3] += aAuxStru[n_,12]
			aSomaStru[n_,5] += aAuxStru[n_,20]
		Next
		
		For n_:=1 to Len(aSomaStru)
			aAuxStru[n_,9]  := aSomaStru[n_,1]
			aAuxStru[n_,12] := aSomaStru[n_,3]
			aAuxStru[n_,20] := aSomaStru[n_,5]
		Next
	EndIf
	
	(cAliasVSY)->(dbSkip())
End
(cAliasVSY)->(dbCloseArea())

Return lProc

/*/{Protheus.doc} OX100VSZPROC

Processa os registros da VSZ para avaliacao de resultado

@author Rubens
@since 03/09/2015
@version 1.0
@param cNumIde, character, Numero de Identificacao da Avaliacao (VSZ_NUMIDE)
@param cAuxMap, character, C๓digo do Mapara de Avaliacao
@param aAuxStru, array, Array que esta sendo utilizada para o acumulo dos valores da Avaliacao (aStruS)
@param cCpoDiv, character, Campo de controle para gravar o elemento inicial de cada servico
@param aStruBase, array, Array base para adicionar na matriz aAuxStru (aStruS)
@param aSomaStruBase, array, Array base para adicionar na matriz aSomaStru
@param lMapOS, booleano, Indica se a chamada ้ para o calculo do total da Ordem de Servico Inteira (Pe็as e Servi็os)

/*/
Static Function OX100VSZPROC( cNumIde , cAuxMap , aAuxStru , cCpoDiv , aStruBase , aSomaStruBase , lMapOS )

Local n_ := 0
Local cSQL
Local nPosVet
Local cAliasVSZ := "TVSZ"
Local aSomaStru := {}
Local lProc := .f.

Default lMapOS := .f.

cSQL := "SELECT VSZ.R_E_C_N_O_ VSZRECNO"
cSQL +=  " FROM " + RetSQLName("VSZ") + " VSZ "
cSQL += " WHERE VSZ.VSZ_FILIAL = '" + xFilial("VSZ") + "'"
cSQL +=   " AND VSZ.VSZ_NUMIDE = '" + cNumIde + "'"
cSQL +=   " AND VSZ.D_E_L_E_T_ = ' '"
cSQL += " ORDER BY VSZ.VSZ_NUMOSV, VSZ.VSZ_TIPTEM, VSZ.VSZ_CODSER"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVSZ , .F., .T. )
While !(cAliasVSZ)->(Eof())
	
	lProc := .t.
	
	VSZ->(dbGoTo( (cAliasVSZ)->VSZRECNO ))
	
	If ( nPosVet := aScan(aAuxStru, {|x| x[1] == VSZ->VSZ_NUMOSV .and. x[3] == VSZ->VSZ_CODSER } ) ) == 0
		nPosVet := Len(aAuxStru) + 1
		aEval(aStruBase,{ |x| AADD( aAuxStru , aClone(x) ) })
		aEval(aSomaStruBase , { |x| AADD( aSomaStru , aClone(x) ) } )
	EndIf
	
	// Inicializa informacoes para calculo ...
	aEval( aAuxStru ,{ |x| ( ;
	x[01] := VSZ->VSZ_NUMOSV ,;
	x[03] := VSZ->VSZ_CODSER ,;
	X[11] := VSZ->VSZ_CODSER ,;
	x[09] := x[10] := x[12] := x[13] := x[20] := x[21] := 0 , ;
	x[14] := .f. ) } , nPosVet , Len(aStruBase) )
	//
	
	If !lMapOS
		cNumero := SubStr(AllTrim(cNumIde),3)
	EndIf
	aAuxStru := FG_CalcVlrs(aAuxStru , VSZ->VSZ_CODSER , cCpoDiv,,,,VSZ->VSZ_NUMOSV)
	
	cCpoDiv += "#" + str(len(aAuxStru)+1,5)
	
	If !lMapOS
		For n_ := nPosVet to Len(aSomaStru)
			aSomaStru[n_,1] += aAuxStru[n_,9]
			aSomaStru[n_,3] += aAuxStru[n_,12]
			aSomaStru[n_,5] += aAuxStru[n_,20]
		Next
		
		For n_:=1 to Len(aSomaStru)
			aAuxStru[n_,9]  := aSomaStru[n_,1]
			aAuxStru[n_,12] := aSomaStru[n_,3]
			aAuxStru[n_,20] := aSomaStru[n_,5]
		Next
	EndIf
	
	(cAliasVSZ)->(dbSkip())
End
(cAliasVSZ)->(dbCloseArea())

Return lProc


/*/{Protheus.doc} OX100IDEAVAL

Verifica se existe registro criado e reutiliza o numero de Identificacao
Deleta os registros para avaliacao que jแ estavam gravados na base de dados

@author Rubens
@since 03/09/2015
@version 1.0
@param cNumOsv, character, Numero da Ordem de Servico
@param cNumIde, character, Numero de Idenficacao para gravacao nas tabelas VSY e VSZ
@return cNumIde , character, Numero de Idenficacao para gravacao nas tabelas VSY e VSZ

/*/
Static Function OX100IDEAVAL(cNumOsv, cNumIde)

Local cSQLVS6 := ""
If Empty(cNumIde)
	
	cSQLVS6 += "( SELECT VS6_NUMIDE "
	cSQLVS6 +=   " FROM " + RetSQLname("VS6") + " VS6"
	cSQLVS6 +=  " WHERE VS6_FILIAL = '" + xFilial("VS6") + "'"
	cSQLVS6 +=    " AND VS6_DOC IN ('Ind-" + cNumOsv + "','Agr-" + cNumOsv + "')"
	cSQLVS6 +=    " AND VS6.D_E_L_E_T_ = ' ' )"
	
	cSQL := "SELECT VSY_NUMIDE "
	cSQL +=  " FROM " + RetSQLName("VSY") + " VSY "
	cSQL += " WHERE VSY.VSY_FILIAL = '" + xFilial("VSY") + "'"
	cSQL +=   " AND VSY.VSY_NUMOSV = '" + cNumOsv + "'"
	cSQL +=   " AND VSY.D_E_L_E_T_ = ' '"
	cSQL +=   " AND VSY.VSY_NUMIDE NOT IN " + cSQLVS6
	cNumIde := FM_SQL(cSQL)
	If Empty(cNumIde)
		cSQL := "SELECT VSZ_NUMIDE "
		cSQL +=  " FROM " + RetSQLName("VSZ") + " VSZ "
		cSQL += " WHERE VSZ.VSZ_FILIAL = '" + xFilial("VSZ") + "'"
		cSQL +=   " AND VSZ.VSZ_NUMOSV = '" + cNumOsv + "'"
		cSQL +=   " AND VSZ.D_E_L_E_T_ = ' '"
		cSQL +=   " AND VSZ.VSZ_NUMIDE NOT IN " + cSQLVS6
		cNumIde := FM_SQL(cSQL)
	EndIf
	
	If Empty(cNumIde)
		cNumIde := GetSxENum("VS6","VS6_NUMIDE")
		ConfirmSx8()
	EndIf
EndIf

Return cNumIde


/*/{Protheus.doc} OX100DELAVAL

Deleta registros que serao utilizados para avaliacao de resultado

@author Rubens
@since 03/09/2015
@version 1.0
@param cNumOsv, character, Numero da Ordem de Servico

/*/
Static Function OX100DELAVAL( cNumOsv , cNumIde )

Local cSQL
Local cSQLVS6 := ""

If Empty(cNumIde)
	cSQLVS6 += "( SELECT VS6_NUMIDE "
	cSQLVS6 +=   " FROM " + RetSQLname("VS6") + " VS6"
	cSQLVS6 +=  " WHERE VS6_FILIAL = '" + xFilial("VS6") + "'"
	cSQLVS6 +=    " AND VS6_DOC IN ('Ind-" + cNumOsv + "','Agr-" + cNumOsv + "')"
	cSQLVS6 +=    " AND VS6.D_E_L_E_T_ = ' ' )"
EndIf

cSQL := "DELETE FROM " + RetSQLName("VSY") + " WHERE VSY_FILIAL = '" + xFilial("VSY") + "' AND D_E_L_E_T_ = ' '"
cSQL += IIF(!Empty(cNumOsv) , " AND VSY_NUMOSV = '" + cNumOsv + "'" , "" )
cSQL += IIF(!Empty(cNumIde) , " AND VSY_NUMIDE = '" + cNumIde + "'" , " AND VSY_NUMIDE NOT IN " + cSQLVS6 )
TCSqlExec(cSQL)
cSQL := "DELETE FROM " + RetSQLName("VSZ") + " WHERE VSZ_FILIAL = '" + xFilial("VSZ") + "' AND D_E_L_E_T_ = ' '"
cSQL += IIF(!Empty(cNumOsv) , " AND VSZ_NUMOSV = '" + cNumOsv + "'" , "" )
cSQL += IIF(!Empty(cNumIde) , " AND VSZ_NUMIDE = '" + cNumIde + "'" , " AND VSZ_NUMIDE NOT IN " + cSQLVS6 )
TCSqlExec(cSQL)

Return




/*/{Protheus.doc} OX100VSZ

Grava registros dos servicos para avaliacao de resultado

@author Rubens
@since 03/09/2015
@version 1.0
@param cNumIde, character, N๚mero de Identificacao do Registro

/*/
Static Function OX100VSZ( cNumIde , cNumOsv , cTipTem, cLibVOO )

Local nCntFor
Local nCntApon
Local nRazIte
Local nPosGet
Local aVetTra
Local nPosRel := 0

Local lVSZVALIRR := VSZ->(FieldPos("VSZ_VALIRR")) > 0
Local lVSZVALCSL := VSZ->(FieldPos("VSZ_VALCSL")) > 0

Local nValPis := 0  // Valor do PIS do Tipo de Servico    ( FISCAL )
Local nValCof := 0  // Valor do COFINS do Tipo de Servico ( FISCAL )
Local nValISS := 0  // Valor do ISS do Tipo de Servico    ( FISCAL )
Local nValIRR := 0  // Valor do IRRF
Local nValCSL := 0  // Valor do CSLL

Local nVSZVALBRU := 0
Local nVSZVALDES := 0
Local nVSZVALSER := 0
Local nVSZTEMCOB := 0
Local nVSZVALISS := 0
Local nVSZVALPIS := 0
Local nVSZVALCOF := 0
Local nVSZVALIRR := 0
Local nVSZVALCSL := 0

Local RVO4TIPTEM := FG_POSVAR("VO4_TIPTEM","aHVO4Res")
Local RVO4TIPSER := FG_POSVAR("VO4_TIPSER","aHVO4Res")

For nCntFor := 1 to Len(aAuxVO4)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Procura a Posicao da GetDados que contem os dados do Fechamento ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPosGet := aScan( oGetResVO4:aCols, { |x| x[RVO4TIPTEM] == aAuxVO4[nCntFor,AS_TIPTEM] .and. x[RVO4TIPSER] == aAuxVO4[nCntFor,AS_TIPSER] } )
	If nPosGet == 0
		Help(" ",1,"OX100GDMA",,STR0047+chr(13)+chr(10)+"OX100VSC",4,1)
		Loop
	EndIf
	//
	
	If !Empty(cNumOsv) .and. (cNumOsv <> aAuxVO4[nCntFor,AS_NUMOSV] .or. cTipTem <> aAuxVO4[nCntFor,AS_TIPTEM] .or. cLibVOO <> aAuxVO4[nCntFor,AS_LIBVOO] )
		Loop
	EndIf
	
	VOI->(dbSetOrder(1))
	VOI->(MsSeek(xFilial("VOI") + oGetResVO4:aCols[ nPosGet , RVO4TIPTEM ] ))
	lNFSrvc := ( VOI->VOI_SITTPO <> "3" )
	
	VOK->(dbSetOrder(1))
	VOK->(dbSeek(xFilial("VOK") + aAuxVO4[nCntFor,AS_TIPSER] ))
	
	// Posiciona Fiscal ...
	If lNFSrvc
		OX100SRVFIS( nPosGet ) // Set o N para a Posicao Correspondente no Fiscal
		nValPis := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
		nValCof := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
		nValISS := MaFisRet(n,"IT_VALISS")
		nValIRR := MaFisRet(n,"IT_VALIRR")
		nValCSL := MaFisRet(n,"IT_VALCSL")
		
		// Do imposto, considera somente o percentual do VO4 em relacao ao total do Tipo de Servico (Fechamento)
		nValPis := A410Arred( nValPis * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALPIS" )
		nValCof := A410Arred( nValCof * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALCOF" )
		nValISS := A410Arred( nValISS * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALISS" )
		If lVSZVALIRR
			nValIRR := A410Arred( nValIRR * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALIRR" )
		EndIf
		If lVSZVALCSL
			nValCSL := A410Arred( nValCSL * aAuxVO4[nCntFor,AS_PERCVLL] , "VSC_VALCSL" )
		EndIf
		
	EndIf
	//
	
	aSort(aAuxVO4[nCntFor,AS_APONTA] , 1 , , { |x,y| x[AS_APONTA_PERCEN] <= y[AS_APONTA_PERCEN] } )
	
	nVSZVALBRU := 0
	nVSZVALDES := 0
	nVSZVALSER := 0
	nVSZTEMCOB := 0
	nVSZVALISS := 0
	nVSZVALPIS := 0
	nVSZVALCOF := 0
	nVSZVALIRR := 0
	nVSZVALCSL := 0
	
	For nCntApon := 1 to Len(aAuxVO4[nCntFor,AS_APONTA])
		
		DbSelectArea("VSZ")
		If !RecLock("VSZ",.t.)
			HELP(" ",1,"REGNLOCK",,"VSZ - OX100VSZ",4,1)
			DisarmTransaction()
			Return .f.
		EndIf
		
		// Posiciona no VO4
		VO4->(dbGoTo( aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_RECNO] ))
		
		VSZ->VSZ_FILIAL := xFilial("VSZ")
		VSZ->VSZ_NUMIDE := cNumIde
		VSZ->VSZ_SERINT := aAuxVO4[nCntFor,AS_SERINT]
		VSZ->VSZ_NUMOSV := aAuxVO4[nCntFor,AS_NUMOSV]
		VSZ->VSZ_LIBVOO := aAuxVO4[nCntFor,AS_LIBVOO]
		VSZ->VSZ_GRUSER := aAuxVO4[nCntFor,AS_GRUSER]
		VSZ->VSZ_CODSER := aAuxVO4[nCntFor,AS_CODSER]
		VSZ->VSZ_TIPSER := aAuxVO4[nCntFor,AS_TIPSER]
		VSZ->VSZ_TIPTEM := aAuxVO4[nCntFor,AS_TIPTEM]
		VSZ->VSZ_TEMPAD := aAuxVO4[nCntFor,AS_TEMPAD]
		VSZ->VSZ_TEMTRA := aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_TEMTRA]
		
		Do Case
			// Tempo para Calculo - 1=Fabrica / 2=Concessionaria / 4=Informado
			Case aAuxVO4[nCntFor,AS_INCTEM] $ "124"
				VSZ->VSZ_TEMVEN := aAuxVO4[nCntFor,AS_TEMPAD]
				VSZ->VSZ_TEMCOB := Round(aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN] * aAuxVO4[nCntFor,AS_TEMCOB] , 0 )
				
				nVSZTEMCOB += VSZ->VSZ_TEMCOB
				
				// Verifica se teve problema de arredondamento
				If nCntApon == Len(aAuxVO4[nCntFor,AS_APONTA])
					If nVSZTEMCOB <> aAuxVO4[nCntFor,AS_TEMCOB]
						VSZ->VSZ_TEMCOB += aAuxVO4[nCntFor,AS_TEMCOB] - nVSZTEMCOB
					EndIf
				EndIf
				//
				
				// Tempo para Calculo - 3=Trabalhado
			Case aAuxVO4[nCntFor,AS_INCTEM] == "3"
				VSZ->VSZ_TEMVEN := aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_TEMTRA]
				VSZ->VSZ_TEMCOB := aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_TEMTRA]
		EndCase
		
		VSZ->VSZ_CODPRO := aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_CODPRO]
		VSZ->VSZ_CODSEC := aAuxVO4[nCntFor,AS_SECAO]
		VSZ->VSZ_DATVEN := dDataBase
		VSZ->VSZ_KILROD := aAuxVO4[nCntFor,AS_KILROD]
		VSZ->VSZ_RECVO4 := StrZero(aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_RECNO],9)
		VSZ->VSZ_VALBRU := 0
		VSZ->VSZ_VALDES := 0
		VSZ->VSZ_VALSER := 0
		VSZ->VSZ_CUSSER := 0
		
		// Tipo de Tempo Interno
		If VOI->VOI_SITTPO == "3"
			Do Case
				Case VOK->VOK_INCMOB == "2"   // 2=Srv de Terceiro
					VSZ->VSZ_CUSSER := VO4->VO4_VALCUS
				Case VOK->VOK_INCMOB == "6"   // 6=Franquia
					VSZ->VSZ_CUSSER := VO4->VO4_VALCUS
			EndCase
			
			// Tipo de Tempo NAO Interno
		Else
			If VOK->VOK_INCMOB $ "1,2,3,6"  // 1=Mao-de-Obra / 2=Srv de Terceiro / 3=Vlr Livre c/Base na Tabela / 6=Franquia
				VSZ->VSZ_VALBRU := A410Arred( aAuxVO4[nCntFor,AS_VALBRU] * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALBRU" )
				VSZ->VSZ_VALDES := A410Arred( aAuxVO4[nCntFor,AS_VALDES] * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALDES" )
				
				If VOK->VOK_INCMOB $ "2,6"  // 2=Srv de Terceiro / 6=Franquia
					VSZ->VSZ_CUSSER := VO4->VO4_VALCUS
				EndIf
				
			ElseIf VOK->VOK_INCMOB == "5" // 5=Km Socorro
				If VOI->VOI_TPOKLM <> "S" // NรO ้ Tp de Tempo de Kilometro
					VSZ->VSZ_VALBRU := A410Arred( aAuxVO4[nCntFor,AS_VALBRU] * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALBRU" )
					VSZ->VSZ_VALDES := A410Arred( aAuxVO4[nCntFor,AS_VALDES] * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALDES" )
				Endif
			EndIf
			
			VSZ->VSZ_VALSER := A410Arred(VSZ->VSZ_VALBRU - VSZ->VSZ_VALDES,"VSZ_VALSER")
			
			nVSZVALBRU += VSZ->VSZ_VALBRU
			nVSZVALDES += VSZ->VSZ_VALDES
			nVSZVALSER += VSZ->VSZ_VALSER
			
			// Verifica se teve problema de arredondamento
			If nCntApon == Len(aAuxVO4[nCntFor,AS_APONTA])
				If nVSZVALDES <> aAuxVO4[nCntFor,AS_VALDES] .or. nVSZVALSER <> ( aAuxVO4[nCntFor,AS_VALBRU] - aAuxVO4[nCntFor,AS_VALDES] )
					VSZ->VSZ_VALBRU += aAuxVO4[nCntFor,AS_VALBRU] - nVSZVALBRU
					VSZ->VSZ_VALDES += aAuxVO4[nCntFor,AS_VALDES] - nVSZVALDES
					VSZ->VSZ_VALSER += ( aAuxVO4[nCntFor,AS_VALBRU] - aAuxVO4[nCntFor,AS_VALDES] ) - nVSZVALSER
				EndIf
			EndIf
			//
			
		EndIf
		
		VSZ->VSZ_VALISS := A410Arred(nValISS * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALISS" )
		VSZ->VSZ_VALPIS := A410Arred(nValPis * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALPIS" )
		VSZ->VSZ_VALCOF := A410Arred(nValCof * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALCOF" )
		
		nVSZVALISS += VSZ->VSZ_VALISS
		nVSZVALPIS += VSZ->VSZ_VALPIS
		nVSZVALCOF += VSZ->VSZ_VALCOF

		If lVSZVALIRR
			VSZ->VSZ_VALIRR := A410Arred(nValIRR * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALIRR" )
			nVSZVALIRR += VSZ->VSZ_VALIRR
		EndIf
		If lVSZVALCSL // CSLL
			VSZ->VSZ_VALCSL := A410Arred(nValCSL * aAuxVO4[nCntFor,AS_APONTA,nCntApon,AS_APONTA_PERCEN], "VSZ_VALCSL" )
			nVSZVALCSL += VSZ->VSZ_VALCSL
		EndIf
		
		// Verifica se teve problema de arredondamento
		If nCntApon == Len(aAuxVO4[nCntFor,AS_APONTA])
			If nVSZVALISS <> nValISS
				VSZ->VSZ_VALISS += nValISS - nVSZVALISS
			EndIf
			If nVSZVALPIS <> nValPIS
				VSZ->VSZ_VALPIS += nValPIS - nVSZVALPIS
			EndIf
			If nVSZVALCOF <> nValCOF
				VSZ->VSZ_VALCOF += nValCOF - nVSZVALCOF
			EndIf
			If lVSZVALIRR .and. nVSZVALIRR <> nValIRR
				VSZ->VSZ_VALIRR += nValIRR - nVSZVALIRR
			EndIf
			If lVSZVALCSL .and. nVSZVALCSL <> nValCSL
				VSZ->VSZ_VALCSL += nValCSL - nVSZVALCSL
			EndIf
		EndIf
		//
		
		VSZ->VSZ_TOTIMP := VSZ->VSZ_VALISS + VSZ->VSZ_VALPIS + VSZ->VSZ_VALCOF
		
		VSZ->VSZ_CUSTOT := VSZ->VSZ_CUSSER
		VSZ->VSZ_DESVAR := VSZ->VSZ_COMVEN + VSZ->VSZ_COMGER
		
		VSZ->VSZ_LUCBRU := VSZ->VSZ_VALSER - VSZ->VSZ_TOTIMP - VSZ->VSZ_CUSTOT
		VSZ->VSZ_LUCLIQ := VSZ->VSZ_LUCBRU - VSZ->VSZ_DESVAR - VSZ->VSZ_DESFIX - VSZ->VSZ_DESDEP - VSZ->VSZ_DESADM
		VSZ->VSZ_RESFIN := VSZ->VSZ_LUCLIQ - VSZ->VSZ_CUSFIX
		
		VSZ->VSZ_DESFIX := 0
		VSZ->VSZ_CUSFIX := 0
		VSZ->VSZ_DESADM := 0
		VSZ->VSZ_DESDEP := 0
		
		VSZ->VSZ_CODMAR := VO1->VO1_CODMAR
		
		VSZ->VSZ_VMFBRU := FG_CALCMF( {{ dDataBase , VSZ->VSZ_VALBRU }} )
		
		VSZ->VSZ_VMFSER := VSZ->VSZ_VMFBRU - FG_CALCMF( {{dDataBase   , VSZ->VSZ_VALDES } })
		VSZ->VSZ_VMFISS := FG_CALCMF( { { FG_RTDTIMP("ISS",dDataBase) , VSZ->VSZ_VALISS } })
		VSZ->VSZ_VMFPIS := FG_CALCMF( { { FG_RTDTIMP("PIS",dDataBase) , VSZ->VSZ_VALPIS } })
		VSZ->VSZ_VMFCOF := FG_CALCMF( { { FG_RTDTIMP("COF",dDataBase) , VSZ->VSZ_VALCOF } })
		
		VSZ->VSZ_TMFIMP := VSZ->VSZ_VMFPIS + VSZ->VSZ_VMFISS + VSZ->VSZ_VMFCOF

		If lVSZVALIRR // IRRF
			VSZ->VSZ_VMFIRR := FG_CALCMF( {{dDataBase , VSZ->VSZ_VALIRR}} )
		EndIf
		If lVSZVALCSL // CSLL
			VSZ->VSZ_VMFCSL := FG_CALCMF( {{dDataBase , VSZ->VSZ_VALCSL}} )
		EndIf

		VSZ->VSZ_CMFSER := FG_CALCMF( { {dDataBase,VSZ->VSZ_CUSSER} })
		VSZ->VSZ_CMFTOT := VSZ->VSZ_CMFSER
		VSZ->VSZ_LMFBRU := VSZ->VSZ_VMFSER - VSZ->VSZ_TMFIMP - VSZ->VSZ_CMFSER
		
		VSZ->VSZ_DMFVAR := VSZ->VSZ_CMFVEN + VSZ->VSZ_CMFGER
		VSZ->VSZ_LMFLIQ := VSZ->VSZ_LMFBRU - VSZ->VSZ_DMFVAR
		VSZ->VSZ_CMFFIX := 0
		VSZ->VSZ_DMFFIX := 0
		VSZ->VSZ_DMFADM := 0
		VSZ->VSZ_DMFDEP := 0
		VSZ->VSZ_RMFFIN := VSZ->VSZ_LMFLIQ - VSZ->VSZ_CMFFIX - VSZ->VSZ_DMFFIX - VSZ->VSZ_DMFADM - VSZ->VSZ_DMFDEP
		
		// ------------------------ //
		// Parametros para comissao //
		// ------------------------ //
		lProcCom := .f.
		nValCom := VSZ->VSZ_VALSER
		xVetTra := VSZ->VSZ_CODPRO
		// Tipo de Tempo Interno
		If VOI->VOI_SITTPO == "3"
			
			// Mao-de-Obra Gratuita, Mao-de-Obra, Valor Livre com Base na Tabela
			If VOK->VOK_INCMOB $ "0/1/3"
				lProcCom := .t.
				nValCom := VO4->VO4_VALINT
			EndIf
			
		Else
			// Mao-de-Obra Gratuita
			If VOK->VOK_INCMOB $ "0"
				lProcCom := .t.
				nValCom := VO4->VO4_VALINT
				
				// Mao-de-Obra, Valor Livre com Base na Tabela
			ElseIf VOK->VOK_INCMOB $ "1/3"
				lProcCom := .t.
				
				// Servico de Terceiro, Socorro
			ElseIf VOK->VOK_INCMOB $ "2/5" .and. VOK->VOK_CMSR3R == "1"
				
				lProcCom := .t.
				
				// Gerando informacao de comissao
				xVetTra := {}
				OX100VETCOM(VSZ->VSZ_TIPTEM, @xVetTra )
			EndIf
		EndIf
		//
		
		If lProcCom
			aValCom    := FG_COMISS("S",xVetTra,VSZ->VSZ_DATVEN,VSZ->VSZ_TIPTEM,nValCom,"T",VSZ->VSZ_NUMIDE)
			VSZ->VSZ_COMVEN := aValCom[1]
			VSZ->VSZ_COMGER := aValCom[2]
			aValCom    := FG_COMISS("S",xVetTra,VSZ->VSZ_DATVEN,VSZ->VSZ_TIPTEM,nValCom,"D",VSZ->VSZ_NUMIDE)
			VSZ->VSZ_CMFVEN := FG_CALCMF(aValCom[1])
			VSZ->VSZ_CMFGER := FG_CALCMF(aValCom[2])
		EndIf
		
		VSZ->(MsUnlock())
		VSZ->(dbGoTo(VSZ->(Recno())))
		
	Next nCntApon
	//
	
Next

Return .t.

/*/{Protheus.doc} OX100POSPECA

Procura a linha da GetDados do produto passado como parametro

@author Rubens
@since 02/10/2015
@version 1.0
@param cSeqFec, character, Sequencia do Fechamento (ligacao do DETVO3 com aAuxVO3)
@return nPosGet , num้rico, Numero da Linha da GetDados

/*/
Static Function OX100POSPECA( cSeqFec )
Local DSEQFEC    := FG_POSVAR("SEQFEC","aHVO3Det")
Local nPosGet := aScan( oGetDetVO3:aCols, { |x| x[DSEQFEC] == cSeqFec } )

If nPosGet == 0
	Help(" ",1,"OX100GDMA",,STR0046+CHR(13)+CHR(10)+cFuncao,4,1)
EndIf
Return (nPosGet)


/*/{Protheus.doc} OX100DVEICON

Cria uma movimentacao de estoque com o valor do fechamento para controle de custo contabil do veiculo

@author Rubens
@since 02/10/2015
@version 1.0
@param cNumOsv, character, Numero da Ordem de Servico
@param cTipTem, character, Tipo de Tempo
@param cLibVOO, character, Numero da Liberacao do Tipo de Tempo
@param cChaInt, character, Numero interno do Chassi do Veiculo do Fechamento
@return lRet , booleano, Indica se foi possivel realizar a movimentao do estoque

/*/
Static Function OX100DVEICON(cNumOsv, cTipTem, cLibVOO, cChaInt)

Local aItensNew := {}
Local lRet := .t.
Local cSQL
Local nValorDes := 0
Local lVVD_FILOSV := VVD->(FieldPos("VVD_FILOSV")) <> 0

If VOO->(FieldPos("VOO_D3DVEI")) == 0 .or. Empty(GetNewPar("MV_MIL0065",""))
	Return lRet
EndIf

cSQL := "SELECT SUM(VVD_VALOR) "
cSQL +=  " FROM " + RetSQLName("VVD") + " VVD "
cSQL += " WHERE VVD.VVD_FILIAL = '" + xFilial("VVD") + "'"
If lVVD_FILOSV
	cSQL += " AND (   VVD.VVD_FILOSV = '" + xFilial("VOO") + "' " // novos registros
	cSQL += "     OR  VVD.VVD_FILOSV = ' ' ) "   // registro antigos
Endif
cSQL +=   " AND VVD.VVD_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VVD.VVD_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND VVD.VVD_LIBVOO = '" + cLibVOO + "'"
cSQL +=   " AND VVD.D_E_L_E_T_ = ' '"
If (nValorDes := FM_SQL(cSQL)) == 0
	Return lRet
EndIf

FGX_VV1SB1("CHAINT", cChaInt )

aItensNew := {}
aadd(aItensNew,{"D3_TM",GetNewPar("MV_MIL0065",""),NIL})
aadd(aItensNew,{"D3_COD",SB1->B1_COD,NIL}) // Veiculo
aadd(aItensNew,{"D3_UM",SB1->B1_UM,NIL})
aadd(aItensNew,{"D3_QUANT",0,NIL})
aadd(aItensNew,{"D3_LOCAL",SB1->B1_LOCPAD,NIL})
aadd(aItensNew,{"D3_EMISSAO",dDataBase,NIL})
aadd(aItensNew,{"D3_CUSTO1",nValorDes,NIL})
lMsHelpAuto := .t.
lMsErroAuto := .f.
MSExecAuto({|x| MATA240(x)},aItensNew)
If lMsErroAuto
	MostraErro()
	lRet := .f.
ElseIf !Empty(SD3->D3_NUMSEQ)
	dbSelectArea("VOO")
	RecLock("VOO",.f.)
	VOO->VOO_D3DVEI := SD3->D3_NUMSEQ
	MsUnLock()
EndIf

Return lRet

/*/{Protheus.doc} OX100VE4POSICIONA

Posiciona registro da VE4 de acordo com o codigo da marca enviado por parametro.
Posicionamento levara em consideracao o conteudo do campo de

@author Rubens
@since 02/10/2015
@version 1.0
@param cAuxCodMar, character, C๓digo da marca para pesquisar
@return lRet , booleano, Indica se foi possivel realizar a pesquisa

/*/
Static Function OX100VE4POSICIONA(cAuxCodMar)

Local cSQL

cSQL := "SELECT R_E_C_N_O_ " + ;
" FROM " + RetSQLName("VE4") + " VE4 " +;
" WHERE VE4.VE4_FILIAL = '" + xFilial("VE4") + "'" +;
" AND VE4.VE4_PREFAB = '" + cAuxCodMar + "'" +;
" AND ( VE4.VE4_QDOIMP NOT IN (' ' , '0' ) OR VE4.VE4_FOREXP <> ' ')" +;
" AND VE4.D_E_L_E_T_ = ' '"
If (nRecno := FM_SQL(cSQL)) <> 0
	VE4->(dbGoTo(nRecno))
	Return .t.
EndIf

VE4->(dbSetOrder(1))
Return VE4->(dbSeek( xFilial("VE4") + cAuxCodMar ))

/*/{Protheus.doc} OX100001_CriaSemaforo
Cria um semaforo por OS + Tipo de Tempo + Liberacao da VOO, para garantir que a mesma libera็ใo nao seja selecionada em janelas diferentes e nใo permtir que o usuแrio gere mais de uma nota fiscal por OS/Tipo de Tempo/Libera็ใo.

@author Rubens
@since 06/06/2016
@version undefined

@type function
/*/
Static Function OX100001_CriaSemaforo()
Local nCont := 1
aSemafVOO := {}
For nCont := 1 to Len(aLockVOO)
	If LockByName("OFIXX100" + aLockVOO[nCont],.T.,.T.)
		AADD( aSemafVOO , "OFIXX100" + aLockVOO[nCont] )
	Else
		OX100002_LiberaSemaforo()
		MsgInfo(STR0150 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
		AllTrim(RetTitle("VOO_NUMOSV")) + ": " + SubStr(aLockVOO[nCont],1,TamSX3("VOO_NUMOSV")[1]) + chr(13) + chr(10) +;
		AllTrim(RetTitle("VOO_TIPTEM")) + ": " + SubStr(aLockVOO[nCont],TamSX3("VOO_NUMOSV")[1] + 1,TamSX3("VOO_TIPTEM")[1]) ) // "Ordem de Servi็o/Tipo de Tempo estแ bloqueada para fechamento por outro usuแrio."
		Return .f.
	EndIf
Next nCont
Return .t.

/*/{Protheus.doc} OX100002_LiberaSemaforo
Libera semแrofo para selecionar o tipo de tempo para fechamento.

@author Rubens
@since 06/06/2016
@version undefined

@type function
/*/
Static Function OX100002_LiberaSemaforo()
Local nCont := 1
For nCont := 1 to Len(aSemafVOO)
	UnlockByName( aSemafVOO[nCont] , .T., .T. )
Next nCont
aSemafVOO := {}
Return .t.

/*/{Protheus.doc} OX100VOOBLQ
Bloqueia registros da VOO para fechamento.

@author Rubens
@since 06/06/2016
@version undefined

@type function
/*/
Static Function OX100VOOBLQ()
// Tenta bloquear os registros de liberacao para fechamento ...
If !MultLock("VOO",aLockVOO,1)
	Return .f.
EndIf
//
Return .t.



/*/{Protheus.doc} OX100ISS
Tratamento de alํquota especํfica de ISS.
Para a correta utiliza็ใo, os campos VOO_ALIISS e C6_ALIQISS devem existir na base de dados.

@author Rubens
@since 04/07/2016
@version undefined

@type function
/*/
Static Function OX100ISS(nPISS)

Local nCont

If aScan( oGetDetVO4:aCols , { |x| !Empty(x[FG_POSVAR("VO4_TIPTEM","aHVO4Res")]) } ) == 0
	Return
EndIf

nBkpN := n
For nCont := 1 to Len(oGetResVO4:aCols)
	oGetResVO4:nAt := nCont
	OX100SRVFIS( oGetResVO4:nAt )
	MaFisRef( "IT_ALIQISS","V300", IIf( nPISS == 0, aAuxVO4Resumo[1,2] , nPISS ) )
Next nCont
n := nBkpN
OX100ATRES(.f.)

Return


/*/{Protheus.doc} OX100ISS
Recalculo do Fiscal atrav้s da Leitura dos Itens

@author Manoel
@since 06/09/2016
@version undefined

@type function
/*/
Function OXX100FIS(cParam)

Local nBkpN := n
Local nCntForF := 0
Local nAuxTot := 0
Local DVO3TIPTEM := FG_POSVAR("VO3_TIPTEM","aHVO3Det")

// Calcula o total do tipo de tempo ...
For nCntForF := 1 to Len(oGetDetVO3:aCols)
	If !Empty(oGetDetVO3:aCols[nCntForF,DVO3TIPTEM])
		// Procura valor total do Fiscal ...
		OX100PECFIS( nCntForF )
		nAuxTot += MaFisRet(n,cParam)
		//
	EndIf
Next nCntFor
//
n := nBkpN

Return nAuxTot

/*/{Protheus.doc} OX100F8
Chamada da Tecla F8

@author Manoel
@since 07/06/2017
@version undefined

@type function
/*/
Static Function OX100F8()

If ExistBlock("OX100F8")
	SETKEY(VK_F8,nil)
	ExecBlock("OX100F8",.f.,.f.)
	SetKey(VK_F8, {|| OX100F8() })
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OX100MRGLC บAutor ณ Fernando Vitor Cavani บData ณ 21/05/18 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Considera Desconto e Margem de Lucro para o Tipo de Tempo  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = N๚mero da Ordem de Servi็o                       บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ True ou False                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX100MRGLC(cNumOsv, cTipTem)
Local lConMrgLuc := .t.

Default cNumOsv := ""
Default cTipTem := ""

// Verifica็ใo especํfica por Marca
If !Empty(cNumOsv) .And. cMVMIL0006 == "JD"
	If lOFJD15009
		lConMrgLuc := OFNJD15009_GarantiaEspecial(cNumOsv)
	EndIf
EndIf

If VOI->(FieldPos("VOI_CONMRG")) > 0 .and. lConMrgLuc
	
	// Verifica็ใo campo de controle VOI_CONMRG
	If  !Empty(cTipTem)
		DBSelectArea("VOI")
		DBSetOrder(1)
		If dbSeek(xFilial("VOI") + cTipTem)
			If VOI->VOI_CONMRG == "0" // Nao considerar Desconto e Margem de Lucro quando o campo for 0
				lConMrgLuc := .f.
			EndIf
		EndIf
	EndIf
	
EndIf

Return lConMrgLuc

/*/{Protheus.doc} OX1000015_MostraImposto


@author Renato Vinicius
@since 04/12/2018
@version undefined

@type function
/*/

Static Function OX1000015_MostraImposto(aRetImposto)

Default aRetImposto := {}

nPosIpi := aScan(aRetImposto,{|x| x[2] == RetTitle("VEC_VALIPI")})
If nPosIpi > 0
	If &(aRetImposto[nPosIpi,1]) == 0
		aDel(aRetImposto,nPosIpi)
		aSize(aRetImposto,Len(aRetImposto)-1)
	Endif
Else
	If MaFisRet(,"NF_VALIPI") > 0
		aAdd(aRetImposto, {'MaFisRet(,"NF_VALIPI")', RetTitle("VEC_VALIPI"), 0}) // Valor do IPI
	Endif
Endif

Return aRetImposto

/*/{Protheus.doc} OX1000025_ValidaTipoTempoPecaSelecionado

@description Fun็ใo para validar se hแ tipo de tempo de pe็a selecionado para faturamento
@author Renato Vinicius
@since 19/02/2019
@version undefined

@type function
/*/

Static Function OX1000025_ValidaTipoTempoPecaSelecionado()

Return Len(aAuxVO3) > 0

/*/{Protheus.doc} OX1000035_ValidaSolicitacaoLiberacaoDesconto

@description Fun็ใo para validar se hแ tipo de tempo de pe็a selecionado para faturamento
@author Renato Vinicius
@since 03/04/2019
@version undefined

@type function
/*/

Static Function OX1000035_ValidaSolicitacaoLiberacaoDesconto(aProbOs)

Local lRetorno  := .t.
Local nPos      := 0
Local nCntFor, nCntFor2
Local aLibItem

Default aProbOs := {}

For nCntFor := 1 to Len(aProbOs)

	If aProbOs[nCntFor, 6]

		For nCntFor2 := 1 to Len(aProbOs[nCntFor, 2])
			// Posicao da Matriz aAuxVO3 com problema de desconto
			If !aProbOs[nCntFor, 2, nCntFor2, 2]

				nPecSom := aProbOs[nCntFor, 2, nCntFor2, 1]

				aLibItem  := aClone(aPecSom[nPecSom])

				lTemPeca := .f.

				cQuery := "SELECT VS1.VS1_NUMORC, VS1.VS1_NUMLIB, "
				cQuery +=       " VS3.VS3_GRUITE, VS3.VS3_CODITE, "
				cQuery +=       " VS3.VS3_QTDITE, VS3.VS3_VALPEC, "
				cQuery +=       " VS3.VS3_VALDES, VS3.VS3_MARLUC "
				cQuery += "FROM " + RetSqlName("VS1") + " VS1 "
				cQuery +=      " JOIN "+RetSqlName("VS3")+" VS3 "
				cQuery +=      "  ON VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
				cQuery +=      " AND VS3.VS3_GRUITE = '" + aPecSom[nPecSom, 4] + "' "
				cQuery +=      " AND VS3.VS3_CODITE = '" + aPecSom[nPecSom, 5] + "' "
				cQuery +=      " AND VS3.VS3_NUMORC = VS1.VS1_NUMORC "
				cQuery +=      " AND VS3.D_E_L_E_T_=' ' "
				//cQuery +=      "LEFT JOIN "+RetSqlName("VS4")+" VS4 ON ( VS4.VS4_FILIAL = '" + xFilial("VS4") + "' AND VS4.VS4_NUMORC=VS1.VS1_NUMORC AND VS4.D_E_L_E_T_=' ' ) "
				cQuery += "WHERE VS1.VS1_FILIAL = '" + xFilial("VS1") + "' "
				cQuery +=  " AND VS1.VS1_STATUS <> ' ' AND VS1.VS1_STATUS<>'C' "
				cQuery +=  " AND VS1.VS1_NUMOSV = '" + aPecSom[nPecSom, 1] + "' "
				cQuery +=  " AND VS1.VS1_TIPTEM = '" + aPecSom[nPecSom, 2] + "' "
				cQuery +=  " AND VS1.VS1_NUMLIB <> ' '"
				cQuery +=  " AND VS1.D_E_L_E_T_=' '"
				//cQuery += "GROUP BY VS1.VS1_NUMORC , VS1.VS1_DATORC"

				TcQuery cQuery New alias "TMPVS1"

				While !TMPVS1->( Eof() )

					lTemPeca := .t.

					///////////////////////////
					// Liberacao             //
					///////////////////////////
					cQuery := "SELECT VS6.R_E_C_N_O_ "
					cQuery += "FROM " + RetSqlName("VS6") + " VS6 "
					cQuery +=      " JOIN "+RetSqlName("VS7")+" VS7 "
					cQuery +=      "  ON VS7.VS7_FILIAL = '" + xFilial("VS7") + "' "
					cQuery +=      " AND VS7.VS7_GRUITE = '" + TMPVS1->VS3_GRUITE + "' "
					cQuery +=      " AND VS7.VS7_CODITE = '" + TMPVS1->VS3_CODITE + "' "
					cQuery +=      " AND VS7.VS7_NUMIDE = VS6.VS6_NUMIDE "
					cQuery +=      " AND VS7.D_E_L_E_T_=' ' "
					cQuery += "WHERE VS6.VS6_FILIAL = '" + xFilial("VS6") + "' "
					cQuery +=  " AND VS6.VS6_NUMIDE = '" + TMPVS1->VS1_NUMLIB + "' "
					cQuery +=  " AND VS6.VS6_NUMORC = '" + TMPVS1->VS1_NUMORC + "' "
					cQuery +=  " AND VS6.VS6_TIPAUT = '2' "
					cQuery +=  " AND VS6.VS6_DATAUT <> ' ' "
					cQuery +=  " AND VS6.D_E_L_E_T_ = ' '"

					If FM_SQL(cQuery) == 0
						TMPVS1->( DbCloseArea() )
						Return .f.
					EndIf

					aLibItem[6] -= TMPVS1->VS3_QTDITE // 06 - DVO3QTDREQ
					aLibItem[9] -= Round(TMPVS1->VS3_VALPEC * TMPVS1->VS3_QTDITE,2) // 09 - DVO3VALBRU
					aLibItem[8] -= TMPVS1->VS3_VALDES // 08 - DVO3VALDES

					TMPVS1->(DbSkip())

				Enddo

				If !lTemPeca
					TMPVS1->( DbCloseArea() )
					Return .f.
				EndIf

				If aLibItem[6] <> 0 .or. ;
						aLibItem[9] <> 0 .or. ;
						aLibItem[8] <> 0
					TMPVS1->( DbCloseArea() )
					Return .f.
				EndIf

				TMPVS1->( DbCloseArea() )

			Endif

		Next

	EndIf

	If aProbOs[nCntFor, 7]

		For nCntFor2 := 1 to Len(aProbOs[nCntFor, 3])

			If !aProbOs[nCntFor, 3, nCntFor2, 2]
				nPos := aProbOs[nCntFor,3,nCntFor2,1]

				aLibItem  := aClone(aAuxVO4[nPos])

				lTemPeca := .f.

				///////////////////////////
				// Orcamentos            //
				///////////////////////////
				cQuery := "SELECT VS1.VS1_NUMORC, VS1.VS1_NUMLIB, VS1.VS1_NUMLIS, "
				cQuery +=       " VS4.VS4_GRUSER, VS4.VS4_CODSER, "
				cQuery +=       " VS4.VS4_TIPSER, VS4.VS4_VALSER, "
				cQuery +=       " VS4.VS4_TEMPAD, VS4.VS4_VALDES "
				cQuery += "FROM " + RetSqlName("VS1") + " VS1 "
				cQuery +=      " JOIN "+RetSqlName("VS4")+" VS4 "
				cQuery +=      "  ON VS4.VS4_FILIAL = '" + xFilial("VS3") + "' "
				cQuery +=      " AND VS4.VS4_GRUSER = '" + aAuxVO4[nPos,AS_GRUSER] + "' "
				cQuery +=      " AND VS4.VS4_CODSER = '" + aAuxVO4[nPos,AS_CODSER] + "' "
				cQuery +=      " AND VS4.VS4_NUMORC = VS1.VS1_NUMORC "
				cQuery +=      " AND VS4.VS4_VALDES <> 0 "
				cQuery +=      " AND VS4.D_E_L_E_T_=' ' "
				cQuery += "WHERE VS1.VS1_FILIAL = '" + xFilial("VS1") + "' "
				cQuery +=  " AND VS1.VS1_STATUS <> ' ' AND VS1.VS1_STATUS<>'C' "
				cQuery +=  " AND VS1.VS1_NUMOSV = '" + aAuxVO4[nPos,AS_NUMOSV] + "' "
				cQuery +=  " AND VS1.VS1_TIPTSV = '" + aAuxVO4[nPos,AS_TIPTEM] + "' "
				cQuery +=  " AND (VS1.VS1_NUMLIB <> ' ' OR VS1.VS1_NUMLIS <> ' ') "
				cQuery +=  " AND VS1.D_E_L_E_T_=' '"

				TcQuery cQuery New alias "TMPVS1"

				While !TMPVS1->( Eof() )

					lTemPeca := .t.

					///////////////////////////
					// Liberacao             //
					///////////////////////////
					cQuery := "SELECT VS6.R_E_C_N_O_ "
					cQuery += "FROM " + RetSqlName("VS6") + " VS6 "
					cQuery +=      " JOIN "+RetSqlName("VS7")+" VS7 "
					cQuery +=      "  ON VS7.VS7_FILIAL = '" + xFilial("VS7") + "' "
					cQuery +=      " AND VS7.VS7_GRUSER = '" + TMPVS1->VS4_GRUSER + "' "
					cQuery +=      " AND VS7.VS7_CODSER = '" + TMPVS1->VS4_CODSER + "' "
					cQuery +=      " AND VS7.VS7_TIPSER = '" + TMPVS1->VS4_TIPSER + "' "
					cQuery +=      " AND VS7.VS7_NUMIDE = VS6.VS6_NUMIDE "
					cQuery +=      " AND VS7.D_E_L_E_T_=' ' "
					cQuery += "WHERE VS6.VS6_FILIAL = '" + xFilial("VS6") + "' "
					cQuery +=  " AND VS6.VS6_NUMIDE IN ('" + TMPVS1->VS1_NUMLIB + "', '" + TMPVS1->VS1_NUMLIS + "') "
					cQuery +=  " AND VS6.VS6_NUMORC = '" + TMPVS1->VS1_NUMORC + "' "
					cQuery +=  " AND VS6.VS6_TIPAUT = '2' "
					cQuery +=  " AND VS6.VS6_DATAUT <> ' ' "
					cQuery +=  " AND VS6.D_E_L_E_T_ = ' '"

					If FM_SQL(cQuery) == 0
						TMPVS1->( DbCloseArea() )
						Return .f.
					EndIf

					aLibItem[AS_TEMPAD] -= TMPVS1->VS4_TEMPAD
					aLibItem[AS_VALBRU] -= TMPVS1->VS4_VALSER
					aLibItem[AS_VALDES] -= TMPVS1->VS4_VALDES

					TMPVS1->(DbSkip())

				Enddo

				If !lTemPeca
					TMPVS1->( DbCloseArea() )
					Return .f.
				EndIf

				If aLibItem[AS_TEMPAD] <> 0 .or. ;
					aLibItem[AS_VALBRU] <> 0 .or. ;
					aLibItem[AS_VALDES] <> 0
					TMPVS1->( DbCloseArea() )
					Return .f.
				EndIf

				TMPVS1->( DbCloseArea() )

			Endif
	
		Next

	EndIf
Next

Return .t.

/*/{Protheus.doc} OX1000061_Condicao_Negociada

@description Retorna se a Condi็ใo ้ Negociada ( no padrใo verifica apenas tipo "9" )
@author Andre Luis Almeida
@since 18/04/2022
/*/
Static Function OX1000061_Condicao_Negociada()
Local lRet := ( SE4->E4_TIPO == "9" )
//PE para permitir a manipula็ใo do retorno se a Condi็ใo ้ Negociada
If ExistBlock("OX100CNG")
	lRet := ExecBlock("OX100CNG",.f.,.f.,{ SE4->E4_TIPO })
EndIf
Return lRet
