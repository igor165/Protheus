#ifdef SPANISH
	#define STR0001 "Grupos de depreciaciуn"
	#define STR0002 "Просмотр"
	#define STR0003 "Создать"
	#define STR0004 "Изменить"
	#define STR0005 "Удалить"
#else
	#ifdef ENGLISH
		#define STR0001 "Depreciation Groups"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Depreciation Groups", "Grupos de depreciaзгo" )
		#define STR0002 "Просмотр"
		#define STR0003 "Создать"
		#define STR0004 "Изменить"
		#define STR0005 "Удалить"
	#endif
#endif
