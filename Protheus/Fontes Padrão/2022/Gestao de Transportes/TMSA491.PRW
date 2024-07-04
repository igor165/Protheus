#INCLUDE "FileIO.CH"
#INCLUDE "TMSA491.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TMSA491DEA.ch"

	//------------------------------------------------------------------------------------------------------------------------------------//
	/* Os DEFINEs  foram removidos para a "TMSA491DEA.ch" (definição de Estrura de Array), onde estão contidos os defines dos              //
	//Fontes TMSA491/TMSA850/TMSA851.Caso seja necessário a criação de mais Defines favor manter o padrão incluindo no "TMSA491DEA.ch" */ //
	//------------------------------------------------------------------------------------------------------------------------------------//

Static lTM491DT6 	:= ExistBlock('TM491DT6')	//--Ponto de entrada apos a gravacao do Docto. de Transp. (DT6), gerado a partir do Docto. de Apoio
Static lTM491NAT 	:= ExistBlock('TM491NAT')	//--Ponto de entrada para retornar um array com as Naturezas da fatura  
Static lTM491QBR 	:= ExistBlock('TM491QBR')	//--Ponto de entrada para realizar a quebra da Fatura
Static lTM491MNT 	:= ExistBlock('TM491MNT')	//--Ponto de entrada para manipular os Doctos. da Fatura
Static lTMFATFIL 	:= ExistBlock("TMFATFIL")	//--Ponto de entrada para acrescentar condicoes de filtro na query de selecao dos Doctos.
Static lTM491CPO 	:= ExistBlock('TM491CPO')	//--
Static lTM491CLI 	:= ExistBlock('TM491CLI')	//--Ponto de entrada para retornar um array com as Naturezas da fatura por Cliente
Static lTM491TRV 	:= ExistBlock("TM491TRV") //-- Ponto de entrada para tratamento da trava da geracao de doctos.
Static lTM491TIP 	:= ExistBlock("TM491TIP") //-- Ponto de entrada para troca do tipo de faturamento
Static lTM491RISS	:= ExistBlock("TM491RISS") //-- Ponto de entrada para alterar a regra de recolhimento do ISS
Static lTM491MAIL	:= ExistBlock("TM491MAIL") //-- Ponto de entrada para customizar o e-mail de fatura via schedule
Static lDUISEROUT	//-- Serie Outra UF
Static lTMTipFat 	:= ExistBlock("TMTIPFAT")
Static lTM491FAT    := ExistBlock("TM491FAT")
Static lTM850Pref	:= ExistBlock("TM850PREF")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA491  ³ Autor ³Patricia A. Salomao    ³ Data ³17.01.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera fatura com base nos paramentros selecionados.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA491()
Local aArea        := GetArea()
Local aAreaSE1     := SE1->( GetArea() )
Local nCntFor      := 0
Local cTmsERP      := SuperGetMV("MV_TMSERP",,'0')

Local aSetKey := {}

Private cCadastro  := STR0001 //"Faturas a Receber por Documentos de Transporte"
Private aRotina    := MenuDef()

//-- Variaveis utilizadas pelo TMSA850 .. Nao Retirar !!!
Private nValorF    := 0
Private nQtdCtrc   := 0
Private nMoedFat   := 1

Private aMsgSch := {}
Private nTotFat := 0  // total de faturas geradas

If cTmsERP == '1' //-- ERP Datasul
    return TMSA492()
EndIf

If ExecSchedule()
	TmsLogMsg("INFO",STR0050+" - Filial "+cFilAnt+" - "+Dtoc(Date())+" "+Time())
	
	BatchProcess(cCadastro, STR0050 , "TMA490" , { || TMSA491Mnt(.F.) } , { || .F. } )  // "Faturamento Automatico via Schedule"

	// se o parametro nao esta definido, envia as mensagens para o console
	If Empty(GetMv("MV_FATMAIL",, "")) .and. Len(aMsgSch) > 0
		For nCntFor := 1 to Len(aMsgSch)
			TmsLogMsg("INFO",aMsgSch[nCntFor])
		Next
	EndIf

	// processo de envio de email para processamento via schedule
	TM491Mail()

	TmsLogMsg("INFO",STR0050+" - Filial "+cFilAnt+" - "+Dtoc(Date())+" "+Time())  // "Faturamento Automatico via Schedule"
Else

	//--Inicializa as teclas de atalho
	AAdd(aSetKey,  { VK_F12,{|a,b| Pergunte("TMA850",.T.)}} )
	TMSKeyOn(aSetKey)

	MBrowse( ,,,,"SE1",,,,,, TMSA850Leg() )

	//-- Finaliza teclas de atalhos
	TMSKeyOff(aSetKey)
EndIf

RestArea( aArea )
RestArea( aAreaSE1 )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A491PreVld³ Autor ³ Daniel Leme           ³ Data ³17.04.2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pré-Validadao da Geracao de Fatura                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A491PreVld(cNat, cNatRod, cNatAer, cNatFlu)
Local lRet      := .T.
Local cTmsERP   := SuperGetMV("MV_TMSERP",,'0')
Local cPrfx     := ''

Default cNat      := '' //--Natureza da Fatura (Generico)
Default cNatRod   := '' //--Natureza da Fatura Transporte Rodoviario
Default cNatAer   := '' //--Natureza da Fatura Transporte Aereo
Default cNatFlu   := '' //--Natureza da Fatura Transporte Fluvial

If Type("cPrefix") == "U" .Or. Empty(cPrefix)
	cPrefix   := GetMv("MV_FATPREF",, "") // Prefixo da Fatura.
EndIf
If Type("cTipo") == "U" .Or. Empty(cTipo)
	cTipo     := GetMv("MV_TIPFAT" ,, "") // Tipo da Fatura.
EndIf
If Type("cMvSrvFat") == "U" .Or. Empty(cMvSrvFat)
	cMvSrvFat := GetMv("MV_SRVFAT" ,, "") // Servicos da Fatura
EndIf

If cTmsERP == '0' //-- ERP Protheus
	If Empty(cPrefix)
		If ExecSchedule()
			AdicionaMsg(STR0051) // "Prefixo da fatura não informado no parâmetro MV_FATPREF"
		Else
			Help(" ", 1, "TMSA49003") //"Informe o prefixo da fatura MV_FATPREF"
		EndIf
		lRet := .F.
	EndIf
	
	If lTM850Pref
		cPrfx := ExecBlock("TM850PREF",.F.,.F.) //PE para manipular o prefixo da fatura
		If !Empty(cPrfx) .And. ValType(cPrfx) == "C"
			cPrefix := cPrfx
		EndIf
	EndIf
	
	If lRet .And. (Empty(cTipo) .Or. Empty(Tabela("05",cTipo,.F.)))
		If ExecSchedule()
			AdicionaMsg(STR0062) // "Tipo da Fatura inválida no parâmetro MV_TIPFAT"
		Else
			Help(" ", 1, "TMSA49004") // "Tipo da Fatura invalida MV_TIPFAT"
		EndIf
		lRet := .F.
	EndIf
EndIf

If lRet .And. Empty(GetMV("MV_CODCOMP",,""))
	If ExecSchedule()
		AdicionaMsg(STR0053) // "É necessário informar o código do componente de frete referente ao Veículo Dedicado"
	Else
		Help("", 1, "TMSA49104") //"E necessario informar o codigo do componente de frete referente ao Veiculo Dedicado"
	EndIf
	lRet := .F.
ElseIf lRet
	DT3->(DbSetOrder(1)) //--DT3_FILIAL+DT3_CODPAS
	If !DT3->(DbSeek(xFilial('DT3')+Left(GetMV("MV_CODCOMP",,""), Len(DT3->DT3_CODPAS))))
		If ExecSchedule()
			AdicionaMsg(STR0054) // "O componente informado no parâmetro 'MV_CODCOMP' não é um componente válido!"
		Else
			Help("", 1, "TMSA49105") //--"O componente informado no parâmetro 'MV_CODCOMP' não é um componente válido!"
		EndIf
		lRet := .F.
	EndIf
EndIf
If lRet .And. Empty(GetMV("MV_PROGEN",,"")) //--Produto Generico
	If ExecSchedule()
		AdicionaMsg(STR0055) // "E necessário indicar no parâmetro MV_PROGEN o código referente ao produto genérico"
	Else
		Help("", 1, "TMSA49103") //--E necessario indicar no parametro MV_PROGEN o codigo refereten ao produto generico
	EndIf
	lRet := .F.
EndIf

If lRet .And. cTmsERP == '0' //-- ERP Protheus
	//--Valida as Naturezas que serao utilizadas
	If !TMSA491Nat(@cNat, @cNatRod, @cNatAer, @cNatFlu)
		AdicionaMsg(STR0068) // "Problemas nas naturezas. Verifique.") 
		lRet := .F.
	EndIf
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491Mnt³ Autor ³ Patricia Antar Salomao³ Data ³17.01.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao da Geracao de Fatura                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA491Mnt(lHelp)
Local aSays     := {}
Local aButtons  := {}
Local nOpca     := 0
Local cNat      := '' //--Natureza da Fatura (Generico)
Local cNatRod   := '' //--Natureza da Fatura Transporte Rodoviario
Local cNatAer   := '' //--Natureza da Fatura Transporte Aereo
Local cNatFlu   := '' //--Natureza da Fatura Transporte Fluvial
Local lContinua := .T.
Local aArea     := GetArea()
Local cTMA490   := "TMA490"

Default lHelp   := .T.

Private cPrefix   := GetMv("MV_FATPREF",, "") // Prefixo da Fatura.
Private cTipo     := GetMv("MV_TIPFAT" ,, "") // Tipo da Fatura.
Private cMvSrvFat := GetMv("MV_SRVFAT" ,, "") // Servicos da Fatura

nTotFat := 0  // total de faturas geradas - criada na funcao TMSA491

lContinua :=  A491PreVld(@cNat, @cNatRod, @cNatAer, @cNatFlu)

If lContinua
	//--Se nao apresentou nenhuma
	//--inconsistencia, continua o
	//--processo...

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                            ³
	//³ MV_PAR01         // Tp. Faturamento De                          ³
	//³ MV_PAR02         // Tp. Faturamento Ate                         ³
	//³ MV_PAR03         // Cliente De                                  ³
	//³ MV_PAR04         // Loja De                                     ³
	//³ MV_PAR05         // Cliente De                                  ³
	//³ MV_PAR06         // Cliente Ate                                 ³
	//³ MV_PAR07         // Tipo de Frete = 1 = CIF 2 = FOB 3 = Ambos   ³
	//³ MV_PAR08         // Filial de Debito De                         ³
	//³ MV_PAR09         // Filial de Debito Ate                        ³
	//³ MV_PAR10         // Considera Titls Anteriores 1=Sim;2=Nao      ³
	//³ MV_PAR11         // Somente Titls Entregues 1=Sim;2=Nao         ³
	//³ MV_PAR12         // Tipo de Fatura                              ³
	//³ MV_PAR13         // Filial de Documento de ?                    ³
	//³ MV_PAR14         // Filial de Documento ate ?                   ³
	//³ MV_PAR15         // Apenas Docs. Serv. Adic. ?                  ³
	//³ MV_PAR16         // Cód.Negociação De ?                         ³
	//³ MV_PAR17         // Cód.Negociação Ate ?                        ³
	//³ MV_PAR18         // Serviço De ?                                ³
	//³ MV_PAR19         // Serviço Ate ?                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cTMA490, .F.)
	If ExecSchedule()
		nOpca := 1
	Else
		Pergunte(cTMA490, .F.)
		Aadd( aSays, STR0010 )  //"Este programa ira gerar Faturas a Receber a partir dos Documentos de Transporte"
		Aadd( aButtons, { 5, .T., {|| Pergunte(cTMA490, .T.)}}) //TMSA490Param()
		Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End()}})
		Aadd( aButtons, { 2, .T., {|o| o:oWnd:End()}})

		FormBatch( cCadastro, aSays, aButtons )
	EndIf

	If nOpca == 1
		If ExecSchedule()
			lEnd := .T.
			BatchProcess(cCadastro, STR0050 , "TMSA491THR" , { || TMSA491THR(.F.,cNat,cNatRod,cNatAer,cNatFlu,.F.) } , { || .F. } )  // "Faturamento Automatico via Schedule"
		Else
			Processa( {|| TMSA491THR(.F.,cNat,cNatRod,cNatAer,cNatFlu,.T.) }, STR0001, "", .F.) //-- "Faturas a Receber por Documentos de Transporte"		
		EndIf
	EndIf

EndIf

