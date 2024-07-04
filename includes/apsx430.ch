#ifdef SPANISH
	#define STR0001 "Archivo de Paquetes"
	#define STR0002 "Archivo de Paquetes"
	#define STR0003 "Archivo de Paquetes"
	#define STR0004 "Archivo de Paquetes"
	#define STR0005 "Archivo de Paquetes"
	#define STR0006 "El modo de acceso de los items no puede ser igual al modo de acceso del encabezado"
	#define STR0007 "Existen owners duplicados en los items"
	#define STR0008 "Copia Paquetes"
	#define STR0009 "Paquete origen"
	#define STR0010 "Paquete destino"
	#define STR0011 "Abierto"
	#define STR0012 "Situacion"
	#define STR0013 "Incorporado"
	#define STR0014 "Cerrado"
	#define STR0015 "En mantenimiento"
	#define STR0016 "Bloqueado"
	#define STR0017 "Atencion"
	#define STR0018 "Este paquete no puede borrase pue esta vinculado al proyecto "
	#define STR0019 "Salir"
	#define STR0020 "Este paquete no puede borrarse pues esta en uso en las tablas de movimiento"
	#define STR0021 "Salir"
	#define STR0022 "Atencion"
	#define STR0023 "Este paquete no puede retirarse de la estructura pues esta en uso en las tablas de movimiento"
	#define STR0024 "Salir"
	#define STR0025 "Buscar"
	#define STR0026 "Visualizar"
	#define STR0027 "Incluir"
	#define STR0028 "Modificar"
	#define STR0029 "Copiar"
	#define STR0030 "Borrar"
	#define STR0031 "Leyenda"
	#define STR0032 "Atencion"
	#define STR0033 "Solo aprobacion"
	#define STR0034 "Solo .CH"
	#define STR0035 "Abierto sin incl. de tabla"
	#define STR0036 "En SQA"
	#define STR0037 "Vincular paquete a un proyecto"
	#define STR0038 "C�digo del proyecto"
	#define STR0039 "Confirmar"
	#define STR0040 "Salir"
	#define STR0041 "No es posible vincular. Este paquete ya est� vinculado al proyecto: "
	#define STR0042 "Se realiz� el v�nculo con el proyecto: "
	#define STR0043 "�Operaci�n anulada!"
	#define STR0044 "Vincular"
	#define STR0045 "Componentes"
	#define STR0046 "No es posible consultar. Este paquete no est� vinculado a un proyecto."
	#define STR0047 "Rastreo"
#else
	#ifdef ENGLISH
		#define STR0001 "Package Registration"
		#define STR0002 "Package Registration"
		#define STR0003 "Package Registration"
		#define STR0004 "Package Registration"
		#define STR0005 "Package Registration"
		#define STR0006 "The access mode of the items cannot be equal to the access mode of the header"
		#define STR0007 "There are duplicated owners in the items"
		#define STR0008 "Copy Packages"
		#define STR0009 "Origin Package"
		#define STR0010 "Destination package"
		#define STR0011 "Open"
		#define STR0012 "Status"
		#define STR0013 "Incorporated"
		#define STR0014 "Closed"
		#define STR0015 "Under Maintenance"
		#define STR0016 "Blocked"
		#define STR0017 "Attention"
		#define STR0018 "This package cannot be deleted because it is linked to the project "
		#define STR0019 "Exit"
		#define STR0020 "This package cannot be deleted because it is being used in movement tables"
		#define STR0021 "Exit"
		#define STR0022 "Attention"
		#define STR0023 "This package cannot be removed from structure because it is being used in movement tables"
		#define STR0024 "Exit"
		#define STR0025 "Search"
		#define STR0026 "View"
		#define STR0027 "Add"
		#define STR0028 "Edit"
		#define STR0029 "Copy"
		#define STR0030 "Delete"
		#define STR0031 "Caption"
		#define STR0032 "Attention"
		#define STR0033 "Only approval"
		#define STR0034 "Only .CH"
		#define STR0035 "Open without table addition"
		#define STR0036 "In SQA"
		#define STR0037 "Relate package to a process"
		#define STR0038 "Project Code"
		#define STR0039 "Confirm"
		#define STR0040 "Quit"
		#define STR0041 "Unable to relate. This package is already related to project: "
		#define STR0042 "Related to project: "
		#define STR0043 "Operation canceled!"
		#define STR0044 "Link"
		#define STR0045 "Components"
		#define STR0046 "Unable to query. Package not associated with project."
		#define STR0047 "Tracking"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Registo de pacotes", "Cadastro de Pacotes" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Registo de pacotes", "Cadastro de Pacotes" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Registo de pacotes", "Cadastro de Pacotes" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Registo de pacotes", "Cadastro de Pacotes" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Registo de pacotes", "Cadastro de Pacotes" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "O modo de acesso dos itens n�o pode ser igual ao modo de acesso do cabe�alho", "O modo de acesso dos itens n�o pode ser igual ao modo de acesso do cabecalho" )
		#define STR0007 "Existem owners duplicados nos itens"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Copia pacotes", "Copia Pacotes" )
		#define STR0009 "Pacote origem"
		#define STR0010 "Pacote destino"
		#define STR0011 "Aberto"
		#define STR0012 "Situa��o"
		#define STR0013 "Incorporado"
		#define STR0014 "Fechado"
		#define STR0015 "Em manuten��o"
		#define STR0016 "Bloqueado"
		#define STR0017 "Aten��o"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Este pacote n�o pode ser exclu�do, pois est� vinculado ao projecto ", "Este pacote n�o pode ser exclu�do pois est� vinculado ao projeto " )
		#define STR0019 "Sair"
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Este pacote n�o pode ser exclu�do, pois est� em uso nas tabelas de movimento", "Este pacote n�o pode ser exclu�do pois est� em uso nas tabelas de movimento" )
		#define STR0021 "Sair"
		#define STR0022 "Aten��o"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Este pacote n�o pode ser retirado da estrutura, pois est� em uso nas tabelas de movimento", "Este pacote n�o pode ser retirado da estrutura pois est� em uso nas tabelas de movimento" )
		#define STR0024 "Sair"
		#define STR0025 "Pesquisar"
		#define STR0026 "Visualizar"
		#define STR0027 "Incluir"
		#define STR0028 "Alterar"
		#define STR0029 "Copiar"
		#define STR0030 "Excluir"
		#define STR0031 "Legenda"
		#define STR0032 "Aten��o"
		#define STR0033 "S� aprova��o"
		#define STR0034 "Apenas .CH"
		#define STR0035 "Aberto sem incl. de tabela"
		#define STR0036 "Em SQA"
		#define STR0037 "Vincular pacote a um projeto"
		#define STR0038 "C�digo do Projeto"
		#define STR0039 "Confirmar"
		#define STR0040 "Abandonar"
		#define STR0041 "N�o � poss�vel vincular. Este pacote j� est� vinculado ao projeto: "
		#define STR0042 "Efetuado v�nculo ao projeto: "
		#define STR0043 "Opera��o cancelada !"
		#define STR0044 "Vincular"
		#define STR0045 "Componentes"
		#define STR0046 "N�o � poss�vel consultar. Este pacote n�o est� vinculado a um projeto."
		#define STR0047 "Rastreamento"
	#endif
#endif
