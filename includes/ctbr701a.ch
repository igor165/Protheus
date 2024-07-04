#ifdef SPANISH
	#define STR0001 "ESTADO DE CAMBIOS EN EL PATRIMONIO NETO"
	#define STR0002 "Este programa imprimirá el Estado de Cambios en el Patrimonio Neto"
	#define STR0003 "Se imprimirá de acuerdo con los Parámetros solicitados por el usuario."
	#define STR0004 "No hay datos por mostrarse"
	#define STR0005 "Ejecutando consulta"
	#define STR0006 "Seleccionando asientos..."
	#define STR0007 "Cuenta"
	#define STR0008 "Total"
	#define STR0009 "AL"
	#define STR0010 "Expresado en"
	#define STR0011 "GERENTE"
	#define STR0012 "CONTADOR"
	#define STR0013 "Plan de Gestión no asociado al libro. ¡Verifique la configuración elegida del libro! "
	#define STR0014 "Capital"
	#define STR0015 "Acciones de Inversión"
	#define STR0016 "Capital Adicional"
	#define STR0017 "Resultados no Realizados"
	#define STR0018 "Reservas Legales"
	#define STR0019 "Otras Reservas"
	#define STR0020 "Resultados Acumulados"
	#define STR0021 "Diferencias de Conversión"
	#define STR0022 "Ajustes al Patrimonio"
	#define STR0023 "Excedente de Revaluación"
	#define STR0024 "Resultado Neto del Ejercicio"
	#define STR0025 "¿Deseea generar archivo txt?"
	#define STR0026 "Generando archivo..."
	#define STR0027 "No se pudo generar el archivo"
	#define STR0028 "Archivo generado correctamente"
#else
	#ifdef ENGLISH
		#define STR0001 "STATEMENT OF CHANGE IN NET EQUITY"
		#define STR0002 "This program will print the Statement of Change in Net Equity"
		#define STR0003 "It will be printed according to the parameters requested by the user."
		#define STR0004 "No data to display."
		#define STR0005 "Executing query"
		#define STR0006 "Selecting entries..."
		#define STR0007 "Account"
		#define STR0008 "Total"
		#define STR0009 "A"
		#define STR0010 "Expressed in"
		#define STR0011 "MANAGER"
		#define STR0012 "ACCOUNTANT"
		#define STR0013 "Management plan not associated with book. Set the chosen book configuration."
		#define STR0014 "Capital"
		#define STR0015 "Investment Actions"
		#define STR0016 "Additional Capital"
		#define STR0017 "Unrealized Results"
		#define STR0018 "Legal Reservations"
		#define STR0019 "Other Reservations"
		#define STR0020 "Accumulated Results"
		#define STR0021 "Conversion Differences"
		#define STR0022 "Adjustments to Equity"
		#define STR0023 "Revaluation Surplus"
		#define STR0024 "Net Profit for the Year"
		#define STR0025 "Do you want generate txt register?"
		#define STR0026 "Generating register..."
		#define STR0027 "Unable to generate register"
		#define STR0028 "Register generated successfully."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "ESTADO DE CAMBIOS EN EL PATRIMONIO NETO", "DEMONSTRAÇÃO DA MUTAÇÃO DO PATRIMÔNIO LÍQUIDO" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Este programa imprimirá el Estado de Cambios en el Patrimonio Neto", "Este programa irá imprimir a Demonstração da Mutação do Patrimônio Líquido" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Se imprimirá de acuerdo con los Parámetros solicitados por el usuario.", "Será impresso conforme os Parâmetros solicitados pelo usuário." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "No hay datos por mostrarse", "Não há dados a apresentar" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Ejecutando consulta", "Executando consulta" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Seleccionando asientos...", "Selecionando lançamentos..." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Cuenta", "Conta" )
		#define STR0008 "Total"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "AL", "A" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Expresado en", "Expressado em" )
		#define STR0011 "GERENTE"
		#define STR0012 "CONTADOR"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Plan de Gestión no asociado al libro. ¡Verifique la configuración elegida del libro! ", "Plano de Gestão não associado ao livro. Configure a configuração elegida do livro!" )
		#define STR0014 "Capital"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Acciones de Inversión", "Ações de Investimento" )
		#define STR0016 "Capital Adicional"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Resultados no Realizados", "Resultados não Realizados" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Reservas Legales", "Reservas Legais" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Otras Reservas", "Outras Reservas" )
		#define STR0020 "Resultados Acumulados"
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Diferencias de Conversión", "Diferenças de Conversão" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Ajustes al Patrimonio", "Acertos no Patrimônio" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Excedente de Revaluación", "Excedente de Reavaliação" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Resultado Neto del Ejercicio", "Resultado Líquido do Execício" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "¿Deseea generar archivo txt?", "Deseja gerar cadastro txt?" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Generando archivo...", "Gerando cadastro..." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "No se pudo generar el archivo", "Não foi possível gerar o cadastro" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Archivo generado correctamente", "Cadastro gerado corretamente" )
	#endif
#endif
