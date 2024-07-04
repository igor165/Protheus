#include "TMSMWZE010.CH"
#Include 'Protheus.ch'
#Include 'Dbstruct.ch'

// Posicoes dos arrays principais
#DEFINE OPC_SELECT		1
#DEFINE OPC_NOME		2
#DEFINE OPC_DESCRI		3
#DEFINE OPC_OBSERV		4
#DEFINE OPC_IMPORT		5
#DEFINE OPC_EXPORT		6
#DEFINE OPC_SX5			7
#DEFINE OPC_ALIAS		8
#DEFINE OPC_ERRO		9
#DEFINE OPC_SOLUCAO		10

// Posicoes que ocuparao as colunas na tela de selecao de Rotinas
#DEFINE ROT_COL_SEL	1
#DEFINE ROT_COL_NOME	3
#DEFINE ROT_COL_DESC	4

// Posicoes que ocuparao as colunas na tela de selecao de Parametros
#DEFINE PAR_COL_SEL	1
#DEFINE PAR_COL_NOME	2
#DEFINE PAR_COL_DESC	3

#DEFINE PAR_PARAM		1
#DEFINE PAR_DESCR		2
#DEFINE PAR_VALOR		3

#DEFINE ERR_TITULO	1
#DEFINE ERR_DESCRI	2

#DEFINE PAN_IDA_PAD	6
#DEFINE PAN_IDA_AVA	3
#DEFINE PAN_VOL_PAD	2
#DEFINE PAN_VOL_AVA	5
#DEFINE PANEL_ROTINAS	4
#DEFINE PANEL_PARAMET	5
#DEFINE PANEL_STAT_ROT	1
#DEFINE PANEL_STAT_PAR	2
#DEFINE PANEL_STAT_ALE	3


#DEFINE LIN_X5_FILIAL	1
#DEFINE LIN_X5_DESTAB	2
#DEFINE LIN_X5_CHAVE	2
#DEFINE LIN_X5_DESCRI	3

Static lInverte1	:= .T.
Static lInverte2	:= .T.

/*/
{Protheus.doc} TMSMWZE010
Wizard TMS Wficaz
Agiliza a configuração do TMS Protheus, através da utilização de uma base de dados pré-configurada.
	
@author Mauro Paladini
@since 28/01/2014
@version 2.0		
/*/
Function TMSMWZE010()

Local oWizard		:= Nil
Local lPadrao		:= .T.
Local lAjusta		:= .T.
Local cPathArq		:= ""
Local cPathLay		:= ""
Local cRotErr		:= ""
Local nAliquota		:= 0
Local lExport		:= SuperGetMv('MV_TMSEFIX',,.F.)
Local aRotSel		:= {}
Local aCabRot		:= {'',STR0001} //'Rotina'
Local aParSel		:= {}
Local aCabPar		:= {'',STR0002, STR0003} //'Parametro'//'Descrição'
Local aErro			:= {}
Local aCabErr		:= {'',STR0004, STR0005} //'Erro'//'Descrição'

Private cModoWiz	:= iIf( lExport , STR0006 , STR0007 )//"Exportação"//"Importação"
Private cModoWiz2	:= iIf( lExport , STR0008 , STR0009 )//"exportar"//"importar"
Private oGetDados 	:= Nil

//------------------------------------------------------------
// Rotinas
//------------------------------------------------------------
AAdd (aRotSel, {.T., "AGRA045",	STR0010				,STR0011, "TMSEFI01", "TMSEFE01", { }, "NNR",,})//"Locais de Estoque"//"Descrição"
AAdd (aRotSel, {.T., "MATA010",	STR0012				,STR0013, "TMSEFI02", "TMSEFE02", { }, "SB1",,})//"Cadastro de Produtos"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0014   //"Verifique se o(s) produto(s) já existiam na abse ou se o Local de estoque foi cadastrado"

AAdd (aRotSel, {.T., "MATA360",	STR0015			,STR0016, "TMSEFI03", "TMSEFE03", { }, "SE4",,})//"Condição de Pagamento"//"Descrição"
AAdd (aRotSel, {.T., "FINA010",	STR0017			,STR0018, "TMSEFI04", "TMSEFE04", { }, "SED",,})//"Naturezas"//"Descrição"
AAdd (aRotSel, {.T., "CRMA980",	STR0019			,STR0020, "TMSEFI05", "TMSEFE05", { }, "SA1",,}) //"Cadastro de Clientes"//"Descrição"
AAdd (aRotSel, {.T., "MATA020",	STR0021			,STR0022, "TMSEFI06", "TMSEFE06", { }, "SA2",,})//"Cadastro de Fornecedores"//"Descrição"
AAdd (aRotSel, {.T., "DLGA080",	STR0023			,STR0024, "TMSEFI07", "TMSEFE07", { "L2", "L3" }, "DC6",,}) //"Tarefas x Atividades"//"Descrição"
AAdd (aRotSel, {.T., "DLGA070",	STR0025			,STR0026, "TMSEFI08", "TMSEFE08", { "L2", "L4" }, "DC5",,})//"Serviços x Tarefas"//"Descrição"
AAdd (aRotSel, {.T., "TMSA115",	STR0027			,STR0028, "TMSEFI09", "TMSEFE09", { }, "DUY",,})//"Grupos de Região"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0029	//"Verifique se há estrutura de região já cadastrada."

AAdd (aRotSel, {.T., "TMSA380",	STR0030			,STR0031, "TMSEFI10", "TMSEFE10", { }, "DTN",,})//"Complemento de Região"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0032	//"Verifique se o grupo de região existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "OMSA070",	STR0033			,STR0034, "TMSEFI11", "TMSEFE11", { }, "DA5",,})//"Zonas"//"Descrição"
AAdd (aRotSel, {.T., "OMSA080",	STR0035			,STR0036, "TMSEFI12", "TMSEFE12", { }, "DA6",,})//"Setores por Zona"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0037	//"Verifique se o cadastro de Zonas existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "OMSA090",	STR0038			,STR0039, "TMSEFI13", "TMSEFE13", { }, "DA7",,})//"Pontos por Setor"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0040	//"Verifique se o cadastro de Setores por Zona existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "OMSA100",	STR0041			,STR0042, "TMSEFI14", "TMSEFE14", { }, "DA8",,})//"Rotas"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0043	//"Verifique se os cadastros de serviços e Pontos por Setor existem em sua base ou se foram importados sem erros."

AAdd (aRotSel, {.T., "TMSA710",	STR0044			,STR0045, "TMSEFI15", "TMSEFE15", { }, "DVA",,})//"Distâncias"//"Descrição"
AAdd (aRotSel, {.T., "TMSA030",	STR0046			,STR0047, "TMSEFI16", "TMSEFE16", { }, "DT3",,}) //"Componentes de Frete"//"Descrição"
AAdd (aRotSel, {.T., "TMSA130",	STR0048			,STR0049, "TMSEFI18", "TMSEFE18", { }, "DTL",,})//"Conf. Tab.Frete"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0050	//"Verifique se a(s) tabela(s) de frete do arquivo já existe(m) em sua base. Verifique também se o cadastro de Componentes de Frete existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "TMSA010_20",	STR0051			,STR0052, "TMSEFI20", "TMSEFE20", { }, "DT0",,})//"Tabela de Frete Fracionado"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0053	//"Verifique se a tabela de frete do arquivo já existe em sua base ou se o cadastro de Configuração da tabela de Frete está correto ou se fora importado sem erros."

AAdd (aRotSel, {.T., "TMSA010_17",	STR0054			,STR0055, "TMSEFI17", "TMSEFE17", { }, "DT0",,})//"Tabela de Frete Lotação"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0056	//"Verifique se a tabela de frete do arquivo já existe em sua base ou se o cadastro de Configuração da tabela de Frete está correto ou se fora importado sem erros."

AAdd (aRotSel, {.T., "TMSA010_33",	STR0057			,STR0058, "TMSEFI33", "TMSEFE33", { }, "DT0",,})//"Tabela de Frete A Pagar"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0059	//"Verifique se a tabela de frete do arquivo já existe em sua base ou se o cadastro de Configuração da tabela de Frete está correto ou se fora importado sem erros."

AAdd (aRotSel, {.T., "MATA080",	STR0060			,STR0061, "TMSEFI19", "TMSEFE19", { }, "SF4",,}) //"Cadastro de Tipo de Ent/Saida"//"Descrição"
AAdd (aRotSel, {.T., "TMSA022",	STR0062			,STR0063, "TMSEFI21", "TMSEFE21", { }, "DY5",,})//"CFOP x Segmento"//"Descrição"
AAdd (aRotSel, {.T., "TMSA150",	STR0064			,STR0065, "TMSEFI22", "TMSEFE22", { }, "DUI",,})//"Configuração de Doctos"//"Descrição"
AAdd (aRotSel, {.T., "TMSA410",	STR0066			,STR0067, "TMSEFI23", "TMSEFE23", { }, "DUF",,})//"Regras de Tributação"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0068	//"Verifique se o cadastro de Configuração de Documentos existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "TMSA600",	STR0069			,STR0070, "TMSEFI24", "TMSEFE24", { }, "DV1",,})//"Regras Por Cliente"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0071	//"Verifique se o cadastro de Regras de Tributação existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "OMSA040",	STR0072			,STR0073, "TMSEFI25", "TMSEFE25", { }, "DA4",,})//"Cadastro de Motoristas"//"Descrição"
AAdd (aRotSel, {.T., "TMSA530",	STR0074			,STR0075, "TMSEFI26", "TMSEFE26", { }, "DUT",,})//"Tipos de Veículo"//"Descrição"
AAdd (aRotSel, {.T., "TMSA800",	STR0076			,STR0077, "TMSEFI31", "TMSEFE31", { }, "DUJ",,})//"Contrato Fornecedor"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0078	//"Verifique se o cadastro de Fornecedores existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "OMSA060",	STR0079			,STR0080, "TMSEFI27", "TMSEFE27", { }, "DA3",,})//"Cadastro de Veículos"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0081	//"Verifique se o cadastro de Tipos de Veículo existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "TMSA060",	STR0082			,STR0083, "TMSEFI28", "TMSEFE28", { }, "DT7",,})//"Despesas de transporte"//"Descrição"
AAdd (aRotSel, {.T., "TECA250",	STR0084			,STR0085, "TMSEFI29", "TMSEFE29", { }, "AAM",,}) //"Contrato Cliente"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0086	//"Verifique se os cadastros de Clientes, Serviços x Tarefas e Tabela de Frete existem em sua base ou se foram importados sem erros."

AAdd (aRotSel, {.T., "TMSA480",	STR0087			,STR0088, "TMSEFI30", "TMSEFE30", { }, "DUO",,})//"Perfil do Cliente"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0089	//"Verifique se o cadastro de Clientes existe em sua base ou se fora importado sem erros."

AAdd (aRotSel, {.T., "TMSA020",	STR0090			,STR0091, "TMSEFI32", "TMSEFE32", { }, "DT2",,})//"Cadastro de Ocorrências"//"Descrição"
AAdd (aRotSel, {.T., "EDIProc",	STR0092			,STR0093, /*LayoutImp*/, /*LayoutExp*/, { }, { "DE0","DE1","DE3","DE9","DED","DEE" },,})//"EDI Proceda"//"Descrição"
aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0094	//"Verifique se já existiam EDI's configurados em sua base. Este cadastro somente será importado em base vazia"

//------------------------------------------------------------
// Parametros
//------------------------------------------------------------

