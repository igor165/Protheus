#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GpTABCRG   ºAutor³ Mauricio Takakura  º Data ³  15/11/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Enviar informacoes de Tabelas Auxiliares ao cliente        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programador ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ademar Jr.  ³16/02/10³??????/2010³Tratamento da localizacao Peru.           ³±±
±±³Mauricio T. ³27/03/10³006700/    ³Erro gerado na declaracao de DEFAULT      ³±±
±±³            ³        ³       2010³nos itens do Mexico.            		   ³±±
±±³Erika K.    ³18/05/10³10732/     ³Ajuste de string da tabela S025 (Peru).   ³±±
±±³            ³        ³       2010³                                          ³±±
±±³Christiane V³03/11/10³25090/     ³Ajuste Tab. S024 Portugal, cód. Oficiais  ³±±
±±³	           ³		³       2010³                                          ³±±
±±³Alex        ³04/12/10³           ³Inclusao dos gastos com outras empresas.  ³±±
±±³            ³        ³           ³Localizacao Equador                       ³±±
±±³Tiago Malta ³30/11/10³027152/2010³-Alteracao da funcao Gp310TABPTG, ajustado³±±
±±³            ³        ³           ³a Tab.S021 Portugal e incluido tabela S033³±±
±±³Ademar Jr.  ³07/10/10³024301/2010³-Implementado o tratamento pra HomologNet.³±±
±±³Alessandro  ³03/01/11³26914/2010 ³Implementado tratamento para residentes no³±±
±±³            ³        ³           ³exterior.                                 ³±±
±±³Ademar Jr.  ³21/03/11³029310/2010³-Ajuste Tabela S011 de Portugal, conforme ³±±
±±³            ³        ³           ³ novo modelo.                             ³±±
±±³Ademar Jr.  ³22/03/11³00????/2011³-Compatibilizacao do fonte da Fase 4 com a³±±
±±³            ³        ³           ³ Fase Normal do RH.                       ³±±
±±³Tiago Malta ³27/04/11³009779/2011³Ajuste na Tab. Auxiliar S020 - Venezuela. ³±±
±±³/Ademar Jr. ³        ³           ³                                          ³±±
±±³ 		   ³		³			³                                          ³±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ¿±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC / Chamado  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ademar Jr.  ³21/07/11³00000017542/2011³-Localizacao Colombia-Criado a carga da Ta-³±±
±±³            ³        ³Chamado TDITZ9  ³ bela Auxiliar S030.                       ³±±
±±³L.Trombini  ³17/08/11³00000019483/2011³-Localizacao Argentina - Retirada pesquisa ³±±
±±³            ³        ³Chamado TDNFFT  ³ da tabela Auxiliar S016, pois estava      ³±±
±±³            ³        ³				 ³ realizando a pesquisa na propria tabela.  ³±±
±±³Luis Ricardo³04/10/11³00000015522/2011³Ajuste na carga das tabelas do Brasil para ³±±
±±³Cinalli     ³		³				 ³preencher a Filial da Tabela em Branco.    ³±±
±±³Ademar Jr.  ³05/10/11³00000017679/2011³-COL-Implementado na carga da Tabela S030  ³±±
±±³            ³        ³Chamado TDHI34  ³    os itens 005S, 006S e 007S.            ³±±
±±³Ademar Jr.  ³14/11/11³00000028373/2011³-AUS-Implementado carga das Tabelas S006 e ³±±
±±³            ³        ³Chamado TDYEKN  ³     S013.                                 ³±±
±±³Laura Medina³19/12/13³                ³Se crearon tablas Alfanuméricas  en la	 ³±±
±±³            ³        ³                ³funcion Gp310TABMEX						 ³±±
±±³Laura Medina|04/03/14|TIGYIB          |Actualizacion conceptos S031  Mexico       ³±±
±±³            ³        ³                ³- MEX-Actualizacion de la tabla S027- Tipo ³±±
±±³            ³        ³TIJIB8          ³      Regimen SAT.                         ³±±
±±³Alf. Medrano³07/09/16³                ³Merge V 12.1.13                            ³±±
±±³            ³        ³                ³se actualiza Gp310TABCOL COLOMBIA          ³±±
±±³LuisEnriquez³22/06/17³    MMI-5054    ³Merge main .En función Gp310TABMEX se rea- ³±±
±±³            ³        ³                ³lizaron ade cuaciones en estructura y lle- ³±±
±±³            ³        ³                ³nado de tablas auxiliares S027 a S037.(MEX)³±±
±±³Jonathan glz³16/08/17³DMINA-221       ³Replica 12.1.17 Se agrega creación de tabla³±±
±±³            ³        ³ReplicaDMINA-219³S031 con actualizacion de conceptos 024D a ³±±
±±³            ³        ³                ³100D. (MEX)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GpTABCRG()

	If cPaisLoc == "PTG"
		Gp310TABPTG()
	ElseIf cPaisLoc == "ANG"
		Gp310TABANG()
	ElseIf cPaisLoc == "ARG"
		Gp310TABARG()
	ElseIf cPaisLoc == "COL"
//		Gp310TABCOL() // tomara la informacion del GPCRGCOL
	ElseIf cPaisLoc == "VEN"
		Gp310TABVEN()
	ElseIf cPaisLoc == "MEX"
		Processa( {|lEnd| Gp310TABMEX(@lEnd)}, "Espere...", "Cargando tablas...", .T. )
	ElseIf cPaisLoc == "PER"
		Processa( {|lEnd| Gp310TABPER(), "Cargamento de Tablas... Aguarde!" })
	ElseIf cPaisLoc == "EQU"
		Processa( {|lEnd| Gp310TabEQU(), "Cargamento de Tablas... Aguarde!" })
	ElseIf cPaisLoc == "BRA"
		Processa( {|lEnd| Gp310TABBRA(), "Carregamento de Tabelas... Aguarde!" })
	ElseIf cPaisLoc == "AUS"
		Processa( {|lEnd| Gp310TabAUS(), "Load Tables ... Wait!" })
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABPTGºAutor³ Kelly Soares       º Data ³  30/06/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabelas auxiliares padroes.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PORTUGAL                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rogerio     ³14/08/08³151449³Alteracao da GP310PTG p/preencher tabelas ³±±
±±³Melonio     ³        ³151451³padroes de Portugal-Relatorios Anuais.    ³±±
±±³            ³        ³151453³Quadro de Pessoal/Balanco Anual/Mod.10 IRS³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp310TABPTG()

Local aTabela  := {}
Local cFilRCC  := xFilial("RCC")
Local cFilRCB  := xFilial("RCB")
Local cNomeArq :=	""
Local nI		:=	0

DbSelectArea("RCB")
DbSetOrder(3)
lAchou := dbSeek(cFilRCB+'DESCRICAO '+'S011')
If lAchou .And. RCB_TAMAN <= 50
	RecLock("RCB",.F.)
	RCB->RCB_TAMAN := 90
	MsUnLock("RCB")
EndIf

DbSetOrder(1)
If !dbSeek(cFilRCB+'S011')

	cNomeArq := 'S011'
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','01','CODIGO'   ,'CODIGO'      ,'C', 2,0,'@!'      ,'NAOVAZIO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','02','DESCRICAO','DESCRICAO'   ,'C',90,0,'@!'      ,'NAOVAZIO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','03','DIASCONTR','VIG.CONTRATO','N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','04','MINDCONTR','MINIMO  DIAS','N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','05','MAXDCONTR','MAXIMO DIAS' ,'N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','06','QTDRENOV' ,'RENOVACOES'  ,'N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','07','PRAZOMIN' ,'PRAZO MINIMO','N', 4,0,'@E 9,999','POSITIVO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','08','PRAZOMAX' ,'PRAZO MAXIMO','N', 4,0,'@E 9,999','POSITIVO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','09','TIPO_QDP' ,'QDR. PESSOAL','C', 1,0,'@!','VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))' ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','10','TIPO_BSO' ,'BAL. SOCIAL' ,'C', 1,0,'@!','VAZIO() .OR. If(PERTENCE("123"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'       ,'','001'} )
	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Else
	DbSelectArea("RCB")
	DbSetOrder(3)
	If dbSeek(cFilRCB+'TIPO_QDP')
		If Alltrim(RCB->RCB_CODIGO)=='S011' .And. Alltrim(RCB->RCB_VALID) <> 'VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))'
			RecLock('RCB',.F.)
            RCB->RCB_VALID:='VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))'
           	MsUnlock()
	    Endif
	Endif
	If dbSeek(cFilRCB+'TIPO_BSO')
		If Alltrim(RCB->RCB_CODIGO)=='S011' .And. Alltrim(RCB->RCB_VALID) <> 'VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'
			RecLock('RCB',.F.)
            RCB->RCB_VALID:='VAZIO() .OR. If(PERTENCE("123"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'
           	MsUnlock()
	    Endif
	Endif
Endif

DbSelectArea("RCC")
DbSetOrder(1)	//-RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN
lAchou := dbSeek(cFilRCC+'S011')
If lAchou .And. SubStr(RCC_CONTEU,1,2)=="01"
	While !Eof() .And. RCC_FILIAL+RCC_CODIGO==cFilRCC+'S011'
		RecLock("RCC",.F.)
		dbDelete()
		MsUnLock("RCC")
		dbSkip()
	EndDo
	lAchou := .F.
