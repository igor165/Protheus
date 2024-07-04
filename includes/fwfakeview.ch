#ifdef SPANISH
	#define STR0001 'Header description'
	#define STR0002 'Detail description'
#else
	#ifdef ENGLISH
		#define STR0001 'Header description'
		#define STR0002 'Detail description'
	#else
		#define STR0001 'Header description'
		#define STR0002 'Detail description'
	#endif
#endif