RestArea( aArea )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491THR³ Autor ³SUSTENTACAO/N3-DL      ³ Data ³29.11.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Query para a geracao de Faturas                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA491THR(lEnd,cNat,cNatRod,cNatAer,cNatFlu,lProcessa,aParam854,aDoctos854,aMsg854)
Local lTMSCTe   	:= SuperGetMv( "MV_TMSCTE", .F., .F. )		//-- Parametro do CT-e ativo.
Local lMV_TMSFMSG	:= SuperGetMv("MV_TMSFMSG", .F., .T. )
Local cAliasQRY		:= GetNextAlias()
Local cQuery		:= ''
Local nCntFor		:= 0
Local aMsgFat		:= {}
Local nQtdThr		:= 0 // Quantidade de Threads previstas
Local nThreads		:= SuperGetMv("MV_TMSTHRE", , 0) // Numero de threads para processamento simultaneos
Local nCountThr		:= 0
Local aPrmQry		:= {} // Vetor com os parametros que serao utilizados para execucao da Query
Local aPrm491QRY	:= {} // Vetor contendo os parametros necessarios para a execucao da funcao TMSA491QRY
Local aJobThr		:= {} // Vetor contendo informacoes das Threads.
Local lThread		:= Iif( nThreads > 0, .T., .F.)
Local cJobFile		:= ""
Local cBarra		:= If(issrvunix(), "/", "\") 
Local cStartPath 	:= GetSrvProfString("StartPath","") + If(Right(GetSrvProfString("StartPath",""),1) == cBarra,"",cBarra) // GetSrvProfString("Startpath","")
Local cJobThr		:= ""
Local cSemaforo		:= AllTrim( Str( ThreadID() ) )
Local nIpcCount		:= 0 
Local aTMA490		:= {} 
Local nX			:= 0 
Local aStruct		:= {} 
Local cCodCli		:= ""
Local cLojCli		:= ""
Local cFilDeb		:= ""
Local aObs			:= {} 
Local cTMA490       := "TMA490"

Default lProcessa	:= .F. 
Default aParam854   := {}
Default aDoctos854  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento nao e menor que data limite de ³
//³ movimentacao no financeiro									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If DtMovFin(dDataBase,,"2")
	lContinua := .T.

	If SubStr(cStartPath, Len(cStartPath), 1 ) != '\' .And. SubStr(cStartPath, Len(cStartPath), 1 ) != '/'
		cStartPath := cStartPath + '\'
	EndIf

	If lThread
		///////////////////////////////////////////////////
		// Definicao da quantidade de Threads /////////////
		///////////////////////////////////////////////////
		If Empty(aParam854)
			cQuery := "  SELECT DT6_FILDEB,DT6_CLIDEV,DT6_LOJDEV, COUNT(*) TOTREG "
			cQuery += "    FROM "+RetSqlName("DT6")+ " DT6 "
			cQuery += "    JOIN "+RetSqlName("DUY")+ " DUY "
			cQuery += "      ON DUY.DUY_FILIAL ='"+xFilial("DUY")+"'"
			cQuery += "     AND DUY.DUY_GRPVEN = DT6.DT6_CDRDES "
			cQuery += "     AND DUY.D_E_L_E_T_ = ' '"
		
			If lTMSCTe
				cQuery += "LEFT JOIN "+RetSqlName("DTP")+ " DTP "
				cQuery += " ON  DTP.DTP_FILORI=DT6.DT6_FILDOC "
				cQuery += " AND DTP.DTP_LOTNFC=DT6.DT6_LOTNFC "
				cQuery += " AND DTP.D_E_L_E_T_ = ' ' "
			EndIf
		
			cQuery += " LEFT JOIN "+RetSqlName("DUO")+ " DUO "
			cQuery += "   ON DUO.DUO_FILIAL ='"+xFilial("DUO")+"'"
			cQuery += "  AND DUO.DUO_CODCLI = DT6.DT6_CLIDEV"
			cQuery += "  AND DUO.DUO_LOJCLI = DT6.DT6_LOJDEV"
			cQuery += "  AND DUO.D_E_L_E_T_ = ' '"
		
			If ExistBlock("TMFATJOI")
				cRet :=	ExecBlock("TMFATJOI",.F.,.F., {cQuery, .F.})
				If Valtype(cRet)=="C"
					cQuery += cRet
				EndIf
			EndIf
		
			cQuery += "WHERE DT6.DT6_FILIAL ='"+xFilial("DT6")+"'"
			cQuery += "  AND DT6.DT6_CLIDEV BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"'"
			cQuery += "  AND DT6.DT6_LOJDEV BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"'"
			cQuery += "  AND DT6.DT6_PREFIX ='"+Space(Len(DT6->DT6_PREFIX))+"'"
			cQuery += "  AND DT6.DT6_NUM    ='"+Space(Len(DT6->DT6_NUM))+"'"
			cQuery += "  AND DT6.DT6_TIPO   ='"+Space(Len(DT6->DT6_TIPO))+"'"
			cQuery += "  AND DT6.DT6_FILDEB BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "
		
			If lTMSCTe   // AUTORIZADO O USO DO CTE DT6_SITCTE = '2'
				cQuery += "	AND ((DT6.DT6_SITCTE = '2' AND DTP.DTP_TIPLOT = '3') OR "
				cQuery += "      (DT6.DT6_SITCTE = '1' AND DTP.DTP_TIPLOT = '3') OR "
				cQuery += "      (DT6.DT6_SITCTE = '4' AND DTP.DTP_TIPLOT = '3') OR "
				cQuery += "      (DTP.DTP_TIPLOT = '3' AND DT6.DT6_DOCTMS = '" + StrZero( 5, Len( DT6->DT6_DOCTMS ) ) + "') OR "    //--Nota Fiscal de Serv. de Transp.
				cQuery += "      (DTP.DTP_TIPLOT = '3' AND DT6.DT6_DOCTMS = '" + Replicate('D', Len( DT6->DT6_DOCTMS ) ) + "') OR " //--Nota Fiscal de Reentrega
				cQuery += "      (DTP.DTP_TIPLOT = '3' AND DT6.DT6_DOCTMS = '" + Replicate('F', Len( DT6->DT6_DOCTMS ) ) + "') OR " //--Nota Fiscal de Armazenagem
				cQuery += "      (DTP.DTP_TIPLOT = '3' AND DT6.DT6_DOCTMS = '" + Replicate('G', Len( DT6->DT6_DOCTMS ) ) + "') OR " //--Nota Fiscal de Complemento
		
				cQuery += "      (DT6.DT6_SITCTE = ' ' AND DTP.DTP_TIPLOT = '1') OR "
				cQuery += "      (DT6.DT6_SITCTE = '0' AND DTP.DTP_TIPLOT = '1') OR "
		
				cQuery += "      (DT6.DT6_SITCTE = '4' AND DTP.DTP_TIPLOT = '4') OR "
				cQuery += "      (DT6.DT6_SITCTE = '2' AND DTP.DTP_TIPLOT = '4'))"
			EndIf // ((AUTORIZADO O USO DO CTE e Lote Eletronico) ou (CTRC antigos e Lote Normal))
		
			//-- Verifica o tipo do frete
			If MV_PAR07 <> 3
				cQuery += "  AND DT6.DT6_TIPFRE = '"+Str(MV_PAR07,Len(DT6->DT6_TIPFRE))+"'"
			EndIf
		
			//-- Somente Titls Entregues
			If MV_PAR11 == 1
				cQuery += "  AND DT6.DT6_DATENT <> ' ' "
			EndIf
		
			If Empty(mv_par12) // nTipoDoc == 1 	//-- Documento normal
				cQuery += "  AND DT6.DT6_DOCTMS NOT IN ( '1', 'A', 'B', 'C', 'H', 'I', 'K', 'N', 'O' )"
			Else
				cQuery += "  AND DT6.DT6_DOCTMS = '"+Upper(Alltrim(mv_par12))+"'" //-- Documento de Apoio
				
				If MV_PAR12 $ "B|C|H|I|K|N|O"
					cQuery += "  AND DT6_FILDOC = '" + cFilAnt + "' "
				EndIf
				
			EndIf
			cQuery += "  AND DT6.DT6_MOEDA  = "+AllTrim(Str(nMoedFat,2,0))
			cQuery += "  AND DT6.DT6_SERIE <> 'PED'"
		
			//-- Nao permite FATURAR titulos que tenham solicitacoes de transferencias em aberto.
			cQuery += "  AND DT6.DT6_NUMSOL = ' '"
			cQuery += "  AND DT6.D_E_L_E_T_ = ' '"
		
			//-- Adiciona filtro do usuario
			If lTMFATFIL
				cRetPe := ExecBlock("TMFATFIL",.F.,.F., {cQuery, .F.})
				If Valtype(cRetPe) == "C"
					cQuery += cRetPe
				EndIf
			EndIf

			//+------------------------------------------------------
			//-- FIX20200115 filtro por serviço e/codigo negociação
			//+------------------------------------------------------
			//³ MV_PAR16         // Cód.Negociação De ?
			//³ MV_PAR17         // Cód.Negociação Ate ?
			//³ MV_PAR18         // Serviço De ? 
			//³ MV_PAR19         // Serviço Ate ?
			cQuery += "AND DT6.DT6_CODNEG >= '" + MV_PAR16 + "' "
			cQuery += "AND DT6.DT6_CODNEG <= '" + MV_PAR17 + "' "
			cQuery += "AND DT6.DT6_SERVIC >= '" + MV_PAR18 + "' "
			cQuery += "AND DT6.DT6_SERVIC <= '" + MV_PAR19 + "' "

			cQuery += " GROUP BY DT6_FILDEB, DT6_CLIDEV, DT6_LOJDEV "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQRY,.T.,.T.)
		
			nQtdThr := 0
			nCntFor := 0
			Do While (cAliasQRY)->(!Eof())
				nQtdThr += 1
				nCntFor += (cAliasQRY)->TOTREG
				aAdd(aPrmQry, {(cAliasQRY)->DT6_FILDEB, (cAliasQRY)->DT6_CLIDEV, (cAliasQRY)->DT6_LOJDEV, (cAliasQRY)->TOTREG, MV_PAR12})
				(cAliasQRY)->(DbSkip())
			EndDo
		
			(cAliasQRY)->(DbCloseArea())
		Else
			aPrmQry := Aclone(aParam854)
		EndIf

		cAliasQRY 	:= GetNextAlias()
		cQuery    	:= ''
		nCountThr 	:= 0

		cSemaforo	:= AllTrim( Str( ThreadID() ) )

		If lProcessa
			ProcRegua(nThreads)	
			IncProc( STR0069 ) //"Monitoramento de Threads"	
		EndIf

		//--------------------------------------------------------------------------------
		//-- Tabela de logs - SQLLITE - APENAS PROTHEUS 12
		//--------------------------------------------------------------------------------
		aAdd(aStruct,{"CLIDEV"	,	"C", TamSX3("A1_COD")[1]		, 00})
		aAdd(aStruct,{"LOJDEV"	,	"C", TamSX3("A1_LOJA")[1]		, 00})
		aAdd(aStruct,{"FILDEB"	,	"C", TamSX3("DT6_FILDEB")[1]	, 00})
		aAdd(aStruct,{"MEMO"	,	"M", 50							, 00})

		cJobFile 	:= CriaTrab(Nil,.F.)

		//-- Cria uma tabela no SQLITE
		DBCreate( cJobFile , aStruct, 'SQLITE_TMP' )

		// Coloca a tabela cJobFile em uso
		DBUseArea( .T., 'SQLITE_TMP', cJobFile , 'LOGTMSFAT', .F., .F. )

		//-----------------------------------------------------------------
		//-- Sobe Threads
		//-----------------------------------------------------------------
		For nCntFor := 1 To nThreads

			If lProcessa
				IncProc( STR0069 + " " + Alltrim(Strzero(nCntFor, 6)) + " / " + Alltrim(Strzero(nThreads, 6)) + " ") //"Monitoramento de Threads"	
			EndIf
			
			cJobThr		:= "cThr" + cValToChar(nCntFor) + cJobFile

			//-----------------------------------------------------------------
			//-- Array contendo o nome da thread
			//-----------------------------------------------------------------
			aAdd(aJobThr, {cJobThr, cJobFile, .T., .F., "", TIME(), TIME(), "", "", {}}) // Adiciona o nome do arquivo de Job no array aJobThr
			StartJob("A491Thread", GetEnvServer(), .F. , cSemaforo , cEmpAnt , cFilAnt ,  cJobThr , cJobFile , aParam854 , aDoctos854 , __cUserId )

		Next nCntFor

		If lProcessa
			ProcRegua(Len(aPrmQry))	
			IncProc( STR0073 + " - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) ) //-- Geração de faturas + Total de registros a processar
		EndIf

		//--------------------------------------------------------------------------------
		//-- Array contendo as opções do pergunte TMA490
		//--------------------------------------------------------------------------------

		Pergunte(cTMA490,.F.)
		Aadd( aTMA490 , mv_par01 )
		Aadd( aTMA490 , mv_par02 )
		Aadd( aTMA490 , mv_par03 )
		Aadd( aTMA490 , mv_par04 )
		Aadd( aTMA490 , mv_par05 )
		Aadd( aTMA490 , mv_par06 )
		Aadd( aTMA490 , mv_par07 )
		Aadd( aTMA490 , mv_par08 )
		Aadd( aTMA490 , mv_par09 )
		Aadd( aTMA490 , mv_par10 )
		Aadd( aTMA490 , mv_par11 )
		Aadd( aTMA490 , mv_par12 )
		Aadd( aTMA490 , mv_par13 )
		Aadd( aTMA490 , mv_par14 )
		Aadd( aTMA490 , mv_par15 )
		Aadd( aTMA490 , mv_par16 )
		Aadd( aTMA490 , mv_par17 )
		Aadd( aTMA490 , mv_par18 )
		Aadd( aTMA490 , mv_par19 )

		//--------------------------------------------------------------------------------
		//-- Percorre array com os clientes
		//--------------------------------------------------------------------------------
		For nCntFor := 1 To Len(aPrmQry)
			aPrm491QRY	:= {}

			aAdd(aPrm491QRY,{ cEmpAnt, cFilAnt, lEnd, cNat, cNatRod, cNatAer, cNatFlu, cJobFile, lThread, dDataBase, "" , aPrmQry[nCntFor] }) 

			If lProcessa

				If nCntFor == Int( Len(aPrmQry) * (10/100) )
					IncProc( "10 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )  
				ElseIf nCntFor == Int( Len(aPrmQry) * (20/100) )
					IncProc( "20 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )
				ElseIf nCntFor == Int( Len(aPrmQry) * (30/100) )
					IncProc( "30 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )
				ElseIf nCntFor == Int( Len(aPrmQry) * (40/100) )
					IncProc( "40 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )
				ElseIf nCntFor == Int( Len(aPrmQry) * (50/100) )
					IncProc( "50 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )
				ElseIf nCntFor == Int( Len(aPrmQry) * (60/100) )
					IncProc( "60 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )
				ElseIf nCntFor == Int( Len(aPrmQry) * (70/100) )
					IncProc( "70 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )
				ElseIf nCntFor == Int( Len(aPrmQry) * (80/100) )
					IncProc( "80 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )
				ElseIf nCntFor == Int( Len(aPrmQry) * (90/100) )
					IncProc( "90 %  - " + STR0074  + ": " + cValToChar(Len(aPrmQry)) )
				EndIf
				
			EndIf

			//--------------------------------------------------------------------------------
			//-- Tratamento para verificar se existe thread disponível para processamento
			//--------------------------------------------------------------------------------
			For nX := 1 To NTRYMAX

				//----------------------------------------------------------------------
				//-- Verifico se existe Thread disponível para realizar a chamada do IPCGO
				//----------------------------------------------------------------------
				nIpcCount := IPCCount( cSemaforo )			
				If nIpcCount > 0				
					IPCGo( cSemaforo, aPrm491QRY , 1 , , aTMA490 )
					Exit				
					//---------------------------------------------------------------------------
					//-- Caso não exista Thread aguardo um período antes de tentar novamente o IPCGO
					//---------------------------------------------------------------------------
				Else
					Sleep( 500 )											
				Endif				
			Next nX	

		Next nCntFor 

		//--------------------------------------------------------------------------------
		//-- Mensagens de erro
		//--------------------------------------------------------------------------------	
		If lProcessa
			ProcRegua(Len(aJobThr))	
			IncProc( STR0075 ) //-- "Aguardando término de execução das threads"                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
		EndIf

		If lProcessa
			IncProc( STR0076 ) //-- "Derrubando threads"                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
		EndIf

		//--------------------------------------------------------------------------------
		//-- Tratamento para derrubar threads
		//--------------------------------------------------------------------------------
		nX	:= 0
		For nCntFor := 1 To NTRYMAX
			//----------------------------------------------------------------------
			//-- Verifico se existe Thread disponível para realizar a chamada do IPCGO
			//----------------------------------------------------------------------
			nIpcCount := IPCCount( cSemaforo )			
			If nIpcCount > 0
				nCntFor	:= 1 
				nX++
				IPCGo( cSemaforo,,,"EXIT" )
			Else
				If nX < nThreads 
					Sleep(500) //-- Aguarda término do processamento
				Else
					Exit
				Endif
			Endif				
		Next nCntFor

		//-----------------------------------------------------------------
		//-- Recupera mensagens do log
		//-----------------------------------------------------------------
		If lMV_TMSFMSG

			If lProcessa
				IncProc( STR0077 ) //-- "Exibição de logs"                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
			EndIf
			
			If DBSqlExec( "TMPLOG" , "SELECT * FROM " + cJobFile , 'SQLITE_TMP')
			
				While ("TMPLOG")->( !Eof() )
					
					cCodCli		:= ("TMPLOG")->CLIDEV
					cLojCli		:= ("TMPLOG")->LOJDEV
					cFilDeb		:= ("TMPLOG")->FILDEB
					aObs		:= STRTOKARR( ("TMPLOG")->MEMO , "<#>" ) 
					
					For nX := 1 To Len(aObs)
						aAdd(aMsgFat, { aObs[nX] , "00", "" } )
					Next nX
									
					("TMPLOG")->(dbSkip())
				EndDo
				
				("TMPLOG")->(dbCloseArea())
				
				//-- Exibe mensagens finaisl
				If Len(aMsgFat) > 0
					If aMsg854 != Nil
						aMsg854 := aClone(aMsgFat)
					Else
						TmsMsgErr( aMsgFat, STR0001 ) //"Faturas a Receber por Documentos de Transporte"
					EndIf
				EndIf
			EndIf

		EndIf
		
		//-- Fecha tabela de log
		("LOGTMSFAT")->(dbCloseArea())
		DBSqlExec(cJobFile, 'DROP TABLE ' + cJobFile , 'SQLITE_TMP')

	Else
		aAdd(aPrm491QRY,{ cEmpAnt, cFilAnt, lEnd, cNat, cNatRod, cNatAer, cNatFlu, "", lThread, , {} })
		If aMsg854 == Nil
			TMSA491Qry(@aPrm491QRY, 1 , , , , , , aParam854 , aDoctos854)
		Else
			aMsg854 := TMSA491Qry(@aPrm491QRY, 1 , , , , , , aParam854 , aDoctos854)
		EndIf
	EndIf

Endif

Return Nil

/*/{Protheus.doc} A491Thread
//-- Inicializa threads
@author caio.y
@since 28/08/2017
@version undefined
@param cSemaforo, characters, descricao
@param cEmp, characters, descricao
@param cFil, characters, descricao
@param cJobThr, characters, descricao
@param cJobFile, characters, descricao
@type function
/*/
Function A491Thread( cSemaforo , cEmp , cFil , cJobThr , cJobFile, aParam854, aDoctos854 , cEnvUser )
Local uParm1 , uParm2 
Local cExit			:= ""
Local aTMA490		:= {}
Local nHdThr		:= -1
Local aMsgThread	:= {}
Local aAux			:= {}
Local cUserBkp		:= ""

Default cSemaforo	:= ""
Default cEmp		:= {}
Default cFil		:= "" 
Default cJobThr		:= ""
Default cJobFile	:= ""
Default aParam854   := {}
Default aDoctos854  := {}
Default cEnvUser	:= "" 

//-- Abre o ambiente
RpcSetType(3)
RpcSetEnv( cEmp, cFil, cEnvUser,,'TMS')

BEGIN SEQUENCE

If !Empty(cEnvUser)
	cUserBkp		:= __cUserId
	__cUserId	:= cEnvUser
EndIf 

While !KillApp()

	//-----------------------------------------------------------------
	//-- Variável global
	//-----------------------------------------------------------------
	PutGlbValue(cJobThr, "0")
	GlbUnLock()	

	If IpcWaitEx(cSemaforo,10000, @uParm1, @uParm2, @cExit ,@aTMA490)			
		If cExit == "EXIT"						
			TmsSQlExec( cJobFile, aMsgThread )			
			Exit
		Else			
			//-----------------------------------------------------------------
			//-- Variável global
			//-----------------------------------------------------------------
			PutGlbValue(cJobThr, "1") //-- STATUS 1 - Iniciando execucao do Job
			GlbUnLock()	
			
			aAux	:= Tmsa491Qry(uParm1, uParm2 , nHdThr, cJobThr , aTMA490 , , , aParam854 , aDoctos854)	

			Aadd( aMsgThread , aAux )

			If Len(aMsgThread) > 500
				TmsSQlExec( cJobFile, aMsgThread )	
				aMsgThread	:= {} 
			EndIf
		
			//-- STATUS 3 - Processamento efetuado com sucesso
			PutGlbValue(cJobThr, "3")
			GlbUnLock()			
		EndIf
	EndIf
EndDo

If !Empty(cEnvUser)
	__cUserId	:= cUserBkp
EndIf 

END SEQUENCE

Return

/*/{Protheus.doc} TmsSQlExec
//A função faz a gravação de log utilizando o driver SQLITE - Apenas versão 12
@author caio.y
@since 01/09/2017
@version Protheus 12
@param cJobFile, characters, Nome da tabela criada
@param aMsgThread, array, Array de mensagens
@type function
/*/
Static Function TmsSQlExec( cJobFile, aMsgThread )
Local nCount		:= 1 
Local nAux			:= 1
Local cQuery		:= ""
Local cAux			:= ""
Local cObs			:= ""
Local cCodCli		:= ""
Local cLojCli		:= ""
Local cFilDeb		:= ""
Local lRet			:= .F. 

Default cJobFile	:= ""
Default aMsgThread	:= {}

For nCount := 1 To Len(aMsgThread)

	cCodCli		:= ""
	cLojCli		:= ""
	cFilDeb		:= ""
	cObs		:= ""

	For nAux := 1 To Len(aMsgThread[nCount])

		If nAux == 1 
			cCodCli	:= aMsgThread[nCount][nAux][1]		
			cLojCli	:= aMsgThread[nCount][nAux][2]		
			cFilDeb	:= aMsgThread[nCount][nAux][3]
		ElseIf nAux	> 1 
			//-- Caracter utilizado para quebra de linha
			If !Empty(cObs)
				cObs	+= "<#>"
			EndIf
			
			cObs	+= RTrim( aMsgThread[nCount][nAux][1] )
		EndIf

	Next nAux

	If !Empty(cAux)
		cAux	+= ", "
	EndIf

	If !Empty(cObs) .And. !Empty(cCodCli)
		cAux	+= "( '"+ cCodCli + "','" + cLojCli + "','"+ cFilDeb + "','" + cObs + "'  )"
	EndIf

Next nCount

If !Empty(cAux)
	cQuery	:= " INSERT INTO " + cJobFile 
	cQuery	+= " (CLIDEV,LOJDEV,FILDEB,MEMO) VALUES "
	cQuery	+= cAux
	If DBSqlExec( cJobFile , cQuery , 'SQLITE_TMP')			
			lRet	:= .T. 
		EndIf
	EndIf

Return lRet
/*/{Protheus.doc} Tmsa491Qry
//Query para a geracao de Faturas 
@author Patricia Antar Salomao
@since 17/01/2005
@version undefined
@param aPrm491QRY, array, descricao
@param nPosPrm, numeric, descricao
@param nPosAte, numeric, descricao
@param nHdThr, numeric, descricaol
@param aTMA490, array, descricao
@type function
/*/
Function Tmsa491Qry(aPrm491QRY, nPosPrm , nHdThr , cNameThr , aTMA490, aDocChv, nPosDoc, aParam854, aDoctos854)
Local aAreaDT6     	:= {}
Local cAliasQRY    	:= ''
Local cQuery       	:= ''
Local cAliasDT6		:= ''
Local cTipTra      	:= ''
Local cFlagEnt     	:= ''
Local cEstDest     	:= ''
Local cCodCli      	:= ''
Local cLojCli      	:= ''
Local cGrpProd     	:= ''
Local cCodServ     	:= ''
Local cCondPag     	:= ''
Local cChave       	:= ''
Local aChave       	:= {}
Local aTipFat      	:= {}
Local dDtaFilDe    	:= CToD('')
Local dDtaFilAte   	:= CToD('')
Local nMoedFat     	:= 1
Local lFatCli      	:= .T.
Local aCliErr      	:= {}
Local cCliDev      	:= ''
Local cLojDev      	:= ''
Local aCampos      	:= {}
//-- Variaveis do perfil do cliente
Local nQtdCTR      	:= 0
Local nValMax      	:= 0
Local cTipFat      	:= ''
Local cBasFat      	:= ''
Local cCpvEnt      	:= ''
Local cSepPro      	:= ''
Local cSepEst      	:= ''
Local cSepDoc      	:= ''
Local cSepTra      	:= ''
Local cSepFre      	:= ''
Local cSepRem      	:= ''
Local cSepEnt      	:= ''
Local lConsTitAnt  	:= .F.
Local dDtaEmissao  	:= Ctod('')
Local cCposUsr     	:= ''
Local cDocTms      	:= ''
Local cFilDeb      	:= ''
Local dBaseAux     	:= 0
Local cSepSrv      	:= ''
Local aVFContr     	:= {}
Local aRetPe       	:= {}
Local nCntFor      	:= 0
Local lContinua    	:= .T.
Local lMostra      	:= (!ExecSchedule())  // controla a chamada pelo Schedule e nao mostra a tela de faturas neste caso
Local lTMSCTe      	:= .F. // SuperGetMv( "MV_TMSCTE", .F., .F. )		//-- Parametro do CT-e ativo. // VOLTAR
Local aPrmContr    	:= {} // Vetor com todos os parametros fornecidos a funcao TMSContrat
Local aPrmPerfil   	:= {} // Vetor com todos os parametros fornecidos a funcao TmsPerfil
Local aMsgFat      	:= {}
Local cNat         	:= IIf( Len(aPrm491QRY) > 0 ,aPrm491QRY[nPosPrm,  4] ,"")
Local cNatRod      	:= IIf( Len(aPrm491QRY) > 0 ,aPrm491QRY[nPosPrm,  5] ,"")
Local cNatAer      	:= IIf( Len(aPrm491QRY) > 0 ,aPrm491QRY[nPosPrm,  6] ,"")
Local cNatFlu      	:= IIf( Len(aPrm491QRY) > 0 ,aPrm491QRY[nPosPrm,  7] ,"")
Local cJobThr      	:= ""
Local cFilDB       	:= ""
Local cClDev       	:= ""
Local cLjDev      	:= ""
Local cTpDoc       	:= ""
Local lRet         	:= .F.
Local lFat         	:= .T.
Local cTipFatPE    	:= ""
Local aCliCalc     	:= {}
Local lCONTDOC	 	:= .F. 
//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.     
Local cTmsERP      	:= ""
Local lDocSrvAdd   	:= .F.
Local lSrvAdd     	 := .F.
Local nValDecr     	:= 0
Local aMsgAux		:= {}

Local cCodNeg       := ""
Local lTmsa854 		:= .F.
Local lSepNeg 		:= DUO->(ColumnPos('DUO_SEPNEG')) > 0  
Local cTMA490       := "TMA490"

Default cNat       	:= ''
Default cNatRod    	:= ''
Default cNatAer    	:= ''
Default cNatFlu    	:= ''
Default nHdThr     	:= -1
Default cNameThr	:= ""
Default aTMA490		:= {} 
Default aDocChv 	:= {}
Default nPosDoc 	:= 0
Default aParam854   := {}
Default aDoctos854  := {}

Private cCliQbr		:= ''
Private cLojQbr		:= ''
Private lCliQbr		:= .F.
Private cTipFre		:= ''
Private cTipFreDv	:= ''
Private lSepNovo	:= .F.
Private cTipo      := '' // Tipo da Fatura.
Private cPrefix    := '' // Prefixo da Fatura.
Private aFatCli    := {} // Faturas por clientes
Private aMsgErr    := {}
Private cDocFat    := ''
Private cDUYEST    := ''
Private cMarca     := '' //GetMark()
Private aDocs	   := {}

Private lThread    := IIf( Len(aPrm491QRY) > 0 ,aPrm491QRY[nPosPrm,  9] ,.F.)

lTmsa854 := !Empty(aDoctos854) //--Variaveis vindas do TMSA854

Pergunte(cTMA490, .F.)

//--Quando for chamado do TMSA854, tem que manter os conteudos default pois a rotina ja faz filtro por documento
If lTmsa854 

	//| ordena do menor para o maior necessário para configurar o cliente devedor DE e ATE
	aParam854 := ASort(aParam854,,,{|K,J| K[2]+K[3] < J[2]+J[3]})

	MV_PAR03 := aParam854[1,2]						//-- Codigo Devedor De
	MV_PAR04 := aParam854[1,3]					 	//-- Loja Devedor De
	MV_PAR05 := aParam854[Len(aParam854),2]         //-- Codigo Devedor Ate
	MV_PAR06 := aParam854[Len(aParam854),3]			//-- Loja Devedor Ate
	MV_PAR07 := 3 									//-- Ambos

	//| Volta a configuração considerando a filial de debito
	aParam854 := ASort(aParam854,,,{|K,J| K[1] < J[1]})

	MV_PAR08 := Space(Len(DT6->DT6_FILDEB)) 		//-- Filial de Débito De  // aParam854[1,1]
	MV_PAR09 := Replicate("Z",Len(DT6->DT6_FILDEB)) //-- Filial de Débito Ate // aParam854[Len(aParam854),1]
	MV_PAR10 := 1 									//-- Considera titulos anteriores - Sim
	MV_PAR11 := 2									//-- Somente titulos entregues - Nao	
	MV_PAR12 := ""									//-- Tipo de Documentos
	MV_PAR13 := Space(Len(DT6->DT6_FILDOC))			//-- Fil.Docto De.
	MV_PAR14 := Replicate("Z",Len(DT6->DT6_FILDOC)) //-- Fil.Docto Ate.
EndIf

If lThread 
	cJobThr		:= cNameThr
	cFilDB  	:= aPrm491QRY[nPosPrm, Len(aPrm491QRY[nPosPrm]), 1]
	cClDev  	:= aPrm491QRY[nPosPrm, Len(aPrm491QRY[nPosPrm]), 2]
	cLjDev  	:= aPrm491QRY[nPosPrm, Len(aPrm491QRY[nPosPrm]), 3]
	cTpDoc  	:= aPrm491QRY[nPosPrm, Len(aPrm491QRY[nPosPrm]), 5]
	dDataBase	:= aPrm491QRY[nPosPrm, 10]
	lDocSrvAdd  := aTMA490[15] == 1 
	lConsTitAnt := aTMA490[10] == 1
Else
	lDocSrvAdd  := (MV_PAR15 == 1)
	lConsTitAnt := (MV_PAR10 == 1)
EndIf

lCONTDOC	:= SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
cTmsERP  	:= SuperGetMV("MV_TMSERP",,'0')
cPrefix		:= SuperGetMv("MV_FATPREF",, "") // Prefixo da Fatura.

If lTM850Pref
	cPrfx := ExecBlock("TM850PREF",.F.,.F.) //PE para manipular o prefixo da fatura
	If !Empty(cPrfx) .And. ValType(cPrfx) == "C"
		cPrefix := cPrfx
	EndIf
EndIf

cTipo		:= SuperGetMv("MV_TIPFAT" ,, "") // Tipo da Fatura.
aAreaDT6    := DT6->(GetArea())
cAliasQRY   := GetNextAlias()
lTMSCTe		:= SuperGetMv( "MV_TMSCTE", .F., .F. )		//-- Parametro do CT-e ativo.
cMarca		:= GetMark()
lSepNovo    := Len ( RetSx3Box( GetSX3Cache("DUO_SEPREM","X3_CBOX"),,, 1 ) ) > 3
dBaseAux    := dDataBase
aMsgErr		:= {} 

aCampos		:= {	{"DT6_FILDOC"	, PesqPict("DT6","DT6_FILDOC")},;
					{"DT6_DOC"		, PesqPict("DT6","DT6_DOC"   )},;
					{"DT6_SERIE"	, PesqPict("DT6","DT6_SERIE" )},;
					{"DT6_VALTOT"	, PesqPict("DT6","DT6_VALTOT")},;
					{"DT6_ACRESC"	, PesqPict("DT6","DT6_ACRESC")},;
					{"DT6_DECRES"	, PesqPict("DT6","DT6_DECRES")},;
					{"_SI_VALFAT"	, PesqPict("DT6","DT6_VALFRE")},;
					{"DT6_DATEMI"	, PesqPict("DT6","DT6_DATEMI")},;
					{"_SI_UFDEST"	, PesqPict("SA1","A1_EST"    )}}

DbSelectArea("DV0")

If lThread 
	//-- STATUS 2 - Conexao efetuada com sucesso
	PutGlbValue(cJobThr, "2")
	GlbUnLock()
EndIf

//-- Apresenta campos do usuario
If lTM491CPO
	cCposUsr := ExecBlock('TM491CPO',.F.,.F., {1} )
	If ValType(cCposUsr) <> 'C'
		cCposUsr := ''
	EndIf
EndIf
cQuery := AllTrim(cCposUsr)

// Adiciona os campos que existirem no DT6 na matriz de campos a serem selecionados
aEval(aCampos,{|e| If(DT6->(FieldPos(e[1])) > 0 , cQuery += ","+AllTrim(e[1]), Nil)})

cQuery := "SELECT " + SubStr(cQuery,2) + ","
cQuery +=         "DT6_DOCTMS, DT6_TIPTRA, DT6_TIPFRE, DT6_VENCTO, DT6_DATEMI, DT6_DATENT, DT6_VALFRE, "
cQuery +=         "DT6_FILDEB, DT6_CLIDEV, DT6_LOJDEV, DT6_CLIREM, DT6_LOJREM, DT6_CLIDES, DT6_LOJDES, "
cQuery +=		  	 "DT6_CDRORI, DT6_CDRDES, DT6_CDRCAL, "
cQuery +=         "DT6_CLICON, DT6_LOJCON, DT6_CLICAL, DT6_LOJCAL, DT6_CLIDPC, DT6_LOJDPC, DT6_SERVIC, DT6.R_E_C_N_O_ NRECNO, "
cQuery +=         "DUY_EST UFQBR, DUO_CODCLI, DUO_LOJCLI, DUO_TIPFAT, DUO_QTDCTR, DUO_VALMAX, "
cQuery +=         "DUO_BASFAT, DUO_CPVENT, DUO_SEPPRO, DUO_SEPEST, DUO_SEPDOC, DUO_SEPTRA, DUO_SEPFRE, "
cQuery +=         "DT6_LOTCET, DT6_VALFAT, DUO_SEPREM, DUO_SEPENT, DT6_SERTMS, F2_TIPO "

If lSepNeg
	cQuery += ", DUO_SEPSRV, DUO_SEPNEG "
Else
	cQuery += ", DUO_SEPSRV "
EndIf
cQuery += ", DT6_CODNEG "

//| #AddNewFields
cQuery += ", DT6_CLIEXP "
cQuery += ", DT6_LOJEXP "
cQuery += ", DT6_CLIREC "
cQuery += ", DT6_LOJREC "

cQuery += " FROM "+RetSqlName("DT6")+ " DT6 "

cQuery += " JOIN "+RetSqlName("DUY")+ " DUY "
cQuery += "   ON DUY.DUY_FILIAL ='"+xFilial("DUY")+"'"
cQuery += "  AND DUY.DUY_GRPVEN = DT6.DT6_CDRDES "
cQuery += "  AND DUY.D_E_L_E_T_ = ' '"

If lTMSCTe
	cQuery += " LEFT JOIN "+RetSqlName("DTP")+ " DTP "
	cQuery += "  ON  DTP.DTP_FILORI=DT6.DT6_FILDOC "
	cQuery += "  AND DTP.DTP_LOTNFC=DT6.DT6_LOTNFC "
	cQuery += "  AND DTP.D_E_L_E_T_ = ' ' "
EndIf

cQuery += " LEFT JOIN "+RetSqlName("DUI")+ " DUI "
cQuery += "   ON DUI.DUI_FILIAL ='"+xFilial("DUI")+"'"
cQuery += "  AND DUI.DUI_DOCTMS = DT6.DT6_DOCTMS "
cQuery += "  AND DUI.D_E_L_E_T_ = ' ' "
	
cQuery += " LEFT JOIN "+RetSqlName("DUO")+ " DUO "
cQuery += "   ON DUO.DUO_FILIAL ='"+xFilial("DUO")+"'"
cQuery += "  AND DUO.DUO_CODCLI = DT6.DT6_CLIDEV"
cQuery += "  AND DUO.DUO_LOJCLI = DT6.DT6_LOJDEV"
cQuery += "  AND DUO.D_E_L_E_T_ = ' '"

cQuery += " JOIN "+RetSqlName("SF2")+ " SF2 "
If !Empty(xFilial('SF2'))	//-- Arquivo SF2 criado em modo exclusivo
	cQuery += " ON  SF2.F2_FILIAL  = DT6.DT6_FILDOC"
Else
	cQuery += " ON  SF2.F2_FILIAL  = '"+xFilial("SF2")+"'"
EndIf
cQuery += "  AND SF2.F2_DOC = DT6.DT6_DOC"
cQuery += "  AND SF2.F2_SERIE = DT6.DT6_SERIE"
cQuery += "  AND SF2.D_E_L_E_T_ = ' '"

If ExistBlock("TMFATJOI")
	cRet := ExecBlock("TMFATJOI",.F.,.F., {cQuery, .F.})
	If Valtype(cRet)=="C"
		cQuery += cRet
	EndIf
EndIf

cQuery += "WHERE DT6.DT6_FILIAL ='"+xFilial("DT6")+"'"

If lThread
	If !Empty(aTMA490[13]) .Or. !Empty(aTMA490[14])
		cQuery += " AND DT6.DT6_FILDOC BETWEEN '" + aTMA490[13]+ "' AND '" + aTMA490[14] + "'"
	EndIf
	cQuery += "  AND DT6.DT6_CLIDEV = '" + cClDev + "'"
	cQuery += "  AND DT6.DT6_LOJDEV = '" + cLjDev + "'"
	cQuery += "  AND DT6.DT6_PREFIX = '" + Space(Len(DT6->DT6_PREFIX)) + "'"
	cQuery += "  AND DT6.DT6_NUM    = '" + Space(Len(DT6->DT6_NUM)) + "'"
	cQuery += "  AND DT6.DT6_TIPO   = '" + Space(Len(DT6->DT6_TIPO)) + "'"
	cQuery += "  AND DT6.DT6_FILDEB = '" + cFilDB + "'"
	If Empty(cTpDoc) // nTipoDoc == 1 	//-- Documento normal
		cQuery += "  AND DT6.DT6_DOCTMS NOT IN ( '1', 'A', 'B', 'C', 'H', 'I', 'K', 'N', 'O' )"
	Else
		cQuery += "  AND DT6.DT6_DOCTMS = '"+Upper(Alltrim(cTpDoc))+"'" //-- Documento de Apoio 
		If cTpDoc $ "B|C|H|I|K|N|O"
			cQuery += "  AND DT6_FILDOC = '" + cFilAnt + "' "
		EndIf
	EndIf
Else
	If (!Empty(MV_PAR13) .Or. !Empty(MV_PAR14))
		cQuery += " AND DT6.DT6_FILDOC BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "'"
	EndIf
	cQuery += "  AND DT6.DT6_CLIDEV BETWEEN '" + MV_PAR03+"' AND '" + MV_PAR05+"'"
	cQuery += "  AND DT6.DT6_LOJDEV BETWEEN '" + MV_PAR04+"' AND '" + MV_PAR06+"'"
	cQuery += "  AND DT6.DT6_PREFIX ='" + Space(Len(DT6->DT6_PREFIX))+"'"
	cQuery += "  AND DT6.DT6_NUM    ='" + Space(Len(DT6->DT6_NUM))+"'"
	cQuery += "  AND DT6.DT6_TIPO   ='" + Space(Len(DT6->DT6_TIPO))+"'"
	cQuery += "  AND DT6.DT6_FILDEB BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "

	If Empty(mv_par12) // nTipoDoc == 1 	//-- Documento normal
		cQuery += "  AND DT6.DT6_DOCTMS NOT IN ( '1', 'A', 'B', 'C', 'H', 'I', 'K', 'N', 'O' )"
	Else
		cQuery += "  AND DT6.DT6_DOCTMS = '"+Upper(Alltrim(mv_par12))+"'" //-- Documento de Apoio 
		If mv_par12 $ "B|C|H|I|K|N|O"
			cQuery += "  AND DT6_FILDOC = '" + cFilAnt + "' "
		EndIf
	EndIf
EndIf

//+------------------------------------------------------
//-- FIX20200115 filtro por serviço e/codigo negociação
//+------------------------------------------------------
//³ MV_PAR16         // Cód.Negociação De ?
//³ MV_PAR17         // Cód.Negociação Ate ?
//³ MV_PAR18         // Serviço De ? 
//³ MV_PAR19         // Serviço Ate ?
If lThread
	cQuery += "AND DT6.DT6_CODNEG >= '" + aTMA490[16] + "' "
	cQuery += "AND DT6.DT6_CODNEG <= '" + aTMA490[17] + "' "
	cQuery += "AND DT6.DT6_SERVIC >= '" + aTMA490[18] + "' "
	cQuery += "AND DT6.DT6_SERVIC <= '" + aTMA490[19] + "' "
Else
	cQuery += "AND DT6.DT6_CODNEG >= '" + MV_PAR16 + "' "
	cQuery += "AND DT6.DT6_CODNEG <= '" + MV_PAR17 + "' "
	cQuery += "AND DT6.DT6_SERVIC >= '" + MV_PAR18 + "' "
	cQuery += "AND DT6.DT6_SERVIC <= '" + MV_PAR19 + "' "
EndIf

If lTMSCTe   // AUTORIZADO O USO DO CTE DT6_SITCTE = '2'
	cQuery += "	AND ((DT6.DT6_SITCTE = '2'   AND DTP.DTP_TIPLOT = '3') OR (DT6.DT6_SITCTE = ' ' AND DTP.DTP_TIPLOT = '1')"
	cQuery += " OR   (DT6.DT6_SITCTE = '0'   AND DTP.DTP_TIPLOT = '1') OR (DT6.DT6_SITCTE = '1' AND DTP.DTP_TIPLOT = '3')"
	cQuery += " OR   (DT6.DT6_SITCTE = '4'   AND DTP.DTP_TIPLOT = '3') "
	cQuery += " OR   (DT6.DT6_SITCTE = '4'   AND DTP.DTP_TIPLOT = '4') OR (DT6.DT6_SITCTE = '2' AND DTP.DTP_TIPLOT = '4') OR (DT6.DT6_SITCTE = '0' AND DUI_DOCFAT <> ' '))"
EndIf // ((AUTORIZADO O USO DO CTE e Lote Eletronico) ou (CTRC antigos e Lote Normal))

If lThread 
	//-- Verifica o tipo do frete
	If aTMA490[7] <> 3
		cQuery += "  AND DT6.DT6_TIPFRE = '"+Str(aTMA490[7],Len(DT6->DT6_TIPFRE))+"'"
	EndIf

	//-- Somente Titulos Entregues
	If aTMA490[11] == 1
		cQuery += "  AND DT6.DT6_DATENT <> ' ' "
	EndIf
Else
	//-- Verifica o tipo do frete
	If MV_PAR07 <> 3
		cQuery += "  AND DT6.DT6_TIPFRE = '"+Str(MV_PAR07,Len(DT6->DT6_TIPFRE))+"'"
	EndIf

	//-- Somente Titulos Entregues
	If MV_PAR11 == 1
		cQuery += "  AND DT6.DT6_DATENT <> ' ' "
	EndIf
EndIf

cQuery += "  AND DT6.DT6_MOEDA  = "+AllTrim(Str(nMoedFat,2,0))
cQuery += "  AND DT6.DT6_SERIE <> 'PED'"
cQuery += " AND DT6.DT6_STATUS NOT IN ('9','C','B')"

//-- Nao permite FATURAR titulos que tenham solicitacoes de transferencias em aberto.
cQuery += "  AND DT6.DT6_NUMSOL = ' '"
cQuery += "  AND DT6.D_E_L_E_T_ = ' '"

//-- Apenas documentos de cobrança de serviço adicional
If lDocSrvAdd
	cQuery += " AND EXISTS (SELECT 1 FROM " + RetSqlName("DY4") + " DY4 "
	cQuery += "                     WHERE DT6.DT6_DOCTMS = '" + StrZero(5, Len(DC5->DC5_DOCTMS)) + "' "
	cQuery += "                       AND DY4.DY4_FILIAL = '" + xFilial("DY4") + "' "
	cQuery += "                       AND DY4.DY4_FILDOC = DT6.DT6_FILDOC"
	cQuery += "                       AND DY4.DY4_DOC    = DT6.DT6_DOC"
	cQuery += "                       AND DY4.DY4_SERIE  = DT6.DT6_SERIE"
	cQuery += "                       AND DY4.D_E_L_E_T_ = ' ') "
EndIf

//-- Adiciona filtro do usuario
If lTMFATFIL
	cRetPe := ExecBlock("TMFATFIL",.F.,.F., {cQuery, .F.})
	If Valtype(cRetPe) == "C"
		cQuery += cRetPe
	EndIf
EndIf

cQuery += " ORDER BY DT6_FILDEB,DT6_CLIDEV,DT6_LOJDEV,NRECNO"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQRY,.T.,.T.)

cAliasDT6 := cAliasQRY

TCSetField(cAliasQRY,"DUO_QTDCTR","N",14,2)
TCSetField(cAliasQRY,"DUO_VALMAX","N",14,2)
TCSetField(cAliasQRY,"DT6_VALTOT","N",14,2)
TCSetField(cAliasQRY,"DT6_ACRESC","N",14,2)
TCSetField(cAliasQRY,"DT6_DECRES","N",14,2)
TCSetField(cAliasQRY,"DT6_VALFRE","N",14,2)
TCSetField(cAliasQRY,"DT6_DATEMI","D",08,0)
TCSetField(cAliasQRY,"DT6_DATENT","D",08,0)
TCSetField(cAliasQRY,"DT6_VENCTO","D",08,0)

Do While (cAliasQRY)->(!Eof())
	dDataBase:= dBaseAux
	cFilDeb  := (cAliasQRY)->DT6_FILDEB
	cCliDev  := (cAliasQRY)->DT6_CLIDEV
	cLojDev  := (cAliasQRY)->DT6_LOJDEV
	cTipFat  := Space(Len(DUO->DUO_TIPFAT))

	If lThread 
		If aScan(aMsgAux, {|x| x[1] + x[2] + x[3] == cCliDev + cLojDev + cFilDeb } ) == 0 
			Aadd( aMsgAux , { cCliDev , cLojDev , cFilDeb }  )
		EndIf		
	EndIf

	If !TMSAVerAge("1",(cAliasQRY)->DT6_FILDOC,(cAliasQRY)->DT6_DOC,(cAliasQRY)->DT6_SERIE,,,,,,,,,"2",.T.,.F.)
		(cAliasQRY)->(dbSkip())
		Loop
	EndIf
	
	If Ascan(aCliErr,cCliDev+cLojDev) > 0
		(cAliasQRY)->(dbSkip())
		Loop
	EndIf
	//|--Se utilizado pela rotina TMSA854 usa os documentos que fazem parte do conjunto de clientes selecionados por ela.
	If lTmsa854
		If AScan(aParam854,{|h| h[2]+h[3] == cCliDev + cLojDev }) == 0
			(cAliasQRY)->(dbSkip())
			Loop
		EndIf
	EndIf

	SA1->( Dbsetorder(1))
	If SA1->( ! Dbseek(xFilial('SA1')+cCliDev+cLojDev))
		AAdd( aMsgAux, {STR0058 + "("+cCliDev+"/"+cLojDev+")", "04", "" } ) // "Problema de integridade: Codigo/Loja nao encontrado na tabela de clientes"	
		Aadd( aCliErr, cCliDev+cLojDev )
		(cAliasQRY)->(dbSkip())
		Loop
	EndIf

	If Len(aPrmPerfil) == 0
		aPerfil		:= TmsPerfil(cCliDev,cLojDev,,.F.,(cAliasQRY)->DT6_CLIREM,(cAliasQRY)->DT6_LOJREM,(cAliasQRY)->DT6_CLIDES,(cAliasQRY)->DT6_LOJDES)
	ElseIf (aPrmPerfil[1, 1] <> cCliDev) .Or. (aPrmPerfil[1, 2] <> cLojDev) .Or. (aPrmPerfil[1, 3] <> "") .Or. (aPrmPerfil[1, 4] <> .F.) .Or. (aPrmPerfil[1, 5] <> (cAliasQRY)->DT6_CLIREM) .Or. (aPrmPerfil[1, 6] <> (cAliasQRY)->DT6_LOJREM) .Or. (aPrmPerfil[1, 7] <> (cAliasQRY)->DT6_CLIDES) .Or. (aPrmPerfil[1, 8] <> (cAliasQRY)->DT6_LOJDES)
		aPrmPerfil	:= {}
		aPerfil		:= TmsPerfil(cCliDev,cLojDev,,.F.,(cAliasQRY)->DT6_CLIREM,(cAliasQRY)->DT6_LOJREM,(cAliasQRY)->DT6_CLIDES,(cAliasQRY)->DT6_LOJDES)
	EndIf

	If Len(aPrmPerfil) == 0
		// Armazenar os Parametros fornecidos a funcao TMSContrat
		aAdd(aPrmPerfil, {cCliDev, cLojDev, "", .F., (cAliasQRY)->DT6_CLIREM, (cAliasQRY)->DT6_LOJREM, (cAliasQRY)->DT6_CLIDES, (cAliasQRY)->DT6_LOJDES})
	EndIf

	If ( Len(aPerfil) > 0 .And. cCliDev+cLojDev == aPerfil[44]+aPerfil[45] ) .And. ;
		(cAliasQRY)->DUO_CODCLI != NIL .And. !Empty((cAliasQRY)->DUO_CODCLI) //-- Se tem perfil para o cliente devedor
		cTipFat := (cAliasQRY)->DUO_TIPFAT
		nQtdCTR := (cAliasQRY)->DUO_QTDCTR
		nValMax := (cAliasQRY)->DUO_VALMAX
		cBasFat := (cAliasQRY)->DUO_BASFAT
		cCpvEnt := (cAliasQRY)->DUO_CPVENT
		cSepPro := (cAliasQRY)->DUO_SEPPRO
		cSepEst := (cAliasQRY)->DUO_SEPEST
		cSepDoc := (cAliasQRY)->DUO_SEPDOC
		cSepTra := (cAliasQRY)->DUO_SEPTRA
		cSepFre := (cAliasQRY)->DUO_SEPFRE
		cSepRem := (cAliasQRY)->DUO_SEPREM
		cSepEnt := (cAliasQRY)->DUO_SEPENT
		cSepSrv := (cAliasQRY)->DUO_SEPSRV
		If lSepNeg
			cSepNeg := (cAliasQRY)->DUO_SEPNEG
		Else
			cSepNeg := ""
		EndIf
	Else
		If Len(aPerfil) > 0
			cTipFat := aPerfil[07]
			nQtdCTR := aPerfil[11]
			nValMax := aPerfil[10]
			cBasFat := aPerfil[06]
			cCpvEnt := aPerfil[08]
			cSepPro := aPerfil[12]
			cSepEst := aPerfil[13]
			cSepDoc := aPerfil[17]
			cSepTra := aPerfil[14]
			cSepFre := aPerfil[15]
			cSepRem := aPerfil[21]
			cSepEnt := aPerfil[23]
			cSepSrv := aPerfil[58]
			If lSepNeg
				cSepNeg := aPerfil[59]
			Else
				cSepNeg := ""
			EndIf
		Else
			AAdd( aMsgAux, {STR0012 + cCliDev + "/" + cLojDev, '04', "TMSA480" } ) //"Perfil do cliente não cadastrado! Cliente: "
			Aadd( aCliErr, cCliDev+cLojDev )
			(cAliasQRY)->(dbSkip())
			Loop
		EndIf
	EndIf
	//-- Valida se o cliente exige Pré-Fatura
	If Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 7 .And. aPerfil[61][1] == "1";
	.And. ( !("TMSAE45" $ FunName()) .Or. !IsInCallStack("TMSAE45A"))

		AAdd( aMsgAux, {STR0080 + cCliDev + "/" + cLojDev, '04', "" } ) //"Este cliente exige que a fatura seja proveniente de uma Pré-Fatura. Execute a rotina de pré-fatura!"
		Aadd( aCliErr, cCliDev+cLojDev )
		(cAliasQRY)->(dbSkip())
		Loop
	EndIf

	If lTM491TIP
		If lThread
			cTipFatPE := ExecBlock("TM491TIP",.F.,.F.,{cCliDev,cLojDev, aTMA490[12] })
		Else
			cTipFatPE := ExecBlock("TM491TIP",.F.,.F.,{cCliDev,cLojDev,mv_par12})
		EndIf

		If !Empty(cTipFatPE) .And. ValType(cTipFatPE) == "C"
			cTipFat := cTipFatPE
		EndIf
	Endif

	If lThread
		If !lTmsa854 .And. ( (cTipFat < aTMA490[1] .Or. cTipFat > aTMA490[2]) .Or. !(cBasFat $ "2;3") )
			Aadd( aCliErr, cCliDev+cLojDev )
			(cAliasQRY)->(dbSkip())
			Loop
		EndIf
	Else
		If !lTmsa854 .And. ( (cTipFat < MV_PAR01 .Or. cTipFat > MV_PAR02) .Or. !(cBasFat $ "2;3") )
			Aadd( aCliErr, cCliDev+cLojDev )
			(cAliasQRY)->(dbSkip())
			Loop
		EndIf
	EndIf

	If lTMTipFat
		If Empty(cTipFat) // Tipo de Faturamento do perfil do Cliente
			aTipFat := ExecBlock("TMTIPFAT",.F.,.F.,{cCliDev,cLojDev,cFilDeb})
			If ValType(aTipFat) == "A" .And. ValType(aTipFat[1]) == "C" .And. ValType(aTipFat[2]) == "C"
				DUZ->(dbSetOrder(1))
				If !DUZ->(MsSeek(xFilial("DUZ")+aTipFat[1]))
					AAdd( aMsgAux, {STR0013 + AllTrim(aTipFat[1]) + STR0014 + cFilDeb + STR0015, "04", "" } ) //"O tipo de faturamento -"###"- para a filial de debito -"###"- informado pelo P.E. TMTIPFAT nao foi encontrado."
					Aadd( aCliErr, cCliDev+cLojDev )
					(cAliasQRY)->(dbSkip())
					Loop
				EndIf
				SE4->(dbSetOrder(1))
				If !SE4->(MsSeek(xFilial("SE4")+aTipFat[2]))
					AAdd( aMsgAux, {STR0016 + AllTrim(aTipFat[2]) + STR0014 + cFilDeb + STR0015, "04", "" } ) //"A condicao de pagamento -"### "- para a filial de debito -"###"- informado pelo P.E. TMTIPFAT nao foi encontrada."
					Aadd( aCliErr, cCliDev+cLojDev )
					(cAliasQRY)->(dbSkip())
					Loop
				EndIf
				cTipFat  := aTipFat[1]
				cCondPag := aTipFat[2]
			Else
				Help(" ", 1,"TMSA49007") //"Erro do retorno do P.E. TMTIPFAT"
				Return Nil
			EndIf
		Else
			cCondPag := Posicione('SA1',1,xFilial('SA1')+cCliDev+cLojDev,'A1_COND')
			If Empty(cCondPag)
				AAdd( aMsgAux, {STR0017 + cCliDev + "/" + cLojDev, '04', "" } ) //"Cadastrar condicao de pagamento para o cliente: "
				Aadd( aCliErr, cCliDev+cLojDev )
				(cAliasQRY)->(dbSkip())
				Loop
			Else
				SE4->(DbSelectArea(1))
				If SE4->(!MsSeek(xFilial("SE4") + cCondPag))
					AAdd( aMsgAux, {STR0082 + AllTrim(cCondPag) + STR0014 + cFilDeb , "04", "" } ) //"Condição de Pagamento não está cadastrada ou é invalida." -"### "- para a filial de debito -"###"- Não está cadastrada ou é invalida."
					Aadd( aCliErr, cCliDev+cLojDev )
					(cAliasQRY)->(dbSkip())
					Loop
				EndIf
			EndIf
		EndIf
	Else
		If !lTmsa854 .And. Empty(cTipFat)
			Aadd(aMsgAux,{STR0018 + cCliDev + "/" + cLojDev, '04', "" } ) //"Tipo de faturamento não cadastrado no perfil do cliente: "
			Aadd( aCliErr, cCliDev+cLojDev )
			(cAliasQRY)->(dbSkip())
			Loop
		EndIf
		If cTmsERP == '0' //-- ERP Protheus
			cCondPag := Posicione('SA1',1,xFilial('SA1')+cCliDev+cLojDev,'A1_COND')
			If Empty(cCondPag)
				AAdd( aMsgAux, {STR0017 + cCliDev + "/" + cLojDev, '04', "" } ) //"Cadastrar condicao de pagamento para o cliente: "
				Aadd( aCliErr, cCliDev+cLojDev )
				(cAliasQRY)->(dbSkip())
				Loop
			Else
				SE4->(DbSelectArea(1))
				If SE4->(!MsSeek(xFilial("SE4") + cCondPag))
					AAdd( aMsgAux, {STR0082 + AllTrim(cCondPag) + STR0014 + cFilDeb + " - " + STR0027 + ": " + cCliDev+"/"+cLojDev, "04", "" } ) //"Condição de Pagamento não está cadastrada ou é invalida." -"### "- para a filial de debito -"###"- Não está cadastrada ou é invalida. ### Cliente: "
					Aadd( aCliErr, cCliDev+cLojDev )
					(cAliasQRY)->(dbSkip())
					Loop
				EndIf
			EndIf	
		EndIf
	EndIf

	TMSA491DtEmi(@dDtaFilDe, @dDtaFilAte, cTipFat, lConsTitAnt, @dDtaEmissao,,cAliasDT6)
	dDataBase := dDtaEmissao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ja' existe algum usuario faturando este Cliente                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave := "FAT"+cFilDeb+cCliDev+cLojDev
	aAdd(aChave,"")
	lContinua := .T.
	//-- Ponto de entrada para definir regras de travamento de acesso exclusivo dos documentos / cliente / loja.
	If lTM491TRV
		aRetPe := ExecBlock("TM491TRV",.F.,.F., {cChave})
		If ValType(aRetPe) == "A"
			aChave := aClone(aRetPe)
		EndIf
	EndIf

	//-- tratamento da trava da geracao de doctos.
	//-- Parametros da Funcao LockByName() :
	//   1o - Nome da Trava
	//   2o - usa informacoes da Empresa na chave
	//   3o - usa informacoes da Filial na chave 
	For nCntFor := 1 To Len(aChave)
		If !LockByName(cChave+aChave[nCntFor],.T.,.F.)
			lContinua := .F.
			Exit
		EndIf
	Next nCntFor

	If !lContinua
		//-- Se Ja estiver reservado retorna .F. pois nao pode executar a Rotina
		AAdd(aMsgAux, {STR0019 + cCliDev + "/" + cLojDev + STR0020 , '04', "" } ) //"Nao foi gerada Fatura para o Cliente: "###", pois ja esta sendo gerada por outro usuario ..."
		Aadd( aCliErr, cCliDev+cLojDev )
		(cAliasQRY)->(dbSkip())
		Loop
	EndIf

	lFatCli := .F.
	Do While (cAliasQRY)->(!Eof()) .And. (cAliasQRY)->(DT6_FILDEB+DT6_CLIDEV+DT6_LOJDEV) == cFilDeb+cCliDev+cLojDev

		//-- Verifica se o lote foi entregue
		If cCpvEnt == StrZero(1,Len(DUO->DUO_CPVENT)) .And. Empty((cAliasQRY)->DT6_LOTCET)
			(cAliasQRY)->(dbSkip())
			Loop
		EndIf

		//-- Se a base de faturamento for por data de emissao, verifica se a mesma esta dentro do intervalo
		//-- Se essa rotina for chamada pelo TMSA854 nao valida data de emissao, pois deve ser tratado como Fatura Manual.
		If cBasFat == StrZero(2,Len(DUO->DUO_BASFAT)) .And. !lTmsa854
			If (cAliasQRY)->DT6_DATEMI < dDtaFilDe .Or. (cAliasQRY)->DT6_DATEMI > dDtaFilAte
				If lTM491FAT
					lRet :=  ExecBlock( "TM491FAT",.F.,.F., ;
					{(cAliasQry)->DT6_FILDOC, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_SERIE, cBasFat} )
					If Valtype(lRet) <> "L"
						lRet :=  .F.
					EndIf
				EndIf
				If !lRet
					AAdd(aMsgAux,{ STR0034 + ":  " + (cAliasQRY)->(DT6_FILDOC+" /"+DT6_DOC+" /"+DT6_SERIE) +; //-- STR0034 - Doc.Transp: DT6_FILDOC / DT6_DOC / DT6_SERIE
							      STR0081 + " " + STR0027 + ": " +  (cAliasQRY)->(DT6_CLIDEV+DT6_LOJDEV) + " - " +; //-- STR0081 - " fora do periodo de faturamento. " STR0027 CLIENTE: A1_COD+A1_LOJA
								  Posicione("SA1",1,xFilial("SA1") +  (cAliasQRY)->(DT6_CLIDEV+DT6_LOJDEV),"A1_NOME"),"01",""})
					(cAliasQRY)->(dbSkip())
					Loop
				EndIf
			EndIf
		EndIf

		//-- Se a base de faturamento for por data de entrega, verifica se a mesma esta dentro do intervalo.
		If cBasFat == StrZero(3,Len(DUO->DUO_BASFAT)) .And. !lTmsa854
			If (cAliasQRY)->DT6_DATENT < dDtaFilDe .Or. (cAliasQRY)->DT6_DATENT > dDtaFilAte
				If lTM491FAT
					lRet :=  ExecBlock( "TM491FAT",.F.,.F., ;
					{(cAliasQry)->DT6_FILDOC, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_SERIE, cBasFat} )
					If Valtype(lRet) <> "L"
						lRet :=  .F.
					EndIf
				EndIf
				If !lRet
					(cAliasQRY)->(dbSkip())
					Loop
				EndIf
			EndIf
		EndIf

		//-- Verifica se as faturas devem ser separadas por produto
		cGrpProd := ' '
		If cSepPro == StrZero(1,Len(DUO->DUO_SEPPRO))
			//-- Obtem o grupo do produto
			cGrpProd := Posicione("SB1",1,xFilial("SB1")+Posicione("DTC",3,xFilial("SB1")+;
			(cAliasQRY)->(DT6_FILDOC+DT6_DOC+DT6_SERIE),"DTC_CODPRO"),"B1_GRUPO")
		EndIf

		//-- Verifica se as faturas devem ser separadas por Servico
		cCodServ := ' '
		If cSepSrv == StrZero(1,Len(DUO->DUO_SEPSRV))
			//-- Obtem o servico
			cCodServ := (cAliasQRY)->DT6_SERVIC
		EndIf

		//-- Verifica se as faturas devem ser separadas por Código de Negociação
		cCodNeg := " "
		If lSepNeg .And. cSepNeg == StrZero(1,Len(DUO->DUO_SEPNEG))
			//-- Obtem o código de negociação
			cCodNeg := (cAliasQRY)->DT6_CODNEG
		EndIf

		//-- Verifica se as faturas devem ser separadas por estado
		cEstDest := ' '
		If !Empty(cSepEst)
			//--  ("*") - Indica que deve ser gerada uma fatura por estado.
			cEstDest := Iif(((cAliasQRY)->UFQBR $ cSepEst) .Or. ("*" $ cSepEst),;
			(cAliasQRY)->UFQBR, ' ')
		EndIf

		cCodCli := (cAliasQRY)->DT6_CLIDEV
		cLojCli := (cAliasQRY)->DT6_LOJDEV

		cCliQbr := ''
		cLojQbr := ''
		lCliQbr := (cSepRem == StrZero(1,Len(DUO->DUO_SEPREM)))

		//-- Separa as faturas por: Tipo de frete FOB + Cliente remetente
		If lSepNovo
			If cSepRem == StrZero(1,Len(DUO->DUO_SEPREM)) .And. (cAliasQRY)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE))
				cCliQbr := (cAliasQRY)->DT6_CLIREM
				cLojQbr := (cAliasQRY)->DT6_LOJREM
			ElseIf cSepRem == StrZero(2,Len(DUO->DUO_SEPREM)) .And. (cAliasQRY)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE))
				cCliQbr := (cAliasQRY)->DT6_CLIDES
				cLojQbr := (cAliasQRY)->DT6_LOJDES
			ElseIf cSepRem == StrZero(3,Len(DUO->DUO_SEPREM)) .And. (cAliasQRY)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE))
				cCliQbr := (cAliasQRY)->DT6_CLICON
				cLojQbr := (cAliasQRY)->DT6_LOJCON
			ElseIf cSepRem == StrZero(4,Len(DUO->DUO_SEPREM)) .And. (cAliasQRY)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE))
				cCliQbr := (cAliasQRY)->DT6_CLICON
				cLojQbr := (cAliasQRY)->DT6_LOJCON
			ElseIf cSepRem == StrZero(5,Len(DUO->DUO_SEPREM)) .And. (cAliasQRY)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE))
				cCliQbr := (cAliasQRY)->DT6_CLIDPC
				cLojQbr := (cAliasQRY)->DT6_LOJDPC
			ElseIf cSepRem == StrZero(6,Len(DUO->DUO_SEPREM)) .And. (cAliasQRY)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE))
				cCliQbr := (cAliasQRY)->DT6_CLIDPC
				cLojQbr := (cAliasQRY)->DT6_LOJDPC
			EndIf
		Else
			If cSepRem == StrZero(1,Len(DUO->DUO_SEPREM)) .And. (cAliasQRY)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE))
				cCliQbr := (cAliasQRY)->DT6_CLIREM 
				cLojQbr := (cAliasQRY)->DT6_LOJREM
			EndIf
		EndIf
		If Empty(cCliQbr) .Or. Empty(cLojQbr)
			cCliQbr := (cAliasQRY)->DT6_CLIDEV
			cLojQbr := (cAliasQRY)->DT6_LOJDEV
		EndIf

		//-- Verifica se o tipo do documento esta contido nos tipos selecionados para separacao
		If lThread
			If !Empty(aTMA490[12]) // nTipoDoc <> 1 //-- Diferente de documento Normal
				cDocTms := (cAliasQRY)->DT6_DOCTMS
			Else
				cDocTms := If(AllTrim((cAliasQRY)->DT6_DOCTMS) $ cSepDoc .Or. "*" $ cSepDoc, (cAliasQRY)->DT6_DOCTMS, ' ')
			EndIf
		Else
			If !Empty(mv_par12) // nTipoDoc <> 1 //-- Diferente de documento Normal
				cDocTms := (cAliasQRY)->DT6_DOCTMS
			Else
				cDocTms := If(AllTrim((cAliasQRY)->DT6_DOCTMS) $ cSepDoc .Or. "*" $ cSepDoc, (cAliasQRY)->DT6_DOCTMS, ' ')
			EndIf
		EndIf
		//-- Verifica se as faturas devem ser separadas por tipo de transporte
		cTipTra := ' '
		If lThread
			If cSepTra == StrZero(1,Len(DUO->DUO_SEPTRA)) .Or. ! Empty(aTMA490[12]) // nTipoDoc <> 1 //-- Diferente de documento normal
				cTipTra := (cAliasQRY)->DT6_TIPTRA
			EndIf
		Else
			If cSepTra == StrZero(1,Len(DUO->DUO_SEPTRA)) .Or. ! Empty(mv_par12) // nTipoDoc <> 1 //-- Diferente de documento normal
				cTipTra := (cAliasQRY)->DT6_TIPTRA
			EndIf
		EndIf
		//-- Verifica se as faturas devem ser separadas por tipo de frete
		cTipFre := ' '
		If cSepFre == StrZero(1, Len(DUO->DUO_SEPFRE))
			cTipFre := (cAliasQRY)->DT6_TIPFRE
		EndIf

		//-- Verifica se as faturas devem ser separadas por CTRC Entregue / Nao Entregue
		cFlagEnt := ' '
		If cSepEnt == StrZero(1, Len(DUO->DUO_SEPENT)) 
			cFlagEnt := Iif(!Empty((cAliasQRY)->DT6_DATENT),STR0008,STR0009) //"Sim"###"Nao"
		EndIf

		cDocFat := ' '
		If lThread
			If !Empty(aTMA490[12])  // nTipoDoc <> 1 //-- Diferente de documento normal
				cDocFat := Posicione("DUI",1,xFilial("DUI")+(cAliasQRY)->DT6_DOCTMS,"DUI_DOCFAT")
			EndIf
		Else
			If !Empty(mv_par12)  // nTipoDoc <> 1 //-- Diferente de documento normal
				cDocFat := Posicione("DUI",1,xFilial("DUI")+(cAliasQRY)->DT6_DOCTMS,"DUI_DOCFAT")
			EndIf
		EndIf

		// Checa se houve mudanca para algum parametro utilizado na chamada da funcao TMSContrat
		If Len(aPrmContr) == 0
			aContrato	:= TMSContrat( cCliDev, cLojDev, (cAliasQRY)->DT6_DATEMI, (cAliasQRY)->DT6_SERVIC, .F., (cAliasQRY)->DT6_TIPFRE,,,,,,,,,,,.F.,(cAliasQRY)->DT6_CLICAL,(cAliasQRY)->DT6_LOJCAL, .T. ,,(cAliasQRY)->DT6_CODNEG )
		ElseIf (aPrmContr[1, 1] <> cCliDev) .Or. (aPrmContr[1, 2] <> cLojDev) .Or. (aPrmContr[1, 3] <>  (cAliasQRY)->DT6_DATEMI) .Or. (aPrmContr[1, 4] <> (cAliasQRY)->DT6_SERVIC) .Or. (aPrmContr[1, 5] <> .F.) .Or. (aPrmContr[1, 6] <> (cAliasQRY)->DT6_TIPFRE)
			aPrmContr	:= {}
			aContrato	:= TMSContrat( cCliDev, cLojDev, (cAliasQRY)->DT6_DATEMI, (cAliasQRY)->DT6_SERVIC, .F., (cAliasQRY)->DT6_TIPFRE,,,,,,,,,,,.F.,,,.T. ,,(cAliasQRY)->DT6_CODNEG )
		EndIf
		If Empty(aContrato)
			aCliCalc := TmsCliCalc( (cAliasQRY)->DT6_CLIREM, (cAliasQRY)->DT6_LOJREM, (cAliasQRY)->DT6_CLIDES, (cAliasQRY)->DT6_LOJDES, .F. )
			If !Empty(aCliCalc)
				aContrato	:= TMSContrat( aCliCalc[1], aCliCalc[2], (cAliasQRY)->DT6_DATEMI, (cAliasQRY)->DT6_SERVIC, .F., (cAliasQRY)->DT6_TIPFRE,,,,,,,,,,,.F.,,,.T. ,,(cAliasQRY)->DT6_CODNEG )
			EndIf
		EndIf

		If Len(aPrmContr) == 0
			// Armazenar os Parametros fornecidos a funcao TMSContrat
			aAdd(aPrmContr, {cCliDev, cLojDev, (cAliasQRY)->DT6_DATEMI, (cAliasQRY)->DT6_SERVIC, .F., (cAliasQRY)->DT6_TIPFRE})
		EndIf

		//-- Caso o tipo do servico for 'transporte' e uma Devolucao Parcial, procura o contrato invertido
		If Empty(aContrato)
			If (cAliasQRY)->DT6_SERTMS == StrZero(2,Len(DT6->DT6_SERTMS)) .And. (cAliasQRY)->DT6_DOCTMS ==StrZero(6,Len(DT6->DT6_DOCTMS))
				If (cAliasQRY)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE))   //FOB, Procura o contrato (CIF) para o destinatario
					cTipFreDv:= StrZero(1,Len(DT6->DT6_TIPFRE))
				EndIf
				If (cAliasQRY)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE))   //CIF, Procura o contrato (FOB) para o destinatario
					cTipFreDv:= StrZero(2,Len(DT6->DT6_TIPFRE))
				EndIf

				If Len(aPrmContr) == 0
					aContrato	:= TMSContrat( cCliDev, cLojDev, (cAliasQRY)->DT6_DATEMI, (cAliasQRY)->DT6_SERVIC, .F.,cTipFreDv,,,,,,,,,,,.F.,,,.T. ,,(cAliasQRY)->DT6_CODNEG )
				ElseIf (aPrmContr[1, 1] <> cCliDev) .Or. (aPrmContr[1, 2] <> cLojDev) .Or. (aPrmContr[1, 3] <>  (cAliasQRY)->DT6_DATEMI) .Or. (aPrmContr[1, 4] <> (cAliasQRY)->DT6_SERVIC) .Or. (aPrmContr[1, 5] <> .F.) .Or. (aPrmContr[1, 6] <> cTipFreDv)
					aPrmContr	:= {}
					aContrato	:= TMSContrat( cCliDev, cLojDev, (cAliasQRY)->DT6_DATEMI, (cAliasQRY)->DT6_SERVIC, .F.,cTipFreDv,,,,,,,,,,,.F.,,,.T. ,,(cAliasQRY)->DT6_CODNEG )
				EndIf

				If Len(aPrmContr) == 0
					// Armazenar os Parametros fornecidos a funcao TMSContrat
					aAdd(aPrmContr, {cCliDev, cLojDev, (cAliasQRY)->DT6_DATEMI, (cAliasQRY)->DT6_SERVIC, .F.,cTipFreDv})
				EndIf
			EndIf
		EndIf

		lFatCli := .T.
		lFat	:= .T.

		//-- Quando o documento de transporte eh '5 - Nota fiscal' e nao encontrar o contrato
		//-- e (o DT6 eh de servico adicional OU parâmetro MV_PAR15 (apenas documentos de serviço adicional) 
		//-- estiver como "1 - Sim": nao deve validar se o contrato existe
		lSrvAdd := .F.
		If (cAliasQry)->DT6_DOCTMS == StrZero(5, Len(DC5->DC5_DOCTMS)) .And. Len(aContrato) <= 0 .And.;
		((FindFunction("TMSA853DSa") .And. TMSA853DSa((cAliasQry)->DT6_FILDOC, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_SERIE, (cAliasQry)->DT6_DOCTMS)) .Or.;
		lDocSrvAdd)
			lSrvAdd := .T.
		EndIf

		//-- Ignora o contrato quando o documento eh de servico adicional
		//**** */
		//-- removido o "If Len(aContrato) > 0 .Or. lSrvAdd" pelo abaixo, entendendo que se o documento foi emitido o contrato utilizado para a emissão
		//-- deve pelo menos existir independente se está encerrado ou suspenso. Antes o fato do contrato estar encerrado ou suspenso já era motivo de desconsiderar
		//-- o documento de entrar na fatura para cobrança e isso não é correto, pois mesmo que um contrato expire esse não deve influenciar se um documento pode ou
		//-- não ser faturado.
		If Len(aContrato) > 0
			If ! lSrvAdd 
				If aContrato[1,29] == '1' .And. cSepSrv == StrZero(1,Len(DUO->DUO_SEPSRV))
					//--Verifica a configuracao do contrato
					//--em relacao ao valor fixo (Veiculo Dedicado):
					aVFContr := TMSA491VlrC( 	cCliDev, cLojDev, (cAliasQry)->DT6_TIPFRE , (cAliasQry)->DT6_SERVIC, dDtaFilAte, aContrato,'',(cAliasQRY)->DT6_CODNEG)
				EndIf
			EndIf
		EndIf
		//-- Trava o registro que está sendo usado por outra estação
		If !lTmsa854 .And. lCONTDOC 				
			If !TmsConTran((cAliasQry)->DT6_FILDOC,(cAliasQry)->DT6_DOC,(cAliasQry)->DT6_SERIE, .T.)				
				lFat := .F.								
			EndIf								 					 
		EndIf	

		nValDecr := (cAliasQry)->DT6_DECRES
		If Len(aContrato) > 0
			If ! lSrvAdd                                       	   .And.;
				aContrato[1,29] == '1'                             .And.;
				cSepSrv         == StrZero(1,Len(DUO->DUO_SEPSRV)) .And.;
				Len(aVFContr)    > 0                               .And.;
				aVFContr[1]      > 0

				nValDecr := (cAliasQry)->DT6_VALTOT

			EndIf
		EndIf

		If lFat .And. lTmsa854 
			lFat := Ascan(aDoctos854,{|x| x[2] + x[3] + x[4] == (cAliasQry)->DT6_FILDOC + (cAliasQry)->DT6_DOC + (cAliasQry)->DT6_SERIE}) > 0
		EndIf
		
		If lFat

				AADD( aDocs, {	cMarca,;								//1
								cCodCli,;								//2
								cLojCli,;								//3
								cGrpProd,;								//4
								(cAliasQRY)->UFQBR,;					//5
								cEstDest,;								//6
								cTipTra,;								//7
								(cAliasQry)->DT6_TIPFRE,;				//8
								(cAliasQry)->DT6_FILDOC,; 				//9
								(cAliasQry)->DT6_DOC,;	  				//10
								(cAliasQry)->DT6_SERIE,; 				//11
								If((cAliasQry)->DT6_VALFAT>0,(cAliasQry)->DT6_VALFAT,(cAliasQry)->DT6_VALTOT),;	//12
								(cAliasQry)->DT6_ACRESC,;				//13
								nValDecr,;	                            //14
								(cAliasQry)->DT6_VALFRE,; 				//15
								(cAliasQry)->DT6_DATEMI,;				//16
								(cAliasQry)->NRECNO,;					//17
								cDocTMS,;			   					//18
								If(!Empty(cDocFat),cDocFat,cDocTMS),;	//19
								(cAliasQry)->DT6_FILDEB,;				//20
								cFlagEnt,;				  				//21
								cCondPag,;								//22
								nQtdCTR ,;								//23
								nValMax,;								//24
								dDtaEmissao,;							//25
								(cAliasQry)->DT6_VALTOT,;				//26
								cCliQbr,;								//27
								cLojQbr,;								//28
								cCodServ,;								//29
								dDtaFilAte,;							//30
								(cAliasQry)->DT6_CLIDES,;				//31
								(cAliasQry)->DT6_LOJDES,;				//32
								cTipFre,;								//33
								cTipFreDv,;								//34
								(cAliasQRY)->DT6_CLIREM,;				//35
								(cAliasQRY)->DT6_LOJREM,;				//36
								(cAliasQRY)->DT6_CLIDES,;				//37
								(cAliasQRY)->DT6_LOJDES,;				//38
								(cAliasQRY)->DT6_CLIDEV,;				//39
								(cAliasQRY)->DT6_LOJDEV,;				//40
								(cAliasQry)->DT6_CDRORI,;				//41
								(cAliasQry)->DT6_CDRDES,;				//42
								(cAliasQry)->DT6_CDRCAL,;				//43
								(cAliasQry)->DT6_CLICON,;				//44
								(cAliasQry)->DT6_LOJCON,;				//45
								(cAliasQry)->DT6_CLIDPC,;				//46
								(cAliasQry)->DT6_LOJDPC,;				//47
								cCodNeg	})								//48

								//| #AddNewFields
								Aadd(aDocs[Len(aDocs)],(cAliasQry)->DT6_CLIEXP) //49
								Aadd(aDocs[Len(aDocs)],(cAliasQry)->DT6_LOJEXP) //50
								Aadd(aDocs[Len(aDocs)],(cAliasQry)->DT6_CLIREC) //51
								Aadd(aDocs[Len(aDocs)],(cAliasQry)->DT6_LOJREC) //52

		EndIf	
		/*Else
			If AScan( aMsgAux, {|x| Right(x[1], Len(cCliDev+cLojDev)+1) $ cCliDev + '/' + cLojDev} ) == 0
				AAdd( aMsgAux, {STR0049 + ": " + cCliDev + '/' + cLojDev, '04', "" } ) //"Nao foi encontrado contrato para o cliente"
			EndIf
		EndIf*/

		dbSelectArea(cAliasQRY)
		dbSkip()
	EndDo

	If !lFatCli //-- Se Nao for faturar o Cliente
		For nCntFor := 1 To Len(aChave)
			UnLockByName(cChave+aChave[nCntFor],.T.,.F.) // Libera Lock
		Next nCntFor
	EndIf