EndIf
If !lAchou
	aTabela	:=	{}
	cNomeArq := 'S011'
																//           1         2         3         4         5         6         7         8         9
																//12123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123412341234123412341234
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','10CONTRATO DE TRABALHO SEM TERMO                                                               0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','11CONTRATO DE TRABALHO PARA PRESTACAO SUBORDINADA DE TELETRABALHO SEM TERMO                    0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','12CONTRATO DE TRABALHO EM COMISSAO DE SERVICO SEM TERMO                                        0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','13CONTRATO DE TRABALHO INTERMITENTE SEM TERMO                                                  0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','14CONTRATO DE TRABALHO POR TEMPO INDETERMINADO PARA CEDENCIA TEMPORARIA                        0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','20CONTRATO DE TRABALHO COM TERMO CERTO                                                         0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','21CONTRATO DE TRABALHO PARA PRESTACAO SUBORDINADA DE TELETRABALHO COM TERMO CERTO              0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','22CONTRATO DE TRABALHO EM COMISSAO DE SERVICO COM TERMO CERTO                                  0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','23CONTRATO DE TRABALHO TEMPORARIO COM TERMO CERTO                                              0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','30CONTRATO DE TRABALHO COM TERMO INCERTO                                                       0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','31CONTRATO DE TRABALHO PARA PRESTACAO SUBORDINADA DE TELETRABALHO COM TERMO INCERTO            0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','32CONTRATO DE TRABALHO EM COMISSAO DE SERVICO COM TERMO INCERTO                                0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','33CONTRATO DE TRABALHO TEMPORARIO COM TERMO INCERTO                                            0   0   0   0   0   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','80OUTRA SITUACAO                                                                               0   0   0   0   0   0'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S013')
	cNomeArq := 'S013'
	aTabela	:=	{}
	aAdd( aTabela, { cFilRCB,cNomeArq,'NIVEIS QUALIFICACAO','01','CODIGO'   ,'CODIGO'   ,'C', 1,0,'@!','NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'NIVEIS QUALIFICACAO','02','DESCRICAO','DESCRICAO','C',50,0,'@!','NAOVAZIO()','','001'} )
	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S013')
	aTabela	:=	{}
	cNomeArq := 'S013'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','1PRATICANTES / APRENDIZES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','2PROFISSIONAIS NAO QUALIFICADOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','3PROFISSIONAIS SEMI-QUALIFICADOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','4PROFISSIONAIS ALTAMENTE QUALIFICADOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','5QUADROS INTERMEDIO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','6QUADROS MEDIOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','7QUADROS SUPERIORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','8DIRIGENTES'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S021')
	aTabela := {}
	cNomeArq := 'S021'
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','01','CODIGO'		,'CODIGO'		,'C',2	,0,'@!','NAOVAZIO()'	,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','02','DESCRICAO'	,'DESCRICAO'	,'C',100,0,'@!','NAOVAZIO()'	,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','03','DIUTURNI'	,'DIUTURNIDADE'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','04','SUBALIMEN'	,'SUB.ALIMENT.'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','05','SUBFERIAS'	,'SUB.FER.PROP'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','06','SUBNATAL'	,'SUB.NAT.PROP'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','07','INDEMNIZ'	,'INDEMNIZACAO'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE RESCISAO','08','AVISOPREV'	,'AVISO PREVIO'	,'C',1	,0,'@!','PERTENCE("SN")','','001'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S021')
	aTabela	:=	{}
	cNomeArq := 'S021'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01CADUCIDADE POR TERMO DO CONTRATO A TERMO CERTO - ARTIGO 388                                         SSSS01N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02CADUCIDADE POR TERMO DO CONTRATO A TERMO INCERTO - ARTIGO 389                                       SSSS01N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03CADUCIDADE DO CONTRATO POR MORTE DO EMPREGADOR E EXTINCAO OU ENCERRAMENTO DA EMPRESA - ARTIGO 390   SSSS02N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04CADUCIDADE DO CONTRATO POR INSOLVENCIA E RECUPERACAO DA EMPRESA - ARTIGO 391                        SSSS04N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05CADUCIDADE COM A REFORMA DO TRABALHADOR POR VELHICE - ARTIGO 392                                    SSSS  N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06INICIATIVA DO EMPREGADOR COM JUSTA CAUSA SUBJECTIVA DE DESPEDIMENTO - ARTIGO 396                    SSSS  N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07INICIATIVA DO EMPREGADOR COM JUSTA CAUSA OBJECTIVA DE DESPEDIMENTO ( COLETIVO ) - ARTIGO 397        SSSS01S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08DESPEDIMENTO POR EXTINCAO DO POSTO DE TRABALHO - ARTIGO 402                                         SSSS06S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','09DESPEDIMENTO POR INADAPTACAO DO TRABALHADOR - ARTIGO 405                                            SSSS07S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','10INICIATIVA DO TRABALHADOR COM JUSTA CAUSA DE RESOLUCAO - ARTIGO 441                                 SSSS  N'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','11POR DENUNCIA - ARTIGO 447                                                                           SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','12MUTUO ACORDO                                                                                        SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','13REFORMA POR INVALIDEZ                                                                               SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','14REFORMA ANTECIPADA                                                                                  SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','15PRE-REFORMA                                                                                         SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','16FALECIMENTO                                                                                         SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','17ANTECIPACAO DA CESSACAO A TERMO CERTO                                                               SSSS  S'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','18ANTECIPACAO DA CESSACAO A TERMO INCERTO                                                             SSSS  S'})


	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)

		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S023')
	aTabela	:=	{}
	cNomeArq := 'S023'
	aAdd( aTabela, {cFilRCB,cNomeArq,'REMUNERACAO DO QUADRO DE PESSOAL','01','CODIGO'   ,'CODIGO'   ,'C',2,0,'@!','NAOVAZIO()','','001'} )
	aAdd( aTabela, {cFilRCB,cNomeArq,'REMUNERACAO DO QUADRO DE PESSOAL','02','DESCRICAO','DESCRICAO','C',40,0,'@!','NAOVAZIO()','','001'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S023')
	aTabela	:=	{}
	cNomeArq := 'S023'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','01','01SALARIO BASE'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','02','02TRABALHO SUPLEMENTAR'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','03','03PREMIOS E SUBSIDIOS REGULARES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','04','04PRESTACOES IRREGULARES'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S024')
	aTabela	:=	{}
	cNomeArq := 'S024'

	aAdd( aTabela, {cFilRCB,cNomeArq,'PAISES','01','CODIGO'   ,'CODIGO'     ,'C',2,0,'@!','NAOVAZIO()','','002'} )
	aAdd( aTabela, {cFilRCB,cNomeArq,'PAISES','02','DESCRICAO','DESCRICAO'  ,'C',30,0,'@!','NAOVAZIO()','','002'} )
	aAdd( aTabela, {cFilRCB,cNomeArq,'PAISES','03','TPNACION' ,'TIPO NACION','C',2,0,'@!','NAOVAZIO()','S25','002'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If dbSeek(cFilRCC+'S024')
	If Substr(RCC->RCC_CONTEU, 1, 2) == '01'
	    While RCC->(!Eof()) .And. RCC_CODIGO == 'S024'
			RecLock("RCC",.F.,.T.)
			dbDelete( )
	    	MsUnlock()
	    	RCC->(DBSKIP())
		End
	Endif
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S024')
	aTabela	:=	{}
	cNomeArq := 'S024'

	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','ADAndorra                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','AEEmiratos Árabes Unidos        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','AFAfeganistão                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','AGAntígua e Barbuda             04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','AIAnguila                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','ALAlbânia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','AMArménia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','ANAntilhas Holandesas           04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','AOANGOLA                        02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','AQAntárctica                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','ARArgentina                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','ASSamoa Americana               04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','ATÁUSTRIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','AUAustrália                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','AWAruba                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','AXIlhas Aland                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','AZAzerbaijão                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','BABósnia-Herzegovina            04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','019','BBBarbados                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','020','BDBangladesh                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','021','BEBÉLGICA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','022','BFBurkina Faso                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','023','BGBULGÁRIA                      01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','024','BHBarém                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','025','BIBurundi                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','026','BJBenim                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','027','BLSão Bartolomeu                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','028','BMBermudas                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','029','BNBrunei Darussalam             04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','030','BOBolívia (Est.Plurinac.)       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','031','BRBRASIL                        03'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','032','BSBahamas	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','033','BTButão                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','034','BVIlha Bouvet                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','035','BWBotswana                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','036','BYBielorrússia                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','037','BZBelize                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','038','CACanadá                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','039','CCIlhas Cocos (Keeling)         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','040','CDCongo (Rep.Democrática)       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','041','CFCentro-Africana (República)   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','042','CGCongo                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','043','CHSuiça                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','044','CICosta do Marfim               04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','045','CKIlhas Cook                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','046','CLChile                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','047','CMCamarões                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','048','CNChina                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','049','COColômbia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','050','CRCosta Rica                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','051','CUCuba                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','052','CVCABO VERDE                    02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','053','CXIlha Christmas                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','054','CYCHIPRE                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','055','CZREPUBLICA CHECA               01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','056','DEALEMANHA                      01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','057','DJJibuti                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','058','DKDINAMARCA                     01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','059','DMDomínica                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','060','DORepública Dominicana          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','061','DZArgélia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','062','ECEquador                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','063','EEESTONIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','064','EGEgipto                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','065','EHSara Ocidental                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','066','EREritreia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','067','ESESPANHA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','068','ETEtiópia	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','069','FIFINLANDIA                     01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','070','FJIlhas Fiji                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','071','FKIlhas Falkland (Malvinas)     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','072','FMMicronésia (Estados Federados)04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','073','FOIlhas Faroé                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','074','FRFRANCA                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','075','GAGabão                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','076','GBREINO UNIDO                   01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','077','GDGranada	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','078','GEGeórgia	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','079','GFGuiana Francesa               04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','080','GGGuernsey                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','081','GHGana                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','082','GIGibraltar                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','083','GLGronelândia                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','084','GMGâmbia                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','085','GNGuiné                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','086','GPGuadalupe                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','087','GQGuiné Equatorial              04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','088','GRGRECIA                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','089','GSGeórgia do Sul                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','090','GTGuatemala                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','091','GUGuam                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','092','GWGUINE-BISSAU                  02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','093','GYGuiana                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','094','HKHong Kong                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','095','HMIlha Heard/Ilhas Mcdonald     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','096','HNHonduras                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','097','HRCroácia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','098','HTHaiti                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','099','HUHUNGRIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','100','IDIndonésia                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','101','IEIRLANDA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','102','ILIsrael                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','103','IMIlha de Man                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','104','INÍndia                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','105','IOTer. Britânico Oc. Índico     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','106','IQIraque                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','107','IRIrão (República Islâmica)     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','108','ISIslândia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','109','ITITALIA                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','110','JEJersey                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','111','JMJamaica                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','112','JOJordânia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','113','JPJAPAO                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','114','KEQuénia                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','115','KGQuirguizistão                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','116','KHCamboja	                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','117','KIKiribati                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','118','KMComores                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','119','KNSão Cristóvão e Nevis         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','120','KPCoreia (Rep.Popular Democr.)  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','121','KRCoreia (República da)         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','122','KWKuwait                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','123','KYIlhas Caimão                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','124','KZCazaquistão                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','125','LALaos (Rep.Popular Democr.)    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','126','LBLíbano                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','127','LCSanta Lúcia                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','128','LILiechtenstein                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','129','LKSri Lanka                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','130','LRLibéria                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','131','LSLesoto                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','132','LTLITUANIA                      01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','133','LULUXEMBURGO                    01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','134','LVLETONIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','135','LYLíbia (Jamahiriya Árabe)      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','136','MAMarrocos                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','137','MCMónaco                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','138','MDMoldova (República de)        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','139','MEMontenegro                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','140','MFSão Martinho                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','141','MGMadagáscar                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','142','MHIlhas Marshall                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','143','MKMacedónia                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','144','MLMali                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','145','MMMyanmar                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','146','MNMongólia                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','147','MOMacau                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','148','MPIlhas Marianas do Norte       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','149','MQMartinica                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','150','MRMauritânia                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','151','MSMonserrate                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','152','MTMalta                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','153','MUMaurícias                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','154','MVMaldivas                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','155','MWMalawi                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','156','MXMéxico                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','157','MYMalásia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','158','MZMOCAMBIQUE                    02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','159','NANamíbia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','160','NCNova Caledónia                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','161','NENiger                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','162','NFIlha Norfolk                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','163','NGNigéria                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','164','NINicarágua                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','165','NLPaíses Baixos                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','166','NONoruega                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','167','NPNepal                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','168','NRNauru                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','169','NUNiue                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','170','NZNova Zelândia                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','171','OMOmã                           04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','172','PAPanamá                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','173','PEPeru                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','174','PFPolinésia Francesa            04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','175','PGPapuásia-Nova Guiné           04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','176','PHFilipinas                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','177','PKPaquistão                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','178','PLPOLONIA                       01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','179','PMSão Pedro e Miquelon          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','180','PNPitcairn                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','181','PRPorto Rico                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','182','PSTerritório Palestiniano Ocup. 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','183','PTPORTUGAL                      01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','184','PWPalau                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','185','PYParaguai                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','186','QACatar                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','187','REReunião                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','188','ROROMENIA                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','189','RSSérvia                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','190','RURUSSIA                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','191','RWRuanda                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','192','SAArábia Saudita                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','193','SBIlhas Salomão                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','194','SCSeychelles                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','195','SDSudão                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','196','SESUECIA                        01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','197','SGSingapura                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','198','SHSanta Helena                  04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','199','SIESLOVENIA                     01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','200','SJSvalbard e Ilha Jan Mayen     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','201','SKESLOVÁQUIA                    01'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','202','SLSerra Leoa                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','203','SMSão Marino                    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','204','SNSenegal                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','205','SOSomália                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','206','SRSuriname                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','207','STSAO TOME E PRINCIPE           02'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','208','SVEl Salvador                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','209','SYSíria (República Árabe da)    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','210','SZSuazilândia                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','211','TCIlhas Turcas e Caicos         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','212','TDChade                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','213','TFTerritório Franceses do Sul   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','214','TGTogo                          04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','215','THTailândia                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','216','TJTajiquistão                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','217','TKTokelau                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','218','TLTimor Leste                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','219','TMTurquemenistão                04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','220','TNTunísia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','221','TOTonga                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','222','TRTurquia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','223','TTTrindade e Tobago             04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','224','TVTuvalu                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','225','TWTaiwan (Província da China)   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','226','TZTanzânia (República Unida)    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','227','UAUcrânia                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','228','UGUganda                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','229','UMIlhas Menores Distantes EUA   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','230','USESTADOS UNIDOS AMERICA(EUA)   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','231','UYUruguai                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','232','UZUsbequistão                   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','233','VASanta Sé (Cid.Est.Vaticano)   04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','234','VCSão Vicente e Granadinas      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','235','VEVenezuela                     04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','236','VGIlhas Virgens (Britânicas)    04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','237','VIIlhas Virgens (EUA)           04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','238','VNVietname                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','239','VUVanuatu                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','240','WFWallis e Futuna (Ilhas)       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','241','WSSamoa                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','242','YEIémen                         04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','243','YTMayotte                       04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','244','ZAÁfrica do Sul                 04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','245','ZMZâmbia                        04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','246','ZWZimbabwe                      04'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','247','APApátrida                      04'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S025')
	aTabela	:=	{}
	cNomeArq := 'S025'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPO NACIONALIDADE','01','TPNAC '     ,'TP NACIONAL.'  ,'C',2,0,'@!','NAOVAZIO()'    ,'','001'} )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPO NACIONALIDADE','02','DESNAC'     ,'DESC.NACION.'  ,'C',30,0,'@!','NAOVAZIO()'    ,'','001'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S025')
	aTabela	:=	{}
	cNomeArq := 'S025'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01PAISES DA UNIAO EUROPEIA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02PAISES AFRICANOS DE LINGUA OFICIAL'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03BRASIL'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04OUTROS PAISES'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S026')
	aTabela	:=	{}
	cNomeArq := 'S026'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPO RENDIMENTO IRS','001','CODIGO'   ,'CODIGO'   ,'C',003,0,'@!','NAOVAZIO()','',''} )
   	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPO RENDIMENTO IRS','002','DESCRICAO','DESCRICAO','C',100,0,'@!','NAOVAZIO()','',''} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S026')
	aTabela	:=	{}
	cNomeArq := 'S026'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','A  TRABALHO DEPENDENTE'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','B  RENDIMENTOS EMPRESARIAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','E  OUTROS RENDIMENTOS DE CAPITAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','EE SALDOS CREDORES C/C (ARTIGO 12)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','F  PREDIAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','G  INCREMENTOS PATRIMONIAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','H  PENSOES'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S027')
	aTabela	:=	{}
	cNomeArq := 'S027'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'CLASSIFICACAO IRS','01','CODIGO'   ,'CODIGO'   ,'C',002,0,'@!','NAOVAZIO()','',''} )
   	aAdd( aTabela, {cFilRCB,cNomeArq,'CLASSIFICACAO IRS','02','DESCRICAO','DESCRICAO','C',120,0,'@!','NAOVAZIO()','',''} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S027')
	aTabela	:=	{}
	cNomeArq := 'S027'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','1 RENDIMENTO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','2 RETENCOES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','3 DESCONTOS OBRIGATORIOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','4 QUOTIZACOES SINDICAIS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','5 REMUNERACOES NAO SUJEITAS A IRS'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S028')
	aTabela	:=	{}
	cNomeArq := 'S028'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'FORMACAO ESCOLAR','01','CODIGO ','CODIGO'  	,'C',  3,0,'@!','NAOVAZIO()','',''} )
   	aAdd( aTabela, {cFilRCB,cNomeArq,'FORMACAO ESCOLAR','02','DESCRICAO','DESCRICAO','C',60,0,'@!','NAOVAZIO()','',''} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S028')
	aTabela	:=	{}
	cNomeArq := 'S028'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','111Nao sabe ler nem escrever'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','112Sabe ler e escrever sem possuir o 1o. Ciclo do Ensino Basico'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2111o. Ciclo do Ensino Basico (Ensino Primario 4a. classe)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2121o. Ciclo do Ensino Basico com cursos de Indole Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2212o. Ciclo do Ensino Basico (Ensino Preparatorio, Telescola ou antigo 2o. ano do Liceu)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2222o. Ciclo do Ensino Basico com cursos de Indole Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2313o. Ciclo do Ensino Basico (antigo 5o. ano do Liceu, ou 9o. ano unificado)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','232Ensino Tecnico: Curso Geral Comercial'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','2333o. Ciclo do Ensino Basico com cursos de Indole Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','234Cursos das Escolas Profissionais - Nivel II'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','311Ensino Secundario (12o. ano) ou equivalente com cursos de Indole Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','312Ensino Secundario Tecnico Complementar'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','313Ensino Secundario Tecnico-Profissional'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','314Cursos das Escolas Profissionais - Nivel III'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','414Formacao de professores/formadores e ciencias da educacao'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','421Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','422Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','431Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','432Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','434Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','438Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','442Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','444Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','446Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','452Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','454Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','458Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','462Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','464Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','472Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','476Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','481Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','484Servicos de transporte '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','485Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','486Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','499Desconhecido ou nao especificado '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','514Formacao de professores/formadores e ciencias da educacao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','521Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','522Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','531Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','532Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','534Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','538Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','542Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','544Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','546Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','552Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','554Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','558Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','562Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','564Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','572Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','576Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','581Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','584Servicos de transporte'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','585Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','586Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','599Desconhecido ou nao especificado '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','614Formacao de professores/formadores e ciencias da educacao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','621Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','622Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','631Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','632Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','634Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','638Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','642Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','644Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','646Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','652Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','654Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','658Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','662Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','664Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','672Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','676Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','681Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','684Servicos de transporte'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','685Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','686Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','699Desconhecido ou nao especificado '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','714Formacao de professores/formadores e ciencias da educacao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','721Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','722Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','731Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','732Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','734Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','738Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','742Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','744Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','746Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','752Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','754Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','758Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','762Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','764Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','772Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','776Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','781Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','784Servicos de transporte'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','785Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','786Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','799Desconhecido ou nao especificado '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','814Formacao de professores/formadores e ciencias da educacao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','821Artes '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','822Humanidades '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','831Ciencias sociais e do comportamento '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','832Informacao e jornalismo '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','834Ciencias empresariais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','838Direito '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','842Ciencias da vida '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','844Ciencias fisicas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','846Matematica e estatistica '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','852Engenharia e tecnicas afins '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','854Industrias transformadoras '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','858Arquitectura e construcao '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','862Agricultura, silvicultura e pescas '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','864Ciencias veterinarias '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','872Saude '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','876Servicos sociais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','881Servicos pessoais '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','884Servicos de transporte'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','885Proteccao do ambiente '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','886Servicos de seguranca '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','899Desconhecido ou nao especificado '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With StrZero(nI,3) // aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S029')
	aTabela	:=	{}
	cNomeArq := 'S029'
   	aAdd( aTabela, {cFilRCB,cNomeArq,'PROFISSOES','01','CODIGO'   ,'CODIGO'   ,'C', 3,0,'@!','NAOVAZIO()','',''} )
   	aAdd( aTabela, {cFilRCB,cNomeArq,'PROFISSOES','02','DESCRICAO','DESCRICAO','C',60,0,'@!','NAOVAZIO()','',''} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S033')
	aTabela	:=	{}
	cNomeArq := 'S033'

	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','01','CODINDE'  ,'CODIGO INDEMNIZACAO'      ,'C',2 ,0,'@!'           ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','02','DESCRICAO','DESCRICAO'                ,'C',60,0,'@!'           ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','03','DIASRETRI','DIAS RETRIBUICAO(DIAS)'   ,'N',6 ,2,'@E 999.99'    ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','04','ANTIGSUP' ,'ANTIGUIDADE SUPERIOR(MES)','N',4 ,0,'9999'         ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','05','ANTIGSUPA','ANTIGUIDADE SUPERIOR(ANO)','N',4 ,0,'9999'         ,'','','' } )
	aAdd( aTabela, {cFilRCB,cNomeArq,'TIPOS DE INDEMNIZACAO','06','MINIMOPAG','MINIMO A PAGAR'           ,'N',9 ,2,'@E 999,999.99','','','' } )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S033')
	aTabela	:=	{}
	cNomeArq := 'S033'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01CADUCIDADE DE CONTRATO A TERMO CERTO                          0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02POR MORTE DO EMPREGADOR                                       0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03EXTINCAO DA PESSOA COLECTIVA                                  0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04ENCERRAMENTO DA EMPRESA                                       0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05DESPEDIMENTO COLECTIVO                                        0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06EXTINCAO DE POSTO DE TRABALHO                                 0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07DESPEDIMENTO POR INADAPTACAO                                  0.00   0   0     0.00'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08RESOLUCAO PELO TRABALHADOR                                    0.00   0   0     0.00'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With StrZero(nI,3) // aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABANGºAutor³ Tiago Malta        º Data ³  29/07/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Angola                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp310TABANG()

Local aTabela  := {}
Local cFilRCC  := xFilial("RCC")
Local cFilRCB  := xFilial("RCB")
Local cNomeArq :=	"S001"
Local nI		:=	0

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+cNomeArq)
	aTabela	:=	{}
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01BENGO                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02BENGUELA                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03BIE                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04CABINGA                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05CUANDO-CUBANGO                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06KWANZA-NORTE                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07KWANZA-SUL                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08CUNENE                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','09HUAMBO                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','10HUILA                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','11LUANDA                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','12LUNDA-NORTE                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','13LUNDA-SUL                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','14MALANJE                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','15MOXICO                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','16NAMIBE                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','17UIGE                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','18ZAIRE                         '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABARGºAutor³ Kelly Soares       º Data ³  16/07/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabelas auxiliares padroes.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ARGENTINA                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TABARG()

Local aTabela  := {}
Local cFilRCC  := xFilial("RCC")
Local cFilRCB  := xFilial("RCB")
Local cNomeArq :=	""
Local nI		:=	0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S011										                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S011')

	cNomeArq := 'S011'
	aAdd( aTabela, { cFilRCB,cNomeArq,'ESCALA DE VACACIONES','01','CODVAC'		,'CODIGO'		,'C' ,2 ,0 ,'@!'	,'NAOVAZIO()'	,'' ,'001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'ESCALA DE VACACIONES','02','DESCRIC'		,'DESCRIPCION'	,'C' ,20,0 ,'@!'	,''				,'' ,'001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'ESCALA DE VACACIONES','03','ANOATE'		,'ANO ATE'		,'N' ,2 ,0 ,'99'	,'POSITIVO()'	,'' ,'001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'ESCALA DE VACACIONES','04','DIASVAC'		,'DIAS VACAC'	,'N' ,3 ,0 ,'999'	,'POSITIVO()'	,'' ,'001'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S011')

	aTabela	:=	{}
	cNomeArq := 'S011'

	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01ESCALA LCT           5 14'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','01ESCALA LCT          10 21'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','01ESCALA LCT          20 28'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','01ESCALA LCT          99 35'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S030										                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S030')
	aTabela	:=	{}
	cNomeArq := 'S030'
	aAdd( aTabela, { cFilRCB,cNomeArq,'AFIP IMPUESTO A LAS GANANCIAS','01','CODIGO'		,'CODIGO'		,'C' ,3 ,0 ,'@!'	,'NAOVAZIO()'	,'' ,'001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'AFIP IMPUESTO A LAS GANANCIAS','02','DESCRIC'	,'DESCRIPCION'	,'C' ,65,0 ,'@!'	,'NAOVAZIO()'	,'' ,'001'} )

	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S030')
	aTabela	:=	{}
	cNomeArq := 'S030'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','019LIQUIDADAS POR LA ENTIDAD QUE ACTÚA COMO AGENTE DE RETNCIÓN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','027APELIDOS Y NOMBRES O DENOMINACION Y DOMICILIO              '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','035APELIDOS Y NOMBRES O DENOMINACION Y DOMICILIO              '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','043APELIDOS Y NOMBRES O DENOMINACION Y DOMICILIO              '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','078APELIDOS Y NOMBRES O DENOMINACION Y DOMICILIO              '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','094TOTALES DEL RUBRO 1 										   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','116APORTES JUBILATORIOS								           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','124APORTES PARA OBRAS SOCIALES Y COTAS MÉDICO ASISTENCIALES(TOTAL DEL RUBRO 11)'})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','132PRIMAS DE SEGURO PARA EL CASO DE MUERTE (TOTAL DEL RUBRO 12)                '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','140GASTOS DE SEPELIO (TOTAL DEL RUBRO 13)                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','159GASTOS ESTIMATIVOS DE CORREDORES Y VIAJANTES DE COMERCIO (MOVILIDAD, ETC.   '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','167OTRAS DEDUCCIONES(TOTAL DEL RUBRO 15)                      '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','175TOTAL DEL RUBRO 2 (SUMA DE LOS INCISOS A) AL F   		   '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','183RESULTADO NETO(DIFERENCIA ENTRE EL RUBRO 1 Y RUBRO 2)      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','191DONACIONES(HASTA EL LÍMITE DEL 5% DEL RUBRO 3) 			   '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','205DIFERENCIA(RUBRO 3 MENOS RUBRO 4)						   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','213DEDUCCION ESPECIAL										   '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','221GANANCIA NO IMPONIBLE							           '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','019','256CÓNYUGE                                                    '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','020','264HIJOS													   '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','021','272OTRAS CARGAS                                               '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','022','302TOTALES DEL RUBRO 6(SUMA DE LOS INCISOS A) B) Y C))        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','023','310GANACIAS NETAS SUJEITAS A IMPUESTO(DIFERENCIA ENTRE EL RUBRO 5 Y 6)         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','024','329TOTAL DEL IMPUESTO DETERMINADO							   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','025','345RETENCIONES EFECTUADAS EN EL PERIODO FISCAL QUE SE LIQUIDA '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','026','353REGÍMENES DE PROMOCÍON(REBAJA DE IMPUESTO, DIFERIMENTO U OUTROS)            '})
//  AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','027','361TOTALES DEL RUBRO 9(SUMA DE LOS INCISOS A) Y B))           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','028','388A FAVOR D.G.I.                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','029','393A FAVOR BENEFICIARIO                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','030','418a) CUOTAS MEDICO ASISTENCIALES                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','031','426b) CUOTAS MEDICO ASISTENCIALES                             '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','032','434TOTAL DEL RUBRO 11                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','033','507a) PRIMAS DE SEGURO                                        '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','034','515TOTAL DEL RUBRO 12                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','035','604a) GASTOS DE SEPELIO                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','036','612b) GASTOS DE SEPELIO                                       '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','037','620TOTAL DEL RUBRO 13                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','038','701a) DONACIONES                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','039','728b) DONACIONES                                              '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','040','736TOTAL DEL RUBRO 14                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','041','809a) OTRAS DEDUCIONES                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','042','817b) OTRAS DEDUCIONES                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','043','825c) OTRAS DEDUCIONES                                        '})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','044','833TOTAL DEL RUBRO 15(SUMA DE LOS INC. A) B)Y C)              '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AJUSTE NA TABELA S016 - RCB	 - RETIRADA DA PESQUISA 	    								                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "ARG"
	dbSelectArea("RCB")
	dbSetOrder(1)
	If RCB->( dbSeek(cFilRCB+"S016") )
		While RCB->( !Eof() ) .And.(RCB->RCB_FILIAL+RCB->RCB_CODIGO) == cFilRCB+"S016"
		   If RCB->RCB_ORDEM == "01" .and. RCB->RCB_PADRAO <> "      "
		      	RecLock("RCB",.F.)
		     	Replace RCB_PADRAO With "      "
				Replace RCB_PESQ   With "2"
		     	RCB->( MsUnlock() )
		    EndIf
			RCB->( dbSkip()   )
		EndDo
	EndIf
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABCOLºAutor³ Abel Ribeiro       º Data ³  20/11/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabelas auxiliares padroes.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Colombia                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Abel RIbeiro³20/11/08³006123³Criado GP310TABCOL p/preencher tabelas    ³±±
±±³            ³        ³      ³padroes de Colombia, Contratos.           ³±±
±±³Alfredo Med.³30/09/13³239604³Crear tablas alfanuméricas S009,S027,S030 ³±±
±±³            ³        ³      ³S031,S032,S033,S034,S037. excluir S022 y  ³±±
±±³            ³        ³      ³S023									       ³±±
±±³Alfredo Med.³28/11/13³239604³Borra y Regenera tablas alfanuméricas     ³±±
±±³            ³        ³      ³S009,S027,S030,S031,S032,S033,S034,S037.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TABCOL()

Local aTabela	:= {}
Local cFilRCC	:= xFilial("RCC")
Local cNomeArq	:=	""
Local nI		:=	0
Local nIni 		:= 0
Local cStr		:= ""

DbSelectArea("RCC")
DbSetOrder(1)

// Se comentan las líneas que crean las tablas S022 y S023
// como requisito de la especificación COL11.8_RH_239604
/*
If !dbSeek(cFilRCC+'S022')
	aTabela	:=	{}
	cNomeArq := 'S022'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','01TERMINO FIJO 1 AÑO                                 365   1 365   3'})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','02TERMINO FIJO 1 A 3 AÑOS                           1095 3651095 999'})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','003','03TERMINO INDEFINIDO                                  60   1  60   0'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

If !dbSeek(cFilRCC+'S023')
	aTabela	:=	{}
	cNomeArq := 'S023'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','001 NECESIDAD DE CONTINUACÍON'})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','002 NUEVAS ESTRATEGIAS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','003','003 NECESIDAD DE MANO DE OBRA'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif
*/

// borra la información estandar de la tabla S009
If dbSeek(cFilRCC+'S009')
	nIni:=1
	While !Eof() .And. (RCC_FILIAL+RCC_CODIGO == cFilRCC+'S009') .and. nIni <=20
		cStr := Strzero(nIni,3)
		If Alltrim(RCC_SEQUEN) == cStr
			RecLock('RCC',.F.)
			dbDelete()
			RCC->(MsUnLock())
		EndIf
		nIni++
		dbSkip()
	EndDo
EndIf

// crea la tabla S009 Tipos de Entidad
	aTabela	:=	{}
	cNomeArq := 'S009'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','01EPS' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','02ARL' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','003','03AFP' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','004','04AFC' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','005','05Cesantía' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','006','06CCF' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','007','07SENA' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','008','08ICBF' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','009','09ESAP' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','010','10MAN' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','011','11DIAN' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','012','12Sindicato' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','013','13Embargo Alimentos' })
    AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','014','14Embargo Cooperativas' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','015','15Embargos Ejecutivos' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','016','16Medicina Pre-pagada' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','017','17Ticket Alimentos' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','018','18Ticket Gasolina' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','019','19Seguro de Vida' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','020','20Otro tipo' })

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI


// borra la información estandar de la tabla S027
If dbSeek(cFilRCC+'S027')
	nIni:=1
	While !Eof() .And. (RCC_FILIAL+RCC_CODIGO == cFilRCC+'S027') .and. nIni <=15
		cStr := Strzero(nIni,3)
		If Alltrim(RCC_SEQUEN) == cStr
			RecLock('RCC',.F.)
			dbDelete()
			RCC->(MsUnLock())
		EndIf
		nIni++
		dbSkip()
	EndDo
EndIf

// Preenche tabela S027 tipos de Retencao
	aTabela	:=	{}
	cNomeArq := 'S027'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','A Salarios ' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','B Cesantias e intereses de cesantias efectivamente pagadas en el periodo' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','003','C Gastos de Representacion' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','004','D Pensiones de Jubilacion, vejez o invalidez' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','005','E Otros ingresos originados en la relacion laboral' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','006','F Aportes Obligatorios por salud' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','007','G Aportes obligatorios a fondos de pensiones y solidaridad pensional' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','008','H Aporte voluntarios, a fondos de pensiones y cuentas AFC' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','009','I Valor de la Retencion en la fuente salarios y demas pagos laborales' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','010','J Arrendamientos' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','011','K Honorarios, comisiones y servicios' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','012','L Intereses y rendimientos financeiros' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','013','M Enajenacion de activos fijos' })
    AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','014','N Loterias, rifas, apuestas y similares' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','015','O Otros' })

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI


// borra la información estandar de la tabla S030
If dbSeek(cFilRCC+'S030')
	nIni:=1
	While !Eof() .And. (RCC_FILIAL+RCC_CODIGO == cFilRCC+'S030') .and. nIni <=11
		cStr := Strzero(nIni,3)
		If Alltrim(RCC_SEQUEN) == cStr
			RecLock('RCC',.F.)
			dbDelete()
			RCC->(MsUnLock())
		EndIf
		nIni++
		dbSkip()
	EndDo
EndIf

// crea la tabla S030 Tipo Movimiento Trayectoria
	aTabela	:=	{}
	cNomeArq := 'S030'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','01Ingreso                       ING' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','02Retiro                        RET' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','003','03Traslado A otra EPS           TAE' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','004','04Traslado Desde otra EPS       TDE' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','005','05Variacion Salario Permanente  VSP' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','006','08Traslado Desde otra AFP       TDP' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','007','09Traslado A otra AFP           TAP' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','008','10Variacion Salario Transitoria VST' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','009','11Modificacion de Funcion       FUN' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','010','12Modificacion de Cargo         CAR' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','011','13Variacion Centros de Trabajo  VCT' })

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI


// borra la información estandar de la tabla S031
If dbSeek(cFilRCC+'S031')
	nIni:=1
	While !Eof() .And. (RCC_FILIAL+RCC_CODIGO == cFilRCC+'S031') .and. nIni <=9
		cStr := Strzero(nIni,3)
		If Alltrim(RCC_SEQUEN) == cStr
			RecLock('RCC',.F.)
			dbDelete()
			RCC->(MsUnLock())
		EndIf
		nIni++
		dbSkip()
	EndDo
EndIf

// crea la tabla S031 Tipo Ausentismo
	aTabela	:=	{}
	cNomeArq := 'S031'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','AAccidente de Trabajo' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','GLicencia por Enfermedad General' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','003','MLicencia por Maternidad' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','004','PLicencia por Paternidad' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','005','FFaltas' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','006','VVacaciones' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','007','LLicencia no Remunerada' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','008','CComisión de Servicios' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','009','NNo Aplica para SS' })

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI


// borra la información estandar de la tabla S032
If dbSeek(cFilRCC+'S032')
	nIni:=1
	While !Eof() .And. (RCC_FILIAL+RCC_CODIGO == cFilRCC+'S032') .and. nIni <=2
		cStr := Strzero(nIni,3)
		If Alltrim(RCC_SEQUEN) == cStr
			RecLock('RCC',.F.)
			dbDelete()
			RCC->(MsUnLock())
		EndIf
		nIni++
		dbSkip()
	EndDo
EndIf

// crea la tabla S032 Calendario
	aTabela	:=	{}
	cNomeArq := 'S032'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','1Comercial (360 días por año/30 días por mes)' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','2Civil (365 días por año / Días Naturales por mes)' })

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI

// borra la información estandar de la tabla S033
If dbSeek(cFilRCC+'S033')
	nIni:=1
	While !Eof() .And. (RCC_FILIAL+RCC_CODIGO == cFilRCC+'S033') .and. nIni <=6
		cStr := Strzero(nIni,3)
		If Alltrim(RCC_SEQUEN) == cStr
			RecLock('RCC',.F.)
			dbDelete()
			RCC->(MsUnLock())
		EndIf
		nIni++
		dbSkip()
	EndDo
EndIf

// crea la tabla S033 Tipo Contrato para Formulación
	aTabela	:=	{}
	cNomeArq := 'S033'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','1Término Indefinido Salario Tradicional' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','2Término Indefinido Salario Integral' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','003','3Término Fijo Salario Tradicional' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','004','4Término Fijo Salario Integral' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','005','5Aprendiz Sena Etapa Lectiva' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','006','6Aprendiz Sena Etapa Productiva' })

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI


// borra la información estandar de la tabla S034
If dbSeek(cFilRCC+'S034')
	nIni:=1
	While !Eof() .And. (RCC_FILIAL+RCC_CODIGO == cFilRCC+'S034') .and. nIni <=10
		cStr := Strzero(nIni,3)
		If Alltrim(RCC_SEQUEN) == cStr
			RecLock('RCC',.F.)
			dbDelete()
			RCC->(MsUnLock())
		EndIf
		nIni++
		dbSkip()
	EndDo
EndIf
//-Carrega tabela de Acumuladores Auxiliares (S034)
	aTabela	:=	{}
	cNomeArq := 'S034'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','001SPILA-NUMERO DE DIAS COTIZADOS A PENSION           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','002SPILA-NUMERO DE DIAS COTIZADOS A SALUD             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','003','003SPILA-NUMERO DE DIAS COTIZADOS A RIESGOS PROFESIONA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','004','004SREFERENTE A RENUMERACAO EXTRAORDINARIA            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','005','005SBASE PARA INDENMIZACION POR EMBARAZO              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','006','006SPILA-NUMERO DE DIAS COTIZADOS A CAJA DE COMPENSAC '})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','007','007SBASE IBC-MES ANTERIOR PARA VACACIONES             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','008','008SPILA-SALARIO BASICO                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','009','009SBASE IBC-PAGOS NO SALARIALES (ART 30 / LEY 1393)  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','010','010SBASE PARA CALCULO DE SUBSIDIO TRANSPORTE          '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		RCC->(MsUnLock())
	Next nI

// borra la información estandar de la tabla S037

If dbSeek(cFilRCC+'S037')
	nIni:=1
	While !Eof() .And. (RCC_FILIAL+RCC_CODIGO == cFilRCC+'S037') .and. nIni <=2
		cStr := Strzero(nIni,3)
		If Alltrim(RCC_SEQUEN) == cStr
			RecLock('RCC',.F.)
			dbDelete()
			RCC->(MsUnLock())
		EndIf
		nIni++
		dbSkip()
	EndDo
EndIf
// crea la tabla S037 “Si o No”
	aTabela	:=	{}
	cNomeArq := 'S037'
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','001','1Si' })
	AAdd(aTabela,{cFilRCC,cNomeArq,'','      ','002','2No' })

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABVENºAutor³ Paulo Leme         º Data ³  04/12/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venezuela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TABVEN()

Local aTabela  := {}
Local cFilRCC  := xFilial("RCC")
Local cFilRCB  := xFilial("RCB")
Local cNomeArq := ""
Local nI	   := 0

DbSelectArea("RCB")
DbSetOrder(1)
If !dbSeek(cFilRCB+'S014')

	cNomeArq := 'S014'
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','01','CODIGO'   ,'CODIGO'      ,'C', 2,0,'@!'      ,'NAOVAZIO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','02','DESCRICAO','DESCRICAO'   ,'C',50,0,'@!'      ,'NAOVAZIO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','03','DIASCONTR','VIG.CONTRATO','N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','04','MINDCONTR','MINIMO  DIAS','N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','05','MAXDCONTR','MAXIMO DIAS' ,'N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','06','QTDRENOV' ,'RENOVACOES'  ,'N', 4,0,'@E 9,999','POSITIVO().AND.NAOVAZIO()','','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','07','PRAZOMIN' ,'PRAZO MINIMO','N', 4,0,'@E 9,999','POSITIVO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','08','PRAZOMAX' ,'PRAZO MAXIMO','N', 4,0,'@E 9,999','POSITIVO()'               ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','09','TIPO_QDP' ,'QDR. PESSOAL','C', 1,0,'@!','VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))' ,'','001'} )
	aAdd( aTabela, { cFilRCB,cNomeArq,'TIPOS DE CONTRATOS','10','TIPO_BSO' ,'BAL. SOCIAL' ,'C', 1,0,'@!','VAZIO() .OR. If(PERTENCE("123"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'       ,'','001'} )
	For nI := 1 To Len(aTabela)
		RecLock('RCB',.T.)
		Replace RCB_FILIAL With aTabela[nI][01]
		Replace RCB_CODIGO With aTabela[nI][02]
		Replace RCB_DESC   With aTabela[nI][03]
		Replace RCB_ORDEM  With aTabela[nI][04]
		Replace RCB_CAMPOS With aTabela[nI][05]
		Replace RCB_DESCPO With aTabela[nI][06]
		Replace RCB_TIPO   With aTabela[nI][07]
		Replace RCB_TAMAN  With aTabela[nI][08]
		Replace RCB_DECIMA With aTabela[nI][09]
		Replace RCB_PICTUR With aTabela[nI][10]
		Replace RCB_VALID  With aTabela[nI][11]
		Replace RCB_VERSAO With aTabela[nI][12]
		MsUnLock()
	Next nI
Else
	DbSelectArea("RCB")
	DbSetOrder(3)
	If dbSeek(cFilRCB+'TIPO_QDP')
		If Alltrim(RCB->RCB_CODIGO)=='S014' .And. Alltrim(RCB->RCB_VALID) <> 'VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))'
			RecLock('RCB',.F.)
            RCB->RCB_VALID:='VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3,4,8 ou deixe o campo vazio","Atencao"),.F.))'
           	MsUnlock()
	    Endif
	Endif
	If dbSeek(cFilRCB+'TIPO_BSO')
		If Alltrim(RCB->RCB_CODIGO)=='S014' .And. Alltrim(RCB->RCB_VALID) <> 'VAZIO() .OR. If(PERTENCE("12348"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'
			RecLock('RCB',.F.)
            RCB->RCB_VALID:='VAZIO() .OR. If(PERTENCE("123"),.T.,(Alert("Informe apenas 1,2,3 ou deixe o campo vazio","Atencao"),.F.))'
           	MsUnlock()
	    Endif
	Endif
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S014')
	aTabela	:=	{}
	cNomeArq := 'S014'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01POR TIEMPO INDETERMINADO', '0','0','0','0','0','0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02POR TIEMPO DETERMINADO',   '0','0','0','0','0','0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03PARA UNA OBRA DETERMINADA','0','0','0','0','0','0'})
