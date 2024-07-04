#INCLUDE "QNCA030.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} QNCA330()
Cadastro de Plano de ação
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function QNCA330()
	Local cFilPend   := GETMV("MV_QNCPACO")
	Local lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.) //Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
	Local lQNC030Fil := ExistBlock("QNC030Fil")
	Local cFiltraQI3 := ""
	Local cFil       := "" 
	
	Private oBrowse
	Private lRevisao := .F.
	Private lFunFNC  := .F.
	Private lAltEta  := .F.
	Private cMotivo  := ""
	Private lModFNC  := .F.
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QI3")
	QI3->(DbSetOrder(1))
	
	If !lTMKPMS
		oBrowse:AddLegend("QI3->QI3_OBSOL=='S'"    , "BR_PRETO" , STR0053 ) // "Plano de Acao Obsoleto"
		oBrowse:AddLegend("!Empty(QI3->QI3_ENCREA)", "ENABLE"   , STR0046 ) // "Plano de Acao Baixado"
		oBrowse:AddLegend("QI3->QI3_STATUS=='5'"   , "BR_MARROM", STR0083 ) // "Cancelada"
		oBrowse:AddLegend("QI3->QI3_STATUS=='4'"   , "BR_CINZA" , STR0082 ) // "Nao-Procede"
		oBrowse:AddLegend("Empty(QI3->QI3_ENCREA)" , "DISABLE"  , STR0047 ) // "Plano de Acao Pendente"
	Else
		If (GetMv("MV_QTMKPMS",.F.,1) == 3) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
			oBrowse:AddLegend("Q030VldLeg() == 1", "BR_PRETO"   , STR0053 ) // "Plano de Acao Obsoleto"
			oBrowse:AddLegend("Q030VldLeg() == 2", "BR_AMARELO" , STR0047 ) // "Plano de Acao Pendente"
			oBrowse:AddLegend("Q030VldLeg() == 3", "BR_CINZA"   , STR0082 ) // "Nao-Procede"
			oBrowse:AddLegend("Q030VldLeg() == 4", "BR_MARROM"  , STR0083 ) // "Cancelada"
			oBrowse:AddLegend("Q030VldLeg() == 5", "ENABLE"     , STR0046 ) // "Plano de Acao Baixado"
			oBrowse:AddLegend("Q030VldLeg() == 6", "BR_LARANJA" , STR0097 ) // "Plano de Acao s/Projeto/EDT"
			oBrowse:AddLegend("Q030VldLeg() == 7", "BR_PINK"    , STR0112 ) // "Plano de Acao Rejeitado"
		Else
			oBrowse:AddLegend("QI3->QI3_OBSOL=='S'"    , "BR_PRETO"   , STR0053 ) // "Plano de Acao Obsoleto"
			oBrowse:AddLegend("Empty(QI3->QI3_ENCREA)" , "BR_AMARELO" , STR0047 ) // "Plano de Acao Pendente"
			oBrowse:AddLegend("QI3->QI3_STATUS=='4'"   , "BR_CINZA"   , STR0082 ) // "Nao-Procede"
			oBrowse:AddLegend("QI3->QI3_STATUS=='5'"   , "BR_MARROM"  , STR0083 ) // "Cancelada"
			oBrowse:AddLegend("!Empty(QI3->QI3_ENCREA)", "ENABLE"     , STR0046 ) // "Plano de Acao Baixado"
		Endif
	EndIf

	IF ExistBlock( "QNCSMACO" )
		ExecBlock( "QNCSMACO", .f., .f. )
	Endif

	If cFilPend == "S"
		cFiltraQI3 := " QI3_ENCREA = '"+SPACE(TAMSX3("QI3_ENCREA")[1])+"'"
	Endif
	
	If lQNC030Fil 
		IF VALTYPE(cFil := ExecBlock( "QNC030Fil", .F., .F.)) == "C"
			cFiltraQI3 += " .And. " + cFil
		ENDIF     
	EndIf
	
	If ExistBlock("QNC030ROT")
		aRotAdic := ExecBlock("QNC030ROT", .F., .F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf	
	
	oBrowse:SetDescription(STR0006) //"Cadastro de Plano de Acao"
	oBrowse:SetFilterDefault(cFiltraQI3)
	oBrowse:Activate()
	
	If Select("QNSXE") > 0
		QNSXE->(dbCloseArea())
	Endif
	
	If Select("QNSXF") > 0
		QNSXF->(dbCloseArea())
	Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina  := {}
	Local cFilPend := GETMV("MV_QNCPACO")
	
	ADD OPTION aRotina TITLE  STR0001  ACTION 'AxPesqui'     		OPERATION 1                      ACCESS 0 //Pesquisar
	ADD OPTION aRotina TITLE  STR0002  ACTION 'VIEWDEF.QNCA330' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE  STR0003  ACTION 'QNC330Alt'				OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE  STR0004  ACTION 'QNC330Alt'       OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE  STR0005  ACTION 'QNC330Alt'	    	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //Excluir
	ADD OPTION aRotina TITLE  STR0032  ACTION 'QNC330Rev'	 			OPERATION 9                      ACCESS 0 //Gera Revisao
	If cFilPend == "N"
		ADD OPTION aRotina TITLE  STR0042  ACTION 'QNC330Sel' OPERATION 6 ACCESS 0 //Muda seleção
	Endif
	ADD OPTION aRotina TITLE  STR0048  ACTION 'QNCA330IMP' OPERATION 6                      ACCESS 0 //Imprime
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := Nil
	Local oStruQI3   := FWFormStruct(1,"QI3")
	Local oStruCab   := FWFormModelStruct():New()
	Local oStruQI4   := FWFormStruct(1,"QI4")
	Local oStruQI5   := FWFormStruct(1,"QI5")
	Local oStruQI6   := FWFormStruct(1,"QI6")
	Local oStruQI7   := FWFormStruct(1,"QI7")
	Local oStruQI8   := FWFormStruct(1,"QI8")
	Local oStruQI9   := FWFormStruct(1,"QI9")
	Local oStruQIE   := FWFormStruct(1,"QIE")
	Local oEvent     := QNCA330EVDEF():New()
	Local aUsrMat    := QNCUSUARIO()
	
	If Type("lRevisao") != "L"
		Private lRevisao := .F.
	EndIf
	
	oStruQI5:AddField( ;           			// Ord. Tipo Desc.
	                   "", ;       			// [01] C Titulo do campo
	                   "", ; 	   			// [02] C ToolTip do campo
	                   "QI5_OK", ;          // [03] C identificador (ID) do Field
	                   'C' , ;              // [04] C Tipo do campo
	                   13, ;       			// [05] N Tamanho do campo
	                   0 , ;                // [06] N Decimal do campo
	                   NIL, ;               // [07] B Code-block de validação do campo
	                   {|| .F.}, ;          // [08] B Code-block de validação When do campo
	                   , ;                  // [09] A Lista de valores permitido do campo
	                   .F., ;               // [10] L Indica se o campo tem preenchimento obrigatório
	                    {||"BR_LARANJA"}, ; // [11] B Code-block de inicializacao do campo
	                   .F., ;               // [12] L Indica se trata de um campo chave
	                   .T., ;               // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                // [14] L Indica se o campo é virtual
	
	oStruCab:AddField( ;           								  // Ord. Tipo Desc.
	                   GetSX3Cache("QI3_CODIGO", "X3_TITULO"), ;  // [01] C Titulo do campo
	                   GetSX3Cache("QI3_CODIGO", "X3_DESCRIC"), ; // [02] C ToolTip do campo
	                   "QIX_CODIGO", ;          				  // [03] C identificador (ID) do Field
	                   'C' , ;                     				  // [04] C Tipo do campo
	                   TAMSX3("QI3_CODIGO")[1], ;       		  // [05] N Tamanho do campo
	                   0 , ;                					  // [06] N Decimal do campo
	                   NIL, ;               					  // [07] B Code-block de validação do campo
	                   {|| .F.}, ;          					  // [08] B Code-block de validação When do campo
	                   , ;                  					  // [09] A Lista de valores permitido do campo
	                   .F., ;               					  // [10] L Indica se o campo tem preenchimento obrigatório
	                    {||QI3->QI3_CODIGO}, ; 					  // [11] B Code-block de inicializacao do campo
	                   .F., ;               					  // [12] L Indica se trata de um campo chave
	                   .T., ;               					  // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                					  // [14] L Indica se o campo é virtual
	
	oStruCab:AddField( ;           							   // Ord. Tipo Desc.
	                   GetSX3Cache("QI3_REV", "X3_TITULO"), ;  // [01] C Titulo do campo
	                   GetSX3Cache("QI3_REV", "X3_DESCRIC"), ; // [02] C ToolTip do campo
	                   "QIX_REV", ;          				   // [03] C identificador (ID) do Field
	                   'C' , ;                                 // [04] C Tipo do campo
	                   TAMSX3("QI3_REV")[1], ;       		   // [05] N Tamanho do campo
	                   0 , ;                                   // [06] N Decimal do campo
	                   NIL, ;                                  // [07] B Code-block de validação do campo
	                   {|| .F.}, ;                             // [08] B Code-block de validação When do campo
	                   , ;                                     // [09] A Lista de valores permitido do campo
	                   .F., ;                                  // [10] L Indica se o campo tem preenchimento obrigatório
	                    {||QI3->QI3_REV}, ;                      // [11] B Code-block de inicializacao do campo
	                   .F., ;                                  // [12] L Indica se trata de um campo chave
	                   .T., ;                                  // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                                   // [14] L Indica se o campo é virtual

	oStruQI3:SetProperty("QI3_OBSOL" , MODEL_FIELD_INIT, {||"N"})
	oStruQI3:SetProperty("QI3_FILMAT", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[2],)})
	oStruQI3:SetProperty("QI3_MAT"   , MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[3],)})
	oStruQI3:SetProperty("QI3_ANO"   , MODEL_FIELD_INIT, {||IIF(!IsBlind(),QncInitAno("QI3", "QI3MASTER"),)})
	oStruQI3:SetProperty("QI3_CODIGO", MODEL_FIELD_INIT, {||IIF(!IsBlind(),GETNEXTNUM(StrZero(Year(dDataBase),4)),)})
	oStruQI3:SetProperty("QI3_NUSR"  , MODEL_FIELD_INIT, {||IIF(!IsBlind(),IF(Empty(QI3->QI3_FILMAT), QA_NUSR(aUsrMat[2],aUsrMat[3],.T.), QA_NUSR(QI3->QI3_FILMAT, QI3->QI3_MAT)),)})
	oStruQI3:SetProperty("QI3_DESCMD", MODEL_FIELD_INIT, {||IIF(!IsBlind(),Q330DesQIB(),)})
	oStruQI3:SetProperty("QI3_NOMCLI", MODEL_FIELD_INIT, {||IIF(!IsBlind(),Q330DesCli(),)})

	oStruQI3:SetProperty("QI3_FILMAT", MODEL_FIELD_VALID, MTBlcVld("QI3", "QI3_FILMAT", "QAChkFil('QI3_FILMAT', 'QI3MASTER')",.F.,.F. ))
	oStruQI3:SetProperty("QI3_MAT"   , MODEL_FIELD_VALID, MTBlcVld("QI3", "QI3_MAT"   , "VldChkMat('QI3', 'QI3MASTER', 'QI3_FILMAT', 'QI3_MAT')",.F.,.F. ))

	oStruQI3:SetProperty("QI3_STATUS", MODEL_FIELD_WHEN, {||QNC330Stat()})
	oStruQI3:SetProperty("QI3_CODIGO", MODEL_FIELD_WHEN, {||.T.})
	oStruQI3:SetProperty("QI3_ANO"   , MODEL_FIELD_WHEN, {||IsBlind()})

	oStruQI3:SetProperty("QI3_MEMO1" , MODEL_FIELD_OBRIGAT, !IsBlind())

	If lRevisao
		oStruQI3:SetProperty("QI3_CODIGO", MODEL_FIELD_INIT, {||QI3->QI3_CODIGO})
		oStruQI3:SetProperty("QI3_REV"   , MODEL_FIELD_INIT, {||StrZero(Val(QI3->QI3_REV)+1, 2)})
		oStruQI3:SetProperty("QI3_ABERTU", MODEL_FIELD_INIT, {||dDataBase})
		oStruQI3:SetProperty("QI3_ENCPRE", MODEL_FIELD_INIT, {||dDatabase+30})
		oStruQI3:SetProperty("QI3_ENCREA", MODEL_FIELD_INIT, {||Ctod("  /  /  ")})
		oStruQI3:SetProperty("QI3_OBSOL" , MODEL_FIELD_INIT, {||"N"})
		oStruQI3:SetProperty("QI3_STATUS", MODEL_FIELD_INIT, {||"1"})
		oStruQI3:SetProperty("QI3_MEMO7" , MODEL_FIELD_OBRIGAT, .T.)
	ElseIf !Empty(M->QI3_MEMO7)
		oStruQI3:SetProperty("QI3_CODIGO", MODEL_FIELD_INIT, {||QI3->QI3_CODIGO}) //ws
		oStruQI3:SetProperty("QI3_MEMO7" , MODEL_FIELD_OBRIGAT, .T.)
	EndIf

	oStruQI3:AddTrigger("QI3_MODELO", "QI3_MODELO", {||.T.}, {||Q330Modelo()})

	oStruQI5:SetProperty("QI5_SEQ", MODEL_FIELD_INIT, {||""})
	oStruQI6:SetProperty("QI6_SEQ", MODEL_FIELD_INIT, {||""})
	oStruQI7:SetProperty("QI7_SEQ", MODEL_FIELD_INIT, {||""})
	oStruQI8:SetProperty("QI8_SEQ", MODEL_FIELD_INIT, {||""})

	oStruQI5:SetProperty("QI5_SEQ", MODEL_FIELD_WHEN, {||IsBlind()})
	oStruQI6:SetProperty("QI6_SEQ", MODEL_FIELD_WHEN, {||IsBlind()})
	oStruQI7:SetProperty("QI7_SEQ", MODEL_FIELD_WHEN, {||IsBlind()})
	oStruQI8:SetProperty("QI8_SEQ", MODEL_FIELD_WHEN, {||IsBlind()})
	
	oStruQI4:SetProperty("QI4_MAT"   , MODEL_FIELD_VALID, MTBlcVld("QI4", "QI4_MAT"   , "VldChkMat('QI4', 'QI4DETAIL', 'QI4_FILMAT', 'QI4_MAT')",.F.,.F. ))
	
	oStruQI5:SetProperty("QI5_MAT"   , MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_MAT"   , "VldChkMat('QI5', 'QI5DETAIL', 'QI5_FILMAT', 'QI5_MAT') .and. QNC330VLETP('M->QI5_MAT')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_PRAZO" , MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_PRAZO" , "Naovazio() .And. QNC330VLETP('M->QI5_PRAZO')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_REALIZ", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_REALIZ", "QNC330VLETP('M->QI5_REALIZ')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_GRAGR" , MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_GRAGR" , "Vazio() .Or. ExistCpo('QUO',M->QI5_GRAGR) .And. QNC330VLETP('M->QI5_GRAGR')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_OBRIGA", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_OBRIGA", "Pertence('12') .And. QNC330VLETP('M->QI5_OBRIGA')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_PRZHR" , MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_PRZHR" , "QaVlHrMvc('QI5', 'QI5DETAIL', 'QI5_PRZHR') .And. QNC330VLETP('M->QI5_PRZHR')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_PROJET", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_PROJET", "QNC330VlPJ() .And. QNC330VLETP('M->QI5_PROJET')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_REVISA", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_REVISA", "QNC330VLETP('M->QI5_REVISA')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_PRJEDT", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_PRJEDT", "QNC330VlPJ() .And. QNC330VLETP('M->QI5_PRJEDT')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_TAREFA", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_TAREFA", "QNC330VLETP('M->QI5_TAREFA')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_REALHR", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_REALHR", "Vazio() .Or. QaVlHrMvc('QI5', 'QI5DETAIL', 'QI5_REALHR') .And. QNC330VLETP('M->QI5_REALHR')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_TRFACT", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_TRFACT", "Pertence('0123') .And. QNC330VLETP('M->QI5_TRFACT')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_STATUS", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_STATUS", "Naovazio() .And. QNC330VLeg() .And. QNC330St()",.F.,.F. ))

	oStruQI5:SetProperty("QI5_DESCRE", MODEL_FIELD_WHEN, {||If(IsBlind(), .T., Q330VldAlt())})
	oStruQI5:SetProperty("QI5_MEMO1" , MODEL_FIELD_WHEN, {||If(IsBlind(), .T., Q330VldAlt())})
	oStruQI5:SetProperty("QI5_MEMO2" , MODEL_FIELD_WHEN, {||If(IsBlind(), .T., Q330VldAlt())})
	oStruQI5:SetProperty("QI5_TPACAO", MODEL_FIELD_WHEN, {||If(IsBlind(), .T., !Q330AltEta())})
	oStruQI5:SetProperty("QI5_FILMAT", MODEL_FIELD_WHEN, {||If(IsBlind(), .T., !Q330AltEta())})
	oStruQI5:SetProperty("QI5_MAT"   , MODEL_FIELD_WHEN, {||If(IsBlind(), .T., !Q330AltEta())})
	oStruQI5:SetProperty("QI5_PRAZO" , MODEL_FIELD_WHEN, {||If(IsBlind(), .T., !Q330AltEta())})
	oStruQI5:SetProperty("QI5_REALIZ", MODEL_FIELD_WHEN, {||If(IsBlind(), .T., !Q330AltEta())})
	oStruQI5:SetProperty("QI5_STATUS", MODEL_FIELD_WHEN, {||If(IsBlind(), .T., !Q330AltEta())})
	
	oStruQI5:SetProperty("QI5_MEMO1" , MODEL_FIELD_OBRIGAT, .F.)
	
	oStruQI4:SetProperty("QI4_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
	oStruQI4:SetProperty("QI4_REV"   , MODEL_FIELD_OBRIGAT, .F.)
	oStruQI5:SetProperty("QI5_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
	oStruQI5:SetProperty("QI5_REV"   , MODEL_FIELD_OBRIGAT, .F.)
	oStruQI6:SetProperty("QI6_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
	oStruQI6:SetProperty("QI6_REV"   , MODEL_FIELD_OBRIGAT, .F.)
	oStruQI7:SetProperty("QI7_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
	oStruQI7:SetProperty("QI7_REV"   , MODEL_FIELD_OBRIGAT, .F.)
	oStruQI8:SetProperty("QI8_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
	oStruQI8:SetProperty("QI8_REV"   , MODEL_FIELD_OBRIGAT, .F.)
	oStruQI9:SetProperty("QI9_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
	oStruQI9:SetProperty("QI9_REV"   , MODEL_FIELD_OBRIGAT, .F.)
	oStruQIE:SetProperty("QIE_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
	oStruQIE:SetProperty("QIE_REV"   , MODEL_FIELD_OBRIGAT, .F.)
	
	oStruQI4:SetProperty("QI4_FILMAT", MODEL_FIELD_VALID, MTBlcVld("QI4", "QI4_FILMAT", "QAChkFil('QI4_FILMAT', 'QI4DETAIL')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_MEMO1" , MODEL_FIELD_INIT, {||IIF(!IsBlind(),QN030INIMEM(QI5->QI5_DESCCO),"TESTE MEMO1")})
	oStruQI5:SetProperty("QI5_MEMO2" , MODEL_FIELD_INIT, {||IIF(!IsBlind(),QN030INIMEM(QI5->QI5_DESCOB),"TESTE MEMO2")})
	oStruQI4:SetProperty("QI4_FILMAT", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[2],)})
	oStruQI4:SetProperty("QI4_NUSR"  , MODEL_FIELD_INIT, {||IIF(!IsBlind(),QA_NUSR(QI4->QI4_FILMAT, QI4->QI4_MAT),)})

	oStruQI5:SetProperty("QI5_FILMAT", MODEL_FIELD_VALID, MTBlcVld("QI5", "QI5_FILMAT", "QAChkFil('QI5_FILMAT', 'QI5DETAIL')",.F.,.F. ))
	oStruQI5:SetProperty("QI5_FILMAT", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[2],)})
	
	oStruQI6:SetProperty("QI6_NCAUSA", MODEL_FIELD_INIT , {||IIF(!IsBlind(),Q330NCAU(),)})
	oStruQI6:SetProperty("QI6_NCAUSA", MODEL_FIELD_VALID, MTBlcVld("QI6", "QI6_NCAUSA", ".T.",.F.,.F. ))

	oStruQI7:SetProperty("QI7_DESCT" , MODEL_FIELD_INIT, {||IIF(!IsBlind(),Padr(FQNCDSX5("QC",QI7->QI7_TPDOC),TamSX3("QI7_DESCT")[1]),)})
	oStruQI7:SetProperty("QI7_TITULO", MODEL_FIELD_INIT, {||IIF(!IsBlind(),QN030TITDC(),)})

	oStruQI7:SetProperty("QI7_RV"    , MODEL_FIELD_WHEN, {||.T.})
	
	oStruQI8:SetProperty("QI8_DESCC" , MODEL_FIELD_INIT, {||IIF(!IsBlind(),Padr(FQNCDSX5("QB",QI8->QI8_CUSTO),TamSX3("QI8_DESCC")[1]),)})
	
	oStruQI9:SetProperty("QI9_DESRES", MODEL_FIELD_INIT, {||IIF(!IsBlind(),Q030IniFNC(QI9->QI9_FNC, QI9->QI9_REVFNC),)})

	oStruQI9:SetProperty("QI9_CODIGO", MODEL_FIELD_VALID, MTBlcVld("QI9", "QI9_CODIGO", ".T.",.F.,.F. ))
	oStruQI9:SetProperty("QI9_REV"   , MODEL_FIELD_VALID, MTBlcVld("QI9", "QI9_REV"   , "Q330ChkAca()",.F.,.F. ))
	oStruQI9:SetProperty("QI9_FNC"   , MODEL_FIELD_VALID, MTBlcVld("QI9", "QI9_FNC"   , ".T.",.F.,.F. )) 
	oStruQI9:SetProperty("QI9_REVFNC", MODEL_FIELD_VALID, MTBlcVld("QI9", "QI9_REVFNC", ".T.",.F.,.F. ))
	
	oStruQIE:SetProperty("QIE_TIPO"  , MODEL_FIELD_WHEN, {||IIF(!IsBlind(),QNCAltAnex("QIE", "QI3MASTER"),.T.)}) 
	oStruQIE:SetProperty("QIE_DESCR" , MODEL_FIELD_WHEN, {||IIF(!IsBlind(),QNCAltAnex("QIE", "QI3MASTER"),.T.)})

	oStruQIE:SetProperty("QIE_SEQ"   , MODEL_FIELD_INIT, {||""})
	oStruQIE:SetProperty("QIE_ETAPA" , MODEL_FIELD_INIT, {||IIF(!IsBlind(),QncInEtapa("QIE", "QI3MASTER"),)})
	oStruQIE:SetProperty("QIE_NUSR"  , MODEL_FIELD_INIT, {||IIF(!IsBlind(),QncAnexMVC("QIE"),)})
	oStruQIE:SetProperty("QIE_DESDOC", MODEL_FIELD_INIT, {||IIF(!IsBlind(),Posicione('QUU',1,xFilial('QUU')+QIE->QIE_TIPODC,'QUU_DESCDO'),)})
	oStruQIE:SetProperty("QIE_FILMAT", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[2],)})
	oStruQIE:SetProperty("QIE_MAT"   , MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[3],)})
	
	oStruQIE:SetProperty("QIE_FILMAT", MODEL_FIELD_VALID, MTBlcVld("QIE", "QIE_FILMAT", "NaoVazio() .And. QAChkFil('QIE_FILMAT', 'QIEDETAIL')",.F.,.F. ))
	oStruQIE:SetProperty("QIE_MAT"   , MODEL_FIELD_VALID, MTBlcVld("QIE", "QIE_MAT"   , "NaoVazio() .And. VldChkMat('QIE', 'QIEDETAIL', 'QIE_FILMAT', 'QIE_MAT')",.F.,.F. ))

	oStruQIE:AddTrigger("QIE_MAT", "QIE_NUSR", {||.T.}, {|oModel|Posicione("QAA",1,oModel:GetValue("QIE_FILMAT")+oModel:GetValue("QIE_MAT"),"PadR(QAA->QAA_NOME,TamSX3('QIE_NUSR')[1])")})
	
	oModel := MPFormModel():New( 'QNCA330',,,,{|oModel|Q330Cancel(oModel)})
	oModel:AddFields( 'QI3MASTER', /*cOwner*/, oStruQI3 , , )
	oModel:AddFields( 'QIXMASTER', 'QI3MASTER', oStruCab , , ,{||QIXLoad()})
	oModel:addGrid( 'QI4DETAIL', 'QI3MASTER', oStruQI4 , , ,)
	oModel:addGrid( 'QI5DETAIL', 'QI3MASTER', oStruQI5 , , ,)
	oModel:addGrid( 'QI6DETAIL', 'QI3MASTER', oStruQI6 , , ,)
	oModel:addGrid( 'QI7DETAIL', 'QI3MASTER', oStruQI7 , , ,)
	oModel:addGrid( 'QI8DETAIL', 'QI3MASTER', oStruQI8 , , ,)
	oModel:addGrid( 'QI9DETAIL', 'QI3MASTER', oStruQI9 , , ,)
	oModel:addGrid( 'QIEDETAIL', 'QI3MASTER', oStruQIE , , ,)
	
	oModel:SetPrimaryKey( {"QI3_CODIGO", "QI3_REV"} )
	oModel:SetRelation("QI4DETAIL", {{"QI4_FILIAL",'xFilial("QI4")'},{"QI4_CODIGO", "QI3_CODIGO"},{"QI4_REV","QI3_REV"}},QI4->(IndexKey(1)))
	oModel:SetRelation("QI5DETAIL", {{"QI5_FILIAL",'xFilial("QI5")'},{"QI5_CODIGO", "QI3_CODIGO"},{"QI5_REV","QI3_REV"}},QI5->(IndexKey(1)))
	oModel:SetRelation("QI6DETAIL", {{"QI6_FILIAL",'xFilial("QI6")'},{"QI6_CODIGO", "QI3_CODIGO"},{"QI6_REV","QI3_REV"}},QI6->(IndexKey(1)))
	oModel:SetRelation("QI7DETAIL", {{"QI7_FILIAL",'xFilial("QI7")'},{"QI7_CODIGO", "QI3_CODIGO"},{"QI7_REV","QI3_REV"}},QI7->(IndexKey(1)))
	oModel:SetRelation("QI8DETAIL", {{"QI8_FILIAL",'xFilial("QI8")'},{"QI8_CODIGO", "QI3_CODIGO"},{"QI8_REV","QI3_REV"}},QI8->(IndexKey(1)))
	oModel:SetRelation("QI9DETAIL", {{"QI9_FILIAL",'xFilial("QI9")'},{"QI9_CODIGO", "QI3_CODIGO"},{"QI9_REV","QI3_REV"}},QI9->(IndexKey(1)))
	oModel:SetRelation("QIEDETAIL", {{"QIE_FILIAL",'xFilial("QIE")'},{"QIE_CODIGO", "QI3_CODIGO"},{"QIE_REV","QI3_REV"}},QIE->(IndexKey(1)))
	
	oModel:SetDescription(STR0006)
	oModel:GetModel( 'QI3MASTER' ):SetDescription(STR0006)
	oModel:GetModel( 'QIXMASTER' ):SetDescription(STR0006)
	oModel:GetModel( 'QI4DETAIL' ):SetDescription(STR0019)
	oModel:GetModel( 'QI5DETAIL' ):SetDescription(STR0015)
	oModel:GetModel( 'QI6DETAIL' ):SetDescription(STR0016)
	oModel:GetModel( 'QI7DETAIL' ):SetDescription(STR0017)
	oModel:GetModel( 'QI8DETAIL' ):SetDescription(STR0018)
	oModel:GetModel( 'QI9DETAIL' ):SetDescription(STR0020)
	oModel:GetModel( 'QIEDETAIL' ):SetDescription(STR0068)
	
	oModel:GetModel( 'QI4DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QI5DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QI6DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QI7DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QI8DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QI9DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QIEDETAIL' ):SetOptional(.T.)

	oModel:GetModel( 'QIXMASTER' ):SetOnlyQuery(.T.)
	
	oModel:InstallEvent("QNCA330EVDEF", /*cOwner*/, oEvent)
	
	FWMemoVirtual(oStruQI3, {{'QI3_PROBLE', 'QI3_MEMO1'},; // Descricao Detalhada 
							 {'QI3_LOCAL' , 'QI3_MEMO2'},; // Local de Execucao
							 {'QI3_RESESP', 'QI3_MEMO3'},; // Resultado Esperado
							 {'QI3_RESATI', 'QI3_MEMO4'},; // Resultado Atingido
							 {'QI3_OBSERV', 'QI3_MEMO5'},; // Observacoes
							 {'QI3_METODO', 'QI3_MEMO6'},; // Metodo Utilizado
							 {'QI3_MOTREV', 'QI3_MEMO7'}}) // Motivo da Revisao

    FWMemoVirtual(oStruQI5, {{'QI5_DESCCO', 'QI5_MEMO1'},; // Descricao Completa
    						 {'QI5_DESCOB', 'QI5_MEMO2'}}) // Observacao

    FWMemoVirtual(oStruQI6, {{'QI6_DESCR' , 'QI6_MEMO1'}}) // Descricao Causa Provavel

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return oView
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel("QNCA330")
	Local oStruQI3 := FWFormStruct(2,"QI3")
	Local oView

	If Type("lRevisao") != "L"
		Private lRevisao := .F.
	EndIf

	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_QI3', oStruQI3,  'QI3MASTER' )
	oView:CreateHorizontalBox( 'TELA', 100 )
	oView:SetOwnerView( 'VIEW_QI3', 'TELA' )

	oView:AddUserButton(OemToAnsi(STR0015),"FILTRO",{|oView| Q330Acoes(oView)})  // "Acoes/Etapas"  //"Acao/Etap"
	oView:AddUserButton(OemToAnsi(STR0016),"FILTRO",{|oView| Q330Causas(oView)}) // "Causas"
	oView:AddUserButton(OemToAnsi(STR0017),"FILTRO",{|oView| Q330Docs(oView)})   // "Documentos"  //"Docs"
	oView:AddUserButton(OemToAnsi(STR0018),"FILTRO",{|oView| Q330Custos(oView)}) // "Custos"
	oView:AddUserButton(OemToAnsi(STR0019),"FILTRO",{|oView| Q330Equipe(oView)}) // "Equipes"
	oView:AddUserButton(OemtoAnsi(STR0076),"FILTRO",{|oView| Q330NConfr(oView)}) // "Ocorrencias/Nao-conformidades" //"N-Confor"
	oView:AddUserButton(OemtoAnsi(STR0077),"FILTRO",{|oView| Q330DocsAn(oView)}) // "Doc.Anexo"
	
	If lRevisao
		oView:AddUserButton(OemtoAnsi(STR0033),"NOTE",{|| Q330RevJus()}) // "Motivo da Revisao"
	Endif

	oStruQI3:RemoveField("QI3_ANO")
	oStruQI3:RemoveField("QI3_PROBLE")
	oStruQI3:RemoveField("QI3_LOCAL")
	oStruQI3:RemoveField("QI3_RESESP")
	oStruQI3:RemoveField("QI3_RESATI")
	oStruQI3:RemoveField("QI3_OBSERV")
	oStruQI3:RemoveField("QI3_METODO")
	oStruQI3:RemoveField("QI3_OBSOL")
	oStruQI3:RemoveField("QI3_MOTREV")
	oStruQI3:RemoveField("QI3_MEMO7")
	oStruQI3:RemoveField("QI3_CODCLI")
	oStruQI3:RemoveField("QI3_LOJCLI")
	oStruQI3:RemoveField("QI3_NOMCLI")

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} QNC330Rev()
Função de chamada antes da revisão.
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return oView
/*/
//-------------------------------------------------------------------
Function QNC330Rev()
	Local lRet := .T.
	Local nRegObs   := QI3->(Recno())
	Local nOrdObs   := QI3->(IndexOrd())
	Local cChaveQI3 := QI3->QI3_FILIAL+QI3->QI3_CODIGO
	Local aUsrMat   := QNCUSUARIO()
	Local cMatFil   := aUsrMat[2]
	Local cMatCod   := aUsrMat[3]
	Local cRev      := ""

	lRevisao := .T.
	
	DbSelectArea("QAA")
	DbSetOrder(1)
	DbSelectArea ("QAD")
	DbSetOrder(1)
	If QAA->(DbSeek(xFilial("QAA")+QI3->QI3_MAT)).And. QAA->QAA_STATUS == "2"
		IF QAD->(DbSeek(xFilial("QAD")+QAA->QAA_CC)) .And. !Empty(QAD->QAD_MAT) .And. QAD->QAD_MAT <> cMatCod
			MsgAlert(OemToAnsi(STR0099)) //"O usuário responsável pelo plano está inativo, somente o responsável pelo Departamento poderá efetuar a revisão."       
	    Else
	    	If dbSeek(cChaveQI3+QI3->QI3_REV)
	    		dbSkip()
				If QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
					MsgAlert(OemToAnsi(STR0050)) // "Ja existe uma Revisao em andamento ou superior."
					dbSetOrder(nOrdObs)
					dbGoTo(nRegObs)
					Return Nil
				Endif
	    	Endif
	
			dbSetOrder(nOrdObs)
			dbGoTo(nRegObs)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Permite apenas a Geracao de Revisao se o Plano de Acao estiver BAIXADO e ³
			//³ se o numero da revisao for menor que "99"(limite de revisoes)            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(QI3->QI3_ENCREA)
				If Val(QI3->QI3_REV) < 99
					cRev := Q330RevJus()
					If !Empty(cRev)
						If FWExecView(STR0032, "QNCA330", 9) == 0
							dbSelectArea("QI3")
							dbGoTo(nRegObs)
							RecLock("QI3",.F.)
								QI3->QI3_OBSOL := "S"
							MsUnLock()
							FKCOMMIT()
							dbSkip()
						Endif
					EndIf
				Endif
			Else
				MsgAlert(OemToAnsi(STR0054)) // "Nao sera permitida a Geracao de Revisao para Lancamentos pendentes."
			Endif   
	    Endif
	ElseIf cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT
		MsgAlert(OemToAnsi(STR0049)) // "Usuario nao autorizado a gerar Revisao."
	Else
		QI3->(dbSetOrder(2))
	    If QI3->(dbSeek(cChaveQI3+QI3->QI3_REV))
	    	QI3->(dbSkip())
			If QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
				MsgAlert(OemToAnsi(STR0050)) // "Ja existe uma Revisao em andamento ou superior."
				dbSetOrder(nOrdObs)
				dbGoTo(nRegObs)
				Return Nil
			Endif
	    Endif
	
		QI3->(dbSetOrder(nOrdObs))
		QI3->(dbGoTo(nRegObs))
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permite apenas a Geracao de Revisao se o Plano de Acao estiver BAIXADO e ³
		//³ se o numero da revisao for menor que "99"(limite de revisoes)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(QI3->QI3_ENCREA)
			If Val(QI3->QI3_REV) < 99
				cRev := Q330RevJus()
				If !Empty(cRev)
					If FWExecView(STR0032, "QNCA330", 9) == 0
						dbSelectArea("QI3")
						dbGoTo(nRegObs)
						RecLock("QI3",.F.)
							QI3->QI3_OBSOL := "S"
						MsUnLock()
						FKCOMMIT()
						dbSkip()
					Endif
				EndIf
			Endif
		Else
			MsgAlert(OemToAnsi(STR0054)) // "Nao sera permitida a Geracao de Revisao para Lancamentos pendentes."
		Endif
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC330Stat()
Verifica o WHEN do campo QI3_STATUS
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return oView
/*/
//-------------------------------------------------------------------
Function QNC330Stat()
	Local cOrigem := AllTrim(QI2->QI2_ORIGEM)
	Local lTMKPMS := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)
	Local oModel  := FWModelActive()
	Local lWhenSt := .T.
	
	If oModel:GetOperation() == 4 .AND. lTMKPMS .AND. cOrigem =="TMK"
	    lWhenSt := .F.
	EndIf

