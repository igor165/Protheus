#INCLUDE "JURA112B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//Define referente aos arrays aCmpProces \ aCmpAudPro \ aCmpsCompl \ aCmpAudObj
#DEFINE CAMPO		1		//Campo\Apelido
#DEFINE TITULO		2
#DEFINE TIPO		3
#DEFINE MASCARA		4
#DEFINE QUERYCAMPO	5

//Define referente ao array aColunas
#DEFINE PROCESSO	1	//Campos do processo NSZ
#DEFINE AUDPROCESS	2	//Campos auditados do processo O0F
#DEFINE AUDCOMPLE	3	//Campos auditados complementares O0C
#DEFINE AUDOBJETO	4	//Campos auditados do objeto O0G
#DEFINE AUDPEDIDO	5	//Campos auditados do pedido O0Y

Static cAba		:= STR0008	//"Auditoria"
Static cDescTab	:= ""

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA112B
Compara marcas da Auditoria

@param lXlsx -  define se o formato � xlsx (automa��o)
@author  Rafael Tenorio da Costa
@since 	 12/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA112B(lXlsx)
Local oGrid     := Nil
Local nRet      := -1
Local cPergunta := "JURA112B"

Default lXlsx := .T.

	/*  Pergunte() JURA112B
		MV_PAR01 - 1 Marca
		MV_PAR02 - 2 Marca
		MV_PAR03 - Assunto Jur�dico
	*/
	//--------------------------------------------------------
	//@param cFunName     Nome da rotina de menu de processamento
	//@param cTitle       Titulo da rotina de menu
	//@param cDescription Descri��o completa da rotina
	//@param bProcess     Bloco de c�digo de processamento. O bloco recebe a variavel que informa que a rotina foi cancelada
	//@param cPerg        Nome do grupo de perguntas do dicion�rio de dados
	//--------------------------------------------------------
	If( JurAuto())
		Comparacao(,.F., lXlsx)
	Else
		oGrid := FWGridProcess():New(cPergunta, STR0001, STR0002, {|lEnd| nRet := Comparacao(oGrid, @lEnd, lXlsx)}, cPergunta, /*cGrid*/, /*lSaveLog*/) //"Compara marcas da Auditoria"	//"Est� rotina tem o objetivo de comparar duas marcas da Auditoria para assim exibir a evolu��o dos Processos."

		//Indica a quantidade de barras de processo
		oGrid:SetMeters(2)
		oGrid:Activate()
		oGrid:IsFinished()
		oGrid:DeActivate()
		FwFreeObj(oGrid)

		If nRet > 0
			ApMsgInfo(STR0003) //"Compara��o gerada com sucesso"
		ElseIf nRet == 0
			ApMsgInfo(STR0004) //"N�o existe dados a serem processados com esses par�metros"
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Comparacao
Gera arquivo de compara��o das auditorias

@author  Rafael Tenorio da Costa
@since 	 12/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Comparacao(oGrid, lEnd, lXlsx)
Local nRet      := -1
Local lContinua := .T.
Local oExcel    := Nil
Local lZip      := .T.

	If ! JurAuto()
		oGrid:SetMaxMeter(5, 1, STR0005) //"Validando par�metros"
		
		//Efetua as valida��es antes de gerar a auditoria
		oGrid:SetIncMeter(1, STR0005) //"Validando par�metros"
	EndIf

	lContinua := ValidAudit()

	If lContinua
		cDescTab := I18n(STR0009, {DtoC(MV_PAR01), DtoC(MV_PAR02)})	//"Auditoria - Marca #1 x Marca #2"

		If ! JurAuto()
			oGrid:SetIncMeter(1, STR0007) //"Gerando Auditoria"
		EndIf
		If __FWLibVersion() >= '20201009' .And. GetRpoRelease() >= '12.1.023' .And. PrinterVersion():fromServer() >= '2.1.0' .And. lXlsx
			lZip := .F.
			oExcel := FWMsExcelXlsx():New()
		Else 
			oExcel := FWMsExcelEx():New()
		EndIf

		GeraExcel(oExcel, oGrid, lZip, lXlsx)

		oExcel:DeActivate()
		FwFreeObj(oExcel)
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidAudit
Efetua as valida��es antes de comparar a auditoria

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidAudit()

	Local aArea		:= GetArea()
	Local cMsgErro  := ""
	Local lContinua := .T.

	//Valida marcas
	DbSelectArea("O0E")
	O0E->( DbSetOrder(1) )	//O0E_FILIAL + O0E_MARCA
	If !O0E->( DbSeek(xFilial("O0E") + DtoS(MV_PAR01)) ) .Or. !O0E->( DbSeek(xFilial("O0E") + DtoS(MV_PAR02)) )
		JurMsgErro(STR0006)	//"Marca Inv�lida"
		lContinua := .F.
	EndIf

	//Valida per�odo
	If lContinua
		cMsgErro := J112aVldDt(MV_PAR01, MV_PAR02)

		If !Empty(cMsgErro)
			If ! JurAuto()
				ApMsgAlert(cMsgErro)
			EndIf
			
			lContinua := .F.
		EndIf
	EndIf

	RestArea(aArea)

Return lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraExcel
Gera o arquivo em excel com a compara��o entre as marcas da auditoria

