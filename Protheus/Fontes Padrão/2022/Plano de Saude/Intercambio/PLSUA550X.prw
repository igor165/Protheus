#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"

static cCodInt 	:= ""
static cDirTmp := PLSMUDSIS( "\plsptu\" )

static cServ 	:= "PPM,HM,HMR,VMT,VMD,REA,VTX,VDI"
static cAux 	:= "AUX,AUR"
static cAnest := "PAP,PA,PAR"
static cCusOpe := "COR,COP,UCO"
static cFilm 	:= "FIL"
static cGenPro := getNewPar("MV_PLPSPXM","99999994")
static cGenPac := getNewPar("MV_PLPACPT","99999998")
static lPTUDEPARA := existBlock("PTUDEPARA")
static cGridFilter := ""
Static aNUMGOI	:= {"",""}
Static lNUMGOI := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA550EXP
classe referente a engine de exportacao do PTU A550

@author    pablo alipio
@since     10/2020
/*/
class PTUA550EXP

	data cOpeDes 	as String 	// Codigo unimed destino
	data cXml 		as String 	// String do Arquivo XML
	data cCabXml	as String 	// String do Arquivo XML
	data cEndXml	as String 	// String do Arquivo XML
	data cNameSpace as String 	// NameSpace do arquivo
	data cStrHash   as String 	// String que vai ser utilizada para calculo do hash
	data cHashMD5   as String 	// Hash MD5 calculado
	data cFolder    as String 	// Pasta onde sera gravado o arquivo XML
	data cFileName  as String 	// Nome do arquivo XML gerado
	data cGuiOpe   	as String 	// Chave da Guia
	data cProtoc  	as String 	// Protocolo
	data cAvisoXML  as String 	// Mensagem de aviso na geracao arquivo XML
	data cSchmFolde as String 	// Pasta com os schemas
	data cSchema    as String 	// Arquivo de Schema
	data cVersao    as String 	// Versao do Schema
	data lAuto      as Boolean  // Indica se a chamada da rotina e via automacao de testes
	data aMsg  		as Array    // Array com mensagens
	data lVersAtual as Boolean 	// Indica se a versao do layout é a mais atual
	data cAlias		as String 	// Alias da query com as guias
	data cAliasAux	as String 	// Alias da query com os procedimentos
	data nArqFull 	as numeric 	// Arquivo XML
	data nArqHash 	as numeric	// Arquivo do hash
	data nArqLog 	as numeric  // Arquivo de logs

	method New() CONSTRUCTOR

	method montaTag()
	method iniFile(cTag)
	method validXML()
	method geraHash()
	method calcHash()
	method geraXML()
	method addMsg()
	method procedimento()
	method procNFforn()
	method QuestNF()
	method beneficiario()
	method getBLOPAG()
	method fimGuia()
	method iniGuia()
	method SetVersao(nVersao)
	method logErro()
endclass
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA550X
exportação do PTU A550 XML

@author    pablo alipio
@since     10/2020
/*/
function PLSUA550X
	local aRet := {}
	cCodInt := plsintpad()

	PRIVATE aMark	:= {}
	private oMBrwBRJ := nil

// abre a tela de filtro
	cGridFilter := PTUA550FIL(.F.)
	setKey(VK_F2 ,{|| cGridFilter := PTUA550FIL(.T.) })

	oMBrwBRJ:= FWMarkBrowse():New()
	oMBrwBRJ:SetAlias("BRJ")
	oMBrwBRJ:SetMenuDef("PLSUA550X")
	oMBrwBRJ:SetFieldMark( 'BRJ_OK' )
	oMBrwBRJ:SetFilterDefault(cGridFilter)
	oMBrwBRJ:SetDescription('Exportação PTU A550')
	oMBrwBRJ:SetAllMark({ ||  markDesAll(oMBrwBRJ) })
	oMBrwBRJ:SetWalkThru(.F.)
	oMBrwBRJ:SetAmbiente(.F.)
	oMBrwBRJ:ForceQuitButton()
	oMBrwBRJ:SetAfterMark({||storeMark(oMBrwBRJ)})

	oMBrwBRJ:AddLegend( "BRJ->BRJ_NIV550 <> ' '",	'BR_VERDE'   ,	"Enviado" )
	oMBrwBRJ:AddLegend( "BRJ->BRJ_NIV550 = ' '",	'BR_VERMELHO',	"Não Enviado" )

	if existBlock("PLS500UNM")
		aRet := execBlock("PLS500UNM",.F.,.F.,{cServ,cAux,cAnest,cCusOpe,cFilm})
		cServ 	:= aRet[1]
		cAux 	:= aRet[2]
		cAnest 	:= aRet[3]
		cCusOpe	:= aRet[4]
		cFilm 	:= aRet[5]
	endif

	cCusOpe := strtran("'"+cCusOpe+"'",",","','")
	cFilm 	:= strtran("'"+cFilm+"'",",","','")

	oMBrwBRJ:Activate()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} menuDef
função para criar o menu da tela

@author    pablo alipio
@since     10/2020
/*/
static function menuDef()
	private aRotina := {}

	Add Option aRotina Title 'Exportar Arquivo(s)'		Action 'PTU550EXP()' 		  Operation 3 Access 0 // Incluir
	Add Option aRotina Title 'Filtro(F2)'  			      Action 'PTUA550FIL(.T.)' 	Operation 1 Access 0 // Filtro
	Add Option aRotina Title 'Dados Adicionais'       Action 'PlDetIt550()' 	  Operation 1 Access 0 // Filtro

return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA550FIL
fitro da tela inicial

@author    pablo alipio
@since     10/2020
/*/
function PTUA550FIL(lF2)
	local cGridFilter := ""
	local cStatus := ""
	local aPergs  := {}
	local aFilter := {}

	default lF2 := .f.

	aAdd( aPergs,{ 1, "A partir de:", dDataBase	, "", "", ""		, "", 50, .f.})
	aadd( aPergs,{ 2, "Status:"		 	, 	cStatus		,{ "0=Todas","1=Não Enviados","2=Enviados"},100,/*'.T.'*/,.f. } )

	cGridFilter += "@BRJ_FILIAL = '"+ BRJ->(xFilial("BRJ"))+ "' AND BRJ_REGPRI = '1' AND D_E_L_E_T_ = ' ' AND (BRJ_GLOSA = '1' OR BRJ_NUMSE2 <> ' ') "

// tela para selecionar os filtros
	if (paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSUA550X',/*lCanSave*/.T.,/*lUserSave*/.T. ) )

		if (!empty(aFilter[1]))
			cGridFilter += " AND BRJ_DATA >= '" + DtoS(aFilter[1]) + "' "
		endif

		if (!empty(aFilter[2]))
			if ( aFilter[2] == "1")
				cGridFilter += " AND BRJ_NIV550 = ' ' "
			endif

			if ( aFilter[2] == "2")
				cGridFilter += " AND BRJ_NIV550 <> ' ' "
			endif
		endif

	endif

	if (lF2)
		If Valtype(oMBrwBRJ) == "O"
			oMBrwBRJ:SetFilterDefault(cGridFilter)
			oMBrwBRJ:Refresh(.T.)
		EndIf
	endif

return cGridFilter

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} markDesAll
função para marcar e desmarcar todos da markbrowse

@author pablo alipio
@since 10/2020
@param oMBrwBRJ := browse da brj
/*/
//------------------------------------------------------------------------------------------
static function markDesAll(oMBrwBRJ)
	local nReg 	 := BRJ->(Recno())
	BRJ->( dbgotop() )

	while !BRJ->(Eof())
		// Marca ou desmarca. Este metodo respeita o controle de semaphoro.
		oMBrwBRJ:MarkRec()
		BRJ->(dbSkip())
	enddo

	BRJ->(dbGoto(nReg))
	oMBrwBRJ:oBrowse:Refresh(.t.)

return .t.


//-------------------------------------------------------------------
/*/{Protheus.doc} PTU550EXP
exportação do ptu xml a550

