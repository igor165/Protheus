#ifdef SPANISH
	#define STR0001 "Plan de Desarrollo Personal"
	#define STR0002 "Planificacion y Acompanamiento de Metas"
	#define STR0003 "Hist�rico Planes Finalizados"
	#define STR0004 "Plan"
	#define STR0005 "Periodo"
	#define STR0006 "Nombre"
	#define STR0007 "Evaluador"
	#define STR0008 "Version"
	#define STR0009 "Ult. aprobacion"
	#define STR0010 "Haga clic en la version a seguir para visualizar el Historico"
	#define STR0011 "Version"
	#define STR0012 "Version Final"
	#define STR0013 "Volver"
	#define STR0014 "Fechar"
	#define STR0015 "Item"
	#define STR0016 "Objetivos y Metas"
	#define STR0017 "Conclusion"
	#define STR0018 "Relevancia"
	#define STR0019 "Alcanzado"
	#define STR0020 "Descripcion"
	#define STR0021 "Capacitacion"
	#define STR0022 "Valor"
	#define STR0023 "R$"
	#define STR0024 "Duracion"
	#define STR0025 "h"
	#define STR0026 "Relev."
	#define STR0027 "Alcanz."
	#define STR0028 "Certificacion"
	#define STR0029 "Comentarios adicionales y/o compromisos del evaluado y evaluador"
	#define STR0030 "No existen planes finalizados"
	#define STR0031 "Imprimir"
	#define STR0032 "Situaci�n"
	#define STR0033 "Obs. del Evaluador"
	#define STR0034 "Leyenda"
	#define STR0035 "Aprobado"
	#define STR0036 "Anulado\Rechazado"
#else
	#ifdef ENGLISH
		#define STR0001 "Personal Development Plan"
		#define STR0002 "Planning and follow-up of goals"
		#define STR0003 "History Plans Terminated"
		#define STR0004 "Plan"
		#define STR0005 "Period"
		#define STR0006 "Name"
		#define STR0007 "Appraiser"
		#define STR0008 "Versn."
		#define STR0009 "Last approval"
		#define STR0010 "Click on version below to view History"
		#define STR0011 "Versn."
		#define STR0012 "Final versn."
		#define STR0013 "Return"
		#define STR0014 "Close"
		#define STR0015 "Item"
		#define STR0016 "Objectives, Goals"
		#define STR0017 "Conclusn."
		#define STR0018 "Relevance"
		#define STR0019 "Attained"
		#define STR0020 "Descriptn"
		#define STR0021 "Qualificatn"
		#define STR0022 "Value"
		#define STR0023 "R$"
		#define STR0024 "Duratn."
		#define STR0025 "(H)"
		#define STR0026 "Relev."
		#define STR0027 "Attain"
		#define STR0028 "Certificatn."
		#define STR0029 "Addl. commentaries and/or commitments of appraisee and appraiser"
		#define STR0030 "No terminated plans exist"
		#define STR0031 "Print"
		#define STR0032 "Status"
		#define STR0033 "Evaluator Note"
		#define STR0034 "Caption"
		#define STR0035 "Approved"
		#define STR0036 "Canceled\Rejected"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Plano De Desenvolvimento Pessoal", "Plano de Desenvolvimento Pessoal" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Planeamento E Acompanhamento De Metas", "Planejamento e Acompanhamento de Metas" )
		#define STR0003 "Hist�rico Planos Finalizados"
		#define STR0004 "Plano"
		#define STR0005 "Per�odo"
		#define STR0006 "Nome"
		#define STR0007 "Avaliador"
		#define STR0008 "Vers�o"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "�lt. aprova��o", "Ult. aprova��o" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Clique Na Vers�o Abaixo Para Visualizar O Hist�rico", "Clique na vers�o abaixo para visualizar o Hist�rico" )
		#define STR0011 "Vers�o"
		#define STR0012 "Vers�o Final"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Voltar atr�s", "Voltar" )
		#define STR0014 "Fechar"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Elemento", "Item" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Objectivos E Metas", "Objetivos e Metas" )
		#define STR0017 "Conclus�o"
		#define STR0018 "Relev�ncia"
		#define STR0019 "Atingido"
		#define STR0020 "Descri��o"
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Capacidade", "Capacita��o" )
		#define STR0022 "Valor"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "�", "R$" )
		#define STR0024 "Dura��o"
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "H", "h" )
		#define STR0026 "Relev."
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Acting.", "Ating." )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Certificado", "Certifica��o" )
		#define STR0029 "Coment�rios adicionais e/ou compromissos do avaliado e avaliador"
		#define STR0030 "N�o existem planos finalizados"
		#define STR0031 "Imprimir"
		#define STR0032 "Situa��o"
		#define STR0033 "Obs. do Avaliador"
		#define STR0034 "Legenda"
		#define STR0035 "Aprovado"
		#define STR0036 "Cancelado\Rejeitado"
	#endif
#endif
