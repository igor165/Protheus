#ifdef SPANISH
	#define STR0001 "Operacion"
	#define STR0002 "Nombre del recurso"
	#define STR0003 "Calendario"
	#define STR0004 "Cod. producto"
	#define STR0005 "Producto"
	#define STR0006 "Orden de produccion"
	#define STR0007 "ID"
	#define STR0008 "Nombre"
	#define STR0009 "Text1"
	#define STR0010 "Text2"
	#define STR0011 "Text3"
	#define STR0012 "Text4"
	#define STR0013 "Text5"
	#define STR0014 "Duration"
	#define STR0015 "Start"
	#define STR0016 "Finish"
#else
	#ifdef ENGLISH
		#define STR0001 "Operation"
		#define STR0002 "Resource´s Name"
		#define STR0003 "Calendar"
		#define STR0004 "Product Code"
		#define STR0005 "Product"
		#define STR0006 "Production Order"
		#define STR0007 "ID"
		#define STR0008 "Name"
		#define STR0009 "Text1"
		#define STR0010 "Text2"
		#define STR0011 "Text3"
		#define STR0012 "Text4"
		#define STR0013 "Text5"
		#define STR0014 "Duration"
		#define STR0015 "Start"
		#define STR0016 "Finish"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Operação", "Operacao" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Nome Do Recurso", "Nome do Recurso" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Calendário", "Calendario" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Cód. Produto", "Cod. Produto" )
		#define STR0005 "Produto"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Ordem De Producao", "Ordem de Producao" )
		#define STR0007 "ID"
		#define STR0008 "Name"
		#define STR0009 "Text1"
		#define STR0010 "Text2"
		#define STR0011 "Text3"
		#define STR0012 "Text4"
		#define STR0013 "Text5"
		#define STR0014 "Duration"
		#define STR0015 "Start"
		#define STR0016 "Finish"
	#endif
#endif
