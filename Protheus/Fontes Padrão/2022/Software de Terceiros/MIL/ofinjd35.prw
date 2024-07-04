#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'OFINJD35.CH'


/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "003697_10"

/*/{Protheus.doc} OFINJD35
    Rotina scheduler que vai rodar infinitamente e gerar conforme especificações(SCHEDULER)
    OU
    Configura gerações do DPM para o scheduler posteriormente usar

    Pontos de entrada:

	Parametros:
		MV_XMILDBG => Usado para gravar logs adicionais de debug

    @author Vinicius Gati
    @since  26/11/2015
/*/
Function OFINJD35(aParam)
	Local nStat
	Private lMenu   := (VALTYPE(aParam) == "U")
	if ! lMenu
		nModulo     := 41
		cModulo     := "PEC"
		__cInternet := 'AUTOMATICO'
		cEmpr       := aParam[1]
		cFil        := aParam[2]
		If Type("cArqTab") == "U"
			cArqTab:=""
		EndIf
		cFOPENed := ""
		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Modulo cModulo
	EndIf
	Private oUtil           := DMS_Util():New()
	Private oSqlHlp         := DMS_SqlHelper():New()
	Private oArHlp          := DMS_ArrayHelper():New()
	Private oLogger         := DMS_Logger():New("OFINJD35.LOG")
	Private oDpmSched       := DMS_DPMSched():New()
	Private oDpm            := DMS_Dpm():New()
	Private lIsDebug        := "OFINJD35" $ GetNewPar("MV_XMILDBG", "NAO") .OR. "*DPM*" $ GetNewPar("MV_XMILDBG", "NAO")
	Private lForcSch        := "OFINJD35SCH" $ GetNewPar("MV_XMILDBG", "NAO")
	Private lProcForce      := lIsDebug .AND. "FORCE" $ GetNewPar("MV_XMILDBG", "NAO")
	Private aCfgs
	Private cTblLogCod
	Private cHora1, cHora2 // range de horas para scheduler
	Private lDebug := .T.

	if !lMenu .AND. !LockByName("OFINJD35" , .T. , .T. , .T. )
		return .t.
	endif

	if ! oDpm:Ready(.F.) //nao manda email pois roda a cada minuto, ia bombardear a caixa de entrada
		if lMenu
			MsgInfo(oDpm:cLastError, STR0017)
		endif
		Return .F.
	endif

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD35'                                  },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
		{'VQL_DADOS'      , 'MODO:' + IIF(lMenu, "Normal", "Agendado")  } ;
	})

	// Compatibilizador para quem utiliza a configuração feita pela rotina OFINJD35, quando há Grupos DPM já configurados.
	If FM_SQL(" SELECT COUNT(VQL_DADOS) FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND (VQL_AGROUP LIKE '%DPMC%' OR VQL_AGROUP = 'SCHEDULER') AND VQL_TIPO = 'PATH_DPMSCHED_F' ") > 0
		TcLink()

		nStat := TcSqlExec(" UPDATE " + RetSqlName("VQL") + " SET VQL_TIPO = 'PATH' WHERE D_E_L_E_T_ = '' AND (VQL_AGROUP LIKE '%DPMC%' OR VQL_AGROUP = 'SCHEDULER') AND VQL_TIPO = 'PATH_DPMSCHED_F' ")
		If nStat >= 0
			ConOut("Compatibilizador.... Os dados da tabela VQL onde VQL_TIPO era 'PATH_PMSCHED_F' foram alterados para 'PATH'.")
		Endif

		TCUnlink()
	Endif

	If lMenu .AND. ! lForcSch
		ONJD35SCRCFG()
	Else
		if lMenu
			Processa( {|lAbort| INFINITYPROC() } )
		Else
			INFINITYPROC()
		EndIf
	EndIf

	oLogger:CloseOpened(cTblLogCod)
Return

