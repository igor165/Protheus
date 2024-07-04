#ifdef SPANISH
	#define STR0001 "Contabilización Off line del ingreso"
	#define STR0002 "Este programa tiene como objetivo crear movimiento contable de ingreso."
	#define STR0003 "Inclusión, Baja y Anulación de la baja"
	#define STR0004 "Espere"
	#define STR0005 "Procesando..."
	#define STR0006 "Generando contabilización de ingresos"
	#define STR0007 "Atención"
	#define STR0008 "No se seleccionaron las sucursales que se procesarán"
	#define STR0009 "Movimiento generado."
	#define STR0010 "Para verificar, acceda al módulo contable."
	#define STR0011 "¡Ningún registro encontrado o asiento contable inconsistente!"
	#define STR0012 "Para contabilizar es necesario crear los siguientes asientos estandarizados: "
	#define STR0013 "Espere, preparando datos..."
	#define STR0014 "Lote ["
	#define STR0015 "] Familia ["
	#define STR0016 "Seleccione las Empresas que se Actualizarán"
	#define STR0017 "No existen bases para consultar"
	#define STR0018 "Grupo Emp"
	#define STR0019 "Descripción"
	#define STR0020 "Código"
	#define STR0021 "Empresa"
	#define STR0022 "Unidad"
	#define STR0023 "Sucursal"
	#define STR0024 "recno"
	#define STR0025 "Marca/Desmarca"
	#define STR0026 " Error en el procesamiento  "
	#define STR0027 " Error en el proceso de contabilidad"
	#define STR0029 "Error en el procesamiento"
	#define STR0030 "Ocurrieron inconsistencias en el proceso. ¿Desea imprimir el informe de errores?"
	#define STR0031 'Procesando movimiento...'
	#define STR0032 'Leyendo registros [ '
	#define STR0033 ' Registro: '
	#define STR0034 ' - Error: ['
	#define STR0035 '¡Es necesario informar el mes y año!'
	#define STR0036 'ErroBlock - Clave: '
	#define STR0037 ' - Estatus: '
	#define STR0038 'Stack: '
	#define STR0039 ' ErroBlock: '
	#define STR0040 'Clave: '
	#define STR0041 'No se encontró valor'
	#define STR0042 'Generó excepción - verifique en la carpeta logpls [ '
	#define STR0043 "Descripción"
	#define STR0044 "starting: "
	#define STR0045 "finished: "
	#define STR0046 'BFQ Desactivado - '
	#define STR0047 'Verificando procesos - ['
	#define STR0048 'Lote no encontrado - clave [PLSREC]'
	#define STR0049 '¡Existe otro proceso que se está ejecutando, por favor, espere!'
	#define STR0050 '¡Imposible crear sesión de control de thRead!'
	#define STR0051 'Movim. de ['
	#define STR0052 '- Composición de la Cob.'
	#define STR0053 '- Baja y Anulación. (Mov. Banco)'
	#define STR0054 '- Baja y Anulación. (No Mov. Banco)'
	#define STR0055 'Mes'
	#define STR0056 'Año vigencia'
	#define STR0057 'Opciones'
	#define STR0058 '¿Agrupa Asiento Contable?'
	#define STR0059 '¿Considera sucursal compartida?'
	#define STR0060 '¿Proceso distribuido Multi Thread?'
	#define STR0061 '¿Baja por la fecha de disponibilidad?'
	#define STR0062 '¿Contabilizar?'
	#define STR0063 '¡Informe el mes!'
	#define STR0064 '¡Informe el año!'
	#define STR0065 '- Facturación anticipada (Rev/Prov).'
	#define STR0066 'De cliente:'
	#define STR0067 'A cliente:'
	#define STR0068 'Finalizando...'
	#define STR0069 "¡Proceso finalizado!"
	#define STR0070 'Procesamiento'
	#define STR0071 'Normal.'
	#define STR0072 'Multi Thread.'
	#define STR0073 'Grid.'
	#define STR0074 'Informe la fecha inicial'
	#define STR0075 'Informe la fecha final'
	#define STR0076 'Fecha inicial'
	#define STR0077 'Fecha final'
	#define STR0078 '- Lote de aviso.'
	#define STR0079 '- Lote de Aviso - Cobrado.'
	#define STR0080 'Solapa ['
	#define STR0081 '] Lote ['