Return lWhenSt

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330Acoes()
Abre a tela de "Acoes/Etapas"
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return 
/*/
//-------------------------------------------------------------------
Static Function Q330Acoes(oViewPai)
	Local oStruCab
	Local oStruQI5  := FWFormStruct(2, "QI5", {|cCampo| !ALLTRIM(cCampo) $ "QI5_CODIGO|QI5_REV" })
	Local oView 	:= Nil
	Local oExecView := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.
	
	oStruQI5:AddField( ;                // Ord. Tipo Desc.
	                   'QI5_OK' , ; 	// [01] C Nome do Campo
	                   '01' , ;    		// [02] C Ordem
	                   " " , ;     		// [03] C Titulo do campo 
	                   ' ', ;      		// [04] C Descrição do campo 
	                   {} , ;      		// [05] A Array com Help 
	                   'C' , ;     		// [06] C Tipo do campo
	                   '@BMP' , ;    	// [07] C Picture
	                   NIL , ;     		// [08] B Bloco de Picture Var
	                   '' , ;      		// [09] C Consulta F3
	                   .T. , ;     		// [10] L Indica se o campo é evitável
	                   NIL , ;     		// [11] C Pasta do campo
	                   NIL , ;     		// [12] C Agrupamento do campo
	                   Nil , ;     		// [13] A Lista de valores permitido do campo (Combo)
	                   Nil , ;     		// [14] N Tamanho Máximo da maior opção do combo
	                   "BR_LARANJA" , ; // [15] C Inicializador de Browse
	                   .T. , ;     		// [16] L Indica se o campo é virtual
	                   NIL , ;     		// [17] C Picture Variável
	                   .F.)	      		// [18]  L   Indica pulo de linha após o campo
	
	oStruCab := QMontaCab()

	oStruQI5:RemoveField("QI5_DESCCO")
	oStruQI5:RemoveField("QI5_DESCOB")
	oStruQI5:RemoveField("QI5_PEND")
	oStruQI5:RemoveField("QI5_PLAGR")
	oStruQI5:RemoveField("QI5_AGREG")
	oStruQI5:RemoveField("QI5_REJEIT")
	oStruQI5:RemoveField("QI5_CJCOD")
	oStruQI5:RemoveField("QI5_PROJET")
	oStruQI5:RemoveField("QI5_ETPRLA")
	
	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddField("FORM_CAB", oStruCab, "QIXMASTER")
	oView:AddGrid("FORM_QI5" , oStruQI5, "QI5DETAIL")
	
	oView:CreateHorizontalBox("BOX_CAB", 12)
	oView:CreateHorizontalBox("BOXFORM_QI5", 88)
	
	oView:SetOwnerView("FORM_CAB", 'BOX_CAB')
	oView:SetOwnerView('FORM_QI5','BOXFORM_QI5')
	
	oView:addIncrementField("FORM_QI5", "QI5_SEQ")

	oView:AddUserButton(OemtoAnsi(STR0101),"PMSCOLOR",{||Q330LegQI5()}) //"Legenda" ##"Legenda dos itens"

	If (GetMv("MV_QTMKPMS",.F.,1) > 2)
		oView:AddUserButton(OemtoAnsi(STR0091),"POSCLI",{|oModel|If(!Empty(oModel:GetModel("QI5DETAIL"):GetValue("QI5_TPACAO")), QNCA160(oModel:GetOperation(), oModel:GetModel("QI5DETAIL"):GetValue("QI5_TPACAO"),oModel:GetModel("QI5DETAIL"):GetLine()),) }) //"Habilidade" ##"Habilidade(s) Adicionais"
	EndIf

	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(OemToAnsi(STR0015))
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(50)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .t.})
	  oExecView:openView(.F.)
	  
	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330Causas()
Abre a tela de "Causas"
@author Luiz Henrique Bourscheid
@since 21/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Q330Causas(oViewPai)
	Local oStruCab
	Local oStruQI6  := FWFormStruct(2, "QI6", {|cCampo| !ALLTRIM(cCampo) $ "QI6_CODIGO|QI6_REV" })
	Local oView 	:= Nil
	Local oExecView := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.

	oStruQI6:RemoveField("QI6_DESCR")
	
	oStruCab := QMontaCab()

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddField("FORM_CAB", oStruCab, "QIXMASTER")
	oView:AddGrid("FORM_QI6" , oStruQI6, "QI6DETAIL")
	
	oView:CreateHorizontalBox("BOX_CAB", 12)
	oView:CreateHorizontalBox("BOXFORM_QI6", 88)
	
	oView:SetOwnerView("FORM_CAB", 'BOX_CAB')
	oView:SetOwnerView('FORM_QI6','BOXFORM_QI6')
	
	oView:addIncrementField("FORM_QI6", "QI6_SEQ")
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(OemToAnsi(STR0016))
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(50)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .t.})
	  oExecView:openView(.F.)
	  
	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330Docs()
Abre a tela de "Documentos"
@author Luiz Henrique Bourscheid
@since 21/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Q330Docs(oViewPai)
	Local oStruCab
	Local oStruQI7  := FWFormStruct(2, "QI7", {|cCampo| !ALLTRIM(cCampo) $ "QI7_CODIGO|QI7_REV" })
	Local oView 	:= Nil
	Local oExecView := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.
	
	oStruQI7:SetProperty("QI7_RV", MVC_VIEW_CANCHANGE, .F.)
	
	oStruCab := QMontaCab()

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddField("FORM_CAB", oStruCab, "QIXMASTER")
	oView:AddGrid("FORM_QI7" , oStruQI7, "QI7DETAIL")
	
	oView:CreateHorizontalBox("BOX_CAB", 12)
	oView:CreateHorizontalBox("BOXFORM_QI7", 88)
	
	oView:SetOwnerView("FORM_CAB", 'BOX_CAB')
	oView:SetOwnerView('FORM_QI7','BOXFORM_QI7')
		
	oView:addIncrementField("FORM_QI7", "QI7_SEQ")
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(OemToAnsi(STR0017))
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(50)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .t.})
	  oExecView:openView(.F.)
	  
	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330Custos()
Abre a tela de "Custos"
@author Luiz Henrique Bourscheid
@since 21/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Q330Custos(oViewPai)
	Local oStruCab
	Local oStruQI8  := FWFormStruct(2, "QI8", {|cCampo| !ALLTRIM(cCampo) $ "QI8_CODIGO|QI8_REV" })
	Local oView 	:= Nil
	Local oExecView := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.

	oStruCab := QMontaCab()

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddField("FORM_CAB", oStruCab, "QIXMASTER")
	oView:AddGrid("FORM_QI8" , oStruQI8, "QI8DETAIL")
	
	oView:CreateHorizontalBox("BOX_CAB", 12)
	oView:CreateHorizontalBox("BOXFORM_QI8", 88)
	
	oView:SetOwnerView("FORM_CAB", 'BOX_CAB')
	oView:SetOwnerView('FORM_QI8','BOXFORM_QI8')
	
	oView:addIncrementField("FORM_QI8", "QI8_SEQ")
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(OemToAnsi(STR0018))
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(50)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .t.})
	  oExecView:openView(.F.)
	  
	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330Equipe()
Abre a tela de "Equipe"
@author Luiz Henrique Bourscheid
@since 21/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Q330Equipe(oViewPai)
	Local oStruCab
	Local oStruQI4  := FWFormStruct(2, "QI4", {|cCampo| !ALLTRIM(cCampo) $ "QI4_CODIGO|QI4_REV" })
	Local oView 	:= Nil
	Local oExecView := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.
	
	oStruCab := QMontaCab()
	
	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddField("FORM_CAB", oStruCab, "QIXMASTER")
	oView:AddGrid("FORM_QI4" , oStruQI4, "QI4DETAIL")
	
	oView:CreateHorizontalBox("BOX_CAB", 12)
	oView:CreateHorizontalBox("BOXFORM_QI4", 88)
	
	oView:SetOwnerView("FORM_CAB", 'BOX_CAB')
	oView:SetOwnerView('FORM_QI4','BOXFORM_QI4')
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(OemToAnsi(STR0019))
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(50)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .t.})
	  oExecView:openView(.F.)
	  
	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330NConfr()
Abre a tela de "Não Conformidades"
@author Luiz Henrique Bourscheid
@since 22/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Q330NConfr(oViewPai)
	Local oStruCab
	Local oStruQI9  := FWFormStruct(2, "QI9", {|cCampo| !ALLTRIM(cCampo) $ "QI9_CODIGO|QI9_REV" })
	Local oView 	:= Nil
	Local oExecView := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.
	
	oStruCab := QMontaCab()

	oStruQI9:RemoveField("QI9_PLAGRE")

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddField("FORM_CAB", oStruCab, "QIXMASTER")
	oView:AddGrid("FORM_QI9" , oStruQI9, "QI9DETAIL")
	
	oView:CreateHorizontalBox("BOX_CAB", 12)
	oView:CreateHorizontalBox("BOXFORM_QI9", 88)

	oView:SetOwnerView("FORM_CAB", 'BOX_CAB')
	oView:SetOwnerView('FORM_QI9','BOXFORM_QI9')
	
	oView:AddUserButton(OemtoAnsi(STR0076),"FILTRO",{||FWExecView(STR0076, "QNCA340", 1)}) // "Ocorrencias/Nao-conformidades" //"N-Confor"
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(OemToAnsi(STR0020))
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(50)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .t.})
	  oExecView:openView(.F.)
	  
	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QMontaCab()
Monta o cabeçalho dos botões.
@author Luiz Henrique Bourscheid
@since 06/06/2018
@version 1.0
@return oStruCab
/*/
//-------------------------------------------------------------------
Static Function QMontaCab()
	Local oStruCab  := FWFormViewStruct():New()
		
	oStruCab:AddField( ;                						   // Ord. Tipo Desc.
	                   'QIX_CODIGO' , ; 						   // [01] C Nome do Campo
	                   '01' , ;    								   // [02] C Ordem
	                   GetSX3Cache("QI3_CODIGO", "X3_TITULO") , ;  // [03] C Titulo do campo 
	                   GetSX3Cache("QI3_CODIGO", "X3_DESCRIC"), ;  // [04] C Descrição do campo 
	                   {} , ;      								   // [05] A Array com Help 
	                   'C' , ;     								   // [06] C Tipo do campo
	                   GetSX3Cache("QI3_CODIGO", "X3_PICTURE") , ; // [07] C Picture
	                   NIL , ;     								   // [08] B Bloco de Picture Var
	                   '' , ;      								   // [09] C Consulta F3
	                   .T. , ;     								   // [10] L Indica se o campo é evitável
	                   NIL , ;     								   // [11] C Pasta do campo
	                   NIL , ;     								   // [12] C Agrupamento do campo
	                   Nil , ;     								   // [13] A Lista de valores permitido do campo (Combo)
	                   Nil , ;     								   // [14] N Tamanho Máximo da maior opção do combo
	                   M->QI3_CODIGO, ; 						   // [15] C Inicializador de Browse
	                   .T. , ;     								   // [16] L Indica se o campo é virtual
	                   NIL , ;     								   // [17] C Picture Variável
	                   .F.)	      								   // [18]  L   Indica pulo de linha após o campo
	                   
	oStruCab:AddField( ;                					    // Ord. Tipo Desc.
	                   'QIX_REV' , ; 						    // [01] C Nome do Campo
	                   '02' , ;    							    // [02] C Ordem
	                   GetSX3Cache("QI3_REV", "X3_TITULO") , ;  // [03] C Titulo do campo 
	                   GetSX3Cache("QI3_REV", "X3_DESCRIC"), ;  // [04] C Descrição do campo 
	                   {} , ;      							    // [05] A Array com Help 
	                   'C' , ;     							    // [06] C Tipo do campo
	                   GetSX3Cache("QI3_REV", "X3_PICTURE") , ; // [07] C Picture
	                   NIL , ;     								// [08] B Bloco de Picture Var
	                   '' , ;      								// [09] C Consulta F3
	                   .T. , ;     								// [10] L Indica se o campo é evitável
	                   NIL , ;     								// [11] C Pasta do campo
	                   NIL , ;     								// [12] C Agrupamento do campo
	                   Nil , ;     								// [13] A Lista de valores permitido do campo (Combo)
	                   Nil , ;     								// [14] N Tamanho Máximo da maior opção do combo
	                   M->QI3_REV, ; 			     			// [15] C Inicializador de Browse
	                   .T. , ;     								// [16] L Indica se o campo é virtual
	                   NIL , ;     								// [17] C Picture Variável
	                   .F.)
