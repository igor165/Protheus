// ######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSCInternational - Contem a tradução do applet Java.
// ---------+-----------------------+-----------------------------------------------------
// Data     | Autor                 | Descricao
// ---------+-----------------------+-----------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli |
// 22.06.09 | 3510 Gilmar P. Santos | FNC 00000008745/2009
// ---------------------------------------------------------------------------------------

#include "BSCDefs.ch"
#include "BSCInter.ch"

function cBSCLanguage()
	Local cReturn
	Local cLang := FWRetIdiom()

	if cLang == "es"
		cReturn := "SPANISH"
	else
		if cLang == "en"
			cReturn := "ENGLISH"
		else
			cReturn := "PORTUGUESE"
		ENDIF
	ENDIF
return cReturn

function cBSCInternational()
	local cTexto := ""

cTexto += 'BIRequest_00001='+STR0001+CRLF/*//'N\u00E3o \u00E9 permitido utilizar um parametro com o nome COMANDO na requisi\u00E7\u00E3o para o servidor.'*/

cTexto += 'JBILayeredPane_00001='+STR0944+CRLF/*//'Estrat\u00E9gia:'*/

cTexto += 'JBIListPanel_00001='+STR0901+CRLF/*//'Novo'*/
cTexto += 'JBIListPanel_00002='+STR0902+CRLF/*//'Visualizar'*/
cTexto += 'JBIListPanel_00003='+STR0931+CRLF/*//'Atualizar'*/

cTexto += 'JBISelectionDialog_00001='+STR0005+CRLF/*//'Escolhidos:'*/
cTexto += 'JBISelectionDialog_00002='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'JBISelectionDialog_00003='+STR0144+CRLF/*//'Dispon\u00edveis:'*/

cTexto += 'JBISelectionPanel_00001='+STR0007+CRLF/*//'Remover'*/
cTexto += 'JBISelectionPanel_00002='+STR0008+CRLF/*//'Adicionar'*/

cTexto += 'JBIXMLTable_00001='+STR0009+CRLF/*//'Dados'*/
cTexto += 'JBIXMLTable_00002='+STR0010+CRLF/*//'Carregando...'*/

cTexto += 'BscFormController_00001='+STR0011+CRLF/*//'N\u00E3o existe um formul\u00E1rio do tipo\ '*/
cTexto += 'BscFormController_00002='+STR0012+CRLF/*//'Erro ao tentar selecionar um formul\u00E1rio do tipo\ '*/
cTexto += 'BscFormController_00003='+STR0011+CRLF/*//'N\u00E3o existe um formul\u00E1rio do tipo\ '*/
cTexto += 'BscFormController_00004='+STR0012+CRLF/*//'Erro ao tentar selecionar um formul\u00E1rio do tipo\ '*/
cTexto += 'BscFormController_00005='+STR0012+CRLF/*//'Erro ao tentar selecionar um formul\u00E1rio do tipo\ '*/

cTexto += 'BIHttpClient_00001='+STR0013+CRLF/*//'Erro na conex\u00E3o. Mensagem:\ '*/

cTexto += 'BscAvaliacaoFrame_00001='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscAvaliacaoFrame_00002='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscAvaliacaoFrame_00003='+STR0932+CRLF/*//'Avalia\u00e7\u00e3o'*/
cTexto += 'BscAvaliacaoFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscAvaliacaoFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscAvaliacaoFrame_00006='+STR0110+CRLF/*//'Titulo:'*/
cTexto += 'BscAvaliacaoFrame_00007='+STR0956+CRLF/*//'Data:'*/
cTexto += 'BscAvaliacaoFrame_00008='+STR0921+CRLF/*//'Responsável:'*/
cTexto += 'BscAvaliacaoFrame_00009='+STR0932+CRLF/*//'Avalia\u00e7\u00e3o:'*/
cTexto += 'BscAvaliacaoFrame_00010='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscAvaliacaoFrame_00011='+STR0975+CRLF/*//'Atenção. O usuário logado não está associado a uma pessoa no sistema. Não é possível incluir sem responsável.'*/

cTexto += 'BscCardCentralFrame_00001='+STR0015+CRLF/*//'Antes de criar o formul\u00E1rio.'*/
cTexto += 'BscCardCentralFrame_00002='+STR0016+CRLF/*//'Criou o formul\u00E1rio.'*/

cTexto += 'BscCardPainelFrame_00001='+STR0017+CRLF/*//'Posi\u00E7\u00E3o anterior:\ '*/

cTexto += 'BscCentralFrame_00001='+STR0018+CRLF/*//'Ferramenta'*/
cTexto += 'BscCentralFrame_00002='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscCentralFrame_00003='+STR0935+CRLF/*//'Data de Análise:'*/
cTexto += 'BscCentralFrame_00004='+STR0926+CRLF/*//'Analise:'*/

cTexto += 'BscDataSourceFrame_00001='+STR0946+CRLF/*//'Fonte de Dados'*/
cTexto += 'BscDataSourceFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscDataSourceFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscDataSourceFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscDataSourceFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscDataSourceFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscDataSourceFrame_00007='+STR0114+CRLF/*//'Importar'*/
cTexto += 'BscDataSourceFrame_00008='+STR0965+CRLF/*//'Fonte de Dados:'*/
cTexto += 'BscDataSourceFrame_00009='+STR0114+CRLF/*//'Importar'*/
cTexto += 'BscDataSourceFrame_00010='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscDataSourceFrame_00011='+STR0117+CRLF/*//'Classe:'*/
cTexto += 'BscDataSourceFrame_00012='+STR0118+CRLF/*//'Recriar hist\u00f3rico durante a importa\u00e7\u00e3o'*/
cTexto += 'BscDataSourceFrame_00013='+STR0119+CRLF/*//'Agendamento:'*/
cTexto += 'BscDataSourceFrame_00014='+STR0925+CRLF/*//'Ambiente:'*/
cTexto += 'BscDataSourceFrame_00015='+STR0121+CRLF/*//'Utilizar o seguinte ambiente do servidor Protheus'*/
cTexto += 'BscDataSourceFrame_00016='+STR0122+CRLF/*//'Utilizar a seguinte conex\u00e3o Top Connect'*/
cTexto += 'BscDataSourceFrame_00017='+STR0123+CRLF/*//'Testar conex\u00e3o'*/
cTexto += 'BscDataSourceFrame_00018='+STR0937+CRLF/*//'Declara\u00e7\u00f5es:'*/
cTexto += 'BscDataSourceFrame_00019='+STR0125+CRLF/*//'Testar sintaxe'*/
cTexto += 'BscDataSourceFrame_00020='+STR0937+CRLF/*//'Declara\u00e7\u00f5es'*/
cTexto += 'BscDataSourceFrame_00021='+STR0248+CRLF/*//'Fonte de Referência'*/
cTexto += 'BscDataSourceFrame_00022='+STR0406+CRLF/*//'Principal'*/
cTexto += 'BscDataSourceFrame_00023='+STR0934+CRLF/*//'Configurações'*/
cTexto += 'BscDataSourceFrame_00024='+STR0948+CRLF/*//'Indicador'*/
cTexto += 'BscDataSourceFrame_00025='+STR0956+CRLF/*//'Data:'*/
cTexto += 'BscDataSourceFrame_00026='+STR0982+CRLF/*//'Consultas'*/
cTexto += 'BscDataSourceFrame_00027='+STR0991+CRLF/*//'Dados do DW'*/
cTexto += 'BscDataSourceFrame_00028='+STR0989+CRLF/*//'Está fonte de dados não é valída. Informe todos os campos da pasta Dados DW.'*/
cTexto += 'BscDataSourceFrame_00029='+STR0990+CRLF/*//'Endereço do DW:'*/
cTexto += 'BscDataSourceFrame_00030='+STR1030+CRLF/*//'Tipo de Fonte:'*/
cTexto += 'BscDataSourceFrame_00031='+STR1031+CRLF/*//'Fonte de Resultado'*/
cTexto += 'BscDataSourceFrame_00032='+STR1032+CRLF/*//'Fonte de Metas'*/

cTexto += 'BscDocumentoFrame_00001='+STR0021+CRLF/*//'Documento'*/
cTexto += 'BscDocumentoFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscDocumentoFrame_00003='+STR0022+CRLF/*//'N\u00E3o foi poss\u00EDvel visualizar. Verifique se o link est\u00E1 correto e tente novamente.'*/
cTexto += 'BscDocumentoFrame_00004='+STR0023+CRLF/*//'Erro'*/
cTexto += 'BscDocumentoFrame_00005='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscDocumentoFrame_00006='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscDocumentoFrame_00007='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscDocumentoFrame_00008='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscDocumentoFrame_00009='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscDocumentoFrame_00010='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscDocumentoFrame_00011='+STR0292+CRLF/*//'Texto:'*/
cTexto += 'BscDocumentoFrame_00012='+STR0902+CRLF/*//'Visualizar'*/
cTexto += 'BscDocumentoFrame_00013='+STR0960+CRLF/*//'Link:'*/

cTexto += 'BscDrillFrame_00001='+STR0024+CRLF/*//'Efeito:'*/
cTexto += 'BscDrillFrame_00002='+STR0025+CRLF/*//'Causa:'*/
cTexto += 'BscDrillFrame_00003='+STR0127+CRLF/*//'Navega\u00e7\u00e3o em janelas separadas'*/
cTexto += 'BscDrillFrame_00004='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscDrillFrame_00005='+STR0147+CRLF/*//'Mapa Estratégico'*/
cTexto += 'BscDrillFrame_00006='+STR0941+CRLF/*//'Drill-Down'*/
cTexto += 'BscDrillFrame_00007='+STR0958+CRLF/*//'Dados de Análise:'*/
cTexto += 'BscDrillFrame_00008='+STR0926+CRLF/*//'Análise:'*/
cTexto += 'BscDrillFrame_00009='+STR0949+CRLF/*//'Indicadores'*/
cTexto += 'BscDrillFrame_00010='+STR0967+CRLF/*//'Indicador de Resultado'*/
cTexto += 'BscDrillFrame_00011='+STR0968+CRLF/*//'Indicador de Tendência'*/
cTexto += 'BscDrillFrame_00012='+STR0969+CRLF/*//'Exibir Indicador de Tendência'*/
cTexto += 'BscDrillFrame_00013='+STR0970+CRLF/*//'Indicadores de Tendência'*/
cTexto += 'BscDrillFrame_00014='+STR0921+CRLF/*//'Responsável:'*/
cTexto += 'BscDrillFrame_00015='+STR0971+CRLF/*//'Métrica de coleta:'*/
cTexto += 'BscDrillFrame_00016='+STR0353+CRLF/*//'Frequência:'*/
cTexto += 'BscDrillFrame_00017='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/

cTexto += 'BscEstrategiaFrame_00001='+STR0945+CRLF/*//'Estrat\u00e9gia'*/
cTexto += 'BscEstrategiaFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscEstrategiaFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscEstrategiaFrame_00004='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscEstrategiaFrame_00005='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscEstrategiaFrame_00006='+STR0944+CRLF/*//'Estrat\u00e9gia:'*/
cTexto += 'BscEstrategiaFrame_00007='+STR0128+CRLF/*//'Fim:'*/
cTexto += 'BscEstrategiaFrame_00008='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscEstrategiaFrame_00009='+STR0129+CRLF/*//'In\u00edcio:'*/
cTexto += 'BscEstrategiaFrame_00010='+STR0130+CRLF/*//'Perspectivas'*/
cTexto += 'BscEstrategiaFrame_00011='+STR0131+CRLF/*//'Ferramentas'*/
cTexto += 'BscEstrategiaFrame_00012='+STR0132+CRLF/*//'Pain\u00e9is'*/
cTexto += 'BscEstrategiaFrame_00013='+STR0133+CRLF/*//'Relat\u00f3rios'*/
cTexto += 'BscEstrategiaFrame_00014='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscEstrategiaFrame_00015='+STR0262+CRLF/*//'Graficos'*/
cTexto += 'BscEstrategiaFrame_00016='+STR0297+CRLF/*//'Atenção! Ao mudar o período da estratégia, as informações contidas na planilha de'*/
cTexto += 'BscEstrategiaFrame_00017='+STR0298+CRLF/*//'valores que estiverem fora do novo período serão apagadas. Confirma alteração?'*/
cTexto += 'BscEstrategiaFrame_00018='+STR0299+CRLF/*//'Confirmação'*/
cTexto += 'BscEstrategiaFrame_00019='+STR0385+CRLF/*//'Duplicador*/
cTexto += 'BscEstrategiaFrame_00020='+STR0386+CRLF/*//'Nome do plano estratégico desdobrado:*/
cTexto += 'BscEstrategiaFrame_00021='+STR0387+CRLF/*//'Organização destino:*/
cTexto += 'BscEstrategiaFrame_00022='+STR0955+CRLF/*//'Tipo de link:*/
cTexto += 'BscEstrategiaFrame_00023='+STR0389+CRLF/*//'Executar*/
cTexto += 'BscEstrategiaFrame_00024='+STR0390+CRLF/*//'Duplicar*/
cTexto += 'BscEstrategiaFrame_00025='+STR0391+CRLF/*//'Desdobrar / Criar link*/
cTexto += 'BscEstrategiaFrame_00026='+STR0939+CRLF/*//'Desdobramentos*/
cTexto += 'BscEstrategiaFrame_00027='+STR0576+CRLF/*//'Temas'*/
cTexto += 'BscEstrategiaFrame_00028='+STR0187+CRLF/*//'Período invalido!'*/
cTexto += 'BscEstrategiaFrame_00029='+STR1036+CRLF/*//'Este processo é executado em segundo plano e pode demorar alguns minutos.'*/

