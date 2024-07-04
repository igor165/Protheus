#ifdef SPANISH
	#define STR0001 "RT 6/84 Ajuste por Inflacion de Activo Fijo"
	#define STR0002 "Grupo"
	#define STR0003 "Activo Fijo"
	#define STR0004 "Fecha"
	#define STR0005 "Cuenta"
	#define STR0006 "Origen"
	#define STR0007 "Revalúo"
	#define STR0008 "Diferencia"
	#define STR0009 "Código"
	#define STR0010 "Descripción"
	#define STR0011 "Estado"
	#define STR0012 "Adquisición"
	#define STR0013 "Baja"
	#define STR0014 "Acumulada"
	#define STR0015 "Dep. Mensual"
	#define STR0016 "Centro de Costo"
	#define STR0017 "Correc Dep."
	#define STR0018 "Correc Bien"
	#define STR0019 "Valor"
	#define STR0020 "Ejercicio"
	#define STR0021 "Acumulada"
	#define STR0022 "Valor Residual"
	#define STR0023 "Este informe imprimira el Ajuste por Inflación."
	#define STR0024 "Atención"
	#define STR0025 "Ok"
	#define STR0026 "Se debe informar un Rango de Periodos."
	#define STR0027 "Se debe informar un Rango de Grupo de Bienes."
	#define STR0028 "El Periodo de Inicio debe ser menor al Final."
	#define STR0029 "Indique la posición."
	#define STR0030 "Bienes"
	#define STR0031 "Transferencias"
	#define STR0032 "Baja"
	#define STR0033 "Activo"
	#define STR0034 "Amortizado"
	#define STR0035 "Vendido"
	#define STR0036 "Bien"
	#define STR0037 "Imputación contable bien transferido"
	#define STR0038 "Valores Históricos"
	#define STR0039 "Valores Ajustados"
#else
	#ifdef ENGLISH
		#define STR0001 "RT 6/84 Adjustment by Inflation of Fixed Asset"
		#define STR0002 "Group"
		#define STR0003 "Fixed Asset"
		#define STR0004 "Date"
		#define STR0005 "Account"
		#define STR0006 "Origin"
		#define STR0007 "Revaluation"
		#define STR0008 "Difference"
		#define STR0009 "Code"
		#define STR0010 "Description"
		#define STR0011 "State"
		#define STR0012 "Acquisition"
		#define STR0013 "Posting Payment"
		#define STR0014 "Accrued"
		#define STR0015 "Monthly Exp."
		#define STR0016 "Cost Center"
		#define STR0017 "Exp. Adjustment"
		#define STR0018 "Asset Adjustment"
		#define STR0019 "Value"
		#define STR0020 "Year"
		#define STR0021 "Accrued"
		#define STR0022 "Residual Value"
		#define STR0023 "This report prints the Adjustment per Inflation."
		#define STR0024 "Attention"
		#define STR0025 "Ok"
		#define STR0026 "Enter Periods Interval."
		#define STR0027 "Enter Assets Group Interval."
		#define STR0028 "Start Period must be earlier than the End Period."
		#define STR0029 "Enter position."
		#define STR0030 "Assets"
		#define STR0031 "Transfers"
		#define STR0032 "Posting Payment"
		#define STR0033 "Asset"
		#define STR0034 "Amortized"
		#define STR0035 "Sold"
		#define STR0036 "Asset"
		#define STR0037 "Accounting taxation asset transfered"
		#define STR0038 "History Values"
		#define STR0039 "Adjusted Values"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "RT 6/84 Ajuste por Inflacion de Activo Fijo", "RT 6/84 Ajuste por Inflação de Ativo Fixo" )
		#define STR0002 "Grupo"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Activo Fijo", "Ativo Fixo" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Fecha", "Data" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Cuenta", "Conta" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Origen", "Origem" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Revalúo", "Reavaliação" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Diferencia", "Diferença" )
		#define STR0009 "Código"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Descripción", "Descrição" )
		#define STR0011 "Estado"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Adquisición", "Aquisição" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Baja", "Baixa" )
		#define STR0014 "Acumulada"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Dep. Mensual", "Dep. Mensal" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Centro de Costo", "Centro de Custo" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Correc Dep.", "Correção Dep." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Correc Bien", "Correção Bem" )
		#define STR0019 "Valor"
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Ejercicio", "Exercício" )
		#define STR0021 "Acumulada"
		#define STR0022 "Valor Residual"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Este informe imprimira el Ajuste por Inflación.", "Esse relatório irá imprimir o Ajuste por Inflação." )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0025 "Ok"
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Se debe informar un Rango de Periodos.", "Deve ser informado um Intervalo de Períodos." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Se debe informar un Rango de Grupo de Bienes.", "Deve ser informado um Intervalo de Grupo de Bens." )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "El Periodo de Inicio debe ser menor al Final.", "O Período de Início deve ser menor que o Final." )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Indique la posición.", "Indique a posição." )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Bienes", "Bens" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Transferencias", "Transferências" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Baja", "Baixa" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Activo", "Ativo" )
		#define STR0034 "Amortizado"
		#define STR0035 "Vendido"
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Bien", "Bem" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Imputación contable bien transferido", "Tributação contábil bem transferido" )
		#define STR0038 "Valores Históricos"
		#define STR0039 "Valores Ajustados"
	#endif
#endif
