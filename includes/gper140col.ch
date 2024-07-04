#ifdef SPANISH
	#define STR0001 "LIQUIDACION DEFINITIVA"
	#define STR0002 "Empresa: "
	#define STR0003 "Sucursal: "
	#define STR0004 "NIT: "
	#define STR0005 "Matrícula: "
	#define STR0006 "Nombre: "
	#define STR0007 "Tipo Id: "
	#define STR0008 "No. Id: "
	#define STR0009 "Centro Costos: "
	#define STR0010 "Departamento: "
	#define STR0011 "Cargo: "
	#define STR0012 "Función: "
	#define STR0013 "Sindicato: "
	#define STR0014 "Proceso: "
	#define STR0015 "EPS: "
	#define STR0016 "AFP: "
	#define STR0017 "ARL: "
	#define STR0018 "CCF: "
	#define STR0019 "Oficio: "
	#define STR0020 "Horas por mes: "
	#define STR0021 "ReteFte: "
	#define STR0022 "% ReteFte: "
	#define STR0023 "Tipo Cesantia: "
	#define STR0024 "Tipo Salario: "
	#define STR0025 "Salario: "
	#define STR0026 "Fecha Ingreso: "
	#define STR0027 "Fecha Reconocimiento: "
	#define STR0028 "Último Aumento: "
	#define STR0029 "Contrato: "
	#define STR0030 "Fecha Retiro: "
	#define STR0031 "Motivo Retiro: "
	#define STR0032 "DEVENGOS"
	#define STR0033 "DEDUCCIONES"
	#define STR0034 "BASES"
	#define STR0035 "Con "
	#define STR0036 "Descripción"
	#define STR0037 "Día/Hora"
	#define STR0038 "Valor "
	#define STR0039 "Total Devengos "
	#define STR0040 "Total Deducciones"
	#define STR0041 "Neto"
	#define STR0042 "hago constar que "
	#define STR0043 " queda a paz y salvo por concepto de prestaciones sociales ya que todos los derechos me han sido reconocidos oportunamente."
	#define STR0044 "de acuerdo con las disposiciones legales y en consecuencia firmo ante testigos."
	#define STR0045 "Aprovada"
	#define STR0046 "Valor "
	#define STR0047 ", "
	#define STR0048 "Ubígueo "
	#define STR0049 " Continua ... "
	#define STR0050 "Total Devengos: "
	#define STR0051 "Total Deducciones: "
	#define STR0052 "Neto: "
	#define STR0053 "Mediante el recibo de $"
	#define STR0054 "Preparada"
	#define STR0055 "Revisada"
	#define STR0056 "Aprobada"
	#define STR0057 "Matrícula"
	#define STR0058 "Centro de Trabajo"
	#define STR0059 "La opción Planilla no se encuentra disponible"
	#define STR0060 "Procedimiento 1"
	#define STR0061 "Procedimiento 2"
	#define STR0062 "_____________________________"
