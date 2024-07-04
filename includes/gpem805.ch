#ifdef SPANISH
	#define STR0001 "Archivo PLAME"
	#define STR0002 "Generación de los archivos del PLAME"
	#define STR0003 "Rellenar los Parametros"
	#define STR0004 "¡Generando Archivos... Espere!"
	#define STR0005 "PLAME  generado con exito!"
	#define STR0006 "Procesando Estructura ... "
	#define STR0007 "Archivo Texto"
	#define STR0008 "Generar en el Directorio"
	#define STR0009 "Antes de continuar es necesario ejecutar la actualizacion 'Generacion del archivo PDT layout 12/2011', disponible para el modulo SIGAGPE en el compatibilizador RHUPDMOD."
	#define STR0010 "No se genero ningun archivo"
	#define STR0011 "Campo "
	#define STR0012 " debe completarse cuando el tipo de documento es pasaporte"
	#define STR0013 " debe completarse"
	#define STR0014 "Ocurrencias para el empleado: "
	#define STR0015 "Se encontraron inconsistencias en la generación del PLAME"
	#define STR0016 "26 (Trabajador - Otras cond...)"
	#define STR0017 "12 (Trabajador Otras Rentas...)"
	#define STR0018 "14 (Datos de la jornada...)"
	#define STR0019 "15 (Trabajador - Dias subsidiados y otros no laborados...)"
	#define STR0020 " NO VALIDO TIPO DE SUSPENSION PARA EL EMPLEADO"
	#define STR0021 "VALOR MAYOR A 31 DIAS"
	#define STR0022 "18 (Detalle de ingresos, tributos y descuentos...)"
	#define STR0023 " NO VALIDO PARA EL REGIMEN PENSIONARIO DE EMPLEADO"
	#define STR0024 " NO VALIDO PARA EMPRESAS PÚBLICAS"
	#define STR0025 "21 (Modalidad en Formación - Modalidad formativa laboral y Otros - Monto pagado...)"
	#define STR0026 "07 - No Disponible"
	#define STR0027 "12 - No Disponible"
	#define STR0028 "14 - Trabajador - Datos de la Jornada Laboral"
	#define STR0029 "15 - Trabajador - Días subsidiados y otros no laborados"
	#define STR0030 "18 - Trabajador - Detalle de ingresos,tributos y descuentos"
	#define STR0031 "19 - No Disponible"
	#define STR0032 "20 - No Disponible"
	#define STR0033 "21 - Modalidad en Formación - Modalidad formativa laboral y Otros - Monto pagado"
	#define STR0034 "22 - No Disponible"
	#define STR0035 "25 - No Disponible"
	#define STR0036 "26 - Trabajador - Otras Condiciones"
	#define STR0037 "27 - No Disponible"
	#define STR0038 "28 - No Disponible"