cTexto += 'BscIndicadorFrame_00001='+STR0959+CRLF/*//'Indicador'*/
cTexto += 'BscIndicadorFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscIndicadorFrame_00003='+STR0028+CRLF/*//'Aten\u00E7\u00E3o! Ao mudar a frequencia de avalia\u00E7\u00E3o de um indicador\ '*/
cTexto += 'BscIndicadorFrame_00004='+STR0029+CRLF/*//'sua planilha ser\u00E1 apagada e criada novamente. Confirma altera\u00E7\u00E3o?'*/
cTexto += 'BscIndicadorFrame_00005='+STR0030+CRLF/*//'Confirma\u00E7\u00E3o'*/
cTexto += 'BscIndicadorFrame_00006='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscIndicadorFrame_00007='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscIndicadorFrame_00008='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscIndicadorFrame_00009='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscIndicadorFrame_00010='+STR0948+CRLF/*//'Indicador:'*/
cTexto += 'BscIndicadorFrame_00011='+STR0135+CRLF/*//'Unidade:'*/
cTexto += 'BscIndicadorFrame_00012='+STR0136+CRLF/*//'Decimais:'*/
cTexto += 'BscIndicadorFrame_00013='+STR0921+CRLF/*//'Respons\u00e1vel:'*/
cTexto += 'BscIndicadorFrame_00014='+STR0137+CRLF// 'Frequência:'*/
cTexto += 'BscIndicadorFrame_00015='+STR0138+CRLF/*//'Ascendente'*/
cTexto += 'BscIndicadorFrame_00016='+STR0139+CRLF/*//'Descendente'*/
cTexto += 'BscIndicadorFrame_00017='+STR0116+CRLF/*//'Descri\u00E7\u00E3o:'*/
cTexto += 'BscIndicadorFrame_00018='+STR0140+CRLF/*//'Avalia\u00e7\u00f5es'*/
cTexto += 'BscIndicadorFrame_00019='+STR0141+CRLF/*//'Metas'*/
cTexto += 'BscIndicadorFrame_00020='+STR0142+CRLF/*//'Planilhas de Valores'*/
cTexto += 'BscIndicadorFrame_00021='+STR0966+CRLF/*//'Fontes de Dados'*/
cTexto += 'BscIndicadorFrame_00022='+STR0243+CRLF/*//'Coleta'*/
cTexto += 'BscIndicadorFrame_00023='+STR0244+CRLF//'Descrição da Métrica:'*/
cTexto += 'BscIndicadorFrame_00024='+STR0245+CRLF/*//'Forma de Coleta:'*/
cTexto += 'BscIndicadorFrame_00025='+STR0963+CRLF// 'Referência'*/
cTexto += 'BscIndicadorFrame_00026='+STR0247+CRLF// 'Referência:'*/
cTexto += 'BscIndicadorFrame_00027='+STR0249+CRLF/*//'Atenção! Ao mudar a frequencia de avaliação de um indicador de referencia\ '*/
cTexto += 'BscIndicadorFrame_00028='+STR0250+CRLF/*//'sua planilha será apagada e criada novamente. Confirma alteração?'*/
cTexto += 'BscIndicadorFrame_00029='+STR0402+CRLF/*//'Cumulativo'*/
cTexto += 'BscIndicadorFrame_00030='+STR0403+CRLF/*//'Orientação'*/
cTexto += 'BscIndicadorFrame_00031='+STR0940+CRLF/*//'Documentos'*/
cTexto += 'BscIndicadorFrame_00032='+STR0185+CRLF/*//'Frequência invalida!'*/
cTexto += 'BscIndicadorFrame_00033='+STR0979+CRLF/*//' "Consulta"'*/
cTexto += 'BscIndicadorFrame_00034='+STR0980+CRLF/*//' "Endereço do DW:"'*/
cTexto += 'BscIndicadorFrame_00035='+STR0981+CRLF/*//' "DataWareHouse:"'*/
cTexto += 'BscIndicadorFrame_00036='+STR0982+CRLF/*//' "Consultas:"'*/
cTexto += 'BscIndicadorFrame_00037='+STR0983+CRLF/*//' "Visualizar consulta"'*/
cTexto += 'BscIndicadorFrame_00038='+STR0984+CRLF/*//' "Tabela"'*/
cTexto += 'BscIndicadorFrame_00039='+STR0985+CRLF/*//' "Por favor, selecione uma consulta"'*/
cTexto += 'BscIndicadorFrame_00040='+STR0008+CRLF/*//' "Adicionar"'*/
cTexto += 'BscIndicadorFrame_00041='+STR0007+CRLF/*//' "Remover"'*/
cTexto += 'BscIndicadorFrame_00042='+STR0262+CRLF//' "Gráficos"'*/
cTexto += 'BscIndicadorFrame_00043='+STR1033+CRLF/*//' "Atenção"'*/
cTexto += 'BscIndicadorFrame_00044='+STR1034+CRLF/*//' "Esse indicador não esta marcado como cumulativo!"'*/
cTexto += 'BscIndicadorFrame_00045='+STR1035+CRLF/*//' "Acumular"'*/
cTexto += 'BscIndicadorFrame_00046='+STR1041+CRLF/*//' "Peso:"'*/
cTexto += 'BscIndicadorCardFrame_00001='+STR0986+CRLF/*//'Consulta do DW'*/   

cTexto += 'BscConsultaDW_00001='+STR0987+CRLF/*// "Visualização de consultas do DW"'*/
cTexto += 'BscConsultaDW_00002='+STR0988+CRLF/*// "Tipo da visualização"'*/
cTexto += 'BscConsultaDW_00003='+STR0500+CRLF/*// "Grafico"'*/
cTexto += 'BscConsultaDW_00004='+STR0984+CRLF/*// "Tabela"'*/
cTexto += 'BscConsultaDW_00005='+STR0902+CRLF/*// "Visualizar"'*/
cTexto += 'BscConsultaDW_00006='+STR0985+CRLF/*// "Por favor, selecione uma consulta"'*/

cTexto += 'BscMapaFrame_00001='+STR0018+CRLF/*//'Ferramenta'*/
cTexto += 'BscMapaFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscMapaFrame_00003='+STR0031+CRLF/*//'Deseja apagar os objetos selecionados?'*/
cTexto += 'BscMapaFrame_00004='+STR0030+CRLF/*//'Confirma\u00E7\u00E3o'*/
cTexto += 'BscMapaFrame_00005='+STR0032+CRLF/*//'Ligacao com mesma origem e destino!'*/
cTexto += 'BscMapaFrame_00006='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscMapaFrame_00007='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscMapaFrame_00008='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscMapaFrame_00009='+STR0156+CRLF/*//'Imprimir'*/
cTexto += 'BscMapaFrame_00010='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscMapaFrame_00011='+STR0158+CRLF/*//'\ \ Carregando...'*/
cTexto += 'BscMapaFrame_00012='+STR0904+CRLF/*//'Excluir Sele\u00e7\u00e3o'*/
cTexto += 'BscMapaFrame_00013='+STR0553+CRLF/*//' Resposabilidade deste usuario   '*/
cTexto += 'BscMapaFrame_00014='+STR0554+CRLF/*//' Responsabilidade de outros'*/
cTexto += 'BscMapaFrame_00015='+STR0555+CRLF/*//'Informe o novo título para o tema'*/
cTexto += 'BscMapaFrame_00016='+STR0556+CRLF/*//'Clique aqui para definir o nome do tema'*/
cTexto += 'BscMapaFrame_00017='+STR0557+CRLF/*//'Divisões'*/
cTexto += 'BscMapaFrame_00018='+STR0558+CRLF/*//'Nome da Divisão'*/
cTexto += 'BscMapaFrame_00019='+STR0559+CRLF/*//'Confirma a impressão do mapa estratégico?'*/
cTexto += 'BscMapaFrame_00020='+STR0560+CRLF/*//'Mudar a cor'*/
cTexto += 'BscMapaFrame_00021='+STR0561+CRLF/*//'Circuluar'*/
cTexto += 'BscMapaFrame_00022='+STR0562+CRLF/*//'Retangular'*/
cTexto += 'BscMapaFrame_00023='+STR0964+CRLF/*// 'Selecionar'*/					
cTexto += 'BscMapaFrame_00024='+STR0564+CRLF/*// 'Cancelar seleção '*/					
cTexto += 'BscMapaFrame_00025='+STR0565+CRLF/*// 'Alterar o texto'*/					
cTexto += 'BscMapaFrame_00026='+STR0953+CRLF/*// 'Exportar'*/
cTexto += 'BscMapaFrame_00027='+STR0958+CRLF/*// 'Dados de análise::'*/
cTexto += 'BscMapaFrame_00028='+STR0926+CRLF/*// 'Análise:'*/       
cTexto += 'BscMapaFrame_00029='+STR0577+CRLF/*// 'Selecione o tipo da linha'*/
cTexto += 'BscMapaFrame_00030='+STR0578+CRLF/*// 'Curva'*/
cTexto += 'BscMapaFrame_00031='+STR0579+CRLF/*// 'Reta'*/		
cTexto += 'BscMapaFrame_00032='+STR0964+CRLF/*// 'Selecionar'*/
cTexto += 'BscMapaFrame_00033='+STR0581+CRLF/*// 'Criar Agrupamentos'*/
cTexto += 'BscMapaFrame_00034='+STR0582+CRLF/*// 'Criar Ligações'*/
cTexto += 'BscMapaFrame_00035='+STR0972+CRLF/*// 'Selecione o tipo de Drill-Down'*/
cTexto += 'BscMapaFrame_00036='+STR0941+CRLF/*// 'Drill Down'*/
cTexto += 'BscMapaFrame_00037='+STR0939+CRLF/*// 'Desdobramentos'*/

cTexto += 'BscMedidaDashboardFrame_00001='+STR0033+CRLF/*//'Painel'*/
cTexto += 'BscMedidaDashboardFrame_00002='+STR0034+CRLF/*//'Indicadores:'*/
cTexto += 'BscMedidaDashboardFrame_00003='+STR0008+CRLF/*//'Adicionar'*/
cTexto += 'BscMedidaDashboardFrame_00004='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscMedidaDashboardFrame_00005='+STR0159+CRLF/*//'Auto-organizar'*/
cTexto += 'BscMedidaDashboardFrame_00006='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscMedidaDashboardFrame_00007='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscMedidaDashboardFrame_00008='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscMedidaDashboardFrame_00009='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscMedidaDashboardFrame_00010='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscMedidaDashboardFrame_00011='+STR0156+CRLF/*//'Imprimir'*/
cTexto += 'BscMedidaDashboardFrame_00012='+STR0935+CRLF/*//'Data de Análise:'*/
cTexto += 'BscMedidaDashboardFrame_00013='+STR0926+CRLF/*//'Análise:'*/
cTexto += 'BscMedidaDashboardFrame_00014='+STR0953+CRLF/*//'Exportar'*/
cTexto += 'BscMedidaDashboardFrame_00015='+STR0543+CRLF/*//'Abrir'*/