EndDo
(cAliasQRY)->(dbCloseArea())

If ExecSchedule()
	aMsgErr	:= aClone(aMsgAux)
	// controle de mensagens de erro
	For nCntFor := 1 to Len(aMsgErr)
		AdicionaMsg(aMsgErr[nCntFor,1])
	Next
EndIf

If Empty(aDocs)
	AAdd( aMsgAux, {STR0021, '04', "" } ) //"Nao Existem dados para gerar a Fatura"
ElseIf lTmsa854 .And. Len(aDocs) <> Len(aDoctos854)
	AAdd( aMsgAux, {STR0084 + AllTrim(Str(Len(aDoctos854))) + STR0085 + AllTrim(Str(Len(aDocs))) + STR0086, '04', "" } ) //"Do(s) "##" documento(s) selecionado(s) a faturar, apenas "##" está(ão) apto(s) a Faturar!"
Else
	//-- Monta vetor de faturas (aFatCli)
	A491MntFat(aCampos, lMostra, cAliasQRY, cNat, cNatRod, cNatAer, cNatFlu, aChave, @aMsgFat)
EndIf

If !Empty(aMsgAux) .And. !ExecSchedule() .And. !lThread
	aMsgErr	:= aClone(aMsgAux)
	If !lTmsa854
		TmsMsgErr( aMsgErr )
	EndIf