@param oExcel     Objeto FWMsExcelEx 
@param oGrid      Objeto da r�gua de progress�o
@param lZip       Indica se o arquivo ser� zipado ou n�o

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraExcel(oExcel, oGrid, lZip, lXlsx)
Local aArea      := GetArea()
Local aColunas   := {}
Local aLinha     := {}
Local nCont      := 0
Local cFilPro    := ""
Local cCajuri    := ""
Local aColGar    := {}
Local aColDes    := {}
Local cTabSql    := ""
Local aRetorno   := {}
Local nRegistros := 0
Local lGrava     := .F.
Local lAuto      := JurAuto()

	If ! lAuto
		oGrid:SetIncMeter(1, STR0063) //"Selecionando registros"
	EndIf

	//Cria aba e tabela
	oExcel:AddWorkSheet(cAba)
	oExcel:AddTable(cAba, cDescTab)

	//Carrega campos e cria colunas do processo e auditados
	aColunas := CarCampos(@oExcel)

	//Retorna Garantias e Despesas por colunas e cria as colunas no oExcel
	ObjGarDes("NT2", @oExcel, @aColGar)
	ObjGarDes("NT3", @oExcel, @aColDes)

	//Retorna dados principais da auditoria Processos\Objetos auditados
	aRetorno   := DadosAudit(aColunas)
	nRegistros := aRetorno[1]
	cTabSql    := aRetorno[2]

	If ! lAuto
		oGrid:SetIncMeter(1, STR0064) //"Preenche planilha"
		oGrid:SetMaxMeter(nRegistros, 2, STR0081) //"Comparando "
		oGrid:SetIncMeter(2, STR0081)             //"Comparando "
	EndIf

	//Campos complementares gravados
	DbSelectArea("O0C")
	O0C->( DbSetOrder(1) ) //O0C_FILIAL+DTOS(O0C_MARCA)+O0C_ENTAUD+O0C_CODAUD+O0C_CMPFOR

	//------------------------------------
	//Gera linhas
	//------------------------------------
	While !(cTabSql)->( Eof() )
		nCont++
		aLinha  := {}
		lGrava  := .T.
		cFilPro := &(cTabSql + "->NSZ_FILIAL")
		cCajuri := &(cTabSql + "->NSZ_COD")


		//Inclui campos do processo
		IncCmpsPro(@aLinha, aColunas[PROCESSO], cTabSql)

		//Inclui campos auditados do processo
		IncCmpsAud(@aLinha, aColunas[AUDPROCESS], cTabSql)

		//Inclui campos complementares auditados
		IncCmpsCom(@aLinha, aColunas[AUDCOMPLE], cFilPro, cCajuri)

		//Inclui campos auditados do objeto
		IncCmpsAud(@aLinha, aColunas[AUDOBJETO], cTabSql)

		If (FWAliasIndic("O0W") .And. FWAliasIndic("O0Y"))
			//Inclui campos auditados do pedido
			IncCmpsAud(@aLinha, aColunas[AUDPEDIDO], cTabSql, .T., aColunas[AUDCOMPLE])
		EndIf

		//Carrega colunas das garantias
		IncCmpsVal(@aLinha, "NT2", aColGar, cFilPro, cCajuri)

		//Carrega colunas das despesas
		IncCmpsVal(@aLinha, "NT3", aColDes, cFilPro, cCajuri)

		//Gera linha no excel
		If ! lAuto
			oGrid:SetIncMeter(2, STR0081 + cValToChar(nCont) + "\" + cValToChar(nRegistros)) //"Comparando "
		EndIf

		oExcel:AddRow(cAba, cDescTab, aClone(aLinha))

		FwFreeObj(aLinha)
		(cTabSql)->( DbSkip() )
	EndDo
	(cTabSql)->( DbCloseArea() )

	FwFreeObj(aColunas)
	FwFreeObj(aLinha)
	FwFreeObj(aColGar)
	FwFreeObj(aColDes)
	FwFreeObj(aRetorno)

	If ! lAuto
		//Grava arquivo
		oGrid:SetIncMeter(1, STR0065)    //"Grava arquivo"
		oGrid:SetMaxMeter(1, 2, STR0082) //"Salvando e Abrindo arquivo"
	EndIf

	If lGrava
		GrvArquivo(oExcel, lZip, lXlsx)
	Else
		FwFreeObj(aLinha)
		If ! lAuto
			ApMsgInfo(STR0119) //"N�o existem dados auditados a serem comparados. Realize a gera��o das marcas e tente novamente."
		EndIf
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarCampos()
Carrega os campos que seram apresentados no excel.

@Param oExcel - objeto excel
@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarCampos(oExcel)
Local aArea      := GetArea()
Local aRetorno   := {}
Local aCmpProces := {}
Local aCmpAudPro := {}
Local aCmpsCompl := {}
Local aCmpAudObj := {}
Local aCmpAudPed := {}
Local aCampos    := {}
Local cCampo     := ""
Local cCmpQuery  := ""
Local cTitulo    := ""
Local nAlign     := 2   //1-Left, 2-Center, 3-Right
Local nFormat    := 1   //1-General, 2-Number, 3-Monet�rio, 4-DateTime
Local lTotal     := .F. //Indica se a coluna deve ser totalizada - ser� sempre .F. porque a linha do processo pode se repetir, por causa da quantidade de objetos por processo
Local lAuditado  := .F. //Define se deve ser criada 2 colunas para cada campo, uma para cada marca
Local nCont      := 0
Local nTipo      := 0
Local cTipo      := ""
Local aAux       := {}
Local cSituac    := ""
Local cPolo      := ""
Local cPeinVl    := ""
Local cIneCon    := ""
Local lO0FNvCmp  := .F. //Indica se os campos O0F_VINCON e O0F_VATINC existem no dicion�rio

	//STR0015 "Polo Empresa" //STR0059 "Polo Ativo" //STR0060 "Polo Passivo"
	cPolo := "(CASE WHEN RTRIM(LTRIM(UPPER(SA1.A1_NOME))) = RTRIM(LTRIM(UPPER(NSZ_PATIVO))) THEN '" + STR0059 + "' ELSE '" + STR0060 + "' END)"

	//Campos do processo
	//               {Campo        , Titulo  , Tipo, Mascara                        , Query, Deseja apresentar o campo nas subquerys?}
	Aadd(aCmpProces, {"NSZ_FILIAL" , STR0010 , "C" , ""                             , ""   , .T. })
	Aadd(aCmpProces, {"NSZ_COD"    , STR0011 , "C" , ""                             , ""   , .T. })                    //"Assunto Jur�dico"
	Aadd(aCmpProces, {"NYB_DESC"   , STR0012 , "C" , ""                             , ""   , .T. })                    //"Tipo Assunto Jur�dico"
	Aadd(aCmpProces, {"MOVPROC"    , STR0108 , "C" , ""                             , ""   , .F. })                    //"Movimenta��o do Processo"
	Aadd(aCmpProces, {"STACONT"    , STR0109 , "C" , ""                             , ""   , .F. })                    //"Status da Contigencia"
	Aadd(aCmpProces, {"A1_NOME"    , STR0013 , "C" , ""                             , ""   , .T. })                    //"Cliente"
	Aadd(aCmpProces, {"NSZ_NUMCAS" , STR0014 , "C" , ""                             , ""   , .T. })                    //"Caso"
	Aadd(aCmpProces, {"POLO_EMPRE" , STR0015 , "C" , ""                             , cPolo, .T. })                    //Polo Empresa
	Aadd(aCmpProces, {"NSZ_PATIVO" , STR0016 , "C" , ""                             , ""   , .T. })                    //"Polo Ativo"
	Aadd(aCmpProces, {"NSZ_PPASSI" , STR0017 , "C" , ""                             , ""   , .T. })                    //"Polo Passivo"
	Aadd(aCmpProces, {"NUQ_ESTADO" , STR0019 , "C" , ""                             , ""   , .T. })                    //"Estado"
	Aadd(aCmpProces, {"NQ6_DESC"   , STR0020 , "C" , ""                             , ""   , .T. })                    //"Comarca"
	Aadd(aCmpProces, {"NQC_DESC"   , STR0021 , "C" , ""                             , ""   , .T. })                    //"Foro"
	Aadd(aCmpProces, {"NQE_DESC"   , STR0029 , "C" , ""                             , ""   , .T. })                    //"Vara"
	Aadd(aCmpProces, {"NUQ_NUMPRO" , STR0030 , "C" , "@R XXXXXXX-XX.XXXX.X.XX.XXXX" , ""   , .T. })                    //"Processo"
	Aadd(aCmpProces, {"A2_NOME"    , STR0087 , "C" , ""                             , ""   , .T. })                    //"Escrit�rio Credenciado"
	Aadd(aCmpProces, {"NSZ_DTINCL" , STR0031 , "D" , ""                             , ""   , .T. })                    //"Inclus�o"
	Aadd(aCmpProces, {"NQ1_DESC"   , STR0032 , "C" , ""                             , ""   , .T. })                    //"Natureza"
	Aadd(aCmpProces, {"NSZ_DETALH" , STR0033 , "M" , ""                             , RetCmpMemo("NSZ_DETALH"), .T. }) //"Detalhe" - apenas para for�ar o retorno na query
	Aadd(aCmpProces, {"NQU_DESC"   , STR0034 , "C" , ""                             , ""   , .T. })                    //"A��o"
	Aadd(aCmpProces, {"NSZ_VLCAUS" , STR0035 , "N" , ""                             , ""   , .T. })                    //"Valor Causa"
	Aadd(aCmpProces, {"NSZ_VACAUS" , STR0036 , "N" , ""                             , ""   , .T. })                    //"Valor Causa Atualizado"

	//Campos complementares n�o auditados
	aAux := J112aCmpCo("2")

	For nCont:= 1 To Len(aAux)
		cCampo    := AllTrim(aAux[nCont][1])
		cTipo     := JurX3Info(cCampo, "X3_TIPO")
		cCmpQuery := ""

		If cTipo == "M"
			cCmpQuery := RetCmpMemo(cCampo)
		EndIf
		Aadd(aCmpProces, {cCampo, AllTrim(aAux[nCont][3]), cTipo, "", cCmpQuery, .T. })
	Next nCont

	cSituac += "(CASE "
	cSituac +=     "WHEN O0F_SITUAC = '1' THEN '" + STR0061 + "' " // Em andamento
	cSituac +=     "WHEN O0F_SITUAC = '2' THEN '" + STR0062 + "' " // Encerrado
	cSituac +=     "ELSE '-'"
	cSituac += "END)"

	//Campos auditados processo
	//Apelido dos campos deve ter no maximo 7 caracteres, porque ira incluir (M1_ ou M2_)
	//               {Campo     , Titulo , Tipo, Mascara, Query       , Deseja apresentar o campo nas subquerys?}
	Aadd(aCmpAudPro, {"A1NOME"  , STR0037, "C" , ""     , "A1_NOME"   , .T. })            //"Cliente Auditado"
	Aadd(aCmpAudPro, {"CTTDESC" , STR0038, "C" , ""     , "CTT_DESC01", .T. })            //Centro de Custo
	Aadd(aCmpAudPro, {"NRBDESC" , STR0039, "C" , ""     , "NRB_DESC"  , .T. })            //�rea
	Aadd(aCmpAudPro, {"NRLDESC" , STR0040, "C" , ""     , "NRL_DESC"  , .T. })            //Sub-�rea
	Aadd(aCmpAudPro, {"DTPROV"  , STR0041, "D" , ""     , "O0F_DTPROV", .T. })            //Data Provis�o
	Aadd(aCmpAudPro, {"CTOSIMB" , STR0042, "C" , ""     , "CTO_SIMB"  , .T. })            //Moeda provis�o
	Aadd(aCmpAudPro, {"VLPROV"  , STR0043, "N" , ""     , "O0F_VLPROV", .T. })            //Prov�vel
	Aadd(aCmpAudPro, {"VAPROV"  , STR0044, "N" , ""     , "O0F_VAPROV", .T. })            //Prov�vel Atualizado
	Aadd(aCmpAudPro, {"VLPRPO"  , STR0045, "N" , ""     , "O0F_VLPRPO", .T. })            //Poss�vel
	Aadd(aCmpAudPro, {"VLPPOA"  , STR0046, "N" , ""     , "O0F_VLPPOA", .T. })            //Poss�vel Atualizado
	Aadd(aCmpAudPro, {"VLPRRE"  , STR0047, "N" , ""     , "O0F_VLPRRE", .T. })            //Remoto
	Aadd(aCmpAudPro, {"VLPREA"  , STR0048, "N" , ""     , "O0F_VLPREA", .T. })            //Remoto Atualizado

	//Verifica se os campos O0F_VINCON e O0F_VATINC existem no dicion�rio
	If Select("O0F") > 0
		lO0FNvCmp := (O0F->(FieldPos('O0F_VINCON')) > 0) .AND. (O0F->(FieldPos('O0F_VATINC')) > 0)
	Else
		DBSelectArea("O0F")
			lO0FNvCmp := (O0F->(FieldPos('O0F_VINCON')) > 0) .AND. (O0F->(FieldPos('O0F_VATINC')) > 0)
		O0F->( DBCloseArea() )
	EndIf
	
	If FWAliasInDic("O0W") .AND. lO0FNvCmp
		Aadd(aCmpAudPro, {"VALINC"  , STR0117, "N" , ""     , "O0F_VINCON", .T. })            //Incontroverso
		Aadd(aCmpAudPro, {"ATUINC"  , STR0118, "N" , ""     , "O0F_VATINC", .T. })            //Incontroverso Atualizado
	EndIf
	Aadd(aCmpAudPro, {"VCPROV"  , STR0049, "N" , ""     , "O0F_VCPROV", .T. })            //Corre��o Prov�vel
	Aadd(aCmpAudPro, {"VJPROV"  , STR0050, "N" , ""     , "O0F_VJPROV", .T. })            //Juros Prov�vel
	Aadd(aCmpAudPro, {"VLFINA"  , STR0051, "N" , ""     , "O0F_VLFINA", .T. })            //Valor Final
	Aadd(aCmpAudPro, {"VAFINA"  , STR0052, "N" , ""     , "O0F_VAFINA", .T. })            //Valor Final Atualizado
	Aadd(aCmpAudPro, {"DTULAT"  , STR0053, "D" , ""     , "O0F_DTULAT", .T. })            //�ltima Atualiza��o
	Aadd(aCmpAudPro, {"SITUAC"  , STR0054, "C" , ""     , cSituac     , .T. })            //Situa��o //"Em andamento" //"Encerrado" //"-"
	Aadd(aCmpAudPro, {"DTENCE"  , STR0055, "D" , ""     , "O0F_DTENCE", .T. })            //Encerramento
	Aadd(aCmpAudPro, {"DTREAB"  , STR0056, "D" , ""     , "O0F_DTREAB", .T. })            //Reabertura
	Aadd(aCmpAudPro, {"NQIDESC" , STR0057, "C" , ""     , "NQI_DESC"  , .T. })            //Motivo Encerramento
	Aadd(aCmpAudPro, {"DETENC"  , STR0058, "M" , ""     , RetCmpMemo("O0F_DETENC"), .T.}) //Detalhe Encerramento - apenas para for�ar o retorno na query

	cPeinVl := "(CASE WHEN O0G_PEINVL = '1' THEN '" + STR0092 + "' ELSE '" + STR0093 + "' END)" //"Objeto Inestim�vel" //"Sim" //"N�o"
	cIneCon := "(CASE WHEN O0G_INECON = '1' THEN '" + STR0092 + "' ELSE '" + STR0093 + "' END)" //"Contig�ncia Inestim�vel"	//"Sim"	//"N�o"

	//Campos auditados objetos
	//Apelido dos campos deve ter no maximo 7 caracteres, porque ira incluir (M1_ ou M2_)
	//               {Campo     , Titulo  , Tipo, Mascara, Query        , Deseja apresentar o campo nas subquerys?}
	Aadd(aCmpAudObj, {"AUDCOD"  , STR0107 , "C" , ""     , "O0G_COD"    , .T. }) //"Cod. Objeto"
	Aadd(aCmpAudObj, {"NSPDESC" , STR0083 , "C" , ""     , "NSP_DESC"   , .T. }) //"Tipo Objeto"
	Aadd(aCmpAudObj, {"PROGNO"  , STR0084 , "C" , ""     , "NQ7_DESC"   , .T. }) //"Risco Objeto"
	Aadd(aCmpAudObj, {"PEINVL"  , STR0088 , "C" , ""     , cPeinVl      , .T. }) //"Objeto Inestim�vel"
	Aadd(aCmpAudObj, {"PEVLR"   , STR0085 , "N" , ""     , "O0G_PEVLR"  , .T. }) //"Valor Objeto"
	Aadd(aCmpAudObj, {"PEVLRA"  , STR0086 , "N" , ""     , "O0G_PEVLRA" , .T. }) //"Valor Atualizado Objeto"
	Aadd(aCmpAudObj, {"INECON"  , STR0089 , "C" , ""     , cIneCon      , .T. }) //"Contig�ncia Inestim�vel"
	Aadd(aCmpAudObj, {"VLCONT"  , STR0090 , "N" , ""     , "O0G_VLCONT" , .T. }) //"Valor Contig�ncia"
	Aadd(aCmpAudObj, {"VLCONA"  , STR0091 , "N" , ""     , "O0G_VLCONA" , .T. }) //"Valor Atualizado Contig�ncia"

	If FWAliasIndic("O0W") .And. FWAliasIndic("O0Y")
		//Campos auditados pedidos
		//Apelido dos campos deve ter no maximo 7 caracteres, porque ira incluir (M1_ ou M2_)
		//               {Campo     , Titulo  , Tipo, Mascara, Query        , Deseja apresentar o campo nas subquerys?}
		Aadd(aCmpAudPed, {"VPROVA"  , STR0111 , "N" , ""     , "O0Y_VPROVA" , .T. }) //"Valor Prov�vel Pedido"
		Aadd(aCmpAudPed, {"VATPRO"  , STR0112 , "N" , ""     , "O0Y_VATPRO" , .T. }) //"Valor Atualizado Prov�vel"
		Aadd(aCmpAudPed, {"VPOSSI"  , STR0113 , "N" , ""     , "O0Y_VPOSSI" , .T. }) //"Valor Poss�vel"
		Aadd(aCmpAudPed, {"VATPOS"  , STR0114 , "N" , ""     , "O0Y_VATPOS" , .T. }) //"Valor Atualizado Poss�vel"
		Aadd(aCmpAudPed, {"VREMOT"  , STR0115 , "N" , ""     , "O0Y_VREMOT" , .T. }) //"Valor Remoto"
		Aadd(aCmpAudPed, {"VATREM"  , STR0116 , "N" , ""     , "O0Y_VATREM" , .T. }) //"Valor Atualizado Remoto"
		Aadd(aCmpAudPed, {"VINCON"  , STR0117 , "N" , ""     , "O0Y_VINCON" , .T. }) //"Valor Incontroverso"
		Aadd(aCmpAudPed, {"VATINC"  , STR0118 , "N" , ""     , "O0Y_VATINC" , .T. }) //"Valor Atualizado Incontroverso"
	EndIf

	//Campos complementares auditados
	aAux := {}
	aAux := CmpsComple()

	For nCont:= 1 To Len(aAux)
		cCampo    := AllTrim(aAux[nCont][1])
		cTipo     := JurX3Info(cCampo, "X3_TIPO")
		cTipo     := IIF(Empty(cTipo), "C", cTipo)
		cCmpQuery := ""

		If cTipo == "M"
			cCmpQuery := RetCmpMemo(cCampo)
		EndIf
		Aadd(aCmpsCompl, {cCampo, AllTrim(aAux[nCont][2]), cTipo, "", cCmpQuery})
	Next nCont

	//Criar colunas no Excel
	aAux := {}
	Aadd(aAux, {aCmpProces, .F.})
	Aadd(aAux, {aCmpAudPro, .T.})
	Aadd(aAux, {aCmpsCompl, .T.})
	Aadd(aAux, {aCmpAudObj, .T.})
	Aadd(aAux, {aCmpAudPed, .T.})

	For nTipo:= 1 To Len(aAux)
		aCampos   := aAux[nTipo][1]
		lAuditado := aAux[nTipo][2]

		For nCont:= 1 To Len(aCampos)

			cTitulo := aCampos[nCont][TITULO]

			//1-General, 2-Number, 3-Monet�rio, 4-DateTime
			Do Case
				Case aCampos[nCont][TIPO] $ "C|M"
					nFormat := 1
					nAlign  := IIF(aCampos[nCont][TIPO] == "M", 1, 2) //1-Left, 2-Center, 3-Right
				Case aCampos[nCont][TIPO] $ "N"
					nFormat := 3
					nAlign  := 1 //1-Left, 2-Center, 3-Right
				Case aCampos[nCont][TIPO] $ "D"
					nFormat := 4
					nAlign  := 2 //1-Left, 2-Center, 3-Right
			End Case
		
			If lAuditado
				oExcel:AddColumn(cAba, cDescTab, cTitulo + " " + DtoC(MV_PAR01), nAlign, nFormat, lTotal) //1� Marca
				oExcel:AddColumn(cAba, cDescTab, cTitulo + " " + DtoC(MV_PAR02), nAlign, nFormat, lTotal) //2� Marca
			Else
				oExcel:AddColumn(cAba, cDescTab, cTitulo, nAlign, nFormat, lTotal)
			EndIf

		Next nCont
	Next nTipo

	Aadd(aRetorno, aClone(aCmpProces))
	Aadd(aRetorno, aClone(aCmpAudPro))
	Aadd(aRetorno, aClone(aCmpsCompl))
	Aadd(aRetorno, aClone(aCmpAudObj))
	Aadd(aRetorno, aClone(aCmpAudPed))

	FwFreeObj(aCmpProces)
	FwFreeObj(aCmpAudPro)
	FwFreeObj(aCmpsCompl)
	FwFreeObj(aCmpAudObj)
	FwFreeObj(aCmpAudPed)
	FwFreeObj(aAux)
	FwFreeObj(aCampos)
	
	RestArea(aArea)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCmpMemo()
Retorna a query que sera executada para retonar o valor do campo memo

@author  Rafael Tenorio da Costa
@since 	 01/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetCmpMemo(cCampo)
Local cCampoQry := ""
Local cBanco    := Upper( TcGetDb() )
Local cQuant    := cValToChar(500)   //Quantidade de caracteres que ser�o retornados no campo memo

	If cBanco $ "ORACLE"
		cCampoQry := "TO_CHAR(SUBSTR(" + cCampo + ", 1, " + cQuant + "))"
	ElseIf cBanco $ "POSTGRES"
		cCampoQry := "SUBSTR(" + cCampo + ", 1, " + cQuant + ")::char(500) "
	ElseIf cBanco == "MSSQL" .Or. cBanco == "DB2"
		cCampoQry := "CAST(" + cCampo + " AS VARCHAR(" + cQuant + "))"
	EndIf
Return cCampoQry

//-------------------------------------------------------------------
/*/{Protheus.doc} ObjGarDes()
Retorna os valores dos Objetos, Garantias e Despesas por tipo

@author  Rafael Tenorio da Costa
@since 	 13/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ObjGarDes(cTabela, oExcel, aColVal)

Local aArea   := GetArea()
Local cSql    := ""
Local aSql    := {}
Local cTipo   := ""
Local cTitulo := ""
Local nCont   := 1

	Do Case
		Case cTabela == "NSY"
			cSql := " SELECT O0G_CPEVLR, NSP_DESC, SUM(O0G_PEVLR) O0G_PEVLR, SUM(O0G_PEVLRA) O0G_PEVLRA"
			cSql += " FROM " + RetSqlName("O0G") + " O0G LEFT JOIN " + RetSqlName("NSP") + " NSP"
			cSql +=     " ON NSP_FILIAL = '" + xFilial("NSP") + "' AND O0G_CPEVLR = NSP_COD AND NSP.D_E_L_E_T_ = ' '"

			If Type("MV_PAR03") != "U" .AND. !Empty(MV_PAR03) //valida se informou a area
				cSql +=     " JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ_FILIAL = O0G_FILPRO AND O0G_CAJURI = NSZ_COD AND NSZ.D_E_L_E_T_ = ' ' AND NSZ_TIPOAS = '" + MV_PAR03 + "' )"
			Endif

			cSql += " WHERE O0G_FILIAL = '" + xFilial("O0G") + "' AND"
			cSql +=      " (O0G_MARCA = '" + DtoS(MV_PAR01) + "' OR O0G_MARCA = '" + DtoS(MV_PAR02) + "') AND"
			cSql +=       " O0G_PEVLRA > 0 AND"
			cSql +=       " O0G.D_E_L_E_T_ = ' '"
			cSql += " GROUP BY O0G_CPEVLR, NSP_DESC"
			cSql += " ORDER BY O0G_CPEVLR, NSP_DESC"

		Case cTabela == "NT2"
			cSql := " SELECT O0H_CTPGAR, NQW_DESC, SUM(O0H_VALOR) O0H_VALOR, SUM(O0H_VLRATU) O0H_VLRATU"
			cSql += " FROM " + RetSqlName("O0H") + " O0H LEFT JOIN " + RetSqlName("NQW") + " NQW"
			cSql +=     " ON NQW_FILIAL = '" + xFilial("NQW") + "' AND O0H_CTPGAR = NQW_COD AND NQW.D_E_L_E_T_ = ' '"

			If Type("MV_PAR03") != "U" .AND. !Empty(MV_PAR03) //valida se informou a area
				cSql +=     " JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ_FILIAL = O0H_FILPRO AND O0H_CAJURI = NSZ_COD AND NSZ.D_E_L_E_T_ = ' ' AND NSZ_TIPOAS = '" + MV_PAR03 + "' )"
			Endif

			cSql += " WHERE O0H_FILIAL = '" + xFilial("O0H") + "' AND"
			cSql +=      " (O0H_MARCA = '" + DtoS(MV_PAR01) + "' OR O0H_MARCA = '" + DtoS(MV_PAR02) + "') AND"
			cSql +=       " O0H.D_E_L_E_T_ = ' '"
			cSql += " GROUP BY O0H_CTPGAR, NQW_DESC"
			cSql += " ORDER BY O0H_CTPGAR, NQW_DESC"

		Case cTabela == "NT3"
			cSql := " SELECT O0I_CTPDES, NSR_DESC, SUM(O0I_VALOR) O0I_VALOR, SUM(O0I_VALOR) O0I_VALOR"
			cSql += " FROM " + RetSqlName("O0I") + " O0I LEFT JOIN " + RetSqlName("NSR") + " NSR"
			cSql +=     " ON NSR_FILIAL = '" + xFilial("NSR") + "' AND O0I_CTPDES = NSR_COD AND NSR.D_E_L_E_T_ = ' '"

			If Type("MV_PAR03") != "U" .AND. !Empty(MV_PAR03) //valida se informou a area
				cSql +=     " JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ_FILIAL = O0I_FILPRO AND O0I_CAJURI = NSZ_COD AND NSZ.D_E_L_E_T_ = ' ' AND NSZ_TIPOAS = '" + MV_PAR03 + "' )"
			Endif

			cSql += " WHERE O0I_FILIAL = '" + xFilial("O0I") + "' AND"
			cSql += 	 " (O0I_MARCA = '" + DtoS(MV_PAR01) + "' OR O0I_MARCA = '" + DtoS(MV_PAR02) + "') AND"
			cSql += 	 " O0I_VALOR > 0 AND"
			cSql += 	 " O0I.D_E_L_E_T_ = ' '"
			cSql += " GROUP BY O0I_CTPDES, NSR_DESC"
			cSql += " ORDER BY O0I_CTPDES, NSR_DESC"
	End Case

	aSql := JurSQL(cSql, "*")

	//Cria colunas
	For nCont:= 1 To Len(aSql)
		cTipo	:= aSql[nCont][1]          //Tipo Objeto, Garantia, Despesa
		cTitulo := AllTrim(aSql[nCont][2]) //Descricao do Tipo

		If cTabela == 'NT2'
			cTitulo += STR0110
		EndIf

		If Ascan(aColVal, {|x| x[1] == cTipo}) == 0
			Aadd(aColVal, {cTipo, cTitulo})
			oExcel:AddColumn(cAba, cDescTab, cTitulo + " " + DtoC(MV_PAR01), 1, 3, .T.) //1� Marca
			oExcel:AddColumn(cAba, cDescTab, cTitulo + " " + DtoC(MV_PAR02), 1, 3, .T.) //2� Marca
		EndIf
	Next nCont

	RestArea(aArea)
	FwFreeObj(aSql)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IncCmpsPro
Inclui campos do processo na linha.

@author  Rafael Tenorio da Costa
@since 	 18/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IncCmpsPro(aLinha, aCmpProces, cTabSql)

	Local nCmpsPro   := 1
	Local xConteudo  := ""
	Local nQtdCmpPro := Len(aCmpProces)

	//Campos do processo
	For nCmpsPro:=1 To nQtdCmpPro

		xConteudo := &(cTabSql + "->" + aCmpProces[nCmpsPro][CAMPO])

		xConteudo := TrataCampo(xConteudo, aCmpProces[nCmpsPro])

		Aadd(aLinha, xConteudo)
	Next nCmpsPro

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} atuVlrCont(aLinha, aColCmpAud, cTabSql, lExstPedM1, lExstPedM2, nColCpComp)
Grava o valor da conting�ncia do progn�stico do pedido.

@param aLinha     - Linhas que ser�o inclu�das no relat�rio.
@param aColCmpAud - Colunas que ser�o preenchidas no excel.
@param cTabSql    - Alias da tabela tempor�ria.
@param lExstPedM1 - Existe pedidos na Marca 1.
@param lExstPedM2 - Existe pedidos na Marca 2.
@param nColCpComp - Quantidade de Campos complementares.

@since   07/05/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function atuVlrCont(aLinha, aColCmpAud, cTabSql, lExstPedM1, lExstPedM2, nColCpComp)
Local xContAtu2  := ''
Local xContAtu1  := ''
Local xContMar1  := ''
Local xContMar2  := ''
Local nPosCont1  := 0
Local nPosCont2  := 0
Local nPsAtCont1 := 0
Local nPsAtCont2 := 0
Local cProgMar1  := Alltrim(&(cTabSql + "->M1_PROGNO"))
Local cProgMar2  := Alltrim(&(cTabSql + "->M2_PROGNO"))

Default lExstPedM1 := .F.
Default lExstPedM2 := .F.
Default cTabSql    := ''
Default nColCpComp := 0

	/*
	 * Para saber a posi��o do campo do valor de conting�ncia original e atual
	 * � necessaria validar a quantidade dos campos complementares configurado
	 * no ambiente.
	 *
	 * L�gica de c�lculo: 
	 * 70 - s�o as colunas padr�es antes dos campos complementares
	 * 15/16/17/18 - s�o as posi��es dos campos de contingencia das marcas,
	 *               sendo considerado, ap�s das colunas de campos complementares.
	 * (nColCpComp * 2) - qtd de campos complementares auditados * 2 para considerar as duas marcas.
	 */
	nPosCont1  := 70 + 15 + (nColCpComp * 2)
	nPosCont2  := 70 + 16 + (nColCpComp * 2)
	nPsAtCont1 := 70 + 17 + (nColCpComp * 2)
	nPsAtCont2 := 70 + 18 + (nColCpComp * 2)

	If lExstPedM1
		Do Case
			//Caractere ou Memo
			Case cProgMar1 == "Prov�vel"
				xContMar1 := &(cTabSql + "->M1_" + aColCmpAud[1][CAMPO])
				xContAtu1 := &(cTabSql + "->M1_" + aColCmpAud[2][CAMPO])
				
				xContMar1 := TrataCampo(xContMar1, aColCmpAud[1])
				xContAtu1 := TrataCampo(xContAtu1, aColCmpAud[2])

			Case cProgMar1 == "Poss�vel"
				xContMar1 := &(cTabSql + "->M1_" + aColCmpAud[3][CAMPO])
				xContAtu1 := &(cTabSql + "->M1_" + aColCmpAud[4][CAMPO])
				
				xContMar1 := TrataCampo(xContMar1, aColCmpAud[3])
				xContAtu1 := TrataCampo(xContAtu1, aColCmpAud[4])

			Case cProgMar1 == "Remoto"
				xContMar1 := &(cTabSql + "->M1_" + aColCmpAud[5][CAMPO])
				xContAtu1 := &(cTabSql + "->M1_" + aColCmpAud[6][CAMPO])
				
				xContMar1 := TrataCampo(xContMar1, aColCmpAud[5])
				xContAtu1 := TrataCampo(xContAtu1, aColCmpAud[6])

			Case cProgMar1 == "Incontroverso"
				xContMar1 := &(cTabSql + "->M1_" + aColCmpAud[7][CAMPO])
				xContAtu1 := &(cTabSql + "->M1_" + aColCmpAud[8][CAMPO])
				
				xContMar1 := TrataCampo(xContMar1, aColCmpAud[7])
				xContAtu1 := TrataCampo(xContAtu1, aColCmpAud[8])
		End Case

		aLinha[nPosCont1]  := xContMar1
		aLinha[nPsAtCont1] := xContAtu1
	EndIf

	If lExstPedM2
		Do Case
			Case cProgMar2 == "Prov�vel"
				xContMar2 := &(cTabSql + "->M2_" + aColCmpAud[1][CAMPO])
				xContAtu2 := &(cTabSql + "->M2_" + aColCmpAud[2][CAMPO])
				
				xContMar2 := TrataCampo(xContMar2, aColCmpAud[1])
				xContAtu2 := TrataCampo(xContAtu2, aColCmpAud[2])

			Case cProgMar2 == "Poss�vel"
				xContMar2 := &(cTabSql + "->M2_" + aColCmpAud[3][CAMPO])
				xContAtu2 := &(cTabSql + "->M2_" + aColCmpAud[4][CAMPO])
				
				xContMar2 := TrataCampo(xContMar2, aColCmpAud[3])
				xContAtu2 := TrataCampo(xContAtu2, aColCmpAud[4])

			Case cProgMar2 == "Remoto"
				xContMar2 := &(cTabSql + "->M2_" + aColCmpAud[5][CAMPO])
				xContAtu2 := &(cTabSql + "->M2_" + aColCmpAud[6][CAMPO])
				
				xContMar2 := TrataCampo(xContMar2, aColCmpAud[5])
				xContAtu2 := TrataCampo(xContAtu2, aColCmpAud[6])

			Case cProgMar2 == "Incontroverso"
				xContMar2 := &(cTabSql + "->M2_" + aColCmpAud[7][CAMPO])
				xContAtu2 := &(cTabSql + "->M2_" + aColCmpAud[8][CAMPO])
				
				xContMar2 := TrataCampo(xContMar1, aColCmpAud[7])
				xContAtu2 := TrataCampo(xContAtu2, aColCmpAud[8])
		End Case

		aLinha[nPosCont2]  := xContMar2
		aLinha[nPsAtCont2] := xContAtu2
	EndIf
return

//-------------------------------------------------------------------
/*/{Protheus.doc} IncCmpsAud(aLinha, aColCmpAud, cTabSql, lPedidos, aColCpComp)
Inclui campos auditados na linha.

@param aLinha     - Linhas que ser�o inclu�das no relat�rio.
@param aColCmpAud - Colunas que ser�o preenchidas no excel.
@param cTabSql    - Alias da tabela tempor�ria.
@param lPedidos   - Indica s� pedido (.T.) ou objeto (.F.)
@param aColCpComp - Campos complementares.

@author  Rafael Tenorio da Costa
@since 	 18/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IncCmpsAud(aLinha, aColCmpAud, cTabSql, lPedidos, aColCpComp)
Local nCmpsAud   := 1
Local xContMar1  := ""
Local xContMar2  := ""
Local lExstPedM1 := .F.
Local lExstPedM2 := .F.
Local nQtdCmpAud := Len(aColCmpAud)

Default lPedidos   := .F.
Default aColCpComp := {}

	//Campos auditados
	For nCmpsAud:=1 To nQtdCmpAud
		xContMar1 := &(cTabSql + "->M1_" + aColCmpAud[nCmpsAud][CAMPO])
		xContMar2 := &(cTabSql + "->M2_" + aColCmpAud[nCmpsAud][CAMPO])

		xContMar1 := TrataCampo(xContMar1, aColCmpAud[nCmpsAud])
		xContMar2 := TrataCampo(xContMar2, aColCmpAud[nCmpsAud])

		Aadd(aLinha, xContMar1)
		Aadd(aLinha, xContMar2)
	Next nCmpsAud

	If lPedidos
		lExstPedM1 :=  (&(cTabSql + "->M1_VPROVA") > 0 .Or. &(cTabSql + "->M1_VPOSSI") > 0 .Or.;
						&(cTabSql + "->M1_VREMOT") > 0 .Or. &(cTabSql + "->M1_VINCON") > 0) .And.;
						Empty(&(cTabSql + "->M1_PEINVL"))
		lExstPedM2 :=  (&(cTabSql + "->M2_VPROVA") > 0 .Or. &(cTabSql + "->M2_VPOSSI") > 0 .Or.;
						&(cTabSql + "->M2_VREMOT") > 0 .Or. &(cTabSql + "->M2_VINCON") > 0) .And.;
						Empty(&(cTabSql + "->M2_PEINVL"))

		atuVlrCont(aLinha, aColCmpAud, cTabSql, lExstPedM1, lExstPedM2, Len(aColCpComp))
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CmpsComple()
Retorna os valores dos Objetos, Garantias e Despesas por tipo

@author  Rafael Tenorio da Costa
@since 	 13/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CmpsComple()

	Local aArea	:= GetArea()
	Local cSql	:= ""

	cSql := " SELECT O0C_CMPFOR, O0B_TITULO"
	cSql += " FROM " + RetSqlName("O0C") + " O0C INNER JOIN " + RetSqlName("O0B") + " O0B"
	cSql += 	" ON O0B_FILIAL = '" + xFilial("O0B") + "' AND (O0C_CMPFOR = O0B_CAMPO OR O0C_CMPFOR = O0B_FORMUL)"
	cSql += " WHERE O0C_FILIAL = '" + xFilial("O0C") + "'"
	cSql += 	" AND (O0C_MARCA = '" + DtoS(MV_PAR01) + "' OR O0C_MARCA = '" + DtoS(MV_PAR02) + "')"
	cSql += 	" AND O0C.D_E_L_E_T_ = ' '"
	cSql += 	" AND O0B.D_E_L_E_T_ = ' '"
	cSql += " GROUP BY O0C_CMPFOR, O0B_TITULO"

	aSql := JurSQL(cSql, "*")

	RestArea(aArea)

Return aSql

//-------------------------------------------------------------------
/*/{Protheus.doc} DadosAudit()
Retorna dados principais da auditoria Processos\Objetos auditados

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DadosAudit(aColunas)
Local cTabSql    := GetNextAlias()
Local cSql       := ""
Local cSqlQtd    := "SELECT COUNT(1) QTD FROM ( "
Local nQuant     := 0
Local cMovicProc := ''
Local cStaCont   := ''
Local lAudPed    := .F.

	cMovicProc := "(CASE "
	cMovicProc +=       "WHEN COALESCE(SITUAC_P1,'-') = '-' AND SITUAC_P2 = '1' "
	cMovicProc +=       "THEN '" + STR0071 + "' "                                 // STR0071 - "Caso Novo"
	cMovicProc +=       "WHEN COALESCE(SITUAC_P1,'-') = '-' AND SITUAC_P2 = '2' "
	cMovicProc +=       "THEN '" + STR0098 + "' "                                 // STR0098 - "Novo Encerrado"
	cMovicProc +=       "WHEN SITUAC_P1 = '1' AND SITUAC_P2 = '2' "
	cMovicProc +=       "THEN '" + STR0018 + "' "                                 // STR0018 - "Encerrado no M�s"
	cMovicProc +=       "WHEN SITUAC_P1 = '2' AND SITUAC_P2 = '1' "
	cMovicProc +=       "THEN '" + STR0022 + "' "                                 // STR0022 - "Caso Reaberto"
	cMovicProc +=       "WHEN SITUAC_P1 = '1' AND SITUAC_P2 = '1' "
	cMovicProc +=       "THEN '" + STR0070 + "' "                                 // STR0070 - "Andamento Estoque"
	cMovicProc +=       "ELSE '-' "
	cMovicProc += " END) MOVPROC," //Movimento do Processo

	cStaCont := "(CASE "
	cStaCont +=       "WHEN SITUAC_P1 = '2' AND SITUAC_P2 = '1' "
	cStaCont +=           "THEN '" + STR0022 + "' "                                                                             // STR0022 - "Caso Reaberto"
	cStaCont +=       "WHEN SITUAC_P1 = '1' AND SITUAC_P2 = '2' AND COALESCE(M1_VLPROV,0) = 0 "
	cStaCont +=           "THEN '" + STR0099 + "' "                                                                             // STR0099 - "Baixa por Encerramento"
	//cStaCont +=       "WHEN COALESCE(MARCA1.VALOR_DESPESA,0) < COALESCE(MARCA2.VALOR_DESPESA,0) "
	//cStaCont +=       "THEN 'Baixa por Pagamento' "
	cStaCont +=       "WHEN SITUAC_P1 = '1' AND SITUAC_P2 = '2' AND COALESCE(M1_VLPROV,0) > 0 "
	cStaCont +=           "THEN '" + STR0100 + "' "                                                                             // STR0100 - "Revers�o por n�o utiliza��o"
	cStaCont +=       "WHEN (COALESCE(M1_VLPROV,0) = 0 AND COALESCE(M2_VLPROV,0) > 0) "
	cStaCont +=           "THEN '" + STR0101 + "' "                                                                             // STR0101 - "Adi��o de Provis�o"
	cStaCont +=       "WHEN ((COALESCE(M2_VLPRPO,0) < COALESCE(M1_VLPRPO,0) OR COALESCE(M2_VLPRRE,0) < COALESCE(M1_VLPRRE,0)) "
	cStaCont +=          "AND COALESCE(M2_VLPROV,0) > COALESCE(M1_VLPROV,0)) OR (COALESCE(M2_VLPROV,0) > COALESCE(M1_VLPROV,0)) "
	cStaCont +=              "THEN '" + STR0102 + "' "                                                                          // STR0102 - "Aumento de Provis�o"
	cStaCont +=       "WHEN COALESCE(M2_VLPROV,0) < COALESCE(M1_VLPROV,0) "
	cStaCont +=           "THEN '" + STR0103 + "' "                                                                             // STR0103 - "Redu��o Provis�o"
	cStaCont +=       "WHEN COALESCE(M2_VLPROV,0) = COALESCE(M1_VLPROV,0) AND COALESCE(M2_VAPROV,0) > COALESCE(M1_VAPROV,0) "
	cStaCont +=           "THEN '" + STR0104 + "' "                                                                             // STR0104 - "Corre��o Monet�ria"
	cStaCont +=       "WHEN COALESCE(M2_VLPROV,0) = 0 AND COALESCE(M1_VLPROV,0) = 0 "
	cStaCont +=           "THEN '" + STR0105 + "' "                                                                             // STR0105 - "Sem Provis�o"
	cStaCont +=       "WHEN COALESCE(M2_VLPROV,0) > 0 AND COALESCE(M1_VLPROV,0) > 0 and COALESCE(M2_VLPROV,0) = COALESCE(M1_VLPROV,0) "
	cStaCont +=           "THEN '" + STR0106 + "' "                                                                             // STR0106 - "Sem Altera��o"
	cStaCont +=       "ELSE '-' "
	cStaCont +=  " END) STACONT,"

	lAudPed := FWAliasIndic("O0W") .And. FWAliasIndic("O0Y")

	//Monta query principal
	cSql := "SELECT " + cMovicProc + cStaCont + " AUDITADOS.*, PROCESSO.* FROM"
		cSql += " ( SELECT * FROM"

			//Query com dados da auditoria por marca1
			cSql += " ( "
			If lAudPed
				cSql += " ( "
				cSql +=     SqlAuditor("M1", MV_PAR01, aColunas, .F. /*lPedidos*/)
				cSql += " ) "
				cSql +=     " UNION "
				cSql += " ( "
				cSql +=     SqlAuditor("M1", MV_PAR01, aColunas, /*lPedidos*/,.T. /*lSemPedObj*/)
				cSql += " ) "
				cSql +=     " UNION "
				cSql += " ( "
				cSql +=     SqlAuditor("M1", MV_PAR01, aColunas, .T. /*lPedidos*/)
				cSql += " ) "
			Else
				cSql += SqlAuditor("M1", MV_PAR01, aColunas)
			EndIf
			cSql += " ) MARCA1"

		cSql += " FULL JOIN"

			//Query com dados da auditoria por marca2
			cSql += " ( "
			If lAudPed
				cSql += " ( "
				cSql +=     SqlAuditor("M2", MV_PAR02, aColunas, .F. /*lPedidos*/)
				cSql += " ) "
				cSql +=     " UNION "
				cSql += " ( "
				cSql +=     SqlAuditor("M2", MV_PAR02, aColunas, .F. /*lPedidos*/,.T. /*lSemPedObj*/)
				cSql += " ) "
				cSql +=     " UNION "
				cSql += " ( "
				cSql +=     SqlAuditor("M2", MV_PAR02, aColunas, .T. /*lPedidos*/)
				cSql += " ) "
			Else
				cSql += SqlAuditor("M2", MV_PAR02, aColunas)
			EndIf
			cSql += " ) MARCA2"

		cSql += " ON M1_O0F_FILPRO = M2_O0F_FILPRO AND M1_O0F_CAJURI = M2_O0F_CAJURI"
		cSql += " AND (M1_O0G_COD = M2_O0G_COD OR M1_O0G_COD = '' OR M2_O0G_COD='')"
		cSql += ") AUDITADOS"

	cSql += " JOIN"
		//Query com dados do processo
		cSql += " ( "
		cSql += SqlProcess( aColunas[PROCESSO] )
		cSql += " ) PROCESSO"

	cSql += " ON ( (M1_O0F_FILPRO = NSZ_FILIAL AND M1_O0F_CAJURI = NSZ_COD) OR (M2_O0F_FILPRO = NSZ_FILIAL AND M2_O0F_CAJURI = NSZ_COD) )"

	//Executa query para retornar a quantidade
	cSqlQtd := cSqlQtd + cSql + " ) QUANTIDADE"
	cSqlQtd := ChangeQuery(cSqlQtd)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSqlQtd), cTabSql, .F., .T.)

	If !(cTabSql)->( Eof() )
		nQuant := (cTabSql)->QTD
	EndIf
	(cTabSql)->( DbCloseArea() )

	//Executa query principal
	cSql += " ORDER BY NSZ_FILIAL, NSZ_COD"
	cSql := ChangeQuery(cSql)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cTabSql, .F., .T.)
