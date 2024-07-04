#ifdef SPANISH
	#define STR0001 "Planilla de haberes"
	#define STR0002 "Matrícula"
	#define STR0003 "Nombre"
	#define STR0004 "Asientos"
	#define STR0005 "C.Costo Empleado."
	#define STR0006 "C.Costo Movimiento."
	#define STR0007 "Área"
	#define STR0008 "No Patronal IPS"
	#define STR0009 "Imprime la Planilla de haberes, de acuerdo con los parametros solicitados por el usuario."
	#define STR0010 "Cat. Empl."
	#define STR0011 "No Patronal MTESS "
	#define STR0012 "Tipo de Contrato:"
	#define STR0013 "Indeterminado"
	#define STR0014 "Determinado"
	#define STR0015 "Ambos"
	#define STR0016 "Proceso:"
	#define STR0017 "Periodo:"
	#define STR0018 "Pago:"
	#define STR0019 "Fch. Periodo:"
	#define STR0020 "Fch. Pago:"
	#define STR0021 "Categoría"
	#define STR0022 "CI"
	#define STR0023 "Salario Mensual"
	#define STR0024 "Salario Diario"
	#define STR0025 "Bco Dep Cia "
	#define STR0026 "Conceptos del Empleado"
	#define STR0027 "Cod."
	#define STR0028 "Descripcion"
	#define STR0029 "Ref."
	#define STR0030 "Valor"
	#define STR0031 "No se encontro ningun periodo."
	#define STR0032 "Verifique Parametros de Impresion."
	#define STR0033 "Analitico"
	#define STR0034 "Sintetico"
	#define STR0035 " de "
	#define STR0036 "Sucursal"
	#define STR0037 "Totales Empleado "
	#define STR0038 "Total Sucursal"
	#define STR0039 "Neto:"
	#define STR0040 "Sucursal / Nombre "
	#define STR0041 "C.Costo Empleado"
	#define STR0042 "Total C.Costo"
	#define STR0043 "Remuneraciones"
	#define STR0044 "Descuentos"
	#define STR0045 "Bases"
	#define STR0046 "Área"
	#define STR0047 "Total Área "
	#define STR0048 "C.Costo Movimiento"
	#define STR0049 "Moneda"
	#define STR0050 "Cuenta Depositorio"
	#define STR0051 "Fch. Ingreso"
	#define STR0052 "Fch. Reconocimiento"
	#define STR0053 "Dif. Netos: "
	#define STR0054 "Dif. Netos del Empleado: "
	#define STR0055 "Sucursal "
	#define STR0056 "Total de Empleados Impresos: "
	#define STR0057 "Item Contable"
	#define STR0058 "Clase de Valor"
	#define STR0059 "Fecha Liquidación"
	#define STR0060 "Total Empresa:"