@author pablo alipio
@since 10/2020
/*/
//-------------------------------------------------------------------

function PTU550EXP(lAutoma)
	local cPath  := ""
	local aMsg   := {}
	local aPergs  := {}
	local lRet		:= .f.
	local aRetPar	:= {}
	default lAutoma := .f.

	private oProcess 	:= nil

	if ( len(aMark) > 0 ) .and. !lAutoma
		
		aadd( aPergs,{ 2 , "Versão PTU:" , 1 , { "1=PTU V2.0","2=PTU V1.1"} , 50 , "" , .F. } )
		aadd( aPergs,{ 6 , "Caminho do Destino:",Space(50),"","","",50,.t.,,,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY  )})
		if( paramBox( aPergs,"Parâmetros - Exportação PTU550 XML",aRetPar,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,300,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/.t.,/*lUserSave*/.t. ) )
			lRet := .t.
			cPath := aRetPar[2]
		endif
		if ( empty(cPath) ) // cancelou o browse ou nenhum
			return .f.
		elseif ( len(aMark) <= 0 )
			msgAlert("Nenhuma linha foi selecionada para exportação.")
			return .f.
		else
			oProcess := msNewProcess():New( { || processa(cPath, aMsg, .f., aRetPar[1] ) } , "Processando" , "Aguarde..." , .F. )
			oProcess:Activate()

			uncheckAll()

			if (len(aMsg) > 0 )
				PLSCRIGEN(aMsg,{ {"Arquivo","@C",50},{"Unimed","@C",4},{"Mensagem","@C",250} }, "Log de Exportação",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)
			endif
		endif
	else
		oProcess := P270fProc():New()
		cCodInt := plsintpad()
		processa(cDirTmp, aMsg, lAutoma)
	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} processa
processa e gera o xml