Return {nQuant, cTabSql}

//-------------------------------------------------------------------
/*/{Protheus.doc} SqlProcess()
Retorna a query com dados retirados do processo

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SqlProcess(aCmpProces)
Local cSql    := ""
Local cCampos := ""
Local nCont   := 1

	//Carrega campos do processo
	For nCont:=1 To Len(aCmpProces)
		If (aCmpProces[nCont][6])
			cCampos += aCmpProces[nCont][QUERYCAMPO] + " " + aCmpProces[nCont][CAMPO] + ", "
		EndIf
	Next nCont

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2)

	cSql := " SELECT " + cCampos + ", "
	cSql += " SITUAC_P1, SITUAC_P2"

	//Auditoria x Processo
	cSql += " FROM " + RetSqlName("NSZ") + " NSZ"

	//Tipo de Assunto jur�dico
	cSql += " LEFT JOIN " + RetSqlName("NYB") + " NYB"
	cSql +=     " ON NYB_FILIAL = '" + xFilial("NYB") + "' AND NSZ_TIPOAS = NYB_COD AND NYB.D_E_L_E_T_ = ' '"

	//Cliente
	cSql += " LEFT JOIN " + RetSqlName("SA1") + " SA1"
	cSql +=     " ON A1_FILIAL = '" + xFilial("SA1") + "' AND NSZ_CCLIEN = A1_COD AND NSZ_LCLIEN = A1_LOJA AND SA1.D_E_L_E_T_ = ' '"

	//Instancias
	cSql += " LEFT JOIN " + RetSqlName("NUQ") + " NUQ"
	cSql +=     " ON NSZ_FILIAL = NUQ_FILIAL AND NSZ_COD = NUQ_CAJURI AND NUQ_INSATU = '1' AND NUQ.D_E_L_E_T_ = ' '"

	//Comarca
	cSql += " LEFT JOIN " + RetSqlName("NQ6") + " NQ6"
	cSql +=     " ON NQ6_FILIAL = '" + xFilial("NQ6") + "' AND NUQ_CCOMAR = NQ6_COD AND NQ6.D_E_L_E_T_ = ' '"

	//Foro
	cSql += " LEFT JOIN " + RetSqlName("NQC") + " NQC"
	cSql +=     " ON NQC_FILIAL = '" + xFilial("NQC") + "' AND NUQ_CCOMAR = NQC_CCOMAR AND NUQ_CLOC2N = NQC_COD AND NQC.D_E_L_E_T_ = ' '"

	//Vara
	cSql += " LEFT JOIN " + RetSqlName("NQE") + " NQE"
	cSql +=     " ON NQ6_FILIAL = '" + xFilial("NQE") + "' AND NUQ_CLOC2N = NQE_CLOC2N AND NUQ_CLOC3N = NQE_COD AND NQE.D_E_L_E_T_ = ' '"

	//Fornecedor \ Escritorio Credenciado
	cSql += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
	cSql +=     " ON A2_FILIAL = '" + xFilial("SA2") + "' AND NUQ_CCORRE = A2_COD AND NUQ_LCORRE = A2_LOJA AND SA2.D_E_L_E_T_ = ' '"

	//Natureza
	cSql += " LEFT JOIN " + RetSqlName("NQ1") + " NQ1"
	cSql +=     " ON NQ1_FILIAL = '" + xFilial("NQ1") + "' AND NUQ_CNATUR = NQ1_COD AND NQ1.D_E_L_E_T_ = ' '"

	//Tipo da a��o
	cSql += " LEFT JOIN " + RetSqlName("NQU") + " NQU"
	cSql +=     " ON NQU_FILIAL = '" + xFilial("NQU") + "' AND NUQ_CTIPAC = NQU_COD AND NQU.D_E_L_E_T_ = ' '"

	//Valida a situa��o do processo da marca 1
	cSql += " LEFT JOIN (SELECT NSZ_COD P1_CAJURI, NSZ_SITUAC SITUAC_P1"
	cSql +=            " FROM " + RetSqlName("NSZ") + " NSZM1"
	cSql +=            " INNER JOIN " + RetSqlName("O0F") +  " O0FM1"
	cSql +=                  " ON  NSZM1.NSZ_FILIAL = O0FM1.O0F_FILPRO"
	cSql +=                  " AND NSZM1.NSZ_COD    = O0FM1.O0F_CAJURI"
	cSql +=                  " AND O0FM1.O0F_MARCA  = '" + DToS(MV_PAR01) + "'"
	cSql +=                  " AND O0FM1.D_E_L_E_T_ = ' '"
	cSql +=                  " AND NSZM1.D_E_L_E_T_ = ' '"
	cSql +=             ") PROC01 ON P1_CAJURI = NSZ.NSZ_COD"

	//Valida a situa��o do processo da marca 2
	cSql += " LEFT JOIN (SELECT NSZ_COD P2_CAJURI, NSZ_SITUAC SITUAC_P2"
	cSql +=            " FROM " + RetSqlName("NSZ") + " NSZM2"
	cSql +=            " INNER JOIN " + RetSqlName("O0F") +  " O0FM2"
	cSql +=                  " ON  NSZM2.NSZ_FILIAL = O0FM2.O0F_FILPRO"
	cSql +=                  " AND NSZM2.NSZ_COD    = O0FM2.O0F_CAJURI"
	cSql +=                  " AND O0FM2.O0F_MARCA  = '" + DToS(MV_PAR02) + "'"
	cSql +=                  " AND O0FM2.D_E_L_E_T_ = ' '"
	cSql +=                  " AND NSZM2.D_E_L_E_T_ = ' '"
	cSql +=             ") PROC02 ON P2_CAJURI = NSZ.NSZ_COD"

	cSql += " WHERE NSZ.D_E_L_E_T_ = ' '"

	If Type("MV_PAR03") != "U" .AND. !Empty(MV_PAR03) //valida se informou a area
		cSql +=     " AND NSZ_TIPOAS = '" + MV_PAR03 + "'"
	EndIf
Return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} SqlAuditor()
Retorna a query de auditoria por marca com informa��es dos Campos auditados e Objetos

@param cMarca     Apelido da marca
@param dMarca     Data da Marca
@param aColunas   Array com a estrutura dos campos a serem usados na query
@param lPedidos   Indica se a query � relativa a pedidos (.T.) ou a objetos (.F.)
@param lSemPedObj Indica se a query � relativa a processos sem auditoria de pedidos/ objetos

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SqlAuditor(cMarca, dMarca, aColunas, lPedidos, lSemPedObj)
Local cSql       := ""
Local cCampos    := ""
Local nCont      := 1
Local nCntCmpPed := 1
Local aCmpAudPro := aColunas[AUDPROCESS]
Local aCmpAudObj := aColunas[AUDOBJETO]
Local aCmpAudPed := aColunas[AUDPEDIDO]
Local cQryCampo  := ""
Local lAudPed    := .F.

Default lPedidos   := .F.
Default lSemPedObj := .F.

	//Inclui os campos chave utilizados no ON do FULL JOIN
	cCampos := "ISNULL(O0F_FILPRO, '') " + cMarca + "_O0F_FILPRO, "
	cCampos += "ISNULL(O0F_CAJURI, '') " + cMarca + "_O0F_CAJURI, "
	If lSemPedObj
		cCampos += "'' " + cMarca + "_O0Y_COD, "
	Else
		If lPedidos
			cCampos += "ISNULL(O0Y_COD	 , '') " + cMarca + "_O0Y_COD, "
		Else
			cCampos += "ISNULL(O0G_COD	 , '') " + cMarca + "_O0G_COD, "
		EndIf
	EndIf

	//Carrega campos do processo auditados inclui identificador de cada marca no nome
	For nCont:=1 To Len(aCmpAudPro)
		If (aCmpAudPro[nCont][6])
			cCampos += aCmpAudPro[nCont][QUERYCAMPO] + " " + cMarca + "_" + aCmpAudPro[nCont][CAMPO] + ", "
		EndIf
	Next nCont

	//Campos que ser�o usados para pedidos e objetos
	If lSemPedObj
			cCampos += "''" + " " + cMarca + "_AUDCOD, "
			cCampos += "''" + " " + cMarca + "_PROGNO, "
			cCampos += "''" + " " + cMarca + "_NSPDESC, "
	Else
		If lPedidos
			cCampos += "O0Y_COD"    + " " + cMarca + "_AUDCOD, "
			cCampos += "O0Y_PROGNO" + " " + cMarca + "_PROGNO, "
		Else
			cCampos += "O0G_COD"  + " " + cMarca + "_AUDCOD, "
			cCampos += "NQ7_DESC" + " " + cMarca + "_PROGNO, "
		EndIf	
		cCampos += "NSP_DESC" + " " + cMarca + "_NSPDESC, "
	EndIf

	//Carrega campos do objeto auditados inclui identificador de cada marca no nome
	//Come�a na 4� posi��o, pois os 3 primeiros campos j� fora inclu�dos acima 
	For nCont:=4 To Len(aCmpAudObj) 
		cQryCampo := ""
		If (aCmpAudObj[nCont][6])
			If lSemPedObj //Para a montagem da query sem O0Y/ O0G
				cQryCampo := Iif(aCmpAudObj[nCont][TIPO] == "N", "0" ," '' ")
			Else
				//Para a montagem da query O0Y
				If lPedidos
					If aCmpAudObj[nCont][CAMPO] == "PEVLR"		
						cQryCampo := "O0Y_VPEDID "
					ElseIf aCmpAudObj[nCont][CAMPO] == "PEVLRA"		
						cQryCampo := "O0Y_VATPED "
					Else
						cQryCampo := Iif(aCmpAudObj[nCont][TIPO] == "N", "0" ," '' ")
					EndIf
				Else //Para a montagem da query O0G
					cQryCampo := aCmpAudObj[nCont][QUERYCAMPO]
				EndIf
			EndIf			
			cCampos += cQryCampo + " " + cMarca + "_" + aCmpAudObj[nCont][CAMPO] + ", "
		EndIf
	Next nCont
	
	lAudPed :=  FWAliasIndic("O0W") .And. FWAliasIndic("O0Y") 
	If lAudPed
	//Carrega campos dos pedidos auditados, inclui identificador de cada marca no nome
		For nCntCmpPed:=1 To Len(aCmpAudPed)
			cQryCampo := ""
			If (aCmpAudPed[nCntCmpPed][6])
				If lSemPedObj //Para a montagem da query sem O0Y/ O0G
					cQryCampo := Iif(aCmpAudPed[nCntCmpPed][TIPO] == "N", "0" ," '' ")
				Else				
					//Para a montagem da query O0Y
					If lPedidos
						cQryCampo := aCmpAudPed[nCntCmpPed][QUERYCAMPO]
					Else
						cQryCampo := Iif(aCmpAudPed[nCntCmpPed][TIPO] == "N", "0" ," '' ")
					EndIf
				EndIf
				cCampos += cQryCampo + " " + cMarca + "_" + aCmpAudPed[nCntCmpPed][CAMPO] + ", "
			EndIf
		Next nCntCmpPed
	EndIf

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2)

	cSql := " SELECT " + cCampos

	//Auditoria de Processo
	cSql += " FROM " + RetSqlName("O0F") + " O0F"

	//Se possuir as tabelas O0W/ O0Y
	If lAudPed 
		//Se nao for a montagem da query de processos sem auditoria de pedidos/ objetos, adiciona os joins 
		If !lSemPedObj
			If lPedidos
				//Auditoria de Pedidos
				cSql += " JOIN " + RetSqlName("O0Y") + " O0Y"
				cSql +=     " ON O0F_FILIAL = O0Y_FILIAL AND O0F_MARCA = O0Y_MARCA AND O0F_FILPRO = O0Y_FILPRO AND O0F_CAJURI = O0Y_CAJURI AND O0Y.D_E_L_E_T_ = ' '"
			Else
				//Auditoria de Objeto
				cSql += " JOIN " + RetSqlName("O0G") + " O0G"
				cSql +=     " ON O0F_FILIAL = O0G_FILIAL AND O0F_MARCA = O0G_MARCA AND O0F_FILPRO = O0G_FILPRO AND O0F_CAJURI = O0G_CAJURI AND O0G.D_E_L_E_T_ = ' '"
			EndIf
		EndIf
	Else
			//Auditoria de Objeto
			cSql += " LEFT JOIN " + RetSqlName("O0G") + " O0G"
			cSql +=     " ON O0F_FILIAL = O0G_FILIAL AND O0F_MARCA = O0G_MARCA AND O0F_FILPRO = O0G_FILPRO AND O0F_CAJURI = O0G_CAJURI AND O0G.D_E_L_E_T_ = ' '"		
	EndIf

	//Cliente auditado
	cSql += " LEFT JOIN " + RetSqlName("SA1") + " SA1"
	cSql +=     " ON A1_FILIAL = '" + xFilial("SA1") + "' AND O0F_CCLIEN = A1_COD AND O0F_LCLIEN = A1_LOJA AND SA1.D_E_L_E_T_ = ' '"

	//Area juridica
	cSql += " LEFT JOIN " + RetSqlName("NRB") + " NRB"
	cSql +=     " ON NRB_FILIAL = '" + xFilial("NRB") + "' AND O0F_CAREAJ = NRB_COD AND NRB.D_E_L_E_T_ = ' '"

	//Sub Area juridica
	cSql += " LEFT JOIN " + RetSqlName("NRL") + " NRL"
	cSql +=     " ON NRL_FILIAL = '" + xFilial("NRL") + "' AND O0F_CAREAJ = NRL_CAREA AND O0F_CSUBAR = NRL_COD AND NRL.D_E_L_E_T_ = ' '"

	//Centro de custo
	cSql += " LEFT JOIN " + RetSqlName("CTT") + " CTT"
	cSql +=     " ON " + "CTT_FILIAL = '" + xFilial("CTT") + "'"
	cSql +=    " AND O0F_CCUSTO = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' '"

	//Moeda
	cSql += " LEFT JOIN " + RetSqlName("CTO") + " CTO"
	cSql +=    " ON CTO_FILIAL = '" + xFilial("CTO") + "' AND O0F_CMOPRO = CTO_MOEDA AND CTO.D_E_L_E_T_ = ' '"

	//Motivo do Encerramento
	cSql += " LEFT JOIN " + RetSqlName("NQI") + " NQI"
	cSql +=     " ON NQI_FILIAL = '" + xFilial("NQI") + "' AND O0F_CMOENC = NQI_COD AND NQI.D_E_L_E_T_ = ' '"

	//Se nao for a montagem da query de processos sem auditoria de pedidos/ objetos, adiciona os left joins de tipo do objeto e progn�stico
	If !lSemPedObj
		//Tipo do Objeto
		cSql += " LEFT JOIN " + RetSqlName("NSP") + " NSP"
		If lPedidos		
			cSql +=     " ON NSP_FILIAL = '" + xFilial("NSP") + "' AND O0Y_CTPPED = NSP_COD AND NSP.D_E_L_E_T_ = ' '"
		Else
			cSql +=     " ON NSP_FILIAL = '" + xFilial("NSP") + "' AND O0G_CPEVLR = NSP_COD AND NSP.D_E_L_E_T_ = ' '"
		EndIf

		If !lPedidos
			//Progn�stico do Objeto
			cSql += " LEFT JOIN " + RetSqlName("NQ7") + " NQ7"
			cSql +=     " ON NQ7_FILIAL = '" + xFilial("NQ7") + "' AND O0G_CPROG = NQ7_COD AND NQ7.D_E_L_E_T_ = ' '"
		EndIf
	EndIf

	If Type("MV_PAR03") != "U" .AND. !Empty(MV_PAR03) //valida se informou a area
		cSql += " JOIN " + RetSqlName("NSZ") + " NSZ"
		cSql +=     " ON NSZ_FILIAL = O0F.O0F_FILPRO AND O0F_CAJURI = NSZ_COD AND NSZ.D_E_L_E_T_ = ' ' AND NSZ.NSZ_TIPOAS = '" + MV_PAR03 + "'"
	Endif

	cSql += " WHERE "
	cSql +=     " O0F_FILIAL = '" + xFilial("O0F") + "' AND "
	cSql +=     " O0F_MARCA  = '" + DtoS(dMarca) + "' AND "
	cSql +=     " O0F.D_E_L_E_T_ = ' '"
	If lAudPed .And. lSemPedObj
		cSql += " AND NOT EXISTS ( "
		cSql +=     " SELECT 1 FROM " + RetSqlName("O0G") +" O0G"
		cSql +=              " WHERE O0F_FILIAL = O0G_FILIAL "
		cSql +=              " AND O0F_MARCA = O0G_MARCA "
		cSql +=              " AND O0F_FILPRO = O0G_FILPRO "
		cSql +=              " AND O0F_CAJURI = O0G_CAJURI "
		cSql +=              " AND O0G.D_E_L_E_T_ = ' ' "
		cSql += " ) "
		cSql += " AND NOT EXISTS ( "
		cSql +=     " SELECT 1 FROM " + RetSqlName("O0Y") +" O0Y"
		cSql +=              " WHERE O0F_FILIAL = O0Y_FILIAL "
		cSql +=              " AND O0F_MARCA = O0Y_MARCA "
		cSql +=              " AND O0F_FILPRO = O0Y_FILPRO "
		cSql +=              " AND O0F_CAJURI = O0Y_CAJURI "
		cSql +=              " AND O0Y.D_E_L_E_T_ = ' ' "
		cSql += " ) "
	EndIf
Return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataCampo()
Formata o campo para a apresenta��o no arquivo

@author  Rafael Tenorio da Costa
@since 	 16/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TrataCampo(xConteudo, aCampo)
Local cTipo	   := aCampo[TIPO]
Local cMascara := aCampo[MASCARA]

	Do Case
		//Caractere ou Memo
		Case cTipo $ "C|M"
			If cTipo == "M"
				xConteudo := Left(xConteudo, 500)
				xConteudo := StrTran(xConteudo, "<p>" , "" )
				xConteudo := StrTran(xConteudo, "</p>", "" )
				xConteudo := StrTran(xConteudo, "<br>", " ")
			EndIf

			xConteudo := AllTrim(xConteudo)

			If !Empty(cMascara) .And. !Empty(xConteudo)
				xConteudo := Transform(xConteudo, cMascara)
			EndIf

		//Numero
		Case cTipo == "N"
			xConteudo := IIF(Empty(xConteudo), 0, xConteudo)

		//4-DateTime
		OtherWise
			If !Empty(xConteudo)
				xConteudo := StoD(xConteudo)
			EndIf
	End Case
Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} IncCmpsCom
Inclui campos complementares auditados na linha.

@author  Rafael Tenorio da Costa
@since 	 18/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IncCmpsCom(aLinha, aColCmpCom, cFilPro, cCajuri)
Local nCmpsCom   := 1
Local cChaveO0F  := ""
Local xContMar1  := ""
Local xContMar2	 := ""
Local nQtdCmpCom := Len(aColCmpCom)
Local nTamChv 	 := TamSx3("O0C_CHVAUD")[1]

	O0C->( DbSetOrder(1) )	//O0C_FILIAL+DTOS(O0C_MARCA)+O0C_ENTAUD+O0C_CODAUD+O0C_CMPFOR

	//Campos complementares
	For nCmpsCom:=1 To nQtdCmpCom

		xContMar1 := ""
		xContMar2 := ""

		cChaveO0F := PadR(xFilial("O0F") + DTOS(MV_PAR01) + cFilPro + cCajuri, nTamChv)
		If O0C->( DbSeek(xFilial("O0C") + DTOS(MV_PAR01) + "O0F" + cChaveO0F + aColCmpCom[nCmpsCom][CAMPO]) )	//O0C_FILIAL+DTOS(O0C_MARCA)+O0C_ENTAUD+O0C_CHVAUD+O0C_CMPFOR
			xContMar1 := AllTrim( Left(O0C->O0C_VALOR, 500) )
		EndIf

		cChaveO0F := PadR(xFilial("O0F") + DTOS(MV_PAR02) + cFilPro + cCajuri, nTamChv)
		If O0C->( DbSeek(xFilial("O0C") + DTOS(MV_PAR02) + "O0F" + cChaveO0F + aColCmpCom[nCmpsCom][CAMPO]) )	//O0C_FILIAL+DTOS(O0C_MARCA)+O0C_ENTAUD+O0C_CHVAUD+O0C_CMPFOR
			xContMar2 := AllTrim( Left(O0C->O0C_VALOR, 500))
		EndIf

		xContMar1 := TrataCampo(xContMar1, aColCmpCom[nCmpsCom])
		xContMar2 := TrataCampo(xContMar2, aColCmpCom[nCmpsCom])

		Aadd(aLinha, xContMar1)
		Aadd(aLinha, xContMar2)
	Next nCmpsCom

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IncCmpsVal()
Inclui campos de valores objetos, garantias e despesas na linha.

@param aLinha  - Linhas que ser�o inclu�das no relat�rio.
@param cTabela - Tabela para busca de dados.
@param aColVal - Colunas que ser�o preenchidas no excel.
@param cFilPro - Filial do processo para busca de dados.
@param cCajuri - C�digo do processo para busca de dados.

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IncCmpsVal(aLinha, cTabela, aColVal, cFilPro, cCajuri)

Local aMarcas	:= {DtoS(MV_PAR01), DtoS(MV_PAR02)}
Local cTipoVal	:= ""
Local cSql      := ""
Local xContMar1 := 0
Local xContMar2 := 0
Local nPosVal	:= 0
Local nSumGarM1 := 0
Local nSumGarM2 := 0
Local nI        := 1
Local nCont     := 1
Local aSql      := {}

	/*DEFINI��O aValores \ aGarantias \ aDespesa
		Filial
		Cajuri
		Marca
		C�digo do Tipo
		Descri��o do Tipo
		Valor
		Valor Atualizado
	*/

	Do Case

		Case cTabela == "NT2"

			cSql := " SELECT O0H_MARCA, O0H_CTPGAR, O0H_VLRATU, O0H_VALOR"
			cSql += " FROM " + RetSqlName("O0H")
			cSql += " WHERE O0H_FILIAL = '" + xFilial("O0H") + "' AND"
			cSql += 	 " (O0H_MARCA = '" + aMarcas[1] + "' OR O0H_MARCA = '" + aMarcas[2] + "') AND"
			cSql += 	 " O0H_FILPRO = '" + cFilPro  + "' AND"
			cSql += 	 " O0H_CAJURI = '" + cCajuri  + "' AND"
			cSql += 	 " D_E_L_E_T_ = ' '"
			cSql += " ORDER BY O0H_MARCA, O0H_CTPGAR"

		Case cTabela == "NT3"

			cSql := " SELECT O0I_MARCA, O0I_CTPDES, SUM(O0I_VALOR) O0I_VALOR"
			cSql += " FROM " + RetSqlName("O0I")
			cSql += " WHERE O0I_FILIAL = '" + xFilial("O0I") + "' AND"
			cSql += 	 " (O0I_MARCA = '" + aMarcas[1] + "' OR O0I_MARCA = '" + aMarcas[2] + "') AND"
			cSql += 	 " O0I_FILPRO = '" + cFilPro  + "' AND"
			cSql += 	 " O0I_CAJURI = '" + cCajuri  + "' AND"
			cSql += 	 " O0I_VALOR > 0 AND"
			cSql += 	 " D_E_L_E_T_ = ' '"
			cSql += " GROUP BY O0I_MARCA, O0I_CTPDES"
			cSql += " ORDER BY O0I_MARCA, O0I_CTPDES"

	End Case

	aSql := JurSQL(cSql, "*")

	//Preenche as colunas de valores das marcas
	For nCont:=1 To Len(aColVal)

		nPosVal	  := 0
		nSumGarM1 := 0
		nSumGarM2 := 0
		xContMar1 := 0
		xContMar2 := 0
		cTipoVal  := aColVal[nCont][1]

		If Len(aSql) > 0

			If cTabela == "NT2"
				For nI:=1 To Len(aSql)
					// Soma os valores da marca 1
					If aSql[nI][1] == aMarcas[1] .And. aSql[nI][2] == cTipoVal
						nSumGarM1 += aSql[nI][3]
					EndIf
					// Soma os valores da marca 2
					If aSql[nI][1] == aMarcas[2] .And. aSql[nI][2] == cTipoVal
						nSumGarM2 += aSql[nI][3]
					EndIf
				Next nI

				xContMar1 := nSumGarM1
				xContMar2 := nSumGarM2
			Else // NT3
				If ( nPosVal := Ascan(aSql, {|x| x[1] == aMarcas[1] .And. x[2] == cTipoVal}) ) > 0
					xContMar1 := aSql[nPosVal][3]
				EndIf
				
				If ( nPosVal := Ascan(aSql, {|x| x[1] == aMarcas[2] .And. x[2] == cTipoVal}) ) > 0
					xContMar2 := aSql[nPosVal][3]
				EndIf
			EndIf
		EndIf

		Aadd(aLinha, xContMar1)
		Aadd(aLinha, xContMar2)
	Next nCont

	//Limpa memoria
	FwFreeObj(aMarcas)
	FwFreeObj(aSql)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvArquivo()
