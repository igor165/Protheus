#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"

#define CRLF chr( 13 ) + chr( 10 )
#define GUIA_CONSULTA 	'01'
#define GUIA_SADT		'02'
#define GUIA_INTERNACAO	'05'
#define GUIA_HONORARIO 	'06'

static cCodInt := ''
static cDirTmp := PLSMUDSIS( "\plsptu\" )
static lStAuto := .F.
static cFiltro := ""
static lVersAtual := .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA560X
Exportação do PTU A560 xml

@author  Lucas Nonato.
@version P12
@since   11/09/2019
/*/
function PLSUA560X()
	local cCampos 	:= ""
	private oMBrw

	BA0->(dbsetorder(1))

	cCampos += iif(BA0->(fieldPos("BA0_TIPLOG")) <= 0, "BA0_TIPLOG,", "" )

	if !empty(cCampos)
		cCampos := substr(cCampos,1,len(cCampos)-1)
		aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): " + cCampos ,{ "Ok" }, 2 )
		return
	endIf


	cFilter := PTU560FIL(.f.)
	setKey(VK_F2 ,{|| cFilter := PTU560FIL(.t.) })

	oMBrw:= FWMarkBrowse():New()
	oMBrw:SetAlias("BRJ")
	oMBrw:SetDescription("Exportação PTU A560" )
	oMBrw:SetMenuDef("PLSUA560X")

	oMBrw:addLegend("BRJ_ARQPAR == '1' .AND. empty(BRJ_NUMTIT) ","ORANGE",	"Parcial 1 não gerado" )
	oMBrw:addLegend("BRJ_ARQPAR == '2' .AND. empty(BRJ_FP2TIT) ","YELLOW",	"Parcial 2 não gerado" )
	oMBrw:addLegend("(BRJ_ARQPAR == '0' .OR. empty(BRJ_ARQPAR)) .AND. empty(BRJ_CFTTIT) ","RED",	  	"Fechamento não gerado" )
	oMBrw:addLegend("BRJ_ARQPAR == '1' .AND. BRJ_NUMTIT <> ' ' ","BLUE",		"Parcial 1 gerado" )
	oMBrw:addLegend("BRJ_ARQPAR == '2' .AND. BRJ_FP2TIT <> ' ' ","WHITE",		"Parcial 2 gerado" )
	oMBrw:addLegend("(BRJ_ARQPAR == '0' .OR. empty(BRJ_ARQPAR)) .AND. BRJ_CFTTIT <> ' ' ","GREEN",		"Fechamento gerado")

	oMBrw:SetFieldMark( 'BRJ_OK' )
	oMBrw:SetAllMark({ ||  A270Inverte(@oMBrw,"BRJ") })
	oMBrw:SetFilterDefault(cFilter)
	oMBrw:SetWalkThru(.F.)
	oMBrw:SetAmbiente(.F.)
	oMBrw:ForceQuitButton()
	oMBrw:Activate()
return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Exportar XML'		Action 'PTU560EXP(.f.)'		OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Cancelar Titulo'	Action 'processa({||P560CANTIT(.f.)},"Exclusao","Processando...",.T.)'	OPERATION MODEL_OPERATION_VIEW ACCESS 0
	Add Option aRotina Title 'Visualizar'  		Action 'VIEWDEF.PLSP500X' 	Operation MODEL_OPERATION_VIEW Access 0
	ADD OPTION aRotina Title "<F2> - Filtrar" 	Action 'PTU560FIL(.t.)'		OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Desmarcar Tudo'	Action 'PTU560DMA()'		OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Dados Adicionais'	Action 'PlDetIt560()'		OPERATION MODEL_OPERATION_VIEW ACCESS 0

return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU560FIL
fitro da tela inicial

@author    Lucas Nonato
@version   V12
@since     25/11/2020
/*/
function PTU560FIL(lF2)
	local cStatus	:= space(1)
	local aPergs  := {}
	local aFilter := {}

	default lF2 := .f.

	cFiltro := ""
	cCodInt := plsintpad()

	aadd( aPergs,{ 2, "Status:"		 	, 	cStatus		,{ "0=Todos","1=Exportado","2=Não Exportado"},100,/*'.T.'*/,.f. } )
	aAdd( aPergs,{ 1, "A partir de:"	, 	dDataBase	, "", "", ""		, "", 50, .f.})


	cFiltro += "@BRJ_FILIAL = '"+ BRJ->(xFilial("BRJ"))+ "' AND BRJ_REGPRI = '1' AND BRJ_NIV550 <> ' ' AND BRJ_NIV550 <> '1' AND D_E_L_E_T_ = ' ' "

// tela para selecionar os filtros
	if (paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSUA560X',/*lCanSave*/.T.,/*lUserSave*/.T. ) )

		if (!empty(aFilter[1]) .and. aFilter[1] != "0")
			if aFilter[1] == "2"
				cFiltro += " AND ((BRJ_ARQPAR = '1' AND BRJ_NUMTIT = ' ') OR  "
				cFiltro += " (BRJ_ARQPAR = '2' AND BRJ_FP2TIT = ' ') OR "
				cFiltro += " ((BRJ_ARQPAR = '0' OR BRJ_ARQPAR = ' ' ) AND BRJ_CFTTIT = ' ' ))"
			else
				cFiltro += " AND ((BRJ_ARQPAR = '1' AND BRJ_NUMTIT <> ' ') OR  "
				cFiltro += " (BRJ_ARQPAR = '2' AND BRJ_FP2TIT <> ' ') OR "
				cFiltro += " ((BRJ_ARQPAR = '0' OR BRJ_ARQPAR = ' ' ) AND BRJ_CFTTIT <> ' ' ))"
			endif
		endif

		if (!empty(aFilter[2]))
			cFiltro += " AND BRJ_DATA >= '" + dtos(aFilter[2]) + "' "
		endif
	endif

	if (lF2)
		If Valtype(oMBrw) == "O"
			oMBrw:SetFilterDefault(cFiltro)
			oMBrw:Refresh(.T.)
		EndIf
	endif

return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU560EXP

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU560EXP(lAuto)
	private oProcess 	:= nil
	default lAuto 		:= .f.

	lStAuto := lAuto

	if lAuto
		cCodInt := plsintpad()
		oProcess := P270fProc():New()
		PTU560BASE(lAuto)
	else
		oProcess := msNewProcess():New( { || PTU560BASE() } , "Processando" , "Aguarde..." , .F. )
		oProcess:Activate()
	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU560BASE

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU560BASE(lAuto)
	local cSql 			as char
	local cPrefix		:= ""
	local cNumTit		:= ""
	local cParcel		:= ""
	local cTipTit		:= ""
	local cTpArq		:= ""
	local cAliasBRJ		:= getNextAlias()
	local aParam        := {}
	local aMsg     		:= {}
	local nQtd     		:= 0
	local nRecnoEV 		:= 0
	local nRecnoTX 		:= 0
	local lErro 		:= .f.

	default lAuto 		:= .f.

	if !lAuto
		if !PLSU560PER(aParam)
			return
		endif
	else
		aadd(aParam,1)
		aadd(aParam,cDirTmp  )//Futuramente trocar pelo esquema de caixa de entrada e caixa de saida na pasta PLSPTU.
	endif

	cSql := " SELECT COUNT(*) QTD FROM " + retSqlName("BRJ") + " BRJ "
	cSql += " WHERE BRJ_OK = '" + oMBrw:cMark + "'"
	cSql += " AND BRJ.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'QTDBRJ',.F.,.T.)
	nQtd := QTDBRJ->QTD
	QTDBRJ->(dbclosearea())

	cSql := " SELECT R_E_C_N_O_ RECNO FROM " + retSqlName("BRJ") + " BRJ "
	cSql += " WHERE BRJ_OK = '" + oMBrw:cMark + "'"
	cSql += " AND BRJ.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasBRJ,.F.,.T.)

	oProcess:SetRegua1( nQtd )
	oProcess:SetRegua2( -1 )
	CINI := time()
	while (cAliasBRJ)->(!eof())
		BRJ->(dbgoto((cAliasBRJ)->RECNO))
		lErro := .f.
		do case
		case BRJ->BRJ_ARQPAR == "1"
			cPrefix := BRJ->BRJ_PREFIX
			cNumTit := BRJ->BRJ_NUMTIT
			cParcel := BRJ->BRJ_PARCEL
			cTipTit := BRJ->BRJ_TIPTIT
			cTpArq	:= "2"
		case BRJ->BRJ_ARQPAR == "2"
			cPrefix := BRJ->BRJ_FP2PRE
			cNumTit := BRJ->BRJ_FP2TIT
			cParcel := BRJ->BRJ_FP2PAR
			cTipTit := BRJ->BRJ_FP2TIP
			cTpArq	:= "2"
		case BRJ->BRJ_ARQPAR == "0" .or. empty(BRJ->BRJ_ARQPAR)
			cPrefix := BRJ->BRJ_CFTPRE
			cNumTit := BRJ->BRJ_CFTTIT
			cParcel := BRJ->BRJ_CFTPAR
			cTipTit := BRJ->BRJ_CFTTIP
			//Se as parciais estiverem vazias é um arquivo integral.
			if empty(BRJ->BRJ_FP2TIT+BRJ->BRJ_NUMTIT)
				cTpArq	:= "1"
			else
				cTpArq	:= "3"
			endif
		endcase

		oProcess:IncRegua1( "Processando... Unimed: [" + BRJ->BRJ_OPEORI + "] Lote: [" + BRJ->BRJ_CODIGO + "]")

		if empty(cNumTit) .or. (!empty(cNumTit) .and. !(SE1->(msSeek(xFilial("SE1")+cPrefix+cNumTit+cParcel+cTipTit))))
			if !geraSE1(@aMsg,@nRecnoEV,@nRecnoTX)
				lErro := .t.
			else
				BRJ->(reclock("BRJ",.f.))
				if BRJ->BRJ_TPCOB == "3"
					do case
					case BRJ->BRJ_ARQPAR == "1"
						BRJ->BRJ_PRENDC := SE1->E1_PREFIXO
						BRJ->BRJ_NUMNDC := SE1->E1_NUM
						BRJ->BRJ_PARNDC := SE1->E1_PARCELA
						BRJ->BRJ_TIPNDC := SE1->E1_TIPO
					case BRJ->BRJ_ARQPAR == "2"
						BRJ->BRJ_NP2PRE := SE1->E1_PREFIXO
						BRJ->BRJ_NP2TIT := SE1->E1_NUM
						BRJ->BRJ_NP2PAR := SE1->E1_PARCELA
						BRJ->BRJ_NP2TIP := SE1->E1_TIPO
					case BRJ->BRJ_ARQPAR == "0" .or. empty(BRJ->BRJ_ARQPAR)
						BRJ->BRJ_CNDPRE := SE1->E1_PREFIXO
						BRJ->BRJ_CNDTIT := SE1->E1_NUM
						BRJ->BRJ_CNDPAR := SE1->E1_PARCELA
						BRJ->BRJ_CNDTIP := SE1->E1_TIPO
					endcase
				else
					do case
					case BRJ->BRJ_ARQPAR == "1"
						BRJ->BRJ_PREFIX := SE1->E1_PREFIXO
						BRJ->BRJ_NUMTIT := SE1->E1_NUM
						BRJ->BRJ_PARCEL := SE1->E1_PARCELA
						BRJ->BRJ_TIPTIT := SE1->E1_TIPO
					case BRJ->BRJ_ARQPAR == "2"
						BRJ->BRJ_FP2PRE := SE1->E1_PREFIXO
						BRJ->BRJ_FP2TIT := SE1->E1_NUM
						BRJ->BRJ_FP2PAR := SE1->E1_PARCELA
						BRJ->BRJ_FP2TIP := SE1->E1_TIPO
					case BRJ->BRJ_ARQPAR == "0" .or. empty(BRJ->BRJ_ARQPAR)
						BRJ->BRJ_CFTPRE := SE1->E1_PREFIXO
						BRJ->BRJ_CFTTIT := SE1->E1_NUM
						BRJ->BRJ_CFTPAR := SE1->E1_PARCELA
						BRJ->BRJ_CFTTIP := SE1->E1_TIPO
					endcase
				endif
				BRJ->(msunlock())
			endif
		endif
		if !lErro
			montaArq(aParam,@aMsg,cTpArq,nRecnoEV,nRecnoTX)
		endif
		(cAliasBRJ)->(dbskip())
	enddo
	cElapsed := ElapTime( CINI, TIME() )
	if !lAuto .and. len(aMsg) > 0
		PLSCRIGEN(aMsg,{ {"Unimed","@C",6},{"Lote","@C",8},{"Mensagem","@C",250} }, "Log de Exportação",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)
	endif

	(cAliasBRJ)->(dbclosearea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaArq
Monta a estrutura do arquivo A560

@author    Lucas Nonato
@version   V12
@since     30/11/2020
/*/
static function montaArq(aParam,aMsg,cTpArq,nRecnoEV,nRecnoTX)
	local oObj      := PLSXmlPTU():New()
	local cFileName := ""
	local cNumFat 	:= "_______"+alltrim(BRJ->BRJ_NUMFAT)
	local nX 		:= 1


	cFileName := "ND"+cTpArq+"_"+substr(cNumFat,len(cNumFat)-6,7)+iif(empty(BRJ->BRJ_ARQPAR) .or. BRJ->BRJ_ARQPAR == "0","","_"+BRJ->BRJ_ARQPAR)+"."+substr(cCodInt,2,3)

	oObj:cLayPTU  := "A560"
	oObj:cSchema  := "ptu_A560.xsd"
	oObj:lCritTag := .f.
	oObj:cSchmFolde	:= PLSMUDSIS(iif(lVersAtual == .T., "\plsptu\schemas\V1_1\","\plsptu\schemas\"))
	
	oObj:cVersao := iif(lVersAtual ==.T., "V1_1","V1_0")
	oObj:IniFile('ptuA560','ISO-8859-1') //Inicia arquivo
	montaCabec(oObj,cTpArq) //Monta cabecalho
	oObj:montaTag(1,'arquivoA560',nil,nil,.T.) //Body
	montaDocumento(oObj,nRecnoEV,nRecnoTX)
	dadosUni(oObj,.t.)
	dadosUni(oObj,.f.)
	oObj:montaTag(1,'arquivoA560',nil,nil,.F.,.T.) //Finaliza Body
	oObj:CalcHash() //Calcula Hash
	oObj:montaTag(1,'hash',oObj:cHashMD5,nil,nil,nil,nil,nil,.F. ) //Gera tag de Hash
	oObj:montaTag(0,'ptuA560',nil,nil,.F.,.T.) //Finaliza arquivo
	oObj:cFolder   := alltrim(aParam[2])
	oObj:cFileName := cFileName
	if !oObj:validXML()
		logErro(aParam,oObj:cErroXML,oObj:cAvisoXML,cFileName)
		oObj:addCritica("Falha na estrutura. Verifique o arquivo: " + cFileName + ".log")
	else
		oObj:addCritica("Arquivo gerado: " + oObj:cFileName )
	endif
	oObj:geraXML(.t.,.t.)

	for nX:=1 to len(oObj:aCriticas)
		aadd(aMsg,{BRJ->BRJ_OPEORI, BRJ->BRJ_CODIGO, oObj:aCriticas[nX][1]	})
	next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaCabec

@author    Lucas Nonato
@version   V12
@since     30/11/2020
/*/
static function montaCabec(oObj,cTpArq)

	oObj:montaTag(1,'cabecalho',nil,nil,.T.)
	oObj:montaTag(2,'nrVerTra_PTU',iif(lVersAtual,"02","01"),.T.)
	oObj:montaTag(1,'unimed',nil,nil,.T.)
	oObj:montaTag(3,'cd_Uni_Destino',BRJ->BRJ_OPEORI,.T.)
	oObj:montaTag(3,'cd_Uni_Origem',cCodInt,.T.)
	oObj:montaTag(2,'unimed',nil,nil,.F.,.T.)
	oObj:montaTag(2,'tp_arquivoNDC',cTpArq,.T.)
	oObj:montaTag(2,'tp_arq_parcial',iif(empty(BRJ->BRJ_ARQPAR) .or. BRJ->BRJ_ARQPAR == "0","",BRJ->BRJ_ARQPAR),.f.)
	oObj:montaTag(1,'cabecalho',nil,nil,.F.,.T.)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} montaDocumento

@author    Lucas Nonato
@version   V12
@since     30/11/2020
/*/
static function montaDocumento(oObj,nRecnoEV,nRecnoTX)
	local cLinhaEV := alltrim(&(getNewPar("MV_PLL5682", "'Cobranca referente a Contestacao da Fatura'")))
	local cLinhaTX := alltrim(&(getNewPar("MV_PLL5681", "'Cobranca referente a Contestacao das Taxas'")))

	if BRJ->BRJ_TPCOB == '3'
		SE1->(dbgoto(nRecnoTX))
	endif

	oObj:montaTag(2,'Documento1',nil,nil,.T.)
	oObj:montaTag(3,'nr_Doc_A500',alltrim(BRJ->BRJ_NUMFAT),.T.)
	oObj:montaTag(3,'Nota_Debito',nil,nil,.T.)
	oObj:montaTag(4,'nr_Nota_Debito',alltrim(SE1->E1_NUM),.T.)
	oObj:montaTag(4,'dt_Emissao_NDC',dtos(SE1->E1_EMISSAO),.T.)
	oObj:montaTag(4,'dt_Ven_NDC',dtos(SE1->E1_VENCTO),.T.)
	oObj:montaTag(4,'vl_NDC',cvaltochar(SE1->E1_VALOR),.T.)
	oObj:montaTag(4,'Linha',nil,nil,.T.)
	oObj:montaTag(5,'nr_Linha',"1",.T.)
	oObj:montaTag(5,'ds_linha',iif(BRJ->BRJ_TPCOB == '3',cLinhaTX,cLinhaEV),.T.)
	oObj:montaTag(4,'Linha',nil,nil,.F.,.T.)
	oObj:montaTag(3,'Nota_Debito',nil,nil,.F.,.T.)
	oObj:montaTag(2,'Documento1',nil,nil,.F.,.T.)

	if BRJ->BRJ_TPCOB == '3'
		SE1->(dbgoto(nRecnoEV))
		oObj:montaTag(2,'Documento2',nil,nil,.T.)
		oObj:montaTag(3,'nr_Doc_A500',alltrim(BRJ->BRJ_NRNDC),.T.)
		oObj:montaTag(3,'Nota_Debito',nil,nil,.T.)
		oObj:montaTag(4,'nr_Nota_Debito',alltrim(SE1->E1_NUM),.T.)
		oObj:montaTag(4,'dt_Emissao_NDC',dtos(SE1->E1_EMISSAO),.T.)
		oObj:montaTag(4,'dt_Ven_NDC',dtos(SE1->E1_VENCTO),.T.)
		oObj:montaTag(4,'vl_NDC',cvaltochar(SE1->E1_VALOR),.T.)
		oObj:montaTag(4,'Linha',nil,nil,.T.)
		oObj:montaTag(5,'nr_Linha',"1",.T.)
		oObj:montaTag(5,'ds_linha',cLinhaEV,.T.)
		oObj:montaTag(4,'Linha',nil,nil,.F.,.T.)
		oObj:montaTag(3,'Nota_Debito',nil,nil,.F.,.T.)
		oObj:montaTag(2,'Documento2',nil,nil,.F.,.T.)
	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dadosDevedora

@author    Lucas Nonato
@version   V12
@since     30/11/2020
/*/
static function dadosUni(oObj,lCredora)
	local cAlias 	:= ""
	local cTagPri	:= ""
	local cTagNm 	:= ""

	if !lCredora
		cAlias 	:= getBA0(BRJ->BRJ_OPEORI)
		cTagPri := "Dados_Devedora"
		cTagNm 	:= "nm_devedora"
	else
		cAlias 	:= getBA0(cCodInt)
		cTagPri := "Dados_Credora"
		cTagNm 	:= "nm_credora"
	endif

	if !(cAlias)->(eof())
		oObj:montaTag(3,cTagPri,nil,nil,.T.)
		oObj:montaTag(4,cTagNm,alltrim((cAlias)->BA0_NOMINT),.T.)
		oObj:montaTag(4,'info_endereco',nil,nil,.T.)
		oObj:montaTag(5,'tp_logradouro',alltrim((cAlias)->(B18_CODEDI)),.T.)
		oObj:montaTag(5,'ds_lograd',alltrim((cAlias)->BA0_END),.T.)
		oObj:montaTag(5,'nr_lograd',alltrim(ifPls((cAlias)->BA0_NUMEND,"S/N")),.T.)
		oObj:montaTag(5,'compl_lograd',alltrim(((cAlias)->BA0_COMPEN)),.f.)
		oObj:montaTag(5,'ds_bairro',alltrim((cAlias)->BA0_BAIRRO),.f.)
		oObj:montaTag(5,'cd_munic',alltrim((cAlias)->BA0_CODMUN),.T.)
		oObj:montaTag(5,'nr_cep',alltrim((cAlias)->BA0_CEP),.T.)
		oObj:montaTag(4,'info_endereco',nil,nil,.F.,.T.)
		oObj:montaTag(4,'cpf_cnpj',nil,nil,.T.)
		oObj:montaTag(5,iif(len(alltrim((cAlias)->BA0_CGC)) == 11,'cd_cpf','cd_cnpj'),alltrim((cAlias)->BA0_CGC),.T.)
		oObj:montaTag(4,'cpf_cnpj',nil,nil,.F.,.T.)
		oObj:montaTag(4,'telefone',nil,nil,.T.)
		oObj:montaTag(5,'tp_fone',"2",.T.)
		oObj:montaTag(5,'nr_ddd',alltrim((cAlias)->BA0_DDD),.T.)
		oObj:montaTag(5,'nr_fone',alltrim((cAlias)->BA0_TELEF1),.T.)
		oObj:montaTag(4,'telefone',nil,nil,.F.,.T.)

		oObj:montaTag(3,cTagPri,nil,nil,.F.,.T.)
	endif

	(cAlias)->(dbclosearea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getBA0 

@author  Lucas Nonato
@version P12
@since   30/11/2020
/*/
static function getBA0(cCodOpe)
	local cSql := ""
	local cAliasBA0		:= getNextAlias()

	cSql := " SELECT BA0_NOMINT, BA0_END, BA0_COMPEN, BA0_NUMEND, BA0_BAIRRO, BA0_CEP, BA0_CODMUN, BA0_EST, BA0_CGC, BA0_DDD, BA0_TELEF1, B18_CODEDI  "
	cSql += " FROM " + retSqlName("BA0") + " BA0 "
	cSql += " LEFT JOIN " + retSqlName("B18") + " B18 "
	cSql += " ON B18_FILIAL = '" + xfilial("B18") + "' "
	cSql += " AND B18_CODIGO = BA0_TIPLOG "
	cSql += " AND B18.D_E_L_E_T_ = ' ' "
	cSql += " WHERE BA0_FILIAL = '" + xfilial("BA0") + "' "
	cSql += " AND BA0_CODIDE = '" + substr(cCodOpe,1,1) + "' "
	cSql += " AND BA0_CODINT = '" + substr(cCodOpe,2,3) + "' "
	cSql += " AND BA0.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasBA0,.F.,.T.)

return cAliasBA0

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSU560PER 
Parambox para resgatar o destino e a versão

@author  Lucas Nonato
@version P12
@since   26/11/2020
/*/
function PLSU560PER(aRet)
	local aPergs    := {}
	local lRet		:= .f.
	aadd( aPergs,{ 2 , "Versão PTU:" , 1 , {"1=Atual","2=Antiga"} , 50 , "" , .F. } )
	aadd( aPergs,{ 6 , "Caminho do Destino:",Space(50),"","","",50,.t.,,,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY  )})
	if( paramBox( aPergs,"Parâmetros - Exportação PTU560 XML",@aRet,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,300,/*oDlgWizard*/,/*cLoad*/"PLSUA5602",/*lCanSave*/.t.,/*lUserSave*/.t. ) )
		lRet := .t.
		lVersAtual := iif(val(cvaltochar(aRet[1]))==1,.T.,.F.) 
	endif
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} logErro

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function logErro(aParam,cError,cAlert,cFileName)
	local nArqLog := 0

	nArqLog := fCreate( alltrim(aParam[2]) + cFileName + ".log",FC_NORMAL,,.F.)

	fWrite( nArqLog, cError + CRLF + cAlert )

	fClose( nArqLog )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} geraSE1

