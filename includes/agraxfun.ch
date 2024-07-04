#ifdef SPANISH
	#define STR0001 "Configuración de balanza"
	#define STR0002 'Devolución de comunicación con la balanza'
	#define STR0003 'Atención:'
	#define STR0004 "Caracteres de devolución"
	#define STR0005 "Ajuste el campo Script, para devolver solo caracteres referentes al peso."
	#define STR0006 "-Para esto identifique el Carácter que indica el inicio de envío de los datos."
	#define STR0007 "-Incluya una fórmula en el Campo Script Ej: Sustr(cConteudo,at(Chr(002),cConteudo)+3,7)."
	#define STR0008 "-Es importante que se utilice at() para identificar dónde se inicia el peso, porque esto hace la devolución más dinámica."
	#define STR0009 'No fue posible Capturar la devolución'
	#define STR0010 'Ayuda'
	#define STR0011 '¡Usuario no autorizado para efectuar pesajes en esta balanza!'
	#define STR0012 'Usuario'
	#define STR0013 "Balança"
	#define STR0014 '¡Usuario no registrado para utilizar esta balanza!'
	#define STR0015 'Capturar'
	#define STR0016 'Confirmar'
	#define STR0017 "Integración de balanzas"
	#define STR0018 "Esperando estabilización del peso... Visor  "
	#define STR0019 "Anular"
	#define STR0020 "No fue posible conectarse con la balanza. Intento: "
	#define STR0021 "No fue posible conectarse con la balanza en el puerto:"
	#define STR0022 'Datos recibidos'
	#define STR0023 "¡No será posible realizar el pesaje automatico, pues hay problemas en la comunicación con la balanza!"
	#define STR0024 "El código de la balanza informado no esta registrado"
	#define STR0025 "Producto seleccionado no tiene complementos de semillas."
	#define STR0026 "No fue posible capturar la devolución"
	#define STR0027 "no fue posible conectarse con la Balanza en la dirección/puerto"
	#define STR0028 "¡Usuario del grupo no autorizado a efectuar pesajes en esta balanza!"
	#define STR0029 "Grupo: "
	#define STR0030 "Peso de la balanza"
	#define STR0031 "¡Usuario no registrado para utilizar esta balanza!"
	#define STR0032 "Consulta específica usuarios o grupos Vs. Balanza"
	#define STR0033 "Sucursal + Cód. Balanza"
	#define STR0034 "Balança vinculada com usuário não disponivel."
	#define STR0035 "Verifique com o administrador do sistema."
	#define STR0036 "No se encontró vínculo del usuario o grupo de usuario vs balanza. Verifique si existe balanza registrada en el 'Registro de Balanzas' y también si existe permiso en el registro de 'Usuario vs Balanza' para el usuario o grupo de usuario."
	#define STR0037 "1º Pesaje"
	#define STR0038 "2º Pesaje"
	#define STR0039 "Subtotal"