cTexto += 'BscMetaFrame_00001='+STR0035+CRLF/*//'Os valores devem estar em ordem decrescente e n\u00E3o podem ser repetidos.'*/
cTexto += 'BscMetaFrame_00002='+STR0036+CRLF/*//'Os valores devem estar em ordem crescente e n\u00E3o podem ser repetidos.'*/
cTexto += 'BscMetaFrame_00003='+STR0961+CRLF/*//'Meta'*/
cTexto += 'BscMetaFrame_00004='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscMetaFrame_00005='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscMetaFrame_00006='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscMetaFrame_00007='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscMetaFrame_00008='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscMetaFrame_00009='+STR0160+CRLF/*//'Meta:'*/
cTexto += 'BscMetaFrame_00010='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscMetaFrame_00011='+STR0161+CRLF/*//'Data Alvo:'*/
cTexto += 'BscMetaFrame_00012='+STR0921+CRLF/*//'Respons\u00e1vel:'*/
cTexto += 'BscMetaFrame_00013='+STR0162+CRLF/*//'Maior Valor'*/
cTexto += 'BscMetaFrame_00014='+STR0163+CRLF/*//'Menor Valor'*/
cTexto += 'BscMetaFrame_00015='+STR0162+CRLF/*//'Maior Valor'*/
cTexto += 'BscMetaFrame_00016='+STR0163+CRLF/*//'Menor Valor'*/
cTexto += 'BscMetaFrame_00017='+STR0164+CRLF/*//'Notas:'*/
cTexto += 'BscMetaFrame_00018='+STR0165+CRLF/*//'Alvos'*/
cTexto += 'BscMetaFrame_00019='+STR0166+CRLF/*//'Notas'*/
cTexto += 'BscMetaFrame_00020='+STR0167+CRLF/*//'Anota\u00e7\u00f5es'*/
cTexto += 'BscMetaFrame_00021='+STR0332+CRLF/*//'Meta Parcelada'*/
cTexto += 'BscMetaFrame_00022='+STR0333+CRLF/*//'Periodo:'*/
cTexto += 'BscMetaFrame_00023='+STR0409+CRLF/*//'Perfil'*/

cTexto += 'BscObjetivoFrame_00001='+STR0912+CRLF/*//'Objetivo'*/
cTexto += 'BscObjetivoFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscObjetivoFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscObjetivoFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscObjetivoFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscObjetivoFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscObjetivoFrame_00007='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscObjetivoFrame_00008='+STR0168+CRLF/*//'Objetivo:'*/
cTexto += 'BscObjetivoFrame_00009='+STR0912+CRLF/*//'Objetivo'*/
cTexto += 'BscObjetivoFrame_00010='+STR0169+CRLF/*//'Iniciativas'*/
cTexto += 'BscObjetivoFrame_00011='+STR0949+CRLF/*//'Indicadores'*/
cTexto += 'BscObjetivoFrame_00012='+STR0921+CRLF/*//'Responsavel'*/
cTexto += 'BscObjetivoFrame_00013='+STR0003+CRLF/*//'Fator Critico de Sucesso'*/
cTexto += 'BscObjetivoFrame_00014='+STR0254+CRLF/*//'Origem'*/

cTexto += 'BscOrganizacaoFrame_00001='+STR0039+CRLF/*//'Organização'*/
cTexto += 'BscOrganizacaoFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscOrganizacaoFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscOrganizacaoFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscOrganizacaoFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscOrganizacaoFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscOrganizacaoFrame_00007='+STR0914+CRLF/*//'Organização:'*/
cTexto += 'BscOrganizacaoFrame_00008='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscOrganizacaoFrame_00009='+STR0172+CRLF/*//'MIss\u00e3o:'*/
cTexto += 'BscOrganizacaoFrame_00010='+STR0173+CRLF/*//'Vis\u00e3o:'*/
cTexto += 'BscOrganizacaoFrame_00011='+STR0164+CRLF/*//'Notas:'*/
cTexto += 'BscOrganizacaoFrame_00012='+STR0174+CRLF/*//'Endere\u00e7o:'*/
cTexto += 'BscOrganizacaoFrame_00013='+STR0175+CRLF/*//'Dados Essenciais'*/
cTexto += 'BscOrganizacaoFrame_00014='+STR0176+CRLF/*//'Cidade:'*/
cTexto += 'BscOrganizacaoFrame_00015='+STR0177+CRLF/*//'Estado:'*/
cTexto += 'BscOrganizacaoFrame_00016='+STR0178+CRLF/*//'Pa\u00eds:'*/
cTexto += 'BscOrganizacaoFrame_00017='+STR0179+CRLF/*//'P\u00e1gina na Web:'*/
cTexto += 'BscOrganizacaoFrame_00018='+STR0180+CRLF/*//'Estrat\u00e9gias'*/
cTexto += 'BscOrganizacaoFrame_00019='+STR0919+CRLF/*//'Pessoas'*/
cTexto += 'BscOrganizacaoFrame_00021='+STR0954+CRLF/*//'Telefone:'*/
cTexto += 'BscOrganizacaoFrame_00022='+STR0252+CRLF/*//'Política da'*/
cTexto += 'BscOrganizacaoFrame_00023='+STR0253+CRLF/*//'Valores:'*/
cTexto += 'BscOrganizacaoFrame_00024='+STR0301+CRLF/*//'Qualidade:'*/
cTexto += 'BscOrganizacaoFrame_00025='+STR0923+CRLF/*//'Reuniões'*/
cTexto += 'BscOrganizacaoFrame_00026='+STR0411+CRLF/*//'Dados Complementares'*/
cTexto += 'BscOrganizacaoFrame_00027='+STR0943+CRLF/*//'E-mail'*/
cTexto += 'BscOrganizacaoFrame_00028='+STR0434+CRLF/*//'Grupos de Pessoas'*/
cTexto += 'BscOrganizacaoFrame_00029='+STR0006+CRLF/*//'Processos'*/
cTexto += 'BscOrganizacaoFrame_00030='+STR1028+CRLF/*//'Duplicar esta Organização'*/
cTexto += 'BscOrganizacaoFrame_00031='+STR1029+CRLF/*//'Duplicar'*/

cTexto += 'BscPerspectivaFrame_00001='+STR0916+CRLF/*//'Perspectiva'*/
cTexto += 'BscPerspectivaFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscPerspectivaFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscPerspectivaFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscPerspectivaFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscPerspectivaFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscPerspectivaFrame_00007='+STR0917+CRLF/*//'Perspectiva:'*/
cTexto += 'BscPerspectivaFrame_00008='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscPerspectivaFrame_00009='+STR0183+CRLF/*//'Ordem:'*/
cTexto += 'BscPerspectivaFrame_00010='+STR0184+CRLF/*//'Objetivos'*/
cTexto += 'BscPerspectivaFrame_00011='+STR0300+CRLF/*//'Operacional (não faz parte da estratégia)'*/
cTexto += 'BscPerspectivaFrame_00012='+STR1039+CRLF/*//'Ao mudar a ordem de uma Perspectiva as customizações de dimensão e posicionamento de perspectivas e objetivos realizadas no Mapa Estrategico Modelo 2 serão perdidas.'*/
cTexto += 'BscPerspectivaFrame_00013='+STR1040+CRLF/*//'Atenção'*/
cTexto += 'BscPerspectivaFrame_00014='+STR1042+CRLF/*//'Deseja continuar?'*/ 
cTexto += 'BscPerspectivaFrame_00015='+STR1043+CRLF/*//'Ao excluir uma Perspectiva as customizações de dimensão e posicionamento de perspectivas e objetivos realizadas no Mapa Estratégico Modelo 2 serão perdidas.'*/

cTexto += 'BscPessoaFrame_00001='+STR0041+CRLF/*//'Pessoa'*/
cTexto += 'BscPessoaFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscPessoaFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscPessoaFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscPessoaFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscPessoaFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscPessoaFrame_00007='+STR0918+CRLF/*//'Pessoa:'*/
cTexto += 'BscPessoaFrame_00008='+STR0069+CRLF/*//'Cargo:'*/
cTexto += 'BscPessoaFrame_00009='+STR0954+CRLF/*//'Telefone:'*/
cTexto += 'BscPessoaFrame_00010='+STR0071+CRLF/*//'Ramal:'*/
cTexto += 'BscPessoaFrame_00011='+STR0174+CRLF/*//'Endere\u00e7o:'*/
cTexto += 'BscPessoaFrame_00012='+STR0176+CRLF/*//'Cidade:'*/
cTexto += 'BscPessoaFrame_00013='+STR0177+CRLF/*//'Estado:'*/
cTexto += 'BscPessoaFrame_00014='+STR0178+CRLF/*//'Pa\u00eds:'*/
cTexto += 'BscPessoaFrame_00015='+STR0341+CRLF/*//'Usuário:'*/

cTexto += 'BscPlanilhaFrame_00001='+STR0042+CRLF/*//'Planilha'*/
cTexto += 'BscPlanilhaFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscPlanilhaFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscPlanilhaFrame_00004='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscPlanilhaFrame_00005='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscPlanilhaFrame_00006='+STR0904+CRLF/*//'Excluir'*/

cTexto += 'BscPrincipalFrame_00001='+STR0043+CRLF/*//'Organizações'*/
cTexto += 'BscPrincipalFrame_00002='+STR0043+CRLF/*//'Organizações'*/

cTexto += 'BscRetornoFrame_00001='+STR0044+CRLF/*//'Retorno'*/
cTexto += 'BscRetornoFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscRetornoFrame_00003='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscRetornoFrame_00004='+STR0193+CRLF/*//'Hor\u00e1rio:'*/
cTexto += 'BscRetornoFrame_00005='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscRetornoFrame_00006='+STR0921+CRLF/*//'Respons\u00e1vel:'*/
cTexto += 'BscRetornoFrame_00007='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscRetornoFrame_00008='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscRetornoFrame_00009='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscRetornoFrame_00010='+STR0956+CRLF/*//'Data:'*/
cTexto += 'BscRetornoFrame_00011='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscRetornoFrame_00012='+STR0975+CRLF/*//'Atenção. O usuário logado não está associado a uma pessoa no sistema. Não é possível incluir sem responsável.'*/

cTexto += 'BscReuniaoFrame_00001='+STR0045+CRLF/*//'Reuniões'*/
cTexto += 'BscReuniaoFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscReuniaoFrame_00003='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscReuniaoFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscReuniaoFrame_00005='+STR0956+CRLF/*//'Data:'*/
cTexto += 'BscReuniaoFrame_00006='+STR0197+CRLF/*//'Local:'*/
cTexto += 'BscReuniaoFrame_00007='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscReuniaoFrame_00008='+STR0196+CRLF/*//'Ata:'*/
cTexto += 'BscReuniaoFrame_00009='+STR0929+CRLF/*//'Assunto:'*/
cTexto += 'BscReuniaoFrame_00010='+STR0193+CRLF/*//'Hor\u00e1rio:'*/
cTexto += 'BscReuniaoFrame_00011='+STR0194+CRLF/*//'Pessoas Convocadas'*/
cTexto += 'BscReuniaoFrame_00012='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscReuniaoFrame_00013='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscReuniaoFrame_00014='+STR0309+CRLF/*//'Detalhes:'*/
cTexto += 'BscReuniaoFrame_00015='+STR0302+CRLF/*//'Início'*/
cTexto += 'BscReuniaoFrame_00016='+STR0303+CRLF/*//'Término'*/
cTexto += 'BscReuniaoFrame_00017='+STR0921+CRLF/*//'Responsavel'*/
cTexto += 'BscReuniaoFrame_00018='+STR0305+CRLF/*//'Pauta'*/
cTexto += 'BscReuniaoFrame_00019='+STR0914+CRLF/*//'Organização'*/
cTexto += 'BscReuniaoFrame_00020='+STR0945+CRLF/*//'Estrategia'*/
cTexto += 'BscReuniaoFrame_00021='+STR0942+CRLF/*//'Elemento'*/
cTexto += 'BscReuniaoFrame_00022='+STR0310+CRLF/*//'Assunto deve ser informado.'*/
cTexto += 'BscReuniaoFrame_00023='+STR0318+CRLF/*//'Data deve ser informada.'*/
cTexto += 'BscReuniaoFrame_00024='+STR0319+CRLF/*//'Término deve ser maior que o Início.'*/
cTexto += 'BscReuniaoFrame_00025='+STR0320+CRLF/*//'Local deve ser informado.'*/
cTexto += 'BscReuniaoFrame_00026='+STR0938+CRLF/*//'Descrição:'*/
cTexto += 'BscReuniaoFrame_00027='+STR0322+CRLF/*//'Deseja notificar as pessoas convocadas?'*/
cTexto += 'BscReuniaoFrame_00028='+STR0323+CRLF/*//'Notificar'*/

cTexto += 'BscSenhaDialog_00001='+STR0046+CRLF/*//'Senha'*/
cTexto += 'BscSenhaDialog_00002='+STR0047+CRLF/*//'A senha e a confirma\u00E7\u00E3o da senha diferem.\ '*/
cTexto += 'BscSenhaDialog_00003='+STR0048+CRLF/*//'Digite novamente.'*/
cTexto += 'BscSenhaDialog_00004='+STR0049+CRLF/*//'A senha deve ter mais de 3 dig\u00EDtos.'*/
cTexto += 'BscSenhaDialog_00005='+STR0962+CRLF/*//'Ok'*/
cTexto += 'BscSenhaDialog_00006='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscSenhaDialog_00007='+STR0198+CRLF/*//'Confirmar Senha:'*/
cTexto += 'BscSenhaDialog_00008='+STR0922+CRLF/*//'Senha:'*/