@author pablo alipio
@since 10/2020
@param  cPath = pasta onde sera salvo o arquivo
@param  aMSg  = array de mensagens sobre o processo
/*/
//-------------------------------------------------------------------

static function processa(cPath, aMsg, lAutoma, nVersao)
	local oPtu      := PTUA550EXP():New()
	local nI        := 1
	local cSql      := ""
	local cChavAux  := ""
	local cFileName := ""
	local lGera     := .f.
	local lValid    := .f.


	default aMsg := {}
	default lAutoma := .f.

	oPtu:aMsg 		:= aClone(aMsg)
	oPtu:cFolder    := cPath
	oPtu:SetVersao(val(cvaltochar(nVersao)))
	oPtu:cVersao    := iif(cvaltochar(nVersao) == "1" , "V2_0","V1_1")

	oProcess:SetRegua1( len(aMark) ) //Alimenta a primeira barra de progresso
	oProcess:SetRegua2( -1 ) //Alimenta a segunda barra de progresso

	BDX->(dbsetorder(1))
	SE2->(dbsetorder(1))

	for nI:=1 to len(aMark)
		BRJ->(dbGoto(aMark[nI][1]))
		oPtu:iniFile("ptuA550")

		oProcess:IncRegua1( "Processando Exportação " + BRJ->BRJ_CODIGO)

		cFileName := alltrim(BRJ->BRJ_NUMFAT)

		if ( len(cFileName) < 7)
			cFileName := replicate("_", 7 - len(cFileName)) + cFileName // se tem menos que 7, precisa preencher com "_"
		else
			cFileName := substr(cFileName, len(cFileName)-6,7)  // senão, precisamos apenas dos ultimos 7 caracteres
		endif

		//o NC é fixo, o 1 é da tag tp_arquivo. está fixo pq ela está fixa. se virar variável, concatenar o conteúdo dela no lugar do 1 aqui
		oPtu:cFileName 	:= "NC1_" + cFileName + "." + substr(cCodInt, 2, 4)

		// cabecalho
		oPtu:MontaTag( 1,"cabecalho")
		oPtu:MontaTag( 2,"nrVerTra_PTU", iif(oPtu:lVersAtual,"03","02"))

		oPtu:MontaTag( 2,"unimed")
		oPtu:MontaTag( 3,"cd_Uni_Destino",BRJ->BRJ_OPEORI)
		oPtu:MontaTag( 3,"cd_Uni_Origem",cCodInt)
		oPtu:MontaTag( 3,"cd_uni_cred",cCodInt)
		oPtu:MontaTag( 2,"unimed",,.T.)

		oPtu:MontaTag( 2,"dadosCobranca")
		oPtu:MontaTag( 3,"dt_Geracao",dtos(date()))
		oPtu:MontaTag( 3,"tp_Cobranca", BRJ->BRJ_TPCOB)
		oPtu:MontaTag( 3,"tp_Arquivo", "1")
		oPtu:MontaTag( 2,"dadosCobranca",,.T.)

		oPtu:MontaTag( 2,"documento1")

		oPtu:MontaTag( 3,"nr_Doc_1_A500", BRJ->BRJ_NUMFAT)

		BAF->(DBSetOrder(2))
		BAF->(DbSeek(xFilial("BAF") + BRJ->BRJ_CODIGO))

		iif(BRJ->BRJ_TPCOB == '3',oPtu:MontaTag( 3,"vl_Tot_Cont_Doc_1", str(BAF->BAF_VLTXGL)),oPtu:MontaTag( 3,"vl_Tot_Cont_Doc_1", str(BAF->BAF_VLRGLO)))
		
			oPtu:MontaTag( 3,"vl_Tot_Pago_Doc_1", str(iif(BRJ_TPPAG == '2',(BRJ->BRJ_VLRFAT - BAF->BAF_VLRGLO),BRJ->BRJ_VLRFAT)))

			oPtu:MontaTag( 2,"documento1",,.T.)

			if(BRJ->BRJ_TPCOB == '3' .and. !empty(BRJ->BRJ_NRNDC))
				oPtu:MontaTag( 2,"documento2")

				oPtu:MontaTag( 3,"nr_Doc_2_A500", BRJ->BRJ_NRNDC)
				oPtu:MontaTag( 3,"vl_Tot_Cont_Doc_2", str(BAF->BAF_VLRGLO))
				oPtu:MontaTag( 3,"vl_Tot_Pago_Doc_2", str(BRJ->BRJ_VLRNDC))

				oPtu:MontaTag( 2,"documento2",,.T.)
			endif

			oPtu:MontaTag( 1,"cabecalho",,.T.)
			// -- cabecalho

			// Tipo_Questionamento
			oPtu:MontaTag( 1,"Tipo_Questionamento")
			oPtu:MontaTag( 2,"Quest")
			oPtu:iniGuia()
			// Questionamento
			BD6->(DBSetOrder(14)) // BD6_FILIAL+BD6_SEQIMP+BD6_INCAUT
			cSql := " SELECT BD6_CODPEG, BD6_NUMERO, BD6_CODLDP, BD6_CODOPE FROM " + RetSQLName("BD6")
			cSql += " WHERE BD6_FILIAL = '" + xFilial("BD6")  + "' AND "
			cSql += " BD6_SEQIMP = '" + BRJ->BRJ_CODIGO + "' AND "
			cSql += " BD6_SITUAC != '2' AND "
			cSql += " (BD6_VLRGLO > 0 OR BD6_VLRGTX > 0) AND "
			cSql += " BD6_NF = ' ' AND " //Só vai estar preenchido quando for questionamento da nota fiscal do fornecedor, será tratado de forma separada mais abaixo
			cSql += " D_E_L_E_T_ = ' ' "
			cSql += " GROUP BY BD6_CODPEG, BD6_NUMERO, BD6_CODLDP, BD6_CODOPE "
			cSql += " ORDER BY BD6_CODPEG, BD6_NUMERO, BD6_CODLDP, BD6_CODOPE "
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBGUIA",.F.,.T.)

			// esse while é pra cada guia encontrada
			while !TRBGUIA->(Eof())
				cSql := " SELECT BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_QTDPRO, BD6_ORIMOV, "
				cSql += " BD6_DIGITO, BD6_NOMUSR, BD6_CODPAD, BD6_CODPRO, BD6_VLRGLO, BD6_VLRGTX, BD6_SEQUEN, BCI_LOTEDI, BD6_NUMIMP, BD6_LOTEDI, "
				cSql += " BD6_SLVPAD, BD6_SLVPRO, BD6_CD_PAC, BD6_DATPRO, BD6_BLOPAG, BD6_MOTBPG,BD6_CODRDA, BD6_TIPGUI "
				cSql += " FROM " + RetSQLName("BD6") + " BD6 "
				cSql += " LEFT JOIN " + RetSQLName("BCI") + " BCI ON "
				cSql += " BCI_FILIAL = '" + xFilial("BCI") + "' AND "
				cSql += " BCI_CODOPE = BD6_CODOPE AND "
				cSql += " BCI_CODLDP = BD6_CODLDP AND "
				cSql += " BCI_CODPEG = BD6_CODPEG AND "
				cSql += " BCI.D_E_L_E_T_ = ' ' "
				cSql += " WHERE BD6_FILIAL = '" + xFilial("BD6")  + "' AND "
				cSql += " BD6_CODOPE = '" + TRBGUIA->BD6_CODOPE + "' AND "
				cSql += " BD6_CODLDP = '" + TRBGUIA->BD6_CODLDP + "' AND "
				cSql += " BD6_CODPEG = '" + TRBGUIA->BD6_CODPEG + "' AND "
				cSql += " BD6_NUMERO = '" + TRBGUIA->BD6_NUMERO + "' AND "
				cSql += " BD6.D_E_L_E_T_ = ' ' "
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBQUEST",.F.,.T.)

				// esse while é pra cada procedimento
				oPtu:cAlias := 'TRBQUEST'
				while !TRBQUEST->(Eof())
					// abre uma tag Questionamento
					if (allTrim(TRBQUEST->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)) != cChavAux)
						// Questionamento
						oPtu:cGuiOpe := (oPtu:cAlias)->(BD6_NUMIMP)
						oPtu:cProtoc := (oPtu:cAlias)->(BD6_LOTEDI)

						oPtu:MontaTag( 3,"Questionamento")
						oPtu:Beneficiario()

					endif

					cSql := " SELECT BD7_SEQ500, sum(BD7_VLRGLO) BD7_VLRGLO, sum(BD7_VLRGTX) BD7_VLRGTX"
					cSql += " FROM " + RetSQLName("BD7")
					cSql += " WHERE "
					cSql += " BD7_FILIAL = '" + xFilial("BD7") + "' AND "
					cSql += " BD7_CODOPE = '" + TRBQUEST->BD6_CODOPE + "' AND "
					cSql += " BD7_CODLDP = '" + TRBQUEST->BD6_CODLDP + "' AND "
					cSql += " BD7_CODPEG = '" + TRBQUEST->BD6_CODPEG + "' AND "
					cSql += " BD7_NUMERO = '" + TRBQUEST->BD6_NUMERO + "' AND "
					cSql += " BD7_ORIMOV = '" + TRBQUEST->BD6_ORIMOV + "' AND "
					cSql += " BD7_SEQUEN = '" + TRBQUEST->BD6_SEQUEN + "' AND "
					cSql += " BD7_SEQ500 != ' ' AND "
					cSql += " D_E_L_E_T_ = ' ' "
					cSql += " Group by BD7_SEQ500 "

					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBD7",.F.,.T.)

					// caso possua BD7_SEQ500 preenchido, precisa de uma tag Procedimento pra cada BD7 encontrado
					if ( !TRBBD7->(Eof()) )

						if (allTrim(TRBQUEST->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)) != cChavAux)
							oPtu:MontaTag( 4,"DadosLoteGuia")
							oPtu:MontaTag( 5,"TXT")
							oPtu:MontaTag( 6,"nr_Lote", TRBQUEST->BD6_LOTEDI)
							oPtu:MontaTag( 6,"nr_Nota", TRBQUEST->BD6_NUMIMP)
							oPtu:MontaTag( 5,"TXT",,.t.)
							oPtu:MontaTag( 4,"DadosLoteGuia", , .t.)
						endif

						while !TRBBD7->(Eof())
							oPtu:procedimento('TRBBD7')
							TRBBD7->(DBSkip())
						enddo

					else //senão, é uma tag Procedimento somente pro BD6
						if (allTrim(TRBQUEST->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)) != cChavAux)
							oPtu:MontaTag( 4,"DadosLoteGuia")
							oPtu:MontaTag( 5,"XML")
							oPtu:MontaTag( 6,"nr_LotePrestador", TRBQUEST->BD6_LOTEDI)
							oPtu:MontaTag( 6,"nr_GuiaTissPrestador", retcharesp(TRBQUEST->BD6_NUMIMP))
							oPtu:MontaTag( 6,"nr_GuiaTissOperadora", plsNUMGOI(TRBQUEST->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO), TRBQUEST->BD6_TIPGUI))
							oPtu:MontaTag( 5,"XML",,.t.)
							oPtu:MontaTag( 4,"DadosLoteGuia", , .t.)
						endif

						oPtu:procedimento()

					endif
					TRBBD7->(dbCloseArea())

					cChavAux := allTrim(TRBQUEST->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))
					TRBQUEST->(DBSkip())
					// se o numero da próxima guia é diferente da anterior, fechamos a tag Questionamento
					if (allTrim(TRBQUEST->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)) != cChavAux)
						oPtu:MontaTag( 3,"Questionamento",, .t.)
					endif

				enddo

				TRBQUEST->(dbCloseArea())

				TRBGUIA->(DBSkip())
				oPTU:fimGuia()
			enddo
			TRBGUIA->(dbCloseArea())

			oPtu:QuestNF()//Monta o Questionamento da nota fiscal do Fornecedor

			oPtu:MontaTag( 2,"Quest",, .t.)
			oPtu:MontaTag( 1,"Tipo_Questionamento", , .t.)
			// -- Tipo_Questionamento

			oPtu:calcHash()
			oPtu:MontaTag( 1,"hash", oPtu:cHashMD5 )
			oPtu:MontaTag( 0,"ptuA550",,.T. )
			lGera := oPtu:geraXML(.t.,lAutoma)
			lValid := oPtu:validXML(lAutoma,.t.)

			if lGera .and. lValid
				If Empty(BRJ->BRJ_NIV550)
					BRJ->( RecLock("BRJ", .F.) )
					BRJ->BRJ_NIV550 := '1'
					BRJ->( MsUnlock() )
				EndIf
			endif

		next

		aMsg := aClone(oPtu:aMsg)

		return

//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  pablo alipio
@since   10/2020
/*/
method New() class PTUA550EXP
	::cOpeDes	:= ""
	::cXml		:= ""
	::cCabXml	:= ""
	::cEndXml	:= ""
	::cNameSpace:= "ptu"
	::cStrHash	:= ""
	::cHashMD5  := ""
	::cFolder   := ""
	::cFileName := ""
	::cGuiOpe  	:= ""
	::cProtoc  	:= ""
	::cAvisoXML := ""
	::cSchmFolde:= ""
	::cSchema   := "ptu_A550.xsd"
	::cVersao   := ""
	::lAuto     := .F.
	::aMsg 		:= {}
	::lVersAtual:= .T.
	::cAlias	:= ""
	::nArqFull	:= 0
	::nArqHash	:= 0
	::nArqLog 	:= 0

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} storeMark
armazena o recno de todas as guias selecionadas
@author pablo alipio
@since 10/2020
@param oMBrwBRJ := browse da brj
/*/
//-------------------------------------------------------------------
static function storeMark(oMBrwBRJ)
	local nScan := 0

	if oMBrwBRJ:IsMark(oMBrwBRJ:Mark())
		aadd(aMark,{BRJ->(RECNO()), oMBrwBRJ:At()})
	else
		nScan := ascan(aMark,{ |x| x[1] == BRJ->(RECNO())})
		//deleta o registro desmarcado
		if nScan > 0
			//Deleta os dados da posição
			adel(aMark, nScan)
			//Deleta a posição do array que ficou vazio após o ADEL
			asize(aMark, LEN(aMark) - 1)
		endif
	endIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} uncheckAll
desmarca todos os itens do grid
@author pablo alipio
@since 10/2020
/*/
//-------------------------------------------------------------------
static function uncheckAll()
	local nI := 1
	local nAt := oMBrwBRJ:At()

	for nI := 1 to len(aMark)
		oMBrwBRJ:GoTo(aMark[1][2], .f.)
		oMBrwBRJ:MarkRec()
	next

	oMBrwBRJ:GoTo(nAt, .F.)

	aMark := {}

