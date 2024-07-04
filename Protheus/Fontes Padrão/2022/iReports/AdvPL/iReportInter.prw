// ######################################################################################
// Projeto: IReport
// Modulo : Core
// Fonte  : IReportInternational - Contem a tradução do applet Java.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 23.11.06 | 1776 - Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "IReportDefs.ch"
#include "iRep_inter.ch"
#include "Protheus.ch"	

function cIR_International()
	local cTexto := ""

	//Textos Padroes, Nesta sessao devem ser usada para criar mensagens que podem ser
	//utilizadas em varias telas do sistema. Como por exemplo Sim, Nao, Nome, Ok, Cancelar
	cTexto += 'IR_Shared_00001=' +STR0010+CRLF//"OK"
	cTexto += 'IR_Shared_00002=' +STR0011+CRLF//"Cancelar"
	cTexto += 'IR_Shared_00003=' +STR0012+CRLF//"Sim"
	cTexto += 'IR_Shared_00004=' +STR0013+CRLF//"Não"
	cTexto += 'IR_Shared_00005=' +STR0014+CRLF//"Repetir"	
	
	//Textos para o Core
	cTexto += 'IR_Core_00001='+STR0001+CRLF	//Gerador de Relatórios iReport    
	//WizardController	
	cTexto += 'WizardController_00001=' +STR0019+CRLF// "Bem Vindo"  
	cTexto += 'WizardController_00002=' +STR0015+CRLF// "Seleção de tabelas"  
	cTexto += 'WizardController_00003=' +STR0016+CRLF// "Relacionamentos"  
	cTexto += 'WizardController_00004=' +STR0017+CRLF// "Seleção de campos"  
	cTexto += 'WizardController_00005=' +STR0018+CRLF// "Modelo"  
	//SelectionPanel
	cTexto += 'SelectionPanel_00001=' +STR0020+CRLF// "Disponíveis"  
	cTexto += 'SelectionPanel_00002=' +STR0021+CRLF// "Selecionados"  
	cTexto += 'SelectionPanel_00003=' +STR0022+CRLF// "Localizar:"  
	//TableRel
	cTexto += 'TableRel_00001=' +STR0023+CRLF// "Localizar..."  
	//WizardFrame
	cTexto += 'WizardFrame_00001=' +STR0024+CRLF// "Anterior"  
	cTexto += 'WizardFrame_00002=' +STR0025+CRLF// "Próximo"  
	cTexto += 'WizardFrame_00003=' +STR0011+CRLF// "Cancelar"  			
	cTexto += 'WizardFrame_00004=' +STR0026+CRLF// "Finalizar"  

	//pnlModelConnection
	cTexto += 'pnlModelConnection_00001=' +STR0027+CRLF// "Tratar campo filial."  
	cTexto += 'pnlModelConnection_00002=' +STR0028+CRLF// "Tratar campo excluído(D_E_L_E_T_E_D)."  
	cTexto += 'pnlModelConnection_00003=' +STR0029+CRLF// "Opções"
	cTexto += 'pnlModelConnection_00004=' +STR0030+CRLF// "Selecione o modelo do relatório"
	cTexto += 'pnlModelConnection_00005=' +STR0031+CRLF// "Modelo de coluna"
	cTexto += 'pnlModelConnection_00006=' +STR0032+CRLF// "Modelo de linha"

	//pnlSelectField
	cTexto += 'pnlSelectField_00001=' +STR0033+CRLF// "Tabela"
	cTexto += 'pnlSelectField_00002=' +STR0034+CRLF// "Campos disponíveis"
	cTexto += 'pnlSelectField_00003=' +STR0035+CRLF// "Campos selecionados"
	cTexto += 'pnlSelectField_00005=' +STR0037+CRLF// "Para prosseguir, é necessário selecionar um ou mais campos."
	cTexto += 'pnlSelectField_00006=' +STR0038+CRLF// "Validação de etapa."
	
	//PnlSelectRelation
	cTexto += 'pnlSelectRelation_00001=' +STR0039+CRLF//  "Aguarde. Carregando os campos da tabela "
	cTexto += 'pnlSelectRelation_00002=' +STR0040+CRLF//  "Aguarde. Carregando os relacionamentos."  
	cTexto += 'pnlSelectRelation_00003=' +STR0041+CRLF//  "Deselecionar"  
	cTexto += 'pnlSelectRelation_00004=' +STR0042 +CRLF// "Selecionar"
	cTexto += 'pnlSelectRelation_00005=' +STR0009 +CRLF// "Excluir"
	
	//pnlSelectTable
	cTexto += 'pnlSelectTable_00001=' +STR0036 +CRLF// "Tabelas disponíveis"
	cTexto += 'pnlSelectTable_00002=' +STR0043 +CRLF//"Tabelas selecionadas"
	cTexto += 'pnlSelectTable_00003=' +STR0044 +CRLF// "Para prosseguir, é necessário selecionar uma ou mais tabelas."
	cTexto += 'pnlSelectTable_00004=' +STR0038 +CRLF// "validacao de etapa."
	cTexto += 'pnlSelectTable_00005=' +STR0045 +CRLF// "Aguarde. Carregando as tabelas do sistema."
return cTexto             

/*
*Nome do arquivo de internacionalizacao
*/
function cIR_IntName()
return INTER_FILE_NAME      

/**
*Extensao do arquivo de internacionalizacao
**/
function cIR_Location()
return IREP_LOCATION