cTexto += 'BscTarDocFrame_00001='+STR0021+CRLF/*//'Documento'*/
cTexto += 'BscTarDocFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscTarDocFrame_00003='+STR0022+CRLF/*//'N\u00E3o foi poss\u00EDvel visualizar. Verifique se o link est\u00E1 correto e tente novamente.'*/
cTexto += 'BscTarDocFrame_00004='+STR0023+CRLF/*//'Erro'*/
cTexto += 'BscTarDocFrame_00005='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscTarDocFrame_00006='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscTarDocFrame_00007='+STR0960+CRLF/*//'Link:'*/
cTexto += 'BscTarDocFrame_00008='+STR0292+CRLF/*//'Texto:'*/
cTexto += 'BscTarDocFrame_00009='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscTarDocFrame_00010='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscTarDocFrame_00011='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscTarDocFrame_00012='+STR0116+CRLF/*//'Descrição:'*/
cTexto += 'BscTarDocFrame_00013='+STR0902+CRLF/*//'Visualizar'*/

cTexto += 'BscTarefaFrame_00001='+STR0050+CRLF/*//'Tarefa'*/
cTexto += 'BscTarefaFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscTarefaFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscTarefaFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscTarefaFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscTarefaFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscTarefaFrame_00007='+STR0053+CRLF/*//'Horas:'*/
cTexto += 'BscTarefaFrame_00008='+STR0056+CRLF/*//'Terceiriza\u00E7\u00E3o:'*/
cTexto += 'BscTarefaFrame_00009='+STR0054+CRLF/*//'M\u00e3o de Obra:'*/
cTexto += 'BscTarefaFrame_00010='+STR0055+CRLF/*//'Materiais:'*/
cTexto += 'BscTarefaFrame_00011='+STR0053+CRLF/*//'Horas:'*/
cTexto += 'BscTarefaFrame_00012='+STR0056+CRLF/*//'Terceiriza\u00e7\u00e3o:'*/
cTexto += 'BscTarefaFrame_00013='+STR0054+CRLF/*//'M\u00e3o de Obra:'*/
cTexto += 'BscTarefaFrame_00014='+STR0055+CRLF/*//'Materiais:'*/
cTexto += 'BscTarefaFrame_00015='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscTarefaFrame_00016='+STR0058+CRLF/*//'Completado:'*/
cTexto += 'BscTarefaFrame_00017='+STR0059+CRLF/*//'Situa\u00e7\u00e3o:'*/
cTexto += 'BscTarefaFrame_00018='+STR0060+CRLF/*//'Descri\u00e7\u00E3o (How):'*/
cTexto += 'BscTarefaFrame_00019='+STR0061+CRLF/*//'Termino:'*/
cTexto += 'BscTarefaFrame_00020='+STR0062+CRLF/*//'Inicio:'*/
cTexto += 'BscTarefaFrame_00021='+STR0063+CRLF/*//'Pessoas em Cobran\u00e7a'*/
cTexto += 'BscTarefaFrame_00022='+STR0064+CRLF/*//'Retornos'*/
cTexto += 'BscTarefaFrame_00023='+STR0940+CRLF/*//'Documentos'*/
cTexto += 'BscTarefaFrame_00024='+STR0263+CRLF/*//'Local'*/
cTexto += 'BscTarefaFrame_00025='+STR0264+CRLF/*//'Custo Estimado (How Much)'*/
cTexto += 'BscTarefaFrame_00026='+STR0265+CRLF/*//'Custo Real (How Much)'*/
cTexto += 'BscTarefaFrame_00027='+STR0977+CRLF/*//'Importância:'*/
cTexto += 'BscTarefaFrame_00028='+STR0978+CRLF/*//'Urgência:'*/

cTexto += 'BscUsuarioFrame_00001='+STR0066+CRLF/*//'Usuário'*/
cTexto += 'BscUsuarioFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscUsuarioFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscUsuarioFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscUsuarioFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscUsuarioFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscUsuarioFrame_00007='+STR0067+CRLF/*//'Alterar Senha'*/
cTexto += 'BscUsuarioFrame_00008='+STR0924+CRLF/*//'Administrador'*/
cTexto += 'BscUsuarioFrame_00009='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscUsuarioFrame_00010='+STR0069+CRLF/*//'Cargo:'*/
cTexto += 'BscUsuarioFrame_00011='+STR0954+CRLF/*//'Telefone:'*/
cTexto += 'BscUsuarioFrame_00012='+STR0071+CRLF/*//'Ramal:'*/
cTexto += 'BscUsuarioFrame_00013='+STR0943+CRLF/*//'E-mail:'*/
cTexto += 'BscUsuarioFrame_00014='+STR0073+CRLF/*//'Seguran\u00e7a'*/
cTexto += 'BscUsuarioFrame_00015='+STR0341+CRLF/*//'Usuário:'*/
cTexto += 'BscUsuarioFrame_00016='+STR0922+CRLF/*//'Senha:'*/
cTexto += 'BscUsuarioFrame_00017='+STR0254+CRLF/*//Origem*/
cTexto += 'BscUsuarioFrame_00018='+STR0255+CRLF// Usuário Protheus*/
cTexto += 'BscUsuarioFrame_00019='+STR0256+CRLF/*//Gravar, Editar*/
cTexto += 'BscUsuarioFrame_00020='+STR0257+CRLF/*//Ver Numeros*/
cTexto += 'BscUsuarioFrame_00021='+STR0258+CRLF/*//Ver Cores*/
cTexto += 'BscUsuarioFrame_00022='+STR0259+CRLF/*//Ler Elementos*/
cTexto += 'BscUsuarioFrame_00023='+STR0260+CRLF/*//Criar Reuniões*/
cTexto += 'BscUsuarioFrame_00024='+STR0924+CRLF/*//Administrador*/
cTexto += 'BscUsuarioFrame_00025='+STR1075+CRLF/*//Atualiza a árvore de dados ao editar itens*/ 
cTexto += 'BscUsuarioFrame_00026='+STR1077+CRLF//"Não atualizar a árvore de dados ao editar itens."     

cTexto += 'BscUsuariosFrame_00001='+STR0074+CRLF/*//'Grupos'*/
cTexto += 'BscUsuariosFrame_00002='+STR0251+CRLF/*//'Total de Grupos:'*/
cTexto += 'BscUsuariosFrame_00003='+STR0075+CRLF/*//'Total de Usu\u00e1rios:'*/
cTexto += 'BscUsuariosFrame_00004='+STR0957+CRLF/*//'Usu\u00e1rios'*/
cTexto += 'BscUsuariosFrame_00005='+STR0077+CRLF/*//'Diret\u00f3rio de Usu\u00e1rios'*/   
cTexto += 'BscUsuariosFrame_00006='+STR1079+CRLF//"Nome"  
cTexto += 'BscUsuariosFrame_00007='+STR1080+CRLF//"Usuários do Grupo"  

cTexto += 'BscApplet_00001='+STR0078+CRLF/*//'Erro configurando LookAndFeel.'*/

cTexto += 'BscBaseFrame_00001='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscBaseFrame_00002='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscBaseFrame_00003='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscBaseFrame_00004='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscBaseFrame_00005='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscBaseFrame_00006='+STR0911+CRLF/*//'Nome:'*/ 
cTexto += 'BscBaseFrame_00007='+STR1078+CRLF//"Permissão" 

cTexto += 'BscCardsPanel_00001='+STR0079+CRLF/*//'teste'*/

cTexto += 'BscDefaultFrameBehavior_00001='+STR0080+CRLF/*//'Erro ao fechar o formul\u00E1rio:\ '*/
cTexto += 'BscDefaultFrameBehavior_00002='+STR0080+CRLF/*//'Erro ao fechar o formul\u00E1rio:\ '*/
cTexto += 'BscDefaultFrameBehavior_00003='+STR0081+CRLF/*//'Erro desconhecido ao fechar o formul\u00E1rio.'*/
cTexto += 'BscDefaultFrameBehavior_00004='+STR0080+CRLF/*//'Erro ao fechar o formul\u00E1rio:\ '*/
cTexto += 'BscDefaultFrameBehavior_00005='+STR0082+CRLF/*//'Erro ao tentar obter a estrutura do tipo\ '*/

cTexto += 'BscLoginPanel_00001='+STR0083+CRLF/*//'Erro carregando imagens!'*/
cTexto += 'BscLoginPanel_00002='+STR0957+CRLF/*//'Usu\u00e1rio:'*/
cTexto += 'BscLoginPanel_00003='+STR0922+CRLF/*//'Senha:'*/
cTexto += 'BscLoginPanel_00004='+STR0086+CRLF/*//'resposta:'*/
cTexto += 'BscLoginPanel_00005='+STR0087+CRLF/*//'Acesso negado!\ '*/
cTexto += 'BscLoginPanel_00006='+STR0023+CRLF/*//'Erro'*/

cTexto += 'BscMainPanel_00001='+STR0088+CRLF/*//'Erro!'*/
cTexto += 'BscMainPanel_00002='+STR0010+CRLF/*//'Carregando...'*/
cTexto += 'BscMainPanel_00003='+STR0088+CRLF/*//'Erro!'*/
cTexto += 'BscMainPanel_00004='+STR0039+CRLF/*//'Organização'*/
cTexto += 'BscMainPanel_00005='+STR0957+CRLF/*//'Usu\u00e1rios'*/
cTexto += 'BscMainPanel_00006='+STR0089+CRLF/*//'principal'*/
cTexto += 'BscMainPanel_00007='+STR0089+CRLF/*//'principal'*/
cTexto += 'BscMainPanel_00008='+STR0905+CRLF/*//'Ajuda'*/
cTexto += 'BscMainPanel_00009='+STR0091+CRLF/*//'Voc\u00EA deseja realmente sair do sistema?'*/
cTexto += 'BscMainPanel_00010='+STR0030+CRLF/*//'Confirma\u00E7\u00E3o'*/
cTexto += 'BscMainPanel_00011='+STR0092+CRLF/*//'Aparencia'*/
cTexto += 'BscMainPanel_00012='+STR0093+CRLF/*//'Janelas'*/
cTexto += 'BscMainPanel_00013='+STR0078+CRLF/*//'Erro configurando LookAndFeel.'*/
cTexto += 'BscMainPanel_00014='+STR0094+CRLF/*//'Conex\u00E3o ociosa.'*/
cTexto += 'BscMainPanel_00015='+STR0095+CRLF/*//'Conectando ao servidor...'*/
cTexto += 'BscMainPanel_00016='+STR0093+CRLF/*//'Janelas'*/
cTexto += 'BscMainPanel_00017='+STR0927+CRLF/*//'Apar\u00eancia'*/
cTexto += 'BscMainPanel_00018='+STR0905+CRLF/*//'Ajuda'*/
cTexto += 'BscMainPanel_00019='+STR0098+CRLF/*//'Cascata'*/
cTexto += 'BscMainPanel_00020='+STR0097+CRLF/*//'Lado a lado'*/
cTexto += 'BscMainPanel_00021='+STR0099+CRLF/*//'Iconizar'*/
cTexto += 'BscMainPanel_00022='+STR0927+CRLF/*//'Apar\u00EAncia  >'*/
cTexto += 'BscMainPanel_00023='+STR0101+CRLF/*//'Esmeralda'*/
cTexto += 'BscMainPanel_00024='+STR0102+CRLF/*//'Safira'*/
cTexto += 'BscMainPanel_00025='+STR0092+CRLF/*//'Aparencia'*/
cTexto += 'BscMainPanel_00026='+STR0103+CRLF/*//'Ajuda  >'*/
cTexto += 'BscMainPanel_00027='+STR0104+CRLF/*//'Conte\u00fado'*/
cTexto += 'BscMainPanel_00028='+STR0105+CRLF/*//'Pesquisar'*/
cTexto += 'BscMainPanel_00029='+STR0106+CRLF/*//'Janelas  >'*/
cTexto += 'BscMainPanel_00030='+STR0107+CRLF/*//'Sobre'*/
cTexto += 'BscMainPanel_00031='+STR0093+CRLF/*//'Janelas'*/
cTexto += 'BscMainPanel_00032='+STR0905+CRLF/*//'Ajuda'*/
cTexto += 'BscMainPanel_00033='+STR0108+CRLF/*//'Enviando requisi\u00e7\u00e3o ao servidor...'*/
cTexto += 'BscMainPanel_00034='+STR0241+CRLF/*//'Área de Trabalho'*/
cTexto += 'BscMainPanel_00035='+STR0313+CRLF/*//'\Política'*/
cTexto += 'BscMainPanel_00036='+STR0314+CRLF/*//'\Exibir'*/
cTexto += 'BscMainPanel_00037='+STR0315+CRLF/*//'\Exibir->'*/
cTexto += 'BscMainPanel_00038='+STR0952+CRLF/*//'\Janela'*/
cTexto += 'BscMainPanel_00039='+STR0915+CRLF/*//'\Pasta'*/
cTexto += 'BscMainPanel_00040='+STR0934+CRLF//'\Configurações'*/
cTexto += 'BscMainPanel_00041='+STR1027+CRLF/*//'\Sair'*/