Return oStruCab

//-------------------------------------------------------------------
/*/{Protheus.doc} QIXLoad()
Inicializa o modelo do cabeçalho
@author Luiz Henrique Bourscheid
@since 06/06/2018
@version 1.0
@return oStruCab
/*/
//-------------------------------------------------------------------
Static Function QIXLoad()
	Local aLoad := {{0 ,0} , 0}
Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} QN330BxPla()
Baixa o plano de Acao
@author Luiz Henrique Bourscheid
@since 06/06/2018
@version 1.0
@return .T.
/*/
//-------------------------------------------------------------------
Function QN330BxPla(cRejPlan, cCodPla, cRevPla, oModel, oModelQI2, oModelQI3)
	Local aAreaOri   := GetArea()
	Local aAreaQI3   := {}
	Local cTpMail    := "1"
	Local cMsg       := ""
	Local aMsg       := {}
	Local cMensag    := ""
	Local lBxPlano   := .T.
	Local lExistPend := .F.
	Local aUsrMat    := QNCUSUARIO()
	Local cMatFil    := aUsrMat[2]
	Local cMatCod    := aUsrMat[3]
	Local cEncAutPla := AllTrim(GetMv("MV_QNEAPLA",.f.,"1"))       // Encerramento Automatico de Plano
	Local lTMKPMS    := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
	Local lQNCBXFNC  := ExistBlock( "QNCBXFNC" )
	
	Default cRejPlan  := ""
	Default cCodPla   := QI3->QI3_CODIGO
	Default cRevPla   := QI3->QI3_REV
	Default oModel    := FWModelActive()
	Default oModelQI2 := ""
	Default oModelQI3 := ""
	
	dbSelectArea("QI3")
	aAreaQI3 := GetArea()
	QI3->(dbSetOrder(2))
	
	If !Empty(cCodPla)
	    IF QI3->(dbSeek(xFilial("QI3")+cCodPla+cRevPla))
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	        //³Encerramento Automatico do Plano de Acao.  ³
	        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If cEncAutPla == "1"
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	            //³Consistencia para nao encerrar o Plano de Acao caso existam pendencias filhas a serem executadas.³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            lExistPend := .T.      // independente de ter ou não Ações etapas será True.
	            dbSelectArea("QI5")
	            QI5->(dBSetOrder(1))
	            IF QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
	                lExistPend := .F.   // Se tiver ações etapas muda para False sem pendencias e caso exista pendencia muda para True
	                While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
	                    If QI5->QI5_PEND == "S"
	                        lExistPend := .T.
	                    Endif
	                    QI5->(dbSkip())
	                Enddo
	            Endif

	            //If Empty(oModelQI3)
				If !Empty(cRejPlan)
						RecLock("QI3",.F.)
						If alltrim(cRejPlan) == "5"    //Se for uma rejeição total de plano/FNC
							QI3->QI3_STATUS := "4" //Nao-Procede
						Else
						QI3->QI3_STATUS := "5" //Cancelada
						EndIf
					QI3->(MsUnLock())
					FKCOMMIT()
				Else
					If !lExistPend
						RecLock("QI3",.F.)
						QI3->QI3_ENCREA := dDataBase
						If Empty(QI3->QI3_ENCPRE)
							QI3->QI3_ENCPRE := dDataBase
						Endif
						If QI3->QI3_STATUS < "3"
							QI3->QI3_STATUS := "3"    // 3-Procede
						Endif
						QI3->(MsUnLock())
						FKCOMMIT()
					Endif
				Endif

				If lTMKPMS
					If !Empty(cRejPlan) .Or. !lExistPend
						If cRejPlan <> "5"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Caso a baixa do Plano tratar-se de um plano filho, deve se buscar na QI9³
							//³o codigo e revisão do Plano Pai para habititar/gerar a pendencia        ³
							//³da etapa pai que gerou este plano filho que esta sendo baixado, pq o    ³
							//³mesmo encontra-se sem pendencia. 									   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("QI9")
							QI9->(DBSetOrder(1))
							If QI9->(MsSeek(xFilial("QI9")+QI3->QI3_CODIGO+QI3->QI3_REV)) .AND. QI9->QI9_AGREG == "S"
								dbSelectArea("QI5")
								QI5->(DBSetOrder(1))
								IF QI5->(MsSeek( xFilial("QI5") + QI9->QI9_PLAGRE+ QI9->QI9_REVPL ))
									While !Eof() .And. QI5->QI5_FILIAL + QI5->QI5_CODIGO + QI5->QI5_REV == QI9->QI9_FILIAL + QI9->QI9_PLAGRE+ QI9->QI9_REVPL
										If Empty(QI5->QI5_REALIZ) .And. (QI5->QI5_PEND) == "N"
											RecLock("QI5",.F.)
											QI5->QI5_PEND := "S"
											MsUnlock()
											FKCOMMIT()
											If QI9FindFNC(QI5->QI5_CODIGO,QI5->QI5_REV,.T.,.T.,.F.) > 0
												QNQI5xPMS({QI5->(Recno())}, QI2->QI2_FNC ,QI2->QI2_REV)
											Else
												QNQI5xPMS({QI5->(Recno())})
											EndIf
											Exit
										Endif
										QI5->(dbSkip())
									EndDo
								Endif
							Endif
						Endif
					Endif
				Endif

	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	            //³ Posiciona Plano de Acao no arquivo QI9                       ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            QI9->(DBSETORDER(1))
	            If QI9->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
	                If QI9->QI9_AGREG == "S"
	                    lBxPlano := .F.
	                Endif
	                If cEncAutPla == "1" .and. lExistPend // proteção para não fazer a baixa da FNC qdo existem pendencias.
	                    lBxPlano := .F.
	                Endif
	
	                If lBxPlano
	                    While QI9->(!Eof()) .And. QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV == QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV
	                        QI2->(DBSETORDER(1))
	                        If QI2->(dbSeek(QI9->QI9_FILIAL+Right(QI9->QI9_FNC,4)+QI9->QI9_FNC+QI9->QI9_REVFNC)) .And. Empty(QI2->QI2_CONREA)
	                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                            //³ Baixa Ficha de Ocorrencia/Nao-conformidades caso Plano de Acao esteja baixado ³
	                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                            //If Empty(oModelQI2)
								RecLock("QI2",.F.)
								
								QI2->QI2_CONREA := dDatabase
								
								If Empty(QI2->QI2_CONPRE)
									QI2->QI2_CONPRE := dDataBase
								Endif
								
								If !Empty(cRejPlan)
									QI2->QI2_STATUS := "5"    ///Ficha Cancelada/Rejeitada.
								Else
									If QI2->QI2_STATUS < "3"
										QI2->QI2_STATUS := "3" // 3-Ficha Baixada
									Endif
								EndIf								
								MsUnlock()
								FKCOMMIT()

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Encerra atendimento no TMK³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								IF QI2->QI2_ORIGEM == "TMK"
									QNCbxTMK(QI2->QI2_FNC,QI2->QI2_REV) //SE ESTA BAIXADA BAIXO O ATENDIMENTO
								EndIf

	                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                            //³ Verifica se ultima Etapa foi realizada para avisar Resp. Acao³
	                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                            If cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES
	                                If QAA->(dbSeek(QI2->QI2_FILRES + QI2->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"
	
	                                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                                    //³ Envio de e-Mail para o responsavel das FNC relacionadas                  ³
	                                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                                    If !Empty(QAA->QAA_EMAIL) .And. !lTMKPMS
	
	                                        cMail := AllTrim(QAA->QAA_EMAIL)
	                                        cTpMail:= QAA->QAA_TPMAIL
	
	                                        // ETAPAS DO PLANO DE ACAO
	                                        If cTpMail == "1"
	                                            cMensag := OemToAnsi(STR0037)+DtoC(QI3->QI3_ENCREA)+CHR(13)+CHR(10)    // "Este Plano de Acao foi baixado no dia "
	                                            cMensag += OemToAnsi(STR0041)                                                             // "Favor verificar a Baixa da Ficha de Ocorrencia/Nao-conformidade."
	                                            cMsg := QNCSENDMAIL(2,cMensag,.T.)
	                                        Else
	                                            cMsg := OemToAnsi(STR0037)+DtoC(QI3->QI3_ENCREA)+CHR(13)+CHR(10)     // "Este Plano de Acao foi baixado no dia "
	                                            cMsg += CHR(13)+CHR(10)
	                                            cMsg += OemToAnsi(STR0038)+Space(1)+TransForm(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+QI2->QI2_REV+Space(1)+OemToAnsi(STR0039)+CHR(13)+CHR(10)    // "A Ficha de Ocorrencia/Nao-conformidade " ### "esta relacionada."
	                                            cMsg += Replicate("-",80)+CHR(13)+CHR(10)
	                                            cMsg += OemToAnsi(STR0040)+CHR(13)+CHR(10)    // "Descricao Detalhada da Ocorrencia/Nao-conformidade:"
	                                            cMsg += CHR(13)+CHR(10)
	                                            cMsg += MSMM(QI2->QI2_DDETA,80)+CHR(13)+CHR(10)
	                                            cMsg += Replicate("-",80)+CHR(13)+CHR(10)
	                                            cMsg += CHR(13)+CHR(10)
	                                            cMsg += OemToAnsi(STR0041)+CHR(13)+CHR(10) // "Favor verificar a Baixa da Ficha de Ocorrencia/Nao-conformidade."
	                                            cMsg += CHR(13)+CHR(10)
	                                            cMsg += CHR(13)+CHR(10)
	                                            cMsg += OemToAnsi(STR0032)+CHR(13)+CHR(10)    // "Atenciosamente "
	                                            cMsg += QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT,.F.)+CHR(13)+CHR(10)
	                                            cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
	                                            cMsg += CHR(13)+CHR(10)
	                                            cMsg += OemToAnsi(STR0036) + CRLF    // "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
	                                        Endif
	
	                                        cAttach := ""
	                                        aMsg:={{OemToAnsi(STR0033)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach } }    // "Plano de Acao No. "
	
	                                        // Geracao de Mensagem para o Responsavel da Ficha de Ocorrencias/Nao-conformidades
	                                        IF lQNCBXFNC 
	                                            aMsg := ExecBlock( "QNCBXFNC", .f., .f. )
	                                        Endif
	
	                                        aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )
	                                    Endif
	                                Endif
	                            Endif
	                        Endif
	                        QI9->(dbSkip())
	                    Enddo
	                Endif
	            Endif
	        EndIf
	
	        dbSelectArea("QI5")
	        QNCAvisa("QI3",2,QI3->(QI3_FILIAL+QI3_CODIGO+QI3->QI3_REV),"1",cMatFil,cMatCod)
	    Endif
	EndIf
	RestArea(aAreaQI3)
	RestArea(aAreaOri)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QN330BxFNC()
Baixa as Fichas de Nao-Conformidades referentes ao Plano.
@author Luiz Henrique Bourscheid
@since 06/06/2018
@version 1.0
@return .T.
/*/
//-------------------------------------------------------------------
Function QN330BxFNC()
	Local nOrdQI2	:= QI2->(IndexOrd())
	Local nPosQI2	:= QI2->(RecNo())
	Local cMensag	:= ""
	Local cMsg   	:= ""
	Local oModel    := FWModelActive()
	Local oModelQI3 := oModel:GetModel("QI3MASTER")
	Local aUsrMat   := QNCUSUARIO()
	Local cMatFil   := aUsrMat[2]
	Local cMatCod   := aUsrMat[3]
	Local lQNCBXFNC := ExistBlock( "QNCBXFNC" )
	
	QI2->(DbSetOrder(5))
	If QI2->(DbSeek(oModelQI3:GetValue("QI3_FILIAL")+oModelQI3:GetValue("QI3_CODIGO")+oModelQI3:GetValue("QI3_REV")))
		While QI2->(!Eof()) .And. QI2->QI2_FILIAL+QI2->QI2_CODACA+QI2->QI2_REVACA == oModelQI3:GetValue("QI3_FILIAL")+oModelQI3:GetValue("QI3_CODIGO")+oModelQI3:GetValue("QI3_REV")
			If Empty(QI2->QI2_CONREA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Baixa Ficha de Ocorrencia/Nao-conformidades caso Plano de Acao estaja baixado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("QI2",.F.)
				If !Empty(M->QI3_ENCREA)
					QI2->QI2_CONREA := oModelQI3:GetValue("QI3_ENCREA")
				Else
					QI2->QI2_CONREA := dDatabase
				EndIf
				If Empty(QI2->QI2_CONPRE)
					QI2->QI2_CONPRE := dDataBase
				Endif
				If QI2->QI2_STATUS < "3"
					QI2->QI2_STATUS := "3"		// 3-Procede
				Endif
				MsUnlock()
				FKCOMMIT()
						
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerra atendimento no TMK³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF QI2->QI2_ORIGEM == "TMK"
	      			QNCbxTMK(QI2->QI2_FNC,QI2->QI2_REV) //SE ESTA  BAIXADA BAIXO O ATENDIMENTO
	      		EndIf  
	      					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se ultima Etapa foi realizada para avisar Resp. Acao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cMatFil) .And. !Empty(cMatCod) .And. cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES
					If QAA->(dbSeek(QI2->QI2_FILRES + QI2->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Envio de e-Mail para o responsavel das FNC relacionadas                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(QAA->QAA_EMAIL)
	
							If Ascan(aUsuarios,{ |x| x[1] == QAA->QAA_LOGIN }) == 0
	
								cMail := AllTrim(QAA->QAA_EMAIL)
								cTpMail:= QAA->QAA_TPMAIL
								
								// ETAPAS DO PLANO DE ACAO
								If cTpMail == "1"
									cMensag := OemToAnsi(STR0063)+DtoC(oModelQI3:GetValue("QI3_ENCREA"))+CHR(13)+CHR(10)	// "Este Plano de Acao foi baixado no dia "
									cMensag += OemToAnsi(STR0064) // "Favor verificar a Baixa da Ficha de Ocorrencia/Nao-conformidade."
									cMsg := QNCSENDMAIL(2,cMensag,.T.)
								Else
									cMsg := OemToAnsi(STR0063)+DtoC(oModelQI3:GetValue("QI3_ENCREA"))+CHR(13)+CHR(10)	 // "Este Plano de Acao foi baixado no dia "
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0065)+Space(1)+TransForm(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+QI2->QI2_REV+Space(1)+OemToAnsi(STR0066)+CHR(13)+CHR(10)	// "A Ficha de Ocorrencia/Nao-conformidade " ### "esta relacionada."
									cMsg += Replicate("-",80)+CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0067)+CHR(13)+CHR(10)	// "Descricao Detalhada da Ocorrencia/Nao-conformidade:"
									cMsg += CHR(13)+CHR(10)
									cMsg += MSMM(QI2->QI2_DDETA,80)+CHR(13)+CHR(10)
									cMsg += Replicate("-",80)+CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0064)+CHR(13)+CHR(10) // "Favor verificar a Baixa da Ficha de Ocorrencia/Nao-conformidade."
									cMsg += CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0052)+CHR(13)+CHR(10)	// "Atenciosamente "
									cMsg += QA_NUSR(oModelQI3:GetValue("QI3_FILMAT"), oModelQI3:GetValue("QI3_MAT"),.F.)+CHR(13)+CHR(10)
									cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0059) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
								Endif
								
								cAttach := ""
								aMsg:={{OemToAnsi(STR0036)+" "+TransForm(oModelQI3:GetValue("QI3_CODIGO"),PesqPict("QI3","QI3_CODIGO"))+"-"+oModelQI3:GetValue("QI3_REV")+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach } }	// "Plano de Acao No. "
								
								// Geracao de Mensagem para o Responsavel da Ficha de Ocorrencias/Nao-conformidades
								IF lQNCBXFNC
									aMsg := ExecBlock( "QNCBXFNC", .f., .f. )
								Endif
							
								aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )
							Endif
						Endif
					Endif
				Endif
			Endif
			QI2->(DbSkip())
		Enddo
	Endif
	
	QI2->(DbSetOrder(nOrdQI2))
	QI2->(DbGoto(nPosQI2))
		
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC330Sel()
Filtra os Lancamtos Pendentes/Baixados do Plano de Acao.
@author Luiz Henrique Bourscheid
@since 20/06/2018
@version 1.0
@return .T.
/*/
//-------------------------------------------------------------------
Function QNC330Sel()
lFunFNC := !lFunFNC

If !lFunFNC
	oBrowse:SetFilterDefault(" .T. ")
Else
	oBrowse:SetFilterDefault(" Empty(QI3->QI3_ENCREA) " )
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} QNCA330IMP()
Imprime o Plano de Acao em formato Grafico/Formulario.
@author Luiz Henrique Bourscheid
@since 20/06/2018
@version 1.0
@return .T.
/*/
//-------------------------------------------------------------------
Function QNCA330IMP()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime o Plano de Acao no formato MsPrint                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QNCR061")
	ExecBlock( "QNCR061",.f.,.f.,{QI3->(Recno())})