Grava arquivo.
@param oExcel     Objeto FWMsExcelEx / FWMsExcelXLSX
@param lZip       Indica se o arquivo ser� zipado ou n�o

@author  Rafael Tenorio da Costa
@since 	 09/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GrvArquivo(oExcel, lZip, lXlsx)
Local cDirTemp  := "\SPOOL\"                                //Caminho onde o arquivo ser� gerado no servidor
Local cArqTmp   := STR0008 + "_" + JurTimeStamp(1) + ".xls" //"Auditoria"
Local cExtens   := STR0068 + " ZIP | *.zip"                 //"Arquivo"
Local lHtml     := ( GetRemoteType() == 5 )                 //Valida se o ambiente � SmartClientHtml
Local cArq	    := ""
Local cDirDest  := ""
Local nErro     := 0
Local cErro     := ""
Local lLinux    := "Linux" $ GetSrvInfo()[2]
Local lAutomato := JurAuto()
Local cFunction := "CpyS2TW"
Local cNomeMod  := "Modelo_Auditoria_01.xls"
Local lCopied   := .F.

	If !lZip
		 cExtens   := STR0068 + " XLSX | *.xlsx"
	EndIf

	If !ExistDir(cDirTemp)
		cErro := I18n(STR0067, {cDirTemp})//"Pasta #1 n�o encontrada, n�o ser� poss�vel gerar o arquivo"
	Else
		//Salva arquivo na pasta temporaria
		oExcel:Activate()
	
		If lAutomato
			If !lZip
				cNomeMod := Iif(lXlsx,StrTran(cNomeMod, ".xls", ".xlsx"), cNomeMod)
			EndIf

			oExcel:GetXmlFile(cDirTemp + cNomeMod)

		Else
			If lZip
				oExcel:GetXmlFile(cDirTemp + cArqTmp)

				If !File(cDirTemp + cArqTmp)
					cErro := I18n(STR0094, {cDirTemp + cArqTmp}	) + CRLF //"Arquivo n�o foi salvo: #1"
							I18n(STR0095, {"oExcel:GetXmlFile"})        //"Metodo #1, n�o salvou o arquivo"
				Else
					//Escolha o local para salvar o arquivo
					If !lHtml
						While Empty(cArq)
							cArq := cGetFile(cExtens, STR0066, , 'C:\', .F., nOr(GETF_LOCALHARD,GETF_NETWORKDRIVE), .F.) //"Escolha o local para salvar o arquivo"
						EndDo
					ElseIf lHtml
						cArq := cDirTemp + StrTran(cArqTmp, ".xls", ".zip")
					Endif

					cDirDest := SubStr(cArq, 1, Rat("\", cArq))
					cArq     := StrTran(cArq + ".zip", ".zip.zip", ".zip")
					cArq     := SubStr(cArq, Rat("\", cArq) + 1)

					//Zipa o arquivo
					If FZip(cDirTemp + cArq, {cDirTemp + cArqTmp}, cDirTemp) == 0
						//Se n�o for html, copia para o sistema de arquivos locais
						If !lHtml
							//Copia o arquivo do diretorio temporario para a m�quina do usuario
							If !CpyS2T(cDirTemp + cArq, cDirDest)
								nErro := FError()
								cErro := I18n( STR0096, {"CpyS2T() " + cValToChar(nErro) + " - " + J026aErrAr(nErro)} ) //"N�o foi poss�vel copiar arquivo do servidor: #1"
							EndIf
						EndIf
					Else
						nErro := FError()
						cErro := I18n( STR0097, {"FZip() " + cValToChar(nErro) + " - " + J026aErrAr(nErro)} ) //"N�o foi poss�vel zipar arquivo: #1"
					EndIf

					//Abre arquivo local ou envia para download quando smartclienthtml
					If ( Empty(cErro) )
						J112AbreArq(cDirDest + cArq, STR0008) //"Auditoria"
					EndIf
				EndIf
			Else
				//Escolha o local para salvar o arquivo
				If !lHtml
					While Empty(cArq)
						cArq := cGetFile(cExtens, STR0066, , 'C:\', .F., nOr(GETF_LOCALHARD,GETF_NETWORKDRIVE), .F.) //"Escolha o local para salvar o arquivo"
					EndDo
				Else
					cArq := cDirTemp + cArqTmp
				EndIf

				// Tratamento para S.O Linux
				If lLinux
					cArq := StrTran(cArq,"\","/")
					cDirTemp := StrTran(cDirTemp,"\","/")
				Endif

				If ExistDir(cDirTemp) //valida se o arquivo tem nome e se o diret�rio existe.

					//Separa o nome do arquivo do caminho completo
					cNomeTmp := SubStr(cArq,Rat(IF(!lLinux,"\","/"),cArq)+1)

					//nome do arquivo criado no servidor, temporariamente
					cDirTemp := cDirTemp + cNomeTmp

					//Separa o diret�rio de destino da m�quina do usu�rio
					cDirDest := SubStr(cArq,1,Rat(IF(!lLinux,"\","/"),cArq))

					oExcel:GetXmlFile(cDirTemp)
					
					If File(cDirTemp)
						//Se n�o for html, copia para o sistema de arquivos locais
						
						If !lHtml
							If lAutomato
								lCopied := __copyfile( cDirTemp,  cDirDest + cNomeTmp ) //copia o arquivo local
							Else
								//Copia o arquivo do diretorio temporario para a m�quina do usuario
								lCopied := CpyS2T(cDirTemp, cDirDest)
							EndIf
							If !lCopied
								nErro := FError()
								cErro := I18n( STR0096, {"CpyS2T() " + cValToChar(nErro) + " - " + J026aErrAr(nErro)} ) //"N�o foi poss�vel copiar arquivo do servidor: #1"
							EndIf
						ElseIf FindFunction(cFunction)
							//Executa o download no navegador do cliente
							&(cFunction+'("'+cDirTemp+'")')
						Endif

					

					EndIf

					//Abre arquivo local ou envia para download quando smartclienthtml
					If ( Empty(cErro) )
						J112AbreArq(cDirDest+ cNomeTmp, STR0008) //"Auditoria"
					EndIf
				Else
					JurMsgErro(STR0122)//"N�o foi poss�vel gerar a exporta��o da auditoria. Verifique junto a equipe t�cnica se a pasta SPOOL existe no diret�rio Protheus_Data"
				EndIf

			EndIf
			//Apaga arquivos temporarios
			FErase(cDirTemp + cArq)
			FErase(cDirTemp + cArqTmp)
		EndIf
	EndIf

	If !Empty(cErro)
		JurMsgErro(cErro)
	EndIf
Return Nil