cTexto += 'BscServerSubstitute_00001='+STR0145+CRLF/*//'XML Enviado:'*/
cTexto += 'BscServerSubstitute_00002='+STR0146+CRLF/*//'XML Recebido:'*/

cTexto += 'BscIniciativaFrame_00001='+STR0950+CRLF/*//'Iniciativa'*/
cTexto += 'BscIniciativaFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscIniciativaFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscIniciativaFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscIniciativaFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscIniciativaFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscIniciativaFrame_00007='+STR0951+CRLF/*//'Iniciativa:'*/
cTexto += 'BscIniciativaFrame_00008='+STR0116+CRLF/*//'Descrição:'*/
cTexto += 'BscIniciativaFrame_00009='+STR0936+CRLF/*//'Data In\u00edcio:'*/
cTexto += 'BscIniciativaFrame_00010='+STR0289+CRLF/*//'Data Fim:'*/
cTexto += 'BscIniciativaFrame_00011='+STR0921+CRLF/*//'Respons\u00e1vel:'*/
cTexto += 'BscIniciativaFrame_00012='+STR0058+CRLF/*//'Completado:'*/
cTexto += 'BscIniciativaFrame_00013='+STR0150+CRLF/*//'Horas Estimadas:'*/
cTexto += 'BscIniciativaFrame_00014='+STR0151+CRLF/*//'Custo Estimado:'*/
cTexto += 'BscIniciativaFrame_00015='+STR0152+CRLF/*//'Horas Reais:'*/
cTexto += 'BscIniciativaFrame_00016='+STR0153+CRLF/*//'Custo Real:'*/
cTexto += 'BscIniciativaFrame_00017='+STR0154+CRLF/*//'Tarefas'*/
cTexto += 'BscIniciativaFrame_00018='+STR0940+CRLF/*//'Documentos'*/
cTexto += 'BscIniciativaFrame_00019='+STR0923+CRLF/*//'Reuniões'*/
cTexto += 'BscIniciativaFrame_00020='+STR0404+CRLF/*//'Status:'*/

cTexto += 'BscRelEstFrame_00001='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscRelEstFrame_00002='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscRelEstFrame_00003='+STR0902+CRLF/*//'Visualizar'*/
cTexto += 'BscRelEstFrame_00004='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscRelEstFrame_00005='+STR0188+CRLF/*//'Incluir descri\u00e7\u00e3o no relat\u00f3rio'*/
cTexto += 'BscRelEstFrame_00006='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscRelEstFrame_00007='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscRelEstFrame_00008='+STR0947+CRLF/*//'Gerar'*/
cTexto += 'BscRelEstFrame_00009='+STR0186+CRLF/*//'Relat\u00F3rio de Estrat\u00E9gia'*/
cTexto += 'BscRelEstFrame_00010='+STR0116+CRLF/*//'Descrição:'*/
cTexto += 'BscRelEstFrame_00011='+STR0931+CRLF/*//'Atualizar'*/

cTexto += 'BscRelIndFrame_00001='+STR0191+CRLF/*//'at\u00e9'*/
cTexto += 'BscRelIndFrame_00002='+STR0902+CRLF/*//'Visualizar'*/
cTexto += 'BscRelIndFrame_00003='+STR0188+CRLF/*//'Incluir descri\u00e7\u00e3o no relat\u00f3rio'*/
cTexto += 'BscRelIndFrame_00004='+STR0116+CRLF/*//'Descrição:'*/
cTexto += 'BscRelIndFrame_00005='+STR0191+CRLF/*//'at\u00e9'*/
cTexto += 'BscRelIndFrame_00006='+STR0947+CRLF/*//'Gerar*/
cTexto += 'BscRelIndFrame_00007='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscRelIndFrame_00008='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscRelIndFrame_00009='+STR0917+CRLF/*//'Perspectiva:'*/
cTexto += 'BscRelIndFrame_00010='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscRelIndFrame_00011='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscRelIndFrame_00012='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscRelIndFrame_00013='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscRelIndFrame_00014='+STR0190+CRLF/*//'Relat\u00f3rio de Indicadores'*/
cTexto += 'BscRelIndFrame_00015='+STR0189+CRLF/*//'Per\u00edodo:'*/
cTexto += 'BscRelIndFrame_00016='+STR0184+':'+CRLF/*//'Objetivos:'*/
cTexto += 'BscRelIndFrame_00017='+STR0935+CRLF/*//'Data de Análise:'*/
cTexto += 'BscRelIndFrame_00018='+STR1073+CRLF/*//'Ordem de Objetivos:'*/
cTexto += 'BscRelIndFrame_00019='+STR1074+CRLF/*//'Ordem de Indicadores:'*/

cTexto += 'BscRelTarFrame_00001='+STR0191+CRLF/*//'at\u00e9'*/
cTexto += 'BscRelTarFrame_00002='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscRelTarFrame_00003='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscRelTarFrame_00004='+STR0918+CRLF/*//'Pessoa:'*/
cTexto += 'BscRelTarFrame_00005='+STR0189+CRLF/*//'Per\u00edodo:'*/
cTexto += 'BscRelTarFrame_00006='+STR0116+CRLF/*//'Descrição:'*/
cTexto += 'BscRelTarFrame_00007='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscRelTarFrame_00008='+STR0192+CRLF/*//'Relatório de Iniciativas e Tarefas'*/
cTexto += 'BscRelTarFrame_00009='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscRelTarFrame_00010='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscRelTarFrame_00011='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscRelTarFrame_00012='+STR0188+CRLF/*//'Incluir descri\u00e7\u00e3o no relat\u00f3rio'*/
cTexto += 'BscRelTarFrame_00013='+STR0191+CRLF/*//'at\u00e9'*/
cTexto += 'BscRelTarFrame_00014='+STR0947+CRLF/*//'Gerar'*/
cTexto += 'BscRelTarFrame_00015='+STR0902+CRLF/*//'Visualizar'*/
cTexto += 'BscRelTarFrame_00016='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscRelTarFrame_00017='+STR0068+CRLF/*//'Tarefas:'*/
cTexto += 'BscRelTarFrame_00018='+STR0065+CRLF/*//'Iniciativas:'*/
cTexto += 'BscRelTarFrame_00019='+STR0070+CRLF/*//'Listar:'*/
cTexto += 'BscRelTarFrame_00020='+STR1106+CRLF//"Período de:"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
cTexto += 'BscRelTarFrame_00021='+STR1107+CRLF//"Responsável:"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
cTexto += 'BscRelTarFrame_00022='+STR1108+CRLF//"Situação:"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
                                                              
cTexto += 'BscRelBookFrame_00001='+STR0911+CRLF/*//'Nome'*/
cTexto += 'BscRelBookFrame_00002='+STR0938+CRLF/*//'Descrição'*/
cTexto += 'BscRelBookFrame_00003='+STR0586+CRLF/*//'Documentos'*/
cTexto += 'BscRelBookFrame_00004='+STR0587+CRLF/*//'Selecione o Documento'*/
cTexto += 'BscRelBookFrame_00005='+STR0588+CRLF/*//'Imprimir de'*/
cTexto += 'BscRelBookFrame_00006='+STR0589+CRLF/*//'Imprimir ate'*/
cTexto += 'BscRelBookFrame_00007='+STR0039+CRLF/*//'Organização'*/
cTexto += 'BscRelBookFrame_00008='+STR0945+CRLF/*//'Estratégia'*/
cTexto += 'BscRelBookFrame_00009='+STR0916+CRLF/*//'Perspectiva'*/
cTexto += 'BscRelBookFrame_00010='+STR0590+CRLF/*//'Tema'*/
cTexto += 'BscRelBookFrame_00011='+STR0912+CRLF/*//'Objetivo'*/
cTexto += 'BscRelBookFrame_00012='+STR0959+CRLF/*//'Indicador'*/
cTexto += 'BscRelBookFrame_00013='+STR0950+CRLF/*//'Iniciativa'*/
cTexto += 'BscRelBookFrame_00014='+STR0050+CRLF/*//'Tarefa'*/
cTexto += 'BscRelBookFrame_00015='+STR0045+CRLF/*//'Reunião'*/
cTexto += 'BscRelBookFrame_00016='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscRelBookFrame_00017='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscRelBookFrame_00018='+STR0506+CRLF/*//'Atualizar'*/
cTexto += 'BscRelBookFrame_00019='+STR0905+CRLF/*//'Ajuda'*/
cTexto += 'BscRelBookFrame_00020='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscRelBookFrame_00021='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscRelBookFrame_00022='+STR0188+CRLF/*//'Incluir Descrição'*/
cTexto += 'BscRelBookFrame_00023='+STR0947+CRLF/*//'Gerar'*/
cTexto += 'BscRelBookFrame_00024='+STR0902+CRLF/*//'Visualizar'*/
cTexto += 'BscRelBookFrame_00025='+STR0591+CRLF/*//'Book de Planejamento Estratégico'*/

cTexto += 'BscDefaultDialogSystem_00001='+STR0023+CRLF/*//'Erro'*/
cTexto += 'BscDefaultDialogSystem_00002='+STR0218+CRLF/*//'associados a este elemento. N\u00E3o pode ser exclu\u00EDdo.'*/
cTexto += 'BscDefaultDialogSystem_00003='+STR0217+CRLF/*//'alterado por outro usu\u00E1rio. Tente novamente mais tarde.'*/
cTexto += 'BscDefaultDialogSystem_00004='+STR0216+CRLF/*//'Voc\u00EA n\u00E3o est\u00E1 autorizado a\ '*/
cTexto += 'BscDefaultDialogSystem_00005='+STR0215+CRLF/*//'\ Aten\u00E7\u00E3o: todos os registros filhos tamb\u00E9m ser\u00E3o excluidos.'*/
cTexto += 'BscDefaultDialogSystem_00006='+STR0214+CRLF/*//'Este elemento n\u00E3o est\u00E1\ '*/
cTexto += 'BscDefaultDialogSystem_00007='+STR0213+CRLF/*//'Erro de protocolo: NOCMD.'*/
cTexto += 'BscDefaultDialogSystem_00008='+STR0212+CRLF/*//'Erro de protocolo:\ '*/
cTexto += 'BscDefaultDialogSystem_00009='+STR0211+CRLF/*//'com o servidor expirou. Por favor realize novamente a conex\u00E3o.'*/
cTexto += 'BscDefaultDialogSystem_00010='+STR0210+CRLF/*//'presente no servidor. Tente atualizar os dados.'*/
cTexto += 'BscDefaultDialogSystem_00011='+STR0209+CRLF/*//'O tempo ocioso de conex\u00E3o\ '*/
cTexto += 'BscDefaultDialogSystem_00012='+STR0208+CRLF/*//'opera\u00E7\u00E3o ao servidor. Por favor, espere a sua conclus\u00E3o.'*/
cTexto += 'BscDefaultDialogSystem_00013='+STR0207+CRLF/*//'Existem outros objetos\ '*/
cTexto += 'BscDefaultDialogSystem_00014='+STR0206+CRLF/*//'\ desconhecido.'*/
cTexto += 'BscDefaultDialogSystem_00015='+STR0205+CRLF/*//'Este registro est\u00E1 sendo\ '*/
cTexto += 'BscDefaultDialogSystem_00016='+STR0204+CRLF/*//'realizar esta opera\u00E7\u00E3o.'*/
cTexto += 'BscDefaultDialogSystem_00017='+STR0203+CRLF/*//'Erro n\u00BA\ '*/
cTexto += 'BscDefaultDialogSystem_00018='+STR0202+CRLF/*//'Erro de protocolo: BADXML.'*/
cTexto += 'BscDefaultDialogSystem_00019='+STR0030+CRLF/*//'Confirma\u00E7\u00E3o'*/
cTexto += 'BscDefaultDialogSystem_00020='+STR0201+CRLF/*//'Voc\u00EA j\u00E1 requisitou uma\ '*/
cTexto += 'BscDefaultDialogSystem_00021='+STR0238+CRLF/*//'Voc\u00EA deseja realmente excluir este registro?'*/
cTexto += 'BscDefaultDialogSystem_00022='+STR0527+CRLF/*//'Informacao'*/
cTexto += 'BscDefaultDialogSystem_00023='+STR0528+CRLF/*//'Aviso'*/
cTexto += 'BscDefaultDialogSystem_00024='+STR0311+CRLF/*//'Sim'*/
cTexto += 'BscDefaultDialogSystem_00025='+STR0312+CRLF/*//'Não'*/
cTexto += 'BscDefaultDialogSystem_00026='+STR1026+CRLF/*//'Caracter inválido'*/

