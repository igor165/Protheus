#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} OFAGCT04
	Criado para acelerar o envio dos dados para a AGCO, não utilizado pelo cliente diretamente
	Ele cria threads de execução que enviam massivamente dados a agco, usado normalmente na 
	geração da carga inicial

	@type  Function
	@author Vinicius Gati
	@since 30/01/2018
	@version 12
	/*/
Function OFAGCT04
	local nX := 1
	Private oGrid
	
	if MSGYESNO("Deseja testar os envios?", "Atenção")
		OFAGCA03({ cEmpAnt, xFilial('VS1'), 'DMS-1' }, .T.)
		OFAGCA03({ cEmpAnt, xFilial('VS1'), 'DMS-2' }, .T.)
		OFAGCA03({ cEmpAnt, xFilial('VS1'), 'DMS-3' }, .T.)
		OFAGCA03({ cEmpAnt, xFilial('VS1'), 'DMS-4' }, .T.)
		OFAGCA03({ cEmpAnt, xFilial('VS1'), 'DMS-5' }, .T.)
		OFAGCA03({ cEmpAnt, xFilial('VS1'), 'DMS-6' }, .T.)
	else
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-1' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-2' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-3' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-4' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-5' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-6' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-1' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-2' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-3' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-4' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-5' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-6' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-1' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-2' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-3' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-4' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-5' })
		StartJob("OFAGCA03", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), 'DMS-6' })
	endif
	
	for nX := 1 to 100
		sleep(1000)
		if MSGYESNO(cValtochar(FM_SQL("SELECT COUNT(*) FROM VB6010 where VB6_FLGENV = '1' ")), 'atenção')
			exit
		endif
	next
Return .T.