return

//-------------------------------------------------------------------
/*/{Protheus.doc} iniFile
inicia o arquivo

@author  pablo alipio
@since   10/2020
@param   cTag = versao do ptu
/*/
//-------------------------------------------------------------------
method iniFile(cTag) CLASS PTUA550EXP

	local cNameSpace := ""

	if !Empty(::cNameSpace)
		cNameSpace := ::cNameSpace+":"
	endif

	::cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>' + CRLF

	::cXml += 	'<'+cNameSpace+cTag+' xsi:schemaLocation="http://ptu.unimed.coop.br/schemas/'+::cVersao+" "+ ;
		self:cSchema +'" xmlns:'+self:cNameSpace+'="http://ptu.unimed.coop.br/schemas/'+::cVersao+ ;
		'" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + ">" + CRLF

return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaTag
formata a TAG XML a ser escrita no arquivo

@author  pablo alipio
@since   10/2020
@param nSpc    = chaveamento
@param cTag    = nome tag
@param cVal    = valor campo
@param lFin    = fechamento da tag
@param lRetPto = retira caracteres especiais
/*/
method montaTag(nSpc,cTag,cVal,lFin,lEncode) CLASS PTUA550EXP
	local cRetTag   := ""
	local cNameSpace:= ""
	local lIni		:= .f.
	default nSpc    := 0
	default cTag    := ""
	default lFin    := .F.
	default lEncode := .F.

	if cVal == nil
		cVal    := ""
		lIni := !lFin
	endif

	if !Empty(::cNameSpace)
		cNameSpace := ::cNameSpace+":"
	endif

	if !empty(cVal) .or. lIni
		cRetTag += '<' + cNameSpace+ cTag + '>'
		cVal 	:= alltrim(iif(lEncode,PtuStTran(cVal),cVal))
		cRetTag += cVal
	endif
	if !empty(cVal) .or. lFin
		cRetTag += '</' + cNameSpace + cTag + '>'
	endif

	if !empty(cVal) .and. cTag <> 'hash'
		::cStrHash += cVal
	endif
	if !empty(cRetTag)
		::cXml  += Replicate( "	", nSpc ) + cRetTag + CRLF
	endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} geraXML
Escreve o arquivo XML

@author    pablo alipio
@since     10/2020
/*/
//-------------------------------------------------------------------
method geraXML(lEnd,lAutoma) CLASS PTUA550EXP
	local lRet := .f.

	default lAutoma := .f.

	if ::nArqFull == 0
		::nArqFull := fCreate( cDirTmp + ::cFileName ,FC_NORMAL,,.F.)
		::addMsg(::cFileName, "Arquivo gerado: " + ::cFileName)
	endif

	fWrite( ::nArqFull, ::cXml )
	if lEnd
		fClose( ::nArqFull )
		if !lAutoma
			if !( CpyS2T( cDirTmp + ::cFileName, ::cFolder,,.f. ) )
				::addMsg(::cFileName, "Não foi possível copiar o arquivo para a pasta selecionada.")
				lRet := .f.
			endif

			if ::nArqLog > 0
				fClose( ::nArqLog )
				CpyS2T( cDirTmp + ::cFileName + ".log", ::cFolder,,.f. )
				fErase( cDirTmp + ::cFileName + ".log" )
			endif

			if ::nArqFull > 0
				lRet := .t.
			endif
			fErase( cDirTmp + ::cFileName)
		endif

	endif
	::cXml := ""



return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} addMsg
adiciona uma mensagem de processamento ao objeto

@author    pablo alipio
@since     10/2020
/*/
method addMsg(cArquivo, cMsg) CLASS PTUA550EXP
	local cUnimed := BRJ->BRJ_OPEORI

	default cMsg    := ""

	aadd(::aMsg,{cArquivo, cUnimed, cMsg})

return


//-------------------------------------------------------------------
/*/{Protheus.doc} procedimento
adiciona tag procedimento ao xml