//	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04SEM CONTRATO                                         0   0   0   0   0   0'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S020')
	aTabela	:=	{}
	cNomeArq := 'S020'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01Remuneração Salario'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02Remuneração Utilidades'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03Remuneração Bonificações'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04Remuneração Gratificação'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05Remuneração Antiguidade'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06Remuneração Outros'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07Imposto Retido'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08Deduções'})
	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABMEXºAutor³ Microsiga          º Data ³  04/12/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venezuela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp310TABMEX(lEnd)

	Local aTabela	:= {}
	Local cFilRCC	:= xFilial("RCC")
	Local cFilRCB	:= xFilial("RCB")
	Local cNomeArq	:= ""
	Local nI		:= 0
	Local lInsert	:= .F.
	Local lCreaTab	:= .t.
	Local cFil		:= Space(10)
	Local cChave	:= Space(6)
	Local cSequen	:= "57"
	Local cMsgProc	:= "Procesando tabla: "

	ProcRegua(13) //Numero de tablas a procesar, si se agrega una nueva tabla, se debe aumentar el numero del parametro.

	IncProc(cMsgProc + "S020.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S020'))

		cNomeArq := 'S020'

		AAdd(aTabela,{cFilRCB,cNomeArq,'DECLARACION ANUAL','01','CLAVE'  ,'CLAVE'      ,'C',  4, 0,'@!'	,''				})
		AAdd(aTabela,{cFilRCB,cNomeArq,'DECLARACION ANUAL','02','DESCR'  ,'DESCRIPCION','C',100, 0,'@!'	,''				})
		AAdd(aTabela,{cFilRCB,cNomeArq,'DECLARACION ANUAL','03','PICTURE','PICTURE'    ,'C', 17, 0,'@!'	,''				})
		AAdd(aTabela,{cFilRCB,cNomeArq,'DECLARACION ANUAL','04','TAMANO' ,'TAMANO'     ,'N',  2, 0,'99'	,''				})
		AAdd(aTabela,{cFilRCB,cNomeArq,'DECLARACION ANUAL','05','DECIMAL','DECIMAL'    ,'N',  1, 0,'9' ,''					})

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL With aTabela[nI][01]
				Replace RCB_CODIGO With aTabela[nI][02]
				Replace RCB_DESC   With aTabela[nI][03]
				Replace RCB_ORDEM  With aTabela[nI][04]
				Replace RCB_CAMPOS With aTabela[nI][05]
				Replace RCB_DESCPO With aTabela[nI][06]
				Replace RCB_TIPO   With aTabela[nI][07]
				Replace RCB_TAMAN  With aTabela[nI][08]
				Replace RCB_DECIMA With aTabela[nI][09]
				Replace RCB_PICTUR With aTabela[nI][10]
				Replace RCB_VALID  With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !(RCC->(dbSeek(cFilRCC+'S020')))
		lInsert := .T.
	EndIf

	If lInsert

		cNomeArq := "S020"

		//INCLUSOS EM P/ DECLARACAO ANUAL DO ANO DE 2010
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','1A  MONTO DE LAS APORTACIONES VOLUNTARIAS EFECTUADAS                                                    @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','1B  INDIQUE EL PATRON APLICO EL MONTO DE LAS APORTACIONES VOLUNTARIAS EN EL CALCULO DEL IMPUESTO        @!                10'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','1C  MONTO DE LAS APORTACIONES VOLUNTARIAS DEDUCIBLES PARA TRABAJADORES QUE REALIZAN SU DECLARACION      @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','1D  MONTO DE LAS APORTACIONES VOLUNTARIAS DEDUCIBLES APLICADAS POR EL PATRON                            @R 99999999999999140'})

		//ALTERADOS P/ 2010
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','2A  A. TOTAL INGRESOS POR SUELDOS, SALARIOS Y CONCEPTOS ASIMILADOS                                      @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','2B  B. IMPUESTO LOCAL INGRESOS POR SUELDOS, SALARIOS Y EN GENERAL POR LA PREST. SERV.PERS. SUBORD.      @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','2C  C. INGRESOS EXENTOS                                                                                 @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','2D  D. TOTAL DE LAS APORTACIONES VOLUNTARIAS DEDUCIBLES                                                 @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','2E  E. INGRESOS NO ACUMULABLES                                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','2F  F. INGRESOS ACUMULABLES                                                                             @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','2G  G. ISR CONFORME A LA TARIFA ANUAL                                                                   @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','2H  H. SUBSIDIO ACREDITABLE                                                                             @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','2I  I. SUBSIDIO NO ACREDITABLE                                                                          @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','2J  J. SUBSIDIO PARA EL EMPLEO                                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','2K  K. MONTO DEL SUBSIDIO ACREDITABLE FRACCION III                                                      @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','2L  L. MONTO DEL SUBSIDIO ACREDITABLE FRACCION IV                                                       @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','2M  M. IMPUESTO SOBRE INGRESOS ACUMULABLES                                                              @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','2N  N. IMPUESTO SOBRE INGRESOS NO ACUMULABLES                                                           @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','019','2O  O. IMPUESTO SOBRE LA RENTA CAUSADA EN EL EJERCICIO QUE DECLARA                                      @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','020','2P  P. IMPUESTO RETENIDO AL CONTRIBUYENTE                                                               @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','021','3Q  Q. MONTO TOTAL DEL PAGO EN UNA SOLA EXHIBICION                                                      @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','022','3R  R. INGRESOS TOTALES POR PAGO EN PARCIALIDADES                                                       @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','023','3S  S. MONTO DIARIO PERCIBIDO POR JUBILACIONES, PENSIONES O HABERES DE RETIRO EN PARCIALIDADES          @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','024','3T  T. CANTIDAD QUE SE HUBIERA PERCIBIDO EN EL PERIODO DE NO HABER PAGO UNICO POR JUB. PENS. O HAB.RET. @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','025','3U  U. NUMERO DE DIAS (8)                                                                               999               30'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','026','3V  V. INGRESOS EXENTOS                                                                                 @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','027','3W  W. INGRESOS GRAVABLES                                                                               @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','028','3X  X. INGRESOS ACUMULABLES                                                                             @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','029','3Y  Y. INGRESOS NO ACUMULABLES                                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','030','3Z  Z. IMPUESTO RETENIDO                                                                                @R 9999999999999 130'})

		//ALTERADA SEQUENCIA/DECIMAIS - 2010
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','031','3A  A. MONTO TOTAL PAGADO                                                                               @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','032','3B  B. NUMERO DE ANOS DE SERVICIO DEL TRABAJADOR                                                        99                20'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','033','3C  C. INGRESOS EXENTOS                                                                                 @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','034','3D  D. INGRESOS GRAVADOS                                                                                @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','035','3E  E. INGRESOS ACUMULABLES                                                                             @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','036','3F  F. IMPUESTO CORRESPONDIENTE AL ULTIMO SUELDO MENSUAL ORDINARIO                                      @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','037','3G  G. INGRESOS NO ACUMULABLES                                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','038','3H  H. IMPUESTO RETENIDO                                                                                @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','039','4I  I. INGRESOS ASIMILADOS A SALARIOS                                                                   @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','040','4J  J. IMPUESTOS RETENIDOS DURANTE EL EJERCICIO                                                         @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','041','41K K. VALOR DE MERCADO DE LAS ACCIONES O TITULOS VALOR AL EJERCER LA OPCION                            @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','042','41L L. PRECIO ESTABLECIDO AL OTORGARSE LA OPCION DE INGRESOS EN ACCIONES O TITULOS VALOR                @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','043','41M M. INGRESO ACUMULABLE                                                                               @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','044','41N N. IMPUESTO RETENIDO                                                                                @R 9999999999999 130'})

		//ALTERADA DESCRICAO - 2010 (EXENTO)
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','045','5OE O. SUELDOS, SALARIOS, RAYAS Y JORNALES EXENTO                                                       @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','046','5PE P. GRATIFICACION ANUAL EXENTO                                                                       @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','047','5QE Q. VIATICOS Y GASTOS DE VIAJE EXENTO                                                                @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','048','5RE R. TIEMPO EXTRAORDINARIO EXENTO                                                                     @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','049','5SE S. PRIMA VACACIONAL EXENTO                                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','050','5TE T. PRIMA DOMINICAL EXENTO                                                                           @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','051','5UE U. PARTICIPACION DE LOS TRABAJADORES EN LAS UTILIDADES (PTU) EXENTO                                 @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','052','5VE V. REEMBOLSO DE GASTOS MEDICOS, DENTALES Y HOSPITALARIOS EXENTO                                     @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','053','5WE W. FONDO DE AHORRO EXENTO                                                                           @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','054','5XE X. CAJA DE AHORRO EXENTO                                                                            @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','055','5YE Y. VALES PARA DESPENSA EXENTO                                                                       @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','056','5ZE Z. AYUDA PARA GASTOS DE FUNERAL EXENTO                                                              @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','057','5A1EA1. CONTRIBUCIONES A CARGO DEL TRABAJADOR PAGADAS POR EL PATRON EXENTO                              @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','058','5B1EB1. PREMIO POR PUNTUALIDAD EXENTO                                                                   @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','059','5C1EC1. PRIMA DE SEGURO DE VIDA EXENTO                                                                  @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','060','5D1ED1. SEGURO DE GASTOS MEDICOS MAYORES EXENTO                                                         @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','061','5E1EE1. VALES PARA RESTAURANTE EXENTO                                                                   @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','062','5F1EF1. VALES PARA GASOLINA EXENTO                                                                      @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','063','5G1EG1. VALES PARA ROPA EXENTO                                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','064','5H1EH1. AYUDA PARA RENTA EXENTO                                                                         @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','065','5I1EI1. AYUDA PARA ARTICULOS ESCOLARES EXENTO                                                           @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','066','5J1EJ1. DOTACION O AYUDA PARA ANTEOJOS EXENTO                                                           @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','067','5K1EK1. AYUDA PARA TRANSPORTE EXENTO                                                                    @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','068','5L1EL1. CUOTAS SINDICALES PAGADAS POR EL PATRON EXENTO                                                  @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','069','5M1EM1. SUBSIDIOS POR INCAPACIDAD EXENTO                                                                @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','070','5N1EN1. BECAS PARA TRABAJADORES Y/O SUS HIJOS EXENTO                                                    @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','071','5O1EO1. PAGOS EFECTUADOS POR OTROS EMPLEADORES (2) (3) EXENTO                                           @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','072','5P1EP1. OTROS INGRESOS POR SALARIOS EXENTO                                                              @R 9999999999999 130'})

		//GRAVADO
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','073','5OG O. SUELDOS, SALARIOS, RAYAS Y JORNALES GRAVADO                                                      @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','074','5PG P. GRATIFICACION ANUAL GRAVADO                                                                      @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','075','5QG Q. VIATICOS Y GASTOS DE VIAJE GRAVADO                                                               @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','076','5RG R. TIEMPO EXTRAORDINARIO GRAVADO                                                                    @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','077','5SG S. PRIMA VACACIONAL GRAVADO                                                                         @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','078','5TG T. PRIMA DOMINICAL GRAVADO                                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','079','5UG U. PARTICIPACION DE LOS TRABAJADORES EN LAS UTILIDADES (PTU) GRAVADO                                @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','080','5VG V. REEMBOLSO DE GASTOS MEDICOS, DENTALES Y HOSPITALARIOS GRAVADO                                    @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','081','5WG W. FONDO DE AHORRO GRAVADO                                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','082','5XG X. CAJA DE AHORRO GRAVADO                                                                           @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','083','5YG Y. VALES PARA DESPENSA GRAVADO                                                                      @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','084','5ZG Z. AYUDA PARA GASTOS DE FUNERAL GRAVADO                                                             @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','085','5A1GA1. CONTRIBUCIONES A CARGO DEL TRABAJADOR PAGADAS POR EL PATRON GRAVADO                             @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','086','5B1GB1. PREMIO POR PUNTUALIDAD GRAVADO                                                                  @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','087','5C1GC1. PRIMA DE SEGURO DE VIDA GRAVADO                                                                 @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','088','5D1GD1. SEGURO DE GASTOS MEDICOS MAYORES GRAVADO                                                        @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','089','5E1GE1. VALES PARA RESTAURANTE GRAVADO                                                                  @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','090','5F1GF1. VALES PARA GASOLINA GRAVADO                                                                     @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','091','5G1GG1. VALES PARA ROPA GRAVADO                                                                         @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','092','5H1GH1. AYUDA PARA RENTA GRAVADO                                                                        @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','093','5I1GI1. AYUDA PARA ARTICULOS ESCOLARES GRAVADO                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','094','5J1GJ1. DOTACION O AYUDA PARA ANTEOJOS GRAVADO                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','095','5K1GK1. AYUDA PARA TRANSPORTE GRAVADO                                                                   @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','096','5L1GL1. CUOTAS SINDICALES PAGADAS POR EL PATRON GRAVADO                                                 @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','097','5M1GM1. SUBSIDIOS POR INCAPACIDAD GRAVADO                                                               @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','098','5N1GN1. BECAS PARA TRABAJADORES Y/O SUS HIJOS GRAVADO                                                   @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','099','5O1GO1. PAGOS EFECTUADOS POR OTROS EMPLEADORES (2) (3) GRAVADO                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','100','5P1GP1. OTROS INGRESOS POR SALARIOS GRAVADO                                                             @R 9999999999999 130'})

		//SEQUENCIA/DECIMAIS
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','101','6Q1 Q1. SUMA DEL INGRESO GRAVADO POR SUELDOS Y SALARIOS                                                 @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','102','6R1 R1. SUMA DEL INGRESO EXENTO POR SUELDOS Y SALARIOS                                                  @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','103','6S1 S1. SUMA DE INGRESOS POR SUELDOS Y SALARIOS                                                         @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','104','6T1 T1. MONTO DEL IMP. LOCAL A LOS ING. POR SUELDOS, SAL.  EN GEN. PREST. SERV.PERS. SUBORDINADO RETENID@R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','105','6U1 U1. IMPUESTO RETENIDO DURANTE EL EJERCICIO                                                          @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','106','6V1 V1. IMPUESTO RETENIDO POR OTRO(S) PATRON(ES) DURANTE EL EJERCICIO                                   @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','107','6W1 W1. SALDO A FAVOR DET. EN EL EJE. QUE DECLARA QUE EL PAT. COMP. DUR. EL SIG. EJ. O SOL. SU DEVOL.   @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','108','6X1 X1. SALDO A FAVOR DEL EJERC. ANTERIOR  NO COMP. DURANTE EL EJ. QUE AMPLARA LA CONSTANCIA            @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','109','6Y1 Y1. SUMA DE LAS CANT. QUE POR CONCEPTO DE CREDITO AL SALARIO LE CORRESP. AL TRABAJADOR              @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','110','6Z1 Z1. CREDITO AL SALARIO ENTREGADO EN EFECTIVO AL TRABAJADOR DURANTE EL EJERCICIO                     @R 9999999999999 130'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','111','6A1 A1. MONTO TOTAL DE INGRESOS OBTENIDOS POR CONCEPTO DE PRESTACIONES  DE PREVISION SOCIAL             @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','112','6B1 B1. SUMA DE INGRESOS EXENTOS POR CONCEPTO DE PRESTACIONES DE PREVISION SOCIAL                       @R 99999999999999140'})
		AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','113','6C1 C1. MONTO DEL SUBS. P/ EL EMPLEO ENTREGADO EN EFEC. AL TRABAJ. DURANTE EL EJERC. QUE DECLARA        @R 9999999999999 130'})

		Begin Transaction
			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL With aTabela[nI][01]
					Replace RCC_CODIGO With aTabela[nI][02]
					Replace RCC_FIL    With aTabela[nI][03]
					Replace RCC_CHAVE  With aTabela[nI][04]
					Replace RCC_SEQUEN With aTabela[nI][05]
					Replace RCC_CONTEU With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI
		End Transaction
	EndIf

	IncProc(cMsgProc + "S021.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S021'))

		cNomeArq := 'S021'

		aTabela	:=	{}
		AAdd(aTabela,{cFilRCB,cNomeArq,'REPRESENTANTE LEGAL','01','NOMBRE','NOMBRE','C', 50, 0,'@!'	,''				})
		AAdd(aTabela,{cFilRCB,cNomeArq,'REPRESENTANTE LEGAL','02','RFC'   ,'RFC'   ,'C', 13, 0,'@!'	,''				})
		AAdd(aTabela,{cFilRCB,cNomeArq,'REPRESENTANTE LEGAL','03','CURP'  ,'CURP'  ,'C', 18, 0,'@!'	,''				})

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL With aTabela[nI][01]
				Replace RCB_CODIGO With aTabela[nI][02]
				Replace RCB_DESC   With aTabela[nI][03]
				Replace RCB_ORDEM  With aTabela[nI][04]
				Replace RCB_CAMPOS With aTabela[nI][05]
				Replace RCB_DESCPO With aTabela[nI][06]
				Replace RCB_TIPO   With aTabela[nI][07]
				Replace RCB_TAMAN  With aTabela[nI][08]
				Replace RCB_DECIMA With aTabela[nI][09]
				Replace RCB_PICTUR With aTabela[nI][10]
				Replace RCB_VALID  With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	IncProc(cMsgProc + "S027.")

	DbSelectArea("RCC")
	DbSetOrder(1)

	cFil   := Space(TamSX3("RCC_FIL")[1])
	cChave := Space(TamSX3("RCC_CHAVE")[1])
	cSequen :="009"

	If ( RCC->(dbSeek(cFilRCC+'S027'+cFil+cChave+cSequen)) )
		lCreaTab := .F.
	Else
		If (RCC->(dbSeek(cFilRCC+'S027')))
			While RCC->(!Eof()) .AND. RCC->RCC_CODIGO=='S027'
				RecLock("RCC",.F.)
					RCC->(DbDelete())
				RCC->(MsUnlock())
				RCC->(DbSkip())
			EndDo
		EndIf

		DbSelectArea("RCB")
		DbSetOrder(1)

		If (RCB->(dbSeek(cFilRCB+'S027')))
			While RCB->(!Eof()) .AND. RCB->RCB_CODIGO=='S027'
				RecLock("RCB",.F.)
					RCB->(DbDelete())
				RCB->(MsUnlock())
				RCB->(DbSkip())
			EndDo
		EndIf
	EndIf

	If  lCreaTab .OR. !RCB->(dbSeek(cFilRCB+'S035'))

		DbSelectArea("RCB")
		DbSetOrder(1)
		If !RCB->(dbSeek(cFilRCB+'S027'))

			aTabela:= {}
			cNomeArq := 'S027'

			//		      RCB_FILIAL, RCB_CODIGO, 	RCB_DESC, 			    RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 	RCB_TAMAN, 	   RCB_DECIMA, 	  RCB_PICTUR,         RCB_VALID
			aAdd(aTabela,{cFilRCB, 	  cNomeArq, 	'Tipo Régimen SAT', 	'01', 			'Clave', 		'Clave', 			'C', 			2, 			0, 			'@!', 		'Naovazio()' })
			aAdd(aTabela,{cFilRCB,	  cNomeArq,		'Tipo Régimen SAT',		'02',			'Desc',			'Descripción',		'C',			150, 		0,			'@!',		'Naovazio()' })

			For nI := 1 To Len(aTabela)
				RecLock('RCB',.T.)
					Replace RCB_FILIAL	With aTabela[nI][01]
					Replace RCB_CODIGO 	With aTabela[nI][02]
					Replace RCB_DESC   	With aTabela[nI][03]
					Replace RCB_ORDEM  	With aTabela[nI][04]
					Replace RCB_CAMPOS 	With aTabela[nI][05]
					Replace RCB_DESCPO 	With aTabela[nI][06]
					Replace RCB_TIPO   	With aTabela[nI][07]
					Replace RCB_TAMAN  	With aTabela[nI][08]
					Replace RCB_DECIMA 	With aTabela[nI][09]
					Replace RCB_PICTUR 	With aTabela[nI][10]
					Replace RCB_VALID  	With aTabela[nI][11]
				RCB->(MsUnLock())
			Next nI
		EndIf

		DbSelectArea("RCC")
		DbSetOrder(1)

		If !( RCC->(dbSeek(cFilRCC+'S027')) ) .OR. !RCC->(dbSeek(cFilRCB+'S035'))

			If (RCC->(dbSeek(cFilRCC+'S027')))
				While RCC->(!Eof()) .AND. RCC->RCC_CODIGO == 'S027'
					RecLock("RCC",.F.)
						RCC->(DbDelete())
					RCC->(MsUnlock())
					RCC->(DbSkip())
				EndDo
			EndIf

			aTabela:= {}
			cNomeArq := "S027"

			//INCLUSOS EM P/ DECLARACAO ANUAL DO ANO DE 2017
			//		  RCC_FILIAL,	RCC_CODIGO,		RCC_FIL,	RCC_CHAVE,	RCC_SEQUEN,	RCC_CONTEU
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'001',			'02Sueldos'})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'002',			'03Jubilados'})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'003',			'04Pensionados'})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'004',			'05Asimilados Miembros Sociedades Cooperativas Produccion'})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'005',			'06Asimilados Integrantes Sociedades Asociaciones Civiles'})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'006',			'07Asimilados Miembros consejos'})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'007',			'08Asimilados Comisionistas'})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'008',			'09Asimilados Honorarios '})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'009',			'10Asimilados Acciones '})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'010',			'11Asimilados Otros '})
			AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'011',			'99Otro Régimen '})

			Begin Transaction

				For nI := 1 To Len(aTabela)
					RecLock('RCC',.T.)
						Replace RCC_FILIAL	With aTabela[nI][01]
						Replace RCC_CODIGO 	With aTabela[nI][02]
						Replace RCC_FIL   	With aTabela[nI][03]
						Replace RCC_CHAVE  	With aTabela[nI][04]
						Replace RCC_SEQUEN 	With aTabela[nI][05]
						Replace RCC_CONTEU 	With aTabela[nI][06]
					RCC->(MsUnLock())
				Next nI

			End Transaction
		EndIf

	EndIf

	lCreaTab 	:=.T.

	IncProc(cMsgProc + "S028.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S028')) .OR. !RCB->(dbSeek(cFilRCB+'S035'))
		If (RCB->(dbSeek(cFilRCB+'S028')))
			While RCB->(!Eof()) .AND. RCB->RCB_CODIGO == 'S028'
				RECLOCK("RCB",.F.)
					RCB->(DbDelete())
				RCB->(MsUnlock())
				RCB->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := 'S028'

		//		      RCB_FILIAL, 	RCB_CODIGO, 	RCB_DESC, 			RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 	RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Tipo Contrato SAT', 		'01', 			'Clave', 			'Clave', 			'C', 			2, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,			cNomeArq,			'Tipo Contrato SAT',		'02',			'Desc',			'Descripción',		'C',			100, 			0,				'@!',			'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR 	With aTabela[nI][10]
				Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S028')) ) .OR. !RCC->(dbSeek(cFilRCB+'S035'))

		If (RCC->(dbSeek(cFilRCC+'S028')))
			While RCC->(!Eof()) .AND. RCC->RCC_CODIGO=='S028'
				RecLock("RCC",.F.)
					RCC->(DbDelete())
				RCC->(MsUnlock())
				RCC->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := "S028"

		//INCLUSOS EM P/ DECLARACAO ANUAL DO ANO DE 2010
		//		      RCC_FILIAL, RCC_CODIGO,		    RCC_FIL,	   RCC_CHAVE,	   RCC_SEQUEN,	        RCC_CONTEU
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'001',			'01Contrato de trabajo por tiempo indeterminado'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'002',			'02Contrato de trabajo para obra determinada'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'003',			'03Contrato de trabajo por tiempo determinado'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'004',			'04Contrato de trabajo por temporada'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'005',			'05Contrato de trabajo sujeto a prueba'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'006',			'06Contrato de trabajo con capacitación inicial'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'007',			'07Modalidad de contratación por pago de hora laborada'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'008',			'08Modalidad de trabajo por comisión laboral'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'009',			'09Modalidades de contratación donde no existe relación de trabajo'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'010',			'10Jubilación, pensión, retiro.'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'099',			'99Otro contrato'})

		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL	With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    	With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

	IncProc(cMsgProc + "S029.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S029')) .OR. !RCB->(dbSeek(cFilRCB+'S035'))
		If (RCB->(dbSeek(cFilRCB+'S029')))
			While RCB->(!Eof()) .AND. RCB->RCB_CODIGO=='S029'
				RecLock("RCB",.F.)
					RCB->(DbDelete())
				RCB->(MsUnlock())
				RCB->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := 'S029'

		//		  RCB_FILIAL, 	RCB_CODIGO, 	RCB_DESC, 			RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 	RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Periodicidad de Pago SAT', 		'01', 			'Clave', 			'Clave', 			'C', 			2, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,			cNomeArq,			'Periodicidad de Pago SAT',		'02',			'Desc',			'Descripción',		'C',			100,			0,				'@!',			'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR 	With aTabela[nI][10]
				Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S029')) ) .OR. !RCC->(dbSeek(cFilRCB+'S035'))
		If (RCC->(dbSeek(cFilRCC+'S029')))
			While RCC->(!Eof()) .AND. RCC->RCC_CODIGO=='S029'
				RecLock("RCC",.F.)
					RCC->(DbDelete())
				RCC->(MsUnlock())
				RCC->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := "S029"

		//INCLUSOS EM P/ DECLARACAO ANUAL DO ANO DE 2010
		//		    RCC_FILIAL,	  RCC_CODIGO,		    RCC_FIL,	   RCC_CHAVE,	   RCC_SEQUEN,	        RCC_CONTEU
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'001',			'01Diario'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'002',			'02Semanal'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'003',			'03Catorcenal'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'004',			'04Quincenal'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'005',			'05Mensual'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'006',			'06Bimestral'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'007',			'07Unidad obra'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'008',			'08Comisión'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'009',			'09Precio alzado'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'099',			'99Otra Periodicidad'})

		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL	With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    	With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

	IncProc(cMsgProc + "S030.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S030')) .OR. !RCB->(dbSeek(cFilRCB+'S035'))
		If (RCB->(dbSeek(cFilRCB+'S030')))
			While RCB->(!Eof()) .AND. RCB->RCB_CODIGO=='S030'
				RecLock("RCB",.F.)
					RCB->(DbDelete())
				RCB->(MsUnlock())
				RCB->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := 'S030'

		//		  RCB_FILIAL, 	RCB_CODIGO, 	RCB_DESC, 			RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 	RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Riesgo Puesto SAT', 	'01', 			'Clave', 			'Clave', 			'C', 			1, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,			cNomeArq,			'Riesgo Puesto SAT',		'02',			'Desc',			'Descripción',		'C',			100,			0,				'@!',			'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR 	With aTabela[nI][10]
				Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S030')) ) .OR. !RCC->(dbSeek(cFilRCB+'S035'))
		If (RCC->(dbSeek(cFilRCC+'S030')))
			While RCC->(!Eof()) .AND. RCC->RCC_CODIGO=='S030'
				RecLock("RCC",.F.)
					RCC->(DbDelete())
				RCC->(MsUnlock())
				RCC->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := "S030"

		//INCLUSOS EM P/ DECLARACAO ANUAL DO ANO DE 2010
		//		  RCC_FILIAL,	RCC_CODIGO,		RCC_FIL,	RCC_CHAVE,	RCC_SEQUEN,	RCC_CONTEU
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'001',			'1Clase I'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'002',			'2Clase II'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'003',			'3Clase III'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'004',			'4Clase IV'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'005',			'5Clase V'})

		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL	With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    	With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

	IncProc(cMsgProc + "S031.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S031')) .OR. !RCB->(dbSeek(cFilRCB+'S035'))
		If (RCB->(dbSeek(cFilRCB+'S031')))
			While RCB->(!Eof()) .AND. RCB->RCB_CODIGO=='S031'
				RecLock("RCB",.F.)
				RCB->(DbDelete())
				RCB->(MsUnlock())
				RCB->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := 'S031'

		//		  RCB_FILIAL, 	RCB_CODIGO, 	RCB_DESC, 			RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 	RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Tipo Concepto SAT', 	'01', 			'Clave', 			'Clave', 			'C', 			4, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,			cNomeArq,			'Tipo Concepto SAT',		'02',			'Desc',			'Descripción',		'C',			120,			0,				'@!',			'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR 	With aTabela[nI][10]
				Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	cFil 	:= Space(TamSX3("RCC_FIL")[1])
	cChave  := Space(TamSX3("RCC_CHAVE")[1])
	cSequen := "057"
	If ( RCC->(dbSeek(cFilRCC+'S031'+cFil+cChave+cSequen)) ) .AND. RCC->(dbSeek(cFilRCB+'S035'))
		lCreaTab := .F.
	Else
		If (RCC->(dbSeek(cFilRCC+'S031')))
			While RCC->(!Eof()) .AND. RCC->RCC_CODIGO=='S031'
				RecLock("RCC",.F.)
					RCC->(DbDelete())
				RCC->(MsUnlock())
				RCC->(DbSkip())
			EndDo
		EndIf
	EndIf

	If lCreaTab
		aTabela:= {}
		cNomeArq := "S031"

		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'001',	'001PSueldos, Salarios, Rayas y Jornales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'002',	'002PGratificación Anual (Aguinaldo)'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'003',	'003PParticipación de los Trabajadores en las Utilidades PTU'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'004',	'004PReembolso de Gastos Médicos, Dentales y Hospitalarios'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'005',	'005PFondo de Ahorro'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'006',	'006PCaja de Ahorro'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'007',	'009PContribuciones a Cargo del Trabajador Pagadas por el Patrón'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'008',	'010PPremio por Puntualidad'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'009',	'011PPrima De Seguro De Vida'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'010',	'012PSeguro de Gastos Médicos Mayores'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'011',	'013PCuotas Sindicales Pagadas por el Patrón'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'012',	'014PSubsidios por Incapacidad'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'013',	'015PBecas para Trabajadores y/o Hijos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'014',	'019PHoras Extras'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'015',	'020PPrima Dominical'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'016',	'021PPrima Vacacional'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'017',	'022PPrima por Antigüedad '})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'018',	'023PPagos por Separación'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'019',	'024PSeguro de Retiro'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'020',	'025PIndemnizaciones'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'021',	'026PReembolso por Funeral'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'022',	'027PCuotas de Seguridad Social Pagadas por el patrón'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'023',	'028PComisiones'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'024',	'029PVales de despensa'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'025',	'030PVales de restaurantes'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'026',	'031PVales de gasolina'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'027',	'032PVales de ropa'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'028',	'033PAyuda para renta'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'029',	'034PAyuda para artículos escolares'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'030',	'035PAyuda para anteojos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'031',	'036PAyuda para transporte'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'032',	'037PAyuda para gasto de funeral'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'033',	'038POtros ingresos por salarios'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'034',	'039PJubilaciones, pensiones o haberes de retiro'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'035',	'044PJubilaciones, pensiones o haberes de retiro en parcialidades'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'036',	'045PIngresos en acciones o títulos valor que representan bienes'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'037',	'046PIngresos asimilados a salarios'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'038',	'047PAlimentación'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'039',	'048PHabitación'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'040',	'049PPremios por asistencia'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'041',	'001DSeguridad Social'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'042',	'002DISR'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'043',	'003DAportaciones a Retiro, Cesantía en Edad Avanzada y Vejez'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'044',	'004DOtros'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'045',	'005DAportaciones a Fondo de Vivienda'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'046',	'006DDescuento por Incapacidad'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'047',	'007DPensión Alimenticia'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'048',	'008DRenta'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'049',	'009DPréstamos provenientes del Fondo Nacional de la Vivienda para los Trabajadores'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'050',	'010DPago por Crédito de Vivienda'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'051',	'011DPago de Abonos INFONACOT'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'052',	'012DAnticipo de Salarios'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'053',	'013DPagos hechos con exceso al trabajador'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'054',	'014DErrores'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'055',	'015DPérdidas'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'056',	'016DAverías'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'057',	'017DAdquisición de artículos producidos por la empresa o establecimiento.'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'058',	'018DCuotas para la constitución y fomento de sociedades cooperativas y de cajas de ahorro'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'059',	'019DCuotas Sindicales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'060',	'020DAusencias (Ausentismo)'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'061',	'021DCuotas Obrero Patronales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'062',	'022DImpuestos Locales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'063',	'023DAportaciones Voluntarias'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'064',	'001OReintegro de ISR pagado en exceso (siempre que no haya sido enterado al SAT)'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'065',	'002OSubsidio para el empleo (efectivamente entregado al trabajador)'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'066',	'003OViáticos (entregados al trabajador)'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'067',	'004OAplicación de saldo a favor por compensación anual.'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'068',	'999OPagos distintos a los listados y que no deben considerarse como ingreso por sueldos, salarios o ingresos asimilados.'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'069',	'024DAjuste en Gratificación Anual (Aguinaldo) Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'070',	'025DAjuste en Gratificación Anual (Aguinaldo) Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'071',	'026DAjuste en Participación de los Trabajadores en las Utilidades PTU Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'072',	'027DAjuste en Participación de los Trabajadores en las Utilidades PTU Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'073',	'028DAjuste en Reembolso de Gastos Médicos Dentales y Hospitalarios Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'074',	'029DAjuste en Fondo de ahorro Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'075',	'030DAjuste en Caja de ahorro Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'076',	'031DAjuste en Contribuciones a Cargo del Trabajador Pagadas por el Patrón Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'077',	'032DAjuste en Premios por puntualidad Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'078',	'033DAjuste en Prima de Seguro de vida Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'079',	'034DAjuste en Seguro de Gastos Médicos Mayores Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'080',	'035DAjuste en Cuotas Sindicales Pagadas por el Patrón Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'081',	'036DAjuste en Subsidios por incapacidad Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'082',	'037DAjuste en Becas para trabajadores y/o hijos Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'083',	'038DAjuste en Horas extra Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'084',	'039DAjuste en Horas extra Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'085',	'040DAjuste en Prima dominical Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'086',	'041DAjuste en Prima dominical Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'087',	'042DAjuste en Prima vacacional Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'088',	'043DAjuste en Prima vacacional Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'089',	'044DAjuste en Prima por antigüedad Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'090',	'045DAjuste en Prima por antigüedad Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'091',	'046DAjuste en Pagos por separación Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'092',	'047DAjuste en Pagos por separación Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'093',	'048DAjuste en Seguro de retiro Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'094',	'049DAjuste en Indemnizaciones Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'095',	'050DAjuste en Indemnizaciones Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'096',	'051DAjuste en Reembolso por funeral Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'097',	'052DAjuste en Cuotas de seguridad social pagadas por el patrón Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'098',	'053DAjuste en Comisiones Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'099',	'054DAjuste en Vales de despensa Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'100',	'055DAjuste en Vales de restaurante Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'102',	'056DAjuste en Vales de gasolina Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'103',	'057DAjuste en Vales de ropa Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'104',	'058DAjuste en Ayuda para renta Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'105',	'059DAjuste en Ayuda para artículos escolares Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'106',	'060DAjuste en Ayuda para anteojos Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'107',	'061DAjuste en Ayuda para transporte Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'108',	'062DAjuste en Ayuda para gastos de funeral Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'109',	'063DAjuste en Otros ingresos por salarios Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'110',	'064DAjuste en Otros ingresos por salarios Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'111',	'065DAjuste en Jubilaciones, pensiones o haberes de retiro Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'112',	'066DAjuste en Jubilaciones, pensiones o haberes de retiro Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'113',	'067DAjuste en Pagos por separación Acumulable'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'114',	'068DAjuste en Pagos por separación No acumulable'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'115',	'069DAjuste en Jubilaciones, pensiones o haberes de retiro Acumulable'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'116',	'070DAjuste en Jubilaciones, pensiones o haberes de retiro No acumulable'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'117',	'071DAjuste en Subsidio para el empleo (efectivamente entregado al trabajador)'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'118',	'072DAjuste en Ingresos en acciones o títulos valor que representan bienes Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'119',	'073DAjuste en Ingresos en acciones o títulos valor que representan bienes Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'120',	'074DAjuste en Alimentación Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'121',	'075DAjuste en Alimentación Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'122',	'076DAjuste en Habitación Exento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'123',	'077DAjuste en Habitación Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'124',	'078DAjuste en Premios por asistencia'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'125',	'079DAjuste en Pagos dist. a los listados y que no deben considerarse como ingreso por sueldos, sal. o ingresos asimilados.'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'126',	'080DAjuste en Viáticos gravados'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'127',	'081DAjuste en Viáticos (entregados al trabajador)'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'128',	'082DAjuste en Fondo de ahorro Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'129',	'083DAjuste en Caja de ahorro Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'130',	'084DAjuste en Prima de Seguro de vida Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'131',	'085DAjuste en Seguro de Gastos Médicos Mayores Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'132',	'086DAjuste en Subsidios por incapacidad Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'133',	'087DAjuste en Becas para trabajadores y/o hijos Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'134',	'088DAjuste en Seguro de retiro Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'135',	'089DAjuste en Vales de despensa Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'136',	'090DAjuste en Vales de restaurante Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'137',	'091DAjuste en Vales de gasolina Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'138',	'092DAjuste en Vales de ropa Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'139',	'093DAjuste en Ayuda para renta Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'140',	'094DAjuste en Ayuda para artículos escolares Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'141',	'095DAjuste en Ayuda para anteojos Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'142',	'096DAjuste en Ayuda para transporte Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'143',	'097DAjuste en Ayuda para gastos de funeral Gravado'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'144',	'098DAjuste a ingresos asimilados a salarios gravados'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'145',	'099DAjuste a ingresos por sueldos y salarios gravados'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFil,	'      ',	'146',	'100DAjuste en Viáticos exentos'})

		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL	With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    	With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

	IncProc(cMsgProc + "S032.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S032')) .OR. !RCB->(dbSeek(cFilRCB+'S035'))
		If (RCB->(dbSeek(cFilRCB+'S032')))
			While RCB->(!Eof()) .AND. RCB->RCB_CODIGO=='S032'
				RECLOCK("RCB",.F.)
					RCB->(DbDelete())
				RCB->(MsUnlock())
				RCB->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := 'S032'

		//		  RCB_FILIAL, 	RCB_CODIGO, 	RCB_DESC, 			RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 	RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Tipo Incapacidad SAT', 	'01', 			'Clave', 			'Clave', 			'C', 			2, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,			cNomeArq,			'Tipo Incapacidad SAT',	'02',			'Desc',			'Descripción',		'C',			100,			0,				'@!',			'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR	With aTabela[nI][10]
				Replace RCB_VALID 	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S032')) ) .OR. !RCC->(dbSeek(cFilRCB+'S035'))
		If (RCC->(dbSeek(cFilRCC+'S032')))
			While RCC->(!Eof()) .AND. RCC->RCC_CODIGO=='S032'
				RecLock("RCC",.F.)
					RCC->(DbDelete())
				RCC->(MsUnlock())
				RCC->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := "S032"

		//INCLUSOS EM P/ DECLARACAO ANUAL DO ANO DE 2010
		//		  RCC_FILIAL,	RCC_CODIGO,		RCC_FIL,	RCC_CHAVE,	RCC_SEQUEN,	RCC_CONTEU
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'001',			'01Riesgo de Trabajo'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'002',			'02Enfermedad General'})
		AAdd(aTabela,{cFilRCC,		cNomeArq,			cFilRCC,		'      ',			'003',			'03Maternidad'})


		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL	With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    	With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

	IncProc(cMsgProc + "S033.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S033')) .OR. !RCB->(dbSeek(cFilRCB+'S035'))
		If (RCB->(dbSeek(cFilRCB+'S033')))
			While RCB->(!Eof()) .AND. RCB->RCB_CODIGO=='S033'
				RecLock("RCB",.F.)
					RCB->(DbDelete())
				RCB->(MsUnlock())
				RCB->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := 'S033'

		//		  RCB_FILIAL, 	RCB_CODIGO, 	RCB_DESC, 			RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 	RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Tipo Banco SAT', 	'01', 			'Clave', 			'Clave', 			'C', 			3, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,			cNomeArq,			'Tipo Banco SAT',	'02',			'Desc',			'Descripción',		'C',			100,			0,				'@!',			'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR 	With aTabela[nI][10]
				Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S033')) ) .OR. !RCC->(dbSeek(cFilRCB+'S035'))
		If (RCC->(dbSeek(cFilRCC+'S033')))
			While RCC->(!Eof()) .AND. RCC->RCC_CODIGO=='S033'
				RecLock("RCC",.F.)
					RCC->(DbDelete())
				RCC->(MsUnlock())
				RCC->(DbSkip())
			EndDo
		EndIf

		aTabela:= {}
		cNomeArq := "S033"

		//INCLUSOS EM P/ DECLARACAO ANUAL DO ANO DE 2010
		//		  RCC_FILIAL,	RCC_CODIGO,		RCC_FIL,	RCC_CHAVE,	RCC_SEQUEN,	RCC_CONTEU
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'001',	'002BANAMEX'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'002',	'006Bancomext'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'003',	'009Banobras'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'004',	'012BBVA Bancomer'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'005',	'014Santander'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'006',	'019BANJERCITO'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'007',	'021HSBC'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'008',	'030Bajío'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'009',	'032IXE'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'010',	'036Inbursa'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'011',	'037Interacciones'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'012',	'042Mifel'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'013',	'044Scotiabank'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'014',	'058BANREGIO'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'015',	'059Invex'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'016',	'060Bansi'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'017',	'062Afirme'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'018',	'072BANORTE'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'019',	'102The Royal Bank'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'020',	'103American Express'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'021',	'106BAMSA'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'022',	'108Tokyo'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'023',	'110JP Morgan'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'024',	'112BMonex'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'025',	'113Ve Por Mas'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'026',	'116ING'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'027',	'124Deutsche'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'028',	'126Credit Suisse'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'029',	'127Azteca'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'030',	'128Autofin'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'031',	'129Barclays'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'032',	'130Compartamos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'033',	'131Banco Famsa'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'034',	'132BMultiva'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'035',	'133Actinver'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'036',	'134Wal-Mart'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'037',	'135NaFin'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'038',	'136InterBanco'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'039',	'137BanCoppel'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'040',	'138ABC Capital'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'041',	'139UBS Bank'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'042',	'140Consubanco'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'043',	'141VolksWagen'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'044',	'143CIBanco'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'045',	'145BBase'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'046',	'166BANSEFI'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'047',	'168Hipotecaria Federal'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'048',	'600MONEXCB'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'049',	'601GBM'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'050',	'602Masari'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'051',	'605Value'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'052',	'606ESTRUCTURADORES'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'053',	'607Tiber'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'054',	'608Vector'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'055',	'610B&B'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'056',	'614ACCIVAL'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'057',	'615Merrill Lynch'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'058',	'616Finamex'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'059',	'617VALMEX'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'060',	'618Unica'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'061',	'619Mapfre'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'062',	'620Profuturo'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'063',	'621CB ACTINVER'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'064',	'622OACTIN'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'065',	'623SKANDIA'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'066',	'626CBDeutsche'})//
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'067',	'627Zurich'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'068',	'628ZurichVi'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'069',	'629Su Casita'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'070',	'630CB Intercam'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'071',	'631CI Bolsa'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'072',	'632Bulltick CB'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'073',	'633Sterling'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'074',	'634Fincomun'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'075',	'636HDI Seguros'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'076',	'637Order'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'077',	'638Akala'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'078',	'640CB JPMorgan'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'079',	'642Reforma'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'080',	'646STP'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'081',	'647Telecom'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'082',	'648Evercore'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'083',	'649Skandia'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'084',	'651SEGMTY'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'085',	'652Asea'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'086',	'653Kuspit'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'087',	'655SOFIEXPRESS'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'088',	'656Unagra'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'089',	'659Opciones Empresariales del Noreste'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'090',	'670Libertad'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'091',	'901Cls'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'092',	'902Indeval'})

		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL		With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    		With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

	IncProc(cMsgProc + "S034.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S034'))

		aTabela:= {}
		cNomeArq := 'S034'

		//		  RCB_FILIAL, 	RCB_CODIGO, 		RCB_DESC, 			RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 		RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Tipo Jornada', 	'01', 			'Clave', 			'Clave', 			'C', 			2, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,		cNomeArq,			'Tipo Jornada',		'02',			'Desc',			'Descripción',		'C',			100,			0,				'@!',			'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR 	With aTabela[nI][10]
				Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S034')) )
		aTabela:= {}
		cNomeArq := "S034"

		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'001',	'01Diurna'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'002',	'02Nocturna'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'003',	'03Mixta'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'004',	'04Por hora'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'005',	'05Reducida'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'006',	'06Continuada'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'007',	'07Partida'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'008',	'08Por turnos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'009',	'99Otra Jornada'})

		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL	With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    	With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

	IncProc(cMsgProc + "S035.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S035'))

		aTabela:= {}
		cNomeArq := 'S035'

		//		  RCB_FILIAL, 	RCB_CODIGO, 		RCB_DESC, 			RCB_ORDEM, 	RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 		RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Origen Recurso', 	'01', 			'Clave', 			'Clave', 			'C', 			2, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,			cNomeArq,			'Origen Recurso',		'02',			'Desc',			'Descripción',		'C',			100,			0,				'@!',			'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR 	With aTabela[nI][10]
				Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S035')) )
		aTabela:= {}
		cNomeArq := "S035"

		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'001',	'IPIngresos Propios'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'002',	'IFIngresos Federales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'003',	'IMIngresos Mixtos'})


		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL	With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    	With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

	IncProc(cMsgProc + "S036.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S036'))

		aTabela:= {}
		cNomeArq := 'S036'

		//		 	 RCB_FILIAL, 	RCB_CODIGO, 	RCB_DESC, 			RCB_ORDEM, 		RCB_CAMPOS, 	RCB_DESCPO, 	RCB_TIPO, 		RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Estado SAT', 		'01', 			'ClaveSAT', 	'Clave SAT', 	'C', 			3, 			0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,		cNomeArq,		'Estado SAT',		'02',			'Clave',		'Clave',		'C',			4,			0,				'@!',		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,		cNomeArq,		'Estado SAT',		'03',			'Desc',			'Descripción',	'C',			100,		0,				'@!',		'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
				Replace RCB_FILIAL	With aTabela[nI][01]
				Replace RCB_CODIGO 	With aTabela[nI][02]
				Replace RCB_DESC   	With aTabela[nI][03]
				Replace RCB_ORDEM  	With aTabela[nI][04]
				Replace RCB_CAMPOS 	With aTabela[nI][05]
				Replace RCB_DESCPO 	With aTabela[nI][06]
				Replace RCB_TIPO   	With aTabela[nI][07]
				Replace RCB_TAMAN  	With aTabela[nI][08]
				Replace RCB_DECIMA 	With aTabela[nI][09]
				Replace RCB_PICTUR 	With aTabela[nI][10]
				Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S036')) )
		aTabela:= {}
		cNomeArq := "S036"

		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'001',	'AGUAGS Aguascalientes'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'002',	'BCNBC  Baja California'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'003',	'BCSBCS Baja California Sur'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'004',	'CAMCAMPCampeche'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'005',	'CHPCHISChiapas'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'006',	'CHHCHIHChihuahua'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'007',	'COACOAHCoahuila'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'008',	'COLCOL Colima'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'009',	'DIFDF  Ciudad de México'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'010',	'DURDGO Durango'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'011',	'GUAGTO Guanajuato'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'012',	'GROGRO Guerrero'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'013',	'HIDHGO Hidalgo'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'014',	'JALJAL Jalisco'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'015',	'MEXMEX Estado de México'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'016',	'MICMICHMichoacán'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'017',	'MORMOR Morelos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'018',	'NAYNAY Nayarit'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'019',	'NLENL  Nuevo León'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'020',	'OAXOAX Oaxaca'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'021',	'PUEPUE Puebla'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'022',	'QUEQRO Querétaro'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'023',	'ROOQROOQuintana Roo'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'024',	'SLPSLP San Luis Potosí'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'025',	'SINSIN Sinaloa'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'026',	'SONSON Sonora'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'027',	'TABTAB Tabasco'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'028',	'TAMTAMPTamaulipas'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'029',	'TLATLAXTlaxcala'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'030',	'VERVER Veracruz'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'031',	'YUCYUC Yucatán'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'032',	'ZACZAC Zacatecas'})

		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
					Replace RCC_FILIAL	With aTabela[nI][01]
					Replace RCC_CODIGO 	With aTabela[nI][02]
					Replace RCC_FIL    	With aTabela[nI][03]
					Replace RCC_CHAVE  	With aTabela[nI][04]
					Replace RCC_SEQUEN 	With aTabela[nI][05]
					Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf


	IncProc(cMsgProc + "S037.")

	DbSelectArea("RCB")
	DbSetOrder(1)
	If !RCB->(dbSeek(cFilRCB+'S037'))

		aTabela:= {}
		cNomeArq := 'S037'

		//		 	 RCB_FILIAL, 		RCB_CODIGO, 	RCB_DESC, 				RCB_ORDEM, 	RCB_CAMPOS, 		RCB_DESCPO, 	RCB_TIPO, 		RCB_TAMAN, 	RCB_DECIMA, 	RCB_PICTUR, RCB_VALID
		aAdd(aTabela,{cFilRCB, 		cNomeArq, 		'Régimen Fiscal', 	'01', 			'Clave', 			'Clave', 		'C', 			3, 				0, 				'@!', 		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,		cNomeArq,		'Régimen Fiscal',		'02',			'Física',			'Física',		'C',			2,				0,				'@!',		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,		cNomeArq,		'Régimen Fiscal',		'03',			'Moral',			'Moral',		'C',			2,				0,				'@!',		'Naovazio()' })
		aAdd(aTabela,{cFilRCB,		cNomeArq,		'Régimen Fiscal',		'04',			'Descripción',	'Descripción','C',			80,				0,				'@!',		'Naovazio()' })

		For nI := 1 To Len(aTabela)
			RecLock('RCB',.T.)
			Replace RCB_FILIAL	With aTabela[nI][01]
			Replace RCB_CODIGO 	With aTabela[nI][02]
			Replace RCB_DESC   	With aTabela[nI][03]
			Replace RCB_ORDEM  	With aTabela[nI][04]
			Replace RCB_CAMPOS 	With aTabela[nI][05]
			Replace RCB_DESCPO 	With aTabela[nI][06]
			Replace RCB_TIPO   	With aTabela[nI][07]
			Replace RCB_TAMAN  	With aTabela[nI][08]
			Replace RCB_DECIMA 	With aTabela[nI][09]
			Replace RCB_PICTUR 	With aTabela[nI][10]
			Replace RCB_VALID  	With aTabela[nI][11]
			RCB->(MsUnLock())
		Next nI
	EndIf

	DbSelectArea("RCC")
	DbSetOrder(1)

	If !( RCC->(dbSeek(cFilRCC+'S037')) )
		aTabela:= {}
		cNomeArq := "S037"

		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'001',	'601NoSíGeneral de Ley Personas Morales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'002',	'603NoSíPersonas Morales con Fines no Lucrativos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'003',	'605SíNoSueldos y Salarios e Ingresos Asimilados a Salarios'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'004',	'606SíNoArrendamiento'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'005',	'608SíNoDemás ingresos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'006',	'609NoSíConsolidación'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'007',	'610NoNoResidentes en el Extranjero sin Establecimiento Permanente en México'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'008',	'611SíNoIngresos por Dividendos (socios y accionistas)'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'009',	'612SíNoPersonas Físicas con Actividades Empresariales y Profesionales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'010',	'614SíNoIngresos por intereses'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'011',	'616SíNoSin obligaciones fiscales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'012',	'620NoSíSociedades Cooperativas de Producción que optan por diferir sus ingresos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'013',	'621SíNoIncorporación Fiscal'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'014',	'622SíSíActividades Agrícolas, Ganaderas, Silvícolas y Pesqueras'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'015',	'623NoSíOpcional para Grupos de Sociedades'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'016',	'624NoSíCoordinados'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'017',	'628NoSíHidrocarburos'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'018',	'607NoSíRégimen de Enajenación o Adquisición de Bienes'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'019',	'629SíNoDe los Regímenes Fiscales Preferentes y de las Empresas Multinacionales'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'020',	'630SíNoEnajenación de acciones en bolsa de valores'})
		AAdd(aTabela,{cFilRCC,	cNomeArq,	cFilRCC,	'      ',	'021',	'615SíNoRégimen de los ingresos por obtención de premios'})

		Begin Transaction

			For nI := 1 To Len(aTabela)
				RecLock('RCC',.T.)
				Replace RCC_FILIAL		With aTabela[nI][01]
				Replace RCC_CODIGO 	With aTabela[nI][02]
				Replace RCC_FIL    		With aTabela[nI][03]
				Replace RCC_CHAVE  	With aTabela[nI][04]
				Replace RCC_SEQUEN 	With aTabela[nI][05]
				Replace RCC_CONTEU 	With aTabela[nI][06]
				RCC->(MsUnLock())
			Next nI

		End Transaction

	EndIf

Return (Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABPERºAutor³ Ademar Fernandes   º Data ³  01/02/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Peru                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TABPER()

Local cFilRCC	:= xFilial("RCC")
Local cFilRCB	:= xFilial("RCB")
Local aTabela	:= {}
Local cNomeArq	:= ""
Local nI		:= 0
Local cMsgProc	:= "Cargamento de Tablas ..."

ProcRegua(15)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S006  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S006')

	aTabela	:=	{}
	cNomeArq := 'S006'
	//													121234567890123456789012345678901234567890123456789012345678901
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01PERSALUD S.A.ENTIDAD PRESTADORA DE SALUD          20514372251'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02PACIFICO S.A.ENTIDAD PRESTADORA DE SALUD          20431115825'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03RIMAC INTENACIONAL S.A.ENTIDAD PRESTADORA DE SALUD20414955020'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04SERVICIOS PROPRIOS                                0          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05MAPFRE PERU S.A.ENTIDAD PRESTADORA DE SALUD       20517182673'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S013  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S013')

	aTabela	:=	{}
	cNomeArq := 'S013'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01TERMINO INDEFINIDO                                  90   1  90   0'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02TERMINO FIJO ATE 1 AÑOS                            365   1 365   3'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03TERMINO FIJO ATE 2 AÑOS                            730   1 730   5'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04TERMINO FIJO ATE 3 AÑOS                           1095   11095  10'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05TERMINO FIJO ATE 5 AÑOS                           1825   11825 999'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S014  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S014')

	aTabela	:=	{}
	cNomeArq := 'S014'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01A PLAZO INDETERMINADO                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02A TIEMPO PARCIAL                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03POR INICIO O INCREMENTO DE ACTIVIDAD              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04POR NECESIDADES DEL MERCADO                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05POR RECONVERCION EMPRESARIAL                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06OCASIONAL                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07DE SUPLENCIA                       			    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08DE EMERGENCIA     							    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','09PARA OBRA DETERMINADA O SERVICO ESPECIFICO        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','10INTERMITENTE                   				    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','11DE TEMPORADA                  				    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','12DE EXPORTACION NO TRADICIONAL 				    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','13DE EXTRANJERO                 				    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','14ADMINISTRATIVO DE SERVICIOS   				    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','99OTROS                         				    '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S018										                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S018')

	aTabela	:=	{}
	cNomeArq := 'S018'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01AVENIDA                       AVE'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02JIRON                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03CALLE                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04PASAJE                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05ALAMEDA                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06MALECON                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07OVALO                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08PARQUE                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','09PLAZA                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','10CARRETERA                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','11BLOCK                            '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S019										                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S019')

	aTabela	:=	{}
	cNomeArq := 'S019'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01URB. URBANIZACION             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02P.J. PUEBLO JOVEN             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03UNIDAD VECINAL                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04C.H. CONJUNTO HABITACIONAL    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05A.H. ASENTAMENTO HUMANO       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06COO. COOPERATIVA              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07RES. RESIDENCIA               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08Z.I. ZONA INDUSTRIAL          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','09GRU. GRUPO                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','10CAS. CASERIO                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','11FND. FUNDO                    '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S025										                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S025')

	aTabela	:=	{}
	cNomeArq := 'S025'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01RENUNCIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02RENUNCIA CON INCENTIVOS                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03DESPIDO O DESTITUCION                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04CESE COLECTIVO                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05JUBILACION                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06INVALIDEZ ABSOLUTA PERMANENTE                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07TERMINACION DE LA OBRA O SERVIC.O VENC. DEL PLAZO '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08MUTUO DISENSO                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','09FALLECIMIENTO                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','10SUSPENSION DE LA PENSION                          '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S027										                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S027')

	aTabela	:=	{}
	cNomeArq := 'S027'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','00DOMICILIO FISCAL              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','01CASA MATRIZ                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','02SUCURSAL                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','03AGENCIA                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','04LOCAL COMERCIAL O DE SERVICIOS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','05SEDE PRODUCTIVA               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','06DEPOSITO (ALMACEN)            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','07OFICINA ADMINISTRATIVA        '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S028										                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S028')

	aTabela	:=	{}
	cNomeArq := 'S028'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01DOC. NACIONAL DE IDENTIDAD    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','04CARNE DE EXTRANJERIA          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','06REG. UNICO DE CONTRIBUYENTES  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','07PASAPORTE                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','11PARTIDA DE NACIMIENTO         '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S029  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S029')

	aTabela	:=	{}
	cNomeArq := 'S029'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','19EJECUTIVO                                        								  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','20OBRERO              								                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','21EMPLEADO                                          							  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','22TRABAJADOR PORTUARIO								                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','23PRACTICANTE SENATI        							                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','24PENSIONISTA O CESANTE   								                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','26PENSIONISTA - LEY28320							                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','27CONSTRUCCION CIVIL							                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','28PILOTO Y COPILOTO DE AVIA.COM.                  								  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','29MARITIMO, FLUVIAL O LACUSTRE								                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','30PERIODISTA							                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','31TRAB.DE LA INDUSTRIA DE CUERO           								          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','32MINERO DE MINA DE SOCAVON								                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','36PESCADOR - LEY 28320								                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','37MINERO DE TAJO ABIERTO                           								  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','38MINERO DE INDUSTRIA MINERA METALURGICA							              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','017','56ARTISTA - LEY DEL ARTISTA - LEY 28131							   				  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','018','64AGRARIO DEPENDENTE - LEY 27360						             			  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','019','65TRABAJADOR ACTIVIDAD ACUICOLA LEY27460      							 	      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','020','66PESCADOR Y PROCESADOR ARTESANAL INDEPENDENTE							  	      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','021','67REG.ESPECIAL D. LEG.1057                    						      		  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','022','70CONDUCTOR DE LA MICROEMPRESA - SEGURO REGULAR							  		  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','023','82FUNCIONARIO PUBLICO                          						   		   	  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','024','83EMPLEADO DE CONFIANZA  					                    		          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','025','84SERVIDOR PUBLICO - DIRECTIVO SUPERIOR						            		  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','026','85SERVIDOR PUBLICO - EJECUTIVO     						       			          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','027','86SERVIDOR PUBLICO - ESPECIALISTA					                      		  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','028','87SERVIDOR PUBLICO - APOYO                                                		  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','029','88PERSONAL DE LA ADMINISTRACION PUBLICA ASIGNACION ESPECIAL - D.U.126-2001		  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','030','98PERSONA QUE GENERA INGRESOS DE CUARTA - QUINTA CATEGORIA                		  '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S030  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S030')

	aTabela	:=	{}
	cNomeArq := 'S030'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','07EDUCACION SECUNDARIA COMPLETA                    			  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','08EDUCACION TECNICA INCOMPLETA                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','09EDUCACION TECNICA COMPLETA                            	  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','10EDUCACION SUPERIOR (INSTITUTO SUPERIOR, ETC) INCOMPLETA     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','11EDUCACION SUPERIOR (INSTITUTO SUPERIOR, ETC) COMPLETA       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','12EDUCACION UNIVERSITARIA INCOMPLETA                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','13EDUCACION UNIVERSITARIA COMPLETA					          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','14GRADO DE BACHILLER							              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','15TITULADO                                        		      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','16ESTUDIOS DE MAESTRIA INCOMPLETA					          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','17ESTUDIOS DE MAESTRIA COMPLETA							      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','18GRADO DE MAESTRIA                       					  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','19ESTUDIOS DE DOCTORADO INCOMPLETO	                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','20ESTUDIOS DE DOCTORADO COMPLETO							  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','21GRADO DE DOCTOR                                  			  '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S032  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S032')

	aTabela	:=	{}
	cNomeArq := 'S032'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','02DECRETO LEY 19990 - SISTEMA NACIONAL DE PENSIONES - ONP     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','03DECRETO LEY 20530 - SISTEMA NACIONAL DE PENSIONES           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','09CAJA DE BENEFICIOS DE SEGURIDAD SOCIAL DEL PESCADOR   	  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','10CAJA DE PENSIONES MILITAR                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','11CAJA DE PENSIONES POLICIAL                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','12OTROS REGIMES PENSIONARIOS                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','21SPP INTEGRA                        				          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','22SPP HORIZONTE     							              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','23SPP PROFUTURO                                   		      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','24SPP PRIMA                      					          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','99SIN REGIMEN PENSIONARIO       						      '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S034  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S034')

	aTabela	:=	{}
	cNomeArq := 'S034'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','10ACTIVO O SUBSIDIADO (EPS/SERV.PROPIOS)                 			         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','12BAJA (EPS/SERV.PROPIOS)                              				         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','14SUSPENSION PERFECTA (EPS/SERV.PROPIOS)             				 		 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','18SIN VINCULO LABORAL CON CONCEPTOS PENDIENTES DE LIQUIDAR (EPS/SERV.PROPIOS)'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','11ACTIVO SUBSIDIADO                                          				 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','12BAJA                                                  			         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','15SUSPENSION PERFECTA                				          				 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','19SIN VINCULO LABORAL CON CONCEPTOS PENDIENTES DE LIQUIDAR				     '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S035  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S035')

	aTabela	:=	{}
	cNomeArq := 'S035'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','0NINGUNO  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','1CANADA   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','2CHILE    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','3CAN      '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S036  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S036')

	aTabela	:=	{}
	cNomeArq := 'S036'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01S.P. SANCION DISCIPLINARIA                                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02S.P. EJERCICIO DEL DERECHO DE HUELGA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03S.P. DETENCION DEL TRABAJADOR, SALVO EL CASO DE CONDENA PRIVATIVA DE LA LIBERTAD'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','04S.P. INHABILITACION ADMINISTRATIVA O JUDICIAL POR PERIODO NO SUPERIOR A 3 MESES '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','05S.P. PERMISO O LICENCIA CONCEDIDOS POR EL EMPLEADOR SIN GOCE DE HABER           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','06S.P. CASO FORTUITO O FUERZA MAYOR                                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','07S.P. FALTA NO JUSTIFICADA                                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','08S.P. POR TEMPORADA O INTERMITENTE                                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','20S.I. ENFERMEDAD O ACCIDENTE (PRIMEROS VEINTE DIAS)                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','21S.I. INCAPACIDAD TEMPORAL (INVALIDEZ, ENFERMEDAD Y ACCIDENTES)                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','22S.I. MATERNIDAD DURANTE EL DESCANSO PRE Y POST NATAL                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','23S.I. DESCANSO VACACIONAL                                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','24S.I. LICENCIA PARA DESEMPENAR CARGO CIVICO Y PARA CUMPLIR CON EL SERVICIO MILITAR OBLIGATORIO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','25S.I. PERMISO Y LICENCIA PARA EL DESEMPENO DE CARGOS SINDICALES                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','26S.I. LICENCIA CON GOCE DE HABER                                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','016','27S.I. DIAS COMPENSADOS POR HORAS TRABAJADAS EN SOBRETIEMPO                       '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TabEQUºAutor³ Erika Kanamori     º Data ³  27/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Equador                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TabEQU()

