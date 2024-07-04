#ifdef SPANISH
	#define STR0001 "Seleccionando Registros.."
	#define STR0002 "¿Confirma Config. de los parametros?"
	#define STR0003 "El plan de gestion aun no esta disponible en este informe."
	#define STR0004 "Error al crear tabla temporal"
	#define STR0005 "Atención"
	#define STR0006 "Fijar la configuración de la retención de ICA en la tabla de impuestos."
	#define STR0007 "Fijar la configuración de la retención de IVA en la tabla de impuestos."
	#define STR0008 "No hay retenciones generadas."
	#define STR0009 "Seleccionando Registros..."
	#define STR0010 "Creando Archivo Temporal..."
	#define STR0011 "ESTADO DE RESULTADOS"
	#define STR0012 "Desconocido"
	#define STR0013 "Ente 05 No identificado"
	#define STR0014 "Ente Cliente No Identificado"
	#define STR0015 "Ente Proveedor No Identificado"
	#define STR0016 "Ente Empleado No Identificado"
	#define STR0017 "Ente Costos No Identificado"
	#define STR0018 "Cuantías menores"
	#define STR0019 " - Inclusión"
	#define STR0020 " - Modificación"
	#define STR0021 " - Indefinido"
	#define STR0022 " - Borrado"
	#define STR0023 "Cheque"
	#define STR0024 "Transferencia"
	#define STR0035 "El Número de Columna indicada en el Plan Referencial <br>está errado y/o no existe en el Formato de la DIAN.<br> - Plan Ref:"
	#define STR0036 "Columna Plan Referencia"
#else
	#ifdef ENGLISH
		#define STR0001 "Selecting Records..."
		#define STR0002 "Do you confirm configuration of the parameters?"
		#define STR0003 "Managerial plan is not available in this report yet."
		#define STR0004 "Error when creating temporary table"
		#define STR0005 "Attention"
		#define STR0006 "Add the configuration of ICA withholding in tax table."
		#define STR0007 "Add the configuration of IVA withholding in tax table."
		#define STR0008 "No withholding generated!"
		#define STR0009 "Selecting records..."
		#define STR0010 "Creating temporary file..."
		#define STR0011 "RESULT DEMONSTRATION"
		#define STR0012 "Unknown"
		#define STR0013 "Entity 05 Not Identified"
		#define STR0014 "Client Entity Not Identified"
		#define STR0015 "Supplier Entity Not Identified"
		#define STR0016 "Employee Entity Not Identified"
		#define STR0017 "Costs Entity Not Identified"
		#define STR0018 "Smaller values"
		#define STR0019 "- Addition"
		#define STR0020 "- Edition"
		#define STR0021 "- Undefined"
		#define STR0022 "- Deletion"
		#define STR0023 "Check"
		#define STR0024 "Transfer"
		#define STR0035 "The column number indicated in the Reference Plan <br> is wrong and/or does not exist in the DIAN Format.<br> - Ref Plan:"
		#define STR0036 "Reference Plan Column"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Registos...", "Selecionando Registros..." )
		#define STR0002 "Confirma Configuração dos parâmetros?"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "O plano de gestão ainda não está disponível nesse relatório.", "O plano gerencial ainda nao está disponível nesse relatório." )
		#define STR0004 "Erro na criação da tabela temporária"
		#define STR0005 "Atenção"
		#define STR0006 "Incluir a configuração da retenção de ICA na tabela de impostos."
		#define STR0007 "Incluir a configuração da retenção de IVA na tabela de impostos."
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Não existem retenções geradas!", "Não existe retenções geradas!" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "A seleccionar Registos...", "Selecionando Registros..." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "A criar Ficheiro Temporário", "Criando Arquivo Temporário" )
		#define STR0011 "DEMONSTRAÇÃO DE RESULTADOS"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Desconocido", "Desconhecido" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Ente 05 No identificado", "Entidade 05 Não identificado" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Ente Cliente No Identificado", "Entidade Cliente Não Identificado" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Ente Proveedor No Identificado", "Entidade Fornecedor Não Identificado" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Ente Empleado No Identificado", "Entidade Funcionário Não Identificado" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Ente Costos No Identificado", "Entidade Custos Não Identificado" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Cuantías menores", "Valores menores" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", " - Inclusión", " - Inclusão" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", " - Modificación", " - Alteração" )
		#define STR0021 " - Indefinido"
		#define STR0022 If( cPaisLoc $ "ANG|PTG", " - Borrado", " - Exclusão" )
		#define STR0023 "Cheque"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Transferencia", "Transferência" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "El Número de Columna indicada en el Plan Referencial <br>está errado y/o no existe en el Formato de la DIAN.<br> - Plan Ref:", "O número de coluna indicada no Plano Referencial <br>está errado e/ou não existe no Formato da DIAN.<br> - Plano Ref:" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Columna Plan Referencia", "Coluna Plano Referencial" )
	#endif
#endif