@author    pablo alipio
@since     10/2020
/*/
method procedimento(cAliasAux) CLASS PTUA550EXP
	local aProced   := {}
	local cAlias    := ::cAlias
	local cCodPad   := allTrim((cAlias)->BD6_CODPAD)
	local cCodPro   := allTrim((cAlias)->BD6_CODPRO)
	local cTpProc   := ""
	local cMotQuest := "99"
	local cMotDes   := ""
	local cSql      := ""
	local cPadTmp   := ""
	local nVlrHM    := 0
	local nVlrCO    := 0
	local nVlrFIL   := 0
	local nVlrTxHM  := 0
	local nVlrTxCO  := 0
	local nVlrTxFIL := 0
	local nX        := 0
	local nQuestCount := 1
	local lTxt      := .f.
	local lProcura  := .f.
	local aGlosas   := {}
	local cCmpvlr   := "BD7_VLAPAJ"
	local cCmptx    := "BD7_VLADSE"
	default cAliasAux := ""

	::MontaTag( 4,"Procedimento")

	::MontaTag( 5,"SeqItem")

	if(!empty(cAliasAux))
		::MontaTag( 6,"seq_itemTXT", (cAliasAux)->BD7_SEQ500)
		::MontaTag( 5,"SeqItem",,.t.)
		lTxt := .t.
	else
		cSql := " SELECT BX6_SEQPTU, BX6_IDUNIC FROM " + RetSQLName("BX6")
		cSql += " WHERE "
		cSql += " BX6_FILIAL = '" + xFilial("BX6") + "' AND "
		cSql += " BX6_CODOPE = '" + (cAlias)->BD6_CODOPE + "' AND "
		cSql += " BX6_CODLDP = '" + (cAlias)->BD6_CODLDP + "' AND "
		cSql += " BX6_CODPEG = '" + (cAlias)->BD6_CODPEG + "' AND "
		cSql += " BX6_NUMERO = '" + (cAlias)->BD6_NUMERO + "' AND "
		cSql += " BX6_ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' AND "
		cSql += " BX6_SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' AND "
		cSql += " D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBX6",.F.,.T.)

		if empty(TRBBX6->BX6_SEQPTU)
			::addMsg(::cFileName, "Sequencial vazio " + (cAlias)->BD6_CODPEG + "-" + (cAlias)->BD6_NUMERO + "-" + (cAlias)->BD6_SEQUEN)
		endif
		::MontaTag( 6,"seq_itemXML", TRBBX6->BX6_SEQPTU)
		::MontaTag( 5,"SeqItem",,.t.)

		::MontaTag( 5,"id_itemUnico",TRBBX6->BX6_IDUNIC)

		TRBBX6->(DBCloseArea())
	endif

	if ( cCodPro == cGenPro )
		cCodPad := (cAlias)->BD6_SLVPAD
		cCodPro := (cAlias)->BD6_SLVPRO
	elseif ( cCodPro ==  cGenPac )
		cCodPad := "98"
		cCodPro := (cAlias)->BD6_CD_PAC
	else
		aProced   := dePara(cCodPad, cCodPro, (cAlias)->BD6_DATPRO,(cAlias)->BD6_CODRDA)
		cCodPad 	:= aProced[1]
		cCodPro 	:= aProced[2]
		cTpProc   := aProced[3]
	endif

	if cCodPad == "00"
		if cTpProc $ "3;4;7;8" //Diárias, taxas, gases medicinais e Alugueis
			cPadTmp := "18"
		elseif cTpProc $ "1;5" // Materiais e OPME
			cPadTmp := "19"
		elseif cTpProc == "2" // Medicamentos
			cPadTmp := "20"
		else
			cPadTmp := "22"
		endif

		cCodPro := cPadTmp + cCodPro

	endif

	::MontaTag( 5,"tp_Tabela", cCodPad)
	::MontaTag( 5,"cd_Servico", cCodPro)
	::MontaTag( 5,"tp_Acordo", iif(((cAlias)->BD6_VLRGLO + (cAlias)->BD6_VLRGTX) == 0, "11", "00"))
	::MontaTag( 5,"qt_Reconh", str((cAlias)->BD6_QTDPRO))
	::MontaTag( 5,"qt_Acordada", "0")

	if(!empty(cAliasAux))
		if( (cAliasAux)->BD7_VLRGLO > 0 .or. (cAliasAux)->BD7_VLRGTX > 0)
			lProcura := .t.
		endif
	elseif( (cAlias)->BD6_VLRGLO > 0 .or. (cAlias)->BD6_VLRGTX > 0)
		lProcura := .t.
	endif

	if lProcura
		cCmpvlr   := "BD7_VLRPAG"
		cCmptx    := "BD7_VLTXPG"
	endif

	cSql := " SELECT "
	cSql += " SUM(case WHEN BD7_CODUNM = " + cFilm + "       THEN " + cCmpvlr +"  else 0 END) FIL , "
	cSql += " SUM(case WHEN BD7_CODUNM IN (" + cCusOpe + ")  THEN " + cCmpvlr +"  else 0 END) CO, "
	cSql += " SUM(case WHEN BD7_CODUNM NOT IN (" + cCusOpe + "," + cFilm + ")	THEN " + cCmpvlr +" else 0 END) HM, "
	cSql += " SUM(case WHEN BD7_CODUNM = " + cFilm + "       THEN " + cCmptx +"  else 0 END) FILTX , "
	cSql += " SUM(case WHEN BD7_CODUNM IN (" + cCusOpe + ")  THEN " + cCmptx +" else 0 END) COTX, "
	cSql += " SUM(case WHEN BD7_CODUNM NOT IN (" + cCusOpe + "," + cFilm + ")	THEN "+ cCmptx +" else 0 END) HMTX "
	cSql += " FROM " + retSqlName("BD7")
	cSql += " WHERE BD7_FILIAL = '"+xFilial("BD7")+"' "
	cSql += " AND BD7_CODOPE = '" + (cAlias)->BD6_CODOPE + "' "
	cSql += " AND BD7_CODLDP = '" + (cAlias)->BD6_CODLDP + "' "
	cSql += " AND BD7_CODPEG = '" + (cAlias)->BD6_CODPEG + "' "
	cSql += " AND BD7_NUMERO = '" + (cAlias)->BD6_NUMERO + "' "
	cSql += " AND BD7_ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' "
	cSql += " AND BD7_SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
	if lTxt
		cSql += " AND BD7_SEQ500 = '" + (cAliasAux)->BD7_SEQ500 + "' "
	endif
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBVLR",.F.,.T.)

	if !TRBVLR->(Eof())
		nVlrHM		:=	TRBVLR->HM -  iif(lProcura,TRBVLR->HMTX,0)
		nVlrCO		:=	TRBVLR->CO -  iif(lProcura,TRBVLR->COTX,0)
		nVlrFIL		:=	TRBVLR->FIL - iif(lprocura,TRBVLR->FILTX,0)
		nVlrTxHM	:=	TRBVLR->HMTX
		nVlrTxCO	:=	TRBVLR->COTX
		nVlrTxFIL	:=	TRBVLR->FILTX
	endif
	TRBVLR->(dbclosearea())

	::MontaTag( 5,"Valores")

// caso o item foi integralmente glosado, enviamos vl_Reconh_Serv com valor 0
	if (nVlrHM == 0 .and. nVlrCO == 0 .and. nVlrFIL == 0 .and. ;
			nVlrTxHM == 0 .and. nVlrTxCO == 0 .and. nVlrTxFIL == 0 )
		::MontaTag( 6,"vl_Reconh_Serv", "0")
	endif	

	if(nVlrHM > 0)
		::MontaTag( 6,"vl_Reconh_Serv", str(nVlrHM))
	endif
	if(nVlrCo > 0)
		::MontaTag( 6,"vl_Reconh_CO", str(nVlrCO))
	endif
	if(nVlrFil > 0)
		::MontaTag( 6,"vl_Reconh_Filme", str(nVlrFIL))
	endif
	::MontaTag( 5,"Valores",,.t.)

	if( nVlrTxHM > 0 .or. nVlrTxCO > 0 .or. nVlrTxFIL > 0 )
		::MontaTag( 5,"Taxas")
		if(nVlrTxHM > 0)
			::MontaTag( 6,"vl_Reconh_Adic_Serv", str(nVlrTxHM))
		endif
		if(nVlrTxCO > 0)
			::MontaTag( 6,"vl_Reconh_Adic_CO", str(nVlrTxCO))
		endif
		if(nVlrTxFIL > 0)
			::MontaTag( 6,"vl_Reconh_Adic_Filme", str(nVlrTxFIL))
		endif
		::MontaTag( 5,"Taxas",,.t.)
	endif

	if(!empty(cAliasAux))
		if( (cAliasAux)->BD7_VLRGLO > 0 .or. (cAliasAux)->BD7_VLRGTX > 0)
			lProcura := .t.
		endif
	elseif( (cAlias)->BD6_VLRGLO > 0 .or. (cAlias)->BD6_VLRGTX > 0)
		lProcura := .t.
	endif

	if lProcura
		cSql := " SELECT BDX_CODGLO, R_E_C_N_O_ Recno FROM "+ retsqlname("BDX")
		cSql += " WHERE BDX_FILIAL = '"+xFilial("BDX")+"' "
		cSql += " AND BDX_CODOPE = '" + (cAlias)->BD6_CODOPE + "' "
		cSql += " AND BDX_CODLDP = '" + (cAlias)->BD6_CODLDP + "' "
		cSql += " AND BDX_CODPEG = '" + (cAlias)->BD6_CODPEG + "' "
		cSql += " AND BDX_NUMERO = '" + (cAlias)->BD6_NUMERO + "' "
		cSql += " AND BDX_CODPAD = '" + (cAlias)->BD6_CODPAD + "' "
		cSql += " AND BDX_CODPRO = '" + alltrim((cAlias)->BD6_CODPRO) + "' "
		cSql += " AND BDX_SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
		cSql += " AND (BDX_ACAO != '2'  OR BDX_ACAOTX = '1') "
		cSql += " AND BDX_TIPREG = '1' "
		cSql += " AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBDX",.F.,.T.)
		aGlosas := {}
		while !TRBBDX->(eof())
			BDX->(dbgoto(TRBBDX->Recno))
			aadd(aGlosas,{TRBBDX->BDX_CODGLO,BDX->BDX_OBS})
			TRBBDX->(dbskip())
		enddo
		TRBBDX->(dbclosearea())

		//Pego o bloqueio de pagamento do BD6
		if len(aGlosas) == 0 .and. (cAlias)->BD6_BLOPAG == "1"
			aadd(aGlosas,{(cAlias)->BD6_MOTBPG,""})
		endif

		//Pego o bloqueio de pagamento do BD7
		if len(aGlosas) == 0
			aGlosas := ::getBLOPAG(cAlias)
		endif

		if len(aGlosas) == 0
			lProcura := .f.
		endif

		for nX := 1 to len(aGlosas)
			::MontaTag( 5,"Motivo_Questionamento")

			cMotQuest := ""
			cMotDes   := ""

			cSql := " SELECT BCT_EDI550 FROM " + RetSQLName("BCT")
			cSql += " WHERE "
			cSql += " BCT_FILIAL = '" + xFilial("BCT") + "' AND "
			cSql += " BCT_CODOPE = '" + (cAlias)->BD6_CODOPE + "' AND "
			cSql += " BCT_PROPRI = '" + Substr(aGlosas[nX][1],1,1) + "' AND "
			cSql += " BCT_CODGLO = '" + Substr(aGlosas[nX][1],2,2) + "' AND "
			cSql += " BCT_EDI550 != ' ' AND "
			cSql += " D_E_L_E_T_ = ' ' "
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBCT",.F.,.T.)
			if !TRBBCT->(Eof())
				cMotQuest := TRBBCT->BCT_EDI550 // cd_Motivo_Ques
			else
				cMotQuest := aGlosas[nX][1] // cd_Motivo_Ques
			endif
			TRBBCT->(dbclosearea())

			// ds_Motivo_Ques
			if(!empty(aGlosas[nX][2]))
				cMotDes := SubStr(aGlosas[nX][2],1,500)
			endif

			::MontaTag( 6,"cd_Motivo_Ques", cMotQuest )
			if(!empty(cMotDes))
				::MontaTag( 6,"ds_Motivo_Ques", cMotDes,,.T.)
			endif

			::MontaTag( 5,"Motivo_Questionamento",,.t.)

			if nQuestCount == 5
				exit
			endif
			nQuestCount++
		next
	endif

	if !lProcura
		cMotQuest := "99"
		::MontaTag( 5,"Motivo_Questionamento")
		::MontaTag( 6,"cd_Motivo_Ques", cMotQuest )
		::MontaTag( 5,"Motivo_Questionamento",,.t.)
	endif

	::MontaTag( 4,"Procedimento",,.t.)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dePara

@author    pablo alipio
@since     10/2020
@param    cCodPadO := BD6_CODPAD
@param    cCodProO := BD6_CODPRO
/*/
static function dePara(cCodPadO,cCodProO,cDatPro,cCodRda)
	local aProced	:= {}
	local cSql 		:= ""
	local cCodPad := ""
	local cCodPro := ""
	local cTpProc := ""
	local lAchou  := .f.
	default cDatPro := ""
	default cCodRda := ""

	if lPTUDEPARA
		aRet      := execBlock("PTUDEPARA",.F.,.F.,{cCodPadO,cCodProO,cDatPro,cCodRda})
		lAchou 	  := aRet[1]
		cCodPad 	:= aRet[2]
		cCodPro 	:= aRet[3]
	endif

	cSql := " SELECT BR8_CODEDI, BR8_TPPROC  FROM " + retSqlName("BR8")
	cSql += " WHERE BR8_FILIAL = '" + xFilial("BR8") + "' AND "
	cSql += " BR8_CODPAD = '" + cCodPadO + "' AND "
	cSql += " BR8_CODPSA = '" + cCodProO + "' AND "
	cSql += " D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBR8",.F.,.T.)

	if !lAchou
		aProced	:= PLGETPROC(cCodPadO,cCodProO)
		cCodPad := aProced[2]
		cCodPro := aProced[3]
	endif

	If !TRBBR8->(Eof())
		cTpProc := TRBBR8->BR8_TPPROC
		if (!empty(TRBBR8->BR8_CODEDI)) .and. !lAchou
			cCodPro := ifPls(TRBBR8->BR8_CODEDI,cCodPro)
		endif
	Endif

	TRBBR8->(DbCloseArea())