ElseIf lThread
	AAdd( aMsgAux, { cClDev + "/" + cLjDev + " : " + Posicione("SA1",1,xFilial("SA1") + cClDev + cLjDev ,"A1_NOME" ) + RetTitle('DT6_FILDEB') + ": " + cFilDB + " - " + STR0065 + Str(Len(aMsgFat)), '04', "" } )

	aMsgErr	:= aClone(aMsgAux)
EndIf

RestArea(aAreaDT6)
dDataBase := dBaseAux

Return aMsgErr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a491MntFat³ Autor ³Patricia Antar Salomao ³ Data ³17.01.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta vetor contendo as faturas e seus documentos.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a491MntFat()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - vetor contendo os campos que serao exibidos na tela ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA491                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a491MntFat(aCampos, lMostra, cAliasTRB, cNat, cNatRod, cNatAer, cNatFlu, aChave, aMsgFat)

Local oDlg, oItem, oPanel, oVlrTot, cOpc
Local oOk       := LoadBitmap(GetResources(), "LBOK")
Local oNo       := LoadBitmap(GetResources(), "LBNO")
Local aButtons  := {}
Local cCodCli   := "" // Codigo do Cliente.
Local cLojCli   := "" // Loja do Cliente.
Local cChave    := ""
Local cNumSeq   := Replicate("0", 6) // Numero sequencial de fatura.
Local nQtdCTRC  := 0 // Quantidade de CTRC's por fatura.
Local nValMax   := 0 // Valor maximo da fatura
Local nCtrcFat  := 1 // Contador de CTRC's por fatura.
Local nOpcA     := 0
Local nValorFat := 0
Local nVlrTot   := 0
Local nX        := 0
Local nZ        := 0
Local nCntFor1  := 0
Local nCntFor2  := 0
Local aFatCli   := {}  // Faturas por clientes.
Local aLibCli   := {}
local aDocsUsr  := {}
Local lAAddDoc  := .F.
Local nLen      := Len(aDocs)
Local lRet      := .F.
Local lFat      := .F.
Local cDescSrv  := ""
Local lProcessa := .F.
Local lCONTDOC  := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.
Local cTmsERP   := SuperGetMV("MV_TMSERP",,'0')
Local aServico  := {}

Local cDesNeg := ""
Local aAreas  := {DDB->(GetArea()),GetArea()}
Local lNegBco := .F.
Local lSrvBco := .F.
	
Default lMostra := .T.
Default cNat    := ''
Default cNatRod := ''
Default cNatAer := ''
Default cNatFlu := ''
Default aChave  := {}
Default aMsgFat := {}

Aadd(aButtons, {'PESQUISA',{|| Tmsa491Psq(@oItem,aFatCli) }, STR0047 })   	//'Pesquisa'
Aadd(aButtons, {"DESTINOS",{|| Tmsa491Det(aFatCli, oItem:nAt, aCampos, @nVlrTot, oVlrTot, cNat, cNatRod, cNatAer, cNatFlu) }, STR0022 , STR0022 }) //"Detalhar"
Aadd(aButtons, {'BMPUSER' ,{|| Tmsa491Cli(aFatCli, oItem:nAt) }, STR0023 , STR0024 }) //"Cadastro Cliente"

If lTM491MNT
	aDocsUsr := ExecBlock("TM491MNT",.F.,.F.,{aDocs})
	If ValType(aDocsUsr)=="A"
		aDocs := aClone(aDocsUsr)
		nLen  := Len(aDocs)
	EndIf
EndIf
aDocs := aSort( aDocs,,,{ |x,y|	x[CLDCODCLI]+x[CLDLOJCLI]+x[CLDCLIQBR]+x[CLDLOJQBR]+x[CLDFILDEB]+x[CLDGRPPRD]+x[CLDUFQBR]+x[CLDDOCTMS]+x[CLDTPTRA]+x[CLDSEPFRE]+x[CLDDATENT]+x[CLDCODNEG]+x[CLDSERVIC] < ;
								y[CLDCODCLI]+y[CLDLOJCLI]+y[CLDCLIQBR]+y[CLDLOJQBR]+y[CLDFILDEB]+y[CLDGRPPRD]+y[CLDUFQBR]+y[CLDDOCTMS]+y[CLDTPTRA]+y[CLDSEPFRE]+y[CLDDATENT]+y[CLDCODNEG]+y[CLDSERVIC]})	

For nX := 1 To nLen
	cCodCli   := aDocs[nX][CLDCODCLI]
	cLojCli   := aDocs[nX][CLDLOJCLI]
	nCtrcFat  := 1
	cNumSeq   := Soma1( cNumSeq, 6)
	nValorFat := 0
	lAAddDoc  := .T.
	lFat      := .T.
	
	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial('SA1')+cCodCli+cLojCli))
	cNomCli   := SA1->A1_NOME

	//-- Obtem a quantidade Maxima de conhecimentos por fatura
	nQtdCTRC := Iif(aDocs[nX][CLDQTDCTR] > 0, aDocs[nX][CLDQTDCTR], Val(Replicate("9", TamSX3("DUO_QTDCTR")[1])))
	//-- Obtem o valor Maximo dos conhecimentos por fatura
	nValMax  := Iif(aDocs[nX][CLDVALMAX] > 0, aDocs[nX][CLDVALMAX], Val(Replicate("9", TamSX3("DUO_VALMAX")[1])))	

	If !Empty(aDocs[nX][CLDCODNEG]) .And. !Empty(aDocs[nX][CLDSERVIC])
		//-- Obtem a descricao da negociacao.
		cDesNeg  := Posicione("DDB",1,xFilial("DDB") + aDocs[nX][CLDCODNEG],"DDB_DESCRI")
		//-- Obtem a descricao do Servico.
		aServico := FWGetSX5('L4', Padr(aDocs[nX,CLDSERVIC], TamSx3("X5_CHAVE")[1]))
		cDescSrv := IIf(Len(aServico) > 0, aServico[1][4], "")
		//-- Monta a chave de quebra
		cChave   := aDocs[nX,CLDCODCLI]+aDocs[nX,CLDLOJCLI]+aDocs[nX,CLDCLIQBR]+aDocs[nX,CLDLOJQBR]+aDocs[nX,CLDFILDEB]+aDocs[nX,CLDGRPPRD]+aDocs[nX,CLDUFQBR]+aDocs[nX,CLDDOCTMS]+aDocs[nX,CLDTPTRA]+aDocs[nX,CLDSEPFRE]+aDocs[nX,CLDDATENT]+aDocs[nX,CLDCODNEG]+aDocs[nX,CLDSERVIC]
	ElseIf !Empty(aDocs[nX][CLDCODNEG])
		//-- Obtem a descricao da negociacao.
		cDesNeg  := Posicione("DDB",1,xFilial("DDB") + aDocs[nX][CLDCODNEG],"DDB_DESCRI")
		//-- Monta a chave de quebra
		cChave   := aDocs[nX,CLDCODCLI]+aDocs[nX,CLDLOJCLI]+aDocs[nX,CLDCLIQBR]+aDocs[nX,CLDLOJQBR]+aDocs[nX,CLDFILDEB]+aDocs[nX,CLDGRPPRD]+aDocs[nX,CLDUFQBR]+aDocs[nX,CLDDOCTMS]+aDocs[nX,CLDTPTRA]+aDocs[nX,CLDSEPFRE]+aDocs[nX,CLDDATENT]+aDocs[nX,CLDCODNEG]
	ElseIf !Empty(aDocs[nX][CLDSERVIC])
		//-- Obtem a descricao do Servico.
		aServico := FWGetSX5('L4', Padr(aDocs[nX,CLDSERVIC], TamSx3("X5_CHAVE")[1]))
		cDescSrv := IIf(Len(aServico) > 0, aServico[1][4], "")
		//-- Monta a chave de quebra
		cChave   := aDocs[nX,CLDCODCLI]+aDocs[nX,CLDLOJCLI]+aDocs[nX,CLDCLIQBR]+aDocs[nX,CLDLOJQBR]+aDocs[nX,CLDFILDEB]+aDocs[nX,CLDGRPPRD]+aDocs[nX,CLDUFQBR]+aDocs[nX,CLDDOCTMS]+aDocs[nX,CLDTPTRA]+aDocs[nX,CLDSEPFRE]+aDocs[nX,CLDDATENT]+aDocs[nX,CLDSERVIC]
	Else
		cChave   := aDocs[nX,CLDCODCLI]+aDocs[nX,CLDLOJCLI]+aDocs[nX,CLDCLIQBR]+aDocs[nX,CLDLOJQBR]+aDocs[nX,CLDFILDEB]+aDocs[nX,CLDGRPPRD]+aDocs[nX,CLDUFQBR]+aDocs[nX,CLDDOCTMS]+aDocs[nX,CLDTPTRA]+aDocs[nX,CLDSEPFRE]+aDocs[nX,CLDDATENT]
	EndIf
	//-- Trava o registro que está sendo usado por outra estação
	If lCONTDOC .And. !Empty(aDocs)				
		If !TmsConTran(aDocs[nX,CLDFILDOC],aDocs[nX,CLDDOC],aDocs[nX,CLDSERIE], .T.)				
			lFat := .F.								
		EndIf								 					 
	EndIf
	
	If lFat
		For nZ := nX to nLen
			//IncProc()
			If !Empty(aDocs[nX][CLDCODNEG]) .And. !Empty(aDocs[nX][CLDSERVIC])
				If cChave <> aDocs[nZ,CLDCODCLI]+aDocs[nZ,CLDLOJCLI]+aDocs[nZ,CLDCLIQBR]+aDocs[nZ,CLDLOJQBR]+aDocs[nZ,CLDFILDEB]+aDocs[nZ,CLDGRPPRD]+aDocs[nZ,CLDUFQBR]+aDocs[nZ,CLDDOCTMS]+aDocs[nZ,CLDTPTRA]+aDocs[nZ,CLDSEPFRE]+aDocs[nZ,CLDDATENT]+aDocs[nZ,CLDCODNEG]+aDocs[nZ,CLDSERVIC] .Or. nCtrcFat > nQtdCTRC 
					Exit
				EndIf
			ElseIf !Empty(aDocs[nX][CLDCODNEG])
				If cChave <> aDocs[nZ,CLDCODCLI]+aDocs[nZ,CLDLOJCLI]+aDocs[nZ,CLDCLIQBR]+aDocs[nZ,CLDLOJQBR]+aDocs[nZ,CLDFILDEB]+aDocs[nZ,CLDGRPPRD]+aDocs[nZ,CLDUFQBR]+aDocs[nZ,CLDDOCTMS]+aDocs[nZ,CLDTPTRA]+aDocs[nZ,CLDSEPFRE]+aDocs[nZ,CLDDATENT]+aDocs[nZ,CLDCODNEG] .Or. nCtrcFat > nQtdCTRC 
					Exit
				EndIf
			ElseIf !Empty(aDocs[nX][CLDSERVIC])
				If cChave <> aDocs[nZ,CLDCODCLI]+aDocs[nZ,CLDLOJCLI]+aDocs[nZ,CLDCLIQBR]+aDocs[nZ,CLDLOJQBR]+aDocs[nZ,CLDFILDEB]+aDocs[nZ,CLDGRPPRD]+aDocs[nZ,CLDUFQBR]+aDocs[nZ,CLDDOCTMS]+aDocs[nZ,CLDTPTRA]+aDocs[nZ,CLDSEPFRE]+aDocs[nZ,CLDDATENT]+aDocs[nZ,CLDSERVIC] .Or. nCtrcFat > nQtdCTRC 
					Exit
				EndIf
			Else
				If cChave <> aDocs[nZ,CLDCODCLI]+aDocs[nZ,CLDLOJCLI]+aDocs[nZ,CLDCLIQBR]+aDocs[nZ,CLDLOJQBR]+aDocs[nZ,CLDFILDEB]+aDocs[nZ,CLDGRPPRD]+aDocs[nZ,CLDUFQBR]+aDocs[nZ,CLDDOCTMS]+aDocs[nZ,CLDTPTRA]+aDocs[nZ,CLDSEPFRE]+aDocs[nZ,CLDDATENT] .Or. nCtrcFat > nQtdCTRC
					Exit
				EndIf
			EndIf
			//-- Ponto de Entrada utilizado para quebra da fatura
			If lTM491QBR
				lRet := ExecBlock('TM491QBR',.F.,.F., {aDocs[nZ,CLDFILDOC], aDocs[nZ,CLDDOC], aDocs[nZ,CLDSERIE],cNumSeq})
				If ValType(lRet) == "L" .And. lRet
					Exit
				EndIf
			EndIf
	
			nPosFat := Ascan(aFatCli, {|x| x[CLSEQ] + x[CLCOD] + x[CLLOJA] == cNumSeq + cCodCli + cLojCli})
			If nPosFat == 0
				If !Empty(aDocs[nX][CLDCODNEG]) .And. !Empty(aDocs[nX][CLDSERVIC])
					Aadd(aFatCli, {	.T.,;					//--01
									cNumSeq,;				//--02
									cCodCli,;				//--03
									cLojCli,;				//--04
									cNomCli,;				//--05
									aDocs[nZ,CLDVALFAT] + (aDocs[nZ,CLDACRESC] - aDocs[nZ,CLDDECRES]),;	//--06
									nQtdCtrc,;				//--07
									nValMax,;				//--08
									aDocs[nZ,CLDCNDPAG],;	//--09
									aDocs[nZ,CLDFILDEB],;	//--10
									aDocs[nZ,CLDGRPPRD],;	//--11
									aDocs[nZ,CLDUFQBR],;	//--12
									aDocs[nZ,CLDDOCTMS],;	//--13
									aDocs[nZ,CLDTPTRA],;	//--14
									aDocs[nZ,CLDTPFRE],;	//--15
									aDocs[nZ,CLDDATENT],;	//--16
									aDocs[nZ,CLDDTEMIS],;	//--17
									{},;					//--18
									aDocs[nZ,CLDSERVIC],;	//--19
									cDescSrv,;				//--20
									aDocs[nZ,CLDDTATE],;  	//--21
									aDocs[nZ,CLDTPFRDV],; 	//--22
									aDocs[nZ,CLDCODNEG],;	//--23
									cDesNeg })				//--24
				ElseIf !Empty(aDocs[nX][CLDCODNEG])
					lSrvBco := .T.
					Aadd(aFatCli, {	.T.,;					//--01
									cNumSeq,;				//--02
									cCodCli,;				//--03
									cLojCli,;				//--04
									cNomCli,;				//--05
									aDocs[nZ,CLDVALFAT] + (aDocs[nZ,CLDACRESC] - aDocs[nZ,CLDDECRES]),;	//--06
									nQtdCtrc,;				//--07
									nValMax,;				//--08
									aDocs[nZ,CLDCNDPAG],;	//--09
									aDocs[nZ,CLDFILDEB],;	//--10
									aDocs[nZ,CLDGRPPRD],;	//--11
									aDocs[nZ,CLDUFQBR],;	//--12
									aDocs[nZ,CLDDOCTMS],;	//--13
									aDocs[nZ,CLDTPTRA],;	//--14
									aDocs[nZ,CLDTPFRE],;	//--15
									aDocs[nZ,CLDDATENT],;	//--16
									aDocs[nZ,CLDDTEMIS],;	//--17
									{},;					//--18
									aDocs[nZ,CLDSERVIC],;	//--19
									cDescSrv,;				//--20
									aDocs[nZ,CLDDTATE],;  	//--21
									aDocs[nZ,CLDTPFRDV],; 	//--22
									aDocs[nZ,CLDCODNEG],;	//--23
									cDesNeg })				//--24
				ElseIf !Empty(aDocs[nX][CLDSERVIC])
					lNegBco := .T.
					Aadd(aFatCli, {	.T.,;					//--01
									cNumSeq,;				//--02
									cCodCli,;				//--03
									cLojCli,;				//--04
									cNomCli,;				//--05
									aDocs[nZ,CLDVALFAT] + (aDocs[nZ,CLDACRESC] - aDocs[nZ,CLDDECRES]),;	//--06
									nQtdCtrc,;				//--07
									nValMax,;				//--08
									aDocs[nZ,CLDCNDPAG],;	//--09
									aDocs[nZ,CLDFILDEB],;	//--10
									aDocs[nZ,CLDGRPPRD],;	//--11
									aDocs[nZ,CLDUFQBR],;	//--12
									aDocs[nZ,CLDDOCTMS],;	//--13
									aDocs[nZ,CLDTPTRA],;	//--14
									aDocs[nZ,CLDTPFRE],;	//--15
									aDocs[nZ,CLDDATENT],;	//--16
									aDocs[nZ,CLDDTEMIS],;	//--17
									{},;					//--18
									aDocs[nZ,CLDSERVIC],;	//--19
									cDescSrv,;				//--20
									aDocs[nZ,CLDDTATE],;  	//--21
									aDocs[nZ,CLDTPFRDV],;	//--22
									aDocs[nZ,CLDCODNEG],;	//--23
									cDesNeg })				//--24
				Else
					lNegBco := .T.
					lSrvBco := .T.
					Aadd(aFatCli, {	.T.,;					//--01
									cNumSeq,;				//--02
									cCodCli,;				//--03
									cLojCli,;				//--04
									cNomCli,;				//--05
									aDocs[nZ,CLDVALFAT] + (aDocs[nZ,CLDACRESC] - aDocs[nZ,CLDDECRES]),;	//--06
									nQtdCtrc,;				//--07
									nValMax,;				//--08
									aDocs[nZ,CLDCNDPAG],;	//--09
									aDocs[nZ,CLDFILDEB],;	//--10
									aDocs[nZ,CLDGRPPRD],;	//--11
									aDocs[nZ,CLDUFQBR],;	//--12
									aDocs[nZ,CLDDOCTMS],;	//--13
									aDocs[nZ,CLDTPTRA],;	//--14
									aDocs[nZ,CLDTPFRE],;	//--15
									aDocs[nZ,CLDDATENT],;	//--16
									aDocs[nZ,CLDDTEMIS],;	//--17
									{},;					//--18
									'',;					//--19
									'',;					//--20
									aDocs[nZ,CLDDTATE],;  	//--21
									aDocs[nZ,CLDTPFRDV],;	//--22
									'',;					//--23
									'' })					//--24
				EndIf
			Else
				//-- Verifica se a soma do(s) titulo(s) anterior(es) com o titulo posicionado ultrapassa o valor limite(DUO_VALMAX)
				If nValMax >= nValorFat + aDocs[nZ,CLDVALFAT]+aDocs[nZ,CLDACRESC]-aDocs[nZ,CLDDECRES]
					aFatCli[nPosFat, CLVLFAT] +=  aDocs[nZ,CLDVALFAT]+aDocs[nZ,CLDACRESC]-aDocs[nZ,CLDDECRES]
				Else
					lAAddDoc := .F. //-- Se ultrapassar o limite, nao adiciona o documento na fatura
				EndIf
			EndIf
	
			//-- Adiciona o Documento na Fatura
			//-- Se Nao for adicionar o documento nesta fatura, sai do laco, para que este documento seja
			//-- adicionado na proxima
			If lAAddDoc
				Tmsa491AAdd(nZ,aFatCli)
			Else
				Exit
			EndIf
	
			nCtrcFat  += 1 // Soma os CTRC's por fatura.
			nVlrTot   += aDocs[nZ,CLDVALFAT]+aDocs[nZ,CLDACRESC]-aDocs[nZ,CLDDECRES] //-- Armazena o valor Total de todas as faturas.
			nValorFat += aDocs[nZ,CLDVALFAT]+aDocs[nZ,CLDACRESC]-aDocs[nZ,CLDDECRES] //-- Armazena o valor Total da Fatura	
		Next
	EndIf	
	nX := (nZ-1)		
Next

DbSelectArea("SE1")


If lMostra .And. !lThread
	If Len(aFatCli) > 0

		TMSA491Aju( @aFatCli, @nVlrTot )

		DEFINE MSDIALOG oDlg TITLE STR0025 FROM 2, 0 TO 40, 153  OF oMainWnd //"Faturas por Clientes"
			
			If !lNegBco .And. !lSrvBco	//-- Não existem negociações em branco ### Não existem serviços em branco
				@ 33,03 LISTBOX oItem ;
						VAR cOpc ;
						Fields HEADER "",STR0026,STR0027,STR0028,STR0029,STR0078,STR0045,STR0048,STR0045,STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0037 ;  //"Sequencia"###"Cliente"###"Loja"###"Nome"###"Serviço"###"Descrição"###"Cod Negociação"###"Descrição"###"Vlr. Fatura"###"Fil.Debito"###"Grp.Prod."###"Estado"###"Doc.Transp."###"Tip.Transp"###"Tipo Frete"###"CTRC Entregue"
						SIZE 600,220 ;
						ON DBLCLICK(aFatCli:=a491MrkList(oItem:nAt, aFatCli, @nVlrTot, oVlrTot),oItem:Refresh()) NOSCROLL ;
						OF oDlg PIXEL

				oItem:SetArray(aFatCli)
				oItem:bLine := {|| {If(aFatCli[oItem:nAt,1],oOk,oNo),aFatCli[oItem:nAt,CLSEQ],aFatCli[oItem:nAt,CLCOD],aFatCli[oItem:nAt,CLLOJA],;
									   aFatCli[oItem:nAt,CLNOME],aFatCli[oItem:nAt,CLCODNEG],aFatCli[oItem:nAt,CLDESNEG],aFatCli[oItem:nAt,CLSERVIC],;
									   aFatCli[oItem:nAt,CLDESSRV],AllTrim(Transform(aFatCli[oItem:nAt,CLVLFAT], PesqPict("SE1", "E1_SALDO"))),;
									   aFatCli[oItem:nAt,CLFILDEB],aFatCli[oItem:nAt,CLGRUPO],aFatCli[oItem:nAt,CLEST],aFatCli[oItem:nAt,CLDOCTMS],;
									   aFatCli[oItem:nAt,CLTIPTRA],aFatCli[oItem:nAt,CLTIPFRE],aFatCli[oItem:nAt,CLCTRCENT]}}
				oItem:bHeaderClick:= {|oObj,nCol| If(nCol==1,aFatCli:=a491MrkAll(oItem, aFatCli, @nVlrTot, oVlrTot),oItem:Refresh())}
			ElseIf !lNegBco	//-- Não existem negociações em branco ### Existem serviços em branco
				@ 33,03 LISTBOX oItem ;
						VAR cOpc ;
						Fields HEADER "",STR0026,STR0027,STR0028,STR0029,STR0078,STR0045,STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0037 ;  //"Sequencia"###"Cliente"###"Loja"###"Nome"###"Serviço"###"Descrição"###"Cod Negociação"###"Descrição"###"Vlr. Fatura"###"Fil.Debito"###"Grp.Prod."###"Estado"###"Doc.Transp."###"Tip.Transp"###"Tipo Frete"###"CTRC Entregue"
						SIZE 600,220 ;
						ON DBLCLICK(aFatCli:=a491MrkList(oItem:nAt, aFatCli, @nVlrTot, oVlrTot),oItem:Refresh()) NOSCROLL ;
						OF oDlg PIXEL

				oItem:SetArray(aFatCli)
				oItem:bLine := {|| {If(aFatCli[oItem:nAt,1],oOk,oNo),aFatCli[oItem:nAt,CLSEQ],aFatCli[oItem:nAt,CLCOD],aFatCli[oItem:nAt,CLLOJA],;
									   aFatCli[oItem:nAt,CLNOME],aFatCli[oItem:nAt,CLCODNEG],aFatCli[oItem:nAt,CLDESNEG],;
									   AllTrim(Transform(aFatCli[oItem:nAt,CLVLFAT], PesqPict("SE1", "E1_SALDO"))),;
									   aFatCli[oItem:nAt,CLFILDEB],aFatCli[oItem:nAt,CLGRUPO],aFatCli[oItem:nAt,CLEST],aFatCli[oItem:nAt,CLDOCTMS],;
									   aFatCli[oItem:nAt,CLTIPTRA],aFatCli[oItem:nAt,CLTIPFRE],aFatCli[oItem:nAt,CLCTRCENT]}}
				oItem:bHeaderClick:= {|oObj,nCol| If(nCol==1,aFatCli:=a491MrkAll(oItem, aFatCli, @nVlrTot, oVlrTot),oItem:Refresh())}

			ElseIf !lSrvBco	//-- Existem negociações em branco ### Não existem serviços em branco
				@ 33,03 LISTBOX oItem ;
						VAR cOpc ;
						Fields HEADER "",STR0026,STR0027,STR0028,STR0029,STR0048,STR0045,STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0037 ;  //"Sequencia"###"Cliente"###"Loja"###"Nome"###"Serviço"###"Descrição"###"Cod Negociação"###"Descrição"###"Vlr. Fatura"###"Fil.Debito"###"Grp.Prod."###"Estado"###"Doc.Transp."###"Tip.Transp"###"Tipo Frete"###"CTRC Entregue"
						SIZE 600,220 ;
						ON DBLCLICK(aFatCli:=a491MrkList(oItem:nAt, aFatCli, @nVlrTot, oVlrTot),oItem:Refresh()) NOSCROLL ;
						OF oDlg PIXEL

				oItem:SetArray(aFatCli)
				oItem:bLine := {|| {If(aFatCli[oItem:nAt,1],oOk,oNo),aFatCli[oItem:nAt,CLSEQ],aFatCli[oItem:nAt,CLCOD],aFatCli[oItem:nAt,CLLOJA],;
									   aFatCli[oItem:nAt,CLNOME],aFatCli[oItem:nAt,CLSERVIC],aFatCli[oItem:nAt,CLDESSRV],;
									   AllTrim(Transform(aFatCli[oItem:nAt,CLVLFAT], PesqPict("SE1", "E1_SALDO"))),;
									   aFatCli[oItem:nAt,CLFILDEB],aFatCli[oItem:nAt,CLGRUPO],aFatCli[oItem:nAt,CLEST],aFatCli[oItem:nAt,CLDOCTMS],;
									   aFatCli[oItem:nAt,CLTIPTRA],aFatCli[oItem:nAt,CLTIPFRE],aFatCli[oItem:nAt,CLCTRCENT]}}
				oItem:bHeaderClick:= {|oObj,nCol| If(nCol==1,aFatCli:=a491MrkAll(oItem, aFatCli, @nVlrTot, oVlrTot),oItem:Refresh())}

			Else	//-- Existem negociações em branco ### Existem serviços em branco
				@ 33,03 LISTBOX oItem ;
						VAR cOpc ;
						Fields HEADER "",STR0026,STR0027,STR0028,STR0029,STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0037 ;  //"Sequencia"###"Cliente"###"Loja"###"Nome"###"Vlr. Fatura"###"Fil.Debito"###"Grp.Prod."###"Estado"###"Doc.Transp."###"Tip.Transp"###"Tipo Frete"###"CTRC Entregue"
						SIZE 600,220 ;
						ON DBLCLICK(aFatCli:=a491MrkList(oItem:nAt, aFatCli, @nVlrTot, oVlrTot),oItem:Refresh()) NOSCROLL OF ;
						oDlg PIXEL

				oItem:SetArray(aFatCli)
				oItem:bLine := {|| {If(aFatCli[oItem:nAt,1],oOk,oNo),aFatCli[oItem:nAt,CLSEQ],aFatCli[oItem:nAt,CLCOD],aFatCli[oItem:nAt,CLLOJA],;
									   aFatCli[oItem:nAt,CLNOME],AllTrim(Transform(aFatCli[oItem:nAt,CLVLFAT], PesqPict("SE1", "E1_SALDO"))),;
									   aFatCli[oItem:nAt,CLFILDEB],aFatCli[oItem:nAt,CLGRUPO],aFatCli[oItem:nAt,CLEST],aFatCli[oItem:nAt,CLDOCTMS],;
									   aFatCli[oItem:nAt,CLTIPTRA],aFatCli[oItem:nAt,CLTIPFRE],aFatCli[oItem:nAt,CLCTRCENT]}}
				oItem:bHeaderClick:= {|oObj,nCol| If(nCol==1,aFatCli:=a491MrkAll(oItem, aFatCli, @nVlrTot, oVlrTot),oItem:Refresh())}
			EndIf

			oPanel := tPanel():New(260,03,"",oDlg,,,,,CLR_WHITE,600, 20, .T.)

			@ 006, 008 SAY STR0038 SIZE 060,009 OF oPanel PIXEL COLOR CLR_BLUE //"Total da(s) Fatura(s) : "
			@ 264, 070 MSGET oVlrTot VAR nVlrTot PICTURE PesqPict("SE1", "E1_SALDO") SIZE 80, 010 OF oDlg PIXEL WHEN( .F. ) HASBUTTON

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA := 1, oDlg:End()},{||oDlg:End()},,aButtons )
	Else
		Help(" ", 1,"TMSA49008") //"Nenhum documento encontrado para geração da(s) fatura(s)"
	EndIf

