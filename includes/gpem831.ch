#ifdef SPANISH
	#define STR0001 "Archivos para SUA"
	#define STR0002 "Esta rutina genera los Archivos para SUA : Incapacidades/Crédito Infonavit/"
	#define STR0003 "Datos de Filiación/Datos de Empleados/Movimientos SUA. "
	#define STR0004 "Procesando incapacidades..."
	#define STR0005 "Procesando crédito INFONAVIT..."
	#define STR0006 "Procesando datos de filiación..."
	#define STR0007 "Procesando datos del empleado..."
	#define STR0008 "Procesando movimientos de SUA..."
	#define STR0009 "¡Proceso finalizado! Registros no encontrados..."
	#define STR0010 If( cPaisLoc == "MEX", "Hubo errores, verifique el Log", "Ocurrieron errores, verifique el Log" )
	#define STR0011 If( cPaisLoc == "MEX", "Proceso finalizado. Archivos generados: ", "¡Proceso finalizado! Archivos generados:" )
	#define STR0012 "¡El año debe ser mayor a 1900!"
	#define STR0013 "¡Debe seleccionar al menos un registro patronal!"
	#define STR0014 "¡Debe seleccionar la carpeta para los archivos a generar!"
	#define STR0015 "LOG  Generación archivos SUA "
	#define STR0016 "Generando log de archivos de SUA..."
	#define STR0017 "Empleado "
	#define STR0018 " ¡Sin número de incapacidad! "
	#define STR0019 If( cPaisLoc == "MEX", "¡La Rama debe ser 1,2 o 3! ", "¡El tipo debe ser 1, 2 o 3! " )
	#define STR0020 " ¡El valor de la Secuencia de Incap. debe ser de 0 a 9! "
	#define STR0021 " ¡El valor del Control de Incap. debe ser de 0 a 9! "
	#define STR0022 " ¡El tipo de Movto. Infonavit es incorrecto! "
	#define STR0023 " ¡El tipo de Movto. Infonativ debe ser de 15 a 20! "
	#define STR0024 "¡Tipo de descuento debe ser 1, 2 o 3!"
	#define STR0025 " con valor de descuento mayor a 9999.9999! "
	#define STR0026 " ¡Sin código postal! "
	#define STR0027 " ¡Sin código de Sexo! "
	#define STR0028 " ¡Sin fecha de nacimiento! "
	#define STR0029 " ¡El nombre del puesto tiene caracteres raros! "
	#define STR0030 If( cPaisLoc == "MEX", "  ¡No tiene Tipo de Salario! ", " ¡No tiene tipo de sueldo! " )
	#define STR0031 "¡El nombre del empleado tiene caracteres raros!"
	#define STR0032 If( cPaisLoc == "MEX", " ¡tiene un salario diario mayor a 99999.99! ", "  tiene un sueldo diario superior a 99999.99! " )
	#define STR0033 " no tiene RFC! "
	#define STR0034 " no tiene CURP! "
	#define STR0035 " con tipo de trabajador no válido (1.2,3)! "
	#define STR0036 " con tipo de jornada no válido (0..6)! "
	#define STR0037 " con tipo de descuento no válido (1,2,3)! "
	#define STR0038 " con valor de descuento mayor a 9999.9999! "
	#define STR0039 " con valores en los datos de crédito Infonavit, pero sin número de crédito! "
	#define STR0040 If( cPaisLoc == "MEX", " ¡con salario diario mayor a 9999999 ", " con sueldo superior a 9999999 " )
	#define STR0041 " ¡Sin número de incapacidad! "
	#define STR0042 If( cPaisLoc == "MEX", " en Acumulados, tiene un salario diario mayor a 9999999", "  en los Acumulados, existe un sueldo diario superior a 9999999" )
	#define STR0043 " El Reg. Patronal debe ser de "
	#define STR0044 " sin NSS! "
	#define STR0045 " ¡NSS no tiene 11 dígitos! "
	#define STR0046 " ¡El NSS debe ser numérico! "
	#define STR0047 If( cPaisLoc == "MEX", "¡el Folio de incapacidad es incorrecto! ", " ¡La Planilla de incapacidad está incorrecta! " )
	#define STR0048 " caracteres! "
	#define STR0049 " ¡El año mes es necesario!"
	#define STR0050 " ¡El mes debe ser de 1 a 12!"
	#define STR0051 "¡El empleado: "
	#define STR0052 ", tiene una incapacidad errónea; la consecuencia informada en el campo "
	#define STR0053 " (RHE_RESINC) debe tener valores entre 0 a 9!"
	#define STR0054 "Atención"
	#define STR0055 "El archivo "
	#define STR0056 ", no ha sido creado. Revise el error e intentenuevamente: "