// se não achou devolvo o original
	cCodPad := ifPls(cCodPad,cCodPadO)
	cCodPro := ifPls(cCodPro,cCodProO)

return {cCodPad,cCodPro,cTpProc}

//-------------------------------------------------------------------
/*/{Protheus.doc} calcHash
calcula o hash MD5 do arquivo

@author    pablo alipio
@since     11/2020
/*/
//-------------------------------------------------------------------
method calcHash() CLASS PTUA550EXP

	if ::nArqHash > 0
		fClose( ::nArqHash )
		::cHashMD5 := md5File(cDirTmp + ::cFileName + ".txt" )
		fErase( cDirTmp + ::cFileName + ".txt" )
	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} geraHash
escreve o arquivo do hash

@author    pablo alipio
@since     11/2020
/*/
//-------------------------------------------------------------------
method geraHash() CLASS PTUA550EXP

	if ::nArqHash == 0
		::nArqHash := fCreate( cDirTmp + ::cFileName + ".txt",FC_NORMAL,,.F.)
	endif

	fWrite( ::nArqHash,::cStrHash )

	::cStrHash := ""

return

//-------------------------------------------------------------------
/*/{Protheus.doc} validXML
valida schema do xml
se detectado alguma falha, salva um log na pasta escolhida no começo da rotina

@author    pablo alipio
@since     11/2020
/*/
method validXML(lAutoma,lValid) class PTUA550EXP
	
	local cError	:= ""
	local cWarning	:= ""
	local lRet		:= .F.
	local cPath 	:= iif(::lVersAtual == .T., "\plsptu\schemas\V2_0\","\plsptu\schemas\V1_1\")

	default lAutoma := .f.
	default lValid  := .f.

//--< valida um arquivo XML com o XSD >--
	if xmlSVldSch(::cCabXml+::cXML+::cEndXml,PLSMUDSIS(cPath)+::cSchema,@cError,@cWarning)
		lRet := .t.
	endif

	if( !lRet ) .AND. !lValid
		::logErro( cError, lAutoma )
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} beneficiario

@author  pablo alipio
@since   11/2020
/*/
method beneficiario() class PTUA550EXP
	local cAlias := ::cAlias
	::MontaTag( 4,"identificacaoBenef")
	::MontaTag( 5,"cd_Unimed", (cAlias)->BD6_CODOPE)
	::MontaTag( 5,"id_Benef", (cAlias)->(BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO))
	::MontaTag( 5,"nm_benef", substr((cAlias)->BD6_NOMUSR, 1, 25))
	::MontaTag( 4,"identificacaoBenef",,.t.)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} logErro

@author    pablo alipio
@since     11/2020
@param     cError = erro a ser incluido no arquivo de log
/*/
method logErro(cError, lAutoma) class PTUA550EXP
	local cMsg 	:= ""
	default lAutoma := .f.

	if ::nArqLog == 0
		::nArqLog := fCreate( cDirTmp + ::cFileName + ".log",FC_NORMAL,,.F.)
		::addMsg(::cFileName, "Falha na estrutura. Verifique o arquivo: " + ::cFileName + ".log")
	endif

	cMsg 	:= "************ Divergencia Validação XML  ************" + CRLF
	cMsg 	+= "Protocolo: "	+ self:cProtoc + CRLF
	cMsg 	+= "Guia: " 		+   self:cGuiOpe + CRLF
	cMsg += strtran(cError, "{http://ptu.unimed.coop.br/schemas/"+self:cVersao+"}","")
	cMsg +=  "****************************************************" + CRLF

	fWrite( ::nArqLog, cMsg )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PtuStTran
Remover Caracter especial e aplicar o encode

@author  Thiago
@since   18/12/2020
@version P12
/*/
Static Function PtuStTran(cConteudo)
	default cConteudo := " "

	cConteudo :=  PlRetponto(cConteudo)

	cConteudo := encodeUtf8(cConteudo,'ISO-8859-1')

return(cConteudo)


//-------------------------------------------------------------------
/*/{Protheus.doc} getBLOPAG
Pega o motivo de bloqueio do BD7
@author  Lucas Nonato
@since   04/05/2021
@version P12
/*/
method getBLOPAG(cAlias) CLASS PTUA550EXP
	local aRet := {}
	cSql := " SELECT BD7_MOTBLO "
	cSql += " FROM " + retSqlName("BD7")
	cSql += " WHERE BD7_FILIAL = '"+xFilial("BD7")+"' "
	cSql += " AND BD7_CODOPE = '" + (cAlias)->BD6_CODOPE + "' "
	cSql += " AND BD7_CODLDP = '" + (cAlias)->BD6_CODLDP + "' "
	cSql += " AND BD7_CODPEG = '" + (cAlias)->BD6_CODPEG + "' "
	cSql += " AND BD7_NUMERO = '" + (cAlias)->BD6_NUMERO + "' "
	cSql += " AND BD7_ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' "
	cSql += " AND BD7_SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
	cSql += " AND BD7_BLOPAG = '1' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY BD7_MOTBLO "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBLO",.F.,.T.)

	while !TRBBLO->(eof())
		if !empty(TRBBLO->BD7_MOTBLO)
			aadd(aRet,{TRBBLO->BD7_MOTBLO,""})
		endif
		TRBBLO->(dbskip())
	enddo

	TRBBLO->(dbclosearea())

return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} 
Quebro o cabeçalho e o final do XML para realizar o valid do schema a cada guia para facilitar analise do usuario final.

