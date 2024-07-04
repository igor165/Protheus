#ifdef SPANISH
	#define STR0001 "Haciendo calculo mensual. Espere..."
	#define STR0002 "No fue posible hacer el calculo mensual."
	#define STR0003 "El objetivo de esta rutina es calcular el resultado final"
	#define STR0004 "de los eventos calculados en un periodo,  permitiendo su "
	#define STR0005 "mantenimiento antes de hacer el cierre mensual.          "
	#define STR0006 "Calculo mensual"
	#define STR0007 "Sucur./Turn/Mat: "
	#define STR0008 "Procesando..."
	#define STR0009 "Periodo para el calculo no valido."
	#define STR0010 "El calculo mensual fue anulado por el usuario"
	#define STR0011 "La regla: "
	#define STR0012 "No esta registrada en el SPA (archivo de Reglas)"
	#define STR0013 "No fue posible efectuar el cálculo para el empleado:"
	#define STR0014 "de la sucursal: "
	#define STR0015 "y turno: "
	#define STR0016 "Verifique si existen eventos registrados en el SP9 (archivo de Eventos)"
	#define STR0017 "Verifique si hay eventos para los Identificadores 001A, 002A y 026A"
	#define STR0018 "Verifique si existen eventos para los identificadores 022A y 021N"
	#define STR0019 "No fue posible hacer el calendario para el empleado: "
	#define STR0020 "No se hizo el calculo mensual para este empleado."
	#define STR0021 "No fue posible cargar los tipos de horas extras."
	#define STR0022 "El calculo mensual no se hara."
	#define STR0023 "No existen eventos con incidencia para DSR. Ajuste las incidencias en el archivo de Eventos (SP9)"
	#define STR0024 "Verifique si existen eventos para los identificadores 018A y 017N"
	#define STR0025 "No se hizo el calculo de descuento de DSR"
	#define STR0026 "Sucursal:"
	#define STR0027 "Turno:"
	#define STR0028 "Secuencia:"
	#define STR0029 "Inicio:"
	#define STR0030 "Transcurridos"
	#define STR0031 "Final previsto:"
	#define STR0032 "Procesados:"
	#define STR0033 "Espere..."
	#define STR0034 "Seleccionando empleados"
	#define STR0035 "El motivo de Justificacion: "
	#define STR0036 " Justifica horas y esta sin codigo de evento debidamente llenado."
	#define STR0037 "El periodo de apunte:"
	#define STR0038 " aun no se cerro."
	#define STR0039 " a "
	#define STR0040 "Atencion"
	#define STR0041 "Actualice el campo PL_HORAS ejecutando el compatibilizador RHUPDMOD  "
	#define STR0042 "Verifique si existe evento para el identificador 036N"
	#define STR0043 "La NUEVA pregunta 'Agrupar eventos' está completado con la opción 'Sí'. De esta manera el cálculo aumenta los conceptos presentes en los resultados. Esta opción se recomienda solamente para cálculos realizados de forma PARCIAL. Para cálculos del período completo de una única vez, recomendamos la opción 'No'. ¿Desea continuar?"
	#define STR0044 'El empleado no tiene convocatorias en el período informado en los parámetros'
	#define STR0045 'No hay período de cálculo de la planilla abierto en el período informado en los parámetros'
	#define STR0046 'No hay período de cálculo abierto para las convocatorias del empleado. Convocatorias sin período abierto:'
	#define STR0047 'No hay período de cálculo abierto para todas las convocatorias del empleado. Convocatorias sin período abierto:'
	#define STR0048 "- Código:"
	#define STR0049 "Fecha inicial:"
	#define STR0050 "Fecha final:"
	#define STR0051 'Para el empleado:'
	#define STR0052 'No se generó el resultado del día:'
	#define STR0053 'debido a que no se encontró la convocatoria para este día.'
	#define STR0054 'Obs.: los resultados incluidos en estas fechas NO se grabarán.'
	#define STR0055 'Las convocatorias registradas para el período abierto de la planilla son:'
	#define STR0056 'El empleado no tiene convocatorias en el período abierto en la planilla.'
	#define STR0057 "La sucursal"
	#define STR0058 "no se procesó, porque el período está cerrado. Por favor seleccione otra fecha inicial y final en los parámetros del cálculo mensual."
	#define STR0059 "Período cerrado:"
	#define STR0060 "Período de cálculo modificado, pues los días anteriores a"
	#define STR0061 "ya se cerraron. Período utilizado para la sucursal"
	#define STR0062 "a"
	#define STR0063 "Al realizar el cálculo mensual, los eventos se sobrepondrán, principalmente la fecha de pago. Esta se actualizará a la fecha base del sistema, si ya existieran eventos en los resultados dentro del período seleccionado."