#else
	#ifdef ENGLISH
		#define STR0001 "PLAME register"
		#define STR0002 "PLAME register generation"
		#define STR0003 "Check parameters"
		#define STR0004 "Generating Files, wait!"
		#define STR0005 "PLAME generated successfully."
		#define STR0006 "Processing Structure... "
		#define STR0007 "Text File"
		#define STR0008 "Generate in Directory"
		#define STR0009 "Before proceeding, you need to run the 'Generation of PDT layout 12/2011 file', available for the SIGAGPE module in the RHUPDMOD compatibility program."
		#define STR0010 "No file generated!"
		#define STR0011 "Field "
		#define STR0012 " You must complete it when the document type is passport"
		#define STR0013 " it must be filled in"
		#define STR0014 "Events for the employee: "
		#define STR0015 "Inconsistencies found in PLAME generation"
		#define STR0016 "26 (Employee - Other Cond...)"
		#define STR0017 "12 (Employee Other Revenues...)"
		#define STR0018 "14 (Working Hours Data...)"
		#define STR0019 "15 - (Employee - Days subsided and days not worked...)"
		#define STR0020 "TYPE OF SUSPENSION INVALID FOR THE EMPLOYEE "
		#define STR0021 "HIGHEST VALUE 31 DAYS"
		#define STR0022 "18 (Detail of revenues, taxes and discounts...)"
		#define STR0023 "INVALID FOR THE SYSTEM OF PENSIONS OF THE EMPLOYEE"
		#define STR0024 "INVALID FOR PUBLIC COMPANIES"
		#define STR0025 "21 (Modality - modality to train work personnel and Others - Value paid...)"
		#define STR0026 "07 - Not available"
		#define STR0027 "12 - Not available"
		#define STR0028 "14 - Employee- Work Hours Data"
		#define STR0029 "15 - Employee - Days subsided and days not worked"
		#define STR0030 "18 - Employee - Detail of revenues, taxes and discounts"
		#define STR0031 "19 - Not available"
		#define STR0032 "20 - Not available"
		#define STR0033 "21 - Modality for training - modality to train work personnel and Others - Value paid"
		#define STR0034 "22 - Not available"
		#define STR0035 "25 - Not available"
		#define STR0036 "26 - Employee - Other Conditions"
		#define STR0037 "27 - Not available"
		#define STR0038 "28 - Not available"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Archivo PLAME", "Cadastro PLAME" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Generación de los archivos del PLAME", "Geração dos cadastros do PLAME" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Preencha os parâmetros", "Preencher os Parâmetros" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "A Gerar Ficheiros... Aguarde!", "Gerando Arquivos... Aguarde!" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "PLAME  generado con exito!", "PLAME gerado com sucesso!" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "A Processar Estructura ... ", "Processando Estrutura ... " )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Ficheiro Texto", "Arquivo Texto" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Gerar no Directório", "Gerar no Diretório" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Antes de prosseguir, é necessário executar a actualização 'Geração do ficheiro PDT layout 12/2011', disponível para o módulo SIGAGPE no compatibilizador RHUPDMOD.", "Antes de prosseguir é necessário executar a atualizaçao 'Geracao do arquivo PDT layout 12/2011', disponível para o módulo SIGAGPE no compatibilizador RHUPDMOD." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Nenhum ficheiro gerado!", "Nenhum arquivo gerado!" )
		#define STR0011 "Campo "
		#define STR0012 " deve ser preenchido quando o tipo de documento é passaporte"
		#define STR0013 " deve ser preenchido"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Ocorrências para o colaborador: ", "Ocorrências para o funcionário: " )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Se encontraron inconsistencias en la generación del PLAME", "Foram encontradas inconsistências na geração do PLAME" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "26 (Trabajador - Otras cond...)", "26 (Funcionário - Outras Cond...)" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "12 (Trabajador Otras Rentas...)", "12 (Funcionário Outras Rendas...)" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "14 (Datos de la jornada...)", "14 (Dados da Jornada...)" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "15 (Trabajador - Dias subsidiados y otros no laborados...)", "15 (Funcionário - Dias subsidiados e outros não trabalhados...)" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", " NO VALIDO TIPO DE SUSPENSION PARA EL EMPLEADO", "TIPO DE SUSPENSÃO INVÁLIDA PARA O FUNCIONÁRIO " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "VALOR MAYOR A 31 DIAS", "VALOR MAIOR A 31 DIAS" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "18 (Detalle de ingresos, tributos y descuentos...)", "18 (Detalhe de rendimentos, tributos e descontos...)" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", " NO VALIDO PARA EL REGIMEN PENSIONARIO DE EMPLEADO", "INVÁLIDO PARA O REGIME DE PENSÕES DO FUNCIONÁRIO" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", " NO VALIDO PARA EMPRESAS PÚBLICAS", "INVÁLIDO PARA EMPRESAS PÚBLICAS" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "21 (Modalidad en Formación - Modalidad formativa laboral y Otros - Monto pagado...)", "21 (Modalidade em Formação - Modalidade formativa de trabalho e Outros - Valor pago...)" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "07 - No Disponible", "07 - Não Disponível" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "12 - No Disponible", "12 - Não Disponível" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "14 - Trabajador - Datos de la Jornada Laboral", "14 - Funcionário - Dados da Jornada de Trabalho" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "15 - Trabajador - Días subsidiados y otros no laborados", "15 - Funcionário - Dias subsidiados e outros não trabalhados" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "18 - Trabajador - Detalle de ingresos,tributos y descuentos", "18 - Funcionário - Detalhe de rendimentos, tributos e descontos" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "19 - No Disponible", "19 - Não Disponível" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "20 - No Disponible", "20 - Não Disponível" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "21 - Modalidad en Formación - Modalidad formativa laboral y Otros - Monto pagado", "21 - Modalidade em Formação - Modalidade formativa de trabalho e Outros - Valor pago" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "22 - No Disponible", "22 - Não Disponível" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "25 - No Disponible", "25 - Não Disponível" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "26 - Trabajador - Otras Condiciones", "26 - Funcionário - Outras Condições" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "27 - No Disponible", "27 - Não Disponível" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "28 - No Disponible", "28 - Não Disponível" )
	#endif
#endif