ElseIf lThread
	nOpcA := 1 // Forcar o Processamento sem intervencao do Usuario
EndIf

If !lMostra .Or. nOpcA == 1

	//--Se existir pelo menos um
	//--registro selecionado para processamento...
	For nX := 1 To Len( aFatCli )
		If aFatCli[nX,1]
			lProcessa := .T.
			Exit
		EndIf
	Next

	If lProcessa
		Processa({|lEnd| Tmsa491GrvFat(aFatCli, cAliasTRB, cNat, cNatRod, cNatAer, cNatFlu, @aMsgFat)},STR0011) //"Gerando Faturas ..."
	Else
		If ! lMostra
			TmsLogMsg("WARN",STR0056) //  "Nenhum documento encontrado para geração da(s) fatura(s)"			
		Else
			Help(" ", 1,"TMSA49008") //"Nenhum documento encontrado para geração da(s) fatura(s)"
		EndIf
	EndIf
	//-- Destrava o registro ao Confirmar a tela.
	If lCONTDOC .And. !Empty(aDocs)	
		For nX := 1 to Len(aDocs)
			TmsConTran(aDocs[nX,CLDFILDOC],aDocs[nX,CLDDOC],aDocs[nX,CLDSERIE], .F.)
		Next nX								 					 
	EndIf	
EndIf

//-- Libera o Lock de todos os clientes da Fatura
If lProcessa .Or. nOpcA = 0 
	For nCntFor1 := 1 To Len(aFatCli)
		cChave := "FAT"+aFatCli[nCntFor1][CLFILDEB]+aFatCli[nCntFor1][CLCOD]+aFatCli[nCntFor1][CLLOJA]
		//-- Verifica se a trava do cliente ja foi liberada; Isto porque, o array aFatcli pode 
		//-- conter varias quebras para o mesmo cliente
		If Ascan(aLibCli,cChave) == 0
			Aadd(aLibCli,cChave)
			If	Len(aChave) == 0
				UnLockByName(cChave,.T.,.F.) //-- Libera Lock
			Else
				For nCntFor2 := 1 To Len(aChave)
					UnLockByName(cChave+aChave[nCntFor2],.T.,.F.) //-- Libera Lock
				Next nCntFor2
			EndIf
		EndIf
	Next

	// se foi chamado pelo schedule adiciona os dados das faturas geradas no vetor
	// para ser enviado por email
	If ExecSchedule()
		nTotFat := Len(aFatCli)
		If nTotFat > 0
			If cTmsERP == '1' //-- ERP Datasul
				AdicionaMsg(STR0072+Strzero(Len(aFatCli),5)) // "Total de Faturas processadas :"
			Else
				AdicionaMsg(STR0065+Strzero(Len(aFatCli),5)) // "Total de Faturas geradas :" 
			EndIf
		EndIf
	EndIf
	//-- Destrava o registro ao Fechar a tela.
	If lCONTDOC .And. !Empty(aDocs)	
		For nX := 1 to Len(aDocs)
			TmsConTran(aDocs[nX,CLDFILDOC],aDocs[nX,CLDDOC],aDocs[nX,CLDSERIE], .F.)
		Next nX								 					 
	EndIf	
EndIf

//-- Limpa marcas dos agendamentos
//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

aDocs := {}

aEval(aAreas,{|x,y| RestArea(x) })

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491AAdd³ Autor ³Patricia Antar Salomao³ Data ³ 19/01/05      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adiciona  os documentos no vetor da Fatura (aFatCli)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA491AAdd()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Linha do Documento                                       ³±±
±±³          ³ExpA2 - Vetor contendo todas as Faturas                          ³±±
±±³          ³ExpA3 - Recno do DT6 que foi gerado com base em doctos de apoio  ³±±
±±³          ³ExpA4 - aDoctos instanciado pela função  TMSGeraSD2              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA491                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA491AAdd(nZ,aFatCli,nRecnoDT6,aDoctosRef)
Local aDoctos := {/*[01]*/ .T. }
Local lCONTDOC := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
					//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.
Local aDT6Area := DT6->(GetArea())
Local aDUYArea := DUY->(GetArea())

Default nRecnoDT6 := 0

If nRecnoDT6 > 0
	DT6->(DbGoto(nRecnoDT6))
EndIf

//--A estrura do aDoctos tem que ser a mesma do aCampos 
AADD(aDoctos, /*[02]*/IIF(nRecnoDT6>0,DT6->DT6_FILDOC,aDocs[nZ,CLDFILDOC]))
AADD(aDoctos, /*[03]*/IIF(nRecnoDT6>0,DT6->DT6_DOC   ,aDocs[nZ,CLDDOC]))
AADD(aDoctos, /*[04]*/IIF(nRecnoDT6>0,DT6->DT6_SERIE ,aDocs[nZ,CLDSERIE]))
AADD(aDoctos, /*[05]*/IIF(nRecnoDT6>0,DT6->DT6_VALTOT,aDocs[nZ,CLDVALTOT]))
AADD(aDoctos, /*[06]*/IIF(nRecnoDT6>0,DT6->DT6_ACRESC,aDocs[nZ,CLDACRESC]))
AADD(aDoctos, /*[07]*/IIF(nRecnoDT6>0,DT6->DT6_DECRES,aDocs[nZ,CLDDECRES]))
AADD(aDoctos, /*[08]*/IIF(nRecnoDT6>0,DT6->(DT6_VALFAT+DT6_ACRESC-DT6_DECRES),aDocs[nZ,CLDVALFAT]+aDocs[nZ,CLDACRESC]-aDocs[nZ,CLDDECRES]))
AADD(aDoctos, /*[09]*/IIF(nRecnoDT6>0,DT6->DT6_DATEMI,aDocs[nZ,CLDDATEMI]))
AADD(aDoctos, /*[10]*/IIF(nRecnoDT6>0,posicione("DUY",1,xFilial("DUY")+DT6->DT6_CDRDES,"DUY_EST"),aDocs[nZ,CLDESTDES]))
AADD(aDoctos, /*[11]*/IIF(nRecnoDT6>0,nRecnoDT6,aDocs[nZ,CLDRECNO]))
AADD(aDoctos, /*[12]*/IIF(nRecnoDT6>0,DT6->DT6_CLIDES,aDocs[nZ,CLDCLIDES]))
AADD(aDoctos, /*[13]*/IIF(nRecnoDT6>0,DT6->DT6_LOJDES,aDocs[nZ,CLDLOJDES]))
AADD(aDoctos, /*[14]*/IIF(nRecnoDT6>0,DT6->DT6_CLIREM,aDocs[nZ,FTCLIREM]))
AADD(aDoctos, /*[15]*/IIF(nRecnoDT6>0,DT6->DT6_LOJREM,aDocs[nZ,FTLOJREM]))
AADD(aDoctos, /*[16]*/IIF(nRecnoDT6>0,DT6->DT6_CLIDES,aDocs[nZ,FTCLIDES]))
AADD(aDoctos, /*[17]*/IIF(nRecnoDT6>0,DT6->DT6_LOJDES,aDocs[nZ,FTLOJDES]))
AADD(aDoctos, /*[18]*/IIF(nRecnoDT6>0,DT6->DT6_CLIDEV,aDocs[nZ,FTCLIDEV]))
AADD(aDoctos, /*[19]*/IIF(nRecnoDT6>0,DT6->DT6_LOJDEV,aDocs[nZ,FTLOJDEV]))
AADD(aDoctos, /*[20]*/IIF(nRecnoDT6>0,DT6->DT6_TIPFRE,aDocs[nZ,CLDTPFRE])) 
AADD(aDoctos, /*[21]*/IIF(nRecnoDT6>0,DT6->DT6_CDRORI,aDocs[nZ,FTCDRORI]))
AADD(aDoctos, /*[22]*/IIF(nRecnoDT6>0,DT6->DT6_CDRDES,aDocs[nZ,FTCDRDES]))
AADD(aDoctos, /*[23]*/IIF(nRecnoDT6>0,DT6->DT6_CDRCAL,aDocs[nZ,FTCDRCAL]))
AADD(aDoctos, /*[24]*/IIF(nRecnoDT6>0,DT6->DT6_CLICON,aDocs[nZ,FTCLICON])) 
AADD(aDoctos, /*[25]*/IIF(nRecnoDT6>0,DT6->DT6_LOJCON,aDocs[nZ,FTLOJCON])) 
AADD(aDoctos, /*[26]*/IIF(nRecnoDT6>0,DT6->DT6_CLIDPC,aDocs[nZ,FTCLIDPC])) 
AADD(aDoctos, /*[27]*/IIF(nRecnoDT6>0,DT6->DT6_LOJDPC,aDocs[nZ,FTLOJDPC]))

 //+---------------------------------------------------------------------------------
 //| Adicionar novos campos pesquisar pela marca #AddNewFields para facilitar
 //| na busca dos pontos em que os campos precisam ser inseridos.
 //+---------------------------------------------------------------------------------
 //| #AddNewFields
 AADD(aDoctos, /*[28]*/IIF(nRecnoDT6>0,DT6->DT6_CLIEXP,aDocs[nZ,FTCLIEXP]))
 AADD(aDoctos, /*[29]*/IIF(nRecnoDT6>0,DT6->DT6_LOJEXP,aDocs[nZ,FTLOJEXP]))
 AADD(aDoctos, /*[30]*/IIF(nRecnoDT6>0,DT6->DT6_CLIREC,aDocs[nZ,FTCLIREC]))
 AADD(aDoctos, /*[31]*/IIF(nRecnoDT6>0,DT6->DT6_LOJREC,aDocs[nZ,FTLOJREC]))

//+----------------------------------------------------------------------------------
//| Retorna para a posição original para não peder a informação do próximo documento de apoio
//| para que a variavel cDocTms seja recuperada de acordo com o campo DUI_DOCFAT
//+----------------------------------------------------------------------------------
RestArea(aDT6Area)
RestArea(aDUYArea)

//-- Trava o registro que está sendo usado por outra estação
If nRecnoDT6 == 0
	If lCONTDOC .And. !Empty(aDoctos) 
		If !TmsConTran(aDoctos[LAFILDOC],aDoctos[LADOC],aDoctos[LASERIE], .T.)
			Return .F.	
		Else
			Aadd(aFatCli[Len(aFatCli),CLDOCTOS], AClone(aDoctos))
		EndIf		
	Else
		Aadd(aFatCli[Len(aFatCli),CLDOCTOS], AClone(aDoctos))
	EndIf
Else
	AADD(aDoctosRef,aClone(aDoctos))
EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a491MrkAll³ Autor ³Vicco                  ³ Data ³27.12.12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos itens do ListBox.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ a491MrkAll(ExpN1, ExpA1, ExpN2, ExpO2).                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Objeto do ListBox.                                 ³±±
±±³          ³ ExpA1 = Array do ListBox(Faturas por Cliente).             ³±±
±±³          ³ ExpN1 = Valor total da Fatura.                             ³±±
±±³          ³ ExpO1 = Objeto do valor total da fatura.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA491                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a491MrkAll(oIt, aFatCli, nVlrTot, oVlrTot)
Local nCntFor := 0
Local lMarca  := aFatCli[1,1]
For nCntFor := 1 To Len( aFatCli )
	If (!lMarca .And. !aFatCli[nCntFor,1]) .Or. (lMarca .And. aFatCli[nCntFor,1])
		oIt:nAt := nCntFor
		aFatCli := a491MrkList(nCntFor, aFatCli, @nVlrTot, oVlrTot)
	EndIf 
Next nCntFor
oIt:nAt := 1
oIt:Refresh(.T.)
Return (aFatCli)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A491MrkLis³ Autor ³Patricia Antar Salomao ³ Data ³20.01.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca o item do ListBox.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A491MrkList(ExpN1, ExpA1, ExpN2, ExpO2).                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Item do ListBox.                                   ³±±
±±³          ³ ExpA1 = Array do ListBox(Faturas por Cliente).             ³±±
±±³          ³ ExpN1 = Valor total da Fatura.                             ³±±
±±³          ³ ExpO1 = Objeto do valor total da fatura.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA491                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A491MrkList(nIt, aFatCli, nVlrTot, oVlrTot)

Local cMarkTrb := Nil
Local lMostrouHelp := .F.
Local lCONTDOC	:= SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran")//--Parametro para controle de Transações da Viagem mod2,
					//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.

/* Inverte a marca do listbox. */
aFatCli[nIt,1] := !aFatCli[nIt,1]
cMarkTrb       := Iif(aFatCli[nIt, 1], cMarca, "  ")

If aFatCli[nIt, 1]
	nVlrTot += aFatCli[nIt, CLVLFAT]
Else
	nVlrTot -= aFatCli[nIt, CLVLFAT]
EndIf

//-- Trava o registro que está sendo usado por outra estação 			
If lCONTDOC .And. !Empty(cMarkTrb)
	DT6->(DbSetOrder(1))
	If DT6->(dbSeek(xFilial("DT6")+aFatCli[nIt][18][1][2]+aFatCli[nIt][18][1][3]+aFatCli[nIt][18][1][4]))
		If DT6->DT6_STATUS $ "B/C" 
			Help("  ",1,"TMSA14438",,+"-"+ STR0034 + DT6->DT6_FILDOC +"-"+ DT6->DT6_DOC +"-"+ DT6->DT6_SERIE,5,18)
			lMostrouHelp   := .T.	

			aFatCli[nIt,1] := .F.
			oVlrTot:Refresh()		
			Return(aFatCli)	
		ElseIf DT6->DT6_STATUS == "D" 
			Help("  ",1,"TMSA14437",, +"-"+ STR0034 + DT6->DT6_FILDOC +"-"+ DT6->DT6_DOC +"-"+ DT6->DT6_SERIE,5,18)
			lMostrouHelp   := .T.	

			aFatCli[nIt,1] := .F.
			oVlrTot:Refresh()		
			Return(aFatCli)	
		ElseIf !lMostrouHelp .And. !TmsConTran(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE, .T.)  
			aFatCli[nIt,1] := .F.
			oVlrTot:Refresh()					
			Return(aFatCli)										
		EndIf		
	EndIf
EndIf 

oVlrTot:Refresh()

Return (aFatCli)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa491Det ³ Autor ³Patricia Antar Salomao³ Data ³ 19/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe uma tela com todos os documentos da Fatura            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa491Det()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Vetor contendo todas as Faturas                     ³±±
±±³          ³ExpN1 - Linha da Fatura                                     ³±±
±±³          ³ExpA2 - Vetor contendo os campos que serao visualizados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSa491                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tmsa491Det(	aFatCli, nLinha, aCampos, nVlrTot, oVlrTot,; 
							cNat, cNatRod, cNatAer, cNatFlu )

Local nMoedFat    := 1
Local aTitulos    := {}
Local aDoctos     := {}
Local nOpcA       := 0
Local nValor      := aFatCli[nLinha, CLVLFAT]  // Valor da Fatura (Sera atualizado na rotina de marcacao)
Local aVFContr    := {}
Local aNatCli     := {}

Default cNat      := ''
Default cNatRod   := ''
Default cNatAer   := ''
Default cNatFlu   := ''

//-- Estas Variaveis sao utilizados pelo programa TMSA850 .. NAO RETIRAR !!!
Private nQtdCtrc  := 0  // Qtde. de Documentos de cada Fatura
Private nMinCtrc  := 0  // Valor Minimo de CTRC por Fatura
Private nMaxCtrc  := 0
Private nValorFat := aFatCli[nLinha, CLVALMAX] // Valor Total da Fatura
Private nValorF   := 0 // Deve ficar com 0 para permitir que o usuario realize ajustes nos ctrcs da fatura
Private aHeader   := {}
Private aCols     := {}
Private lFtAut    := .T.

If Type("cCli") == "U"
	cCli     := aFatCli[nLinha,3]
	_cLoja   := aFatCli[nLinha,4]
	cFilDeb  := aFatCli[nLinha,10]
	MV_PAR02 := 2
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com campos a serem mostrados na marcacao de ctrc   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aTitulos," ")
aEval(aCampos, { |e|	If(e[1] = "_SI_VALFAT", Aadd(aTitulos,STR0039),; //"Valor a faturar"
						If(e[1] = "_SI_UFDEST", Aadd(aTitulos,STR0040),; //"Uf Destino"
						Aadd(aTitulos, FWX3Titulo(If(e[1]="DT6_VALTOT","DT6_VALFRE",e[1]))))) } )

aDoctos := Aclone(aFatCli[nLinha,CLDOCTOS])

aSort( aDoctos,,,{ |x,y| x[2]+x[3]+x[4] < y[2]+y[3]+y[4]})

// Contador (sera autilizado na rotina de marcacao)
// nQtdCtrc  := Len(aDoctos) 
AEval(aDoctos, {|campos| If(campos[1],nQtdCtrc++,)} ) //--Realiza contagem de todos os documentos marcados
nMaxCtrc  := Len(aDoctos) // Qtde Maxima de CTRC por Fatura (sera utilizado para comparacao com o contador)

If lTM491CLI
	aNatCli := ExecBlock('TM491CLI',.F.,.F.,{aFatCli[nLinha][CLCOD],aFatCli[nLinha][CLLOJA],cNat,cNatRod,cNatAer,cNatFlu,aDoctos}) 
	//aNatCli[1] := Natureza da Fatura (Generico)
	//aNatCli[2] := Natureza da Fatura Transporte Rodoviario
	//aNatCli[3] := Natureza da Fatura Transporte Aereo
	//aNatCli[4] := Natureza da Fatura Transporte Fluvial
	If ValType(aNatCli) <> 'A'
		aNatCli   := {}
	Else
		If !Empty(aNatCli)
			cNat        := aNatCli[1] // Natureza da Fatura (Generico)
			If Len(aNatCli) >= 2
				cNatRod  := aNatCli[2] // Natureza da Fatura Transporte Rodoviario
			EndIf
			If Len(aNatCli) >= 3
				cNatAer  := aNatCli[3] // Natureza da Fatura Transporte Aereo
			EndIf
			If Len(aNatCli) >= 4
				cNatFlu  := aNatCli[4] // Natureza da Fatura Transporte Fluvial	
			EndIf
		EndIf
	EndIf
EndIf

//-- Se a Fatura foi separada por Tipo de Transporte
If !Empty(cNatRod) .And. aFatCli[nLinha,CLTIPTRA] == '1'  // Transporte Rodoviario
	cNat := cNatRod //-- Natureza Transporte Rodoviario
ElseIf !Empty(cNatAer) .And. aFatCli[nLinha,CLTIPTRA] == '2'  // Transporte Aereo
	cNat := cNatAer //-- Natureza Transporte Aereo
ElseIf !Empty(cNatFlu) .And. aFatCli[nLinha,CLTIPTRA] == '3'  // Transporte Fluvial
	cNat := cNatFlu //-- Natureza Transporte Fluvial
EndIf

//-- Posiciona no SA1 para que a Tmsa850tela() exiba o nome do cliente da Fatura
SA1->(dbSetOrder(1))
SA1->(MsSeek(xFilial('SA1')+ aFatCli[nLinha][CLCOD]+ aFatCli[nLinha][CLLOJA]))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina responsavel por buscar o valor Fixo de Cobranca e o Imposto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValCImp := 0

If ( Len(aFatCli[nLinha,18]) > 0 )

	If !Empty(aFatCli[nLinha][CLSERVIC])
		//--Verifica a configuracao do contrato
		//--em relacao ao valor fixo (Veiculo Dedicado):
		aVFContr := TMSA491VlrC( 	aFatCli[nLinha, CLCOD], aFatCli[nLinha, CLLOJA],; 
									aFatCli[nLinha, CLTIPFRE] , aFatCli[nLinha, CLSERVIC],;
									aFatCli[nLinha, CLDTATE],,aFatCli[nLinha][CLTPFRDV])

		If Len(aVFContr) > 0
			nValCImp := aVFContr[5]
		EndIf
	EndIf
EndIf

nOpcA := Tmsa850Tela( .F., cPrefix, "", cNat, nMoedFat, 3,;
						aCampos, aTitulos, aDoctos, @nValor, 0, .F.,;
						.F., 0, nValCImp, aFatCli, nLinha,,,,,,@aVFContr )

If nOpcA <> 2
	// Subtrai o valor da fatura atual, para recalcular possiveis ajustes efetuados pelo usuario
	nVlrTot -= aFatCli[nLinha,CLVLFAT] 
	// Armazena as alteracoes efetuadas nos doctos, pelo usuario
	aFatCli[nLinha,CLDOCTOS] := aClone(aDoctos)
	aFatCli[nLinha,CLVLFAT]  := nValor
	// Recalcula o novo valor total das faturas
	nVlrTot += aFatCli[nLinha,CLVLFAT]
EndIf

oVlrTot:Refresh()

Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa491Grv³ Autor ³Patricia Antar Salomao ³ Data ³19.01.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava as faturas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa491GrvFat()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Vetor contendo as Faturas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA491                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa491GrvFat(aFatCli, cAliasTRB, cNat, cNatRod, cNatAer, cNatFlu, aMsgFat)
Local nCntFor     := 1
Local n2Cnt       := 1
Local lMostraGet  := .F. //-- Nao exibir tela na funcao TMSA850Grv()
Local cCondicao   := ''
Local nMoedFat    := 1
Local aDoctos     := {}
Local cTipTra     := ''
Local cNumNFS     := ''
Local dDtaEmissao := Ctod('')
Local cPrefDT6    := ''
Local nValor      := 0
Local lGeraDT6    := !Empty(mv_par12) .And. !Empty(cDocFat) //-- Diferente de documento normal
Local aVFContr    := {}
Local nRecDT6     := 0
Local nValFat     := 0
Local aFtGeradas  := {}
Local lMV_TMSFMSG := SuperGetMv("MV_TMSFMSG",.F.,.T.)
Local lMV_TMSNFAT := SuperGetMv("MV_TMSNFAT",.F.,.T.)
Local cTmsERP     := SuperGetMV("MV_TMSERP",,'0')
Local aErrosInt   := {}
Local nContErro   := 0
Local aNatCli     := {}
Local cMv_Estado  := ''
Local cTMA490     := "TMA490"
Local aTmpDocs    := {}

Default cNat     := ''
Default cNatRod  := ''
Default cNatAer  := ''
Default cNatFlu  := ''
Default aMsgFat  := {}

//-- Variaveis utilizadas pelo programa TMSA850 .. Nao Retirar !!!
Private aCols    := {}
Private aHeader  := {}
Private aDocAct  := {}
Private cCli     := ''
Private _cLoja   := ''
Private cFilDeb  := ''
Private cCliFat  := CriaVar('A1_COD' ,.F.)
Private cLojaFat := CriaVar('A1_LOJA',.F.)

//-- Variavel utilizada pelo programa TMSA491
Private nTipoDoc := Iif( !Empty(mv_par12) .And. mv_par12 == 'B', 2, 0 )  //Documento de Apoio 1

If Valtype(lDUISEROUT) == "U"
	lDUISEROUT := DUI->(FieldPos("DUI_SEROUT")) > 0 //-- Serie Outra UF
EndIf

If	cMv_Estado == ""
	cMv_Estado := SuperGetMV("MV_ESTADO",.F.,"")//--O tratamento específico abaixo para o estado do Parana foi retirado de acordo com conformidade do art. 11, II e IV da LC nº 87/96.
EndIf

Pergunte("AFI280", .F.) // Carrega as Perguntas do programa Fina280 (executado na funcao TMSA850Grava())

If lGeraDT6	
	If !Empty(GetMV("MV_DATAFIS",,"")) .AND. !ExecSchedule()
		If !FisChkDt(dDataBase)
			Return( .F. )
		EndIf
	EndIf
	DUI->(DbSetOrder(1))		
	If DUI->(DbSeek(xFilial("DUI")+cDocFat))
		cPrefDT6 := DUI->DUI_SERIE		  
	EndIf
EndIf

For nCntFor := 1 To Len(aFatCli)
	//--Inicia processamento dos Documentos marcados para fatura
	Begin Transaction
		If aFatCli[nCntFor][1] .And. aFatCli[nCntFor][CLVLFAT] > 0  //-- Se a Fatura estiver Marcada e tiver documentos marcados
			cCli        := aFatCli[nCntFor][CLCOD]
			_cLoja      := aFatCli[nCntFor][CLLOJA]
			nValor      := aFatCli[nCntFor][CLVLFAT]
			cCondicao   := aFatCli[nCntFor][CLCOND]
			cFilDeb     := aFatCli[nCntFor][CLFILDEB]
			aDoctos     := aFatCli[nCntFor][CLDOCTOS]
			dDtaEmissao := aFatCli[nCntFor][CLDATEMI]
			aCols       := {}
			aHeader     := {}

			//------------------------------------------------------------
			//-- Criando aDoctos para o ponto de entrada TM491CLI.
			//------------------------------------------------------------
			aDoctos := Aclone(aFatCli[nCntFor,CLDOCTOS])
			For n2Cnt := 1 To Len(aDoctos)
				If aDoctos[n2Cnt,1] == .T.
					Aadd(aTmpDocs,aDoctos[n2Cnt])
				EndIf
			Next n2Cnt
			aDoctos := aClone(aTmpDocs)
			aSize(aTmpDocs,0); aTmpDocs := {}

			//-- Ordena os documentos por filial,doc e serie
			aSort(aDoctos,,,{|x,y| x[2]+x[3]+x[4] < y[2]+y[3]+y[4]})
			//---Verifica a região de origem 	
			For n2Cnt := 1 To Len(aDoctos)
				If aDoctos[n2Cnt][LACDRORI] <> cFilant
				 	cDUYEST :=	aDoctos[n2Cnt][LACDRORI]
				EndIf						
			Next 			
			If lGeraDT6	
				cDUYEST := Posicione("DUY",1,xFilial("DUY")+cDUYEST,"DUY_EST")				
				//-- Verifica se informou serie para origem em outra filial.
				If	lDUISEROUT .And. !Empty(DUI->DUI_SEROUT)
					If	cMv_Estado <> cDUYEST
						cPrefDT6 := DUI->DUI_SEROUT //--Serie Outra UF
					EndIf			
				EndIf
			EndIf
			If lTM491CLI
				aNatCli := ExecBlock('TM491CLI',.F.,.F.,{cCli,_cLoja,cNat,cNatRod,cNatAer,cNatFlu,aDoctos}) 
				//aNatCli[1] := Natureza da Fatura (Generico)
				//aNatCli[2] := Natureza da Fatura Transporte Rodoviario
				//aNatCli[3] := Natureza da Fatura Transporte Aereo
				//aNatCli[4] := Natureza da Fatura Transporte Fluvial
				If ValType(aNatCli) <> 'A'
					aNatCli := {}
				Else
					If !Empty(aNatCli)
						cNat := aNatCli[1] // Natureza da Fatura (Generico)
						If Len(aNatCli) >= 2
							cNatRod := aNatCli[2] // Natureza da Fatura Transporte Rodoviario
						EndIf
						If Len(aNatCli) >= 3
							cNatAer := aNatCli[3] // Natureza da Fatura Transporte Aereo
						EndIf
						If Len(aNatCli) >= 4
							cNatFlu := aNatCli[4] // Natureza da Fatura Transporte Fluvial	
						EndIf
					EndIf
				EndIf
			EndIf
			//-- Se a Fatura foi separada por Tipo de Transporte
			If		!Empty(cNatRod) .And. aFatCli[nCntFor,CLTIPTRA] == '1' // Transporte Rodoviario
				cNat := cNatRod //-- Natureza Transporte Rodoviario
			ElseIf  !Empty(cNatAer) .And. aFatCli[nCntFor,CLTIPTRA] == '2' // Transporte Aereo
				cNat := cNatAer //-- Natureza Transporte Aereo
			ElseIf  !Empty(cNatFlu) .And. aFatCli[nCntFor,CLTIPTRA] == '3' // Transporte Fluvial
				cNat := cNatFlu //-- Natureza Transporte Fluvial
			EndIf

			If lGeraDT6
				cTipTra  := aFatCli[nCntFor][CLTIPTRA]
				aVFContr := TMSA491VlrC( aFatCli[nCntFor, CLCOD], aFatCli[nCntFor, CLLOJA], aFatCli[nCntFor, CLTIPFRE] , aFatCli[nCntFor, CLSERVIC], aFatCli[nCntFor, CLDTATE],,aFatCli[nCntFor][CLTPFRDV])
				cNumNFs  := TMSGeraSD2( aDoctos, cCli, _cLoja, cPrefDT6, cTipTra, aVFContr, @nRecDT6, @nValFat )
				nValor := nValFat
				nValFat:= 0
			EndIf
			
			If lMV_TMSNFAT .AND. lGeraDT6   //verifica se numeração deve olhar o MV_NUMFAT e documento diferente do tipo "normal" 
				cNumNFs := ""		//o número da fatura corresponderá ao conteúdo do parametro MV_NUMFAT
			EndIf
			
			If cTmsERP == '0' //-- ERP Protheus
				//--Realiza a gravacao da Fatura (SE1)
				aFtGeradas := TMSA850Grv(lMostraGet, cCondicao, nMoedFat, aDoctos, dDtaEmissao,    , cNumNFS,;
				                         cAliasTRB , cPrefDT6 , nValor  , cNat   , @nRecDT6   , .F., ExecSchedule())
			EndIf

			If Len( aFtGeradas ) > 0
				AaddMsgErr( aFtGeradas, @aMsgFat )
			EndIf
		EndIf
	End Transaction

	If cTmsERP == '1' //-- ERP Datasul
		If aFatCli[nCntFor][1] .And. aFatCli[nCntFor][CLVLFAT] > 0  //-- Se a Fatura estiver Marcada e tiver documentos marcados
			aFtGeradas := Tmsa851Grv(lMostraGet, nMoedFat , aDoctos, dDtaEmissao, , nValor, cAliasTRB, cPrefDT6, @nRecDT6, .F., ExecSchedule(), @aErrosInt)
			If ! Empty(aErrosInt) 
				If ExecSchedule() .Or. lThread
					For nContErro := 1 To Len(aErrosInt)
						AdicionaMsg(aErrosInt[nContErro])
					Next
				EndIf
				Return( .F. )
			EndIf

			If Len( aFtGeradas ) > 0
				AaddMsgErr( aFtGeradas, @aMsgFat )
			EndIf
		EndIf
	EndIf