Else
	QNCR060(QI3->(Recno()))
Endif	

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} QNC330Alt()
Função de chamada antes da revisão.
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return oView
/*/
//-------------------------------------------------------------------
Function QNC330Alt(cAlias, nReg, nOpcAcao, lAltEAcao)
	Local cChaveQI3   := QI3->QI3_FILIAL+QI3->QI3_CODIGO
	Local aUsrMat	  := QNCUSUARIO() 
	Local nRetOpc 	  := 0
	Local cMsg	      := ""
	Local lAutorizado := Q330AltPla()
	Local cQPathFNC   := QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
	Local aQPath      := QDOPATH()
	Local cQPathTrm   := aQPath[3]
	Local cBarRmt     := IIF(IsSrvUnix(),"/","\")
	Local lSigilo	  := .T.
	Local aNomes		:= {}
	Local cMensagem		:= ""
	Local nConta		:= 0

	Default lAltEAcao := .F.

	Private lApelido 	:= aUsrMat[1]
	Private cMatFil  	:= aUsrMat[2]
	Private cMatCod  	:= aUsrMat[3]
	Private cMatDep  	:= aUsrMat[4]
	Private cFilMat	 	:= cMatFil
	Private aQNQI3      := {}
	Private __lQNSX8    := .F.
	Private lFNC
	Private nOpc 		:= nOpcAcao
		
	If !Right( cQPathFNC,1 ) == cBarRmt
		cQPathFNC := cQPathFNC + cBarRmt
	Endif

	If !Right( cQPathTrm,1 ) == cBarRmt
		cQPathTrm := cQPathTrm + cBarRmt
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o diretorio para gravacao do Docto Anexo Existe. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. nOpc == 4
		nHandle := fCreate(cQPathFNC+"SIGATST.CEL")
		If nHandle <> -1  // Consegui criar e vou fechar e apagar novamente...
			fClose(nHandle)
			fErase(cQPathFNC+"SIGATST.CEL")
		Else
			Help("",1,"QNCDIRDCNE") // "O Diretorio definido no parametro MV_QNCPDOC" ### "para o Documento Anexo nao existe."
			Return 3
		EndIf
	EndIf
	
	lFNC := If(nOpcAcao == 7,.T.,.F.)
	
	lAltEta := lAltEAcao

	If nOpc == 7
		nOpc := 3
	Endif
	
	cOldPlan := QI3->QI3_CODIGO
	cOldRev  := QI3->QI3_REV

	nOrdQI3 := QI3->(IndexOrd())
	nRegQI3 := QI3->(Recno())
	
	If nOpcAcao <> 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se Plano eh Sigiloso. Somente Responsavel e Reponsaveis pelas Etapas podem Manipular  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If QI3->QI3_SIGILO == "1"	

			lSigilo := .T.
			
			If cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT

				aNomes 		:= {AllTrim(Posicione("QAA",1, QI3->QI3_FILMAT+QI3->QI3_MAT,"QAA_NOME")) }
				cMensagem 	:= ""
				
				QI5->(dbSetOrder(1))
				If QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
					While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
						If QI5->QI5_FILMAT + QI5->QI5_MAT <> cMatFil + cMatCod 
							cNome := AllTrim(Posicione("QAA",1, QI5->QI5_FILMAT+QI5->QI5_MAT,"QAA_NOME"))
							If Ascan(aNomes, { |x| x == cNome }) == 0
								Aadd(aNomes, cNome)
							Endif
						Else
							lSigilo := .f.
						Endif
						QI5->(dbSkip())
					Enddo
				Endif							

				For nConta := 1 To Len(aNomes)
					cMensagem += ", " + aNomes[nConta] 
				Next nConta
			Else          
				lSigilo := .F.
			Endif
			
			If lSigilo .And. Existblock("QNC30SIG") // Ponto de Entrada para deixar que um Plano sigiloso seja visualizado por alguns usuarios
				lSigilo := Execblock("QNC30SIG",.F.,.F.,{cMatFil,cMatCod})
			Endif
				
			If lSigilo 
				If Len(aNomes) == 1
					MsgAlert(OemToAnsi(STR0086)+Chr(13)+;					// "Plano de Ação Sigiloso"
					OemToAnsi(STR0087 + Substr(cMensagem,3) + STR0088 ))  	// "Somente o usuario " ### " tem acesso"
				Else
					MsgAlert(OemToAnsi(STR0086)+Chr(13)+;					// "Plano de Ação Sigiloso"
					OemToAnsi(STR0089 + Substr(cMensagem,3) + STR0088 ))	// "Somente os usuarios " ### " tem acesso"
				Endif

				Return 
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja Exclusao verifica se existe revisoes anteriores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 5 .And. QI3->QI3_OBSOL <> "S"
			dbGoTo(nRegQI3)
	        M->QI3_REV := QI3->QI3_REV
		    If dbSeek(cChaveQI3)
				While !Eof() .And. QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
	                If QI3->QI3_REV <> M->QI3_REV
	                	lRevisao := .T.
	                	Exit
					Endif
					dbSkip()
				Enddo
			Endif
		Endif

		dbSetOrder(nOrdQI3)
		dbGoTo(nRegQI3)

		If nOpcAcao == 4
			lAltEta := Q330AltEta()
	    EndIf

		If !lAutorizado
			nOpc := 1
			If !lAltEta
				MsgAlert(OemToAnsi(STR0030)+Chr(13)+;	// "Usuario nao autorizado a fazer Manutencao neste Plano de Acao,"
						OemToAnsi(STR0031))				// "sera apenas visualizada."
			EndIf
		EndIf
	EndIf

	Do Case
	    Case nOpc == 1
	    	cMsg := STR0002
	    Case nOpc == 3
	    	cMsg := STR0003
	    Case nOpc == 4
	    	cMsg := STR0004
	    Case nOpc == 5
	    	cMsg := STR0005
    EndCase
	
	nRetOpc := FWExecView(cMsg, "QNCA330", nOpc)
	
Return nRetOpc

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330DocsAn()
Abre a tela de "Documentos Anexos"
@author Luiz Henrique Bourscheid
@since 21/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Q330DocsAn(oViewPai)
	Local oStruQIE  := FWFormStruct(2, "QIE", {|cCampo| !ALLTRIM(cCampo) $ "QIE_CODIGO|QIE_REV" })
	Local oView 	:= Nil
	Local oExecView := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddGrid("FORM_QIE" , oStruQIE, "QIEDETAIL")
	
	oView:CreateHorizontalBox("BOXFORM_QIE", 100)
	
	oView:SetOwnerView('FORM_QIE','BOXFORM_QIE')
	
	oView:EnableTitleView('FORM_QIE' , OemToAnsi(STR0068) )
	
	oView:addIncrementField("FORM_QIE", "QIE_SEQ")

	oView:AddUserButton(OemToAnsi(STR0077),"ANEXO",{|oView| QncAnexoMv("QIE", "QI3MASTER", "QIEDETAIL")})   // "Documentos"  //"Docs"
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(OemToAnsi(STR0068))
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(50)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .t.})
	  oExecView:openView(.F.)
	  
	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330Cancel()
Função invocada caso o usuário cancele a ação
@author Luiz Henrique Bourscheid
@since 07/06/2018
@version 1.0
@return .T.
/*/
//-------------------------------------------------------------------
Function Q330Cancel(oModel)
	Local cQPathFNC := QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
	Local aQPath    := QDOPATH()
	Local cQPathTrm := aQPath[3]
	Local cBarRmt   := IIF(IsSrvUnix(),"/","\")
	Local lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
	Local oModelQI3 := oModel:GetModel("QI3MASTER")
	Local aQNQI3    := {}

	If Type("__lQNSX8") != "L"
		Private __lQNSX8 := .F.
	EndIf

	If !Right( cQPathFNC,1 ) == cBarRmt
		cQPathFNC := cQPathFNC + cBarRmt
	Endif

	If !Right( cQPathTrm,1 ) == cBarRmt
		cQPathTrm := cQPathTrm + cBarRmt
	Endif

	If oModel:GetOperation() == 3
		If __lQNSX8
			RollBackQE(aQNQI3)
		EndIf

		//Caso tenha cancelado o plano de acao, verifica se existe Etapa x Habilidades cadastradas e realiza a delecao...
		If lTMKPMS
			dbSelectArea("QUR")
			dbSetOrder(1)
			If DbSeek(xFilial("QUR")+M->QI3_CODIGO)
				While !Eof() .and. QUR->QUR_FILIAL+QUR->QUR_CODIGO == QI3->QI3_FILIAL+oModelQI3:GetValue("QI3_CODIGO")
					RecLock("QUR",.F.)
					dbDelete()
					MsUnlock()
					dbSkip()
				Enddo
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui Documento anexo             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QIE->(DbSeek(M->QI3_FILIAL+oModelQI3:GetValue("QI3_CODIGO")+oModelQI3:GetValue("QI3_REV")))
			While QIE->(!Eof()) .And. QIE->QIE_FILIAL+QIE->QIE_CODIGO+QIE->QIE_REV == M->QI3_FILIAL+oModelQI3:GetValue("QI3_CODIGO")+oModelQI3:GetValue("QI3_REV")
				cFileTrm:= AllTrim(QIE->QIE_ANEXO)
				If File(cQPathFNC+cFileTrm)
					FErase(cQPathFNC+cFileTrm)	
				Endif
				RecLock("QIE",.F.)
				QIE->(DbDelete())
				MsUnlock()
			    FKCOMMIT()	
				QIE->(DbSkip())
			EndDo
		EndIf
	Endif
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330Modelo()
Trigger do campo QI3_MODELO para carga das etapas.
@author Luiz Henrique Bourscheid
@since 13/03/2019
@version 1.0
@return .T.
/*/
//-------------------------------------------------------------------
Function Q330Modelo()
	Local lTMKPMS 	:= ChkFile("QUO")
	Local nModelo 	:= 0
	Local nCntMod 	:= 0
	Local oModel    := FWModelActive()
	Local oModelQI3 := oModel:GetModel("QI3MASTER")
	Local oModelQI5 := oModel:GetModel("QI5DETAIL")
	Local cTPAcao 	:= ""
	Local cHRTotal
	Local cHRParcial
	Local cHRDecimal
	Local aArea
	Local nLinha 		:= 0
	Local nSeqQI5   := "01"
	
	If oModelQI5:Length(.T.) == 1 .And. Empty(oModelQI5:GetValue("QI5_TPACAO"))
		If lTMKPMS
			If (GetMv("MV_QTMKPMS",.F.,1) == 0) .or. (GetMv("MV_QTMKPMS",.F.,1) == 1)
				nModelo := 0
			Else
				nModelo := 1    
			Endif
		Else
			nModelo := 0
		Endif	

		If nModelo == 0 				
			dbSelectArea("QIC")
			dbSetOrder(1)	
			If dbseek(xFilial("QIC")+AllTrim(oModelQI3:GetValue("QI3_MODELO")))
				While !Eof() .And. xFilial("QIC")+AllTrim(QIC_CODIGO) == xFilial("QIC")+AllTrim(oModelQI3:GetValue("QI3_MODELO"))
					nCntMod++
					dbSkip()
				Enddo
			Endif
		Else	
			dbSelectArea("QUP")
			If dbseek( xFilial("QUP")+AllTrim(oModelQI3:GetValue("QI3_MODELO")))
				While !Eof() .And. xFilial("QUP")+Alltrim(QUP_GRUPO) == xFilial("QUP")+Alltrim(oModelQI3:GetValue("QI3_MODELO"))
					nCntMod++
					dbSkip()
				Enddo
			EndiF
		Endif

		If nModelo == 1
			If !Empty(oModelQI3:GetValue("QI3_MODELO")) .And. nCntMod > 0
				dbSelectArea("QUP")
				QUP->(dbSetOrder(2))
				If QUP->(dbseek(xFilial("QUP")+AllTrim(oModelQI3:GetValue("QI3_MODELO"))))
					While !EoF() .And. xFilial("QUP")+QUP_GRUPO == xFilial("QUP")+AllTrim(oModelQI3:GetValue("QI3_MODELO"))
						If oModelQI5:GetLine() == nLinha
							nLinha  := oModelQI5:AddLine()
							nSeqQI5 := StrZero(Val(nSeqQI5)+1,2)
						Else
							nLinha := oModelQI5:GetLine()
						EndIf
						oModelQI5:GoLine(nLinha)
						
						oModelQI5:LoadValue("QI5_SEQ"   , nSeqQI5 )
						oModelQI5:LoadValue("QI5_DESCTP", FQNCDESETA(QUP->QUP_TPACAO) )
						oModelQI5:LoadValue("QI5_NUSR"  , Posicione("QAA", 1, xFilial("QAA")+QUP->QUP_RESP, "QAA_NOME") )
						oModelQI5:LoadValue("QI5_TPACAO", QUP->QUP_TPACAO )
						oModelQI5:LoadValue("QI5_MAT"   , QUP->QUP_RESP )
						oModelQI5:LoadValue("QI5_PLAGR" , QUP->QUP_OBRIGA )
						oModelQI5:LoadValue("QI5_GRAGR" , QUP->QUP_GRAGR )
						oModelQI5:LoadValue("QI5_PRJEDT", QUP->QUP_CJCOD )
						oModelQI5:LoadValue("QI5_REVISA", PMSAF8VER(QUP->QUP_PROJET) )
						oModelQI5:LoadValue("QI5_OBRIGA", QUP->QUP_OBRIGA )
						oModelQI5:LoadValue("QI5_TRFACT", QUP->QUP_TRFACT )
						oModelQI5:LoadValue("QI5_DESCRE", "Adicionado pelo modelo" )
						
						DbselectArea("QUO")
						QUO->(dbSetOrder(1))
						If QUO->(dbSeek(xFilial("QUO")+AllTrim(oModelQI3:GetValue("QI3_MODELO"))))
							cHRTotal    := Hrs2Min(QUO->QUO_PRZHR)
							cHRParcial  := QNCCalcPercHR(cHRTotal, QUP->QUP_PERC)
							cHRDecimal  := Padl(Alltrim(TransForm(Min2Hrs(cHRParcial),"@R 9999.99")),7,"0")   
							oModelQI5:LoadValue("QI5_PRZHR" , Alltrim(StrTran(cHRDecimal,".",":")) )
						Endif     	
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Amarra as Habilidades as Etapas. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
						aArea := GetArea()
						If cTPAcao <>  QUP->QUP_TPACAO
							QNCCARHAB(QUP->QUP_TPACAO,M->QI3_FILIAL,M->QI3_CODIGO)
						Endif	
						RestArea(aArea)  	    
						cTPAcao := QUP->QUP_TPACAO

						QUP->(DbSkip())
					EndDo
				Endif
			Endif
		Else
			dbSelectArea("QIC")
			QIC->(dbSetOrder(1))
			If QIC->(dbseek(xFilial("QIC")+AllTrim(oModelQI3:GetValue("QI3_MODELO"))))
				While QIC->(!EoF()) .And. xFilial("QIC")+QIC_CODIGO == xFilial("QIC")+AllTrim(oModelQI3:GetValue("QI3_MODELO"))
					If oModelQI5:GetLine() == nLinha
						nLinha  := oModelQI5:AddLine()
						nSeqQI5 := StrZero(Val(nSeqQI5)+1,2)
					Else
						nLinha := oModelQI5:GetLine()
					EndIf
					oModelQI5:GoLine(nLinha)

					oModelQI5:LoadValue("QI5_SEQ"   , nSeqQI5 )
					oModelQI5:LoadValue("QI5_DESCTP", Padr(FQNCDSX5("QD",QIC->QIC_TPACAO),30) )
					oModelQI5:LoadValue("QI5_TPACAO", QIC->QIC_TPACAO )
					oModelQI5:LoadValue("QI5_PRAZO" , dDataBase )
					oModelQI5:LoadValue("QI5_MAT"   , QNCUSUARIO()[3] )
					oModelQI5:LoadValue("QI5_NUSR"  , Posicione("QAA",1,oModelQI5:GetValue("QI5_FILMAT")+oModelQI5:GetValue("QI5_MAT"),"PadR(QAA->QAA_NOME,TamSX3('QI5_NUSR')[1])") )
					oModelQI5:LoadValue("QI5_DESCRE", "Adicionado pelo modelo" )

					QIC->(DbSkip())
				EndDo
			Endif
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330RevJus()
Função que abre a tela de justificativa de revisão
@author Luiz Henrique Bourscheid
@since 22/03/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function Q330RevJus()
	Local oTexto	 := NIL
	Local oFontMet := TFont():New("Courier New",6,0)
	Local cCod	   := ""
	Local nOpca
	Local cAntes    := cMotivo

	//Tela do Motivo de Revisão
	cCod := QI3->QI3_CODIGO+"  "+STR0029+QI3->QI3_REV //"Revisao: "
	
	DEFINE MSDIALOG oDlg FROM 62,100 TO 320,610 TITLE STR0033 PIXEL //"Motivo da revisão"
	
	@ 003, 004 TO 027, 250 LABEL STR0006 OF oDlg PIXEL
	@ 040, 004 TO 110, 250 OF oDlg PIXEL

	@ 013, 010 MSGET cCod WHEN .F. SIZE 185, 010 OF oDlg PIXEL

	@ 050, 010 GET oTexto VAR cMotivo MEMO NO VSCROLL SIZE 238, 051 OF oDlg PIXEL
		
	oTexto:SetFont(oFontMet)

	DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 2
		cMotivo := cAntescMotivo := cAntes
	EndIf

Return cMotivo

//-------------------------------------------------------------------
/*/{Protheus.doc} Q330LegQI5()
Monta a legenda dos itens da tela de Acoes X Etapas
@author Luiz Henrique Bourscheid
@since 02/04/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Q330LegQI5()
	Local aLegenda := {}

	aAdd(aLegenda,{'BR_VERDE',STR0103})		 //Etapa concluida
	aAdd(aLegenda,{'BR_AMARELO',STR0102})	 //Etapa em execução
	aAdd(aLegenda,{'BR_LARANJA',STR0111})  //Etapa não iniciada
	If SuperGetMV("MV_QTMKPMS",.F.,1) > 2
		aAdd(aLegenda,{'BR_PRETO',STR0104})	 //Etapa rejeitada
		aAdd(aLegenda,{'BR_BRANCO',STR0105}) //Etapa não gerada
	EndIf

	BrwLegenda(STR0015,STR0043,aLegenda) //Legenda
Return
