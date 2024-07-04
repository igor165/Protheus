#ifdef SPANISH
	#define STR0001 " Inicio de job de contabilizacion del MATA330 "
	#define STR0002 " Final de job de contabilizacion del MATA330 "
	#define STR0003 " Inicio de job de generacion del TRB de MATA330 "
	#define STR0004 " Final del job de generacion del TRB de MATA330 "
	#define STR0005 "MATA330: Inicio del job de Transferencia de Sucursales"
	#define STR0006 "MATA330: Termino del job de Transferencia de Sucursales"
	#define STR0007 "MATA330: Procesando la Orden"
	#define STR0008 "MATA330: Fin de la Orden"
	#define STR0009 "Thread:"
	#define STR0010 "Acertando costo unificado por empresa"
	#define STR0011 "Acertando costo unificado por sucursal"
	#define STR0012 "MATA330:Error al encerrar archivo de semaforo, error numero: "
	#define STR0013 "MATA330: Inicio de transferencia de sucursal"
	#define STR0014 "MATA330: Final de transferencia de sucursal"
	#define STR0015 "MATA330: Procesando A330TT2B2 - Thread #1[1]#"
	#define STR0016 "MATA330: Finalizado A330TT2B2 - Thread #1[1]#"
	#define STR0017 "Procedures: inicio de prorrateo del costo de los apuntes de la orden de producción en la sucursal:"
	#define STR0018 "Procedures: inicio de prorrateo del costo de los apuntes de la orden de producción en la sucursal:"
	#define STR0019 "Falla en la actualización del saldo actual de los productos para el costo unificado:"
	#define STR0020 "Falla en la actualización del costo unificado en la tabla SB2:"
	#define STR0021 "Falla en la selección de los productos para el costo unificado:"
#else
	#ifdef ENGLISH
		#define STR0001 " Start accounting job of MATA330 "
		#define STR0002 " End accounting job of MATA330 "
		#define STR0003 " Beginning of MATA330 TRB generation job "
		#define STR0004 " End of MATA330 TRB generation job "
		#define STR0005 "MATA330: Start of Branch Transfer Job"
		#define STR0006 "MATA330: End of Branch Transfer Job"
		#define STR0007 "MATA330: Processing the Order"
		#define STR0008 "MATA330: Closing of Order"
		#define STR0009 "Thread:"
		#define STR0010 "Adjusting unified cost per company"
		#define STR0011 "Adjusting unified cost per branch"
		#define STR0012 "MATA330:Error closing semaphore file, error number: "
		#define STR0013 "MATA330: Branch Transfer Start"
		#define STR0014 "MATA330: Branch Transfer End"
		#define STR0015 "MATA330: Processing A330TT2B2 - Thread #1[1]#"
		#define STR0016 "MATA330: Finished A330TT2B2 - Thread #1[1]#"
		#define STR0017 "Procedures: Start of proportionment the cost of annotations of production order at branch:"
		#define STR0018 "Procedures: End of proportionment the cost of annotations of production order at branch:"
		#define STR0019 "Failure in the updating of the current balance of the products for the unified cost:"
		#define STR0020 "Failure in the updating of unified cost in the SB2:"
		#define STR0021 "Failure in the selection of product for the unified cost:"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", " início do trabalho de contabilização do mata330 ", " Inicio do job de contabilizacao do MATA330 " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", " final do trabalho de contabilização do mata330 ", " Final do job de contabilizacao do MATA330 " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", " início do trabalho de criação do trb do mata330 ", " Inicio do job de geração do TRB do MATA330 " )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", " final do trabalho de criação do trb do mata330 ", " Final do job de geração do TRB do MATA330 " )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "MATA330: Início do job de transferência de filiais", "MATA330: Inicio do job de Transferencia de Filiais" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "MATA330: Término do job de transferência de filiais", "MATA330: Termino do job de Transferencia de Filiais" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "MATA330: A processar a ordem", "MATA330: Processando a Ordem" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "MATA330: Término da ordem", "MATA330: Termino da Ordem" )
		#define STR0009 "Thread:"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "A acertar custo unificado por empresa", "Acertando custo unificado por empresa" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "A acertar custo unificado por filial", "Acertando custo unificado por filial" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "MATA330:Erro ao fechar ficheiro de semáforo; erro número: ", "MATA330:Erro ao fechar arquivo de semaforo, erro numero: " )
		#define STR0013 "MATA330: Inicio da Transferencia de Filial"
		#define STR0014 "MATA330: Termino da Transferencia de Filial"
		#define STR0015 " MATA330: Processando A330TT2B2 - Thread #1[1]#"
		#define STR0016 " MATA330: Finalizado A330TT2B2 - Thread #1[1]#"
		#define STR0017 "Procedures: Inicio da proporcionalização o custo dos apontamentos da ordem de produção na filial: "
		#define STR0018 "Procedures: Fim da proporcionalização o custo dos apontamentos da ordem de produção na filial:"
		#define STR0019 "Falha na atualização do saldo atual dos produtos para o custo unificado: "
		#define STR0020 "Falha na atualização do custo unificado na tabela SB2: "
		#define STR0021 "Falha na seleção dos produto para o custo unificado: "
	#endif
#endif