Local cFilRCC	:= xFilial("RCC")
Local cFilRCB	:= xFilial("RCB")
Local aTabela	:= {}
Local cNomeArq	:= ""
Local nI		:= 0
Local cMsgProc	:= "Cargamento de Tablas ..."

ProcRegua(15)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S003  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S003')

	aTabela	:=	{}
	cNomeArq := 'S003'
	//													121234567890123456789012345678901234567890123456789012345678901
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','001Arabia                        Arabe                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','002Argentina                     Argentina                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','003Brasil                        Brasilera                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','004Canadá                        Canadiense                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','005Chile                         Chilena                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','006Colombia                      Colombiana                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','007Costa Rica                    Costaricense                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','008Cuba                          Cubana                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','009Ecuador                       Ecuatoriana                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','010Espana                        Espanola                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','011Mexico                        Mexicana                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','012Paraguay                      Paraguaya                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','013Peru                          Peruana                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','014Estados Unidos                Estadounidense                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','015','015Venezuela                     Venezolana                    '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S019									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S019')

	aTabela	:=	{}
	cNomeArq := 'S019'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','106 GASTOS DE VIVIENDA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','107 GASTOS DE EDUCACION'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','108 GASTOS DE SALUD'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','109 GASTOS DE VESTIMENTA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','110 GASTOS DE ALIMENTACION'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','106OGASTOS DE VIVIENDA OTROS EMPLEADORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','107OGASTOS DE EDUCACION OTROS EMPLEADORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','108OGASTOS DE SALUD OTROS EMPLEADORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','109OGASTOS DE VESTIMENTA OTROS EMPLEADORES'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','110OGASTOS DE ALIMENTACION OTROS EMPLEADORES'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S020									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S020')

	aTabela	:=	{}
	cNomeArq := 'S020'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','01COSTA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','02ORIENTE'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','03SIERRA'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabela[nI][01]
		Replace RCC_CODIGO With aTabela[nI][02]
		Replace RCC_FIL    With aTabela[nI][03]
		Replace RCC_CHAVE  With aTabela[nI][04]
		Replace RCC_SEQUEN With aTabela[nI][05]
		Replace RCC_CONTEU With aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TABBRAºAutor³ Ademar Fernandes   º Data ³  07/10/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasil                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TABBRA()