#else
	#ifdef ENGLISH
		#define STR0001 "Revenue off-line accounting"
		#define STR0002 "This program aims at creating the revenue accounting transaction"
		#define STR0003 "Addition, Write-off and cancellation of write-off"
		#define STR0004 "Wait"
		#define STR0005 "Processing..."
		#define STR0006 "Generating Revenue Accounting"
		#define STR0007 "Attention"
		#define STR0008 "Branches to be selected were not informed"
		#define STR0009 "Generated transaction!"
		#define STR0010 "To check it, access the accounting module."
		#define STR0011 "No record found or accounting entry is inconsistent."
		#define STR0012 "You must create the following standard entries to account: "
		#define STR0013 "Wait, preparing data..."
		#define STR0014 "Batch ["
		#define STR0015 "] Family ["
		#define STR0016 "Choose companies to be updated"
		#define STR0017 "There are no banks to be queried"
		#define STR0018 "Comp Group"
		#define STR0019 "Description"
		#define STR0020 "Code"
		#define STR0021 "Company"
		#define STR0022 "Unit"
		#define STR0023 "Branch"
		#define STR0024 "Ackn:"
		#define STR0025 "Select/Clear"
		#define STR0026 " Error in the Processing  "
		#define STR0027 " Error in the accounting process"
		#define STR0029 "Error in the Processing"
		#define STR0030 "There were inconsistencies in the process. Do you want to print error report?"
		#define STR0031 'Processing transaction'
		#define STR0032 'Reading record [ '
		#define STR0033 ' Record: '
		#define STR0034 ' - Error: ['
		#define STR0035 'Enter month and year'
		#define STR0036 'ErroBlock - Key: '
		#define STR0037 ' - Status : '
		#define STR0038 'Stack: '
		#define STR0039 ' ErroBlock: '
		#define STR0040 'Key: '
		#define STR0041 'Value not found'
		#define STR0042 'Generated exception - check in folder logpls [ '
		#define STR0043 "Description"
		#define STR0044 "starting: "
		#define STR0045 "finished: "
		#define STR0046 'Deactivated BFQ - '
		#define STR0047 'Checking processes - ['
		#define STR0048 'Batch not found - key [PLSREC]'
		#define STR0049 'There is other process being run, please, wait!'
		#define STR0050 'Creating a thRead control session is not possible!'
		#define STR0051 'Mov. From ['
		#define STR0052 '- Coll. Composition'
		#define STR0053 ' - Posting Payment and Cancellation. (Bank Transaction)'
		#define STR0054 ' - Posting Payment and Cancellation. (Not Bank Transaction)'
		#define STR0055 'Month.'
		#define STR0056 'Competence Year.'
		#define STR0057 'Options'
		#define STR0058 'Group Ledger Entry?'
		#define STR0059 'Consider Shared Branch?'
		#define STR0060 'Multi Thread Distributed Process?'
		#define STR0061 'Post by date of availability?'
		#define STR0062 'Account?'
		#define STR0063 'Enter month!'
		#define STR0064 'Enter year!'
		#define STR0065 '- Early Billing (Rev/Prov).'
		#define STR0066 'From Customer'
		#define STR0067 'To Customer'
		#define STR0068 'Finishing...'
		#define STR0069 "Process completed!"
		#define STR0070 'Processing'
		#define STR0071 'Normal.'
		#define STR0072 'Multi Thread.'
		#define STR0073 'Grid.'
		#define STR0074 'Enter start date'
		#define STR0075 'Enter end date'
		#define STR0076 'Start Date'
		#define STR0077 'End Date'
		#define STR0078 '- Warning Batch.'
		#define STR0079 '- Warning Batch - Collected.'
		#define STR0080 'Form ['
		#define STR0081 '] Batch ['
	#else
		#define STR0001 "Contabilização Off-line de Receita"
		#define STR0002 "Este programa tem como objectivo criar movimento contábil de Receita."
		#define STR0003 "Inclusão, Baixa e Cancelamento de Baixa"
		#define STR0004 "Aguarde"
		#define STR0005 "Processando..."
		#define STR0006 "Gerando Contabilização de Receitas"
		#define STR0007 "Atenção"
		#define STR0008 "Não foram selecionadas as filiais a serem processadas"
		#define STR0009 "Movimento gerado!"
		#define STR0010 "Para conferir, acesse o modulo contábil."
		#define STR0011 "Nenhum registro encontrado ou lançamento contábil inconsistente!"
		#define STR0012 "Para contabilizar é necessário criar os seguintes Lançamentos Padronizados: "
		#define STR0013 "Aguarde, preparando dados..."
		#define STR0014 "Lote ["
		#define STR0015 "] Familia ["
		#define STR0016 "Escolha a(s) Empresa(s) que será(ão) Atualizada(s)"
		#define STR0017 "Nao existe bancos a consultar"
		#define STR0018 "Grupo Emp"
		#define STR0019 "Descricao"
		#define STR0020 "Codigo"
		#define STR0021 "Empresa"
		#define STR0022 "Unidade"
		#define STR0023 "Filial"
		#define STR0024 "recno"
		#define STR0025 "Marca/Desmarca"
		#define STR0026 " Erro no processamento  "
		#define STR0027 " Erro no processo de contabilização"
		#define STR0029 "Erro no Processamento"
		#define STR0030 "Ocorreram inconsistencia no processo, deseja imprimir o relatorio de erros?"
		#define STR0031 'Processando Movimento...'
		#define STR0032 'Lendo registro [ '
		#define STR0033 ' Registro: '
		#define STR0034 ' - Erro: ['
		#define STR0035 'Necessário informar o mês e ano!'
		#define STR0036 'ErroBlock - Chave: '
		#define STR0037 ' - Status: '
		#define STR0038 'Stack: '
		#define STR0039 ' ErroBlock: '
		#define STR0040 'Chave: '
		#define STR0041 'Não encontrou valor'
		#define STR0042 'Gerou exceção - verifique na pasta logpls [ '
		#define STR0043 "Descrição"
		#define STR0044 "starting: "
		#define STR0045 "finished: "
		#define STR0046 'BFQ Desativado - '
		#define STR0047 'Verificando processos - ['
		#define STR0048 'Lote não encontrado - chave [PLSREC]'
		#define STR0049 'Existe outro processo sendo executado, por favor, aguarde!'
		#define STR0050 'Impossível criar sessão de controle de thRead!'
		#define STR0051 ' Movim. de ['
		#define STR0052 ' - Composição da Cob.'
		#define STR0053 ' - Baixa e Cancelamento. (Mov. Banco)'
		#define STR0054 ' - Baixa e Cancelamento. (Não Mov. Banco)'
		#define STR0055 'Mês.'
		#define STR0056 'Ano Competência.'
		#define STR0057 'Opções'
		#define STR0058 'Aglutina Lançamento Contabíl?'
		#define STR0059 'Considera Filial Compartilhada?'
		#define STR0060 'Processo Distribuido Multi Thread?'
		#define STR0061 'Baixa pela data da Disponibilidade?'
		#define STR0062 'Contabilizar?'
		#define STR0063 'Informe o Mês!'
		#define STR0064 'Informe o Ano!'
		#define STR0065 ' - Faturamento Antecipado (Rev/Prov).'
		#define STR0066 'Cliente De.'
		#define STR0067 'Cliente Até.'
		#define STR0068 'Finalizando...'
		#define STR0069 "Processo concluido!"
		#define STR0070 'Processamento'
		#define STR0071 'Normal.'
		#define STR0072 'Multi Thread.'
		#define STR0073 'Grid.'
		#define STR0074 'Informe a Data Inicio!'
		#define STR0075 'Informe a Data Fim!'
		#define STR0076 'Data Inicio'
		#define STR0077 'Data Fim'
		#define STR0078 ' - Lote de Aviso.'
		#define STR0079 ' - Lote de Aviso - Cobrado.'
		#define STR0080 ' Guia [ '
		#define STR0081 ' ] Lote [ '
	#endif
#endif
