#INCLUDE "TmsA340.ch" 
#Include 'Protheus.ch'

Static lRestRepom := SuperGetMV('MV_VSREPOM',,"1") == "2.2"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA340  ³ Autor ³ Alex Egydio           ³ Data ³26.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encerramento de Viagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA340(cSer340,cTra340,nInd340,cFilOri,cViagem)

Local aCores		:= {}
Local cFiltro     := ""

Private cCadastro	:= STR0001 //'Encerramento de Viagem'
Private aIndex    := {}
Private bFiltraBrw
						
DEFAULT nInd340	:= 3
DEFAULT cFilOri	:= ''
DEFAULT cViagem	:= ''
DEFAULT cSer340	:= ' '
DEFAULT cTra340	:= ' '

Private cSerTms	:= cSer340
Private cTipTra	:= cTra340        

If Type("aRotina") == "U"
	Private aRotina	   := MenuD340()
EndIf
                
Pergunte("TMA340",.F.)

Aadd(aCores,{"DTQ_STATUS=='1'",'BR_VERDE'		})	//-- Em Aberto
Aadd(aCores,{"DTQ_STATUS=='5'",'BR_VERMELHO'	})	//-- Fechada
Aadd(aCores,{"DTQ_STATUS=='2'",'BR_AMARELO'		}) //-- Em Transito
Aadd(aCores,{"DTQ_STATUS=='4'",'BR_LARANJA'		})	//-- Chegada em Filial
Aadd(aCores,{"DTQ_STATUS=='3'",'BR_AZUL'		})	//-- Encerrada
Aadd(aCores,{"DTQ_STATUS=='9'",'BR_PRETO'		})	//-- Cancelada

DbSelectArea('DTQ')

If	Empty( cViagem )
	DbSetOrder( nInd340 )

	cFiltro := "DTQ_FILIAL == '" + xFilial("DTQ") + "' .And. "
	cFiltro += "DTQ_SERTMS == '" + cSer340 + "' .And. "
	cFiltro += "DTQ_TIPTRA == '" + cTra340 + "'"

	CursorWait()
	bFiltraBrw := {|| FilBrowse("DTQ",@aIndex,@cFiltro) }
	Eval(bFiltraBrw)
	CursorArrow()

	//-- Endereca a funcao de BROWSE
	mBrowse( 6,1,22,75,'DTQ', , , , , ,aCores )

	EndFilBrw("DTQ",aIndex)
Else
	// Em Transito ou Chegada Parcial
	If DTQ->DTQ_STATUS != "2" .And. DTQ->DTQ_STATUS != "4"
		Help("",1,"TMSA34012") //--"Encerramento somente permitido em viagens em Transito ou Chegada Parcial"
		Return
	EndIf		
	TMSA340Grv()
EndIf

RetIndex('DTQ')

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA340Mnt³ Autor ³ Alex Egydio           ³ Data ³26.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encerramento de Viagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA340Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA340Mnt( cAlias, nReg, nOpcx, aStruct, lEstAuto )

Local cSeek			:= ''
Local aSays			:= {}
Local aButtons		:= {}
Local aRegioes		:= {}
Local lContVei		:= SuperGetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local cAtivCHG		:= SuperGetMv("MV_ATIVCHG",," ") // Atividade de Chegada.
Local lContinua		:= .T. 
Local cEncVDoc		:= SuperGetMv("MV_ENCVDOC",,"0") // Permite encerrar uma viagem, com documentos em transito, em uma filial diferente da filial Origem.
Local lEncVDoc		:= .F.  
Local cViagem		:= ""   
Local cFilOri		:= ""
Local lLibCTC		:= SuperGetMV( 'MV_LIBCTC', , .F. )
Local cFilCTC		:= IF(Empty(FwFilial('DTY')), xFilial('DTY'), DTQ->DTQ_FILORI)
Local lTMSOPdg		:= SuperGetMV( 'MV_TMSOPDG', , '0' ) == '2' //-- Integracao com Operadoras de Frota
Local lFrotaProp	:= .F.
Local aMsgErr		:= {}
Local cEncRepom		:= SuperGetMV( "MV_ENREPOM", , "1" ) // -- Encerra Repom pela 1=Ocorrencia / 2=Encerramento  
Local lRetPE		:= .F.  
Local lTM340OPE		:= ExistBlock('TM340OPE')
Local lChegFil		:= .F.
Local cAliasQry		:= GetNextAlias()
Local cQuery		:= ''
Local lTM340MNT		:= ExistBlock('TM340MNT')
Local cNotas		:= ""
Local lMVITMSDMD	:= SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.
Local cColGFE		:= SuperGetMV("MV_COLGFE",.F.,"0")   //0-Padrão, 1-Encerramento
Local aAreasAnt		:= {}
Local lTMS3GFE		:= Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local cTMS3GFE		:= SuperGetMV("MV_TMS3GFE",,"N")  //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Integra
Local lQuitEnc		:= .F.
Local cHelp			:= ""

Default lEstAuto	:= .F.

Private aValInf		:= {}

/* Verifica se o registro n„o est  em uso por outra esta‡„o. */
If !SoftLock("DTQ")
	Return Nil
EndIf

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If !TMSAVerAge("6",,,,,,,,,,,,"2",.T.,.T.,,DTQ->DTQ_VIAGEM,)
	Return .F.
EndIf

If nOpcx == 3
	SetMVValue("TMA340","MV_PAR01",0) // Inicializa a Quantidade de Pernoite com 'Zero'           
EndIf    

Pergunte("TMA340",.F.)

If nOpcx == 4   // Estornar
	If DTQ->DTQ_STATUS <> StrZero(3,Len(DTQ->DTQ_STATUS)) //-- Encerrado
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help("",1,"TMSA34008")  // O Estorno so' sera' efetuado em Viagens Encerradas ...
		Return .F.
	EndIf
   
	If DTQ->DTQ_FILATU <> cFilAnt
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( ' ', 1, 'TMSA31006',, DTQ->DTQ_FILATU, 2, 8 ) // Estorno habilitado somente para a filial
		Return .F.
	EndIf
	
   //-- Se nao for Transporte Aereo/Fluvial, so permite Estornar o Encerramento da Viagem, se todos os Veiculos / Motoristas
   //-- utilizados na Viagem, estejam com Status == '1' (Em Aberto)   
	If A340AtuStat(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, nOpcx)
		If !TMSA340Vei()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return .F.
		EndIf
	EndIf
	
	If !A340VerDUD()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( ' ', 1,"TMSA34013")  // O Estorno nao sera realizado, pois existem documentos da viagem atual já vinculados em uma outra viagem
		Return .F.
	EndIf

	//-- Valida Se Viagem Pode Ser Estornada Conforme Serviço e/ou Cod. Neg.
	If FindFunction("TmsVlVgSrv") .And. TmsVlVgSrv( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM , @cNotas )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( ' ', 1, 'TMSA34017',, cNotas, 2, 8 ) //-- Existem Solicitações De Coleta Que Estão Vinculadas a  Nota(s) Já Calculada(s).  
		Return .F.
	EndIf

	//-- Ponto de Entrada para validar estorno
	If	ExistBlock('TMA340EST')
		lContinua := ExecBlock('TMA340EST',.F.,.F.)
		If ValType(lContinua) == 'L' .And. !lContinua
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return .F.
		ElseIf ValType(lContinua) <> 'L'
			//-- Forca o valor de lContinua para .T. pois o ponto de entrada nao retornou um valor logico
			lContinua := .T.
		EndIf
	EndIf

	//-- Verifica a Situacao do Contrato de Carreteiro (Caso Exista)
	If lLibCTC .Or. lTMSOPdg
		DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
		If DTY->(MsSeek(cFilCTC + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
			//-- Se o contrato de Carreteiro estiver com o status 'Liberado para Pagamento' ou 
			//-- 'Contrato Quitado', nao permitir o estorno do encerramento da viagem.
			If DTY->DTY_STATUS == '3' .Or. DTY->DTY_STATUS == '5'
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				
				If DTY->DTY_STATUS == '3'
					cHelp := STR0036 //"O encerramento da Viagem não podera ser estornado, pois o contrato de carreteiro já foi emitido."
				Else
					cHelp := STR0037 //"O Encerramento da Viagem não podera ser estornado, pois a Viagem está vinculada a um Contrato de Carreteiro com Status de 'Contrato Quitado'."
				EndIf

				Help( NIL, NIL, "TMSA340MntEnce", NIL, cHelp, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0038 } ) //"Realizar o estorno do contrato de carreteiro, e somente após este processo será possivel estornar o encerramento da Viagem."
				Return(.F.)
			EndIf
		EndIf
	EndIf

	If	DUD->(FieldPos("DUD_NUMRED")) > 0
		If	T340VerRdp()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( ' ', 1,"TMSA34015")  // Existe contrato de redespacho gerado para esta viagem.
			Return .F.
		EndIf
	EndIf

	If	lEstAuto .Or. MsgYesNo( STR0012  + DTQ->DTQ_FILORI + '/' + DTQ->DTQ_VIAGEM + " ?" )  //'Confirma Estorno do Encerramento da Viagem '###'Sim'###'Nao'
			//-- Ponto de Entrada para processar o estorno.
		If	ExistBlock('TMA340PRC')
			lContinua := ExecBlock('TMA340PRC',.F.,.F., { nOpcx })
			If ValType(lContinua) == 'L' .And. !lContinua
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Return .F.
			EndIf
		EndIf
		Begin Transaction
	
			If lContinua
				RecLock('DTQ',.F.)
				DTQ->DTQ_DATENC := CriaVar('DTQ_DATENC', .F.)
				DTQ->DTQ_HORENC := CriaVar('DTQ_HORENC', .F.)
				
				DbSelectArea("DTW")
				DTW->(DbSeek(xFilial("DTW")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
				While DTW->(!EOF()) .And. xFilial("DTW")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM == DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM)
					If DTW->DTW_ATIVID == cAtivCHG .And. !Empty(DTW->DTW_DATINI)
						lChegFil := .T.
						Exit
					EndIf
					DTW->(DbSkip())
				EndDo
				
				If lChegFil
					DTQ->DTQ_STATUS := StrZero(4,Len(DTQ->DTQ_STATUS))	//-- Chegada Em Filial
				Else
					DTQ->DTQ_STATUS := StrZero(2,Len(DTQ->DTQ_STATUS))	//-- Em Transito
				EndIf

				//-- Atualiza Gestão de Demandas
				If lMVITMSDMD .And. FindFunction("PlnDmdTran") .And. TableInDic("DL9")
					PlnDmdTran(TVgGetPlnD(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM),  '7') //Estorna Viagem -> Volta Planejamento da Demanda para "Em transito"
				EndIf
				
				DTQ->DTQ_QTDPER := 0  // Quantidade de pernoite
				MsUnLock()
			
				DTW->(dbSetOrder(3))
				DTW->(MsSeek( cSeek := xFilial('DTW')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))
				While DTW->(! Eof() .And. DTW_FILIAL+DTW_FILORI+DTW_VIAGEM == cSeek )
					If DTW->DTW_STATUS == StrZero( 9, Len(DTW->DTW_STATUS)) // Cancelado ### Chegada de Viagem
						cQuery := " SELECT (COUNT(*)) TOTREG FROM " + RetSqlName("DTW") + " DTW "
						cQuery += "  WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
						cQuery += " 	AND DTW.DTW_FILORI = '" + DTW->DTW_FILORI + "' "
						cQuery += " 	AND DTW.DTW_VIAGEM = '" + DTW->DTW_VIAGEM + "' "
						cQuery += " 	AND DTW.DTW_STATUS = '" + StrZero(2, Len(DTW->DTW_STATUS)) + "' "
						cQuery += " 	AND DTW.DTW_SEQUEN > '" + DTW->DTW_SEQUEN + "' "
						cQuery += " 	AND DTW.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
						////////////////////////////////////////////////////////////////////////////////						
						// SOMENTE RE-ABRIR A OPERACAO, CASO NAO EXISTAM OPERACOES ENCERRADAS ADIANTE //
						////////////////////////////////////////////////////////////////////////////////
						If (cAliasQry)->TOTREG == 0
							DTW->( RecLock('DTW',.F.) )
							DTW->DTW_DATREA := CriaVar('DTW_DATREA', .F.)
							DTW->DTW_HORREA := CriaVar('DTW_HORREA', .F.)
							DTW->DTW_STATUS := StrZero(1,Len(DTW->DTW_STATUS))	//-- Aberto
							DTW->( MsUnLock() )
						EndIf
						(cAliasQry)->( dbCloseArea() )
					EndIf
					DTW->(dbSkip())
				EndDo
	 
				If lContVei
					If ValType(mv_par02) == "N" .And. mv_par02 == 1  //Libera automaticamente o veiculo/motorista
						TMSA340Sta(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '2', '3')
					Else
						TMSA340Sta(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '1', '3')
					EndIf
				EndIf
	      
		     	//-- Retorna o Status do Contrato de Carreteiro para 'Em Aberto'
				If lLibCTC .Or. lTMSOPdg
					DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
					DTY->(MsSeek(cFilCTC + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
					While DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == cFilCTC + DTQ->(DTQ_FILORI + DTQ_VIAGEM)
						If DTY->DTY_STATUS == '2'
							RecLock('DTY',.F.)
							DTY->DTY_STATUS := '1'
							MsUnLock()
						EndIf
						DTY->(DbSkip())
					EndDo
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				If lTMSOPdg 
					lQuitEnc:= T340RepCFG()
				EndIf

				If lTMSOPdg  .And.  lQuitEnc //cEncRepom == "1" // -- Encerramento na Repom pela Rotina de Encerramento
					DTR->(DbSetOrder(1))
					If DTR->(MsSeek(xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM)) .And. !Empty(DTR->DTR_CODOPE) .And. !Empty(DTR->DTR_PRCTRA)
						lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
						If !lEstAuto
							CursorWait()
							MsgRun( If( !lFrotaProp, STR0025, STR0026 ) ,; //-- 'Solicitando Autorizacao para Quitacao do Contrato na Operadora...' ## 'Baixa da Viagem junto a Operadora de Frotas...'
							STR0001,; //-- 'Encerramento de Viagem'
							{|| lContinua := TMA340Oper( DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgErr, lFrotaProp, nOpcx )} )
							CursorArrow()
						Else
							lContinua := TMA340Oper( DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgErr, lFrotaProp, nOpcx )
						EndIf
						
						//-- Ponto de Entrada para tratar a quitacao do contrato efetuada no Posto pelo Carreteiro
						If lTM340OPE
							lRetPE := ExecBlock('TM340OPE',.F.,.F., { DTR->DTR_CODOPE, cFilOri, cViagem, @aMsgErr, lFrotaProp, nOpcx, lContinua})
							If ValType(lRetPE) == 'L'
								lContinua:= lRetPE
							EndIf
						EndIf
					EndIf
				EndIf
				
				//-- Tratamento Para Estorno De Custeio De Viagens De Coleta
				If lContinua

					//-- Calcular Valorização Da Viagem De Coleta Qdo Parametrizado.
					If DTQ->DTQ_SERTMS $ '1/3' //-- Coleta/Entrega
						/* Não Limpa Mais As Referencias, Pois Os Valores Serão Substituidos Pelo DJI
						//-- Limpa Referências De Valorização da Coleta
						Tmsa310LVC( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .f., .f., Nil, .t. )
						*/
						
						//-- Retorna Para o DT8 e DT6 o Último Movimento 'Previsto' Válido. 
						TmsAtuDJI( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '1', '4', Nil, lEstAuto ) //-- TmsAtuDJI( cFilVge, cViagem, cTipCal, cStatus, aParTab, lRotAut )
						
					EndIf
				EndIf		

				If lContinua .And. ExistFunc("Tms3GfeInt")
					//----- Integração de Solicitação de Coleta TMS x GFE 
					If cColGFE == "1" .And. DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE)) .And. lTMS3GFE .And. cTMS3GFE <> 'N'
					    If DTQ->DTQ_SERADI == StrZero(1,Len(DTQ->DTQ_SERADI)) .Or. DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) 							
							//--- Chama a Ocorrencia de Integração com o GFe das Coletas
   							If ExistFunc('TM360OcGFE')
								lContinua:= T340OcoGFE(.F.)								
   							EndIf
							If lContinua   
								aAreasAnt:= GetArea()
								lContinua:= Tms3GfeInt(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., .T.)
								RestArea(aAreasAnt)
							EndIf	
						EndIf	
					EndIf	
				EndIf
		      
				If lContinua
					If __lSX8
						ConfirmSX8()
					EndIf
				Else // Se der Problema com a Repom rotina operacao no TMS
					If	__lSX8
						RollBackSX8()
					EndIf
					DisarmTransaction()
				EndIf

			EndIf
		End Transaction
	EndIf

	If !Empty(aMsgErr) .And. !lEstAuto
		TmsMsgErr( aMsgErr )
	EndIf
	
Else  // Encerrar

	If DTQ->DTQ_FILATU <> cFilAnt
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( ' ', 1, 'TMSA34011',, DTQ->DTQ_FILATU, 2, 8 ) // Encerramento habilitado somente para a filial
		Return .F.
	EndIf
	
	// Em Transito ou Chegada Parcial
	If DTQ->DTQ_STATUS != "2" .And. DTQ->DTQ_STATUS != "4"
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help("",1,"TMSA34012") //"Encerramento somente permitido em viagens em Transito ou Chegada Parcial"
		Return
	EndIf
	
	//-- Somente permite encerrar viagem de transporte com documentos "Em Transito" devido a necessidade da ocorrencia
	//-- nas viagens de coleta e entrega
	DUD->(dbSetOrder(4))
	If DTQ->DTQ_SERTMS == "2" .And. ( DUD->(MsSeek(xFilial("DUD")+DTQ->DTQ_FILORI+StrZero(2,Len(DUD->DUD_STATUS))+DTQ->DTQ_VIAGEM)) .Or. DTQ->DTQ_TIPVIA == "2")
		If cEncVDoc == "0" //Nao encerra a viagem
			lEncVDoc := .F.
		ElseIf cEncVDoc == "1" //Encerra a viagem
			lEncVDoc := .T.
		ElseIf cEncVDoc == "2"
			If (Aviso(STR0016 ,STR0027,{STR0013,STR0014}) == 1) //'Aviso'###'"Existem Documentos em trânsito para esta viagem. Confirma o Encerramento?" '###'Sim'###'Nao'
				lEncVDoc := .T.
			Else
				lEncVDoc := .F.
			EndIf
		EndIf
	EndIf
	
	If !lEncVDoc .And. DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) // Transporte
		aRegioes := TMSRegDca( DTQ->DTQ_ROTA )
		If Ascan( aRegioes, { | e | e[3] == cFilAnt } ) == 0
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ', 1, 'TMSA34003')	//-- Somente as Filiais na Rota desta Viagem podem encerra-la.
			Return
		EndIf
	EndIf
	
	//-- Inicializa aValInf
	TmsValInf(aValInf,'10',DTQ->DTQ_FILORI,,,,,,,,,,,3,DTQ->DTQ_VIAGEM)

	Aadd( aSays, OemToAnsi(STR0006) ) //'Este programa tem como objetivo, efetuar o Encerramento da viagem. '
	Aadd( aSays, OemToAnsi(STR0007) ) //'Apos a confirmacao, a viagem ficara com status ( Encerrada ) .'
	    
	Aadd( aButtons, { 1, .T., {|o| TMSA340Grv(.F.,aValInf,lEncVDoc, nOpcx), o:oWnd:End() } } )
	Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
		
	//-- Valor informado
	Aadd( aButtons, { 11, .T., {|o| TmsValInf(aValInf,'9',DTQ->DTQ_FILORI,,,,,,,,,,,3,DTQ->DTQ_VIAGEM) } } )

	Aadd( aButtons, { 5, .T., {|o| Pergunte("TMA340",.T.)} } )
	
	FormBatch( cCadastro, aSays, aButtons )