#else
	#ifdef ENGLISH
		#define STR0001 "Executing Monthly Calculation. Please wait..."
		#define STR0002 "It was not possible to execute the monthly calculation."
		#define STR0003 "This routine has the purpose of calculating the accrued "
		#define STR0004 "amount of events calculated in one Period, thus allowing "
		#define STR0005 "its maintenance before executing Monthly Closing.        "
		#define STR0006 "Monthly Calculation"
		#define STR0007 "Branch/Shift/Reg : "
		#define STR0008 "Processing..."
		#define STR0009 "Period for Calculation is Invalid."
		#define STR0010 "The monthly calculation was cancelled by the user."
		#define STR0011 "The rule: "
		#define STR0012 "Is not registered in SPA (Rules file)"
		#define STR0013 "Unable to perform calculation for employee:"
		#define STR0014 "Branch: "
		#define STR0015 "Shift: "
		#define STR0016 "Check if there are events registered in SP9 (Events file)"
		#define STR0017 "Check whether there are Events for Identifiers 001a, 002a AND 026a"
		#define STR0018 "Check if there are events for the identifiers 022A and 021N"
		#define STR0019 "It was not possible to set the calendar for the employee: "
		#define STR0020 "The monthly calculation was not executed for this employee."
		#define STR0021 "It was not possible to load the overtime types."
		#define STR0022 "The monthly calculation won´t be executed."
		#define STR0023 "There are no events with incidence for DSR. Check the incidences in the Events File (SP9)"
		#define STR0024 "Check if there are events for the identifiers 018A and 017N"
		#define STR0025 "The DSR discount calculation was not executed"
		#define STR0026 "Branch:"
		#define STR0027 "Shift:"
		#define STR0028 "Sequence:"
		#define STR0029 "Beginning:"
		#define STR0030 "Elapsed"
		#define STR0031 "Estimated end:"
		#define STR0032 "Processed:"
		#define STR0033 "Please, wait..."
		#define STR0034 "Selecting Employees"
		#define STR0035 "Bonus reason: "
		#define STR0036 " Guarantee Hours and this one without the Event Code correctly filled out."
		#define STR0037 "Note period:"
		#define STR0038 "it was not closed."
		#define STR0039 " to "
		#define STR0040 "Attention"
		#define STR0041 "Update the field PL_HORAS by running the compatibility program RHUPDMOD  "
		#define STR0042 "Check if there is event for identifier 036N"
		#define STR0043 "The NEW question 'Group Events' is completed as 'Yes'. Thus, calculation inputs budgets already presented in the results. This option is only recommended for calculations partially executed. For calculation of the full period at once, we recommend option 'No'. Continue?"
		#define STR0044 'Employee lacks calls on dates entered in parameters'
		#define STR0045 'No payroll calculation period open in period entered in parameters'
		#define STR0046 'No calculation period open for employee calls. Calls without open period:'
		#define STR0047 'No calculation period open for all employee calls. Calls without open period:'
		#define STR0048 "- Code:"
		#define STR0049 "Start date:"
		#define STR0050 "End Date:"
		#define STR0051 'For employee:'
		#define STR0052 'No result generated for day:'
		#define STR0053 'because no call was found for this day.'
		#define STR0054 'Note: results found for these dates will NOT be recorded.'
		#define STR0055 'The calls registered for pending payroll period are:'
		#define STR0056 'Employee lacks calls in pending payroll period.'
		#define STR0057 "The Branch"
		#define STR0058 "Was not processed, as the period is closed. Please select start and end date in the parameters of the monthly calculation."
		#define STR0059 "Closed period:"
		#define STR0060 "Calculation period edited as days previous to"
		#define STR0061 "Have already been closed. Period used for the branch"
		#define STR0062 "to"
		#define STR0063 "In the monthly calculation, the events are overlapped, mainly the payment date - it is updated to the base date of the system if there already are events in the results in the selected period."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "A Realizar Cálculo Mensal.  Aguarde...", "Realizando Calculo Mensal.  Aguarde..." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Não Foi Possível Realizar O Cálculo Mensal.", "Nao foi possivel Realizar o Calculo Mensal." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Esto procedimento tem  como objectivo apurar o resultado  final", "Esta rotina tem  como objetivo apurar o resultado  final" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Dos eventos calculados num período, possibilitando a sua", "dos eventos calculados em um Período, possibilitando sua" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", 'mAnutençäo antes de realizar o Fechamento Mensal.', "manutençäo antes de realizar o Fechamento Mensal.       " )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Cálculo Mensal", "Calculo Mensal" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Filial/tno/mat : ", "Filial/Tno/Mat : " )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "A processar...", "Processando..." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Período Para O Cálculo Inválido.", "Periodo para o Calculo Invalido." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "O Cálculo Mensal Foi Cancelado Pelo Utilizador", "O Calculo Mensal Foi Cancelado Pelo Usuario" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "A regra: ", "A Regra: " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Não Está Registada No Spa (registo De Regras)", "Nao Esta Cadastrada no SPA (Cadastro de Regras)" )
		#define STR0013 "Não foi possível efetuar o cálculo para o funcionário:"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Da filial: ", "da Filial: " )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "E turno: ", "e Turno: " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Verifique Se Existem Eventos Registados No Sp9 (registo De Eventos)", "Verifique se existem Eventos cadastrados no SP9 (Cadastro de Eventos)" )
		#define STR0017 "Verifique se Existem Eventos para os Identificadores 001A, 002A e 026A"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Verifique se existem eventos para os identificadores 022a e 021n", "Verifique se Existem Eventos para os Identificadores 022A e 021N" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Não foi possível construir o calendário para o empregado: ", "Nao foi possivel Montar o Calendario para o Funcionario: " )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "O cálculo mensal não foi efectuado para este empregado.", "O Calculo Mensal nao foi efetuado para este funcionario." )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Não Foi Possível Carregar Os Tipos De Horas Extra.", "Nao foi Possivel Carregar os Tipos de Horas Extras." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "O cálculo mensal não será efectuado.", "O Calculo Mensal nao sera efetuado." )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Não existem eventos com incidência para dsr. corrija as incidências no registo de eventos (sp9)", "Nao Existem Eventos com Incidencia para DSR. Acerte as Incidencias no Cadastro de Eventos (SP9)" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Verifique se existem eventos para os identificadores 018a e 017n", "Verifique se Existem Eventos para os Identificadores 018A e 017N" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "O Cálculo De Desconto De Dsr Não Foi Efectuado", "O Calculo de Desconto de DSR nao Foi Efetuado" )
		#define STR0026 "Filial:"
		#define STR0027 "Turno:"
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Sequência:", "Sequencia:" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Início:", "Inicio:" )
		#define STR0030 "Decorridos"
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Fim estimado:", "Final estimado:" )
		#define STR0032 "Processados:"
		#define STR0033 "Aguarde..."
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Empregados", "Selecionando Funcionarios" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "O motivo de regularização de ausência: ", "O motivo de Abono: " )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", " justifica horas e está sem código de evento devidamente preenchido.", " Abona Horas e esta sem Codigo de Evento devidamente preenchido." )
		#define STR0037 "O período de apontamento:"
		#define STR0038 " ainda não foi fechado."
		#define STR0039 " a "
		#define STR0040 "Atenção"
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Actualize o campo PL_HORAS executando o compatibilizador RHUPDMOD  ", "Atualize o campo PL_HORAS executando o compatibilizador RHUPDMOD  " )
		#define STR0042 "Verifique se existe evento para o identificador 036N"
		#define STR0043 "A NOVA pergunta 'Agrupar Eventos' está preenchida com a opção 'Sim'. Desse modo o cálculo incrementa as verbas já presentes nos resultados. Esta opção é recomendada apenas para cálculos realizados de forma PARCIAL. Para cálculos do período completo de uma única vez, recomendamos a opção 'Não'. Deseja continuar?"
		#define STR0044 'O funcionário não possui convocações nas datas informadas nos parâmetros'
		#define STR0045 'Não há período de cálculo de folha aberto no período informado nos parâmetros'
		#define STR0046 'Não há período de cálculo aberto para as convocações do funcionário. Convocações sem período aberto: '
		#define STR0047 'Não há período de cálculo aberto para todas as convocações do funcionário. Convocações sem período aberto: '
		#define STR0048 "   - Código: "
		#define STR0049 "Data de início: "
		#define STR0050 "Data de término: "
		#define STR0051 'Para o Funcionario:'
		#define STR0052 'Não foi gerado resultado do dia: '
		#define STR0053 ' devido não ter sido encontrado convocação para esse dia.'
		#define STR0054 'Obs.: os resultados compreendidos nessas datas NÃO serão gravados.'
		#define STR0055 'As convocações cadastradas para o período em aberto da folha são: '
		#define STR0056 'O funcionário não possui convocações no período em aberto da folha.'
		#define STR0057 "A Filial "
		#define STR0058 " não foi processada, porque período está fechado. Por favor selecione outra data de inicio e fim nos parâmetros do calculo mensal."
		#define STR0059 "Período fechado: "
		#define STR0060 "Período de calculo alterado pois os dias anteriores a "
		#define STR0061 " já foram fechados. Período utilizado para a filial "
		#define STR0062 " até "
		#define STR0063 "Ao realizar o cálculo mensal os eventos serão sobrepostos, principalmente a data de pagamento. Ela será atualizada para a data base do sistema caso já existam eventos nos resultados dentro do período selecionado."
	#endif
#endif