cTexto += 'BIXMLGeneralData_00001='+STR0229+CRLF/*//'\ o valor \"'*/
cTexto += 'BIXMLGeneralData_00002='+STR0225+CRLF/*//'\" n\u00E3o existe.'*/
cTexto += 'BIXMLGeneralData_00003='+STR0226+CRLF/*//'Chave \"'*/
cTexto += 'BIXMLGeneralData_00004='+STR0227+CRLF/*//'\" do campo \"'*/
cTexto += 'BIXMLGeneralData_00005='+STR0228+CRLF/*//'N\u00E3o foi poss\u00EDvel converter'*/
cTexto += 'BIXMLGeneralData_00006'+STR0230+CRLF/*//'\" para um valor no formato float.'*/
cTexto += 'BIXMLGeneralData_00007='+STR0224+CRLF/*//'\" para um valor no formato boolean.'*/
cTexto += 'BIXMLGeneralData_00008='+STR0223+CRLF/*//'\" para um valor no formato int.'*/
cTexto += 'BIXMLGeneralData_00009='+STR0222+CRLF/*//'\" para um valor no formato GregorianCalendar.'*/
cTexto += 'BIXMLGeneralData_00010='+STR0221+CRLF/*//'A chave \"'*/
cTexto += 'BIXMLGeneralData_00011='+STR0219+CRLF/*//'\" para um valor no formato double.'*/
cTexto += 'BIXMLGeneralData_00012='+STR0220+CRLF/*//'\" para um valor no formato long.'*/

cTexto += 'BIXMLRecord_00001='+STR0225+CRLF/*//'\" n\u00E3o existe.'*/
cTexto += 'BIXMLRecord_00002='+STR0226+CRLF/*//'Chave \"'*/

cTexto += 'BIXMLVector_00001='+STR0237+CRLF/*//'Erro de I/O no XML.'*/
cTexto += 'BIXMLVector_00002='+STR0236+CRLF/*//'Erro no processamento dos dados recebidos'*/
cTexto += 'BIXMLVector_00003='+STR0235+CRLF/*//'\ do servidor.'*/
cTexto += 'BIXMLVector_00004='+STR0234+CRLF/*//'est\u00E3o corrompidos.\ '*/
cTexto += 'BIXMLVector_00005='+STR0233+CRLF/*//'Dados recebidos do servidor\ '*/
cTexto += 'BIXMLVector_00006='+STR0232+CRLF/*//'Cadeia com XML \u00E9 vazia.'*/
cTexto += 'BIXMLVector_00007='+STR0231+CRLF/*//'Cadeia com XML \u00E9 nula.'*/

cTexto += 'BscAjuda_00001='+STR0905+CRLF/*//'Ajuda'*/

cTexto += 'BscRel5w2hFrame_00001='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscRel5w2hFrame_00002='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscRel5w2hFrame_00003='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscRel5w2hFrame_00004='+STR0905+CRLF/*//'Ajuda'*/
cTexto += 'BscRel5w2hFrame_00005='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscRel5w2hFrame_00006='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscRel5w2hFrame_00007='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscRel5w2hFrame_00008='+STR0938+CRLF/*//'Descrição:'*/
cTexto += 'BscRel5w2hFrame_00009='+STR0274+CRLF/*//'Incluir descrição no relatório'*/
cTexto += 'BscRel5w2hFrame_00010='+STR0918+CRLF/*//'Pessoa:'*/
cTexto += 'BscRel5w2hFrame_00011='+STR0916+CRLF/*//'Perspectiva'*/
cTexto += 'BscRel5w2hFrame_00012='+STR0912+CRLF/*//'Objetivo:'*/
cTexto += 'BscRel5w2hFrame_00013='+STR0950+CRLF/*//'Iniciativa:'*/
cTexto += 'BscRel5w2hFrame_00014='+STR0279+CRLF/*//'Início de:'*/
cTexto += 'BscRel5w2hFrame_00015='+STR0930+CRLF/*//'até'*/
cTexto += 'BscRel5w2hFrame_00016='+STR0281+CRLF/*//'Término de:'*/
cTexto += 'BscRel5w2hFrame_00017='+STR0930+CRLF/*//'até'*/
cTexto += 'BscRel5w2hFrame_00018='+STR0283+CRLF/*//'Situação:'*/
cTexto += 'BscRel5w2hFrame_00019='+STR0947+CRLF/*//'Gerar Relatório'*/
cTexto += 'BscRel5w2hFrame_00020='+STR0902+CRLF/*//'Visualizar'*/
cTexto += 'BscRel5w2hFrame_00021='+STR0920+CRLF/*//'Plano de Ação'*/
cTexto += 'BscRel5w2hFrame_00022='+STR0920+CRLF/*//'Plano de Ação'*/
cTexto += 'BscRel5w2hFrame_00023='+STR0293+CRLF/*//'Entidades'*/
cTexto += 'BscRel5w2hFrame_00024='+STR0945+CRLF/*//'Estrategia'*/
cTexto += 'BscRel5w2hFrame_00025='+STR0977+CRLF/*//'Importância:'*/
cTexto += 'BscRel5w2hFrame_00026='+STR0978+CRLF/*//'Urgência:'*/

//Grafico
cTexto += 'BscGraphFrame_00001='+STR0500+CRLF/*//'Grafico'*/
cTexto += 'BscGraphFrame_00002='+STR0959+CRLF/*//'Indicador'*/
cTexto += 'BscGraphFrame_00003='+STR0502+CRLF/*//'Avaliacao'*/
cTexto += 'BscGraphFrame_00004='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscGraphFrame_00005='+STR0504+CRLF/*//'Zoom:'*/
cTexto += 'BscGraphFrame_00006='+STR0505+CRLF/*//'Estilo do gráfico'*/
cTexto += 'BscGraphFrame_00007='+STR0506+CRLF/*//'Atualizar'*/
cTexto += 'BscGraphFrame_00008='+STR0507+CRLF/*//'Avançado'*/
cTexto += 'BscGraphFrame_00009='+STR0508+CRLF/*//'Frequencia'*/
cTexto += 'BscGraphFrame_00010='+STR0963+CRLF/*//'Referencia'*/
cTexto += 'BscGraphFrame_00011='+STR0961+CRLF/*//'Meta'*/
cTexto += 'BscGraphFrame_00012='+STR0511+CRLF/*//'Periodo de'*/
cTexto += 'BscGraphFrame_00013='+STR0930+CRLF/*//'ate'*/
cTexto += 'BscGraphFrame_00014='+STR0513+CRLF/*//'Agrupamento'*/
cTexto += 'BscGraphFrame_00015='+STR0956+CRLF/*//'Data'*/
cTexto += 'BscGraphFrame_00016='+STR0515+CRLF/*//'º semana '	*/	
cTexto += 'BscGraphFrame_00017='+STR0516+CRLF/*//'º quinzena '*/		
cTexto += 'BscGraphFrame_00018='+STR0517+CRLF/*//'º bimestre: '*/		
cTexto += 'BscGraphFrame_00019='+STR0518+CRLF/*//'º trimeste '*/		
cTexto += 'BscGraphFrame_00020='+STR0519+CRLF/*//'º quadrimestre '*/		
cTexto += 'BscGraphFrame_00021='+STR0520+CRLF/*//'º semestre '*/		
cTexto += 'BscGraphFrame_00022='+STR0521+CRLF/*//' de '*/		
cTexto += 'BscGraphFrame_00023='+STR0529+CRLF/*//'Indicadores de frequencia semanal so podem ser ter agrupamento anual!'*/		
cTexto += 'BscGraphFrame_00024='+STR0530+CRLF/*//''O valor de data ate deve ser menor que data de.'*/
cTexto += 'BscGraphFrame_00025='+STR0549+CRLF/*//'Descarregar'*/
cTexto += 'BscGraphFrame_00026='+STR0550+CRLF/*//'Indicadores quadrimestrais só podem ser agrupados anualmente.'*/
cTexto += 'BscGraphFrame_00027='+STR0551+CRLF/*//'Data da avaliação: '*/
cTexto += 'BscGraphFrame_00028='+STR0953+CRLF/*//'Exportar '*/
cTexto += 'BscGraphFrame_00029='+STR0567+CRLF/*//'Imprimir'*/
cTexto += 'BscGraphFrame_00030='+STR0926+CRLF/*//'Análise:'*/
cTexto += 'BscGraphFrame_00031='+STR0569+CRLF/*//'Avaliação:'*/
cTexto += 'BscGraphFrame_00032='+STR0593+CRLF/*//'Ind.:'*/
cTexto += 'BscGraphFrame_00033='+STR0594+CRLF/*//'Ref.:'*/
cTexto += 'BscGraphFrame_00034='+STR0973+CRLF/*//'Maximizar'*/
cTexto += 'BscGraphFrame_00035='+STR0974+CRLF/*//'Fechar.:'*/  
cTexto += 'BscGraphFrame_00036='+STR1038+CRLF/*//'DrillDown acessível somente através modo normal de visualização.'*/  

//Grafico Avancado
cTexto += 'BscGraphFrameAvancado_00001='+STR0522+CRLF/*//'Cores por linha'*/		
cTexto += 'BscGraphFrameAvancado_00002='+STR0523+CRLF/*//'Trocar linha X coluna'*/		
cTexto += 'BscGraphFrameAvancado_00003='+STR0524+CRLF/*//'Mostrar legenda'*/		
cTexto += 'BscGraphFrameAvancado_00004='+STR0962+CRLF/*//'Ok'*/		
cTexto += 'BscGraphFrameAvancado_00005='+STR0906+CRLF/*//'Cancelar'*/		
cTexto += 'BscGraphFrameAvancado_00006='+STR0592+CRLF/*//'Mostrar meta usando séries'*/		

//Bsc FileChooser

cTexto += 'BscFileChooser_00001='+STR0531+CRLF/*//'O arquivo ''*/		
cTexto += 'BscFileChooser_00002='+STR0532+CRLF/*//' ja existe.\nDeseja substituir o arquivo existente? '*/		
cTexto += 'BscFileChooser_00003='+STR0533+CRLF/*//' ja existe. '*/		
cTexto += 'BscFileChooser_00004='+STR0534+CRLF/*//'Escolha outro nome.'*/		
cTexto += 'BscFileChooser_00005='+STR0535+CRLF/*//'Não foi encontrado. \n '*/		
cTexto += 'BscFileChooser_00006='+STR0536+CRLF/*//'Verifique o nome do arquivo.'*/		
cTexto += 'BscFileChooser_00007='+STR0537+CRLF/*//'BSC - Gravar arquivo...'*/		
cTexto += 'BscFileChooser_00008='+STR0538+CRLF/*//'BSC - Abrir arquivo...'*/		
cTexto += 'BscFileChooser_00009='+STR0539+CRLF/*//'Arquivo'*/		
cTexto += 'BscFileChooser_00010='+STR0540+CRLF/*//'Tamanho'*/		
cTexto += 'BscFileChooser_00011='+STR0541+CRLF/*//'Data'*/		
cTexto += 'BscFileChooser_00012='+STR0907+CRLF/*//'Gravar'*/		
cTexto += 'BscFileChooser_00013='+STR0543+CRLF/*//'Abrir'*/		
cTexto += 'BscFileChooser_00014='+STR0544+CRLF/*// 'Local'*/
cTexto += 'BscFileChooser_00015='+STR0545+CRLF/*// 'Nome do arquivo'*/
cTexto += 'BscFileChooser_00016='+STR0546+CRLF/*// 'Tipo do arquivo'*/
cTexto += 'BscFileChooser_00017='+STR0906+CRLF/*// 'Cancelar'*/
cTexto += 'BscFileChooser_00018='+STR0548+CRLF/*// 'Lista de arquivos.'*/

//Bsc DeskTop
cTexto += 'BscDesktopFrame_00001='+STR0933+CRLF/*//  'Configuração'*/
cTexto += 'BscDesktopFrame_00002='+STR0928+CRLF/*//  'Área de trabalho'*/
cTexto += 'BscDesktopFrame_00003='+STR0326+CRLF/*//  'Tipo de vizualização'*/
cTexto += 'BscDesktopFrame_00004='+STR0952+CRLF/*//  'Janela'*/
cTexto += 'BscDesktopFrame_00005='+STR0915+CRLF/*//  'Pasta'*/
cTexto += 'BscDesktopFrame_00006='+STR0928+CRLF/*//  'Área de trabalho'*/
cTexto += 'BscDesktopFrame_00007='+STR0330+CRLF/*//  'Organização'*/
cTexto += 'BscDesktopFrame_00008='+STR0957+CRLF/*//  'Usuários'*/