EndIf

MsUnLockAll()

If lTM340MNT
	ExecBlock("TM340MNT",.F.,.F.,{nOPcx,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM })
EndIf
MbrChgLoop()
//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA340Grv³ Autor ³ Alex Egydio           ³ Data ³26.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA340Grv()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA340Grv(lEncAuto,aValInf,lEncvDoc, nOpcx, lHelpAuto)

	Local aAreas     := {	DA3->(GetArea()),;
								DT2->(GetArea()),;
								DT5->(GetArea()),;
								DT6->(GetArea()),;
								DT8->(GetArea()),;
								DTO->(GetArea()),;
								DTP->(GetArea()),;
								DTR->(GetArea()),;
								DTU->(GetArea()),;
								DTQ->(GetArea()),;
								DTW->(GetArea()),;
								DTY->(GetArea()),;
								DUA->(GetArea()),;
								DUD->(GetArea()),;
								GetArea()	}

	Local aAreaDTW    := DTW->(GetArea())
	Local aAreaDTQ    := DTQ->(GetArea())								
	Local cFilOri     := DTQ->DTQ_FILORI
	Local cViagem     := DTQ->DTQ_VIAGEM
	Local cHoraEnc    := ''
	Local cSeek       := ''
	Local cStatus     := StrZero( 1, Len( DTW->DTW_STATUS ) )
	Local lEncerrar   := .T.
	Local lCancelaDTW := .F.
	Local aSemDUA     := {}
	Local lContVei    := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
	Local lColeta
	Local cStatusDUD  := "'" + StrZero(1,Len(DUD->DUD_STATUS)) + "/" + StrZero(2,Len(DUD->DUD_STATUS)) + "'"
	Local lLibCTC     := SuperGetMV( 'MV_LIBCTC',, .F. )
	Local cFilCTC     := IF(Empty(FwFilial('DTY')), xFilial('DTY'), DTQ->DTQ_FILORI)
	Local lTMSOPdg    := SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
	Local lFrotaProp  := .F.
	Local aMsgErr     := {}
	Local lFoundDF6   := .F.
	Local lRet        := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcoes do parametro "MV_PCANOP" :                    ³
	//³ 0 = Cancelar Operacao.                               ³
	//³ 1 = Perguntar se a operacao deve ser cancelada.      ³
	//| 2 = Nao Cancelar									 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nPCanOp 		:= GetMv('MV_PCANOP',,1) // Opcoes para o cancelamento de operacoes de transportes. 1=Perg.Antes de Canc.;2=Nao Canc.;3=Apont.Obrigat.
	Local lPergOp 		:= nPCanOp == 1          // Exibe pergunta(Cancela operacoes Sim/Nao)
	Local oXmlChk	 	:= Nil //-- Objeto para consultar repom
	Local lREPHasEnc 	:= .F. //-- Indica se já encerrou em posto, após consultar REPOM, para não enviar nova quitação para a operadora, apenas encerrar no TMS
	Local cAtivChg	 	:= GetMV('MV_ATIVCHG',,'')
	Local cAtivSai	 	:= GetMV('MV_ATIVSAI',,'')
	Local lRetPE     	:= .F.
	Local lTM340OPE 	:= ExistBlock('TM340OPE')
	Local lLibVgBlq  	:= SuperGetMV('MV_LIBVGBL',,.F.)  //-- Libera Encerramento de viagens com ocorrencia do tipo Bloqueia Documento.
	Local lTma340TOk 	:= ExistBlock('TMA340TOK')
	Local cRem			:= ""
	Local cDes			:= ""
	Local nCnt			:= 0
	Local cAliasQry  	:= GetNextAlias()
	Local cQuery     	:= ''
	Local cServEnt      := Padr(GetMV("MV_SVCENT",,""),Len(DC5->DC5_SERVIC))
	Local cVsRepom      := SuperGetMV( 'MV_VSREPOM',, '1' )  //-- Versao 2- Contempla nova Legislacao (Encerramento viagem no Posto)
	Local cLocalQuit    := ''    //0-Filial, 1-Posto
	Local lFilial		:= .T.
	Local cNumLot		:= ""
	Local cContr		:= ""  //-- Cargolift Fase2 Número Do Contrato Para Valorização Da Coleta
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local aZeraVlr   := {}
	Local aInfDT8    := {}
	Local lRegCol        := .F.
	Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.	
	Local lMDFEAUT 	:= SuperGetMv('MV_MDFEAUT',,.F.) .And. ExistFunc("TmsMDFeAut") //--MDFe Automático 
	Local cFilBack	 := cFilAnt
	Local aAreaSM0 	:= SM0->(GetArea())
	Local lUFAtiv     := DTX->(ColumnPos("DTX_UFATIV")) > 0
	Local lTMS3GFE    := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
	Local cTMS3GFE    := SuperGetMV("MV_TMS3GFE",,"N")  //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Integra
	Local cColGFE     := SuperGetMV("MV_COLGFE",.F.,"0")   //0-Padrão, 1-Encerramento
	Local aAreasAnt   := {}
	Local lGerOcoGFE  := .F.
	Local lQuitEnc    := .F.
	Local lTMSIntChk  := SuperGetMV("MV_TMAPCKL",,.F.) .And. ExistFunc("TMSIntChk") .And.ExistFunc("TMSDLZAti") .AND. TMSDLZAti()
	Local lVigFret		:= .F.
	Local l310VgTF		:= FINDFUNCTION( "TMS310VgTF" )
	Local l310AVg		:= FINDFUNCTION( "TMS310AVg" )
	Local aMsg			:= {}
	Local lAvisa 		:= !IsBlind()

	IF Type("cSerTms") == "U"
		Private cSerTms	:= DTQ->DTQ_SERTMS
	EndIF

	IF Type("cTipTra") == "U"
		Private cTipTra := " "
	EndIF

	Default lEncAuto 	:= .F. //-- Verifica a origem da chamada
	Default aValInf  	:= {}
	Default lEncVDoc 	:= .F. //-- Informa se a viagem foi encerrada em uma filial diferente da filial de origem
	Default nOpcx    	:= 3
	Default lHelpAuto := .F.
                 
	Pergunte("TMA340",.F.)

	If lHelpAuto
	//-- Grava Help´s em arquivo de LOG
		If ( Type("lMsHelpAuto") <> "L" )
			lMsHelpAuto := .T.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para validar a gravacao do Encerramen³
	//³to da Viagem                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                 
	If lTma340TOk
		lRet := ExecBlock("TMA340TOK",.F.,.F., {cFilOri, cViagem, lEncAuto, nOpcx, cSerTms, cTipTra} )
		If ValType(lRet) # "L"
			lRet := .F.
		EndIf
		If !lRet
			Return(.F.)
		EndIf
	EndIf

	If DTQ->DTQ_STATUS != "2" .And. DTQ->DTQ_STATUS != "4"
		Help("",1,"TMSA34012") //"Encerramento somente permitido em viagens em Transito ou Chegada Parcial"
		Return(.F.)
	EndIf

	Begin Transaction
		CursorWait()
	
		// Operacoes de Transporte
		If !lEncAuto .And. nPCanOp <> 2
			lCancelaDTW := .T.
			DTW->( DbSetOrder( 3 ) )
			If	DTW->( MsSeek( cSeek := xFilial('DTW') + cFilOri + cViagem + cStatus ) )
				If lPergOp // Exibe pergunta(Cancela operacoes Sim/Nao)
					If (Aviso(STR0016,STR0008 + " " + STR0034,{STR0009,STR0010},,STR0004) <> 1) //'Existem operacoes de transporte em aberto para esta viagem. Estas operacoes serao canceladas.'###'Continua'###'Sair'###'Encerramento' //'AVISO'
						lCancelaDTW := .F.
						lEncerrar   := .F.
					EndIf
				ElseIf nPCanOp == 3
					Help("",1,"TMSA34016")
					lEncerrar := .F.
				EndIf
			EndIf
		Else
			If nPCanOp == 0 .Or. nPCanOp == 1
				lCancelaDTW := .T.
			ElseIf nPCanOp == 3 .And. DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS))
				DTW->( DbSetOrder( 3 ) )
				If	DTW->( MsSeek( cSeek := xFilial('DTW') + cFilOri + cViagem + cStatus ) )
					lEncerrar := .F.
				ElseIf !DTW->( MsSeek( cSeek := xFilial('DTW') + cFilOri + cViagem ) )
					lEncerrar := .F.
				ElseIf DTW->DTW_SERVIC == cServEnt
					lEncerrar := .F.
				EndIf
			
				If lEncerrar
					If lLibVgBlq
						If !T340VerDoc() //-- Com parametro habilitado pode encerrar a viagem, caso os doc tenham ocorrencia <> de informativa.
							lEncerrar := .T.
						EndIf
					Else
						Help("",1,"TMSA34016")
						lEncerrar := .F.
					EndIf
				EndIf
			Else // 2 OU 3
				cQuery := " SELECT (COUNT(*)) TOTREG FROM " + RetSqlName("DTW") + " DTW "
				cQuery += "  WHERE DTW.DTW_FILIAL =  '" + xFilial("DTW") + "' "
				cQuery += " 	AND DTW.DTW_FILORI = '" + cFilOri + "' "
				cQuery += " 	AND DTW.DTW_VIAGEM = '" + cViagem + "' "
				cQuery += " 	AND DTW.DTW_STATUS = '" + cStatus + "' "
				cQuery += " 	AND DTW.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				If (cAliasQry)->(!Eof()) .And. (cAliasQry)->TOTREG > 0
					If nPCanOp == 2
						lCancelaDTW := .F.
					Else
						lCancelaDTW := .F.
						lEncerrar 	:= .F.
					EndIf
				EndIf
			
				(cAliasQry)->( dbCloseArea() )
			EndIf
		EndIf
		      
		If !lRestRepom 
			//-- Verificar se o fornecedor entrega em Filial ou Posto
			DUP->(DbSetOrder(1))                                    //-- Motorista da viagem
			If DUP->(DbSeek(xFilial("DUP")+cFilOri+cViagem))  .And. lTMSOPdg
				DA4->(DbSetOrder(1))                                 //-- Motorista
				If DA4->(DbSeek(xFilial("DA4")+DUP->DUP_CODMOT))
					SA2->(DbSetOrder(1))                         //-- Fornecedores
					If SA2->(DbSeek(xFilial("SA2")+DA4->DA4_FORNEC+DA4->DA4_LOJA))
						cLocalQuit	:= SA2->A2_LOCQUIT 		// Entrega Filial = Nao pode quitar em posto
					EndIf
					
					//-- Viagem Vazia, o local de quitacao sera sempre em Filial, por nao haver baixa antecipada
					If DTQ->DTQ_TIPVIA == StrZero( 2, Len( DTQ->DTQ_TIPVIA ) )
						cLocalQuit := StrZero( 0, Len( SA2->A2_LOCQUIT ) ) 	//Filial
					EndIf
				EndIf
			EndIf
		EndIf 

		If lEncerrar
			//-- Grava o valor informado
			TmsGrvInf(aValInf,'4',DTQ->DTQ_FILORI,,,,,,,,3,DTQ->DTQ_VIAGEM)
			// Verificar se existem ocorrencias para documentos de viagem de coleta ou entrega
			If DTQ->DTQ_SERTMS $ "1|3" // Coleta & Entrega
				lColeta := DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS))
	
				If DTQ->DTQ_SERTMS == '1' //-- Coleta
					DF6->(DbSetOrder(1))
					If DF6->(MsSeek(xFilial('DF6')+cFilOri+cViagem)) .And. DF6->DF6_QTDENF == DF6->DF6_QTDDIG
						lFoundDF6 := .T.
					Else
						lFoundDF6 := .F.
					EndIf
				EndIf
	
				If !lFoundDF6
					DUD->(DbSetOrder(2))  // DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILDOC+DUD_DOC+DUD_SERIE
					DUD->( MsSeek( xFilial() + cFilOri + cViagem ) )
					While DUD->( !Eof() .And. (DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == xFilial("DUD")+cFilOri+cViagem) )
						If DUD->DUD_STATUS $ cStatusDUD .And. !TMSA340Rdp()
							If DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS))
								// Posiciona o DT5(Solicitacao de Coleta).
								DT5->(dbSetOrder(4))
								DT5->(MsSeek(xFilial("DT5") + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE))
							
								// Posiciona o DUE(Cadastro de Solicitantes).
								DUE->(dbSetOrder(1))
								DUE->(MsSeek(xFilial("DUE") + DT5->DT5_CODSOL))
							
								Aadd( aSemDUA, { DUD->(DUD_FILDOC + "-" + DUD_DOC + "/" + DUD_SERIE), DUE->DUE_NOME } )
							Else
								//-- Com parametro habilitado pode encerrar a viagem, caso os doc tenham ocorrencia <> de informativa.
								//-- Com parametro desabilitado pode encerrar a viagem, desde que tenha uma ocorrencia do tipo 21 - Trecho
								If (!lLibVgBlq .And. !T340VerDoc('21')) .Or. !T340VerDoc() 
									cRem := Posicione("SA1", 1, xFilial("SA1")+Posicione( "DTC", 3, xFilial("DTC") + (DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)), "DTC_CLIREM+DTC_LOJREM"), "A1_NOME")
									cDes := Posicione("SA1", 1, xFilial("SA1")+Posicione( "DTC", 3, xFilial("DTC") + (DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)), "DTC_CLIDES+DTC_LOJDES"), "A1_NOME")
		
									Aadd( aSemDUA, { DUD->(DUD_FILDOC + "-" + DUD_DOC + "/" + DUD_SERIE), cRem, cDes } )
								EndIf
							EndIf
						ElseIf lTMSIntChk
							EstDocChk( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
						EndIf
	      		
						DUD->( DbSkip() )
					EndDo
				EndIf
			EndIf
				
			//--
			If Len( aSemDUA ) > 0
				//-- Apresenta os Documentos sem Ocorrencias.
				If !lEncAuto
					TMSA340Doc(aSemDUA, lColeta)
				EndIf
				lRet := .F.
			EndIf
						
			If lRet
				If lEncAuto	.And. nPCanOp == 3
					DTW->( DbSetOrder( 3 ) )
					If DTW->( MsSeek( cSeek := xFilial('DTW') + cFilOri + cViagem + cStatus ) )
						Help("",1,"TMSA34016")
						lRet     := .F.
						lEncerrar:= .F.
					EndIf
				EndIf
			EndIf
		
			If !lRet
				RestArea( aAreaDTW )
				RestArea( aAreaDTQ )
			EndIf
		
			//-- Ponto de Entrada para processar no encerramento da viagem.
			If	lRet .And. ExistBlock('TMA340PRC')
				lContinua := ExecBlock('TMA340PRC',.F.,.F., { nOpcx })
				If ValType(lContinua) == 'L' .And. !lContinua
					lRet := .F.
				EndIf
			EndIf
	
			cHoraEnc	:= StrTran(Left(Time(),5),':','')

			If lRet

				If lCancelaDTW //Cancela operacoes com pendencia de apontamento
			
					//Posiciona na primeira operacoao da Viagem 
					DTW->( DbSetOrder( 1 ) ) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_SEQUEN
					DTW->( MsSeek( cSeek := xFilial('DTW') + cFilOri + cViagem ) )
				
					While DTW->( !Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM) == cSeek
	                                  
						//Cancelas operacoes abertas (DTW_STATUS = cStatus), nao deve cancelar operacoes de Chegada/Saida, essas devem ser apontadas manualmente, mesmo apos o encerramento da viagem
						If DTW->DTW_STATUS = cStatus .AND. !(DTW->DTW_ATIVID = cAtivChg .Or. DTW->DTW_ATIVID = cAtivSai)
							DTW->( RecLock('DTW',.F.) )
								DTW->DTW_DATREA := dDataBase
								DTW->DTW_HORREA := cHoraEnc
								DTW->DTW_STATUS := StrZero(9,Len(DTW->DTW_STATUS))		//-- Cancelado
							DTW->( MsUnLock() )
						EndIf

						DTW->( DbSkip() )
					EndDo
				EndIf
	    
				RecLock('DTQ',.F.)
				DTQ->DTQ_DATENC := dDataBase
				DTQ->DTQ_HORENC := cHoraEnc
				DTQ->DTQ_STATUS := StrZero(3,Len(DTQ->DTQ_STATUS))	//-- Encerrado
				If DTQ->DTQ_SERTMS == StrZero( 1, Len( DTQ->DTQ_SERTMS ) ) .Or. ;
						DTQ->DTQ_SERTMS == StrZero( 3, Len( DTQ->DTQ_SERTMS ) )
					If !lEncAuto
						DTQ->DTQ_QTDPER := mv_par01  // Quantidade de pernoite
					EndIf
				EndIf
				DTQ->( MsUnLock() )
	
				//-- Atualiza Gestão de Demandas
				If lMVITMSDMD .And. FindFunction("PlnDmdTran") .And. TableInDic("DL9")
					PlnDmdTran(TVgGetPlnD(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM),  '4') //Encerrar Viagem -> Encerra Planejamento Demanda
				EndIf				

				//-- Verifica se deve atualizar o status do veiculo/motorista.
				If lContVei .And. A340AtuStat(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, 3)
					If ValType(mv_par02) == "N" .And. mv_par02 == 1  //Libera automaticamente o veiculo/motorista
						TMSA340Sta(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '3', '2')
					Else
						TMSA340Sta(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '3', '1')
					EndIf
				EndIf
		
				If lEncVDoc
		  			//Modifica o Status do DUD do documento para Cancelado e Cria um novo registro no DUD para o documento.
					A340AtuDUD()
				EndIf
	    
				//-- Atualiza o Status do Contrato de Carreteiro (Se Houver)
				If !lRestRepom .And. ( lLibCTC .Or. lTMSOPdg ) 
					DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
					DTY->(MsSeek(cFilCTC + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
					While DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == cFilCTC + DTQ->(DTQ_FILORI + DTQ_VIAGEM)
						If DTY->DTY_STATUS == '1'
							RecLock('DTY',.F.)
							If DTY->(FieldPos("DTY_LOCQUI")) > 0 .And. cVsRepom == '2'
								DTY->DTY_LOCQUI:= cLocalQuit
							EndIf
							If cLocalQuit == '1' .And. DTY->DTY_CODOPE == '01'// Posto ? 
								DTY->DTY_STATUS := '1' //-- Aberto, aguardando WS quitaContrato
							Else                 // Filial ?
								If lLibCTC
									DTY->DTY_STATUS := '2' //-- Aguardando Liberacao para Pagamento
								ELse
									DTY->DTY_STATUS := "3" //-- Liberado para pagamento
								EndIf
							EndIf
							MsUnLock()
						EndIf
						DTY->(DbSkip())
					EndDo
				EndIf
	
				//-- Ponto de Entrada apos o encerramento de viagem
				If	ExistBlock('TMA340GRV')
					lRet := ExecBlock('TMA340GRV',.F.,.F.)
				EndIf
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTMSOPdg
					lQuitEnc:= T340RepCFG()
				EndIf

				If lTMSOPdg .And. lQuitEnc //cEncRepom == "1" // -- Encerra Repom pela Rotina de Encerramento
					// Controle de quitação posto ou filial
					If !lRestRepom .And. cVsRepom == '2'						
						DUP->(DbSetOrder(1))                                    //-- Motorista da viagem
						If DUP->(DbSeek(xFilial("DUP")+cFilOri+cViagem))
							DA4->(DbSetOrder(1))                                 //-- Motorista
							If DA4->(DbSeek(xFilial("DA4")+DUP->DUP_CODMOT))
								SA2->(DbSetOrder(1))                         //-- Fornecedores
								If SA2->(DbSeek(xFilial("SA2")+DA4->DA4_FORNEC+DA4->DA4_LOJA))
									cLocalQuit	:= SA2->A2_LOCQUIT 		// Entrega Filial = Nao pode quitar em posto
								EndIf
								//-- Viagem Vazia, o local de quitacao sera sempre em Filial, por nao haver baixa antecipada
								If DTQ->DTQ_TIPVIA == StrZero( 2, Len( DTQ->DTQ_TIPVIA ) )
									cLocalQuit := StrZero( 0, Len( SA2->A2_LOCQUIT ) ) 	//Filial
								EndIf
							EndIf
						EndIf
						If cLocalQuit == '1'
							lFilial := .F.
						EndIf
					ElseIf lRestRepom 
						lFilial	:= .T. 
					EndIF

					DTR->(DbSetOrder(1))
					If DTR->(MsSeek(xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM)) .And. DTR->DTR_CODOPE == '01' //.And. !Empty(DTR->DTR_PRCTRA)
						CursorWait()

						If lRestRepom
							lREPHasEnc	:= .F. 
						Else 
							DEG->(DbSetOrder(1))
							If DEG->(MsSeek(xFilial('DEG')+DTR->DTR_CODOPE)) .And. cLocalQuit == '1' //-- se for quitação em posto, verifica se já está quitado antes de encerrar e, se tiver, não integra.. 
								oXmlChk := TmsConsRep( DEG->DEG_IDOPE, DEG->DEG_CODACE, DEG->DEG_URLWS, DTQ->DTQ_FILORI, DTR->DTR_PRCTRA,  DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM )
								If ValType( oXmlChk ) == 'O' .And. (AllTrim(oXmlChk:_Processo_Transporte:_status_codigo:Text) == "17" .Or. AllTrim(oXmlChk:_Processo_Transporte:_status_codigo:Text) == "6")	//-- Status Repom contido em "17-Prestado Contas"|"6-Pago"
									lREPHasEnc := .T. //-- Indica se já encerrou em posto, após consultar REPOM, para não enviar nova quitação para a operadora, apenas encerrar no TMS
								EndIf
							EndIf
						EndIf 

						//-- Nâo integra com a Repom caso já tenha sido encerrado no posto.
						If !lREPHasEnc
							If !lFilial
								MsgRun( 'Baixa Antecipada do Contrato junto a Operadora de Frotas...' ,;
									STR0001,; //-- 'Encerramento de Viagem'
								{|| lEncerrar := TMA340Oper( DTR->DTR_CODOPE, cFilOri, cViagem, @aMsgErr, , nOpcx, .F. )} )
							Else
								lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
								MsgRun( If( !lFrotaProp, STR0025, STR0026 ) ,; //-- 'Quitacao do Contrato junto a Operadora de Frotas...' ## 'Baixa da Viagem junto a Operadora de Frotas...'
								STR0001,; //-- 'Encerramento de Viagem'
								{|| lEncerrar := TMA340Oper( DTR->DTR_CODOPE, cFilOri, cViagem, @aMsgErr, lFrotaProp, nOpcx )} )
							EndIf
						EndIf
						CursorArrow()
						//-- Ponto de Entrada para tratar a quitacao do contrato efetuada no Posto pelo Carreteiro
						If lTM340OPE
							lRetPE := ExecBlock('TM340OPE',.F.,.F., { DTR->DTR_CODOPE, cFilOri, cViagem, @aMsgErr, lFrotaProp, nOpcx, lEncerrar})
							If ValType(lRetPE) == 'L'
								lEncerrar:= lRetPE
							EndIf
						EndIf
					EndIf
				EndIf
			
				//-- Calcular Valorização Da Viagem De Coleta Qdo Parametrizado.
				If cSerTMS $ '1/3' .And. DTQ->DTQ_TIPVIA <> StrZero( 2, Len( DTQ->DTQ_TIPVIA ) ) //-- Coleta/Entrega e diferente de Vazia  
			
					//-- Limpa Referências De Valorização da Coleta
					Tmsa310LVC( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .f., .f., Nil, .f. )

					//-- Loop Por Lote
					cQuery :=	" SELECT      DT5.DT5_FILDOC, DT5.DT5_DOC, DT5.DT5_SERIE, DUD.DUD_LOTE, DT5.DT5_NCONTR, DT5.R_E_C_N_O_ DT5REC, DUD.R_E_C_N_O_ DUDREC "
					cQuery +=	" FROM        " + RetSQLName("DUD") + " DUD "
					cQuery +=	" INNER JOIN  " + RetSQLName("DT5") + " DT5 "
					cQuery +=	" ON          DT5.DT5_FILIAL  =  '" + xFilial("DT5") + "' "
					cQuery +=	" AND         DT5.DT5_FILDOC  =  DUD.DUD_FILDOC "
					cQuery +=	" AND         DT5.DT5_DOC     =  DUD.DUD_DOC "
					cQuery +=	" AND         DT5.DT5_SERIE   =  DUD.DUD_SERIE "
					cQuery +=	" AND         DT5.DT5_SERIE   =  'COL' "
					cQuery +=	" AND         DT5.DT5_CODNEG  <> '" + Space(TamSX3("DT5_CODNEG")[1]) + "' "
					cQuery +=	" AND         DT5.DT5_SERVIC  <> '" + Space(TamSX3("DT5_SERVIC")[1]) + "' "
					cQuery +=	" AND         DT5.D_E_L_E_T_  =  ' ' "
					cQuery +=	" WHERE       DUD.DUD_FILIAL  =  '" + xFilial("DUD") + "' "
					cQuery +=	" AND         DUD.DUD_FILORI  =  '" + DTQ->DTQ_FILORI + "' "
					cQuery +=	" AND         DUD.DUD_VIAGEM  =  '" + DTQ->DTQ_VIAGEM + "' "
					cQuery +=	" AND         DUD.D_E_L_E_T_  =  ' ' "
					cQuery +=	" ORDER BY    DUD.DUD_LOTE "
	
					cQuery := ChangeQuery(cQuery)
					
					Eval(bQuery)

					//-- Formata Campo DT5.R_E_C_N_O_
					TcSetField(cAliasT,"DT5REC","N",16,0)
					TcSetField(cAliasT,"DUDREC","N",16,0)					

					//-- Inicializa Variáveis
					cNumLot := ""
					cContr  := ""

					DbSelectArea("DT6")
					DT6->(DbSetOrder( 1 )) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE

					DbSelectArea(cAliasT)
					(cAliasT)->(DbGoTop())

					While (cAliasT)->( !Eof())
					
						cNumLot := (cAliasT)->DUD_LOTE
						cContr  := (cAliasT)->DT5_NCONTR
						lRegCol := .T.
						
						DbSelectArea(cAliasT)
						While (cAliasT)->( !Eof()) .And. (cAliasT)->DUD_LOTE == cNumLot

							//-- Exclui Lotes Vazios Do Tratamento (Tratamento Erro CargoLift)
							If Empty((cAliasT)->DUD_LOTE)
								(cAliasT)->(DbSkip())
								Loop
							EndIf
	
							//-- Posiciona Nos Movimentos Da Viagem Pelo RECNO
							DbSelectArea("DUD")
							DUD->(DbGoTo((cAliasT)->DUDREC))
	
							//-- Posiciona No Agendamento Pelo RECNO
							DbSelectArea("DT5")
							DT5->(DbGoTo((cAliasT)->DT5REC))
							
							If DT6->(MsSeek(FWxFilial('DT6') + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE ) )
								If l310VgTF
									lVigFret := If( !Empty(DT6->DT6_TABFRE) .AND. !Empty(DT6->DT6_TIPTAB),TMS310VgTF( DT6->DT6_TABFRE, DT6->DT6_TIPTAB ), .T. )
									If !lVigFret
										aAdd( aMsg ,{	DUD->DUD_VIAGEM,;  //-- 01
														DT6->DT6_FILDOC,;  //-- 02
														DT6->DT6_DOC   ,;  //-- 03
														DT6->DT6_SERIE ,;  //-- 04
														DT6->DT6_DATEMI,;  //-- 05
														DT6->DT6_CDRORI,;  //-- 06
														DT6->DT6_CDRDES,;  //-- 07
														DT6->DT6_CLIREM,;  //-- 08
														DT6->DT6_LOJREM,;  //-- 09
														DT6->DT6_CLIDES,;  //-- 10
														DT6->DT6_LOJDES,;  //-- 11
														DT6->DT6_NCONTR,;  //-- 12
														DT6->DT6_SERVIC,;  //-- 13
														DT6->DT6_CODNEG } )//-- 14
									EndIf
								EndIf
								//-- Valoriza Coleta Não Realizada
								If TmsSobServ('VALCOL',,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"0", Nil ) == '2' .AND. lVigFret //-- 1 = SIM ; 2 = NAO
				
									//-- Posiciona Nas Ocorrencias da Viagem
									DbSelectArea("DUA")
									DbSetOrder(4) //-- DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_FILORI+DUA_VIAGEM
									If MsSeek( FWxFilial("DUA") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE , .F.)
				
										//-- Procura Por Ocorrencias De Cancelamento
										While DUA->(!Eof()) .And. DUA->DUA_FILIAL + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE == xFilial("DUA") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE
													
											//-- Posiciona No Cad. Ocorrencias
											DbSelectArea("DT2")
											DbSetOrder(1)
											MsSeek( FWxFilial("DT2") + DUA->DUA_CODOCO , .F. )
														
											//-- Verifica Se Trata-se De Cancelamento / Retorno Dcto
											If DT2->DT2_TIPOCO == StrZero(12,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(04,Len(DT2->DT2_TIPOCO))
		
												//-- Verifica Se Trata-se De Rateio (Se Não Utiliza Rateio, Remove Documento )
												If TmsSobServ('BACRAT',,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"1", Nil ) == '1' //-- '1' = Não Utiliza Rateio
												
													//-- Remove Agendamento Do Lote
													RecLock("DUD",.F.)
													Replace DUD_LOTE With ""
													DUD->(MsUnlock())
													
													//-- Posiciona No Cadastro Do Lote
													DbSelectArea("DTP")
													DbSetOrder(1)	//-- DTP_FILIAL+DTP_LOTNFC
													If MsSeek( FWxFilial("DTP") + cNumLot , .F. )
														
														//-- Ajusta dados Do Lote
														RecLock("DTP", .F. )
															
														If DTP->DTP_QTDLOT == 1
															DTP->(DbDelete())
															cNumLot := "" //-- Se Variável Vazia, Não Processa o Lote
														Else
															Replace DTP->DTP_QTDLOT With	( DTP->DTP_QTDLOT - 1 )
															Replace DTP->DTP_QTDDIG With	( DTP->DTP_QTDDIG - 1 )
														EndIf
															
														DTP->(MsUnlock())
														
														Exit	//-- Sai Do Loop Do DUA
							
													EndIf
												Else
													//-- Se For Rateio e 'Valoriza Coleta Não Realizada' = 'Não' e Só Houver Um Documento No Lote, Não Calcula a valorização No TMSA200
													//-- Posiciona No Cadastro Do Lote
													DbSelectArea("DTP")
													DbSetOrder(1)	//-- DTP_FILIAL+DTP_LOTNFC
													MsSeek( FWxFilial("DTP") + cNumLot , .F. )
													If DTP->DTP_QTDLOT == 1
														cNumLot := "" //-- Se Variável Vazia, Não Processa o Lote
													Else	
														aAdd( aZeraVlr, { DUA->DUA_FILDOC,  DUA->DUA_DOC, DUA->DUA_SERIE } )
													EndIf
												EndIf	
											EndIf
								
											DUA->(DbSkip())
										EndDo
									EndIf
								EndIf
							EndIf
							(cAliasT)->(DbSkip())
						EndDo

						If l310AVg .AND. Len(aMsg) > 0
							TMS310AVg( aMsg, lAvisa, .T. )
						EndIf

						//-- Executa o Cálculo Do Frete Para a Coleta
						If !Empty(cNumLot)
							//-- Força Reposicionamento No Lote De Coleta
							DbSelectArea("DTP")
							DbSetOrder(1) //-- DTP_FILIAL+DTP_LOTNFC
							If MsSeek( FWxFilial("DTP") + cNumLot , .f. )
										
								//-- Processa o Cálculo Do Frete Para Valorização Dos Documentos Da Viagem
								TMSA200Mnt("DTP",DTP->(Recno()), 2 , Nil , .f., cContr )
								
								//-- Zera Valores De Componentes (Retorna Documento)
								If !Empty(aZeraVlr)
									Tmsa310LVC( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .f., .f., @aZeraVlr, .f. )								
									Tmsa340Per( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM ) //-- Ajusta Percentuais Dos Documentos Removidos Do Calc. De Rateio
								EndIf
							EndIf
						EndIf
					EndDo

					//-- Verifica Se Valorizou Os Documentos Da Coleta
					If lRegCol  //Registro de Coleta
						If !(Tmsa310Vlr( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM, .t. ))
							lEncerrar := .f. //-- Se Erro, Estorna Movimento
						Else
							//-- Gera Réplica da Tabela DT8
							//-- Posiciona No Movimento Da Viagem
							DbSelectArea("DUD")
							DbSetOrder(2) //-- DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
							MsSeek( FWxFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM , .F. )
						
							While !DUD->(Eof()) .And. (DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == (FWxFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
								
								If DUD->DUD_SERIE == "COL"
								
									aInfDT8 := {} //-- Inicializa Variável
									aAdd( aInfDT8, {'DT8_FILDOC'	, DUD->DUD_FILDOC })
									aAdd( aInfDT8, {'DT8_DOC'		, DUD->DUD_DOC    })
									aAdd( aInfDT8, {'DT8_SERIE'		, DUD->DUD_SERIE  })
									
									//-- Gera Réplica da Tabela DT8
									TmsAtuDJI( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '2', '1', aInfDT8, lEncAuto )					
									
								EndIf	
											
								DUD->(DbSkip())
							EndDo					
						EndIf
					EndIf
						
					//-- Fecha Arquivo Temporário
					If Select(cAliasT) > 0
						(cAliasT)->(DbCloseArea())
					EndIf						
				EndIf
		   			
				//----- Integração de Solicitação de Coleta TMS x GFE 
				If ExistFunc('Tms3GfeInt') .And. lEncerrar 
					If cColGFE == "1" .And. lTMS3GFE .And. DTQ->DTQ_PAGGFE ==  StrZero(1,Len(DTQ->DTQ_PAGGFE))  .And. cTMS3GFE <> 'N'
						If DTQ->DTQ_SERADI == StrZero(1,Len(DTQ->DTQ_SERADI)) .Or. DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))
							aAreasAnt:= GetArea()
							lEncerrar:= Tms3GfeInt(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., .F.)
							If lEncerrar
								lGerOcoGFE:= .T.
							EndIf
							RestArea(aAreasAnt)
						EndIf	
					EndIf
				EndIf

				If lEncerrar
					If __lSX8
						ConfirmSX8()
					EndIf
				Else // Se der Problema com a Repom estorna a gravacao no TMS
					If	__lSX8
						RollBackSX8()
					EndIf
					DisarmTransaction()
				EndIf
			EndIf
		
		EndIf

	End Transaction
		
	If !lEncerrar .And. !Empty( aMsgErr )
		If lHelpAuto
			For nCnt := 1 To Len(aMsgErr)
				AutoGrLog(aMsgErr[nCnt,1])
			Next nCnt
		Else
			TmsMsgErr( aMsgErr )
		EndIf
	EndIf
	
	If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
		lMdfeAut:= TMA190Srv(cFilOri,cViagem)
	EndIf

	If lMDFEAUT .And. Empty( aMsgErr ) //--MDFe Automático
       //-- Encerra manifesto
        aMDFe := {} 
        DTX->(DbSetOrder(5)) //--DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI                                                                                                                     
        DTX->(MsSeek(xFilial("DTX")+cFilOri+cViagem) )
        Do WHile DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM) == xFilial("DTX")+cFilOri+cViagem
            If DTX->DTX_TIPMAN  == '2' .And.  DTX->DTX_STFMDF <> '2' //--Eletronico e não Encerrado              
				Aadd(aMDFe,{DTX->DTX_FILMAN,;
							DTX->DTX_MANIFE,;
							DTX->DTX_MANIFE,;
							DTX->DTX_SERMAN,;
							DTX->DTX_VIAGEM,;
							Iif(lUFAtiv, DTX->DTX_UFATIV, '')})
            EndIf
            DTX->(DbSkip())
        EndDo
                 
       If !Empty(aMDFe) 
			//-- Alterar o conteudo da variavel cFilAnt													
			cFilAnt := aMDFe[Len(aMDFe),1]
			SM0->(MsSeek(cEmpAnt+cFilAnt))									
			lContinua := TmsMDFeAut(aMDFe, 2) //--Encerra o Manifesto    
			cFilAnt := cFilBack 
			RestArea(aAreaSM0)        
		EndIf		
   EndIf


   //--- Chama a Ocorrencia de Integração com o GFe das Coletas
   If lGerOcoGFE .And. ExistFunc('TM360OcGFE')
		T340OcoGFE(lEncerrar)
   EndIf

	//-- Restaura Posicionamento Dos Arquivos
	AEval(aAreas,{|x,y| RestArea(x) })

	CursorArrow()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA340Doc³ Autor ³ Antonio C Ferreira    ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresentacao dos Documentos sem Ocorrencias registradas.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA340Doc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function TMSA340Doc(aSemDUA, lColeta)

Local oDlgEsp
Local cSemDua   := ""
Local oBut1      
Local oSemDUA             
Local cFunction	:= 'TMSA340'

IIf(ExistFunc('FWPDLogUser'),FwPdLogUser(cFunction),)
DEFINE MSDIALOG oDlgEsp TITLE STR0017 FROM 9.8,00 TO 28,80 OF oMainWnd  //"Documentos sem Ocorrencias"

	If lColeta
		// Coleta.
		@ .5,.7 LISTBOX oSemDUA VAR cSemDUA FIELDS HEADER STR0018, STR0019 SIZE 280,130  //"Documento"###"Solicitante"
		oSemDUA:SetArray(aSemDUA)
		oSemDUA:bLine := {|| {aSemDUA[oSemDUA:nAt,1] , aSemDUA[oSemDUA:nAt,2] }}
	Else
		// Entrega.
		@ .5,.7 LISTBOX oSemDUA VAR cSemDUA FIELDS HEADER STR0018, STR0020, STR0021 SIZE 280,130  //"Documento"###"Remetente"###"Destinatario"
		oSemDUA:SetArray(aSemDUA)
		oSemDUA:bLine := {|| {aSemDUA[oSemDUA:nAt,1] , aSemDUA[oSemDUA:nAt,2], aSemDUA[oSemDUA:nAt,3]} }
	EndIf		

	DEFINE SBUTTON oBut1 FROM 4,287  TYPE 1 ACTION oDlgEsp:End() ONSTOP STR0022 ENABLE OF oDlgEsp //"Sair"
ACTIVATE MSDIALOG oDlgEsp CENTERED


Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA340Sta³ Autor ³Patricia A. Salomao    ³ Data ³17.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza Status dos Motoristas e Veiculos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA340Sta(ExpC1,ExpC2,ExpC3,ExpC4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Viagem                                             ³±±
±±³          ³ ExpC3 - Status Atual do Motorista / Veiculo                ³±±
±±³          ³ ExpC3 - Novo Status do Motorista / Veiculo                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA340Sta(cFilOri,cViagem,cOldStatus,cNewStatus,lLibEntr)
	
Local aAreaDTO   := DTO->( GetArea() )
Local aAreaDTU   := DTU->( GetArea() )
Local aAreaDTR   := DTR->( GetArea() )
Local lLiberVei  := .T.
Local lLiberRbq  := .T.
Local cAliasQry  := GetNextAlias()
Local cNumLib    := ""
Default lLibEntr := .F.

// Procura veiculos e/ou motoristas relacionados e muda status para em aberto	
DTO->(dbSetOrder(2))
DTU->(dbSetOrder(2))
DTR->(dbSetOrder(1))
DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) ==  xFilial("DTR")+cFilOri+cViagem
	//-- Verifica se deverá liberar cavalo e motorista na entrada do veiculo na chegada final da viagem
	If lLibEntr
		lLiberRbq := .F.
		DA3->(DbSetOrder(1))
		If DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODVEI))
			DUT->(DbSetOrder(1))
			If DUT->(MsSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
				If DUT->DUT_CATVEI <> StrZero(2,Len(DUT->DUT_CATVEI)) //-- Cavalo
					lLiberVei := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	// Verifica STATUS dos VEICULOS
	If lLiberVei .And. !Empty(DTR->DTR_CODVEI) .And. DTU->(MsSeek(xFilial("DTU")+DTR->DTR_CODVEI+cOldStatus))
		cQuery := " SELECT MAX(DTU_NUMLIB) NUMLIB "
		cQuery += " FROM " + RetSqlName("DTU")
		cQuery += " WHERE DTU_FILVGS = '" + DTR->DTR_FILORI + "' "
		cQuery += " 	AND DTU_NUMVGS = '" + DTR->DTR_VIAGEM + "' "
		cQuery += " 	AND DTU_CODVEI = '" + DTR->DTR_CODVEI + "' "
		cQuery += " 	AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(!Eof())
			cNumLib := (cAliasQry)->NUMLIB
		EndIf
		(cAliasQry)->(DbCloseArea())
		DbSelectArea("DTU")
		Reclock("DTU",.f.)
		DTU->DTU_STATUS := cNewStatus
		DTU->DTU_NUMLIB := cNumLib
		If cNewStatus == StrZero(2,Len(DTU->DTU_STATUS))  // Liberado
			DTU->DTU_DATLIB := dDataBase
			DTU->DTU_HORLIB := StrTran(Left(Time(),5),':','')
		EndIf
		MsUnlock()
	EndIf
	If lLiberRbq .And. !Empty(DTR->DTR_CODRB1) .And. DTU->(MsSeek(xFilial("DTU")+DTR->DTR_CODRB1+cOldStatus))
		cQuery := " SELECT MAX(DTU_NUMLIB) NUMLIB "
		cQuery += " FROM " + RetSqlName("DTU")
		cQuery += " WHERE DTU_FILVGS = '" + DTR->DTR_FILORI + "' "
		cQuery += " 	AND DTU_NUMVGS = '" + DTR->DTR_VIAGEM + "' "
		cQuery += " 	AND DTU_CODVEI = '" + DTR->DTR_CODRB1 + "' "
		cQuery += " 	AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(!Eof())
			cNumLib := (cAliasQry)->NUMLIB
		EndIf
		(cAliasQry)->(DbCloseArea())
		DbSelectArea("DTU")
		Reclock("DTU",.f.)
		DTU->DTU_STATUS := cNewStatus
		DTU->DTU_NUMLIB := cNumLib
		If cNewStatus == StrZero(2,Len(DTU->DTU_STATUS))  // Liberado
			DTU->DTU_DATLIB := dDataBase
			DTU->DTU_HORLIB := StrTran(Left(Time(),5),':','')
		EndIf
		MsUnlock()
	EndIf
	If lLiberRbq .And. !Empty(DTR->DTR_CODRB2) .And. DTU->(MsSeek(xFilial("DTU")+DTR->DTR_CODRB2+cOldStatus))
		cQuery := " SELECT MAX(DTU_NUMLIB) NUMLIB "
		cQuery += " FROM " + RetSqlName("DTU")
		cQuery += " WHERE DTU_FILVGS = '" + DTR->DTR_FILORI + "' "
		cQuery += " 	AND DTU_NUMVGS = '" + DTR->DTR_VIAGEM + "' "
		cQuery += " 	AND DTU_CODVEI = '" + DTR->DTR_CODRB2 + "' "
		cQuery += " 	AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(!Eof())
			cNumLib := (cAliasQry)->NUMLIB
		EndIf
		(cAliasQry)->(DbCloseArea())
		DbSelectArea("DTU")
		Reclock("DTU",.f.)
		DTU->DTU_STATUS := cNewStatus
		DTU->DTU_NUMLIB := cNumLib
		If cNewStatus == StrZero(2,Len(DTU->DTU_STATUS))  // Liberado
			DTU->DTU_DATLIB := dDataBase
			DTU->DTU_HORLIB := StrTran(Left(Time(),5),':','')
		EndIf
		MsUnlock()
	EndIf
	If DTR->(ColumnPos('DTR_CODRB3')) > 0
		If lLiberRbq .And. !Empty(DTR->DTR_CODRB3) .And. DTU->(MsSeek(xFilial("DTU")+DTR->DTR_CODRB3+cOldStatus))
			cQuery := " SELECT MAX(DTU_NUMLIB) NUMLIB "
			cQuery += " FROM " + RetSqlName("DTU")
			cQuery += " WHERE DTU_FILVGS = '" + DTR->DTR_FILORI + "' "
			cQuery += " 	AND DTU_NUMVGS = '" + DTR->DTR_VIAGEM + "' "
			cQuery += " 	AND DTU_CODVEI = '" + DTR->DTR_CODRB3 + "' "
			cQuery += " 	AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
			If (cAliasQry)->(!Eof())
				cNumLib := (cAliasQry)->NUMLIB
			EndIf
			(cAliasQry)->(DbCloseArea())
			DbSelectArea("DTU")
			Reclock("DTU",.f.)
			DTU->DTU_STATUS := cNewStatus
			DTU->DTU_NUMLIB := cNumLib
			If cNewStatus == StrZero(2,Len(DTU->DTU_STATUS))  // Liberado
				DTU->DTU_DATLIB := dDataBase
				DTU->DTU_HORLIB := StrTran(Left(Time(),5),':','')
			EndIf
			MsUnlock()
		EndIf
	EndIf 
	If lLiberVei
		DUP->(dbSetOrder(1))
		DUP->(MsSeek(xFilial("DUP")+cFilOri+cViagem+DTR->DTR_ITEM))
		// Verifica STATUS dos MOTORISTAS 
		While !DUP->(Eof()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR) == xFilial("DUP")+cFilOri+cViagem+DTR->DTR_ITEM
			If !Empty(DUP->DUP_CODMOT) .And. DTO->(MsSeek(xFilial("DTO")+DUP->DUP_CODMOT+cOldStatus))
				cQuery := " SELECT MAX(DTO_NUMLIB) NUMLIB "
				cQuery += " FROM " + RetSqlName("DTO")
				cQuery += " WHERE DTO_FILVGS = '" + DUP->DUP_FILORI + "' "
				cQuery += " 	AND DTO_NUMVGS = '" + DUP->DUP_VIAGEM + "' "
				cQuery += " 	AND DTO_CODMOT = '" + DUP->DUP_CODMOT + "' "
				cQuery += " 	AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
				If (cAliasQry)->(!Eof())
					cNumLib := (cAliasQry)->NUMLIB
				EndIf
				(cAliasQry)->(DbCloseArea())
				DbSelectArea("DTO")
				Reclock("DTO",.F.)
				DTO->DTO_STATUS := cNewStatus
				DTO->DTO_NUMLIB := cNumLib
				If cNewStatus == StrZero(2,Len(DTO->DTO_STATUS))  // Liberado
					DTO->DTO_DATLIB := dDataBase
					DTO->DTO_HORLIB := StrTran(Left(Time(),5),':','')
				EndIf
				MsUnlock()
			EndIf
			DUP->(dbSkip())
		EndDo
	EndIf
	DTR->(dbSkip())
EndDo

// Restaura areas originais
RestArea(aAreaDTO)
RestArea(aAreaDTU)
RestArea(aAreaDTR)

Return .T.          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA340Vis³ Autor ³Patricia A. Salomao    ³ Data ³17.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualizacao do Encerramento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA340Vis()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA340Vis()

Private l140Auto := .F.
Private lPergF12 := .F.

If DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) .Or. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
   TMSA141Mnt('DTQ', Recno(), 2)
Else
   TMSA140Mnt('DTQ', Recno(), 2)	
EndIf     

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A340AtuStat³ Autor ³Eduardo de Souza      ³ Data ³ 06/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se devera atualizar o status do veiculo/motorista.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A340AtuStat(ExpC1,ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Viagem                                             ³±±
±±³          ³ ExpN3 - Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A340AtuStat(cFilOri, cViagem, nOpcx)

Local aAreaDTR := DTR->(GetArea())
Local aAreaDTQ := DTQ->(GetArea())
Local aAreaDTU := DTU->(GetArea())
Local cVgeInt  := ""  
Local lAtuStat := .T.
Local aViagens := {} //Somente as Viagens Encerradas ou Somente as Viagens Não encerradas
Local aViagOri := {} //Todas as Viagens interligadas e a Viagem Original
Local lExistInt:= .F.  
Local cCodVei  := ""  //Codigo do veiculo

DTQ->(DbSetOrder(2))
DTR->(DbSetOrder(1))

If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
	cVgeInt := Iif(Empty(DTR->DTR_NUMVGE), DTR->DTR_FILORI+DTR->DTR_VIAGEM, DTR->DTR_FILVGE+DTR->DTR_NUMVGE) 
	cCodVei := DTR->DTR_CODVEI 
	// Verifica se existem viagens interligadas.
	DTR->(DbSetOrder(2))
	DTR->(MsSeek(xFilial("DTR")+cVgeInt))
	While DTR->(!Eof()) .And. (DTR->DTR_FILIAL+DTR->DTR_FILVGE+DTR->DTR_NUMVGE) == (xFilial("DTR")+cVgeInt) 
		//Não permite adicionar a viagem que esta sendo Encerrada 
    	If (DTR->DTR_FILORI+DTR->DTR_VIAGEM) <> (cFilOri+cViagem) .Or. nOpcx == 4
	 		If DTQ->(MsSeek(xFilial("DTQ")+DTR->DTR_FILORI+DTR->DTR_VIAGEM))
  				If  nOpcx == 3  //Encerramento     
	  				//No Encerramento se o Status da Viagem for diferente de Encerrada ou Cancelada 
  					If DTQ->DTQ_STATUS  <> StrZero(3 ,Len(DTQ->DTQ_STATUS)) .And.;
  					   DTQ->DTQ_STATUS  <> StrZero(9 ,Len(DTQ->DTQ_STATUS))
						Aadd(aViagens, {DTR->DTR_FILORI, DTR->DTR_VIAGEM})
					EndIf	 
  				Else  //Estorno   
	  				//No Estorno se o Status da Viagem for igual a Encerrada ou Cancelada  
  					If DTQ->DTQ_STATUS  == StrZero(3 ,Len(DTQ->DTQ_STATUS)) .Or.;
  					   DTQ->DTQ_STATUS  == StrZero(9 ,Len(DTQ->DTQ_STATUS))
						Aadd(aViagens, {DTR->DTR_FILORI, DTR->DTR_VIAGEM})
			 		EndIf
				EndIf
			EndIf
		EndIf
		lExistInt := .T.
		DTR->(dbSkip())
	EndDo
	
	//Verifica status da viagem original.  
	If lExistInt   
   		//Nao verifica  a viagem que está sendo encerrada.
    	If cVgeInt <> (cFilOri+cViagem) .Or. nOpcx == 4 //Quando existe viagem interligada e estorno da viagem original preenche o vetor aViagOri, que será usado na rotina logo abaixo
			DTR->(DbSetOrder(1))    
			If DTR->(MsSeek(xFilial("DTR")+cVgeInt))
				If DTQ->(MsSeek(xFilial("DTQ")+DTR->DTR_FILORI+DTR->DTR_VIAGEM))
					If  nOpcx == 3  //Encerramento
						If DTQ->DTQ_STATUS  <> StrZero(3 ,Len(DTQ->DTQ_STATUS)) .And.;
  					   	   DTQ->DTQ_STATUS  <> StrZero(9 ,Len(DTQ->DTQ_STATUS))  
							Aadd(aViagens, {DTR->DTR_FILORI, DTR->DTR_VIAGEM})
						EndIf	 
  			   		Else  //Estorno
						If DTQ->DTQ_STATUS  == StrZero(3 ,Len(DTQ->DTQ_STATUS)) .Or.;
  					   	   DTQ->DTQ_STATUS  == StrZero(9 ,Len(DTQ->DTQ_STATUS))  
							Aadd(aViagens, {DTR->DTR_FILORI, DTR->DTR_VIAGEM})
				   		EndIf 
					EndIf	
					Aadd(aViagOri, {DTR->DTR_FILORI, DTR->DTR_VIAGEM})
				EndIf
			EndIf			
		EndIf	
	EndIf
  
	//Se Encerramento, nao libera o veículo quando alguma viagem interligada ou original tem o Status diferente de encerrada ou cancelada
    //Se Estorno, não checa e não muda o Status do veículo quando alguma viagem interligada ou encerrada tem o status igual a Encerrada ou cancelada
	If Len(aViagens) > 0  
    	If nOpcx == 3 //Quando Encerramento mostrar Help
			Help(" ",1,"TMSA43016",,aViagens[1,1]+"-"+aViagens[1,2],3,1) // O Veiculo/Motorista digitado esta sendo utilizado na viagem :
		Endif
	    lAtuStat := .F. 
  	EndIf
EndIf   

//Quando Estorno de Viagens Interligadas, Verifica se o Veiculo esta reservado para uma viagem diferente 
//da viagem original.
If nOpcx == 4 .And. lExistInt 
	DTU->(dbSetOrder(2))
	If DTU->(MsSeek (xFilial("DTU")+cCodVei+StrZero(3 ,Len(DTU->DTU_STATUS)))) 
		If Ascan(aViagOri, {|x| x[1]+x[2] == DTU->DTU_FILVGE+DTU->DTU_NUMVGE}) == 0	
			lAtuStat := .T.  // Veiculo reservado para outra viagem diferente da viagem original
		EndIf
	Else
		lAtuStat := .T. //Veiculo nao está reservado mas pode ter sido liberado por uma outra viagem.		
	EndIf
EndIf

RestArea(aAreaDTR)
RestArea(aAreaDTQ)
RestArea(aAreaDTU)

Return lAtuStat

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA340Vei ³ Autor ³Eduardo de Souza      ³ Data ³ 10/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o veiculo/motorista esta 'Em Aberto'           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA340Vei()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA340Vei(lHelp)
Local lContVei := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local lEmViag  := GetMV("MV_EMVIAG",,.F.) // Utilizado para verificar se o veiculo esta em uso em outra viagem.
Local lRet     := .T.
Local cFilVge  := ""
Local cNumVge  := ""

Default lHelp  := .T.

//--- Verifica se a Viagem Principal tem alguma viagem interligada
DTR->(DbSetOrder(2))
If DTR->(MsSeek(xFilial('DTR') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	cFilVge:= DTR->DTR_FILORI
	cNumVge:= DTR->DTR_VIAGEM
EndIf

DTR->(DbSetOrder(1))
If DTR->(MsSeek(xFilial('DTR') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	While !DTR->(Eof()) .And. DTR->(DTR_FILIAL + DTR_FILORI + DTR_VIAGEM) == xFilial('DTR') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)
		If lRet .And. (lContVei .Or. lEmViag)
			If Empty(cNumVge)
				cFilVge:= DTR->DTR_FILVGE
				cNumVge:= DTR->DTR_NUMVGE
			EndIf
			
			//-- Veiculo Principal
			If !TMSEmViag(,,DTR->DTR_CODVEI, 1, lHelp,,,cFilVge,cNumVge)
				lRet := .F.
			EndIf
			//-- 1.o Reboque			
			If lRet .And. !Empty(DTR->DTR_CODRB1) .And. !TMSEmViag(,,DTR->DTR_CODRB1, 1, lHelp,,,cFilVge,cNumVge)
				Return(.F.)
			EndIf
			//-- 2.o Reboque
			If lRet .And. !Empty(DTR->DTR_CODRB2) .And. !TMSEmViag(,,DTR->DTR_CODRB2, 1, lHelp,,,cFilVge,cNumVge)
				Return(.F.)
			EndIf
			//-- 3.o Reboque
			If DTR->(ColumnPos('DTR_CODRB3')) > 0
				If lRet .And. !Empty(DTR->DTR_CODRB3) .And. !TMSEmViag(,,DTR->DTR_CODRB3, 1, lHelp,,,cFilVge,cNumVge)
					Return(.F.)
				EndIf
			EndIf
			//-- Motoristas
			If lRet
				DUP->(DbSetOrder(1))
				If DUP->(MsSeek(xFilial('DUP') + DTQ->(DTQ_FILORI + DTQ_VIAGEM) + DTR->DTR_ITEM))
					Do While !DUP->(Eof()) .And. DUP->(DUP_FILIAL + DUP_FILORI + DUP_VIAGEM + DUP_ITEDTR) == xFilial("DUP") + DTQ->(DTQ_FILORI + DTQ_VIAGEM) + DTR->DTR_ITEM
						If lRet .And. !TMSEmViag(,,DUP->DUP_CODMOT, 2, lHelp,,,cFilVge,cNumVge)
							lRet := .F.
						EndIf
						DUP->(DbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
		DTR->(DbSkip())
	EndDo
EndIf

Return(lRet)		


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A340VerDUD³ Autor ³Gilson da Silva		  ³ Data ³11.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se os novos registros que foram criados no DUD no ³±±
±±³          ³ momento do encerramento da viagem estão com o status em    ³±±
±±³          ³ aberto e verifica se o campo DUD_VIAGEM desses registros   ³±±
±±³          ³ está vazio.																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A340VerDUD()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial onde encontra-se o documento.		   		  ³±±
±±³			 ³ ExpC2 - Viagem onde encontra-se o documento.	   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A340VerDUD()
Local aArea 	 := GetArea() 
Local cAliasTop := GetNextAlias()
Local cQuery    := ""
Local lRet      := .T. 

cQuery := "SELECT COUNT(*) NCOUNT FROM "+RetSqlName("DUD")+" DUD1 "
cQuery += " WHERE DUD1.DUD_FILIAL = '"+xFilial("DUD")+"'"
cQuery += "   AND DUD1.DUD_FILORI = '"+DTQ->DTQ_FILORI+"'"
cQuery += "   AND DUD1.DUD_VIAGEM = '"+DTQ->DTQ_VIAGEM+"'"
cQuery += "   AND EXISTS ( SELECT 1 FROM "+RetSqlName("DUD")+" DUD2"
cQuery += "                 WHERE DUD2.DUD_FILIAL  = '"+xFilial("DUD")+"'"
cQuery += "                   AND DUD2.DUD_FILDOC  = DUD1.DUD_FILDOC"
cQuery += "                   AND DUD2.DUD_DOC     = DUD1.DUD_DOC   "
cQuery += "                   AND DUD2.DUD_SERIE   = DUD1.DUD_SERIE "
cQuery += "                   AND DUD2.DUD_FILVGE  = '"+DTQ->DTQ_FILORI+"'"
cQuery += "                   AND DUD2.DUD_NUMVGE  = '"+DTQ->DTQ_VIAGEM+"'"
cQuery += "                   AND DUD2.DUD_VIAGEM <> ' ' "
cQuery += "                   AND DUD2.D_E_L_E_T_  = ' ')"
cQuery += " 	AND DUD1.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
If (cAliasTop)->NCOUNT > 0 
	lRet := .F.   
EndIf	
(cAliasTop)->( DbCloseArea() )
RestArea(aArea)		
Return lRet		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A340AtuDUD³ Autor ³Gilson da Silva		  ³ Data ³11.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Modifica o status do DUD para Cancelado e cria um novo     ³±±
±±³          ³ registro no DUD com o Status em aberto, vinculando-os      ³±±
±±³          ³ através dos campos DUD_FILVGE e DUD_NUMVGE.				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A340AtuDUD()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A340AtuDUD()

Local aArea 	 := GetArea() 
Local cAliasTop := GetNextAlias()
Local cQuery    := ""                    
Local aCampos   := {}
Local cFilOri   := DTQ->DTQ_FILORI
Local cViagem   := DTQ->DTQ_VIAGEM
Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0

cQuery := "SELECT R_E_C_N_O_ NRECDUD FROM "
cQuery += RetSqlName("DUD")+" DUD "
cQuery += " WHERE DUD_FILIAL  = '"+xFilial("DUD")+"'" 
cQuery += "   AND DUD_FILORI  = '"+cFilOri+"'"
cQuery += "   AND DUD_VIAGEM  = '"+cViagem+"'" 
cQuery += "   AND DUD_STATUS  = '2'"   
cQuery += "   AND D_E_L_E_T_  = ' '" 
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)

While (cAliasTop)->( !Eof() )

	DUD->(dbGoTo((cAliasTop)->NRECDUD))
	RecLock('DUD',.F.)
	DUD->DUD_STATUS := StrZero(9,Len(DUD->DUD_STATUS)) //--Cancelado
	MsUnLock()
     
   //-- Gerar um Novo DUD
	dbSelectArea("DUD")
	aCampos  := {}
	Aadd( aCampos, { 'DUD_FILORI', cFilAnt } )
	Aadd( aCampos, { 'DUD_FILATU', cFilAnt } )
	Aadd( aCampos, { 'DUD_FILVGE', cFilOri } )
	Aadd( aCampos, { 'DUD_NUMVGE', cViagem } )
	Aadd( aCampos, { 'DUD_STATUS', StrZero(1,Len(DUD->DUD_STATUS)) } )
	Aadd( aCampos, { 'DUD_VIAGEM', CriaVar('DUD_VIAGEM', .F.) } )  
	Aadd( aCampos, { 'DUD_MANIFE', CriaVar('DUD_MANIFE', .F.) } )
	If lDTX_SERMAN
		Aadd( aCampos, { 'DUD_SERMAN', CriaVar('DUD_SERMAN', .F.) } )
	EndIf
	Aadd( aCampos, { 'DUD_FILMAN', CriaVar('DUD_FILMAN', .F.) } )
	Aadd( aCampos, { 'DUD_SEQUEN', CriaVar('DUD_SEQUEN', .F.) } )
  
	TmsCopyReg( aCampos )
  
  	(cAliasTop)->( DbSkip() )  							
EndDo
(cAliasTop)->( DbCloseArea() )		
RestArea(aArea)		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA340Oper³ Autor ³ Vitor Raspa           ³ Data ³ 15.Nov.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Baixa a Viagem (Propria) ou Autoriza a Quitacao do Contrato ³±±
±±³          ³(Terceiro) junto a Operadora de Frotas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lRet := TMA340Oper(cExpC1, cExpC2, cExpC3, @aExpA1, nExpN1) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 - Codigo da Operadora de Frotas                      ³±±
±±³          ³cExpC2 - Filial de Origem                                   ³±±
±±³          ³cExpC3 - Numero da Viagem                                   ³±±
±±³          ³aExpA1 - Array com as Mensagens de Erro (Por Referencia)    ³±±
±±³          ³lExpL1 - Indicador de Frota Propria (.T.)                   ³±±
±±³          ³nExpN1 - Opcao Selecionada (3-Encerramento / 5-Estorno      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - .T. indica sucesso no processamento do metodo      ³±±    
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA340Oper( cCodOpe, cFilOri, cViagem, aMsgErr, lFrotaProp, nOpcx, lFilial, nValFre )
Local lRet := .T.

If cCodOpe == "01"
	//-- Bloco de código movido para TMSRepom.prw
	lRet := RepQuitaCt( @cCodOpe, @cFilOri, @cViagem, @aMsgErr, @lFrotaProp, @nOpcx, @lFilial, @nValFre )
EndIf

Return( lRet )				


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuD340  ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MenuD340()
     
Private aRotina	:= {	{ STR0002 ,'TMSXPesqui',0,1,0,.F.},;		 	//'Pesquisar'
								{ STR0003 ,'TMSA340Vis',0,2,0,NIL},; 			//'Visualizar'
								{ STR0004 ,'TMSA340Mnt',0,4,0,NIL},; 			//'Encerrar'
								{ STR0011 ,'TMSA340Mnt',0,5,0,NIL},; 			//'Estornar'
								{ STR0023 ,'TMSA140Fbr',0,1,0,NIL},; 			//'Status'
								{ STR0005 ,'TMSA140Leg',0,6,0,.F.} } 			//'Legenda'


If ExistBlock("TMA340MNU")
	ExecBlock("TMA340MNU",.F.,.F.)
EndIf

Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA340Rdp³ Autor ³Andre Godoi				  ³ Data ³04.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se os documentos pertence ao redespacho e se 	  ³±±
±±³          ³ o mesmo esta em status de "Indicado para Entrega"			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  					                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Em caso de pertencer	                                ³±±
±±³			 ³ .F. Em caso de Nao pertencer	                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340Grv                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA340Rdp()
Local aAreaDT6 := DT6->(GetArea())    
Local cCodOco  := PadR(SuperGetMv('MV_OCORRDP',,""), TamSx3('DUA_CODOCO')[1])
Local lRet     := .F.
Local lRedesp  := AliasInDic('DFV')

If lRedesp
	DFV->( DbSetOrder( 2 ) )	//-- Qdo existe doc de redespacho, a viagem pode ser encerrada normalmente.
	If DFV->( MsSeek( xFilial("DFV") + DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
		DUA->(DbSetOrder(3))
		If DUA->(MsSeek(xFilial('DUA') + cCodOco + DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
			//-- Documento indicado p/ entrega
			lRet	:= .T.
		EndIf
	EndIf
EndIf

RestArea(aAreaDT6)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³T340VerRdp³ Autor ³Andre Godoi            ³ Data ³29.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se os documentos pertence ao redespacho e se 	  ³±±
±±³          ³ o mesmo esta em status de "Indicado para Entrega"		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A340RetDUD()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Em caso de pertencer	                                  ³±±
±±³			 ³ .F. Em caso de Nao pertencer	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function T340VerRdp()    
Local lRet		 	:= .F.
Local cAliasQry  	:= GetNextAlias()
Local cQuery		:= ''
Local nQtdDoc		:= 0 
	
DTY->(DbSetOrder(2))

If DTY->(MsSeek( xFilial('DTY') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))

	cQuery :=" SELECT COUNT(*) DUDQTD FROM " + RetSqlName('DUD')
	cQuery +=" 		WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
	cQuery +=" 		  AND	DUD_FILORI = '" + DTQ->(DTQ_FILORI) + "' "
	cQuery +=" 		  AND	DUD_VIAGEM = '" + DTQ->(DTQ_VIAGEM) + "' "   
	cQuery +=" 		  AND	DUD_NUMRED <> ' ' "
	cQuery +=" 		  AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
	nQtdDoc	:=	(cAliasQry)->DUDQTD
	(cAliasQry)->(DbCloseArea())

	If nQtdDoc > 0
		lRet := .T.
	EndIf

EndIf

Return ( lRet )         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³T340VerDoc³ Autor ³Andre Godoi            ³ Data ³29.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe apontento de ocorrencia diferente de 	  ³±±
±±³			 ³	informativa para o documento.									 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 				                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Em caso de Existir		                                ³±±
±±³			 ³ .F. Em caso de Nao Existir		                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function T340VerDoc(cTipOco)    
Local lRet		 	:= .F.
Local cAliasQry  	:= GetNextAlias()
Local cQuery		:= ''
Local nQtdDoc		:= 0
Local lTM340OCO   := ExistBlock("TM340OCO")	
Local nQtdPe      := 0

Default cTipOco   := ""   

cQuery :=" SELECT COUNT(*) DUAQTD "
cQuery += "     FROM " + RetSqlName('DUA') + " DUA, " + RetSqlName("DT2") + " DT2"
cQuery +=" 		WHERE DUA.DUA_FILIAL = '" + xFilial('DUA') + "' "
cQuery +=" 		  AND	DUA.DUA_FILORI = '" + DUD->(DUD_FILORI) + "' "
cQuery +=" 		  AND	DUA.DUA_VIAGEM = '" + DUD->(DUD_VIAGEM) + "' "
If cTipOco == '21'
	cQuery +=" 		  AND DT2.DT2_FILIAL = '" + xFilial('DT2') + "' "
	cQuery +=" 		  AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
	cQuery +=" 		  AND DT2.DT2_TIPOCO = '21'"	// Trecho
Else 
	cQuery +=" 		  AND DUA.DUA_FILDOC = '" + DUD->(DUD_FILDOC) + "' "
	cQuery +=" 		  AND DUA.DUA_DOC	   = '" + DUD->(DUD_DOC) 	 + "' "
	cQuery +=" 		  AND DUA.DUA_SERIE  = '" + DUD->(DUD_SERIE) 	 + "' "
	cQuery +=" 		  AND DT2.DT2_FILIAL = '" + xFilial('DT2') + "' "
	cQuery +=" 		  AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
	cQuery +=" 		  AND DT2.DT2_TIPOCO <>'05'"	// Tem que ser diferente de informativa.
EndIf
cQuery +=" 		  AND DT2.D_E_L_E_T_ <> '*'"
cQuery +=" 		  AND DUA.D_E_L_E_T_ <> '*'"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
nQtdDoc	:=	(cAliasQry)->DUAQTD

(cAliasQry)->(DbCloseArea())    

If lTM340OCO
  nQtdPe := ExecBlock("TM340OCO",.F.,.F., {DUD->DUD_FILORI, DUD->DUD_VIAGEM, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, nQtdDoc })
  If ValType(nQtdPe) == "N"
    nQtdDoc := nQtdPe
  EndIf
EndIf		

If nQtdDoc >= 1
	lRet := .T.
EndIf

Return ( lRet )
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa340Per
@autor		: Eduardo Alberti
@descricao	: Ajusta Percentuais Dos Documentos Removidos Do Calc. De Rateio
@since		: Jul./2016
@param		: 	cFilOri 	: <Caracter> - Filial Origem
				cViagem   	: <Caracter> - Número Da Viagem
/*/
//-------------------------------------------------------------------------------------------------								
Function Tmsa340Per( cFilOri, cViagem )

	Local aAreas     := {DT8->(GetArea()),GetArea()}
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local cQuery     := ""
	Local cCodRet    := StrZero( 4 , TamSX3("DT2_TIPOCO")[1]) + "," + StrZero( 12 , TamSX3("DT2_TIPOCO")[1])
	Local nPos       := 0
	Local aTots      := {}
	Local cCodPas    := ""
	Local nLinCnt    := 0
	Local nPerc      := 0
	
	Default cFilOri  := ""
	Default cViagem  := ""

	//-- Inicializa Controle De Sequence
	Begin Sequence
	
		//-- Verifica Parametro Passado
		If Empty(cViagem)
			Break
		EndIf

		cQuery := ""
		cQuery += " SELECT      DT8.DT8_CODPAS,DT8.DT8_PERRAT, DT8.DT8_VALPAS, DT8.R_E_C_N_O_ RECDT8 "
		cQuery += " FROM        " +	RetSqlName("DT8") + " DT8 " //-- Composição de Frete
		cQuery += " INNER JOIN  " +	RetSqlName("DUD") + " DUD " //-- Movimento de Viagem
		cQuery += " ON          DUD.DUD_FILIAL =  '" + FWxFilial("DUD") + "' "
		cQuery += " AND         DUD.DUD_FILDOC =  DT8.DT8_FILDOC "
		cQuery += " AND         DUD.DUD_DOC    =  DT8.DT8_DOC "
		cQuery += " AND         DUD.DUD_SERIE  =  DT8.DT8_SERIE "
		cQuery += " AND         DUD.DUD_FILORI =  '" + cFilOri + "' "
		cQuery += " AND         DUD.DUD_VIAGEM =  '" + cViagem + "' "
		cQuery += " AND         DUD.D_E_L_E_T_ =  ' ' "
		cQuery += " AND EXISTS (SELECT      0 "
		cQuery += "             FROM        " +	RetSqlName("DUA") + " DUA " //-- Registros de Ocorrências
		cQuery += "             INNER JOIN  " +	RetSqlName("DT2") + " DT2 " //-- Tabela de Ocorrências
		cQuery += "             ON          DT2.DT2_FILIAL  =  '" + FWxFilial("DT2") + "' "
		cQuery += "             AND         DT2.DT2_CODOCO  =  DUA.DUA_CODOCO "
		cQuery += "             AND         DT2.DT2_TIPOCO IN  " + FormatIn( cCodRet , "," ) //-- Códigos de Retorno De Documentos
		cQuery += "             AND         DT2.D_E_L_E_T_  =  ' ' "
		cQuery += "             WHERE       DUA.DUA_FILIAL  =  '" + FWxFilial("DUA") + "' "
		cQuery += "             AND         DUA.DUA_FILORI  =  DUD.DUD_FILORI "
		cQuery += "             AND         DUA.DUA_VIAGEM  =  DUD.DUD_VIAGEM "
		cQuery += "             AND         DUA.D_E_L_E_T_  =  ' ' ) "
		cQuery += " WHERE       DT8.DT8_FILIAL =  '" + FWxFilial("DT8") + "' "
		cQuery += " AND         DT8.DT8_CODPAS <> 'TF' " //-- Remove Componente 'TF' Total Do Frete
		cQuery += " AND         DT8.D_E_L_E_T_ =  ' ' "
		cQuery += " ORDER BY    DT8.DT8_CODPAS "
	
		cQuery := ChangeQuery(cQuery)

		//-- Executa Query
		Eval(bQuery)
	
		//-- Verifica Se Existem Dados Para Processamento
		If nTotReg == 0
			Break
		EndIf
		
		TcSetField( cAliasT ,"DT8_PERRAT" ,"N" ,TamSX3("DT8_PERRAT")[1] ,TamSX3("DT8_PERRAT")[2] )
		TcSetField( cAliasT ,"DT8_VALPAS" ,"N" ,TamSX3("DT8_VALPAS")[1] ,TamSX3("DT8_VALPAS")[2] )
		TcSetField( cAliasT ,"RECDT8"     ,"N" ,14                      ,0                       )

		DbSelectArea(cAliasT)
		(cAliasT)->(DbGoTop())
		
		//-- Primeira Passada Determina Valores Totais Para Proporcionalização
		While (cAliasT)->(!Eof())

			nPos := aScan( aTots, { |x| x[1] == (cAliasT)->DT8_CODPAS })
			
			If nPos == 0
				aAdd( aTots, { 	(cAliasT)->DT8_CODPAS,; //-- 01 - Código Componente
									(cAliasT)->DT8_PERRAT,; //-- 02 - Percentual Rateio Acumulado
									(cAliasT)->DT8_VALPAS,; //-- 03 - Valor Componente Acumulado
									 1						,; //-- 04 - Quantidade De Linhas
									 0 						} )//-- 05 - Percentual Já Utilizado
			Else
				aTots[nPos,02] += (cAliasT)->DT8_PERRAT
				aTots[nPos,03] += (cAliasT)->DT8_VALPAS
				aTots[nPos,04] += 1							
			EndIf	

			DbSelectArea(cAliasT)
			(cAliasT)->(DbSkip())
		EndDo	

		//-- Verifica Necessidade De Ajustes No Percentual Gravado
		DbSelectArea(cAliasT)
		(cAliasT)->(DbGoTop())
		While (cAliasT)->(!Eof())
		
			//-- Verifica Se é a Primeira Linha Do Componente
			If cCodPas <> (cAliasT)->DT8_CODPAS
				cCodPas := (cAliasT)->DT8_CODPAS
				nLinCnt := 1
			Else
				nLinCnt ++
			EndIf					

			nPos := aScan( aTots, { |x| x[1] == (cAliasT)->DT8_CODPAS })
			
			//-- Verifica o Percentual Já Gravado
			If aTots[nPos,2] <> 100

				//-- Verifica Ultima Linha Para Arredondamento De Cálculo
				If nLinCnt < aTots[nPos,4]
				
					//-- Determina o Percentual Atualizado
					nPerc := Round(NoRound( ((cAliasT)->DT8_VALPAS / ( aTots[nPos,3] / 100 )) ,3),TamSX3("DT8_PERRAT")[2])
					
					//-- Atualiza Vetor Com Percentual Utilizado
					aTots[ nPos, 05] += nPerc
					
					DbSelectArea("DT8")
					DT8->(DbGoTo((cAliasT)->RECDT8))
					
					RecLock("DT8",.F.)
					Replace DT8->DT8_PERRAT With nPerc
					DT8->(MsUnlock())					

				Else

					DbSelectArea("DT8")
					DT8->(DbGoTo((cAliasT)->RECDT8))
					
					RecLock("DT8",.F.)
					Replace DT8->DT8_PERRAT With Iif( (cAliasT)->DT8_VALPAS == 0,0,(100 - aTots[ nPos, 05])) 
					DT8->(MsUnlock())					

				EndIf	
			EndIf			

			DbSelectArea(cAliasT)
			(cAliasT)->(DbSkip())
		EndDo

	//-- Finaliza Controle De Sequence
	End Sequence
	
	//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf	

	//-- Restaura Posicionamento Das Tabelas
	AEval(aAreas,{|x,y| RestArea(x) })
	
Return()



//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T340OcoGFE
@autor		: Katia
@descricao	: Realiza o apontamento da ocorrencia no GFE quando o parametro MV_COLGFE = 1
              Onde as coletas sao integradas no momento do Encerramento da Viagem e portanto as 
			  ocorrências do GFE (DT2_CDTIPO) devem ser integradas somente após o documento de carga 
			  serem  gerados. 
@since		: 27/11/2019
@param		: 	lEncerrar : Indica  o processamento do Encerramento ou Estorno do Encerramento
				da Viagem
/*/
//-------------------------------------------------------------------------------------------------		
Function T340OcoGFE(lEncerrar)

Local cAliasDUA:= ""
Local cQuery   := ""
Local lRet     := .T.
Local aArea    := GetArea()
Local aErrTms  := {}

Default lEncerrar:= .T.  //Encerramento Viagem ou Estorno do Encerramento da Viagem

cAliasDUA := GetNextAlias()
cQuery := " SELECT DUA_FILDOC, DUA_DOC, DUA_SERIE, DUA_FILORI, DUA_VIAGEM, DUA_CODOCO, DUA_CODFOR, DUA_LOJFOR, DUA_VALINF, DUA_SEQOCO, DUA_FILOCO, DUA_NUMOCO, DUA_QTDOCO " 
cQuery += "   FROM " + RetSqlName("DUA") + " DUA "
cQuery += "   INNER JOIN " + RetSqlName("DT2") + " DT2 "
cQuery += "   ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
cQuery += "   AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
cQuery += "   AND DT2.DT2_TIPOCO IN ('01','04','21') " //01-Encerra Processo ou 04-Retorna Documento
cQuery += "   AND DT2.DT2_CDTIPO <> ' ' "
cQuery += "   AND DT2.D_E_L_E_T_ = ' ' "
cQuery += "   WHERE DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
cQuery += "   AND DUA.DUA_FILORI = '" + DTQ->DTQ_FILORI + "' "
cQuery += "   AND DUA.DUA_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
cQuery += "   AND DUA.DUA_SERIE = 'COL' "
cQuery += "   AND DUA.DUA_CHVEXT = ' ' "
cQuery += "   AND DUA.DUA_ORIGEM = 'TMSA360E' "
cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "
cQuery += "   ORDER BY DUA_FILORI, DUA_VIAGEM, DUA_FILOCO, DUA_NUMOCO, DUA_FILDOC, DUA_DOC, DUA_SERIE DESC "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDUA, .F., .T.)
While (cAliasDUA)->(!Eof())  
			
	If lEncerrar
		lRet:= TM360OcGFE((cAliasDUA)->DUA_FILDOC,(cAliasDUA)->DUA_DOC,(cAliasDUA)->DUA_SERIE,(cAliasDUA)->DUA_FILORI,(cAliasDUA)->DUA_VIAGEM,(cAliasDUA)->DUA_CODOCO,;
		                  (cAliasDUA)->DUA_CODFOR,(cAliasDUA)->DUA_LOJFOR, (cAliasDUA)->DUA_VALINF,(cAliasDUA)->DUA_SEQOCO, (cAliasDUA)->DUA_FILOCO, (cAliasDUA)->DUA_NUMOCO,;
						  (cAliasDUA)->DUA_QTDOCO )			
	Else
		lRet:= TM360EsGFE( (cAliasDUA)->DUA_FILOCO, (cAliasDUA)->DUA_NUMOCO, (cAliasDUA)->DUA_SEQOCO, (cAliasDUA)->DUA_CODOCO, .T., @aErrTms )
	EndIf					  

	(cAliasDUA)->(DbSkip())  
EndDo
(cAliasDUA)->(DbCloseArea())

If Len(aErrTms) > 0 
	TmsMsgErr(aErrTms)
	lRet:= .F.   
EndIf

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} T340RepCFG
@descricao	: Verifica se Quita a Repom pelo Encerramento da Viagem
@autor		: Katia
@since		: 16/11/2020
@param		: 	lRet
/*/
//------------------------------------------------------------------
Static Function T340RepCFG()
Local lRet      := .F.
Local cRepQui   := ""
Local cEncRepom := SuperGetMV("MV_ENREPOM",,"1") // -- Encerra Repom pela 1=Ocorrencia / 2=Encerramento  

If !lRestRepom
	lRet:= cEncRepom == "1" // -- Encerra Repom pela Rotina de Encerramento 
Else
	cRepQui:= TM15CFGREP('DEG_REPQUI')  //Quitacao
	If cRepQui == "2" //Encerramento
		lRet:= .T.
	EndIf
EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} EstDocChk()
Estorna documentos do check-list caso ainda esteja em aberto

Uso: TMSA340
@author Rodrigo.Pirolo
@since 09/02/2021
/*/
//-----------------------------------------------------------

Static Function EstDocChk( cFilOri, cViagem, cFilDoc, cDoc, cSerie )

Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasQry	:= ""
Local cObserv	:= STR0035//"CheckList cancelado pelo Encerramento da Viagem (TMSA340)."

Default cFilOri		:= ""
Default cViagem		:= "" 
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT  DM0_IDINTG "
cQuery	+= " FROM " + RetSqlName("DM0") + " DM0 "
cQuery	+= " WHERE "
cQuery	+= 		" DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
cQuery	+= 		" AND DM0.DM0_FILDOC = '" + cFilDoc + "' "
cQuery	+= 		" AND DM0.DM0_DOC = '" + cDoc + "' "
cQuery	+= 		" AND DM0.DM0_SERIE = '" + cSerie + "' "
cQuery	+= 		" AND DM0_STATUS = '1' "
cQuery	+= 		" AND DM0.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T. )

While (cAliasQry)->( !EoF() )
	//-- Envia o estorno do Check List
	TMSCanChk( (cAliasQry)->DM0_IDINTG , cFilOri , cViagem, cObserv )
	
	(cAliasQry)->( DbSkip() )
EndDo
	
(cAliasQry)->( dbCloseArea() )

RestArea( aArea )

Return
