#ifdef SPANISH
	#define STR0001 "Para usar esta herramienta es necesario modificar el parámetro 'MV_GSGEROS' a '2' y crear las preguntas 'TEC900A'"
	#define STR0002 "Para usar esta herramienta es necesario compilar el rdmake estándar 'PNMTABC01'. Si la prueba tiene alguna modificación, para usar el estándar, modifique el parámetro 'MV_GSPNMTA' a '.T.'."
	#define STR0003 "No fue posible grabar la asignación."
	#define STR0004 "No fue posible proyectar la agenda con los parámetros informados. Por favor, revíselos."
#else
	#ifdef ENGLISH
		#define STR0001 "To use this tool, change parameter 'MV_GSGEROS' to '2' and create 'TEC900A' questions."
		#define STR0002 "To use this tool, compile default rdmake 'PNMTABC01' if the test has any changes. To use default change parameter 'MV_GSPNMTA' to '.T.'."
		#define STR0003 "Unable to save allocation."
		#define STR0004 "Unable to project schedule with the parameters set. Please, revise them."
	#else
		#define STR0001 "Para usar essa ferramenta é necessario modificar o parametro 'MV_GSGEROS' para '2' e fazer a criação dos perguntes 'TEC900A'"
		#define STR0002 "Para usar essa ferramenta é necessario fazer a compilação do rdmake padrão 'PNMTABC01' caso o teste tenha alguma modificação, para usar o padrão altere o parametro 'MV_GSPNMTA' para '.T.'. "
		#define STR0003 "Não foi possivel gravar a alocação."
		#define STR0004 "Não foi possivel projetar agenda com os parametros informados. Por favor revise-os."
	#endif
#endif