//BSC Agendador
cTexto += 'BscAgendadorFrame_00001='+STR0335+CRLF/*//  'Agendamentos'*/
cTexto += 'BscAgendadorFrame_00002='+STR0354+CRLF/*//  'Situação'*/
cTexto += 'BscAgendadorFrame_00003='+STR0355+CRLF/*//  'Iniciando ...'*/
cTexto += 'BscAgendadorFrame_00004='+STR0356+CRLF/*//  'Parando ...'*/
cTexto += 'BscAgendadorFrame_00005='+STR0357+CRLF/*//  'Executando ...'*/
cTexto += 'BscAgendadorFrame_00006='+STR0358+CRLF/*//  'Parado!'*/
cTexto += 'BscAgendadorFrame_00007='+STR0359+CRLF/*//  'Iniciar'*/
cTexto += 'BscAgendadorFrame_00008='+STR0360+CRLF/*//  'Parar'*/
cTexto += 'BscAgendadorFrame_00009='+STR0931+CRLF/*//  'Atualizar'*/
cTexto += 'BscAgendadorFrame_00010='+STR0413+CRLF/*//  'Agendador'*/

//BSC Configuracao de Servidor de email SMTP
cTexto += 'BscSMTPConfFrame_00001='+STR0336+CRLF/*//  'Servidor de email'*/
cTexto += 'BscSMTPConfFrame_00002='+STR0933+CRLF/*//  'Configuração' */
cTexto += 'BscSMTPConfFrame_00003='+STR0338+CRLF/*//  'Conta de email:'*/
cTexto += 'BscSMTPConfFrame_00004='+STR0339+CRLF/*//  'Servidor SMTP:'*/
cTexto += 'BscSMTPConfFrame_00005='+STR0340+CRLF/*//  'Porta SMTP:'*/
cTexto += 'BscSMTPConfFrame_00006='+STR0957+CRLF/*//  'Usuário:'*/
cTexto += 'BscSMTPConfFrame_00007='+STR0922+CRLF/*//  'Senha:'*/

//BSC Agendamento de processos
cTexto += 'BscAgendamentoFrame_00001='+STR0343+CRLF/*//  'Agenda'*/
cTexto += 'BscAgendamentoFrame_00002='+STR0911+CRLF/*//  'Nome:'*/
cTexto += 'BscAgendamentoFrame_00003='+STR0345+CRLF/*//  'Ação:'*/
cTexto += 'BscAgendamentoFrame_00004='+STR0942+CRLF/*//  'Elemento:'*/
cTexto += 'BscAgendamentoFrame_00005='+STR0347+CRLF/*//  'Comando a ser executado'*/
cTexto += 'BscAgendamentoFrame_00006='+STR0936+CRLF/*//  'Data Início:'*/
cTexto += 'BscAgendamentoFrame_00007='+STR0349+CRLF/*//  'Data Término:'*/
cTexto += 'BscAgendamentoFrame_00008='+STR0925+CRLF/*//  'Ambiente:'*/
cTexto += 'BscAgendamentoFrame_00009='+STR0351+CRLF/*//  'Executado em:'*/
cTexto += 'BscAgendamentoFrame_00010='+STR0352+CRLF/*//  'Agendador de Processos'*/
cTexto += 'BscAgendamentoFrame_00011='+STR0353+CRLF/*//  'Frequência:'*/   
cTexto += 'BscAgendamentoFrame_00012='+STR1081+CRLF//Tarefa  
cTexto += 'BscAgendamentoFrame_00013='+STR1082+CRLF//Agendar
cTexto += 'BscAgendamentoFrame_00014='+STR1083+CRLF//Detalhes 
cTexto += 'BscAgendamentoFrame_00015='+STR1084+CRLF//Data de Início:
cTexto += 'BscAgendamentoFrame_00016='+STR1085+CRLF//Data de Término:
cTexto += 'BscAgendamentoFrame_00017='+STR1086+CRLF//Diário
cTexto += 'BscAgendamentoFrame_00018='+STR1087+CRLF//Semanal
cTexto += 'BscAgendamentoFrame_00019='+STR1088+CRLF//Mensal
cTexto += 'BscAgendamentoFrame_00020='+STR1089+CRLF//Horário:
cTexto += 'BscAgendamentoFrame_00021='+STR1090+CRLF//Dia:
cTexto += 'BscAgendamentoFrame_00022='+STR1091+CRLF//Período
cTexto += 'BscAgendamentoFrame_00023='+STR1092+CRLF//Frequência   
cTexto += 'BscAgendamentoFrame_00024='+STR1093+CRLF//Última Execução
cTexto += 'BscAgendamentoFrame_00025='+STR1094+CRLF//Próxima Execução
cTexto += 'BscAgendamentoFrame_00026='+STR1095+CRLF//Data:

//BSC Mensagens
cTexto += 'BscMensagemFrame_00001='+STR0362+CRLF/*//  'Responder'*/
cTexto += 'BscMensagemFrame_00002='+STR0363+CRLF/*//  'Responder a todos'*/
cTexto += 'BscMensagemFrame_00003='+STR0364+CRLF/*//  'Encaminhar'*/
cTexto += 'BscMensagemFrame_00004='+STR0365+CRLF/*//  'Enviar'*/
cTexto += 'BscMensagemFrame_00005='+STR0906+CRLF/*//  'Cancelar'*/
cTexto += 'BscMensagemFrame_00006='+STR0367+CRLF/*//  'Mensagens'*/
cTexto += 'BscMensagemFrame_00007='+STR0910+CRLF/*//  'Mensagem'*/
cTexto += 'BscMensagemFrame_00008='+STR0369+CRLF/*//  'Para'*/
cTexto += 'BscMensagemFrame_00009='+STR0370+CRLF/*//  'CC'*/
cTexto += 'BscMensagemFrame_00010='+STR0371+CRLF/*//  'De:'*/
cTexto += 'BscMensagemFrame_00011='+STR0929+CRLF/*//  'Assunto:'*/
cTexto += 'BscMensagemFrame_00012='+STR0910+CRLF/*//  'Mensagem:'*/
cTexto += 'BscMensagemFrame_00013='+STR0374+CRLF/*//  'Prioridade:'*/
cTexto += 'BscMensagemFrame_00014='+STR0375+CRLF/*//  'Baixa'*/
cTexto += 'BscMensagemFrame_00015='+STR0376+CRLF/*//  'Média' */
cTexto += 'BscMensagemFrame_00016='+STR0377+CRLF/*//  'Alta'*/
cTexto += 'BscMensagemFrame_00017='+STR0378+CRLF/*//  'Anexo:'*/
cTexto += 'BscMensagemFrame_00018='+STR0379+CRLF/*//  'Itens Enviados'*/
cTexto += 'BscMensagemFrame_00019='+STR0380+CRLF/*//  'Itens Excluídos'*/
cTexto += 'BscMensagemFrame_00020='+STR0381+CRLF/*//  'Caixa de Entrada'*/
cTexto += 'BscMensagemFrame_00021='+STR0901+CRLF/*//  'Novo'*/
cTexto += 'BscMensagemFrame_00022='+STR0902+CRLF/*//  'Visualizar'*/
cTexto += 'BscMensagemFrame_00023='+STR0384+CRLF/*//  'Enviar/Receber'*/
cTexto += 'BscMensagemFrame_00024='+STR0543+CRLF/*//  'Abrir'*/
cTexto += 'BscMensagemFrame_00025='+STR0583+CRLF/*//  'Selecione o anexo para abrir.'*/
cTexto += 'BscMensagemFrame_00026='+STR0584+CRLF/*//  'Selecione um destinatário!'*/
cTexto += 'BscMensagemFrame_00027='+STR0321+CRLF/*//  'Deseja notificar as pessoas por email?'*/
cTexto += 'BscMensagemFrame_00028='+STR1109+CRLF/*//  "O remetente não foi selecionado."*/
cTexto += 'BscMensagemFrame_00029='+STR1110+CRLF/*//  "O campo assunto não foi preenchido."*/
cTexto += 'BscMensagemFrame_00030='+STR1111+CRLF/*//  "O campo mensagem não foi preenchido."*/

cTexto += 'BscDesdobramentoFrame_00001='+STR0393+CRLF/*//  'Desdobramento'*/
cTexto += 'BscDesdobramentoFrame_00002='+STR0944+CRLF/*//  'Estratégia:'*/
cTexto += 'BscDesdobramentoFrame_00003='+STR0395+CRLF/*//  'Origem'*/
cTexto += 'BscDesdobramentoFrame_00004='+STR0914+CRLF/*//  'Organização:'*/
cTexto += 'BscDesdobramentoFrame_00005='+STR0397+CRLF/*//  'Destino'*/
cTexto += 'BscDesdobramentoFrame_00006='+STR0955+CRLF/*//  'Tipo de link:'*/
cTexto += 'BscDesdobramentoFrame_00007='+STR0939+CRLF/*//  'Descrição:'*/
cTexto += 'BscDesdobramentoFrame_00008='+STR0939+CRLF/*//  'Desdobramentos'*/
cTexto += 'BscDesdobramentoFrame_00009='+STR0913+CRLF/*//  'Objetivo:'*/

cTexto += 'JBIHeadPanel_00001='+STR0914+CRLF/*//'Organização:'*/
cTexto += 'JBIHeadPanel_00002='+STR0945+CRLF/*//'Estratégia:'*/
cTexto += 'JBIHeadPanel_00003='+STR0917+CRLF/*//'Perspectiva:'*/
cTexto += 'JBIHeadPanel_00004='+STR0913+CRLF/*//'Objetivo:'*/
cTexto += 'JBIHeadPanel_00005='+STR0948+CRLF/*//'Indicador:'*/
cTexto += 'JBIHeadPanel_00006='+STR0951+CRLF/*//'Iniciativa:'*/
cTexto += 'JBIHeadPanel_00007='+STR0420+CRLF/*//'Tarefa:'*/
cTexto += 'JBIHeadPanel_00008='+STR0020+CRLF/*//'FCS:'*/

cTexto += 'BscAnaliseParceladaCardFrame_00001='+STR0424+CRLF/*//'Análise de Sistemas'*/
cTexto += 'BscAnaliseParceladaCardFrame_00002='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscAnaliseParceladaCardFrame_00003='+STR0906+CRLF/*//'Cancelar'*/  
cTexto += 'BscAnaliseParceladaCardFrame_00004='+STR1102+CRLF//"Análise Acumulada (Padrão)"
cTexto += 'BscAnaliseParceladaCardFrame_00005='+STR1103+CRLF//"Análise Parcelada"

cTexto += 'BscObjetivoCardFrame_00001='+STR0941+CRLF/*//'Drill Down'*/

cTexto += 'BscPerformanceCardFrame_00001='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscPerformanceCardFrame_00002='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscPerformanceCardFrame_00003='+STR0935+CRLF/*//'Data de Análise:'*/    
cTexto += 'BscPerformanceCardFrame_00004='+STR1104+CRLF//"Confirmação"

cTexto += 'BscTemaEstrategico_00001='+STR0572+CRLF/*//'Temas estratégicos'*/
cTexto += 'BscTemaEstrategico_00002='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscTemaEstrategico_00003='+STR0938+CRLF/*//'Descrição:'*/
cTexto += 'BscTemaEstrategico_00004='+STR0575+CRLF/*//'Lista de Objetivo'*/

cTexto += 'BscGrupoPessoaFrame_00001='+STR0435+CRLF/*//'Grupo de Pessoas'*/
cTexto += 'BscGrupoPessoaFrame_00002='+STR0436+CRLF/*//'Grupo'*/
cTexto += 'BscGrupoPessoaFrame_00003='+STR0919+CRLF/*//'Pessoas'*/
cTexto += 'BscGrupoPessoaFrame_00004='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscGrupoPessoaFrame_00005='+STR0938+CRLF/*//'Descrição:'*/

cTexto += 'JBIMultiSelectionDialog_00001='+STR0914+CRLF/*//'Organização:'*/
cTexto += 'JBIMultiSelectionDialog_00002='+STR0441+CRLF/*//'Grupos:'*/
cTexto += 'JBIMultiSelectionDialog_00003='+STR0442+CRLF/*//'Pessoas:'*/
cTexto += 'JBIMultiSelectionDialog_00004='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'JBIMultiSelectionDialog_00005='+STR0444+CRLF/*//'Adiciona'*/