@author  Lucas Nonato
@version P12
@since   23/06/2020
/*/
method iniGuia() class PTUA550EXP
	::cCabXml := ::cXml

	::geraXML()

	::MontaTag( 2,"Quest",, .t.)
	::MontaTag( 1,"Tipo_Questionamento", , .t.)
	::MontaTag( 1,"hash", 'XXXX',.T. )
	::MontaTag( 0,"ptuA550",,.T. )
	::cEndXml := ::cXml

	::cXml := ""

return


//-------------------------------------------------------------------
/*/{Protheus.doc} fimGuia
Antes de gravar a guia no XML faço a validação

@author  Lucas Nonato
@version P12
@since   23/06/2020
/*/
method fimGuia() class PTUA550EXP

	::validXML()
	::geraXML()
	::geraHash()

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlDetIt550
Função para manter o filtro da tela. Após passar pelo  PLSED500VS, retornava todos no browse
@version   V12
@since     06/2021
/*/
function PlDetIt550()
	PlRtGdPTUXML(oMBrwBRJ, cGridFilter)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} 
@author   Daniel Silva 
@version  V12
@since    01/2022
/*/
method SetVersao(nVersao) class PTUA550EXP

	lNUMGOI := BD5->(FieldPos("BD5_NUMGOI")) > 0 .AND. BE4->(FieldPos("BE4_NUMGOI")) > 0

	if nVersao==1 //1-Atual
		::lVersAtual := .T.
	else
		::lVersAtual := .F.//2-antiga
	endif

return

//Função para retornar o número da guia TISS da operadora que enviou o A500
static function plsNUMGOI(cChave, cTipo)
Local cRet := ""
Local lResInt := ctipo == "05"

if lNUMGOI .AND. aNUMGOI[1] <> cChave
	aNUMGOI := {"",""}
	iif(lResInt, BE4->(dbsetOrder(1)), BD5->(DbSetOrder(1)))
	if iif(lResInt, BE4->(MsSeek(xFilial("BE4") + cChave)), BD5->(MsSeek(xfilial("BD5") + cChave)))
		aNUMGOI[1] := cChave
		aNUMGOI[2] := iif(lResInt, BE4->BE4_NUMGOI, BD5->BD5_NUMGOI)
	endif
endif

cRet := aNUMGOI[2]

RETURN cRet

//Retira os caracteres proibidos pelo manual do ptu
Static function retcharesp(cString)
Local cRet := cString

cRet := StrTran(cRet, "*", " ")
cRet := StrTran(cRet, ":", " ")
cRet := StrTran(cRet, "?", " ")
cRet := StrTran(cRet, "/", " ")
cRet := StrTran(cRet, "\", " ")

return cRet

/*/{Protheus.doc} QuestNF
	(Monta o questionamento da nota fiscal do Fornecedor)
	@author Thiago Rodrigues
	@since 25/07/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method QuestNF() class PTUA550EXP
local cSql     := ""
local cChavAux := ""

cSql := " SELECT BD6_CODPEG, BD6_NUMERO, BD6_CODLDP, BD6_CODOPE FROM " + RetSQLName("BD6")
cSql += " WHERE BD6_FILIAL = '" + xFilial("BD6")  + "' AND "
cSql += " BD6_SEQIMP = '" + BRJ->BRJ_CODIGO + "' AND "
cSql += " BD6_SITUAC != '2' AND "
cSql += " (BD6_VLRGLO > 0 OR BD6_VLRGTX > 0) AND "
cSql += " BD6_NF <> ' ' AND "
cSql += " D_E_L_E_T_ = ' ' "
cSql += " GROUP BY BD6_CODPEG, BD6_NUMERO, BD6_CODLDP, BD6_CODOPE "
cSql += " ORDER BY BD6_CODPEG, BD6_NUMERO, BD6_CODLDP, BD6_CODOPE "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBGUIANF",.F.,.T.)

// esse while é pra cada guia encontrada
while !TRBGUIANF->(Eof())
	
	cSql := " SELECT BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_QTDPRO, BD6_ORIMOV, "
	cSql += " BD6_DIGITO, BD6_NOMUSR, BD6_CODPAD, BD6_CODPRO, BD6_VLRGLO, BD6_VLRGTX, BD6_SEQUEN, BCI_LOTEDI, BD6_NUMIMP, BD6_LOTEDI, "
	cSql += " BD6_SLVPAD, BD6_SLVPRO, BD6_CD_PAC, BD6_DATPRO, BD6_BLOPAG, BD6_MOTBPG,BD6_CODRDA, BD6_TIPGUI ,BD6_NF, BD5_GUIPRI, BD6_VLRPAG,"
	CSQL += " BD6_VLRGLO, BD6_VLRGTX, BD6_QTDPRO, BD6_VLTXPG"
	cSql += " FROM " + RetSQLName("BD6") + " BD6 "
	
	cSql += " LEFT JOIN " + RetSQLName("BCI") + " BCI ON "
	cSql += " BCI_FILIAL = '" + xFilial("BCI") + "' AND "
	cSql += " BCI_CODOPE = BD6_CODOPE AND "
	cSql += " BCI_CODLDP = BD6_CODLDP AND "
	cSql += " BCI_CODPEG = BD6_CODPEG AND "
	cSql += " BCI.D_E_L_E_T_ = ' ' "
	
	cSql += "LEFT JOIN " + RetSqlName("BD5") + " BD5  " 
	cSql += "ON  BD5.BD5_FILIAL = BD6.BD6_FILIAL " 
	cSql += "AND BD5.BD5_CODOPE = BD6.BD6_CODOPE  " 
	cSql += "AND BD5.BD5_CODLDP = BD6.BD6_CODLDP  " 
	cSql += "AND BD5.BD5_CODPEG = BD6.BD6_CODPEG  " 
	cSql += "AND BD5.BD5_NUMERO = BD6.BD6_NUMERO  " 
	cSql += "AND BD5.D_E_L_E_T_ = ' ' "

	cSql += " WHERE BD6_FILIAL = '" + xFilial("BD6")  + "' AND "
	cSql += " BD6_CODOPE = '" + TRBGUIANF->BD6_CODOPE + "' AND "
	cSql += " BD6_CODLDP = '" + TRBGUIANF->BD6_CODLDP + "' AND "
	cSql += " BD6_CODPEG = '" + TRBGUIANF->BD6_CODPEG + "' AND "
	cSql += " BD6_NUMERO = '" + TRBGUIANF->BD6_NUMERO + "' AND "
	cSql += " BD6.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBQUESTNF",.F.,.T.)

	::cAlias := 'TRBQUESTNF'
	while !TRBQUESTNF->(eof())

		// abre uma tag Questionamento Questionamento NF Fornecedor
		if (allTrim(TRBQUESTNF->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)) != cChavAux)
			::MontaTag( 3,"Questionamento_NFiscalFornec")

			::Beneficiario()

			::MontaTag( 4,"nr_NotaFiscalFornecedor",TRBQUESTNF->BD6_NF)
			::MontaTag( 4,"nr_GuiaTissPrincipal",TRBQUESTNF->BD5_GUIPRI)
		endif

		//Procedimentos 
		::procNFforn()

		cChavAux := allTrim(TRBQUESTNF->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))
		TRBQUESTNF->(dbSkip())

		if (allTrim(TRBQUESTNF->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)) != cChavAux)
			::MontaTag( 3,"Questionamento_NFiscalFornec", , .t.)
		endIf	
		
	end	
	TRBQUESTNF->(dbCloseArea())

TRBGUIANF->(dbSkip())
::fimGuia()
end

TRBGUIANF->(dbCloseArea())

Return 

