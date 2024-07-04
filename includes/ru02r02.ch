#ifdef SPANISH
	#define STR0001 "января"
	#define STR0002 "февраля"
	#define STR0003 "марта"
	#define STR0004 "апреля"
	#define STR0005 "мая"
	#define STR0006 "июня"
	#define STR0007 "июля"
	#define STR0008 "августа"
	#define STR0009 "сентября"
	#define STR0010 "октября"
	#define STR0011 "ноября"
	#define STR0012 "декабря"
	#define STR0013 "г"
	#define STR0014 "de"
	#define STR0015 "Impresiуn de factura"
	#define STR0016 "Atenciуn: los datos del suscriptor no se informaron"
	#define STR0017 "Atenciуn"
	#define STR0018 "los datos del suscriptor no se informaron"
	#define STR0019 "#"
#else
	#ifdef ENGLISH
		#define STR0001 "january"
		#define STR0002 "february"
		#define STR0003 "march"
		#define STR0004 "april"
		#define STR0005 "may"
		#define STR0006 "june"
		#define STR0007 "july"
		#define STR0008 "august"
		#define STR0009 "september"
		#define STR0010 "october"
		#define STR0011 "november"
		#define STR0012 "december "
		#define STR0013 "y"
		#define STR0014 "from"
		#define STR0015 " Invoice printing"
		#define STR0016 "Warning: signer’s data has not entered"
		#define STR0017 "Warning"
		#define STR0018 "signer’s data has not entered"
		#define STR0019 "#"
	#else
		#define STR0001 "января"
		#define STR0002 "февраля"
		#define STR0003 "марта"
		#define STR0004 "апреля"
		#define STR0005 "мая"
		#define STR0006 "июня"
		#define STR0007 "июля"
		#define STR0008 "августа"
		#define STR0009 "сентября"
		#define STR0010 "октября"
		#define STR0011 "ноября"
		#define STR0012 "декабря"
		#define STR0013 "г"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "от", "de" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Печать счета-фактуры", "Impressгo da fatura" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Внимание, подписанты не указаны", "Atenзгo: os dados do assinante nгo foram informados" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Внимание", "Atenзгo" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "подписанты не указаны", "os dados do assinante nгo foram informados" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "№", "#" )
	#endif
#endif