#else
	#ifdef ENGLISH
		#define STR0001 "DEFINITIVE CLEARANCE"
		#define STR0002 "Company:"
		#define STR0003 "Branch:"
		#define STR0004 "NIT:"
		#define STR0005 "Registration:"
		#define STR0006 "Name"
		#define STR0007 "Id Type:"
		#define STR0008 "ID No.:"
		#define STR0009 "Cost Centers:"
		#define STR0010 "Department:"
		#define STR0011 "Position:"
		#define STR0012 "Function:"
		#define STR0013 "Trade Union:"
		#define STR0014 "Process:"
		#define STR0015 "EPS:"
		#define STR0016 "AFP:"
		#define STR0017 "ARL:"
		#define STR0018 "CCF:"
		#define STR0019 "Occupation:"
		#define STR0020 "Hours per Month:"
		#define STR0021 "ReteFte:"
		#define STR0022 "% ReteFte:"
		#define STR0023 "Unemployment Sec. Type:"
		#define STR0024 "Salary type:"
		#define STR0025 "Salary:"
		#define STR0026 "Issue Date:"
		#define STR0027 "Date of Recognition:"
		#define STR0028 "Last Adjustment:"
		#define STR0029 "Contract:"
		#define STR0030 "Outflow Date:"
		#define STR0031 "Ouflow Reason:"
		#define STR0032 "COMPENSATION"
		#define STR0033 "DEDUCTIONS"
		#define STR0034 "BASES"
		#define STR0035 "With"
		#define STR0036 "Description"
		#define STR0037 "Day/Time"
		#define STR0038 "Value"
		#define STR0039 "Total Compensations"
		#define STR0040 "Total Deductions"
		#define STR0041 "Net"
		#define STR0042 "I state that"
		#define STR0043 "the social provision funds remain safe and sound as all my rights have in due course been recognized."
		#define STR0044 "in accordance with legal provisions and in view of the above assessment, I sign before a witness."
		#define STR0045 "Approved"
		#define STR0046 "Value"
		#define STR0047 ","
		#define STR0048 "Ubigeo"
		#define STR0049 "Continue..."
		#define STR0050 "Total Compensations:"
		#define STR0051 "Total Deductions:"
		#define STR0052 "Net:"
		#define STR0053 "By the receipt of $"
		#define STR0054 "Ready"
		#define STR0055 "Reviewed"
		#define STR0056 "Approved"
		#define STR0057 "Registration"
		#define STR0058 "Work Center"
		#define STR0059 "Spreadsheet option is not available"
		#define STR0060 "Procedure 1"
		#define STR0061 "Procedure 2"
		#define STR0062 "_____________________________"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "LIQUIDACION DEFINITIVA", "LIQUIDAÇÃO DEFINITIVA" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Empresa: ", "Empresa:" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Sucursal: ", "Filial:" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "NIT: ", "NIT:" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Matrícula: ", "Matrícula:" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Nombre: ", "Nome" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Tipo Id: ", "Tipo Id:" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "No. Id: ", "Nº Id:" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Centro Costos: ", "Centro Custos:" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Departamento: ", "Departamento:" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Cargo: ", "Cargo:" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Función: ", "Função:" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Sindicato: ", "Sindicato:" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Proceso: ", "Processo:" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "EPS: ", "EPS:" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "AFP: ", "AFP:" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "ARL: ", "ARL:" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "CCF: ", "CCF:" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Oficio: ", "Ocupação:" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Horas por mes: ", "Horas por Mês:" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "ReteFte: ", "ReteFte:" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "% ReteFte: ", "% ReteFte:" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Tipo Cesantia: ", "Tipo Seg. Desemprego:" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Tipo Salario: ", "Tipo Salário:" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Salario: ", "Salário:" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Fecha Ingreso: ", "Data de Admissão:" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Fecha Reconocimiento: ", "Data de Reconhecimento:" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Último Aumento: ", "Último Reajuste:" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Contrato: ", "Contrato:" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Fecha Retiro: ", "Data de Saída:" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Motivo Retiro: ", "Motivo Saída:" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "DEVENGOS", "REMUNERACIONES" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "DEDUCCIONES", "DEDUÇÕES" )
		#define STR0034 "BASES"
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Con ", "Com" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Descripción", "Descrição" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Día/Hora", "Dia/Hora" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "Valor ", "Valor" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Total Devengos ", "Total Remunerações" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Total Deducciones", "Total Deduções" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Neto", "Líquido" )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "hago constar que ", "deixo constância que" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", " queda a paz y salvo por concepto de prestaciones sociales ya que todos los derechos me han sido reconocidos oportunamente.", "fica em paz e à salvo a verba por prestações sociais já que todos os meus direitos foram reconhecimentos oportunamente." )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "de acuerdo con las disposiciones legales y en consecuencia firmo ante testigos.", "conforme as disposições legais e pelo exposto assino perante testemunha." )
		#define STR0045 "Aprovada"
		#define STR0046 If( cPaisLoc $ "ANG|PTG", "Valor ", "Valor" )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", ", ", "," )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "Ubígueo ", "Ubigeo" )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", " Continua ... ", "Prosseguir..." )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "Total Devengos: ", "Total Remunerações:" )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "Total Deducciones: ", "Total Deduções:" )
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "Neto: ", "Líquido:" )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "Mediante el recibo de $", "Pelo recibo de $" )
		#define STR0054 "Preparada"
		#define STR0055 "Revisada"
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "Aprobada", "Aprovada" )
		#define STR0057 "Matrícula"
		#define STR0058 If( cPaisLoc $ "ANG|PTG", "Centro de Trabajo", "Centro de Trabalho" )
		#define STR0059 If( cPaisLoc $ "ANG|PTG", "La opción Planilla no se encuentra disponible", "A opção Planilha não está disponível" )
		#define STR0060 If( cPaisLoc $ "ANG|PTG", "Procedimiento 1", "Procedimento 1" )
		#define STR0061 If( cPaisLoc $ "ANG|PTG", "Procedimiento 2", "Procedimento 2" )
		#define STR0062 "_____________________________"
	#endif
#endif