Next

If lMV_TMSFMSG .And. Len(aMsgFat) > 0
	// se foi chamado pelo schedule, adiciona os dados de faturas geradas no vetor
	// para envio por email de acordo com o parametro
	If ExecSchedule() .Or. lThread
		For nCntFor := 1 to Len(aMsgFat)
			AdicionaMsg( aMsgFat[nCntFor,1] ) //-- 'Fatura Gerada:'
		Next
	Else
		TmsMsgErr( aMsgFat, STR0001 ) //"Faturas a Receber por Documentos de Transporte"
	EndIf
EndIf

//--Restaura as Perguntas do programa
Pergunte(cTMA490, .F.)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA491DtEm³ Autor ³Patricia A. Salomao ³ Data ³ 19.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Baseado no tipo de Faturamento do cliente, monta as datas   ³±±
±±³          ³para filtrar a emissao do titulo ou a entrega do documento. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA491DtEmi()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 - Data de Emissao a ser considerada (De)              ³±±
±±³          ³ExpD2 - Data de Emissao a ser considerada (Ate)             ³±±
±±³          ³ExpC1 - Tipo de Faturamento do Cliente                      ³±±
±±³          ³ExpL1 - Considera Titulos Anteriores                        ³±±
±±³          ³ExpD3 - Data de Emissao da Fatura                           ³±±
±±³          ³ExpD4 - Data de Referencia para substituir dDataBase        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA491                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA491DtEmi(dDtaFilDe, dDtaFilAte, cTipFat, lConsTitAnt, dDtaEmissao, dDataRef,cAliasDT6 )

Local nDiaBase  := 0
Local nMesBase  := 0
Local nAnoBase  := 0

Local nDiaDe    := 0
Local nDiaAte   := 0
Local nDiaEmis  := 0
Local nDif      := 0
Local aFaixas   := {}
Local aArea     := GetArea()
Local lTM491EMI := ExistBlock('TM491EMI')
Local aDatas    := {}
Local lPonto    := .F.
Local nCount    := 0
Local cQuery	:= ""
Local cAliasQry	:= ""
Local aAreaDV0	:= DV0->(GetArea())

Default cTipFat := ''
Default dDataRef:= dDataBase

nDiaBase  := Day(dDataRef)
nMesBase  := Month(dDataRef)
nAnoBase  := Year(dDataRef)

/* Posiciona o header dos Tipos de Faturamento. */
DUZ->(dbSetOrder(1))
DUZ->(MsSeek(xFilial("DUZ") + cTipFat))

/* Posiciona os itens dos Tipos de Faturamento. */
DV0->(dbSetOrder(1))

cAliasQry := GetNextAlias()
cQuery := "   SELECT DV0_VALDE, DV0_VALATE, DV0_DIAFAT "
cQuery += "     FROM " + RetSqlName("DV0") 
cQuery += "    WHERE DV0_FILIAL = '" + xFilial('DV0') + "' "
cQuery += "      AND DV0_TIPFAT = '" + DUZ->DUZ_TIPFAT + "' "
cQuery += "      AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY " + SqlOrder(DV0->(IndexKey()))
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

If DUZ->DUZ_TIPDIA == StrZero(1, Len(DUZ->DUZ_TIPDIA)) // Tipo de Faturamento mensal.
	/* Obtem as faixas do tipode faturamento. */
	While (cAliasQry)->(!Eof())
		Aadd(aFaixas, {(cAliasQry)->DV0_VALDE, (cAliasQry)->DV0_VALATE, (cAliasQry)->DV0_DIAFAT})
		(cAliasQry)->(DbSkip())
	EndDo
	/* Verifica que faixa o dia(nDiaBase) pertence. */
	nPosFaixa := Ascan(aFaixas, {|x| x[2] >= nDiaBase})

	If nPosFaixa == 1
		nPosFaixa := Len(aFaixas)
		/* Caso a faixa seja a primeira obtem as datas De/Ate com base no mes anterior. */
		nMesBase := Iif(nMesBase ==  1, 12, (nMesBase - 1))       // Obtem o mes anterior.
		nAnoBase := Iif(nMesBase == 12, (nAnoBase - 1), nAnoBase) // Se o mes for dezembro tira um do ano.
		nDiaDe   := aFaixas[nPosFaixa,1]
		/* Obtem o ultimo dia do mesm base. */
		nDiaAte  := Day(LastDay(Ctod("01" + "/" + StrZero(nMesBase, 2) + "/" + StrZero(nAnoBase, 4))))
	Else
		/* Obtem as datas com base na faixa anterior. */
		nPosFaixa := (nPosFaixa - 1)
		nDiaDe    := aFaixas[nPosFaixa, 1]
		nDiaAte   := aFaixas[nPosFaixa, 2]
	EndIf
	dDtaFilDe  := Ctod(StrZero(nDiaDe, 2)  + "/" + StrZero(nMesBase, 2) + "/" + StrZero(nAnoBase, 4)) // Data de.
	dDtaFilAte := Ctod(StrZero(nDiaAte, 2) + "/" + StrZero(nMesBase, 2) + "/" + StrZero(nAnoBase, 4)) // Data Ate.
	nDiaEmis   := aFaixas[nPosFaixa, 3] // Dia da emissao da fatura.

	//-- Obtem a data de emissao da fatura
	dDtaEmissao := dDataRef
	
Else // Tipo de Faturamento semanal.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Com base nos dias informados nos campos DV0_VALDE/DV0_VALATE obtem o      ³
	//³intervalo de uma semana anterior a semana corrente.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDif := Abs((cAliasQry)->DV0_VALDE - Dow(dDataRef))

	If (cAliasQry)->DV0_VALDE < Dow(dDataRef)
		nDif := (7-nDif)
	EndIf

	dDtaFilDe := (dDataRef - 7) + nDif
	nDif      := Abs((cAliasQry)->DV0_VALDE - (cAliasQry)->DV0_VALATE)

	If (cAliasQry)->DV0_VALDE >= (cAliasQry)->DV0_VALATE
		nDif := (7-nDif)
	EndIf

	dDtaFilAte := dDtaFilDe + nDif 

	//-- Se o periodo ultrapassar a database, considera a semana anterior
	If dDtaFilAte > dDataRef
		dDtaFilDe  -= 7
		dDtaFilAte -= 7
	EndIf

	//-- Obtem a data de emissao da fatura
	dDtaEmissao := dDataRef

EndIf

If lConsTitAnt
	dDtaFilDe := CtoD("01/01/" + Str(Set(5), 4))
EndIf

If lTM491EMI	
	aDatas := ExecBlock('TM491EMI',.F.,.F., {dDtaFilDe,dDtaFilAte,dDtaEmissao,cTipFat,lConsTitAnt,cAliasDT6} )
	If ValType(aDatas) == 'A' .And. Len(aDatas) > 0
		lPonto := .T.
	EndIf
	For nCount := 1 To Len(aDatas)
		If ValType(aDatas[nCount]) == 'D' .And. lPonto
			lPonto := .T.
		Else
			lPonto := .F.
			Exit
		EndIf
	Next nCount
	If lPonto
		dDtaFilDe  := aDatas[1]
		dDtaFilAte := aDatas[2]
		dDtaEmissao:= aDatas[3]
	EndIf
EndIf

(cAliasQry)->(DbCloseArea())
RestArea(aAreaDV0)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSGeraSD2
Tratamento para geração do documento de frete quando o faturamento é relacionado a documentos
de apoio. Gera nota fiscal de saída e informações da DT6 e DT8.
@type function
@author Eduardo de Souza
@version 12
@since 12/08/2004
@param [aDoctos], Array, Array contendo os documentos
@param [cCliente], Caracter, Código do Cliente
@param [cLoja], Caracter, Loja do Cliente
@param [cSerNf], Caracter, Série da Nota Fiscal
@param [cTipTra], Caracter, Tipo Transporte
@param [aVFContr], Array, Valor da Fatura (Veículo Dedicado)
@param [nRecDT6], Numérico, RecNo do DT6
@param [nValFat], Numérico, Cobra somente valor fixo do contrato (.T./.F.)
@return cNumNFS Retorna o número da NFS gerada
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSGeraSD2(aDocFAT, cCliente, cLoja, cSerNf, cTipTra, aVFContr, nRecDT6, nValFat)

	Local nCountA    := 0
	Local nCount     := 0
	Local lConsig    := .F.
	Local nQtdVol    := 0	//--Volumes
	Local nValMerc   := 0	//--Val. das Mercadorias
	Local nPesoM3    := 0	//--Peso Cubado
	Local nPesoCobr  := 0	//--Peso Cobrado
	Local nPeso      := 0	//--Peso
	Local nQtdUnit   := 0	//--Unitizadores
	Local cDocTMS    := ''
	Local cTES       := ''
	Local cTipoNF    := ''
	Local cSeqInscr  := ''
	Local aRegra     := {}
	Local aCmpFrt    := {}
	Local nPos       := 0
	Local cDesComp   := ''
	Local nPosComp   := 0
	Local cProGen    := PadR( GetMV("MV_PROGEN",,""), Len(SB1->B1_COD) )
	Local cDocApoio  := ''
	Local cF4_ISS    := ''
	Local cSrv       := ''
	Local aStruSF2   := SF2->( DbStruct() )
	Local aDadosSF2  := {}
	Local bFatSE1    := {|| .F. }
	Local cNumNFS    := ''
	Local cEstOriTrb := ""

	Local cEspecie 	:= A460Especie(cSerNF)

	Local aArea      := GetArea()
	Local aAreaDUI   := DUI->( GetArea() )
	Local aAreaDTC   := DTC->( GetArea() )
	Local aAreaDT3   := DT3->( GetArea() )
	Local aAreaSA1   := SA1->( GetArea() )
	Local aAreaDUY   := DUY->( GetArea() )
	Local aAreaSB1   := SB1->( GetArea() )
	Local aAreaSF4   := SF4->( GetArea() )
	Local cQuery     := ""
	Local cAliasQry  := ""
	Local cCliGen    := Left(GetMv("MV_CLIGEN"),Len(SA1->A1_COD))
	Local cLojGen    := Right(GetMv("MV_CLIGEN"),Len(SA1->A1_LOJA))
	Local lQuebraDT6 := .F.
	Local cDocKeyAtu := ""
	Local cDocKeyOld := ""
	Local lTMSCTe    := SuperGetMv("MV_TMSCTE",.F.,.T.)
	Local aDoctos    := {}
	Local cCodMsg    := ""
	Local cCodProNf  := ''
	Default aVFContr := {}

	//--Campos que serao aglutinados
	//--para geracao do novo documento
	cCposSF2 := 'F2_FRETE|F2_SEGURO|F2_ICMFRET|F2_VALBRUT|F2_VALICM|F2_BASEICM|F2_VALIPI|F2_BASEIPI|F2_VALMERC|'
	cCposSF2 += 'F2_DESCONT|F2_VOLUME1|F2_VOLUME2|F2_VOLUME3|F2_VOLUME4|F2_ICMSRET|F2_PLIQUI|F2_PBRUTO|F2_FATORB0|'
	cCposSF2 += 'F2_FATORB1|F2_VARIAC|F2_BASEISS|F2_VALISS|F2_VALFAT|F2_CONTSOC|F2_BRICMS|F2_FRETAUT|F2_ICMAUTO|'
	cCposSF2 += 'F2_DESPESA|F2_BASIMP1|F2_BASIMP2|F2_BASIMP3|F2_BASIMP4|F2_BASIMP5|F2_BASIMP6|F2_VALIMP1|F2_VALIMP2|'
	cCposSF2 += 'F2_VALIMP3|F2_VALIMP4|F2_VALIMP5|F2_VALIMP6|F2_VALINS|F2_VALCOFI|F2_VALPIS|F2_TXMOEDA|F2_VALIRRF|'
	cCposSF2 += 'F2_BASEINS|F2_DESCCAB|'

	//-- Ordena aDoctos considerando a seguinte sequência.
	//	 1.[28] Cod.Expedidor
	//	 2.[29] Loj.Expedidor
	//	 3.[30] Cod.Recebedor
	//	 4.[31] Loj.Recebedor
	//	 5.[14] Cod.Remetente
	//	 6.[15] Loj.Remetente
	//	 7.[12] Cod.Destinatario
	//	 8.[13] Loj.Destinatario
	//	 9.[24] Cod.Consignatario
	//	10.[25] Loj.Consignatario
	//	11.[18] Cod.Devedor
	//	12.[19] Loj.Devedor
	//	13.[21] Reg.Origem
	//	14.[22] Reg.Destino
	//	15.[23] Reg.Calculo
	If lTMSCTe .And. !Empty(cDocFat)  .And. cDocFat != "5"
		aSort(aDocFAT,,,{|x,y| x[28]+x[29]+x[30]+x[31]+x[14]+x[15]+x[12]+x[13]+x[24]+x[25]+x[18]+x[19]+x[21]+x[22]+x[23] <;
							   y[28]+y[29]+y[30]+y[31]+y[14]+y[15]+y[12]+y[13]+y[24]+y[25]+y[18]+y[19]+y[21]+y[22]+y[23] })
	
	//-- Se gerar NF, considerar a chave apenas com devedor+origem+destino+calculo 
	ElseIf lTMSCTe .And. cDocFat == "5"
		aSort(aDocFAT,,,{|x,y| x[18]+x[19]+x[21]+x[22]+x[23] <;
							   y[18]+y[19]+y[21]+y[22]+y[23] })

	//-- mantem o comportamento legado 1 documento de transporte para 'n' documento de apoio de mesmo devedor.
	Else
		aDoctos := aDocFAT
	EndIf

	//--PROCESSA OS DOCUMENTOS SELECIONADOS:
	For nCountA := 1 To Len(aDocFAT)
		If aDocFAT[nCountA,1]
			DT6->( DbSetOrder(1) ) //--DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			If DT6->( DbSeek(xFilial('DT6')+xFilial('SF2')+aDocFAT[nCountA,3]+aDocFAT[nCountA,4]) )

				//+----------------------------------------------------------------------
				//| Valida o momento que será fechado o agrupamento de documentos
				//| ordem dos campos agrupados para compor a chave de quebra.
				//+----------------------------------------------------------------------
				//| 1.Cliente expedidor
				//| 2.Loja expedidor
				//| 3.Cliente recebedor
				//| 4.Loja recebedor
				//| 5.Cliente agrupador (definido a partir do perfil do remetente)
				//| 6.Loja agrupador
				//| 7.Cliente destinatário
				//| 8.Loja destinatário
				//| 9.Cliente consignatário
				//| 10.Loja consignatário
				//| 11.Cliente despachante
				//| 12.Loja despachante
				//| 13.Código do devedor
				//| 14.Loja do devedor
				//| 15.Região de origem
				//| 16.Região de cálculo
				//+----------------------------------------------------------------------
				If lTMSCTe
					cDocKeyAtu :=   Iif(cDocFat == "5", "", aDocFAT[nCountA,28])+; //.Cod.Expedidor
									Iif(cDocFat == "5", "", aDocFAT[nCountA,29])+; //.Loj.Expedidor
									Iif(cDocFat == "5", "", aDocFAT[nCountA,30])+; //.Cod.Recebedor
									Iif(cDocFat == "5", "", aDocFAT[nCountA,31])+; //.Loj.Recebedor
									Iif(cDocFat == "5", "", aDocFAT[nCountA,14])+; //.Cod.Remetente
									Iif(cDocFat == "5", "", aDocFAT[nCountA,15])+; //.Loj.Remetente
									Iif(cDocFat == "5", "", aDocFAT[nCountA,12])+; //.Cod.Destinatario
									Iif(cDocFat == "5", "", aDocFAT[nCountA,13])+; //.Loj.Destinatario
									Iif(cDocFat == "5", "", aDocFAT[nCountA,24])+; //.Cod.Consignatario
									Iif(cDocFat == "5", "", aDocFAT[nCountA,25])+; //.Loj.Consignatario
									aDocFAT[nCountA,18]+; //.Cod.Devedor
									aDocFAT[nCountA,19]+; //.Loj.Devedor
									aDocFAT[nCountA,21]+; //.Reg.Origem
									aDocFAT[nCountA,22]+; //.Reg.Destino
									aDocFAT[nCountA,23]   //.Reg.Calculo


					lQuebraDT6 := (cDocKeyAtu <> cDocKeyOld) .And. (nCountA > 1) //| Nao considera a primeira iteracao, se existir apenas 1 docto na matriz será gerado após esse iteração.

					//| Atualizo a variavel cDocKeyOld com a mesma chave contida na variável cDocKeyAtu para comparação na próxima iteração do looping
					cDocKeyOld = cDocKeyAtu
					//| Gera ou Acumula os valores e quantidades do Documento
					If lQuebraDT6

						cNumNFS := TmsA491DT6(aVFContr,aCmpFrt,aStruSF2,aDadosSF2,cProGen,cDocApoio,cTipTra,cCliente,cLoja,cDocTMS,nQtdVol,nPeso,aDadosSF2,cCposSF2,aCmpFrt,;
								cF4_ISS,cTES,bFatSE1,cSerNF,aVFContr,cEspecie,nValMerc,nPesoM3,nPeso,nPesoCobr,nQtdUnit,cSrv,@nRecDT6,@nValFat,aDoctos)

						//| adiciona os documentos gerados com base em documentos de apoio ao vetor aDoctos para entrar na fatura, esses documentos não acrescentam valores a fatura.
						If nRecDT6 > 0
							TMSA491AAdd(0,{},nRecDT6,@aDocFAT)
						EndIf

						//| zerar acumuladores
						nQtdVol   := 0
						nValMerc  := 0
						nPesoM3   := 0
						nPesoCobr := 0
						nPeso     := 0
						nQtdUnit  := 0
						lQuebraDT6:= .F.
						cTES      := ""
						aDadosSF2 := {}
						aDoctos   := {}
						aCmpFrt   := {}
						//| deve ser zerado para não gravar o numero do ultimo ct-e no E1_NUMNOTA já que existe quebra além do campo do devedor gerando mais 
						//| de 1 documento por documento de apoio agrupado. Também é necessário para que a exclusão do documento informado no campo E1_NUMNOT
						//| seja efetiva.
						nRecDT6   := 0 
					EndIf

					//-- Adiciona documentos de apoio ao array agrupando para gerar uma NFE ou CTE
					AADD(aDoctos,aClone(aDocFAT[nCountA]))
				EndIf

				//| Acumulador das quantidades para gerar o Documento.
				nQtdVol   += DT6->DT6_QTDVOL
				nValMerc  += DT6->DT6_VALMER
				nPesoM3   += DT6->DT6_PESOM3
				nPesoCobr += DT6->DT6_PESCOB
				nPeso     += DT6->DT6_PESO
				nQtdUnit  += DT6->DT6_QTDUNI

				//--Regra de Tributacao (TES):
				If Empty( cTES )
					//--Verifica se o devedor do frete
					//--eh o consignatario (Para tratamento
					//--em relacao a regra de tributacao):
					lConsig   := DT6->DT6_DEVFRE == StrZero( 3, Len(DT6->DT6_DEVFRE) )
					cEstOriTrb := Posicione("DUY",1,xFilial("DUY")+DT6->DT6_CDRORI,"DUY_EST")

					cDocTMS   := Posicione( "DUI", 1, xFilial("DUI")+DT6->DT6_DOCTMS, "DUI_DOCFAT" )
					cDocApoio := DT6->DT6_DOCTMS
					cTES      := ""
					cTipoNF   := ""

					If !Empty(cDocTMS)
						cTipoNF   := Posicione( "DTC", 3, xFilial("DTC")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE), "DTC_TIPNFC" )
						cCodProNf := Posicione( "DTC", 3, xFilial("DTC")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE), "DTC_CODPRO" )
						cSeqInscr := TMSSeqIns( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE )
						aRegra    := TmsRegTrib( cDocTMS, DT6->DT6_TIPFRE,,DT6->DT6_CLIDEV, DT6->DT6_LOJDEV, DT6->DT6_CDRDES,,cCodProNf,,cEstOriTrb, lConsig, cTipoNF, cSeqInscr )
						If !Empty(aRegra)
							cTES    := aRegra[ 1 ]
							cCodMsg	:= aRegra[ 2 ]
							cF4_ISS := aRegra[ 3 ]
						EndIf
					EndIf
				EndIf

				If (DT6->DT6_DOCTMS $ "|B|C|H|I|N|O|") .And. Empty( cTES ) //-- Quando for fatura de documento de apoio, o doc gerado sera tipo CTRC
					DV1->(DbSetOrder(1))
					If DV1->(DbSeek(xFilial("DV1")+cCliGen+cLojGen+DT6->DT6_DOCTMS))
						DUF->(DbSetOrder(1))
						If DT6->DT6_TIPFRE == "1" .Or. DT6->DT6_TIPFRE == "2"
							If	DUF->(!MsSeek(xFilial("DUF")+DV1->DV1_REGTRI+DT6->DT6_TIPFRE))
								DUF->( MsSeek(xFilial("DUF")+DV1->DV1_REGTRI+"3"))
							EndIf
						ElseIf Empty(DT6->DT6_TIPFRE) .Or. DT6->DT6_TIPFRE == "3"
							DUF->(MsSeek(xFilial("DUF")+DV1->DV1_REGTRI+StrZero(3,Len(DUF->DUF_TIPFRE)) ))
						EndIf

						DUG->(DbSetOrder(1))
						If (DUG->(MsSeek(xFilial('DUG')+DUF->DUF_REGTRI+DUF->DUF_TIPFRE)))
							cTes := DUG->DUG_TES
						EndIf
					EndIf
				EndIf

				//--Aglutina os dados do cabecalho
				//--das notas fiscais dos Doctos. de Apoio
				//--*Somente aglutina os valores se o contrato
				//--nao estiver configurado c/ valor fixo ou
				//--se o contrato estiver configurado com valor
				//--fixo (variavel)
				If Len( aVFContr ) == 0 .Or. (Len(aVFContr) > 0 .And. (aVFContr[1] == 0 .Or. !aVFContr[2]))
					SF2->( DbSetOrder(1) ) //--F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
					If SF2->( DbSeek( xFilial('SF2')+DT6->(DT6_DOC+DT6_SERIE+DT6_CLIDEV+DT6_LOJDEV) ) )
						If Len(aDadosSF2) == 0
							For nCount := 1 To Len(aStruSF2)
								If AllTrim(aStruSF2[nCount,1]) $ cCposSF2
									AAdd( aDadosSF2, { aStruSF2[nCount,1],  SF2->(FieldGet(FieldPos(aStruSF2[nCount,1]))) } )
								EndIf
							Next
						Else
							For nCount := 1 To Len(aStruSF2)
								If AllTrim(aStruSF2[nCount,1]) $ cCposSF2
									nPos := AScan(aDadosSF2, {|x| AllTrim(x[1]) == AllTrim(aStruSF2[nCount,1])} )
									If nPos > 0
										aDadosSF2[nPos,2] += SF2->(FieldGet(FieldPos(aStruSF2[nCount,1])))
									EndIf
								EndIf
							Next
						EndIf
					EndIf
				EndIf

				//--Verifica a composicao do frete
				//--dos documentos selecionados para
				//--fatura e acumula os dados referente aos
				//--documentos
				If Len( aVFContr ) == 0 .Or. (Len(aVFContr) > 0 .And. (aVFContr[1] == 0 .Or. !aVFContr[2]))
					DT8->(DbSetOrder(2)) //--DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS

					cAliasQry := GetNextAlias()
					cQuery := "   SELECT DT8_FILIAL, DT8_FILDOC, DT8_DOC, DT8_SERIE, DT8_CODPAS, DT8_VALPAS, DT8_VALIMP, DT8_VALTOT, DT8_CDRORI, DT8_CDRDES, "
					cQuery += "          DT8_DESC, DT8_ACRESC, DT8_CALMIN "
					cQuery += "     FROM " + RetSqlName("DT8") 
					cQuery += "    WHERE DT8_FILIAL = '" + xFilial('DT8') + "' "
					cQuery += "      AND DT8_FILDOC = '" + DT6->DT6_FILDOC + "' "
					cQuery += "      AND DT8_DOC = '" + DT6->DT6_DOC + "' "
					cQuery += "      AND DT8_SERIE = '" + DT6->DT6_SERIE + "' "
					cQuery += "      AND D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY " + SqlOrder(DT8->(IndexKey()))
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

					While (cAliasQry)->(!Eof())
						//--Inicializa o vetor
						//--com a composicao do frete:
						If Empty(aCmpFrt)
							AAdd( aCmpFrt, { cProGen, {} } )
						EndIf
						
						nPos     := Len( aCmpFrt )
						nPosComp := AScan( aCmpFrt[nPos,2], {|x| x[3] == (cAliasQry)->DT8_CODPAS} )
						If	nPosComp == 0
							cDesComp := Posicione('DT3', 1, xFilial('DT3') + (cAliasQry)->DT8_CODPAS, 'DT3_DESCRI')
							AAdd( aCmpFrt[nPos][2], {	cDesComp,;					//--[01]DESCRICAO DO COMPONENTE
														(cAliasQry)->DT8_VALPAS,;	//--[02]VALOR DO COMPONENTE (LIQUIDO)
														(cAliasQry)->DT8_CODPAS,;	//--[03]CODIGO DO COMPONENTE
														'',;						//--[04]ITEM x SD2
														(cAliasQry)->DT8_VALIMP,;	//--[05]VALOR DOS IMPOSTOS
														(cAliasQry)->DT8_VALTOT,;	//--[06]VALOR DO COMPONENTE (BRUTO)
														(cAliasQry)->DT8_CDRORI,;	//--[07]REGIAO DE ORIGEM
														(cAliasQry)->DT8_CDRDES,;	//--[08]REGIAO DESTINO
														'',;						//--[09]TABELA DE FRETE
														'',;						//--[10]TIPO DA TABELA DE FRETE
														'',;						//--[11]SEQUENC. DA TABELA DE FRETE
														'',;						//--[12]**NAO USADO**
														(cAliasQry)->DT8_DESC,;		//--[13]VALOR DE DESCONTO
														(cAliasQry)->DT8_ACRESC,;	//--[14]VALOR DE ACRESCIMO
														(cAliasQry)->DT8_CALMIN} )	//--[15]CALCULADO PELO MINIMO (1=SIM/2=NAO)

						Else
							aCmpFrt[nPos][2][nPosComp][02] += (cAliasQry)->DT8_VALPAS	//--[02]VALOR DO COMPONENTE (LIQUIDO)
							aCmpFrt[nPos][2][nPosComp][05] += (cAliasQry)->DT8_VALIMP	//--[05]VALOR DOS IMPOSTOS
							aCmpFrt[nPos][2][nPosComp][06] += (cAliasQry)->DT8_VALTOT	//--[06]VALOR DO COMPONENTE (BRUTO)
							aCmpFrt[nPos][2][nPosComp][13] += (cAliasQry)->DT8_DESC	//--[13]VALOR DE DESCONTO
							aCmpFrt[nPos][2][nPosComp][14] += (cAliasQry)->DT8_ACRESC	//--[14]VALOR DE ACRESCIMO
						EndIf
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(DbCloseArea())
				EndIf

			EndIf
		EndIf
	Next

	cNumNFS := TmsA491DT6(aVFContr,aCmpFrt,aStruSF2,aDadosSF2,cProGen,cDocApoio,cTipTra,cCliente,cLoja,cDocTMS,nQtdVol,nPeso,aDadosSF2,cCposSF2,aCmpFrt,;
			   				cF4_ISS,cTES,bFatSE1,cSerNF,aVFContr,cEspecie,nValMerc,nPesoM3,nPeso,nPesoCobr,nQtdUnit,cSrv,@nRecDT6,@nValFat,aDoctos,cCodMsg)

	//-- Adiciona CT-e/NFe gerada com base em documento de apoio ao vetor aDocFat equivalente ao aDoctos passado por parametro.
	If lTMSCTE
		TMSA491AAdd(0,{},nRecDT6,@aDocFAT)
		nRecDT6 := 0
	EndIf

	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aAreaDUY)
	RestArea(aAreaSA1)
	RestArea(aAreaDT3)
	RestArea(aAreaDTC)
	RestArea(aAreaDUI)
	RestArea(aArea)