AAdd(aParSel, {.T., 'MV_1DUPREF' ,  STR0095}) //'Campo ou dado a ser gravado no prefixo do titulo. Quando o mesmo for gerado automaticamente pelo modulo de faturamento. '
AAdd(aParSel, {.T., 'MV_ADTPRO'  ,  STR0096}) //'Informe se gera adiantamento para motorista proprio.'
AAdd(aParSel, {.T., 'MV_AGECOTS' ,  STR0097}) //'Define se a cotacao gerada a partir do agendamento devera ser sempre para o solicitante. '
AAdd(aParSel, {.T., 'MV_ALIANCA' ,  STR0098}) //'Define se utiliza Alianca no SIGATMS'
AAdd(aParSel, {.T., 'MV_ALIQISS' ,  STR0099}) //'Aliquota do ISS em casos de prestacao de servicos.usando percentuais definidos pelo municipio.   '
AAdd(aParSel, {.T., 'MV_APSOLTR' ,  STR0100}) //'.T. -Os documentos seräo transf.automaticamente p/a Filial de debito destino;.F. -A filial de debito destino tera que aprovar todas as transf.solicit. '
AAdd(aParSel, {.T., 'MV_ATIVCHG' ,  STR0101}) //'Atividade de Chegada de Viagem'
AAdd(aParSel, {.T., 'MV_ATIVDCA' ,  STR0102}) //'Atividade de Descarregamento'
AAdd(aParSel, {.T., 'MV_ATIVRTA' ,  STR0103}) //'Atividade de Retorno do Aeroporto'
AAdd(aParSel, {.T., 'MV_ATIVRTP' ,  STR0104}) //'Atividade de Retorno do Porto'
AAdd(aParSel, {.T., 'MV_ATIVSAI' ,  STR0105}) //'Atividade de Saida de Viagem'
AAdd(aParSel, {.T., 'MV_BLQPES'  ,  STR0106}) //'Define o peso a ser utilizado no bloqueio das viagens, podendo ser configurado como: 1=Peso Real, 2=Peso Cubado e 3=Maior Peso.'
AAdd(aParSel, {.T., 'MV_CALNORI' ,  STR0107}) //'Utilizado para definir se devera ser verificado os niveis superiores da regiao de origem no calculo do frete'
AAdd(aParSel, {.T., 'MV_CANCFT'  ,  STR0108}) //"Permite o cancelamento de CTRC'S contidos em uma fatura que ja tenha sido movimentada ?"
AAdd(aParSel, {.T., 'MV_CANCHST' ,  STR0109}) //'Permite efetuar o cancelamento da fatura e gravar ou nao o historico de cancelamento'
AAdd(aParSel, {.T., 'MV_CARGDIR' ,  STR0110}) //'Determina a partir de qual peso em Kg sera considerada uma carga direta.'
AAdd(aParSel, {.T., 'MV_CDHISAP' ,  STR0111}) //'Informe o codigo do historico de fechamento de racao de premio de seguros do TMS '
AAdd(aParSel, {.T., 'MV_CDRMUN'  ,  STR0112}) //'Codigo da regiao do municipio'
AAdd(aParSel, {.T., 'MV_CLICOT'  ,  STR0114}) //'Utiliza informacoes de preco do cliente'
AAdd(aParSel, {.T., 'MV_CLIGEN'  ,  STR0115}) //'Define o codigo do Cliente / Loja que serao utili-zados nos Contratos Genericos (Modulo TMS) '
AAdd(aParSel, {.T., 'MV_COLSOCO' ,  STR0116}) //'Gera contrato de carreteiro para viagens de coleta sem registro de ocorrencia ?'
AAdd(aParSel, {.T., 'MV_COMPENT' ,  STR0117}) //'Codigo do Componente de Entrega'
AAdd(aParSel, {.T., 'MV_COMPIMP' ,  STR0118}) //'Codigo do componente de frete que sera utilizado para complemento de imposto. '
AAdd(aParSel, {.T., 'MV_COMPPDG' ,  STR0119}) //'Informe o codigo do componente de frete de pedagio'
AAdd(aParSel, {.T., 'MV_CONTDCA' ,  STR0120}) //'Efetua controle de descarregamento '
AAdd(aParSel, {.T., 'MV_CONTHIS' ,  STR0121}) //'Controla alteracao da Tabela/Ajuste de Frete '
AAdd(aParSel, {.T., 'MV_CONTVEI' ,  STR0122}) //'Controla Motoristas / Veiculos ? '
AAdd(aParSel, {.T., 'MV_COTVFEC' ,  STR0123}) //'Permitir a digitacao de valor fechado por componente na cotacao de frete.'
AAdd(aParSel, {.T., 'MV_CTCPREF' ,  STR0124}) //'Define o prefixo utilizado no contrato de carreteiro'
AAdd(aParSel, {.T., 'MV_DATAFAT' ,  STR0125}) //'Data de emissao da fatura. Se nao for informado sera considerada a data atual do sistema'
AAdd(aParSel, {.T., 'MV_DESAWB'  ,  STR0126}) //"Codigo de Despesa de AWB's"
AAdd(aParSel, {.T., 'MV_DESCTC'  ,  STR0127}) //'Codigo de Despesa de contrato de carreteiro'
AAdd(aParSel, {.T., 'MV_DESPDG'  ,  STR0128}) //'Codigo de Despesa de Pedagio'
AAdd(aParSel, {.T., 'MV_DESPRE'  ,  STR0129}) //'Codigo de Despesa de Contrato de Premio'
AAdd(aParSel, {.T., 'MV_DOCNAVB' ,  STR0130}) //'Define os tipos de documentos que nao deveram ser averbados. Para a separacao devera ser utilizada avirgula.'
AAdd(aParSel, {.T., 'MV_DOCVGE'  ,  STR0131}) //'Determina se os enderecos/documentos podem ser vinculados a uma viagem atraves do carregamento'
AAdd(aParSel, {.T., 'MV_DOMFERI' ,  STR0132}) //'Deve considerar domingo como feriado quando utilizado a funcao DTVALID() ?'
AAdd(aParSel, {.T., 'MV_EDIDIRE' ,  STR0133}) //'Diretorio de envio dos arquivos EDI'
AAdd(aParSel, {.T., 'MV_EDIDIRR' ,  STR0134}) //'Diretorio de recebimento de arquivos edi.'
AAdd(aParSel, {.T., 'MV_EDILOG'  ,  STR0135}) //'Gera Log '
AAdd(aParSel, {.T., 'MV_EDIRMOV' ,  STR0136}) //'Diretorio de backup dos arquivos recebidos edi'
AAdd(aParSel, {.T., 'MV_ENTAER'  ,  STR0137}) //'Define o Tipo de Transporte que realizara a Entrega de um Transporte Aereo; 1- Rodoviario / 2 -  Aereo'
AAdd(aParSel, {.T., 'MV_ENCVDOC' ,  STR0138}) //'Encerra viagem com documentos em transito em qualquer filial ? 0=Nao Encerra 1=Encerra Viagem 2=Pergunta'
AAdd(aParSel, {.T., 'MV_ENTSOCO' ,  STR0139}) //'Gera contrato de carreteiro para viagens de entrega sem registro de ocorrencia ?'
AAdd(aParSel, {.T., 'MV_ENCVIAG' ,  STR0140}) //'Define se devera encerrar a viagem com ocorrencia para todos os documentos.'
AAdd(aParSel, {.T., 'MV_ENVIAG'  ,  STR0141}) //'Permite validar se o veiculo esta em uso para outra viagem, mesmo com o controle de veiculos desligado'
AAdd(aParSel, {.T., 'MV_ESPECIE' ,  STR0142}) //'Contem tipos de documentos fiscais utilizados na  emissao de notas fiscais'
AAdd(aParSel, {.T., 'MV_FATCUB'  ,  STR0144}) //'Fator de cubagem padrao'
AAdd(aParSel, {.T., 'MV_FATPREF' ,  STR0145}) //'Prefixo do titulo da fatura de transporte'
AAdd(aParSel, {.T., 'MV_FILDPC'  ,  STR0146}) //'Define as filiais aliancas que efetuam redespac para a filial atual.'
AAdd(aParSel, {.T., 'MV_FORGEN'  ,  STR0147}) //'Define o codigo do Fornecedor / Loja que serao utilizados nos contratos genericos (Modulo TMS)'
AAdd(aParSel, {.T., 'MV_FORINSS' ,  STR0148}) //'Fornecedor padrao para titulos de INSS'
AAdd(aParSel, {.T., 'MV_FORSEG'  ,  STR0149}) //'Define o codigo do Fornecedor / Loja que serao  u-tilizados na geracao de titulos a pagar de seguro'
AAdd(aParSel, {.T., 'MV_FORSEST' ,  STR0150}) //'Fornecedor padrao para titulos de SEST'
AAdd(aParSel, {.T., 'MV_GERADF'  ,  STR0152}) //'Gera Contas a Pagar do Adiantamento de Frete com valor superior ao valor do frete+pedagio'
AAdd(aParSel, {.T., 'MV_GERCONT' ,  STR0153}) //'Gera Contrato de Carreteiro para Viagens de Ent   a / Coleta Nao Efetuadas ?'
AAdd(aParSel, {.T., 'MV_GEROPER' ,  STR0154}) //'Valida se o carregamento devera gerar as operacoes informadas no Servico Operacional do Servico de Negociacao'
AAdd(aParSel, {.T., 'MV_GERTIT'  ,  STR0155}) //'Gerar Contas a Pagar no Contrato de Carreteiro ?'
AAdd(aParSel, {.T., 'MV_HORCOF'  ,  STR0156}) //'Horario final de coletas da transportadora'
AAdd(aParSel, {.T., 'MV_HORCOI'  ,  STR0157}) //'Horario inicial de coletas da transportadora'
AAdd(aParSel, {.T., 'MV_INCISS'  ,  STR0158}) //'Verifica se o calculo do ISS devera ser embutido'
AAdd(aParSel, {.T., 'MV_INTTMS'  ,  STR0159}) //'Identifica se o Modulo do TMS esta integrado aos  outros modulos.'
AAdd(aParSel, {.T., 'MV_ISS'     ,  STR0160}) //'Natureza utilizada para Imposto s/Servico'
AAdd(aParSel, {.T., 'MV_KMDIST'  ,  STR0161}) //'Define que o calculo do Km será sempre pelo cadastro de Distancia para os calculos do frete a pagar.'
AAdd(aParSel, {.T., 'MV_KMOBRIG' ,  STR0162}) //'Obriga informar a quilometragem apos o apontamentodos registros das ocorrencias qdo todos os doctos da viagem estiverem com o status concluido.'
AAdd(aParSel, {.T., 'MV_KMVEIOP' ,  STR0163}) //'Valida se Mostra Tela de Apontamento Manual de chegada / Saida de Viagens'
AAdd(aParSel, {.T., 'MV_LIMINSS' ,  STR0164}) //'Valor limite de retencäo para o INSS de pessoa fisica'
AAdd(aParSel, {.T., 'MV_LOCALIZ' ,  STR0165}) //'Indica se produtos poderao usar controle de localizacao fisica ou nao. (S)im ou (N)ao.'
AAdd(aParSel, {.T., 'MV_MANVIAG' ,  STR0166}) //'Permite manifestar viagens ainda nao disponiveis para a filial corrente'
AAdd(aParSel, {.T., 'MV_MOTGEN'  ,  STR0167}) //'Codigo do motorista generico'
AAdd(aParSel, {.T., 'MV_MULTEND' ,  STR0168}) //'Permite multiplo enderecamento para cada NF de Cliente'
AAdd(aParSel, {.T., 'MV_MUNIC' 	 ,  STR0169}) //'Utilizado para identificar o codigo dado a  secre-taria das financas do municipio para recolher o ISS'
AAdd(aParSel, {.T., 'MV_NATCTC'  ,  STR0170}) //'Codigo da Natureza utilizado para geracao de titu-los a pagar provenientes de contratos de carretei-ros.'
AAdd(aParSel, {.T., 'MV_NATDEB'  ,  STR0171}) //'Codigo da Natureza utilizado para geracao de titu-los a pagar provenientes de contratos de carretei-ros para a Filial de Debito'
AAdd(aParSel, {.T., 'MV_NATFAT'  ,  STR0172}) //'Codigo da Natureza do titulo da fatura de transporte.'
AAdd(aParSel, {.T., 'MV_NATFTRA' ,  STR0173}) //'Codigo da natureza de fatura de transporte. Informe uma natureza para cada tipo de transporte (1=Rodoviario;2=Aereo;3=Fluvial).'
AAdd(aParSel, {.T., 'MV_NATPDG'  ,  STR0174}) //'Codigo da Natureza utilizado para geracao de titu-los a pagar provenientes de valores de pedagios.'
AAdd(aParSel, {.T., 'MV_NUMFAT'  ,  STR0175}) //'Numero sequencial de Faturas'
AAdd(aParSel, {.T., 'MV_OCODOC'  ,  STR0176}) //'Se a categoria da ocorrencia for por documento, considera todos os documentos da viagem ?'
AAdd(aParSel, {.T., 'MV_OCORCOL' ,  STR0177}) //'Define a ocorrencia de coleta utilizado no apontamento automatico de ocorrencia na geracao da nota'
AAdd(aParSel, {.T., 'MV_OCORENT' ,  STR0178}) //'Define a ocorrencia de entrega utilizada no apontamento automatico de ocorrencias no calculo de frete'
AAdd(aParSel, {.T., 'MV_OCORREE' ,  STR0179}) //'Define ocorrencias de reentrega'
AAdd(aParSel, {.T., 'MV_PASSTAB' ,  STR0180}) //'Controle de Passos na Geracao de Tabelas de Free Reajuste de preco de Cliente'
AAdd(aParSel, {.T., 'MV_PCANOP'  ,  STR0181}) //'Define se na chegada/saida/encerramento de viagem existirem operacoes anteriores devera 0-Cancelar; 1=Perg.Antes de Canc.;2=Nao Canc.;3=Apont.Obrigat.'
AAdd(aParSel, {.T., 'MV_PESCOB'  ,  STR0182}) //'Componente de frete que determina o peso cobrado  '
AAdd(aParSel, {.T., 'MV_PRCPROD' ,  STR0183}) //'O valor base para calculo do frete sera por produto ?'
AAdd(aParSel, {.T., 'MV_PRDCTC'  ,  STR0184}) //'Produto utilizado para Gerar Pedido de Compras / Contrato de Carreteiro (Pessoa Juridica)'
AAdd(aParSel, {.T., 'MV_PRDDIV'  ,  STR0185}) //'Define se podera ser informado Diversos Produto nos programas do Modulo do TMS (Gestäo de Transporrtes)'
AAdd(aParSel, {.T., 'MV_PREGPE'  ,  STR0186}) //'Gera Premio para Motorista Proprio na Folha de Pagamento ?'
AAdd(aParSel, {.T., 'MV_PROGEN'  ,  STR0187}) //'Define o codigo do produto que sera utilizado para obtencao de tabelas de frete ou seguro quando não for encontrado o cod.produto solicitado '
AAdd(aParSel, {.T., 'MV_REDESP'  ,  STR0188}) //'Controla Redespacho no Transporte ? '
AAdd(aParSel, {.T., 'MV_ROTGCOL' ,  STR0189}) //'Rota generica para coleta'
AAdd(aParSel, {.T., 'MV_ROTGENT' ,  STR0190}) //'Rota generica para entrega'
AAdd(aParSel, {.T., 'MV_ROTGTAB' ,  STR0191}) //'Rota generica para tabela de frete de carreteiros '
AAdd(aParSel, {.T., 'MV_SELDOC'  ,  STR0192}) //'Na consulta padrao, define se os documentos serao selecionados automaticamente na Viagem Modelo 2.'
AAdd(aParSel, {.T., 'MV_SELFIS'  ,  STR0193}) //'Filiais que usam o selo fiscal'
AAdd(aParSel, {.T., 'MV_SELSERV' ,  STR0194}) //'T Ativa tela de selecao de servico na inclusao do documento do cliente. F Desativa tela.'
AAdd(aParSel, {.T., 'MV_SERTMS'  ,  STR0195}) //'Define a descricäo dos servicos de transporte.    Ex: 1=Coleta;2=Transporte;3=Entrega.'
AAdd(aParSel, {.T., 'MV_SRVALI'  ,  STR0196}) //'Servico de Transporte Alianca de segundo percurso'
AAdd(aParSel, {.T., 'MV_SRVFAT'  ,  STR0197}) //'Define os servicos para o documento de fatura E   B1=001;C2=010, onde, B=Docto Transporte e 1=Tipo '
AAdd(aParSel, {.T., 'MV_SVCENT'  ,  STR0198}) //'Codigo do servico p/ carregamento de entrega do modulo TMS. '
AAdd(aParSel, {.T., 'MV_SVCLOT'  ,  STR0199}) //'Codigo do servico p/ conferencia de lote de notas fiscais do modulo TMS.'
AAdd(aParSel, {.T., 'MV_TESAWB'  ,  STR0200}) //'Tipo de Entrada/Saida para a geracäo de AWB '
AAdd(aParSel, {.T., 'MV_TESDD'   ,  STR0201}) //'TES pre-determinado para geracao de movimentos de vasilhames ou mercadorias a serem transportadas r emetidos para terceiros.'
AAdd(aParSel, {.T., 'MV_TESDR'   ,  STR0202}) //'TES pre-determinado para geracao de movimentos de vasilhames ou mercadorias a serem transportadas r emetidos por terceiros. '
AAdd(aParSel, {.T., 'MV_TIPFAT'  ,  STR0203}) //'Tipo do titulo da fatura de transporte.'
AAdd(aParSel, {.T., 'MV_TMPCOL'  ,  STR0204}) //'Tempo medio previsto para efetuar coletas.'
AAdd(aParSel, {.T., 'MV_TMPNORI' ,  STR0205}) //'Permite pesquisar em todos os niveis de região de origem.'
AAdd(aParSel, {.T., 'MV_TMSALOC' ,  STR0206}) //'Determina se devera verificar veiculos/motoristas utilizados no periodo informado no complemento de viagem.'
AAdd(aParSel, {.T., 'MV_TMSBLVG' ,  STR0207}) //'O sistema devera bloquear a viagem mesmo com a existencia de um desbloqueio anterior.'
AAdd(aParSel, {.T., 'MV_TMSCDPG' ,  STR0208}) //'Considera condicao de pagamento informada no cadastro do fornecedor, para geracao do contrato de carreteiro por viagem.'
AAdd(aParSel, {.T., 'MV_TMSCFEC' ,  STR0209}) //'Indica se as funcionalidades de carga fechada estao ativas'
AAdd(aParSel, {.T., 'MV_TMSCRET' ,  STR0210}) //'Codigo de Retencao da DIRF usado para gerar o   Contrato de Carreteiro (Modulo de Transporte) '
AAdd(aParSel, {.T., 'MV_TMSCRTR' ,  STR0211}) //'Controla o bloqueio de credito na solicitacao de transferencia de debito.'
AAdd(aParSel, {.T., 'MV_TMSDTVC' ,  STR0212}) //'Define a data de vigencia do contrato do fornecedor utilizada na liberacao do contrato 1=Data de emissao do contato, 2=Data de liberacao do contrato.'
AAdd(aParSel, {.T., 'MV_TMSDOC'  ,  STR0213}) //'Define a descricao dos documentos de transporte   B e C. '
AAdd(aParSel, {.T., 'MV_TMSEXP'  ,  STR0214}) //'Controla Modo Express'
AAdd(aParSel, {.T., 'MV_TMSFATU' ,  STR0215}) //'F nao considera a filial cadastrada no registro de indenizacao. t considera a filial cadastrada no registro de indenizacao.'
AAdd(aParSel, {.T., 'MV_TMSFMSG' ,  STR0216}) //'Define se devera apresentar a mensagem para fatura geradas.'
AAdd(aParSel, {.T., 'MV_TMSGREM' ,  STR0217}) //'Indica se os campos DTC_CODREM e DT6_LOJREM serao mantidos em tela, e validados automaticamente. '
AAdd(aParSel, {.T., 'MV_TMSGRPC' ,  STR0218}) //'Indica se o Contrato de Carreteiro deve gerar PEDIDO de Compras '
AAdd(aParSel, {.T., 'MV_TMSMFAT' ,  STR0219}) //'Modo de Faturamento do TMS. 1- Faturamento a pa   r do SE1; 2- Faturamento a partir do DT6 '
AAdd(aParSel, {.T., 'MV_TMSOCOL' ,  STR0220}) //'Permite informar a ocorrencia do documento em outra filial.'
AAdd(aParSel, {.T., 'MV_TMSPCLI' ,  STR0221}) //'Permite a busca de pontos por setor, configurado por codigo de cliente'
AAdd(aParSel, {.T., 'MV_TMSRVOL' ,  STR0222}) //'Rateio do valor do frete a pagar por volumes coletados e/ou entregues'
AAdd(aParSel, {.T., 'MV_TMSUNFS' ,  STR0223}) //'Informe se a filial utiliza nota fiscal ou Conhecimento para Documentos de Armazenagem, Reentrega e Refaturamento. '
AAdd(aParSel, {.T., 'MV_TMSVDEP' ,  STR0224}) //'Valor por dependente'
AAdd(aParSel, {.T., 'MV_TMSUFPG' ,  STR0225}) //'Indica o estado que sera utilizado na escrituracao dos documentos de transportes sendo que t=pagador do frete e f = destinatario da mercadoria.'
AAdd(aParSel, {.T., 'MV_TMSVINF' ,  STR0226}) //'Permite informar o valor do frete na digitacao Nota Fiscal '
AAdd(aParSel, {.T., 'MV_TPNRNFS' ,  STR0227}) //'Define o tipo de controle de numeração de documentos (1=SX5,2=SXE/SXF)'
AAdd(aParSel, {.T., 'MV_TPTCTC'  ,  STR0228}) //'Tipo de titulos a pagar provenientes de contratos de carreteiros. '
AAdd(aParSel, {.T., 'MV_TPTPDG'  ,  STR0229}) //'Tipo de titulos a pagar provenientes de valores de pedagios. '
AAdd(aParSel, {.T., 'MV_TPTPRE'  ,  STR0230}) //'Tipo dos  titulos a pagar provenientes de contrato de Premio de Carreteiro '
AAdd(aParSel, {.T., 'MV_ULTDEST' ,  STR0231}) //'Define se utiliza o ultimo destino da coleta/     entrega para calculo do frete.'
AAdd(aParSel, {.T., 'MV_VEIGEN'  ,  STR0232}) //'Codigo do veiculo generico de categoria STR0233  '//"Cavalo"//'Codigo do veiculo generico de categoria "Cavalo"  '
AAdd(aParSel, {.T., 'MV_VERBMOT' ,  STR0234}) //'Validade da cotacao de frete em dias '
AAdd(aParSel, {.T., 'MV_VLDCOT'  ,  STR0235}) //'Aglutina itens da tabela SD2 ou SC6 ao efetuar calculo de Frete e Geracao de Fatura para documentos de apoio?'
AAdd(aParSel, {.T., 'MV_TMSAGD2' ,  STR0236}) //'Numero do registro na ANTT.'
AAdd(aParSel, {.T., 'MV_TMSANTT' ,  STR0237}) //'Permite o usuario retirar a obrigatoriedade de apontar a operacao descarregamento da viagem para que seja possivel efetuar o encerramento da viagem'
AAdd(aParSel, {.T., 'MV_TMSCDCA' ,  STR0238}) //'Permite o usuario retirar a obrigatoriedade de apontar a operacao descarregamento da viagem para que seja possivel efetuar o encerramento da viagem'
AAdd(aParSel, {.T., 'MV_TMSCTE'  ,  STR0239}) //'Habilita o Ct-e - Conhecimento de transp.Eletronico'
AAdd(aParSel, {.T., 'MV_TMSD2NF' ,  STR0240}) //'Gerar item SD2 aglutinado para Nota Fiscal (tipo documento 5) no TMS '
AAdd(aParSel, {.T., 'MV_TMSDIAV' ,  STR0241}) //'Calcula a quantidade do compoenente Diaria (54 e  60) por Fornecedor e Veiculo '
AAdd(aParSel, {.T., 'MV_TMSDIND' ,  STR0242}) //'Numero de dias que sera permitido apontar uma ocorrencia de Indenizacao apos a entrega do documento'
AAdd(aParSel, {.T., 'MV_TMSFOB'  ,  STR0243}) //'Define se o tipo do frete para o consignatario ou despachante e FOB como sugestao.  '
AAdd(aParSel, {.T., 'MV_TMSNFAT' ,  STR0244}) //'Considera a seqüencia do parametro MV_NUMFAT para numeracao dos titulos quando utilizado documentos de apoio. '
AAdd(aParSel, {.T., 'MV_TMSGVT'  ,  STR0245}) //'Tempo em seguntdos para execucao do refresh no painel de gestao de viagens. Em caso de "0" o refresh automatico e desabilitado. '
AAdd(aParSel, {.T., 'MV_TMSOPDG' ,  STR0246}) //'Indica se a integracao com Operadoras de Frota esta ativa. 0=Nao utiliza, 1=Somente Vale-Pedagio e 2=Vale Pedagio e Frota '
AAdd(aParSel, {.T., 'MV_TMSPROC' ,  STR0247}) //'Indica se o sistema deve usar as procedures instaladas no banco de dados para as rotinas do   TMS '
AAdd(aParSel, {.T., 'MV_TMSPVOC' ,	STR0248})//'Calcula o valor do componente de frete a pagar ""Peso/Volume"" com base no apontamento da ocorrencia. '
AAdd(aParSel, {.T., 'MV_TPDCREE' ,  STR0249}) //'Quais os tipos de documentos de origem do TMS que Reentrega. 2 = CTRC e 5 = Nota Fiscal, (2;5) Aceita mais de um documento.'
AAdd(aParSel, {.T., 'MV_ATIVRTA' ,  STR0250}) //'Atividade de Retorno do Aeroporto'
AAdd(aParSel, {.T., 'MV_ATIVRTP' ,  STR0251}) //'Atividade de Retorno do Porto'
AAdd(aParSel, {.T., 'MV_ATIVRDP' ,  STR0252}) //'Atividade de Saida para retirada do Reboque'
AAdd(aParSel, {.T., 'MV_OBSREEN' ,  STR0253}) //'Observacao do documento de Reentrega.'
AAdd(aParSel, {.T., 'MV_DATATMS' ,  STR0254}) //'Data limite para as movimentacoes no modulo'
AAdd(aParSel, {.T., 'MV_SERARM'  ,  STR0255}) //'Informe um servico para cobranca de armazenagem relacionado no contrato do cliente.'
AAdd(aParSel, {.T., 'MV_ATIVCHP' ,  STR0256}) //'Atividade de chegada do reboque no destino'
AAdd(aParSel, {.T., 'MV_CREDCLI' ,  STR0257}) //'Utilizado na liberacao automatica de credito Utilize "L" para controle de credito por loja ou "C" para controle de credito por cliente.'

