#Include "Protheus.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "SPEDNFE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE nPercAlt 2.4
#DEFINE TAMMAXXML 400000 //- Tamanho maximo do XML em bytes

#DEFINE TRANSMITIDO 		'1'
#DEFINE NAO_TRANSMITIDO 	'2'
#DEFINE AUTORIZADO			'3'
#DEFINE NAO_AUTORIZADO		'4'
#DEFINE CANCELADO			'5'
#DEFINE ENCERRADO			'6'
#DEFINE EVENAOREALIZADO		'1' //Transmitido
#DEFINE EVEREALIZADO		'2' //Nao vinculado
#DEFINE EVEVINCULADO		'3' //Autorizado
#DEFINE EVENAOVINCULADO		'4' //Rejeitado

//DEFINES MONITOR EVENTO: DF-e
#DEFINE DFESELEC			1
#DEFINE DFESTATUS			2
#DEFINE DFESERNT			3
#DEFINE DFENUMNT			4
#DEFINE DFECHVMDF			5
#DEFINE DFEVLRNT			6
#DEFINE DFEPROTOC			7
#DEFINE DFECMUNDE			8
#DEFINE DFENMUNDE			9
#DEFINE DFETIPONT			10
#DEFINE DFERECNO			11
#DEFINE DFEVINCUL			12
#DEFINE DFEHISTOR			13
#DEFINE DFECLINF			14
#DEFINE DFELJCLI			15
#DEFINE DFEORDEM			16
#DEFINE DFEFILORI			17
//DEFINES MONITOR EVENTO: Tipos de Eventos
#DEFINE EVCANCELAR			"110111"
#DEFINE EVENCERRAR			"110112"
#DEFINE INCCONDEVE			"110114"
#DEFINE DFEEVENTO			"110115"
#DEFINE INFPAGEVE			"110116"
//DEFINES ORDEM DE APRESENTACAO DO EVENTOS MONITOR EVENTO:
#DEFINE EVORDAUTOR			"1"
#DEFINE EVORDTRANS			"2"
#DEFINE EVORDREJEI			"3"
#DEFINE EVORDNAOTR 			"4"

// Informações do Contratante do serviço de Transporte
#define INFCNTNOME	1
#define INFCNTCNPJ	2
#define INFCNTIDES	3
#define INFCNTNRO 	4
#define INFCNTVGLO	5

Static __cVersao			:= "3.00" //Versão Layout MDFe
Static lMDFePost			:= .F.
Static lMotori				:= .F.
Static cOpcEvent			:= ""
Static lInfPag				:= ExistFunc("MDFeInfPag")
Static aScreen 				:= {1,1}

//-----------------------------------------------------------------------
/*/{Protheus.doc} SPEDMDFE
Função principal

@author Natalia Sartori
@since 10/02/2014
@version P11
/*/
//-----------------------------------------------------------------------
Function SPEDMDFE()
	Local aArea     	:= GetArea()
	Local lRetorno  	:= .T.
	Local nVezes    	:= 0

	Private aRotina		:= MenuDef()
	Private cMark		:= GetMark()
	Private lBtnFiltro	:= .F.
	Private oMsSel 		:= Nil
	Private oGerMDFe 	:= Nil
	Private oListDocs	:= Nil
	Private oOkx		:= LoadBitmap( GetResources(), "LBOK" )
	Private oNo			:= LoadBitmap( GetResources(), "LBNO" )
	//Private aListDocs	:= {{oNo,"","",STOD("20010101"),"1",.F.,.F.}}
	Private aHeadMun	:= GetHeaderMun()
	Private aColsMun	:= GetNewLine(aHeadMun)
	Private aHeadPerc	:= GetHeaderPerc()
	Private aColsPerc	:= GetNewLine(aHeadPerc)
	Private aHeadAuto	:= GetHeaderAuto()
	Private aColsAuto	:= GetNewLine(aHeadAuto)
	Private aHeadLacre	:= GetHeaderLacre()
	Private aColsLacre	:= GetNewLine(aHeadLacre)
	Private cNumMDF		:= Space(TamSx3('CC0_NUMMDF')[1])			//Variavel que contem o numero do MDFE
	Private cSerMDF		:= Space(TamSx3('CC0_SERMDF')[1])			//Variavel que contem a Serie do MDFE
	Private cUFCarr		:= Space(TamSx3('CC0_UFINI')[1])			//Variavel que contem a UF de Carregamento
	Private cUFDesc		:= Space(TamSx3('CC0_UFFIM')[1])			//Variavel que contem a UF de Descarregamento
	Private cUFCarrAux	:= Space(TamSx3('CC0_UFINI')[1])			//Variavel Auxiliar (para controle alteracoes) que contem a UF de Carregamento
	Private cUFDescAux	:= Space(TamSx3('CC0_UFFIM')[1])			//Variavel Auxiliar (para controle alteracoes) que contem a UF de Descarregamento
	Private cVTotal		:= Space(TamSx3('CC0_VTOTAL')[1])			//Variavel que contem o valor total da carga/mercadoria
	Private cVeiculo	:= Space(TamSx3('DA3_COD')[1])				//Variavel que contem
	Private cVeiculoAux	:= Space(TamSx3('DA3_COD')[1])				//Variavel Auxiliar (para controle alteracoes) que contem o codigo do veiculo
	Private cMotorista	:= iif((CC0->(ColumnPos("CC0_MOTORI")) > 0),Space(TamSx3('CC0_MOTORI')[1]),nil)				//Variavel Auxiliar (para controle alteracoes) que contem o codigo do veiculo
	Private cCarga		:= Space(TamSx3('DAK_COD')[1])				//Variavel Auxiliar (para controle alteracoes) que contem o codigo da carga
	Private dDataIniFil	:= CtoD("  /  /  ")							//Variavel Auxiliar que contem a data de inicio para buscar as notas
	Private dDataFimFil	:= CtoD("  /  /  ")							//Variavel Auxiliar que contem a data de final para buscar as notas
	Private lLoadParam	:= .F.										//Variavel Auxiliar (para controle alteracoes) que verifica se realiza a buscar as notas
	Private nQtNFe		:= 0										//Variavel que contem a Quantidade total de NFe
	Private nVTotal		:= 0										//Variavel que contem a Valor total de notas
	Private nPBruto		:= 0										//Variavel que contem a Peso total do MDF-e
	Private nRQtNFe  	:= 0										//ArmaArmazena o valor da Quantidadepra para ser restaurado quando houver troca de filial
	Private nRVTotal 	:= 0										//ArmaArmazena o valor total para ser restaurado quando houver troca de filial
	Private nRPBruto 	:= 0										//ArmaArmazena o valor do Peso para ser restaurado quando houver troca de filial
	Private cInfCpl		:= Space(5000)								//Variavel que contem as informacoes complementares do Manifesto
	Private cInfFsc		:= Space(2000)								//Variavel que contem as informacoes fiscais do Manifesto
	Private aCmpBrow 	:= {}
	Private aMun		:= {}
	Private cIndTRB1 	:= ""
	Private cIndTRB2 	:= ""
	Private cArqTRB	 	:= ""	
	Private cEntSai		:= ""
	Private cStatFil 	:= ""
	Private cSerFil		:= ""
	Private cNumNFDe	:= ""
	Private cNumNFAt	:= ""
	Private cDtEmDe		:= ""
	Private cDtEmAt		:= ""
	Private cFModal	    := ""
	Private cNfeFil		:= "2-Não"
	Private cFilMDF 	:= SUPERGETMV("MV_FILMDFE", .F., "")
	Private lFilDMDF2	:= SF2->(ColumnPos("F2_"+cFilMDF)) > 0
	Private lFilDMDF1	:= SF1->(ColumnPos("F1_"+cFilMDF)) > 0
	Private aHeadCiot	:= GetHeaderCIOT()
	Private aColsCiot	:= GetNewLine(aHeadCiot, .T.)
	Private aHeadValPed	:= GetValPedHeader()
	Private aColsValPed	:= GetNewLine(aHeadValPed, .T.)
	Private oTempTable
	private oDlgPgt		:= Nil
	private aChvsNFe	:= {}
	private cVVTpCarga	:= ""
	private cPPCProd	:= ""
	private cPPxProd	:= ""
	private cPPCodbar	:= ""
	private cPPNCM		:= ""
	private cPPCEPCarr	:= ""
	private cPPCEPDesc	:= ""

	private cNumVoo  	:= space(9)
	private dDatVoo 	:= stod("")
	private cAerOrig	:= space(4)
	private cAerDest	:= space(4)
	private cModal   	:= STR0885
	private lModal		:= CC0->(ColumnPos("CC0_MODAL")) > 0

	private aInfSeg		:= {}
	private aInfContTr	:= {}
	private aCondutores	:= {}
	private aRebMDFe	:= {}

	if(!accessPD())
		return
	endif

	aScreen := iif(!IsBlind(),GetScreenRes(),{1,1})

	If lInfPag
		oDlgPgt := MDFeInfPag():new()
	EndIf
	lMDFePost	:= CC0->(ColumnPos("CC0_CARPST")) > 0 .And. CC0->(ColumnPos("CC0_VINCUL")) > 0 .And. !UsaColaboracao("5") //MDF-e Carrega Posterior
	lMotori		:= CC0->(ColumnPos("CC0_MOTORI")) > 0

	//Cria o arquivo de apoio TRB
	CreateTRB()

	While IIF(Valtype(lRetorno)=="U", .T., lRetorno )//Quando MdfeFiltro chamado por "outras acoes" devo verificar se a variavel lRetornoesta criada
		lBtnFiltro:= .F.
	    lRetorno := MDFInit(nVezes==0)
	    nVezes++
	    If !lBtnFiltro
	    	Exit
	    EndIf
	EndDo

	RestArea(aArea)

	//Fecha o alias
	oTempTable:Delete()
	
	freeObj(oTempTable)
	oTempTable := nil	

	fwfreeobj(oDlgPgt)
	oDlgPgt := nil
	
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} MDFInit
Função de montagem das perguntas e condição para efeturar o filtro

@author Natalia Sartori
@since 10/02/2014
@version P11
/*/
//-----------------------------------------------------------------------
Static Function MDFInit(lInit,cAlias)

Local aIndArq		:={}
Local lEntAtiva		:= .T.
Local aStatus		:={}
Private aFilBrw		:= {}
Private lUsaColab	:= UsaColaboracao("5")
Private cIdEnt		:= RetIdEnti(lUsaColab)
Private cCadastro	:= iif(lUsaColab, STR0522 + " - " + STR0720, STR0522 + " - " + STR0721 + ": " + cIdEnt + " " + STR0037 + " TSS: " + Iif(!Empty(cIdEnt),getVersaoTSS(),""))
Private oWS

//Verifica se possui o update 157 executado
SX2->(dbSetOrder(1))
If SX2->(dbSeek("CC0"))

	//Verifica se o serviço do TSS foi configurado no ambiente
	If lInit .And. !lUsaColab
		If (!CTIsReady() .Or. !CTIsReady(,2))
			If PswAdmin(,,RetCodUsr()) == 0
				SpedNFeCFG()
			Else
				HelProg(,"FISTRFNFe")
			EndIf
		EndIf
		lEntAtiva := EntAtivTss()
	EndIf

	
	If lUsaColab .Or. ( lEntAtiva .And. (!lInit .Or. CTIsReady()) )

		//Exibe a ParamBox ao Usuario
		If ParBoxMdfe(@aStatus)

			dbSelectArea('CC0')
		    //Aplica o filtro definido a partir do pergunte da parambox ao usuario
            MDFSetFilter(@aIndArq)

   			//Exibe a mBrowse ao usuario
			oMBrowse := FWMBrowse():New()
			oMBrowse:SetAlias("CC0") 
			oMBrowse:SetMenuDef("SPEDMDFE")
			oMBrowse:SetDescription(cCadastro)
			oMBrowse:AddColumn({STR0522, {|| LegMDFE() },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| MDFeLegend() },,,,.F.}) //#"MDF-e"
			If lMDFePost
				oMBrowse:AddColumn({STR0523, {|| LegEvento() },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| MDFeLegend() },,,,.F.}) //#"Evento DF-e"
			EndIf
			oMBrowse:Activate()

			//Desmonta os filtros criados pela MDFSetFilter apos usar a rotina
			RetIndex("CC0")
			dbClearFilter()
			aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})
		EndIf
	Else
		HelProg(,"FISTRFNFe")
	EndIf
Else
	Aviso("MDF-e",STR0473,{STR0114},3) //"Execute o compatibilizador NFEP11R1 (Id. NFE11R157) para o MDFe"
EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} MDFSetFilter
Realiza a Filtragem de acordo com os parametros escolhidos na ParamBox

@author Natalia Sartori
@since 10/02/2014
@version P11
/*/
//-----------------------------------------------------------------------
Static Function MDFSetFilter(aIndArq)
	Local cCondicao 	:= ""
	Local bFiltraBrw	:= {}

	//Realiza a Filtragem de acordo com os parametros escolhidos na ParamBox
	cCondicao := "CC0_FILIAL=='" + xFilial("CC0") + "'"

	If ValType(cStatFil) == "N"
		cStatFil := aStatus[cStatFil]
	EndIf

	If !Empty(cEntSai) .and. SubStr(cEntSai,1,1) == '1'  //"Tipo NF"
		cCondicao += " .and. CC0_TPNF == '" + SubStr(cEntSai,1,1) + "' "
	ElseIf !Empty(cEntSai) .and. SubStr(cEntSai,1,1) == '2'  //"Tipo NF"
		cCondicao += " .and. CC0_TPNF == '2' "
	EndIf

	If !Empty(cStatFil) .and. SubStr(cStatFil,1,1) <> '0'
		
		If SubStr(cStatFil,1,2) $ '1-|2-|3-|4-|5-|6-' 
			cCondicao += " .and. CC0_STATUS == '" + SubStr(cStatFil,1,1) + "' "
		ElseIf SubStr(cStatFil,1,2) == '7-'
			cCondicao += " .and. CC0_CARPST == '1' 
		ElseIf SubStr(cStatFil,1,2) == '8-'
			cCondicao += " .and. CC0_CARPST == '1' .and. CC0_VINCUL == '" + EVEREALIZADO + "'"  //Carrega posterior sem vinculo
		ElseIf SubStr(cStatFil,1,2) == '9-'
			cCondicao += " .and. CC0_CARPST == '1' .and. CC0_VINCUL == '" + EVENAOREALIZADO + "'" //Carrega posterior transmitido
		ElseIf SubStr(cStatFil,1,2) == '10'
			cCondicao += " .and. CC0_CARPST == '1' .and. CC0_VINCUL == '" + EVEVINCULADO + "'" //Carrega posterior autorizado
		ElseIf SubStr(cStatFil,1,2) == '11'
			cCondicao += " .and. CC0_CARPST == '1' .and. CC0_VINCUL == '" + EVENAOVINCULADO + "'" //Carrega posterior rejeitado
		EndIf
	EndIf

	If !Empty(cSerFil)
		cCondicao+=" .and. CC0_SERMDF == '" + cSerFil + "' "
	EndIF

	If !Empty(cNumNFDe)
		cCondicao+= " .and. CC0_NUMMDF >= '" + cNumNFDe + "' "
	EndIf

	If !Empty(cNumNFAt)
		cCondicao+= " .and. CC0_NUMMDF <= '" + cNumNFAt + "' "
	EndIf

	If !Empty(cDtEmDe)
		cCondicao+= " .and. dtos(CC0_DTEMIS) >= '" + dtos(cDtEmDe) + "' "
	EndIf

	If !Empty(cDtEmAt)
		cCondicao+= " .and. dtos(CC0_DTEMIS) <= '" + dtos(cDtEmAt) + "' "
	EndIf

	If lModal
		If !Empty(cFModal) .and. SubStr(cFModal,1,1) == '1'  //"1-Rodoviário"
			cCondicao += " .and. (CC0_MODAL == '1' .or. CC0_MODAL == '" + ' ' + "')  "
		ElseIf !Empty(cFModal) .and. SubStr(cFModal,1,1) == '2'  //"2-Aéreo"
			cCondicao += " .and. CC0_MODAL == '2' "
		EndIf
	EndIf

	aFilBrw		:=	{'CC0',cCondicao}
	bFiltraBrw := {|| FilBrowse("CC0",@aIndArq,@cCondicao) }
	Eval(bFiltraBrw)

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilização de menu Funcional

@author Natalia Sartori
@since 10/02/2014
@version P11
@param	aRotina		1. Nome a aparecer no cabecalho
					2. Nome da Rotina associada
					3. Reservado
					4. Tipo de Transação a ser efetuada:
          	  			1 - Pesquisa e Posiciona em um Banco de Dados
						2 - Simplesmente Mostra os Campos
						3 - Inclui registros no Bancos de Dados
						4 - Altera o registro corrente
						5 - Remove o registro corrente do Banco de Dados
					5. Nivel de acesso
					6. Habilita Menu Funcional
@return	aRotina Array com opcoes da rotina
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

	local aRotina := {}

	aAdd(aRotina,{ STR0004, "PesqBrw"	, 0, 1, 0, .F.}) //Pesquisar
	aAdd(aRotina,{ STR0476, "MDFeVisual", 0, 2, 0, .F.}) //Visualizar
	aAdd(aRotina,{ STR0474, "MDFeInclui", 0, 3, 0, .F.}) //Incluir
	aAdd(aRotina,{ STR0475, "MDFeAltera", 0, 4, 0, .F.}) //Alterar
	aAdd(aRotina,{ STR0477, "MDFeExclui", 0, 5, 0, .F.}) //Excluir
	aAdd(aRotina,{ STR0478, "MDFeManage", 0, 2, 0, .F.}) //Gereciar MDFe
	aAdd(aRotina,{ STR0513,	"MDFeDamDfe", 0, 2, 0, .F.}) //Damdfe
	if !UsaColaboracao("5")
		aAdd(aRotina,{ STR0653,	"MDFeExport"	,0,2,0,.F.}) //Exportar
		aAdd(aRotina,{ STR0005,	"SpedNFeCfg"	,0,3,0,.F.}) //Wiz.Config.
	endIf
	aAdd(aRotina,{ STR0006, "MDFeParam" , 0, 3, 0, .F.}) //Parâmetros
	aAdd(aRotina,{ STR0113,	"MdfeFiltro", 0, 3, 0, NIL}) //Filtro
	aAdd(aRotina,{ STR0299,	"MDFeLegend", 0, 2, 0, .F.}) //Legenda
	
	//Ponto de entrada para o cliente customizar os botoes apresentados
	If ExistBlock("MDFeMenu")
		aRotina := ExecBlock("MDFeMenu", .F., .F.,{aRotina})
	EndIf

Return aRotina

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeParam
Função de configuração dos parâmetros do MDF-e

@author Natalia Sartori
@since 10/02/2014
@version P11

@param
@Return
/*/
//-----------------------------------------------------------------------
Function MDFeParam()

Local aPerg1  	:= {}
Local aParam 	:= {"","","","","","",""}
Local aConfig := {}

Local aCombo1	:= {}	//Ambiente
Local aCombo2	:= {}	//Modalidade
Local aCombo3	:= {}	//Versao do leiaute do evento
Local aCombo4	:= {}   //Versao do leiaute
Local aCombo5	:= {}   //Versao do MDFe
Local aCombo6	:= {}  //Horario de verao
Local aCombo7	:= {}  //Fuso Horario

Local cError	:= ""
Local cCombo1	:= ""
Local cCombo2	:= ""
Local cCombo3	:= "3.00"
Local cCombo4	:= "3.00"
Local cCombo5	:= "3.00"
Local cCombo6	:= "2-Nao"
Local nCombo6	:= 2 //"2-Nao"
Local cCombo7	:= "2-Brasilia"
Local nCombo7	:= 2 //"2-Brasilia"
Local cParMANPar	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDMDFPAR"
Local nSLMDFE	:= 0

Local lUsaColab	:= UsaColaboracao("5")
// Ambiente
aadd(aCombo1,STR0032)	//"2-Homologacao"
aadd(aCombo1,STR0031)	//"1-Producao"

// Modalidade do MDF-e
aadd(aCombo2,STR0033) //"1-Normal"
aadd(aCombo2,"2-Contingência") //"2-Contingência"

// Versao do leiaute específico do evento
aadd(aCombo3,"1.00")
aadd(aCombo3,"3.00")

// Versao do leiaute geral do evento
aadd(aCombo4,"1.00")
aadd(aCombo4,"3.00")

// Versao do MDF-e
aadd(aCombo5,"1.00")
aadd(aCombo5,"3.00")

// Horário de verão
aadd(aCombo6,"1-Sim")
aadd(aCombo6,"2-Nao")

// Fuso Horário
aadd(aCombo7,"1-Fernando de Noronha")
aadd(aCombo7,"2-Brasilia")
aadd(aCombo7,"3-Manaus")
aadd(aCombo7,"4-Acre")

If CTIsReady(,,,lUsaColab)

	If lUsaColab

		ColParametros("MDF")
		lOk	:= .T.

	Else

		//Get de parâmetros
		aConfig := getCfgMdfe(@cError)

		If len (aConfig) >= 8 .And. Empty(cError)
			cCombo1 := aConfig[1]// oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
			cCombo2 := aConfig[2]// oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE
			cCombo3 := aConfig[3]// oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT
			cCombo4 := aConfig[4]// oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN
			cCombo5 := aConfig[5]// oWS:OWSCFGMDFERESULT:CVERSAOMDFE
			cCombo6 := aConfig[6]// oWS:OWSCFGMDFERESULT:CHORAVERAOCCE
			nCombo6 := val(substr(Alltrim(aConfig[6]),1,1))
			cCombo7 := aConfig[7]// oWS:OWSCFGMDFERESULT:CHORARIOCCE
			nCombo7 := val(substr(Alltrim(aConfig[7]),1,1))
			nSLMDFE := aConfig[8]// oWS:OWSCFGMDFERESULT:NSEQLOTEMDFE
		EndIf

		AADD(aPerg1,{2,STR0035,cCombo1,aCombo1,120,".T.",.T.,".T."}) 			//"Ambiente"
		AADD(aPerg1,{2,STR0036,cCombo2,aCombo2,120,".T.",.T.,".T."}) 			//"Modalidade
		AADD(aPerg1,{2,STR0351,cCombo3,aCombo3,120,".T.",.T.,".T."})	 		//"Versao do leiaute do evento"
		AADD(aPerg1,{2,STR0350,cCombo4,aCombo4,120,".T.",.T.,".T."}) 			//"Versao do leiaute"
		AADD(aPerg1,{2,"Versão MDFe",cCombo5,aCombo5,120,".T.",.T.,".T."})		//"Versao do MDFe"

		if nCombo6 > 0 .And. nCombo7 > 0
			AADD(aPerg1,{2,STR0369,cCombo6,aCombo6,120,".T.",.T.,".T."})//"Horario de verao 1 - Sim ou 2 - Não
			AADD(aPerg1,{2,STR0370,cCombo7,aCombo7,120,".T.",.T.,".T."})//UTC -> "TZD - Time Zone Designator /Designador de Fuso Horário"
		EndIf

		aParam := {cCombo1,cCombo2,cCombo3,cCombo4,cCombo5,cCombo6,cCombo7}

		If ParamBox(aPerg1,"MDF-e",aParam,,,,,,,cParMANPar,.T.,.F.)

			//Set de parâmetros
			if nCombo6 > 0 .And. nCombo7 > 0
				getCfgMdfe(@cError, cIdEnt, aParam[1], aParam[2], aParam[3], aParam[4], aParam[5], aParam[6], aParam[7], nSLMDFE )
			Else
				getCfgMdfe(@cError, cIdEnt, aParam[1], aParam[2], aParam[3], aParam[4], aParam[5], , , nSLMDFE )
			EndIf

			lOk := Iif (Empty(cError),.T.,.F.)
			If !lOk .And. "004 - Versao do MDF-e" $ cError
				cError += CRLF + " " + STR0745 //Atualize a versão do TSS
			EndIf

			If lOk
				Aviso("MDF-e",STR0346,{STR0114},3)	//"Configuração efetuada com sucesso"
			Else
				Aviso("MDF-e",STR0347  + CRLF + cError ,{STR0114/*OK*/},3)	//"Houve um erro durante a configuracão"
			EndIf
		EndIf
	EndIf
Else
	Aviso("MDF-e",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIF

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} LegMDFE()
Legenda da MarkBrow MDFe

@author Fernando Bastos
@since 08/08/2019
@version 12.1.28
/*/
//-----------------------------------------------------------------------
Static Function LegMDFE()

Local cLegenda := ""

Do Case
	Case CC0->CC0_STATUS=='1'
		cLegenda := "BR_AZUL"		//1-Transmitidos
	Case CC0->CC0_STATUS=='2'
		cLegenda := "DISABLE"		//2-Não Transmitidos
	Case CC0->CC0_STATUS=='3'
		cLegenda := "BR_VERDE"		//3-Autorizados
	Case CC0->CC0_STATUS=='4'
		cLegenda := "BR_PRETO"		//4-Não Autorizados
	Case CC0->CC0_STATUS=='5'
		cLegenda := "BR_LARANJA"	//5-Cancelados
	Case CC0->CC0_STATUS=='6'
		cLegenda := "BR_AMARELO"	//6-Encerrados
EndCase

Return cLegenda

//-----------------------------------------------------------------------
/*/{Protheus.doc} MDFeLegend()
Legenda da MarkBrow

@author Natalia Sartori
@since 10/02/2014
@version P11
/*/
//-----------------------------------------------------------------------
Function MDFeLegend()
Local aLegenda	:= {}

AADD(aLegenda, {""				, " " + STR0522})	//#"MDF-e"
AADD(aLegenda, {"BR_AZUL"		,STR0466})			//1-Transmitidos
AADD(aLegenda, {"DISABLE"		,STR0467})			//2-Não Transmitidos
AADD(aLegenda, {"BR_VERDE"		,STR0468})			//3-Autorizados
AADD(aLegenda, {"BR_PRETO"		,STR0469})			//4-Não Autorizados
AADD(aLegenda, {"BR_LARANJA"	,STR0470})			//5-Cancelados
AADD(aLegenda, {"BR_AMARELO"	,STR0471})			//6-Encerrados

If lMDFePost
	AADD(aLegenda, {""				,""})
	AADD(aLegenda, {""				," " + STR0523 })	//#"Evento DFe"
	AADD(aLegenda, {"BR_VERDE"		,"1-" + STR0520 })	//#"Carrega Posterior Autorizado"
	AADD(aLegenda, {"BR_AZUL"		,"2-" + STR0519 })	//#"Carrega Posterior Transmitido"
	AADD(aLegenda, {"BR_PRETO"		,"3-" + STR0518 })	//#"Carrega Posterior Sem Vinculo"
	AADD(aLegenda, {"DISABLE"		,"4-" + STR0521 })	//#"Carrega Posterior Rejeitado"
EndIf

BrwLegenda("Legenda",STR0117,aLegenda)

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeVisual
Montagem da regra da legenda dos eventos 

@author Fernando Bastos
@since 08/08/2019
@version 12.1.28
@Return
/*/
//-----------------------------------------------------------------------
Static Function LegEvento()

Local cLegenda := ""

Do Case
	Case CC0_CARPST == '1' .And. CC0_VINCUL $ " /" + EVEREALIZADO  // Carrega Posterior sem Vinculado 
		cLegenda := "BR_PRETO"

	Case CC0_CARPST == '1' .And. CC0_VINCUL == EVENAOREALIZADO // Carrega Posterior transmitido 
		cLegenda := "BR_AZUL"

	Case CC0_CARPST == '1' .And. CC0_VINCUL == EVEVINCULADO // Carrega Posterior autorizado 
		cLegenda := "BR_VERDE"

	Case CC0_CARPST == '1' .And. CC0_VINCUL == EVENAOVINCULADO // Carrega Posterior rejeitado 
		cLegenda := "DISABLE"
EndCase

Return cLegenda

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeVisual
Montagem da Dialog de visualização de um MDFe ja criado

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return
/*/
//-----------------------------------------------------------------------
Function MDFeVisual(cAlias, nReg, nOpc)
	//Antes de chamar a rotina de pintura de tela, define o conteudo das variaveis private
	LoadVarsByCC0(nOpc)
	MDFeShowDlg(nOpc)
	ResetVars()
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeInclui
Montagem da Dialog de inclusão do MDFe

@author Natalia Sartori
@since 10/02/2014
@version P11

@param
@Return
/*/
//-----------------------------------------------------------------------
Function MDFeInclui(cAlias, nReg, nOpc)
  	//Antes de chamar a rotina de pintura de tela, define o conteudo das variaveis private
	ResetVars()
	//Chama a funcao que faz a pintura de tela, a partir das variaveis vazias
	MDFeShowDlg(nOpc)
	//Antes de chamar a rotina de pintura de tela, define o conteudo das variaveis private
	ResetVars()
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeAltera
Montagem da Dialog de alteração do MDFe

@author Natalia Sartori
@since 10/02/2014
@version P11

@param
@Return
/*/
//-----------------------------------------------------------------------
Function MDFeAltera(cAlias, nReg, nOpc)
	If CC0->CC0_STATUS == NAO_TRANSMITIDO .or. CC0->CC0_STATUS == NAO_AUTORIZADO
		//Antes de chamar a rotina de pintura de tela, define o conteudo das variaveis private
		LoadVarsByCC0(nOpc)
		//Chama a funcao que faz a pintura de tela, a partir das variaveis vazias
		MDFeShowDlg(nOpc)
		//Antes de chamar a rotina de pintura de tela, define o conteudo das variaveis private
		ResetVars()
	Else
		MsgInfo(STR0755) //Opcao nao disponivel de acordo com o status do documento.
	EndIf
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeExclui
Montagem da Dialog de exclusão do MDFe

@author Natalia Sartori
@since 10/02/2014
@version P11

@param
@Return
/*/
//-----------------------------------------------------------------------
Function MDFeExclui(cAlias, nReg, nOpc)

	If CC0->CC0_STATUS == NAO_TRANSMITIDO .or. CC0->CC0_STATUS == NAO_AUTORIZADO
		//Antes de chamar a rotina de pintura de tela, define o conteudo das variaveis private
		LoadVarsByCC0(nOpc)
		//Chama a funcao que faz a pintura de tela, a partir das variaveis vazias
		MDFeShowDlg(nOpc)
	  	//Antes de chamar a rotina de pintura de tela, define o conteudo das variaveis private
		ResetVars()
	Else
		MsgInfo(STR0755) //Opcao nao disponivel de acordo com o status do documento.
		
	Endif
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeDamDfe
Realiza a chamada da função responsavel pela Pintura do DamDfe

@author Natalia Sartori
@since 10/02/2014
@version P11

@param
@Return
/*/
//-----------------------------------------------------------------------
Function MDFeDamDfe(cAlias, nReg, nOpc)

	SpedDAMDFE()
	//Recarrega a lista
	if oListDocs <> Nil
		ReloadListDocs()
	endif
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeShowDlg
Montagem da Dialog de inclusão do MDFe

@author Natalia Sartori
@since 10/02/2014
@version P11

@param
@Return
/*/
//-----------------------------------------------------------------------
Function MDFeShowDlg(nOpc)
	Local nTopGD  	 	:= 0
	Local nLeftGD 	 	:= 0
	Local nDownGD 	 	:= 0
	Local nRightGD	 	:= 0
	Local lIncAltDel 	:= (nOpc == 3 .or. nOpc == 4)
	Local nIncAltDel 	:= GD_INSERT+GD_UPDATE+GD_DELETE
	Local cOperation 	:= ""
	Local lMV_VEICDCL	:= GetNewPar("MV_VEICDCL",.T.)	//Parametro que verifica se utiliza a tabela LBW do template de combustiveis
	Local cCombo1		:= ""
	Local lReset  		:= .F.
	Local aCombo1 		:= {}
	Local aCombo2 		:= {}
	Local aCombo3 		:= {}
	Local aObjects		:= {}
	Local aInfo			:= {}
	Local aSizeAut
	Local aPosObj 		:= {}
	local aDados		:= {}
	local lGrava		:= .F.
	local oTplRet		:= nil

	Private oTela 		//Objeto tipo "Dialog" - Tela Principal
	Private cCodMun 	:= Space(TamSx3("CC2_CODMUN")[1])
	Private cNomMun 	:= Space(TamSx3("CC2_MUN")[1])
	Private cEstMun 	:= Space(TamSx3("CC2_EST")[1])
	Private oGetQtNFe
	Private oGetPBruto
	Private oGetVTot
	Private oGetDMun
	Private oGetDPerc
	Private oGetDLacre
	Private oGetDAut
	Private oGetDCiot
	private oGetDValPed

	private oGetSeg		:= nil
	private oGetAverb	:= nil
	private aHeadSeg	:= {}
	private aColsSeg	:= {}
	private aHeadAverb	:= {}
	private aColsAverb	:= {}

	private oGetInfCnt	:= nil
	private oGetCondut	:= nil
	private oGetReb		:= nil
	private aHeadInfCt	:= {}
	private aHeadCond	:= {}
	private aHeadReb	:= {}
	private aColsInfCt	:= {}
	private aColsCondu	:= {}
	private aColsReb	:= {}
	Default nOpc 		:= 3

	//Todas Filiais
	aadd(aCombo1,"1-Sim")
	aadd(aCombo1,"2-Não")
	cCombo1 := cNfeFil

	//Posterior
	aadd (aCombo2,STR0524) //#"1-Sim"
	aadd (aCombo2,STR0525) //#"2-Não"
	Private cPoster:= aCombo2[2]

	//Tipo de Modal
	aadd(aCombo3,STR0885)
	aadd(aCombo3,STR0886)

	Do Case
		Case nOpc == 2
			cOperation := "Visualizar"
		Case nOpc == 3
			cOperation := "Incluir"
		Case nOpc == 4
			cOperation := "Alterar"
		Case nOpc == 5
			cOperation := "Excluir"
	EndCase

	aSizeAut := MsAdvSize()

	aObjects := {}
	AAdd( aObjects, { 50, 40, .T., .T., .T. } )
	AAdd( aObjects, { 60, 70, .T., .T. ,.T.} )

	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, , .T. )

	//Monta a dialog Principal
	oTela:= MSDIALOG():Create()
	oTela:cName     := "oTela"
	oTela:cCaption  := STR0841 + " - " + cOperation
	oTela:nLeft     := aSizeAut[7]
	oTela:nTop      := aSizeAut[1]
	oTela:nWidth    := aSizeAut[5]
	oTela:nHeight   := aSizeAut[6]+25
	oTela:lShowHint := .F.
	oTela:lCentered := .T.
	oTela:bInit 	:= {|| EnchoiceBar(oTela, {||( Iif(MDFeSetRec(nOpc, @aDados), lGrava := oTela:End(),.F.) )} , {|| oTela:End() } ,, MDFeBut(nOpc),,,.F.,.F.,.F.,,.F. ) }

	//Monta os Paineis (TPanel)
	oPanel1:= tPanel():Create(oTela,MDFeResol(0.1,.T.),MDFeResol(0.1,.F.),,,,,CLR_YELLOW,,MDFeResol(49.3,.T.),MDFeResol(10,.F.))
	oPanel2:= tPanel():Create(oTela,MDFeResol(7.8,.T.),MDFeResol(0.1,.F.),,,,,CLR_YELLOW,,MDFeResol(49.3,.T.),MDFeResol(26.8,.F.))

	//Monta as guias (Folders) da rotina
	aTFolder := {}
	aAdd(aTFolder,STR0838) //1 "Documentos"
	aAdd(aTFolder,STR0839) //2 "Carregamento/Percurso"
	aAdd(aTFolder,"CIOT") //3 //"CIOT"
	If lInfPag
		aAdd(aTFolder,STR0840) //4 //"Informações de Pagamentos"
	EndIf
	aAdd(aTFolder,STR0835) //5 'Vale-Pedágio'
	aAdd(aTFolder,STR0836) //6 "Produto Predominante"
	aAdd(aTFolder,STR0907) //7 "Seguro"
	aAdd(aTFolder,STR0915) //8 "Contratantes do serviço de transporte"
	aAdd(aTFolder,STR0950) //9 "Condutores Adicionais"
	aAdd(aTFolder,STR0963) //10 "Reboques"
	If lModal
		aAdd(aTFolder,STR0888) // Len() - 1 "Modal Aereo"
	EndIf
	aAdd(aTFolder,STR0837) //Len() //"Outros"
	oTFolder := TFolder():New( MDFeResol(0.2,.T.),MDFeResol(0.5,.F.),aTFolder,,oPanel2,,,,.T.,,MDFeResol(46.5,.T.),MDFeResol(23.9,.F.) )

	//Monta o Box1 - Cabeçalho
	oBox1:= TGROUP():Create(oPanel1)
	oBox1:cName 	   := "oBox1"
	oBox1:cCaption     := STR0842 //"Informações do Manifesto"
	oBox1:nLeft 	   := MDFeResol(0.5,.T.)
	oBox1:nTop  	   := MDFeResol(8,.F.)
	oBox1:nWidth 	   := MDFeResol(93.5,.T.)
	oBox1:nHeight 	   := MDFeResol(11.8,.F.)
	oBox1:lShowHint    := .F.
	oBox1:lReadOnly    := .F.
	oBox1:Align        := 0
	oBox1:lVisibleControl := .T.

	//Monta a legenda 'Numero'
	oSayNum:= TSAY():Create(oPanel1)
	oSayNum:cName			:= "oSayNum"
	oSayNum:cCaption 		:= STR0843 //"Número:"
	oSayNum:nLeft 			:= MDFeResol(4,.T.)
	oSayNum:nTop 			:= MDFeResol(10.3,.F.)
	oSayNum:nWidth 	   		:= MDFeResol(10,.T.)
	oSayNum:nHeight 		:= MDFeResol(2.5,.F.)
	oSayNum:lShowHint 		:= .F.
	oSayNum:lReadOnly 		:= .F.
	oSayNum:Align 			:= 0
	oSayNum:lVisibleControl	:= .T.
	oSayNum:lWordWrap 	  	:= .F.
	oSayNum:lTransparent 	:= .F.

	//Monta a Get - Numero
	oGetNum:= TGET():Create(oPanel1)
	oGetNum:cName 	 		:= "oGetNum"
	oGetNum:nLeft 	 		:= MDFeResol(8,.T.)
	oGetNum:nTop 	 		:= MDFeResol(10,.F.)
	oGetNum:nWidth 	 		:= MDFeResol(9,.T.)
	oGetNum:nHeight 	 	:= MDFeResol(nPercAlt,.F.)
	oGetNum:lShowHint 		:= .F.
	oGetNum:lReadOnly 		:= .F.
	oGetNum:Align 	 		:= 0
	oGetNum:lVisibleControl := .T.
	oGetNum:lPassword 		:= .F.
	oGetNum:lHasButton		:= .F.
	oGetNum:cVariable 		:= "cNumMDF"
	oGetNum:bSetGet 	 	:= {|u| If(PCount()>0,cNumMDF:=u,cNumMDF)}
	oGetNum:Picture   		:= PesqPict("CC0","CC0_NUMMDF")
	oGetNum:bWhen     		:= {|| .F.}
	oGetNum:bChange			:= {|| .T.}
	oGetNum:bValid			:= {|| .T.}

	//Monta a legenda 'Serie'
	oSaySerie:= TSAY():Create(oPanel1)
	oSaySerie:cName				:= "oSaySerie"
	oSaySerie:cCaption 			:= STR0249 //"Série"
	oSaySerie:nLeft 			:= MDFeResol(20,.T.)
	oSaySerie:nTop 		   		:= MDFeResol(10.3,.F.)
	oSaySerie:nWidth 	   		:= MDFeResol(11,.T.)
	oSaySerie:nHeight 			:= MDFeResol(2.5,.F.)
	oSaySerie:lShowHint 		:= .F.
	oSaySerie:lReadOnly 		:= .F.
	oSaySerie:Align 			:= 0
	oSaySerie:lVisibleControl	:= .T.
	oSaySerie:lWordWrap 	  	:= .F.
	oSaySerie:lTransparent 		:= .F.

	//Monta a Get - 'Serie'
	oGetSerie:= TGET():Create(oPanel1)
	oGetSerie:cName 	 		:= "oGetSerie"
	oGetSerie:nLeft 	 		:= MDFeResol(23,.T.)
	oGetSerie:nTop 	 	 		:= MDFeResol(10,.F.)
	oGetSerie:nWidth 	 		:= MDFeResol(4,.T.)
	oGetSerie:nHeight 	 		:= MDFeResol(nPercAlt,.F.)
	oGetSerie:lShowHint 		:= .F.
	oGetSerie:lReadOnly 		:= .F.
	oGetSerie:Align 	 		:= 0
	oGetSerie:lVisibleControl 	:= .T.
	oGetSerie:lPassword 		:= .F.
	oGetSerie:lHasButton		:= .F.
	oGetSerie:cVariable 		:= "cSerMDF"
	oGetSerie:bSetGet 	 		:= {|u| If(PCount()>0,cSerMDF:=u,cSerMDF)}
	oGetSerie:Picture   		:= PesqPict("CC0","CC0_SERMDF")
	oGetSerie:bWhen     		:= {|| .F.}
	oGetSerie:bChange			:= {|| .T. }
	oGetSerie:bValid			:= {|| .T.}

	//Monta a legenda 'Uf.Carreg.'
	oSayUFCarr:= TSAY():Create(oPanel1)
	oSayUFCarr:cName			:= "oSayUFCarr"
	oSayUFCarr:cCaption 		:= STR0546 //"UF Carregamento:"
	oSayUFCarr:nLeft 			:= MDFeResol(30,.T.)
	oSayUFCarr:nTop 			:= MDFeResol(10.3,.F.)
	oSayUFCarr:nWidth 	   		:= MDFeResol(10,.T.)
	oSayUFCarr:nHeight 			:= MDFeResol(2.5,.F.)
	oSayUFCarr:lShowHint 		:= .F.
	oSayUFCarr:lReadOnly 		:= .F.
	oSayUFCarr:Align 			:= 0
	oSayUFCarr:lVisibleControl	:= .T.
	oSayUFCarr:lWordWrap 	  	:= .F.
	oSayUFCarr:lTransparent 	:= .F.
	oSayUFCarr:nClrText 		:= CLR_HBLUE

	//Monta a Get - 'Uf.Carreg.'       ³
	oGetUfCarr:= TGET():Create(oPanel1)
	oGetUfCarr:cName 	 		:= "oGetUfCarr"
	oGetUfCarr:nLeft 	 		:= MDFeResol(38.5,.T.)
	oGetUfCarr:nTop 	 		:= MDFeResol(10,.F.)
	oGetUfCarr:nWidth 	 		:= MDFeResol(5,.T.)
	oGetUfCarr:nHeight 	 		:= MDFeResol(nPercAlt,.F.)
	oGetUfCarr:lShowHint 		:= .F.
	oGetUfCarr:lReadOnly 		:= .F.
	oGetUfCarr:Align 	 		:= 0
	oGetUfCarr:lVisibleControl 	:= .T.
	oGetUfCarr:lPassword 		:= .F.
	oGetUfCarr:lHasButton		:= .F.
	oGetUfCarr:cF3				:= "12"
	oGetUfCarr:cVariable 		:= "cUFCarr"
	oGetUfCarr:bSetGet 	 		:= {|u| If(PCount()>0,cUFCarr:=u,cUFCarr)}
	oGetUfCarr:Picture   		:= PesqPict("CC0","CC0_UFINI")
	oGetUfCarr:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)}
	oGetUfCarr:bChange			:= {|| .T.}
	oGetUfCarr:bValid			:= {|| !Empty(cUFCarr) .and. ExistCpo("SX5",'12'+cUFCarr,1) .and. ValListCar(nOpc) .And. ValidPost(nOpc)}

	//Monta a legenda 'Uf.Descarreg.'    ³
	oSayUFDesc:= TSAY():Create(oPanel1)
	oSayUFDesc:cName			:= "oSayUFDesc"
	oSayUFDesc:cCaption 		:= STR0547 //"UF Descarregamento:"
	oSayUFDesc:nLeft 			:= MDFeResol(47,.T.)
	oSayUFDesc:nTop 			:= MDFeResol(10.3,.F.)
	oSayUFDesc:nWidth 	   		:= MDFeResol(10,.T.)
	oSayUFDesc:nHeight 			:= MDFeResol(2.7,.F.)
	oSayUFDesc:lShowHint 		:= .F.
	oSayUFDesc:lReadOnly 		:= .F.
	oSayUFDesc:Align 			:= 0
	oSayUFDesc:lVisibleControl	:= .T.
	oSayUFDesc:lWordWrap 	  	:= .F.
	oSayUFDesc:lTransparent 	:= .F.
	oSayUFDesc:nClrText 		:= CLR_HBLUE

	//Monta a Get - 'Uf.Descarreg.'    ³
	oGetUfDesc:= TGET():Create(oPanel1)
	oGetUfDesc:cName 	 		:= "oGetUfDesc"
	oGetUfDesc:nLeft 	 		:= MDFeResol(57,.T.)
	oGetUfDesc:nTop 	 		:= MDFeResol(10,.F.)
	oGetUfDesc:nWidth 	 		:= MDFeResol(5,.T.)
	oGetUfDesc:nHeight 	 		:= MDFeResol(nPercAlt,.F.)
	oGetUfDesc:cF3				:= "12"
	oGetUfDesc:lShowHint 		:= .F.
	oGetUfDesc:lReadOnly 		:= .F.
	oGetUfDesc:Align 	 		:= 0
	oGetUfDesc:lVisibleControl 	:= .T.
	oGetUfDesc:lPassword 		:= .F.
	oGetUfDesc:lHasButton		:= .F.
	oGetUfDesc:cVariable 		:= "cUFDesc"
	oGetUfDesc:bSetGet 	 		:= {|u| If(PCount()>0,cUFDesc:=u,cUFDesc)}
	oGetUfDesc:Picture   		:= PesqPict("CC0","CC0_UFFIM")
	oGetUfDesc:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)}
	oGetUfDesc:bChange			:= {|| .t. }
	oGetUfDesc:bValid			:= {|| !Empty(cUFDesc) .and. ExistCpo("SX5",'12'+cUFDesc,1) .and. ValListDesc(nOpc) .And. ValidPost(nOpc)}

	//Monta a legenda 'Veiculo'        ³
	oSayVeic:= TSAY():Create(oPanel1)
	oSayVeic:cName				:= "oSayVeic"
	oSayVeic:cCaption 			:= STR0954 //"Veículo:"
	oSayVeic:nLeft 				:= MDFeResol(65,.T.)
	oSayVeic:nTop 				:= MDFeResol(10.3,.F.)
	oSayVeic:nWidth 	   		:= MDFeResol(10,.T.)
	oSayVeic:nHeight 			:= MDFeResol(2.5,.F.)
	oSayVeic:lShowHint 			:= .F.
	oSayVeic:lReadOnly 			:= .F.
	oSayVeic:Align 				:= 0
	oSayVeic:lVisibleControl	:= .T.
	oSayVeic:lWordWrap 	  		:= .F.
	oSayVeic:lTransparent 		:= .F.
	oSayVeic:nClrText 			:= CLR_HBLUE

	//Monta a Get - 'Veiculo'
	oGetVeiculo:= TGET():Create(oPanel1)
	oGetVeiculo:cName 	 		:= "oGetVeiculo"
	oGetVeiculo:nLeft 	 		:= MDFeResol(69,.T.)
	oGetVeiculo:nTop 	 		:= MDFeResol(10,.F.)
	oGetVeiculo:nWidth 	 		:= MDFeResol(10,.T.)
	oGetVeiculo:nHeight 	 	:= MDFeResol(nPercAlt,.F.)
	oGetVeiculo:lShowHint 		:= .F.
	oGetVeiculo:lReadOnly 		:= .F.
	oGetVeiculo:Align 	 		:= 0
	oGetVeiculo:lVisibleControl := .T.
	oGetVeiculo:lPassword 		:= .F.
	oGetVeiculo:lHasButton		:= .F.
	oGetVeiculo:cVariable 		:= "cVeiculo"
	oGetVeiculo:bSetGet 	 	:= {|u| If(PCount()>0,cVeiculo:=u,cVeiculo)}
	oGetVeiculo:Picture   		:= PesqPict("DA3","DA3_COD")
	oGetVeiculo:bWhen     		:= {|| (nOpc == 3 )} //So altera o Veiculo se For inclusao!!!! Alteracao eh proibido
	If lMV_VEICDCL .and. existTemplate("TDCVG001")
	 	oTplRet := execTemplate("TDCVG001",.F.,.F.,{oGetVeiculo})
		If valType(oTplRet) == "O"
			oGetVeiculo := oTplRet
		EndIf
	Else
		oGetVeiculo:cF3 		:= "DA3"
		oGetVeiculo:bValid		:= {|| Iif(Empty(cVeiculo),.T., iif(SubStr(cPoster,1,1) =="2",ParamNfs(nOpc) .and. ShowNFs(nOpc),VldVeiculo(cVeiculo))) .and. SetMotori(cVeiculo)} //2-Não
	EndIf

	//Monta a legenda 'Valor Total'
	oSayVTot:= TSAY():Create(oPanel1)
	oSayVTot:cName			:= "oSayVTot"
	oSayVTot:cCaption 		:= STR0952 //"Valor Total: "
	oSayVTot:nLeft 			:= MDFeResol(4,.T.)
	oSayVTot:nTop 			:= MDFeResol(15.3,.F.)//12
	oSayVTot:nWidth 	   	:= MDFeResol(10,.T.)//10
	oSayVTot:nHeight 		:= MDFeResol(2.5,.F.)
	oSayVTot:lShowHint 		:= .F.
	oSayVTot:lReadOnly 		:= .F.
	oSayVTot:Align 			:= 0
	oSayVTot:lVisibleControl:= .T.
	oSayVTot:lWordWrap 	  	:= .F.
	oSayVTot:lTransparent 	:= .F.

	//Monta a legenda 'Todas Filiais  '
	oSayNfeFil:= TSAY():Create(oPanel1)
	oSayNfeFil:cName			:= "oSayNfeFil"
	oSayNfeFil:cCaption 		:= STR0953 //"Todas Filiais:"
	oSayNfeFil:nLeft 			:= MDFeResol(80,.T.)
	oSayNfeFil:nTop 			:= MDFeResol(10.3,.F.)
	oSayNfeFil:nWidth 	   		:= MDFeResol(10,.T.)
	oSayNfeFil:nHeight 			:= MDFeResol(2.7,.F.)
	oSayNfeFil:lShowHint 		:= .F.
	oSayNfeFil:lReadOnly 		:= .F.
	oSayNfeFil:Align 			:=  0
	oSayNfeFil:lVisibleControl	:= .T.
	oSayNfeFil:lWordWrap 	  	:= .F.
	oSayNfeFil:lTransparent 	:= .F.
	oSayNfeFil:nClrText 		:= CLR_HBLUE

	//Monta a Get - 'Todas Filiais'
	oGetNfeFil:= TGET():Create(oPanel1)
	oGetNfeFil:cName 	 		:= "oGetNfeFil"
	oGetNfeFil:nLeft 	 		:= MDFeResol(85,.T.)
	oGetNfeFil:nTop 	 		:= MDFeResol(10,.F.)
	oGetNfeFil:nWidth 	 		:= MDFeResol(5,.T.)
	oGetNfeFil:nHeight 	 		:= MDFeResol(nPercAlt,.F.)
	oGetNfeFil:lShowHint 		:= .F.
	oGetNfeFil:lReadOnly 		:= .F.
	oGetNfeFil:Align 	 		:= 	0
	oGetNfeFil:lVisibleControl 	:= .F.
	oGetNfeFil:lPassword 		:= .F.
	oGetNfeFil:lHasButton		:= .F.
	oGetNfeFil:cVariable 		:= "cNfeFil"
	oGetNfeFil:bWhen     		:= {|| (nOpc == 3 )}
	oCombo:= TComboBox():New(MDFeResol(5,.F.),MDFeResol(43,.T.),{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aCombo1,50,20,oPanel1,,{||RestFilial(),cNfeFil:=cCombo1,lReset:=.T.,ShowNFs(nOpc,.F.)},,,,.T.,,,,,,,,,'cCombo1')
	oGetNfeFil:bSetGet 	 		:= {||cNfeFil}

	//Monta a legenda 'Valor Total'
	oSayVTot:= TSAY():Create(oPanel1)
	oSayVTot:cName			:= "oSayVTot"
	oSayVTot:cCaption 		:= STR0952 //"Valor Total: "
	oSayVTot:nLeft 			:= MDFeResol(4,.T.)
	oSayVTot:nTop 			:= MDFeResol(15.3,.F.)//12
	oSayVTot:nWidth 	   	:= MDFeResol(10,.T.)//10
	oSayVTot:nHeight 		:= MDFeResol(2.5,.F.)
	oSayVTot:lShowHint 		:= .F.
	oSayVTot:lReadOnly 		:= .F.
	oSayVTot:Align 			:= 0
	oSayVTot:lVisibleControl:= .T.
	oSayVTot:lWordWrap 	  	:= .F.
	oSayVTot:lTransparent 	:= .F.

	//Monta a Get - Valor Total
	oGetVTot:= TGET():Create(oPanel1)
	oGetVTot:cName 	 		:= "oGetVTot"
	oGetVTot:nLeft 	 		:= MDFeResol(9,.T.)
	oGetVTot:nTop 	 		:= MDFeResol(15,.F.)
	oGetVTot:nWidth 	 	:= MDFeResol(8,.T.)
	oGetVTot:nHeight 	 	:= MDFeResol(nPercAlt,.F.)
	oGetVTot:lShowHint 		:= .F.
	oGetVTot:lReadOnly 		:= .F.
	oGetVTot:Align 	 		:= 0
	oGetVTot:lVisibleControl:= .T.
	oGetVTot:lPassword 		:= .F.
	oGetVTot:lHasButton		:= .F.
	oGetVTot:cVariable 		:= "nVTotal"
	oGetVTot:bSetGet 	 	:= {|u| If(PCount()>0,nVTotal:=u,nVTotal)}
	oGetVTot:Picture   		:= PesqPict("SF2","F2_VALBRUT")
	oGetVTot:bWhen     		:= {|| .F.}
	oGetVTot:bChange		:= {|| .T. }
	oGetVTot:bValid			:= {|| .T.}

	//Monta a legenda 'Peso Bruto'
	oSayPBruto:= TSAY():Create(oPanel1)
	oSayPBruto:cName			:= "oSayPBruto"
	oSayPBruto:cCaption 		:= "Peso Bruto:"
	oSayPBruto:nLeft 			:= MDFeResol(20,.T.)
	oSayPBruto:nTop 			:= MDFeResol(15.3,.F.)
	oSayPBruto:nWidth 	   		:= MDFeResol(10,.T.)
	oSayPBruto:nHeight 			:= MDFeResol(2.5,.F.)
	oSayPBruto:lShowHint 		:= .F.
	oSayPBruto:lReadOnly 		:= .F.
	oSayPBruto:Align 			:= 0
	oSayPBruto:lVisibleControl	:= .T.
	oSayPBruto:lWordWrap 	  	:= .F.
	oSayPBruto:lTransparent 	:= .F.

	//Monta a Get - Peso Bruto
	oGetPBruto:= TGET():Create(oPanel1)
	oGetPBruto:cName 	 		:= "oGetPBruto"
	oGetPBruto:nLeft 	 		:= MDFeResol(26,.T.)
	oGetPBruto:nTop 	 		:= MDFeResol(15,.F.)
	oGetPBruto:nWidth 	 		:= MDFeResol(7,.T.)
	oGetPBruto:nHeight 	 		:= MDFeResol(nPercAlt,.F.)
	oGetPBruto:lShowHint 		:= .F.
	oGetPBruto:lReadOnly 		:= .F.
	oGetPBruto:Align 	 		:= 0
	oGetPBruto:lVisibleControl 	:= .T.
	oGetPBruto:lPassword 		:= .F.
	oGetPBruto:lHasButton		:= .F.
	oGetPBruto:cVariable 		:= "nPBruto"
	oGetPBruto:bSetGet 	 		:= {|u| If(PCount()>0,nPBruto:=u,nPBruto)}
	oGetPBruto:Picture   		:= "@E 9999999.9999"
	oGetPBruto:bWhen     		:= {|| .F.}
	oGetPBruto:bChange			:= {|| .T. }
	oGetPBruto:bValid			:= {|| .T.}

	//Monta a legenda 'Quant. NFe'
	oSayQtNFe:= TSAY():Create(oPanel1)
	oSayQtNFe:cName			:= "oSayQtNFe"
	oSayQtNFe:cCaption 		:= "Quant. NFe"
	oSayQtNFe:nLeft 		:= MDFeResol(35,.T.)
	oSayQtNFe:nTop 			:= MDFeResol(15.3,.F.)
	oSayQtNFe:nWidth 	   	:= MDFeResol(10,.T.)
	oSayQtNFe:nHeight 		:= MDFeResol(2.5,.F.)
	oSayQtNFe:lShowHint 	:= .F.
	oSayQtNFe:lReadOnly 	:= .F.
	oSayQtNFe:Align 		:= 0
	oSayQtNFe:lVisibleControl:= .T.
	oSayQtNFe:lWordWrap 	:= .F.
	oSayQtNFe:lTransparent 	:= .F.

	//Monta a Get - Quant. NFe
	oGetQtNFe:= TGET():Create(oPanel1)
	oGetQtNFe:cName 	 		:= "oGetQtNFe"
	oGetQtNFe:nLeft 	 		:= MDFeResol(40.6,.T.)
	oGetQtNFe:nTop 	 			:= MDFeResol(15,.F.)
	oGetQtNFe:nWidth 	 		:= MDFeResol(6,.T.)
	oGetQtNFe:nHeight 	 		:= MDFeResol(nPercAlt,.F.)
	oGetQtNFe:lShowHint 		:= .F.
	oGetQtNFe:lReadOnly 		:= .F.
	oGetQtNFe:Align 	 		:= 0
	oGetQtNFe:lVisibleControl 	:= .T.
	oGetQtNFe:lPassword 		:= .F.
	oGetQtNFe:lHasButton  		:= .F.
	oGetQtNFe:cVariable 		:= "nQtNFe"
	oGetQtNFe:bSetGet 	  		:= {|u| If(PCount()>0,nQtNFe:=u,nQtNFe)}
	oGetQtNFe:Picture    		:= "@E 999,999"
	oGetQtNFe:bWhen      		:= {|| .F.}
	oGetQtNFe:bChange	 		:= {|| .T. }
	oGetQtNFe:bValid			:= {|| .T.}

	If lMotori
		//Monta a legenda Motorista
		oSayMot:= TSAY():Create(oPanel1)
		oSayMot:cName			:= "oSayMot"
		oSayMot:cCaption 		:= STR0951 //"Condutor Principal:"
		oSayMot:nLeft 			:= MDFeResol(65,.T.)
		oSayMot:nTop 			:= MDFeResol(15.3,.F.)
		oSayMot:nWidth 	   		:= MDFeResol(10,.T.)
		oSayMot:nHeight 		:= MDFeResol(2.5,.F.)
		oSayMot:lShowHint 		:= .F.
		oSayMot:lReadOnly 		:= .F.
		oSayMot:Align 			:= 0
		oSayMot:lVisibleControl	:= .T.
		oSayMot:lWordWrap 		:= .F.
		oSayMot:lTransparent 	:= .F.
		oSayMot:nClrText 		:= CLR_HBLUE

		//Monta a Get - Motorista
		oGetMot:= TGET():Create(oPanel1)
		oGetMot:cName 	 			:= "oGetMot"
		oGetMot:nLeft 	 			:= MDFeResol(72,.T.)
		oGetMot:nTop 	 			:= MDFeResol(15,.F.)
		oGetMot:nWidth 	 			:= MDFeResol(8,.T.)
		oGetMot:nHeight 	 		:= MDFeResol(nPercAlt,.F.)
		oGetVeiculo:lShowHint 		:= .F.
		oGetVeiculo:lReadOnly 		:= .F.
		oGetVeiculo:Align 	 		:= 0
		oGetVeiculo:lVisibleControl := .T.
		oGetVeiculo:lPassword 		:= .F.
		oGetVeiculo:lHasButton		:= .F.
		oGetMot:cF3 				:= "DA4"
		oGetMot:cVariable 			:= "cMotorista"
		oGetMot:bSetGet 	 		:= {|u| If(PCount()>0,cMotorista:=u,cMotorista)}
		oGetMot:Picture   			:= PesqPict("CCO","CC0_MOTORI")
		oGetMot:bWhen     			:= {|| (nOpc == 3 .or. nOpc == 4)} 
		oGetMot:bValid				:= {|| Empty(cMotorista) .or. (ExistCpo("DA4",(cMotorista),1) .and. MDFeVldMot()) }
	Endif

	If lModal
		//Monta a legenda Modal
		oSayMod:= TSAY():Create(oPanel1)
		oSayMod:cName			:= "oSayMod"
		oSayMod:cCaption 		:= STR0889 //"Modal:"
		oSayMod:nLeft 	 		:= MDFeResol(82.0,.T.)
		oSayMod:nTop 			:= MDFeResol(15.3,.F.)
		oSayMod:nWidth 	   		:= MDFeResol(10,.T.)
		oSayMod:nHeight 		:= MDFeResol(2.5,.F.)
		oSayMod:lShowHint 		:= .F.
		oSayMod:lReadOnly 		:= .F.
		oSayMod:Align 			:= 0
		oSayMod:lVisibleControl	:= .T.
		oSayMod:lWordWrap 		:= .F.
		oSayMod:lTransparent 	:= .F.
		oSayMod:nClrText 		:= CLR_HBLUE
    
		//Monta a Get - Modal
		oGetMod:= TGET():Create(oPanel1)
		oGetMod:cName 	 		:= "oGetNfeFil"
		oGetMod:nLeft 	 		:= MDFeResol(85,.T.)
		oGetMod:nTop 	 		:= MDFeResol(10,.F.)
		oGetMod:nWidth 	 		:= MDFeResol(5,.T.)
		oGetMod:nHeight 	 	:= MDFeResol(nPercAlt,.F.)
		oGetMod:lShowHint 		:= .F.
		oGetMod:lReadOnly 		:= .F.
		oGetMod:Align 	 		:= 	0
		oGetMod:lVisibleControl := .F.
		oGetMod:lPassword 		:= .F.
		oGetMod:lHasButton		:= .F.
		oGetMod:cVariable 		:= "cModal"
		oGetMod:bWhen     		:= {|| (nOpc == 3 )}
		oCombo3:= TComboBox():New(MDFeResol(7.4,.F.),MDFeResol(43,.T.),{|u|if(PCount()>0,cModal:=u,cModal)},  aCombo3,50,20,oPanel1,,{||.T.,ShowNFs(nOpc,.F.)},,,,.T.,,,,,,,,,'cModal')
		oCombo3:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)} 
		oGetMod:bSetGet 	 	:= {||cModal}
	Endif

	If lMDFePost
		//Monta a legenda 'Posterior.'
		oSayPoster:= TSAY():Create(oPanel1)
		oSayPoster:cName			:= "oSayPoster"
		oSayPoster:cCaption 		:= STR0526+":"	//#"Carrega Posterior"
		oSayPoster:nLeft 			:= MDFeResol(48.4,.T.)
 		oSayPoster:nTop 			:= MDFeResol(15.3,.F.)
		oSayPoster:nWidth 	   		:= MDFeResol(10,.T.)
		oSayPoster:nHeight 			:= MDFeResol(2.7,.F.)
		oSayPoster:lShowHint 		:= .F.
		oSayPoster:lReadOnly 		:= .F.
		oSayPoster:Align 			:= 0
		oSayPoster:lVisibleControl	:= .T.
		oSayPoster:lWordWrap 	  	:= .F.
		oSayPoster:lTransparent 	:= .F.
		oSayPoster:nClrText 		:= CLR_HBLUE

		//Monta a Get - 'Posterior'
		oCombo2 := TComboBox():New(MDFeResol(7,.F.),MDFeResol(28.5,.T.),{|u|if(PCount()>0,cPoster:=u,cPoster)},aCombo2,33,20,oPanel1,,,{|| iif(oCombo2:LMODIFIED, iif(SubStr(cPoster,1,1) == "1", iif(VldVeiculo(cVeiculo),(CleanTRB(nOpc),.T.),.F.), (ShowNFs(nOpc,.F.),.T.)) ,.T.)  },,,.T.,,,,{|| nOpc == 3},,,,,'cPoster') //#"1-Sim"

	Endif

	//Monta o Box 4 - Informações Adicionais
	oBox4:= TGROUP():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)])
	oBox4:cName		:= "oBox4"
	oBox4:cCaption	:= "Informações Adicionais"
	oBox4:nLeft		:= MDFeResol(0.5,.T.)
	oBox4:nTop		:= MDFeResol(0.3,.F.)
	oBox4:nWidth	:= MDFeResol(91.7,.T.)
	oBox4:nHeight	:= MDFeResol(14.5,.F.)
	oBox4:lShowHint	:= .F.
	oBox4:lReadOnly	:= .F.
	oBox4:Align		:= 0
	oBox4:lVisibleControl := .T.

	//Monta o Box5 - Autorizados     
	oBox5:= TGROUP():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)])
	oBox5:cName 	   := "oBox5"
	oBox5:cCaption   := "Autorizados"
	oBox5:nLeft 	   := MDFeResol(0.5,.T.)
	oBox5:nTop  	   := MDFeResol(15,.F.)
	oBox5:nWidth 	   := MDFeResol(45.5,.T.)
	oBox5:nHeight 	   := MDFeResol(28.5,.F.)
	oBox5:lShowHint    := .F.
	oBox5:lReadOnly    := .F.
	oBox5:Align        := 0
	oBox5:lVisibleControl := .T.

	//Monta o Box6 - Lacres  
	oBox6:= TGROUP():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)])
	oBox6:cName 	   := "oBox6"
	oBox6:cCaption   := "Lacres"
	oBox6:nLeft 	   := MDFeResol(46.7,.T.)
	oBox6:nTop  	   := MDFeResol(15,.F.)
	oBox6:nWidth 	   := MDFeResol(45.5,.T.)
	oBox6:nHeight 	   := MDFeResol(28.5,.F.)
	oBox6:lShowHint    := .F.
	oBox6:lReadOnly    := .F.
	oBox6:Align        := 0
	oBox6:lVisibleControl := .T.

	//Monta a legenda 'Info.Compl.'
	oSayInfCpl:= TSAY():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)])
	oSayInfCpl:cName			:= "oSayInfCpl"
	oSayInfCpl:cCaption 		:= "Inf.Complementares"
	oSayInfCpl:nLeft 			:= Iif(aSizeAut[2]==0,11.5,aSizeAut[2])+1.5
	oSayInfCpl:nTop 			:= Iif(aSizeAut[2]==0,11.5,aSizeAut[2])*2
	oSayInfCpl:nWidth 	   		:= MDFeResol(20,.T.)
	oSayInfCpl:nHeight 			:= MDFeResol(2.5,.F.)
	oSayInfCpl:lShowHint 		:= .F.
	oSayInfCpl:lReadOnly 		:= .F.
	oSayInfCpl:Align 			:= 0
	oSayInfCpl:lVisibleControl	:= .T.
	oSayInfCpl:lWordWrap 	  	:= .F.
	oSayInfCpl:lTransparent 	:= .F.

	//Monta o memo "Informações Complementares"
	oMemo := TMultiGet():New( MDFeResol(1,.T.),(Iif(aSizeAut[2]==0,11.5,aSizeAut[2])*3)-4, { | u | If( PCount() == 0, cInfCpl, cInfCpl := u ) },oTFolder:aDialogs[Len(oTFolder:aDialogs)], MDFeResol(16,.T.),MDFeResol(5.5,.F.),,.T.,,,,.T.,,.F.,,.F.,.F.,.F.,,,.F.,,)
	oMemo:EnableVScroll(.T.)

	//Monta a legenda 'Inf.Fisco'
	oSayInfFis:= TSAY():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)])
	oSayInfFis:cName			:= "oSayInfFis"
	oSayInfFis:cCaption 		:= "Inf.Fisco"
	oSayInfFis:nLeft 			:= aSizeAut[3]
	oSayInfFis:nTop 			:= Iif(aSizeAut[2]==0,11.5,aSizeAut[2])*2
	oSayInfFis:nWidth 	   		:= MDFeResol(20,.T.)
	oSayInfFis:nHeight 	 		:= MDFeResol(2.5,.F.)
	oSayInfFis:lShowHint 		:= .F.
	oSayInfFis:lReadOnly 		:= .F.
	oSayInfFis:Align 			:= 0
	oSayInfFis:lVisibleControl	:= .T.
	oSayInfFis:lWordWrap 	  	:= .F.
	oSayInfFis:lTransparent 	:= .F.

	//Monta o memo "Informações Fisco"
	oMemo2 := TMultiGet():New( MDFeResol(1,.T.),(aSizeAut[3]/2)+29/*MDFeResol(36,.F.)*/, { | u | If( PCount() == 0, cInfFsc, cInfFsc := u ) },oTFolder:aDialogs[Len(oTFolder:aDialogs)], MDFeResol(16,.T.),MDFeResol(5.5,.F.),,.T.,,,,.T.,,.F.,,.F.,.F.,.F.,,,.F.,,)
	oMemo2:EnableVScroll(.T.)

	//Monta o Box7 - Municipios de Carregamento
	oBox7:= TGROUP():Create(oTFolder:aDialogs[2])
	oBox7:cName 	   := "oBox7"
	oBox7:cCaption   := "Municípios de Carregamento"
	oBox7:nLeft 	   := MDFeResol(0.5,.T.)
	oBox7:nTop  	   := MDFeResol(0.3,.F.)
	oBox7:nWidth 	   := MDFeResol(45,.T.)
	oBox7:nHeight 	   := MDFeResol(43,.F.)
	oBox7:lShowHint    := .F.
	oBox7:lReadOnly    := .F.
	oBox7:Align        := 0
	oBox7:lVisibleControl := .T.

	//Monta o Box8 - Percurso do veiculo
	oBox8:= TGROUP():Create(oTFolder:aDialogs[2])
	oBox8:cName			:= "oBox8"
	oBox8:cCaption   	:= "Percurso do veículo"
	oBox8:nLeft			:= MDFeResol(46.6,.T.)//46.8
	oBox8:nTop			:= MDFeResol(0.3,.F.)
	oBox8:nWidth		:= MDFeResol(45.5,.T.)
	oBox8:nHeight		:= MDFeResol(43,.F.)
	oBox8:lShowHint		:= .F.
	oBox8:lReadOnly		:= .F.
	oBox8:Align			:= 0
	oBox8:lVisibleControl := .T.

	//Monta o Box 9 - Documentos vinculados
	oBox9:= TGROUP():Create(oTFolder:aDialogs[1])
	oBox9:cName		:= "oBox9"
	oBox9:cCaption	:= "Documentos vinculados"
	oBox9:nLeft		:= MDFeResol(0.5,.T.)//0.5
	oBox9:nTop		:= MDFeResol(0.3,.F.)//0.3
	oBox9:nWidth	:= MDFeResol(91.7,.T.)//91.7
	oBox9:nHeight	:= MDFeResol(43.2,.F.)//43.2
	oBox9:lShowHint	:= .F.
	oBox9:lReadOnly	:= .F.
	oBox9:Align		:= 0
	oBox9:lVisibleControl := .T.

	oBox10:= TGROUP():Create(oTFolder:aDialogs[3])
	oBox10:cName			:= "oBox10"
	oBox10:cCaption			:= STR0624 //"CIOT Vinculados"
	oBox10:nLeft			:= MDFeResol(0.5,.T.)
	oBox10:nTop				:= MDFeResol(0.3,.F.)
	oBox10:nWidth			:= MDFeResol(91.7,.T.)
	oBox10:nHeight			:= MDFeResol(43.2,.F.)
	oBox10:lShowHint		:= .F.
	oBox10:lReadOnly		:= .F.
	oBox10:Align			:= 0
	oBox10:lVisibleControl	:= .T.

	oBox11:= TGROUP():Create(oTFolder:aDialogs[5])
	oBox11:cName			:= "oBox11"
	oBox11:cCaption			:= STR0835 //"Vale-Pedágio"
	oBox11:nLeft			:= MDFeResol(0.5,.T.)
	oBox11:nTop				:= MDFeResol(0.3,.F.)
	oBox11:nWidth			:= MDFeResol(91.7,.T.)
	oBox11:nHeight			:= MDFeResol(43.2,.F.)
	oBox11:lShowHint		:= .F.
	oBox11:lReadOnly		:= .F.
	oBox11:Align			:= 0
	oBox11:lVisibleControl	:= .T.

	oBox12:= TGROUP():Create(oTFolder:aDialogs[6])
	oBox12:cName			:= "oBox12"
	oBox12:cCaption			:= STR0836 //"Produto Predominante"
	oBox12:nLeft			:= MDFeResol(0.5,.T.)
	oBox12:nTop				:= MDFeResol(0.3,.F.)
	oBox12:nWidth			:= MDFeResol(91.7,.T.)
	oBox12:nHeight			:= MDFeResol(41.5,.F.)
	oBox12:lShowHint		:= .F.
	oBox12:lReadOnly		:= .F.
	oBox12:Align			:= 0
	oBox12:lVisibleControl	:= .T.

	oBox13:= TGROUP():Create(oTFolder:aDialogs[7])
	oBox13:cName		:= "oBox13"
	oBox13:cCaption		:= STR0907 // "Seguro"
	oBox13:nLeft		:= MDFeResol(0.5,.T.)
	oBox13:nTop			:= MDFeResol(0.3,.F.)
	oBox13:nWidth		:= MDFeResol(91.7,.T.)
	oBox13:nHeight		:= MDFeResol(41.5,.F.)
	oBox13:lShowHint	:= .F.
	oBox13:lReadOnly	:= .F.
	oBox13:Align		:= 0
	oBox13:lVisibleControl := .T.

	oBox15:= TGROUP():Create(oTFolder:aDialogs[8])
	oBox15:cName := "oBox15"
	oBox15:cCaption	:= STR0915 //"Contratantes do serviço de transporte"
	oBox15:nLeft:= MDFeResol(0.5,.T.)
	oBox15:nTop	:= MDFeResol(0.3,.F.)
	oBox15:nWidth := MDFeResol(91.7,.T.)
	oBox15:nHeight := MDFeResol(41.5,.F.)
	oBox15:lShowHint:= .F.
	oBox15:lReadOnly:= .F.
	oBox15:Align := 0
	oBox15:lVisibleControl := .T.

	oBox16:= TGROUP():Create(oTFolder:aDialogs[9])
	oBox16:cName 			:= "oBox16"
	oBox16:cCaption			:= STR0950 //"Condutores adicionais"
	oBox16:nLeft			:= MDFeResol(0.5,.T.)
	oBox16:nTop				:= MDFeResol(0.3,.F.)
	oBox16:nWidth 			:= MDFeResol(91.7,.T.)
	oBox16:nHeight 			:= MDFeResol(41.5,.F.)
	oBox16:lShowHint		:= .F.
	oBox16:lReadOnly		:= .F.
	oBox16:lVisibleControl	:= .T.
	oBox16:Align 			:= 0

	oBox17 := TGROUP():Create(oTFolder:aDialogs[10])
	oBox17:cName 			:= "oBox17"
	oBox17:cCaption			:= STR0963 // "Reboques"
	oBox17:nLeft			:= MDFeResol(0.5,.T.)
	oBox17:nTop				:= MDFeResol(0.3,.F.)
	oBox17:nWidth 			:= MDFeResol(91.7,.T.)
	oBox17:nHeight 			:= MDFeResol(41.5,.F.)
	oBox17:lShowHint		:= .F.
	oBox17:lReadOnly		:= .F.
	oBox17:lVisibleControl	:= .T.
	oBox17:Align 			:= 0

	If lModal
		oBox14:= TGROUP():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oBox14:cName			:= "oBox14"
		oBox14:cCaption			:= STR0890 //"Informação Modal Aéreo" 
		oBox14:nLeft			:= MDFeResol(0.5,.T.)
		oBox14:nTop				:= MDFeResol(0.3,.F.)
		oBox14:nWidth			:= MDFeResol(91.7,.T.)
		oBox14:nHeight			:= MDFeResol(41.5,.F.)
		oBox14:lShowHint		:= .F.
		oBox14:lReadOnly		:= .F.
		oBox14:Align			:= 0
		oBox14:lVisibleControl	:= .T.
	EndIf

	//Monta a MarkBrowse de Notas a Manifestar
	If nOpc == 3
		LoadTRB(nOpc)	//Carrega o arquivo de apoio TRB
	EndIf
	nTopGD  	:= MDFeResol(1,.F.)
	nLeftGD 	:= MDFeResol(0.5,.T.)
	nDownGD 	:= MDFeResol(21,.F.)
	nRightGD	:= MDFeResol(46,.T.)
	oMsSel 		:= MsSelect():New("TRB","TRB_MARCA",,aCmpBrow,,cMark,{nTopGD,nLeftGD,nDownGD,nRightGD},,,oTFolder:aDialogs[1])
	oMsSel:bAval:= { || MarcaNF(nOpc)}

	//Monta a GetDados "Municipio de Carregamento"
	nTopGD  	:= MDFeResol(2,.F.)
	nLeftGD 	:= MDFeResol(0.8,.T.)
	nDownGD 	:= MDFeResol(20.8,.F.)
	nRightGD	:= MDFeResol(22.3,.T.)
	oGetDMun	:= MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(lIncAltDel,nIncAltDel,0) ,,,,{"CC2_CODMUN"},,50,,,,oTFolder:aDialogs[2],aHeadMun,aColsMun)

	//Monta a GetDados "Percurso do veiculo"
	nTopGD  	:= MDFeResol(2,.F.)
	nLeftGD 	:= MDFeResol(23.7,.T.)
	nDownGD 	:= MDFeResol(20.8,.F.)
	nRightGD	:= MDFeResol(45.7,.T.)
	oGetDPerc	:= MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(lIncAltDel,nIncAltDel,0),,,,,,25,,,,oTFolder:aDialogs[2],aHeadPerc,aColsPerc)

	//Monta a GetDados "CIOT"
	nTopGD  	:= MDFeResol(1,.F.)
	nLeftGD 	:= MDFeResol(0.5,.T.)
	nDownGD 	:= MDFeResol(21,.F.)
	nRightGD	:= MDFeResol(46,.T.)
	oGetDCiot   := MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(lIncAltDel,nIncAltDel,0),"VldLinCiot()",,,,,,,,,oTFolder:aDialogs[3],aHeadCiot,aColsCiot)

	/*==================== Informações de Pagamento ========================*/
	if lInfPag .And. oDlgPgt:CreateGrid(@oTFolder:aDialogs[4], iif(lIncAltDel,nIncAltDel,0))
		oDlgPgt:Show()
	endif

	//Monta a GetDados "Vale-Pedagio"
	nTopGD  	:= MDFeResol(1,.F.)
	nLeftGD 	:= MDFeResol(0.5,.T.)
	nDownGD 	:= MDFeResol(21,.F.)
	nRightGD	:= MDFeResol(46,.T.)
	oGetDValPed	:= MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(lIncAltDel,nIncAltDel,0),"valPedValLin()",,,,,,,,,oTFolder:aDialogs[5],aHeadValPed,aColsValPed)

	oSayPPcProd:= TSAY():Create(oTFolder:aDialogs[6])
	oSayPPcProd:cName			:= "oSayPPCProd"
	oSayPPcProd:cCaption 		:= STR0846 //"Produto:"
	oSayPPcProd:nTop 			:= MDFeResol(5,.F.)
	oSayPPcProd:nLeft 			:= MDFeResol(2,.T.)
	oSayPPcProd:nWidth 	   		:= MDFeResol(10,.T.)
	oSayPPcProd:nHeight 		:= MDFeResol(2.5,.F.)
	oSayPPcProd:lShowHint 		:= .F.
	oSayPPcProd:lReadOnly 		:= .F.
	oSayPPcProd:Align 			:= 0
	oSayPPcProd:lVisibleControl	:= .T.
	oSayPPcProd:lWordWrap 		:= .F.
	oSayPPcProd:lTransparent 	:= .F.

	oGetPPcProd:= TGET():Create(oTFolder:aDialogs[6])
	oGetPPcProd:cName 	 		:= "oGetPPcProd"
	oGetPPcProd:nTop 			:= MDFeResol(3.9,.F.)
	oGetPPcProd:nLeft 			:= MDFeResol(8,.T.)
	oGetPPcProd:nWidth 	   		:= MDFeResol(15,.T.)
	oGetPPcProd:nHeight 		:= MDFeResol(3,.F.)
	oGetPPcProd:cF3 			:= "SB1"
	oGetPPcProd:cVariable 		:= "cPPCProd"
	oGetPPcProd:bSetGet 	 	:= {|u| If(PCount()>0,cPPCProd:=u,cPPCProd)}
	oGetPPcProd:Picture   		:= PesqPict("SB1","B1_COD")
	oGetPPcProd:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)} 
	oGetPPcProd:bValid			:= {|| mdfePPTrig() }
	
	oSayPPxProd:= TSAY():Create(oTFolder:aDialogs[6])
	oSayPPxProd:cName			:= "oSayPPxProd"
	oSayPPxProd:cCaption 		:= STR0847 //"Descrição do produto:"
	oSayPPxProd:nTop 			:= MDFeResol(5,.F.)
	oSayPPxProd:nLeft 			:= MDFeResol(27,.T.)
	oSayPPxProd:nWidth 	   		:= MDFeResol(10,.T.)
	oSayPPxProd:nHeight 		:= MDFeResol(2.5,.F.)
	oSayPPxProd:lShowHint 		:= .F.
	oSayPPxProd:lReadOnly 		:= .F.
	oSayPPxProd:Align 			:= 0
	oSayPPxProd:lVisibleControl	:= .T.
	oSayPPxProd:lWordWrap 		:= .F.
	oSayPPxProd:lTransparent 	:= .F.
	oSayPPxProd:nClrText 		:= CLR_HBLUE

	oGetPPxProd:= TGET():Create(oTFolder:aDialogs[6])
	oGetPPxProd:cName 	 		:= "oGetPPxProd"
	oGetPPxProd:nTop 			:= MDFeResol(3.9,.F.)
	oGetPPxProd:nLeft 			:= MDFeResol(37,.T.)
	oGetPPxProd:nWidth 	   		:= MDFeResol(23,.T.)
	oGetPPxProd:nHeight 		:= MDFeResol(3,.F.)
	oGetPPxProd:cVariable 		:= "cPPxProd"
	oGetPPxProd:bSetGet 	 	:= {|u| If(PCount()>0,cPPxProd:=u,cPPxProd)}
	oGetPPxProd:Picture   		:= PesqPict("SB1","B1_DESC")
	oGetPPxProd:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)} 

	//Produto predominante
	oSaytpCarga:= TSAY():Create(oTFolder:aDialogs[6])
	oSaytpCarga:cName			:= "oSaytpCarga"
	oSaytpCarga:cCaption 		:= STR0845 //"Tipo de Carga:"
	oSaytpCarga:nTop 			:= MDFeResol(5,.F.)
	oSaytpCarga:nLeft 			:= MDFeResol(64,.T.)
	oSaytpCarga:nWidth 	   		:= MDFeResol(10,.T.)
	oSaytpCarga:nHeight 		:= MDFeResol(2.5,.F.)
	oSaytpCarga:lShowHint 		:= .F.
	oSaytpCarga:lReadOnly 		:= .F.
	oSaytpCarga:Align 			:= 0
	oSaytpCarga:lVisibleControl	:= .T.
	oSaytpCarga:lWordWrap 		:= .F.
	oSaytpCarga:lTransparent 	:= .F.
	oSaytpCarga:nClrText 		:= CLR_HBLUE
	
	oGettpCarga:= tComboBox():New(MDFeResol(2,.F.),MDFeResol(36,.T.),{|u|if(PCount()>0,cVVTpCarga:=u,cVVTpCarga)},TpCargaIt(),100,17,oTFolder:aDialogs[6],,{ || },,,,.T.,,,,{|| (nOpc == 3 .or. nOpc == 4)},,,,,'cVVTpCarga')
	
	oSayPPNCM:= TSAY():Create(oTFolder:aDialogs[6])
	oSayPPNCM:cName				:= "oSayPPNCM"
	oSayPPNCM:cCaption 			:= STR0848 //"Código NCM:"
	oSayPPNCM:nTop 				:= MDFeResol(13,.F.)
	oSayPPNCM:nLeft 			:= MDFeResol(2,.T.)
	oSayPPNCM:nWidth 	   		:= MDFeResol(10,.T.)
	oSayPPNCM:nHeight 			:= MDFeResol(2.5,.F.)
	oSayPPNCM:lShowHint 		:= .F.
	oSayPPNCM:lReadOnly 		:= .F.
	oSayPPNCM:Align 			:= 0
	oSayPPNCM:lVisibleControl	:= .T.
	oSayPPNCM:lWordWrap 		:= .F.
	oSayPPNCM:lTransparent 		:= .F.

	oGetPPNCM:= TGET():Create(oTFolder:aDialogs[6])
	oGetPPNCM:cName 	 		:= "oGetPPNCM"
	oGetPPNCM:nTop 				:= MDFeResol(12,.F.)
	oGetPPNCM:nLeft 			:= MDFeResol(8,.T.)
	oGetPPNCM:nWidth 	   		:= MDFeResol(10,.T.)
	oGetPPNCM:nHeight	 		:= MDFeResol(3,.F.)
	oGetPPNCM:cF3 				:= "SYD"
	oGetPPNCM:cVariable 		:= "cPPNCM"
	oGetPPNCM:bSetGet 		 	:= {|u| If(PCount()>0,cPPNCM:=u,cPPNCM)}
	oGetPPNCM:Picture   		:= PesqPict("SB1","B1_POSIPI")
	oGetPPNCM:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)} 
	oGetPPNCM:bValid			:= {|| Empty(cPPNCM) .or. ExistCpo("SYD",cPPNCM)}

	oSayPPCodBar:= TSAY():Create(oTFolder:aDialogs[6])
	oSayPPCodBar:cName			:= "oSayPPCodBar"
	oSayPPCodBar:cCaption 		:= STR0849 //"Cód. de Barras (GTIN):"
	oSayPPCodBar:nTop 			:= MDFeResol(13,.F.)
	oSayPPCodBar:nLeft 			:= MDFeResol(27,.T.)
	oSayPPCodBar:nWidth 	   	:= MDFeResol(10,.T.)
	oSayPPCodBar:nHeight 		:= MDFeResol(2.5,.F.)
	oSayPPCodBar:lShowHint 		:= .F.
	oSayPPCodBar:lReadOnly 		:= .F.
	oSayPPCodBar:Align 			:= 0
	oSayPPCodBar:lVisibleControl:= .T.
	oSayPPCodBar:lWordWrap 		:= .F.
	oSayPPCodBar:lTransparent 	:= .F.

	oGetPPCodbar:= TGET():Create(oTFolder:aDialogs[6])
	oGetPPCodbar:cName 	 		:= "oGetPPCodbar"
	oGetPPCodbar:nTop 			:= MDFeResol(12,.F.)
	oGetPPCodbar:nLeft 			:= MDFeResol(37,.T.)
	oGetPPCodbar:nWidth 	   	:= MDFeResol(15,.T.)
	oGetPPCodbar:nHeight 		:= MDFeResol(3,.F.)
	oGetPPCodbar:cVariable 		:= "cPPCodbar"
	oGetPPCodbar:bSetGet 	 	:= {|u| If(PCount()>0,cPPCodbar:=u,cPPCodbar)}
	oGetPPCodbar:Picture   		:= PesqPict("SB1","B1_CODBAR")
	oGetPPCodbar:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)}

	oSayPPCEPCar:= TSAY():Create(oTFolder:aDialogs[6])
	oSayPPCEPCar:cName			:= "oSayPPCEPCar"
	oSayPPCEPCar:cCaption 		:= STR0876 //"CEP de Carregamento:"
	oSayPPCEPCar:nTop 			:= MDFeResol(13,.F.)
	oSayPPCEPCar:nLeft 			:= MDFeResol(61.3,.T.)
	oSayPPCEPCar:nWidth 	   	:= MDFeResol(10,.T.)
	oSayPPCEPCar:nHeight 		:= MDFeResol(2.5,.F.)
	oSayPPCEPCar:lShowHint 		:= .F.
	oSayPPCEPCar:lReadOnly 		:= .F.
	oSayPPCEPCar:Align 			:= 0
	oSayPPCEPCar:lVisibleControl:= .T.
	oSayPPCEPCar:lWordWrap 		:= .F.
	oSayPPCEPCar:lTransparent 	:= .F.

	oGetPPCEPCar:= TGET():Create(oTFolder:aDialogs[6])
	oGetPPCEPCar:cName 	 		:= "oGetPPCEPCar"
	oGetPPCEPCar:nTop 			:= MDFeResol(12,.F.)
	oGetPPCEPCar:nLeft 			:= MDFeResol(72,.T.)
	oGetPPCEPCar:nWidth 	   	:= MDFeResol(10,.T.)
	oGetPPCEPCar:nHeight 		:= MDFeResol(3,.F.)
	oGetPPCEPCar:cVariable 		:= "cPPCEPCarr"
	oGetPPCEPCar:bSetGet 	 	:= {|u| If(PCount()>0,cPPCEPCarr:=u,cPPCEPCarr)}
	oGetPPCEPCar:Picture   		:= PesqPict("SA1","A1_CEP")
	oGetPPCEPCar:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)}

	oSayPPCEPDes:= TSAY():Create(oTFolder:aDialogs[6])
	oSayPPCEPDes:cName			:= "oSayPPCEPDes"
	oSayPPCEPDes:cCaption 		:= STR0877 //"CEP de Descarregamento:"
	oSayPPCEPDes:nTop 			:= MDFeResol(21,.F.)
	oSayPPCEPDes:nLeft 			:= MDFeResol(2,.T.)
	oSayPPCEPDes:nWidth 	   	:= MDFeResol(10,.T.)
	oSayPPCEPDes:nHeight 		:= MDFeResol(2.5,.F.)
	oSayPPCEPDes:lShowHint 		:= .F.
	oSayPPCEPDes:lReadOnly 		:= .F.
	oSayPPCEPDes:Align 			:= 0
	oSayPPCEPDes:lVisibleControl:= .T.
	oSayPPCEPDes:lWordWrap 		:= .F.
	oSayPPCEPDes:lTransparent 	:= .F.

	oGetPPCEPDes:= TGET():Create(oTFolder:aDialogs[6])
	oGetPPCEPDes:cName 	 		:= "oGetPPCEPDes"
	oGetPPCEPDes:nTop 			:= MDFeResol(20,.F.)
	oGetPPCEPDes:nLeft 			:= MDFeResol(13,.T.)
	oGetPPCEPDes:nWidth 	   	:= MDFeResol(10,.T.)
	oGetPPCEPDes:nHeight 		:= MDFeResol(3,.F.)
	oGetPPCEPDes:cVariable 		:= "cPPCEPDesc"
	oGetPPCEPDes:bSetGet 	 	:= {|u| If(PCount()>0,cPPCEPDesc:=u,cPPCEPDesc)}
	oGetPPCEPDes:Picture   		:= PesqPict("SA1","A1_CEP")
	oGetPPCEPDes:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)}
    

	//----------------- Informações do Contratantes do serviço de transporte
	DlgInfCont(@oBox15, nOpc)
	
	//------------------Informação Modal Aéreo"---------------------------
	if lModal
		//------------------------Número do Voo:------------------------------
		oSayNumVoo:= TSAY():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oSayNumVoo:cName			:= "oSayNumVoo"
		oSayNumVoo:cCaption 		:= STR0891 //"Número do Voo:"
		oSayNumVoo:nTop 			:= MDFeResol(5,.F.)
		oSayNumVoo:nLeft 			:= MDFeResol(2,.T.)
		oSayNumVoo:nWidth 	   		:= MDFeResol(10,.T.)
		oSayNumVoo:nHeight 		    := MDFeResol(2.5,.F.)
		oSayNumVoo:lShowHint 		:= .F.
		oSayNumVoo:lReadOnly 		:= .F.
		oSayNumVoo:Align 			:= 0
		oSayNumVoo:lVisibleControl	:= .T.
		oSayNumVoo:lWordWrap 		:= .F.
		oSayNumVoo:lTransparent 	:= .F.
		oSayNumVoo:nClrText 		:= CLR_HBLUE

		oGetNumVoo:= TGET():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oGetNumVoo:cName 	 		:= "oGetNumVoo"
		oGetNumVoo:nTop 			:= MDFeResol(4.1,.F.)
		oGetNumVoo:nLeft 			:= MDFeResol(11,.T.)
		oGetNumVoo:nWidth 	   		:= MDFeResol(10,.T.)
		oGetNumVoo:nHeight 		    := MDFeResol(3,.F.)
		oGetNumVoo:cVariable 		:= "cNumVoo"
		oGetNumVoo:bSetGet 	 	    := {|u| If(PCount()>0,cNumVoo:=u,cNumVoo)}
		oGetNumVoo:Picture   		:= "@!"
		oGetNumVoo:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)} 

		//----------------------------Data do Voo-----------------------------
		oSayDatVoo:= TSAY():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oSayDatVoo:cName			:= "oSayDatVoo"
		oSayDatVoo:cCaption 		:= STR0892 //"Data do Voo:"
		oSayDatVoo:nTop 			:= MDFeResol(5,.F.)
		oSayDatVoo:nLeft 			:= MDFeResol(27,.T.)
		oSayDatVoo:nWidth 	   		:= MDFeResol(15,.T.)
		oSayDatVoo:nHeight 		    := MDFeResol(2.5,.F.)
		oSayDatVoo:lShowHint 		:= .F.
		oSayDatVoo:lReadOnly 		:= .F.
		oSayDatVoo:Align 			:= 0
		oSayDatVoo:lVisibleControl	:= .T.
		oSayDatVoo:lWordWrap 		:= .F.
		oSayDatVoo:lTransparent 	:= .F.
		oSayDatVoo:nClrText 		:= CLR_HBLUE

		oGetDatVoo:= TGET():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oGetDatVoo:cName 	 		:= "oGetDatVoo"
		oGetDatVoo:nTop 			:= MDFeResol(4.1,.F.)
		oGetDatVoo:nLeft 			:= MDFeResol(37,.T.)
		oGetDatVoo:nWidth 	   		:= MDFeResol(10,.T.)
		oGetDatVoo:nHeight 		    := MDFeResol(3,.F.)
		oGetDatVoo:cVariable 		:= "dDatVoo"
		oGetDatVoo:bSetGet 	 	    := {|u| If(PCount()>0,dDatVoo:=u,dDatVoo)}
		oGetDatVoo:Picture   		:= "@D"
		oGetDatVoo:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)} 

		//---------------------------------Aeroporto de Origem'-------------------------------------
		oSayAerOrig:= TSAY():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oSayAerOrig:cName			:= "oSayAerOrig"
		oSayAerOrig:cCaption 		:= STR0893 //"Aeroporto de Origem:"
		oSayAerOrig:nTop 			:= MDFeResol(13,.F.)
		oSayAerOrig:nLeft 			:= MDFeResol(2,.T.)
		oSayAerOrig:nWidth 	   		:= MDFeResol(10,.T.)
		oSayAerOrig:nHeight 		:= MDFeResol(2.5,.F.)
		oSayAerOrig:lShowHint 		:= .F.
		oSayAerOrig:lReadOnly 		:= .F.
		oSayAerOrig:Align 			:= 0
		oSayAerOrig:lVisibleControl	:= .T.
		oSayAerOrig:lWordWrap 		:= .F.
		oSayAerOrig:lTransparent 	:= .F.
		oSayAerOrig:nClrText 		:= CLR_HBLUE

		oGetAerOrig:= TGET():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oGetAerOrig:cName 	 		:= "oGetAerOrig"
		oGetAerOrig:nTop 		    := MDFeResol(12.1,.F.)
		oGetAerOrig:nLeft 			:= MDFeResol(11,.T.)
		oGetAerOrig:nWidth 	   		:= MDFeResol(10,.T.)
		oGetAerOrig:nHeight	 		:= MDFeResol(3,.F.)
		oGetAerOrig:cF3 			:= "M9"
		oGetAerOrig:cVariable 		:= "cAerOrig"
		oGetAerOrig:bSetGet 		:= {|u| If(PCount()>0,cAerOrig:=u,cAerOrig)}
		oGetAerOrig:Picture   	    := "@!"
		oGetAerOrig:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)} 
		oGetAerOrig:bValid		    := {|| Empty(cAerOrig) .or. ExistCpo("SX5",'M9'+cAerOrig,1)}

		//--------------------------Aeroporto de Destino-----------------
		oSayAerDest:= TSAY():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oSayAerDest:cName			:= "oSayAerDest"
		oSayAerDest:cCaption 		:= STR0894 //"Aeroporto de Destino:"
		oSayAerDest:nTop 			:= MDFeResol(13,.F.)
		oSayAerDest:nLeft 			:= MDFeResol(27,.T.)
		oSayAerDest:nWidth 	   		:= MDFeResol(10,.T.)
		oSayAerDest:nHeight 		:= MDFeResol(2.5,.F.)
		oSayAerDest:lShowHint 		:= .F.
		oSayAerDest:lReadOnly 		:= .F.
		oSayAerDest:Align 			:= 0
		oSayAerDest:lVisibleControl	:= .T.
		oSayAerDest:lWordWrap 		:= .F.
		oSayAerDest:lTransparent 	:= .F.
		oSayAerDest:nClrText 		:= CLR_HBLUE

		oGetAerDest:= TGET():Create(oTFolder:aDialogs[Len(oTFolder:aDialogs)-1])
		oGetAerDest:cName 	 		:= "oGetAerDest"
		oGetAerDest:nTop 		    := MDFeResol(12.1,.F.)
		oGetAerDest:nLeft 			:= MDFeResol(37,.T.)
		oGetAerDest:nWidth 	   		:= MDFeResol(10,.T.)
		oGetAerDest:nHeight	 		:= MDFeResol(3,.F.)
		oGetAerDest:cF3 			:= "M9"
		oGetAerDest:cVariable 		:= "cAerDest"
		oGetAerDest:bSetGet 		:= {|u| If(PCount()>0,cAerDest:=u,cAerDest)}
		oGetAerDest:Picture      	:= "@!"
		oGetAerDest:bWhen     		:= {|| (nOpc == 3 .or. nOpc == 4)} 
		oGetAerDest:bValid		    := {|| Empty(cAerDest) .or. ExistCpo("SX5",'M9'+cAerDest,1)}
	endif

	// Seguro
	DialogSeg(@oBox13, nOpc)

	//Condutores
	DlgConduto(@oBox16, nOpc)

	//Reboques
	DlgReboque(@oBox17, nOpc)

	//Monta a GetDados "Autorizados"
	nTopGD  	:= MDFeResol(8.4,.F.)
	nLeftGD 	:= MDFeResol(0.6,.T.)
	nDownGD 	:= MDFeResol(21.5,.F.)
	nRightGD	:= MDFeResol(22.6,.T.)
	oGetDAut	:= MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(lIncAltDel,nIncAltDel,0),,,,,,10,,,,oTFolder:aDialogs[Len(oTFolder:aDialogs)],aHeadAuto,aColsAuto)

	//Monta a GetDados "Lacres"
	nTopGD  	:= MDFeResol(8.4,.F.)
	nLeftGD 	:= MDFeResol(23.7,.T.)
	nDownGD 	:= MDFeResol(21.5,.F.)
	nRightGD	:= MDFeResol(45.7,.T.)
	oGetDLacre  := MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(lIncAltDel,nIncAltDel,0),,,,,,60,,,,oTFolder:aDialogs[Len(oTFolder:aDialogs)],aHeadLacre,aColsLacre)

	If ((nOpc == 4) .And. lMDFePost .And. CC0->CC0_CARPST =='1')
		cPoster  := IIF(CC0->CC0_CARPST =='1',STR0524,STR0525) //#"1-Sim" ##"2-Não"
		CleanTRB(nOpc)
	ElseIF (nOpc == 5 .Or. nOpc == 2) .And. lMDFePost  .And. CC0->CC0_CARPST =='1'
		cPoster  := IIF(CC0->CC0_CARPST =='1',STR0524,STR0525) //#"1-Sim" ##"2-Não"
		CleanTRB(nOpc)
		oCombo:bWhen := {||.F.}
		oCombo2:bWhen := {||.F.}
	ElseIF (nOpc == 5 .Or. nOpc == 2) .And. lMDFePost
		oCombo:bWhen := {||.F.}
		oCombo2:bWhen := {||.F.}
	EndIf

	//  Exibe a Dialog ao usuario
	oTela:Activate()

	if lGrava .and. (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5)
		MsgRun(STR0981,STR0534,{|| RecInCC0(nOpc, aDados)  }) // "Gravando dados de Manifestação" # "Aguarde"
	endif

	oMsSel := Nil
	cNfeFil := "2-Não"
	cCombo1 := "2-Não"
	cPoster := STR0525 //#"2-Não"

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeManage
Montagem da Dialog do Gerenciador do MDFe

@author Natalia Sartori
@since 10/02/2014
@version P11

@param
@Return
/*/
//-----------------------------------------------------------------------
Function MDFeManage(cAlias, nReg, nOpc,cMark, lInverte)

	Local aAreaCC0	:= CC0->(GetArea())
	Local aObjects	:= {}
	Local aInfo		:= {}
	Local aSizeAut	:= {}
	Local aPosObj 	:= {}
	Local aButtons	:= {}

	aSizeAut := MsAdvSize()

	aObjects := {}
	AAdd( aObjects, { 50, 40, .T., .T., .T. } )
	AAdd( aObjects, { 60, 70, .T., .T. ,.T.} )

	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, , .T. )

	//Verifica se possui o campo CC0_TPEVEN
	dbSelectArea('CC0')
	if !lUsaColab
		aAdd(aButtons, { , {|| (SpedNFeStatus() ) } , STR0007 }) //Status SEFAZ
	endIf
	aAdd(aButtons, { , {|| ( MDFeTrans() ) 						}	, STR0261 				}) //'Transmitir'
	aAdd(aButtons, { , {|| ( MDFeMonit() ) 						}	, STR0432				}) //'Monitorar'
	aAdd(aButtons, { , {|| ( MDFeDamDfe( , , nOpc ) )			}	, STR0290+' '+STR0513	}) //'Imprimir Damdfe'
	aAdd(aButtons, { , {|| ( MDFeEvento(aListDocs,EVCANCELAR) )	}	, STR0677				}) //'Cancelar'
	aAdd(aButtons, { , {|| ( MDFeEvento(aListDocs,EVENCERRAR) )	}	, STR0955				}) //'Encerrar'
	if GetRpoRelease() <= "12.1.027" //Remover essa opção apos inicio do release 12.1.33
		aAdd(aButtons, { , {|| ( IncCondutor(aListDocs,INCCONDEVE) )}	, STR0527				}) //#'Incluir Condutor'
	endIf
	If lMDFePost
		aAdd(aButtons, { , {|| FWMsgRun(,{|| MntEventos(aListDocs)},STR0528,STR0529) } , STR0530 } ) //#"Monitor Evento" ##"Por favor aguarde a montagem da tela de Eventos..." ###"Eventos"
	EndIf

	aAdd(aButtons, { , {||IIF(ParBoxMdfe(), ReloadListDocs(),nil)}	, STR0654 				}) //'Filtro'
	
	//Monta o dialog Principal
	oGerMDFe:= MSDIALOG():Create()
	oGerMDFe:cName     	:= "oGerMDFe"
	oGerMDFe:cCaption  	:= STR0478 //"Gerenciar MDFe"
	oGerMDFe:nLeft     	:= aSizeAut[7]
	oGerMDFe:nTop      	:= aSizeAut[1]
	oGerMDFe:nWidth    	:= aSizeAut[5]
	oGerMDFe:nHeight   	:= aSizeAut[6]+25
	oGerMDFe:lShowHint 	:= .F.
	oGerMDFe:lCentered 	:= .T.
	oGerMDFe:bInit 		:= {|| EnchoiceBar(oGerMDFe,{||oGerMDFe:End()},{||oGerMDFe:End()},,aButtons,,,.F.,.F.,.F.,.F.,.F.,.F. ) }

	If CTIsReady(,,,lUsaColab)
		InstanceObjt(@oGerMDFe)
		RestArea(aAreaCC0)
	Else
		Aviso("MDF-e",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf

	delclassIntF()
Return
//----------------------------------------------------------------------
/*/{Protheus.doc} InstanceObjt
Instancia o objeto antes de setar valores de retorno

@author Cleiton Genuino da Silva
@since 07/04/2017
@version P11
@Return
/*/
//-----------------------------------------------------------------------
Static Function InstanceObjt(oGerMDFe)
Local aSizeAut 	:= MsAdvSize()
Private aListDocs	:= {}
Private lMarkAll	:= .T.

Default oGerMDFe	:= nil

fwfreeobj(oListDocs)
oListDocs := Nil

aSize(aListDocs, 0)
aListDocs	:= {{oNo,"","",STOD("20010101"),"1",.F.,.F.}}
aListDocs	:=	GetListBox()

@ aSizeAut[2],aSizeAut[1] LISTBOX oListDocs 	FIELDS HEADER "","Serie","NÚmero","Data Emissão","Status Documento","Status Evento","Modal" SIZE aSizeAut[3],aSizeAut[4]-21.5 PIXEL OF oGerMDFe

oListDocs:SetArray( aListDocs )
oListDocs:bLine := {||     {If(aListDocs[oListDocs:nAt,7],oOkx,oNo),;
												aListDocs[oListDocs:nAt,2],;
												aListDocs[oListDocs:nAt,3],;
												aListDocs[oListDocs:nAt,4],;
												aListDocs[oListDocs:nAt,5],;
												aListDocs[oListDocs:nAt,6],;
												aListDocs[oListDocs:nAt,9]}}
oListDocs:BLDBLCLICK := {|| MDFLinGer(@oListDocs,@aListDocs,oOkx,oNo)}
oListDocs:bHeaderClick := {|| aEval(aListDocs, {|e| e[7] := lMarkAll}),lMarkAll:=!lMarkAll, oListDocs:Refresh()}

oGerMDFe:Activate() //Exibe a dialog ao usuario
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GetDescStatus
Retorna a descricao do status de acordo com o parametro de codigo recebido

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return
/*/
//-----------------------------------------------------------------------
Static Function GetDescStatus(cStatus)
	Local cDesc := ""

	Do Case
		Case cStatus == TRANSMITIDO
			cDesc := "Transmitido"
		Case cStatus == NAO_TRANSMITIDO
			cDesc := "Nao Transmitido"
		Case cStatus == AUTORIZADO
			cDesc := "Autorizado"
		Case cStatus == NAO_AUTORIZADO
			cDesc := "Nao Autorizado"
		Case cStatus == CANCELADO
			cDesc := "Cancelado"
		Case cStatus == ENCERRADO
			cDesc := "Encerrado"
	EndCase
Return cDesc


//----------------------------------------------------------------------
/*/{Protheus.doc} GetDescEven
Retorna a descricao do status do evento acordo com o parametro de codigo recebido

@author Cesar Bianchi
@since 07/07/2014
@version P11
@Return	cDescription
/*/
//-----------------------------------------------------------------------
Static Function GetDescEven(cStatus,cTpEven,cCodTpEven)
	Local cDesc := ""
    Default cTpEven := ""
	Default cStatus := ""
	Default cCodTpEven	:= ""


	If !Empty(cStatus + cCodTpEven)
		//Monta o tipo de evento
		Do case
			Case cTpEven == EVCANCELAR .Or. cCodTpEven == "5"
				cDesc := "Cancelamento "
			Case "112" $ cTpEven .Or. cCodTpEven == "6"
				cDesc := "Encerramento "
			Case cTpEven == DFEEVENTO
				cDesc :=  STR0531 + " " //#"Vínculo Nota"
			Case cTpEven == INCCONDEVE
				cDesc :=  STR0532 + " " //#"Vínculo Condutor"
			Case cTpEven == INFPAGEVE
				cDesc :=  "Vinculo de Pagamento de Operação de Transporte "
			Otherwise
				cDesc := "Evento (Cancelamento/Encerramento) "
		EndCase

        //Monta o status
		Do Case
			Case cTpEven == INCCONDEVE
				cDesc += "realizado"
			Case cStatus == EVENAOREALIZADO
				cDesc += "transmitido"
			Case cStatus == EVEREALIZADO
				cDesc += "nao transmitido"
			Case cStatus == EVEVINCULADO
				cDesc += "autorizado"
			Case cStatus == EVENAOVINCULADO
				cDesc += "não autorizado"
		EndCase
	EndIf
Return cDesc

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFLinGer
Marca/Desmarca uma MDFe dentro do grid de "Gerenciar MDFe"

@author Natalia Sartori
@since 10/02/2014
@version P11

@param	 	nPerc  - Valor em percentual de video desejado
@Return	lWidht - Flag para controlar se a medida e vertical ou horz
/*/
//-----------------------------------------------------------------------
Static Function MDFLinGer(oList,aArray,oOkx,oNo)
	aArray[oList:nAt,7] := iif(aArray[oList:nAt,7],.F.,.T.)
	oList:Reset()
	oList:SetArray(aArray)
	oList:bLine := {||     {If(aArray[oList:nAt,7],oOkx,oNo),;
												aArray[oList:nAt,2],;
								                aArray[oList:nAt,3],;
								                aArray[oList:nAt,4],;
					         	        		aArray[oList:nAt,5],;
					         	        		aArray[oList:nAt,6],;
												aArray[oList:nAt,9]}}
	oList:Refresh()
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeResol
Montagem da Dialog do Gerenciador do MDFe

@author Natalia Sartori
@since 10/02/2014
@version P11

@param	 	nPerc  - Valor em percentual de video desejado
@Return	lWidht - Flag para controlar se a medida e vertical ou horz
/*/
//-----------------------------------------------------------------------
Static Function MDFeResol(nPerc,lWidth)
	Local nRet
	Private nResHor := aScreen[1] //Tamanho resolucao de video horizontal
	Private nResVer := aScreen[2] //Tamanho resolucao de video vertical

	if lWidth
		nRet := nPerc * nResHor / 100
	else
		nRet := nPerc * nResVer / 100
	endif

Return nRet

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeBut
Cria os botoes da EnchoiceButtons da opção inclur novo MDFe

@author Natalia Sartori
@since 10/02/2014
@version P11

@param	 	nPerc  - Valor em percentual de video desejado
@Return	lWidht - Flag para controlar se a medida e vertical ou horz
/*/
//-----------------------------------------------------------------------
Static Function MDFeBut(nOpc)
	Local aButtons := {{"PROJETPMS", {|| defProdPred(nOpc)}, STR0836, STR0836 }} //"Produto Predominante"

	aAdd( aButtons, {"PROJETPMS", {|| MDfeDefCnt(nOpc)}, STR0916, STR0916 } ) // "Contr. Serv. Transp."

	aAdd( aButtons, {"PROJETPMS", {|| MDfeDefReb(nOpc)}, STR0963, STR0963 } ) // "Reboques"

	//Ponto de entrada para o cliente inserir novos botoes caso desejar
	If ExistBlock("MDFeBut")
		aButtons := ExecBlock("MDFeBut", .F., .F., {aButtons} )
	EndIf
Return aButtons


//----------------------------------------------------------------------
/*/{Protheus.doc} CreateTRB
Cria um arquivo de trabalho temporario, e define o array "Header" da
MarkBrowse de documentos

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	aBrow
/*/
//-----------------------------------------------------------------------
Static Function CreateTRB()

	Private aCmpTRB   := {}

	//Trava o cursor enquanto carrega o arquivo de trabalho
	CursorWait()

	//Monta a aCmpBrow do arquivo de Trabalho
	aAdd(aCmpBrow,{"TRB_MARCA"			,,"Sel" 	       			,"  " 						})
	aAdd(aCmpBrow,{"TRB_SERIE"		,, GetTitulo("F2_SERIE")	,PesqPict("SF2","F2_SERIE") 	})
	aAdd(aCmpBrow,{"TRB_DOC"		,, GetTitulo("F2_DOC")		,PesqPict("SF2","F2_DOC")		})
	If lMDFePost
		aAdd(aCmpBrow,{"TRB_POSTE"		,, GetTitulo("CC0_CARPST")	,PesqPict("CC0","CC0_CARPST")   })
	EndIf
	aAdd(aCmpBrow,{"TRB_EMISS"		,, GetTitulo("F2_EMISSAO")	,PesqPict("SF2","F2_EMISSAO")	})
	aAdd(aCmpBrow,{"TRB_CHVNFE"		,, GetTitulo("F2_CHVNFE")	,PesqPict("SF2","F2_CHVNFE") 	})
	aAdd(aCmpBrow,{"TRB_CODMUN"		,, "Cod Municipio Desc."	,PesqPict("CC2","CC2_CODMUN") 	})
	aAdd(aCmpBrow,{"TRB_NOMMUN"		,, "Nome"					,PesqPict("CC2","CC2_MUN") 		})
	aAdd(aCmpBrow,{"TRB_CODCLI" 	,, GetTitulo("A1_COD")		,PesqPict("SA1","A1_COD") 		})
	aAdd(aCmpBrow,{"TRB_NOMCLI"    	,, GetTitulo("A1_NOME")		,PesqPict("SA1","A1_NOME") 		})
	aAdd(aCmpBrow,{"TRB_TPNF"		,,"Tipo da Nota" 	       	,"  "	 						})

	//Monta a estrutura do arquivo de trabalho
	Aadd( aCmpTRB, {"TRB_MARCA"			,"C"    ,2            			 	,0    })
	Aadd( aCmpTRB, {"TRB_FILIAL"		,"C"    ,TamSx3("F2_FILIAL")[1]		,0    })
	Aadd( aCmpTRB, {"TRB_SERIE"			,"C"    ,TamSx3("F2_SERIE")[1] 		,0    })
	Aadd( aCmpTRB, {"TRB_DOC"			,"C"    ,TamSx3("F2_DOC")[1] 		,0    })
	Aadd( aCmpTRB, {"TRB_EMISS"			,"D"    ,TamSx3("F2_EMISSAO")[1]	,0    })
	Aadd( aCmpTRB, {"TRB_CHVNFE"  		,"C"    ,TamSx3("F2_CHVNFE")[1]   	,0    })
	Aadd( aCmpTRB, {"TRB_EST"			,"C"    ,TamSx3("CC2_EST")[1]		,0    })
	Aadd( aCmpTRB, {"TRB_CODMUN"		,"C"    ,TamSx3("CC2_CODMUN")[1]	,0    })
	Aadd( aCmpTRB, {"TRB_NOMMUN"		,"C"    ,TamSx3("CC2_MUN")[1]    	,0    })
	Aadd( aCmpTRB, {"TRB_CODCLI"		,"C"    ,TamSx3("A1_COD")[1]    	,0    })
	Aadd( aCmpTRB, {"TRB_LOJCLI"		,"C"    ,TamSx3("A1_LOJA")[1]    	,0    })
	Aadd( aCmpTRB, {"TRB_NOMCLI"		,"C"    ,TamSx3("A1_NOME")[1]   	,0    })
	Aadd( aCmpTRB, {"TRB_VALTOT"		,"N"    ,TamSx3("F2_VALBRUT")[1]   	,TamSx3("F2_VALBRUT")[2]   })
	Aadd( aCmpTRB, {"TRB_PESBRU"		,"N"    ,TamSx3("F2_PBRUTO")[1]   	,TamSx3("F2_PBRUTO")[2]    })
	Aadd( aCmpTRB, {"TRB_VEICU1"		,"C"    ,TamSx3("F2_VEICUL1")[1]   	,0    })
	Aadd( aCmpTRB, {"TRB_VEICU2"		,"C"    ,TamSx3("F2_VEICUL2")[1]   	,0    })
	Aadd( aCmpTRB, {"TRB_VEICU3"		,"C"    ,TamSx3("F2_VEICUL3")[1]   	,0    })
	Aadd( aCmpTRB, {"TRB_TPNF"			,"C"    ,1						 	,0    })
	Aadd( aCmpTRB, {"TRB_POSTE"			,"C"    ,1						 	,0    })
	Aadd( aCmpTRB, {"TRB_RECNF"			,"N"    ,16							,0    })

	oTempTable := FWTemporaryTable():New( "TRB" )
	oTemptable:SetFields( aCmpTRB )
	oTempTable:AddIndex("01", {"TRB_SERIE", "TRB_DOC" } )
	oTempTable:AddIndex("02", {"TRB_CODMUN", "TRB_SERIE", "TRB_DOC"} )
	oTempTable:AddIndex("03", {"TRB_MARCA", "TRB_SERIE", "TRB_DOC"} )
	oTempTable:Create()
	cAlias := oTempTable:GetRealName()

	//Libera o cursor do mouse
	CursorArrow()

Return

Function TRBSetIndex(nIdx)
	If nIdx == 1
		IndRegua("TRB",cIndTRB1,"TRB_SERIE + TRB_DOC",,,"Indexando ... ")
	Else
		IndRegua("TRB",cIndTRB2,"TRB_CODMUN + TRB_SERIE + TRB_DOC",,,"Indexando ... ")
	EndIf
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} ParamNfs()
Parametro para filtras NFs na tela de selecao

@author Leonardo Kichitaro
@since 11/02/2016
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function ParamNfs(nOpc,lReset)

	Local aParam		:= {CtoD("  /  /  "),CtoD("  /  /  ")}
	Local aPerg			:= {}
	Local cParNfePar	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"PARMDFE"

	Default lReset := .F.

	aadd(aPerg,{1,STR0100,aParam[01],"",".T.","",".T.",50,.F.})	//"Data inicial"
	aadd(aPerg,{1,STR0101,aParam[02],"",".T.","",".T.",50,.T.})	//"Data final"

	aParam[01] := ParamLoad(cParNfePar,aPerg,1,aParam[01])
	aParam[02] := ParamLoad(cParNfePar,aPerg,2,aParam[02])

	If nOpc == 3 .or. lReset
		If ParamBox(aPerg,"MDF-e",@aParam,,,,,,,cParNfePar,.T.,.T.)
			dDataIniFil := aParam[01]
			dDataFimFil := aParam[02]
			lLoadParam	:= .T.
		EndIf
	EndIf

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} ShowNFs()
Carrega todas as notas de um determinado veiculo, exibindo uma dialog
do tipo "Processa" ao usuario

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function ShowNFs(nOpc,lReset)
    Default lReset := .F.
	Default nOpc   :=	3
	//Controle de variaveis
	If (nOpc == 3 .and. cVeiculoAux <> cVeiculo) .or. lReset .or. lLoadParam

	    nQtNFe		:= 0
		nVTotal		:= 0
		nPBruto		:= 0
		cVeiculoAux := cVeiculo
		lLoadParam	:= .F.
	EndIf

	IF SubStr(cPoster,1,1) == "2" //2-Não
		MsgRun(STR0533,STR0534,{|| LoadTRB(nOpc) }) //#"Buscando documentos do Veículo" ##"Aguarde"
		TRB->(dbGoTop())
		oMsSel:oBrowse:Refresh()
	Else
		LoadTRB(nOpc)
	EndIf

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} LoadTRB
Carrega os dados do SF2/SA1 no arquivo de apoio TRB

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function LoadTRB(nOpc)
	Local cQuery		:= ""
	Local cNomeCliFor	:= ""
	Local cAlias 		:= GetNextAlias()
	Local cTpNF			:= ""
	Local lMarca 		:= .F.
	Local lCliFor		:= .F.
	local cFilReg		:= ""
	local nRecNFe		:= 0

	//Antes de gravar, esvazio a TRB
	CleanTRB(nOpc)

	If !Empty(cVeiculo) .or. !Empty(cCarga)

		if cEntSai == "1".or. cEntSai == "3" //1-Saida e 3-Entrada e Saida
			cQuery += "SELECT SF2.F2_FILIAL FILIAL,SF2.F2_SERIE SERIE, SF2.F2_DOC DOC, SF2.F2_EMISSAO EMISSAO, SF2.F2_CHVNFE CHVNFE, SF2.F2_ESPECIE ESPECIE, SF2.F2_CARGA CARGA, "
			cQuery += " SF2.F2_VALBRUT VALBRUT, SF2.F2_PBRUTO PBRUTO, SF2.F2_CLIENTE CLIFOR, SF2.F2_LOJA LOJA, SF2.F2_TIPO TIPO, "
			cQuery += " SF2.F2_SERMDF SERMDF, SF2.F2_NUMMDF NUMMDF, SF2.F2_VEICUL1 VEICUL1, SF2.F2_VEICUL2 VEICUL2, SF2.F2_VEICUL3 VEICUL3,'S' AS TP_NF, R_E_C_N_O_ RECNF FROM "
			cQuery += RetSqlName('SF2') + " SF2"
			cQuery += " WHERE "
			cQuery += "SF2.F2_CHVNFE <> ' ' "
			cQuery += "AND SF2.F2_ESPECIE = 'SPED' "
			cQuery += "AND SF2.F2_FIMP <> 'D' "
			cQuery += "AND SF2.D_E_L_E_T_ = ' ' "
			If nOpc == 3 .And. !Empty(dDataIniFil) .And. !Empty(dDataFimFil)
				cQuery += "AND SF2.F2_EMISSAO >= '" +DToS(dDataIniFil)+"' AND SF2.F2_EMISSAO <= '" +DToS(dDataFimFil)+"' "
			endIf
			cQuery += "AND (SF2.F2_VEICUL1 = '" + cVeiculo + "' "
			cQuery += 		"OR SF2.F2_VEICUL2 = '" + cVeiculo + "' "
			cQuery += 		"OR SF2.F2_VEICUL3 = '" + cVeiculo + "') "
			cQuery += "AND ("

			if nOpc == 3 .or. nOpc == 4
				//Traz notas nao selecionadas:
				cQuery += "(SF2.F2_SERMDF = ' ' "
				If SubStr(cNfeFil,1,1) == "2"
					cQuery += "AND SF2.F2_FILIAL = '" + xFilial('SF2') + "' "
				endIf
				cQuery += "AND SF2.F2_NUMMDF = ' ' ) "
			endif

			//Traz notas ja selecionadas:
			If nOpc <> 3
				if nOpc == 4
					cQuery += " OR "
				endif
				cQuery += "(SF2.F2_SERMDF = '" + CC0->CC0_SERMDF + "' "
				if !Empty(cFilMDF) .and. lFilDMDF2
					cQuery += "AND  F2_"+cFilMDF + " = '" + xFilial("CC0") + "' "
				endIf
				cQuery += "AND SF2.F2_NUMMDF = '" + CC0->CC0_NUMMDF + "') "
			EndIf
			cQuery += ")"

		endIf

		if cEntSai == "3" //3-Entrada e Saida
			cQuery += " Union All "
		endIf

		If cEntSai == "2" .or. cEntSai == "3" //2-Entrada e 3-Entrada e Saida
			cQuery += "SELECT SF1.F1_FILIAL FILIAL,SF1.F1_SERIE SERIE, SF1.F1_DOC DOC, SF1.F1_EMISSAO EMISSAO, SF1.F1_CHVNFE CHVNFE, SF1.F1_ESPECIE ESPECIE,'F1_CARGA' AS CARGA,"
			cQuery += " SF1.F1_VALBRUT VALBRUT, SF1.F1_PBRUTO PBRUTO, SF1.F1_FORNECE CLIFOR, SF1.F1_LOJA LOJA, SF1.F1_TIPO TIPO, "
			cQuery += " SF1.F1_SERMDF SERMDF, SF1.F1_NUMMDF NUMMDF, SF1.F1_VEICUL1 VEICUL1, SF1.F1_VEICUL2 VEICUL2, SF1.F1_VEICUL3 VEICUL3,'E' AS TP_NF, R_E_C_N_O_ RECNF FROM "
			cQuery += RetSqlName('SF1') + " SF1 "
			cQuery += " WHERE "
			cQuery += "SF1.F1_ESPECIE = 'SPED' "
			cQuery += "AND SF1.D_E_L_E_T_ = ' ' "
			cQuery += "AND SF1.F1_CHVNFE <> ' ' "
			if(nOpc == 3) .And. !Empty(dDataIniFil) .And. !Empty(dDataFimFil)
				cQuery += "AND SF1.F1_EMISSAO >= '" +DToS(dDataIniFil)+"' AND SF1.F1_EMISSAO <= '" +DToS(dDataFimFil)+"' "
			endIf
			cQuery += "AND (SF1.F1_VEICUL1 = '" + cVeiculo + "' "
			cQuery += 		"OR SF1.F1_VEICUL2 = '" + cVeiculo + "' "
			cQuery += 		"OR SF1.F1_VEICUL3 = '" + cVeiculo + "') "

			cQuery += " AND ("
			
			if nOpc == 3 .or. nOpc == 4
				//Trazer as nao selecionadas
				cQuery += "(SF1.F1_SERMDF = ' ' "
				If SubStr(cNfeFil,1,1) == "2"
					cQuery += "AND SF1.F1_FILIAL = '" + xFilial('SF1') + "' "
				endIf
				cQuery += "AND SF1.F1_NUMMDF = ' ' ) "
			endif

			//Trazer as ja selecionadas
			If nOpc <> 3
				if nOpc == 4
					cQuery += " OR "
				endif
				cQuery += "(SF1.F1_SERMDF = '" + CC0->CC0_SERMDF + "' "
				if !Empty(cFilMDF)  .and. lFilDMDF1
					cQuery += "AND  F1_"+cFilMDF + " = '" + xFilial("CC0") + "' "
				endIf
				cQuery += "AND SF1.F1_NUMMDF = '" + CC0->CC0_NUMMDF + "') "
			EndIf

			cQuery += ") "
		endIf

		If cEntSai == "2" //2-Entrada
			If ExistBlock("MDSQLSF1")
				cQuery := ExecBlock("MDSQLSF1", .F., .F.,{cQuery})
			EndIf
		ElseIf ExistBlock("MDSQLSF2") //1-Saida e 3-Entrada e Saida
			cQuery := ExecBlock("MDSQLSF2", .F., .F.,{cQuery})
		EndIf

		SA1->(dbSetOrder(1))
		SA2->(dbSetOrder(1))

		cQuery := ChangeQuery(cQuery)
		
		iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
		
		While (cAlias)->(!Eof())
			lMarca		:= !Empty((cAlias)->SERMDF)
			cTpNF		:= (cAlias)->TP_NF
			nRecNFe		:= (cAlias)->RECNF
			cNomeCliFor := ""

			If Alltrim(cTpNF) == "E"

				cFilReg := retFilClFo((cAlias)->FILIAL, (cAlias)->TIPO $ "B|D")
				If (cAlias)->TIPO $ "B|D"
					lCliFor	:= .F.
					If SA1->(dbSeek(cFilReg + (cAlias)->CLIFOR + (cAlias)->LOJA))
						cNomeCliFor	:= SA1->A1_NOME
						lCliFor		:= .T.
					EndIf
				Else
					lCliFor := .F.
					If SA2->(dbSeek(cFilReg + (cAlias)->CLIFOR + (cAlias)->LOJA))
						cNomeCliFor	:= SA2->A2_NOME
						lCliFor		:= .T.
					EndIf
				EndIf
			Else

				cFilReg := retFilClFo((cAlias)->FILIAL, !(cAlias)->TIPO $ "B|D")
				If (cAlias)->TIPO $ "B|D"
					lCliFor := .F.
					If SA2->(dbSeek(cFilReg + (cAlias)->CLIFOR + (cAlias)->LOJA))
						cCliFor		:= SA2->A2_COD
						cLjCliFor	:= SA2->A2_LOJA
						cNomeCliFor	:= SA2->A2_NOME
						lCliFor 	:= .T.
					EndIf
				Else
					lCliFor := .F.
					If SA1->(dbSeek(cFilReg + (cAlias)->CLIFOR + (cAlias)->LOJA))
						cCliFor		:= SA1->A1_COD
						cLjCliFor	:= SA1->A1_LOJA
						cNomeCliFor	:= SA1->A1_NOME
						lCliFor 	:= .T.
					EndIf
				EndIf
			Endif
			If (nOpc <> 2  .Or. (nOpc == 2 .And. lMarca)) .And. lCliFor
				If !Empty((cAlias)->DOC) .And. !Empty((cAlias)->SERIE)
					RecTRB(.T.,(cAlias)->SERIE,(cAlias)->DOC,(cAlias)->EMISSAO,(cAlias)->CHVNFE,(cAlias)->CLIFOR,(cAlias)->LOJA,cNomeCliFor,,,,(cAlias)->VALBRUT,(cAlias)->PBRUTO,lMarca,(cAlias)->VEICUL1,(cAlias)->VEICUL2,(cAlias)->VEICUL3,(cAlias)->CARGA,(cAlias)->FILIAL,cTpNF,nRecNFe)
				End
			EndIf
			If !Empty((cAlias)->CARGA) .And. Empty(cVeiculo) .And. nOpc == 3 .And. Alltrim(cTpNF) == "S"
				cVeiculo := (cAlias)->VEICUL1
			EndIf
			(cAlias)->(dbSkip())
		EndDo
		
		if Select("TRB") > 0
			TRB->(dbGoTop())
		endIf

	EndIf

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} RecTRB
Grava ou altera um registro na TRB a partir dos parametros recebidos

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function RecTRB(lInclui,cSerie,cDoc,cEmissao,cChaveNFe,cCodCli,cLoja,cNomCli,cCodMun,cNomMun,cEstMun,nValBru,nPeso,lMarca,cVeic1,cVeic2,cVeic3,cCarga,cTotFilial,cTpNF, nRecNfe)
	Local lRet	:= .T.
	local nPos	:= 0
	Default cCodMun := ""
	Default cNomMun := ""
	Default lMarca := .F.
	Default cCarga := ""
	Default cTotFilial := ""
	Default cTpNF	 := ""
	Default nRecNfe	:= 0

	dbSelectArea('TRB')
	TRB->(dbSetOrder(1))

	If !lInclui
		If !TRB->(dbSeek(cSerie+cDoc))
			lRet := .F.
		EndIf
	EndIf

	If lRet
		RecLock('TRB',lInclui)
		TRB->TRB_MARCA := iif(lMarca,cMark,"")
		TRB->TRB_FILIAL := cTotFilial
		TRB->TRB_SERIE := cSerie
		TRB->TRB_DOC := cDoc
		TRB->TRB_EMISS := STOD(cEmissao)
		TRB->TRB_CHVNFE := cChaveNFe
		
		if (nPos := aScan(aChvsNFe,{|x| alltrim(x[4]) == Alltrim(TRB->TRB_CHVNFE) })) > 0
			TRB->TRB_EST	:= GetUfSig(aChvsNFe[nPos,1])
			TRB->TRB_CODMUN := aChvsNFe[nPos,2]
			TRB->TRB_NOMMUN := aChvsNFe[nPos,3]
		else
			TRB->TRB_CODMUN := cCodMun
			TRB->TRB_NOMMUN := cNomMun
			TRB->TRB_EST	:= 	cEstMun
		endif
		TRB->TRB_CODCLI := cCodCli
		TRB->TRB_LOJCLI := cLoja
		TRB->TRB_NOMCLI := cNomCli
		TRB->TRB_VALTOT := nValBru
		TRB->TRB_PESBRU := nPeso
		TRB->TRB_VEICU1 := cVeic1
		TRB->TRB_VEICU2 := cVeic2
		TRB->TRB_VEICU3 := cVeic3
		TRB->TRB_TPNF	:= cTpNF
		TRB->TRB_RECNF	:= nRecNfe
		If lMDFePost
			TRB->TRB_POSTE  := iif( SubStr(cPoster,1,1) == "1","1","2") //#"1-Sim"
		EndIf
		TRB->(msUnlock())
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} CleanTRB
Esvazia a tabela TRB, para uma nova recarga

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function CleanTRB(nOpc)

	If Select('TRB') > 0
		TRB->(dbGoTop())
		While TRB->(!Eof())
			RecLock('TRB',.F.)
			TRB->TRB_MARCA := " "
			TRB->(dbDelete())
			TRB->(msUnlock())
			TRB->(dbSkip())
		EndDo
	EndIf

	//Reinicia variaveis de controle
	If nOpc == 3
		cCodMun := Space(TamSx3("CC2_CODMUN")[1])
		cNomMun := Space(TamSx3("CC2_MUN")[1])
	    nQtNFe	:= 0
	    nVTotal	:= 0
	    nPBruto	:= 0
	 EndIf

	//Atualiza os objetos graficos da tela
	RefreshMainObjects()
Return


//----------------------------------------------------------------------
/*/{Protheus.doc} GetTitulo
Retorna o titulo de um campo do SX3 passado como parametro

@author Natalia Sartori
@since 10/02/2014
@version P11

@param	cField  - Nome do campo pesquisado
@Return	cTitulo - Titulo do campo pesquisado no SX3
/*/
//-----------------------------------------------------------------------
Static Function GetTitulo(cField)
	Local cTitulo := ""
	Local aArea := GetArea()
	Default cField := ""

	dbSelectArea('SX3')
	SX3->(dbSetOrder(2))
	If !Empty(cField) .and. SX3->(dbSeek(cField))
		cTitulo := X3Titulo()
	EndIf

	RestArea(aArea)
Return cTitulo

//----------------------------------------------------------------------
/*/{Protheus.doc} MarcaNF
Marca uma NF na MSSelect de Notas

@author Natalia Sartori
@since 10/02/2014
@version P11

@param	cField  - Nome do campo pesquisado
@Return	cTitulo - Titulo do campo pesquisado no SX3
/*/
//-----------------------------------------------------------------------
Function MarcaNF(nOpc)
    Local lMarca := Empty(TRB->TRB_MARCA)

	If (nOpc == 3 .or. nOpc == 4)
		If SubStr(cPoster,1,1) == "2" //2-Não
		    //Define qual sera o municipio de carregamento desta NFe
		    if lMarca
			    If len(aMun) <= 99
				    If !SetMunForNF()
				    	Return .F.
				    EndIf
				Else
					MsgStop(STR0535) //#'O limite de 100 municipios foi atingido.'
					Return .F.
				EndIf
			EndIf

		    //Grava a marca e o municipio
		    RecLock("TRB",.F.)
			if lMarca .Or. SubStr(cPoster,1,1) == "1" //1-Sim
				TRB->TRB_MARCA := cMark
				TRB->TRB_CODMUN := cCodMun
				TRB->TRB_NOMMUN := cNomMun
				TRB->TRB_EST	:= cEstMun

			    //Soma totais de notas
			    nQtNFe++
				nVTotal := nVTotal + TRB->TRB_VALTOT
				nPBruto := nPBruto + TRB->TRB_PESBRU
			Else
				TRB->TRB_MARCA := " "
				TRB->TRB_CODMUN := " "
				TRB->TRB_NOMMUN := " "
				TRB->TRB_EST	:= " "

				//Subtrai totais de notas
			   	iif (nQtNFe	> 0	,nQtNFe-- ,nQtNFe)
				iif (nVTotal	> 0	,nVTotal := nVTotal - TRB->TRB_VALTOT	,nVTotal)
				iif (nPBruto	> 0,nPBruto := nPBruto - TRB->TRB_PESBRU	,nPBruto)

			EndIf
		    TRB->(msUnlock())

		    //Atualiza objetos graficos
			RefreshMainObjects()

		Else
			If !SetMunForNF()
			   	Return .F.
			EndIf
			//Grava a marca e o municipio
			If MsSeek(TRB->TRB_SERIE+TRB->TRB_DOC,.F.)
				RecLock("TRB",.F.)
			Else
				RecLock("TRB",.T.)
			EndIf
			TRB->TRB_CODMUN := cCodMun
			TRB->TRB_NOMMUN := cNomMun
			TRB->TRB_EST	:= cEstMun
		    TRB->(msUnlock())
		EndIf
	EndIf

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} SetMunForNF
Exibe a dialog com o municipio de carregamento da NF

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function SetMunForNF()
	Local oDlgMun := NIl
	Local oBoxMun := Nil
	Local lRet		:= .F.
	Local cUF		:= cUFDesc
	Local aIndArq	:={}
	Local cCondicao	:= ""
	Private oGetCodMun := ""
	Private oGetDesMun := ""

	cCodMun := GetMunIbge()

	//Ponto de entrada para definir o código do município e trazer automático
	If ExistBlock("MDFeMun")
		cCodMun := ExecBlock("MDFeMun", .F., .F.,{cEntSai,TRB->TRB_SERIE,TRB->TRB_DOC,TRB->TRB_CODCLI,TRB->TRB_LOJCLI})
	EndIf
	//Monta o Filtro na CC2 com a UF de descarregamento
	//Este ponto eh importante para que so sejam apresentados os municipios da UF marcada
	cCondicao := "CC2_FILIAL == '" + xFilial("CC2") + "'"
	cCondicao += " .AND. CC2_EST == '" + cUF + "' "
	FilBrowse("CC2",@aIndArq,@cCondicao)

	//Monta a Dialog
	oDlgMun:= MSDIALOG():Create()
	oDlgMun:cName     		:= "oDlgMun"
	oDlgMun:cCaption  		:= "Municipio Descarregamento"
	oDlgMun:nLeft     		:= MDFeResol(80,.T.)
	oDlgMun:nTop      		:= MDFeResol(50,.F.)
	oDlgMun:nWidth    		:= MDFeResol(30,.T.)
	oDlgMun:nHeight   		:= MDFeResol(30,.F.)
	oDlgMun:lShowHint 		:= .F.
	oDlgMun:lCentered 		:= .T.
	oDlgMun:bInit 			:= {|| EnchoiceBar(oDlgMun, {||( lRet := .T., oDlgMun:End() )} , {||( lRet := .F., oDlgMun:End() )} ,, {} ) }

	//Box Municipio Carregamento
	oBoxMun:= TGROUP():Create(oDlgMun)
	oBoxMun:cName 	   := "oBoxMun"
	oBoxMun:cCaption   := STR0608 //#"Descarga de Mercadorias"
	oBoxMun:nLeft 	   := MDFeResol(2,.T.)
	oBoxMun:nTop  	   := MDFeResol(9,.F.)
	oBoxMun:nWidth 	   := MDFeResol(26,.T.)
	oBoxMun:nHeight    := MDFeResol(15,.F.)
	oBoxMun:lShowHint  := .F.
	oBoxMun:lReadOnly  := .F.
	oBoxMun:Align      := 0
	oBoxMun:lVisibleControl := .T.

	//Say UF de descarregamento
	oSayUFDes:= TSAY():Create(oDlgMun)
	oSayUFDes:cName				:= "oSayUFDes"
	oSayUFDes:cCaption 			:= STR0609 //#"UF de Descarregamento: "
	oSayUFDes:nLeft 			:= MDFeResol(4,.T.)
	oSayUFDes:nTop 				:= MDFeResol(12,.F.)
	oSayUFDes:nWidth 	   		:= MDFeResol(15,.T.)
	oSayUFDes:nHeight 			:= MDFeResol(2.5,.F.)
	oSayUFDes:lShowHint 		:= .F.
	oSayUFDes:lReadOnly 		:= .F.
	oSayUFDes:Align 			:= 0
	oSayUFDes:lVisibleControl	:= .T.
	oSayUFDes:lWordWrap 	  	:= .F.
	oSayUFDes:lTransparent	 	:= .F.
	oSayUFDes:nClrText	 		:= CLR_HBLUE

	//Get UF Carregamento
	oGetUFDes:= TGET():Create(oDlgMun)
	oGetUFDes:cName 	 		:= "oGetCodMun"
	oGetUFDes:nLeft 	 		:= MDFeResol(18,.T.)
	oGetUFDes:nTop 	 			:= MDFeResol(11.7,.F.)
	oGetUFDes:nWidth 	  		:= MDFeResol(6,.T.)
	oGetUFDes:nHeight 	  		:= MDFeResol(nPercAlt,.F.)
	oGetUFDes:lShowHint 		:= .F.
	oGetUFDes:lReadOnly 		:= .F.
	oGetUFDes:Align 	 		:= 0
	oGetUFDes:cF3				:= ""
	oGetUFDes:lVisibleControl 	:= .T.
	oGetUFDes:lPassword 		:= .F.
	oGetUFDes:lHasButton		:= .F.
	oGetUFDes:cVariable 		:= "cUF"
	oGetUFDes:bSetGet 	 		:= {|u| If(PCount()>0,cUF:=u,cUF)}
	oGetUFDes:Picture   		:= PesqPict("CC2","CC2_EST")
	oGetUFDes:bWhen     		:= {|| .F.}
	oGetUFDes:bChange			:= {|| .F. }

 	//Say Codigo Municipio de descarregamento
	oSayCodMun:= TSAY():Create(oDlgMun)
	oSayCodMun:cName			:= "oSayCodMun"
	oSayCodMun:cCaption 		:= "Municipio de Descarregamento: "
	oSayCodMun:nLeft 			:= MDFeResol(4,.T.)
	oSayCodMun:nTop 			:= MDFeResol(16,.F.)
	oSayCodMun:nWidth 	   		:= MDFeResol(15,.T.)
	oSayCodMun:nHeight 			:= MDFeResol(2.5,.F.)
	oSayCodMun:lShowHint 		:= .F.
	oSayCodMun:lReadOnly 		:= .F.
	oSayCodMun:Align 			:= 0
	oSayCodMun:lVisibleControl	:= .T.
	oSayCodMun:lWordWrap 	  	:= .F.
	oSayCodMun:lTransparent 	:= .F.
	oSayCodMun:nClrText 		:= CLR_HBLUE

	//Get Codigo Municipio de Carregamento
	oGetCodMun:= TGET():Create(oDlgMun)
	oGetCodMun:cName 	 		:= "oGetCodMun"
	oGetCodMun:nLeft 	 		:= MDFeResol(18,.T.)
	oGetCodMun:nTop 	 		:= MDFeResol(15.7,.F.)
	oGetCodMun:nWidth 	  		:= MDFeResol(6,.T.)
	oGetCodMun:nHeight 	  		:= MDFeResol(nPercAlt,.F.)
	oGetCodMun:lShowHint 		:= .F.
	oGetCodMun:lReadOnly 		:= .F.
	oGetCodMun:Align 	 		:= 0
	oGetCodMun:cF3				:= "CC2"
	oGetCodMun:lVisibleControl 	:= .T.
	oGetCodMun:lPassword 		:= .F.
	oGetCodMun:lHasButton		:= .F.
	oGetCodMun:cVariable 		:= "cCodMun"
	oGetCodMun:bSetGet 	 		:= {|u| If(PCount()>0,cCodMun:=u,cCodMun)}
	oGetCodMun:Picture   		:= PesqPict("CC2","CC2_CODMUN")
	oGetCodMun:bWhen     		:= {|| .T.}
	oGetCodMun:bChange			:= {|| LoadNomeMun(cCodMun,@cNomMun,@cEstMun) }
	oGetCodMun:bValid			:= {|| !Empty(cCodMun) .and. LoadNomeMun(cCodMun,@cNomMun,@cEstMun) }

	//Say Nome Municipio
	oSayDesMun:= TSAY():Create(oDlgMun)
	oSayDesMun:cName			:= "oSayDesMun"
	oSayDesMun:cCaption 		:= "Nome: "
	oSayDesMun:nLeft 			:= MDFeResol(4,.T.)
	oSayDesMun:nTop 			:= MDFeResol(20,.F.)
	oSayDesMun:nWidth 	   		:= MDFeResol(15,.T.)
	oSayDesMun:nHeight 			:= MDFeResol(2.5,.F.)
	oSayDesMun:lShowHint 		:= .F.
	oSayDesMun:lReadOnly 		:= .F.
	oSayDesMun:Align 			:= 0
	oSayDesMun:lVisibleControl	:= .T.
	oSayDesMun:lWordWrap 	  	:= .F.
	oSayDesMun:lTransparent 	:= .F.
	oSayDesMun:nClrText 		:= CLR_HBLUE

	//Get Codigo Municipio de Descarregamento
	oGetDesMun:= TGET():Create(oDlgMun)
	oGetDesMun:cName 	 		:= "oGetDesMun"
	oGetDesMun:nLeft 	 		:= MDFeResol(8,.T.)
	oGetDesMun:nTop 	 		:= MDFeResol(19.7,.F.)
	oGetDesMun:nWidth 	  		:= MDFeResol(16,.T.)
	oGetDesMun:nHeight 	  		:= MDFeResol(nPercAlt,.F.)
	oGetDesMun:lShowHint 		:= .F.
	oGetDesMun:lReadOnly 		:= .F.
	oGetDesMun:Align 	 		:= 0
	oGetDesMun:lVisibleControl 	:= .T.
	oGetDesMun:lPassword 		:= .F.
	oGetDesMun:lHasButton		:= .F.
	oGetDesMun:cVariable 		:= "cNomMun"
	oGetDesMun:bSetGet 	 		:= {|u| If(PCount()>0,cNomMun:=u,cNomMun)}
	oGetDesMun:Picture   		:= PesqPict("CC2","CC2_MUN")
	oGetDesMun:bWhen     		:= {|| .F.}
	oGetDesMun:bChange			:= {|| .T. }
	oGetDesMun:bValid			:= {|| !Empty(cNomMun)}

	//Exibe a Dialog
	oDlgMun:Activate()

	//Verifica se a UF do municipio é a mesma da UF Descarga
	If lRet
		If cEstMun != cUFDesc
			MsgStop(STR0759 + cUFDesc + STR0760) //Este municipio não esta localizado dentro a UF: ,  definido como UF de Descarga do MDFe.
			lRet := .F.
		Else
			//Verifica se ja contou o municipio
			If aScan(aMun,cCodMun) <= 0
				aAdd(aMun,cCodMun)
			EndIf
		EndIf
	EndIf

	//Elimina os filtros da CC2
	RetIndex("CC2")
	dbClearFilter()
	aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LoadVarsByCC0
Carrega as variais private a partir do registro selecionado na CC0 e
do XML

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function LoadVarsByCC0(nOpc)
	Local oXML		:= Nil
	Local oInfFsc	:= NIl
	Local oInfCpl	:= Nil
	Local aLacres	:= {}
	Local aMunCar	:= {}
	Local aPerc		:= {}
	Local aMunNfe	:= {}
	Local nI		:= 1
	Local nJ		:= 1
	Local cError	:= ""
	Local cWarning	:= ""
	Local cEstCod	:= ""
	Local cMunCod	:= ""
	Local cMunDesc	:= ""
	Local cCIOT 	:= ""
	Local cContrat	:= ""
	local cIndice	:= ""
	local cCgc		:= ""
	local cTpValePed:= ""
	local cNumCompra:= ""

	Private aCNPJ	:= {}
	Private aCiot	:= {}
	private aValPed	:= {}
	private oProdPre:= nil
	private oModalA := nil

	cSerMDF		:= CC0->CC0_SERMDF
	cNumMDF		:= CC0->CC0_NUMMDF
	cUFCarr		:= CC0->CC0_UFINI
	cUFDesc		:= CC0->CC0_UFFIM
	cUFCarrAux	:= cUFCarr
	cUFDescAux	:= cUFDesc
	cVTotal		:= CC0->CC0_VTOTAL
	cVeiculo	:= CC0->CC0_VEICUL
	cVeiculoAux	:= cVeiculo
	nQtNFe		:= CC0->CC0_QTDNFE
	nVTotal		:= CC0->CC0_VTOTAL
	nPBruto		:= CC0->CC0_PESOB
	cVVTpCarga	:= ""
	cPPcProd	:= space( getSx3Cache( "B1_COD", "X3_TAMANHO") ) // CriaVar("B1_COD")
	cPPxProd	:= space( getSx3Cache( "B1_DESC", "X3_TAMANHO") ) // CriaVar("B1_DESC")
	cPPCodbar	:= space( getSx3Cache( "B1_CODBAR", "X3_TAMANHO") ) // CriaVar("B1_CODBAR")
	cPPNCM		:= space( getSx3Cache( "B1_POSIPI", "X3_TAMANHO") ) // CriaVar("B1_POSIPI")
	cPPCEPCarr	:= space( getSx3Cache( "A1_CEP", "X3_TAMANHO") ) // CriaVar("A1_CEP")
	cPPCEPDesc	:= space( getSx3Cache( "A1_CEP", "X3_TAMANHO") ) // CriaVar("A1_CEP")

	If lMotori
		cMotorista  := CC0->CC0_MOTORI
	EndIf
	If lMDFePost
		cPoster  := IIF(CC0->CC0_CARPST =='1',STR0524,STR0525)//#"1-Sim" ##"2-Não"
	EndIf
	oXML		:= XmlParser(CC0->CC0_XMLMDF,"",@cError,@cWarning)
	nRQtNFe		:= nQtNFe
	nRVTotal	:= nVTotal
	nRPBruto	:= nPBruto
	cNfeFil		:= iif( nOpc <> 3 .and. !empty(alltrim(CC0->CC0_CODRET)) .and. alltrim(CC0->CC0_CODRET) == "1", "1-Sim", "2-Não")
    
	If lModal
		cModal		:= if( empty(alltrim(CC0->CC0_MODAL)) .or. alltrim(CC0->CC0_MODAL) == "1", STR0885, STR0886)
	EndIf
   	
	If ValType(oXML) == "O"
		aMunNfe		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA")
		oProdPre	:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_PRODPRED")
		oInfCpl		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFADIC:_INFCPL")
		oInfFsc		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFADIC:_INFADFISCO")
		aLacres		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_LACRES")
		aCNPJ		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_AUTXML")
		aMunCar		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_IDE:_INFMUNCARREGA")
	    aPerc		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_IDE:_INFPERCURSO")
		aCiot		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_INFCIOT")
		aValPed		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_VALEPED:_DISP")
		aPgtos		:= GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_INFPAG")
		oModalA     := GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFMODAL:_AEREO")

	    //Monta o texto de informacoes complementares
	    If ValType(oInfCpl) == "O"
		    cInfCpl := Padr(oInfCpl:TEXT,5000)
		EndIf

		//Monta o texto de informacoes complementares
	    If ValType(oInfFsc) == "O"
		    cInfFsc := Padr(oInfFsc:TEXT,2000)
		EndIf

		//Produto Predominante carregando dados
		if valType(oProdPre) == "O"
			cVVTpCarga	:= iif(type("oProdPre:_TPCARGA")=="O",oProdPre:_TPCARGA:TEXT,cVVTpCarga)
			if !empty(cVVTpCarga)
				atpItens := tpCargaIt()
				aEval( atpItens, {|x| iif(subStr(x,1,2) == cVVTpCarga, cVVTpCarga := x, nil)  })
			endIf
			cPPxProd	:= padr(iif(type("oProdPre:_XPROD")=="O",oProdPre:_XPROD:TEXT,cPPxProd),tamsx3("B1_DESC")[1])
			cPPCodbar	:= padr(iif(type("oProdPre:_CEAN")=="O",oProdPre:_CEAN:TEXT,cPPCodbar),tamsx3("B1_CODBAR")[1])
			cPPNCM		:= padr(iif(type("oProdPre:_NCM")=="O",oProdPre:_NCM:TEXT,cPPNCM),tamsx3("B1_POSIPI")[1])
			cPPCEPCarr	:= padr(iif(type("oProdPre:_INFLOTACAO:_INFLOCALCARREGA:_CEP")=="O",oProdPre:_INFLOTACAO:_INFLOCALCARREGA:_CEP:TEXT,cPPCEPCarr),tamsx3("A1_CEP")[1])
			cPPCEPDesc	:= padr(iif(type("oProdPre:_INFLOTACAO:_INFLOCALDESCARREGA:_CEP")=="O",oProdPre:_INFLOTACAO:_INFLOCALDESCARREGA:_CEP:TEXT,cPPCEPDesc),tamsx3("A1_CEP")[1])
		endIf
          
		If lModal .and.  valType(oModalA) == "O"
			cNumVoo   	:= iif(type("oModalA:_NVOO")=="O",oModalA:_NVOO:TEXT,cNumVoo)
		  	dDatVoo     := iif(type("oModalA:_DVOO")=="O",sToD(strTran(oModalA:_DVOO:TEXT,"-","")),dDatVoo)
		  	cAerOrig    := iif(type("oModalA:_CAEREMB")=="O",oModalA:_CAEREMB:TEXT,cAerOrig)
		    cAerDest    := iif(type("oModalA:_CAERDES")=="O",oModalA:_CAERDES:TEXT,cAerDest)
		endIf

	   	//Monta o array (aCols) de lacres
	   	aColsLacre := {}
	   	If ValType(aLacres) <> "U"
		   	If ValType(aLacres) == "A"
			   	For nI := 1 to len(aLacres)
			   		aAdd(aColsLacre,{aLacres[nI]:_nLACRE:TEXT,.F.})
			   	Next nI
			ElseIf !Empty(aLacres:_nlacre:TEXT)
				aAdd(aColsLacre,{aLacres:_nLACRE:TEXT,.F.})
			Else
				aColsLacre := GetNewLine(aHeadLacre)
			EndIf
		EndIf

	   	//Monta o array de CNPJs/CPF Autorizados
	   	aColsAuto := {}
	   	If ValType(aCNPJ) <> "U"
		   	If ValType(aCNPJ) == "A"
			   	For nI := 1 to len(aCNPJ)
				   cIndice := allTrim(Str(nI))
			   		If mdfeType("aCNPJ["+cIndice+"]:_CPF") <> "U"
						aAdd(aColsAuto,{aCNPJ[nI]:_CPF:TEXT,.F.})
					EndIf

					If mdfeType("aCNPJ["+cIndice+"]:_CNPJ") <> "U"
						aAdd(aColsAuto,{aCNPJ[nI]:_CNPJ:TEXT,.F.})
					EndIf
			   	Next nI
			ElseIf Type("aCNPJ:_CPF") <> "U" .and. !Empty(aCNPJ:_CPF:TEXT)
				aAdd(aColsAuto,{aCNPJ:_CPF:TEXT,.F.})
			ElseIf Type("aCNPJ:_CNPJ") <> "U" .and. !Empty(aCNPJ:_CNPJ:TEXT)
				aAdd(aColsAuto,{aCNPJ:_CNPJ:TEXT,.F.})
			Else
				aColsAuto := GetNewLine(aHeadAuto)
			EndIf
		EndIf

		//Monta o array de Municipios de Carregamento
		aColsMun := {}
	   	If ValType(aMunCar) <> "U"
	   		If ValType(aMunCar) == "A"
				For nI := 1 to len(aMunCar)
					aAdd(aColsMun,{Iif(Empty(substr(aMunCar[ nI ]:_CMUNCARREGA:TEXT,3,len(aMunCar[ nI ]:_CMUNCARREGA:TEXT))),Space(TamSx3('CC2_CODMUN')[1]),substr(aMunCar[ nI ]:_CMUNCARREGA:TEXT,3,len(aMunCar[ nI ]:_CMUNCARREGA:TEXT))),GetUfSig(substr(aMunCar[ nI ]:_CMUNCARREGA:TEXT,1,2)),aMunCar[ nI ]:_XMUNCARREGA:TEXT,.F.})
				Next nI
			ElseIf !Empty(aMunCar:_CMUNCARREGA:TEXT)
				aAdd(aColsMun,{Iif(Empty(substr(aMunCar:_CMUNCARREGA:TEXT,3,len(aMunCar:_CMUNCARREGA:TEXT))),Space(TamSx3('CC2_CODMUN')[1]),substr(aMunCar:_CMUNCARREGA:TEXT,3,len(aMunCar:_CMUNCARREGA:TEXT))),GetUfSig(substr(aMunCar:_CMUNCARREGA:TEXT,1,2)),aMunCar:_XMUNCARREGA:TEXT,.F.})
			Else
				aColsMun := GetNewLine(aHeadMun)
			EndIf
		EndIf

		//Monta o array de percurso
		aColsPerc := {}
	   	If ValType(aPerc) <> "U"
		   	If ValType(aPerc) == "A"
			   	For nI := 1 to len(aPerc)
			   		aAdd(aColsPerc,{aPerc[nI]:_UFPER:TEXT,.F.})
			   	Next nI
			ElseIf !Empty(aPerc:_UFPER:TEXT)
		   		aAdd(aColsPerc,{aPerc:_UFPER:TEXT,.F.})
		 	Else
		 		aColsPerc := GetNewLine(aHeadPerc)
			EndIf
		EndIf

		//Por fim pega todas as Chaves de NFe e atualiza os municipios dentro do TRB
		If ValType(aMunNfe) <> "U"
			If ValType(aMunNfe) == "A"
			    For nI := 1 to len(aMunNfe)
			    	//Pego o nome e o codigo do municipio'
			    	cEstCod := substr(aMunNFe[nI]:_CMUNDESCARGA:TEXT,1,2)
			    	cMunCod := substr(aMunNFe[nI]:_CMUNDESCARGA:TEXT,3,len(aMunNFe[nI]:_CMUNDESCARGA:TEXT))
			    	cMunDesc := aMunNFe[nI]:_XMUNDESCARGA:TEXT
			    	If ValType(aMunNFe[nI]:_INFNFE) == "A"

			    		//Pego  todas as notas deste municipio
			       		For nJ := 1 to len(aMunNFe[nI]:_INFNFE)
			       			aAdd(aChvsNFe,{cEstCod,cMunCod,cMunDesc,aMunNFe[nI]:_INFNFE[nJ]:_CHNFE:TEXT})
			       		Next nJ
			    	Else
				    	aAdd(aChvsNFe,{cEstCod,cMunCod,cMunDesc,aMunNFe[nI]:_INFNFE:_CHNFE:TEXT})
			    	EndIf
			    Next nI
			ElseIf lMDFePost .And. !Empty(ValType(aMunNfe)) .And. SubStr(cPoster,1,1) == "1" //1-Sim
				cEstCod := substr(aMunNFe:_CMUNDESCARGA:TEXT,1,2)
		    	cMunCod := substr(aMunNFe:_CMUNDESCARGA:TEXT,3,len(aMunNFe:_CMUNDESCARGA:TEXT))
		    	cMunDesc := aMunNFe:_XMUNDESCARGA:TEXT
			Else
		    	//Pego o nome e o codigo do municipio'
		    	cEstCod := substr(aMunNFe:_CMUNDESCARGA:TEXT,1,2)
		    	cMunCod := substr(aMunNFe:_CMUNDESCARGA:TEXT,3,len(aMunNFe:_CMUNDESCARGA:TEXT))
		    	cMunDesc := aMunNFe:_XMUNDESCARGA:TEXT
		    	If ValType(aMunNFe:_INFNFE) == "A"

		    		//Pego  todas as notas deste municipio
		       		For nJ := 1 to len(aMunNFe:_INFNFE)
		       			aAdd(aChvsNFe,{cEstCod,cMunCod,cMunDesc,aMunNFe:_INFNFE[nJ]:_CHNFE:TEXT})
		       		Next nJ
		    	Else
			    	aAdd(aChvsNFe,{cEstCod,cMunCod,cMunDesc,aMunNFe:_INFNFE:_CHNFE:TEXT})
		    	EndIf
			EndIf
		EndIf

		//Monta o array de percurso
		aColsCiot := {}
	   	If ValType(aCiot) <> "U"
		   	If ValType(aCiot) == "A"
			   	For nI := 1 to len(aCiot)
				   	cIndice := allTrim(Str(nI))
					cCIOT := aCiot[nI]:_CIOT:TEXT
					cContrat := ""
					if mdfeType("aCiot["+cIndice+"]:_CNPJ") <> "U"
						cContrat := aCiot[nI]:_CNPJ:TEXT
					elseIf mdfeType("aCiot["+cIndice+"]:_CPF") <> "U"
						cContrat := aCiot[nI]:_CPF:TEXT
					endif
			   		aAdd(aColsCiot,{cCIOT,FormatCpo("CGC",cContrat),.F.})
			   	Next nI
			Else
				cCIOT := aCiot:_CIOT:TEXT
				cContrat := ""
				if mdfeType("aCiot:_CNPJ") <> "U"
					cContrat := aCiot:_CNPJ:TEXT
				elseif mdfeType("aCiot:_CPF") <> "U"
					cContrat := aCiot:_CPF:TEXT
				endif
				aAdd(aColsCiot,{cCIOT,FormatCpo("CGC",cContrat),.F.})
			EndIf
		EndIf
		If Len(aColsCiot) == 0
			aColsCiot := GetNewLine(aHeadCiot, .T.)
		EndIf

		If lInfPag .And. ValType(aPgtos) <> "U" .and. type("oDlgPgt") == "O"
			If ValType(aPgtos) <> "A"
				aPgtos := {aPgtos}
			EndIf
			oDlgPgt:setInfPag(aPgtos)
		EndIf

		//Vale-pedagio
		aColsValPed := {}
		If type("aValPed") <> "U"
			aValPed := iif(type("aValPed")=="A",aValPed,{aValPed})

			for nI := 1 to len(aValPed)
				cIndice		:= allTrim(Str(nI))
				cCgc 		:= Padr("",15)
				cNumCompra	:= Padr("",20)
				cTpValePed	:= " "

				if mdfeType("aValPed[" + cIndice + "]:_CPFPg") == "O" .and. !empty(aValPed[nI]:_CPFPg:TEXT)
					cCgc := aValPed[nI]:_CPFPg:TEXT

				elseif mdfeType("aValPed[" + cIndice + "]:_CNPJPg") == "O" .and. !empty(aValPed[nI]:_CNPJPg:TEXT)
					cCgc := aValPed[nI]:_CNPJPg:TEXT
				endIf
				
				if mdfeType("aValPed[" + cIndice + "]:_nCompra") == "O" .and. !empty(aValPed[nI]:_nCompra:TEXT)
					cNumCompra := aValPed[nI]:_nCompra:TEXT
				endIf

				if mdfeType("aValPed[" + cIndice + "]:_tpValePed") == "O" .and. !empty(aValPed[nI]:_tpValePed:TEXT)
					cTpValePed := allTrim(str(val(aValPed[nI]:_tpValePed:TEXT)))
				endIf

				aAdd(aColsValPed, {	aValPed[nI]:_CNPJForn:TEXT		,;
									FormatCpo("CGC",cCgc)			,;
									cNumCompra						,;
									val(aValPed[nI]:_vValePed:TEXT)	,;
									cTpValePed						,;
									 .F.							})
			next
		endIf
		If Len(aColsValPed) == 0
			aColsValPed := GetNewLine(aHeadValPed, .T.)
		EndIf

		//Seguro
		LoadXmlSeg(oXML)

		// Contratantes do serviço de transporte
		LoadInfCtr(oXML)
		
		//Carrega os condutores
		LoadCondutores(oXML)

		//Carrega os reboques
		LoadReboque(oXML)

		LoadTRB(nOpc)
	EndIf

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} ResetVars
Inicializa as variaveis com valores nulos

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function ResetVars()
	aHeadMun	:= GetHeaderMun()
	aHeadPerc	:= GetHeaderPerc()
	aHeadAuto	:= GetHeaderAuto()
	aHeadLacre	:= GetHeaderLacre()
	aHeadCiot	:= GetHeaderCiot()
	cNumMDF		:= Space(TamSx3('CC0_NUMMDF')[1])			//Variavel que contem o numero do MDFE
	cSerMDF		:= Space(TamSx3('CC0_SERMDF')[1])			//Variavel que contem a Serie do MDFE
	cUFCarr		:= Space(TamSx3('CC0_UFINI')[1])			//Variavel que contem a UF de Carregamento
	cUFDesc		:= Space(TamSx3('CC0_UFFIM')[1])			//Variavel que contem a UF de Descarregamento
	cUFCarrAux	:= Space(TamSx3('CC0_UFINI')[1])			//Variavel Auxiliar (para controle alteracoes) que contem a UF de Carregamento
	cUFDescAux	:= Space(TamSx3('CC0_UFFIM')[1])			//Variavel Auxiliar (para controle alteracoes) que contem a UF de Descarregamento
	cVTotal		:= Space(TamSx3('CC0_VTOTAL')[1])			//Variavel que contem o valor total da carga/mercadoria
	cVeiculo	:= Space(TamSx3('DA3_COD')[1])				//Variavel que contem o valor total da carga/mercadoria
	cVeiculoAux	:= Space(TamSx3('DA3_COD')[1])				//Variavel que contem o valor total da carga/mercadoria
	cCarga		:= Space(TamSx3('DAK_COD')[1])				//Variavel que contem o código da carga
	cMotorista  := iif(lMotori,Space(TamSx3('CC0_MOTORI')[1]),nil)			//Variavel que contem o código do motorista
	nQtNFe		:= 0										//Variavel que contem a Quantidade total de NFe
	nVTotal		:= 0										//Variavel que contem a Valor total de notas
	nPBruto		:= 0										//Variavel que contem a Peso total do MDF-e
	cInfCpl		:= ""
	cInfFsc		:= ""
	aColsMun	:= GetNewLine(aHeadMun)
	aColsPerc	:= GetNewLine(aHeadPerc)
	aColsAuto	:= GetNewLine(aHeadAuto)
	aColsLacre	:= GetNewLine(aHeadLacre)
	aColsCiot	:= GetNewLine(aHeadCiot,.T.)
	aColsValPed	:= GetNewLine(aHeadValPed,.T.)
	aChvsNFe	:= aSize(aChvsNFe,0)
	aChvsNFe	:= {}
	cVVTpCarga	:= ""
	cPPcProd	:= space( getSx3Cache( "B1_COD", "X3_TAMANHO") ) // CriaVar("B1_COD")
	cPPxProd	:= space( getSx3Cache( "B1_DESC", "X3_TAMANHO") ) // CriaVar("B1_DESC")
	cPPCodbar	:= space( getSx3Cache( "B1_CODBAR", "X3_TAMANHO") ) // CriaVar("B1_CODBAR")
	cPPNCM		:= space( getSx3Cache( "B1_POSIPI", "X3_TAMANHO") ) // CriaVar("B1_POSIPI")
	cPPCEPCarr	:= space( getSx3Cache( "A1_CEP", "X3_TAMANHO") ) // CriaVar("A1_CEP")
	cPPCEPDesc	:= space( getSx3Cache( "A1_CEP", "X3_TAMANHO") ) // CriaVar("A1_CEP")
	
	cNumVoo     := space(9)
	dDatVoo     := sToD("")
	cAerOrig    := space(4)
	cAerDest    := space(4)
	
	ClearInfPag()
	ClearInfSeg()
	ClearInfCtr()
	ClearCondutor()
	ClearReboque()
	
Return

Static Function GetMDeInfo(oXMLStru,cNode)
	Local xRet := oXMLStru
    Local aBusca := StrTokArr(cNode,":")
    Local nI := 1

    For nI := 1 to len(aBusca)
		xRet := XmlChildEx(xRet,aBusca[nI])

		If ValType(xRet) == "U"
		     exit
		EndIf
	Next nI

Return xRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LoadNomeMun
Carrega o nome do municipio a partir do codigo recebido Exibe a dialog com
o municipio de carregamento da NF

@author Natalia Sartori
@since 10/02/2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function LoadNomeMun(cCodMun,cNomMun,cEstMun)
	Local aArea := CC2->(GetArea())
	Local lRet := .F.

	dbSelectArea('CC2')
	CC2->(dbSetOrder(1))
	If CC2->(dbSeek(xFilial('CC2')+cUFDesc+cCodMun))
   		cNomMun := CC2->CC2_MUN
		cEstMun := cUFDesc
		lRet := .T.
	Else
		cCodMun := Space(TamSx3("CC2_CODMUN")[1])
		cNomMun := Space(TamSx3("CC2_MUN")[1])
		MsgInfo( STR0756 + cUFDesc) //Codigo de Municipio não localizado para a UF: 
		lRet := .F.
	EndIf
	oGetDesMun:Refresh()
	RestArea(aArea)
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} RefreshMainObjects
Atualiza os principais componentes graficos da tela principal (Main)

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function RefreshMainObjects()

	If ValType(oMsSel) == "O"
		oMsSel:oBrowse:Refresh()
		oGetQtNFe:Refresh()
		oGetPBruto:Refresh()
		oGetVTot:Refresh()
		oGetNfeFil:Refresh()
		oCombo:Refresh()
		If lMDFePost
			oCombo2:Refresh()
		EndIf
		If lModal
			oCombo3:Refresh()
		EndIf

	EndIf

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GetHeaderMun
Retorna um array com as colunas a serem exibidas na GetDados de Municipio
Carregamento

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function GetHeaderMun()
	Local aArea	     := GetArea()
	Local aRet       := {}
	Local aCampos    := {"CC2_CODMUN","CC2_EST","CC2_MUN"}
	Local nI		 := 1

	//Posiciona no SX3
	SX3->(dbSetOrder(2))
	For nI := 1 to len(aCampos)
		If !Empty(FWSX3Util():GetFieldType( aCampos[nI]) )
			aAdd( aRet,{  TRIM(FwX3Titulo(aCampos[nI])),;
				aCampos[nI]							  ,;
				GetSx3Cache(aCampos[nI], "X3_PICTURE"),;
				GetSx3Cache(aCampos[nI], "X3_TAMANHO"),;
				GetSx3Cache(aCampos[nI], "X3_DECIMAL"),;
				iif(  aCampos[nI] == "CC2_CODMUN", "MunTrigger()", ".T."),;
				GetSx3Cache(aCampos[nI], "X3_USADO" ) ,;
				GetSx3Cache(aCampos[nI], "X3_TIPO"  ) ,;
				iif(  aCampos[nI] == "CC2_CODMUN", "CC2", GetSx3Cache(aCampos[nI], "X3_F3")),;
				GetSx3Cache(aCampos[nI], "X3_CONTEXT"),;
				GetSx3Cache(aCampos[nI], "X3_CBOX"   ),;
				GetSx3Cache(aCampos[nI], "X3_RELACAO"),;
				iif(  aCampos[nI] == "CC2_CODMUN", "MunTrigger()", ".T."),;
				GetSx3Cache(aCampos[nI], "X3_VISUAL" ),;
				GetSx3Cache(aCampos[nI], "X3_VLDUSER"),;
				GetSx3Cache(aCampos[nI], "X3_PICTVAR")})
		EndIf
	Next nI

	RestArea(aArea)
Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GetNewLine
Realiza o carregamento da 1 linha da aLinhas em branco na aCols

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function GetNewLine(aHeader, lSemDic)
	Local aRet   := {}
	Local aArea  := getArea()
	Local nI	 := 0

	Default lSemDic := .F.

	//Cria um linha do aLinhas em branco
	aAdd(aRet, Array( Len(aHeader)+1 ) )

	For nI := 1 To Len(aHeader)
		if allTrim(upper(aHeader[nI][2])) $ "MDFECGC"
			aRet[Len(aRet),nI] := space(aHeader[nI][4])
		//elseIf lSemDic
		else
			If aHeader[nI][8] == "N" //Numericos
				aRet[Len(aRet),nI] := 0
			ElseIf aHeader[nI][8] == "D"
				aRet[Len(aRet),nI] := cTod("  /  /    ")
			Else //Caracter
				aRet[Len(aRet),nI] := space(aHeader[nI][4])
			EndIf
		//else
		//	aRet[Len(aRet),nI] := criaVar(alltrim(aHeader[nI,2]))
		endIf
	Next nI

	//Atribui .F. para a coluna que determina se alinha do aLinhas esta deletada
	aRet[Len(aRet)][Len(aHeader)+1] := .F.

	RestArea(aArea)
Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} MunTrigger
Gatilha o nome do municipio de acordo com o o codigo digitado na GetDados
Carregamento

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Function MunTrigger()
	Local aArea := GetArea()
	Local lRet := .F.

	If !Empty(M->CC2_CODMUN)
		dbSelectArea('CC2')
		CC2->(dbSetOrder(1))
		If CC2->(dbSeek(xFilial('CC2')+cUFCarr+M->CC2_CODMUN))
			oGetDMun:aCols[oGetDMun:nAt,2] := CC2->CC2_EST
			oGetDMun:aCols[oGetDMun:nAt,3] := CC2->CC2_MUN
			oGetDMun:oBrowse:Refresh()
			oGetDMun:Refresh()
			lRet := .T.
		Else
			MsgStop(STR0759 + cUFCarr + STR0761) //Este municipio não esta localizado dentro a UF: , definido como UF de Carregamento do MDFe
			lRet := .F.
		EndIf
	Else
		oGetDMun:aCols[oGetDMun:nAt,2] := Space(TamSx3('CC2_EST')[1])
		oGetDMun:aCols[oGetDMun:nAt,3] := Space(TamSx3('CC2_MUN')[1])
		oGetDMun:oBrowse:Refresh()
		oGetDMun:Refresh()
		lRet := .T.
	EndIf

	RestArea(aArea)
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GetHeaderAuto
Retorna um array com as colunas a serem exibidas na GetDados de Autorizados

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
static function GetHeaderAuto()
	local aArea	     := GetArea()
	local aRet       := {}

	aadd(aRet,{	"CNPJ/CPF",;				//X3Titulo()
				"MDFeCGC",;					//X3_CAMPO
				"@R 99.999.999/9999-99",;	//X3_PICTURE
				14,;						//X3_TAMANHO
				0,;							//X3_DECIMAL
				"",;						//X3_VALID
				"",;						//X3_USADO
				"C",;						//X3_TIPO
				"",; 						//X3_F3
				"R",;						//X3_CONTEXT
				"",;						//X3_CBOX
				"",;						//X3_RELACAO
				"",;						//X3_WHEN
				"",;						//X3_VISUAL
				"",;						//X3_VLDUSER
				"PictAuto()"})				//X3_PICTVAR
RestArea(aArea)
return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} PictAuto
Seleciona picture do campo MDFeCGC de acordo com o documento informado: CPF ou CNPJ

@author Jonatas Almeida
@since 29.06.2016
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
function PictAuto()
	Local cMask := "@R 99.999.999/9999-99%C"
	Local cConteudo := ""

	oGetDAut:acols[oGetDAut:nat][1] := padr(oGetDAut:acols[oGetDAut:nat][1],aHeadAuto[1][4])
	cConteudo := oGetDAut:acols[oGetDAut:nat][1]

	if(!Empty(cConteudo))
		cConteudo := strTran(cConteudo,".","")
		cConteudo := strTran(cConteudo,"-","")
		cConteudo := strTran(cConteudo,"/","")

		if(len(allTrim(cConteudo)) <= 11)
			cMask := "@R 999.999.999-999999%C"
		else
			cMask := "@R 99.999.999/9999-99%C"
		endIf
	else
		oGetDAut:acols[oGetDAut:nat][1] := Space(aHeadAuto[1][4])
	endIf
return cMask

//----------------------------------------------------------------------
/*/{Protheus.doc} GetHeaderPerc
Retorna um array com as colunas a serem exibidas na GetDados de Percurso

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function GetHeaderPerc()
	Local aArea	     := GetArea()
	Local aRet       := {}
	Local aCampos	 :=  {"CC2_EST"}
	Local nI		 := 1

	For nI := 1 to len(aCampos)
		If !Empty(FWSX3Util():GetFieldType( aCampos[nI]) )
			aAdd( aRet,{  TRIM(FwX3Titulo(aCampos[nI])),;
				aCampos[nI]							  ,;
				GetSx3Cache(aCampos[nI], "X3_PICTURE"),;
				GetSx3Cache(aCampos[nI], "X3_TAMANHO"),;
				GetSx3Cache(aCampos[nI], "X3_DECIMAL"),;
				iif(  aCampos[nI] == "CC2_EST", "ValidUfMDF(M->CC2_EST)", GetSx3Cache(aCampos[nI], "X3_VALID")),;
				GetSx3Cache(aCampos[nI], "X3_USADO" ) ,;
				GetSx3Cache(aCampos[nI], "X3_TIPO"  ) ,;
				iif(  aCampos[nI] == "CC2_EST", "12", GetSx3Cache(aCampos[nI], "X3_F3")),;
				GetSx3Cache(aCampos[nI], "X3_CONTEXT"),;
				GetSx3Cache(aCampos[nI], "X3_CBOX"   ),;
				GetSx3Cache(aCampos[nI], "X3_RELACAO"),;
				".T.",;
				GetSx3Cache(aCampos[nI], "X3_VISUAL" ),;
				GetSx3Cache(aCampos[nI], "X3_VLDUSER"),;
				GetSx3Cache(aCampos[nI], "X3_PICTVAR")})
		EndIf
	Next nI

	RestArea(aArea)
Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GetHeaderLacre
Retorna um array com as colunas a serem exibidas na GetDados de Percurso

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function GetHeaderLacre()
	Local aArea	     := GetArea()
	Local aRet       := {}
	Local aCampos    := {"DVB_LACRE"}
	Local nI		 := 1

	For nI := 1 to len(aCampos)
		If !Empty(FWSX3Util():GetFieldType( aCampos[nI]) )
			aAdd( aRet,{ TRIM(FwX3Titulo(aCampos[nI])),;
				aCampos[nI]							  ,;
				GetSx3Cache(aCampos[nI], "X3_PICTURE"),;
				GetSx3Cache(aCampos[nI], "X3_TAMANHO"),;
				GetSx3Cache(aCampos[nI], "X3_DECIMAL"),;
				".T.",;
				GetSx3Cache(aCampos[nI], "X3_USADO"  ),;
				GetSx3Cache(aCampos[nI], "X3_TIPO"   ),;
				GetSx3Cache(aCampos[nI], "X3_F3"     ),;
				GetSx3Cache(aCampos[nI], "X3_CONTEXT"),;
				GetSx3Cache(aCampos[nI], "X3_CBOX"   ),;
				GetSx3Cache(aCampos[nI], "X3_RELACAO"),;
				".T.",;
				GetSx3Cache(aCampos[nI], "X3_VISUAL" ),;
				GetSx3Cache(aCampos[nI], "X3_VLDUSER"),;
				GetSx3Cache(aCampos[nI], "X3_PICTVAR")})
		EndIf	
	Next nI

	RestArea(aArea)
Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeSetRec
Realiza a inclusao do novo MDFe no banco de dados

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function MDFeSetRec(nOpc, aDados)
	Local lRet		:= .F.
	default aDados	:= {}

	If (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5)
		MsgRun(STR0980 ,STR0534 ,{|| lRet := MDFeNewRec(.F.,nOpc, @aDados ) }) // "Validando dados de Manifestação" # "Aguarde"
	Else
		lRet := .T.
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeNewRec
Montagem do wizard de transmissão do MDFe

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Function MDFeNewRec(lAuto, nOpc, aDados)
	Local cTpNrNfs		:= SuperGetMV("MV_TPNRNFS",,"1")
	Local lRet 			:= .F.
	Local cMsg			:= ""
	Local cXML			:= ""
	Local lErpHverao	:= GetNewPar("MV_HVERAO",.F.) // Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
	Local lVldOk		:= .T.

	default aDados := {}

	Private cNumero		:= ""
	Private cSerie 		:= ""
	Private dDataEmi	:= Date()
	Private cTime		:= FwTimeUF(Upper(Left(LTrim(SM0->M0_ESTENT),2)),,lErpHVerao)[2]
	Private cTZD 		:= Substr(Alltrim(FwGMTByUF(Upper(Left(LTrim(SM0->M0_ESTENT),2)),lErpHverao)), 1, 6 )//***Define TZD***
	Default lAuto		:= .F.

	//Define a mensagem de alerta ao usuario
	if nOpc == 3
		cMsg := 'Confirma a inclusão de novo MDF-e'
	ElseIf nOpc == 4
		cMsg := 'Confirma a alteracao do MDF-e'
	ElseIf nOpc == 5
		cMsg := 'Confirma a exclusão do MDF-e'
	EndIf

	//Processa a operação
	If tssHasRdm("XmlMDFeSef")
		If !lAuto
			If !Empty(cUFCarr) .and. !Empty(cUFDesc) .and. !Empty(cVeiculo)
				If nQtNFe > 0 .OR. SubStr(cPoster,1,1) == "1" //"1-Sim"
					If VldMdfeOK(nOpc, nQtNFe)
						If SubStr(cPoster,1,1) == "1" //#"1-Sim"
							ShowNFs(nOpc,.T.)
							MarcaNF(nOpc)
						EndIf

						If MsgYesNo(cMsg)

							//PE para validacao do formulario
							If ExistBlock("MDFeOk")
								lVldOk := ExecBlock("MDFeOk",.F.,.F.,{nOpc,cUFCarr,cUFDesc,cVeiculo,cPoster})
							EndIf

							If lVldOk

								aDados := {}

								//Inclusao
								If nOpc == 3
									If Sx5NumNota(@cSerie,cTpNrNfs)
										
										cXML := tssExecRdm("XmlMDFeSef",.F., xFilial('CC0'))[2]

										aAdd(aDados,{"CC0_FILIAL"	,	cFilAnt				})
										aAdd(aDados,{"CC0_SERMDF"	,	cSerie				})
										aAdd(aDados,{"CC0_NUMMDF"	,	cNumero				})
										aAdd(aDados,{"CC0_TPNF"		,	cEntSai				})
										aAdd(aDados,{"CC0_DTEMIS"	,	DtoS (dDataEmi)		})
										aAdd(aDados,{"CC0_HREMIS"	,	cTime				})
										aAdd(aDados,{"CC0_UFINI"	,	cUFCarr				})
										aAdd(aDados,{"CC0_UFFIM"	,	cUFDesc				})
										aAdd(aDados,{"CC0_QTDNFE"	,	nQtNFe				})
										aAdd(aDados,{"CC0_VTOTAL"	,	nVTotal				})
										aAdd(aDados,{"CC0_STATUS"	, 	NAO_TRANSMITIDO 	})
										aAdd(aDados,{"CC0_PESOB"	,	nPBruto				})
										aAdd(aDados,{"CC0_VEICUL"	,	cVeiculo			})
										aAdd(aDados,{"CC0_XMLMDF"	,	cXML				})
										aAdd(aDados,{"CC0_CODRET"	,	SubStr(cNfeFil,1,1)	})
										If lMotori
											aAdd(aDados,{"CC0_MOTORI"	,	cMotorista			})
										EndIf
										If lMDFePost
											aAdd(aDados,{"CC0_CARPST",	iif( SubStr(cPoster,1,1) == "1","1","2") }) //#"1-Sim"
										EndIf

										If lModal
											aAdd(aDados,{"CC0_MODAL",	iif( SubStr(cModal,1,1) == "1","1","2") })
										EndIf
										
										//If CC0->(FieldPos("CC0_CARGA")) > 0 \\Não está no dicinonário de dados aguardando replica da Issue - LOGTMS01-652
											//aAdd(aDados,{"CC0_CARGA"	,	cCarga         	})
										//EndIf
										
										lRet := .T.

									EndIf

								//Alteracao
								ElseIf nOpc == 4
									cSerie := CC0->CC0_SERMDF
									cNumero := CC0->CC0_NUMMDF
									
									cXML := tssExecRdm("XmlMDFeSef",.F., xFilial('CC0'))[2]

									aAdd(aDados,{"CC0_FILIAL"	,	cFilAnt				})
									aAdd(aDados,{"CC0_SERMDF"	,	cSerie				})
									aAdd(aDados,{"CC0_NUMMDF"	,	cNumero				})
									aAdd(aDados,{"CC0_TPNF"		,	cEntSai				})
									aAdd(aDados,{"CC0_DTEMIS"	,	DtoS(Date())		})
									aAdd(aDados,{"CC0_HREMIS"	,	Time()				})
									aAdd(aDados,{"CC0_UFINI"	,	cUFCarr				})
									aAdd(aDados,{"CC0_UFFIM"	,	cUFDesc				})
									aAdd(aDados,{"CC0_QTDNFE"	,	nQtNFe				})
									aAdd(aDados,{"CC0_VTOTAL"	,	nVTotal				})
									aAdd(aDados,{"CC0_STATUS"	, 	NAO_TRANSMITIDO 	})
									aAdd(aDados,{"CC0_PESOB"	,	nPBruto				})
									aAdd(aDados,{"CC0_VEICUL"	,	cVeiculo			})
									aAdd(aDados,{"CC0_XMLMDF"	,	cXML				})
									aAdd(aDados,{"CC0_CODRET"	,	SubStr(cNfeFil,1,1)	})
									If lMotori
										aAdd(aDados,{"CC0_MOTORI"	,	cMotorista			})
									EndIf
									If lMDFePost
										aAdd(aDados,{"CC0_CARPST",	iif( SubStr(cPoster,1,1) == "1","1","2") }) //#"1-Sim"
									EndIf
									
									If lModal
										aAdd(aDados,{"CC0_MODAL",	iif( SubStr(cModal,1,1) == "1","1","2") })
									EndIf

									lRet := .T.

								//Exclusao
								ElseIf nOpc == 5

									//Remove TODAS as marcacoes anteriores deste manifesto na SF2
									cSerie := CC0->CC0_SERMDF
									cNumero := CC0->CC0_NUMMDF
									lRet := DelMDFSF2(cSerie,cNumero,nOpc) .Or. (lMDFePost .And. CC0->CC0_CARPST == "1") //1 - Carrega Posterior Sim

									//Apaga da CC0
									If !lRet
										MsgStop( STR0762 ) //Não foi possível remover o vínculo entre o MDF-e e o(s) documento(s) vinculado(s).
									EndIf
								EndIf
							EndIf

						Else
							lRet := .F.
						EndIf
					EndIf
				Else
					MsgStop( STR0763 ) //Ao menos 1 documento do tipo NF-e deve ser marcado para elaboração do manifesto
					lRet := .F.
				EndIf
			Else
				MsgStop( STR0764 ) //Um ou mais campos obrigatorios nao foram preenchidos.
				lRet := .F.
			EndIf
		Else
			//Tratamento automatico nao implementado - SIGA3286
		EndIF
	Else
		Help(NIL, NIL,STR0639, NIL, STR0637, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0638})
		//STR0637:	Problema:	"Fonte de geração do MDF-e não compilado."
		//STR0638:	Solução:	"Acesse o portal do cliente, baixe o fonte MDFESEFAZ.PRW e compile em seu ambiente"
		//STR0639: "Fonte não compilado"
		lRet := .F.
	EndIf
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} RecInCC0
Inclui um novo registro de manifesto na CC0

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function RecInCC0(nOpc, aDados)
	Local nI		:= 1
	Local lRet		:= .T.
	local cTpNf		:= cEntSai
	local cTpNrNfs	:= SuperGetMV("MV_TPNRNFS",,"1")
	local nPos		:= 0
	local cNumero	:= ""
	local cSerie	:= ""
	local lInclui	:= .F.

	default aDados		:= {}

	if nOpc == 5
		if RecLock('CC0',.F.)
			CC0->(dbDelete())
			CC0->(msUnlock())
		endif
	else
		if len(aDados) > 0 

			nPos := aScan( aDados , { |X| alltrim(X[1]) == "CC0_NUMMDF"})
			if nPos > 0
				cNumero := aDados[nPos][2]
			endif

			nPos := aScan( aDados , { |X| alltrim(X[1]) == "CC0_SERMDF"})
			if nPos > 0
				cSerie := aDados[nPos][2]
			endif

			lInclui := nOpc == 3

			//Grava na Tabela
			Begin Transaction

			if RecLock("CC0",lInclui)
				For nI := 1 to len(aDados)
					CC0->(FieldPut(FieldPos(aDados[nI][1]),aDados[nI][2]))
				Next nI
				CC0->(msUnlock())
			endif
			lRet := .T.

			if nOpc == 3
				// Controle de numeracao por SD9
				if cTpNrNfs == "3"
					//Confirma o uso da numeracao do SX5 e SD9
					MA461NumNf(.T.,cSerie,"")
				else
					//Confirma o uso da numeracao do SX5
					NxtSX5Nota(cSerie,.T.,cTpNrNfs)
				endif

				if ( __lSX8 )
					ConfirmSX8()
				endif

			else
				//Remove TODAS as marcacoes anteriores deste manifesto na SF2
				DelMDFSf2(cSerie,cNumero,4)
			endif

			//Atualiza notas na SF2, com o codigo do Manifesto
			AtuSF2(cSerie,cNumero,nOpc, @cTpNf)
			//Atualiza tipo de nf da MDF-e para melhor exibição nos filtros iniciais
			if RecLock("CC0",.F.)
				CC0->CC0_TPNF := cTpNf
				CC0->(msUnlock())
			endif

			End Transaction
			
			//Tratamento paliativo para não travar tela de numeração de notas (SX5) em outras rotinas do Protheus
			//simulteneamente, devido a tratamento errado na função NxtSX5Nota() 
			If !InTransact() 
				SX5->(MsRUnLock())
				SX6->(MsRUnLock())
			EndIf

		endif

	endif

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} AtuSF2
Atualiza as notas da SF2 que foram contempladas no manifesto recem criado

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function AtuSF2(cSerMDF,cNumMDF, nOpc, cTpNf)
    Local lRet		:= .F.
	Local cFilMDF	:= SUPERGETMV("MV_FILMDFE", .F., "")
    Local lFilDMDF2 := SF2->(ColumnPos("F2_"+cFilMDF)) > 0
	Local lFilDMDF1 := SF1->(ColumnPos("F1_"+cFilMDF)) > 0
	Local lTemEntrad:= .F.
	Local lTemSaida	:= .F.

    Default cSerMDF := ""          
    Default cNumMDF := ""

	if !Empty(cSerMDF) .and. !Empty(cNumMDF)
		dbSelectArea('TRB')
		TRB->(dbGoTop())
		While TRB->(!Eof())
			//Verifica se a nota esta marcada
			If !Empty(TRB->TRB_MARCA)

				If TRB->TRB_TPNF == "S"
					//Localiza a nota marcada na SF2
					dbSelectArea('SF2')
					SF2->(dbSetOrder(2))
					If SF2->(dbSeek(TRB->TRB_FILIAL + TRB->TRB_CODCLI + TRB->TRB_LOJCLI + TRB->TRB_DOC + TRB->TRB_SERIE ))
						lTemSaida := .T.
						RecLock('SF2',.F.)
						SF2->F2_SERMDF := cSerMDF
						SF2->F2_NUMMDF := cNumMDF						
						If !Empty(cFilMDF)  .and. lFilDMDF2
						  SF2->&("F2_"+cFilMDF) := xFilial("CC0")																		
						Endif 
						SF2->(msUnlock())
						lRet := .T.
					EndIf
				Else
					//Localiza a nota marcada na SF1
					dbSelectArea('SF1')
					SF1->(dbSetOrder(1))	
					If SF1->(dbSeek(TRB->TRB_FILIAL + TRB->TRB_DOC + TRB->TRB_SERIE + TRB->TRB_CODCLI + TRB->TRB_LOJCLI ))
						lTemEntrad := .T.
						RecLock('SF1',.F.)
						SF1->F1_SERMDF := cSerMDF
						SF1->F1_NUMMDF := cNumMDF						
						If !Empty(cFilMDF) .and. lFilDMDF1
						  SF1->&("F1_"+cFilMDF) := xFilial("CC0")																		
						Endif 						
						SF1->(msUnlock())
						lRet := .T.
					EndIf
				EndIf

			EndIf
			TRB->(dbSkip())
		EndDo

	EndIf
	IF SubStr(cPoster,1,1) == "1" //#"1Sim"
		lRet := .T.
	EndIf
	TRB->(dbGoTop())

	If ExistBlock("TRBMDFe")
		ExecBlock("TRBMDFe",.F.,.F.,{nOpc,cSerMDF,cNumMDF})
	EndIf

	//Para marcar corretamente o tipo de NF dentro da MDF-e (a ser exibido nos filtros)
	If lTemEntrad .And. lTemSaida
		cTpNf := "3"
	ElseIf lTemSaida
		cTpNf := "1"
	ElseIf lTemEntrad
		cTpNf := "2"
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} DelMDFSf2
Remove todos os registros do MDF passado como parametro da SF2

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function DelMDFSf2(cSerie,cNumero,nOpc)
    Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local aArea	 := GetArea()
	Local lRet	 := .F.

	Default nOpc := 2

	lFilDMDF2 := SF2->(ColumnPos("F2_"+cFilMDF)) > 0 
	lFilDMDF1 := SF1->(ColumnPos("F1_"+cFilMDF)) > 0  

	if(cEntSai == "1") // - *** NFe Saida ***
		dbSelectArea('SF2')
		#IFDEF TOP		           
			cQuery := "SELECT " 
			If !Empty(cFilMDF) .And. lFilDMDF2  
				cQuery += "SF2.F2_"+cFilMDF+","
			EndiF 
			cQuery += "SF2.R_E_C_N_O_ RECN FROM " + RetSqlName('SF2') + " SF2 "
			cQuery += " WHERE SF2.F2_SERMDF = '" + cSerie + "' "			
			cQuery += " 	AND SF2.F2_NUMMDF = '" + cNumero + "' "
			cQuery += " 	AND SF2.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
			While (cAlias)->(!Eof())
				SF2->(dbGoTo((cAlias)->RECN)) 
				IF !lFilDMDF2 .Or. (lFilDMDF2 .And. !Empty(cFilMDF) .And. SF2->&("F2_"+cFilMDF) == xFilial('CC0'))
					If RecLock('SF2',.F.)
						SF2->F2_SERMDF := ""
						SF2->F2_NUMMDF := ""
						If lFilDMDF2 .And. !Empty(cFilMDF)
							SF2->&("F2_"+cFilMDF) := ""
						EndIf
						SF2->(msUnlock())
						lRet := .T.
					EndIf
				EndIf
			(cAlias)->(dbSkip())
			EndDo
		#ELSE
			SF2->(dbSetOrder(1))
			SF2->(dbGoTop())
			While SF2->(!Eof())
				If SF2->F2_FILIAL = xFilial('SF2') .and. ;
					SF2->F2_SERMDF = cSerie .and. ;
					SF2->F2_NUMMDF = cNumero .and.;
					IIF(!Empty(cFilMDF) .and. lFilDMDF2,SF2->&("F2_"+cFilMDF) == CC0->CC0_FILIAL ,.T.)

					RecLock('SF2',.F.)
					SF2->F2_SERMDF := ""
					SF2->F2_NUMMDF := ""
					If !Empty(cFilMDF) .And. lFilDMDF2
						SF2->&("F2_"+cFilMDF) := ""
					EndIF
					SF2->(msUnlock())
					lRet := .T.
				EndIf
				SF2->(dbSkip())
			EndDo
		#ENDIF

	ElseIF cEntSai == "2" // - *** NFe Entrada***
		dbSelectArea('SF1')
		#IFDEF TOP
			cQuery := "SELECT " 
			If !Empty(cFilMDF) .And. lFilDMDF1  
				cQuery += " SF1.F1_"+cFilMDF+","
			EndiF 
			cQuery += " SF1.R_E_C_N_O_ RECN FROM " + RetSqlName('SF1') + " SF1"
			cQuery += " WHERE SF1.F1_SERMDF = '" + cSerie + "'"
			cQuery += " AND SF1.F1_NUMMDF = '" + cNumero + "'"
			cQuery += " AND SF1.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
			While (cAlias)->(!Eof())
				SF1->(dbGoTo((cAlias)->RECN))
				If !lFilDMDF1 .Or. (lFilDMDF1 .And. !Empty(cFilMDF) .And. SF1->&("F1_"+cFilMDF) == xFilial('CC0'))
					If RecLock('SF1',.F.)
						SF1->F1_SERMDF := ""
						SF1->F1_NUMMDF := ""
						If lFilDMDF1 .And. !Empty(cFilMDF)
							SF1->&("F1_"+cFilMDF) := ""
						EndIf
						SF1->(msUnlock())
						lRet := .T.
					EndIf
				EndIf
				(cAlias)->(dbSkip())
			EndDo

		#ELSE
			SF1->(dbSetOrder(1))
			SF1->(dbGoTop())
			While SF1->(!Eof())
				If SF1->F1_FILIAL = xFilial('SF1') .and. ;
					SF1->F1_SERMDF = cSerie .and. ;
					SF1->F1_NUMMDF = cNumero .and.;
					IIF(!Empty(cFilMDF) .and. lFilDMDF1,SF1->&("F1_"+cFilMDF) == CC0->CC0_FILIAL ,.T.)

					RecLock('SF1',.F.)
					SF1->F1_SERMDF := ""
					SF1->F1_NUMMDF := ""
					If !Empty(cFilMDF) .And. lFilDMDF1					
						SF1->&("F1_"+cFilMDF) := ""
					EndIF
					SF1->(msUnlock())
					lRet := .T.
				EndIf
				SF1->(dbSkip())
			EndDo
		#ENDIF
	Else
		dbSelectArea('SF1')
		dbSelectArea('SF2')
		#IFDEF TOP
			cQuery := "SELECT"
			If lFilDMDF1 .And. !Empty(cFilMDF)
				cQuery += " SF1.F1_"+cFilMDF+","
			EndiF 
			cQuery += " SF1.R_E_C_N_O_ RECN FROM " + RetSqlName('SF1') + " SF1"
			cQuery += " WHERE SF1.F1_SERMDF = '" + cSerie + "'"			
			cQuery += " AND SF1.F1_NUMMDF = '" + cNumero + "'"
			cQuery += " AND SF1.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
			
			While (cAlias)->(!Eof())
				SF1->(dbGoTo((cAlias)->RECN))
				If !lFilDMDF1 .Or. (lFilDMDF1 .And. !Empty(cFilMDF) .And. SF1->&("F1_"+cFilMDF) == xFilial('CC0'))
					If RecLock('SF1',.F.)
						SF1->F1_SERMDF := ""
						SF1->F1_NUMMDF := ""
						If lFilDMDF1 .And. !Empty(cFilMDF)
							SF1->&("F1_"+cFilMDF) := ""
						EndIf
						SF1->(msUnlock())
						lRet := .T.
					EndIf
				EndIF
				(cAlias)->(dbSkip())
			EndDo

			cQuery := "SELECT"
			If lFilDMDF2 .And. !Empty(cFilMDF)
				cQuery += " SF2.F2_"+cFilMDF+","
			EndiF 
			cQuery += " SF2.R_E_C_N_O_ RECN FROM " + RetSqlName('SF2') + " SF2"
			cQuery += " WHERE SF2.F2_SERMDF = '" + cSerie + "'"
			cQuery += " AND SF2.F2_NUMMDF = '" + cNumero + "'"
			cQuery += " AND SF2.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
			While (cAlias)->(!Eof())
				SF2->(dbGoTo((cAlias)->RECN))
				If !lFilDMDF2 .Or. (lFilDMDF2 .And. !Empty(cFilMDF) .And. SF2->&("F2_"+cFilMDF) == xFilial('CC0'))
					If RecLock('SF2',.F.)
						SF2->F2_SERMDF := ""
						SF2->F2_NUMMDF := ""
						If lFilDMDF2 .And. !Empty(cFilMDF)
							SF2->&("F2_"+cFilMDF) := ""
						EndIf
						SF2->(msUnlock())					
						lRet := .T.
					EndIf
				EndIf
				(cAlias)->(dbSkip())
			EndDo

		#ELSE
			SF2->(dbSetOrder(1))
			SF2->(dbGoTop())
			While SF2->(!Eof())
				If SF2->F2_FILIAL = xFilial('SF2') .and. ;
					SF2->F2_SERMDF = cSerie .and. ;
					SF2->F2_NUMMDF = cNumero .and.;
					IIF(!Empty(cFilMDF) .and. lFilDMDF2,SF2->&("F2_"+cFilMDF) == CC0->CC0_FILIAL ,.T.)

					RecLock('SF2',.F.)
					SF2->F2_SERMDF := ""
					SF2->F2_NUMMDF := ""
					If !Empty(cFilMDF) .And. lFilDMDF2
						SF2->&("F2_"+cFilMDF) := ""
					EndIF
					SF2->(msUnlock())
					lRet := .T.
				EndIf
				SF2->(dbSkip())
			EndDo

			SF1->(dbSetOrder(1))
			SF1->(dbGoTop())
			While SF1->(!Eof())
				If SF1->F1_FILIAL = xFilial('SF1') .and. ;
					SF1->F1_SERMDF = cSerie .and. ;
					SF1->F1_NUMMDF = cNumero .and.;
					IIF(!Empty(cFilMDF) .and. lFilDMDF1,SF1->&("F1_"+cFilMDF) == CC0->CC0_FILIAL ,.T.)

					RecLock('SF1',.F.)
					SF1->F1_SERMDF := ""
					SF1->F1_NUMMDF := ""
					If !Empty(cFilMDF) .And. lFilDMDF1
						SF1->&("F1_"+cFilMDF) := ""
					EndIF
					SF1->(msUnlock())
					lRet := .T.
				EndIf
				SF1->(dbSkip())
			EndDo
		#ENDIF
	endIf

	// Caso não tenha nenhum documento vinculado com o MDFe, deixar excluir o registro.
	lRet := iif(Select(cAlias)>0 .and. (cAlias)->(eof()) .and. (cAlias)->(bof()),lRet := .T.,lRet)

	If ExistBlock("TRBMDFe")
		ExecBlock("TRBMDFe",.F.,.F.,{nOpc,cSerMDF,cNumMDF}) 
	EndIf

	RestArea(aArea)
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GetUfSig

Montagem do wizard de transmissão do MDFe

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function GetUfSig(cCod,lForceUF)
	Local aUF			:= {}
	Local nPos			:= 0
	Local cSigla		:= ""
	DEFAULT lForceUF	:= .F.

	//Preenchimento do Array de UF
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})

	nPos := aScan(aUF,{|x| x[1] == cCod})
	If nPos == 0
		nPos := aScan(aUF,{|x| x[2] == cCod})
		If nPos <> 0
			cSigla := aUF[nPos][1]
		EndIf
	Else
		cSigla := aUF[nPos][IIF(!lForceUF,2,1)]
	EndIf

Return cSigla

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeTrans

Montagem do wizard de transmissão do MDFe

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Static Function MDFeTrans ()

Local aArea			:= GetArea()
Local aPerg			:= {}
Local aParam		:= {Space(Len(CC0->CC0_SERMDF)),Space(Len(CC0->CC0_NUMMDF)),Space(Len(CC0->CC0_NUMMDF))}
Local aTexto		:= {}
Local aXML			:= {}
Local cVersTSS		:= ""
Local cRetorno		:= ""
Local cAmbiente		:= ""
Local cModalidade	:= ""
Local cVerLeiEve	:= ""
Local cVerLeiaut	:= ""
Local cVersaoMdf	:= ""
Local cHoraVeraoMdfe:= ""
Local cHorarioMdfe	:= ""
Local cParMFFeRe	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDMDFEREM"
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMonitorSEF	:= ""
Local cSugestao		:= ""
Local oWizard     	:= nil
Local nX         	:= 0
Local lOk			:= .T.
Local lRetorno		:= .F.
Local lUsaColab		:= UsaColaboracao("5")

MV_PAR01 := aParam[01] := PadR(ParamLoad(cParMFFeRe,aPerg,1,aParam[01]),Len(CC0->CC0_SERMDF))
MV_PAR02 := aParam[02] := PadR(ParamLoad(cParMFFeRe,aPerg,2,aParam[02]),Len(CC0->CC0_NUMMDF))
MV_PAR03 := aParam[03] := PadR(ParamLoad(cParMFFeRe,aPerg,3,aParam[03]),Len(CC0->CC0_NUMMDF))

aadd(aPerg,{1,STR0479,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie do MDFe"
aadd(aPerg,{1,STR0480,aParam[02],"",".T.","",".T.",30,.T.})	//"MDFe inicial"
aadd(aPerg,{1,STR0481,aParam[03],"",".T.","",".T.",30,.T.})	//"MDFe final"

If CTIsReady(,,,lUsaColab)
	If !Empty(cIdEnt)

		If lUsaColab

			lOk := ColParValid(("MDF"),@cRetorno)

			If lOk
				cAmbiente		:= ColGetPar("MV_AMBMDF","0")+" - " +ColDescOpcao("MV_AMBMDF", ColGetPar("MV_AMBMDF","2") )
				cModalidade	:= ColGetPar("MV_MODMDF","1")+" - " +ColDescOpcao("MV_MODMDF", ColGetPar("MV_MODMDF","1") )
				cVersaoMdf		:= ColGetPar("MV_VERMDF","3.00")
				cVerLeiaut		:= ColGetPar("MV_VLAYMDF","3.00")
				cVerLeiEve		:= ColGetPar("MV_EVENMDF","3.00")
				cHoraVeraoMdfe:= ColGetPar("MV_HRVERAO","2")
				cHorarioMdfe	:= ColGetPar("MV_HORARIO","2")//1-Fernando de Noronha; 2-Brasília ;3-Manaus e 4-Acre

				cMonitorSEF += "- MDFe"+CRLF
				cMonitorSEF += STR0017+cVersaoMdf+CRLF	//"Versao do layout: "
				cMonitorSEF += STR0129+": "+cVerLeiaut+CRLF	//"Versão da mensagem: "
			Else
				Aviso("MDF-e",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
			EndIf

		Else

			oWS :=  WsSpedCfgNFe():New()
			oWS:cUSERTOKEN 		:= "TOTVS"
			oWS:cID_ENT    		:= cIdEnt
			oWS:nAmbienteMDFE  	:= 0
			oWS:cVersaoMDFE 	:= "0.00"
			oWS:nModalidadeMDFE := 0
			oWS:cVERMDFELAYOUT	:= "0.00"
			oWS:cVERMDFELAYEVEN	:= "0.00"
			oWS:nSEQLOTEMDFE  	:= 0
			oWS:cHORAVERAOMDFE	:= "0"
			oWS:cHORARIOMDFE		:= "0"
	   		oWS:_URL       		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
			lOk:= oWS:CFGMDFE()

			cAmbiente		:= oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
			cModalidade		:= oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE
			cVerLeiEve		:= oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN
			cVerLeiaut		:= oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT
			cVersaoMdf		:= oWS:OWSCFGMDFERESULT:CVERSAOMDFE
			cHoraVeraoMdfe	:= oWS:OWSCFGMDFERESULT:CHORAVERAOMDFE
			cHorarioMdfe  	:= oWS:OWSCFGMDFERESULT:CHORARIOMDFE

			//Verifica o status na SEFAZ
			If lOk
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
				if type("oWS:oWSMODELOS") <> "U" //status da sefaz por modelo
					oWS:oWSMODELOS:OWSMODDOCS := NFESBRA_ARRAYOFMODDOC():NEW()
					aadd(oWS:oWSMODELOS:OWSMODDOCS:OWSMODDOC, NFESBRA_MODDOC():New())
					Atail(oWS:oWSMODELOS:OWSMODDOCS:OWSMODDOC):CMODELO := "58"
				endIf
				lOk := oWS:MONITORSEFAZMODELO()
				If lOk
					aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO

					For nX := 1 To Len(aXML)
							Do Case
								Case aXML[nX]:cModelo == "58"
									cMonitorSEF += "- MDFe"+CRLF
									cMonitorSEF += STR0017+cVersaoMdf+CRLF	//"Versao do layout: "
									If !Empty(aXML[nX]:cSugestao)
										cSugestao += STR0125+"(MDFe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugestão"
									EndIf

									cMonitorSEF += Space(6)+STR0129+": "+aXML[nX]:cVersaoMensagem+CRLF //"Versão da mensagem"
									cMonitorSEF += Space(6)+STR0120+": "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF //"Código do Status"
					                cMonitorSEF += Space(6)+STR0121+": "+aXML[nX]:cUFOrigem //"UF Origem"
					                If !Empty(aXML[nX]:cUFResposta)
						                cMonitorSEF += "("+aXML[nX]:cUFResposta+")"+CRLF //"UF Resposta"
						   			Else
						   				cMonitorSEF += CRLF
						   			EndIf
					                If aXML[nX]:nTempoMedioSEF <> Nil
										cMonitorSEF += Space(6)+STR0071+": "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF //"Tempo de espera"
									EndIf
									If !Empty(aXML[nX]:cMotivo)
										cMonitorSEF += Space(6)+STR0123+": "+aXML[nX]:cMotivo+CRLF //"Motivo"
									EndIf
									If !Empty(aXML[nX]:cObservacao)
										cMonitorSEF += Space(6)+STR0124+": "+aXML[nX]:cObservacao+CRLF //"Observação"
									EndIf
							EndCase
					Next nX

				EndIf
			EndIf
		EndIf

		//Montagem da Interface
		If (lOk == .T. .or. lOk == Nil)
			aadd(aTexto,{})
			If lUsaColab
				aTexto[1] := STR0493+" " 		//"Esta rotina tem como objetivo auxilia-lo na geração do arquivo do Manifesto Eletrônico de Documentos Fiscais para transmissão via TOTVS Colaboração."
				aTexto[1] += STR0494+CRLF+CRLF 	//"Neste momento o sistema, está operando com a seguinte configuração: "
				cVersTSS 	:= " TC2.0 "		//"Vesão - TSS ou TC2.0"
			Else
				aTexto[1] := STR0482+" " 		//"Esta rotina tem como objetivo auxilia-lo na transmissão do Manifesto Eletrônico de Documentos Fiscais para o serviço TSS
				aTexto[1] += STR0014+CRLF+CRLF 	//"Neste momento o Totvs Services SPED, está operando com a seguinte configuração: "
				cVersTSS		:= " TSS: " + getVersaoTSS()
			EndIf

			aTexto[1] += STR0015+cAmbiente+CRLF 	//"Ambiente: "
			aTexto[1] += STR0016+cModalidade+CRLF	//"Modalidade de emissão: "
			aTexto[1] += STR0037+cVersTSS+CRLF		//"Vesão - TSS ou TC2.0"
			If !Empty(cSugestao)
				aTexto[1] += CRLF
				aTexto[1] += cSugestao
				aTexto[1] += CRLF
			EndIf
			aTexto[1] += cMonitorSEF

			aadd(aTexto,{})
	 		oWizard := APWizard():New( /*HEADER*/ STR0019,/*MESSAGE*/STR0484,/*TITLE*/STR0483,aTexto[1],{||.T.},{||.T.},.F., , , )
 			@ 010,010 GET aTexto[1] MEMO SIZE 280, 125 READONLY PIXEL OF oWizard:oMPanel[1]

			CREATE PANEL oWizard	;
				HEADER STR0483	 ;//"Assistente de transmissão do Manifesto Eletrônico de Documentos Fiscais"
				MESSAGE "" ;
				BACK {|| .T.} ;
				NEXT {|| ParamSave(cParMFFeRe,aPerg,"1"),Processa({|lEnd| cRetorno := MDFeRemes(aArea[1],aParam[1],aParam[2],aParam[3],cIdEnt,SubStr(cAmbiente,1,1),SubStr(cModalidade,1,1),cVersaoMdf,cURL,@lEnd,cHoraVeraoMdfe,cHorarioMdfe)}),aTexto[02]:= cRetorno,.T.};
				PANEL
		    ParamBox(aPerg,"MDF-e",@aParam,,,,,,oWizard:oMPanel[2],cParMFFeRe,.T.,.T.)

			CREATE PANEL oWizard  ;
				HEADER STR0483;//"Assistente de transmissão do Manifesto Eletrônico de Documentos Fiscais"
				MESSAGE "";
				BACK {|| .T.};
				FINISH {|| .T.};
				PANEL
			@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
			ACTIVATE WIZARD oWizard CENTERED
		EndIf
		lRetorno := lOk

		//Recarrega a list
		ReloadListDocs()
	Else
		lRetorno := .F.
	EndIf
Else
	Aviso("MDF-e",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

RestArea(aArea)
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeRemes

Regras para chamada do método remessa

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	Nil
/*/
//-----------------------------------------------------------------------
Function MDFeRemes(cAlias,cSerie,cNotaIni,cNotaFim,cIDEnt,cAmbiente,cModalidade,cVersao,cURL,lEnd,cHoraVeraoMdfe,cHorarioMdfe)

Local aArea				:= GetArea()
Local aNotas			:= {}
Local aXML				:= {}
Local aRetNotas			:= {}
Local aNFeCol			:= {}
Local cAliasCC0			:= "CC0"
Local cQuery			:= ""
Local cHoraIni			:= Time()
Local cXml				:= ""
Local cErro				:= ""
local cAviso			:= ""
Local cDV				:= ""
Local cTpEmis			:= ""
Local cChave			:= ""
Local cCodMod			:= ""
Local cSerieMDF			:= ""
Local cNumero			:= ""
Local nX				:= 0
Local nY				:= 0
Local nNFes				:= 0
Local nXmlSize			:= 0
Local nXmlSize2			:= 0
Local lHVerao			:= .F.
Local lErpHverao		:= GetNewPar("MV_HVERAO",.F.)	// Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local cTimeRem			:= ""
Local cTZD 				:= ""
Local dDataIni			:= Date()
Local cChvQrCode		:= ""
Local lRetorno			:= .T.
Local lUsaColab	 		:= UsaColaboracao("5")
Local lTagProduc 		:= date() >= CTOD("01/07/2019") .or. cAmbiente == '2'

Private oXmlRem      	:= nil

Default cHoraVeraoMdfe 	:= "2"
Default cHorarioMdfe 	:= ""

//Controle TZD Fuso Horário versao: 3.00
if (cVersao >= __cVersao)
	lHVerao := Iif("1" $ cHoraVeraoMdfe/*1-Sim ### 2-Nao*/,.T.,.F.)
	cTZD	 := Substr(Alltrim(FwGMTByUF(Upper(Left(LTrim(SM0->M0_ESTENT),2)),lHVerao)), 1, 6 )//***Define TZD***
EndIf

IF lHVerao
	lErpHVerao := .T.
EndIf
cTimeRem := FwTimeUF(Upper(Left(LTrim(SM0->M0_ESTENT),2)),,lErpHVerao,,lHVerao)[2] //FwTimeUF(cUF,,lTssHverao,,lHVerao)

If cModalidade == '1'
	cTpEmis := '1'
ElseIf cModalidade == '2'
	cTpEmis := '2'
EndIf

dbSelectArea("CC0")
CC0->(dbSetOrder(1))

#IFDEF TOP
	lQuery    	:= .T.
	cAliasCC0	:= GetNextAlias()

	cQuery := "SELECT CC0_FILIAL, CC0_SERMDF, CC0_NUMMDF, CC0_STATUS, CC0_DTEMIS"
	cQuery += " FROM " + RetSqlName('CC0') + " CC0"
	cQuery += " WHERE CC0_FILIAL = '" + xFilial('CC0') + "' AND"
	cQuery += " CC0_SERMDF = '" + Alltrim(cSerie) + "' AND"
	cQuery += " CC0_NUMMDF >= '" + cNotaIni + "' AND"
	cQuery += " CC0_NUMMDF <= '" + cNotaFim + "' AND"
	cQuery += " CC0_STATUS <> '" + TRANSMITIDO + "' AND"
	cQuery += " CC0_STATUS <> '" + AUTORIZADO + "' AND"
	cQuery += " CC0_STATUS <> '" + CANCELADO + "' AND"
	cQuery += " CC0_STATUS <> '" + ENCERRADO + "' AND"
	cQuery += " D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasCC0, .F., .T.)

	While !Eof() .And. xFilial("CC0") == (cAliasCC0)->CC0_FILIAL .And.;
		alltrim((cAliasCC0)->CC0_SERMDF) == Alltrim(cSerie) .And.;
		(cAliasCC0)->CC0_NUMMDF >= cNotaIni .And.;
		(cAliasCC0)->CC0_NUMMDF <= cNotaFim

		IncProc("(1/2) "+STR0485+(cAliasCC0)->CC0_NUMMDF) //"Preparando MDFe: "

		aadd(aNotas,{})
		nX := Len(aNotas)
		aadd(aNotas[nX],(cAliasCC0)->CC0_FILIAL)
		aadd(aNotas[nX],(cAliasCC0)->CC0_SERMDF)
		aadd(aNotas[nX],(cAliasCC0)->CC0_NUMMDF)
		aadd(aNotas[nX],(cAliasCC0)->CC0_DTEMIS)

		If CC0->(dbSeek( xFilial("CC0") + (cAliasCC0)->CC0_SERMDF + (cAliasCC0)->CC0_NUMMDF))
			aadd(aNotas[nX],(CC0->CC0_XMLMDF))
		EndIf

		(cAliasCC0)->(DbSkip())
	EndDo
	(cAliasCC0)->(DbCloseArea())

#ELSE
	CC0->(dbGoTop())

	MsSeek(xFilial("CC0")+cSerie+cNotaIni,.T.)

	While !Eof() .And. xFilial("CC0") == CC0->CC0_FILIAL .And.;
		alltrim(CC0->CC0_SERMDF) == Alltrim(cSerie) .And.;
		CC0->CC0_NUMMDF >= cNotaIni .And.;
		CC0->CC0_NUMMDF <= cNotaFim .And.;
		CC0->CC0_STATUS <> TRANSMITIDO .And. ;
		CC0->CC0_STATUS <> AUTORIZADO .And. ;
		CC0->CC0_STATUS <> ENCERRADO .And. ;
		CC0->CC0_STATUS <> CANCELADO

		IncProc("(1/2) "+STR0485+ CC0->CC0_NUMMDF) //"Preparando MDFe: "

		aadd(aNotas,{})
		nX := Len(aNotas)
		aadd(aNotas[nX],CC0->CC0_FILIAL)
		aadd(aNotas[nX],CC0->CC0_SERMDF)
		aadd(aNotas[nX],CC0->CC0_NUMMDF)
		aadd(aNotas[nX],CC0->CC0_DTEMIS)
		aadd(aNotas[nX],CC0->CC0_XMLMDF)

		CC0->(DbSkip())
	EndDo

#ENDIF

ProcRegua(Len(aNotas))

If lUsaColab
	oDoc := ColaboracaoDocumentos():new()
	oDoc:cModelo 	:= "MDF"
	oDoc:cTipoMov	:= "1"
Else
	oWs:= WsNFeSBra():New()
	oWs:cUserToken	:= "TOTVS"
	oWs:cID_ENT		:= cIdEnt
	oWS:_URL			:= AllTrim(cURL)+"/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS	:=  NFeSBRA_ARRAYOFNFeS():New()
EndIf

For nX := 1 To Len(aNotas)

	cXml := aNotas[nX][5] //Pega xml da tabela para realizar alterações antes do envio

	If !lTagProduc .And. At("<infMDFeSupl>",cXml) > 0
		cXml := StrTran(cXml, SubStr(cXml, At("<infMDFeSupl>",cXml), At("</infMDFeSupl>",cXml) - At("<infMDFeSupl>",cXml) + 14), "")
	EndIf	

	oXmlRem := XmlParser(cXml,"_",@cErro,@cAviso)

	If mdfeType("oXmlRem:_MDFE:_INFMDFE")<>"U"

		//Tratamento para nao alterar a chave e outros dados toda transmissão ja que a mesma é montada na inclusao/alteração
		If !(oXmlRem:_MDFE:_INFMDFE:_IDE:_TPEMIS:TEXT == cTpEmis) .Or. Len(AllTrim(SubStr(oXmlRem:_MDFE:_INFMDFE:_ID:TEXT,5))) <> 44
			cDV		:= cTpEmis + oXmlRem:_MDFE:_INFMDFE:_IDE:_CMDF:TEXT
			cChave	:= MDFeChave(	oXmlRem:_MDFE:_INFMDFE:_IDE:_CUF:TEXT,;
									FsDateConv(StoD(aNotas[nX][04]),"YYMM"),AllTrim(SM0->M0_CGC),'58',;
									StrZero(Val(aNotas[nX][02]),3),;
									StrZero(Val(aNotas[nX][03]),9),;
									cDV )

			oXmlRem:_MDFE:_INFMDFE:_IDE:_CMDF:TEXT		:= substr(cDV,2,8)
			oXmlRem:_MDFE:_INFMDFE:_IDE:_TPEMIS:TEXT	:= cTpEmis
			oXmlRem:_MDFE:_INFMDFE:_IDE:_CDV:TEXT		:= SubStr( AllTrim(cChave), Len( AllTrim(cChave) ), 1)
			oXmlRem:_MDFE:_INFMDFE:_ID:TEXT				:= "MDFe"+cChave
		else
			cChave := SUbStr(oXmlRem:_MDFE:_INFMDFE:_ID:TEXT,5)
		EndIf

		oXmlRem:_MDFE:_INFMDFE:_VERSAO:TEXT := cVersao
		oXmlRem:_MDFE:_INFMDFE:_IDE:_TPAMB:TEXT := cAmbiente
		oXmlRem:_MDFE:_INFMDFE:_IDE:_DHEMI:TEXT := SubStr(oXmlRem:_MDFE:_INFMDFE:_IDE:_DHEMI:TEXT,1,19)+cTZD
		oXmlRem:_MDFE:_INFMDFE:_INFMODAL:_VERSAOMODAL:TEXT := cVersao

		If mdfeType("oXmlRem:_MDFE:_INFMDFESUPL")<>"U"
			If lTagProduc
				cChvQrCode := AllTrim(oXmlRem:_MDFE:_INFMDFESUPL:_qrCodMDFe:text)

				If At("&tpAmb=", cChvQrCode) > 0 //Caso ja tenha seido informado anteriormente
					cChvQrCode := SubStr(cChvQrCode,1,At("chMDFe=",cChvQrCode)+6)
				Else
					cChvQrCode := Alltrim(oXmlRem:_MDFE:_INFMDFESUPL:_qrCodMDFe:text)
				EndIf
				oXmlRem:_MDFE:_INFMDFESUPL:_qrCodMDFe:text := AllTrim(cChvQrCode)+cChave+'&tpAmb='+Alltrim(cAmbiente)
			EndIf
		EndIf
		
		cCodMod := (oXmlRem:_MDFE:_INFMDFE:_IDE:_MOD:TEXT)

		If CC0->(dbSeek( xFilial("CC0") + aNotas[nX][02] + aNotas[nX][03]))
			RecLock("CC0")
			CC0->CC0_XMLMDF:= XMLSaveStr(oXmlRem)
			CC0->(MsUnlock())
		EndIf

		aXML:= XMLSaveStr(oXmlRem)

	EndIf

	nXmlSize2 := Len(aXML)

	If !Empty(aXML) .And. nXmlSize2 <= TAMMAXXML
		If nXmlSize + Len(aXML) <= TAMMAXXML
			nY++
			nNFes++
			nXmlSize += Len(aXML)

			If lUsaColab

				cSerieMDF		:= aNotas[nX][2]
				cNumero 	:= aNotas[nX][3]
				//Adicionando no aNFe para manter o padrao das funcoes SpedCCeXml e ColEnvEvento
				aNFeCol := {}
				aAdd(aNFeCol,"" ) 			//01 - em branco
				aAdd(aNFeCol,cSerieMDF) 	//02 - Serie
				aAdd(aNFeCol,cNumero) 		//03 - Numero
				aAdd(aNFeCol,"")			//04 - em branco
				aAdd(aNFeCol,"")			//05 - em branco

				lRetorno := XmlMDFTrans( aNFeCol, aXML, cCodMod, @cErro, "110110" )

			Else
				aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())

				aadd(aRetNotas,aNotas[nX])

				oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cID := aNotas[nX][2]+aNotas[nX][3]    //Serie + Numero
				oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cXML:= aXML
			EndIf
		Else
			If lUsaColab
				lRetorno := XmlRemMDF( aNotas, aXML, oXmlRem, @cErro )
			Else
				lRetorno := RemessaMDF(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL)
				If !lRetorno
					Exit
				EndIf
				nX -- //- Diminui o contador para que seja pego a nota corrente
				Loop
			EndIf
		EndIF
	ElseIf !Empty(aXML) .And. nXmlSize2 > TAMMAXXML
		Aviso("MDF-e",STR0149+CRLF+CRLF+STR0150+aNotas[nX][2]+" / "+aNotas[nX][3],{STR0114},3)
		nXmlSize2 := 0
	EndIf
	If ((nY >=50 .Or. nX == Len(aNotas) .Or. nXmlSize>=TAMMAXXML) .And. nNFes > 0) .And. !lUsaColab
		lRetorno:= RemessaMDF(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL)
	EndIf
Next nX

If lRetorno
	If lUsaColab
		cRetorno := STR0491+CRLF //"Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += STR0495+CRLF+CRLF //"Verifique se os arquivos foram processados e autorizados na SEFAZ via TOTVS Colaboração, utilizando a rotina 'Monitor'. Antes de imprimir o DAMDFE."
	Else
		cRetorno := STR0026+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
		cRetorno += STR0487+CRLF+CRLF //"Verifique se os Manifestos foram autorizadas na SEFAZ, utilizando a rotina 'Monitorar'. Antes de imprimir o DAMDFE."
	EndIf
	cRetorno += STR0488+AllTrim(Str(nNFes,18))+STR0489+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidos "###" manifestos em"
	cRetorno += cErro
Else
	If lUsaColab
		cRetorno := STR0490+CRLF+CRLF //"Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."
	Else
		cRetorno := STR0030+CRLF+CRLF //"Houve erro durante a transmissão para o Totvs Services SPED."
	EndIf
	cRetorno += cErro
EndIf

RestArea(aArea)

Return (cRetorno)

//----------------------------------------------------------------------
/*/{Protheus.doc} RemessaMDF

Envio da remessa ao TSS

@author Natalia Sartori
@since 24.02.2014
@version P11
@Return	lRet
/*/
//-----------------------------------------------------------------------
Function RemessaMDF(oWs,cErro,aRetNotas,nTotNf,nXmlSize,cIdEnt,cURL)

Local nY
Local lRetorno := .T.

If nXmlSize>0 .And. oWs:Remessa()
	If Len(oWs:oWsRemessaResult:oWSID:cString) <> nTotNF
		cErro := STR0486+CRLF+CRLF //"Os Manifestos abaixo foram recusados, verifique a rotina 'Monitor' para saber os motivos."
	EndIf
	For nY := 1 To Len(aRetNotas)
		If Len(oWs:oWsRemessaResult:oWSID:cString) <> nY
			If aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][2]+aRetNotas[nY][3])==0
				cErro += "MDFe: "+aRetNotas[nY][2]+aRetNotas[nY][3]+CRLF
			EndIf
		EndIf
		dbSelectArea("CC0")
		dbSetOrder(1)
 			If MsSeek(xFilial("CC0")+aRetNotas[nY][2]+aRetNotas[nY][3]) .And. CC0->CC0_STATUS $ "2,4" //2- Não Transmitidos - 4-Não Autorizados
			RecLock("CC0")
			CC0->CC0_STATUS := IIF(aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][2]+AllTrim(aRetNotas[nY][3]))==0,NAO_AUTORIZADO,TRANSMITIDO) //4-Não Autorizados - 1-Transmitidos
			MsUnlock()
		EndIf
	Next nY


	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
	nTotNF := 0
	nXmlSize := 0
	aRetNotas := {}
Else
	cErro := GetWscError(3)
	DEFAULT cErro := STR0025 //"Erro indeterminado"
	lRetorno := .F.
EndIf

Return lRetorno


//----------------------------------------------------------------------
/*/{Protheus.doc} GetlabelTSS
Obtem a versão do TSS

@author Natalia Sartori
@since 25.02.2014
@version P11
@Return	cVersaoTSS - Versão do TSS
/*/
//-----------------------------------------------------------------------
Function GetlabelTSS ()

Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cVersaoTSS	:= ""

Local lOK	:= .F.
Local lUsaColab := UsaColaboracao("5")

if !lUsaColab

	//Obtem a versao do TSS - Totvs Services SPED
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	lOk := oWs:CfgTSSVersao()
	If lOk
		cVersaoTSS:=oWs:cCfgTSSVersaoResult
	EndIf
Else
	cVersaoTSS := "TC2.0"
endif

Return cVersaoTSS


//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeChave

Função responsável em montar a Chave de Acesso e calcular
o seu digito verIficador

@Natalia Sartori
@since 25.02.2014
@version 1.00

@param      	cUF...: Codigo da UF
				cAAMM.: Ano (2 Digitos) + Mes da Emissao do MDFe
				cCNPJ.: CNPJ do Emitente do MDFe
				cMod..: Modelo (58 = MDFe)
				cSerie: Serie do MDFe
				nCT...: Numero do MDFe
				cDV...: Numero do Lote de Envio a SEFAZ
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeChave(cUF, cAAMM, cCNPJ, cMod, cSerie, nMDF, cDV)

Local nCount      := 0
Local nSequenc    := 2
Local nPonderacao := 0
Local cResult     := ''
Local cChvAcesso  := cUF +  cAAMM + iif(len(cCNPJ) == 14, cCNPJ, PADL(cCNPJ,14,"0")) + cMod + cSerie + nMDF + cDV

//SEQUENCIA DE MULTIPLICADORES (nSequenc), SEGUE A SEGUINTE
//ORDENACAO NA SEQUENCIA: 2,3,4,5,6,7,8,9,2,3,4... E PRECISA SER
//GERADO DA DIREITA PARA ESQUERDA, SEGUINDO OS CARACTERES
//EXISTENTES NA CHAVE DE ACESSO INFORMADA (cChvAcesso)
For nCount := Len( AllTrim(cChvAcesso) ) To 1 Step -1
	nPonderacao += ( Val( SubStr( AllTrim(cChvAcesso), nCount, 1) ) * nSequenc )
	nSequenc += 1
	If (nSequenc == 10)
		nSequenc := 2
	EndIf
Next nCount

//Quando o resto da divisão for 0 (zero) ou 1 (um), o DV devera ser igual a 0 (zero).
If ( mod(nPonderacao,11) > 1)
	cResult := (cChvAcesso + cValToChar( (11 - mod(nPonderacao,11) ) ) )
Else
	cResult := (cChvAcesso + '0')
EndIf

Return(cResult)

//-----------------------------------------------------------------------
/*/{Protheus.doc} MDFeMonit
Monitoramento do MDFe

@author Natalia Sartori
@since 10/02/2014
@version P11
/*/
//-----------------------------------------------------------------------
Function MDFeMonit(cSerie,cNotaIni,cNotaFim,lMDFe,cModel)

Local cIdEnt	:= ""
Local cMonMdfe	:= ""
Local aPerg 	:= {}
Local aParam	:= {Space(Len(CC0->CC0_SERMDF)),Space(Len(CC0->CC0_NUMMDF)),Space(Len(CC0->CC0_NUMMDF))}
Local aSize 	:= {}
Local aObjects	:= {}
Local aList		:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"MONMDFE"
Local lOK        := .F.
Local lUsaColab  := UsaColaboracao("5")
Local bBloco

Default cSerie   := ''
Default cNotaIni := ''
Default cNotaFim := ''
Default lMDFe    := .T.
Default cModel	 := ""

aadd(aPerg,{1,STR0479,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie do MDFe"
aadd(aPerg,{1,STR0480,aParam[02],"",".T.","",".T.",30,.T.})	//"MDFe inicial"
aadd(aPerg,{1,STR0481,aParam[03],"",".T.","",".T.",30,.T.})	//"MDFe final"

aParam[01] := ParamLoad(cParNfeRem,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeRem,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeRem,aPerg,3,aParam[03])

If CTIsReady(,,,lUsaColab)
	//Obtem o codigo da entidade
	cIdEnt := RetIdEnti(lUsaColab)
	If !Empty(cIdEnt)
		//Instancia a classe
		If !Empty(cIdEnt)
			If (lMDFe) .And. !Empty(cSerie) .And. !Empty(cNotaIni) .And. !Empty(cNotaFim)
				aParam[01] := cSerie
				aParam[02] := cNotaIni
				aParam[03] := cNotaFim
				lOK        := .T.
			Else
				lOK      := ParamBox(aPerg,"MDF-e",@aParam,,,,,,,cParNfeRem,.T.,.T.)
				cSerie   := aParam[01]
				cNotaIni := aParam[02]
				cNotaFim :=	aParam[03]
			EndIf

			If (lOK)

				if lUsaColab
					cMonMdfe := "ColMdfMon"
					bBloco := "{|| " + cMonMdfe + "(cSerie,cNotaIni,cNotaFim,.T.) }"
				else
					cMonMdfe := "MDFeWSMnt"
					bBloco := "{|| " + cMonMdfe + "(cIdEnt,cSerie,cNotaIni,cNotaFim,.T.) }"
				endif

				aList:= Eval(&bBloco)

				If !Empty(aList)
					//Atualiza os dados da CC0 com o monitor
					UpdCC0(aList)

					aSize := MsAdvSize()
					aObjects := {}
					AAdd( aObjects, { 100, 100, .t., .t. } )
					AAdd( aObjects, { 100, 015, .t., .f. } )

					aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj := MsObjSize( aInfo, aObjects )

					DEFINE MSDIALOG oDlg TITLE cCadastro + " - " + STR0009 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

					@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "",STR0049,STR0035,STR0036,STR0050,STR0051,STR0052,STR0053; //"NF"###"Ambiente"###"Modalidade"###"Protocolo"###"Recomendação"###"Tempo decorrido"###"Tempo SEF"
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
					oListBox:SetArray( aList )
					oListBox:bLine := { || { aList[ oListBox:nAT,1 ],aList[ oListBox:nAT,2 ],aList[ oListBox:nAT,3 ],aList[ oListBox:nAT,4 ],aList[ oListBox:nAT,5 ],aList[ oListBox:nAT,6 ],aList[ oListBox:nAT,7 ],aList[ oListBox:nAT,8 ]} }


					@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT STR0114   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"
					@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn2 PROMPT STR0054   		ACTION (Bt2NFeMnt(aList[oListBox:nAT][09])) OF oDlg PIXEL SIZE 035,011 //"Mensagens"
					@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT STR0055   		ACTION (Bt3NFeMnt(cIdEnt,aList[ oListBox:nAT,2 ],,lUsaColab)) OF oDlg PIXEL SIZE 035,011 //"Rec.XML"
					@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT STR0118 		ACTION (aList:= Eval(&bBloco),oListBox:nAt := 1,IIF(Empty(aList),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
					@ aPosObj[2,1],aPosObj[2,4]-200 BUTTON oBtn4 PROMPT STR0115  		ACTION (Bt3NFeMnt(cIdEnt,aList[ oListBox:nAT,2 ],2,lUsaColab)) OF oDlg PIXEL SIZE 035,011 //"Schema"
					ACTIVATE MSDIALOG oDlg

					//Apos sair, atualiza novamente os dados na CC0, pois pode ter clicado em REFRESH
					aList:= Eval(&bBloco)
					UpdCC0(aList)

					//Atualiza o grid da tela "Gerenciar MDFe"
					ReloadListDocs()
				Else
					MsgStop( STR0765 ) //Nenhum documento localizado no intervalo informado
				EndIf
			EndIf
		EndIf
	Else
		Aviso("MDF-e", STR0021, {STR0114}, 3) //Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!, OK
	EndIf
Else
	Aviso("MDF-e", STR0021, {STR0114}, 3) //Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!, OK
EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} Bt3NFeMnt
Função que faz validação de schema do XML da NFe.

@author Henrique Brugugnoli
@since 26/01/2011
@version 1.0

@param	cIdEnt	Codigo da entidade
		cIdNFe	Id da NFe que será feito a validação de schema

@return	.T.
/*/
//-----------------------------------------------------------------------
Static Function Bt3NFeMnt(cIdEnt,cIdNFe,nTipo,lUsaColab)

Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMsg     := ""

Local oWS
Local oDoc := Nil

DEFAULT nTipo  := 1
DEFAULT lUsaColab := .F.

if !lUsaColab
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt
	oWS:oWSNFEID          := NFESBRA_NFES2():New()
	oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := cIdNfe
	oWS:nDIASPARAEXCLUSAO := 0
	oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

	If oWS:RETORNANOTAS()
		If Len(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
			If nTipo == 1
				Do Case
					Case oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA <> Nil
						Aviso("MDF-e",oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML,{STR0114},3)
					OtherWise
						Aviso("MDF-e",oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML,{STR0114},3)
				EndCase
			Else
				cMsg := AllTrim(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML)

				If !Empty(cMsg)
					Aviso("MDF-e",@cMsg,{STR0114},3,/*cCaption2*/,/*nRotAutDefault*/,/*cBitmap*/,.T.)
					oWS:= WSNFeSBRA():New()
					oWS:cUSERTOKEN     := "TOTVS"
					oWS:cID_ENT        := cIdEnt
					oWs:oWsNFe:oWSNOTAS:=  NFeSBRA_ARRAYOFNFeS():New()
					aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())
					oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cID := cIdNfe
					oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cXML:= EncodeUtf8(cMsg)
					oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

					If oWS:Schema()
						If Empty(oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM)
							Aviso("MDF-e",STR0091,{STR0114})
						Else
							If ( MsgYesNo(STR0343) ) //"Schema com erro. Deseja visualizar as possibilidades que podem ter causado o erro?"
								ViewSchemaMsg( oWS:oWSSCHEMARESULT:oWSNFES4[1]:oWsSchemaMsg:oWsSchemaError )
							Else
								Aviso("MDF-e",IIF(Empty(oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM),STR0091,oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM),{STR0114},3)
							EndIf
						EndIf
					Else
						Aviso("MDF-e",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		Aviso("MDF-e",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
	EndIf
else
	oDoc 			:= ColaboracaoDocumentos():new()
	oDoc:cModelo	:= "MDF"
	oDoc:cTipoMov	:= "1"
	oDoc:cIDERP	:= "MDF"+cIdNFe + FwGrpCompany()+FwCodFil()

	if oDoc:consultar()
		If nTipo == 1
			if !Empty(oDoc:cXmlRet)
				Aviso("SPED",DecodeUtf8(oDoc:cXmlRet),{STR0114},3)
			else
				Aviso("SPED",oDoc:cXml,{STR0114},3)
			endif

		else
			Aviso("SPED", STR0747, {STR0114}, 3) //Validação de Schema indisponível para TOTVS Colaboração - 2.0, OK
		endif
	else
		Aviso("SPED",oDoc:cCodErr+" - "+oDoc:cMsgErr,{STR0114},3)
	endif
	oDoc := Nil
	DelClassIntF()

endif
Return .T.

Static Function Bt2NFeMnt(aMsg)

Local aSize    := MsAdvSize()
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oDlg
Local oListBox
Local oBtn1

If !Empty(aMsg)
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE "MDF-e" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER STR0060,STR0061,STR0062,STR0063,STR0064,STR0065,STR0066,STR0067,STR0068,STR0069; //"Lote"###"Dt.Lote"###"Hr.Lote"###"Recibo SEF"###"Cod.Env.Lote"###"Msg.Env.Lote"###"Cod.Ret.Lote"###"Msg.Ret.Lote"###"Cod.Ret.NFe"###"Msg.Ret.NFe"
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
	oListBox:SetArray( aMsg )
	oListBox:bLine := { || { aMsg[ oListBox:nAT,1 ],aMsg[ oListBox:nAT,2 ],aMsg[ oListBox:nAT,3 ],aMsg[ oListBox:nAT,4 ],aMsg[ oListBox:nAT,5 ],aMsg[ oListBox:nAT,6 ],aMsg[ oListBox:nAT,7 ],aMsg[ oListBox:nAT,8 ],aMsg[ oListBox:nAT,9 ],aMsg[ oListBox:nAT,10 ]} }
	@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT STR0114         ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011
	ACTIVATE MSDIALOG oDlg
EndIf
Return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewSchemaMsg
Função que monta tela com tratamento de erro de schema.

@author Henrique Brugugnoli
@since 25/07/2011
@version 1.0

@param	aMessages	Array com as mensagens
/*/
//-----------------------------------------------------------------------
Static Function ViewSchemaMsg( aMessages )

Local cTag			:= ""
Local cDesc			:= ""
Local cHierarquia   := ""
Local cDica			:= ""
Local cErro			:= ""
Local oTree
Local nX

DEFINE MSDIALOG oDlg TITLE STR0335 FROM 0,0 TO 300,500 PIXEL  //"Mensagens de Schema X Possibilidades"

@ 000, 000 MSPANEL oPanelLeft OF oDlg SIZE 085, 000
oPanelLeft:Align := CONTROL_ALIGN_LEFT

@ 000, 000 MSPANEL oPanelRight OF oDlg SIZE 000, 000
oPanelRight:Align := CONTROL_ALIGN_ALLCLIENT

oTree := xTree():New(000,000,000,000,oPanelLeft,,,)
oTree:Align := CONTROL_ALIGN_ALLCLIENT

oTree:AddTree(STR0336,,,"PARENT",,,) //"Mensagens"

For nX := 1 to len(aMessages)

	cCargo := aMessages[nX]:cTag

	oMessage := aMessages[nX]

	If ( oTree:TreeSeek(cCargo) )
		oTree:addTreeItem(STR0337,"BPMSEDT3.png",cCargo+"|"+AllTrim(Str(nX)),{ || SchemaRefreshTree( @cTag, @cDesc, @cHierarquia, @cDica, @cErro, aMessages, oTree ), oTag:Refresh(), oDesc:Refresh(), oHierarquia:Refresh(), oDica:Refresh(), oErro:Refresh() }) //"Possibilidade"
	Else
		If ( nX > 1 )
			oTree:EndTree()
		EndIf

		oTree:AddTree(cCargo,"f10_verm.png","f10_verm.png",cCargo,,,,,)
		oTree:addTreeItem(STR0337,"BPMSEDT3.png",cCargo+"|"+AllTrim(Str(nX)),{ || SchemaRefreshTree( @cTag, @cDesc, @cHierarquia, @cDica, @cErro, aMessages, oTree ), oTag:Refresh(), oDesc:Refresh(), oHierarquia:Refresh(), oDica:Refresh(), oErro:Refresh() }) 	//"Possibilidade"
	EndIf

Next nX

oTree:EndTree()

DEFINE FONT oFont BOLD

@ 005, 010 SAY oSay PROMPT STR0334 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Tag:"
@ 005, 024 SAY oTag PROMPT cTag OF oPanelRight PIXEL SIZE 040, 015

@ 020, 010 SAY oSay PROMPT STR0297+":" OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //Descrição:
@ 020, 042 SAY oDesc PROMPT cDesc OF oPanelRight PIXEL SIZE 110, 015

@ 035, 010 SAY oSay PROMPT STR0333 OF oPanelRight PIXEL FONT oFont SIZE 040, 015   //"Hierarquia:"
@ 035, 043 SAY oHierarquia PROMPT cHierarquia OF oPanelRight PIXEL SIZE 150, 015

@ 050, 010 SAY oSay PROMPT STR0332 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Dica:"
@ 050, 026 SAY oDica PROMPT cDica OF oPanelRight PIXEL SIZE 150, 015

@ 065, 010 SAY oSay PROMPT STR0331 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Erro Técnico:"
@ 065, 050 SAY oErro PROMPT cErro OF oPanelRight PIXEL SIZE 100, 055

@ 133, 097 BUTTON oBtn PROMPT STR0330 SIZE 030, 010 ACTION CreateLog( aMessages ) OF oPanelRight PIXEL //"Gerar Log"
@ 133, 130 BUTTON oBtn PROMPT STR0294 SIZE 028, 010 ACTION oDlg:end() OF oPanelRight PIXEL //"Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SchemaRefreshTree
Função que atualiza as informações da tela de schema.

@author Henrique Brugugnoli
@since 25/07/2011
@version 1.0

@param	@cTag		 Nome da tag
		@cDesc		 Descrição da tag
		@cHierarquia Pai da tag
		@cDica		 Dica do erro ocorrido
		@cErro		 Erro técnico
		aMessage	 Array com todas as tags e suas mensagens
		oTree		 Objeto com a árvore (XTree) de possibilidades

@return .T.
/*/
//-----------------------------------------------------------------------
Static Function SchemaRefreshTree( cTag, cDesc, cHierarquia, cDica, cErro, aMessage, oTree )

Local nPos	:= 0

nPos := Val(Substr(oTree:GetCargo(),At("|",oTree:GetCargo())+1))

cTag		:= aMessage[nPos]:cTag
cDesc		:= aMessage[nPos]:cDesc
cHierarquia	:= aMessage[nPos]:cParent
cDica		:= aMessage[nPos]:cLog
cErro		:= aMessage[nPos]:cErro

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} CreateLog
Função criará em disco um arquivo xml Log dos erros de schema.

@author Henrique Brugugnoli
@since 26/01/2011
@version 1.0

@param	aMessage	Array com todas as tags e suas mensagens

/*/
//-----------------------------------------------------------------------
Static Function CreateLog( aMessage )

Local cDir		:= cGetFile( "*.xml", STR0338+" XML", 1, "C:\", .T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),, .T. )
Local cFile		:= "schemalog_"+DtoS(Date())+StrTran(Time(),":","")+".xml"

Local nHandle
Local nX

If ( !Empty(cDir) )

	nHandle := FCreate(cDir+cFile)

	If ( nHandle > 0 )

		FWrite(nHandle,"<schemalog>")

		For nX := 1 to len(aMessage)

			FWrite(nHandle,"<possibilidade item='"+AllTrim(Str(nX))+"'>")
			FWrite(nHandle,"<tag>")
			FWrite(nHandle,aMessage[nX]:cTag)
			FWrite(nHandle,"</tag>")
			FWrite(nHandle,"<descricao>")
			FWrite(nHandle,EncodeUTF8(aMessage[nX]:cDesc))
			FWrite(nHandle,"</descricao>")
			FWrite(nHandle,"<hierarquia>")
			FWrite(nHandle,aMessage[nX]:cParent)
			FWrite(nHandle,"</hierarquia>")
			FWrite(nHandle,"<dica>")
			FWrite(nHandle,EncodeUTF8(aMessage[nX]:cLog))
			FWrite(nHandle,"</dica>")
			FWrite(nHandle,"<erro>")
			FWrite(nHandle,aMessage[nX]:cErro)
			FWrite(nHandle,"</erro>")
			FWrite(nHandle,"</possibilidade>")

		Next nX

		FWrite(nHandle,"</schemalog>")
		FClose(nHandle)

		If ( MsgYesNo( STR0339 + cDir + cFile + CRLF + STR0340 ) ) //"Arquivo de LOG gerado com sucesso em: " # "Deseja abrir a pasta onde o arquivo foi gerado?"
			ShellExecute ( "OPEN", cDir, "", cDir, 1 )
		EndIf

	Else
		MsgInfo(STR0341) //"Não foi possível criar o arquivo."
	EndIf

Else
	MsgInfo(STR0342) //"Deve ser informado um diretório para ser salvo o arquivo de LOG."
EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} UpdCC0
Atualiza as informacoes de Status na CC0 a partir da execucao do metodo
monitor do TSS

@author Natalia Sartori
@since 27.02.2014
@version P11
@Return	NIL
/*/
//-----------------------------------------------------------------------
Static Function UpdCC0(aDados)
    Local aArea 	:= CC0->(GetArea())
	Local nI		:= 1
	Local cSer 		:= ""
	Local cNum		:= ""
	Local aInfo		:= {}
	Local lUsaColab	:= UsaColaboracao("5")
	Local cChave	:= ""
	Local lOffline	:= .F.
	Local aPELog	:= {.F., "0", 0}
	Local lPeEvtLog	:= ExistBlock("MdfeEvtLog")

	dbSelectArea('CC0')
	CC0->(dbSetOrder(1))

	For nI := 1 to len(aDados)
    	cSer   := Iif(lUsaColab,substr(aDados[nI,2],4,3),substr(aDados[nI,2],1,3))
		cNum   := Iif(lUsaColab,substr(aDados[nI,2],7,9),substr(aDados[nI,2],4,10))
		aInfo  := aClone(aDados[nI,9])
		aPELog := {.F., "0", 0}
		If( CC0->(dbSeek(xFilial('CC0')+cSer+cNum)) )						
			cChave		:= Replace(NfeIdSPED(CC0->CC0_XMLMDF,"Id"),"MDFe","")
			lOffline	:= substr(cChave, 35, 1) == "2"

			if( len(aInfo) > 0 )
				RecLock('CC0',.F.)
				If aInfo[len(aInfo),9] == "100" .Or.;
					(aInfo[len(aInfo),9] == "135" .AND. Substr(aDados[nI][6],1,3) $ "001/034" ) .Or.; //Vincula posterior autorizado //034-Encerramento nao autorizado
					(lOffline .And. SubStr(aDados[nI][6],1,3) == "001") //Autorizado ou contingencia FSDA
					CC0->CC0_STATUS := AUTORIZADO
					CC0->CC0_PROTOC := alltrim(aDados[nI][5])
					CC0->CC0_MSGRET := aInfo[len(aInfo),10]
					CC0->CC0_CHVMDF := cChave

				ElseIf aInfo[len(aInfo),9] == "132"  .Or.  ( aInfo[len(aInfo),9] == "135" .AND. Substr(aDados[nI][6],1,3) == "013" )
					CC0->CC0_STATUS := ENCERRADO
					CC0->CC0_STATEV := EVEVINCULADO
					CC0->CC0_PROTOC := alltrim(aDados[nI][5])
					CC0->CC0_MSGRET := aInfo[len(aInfo),10]
					aPELog			:= {.T., ENCERRADO, CC0->(RECNO())}													

				ElseIf aInfo[len(aInfo),9] $ "101/218" .Or.  ( aInfo[len(aInfo),9] == "135" .AND. Substr(aDados[nI][6],1,3) == "004" )
					CC0->CC0_STATUS := CANCELADO
					CC0->CC0_STATEV := EVEVINCULADO
					CC0->CC0_PROTOC := alltrim(aDados[nI][5])
					CC0->CC0_MSGRET := aInfo[len(aInfo),10]
					aPELog			:= {.T., CANCELADO, CC0->(RECNO())}	

					//Reset NFe
					DelMDFSF2(CC0->CC0_SERMDF,CC0->CC0_NUMMDF)

				ElseIf CC0->CC0_STATEV == EVEREALIZADO //Evento não vinculado
					CC0->CC0_STATEV := EVENAOVINCULADO
					CC0->CC0_MSGRET := aInfo[len(aInfo),10]

				ElseIf !(Substr(aDados[nI][6],1,3) $ "009/007") .And.; //007=Autorizada operação em contigência / 009 = Aguardar processamento do lote
						(Empty(CC0->CC0_STATEV) .Or. CC0->CC0_STATEV <> EVENAOVINCULADO)
					CC0->CC0_STATUS := NAO_AUTORIZADO
					CC0->CC0_MSGRET := aInfo[len(aInfo),10]

				//realizado essa alteracao pois estava ficando como Status Doc 'Autorizado' e Status Evento(mensagem) como 'Encerramento nao autorizado'
				ElseIf lUsaColab .And.( Empty(CC0->CC0_STATEV) .Or. CC0->CC0_STATEV == EVENAOVINCULADO )
					CC0->CC0_STATUS := NAO_AUTORIZADO
					CC0->CC0_MSGRET := aInfo[len(aInfo),10]
				EndIf
				CC0->(msUnlock())

				//P.E Coleta de Dados
				If  lPeEvtLog .AND. aPELog[1] //Ponto de Entrada MdfeEvtLog
					ExecBlock("MdfeEvtLog", .F., .F. , { aPELog[2], GetDescEven(,,aPELog[2]), aPELog[3] })
				Endif
			elseif(lOffline)
				RecLock('CC0',.F.)
				CC0->CC0_CHVMDF := cChave
				CC0->(msUnlock())
			endif	
		EndIf
	Next nI

	RestArea(aArea)
Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedDAMDFE
Rotina de chamada de impressão da DAMDFE.

@author Rafael Iaquinto
@since 27.02.2014
@version P11
@Return	cVersaoTSS - Versão do TSS
/*/
//-----------------------------------------------------------------------
Function SpedDAMDFE()

Local aIndArq   	:= {}
Local oDamdfe
Local cFilePrint	:= "DAMDFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
Local oSetup
Local aDevice  		:= {}
Local cSession		:= GetPrinterSession()

AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6

nLocal       	:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
//nOrientation 	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
nOrientation 	:= 2
cDevice     	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
nPrintType      := aScan(aDevice,{|x| x == cDevice })

If CTIsReady(,,,lUsaColab)
	dbSelectArea("SF2")
	RetIndex("SF2")
	dbClearFilter()

	lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
	oDamdfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)

	// Cria e exibe tela de Setup Customizavel
	// OBS: Utilizar include "FWPrintSetup.ch"
	//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN + PD_DISABLEORIENTATION

	If tssHasRdm("DAMDFE")
		If ( !oDamdfe:lInJob )
			oSetup := FWPrintSetup():New(nFlags, "DAMDFE")
			// ----------------------------------------------
			// Define saida
			// ----------------------------------------------
			oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
			oSetup:SetPropert(PD_ORIENTATION , nOrientation)
			oSetup:SetPropert(PD_DESTINATION , nLocal)
			oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
			oSetup:SetPropert(PD_PAPERSIZE   , 2)

		EndIf

		// Pressionado botão OK na tela de Setup
		If oSetup:Activate() == PD_OK // PD_OK =1
			
			//Salva os Parametros no Profile   
	        fwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
	        fwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
	        fwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
	        //fwWriteProfString( cSession, "ORIENTATION", "LANDSCAPE" , .T. )

			// Configura o objeto de impressão com o que foi configurado na interface.
	        oDamdfe:setCopies( val( oSetup:cQtdCopia ) )

			If oSetup:GetProperty(PD_ORIENTATION) == 1
				//Danfe Retrato DANFEII.PRW        
				tssExecRdm("DAMDFE",.F., cIdEnt,oDamdfe, oSetup, cFilePrint)

			Else // Tratamento futuro com a implementação do DAMDFE paisagem
				//Danfe Paisagem DANFEIII.PRW
				tssExecRdm("DAMDFE",.F., cIdEnt,oDamdfe, oSetup, cFilePrint)
			EndIf

		Else
			MsgInfo( STR0757 ) //Relatório cancelado pelo usuário.
			Pergunte("DAMDFE",.F.)
			bFiltraBrw := {|| FilBrowse(aFilBrw[1],@aIndArq,@aFilBrw[2])}
			Eval(bFiltraBrw)
			Return
		Endif

		Pergunte("DAMDFE",.F.)
		bFiltraBrw := {|| FilBrowse(aFilBrw[1],@aIndArq,@aFilBrw[2])}
		Eval(bFiltraBrw)
	Else
		Help(NIL, NIL,STR0639, NIL, STR0640, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0641})
		// STR0640 Problema: "Fonte de impressão do DAMDFE não compilado."
		// STR0641 Solução: "Acesse o portal do cliente, baixe o fonte DAMDFE.PRW e compile em seu ambiente."
		// STR0639: "Fonte não compilado"
	EndIf
EndIf

oDamdfe := Nil
oSetup := Nil
ClearRelt("damdfe")

Return()

//-----------------------------------------------------------------------
/*/{Protheus.doc} MDFeWSMnt
Função de chamada do método MonitorFaixa

@author Natalia Sartori
@since 28.02.2014
@version P11
@Return	NIL
/*/
//-----------------------------------------------------------------------
Static Function MDFeWSMnt(cIdent, cSerie, cMdfMin, cMdfMax, lMonitor)

Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cModelo	:= '58'
Local lOk		:= .T.
Local oWS		:= nil
Local oRetorno	:= nil
Local aListBox	:= {}
Local aMsg		:= {}
Local nX		:= 0
Local nY		:= 0
Local oGreen	:= LoadBitMap(GetResources(), "BR_VERDE")
Local oRed		:= LoadBitMap(GetResources(), "DISABLE")

Default lMonitor := .T.

Private oXmlMonit := nil

If CTIsReady()

	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN    := "TOTVS"
	oWS:cID_ENT       := cIdEnt
	oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:cIdInicial    := cSerie + cMdfMin
	oWS:cIdFinal      := cSerie + cMdfMax
	oWS:cModelo       := cModelo
	lOk := oWS:MONITORFAIXA()
	oRetorno := oWS:oWsMonitorFaixaResult

	For nX := 1 To Len(oRetorno:oWSMONITORNFE)

		If lMonitor
			aMsg := {}
			oXmlMonit := oRetorno:oWSMONITORNFE[nX]
			If mdfeType("oXmlMonit:OWSERRO:OWSLOTENFE")<>"U"
		 		For nY := 1 To Len(	oXmlMonit:OWSERRO:OWSLOTENFE)
					If oXmlMonit:OWSERRO:OWSLOTENFE[nY]:NLOTE<>0
						aadd(aMsg,{oXmlMonit:OWSERRO:OWSLOTENFE[nY]:NLOTE,oXmlMonit:OWSERRO:OWSLOTENFE[nY]:DDATALOTE,oXmlMonit:OWSERRO:OWSLOTENFE[nY]:CHORALOTE,;
									oXmlMonit:OWSERRO:OWSLOTENFE[nY]:NRECIBOSEFAZ,;
		 							oXmlMonit:OWSERRO:OWSLOTENFE[nY]:CCODENVLOTE,PadR(oXmlMonit:OWSERRO:OWSLOTENFE[nY]:CMSGENVLOTE,50),;
		 							oXmlMonit:OWSERRO:OWSLOTENFE[nY]:CCODRETRECIBO,PadR(oXmlMonit:OWSERRO:OWSLOTENFE[nY]:CMSGRETRECIBO,50),;
									oXmlMonit:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE,PadR(oXmlMonit:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE,5000)})
					EndIf
				Next nY
			EndIf

			nY := Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)

			aadd(aListBox,{ IIf(Empty(oXmlMonit:cPROTOCOLO),oRed,oGreen),;
							oXmlMonit:cID,;
							IIf(oXmlMonit:nAMBIENTE==1,STR0056,STR0057),; //"ProduþÒo"###"HomologaþÒo"
							IIf(oXmlMonit:nMODALIDADE==1,STR0058,STR0059),; //"Normal"###"ContingÛncia"
							oXmlMonit:cPROTOCOLO,;
							PadR(oXmlMonit:cRECOMENDACAO,300),;
							oXmlMonit:cTEMPODEESPERA,;
							oXmlMonit:nTEMPOMEDIOSEF,;
							aMsg })
		EndIf
	Next nX
Else
	Aviso("MDF-e",STR0021 , {STR0114} ,3) //Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!, OK
EndIf

oXmlMonit	:= Nil
oRetorno 	:= Nil
oWS 		:= Nil
Return(Iif(lMonitor,aListBox,Nil))

//------------------------------------------------------------------------
/*/{Protheus.doc} MDFeEvento
Encerramento de MDF-e.

@author Rafael Iaquinto
@since 27.02.2014
@version P11
@Return	NIL
/*/
//-----------------------------------------------------------------------
Static Function MDFeEvento(aList,cEvento)

Local aRegMark		:= {}
Local aAreaCC0		:= CC0->(GetArea())
Local nX			:= 0
Local nPos			:= 0
Local nEnvio		:= 0
Local nY			:= 0
Local nTentativa	:= 3
Local aTrans		:= {}
Local aDados		:= {}
Local aDadosXml		:= {}
Local aNotas		:= {}
Local aXML			:= {}
Local aNFeCol		:= {}
Local cXml			:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMsg			:= ""
Local cMsgOk		:= ""
Local cMsgNOk		:= ""
Local cMsgErro		:= ""
Local cJust			:= ""
Local cErro			:= ""
Local cAviso		:= ""
Local cXmlRet		:= ""
Local cSerie		:= ""
Local cNumero		:= ""
Local cChvmdf		:= ""
Local cProtoc		:= ""
Local cXmlCC0		:= ""
Local cMunicipio	:= ""
Local cCondicao 	:= ""
Local cErroWs		:= ""
local cMsgEnc		:= ""
Local lEnvEvento	:= .F.
Local lSameJus		:= .F.
Local lCleanNF		:= .F.
local lOkCanc		:= .T.

Private oWs

aRegMark	:= GetRegMark(aList,7)
nRegMark 	:= Len(aRegMark)

If nRegMark > 0 .And. nRegMark <= 20
	
	if cEvento == EVCANCELAR
		cMsgEnc := "cancelar"
	elseIf cEvento == EVENCERRAR
		cMsgEnc := "encerrar"
	endIf

	if empty(cMsgEnc) .or. MsgYesNo(STR0642 + cMsgEnc + STR0643) //#"Deseja realmente "  ##" o(s) MDF-e(s)?"
		
		//Monta o XML do Evento
		cXml := '<envEvento>'
		cXml += '<eventos>'
		For nX := 	1 to nRegMark

			CC0->(DbGoto(aRegMark[nX,8]))

			If lUsaColab
				// Autorizado ou Nao autorizado (caso o documento for rejeitado podera gerar outro documento)
				cCondicao := ( CC0->CC0_STATUS == AUTORIZADO .Or. CC0->CC0_STATUS == NAO_AUTORIZADO )
			Else
				cCondicao := CC0->CC0_STATUS == AUTORIZADO
			EndIf

			If cCondicao

				If cEvento == EVCANCELAR
					If !lSameJus .And. MsgYesNo( STR0769 ) //Informar a justificativa para os cancelamentos?
						while lOkCanc
							if Aviso(STR0748 + CC0->CC0_SERMDF + CC0->CC0_NUMMDF, @cJust, {STR0713, STR0677}, 3, STR0749,,, .T.) == 1 //Motivo de cancelamento MDF-e , Confirmar, Cancelar, Cancelamento de MDF-e como Evento
								if empty(alltrim(cJust)) .or. len(alltrim(cJust)) < 15 .or. len(alltrim(cJust)) > 255
									MsgAlert( STR0767 ) //A justificativa do cancelamento deverá ter no mínimo 15 e no máximo 255 caracteres.
								else
									lSameJus := MsgYesNo( STR0770 ) //Utilizar a mesma justificativa para todos?
									exit
								endif
							else 
								// Caso seja cancelado
								cJust := ""
								exit
							EndIf
						end
					EndIf
				EndIf
				cXml += XmlDetEvento(cEvento,CC0->CC0_CHVMDF,cJust)

				aadd(aTrans,{1,CC0->(RECNO()), CC0->CC0_CHVMDF,CC0->CC0_SERMDF+CC0->CC0_NUMMDF } )

				lEnvEvento := .T.

			Else
				aadd(aTrans,{3,CC0->(RECNO()), CC0->CC0_CHVMDF,CC0->CC0_SERMDF+CC0->CC0_NUMMDF } )
			EndIf

			aadd(aNotas,{})
			nX := Len(aNotas)
			aadd(aNotas[nX],CC0->CC0_FILIAL)//[nX][1]
			aadd(aNotas[nX],CC0->CC0_SERMDF)//[nX][2]
			aadd(aNotas[nX],CC0->CC0_NUMMDF)//[nX][3]
			aadd(aNotas[nX],CC0->CC0_DTEMIS)//[nX][4]
			aadd(aNotas[nX],CC0->CC0_XMLMDF)//[nX][5]
			aadd(aNotas[nX],CC0->CC0_CHVMDF)//[nX][6]
			aadd(aNotas[nX],CC0->CC0_PROTOC)//[nX][7]

		Next nx
		cXml += '</eventos>'
		cXml += '</envEvento>'


		If lEnvEvento

			If lUsaColab

				For nX := 1 to Len(aNotas)

					cSerie		:= aNotas[nX][2]
					cNumero 	:= aNotas[nX][3]
					cChvmdf 	:= aNotas[nX][6]
					cProtoc		:= aNotas[nX][7]
					//Adicionando no aNFe para manter o padrao das funcoes SpedCCeXml e ColEnvEvento
					aNFeCol := {}
					aAdd(aNFeCol,"" ) 			//01 - em branco
					aAdd(aNFeCol,cSerie) 		//02 - Serie
					aAdd(aNFeCol,cNumero) 		//03 - Numero
					aAdd(aNFeCol,"")			 	//04 - em branco
					aAdd(aNFeCol,"")			 	//05 - em branco

					//Buscando valor da tag cMunDescarga para obter o codigo do municipio
					cXmlCC0	:= CC0->CC0_XMLMDF
					aDados 		:= ColDadosNf(3,"58")
					aDadosXml	:= ColDadosXMl( cXmlCC0, aDados, @cErro, @cAviso)

					If Len(aDadosXml) > 0
						If cEvento == EVENCERRAR
							cMunicipio	:= SM0->M0_CODMUN
						Else
							cMunicipio	:= Alltrim(aDadosXml[9])  //Codigo Municipio Descarga
						EndIf
					EndIf
					//Chamando funcao da geracao Evento
					cXmlRet := SpedCCeXml(Iif(lUsaColab,aNFeCol,nil),cJust,cEvento,cProtoc,"MDF",cChvmdf, cMunicipio )

					//Adicionando no array para manter o padrao da funcao XmlMDFTrans
					aXML := cXmlRet

					//Chamando funcao da geracao XML
					lRetorno := XmlMDFTrans( aNFeCol, aXML, "58" , @cErro, cEvento )

					If lRetorno
						aDados := ColDadosNf(2,"58")
						aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)

						For nY:=1  To Len(aTrans)
							nPos:=aScan(aDadosXml,{|X| X == aTrans[nY][3]})
							If nPos > 0
								aTrans[nY][1] := 2
								nEnvio++
							EndIf
						Next
						lEnvEvento:= .T.
					EndIf
				Next nX

			Else
				While nTentativa > 0
					// Chamado do metodo e envio
					oWs:= WsNFeSBra():New()
					oWs:cUserToken	:= "TOTVS"
					oWs:cID_ENT		:= cIdEnt
					oWs:cXML_LOTE	:= cXml
					oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

					If oWs:RemessaEvento()
						nTentativa := 0
						If mdfeType("oWS:oWsRemessaEventoResult:cString") <> "U"
							If mdfeType("oWS:oWsRemessaEventoResult:cString") <> "A"
								aRetorno:={oWS:oWsRemessaEventoResult:cString}
							Else
								aRetorno:=oWS:oWsRemessaEventoResult:cString
							EndIf

							For nX:=1  To Len(aTrans)
								nPos:=aScan(aRetorno,{|X|  Substr(X,9,44) == aTrans[nX][3]})
								If nPos > 0
									aTrans[nPos][1] := 2
									nEnvio++
								EndIf
							Next
							lEnvEvento:= .T.
						Endif
					Else
						lEnvEvento := .F.
						cErroWs := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

						//Tratamento para em caso de divergencia entre as informações da MDF-e no Protheus x TSS (SEFAZ)
						If nTentativa > 1 .And. "005 - CHAVE DE ACESSO OU PROTOCOLO DE AUTORIZAÇÃO DO MDFE NÃO ENCONTRADO" $ Upper(cErroWs)
							cXml := Ajstchv(aTrans,cXml)
							nTentativa--
						Else
							nTentativa := 0
							Aviso("MDF-e",cErroWs,{STR0114},3)
						EndIf
					Endif
				End
			EndIf
		EndIf

		If lEnvEvento
			For nX := 1 to len(aTrans)
				If aTrans[nX][1] == 1
					cMsgNOk	+= "MDF: "+aTrans[nX][4] + CRLF
					cMsgNOk	+= cErro
					MdfAtuEvento(aTrans[nX][2],EVENAOREALIZADO,cEvento)
				ElseIf aTrans[nX][1] == 2
					cMsgOk	+= "MDF: "+aTrans[nX][4] + CRLF
					MdfAtuEvento(aTrans[nX][2],EVEREALIZADO,cEvento)
				ElseIf aTrans[nX][1] == 3
					cMsgErro += "MDF: "+aTrans[nX][4] + CRLF
					cMsgErro += cErro
				EndIf
			Next nX

			cMsg := STR0774 + CRLF + CRLF //Resultado da transmissão dos Eventos do MDFe: 
			If Len(cMsgOk) > 0
				If cEvento == EVENCERRAR
					lCleanNF := .T.
				EndIf
				cMsg += STR0775 + CRLF + CRLF //"MDF-e com evento transmitido com sucesso: 
				cMsg += cMsgOk+CRLF
			EndIf

			If Len(cMsgNOk) > 0
				cMsg += STR0776 + CRLF + CRLF //MDF-e com problemas na transmissao do evento: 
				cMsg += cMsgNOk+CRLF
				cMsg += IIf( Empty(cErro), cErro , "" )
			EndIf

			If Len(cMsgErro) > 0
				cMsg += STR0777 + CRLF + CRLF // "MDF-e não autorizado, evento não transmitido: "
				cMsg += cMsgErro+CRLF
				cMsg += IIf( Empty(cErro), cErro , "" )
			EndIf

			EnvExibLog(cMsg, STR0773 ) //Resultado da transmissão

			If lCleanNF
				IF Aviso(STR0539, STR0750,{STR0183, STR0662}) == 1 //Atenção, Houve qualquer alteração nas informações do MDF-e (veículos, carga, documentação, motorista, etc.), que precise ser emitido uma nova MDF-e?, Sim, Não
					If MsgYesNo( STR0771 ) //A confirmação dessa opção será liberado a(s) Nota(s) Fiscal(is) vinculada a(s) MDF-e(s). Deseja mesmo seguir com esse procedimento?
						For nX := 1 To Len(aTrans)
							CC0->(DbGoto(aTrans[nX][2]))
							DelMDFSf2(CC0->CC0_SERMDF,CC0->CC0_NUMMDF)
						Next
					EndIf
				EndIf
			EndIf

			//Recarrega a lista
			If !IsInCallStack("TRANSEVENTO")
				ReloadListDocs()
			EndIf

		ElseIf len(aTrans) > 0
			MsgInfo(STR0499) //Somente documentos autorizados podem gerar evento.
		EndIf
	endIf
ElseIf nRegMark > 20
	MsgInfo( STR0758 ) //Não é possível transmitir mais de 20 registros em uma mesma requisição!
Else
	MsgInfo( STR0500 ) //Deve ser marcado pelo menos um registro!
EndIF

RestArea(aAreaCC0)

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetRegMark
Pega registros marcados o aListBox

@author Rafael Iaquinto
@since 27.02.2014
@version P11

@param	aList		aListBox
		nPosMark	Posição do mark no ListBox

@Return	NIL
/*/
//------------------------------------------------------------------------
Static Function GetRegMark(aList,nPosMark)
	Local nX			:= 0
	Local aPosMark		:= {}
	Default nPosMark	:= 7
	Default aList  	:= {{oNo,"","",STOD("20010101"),"1",.F.,.F.}}
	For nX := 1 to len(aList)
		If aList[nX,nPosMark]
			aadd(aPosMark,aList[nX])
		EndIF
	Next nX

Return(aPosMark)


//------------------------------------------------------------------------
/*/{Protheus.doc} XmlDetEvento
Monta o DetEvento do XML de evento do MDF-e.

@author Rafael Iaquinto
@since 27.02.2014
@version P11

@param	aList		aListBox
		nPosMark	Posição do mark no ListBox

@Return	NIL
/*/
//------------------------------------------------------------------------
Static Function XmlDetEvento(cEvento,cChvMdf,cJust)
Local cXml		:= ""
Local lEndFis 	:= GetNewPar("MV_SPEDEND",.F.)

cXml := '<detEvento>'
cXml += '<tpEvento>'+cEvento+'</tpEvento>'
cXml += '<chnfe>'+cChvMdf+'</chnfe>'
if cEvento == EVENCERRAR
	cXml += '<dtEnc>'+FsDateConv(Date(),"YYYY")+"-"+FsDateConv(Date(),"MM")+"-"+FsDateConv(Date(),"DD")+'</dtEnc>'
	cXml += '<cUF>'+IIF(!lEndFis,SM0->M0_ESTCOB,SM0->M0_ESTENT)+'</cUF>'
	cXml += '<cMun>'+SM0->M0_CODMUN+'</cMun>'
ElseIF cEvento == EVCANCELAR
	cXml += '<xJust>'+cJust+'</xJust>'
ElseIF cEvento == INCCONDEVE
 	cXml += '<nomecondutor>'+Alltrim(cNomeCon)+'</nomecondutor>'
	cXml += '<cpfcondutor>'+Alltrim(cCPFCon)+'</cpfcondutor>'
EndIf
cXml += '</detEvento>'

Return(cXml)

//------------------------------------------------------------------------
/*/{Protheus.doc} MdfAtuEvento
Atualiza os dados do evento do MDF-e.

@author Rafael Iaquinto
@since 27.02.2014
@version P11

@param	aList		aListBox
		nPosMark	Posição do mark no ListBox

@Return	NIL
/*/
//------------------------------------------------------------------------
Static Function MdfAtuEvento(nRecno,cStatus,cTpEven)
	Local aAreaCC0		:= CC0->(GetArea())

	CC0->(dbGoTo(nRecno))
	RecLock('CC0',.F.)
	CC0->CC0_STATEV := cStatus
	CC0->CC0_TPEVEN := cTpEven
	CC0->(msUnlock())

	RestArea(aAreaCC0)
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} EnvExibLog
Função que exibe o log de envio do Evento do MDFe.

@author Rafael Iaquinto
@since 23/01/2013
@version 1.0

@param	cMsg			Mensagem a ser exibida para o usuário

@return	Nil
/*/
//-----------------------------------------------------------------------

Static Function EnvExibLog(cMsg,cTitulo)

	Local oDlg
	Local oBtn1

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 TO 600,800 PIXEL OF oMainWnd
	DEFINE FONT oFont BOLD

	oMemo := TMultiGet():New( 010,010, { | u | If( PCount() == 0, cMsg, cMsg := u ) },oDlg, 380,270,,.F.,,,,.T.,,.F.,,.F.,.F.,.F.,,,.F.,, )
	oMemo:EnableVScroll(.T.)
	oMemo:oFont:=oFont

	@ 285,355 BUTTON oBtn1 PROMPT "OK" ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"

	ACTIVATE MSDIALOG oDlg CENTERED

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetListBox
Função que retorna o array de MDFes para o recurso "Gerenciar MDFe"

@author Rafael Iaquinto
@since 23/01/2013
@version 1.0
@return	Nil
/*/
//-----------------------------------------------------------------------
Static Function GetListBox()
	Local aListReturn := {}
	Local cAlias := GetNextAlias()
	Local cMod   := STR0885 // 1-Rodoviário

	aSize(aListReturn, 0)

	cQuery := "	SELECT CC0.CC0_SERMDF, CC0.CC0_NUMMDF, CC0.CC0_DTEMIS, CC0.CC0_STATUS, CC0.CC0_STATEV, CC0.CC0_TPEVEN, CC0.CC0_STATEV,  CC0.R_E_C_N_O_ "
	If lModal
		cQuery += ",CC0.CC0_MODAL "
	EndIf

	cQuery += " FROM " + RetSqlName('CC0') + " CC0 "
	cQuery += " WHERE CC0.CC0_FILIAL = '" + xFilial("CC0") + "' "
	If !Empty(cSerFil)
		cQuery += " 	AND CC0.CC0_SERMDF = '" + cSerFil + "'"
	EndIf
	If SubStr(cStatFil,1,1) <> '0'
		cQuery += " 	AND CC0.CC0_STATUS = '" + SubStr(cStatFil,1,1) + "' "
	EndIf

	If !Empty(cNumNFDe)
		cQuery += " AND CC0_NUMMDF >= '" + cNumNFDe + "'"
	EndIf
	If !Empty(cNumNFAt)
		cQuery += " AND CC0_NUMMDF <= '" + cNumNFAt + "'"
	EndIf

	If !Empty(cDtEmDe)
		cQuery += " AND CC0_DTEMIS>= '" + DToS(cDtEmDe) + "'"
	EndIf
	If !Empty(cDtEmAt)
		cQuery += " AND CC0_DTEMIS <= '" + DToS(cDtEmAt) + "'"
	EndIf

	If lModal .and. SubStr(cFModal,1,1) <> '3' 
		If !Empty(cFModal) .and. SubStr(cFModal,1,1) == '1'  //"1-Rodoviário"
			cQuery += " AND (CC0_MODAL = '1' OR CC0_MODAL = '" + ' ' + "')  "
		ElseIf !Empty(cFModal) .and. SubStr(cFModal,1,1) = '2'  //"2-Aéreo"
			cQuery += " AND CC0_MODAL = '2' "
		EndIf
	EndIf

	cQuery += " 	AND CC0.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY CC0.CC0_SERMDF, CC0.CC0_NUMMDF "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
	While (cAlias)->(!Eof())
		If lModal .and.  !empty((cAlias)->CC0_MODAL)
			cMod := if( (cAlias)->CC0_MODAL == "2", STR0886, STR0885 ) // 1-Rodoviário // "Aéreo"
		else
			cMod := STR0885 // 1-Rodoviário
		EndIf

		aadd(aListReturn,{"",(cAlias)->CC0_SERMDF,(cAlias)->CC0_NUMMDF,STOD((cAlias)->CC0_DTEMIS),GetDescStatus((cAlias)->CC0_STATUS),GetDescEven((cAlias)->CC0_STATEV,(cAlias)->CC0_TPEVEN),.F.,(cAlias)->R_E_C_N_O_,cMod})
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->( dbCloseArea() )

	If len(aListReturn)  = 0
		aadd(aListReturn,{"","","","","","",.F.,0,""})
	endif

Return aListReturn

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValidUf
Valida se o codigo de UG recem digitado eh valido (existe na tabela CC2)

@author Cesar Bianchi
@since 05/07/2014
@version 1.0
@param	cUF Codigo da Unidade Federativa
@return	lRet
/*/
//-----------------------------------------------------------------------
Function ValidUfMDF(cUF)
	Local lRet := .F.
	Local aArea := GetArea()
	Default cUF := ""

	If !Empty(cUF)
		dbSelectArea('SX5')
		SX5->(dbSetOrder(1))
		lRet := SX5->(dbSeek(xFilial('SX5')+"12"+cUF))

		If lRet .and. (cUF == cUFCarr .or. cUF == cUFDesc)
			MsgAlert( STR0768 ) //UF presente em Carregamento ou Descarregamento. Não é necessária sua inclusão em Percurso do veículo
			lRet := .F.
		EndIf
	EndIF

	RestArea(aArea)
Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} ValListDesc
Valida se o usuario trocou o codigo da UF de descarregamento, eliminando a lista
de municipios e de NFs Marcadas.

@author Cesar Bianchi
@since 05/07/2014
@version 1.0
@return	lRet
/*/
//-----------------------------------------------------------------------
Static Function ValListDesc(nOpc)
	Local lRet := .T.

 	If nQtNFe > 0 .and. cUFDescAux <> cUFDesc
 		If Aviso(STR0539, STR0751, {STR0183, STR0662}) == 1 //Atenção, O Codigo da UF de Descarregamento foi substituido. Esta alteração requer que todas as NFs sejam re-vinculadas ao manifesto (Aba Documentos). Deseja prosseguir com a alteração?, Sim, Não

			//Varre TRB limpando marcas
			dbSelectArea('TRB')
			TRB->(dbGoTop())
			While TRB->(!Eof())
				If !Empty(TRB->TRB_MARCA)
					RecLock('TRB',.F.)
					TRB->TRB_MARCA := ""
					TRB->TRB_CODMUN := ""
					TRB->TRB_NOMMUN := ""
					TRB->TRB_EST	:= ""
					TRB->(msUnLock())
				EndIf
				TRB->(dbSkip())
			EndDo

			//Controle UF alterada
			cUFDescAux := cUFDesc

			//Controle de variaveis
		    nQtNFe := 0
			nVTotal := 0
			nPBruto := 0
			cVeiculoAux := cVeiculo
			cCodMun := Space(TamSx3("CC2_CODMUN")[1])
			TRB->(dbGoTop())

			//Atualiza objetos graficos
			RefreshMainObjects()
 		Else
 			//Usuario nao aceitou a alteracao (clicou em nao)
 			lRet := .F.
 		EndIf
 	Else
		//Primeira vez
		cUFDescAux := cUFDesc
 	EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValListCar
Valida se o usuario trocou o codigo da UF de carregamento, eliminando a lista
de municipios de descarregamento

@author Cesar Bianchi
@since 05/07/2014
@version 1.0
@return	lRet
/*/
//-----------------------------------------------------------------------
Static Function ValListCar(nOpc)
	Local lRet := .T.
	Local nI := 1
    Local aMunCarr := {}

	If Valtype(oGetDMun) == "O" .and. ValType(oGetDMun:aCols) == "A"

	 	//Adiciona no array auxiliar apenas os municipios nao deletados.
	 	For nI := 1 to len(oGetDMun:aCols)
	 		If !oGetDMun:aCols[nI,len(oGetDMun:aCols[nI])]	//Linha nao deletada
	 			aAdd(aMunCarr,oGetDMun:aCols[nI])
	 		EndIf
	 	Next nI

	 	//Valido se sobrou algum municipio. Se sim, entao nao pode proseguir sem o pergunte
	 	If len(aMunCarr) > 0 .and. !Empty(aMunCarr[1,1]) .and. cUFCarrAux <> cUFCarr
	 		If Aviso(STR0019, STR0752, {STR0183, STR0662}) == 1 //Atenção, O Codigo da UF de Carregamento foi substituido. Esta alteração requer que todos os municipios de carregamento listados na aba Carregamento/Percurso sejam re-definidos. Deseja prosseguir com a alteração?, Sim, Não
	 			aColsMun := GetNewLine(aHeadMun)
	 	   		oGetDMun:aCols := aClone(aColsMun)
				oGetDMun:oBrowse:Refresh()
				cUFCarrAux := cUFCarr
	 			lRet := .T.
	 		Else
	 			//Usuario nao aceitou a alteracao (clicou em nao)
	 			lRet := .F.
	 		EndIf
	 	Else
			//Alterou UF mas nao tinha municipios na lista de Carregamentos.
			cUFCarrAux := cUFCarr
	 	EndIf
	Else
		//Primeira vez
		cUFCarrAux := cUFCarr
	EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ReloadListDocs
Recarrega a lista presente na getdados da rotina "gerenciar mdf-e"

@author Cesar Bianchi
@since 05/07/2014
@version 1.0
@return	lRet
/*/
//-----------------------------------------------------------------------
Static Function ReloadListDocs()

	if Type( "oListDocs" ) <> "U"

		aListDocs	:=	GetListBox()

		oListDocs:SetArray( aListDocs )

		oListDocs:bLine := {||     {If(aListDocs[oListDocs:nAt,7],oOkx,oNo),;
															aListDocs[oListDocs:nAt,2],;
											                aListDocs[oListDocs:nAt,3],;
											                aListDocs[oListDocs:nAt,4],;
								         	        		aListDocs[oListDocs:nAt,5],;
															aListDocs[oListDocs:nAt,6],;
								         	        		aListDocs[oListDocs:nAt,9]}}
		oListDocs:BLDBLCLICK := {|| MDFLinGer(@oListDocs,@aListDocs,oOkx,oNo)}
		oListDocs:bHeaderClick := {|| aEval(aListDocs, {|e| e[7] := lMarkAll}),lMarkAll:=!lMarkAll, oListDocs:Refresh()}
		oListDocs:Refresh()

	endif
Return
static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)
//-----------------------------------------------------------------------
/*/{Protheus.doc} MDFeLookUp
Funcao utilizada para retornar o filtro da consulta padrao. A consulta deve ser
indicada atraves do parametro cLookUp.

@param cLookUp -> Informe a consulta padrao que deseja utilizar o filtro

@author Luccas Curcio

@since 11/09/2014

@version 1.0

@return	cFilter -> Expressao do filtro
/*/
//-----------------------------------------------------------------------
function MDFeLookUp( cLookUp )

local cField	:=	ReadVar()
local cFilter	:=	""

if cLookUp == "CC2"

	//Consulta originada do campo "Codigo IBGE"  no formulario de Municipios de Carregamento
	if cField == "M->CC2_CODMUN"

		cFilter := "CC2->CC2_EST=='" + cUFCarr + "'"

	//Consulta originada do campo "Municipio de Descarregamento"  no formulario de Municipios de Descarregamento
	elseif cField == "CCODMUN"

		cFilter := "CC2->CC2_EST=='" + cUFDesc + "'"

	endif

endif

return cFilter

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetXmlNFe
Retorna o xml das notas vinculadas que foram emitidas.

@author Natalia Sartori
@since 08/04/2015
@version 1.0

@param  cID ID da nota que sera retornado

@return aRetorno   Array com os dados da nota
/*/
//-----------------------------------------------------------------------
Function RetXmlNFe( cSerieNFe,cNumNFe )

Local aRetorno		:= {}
Local cRetorno		:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL",""),250)
Local lUsaColab		:= UsaColaboracao("5")
Local oWS

If CTIsReady(,,,lUsaColab)
	If !lUsacolab

		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt
		oWS:nDIASPARAEXCLUSAO := 0
		oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:oWSNFEID          := NFESBRA_NFES2():New()
		oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()

		aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
		Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := cSerieNFe+cNumNFe

		If oWS:RETORNANOTASNX()
			If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
				cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[1]:oWSNFE:CXML
				aadd(aRetorno,{cRetorno})
			EndIf
		Else
			Aviso("MDF-e",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
		EndIf
	Endif
Else
	If !lUsacolab
		Aviso("MDF-e",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
EndIf
oWS       := Nil

Return aRetorno
//-----------------------------------------------------------------------
/*/{Protheus.doc} RetCodBarra
Retorna o segundo codigo de barra da NFe emitida em contingencia

@author Natalia Sartori
@since 08/04/2015
@version 1.0

@param  cXml		Xml da NFe

@return cChvCTG	Chave de acesso da NF-e em contingencia que compoe a tag
					SegCodBarra
/*/
//-----------------------------------------------------------------------
Function RetCodBarra (cXml)

Local cAviso	:= ""
Local cErro	:= ""
Local cUF		:= ""
Local cTpEmis	:= ""
Local cCnpjCpf	:= ""
Local cDiaEmis	:= ""
Local cChvCTG	:= ""

Private oNFeRet

If !Empty(cXml)
	oNFeRet := XmlParser(cXml,"_",@cAviso,@cErro)
	If Type("oNFeRet:_NFE:_INFNFE:_IDE:_MOD:TEXT") <> "U" .and. oNFeRet:_NFE:_INFNFE:_IDE:_MOD:TEXT $ "55"
		cUF := GetUfSig(oNFeRet:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT)
		cTpEmis	:= oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT

		If Type("oNFeRet:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") <> "U"
			cCnpjCpf := oNFeRet:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
		ElseIf Type("oNFeRet:_NFE:_INFNFE:_DEST:_CPF:TEXT") <> "U"
			cCnpjCpf := StrZero(Val(oNFeRet:_NFE:_INFNFE:_DEST:_CPF:TEXT),14)
		EndIf
		If Empty(cCnpjCpf) //operação com exterior informar o conteudo zerado
			cCnpjCpf := "00000000000000"
		EndIf

		cVNF := Strzero(Val(strtran(oNFeRet:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)

		cICMSp := IIf(oNFeRet:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_Vicms:TEXT $ "0",2,1) //1=Ha destaque do ICMS 2= Não ha
		cICMSs := IIf(oNFeRet:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_Vst:TEXT $ "0",2,1) //1=Ha destaque do ICMS ST 2= Não ha

		If Type("oNFeRet:_NFE:_INFNFE:_IDE:_DHEMI:TEXT") <> "U"
			cDiaEmis := Substr(oNFeRet:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,9,2)
		ElseIf Type("oNFeRet:_NFE:_INFNFE:_IDE:_DEMI:TEXT") <> "U"
			cDiaEmis := Substr(oNFeRet:_NFE:_INFNFE:_IDE:_DEMI:TEXT,9,2)
		EndIf

		cChvCTG := NFeChCtg (cUF,cTpEmis,cCnpjCpf,cVNF,Alltrim(str(cICMSp)),Alltrim(str(cICMSs)),cDiaEmis)
	EndIf
EndIf


Return (cChvCTG)

//----------------------------------------------------------------------
/*/{Protheus.doc} NFeChCtg

Função responsável em montar o Segundo Codigo de Barra (nfe em contingencia)
e calcular o seu digito verificador

@Natalia Sartori
@since 08.04.2015
@version 1.00

@param      	cUF...: Codigo da UF
				cTpEmis.: Tipo de Emissão da NFe
				cCNPJ.: CNPJ do Destinatário da NFe
				cvNF..: Valor total da NFe
				cIcmsOp: Destaque do ICMS proprio
				cIcmsS...: Destaque do ICMS ST
				cDia...: Dia de Emissão da NF-e

@Return	cResult
/*/
//-----------------------------------------------------------------------
Static Function NFeChCtg(cUF,ctpEmis,cCNPJ, cvNF, cIcmsOp, cICMSs, cDia)

Local nCount      := 0
Local nSequenc    := 2
Local nPonderacao := 0
Local cResult     := ''
Local cChvCTG  := cUF +  ctpEmis + cCNPJ + cvNF + cIcmsOp + cICMSs + cDia

//SEQUENCIA DE MULTIPLICADORES (nSequenc), SEGUE A SEGUINTE
//ORDENACAO NA SEQUENCIA: 2,3,4,5,6,7,8,9,2,3,4... E PRECISA SER
//GERADO DA DIREITA PARA ESQUERDA, SEGUINDO OS CARACTERES
//EXISTENTES NA CHAVE DE ACESSO INFORMADA (cChvAcesso)   
For nCount := Len( AllTrim(cChvCTG) ) To 1 Step -1
	nPonderacao += ( Val( SubStr( AllTrim(cChvCTG), nCount, 1) ) * nSequenc )
	nSequenc += 1
	If (nSequenc == 10)
		nSequenc := 2
	EndIf

Next nCount

//Quando o resto da divisão for 0 (zero) ou 1 (um), o DV devera ser igual a 0 (zero).
If ( mod(nPonderacao,11) > 1)
	cResult := (cChvCTG + cValToChar( (11 - mod(nPonderacao,11) ) ) )
Else
	cResult := (cChvCTG + '0')
EndIf

Return(cResult)
//-------------------------------------------------------------------------
/*/{Protheus.doc} GetMunIbge

Função responsável por trazer automaticamente o valor o código do município

@Leonardo Kichitaro
@since 19.11.2015
@version 1.00

@Return	cRetMun
/*/
//-------------------------------------------------------------------------
Static Function GetMunIbge(cSerNota, cDocNota, cCodCli, cLojaCli, cTpNF,cFilOri)

Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSF2		:= SF2->(GetArea())
Local cRetMun		:= ""
Local cChaveMun		:= ""
Local cFilReg		:= ""
Local nMV_MDFEMUN	:= GetNewPar("MV_MDFEMUN",0)	//Parametro que trará o código de município do cliente ou código de município do cliente de entrega já preenchidos
Local lMoniEvent	:= IsInCallStack("DFeSetMunNF")	//novo monitor de eventos (DF-e)

Default cSerNota	:= ""
Default cDocNota	:= ""
Default cCodCli		:= ""
Default cLojaCli	:= ""
Default cTpNF		:= iif(TRB->TRB_TPNF == "S","1","2")  //1-Saida/2-Entrada
default cFilOri		:= xFilial("SF2")

cRetMun := cCodMun

If nMV_MDFEMUN == 1
	If lMoniEvent
		cChaveMun := cCodCli+cLojaCli
	Else
		cChaveMun := TRB->TRB_CODCLI+TRB->TRB_LOJCLI
	EndIf
	cFilReg := retFilClFo(iif(lMoniEvent,cFilOri,TRB->TRB_FILIAL), cTpNF == "1")
	If cTpNF == "1"
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(cFilReg+cChaveMun))
			cRetMun := SA1->A1_COD_MUN
		EndIf
	Else 
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(cFilReg+cChaveMun))
			cRetMun := SA2->A2_COD_MUN
		EndIf
	EndIf

ElseIf nMV_MDFEMUN == 2
	cFilReg := retFilClFo(iif(lMoniEvent,cFilOri,TRB->TRB_FILIAL), cTpNF == "1")

	If cTpNF == "1"
		
		If lMoniEvent
			cChaveMun := cFilOri+cCodCli+cLojaCli+cDocNota+cSerNota
		Else
			cChaveMun := TRB->TRB_FILIAL+TRB->TRB_CODCLI+TRB->TRB_LOJCLI+TRB->TRB_DOC+TRB->TRB_SERIE
		EndIf
		SF2->(dbSetOrder(2)) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
		If SF2->(dbSeek(cChaveMun))
			SA1->(dbSetOrder(1))
			
			If lMoniEvent
				cChaveMun := cCodCli+cLojaCli
			Else
				cChaveMun := TRB->TRB_CODCLI+TRB->TRB_LOJCLI
			EndIf
			If SA1->(dbSeek(cFilReg+Iif(!Empty(SF2->F2_CLIENT),SF2->F2_CLIENT+SF2->F2_LOJENT,cChaveMun)))
				cRetMun := SA1->A1_COD_MUN
			EndIf
		EndIf
	Else
		If lMoniEvent
			cChaveMun := cCodCli+cLojaCli
		Else
			cChaveMun := TRB->TRB_CODCLI+TRB->TRB_LOJCLI
		EndIf
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(cFilReg+cChaveMun))
			cRetMun := SA2->A2_COD_MUN
		EndIf
	EndIf
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSF2)

Return cRetMun
//------------------------------------------------------------------------
/*/{Protheus.doc} IncCondutor
Inclusao de Condutor

@author Fernando Bastos
@since 15.03.2016
@version 1.00

@param 	aList		- Array com Grid da tela principal
		cEvento	- Tipo do Evento

@Return	NIL
/*/
//-----------------------------------------------------------------------
Static Function IncCondutor (aList,cEvento)
Local cNumNota 	:= ""
Local cSerNota 	:= ""
Local cChave	 	:= ""
Local cErroPost	:= ""
Local cCondicao	:= ""
Local dDatMDFe 	:= CtoD("  /  /  ")
Local nNota	 	:= 0
Local aNota	 	:= {}
Local oNo			:= LoadBitMap(GetResources(), "BR_BRANCO")
Local oDlg
Local oNome
Local oCPF
Local oCod
Local oCod1
Private cNomeCon	:= Space(TamSx3('DA4_NOME')[1])
Private cCPFCon	:= Space(TamSx3('DA4_CGC')[1])
Private cCod		:= Space(TamSx3('DA4_COD')[1])
Private oNome1
Private oCPF1
Private aNotaRet	:= {}

Default aList  	:= {{oNo,"","",STOD("20010101"),"1",.F.,.F.}}
Default cEvento	:= INCCONDEVE

DEFINE FONT oBold BOLD
aNota	:= GetRegMark(aList,7)
nNota 	:= Len(aNota)
	If nNota == 1 // Deve ser apenas uma inclusão de condutor por vez
		cNumNota := aNota[1][3]
		cSerNota := aNota[1][2]
		dDatMDFe := aNota[1][4]
		CC0->( dbSetOrder( 1 ) )
		If CC0->(dbSeek(xFilial('CC0')+CSerNota+cNumNota))
			cChave := CC0->CC0_CHVMDF
			cCondicao := CC0->CC0_STATUS == AUTORIZADO .Or. CC0->CC0_TPEVEN == INCCONDEVE
			If 	cCondicao
				If !(lUsaColab)
					aNotaRet := RetMonEven(cChave, cChave,cEvento,"58" )
					IF Empty(aNotaRet)
						aadd (aNotaRet,{oNo,"","","","","","","","",""})
					EndIF
					cErroPost := IIF(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
					If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
						MsgInfo(STR0030 + CRLF + cErroPost )
						Return .F.
					endif
					aNotaRet := RetEven(cIdEnt,cChave,@aNotaRet)
					cErroPost := IIF(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
					If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
						MsgInfo(STR0030 + CRLF + cErroPost )
						Return .F.
					endif
				Else
					aNotaRet := ColMonIncC (cSerNota,cNumNota)
				Endif
				If !(lUsaColab)
					DEFINE MSDIALOG oDlg TITLE STR0772 From 10,10 TO 500,1012 OF oMainWnd PIXEL //Inclusão de Condutor
					@015,010 SAY	STR0324			PIXEL OF oDlg FONT oBold	//Numero
					@015,036 SAY	cNumNota			PIXEL OF oDlg
					@015,078 SAY	STR0249			PIXEL OF oDlg FONT oBold	//Série
					@015,097 SAY	cSerNota			PIXEL OF oDlg
					@015,125 SAY	STR0325			PIXEL OF oDlg FONT oBold	//Dt. Emissao
					@015,151 SAY	dDatMDFe			PIXEL OF oDlg

					If lMDFePost
						@008,215 SAY STR0536 PIXEL OF oDlg FONT oBold COLOR CLR_RED //#'Em uma futura atualização, a opção de "Incluir Condutor" será movida para outro lugar.'
						@018,215 SAY STR0537 PIXEL OF oDlg FONT oBold COLOR CLR_RED //#'Experimente os recursos aprimorados em "Outras ações / Eventos / Incluir Condutor"'
					Endif

					@033,010 SAY oCod PROMPT STR0103 PIXEL OF oDlg FONT oBold  // Código
					@030,035 MSGET oCod1 VAR cCod F3 "DA4" PICTURE "@!" SIZE 30,08 PIXEL VALID GetCond(@cCod,@cNomeCon,@cCPFCon) OF oDlg
					@033,100 SAY oNome PROMPT STR0498 PIXEL OF oDlg FONT oBold // Nome do Condutor
					@030,157 MSGET oNome1 VAR cNomeCon PICTURE "@!" SIZE 200,08 PIXEL OF oDlg  WHEN .F.
					@033,395 SAY oCPF PROMPT STR0591 PIXEL OF oDlg FONT oBold // CPF
					@030,410 MSGET oCPF1 VAR cCPFCon PICTURE "@R 999.999.999-99" SIZE 070,08 PIXEL OF oDlg  WHEN .F.
					@050,010 LISTBOX oListBox FIELDS HEADER "",STR0050,STR0362,STR0295,STR0364,STR0365,STR0591,STR0498 SIZE 480,150 PIXEL OF oDlg	//"Protocolo - ID Evento - Ambiente - Status do Evento - Retorno da Transmissao - Retorno Processamento do Evento - CPF  - Nome do Condutor"
					AtuGrid(aNotaRet)
					@ 220,235 BUTTON oBtn1 PROMPT STR0261	 	ACTION (Bt1IncCond(cIdEnt,cChave,cCPFCon,cNomeCon,cEvento,aNota,aNotaRet),oListBox:nAt := 1,oListBox:Refresh()) OF oDlg PIXEL SIZE 035,011 // Transmitir
					@ 220,290 BUTTON oBtn3 PROMPT STR0118		ACTION (Bt2IncCond(cIdEnt,cChave,cEvento,aNotaRet,aNota),oListBox:nAt := 1,oListBox:Refresh()) OF oDlg PIXEL SIZE 035,011 //"Refresh"
					@ 220,345 BUTTON oBtn5 PROMPT STR0055		ACTION (Bt3IncCond(cIdEnt,oListBox:nAt,cChave,aNotaRet)) OF oDlg PIXEL SIZE 035,011 //"Rec.XML"
					@ 220,400 BUTTON oBtn2 PROMPT STR0117		ACTION (SpedEvenLeg(),,) OF oDlg PIXEL SIZE 035,011 // Legenda
					@ 220,455 BUTTON oBtn4 PROMPT STR0294		ACTION (ReloadListDocs(),aNotaRet:={},oDlg:End()) OF oDlg PIXEL SIZE 035,011 //"Sair"
					ACTIVATE MSDIALOG oDLg CENTERED
				Else
					DEFINE MSDIALOG oDlg TITLE STR0772 From 10,10 TO 500,1012 OF oMainWnd PIXEL ////Inclusão de Condutor
					@015,010 SAY	STR0324			PIXEL OF oDlg FONT oBold	//Numero
					@015,036 SAY	cNumNota			PIXEL OF oDlg
					@015,078 SAY	STR0249			PIXEL OF oDlg FONT oBold	//Série
					@015,097 SAY	cSerNota			PIXEL OF oDlg
					@015,125 SAY	STR0325			PIXEL OF oDlg FONT oBold	//Dt. Emissao
					@015,151 SAY	dDatMDFe			PIXEL OF oDlg
					@033,010 SAY oCod PROMPT STR0103 PIXEL OF oDlg FONT oBold  // Código
					@030,035 MSGET oCod1 VAR cCod F3 "DA4" PICTURE "@!" SIZE 30,08 PIXEL VALID GetCond(@cCod,@cNomeCon,@cCPFCon) OF oDlg
					@033,100 SAY oNome PROMPT STR0498 PIXEL OF oDlg FONT oBold // Nome do Condutor
					@030,157 MSGET oNome1 VAR cNomeCon PICTURE "@!" SIZE 200,08 PIXEL OF oDlg  WHEN .F.
					@033,395 SAY oCPF PROMPT STR0591 PIXEL OF oDlg FONT oBold // CPF
					@030,410 MSGET oCPF1 VAR cCPFCon PICTURE "@R 999.999.999-99" SIZE 070,08 PIXEL OF oDlg  WHEN .F.
					@050,010 LISTBOX oListBox FIELDS HEADER "",STR0050,STR0362,STR0295,STR0364,STR0365,STR0591,STR0498,"Nome do Arquivo" SIZE 480,150 PIXEL OF oDlg	//"Protocolo - ID Evento - Ambiente - Status do Evento - Retorno da Transmissao - Retorno Processamento do Evento - CPF  - Nome do Condutor"
					AtuGrid(aNotaRet)
					@ 220,235 BUTTON oBtn1 PROMPT STR0261	 	ACTION (Bt1IncCond(cIdEnt,cChave,cCPFCon,cNomeCon,cEvento,aNota,aNotaRet),oListBox:nAt := 1,oListBox:Refresh()) OF oDlg PIXEL SIZE 035,011 // Transmitir
					@ 220,290 BUTTON oBtn3 PROMPT STR0118		ACTION (Bt2IncCond(cIdEnt,cChave,cEvento,aNotaRet,aNota),oListBox:nAt := 1,oListBox:Refresh()) OF oDlg PIXEL SIZE 035,011 //"Refresh"
					@ 220,345 BUTTON oBtn5 PROMPT STR0055		ACTION (Bt3IncCond(cIdEnt,oListBox:nAt,cChave,aNotaRet,aNota)) OF oDlg PIXEL SIZE 035,011 //"Rec.XML"
					@ 220,400 BUTTON oBtn2 PROMPT STR0117		ACTION (SpedEvenLeg(),,) OF oDlg PIXEL SIZE 035,011 // Legenda
					@ 220,455 BUTTON oBtn4 PROMPT STR0294		ACTION (ReloadListDocs(),aNotaRet:={},oDlg:End()) OF oDlg PIXEL SIZE 035,011 //"Sair"
					ACTIVATE MSDIALOG oDLg CENTERED
				EndIf
			Else
				MsgInfo(STR0499) //Somente documentos autorizados podem gerar evento.
			EndIf
		EndIf
	Elseif nNota < 1
		MsgInfo(STR0500) //Deve ser marcado pelo menos um registro!
	Else
		MsgInfo(STR0501) //Selecione apenas um MDF-e por vez!
	Endif
Return
//-----------------------------------------------------------------------
/*/{Protheus.doc} AtuGrid()
Atualiza a Grid do retorno nfemonitorloteevento

@author Fernando Bastos
@since 22.03.2016
@version 1.00

@param 	aListBox	 - Array com o lista para ser atualzada

@Return Return .T. - Quando o aListBox esta correto
/*/
//-----------------------------------------------------------------------
static function AtuGrid(aNotaRet)
Local oNo			:= LoadBitMap(GetResources(), "BR_BRANCO")
Local lReturn 		:= .T.

IF Empty(aNotaRet)
	aadd (aNotaRet,{oNo,"","","","","","","","",""})
EndIF
If !empty(aNotaRet)
	oListBox:SetArray(aNotaRet)
	oListBox:bLine:={||	{	aNotaRet[oListBox:nAt][01],;
							aNotaRet[oListBox:nAt][02],;
							aNotaRet[oListBox:nAt][03],;
							aNotaRet[oListBox:nAt][04],;
							aNotaRet[oListBox:nAt][05],;
							aNotaRet[oListBox:nAt][06],;
							aNotaRet[oListBox:nAt][10],;
							aNotaRet[oListBox:nAt][09],;
							Iif(lUsaColab,aNotaRet[oListBox:nAt][11],"")}}
	oListBox:Refresh()
	lReturn := .T.
Else
	lReturn := .F.
EndIf
Return lReturn
//-----------------------------------------------------------------------
/*/{Protheus.doc} Bt1IncCond()
Botao de transmissao do evento de inclusao de condutor

@author Fernando Bastos
@since 23.03.2016
@version 1.00

@param 	cIdEnt		- Codigo da Entidade
		cChave		- Chave do MDFe
		cCPFCon	- CPF do Condutor
		cNomeCon	- Nome do Condutor
		cEvento	- Tipo do evento
		aNota		- Array com as notas da Grid da primeira tela
		aNotaRet	- Array com o Evento NfeRetornaEvento

@Return Return 	- .T.
/*/
//-----------------------------------------------------------------------
Static function Bt1IncCond(cIdEnt,cChave,cCPFCon,cNomeCon,cEvento,aNota,aNotaRet)
Local cErroPost := ""

If IncCondVal(cCod, cCPFCon, cNomeCon, aNotaRet) //Valida condutor
	//Monta o DetEvento do XML de evento do MDF-e.
	MDFeEvento( aNota,cEvento)
	If !(lUsaColab)
		aNotaRet := RetMonEven(cChave, cChave,cEvento,"58" )
		aNotaRet := RetEven(cIdEnt,cChave,@aNotaRet)
		If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
			MsgInfo(STR0030 + CRLF + cErroPost )
		endif
	Endif
	//Atualiza a Grid
	AtuGrid(aNotaRet)
Endif
Return .T.
//-----------------------------------------------------------------------
/*/{Protheus.doc} Bt2IncCond()
Botao de Refresh

@author Fernando Bastos
@since 24.03.2016
@version 1.00

@param 	cIdEnt		- Codigo da Entidade
		cChave		- Chave do MDFe
		cEvento	- Tipo do evento
		aNotaRet	- Array com o Evento NfeRetornaEvento

@Return Return 	- .T.
/*/
//-----------------------------------------------------------------------
Static function Bt2IncCond(cIdEnt,cChave,cEvento,aNotaRet,aNota)
Local cErroPost	:= ""
	If !(lUsaColab)
		aNotaRet := RetMonEven(cChave, cChave,cEvento,"58" )
		aNotaRet := RetEven(cIdEnt,cChave,@aNotaRet)
		If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
			MsgInfo(STR0030 + CRLF + cErroPost )
		endif
	Else
		aNotaRet := ColMonIncC (aNota[1][2],aNota[1][3])
	Endif
	AtuGrid(aNotaRet)
Return .T.
//-----------------------------------------------------------------------
/*/{Protheus.doc} Bt3IncCond()
Botao de Rec.XML

@author Fernando Bastos
@since 23.03.2016
@version 1.00

@param 	cIdEnt		- Codigo da Entidade
		nPos		- Posicao da Grid
		cChave		- Chave do MDFe
		aNotaRet	- Array com o Evento NfeRetornaEvento

@Return Return 	- .T.
/*/
//-----------------------------------------------------------------------
Static function Bt3IncCond(cIdEnt,nPos,cChave,aNotaRet,aNota)
Local cErroPost := ""
Default nPos    := 0
	If !(lUsaColab)
		aNotaRet := RetEven(cIdEnt,cChave,@aNotaRet)
		If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
			MsgInfo(STR0030 + CRLF + cErroPost )
		endif
		IF (Len(aNotaRet[nPos]) == 7)
			aadd(aNotaRet[nPos],"")
			aadd(aNotaRet[nPos],"")
			aadd(aNotaRet[nPos],"")
		EndIf
		Aviso(cCadastro,aNotaRet[nPos][8],{STR0114},3)
	Else
		aNotaRet := ColMonIncC (aNota[1][2],aNota[1][3])
		Aviso(cCadastro,aNotaRet[nPos][12],{STR0114},3)
	Endif
Return .T.
//-----------------------------------------------------------------------
/*/{Protheus.doc} GetCond()
Carrega o motorista

@author Fernando Bastos
@since 17.03.2016
@version 1.00

@param 	oCod1	 	- Codigo do Condutor
		cNomeCon	- Nome do Condutor
		cCPFCon 	- CPF do Condutor


@Return lReturn 	- .T. - Retorna na tela o nome e CPF do condutor
/*/
//-----------------------------------------------------------------------
Static function GetCond(cCod,cNomeCon,cCPFCon)
Local lreturn := .F.
If !Empty (cCod)
	DA4->( dbSetOrder( 1 ) )
	IF DA4->( dbSeek( xFilial("DA4")+cCod ) )
		cNomeCon := DA4->DA4_NOME
		cCPFCon  := DA4->DA4_CGC
		lreturn := .T.
	Else
		cNomeCon := space( getSx3Cache( "DA4_NOME", "X3_TAMANHO") ) // criaVar("DA4_NOME")
		cCPFCon  := space( getSx3Cache( "DA4_CGC", "X3_TAMANHO") ) // criaVar("DA4_CGC")
		lreturn := .T.
	EndIf
ELse
	cNomeCon := space( getSx3Cache( "DA4_NOME", "X3_TAMANHO") ) // criaVar("DA4_NOME")
	cCPFCon  := space( getSx3Cache( "DA4_CGC", "X3_TAMANHO") ) // criaVar("DA4_CGC")
	lreturn := .T.
Endif
Return lreturn
//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedEvenLeg
Função que demonstra a legenda das cores da mbrowse

@author Fernando Bastos
@since 18.03.2016
@version 1.00

@param	Null
/*/
//-----------------------------------------------------------------------
Function SpedEvenLeg()
Local aLegenda := {}
AADD(aLegenda, {"BR_VERDE"		,STR0447})//"Evento vinculado com sucesso"
AADD(aLegenda, {"DISABLE"		,STR0449})//"Evento não vinculado"
BrwLegenda(cCadastro,STR0117,aLegenda) //"Legenda"
Return
//-----------------------------------------------------------------------
/*/{Protheus.doc} RetEven()
Função que executa os webservices de consulta do Evento NfeRetornaEvento

@author Fernando Bastos
@since 21.03.2016
@version 1.00

@param	 cIdEnt		- Entidade da empresa
		 cChave		- Chave para Consulta
		 aNotaRet	- Array com o Evento NfeRetornaEvento

@Return aDados 	- lista com o retorno da consulta
/*/
//-----------------------------------------------------------------------
Static Function RetEven(cIdEnt,cChave,aNotaRet)
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cErro			:= ""
Local cAviso		:= ""
Local cIdEven		:= ""
Local cErroPost		:= ""
Local nX			:= 0
Local nPos			:= 0
Local aDados		:= {}
Local aIdCPF		:= {}
Local aTag			:= {}
Local aTagRet		:= {}

Default cChave 		:= ""
Default cIdEnt 		:= ""
Default aNotaRet	:= {}

aadd(aTag,"eventoMDFe|infEvento|detEvento|evIncCondutorMDFe|condutor|xNome")
aadd(aTag,"eventoMDFe|infEvento|detEvento|evIncCondutorMDFe|condutor|CPF")
aadd(aTag,"eventoMDFe|infEvento|dhEvento")

// Executa o metodo NfeRetornaEvento()
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN	:= "TOTVS"
oWS:cID_ENT		:= cIdEnt
oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
oWS:cEvenChvNFE	:= cChave
lOk:=oWS:NFERETORNAEVENTO()
If lOk
	// Tratamento do retorno do evento
	If ValType(oWS:oWsNfeRetornaEventoResult) <> "U" .And. ValType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"
		aDados := oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento
		For nX := 1 To Len(aDados)
			cIdEven := aDados[nX]:CID_EVENTO
			aadd(aIdCPF,aDados[nX]:CXML_SIG)
			aTagRet :=	ColDadosXMl(aDados[nX]:CXML_SIG,aTag,@cAviso,@cErro)
			aadd(aIdCPF,aTagRet[1])
			aadd(aIdCPF,aTagRet[2])
			aadd(aIdCPF,aDados[nX]:NLOTE)
			aadd(aIdCPF,aTagRet[3])	//Data e hora

			nPos := aScan(aNotaRet ,{|x| x[3] == cIdEven } )
			If nPos > 0	
				If len(aNotaRet[nPos]) >= 7  .And. Len(aNotaRet[nPos]) < 12 
					aadd(aNotaRet[nPos],aIdCPF[1])
					aadd(aNotaRet[nPos],aIdCPF[2])
					aadd(aNotaRet[nPos],aIdCPF[3])
					aadd(aNotaRet[nPos],aIdCPF[4])
					aadd(aNotaRet[nPos],aIdCPF[5])
				Else
					aNotaRet[nPos][08] := aIdCPF[1]
					aNotaRet[nPos][09] := aIdCPF[2]
					aNotaRet[nPos][10] := aIdCPF[3]
					aNotaRet[nPos][11] := aIdCPF[4]
					aNotaRet[nPos][12] := aIdCPF[5]
				EndIF
			EndIf 
			aIdCPF :={}
		Next nX
	Endif
Else
	If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
		MsgInfo(STR0030 + CRLF + cErroPost ) //Houve erro durante a transmissão para o Totvs Services SPED.
	endif
EndIf
Return(aNotaRet)
//----------------------------------------------------------------------
/*/{Protheus.doc} RestFilial
Restaura o valor do MDFE quando troca de filial

@author Fernando Bastos
@since 27/12/2016
@version P11

@param
@Return .T.
/*/
//-----------------------------------------------------------------------
Function RestFilial()
	nQtNFe  := nRQtNFe
	nVTotal := nRVTotal
	nPBruto := nRPBruto
Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeExport
Funcao responsavel por Exportar XML MDF-e

@author Douglas Parreja
@since 20/10/2017
@version P12.17

@param
@Return .T.
/*/
//-----------------------------------------------------------------------
function MDFeExport()

	// Rotina exportacao SPEDNFE
	SpedExport(5)

return .T.
//-----------------------------------------------------------------------
/*/{Protheus.doc} ValidPost
Valida a regra do carremento posterior , onde so é permitido o Envio qunado
UF carregamento igual UF Descarregamento

@author Fernando Bastos 
@since 06/08/2019
@version 1.0
@return	.T.
/*/
//-----------------------------------------------------------------------
Static Function ValidPost(nOpc)

If lMDFePost
	If (cUFCarr == cUFDesc) .And. nOpc == 3
		oCombo2:bWhen := {||.T.}
	Else 
		oCombo2:bWhen := {||.F.}
	EndIf
EndIf

Return .T.

Function MdfeFiltro()

	INCLUI    := .F.
	lBtnFiltro:= .T.
	
	CloseBrowse()

Return Nil


//-----------------------------------------------------------------------
/*/{Protheus.doc} MntEventos
Função responsavel pela chamada de função que monta tela do Monitor Eventos 
MDF-e

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		aListMdfe: Lista de array com as mdf-e
@return		.T.
/*/
//-----------------------------------------------------------------------
Static Function MntEventos(aListMdfe)
Local nPosReg 	:= 0
Local aCC0Area	:= {}
Local cNumMdfe	:= ""
Local cSerMdfe	:= ""

//Valida se o registro selecionada MDF-e é valido
If ValMDfeSel(aListMdfe).And. (nPosReg := aScan(aListMdfe, {|x| x[7] } )) > 0
	cSerMdfe := Padr(aListMdfe[nPosReg,2],TamSx3("CC0_SERMDF")[1])
	cNumMdfe := Padr(aListMdfe[nPosReg,3],TamSx3("CC0_NUMMDF")[1])
	aCC0Area := CC0->(GetArea())

	//ParamBox()
	CC0->(DBSetOrder(1)) //CC0_FILIAL + CC0_SERMDF + CC0_NUMMDF
	If CC0->(DBSeek(xFilial("CC0")+cSerMdfe+cNumMdfe))
		TelaMntDfe(aListMdfe, nPosReg)
	EndIf

	ClearInfPag()

	RestArea(aCC0Area)
EndIf

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValMDfeSel
Realiza as validações do registros selecionado MDf-e para saber se 
está apto para uso

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version	1.00
@param		Nil
@return		.T.
/*/
//-----------------------------------------------------------------------
Static Function ValMDfeSel(aListMdfe)
Local lRet 			:= .T.
Local nTotRegSel	:= 0
Local cMsg			:= ""

Default aListMdfe	:= {}

If Len(aListMdfe) > 0

	AEval( aListMdfe, {|x| iif(x[7],nTotRegSel++,Nil)  })
	If nTotRegSel == 0
		lRet := .F.
		cMsg := STR0500 //Deve ser marcado pelo menos um registro!

	ElseIf nTotRegSel > 1
		lRet := .F.
		cMsg := STR0501 //Selecione apenas um MDF-e por vez!
	EndIf
Else
	lRet := .F.
	cMsg := STR0538 //#"Operação não permitida em formulario vazio." 
EndIf

If !lRet
	MsgInfo(cMsg, STR0539) //#"Atenção"
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} TelaMntDfe
Função principal da tela de monitor de eventos MDF-e

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@param		aListMdfe: Array com todos os mdf-e
			nPosReg: Posição selecionada do array de mdf-e
@return		.T.
/*/
//-----------------------------------------------------------------------
Static Function TelaMntDfe(aListMdfe, nPosReg)

Local aMsSize	  	:= Nil
Local oDlgEvent 	:= Nil
Local oPnlOpc		:= Nil
Local oPnlFiltro	:= Nil
Local oPnlGrid		:= Nil
Local oPnlLeg		:= Nil
Local oPnlBtn		:= Nil
Local oBtnSair		:= Nil
Local oBtnTransm	:= Nil
Local oTFont		:= Nil
Local oFontTit		:= Nil
Local oBtnRefres	:= Nil
Local oBtnRecXml	:= Nil
Local oBtnHist		:= NIl
Local oSayConf		:= Nil
Local oSaynReal		:= Nil
Local oSayDesc		:= Nil
Local oSayCienc		:= Nil
Local oBmpCinz		:= Nil
Local oBmpAzul		:= Nil
Local oBmpVerm		:= Nil
Local oBmpVerd		:= Nil
Local oGrpLegend	:= Nil
Local lEnchoiceBar	:= .F.
Local nPosColMei	:= 0
Local nPLegIni		:= 0
Local nPosColInf	:= 0	//Posicao inicial da coluna da Inferior
Local nPosLinInf	:= 0	//Posicção da linha no painel inferiror
Local nEspacoBtn	:= 60	//Espaco entre os botoes da tela
Local nEspacoLeg	:= 70	//Espaco entre as legendas
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
Local cTitulo		:= STR0540 //#"Monitor de Eventos MDF-e"
Local aOpcCombo		:= {}
Local cOpcMonitor	:= ""
Local bOpcCombo		:= {|| (cOpcEvent := SubStr(cOpcMonitor,1,1),;
							MntTelaEvent(@oDlgEvent,@oPnlFiltro,@oPnlGrid,@aPosObj),;
							oPnlFiltro:Refresh(), oPnlGrid:Refresh(), oDlgEvent:Refresh() ) }

//Variaveis para uso da opção 'Inclusao de DF-e (notas)'
Private dDtIniDfe	:= dDtFimDfe := cToD("//")
Private cNfIniDfe	:= cNfFimDfe := Space(TamSx3("F2_DOC")[1])
Private cNumSerDFe	:= Space((TamSx3("F2_SERIE")[1]*4)-1) //sempre traz a possibilidade de ser informada 3 notas + o separador
Private cAllFilDFe	:= STR0525 //#"2-Não"
Private cTpDfe		:= ""
Private cCodMunDfe	:= space( getSx3Cache( "CC2_CODMUN", "X3_TAMANHO") ) // CriaVar("CC2_CODMUN") //Para o facilitador 
Private cNMunDFe	:= space( getSx3Cache( "CC2_MUN", "X3_TAMANHO") ) // CriaVar("CC2_MUN") //Para o facilitador 
Private cCodMun 	:= space( getSx3Cache( "CC2_CODMUN", "X3_TAMANHO") ) // CriaVar("CC2_CODMUN") //para edição manual dobleclick
Private cNomeMun 	:= space( getSx3Cache( "CC2_MUN", "X3_TAMANHO") ) // CriaVar("CC2_MUN")//para edição manual dobleclick
Private lRepMun		:= .F.
Private oLstBoxDfe	:= NIl
Private aListDfe	:= {}

//Variaveis para uso da opção 'Inclusao de Condutor'
Private aCondu		:= {}
Private aRetNota	:= {}
Private oLstCond	:= Nil
Private cNomeCon	:= space( getSx3Cache( "DA4_NOME", "X3_TAMANHO") ) // CriaVar('DA4_NOME')
Private cCPFCon		:= space( getSx3Cache( "DA4_CGC", "X3_TAMANHO") ) // CriaVar('DA4_CGC')
Private cCodCon		:= space( getSx3Cache( "DA4_COD", "X3_TAMANHO") ) // CriaVar('DA4_COD')

//Variaveis para uso da opção 'Pagamento de Operacao de Transporte'
Private aDadosPgto	:= {}
Private aRetInfPag	:= {}
Private cNrViagem	:= space(5)
Private cQtdViagem	:= space(5)
Private oLstPagto	:= nil 
Private oGQtdVig	:= nil
Private oGNrVig		:= nil

aAdd(aListDfe,RetDfeArr())
aAdd(aCondu,RetIncArr())
aAdd(aDadosPgto,RetPgtArr())

AAdd( aObjects, { 10, 10, .T., .T. } ) //Opcoes		-> Combobox de opções
AAdd( aObjects, { 20, 20, .T., .T. } ) //Filtro		-> Campos para filtro
AAdd( aObjects, { 50, 50, .T., .T. } ) //Grid		-> Grid
AAdd( aObjects, { 10, 10, .T., .T. } ) //Legenda	-> Legenda
AAdd( aObjects, { 10, 10, .T., .T. } ) //Botoes		-> Botoes de ação (%)
aMsSize	:= MsAdvSize(lEnchoiceBar) //Tamanho da tela (considera EnchoiceBar sim ou nao)
aInfo	:= { aMsSize[1], aMsSize[2], aMsSize[3], aMsSize[4], /*Sep_Verti*/ 3, /*Sep_Horiz*/ 3 }
aPosObj	:= MsObjSize( aInfo, aObjects, .T. ) 

aAdd(aOpcCombo,STR0541) //#"1- Incluir DF-e (NFe)"
aAdd(aOpcCombo,STR0542) //#"2- Incluir Condutor"
if lInfPag
	aAdd( aOpcCombo, "3- Pagamento Oper. Transporte" )
endif
cOpcMonitor	:= aOpcCombo[1]
cOpcEvent := SubStr(cOpcMonitor,1,1)

ClearInfPag()

DEFINE MSDIALOG oDlgEvent TITLE cTitulo From aMsSize[7],0 TO aMsSize[6],aMsSize[5] OF oMainWnd PIXEL

	//---------------------------------- 1- COMBOBOX ---------------------------------------//
	//Painel OpcCombo
	oPnlOpc := tPanel():Create(oDlgEvent,aPosObj[1,1],aPosObj[1,2],"",oTFont,.F.,,,,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1])
	TSay():New(07,08,{|| STR0543 },oPnlOpc,,,,,,.T.,,,200,20) //#"Seleção de Eventos:"
	TComboBox():New(03,60,{|u|if(PCount()>0,cOpcMonitor :=u, cOpcMonitor)},aOpcCombo,95,50,oPnlOpc,,bOpcCombo,,,,.T.,,,,,,,,,'cOpcMonitor')
	nLinOpc := 06
	nColOpc := 165
	TSay():New(nLinOpc,nColOpc, {|| STR0544 } ,oPnlOpc,,oFontTit,,,,.T.) //#"Numero MDF-e: "
	nColOpc += 45
	TSay():New(nLinOpc,nColOpc, {|| AllTrim(CC0->CC0_NUMMDF) } ,oPnlOpc,,oFontTit,,,,.T.,CLR_RED)

	nColOpc += 50
	TSay():New(nLinOpc,nColOpc, {|| STR0545 } ,oPnlOpc,,oFontTit,,,,.T.) //#"Serie MDF-e: "
	nColOpc += 40
	TSay():New(nLinOpc,nColOpc, {|| AllTrim(CC0->CC0_SERMDF) } ,oPnlOpc,,oFontTit,,,,.T.,CLR_RED)

	nColOpc += 40
	TSay():New(nLinOpc,nColOpc, {|| STR0546 } ,oPnlOpc,,oFontTit,,,,.T.) //#"UF Carregamento: "
	nColOpc += 55
	TSay():New(nLinOpc,nColOpc, {|| AllTrim(CC0->CC0_UFINI) } ,oPnlOpc,,oFontTit,,,,.T.,CLR_RED)

	nColOpc += 33
	TSay():New(nLinOpc,nColOpc, {|| STR0547 } ,oPnlOpc,,oFontTit,,,,.T.) //#"UF Descarregamento: "
	nColOpc += 65
	TSay():New(nLinOpc,nColOpc, {||  AllTrim(CC0->CC0_UFFIM) } ,oPnlOpc,,oFontTit,,,,.T.,CLR_RED)

	nColOpc += 25
	TSay():New(nLinOpc,nColOpc, {|| STR0548 } ,oPnlOpc,,oFontTit,,,,.T.) //#"Veículo: "
	nColOpc += 30
	TSay():New(nLinOpc,nColOpc, {|| AllTrim(CC0->CC0_VEICUL) } ,oPnlOpc,,oFontTit,,,,.T.,CLR_RED)

	nLinOpc := 21
	nColOpc := 165
	TSay():New(nLinOpc,nColOpc, {|| STR0621 } ,oPnlOpc,,oFontTit,,,,.T.) //#"Status:"
	nColOpc += 45
	TSay():New(nLinOpc,nColOpc, {|| GetDescStatus(CC0->CC0_STATUS) } ,oPnlOpc,,oFontTit,,,,.T.,CLR_RED)

	nColOpc += 50
	TSay():New(nLinOpc,nColOpc, {|| STR0623 } ,oPnlOpc,,oFontTit,,,,.T.) //#"Carrega posterior:"
	nColOpc += 50
	TSay():New(nLinOpc,nColOpc, {|| iif(CC0->CC0_CARPST=="1",STR0524,STR0525) } ,oPnlOpc,,oFontTit,,,,.T.,CLR_RED) //#Carrega posterior ##"1-Sim" ###"2-Não"

	nColOpc += 30
	TSay():New(nLinOpc,nColOpc, {|| "Chave MDf-e:" } ,oPnlOpc,,oFontTit,,,,.T.)
	nColOpc += 50
	TSay():New(nLinOpc,nColOpc, {|| AllTrim(CC0->CC0_CHVMDF) } ,oPnlOpc,,oFontTit,,,,.T.,CLR_RED)
	
	//---------------------------------- 2- FILTROS ----------------------------------------//
	//Painel Filtros
	oPnlFiltro := MntPnlParam(@oPnlFiltro,@oDlgEvent,@aPosObj)

	//----------------------------------- 3- GRID ------------------------------------------//
	//Painel Grid
	oPnlGrid := MntPnlGrid(@oPnlGrid,@oDlgEvent,@aPosObj)

	//----------------------------------- 4- LEGENDA --------------------------------------//
	//Painel Legenda
	oPnlLeg := tPanel():Create(oDlgEvent,aPosObj[4,1],aPosObj[4,2],"",oTFont,.F.,,,,aPosObj[4,4]-aPosObj[4,2],aPosObj[4,3]-aPosObj[4,1])
	
	nPLegIni 	:= 0
	nPLegFin 	:= 0
	nPosLinMei 	:= nPLegIni + 10

	oGrpLegend := TGroup():Create(oPnlLeg,nPLegIni,nPLegFin,nPosLinMei+15,aPosObj[4,4]-aPosObj[4,2],STR0549,,,.T.) //#"legenda"
		
	nPosColMei := nPLegFin + 10
	oBmpCinz := TBitmap():Create(oGrpLegend, nPosLinMei, nPosColMei, 017, 017, "BR_PRETO.PNG", Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
	nPosColMei += 10
	oSayDesc := TSay():Create(oGrpLegend,{|| STR0550 },nPosLinMei,nPosColMei,,oTFont,,,,.T.) //#"Não Transmitido"

	nPosColMei += nEspacoLeg
	oBmpAzul := TBitmap():Create(oGrpLegend, nPosLinMei, nPosColMei, 017, 017, "BR_AZUL.PNG", Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
	nPosColMei += 10
	oSayCienc := TSay():Create(oGrpLegend,{|| STR0551 },nPosLinMei,nPosColMei,,oTFont,,,,.T.) //#"Transmitido"

	nPosColMei += nEspacoLeg
	oBmpVerd := TBitmap():Create(oGrpLegend, nPosLinMei, nPosColMei, 017, 017, "BR_VERDE.PNG", Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
	nPosColMei += 10
	oSayConf := TSay():Create(oGrpLegend,{|| STR0552 },nPosLinMei,nPosColMei,,oTFont,,,,.T.) //#"Autorizado"
	
	nPosColMei += nEspacoLeg
	oBmpVerm := TBitmap():Create(oGrpLegend, nPosLinMei, nPosColMei, 017, 017, "BR_VERMELHO.PNG", Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
	nPosColMei += 10
	oSaynReal := TSay():Create(oGrpLegend,{|| STR0553 },nPosLinMei,nPosColMei,,oTFont,,,,.T.) //#"Rejeitado"

	
	//----------------------------------- 5- BOTOES --------------------------------------//
	oPnlBtn := tPanel():Create(oDlgEvent,aPosObj[5,1],aPosObj[5,2],"",oTFont,.F.,,,,aPosObj[5,4]-aPosObj[5,2],aPosObj[5,3]-aPosObj[5,1])

	nPosLinInf := (aPosObj[5,3]-aPosObj[5,1]) / 5
	nPosColInf := (aPosObj[5,4]-aPosObj[5,2] - nEspacoBtn) 
	//Botao Sair
	oBtnSair := TButton():Create(oPnlBtn, nPosLinInf, nPosColInf, STR0554, {|| ReloadListDocs(), oDlgEvent:End() }, 40, 12, Nil, oTFont, Nil, .T., Nil,,) //#"Sair"

	nPosColInf -= nEspacoBtn
	//Botao Historico Evento
	oBtnHist := TButton():Create(oPnlBtn, nPosLinInf, nPosColInf, STR0555, {|| FWMsgRun(,{|| HistEvento() },STR0556,STR0557) } , 40, 12, Nil, oTFont, Nil, .T.) //#"Mensagem" ##"Mensagem Evento" ###"Por favor aguarde, recuperando histórico deste evento..."

	nPosColInf -= nEspacoBtn
	//Botao Rec.XML
	oBtnRecXml := TButton():Create(oPnlBtn, nPosLinInf, nPosColInf, STR0558, {|| FWMsgRun(,{|| EvRecXml()},STR0559,STR0560) } , 40, 12, Nil, oTFont, Nil, .T.) //#"Rec.XML" ##"Recuperando XML" ###"Por favor aguarde, recuperando XML deste evento..."

	nPosColInf -= nEspacoBtn
	//Botao Refresh
	oBtnRefres := TButton():Create(oPnlBtn, nPosLinInf, nPosColInf, STR0620, {|| FWMsgRun(,{|| RefresEvento()},STR0561,STR0562) }, 40, 12, Nil, oTFont, Nil, .T.,,,,{ || CC0->CC0_STATUS == AUTORIZADO }) //#"Refresh de Evento" ##"Por favor, aguarde pela atualização do(s) evento(s)..." ##"Refresh"

	nPosColInf -= nEspacoBtn
	//Botao Transmitir
	oBtnTransm := TButton():Create(oPnlBtn, nPosLinInf, nPosColInf, STR0563, {|| FWMsgRun(,{|oSayProc| TransEvento()},STR0565,STR0564) }, 40, 12, Nil, oTFont, Nil, .T.,,,,{ || CC0->CC0_STATUS == AUTORIZADO }) //#"Transmitir" ##"Por favor, aguarde pela transmissão do(s) evento(s)..." ###"Transmissão de Evento"

ACTIVATE DIALOG oDlgEvent CENTERED

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} MntTelaEvent
Função responsavel por atualizar os componentes de Grid e Parametros do 
eventos quando alterado a seleção de evento.

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@param		Objetos da tela
@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function MntTelaEvent(oDlgEvent,oPnlFiltro,oPnlGrid,aPosObj)
oPnlFiltro := MntPnlParam(@oPnlFiltro,@oDlgEvent,@aPosObj)
oPnlGrid := MntPnlGrid(@oPnlGrid,@oDlgEvent,@aPosObj)
EvLimpaVar()
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} MntPnlParam
Função responsavel por atualizar o painel de parametros do evento

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@param		Objetos da tela
@return		oPnlFiltro: Objeto que tem os componentes da tela
/*/
//-----------------------------------------------------------------------
Static Function MntPnlParam(oPnlFiltro,oDlgEvent,aPosObj)
Local nColuna		:= 10
Local bBtnMunDfe	:= Nil
Local bBtnFilDfe	:= Nil
local lAltera		:= .T.
local nOpc			:= 0
local bWhen			:= { || .F. }

If ValType("oPnlFiltro") <>  "U"
	fwfreeobj(oPnlFiltro)
	oPnlFiltro := Nil
EndIf

If cOpcEvent == "1" //DF-e
	oPnlFiltro := TPanel():Create(oDlgEvent,aPosObj[2,1],aPosObj[2,2],"",Nil,.F.,,,,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	oGrpFiltro := TGroup():Create(oPnlFiltro,0,0,aPosObj[2,3]-aPosObj[2,1],aPosObj[2,4]-aPosObj[2,2],STR0619,,,.T.) //#"Parâmetros do Evento"

	nSepCampos	:= 75
	nSepCol		:= 27
	nLinhaGet 	:= 13
	nLinhaSay 	:= 16
	nColuna		:= 0
	nColIni		:= 12
	nPulaLinha	:= 23
	bBtnFilDfe	:= { || FWMsgRun(, {|| FiltrarDFe()},STR0566,STR0567) } //#"Buscar NF-e" ##"Por favor, aguarde pela busca de NF-e..."
	bBtnMunDfe	:= { || AddMunDFe() }
	
	//Data Inicial
	nColuna += nColIni
	TSay():New(nLinhaSay,nColuna,{|| STR0568 },oGrpFiltro,,,,,,.T.) //#"Dt. Inicial"
	nColuna += nSepCol
	TGet():New(nLinhaGet,nColuna,{ | u | If( PCount() == 0, dDtIniDfe, dDtIniDfe := u ) },oGrpFiltro, 60, 10, "@D",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtIniDfe")
				
	nColuna += nSepCampos

	//Data Final
	TSay():New(nLinhaSay,nColuna,{|| STR0569 },oGrpFiltro,,,,,,.T.) //#"Dt. Final"
	nColuna += nSepCol-1
	TGet():New(nLinhaGet,nColuna,{ | u | If( PCount() == 0, dDtFimDfe, dDtFimDfe := u ) },oGrpFiltro, 60, 10, "@D",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtFimDfe")

	nColuna += nSepCampos

	//Nota Inicial
	TSay():New(nLinhaSay,nColuna,{|| STR0570 },oGrpFiltro,,,,,,.T.) //#"Nota Inicial"
	nColuna += nSepCol+1
	TGet():New(nLinhaGet,nColuna,{ | u | If( PCount() == 0, cNfIniDfe, cNfIniDfe := u ) },oGrpFiltro, GetTextWidth(0,cNfIniDfe), 10, "@D",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNfIniDfe")

	nColuna += nSepCampos - 20

	//Nota Final
	TSay():New(nLinhaSay,nColuna,{|| STR0571 },oGrpFiltro,,,,,,.T.) //#"Nota Final"
	nColuna += nSepCol
	TGet():New(nLinhaGet,nColuna,{ | u | If( PCount() == 0, cNfFimDfe, cNfFimDfe := u ) },oGrpFiltro, GetTextWidth(0,cNfFimDfe), 10, "@D",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNfFimDfe")

	nColuna += nSepCampos - 23

	//Serie
	TSay():New(nLinhaSay,nColuna,{|| STR0572 },oGrpFiltro,,,,,,.T.) //#"Série"
	nColuna += nSepCol-11
	oSerEvMdfe := TGet():New(nLinhaGet,nColuna,{ | u | If( PCount() == 0, cNumSerDFe, cNumSerDFe := u ) },oGrpFiltro, 45, 10, "@D",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNumSerDFe")
	oSerEvMdfe:cPlaceHold := "Ex.:000;111;222"

	nColuna += nSepCampos - 25

	//Tipo de Nota?
	TSay():New(nLinhaSay,nColuna,{|| STR0573 },oGrpFiltro,,,,,,.T.) //#"Tipo de Nota"
	nColuna += nSepCol
	TComboBox():New(nLinhaGet,nColuna+7,{|u|if(PCount()>0, cTpDfe :=u, cTpDfe)},{STR0574,STR0575,STR0576},60,14,oGrpFiltro,,{|| .T. },,,,.T.,,,,,,,,,'cTpDfe') //#"1-Saida" ##"2-Entrada" ###"3-Saida e Entrada"

	nColuna += nSepCampos+5

	//Todas Filiais?
	TSay():New(nLinhaSay,nColuna,{|| STR0577 },oGrpFiltro,,,,,,.T.) //#"Todas Filiais?"
	nColuna += nSepCol
	TComboBox():New(nLinhaGet,nColuna+7,{|u|if(PCount()>0, cAllFilDFe:=u, cAllFilDFe)},{STR0524,STR0525},40,14,oGrpFiltro,,{|| .T. },,,,.T.,,,,,,,,,'cAllFilDFe') //#"1-Sim" ##"2-Não"

	//Botao Buscar/Filtrar Nota
	nLinhaGet	+= nPulaLinha
	nColuna		:= nColIni
	TButton():Create(oGrpFiltro, nLinhaGet, nColuna, STR0566, bBtnFilDfe, GetTextWidth(0,STR0566), 14, Nil, NIl, Nil, .T.,,,,{ || CC0->CC0_STATUS == AUTORIZADO }) //#"Buscar NF-e"

	//Replica Municipio
	nColuna 	+= nSepCampos
	nLinhaSay	+= nPulaLinha
	TCheckBox():New(nLinhaSay, nColuna, OemToAnsi(STR0578), {|u|if( pcount()==0, lRepMun, lRepMun := u)},oGrpFiltro,GetTextWidth(0,OemToAnsi(STR0578)),10,,,,,,,,.T.) //#"Replica Município?"

	nColuna += nSepCampos

	//Cod. Municipio de Descarregamento
	TSay():New(nLinhaSay,nColuna,{|| STR0579 },oGrpFiltro,,,,,,.T.) //#"Cod. Município Descarregamento"
	nColuna += nSepCol+57
	TGet():New(nLinhaGet,nColuna,{ | u | If( PCount() == 0, cCodMunDfe, cCodMunDfe := u ) },oGrpFiltro, 15, 10, "@D",{|| DFeVldMun(cCodMunDfe, @cNMunDFe, AllTrim(CC0->CC0_UFFIM)) },,,,.F.,,.T.,,.F.,{|| lRepMun },.F.,.F.,,.F.,.F. ,"CC2","cCodMunDfe",,,,,,,,,,CLR_HBLUE)

	nColuna	+= nSepCampos-17

	//Nome Municipio
	TSay():New(nLinhaSay,nColuna,{|| STR0580 },oGrpFiltro,,,,,,.T.) //#"Município Descarregamento"
	nColuna += nSepCol+42
	TGet():New(nLinhaGet,nColuna,{ | u | If( PCount() == 0, cNMunDFe, cNMunDFe := u ) },oGrpFiltro, 180, 10, "@D",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cNMunDFe",,,,,,,,,,CLR_HBLUE)

	nColuna += nSepCampos+120

	//Botao Add Municipio
	TButton():Create(oGrpFiltro, nLinhaGet, nColuna, STR0581, bBtnMunDfe, GetTextWidth(0,STR0581), 13, Nil, NIl, Nil, .T.,,,,{ || CC0->CC0_STATUS == AUTORIZADO .And. lRepMun }) //#"Add Município"

Elseif cOpcEvent == "2" //Incluir Condutor

	oPnlFiltro := TPanel():Create(oDlgEvent,aPosObj[2,1],aPosObj[2,2],"",Nil,.F.,,,,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	oGrpFiltro := TGroup():Create(oPnlFiltro,0,0,aPosObj[2,3]-aPosObj[2,1],aPosObj[2,4]-aPosObj[2,2],STR0619,,,.T.) //#"Parâmetros do Evento"

	TSay():New(20,15,{|| STR0103 },oGrpFiltro,,,,,,.T.,,,,)  //Código
	TGet():New(17,35,{ | u | If( PCount() == 0, cCodCon, cCodCon := u ) }, oGrpFiltro, 030, 010, "!@",{|| GetCond(@cCodCon,@cNomeCon,@cCPFCon)},,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,"DA4","cCodCon")

	TSay():New(20,135,{|| STR0498 },oGrpFiltro,,,,,,.T.,,,,) //Nome do Condutor	
	TGet():New(17,190,{ | u | If( PCount() == 0, cNomeCon, cNomeCon := u ) }, oGrpFiltro, 300, 010, "!@",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cNomeCon")

	TSay():New(20,556,{|| STR0591 },oGrpFiltro,,,,,,.T.,,,,) //CPF
	TGet():New(17,570,{ | u | If( PCount() == 0, cCPFCon, cCPFCon := u ) }, oGrpFiltro, 080, 010, "@R 999.999.999-99",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cCPFCon")

Elseif cOpcEvent == "3" //Pagamento da operação de transporte
	
	ClearInfPag()

	lAltera := .T.
	aDadosPgto := InfPagLoad(@cQtdViagem, @cNrViagem, @lAltera)

	if lAltera
		nOpc := GD_INSERT+GD_UPDATE+GD_DELETE
		bWhen := { || .T. }
	endif

	oPnlFiltro := TPanel():Create(oDlgEvent,aPosObj[2,1],aPosObj[2,2],"",Nil,.F.,,,,aPosObj[2,4]-aPosObj[2,2],(aPosObj[3,1]*2)-35)
	oGrpFiltro := TGroup():Create(oPnlFiltro,0,0,(aPosObj[3,1]*2)-35,aPosObj[2,4]-aPosObj[2,2],STR0619,,,.T.)

	nSepCol		:= 70
	nLinhaSay 	:= 10
	nColuna		:= 0
	nColIni		:= 12	
	//Data Inicial
	nColuna += nColIni
	TSay():New(nLinhaSay+2,nColuna,{|| "Qtd. Viagens" },oGrpFiltro,,,,,,.T.,,,,)
	nColuna += nSepCol
	oGQtdVig := TGet():New(nLinhaSay,nColuna-30,{ | u | If( PCount() == 0, cQtdViagem, cQtdViagem := u ) }, oGrpFiltro, 030, 010, "@R 99999",,,,,.F.,,.T.,,.F.,bWhen,.F.,.F.,,.F.,.F. ,,"cQtdViagem")

	nColuna += nColIni
	TSay():New(nLinhaSay+2,nColuna,{|| "Nr. Viagem" },oGrpFiltro,,,,,,.T.,,,,)
	nColuna += nSepCol
	oGNrVig := TGet():New(nLinhaSay,nColuna-30,{ | u | If( PCount() == 0, cNrViagem, cNrViagem := u ) }, oGrpFiltro, 030, 010, "@R 99999",,,,,.F.,,.T.,,.F.,bWhen,.F.,.F.,,.F.,.F. ,,"cNrViagem")

	if oDlgPgt:CreateGrid(@oGrpFiltro, nOpc, { 3.2, 0.2, 09, 49} , {09, 0.2, 19.5, 24.6}, {09, 24.8, 19.5, 49}, .F.)
		oDlgPgt:Show()
	endif

EndIf

Return oPnlFiltro

//-----------------------------------------------------------------------
/*/{Protheus.doc} MntPnlGrid
Função responsavel por atualizar o painel de gride do evento

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@param		Objetos da tela
@return		oPnlFiltro: Objeto que tem os componentes da tela
/*/
//-----------------------------------------------------------------------
Static Function MntPnlGrid(oPnlGrid,oDlgEvent,aPosObj)
Local oMarca		:= LoadBitmap( GetResources(), "LBOK" )
Local oDesmarca		:= LoadBitmap( GetResources(), "LBNO" )
Local lDfeMarkAll	:= .T.

If ValType("oPnlGrid") <> "U"
	fwfreeobj(oPnlGrid)
	oPnlGrid := Nil
EndIf

If cOpcEvent == "1" //DF-e
	
	oPnlGrid := tPanel():Create(oDlgEvent,aPosObj[3,1],aPosObj[3,2],"",Nil,.F.,,,,aPosObj[3][4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1])

	oLstBoxDfe := Nil
	fwfreeobj(oLstBoxDfe)
	
	@0,0 LISTBOX oLstBoxDfe FIELDS HEADER "","",STR0582,STR0572,STR0583,STR0584,STR0585,STR0586,STR0587,STR0579,STR0580; //#"Tipo" #"Série" #"Número" #"Chave" #"Valor" #"Protocolo Evento" #"Histórico" #"Cod.Municipio Descarregamento" #"Municipio Descarregamento"
		SIZE aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1] PIXEL OF oPnlGrid ON dblClick (aListDfe[oLstBoxDfe:nAt,DFESELEC]:= !aListDfe[oLstBoxDfe:nAt,DFESELEC])

	oLstBoxDfe:SetArray( aListDfe )
	
	oLstBoxDfe:bLDblClick	:= {|| iif(!Empty(aListDfe[oLstBoxDfe:nAt,DFECHVMDF]) .And. (aListDfe[oLstBoxDfe:nAt,DFESELEC] .Or. lRepMun .Or. aListDfe[oLstBoxDfe:nAt,DFESTATUS]==EVEVINCULADO .Or. DFeSetMunNF(oLstBoxDfe:nAt)) ,;
									aListDfe[oLstBoxDfe:nAt][DFESELEC] := !aListDfe[oLstBoxDfe:nAt][DFESELEC],Nil), oLstBoxDfe:Refresh() }
	
	oLstBoxDfe:bHeaderClick	:= {|| iif(lRepMun,(aEval(aListDfe, {|e| e[1] := lDfeMarkAll}), lDfeMarkAll:=!lDfeMarkAll, oLstBoxDfe:Refresh()),Nil) }
	
	oLstBoxDfe:bLine 		:= {|| { iIf(aListDfe[oLstBoxDfe:nAt, DFESELEC],oMarca,oDesmarca)				,; 			//Selecao - Marca ou Desmarca
										getColorEve(aListDfe[oLstBoxDfe:nAt, DFESTATUS])					,; 			//Legenda - para cada status
										aListDfe[oLstBoxDfe:nAt, DFETIPONT]									,; 			//Tipo - Entrada ou Saida
										aListDfe[oLstBoxDfe:nAt, DFESERNT]									,; 			//Serie Nota
										aListDfe[oLstBoxDfe:nAt, DFENUMNT]									,; 			//Numero Nota
										aListDfe[oLstBoxDfe:nAt, DFECHVMDF]									,; 			//Chave Nota
										AllTrim(Transform(aListDfe[oLstBoxDfe:nAt,DFEVLRNT],"@E 99,999,999,999.99")),;	//Valor Nota
										aListDfe[oLstBoxDfe:nAt, DFEPROTOC]									,;			//Protocolo DF-e
										aListDfe[oLstBoxDfe:nAt, DFEHISTOR]									,;			//Historico Evento
										aListDfe[oLstBoxDfe:nAt, DFECMUNDE]									,;			//Cod Municipio Desca.
										aListDfe[oLstBoxDfe:nAt, DFENMUNDE]									}}			//Nome Municipio Desca.

	DFeIncGrid() //Inicializa as DF-es

Elseif cOpcEvent == "2" //Incluir Condutor
	
	oPnlGrid := tPanel():Create(oDlgEvent,aPosObj[3,1],aPosObj[3,2],"",Nil,.F.,,,,aPosObj[3][4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1])

	@0, 0 LISTBOX oLstCond FIELDS HEADER "",STR0586,STR0588,STR0035,STR0589,STR0590,STR0592,STR0591 ; //#"Protocolo" #"ID Evento" #"Ambiente" #"Retorno da Transmissão" #"CPF" #"Nome do Condutor"
			SIZE aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1] PIXEL OF oPnlGrid
			
	oLstCond:SetArray( aCondu )	
	oLstCond:bLine := {| | { getColorEve(aCondu[oLstCond:nAt, 1])					,; //1 - Status
							aCondu[oLstCond:nAt, 2]									,; //2 - Protocolo
							aCondu[oLstCond:nAt, 3]									,; //3 - ID Evento
							aCondu[oLstCond:nAt, 4]									,; //4 - Ambiente
							aCondu[oLstCond:nAt, 5]									,; //5 - Status do evento							
							aCondu[oLstCond:nAt, 6]									,; //6 - Retorno da Transmissão
							aCondu[oLstCond:nAt, 7]									,; //7 - CPF
							aCondu[oLstCond:nAt, 8]									}} //8 - Nome do Condutor
	IncUpdGrid()

ElseIf cOpcEvent == "3" //Pagamento da operação de trans
	
	oPnlGrid := tPanel():Create(oDlgEvent,(aPosObj[3,1]*2),aPosObj[3,2],"",Nil,.F.,,,,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-(aPosObj[3,1]*2))

	@0, 0 LISTBOX oLstPagto FIELDS HEADER "",STR0586,STR0588,STR0035,STR0590 ; //#"Protocolo" #"ID Evento" #"Ambiente" #"Retorno da Transmissão"
			SIZE aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-(aPosObj[3,1]*2) PIXEL OF oPnlGrid
			
	oLstPagto:SetArray( aDadosPgto )
	oLstPagto:bLine := {| | { getColorEve(aDadosPgto[oLstPagto:nAt, 1])	 ,; //1 - Status
							aDadosPgto[oLstPagto:nAt, 2]	 ,; //2 - Protocolo
							aDadosPgto[oLstPagto:nAt, 3]	 ,; //3 - ID Evento
							aDadosPgto[oLstPagto:nAt, 4]	 ,; //4 - Ambiente
							aDadosPgto[oLstPagto:nAt, 5]	 }} //5 - Retorno da Transmissão
	oLstPagto:bChange := { || AtuInfPag() }
	oLstPagto:Refresh()

EndIf

Return oPnlGrid

//-----------------------------------------------------------------------
/*/{Protheus.doc} AddMunDFe
Função da ação do botão Add Municipio responsavel por adicionar no grid 
os codigo e nomes dos municipios informados pelo usuario nos parametros 
di evento.

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@param		
@return		.T.
/*/
//-----------------------------------------------------------------------
Static Function AddMunDFe()
Local aListDfe	:= GetArrDFe()
Local nI		:= 1

If !Empty(cCodMunDfe)
	For nI := 1 To Len(aListDfe)
		If aListDfe[nI,DFESELEC] .And. !(aListDfe[nI,DFESTATUS] $ EVEVINCULADO+"/"+EVENAOREALIZADO)
			aListDfe[nI,DFECMUNDE] := cCodMunDfe
			aListDfe[nI,DFENMUNDE] := cNMunDFe
		EndIf
	Next nI
EndIf

SetArrDFe(aListDfe)

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} getColorEve
Atualiza cor da legenda do listbox no gride dos eventos MDF-e

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@param		cStatus: Status da Manifestaçao
@return		oClrRet: Cor da legenda no listbox		
/*/
//-----------------------------------------------------------------------
Static function getColorEve( cStatus )
Local oClrRet	:= Nil
Local oAzul		:= LoadBitmap( GetResources(), "BR_AZUL" )
Local oPreto	:= LoadBitmap( GetResources(), "BR_PRETO" )
Local oVerde	:= LoadBitmap( GetResources(), "BR_VERDE" )
Local oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO" )

If cStatus == EVEVINCULADO
	oClrRet := oVerde 		//Autorizado
ElseIf cStatus == EVENAOVINCULADO
	oClrRet := oVermelho	//Rejeitado
ElseIf cStatus == EVENAOREALIZADO
	oClrRet := oAzul 		//Transmitido
ElseIf cStatus == EVEREALIZADO
	oClrRet := oPreto 		//Nao Transmitido
endif

return oClrRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetDfeArr
Retorna estrutura de dados do listbox da DFe do monitor de Evento

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@return		aDfe - Array com as estrutura de dados do array do listbox 
			do monitor de Evento
/*/
//-----------------------------------------------------------------------
Static Function RetDfeArr()
Local aDfe := ARRAY(17)
aDFe[DFESELEC]	:= .F.			//1Selecionada ou nao
aDFe[DFESTATUS]	:= EVEREALIZADO	//2Situacao da nota no MDF-e
aDfe[DFEORDEM]	:= EVORDNAOTR	//3Ordem de apresentacao
aDFe[DFECHVMDF]	:= ""			//4Chave Nota
aDFe[DFESERNT]	:= ""			//5Serie Nota
aDFe[DFENUMNT]	:= "" 			//6Numero Nota
aDFe[DFEVLRNT]	:= 0			//7Valor Nota
aDFe[DFEPROTOC]	:= ""			//8Protocolo DF-e
aDFe[DFECMUNDE]	:= ""			//9Codigo Munucipio Descarregamento
aDFe[DFENMUNDE]	:= ""			//10Nome Munucipio Descarregamento
aDFe[DFETIPONT]	:= ""			//11Tipo Entrada ou Saida?
aDFe[DFERECNO]	:= 0			//12Numero do RECNO do registro na tabela (SF1 ou SF2)
aDFe[DFEVINCUL]	:= .F.			//13Registro ja vinculado?
aDfe[DFEHISTOR]	:= ""			//14Historico do evento
aDfe[DFECLINF]	:= ""			//15Codigo do cliente da NF (DF-e)
aDfe[DFELJCLI]	:= ""			//16Loja do cliente da NF (DF-e)
aDfe[DFEFILORI]	:= ""			//17Filial de origem da DF-e
Return aDfe

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetIncArr
Retorna estrutura de dados do listbox do Inclusao de condutor

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@return		aIncCon	- Array com as estrutura de dados do array do listbox 
			do monitor de Evento
/*/
//-----------------------------------------------------------------------
Static Function RetIncArr()
Local aIncCon := ARRAY(8)
aIncCon[1]	:= ""
aIncCon[2]	:= ""
aIncCon[3]	:= ""
aIncCon[4]	:= ""
aIncCon[5]	:= ""
aIncCon[6]	:= ""
aIncCon[7]	:= ""
aIncCon[8]	:= ""
Return aIncCon

//-----------------------------------------------------------------------
/*/{Protheus.doc} FiltrarDFe
Função responsavel por add no array da lista com as notas (entrada e/ou saida) 
de acordo com o informado pelo usuario nos campos de filtro/parametros do evento
a ser apresentada ao usuario

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@param		Nil
@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function FiltrarDFe()
Local aVincDFe	:= {}
Local cQuery	:= ""
Local cSerEv	:= EvFormtSer(cNumSerDFe)
Local cAlias	:= GetNextAlias()
Local cOpTpDfe	:= SubStr(cTpDfe,1,1)

If cOpTpDfe == "1" .Or. cOpTpDfe == "3" 	//1=Saida / 3=Ambos
	cQuery += "SELECT F2_CHVNFE AS CHAVE_NFE, F2_SERIE AS SERIE, F2_DOC AS NUMERO, F2_VALBRUT AS VALOR, '' AS PROTOCOLO, SF2.R_E_C_N_O_ AS RECNO, '1-Saida' AS TIPO"
	cQuery += ", F2_NUMMDF AS NUMMDFE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, F2_FILIAL FILORI"
	cQuery += " FROM " + RetSqlName("SF2") + " SF2"
	cQuery += " WHERE SF2.D_E_L_E_T_ = ' '"
	cQuery += " AND SF2.F2_ESPECIE = 'SPED' AND SF2.F2_FIMP <> 'D' AND SF2.F2_CHVNFE <> ' '"
	cQuery += " AND SF2.F2_NUMMDF = ' ' AND SF2.F2_SERMDF = ' '"
	cQuery += " AND SF2.F2_VEICUL1 = '" + AllTrim(CC0->CC0_VEICUL) + "'"
	If !Empty(cFilMDF) .And. lFilDMDF2
		cQuery += " AND SF2.F2_" + cFilMDF + " = ' '"
	Endif
	If !Empty(cNumSerDFe) .And. !Empty(cSerEv)
		cQuery += " AND SF2.F2_SERIE IN (" + AllTrim(cSerEv) + ")"
	EndIf
	If !Empty(cAllFilDFe) .And. SubStr(cAllFilDFe,1,1) == "2" //Todas Filiais? //2-Não
		cQuery += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
	EndIf
	If !Empty(dDtIniDfe)
		cQuery += " AND SF2.F2_EMISSAO >= '" + DToS(dDtIniDfe) + "'"
	EndIf
	If !Empty(dDtFimDfe)
		cQuery += " AND SF2.F2_EMISSAO <= '" + DToS(dDtFimDfe) + "'"
	EndIf
	If !Empty(cNfIniDfe)
		cQuery += " AND SF2.F2_DOC >= '" + AllTrim(cNfIniDfe) + "'"
	EndIf
	If !Empty(cNfFimDfe)
		cQuery += " AND SF2.F2_DOC <= '" + AllTrim(cNfFimDfe) + "'"
	EndIf

EndIf

If cOpTpDfe == "3"	//3=Ambos
	cQuery += " UNION "
EndIf

If cOpTpDfe == "2" .Or. cOpTpDfe == "3"	//2=Entrada / 3=Ambos
	cQuery += "SELECT F1_CHVNFE AS CHAVE_NFE, F1_SERIE AS SERIE, F1_DOC AS NUMERO, F1_VALBRUT AS VALOR, '' AS PROTOCOLO, SF1.R_E_C_N_O_ AS RECNO, '2-Entrada' AS TIPO"
	cQuery += ", F1_NUMMDF AS NUMMDFE, F1_FORNECE AS CLIENTE, F1_LOJA AS LOJA, F1_FILIAL FILORI"
	cQuery += " FROM " + RetSqlName("SF1") + " SF1"
	cQuery += " WHERE SF1.D_E_L_E_T_ = ' '"
	cQuery += " AND SF1.F1_ESPECIE = 'SPED' AND SF1.F1_FIMP <> 'D' AND SF1.F1_CHVNFE <> ' '"
	cQuery += " AND SF1.F1_NUMMDF = ' ' AND SF1.F1_SERMDF = ' '" 
	cQuery += " AND SF1.F1_VEICUL1 = '" + AllTrim(CC0->CC0_VEICUL) + "'"
	If !Empty(cFilMDF) .And. lFilDMDF1
		cQuery += " AND SF1.F1_" + cFilMDF + " = ' '"
	Endif
	If !Empty(cNumSerDFe) .And. !Empty(cSerEv)
		cQuery += " AND SF1.F1_SERIE IN (" + AllTrim(cSerEv) + ")"
	EndIf
	If !Empty(cAllFilDFe) .And. SubStr(cAllFilDFe,1,1) == "2" //Todas Filiais? //2-Não
		cQuery += " AND SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
	EndIf
	If !Empty(dDtIniDfe)
		cQuery += " AND SF1.F1_EMISSAO >= '" + DToS(dDtIniDfe) + "'"
	EndIf
	If !Empty(dDtFimDfe)
		cQuery += " AND SF1.F1_EMISSAO <= '" + DToS(dDtFimDfe) + "'"
	EndIf
	If !Empty(cNfIniDfe)
		cQuery += " AND SF1.F1_DOC >= '" + AllTrim(cNfIniDfe) + "'"
	EndIf
	If !Empty(cNfFimDfe)
		cQuery += " AND SF1.F1_DOC <= '" + AllTrim(cNfFimDfe) + "'"
	EndIf
EndIf

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

//Faz copia dos registros vinculados
aListDfe := GetArrDFe()
aEval(aListDfe, {|x| iif(x[DFEVINCUL] , aAdd(aVincDFe, x), Nil ) } )

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

If (cAlias)->(Eof()) .And. (cAlias)->(Bof())
	MsgInfo(STR0622,STR0539) //#"Nenhuma NF-e encontrada de acordo com os parametros informados!" ##"Atenção"
Else
	While (cAlias)->(!Eof())
		aDFe := RetDfeArr()
		aDFe[DFESELEC]	:= .F.
		aDFe[DFESTATUS]	:= EVEREALIZADO
		aDFe[DFEORDEM]	:= EVORDNAOTR
		aDFe[DFECHVMDF]	:= (cAlias)->CHAVE_NFE
		aDFe[DFESERNT]	:= (cAlias)->SERIE
		aDFe[DFENUMNT]	:= (cAlias)->NUMERO
		aDFe[DFEVLRNT]	:= (cAlias)->VALOR
		aDFe[DFETIPONT]	:= (cAlias)->TIPO
		aDFe[DFECLINF]	:= (cAlias)->CLIENTE
		aDFe[DFELJCLI]	:= (cAlias)->LOJA
		aDFe[DFEFILORI]	:= (cAlias)->FILORI
		aDFe[DFERECNO]	:= (cAlias)->RECNO //Recno das notas (SF1 ou SF2)
		aDFe[DFEVINCUL]	:= .F.
		
		aAdd(aVincDFe,aDFe) //Add no array com os registros ja vinculados (fixos) antes

		(cAlias)->(dbSkip())
	EndDo
EndIf

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

If Len(aVincDFe) == 0
	aAdd(aVincDFe, RetDfeArr())
EndIf

SetArrDFE(aClone(aVincDFe), .T.)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} TransEvento
Função responsavel por realizar as chamadas da validação e transmissão dos
eventos MDF-e

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		Nil
@return		lRet: .T.=Sucesso / .F.=Problema
/*/
//-----------------------------------------------------------------------
Static Function TransEvento()
Local lRet := .F.

If cOpcEvent == "1" //DFe
	If DFeVldTrans()
		lRet := TransmiDfe()
	EndIf

ElseIf cOpcEvent == "2"	//Incluir Condutor
	aNotaCond := GetArrCond()
	If IncCondVal(cCodCon, cCPFCon,cNomeCon,aNotaCond)
		lRet := TransmiCond()
		If lRet
			EvLimpaVar()
		EndIf
	EndIf

ElseIf cOpcEvent == "3"	//Pagamento de Operacao de Transporte
	If PgtoVldTrans()
		lRet := TransPgto()
	EndIf
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} DFeVldTrans
Função responsavel por realziar as devidas validações do evento de DF-e
a ser transmitido

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		Nil
@return		lRet: .T.=Evento valido / .F.=Evento não valido
/*/
//-----------------------------------------------------------------------
Static Function DFeVldTrans()
Local lRet		:= .T.
Local lSelec	:= .F.	//Existe registro selecionado
Local aNotas	:= {}
Local nFor		:= 0
Local cErro		:= ""

If lMDFePost .And. CC0->CC0_CARPST <> "1"
	cErro := STR0593 //#"Transmissão somente permitida para MDF-e carrega posterior."
	lRet := .F.

ElseIf !(CC0->CC0_STATUS == AUTORIZADO)
	cErro := STR0594 //#"Transmissão somente permitida para MDF-e autorizados."
	lRet := .F.

Else
	aNotas := GetArrDFe()
	For nFor := 1 To Len(aNotas)

		//Verifica se existe registros selecionado
		If aNotas[nFor, DFESELEC] .And. !(aNotas[nFor, DFESTATUS] == EVEVINCULADO)
			lSelec := .T.
		EndIf

		//Verifica se a nota selecionada esta com os campos de municipio preenchidos
		If aNotas[nFor, DFESELEC] .And. Empty(aNotas[nFor, DFECMUNDE]) .And. aNotas[nFor, DFESTATUS] == EVEREALIZADO
			lRet := .F.
			cErro += STR0595 + CRLF + CRLF + STR0596 //#"Existe(m) registro(s) selecionado(s) com municipio em branco!" ##"Por favor preencher-lo(s) ou retirar sua(s) seleção(ões)."
			Exit
		EndIf

	Next nFor

	if !lSelec
		lRet := .F.
		cErro += STR0597 + CRLF + CRLF + STR0598  //#"Nenhum registro selecionado." ##"Por favor selecionar ao menos um registro que não esteja autorizado."
	EndIf
EndIf

If !lRet
	MsgInfo(cErro,STR0539) //#"Atenção"
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} TransmiDfe
Função responsavel por transmitir para o TSS as notas (DF-e) de inclusao
para a MDF-e

@author 	Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		Nil
@return		lRet: .T.=Sucesso na transmissao / .F.=Falha na transmissao
/*/
//-----------------------------------------------------------------------
Static Function TransmiDfe()
Local lRet			:= .F.
Local lUsaColab		:= .F.
Local aRetRemessa	:= {}
Local nI			:= 0
Local cXml			:= ""
Local cCodMunuic	:= ""
Local cDescMunic	:= ""
Local cChaveMDFe	:= AllTrim(CC0->CC0_CHVMDF)
Local UfDescar		:= AllTrim(CC0->CC0_UFFIM)
Local cRet			:= ""
Local cMsg			:= ""
Local aNtTransm		:= {}
Local lGrvOk		:= .F.
Local cNotas		:= ""

aListDfe := GetArrDFe()

DFeMunCarrega(@cCodMunuic,@cDescMunic)

//Montando XML para Transmissao do Evento de vinculacao de DF-e na MDF-e
cXml += '<envEvento>'
cXml += 	'<eventos>'
cXml += 		'<detEvento>'
cXml += 			'<tpEvento>'+ DFEEVENTO + '</tpEvento>'
cXml += 			'<chNFe>' + cChaveMDFe + '</chNFe>' //Chave do MDFe para incluao dos DFe
cXml += 			'<cMunCarrega>' + AllTrim(cCodMunuic) + '</cMunCarrega>' //Codigo do Municipio de carregamento
cXml += 			'<xMunCarrega>' + AllTrim(cDescMunic) + '</xMunCarrega>' //Nome do Municipio de carregamento

For nI := 1 To len(aListDfe)
	If aListDfe[nI,DFESELEC] .And. !(aListDfe[nI,DFESTATUS] == EVEVINCULADO) //Transmite as notas que foram selecionadas e que nao estavam vinculadas.
		aAdd(aNtTransm, { nI, aListDfe[nI,DFERECNO], SubsTr(aListDfe[nI,DFETIPONT],1,1), aListDfe[nI,DFESTATUS] } )
		cXml += 		'<infDoc>' //Grupo com as infos dos docs a serem inseridos no MDFe
		cXml += 			'<cMunDescarga>' + AllTrim(GetUfSig(UfDescar)) + AllTrim(aListDfe[nI,DFECMUNDE]) + '</cMunDescarga>' //Cod. do municipio de Descarregamento
		cXml += 			'<xMunDescarga>' + AllTrim(aListDfe[nI,DFENMUNDE]) + '</xMunDescarga>' //Nome do municipio de Descarregamento
		cXml += 			'<chDFe>' + aListDfe[nI,DFECHVMDF] + '</chDFe>' //Chave do DFe (Nota) informada no MDFe para
		cXml += 		'</infDoc>'

		cNotas += aListDfe[nI,DFESERNT] + "/" + aListDfe[nI,DFENUMNT] + CRLF
	EndIf
Next nI

cXml += 		'</detEvento>'
cXml += 	'</eventos>'
cXml += '</envEvento>'

lGrvOk := DFeGrvNota(aNtTransm) //Grava dados do MDF-e na Nota

If lGrvOk
	If lUsaColab
		//TODO: Codificar caso seja Colaboracao
	Else
		aRetRemessa := RemessaDFe(cXml) 
		lRet := aRetRemessa[1] //[1] -> Sucesso Execucao WS 
		cRet := aRetRemessa[2] //[2] -> Mensagem

		If !lRet //Problemas ao tentar transmitir
			DFeGrvNota(aNtTransm,.T.) //Remove a gravacao dados do MDF-e na Nota
			Aviso(STR0599,cRet,{STR0114},3) //#"Transmissão de Inclusão de DF-e" ##"OK" 

		Else //Transmissao OK
			cMsg := STR0600 + CRLF + CRLF +; //#"Transmissão do evento de inclusao de DF-e realizado com sucesso!"
					STR0601 + CRLF +  cNotas //#"Foram transmitidas as seguitnes notas fiscais:"
			EnvExibLog(cMsg,STR0602) //#"Resultado da transmissão"
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

If !lUsaColab .And. lRet
	aEval(aNtTransm, {|x| iif(x[1], (aListDfe[x[1],DFESTATUS] := EVENAOREALIZADO, aListDfe[x[1],DFEORDEM] := EVORDTRANS, aListDfe[x[1],DFEVINCUL] := .T.), Nil) } )
	SetArrDFe(aListDfe) //Atualiza array do listbox
Endif

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} TransmiCond
Função responsavel por transmitir para o TSS os condutores da MDF-e

@author 	Fernando Bastos
@since 		07.08.2019
@version 	1.00
@param		Nil
@return		lRet: .T.=Sucesso na transmissao / .F.=Falha na transmissao
/*/
//-----------------------------------------------------------------------
Static Function TransmiCond()
Local cErroPost	:= ""
Local aNotaRet	:= {}
Local cEvento	:= INCCONDEVE
Local aNota		:= GetRegMark(aListDocs,7)
Local cNumNota	:= aNota[1][3]
Local cSerNota	:= aNota[1][2]
Local cChave	:= CC0->CC0_CHVMDF

If (CC0->CC0_STATUS == AUTORIZADO .Or. CC0->CC0_TPEVEN == INCCONDEVE) .And. !(lUsaColab)
	aNotaRet := RetMonEven(cChave, cChave,cEvento,"58" )
	IF Empty(aNotaRet)
		aadd (aNotaRet,{oNo,"","","","","","","","",""})
	EndIF
	cErroPost := IIF(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
		MsgInfo(STR0030 + CRLF + cErroPost ) //Houve erro durante a transmissão para o Totvs Services SPED.
		Return .F.
	endif
	aNotaRet := RetEven(cIdEnt,cChave,@aNotaRet)
	cErroPost := IIF(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
		MsgInfo(STR0030 + CRLF + cErroPost ) //Houve erro durante a transmissão para o Totvs Services SPED.
		Return .F.
	endif
Else
	aNotaRet := ColMonIncC (cSerNota,cNumNota)
Endif

//Monta o DetEvento do XML de evento do MDF-e.
MDFeEvento( aNota,cEvento)
If !(lUsaColab)
	aNotaRet := RetMonEven(cChave, cChave,cEvento,"58" )
	aNotaRet := RetEven(cIdEnt,cChave,@aNotaRet)
	If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
		MsgInfo(STR0030 + CRLF + cErroPost ) //Houve erro durante a transmissão para o Totvs Services SPED.
	endif
Endif

//Atualiza a Grid
IncUpdGrid()

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} DFeGrvNota
Função responsavel pela persistencia dos dados da MDF-e nas notas vinculadas

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		aNtTransm: Notas transmitidas
			lRemove: Se remove o vinculo ou nao
@return		lRet: .T.=Atualização realziada com sucesso /.F.=Falha na atualização
/*/
//-----------------------------------------------------------------------
Static Function DFeGrvNota(aNtTransm, lRemove)
Local lRet			:= .T.
Local nI 			:= 0
Local nRecSF		:= 0

Default aNtTransm	:= {}
Default lRemove		:= .F.

Begin Transaction
	For nI := 1 To Len(aNtTransm)
		nRecSF := aNtTransm[nI,2]

		If aNtTransm[nI,3] == '1' //Saida

			SF2->(DbGoto(nRecSF))
			If RecLock("SF2",.F.)
				SF2->F2_SERMDF := iif(lRemove,"", CC0->CC0_SERMDF)
				SF2->F2_NUMMDF := iif(lRemove,"", CC0->CC0_NUMMDF)
				If !Empty(cFilMDF) .and. lFilDMDF2
					SF2->&("F2_"+cFilMDF) := iif(lRemove,"", xFilial("CC0"))
				Endif
				SF2->(MSUnlock())
			Else
				lRet := .F.
			EndIf

		ElseIf aNtTransm[nI,3] == '2' //Entrada

			SF1->(DbGoto(nRecSF))
			If RecLock("SF1",.F.)
				SF1->F1_SERMDF := iif(lRemove,"", CC0->CC0_SERMDF)
				SF1->F1_NUMMDF := iif(lRemove,"", CC0->CC0_NUMMDF)
				If !Empty(cFilMDF)  .and. lFilDMDF2
					SF1->&("F1_"+cFilMDF) := iif(lRemove,"", xFilial("CC0"))
				Endif 
				SF1->(MSUnlock())
			Else
				lRet := .F.
			EndIf
		EndIf

	Next nI

	If lRet
		If lRemove
			lRet := DfeAtuStatus(EVEREALIZADO, STR0603) //MDF-e com Não Vinculado #"Não Vinculado"
		Else
			lRet := DfeAtuStatus(EVENAOREALIZADO, STR0551)  //MDF-e com Vinculado Transmitido #"Transmitido"
		EndIf
	EndIf
End Transaction

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} DfeAtuStatus
Função responsavel por atualizar os campos de status da MDF-e

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		StatusEvento: Novo status da MDF-e
			cMsg: mensagem a ser gravada
@return		lRet: .T.=Sucesso / .F.=Falha
/*/
//-----------------------------------------------------------------------
Static Function DfeAtuStatus(StatusEvento,cMsg)
Local lRet				:= .T.
Default StatusEvento	:= EVENAOREALIZADO
Default cMsg			:= Nil

If RecLock("CC0",.F.)
	CC0->CC0_VINCUL := StatusEvento
	CC0->CC0_STATEV := StatusEvento
	CC0->CC0_TPEVEN := DFEEVENTO
	If cMsg <> Nil
		CC0->CC0_MSGRET := cMsg
	EndIf
	CC0->(MSUnlock())
Else
	lRet := .F.
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} DFeUpdGrid
Função responsavel por atualizar o gride com a lista de notas

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		Nil
@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function DFeUpdGrid()
Local cDfeChv		:= ""
Local cUltEvento	:= ""
Local cUltStatus	:= ""
Local nI			:= 0
Local nJ			:= 0
Local cChaveMDFe	:= CC0->CC0_CHVMDF
Local aDFeEveRet	:= {}
Local lEveAuto		:= .F. //Evento Autorizado?

aListDfe := GetArrDFe()

If lUsaColab
	//TODO:
Else
	aDFeEveRet := RetMonEven(cChaveMDFe,cChaveMDFe,DFEEVENTO,"58")
	aDFeEveRet := RetEvenDfe(cIdEnt,cChaveMDFe,@aDFeEveRet)	//Retorna o status de cada evento
EndIf

If Len(aDFeEveRet) > 0 .And. Len(aDFeEveRet[1]) >= 9
	For nI := 1 To Len(aDFeEveRet)

		For nJ := 1 To len(aDFeEveRet[nI,9])
			cDfeChv		:= AllTrim(aDFeEveRet[nI,9,nJ,3])

			If (nPos := (aScan(aListDfe, {|x| AllTrim(x[DFECHVMDF]) == cDfeChv})) ) > 0
				If !(aListDfe[nPos,DFESTATUS] == EVEVINCULADO) //somente atualiza se nunca foi autorizado
					aListDfe[nPos,DFEVINCUL]	:= .T.							//Vinculado => .T.
					aListDfe[nPos,DFEPROTOC]	:= aDFeEveRet[ni,2]				//Protocolo
					aListDfe[nPos,DFESTATUS]	:= iif((lEveAuto := aDFeEveRet[ni,5] == "6"),EVEVINCULADO,EVENAOVINCULADO)
					aListDfe[nPos,DFEORDEM]		:= iif(aListDfe[nPos,DFESTATUS] == EVEVINCULADO,EVORDAUTOR,EVORDREJEI)
					aListDfe[nPos,DFECMUNDE]	:= iif(!Empty(aDFeEveRet[nI,9,nJ,1]), SubStr(aDFeEveRet[nI,9,nJ,1],3),"") //Cod Municipio
					aListDfe[nPos,DFENMUNDE]	:= aDFeEveRet[nI,9,nJ,2]		//Nome Municipio
					aListDfe[nPos,DFEHISTOR]	:= aDFeEveRet[ni,6]				//Historico Evento

					If lEveAuto
						cUltEvento := EVEVINCULADO
					Else
						cUltEvento := EVENAOVINCULADO
					EndIf

					cUltStatus := aListDfe[nPos,DFEHISTOR]
				EndIf
			EndIf
		Next nJ
	Next nI

	If !Empty(cUltEvento) .And. !(CC0->CC0_VINCUL == cUltEvento) 	//Atualiza status do vinculo para o ultimo status do ultimo evento
		DfeAtuStatus(cUltEvento, cUltStatus)
	EndIf

EndIf

SetArrDFe(aListDfe, .T.)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} EvRecXml()
Ação do botao de Rec.XML

@author		Felipe Sales Martinez (FSM)
@since		27.08.2019
@version 	1.00
@param 		Nil
@Return		Nil
/*/
//-----------------------------------------------------------------------
Static function EvRecXml()
Local lOK			:= .F.
Local cChaveMDFe	:= ""
Local cEvXml		:= ""
Local cProtocol		:= ""
Local cErroPost		:= ""
Local cCodEvento	:= ""
Local nPos			:= GetPosEven()
Local aNotaRet		:= {}
Local aLst			:= {}
Local cIdEnt 		:= RetIdEnti(lUsaColab)

If nPos > 0
	If cOpcEvent == "1" //Evento DF-e

		cCodEvento := DFEEVENTO
		If Len((aLst := GetArrDFe())) > 0
			lOK			:= .T.
			cProtocol 	:= aLst[nPos,DFEPROTOC]
		EndIf

	ElseIf cOpcEvent == "2" //Evento Incluir Condutor

		cCodEvento := INCCONDEVE
		If Len((aLst := GetArrCond())) > 0
			lOK			:= .T.
			cProtocol 	:= aLst[nPos,2]
		EndIf

	ElseIf cOpcEvent == "3" //pagamento de Operacao de Transporte

		cCodEvento := INFPAGEVE
		If Len((aLst := GetArrPgt())) > 0
			lOK			:= .T.
			cProtocol 	:= aLst[nPos,2]
		EndIf
	EndIf
EndIf

If lOK
	If !Empty(cProtocol)
		cChaveMDFe	:= CC0->CC0_CHVMDF

		If lUsaColab
			//TODO:
		Else
			aNotaRet := RetMonEven(cChaveMDFe, cChaveMDFe,cCodEvento,"58" )
			aNotaRet := RetEven(cIdEnt,cChaveMDFe,@aNotaRet)
			If (nPos := aScan(aNotaRet, {|x| alltrim(x[2]) == cProtocol})) > 0
				cEvXml := aNotaRet[nPos][8]
			EndIf
		EndIf

		If !Empty(cEvXml)
			Aviso(cCadastro,cEvXml,{STR0114},3)
		Else
			cErroPost := IIF(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
				MsgInfo(STR0030 + CRLF + cErroPost ) //Houve erro durante a transmissão para o Totvs Services SPED.
			EndIf
		EndIf
	Else
		MsgInfo(STR0604 + CRLF + STR0605) //#"Protocolo não identificado!" ##"Por favor verificar o status de transmissão desta nota."
	EndIf
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} IncUpdGrid
Função responsavel por atualizar o grid de inclusao de condutor

@author		Fernando Bastos
@since 		19.08.2019
@version 	1.00
@param		Nil
@return		Atualiza a Grid com todos os condutores		
/*/
//-----------------------------------------------------------------------
static function IncUpdGrid()
Local cStatus	:= ""
Local cChave	:= CC0->CC0_CHVMDF
Local nX		:= 0
Local aRetNota	:= {}

aCondu := {}

If lUsaColab
	//TODO:
Else
	aRetNota := RetMonEven(cChave,cChave,INCCONDEVE,"58" )
	aRetNota := RetEven(cIdEnt,cChave,@aRetNota)
	If Len(aRetNota) > 0 .And. Len(aRetNota[1]) <= 7 //problemas na recuperação das notas e dados adicionais
		aRetNota := {}
	EndIf
EndIf

IF Empty(aRetNota)
	aadd (aRetNota,{"","","","","","","","","",""})
EndIF

For nX := 1 To Len(aRetNota)

	if aRetNota[nX][5] $ "6"			//Autorizado
		cStatus := EVEVINCULADO		
	ElseIf aRetNota[nX][5] $ "3|5"		//Rejeitado
		cStatus := EVENAOVINCULADO
	ElseIf aRetNota[nX][5] $ "1|2|4"	//Transmitido 
		cStatus := EVENAOREALIZADO    
	Else								//Nao Transmitido  
		cStatus := EVEREALIZADO
	EndIF

	AADD(aCondu, {cStatus,aRetNota[nX][2],aRetNota[nX][3],aRetNota[nX][4],aRetNota[nX][5],aRetNota[nX][6],aRetNota[nX][9],aRetNota[nX][10]} )
Next nX 

SetArrCond(aCondu, .T.)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RemessaDFe
Função responsavel por comunicar-se com o TSS para a realização da trans-
missão das DF-e

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		cXMl: XML compelto para transmissao da DF-e
@return		lRet: .T. = Sucesso no envio / .F. Falha no envio	
/*/
//-----------------------------------------------------------------------
Static Function RemessaDFe(cXml)
Local lRet		:= .F.
Local cIdEnt	:= RetIdEnti(lUsaColab)
Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cRetorno	:= ""

Private oWsDfe	:= Nil

oWsDfe:= WsNFeSBra():New() 	// Chamado do metodo e envio
oWsDfe:cUserToken	:= "TOTVS"
oWsDfe:cID_ENT		:= cIdEnt
oWsDfe:cXML_LOTE	:= cXml
oWsDfe:_URL			:= AllTrim(cURL)+"/NFeSBRA.apw"

If oWsDfe:RemessaEvento()
	lRet := .T.
	If Type("oWsDfe:oWsRemessaEventoResult:cString") <> "U"
		If Type("oWsDfe:oWsRemessaEventoResult:cString") <> "A"
			aRetorno := {oWsDfe:oWsRemessaEventoResult:cString}
		Else
			aRetorno := oWsDfe:oWsRemessaEventoResult:cString
		EndIf
		cRetorno := aRetorno[1]
	EndIf
Else
	lRet := .F.
	cRetorno := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
EndIf

Return { lRet, cRetorno }

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetEvenDfe()
Função que executa os webservices de consulta do Evento NfeRetornaEvento
para DF-e

@author		Felipe Sales Martinez
@since 		19.08.2019
@version 	1.00
@param		cIdEnt: Entidade da empresa
		 	cChave: Chave para Consulta
		 	aNotaRet: Array com o Evento NfeRetornaEvento
@Return		aDados: Lista com o retorno da consulta
/*/
//-----------------------------------------------------------------------
Static Function RetEvenDfe(cIdEnt,cChave,aEventRet, cTagArr, aTag, aTag2)
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cErro			:= ""
Local cAviso		:= ""
Local cIdEven		:= ""
Local nX			:= 0
Local nPos			:= 0
Local aDados		:= {}
Local cErroPost		:= ""
local aTagRet		:= {}

default cChave 		:= ""
default cIdEnt 		:= ""
default aEventRet	:= {}
default cTagArr 	:= "eventoMDFe|infEvento|detEvento|evIncDFeMDFe|infDoc"
default aTag		:= {"cMunDescarga", "xMunDescarga", "chNFe"}
default aTag2		:= {"eventoMDFe|infEvento|dhEvento"}

// Executa o metodo NfeRetornaEvento()
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN	:= "TOTVS"
oWS:cID_ENT		:= cIdEnt
oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
oWS:cEvenChvNFE	:= cChave

If Len(aEventRet) > 0 
	If oWS:NFERETORNAEVENTO()
		// Tratamento do retorno do evento
		If ValType(oWS:oWsNfeRetornaEventoResult) <> "U" .And. ValType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"
			
			aDados := oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento

			For nX := 1 To Len(aDados)
				cIdEven := aDados[nX]:CID_EVENTO

				If (nPos := aScan(aEventRet ,{|x| x[3] == cIdEven } )) > 0
					aAdd(aEventRet[nPos],aDados[nX]:CXML_SIG)	//Add o XML ao array de informação para cada evento enviado
					aAdd(aEventRet[nPos],{})					//1- Cod Municipio //2 - Nome Municipio //3 - Chave DFe
					aAdd(aEventRet[nPos],aDados[nX]:NLOTE)	 	//Numero do lote
					aAdd(aEventRet[nPos],"") 					//Data e hora

					If len(aTag) > 0 .and. !empty(cTagArr) .and. Len((aTagRet := DFeDadosXMl(aDados[nX]:CXML_SIG,cTagArr,aTag,@cAviso,@cErro))) > 0 .And. !Empty(aTagRet[1])
						aEventRet[nPos][09] := aTagRet	//1- Cod Municipio //2 - Nome Municipio //3 - Chave DFe
					EndIf

					If len(aTag2) > 0 .and. Len((aInfoRet := ColDadosXMl(aDados[nX]:CXML_SIG,aTag2,@cAviso,@cErro))) > 0 .and. !empty(aInfoRet[1])
						aEventRet[nPos][11] := aInfoRet[1] //Data e hora
					EndIf

				EndIf
			Next nX

		Endif
	Else
		cErroPost := if(empty(getWscError(3)),getWscError(1),getWscError(3)) 
		If !Empty(cErroPost) .And. "WSCERR044" $ cErroPost
			Aviso(cCadastro,cErroPost,{STR0114},3)
		endif
	EndIf
EndIf

Return aEventRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RefresEvento
Acao do botao Refresh da tela de monitor de evento

@author 	Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		Nil
@return		.T.
/*/
//-----------------------------------------------------------------------
Static Function RefresEvento()

If cOpcEvent == "1" //DF-e
	DFeUpdGrid()
ElseIf cOpcEvent == "2" //Incluir Condutor
	IncUpdGrid()
ElseIf cOpcEvent == "3" //Pagamento da operação de transporte
	PgtUpdGrid()
EndIf

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetArrDFe
Retorna estrutura de dados do listbox da DFe do monitor de Evento

@author 	Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@return		aDfe - Array com as estrutura de dados do array do listbox 
			do monitor de Evento
/*/
//-----------------------------------------------------------------------
Static Function GetArrDFe()
Return oLstBoxDfe:aArray

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetArrDFe
Atualiza a estrutura de dados do listbox da DFe do monitor de Evento

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function SetArrDFe(aList, lRefresh)
Default aList 	:= Nil
Default lRefresh:= .F.

If aList <> Nil
	If lRefresh .And. Len(aList) > 1
		aList := Asort(aList,,,{|x,y| x[DFEORDEM]+x[DFETIPONT]+x[DFESERNT]+x[DFENUMNT] < y[DFEORDEM]+y[DFETIPONT]+y[DFESERNT]+y[DFENUMNT] })
	EndIf

	oLstBoxDfe:aArray := aList
	aListDfe := oLstBoxDfe:aArray
	
	If lRefresh
		oLstBoxDfe:nAt := 1
		oLstBoxDfe:Refresh()
	EndIf
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetArrCond
Retorna estrutura de dados do listbox da DFe do monitor de Evento

@author 	Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@return		aDfe - Array com as estrutura de dados do array do listbox 
			do monitor de Evento
/*/
//-----------------------------------------------------------------------
Static Function GetArrCond()
Return oLstCond:aArray

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetArrCond
Retorna estrutura de dados do listbox da DFe do monitor de Evento

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function SetArrCond(aList, lRefresh)
Default aList 	:= Nil
Default lRefresh:= .F.

If aList <> Nil
	oLstCond:aArray := aList
	aCondu := oLstCond:aArray
	If lRefresh
		oLstCond:nAt := 1
		oLstCond:Refresh()
	EndIf
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetPosCond
Retorna a posição atual do gride de eventos

@author 	Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@return		nPos: Posição atual do gride
/*/
//-----------------------------------------------------------------------
Static Function GetPosEven()
Local nPos := 0

If cOpcEvent == "1"
	nPos := oLstBoxDfe:nAt
ElseIf cOpcEvent == "2"
	nPos := oLstCond:nAt
ElseIf cOpcEvent == "3"
	nPos := oLstPagto:nAt
EndIf

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} DFeDadosXMl
Retorna dados do xml de acordo com o informado no parametros

@author		Felipe Sales Martinez (FSM)
@since		16/08/2019
@version	1.0 
@param		cXml: XML completo da transmissao
			cTagArr: Caminho do xml onde a informação do array com os 
			dados estao
			aTag: Campos do array do cTagArr
			cErro: Tratamento de erro
			cAviso: Tratamento de aviso
@return		ainfo: Informações do xml para as tags informadas
/*/
//-------------------------------------------------------------------
Static function DFeDadosXMl(cXml, cTagArr, aTag, cErro, cAviso)
Local aInfo	:= {}
Local nI	:= 0
Local nx	:= 0

Private oXml := Nil
Private aXmlDfe := {}
	
cXml := XmlClean(cXml)
oXml := XmlParser(encodeUTF8(cXml),"_",@cAviso,@cErro)

If oXml == nil
	oXml := XmlParser(cXml,"_",@cAviso,@cErro) 
Endif

If Empty(cAviso + cErro )

	cArrDoc := "oXml:_" + StrTran( cTagArr , "|" , ":_")
	If Type(cArrDoc) == "A"
		aXmlDfe := &(cArrDoc)
	ElseIf Type(cArrDoc) == "O"
		aAdd(aXmlDfe, &(cArrDoc)   )
	EndIf

	For nI := 1 To Len(aXmlDfe)
		aAdd(aInfo,{})
		For nx := 1 To len(aTag)
			cTag := "aXmlDfe["+cValToChar(nI)+"]:_"+aTag[nx]+":TEXT"
			If Type(cTag) <> "U"
				aAdd(aInfo[nI],&(cTag))
			EndIf
		Next nX
	Next 

Endif

oXml := Nil
DelClassIntF()

return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlClean
Retira e valida algumas informações e caracteres indesejados para o 
parse do XML.

@author		Felipe Sales Martinez (FSM)
@since		16/08/2019
@version	1.0 
@param		cXml, string, XML que será feito a validação e a retirada
			dos caracteres especiais
@return		cRetorno - XML limpo
/*/
//-------------------------------------------------------------------
Static Function XmlClean( cXml )
Local cRetorno	:= ""

DEFAULT cXml	:= ""

If ( !Empty(cXml) )
	cRetorno := Alltrim(cXml)
	/* < - &lt; 	> - &gt; 	& - &amp; 	" - &quot; 	' - &#39; */
	If !( "&amp;" $ cRetorno .or. "&lt;" $ cRetorno .or. "&gt;" $ cRetorno .or. "&quot;" $ cRetorno .or. "&#39;" $ cRetorno )
		cRetorno := StrTran(cRetorno,"&","&amp;amp;") //Retira caracteres especiais e faz a substituição
	EndIf
EndIf
Return cRetorno  

//-------------------------------------------------------------------
/*/{Protheus.doc} DFeVldMun
Função responsavel por Validar o codigo do municipio informado

@author		Felipe Sales Martinez (FSM)
@since 		16/08/2019
@version	1.0 
@param		cXml, string, XML que será feito a validação e a retirada
			dos caracteres especiais
@return		lRet - .T.: Codgo valido / .T.: Codigo invalido
/*/
//-------------------------------------------------------------------
Static Function DFeVldMun(cCodMun, cNomeMun, cUf)
Local lRet := .T.

Default cCodMun		:= ""
Default cNomeMun	:= ""
Default cUf			:= ""

If !Empty(cCodMun) 
	CC2->(DBSetOrder(1))//"CC2_FILIAL+CC2_EST+CC2_CODMUN"
	If CC2->(DBSeek(xFilial("CC2")+cUf+cCodMun))
		cNomeMun := Padr(CC2->CC2_MUN,Len(cNomeMun))
	Else
		MsgInfo(STR0606 +CRLF+CRLF+; //"Codigo de Municipio não existe."
				STR0607, STR0539 ) //#"Por favor informar um codigo valido." #"Atenção"
		lRet := .F.
	EndIf
Else
	cNomeMun := space( getSx3Cache( "CC2_MUN", "X3_TAMANHO") ) // CriaVar("CC2_MUN")
EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} DFeSetMunNF
Exibe a dialog com o municipio de carregamento da NF (DF-e)

@author		Felipe Sales Martinez (FSM)
@since		19/08/2019
@version	1.0
@Return		lRet - .T. -> Botão OK / .F. -> Botao Cancelar
/*/
//-----------------------------------------------------------------------
Static Function DFeSetMunNF(nPos)
	Local lRet		:= .F.
	Local oDlgMun 	:= NIl
	Local oBoxMun 	:= Nil
	Local cFiltroCC2:= ""
	Local cTpNf		:= ""
	Local cUF		:= AllTrim(CC0->CC0_UFFIM)
	Local aNotas	:= {}
	Local aCC2Area	:= {}

	Default nPos	:= 0

	Private oGetCodMun := ""
	Private oGetDesMun := ""

	If nPos > 0
		aCC2Area 	:= CC2->(GetArea())
		aNotas		:= GetArrDFe()
		cSerNota	:= Padr(aNotas[nPos, DFESERNT],TamSx3("F2_SERIE")[1])
		cDocNota	:= Padr(aNotas[nPos, DFENUMNT],TamSx3("F2_DOC")[1])
		cCliNota	:= Padr(aNotas[nPos, DFECLINF],TamSx3("F2_CLIENTE")[1])
		cLojaNota	:= Padr(aNotas[nPos, DFELJCLI],TamSx3("F2_LOJA")[1])
		cFilOri		:= Padr(aNotas[nPos, DFEFILORI],TamSx3("F2_FILIAL")[1])
		cTpNf		:= SubStr(aNotas[nPos, DFETIPONT],1,1)
		cCodMun		:= GetMunIbge(cSerNota,cDocNota,cCliNota,cLojaNota,cTpNf,cFilOri)

		// Ponto de entrada para definir o código do município e trazer automático
		If ExistBlock("MDFeMun")
			cCodMun := ExecBlock("MDFeMun", .F., .F.,{cEntSai,cSerNota,cDocNota,cCliNota,cLojaNota})
		EndIf

		//Monta o Filtro na CC2 com a UF de descarregamento
		//Este ponto eh importante para que so sejam apresentados os municipios da UF marcada
		cFiltroCC2 := "CC2->CC2_EST == '" + cUF + "' .And. CC2->CC2_FILIAL == '" + xFilial("CC2") + "'"

		DEFINE MSDIALOG oDlgMun TITLE STR0580 From 0,0 TO 250,455 OF oMainWnd PIXEL //#"Município Descarregamento" 

			nLin := 35
			nCol := 05
			oBoxMun:= TGroup():Create(oDlgMun,nLin,nCol,120,225,STR0608,,,.T.) //Box Municipio Carregamento #"Descarga de Mercadorias"

			nLin += 20
			nCol := 15
			oSayUFDes:= TSAY():New(nLin+2,nCol,{|| STR0609 },oBoxMun,,,,,,.T.,,,, ) //"UF de Descarregamento: "
			nCol += 67
			TGet():New(nLin,nCol,{|u| If(PCount()>0,cUF:=u,cUF)},oBoxMun, 13, 10,PesqPict("CC2","CC2_EST"),,,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F. ,,"cUF")

			nLin += 20
			nCol := 15
			oSayUFDes:= TSAY():New(nLin+2,nCol,{|| STR0610},oBoxMun,,,,,,.T.,,,, ) //#"Município de Descarregamento: "
			nCol += 80
			TGet():New(nLin,nCol,{|u| If(PCount()>0,cCodMun:=u,cCodMun)},oBoxMun,  15, 10,PesqPict("CC2","CC2_CODMUN"),{|| DFeVldMun(cCodMun,@cNomeMun,cUF) },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,'F3CC2("'+cFiltroCC2+'","'+cUF+'")',"cCodMun")

			nLin += 20
			nCol := 15
			oSayUFDes:= TSAY():New(nLin+2,nCol,{|| STR0611},oBoxMun,,,,,,.T.,,,, ) //#"Nome: "
			nCol += 20
			TGet():New(nLin,nCol,{|u| If(PCount()>0,cNomeMun:=u,cNomeMun)},oBoxMun, 180, 10, PesqPict("CC2","CC2_MUN"),,,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F. ,,"cNomeMun")

		ACTIVATE DIALOG oDlgMun CENTERED ON INIT EnchoiceBar(oDlgMun, {||( lRet := .T., oDlgMun:End() )} , {||( lRet := .F., oDlgMun:End() )},,,,,.F.,.F.,.F.,.T.,.F.)

		//Verifica se a UF do municipio é a mesma da UF Descarga
		If lRet
			If !Empty(cCodMun)
				aNotas[nPos,DFECMUNDE] := cCodMun
				aNotas[nPos,DFENMUNDE] := cNomeMun
				SetArrDFe(aNotas)
			Else
				lRet := .F. //Não marcar caso nao tenha sido informado nada
			EndIf
		EndIf
		RestArea(aCC2Area)
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} DFeMunCarrega
Função responsável por retornar o codigo do municipio informado no XML 
do MDF-e enviado.

@author		Felipe Sales Martinez (FSM)
@since		19.08.2019
@version	1
@Return		cCodMun: Codigo do municipio preente no XML
/*/
//-----------------------------------------------------------------------
Static Function DFeMunCarrega(cCodMun,cNomeMun)
Local cError	:= ""
Local cWarning	:= ""
Local oXML		:= XmlParser(CC0->CC0_XMLMDF,"",@cError,@cWarning)

Private aMunCar	:= {}

If ValType(oXML) == "O"
	aMunCar := GetMDeInfo(oXML,"_MDFE:_INFMDFE:_IDE:_INFMUNCARREGA")
EndIf

If Type("aMunCar") <> "U"
	If Type("aMunCar:_CMUNCARREGA:TEXT") == "C" .And. !Empty(aMunCar:_CMUNCARREGA:TEXT)
		cCodMun := aMunCar:_CMUNCARREGA:TEXT
	EndIf
	If Type("aMunCar:_XMUNCARREGA:TEXT") == "C" .And. !Empty(aMunCar:_XMUNCARREGA:TEXT)
		cNomeMun := aMunCar:_XMUNCARREGA:TEXT
	EndIf
EndIf

Return cCodMun

//-----------------------------------------------------------------------
/*/{Protheus.doc} DFeIncGrid
Função responsavel por montar os dados a serem apresentados no gride das 
notas a serem apresentada na opção de NF-es (DF-e)

@author		Felipe Sales Martinez (FSM)
@since		30.08.2019
@version	1.00
@param		Nil	
@return		
/*/
//-----------------------------------------------------------------------
Static Function DFeIncGrid()
Local cStatus		:= ""
Local cOrd			:= ""
Local nI			:= 0
Local nJ			:= 0
Local aList			:= {}
Local aNotas		:= RetNFeVinc()
Local aDFeEveRet	:= {}
Local cChaveMDFe	:= CC0->CC0_CHVMDF
Local cUltEvento	:= ""
Local cUltStatus	:= ""

if lUsaColab
	//TODO:
Else
	aDFeEveRet := RetMonEven(cChaveMDFe,cChaveMDFe,DFEEVENTO,"58")
	aDFeEveRet := RetEvenDfe(cIdEnt,cChaveMDFe,@aDFeEveRet)	//Retorna o status de cada evento
EndIf

If Len(aDFeEveRet) > 0 .And. Len(aDFeEveRet[1]) >= 9

	For nI := 1 To Len(aDFeEveRet)

		For nJ := 1 To len(aDFeEveRet[nI,9])

			cDfeChv := AllTrim(aDFeEveRet[nI,9,nJ,3])

			nPosVinc := aScan(aNotas, {|x| AllTrim(x[1]) == cDfeChv }) //busca a chave no array com as notas vinculadas
			If (nPosList := aScan(aList, {|x| AllTrim(x[DFECHVMDF]) == cDfeChv })) == 0 //busca no array das lista a ser apresentada //para casos de notas enviadas em mais de um evento
				aAdd(aList,RetDfeArr())
				nPosList := Len(aList)
			EndIf

			If aDFeEveRet[nI,5] == "6"			//Autorizado
				cStatus := EVEVINCULADO
				cOrd	:= EVORDAUTOR
			ElseIf aDFeEveRet[nI,5] $ "3|5"		//Rejeitado
				cStatus := EVENAOVINCULADO
				cOrd	:= EVORDREJEI
			ElseIf aDFeEveRet[nI,5] $ "1|2|4"	//Transmitido 
				cStatus := EVENAOREALIZADO
				cOrd	:= EVORDTRANS
			Else								//Nao Transmitido  
				cStatus := EVEREALIZADO
				cOrd	:= EVORDNAOTR
			Endif

			If !(aList[nPosList,DFESTATUS] == EVEVINCULADO)
				aList[nPosList,DFESELEC]	:= .F.						//Selecionada ou nao
				aList[nPosList,DFESTATUS]	:= cStatus					//Situacao da nota no MDF-e
				aList[nPosList,DFEORDEM]	:= cOrd						//ordem apresentacao
				aList[nPosList,DFEPROTOC]	:= aDFeEveRet[nI,2]			//Protocolo DF-e
				aList[nPosList,DFEHISTOR]	:= aDFeEveRet[nI,6]			//Historico do evento
				aList[nPosList,DFECHVMDF]	:= cDfeChv					//Chave Nota
				aList[nPosList,DFEVINCUL]	:= .T.						//Registro ja vinculado?
				aList[nPosList,DFENMUNDE]	:= aDFeEveRet[nI,9,nJ,2]	//Nome Munucipio Descarregamento
				aList[nPosList,DFECMUNDE]	:= iif(!Empty(aDFeEveRet[nI,9,nJ,1]), SubStr(aDFeEveRet[nI,9,nJ,1],3),"")	//Codigo Munucipio Descarregamento
				If nPosVinc > 0
					aList[nPosList,DFESERNT]	:= aNotas[nPosVinc,2]		// Serie Nota
					aList[nPosList,DFENUMNT]	:= aNotas[nPosVinc,3]		// Numero Nota
					aList[nPosList,DFEVLRNT]	:= aNotas[nPosVinc,4]		// Valor Nota
					aList[nPosList,DFECLINF]	:= aNotas[nPosVinc,5]		// Codigo do cliente da NF (DF-e)
					aList[nPosList,DFELJCLI]	:= aNotas[nPosVinc,6]		// Loja do cliente da NF (DF-e)
					aList[nPosList,DFETIPONT]	:= aNotas[nPosVinc,7]		// Tipo Entrada ou Saida?
					aList[nPosList,DFERECNO]	:= aNotas[nPosVinc,8]		// Numero do RECNO do registro na tabela (SF1 ou SF2)
					aList[nPosList,DFEFILORI]	:= aNotas[nPosVinc,9]		// Filial original da nota
				Else
					aList[nPosList,DFEHISTOR]	:= STR0618 //Historico do evento #"Problema Integridade: Esta Nota Fiscal não está vinculada a esta MDF-e no Protheus"
				EndIf

				cUltEvento := cStatus
				cUltStatus := aList[nPosList,DFEHISTOR]
			EndIf

			If nPosVinc > 0
				aDel(aNotas,nPosVinc)
				aSize(aNotas,Len(aNotas)-1)
			EndIf

		Next nJ

	Next nI

EndIf

//Notas vinculadas no protheus mas não encontradas no Evento (ou por erro de comunicação ou por inconsistencia na base)
For nI := 1 To Len(aNotas)
	cDfeChv := AllTrim(aNotas[nI,1])
	If (nPosList := aScan(aList, {|x| AllTrim(x[DFECHVMDF]) == cDfeChv })) == 0 //busca no array das lista a ser apresentada //para casos de notas enviadas em mais de um evento
		aAdd(aList,RetDfeArr())
		nPosList := Len(aList)
		aList[nPosList,DFESTATUS]	:= iif(CC0->CC0_CARPST=="1",EVENAOREALIZADO,EVEVINCULADO)	//Status do evento
		aList[nPosList,DFEVINCUL]	:= .T.				//Vinculado
		aList[nPosList,DFEORDEM]	:= EVORDTRANS		//Ordem evento
		aList[nPosList,DFECHVMDF]	:= aNotas[nI,1]		//Chave Nota
		aList[nPosList,DFESERNT]	:= aNotas[nI,2]		//Serie Nota
		aList[nPosList,DFENUMNT]	:= aNotas[nI,3]		//Numero Nota
		aList[nPosList,DFEVLRNT]	:= aNotas[nI,4]		//Valor Nota
		aList[nPosList,DFECLINF]	:= aNotas[nI,5]		//Codigo do cliente da NF (DF-e)
		aList[nPosList,DFELJCLI]	:= aNotas[nI,6]		//Loja do cliente da NF (DF-e)
		aList[nPosList,DFETIPONT]	:= aNotas[nI,7]		//Tipo Entrada ou Saida?
		aList[nPosList,DFERECNO]	:= aNotas[nI,8]		//Numero do RECNO do registro na tabela (SF1 ou SF2)
		aList[nPosList,DFEFILORI]	:= aNotas[nI,9]		//Filial original da nota
	EndIf
Next nI

If Len(aList) == 0
	aAdd(aList,RetDfeArr())
EndIf

SetArrDFe(aList, .T.)

aSize(aNotas,0)
aNotas := Nil

If !Empty(cUltEvento) .And. !(CC0->CC0_VINCUL == cUltEvento) 	//Atualiza status do vinculo para o ultimo status do ultimo evento
	DfeAtuStatus(cUltEvento, cUltStatus)
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetNFeVinc
Função repsonsavel por retornar array com as notas (NF-e) vinculadas ao 
MDF-e selecionado

@author 	Felipe Sales Martinez (FSM)
@since 		30.08.2019
@version 	1.00
@param		Nil
@return		aListNf: Array com as notas viculadas a MDF-e
/*/
//-----------------------------------------------------------------------
Static Function RetNFeVinc()
Local aListNf	:= {}
Local cQuery	:= ""
Local cAlias	:= GetNextAlias()

cQuery += "SELECT F2_CHVNFE AS CHAVE_NFE, F2_SERIE AS SERIE, F2_DOC AS NUMERO, F2_VALBRUT AS VALOR, '' AS PROTOCOLO, SF2.R_E_C_N_O_ AS RECNO, '1-Saida' AS TIPO"
cQuery += ", F2_NUMMDF AS NUMMDFE, F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJACLI, F2_FILIAL FILORI"
cQuery += " FROM " + RetSqlName("SF2") + " SF2"
cQuery += " WHERE SF2.D_E_L_E_T_ = ' '"
cQuery += " AND SF2.F2_ESPECIE = 'SPED' AND SF2.F2_FIMP <> 'D' AND SF2.F2_CHVNFE <> ' '"
cQuery += " AND SF2.F2_NUMMDF = '" + CC0->CC0_NUMMDF + "' AND SF2.F2_SERMDF = '" + CC0->CC0_SERMDF + "'"
cQuery += " UNION "
cQuery += "SELECT F1_CHVNFE AS CHAVE_NFE, F1_SERIE AS SERIE, F1_DOC AS NUMERO, F1_VALBRUT AS VALOR, '' AS PROTOCOLO, SF1.R_E_C_N_O_ AS RECNO, '2-Entrada' AS TIPO"
cQuery += ", F1_NUMMDF AS NUMMDFE, F1_FORNECE AS CLIENTE, F1_LOJA AS LOJA, F1_FILIAL FILORI"
cQuery += " FROM " + RetSqlName("SF1") + " SF1"
cQuery += " WHERE SF1.D_E_L_E_T_ = ' '"
cQuery += " AND SF1.F1_ESPECIE = 'SPED' AND SF1.F1_FIMP <> 'D' AND SF1.F1_CHVNFE <> ' '"
cQuery += " AND SF1.F1_NUMMDF = '" + CC0->CC0_NUMMDF + "' AND SF1.F1_SERMDF = '" + CC0->CC0_SERMDF + "'"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

While (cAlias)->(!Eof())
	aAdd(aListNf, {	/*1*/(cAlias)->CHAVE_NFE,;
					/*2*/(cAlias)->SERIE,;
					/*3*/(cAlias)->NUMERO,;
					/*4*/(cAlias)->VALOR,;
					/*5*/(cAlias)->CLIENTE,;
					/*6*/(cAlias)->LOJACLI,;
					/*7*/(cAlias)->TIPO,;
					/*8*/(cAlias)->RECNO,;
					/*9*/(cAlias)->FILORI } )
	(cAlias)->(dbSkip())
EndDo

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

Return aListNf

//-----------------------------------------------------------------------
/*/{Protheus.doc} HistEvento
Função responsavel por logica do ação do botão Mensagens do mintor de eventos

@author		Felipe Sales Martinez (FSM)
@since		30.08.2019
@version 	1.00
@param		Nil
@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function HistEvento()
Local aHist := {}

If cOpcEvent == "1" //DF-e
	aHist := DFeHist(DFEEVENTO)
ElseIf cOpcEvent == "2" //Incluir Condutor
	aHist := ICondHist()
ElseIf cOpcEvent == "3" //Pagamento de operacao de transporte
	aHist := DFeHist(INFPAGEVE)
EndIf

EvShowMsg(aHist) //Mota tela

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} ICondHist
Função responsavel por montar array com dos dados a serem exibidos na tela
de mensagens do evento de incluir condutor

@author		Felipe Sales Martinez (FSM)
@since		30.08.2019
@version 	1.00
@param	
@return		aHist: Array con os dados a serem exibidos na tela de mensagem
			do evento
/*/
//-----------------------------------------------------------------------
Static Function ICondHist()
Local cData			:= ""
Local cHora			:= ""
Local aHist			:= {}
Local cChaveMDFe	:= CC0->CC0_CHVMDF

If lUsaColab
	//TODO:
Else
	aRetNota := RetMonEven(cChaveMDFe,cChaveMDFe,INCCONDEVE,"58" )
	aRetNota := RetEven(cIdEnt,cChaveMDFe,@aRetNota)
EndIf

If Len(aRetNota) > 0 .And. Len(aRetNota[1]) >= 12
	If Len((aNotas	:= GetArrCond())) > 0 .And. (nPos:= GetPosEven()) > 0
		If !Empty(cProtocol := AllTrim(aNotas[nPos,2]))
			If (nPosHis := aScan(aRetNota, {|x| AllTrim(x[2]) == cProtocol })) > 0

				cData := substr(aRetNota[nPosHis,12],9,2)+"/"+substr(aRetNota[nPosHis,12],6,2)+"/"+substr(aRetNota[nPosHis,12],1,4)
				cHora := substr(aRetNota[nPosHis,12],at("T",aRetNota[nPosHis,12])+1,8)

				aAdd(aHist, {aRetNota[nPosHis,11],;										//Numero Lote
							cData,;														//Data
							cHora,;														//hora
							aRetNota[nPosHis,2],; 										//Protocolo
							iif(aRetNota[nPosHis,4] == "1",STR0612,STR0613),;			//Ambiente #"Produção"##"Homologação"
							iif(aRetNota[nPosHis,5] == "5",STR0553,STR0552),;			//Status #"Rejeitado" ##"Autorizado"
							aRetNota[nPosHis,6],;										//Msg Evento
							aRetNota[NposHis,3]})										//ID Evento
			EndIf
		EndIf
	EndIf
EndIf

Return aHist

//-----------------------------------------------------------------------
/*/{Protheus.doc} DFeHist
Função responsavel por montar array com dos dados a serem exibidos na tela
de mensagens do evento de DF-e

@author		Felipe Sales Martinez (FSM)
@since		30.08.2019
@version 	1.00
@param		Nil
@return		aHist: Array con os dados a serem exibidos na tela de mensagem
			do evento
/*/
//-----------------------------------------------------------------------
Static Function DFeHist(cEvento)
Local cData			:= ""
Local cHora			:= ""
Local aHist			:= {}
Local aDFeEveRet	:= {}
Local cChaveMDFe	:= CC0->CC0_CHVMDF

Default cEvento		:= DFEEVENTO

If lUsaColab
	//TODO:
Else
	aDFeEveRet := RetMonEven(cChaveMDFe,cChaveMDFe,cEvento,"58")
	aDFeEveRet := RetEvenDfe(cIdEnt,cChaveMDFe,@aDFeEveRet)	//Retorna o status de cada evento
EndIf

If Len(aDFeEveRet) > 0 .And. Len(aDFeEveRet[1]) >= 9

	If cEvento == INFPAGEVE
		aNotas	:= GetArrPgt()
		nPosProt := 2
	Else
		aNotas	:= GetArrDFe()
		nPosProt := DFEPROTOC
	EndIf

	If Len(aNotas) > 0 .And. (nPos:= GetPosEven()) > 0
		If !Empty(cProtocol := AllTrim(aNotas[nPos,nPosProt]))
			If (nPosHis := aScan(aDFeEveRet, {|x| AllTrim(x[2]) == cProtocol })) > 0

				cData := substr(aDFeEveRet[nPosHis,11],9,2)+"/"+substr(aDFeEveRet[nPosHis,11],6,2)+"/"+substr(aDFeEveRet[nPosHis,11],1,4)
				cHora := substr(aDFeEveRet[nPosHis,11],at("T",aDFeEveRet[nPosHis,11])+1,8)

				aAdd(aHist, {aDFeEveRet[nPosHis,10],;										//Numero Lote
							cData,;															//Data
							cHora,;															//hora
							aDFeEveRet[nPosHis,2],; 										//Protocolo
							iif(aDFeEveRet[nPosHis,4] == "1",STR0612,STR0613),;				//Ambiente #"Produção"##"Homologação"
							iif(aDFeEveRet[nPosHis,5] == "5",STR0553,STR0552),;				//Status #"Rejeitado" ##"Autorizado"
							aDFeEveRet[nPosHis,6],; 										//Msg Evento
							aDFeEveRet[NposHis,3]})											//ID Evento
			EndIf
		Else
			MsgInfo(STR0604 + CRLF + STR0605) //#"Protocolo não identificado!" ##"Por favor verificar o status de transmissão desta nota."
		EndIf
	EndIf

EndIf

Return aHist

//-----------------------------------------------------------------------
/*/{Protheus.doc} EvShowMsg
Função responsavel por mostrar mensagens do evento

@author		Felipe Sales Martinez (FSM)
@since		19.08.2019
@version	1.00
@param		Nil
@return		.T.
/*/
//-----------------------------------------------------------------------
Static Function EvShowMsg(aMsg)
Local aSize    := MsAdvSize()
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oDlg
Local oListBox
Local oBtn1

Default aMsg := {}

If !Empty(aMsg)
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE STR0556 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //#"Menssagem do Evento" 
	//"Lote", "Dt.Lote", "Hr.Lote", "Protocolo Evento", "Ambiente", "Status Evento", "Memsagem Retorno", "ID Evento"
	@	aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER STR0060,STR0061,STR0062,STR0586,STR0035,STR0589,STR0614,STR0588;
		SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL

	oListBox:SetArray( aMsg )
	oListBox:bLine := { || {aMsg[ oListBox:nAT,1 ],; 	//Numero Lote
							aMsg[ oListBox:nAT,2 ],;	//Data lote
							aMsg[ oListBox:nAT,3 ],;	//Hora lote
							aMsg[ oListBox:nAT,4 ],;	//Protocolo
							aMsg[ oListBox:nAT,5 ],;	//Ambiente
							aMsg[ oListBox:nAT,6 ],;	//Status Evento
							aMsg[ oListBox:nAT,7 ],;	//Msg retorno
							aMsg[ oListBox:nAT,8 ]} }	//ID EVENTO

	@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT STR0114 ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011 //#OK
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} IncCondVal
Validações dos campos de inclusao de condutores

@author		Felipe Sales Martinez
@since		19.08.2019
@version	1.00
@param	
@return		lret: .T.-Dados validos / .F.-Dados invalidos
/*/
//-----------------------------------------------------------------------
Static Function IncCondVal(cCod, cCPFCon, cNomeCon, aNotaRet)
Local lRet			:= .T.
Local nX			:= 0
Local cSig			:= ""

Default cCod		:= ""
Default cCPFCon		:= ""
Default cNomeCon	:= ""
Default aNotaRet	:= {}

//Não enviar um evento com CNPJ
If len(Alltrim(cCPFCon)) > 11 .OR. Empty(cCPFCon)
	MsgInfo(STR0503)//Informe um CPF Válido
	lRet := .F.

Elseif Empty(cCod) //Não permite a transmissão sem um condutor
	MsgInfo (STR0502) //"Selecione um Condutor!"
	lRet := .F.
EndIf

If lRet 
	//Não enviar um evento com o mesmo condutor
	For nX := 1 To len(aNotaRet)
		If aNotaRet[nX][5] == "135" .Or. aNotaRet[nX][5] == "6" 
			If Len(aNotaRet[nX]) >= 10
				cSig += Iif(empty(aNotaRet[nx][8]),aNotaRet[nx][10],aNotaRet[nx][8])
				If Alltrim(cCPFCon) $ cSig
					MsgInfo(STR0615 + Alltrim(cNomeCon)+ STR0616 + Transform(Alltrim(cCPFCon),"@r 999.999.999-99") +" .") //#"Já exite um evento para o condutor " ##", portador do CPF "
					lRet := .F.
				EndiF
			Else
				aadd(aNotaRet[nX],"")
				aadd(aNotaRet[nX],"")
				aadd(aNotaRet[nX],"")
				cSig += Iif(empty(aNotaRet[nx][8]),aNotaRet[nx][10],aNotaRet[nx][8])
				If Alltrim(cCPFCon) $ cSig
					MsgInfo(STR0615 + Alltrim(cNomeCon) + STR0616 + Transform(Alltrim(cCPFCon),"@r 999.999.999-99") +" .") //#"Já exite um evento para o condutor " ##", portador do CPF "
					lRet := .F.
				EndiF
			EndIf
		Endif
		If !lRet
			Exit
		EndIf
	Next nX
Endif

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} VldVeiculo
Função responsavel por validar o veiculo informado na MDF-e é tipo proprio
quando selecionado a opção de vincula posterior

@author		Felipe Sales Martinez(FSM)
@since		19.08.2019
@version	1.00
@param		cVeiculo - Codigo do veiculo
@return		lRet: .T. = Veiculo permitido / .F. = Veiculo não permitido
/*/
//-----------------------------------------------------------------------
Static Function VldVeiculo(cVeiculo)
Local lRet		:= .T.
Local aDA3Area	:= {}

if lMDFePost
	aDA3Area := DA3->(GetArea())
	DA3->(DBSetOrder(1)) //DA3_FILIAL+DA3_COD
	If !Empty(cVeiculo) .And. DA3->(DBSeek(xFilial("DA3")+cVeiculo))
		If !(DA3->DA3_FROVEI == "1") //Diferente de 1-Frota propria -> Error
			lRet := .F.
			MsgInfo(STR0617,STR0539) //#"Quando selecionada a opção de MDF-e Carrega Posterior: '1-Sim', o veículo informado deverá ser do tipo 'Frota Propria'." #"Atenção"
		EndIf
	EndIf
	RestArea(aDA3Area)
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} EvFormtSer
Função responsavel separar as series informadas nos parametros de busca 
da Nf-e

@author		Felipe Sales Martinez
@since		19.08.2019
@version	1.00
@param		cSerieEvento = Serie(s) do evento para filtro das notas fiscais
@return		cRet: 
/*/
//-----------------------------------------------------------------------
Static Function EvFormtSer(cSerieEvento)
Local cRet		:= ""
Local aEvSer	:= {}
Local nI		:= 1

cSerieEvento := AllTrim(cSerieEvento)

If !Empty(cSerieEvento)
	If Isnumeric(cSerieEvento) .Or. Len(AllTrim(cSerieEvento)) == TamSx3("F2_SERIE")[1]
		cRet := "'" + AllTrim(cSerieEvento) + "'"
	Else
		cRet 	:= StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cSerieEvento,",",";"),"/",";"),"\",";"),"*",";"),"-",";"),"-",";"),",",";")
		aEvSer	:= StrToArray(cRet,";")
		cRet 	:= ""
		For nI := 1 To Len(aEvSer)
			cRet += "'" + aEvSer[nI] + "'"
			If nI <> Len(aEvSer)
				cRet += ","
			EndIf
		Next nI
	EndIf
EndIf
Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} EvLimpaVar
Função responsavel por limpar as variaveis dos parametros do evento 
posicionado

@author		Felipe Sales Martinez
@since		30.08.2019
@version	1.00
@param		NIl
@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function EvLimpaVar()

If cOpcEvent == "2" //Inclusao Condutor
	cNomeCon:= space( getSx3Cache( "DA4_NOME", "X3_TAMANHO") ) // CriaVar("DA4_NOME")
	cCPFCon	:= space( getSx3Cache( "DA4_CGC", "X3_TAMANHO") ) // CriaVar("DA4_CGC")
	cCodCon	:= space( getSx3Cache( "DA4_COD", "X3_TAMANHO") ) // CriaVar("DA4_COD")
EndIf

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} F3CC2
Função responsavel realizar a consulta padrão CC2 com filtro por estado

@author		Felipe Sales Martinez
@since		17.01.2020
@version	1.00
@param		NIl
@return		Nil
/*/
//-----------------------------------------------------------------------
Function F3CC2(cFiltro, cUF)
Local lRet		:= .F.
Local cAnterior	:= ""

If !Empty(cCodMun)
	cAnterior := cUF+cCodMun
EndIf

If (lRet := ConPad1(,,,"CC2",,,.T.,,,cAnterior,,,cFiltro))
	cCodMun := CC2->CC2_CODMUN
	cNomeMun := CC2->CC2_MUN
EndIf
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} Ajstchv
Função responsavel por identificar e substituir a chave da MDF-e e seu 
XML quando há divergencia entre o gravado no Protheus x TSS
Obs.: Problema ocasionado devido a mal tratamento de retorno do status da
mdf-e

@author		Felipe Sales Martinez
@since		04.03.2020
@version	1.00
@param		aTrans: Array com os MDF-es a serem verificados e ajustados
			cXMlEvent: XML para execução do evento
@return		cRet: XML para execução do evento ajustado
/*/
//-----------------------------------------------------------------------
Static Function Ajstchv(aTrans,cXMlEvent)
Local cRet			:= ""
Local cXMlTss		:= ""
Local cChaveTss		:= ""
Local cNewXMl		:= ""
Local cErro			:= ""
Local nPosSig		:= 0
Local nPos			:= 0
Local nI			:= 0

Default aTrans		:= {}
Default cXMlEvent	:= ""

Private oWSMdfe		:= WSNFeSBRA():New()

cRet := cXMlEvent

oWSMdfe:cUSERTOKEN			:= "TOTVS"
oWSMdfe:cID_ENT				:= cIdEnt
oWSMdfe:oWSNFEID			:= NFESBRA_NFES2():New()
oWSMdfe:oWSNFEID:oWSNotas	:= NFESBRA_ARRAYOFNFESID2():New()
oWSMdfe:_URL				:= AllTrim(PadR(GetNewPar("MV_SPEDURL","http://"),250))+"/NFeSBRA.apw"
oWSMdfe:nDIASPARAEXCLUSAO	:= 0
For nI := 1 To Len(aTrans)
	aadd(oWSMdfe:oWSNFEID:oWSNOTAS:oWSNFESID2, NFESBRA_NFESID2():new() )
	oWSMdfe:oWSNFEID:oWSNOTAS:oWSNFESID2[nI]:cID := aTrans[nI][4]
Next nI 

If oWSMdfe:RETORNANOTAS()
	If Type("oWSMdfe:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3") == "A" .And.;
		Len(oWSMdfe:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
		For nI := 1 To Len(oWSMdfe:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3)
			cXMlTss := AllTrim(oWSMdfe:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[nI]:oWSNFE:cXML)
			cChaveTss := Replace(NfeIdSPED(cXMlTss,"Id"),"MDFe","")

			If (nPos := aScan(aTrans, {|x| AllTrim(x[4]) == AllTrim(oWSMdfe:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[nI]:cID)}) ) > 0
				CC0->(DbGoto(aTrans[nPos][2]))
				If CC0->(Recno()) == aTrans[nPos][2]
					If !(CC0->CC0_CHVMDF == cChaveTss)

						Conout("Chave CC0 [" + CC0->CC0_CHVMDF + "] x Chave TSS [" + cChaveTss + "]")

						If (nPosSig := at('<Signature ',cXMlTss)) <> 0
							cNewXMl := SubStr(cXMlTss,1,nPosSig-1)
							cNewXMl	+= SubStr(cXMlTss,rat("</Signature>",cXMlTss)+Len('</Signature>'))
						Else
							cNewXMl := cXMlTss
						EndIf

						If !Empty(cNewXMl) .And. CC0->(RecLock("CC0",.F.))
							CC0->CC0_XMLMDF := cNewXMl
							If !Empty(CC0->CC0_CHVMDF)
								CC0->CC0_CHVMDF := cChaveTss
							EndIf
							CC0->(MsUnlock())

							cRet := StrTran( cRet, '<chnfe>'+aTrans[nPos][3]+'</chnfe>', '<chnfe>'+CC0->CC0_CHVMDF+'</chnfe>' )
							aTrans[nPos][3] := CC0->CC0_CHVMDF
							Conout("Divergencia de chave ajustada automaticamente [CC0_RECNO:" + AllTrim(Str(CC0->(Recno()))) + "]")
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI

	Else
		Conout("Metodo RETORNANOTAS sem retorno.")	
	EndIf
Else
	cErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))	
	Conout("Problema ao executar funcao de ajustar chave MDFe: " + cErro)
	Aviso("MDF-e", STR0753 + CHR(10)+CHR(13) + cErro,{STR0114},3) //Tentativa de ajuste de MDF-e: 
EndIf

FreeObj(oWSMdfe)
oWSMdfe := Nil

Return cRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GetHeaderCIOT
Retorna um array com as colunas a serem exibidas na GetDados de CIOT

@author Felipe Sales Martinez
@since 12.03.2020
@version P12
@Return	aRet -> Array com estrutura de campos do gride de CIOT
/*/
//-----------------------------------------------------------------------
Static Function GetHeaderCIOT()
	local aRet := {}
	aadd(aRet,{	STR0625,"MdfeCiot","@R 999999999999",12,0,"VldCiot()","","C","","R","","","","","",""}) //"Numero CIOT"
	aadd(aRet,{	STR0626,"MdfeContr","",18,0,"VldCgc(@MdfeContr)","","C","","R","","","","","",""}) //"CNPJ/CPF do Contratante/Subcontratante"
Return aRet


//----------------------------------------------------------------------
/*/{Protheus.doc} GetHeaderCIOT
Retorna um array com as colunas a serem exibidas na GetDados de CIOT

@author Felipe Sales Martinez
@since 12.03.2020
@version P12
@Return	aRet -> Array com estrutura de campos do gride de CIOT
/*/
//-----------------------------------------------------------------------
Static Function GetValPedHeader()
	local aRet := {}
	aadd(aRet,{	STR0850,"valPedForn","@R 99.999.999/9999-99",14,0,"VldCgc(valPedForn)","","C","","R","","","","","",""}) //"CNPJ Empresa Fornecedora do Vale-Pedágio"
	aadd(aRet,{	STR0851,"valPedPgto","",14,0,"VldCgc(@valPedPgto)","","C","","R","","","","","",""}) //"CNPJ/CPF Responsável Pagamento"
	aadd(aRet,{	STR0852,"valPednCom","@R 99999999999999999999",20,0,"","","C","","R","","","","","",""}) //"Número Comprovante de Compra"
	aadd(aRet,{	STR0853,"valPedvPed","@E 9,999,999,999,999.99",15,2,"positivo()","","N","","R","","","","","",""}) //"Valor do Vale-Pedagio"
	aadd(aRet,{	STR0854,"valPedTpPe","@!",1,0,"","","C","","R","1=TAG;2=Cupom;3=Cartão","","","","",""}) //"Tipo do Vale-Pedágio"
Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} VldCiot
Valida informação digitada no campo 'MdfeContr'

@author Felipe Sales Martinez
@since 12.03.2020
@version P12
@Return	lRet - .T. -> Informação do campo valida / .F. -> informação do campo
		invalida.
/*/
//-----------------------------------------------------------------------
Function VldCiot()
Local lRet := .T.

if !Empty(MdfeCiot) .And. (len(AllTrim(MdfeCiot)) <> 12 .Or. "-" $ MdfeCiot)
	lRet := .F.
	MsgInfo(STR0627 + CHR(10)+CHR(13)+; //"Numero de CIOT invalido."
			STR0628,STR0539) //"Por favor informar apenas numeros e com tamanho total de 12 caracteres" //"Atenção"
endif

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} VldCgc
Valida informação digitada no campo 'MdfeContr'

@author Felipe Sales Martinez
@since 12.03.2020
@version P12
@Return	lRet - .T. -> Informação do campo valida / .F. -> informação do campo
		invalida.
/*/
//-----------------------------------------------------------------------
Function VldCgc(cCgc)
Local lRet := .T.

If !Empty(cCgc)
	cCgc := StrTran(StrTran(StrTran(cCgc,"."),"/"),"-")
	If (lRet := CGC(cCgc))
		cCgc := formatCpo("CGC",cCgc)
	EndIf
EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} VldLinCiot
Valida a linha do grid recem posicionada na area referente ao CIOT

@author Felipe Sales Martinez
@since 12.03.2020
@version P12
@Return	boolean - .T. -> linha OK / .F. -> Linha com problema
/*/
//-----------------------------------------------------------------------
Function VldLinCiot(nPos)
Local lRet := .T.

Default nPos := oGetDCiot:nAt

If !oGetDCiot:aCols[nPos,Len(oGetDCiot:aCols[nPos])] .And. (!Empty(oGetDCiot:aCols[nPos,1]) .Or. !Empty(oGetDCiot:aCols[nPos,2]))
	If Empty(oGetDCiot:aCols[nPos,1])
		lRet := .F.
		MsgInfo(STR0629,STR0539) //"Informar Numero do CIOT" //"Atenção"
	ElseIf Empty(oGetDCiot:aCols[nPos,2])
		lRet := .F.
		MsgInfo(STR0630,STR0539) //"Informar CNPJ/CPF do Contratante" //"Atenção"
	EndIf
EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} FormatCpo
Formata picture dos campos a serem apresentados ao usuario em tela

@author Felipe Sales Martinez
@since 12.03.2020
@version P12
@Return	xInfo - Dado do campo formatado
/*/
//-----------------------------------------------------------------------
Static Function FormatCpo(cCpo,xInfo)

Do Case
	Case Upper(cCpo) == "CGC"
		xInfo := AllTrim(xInfo)
		xInfo := Padr(Transform(xInfo, iif(Len(xInfo) > 11,"@R 99.999.999/9999-99","@R 999.999.999-99") ),18)
EndCase

Return xInfo

//----------------------------------------------------------------------
/*/{Protheus.doc} VldMdfeOK
Valida o botã Salvar

@author Felipe Sales Martinez
@since 16.03.2020
@version P12
@Return	lRet
/*/
//-----------------------------------------------------------------------
Static Function VldMdfeOK(nOpc, nQtNFe)
Local lRet 		:= .T.
Local nI		:= 0

If nOpc <> 5 
	if Type("oGetDCiot") <> "U"
		For nI := 1 To Len(oGetDCiot:aCols)
			If !VldLinCiot(nI)
				lRet := .F.
				Exit
			EndIf
		Next
	endIf

	if Type("oGetDValPed") <> "U"
		For nI := 1 To Len(oGetDValPed:aCols)
			If !valPedValLin(nI)
				lRet := .F.
				Exit
			EndIf
		Next
	endIf

	if type("cVVTpCarga") == "C"
		if ( !empty(cVVTpCarga) .and. empty(cPPxProd) ) .or. ( !empty(cPPxProd) .and. empty(cVVTpCarga) )
			msgInfo(STR0875,STR0539) //"Na aba [Produto Predominante] há informações obrigatorias (em azul) não preenchidas." //"Atenção
			lRet := .F.
		endIf

		if nQtNFe == 1 .and. !empty(cVVTpCarga) .and. !empty(cPPxProd) .and. ( empty(cPPCEPCarr) .or. empty(cPPCEPDesc) )
			//Quando selecionado apenas 1 documento fiscal, na aba [Produto Predominante] devem ser informados os campos de CEP de carregamento e CEP descarregamento."
			msgInfo(STR0878,STR0539)
			lRet := .F.
		endIf
	endIf

	//Valida informações de pagamento
	If lRet .And. lInfPag .And. type("oDlgPgt") == "O"
		If !oDlgPgt:ValidaOk()
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. Type("oGetDMun") <> "U" .And. Len(oGetDMun:aCols) > 0
		lRet := VldMunCar(oGetDMun:aCols)
	EndIf

	If lRet .And. lModal .and. (SubStr(cModal,1,1) == "2")
		If empty(cNumVoo) .or. empty(dDatVoo) .or. empty(cAerOrig) .or. empty(cAerDest)
			msgInfo(STR0895)
			lRet := .F.
		EndIf
	EndIf

	if lRet .and. !type("oGetSeg") == "U" .and. Len(oGetSeg:aCols) > 0
		lRet := VldSeg()
	endif

	if lRet .and. !type("oGetInfCnt") == "U" .and. Len(oGetInfCnt:aCols) > 0
		lRet := VldInfCont()
	endif

	if lRet .and. lMotori .and. empty(cMotorista) .and. type("oGetCondut") == "O" 
		if len(oGetCondut:aCols) == 0 .or. aScan( oGetCondut:aCols , { |X| !X[len(X)] .and. !empty(X[1])  }) == 0
			MsgInfo(STR0964, STR0539) // "Informe um Condutor Principal ou Condutores adicionais." # "Atenção"
			lRet := .F.
		endif
	endif

EndIf

return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} ClearInfPag
Responsavel por limpar as variaveis do painel de pagamentos do MDF-e

@author Felipe Sales Martinez
@since 16.03.2020
@version P12
@Return	lRet
/*/
//-----------------------------------------------------------------------
static function ClearInfPag()

if lInfPag
	if type("oDlgPgt") == "O"
		fwfreeobj(oDlgPgt)
		oDlgPgt := nil
	endif

	oDlgPgt	:= MDFeInfPag():new()
endif

return

//----------------------------------------------------------------------
/*/{Protheus.doc} InfPagLoad
Responsavel por carregar as informações do grid do evento referente ao 
status do evento de pagamento de operacao de transporte

@author Bruno Akyo Kubagawa
@since 30.03.2020
@version P12
@Return	aRet
/*/
//-----------------------------------------------------------------------
static function InfPagLoad(cQtdViagem, cNrViagem, lAltera)
	local aRet			:= {}
	local lUsaColab		:= UsaColaboracao("5")
	local cChaveMDFe	:= ""
	local aPagEveRet	:= {}
	local nInfPag		:= 0
	local cStatus		:= ""
	local cXml			:= ""
	local cAviso		:= ""
	local cErro			:= ""
	local cDescAmb		:= ""
	local aRetPag		:= {}

	default cQtdViagem  := space(5)
	default cNrViagem	:= space(5)
	default lAltera		:= .T.

	private oInfPag := nil

	begin sequence

		if lUsaColab
			break
		endif
		
		cChaveMDFe := CC0->CC0_CHVMDF
		if empty(cChaveMDFe)
			break
		endif

		aPagEveRet := RetMonEven(cChaveMDFe,cChaveMDFe,INFPAGEVE,"58")
		aPagEveRet := RetEvenDfe(cIdEnt,cChaveMDFe,@aPagEveRet, "", {})
		aSize(aRetInfPag,0)
		aRetInfPag := {}
		for nInfPag := 1 to len(aPagEveRet)
			/*aPagEveRet[nInfPag]
				[1] - oNo / oOk 
				[2] - Protocolo
				[3] - ID_EVENTO
				[4] - Ambiente
				[5] - Status
				[6] - MotEven ou Mensagem
				[7] - XML manter devido ao TOTVS Colaboração.
				[8] - XML_SIG
				[9] - Array
				[10] - Numero do Lote
				[11] - data e hora do evento
			*/
			if aPagEveRet[nInfPag][5] $ "6"
				cStatus := EVEVINCULADO	//Autorizado
				lAltera := .F.
			ElseIf aPagEveRet[nInfPag][5] $ "3|5"
				cStatus := EVENAOVINCULADO	//Rejeitado
			ElseIf aPagEveRet[nInfPag][5] $ "1|2|4"
				cStatus := EVENAOREALIZADO	//Transmitido
				lAltera := .F.
			Else
				cStatus := EVEREALIZADO	//Nao Transmitido  
			Endif

			cDescAmb := iif(AllTrim(aPagEveRet[nInfPag][4]) == '1',"Produção","Homologação")

			aAdd( aRet, {cStatus, aPagEveRet[nInfPag][2], aPagEveRet[nInfPag][3], cDescAmb, aPagEveRet[nInfPag][6]  })
			aAdd( aRetInfPag, { aPagEveRet[nInfPag][3] , aRet[nInfPag] , "", "",nil })
			
			If CC0->CC0_STATUS==AUTORIZADO
				MdfAtuEvento(CC0->(RECNO()),cStatus,INFPAGEVE)
			EndIf

			cQtdViagem := space(5)
			cNrViagem := space(5)
			aRetPag := {}
			if len(aPagEveRet[nInfPag]) > 7 .and. !empty(aPagEveRet[nInfPag][8])

				cXml := aPagEveRet[nInfPag][8]
				cAviso := ""
				cErro := ""
				cXml := XmlClean(cXml)
				aRetPag := {}
				oInfPag := XmlParser(encodeUTF8(cXml),"_",@cAviso,@cErro)
				if !empty(cErro)
					ConOut("Erro função InfPagLoad - " + cErro + " - chave: " + cChaveMDFe)
				else
					if mdfeType("oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens") == "O"
						if mdfeType("oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens:_QtdViagens:TEXT") == "C"
							cQtdViagem := oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens:_QtdViagens:TEXT
						elseif mdfeType("oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens:_QtdViagens:TEXT") == "N"
							cQtdViagem := cValToChar(oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens:_QtdViagens:TEXT)
						else
							cQtdViagem := space(5)
						endif
						if mdfeType("oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens:_NroViagem:TEXT") == "C"
							cNrViagem:= oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens:_NroViagem:TEXT
						elseif mdfeType("oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens:_NroViagem:TEXT") == "N"
							cNrViagem := oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfViagens:_NroViagem:TEXT
						else
							cNrViagem := space(5)
						endif
					else
						cQtdViagem := space(5)
						cNrViagem := space(5)
					endif

					if mdfeType("oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfPag") == "O"
						aRetPag := {oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfPag}
					elseif mdfeType("oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfPag") == "A"
						aRetPag := oInfPag:_EventoMDFe:_InfEvento:_DetEvento:_EvPagtoOperMDFe:_InfPag
					endif

					aRetInfPag[len(aRetInfPag)][3] := cQtdViagem
					aRetInfPag[len(aRetInfPag)][4] := cNrViagem
					aRetInfPag[len(aRetInfPag)][5] := aClone(aRetPag)

				endif
			endif
		next nInfPag

		if len(aRetInfPag) > 0
			cQtdViagem := aRetInfPag[1][3]
			cNrViagem := aRetInfPag[1][4]
			aRetPag := aClone(aRetInfPag[1][5])
			oDlgPgt:setinfPag(aRetPag)
		endif

	end sequence

	if len(aRet) == 0
		aAdd(aRet,RetPgtArr())
	endif

return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} AtuInfPag
Responsavel por Atualziar as variaveis da tela de evento do pagamento 
de operacao de transporte

@author Bruno Akyo Kubagawa
@since 30.03.2020
@version P12
@Return	aRet
/*/
//-----------------------------------------------------------------------
static function AtuInfPag(nPosInfPag)
	local nPos		 := 0
	local aPag 		 := {}

	default nPosInfPag := oLstPagto:nAt

	begin sequence

	if len(aRetInfPag) == 0
		break
	endif

	if len(aRetInfPag) >= nPosInfPag 
		
		if (nPos := aScan(aRetInfPag, { |X| alltrim(X[1]) == oLstPagto:aArray[nPosInfPag][3] })) > 0
			cQtdViagem := aRetInfPag[nPos][3]
			cNrViagem := aRetInfPag[nPos][4]
			aPag := aClone(aRetInfPag[nPos][5])
		endif
		oDlgPgt:setinfPag(aPag)
		oDlgPgt:Refresh()
		oGQtdVig:Refresh(.T.)
		oGNrVig:Refresh(.T.)
	endif

	end sequence

return

//----------------------------------------------------------------------
/*/{Protheus.doc} PgtoVldTrans
Responsavel por validar o click do botão transmitir para o evento de
pagamento de operação de transporte

@author Felipe Sales Martinez
@since 02.04.2020
@version P12
@Return	lRet
/*/
//-----------------------------------------------------------------------
Static Function PgtoVldTrans()
Local lRet		:= .T.
Local cErro		:= ""
Local aEventos	:= aClone(GetArrPgt())

If !(CC0->CC0_STATUS == AUTORIZADO)
	cErro	:= STR0594 //#"Transmissão somente permitida para MDF-e autorizados."
	lRet	:= .F.
ElseIf Empty(cNrViagem) .Or. Empty(cQtdViagem)
	cErro	:= "As informações de numero de viagem e quantidade de viagens devem ser informadas."
	lRet	:= .F.
ElseIf Len(aEventos) > 0 .And. AllTrim(aEventos[GetPosEven(),1]) $ EVEVINCULADO+"/"+EVENAOREALIZADO
	cErro	:= "Evento já transmitido, operação não permitida."
	lRet	:= .F.
Else
	lRet := oDlgPgt:ValidaOk(.T.)
EndIf

If !lRet .And. !Empty(cErro)
	MsgInfo(cErro,STR0539) //#"Atenção"
EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} TransPgto
Responsavel por transmitir o evento de pagamento de operação de transporte

@author Felipe Sales Martinez
@since 02.04.2020
@version P12
@Return	lRet
/*/
//-----------------------------------------------------------------------
Static Function TransPgto()
Local lRet		:= .F.
Local cXml		:= ""
Local cXmlPgt	:= ""

If !Empty(cXmlPgt := oDlgPgt:XmlInfPag())

	cXml += '<envEvento>'
		cXml += '<eventos>'
			cXml += '<detEvento>'
				cXml += '<tpEvento>' + INFPAGEVE + '</tpEvento>'
				cXml += '<chnfe>' + AllTrim(CC0->CC0_CHVMDF)  + '</chnfe>'
				cXml += '<qtdViagens>' + StrZero(Val(cQtdViagem),5) + '</qtdViagens>'
				cXml += '<nroViagem>' +  StrZero(Val(cNrViagem),5) + '</nroViagem>'
				cXml += cXmlPgt
			cXml += '</detEvento>'
		cXml += '</eventos>'
	cXml += '</envEvento>'

	If lUsaColab
		//TODO: Codificar caso seja Colaboracao
	Else
		aRetRemessa := RemessaDFe(cXml) 
		lRet := aRetRemessa[1] //[1] -> Sucesso Execucao WS 
		cRet := aRetRemessa[2] //[2] -> Mensagem

		If !lRet //Problemas ao tentar transmitir
			Aviso(STR0754, cRet, {STR0114},3) //Transmissão Pagamento de Operação de Transporte, OK

		Else //Transmissao OK
			EnvExibLog("Transmissão do evento de Pagamento de Operação de Transporte realizada com sucesso!" + Replic(CHR(10)+CHR(13),2) + ;
					   "Pressionar botão 'Refresh' para atualização do status deste evento.",STR0602) //#"Resultado da transmissão"
		EndIf
	EndIf
EndIf

If lRet
	PgtUpdGrid()
EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} PgtUpdGrid
Responsavel por atualziar o grid do status do evento

@author Felipe Sales Martinez
@since 02.04.2020
@version P12
@Return	lRet
/*/
//-----------------------------------------------------------------------
Static Function PgtUpdGrid() 
Local lAltera := .T.

SetArrPgt(InfPagLoad(@cQtdViagem, @cNrViagem, @lAltera),.T.)
oGQtdVig:bWhen := {|| lAltera }
oGNrVig:bWhen := {|| lAltera }
If aScan(ClassMethArr(oDlgPgt), {|x| x[1] == "ACTDESACT" }) > 0 //TODO: Retirar nas proximas versoes
	oDlgPgt:ActDesact(lAltera)
EndiF
oDlgPgt:Refresh()

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetArrPgt
Atualiza a estrutura de dados do listbox da Pagamento de Op. Transporte

@author		Felipe Sales Martinez (FSM)
@since		07.08.2019
@version	1.00
@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function SetArrPgt(aList, lRefresh)
Default aList 	:= Nil
Default lRefresh:= .F.

If aList <> Nil
	oLstPagto:aArray := aList
	aDadosPgto := oLstPagto:aArray
	
	If lRefresh
		oLstPagto:Refresh()
	EndIf
EndIf

Return Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} GetArrPgt
Retorna o array do status do evento de pagamento

@author Felipe Sales Martinez
@since 02.04.2020
@version P12
@Return	lRet
/*/
//-----------------------------------------------------------------------
Static Function GetArrPgt()
Return oLstPagto:aArray

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetIncArr
Retorna estrutura de dados do listbox do Inclusao de condutor

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@return		aIncCon	- Array com as estrutura de dados do array do listbox 
			do monitor de Evento
/*/
//-----------------------------------------------------------------------
Static Function RetPgtArr()
Local aPgtoOp := ARRAY(5)
aPgtoOp[1]	:= EVEREALIZADO
aPgtoOp[2]	:= " "
aPgtoOp[3]	:= " "
aPgtoOp[4]	:= " "
aPgtoOp[5]	:= " "
Return aPgtoOp

//-----------------------------------------------------------------------
/*/{Protheus.doc} VldMunCar
Valida se foi informado algum municipio de carregamento

@author		Felipe Sales Martinez (FSM)
@since 		16.06.2020
@version 	1.00
@return		.T./.F.
/*/
//-----------------------------------------------------------------------
Static Function VldMunCar(aMunCar)
Local lRet	:= .F.
Local nI	:= 1

for nI := 1 To Len(aMunCar)
	if !aMunCar[nI,len(aMunCar[nI])] .and. !Empty(aMunCar[nI,1])
		lRet := .T.
		exit
	endif
next

If !lRet
	MsgStop ( STR0766 ) //É necessário informar ao menos um municipio de carregamento na aba Carregamento/Percurso.
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetMotori
Alimenta o campo motoriasta com o o código de motorista cadastrado no veículo	

@author		Caique Lima Fonseca
@since 		28.07.2020
@version 	1.00
@return		.T./.F.
/*/
//-----------------------------------------------------------------------
Static Function SetMotori(cVeiculo)
Local lRet	:= .T.

If lMotori //Só alimento a variável global caso exista o campo
	aDA3Area := DA3->(GetArea())
	DA3->(DBSetOrder(1)) //DA3_FILIAL+DA3_COD
	If !Empty(cVeiculo) .And. DA3->(DBSeek(xFilial("DA3")+cVeiculo))
		If !Empty(DA3->DA3_MOTORI)
			cMotorista := DA3->DA3_MOTORI
		EndIf
	EndIf
	RestArea(aDA3Area)
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} retFilClFo
Retorna a filial do cliente ou fornecedor

@author		Felipe Sales Martinez
@since 		04/03/2021
@version 	1.00
@param		cFilDoc, String, Filial da Nota Fiscal Entrada/Saida
			isCustomer, String, Se é cliente ou não (fornecedor)
@return		cFil, String, Filial do cliente/fornecedor
/*/
//-----------------------------------------------------------------------
Static function retFilClFo(cFilDoc,isCustomer)
local cFilret		:= ""
local cTabCliFo		:= "SA1"

default isCustomer	:= .T.

if !isCustomer
	cTabCliFo := "SA2"
endIf

cFilret := FwxFilial(cTabCliFo,cFilDoc)

return cFilret

/*/{Protheus.doc} valPedValLin
Valida a linha posicionada na tela referente ao Vale-Pedagio

@author		Felipe Sales Martinez
@since 		16/06/2021
@version 	1.00
@param		nPos - linha a ser avaliada
@return		logico, .T.-> sucesso / .F. -> problema com a linha
/*/
function valPedValLin(nPos)
Local lRet := .T.

Default nPos := oGetDValPed:nAt

If !oGetDValPed:aCols[nPos,Len(oGetDValPed:aCols[nPos])] .and.;
	(!Empty(oGetDValPed:aCols[nPos,1]) .Or. !Empty(oGetDValPed:aCols[nPos,2]) .or. !Empty(oGetDValPed:aCols[nPos,3]) .Or.;
	!Empty(oGetDValPed:aCols[nPos,4]) .or. !Empty(oGetDValPed:aCols[nPos,5]))

	If Empty(oGetDValPed:aCols[nPos,1]) //valPedForn
		lRet := .F.
		MsgInfo("informar o CNPJ da Empresa Fornecedora do Vale-Pedágio na linha [" + allTrim(Str(nPos)) + "]",STR0539) //"Informar Numero do CIOT" //"Atenção"
	ElseIf Empty(oGetDValPed:aCols[nPos,4]) //valPedvPed
		lRet := .F.
		MsgInfo("informar o Valor do Vale-Pedagio na linha [" + allTrim(Str(nPos)) + "]",STR0539) //"Informar Numero do CIOT" //"Atenção"
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} mdfePPTrig
Realiza o gatilhos nos demais campos do produto predominantes
com base no código do produto

@author		Felipe Sales Martinez
@since		17.06.2021
@version	1.00
@param		NIl
@return		lret, boolean, Sucesso ou não ao realizar o gatilho
/*/
Function mdfePPTrig()
local lRet	:= .T.

if !empty(cPPcProd)
	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	If SB1->(MsSeek(xFilial("SB1")+padr(cPPcProd,tamSX3("B1_COD")[1])))
		cPPxProd	:= SB1->B1_DESC
		cPPCodbar	:= SB1->B1_CODBAR
		cPPNCM		:= SB1->B1_POSIPI
	else
		msgAlert(STR0908,STR0539) //#"Não existe registro relacionado ao codigo informado na tabela de Produtos (SB1)." ##Atenção
		lRet := .F.
	endIf
endIF

return lRet

/*/{Protheus.doc} mdfeType
Função para evitar problema com SONARQUBE

@author		Felipe Sales Martinez
@since		17.06.2021
@version	1.00
@param		cNode, string, nó a ser avaliado
@return		boolean, .T. -> nó existente / .F. -> nó não existente
/*/
static function mdfeType(cNode)
return type(cNode)

/*/{Protheus.doc} tpCargaIt
Retorna os tipos de carga existentes

@author		Felipe Sales Martinez
@since		17.06.2021
@version	1.00
@param		NIl
@return		aItens, array, tipos de cargas
/*/
static function tpCargaIt()
local aItens:= {""		,;
				STR0855,; //"01-Granel Sólido"
				STR0856,;//"02-Granel Líquido"
				STR0857,;//"03-Frigorificada"
				STR0858,;//"04-Conteinerizada"
				STR0859,;//"05-Carga Geral"
				STR0860,;//"06-Neogranel"
				STR0861,;//"07-Perigosa (Granel Sólido)"
				STR0862,;//"08-Perigosa (Granel Líquido)"
				STR0863,;//"09-Perigosa (Carga Frigorificada)"
				STR0864,;//"10-Perigosa (Conteinerizada)"
				STR0865}//"11-Perigosa (Carga Geral)"
return aItens

/*/{Protheus.doc} defProdPred
Responsavel por todo o mecanismo de seleção de produto predominante

@author		Felipe Sales Martinez
@since		17.06.2021
@version	1.00
@param		nOpc, numerico, opção do menu de edição da MDF-e
@return		Nil
/*/
Function defProdPred(nOpc)
local cQuery	:= ""
local aNotas	:= {}

if nOpc == 3 .or. nOpc == 4

	aNotas := recNFPPred() 	//notas selecionadas

	if len(aNotas) > 0
		//query para apresentação dos produtos com mais ocorrencia
		cQuery := retQueryPP(aNotas)
		
		//seleção do produto predominante
		selProdPre(cQuery)

		TRB->(dbsetOrder(1))
		TRB->(dbgoTop())
	endIf
endIf

Return nil

/*/{Protheus.doc} recNFPPred
Retorna os recnos das notas selecionadas para serem utilizadas
na query de produto predominante

@author		Felipe Sales Martinez
@since		17.06.2021
@version	1.00
@param		NIl
@return		aNotas, array, [1] - Recnos NF-e Entrada / [2] - Recnos NF-e Saida
/*/
static function recNFPPred()
local aNotas	:= {"",""}
local aArea		:= {}

aArea := TRB->(getArea())
TRB->(DBGoTop())
TRB->(dbsetOrder(3)) //TRB_MARCA+TRB_SERIE+TRB_DOC
if TRB->(dbSeek(cMark))
	while TRB->(!EOF()) .and. TRB->TRB_MARCA == cMark
		if TRB->TRB_TPNF == "E"
			aNotas[1] += "'" + allTrim(str(TRB->TRB_RECNF)) + "',"
		else
			aNotas[2] += "'" + allTrim(str(TRB->TRB_RECNF)) + "',"
		endIf
		TRB->(dbSkip())
	end

	aNotas[1] := iif(!empty(aNotas[1]),subStr(aNotas[1],1,rat("',", aNotas[1])),"")
	aNotas[2] := iif(!empty(aNotas[2]),subStr(aNotas[2],1,rat("',", aNotas[2])),"")

else
	msginfo(STR0866 + CHR(10)+CHR(13) +; //"Não foi selecionada nenhuma nota na aba 'Documentos'!"
			STR0867) //"Por favor selecionar ao menos um documento (NF-e) para realizar esta operação."
	aNotas := {}
endIf

TRB->(dbsetOrder(1))
restArea(aArea)

return aNotas

/*/{Protheus.doc} retQueryPP
Responsavel por montar query para determinar o produto predominante
com base nas notas selecionadas

@author		Felipe Sales Martinez
@since		17.06.2021
@version	1.00
@param		aNotas, array, recno de notas selecionadas
@return		cQuery, String, query a ser executada
/*/
static function retQueryPP(aNotas)
local cQuery	:= ""
local cDb  	:= UPPER(TcGetDb())

if !empty(aNotas[1])
	cQuery += "SELECT "+retQrSel(cDb,1)+" '  ' MARK, SD1.D1_COD PRODUTO, SUM(SD1.D1_TOTAL) TOT FROM " + RetSqlName("SF1") + " SF1 "
	cQuery += "INNER JOIN " + RetSqlName("SD1") + " SD1 "
	cQuery += "ON SD1.D1_FILIAL = SF1.F1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SD1.D1_LOJA = SF1.F1_LOJA AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SF1.R_E_C_N_O_ IN (" + aNotas[1] + ")  "+retQrSel(cDb,4)+" "
	cQuery += "GROUP BY SD1.D1_COD "
endIf

if !empty(aNotas[1]) .and. !empty(aNotas[2])
	cQuery += " UNION "
endIf

if !empty(aNotas[2])
	cQuery += "SELECT "+retQrSel(cDb,2)+" '  ' MARK, SD2.D2_COD PRODUTO, SUM(SD2.D2_TOTAL) TOT FROM " + RetSqlName("SF2") + " SF2 "
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " SD2 "
	cQuery += "ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SF2.R_E_C_N_O_ IN (" + aNotas[2] + ") "+retQrSel(cDb,4)+" "
	cQuery += "GROUP BY SD2.D2_COD "
endIf

cQuery += "ORDER BY 3 DESC "+retQrSel(cDb,3)+""

return cQuery

/*/{Protheus.doc} selProdPre
Responsavel por exibir os produtos predominantes com mais ocorrencias 
para seleção

@author		Felipe Sales Martinez
@since		17.06.2021
@version	1.00
@param		cQuery, String, query a ser executada
@return		nil
/*/
static function selProdPre(cQuery)
local lOk 			:= .F.
local bOk			:= {||( cPPcProd := (cAlias)->PRODUTO,  lOk := .T., oDlgPP:End() )}
local bCancelar		:= {|| oDlgPP:End()}
local nI			:= 0
local cAlias 		:= GetNextAlias()
local aFields 		:= {}
local aColumns		:= {}
local cbckCadastro	:= cCadastro
local cDescricao	:= "Posicione('SB1',1,FwxFilial('SB1',xFilial('SB1')) + ('" + cAlias + "')->(PRODUTO),'B1_DESC')"

private nRecMarked	:= 0
private oMark		:= nil
private oDlgPP 		:= nil

cCadastro := STR0868 //"Produtos com maiores valores dentre os documentos selecionados:"

Define MsDialog oDlgPP FROM 0, 0  To MDFeResol(75,.F.),MDFeResol(75,.T.) Title STR0869 OF oMainWnd PIXEL //"Seleção de Produto Predominante"

aAdd( aFields, {"PRODUTO"	, STR0870, "C", tamsx3("B1_COD")[1]		, 0						, PesqPict("SB1","B1_COD")})//"Código"
aAdd( aFields, {cDescricao	, STR0871, "C", tamsx3("B1_DESC")[1]	, 0						, PesqPict("SB1","B1_DESC")})//"Descrição"
aAdd( aFields, {"TOT"		, STR0872, "N", tamsx3("D2_TOTAL")[1]	, tamsx3("D2_TOTAL")[2]	, PesqPict("SD2","D2_TOTAL")})//"Valor Total"

For nI := 1 To Len( aFields )
 
	AAdd( aColumns, FWBrwColumn():New() )
	
	aColumns[Len(aColumns)]:SetID( aFields[nI] )
	aColumns[Len(aColumns)]:SetData( &("{ || " + aFields[nI][1] + " }") )
	aColumns[Len(aColumns)]:SetTitle( aFields[nI][2] )
	aColumns[Len(aColumns)]:SetType( aFields[nI][3] )
	aColumns[Len(aColumns)]:SetSize( aFields[nI][4] )
	aColumns[Len(aColumns)]:SetDecimal(aFields[nI][5] )
	aColumns[Len(aColumns)]:SetPicture( aFields[nI][6] )

Next nI
 
oMark := FWMarkBrowse():New()
oMark:SetColumns( aColumns )
oMark:SetOwner(oDlgPP)
oMark:SetDataQuery()
oMark:SetTemporary( .T. )
oMark:SetQuery(cQuery)
oMark:SetFieldMark("MARK")
oMark:SetMenuDef('')
oMark:SetIgnoreARotina(.T.)
oMark:DisableReport()
oMark:DisableConfig()
oMark:DisableFilter()
oMark:SetAlias( cAlias )
oMark:SetCustomMarkRec({|| pPMark(cAlias )})
oMark:SetAllMark({|| .F. })
oMark:Activate()

ACTIVATE MSDIALOG oDlgPP ON INIT EnchoiceBar(oDlgPP, bOk , bCancelar ,,,,,.F.,.F.,.F.,,.F.) CENTERED

if lOk
	SB1->(dbSetOrder(1))
	if SB1->(msSeek( FwxFilial("SB1",xFilial("SB1")) + cPPcProd ))
		cPPxProd	:= SB1->B1_DESC
		cPPCodbar	:= SB1->B1_CODBAR
		cPPNCM		:= SB1->B1_POSIPI
	endIf
endIf

cCadastro := cbckCadastro

return nil

/*/{Protheus.doc} pPMark
Responsavel por marcar ou desmarcar.

@author		Felipe Sales Martinez
@since		17.06.2021
@version	1.00
@param		cAlias, String, alias temporaria para marcação
@return		nil
/*/
static function pPMark(cAlias)

if oMark:IsMark() //clicado para desmarcar
	nRecMarked := 0
	RecLock(cAlias, .F.)
	(cAlias)->MARK := "  " 
	(cAlias)->(msUnlock())

else //clicado para marcar
	if nRecMarked == 0
		nRecMarked := oMark:at()
		RecLock(cAlias, .F.)
		(cAlias)->MARK := oMark:Mark()
		(cAlias)->(msUnlock())
	else
		alert(STR0873 + CHR(10)+CHR(13) +; //"Não é possível selecionar mais de um produto como produto predominante."
			STR0874, STR0539) //"Caso desejado desmaque o produto já selecionado e volte a marcar este produto." //"Atenção"
	endIf
endIf

return nil

/*/{Protheus.doc} DialogSeg
Apresenta a interface para informar os dados do seguro

@return		nil
/*/
static function DialogSeg(oPanel, nOpc)
	local nTopGD	 := 0
	local nLeftGD	 := 0
	local nDownGD	 := 0
	local nRightGD	 := 0

	default nOpc := 0

	SetInfSeg()

	nTopGD := MDFeResol(1,.F.)
	nLeftGD := MDFeResol(0.5,.T.)
	nDownGD := MDFeResol(21,.F.)
	nRightGD := MDFeResol(36,.T.)
	oGetSeg := MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(nOpc == 3 .or. nOpc == 4,GD_INSERT+GD_UPDATE+GD_DELETE,0),"MdfeVldSeg(,,1)",,,,,,,,"MdfeVldSeg(,,2)",oPanel,aHeadSeg,@aColsSeg, "MdfeSegChg()")

	nTopGD := MDFeResol(1,.F.)
	nLeftGD := MDFeResol(36,.T.)
	nDownGD := MDFeResol(21,.F.)
	nRightGD := MDFeResol(46,.T.)
	oGetAverb := MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(nOpc == 3 .or. nOpc == 4,GD_INSERT+GD_UPDATE+GD_DELETE,0),"MdfeVldAvb(,1)",,,,,,,,"MdfeVldAvb(,2)",oPanel,aHeadAverb,@aColsAverb)

return nil

/*/{Protheus.doc} GetHSeg
Define cabeçalho da informação dos seguro

@return		nil
/*/
static function GetHSeg()
	local aRet := {}
	// https://devforum.totvs.com.br/579-aheader-do-msnewgetdados
	aadd(aRet,{	STR0897	,"SegResp"		,"" ,01 ,0 ,"MdfeVldSeg(1, SegResp)"								,"","C","","R","1=" + STR0898 + ";2=" + STR0899,"","","","",""}) // "Responsável pelo Seguro"// "Emitente do MDF-e" // "Responsável pela contratação do serviço de transporte (contratante)"
	aadd(aRet,{ STR0900 ,"SegCNPJ"		,"" ,14 ,0 ,"VldCgc(@SegCNPJ) .and. MdfeVldSeg(2, SegCNPJ)"			,"","C","","R","","","MdfeWhen()","","",""}) // "CNPJ/CPF do Responsável"
	aadd(aRet,{	STR0901	,"SegSegu"		,"" ,30 ,0 ,"MdfeVldSeg(3, SegSegu)"								,"","C","","R","","","MdfeWhen()","","",""}) // "Seguradora" 
	aadd(aRet,{	STR0902	,"SegCNPJSeg"	,"" ,14 ,0 ,"VldCgc(@SegCNPJSeg) .and. MdfeVldSeg(4, SegCNPJSeg)"	,"","C","","R","","","MdfeWhen()","","",""}) // "CNPJ Seguradora"
	aadd(aRet,{	STR0903 ,"SegApol"		,"" ,20 ,0 ,"MdfeVldSeg(5, SegApol)"								,"","C","","R","","","","","",""}) // "Apólice"
return aRet

/*/{Protheus.doc} GetHAverb
Define cabeçalho da averbação

@return		nil
/*/
static function GetHAverb()
	local aRet := {}
	aadd(aRet,{	STR0904 ,"SegAver","",40,0,"MdfeVldAvb(SegAver)","","C","","R","","","","","",""}) // "Número da Averbação"
return aRet

/*/{Protheus.doc} MdfeWhen
Define se o campo será editavel

@return		nil
/*/
function MdfeWhen()
	local lRet		:= .T.

	if type("oGetSeg") == "O" .and. len(oGetSeg:aCols) >  0 .and. oGetSeg:nAt > 0 .and. oGetSeg:aCols[oGetSeg:nAt][1] == "1"
		lRet := .F.
	endif

return lRet

/*/{Protheus.doc} MdfeVldSeg
Carrega as informações dos campos

@return		nil
/*/
function MdfeVldSeg(nCampo, cInfo, nOpc)
	local lOk		 := .T.

	default nCampo	 := 0
	default cInfo	 := ""
	default nOpc	 := 0

	if nCampo > 0 
		do case
			case nCampo == 1
				aInfSeg[oGetSeg:nAt][nCampo] := cInfo
			case nCampo == 2
				cInfo := strTran( strTran( strTran(cInfo,".",""), "-", ""), "/","")	
				if len(alltrim(cInfo)) > 11
					aInfSeg[oGetSeg:nAt][2] := cInfo
					aInfSeg[oGetSeg:nAt][3] := ""
				else
					aInfSeg[oGetSeg:nAt][2] := ""
					aInfSeg[oGetSeg:nAt][3] := cInfo
				endif
			case nCampo == 4
				cInfo := strTran( strTran( strTran(cInfo,".",""), "-", ""), "/","")	
				aInfSeg[oGetSeg:nAt][5] := cInfo
			otherwise
				aInfSeg[oGetSeg:nAt][nCampo+1] := cInfo
		endcase
	endif

	MdfeVldAvb(,nOpc)
	if nOpc == 0
		aInfSeg[oGetSeg:nAt][8] := oGetSeg:aCols[oGetSeg:nAt,Len(oGetSeg:aCols[oGetSeg:nAt])]
	else
		aInfSeg[oGetSeg:nAt][8] := if(nOpc == 1, .F., .T.)
	endif

return lOk

/*/{Protheus.doc} MdfeVldAvb
Valida as informações do Averbação

@return		nil
/*/
function MdfeVldAvb(cInfo, nOpc)
	local lOk		 := .T.
	local nAverb	 := 0
	local aAverb	 := {}

	default cInfo	:= ""
	default nOpc	:= 0

	if !empty(cInfo)
		oGetAverb:aCols[oGetAverb:nAt][1] := cInfo
	endif

	for nAverb := 1 to len(oGetAverb:aCols)
		aAdd( aAverb, { oGetAverb:aCols[nAverb][1], oGetAverb:aCols[nAverb,Len(oGetAverb:aCols[nAverb])] } )
	next

	if !nOpc == 0
		aAverb[oGetAverb:nAt,Len(aAverb[oGetAverb:nAt])] := if( aAverb[oGetAverb:nAt,Len(aAverb[oGetAverb:nAt])], .T., if(nOpc == 1, .F., .T.))
	endif

	aInfSeg[oGetSeg:nAt][7] := aClone(aAverb)

return lOk

/*/{Protheus.doc} MdfeSegChg
Onchange do seguro

@return		nil
/*/
function MdfeSegChg()

	if len(aInfSeg) <= oGetSeg:nAt
		aAdd( aInfSeg, { space(01) , space(14), space(11), space(30), space(14), space(20), {{space(40), .F.}}, .F.} )
	endif

	MdfeAvbChg()

return

/*/{Protheus.doc} MdfeAvbChg
Onchange do Averbação

@return		nil
/*/
function MdfeAvbChg()

	SetInfAvb(aHeadAverb, aInfSeg[oGetSeg:nAt][7])
	oGetAverb:aCols := {}
	oGetAverb:setArray(aColsAverb)
	oGetAverb:refresh()

return

/*/{Protheus.doc} LoadXmlSeg
Carrega as informações dos dados do seguro

@return		nil
/*/
static function LoadXmlSeg(oXML)
	local oInfSeg	 := nil
	local cRespSeg	 := ""
	local cCNPJ		 := ""
	local cCPF		 := ""
	local cSeg		 := ""
	local cCNPJSeg	 := ""
	local cApolice	 := ""
	local aAverb	 := {}
	local nSeg		 := 0
	local nAverb	 := 0
	local cAverb	 := ""
	local aXmlAverb  := {}

	private aXmlSeg	  := {}

	ClearInfSeg()
	// Estrutura do array aInfSeg, é um subconjunto de:
	// <seg> 0 - n -> Informações de Seguro da Carga
	//		<infResp> 1 - 1 -> Informações do responsável pelo seguro da carga 
	//			1 <respSeg>	-> 1 - 1 -> Responsável pelo seguro - Preencher com:  1 - Emitente do MDF-e; 2 - Responsável pela contratação do serviço de transporte (contratante) 
	// 									Dados obrigatórios apenas no modal Rodoviário, depois da lei 11.442/07. Para os demais modais esta informação é opcional. 
	//			2 <CNPJ> 	-> 1 - 1 -> Número do CNPJ do responsável pelo seguro 
	//									Obrigatório apenas se responsável pelo seguro for (2) responsável pela contratação do transporte - pessoa jurídica 
	//			3 <CPF>		-> 1 - 1 -> Número do CPF do responsável pelo seguro 
	//									Obrigatório apenas se responsável pelo seguro for (2) responsável pela contratação do transporte - pessoa física 
	//		<infSeg> 0 - 1 -> Informações da seguradora
	//			4 <xSeg>	-> 1 - 1 -> Nome da Seguradora
	//			5 <CNPJ>	-> 1 - 1 -> Número do CNPJ da seguradora
	// 									Obrigatório apenas se responsável pelo seguro for (2) responsável pela contratação do transporte - pessoa jurídica 
	//		6 <nApol>	-> 0 - 1 -> Número da Apólice
	// 								Obrigatório pela lei 11.442/07 (RCTRC) 
	//		7 <nAver>	-> 0 - n -> Número da Averbação
	// 								Informar as averbações do seguro
	//		8 -> posição de controle para validar se foi excluido a linha

	oInfSeg := GetMDeInfo(oXML,"_MDFE:_INFMDFE:_SEG")
	if !valtype(oInfSeg) == "U"

		aXmlSeg := oInfSeg
		if !valtype(oInfSeg) == "A"
			aXmlSeg := {oInfSeg}
		endif

		for nSeg := 1 to len(aXmlSeg)

			FwFreeObj(aAverb)
			aAverb := {}

			cRespSeg := if(mdfeType("aXmlSeg[" + alltrim(str(nSeg)) + "]:_INFRESP:_RESPSEG") == "O" .and. !empty(aXmlSeg[nSeg]:_INFRESP:_RESPSEG:TEXT), aXmlSeg[nSeg]:_INFRESP:_RESPSEG:TEXT, "")
			cCNPJ := if(mdfeType("aXmlSeg[" + alltrim(str(nSeg)) + "]:_INFRESP:_CNPJ") == "O" .and. !empty(aXmlSeg[nSeg]:_INFRESP:_CNPJ:TEXT), aXmlSeg[nSeg]:_INFRESP:_CNPJ:TEXT, "")
			cCPF := if(mdfeType("aXmlSeg[" + alltrim(str(nSeg)) + "]:_INFRESP:_CPF") == "O" .and. !empty(aXmlSeg[nSeg]:_INFRESP:_CPF:TEXT), aXmlSeg[nSeg]:_INFRESP:_CPF:TEXT, "")
			cSeg := if(mdfeType("aXmlSeg[" + alltrim(str(nSeg)) + "]:_INFSEG:_XSEG") == "O" .and. !empty(aXmlSeg[nSeg]:_INFSEG:_XSEG:TEXT), aXmlSeg[nSeg]:_INFSEG:_XSEG:TEXT, "")
			cCNPJSeg := if(mdfeType("aXmlSeg[" + alltrim(str(nSeg)) + "]:_INFSEG:_CNPJ") == "O" .and. !empty(aXmlSeg[nSeg]:_INFSEG:_CNPJ:TEXT), aXmlSeg[nSeg]:_INFSEG:_CNPJ:TEXT, "")
			cApolice := if(mdfeType("aXmlSeg[" + alltrim(str(nSeg)) + "]:_NAPOL") == "O" .and. !empty(aXmlSeg[nSeg]:_NAPOL:TEXT), aXmlSeg[nSeg]:_NAPOL:TEXT, "")

			aXmlAverb := {}
			if !mdfeType("aXmlSeg[" + alltrim(str(nSeg)) + "]:_NAVER") == "U"
				aXmlAverb := aXmlSeg[nSeg]:_NAVER
				if !mdfeType("aXmlSeg[" + alltrim(str(nSeg)) + "]:_NAVER") == "A"
					aXmlAverb := {aXmlSeg[nSeg]:_NAVER}
				endif
				for nAverb := 1 to len(aXmlAverb)
					cAverb := PadR( aXmlAverb[nAverb]:TEXT, 40)
					if !empty(cAverb )
						aAdd( aAverb, {cAverb, .F.} )
					endif
				next

			endif

			aAdd( aInfSeg, { PadR(cRespSeg, 1) , PadR( cCNPJ, 14), PadR( cCPF, 11), PadR( cSeg, 30), PadR( cCNPJSeg, 14), PadR( cApolice, 20), aClone(aAverb), .F. } )

		next

	else
		aAdd( aInfSeg, { PadR(cRespSeg, 1) , PadR( cCNPJ, 14), PadR( cCPF, 11), PadR( cSeg, 30), PadR( cCNPJSeg, 14), PadR( cApolice, 20), {{space(40), .F.}}, .F. } )

	endif

return

/*/{Protheus.doc} SetInfSeg
Carrega o vetor aCols do seguro 

@return		nil
/*/
static function SetInfSeg()
	local nInfSeg	 := 0
	local nCampos	 := 0

	aHeadSeg	:= GetHSeg()
	aHeadAverb	:= GetHAverb()

	if len(aInfSeg) == 0
		aColsSeg	:= GetNewLine(aHeadSeg, .T.)
		aColsAverb	:= GetNewLine(aHeadAverb, .T.)

	else
		fwfreeobj(aColsSeg)
		aColsSeg := {}
		for nInfSeg := 1 to len(aInfSeg)

			//Cria um linha do aLinhas em branco
			aAdd(aColsSeg, Array( Len(aHeadSeg)+1 ) )
			for nCampos := 1 To Len(aHeadSeg)
				do case
					case nCampos == 1
						aColsSeg[Len(aColsSeg),nCampos] := aInfSeg[nInfSeg][nCampos]
					case nCampos == 2
						if !empty(aInfSeg[nInfSeg][2])
							aColsSeg[Len(aColsSeg),nCampos] := FormatCpo("CGC",aInfSeg[nInfSeg][2])
						else
							aColsSeg[Len(aColsSeg),nCampos] := FormatCpo("CGC",aInfSeg[nInfSeg][3])
						endif
					case nCampos == 4
						aColsSeg[Len(aColsSeg),nCampos] := FormatCpo("CGC",aInfSeg[nInfSeg][5])
					otherwise
						aColsSeg[Len(aColsSeg),nCampos] := aInfSeg[nInfSeg][nCampos+1]
				endcase
			next
			//Atribui .F. para a coluna que determina se alinha do aLinhas esta deletada
			aColsSeg[Len(aColsSeg)][Len(aHeadSeg)+1] := .F.

			SetInfAvb(aHeadAverb, aInfSeg[nInfSeg][7])

		next

	endif

return

/*/{Protheus.doc} SetInfAvb
Carrega o vetor aCols da averbação

@return		nil
/*/
static function SetInfAvb(aHeader, aAverb)
	local nInfAverb	 := 1

	default aHeader	 := GetHAverb()
	default aAverb	 := {}

	if len(aAverb) > 0 // Averbação
		aColsAverb := {}
		for nInfAverb := 1 to len(aAverb)
			aAdd(aColsAverb, Array( Len(aHeader)+1 ) )
			aColsAverb[Len(aColsAverb),1] := aAverb[nInfAverb][1]
			aColsAverb[Len(aColsAverb)][Len(aHeader)+1] := aAverb[nInfAverb][2]
		next
	else
		aColsAverb := GetNewLine(aHeader, .T.)
	endif

return

/*/{Protheus.doc} ClearInfSeg
Limpa a private aInfSeg

@return		nil
/*/
static function ClearInfSeg()

	FwFreeObj(aInfSeg)
	aInfSeg := {}

return

/*/{Protheus.doc} VldSeg
Função para realizar a validação das informações do seguro ao confirma a inclusão ou alteração do MDFe.

@return		nil
/*/
static function VldSeg()
	local lRet		 := .F.
	local cMsgError	 := ""
	local nInfSeg	 := 0
	local cRespSeg	 := ""


	if type("aInfSeg") == "A" .and. len(aInfSeg) > 0
		cMsgError := ""
		for nInfSeg := 1 to len(aInfSeg)

			if aInfSeg[nInfSeg][len( aInfSeg[nInfSeg] )] .or. empty(aInfSeg[nInfSeg][1])
				loop
			endif

			cMsgLine := ""
			cRespSeg := aInfSeg[nInfSeg][1]

			if alltrim(cRespSeg) == "2" 
				if empty(aInfSeg[nInfSeg][2]) .and. empty(aInfSeg[nInfSeg][3])
					cMsgLine += "'" + STR0900 + "'" + CHR(13) + CHR(10) // "CNPJ/CPF do Responsável"
				endif

				if !empty(aInfSeg[nInfSeg][4]) .and. empty(aInfSeg[nInfSeg][5])
					cMsgLine += "'" + STR0902 + "'" + CHR(13) + CHR(10) // "CNPJ Seguradora"
				endif
			endif

			if !empty(cMsgLine)

				cMsgError += STR0905 + alltrim(str(nInfSeg)) + CHR(13) + CHR(10) // "Item: "
				cMsgError += STR0906 + CHR(13) + CHR(10) + cMsgLine // "Campos obrigatórios apenas se responsável pelo seguro for (2) responsável pela contratação do transporte."
			endif
		next

	endif

	lRet := empty(cMsgError)

	if !lRet
		MsgInfo(cMsgError,STR0539) //"Atenção"
	endif

return lRet

/*/{Protheus.doc} LoadInfCtr
Carrega as informações dos dados dos contratantes de serviço de transporte

@return		nil
/*/
static function LoadInfCtr(oXML)
	local oInfCtr	 	:= nil
	local cNome		 	:= ""
	local cCNPJ		 	:= ""
	local cCPF		 	:= ""
	local cIdEst	 	:= ""
	local nInfCtr	 	:= 0
	local cReg		 	:= ""
	local cNumCtr		:= ""
	local nVlCtrGlobal	:= 0

	private aXmlCtr	  := {}

	ClearInfCtr()

	oInfCtr := GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_INFCONTRATANTE")
	if !valtype(oInfCtr) == "U"

		aXmlCtr := oInfCtr
		if !valtype(oInfCtr) == "A"
			aXmlCtr := {oInfCtr}
		endif

		for nInfCtr := 1 to len(aXmlCtr)
			cCPF 			:= ""
			cCNPJ 			:= ""
			cReg 			:= ""
			cNome 			:= if(mdfeType("aXmlCtr[" + alltrim(str(nInfCtr)) + "]:_XNOME") == "O" .and. !empty(aXmlCtr[nInfCtr]:_XNOME:TEXT), aXmlCtr[nInfCtr]:_XNOME:TEXT, "") 
			cCNPJ 			:= if(mdfeType("aXmlCtr[" + alltrim(str(nInfCtr)) + "]:_CNPJ") == "O" .and. !empty(aXmlCtr[nInfCtr]:_CNPJ:TEXT), aXmlCtr[nInfCtr]:_CNPJ:TEXT, "")
			cNumCtr 		:= if(mdfeType("aXmlCtr[" + alltrim(str(nInfCtr)) + "]:_INFCONTRATO:_NROCONTRATO") == "O" .and. !empty(aXmlCtr[nInfCtr]:_INFCONTRATO:_NROCONTRATO:TEXT), aXmlCtr[nInfCtr]:_INFCONTRATO:_NROCONTRATO:TEXT, "")
			nVlCtrGlobal	:= if(mdfeType("aXmlCtr[" + alltrim(str(nInfCtr)) + "]:_INFCONTRATO:_VCONTRATOGLOBAL") == "O" .and. !empty(aXmlCtr[nInfCtr]:_INFCONTRATO:_VCONTRATOGLOBAL:TEXT), Val(aXmlCtr[nInfCtr]:_INFCONTRATO:_VCONTRATOGLOBAL:TEXT), 0)
			if empty(cCNPJ)
				cCPF := if(mdfeType("aXmlCtr[" + alltrim(str(nInfCtr)) + "]:_CPF") == "O" .and. !empty(aXmlCtr[nInfCtr]:_CPF:TEXT), aXmlCtr[nInfCtr]:_CPF:TEXT, "")
				cReg := cCPF
			else
				cReg := cCNPJ
			endif
			cReg := PadR( cReg, GetSx3Cache("A1_CGC","X3_TAMANHO"))
			cIdEst := if(mdfeType("aXmlCtr[" + alltrim(str(nInfCtr)) + "]:_IDESTRANGEIRO") == "O" .and. !empty(aXmlCtr[nInfCtr]:_IDESTRANGEIRO:TEXT), aXmlCtr[nInfCtr]:_IDESTRANGEIRO:TEXT, "")

			aAdd( aInfContTr, { PadR(cNome, 60) , cReg, PadR( cIdEst, 20) , padr(cNumCtr,20) , nVlCtrGlobal} )

		next

	else
		aAdd( aInfContTr, { PadR(cNome, 60) , cReg, PadR( cIdEst, 20) , padr(cNumCtr,20) , nVlCtrGlobal} )

	endif

return

/*/{Protheus.doc} ClearInfCtr
Limpa a private aInfContTr

@return		nil
/*/
static function ClearInfCtr()

	FwFreeObj(aInfContTr)
	aInfContTr := {}

return

/*/{Protheus.doc} VldInfCont
Função para realizar a validação das informações do contratante do serviço de transporte ao confirma a inclusão ou alteração do MDFe.

@return		nil
/*/
static function VldInfCont()
	local lRet		 := .F.
	local cMsgError	 := ""
	local nInfCont	 := 0
	local nPos		 := 0
	local cInfo		 := ""
	
	cMsgError := ""
	for nInfCont := 1 to len(oGetInfCnt:aCols)

		cMsgLine := ""
		nPos := 0
		cInfo := ""
	
		if oGetInfCnt:aCols[nInfCont][len( oGetInfCnt:aCols[nInfCont] )] .or. (empty(oGetInfCnt:aCols[nInfCont][INFCNTNOME]) .and. empty(oGetInfCnt:aCols[nInfCont][INFCNTCNPJ]) .and. empty(oGetInfCnt:aCols[nInfCont][INFCNTIDES]))
			loop
		endif

		if !CmpInfCnt(nInfCont, oGetInfCnt:aCols, @nPos, @cInfo)
			cMsgLine += STR0917 + CHR(13) + CHR(10) + "[ " + STR0918 + ": " + alltrim(str(nPos)) + " - " + alltrim(cInfo) + " ]." + CHR(13) + CHR(10) // "Já foi informado: Razão social ou CPF/CNPJ ou Id Estrangeiro do contratante." ## item
		endif

		if !empty(oGetInfCnt:aCols[nInfCont][INFCNTNOME]) .And. len(alltrim( oGetInfCnt:aCols[nInfCont][1] )) <= 2
			cMsgLine += STR0919 + CHR(13) + CHR(10) // "Razão social ou Nome do contratante deve ter no mínimo 3 caracteres."
		endif

		if empty(oGetInfCnt:aCols[nInfCont][INFCNTCNPJ]) .and. empty(oGetInfCnt:aCols[nInfCont][INFCNTIDES])
			cMsgLine += STR0920 + CHR(13) + CHR(10) // "Deve ser informado o número do CPF/CNPJ do contratante do serviço ou Identificador do contratante em caso de contratante estrangeiro."
	
		elseif !empty(oGetInfCnt:aCols[nInfCont][INFCNTCNPJ]) .and. !VldCgc( alltrim(oGetInfCnt:aCols[nInfCont][INFCNTCNPJ]) )
			cMsgLine += STR0921 + CHR(13) + CHR(10) // "Deve ser informado o número do CPF/CNPJ do contratante do serviço corretamente."

		elseif !empty(oGetInfCnt:aCols[nInfCont][INFCNTIDES]) .and. len(alltrim(oGetInfCnt:aCols[nInfCont][INFCNTIDES])) <= 2
			cMsgLine += STR0922 + CHR(13) + CHR(10) // "Deve ser informado o Id Estrangeiro do contratante corretamente."

		endif
	
		if !empty(cMsgLine)

			cMsgError += STR0905 + alltrim(str(nInfCont)) + CHR(13) + CHR(10) // "Item: "
			cMsgError += cMsgLine
		endif
	next


	lRet := empty(cMsgError)

	if !lRet
		MsgInfo(cMsgError,STR0539) //"Atenção"
	endif

return lRet

/*/{Protheus.doc}  CmpInfCnt
Valida se já foi informado o contratante

@return		nil
/*/
static function CmpInfCnt(nLine, aDados, nPos, cInfo)
	local lRet		 := .T.
	local nInf		 := 0
	local nProx		 := 0
	local cNome		 := ""
	local cCNPJ		 := ""
	local cIdEst	 := ""

	default nLine	 := 0
	default aDados	 := {}
	default nPos	 := 0
	default cInfo	 := ""

	begin sequence

	nProx := nLine + 1

	if nLine == len(aDados) .or. nProx > len(aDados)
		break
	endif

	cNome := alltrim(aDados[nLine][INFCNTNOME])
	cCNPJ := alltrim(aDados[nLine][INFCNTCNPJ])
	cIdEst := alltrim(aDados[nLine][INFCNTIDES])
	cInfo := ""
	nPos := 0
	for nInf := nProx to len(aDados)

		if aDados[nInf][len( aDados[nInf] )] .or. (empty(aDados[nInf][INFCNTNOME]) .and. empty(aDados[nInf][INFCNTCNPJ]) .and. empty(aDados[nInf][INFCNTIDES]))
			loop
		endif

		if !empty(aDados[nInf][INFCNTNOME]) .and. cNome == alltrim(aDados[nInf][INFCNTNOME])
			cInfo += cNome
		endif

		if !empty(aDados[nInf][INFCNTCNPJ]) .and. cCNPJ == alltrim(aDados[nInf][INFCNTCNPJ])
			cInfo += + if(!empty(cInfo), ", ", "") + cCNPJ
		endif

		if !empty(aDados[nInf][INFCNTIDES]) .and. cIdEst == alltrim(aDados[nInf][INFCNTIDES])
			cInfo += if(!empty(cInfo), ", ", "") + cIdEst
		endif

		if !empty(cInfo)
			nPos := nInf
			exit
		endif
	next

	end sequence

	lRet := nPos == 0

return lRet

/*/{Protheus.doc} DlgInfCont
Apresenta a interface para informações dos contratantes de serviço de transporte	

@return		nil
/*/
static function DlgInfCont(oPanel, nOpc)
	local nTopGD	 := 0
	local nLeftGD	 := 0
	local nDownGD	 := 0
	local nRightGD	 := 0

	default nOpc := 0

	SetInfCont()

	nTopGD := MDFeResol(1,.F.)
	nLeftGD := MDFeResol(0.5,.T.)
	nDownGD := MDFeResol(21,.F.)
	nRightGD := MDFeResol(46,.T.)

	oGetInfCnt := MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(nOpc == 3 .or. nOpc == 4,GD_INSERT+GD_UPDATE+GD_DELETE,0),,,,,,,,,,oPanel,aHeadInfCt,@aColsInfCt)
	
return

/*/{Protheus.doc} SetInfCont
Carrega o vetor aCols do contratantes

@return		nil
/*/
static function SetInfCont()
	local nInfCont	 := 0
	local nCampos	 := 0

	FwFreeObj(oGetInfCnt)
	aHeadInfCt := GetHInfCnt()

	if len(aInfContTr) == 0
		aColsInfCt	:= GetNewLine(aHeadInfCt, .T.)

	else
		fwfreeobj(aColsInfCt)
		aColsInfCt := {}
		for nInfCont := 1 to len(aInfContTr)

			//Cria um linha do aLinhas em branco
			aAdd(aColsInfCt, Array( Len(aHeadInfCt)+1 ) )
			for nCampos := 1 To Len(aHeadInfCt)
				if nCampos == INFCNTCNPJ
					aColsInfCt[Len(aColsInfCt),nCampos] := if (!empty(aInfContTr[nInfCont][nCampos]), FormatCpo("CGC",aInfContTr[nInfCont][nCampos]), padr("", GetSx3Cache("A1_CGC","X3_TAMANHO")) )
				else
					aColsInfCt[Len(aColsInfCt),nCampos] := aInfContTr[nInfCont][nCampos]
				endif
			next
			//Atribui .F. para a coluna que determina se alinha do aLinhas esta deletada
			aColsInfCt[Len(aColsInfCt)][Len(aHeadInfCt)+1] := .F.

		next

	endif

return

/*/{Protheus.doc} GetHInfCnt
Define cabeçalho da informação dos contratantes

@return		nil
/*/
static function GetHInfCnt()
	
	local aRet := {}

	// https://devforum.totvs.com.br/579-aheader-do-msnewgetdados
	aadd(aRet,{	STR0923 ,"InfCntNome"	,""		,60 ,0 ,""							,"","C","","R","","","","","",""}) // "Nome Contratante"
	aadd(aRet,{	STR0924 ,"InfCntCNPJ"	,""		,14 ,0 ,"VldCgc(@InfCntCNPJ)"		,"","C","","R","","","","","",""}) // "CNPJ/CPF Contratante"
	aadd(aRet,{	STR0925	,"InfCntIDEs"	,"" 	,20 ,0 ,""							,"","C","","R","","","","","",""}) // "Id Estrangeiro"
	aadd(aRet,{	STR0982	,"InfCntNro"	,"@E 99999999999999999999"		,20 ,0 ,"","","C","","R","","","","","",""}) // "Numero do Contrato"
	aadd(aRet,{	STR0983	,"InfCntVGlo"	,"@E 9, 999, 999, 999, 999.99"	,16	,2	,"","","N","","R","","","","","",""}) // "Valor Global do Contrato"

return aRet

/*/{Protheus.doc} MDfeDefCnt
Escolhe o contratante do serviço de transporte

@return		nil
/*/
function MDfeDefCnt(nOpc)

local cQuery	:= ""
local aNotas	:= {}

if nOpc == 3 .or. nOpc == 4

	aNotas := recNFPPred() 	//notas selecionadas

	if len(aNotas) > 0
		//query para apresentação dos produtos com mais ocorrencia
		cQuery := retQryCont(aNotas)
		
		//seleção do produto predominante
		selCntTrp(cQuery)

	endIf

endIf

return

/*/{Protheus.doc} retQryCont
Responsavel por montar query para determinar quem são os clientes/fornecedores
com base nas notas selecionadas para apresentar o contratante do serviço de
transporte

@param		aNotas, array, recno de notas selecionadas
@return		cQuery, String, query a ser executada
/*/
static function retQryCont(aNotas)
local cQuery	:= ""

if !empty(aNotas[1])
	cQuery += "SELECT DISTINCT '  ' MARK, SF1.F1_FILIAL FILIAL, 'E' TP_NF, SF1.F1_TIPO TIPO, SF1.F1_FORNECE CODIGO, SF1.F1_LOJA LOJA FROM " + RetSqlName("SF1") + " SF1 " 
	cQuery += "WHERE SF1.R_E_C_N_O_ IN (" + aNotas[1] + ") "
endIf

if !empty(aNotas[1]) .and. !empty(aNotas[2])
	cQuery += " UNION "
endIf

if !empty(aNotas[2])
	cQuery += "SELECT DISTINCT  '  ' MARK, SF2.F2_FILIAL FILIAL, 'S' TP_NF, SF2.F2_TIPO TIPO, SF2.F2_CLIENTE CODIGO, SF2.F2_LOJA LOJA FROM " + RetSqlName("SF2") + " SF2 " 
	cQuery += "WHERE SF2.R_E_C_N_O_ IN (" + aNotas[2] + ") "
endIf

cQuery += " ORDER BY 2, 3, 4 "

return cQuery

/*/{Protheus.doc} selCntTrp
Responsavel por exibir quem são os clientes/fornecedores com base nas notas 
selecionadas para apresentar o contratante do serviço de transporte 
para seleção

@param		cQuery, String, query a ser executada
@return		nil
/*/
static function selCntTrp(cQuery)
local lOk 			:= .F.
local cAlias 		:= GetNextAlias()
local bOk			:= {|| getContrat(cAlias, aInfFil ), lOk := .T., oDlgCnt:End() }
local bCancelar		:= {|| oDlgCnt:End() }
local nI			:= 0
local aFields 		:= {}
local aColumns		:= {}
local cbckCadastro	:= cCadastro
local cCGC 			:= "MdfeGetCnt( '" + cAlias + "', 'CGC' )"
local cID_ESTR 		:= "MdfeGetCnt( '" + cAlias + "', 'ID_ESTR' )"
local cNOME 		:= "MdfeGetCnt( '" + cAlias + "', 'NOME' )"
local oIntCtr		:= nil
local cIdUp 		:= ""
local cIdMidUp		:= ""
local cIdMidDown	:= ""
local cIdDown 		:= ""
local oPUp 			:= nil
local oPMidUp		:= nil
local oPMidDown		:= nil
local oPDown 		:= nil
local oListFil		:= nil
local aInfFil		:= {}

private oMarkCnt	:= nil
private oDlgCnt 	:= nil

cCadastro := STR0915 // "Contratantes do serviço de transporte"

Define MsDialog oDlgCnt FROM 0, 0  To MDFeResol(75,.F.),MDFeResol(75,.T.) Title STR0926 OF oMainWnd PIXEL // "Seleção do contratante"

oIntCtr := FWFormContainer():New( oDlgCnt )
cIdUp := oIntCtr:CreateHorizontalBox(05)
cIdMidUp := oIntCtr:CreateHorizontalBox(15)
cIdMidDown := oIntCtr:CreateHorizontalBox(05)
cIdDown := oIntCtr:CreateHorizontalBox(75)

oIntCtr:Activate( oDlgCnt, .T. )
oPUp := oIntCtr:GeTPanel( cIdUp )
oPMidUp := oIntCtr:GeTPanel( cIdMidUp )
oPMidDown := oIntCtr:GeTPanel( cIdMidDown )
oPDown := oIntCtr:GeTPanel( cIdDown )

TSay():New(04,04,{ || STR0927 },oPUp,,,,,,.T.,CLR_BLUE,,200,20) // "Emitente do MDFe"

aAdd( aInfFil, { .F., FormatCpo("CGC", alltrim(SM0->M0_CGC)) , PadR(alltrim(SM0->M0_NOMECOM), 60)})
@ 0, 0 LISTBOX oListFil FIELDS HEADER " ",STR0929, STR0928 SIZE 100,100 PIXEL OF oPMidUp // "CNPJ/CPF" ## "Nome"
oListFil:SetArray( aInfFil )
oListFil:bLine := { || {If(aInfFil[oListFil:nAt,1],oOkx,oNo),aInfFil[oListFil:nAt,2],aInfFil[oListFil:nAt,3]}}
oListFil:Align := CONTROL_ALIGN_ALLCLIENT
oListFil:BldBlClick := {|| aInfFil[oListFil:nAt,1] := !aInfFil[oListFil:nAt,1], oListFil:Refresh() }
oListFil:bHeaderClick := {|| aEval(aInfFil, {|e| e[1] := !e[1] }), oListFil:Refresh()}

TSay():New(04,04,{ || STR0930 },oPMidDown,,,,,,.T.,CLR_BLUE,,200,20) // "Clientes ou Fornecedores"

aAdd( aFields, { "CODIGO"	, STR0931 , "C", GetSx3Cache("A1_COD","X3_TAMANHO")	 , 0 , GetSx3Cache("A1_COD","X3_PICTURE") }) // "Código"
aAdd( aFields, { "LOJA"		, STR0932 , "C", GetSx3Cache("A1_LOJA","X3_TAMANHO")	 , 0 , GetSx3Cache("A1_LOJA","X3_PICTURE") }) // "Loja"
aAdd( aFields, { cCGC		, STR0929 , "C", GetSx3Cache("A1_CGC","X3_TAMANHO")	 , 0 , "" }) // "CNPJ/CPF"
aAdd( aFields, { cID_ESTR	, STR0933 , "C", GetSx3Cache("A1_PFISICA","X3_TAMANHO"), 0 , GetSx3Cache("A1_PFISICA","X3_PICTURE") }) // "ID Estrangeiro"
aAdd( aFields, { cNOME		, STR0928 , "C", GetSx3Cache("A1_NOME","X3_TAMANHO")	 , 0 , GetSx3Cache("A1_NOME","X3_PICTURE") }) // "Nome"
	
for nI := 1 To Len( aFields )
	aAdd( aColumns, FWBrwColumn():New() )
	aColumns[Len(aColumns)]:SetID( aFields[nI] )
	aColumns[Len(aColumns)]:SetTitle( aFields[nI][2] )
	aColumns[Len(aColumns)]:SetData( &("{ || " + aFields[nI][1] + " }") )
	aColumns[Len(aColumns)]:SetType( aFields[nI][3] )
	aColumns[Len(aColumns)]:SetSize( aFields[nI][4] )
	aColumns[Len(aColumns)]:SetDecimal(aFields[nI][5] )
	aColumns[Len(aColumns)]:SetPicture( aFields[nI][6] )
next nI
 
oMarkCnt := FWMarkBrowse():New()
oMarkCnt:SetDataQuery( .T. )
oMarkCnt:SetQuery(cQuery)
oMarkCnt:SetAlias( cAlias )
oMarkCnt:SetFieldMark("MARK")
oMarkCnt:SetColumns( aColumns )
oMarkCnt:SetMenuDef('')
oMarkCnt:DisableReport()
oMarkCnt:DisableConfig()
oMarkCnt:DisableFilter()
oMarkCnt:ForceQuitButton(.T.)
oMarkCnt:SetOwner(oPDown)
oMarkCnt:SetTemporary( .T. )
oMarkCnt:SetIgnoreARotina(.T.)
oMarkCnt:Activate()

ACTIVATE MSDIALOG oDlgCnt ON INIT EnchoiceBar(oDlgCnt, bOk , bCancelar ,,,,,.F.,.F.,.F.,,.F.) CENTERED

cCadastro := cbckCadastro

if select(cAlias) > 0
	(cAlias)->(dbCloseArea())
endif

return nil

/*/{Protheus.doc} getContrat
Retorna a informação da SA1 e SA2

/*/
static function getContrat( cAlias, aItem)
	local lRet 	:= .T.
	local nItem := 0

	default aItem := {}

	FwFreeObj(aColsInfCt)
	aColsInfCt := {}

	for nItem := 1 to len(oGetInfCnt:aCols)

		if oGetInfCnt:aCols[nItem][len( oGetInfCnt:aCols[nItem] )] .or. (empty(oGetInfCnt:aCols[nItem][INFCNTNOME]) .and. empty(oGetInfCnt:aCols[nItem][INFCNTCNPJ]) .and. empty(oGetInfCnt:aCols[nItem][INFCNTIDES]))
			loop
		endif

		aAdd(aColsInfCt, Array( Len(aHeadInfCt)+1 ) )
		aColsInfCt[len(aColsInfCt)][INFCNTNOME] := oGetInfCnt:aCols[nItem][INFCNTNOME]
		aColsInfCt[len(aColsInfCt)][INFCNTCNPJ] := oGetInfCnt:aCols[nItem][INFCNTCNPJ]
		aColsInfCt[len(aColsInfCt)][INFCNTIDES] := oGetInfCnt:aCols[nItem][INFCNTIDES]
		aColsInfCt[len(aColsInfCt)][INFCNTNRO]	:= oGetInfCnt:aCols[nItem][INFCNTNRO]
		aColsInfCt[len(aColsInfCt)][INFCNTVGLO] := oGetInfCnt:aCols[nItem][INFCNTVGLO]
		aColsInfCt[Len(aColsInfCt)][Len(aHeadInfCt)+1] := .F.

	next

	for nItem := 1 to len(aItem)
		if aItem[nItem][1]
			aAdd(aColsInfCt, Array( Len(aHeadInfCt)+1 ) )
			aColsInfCt[len(aColsInfCt)][INFCNTNOME] := aItem[nItem][3]
			aColsInfCt[len(aColsInfCt)][INFCNTCNPJ] := aItem[nItem][2]
			aColsInfCt[len(aColsInfCt)][INFCNTIDES] := space(GetSx3Cache("A1_PFISICA","X3_TAMANHO"))
			aColsInfCt[len(aColsInfCt)][INFCNTNRO]	:= padr("",20)
			aColsInfCt[len(aColsInfCt)][INFCNTVGLO] := 0
			aColsInfCt[Len(aColsInfCt)][Len(aHeadInfCt)+1] := .F.
		endif
	next

	(cAlias)->(dbGoTop())
	while (cAlias)->(!eof())
		if !empty((cAlias)->MARK)
			aAdd(aColsInfCt, Array( Len(aHeadInfCt)+1 ) )
			aColsInfCt[len(aColsInfCt)][INFCNTNOME] := MdfeGetCnt( cAlias , 'NOME' )
			aColsInfCt[len(aColsInfCt)][INFCNTCNPJ] := MdfeGetCnt( cAlias , 'CGC' )
			aColsInfCt[len(aColsInfCt)][INFCNTIDES] := MdfeGetCnt( cAlias , 'ID_ESTR' )
			aColsInfCt[len(aColsInfCt)][INFCNTNRO]	:= padr("",20)
			aColsInfCt[len(aColsInfCt)][INFCNTVGLO] := 0
			aColsInfCt[Len(aColsInfCt)][Len(aHeadInfCt)+1] := .F.
		endif
		(cAlias)->(dbSkip())
	end

	if len(aColsInfCt) == 0
		aColsInfCt	:= GetNewLine(aHeadInfCt, .T.)
	endif

	oGetInfCnt:aCols := {}
	oGetInfCnt:SetArray(aColsInfCt, .T.)
	oGetInfCnt:Refresh( .T. )

return lRet

/*/{Protheus.doc} MdfeGetCnt
Retorna a informação da SA1 e SA2

/*/
function MdfeGetCnt( cAlias, cCampo )
	local cRet		:= ""
	local cFilReg	:= ""
	local cTabela	:= ""

	default cAlias := ""
	default cCampo := ""

	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(1))

	if alltrim((cAlias)->TP_NF) == "E"
		cFilReg := retFilClFo((cAlias)->FILIAL, (cAlias)->TIPO $ "B|D")
		if (cAlias)->TIPO $ "B|D"
			if SA1->(dbSeek(cFilReg + (cAlias)->CODIGO + (cAlias)->LOJA))
				cTabela := "SA1"
			endif
		else
			if SA2->(dbSeek(cFilReg + (cAlias)->CODIGO + (cAlias)->LOJA))
				cTabela := "SA2"
			endif
		endif
	else
		cFilReg := retFilClFo((cAlias)->FILIAL, !(cAlias)->TIPO $ "B|D")
		if (cAlias)->TIPO $ "B|D"
			if SA2->(dbSeek(cFilReg + (cAlias)->CODIGO + (cAlias)->LOJA))
				cTabela := "SA2"
			endif
		else
			if SA1->(dbSeek(cFilReg + (cAlias)->CODIGO + (cAlias)->LOJA))
				cTabela := "SA1"
			endif
		endif
	endif

	if !empty(cTabela)
		do case
			case cCampo == "CGC"
				cRet := FormatCpo("CGC",(cTabela)->&(SubStr(cTabela, 2, 2) + "_CGC"))
			case cCampo == "ID_ESTR"
				cRet := (cTabela)->&(SubStr(cTabela, 2, 2) + "_PFISICA")
			case cCampo == "NOME"
				cRet := (cTabela)->&(SubStr(cTabela, 2, 2) + "_NOME")
		end case
	endif

return cRet

/*/{Protheus.doc} DlgConduto
Apresenta a interface para informações dos condutores

@return		nil
/*/
static function DlgConduto(oPanel, nOpc)
	local nTopGD	:= 0
	local nLeftGD	:= 0
	local nDownGD	:= 0
	local nRightGD	:= 0
	local nMaxCond	:= 9 //Numero maixo de 9 condutores adicionais + condutor principal = total de 10

	default nOpc	:= 0

	SetCondutor()

	nTopGD		:= MDFeResol(1,.F.)
	nLeftGD		:= MDFeResol(0.5,.T.)
	nDownGD		:= MDFeResol(21,.F.)
	nRightGD	:= MDFeResol(46,.T.)
	oGetCondut	:= MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(nOpc == 3 .or. nOpc == 4,GD_INSERT+GD_UPDATE+GD_DELETE,0),,,,,,nMaxCond,,,,oPanel,aHeadCond,@aColsCondu)
	
return

/*/{Protheus.doc} SetCondutor
Carrega o vetor aCols do contratantes

@return		nil
/*/
static function SetCondutor()
	local nInfo	:= 0
	local nI	:= 0

	FwFreeObj(oGetCondut)
	aHeadCond := GetHCondut()

	if len(aCondutores) == 0
		aColsCondu	:= GetNewLine(aHeadCond, .T.)
	else
		fwfreeobj(aColsCondu)
		aColsCondu := {}
		for nInfo := 1 to len(aCondutores)

			//Cria um linha do aLinhas em branco
			aAdd(aColsCondu, Array( Len(aHeadCond)+1 ) )
			for nI := 1 To Len(aHeadCond)
				aColsCondu[Len(aColsCondu),nI] := iif(aHeadCond[nI,8]=="C",padr(aCondutores[nInfo][nI], aHeadCond[nI,4]),aCondutores[nInfo][nI])
			next
			//Atribui .F. para a coluna que determina se alinha do aLinhas esta deletada
			aColsCondu[Len(aColsCondu)][Len(aHeadCond)+1] := .F.
		next
	endif
return

/*/{Protheus.doc} GetHCondut
Define cabeçalho da informação de condutores
@param	nil
@date	08/11/2021
@return	nil
/*/
static function GetHCondut()
	local aRet := {}
	aadd(aRet,{STR0948,"CondCgc","@R 999.999.999-99",11,0,"MDFeVldCon('CondCgc',CondCgc)","","C","F3DA4()","R","","","","","",""}) //"CPF do Condutor"
	aadd(aRet,{STR0949,"CondNome","",60 ,0 ,"","","C","","R","","","","","",""}) //"Nome do Condutor"
return aRet

/*/{Protheus.doc} loadCondutores
Carrega as informações do condutor
@param	nil
@date	08/11/2021
@return	nil
/*/
static function loadCondutores(oXML)
	local oCondutores	:= nil
	local cNome		 	:= ""
	local cCPF		 	:= ""
	local nI			:= 0
	local nIni			:= if( lMotori .and. empty(cMotorista), 1, 2 )

	private aXMLCond	:= {}

	ClearCondutor()

	oCondutores := GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR")

	if !valtype(oCondutores) == "U"

		aXMLCond := iif(valtype(oCondutores) == "A", oCondutores, {oCondutores})
		for nI := nIni to len(aXMLCond) //Ignora o primeiro pois o motorista principal fica no cabeçalho da rotina
			cNome	:= allTrim(if(mdfeType("aXMLCond[" + alltrim(str(nI)) + "]:_XNOME") == "O" .and. !empty(aXMLCond[nI]:_XNOME:TEXT), aXMLCond[nI]:_XNOME:TEXT, ""))
			cCPF	:= allTrim(if(mdfeType("aXMLCond[" + alltrim(str(nI)) + "]:_CPF") == "O" .and. !empty(aXMLCond[nI]:_CPF:TEXT), aXMLCond[nI]:_CPF:TEXT, ""))
			aAdd( aCondutores, { PadR( cCPF, 11), PadR(cNome, 60) } )
		next

	else
		aAdd( aCondutores, { PadR( cCPF, 11), PadR(cNome, 60) } )
	endif
	fwFreeObj(aXMLCond)
	aXMLCond := {}
	fwFreeObj(oCondutores)
	oCondutores := nil
return nil

/*/{Protheus.doc} ClearCondutor
Limpa a private aCondutores

@return		nil
/*/
static function ClearCondutor(xData)
	fwFreeObj(aCondutores)
	aCondutores := {}
return

/*/{Protheus.doc} MDFeVldCon
Validação dos campos de condutores adicionais

@return		nil
/*/
function MDFeVldCon(cCampo, xInfo)
	local lRet		:= .T.
	local nPos		:= 0
	local aAreaDA4	:= {}

	cCampo := upper(cCampo)
	
	do case
		case cCampo == "CONDCGC"
	
			lRet := VldCgc(xInfo)
			if lRet .and. (nPos := aScan(oGetCondut:aCols, {|x| allTrim(x[1]) == alltrim(xInfo) })) > 0 .and. nPos != oGetCondut:nAt
				msgStop(STR0944 + allTrim(FormatCpo("CGC",xInfo)) + STR0945 + CHR(10)+CHR(13) + STR0946 + cValToChar(nPos), STR0539) //#"Numero de CPF: '" ##"' já informado na lista de condutores adicionais." ###"Linha: " ###Atenção
				lRet := .F.
			endIf
			if lRet .and. !empty(cMotorista)
				aAreaDA4 := DA4->(getArea())
				DA4->(dbSetOrder(1))
				if DA4->(MsSeek(xFilial("DA4")+cMotorista))
					if allTrim(DA4->DA4_CGC) == allTrim(xInfo)
						msgStop(STR0944 + allTrim(FormatCpo("CGC",xInfo)) + STR0947, STR0539) //#"Numero de CPF: '" ##"' já informado como condutor principal." ###Atenção
						lRet := .F.
					endIf
				endIf
				restArea(aAreaDA4)
			endIf
	endCase

return lRet

/*/{Protheus.doc} F3DA4
Consulta padrao F3 do campo de motoristas

@return		lRet = .T. Selecionado dado valido, .F. Selecionado dado invalido
/*/
function F3DA4()
Local lRet	:= ConPad1(,,,"DA4CGC",'CondCgc',,.F.,,,,,,)

if lRet .and. !MDFeVldCon('CondCgc', padr(DA4->DA4_CGC,11))
	lRet := .F.
endIf

Return lRet

/*/{Protheus.doc} F3DA4
Consulta padrao F3 do campo de motoristas

@return		lRet = .T. Selecionado dado valido, .F. Selecionado dado invalido
/*/
function MDFeVldMot()
local lRet		:= .T.
local aAreaDA4	:= DA4->(getArea())
local nPos		:= 0

DA4->(dbSetOrder(1))
if DA4->(MsSeek(xFilial("DA4")+cMotorista))
	if (nPos := aScan(oGetCondut:aCols, {|x| allTrim(x[1]) == allTrim(DA4->DA4_CGC) })) > 0
		msgStop(STR0944 + allTrim(FormatCpo("CGC",allTrim(DA4->DA4_CGC))) +STR0945 + CHR(10)+CHR(13) + STR0946 + cValToChar(nPos), STR0539) //#STR0944 ##"' já informado na lista de condutores adicionais." ###"Linha: " ####Atenção
		lRet := .F.
	endIf
endIf
restArea(aAreaDA4)
return lRet

/*/{Protheus.doc} vFilMdfe
Valida numero e data do filtro da mdfe.

@return		lRetorno = .T. campo valido, .F. campo invalido
/*/
Static Function vFilMdfe(cNumIni,cNumFim,dDtIni,dDtFim)

	Local lRetorno := .T.

	Default cNumIni	:= ""
	Default cNumFim	:= ""
	Default dDtIni	:= ctod("")
	Default dDtFim	:= ctod("")

	if !empty(cNumIni)  .and. !empty(cNumFim)
		if cNumIni > cNumFim
			MsgAlert(STR0956 , STR0539)
			lRetorno := .F.
		endif
	endif

	if !empty(dDtIni)  .and. !empty(dDtFim) 
		if dDtIni > dDtFim
			MsgAlert(STR0957, STR0539)
			lRetorno := .F.
		endif
	endif

Return lRetorno

/*/{Protheus.doc} ParBoxMdfe
Exibe a ParamBox ao Usuario

@return		lRet = .T. ParamBox valido, .F. ParamBox invalido
/*/
Static Function ParBoxMdfe(aStatus)
Local cFilMdfe		:= SM0->M0_CODIGO+SM0->M0_CODFIL+"FILTROMDFE"
Local aPerg	 		:={}
Local aParam		:={"","","","","","",""}
Local dDataAt  		:= 	Date()
Local lRet          := .F.
DEFAULT aStatus     :={}

//Monta as opçoes de filtro da ParamBox
aadd(aStatus,STR0465)//"0-Sem filtro"
aadd(aStatus,STR0466)//"1-Transmitidos"
aadd(aStatus,STR0467)//"2-Não Transmitidos"
aadd(aStatus,STR0468)//"3-Autorizados"
aadd(aStatus,STR0469)//"4-Não Autorizados"
aadd(aStatus,STR0470)//"5-Cancelados"
aadd(aStatus,STR0471)//"6-Encerrados"
If lMDFePost
	aadd(aStatus,"7-" + STR0517) //#"Carrega Posterior"
	aadd(aStatus,"8-" + STR0518) //#"Carrega Posterior sem Vinculo"
	aadd(aStatus,"9-" + STR0519) //#"Carrega Posterior Transmitido"
	aadd(aStatus,"10-" + STR0520) //#"Carrega Posterior Autorizado"
	aadd(aStatus,"11-" + STR0521) //#"Carrega Posterior Rejeitado"
EndIf

MV_PAR01	:= aParam[01] := PadR(ParamLoad(cFilMdfe,aPerg,1,aParam[01]),9)
MV_PAR02	:= aParam[02] := PadR(ParamLoad(cFilMdfe,aPerg,2,aParam[02]),36)
MV_PAR03	:= aParam[03] := PadR(ParamLoad(cFilMdfe,aPerg,3,aParam[03]),3)
MV_PAR04	:= aParam[04] := PadR(ParamLoad(cFilMdfe,aPerg,4,aParam[04]),9)
MV_PAR05	:= aParam[05] := PadR(ParamLoad(cFilMdfe,aPerg,5,aParam[05]),9)
MV_PAR06	:= aParam[06] := PadR(ParamLoad(cFilMdfe,aPerg,6,aParam[06]),9)
MV_PAR07	:= aParam[07] := PadR(ParamLoad(cFilMdfe,aPerg,7,aParam[07]),9)

aadd(aPerg,{2,STR0075,PadR("",Len("3-Entradas e Saidas")),{STR0076,STR0077,STR0504},100,".T.",.T.,".T."}) //"Tipo de NFe"###"1-Saída"###"2-Entrada###3-Entradas e Saidas"
aadd(aPerg,{2,STR0082,aParam[02],aStatus,100,".T.",.F.,".T."})//Filtra
aadd(aPerg,{1,STR0472,aParam[03],,,,,30,.F.})//"Série do MDFe"

aadd(aPerg,{1,STR0958,aParam[04],,,,,30,.F.})//"Número de:"
aadd(aPerg,{1,STR0959,aParam[05],,,,,30,.F.})//"Número até:"
aadd(aPerg,{1,STR0960,dDataAt,,,,,60,.F.})//"Data de emissão de:"
aadd(aPerg,{1,STR0961,dDataAt,,,,,60,.F.})//"Data de emissão até:"
	
If lModal
	aadd(aPerg,{2,STR0896,PadR("",Len(STR0885)),{STR0885,STR0886,STR0887},100,".T.",.T.,".T."}) //'1-Rodoviário','2-Aéreo','3-Todas'
EndIf

lRet := ParamBox(aPerg,STR0113,aParam,{||vFilMdfe(MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07)},,.T.,,,,cFilMdfe,.T.,.T.)
    
If  lRet
//Define as variaveis de filtro privadas
	cEntSai		:= SubStr(MV_PAR01,1,1)
		
	If SubStr(MV_PAR02,1,1) != "7"
		cStatFil	:= MV_PAR02
	Else
		cStatFil	:= aStatus[4] //"3-Autorizados"
	EndIf

	cSerFil		:= MV_PAR03
    cNumNFDe	:= MV_PAR04
    cNumNFAt	:= MV_PAR05
	cDtEmDe		:= MV_PAR06
	cDtEmAt		:= MV_PAR07 
	cFModal	    := MV_PAR08
EndIf

return  lRet

/*/{Protheus.doc} DlgReboque
Apresenta a interface para informações dos reboques

@return		nil
/*/
static function DlgReboque(oPanel, nOpc)
	local nTopGD	:= 0
	local nLeftGD	:= 0
	local nDownGD	:= 0
	local nRightGD	:= 0
	local nMaxReb	:= 3

	default nOpc	:= 0

	SetReboque()

	nTopGD := MDFeResol(1,.F.)
	nLeftGD := MDFeResol(0.5,.T.)
	nDownGD := MDFeResol(21,.F.)
	nRightGD := MDFeResol(46,.T.)
	oGetReb	:= MsNewGetDados():New(nTopGD,nLeftGD,nDownGD,nRightGD,iif(nOpc == 3 .or. nOpc == 4,GD_INSERT+GD_UPDATE+GD_DELETE,0),,,,,,nMaxReb,,,,oPanel,aHeadReb,@aColsReb)
	
return

/*/{Protheus.doc} SetReboque
Carrega o vetor aCols do reboque

@return		nil
/*/
static function SetReboque()
	local nInfo	:= 0
	local nI	:= 0

	FwFreeObj(oGetReb)
	aHeadReb := GetHReb()

	if len(aRebMDFe) == 0
		aColsReb	:= GetNewLine(aHeadReb, .T.)
	else
		fwfreeobj(aColsReb)
		aColsReb := {}
		for nInfo := 1 to len(aRebMDFe)
			aAdd(aColsReb, Array( Len(aHeadReb)+1 ) )
			for nI := 1 To Len(aHeadReb)
				aColsReb[Len(aColsReb),nI] := iif(aHeadReb[nI,8]=="C",padr(aRebMDFe[nInfo][nI], aHeadReb[nI,4]),aRebMDFe[nInfo][nI])
			next
			aColsReb[Len(aColsReb)][Len(aHeadReb)+1] := .F.
		next
	endif
return

/*/{Protheus.doc} GetHReb
Define cabeçalho da informação de reboque
@param	nil
@date	08/11/2021
@return	nil
/*/
static function GetHReb()
	local aRet := {}

	aadd(aRet,{STR0931 ,"RebCodVeic", GetSx3Cache("DA3_COD","X3_PICTURE")	 , GetSx3Cache("DA3_COD","X3_TAMANHO")	 , GetSx3Cache("DA3_COD","X3_DECIMAL")	 , "MDFeVldReb(RebCodVeic)","","C","F3DA3()","R","","","","","",""}) // "Código"
	aadd(aRet,{STR0965 ,"RebPlaca"	 , GetSx3Cache("DA3_PLACA","X3_PICTURE") , GetSx3Cache("DA3_PLACA","X3_TAMANHO") , GetSx3Cache("DA3_PLACA","X3_DECIMAL") , "","","C","","R","","",".F.","","",""}) // "Placa"
	aadd(aRet,{STR0966 ,"RebEstado" , GetSx3Cache("DA3_ESTPLA","X3_PICTURE"), GetSx3Cache("DA3_ESTPLA","X3_TAMANHO"), GetSx3Cache("DA3_ESTPLA","X3_DECIMAL"), "","","C","","R","","",".F.","","",""}) // "Estado"
	aadd(aRet,{STR0967 ,"RebRenavam", GetSx3Cache("DA3_RENAVA","X3_PICTURE"), GetSx3Cache("DA3_RENAVA","X3_TAMANHO"), GetSx3Cache("DA3_RENAVA","X3_DECIMAL"), "","","C","","R","","",".F.","","",""}) // "Renavam"
	aadd(aRet,{STR0968 ,"RebProp"	 , GetSx3Cache("DA3_FROVEI","X3_PICTURE"), GetSx3Cache("DA3_FROVEI","X3_TAMANHO"), GetSx3Cache("DA3_FROVEI","X3_DECIMAL"), "","","C","","R","1=" + STR0969 + ";2=" + STR0970 + ";3=" + STR0971 + "","",".F.","","",""}) // "Frota" # Propria # Terceiro # Agregado

return aRet

/*/{Protheus.doc} loadReboque
Carrega as informações do reboque
@param	nil
@date	08/11/2021
@return	nil
/*/
static function loadReboque(oXML)
	local oReboque	:= nil
	local nI		:= 0
	local cInt		:= ""
	local cPlaca	:= ""
	local cUF		:= ""
	local cRenavam 	:= ""
	local cTpProp	:= ""

	private aXMLCond	:= {}

	ClearReboque()

	oReboque := GetMDeInfo(oXML,"_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE")

	if !valtype(oReboque) == "U"

		aXMLCond := iif(valtype(oReboque) == "A", oReboque, {oReboque})

		for nI := 1 to len(aXMLCond)
			cInt := allTrim(if(mdfeType("aXMLCond[" + alltrim(str(nI)) + "]:_CINT") == "O" .and. !empty(aXMLCond[nI]:_CINT:TEXT), aXMLCond[nI]:_CINT:TEXT, ""))
			cPlaca := allTrim(if(mdfeType("aXMLCond[" + alltrim(str(nI)) + "]:_PLACA") == "O" .and. !empty(aXMLCond[nI]:_PLACA:TEXT), aXMLCond[nI]:_PLACA:TEXT, ""))
			cUF := allTrim(if(mdfeType("aXMLCond[" + alltrim(str(nI)) + "]:_UF") == "O" .and. !empty(aXMLCond[nI]:_UF:TEXT), aXMLCond[nI]:_UF:TEXT, ""))
			cRenavam := allTrim(if(mdfeType("aXMLCond[" + alltrim(str(nI)) + "]:_RENAVAM") == "O" .and. !empty(aXMLCond[nI]:_RENAVAM:TEXT), aXMLCond[nI]:_RENAVAM:TEXT, ""))
			cTpProp := allTrim(if(mdfeType("aXMLCond[" + alltrim(str(nI)) + "]:_PROP:_TPPROP") == "O" .and. !empty(aXMLCond[nI]:_PROP:_TPPROP:TEXT), aXMLCond[nI]:_PROP:_TPPROP:TEXT, ""))
			if !empty(cTpProp)
				if cTpProp == "0" //TAC Agregado
					cTpProp := "3" 
				elseif cTpProp == '1' //TAC Independente
					cTpProp	:= "2" 
				else//Outros
					cTpProp	:= "1" 
				endif
			endif

			aAdd( aRebMDFe, { PadR( cInt, GetSx3Cache("DA3_COD","X3_TAMANHO")), PadR(cPlaca, GetSx3Cache("DA3_PLACA","X3_TAMANHO")), PadR(cUF, GetSx3Cache("DA3_ESTPLA","X3_TAMANHO")), PadR(cRenavam, GetSx3Cache("DA3_RENAVA","X3_TAMANHO")), PadR(cTpProp, GetSx3Cache("DA3_FROVEI","X3_TAMANHO")) } )
		next

	else
		aAdd( aRebMDFe, { PadR( cInt, GetSx3Cache("DA3_COD","X3_TAMANHO")), PadR(cPlaca, GetSx3Cache("DA3_PLACA","X3_TAMANHO")), PadR(cUF, GetSx3Cache("DA3_ESTPLA","X3_TAMANHO")), PadR(cRenavam, GetSx3Cache("DA3_RENAVA","X3_TAMANHO")), PadR(cTpProp, GetSx3Cache("DA3_FROVEI","X3_TAMANHO")) } )
	endif

	fwFreeObj(aXMLCond)
	aXMLCond := {}
	fwFreeObj(oReboque)
	oReboque := nil

return nil

/*/{Protheus.doc} ClearReboque
Limpa a private aRebMDFe

@return		nil
/*/
static function ClearReboque()
	fwFreeObj(aRebMDFe)
	aRebMDFe := {}
return

/*/{Protheus.doc} F3DA3
Consulta padrao F3 do campo de motoristas

@return		lRet = .T. Selecionado dado valido, .F. Selecionado dado invalido
/*/
function F3DA3()
	local lRet	:= ConPad1(,,,"DA3",'RebCodVeic',,.F.,,,,,,)
return lRet

/*/{Protheus.doc} MDFeVldReb
Validação dos campos de reboque

@return		nil
/*/
function MDFeVldReb(cCodigo)
	local lRet		:= .F.
	local nPos		:= 0
	local cMsg 		:= ""
	local aAreaDA3 	:= {} 

	default cCodigo := ""

	dbSelectArea("DA3")
	aAreaDA3 := DA3->(getArea())

	begin sequence

	if alltrim(cCodigo) == alltrim(cVeiculo)
		cMsg := STR0972 // "Dado já informado no cabeçalho do MDFe."
		break
	endif

	if (nPos := aScan(oGetReb:aCols, {|x| allTrim(x[1]) == alltrim(cCodigo) })) > 0 .and. nPos != oGetReb:nAt
		cMsg := STR0973 + cValtochar(nPos) // "Dado já informado na linha: "
		break
	endif

	DA3->(dbSetOrder(1))
	if !DA3->(dbSeek(xFilial('DA3') + cCodigo))
		cMsg := STR0974 + " - " + alltrim(cCodigo) // "Dado não encontrado."
		break
	endif

	oGetReb:aCols[oGetReb:nAt][2] := DA3->DA3_PLACA
	oGetReb:aCols[oGetReb:nAt][3] := DA3->DA3_ESTPLA
	oGetReb:aCols[oGetReb:nAt][4] := DA3->DA3_RENAVA
	if !empty(DA3->DA3_CODFOR) .and. !empty(DA3->DA3_LOJFOR)
		oGetReb:aCols[oGetReb:nAt][5] := DA3->DA3_FROVEI
	else
		oGetReb:aCols[oGetReb:nAt][5] := space(len(DA3->DA3_FROVEI))
	endif
	lRet := .T.

	end sequence

	restArea(aAreaDA3)

	if !lRet
		msgInfo(cMsg, STR0539) // "Atenção"
	endif

return lRet


/*/{Protheus.doc} MDfeDefReb
Escolhe o reboque

@return		nil
/*/
function MDfeDefReb(nOpc)
	local aAreaTRB	:= {}
	local aVeic		:= {}
	local cVeic		:= ""
	local nVeic		:= 0

	if nOpc == 3 .or. nOpc == 4

		aAreaTRB := TRB->(getArea())
		TRB->(dbGoToP())
		while TRB->(!Eof())
			if !Empty(TRB->TRB_MARCA)
				for nVeic := 1 to 3
					cVeic := TRB->&("TRB_VEICU" + alltrim(str(nVeic)))
					if !empty(cVeic) .And. !alltrim(cVeic) == alltrim(cVeiculo)
						if (aScan(aVeic,{|x| x == cVeic })) == 0
							aadd(aVeic, cVeic )
						endif
					endif
				next
			endif
			TRB->(dbSkip())
		end
		restArea(aAreaTRB)

		if len(aVeic) > 0
			selReb(aVeic)
		else
			MsgInfo(STR0975, STR0539) // "Nenhum reboque informado para os documentos selecionados." # "Atenção"
		endIf

	endIf

return

/*/{Protheus.doc} selReb
Responsavel por exibir quais são os reboques com base nas notas 
selecionadas para apresentar 

@param		cQuery, String, query a ser executada
@return		nil
/*/
static function selReb(aVeic)
	local lOk 			:= .F.
	local cQuery		:= ""
	local nVeic			:= ""
	local cVeic1		:= ""
	local cVeic2		:= ""
	local cVeic3		:= ""	
	local cIN			:= ""
	local cAlias 		:= ""
	local cMarcReb		:= ""
	local bOk			:= {|| getReboque(cAlias), lOk := .T., oDlgReb:End() }
	local bCancelar		:= {|| oDlgReb:End() }
	local nI			:= 0
	local aFields 		:= {}
	local aColumns		:= {}
	local cbckCadastro	:= cCadastro
	local oIntReb		:= nil
	local cPanel 		:= ""
	local oPanel 		:= nil

	private oMarkReb	:= nil
	private oDlgReb 	:= nil

	default aVeic	 := {}

	cIN := ""
	for nVeic := 1 to len(aVeic)
		if nVeic == 1
			cVeic1 := aVeic[nVeic]
		elseif nVeic == 2
			cVeic2 := aVeic[nVeic]
		elseif nVeic == 3
			cVeic3 := aVeic[nVeic]
		endif
		cIN += " '" + aVeic[nVeic] + "',"
	next
	cIN := substr(cIN,1,len(cIN)-1)

	cMarcReb := GetMark()

	cQuery := " SELECT DISTINCT "
	cQuery += " CASE "
	cQuery += " WHEN DA3_COD = '" + cVeic1 + "' OR DA3_COD = '" + cVeic2 + "' OR DA3_COD = '" + cVeic3 + "' 
	cQuery += " THEN '" + cMarcReb + "' "
	cQuery += " ELSE  '  '"
	cQuery += " END MARK, "
	cQuery += " DA3.DA3_FILIAL FILIAL, DA3.DA3_COD CODIGO, DA3.DA3_PLACA PLACA, DA3.DA3_ESTPLA ESTADO, DA3.DA3_RENAVA RENAVAM, DA3.DA3_FROVEI FROTA, DA3.DA3_CODFOR CODFOR, DA3.DA3_LOJFOR LOJFOR FROM " + RetSqlName("DA3") + " DA3 " 
	cQuery += " WHERE DA3.D_E_L_E_T_ = ' ' "
	// Verificar pois no rdmake MDFeSEFAZ o dbseek está pelo xFilial
	//if SubStr(cNfeFil,1,1) == "2" // Todas Filiais
		cQuery += " AND DA3.DA3_FILIAL = '" + xFilial('DA3') + "' "
	//endif
	cQuery += " AND DA3.DA3_COD IN ( "
	cQuery += cIN
	cQuery += " ) "
	cQuery += " ORDER BY 2, 3 "

	cAlias := GetNextAlias()

	aAdd( aFields, { "FILIAL"	, STR0976 , "C", GetSx3Cache("DA3_FILIAL","X3_TAMANHO") , 0 , GetSx3Cache("DA3_FILIAL","X3_PICTURE"), {} }) // "Filial"
	aAdd( aFields, { "CODIGO"	, STR0931 , "C", GetSx3Cache("DA3_COD","X3_TAMANHO") , 0 , GetSx3Cache("DA3_COD","X3_PICTURE"), {} }) // "Código"
	aAdd( aFields, { "PLACA"	, STR0965 , "C", GetSx3Cache("DA3_PLACA","X3_TAMANHO") , 0 , GetSx3Cache("DA3_PLACA","X3_PICTURE"), {} }) // "Placa"
	aAdd( aFields, { "ESTADO"	, STR0966 , "C", GetSx3Cache("DA3_ESTPLA","X3_TAMANHO") , 0 , GetSx3Cache("DA3_ESTPLA","X3_PICTURE"), {} }) // "Estado"
	aAdd( aFields, { "RENAVAM"	, STR0967 , "C", GetSx3Cache("DA3_RENAVA","X3_TAMANHO") , 0 , GetSx3Cache("DA3_RENAVA","X3_PICTURE"), {} }) // "RENAVAM"
	aAdd( aFields, { "FROTA"	, STR0968 , "C", GetSx3Cache("DA3_FROVEI","X3_TAMANHO")	 , 0 , GetSx3Cache("DA3_FROVEI","X3_PICTURE"), {"1="+STR0969,"2="+STR0970,"3="+STR0971} }) // "Frota" # Propria # Terceiro # Agregado

	for nI := 1 To Len( aFields )
		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[Len(aColumns)]:SetID( aFields[nI] )
		aColumns[Len(aColumns)]:SetTitle( aFields[nI][2] )
		aColumns[Len(aColumns)]:SetData( &("{ || " + aFields[nI][1] + " }") )
		aColumns[Len(aColumns)]:SetType( aFields[nI][3] )
		aColumns[Len(aColumns)]:SetSize( aFields[nI][4] )
		aColumns[Len(aColumns)]:SetDecimal(aFields[nI][5] )
		aColumns[Len(aColumns)]:SetPicture( aFields[nI][6] )
		if len(aFields[nI][7]) > 0 
			aColumns[Len(aColumns)]:SetOptions(aFields[nI][7])
		endif
	next nI

	cCadastro := STR0963 // "Reboques"

	Define MsDialog oDlgReb FROM 0, 0  To MDFeResol(75,.F.),MDFeResol(75,.T.) Title STR0977 OF oMainWnd PIXEL // "Seleção dos reboques"

	oIntReb := FWFormContainer():New( oDlgReb )
	cPanel := oIntReb:CreateHorizontalBox(100)

	oIntReb:Activate( oDlgReb, .T. )
	oPanel := oIntReb:GeTPanel( cPanel )

	oMarkReb := FWMarkBrowse():New()
	oMarkReb:SetDataQuery( .T. )
	oMarkReb:SetMark(cMarcReb)
	oMarkReb:SetQuery(cQuery)
	oMarkReb:SetAlias( cAlias )
	oMarkReb:SetFieldMark("MARK")
	oMarkReb:SetColumns( aColumns )
	oMarkReb:SetMenuDef('')
	oMarkReb:DisableReport()
	oMarkReb:DisableConfig()
	oMarkReb:DisableFilter()
	oMarkReb:ForceQuitButton(.T.)
	oMarkReb:SetOwner(oPanel)
	oMarkReb:SetTemporary( .T. )
	oMarkReb:SetIgnoreARotina(.T.)	
	oMarkReb:Activate()

	ACTIVATE MSDIALOG oDlgReb ON INIT EnchoiceBar(oDlgReb, bOk , bCancelar ,,,,,.F.,.F.,.F.,,.F.) CENTERED

	cCadastro := cbckCadastro

	if select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	endif

return nil

/*/{Protheus.doc} getReboque
Retorna os rebqoues

/*/
static function getReboque( cAlias )
	local lRet		 := .T.
	local nItem		 := 0
	local cVeicNota  := ""

	FwFreeObj(aColsReb)
	aColsReb := {}

	for nItem := 1 to len(oGetReb:aCols)
		if oGetReb:aCols[nItem][len( oGetReb:aCols[nItem] )] .or. empty(oGetReb:aCols[nItem][1]) .or. (alltrim(oGetReb:aCols[nItem][1]) == alltrim(cVeiculo))
			loop
		endif

		aAdd(aColsReb, Array( len(aHeadReb)+1 ) )
		aColsReb[len(aColsReb)][1] := oGetReb:aCols[nItem][1]
		aColsReb[len(aColsReb)][2] := oGetReb:aCols[nItem][2]
		aColsReb[len(aColsReb)][3] := oGetReb:aCols[nItem][3]
		aColsReb[len(aColsReb)][4] := oGetReb:aCols[nItem][4]
		aColsReb[len(aColsReb)][5] := oGetReb:aCols[nItem][5]

		aColsReb[len(aColsReb)][len(aHeadReb)+1] := .F.

	next

	if len(aColsReb) < 3
		(cAlias)->(dbGoTop())
		while (cAlias)->(!eof())
			if !empty((cAlias)->MARK)
				cVeicNota := (cAlias)->CODIGO
				if len(aColsReb) == 3
					exit
				endif
				if !empty(cVeicNota) .and. !((alltrim(cVeicNota) == alltrim(cVeiculo))) .and. aScan( aColsReb, { |X| alltrim(X[1]) == alltrim(cVeicNota)} ) == 0

					aAdd(aColsReb, Array( len(aHeadReb)+1 ) )
					aColsReb[len(aColsReb)][1] := (cAlias)->CODIGO
					aColsReb[len(aColsReb)][2] := (cAlias)->PLACA
					aColsReb[len(aColsReb)][3] := (cAlias)->ESTADO
					aColsReb[len(aColsReb)][4] := (cAlias)->RENAVAM
					if !empty((cAlias)->CODFOR) .and. !empty((cAlias)->LOJFOR)
						aColsReb[len(aColsReb)][5] := (cAlias)->FROTA
					else
						aColsReb[len(aColsReb)][5] := space(len((cAlias)->FROTA))
					endif
					aColsReb[len(aColsReb)][len(aHeadReb)+1] := .F.

				endif
			endif
			(cAlias)->(dbSkip())
		end
	endif

	if len(aColsReb) == 0
		aColsReb	:= GetNewLine(aHeadReb, .T.)
	endif

	oGetReb:aCols := {}
	oGetReb:SetArray(aColsReb, .T.)
	oGetReb:Refresh( .T. )

return lRet

/*/{Protheus.doc} retQrSel
Converter a query de acordo com o banco de dados
@author		Leonardo Silva Barbosa
@since		09.09.2022
@param		cDb, string, string contendo o banco de dados utilizado
@param		nPos, int, numero da posicao do ajuste
@return		cQuery, string, ajuste na query de acordo com a posicao
/*/
static function retQrSel(cDb,nPos)
local cQuery := ""

	If cDb == 'INFORMIX' .and. (nPos == 1 .or. nPos == 2 )
		cQuery := " FIRST 5 "
	Elseif cDb == 'MSSQL' .and. (nPos == 1 .or. nPos == 2 )
		cQuery := " TOP 5 "
	elseif cDb == 'POSTGRES' .and. nPos==3
		cQuery := " LIMIT 5 "
	elseif cDb == 'ORACLE' .and. nPos==4
		cQuery := " AND ROWNUM < 6 "		
	EndIf

return cQuery
