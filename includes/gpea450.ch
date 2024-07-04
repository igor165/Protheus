#ifdef SPANISH
	#define STR0001 "Esta rutina genera la infomación de la Trayectoria laboral"
	#define STR0002 " de empleados en un determinado período"
	#define STR0003 "Actualización archivo SUA"
	#define STR0004 "Código del registro patronal no fue informado"
	#define STR0005 "Código de IMSS no fue informado"
	#define STR0006 "Código de CURP no fue informado"
	#define STR0007 "Fecha de crédito Infonavit no fue informada"
	#define STR0008 "Tipo de Infonavit no fue informado"
	#define STR0009 "Existe una secuencia no válida de los tipos de movimiento"
	#define STR0010 "Fechas duplicadas en la trayectoria laboral"
	#define STR0011 "Atención"
	#define STR0012 "¿Confirma la configuración de los parámetros?"
	#define STR0013 "Ocurrieron inconsistencias durante el proceso. ¿Desea consultar el LOG?"
	#define STR0014 "Log de ocurrencias"
	#define STR0015 "Empleados grabados"
	#define STR0016 "Espere..."
	#define STR0017 "Atención"
	#define STR0018 "Confirma la configuración de parámetros"
	#define STR0019 "Valor de descuento Infonavit no válido"
	#define STR0020 "Tipo de empleado no fue informado"
	#define STR0021 "Tipo de sueldo no fue informado"
	#define STR0022 "Tipo de jornada no fue informado"
	#define STR0023 "Empleado con valor de descuento Infonavit y con fecha de suspensión anterior al bimestre"
	#define STR0024 "Nombre del empleado tiene caracteres especiales"
	#define STR0025 "Apellido paterno no puede quedar en blanco"
	#define STR0026 "Código de IMSS debe contener solamente números"
	#define STR0027 "El digito verificador del código de IMSS no coincide"
	#define STR0028 "Sueldo integrado inferior a Sueldo mínimo integrado"
	#define STR0029 "Empleado no tiene Ingreso para el Registro Patronal seleccionado"
	#define STR0030 "Cálculo de SUA"
	#define STR0031 "Esta rutina ejecuta los cálculos necesarios para cargar las tablas del SUA"
	#define STR0032 "Tomando como base la Trayectoria laboral, el Historial de crédito Infonavit"
	#define STR0033 "Procesando..."
	#define STR0034 "El mes debe estar entre 1 y 12"
	#define STR0035 "El año debe ser superior a 1900"
	#define STR0036 "Debe seleccionarse al menos 1 Registro Patronal"
	#define STR0037 "Proceso parado debido a errores generados  en la limpieza de las tablas. Verifique los errores"
	#define STR0038 "Seleccionando movimiento para el SUA"
	#define STR0039 "Inicio de la generación del movimiento para el SUA"
	#define STR0040 "Error: no se encontró salario anterior del empleado "
	#define STR0041 "Y el movimiento NO se generó"
	#define STR0042 "Generando movimientos para el SUA"
	#define STR0043 "¡Proceso finalizado! Los registros no se encontraron"
	#define STR0044 "Proceso finalizado, con errores generados"
	#define STR0045 "Proceso finalizado con éxito"
	#define STR0046 " Empleado y "
	#define STR0047 " Movimientos generados para el SUA"
	#define STR0048 "no existe."
	#define STR0049 "Error: puesto no encontrado"
	#define STR0050 " para el empleado:"
	#define STR0051 "Generando salario diario anterior..."
	#define STR0052 "No existen registros para Salarios (RCP) anteriores al período."
	#define STR0053 "Generando salario diario anterior..."
	#define STR0054 "Seleccionando Faltas e Incapacidades..."
	#define STR0055 "Generando faltas e incapacidades..."
	#define STR0056 "Seleccionando movimientos de Infonavit..."
	#define STR0057 "Generando movimientos de Infonavit..."
	#define STR0058 "Generando movimientos para el SUA..."
	#define STR0059 "Generando movimientos para el SUA..."
	#define STR0060 "Limpiando tablas de movimiento para el SUA"
	#define STR0061 "Limpiando tablas de empleados SUA"
	#define STR0062 "Limpiando tablas de faltas e incapacidades..."
	#define STR0063 "Limpiando tablas de Infonavit..."
	#define STR0064 "LOG de cálculo del SUA de :"
	#define STR0065 " Total de errores encontrados : "
	#define STR0066 " Total de empleados procesados :"
	#define STR0067 " Total de empleados generados del SUA :"
	#define STR0068 " Total de movimientos generados al SUA :"
	#define STR0069 "Generando log de cálculo del SUA..."
	#define STR0070 "y el ausentismo de cada Empleado."
	#define STR0071 "Después de ese proceso, los informes mensual y bimestral pueden ejecutarse"
	#define STR0072 "Error: Tiene incapacidades sin folio, y no se procesaron algunos registros del empleado: "
	#define STR0073 "Error: Ausencia sin rama definida, puede haber inconsistencias en el ausentismo del empleado: "
	#define STR0074 " Fecha de ingreso "