cTexto += 'BscDrillObjetivo_00001='+STR0024+CRLF/*//'Efeito:'*/
cTexto += 'BscDrillObjetivo_00002='+STR0025+CRLF/*//'Causa:'*/
cTexto += 'BscDrillObjetivo_00003='+STR0127+CRLF/*//'Navega\u00e7\u00e3o em janelas separadas'*/
cTexto += 'BscDrillObjetivo_00004='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscDrillObjetivo_00005='+STR0147+CRLF/*//'Mapa Estratégico'*/
cTexto += 'BscDrillObjetivo_00006='+STR0939+CRLF/*//'Desdobramentos'*/
cTexto += 'BscDrillObjetivo_00007='+STR0958+CRLF/*//'Dados de Análise:'*/
cTexto += 'BscDrillObjetivo_00008='+STR0926+CRLF/*//'Análise:'*/
cTexto += 'BscDrillObjetivo_00009='+STR0912+CRLF/*//'Objetivo'*/
cTexto += 'BscDrillObjetivo_00010='+STR0002+CRLF/*//'Objetivos Desdobrados'*/

cTexto += 'BscFcsFrame_00001='+STR0003+CRLF/*//'Fator Crítico de Sucesso'*/
cTexto += 'BscFcsFrame_00002='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscFcsFrame_00003='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscFcsFrame_00004='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscFcsFrame_00005='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscFcsFrame_00006='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscFcsFrame_00007='+STR0116+CRLF/*//'Descrição:'*/
cTexto += 'BscFcsFrame_00008='+STR0004+CRLF/*//'% Atendimento:'*/
cTexto += 'BscFcsFrame_00009='+STR0949+CRLF/*//'Indicadores'*/
cTexto += 'BscFcsFrame_00010='+STR0006+CRLF/*//'Processos'*/
cTexto += 'BscFcsFrame_00011='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscFcsFrame_00012='+STR0019+CRLF/*//'Indicador de FCS'*/

cTexto += 'BscProcessoFrame_00001='+STR0037+CRLF/*//'Processo'*/
cTexto += 'BscProcessoFrame_00002='+STR0116+CRLF/*//'Descrição:'*/
cTexto += 'BscProcessoFrame_00003='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscProcessoFrame_00004='+STR0027+CRLF/*//'Fluxo do Processo'*/

cTexto += 'BscFluxoFrame_00001='+STR0027+CRLF/*//'Fluxo do Processo'*/
cTexto += 'BscFluxoFrame_00002='+STR0116+CRLF/*//'Descrição:'*/
cTexto += 'BscFluxoFrame_00003='+STR0026+CRLF/*//'Seqüencia'*/
cTexto += 'BscFluxoFrame_00004='+STR0921+CRLF/*//'Responsável:'*/

cTexto += 'BscRelEvolFrame_00001='+STR0903+CRLF/*//'Editar'*/
cTexto += 'BscRelEvolFrame_00002='+STR0911+CRLF/*//'Nome:'*/
cTexto += 'BscRelEvolFrame_00003='+STR0902+CRLF/*//'Visualizar'*/
cTexto += 'BscRelEvolFrame_00004='+STR0907+CRLF/*//'Gravar'*/
cTexto += 'BscRelEvolFrame_00005='+STR0188+CRLF/*//'Incluir descri\u00e7\u00e3o no relat\u00f3rio'*/
cTexto += 'BscRelEvolFrame_00006='+STR0904+CRLF/*//'Excluir'*/
cTexto += 'BscRelEvolFrame_00007='+STR0906+CRLF/*//'Cancelar'*/
cTexto += 'BscRelEvolFrame_00008='+STR0947+CRLF/*//'Gerar'*/
cTexto += 'BscRelEvolFrame_00009='+STR0181+CRLF/*//'Relatório de Evolução de Indicadores'*/
cTexto += 'BscRelEvolFrame_00010='+STR0116+CRLF/*//'Descri\u00e7\u00e3o:'*/
cTexto += 'BscRelEvolFrame_00011='+STR0931+CRLF/*//'Atualizar'*/
cTexto += 'BscRelEvolFrame_00012='+STR0182+CRLF/*//'Imprimir planilha de Referência'*/
cTexto += 'BscRelEvolFrame_00013='+STR0371+CRLF/*//'De:'*/
cTexto += 'BscRelEvolFrame_00014='+STR0917+CRLF/*//'Perspectiva:'*/
cTexto += 'BscRelEvolFrame_00015='+STR0913+CRLF/*//'Objetivo:'*/
cTexto += 'BscRelEvolFrame_00016='+STR0948+CRLF/*//'Indicador:'*/
cTexto += 'BscRelEvolFrame_00017='+STR0930+CRLF/*//'até'*/

cTexto += 'BscRelEvolFrame_00018='+STR1071+CRLF/*//'Ordem de Objetivos:'*/
cTexto += 'BscRelEvolFrame_00019='+STR1072+CRLF/*//'Ordem de Indicadores:'*/

cTexto += 'BscMapaOvalFrame_00001='+STR0992+CRLF/*//'Mapa Estratégico Modelo 2'*/
cTexto += 'BscMapaOvalFrame_00002='+STR0156+CRLF/*//'Imprimir'*/
cTexto += 'BscMapaOvalFrame_00003='+STR0953+CRLF/*//'Exportar'*/
cTexto += 'BscMapaOvalFrame_00004='+STR0543+CRLF/*//'Abrir'*/ 
cTexto += 'BscMapaOvalFrame_00005='+STR0926+CRLF/*//'Analise'*/ 
cTexto += 'BscMapaOvalFrame_00006='+STR1024+CRLF/*//'Parcelada'*/ 
cTexto += 'BscMapaOvalFrame_00007='+STR1025+CRLF/*//'Acumulada'*/ 

cTexto += 'BscPerspectivaOval_00001='+STR0993+CRLF/*//'Cor de fundo'*/
cTexto += 'BscPerspectivaOval_00002='+STR0994+CRLF/*//'Degrade'*/
cTexto += 'BscPerspectivaOval_00003='+STR1010+CRLF/*//'Cor'*/
cTexto += 'BscPerspectivaOval_00004='+STR1011+CRLF/*//'Fonte'*/
cTexto += 'BscPerspectivaOval_00005='+STR1023+CRLF/*//Titulo'*/

cTexto += 'BscPerspectiva_DDFrame_00001='+STR0995+CRLF/*//'Perspectiva detalhe'*/

cTexto += 'BscIndicadorDetalheFrame_00001='+STR0996+CRLF/*//' "Detalhes do Indicador"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00002='+STR0997+CRLF/*//' "Tipo:"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00003='+STR0998+CRLF/*//' "Cor:"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00004='+STR0999+CRLF/*//' "Gráfico"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00005='+STR0913+CRLF/*//' "Objetivo"	'*/ 
cTexto += 'BscIndicadorDetalheFrame_00006='+STR1000+CRLF/*//' "Iniciativas (plano de ações)"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00007='+STR1001+CRLF/*//' "Coluna"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00008='+STR1002+CRLF/*//' "Coluna 3D"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00009='+STR1003+CRLF/*//' "Linha"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00010='+STR1004+CRLF/*//' "Linha 3D"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00011='+STR1005+CRLF/*//' "Pizza"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00012='+STR1006+CRLF/*//' "Pizza 3D"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00013='+STR1007+CRLF/*//' "Valores"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00014='+STR1008+CRLF/*//' "Período"'*/ 
cTexto += 'BscIndicadorDetalheFrame_00015='+STR1009+CRLF/*//' "Período"'*/ 

cTexto += 'JBIFontChooser_00001='+STR1012+CRLF/*//'"Normal"'*/ 
cTexto += 'JBIFontChooser_00002='+STR1013+CRLF/*//'"Negrito"'*/
cTexto += 'JBIFontChooser_00003='+STR1014+CRLF/*//'"Itálico"'*/
cTexto += 'JBIFontChooser_00004='+STR1015+CRLF/*//'"Negrito Itálico"'*/
cTexto += 'JBIFontChooser_00005='+STR1016+CRLF/*//'"Seleção de Fontes"'*/
cTexto += 'JBIFontChooser_00006='+STR1017+CRLF/*//'"Fonte:"'*/
cTexto += 'JBIFontChooser_00007='+STR1018+CRLF/*//'"Estilo:"'*/
cTexto += 'JBIFontChooser_00008='+STR1019+CRLF/*//'"Tamanho:"'*/
cTexto += 'JBIFontChooser_00009='+STR1020+CRLF/*//'"Modelo"'*/
cTexto += 'JBIFontChooser_00010='+STR0906+CRLF/*//'"Cancelar"'*/

cTexto += 'BscMapaObjetivoOval_00001='+STR1021+CRLF/*//'Cor da fonte'*/
cTexto += 'BscMapaObjetivoOval_00002='+STR1022+CRLF/*//'Tipo da fonte'*/

cTexto += 'BIProgressBar_00001='+STR1044+CRLF/*//'"Número de tentativas de conexão excedido"'*/

cTexto += 'BscEstruturaImport_00001='+STR1045+CRLF/*//'"Importar"'*/
cTexto += 'BscEstruturaImport_00002='+STR1046+CRLF/*//'"Estrutura"'*/
cTexto += 'BscEstruturaImport_00003='+STR1047+CRLF/*//'"Logs"'*/
cTexto += 'BscEstruturaImport_00004='+STR1048+CRLF/*//'"Arquivo:"'*/
cTexto += 'BscEstruturaImport_00005='+STR1049+CRLF/*//'"Detalhes"'*/
cTexto += 'BscEstruturaImport_00006='+STR1050+CRLF/*//'"Mensagem"'*/
cTexto += 'BscEstruturaImport_00007='+STR1051+CRLF/*//'"Tamanho do Arquivo:"'*/
cTexto += 'BscEstruturaImport_00008='+STR1052+CRLF/*//'"Data de Modificação:"'*/
cTexto += 'BscEstruturaImport_00009='+STR1053+CRLF/*//'"Aguarde... Realizando a importação"'*/
cTexto += 'BscEstruturaImport_00010='+STR1054+CRLF/*//'"Selecione um arquivo com uma estrutura válida e pressione o botão importar"'*/
cTexto += 'BscEstruturaImport_00011='+STR1055+CRLF/*//'"Aguarde... Parando a importação"'*/
cTexto += 'BscEstruturaImport_00012='+STR1056+CRLF/*//'"Não existem estruturas exportadas"'*/
cTexto += 'BscEstruturaImport_00013='+STR1057+CRLF/*//'"Cancelar"'*/

cTexto += 'BscEstruturaExport_00001='+STR1058+CRLF/*//'"Exportar"'*/
cTexto += 'BscEstruturaExport_00002='+STR1059+CRLF/*//'"Estrutura"'*/
cTexto += 'BscEstruturaExport_00003='+STR1060+CRLF/*//'"Logs"'*/
cTexto += 'BscEstruturaExport_00004='+STR1061+CRLF/*//'"Organização:"'*/
cTexto += 'BscEstruturaExport_00005='+STR1062+CRLF/*//'"Detalhes"'*/
cTexto += 'BscEstruturaExport_00006='+STR1063+CRLF/*//'"Mensagem"'*/
cTexto += 'BscEstruturaExport_00007='+STR1064+CRLF/*//'"Arquivo:"'*/
cTexto += 'BscEstruturaExport_00008='+STR1065+CRLF/*//'"Campo nome do arquivo obrigatório"'*/
cTexto += 'BscEstruturaExport_00009='+STR1066+CRLF/*//'"Aguarde... Realizando a exportação"'*/
cTexto += 'BscEstruturaExport_00010='+STR1067+CRLF/*//'"Selecione uma organização válida e pressione o botão exportar"'*/
cTexto += 'BscEstruturaExport_00011='+STR1068+CRLF/*//'"Aguarde... Parando a exportação"'*/
cTexto += 'BscEstruturaExport_00012='+STR1069+CRLF/*//'"Não existem organizações cadastradas"'*/
cTexto += 'BscEstruturaExport_00013='+STR1070+CRLF/*//'"Cancelar"'*/

cTexto += 'BscValidateFields_00001='+STR1076+CRLF/*//'"Existem campos obrigatórios não preenchidos."'*/
                 
cTexto += 'JBIMessagePanel_00001='+STR1096+CRLF//"Novo"  
cTexto += 'JBIMessagePanel_00002='+STR1097+CRLF//"Responder" 
cTexto += 'JBIMessagePanel_00003='+STR1098+CRLF//"Responder a todos"
cTexto += 'JBIMessagePanel_00004='+STR1099+CRLF//"Encaminhar"    
cTexto += 'JBIMessagePanel_00005='+STR1100+CRLF//"Visualizar"
cTexto += 'JBIMessagePanel_00006='+STR1101+CRLF//"Enviar/Receber"
        
return cTexto