/*/{Protheus.doc} ONJD35SCRCFG
	Abre a tela de configuração e mostra como está configurada as gerações , além de mostrar o último arquivo importado

	@author       Vinicius Gati
	@since        08/07/2015
	@description  Verifica se está no momento permitido de processar coisas pesadas

/*/
Static Function ONJD35SCRCFG()
	Local nIdx := 1
	Private oDlg,oGrp1,oSay2,oSay3,oSay4,oGet5,oGet6,oGet7,oGrp8,oList10,oGrp11,oSBtn12,oSay14,oList15,oBtnHlp, oget1, oBtnSave, oSBtn13, oSBtn15
	Private oCbxGrp, cGrupoDpm, aGrupos, lDlgAtivo
	Private cHoraProcD := cHoraPMM := cHoraDPE := "22:00"
	Private cPathSch := ""
	Private lUsaGrps
	Private oDTFConfig := OFJDDTFConfig():New()
	Private oRetAPiG := OFJDDTF():New("GET")
	Private oRetAPiP := OFJDDTF():New("PUT")
	
	oDTFConfig:GetConfig()

	lUsaGrps := LEN( oDpm:GetConfigs() ) > 0

	aGrupos := {}

	oDlg := MSDIALOG():Create()
	oDlg:cName     := "oDlg"
	oDlg:cCaption  := STR0009 /*"Configuração Scheduler"*/
	oDlg:nLeft     := 0
	oDlg:nTop      := 0
	oDlg:nWidth    := 953
	oDlg:nHeight   := 600
	oDlg:lShowHint := .F.
	oDlg:lCentered := .F.

	aDpmCfgs := oDpm:GetConfigs()
	AEVAL(aDpmCfgs, { |cfg| AADD(aGrupos, STR0008 /*"Grupo: "*/ + RIGHT(ALLTRIM(cfg:cGrupo), 1)) })
	@ 2,2 MSCOMBOBOX oCbxGrp VAR cGrupoDpm SIZE 45,10 ITEMS aGrupos OF oDlg ON CHANGE FS_DlgRefresh() PIXEL WHEN lUsaGrps

	oGrp1 := TGROUP():Create(oDlg)
	oGrp1:cName := "oGrp1"
	oGrp1:cCaption := STR0015 /*"Cfg. Padrão"*/
	oGrp1:nLeft := 5
	oGrp1:nTop := 25
	oGrp1:nWidth := 234
	oGrp1:nHeight := 112
	oGrp1:lShowHint := .F.
	oGrp1:lReadOnly := .F.
	oGrp1:Align := 0
	oGrp1:lVisibleControl := .T.

	oSay2 := TSAY():Create(oDlg)
	oSay2:cName := "oSay2"
	oSay2:cCaption := STR0014 /*"Proc. Diário"*/
	oSay2:nLeft := 15
	oSay2:nTop := 49
	oSay2:nWidth := 65
	oSay2:nHeight := 17
	oSay2:lShowHint := .F.
	oSay2:lReadOnly := .F.
	oSay2:Align := 0
	oSay2:lVisibleControl := .T.
	oSay2:lWordWrap := .F.
	oSay2:lTransparent := .F.

	oSay3 := TSAY():Create(oDlg)
	oSay3:cName := "oSay3"
	oSay3:cCaption := "DPE"
	oSay3:nLeft := 15
	oSay3:nTop := 74
	oSay3:nWidth := 65
	oSay3:nHeight := 17
	oSay3:lShowHint := .F.
	oSay3:lReadOnly := .F.
	oSay3:Align := 0
	oSay3:lVisibleControl := .T.
	oSay3:lWordWrap := .F.
	oSay3:lTransparent := .F.

	oSay4 := TSAY():Create(oDlg)
	oSay4:cName := "oSay4"
	oSay4:cCaption := "PMM"
	oSay4:nLeft := 16
	oSay4:nTop := 101
	oSay4:nWidth := 65
	oSay4:nHeight := 17
	oSay4:lShowHint := .T.
	oSay4:lReadOnly := .T.
	oSay4:Align := 0
	oSay4:lVisibleControl := .T.
	oSay4:lWordWrap := .F.
	oSay4:lTransparent := .F.

	@ 022,055 MSGET oGet5 VAR cHoraProcD PICTURE "@R 99:99" OF oDlg VALID {|| cHoraProcD := ONJD35FMTHR(cHoraProcD) } PIXEL COLOR CLR_BLACK When .F.
	@ 037,055 MSGET oGet6 VAR cHoraDPE   PICTURE "@R 99:99" OF oDlg VALID {|| cHoraDPE := ONJD35FMTHR(cHoraDPE) } PIXEL COLOR CLR_BLACK When .F.
	@ 051,055 MSGET oGet6 VAR cHoraPMM   PICTURE "@R 99:99" OF oDlg VALID {|| cHoraPMM := ONJD35FMTHR(cHoraPMM) } PIXEL COLOR CLR_BLACK When .F.

	oGrp8 := TGROUP():Create(oDlg)
	oGrp8:cName := "oGrp8"
	oGrp8:cCaption := STR0013 /*"Cfg. Dpm Sched"*/
	oGrp8:nLeft := 470
	oGrp8:nTop := 25
	oGrp8:nWidth := 455
	oGrp8:nHeight := 524
	oGrp8:lShowHint := .F.
	oGrp8:lReadOnly := .F.
	oGrp8:Align := 0
	oGrp8:lVisibleControl := .T.

    lstCfgSched := TWBrowse():New(20, 238, 220, 254,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    lstCfgSched:AddColumn( TCColumn():New( STR0001 /* "Geração" */  , { || ALLTRIM(STR( lstCfgSched:nAt ))                },,,,"LEFT", 50,.F.,.F.,,,,.F.,) )
    lstCfgSched:AddColumn( TCColumn():New( STR0002 /* "Dias"    */  , { || STR0004 /* "Todos" */                          },,,,"LEFT", 50,.F.,.F.,,,,.F.,) )
    lstCfgSched:AddColumn( TCColumn():New( STR0003 /* "Horário" */  , { || aCfgs[lstCfgSched:nAt]:GetTime()               },,,,"LEFT", 50,.F.,.F.,,,,.F.,) )
    lstCfgSched:AddColumn( TCColumn():New( ""                       , { || ""                                             },,,,"LEFT", 10,.F.,.F.,,,,.F.,) )
    lstCfgSched:SetArray( {} )
    lstCfgSched:nAt := 1

	oGrp11 := TGROUP():Create(oDlg)
	oGrp11:cName := "oGrp11"
	oGrp11:cCaption := STR0012 /*"Ultimas Gerações"*/
	oGrp11:nLeft := 244
	oGrp11:nTop := 25
	oGrp11:nWidth := 221
	oGrp11:nHeight := 524
	oGrp11:lShowHint := .F.
	oGrp11:lReadOnly := .F.
	oGrp11:Align := 0
	oGrp11:lVisibleControl := .T.

	oSBtn12 := TButton():Create(oDlg)
	oSBtn12:cName := "oSBtn12"
	oSBtn12:cCaption := STR0011 /* "Caminho Arq. Monitoramento:" */
	oSBtn12:nLeft := 16
	oSBtn12:nTop := 174
	oSBtn12:nWidth := 200
	oSBtn12:nHeight := 22
	oSBtn12:lShowHint := .F.
	oSBtn12:lReadOnly := .F.
	oSBtn12:Align := 0
	oSBtn12:lVisibleControl := .T.
	oSBtn12:bAction := { || oSBtn12:cCaption := cPathSch := OJD35GtFile() }

	oSay14 := TSAY():Create(oDlg)
	oSay14:cName := "oSay14"
	oSay14:cCaption := STR0010 /* "Caminho do Arq. DPMSCHED" */
	oSay14:nLeft := 16
	oSay14:nTop := 150
	oSay14:nWidth := 106
	oSay14:nHeight := 17
	oSay14:lShowHint := .F.
	oSay14:lReadOnly := .F.
	oSay14:Align := 0
	oSay14:lVisibleControl := .T.
	oSay14:lWordWrap := .F.
	oSay14:lTransparent := .F.

	oSBtn13                := TButton():Create(oDlg)
	oSBtn13:cName          := "oSBtn13"
	oSBtn13:cCaption       := STR0019 /* "Configurar Dados Transferência" */
	oSBtn13:nLeft          := 16
	oSBtn13:nTop           := 204
	oSBtn13:nWidth         := 200
	oSBtn13:nHeight        := 22
	oSBtn13:lShowHint      := .F.
	oSBtn13:lReadOnly      := .F.
	oSBtn13:Align          := 0
	oSBtn13:lVisibleControl:= .T.
	oSBtn13:bAction        := { || Pergunte("OFM430",.T.), Pergunte("VIA040B", .T.), Pergunte("MT460A",.T.), MSGINFO(STR0024) }//'Configuração finalizada'

	oSBtn15                := TButton():Create(oDlg)
	oSBtn15:cName          := "oSBtn15"
	oSBtn15:cCaption       := STR0021 // Recebe dados DTF
	oSBtn15:nLeft          := 16
	oSBtn15:nTop           := 234
	oSBtn15:nWidth         := 200
	oSBtn15:nHeight        := 22
	oSBtn15:lShowHint      := .F.
	oSBtn15:lReadOnly      := .F.
	oSBtn15:Align          := 0
	oSBtn15:lVisibleControl:= .T.
	oSBtn15:bAction        := { || OA411002A_CallDTFAPI(oDTFConfig:getJDPRISM()), MSGINFO(STR0025) }//Recebimento finalizado

	oSBtn15                := TButton():Create(oDlg)
	oSBtn15:cName          := "oSBtn15"
	oSBtn15:cCaption       := STR0022// Envia DPMEXT DTF
	oSBtn15:nLeft          := 16
	oSBtn15:nTop           := 264
	oSBtn15:nWidth         := 200
	oSBtn15:nHeight        := 22
	oSBtn15:lShowHint      := .F.
	oSBtn15:lReadOnly      := .F.
	oSBtn15:Align          := 0
	oSBtn15:lVisibleControl:= .T.
	oSBtn15:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getDPMEXT()), MSGINFO(STR0026) }//Envio finalizado

	oSBtn15                := TButton():Create(oDlg)
	oSBtn15:cName          := "oSBtn15"
	oSBtn15:cCaption       := STR0023// Envia PMMANAGE DTF
	oSBtn15:nLeft          := 16
	oSBtn15:nTop           := 294
	oSBtn15:nWidth         := 200
	oSBtn15:nHeight        := 22
	oSBtn15:lShowHint      := .F.
	oSBtn15:lReadOnly      := .F.
	oSBtn15:Align          := 0
	oSBtn15:lVisibleControl:= .T.
	oSBtn15:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getPMMANAGE()), MSGINFO(STR0026) }//Envio finalizado

	lstLogGer := TWBrowse():New(20, 126, 105, 254,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	lstLogGer:AddColumn( TCColumn():New( STR0001 /* "Geração" */ , { || aGers[lstLogGer:nAt]:GetValue('VQL_AGROUP')                },,,,"LEFT", 40,.F.,.F.,,,,.F.,) )
	lstLogGer:AddColumn( TCColumn():New( STR0003 /* "Horario" */ , { || STOD(aGers[lstLogGer:nAt]:GetValue('VQL_DATAI'))           },,,,"LEFT", 40,.F.,.F.,,,,.F.,) )
	lstLogGer:AddColumn( TCColumn():New( "" /* "" */             , { || ONJD35FMTHR( aGers[lstLogGer:nAt]:GetValue('VQL_HORAI') )  },,,,"LEFT", 30,.F.,.F.,,,,.F.,) )
	lstLogGer:AddColumn( TCColumn():New( ""                      , { || ""                                                         },,,,"LEFT", 10,.F.,.F.,,,,.F.,) )
	aGers := FS_GtLastGens()
	lstLogGer:SetArray( aGers )
	lstLogGer:nAt := 1

	oBtnSave := TButton():Create(oDlg)
	oBtnSave:cName := "oBtnSave"
	oBtnSave:cCaption := STR0007 /* "Salvar" */
	oBtnSave:nLeft := 6
	oBtnSave:nTop := 518
	oBtnSave:nWidth := 50
	oBtnSave:nHeight := 33
	oBtnSave:lShowHint := .F.
	oBtnSave:lReadOnly := .F.
	oBtnSave:Align := 0
	oBtnSave:lVisibleControl := .T.
	oBtnSave:bAction := {|| ONJD35SALVAR() }

	lDlgAtivo := .T.
	FS_DlgRefresh()
	oDlg:Activate()
Return

/*/{Protheus.doc} OJD35GtFile

	@author       Vinicius Gati
	@since        26/11/2015
	@description  Selecao de caminho dos arquivos DPM

/*/
Static Function OJD35GtFile()
Return cGetFile( '', STR0005, 1, '', .F., GETF_RETDIRECTORY )


/*/{Protheus.doc} ONJD35SALVAR

	@author       Vinicius Gati
	@since        30/11/2015
	@description  Salva os dados da tela no VQL

/*/
Static Function ONJD35SALVAR()
	Local oLogger  := DMS_Logger():New()
	Local lUsaGrps := LEN( oDpm:GetConfigs() ) > 0

	BEGIN TRANSACTION
		dbselectarea('VAI')
		dbsetOrder(4)
		DbSeek( xFilial("VAI") + __CUSERID )

		cTblLogCod := oLogger:LogToTable({;
			{'VQL_AGROUP', 'OFINJD35'                    },;
			{'VQL_TIPO'  , 'CFG_ALTERADA'                },;
			{'VQL_DADOS' , "Usuário: " + VAI->VAI_NOMTEC } ;
		})

		If ! lUsaGrps // mais fácil primeiro
			cAgroup := "SCHEDULER"
		Else
			DO CASE
				CASE '1' $ cGrupoDpm
					cAgroup := 'DPMC1'
				CASE '2' $ cGrupoDpm
					cAgroup := 'DPMC2'
				CASE '3' $ cGrupoDpm
					cAgroup := 'DPMC3'
				CASE '4' $ cGrupoDpm
					cAgroup := 'DPMC4'
			END CASE
		EndIf

		// limpo a atual config e gravo novamente, desse modo temos as mudanças (isso "não deve" acontecer com frequencia)
		TCSQLEXEC(" UPDATE " + RetSqlName('VQL') + " SET R_E_C_D_E_L_ = R_E_C_N_O_, D_E_L_E_T_ = '*' WHERE VQL_AGROUP = '"+cAgroup+"' AND VQL_TIPO IN ('HORA_PRC_DIARIO','HORA_DPE','HORA_PMM','PATH') AND D_E_L_E_T_ = ' ' ")

		oLogger:LogToTable({;
			{'VQL_AGROUP' , cAgroup           },;
			{'VQL_CODVQL' , cTblLogCod        },;
			{'VQL_TIPO'   , 'HORA_PRC_DIARIO' },;
			{'VQL_DADOS'  , cHoraProcD        } ;
		})
		oLogger:LogToTable({;
			{'VQL_AGROUP' , cAgroup           },;
			{'VQL_CODVQL' , cTblLogCod        },;
			{'VQL_TIPO'   , 'HORA_DPE'        },;
			{'VQL_DADOS'  , cHoraDPE          } ;
		})
		oLogger:LogToTable({;
			{'VQL_AGROUP' , cAgroup           },;
			{'VQL_CODVQL' , cTblLogCod        },;
			{'VQL_TIPO'   , 'HORA_PMM'        },;
			{'VQL_DADOS'  , cHoraPMM          } ;
		})
		oLogger:LogToTable({;
			{'VQL_AGROUP' , cAgroup           },;
			{'VQL_CODVQL' , cTblLogCod        },;
			{'VQL_TIPO'   , 'PATH' 			  },;
			{'VQL_DADOS'  , cPathSch          } ;
		})

		oLogger:CloseOpened(cTblLogCod) // fecha log de execução
	END TRANSACTION
Return .T.

/*/{Protheus.doc} ONJD35FMTHR
	valida e formata data digitada

	@author       Vinicius Gati
	@since        26/11/2015
	@description  Selecao de caminho dos arquivos DPM

/*/
Static Function ONJD35FMTHR(cDigitado)
	cDigitado := ALLTRIM(cDigitado)
	nHora     := VAL(LEFT(cDigitado, 2))
	nMinutos  := VAL(RIGHT(cDigitado, 2))
	If nHora <= 23 .AND. nMinutos <= 59
		Return LEFT(cDigitado, 2) + ":" + RIGHT(cDigitado, 2)
	EndIf
Return "22:00"

/*/{Protheus.doc} FS_DlgRefresh
    Reprocessa visual e dados dos browses (apos trocar mes e ano)

    @author Vinicius Gati
    @since  27/11/2015
/*/
Static Function FS_DlgRefresh()
	Local cAgroup := "SCHEDULER"
	Local oDpmCfg// := DMS_DPMConfig():New()

	if lDlgAtivo

		If lUsaGrps // mais fácil primeiro
			DO CASE
				CASE '1' $ cGrupoDpm
					cAgroup := 'DPMC1'
				CASE '2' $ cGrupoDpm
					cAgroup := 'DPMC2'
				CASE '3' $ cGrupoDpm
					cAgroup := 'DPMC3'
				CASE '4' $ cGrupoDpm
					cAgroup := 'DPMC4'
			END CASE
		EndIf

		oDpmCfg    := DMS_DPMConfig():New(cAgroup)
		cHoraProcD := oDpmCfg:GetHoraProcDiario()
		cHoraDPE   := oDpmCfg:GetHoraDPE()
		cHoraPMM   := oDpmCfg:GetHoraPMM()
		oSBtn12:cCaption := cPathSch := oDpmCfg:GetPath()
		aCfgs := ONJD35CFGAT(oDpmCfg:cGrupo)
		lstCfgSched:SetArray( aCfgs )
		lstCfgSched:Refresh()
	EndIf
Return

/*/{Protheus.doc} FS_GtLastGens
    Reprocessa visual e dados dos browses (apos trocar mes e ano)

    @author Vinicius Gati
    @since  27/11/2015
/*/
Static Function FS_GtLastGens()
	Local cQuery  := ""
	Local aObjs   := {}
	Local oSqlHlp := DMS_SqlHelper():New()
	Local cSGBD   := Upper(TcGetDb())

	cQuery += " SELECT VQL_AGROUP, 

	If cSGBD $ "ORACLE" 
		cQuery += "	TO_CHAR(4 - LENGTH(VQL_HORAI),'9999') + RTrim(VQL_HORAI) as VQL_HORAI,
	Else
		cQuery += "	REPLICATE('0', 4 - LEN(VQL_HORAI)) + RTrim(VQL_HORAI) as VQL_HORAI,  
	EndIf
	cQuery += "	VQL_DATAI, VQL_DATAF, VQL_HORAF "
	cQuery += "    FROM " + RetSqlName('VQL')
	cQuery += "   WHERE VQL_AGROUP IN ('OFINJD31', 'OFINJD06', 'OFINJD09') AND VQL_TIPO = 'LOG_EXECUCAO' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery := oSqlHlp:TOPFunc(cQuery, 100)
	aObjs := oSqlHlp:GetSelect({;
		{'campos', {'VQL_AGROUP', 'VQL_DATAI', 'VQL_HORAI', 'VQL_DATAF', 'VQL_HORAF'}},;
		{'query', cQuery} ;
	})
Return aObjs

/*/{Protheus.doc} INFINITYPROC
	Processamento infinito que fica gerando arquivos conforme DPMSCHED ou configuração das gerações

	@author       Vinicius Gati
	@since        04/12/2015
	@description  Verifica se está no momento permitido de processar coisas pesadas

/*/
Static Function INFINITYPROC()
	Local cAgroup  := "SCHEDULER"
	Local aConfs   := oDpm:GetConfigs()
	Local lUsaGrps := LEN(aConfs) > 0
	Local nIdx     := 1
	Local nIdx2    := 1
	Local aAreas := { ;
		"CC2","CC6","CC7","CD2","CD3","CD5","CD6","CDA","CDC","CDH","CDL","CDO","CDT",;
		"CE0","CE1","CF5","CF8","CFC","CG1","CLN","CT0","CT1","CT2","CTL","CVA","CVB",;
		"DT3","DUE","DUL","DUY","F0R","SA1","SA2","SA4","SB1","SB5",;
		"SBI","SBZ","SC6","SD1","SD2","SE2","SE5","SED","SF1","SF2","SF3","SF4",;
		"SF6","SF7","SF9","SFA","SFB","SFC","SFI","SFP","SFQ","SFT","SFU","SFX","SL1",;
		"SLG","SLX","SN1","SS1","SS4","SS5","SS9","SUS","SWN","SC7","SM2","SM5";
	}

	For nIdx := 1 to Len(aAreas)
		OFINJD3502_PrepareTable(aAreas[nIdx])
	Next

	cHora1 := TIME() // Resultado: 10:37:17

	If ! lUsaGrps // mais fácil primeiro
		aConfs := { DMS_DPMConfig():New(cAgroup) }
	EndIf

	Do While .T. .AND. FM_SQL('SELECT count(*) FROM ' + RetSqlName('VQL') + " WHERE VQL_AGROUP = 'OFINJD35' AND VQL_TIPO = 'SCH_STOP' AND D_E_L_E_T_ = '' ") == 0
		if dDatabase != DATE()
			dDatabase := DATE()
		endif

		sleep(60000)
		If Empty(cHora2) // isso faz com que o range de datas seja perfeito
			cHora2 := TIME()
		Else
			cHora1 := STRTRAN( ALLTRIM(TRANSFORM(SOMAHORAS(LEFT(cHora2,5), "00:01"), '@E 9999999.99')), ',', ':' ) + ":00"
			cHora1 := IIF( LEN(chora1) == 7, "0" + cHora1, cHora1 )
			cHora2 := TIME()
		EndIf
		if lDebug
			conout("DPMSCHED - Verificando geracoes entre " + cHora1 + " e " + cHora2)
		Endif
		for nIdx := 1 to LEN(aConfs)
			oConf := aConfs[nIdx]
			// verificar proximas gerações e gera se estiver no horário
			oSched  := DMS_DPMSched():New(oConf:cGrupo)
			aGerar  := oSched:WhatToGen( cHora1, cHora2 ) // pega o que precisa ser gerado
			if lDebug
				conout( "DPMSCHED - Numero de geracoes : " + ALLTRIM(STR(LEN(aGerar))) )
			EndIf
			for nIdx2 := 1 to LEN(aGerar)
				cTipo := aGerar[nIdx2]:cTipo
				If lUsaGrps
					StartJob("ONJD35DPEG", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), oConf:cGrupo, cTipo }) //  usa grupo
					conout("Executando thread - Emp: " + cEmpAnt + " Filial: " +  xFilial('VS1') )
					conout("Environment: " + GetEnvServer())
				Else
					conout("Executando thread - Emp: " + cEmpAnt + " Filial: " +  xFilial('VS1') )
					conout("Environment: " + GetEnvServer())
					StartJob("ONJD35DPEG", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'),             , cTipo })
				EndIf
			Next

			// verifica se tem scheduler(arquivos) novos pra importar
			ChkSchFile(oConf)
			//
		next
	End
	if lMenu
		MSGINFO(STR0016/*"Finalizado com sucesso."*/, STR0017/*Informação*/)
	EndIf
Return

/*/{Protheus.doc} ChkSchfile
	checa se novo arquivo dpmsched foi colocado para uso na pasta configurada

	@author       Vinicius Gati
	@since        01/12/2015
	@type         function

/*/
Static Function ChkSchFile(oDpmCfg)
	Local cPath := oDpmCfg:GetPath()
	Local nIdx  := 1
	Local aArquivos := ""
	Local oBckBlk  := ErrorBlock()

	aArquivos := Directory( cPath + ALLTRIM(" \ ") + "JD2DLR_DPMSCHED_*.DAT",,nil, .T.)

	if LEN( aArquivos ) > 0
		for nIdx := 1 to LEN(aArquivos)
			aArqData := aArquivos[nIdx]
			If "JD2DLR_DPMSCHED_" $ aArqData[1];
				.AND. FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+oDpmCfg:cGrupo+"' AND VQL_TIPO = 'DPMSCHED_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
				FT_FUse( cPath + ALLTRIM(" \ ") + aArqData[1] )
				cArqCtnt := FT_FReadLn()
				FT_FUse()
				OFINJD3506_IMPSCH(oDpmCfg,cArqCtnt, aArqData, cPath)
			EndIf
		next
	endif

	aArquivos := Directory( cPath + ALLTRIM(" \ ") + "JD2DLR_DPMXFER_*.DAT",,nil, .T.)
	if LEN( aArquivos ) > 0
		for nIdx := 1 to LEN(aArquivos)
				aArqData := aArquivos[nIdx]
				If FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+oDpmCfg:cGrupo+"' AND VQL_TIPO = 'DPMXFER_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
					OFINJD3505_IMPXFE(oDpmCfg, cPath, aArqData)
				EndIf
		next
	endif

	aArquivos := Directory( cPath + ALLTRIM(" \ ") + "JD2DLR_DPMORD_*.DAT",,nil, .T.)

	if LEN( aArquivos ) > 0
		for nIdx := 1 to LEN(aArquivos)
				aArqData := aArquivos[nIdx]
				If FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+oDpmCfg:cGrupo+"' AND VQL_TIPO = 'DPMORD_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
					OFINJD3504_IMPORD(oDpmCfg, cPath, aArqData)
				EndIf
		next
	endif
	ErrorBlock(oBckBlk)
Return

/*/{Protheus.doc} ONJD35DPEG
	roda DPE apos rodar processamento diario

	@author       Vinicius Gati
	@since        15/12/2015
	@description  gera DPE e antes ve se gerou processamento diario, fiz isso pra nao ter que controlar com sleep a geração acima, no pain no gain

/*/
Function ONJD35DPEG(aParams)
	Prepare Environment Empresa aParams[1] Filial aParams[2] Modulo "PEC"

	OFINJD31(, .t.) // Acho que o OFINJD31 e obrigatorio no DPMSCHED... talvez seja necessario otimiza-lo porem acho que como esta ja ficou bem funcional
	if Empty(aParams[4])
		cTipo := "I"
	Else
		cTipo := aParams[4]
	EndIf
	conout("Geração de Parts Data via JDPrism tipo :" + aParams[4])
	//
	if TCSQLEXEC(" SELECT COUNT(*) FROM "+RetSqlName('VQL')+" WHERE VQL_AGROUP = '"+IIF(EMPTY(aParams[3]), "", aParams[3])+"' AND VQL_TIPO = 'SCHED_I' AND VQL_DATAF = '' AND D_E_L_E_T_ = ' ' ") > 0
		cTipo := "I"
		TCSQLEXEC(" UPDATE "+RetSqlName('VQL')+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP = '"+IIF(EMPTY(aParams[3]), "", aParams[3])+"' AND VQL_TIPO = 'SCHED_I' AND VQL_DATAF = '' AND D_E_L_E_T_ = ' ' ")
	endif
	// Removido a motivo de que o OFINJD31 está rodando ofinjd06 automaticamente via scheduler
	// 
	// if !Empty(aParams[3])
	// 	conout("Gerando DPE com grupos de dpm")
	// 	OFINJD06( , .T., { DMS_DPMConfig():New(aParams[3]) }, cTipo /*tipo de geracao*/ ) // Vai grupo dpm!
	// else
	// 	conout("Gerando DPE sem grupos de dpm")
	// 	OFINJD06( , .T., {                                 }, cTipo /*tipo de geracao*/ ) // Vai!
	// EndIf
Return .T.

/*/{Protheus.doc} ONJD35CFGAT
	checa se novo arquivo dpmsched foi colocado para uso na pasta configurada

	@author       Vinicius Gati
	@since        05/12/2015

/*/
Function ONJD35CFGAT(cGrupo)
	Local oConf   := DMS_DPMConfig():New(cGrupo)

	oSched  := DMS_DPMSched():New(oConf:cGrupo)
	oSched:UpdateGers() //TODO: Na classe DMS_DPMSched, se não tiver arquivo DPMSCHED, retornar gerações com horário padrão, JDPrism V2
Return oSched:aGeracoes

/*/{Protheus.doc} ONJD35MV
	Move um arquivo para outra pasta

	@author       Vinicius Gati
	@since        05/12/2015
	@description  Renomeia o arquivo para caixa alta

/*/
Function ONJD35MV()
	FRenameEx(Alltrim(MV_PAR01)+Alltrim(cArquivo),UPPER(Alltrim(MV_PAR01)+Alltrim(cArquivo)))
return .T.


/*/{Protheus.doc} OFINJD3501_EnviaEmailDeErro

	@author       Vinicius Gati
	@since        05/12/2015
	@description  Envia email de rro

/*/
Function OFINJD3501_EnviaEmailDeErro(cErrMessage)
	Local oEmailHlp := DMS_EmailHelper():New()
	Local nIdxEr    := AT(cErrMessage, "Alias does not exist ")
	Local cTabela   := ""

	conout("Tentativa de recuperação de erro iniciada erro: " + cErrMessage)

	if nIdxEr > 0 // Erro contornavel detectado
		cTabela := SUBSTR(cErrMessage, nIdxEr + 21,  3)
		dbSelectArea(cTabela)
		conout("Tabela sem inicialização detectada : "+cTabela)
	else
		cErrMessage := FwNoAccent(cErrMessage)
		if ! OFINJD3503_JaEnviouEmail(cErrMessage)
			conout(cErrMessage)
			oEmailHlp:SendTemplate({;
				{'template'           , 'mil_sys_err'                                                    },;
				{'origem'             , GetNewPar("MV_MIL0088", "")                                      },;
				{'destino'            , GetNewPar("MV_MIL0102", "")                                      },;
				{'assunto'            , "Erro de sistema detectado em " + dtoc(DATE()) + " " + TIME()    },;
				{':titulo'            , "Erro de sistema detectado em " + dtoc(DATE()) + " " + TIME()    },;
				{':cabecalho1'        , "Lamentamos o ocorrido, seguem detalhes do mesmo:"               },;
				{':dados_cabecalho1'  , cErrMessage                                                      } ;
			})
		end
	end
Return .T.

/*/{Protheus.doc} OFINJD3502_PrepareTable

	@author       Vinicius Gati
	@since        05/12/2015
	@description  Da load na tabela para evitar erro na integração com outras rotinas

/*/
Function OFINJD3502_PrepareTable(cTabela)
	SX2->(dbSetOrder(1))
	if SX2->(dbSeek(cTabela))
		dbSelectArea(cTabela)
		&(cTabela)->(dbGoTop())
		if lDebug
			conout("abrindo:" + cTabela)
		End
	end
Return .T.

/*/{Protheus.doc} OFINJD3503_JaEnviouEmail

	@author       Vinicius Gati
	@since        05/12/2015
	@description  Verifica se já foi enviado o erro, para evitar enviar muitos emails do mesmo assunto no mesmo dia

/*/
Function OFINJD3503_JaEnviouEmail(cErrMessage)
	Local nIdx := 1
	Local oUtil := DMS_Util():New()
	Local cFileName := "OFINJD35_EMAILS_"+DTOS(date())+left(strtran(TIME(), ':', ''), 2)+".log" // 1 email por hora somente
	Local aEmails

	oData   := oUtil:ParamFileOpen(cFileName)
	aEmails := oData:getValue('emails', {})
	
	if ! Empty(aEmails)
		for nIdx := 1 to LEN( aEmails )
			if alltrim(aEmails[nIdx]) == alltrim(FwNoAccent(cErrMessage))
				conout("email já enviado, será enviado outro somente no próximo dia.")
				return .T.
			end
		end
	end
	AADD(aEmails, alltrim(cErrMessage))
	oData:SetValue('emails', aEmails)
	oUtil:ParamFileSave(cFileName, oData)
Return .F.

/*/{Protheus.doc} OFINJD3504_IMPORD
	Importacao do arquivo orders
	
	@type function
	@author Vinicius Gati
	@since 23/08/2017
/*/
Function OFINJD3504_IMPORD(oDpmCfg, cPath, aArqData)
	local oOrders
	Local oBckBlk  := ErrorBlock()
	
	ErrorBlock({ |e| ;
		OFINJD3501_EnviaEmailDeErro(e:Description),;
		KillApp(.t.);
	})
	BEGIN TRANSACTION
		oOrders := DMS_DPMOrders():New( cPath , aArqData[1], oDpmCfg:cGrupo )
		If oOrders:AllOk()
			if oOrders:Efetivar()
				conout("Arquivo ORDER importado com sucesso.")
				FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
			Else
				conout("Ocorreu um erro na importação do arquivo ORDER")
			EndIf
		EndIf
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.

/*/{Protheus.doc} OFINJD3505_IMPXFE
	Importa o dpm transfer
	
	@type function
	@author Vinicius Gati
	@since 23/08/2017
/*/
Function OFINJD3505_IMPXFE(oDpmCfg, cPath, aArqData)
	local oXFer
	Local oBckBlk  := ErrorBlock()
	
	ErrorBlock({ |e| ;
		OFINJD3501_EnviaEmailDeErro(e:Description),;
		KillApp(.t.);
	})
	BEGIN TRANSACTION
		oXFer := DMS_DPMXFers():New( cPath , aArqData[1], oDpmCfg:cGrupo )
		If oXFer:AllOk()
			if oXFer:Efetivar()
				conout("Arquivo TRANSFER importado com sucesso.")
				FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
			Else
				conout("Ocorreu um erro na importação do arquivo TRANSFER")
			EndIf
		Else
			conout(STR0018 /* "JDPRISM Warning: Padrão de arquivo xFer inválido. Arquivo:" */ + cPath + ALLTRIM(" \ ") + aArqData[1] )
		EndIf
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.

/*/{Protheus.doc} OFINJD3506_IMPSCH
	Importa arquivo dpmsched
	
	@type function
	@author Vinicius Gati
	@since 23/08/2017	
/*/
Function OFINJD3506_IMPSCH(oDpmCfg, cArqCtnt, aArqData, cPath)
	Local oBckBlk  := ErrorBlock()
	
	ErrorBlock({ |e| ;
		OFINJD3501_EnviaEmailDeErro(e:Description),;
		killapp(.t.);
	})
	BEGIN TRANSACTION
		cVQLFN := oLogger:LogToTable({; // salva arquivo já importado para não fazer 2 vezes pro mesmo grupo
			{'VQL_AGROUP' , oDpmCfg:cGrupo },;
			{'VQL_CODVQL' , cTblLogCod     },;
			{'VQL_TIPO'   , 'DPMSCHED_IMP' },;
			{'VQL_DADOS'  , aArqData[1]    } ;
		})
		cVQLFN := oLogger:LogToTable({; // salva o conteudo do arquivo para o grupo SCHEDULE = padrão e DPMC[1-4] para cada grupo
			{'VQL_AGROUP' , oDpmCfg:cGrupo  },;
			{'VQL_CODVQL' , cVQLFN          },;
			{'VQL_TIPO'   , 'DPMSCHED_FILE' },;
			{'VQL_DADOS'  , cArqCtnt        } ;
		})

		oSched  := DMS_DPMSched():New(oDpmCfg:cGrupo)
		oSched:UpdateGers(.T.) // o True aqui serve para verificar se é init, só deve ser feito quando o arquivo é recém importado
		FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.