/*/{Protheus.doc} procNFforn
	(monta o bloco de procedimenos da nota fiscal do fornecedor)
	@author Thiago Rodrigues
	@since 25/07/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method procNFforn() class PTUA550EXP
local cAlias      := ::cAlias
local cCodPad     := allTrim((cAlias)->BD6_CODPAD)
local cCodPro     := allTrim((cAlias)->BD6_CODPRO)
local cMotQuest   := "99"
local cMotDes     := ""
LOCAL aGlosas     :={}
local nX          := 1
local nQuestCount := 1
local lProcura    :=.f.
local cPadTmp     :=""
local cTpProc     :=""
local cCmpvlr     := "BD7_VLAPAJ" //Valor apresentado no A500
local cCmptx      := "BD7_VLADSE" //Valor de taxa apresentado no A500
local nVlrPAG     := 0
local nTxPAG      := 0

//Monta o bloco de procedimentos
cSql := " SELECT BX6_SEQPTU, BX6_IDUNIC FROM " + RetSQLName("BX6")
cSql += " WHERE "
cSql += " BX6_FILIAL = '" + xFilial("BX6") + "' AND "
cSql += " BX6_CODOPE = '" + (cAlias)->BD6_CODOPE + "' AND "
cSql += " BX6_CODLDP = '" + (cAlias)->BD6_CODLDP + "' AND "
cSql += " BX6_CODPEG = '" + (cAlias)->BD6_CODPEG + "' AND "
cSql += " BX6_NUMERO = '" + (cAlias)->BD6_NUMERO + "' AND "
cSql += " BX6_ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' AND "
cSql += " BX6_SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' AND "
cSql += " D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBX6",.F.,.T.)

if empty(TRBBX6->BX6_SEQPTU)
	::addMsg(::cFileName, "Sequencial vazio " + (cAlias)->BD6_CODPEG + "-" + (cAlias)->BD6_NUMERO + "-" + (cAlias)->BD6_SEQUEN)
endif

::MontaTag( 4,"Procedimento") 
::MontaTag( 5,"seq_item",TRBBX6->BX6_SEQPTU)
::MontaTag( 5,"id_itemUnico",TRBBX6->BX6_IDUNIC)

aProced := dePara(cCodPad,cCodPro,(cAlias)->BD6_DATPRO,(cAlias)->BD6_CODRDA)
cCodPad := aProced[1]
cCodPro := aProced[2]
cTpProc := aProced[3]
	
if cCodPad == "00"
	if cTpProc $ "3;4;7;8" //Diárias, taxas, gases medicinais e Alugueis
		cPadTmp := "18"
	elseif cTpProc $ "1;5" // Materiais e OPME
		cPadTmp := "19"
	elseif cTpProc == "2" // Medicamentos
		cPadTmp := "20"
	else
		cPadTmp := "22"
	endif
	cCodPro := cPadTmp + cCodPro
endif	

if( (cAlias)->BD6_VLRGLO > 0 .or. (cAlias)->BD6_VLRGTX > 0)
	lProcura := .t.
endif

if lProcura
	cCmpvlr   := "BD7_VLRPAG"
	cCmptx    := "BD7_VLTXPG"
endif

cSql := " SELECT "
cSql += " SUM( " + cCmpvlr +" )  VlrPag, "
cSql += " SUM( " + cCmptx + " )  VlTxPag "
cSql += " FROM " + retSqlName("BD7")
cSql += " WHERE BD7_FILIAL = '"+xFilial("BD7")+"' "
cSql += " AND BD7_CODOPE = '" + (cAlias)->BD6_CODOPE + "' "
cSql += " AND BD7_CODLDP = '" + (cAlias)->BD6_CODLDP + "' "
cSql += " AND BD7_CODPEG = '" + (cAlias)->BD6_CODPEG + "' "
cSql += " AND BD7_NUMERO = '" + (cAlias)->BD6_NUMERO + "' "
cSql += " AND BD7_ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' "
cSql += " AND BD7_SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"VlrBD7",.F.,.T.)

if !VlrBD7->(eof())
	nVlrPAG := VlrBD7->VlrPag - iif(lProcura,VlTxPag,0)
	nTxPAG  := VlrBD7->VlTxPag
endif
VlrBD7->(dbCloseArea())

::MontaTag( 5,"tp_Tabela", cCodPad)
::MontaTag( 5,"cd_Servico",cCodPro)

::MontaTag( 5,"Valores")
::MontaTag( 6,"vl_Reconh_Serv",iif(nVlrPAG== 0,"0",str(nVlrPAG))) //Se o item foi totalmente glosado devemos enviar 0
::MontaTag( 5,"Valores",,.t.)

if nTxPAG > 0
	::MontaTag( 5,"Taxas") 
	::MontaTag( 6,"vl_Reconh_Adic_Serv",str(nTxPAG)) 
	::MontaTag( 5,"Taxas",,.t.)
endif

::MontaTag( 5,"tp_Acordo", iif(((cAlias)->BD6_VLRGLO + (cAlias)->BD6_VLRGTX) == 0, "11", "00"))
::MontaTag( 5,"qt_Reconh",cValToChar((cAlias)->BD6_QTDPRO))
//::MontaTag( 5,"qt_Acordada", "0") Estava ocorrendo critica na UB  "O campo só deve ser enviado quando Tp_arquivo <> 1" e hoje só enviamos tp_arquivo =1

if lProcura
	cSql := " SELECT BDX_CODGLO, R_E_C_N_O_ Recno FROM "+ retsqlname("BDX")
	cSql += " WHERE BDX_FILIAL = '"+xFilial("BDX")+"' "
	cSql += " AND BDX_CODOPE = '" + (cAlias)->BD6_CODOPE + "' "
	cSql += " AND BDX_CODLDP = '" + (cAlias)->BD6_CODLDP + "' "
	cSql += " AND BDX_CODPEG = '" + (cAlias)->BD6_CODPEG + "' "
	cSql += " AND BDX_NUMERO = '" + (cAlias)->BD6_NUMERO + "' "
	cSql += " AND BDX_CODPAD = '" + (cAlias)->BD6_CODPAD + "' "
	cSql += " AND BDX_CODPRO = '" + alltrim((cAlias)->BD6_CODPRO) + "' "
	cSql += " AND BDX_SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
	cSql += " AND (BDX_ACAO != '2'  OR BDX_ACAOTX = '1') "
	cSql += " AND BDX_TIPREG = '1' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBDX",.F.,.T.)
	aGlosas := {}
	while !TRBBDX->(eof())
		BDX->(dbgoto(TRBBDX->Recno))
		aadd(aGlosas,{TRBBDX->BDX_CODGLO,BDX->BDX_OBS})
		TRBBDX->(dbskip())
	enddo
	TRBBDX->(dbclosearea())
	
	if len(aGlosas) == 0
		lProcura := .f.
	endif	

	for nX := 1 to len(aGlosas)
		::MontaTag( 5,"Motivo_Questionamento")

		cMotQuest := ""
		cMotDes   := ""

		cSql := " SELECT BCT_EDI550 FROM " + RetSQLName("BCT")
		cSql += " WHERE "
		cSql += " BCT_FILIAL = '" + xFilial("BCT") + "' AND "
		cSql += " BCT_CODOPE = '" + (cAlias)->BD6_CODOPE + "' AND "
		cSql += " BCT_PROPRI = '" + Substr(aGlosas[nX][1],1,1) + "' AND "
		cSql += " BCT_CODGLO = '" + Substr(aGlosas[nX][1],2,2) + "' AND "
		cSql += " BCT_EDI550 != ' ' AND "
		cSql += " D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBCT",.F.,.T.)
		if !TRBBCT->(Eof())
			cMotQuest := TRBBCT->BCT_EDI550 // cd_Motivo_Ques
		else
			cMotQuest := aGlosas[nX][1] // cd_Motivo_Ques
		endif
		TRBBCT->(dbclosearea())

		// ds_Motivo_Ques
		if(!empty(aGlosas[nX][2]))
			cMotDes := SubStr(aGlosas[nX][2],1,500)
		endif

		::MontaTag( 6,"cd_Motivo_Ques", cMotQuest )
		if(!empty(cMotDes))
			::MontaTag( 6,"ds_Motivo_Ques", cMotDes,,.T.)
		endif

		::MontaTag( 5,"Motivo_Questionamento",,.t.)

		if nQuestCount == 5
			exit
		endif
		nQuestCount++
	next
endif

//se o item não foi contestado é obrigatorio enviar com motivo 99
if !lProcura
	cMotQuest := "99"
	::MontaTag( 5,"Motivo_Questionamento")
	::MontaTag( 6,"cd_Motivo_Ques", cMotQuest )
	::MontaTag( 5,"Motivo_Questionamento",,.t.)
endif

::MontaTag( 4,"Procedimento",,.t.)

TRBBX6->(dbCloseArea())
Return 
