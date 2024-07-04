#ifdef SPANISH
	#define STR0001 "Presente"
	#define STR0002 "Por la presente y en cumplimiento del Art. 222 del Código del trabajo, ponemos"
	#define STR0003 "a su conocimiento que las vacaciones que le corresponden de acuerdo a su antigüedad, "
	#define STR0004 "de"
	#define STR0005 " días, deberá usufructuar, desde el "
	#define STR0006 "El empleado recibe "
	#define STR0007 " de "
	#define STR0008 ", "
	#define STR0009 " correspondiente al período"
	#define STR0010 "-"
	#define STR0011 "debiendo reintegrarse a sus labores el día "
	#define STR0012 "."
	#define STR0013 "Sirvase pasar por la tesorería, el día "
	#define STR0014 " para percibir los"
	#define STR0015 "Atentamente. "
	#define STR0016 "__________________________________"
	#define STR0017 "RECIBÍ CONFORME"
	#define STR0018 "COMUNICACIÓN DE VACACIONES"
	#define STR0019 "haberes que le corresponden en concepto de vacaciones."
	#define STR0020 "Aviso de Vacaciones"
	#define STR0021 "Configure parámetro "
	#define STR0022 "MV_RELSERV"
	#define STR0023 "MV_RELACNT"
	#define STR0024 "MV_RELPSW"
	#define STR0025 "Configure email del cliente."
	#define STR0026 "Error en el Envio del Email"
	#define STR0027 "Se consigna en documento adjunto su Aviso de Vacaciones"
	#define STR0028 "Sr.(a)"
	#define STR0029 "Aviso"
	#define STR0030 "Tiempo de Servidor"
	#define STR0031 "Autenticación con servidor smtp"
	#define STR0032 "AVISO DE VACACIONES"
	#define STR0033 "Representación de Aviso de Vacaciones"
#else
	#ifdef ENGLISH
		#define STR0001 "Communication"
		#define STR0002 "Hereby and in compliance with Art. 222 of the Labor Law,"
		#define STR0003 "we inform you that the vacation to which you are entitled for length of service,"
		#define STR0004 "of"
		#define STR0005 "days, must be enjoyed as of"
		#define STR0006 "The employee receives"
		#define STR0007 "of"
		#define STR0008 ","
		#define STR0009 "corresponding to the period"
		#define STR0010 "-"
		#define STR0011 "**"
		#define STR0012 "."
		#define STR0013 "Present yourself at the treasury office on"
		#define STR0014 "to receive"
		#define STR0015 "Sincerely,"
		#define STR0016 "__________________________________"
		#define STR0017 "RECEIVED ACCORDING"
		#define STR0018 "VACATION NOTICE"
		#define STR0019 "payment corresponding to vacation."
		#define STR0020 "Vacation Notice"
		#define STR0021 "Set parameter"
		#define STR0022 "MV_RELSERV"
		#define STR0023 "MV_RELACNT"
		#define STR0024 "MV_RELPSW"
		#define STR0025 "Set customer’s e-mail."
		#define STR0026 "Error sending email"
		#define STR0027 "Your Vacation Notice is attached."
		#define STR0028 "Mr./Ms."
		#define STR0029 "Warning"
		#define STR0030 "Server Time"
		#define STR0031 "SMTP server authentication"
		#define STR0032 "VACATION NOTICE"
		#define STR0033 "Representation of Vacation Notice"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Presente", "Comunicado" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Por la presente y en cumplimiento del Art. 222 del Código del trabajo, ponemos", "Pela presente e em cumprimento do Art. 222 do Código de trabalho, " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "a su conocimiento que las vacaciones que le corresponden de acuerdo a su antigüedad, ", "comunicamos que as férias às quais tem direito pelo tempo de serviço," )
		#define STR0004 "de"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", " días, deberá usufructuar, desde el ", "dias, devem ser gozadas, a partir do" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "El empleado recibe ", "O funcionário recebe" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", " de ", "de" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", ", ", "," )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " correspondiente al período", "correspondente ao período" )
		#define STR0010 "-"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "debiendo reintegrarse a sus labores el día ", "debiendo reintegrarse a sus labores el día" )
		#define STR0012 "."
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Sirvase pasar por la tesorería, el día ", "Apresente-se na tesouraria, no dia" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", " para percibir los", "para receber os" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Atentamente. ", "Atenciosamente," )
		#define STR0016 "__________________________________"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "RECIBÍ CONFORME", "RECEBE CONFORME" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "COMUNICACIÓN DE VACACIONES", "AVISO DE FÉRIAS" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "haberes que le corresponden en concepto de vacaciones.", "remuneração correspondente às férias." )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Aviso de Vacaciones", "Aviso de Férias" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Configure parámetro ", "Configure parâmetro" )
		#define STR0022 "MV_RELSERV"
		#define STR0023 "MV_RELACNT"
		#define STR0024 "MV_RELPSW"
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Configure email del cliente.", "Configure e-mail do cliente." )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Error en el Envio del Email", "Erro no Envio do Email" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Se consigna en documento adjunto su Aviso de Vacaciones", "No documento anexo está incluído seu Aviso de Férias" )
		#define STR0028 "Sr.(a)"
		#define STR0029 "Aviso"
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Tiempo de Servidor", "Tempo de Servidor" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Autenticación con servidor smtp", "Autenticação com Servidor smtp" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "AVISO DE VACACIONES", "AVISO DE FÉRIAS" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Representación de Aviso de Vacaciones", "Representação de Aviso de Férias" )
	#endif
#endif