Local cFilRCC	:= xFilial("RCC")
Local cFilRCB	:= xFilial("RCB")
Local aTabela	:= {}
Local cNomeArq	:= ""
Local nI		:= 0
Local cMsgProc	:= "Carregamento de Tabelas ..."
Local cFilRCC_Us:= 	Replicate( " ", Len( cFilRCC ) )	 	// A Filial das Tabelas do Brasil devem ter origem compartilhada

ProcRegua(6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S019  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S019')

	aTabela	:=	{}
	cNomeArq := 'S019'
	//													                      1         2         3         4         5         6         7         8         9         0         1         2
	//													          123123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','SJ2DESPEDIDA SEM JUSTA CAUSA, PELO EMPREGADOR'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','JC2DESPEDIDA POR JUSTA CAUSA, PELO EMPREGADOR'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','RA2RESCISAO ANTECIPADA, PELO EMPREGADOR, DO CONTRATO DE TRABALHO POR PRAZO DETERMINADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','FE2RESCISAO DO CONTRATO DE TRABALHO POR FALECIMENTO DO EMPREGADOR INDIVIDUAL SEM CONTINUACAO DA ATIVIDADE DA EMPRESA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','FE1RESCISAO DO CONTRATO DE TRABALHO POR FALECIMENTO DO EMPREGADOR INDIVIDUAL POR OPCAO DO EMPREGADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','RA1RESCISAO ANTECIPADA, PELO EMPREGADO, DO CONTRATO DE TRABALHO POR PRAZO DETERMINADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','SJ1RESCISAO CONTRATUAL A PEDIDO DO EMPREGADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','FT1RESCISAO DO CONTRATO DE TRABALHO POR FALECIMENTO DO EMPREGADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','PD0EXTINCAO NORMAL DO CONTRATO DE TRABALHO POR PRAZO DETERMINADO'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','RI2RESCISAO INDIRETA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','CR0RESCISAO POR CULPA RECIPROCA'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','FM0RESCISAO POR FORCA MAIOR'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S020  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S020')

	aTabela	:=	{}
	cNomeArq := 'S020'
	//													                      1         2         3         4         5         6         7         8         9         0         1         2
	//													          123123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','001SALARIO FIXO                                                                                        SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','002GARANTIA                                                                                            SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','003PRODUCAO                                                                                            NSNS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','004HORAS EXTRAS                                                                                        NSSN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','005HORAS TRABALHADAS NO MES                                                                            NSNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','006PERCENTAGEM                                                                                         SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','007COMISSAO                                                                                            SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','008PREMIOS                                                                                             SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','009MULTA ARTIGO 477 PARAGRAFO 8 CLT - ATRASO PAGAMENTO RESCISAO                                        SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','010VIAGENS                                                                                             SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','011GORJETAS                                                                                            SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','012HORAS ADICIONAL NOTURNO                                                                             NSSN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','013','013INSALUBRIDADE                                                                                       NNSS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','014','014PERICULOSIDADE                                                                                      NNSS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','015','015SOBREAVISO                                                                                          NSSN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','016','016PRONTIDAO                                                                                           NSSN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','017','017GRATIFICACAO                                                                                        SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','018','018ADICIONAL TEMPO SERVICO                                                                             NNSS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','019','019ADICIONAL POR TRANSFERENCIA DE LOCALIDADE DE TRABALHO                                               NNSS'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','020','020SALARIO FAMILIA NO QUE EXCEDER O VALOR LEGAL OBRIGATORIO                                            SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','021','021ABONO OU GRATIFICACAO DE FERIAS, DESDE QUE EXCEDENTE A 20 DIAS DO SALARIO, CONCEDIDO EM VIRTUDE D...SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','022','022DIARIAS PARA VIAGEM, PELO SEU VALOR GLOBAL, QUANDO EXCEDEREM A 50% DA REMUNERACAO DO EMPREGADO, D...SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','023','023AJUDA DE CUSTO - ARTIGO 470 CLT                                                                     SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','024','024ETAPAS, NO CASO DOS MARITIMOS                                                                       SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','025','025LICENCA PREMIO INDENIZADA                                                                           SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','026','026QUEBRA DE CAIXA                                                                                     SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','027','027PARTICIPACAO DO EMPREGADO NOS LUCRO OU RESUTADOS DA EMPRESA, PAGA NOS TERMOS DA LEGISLACAO          SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','028','028INDENIZACAO RECEBIDA A TITULO DE INCENTIVO A DEMISSAO                                               SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','029','029BOLSA APRENDIZAGEM                                                                                  SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','030','030ABONOS DESVINCULADOS DO SALARIO                                                                     SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','031','031GANHOS EVENTUAIS DESVINCULADOS DO SALARIO                                                           SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','032','032REEMBOLSO CRECHE PAGO EM CONFORMIDADE A LEGISLACAO TRABALHISTA                                      SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','033','033REEMBOLSO BABA PAGO EM CONFORMIDADE A LEGISLACAO TRABALHISTA E PREVIDENCIARIA                       SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','034','034GRATIFICACAO SEMESTRAL                                                                              SNNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','035','035NUMERO DE DIAS TRABALHADOS NO MES                                                                   NSNN'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','036','036MULTA DO ART. 476-A, PARAGRAFO 5,DA CLT                                                             SNNN'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S021  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S021')

	aTabela	:=	{}
	cNomeArq := 'S021'
																				  //             1         2         3         4         5
																				  // 12312345678901234567890123456789012345678901234567890
    AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','100RENDAS DE PROPRIEDADE IMOBILIARIA                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','110RENDAS DO TRASPORTE INTERNACIONAL                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','120LUCROS E DIVIDENTOS DISTRIBUIDOS                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','130JUROS                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','140ROYALTIES                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','150GANHOS DE CAPITAL                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','160RENDAS DO TRABALHO SEM VINCULO EMPREGATICIO       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','170RENDA DO TRABALHO COM VINCULO EMPREGATICIO        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','180REMUNERACAO DE ADMINISTRADORES                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','190RENDAS DE ARTISTAS E DE ESPORTISTAS               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','200PENSOES                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','210PAGAMENTOS GOVERNAMENTAIS                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','013','220RENDAS DE PROFESSORES E PESQUISADORES             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','014','230RENDAS DE ESTUDANTES E APRENDIZES                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','015','300OUTRAS RENDAS                                     '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S022  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S022')

	aTabela	:=	{}
	cNomeArq := 'S022'
																				  //             1         2         3         4         5         6         7         8
																				  // 12312345678901234567890123456789012345678901234567890123456789012345678901234567890
    AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','10RETENCAO DO IRRF - ALIQUOTA PADRAO                                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','11RETENCAO DO IRRF - ALIQUOTA DA TABELA PROGRESSIVA                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','12RETENCAO DO IRRF - ALIQUOTA DIFERENCIADA (PAISES TRIBUTACAO FAVORECIDA)          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','13RETENCAO DO IRRF - ALIQUOTA LIMITADA CONFORME CLAUSULA EM CONVENIO               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','30RETENCAO DO IRRF - OUTRAS HIPOTESES                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','40NAO-RETENCAO DO IRRF - ISENCAO ESTABELECIDA EM CONVENIO                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','41NAO-RETENCAO DO IRRF - ISENCAO PREVISTA EM LEI INTERNA                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','42NAO-RETENCAO DO IRRF - ALIQUOTA ZERO PREVISTA EM LEI INTERNA                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','43NAO-RETENCAO DO IRRF - PAGAMENTO ANTECIPADO DO IMPOSTO                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','44NAO-RETENCAO DO IRRF - MEDIDA JUDICIAL                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','50NAO-RETENCAO DO IRRF - OUTRAS HIPOTESES                                          '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S023  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S023')

	aTabela	:=	{}
	cNomeArq := 'S023'
																				  //             1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
																				  // 1231234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','500A FONTE PAGADORA é MATRIZ DA BENEFICIARIA NO EXTERIOR.                                                                                                                                                                                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','510A FONTE PAGADORA é FILIAL, SUCURSAL OU AGENCIA DE BENEFICIARIA NO EXTERIOR.                                                                                                                                                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','520A FONTE PAGADORA é CONTROLADA OU COLIGADA DA BENEFICIARIA NO EXTERIOR, NA FORMA DOS PARAGRAFOS 1º E 2º DO ART. 243 DA LEI Nº 6404, DE 15 DE DEZEMBRO DE 1976.                                                                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','530A FONTE PAGADORA é CONTROLADORA OU COLIGADA DA BENEFICIARIA NO EXTERIOR, NA FORMA DOS PARAGRAFOR 1º E 2º DO ART. 243 DA LEI Nº 6404, DE 15 DE DEZEMBRO DE 1976.                                                                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','540A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR ESTAO SOB CONTROLE SOCIETARIO OU ADMINISTRATIVO COMUM OU QUANDO PELO MENOS 10% DO CAPITAL DE CADA UMA , PERTENCER A UMA MESMA PESSOA FISICA OU JURIDICA.                                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','550A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR TÊM PARTICIPACAO SOCIETARIA NO CAPITAL DE UMA TERCEIRA PESSOA JURIDICA, CUJA SOMA AS CARACTERIZE COMO CONTROLADORAS OU COLIGADAS NA FORMA DOS §§ 1º E 2º DO ART. 243 DA LEI Nº 6.404, DE 15 DE DEZ DE 1976'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','560A FONTE PAGADORA OU A BENEFICIARIA NO EXTERIOR MANTENHA CONTRATO DE EXCLUSIVIDADE COMO AGENTE, DISTRIBUIDOR OU CONCESSIONARIO NAS OPERACOES COM BENS,  SERVICOS E DIREITOS.                                                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','570A FONTE PAGADORA E A BENEFICIARIA MANTÉM ACORDO DE ATUACAO CONJUNTA.                                                                                                                                                                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','900NAO HA RELACAO ENTRE A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR.                                                                                                                                                                                     '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S024  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S024')

	aTabela	:=	{}
	cNomeArq := 'S024'
																				  //             1         2         3         4         5
																				  // 12312345678901234567890123456789012345678901234567890
    AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','001','105BRASIL                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','002','013AFEGANISTAO                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','003','756AFRICA DO SUL                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','004','017ALBANIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','005','023ALEMANHA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','006','037ANDORRA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','007','040ANGOLA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','008','041ANGUILLA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','009','043ANTIGUA BARBUDA                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','010','047ANTILHAS HOLANDESAS                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','011','053ARABIA SAUDITA                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','012','059ARGELIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','013','063ARGENTINA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','014','064ARMENIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','015','065ARUBA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','016','073ARZEBAIJAO, REPUBLICA DO                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','017','069AUSTRALIA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','018','072AUSTRIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','019','077BAHAMAS, ILHAS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','020','080BAHREIN, ILHAS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','021','081BANGLADESH                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','022','083BARBADOS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','023','085BELARUS, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','024','087BELGICA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','025','088BELIZE                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','026','229BENIN                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','027','090BERMUDAS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','028','097BOLIVIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','029','098BOSNIA-HERZEGOVINA                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','030','101BOTSUANA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','031','108BRUNEI                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','032','111BULGARIA, REPUBLICA DA                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','033','031BURKINA FASO                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','034','115BURUNDI                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','035','119BUTAO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','036','127CABO VERDE, REPUBLICA DE                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','037','145CAMAROES                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','038','141CAMBOJA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','039','149CANADA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','040','151CANARIAS, ILHAS                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','041','153CASAQUISTAO, REPUBLICA DO                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','042','154CATAR                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','043','137CAYMAN, ILHAS                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','044','788CHADE                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','045','158CHILE                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','046','160CHINA, REPUBLICA POPULAR                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','047','163CHIPRE                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','048','511CHRISTMAS, ILHAS (NAVIDAD)                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','049','741CINGAPURA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','050','165COCOS-KEELING, ILHAS                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','051','169COLOMBIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','052','173COMORES, ILHAS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','053','177CONGO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','054','888CONGO, REPÚBLICA DEMOCRÁTICA DO                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','055','183COOK, ILHAS                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','056','190COREIA, REPUBLICA                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','057','187COREIA, REPUBLICA POPULAR DEMOCRATICA             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','058','193COSTA DO MARFIM                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','059','196COSTA RICA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','060','198COVEITE                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','061','195CROACIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','062','199CUBA                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','063','998DELEGAÇÃO ESPECIAL DA PALESTINA                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','064','232DINAMARCA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','065','783DJIBUTI                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','066','235DOMINICA, ILHA                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','067','372DUBAI                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','068','237DUBAI                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','069','240EGITO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','070','687EL SALVADOR                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','071','244EMIRADOS ÁRABES UNIDOS                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','072','243ERITREIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','073','239EQUADOR                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','074','247ESLOVACA, REPÚBLICA                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','075','246ESLOVÊNIA, REPÚBLICA DA                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','076','245ESPANHA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','077','249ESTADOS UNIDOS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','078','251ESTÔNIA, REPÚBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','079','253ETIÓPIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','080','255FALKLAND (ILHAS MALVINAS)                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','081','259FEROE, ILHAS                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','082','263FEZZAN                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','083','870FIDJI                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','084','267FILIPINAS                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','085','271FINLANDIA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','086','161FORMOSA(TAIWAN)                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','087','275FRANCA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','088','281GABAO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','089','285GAMBIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','090','289GANA                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','091','291GEORGIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','092','293GIBRALTAR                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','093','297GRANADA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','094','301GRECIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','095','305GROENLANDIA                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','096','309GUADALUPE                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','097','313GUAM                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','098','317GUATEMALA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','099','337GUIANA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','100','325GUIANA FRANCESA                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','101','329GUINE                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','102','334GUINE-BISSAU                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','103','331GUINE-EQUATORIAL                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','104','341HAITI                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','105','345HONDURAS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','106','351HONG KONG                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','107','355HUNGRIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','108','357IEMEM                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','109','361INDIA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','110','365INDONESIA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','111','367INGLATERRA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','112','372IRA, REPUBLICA ISLAMICA DO                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','113','369IRAQUE                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','114','375IRLANDA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','115','379ISLANDIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','116','383ISRAEL                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','117','386ITALIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','118','388IUGOSLAVIA, REPUBLICA FEDERATIVA DA               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','119','391JAMAICA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','120','399JAPAO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','121','150JERSEY, ILHA DO CANAL										 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','122','396JOHNSTON, ILHAS                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','123','403JORDANIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','124','411KIRIBATI                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','125','420LAOS, REPUBLICA POPULAR DEMOCRATICA               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','126','423LEBUAN, ILHAS                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','127','426LESOTO                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','128','427LETONIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','129','431LIBANO                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','130','434LIBERIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','131','438LIBIA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','132','440LIECHTENSTEIN                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','133','442LITUÂNIA, REPÚBLICA DA                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','134','445LUXEMBURGO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','135','447MACAU                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','136','449MACEDÔNIA, ANT.REP.IUGOSLAVA                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','137','450MADAGASCAR                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','138','452MADEIRA, ILHA DA                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','139','455MALÁSIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','140','458MALAVI                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','141','461MALDIVAS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','142','464MALI                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','143','467MALTA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','144','359MAN, ILHA DE                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','145','472MARIANAS DO NORTE                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','146','474MARROCOS                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','147','476MARSHALL, ILHAS                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','148','477MARTINICA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','149','485MAURÍCIO                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','150','488MAURITÂNIA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','151','493MÉXICO                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','152','093MIANMAR (BIRMÂNIA)                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','153','499MICRONÉSIA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','154','490MIDWAY, ILHAS                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','155','505MOÇAMBIQUE                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','156','494MOLDOVA, REPÚBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','157','495MÔNACO                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','158','497MONGÓLIA                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','159','498MONTENEGRO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','160','501MONTSERRAT, ILHAS                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','161','507NAMÍBIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','162','508NAURU                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','163','517NEPAL                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','164','521NICARÁGUA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','165','525NIGER                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','166','528NIGÉRIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','167','531NIUE, ILHA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','168','535NORFOLK, ILHA                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','169','538NORUEGA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','170','542NOVA CALEDONIA                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','171','548NOVA ZELANDIA                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','172','556OMÃ                                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','173','563PACIFICO, ILHAS DO (ADMINIST. DOS EUA)            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','174','566PACIFICO, ILHAS DO (POSSESSAO DOS EUA)            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','175','573PAISES BAIXOS (HOLANDA)                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','176','575PALAU                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','177','580PANAMA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','178','545PAPUA NOVA GUINE                                  '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','179','576PAQUISTAO                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','180','586PARAGUAI                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','181','589PERU                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','182','593PITCAIRN, ILHA DE                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','183','599POLINESIA FRANCESA                                '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','184','603POLONIA, REPUBLICA DA                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','185','611PORTO RICO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','186','607PORTUGAL                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','187','623QUENIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','188','625QUIRGUIZ, REPUBLICA DA                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','189','628REINO UNIDO                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','190','640REPUBLICA CENTRO-AFRICANA                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','191','647REPUBLICA DOMINICANA                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','192','660REUNIAO, ILHA                                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','193','670ROMENIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','194','675RUANDA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','195','676RUSSIA, FEDERACAO DA                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','196','685SAARA OCIDENTAL                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','197','677SALOMAO, ILHAS                                    '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','198','690SAMOA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','199','691SAMOA AMERICANA                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','200','697SAN MARINO                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','201','710SANTA HELENA                                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','202','715SANTA LÚCIA                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','203','678SAINT KITTS E NEVIS                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','204','695SÃO CRISTÓVÃO E NEVES, ILHAS                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','205','700SÃO PEDRO E MIQUELON                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','206','720SÃO TOMÉ E PRÍNCIPE, ILHAS                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','207','705SÃO VICENTE E GRANADINAS                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','208','728SENEGAL                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','209','735SERRA LEOA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','210','737SERVIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','211','731SEYCHELLES                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','212','744SÍRIA, REPÚBLICA ÁRABE DA                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','213','748SOMÁLIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','214','750SRI LANKA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','215','754SUAZILÂNDIA                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','216','759SUDÃO                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','217','764SUÉCIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','218','767SUÍÇA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','219','770SURINAME                                          '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','220','776TAILÂNDIA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','221','772TADJIQUISTÃO, REPÚBLICA DO                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','222','780TANZÂNIA, REPÚBLICA UNIDA DA                      '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','223','791TCHECA, REPÚBLICA                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','224','782TERRITÓRIO BRITÂNICO NO OCEANO ÍNDICO             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','225','795TIMOR LESTE                                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','226','800TOGO                                              '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','227','810TONGA                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','228','805TOQUELAU, ILHAS                                   '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','229','815TRINIDAD E TOBAGO                                 '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','230','820TUNÍSIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','231','823TURCAS E CAICOS, ILHAS                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','232','824TURCOMENISTÃO, REPÚBLICA DO                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','233','827TURQUIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','234','828TUVALU                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','235','831UCRÂNIA                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','236','833UGANDA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','237','845URUGUAI                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','238','847UZBEQUISTÃO, REPÚBLICA DO                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','239','551VANUATU                                           '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','240','848VATICANO, ESTADO DA CIDADE DO                     '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','241','873WAKE, ILHA                                        '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','242','850VENEZUELA                                         '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','243','858VIETNÃ                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','244','863VIRGENS, ILHAS (BRITÂNICAS)                       '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','245','866VIRGENS, ILHAS(EUA)                               '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','246','875WALLIS E FUTUNA, ILHAS                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','247','888ZAIRE                                             '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','248','890ZÂMBIA                                            '})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC_Us,'      ','249','665ZIMBABUE                                          '})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gp310TabAUSºAutor³ Equipe RH Inovacao º Data ³  14/11/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e preenche tabela auxiliar padrao.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Australia                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp310TabAUS()

