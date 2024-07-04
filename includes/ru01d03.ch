#ifdef SPANISH
	#define STR0001 "Grp Dep vs. Cуd OKOF"
	#define STR0002 "Cуdigo de grupo y OKOF (#[GROUP]#/ #[OKOF]#) existe en la base de datos."
	#define STR0003 "Просмотр"
	#define STR0004 "Создать"
	#define STR0005 "Изменить"
	#define STR0006 "Удалить"
#else
	#ifdef ENGLISH
		#define STR0001 "Dep. Grp. x OKOF Codes"
		#define STR0002 "Group and OKOF code (#[GROUP]#/ #[OKOF]#) already exists in database."
		#define STR0003 "View"
		#define STR0004 "Add"
		#define STR0005 "Edit"
		#define STR0006 "Delete"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Dep. Grp. x OKOF Codes", "Grp Dep x Cуd OKOF" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Group and OKOF code (#[GROUP]#/ #[OKOF]#) already exists in database.", "Cуdigo de grupo e OKOF (#[GROUP]#/ #[OKOF]#) jб existe no banco de dados." )
		#define STR0003 "Просмотр"
		#define STR0004 "Создать"
		#define STR0005 "Изменить"
		#define STR0006 "Удалить"
	#endif
#endif