Return cNumNFS

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA491Doc
Geração do documento de Transporte (DTP/DT6/DT8) 
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 19/08/2004
@param [cNumNFS], Caracter, Numero da Nota fiscal
@param [cCliente], Caracter, Cliente pagador
@param [cLoja], Caracter, Loja do cliente pagador
@param [cDocTMS], Caracter, Documento de Transporte
@param [aCmpFrt], Array, Vetor com a Composicao do Frete (DT8)
@param [nValMerc], Numérico, Valor da mercadoria
@param [nPesoM3], Numérico, Peso Cubado Total
@param [nPeso], Numérico, Peso
@param [nPesoCobr], Numérico, Peso Cobrado Total
@param [nQtdUnit], Numérico, Qtde. Total de Unitizadores
@param [nQtdVol], Numérico, Qtde. Total Volumes
@param [cTipTra], Caracter, Tipo de transporte
@param [cSrv], Caracter, Serviço de negociação
@param [nRecDT6], Numérico, Recno do DT6 gerado para referencia
@param [nValFat], Numérico, Valor Fixo do Contrato
@param [aDoctos], Array, Documentos
@return Nil Não há retorno
@example TmsA491Doc(cNumNFS, cCliente, cLoja, cDocTMS, aCmpFrt, nValMerc, nPesoM3, nPeso, nPesoCobr, nQtdUnit, nQtdVol, cTipTra, cSrv, nRecDT6, nValFat, aDoctos)
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSA491Doc(cNumNFS , cCliente, cLoja, cDocTMS  , aCmpFrt ,; 
						   nValMerc, nPesoM3 , nPeso, nPesoCobr, nQtdUnit,;
						   nQtdVol , cTipTra , cSrv , nRecDT6  , nValFat ,;
						   aDoctos,cCodMsg)

Local aArea      := GetArea()
Local aAreaDUY   := DUY->(GetArea())
Local aParGrvDT6 := {}
Local aRetVerImp := {}
Local aPontEntr  := {}
Local aRetDT6    := {}
Local cChave     := ""
Local cCodPro    := ""
Local cTipFre    := ""
Local cDevFre    := ""
Local cCliRem    := ""
Local cLojRem    := ""
Local cCliDes    := ""
Local cLojDes    := ""
Local cCliDev    := ""
Local cLojDev    := ""
Local cCliCon    := ""
Local cLojCon    := ""
Local cCliDpc    := ""
Local cLojDpc    := ""
Local cCdrOri    := ""
Local cCdrDes    := ""
Local cCdrCal    := ""
Local cFilDeb    := ""
Local cSerNF     := ""
Local cLotNfc    := ""
Local nIni       := 0
Local nPosSel    := 0
Local nAcresc    := 0
Local nDecresc   := 0
Local nValFre    := 0
Local nValImp    := 0
Local nValTot    := 0
Local aAreaDTC   := {}
Local aAreaDT6   := {}
Local cFilDes    := ""
Local nVrlFatF2	 := 0
Local aAreaSF2   := {}
Local cA1RecISS  := ''
Local lTPABISS   := IIf(GetNewPar("MV_TPABISS", "1") == "1",.T.,.F.)
Local lDescIss   := IIf(GetNewPar("MV_DESCISS", .T.) == .T.,.T.,.F.)  
Local cFilDco    := ''
Local cDocDco    := ''
Local cSerDco    := ''

Default cNumNFS   := ""
Default cCliente  := ""
Default cLoja     := ""
Default cDocTMS   := ""
Default aCmpFrt   := {}
Default nValMerc  := 0
Default nPesoM3   := 0 
Default nPeso     := 0
Default nPesoCobr := 0
Default nQtdUnit  := 0
Default nQtdVol   := 0
Default cTipTra   := ""
Default cSrv      := ""
Default nRecDT6   := 0
Default nValFat   := 0
Default aDoctos   := {}
Default cCodMsg   := ""

//-- Verificacao dos documentos, se estes sao iguais ou nao
nIni	:= ASCAN(aDoctos, {|e| e[CLDMARCA] == .T.})
cChave	:= aDoctos[nIni][LACLIREM] + aDoctos[nIni][LALOJREM] + ;
			aDoctos[nIni][LACLIDES] + aDoctos[nIni][LALOJDES] + ;
			aDoctos[nIni][LACLIDEV] + aDoctos[nIni][LALOJDEV] + ;
			aDoctos[nIni][LACLICON] + aDoctos[nIni][LALOJCON] + ;
			aDoctos[nIni][LACLIDPC] + aDoctos[nIni][LALOJDPC]
nPosSel	:= aScanX(aDoctos, {|e,i| (cChave <> e[LACLIREM] + e[LALOJREM] + e[LACLIDES] + e[LALOJDES] + e[LACLIDEV] + e[LALOJDEV] + e[LACLICON] + e[LALOJCON] + e[LACLIDPC] + e[LALOJDPC])})

//-- Verifica os valores de impostos calculados a partir da geracao nota fiscal de saida, 
//-- atualiza a composição de frete e retorna os valores totais
aRetVerImp := TmsVerImpC(cNumNFS, cCliente, cLoja, cDocTMS, /* cCodPro */, aCmpFrt)
cSerNF     := aRetVerImp[1]
aCmpFrt    := aClone(aRetVerImp[2])
nValFre    := aRetVerImp[3]
nValImp    := aRetVerImp[4]
nValTot    := aRetVerImp[5]
cCodPro    := aRetVerImp[6]

//-- Informacoes com base no aDoctos
aAreaDTC := DTC->(GetArea())
DTC->(DbSetOrder(3))
DTC->(DbSeek(xFilial("DTC") + aDoctos[nIni,LAFILDOC] + aDoctos[nIni,LADOC] + aDoctos[nIni,LASERIE]))	
cTipFre := DTC->DTC_TIPFRE
cDevFre := DTC->DTC_DEVFRE
RestArea(aAreaDTC)

aAreaDT6 := DT6->(GetArea())
DT6->(DbSetOrder(1))
DT6->(DbSeek(xFilial("DT6") + aDoctos[nIni,LAFILDOC] + aDoctos[nIni,LADOC] + aDoctos[nIni,LASERIE]))
cFilDes := DT6->DT6_FILDES
cFilDco := DT6->DT6_FILDOC
cDocDco := DT6->DT6_DOC
cSerDco := DT6->DT6_SERIE
RestArea(aAreaDT6)	

aAreaSF2 := SF2->(GetArea())
SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If SF2->(DbSeek(xFilial("SF2") + cNumNFS + cSerNF + cCliente + cLoja ))
	nVrlFatF2 := SF2->F2_VALFAT
EndIf
RestArea(aAreaSF2)

If nPosSel >= 1
	// Não apagar até entender o motivo de ter sido feito dessa forma
	// cCliRem := Iif(lCliQbr .And. cTipFre == "2", cCliQbr, cCliente)
	// cLojRem := Iif(lCliQbr .And. cTipFre == "2", cLojQbr, cLoja)
	// cCliDes := cCliente
	// cLojDes := cLoja
	cCliRem := aDoctos[nIni][LACLIREM]
	cLojRem := aDoctos[nIni][LALOJREM]
	cCliDes := aDoctos[nIni][LACLIDES]
	cLojDes := aDoctos[nIni][LALOJDES]
	cCliDev := cCliente
	cLojDev := cLoja

	cCliCon := cCliente
	cLojCon := cLoja

	//-- Regiao Origem / Regiao Destino / Filial de Debito
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja))
		cCdrOri := aDoctos[nIni][LACDRORI] //-- Regiao origem
		cCdrDes := aDoctos[nIni][LACDRDES] //-- Regiao destino
		cCdrCal := aDoctos[nIni][LACDRCAL] //-- Regiao calculo
		cFilDeb := If(Empty(SA1->A1_FILDEB), Iif(cTipFre == '1', cFilAnt, cFilDes), SA1->A1_FILDEB) //-- Filial Debito
	EndIf
Else
	cCliRem := aDoctos[nIni][LACLIREM]
	cLojRem := aDoctos[nIni][LALOJREM]
	cCliDes := aDoctos[nIni][LACLIDES]
	cLojDes := aDoctos[nIni][LALOJDES]
	cCliDev := aDoctos[nIni][LACLIDEV]
	cLojDev := aDoctos[nIni][LALOJDEV]
	cCdrOri := aDoctos[nIni][LACDRORI]
	cCdrDes := aDoctos[nIni][LACDRDES]
	cCdrCal := aDoctos[nIni][LACDRCAL]
	cCliCon := aDoctos[nIni][LACLICON]
	cLojCon := aDoctos[nIni][LALOJCON]
	cCliDpc := aDoctos[nIni][LACLIDPC]
	cLojDpc := aDoctos[nIni][LALOJDPC]
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja))
		cFilDeb := If(Empty(SA1->A1_FILDEB), Iif(cTipFre == '1', cFilAnt, cFilDes), SA1->A1_FILDEB) //-- Filial Debito
	EndIf
EndIf

//-- Valores acrescimo e decrescimo:
aEval(aDoctos, {|x| nAcresc  += x[LAACRESC]})
aEval(aDoctos, {|x| nDecresc += x[LADECRES]})

//-- Gravacao de um lote (DTP) de notas fiscais
cLotNfc := TmsGrvLot()

//-- Gravacao do documento de transporte (DT6)
aParGrvDT6 := {/* cFilOri */, cFilDes      , /* cFilNeg */, cFilDeb      , /* cFilDoc */, cNumNFS      , cSerNF       , cCliRem      , cLojRem      , cCliDes      ,;
				cLojDes      , cCliDev      , cLojDev      , cCliente     , cLoja        , cCdrOri      , cCdrDes      , cCdrCal      , cCliCon      , cLojCon      ,;
				cCliDpc      , cLojDpc      , /* dPrzEnt */, /* dDatEmi */, /* cHorEmi */, /* cUsrGer */, cDocTMS      , /* cStatus */, /* cBlqDoc */, /* cPriPer */,;
				/* cFImp */  , cTipFre      , cDevFre      , /* cSerTms */, cLotNfc      , /* nMoeda */ , cTipTra      , cSrv         , cCodMsg      , /* cSitCte */,;
				/* cRetCte */, nValMerc     , nPesoM3      , nPesoCobr    , nQtdUnit     , nQtdVol      , nQtdVol      , nPeso        , nValFre      , nValImp      ,;
				nValTot      , nVrlFatF2    , nAcresc      , nDecresc     , /*cTabFre*/  , /*cTipTab*/  ,/*cSeqTab*/   ,/*cNrCont*/   , /*cCodNeg*/  , cFilDco      ,; 
				cDocDco      , cSerDco  }

aPontEntr  := {/* cPEPosDT6 */, "TM491DT6"}
aRetDT6    := TmsGrvDT6(aParGrvDT6, aPontEntr)
cFilDoc    := aRetDT6[1]
cDoc       := aRetDT6[2]
cSerie     := aRetDT6[3]
nRecDT6    := aRetDT6[4]

//-- Gravacao da Composicao do Frete
TmsGrvDT8("TMSA200", cFilDoc, cDoc, cSerie, "1", .T., aCmpFrt)

//-- Valor total para geracao da fatura
cA1RecISS := Posicione('SA1', 1, xFilial('SA1')+cCliDev+cLojDev, 'A1_RECISS') 

If cA1RecISS == '1' .And. lDescIss	.And. lTPABISS //Cenário - Campo A1_RECISS = S e parâmetros MV_TPABISS= 1 e MV_DESCISS = .T.
	nValFat += Iif(nVrlFatF2  > 0,nVrlFatF2 ,nValTot) + nAcresc - nDecresc
Else
	nValFat += nValTot + nAcresc - nDecresc
EndIf	

RestArea(aAreaDUY)
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491CDoc³ Autor ³ Eduardo de Souza     ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelamento de documento de Transporte                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA491CDoc()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA281                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA491CDoc(cFilDoc, cDoc, cSerie)

Local lTMSNFAT := SuperGetMv("MV_TMSNFAT",.F.,.T.)
Local cPrfx    := ""

Private cPrefix   := GetMv("MV_FATPREF",, "") // Prefixo da Fatura.
Private cTipo     := GetMv("MV_TIPFAT" ,, "") // Tipo da Fatura.
Private cMvSrvFat := GetMv("MV_SRVFAT",, "") // Servicos da Fatura

Default cFilDoc   := SE1->E1_FILORIG 
Default cSerie    := IIf(!Empty(SE1->E1_SERIE),SE1->E1_SERIE,SE1->E1_PREFIXO)

If lTM850Pref
	cPrfx := ExecBlock("TM850PREF",.F.,.F.) //PE para manipular o prefixo da fatura
	If !Empty(cPrfx) .And. ValType(cPrfx) == "C"
		cPrefix := cPrfx
	EndIf
EndIf

