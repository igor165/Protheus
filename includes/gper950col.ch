#ifdef SPANISH
	#define STR0001 "Generación de Plantilla UGPP"
	#define STR0002 "Rutina para Generar Archivo: "
	#define STR0003 "Unidad Administrativa Especial de Gestión Pensional "
	#define STR0004 "- Tablas alfanuméricas: S010, S011, S012 "
	#define STR0005 "- Movimientos e Histórico de movimientos de nómina "
	#define STR0006 "Antes de ejecutar la generación del reporte UGPP, asegúrese de lo siguiente:  "
	#define STR0007 "Generación Reporte UGPP"
	#define STR0008 "Generando registros"
	#define STR0009 "Seleccionando información ..."
	#define STR0010 "y Contribuciones Parafiscales de la Protección Social (UGPP)"
	#define STR0011 "Generando archivo Excel..."
	#define STR0012 "Archivo generado exitosamente en: "
	#define STR0013 "Ocurrió un error al Generar el archivo, por favor intente nuevamente."
	#define STR0014 "Proceso Finalizado UGPP..."
	#define STR0015 "No se encontraron registros con los parámetros de búsuqeda informados."
	#define STR0016 "No existen periodos registrados para el mes/ año: "
	#define STR0017 " - No Se puede continuar con el proceso."
	#define STR0018 "No existe registro en S011 para razón Social "
	#define STR0019 "Erro de Gravacao do Arquivo - Codigo DOS: "
	#define STR0020 "Error"
	#define STR0021 "Procesando..."
	#define STR0022 "Periodo dado no es válido - "
	#define STR0023 "Preparando Información ..."
	#define STR0024 "Ley 590/2000 año "
	#define STR0025 "Ley 1429 Col años 1 y 2"
	#define STR0026 "Ley 1429 Col año "
	#define STR0027 "Ley 1429 AGV años 1 al 8"
	#define STR0028 "Ley 1429 AGV año "
	#define STR0029 "TP Vacaciones"
	#define STR0030 "TP Licencia Remunerada"
	#define STR0031 "TP No compensación"
	#define STR0032 "TP Incapacidad"
	#define STR0033 "TP Salarial"
	#define STR0034 "TP NO Salarial"
#else
	#ifdef ENGLISH
		#define STR0001 "Generation of UGPP Payroll"
		#define STR0002 "Routine to Generate Register:"
		#define STR0003 "Special Administrative Unit of Management of Pensions"
		#define STR0004 "- Alphanumeric tables: S010, S011, S012"
		#define STR0005 "- Transactions and History of transactions of payroll"
		#define STR0006 "Before executing the generation of UGPP report, check this:"
		#define STR0007 "Generation of UGPP Report"
		#define STR0008 "Generating records"
		#define STR0009 "Selecting Information..."
		#define STR0010 "and Parafiscal Contributions of Social Protection (UGPP)"
		#define STR0011 "Generating Excel File..."
		#define STR0012 "File successfully generated on:"
		#define STR0013 "Error generating register, please try again."
		#define STR0014 "UGPP process completed ..."
		#define STR0015 "No records found with the search parameters informed."
		#define STR0016 "No periods registered for month/year:"
		#define STR0017 "- unable to continue with the process,"
		#define STR0018 "No record in S011 for Corporate Name"
		#define STR0019 "Error saving register - DOS Code:"
		#define STR0020 "Error"
		#define STR0021 "Processing..."
		#define STR0022 "Period informed invalid -"
		#define STR0023 "Preparing information..."
		#define STR0024 "Ley 590/2000 año "
		#define STR0025 "Ley 1429 Col años 1 y 2"
		#define STR0026 "Ley 1429 Col año "
		#define STR0027 "Ley 1429 AGV años 1 al 8"
		#define STR0028 "Ley 1429 AGV año "
		#define STR0029 "TP Vacaciones"
		#define STR0030 "TP Licencia Remunerada"
		#define STR0031 "TP No compensación"
		#define STR0032 "TP Incapacidad"
		#define STR0033 "TP Salarial"
		#define STR0034 "TP NO Salarial"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Generación de Plantilla UGPP", "Geração da Folha UGPP" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Rutina para Generar Archivo: ", "Rotina para Gerar Cadastro:" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Unidad Administrativa Especial de Gestión Pensional ", "Unidade Administrativa Especial de Gestão de Pensões" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "- Tablas alfanuméricas: S010, S011, S012 ", "- Tabelas alfanuméricas: S010, S011, S012" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "- Movimientos e Histórico de movimientos de nómina ", "- Movimentos e Histórico de movimentos da folha de pagamento" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Antes de ejecutar la generación del reporte UGPP, asegúrese de lo siguiente:  ", "Antes de executar a geração do relatório UGPP, certifique-se do seguinte:" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Generación Reporte UGPP", "Geração Relatório UGPP" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Generando registros", "Gerando registros" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Seleccionando información ...", "Selecionando informação ..." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "y Contribuciones Parafiscales de la Protección Social (UGPP)", "e Contribuições Parafiscais da Proteção Social (UGPP)" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Generando archivo Excel...", "Gerando Cadastro Excel..." )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Archivo generado exitosamente en: ", "Cadastro gerado com sucesso em:" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al Generar el archivo, por favor intente nuevamente.", "Ocorreu um erro ao Gerar o cadastro, por favor tente novamente." )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Proceso Finalizado UGPP...", "Processo Concluído UGPP..." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "No se encontraron registros con los parámetros de búsuqeda informados.", "Não foram encontrados registros com os parâmetros de busca informados." )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "No existen periodos registrados para el mes/ año: ", "Não existem períodos cadastrados para o mês/ano:" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", " - No Se puede continuar con el proceso.", "- Não é possível continuar com o processo." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "No existe registro en S011 para razón Social ", "Não existe registro em S011 para Razão Social" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Erro de Gravacao do Arquivo - Codigo DOS: ", "Erro ao Salvar o Cadastro - Código DOS:" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Error", "Erro" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Procesando...", "Processando..." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Periodo dado no es válido - ", "Período informado inválido -" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Preparando Información ...", "Preparando informação ..." )
		#define STR0024 "Ley 590/2000 año "
		#define STR0025 "Ley 1429 Col años 1 y 2"
		#define STR0026 "Ley 1429 Col año "
		#define STR0027 "Ley 1429 AGV años 1 al 8"
		#define STR0028 "Ley 1429 AGV año "
		#define STR0029 "TP Vacaciones"
		#define STR0030 "TP Licencia Remunerada"
		#define STR0031 "TP No compensación"
		#define STR0032 "TP Incapacidad"
		#define STR0033 "TP Salarial"
		#define STR0034 "TP NO Salarial"
	#endif
#endif