#else
	#ifdef ENGLISH
		#define STR0001 "Scale Configuration"
		#define STR0002 'Scale communication return'
		#define STR0003 'Attention:'
		#define STR0004 "Return characters"
		#define STR0005 "Adjust the Script field, to retrieve only the characters regarding weight;"
		#define STR0006 "-For this, identify the Character that indicates the start of data sending;"
		#define STR0007 "-Include a formula on the Script field Ex: Substr(cConteudo,at(Chr(002),cConteudo)+3,7);"
		#define STR0008 "-It is important to use at() to identify where the weight starts, because it makes return more dynamic."
		#define STR0009 'Return could not be Collected'
		#define STR0010 'Help'
		#define STR0011 'User not authorized to weigh using this scale!'
		#define STR0012 'User'
		#define STR0013 "Scale"
		#define STR0014 'User not registered to use this scale!'
		#define STR0015 'Collect'
		#define STR0016 'Confirm'
		#define STR0017 "Scale Integration"
		#define STR0018 "Waiting for weight stabilization.... Display  "
		#define STR0019 "Cancel"
		#define STR0020 "Could not connect to scale. Attempt: "
		#define STR0021 "Could not connect to Scale at Port:"
		#define STR0022 'Received Data'
		#define STR0023 "Cannot perform automatic weighing because communication problems with the scale exist!"
		#define STR0024 "Scale code entered is not registered"
		#define STR0025 "Product selected has no seed complements."
		#define STR0026 "Return could not be Collected"
		#define STR0027 "could not connect to Scale at address/port"
		#define STR0028 "Group user not authorized to weight using this scale"
		#define STR0029 "Group: "
		#define STR0030 "Scale Weight"
		#define STR0031 "Group user not registered to use this scale"
		#define STR0032 "Specific Search Users or Groups x Scale"
		#define STR0033 "Branch + Scale Code"
		#define STR0034 "Scale linked to user not available"
		#define STR0035 "Check with system administrator"
		#define STR0036 "No user or user group x scale relationship found. Check whether there is a scale is registered in ‘Scale Register’ and also a permission in the ‘User x Scale’ register for the user or user group."
		#define STR0037 "1st Weighing"
		#define STR0038 "2nd Weighing"
		#define STR0039 "Subtotal"
	#else
		#define STR0001 "Configuração de Balança"
		#define STR0002 'Retorno de comunicação com a balança'
		#define STR0003 'Atenção:'
		#define STR0004 "Caracteres de retorno"
		#define STR0005 "Ajuste o campo Script, para retornar somente os caracteres ref. ao peso;"
		#define STR0006 "-Para isso identifique o Caracter que indica o inicio do envio dos dados;"
		#define STR0007 "-Inclua uma formula no Campo Script Ex: Substr(cConteudo,at(Chr(002),cConteudo)+3,7);"
		#define STR0008 "-É importante que utilize at() para identificar onde se inicia o peso, pois isto torna o retorno mais dinamico."
		#define STR0009 'Não foi possível Capturar o Retorno'
		#define STR0010 "Ajuda"
		#define STR0011 "Usuário não autorizado a pesar usando essa balança"
		#define STR0012 "Usuário"
		#define STR0013 "Balança"
		#define STR0014 "Usuário não cadastrado para usar essa balança"
		#define STR0015 "Coletar"
		#define STR0016 "Confirmar"
		#define STR0017 "Integração de balanças"
		#define STR0018 "Aguardando estabilização do peso Exibir  "
		#define STR0019 "Cancelar"
		#define STR0020 "Não foi possível conectar com a balança Tentativa: "
		#define STR0021 "Não foi possível conectar com a balança no porto"
		#define STR0022 "Dados recebidos"
		#define STR0023 "Pesagem automática não é possível devido a problemas de comunicação com a balança"
		#define STR0024 "Código da balança informado não está cadastrado."
		#define STR0025 "Produto selecionado não possui complemento de semente"
		#define STR0026 "Não foi possível recolher o retorno"
		#define STR0027 "não foi possível conectar com a balança no endereço/porto"
		#define STR0028 "Usuário do grupo não autorizado a efetuar pesagens nesta balança!"
		#define STR0029 "Grupo: "
		#define STR0030 "Peso da Balança"
		#define STR0031 "Usuário do grupo não cadastrado para utilizar esta balança!"
		#define STR0032 "Consulta Específica Usuários ou Grupos X Balança"
		#define STR0033 "Filial + Cód. Balança"
		#define STR0034 "Balança vinculada com usuário não disponivel."
		#define STR0035 "Verifique com o administrador do sistema."
		#define STR0036 "Não foi encontrado relacionamento de usuário ou grupo de usuário x balança. Verifique se existe balança cadastrada no 'Cadastro de Balanças' e também se existe permissão no cadastro de 'Usuário x Balança' para o usuário ou o grupo de usuário."
		#define STR0037 "1ª Pesagem"
		#define STR0038 "2ª Pesagem"
		#define STR0039 "Subtotal"
	#endif
#endif