//-- Estorna documentos
If lTMSNFAT
	If	TMSDelNFS( cDoc, cSerie )

		//-- Exclui documento de transporte
		DT6->(DbSetOrder(1))
		If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))

			//-- Exclui lote
			DTP->(DbSetOrder())
			If DTP->(MsSeek(xFilial("DTP")+DT6->DT6_LOTNFC))
				RecLock("DTP",.F.)
					DTP->(DbDelete())
				DTP->(MsUnlock())
			EndIf

			//-- Exclui composicao do documento de transporte
			DT8->(DbSetOrder(2))
			If DT8->(MsSeek(xFilial("DT8")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
				While DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_FILDOC + DT8->DT8_DOC + DT8->DT8_SERIE == xFilial("DT8") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE
					RecLock("DT8",.F.)
					DT8->(DbDelete())
						DT8->(MsUnlock())
					DT8->(DbSkip())
				EndDo
			EndIf

			//--Exclui o Documento de Transporte
			RecLock("DT6",.F.)
				DT6->(DbDelete())
			DT6->(MsUnlock())
		EndIf
	EndIf
Else
	If	TMSDelNFS( SE1->E1_NUM, cSerie )
		//-- Exclui documento de transporte
		DT6->(DbSetOrder(1))
		If DT6->(MsSeek(xFilial("DT6")+SE1->E1_FILORIG+SE1->E1_NUM+cSerie))

			//-- Exclui lote
			DTP->(DbSetOrder())
			If DTP->(MsSeek(xFilial("DTP")+DT6->DT6_LOTNFC))
				RecLock("DTP",.F.)
					DTP->(DbDelete())
				DTP->(MsUnlock())
			EndIf

			//-- Exclui composicao do documento de transporte
			DT8->(DbSetOrder(2))
			If DT8->(MsSeek(xFilial("DT8")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
				While DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_FILDOC + DT8->DT8_DOC + DT8->DT8_SERIE == xFilial("DT8") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE
					RecLock("DT8",.F.)
						DT8->(DbDelete())
					DT8->(MsUnlock())
					DT8->(DbSkip())
				EndDo
			EndIf

			//--Exclui o Documento de Transporte
			RecLock("DT6",.F.)
				DT6->(DbDelete())
			DT6->(MsUnlock())
		EndIf
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491Nat ³ Autor ³ Eduardo de Souza     ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Armazena as naturezas de Transporte                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA491Nat()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Natureza da Fatura Transporte Rodoviario           ³±±
±±³          ³ ExpC2 - Natureza da Fatura Transporte Rodoviario           ³±±
±±³          ³ ExpC3 - Natureza da Fatura Transporte Aereo                ³±±
±±³          ³ ExpC4 - Natureza da Fatura Transporte Fluvial              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA491                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA491Nat(cNat, cNatRod, cNatAer, cNatFlu)

Local cNatTipTra   := GetMv("MV_NATFTRA",, "") // 'Servicos da Fatura  
Local nTamIni      := 0
Local nPosIni      := 0
Local aNatCli      := {}
Local lRet         := .T.

Default cNatRod    := ''
Default cNatAer    := ''
Default cNatFlu    := ''

cNat := GetMv("MV_NATFAT" ,, "") // Natureza da Fatura (Generico)

If lTM491NAT
	aNatCli := ExecBlock('TM491NAT',.F.,.F.)  // -- Retorno do ponto de entrada.
	//aNatCli[1] := Natureza da Fatura (Generico)
	//aNatCli[2] := Natureza da Fatura Transporte Rodoviario
	//aNatCli[3] := Natureza da Fatura Transporte Aereo
	//aNatCli[4] := Natureza da Fatura Transporte Fluvial
	If ValType(aNatCli) <> 'A'
		aNatCli   := {}
		lTM491NAT := .F.
	EndIf
EndIf

//-- Alimenta as naturezas de transporte
If lTM491NAT
	cNat     := aNatCli[1] // Natureza da Fatura (Generico)
	If Len(aNatCli) >= 2
		cNatRod  := aNatCli[2] // Natureza da Fatura Transporte Rodoviario
	EndIf
	If Len(aNatCli) >= 3
		cNatAer  := aNatCli[3] // Natureza da Fatura Transporte Aereo
	EndIf
	If Len(aNatCli) >= 4
		cNatFlu  := aNatCli[4] // Natureza da Fatura Transporte Fluvial	
	EndIf
Else
	If !Empty(cNatTipTra)
		//-- Procura a Natureza do Transporte Rodoviario informada no parametro MV_NATFTRA
		If (nPosIni := At('1=',cNatTipTra)) > 0
			nPosIni +=2
			nTamIni := At(";",Substr(cNatTipTra,nPosIni)) - 1
			If nTamIni > 0
				cNatRod := Substr(cNatTipTra,nPosIni, nTamIni)
			Else
				cNatRod := ALLtrim(Substr(cNatTipTra,nPosIni, Len(SED->ED_CODIGO)))
			EndIf
		EndIf

		//-- Procura a Natureza do Transporte Aereo informada no parametro MV_NATFTRA
		If (nPosIni := At('2=',cNatTipTra)) > 0
			nPosIni +=2
			nTamIni := At(";",Substr(cNatTipTra,nPosIni)) - 1
			If nTamIni > 0
				cNatAer := Substr(cNatTipTra,nPosIni, nTamIni)
			Else
				cNatAer := ALLtrim(Substr(cNatTipTra,nPosIni, Len(SED->ED_CODIGO)))
			EndIf
		EndIf

		//-- Procura a Natureza do Transporte Fluvial informada no parametro MV_NATFTRA
		If (nPosIni := At('3=',cNatTipTra)) > 0
			nPosIni +=2
			nTamIni := At(";",Substr(cNatTipTra,nPosIni)) - 1
			If nTamIni > 0
				cNatFlu := Substr(cNatTipTra,nPosIni, nTamIni)
			Else
				cNatFlu := AllTrim(Substr(cNatTipTra,nPosIni, Len(SED->ED_CODIGO)))
			EndIf
		EndIf
	EndIf
EndIf
If !Empty(cNatRod) .And. !(SED->(MsSeek(xFilial("SED") + cNatRod)))
	Help(" ", 1,"TMSA49009",,AllTrim(cNatRod) + STR0046 + CRLF + STR0007,1,12) //"A Natureza"###" informada no parametro MV_NATFTRA, nao foi cadastrada"
	lRet := .F.
EndIf
If lRet .And. !Empty(cNatAer) .And. !(SED->(MsSeek(xFilial("SED") + cNatAer)))
	Help(" ", 1,"TMSA49009",,AllTrim(cNatAer) + STR0046 + CRLF + STR0007,1,12) //"A Natureza"###" informada no parametro MV_NATFTRA, nao foi cadastrada"
	lRet := .F.
EndIf
If lRet .And. !Empty(cNatFlu) .And. !(SED->(MsSeek(xFilial("SED") + cNatFlu)))
	Help(" ", 1,"TMSA49009",,AllTrim(cNatFlu) + STR0046 + CRLF + STR0007,1,12) //"A Natureza"###" informada no parametro MV_NATFTRA, nao foi cadastrada"
	lRet := .F.
EndIf
If lRet .And. Empty(cNat) .Or. !(SED->(MsSeek(xFilial("SED") + cNat)))
	Help(" ", 1, "TMSA49005") // "Natureza da Fatura invalida MV_NATFAT"
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa491Cli ³ Autor ³ Eduardo de Souza     ³ Data ³ 23/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza o cliente da fatura.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa491Cli(ExpA1,ExpN1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Vetor contendo todas as Faturas                     ³±±
±±³          ³ExpN1 - Linha da Fatura                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA491                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa491Cli(aFatCli,nLinha)

//-- Posiciona no cliente da Fatura
SA1->(dbSetOrder(1))
If SA1->(MsSeek(xFilial('SA1')+ aFatCli[nLinha][CLCOD]+ aFatCli[nLinha][CLLOJA]))
	A030Visual('SA1',SA1->(Recno()),2)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491Psq³ Autor ³ Eduardo de Souza      ³ Data ³ 03/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa cliente                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA491Psq(ExpO1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - List Box                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA491                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa491Psq(oLbx,aFatCli)

Local aCbx     := {}
Local cCampo   := ''
Local cOrd
Local lSeek    := .F.
Local nOrdem   := 1
Local nSeek    := 0
Local oCbx
Local oDlg
Local oPsqGet

//-- (01) Cod.Cliente + Loja Cliente
cCampo := STR0027+"+"+STR0028
Aadd( aCbx, cCampo )
//-- (02) Nome Cliente
cCampo := STR0029
Aadd( aCbx, cCampo )
//-- (03) Valor
cCampo := STR0030
Aadd( aCbx, cCampo )


cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0047 //"Pesquisa"

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If	lSeek
	cCampo := AllTrim( cCampo )
	If nOrdem == 1
		ASort( aFatCli,,,{|x,y| x[CLCOD] + x[CLLOJA] < y[CLCOD] + y[CLLOJA] })
		nSeek := Ascan( aFatCli,{ | x | PadR( x[CLCOD] + x[CLLOJA] + AllTrim(Str(x[CLVLFAT])), Len( cCampo ) ) == cCampo } )
	ElseIf nOrdem == 2
		ASort( aFatCli,,,{|x,y| x[CLNOME] < y[CLNOME] })
		nSeek := Ascan( aFatCli,{ | x | PadR( x[CLNOME] + AllTrim(Str(x[CLVLFAT])), Len( cCampo ) ) == cCampo } )
	Else
		ASort( aFatCli,,,{|x,y| x[CLVLFAT] < y[CLVLFAT] })
		nSeek := Ascan( aFatCli,{ | x | PadR( AllTrim(Str(x[CLVLFAT])), Len( cCampo ) ) == cCampo } )
	EndIf
EndIf

If	nSeek > 0
	oLbx:nAT := nSeek
	oLbx:Refresh()
EndIf

oLbx:SetFocus()

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491ChD ³ Autor ³ Telso Carneiro       ³ Data ³ 11/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica Tipo de documento 1=Normal;2=Documento de Apoio 1 ³±±
±±³          ³ 3=Documento de Apoio 2, para o Faturamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA491ChD                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA491                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA491ChD(cTMSMFat,cTipoDoc)
Local lRet := .T.

If cTMSMFat <> '2'
	//-- Verifica se o campo Documento da Fatura existe.
	lRet := .F.
	If !Empty(Posicione("DUI",1,xFilial("DUI")+cTipoDoc,"DUI_DOCFAT")) .Or. Empty(cTipoDoc)
		lRet := .T.
	Endif
Endif

If ! lRet
	Help("",1,"TMSA49101") //-- O Parametro MV_TMSMFAT esta configurado para faturar a partir do SE1
Endif

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
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
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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

Static Function MenuDef()

Private aRotina	:= {	{ STR0002 ,"AxPesqui"   , 0, 1,0,.F. },;	//"Pesquisar"
						{ STR0003 ,"Tmsa850Vis" , 0, 2,0,NIL },;	//"Visualizar"
						{ STR0004 ,"Tmsa491Mnt" , 0, 3,0,NIL },;	//"Gerar"
						{ STR0005 ,"Tmsa850Exc" , 0, 6,0,NIL },;	//"Cancelar"
						{ STR0071 ,"TmsA491Imp" , 0, 8,0,NIL },;    //Impressão Fatura
						{ STR0006 ,"Tmsa850Leg" , 0, 6,0,.F. } }	//"Legenda"

//-- Rotina comentada pois esta opção não será expedida na versão 12.1.23						
//If FindFunction("Tmsa854")
//	aAdd(aRotina,{ STR0080,"VIEWDEF.TMSA854" , 0, 3,0,NIL }) //"Fatura Cod. Barras"
//EndIf						

If ExistBlock("TM491MNU")
	ExecBlock("TM491MNU",.F.,.F.)
EndIf

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491Aju ³ Autor ³ Robson Alves         ³ Data ³ 30/07/08 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Atualiza o valor fixo de contrato na fatura.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSA491Aju( aFatCli, nVlrTot )
Local nA       := 0
Local nB       := 0
Local nValDiff := 0
Local nValProp := 0
Local aVFContr := {}

//--Atualiza os valores dos
//--documentos:
For nA := 1 To Len( aFatCli)

	If !Empty(aFatCli[nA,CLSERVIC])

		//--Verifica se o contrato do cliente esta 
		//--configurado para cobranca de valor fixo
		aVFContr := TMSA491VlrC( aFatCli[nA,CLCOD], aFatCli[nA,CLLOJA], aFatCli[nA,CLTIPFRE], aFatCli[nA,CLSERVIC], aFatCli[nA,CLDTATE],,aFatCli[nA][CLTPFRDV],nil,.F. ) 

		If Len(aVFContr) > 0 .And. aVFContr[1] > 0

			//--Proporcionaliza o valor fixo
			//--do contrato de acordo com a 
			//--quantidade de documentos da 
			//--fatura:
			nValProp := Round( aVFContr[5] / Len(aFatCli[nA,CLDOCTOS]), TamSX3("DT6_VALFRE")[2] )

			For nB := 1 To Len( aFatCli[nA,CLDOCTOS] )
				aFatCli[nA, CLDOCTOS, nB, 6] := nValProp	//--Valor do Acrescimo: Acrescenta o valor fixo do contrato + Impostos
				aFatCli[nA, CLDOCTOS, nB, 8] += nValProp	//--Valor a Faturar: Considera o valor a faturar (Com o Desconto) + valor fixo do contrato + Impostos
			Next nB

			aFatCli[nA, CLVLFAT] += aVFContr[5]		//--Total da Fatura: Acrescenta o valor fixo do contrato + Impostos

			//--Retorna o Valor Total da
			//--Fatura atualizado
			nVlrTot += aVFContr[5]

			//--Verifica se existe diferenca de
			//--arredondamento:
			nValDiff := aVFContr[5] - Round( nValProp * Len(aFatCli[nA,CLDOCTOS]), TamSX3("DT6_VALFRE")[2] )
			If nValDiff <> 0
				//--Realiza o ajuste da 
				//--diferenca encontrada no
				//--primeiro docto. da Fatura:
				If nValDiff > 0
					aFatCli[nA, CLDOCTOS, 1, 6] += nValDiff
					aFatCli[nA, CLDOCTOS, 1, 8] += nValDiff
				Else
					aFatCli[nA, CLDOCTOS, 1, 6] -= (nValDiff * -1)
					aFatCli[nA, CLDOCTOS, 1, 8] -= (nValDiff * -1)
				EndIf
			EndIf
		EndIf
	EndIf
Next nA

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491VlrC³ Autor ³ Robson Alves         ³ Data ³ 30/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o contrato contempla um valor fixo de cobranca.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA491VlrC(  ExpC1, ExpC2, ExpC3 , ExpC4, ExpD5)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Cliente.                                 ³±±
±±³          ³ ExpC2 - Loja do Cliente.                                   ³±±
±±³          ³ ExpC3 - Tipo de Frete                                      ³±±
±±³          ³ ExpC4 - Servico                                            ³±±
±±³          ³ ExpC5 - Data "Ate" da faixa do tipo de faturamento         ³±±
±±³          ³ ExpL5 - Contrato cobra somente valor fixo (.T./.F.)        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA491VlrC( cCliDev, cLojDev, cTipFre , cServic, dDtAte, aContrato,cTipFreDv,cCodNeg, lVisErr )
Local aRet      := {}
Local aFrtAux   := {}
Local cCdrOri   := GetMv("MV_CDRORI",,"")
Local cCdrDes   := cCdrOri
Local cDocTMS   := ''
Local cDocFAT   := ''
Local cTpCli    := ''
Local cIncISS   := Iif(SuperGetMv('MV_INCISS',,.F.),'S','N') //-- TES Incide ISS (S/N)
Local cCliGen   := Left(GetMv("MV_CLIGEN"),Len(SA1->A1_COD))
Local cLojGen   := Right(GetMv("MV_CLIGEN"),Len(SA1->A1_LOJA))
Local cCodComp  := PadR( GetMV("MV_CODCOMP",,""), Len(DT3->DT3_CODPAS) ) //Parametro para identificar o codigo do componente
Local cDesComp  := ''
Local cCodPro   := ''
Local cSerTms   := ''
Local lIdentDoc := DTC->(ColumnPos("DTC_DOCTMS")) > 0

Local aArea     := GetArea()
Local aAreaDC5  := DC5->( GetArea() )
Local aAreaDUI  := DUI->( GetArea() )
Local aAreaSA1  := SA1->( GetArea() )
Local aAreaDT3  := DT3->( GetArea() )
Local aAreaDUX  := DUX->( GetArea() )

If Type("aMsgErr") == "U"
	Private aMsgErr := {}
EndIf

Default aContrato  := ""
Default cTipFreDv  := ""
Default cCodNeg    := ""
Default lVisErr    := .T.

//--FORMATO DO VETOR "aRET"
//--[01]VALOR FIXO DO CONTRATO
//--[02]COBRA SOMENTE O VALOR FIXO DO CONTRATO (.T./.F.)
//--[03]VALOR LIQUIDO REFERENTE AO VALOR FIXO
//--[04]VALOR DOS IMPOSTOS 
//--[05]VALOR BRUTO REFERENTE AO VALOR FIXO

//--Obtem o contrato do cliente...
If Empty(aContrato)
	aContrato := TMSContrat( cCliDev, cLojDev, dDtAte, cServic, .F., cTipFre ,,,,,,,,,,,,,,,,cCodNeg)
	//-- Caso o tipo do servico for 'transporte' e uma Devolucao Parcial, procura o contrato invertido 
	If Empty(aContrato)
		cSerTms := Posicione('DC5', 1, xFilial('DC5') + cServic, 'DC5_SERTMS')
		If cSerTms == StrZero(2,Len(DT6->DT6_SERTMS)) .And. !Empty(cTipFreDv) .And. cTipFre <> cTipFreDv   //Identifica que ha inversao de Tipo de Frete
			If cTipFre == StrZero(2,Len(DT6->DT6_TIPFRE))   //FOB, Procura o contrato (CIF) para o destinatario
				cTipFreDv:= StrZero(1,Len(DT6->DT6_TIPFRE))
			EndIf
			If cTipFre == StrZero(1,Len(DT6->DT6_TIPFRE))   //CIF, Procura o contrato (FOB) para o destinatario
				cTipFreDv:= StrZero(2,Len(DT6->DT6_TIPFRE))
			EndIf
			aContrato := TMSContrat( cCliDev, cLojDev, dDtAte, cServic, .F.,cTipFreDv ,,,,,,,,,,,,,,,,cCodNeg)
		EndIf
	EndIf
EndIf

If !Empty( aContrato )
	cContrato := aContrato[1,1]
	//--Verifica se o contrato contempla um valor 
	//--fixo de cobranca de faturamento.
	DUX->( DbSetOrder(2) ) //--DUX_FILIAL+DUX_NCONTR+DUX_SERVIC
	If DUX->( MsSeek( xFilial("DUX") + cContrato + cServic ) )
		If DUX->DUX_VALFIX > 0 .And. DUX->DUX_FIXVAR <> StrZero(0, Len(DUX->DUX_FIXVAR) )
			AAdd( aRet, DUX->DUX_VALFIX )
		Else
			AAdd( aRet, 0 )
		EndIf
		AAdd( aRet, DUX->DUX_FIXVAR == StrZero(1, Len(DUX->DUX_FIXVAR)) )

		If aRet[1] > 0
			If lIdentDoc
				cDocTMS := TMSTipDoc(DT6->DT6_CDRORI,DT6->DT6_CDRCAL)
			Else
				cDocTMS := Posicione('DC5', 1, xFilial('DC5') + cServic, 'DC5_DOCTMS')
			EndIf
			//--Tratamento: Produto de Calculo
			DUI->( DbSetOrder(1) )
			If DUI->( DbSeek( xFilial('DUI') + cDocTMS ) )
				cDocFAT := DUI->DUI_DOCFAT
				If !Empty(DUI->DUI_PRDCIF)
					cCodPro := DUI->DUI_PRDCIF
				Else
					cCodPro := DUI->DUI_CODPRO
				EndIf
			EndIf

			//--Dados do Cliente
			cTpCli     := Posicione('SA1', 1, xFilial('SA1')+cCliDev+cLojDev, 'A1_TIPO') 
			cA1_INCISS := Posicione('SA1', 1, xFilial('SA1')+cCliDev+cLojDev, 'A1_INCISS')

			cDesComp  := Posicione( 'DT3', 1, xFilial('DT3') + cCodComp, 'DT3_DESCRI' )

			//--Calcula o valor dos Impostos
			//--em cima do valor fixo do contrato
			AAdd( aFrtAux, {'', {}} )
			AAdd( aFrtAux[Len(aFrtAux)][2], {	cDesComp,;	//--[01]DESCRICAO DO COMPONENTE
												aRet[1],;	//--[02]VALOR DO COMPONENTE (LIQUIDO)
												cCodComp,;	//--[03]CODIGO DO COMPONENTE
												'',;		//--[04]ITEM x SD2
												0,;			//--[05]VALOR DOS IMPOSTOS
												aRet[1],;	//--[06]VALOR DO COMPONENTE (BRUTO)
												cCdrOri,;	//--[07]REGIAO DE ORIGEM
												cCdrDes,;	//--[08]REGIAO DESTINO
												'',;		//--[09]TABELA DE FRETE
												'',;		//--[10]TIPO DA TABELA DE FRETE
												'',;		//--[11]SEQUENC. DA TABELA DE FRETE
												'',;		//--[12]**NAO USADO**
												0,;			//--[13]VALOR DE DESCONTO
												0,;			//--[14]VALOR DE ACRESCIMO
												'2' } )		//--[15]CALCULADO PELO MINIMO (1=SIM/2=NAO)

			//--Calcula os Impostos.
			//--Os valores serao atualizados no 
			//--vetor "aFrtAux":
			TmsA040Imp( aFrtAux[Len(aFrtAux)][2],;	//--Composicao do Frete
						cCliDev, cLojDev,;			//--Devedor do Frete 
						cDocFAT,; 					//--Documento de Transporte
						cTipFre,;					//--Tipo do Frete (1=CIF|2=FOB)
						cCdrDes,; 					//--Codigo da Regiao Destino
						.T.,;						//--Considera a UF de destino (.T./.F.)
						,; 							//--Aliquota do ICMS
						cFilAnt,;					//--Filial de Destino
						cTpCli,;					//--Tipo do Cliente (F=Cons.Final|L=Produtor Rural|R=Revendedor|S=Solidario|X=Exportacao)
						.F.,;						//--Calculo referente a complemento de imposto? (.T./.F.)
						cCdrOri,;					//--Codigo da regiao de origem
						cFilAnt,;					//--Filial de Origem
						cIncISS,;					//--ISS embutido no preco
						cCliDev, cLojDev,;			//--Cliente Remetente
						cCliGen, cLojGen,;			//--Cliente Destinatario
						'N',; 						//--Tipo do Documento (N=Docto. Normal|I=Complemento de Imposto)
						.F.,;						//--Exibe Help (.T./.F.)
						'0',; 						//--Tipo da Nota Fiscal (0=Normal|1=Devoluncao|2=SubContratacao)
						cCodPro ) 					//--Codigo do Produto de Calculo

			//--Retorna os Valores (Liquido/Impostos/Bruto)
			AAdd( aRet, aFrtAux[Len(aFrtAux)][2][1][2] )	//--Valor Liquido
			AAdd( aRet, aFrtAux[Len(aFrtAux)][2][1][5] )	//--Impostos
			AAdd( aRet, aFrtAux[Len(aFrtAux)][2][1][6] )	//--Valor Bruto
		Else
			//--Retorna o vetor zerado
			AAdd( aRet, 0 )	//--Valor Liquido
			AAdd( aRet, 0 )	//--Impostos
			AAdd( aRet, 0 )	//--Valor Bruto
		EndIf
	EndIf
Else
	AAdd( aMsgErr, {STR0049, '04', "" } ) //"Nao foi encontrado contrato para o cliente"
EndIf

If !Empty(aMsgErr) .And. lVisErr
	TmsMsgErr( aMsgErr )
EndIf

RestArea( aAreaDUX )
RestArea( aAreaDT3 )
RestArea( aAreaSA1 )
RestArea( aAreaDUI )
RestArea( aAreaDC5 )
RestArea( aArea )
Return( aRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA491SrvFt ³ Autor ³ TOTVS S/A          ³ Data ³ 05-Out-09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os Servicos de Faturamento Vs. Doctos. de Apoio    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSA491SrvFt()
Local nCnt     := 0
Local nPosIni  := 0
Local nTam     := 0
Local aTpSrvFt := {}
Local cSrvFat  := GetMv("MV_SRVFAT",, "") // Servicos da Fatura
Local aRet     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DOCTOS. APOIO x SERVICOS FAT.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aTpSrvFt, "B1=" )
Aadd( aTpSrvFt, "B2=" )
Aadd( aTpSrvFt, "C1=" )
Aadd( aTpSrvFt, "C2=" )
Aadd( aTpSrvFt, "H1=" )
Aadd( aTpSrvFt, "H2=" )
Aadd( aTpSrvFt, "I1=" )
Aadd( aTpSrvFt, "I2=" )

For nCnt := 1 To Len(aTpSrvFt)
	nPosIni := At( aTpSrvFt[nCnt], cSrvFat )
	If nPosIni <> 0
		nPosIni += 3
		nTam := At( ";", Substr(cSrvFat,nPosIni) ) - 1
		If nTam <= 0
			nTam := Len(Alltrim(Substr(cSrvFat,nPosIni))) + 1
		EndIf
		AAdd( aRet, { SubStr(aTpSrvFt[nCnt],1,2), Substr(cSrvFat,nPosIni,nTam) })
	EndIf
Next

Return( aRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TM491DOC ³ Autor ³Aldo Barbosa dos Santos³ Data ³23.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3 para visualizar tipo de documento              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM491DOC(cCampo)
Local lTodos := .F.
Local xRet
Default cCampo  := ReadVar()

xRet := Tm491Perg(cCampo)

Return( xRet )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM491Perg ³ Autor ³Aldo Barbosa dos Santos³ Data ³23.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe a tela do F3 do pergunte                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Campo                                      ³±±
±±³          ³ ExpL2 - Seleciona opcao via consulta F3                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function Tm491Perg(cCampo)
Local nTmsItem  := 0
Local aTipoDoc  := {}
Local cTitulo   := STR0041  //"Selecao do Tipo de Documento"
Local lRet      := .T.

aTpSrvFat := {}
aRetSvc   := {}

// carrega o vetor com os tipos de documento
cDOCTMS  := &(cCampo)  // variavel necessaria para o TMSValField
aTipoDoc := TMSValField('cDOCTMS',.F.,'',.F.,.T.,.F.,.T.)

// acrescenta o tipo Normal
Aadd( aTipoDoc, {' ',  ' '})
AIns ( aTipoDoc, 1 )
aTipoDoc[1] := {' ',  STR0042}  //'Normal'

// valida a digitacao do pergunte
lRet := Tm491Vld( '12', &(cCampo) )

//-- Apresenta a tela para selecao do item.
If	lRet
	nTmsItem := TmsF3Array( {STR0062,STR0063}, aTipoDoc, cTitulo, Nil, Nil, Nil )  // 	"Código"#"Descrição"

	If	nTmsItem > 0
		//-- VAR_IXB eh utilizada como retorno da consulta F3 TIPDOC.
		VAR_IXB := aTipoDoc[ nTmsItem, 1 ]
	EndIf
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tm491Vld  ³ Autor ³ Aldo Barbosa dos Santos        ³23/11/10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do pergunte do programa TMSA491                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA491                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tm491Vld(cPerg, cDado)
 Local cTMSMFat  := GetMV("MV_TMSMFAT",,"") //-- Modo de Faturamento:1-Faturamento a partir do SE1;2=Faturamento a partir do DT6
 Local lRetorno := .T.
 Local aTipoDoc := {}

	// validacao dos perguntes do programa TMSA491
	If cPerg == '12'  // Valid da pergunta 12 "Tipo de Documento"
		cDocTms := cDado // variavel necessaria para o TMSValField
		aTipoDoc := TMSValField('cDOCTMS',.F.,'',.F.,.T.,.F.,.T.)

		// acrescenta o tipo Normal
		Aadd( aTipoDoc, {' ',  ' '})
		AIns ( aTipoDoc, 1 )
		aTipoDoc[1] := {' ',  STR0042}  //'Normal'

		lRetorno := ( Ascan( aTipoDoc, { |x| x[1] ==  cDado }) > 0 )
		If ! lRetorno
			Aviso(STR0060, STR0066+" "+STR0067+" !", {STR0061} ) //"AVISO"#"Tipo de Documento"#"inválido"#"OK"
		ElseIf  (!Empty(GetMV("MV_DATAFIS",,"")) .AND. cDocTms != " ")
				If !FisChkDt(dDataBase)
					Return( .F. )
				EndIf
		Else
			lRetorno := TMSA491ChD(cTMSMFat,cDocTms)
		EndIf

	EndIf

Return( lRetorno )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tm491Mail ³ Autor ³ Aldo Barbosa dos Santos        ³25/11/10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Prepara os dados para envio de email                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM491Mail()
Local aArea       := GetArea()
Local lSendMail   := .F.
Local nAux        := 0
Local cSubject    := ""
Local cBody       := ""
Local cMsgErr     := ""
Local aDestE      := {}
Local cDestE      := GetMv("MV_FATMAIL",, "") // destinatarios do email de faturamento via schedule
Local aTM491MAIL  := {}

// se o parametro de destinatarios de envio de email estiver vazio ignora o envio
If ValType(cDestE) <> "C" .or. Empty(cDestE)
	Return Nil
EndIf

aDestE := StrTokArr(cDestE,";")
If Len(aDestE) == 0
	Return Nil
EndIf

cSubject	:= ''+STR0059+' - ' + Dtoc(dDataBase) + ' - ' + Time()

// corpo principal do email com o resumo do envio
cBody	:= '<html>'
cBody	+= '  <head>'
cBody	+= '    <title>' + STR0059 + ' ' + STR0057 + ' - Filial ' + cFilAnt + '</title>' // "Faturamento Automatico"#"via Schedule"
cBody	+= '  </head>'
cBody	+= '  <body style="font-family: Arial; font-size: 12px">'
cBody	+= '    <h1 style="color: #000099">'
cBody	+= '      <b>' + STR0059 + ' - Filial ' + cFilAnt + '</b>' // "Faturamento Automático"
cBody	+= '    </h1>'
cBody	+= '    <h1><hr></h1>'

// Adiciona as mensagens contidas no vetor:
If Len(aMsgSch) > 0
	cBody	+= '    <h2>' + STR0064 + ' : </h2>' // "Mensagens do processamento"
	cBody	+= '    <ul>'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MONTAGEM DO E-MAIL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nAux := 1 To Len(aMsgSch)
		cBody += '      <li>' + aMsgSch[nAux] + '</li>'
	Next
	cBody	+= '    </ul>'
	cBody	+= '    <h1><hr></h1>'
EndIf

cBody	+= '    <h3 style="color: #FF0000">' + STR0059 + '&nbsp;' + Dtoc(Date()) + ' as ' + Time() + '</h3>'
cBody	+= '  </body>'
cBody	+= '</html>'


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PONTO DE ENTRADA PARA MANIPULAR A MENSAGEM         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTM491MAIL
	aTM491MAIL := ExecBlock('TM491MAIL',.F.,.F.,{cSubject,cBody,aDestE,aMsgSch})
	If ValType(aTM491MAIL ) == 'A'
		If ValType(aTM491MAIL[1]) == 'C'
			cSubject := aTM491MAIL[1]			// assunto
		EndIf
		If ValType(aTM491MAIL[2]) == 'C'
			cBody := aTM491MAIL[2]				// corpo do email
		EndIf
		If ValType(aTM491MAIL[3]) == 'A'
			aDestE := aClone(aTM491MAIL[3])		// destinatarios
		EndIf
		If ValType(aTM491MAIL[4]) == 'A'
			aMsgSch := aClone(aTM491MAIL[4])	// mensagens de erro
		EndIf
	EndIf
EndIf

// se nao tem assunto, ou corpo, ou destinatario - nao envia email para nao dar erro
If ! Empty(cSubject) .and. !Empty(cBody) .and. !Empty(aDestE)
	lSendMail := TMSMAIL( aDestE, Nil, cSubject, cBody, .F., '3', @cMsgErr, lTM491MAIL )

	If !lSendMail .And. !Empty(cMsgErr)
		TmsLogMsg("WARN",cMsgErr)  //-- Ocorreu um problema no envio do e-mail:
	EndIf
EndIf

RestArea(aArea)
Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ExecSchedule³ Autor ³ Aldo Barbosa dos Santos      ³21/12/10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna se o programa esta sendo executado via schedule     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExecSchedule()
Local lRetorno := .T.

lRetorno := IsBlind()

Return( lRetorno )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AdicionaMsg³ Autor ³ Aldo Barbosa dos Santos       ³22/12/10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona Mensagem no vetor do schedule                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AdicionaMsg(cMsg)
Local cDestE   := SuperGetMv("MV_FATMAIL",, "")    // destinatarios do email de faturamento via schedule
Local nThreads := SuperGetMv("MV_TMSTHRE", , 0)

If ! Empty(cDestE) .And. nThreads=0
	Aadd(aMsgSch, cMsg) // adiciona mensagem ao vetor para envio por email
Else
	TmsLogMsg("WARN",cMsg)
EndIf

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsA491Imp
Chama o programa para impressão da Fatura posicionada
@type function
@author Rafael Souza
@version 12
@since 01/10/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Registro
@param [nOpcx], Numérico, Opção do menu
@param [lImprime], Lógico, Define se deve ou não imprimir
@return Nil Não há retorno
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 30/05/2017
/*/
//-------------------------------------------------------------------------------------------------
Function TmsA491Imp(cAlias, nReg, nOpcx, lImprime)
	
	Local cPrefixo := ""
	Local cNumFat  := ""
	Local cCliFat  := ""
	Local cLojFat  := ""
	Local dDtaEmis := ""
	Local cTmsERP  := SuperGetMV("MV_TMSERP",,'0')
	Local cPerg    := ""

	Default lImprime := .T.

	If ! lImprime
		Return
	EndIf

	If cTmsERP == '0' //-- ERP Protheus

		cPerg    := "TMSR650"
		cPrefixo := SE1->E1_PREFIXO
		cNumFat  := SE1->E1_NUM
		cCliFat  := SE1->E1_CLIENTE
		cLojFat  := SE1->E1_LOJA
		dDtaEmis := SE1->E1_EMISSAO

		//-- Atualiza os valores do SX1 conforme registro posicionado no Browse:
		
	SetMvValue(cPerg,"MV_PAR01",cPrefixo)	//-- Prefixo
	SetMvValue(cPerg,"MV_PAR02",cNumFat )	//-- Fatura De
	SetMvValue(cPerg,"MV_PAR03",cNumFat )	//-- Fatura Ate
	SetMvValue(cPerg,"MV_PAR04",cCliFat )	//-- Cliente De
	SetMvValue(cPerg,"MV_PAR05",cLojFat )   //-- Loja De
	SetMvValue(cPerg,"MV_PAR06",cCliFat )   //-- Cliente Ate
	SetMvValue(cPerg,"MV_PAR07",cLojFat )   //-- Loja Ate
	SetMvValue(cPerg,"MV_PAR08",dDtaEmis)	//-- Emissao De
	SetMvValue(cPerg,"MV_PAR09",dDtaEmis)	//-- Emissao Ate		

	ElseIf cTmsERP == '1' //-- ERP Datasul

		If DRT->DRT_STATUS = "3" .Or.; //-- Fatura parcialmente baixada
		   DRT->DRT_STATUS = "4" .Or.; //-- Fatura totalmente baixada
		   DRT->DRT_STATUS = "5" .Or.; //-- Fatura cancelada
		   DRT->DRT_STATUS = "6"       //-- Fatura protestada
			Help(" ", 1, "TMSA49106")  //-- "Apenas fatura com status: Fatura integrada ou Fatura impressa, pode ser impressa."
			Return
		EndIf

		cPerg    := "TMSR650A"
		cNumFat  := DRT->DRT_NUM
		cCliFat  := DRT->DRT_CLIFAT
		cLojFat  := DRT->DRT_LOJFAT
		dDtaEmis := DRT->DRT_DTEMIS

		//-- Atualiza os valores do SX1 conforme registro posicionado no Browse:
		SetMvValue(cPerg,"MV_PAR01",cNumFat)    //-- Fatura De       
		SetMvValue(cPerg,"MV_PAR02",cNumFat)	//-- Fatura Ate
		SetMvValue(cPerg,"MV_PAR03",cCliFat)	//-- Cliente De
		SetMvValue(cPerg,"MV_PAR04",cLojFat)	//-- Loja De
		SetMvValue(cPerg,"MV_PAR05",cCliFat)	//-- Cliente Ate
		SetMvValue(cPerg,"MV_PAR06",cLojFat)	//-- Loja Ate      
		SetMvValue(cPerg,"MV_PAR07",dDtaEmis) 	//-- Emissao De
		SetMvValue(cPerg,"MV_PAR08",dDtaEmis) 	//-- Emissao Ate
		
	EndIf

	//-- Executa relatorio padrao
	U_TMSR650(.T.)

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsA491DT6
Complementa os dados do frete do documento oficial que será gerado a partir do documento de apoio
@type static function
@author Valdemar Roberto Mognon
@version 12
@since 28/06/2019
/*/
//-------------------------------------------------------------------------------------------------
Static Function TmsA491DT6(aVFContr,aCmpFrt,aStruSF2,aDadosSF2,cProGen,cDocApoio,cTipTra,cCliente,cLoja,cDocTMS,nQtdVol,nPeso,aDadosSF2,cCposSF2,aCmpFrt,;
						   cF4_ISS,cTES,bFatSE1,cSerNF,aVFContr,cEspecie,nValMerc,nPesoM3,nPeso,nPesoCobr,nQtdUnit,cSrv,nRecDT6,nValFat,aDoctos,cCodMsg)

Local nPos       := 0
Local nPosComp   := 0
Local nCount     := 0
Local cCodComp   := PadR( GetMV("MV_CODCOMP",,""), Len(DT3->DT3_CODPAS) ) //Parametro para identificar o codigo do componente
Local cDesComp   := ""
Local cNumNFS    := ""
Local aSrv       := {}
Local aParGerNfs := {}
Local aPontEntr  := {}
Local aAreaDT6   := DT6->(GetArea())
Default aVFContr  := {}
Default aCmpFrt   := {}
Default aStruSF2  := {}
Default aDadosSF2 := {}
Default cProGen   := ""
Default cDocApoio := ""
Default cTipTra   := ""
Default cCliente  := ""
Default cLoja     := ""
Default cDocTMS   := ""
Default nQtdVol   := 0
Default nPeso     := 0
Default aDadosSF2 := {}
Default cCposSF2  := ""
Default aCmpFrt   := {}
Default cF4_ISS   := ""
Default cTES      := ""
Default bFatSE1   := {||.T.}
Default cSerNF    := ""
Default aVFContr  := {}
Default cEspecie  := ""
Default nValMerc  := 0
Default nPesoM3   := 0
Default nPeso     := 0
Default nPesoCobr := 0
Default nQtdUnit  := 0
Default cSrv      := ""
Default nRecDT6   := 0
Default nValFat   := 0
Default aDoctos   := {}
Default cCodMsg	  := ""

	If Len( aVFContr ) > 0
		If !aVFContr[2] .And. aVFContr[1] > 0
			//--Tratamento: Veiculo Dedicado
			//--Caso contrato esteja configurado
			//--com valor fixo a ser cobrado (Variavel), 
			//--gera mais um item na nota fiscal referente
			//--ao componente "Veiculo Dedicado":

			//--Duplica o componente 'TF' (Totalizador),
			//--pois este deve ser o ultimo elemento
			//--do vetor:
			nPos := Len( aCmpFrt )
			nPosComp := AScan( aCmpFrt[nPos,2], {|x| x[3] == 'TF'} )
			AAdd( aCmpFrt[nPos][2], aClone( aCmpFrt[nPos][2][nPosComp] ) )

			//--Altera os dados do componente
			//--que era o 'TF' e mantem o ultimo
			//--componente como o totalizador:
			cDesComp  := Posicione( 'DT3', 1, xFilial('DT3') + cCodComp, 'DT3_DESCRI' )

			aCmpFrt[nPos][2][nPosComp][01] := cDesComp			//--[01]DESCRICAO DO COMPONENTE
			aCmpFrt[nPos][2][nPosComp][02] := aVFContr[3]		//--[02]VALOR DO COMPONENTE (LIQUIDO)
			aCmpFrt[nPos][2][nPosComp][03] := cCodComp			//--[03]CODIGO DO COMPONENTE
			aCmpFrt[nPos][2][nPosComp][04] := ''				//--[04]ITEM x SD2
			aCmpFrt[nPos][2][nPosComp][05] := aVFContr[4]		//--[05]VALOR DOS IMPOSTOS
			aCmpFrt[nPos][2][nPosComp][06] := aVFContr[5]		//--[06]VALOR DO COMPONENTE (BRUTO)
			aCmpFrt[nPos][2][nPosComp][07] := DT6->DT6_CDRORI	//--[07]REGIAO DE ORIGEM
			aCmpFrt[nPos][2][nPosComp][08] := DT6->DT6_CDRDES	//--[08]REGIAO DESTINO
			aCmpFrt[nPos][2][nPosComp][09] := ''				//--[09]TABELA DE FRETE
			aCmpFrt[nPos][2][nPosComp][10] := ''				//--[10]TIPO DA TABELA DE FRETE
			aCmpFrt[nPos][2][nPosComp][11] := ''				//--[11]SEQUENC. DA TABELA DE FRETE
			aCmpFrt[nPos][2][nPosComp][12] := ''				//--[12]**NAO USADO**
			aCmpFrt[nPos][2][nPosComp][13] := 0				//--[13]VALOR DE DESCONTO
			aCmpFrt[nPos][2][nPosComp][14] := 0				//--[14]VALOR DE ACRESCIMO
			aCmpFrt[nPos][2][nPosComp][15] := '2'				//--[15]CALCULADO PELO MINIMO (1=SIM/2=NAO)

			//--Ajusta a linha totalizadora:
			nPosComp := AScan( aCmpFrt[nPos,2], {|x| x[3] == 'TF'} )
			If nPosComp > 0
				aCmpFrt[nPos][2][nPosComp][02] += aVFContr[3]		//--[02]VALOR DO COMPONENTE (LIQUIDO)
				aCmpFrt[nPos][2][nPosComp][05] += aVFContr[4]		//--[02]VALOR DOS IMPOSTOS
				aCmpFrt[nPos][2][nPosComp][06] += aVFContr[5]		//--[06]VALOR DO COMPONENTE (BRUTO)
			EndIf

			//--Ajusta o vetor auxiliar
			//--para geracao da NF de saida:
			For nCount := 1 To Len(aStruSF2)
				If AllTrim(aStruSF2[nCount,1]) == 'F2_VALBRUT'
					nPos := AScan(aDadosSF2, {|x| AllTrim(x[1]) == AllTrim(aStruSF2[nCount,1])} )
					If nPos > 0
						aDadosSF2[nPos,2] += aVFContr[5]
					EndIf
				ElseIf AllTrim(aStruSF2[nCount,1]) == 'F2_VALICM'
					nPos := AScan(aDadosSF2, {|x| AllTrim(x[1]) == AllTrim(aStruSF2[nCount,1])} )
					If nPos > 0
						aDadosSF2[nPos,2] += aVFContr[4]
					EndIf
				ElseIf AllTrim(aStruSF2[nCount,1]) $ 'F2_BASEICM|F2_VALMERC'
					nPos := AScan(aDadosSF2, {|x| AllTrim(x[1]) == AllTrim(aStruSF2[nCount,1])} )
					If nPos > 0
						aDadosSF2[nPos,2] += aVFContr[3]
					EndIf
				EndIf
			Next

		ElseIf aVFContr[2] .And. aVFContr[1] > 0
			//--Caso o contrato esteja configurado
			//--para geracao do valor fixo, monta a
			//--composicao do frete apenas com um
			//--unico componente:

			//--Componente referente ao valor
			//--fixo do contrato:
			AAdd( aCmpFrt, { cProgen, {} } )
			nPos := Len(aCmpFrt )

			cDesComp  := Posicione( 'DT3', 1, xFilial('DT3') + cCodComp, 'DT3_DESCRI' )
			AAdd( aCmpFrt[nPos][2], {	cDesComp,;			//--[01]DESCRICAO DO COMPONENTE
										aVFContr[3],;		//--[02]VALOR DO COMPONENTE (LIQUIDO)
										cCodComp,;			//--[03]CODIGO DO COMPONENTE
										'',;				//--[04]ITEM x SD2
										aVFContr[4],;		//--[05]VALOR DOS IMPOSTOS
										aVFContr[5],;		//--[06]VALOR DO COMPONENTE (BRUTO)
										DT6->DT6_CDRORI,;	//--[07]REGIAO DE ORIGEM
										DT6->DT6_CDRDES,;	//--[08]REGIAO DESTINO
										'',;				//--[09]TABELA DE FRETE
										'',;				//--[10]TIPO DA TABELA DE FRETE
										'',;				//--[11]SEQUENC. DA TABELA DE FRETE
										'',;				//--[12]**NAO USADO**
										0,;					//--[13]VALOR DE DESCONTO
										0,;					//--[14]VALOR DE ACRESCIMO
										'2'} )				//--[15]CALCULADO PELO MINIMO (1=SIM/2=NAO)

			//--Cria a linha totalizadora
			AAdd( aCmpFrt[nPos][2], {	'Total do Frete',;	//--[01]DESCRICAO DO COMPONENTE
										aVFContr[3],;		//--[02]VALOR DO COMPONENTE (LIQUIDO)
										'TF',;				//--[03]CODIGO DO COMPONENTE
										'',;				//--[04]ITEM x SD2
										aVFContr[4],;		//--[05]VALOR DOS IMPOSTOS
										aVFContr[5],;		//--[06]VALOR DO COMPONENTE (BRUTO)
										DT6->DT6_CDRORI,;	//--[07]REGIAO DE ORIGEM
										DT6->DT6_CDRDES,;	//--[08]REGIAO DESTINO
										'',;				//--[09]TABELA DE FRETE
										'',;				//--[10]TIPO DA TABELA DE FRETE
										'',;				//--[11]SEQUENC. DA TABELA DE FRETE
										'',;				//--[12]**NAO USADO**
										0,;					//--[13]VALOR DE DESCONTO
										0,;					//--[14]VALOR DE ACRESCIMO
										'2'} )				//--[15]CALCULADO PELO MINIMO (1=SIM/2=NAO)
		EndIf
	EndIf

	If Len(aCmpFrt) > 0

		//-- Tratamento: Servico de Faturamento
		If Empty(cSrv)
			aSrv := TMSA491SrvFt()
			nPos := AScan(aSrv, {|x| x[1] == cDocApoio + cTipTra})
			Iif(nPos > 0, cSrv := aSrv[nPos,2], )
		EndIf

		//-- Geracao da Nota Fiscal de Saida
		aParGerNfs := {DTC->DTC_CDRORI, DTC->DTC_CDRCAL, cCliente, cLoja, cDocTMS  ,;
					   ""             , ""             , nQtdVol , nPeso, aDadosSF2,;
					   cCposSF2       , aCmpFrt        , cF4_ISS , cTES , bFatSE1  ,;
					   cSerNF         , aVFContr       , cEspecie}
		aPontEntr  := {"TM491RISS"}
		cNumNFS    := TmsGerNfs(aParGerNfs, aPontEntr,aDoctos)

		//-- Geracao do Documento de Transporte
		If ! Empty(cNumNFS)

			TMSA491Doc(cNumNFS , cCliente, cLoja, cDocTMS  , aCmpFrt ,; 
			           nValMerc, nPesoM3 , nPeso, nPesoCobr, nQtdUnit,; 
					   nQtdVol , cTipTra , cSrv , @nRecDT6 , @nValFat,;
					   aDoctos,cCodMsg)

		EndIf
	EndIf
	RestArea(aAreaDT6)
Return cNumNFS