Aviso( STR0330, STR0423, {STR0424} ) //STR0330 "Parametros" STR0423 "Os Parametros MV_ESTADO, MV_CDRORI e MV_FRETEST devem ser preenchidos atraves do Configurador." STR0424 "OK"
// Preenchendo aPanels com os passos que o Wizard deve possui
//------------------------------------------------------------
// Tela de Apresentacao
//------------------------------------------------------------
oWizard := APWizard():New(		STR0258 ,; //"Wizard TMS Protheus"
								STR0259 + iIf( lExport , STR0260 , STR0261 ) + STR0262  ,;//"Este assistente irá lhe ajudar a"//" exportar "//" importar "//"os dados necessários para a funcionamento do TMS."
								STR0263 + cModoWiz ,;//"Assistente de "
								STR0264 + CRLF + CRLF + ;//"Este wizard tem como objetivo agilizar a configuração do TMS Protheus, através da utilização de uma base de dados pré-configurada, para as funcionalidades: "
								STR0265 + CRLF + ;//"- Emissão do CTRC (o CT-e necessita de certificado específico do cliente para transmissão junto ao SEFAZ); "
								STR0266 + CRLF + ;//"- Operação da carga; "
								STR0267 + CRLF ,;//"- Controle e pagamento de terceiros e de agregados. "
								{|| .T. },; // bNext
								{|| .T. },; // bFinish
								, , , )
								
//------------------------------------------------------------
// P1. Tela de Entrada do path dos arquivos de importação
//------------------------------------------------------------
oWizard:NewPanel( 	STR0268 ,;  //"Arquivos de IO"
					STR0269 ,; 	//"Defina o local dos arquivos de entrada da configuração."
					{|| .T.} ,; // bBack
					{|| VldGetFolder( cPathArq , cPathLay ) }  , ; // bNext
					{|| .T.} ,; // bFinish
					 .T. ,; // lPanel
					 {|| getFolder(oWizard, @cPathArq, @cPathLay, @lExport)}) // bExecute lArq := ParamBox(aParam, "Arquivos de Importação", @aRet) })

