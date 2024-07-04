#ifdef SPANISH
	#define STR0001 "Liberacion de Venta"
	#define STR0002 "Buscar"
	#define STR0003 "Visualizar"
	#define STR0004 "Liberar"
	#define STR0005 "Liberacion"
	#define STR0006 "¡Usuario no autorizado! Verificar Equipo Tecnico, campo "
	#define STR0007 "Atencion"
	#define STR0008 "Rechazar"
	#define STR0009 "¿Desea realmente rechazar este Pedido de liberación?"
	#define STR0010 "Operación de rechazo de pedido interrumpida"
	#define STR0011 "Solicitud de liberación de venta ya se liberó o rechazó."
#else
	#ifdef ENGLISH
		#define STR0001 "Release of Sale"
		#define STR0002 "Search"
		#define STR0003 "View"
		#define STR0004 "Release"
		#define STR0005 "Release"
		#define STR0006 "User not authorized! Check Technical Team, field "
		#define STR0007 "Attention"
		#define STR0008 "Reject"
		#define STR0009 "Reject Release Request?"
		#define STR0010 "Release Request operation aborted"
		#define STR0011 "Request of sales release has already been released or rejected."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Liberação de Venda", "Liberacao de Venda" )
		#define STR0002 "Pesquisar"
		#define STR0003 "Visualizar"
		#define STR0004 "Liberar"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Liberação", "Liberacao" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Utilizador não autorizado! Verificar Equipa Técnica, campo ", "Usuario não autorizado! Verificar Equipe Tecnica, campo " )
		#define STR0007 "Atenção"
		#define STR0008 "Rejeitar"
		#define STR0009 "Deseja realmente rejeitar este Pedido de Liberação?"
		#define STR0010 "Operação de Rejeição de Pedido abortada"
		#define STR0011 "Solicitação de liberação de venda já foi liberada ou rejeitada."
	#endif
#endif
