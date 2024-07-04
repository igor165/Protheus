#ifdef SPANISH
	#define STR0001 "Atención"
	#define STR0002 "El campo ###, debe ser informado."
	#define STR0003 "OK"
	#define STR0004 "Detalles de verificación del producto"
	#define STR0005 "Orden"
	#define STR0006 "&Retorna"
#else
	#ifdef ENGLISH
		#define STR0001 "Attention"
		#define STR0002 "Field ### is required."
		#define STR0003 "OK"
		#define STR0004 "Product Checking Details"
		#define STR0005 "Order"
		#define STR0006 "&Return"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "El campo ###, debe ser informado.", "O campo ###, deve ser informado." )
		#define STR0003 "OK"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Detalles de verificación del producto", "Detalhes de conferência do produto" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Orden", "Ordem" )
		#define STR0006 "&Retorna"
	#endif
#endif