//------------------------------------------------------------
// P2. Tela de Tipo de instalacao - Simples / Avancada
//------------------------------------------------------------
oWizard:NewPanel( 	STR0270 ,; //"Tipo de Instalação"
					STR0271 ,;//"Defina se deseja utilizar a instalação Simples, processando todas as rotinas disponiveis. Ou Avançada     se deseja efetuar o processamento para rotinas selecionadas."
					 {|| .T.} ,; // bBack
					 {|| ( oWizard:setPanel( iif( lPadrao , iIf( lExport , 6 , 5 ) , PAN_IDA_AVA ) ), .T.) }  , ; // bNext
					 {|| .T.} ,; // bFinish
					 .T. ,; // lPanel
					 {|| getType( @lPadrao, oWizard ) }) // bExecute

//------------------------------------------------------------
// P3. Tela de seleção das rotinas que serão importadas
//------------------------------------------------------------
oWizard:NewPanel( 	STR0272 ,; //"Rotinas a processar"
					STR0273 + cModoWiz2 + STR0274 ,;//"Selecione as rotinas que deseja "//" para a base"
					{||.T.}	,; // bBack
					{||.T.}	,; // bNext
					{||.T.}	,; // bFinish
					.T. ,; // lPanel
					{|| wizSelOpc(oWizard, @aRotSel, aCabRot, .T.) }) // bExecute

//------------------------------------------------------------
// P4. Tela de seleção dos Parametros que serao importados
//------------------------------------------------------------
oWizard:NewPanel( 	STR0275 ,; //"Parametros a processar"
					STR0276 + cModoWiz2 + STR0277 ,;//"Selecione os parametros que deseja "//" para a base"
					{||.T.}	,; // bBack
					{||( oWizard:setPanel( iIf( lExport , 6 , 5 ) ) , .T.) }	,;
					{||.T.}	,; // bFinish
					.T. ,; // lPanel
					{|| wizSelOpc(oWizard, @aParSel, aCabPar, .F.) }) // bExecute

//------------------------------------------------------------
// P5. Tela de Ajuste de Localizacao
//------------------------------------------------------------
oWizard:NewPanel( 	STR0278 ,; //"Ajuste de Localização"
					STR0279 ,;//"Informe se deseja que o assistente configure a localização de sua filial."
					{|| ( iIf( lPadrao , oWizard:SetPanel( 4 ) , nil ), .T. )} , ; // bBack
					{|| ( VldAjusLoc( lAjusta , lPadrao , nAliquota, oWizard ) ) },;
					{|| .T. },; // bFinish
					.T. ,; // lPanel
					{|| getAjusLoc( @lAjusta, lPadrao, @nAliquota, oWizard ) }) // bExecute


//------------------------------------------------------------
// P6. Tela de confirmação do processamento
//------------------------------------------------------------
oWizard:NewPanel(	STR0280 ,; //"Confirmação"
					STR0281 ,;//"Você confirma o processamento dos dados selecionados?"
					{|| oWizard:SetPanel( iIf( lExport , iIf( lPadrao , 4 , 6 ) , iIf( lPadrao , 4 , 7 ) )  ), .T. } , ; // bBack
					{|| FWMsgRun( oWizard:oMPanel[oWizard:nPanel] , {|oWait| wizProcTxt(oWait,oWizard, @aRotSel, @aParSel, cPathArq,cPathLay, lExport, @aErro, @cRotErr, lAjusta, nAliquota) } ,, STR0282 ) , .T. } ,;  // ////"Aguarde enquanto os arquivos de dados são processados"
					{||.T.} ,; // bFinish
					.T. ,; // lPanel
					{|| wizConfirm(oWizard) }) // bExecute


//------------------------------------------------------------
// P7. Tela de informação sobre a importação dos arquivos
//------------------------------------------------------------
oWizard:NewPanel( 	STR0283 ,; //"Rotina finalizada"
					STR0284 ,;//"O sistema concluiu a rotina de processamento."
					 {||.F.} ,; // bBack
					 {||.F.} ,; // bNext
					 {||.T.} ,; // bFinish
					 .T. ,; // lPanel
					 {|| wizStaProc(oWizard, aRotSel, aParSel, aCabRot, aCabPar, cRotErr, aErro, aCabErr ) }) // bExecute

oWizard:Activate(	.T./*<.lCenter.>*/,;
					{||.T.}/*<bValid>*/, ;
					{||.T.}/*<bInit>*/, ;
					{||.T.}/*<bWhen>*/ )

Return
      

//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} VldGetFolder
	
@author Mauro Paladini
@since 06/01/2014
@version 1.0
		
@description
Efetua a validacao do Panel de selecao de diretorios para os layouts de importacao/exportacao

/*/
//--------------------------------------------------------------------------------------------------------

Static Function VldGetFolder( cPathArq , cPathLay )

Local lRet :=  .T.

If Empty(cPathArq)
	lRet := .F.
	MsgStop(STR0285)//"O local dos arquivos não foi informado."
Endif

If lRet .And. Empty(cPathLay)
	lRet := .F.
	MsgStop(STR0286)//"O local dos arquivos de layout não foi informado."
Endif

Return lRet


//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} wizProcTxt
	
@author wanderley.ramos
@since 08/10/2013
@version 1.0
		
@param oWizard, objeto, 
@param @aRotSel, ${param_type}

@return Nil , Nulo

@description

Efetua processamento dos arquivos de importação

/*/
//--------------------------------------------------------------------------------------------------------

Static Function wizProcTxt(oWait,oWizard, aRotSel, aParSel, cPathArq,cPathLay, lExport, aErro, cRotErr, lAjusta, nAliquota)

Local oMile			:= Nil
Local nRot			:= 0

//Imp/Exp Manual
Local nH			:= 0
Local cLinha		:= ""
Local cTipo			:= ""
Local cDado			:= ""
Local cTabX5		:= ""
Local cFile			:= ""
Local cCliGen		:= ""
Local cLayout		:= ""
Local cRegSup		:= ""
Local cFilCC2		:= xFilial('CC2')
Local cFilDUY		:= xFilial('DUY')
Local cFilSA1		:= xFilial('SA1')
Local cFreteEst		:= GetMv('MV_FRETEST',,'')
Local xDado	
Local nAlias		:= 0
Local nCpo			:= 0
Local nPosEst		:= At(cFreteEst, SM0->M0_ESTCOB)
Local aCab			:= {}
Local aDUYOri		:= {}
Local lErroImpXml	:= .F.
Local lExpFilter  := GetMv("MV_TMSEFIL",,.T.)
Local cErroImp		:= ""
			
Private lMsErroAuto	:= .F.
PRIVATE lAutoErrNoFile := .T.

// Acerta rotinas selecionadas
validSel( @aRotSel, cPathArq, @aErro, lExport )
validSel( @aParSel, cPathArq, @aErro, lExport )

//------------------------------------------------------------
// Carga de Municipios
//------------------------------------------------------------
FisAtuCC2()

dbSelectArea('CC2')
If CC2->(LastRec()) < 5507
	AAdd(aErro, {	.T.	, STR0287 , STR0288 }) 	//"Falha ao Importar Municipios"//"A carga de Municipios não foi concluida com sucesso. Favor verificar"
EndIf

//------------------------------------------------------------
// Processamento de Rotinas
//------------------------------------------------------------
For nRot := 1  To Len(aRotSel) // 1 -> Carga de Municipios
	
                                    
	//------------------------------------------------------------
	// Processamento de tabelas SX5, se houver
	//------------------------------------------------------------
	if !Len(aRotSel[nRot,OPC_SX5]) == 0
	
		// Adiciona o processamento no SX5
		IF aScan( aRotSel ,{|x|  x[2] == "WIZSX5" }) == 0
			AAdd (aRotSel, {.T., "WIZSX5",	STR0289	 ,STR0290, "", "", { }, "SX5" ,, }) //"Tabelas SX5"//"Tabelas relacionadas"
		Endif
	
		For nAlias := 1 to Len(aRotSel[nRot,OPC_SX5])
			
			cTabX5 := aRotSel[nRot,OPC_SX5, nAlias]
			
			if lExport
				// Processa exportacao de tabela X5
				wizExpSX5( cTabX5, cPathArq, aErro , aRotSel )
			Else
				// Processa importacao de tabela X5
				wizImpSX5( cTabX5, cPathArq, aErro , aRotSel )
			EndIf
						
		Next nAlias
	
	EndIF
	

	If ! RTrim(aRotSel[nRot,OPC_NOME]) $ "WIZSX5|WIZSX6|AJULOC"
		
		cFile := cPathArq + aRotSel[nRot,OPC_NOME] + ".txt"
	
		if  lExport .Or. file( cFile ) .Or. ValType(aRotSel[nRot, OPC_ALIAS]) == "A" 

		
			If ValType(aRotSel[nRot, OPC_ALIAS]) == "C"
			
				// Cria obj do Mile
				oMile := FwMile():New()
			
				
				// Verifica se layout esta cadastrado na base, caso nao esteja importa
				getLayout(	iif( lExport, aRotSel[nRot, OPC_EXPORT], aRotSel[nRot, OPC_IMPORT]),;
										cPathLay , @lErroImpXml , @cErroImp )
										
				If lErroImpXml
					
					aRotSel[nRot,OPC_SELECT]	:= .F.
					aRotSel[nRot,OPC_ERRO]		:= STR0291 + iif( lExport, aRotSel[nRot, OPC_EXPORT], aRotSel[nRot, OPC_IMPORT]) + " : " + cErroImp//"Erro ao importar o layout "
					aRotSel[nRot,OPC_SOLUCAO]	:= STR0292	//"Verifique o log detalhado através do módulo configurador. A rotina deve ser uma rotina em padrão MVC."
										
					AAdd(aErro, { .T., STR0293,STR0294 +  aRotSel[nRot,OPC_NOME] + cErroImp })	//"Erro Layout"//"Erro ao importar layout da Rotina "
					aRotSel[nRot, OPC_SELECT] 	:= .F.
					
				Endif						
													
				// Define Layout utilizado
				cLayout := iif( lExport, aRotSel[nRot, OPC_EXPORT], aRotSel[nRot, OPC_IMPORT])
				
				IF !lErroImpXml
	
					if !Empty(cLayout) 
						oMile:SetLayout( cLayout )
						
						oMile:SetOperation(iif(lExport, "2", "1"))
						
						If lExport
							//oMile:SetOperation("2")
							oMile:SetAlias( aRotSel[nRot,OPC_ALIAS] )
						EndIf			
						
						// Define o arquivo TXT utilizado		
						oMile:SetTXTFile( cFile )
						
						// --- ATENCAO ---
						// Por estar utilizando o MsgRun, o SetInterface deve ser configurado para .F.
						// Apos a correcao do Mile, o setInterface deve ser alterado para .T.
						oMile:SetInterface(.T.)	
						
						// Ativa componente do Mile
						If oMile:Activate()
						
							// Efetua operacao de Imp/Exp
							If lExport			
							
								// Executa filtro nas tabelas do TMS referente a tabela de frete
		
								If RTrim(aRotSel[nRot,OPC_NOME]) $ "TMSA010_17"							
									
									DbSelectArea("DT0")
									SET FILTER TO &("DT0_TABFRE == 'NTCL' .And. DT0_TIPTAB == '01' " )
		
								ElseIf RTrim(aRotSel[nRot,OPC_NOME]) $ "TMSA010_20"
		
									DbSelectArea("DT0")
									SET FILTER TO &("DT0_TABFRE == 'NTCF' .And. DT0_TIPTAB == '01' " )
								
								ElseIf RTrim(aRotSel[nRot,OPC_NOME]) $ "TMSA010_33"	
								
									DbSelectArea("DT0")
									SET FILTER TO &( "DT0_TABFRE == 'C001' .And. DT0_TIPTAB == '01' " )
									
								ElseIf !Empty(xFilial(aRotSel[nRot,OPC_ALIAS])) .And. lExpFilter
									DbSelectArea(aRotSel[nRot,OPC_ALIAS])
									If Left(aRotSel[nRot,OPC_ALIAS],1) == "S" 
										SET FILTER TO &( Substr(aRotSel[nRot,OPC_ALIAS],2,2)+"_FILIAL == '"+xFilial(aRotSel[nRot,OPC_ALIAS])+"' " )
									Else
										SET FILTER TO &( aRotSel[nRot,OPC_ALIAS]+"_FILIAL == '"+xFilial(aRotSel[nRot,OPC_ALIAS])+"' " )
									EndIf						
								EndIf						
							
								oMile:Export()
								
								IF RTrim(aRotSel[nRot,OPC_NOME]) $ "TMSA010_17|TMSA010_20|TMSA010_33"
									DbSelectArea("DT0")
									SET FILTER TO
								ElseIf !Empty(xFilial(aRotSel[nRot,OPC_ALIAS])) .And. lExpFilter
									DbSelectArea(aRotSel[nRot,OPC_ALIAS])
									SET FILTER TO
								Endif							
								
							Else			
								oMile:Import()
							EndIf
							
							// Em caso de inconsistencias no processamente, salva o erro
							If oMile:Error()

								aRotSel[nRot,OPC_SELECT]	:= .F.
								aRotSel[nRot,OPC_ERRO]		:= oMile:GetError()
								If Empty(aRotSel[nRot,OPC_SOLUCAO])
									aRotSel[nRot,OPC_SOLUCAO] := ""
								Else 
									aRotSel[nRot,OPC_SOLUCAO] += Chr(13)+Chr(10)
								EndIf
								aRotSel[nRot,OPC_SOLUCAO]	+= STR0295	//"Verifique o log detalhado do acelerador Mile através do módulo configurador"

								AAdd( aErro, {.T., STR0296, oMile:GetError() } )	//"Erro no processo"

							EndIf
							
							oMile:DeActivate()
						Else

							aRotSel[nRot,OPC_SELECT]	:= .F.
							aRotSel[nRot,OPC_ERRO]		:= STR0297 	//"Falha ao Ativar Mile."
							aRotSel[nRot,OPC_SOLUCAO]	:= STR0298	//"Verifique se o layout existe e se todos os campos estao compatíveis com a rotina."

							AAdd(aErro, { .T., STR0299, ;//"Falha ao Ativar Mile."
											 STR0300 +  aRotSel[nRot,OPC_NOME]})//" Rotina: "
						EndIf
						
					Else
									
						aRotSel[nRot,OPC_SELECT]	:= .F.
						aRotSel[nRot,OPC_ERRO]		:= STR0301 //"Layout não informado."
						aRotSel[nRot,OPC_SOLUCAO]	:= STR0302 + aRotSel[nRot,OPC_NOME] + STR0303	//" Rotina "//" não teve seu layout informado. Contato o administrador."

						AAdd(aErro, { .T., STR0304,; ////"Layout não informado."
										 STR0305 +  aRotSel[nRot,OPC_NOME] + STR0306})	//" Rotina "//" não teve seu layout informado. Contato o administrador."
										 
					EndIf
				
				Endif
			
			Else
				// Faz tratamento para importar/exportar via LeTxt			
				
				If lExport					
					 
					For nAlias := 1 to Len(aRotSel[nRot,OPC_ALIAS])
		
						cAlias := aRotSel[nRot,OPC_ALIAS, nAlias]
		
						// Gera arquivo txt de exportação
						nHand := FCreate( cPathArq + aRotSel[nRot,OPC_NOME] + "_" + cAlias + ".txt", 0)
		
						If nHand > 0
						
							
							dbSelectArea(cAlias)
							(cAlias)->(dbSetOrder(1))
							
							aStru :=  (cAlias)->(dbStruct())				
							
							For nCpo := 1 To Len(aStru)
							
								// Imprime cabeçalho com os campo
								FWRITE(nHand, iif(nCpo > 1, "|", "") + aStru[nCpo, DBS_NAME] ) 
								
							Next nCpo 			
							
							FWRITE( nHand, chr(13)  + chr(10) )
							
							// Imprime conteudo do arquivo de dados no arquivo TXT de exportacao
							While (cAlias)->(!Eof())
								
								For nCpo := 1 To Len(aStru)
																
									cTipo := valtype((cAlias)->( FieldGet( FieldPos( aStru[nCpo, DBS_NAME] ) ) ))
									xDado := (cAlias)->( FieldGet( FieldPos( aStru[nCpo, DBS_NAME] ) ) )
									
									if cTipo == "N" 
										cDado := cValToChar( xDado )
									Elseif cTipo == "D"
										cDado := DTOC( xDado ) 
									Elseif cTipo == "L"
										cDado := iif(xDado, "T", "F")
									Else
										cDado := xDado
									EndIf
									
									FWRITE(nHand, iif(nCpo > 1, "|", "") + cDado  )
									
								Next nCpo
								
								FWRITE( nHand, chr(13)  + chr(10) )
								
								(cAlias)->(dbSkip())
							End
							
							If !FCLOSE(nHand)
								
								// Salva erro ao fechar arquivo de exportacao
								AAdd(aErro, { .T., STR0307 + aRotSel[nRot,OPC_NOME] + "_" + cAlias +".txt",;//"Falha ao fechar arquivo de exportação: "
												STR(FERROR()) } )
							
							EndIf
		
						Else
							
							// Salva erro ao criar arquivo TXT
							AAdd(aErro, {	.T., STR0308 + aRotSel[nRot,OPC_NOME] + "_" + cAlias +".txt",; //"Falha ao criar arquivo de exportação: "
											STR(FERROR())})
												
						EndIf
							
					Next nAlias
								
				Else
					
					if !Len(aRotSel[nRot,OPC_ALIAS]) == 0
						For nAlias := 1 to Len(aRotSel[nRot,OPC_ALIAS])
						
										
							cAlias := aRotSel[nRot,OPC_ALIAS, nAlias]
							
							lImportou := LeTXT(cPathArq + aRotSel[nRot,OPC_NOME] + "_"+ cAlias + ".txt",{|cFile, cLinha, nLinha, nPercent| GravaLin(cFile, cLinha, nLinha, nPercent)})
							
							If !lImportou

								aRotSel[nRot,OPC_SELECT]	:= .F.
								aRotSel[nRot,OPC_ERRO]		:= STR0309 + " " + aRotSel[nRot,OPC_NOME] + "_" + cAlias + ".txt"//"Falha ao processar arquivo de importação: "
								If Empty(aRotSel[nRot,OPC_SOLUCAO])
									aRotSel[nRot,OPC_SOLUCAO] := ""
								Else
									aRotSel[nRot,OPC_SOLUCAO] += Chr(13)+Chr(10)
								EndIf
								aRotSel[nRot,OPC_SOLUCAO]	:= STR0310	//"Verifique formato do arquivo ou verifique se a base de dados esta vazia para realizar esta importação."
								
								AAdd(aErro, {	.T. , aRotSel[nRot,OPC_NOME] , STR0311 + aRotSel[nRot,OPC_NOME] + "_" + cAlias +".txt" } )//"Falha ao processar arquivo de importação: "

							EndIf
							
						Next nAlias
					
					Else
					
						aRotSel[nRot,OPC_SELECT]	:= .F.
						aRotSel[nRot,OPC_ERRO]		:= STR0312 + aRotSel[nRot,OPC_NOME] //"Alias não informado para a rotina: "
						aRotSel[nRot,OPC_SOLUCAO]	:= STR0313	//"Verifique formato/nome do arquivo"

						AAdd(aErro, {	.T., aRotSel[nRot,OPC_NOME] , STR0314 + aRotSel[nRot,OPC_NOME] })//"Alias não informado para a rotina: "
												
					EndIF
					
				EndIf
				
			EndIf
			
		elseif !file( cFile )
		
			AAdd(aErro, {	.T., STR0315,;		//"Arquivo não encotrado"
							STR0316 + aRotSel[nRot,OPC_NOME] + STR0317})		//"A rotina "//"não possui arquivo de importação."
			aRotSel[nRot, OPC_SELECT] := .F.	
			
		EndIf
	
	Endif

