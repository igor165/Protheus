#ifdef SPANISH
	#define STR0001 "CERTIFICADO DE RETENCIÓN DE RENTA EN LA FUENTE"
	#define STR0002 "Fecha de emisión"
	#define STR0003 "DÍA MES AÑO"
	#define STR0004 "AÑO FISCAL"
	#define STR0005 "Ciudad donde se consigna la retención"
	#define STR0006 "Nombre/razón social a quien se aplica la retención"
	#define STR0007 "C.C o NIT"
	#define STR0008 "Razón social completa o nombres del agente retenedor"
	#define STR0009 "Dirección del agente retenedor"
	#define STR0010 "Municipio"
	#define STR0011 "Departamento"
	#define STR0012 "Concepto"
	#define STR0013 "Nº Factura"
	#define STR0014 "Período"
	#define STR0015 "Valor total"
	#define STR0016 "Valor de la retención"
	#define STR0017 "Certificado de retención en la fuente expedido de forma continua e impresa en computador, no necesita "
	#define STR0018 "firma legalizada ( Art.10 D.R. 836/91)."
	#define STR0019 "CERTIFICADO Nº:"
	#define STR0020 "Monto total sujeto a retención"
	#define STR0021 "Valor retenido"
	#define STR0022 "Este documento no requiere para su validez firma autógrafa de acuerdo con el artículo 10 del"
	#define STR0023 " Decreto 836 de 1991, recopilado en el artículo 1.6.1.12.12 del DUT 1625 de octubre 11 de 2016,"
	#define STR0024 " que regula el contenido del certificado de retenciones a título de renta."
	#define STR0025 "Se expide este certificado para dar cumplimiento a lo Dispuesto en el artículo 381"
	#define STR0026 " del Estatuto Tributario."
#else
	#ifdef ENGLISH
		#define STR0001 "WITHHOLDING CERTIFICATE"
		#define STR0002 "Date of Issue"
		#define STR0003 "DAY MONTH YEAR"
		#define STR0004 "FISCAL YEAR"
		#define STR0005 "City where withholding is registered"
		#define STR0006 "Name or company name object of withholding"
		#define STR0007 "C.C or NIT"
		#define STR0008 "Full company name or names of the Withholding Agent"
		#define STR0009 "Address of Withholding Agent"
		#define STR0010 "City"
		#define STR0011 "Department"
		#define STR0012 "Concept"
		#define STR0013 "No. Invoice"
		#define STR0014 "Period"
		#define STR0015 "Total Value"
		#define STR0016 "Withholding Value"
		#define STR0017 "Withholding Certificate issued printed continuously, not requiring "
		#define STR0018 "registered signature (Art.10 D.R. 836/91)."
		#define STR0019 "CERTIFICATE NUMBER:"
		#define STR0020 "Total value subject to withholding"
		#define STR0021 "Withheld value"
		#define STR0022 "This document does not required for its validity the signature according to article 10 of"
		#define STR0023 "Decree 836 from 1991, compiled in the article 1.6.1.12.12 of DUT 1625 from October 11 2016,"
		#define STR0024 "regulating the content of the certificate of withholding as a matter of revenue."
		#define STR0025 "Certificate issued to comply with the article 381"
		#define STR0026 "of the Taxation Statute."
	#else
		#define STR0001 "CERTIFICADO DE RETENÇÃO DE RENDA NA FONTE"
		#define STR0002 "Data de Emissão"
		#define STR0003 "DIA MÊS ANO"
		#define STR0004 "ANO FISCAL"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Concelho onde está inscrita a retenção", "Cidade onde está inscrita a retenção" )
		#define STR0006 "Nome ou razão social a quem se pratica a retenção"
		#define STR0007 "C.C ou NIT"
		#define STR0008 "Razão social completa ou nomes do Agente Retentor"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "MORADA do Agente Retentor", "Endereço do Agente Retentor" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Concelho", "Município" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Departamento", "Estado" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Conceito", "Verba" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "No. Factura", "Nº Nota Fiscal" )
		#define STR0014 "Período"
		#define STR0015 "Valor Total"
		#define STR0016 "Valor Retenção"
		#define STR0017 "Certificado de Retenção na Fonte emitido de forma continua e impressa no computador, não precisa "
		#define STR0018 "assinatura registrada ( Art.10 D.R. 836/91)."
		#define STR0019 "CERTIFICADO Nº:"
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Monto total sujeto a retención", "Valor total sujeito a retenção" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Valor retenido", "Valor retido" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Este documento no requiere para su validez firma autógrafa de acuerdo con el artículo 10 del", "Este documento não requer para sua validade a assinatura escrita segundo o artigo 10 do" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", " Decreto 836 de 1991, recopilado en el artículo 1.6.1.12.12 del DUT 1625 de octubre 11 de 2016,", "Decreto 836 de 1991, compilado no artigo 1.6.1.12.12 do DUT 1625 de outubro 11 de 2016," )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", " que regula el contenido del certificado de retenciones a título de renta.", "que regula o conteúdo do certificado de retenções a título de renda." )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Se expide este certificado para dar cumplimiento a lo Dispuesto en el artículo 381", "Certificado emitido para cumprir com o previsto no artigo 381" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", " del Estatuto Tributario.", "do Estatuto Tributário." )
	#endif
#endif