#else
	#ifdef ENGLISH
		#define STR0001 "Files for SUA"
		#define STR0002 "This routine generates Files for SUA: Disabilities/Infonavit Credit/"
		#define STR0003 If( cPaisLoc == "MEX", "Affiliate Data/Employee Data/SUA Transactions ", "Affiliation Data/Employee Data/SUA Movements. " )
		#define STR0004 "Processing Disabilities..."
		#define STR0005 "Processing INFONAVIT Credit..."
		#define STR0006 "Processing Affiliation Data..."
		#define STR0007 "Processing Employee Data..."
		#define STR0008 "Processing SUA Movements..."
		#define STR0009 If( cPaisLoc == "MEX", "¡Proceso Finalizado! No encontro registros...", "Process Completed! Records not found..." )
		#define STR0010 If( cPaisLoc == "MEX", "Error, check log", "Errors occurred, check Log" )
		#define STR0011 If( cPaisLoc == "MEX", "Process finalized, these files were generated: ", "Process Completed. Generated files:" )
		#define STR0012 "Year must be after 1900!"
		#define STR0013 "Select at least one employer record!"
		#define STR0014 "Select the folder for files to be generated!"
		#define STR0015 "SUA File Generation LOG "
		#define STR0016 "Generating Log of SUA Files..."
		#define STR0017 "Employee "
		#define STR0018 " Without Disability Number! "
		#define STR0019 If( cPaisLoc == "MEX", "¡La Rama debe ser 1,2 o 3! ", "The type must be 1, 2 or 3! " )
		#define STR0020 " The value of Disab. Sequence must be from 0 to 9! "
		#define STR0021 " The value of Disab. Control must be from 0 to 9! "
		#define STR0022 " The type of Infonavit movement is wrong! "
		#define STR0023 " The type of Infonavit movement must be between 15 and 20! "
		#define STR0024 "The Discount type must be 1, 2 or 3! "
		#define STR0025 " with discount value higher than 9999,9999! "
		#define STR0026 " With no postal code! "
		#define STR0027 " With no gender code! "
		#define STR0028 " With no date of birth! "
		#define STR0029 " The station name has strange characters! "
		#define STR0030 If( cPaisLoc == "MEX", "  No Type of Salary! ", " There is no Salary Type! " )
		#define STR0031 "Employee's name countains uncommon characters! "
		#define STR0032 If( cPaisLoc == "MEX", " daily salary higher than 99999.99! ", "  with a daily salary higher than 99999,99! " )
		#define STR0033 " with no RFC! "
		#define STR0034 " with no CURP! "
		#define STR0035 " with invalid employee type (1,2,3)! "
		#define STR0036 " with invalid type of working hours (0..6)! "
		#define STR0037 " with invalid discount type (1,2,3)! "
		#define STR0038 " with discount value higher than 9999,9999! "
		#define STR0039 " with values on the data of infonavit credit, but with no credit number! "
		#define STR0040 If( cPaisLoc == "MEX", " daily salary higher than 9999999 ", " with daily salary higher than 9999999 " )
		#define STR0041 " Without Disability Number! "
		#define STR0042 If( cPaisLoc == "MEX", " In Accruals, daily salary higher than 9999999", "  in Accruals, there is a daily salary higher than 9999999" )
		#define STR0043 " Employer Registration must be "
		#define STR0044 " without NSS! "
		#define STR0045 " NSS does not have 11 digits! "
		#define STR0046 " NSS must be numeric! "
		#define STR0047 If( cPaisLoc == "MEX", "¡el Folio de Incapacidad es incorrecto! ", " the Disability Payroll is wrong! " )
		#define STR0048 " characters! "
		#define STR0049 " The month year is required!"
		#define STR0050 " Month must be between 1 and 12!"
		#define STR0051 "¡El empleado: "
		#define STR0052 ", tiene una incapacidad errónea; la consecuencia informada en el campo "
		#define STR0053 " (RHE_RESINC) debe tener valores entre 0 a 9!"
		#define STR0054 "Atención"
		#define STR0055 "El archivo "
		#define STR0056 ", no ha sido creado. Revise el error e intentenuevamente: "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Ficheiros para SUA", "Arquivos para SUA" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Este procedimento gera os Ficheiros para o SUA : Incapacidades/Crédito Infonavit/", "Esta rotina gera os Arquivos para o SUA : Incapacidades/Crédito Infonavit/" )
		#define STR0003 If( cPaisLoc == "MEX", "Datos Afiliatorios/Datos de Empleados/Movimientos SUA. ", If( cPaisLoc $ "ANG|PTG", "Dados Afiliatórios/Dados de Colaboradores/Movimentos SUA. ", "Dados de Filiação/Dados de Funcionários/Movimentos SUA. " ) )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "A processar incapacidades...", "Processando Incapacidades..." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "A processar crédito INFONAVIT...", "Processando Crédito INFONAVIT..." )
		#define STR0006 If( cPaisLoc == "MEX", "Procesando Datos Afiliatorios...", If( cPaisLoc $ "ANG|PTG", "A processar dados afiliatórios...", "Processando Dados de Filiação.." ) )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "A processar dados do colaboradores...", "Processando Dados do Funcionário..." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "A processar movimentos do SUA...", "Processando Movimentos do SUA..." )
		#define STR0009 If( cPaisLoc == "MEX", "¡Proceso Finalizado! No encontro registros...", If( cPaisLoc $ "ANG|PTG", "Processo finalizado. Registos não encontrados...", "Processo Finalizado! Registros não encontrados..." ) )
		#define STR0010 If( cPaisLoc == "MEX", "Hubo errores, verifique el Log", If( cPaisLoc $ "ANG|PTG", "Ocorreram erros, verifique o Log.", "Ocorreram erros, confira o Log" ) )
		#define STR0011 If( cPaisLoc == "MEX", "Proceso Finalizado, Genero los archivos: ", If( cPaisLoc $ "ANG|PTG", "Processo finalizado. Ficheiros gerados:", "Processo Finalizado. Arquivos gerados:" ) )
		#define STR0012 "O ano deve ser maior que 1900!"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Deve seleccionar pelo menos um registo patronal.", "Deve selecionar pelo menos um registro patronal!" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Deve seleccionar a pasta para os ficheiros a serem gerados.", "Deve selecionar a pasta para os arquivos a serem gerados!" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "LOG  Geração Ficheiros SUA ", "LOG  Geração Arquivos SUA " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "A gerar Log de Ficheiros de SUA...", "Gerando Log de Arquivos de SUA..." )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Colaborador ", "Funcionário " )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", " Sem número de incapacidade. ", " Sem Número de Incapacidade! " )
		#define STR0019 If( cPaisLoc == "MEX", "¡La Rama debe ser 1,2 o 3! ", If( cPaisLoc $ "ANG|PTG", " O tipo deve ser 1, 2 ou 3. ", " O tipo deve ser  1, 2 ou 3! " ) )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", " O valor da Seqüência de Incap. deve ser de 0 a 9. ", " O valor da Sequência de Incap. deve ser de 0 a 9! " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", " O valor do Controlo de Incap.  deve ser de 0 a 9. ", " O valor do Controle de Incap.  deve ser de 0 a 9! " )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", " O tipo de movto. Infonavit é  incorrecto. ", " O tipo de Movto. Infonavit é incorreto! " )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", " O tipo de movto. Infonavit deve ser de 15 a 20. ", " O tipo de Movto. Infonavit deve ser de 15 a 20! " )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Tipo de Desconto deve ser 1, 2 ou 3. ", " Tipo de Desconto deve ser 1, 2 ou 3! " )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", " com valor de desconto maior que 9999.9999. ", " com valor de desconto maior que 9999.9999! " )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", " Sem código postal. ", " Sem código postal! " )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", " Sem código de Sexo. ", " Sem código de Sexo! " )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", " Sem  data de nascimento. ", " Sem  data de nascimento! " )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", " O nome do posto possui caracteres estranhos. ", " O nome do cargo possui caracteres estranhos! " )
		#define STR0030 If( cPaisLoc == "MEX", "  ¡No tiene Tipo de Salario! ", If( cPaisLoc $ "ANG|PTG", " Não possui Tipo de Salário. ", " Não possui Tipo de Salário! " ) )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", " O nome do colaborador possui caracteres estranhos. ", " O nome do funcionário possui caracteres estranhos! " )
		#define STR0032 If( cPaisLoc == "MEX", " ¡tiene un salario diario mayor a 99999.99! ", If( cPaisLoc $ "ANG|PTG", "  tem um salário diário maior que 99999.99. ", "  tem um salario diário maior que 99999.99! " ) )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", " não tem RFC. ", " não tem CPF! " )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", " não tem CURP. ", " não tem CURP! " )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", " com tipo de trabalhador inválido (1,2,3). ", " com tipo de trabalhador inválido (1,2,3)! " )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", " com tipo de jornada inválido (0..6). ", " com tipo de jornada inválido (0..6)! " )
		#define STR0037 " com tipo de Desconto inválido (1,2,3)! "
		#define STR0038 " com valor de desconto maior que 9999.9999! "
		#define STR0039 If( cPaisLoc $ "ANG|PTG", " com valores nos dados de crédito Infonavit, mas sem número de crédito. ", " com valores nos dados de crédito Infonavit, mas sem número de crédito! " )
		#define STR0040 " com salário diário maior que 9999999 "
		#define STR0041 " Sem Número de Incapacidade! "
		#define STR0042 If( cPaisLoc == "MEX", " en Acumulados, tiene un salario diario mayor a 9999999", "  nos Acumulados, existe um salário diário maior que 9999999" )
		#define STR0043 " O Reg. Patronal deve ser de "
		#define STR0044 " sem NSS! "
		#define STR0045 If( cPaisLoc $ "ANG|PTG", " O SS não tem 11 dígitos. ", " O NSS não tem 11 dígitos! " )
		#define STR0046 " O NSS deve ser numérico! "
		#define STR0047 If( cPaisLoc == "MEX", "¡el Folio de Incapacidad es incorrecto! ", If( cPaisLoc $ "ANG|PTG", " a Folha de Incapacidade está incorrecta! ", " a Folha de Incapacidade está  errada! " ) )
		#define STR0048 " caracteres! "
		#define STR0049 If( cPaisLoc $ "ANG|PTG", " O ano mês é requerido.", " O ano mês é necessário!" )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", " O mês deve ser de 1 a 12.", " O mês deve ser de 1 a 12!" )
		#define STR0051 "¡El empleado: "
		#define STR0052 ", tiene una incapacidad errónea; la consecuencia informada en el campo "
		#define STR0053 " (RHE_RESINC) debe tener valores entre 0 a 9!"
		#define STR0054 "Atención"
		#define STR0055 "El archivo "
		#define STR0056 ", no ha sido creado. Revise el error e intentenuevamente: "
	#endif
#endif
