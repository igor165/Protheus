#ifdef SPANISH
	#define STR0001 "Asignar transportadora, vehículo y acoplado."
	#define STR0002 "Sucursal"
	#define STR0003 "Existen registros sin asignar vehiculo."
	#define STR0004 "Seleccionando registros... "
	#define STR0005 "Por favor espere. "
	#define STR0006 "Documento"
	#define STR0007 "Cliente"
	#define STR0008 "Sucursal"
	#define STR0009 "Serie"
	#define STR0010 "Transportadora"
	#define STR0011 "Vehiculo"
	#define STR0012 "Acoplado"
	#define STR0013 "Asignar Transportadora"
	#define STR0014 "Asignar Vehiculo"
	#define STR0015 "Asignar Acoplado"
	#define STR0016 "Fecha de Emision"
	#define STR0017 "No se realizó ninguna asignación."
	#define STR0018 "No se informó registro."
	#define STR0019 "Existen registros sin asignar transportadora."
	#define STR0020 "El tipo de vehículo debe de ser acoplado."
	#define STR0021 "El tipo de vehículo debe de ser diferente de acoplado."
	#define STR0022 "No existe el tipo de vehículo."
#else
	#ifdef ENGLISH
		#define STR0001 "Asignar transportadora, vehículo y acoplado."
		#define STR0002 "Sucursal"
		#define STR0003 "Existen registros sin asignar vehiculo."
		#define STR0004 "Seleccionando registros... "
		#define STR0005 "Por favor espere. "
		#define STR0006 "Documento"
		#define STR0007 "Cliente"
		#define STR0008 "Sucursal"
		#define STR0009 "Serie"
		#define STR0010 "Transportadora"
		#define STR0011 "Vehiculo"
		#define STR0012 "Acoplado"
		#define STR0013 "Asignar Transportadora"
		#define STR0014 "Asignar Vehiculo"
		#define STR0015 "Asignar Acoplado"
		#define STR0016 "Fecha de Emision"
		#define STR0017 "No se realizó ninguna asignación."
		#define STR0018 "No se informó registro."
		#define STR0019 "Existen registros sin asignar transportadora."
		#define STR0020 "El tipo de vehículo debe de ser acoplado."
		#define STR0021 "El tipo de vehículo debe de ser diferente de acoplado."
		#define STR0022 "No existe el tipo de vehículo."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Asignar transportadora, vehículo y acoplado.", "Aloca transportadora, veiculo e reboque." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Sucursal", "Filial" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Existen registros sin asignar vehiculo.", "Existem registros sem alocar veiculo." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Seleccionando registros... ", "Selecionando registros... " )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Por favor espere. ", "Por favor aguarde. " )
		#define STR0006 "Documento"
		#define STR0007 "Cliente"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Sucursal", "Filial" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Serie", "Série" )
		#define STR0010 "Transportadora"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Vehiculo", "Veiculo" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Acoplado", "Reboque" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Asignar Transportadora", "Alocar Transportadora" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Asignar Vehiculo", "Alocar Veiculo" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Asignar Acoplado", "Alocar Reboque" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Fecha de Emision", "Data de Emissão" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "No se realizó ninguna asignación.", "Não foi efetuada nenhuma alocação." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "No se informó registro.", "Não foi informado nenhum registro." )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Existen registros sin asignar transportadora.", "Existem registros sem alocar transportadora." )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "El tipo de vehículo debe de ser acoplado.", "O tipo de veiculo deve de ser reboque." )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "El tipo de vehículo debe de ser diferente de acoplado.", "O tipo de veiculo deve de ser diferente de reboque." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "No existe el tipo de vehículo.", "Não existe o tipo de veiculo." )
	#endif
#endif