Next nRot


//------------------------------------------------------------
// Processamento de Parametros
//------------------------------------------------------------
If Len(aParSel) > 0

	IF aScan( aRotSel ,{|x|  x[2] == "WIZSX6" }) == 0
		AAdd (aRotSel, {.T., "WIZSX6",	STR0318	 ,STR0319, "", "", { }, "SX6" ,, }) //"Parametros"//"Descricao"
	Endif			

	if lExport
		
		nHand := FCreate(cPathArq + "TMSEFSX6.txt", 0)
		If nHand > 0
			
			// Varre os parametros selecionados
			For nRot := 1 To Len(aParSel)
			
				xDado := GetMV( aParSel[nRot, OPC_NOME],, Nil )
								
				cTipo := valtype(xDado)
				
				// Verifica se Parametro existe
				If cTipo <> "U"
				
					if cTipo == "N" 
						cDado := cValToChar( xDado )
					Elseif cTipo == "D"
						cDado := DTOC( xDado ) 
					Elseif cTipo == "L"
						cDado := iif(xDado, "T", "F")
					Else
						cDado := xDado
					EndIf
					
					// Imprime: "<PARAMETRO>|<DESCRICAO>|<VALOR>"
					FWRITE(nHand, aParSel[nRot, OPC_NOME] + "|" +;
									aParSel[nRot, OPC_DESCRI] + "|" +;
									cDado + ;
									chr(13)  + chr(10) )
				
				EndIf							
		
			Next nRot
			
			If !FCLOSE(nHand)
					
				aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
				aRotSel[Len(aRotSel),OPC_ERRO]		:= STR0320	//"Falha ao fechar arquivo de exportação: TMSEFSX6.txt"
				aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0321	//"Verifique se o arquivo está sendo usado por outro processo"

				// Salva erro ao fechar arquivo de exportacao
				AAdd(aErro, { .T. , STR0322 , STR0323 } )	//"Parametros"//"Falha ao fechar arquivo de exportação: TMSEFSX6.txt"
							 			
			EndIf
						
		Else
			
			aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
			aRotSel[Len(aRotSel),OPC_ERRO]		:= STR0324	//"Falha ao criar arquivo de exportação: TMSEFSX6.txt"
			aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0325	//"Verifique as permissões de usuário para gravação no diretório informado"

			// Salva erro ao criar arquivo TXT
			AAdd(aErro, { .T. , STR0326 , STR0327 } )	//"Parametros"//"Falha ao criar arquivo de exportação: TMSEFSX6.txt"
							
							
		EndIf
		
	Else
		
		// Abre arquivo de importação
		nHand := FT_FUse( cPathArq + "TMSEFSX6.txt" )
		If nHand > 0
		
			FT_FGoTop()					
						
			// Le todos os parametros do arquivo
			While !FT_FEOF() 
						
				cLinha  := FT_FReadLn()			
				aParam := StrToKArr(cLinha, "|")
											
				IF SX6->( DbSeek( Space(FWSizeFilial()) + aParam[PAR_PARAM] ) )
								
					// Atualiza valor do Parametro
					PutMV(aParam[PAR_PARAM], aParam[PAR_VALOR])
				
				Else
					
					aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
					aRotSel[Len(aRotSel),OPC_ERRO]		:= STR0328	//"Parametro não atualizado"
					aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0329	//"Somente serão atualizados os parametros compartilhados existentes na base de dados"

					AAdd(aErro, { .T., STR0330 , STR0331 + aParam[PAR_PARAM] + STR0332 } )	//"Parametros"//"Parametro "//" nao existente no dicionário"
				
				Endif
				
				FT_FSKIP()
	
			End
			
			If !FCLOSE(nHand)
					
				aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
				aRotSel[Len(aRotSel),OPC_ERRO]		:= STR0333	//"Falha ao fechar arquivo de importação: TMSEFSX6.txt"
				aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0334	//"Verifique as permissões de usuário para gravação no diretório informado"

				// Salva erro ao fechar arquivo de exportacao
				AAdd(aErro, { .T., STR0335 , STR0336 } )	//"Parametros"//"Falha ao fechar arquivo de importação: TMSEFSX6.txt"

			EndIf
											
		Else
					
			aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
			aRotSel[Len(aRotSel),OPC_ERRO]		:= STR0337	//"Falha ao abrir arquivo de importação: TMSEFSX6.txt"
			aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0338	//"Não foi possível abrir o arquivo. Verifique se o arquivo existe no diretório informado ou se o formato é um formato válido."
			
			// Salva erro ao criar arquivo TXT
			AAdd(aErro, {	.T., STR0339 , STR0340 })	//"Parametros"//"Falha ao abrir arquivo de importação: TMSEFSX6.txt"
								
		EndIf
		
	EndIf
	
EndIf


//------------------------------------------------------------
// Ajuste de Localização
//------------------------------------------------------------