#else
	#ifdef ENGLISH
		#define STR0001 "Payroll"
		#define STR0002 "Registration"
		#define STR0003 "Name"
		#define STR0004 "Entries"
		#define STR0005 "Employee Cost Center"
		#define STR0006 "Transaction Cost Center"
		#define STR0007 "Area"
		#define STR0008 "Non-employer IPS"
		#define STR0009 "Prints the Payroll, according to parameters requested by the user."
		#define STR0010 "Cat. Empl.:"
		#define STR0011 "Non-employer MTESS"
		#define STR0012 "Type of contract:"
		#define STR0013 "Indeterminate"
		#define STR0014 "Determinate"
		#define STR0015 "Both"
		#define STR0016 "Process:"
		#define STR0017 "Period:"
		#define STR0018 "Payment:"
		#define STR0019 "Dat. Period:"
		#define STR0020 "Date Payment:"
		#define STR0021 "Category"
		#define STR0022 "CI"
		#define STR0023 "Monthly Wage"
		#define STR0024 "Daily Wage"
		#define STR0025 "Co Dep Bank"
		#define STR0026 "Employee Resources"
		#define STR0027 "Code"
		#define STR0028 "Description"
		#define STR0029 "Ref"
		#define STR0030 "Value"
		#define STR0031 "No period was found"
		#define STR0032 "Check Printing Parameters"
		#define STR0033 "Detailed"
		#define STR0034 "Summarized"
		#define STR0035 "from"
		#define STR0036 "Branch"
		#define STR0037 "Employee Totals"
		#define STR0038 "Branch Total"
		#define STR0039 "Net:"
		#define STR0040 "Branch/name"
		#define STR0041 "Employee Cost Center"
		#define STR0042 "Total Cost Center"
		#define STR0043 "Wages"
		#define STR0044 "Discounts"
		#define STR0045 "Bases"
		#define STR0046 "Area"
		#define STR0047 "Total Area"
		#define STR0048 "Transaction Cost Center"
		#define STR0049 "Currency"
		#define STR0050 "Deposit Account"
		#define STR0051 "Date Inflow"
		#define STR0052 "Date Recognition"
		#define STR0053 "Dif. Net"
		#define STR0054 "Dif. Net of Employee:"
		#define STR0055 "Branch"
		#define STR0056 "Total of Employees Printed:"
		#define STR0057 "Accounting Item"
		#define STR0058 "Value Class"
		#define STR0059 "Settlement Date"
		#define STR0060 "Company total:"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Planilla de haberes", "Folha de Pagamento" )
		#define STR0002 "Matrícula"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Nombre", "Nome" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Asientos", "Lançamentos" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "C.Costo Empleado.", "C.Custo Funcionário." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "C.Costo Movimiento.", "C.Custo Movimento." )
		#define STR0007 "Área"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "No Patronal IPS", "Não Patronal IPS" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Imprime la Planilla de haberes, de acuerdo con los parametros solicitados por el usuario.", "Imprime a Folha de Pagamento, segundo os parâmetros solicitados pelo usuário." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Cat. Empl.", "Cat. Func.:" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "No Patronal MTESS ", "Não Patronal MTESS" )
		#define STR0012 "Tipo de Contrato:"
		#define STR0013 "Indeterminado"
		#define STR0014 "Determinado"
		#define STR0015 "Ambos"
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Proceso:", "Processo:" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Periodo:", "Período:" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Pago:", "Pagamento:" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Fch. Periodo:", "Dat. Período:" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Fch. Pago:", "Dat. Pagamento:" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Categoría", "Categoria" )
		#define STR0022 "CI"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Salario Mensual", "Salário Mensal" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Salario Diario", "Salario Diário" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Bco Dep Cia ", "Bco Dep Cia" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Conceptos del Empleado", "Verbas do Funcionário" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Cod.", "Cód." )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Descripcion", "Descrição" )
		#define STR0029 "Ref."
		#define STR0030 "Valor"
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "No se encontro ningun periodo.", "Não foi encontrado qualquer período." )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Verifique Parametros de Impresion.", "Confira Parâmetros de Impressão." )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Analitico", "Analítico" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Sintetico", "Sintético" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", " de ", "de" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Sucursal", "Filial" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Totales Empleado ", "Totais Funcionário" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "Total Sucursal", "Total Filial" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Neto:", "Líquido:" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Sucursal / Nombre ", "Filial / Nome" )
		#define STR0041 "C.Costo Empleado"
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Total C.Costo", "Total C.Custo" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", "Remuneraciones", "Remunerações" )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Descuentos", "Descontos" )
		#define STR0045 "Bases"
		#define STR0046 "Área"
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "Total Área ", "Total Área" )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "C.Costo Movimiento", "C.Custo Movimento" )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "Moneda", "Moeda" )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "Cuenta Depositorio", "Conta Depósito" )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "Fch. Ingreso", "Dat. Entrada" )
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "Fch. Reconocimiento", "Dat. Reconhecimento" )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "Dif. Netos: ", "Dif. Líquidos:" )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "Dif. Netos del Empleado: ", "Dif. Líquidos do Funcionário:" )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "Sucursal ", "Filial" )
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "Total de Empleados Impresos: ", "Total de Funcionários Impressos:" )
		#define STR0057 If( cPaisLoc $ "ANG|PTG", "Item Contable", "Item Contábil" )
		#define STR0058 If( cPaisLoc $ "ANG|PTG", "Clase de Valor", "Classe de Valor" )
		#define STR0059 If( cPaisLoc $ "ANG|PTG", "Fecha Liquidación", "Data Liquidação" )
		#define STR0060 "Total Empresa:"
	#endif
#endif
