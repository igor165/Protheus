#Include 'Protheus.ch'

//JOB de Processamento de Tabelas de Valores
Function PLSR707JB(aJob)
 
Private cCodEmp  := aJob[1]
Private cCodFil  := aJob[2]

RpcSetEnv( cCodEmp, cCodFil ,,,'PLS',, )

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Inicio da execucao da tarefa de JOB PLSR707B - Relatorio de Exames Elegiveis RDA" , 0, 0, {})

PLSR707()

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Fim da execucao da tarefa de JOB PLSR707JB" , 0, 0, {})

Return