If lAjusta .And. !lExport // So ajusta na importacao

	// Adiciona o processamento do ajuste de localizacao
	IF aScan( aRotSel ,{|x|  x[2] == "AJULOC" }) == 0
		AAdd (aRotSel, {.T., "AJULOC" ,	STR0341	 ,STR0342, "", "", { }, "SX5" ,, }) //"Ajuste de Localização"//"Descrição"
	Endif

	dbSelectArea('CC2')
	CC2->(dbSetOrder(1))	// Filial + Estado + municipo (codigo IBGE)
	
	// Posiciona tab de municipios de acordo com a filial logada
	If ( CC2->(dbSeek( cFilCC2 + SM0->( upper(M0_ESTCOB) + Substr(M0_CODMUN,3)) )) )
		
		dbSelectArea('DUY')		
		DUY->(dbSetOrder(6)) // Filial + Estado + Cd Municipio
		
		// Posiciona na Estrutura de Regioes
		If ( DUY->(dbSeek( cFilDUY + SM0->( upper(M0_ESTCOB) + Substr(M0_CODMUN,3)) )) )
			
			if nPosEst < 0
				cFreteEst += upper(SM0->M0_ESTCOB) + StrZero( nAliquota, 2 )
			Else
				cFreteEst := StrTran(cFreteEst, SubStr(cFreteEst, nPosEst, 4), upper(SM0->M0_ESTCOB) + StrZero( nAliquota, 2 ) )
			EndIf
			
			cRegSup := DUY->DUY_GRPSUP
			
			aDUYOri := DUY->(GetArea())
			DUY->(DbSetOrder(5)) //-- DUY_FILIAL+DUY_FILDES+DUY_CATGRP+DUY_GRPVEN
			lIncluiDUY := ! DUY->(MsSeek(cFilDUY + PadR(FWCodFil(),FWSizeFilial()) + StrZero(2,Len(DUY->DUY_CATGRP))))
			
			/*todo:DL: verificar se existe a filial no DUY. Como exemplo vc pode olhar uma filial incluida no DUY pela rotina do sistema */
			/*todo:DL: utilizar execauto (vide exemplo no tmsa120.prw) ou instanciar o model para */
						
			If lIncluiDUY
				Aadd(aCab,{"DUY_GRPVEN"	, "FIL" + Right(FWCodFil(),Len(DUY->DUY_GRPVEN)-3)	, nil})
			Else
				Aadd(aCab,{"DUY_GRPVEN"	, DUY->DUY_GRPVEN	, nil})
			EndIf
			Aadd(aCab,{"DUY_DESCRI"	, "FILIAL "+SM0->M0_FILIAL							, nil})
			If lIncluiDUY
				Aadd(aCab,{"DUY_GRPSUP"	, cRegSup											, nil})
			EndIf			
			Aadd(aCab,{"DUY_EST"	 	, upper(SM0->M0_ESTCOB)								, nil})
			Aadd(aCab,{"DUY_FILDES"	, SM0->M0_CODFIL										, nil})
			Aadd(aCab,{"DUY_CATREG"	, "1"													, nil})
			Aadd(aCab,{"DUY_CATGRP"	, "2"													, nil})
			Aadd(aCab,{"DUY_REGISE"	, "2"													, nil})
			Aadd(aCab,{"DUY_ALQISS"	, 0														, nil})
			Aadd(aCab,{"DUY_PORTMS"	, "2"													, nil})

			//-- Posiciona no arquivo de grupos de regioes pela filial de destino, se nao encontrar permite a inclusao
			DUY->(DbSetOrder(5))
			
			MsExecAuto({|x,y,z|Tmsa115(x,y,z)},aCab,iif(lIncluiDUY, 3, 4))
						
			If lMsErroAuto
				
				// Desbloqueia tabela em caso de erro
				If DUY->(IsLocked())
					DUY->(MsUnlock())
				EndIf
	
				nPosErro := 1
				aErrExecAuto := GetAutoGRLog()
				For nH := 1 To Len(aErrExecAuto)
					If STR0344 $ aErrExecAuto[nH]	//"< -- Invalido"
						nPosErro := nH
						Exit
					Endif				
				Next nX
				
				If Empty(aErrExecAuto)
					aAdd(aErrExecAuto,STR0345)	//"Erro ExecAuto - não detalhado"
				EndIf
				AAdd(aErro, {.T. , STR0346 , aErrExecAuto[nPosErro] })//"Ajuste de Localização"
																															
				aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
				aRotSel[Len(aRotSel),OPC_ERRO]		:= aErrExecAuto[nPosErro]
				aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0347	//"Verifique o conteúdo dos campos obrigatórios."
				
				Return .T.

			EndIf
			
			RestArea(aDUYOri)
			
			RecLock("DUY",.F.)
				DUY->DUY_GRPSUP := "FIL"+Right(FWCodFil(),Len(DUY->DUY_GRPVEN)-3)
			DUY->(MsUnlock())
			
		
			/*Todo:Localizar (reposicionar) a região que fora colocada no MV_CDRORI. 
			Alterar o campo DUY_GRPSUP com o código de região da Filial (mais acima ...DUY->DUY_GRPVEN := "FIL001" )*/

			cCliGen := GetMv('MV_CLIGEN',,"")
			
			IF !Empty(cCliGen) 
			
				dbSelectArea('SA1')
				SA1->(dbSetOrder(1))	// Filial + Cd CLiente + Loja
				
				
				If ( SA1->(dbSeek( cFilSA1 + cCliGen )) )
				
					RecLock("SA1", .F.)
						
						SA1->A1_CDRDES := GetMv('MV_CDRORI',,"")
						 
					SA1->(MsUnlock())
					
					IF Empty(SA1->A1_CDRDES)
					
						AAdd(aErro, { .T. , STR0348 ,;//"Ajuste de Localizacao"
												STR0349}) //"Por gentileza, cadastre uma região de origem válida. Verifique o parametro MV_CDRORI"

						aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
						aRotSel[Len(aRotSel),OPC_ERRO]		:= STR0350  //"Codigo da regiao de origem inválido."
						aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0351 //"Por gentileza, cadastre uma região de origem válida. Verifique o parametro MV_CDRORI"

					EndIf
					
				Else
				
					AAdd(aErro, {	.T., 	STR0352 ,;//"Cliente Generico não cadastrado"
											STR0353 })//"Por gentileza, cadastre um cliente generico. Verifique o parametro MV_CLIGEN"

					aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
					aRotSel[Len(aRotSel),OPC_ERRO]		:= STR0354 //"Cliente Generico não cadastrado"
					aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0355 //"Por gentileza, cadastre um cliente generico. Verifique o parametro MV_CLIGEN"

				EndIf

			Else
			
				AAdd(aErro, {	.T., 	STR0356 ,;//"Cliente Generico não cadastrado"
										STR0357 })	 //"Por gentileza, cadastre um cliente generico. Verifique o parametro MV_CLIGEN"

				aRotSel[Len(aRotSel),OPC_SELECT]	:= .F.
				aRotSel[Len(aRotSel),OPC_ERRO]		:= STR0358//"Cliente Generico não cadastrado"
				aRotSel[Len(aRotSel),OPC_SOLUCAO]	:= STR0359 //"Por gentileza, cadastre um cliente generico. Verifique o parametro MV_CLIGEN"

			EndIf
						
		EndIf
		
	EndIf
	
EndIf


Return .T.


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getLayout
	
@author wanderley.ramos
@since 07/10/2013
@version 1.0		

@param cRotina, caracter, nome da rotina que buscara o layout

@return cLayout, String com o Id do layout

@description
	
Rotina que retorna o layout referente à rotina informada

/*/
//--------------------------------------------------------------------------------------------------------
Static Function getLayout( cLayout, cPath , lErroImpXml , cErro )

Local cXML	:= ''

lErroImpXml := .F.

// rotina que abre a XXJ
If select("XXJ") > 0
	Fwopenxxj()
Endif

dbSelectArea('XXJ')
XXJ->(dbSetOrder(1)) // Codigo

if !XXJ->(dbSeek( cLayout ) ) // codigo do Layout

	importLayout( cPath, cLayout , @lErroImpXml , @cErro )	
	
EndIf

Return cXML

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getFolder
	
@author wanderley.ramos
@since 07/10/2013
@version 1.0		

@param oWizard, objeto, componente do wizard que servira de base para a tela

@return cPathArq, String com o folder selecionado

@description
	
Rotina para seleção do path onde ficam os arquivos de importação que carregarao a base de dados.

/*/
//--------------------------------------------------------------------------------------------------------

Static Function getFolder(oWizard, cPathArq, cPathLay, lExport)

Local oGetArq		:= nil
Local oBtnArq		:= nil
Local oGetLay		:= nil
Local oBtnLay		:= nil

oWizard:oMPanel[oWizard:nPanel]:FreeChildren()

@ 014, 006 SAY STR0360 SIZE 035, 017 OF oWizard:oMPanel[oWizard:nPanel] PIXEL//"Local Arquivos:"
@ 013, 054 MSGET oGetArq VAR cPathArq SIZE 150, 010 OF oWizard:oMPanel[oWizard:nPanel] PIXEL

@ 040, 006 SAY STR0361 SIZE 035, 017 OF oWizard:oMPanel[oWizard:nPanel] PIXEL //"Local Layouts:"
@ 040, 054 MSGET oGetLay VAR cPathLay SIZE 150, 010 OF oWizard:oMPanel[oWizard:nPanel] PIXEL

/*
@ 80,006 CheckBox oCheck Var lExport Size 035,010 Pixel Of oWizard:oMPanel[oWizard:nPanel] Prompt "Exporta ?" Pixel; // */
			
// Botao de Busca de Arquivos de dados
@ 013, 210  BUTTON oBtnArq Prompt STR0362	SIZE 30,10 PIXEL; ////"Procurar"
				ACTION ( cPathArq := cGetFile( "",STR0363,,,,GETF_RETDIRECTORY ), oGetArq:Refresh() ); //"Selecione Diretorio"
			OF oWizard:oMPanel[oWizard:nPanel]

// Botao de Busca de Layouts
@ 040, 210  BUTTON oBtnLay Prompt STR0364	SIZE 30,10 PIXEL; ////"Procurar"
				ACTION ( cPathLay := cGetFile( "",STR0365,,,,GETF_RETDIRECTORY ), oGetLay:Refresh() ); //"Selecione Diretorio"
			OF oWizard:oMPanel[oWizard:nPanel]

Return nil

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getType
	
@author wanderley.ramos
@since 21/10/2013
@version 1.0		

@param lPadrao, logico, indica se o tipo da instalação sera simples ou Avancada
@param oWizard, objeto, componente do wizard que servira de base para a tela

@return Nil, -

@description
	
Rotina para seleção do tipo de instalação. Podendo ser Simples, na qual todas as opçoes de rotinas
 de rotinas e parametros serao processadas ou Avançada, que permite ao usuario selecionar o que deve ser processado.
/*/
//--------------------------------------------------------------------------------------------------------

Static Function getType( lPadrao, oWizard)

Local ocheck1		:= nil
Local ocheck2		:= nil
Local lChAvanc		:= !lPadrao

oWizard:oMPanel[oWizard:nPanel]:FreeChildren()

@ 024, 020 SAY STR0366 SIZE 230, 017 OF oWizard:oMPanel[oWizard:nPanel] PIXEL //"Opção Padrão: Todas as rotinas e parametros serão processados."
@ 055, 020 SAY STR0367 SIZE 230, 017 OF oWizard:oMPanel[oWizard:nPanel] PIXEL //"Opção Avançada: Permite a escolha de quais rotinas e parametros serão processados."


@ 014,020 CheckBox oCheck1 Var lPadrao Size 035,010 Pixel Of oWizard:oMPanel[oWizard:nPanel] Prompt STR0368 Pixel; //"Padrão"
	On Change (	lchAvanc := !lPadrao,  oCheck2:Refresh() )
	 				
@ 045,020 CheckBox oCheck2 Var lChAvanc Size 035,010 Pixel Of oWizard:oMPanel[oWizard:nPanel] Prompt STR0369 Pixel; //"Avançada"
	On Change (	lPadrao := !lChAvanc,  oCheck1:Refresh() )
			
Return


//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} getAjusLoc
	
@author wanderley.ramos
@since 24/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static Function getAjusLoc( lAjusta, lPadrao, nAliquota, oWizard)

Local ocheck1		:= nil
Local oGet			:= nil

oWizard:oMPanel[oWizard:nPanel]:FreeChildren()

@ 014, 020 SAY STR0370+ GetMv("MV_FRETEST",,"") +"." SIZE 240, 050 OF oWizard:oMPanel[oWizard:nPanel] PIXEL ////"Serão alterados dados do cliente Generico e de parametros referentes à localização da Filial para os dados do estado:"

@ 037, 020 SAY STR0371 SIZE 130, 017 OF oWizard:oMPanel[oWizard:nPanel] PIXEL //"Aliquota interna de ICMS de cada estado:"//"Aliquota interna de ICMS do estado:"

@ 035, 134 MSGET oGet VAR nAliquota PICTURE "@E 99" SIZE 40,010 OF oWizard:oMPanel[oWizard:nPanel] PIXEL

@ 130,010 CheckBox oCheck1 Var lAjusta Size 105,010 Pixel Of oWizard:oMPanel[oWizard:nPanel] WHEN !lPadrao Prompt STR0372 Pixel; ////"Ajusta Localização"
	
Return     




//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} VldAjusLoc
	
@author Mauro Paladini
@since 26/12/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static Function VldAjusLoc( lAjusta , lPadrao , nAliquota, oWizard )
    
Local lRet	:= .T.
	
If lAjusta .And. nAliquota == 0
	MsgStop(STR0373)//"Não foi informado o valor da alíquota"
	lRet := .F.
Endif

Return lRet 

//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} wizConfirm
	
@author wanderley.ramos
@since 29/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static Function wizConfirm(oWizard)

oWizard:oMPanel[oWizard:nPanel]:FreeChildren()

@ 014, 020 SAY STR0421 +; // "Clicando em Avançar o assistente irá processar os arquivos de dados e efetuar a carga de informação."                                                                                                                                                                                                                                                                                                                                                                                                              
				STR0376 SIZE 240, 050 OF oWizard:oMPanel[oWizard:nPanel] PIXEL//" Confirme seus dados, após este passo não será possível retornar."

Return Nil

//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} wizSelOpc
	
@author wanderley.ramos
@since 07/10/2013
@version 1.0
		
@param oWizard, objeto, componente do wizard que servira de base para a tela
@param aRotSel, array, array que sera preenchido com as rotinas selecionadas

@return nil, nulo

@description

rotina que cria uma browse no wizard para listar todas as rotinas que o assistente pode 
 importar. Dando a opção ao usuario sobre quais tabelas deseja importar

/*/
//--------------------------------------------------------------------------------------------------------

Static Function wizSelOpc(oWizard, aOpcoes, aCabec, lRot)

Local oCheck		:= Nil
Local lInverte		:= .F.

Local aCols			:= {}
Local aHeader		:= {}
Local nCont			:= 1
Local nTop			:= 010
Local oGetBusca		:= Nil
Local cParBusca		:= Space(30)

Local nPosOpc		:= iif( lRot, ROT_COL_SEL, PAR_COL_SEL ) 
Local nPosNome		:= iif( lRot, ROT_COL_NOME, PAR_COL_NOME )
Local nPosDescri	:= iif( lRot, ROT_COL_DESC, PAR_COL_DESC )

oWizard:oMPanel[oWizard:nPanel]:FreeChildren()

// Definindo aHeader utilizado com base nos campos informados
aHeader := montaHeader( oWizard:nPanel, aCabec )

// Monta aCols
for nCont := 1 To Len(aOpcoes)
	
	aadd(aCols, Array( Len(aHeader)+1 ))
	aCols[len(aCols), len(aHeader)+1 ] := .F.
	
	aCols[len(aCols), 1] := iif(aOpcoes[len(aCols), nPosOpc], "LBOK", "LBNO" )		
	aCols[len(aCols), 2] := aOpcoes[len(aCols), nPosNome]	// De acordo com o array pega a posicao correta
	if !lRot
		aCols[len(aCols), 3] := aOpcoes[len(aCols), nPosDescri]	// De acordo com o array pega a posicao correta // Retirada Descrição das rotinas por falta de definição.
	EndIf
	