Local cFilRCC	:= xFilial("RCC")
Local cFilRCB	:= xFilial("RCB")
Local aTabela	:= {}
Local cNomeArq	:= ""
Local nI		:= 0
Local cMsgProc	:= "Load Tables ... Wait!"

ProcRegua(5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S006  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S002')

	aTabela	:=	{}
	cNomeArq := 'S002'
	//													   1231234567890123456789012345678901234567890123456789012345678901
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','001SPAYG Withholding'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','002SSuperannuation'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','003SHELP'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','004SSSFS'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S006  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S006')

	aTabela	:=	{}
	cNomeArq := 'S006'
	//													   1231234567890123456789012345678901234567890123456789012345678901
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','001Cars using the statutory formula'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','002Cars using the operating cost method'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','003Loans granted'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','004Debt waiver'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','005Expense payments'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','006Housing - units of accomodation provided'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','007Employees receiving living-away-from-home allowance'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','008Airline transport'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','009Board'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','010Property'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','011Income tax exempt body - entertainment'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','012','012Other benefits'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','013','013Car parking'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','014','014Meal entertainment'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Tabela S013  									                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(cMsgProc)

DbSelectArea("RCC")
DbSetOrder(1)
If !dbSeek(cFilRCC+'S013')

	aTabela	:=	{}
	cNomeArq := 'S013'
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','001','001Salaries and Wages'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','002','002Allowances'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','003','003Bonuses/Commisions'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','004','004Termination Payments'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','005','005Superannuation'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','006','006Fringe Benefits'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','007','007Aprentice and Trainee Wages'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','008','008Other Taxable Wages'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','009','009Accounts Payable/Services'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','010','010Deduction'})
	AAdd(aTabela,{cFilRCC,cNomeArq,cFilRCC,'      ','011','011Payable Tax'})

	For nI := 1 To Len(aTabela)
		RecLock('RCC',.T.)
		RCC->RCC_FILIAL := aTabela[nI][01]
		RCC->RCC_CODIGO := aTabela[nI][02]
		RCC->RCC_FIL    := aTabela[nI][03]
		RCC->RCC_CHAVE  := aTabela[nI][04]
		RCC->RCC_SEQUEN := aTabela[nI][05]
		RCC->RCC_CONTEU := aTabela[nI][06]
		MsUnLock()
	Next nI
Endif

Return
