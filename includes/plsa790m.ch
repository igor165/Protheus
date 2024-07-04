#ifdef SPANISH
	#define STR0001 "Contrato"
	#define STR0002 "Familia"
	#define STR0003 "Rda"
	#define STR0004 "Solicitante"
	#define STR0005 "Ejecutante"
	#define STR0006 "Val. Cobranza"
	#define STR0007 "Movimiento"
	#define STR0008 "Formulario"
	#define STR0009 "Financiero"
	#define STR0010 "Criticas"
	#define STR0011 "Grupo Caren"
	#define STR0012 "Clase Caren"
	#define STR0013 'Analizar'
	#define STR0014 'Personalizar'
	#define STR0015 'Reservar/Liberar'
	#define STR0016 'Enviar p/ Espera'
	#define STR0017 'Finaliza analisis Part.'
	#define STR0018 'Modif. Prioridad'
	#define STR0019 'Inconsistencia'
	#define STR0020 'Banco de conocimiento'
	#define STR0021 'Relacionados'
	#define STR0022 "Neg. Participacion"
	#define STR0023 "Transf. p/ Demanda"
	#define STR0024 "Hist. Aud. Guia"
	#define STR0025 "Hist. GIH"
	#define STR0026 "Actualizar el Browse"
	#define STR0027 "¿Tiene documentos adjuntos vinculados?"
	#define STR0028 "Interacción"
	#define STR0029 "Instaura\Libera Junta Médica"
	#define STR0030 "Anexos Clin. Vinc."
	#define STR0031 "Documento adjunto Radioterapia"
	#define STR0032 "Archivos adjuntos HAT"
	#define STR0033 "Atención"
	#define STR0034 "Descarga de los archivos realizados con éxito. Archivos:"
	#define STR0035 "Falla al copiar archivo(s)."
	#define STR0036 "El número del formulario en el prestador no está informado."
	#define STR0037 "Ok"
	#define STR0038 "Formulario de referencia"
#else
	#ifdef ENGLISH
		#define STR0001 "Contract"
		#define STR0002 "Family"
		#define STR0003 "Service Network"
		#define STR0004 "Requester"
		#define STR0005 "Executer"
		#define STR0006 "Collection Vl."
		#define STR0007 "Transaction"
		#define STR0008 "Form"
		#define STR0009 "Financials"
		#define STR0010 "Warning Messages"
		#define STR0011 "Grace Period Group"
		#define STR0012 "Grace Period Class"
		#define STR0013 'Analyze'
		#define STR0014 'Customize'
		#define STR0015 'Reserve/Release'
		#define STR0016 'Send for Awaiting'
		#define STR0017 'Finalize Analysis Part.'
		#define STR0018 'Change Priority'
		#define STR0019 'Inconsistency'
		#define STR0020 'Knowledge Base'
		#define STR0021 'Related'
		#define STR0022 "; Neg. Participation"
		#define STR0023 "Transf. to Demand"
		#define STR0024 "Form Aud.Hist."
		#define STR0025 "GIH Hist."
		#define STR0026 "Update Browser"
		#define STR0027 "Linked Attachments?"
		#define STR0028 "Interaction"
		#define STR0029 "Introduce\Release Medical Board"
		#define STR0030 "Linked Clin. Attachments"
		#define STR0031 "Radiotherapy Attachment"
		#define STR0032 "HAT Attachments"
		#define STR0033 "Attention"
		#define STR0034 "Download of the file(s) successfully performed. Files:"
		#define STR0035 "Failure copying file(s)."
		#define STR0036 "The number of the form in the provider is not filled out."
		#define STR0037 "Ok"
		#define STR0038 "Reference Form"
	#else
		#define STR0001 "Contrato"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Família", "Familia" )
		#define STR0003 "Rda"
		#define STR0004 "Solicitante"
		#define STR0005 "Executante"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Vlr. Cobrança", "Vlr. Cobranca" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Movimentação", "Movimentacao" )
		#define STR0008 "Guia"
		#define STR0009 "Financeiro"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Críticas", "Criticas" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Grupo Carên.", "Grupo Caren" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Classe Carên.", "Classe Caren" )
		#define STR0013 'Analisar'
		#define STR0014 'Personalizar'
		#define STR0015 'Reservar/Liberar'
		#define STR0016 'Enviar p/ Espera'
		#define STR0017 If( cPaisLoc $ "ANG|PTG", 'Finaliza Análise Part.', 'Finaliza Analise Part.' )
		#define STR0018 'Alt. Prioridade'
		#define STR0019 'Inconsistência'
		#define STR0020 'Banco de conhecimento'
		#define STR0021 'Relacionados'
		#define STR0022 "Neg. Participação"
		#define STR0023 "Transf. p/ Demanda"
		#define STR0024 "Hist. Aud. Guia"
		#define STR0025 "Hist. GIH"
		#define STR0026 "Atualizar Browse"
		#define STR0027 "Possui Anexos vinculados?"
		#define STR0028 "Interação"
		#define STR0029 "Instaura\Libera Junta Médica"
		#define STR0030 "Anexos Clin. Vinc."
		#define STR0031 "Anexo Radioterapia"
		#define STR0032 "Anexos HAT"
		#define STR0033 "Atenção"
		#define STR0034 "Download do(s) arquivo(s) realizado com sucesso. Arquivos: "
		#define STR0035 "Falha ao copiar arquivo(s)."
		#define STR0036 "O número da guia no prestador não está preenchido."
		#define STR0037 "Ok"
		#define STR0038 "Guia Referência"
	#endif
#endif
