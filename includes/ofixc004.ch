#ifdef SPANISH
	#define STR0001 "Pantalla"
	#define STR0002 "Datos"
	#define STR0003 "Letrero"
	#define STR0004 "Altura"
	#define STR0005 "PARAMETROS - Panel de Taller"
	#define STR0006 "Linea 1"
	#define STR0007 "Linea 2"
	#define STR0008 "Color: "
	#define STR0009 "Dias para Filtor de Datos"
	#define STR0010 "Anterior a DataBase"
	#define STR0011 "Posterior a DataBase"
	#define STR0012 "Espacio"
	#define STR0013 "Posicion"
	#define STR0014 "Lineas"
	#define STR0015 "Exhibir"
	#define STR0016 "Prevision"
	#define STR0017 "Fuente"
	#define STR0018 "Pequena"
	#define STR0019 "Media"
	#define STR0020 "Grande"
	#define STR0021 "Tiempos de actualizacion en segundos "
	#define STR0022 "minimo 30"
	#define STR0023 "minimo 300 (5 min)"
	#define STR0024 "Muestra"
	#define STR0025 "Leyenda nota pie de pagina"
	#define STR0026 "Atencion"
	#define STR0027 "�Desea volver a las configuraciones default?"
	#define STR0028 "Restaurar Parametros Default"
	#define STR0029 "Aguardando Presupuesto"
	#define STR0030 "No"
	#define STR0031 "Si"
	#define STR0032 "OS"
	#define STR0033 "Matricula"
	#define STR0034 "Modelo"
	#define STR0035 "Cliente"
	#define STR0036 "Box"
	#define STR0037 "Consultor"
	#define STR0038 "Entrada"
	#define STR0039 "Prevision Salida"
	#define STR0040 "Progreso"
	#define STR0041 "�De Prevision?"
	#define STR0042 "�A Prevision?"
	#define STR0043 'OS con servicio(s) en proceso'
	#define STR0044 'OS con servicio(s) en pausa'
	#define STR0045 'OS liberada para facturacion'
	#define STR0046 "Nombre Fuente "
	#define STR0047 "Tama�o"
	#define STR0048 "Actualiza pantalla"
	#define STR0049 "Actualiza pantalla entera"
	#define STR0050 "�Es necesario reiniciar la rutina!"
	#define STR0051 "Filtrar"
	#define STR0052 "TT P�blico"
	#define STR0053 "TT Garant�a"
	#define STR0054 "TT Interno"
	#define STR0055 "TT Revisi�n"
	#define STR0056 "Excepto TT"
	#define STR0057 "Filtro"
#else
	#ifdef ENGLISH
		#define STR0001 "Screen"
		#define STR0002 "Data"
		#define STR0003 "Sign"
		#define STR0004 "Height"
		#define STR0005 "PARAMETERS - WORSHOP PANEL"
		#define STR0006 "Line 1"
		#define STR0007 "Line 2"
		#define STR0008 "Color: "
		#define STR0009 "Days for Data Filter"
		#define STR0010 "Before BaseDate"
		#define STR0011 " After BaseDate"
		#define STR0012 "Spacing"
		#define STR0013 "Position"
		#define STR0014 "Rows"
		#define STR0015 "Display"
		#define STR0016 "Forecast"
		#define STR0017 "Source"
		#define STR0018 "Small"
		#define STR0019 "Medium"
		#define STR0020 "Large"
		#define STR0021 "Update time in seconds"
		#define STR0022 "minimum 30"
		#define STR0023 "minimum 300 (5 min)"
		#define STR0024 "Display"
		#define STR0025 "Footer caption"
		#define STR0026 "Attention"
		#define STR0027 "Do you want to save default configurations?"
		#define STR0028 "Restore Default Parameters"
		#define STR0029 "Waiting Budget"
		#define STR0030 "No"
		#define STR0031 "Yes"
		#define STR0032 "SO"
		#define STR0033 "License Plate"
		#define STR0034 "Model"
		#define STR0035 "Customer"
		#define STR0036 "Box"
		#define STR0037 "Consultant"
		#define STR0038 "Inflow"
		#define STR0039 "Estimated Outflow"
		#define STR0040 "Progress"
		#define STR0041 "Estimate From?"
		#define STR0042 "Estimate To?"
		#define STR0043 'SO with service(s) in progress'
		#define STR0044 'SO with paused service(s)'
		#define STR0045 'SO released for invoicing'
		#define STR0046 "Font Name"
		#define STR0047 "Size"
		#define STR0048 "Update Screen"
		#define STR0049 "Update the whole screen"
		#define STR0050 "You must restart routine!"
		#define STR0051 "Filter"
		#define STR0052 "Public TT"
		#define STR0053 "Warranty TT"
		#define STR0054 "Internal TT"
		#define STR0055 "Inspection TT"
		#define STR0056 "Except TT"
		#define STR0057 "Filter"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Ecr�", "Tela" )
		#define STR0002 "Dados"
		#define STR0003 "Letreiro"
		#define STR0004 "Altura"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "PAR�METROS - Painel de Oficina", "PARAMETROS - Painel de Oficina" )
		#define STR0006 "Linha 1"
		#define STR0007 "Linha 2"
		#define STR0008 "Cor: "
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Dias para filtro de dados", "Dias para Filtro de Dados" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Anterior � DataBase", "Anterior a DataBase" )
		#define STR0011 "Posterior a DataBase"
		#define STR0012 "Espa�amento"
		#define STR0013 "Posi��o"
		#define STR0014 "Linhas"
		#define STR0015 "Exibir"
		#define STR0016 "Previs�o"
		#define STR0017 "Fonte"
		#define STR0018 "Pequena"
		#define STR0019 "M�dia"
		#define STR0020 "Grande"
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Tempos de actualiza��o em segundos", "Tempos de atualiza��o em segundos" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "m�nimo 30", "minimo 30" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "m�nimo 300 (5 min)", "minimo 300 (5 min)" )
		#define STR0024 "Exibe"
		#define STR0025 "Legenda rodap�"
		#define STR0026 "Aten��o"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Deseja voltar �s configura��es padr�es?", "Deseja voltar as configura��es default?" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Restaurar par�metros padr�es", "Restaurar Parametros Default" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "A aguardar or�amento", "Aguardando Or�amento" )
		#define STR0030 "N�o"
		#define STR0031 "Sim"
		#define STR0032 "OS"
		#define STR0033 "Placa"
		#define STR0034 "Modelo"
		#define STR0035 "Cliente"
		#define STR0036 "Box"
		#define STR0037 "Consultor"
		#define STR0038 "Entrada"
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Previs�o sa�da", "Previs�o Sa�da" )
		#define STR0040 "Progresso"
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "De previs�o?", "Previs�o De ?" )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "At� previs�o?", "Previs�o At� ?" )
		#define STR0043 'OS com servi�o(s) em andamento'
		#define STR0044 'OS com servi�o(s) em pausa'
		#define STR0045 If( cPaisLoc $ "ANG|PTG", 'OS liberada para factura��o', 'OS liberada para faturamento' )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", "Nome fonte", "Nome Fonte" )
		#define STR0047 "Tamanho"
		#define STR0048 "Atualiza Tela"
		#define STR0049 "Atualiza tela inteira"
		#define STR0050 "Necess�rio reiniciar a rotina!"
		#define STR0051 "Filtrar"
		#define STR0052 "TT P�blico"
		#define STR0053 "TT Garantia"
		#define STR0054 "TT Interno"
		#define STR0055 "TT Revis�o"
		#define STR0056 "Exceto TT"
		#define STR0057 "Filtro"
	#endif
#endif