@author    Lucas Nonato
@version   V12
@since     04/12/2020
/*/
static function geraSE1(aMsg,nRecnoEV,nRecnoTX)
	local lOk		:= .t.
	local cSql 		:= ""
	local cMsgTipo	:= ""
	local cAliasBA0	:= getNextAlias()
	local nValorTit	:= 0
	local nVlrTxTit	:= 0

	cSql := " SELECT SA1.R_E_C_N_O_ Recno "
	cSql += " FROM " + retSqlName("BA0") + " BA0 "
	cSql += " INNER JOIN " + retSqlName("SA1") + " SA1 "
	cSql += " ON A1_FILIAL = '" + xfilial("SA1") + "' "
	cSql += " AND A1_COD  = BA0_CODCLI "
	cSql += " AND A1_LOJA = BA0_LOJCLI "
	cSql += " AND SA1.D_E_L_E_T_ = ' ' "
	cSql += " WHERE BA0_FILIAL = '" + xfilial("BA0") + "' "
	cSql += " AND BA0_CODIDE = '" + substr(BRJ->BRJ_OPEORI,1,1) + "' "
	cSql += " AND BA0_CODINT = '" + substr(BRJ->BRJ_OPEORI,2,3) + "' "
	cSql += " AND BA0.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasBA0,.F.,.T.)

	if (cAliasBA0)->(eof())
		(cAliasBA0)->(dbclosearea())
		aadd(aMsg,{BRJ->BRJ_OPEORI, BRJ->BRJ_CODIGO, "Cliente não localizado"	})
		return .f.
	endif

	SA1->(dbgoto((cAliasBA0)->Recno))

	(cAliasBA0)->(dbclosearea())

	cSql := " SELECT SUM(B2A_VALCOB) VLRAPR, SUM(B2A_VALACI) VLRACORDO, SUM(B2A_VLTXAP) VLTXAP, SUM(B2A_VLTXAC) VLTXACORDO"
	cSql += " FROM " + retSqlName("B2A") + " B2A "
	cSql += " WHERE B2A_FILIAL = '" + xfilial("B2A") + "' "
	cSql += " AND B2A_ALIAS = 'BRJ' "
	cSql += " AND B2A_LOTE = '" + BRJ->BRJ_CODIGO + "' "
	cSql += " AND B2A_NIVEL = '" + BRJ->BRJ_ARQPAR + "' "
	cSql += " AND B2A.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPB2A",.F.,.T.)

	if BRJ->BRJ_ARQPAR == "1"
		cMsgTipo := "parcial 1"
	elseif BRJ->BRJ_ARQPAR == "2"
		cMsgTipo := "parcial 2"
	else
		cMsgTipo := "fechamento"
	endif

	if BRJ->BRJ_TPCOB == '3'
		nValorTit := TMPB2A->VLRACORDO
		nVlrTxTit := TMPB2A->VLTXACORDO
	else
		nValorTit := TMPB2A->VLRACORDO + TMPB2A->VLTXACORDO
	endif

	TMPB2A->(dbclosearea())

	if nValorTit+nVlrTxTit <= 0
		getVlrBatch(@nValorTit,@nVlrTxTit)
	endif

	if nValorTit+nVlrTxTit <= 0
		aadd(aMsg,{BRJ->BRJ_OPEORI, BRJ->BRJ_CODIGO, "Lote de " + cMsgTipo + " não possui valores a receber." })
		return .f.
	endif

	if BRJ->BRJ_TPCOB == '3'
		lOK := criaSE1(nVlrTxTit,@aMsg)
		if lOk
			nRecnoTX := SE1->(recno())
			BRJ->(reclock("BRJ",.f.))
			do case
			case BRJ->BRJ_ARQPAR == "1"
				BRJ->BRJ_PREFIX := SE1->E1_PREFIXO
				BRJ->BRJ_NUMTIT := SE1->E1_NUM
				BRJ->BRJ_PARCEL := SE1->E1_PARCELA
				BRJ->BRJ_TIPTIT := SE1->E1_TIPO
			case BRJ->BRJ_ARQPAR == "2"
				BRJ->BRJ_FP2PRE := SE1->E1_PREFIXO
				BRJ->BRJ_FP2TIT := SE1->E1_NUM
				BRJ->BRJ_FP2PAR := SE1->E1_PARCELA
				BRJ->BRJ_FP2TIP := SE1->E1_TIPO
			case BRJ->BRJ_ARQPAR == "0" .or. empty(BRJ->BRJ_ARQPAR)
				BRJ->BRJ_CFTPRE := SE1->E1_PREFIXO
				BRJ->BRJ_CFTTIT := SE1->E1_NUM
				BRJ->BRJ_CFTPAR := SE1->E1_PARCELA
				BRJ->BRJ_CFTTIP := SE1->E1_TIPO
			endcase
			BRJ->(msunlock())
		endif
	endif

	if lOK
		lOK := criaSE1(nValorTit,@aMsg)
		if lOk
			nRecnoEV := SE1->(recno())
		endif
	endif

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} geraSE1

@author    Lucas Nonato
@version   V12
@since     04/12/2020
/*/
static function criaSE1(nValorTit,aMsg)
	local cPrefNDC	:= ""
	local cTipoNDC	:= ""
	local cNumero	:= ""
	local nDiasVcto	:= GetNewPar("MV_PLVCTTC", 10)
	local lOk 		:= .t.
	local aCampos	:= {}

	private lMsErroAuto	:= .f.

	if nValorTit > 0
		cPrefNDC := getNewPar("MV_PLPREE1",'"NDC"')
		cTipoNDC := getNewPar("MV_PLSTPCP","FT")
		cPrefNDC := strtran(cPrefNDC,"'","")
		cPrefNDC := strtran(cPrefNDC,'"',"")
		cNumero  := nxtSX5Nota(cPrefNDC,.T.,"1",nil,"BK","PLS")

		aAdd(aCampos, {"E1_FILIAL" , xfilial("SE1")			, Nil})
		aadd(aCampos, {"E1_PREFIXO", cPrefNDC				, Nil})
		aadd(aCampos, {"E1_NUM"    , cNumero				, Nil})
		aadd(aCampos, {"E1_PARCELA", ' '					, Nil})
		aadd(aCampos, {"E1_TIPO"   , cTipoNDC				, Nil})
		aadd(aCampos, {"E1_NATUREZ", SA1->A1_NATUREZ		, Nil})
		aadd(aCampos, {"E1_CLIENTE", SA1->A1_COD			, Nil})
		aadd(aCampos, {"E1_LOJA"   , SA1->A1_LOJA			, Nil})
		aadd(aCampos, {"E1_NOMCLI" , SA1->A1_NOME			, Nil})
		aadd(aCampos, {"E1_EMISSAO", dDataBase				, Nil})
		aadd(aCampos, {"E1_VENCTO" , dDataBase+nDiasVcto	, Nil})
		aadd(aCampos, {"E1_VENCREA", dataValida(dDataBase+nDiasVcto,.T.), Nil})
		aadd(aCampos, {"E1_VALOR"  , nValorTit				, Nil})
		aadd(aCampos, {"E1_HIST"   , "Processo Ajius "		, Nil})
		aadd(aCampos, {"E1_ORIGEM" , "A560"					, Nil})
		aadd(aCampos, {"E1_CODINT" , cCodInt				, Nil})
		aadd(aCampos, {"E1_BASEIRF", 0				        , Nil})
		aadd(aCampos, {"E1_BASEPIS", 0	     				, Nil})
		aadd(aCampos, {"E1_BASECOF", 0						, Nil})
		aadd(aCampos, {"E1_BASECSL", 0		        		, Nil})
		aadd(aCampos, {"E1_BASEINS", 0	            		, Nil})
		aadd(aCampos, {"E1_BASEISS", 0		        		, Nil})
		aadd(aCampos, {"E1_IRRF"   , 0 		              	, Nil})
		aadd(aCampos, {"E1_MULTNAT", "2"             		, Nil})
		aadd(aCampos, {'E1_DECRESC', 0               		, Nil})
		aadd(aCampos, {'E1_SDDECRE', 0               		, Nil})
		aadd(aCampos, {'E1_ACRESC' , 0               		, Nil})
		aadd(aCampos, {'E1_SDACRES', 0               		, Nil})
		aadd(aCampos, {'E1_INSS'   , 0               		, Nil})
		aadd(aCampos, {'E1_COFINS' , 0               		, Nil})
		aadd(aCampos, {'E1_PIS'	   , 0               		, Nil})
		aadd(aCampos, {'E1_IRRF'   , 0  	             	, Nil})
		aadd(aCampos, {'E1_CSLL'   , 0	                	, Nil})
		aadd(aCampos, {'E1_ISS'    , 0				 		, Nil})
		aadd(aCampos, {'E1_VRETIRF', 0 						, Nil})

		msExecAuto({|x,y| Fina040(x,y)}, aCampos, 3) //Inclusao

		if lMsErroAuto
			lOk := .f.
			SE1->( rollBackSX8() )
			aadd(aMsg,{BRJ->BRJ_OPEORI, BRJ->BRJ_CODIGO, "Erro na criação do titulo."	})
			If !lStAuto
				mostraerro()
			EndIf
		else
			aadd(aMsg,{BRJ->BRJ_OPEORI, BRJ->BRJ_CODIGO, "Titulo " + SE1->(E1_PREFIXO+E1_NUM) + " criado com R$" + cvaltochar(nValorTit) + " a receber." })
		endif
	endif

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} P560CANTIT