Next ncont

If oWizard:nPanel == 5

	nTop := 020

	@ 007, 010 SAY STR0377 SIZE 080, 017 OF oWizard:oMPanel[oWizard:nPanel] PIXEL //"Parâmetro:"
	@ 006, 045 MSGET oGetBusca VAR cParBusca PICTURE "@!" SIZE 080,010 OF oWizard:oMPanel[oWizard:nPanel] PIXEL

	@ 007, 140 	BUTTON oBtnPesq PROMPT STR0378 SIZE 040,10 PIXEL ;//"Pesquisar"
				ACTION ( Pesquisa(cParBusca,@oWizard,aCols,@oGetDados) , oGetdados:oBrowse:Refresh() ) ;
				OF oWizard:oMPanel[oWizard:nPanel]

Else
	nTop := 010
Endif


oGetDados := MsNewGetDados():New( nTop ,010,(oWizard:oDlg:nRight/6)-33,(oWizard:oDlg:nWidth/2)-10,0,,,,{},,,,,,oWizard:oMPanel[oWizard:nPanel],aHeader,aCols)

oGetDados:oBrowse:bLDblClick  := {|| Iif(	oGetDados:aCols[oGetDados:nAt,1]=="LBNO",;
											(oGetDados:aCols[oGetDados:nAt,1]:="LBOK" , aOpcoes[oGetDados:nAt,1] := .T.),; 		// Caso verdadeiro
										    (oGetDados:aCols[oGetDados:nAt,1]:="LBNO" , aOpcoes[oGetDados:nAt,1] := .F.);	  	// Caso falso
										       ), oGetDados:oBrowse:Refresh()}
										     
@ 130,010 CheckBox oCheck Var lInverte Size 055,010 Pixel Of oWizard:oMPanel[oWizard:nPanel] Prompt STR0379; ////"Marca/Desmarcar Todos"
	 On Change (	Iif(lInverte,(	AEval(aOpcoes,{|x| x[1] := .T.}), AEval(oGetDados:aCols,{|x| x[1] := "LBOK"}) ),;
	 							   (	AEval(aOpcoes,{|x| x[1] := .F.}), AEval(oGetDados:aCols,{|x| x[1] := "LBNO"}) )),;
	 				oGetDados:Refresh() ) Pixel

Return !empty(aOpcoes)



//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} Pesquisa
	
@author Mauro Paladini 
@since 07/10/2013
@version 1.0		
Faz a pesquisa de parametros                                          

/*/
//--------------------------------------------------------------------------------------------------------
Static Function Pesquisa(cParBusca,oWizard,aCols,oGetDados)

Local nPosAux := 0

nPosAux := aScan( aCols ,{|x|  AllTrim(cParBusca) $ x[2] })
	
If nPosAux > 0
	oGetDados:GoTo(nPosAux)
	oGetdados:Refresh()
	oGetDados:oBrowse:SetFocus()
Endif

Return 



//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} validRotSel
	
@author wanderley.ramos
@since 07/10/2013
@version 1.0
		
@param aRotSel, array, array que preenchido com as rotinas
@return cPathArq, String com o folder dos arquivos de input

@return lRet, Indica se a rotina esta ok.

@description

Le rotinas informadas e veriica se os arquivos texto estao de acordo.

/*/
//--------------------------------------------------------------------------------------------------------

static function validSel( aSel, cPathArq, aErro, lExport )

Local nRot				:= 0
Local aSelect			:= {}

// Somente rotinas selecionadas
aEval(aSel, {|| nRot++, iif(aSel[nRot,OPC_SELECT], AAdd(aSelect, aSel[nRot]), Nil)})

aSel := aSelect

Return .T.//!Empty(aRotSel)


//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} wizStaProc
	
@author wanderley.ramos
@since 11/10/2013
@version 1.0
		

@description

