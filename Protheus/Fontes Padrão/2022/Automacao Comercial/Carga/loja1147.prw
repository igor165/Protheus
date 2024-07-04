#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1147() ; Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadMakerProgress

Classe que representa o progresso da geração de carga.

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Class LJCInitialLoadMakerProgress
	Data nStatus
	Data aTables
	Data nActualTable
	Data nTotalRecords
	Data nActualRecord
	Data nRecordsPerSecond

	Method New()
EndClass


//--------------------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor

@param nStatus Status do progresso, sendo:
	1 - Iniciado 
	2 - Exportando
	3 - Compactando 
	4 - Finalizado 
@param aTables Lista das tabelas que estão sendo geradas.
@param nActualTable índice da tabela sendo processada.     
@param nTotalRecords Total de registros gerados.  
@param nActualRecord Número do registro atual. .   
@param nRecordsPerSeconds Taxa de registros/segundo sendo gerados.

 
@return Self

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method New( nStatus, aTables, nActualTable, nTotalRecords, nActualRecord, nRecordsPerSecond ) Class LJCInitialLoadMakerProgress
	Self:nStatus := nStatus
	Self:aTables := aTables
	Self:nActualTable := nActualTable
	Self:nTotalRecords := nTotalRecords
	Self:nActualRecord := nActualRecord
	Self:nRecordsPerSecond := nRecordsPerSecond
Return