@author    Lucas Nonato
@version   V12
@since     04/12/2020
/*/
function P560CANTIT(lAuto)
	local cChvSE1 	:= ""
	local cChv2SE1 	:= ""
	local lOk 		:= .t.
	local lExc 		:= .t.
	local aCampos	:= {}
	private lMsErroAuto := .f.
	default lAuto := .f.

	if BRJ->BRJ_ARQPAR == "1"
		cChvSE1  := alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))
		cChv2SE1 := alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))
		cMsgTipo := "parcial 1"
	elseif BRJ->BRJ_ARQPAR == "2"
		cChvSE1  := alltrim(BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))
		cChv2SE1 := alltrim(BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP))
		cMsgTipo := "parcial 2"
	else
		cChvSE1  := alltrim(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))
		cChv2SE1 := alltrim(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))
		cMsgTipo := "fechamento"
	endif

	if empty(cChvSe1)
		if !lAuto
			MsgInfo("Cancelamento de " + cMsgTipo + " já efetuado ou ainda não foi exportado o A560!","Cancelamento ")
		endif
		return .F.
	endIf

	procRegua(-1)

	If !lAuto
		lExc := MsgYesNo("Confirma o cancelamento do titulo de " + cMsgTipo + "?" + CRLF +  "[" + BRJ->BRJ_CODIGO + "] " + BRJ->BRJ_NOMORI  , "Exclusão")
	endif

	if !lExc
		return
	endif

	SE1->( dbSetOrder(1) )
	If SE1->( msseek(xFilial("SE1")+cChvSE1))
		aCampos  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
			{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
			{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
			{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}

		msExecAuto({|x,y| Fina040(x,y)},aCampos,5) //Exclusao

		if lMsErroAuto
			lOk := .f.
			mostraerro()
		else
			limpaTit(1)
			if !lAuto .and. empty(!empty(cChv2SE1))
				msgInfo("Titulo "+cChvSE1+" cancelado com sucesso.")
			endif
		endif
	else
		lOk := .f.
		if msgYesNo("Titulo " + cChvSE1 + " não localizado, deseja remover o vinculo?")
			limpaTit(1)
		endif
	endif

	if !empty(cChv2SE1) .and. SE1->( msseek(xFilial("SE1")+cChv2SE1))
		aCampos  := {{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
			{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			{"E1_PARCELA"	,SE1->E1_PARCELA		,Nil},;
			{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
			{"E1_NATUREZ"	,SE1->E1_NATUREZ		,Nil}}

		msExecAuto({|x,y| Fina040(x,y)},aCampos,5) //Exclusao

		if lMsErroAuto
			lOk := .f.
			mostraerro()
		else
			limpaTit(1)
			if !lAuto
				if lOk
					msgInfo("Titulos " + cChv2SE1 + " e " + cChvSE1 + " cancelados com sucesso.")
				endif
			endif
		endif
	elseif !empty(cChv2SE1)
		lOk := .f.
		if msgYesNo("Titulo " + cChv2SE1 + " não localizado, deseja remover o vinculo?")
			limpaTit(2)
		endif
	endif

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaTit

@author    Lucas Nonato
@version   V12
@since     04/12/2020
/*/
static function limpaTit(nOpc)

	default nOpc := 0

	BRJ->(reclock("BRJ",.f.))
	do case
	case BRJ->BRJ_ARQPAR == "1"
		if nOpc == 1
			BRJ->BRJ_PREFIX := ""
			BRJ->BRJ_NUMTIT := ""
			BRJ->BRJ_PARCEL := ""
			BRJ->BRJ_TIPTIT := ""
		else
			BRJ->BRJ_PRENDC := ""
			BRJ->BRJ_NUMNDC := ""
			BRJ->BRJ_PARNDC := ""
			BRJ->BRJ_TIPNDC := ""
		endif
	case BRJ->BRJ_ARQPAR == "2"
		if nOpc == 1
			BRJ->BRJ_FP2PRE := ""
			BRJ->BRJ_FP2TIT := ""
			BRJ->BRJ_FP2PAR := ""
			BRJ->BRJ_FP2TIP := ""
		else
			BRJ->BRJ_NP2PRE := ""
			BRJ->BRJ_NP2TIT := ""
			BRJ->BRJ_NP2PAR := ""
			BRJ->BRJ_NP2TIP := ""
		endif
	case BRJ->BRJ_ARQPAR == "0" .or. empty(BRJ->BRJ_ARQPAR)
		if nOpc == 1
			BRJ->BRJ_CFTPRE := ""
			BRJ->BRJ_CFTTIT := ""
			BRJ->BRJ_CFTPAR := ""
			BRJ->BRJ_CFTTIP := ""
		else
			BRJ->BRJ_CNDPRE := ""
			BRJ->BRJ_CNDTIT := ""
			BRJ->BRJ_CNDPAR := ""
			BRJ->BRJ_CNDTIP := ""
		endif
	endcase
	BRJ->(msunlock())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getVlrBatch