#else
	#ifdef ENGLISH
		#define STR0001 "This routine creates information about Work Shift"
		#define STR0002 "of employees in a given period"
		#define STR0003 "Update of file SUA"
		#define STR0004 "Patronal Record Code is not filled"
		#define STR0005 "IMSS Code is not filled"
		#define STR0006 "CURP code is not filled"
		#define STR0007 "Infonavit Credit Date is not filled"
		#define STR0008 "Type of Infonavit is not filled"
		#define STR0009 "There is an invalid sequence of transactions"
		#define STR0010 "Duplicate Dates in Work Shift"
		#define STR0011 "Attention"
		#define STR0012 "Do you confirm parameters configuration?"
		#define STR0013 "Inconsistencies occured during process. Do you want to see the LOG?"
		#define STR0014 "Ocurrences Log"
		#define STR0015 "Employee(s) Saved"
		#define STR0016 "Wait..."
		#define STR0017 "Attention"
		#define STR0018 "Do you confirm parameters configuration?"
		#define STR0019 "Invalid Infonavit discount value"
		#define STR0020 "Type of employee is not informed"
		#define STR0021 "Wage type is not filled"
		#define STR0022 "Work Shift is not filled"
		#define STR0023 "Employee with Infonavit discount value and with suspension date prior to the bimester"
		#define STR0024 "Employee name contains special characters"
		#define STR0025 "Paternal nickname cannot be blank"
		#define STR0026 "IMSS code must contain only numbers"
		#define STR0027 "IMSS verifying digit code dows not match"
		#define STR0028 "Integrated Wage is smaller than Integrated Minimum Wage"
		#define STR0029 "Employee has no Ingression for selected Patronal Register"
		#define STR0030 "SUA Calculation"
		#define STR0031 "This routine runs calculation necessary to load SUA tables"
		#define STR0032 "Considering Labor History, Infonavit Credit History"
		#define STR0033 "Processing..."
		#define STR0034 "The month must be between 1 and 12."
		#define STR0035 "The year must be greater than 1900."
		#define STR0036 "At least one Employer Record must be selected"
		#define STR0037 "Process stopped due to errors generated in the clearing of tables. Check the errors"
		#define STR0038 "Selecting Transaction for SUA"
		#define STR0039 "Starting generation of Transaction for SUA"
		#define STR0040 "Error: no se encontró salario anterior del empleado "
		#define STR0041 "And the Transaction was not generated."
		#define STR0042 "Generating Transaction for SUA"
		#define STR0043 "Process finished! Records not found"
		#define STR0044 "Process finished with errors generated"
		#define STR0045 "Process successfully finished"
		#define STR0046 " Employee and "
		#define STR0047 " Transactions Generated for SUA"
		#define STR0048 "It does not exist"
		#define STR0049 "Error. Station not found"
		#define STR0050 " for the employee:"
		#define STR0051 "Generating Former Daily Salary..."
		#define STR0052 "There are no records for Wages (RPC) prior to the period."
		#define STR0053 "Generating Former Daily Salary..."
		#define STR0054 "Selecting Absence and Disability..."
		#define STR0055 "Generating absence and disability..."
		#define STR0056 "Selecting Infonavit transactions..."
		#define STR0057 "Generating Infonavit transactions..."
		#define STR0058 "Generating transaction for SUA..."
		#define STR0059 "Generating transaction for SUA..."
		#define STR0060 "Clearing transaction tables for SUA"
		#define STR0061 "Clearing employee tables SUA"
		#define STR0062 "Cleaning absence and disability tables..."
		#define STR0063 "Clearing Infonavit tables..."
		#define STR0064 "SUA Calculation LOG of :"
		#define STR0065 " Total Errors found : "
		#define STR0066 " Total of Employees Processed :"
		#define STR0067 " Total of Employees Generated form SUA :"
		#define STR0068 " Total of Transaction Generated to SUA :"
		#define STR0069 "Generating SUA Calculation Log..."
		#define STR0070 "and Absence of each Employee."
		#define STR0071 "After this process, the monthly and bimonthly reports can be executed"
		#define STR0072 "Error: Tiene incapacidades sin folio, y no se procesaron algunos registros del empleado: "
		#define STR0073 "Error: Ausencia sin rama definida, puede haber inconsistencias en el ausentismo del empleado: "
		#define STR0074 " Fecha de ingreso "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este Procedimento Gera As Infomações Da Trajectória De Trabalho", "Esta rotina gera as infomações da Trajetória de Trabalho" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", " de empregados num determinado período", " de funcionários em um determinado período" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Actualização  Ficheiro Sua", "Atualização Arquivo SUA" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Código  do registo patronal não esta preenchido", "Código do Registro Patronal não está preenchido" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Código  de imss não esta preenchido", "Código de IMSS não está preenchido" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Código  de curp não está preenchido", "Código de CURP não está preenchido" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Data de crédito infonavit não esta preenchida", "Data de Crédito Infonavit náo está preenchida" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Tipo de infonavit não esta preenchido", "Tipo de Infonavit não está preenchido" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Existe uma sequência  dos tipos de movimentos invalida", "Existe uma sequência dos tipos de movimentos inválida" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Datas Duplicadas Na Trajectória Laboral", "Datas Duplicadas na Trajetória de Trabalho" )
		#define STR0011 "Atenção"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Confirma configura??o dos par?metros?", "Confirma configuração dos parâmetros?" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Ocorreram Inconsistencias Durante O Processo.deseja Consultar O Diário", "Ocorreram Inconsistências durante o Processo. Deseja consultar o LOG?" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Diário De Ocorrências", "Log de Ocorrências" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Empregado(s) Gravado(s)", "Funcionários Salvos" )
		#define STR0016 "Aguarde..."
		#define STR0017 "Atenção"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Confirma Configuração  Dos Parâmetro S", "Confirma Configuração dos Parâmetros" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Valor de desconto infonavit inválido", "Valor de desconto Infonavit inválido" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Tipo de empregado não esta preenchido", "Tipo de Funcionário não está preenchido" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Tipo de remuneração não esta preenchido", "Tipo de Salário não está preenchido" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Tipo de dia não esta preenchida", "Tipo de Jornada não está preenchida" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Empregado com valor de desconto infonavit e com data de suspensão anterior ao bimestre", "Funcionário com valor de desconto Infonavit e com data de suspensão anterior ao bimestre" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Nome do empregado possui caracteres especiais", "Nome do funcionário possui caracteres especiais" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Apelido paterno não pode estar em branco", "Sobrenome paterno não pode estar em branco" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Código  de imss deve conter apenas número s", "Código de IMSS deve conter apenas números" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "O digito verificador do código  de imss não coincide", "O dígito verificador do Código de IMSS não coincide" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Remuneração Integrado Menor Que O Remuneração Mínimo Integrado", "Salário Integrado menor que o Salário Mínimo Integrado" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Empregado não possui ingresso para o registo patronal seleccionado", "Funcionário não possui Admissão para o Registro Patronal selecionado" )
		#define STR0030 "Cálculo do SUA"
		#define STR0031 "Esta rotina executa os cálculos necessários para carregar as tabelas do SUA"
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "O Histórico de Crédito Infonavit baseia-se na Trajectória Laboral", "Tomando como base a Trajetória de Trabalho, o Histórico de Crédito Infonavit" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "A processar...", "Processando..." )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "O mês deve ser entre 1 e 12", "O mês deve ficar entre 1 e 12" )
		#define STR0035 "O ano deve ser maior que 1900"
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Deve ser seleccionado ao menos 1 Registo Patronal", "Deve ser selecionado ao menos 1 Registro Patronal" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Processo parado devido a erros gerados na limpeza das tabelas. Verifique os erros.", "Processo parado, devido a erros gerados na limpeza das tabelas. Verifique os erros" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "A seleccionar movimento para o SUA", "Selecionando Movimento para o SUA" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Início da geração do movimento para o SUA", "Início da geração do Movimento para o SUA" )
		#define STR0040 "Error: no se encontró salario anterior del empleado "
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "E o Movimento não foi gerado.", "E o Movimento não foi gerado" )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "A gerar movimentos para o SUA", "Gerando Movimentos para o SUA" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", "Processo finalizado. Os registos não foram encontrados", "Processo concluído! Os registros não foram encontrados" )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Processo finalizado com erros gerados", "Processo concluído, com erros gerados" )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "Processo finalizado com êxito", "Processo concluído com sucesso" )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", " Colaborador e ", " Funcionário e " )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", " Movimientos gerados para o SUA", " Movimentos Gerados para o SUA" )
		#define STR0048 "Não existe"
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "Erro. Posto não encontrado", "Erro. Cargo não encontrado" )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", " para o colaborador:", " para o funcionário:" )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "A gerar salário diário anterior...", "Gerando Salário Diário Anterior..." )
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "Não existem registos para Salários (RCP) anteriores ao período.", "Não existem registros para Salários (RCP) anteriores ao período." )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "A gerar salário diário anterior...", "Gerando Salário Diário Anterior..." )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "A seleccionar faltas e incapacidades...", "Selecionando Faltas e Incapacidades..." )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "A gerar faltas e incapacidades...", "Gerando faltas e incapacidades..." )
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "A seleccionar movimentos de Infonavit...", "Selecionando movimentos de Infonavit..." )
		#define STR0057 If( cPaisLoc $ "ANG|PTG", "A gerar movimentos de Infonavit...", "Gerando movimentos de Infonavit..." )
		#define STR0058 If( cPaisLoc $ "ANG|PTG", "A gerar movimentos para o SUA...", "Gerando movimento para o SUA..." )
		#define STR0059 If( cPaisLoc $ "ANG|PTG", "A gerar movimentos para o SUA...", "Gerando movimento para o SUA..." )
		#define STR0060 If( cPaisLoc $ "ANG|PTG", "A limpar tabelas de movimento para o SUA", "Limpando tabelas de movimento para o SUA" )
		#define STR0061 If( cPaisLoc $ "ANG|PTG", "A limpar tabelas de colaboradores SUA", "Limpando tabelas de funcionários SUA" )
		#define STR0062 If( cPaisLoc $ "ANG|PTG", "A limpar tabelas de faltas e incapacidades...", "Limpando tabelas de faltas e incapacidades..." )
		#define STR0063 If( cPaisLoc $ "ANG|PTG", "A limpar tabelas de Infonavit...", "Limpando tabelas de Infonavit..." )
		#define STR0064 If( cPaisLoc $ "ANG|PTG", "LOG de cálculo do SUA de :", "LOG de Cálculo do SUA de :" )
		#define STR0065 If( cPaisLoc $ "ANG|PTG", " Total de erros encontrados : ", " Total de Erros encontrados : " )
		#define STR0066 If( cPaisLoc $ "ANG|PTG", " Total de colaboradores processados :", " Total de Funcionários Processados :" )
		#define STR0067 If( cPaisLoc $ "ANG|PTG", " Total de colaboradores gerados do SUA :", " Total de Funcionários Gerados do SUA :" )
		#define STR0068 If( cPaisLoc $ "ANG|PTG", " Total de movimentos gerados ao SUA :", " Total de Movimentos Gerados para o SUA :" )
		#define STR0069 If( cPaisLoc $ "ANG|PTG", "A gerar Log de Cálculo do SUA...", "Gerando Log de Cálculo do SUA..." )
		#define STR0070 If( cPaisLoc $ "ANG|PTG", "e a ausência de cada colaborador.", "e as Faltas de cada Funcionário." )
		#define STR0071 If( cPaisLoc $ "ANG|PTG", "Após este processo, os relatórios mensal e bimestral podem ser executados", "Após esse processo, os relatórios mensal e bimestral podem ser executados" )
		#define STR0072 "Error: Tiene incapacidades sin folio, y no se procesaron algunos registros del empleado: "
		#define STR0073 "Error: Ausencia sin rama definida, puede haber inconsistencias en el ausentismo del empleado: "
		#define STR0074 " Fecha de ingreso "
	#endif
#endif