Rotina que exibe o status do processamento, informando as rotinas importadas e os erros de processamento 
/*/
//--------------------------------------------------------------------------------------------------------

static function wizStaProc(oWizard, aRotSel, aParSel, aCabRot, aCabPar, cRotErr, aErro, aCabErr )

Local aColsRot		:= {}
Local aColsPar		:= {}
Local aColsErr		:= {}

Local aHeadRot		:= {}
Local aHeadPar		:= {}
Local aHeadErr		:= {}

Local oGetRot		:= Nil
Local oGetPar		:= Nil
Local oGetErr		:= Nil

Local aAuxRot		:= {}
Local nRot			:= 0
Local nTotSucesso 	:= 0
Local nTotFalha		:= 0

Local nParSucesso	:= 0
Local nParFalha		:= 0
Local lExport		:= SuperGetMv('MV_TMSEFIX',,.F.)//.F.

AEval(aRotSel, {|| nRot++, AAdd(aAuxRot, { aRotSel[nRot,OPC_SELECT] , aRotSel[nRot,OPC_DESCRI] , aRotSel[nRot,OPC_ERRO] , aRotSel[nRot,OPC_SOLUCAO], Iif( lExport, aRotSel[nRot, OPC_EXPORT], aRotSel[nRot, OPC_IMPORT]) } )} )

// Montando os aHeaders
aHeadRot := montaHeader( oWizard:nPanel, aCabRot, 1 )
aHeadPar := montaHeader( oWizard:nPanel, aCabPar, 2 )
aHeadErr := montaHeader( oWizard:nPanel, aCabErr, 3 )

// Montando os aCols
aColsRot := montaACols( aHeadRot, aAuxRot,	"BR_VERDE", "BR_VERMELHO")
aColsPar := montaACols( aHeadPar, aParSel,	"BR_VERDE", "BR_VERMELHO")
aColsErr := montaACols( aHeadErr, aErro,	"BR_VERMELHO")

oFolder := TFolder():New(10,10,{STR0380,STR0381,STR0382},,oWizard:oMPanel[oWizard:nPanel],,,,.T.,.F.,(oWizard:oMPanel[oWizard:nPanel]:nClientWidth/2)-20, (oWizard:oMPanel[oWizard:nPanel]:nClientHeight/2)-30)//"Rotinas"//"Parâmetros"//"Alertas"


// Totaliza total de rotinas com sucesso e falha
aEval(aColsRot, {|x|  nTotSucesso 	+= If( x[1] == "BR_VERDE" , 1 , 0 ) })
aEval(aColsRot, {|x|  nTotFalha 	+= If( x[1] == "BR_VERMELHO" , 1 , 0 ) })

oGetRot := MsNewGetDados():New(001,001,oFolder:aDialogs[1]:nClientHeight/2-11,oFolder:aDialogs[1]:nClientWidth/2-10,0,,,,{},,,,,,oFolder:aDialogs[1],aHeadRot,aColsRot)
oGetRot:oBrowse:bLDblClick := {|| VerDetalhe( aAuxRot[oGetRot:nAt,3] , aAuxRot[oGetRot:nAt,4], aAuxRot[oGetRot:nAt,5] )}
oGetRot:nAt := 1
oGetRot:oBrowse:nAt := 1
oGetRot:oBrowse:nRowPos := 1
oGetRot:oBrowse:Refresh(.T.)
oGetRot:oBrowse:cToolTip := STR0383//"Faça duplo click na rotina para ver detalhes"

oBmpRotSuc := TBitmap():New ( oFolder:aDialogs[1]:nClientHeight/2-9, 015, 10, 10, "BR_VERDE",,.T., oFolder:aDialogs[1],,,,,,,,,.T.)
@ oFolder:aDialogs[1]:nClientHeight/2-9, 025 SAY cValToChar(nTotSucesso) + "  " +  STR0384 SIZE 038, 020 OF oFolder:aDialogs[1] PIXEL//"c/ Sucesso"

oBmpRotFal := TBitmap():New ( oFolder:aDialogs[1]:nClientHeight/2-9, 080,10, 10, "BR_VERMELHO",,.T., oFolder:aDialogs[1],,,,,,,,,.T.)
@ oFolder:aDialogs[1]:nClientHeight/2-9, 090 SAY cValToChar(nTotFalha) + "   " + STR0385 + " - " + STR0386 SIZE 180, 020 OF oFolder:aDialogs[1] PIXEL//"c/ Falha"//"Clique sobre Rotina para maiores detalhes"


// Totaliza total de parametros com sucesso e falha
aEval(aColsPar, {|x|  nParSucesso 	+= If( x[1] == "BR_VERDE" , 1 , 0 ) })
aEval(aColsPar, {|x|  nParFalha 	+= If( x[1] == "BR_VERMELHO" , 1 , 0 ) })

oGetPar := MsNewGetDados():New(001,001,oFolder:aDialogs[2]:nClientHeight/2-11,oFolder:aDialogs[2]:nClientWidth/2-10,0,,,,{},,,,,,oFolder:aDialogs[2],aHeadPar,aColsPar)
oGetPar:nAt := 1
oGetPar:oBrowse:nAt := 1
oGetPar:oBrowse:nRowPos := 1
oGetPar:oBrowse:Refresh(.T.)

oBmpParSuc := TBitmap():New ( oFolder:aDialogs[2]:nClientHeight/2-9, 015, 10, 10, "BR_VERDE",,.T., oFolder:aDialogs[2],,,,,,,,,.T.)
@ oFolder:aDialogs[2]:nClientHeight/2-9, 025 SAY cValToChar(nParSucesso) + "  " + STR0387 SIZE 035, 020 OF oFolder:aDialogs[2] PIXEL//"Sucesso"

oBmpParFal := TBitmap():New ( oFolder:aDialogs[2]:nClientHeight/2-9, 080, 10, 10, "BR_VERMELHO",,.T., oFolder:aDialogs[2],,,,,,,,,.T.)
@ oFolder:aDialogs[2]:nClientHeight/2-9, 090 SAY cValToChar(nParFalha) + "  " + STR0388 SIZE 035, 080 OF oFolder:aDialogs[2] PIXEL//"Falha"

// Resumo das alertas

oGetErr := MsNewGetDados():New(001,001,oFolder:aDialogs[3]:nClientHeight/2-1,oFolder:aDialogs[3]:nClientWidth/2-1,0,,,,{},,,,,,oFolder:aDialogs[3],aHeadErr,aColsErr)
oGetErr:nAt := 1
oGetErr:oBrowse:nAt := 1
oGetErr:oBrowse:nRowPos := 1
oGetErr:oBrowse:Refresh(.T.)

Return nil

//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} montaHeader
	
@author wanderley.ramos
@since 11/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static function montaHeader( nPanel, aCab, nFolder)

Local nCol 		:= 1
Local aHeader		:= {}
Local nTam			:= 0

Default nFolder 	:= 0

// Primeira Coluna eh para figura
aAdd(aHeader, {	aCab[nCol]							,; // 01 - Titulo
                  "CPO"+cValToChar(nCol)			,; // 02 - Campo	
                  "@BMP"							,; // 03 - Picture
                  3									,; // 04 - Tamanho
                  0									,; // 05 - Decimal
                  "allwaystrue()"					,; // 06 - Valid
                  ""								,; // 07 - Usado
                  "C"								,; // 08 - Tipo
                  ""								,; // 09 - F3
                  "R"								,; // 10 - Contexto
                  ''								,; // 11 - ComboBox
                  ''								,; // 12 - 
                  ''								,; // 13 - When 
                  'A'							 	; // 14 - Visualizar
                  })

// Dasegunda em diante preenche com os dados do cabecalho
For nCol := 2 to Len(aCab)
	//------------------------------------------------------------
	// Definindo tamanho da coluna
	//------------------------------------------------------------
	if nPanel == PANEL_ROTINAS
		nTam := 35
	ElseIf nPanel == PANEL_PARAMET
		if ncol == 2 // Titulo
			nTam := 15
		Else // Descricao
			nTam := 70
		EndIf
	Else
		if nFolder == PANEL_STAT_ROT
		
			nTam := 35
			
		ElseIf nFolder == PANEL_STAT_PAR
		
			if ncol == 2 // Titulo
				nTam := 15
			Else // Descricao
				nTam := 40
			EndIf
		
		Else
		
			if ncol == 2 // Titulo
				nTam := 20
			Else // Descricao
				nTam := 40
			EndIf
				
		EndIf
	EndIf 
	
	aAdd(aHeader, {	aCab[nCol]				,; // 01 - Titulo
                  "CPO"+cValToChar(nCol)	,; // 02 - Campo	
                  ""						,; // 03 - Picture
                  nTam						,; // 04 - Tamanho
                  0							,; // 05 - Decimal
                  "allwaystrue()"			,; // 06 - Valid
                  ""						,; // 07 - Usado
                  "C"						,; // 08 - Tipo
                  ""						,; // 09 - F3
                  "R"						,; // 10 - Contexto
                  ''						,; // 11 - ComboBox
                  ''						,; // 12 - 
                  ''						,; // 13 - When 
                  'A'						; // 14 - Visualizar
                  })
Next nCol
	
Return aHeader

//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} montaAcols
	
@author wanderley.ramos
@since 11/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static function montaACols( aHeader, aOpcoes, cFig1, cFig2)

Local nCont	:= 1
Local nCol		:= 1
Local aCols	:= {}

default cFig2 := ""

for nCont := 1 To Len(aOpcoes)
	
	aadd(aCols, Array( Len(aHeader)+1 ))
	aCols[len(aCols), len(aHeader)+1 ] := .F.
	
	aCols[len(aCols), 1] :=  AllTrim( iif(aOpcoes[nCont, 1], cFig1, cFig2 ) )
	
	for nCol := 2 to Len(aHeader)		
		
		aCols[len(aCols), ncol] := AllTrim(aOpcoes[nCont, ncol])
		
	next nCol
	
Next ncont

Return aCols


//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} wizImpSX5
	
@author wanderley.ramos
@since 23/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static function wizImpSX5( cTabX5, cPathArq, aErro , aRotSel )

local cFile		:= cPathArq + "TMSEFSX5" + cTabX5 + ".txt"
Local cLinha	:= ""
Local aLinha	:= {}
Local nHand		:= 0    
Local nPosRot 	:= aScan( aRotSel ,{|x|  x[2] == "WIZSX5" })

If File(cFile)

	nHand := FT_FUse( cFile ) 
	
	If nHand > 0
	
		//-- Realiza a leitura da primeira linha como cabeçalho
		FT_FGoTop()
		
		cLinha := FT_FReadLn() // Retorna a linha corrente
								
		aLinha := StrToKArr(cLinha, "|")
		FT_FSKIP()
	 		 	
	 	If Len(FWGetSX5 ("00", cTabX5)) == 0
 		 	FwPutSX5("", "00", cTabX5, aLinha[LIN_X5_DESTAB])
	 	EndIf
	 	
		While !FT_FEOF() 
			
			cLinha := FT_FReadLn() // Retorna a linha corrente
									
			aLinha := StrToKArr(cLinha, "|")
			
			// Verifica qtd de colunas no arquivo
			if Len(aLinha) == 3
		 	
			 	// Verifica existencia dos registros
			 	If Len(FWGetSX5 (cTabX5, aLinha[LIN_X5_CHAVE])) == 0
			 		FwPutSX5("", cTabX5, aLinha[LIN_X5_CHAVE], aLinha[LIN_X5_DESCRI])
 		 		EndIf

			ELse

				If nPosRot > 0
					aRotSel[nPosRot,OPC_SELECT]		:= .F.
					aRotSel[nPosRot,OPC_ERRO] 		:= STR0389//"Dados inconsistentes em arquivo"
					aRotSel[nPosRot,OPC_SOLUCAO]	:= STR0390 + cFile + STR0391//"Arquivo  "//" contem colunas inválidas. Favor verificar."
				Endif

				// Salva erro ao criar arquivo TXT
				AAdd(aErro, {	.T., STR0392,; ////"Dados inconsistentes em arquivo"
								STR0393 + cFile + STR0394})//"Arquivo  "//" contem colunas inválidas. Favor verificar."
			EndIf
			
			FT_FSKIP()
			
		End
		
	else
		
		If nPosRot > 0
			aRotSel[nPosRot,OPC_SELECT]		:= .F.
			aRotSel[nPosRot,OPC_ERRO] 		:= STR0395 + cFile//"Falha ao abrir arquivo de importação: "
			aRotSel[nPosRot,OPC_SOLUCAO]	:= STR0396				//"Não foi possível abrir o arquivo. Verifique se o arquivo existe no diretório informado ou se o formato é um formato válido."
		Endif

		// Salva erro ao criar arquivo TXT
		AAdd(aErro, {	.T., STR0397 + cFile ,	STR(FERROR()) })//"Falha ao abrir arquivo de importação: "
						
	endIf
	
Else

	If nPosRot > 0
		aRotSel[nPosRot,OPC_SELECT]		:= .F.
		aRotSel[nPosRot,OPC_ERRO] 		:= STR0398 + cFile//"Falha ao abrir arquivo de importação: "
		aRotSel[nPosRot,OPC_SOLUCAO]	:= STR0399				//"Verifique se o arquivo existe no diretório informado"
	Endif

	AAdd(aErro, { .T., STR0400, STR0401 + cFile + STR0402 } ) //"Arquivo de dados invalido."//"Arquivo "//" invalido. "

EndIf

Return Nil


//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} wizExpSX5
	
@author wanderley.ramos
@since 23/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static Function wizExpSX5( cTabX5, cPathArq, aErro , aRotSel)

local cFile		:= cPathArq + "TMSEFSX5" + cTabX5 + ".txt"
Local nHand		:= 0
Local cFilSX5	:= xFilial('SX5')
Local nPosRot 	:= aScan( aRotSel ,{|x|  x[2] == "WIZSX5" })
Local cTab		:= ''
Local aSX5		:= {}
Local nI 		:= 0

nHand := FCreate(cFile, 0)

If nHand > 0
	
	cTab := Tabela("00", cTabX5, .F.)
	If !Empty(cTab) 
	
		// Imprime cabeçalho com Descricao da Tabela
		FWRITE(nHand, cFilSX5 +"|"+ cTab) 
		FWRITE( nHand, chr(13)  + chr(10) )
		
		// Imprime registros da tabela no arquivo TXT de exportacao
		aSX5 := FwGetSX5(cTabX5)
		For nI := 1 to Len(aSX5)
			FWRITE(nHand, cFilSX5 + "|" + aSX5[nI][3] + "|" + aSX5[nI][4])
			FWRITE( nHand, chr(13)  + chr(10) )
		Next
		
		If !FCLOSE(nHand)

			If nPosRot > 0
				aRotSel[nPosRot,OPC_SELECT]		:= .F.
				aRotSel[nPosRot,OPC_ERRO] 		:= STR0403 + cFile//"Falha ao fechar arquivo de exportação: "
				aRotSel[nPosRot,OPC_SOLUCAO]	:= STR0404				//"Verifique se o arquivo está bloqueado por outro processo"
			Endif

			// Salva erro ao fechar arquivo de exportacao
			AAdd(aErro, { .T., STR0405 + cFile,;//"Falha ao fechar arquivo de exportação: "
							STR(FERROR()) } )
		
		EndIf
		
	Else
			
		If nPosRot > 0
			aRotSel[nPosRot,OPC_SELECT]		:= .F.
			aRotSel[nPosRot,OPC_ERRO]		:= STR0406 + cTabX5 + STR0407//"Tabela SX5 - "//" não está disponivel para exportação."
			aRotSel[nPosRot,OPC_SOLUCAO]	:= STR0408			//"Verifique através do modulo configurador se a tabela existe para a exportação"
		Endif

		// Salva erro ao fechar arquivo de exportacao
		AAdd(aErro, { .T., STR0409,; ////"Tabela não disponivel para exportação"
						STR0410 + cTabX5+STR0411 } )//"Tabela SX5 - "//" não está disponivel para exportação."
							
	EndIf

Else
	
	If nPosRot > 0
		aRotSel[nPosRot,OPC_SELECT] 	:= .F.
		aRotSel[nPosRot,OPC_ERRO]		:= STR0412 + cFile//"Falha ao criar arquivo de exportação: "
		aRotSel[nPosRot,OPC_SOLUCAO]	:= STR0413//"Verifique as permissões de usuário para gravação no diretório informado"
	Endif

	// Salva erro ao criar arquivo TXT
	AAdd(aErro, {	.T., STR0414 + cFile, STR(FERROR())})//"Falha ao criar arquivo de exportação: "
						
EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} importLayout
	
@author Daniel.leme
@since 11/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ImportLayout( cPath, cFile , lErroImpXml , cErro )

Local cXml := FwMemoRead( cPath + cFile +  ".xml")
Local oMdl:= FwLoadModel("CFGA601")
Local bError

cErro := ""

If !Empty(cXml)

	bError := ErrorBlock( {|| lErroImpXml := .T., cErro := STR0415, TMZE010Err() } ) ////"Erro Mile na importação do Layout"
	Begin Sequence

		oMdl:SetOperationMode(3)
		oMdl:Activate()
		
		If !oMdl:LoadXMlData(cXml)
			lErroImpXml := .T.
			cErro 		:= oMdl:GetErrorMessage()[6]+"/"+oMdl:GetErrorMessage()[7]
		Else
		
			If oMdl:VldData()
				oMdl:CommitData()
			Else
				lErroImpXml := .T.
				cErro := oMdl:GetErrorMessage()[6]+"/"+oMdl:GetErrorMessage()[7]
			EndIf
		
		EndIf
	
		oMdl:DeActivate()
	End Sequence
	ErrorBlock(bError)
	
EndIf

Return cXml
//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} LeTXT
	
@author Daniel.leme
@since 11/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static Function LeTXT(cFile, bBlock)

Local nBuf	   := 16 * 1024  // 16K
Local nHdl	   := fOpen(cFile, 0)
Local nTam	   := fSeek(nHdl, 0, 2)
Local nLin	   := 0
Local nLido    := 0
Local nPos     := Nil
Local cBuffer  := ""
Local lLeuTudo := .F.
Local cLinha   := ""
Local nPercent := 0
Local lImportou := .T.
Local lProc 		:= .F.

fSeek(nHdl, 0)
While lImportou .And. nLido < nTam
	lProc := .T.
	If Len(cBuffer) < nBuf .And. ! lLeuTudo
		cBuffer  += fReadStr(nHdl, nBuf)
		lLeuTudo := fSeek(nHdl, 0, 1) = nTam
	Endif
	nPos     := At(Chr(13) + Chr(10), cBuffer)
	cLinha   := Substr(cBuffer, 1, nPos - 1)
	nLin     ++
	nLido    += Len(cLinha) + 2 // Assumo Chr(13)+Chr(10) no final da linha
	nPercent := Min(80, (nLido * 100 / nTam) + 1) + 20
	lImportou := Eval(bBlock, cFile, cLinha, nLin, nPercent)
	cBuffer := Substr(cBuffer, nPos + 2)
Enddo
fClose(nHdl)
Return(lImportou .And. lProc)

//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} GravaLin
	
@author Daniel.leme
@since 11/10/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------

Static Function GravaLin(cFile, cLinha, nLin, nPercent)
Local aLinha := {}
Local nCpo,cTipo


Static aCpos,aTpo

If nLin == 1
	aCpos := StrToKArr(cLinha, "|")
	aTpo := {}
	aEval(aCpos,{|cCpo| aAdd(aTpo, ValType( (cAlias)->&(cCpo) )) })
	
	lImportou := (cAlias)->(RecCount()) == 0
Else

	aLinha := StrToKArr(cLinha, "|")
	
	lImportou := .T.
	RecLock(cAlias, .T.)
	// Insere valor no campo correspondente
	For nCpo := 1 To Len(aLinha)
	
		// Reconverte o dado
		//cTipo := valtype((cAlias)->&( aCpos[nCpo] ))
		cTipo := aTpo[nCpo]
		if cTipo == "N" 
			aLinha[nCpo] := Val( aLinha[nCpo] )
		Elseif cTipo == "D"
			aLinha[nCpo] := CtoD(aLinha[nCpo])
		Elseif cTipo == "L"
			aLinha[nCpo] := iif(aLinha[nCpo]== "T", .T., .F.)
		EndIf

		If "_FILIAL" $ upper(FieldName(nCPo))
			aLinha[nCpo] := xFilial(cAlias)
		Endif

		// Grava o campo com o dado convertido
		FieldPut( FieldPos(aCpos[nCpo]), aLinha[nCpo] )
		 
	Next ncpo 
	
	(cAlias)->(MsUnlock())
	
EndIf

Return lImportou

//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} TMZE010Err
	
@author Daniel.leme
@since 18/12/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------
Static  Function TMZE010Err()
If InTransact()
	DisarmTransaction()
EndIf
Break

Return



//--------------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} VerDetalhe()
	
@author Mauro Paladini
@since 18/12/2013
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------

Static Function VerDetalhe( cMsgDet , cMsgSolucao, cLayout )

Local oDlgLeg							//Dialogo para mensagem 
Local oFntMsg							//varaivel que define o fonte a ser utilizado na mensagem 
Local oFntTit							//variavel que define o fonte do titulo da mensagem

// variaveis para o texto de detalhe
Local oMsgDet							//Objeto para mensagem detalhada
Local lTelaDetalhe :=.F.				//Variavel que identifica se possui descricao detalhada

Default cMsgDet		:= ''
Default cMsgSolucao	:= ''
Default cLayout       := ''

If Type("lAutoExec") == "U"
	lAutoExec := .F.
EndIf

If !lAutoExec	// Para ExecAuto nao deve apresentar mensagem

	// Sem detalhes para exibir em caso de sucesso
	If Empty(cMsgDet)
		Return
	Endif
	
	DEFINE MSDIALOG oDlgLeg TITLE STR0416 FROM 0,0 TO 130,600 PIXEL //"Detalhe da ocorrência"
	
		DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
		DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15
		
		@ 05,05 TO 45,300 PROMPT STR0417 PIXEL//"  Problema  "
		@ 13,07 SAY cMsgDet PIXEL SIZE 240,200 FONT oFntMsg
				
		@ 50,130 BUTTON "Ok" PIXEL ACTION oDlgLeg:End() //"Ok"
		@ 50,180 BUTTON STR0418 PIXEL ACTION CFGA600l(cLayout)//"Log"
		@ 50,230 BUTTON STR0419 PIXEL ACTION If(	!lTelaDetalhe,; //"Detalhes"//"Detalhe"
													(oDlgLeg:ReadClientCoors(.T.),oDlgLeg:Move(oDlgLeg:nTop,oDlgLeg:nLeft,oDlgLeg:nWidth,oDlgLeg:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
													(oDlgLeg:ReadClientCoors(.T.),oDlgLeg:Move(oDlgLeg:nTop,oDlgLeg:nLeft,oDlgLeg:nWidth,oDlgLeg:nHeight-165,,.T.),lTelaDetalhe:=.F.))
														
		@ 67,05 TO 140,300 PROMPT STR0420 PIXEL//'Possível Solução'
		@ 73,07 GET oMsgDet VAR cMsgSolucao FONT oFntMsg MEMO size 290,65  PIXEL READONLY
		
	ACTIVATE MSDIALOG oDlgLeg CENTERED

EndIf

Return (NIL)