Essa função servirá apenas na transição do PTU Batch com o XML, poderá ser removida após o processo ser todo via XML.
@author    Lucas Nonato
@version   V12
@since     04/12/2020
/*/
static function getVlrBatch(nValorTit,nVlrTxTit)
	local cSql := ""

	cSql := "SELECT SUM(BD7_VLRGLO) BD7_VLRGLO, SUM(BD7_VLTXPG) BD7_VLTXPG, SUM(BD7_VLRGTX) BD7_VLRGTX "
	cSql += "FROM " + RetSqlName("BD6") + " BD6," + RetSqlName("BD7") + " BD7 "
	cSql += " WHERE BD7_FILIAL = BD6_FILIAL "
	cSql += " AND BD7_CODOPE = BD6_CODOPE "
	cSql += " AND BD7_CODLDP = BD6_CODLDP "
	cSql += " AND BD7_CODPEG = BD6_CODPEG "
	cSql += " AND BD7_NUMERO = BD6_NUMERO "
	cSql += " AND BD7_ORIMOV = BD6_ORIMOV "
	cSql += " AND BD7_SEQUEN = BD6_SEQUEN "
	cSql += " AND BD7_SEQIMP = BD6_SEQIMP "
	cSql += "AND BD7_BLOPAG <> '1' "
	cSql += "AND BD6_GUIORI <> ' ' "
	cSql += "AND BD6.D_E_L_E_T_ = ' ' AND BD7.D_E_L_E_T_ = ' ' AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_SEQIMP = '" + BRJ->BRJ_CODIGO + "'"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TRBBD7',.F.,.T.)

	if !TRBBD7->(eof())
		if BRJ->BRJ_TPCOB == '3'
			nVlrTxTit := TRBBD7->BD7_VLRGTX
			nValorTit := TRBBD7->BD7_VLRGLO - TRBBD7->BD7_VLRGTX
		else
			nValorTit := TRBBD7->BD7_VLRGLO + TRBBD7->BD7_VLRGTX
		endif
	endif

	TRBBD7->(dbclosearea())

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlDetIt560
Função para manter o filtro da tela. Após passar pelo  PLSED500VS, retornava todos no browse
@version   V12
@since     06/2021
/*/
function PlDetIt560()
	PlRtGdPTUXML(oMBrw, cFiltro)
return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlRtGrdPTUXML
Função para manter o filtro da tela. Após passar pelo  PLSED500VS, retornava todos no browse
@version   V12
@since     06/2021
/*/
function PlRtGdPTUXML(oObjGrd, cFilterX)
	local aArea1 := GetArea()
	PLSED500VS()
	If Valtype(oObjGrd) == "O"
		oObjGrd:SetFilterDefault(cFilterX)
		oObjGrd:Refresh(.T.)
	EndIf
	RestArea(aArea1)
return


