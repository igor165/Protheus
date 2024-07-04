#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA284.CH"

Static __LGPD := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA284
Fechamento Conta do Profissional

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Function JURA284()
Local oBrowse := Nil

	If AliasInDic("OHW") .And. ( SuperGetMV("MV_JINTGPE", .F., "1") == "1" .Or.;
	 							 ( RGB->(ColumnPos("RGB_LOTPLS") ) > 0  .And. RGB->(ColumnPos("RGB_CODRDA") ) > 0 )  ) 
		oBrowse := FWMBrowse():New()
		oBrowse:SetMenuDef("JURA284")
		oBrowse:SetDescription(STR0001) // "Fechamento Conta do Profissional"
		oBrowse:SetAlias("OHW")
		oBrowse:Activate()
	Else
		MsgStop(STR0002) // "Necessaria a criacao da Tabela de Fechamento Conta Participantes(OHW) e os campos de va­nculo de lote no registro de lancamentos de eventos (RGB_LOTPLS e RGB_CODRDA), caso a integracao GPE esteja habilitada (para¢metro MV_JINTGPE valor 2). "
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	aAdd(aRotina, {STR0003, "VIEWDEF.JURA284", 0, 2, 0, Nil }) // "Visualizar"
	aAdd(aRotina, {STR0004, "JUR284DlGL()"   , 0, 3, 0, Nil }) // "Gerar Lote"
	aAdd(aRotina, {STR0005, "JURA284CLt()"   , 0, 4, 0, Nil }) // "Cancelar Lote"
	aAdd(aRotina, {STR0006, "VIEWDEF.JURA284", 0, 4, 0, Nil }) // "Alterar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Natureza Juridica

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := Nil
Local oStructOHW := FWFormStruct(1, "OHW")
Local oStructOHB := FWFormStruct(1, "OHB")

	oStructOHB:SetProperty("*", MODEL_FIELD_INIT, {|| Nil})
	oStructOHB:SetProperty('OHB_DNATOR', MODEL_FIELD_INIT, {|| IF(!INCLUI, GetAdvFVal('SED',"ED_DESCRIC", xFilial('SED') + OHB->OHB_NATORI, 1, ""), "")})
	oStructOHB:SetProperty('OHB_DNATDE', MODEL_FIELD_INIT, {|| IF(!INCLUI, GetAdvFVal('SED',"ED_DESCRIC", xFilial('SED') + OHB->OHB_NATDES, 1, ""), "")})
	oStructOHB:SetProperty('OHB_DMOELC', MODEL_FIELD_INIT, {|| IF(!INCLUI, GetAdvFVal('CTO',"CTO_SIMB"  , xFilial('CTO') + OHB->OHB_CMOELC, 1, ""), "")})
	oStructOHB:SetProperty('OHB_DMOEC' , MODEL_FIELD_INIT, {|| IF(!INCLUI, GetAdvFVal('CTO',"CTO_SIMB"  , xFilial('CTO') + OHB->OHB_CMOEC , 1, ""), "")})

	oStructOHB:AddField(AllTrim('') , ; // [01] C Titulo do campo
	                    AllTrim('') , ; // [02] C ToolTip do campo
	                    'OHB_LEGEND', ; // [03] C identificador (ID) do Field
	                    'C'         , ; // [04] C Tipo do campo
	                    50          , ; // [05] N Tamanho do campo
	                    0           , ; // [06] N Decimal do campo
	                    Nil         , ; // [07] B Code-block de validacao do campo
	                    Nil         , ; // [08] B Code-block de validacao When do campo
	                    Nil         , ; // [09] A Lista de valores permitido do campo
	                    Nil         , ; // [10] L Indica se o campo tem preenchimento obrigatório
	                    {|| IF(!INCLUI .And. OHB->OHB_ORIGEM == "8", IIF(GetAdvFVal ('SED',"ED_TPCOJR", xFilial('SED') + OHB->OHB_NATDES, 1, "") == "7", "BR_VERDE", "BR_VERMELHO"), "")}, ; // [11] B Code-block de inicializacao do campo
	                    Nil         , ; // [12] L Indica se trata de um campo chave
	                    Nil         , ; // [13] L Indica se o campo pode receber valor em uma operacao de update.
	                    .T.)            // [14] L Indica se o campo e virtual

	oModel:= MPFormModel():New("JURA284", /*Pre-Validacao*/, /*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("OHWMASTER", Nil, oStructOHW, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:AddGrid('OHBDETAIL', 'OHWMASTER' /*cOwner*/, oStructOHB, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:AddGrid('OHBDETAIL2', 'OHWMASTER' /*cOwner*/, oStructOHB, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:SetRelation('OHBDETAIL', {{'OHB_FILIAL', "XFILIAL('OHB')"}, {'OHB_LOTE', 'OHW_LOTE'}}, OHB->(IndexKey(4)))
	oModel:SetRelation('OHBDETAIL2', {{'OHB_FILIAL', "XFILIAL('OHB')"}, {'OHB_LOTE', 'OHW_LOTE'}}, OHB->(IndexKey(4)))
	oModel:GetModel("OHWMASTER"):SetDescription(STR0007) // "Folha de Pagamento"
	oModel:GetModel("OHBDETAIL"):SetDescription(STR0008) // "Lancamentos de Fechamento de CC Participante"
	oModel:GetModel("OHBDETAIL"):SetLoadFilter( , "OHB_ORIGEM = '8'")
	oModel:GetModel("OHBDETAIL2"):SetLoadFilter( , "OHB_ORIGEM <> '8'")
	oModel:SetOptional("OHBDETAIL", .T.)
	oModel:SetOptional("OHBDETAIL2", .T.)

	oModel:SetPrimaryKey({"OHW_FILIAL", "OHW_LOTE"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Natureza Juridica

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel("JURA284")
Local oStructOHW := FWFormStruct(2, "OHW")
Local oStruOHB   := FWFormStruct(2, 'OHB', {|x| Alltrim(x) $ 'OHB_CODIGO|OHB_DTINCL|OHB_NATORI|OHB_DNATOR|OHB_NATDES|OHB_DNATDE|OHB_VALOR|OHB_ANOMES|OHB_NUMPG|OHB_DMOELC|OHB_DMOEC|OHB_VALORC'})
Local oStruOHB2  := FWFormStruct(2, 'OHB', {|x| Alltrim(x) $ 'OHB_CODIGO|OHB_DTINCL|OHB_DTLANC|OHB_NATORI|OHB_DNATOR|OHB_NATDES|OHB_DNATDE|OHB_VALOR|OHB_DMOELC|OHB_DMOEC|OHB_VALORC'})

	oStructOHW:RemoveField("OHW_CPART")
	oStruOHB:AddField('OHB_LEGEND'     , ; // [01] C Nome do Campo
	                  '00'             , ; // [02] C Ordem
	                  AllTrim('')      , ; // [03] C Titulo do campo
	                  AllTrim('')      , ; // [04] C Descricao do campo
	                  {STR0009}        , ; // [05] A Array com Help // 'Legenda'
	                  'C'              , ; // [06] C Tipo do campo
	                  '@BMP'           , ; // [07] C Picture
	                  Nil              , ; // [08] B Bloco de Picture Var
	                  ''               , ; // [09] C Consulta F3
	                  .T.              , ; // [10] L Indica se o campo e alteravel
	                  Nil              , ; // [11] C Pasta do campo
	                  Nil              , ; // [12] C Agrupamento do campo
	                  Nil              , ; // [13] A Lista de valores permitido do campo (Combo)
	                  Nil              , ; // [14] N Tamanho maximo da maior opcao do combo
	                  Nil              , ; // [15] C Inicializador de Browse
	                  .T.              , ; // [16] L Indica se o campo e virtual
	                  Nil              , ; // [17] C Picture Variavel
	                  Nil              )   // [18] L Indica pulo de linha após o campo

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("OHWFIELD"  , oStructOHW, "OHWMASTER")
	oView:AddGrid("OHBGRID_GER", oStruOHB  , "OHBDETAIL")
	oView:AddGrid("OHBGRID_VIN", oStruOHB2 , "OHBDETAIL2")

	oView:CreateHorizontalBox('FORMFIELD', 40,,,,)
	oView:SetOwnerView("OHWFIELD", "FORMFIELD")

	oView:CreateHorizontalBox('FORMGRID' , 60,,,,)
	oView:SetOwnerView("OHBGRID_GER", "FORMGRID")
	oView:SetOwnerView("OHBGRID_VIN", "FORMGRID")

	oView:CreateFolder('FOLDER_01', "FORMGRID")
	oView:AddSheet("FOLDER_01", "ABA_GER", STR0008 ) // "Lancamentos de Fechamento de CC Participante"
	oView:AddSheet("FOLDER_01", "ABA_VIN", STR0010 ) // "Lancamentos vinculados no Lote"

	oView:CreateHorizontalBox("FORMFOLDER_GER", 100,,, "FOLDER_01", "ABA_GER")
	oView:CreateHorizontalBox("FORMFOLDER_VIN", 100,,, "FOLDER_01", "ABA_VIN")
	oView:SetOwnerView("OHBGRID_GER", "FORMFOLDER_GER")
	oView:SetOwnerView("OHBGRID_VIN", "FORMFOLDER_VIN")

	oView:SetNoInsertLine("OHBGRID_GER")
	oView:SetNoDeleteLine("OHBGRID_GER")
	oView:SetNoUpdateLine("OHBGRID_GER")

	oView:SetNoInsertLine("OHBGRID_VIN")
	oView:SetNoDeleteLine("OHBGRID_VIN")
	oView:SetNoUpdateLine("OHBGRID_VIN")

	oView:SetViewProperty("OHBGRID_GER", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| Iif(Alltrim(cFieldName) == "OHB_LEGEND", Jur284Leg(), Nil)}})

	oView:SetCloseOnOk({|| .T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur284Leg
Define a cor da legenda do campo OHB_LEGEND e exibe a tela da Ledenda

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function Jur284Leg()
Local oLegend := FWLegend():New()

	// Adiciona descricao para cada legenda
	oLegend:Add( { || }, 'BR_VERDE'   , STR0011) // 'Credito na conta do profissional'
	oLegend:Add( { || }, 'BR_VERMELHO', STR0012) // 'Debito na conta do profissional'

	// Ativa a Legenda
	oLegend:Activate()

	// Exibe a Tela de Legendas
	oLegend:View()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J284GerLot
Funcao para gerar o lote e Lancamentos Naturezas e Folha de Pagamento

@param  dDtFech, Data do Fechamento

@Return lProc,   Lote gerado

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Function JURA284GLt(dDtFech, lAutomato)
Local cTmpOHB     := "" // Lancamentos a serem processados
Local cUpdOHB     := "" // Co.And. de atualizacao da tabela
Local cMsgRet     := "" // Mensagem de Erro
Local cSiglaPart  := AllTrim(JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__CUSERID), "RD0_SIGLA"))
Local cIntGPE     := SuperGetMV("MV_JINTGPE", .F., "1") // Habilita Integracao GPE 1= Nao, 2= Sim
Local cConcat     := IIf(Upper( TcGetDb() ) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")
Local lIntGPE     := cIntGPE == "2" // Habilita Integracao GPE?
Local lProc       := .T. // Retorno da rotina
Local lIncNat     := .T. // Natureza a ser inserida
Local aStruQry    := {}  // Estrutura da Tabela de Natureza
Local oTmpNat     := Nil // Tabela de Naturezas
Local oTmpLanc    := Nil // Temporaria de lancto
Local oTmpUpd     := Nil // Tabela para Update da OHB
Local oMdlJura284 := Nil // Modelo de Lote de Lancamentos
Local oTmpLDet    := NIL //Tabela temporaria de lancamento - detalhe
Local lNatDupl    := .F. //Existem naturezas com participantes duplcicados
Local cRegs       := "" //Registros de Naturezas duplicados
Local lIncFol     := .F. //Existem regitros validos para folha de pagamento?
Local aOfNat      := {} //Campos a Ofuscar do Lancamentos de Naturezas
Local aOfPart     := {} //Campos a Ofuscar do Castro de Participantes
Local lNurNat     := !Empty(SuperGetMV("MV_JNATFEP", .F., "")) .And. NUR->(ColumnPos("NUR_NATURE")) > 0
Local lVerbTran   := AliasInDic("OI0") .And. ChkFile("OI0")

Default dDtFech   := CToD("")
Default lAutomato := .F.

	If !Empty(cSiglaPart)

		If !Empty(dDtFech)
			lNatDupl := FindFunction("Ja159NatDup") .AND. Ja159NatDup(@cRegs)

			If !lNatDupl
				cQuery := J284QryFin(DtoS(dDtFech), lIntGPE, lNurNat)
				
				cTmpOHB :=  GetNextAlias()
				DbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cTmpOHB, .T., .F.)

				If (cTmpOHB)->(!Eof())

					If lIntGPE
						// Tabela de lancamentos para a Folha - Cabecalho
						aStruQry := {{"RDZ_CODENT", GetSx3Cache("RDZ_CODENT", "X3_TIPO"), TamSx3("RDZ_CODENT")[1], TamSx3("RDZ_CODENT")[2]},;
						             { "RA_FILIAL" , GetSx3Cache("RA_FILIAL" , "X3_TIPO"), TamSx3("RA_FILIAL")[1] , TamSx3("RA_FILIAL")[2]},;
						             { "RA_MAT"    , GetSx3Cache("RA_MAT"    , "X3_TIPO"), TamSx3("RA_MAT")[1]    , TamSx3("RA_MAT")[2]},;
						             { "RD0_CODIGO", GetSx3Cache("RD0_CODIGO", "X3_TIPO"), TamSx3("RD0_CODIGO")[1], TamSx3("RD0_CODIGO")[2]},;
						             { "RD0_NOME"  , GetSx3Cache("RD0_NOME"  , "X3_TIPO"), TamSx3("RD0_NOME")[1]  , TamSx3("RD0_NOME")[2]},;
						             { "RD0_SIGLA"  , GetSx3Cache("RD0_SIGLA"  , "X3_TIPO"), TamSx3("RD0_SIGLA")[1]  , TamSx3("RD0_SIGLA")[2]},;
						             { "RGB_PERIOD", GetSx3Cache("RGB_PERIOD", "X3_TIPO"), TamSx3("RGB_PERIOD")[1], TamSx3("RGB_PERIOD")[2]},;
						             { "RGB_ROTEIR", GetSx3Cache("RGB_ROTEIR", "X3_TIPO"), TamSx3("RGB_ROTEIR")[1], TamSx3("RGB_ROTEIR")[2]},;
						             { "RGB_SEMANA", GetSx3Cache("RGB_SEMANA", "X3_TIPO"), TamSx3("RGB_SEMANA")[1], TamSx3("RGB_SEMANA")[2]},;
						             { "RGB_PROCES", GetSx3Cache("RGB_PROCES", "X3_TIPO"), TamSx3("RGB_PROCES")[1], TamSx3("RGB_PROCES")[2]},;
						             { "RGB_CC"    , GetSx3Cache("RGB_CC"    , "X3_TIPO"), TamSx3("RGB_CC")[1]    , TamSx3("RGB_CC")[2]},;
						             { "RGB_CODFUN", GetSx3Cache("RGB_CODFUN", "X3_TIPO"), TamSx3("RGB_CODFUN")[1], TamSx3("RGB_CODFUN")[2]},;
						             { "VALIDFUNC" , "C", 1, 0},;
						             { "CODERRFUN" , "C", 5, 0};
						            }
						oTmpLanc := FWTemporaryTable():New(GetNextAlias(), aStruQry)
						oTmpLanc:AddIndex("1", {"RD0_CODIGO"})
						oTmpLanc:AddIndex("2", {"VALIDFUNC", "RD0_CODIGO"})
						oTmpLanc:Create()

						If __LGPD
							aEval(aStruQry, {|s| aAdd(aOfPart, s[1])})
							aStruQry := FwProtectedDataUtil():UsrNoAccessFieldsInList(aOfPart)
							aOfPart := {}
							AEval(aStruQry, {|x| AAdd( aOfPart, x:CFIELD)})
						EndIf

						// Tabela de lancamentos para a Folha - Detahe
						aStruQry := {{"RD0_CODIGO", GetSx3Cache("RD0_CODIGO", "X3_TIPO"), TamSx3("RD0_CODIGO")[1], TamSx3("RD0_CODIGO")[2]},;
						             {"RGB_PD"    , GetSx3Cache("RGB_PD"    , "X3_TIPO"), TamSx3("RGB_PD")[1]    , TamSx3("RGB_PD")[2]},;
						             {"RGB_VALOR" , GetSx3Cache("RGB_VALOR" , "X3_TIPO"), TamSx3("RGB_VALOR")[1] , TamSx3("RGB_VALOR")[2]};
						            }

						oTmpLDet := FWTemporaryTable():New(GetNextAlias(), aStruQry)
						oTmpLDet:AddIndex("1", {"RD0_CODIGO", "RGB_PD"})
						oTmpLDet:Create()

					EndIf

					// Tabela de Lancamentos de verbas - detalhe
					aStruQry := {{"OHB_NATORI", GetSx3Cache("OHB_NATORI", "X3_TIPO"), TamSx3("OHB_NATORI")[1], TamSx3("OHB_NATORI")[2]},;
					             {"OHB_CESCRO", GetSx3Cache("OHB_CESCRO", "X3_TIPO"), TamSx3("OHB_CESCRO")[1], TamSx3("OHB_CESCRO")[2]},;
					             {"OHB_CCUSTO", GetSx3Cache("OHB_CCUSTO", "X3_TIPO"), TamSx3("OHB_CCUSTO")[1], TamSx3("OHB_CCUSTO")[2]},;
					             {"OHB_SIGLAO", GetSx3Cache("OHB_SIGLAO", "X3_TIPO"), TamSx3("OHB_SIGLAO")[1], TamSx3("OHB_SIGLAO")[2]},;
					             {"OHB_NATDES", GetSx3Cache("OHB_NATDES", "X3_TIPO"), TamSx3("OHB_NATDES")[1], TamSx3("OHB_NATDES")[2]},;
					             {"OHB_CESCRD", GetSx3Cache("OHB_CESCRD", "X3_TIPO"), TamSx3("OHB_CESCRD")[1], TamSx3("OHB_CESCRD")[2]},;
					             {"OHB_CCUSTD", GetSx3Cache("OHB_CCUSTD", "X3_TIPO"), TamSx3("OHB_CCUSTD")[1], TamSx3("OHB_CCUSTD")[2]},;
					             {"OHB_SIGLAD", GetSx3Cache("OHB_SIGLAD", "X3_TIPO"), TamSx3("OHB_SIGLAD")[1], TamSx3("OHB_SIGLAD")[2]},;
					             {"OHB_VLNAC" , GetSx3Cache("OHB_VLNAC" , "X3_TIPO"), TamSx3("OHB_VLNAC")[1], TamSx3("OHB_VLNAC")[2]},;
					             {"VALIDNAT"  , "C", 1, 0},;
					             {"CODERRNAT" , "C", 5, 0};
					            }

					oTmpNat := FWTemporaryTable():New(GetNextAlias(), aStruQry)
					oTmpNat:AddIndex("1", {"OHB_NATORI"})
					oTmpNat:AddIndex("2", {"VALIDNAT", "OHB_NATORI"})
					oTmpNat:Create()
					If __LGPD
						aEval(aStruQry, {|s| aAdd(aOfNat, s[1])})
						aStruQry := FwProtectedDataUtil():UsrNoAccessFieldsInList(aOfNat)
						aOfNat := {}
						AEval(aStruQry, {|x| AAdd( aOfNat, x:CFIELD)})
					EndIf
					JurFreeArr(aStruQry)

					oTmpUpd := JurCriaTmp(GetNextAlias(), "SELECT OHB_FILIAL, OHB_CODIGO FROM " + RetSqlName("OHB") + " WHERE 1 = 2", "OHB")[1]

					J284PrcReg(lIntGPE, cTmpOHB, oTmpNat, oTmpUpd,oTmpLanc, oTmpLDet, @cMsgRet, lNurNat, lVerbTran)

					lProc := J284VlNat(@cMsgRet, oTmpNat, @lIncNat, aOfNat)

					If lIntGPE
						lProc := lProc .And. J284VlGPE(@cMsgRet, oTmpLanc, oTmpLDet, @lIncFol, aOfPart)
					EndIf

					If lProc .And. lIncNat
						If !(lProc := CtbValiDt(, Date(), .F.,,, {"PFS001"},)) // Calendário Válido
							cMsgRet += CRLF + STR0014 + CRLF + I18n(STR0013, {cFilAnt}) // "Calendário Contábil bloqueado."#"Verifique o bloqueio do processo 'PFS001' no Calendário Contábil da filial '#1', para o período da data do lançamento."
						EndIf
					EndIf

					If lProc
						BEGIN TRANSACTION
							// Inclui o  lote de lancamentos
							oMdlJura284 := FwLoadModel("JURA284")
							oMdlJura284:SetOperation(3)
							oMdlJura284:Activate()

							lProc := lProc .And. oMdlJura284:SetValue("OHWMASTER", "OHW_STATUS", "1")
							lProc := lProc .And. oMdlJura284:SetValue("OHWMASTER", "OHW_DTINCL", Date())
							lProc := lProc .And. oMdlJura284:SetValue("OHWMASTER", "OHW_SIGLA" , cSiglaPart)
							lProc := lProc .And. oMdlJura284:SetValue("OHWMASTER", "OHW_INTGPE", cIntGPE)
							lProc := lProc .And. oMdlJura284:SetValue("OHWMASTER", "OHW_DTFECH", dDtFech)

							lProc := lProc .And. oMdlJura284:VldData() .And. oMdlJura284:Commitdata()
							
							If !lProc
								cMsgRet += CRLF + JurShowErro(oMdlJura284:GetModel():GetErrormessage(), Nil, Nil, .F., .F.)
							Else
								// Rotina para gerar os lancamentos
								lProc := Jur284GLan(oMdlJura284:GetValue("OHWMASTER", "OHW_LOTE"), @cMsgRet, oTmpNat, cSiglaPart)
							EndIf

							If lProc .And. lIntGPE
								//Rotina de Geracao de Verbas para a Folha de Pagamento
								lProc := Jur284GGPE(oMdlJura284:GetValue("OHWMASTER", "OHW_LOTE"), @cMsgRet, oTmpLanc, oTmpLDet)
							EndIf

							If lProc
								cUpdOHB := "UPDATE " + RetSqlName("OHB") + " SET " + ;
								           "OHB_LOTE = '" + oMdlJura284:GetValue("OHWMASTER", "OHW_LOTE") + "' " + ;
								           "WHERE D_E_L_E_T_ = ' ' AND OHB_FILIAL" + cConcat + "OHB_CODIGO IN (SELECT OHB_FILIAL" + cConcat + " OHB_CODIGO  FROM " + oTmpUpd:GetRealName() + ") "
								If TCSQLExec(cUpdOHB) < 0 // Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()
									cMsgRet += CRLF +  STR0015 + AllTrim(TCSQLError()) + "] " //"Problemas ao atualizar lançamentos ["
									lProc := .F.
								EndIf
							EndIf

							If !lProc
								DisarmTransaction()
								
								// O DisarmTransaction nao esta desconsiderando o commit do modelo na linha 358
								OHW->(DbSetOrder(1)) // OHW_FILIAL + OHW_LOTE
								If OHW->(DbSeek(xFilial("OHW") + oMdlJura284:GetValue("OHWMASTER", "OHW_LOTE")))
									oMdlJura284:DeActivate()
									oMdlJura284:SetOperation(5)
									oMdlJura284:Activate()
									oMdlJura284:CommitData()
								EndIf
							EndIf

						END TRANSACTION
						
						oMdlJura284:DeActivate()
						oMdlJura284:Destroy()
					EndIf

					If lIntGPE
						oTmpLanc:Delete()
						oTmpLDet:Delete()
					EndIf
					oTmpNat:Delete()
					oTmpUpd:Delete()
					JurFreeArr(aStruQry)
				Else
					cMsgRet := CRLF + STR0016 // "Nao encontrados lancamentos para processar o fechamento"
					lProc := .F.
				EndIf
				(cTmpOHB)->(DbCloseArea())
			Else
				lProc := .F.
				cMsgRet := CRLF + STR0038 + cRegs // "Localizadas Naturezas vinculadas a mais de um participante: "
			EndIf
		Else
			cMsgRet := CRLF + STR0017 // "Processamento cancelado pelo usuário"
			lProc := .F.
		EndIf
	Else
		cMsgRet := CRLF + STR0018 // "Não localizado Participante Jurídico vinculado ao usuário logado"
		lProc := .F.
	EndIf

	// Final do Processamento, exibe a mensagem de erro
	If !lProc
		If !lAutomato
			JurErrLog(Substr(cMsgRet, Len(CRLF)+1), STR0019)  // "Problemas ao gerar Lote"
		Else
			Help( ,,, 'JURA284GLt', STR0019 + ": " + Substr(cMsgRet, Len(CRLF)+1), 1, 0)
		EndIf
	EndIf

Return lProc
//-------------------------------------------------------------------
/*/{Protheus.doc} Jur284GLan
Funcao de Gravacao dos Lancamentos de Fechamento 

@param cLote,     Lote de Lancamentos
@param cMsgProc,  Mensagem de Erro
@param oTmpNat,   Tabela de Naturezas
@param cSiglaLan, Sigla do Participante

@Return lProc,    Gravacao realizada

@author fabiana.silva
@since 28/10/2020

/*/
//-------------------------------------------------------------------
Static Function Jur284GLan( cLote, cMsgProc,  oTmpNat, cSiglaLan)
Local lProc      := .T.
Local cAliasNat  := oTmpNat:GetAlias()
Local cHistpad   := SuperGetMv("MV_JHISTTR", .F., "") // Histórico Padrao 
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')   // Moeda Nacional
Local oMdJura241 := Nil // Modelo de Lancamentos

	(cAliasNat)->(DbSetOrder(2)) //VALIDNAT + OHB_NATORI
	(cAliasNat)->(DbSeek("1")) 

	oMdJura241 := FwLoadModel("JURA241")

	Do While (cAliasNat)->(!Eof()) .And. (cAliasNat)->VALIDNAT <> "2"
		If (cAliasNat)->OHB_VLNAC <> 0
			oMdJura241:SetOperation(3)
			If !oMdJura241:IsActive()
				oMdJura241:Activate()
			EndIf

			If (cAliasNat)->OHB_VLNAC > 0 // Sai da Natureza do Participante
				cNatOri   := (cAliasNat)->OHB_NATORI
				cEscriOri := (cAliasNat)->OHB_CESCRO
				cCCusOri  := (cAliasNat)->OHB_CCUSTO
				cSiglaOri := (cAliasNat)->OHB_SIGLAO

				cNatDes   := (cAliasNat)->OHB_NATDES
				cEscriDes := (cAliasNat)->OHB_CESCRD
				cCCusDes  := (cAliasNat)->OHB_CCUSTD
				cSiglaDes := (cAliasNat)->OHB_SIGLAD
			Else
				cNatOri   := (cAliasNat)->OHB_NATDES // Sai da Natureza da Categoria
				cEscriOri := (cAliasNat)->OHB_CESCRD
				cCCusOri  := (cAliasNat)->OHB_CCUSTD
				cSiglaOri := (cAliasNat)->OHB_SIGLAD

				cNatDes   := (cAliasNat)->OHB_NATORI
				cEscriDes := (cAliasNat)->OHB_CESCRO
				cCCusDes  := (cAliasNat)->OHB_CCUSTO
				cSiglaDes := (cAliasNat)->OHB_SIGLAO
			EndIf

			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_ORIGEM", "8") // Fech. C/C Prof.
			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_NATORI", cNatOri)

			If !Empty(cEscriOri)
				lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_CESCRO", cEscriOri)
			EndIf
			If !Empty(cCCusOri)
				lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_CCUSTO", cCCusOri)
			EndIf
			If !Empty(cSiglaOri)
				lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_SIGLAO", cSiglaOri)
			EndIf

			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_NATDES", cNatDes)
			If !Empty(cEscriDes)
				lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_CESCRD", cEscriDes)
			EndIf
			If !Empty(cCCusDes)
				lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_CCUSTD", cCCusDes)
			EndIf
			If !Empty(cSiglaDes)
				lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_SIGLAD",cSiglaDes)
			EndIf
			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_SIGLA" , cSiglaLan)
			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_DTLANC", Date())
			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_CMOELC", cMoedaNac)
			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_VALOR" , Abs((cAliasNat)->OHB_VLNAC))
			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_CHISTP", cHistpad)
			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_LOTE"  , cLote)
			lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_FILORI", cFilAnt)

			If Empty(oMdJura241:GetValue("OHBMASTER", "OHB_HISTOR"))
				lProc := lProc .And. oMdJura241:SetValue("OHBMASTER", "OHB_HISTOR", STR0020 + cLote) // "Fechamento de CC Lote: "
			EndIf
			lProc := lProc .And. oMdJura241:VldData() .And. oMdJura241:Commitdata()
			
			If !lProc
				cMsgProc += CRLF + JurShowErro(oMdJura241:GetModel():GetErrormessage(), Nil, Nil, .F., .F.)
			EndIf

			If oMdJura241:IsActive()
				oMdJura241:DeActivate()
			EndIf

			If !lProc
				Exit
			EndIf
		EndIf
		(cAliasNat)->(DbSkip())
	EndDo

	If !oMdJura241:IsActive()
		oMdJura241:DeActivate()
	EndIf

	oMdJura241:Destroy()

Return lProc

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR284DlGL
Funcao de selecao da Data Final dos Lancamentos  e processamento do Lote

@param dDtFech, Data Final

@Return dDtFech, Data Final

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Function JUR284DlGL(dDtFech)
Local oDlg      := Nil
Local oDataFec  := Nil
Local oMainColl := Nil
Local oLayer    := FWLayer():New()

	oDlg := FWDialogModal():New()
	oDlg:SetFreeArea(100, 50)
	oDlg:SetEscClose(.F.)    // Nao permite fechar a tela com o ESC
	oDlg:SetCloseButton(.F.) // Nao permite fechar a tela com o "X"
	oDlg:SetBackground(.T.)  // Escurece o fundo da janela
	oDlg:SetTitle(STR0004)   // "Gerar Lote"
	oDlg:CreateDialog()

	oLayer:Init(oDlg:GetPanelMain(), .F.)   // Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:AddCollumn("MainColl", 100, .F.) // Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel("MainColl")
	oDataFec  := TJurPnlCampo():New(015, 035, 060, 022, oMainColl, STR0021, ("OHW_DTINCL"), {|| }, {|| },,,,) // "Data da Movimentacao"
	oDlg:AddOkButton({|| FWMsgRun(, {|| {dDtFech := oDataFec:Valor, JURA284GLt(dDtFech)}, oDlg:oOwner:End()}, STR0036, STR0037)}) // "Gerando lote" # "Aguarde"

	oDlg:AddCloseButton({|| dDtFech := CToD("  /  /    "), oDlg:oOwner:End()})
	oDlg:Activate()

Return dDtFech

//-------------------------------------------------------------------
/*/{Protheus.doc} J284QryFin
Funcao para gerar a query de Lancamentos

@param cDataLim - Data do Fechamento
@param lIntGPE  - Indica se a integracao com o GPE esta ativa
@param lNurNat  - Indica se utiliza o novo campo de natureza do participante

@Return cQuery  - Query Gerada

@author fabiana.silva
@since 28/10/2020

/*/
//-------------------------------------------------------------------
Static Function J284QryFin(cDataLim, lIntGPE, lNurNat)
Local cQuery := ""

	cQuery :=    " SELECT TAB.* "
	cQuery +=      " FROM ( "
	cQuery +=            " SELECT OHBT.*, SRV.RV_COD JURVERO, SRV.RV_TIPOCOD JURVERTPO "
	cQuery +=              " FROM ( SELECT W.* "
	cQuery +=                        "FROM "
	cQuery +=                              " ( SELECT OHB.OHB_FILIAL, OHB.OHB_CODIGO, OHB.OHB_DTLANC, OHB.OHB_NATORI, OHB.OHB_NATDES, "
	cQuery +=                                       " OHB.OHB_VLNAC * -1 OHB_VLNACO, OHB.OHB_VLNAC * 1 OHB_VLNACD, OHB.R_E_C_N_O_ RECNO, OHB.OHB_CPAGTO, OHB.OHB_ORIGEM OHB_ORIGEO, "
    cQuery +=                                       " SED.ED_CCJURI ED_CCJURIO, SED2.ED_CCJURI ED_CCJURID, SED.ED_TPCOJR ED_TPCOJRO, SED2.ED_TPCOJR ED_TPCOJRD, SED.ED_JURVERB, "
	cQuery +=                                       " RD0.RD0_NOME RD0_NOMEO, RD0.RD0_SIGLA RD0_SIGLAO, RD0.RD0_CC RD0_CCO, NUR.NUR_CESCR NUR_CESCRO, RDZ.RDZ_CODENT RDZ_CODENO, "
	cQuery +=                                       " RDZ.RDZ_ENTIND RDZ_INDENO, NUR.NUR_CPART NUR_CPARTO, NUR.NUR_CCAT NUR_CCATO, SED3.ED_CCJURI ED_CCNATO, "
	cQuery +=                                       " NRN.NRN_NATSLD NRN_NATSLO, SRV.RV_COD JURVERN, SRV.RV_TIPOCOD JURVERTPN, SED3.ED_TPCOJR ED_TPCONO, " + Iif(!lNurNat, "SA2.A2_NATUREZ", "NUR.NUR_NATURE") + " NATUREO, "
	cQuery +=                                       " ' ' RD0_NOMED, ' ' RD0_SIGLAD, ' ' RD0_CCD, ' ' NUR_CESCRD, ' ' RDZ_CODEND, "
	cQuery +=                                       " ' ' RDZ_INDEND, ' ' NUR_CPARTD, ' ' NUR_CCATD, "
	cQuery +=                                       " ' ' ED_CCNATD, ' ' NRN_NATSLD , ' ' ED_TPCOND, ' ' NATURED, ' ' OHB_CPAGTD, ' ' OHB_ORIGED, 'O' TPREG"
	cQuery +=                                  " FROM " + RetSqlName("OHB") + " OHB "
	cQuery +=                                 " INNER JOIN " + RetSqlName("SED") + " SED "
	cQuery +=                                    " ON SED.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=                                   " AND SED.ED_CODIGO = OHB.OHB_NATORI "
	cQuery +=                                   " AND SED.ED_TPCOJR = '7' "
	cQuery +=                                   " AND SED.D_E_L_E_T_ = ' ' "
	cQuery +=                                 " INNER JOIN " + RetSqlName("SED") + " SED2 "
	cQuery +=                                    " ON SED2.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=                                   " AND SED2.ED_CODIGO = OHB.OHB_NATDES "
	cQuery +=                                   " AND SED2.D_E_L_E_T_ = ' ' "
	cQuery +=                                 " INNER JOIN " + RetSqlName("NUR") + " NUR "
	cQuery +=                                    " ON NUR.NUR_FILIAL = '" + xFilial("NUR") + "' "
	cQuery +=                                   " AND NUR.NUR_FORNAT = '1' " // Solicitante
	cQuery +=                                   " AND NUR.D_E_L_E_T_ = ' ' "
	If lNurNat
		cQuery +=                               " AND NUR.NUR_NATURE =  OHB.OHB_NATORI "
	EndIf
	cQuery +=                                 " INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery +=                                    " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=                                   " AND RD0.RD0_TPJUR  = '1' " // Solicitante
	cQuery +=                                   " AND RD0.D_E_L_E_T_ = ' ' "
	cQuery +=                                   " AND RD0.RD0_CODIGO = NUR.NUR_CPART " // Solicitante
	If !lNurNat
		cQuery +=                             " INNER JOIN " + RetSqlName("SA2") + " SA2 "
		cQuery +=                                " ON SA2.A2_NATUREZ =  OHB.OHB_NATORI "
		cQuery +=                               " AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		cQuery +=                               " AND SA2.D_E_L_E_T_ = ' ' "
		cQuery +=                               " AND RD0.RD0_FORNEC = SA2.A2_COD " // Solicitante
		cQuery +=                               " AND RD0.RD0_LOJA = SA2.A2_LOJA " // Solicitante
	EndIf
	cQuery +=                                 " INNER JOIN " + RetSqlName("NRN") + " NRN "
	cQuery +=                                    " ON NRN.NRN_FILIAL = '" + xFilial("NRN") + "' "
	cQuery +=                                   " AND NUR.NUR_CCAT = NRN.NRN_COD "
	cQuery +=                                  " LEFT JOIN " + RetSqlName("RDZ") + " RDZ "
	cQuery +=                                    " ON RDZ.RDZ_FILIAL = '" + xFilial("RDZ") + "' "
	cQuery +=                                   " AND RDZ.RDZ_CODRD0 = RD0.RD0_CODIGO" // Solicitante
	cQuery +=                                   " AND RDZ.RDZ_ENTIDA = 'SRA' "
	cQuery +=                                   " AND RDZ.RDZ_EMPENT = '" + cEmpAnt + "' "
	cQuery +=                                   " AND RDZ.RDZ_FILENT = '" + cFilAnt + "' " // Solicitante
	cQuery +=                                   " AND RDZ.D_E_L_E_T_ = ' ' "
	cQuery +=                                  " LEFT JOIN " + RetSqlName("SED") +" SED3 "
	cQuery +=                                    " ON SED3.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=                                   " AND SED3.ED_CODIGO = NRN.NRN_NATSLD " // Solicitante
	cQuery +=                                   " AND SED3.D_E_L_E_T_ = ' ' "
	cQuery +=                                  " LEFT JOIN " + RetSqlName("SRV") + " SRV "
	cQuery +=                                    " ON SRV.RV_FILIAL = '" + xFilial("SRV") + "' "
	cQuery +=                                   " AND SRV.RV_COD = SED.ED_JURVERB "
	cQuery +=                                   " AND SRV.D_E_L_E_T_ = ' ' "
	cQuery +=                                 " WHERE OHB.OHB_FILIAL = '" + xFilial("OHB") + "'
	cQuery +=                                   " AND OHB.OHB_DTLANC <= '" + cDataLim + "' "
	cQuery +=                                   " AND OHB.OHB_LOTE = ' ' "
	cQuery +=                                   " AND OHB.D_E_L_E_T_ = ' ' "
    cQuery +=                                "  UNION "
	cQuery +=                                " SELECT OHB.OHB_FILIAL, OHB.OHB_CODIGO, OHB.OHB_DTLANC, OHB.OHB_NATORI, OHB.OHB_NATDES, "
	cQuery +=                                       " OHB.OHB_VLNAC * -1 OHB_VLNACO, OHB.OHB_VLNAC * 1 OHB_VLNACD, OHB.R_E_C_N_O_ RECNO, ' ' OHB_CPAGTO, ' ' OHB_ORIGEO, "
    cQuery +=                                       " SED.ED_CCJURI ED_CCJURIO, SED2.ED_CCJURI ED_CCJURID, SED.ED_TPCOJR ED_TPCOJRO, SED2.ED_TPCOJR ED_TPCOJRD, SED.ED_JURVERB, "
	cQuery +=                                       " ' ' RD0_NOMEO, ' ' RD0_SIGLAO, ' ' RD0_CCO, ' ' NUR_CESCRO, ' ' RDZ_CODENO, "
	cQuery +=                                       " ' ' RDZ_INDENO, ' ' NUR_CPARTO, ' ' NUR_CCATO, ' ' ED_CCNATO, "
	cQuery +=                                       " ' ' NRN_NATSLO, ' ' JURVERN, ' ' JURVERTPN, ' ' ED_TPCONO, ' ' NATUREO, "
	cQuery +=                                       " RD0.RD0_NOME RD0_NOMED, RD0.RD0_SIGLA RD0_SIGLAD, RD0.RD0_CC RD0_CCD, NUR.NUR_CESCR NUR_CESCRD, RDZ.RDZ_CODENT RDZ_CODEND, "
	cQuery +=                                       " RDZ.RDZ_ENTIND RDZ_INDEND, NUR.NUR_CPART NUR_CPARTD, NUR.NUR_CCAT NUR_CCATD, "
	cQuery +=                                       " SED3.ED_CCJURI ED_CCNATD, NRN.NRN_NATSLD , SED3.ED_TPCOJR ED_TPCOND, " + IIf(!lNurNat, "SA2.A2_NATUREZ", "NUR.NUR_NATURE") + " NATURED, OHB.OHB_CPAGTO OHB_CPAGTD, OHB.OHB_ORIGEM OHB_ORIGED , 'D' TPREG"
	cQuery +=                                  " FROM " + RetSqlName("OHB") + " OHB "
	cQuery +=                                 " INNER JOIN " + RetSqlName("SED") + " SED2 "
	cQuery +=                                    " ON SED2.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=                                   " AND SED2.ED_CODIGO = OHB.OHB_NATDES "
	cQuery +=                                   " AND SED2.ED_TPCOJR = '7' "
	cQuery +=                                   " AND SED2.D_E_L_E_T_ = ' ' "
	cQuery +=                                 " INNER JOIN " + RetSqlName("SED") + " SED "
	cQuery +=                                    " ON SED.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=                                   " AND SED.ED_CODIGO = OHB.OHB_NATORI "
	cQuery +=                                   " AND SED.D_E_L_E_T_ = ' ' "
	cQuery +=                                 " INNER JOIN " + RetSqlName("NUR") + " NUR "
	cQuery +=                                    " ON NUR.NUR_FILIAL = '" + xFilial("NUR") + "' "
	cQuery +=                                   " AND NUR.NUR_FORNAT = '1' " // Solicitante
	cQuery +=                                   " AND NUR.D_E_L_E_T_ = ' ' "
	If lNurNat
		cQuery +=                               " AND NUR.NUR_NATURE =  OHB.OHB_NATDES "
	EndIf
	cQuery +=                                 " INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery +=                                    " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=                                   " AND RD0.RD0_TPJUR  = '1' " // Solicitante
	cQuery +=                                   " AND RD0.D_E_L_E_T_ = ' ' "
	cQuery +=                                   " AND RD0.RD0_CODIGO = NUR.NUR_CPART " // Solicitante
	If !lNurNat
		cQuery +=                             " INNER JOIN " + RetSqlName("SA2") + " SA2 "
		cQuery +=                                " ON SA2.A2_NATUREZ =  OHB.OHB_NATDES "
		cQuery +=                               " AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		cQuery +=                               " AND SA2.D_E_L_E_T_ = ' ' "
		cQuery +=                               " AND RD0.RD0_FORNEC = SA2.A2_COD " // Solicitante
		cQuery +=                               " AND RD0.RD0_LOJA = SA2.A2_LOJA " // Solicitante
	EndIf
	cQuery +=                                 " INNER JOIN " + RetSqlName("NRN") + " NRN "
	cQuery +=                                    " ON NRN.NRN_FILIAL = '" + xFilial("NRN") + "' "
	cQuery +=                                   " AND NUR.NUR_CCAT = NRN.NRN_COD
	cQuery +=                                  " LEFT JOIN " + RetSqlName("RDZ") + " RDZ "
	cQuery +=                                    " ON RDZ.RDZ_FILIAL = '" + xFilial("RDZ") + "' "
	cQuery +=                                   " AND RDZ.RDZ_CODRD0 = RD0.RD0_CODIGO" // Solicitante
	cQuery +=                                   " AND RDZ.RDZ_ENTIDA = 'SRA' "
	cQuery +=                                   " AND RDZ.RDZ_EMPENT = '" + cEmpAnt + "' "
	cQuery +=                                   " AND RDZ.RDZ_FILENT = '" + cFilAnt + "' " // Solicitante
	cQuery +=                                   " AND RDZ.D_E_L_E_T_ = ' ' "
	cQuery +=                                  " LEFT JOIN " + RetSqlName("SED") +" SED3 "
	cQuery +=                                    " ON SED3.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=                                   " AND SED3.ED_CODIGO = NRN.NRN_NATSLD " // Solicitante
	cQuery +=                                   " AND SED3.D_E_L_E_T_ = ' ' "
	cQuery +=                                  " LEFT JOIN " + RetSqlName("SRV") + " SRV "
	cQuery +=                                    " ON SRV.RV_FILIAL = '" + xFilial("SRV") + "' "
	cQuery +=                                   " AND SRV.RV_COD = SED.ED_JURVERB "
	cQuery +=                                   " AND SRV.D_E_L_E_T_ = ' ' "
	cQuery +=                                 " WHERE OHB.OHB_FILIAL = '" + xFilial("OHB") + "'
	cQuery +=                                   " AND OHB.OHB_DTLANC <= '" + cDataLim + "' "
	cQuery +=                                   " AND OHB.OHB_LOTE = ' ' "
	cQuery +=                                   " AND OHB.D_E_L_E_T_ = ' ' "
	cQuery +=                     " ) W ) OHBT " 
	cQuery +=              " LEFT JOIN " + RetSqlName("SRV") + " SRV "
	cQuery +=                " ON SRV.RV_FILIAL = '" + xFilial("SRV") + "' "
	cQuery +=               " AND SRV.RV_COD = OHBT.ED_JURVERB "
	cQuery +=               " AND SRV.D_E_L_E_T_  = ' ' "
	cQuery +=           " ) TAB "
	If !lIntGPE
		cQuery += " ORDER BY TAB.OHB_NATORI, TAB.OHB_DTLANC "
	Else
		cQuery += " ORDER BY TAB.NUR_CPARTO, JURVERO, TAB.NUR_CPARTD, TAB.JURVERN, TAB.OHB_DTLANC  "
	EndIf

	cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J284PrcReg
Funcao para processar os Lancamentos

@param lIntGPE,   Integra GPE
@param cTmpOHB,   Registros de Lancamentos
@param oTmpNat,   Naturezas processadas
@param oTmpUpd,   Registros com as chaves de Lancamentos a serem atualizados
@param oTmpLanc,  Lancamentos GPE Processados
@param oTmpLDet,  Tabela temporaria de lancamentos
@param cMsgRet,   Mensagem de Erro
@param lNurNat,   Indica se utiliza o novo campo de natureza do participante
@param lVerbTran, Indica que utiliza a verba na natureza transitoria

@Return lRet,     Registros Processados com sucesso

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function J284PrcReg(lIntGPE, cTmpOHB, oTmpNat, oTmpUpd, oTmpLanc, oTmpLDet, cMsgRet, lNurNat, lVerbTran)
Local cAliUpd   := oTmpUpd:GetAlias() // Alias dos Registros processados
Local lRet      := .T.
Local cPart     := ""
Local cNome     := ""
Local cIndSRA   := ""
Local cChvSRA   := ""
Local nValor    := 0
Local cVerba    := ""
Local cRoteiro  := ""
Local cTpVerb   := ""
Local cSigla    := ""
Local cNatPartO := ""
Local cNatPartD := ""
Local cQuery    := ""

	Do While (cTmpOHB)->(!Eof())
		
		If lNurNat
			cNatPartO := (cTmpOHB)->NATUREO // JurGetDados("NUR", 1, xFilial("NUR") + (cTmpOHB)->NUR_CPARTO, "NUR_NATURE") // NUR_FILIAL + NUR_CPART
			cNatPartD := (cTmpOHB)->NATURED // JurGetDados("NUR", 1, xFilial("NUR") + (cTmpOHB)->NUR_CPARTD, "NUR_NATURE")
		EndIf

		//Natureza Origem/Verba Credito
		ProcNat( (cTmpOHB)->ED_TPCOJRO, (cTmpOHB)->OHB_NATORI, (cTmpOHB)->OHB_VLNACO, (cTmpOHB)->ED_CCJURIO,;
				(cTmpOHB)->RD0_SIGLAO, (cTmpOHB)->RD0_CCO   , (cTmpOHB)->NUR_CESCRO, (cTmpOHB)->NUR_CPARTO,;
				(cTmpOHB)->NUR_CCATO , (cTmpOHB)->NRN_NATSLO, (cTmpOHB)->ED_CCNATO , oTmpNat, ;
				(cTmpOHB)->ED_TPCONO, lNurNat, cNatPartO, "O", (cTmpOHB)->TPREG)

		//Natureza Destino/Verba Debito
		ProcNat( (cTmpOHB)->ED_TPCOJRD, (cTmpOHB)->OHB_NATDES, (cTmpOHB)->OHB_VLNACD, (cTmpOHB)->ED_CCJURID,;
				(cTmpOHB)->RD0_SIGLAD, (cTmpOHB)->RD0_CCD   , (cTmpOHB)->NUR_CESCRD, (cTmpOHB)->NUR_CPARTD,;
				(cTmpOHB)->NUR_CCATD , (cTmpOHB)->NRN_NATSLD, (cTmpOHB)->ED_CCNATD , oTmpNat, ;
				(cTmpOHB)->ED_TPCOND, lNurNat, cNatPartD, "D", (cTmpOHB)->TPREG)

		If lIntGPE

			If ((cTmpOHB)->ED_TPCOJRO == "7" .And. (!lNurNat .And. "O" == (cTmpOHB)->TPREG));
				.Or. (lNurNat .And. (cTmpOHB)->ED_TPCOJRO == "7" .And. (cTmpOHB)->OHB_NATORI == cNatPartO)
				cPart      := (cTmpOHB)->NUR_CPARTO
				cNome      := (cTmpOHB)->RD0_NOMEO
				cIndSRA    := (cTmpOHB)->RDZ_INDENO
				cChvSRA    := (cTmpOHB)->RDZ_CODENO
				nValor     := (cTmpOHB)->OHB_VLNACO * -1
				cVerba     := (cTmpOHB)->JURVERN
				cTpVerb    := (cTmpOHB)->JURVERTPN
				cSigla     := (cTmpOHB)->RD0_SIGLAO 
			ElseIf ((cTmpOHB)->ED_TPCOJRD == "7" .And. (!lNurNat .And. "D" == (cTmpOHB)->TPREG)) .Or. ((!lNurNat .And. "D" == (cTmpOHB)->TPREG) .And. (cTmpOHB)->ED_TPCOJRD != "7");
					.Or. (lNurNat .And. (cTmpOHB)->ED_TPCOJRD == "7" .And. (cTmpOHB)->OHB_NATDES == cNatPartD)
				cPart      := (cTmpOHB)->NUR_CPARTD
				cNome      := (cTmpOHB)->RD0_NOMED
				cIndSRA    := (cTmpOHB)->RDZ_INDEND
				cChvSRA    := (cTmpOHB)->RDZ_CODEND
				nValor     := (cTmpOHB)->OHB_VLNACO
				cVerba     := (cTmpOHB)->JURVERO
				cTpVerb    := (cTmpOHB)->JURVERTPO
				If lVerbTran
					cVerba := TrataVerba((cTmpOHB)->ED_CCJURIO, (cTmpOHB)->OHB_CPAGTD, (cTmpOHB)->OHB_ORIGED, cVerba, @cTpVerb, @cQuery)
				EndIf
				cSigla     := (cTmpOHB)->RD0_SIGLAD
			EndIf
			ProcGPE(cPart, cNome, cIndSRA, cChvSRA,;
					nValor, cVerba, cRoteiro, oTmpLanc:GetAlias(),;
					oTmpLDet:GetAlias(), cTpVerb, (cTmpOHB)->ED_TPCOJRO, cSigla)
		EndIf

		Reclock(cAliUpd, .T.)
		(cAliUpd)->OHB_FILIAL := (cTmpOHB)->OHB_FILIAL
		(cAliUpd)->OHB_CODIGO := (cTmpOHB)->OHB_CODIGO
		(cAliUpd)->(MsUnLock())
		(cTmpOHB)->(DbSkip())
	EndDo

Return  lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcNat
Funcao para processar a Natureza

@param cTpCta,     Tipo de Conta
@param cNatLanc,   Natureza de Lancamento
@param nVlNac,     Valor nacional do lancamento
@param cCcJuri,    Centro de Custo Jura­dico da Natureza
@param cSigla,     Sigla do Participante
@param cCCusto,    Centro de Custo Jura­dico do Participante
@param cEscri,     Escritório do participante
@param cPart,      Código do participante
@param cCatPart,   Categoria do Participante
@param cNatCat,    Natureza da Categoria
@param cCCJurNat,  CC do Juri da Natureza da Categoria
@param oTmpNat,    Tabela Temporaria de Natureza
@param cTpCtaNat,  Tipo de Conta de Natureza
@param lNurNat,    Indica se utiliza o novo campo de natureza do participante
@param cNatPart,   Natureza vinculada no participante (NUR_NATURE)
@param cTpNat,     Tipo da Natureza Processada 
@param cTpNatReg,  Tipo da Natureza Registro


@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function ProcNat(cTpCta, cNatLanc, nVlNac, cCcJuri, cSigla, cCCusto, cEscri, cPart, ;
                        cCatPart, cNatCat, cCCJurNat, oTmpNat, cTpCtaNat, lNurNat, cNatPart, cTpNat, cTpNatReg)
Local cValidNat  := "1" // Natureza Valida? 1= Sim/2=Nao
Local cAliasNat  := oTmpNat:GetAlias()
Local cCodRet    := ""
Local lIsNatPart := cNatLanc == cNatPart

	If cTpCta == "7"  
		If (!lNurNat .And. cTpNat == cTpNatReg) .Or. (lNurNat .And. lIsNatPart)
			If Empty(cPart)
				cCodRet   := "1" // Natureza sem Participante definido
				cValidNat := "2"
			ElseIf  Empty(cCatPart)
				cCodRet   += "2" // Participante sem Categoria Definida
				cValidNat := "2"
			ElseIf  Empty(cSigla) .AND. (cCcJuri == "3" .OR. cCCJurNat == "3")
				cCodRet   += "5" // Participante sem Sigla Cadastrada
				cValidNat := "2"
			ElseIf Empty(cNatCat)
				cCodRet   := "3" // Participante sem Natureza Definida na categoria
				cValidNat := "2"
			EndIf

			If !(cAliasNat)->(DbSeek(cNatLanc))
				Reclock(cAliasNat, .T.)
				(cAliasNat)->OHB_NATORI := cNatLanc
				(cAliasNat)->(TrataNat("O", cCcJuri, cEscri, cCCusto, cSigla, cTpCta))
				(cAliasNat)->OHB_NATDES := cNatCat
				(cAliasNat)->(TrataNat("D", cCCJurNat, cEscri, cCCusto, cSigla, cTpCtaNat))
			Else
				Reclock(cAliasNat, .F.)
			EndIf

			If (cAliasNat)->VALIDNAT <> "2"
				(cAliasNat)->VALIDNAT := cValidNat
			EndIf

			//Agrupa do codigo de erro da natureza
			If !Empty(cCodRet) .And.  !(cCodRet $ (cAliasNat)->CODERRNAT)
				(cAliasNat)->CODERRNAT := AllTrim((cAliasNat)->CODERRNAT) + cCodRet
			EndIf

			(cAliasNat)->OHB_VLNAC += nVlNac
			(cAliasNat)->(MsUnLock())
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcGPE
Funcao para processar as Verbas da Folha

@param cPart,      Codigo do Participante
@param cNome,      Nome do Participante
@param cIndSRA,    Indice da Tabela SRA
@param cChvSRA,    Chave da Tabela SRA
@param nValor,     Valor nacional do lancamento
@param cVerba,     Codigo da Verba
@param cRoteiro,   Roteiro de Pagamento
@param cAliasLanc, Tabela de Lancamentos (Cabecalho)
@param cAliasDet,  Tabela de Lancamentos (Detalhe)
@param cTipVerb,   Tipo de Verba
@param cTipCta,    Tipo da Conta
@param cSigla,     Sigla do Participante

@return NIL

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function ProcGPE(cPart, cNome, cIndSRA, cChvSRA,;
                        nValor, cVerba, cRoteiro, cAliasLanc,;
                        cAliasDet, cTipVerb, cTipCta, cSigla)

Local cValidFunc := "1" // Funcionario valido;"2" Funcionario invalido (impeditivo);"3" funcionario desligado
Local aAreaSRA   := {}
Local aPerFol    := {} // Periodo da folha
Local cCodRetGPE := "" // Codigo de erro da Folha de Pagamento
Local cPeriodo   := ""
Local cSemana    := ""
Local cRotPart   := ""

	aAreaSRA   := SRA->(GetArea())

	//Validacoes
	If Empty(cChvSRA) .Or. Empty(Val(cIndSRA))
		// Verifica se o participante possui vinculo com o RH
		cCodRetGPE := "4" // Participante sem vinculo com funcionario
		cValidFunc := "2"
		(cAliasLanc)->(DbSeek(cPart))

	ElseIf (cTipCta == "7" .And. !Empty(cVerba) .And. !cTipVerb $ "1|3" ) .Or. ;
		(cTipCta <> "7" .And. !Empty(cVerba) .And. !cTipVerb $ "2|4" )
		cCodRetGPE := "7" //Verba Inválida
		cValidFunc := "2"
		(cAliasLanc)->(DbSeek(cPart)) 
	Else

		If !(cAliasLanc)->(DbSeek(cPart))
			SRA->(DbSetOrder(Val(cIndSRA)))

			If !SRA->(DbSeek(RTrim(cChvSRA)))
				cCodRetGPE   := "4" // Participante sem vinculo com funcionário
				cValidFunc   := "2"
			ElseIf !Empty(SRA->RA_DEMISSA)
				cCodRetGPE   := "6" // Participante Desligado
				cValidFunc   := "3"
			EndIf

			If  SRA->(Found()) .And. cValidFunc $ "1|3" //IIF(lLancDemi, "1|3", "1") // Alteracao para permitir gerar a folha para participantes com data de demissao preenchida.
				//Retorna o roteiro de calculo, dado o participante
				cRotPart := fGetCalcRot(IIF( !(SRA->RA_CATFUNC $ "A|P"),"1", "9"))		 
				aPerFol := {}
				If !fGetPerAtual( @aPerFol, NIL, SRA->RA_PROCES, cRotPart) .Or. !fVldAccess( , aPerFol[1, 7], aPerFol[1,2], .f., cRotPart, , "V" ) 
					cCodRetGPE := "8" //Falha ao carregar peri­odo atual de pagamento da folha
					cValidFunc := "2"
				Else
					cPeriodo := aPerFol[1,1]
					cSemana  := aPerFol[1,2]
				EndIf
			EndIf
		EndIf
	EndIf
	If !(cAliasLanc)->(Found())
		RecLock(cAliasLanc, .T.)

		(cAliasLanc)->RD0_CODIGO := cPart
		(cAliasLanc)->RD0_NOME   := cNome
		(cAliasLanc)->RD0_SIGLA  := cSigla
		(cAliasLanc)->RDZ_CODENT := cChvSRA
		(cAliasLanc)->RGB_ROTEIR := cRotPart

		If SRA->(Found())
			(cAliasLanc)->RA_FILIAL  := SRA->RA_FILIAL
			(cAliasLanc)->RA_MAT     := SRA->RA_MAT
			(cAliasLanc)->RGB_PROCES := SRA->RA_PROCES
			(cAliasLanc)->RGB_CC     := SRA->RA_CC
			(cAliasLanc)->RGB_CODFUN := SRA->RA_CODFUNC
			(cAliasLanc)->RGB_PERIOD := cPeriodo
			(cAliasLanc)->RGB_SEMANA := cSemana
		EndIf

	Else
		RecLock(cAliasLanc, .F.)
	EndIf

	If (cAliasLanc)->VALIDFUNC <> "2"
		If  cValidFunc == "2"
			(cAliasLanc)->VALIDFUNC := cValidFunc
		ElseIf (cAliasLanc)->VALIDFUNC <> "3"
			(cAliasLanc)->VALIDFUNC := cValidFunc
		EndIf
	EndIf

	If !Empty(cCodRetGPE) .And. !(cCodRetGPE $ (cAliasLanc)->CODERRFUN)
		(cAliasLanc)->CODERRFUN := AllTrim((cAliasLanc)->CODERRFUN) + cCodRetGPE
	EndIf

	(cAliasLanc)->(MsUnLock())

	If !(cAliasDet)->(DbSeek(cPart + cVerba))
		RecLock(cAliasDet, .T.)
		(cAliasDet)->RD0_CODIGO := cPart
		(cAliasDet)->RGB_PD     := cVerba
	Else
		RecLock(cAliasDet, .F.)
	EndIf

	(cAliasDet)->RGB_VALOR += nValor
	(cAliasDet)->(MsUnLock())

	RestArea(aAreaSRA)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataNat
Funcao para gravar os dados da Natureza conforme classificacao

@param cTipoNat - Tipo da Natureza - Origem/Destino
@param cCcJuri  - CC do Juridico
@param cEscri   - Escritório
@param cSigla   - Sigla do Participante
@param cTpCta   - Tipo de Conta

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function TrataNat(cTipoNat, cCcJuri, cEscri, cCCusto, cSigla, cTpCta)

	If cTpCta <> "1"
		If cCcJuri $ "1|2" .Or. (Empty(cCcJuri) .And. !Empty(cEscri)) // Escritório|Centro de Custo|Vazio
			FIELD->&("OHB_CESCR" + cTipoNat) := cEscri
			If cCcJuri == "2" .Or. (Empty(cCcJuri) .And. !Empty(cCCusto)) // Centro de Custo|Vazio
				FIELD->&("OHB_CCUST" + cTipoNat) := cCCusto
			EndIf
		ElseIf cCcJuri == "3" // Profissional
			FIELD->&("OHB_SIGLA" + cTipoNat) := cSigla 
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J284VlNat
Funcao para verificar todos os registros de Natureza estao validos

@param cMsgErro, Mensagem de Erro
@param oTmpNat,  Tabela de Naturezas
@param lIncNat,  Existe Lancamento de Natureza valido a ser inclui­do:
@param aOfNat,   Campos a serem ofuscados no cadastro de Naturezas

@return lProc,   Dados existentes da Natureza estao validos

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function J284VlNat(cMsgErro, oTmpNat, lIncNat, aOfNat)
Local cAliasNat := oTmpNat:GetAlias()
Local lProc     := .T. // Retorno com sucesso
Local cTmp      := ""  // Variavel temporaria
Local cCabec    := STR0055 // "Natureza Origem - Natureza Destino"
Local nPos      := 0   // Posicao
Local cMsgProc  := ""  // Mensagem de Erro
Local aErros    := RetCodErros()
Local aMsgErros := {} 
Local cCodErro  := "" //Codigo do Erro
Local nPos2     := 0

	(cAliasNat)->(DbSetOrder(2)) // VALIDNAT + OHB_NATORI
	(cAliasNat)->(DbSeek("2")) 

	Do While !(cAliasNat)->(Eof()) .And. (cAliasNat)->VALIDNAT == "2"
		If (cAliasNat)->OHB_VLNAC <> 0
			cTmp   := (cAliasNat)->CODERRNAT
			If Empty(cTmp)
				cTmp := "#" 
			EndIf 
			Do While !Empty(cTmp) 
				cCodErro := Left(cTmp,1)
				If (nPos := aScan(aErros, {|e| e[1] == cCodErro})) > 0
					cMsgProc := aErros[nPos, 2]
				Else
					cCodErro := "#" // "Problema não identificado"
					cMsgProc := STR0029 
				EndIf
				cTmp := Substr(cTmp,2)
				If (nPos := aScan(aMsgErros, {|m| m[1] == cCodErro })) = 0
					aAdd(aMsgErros, { cCodErro, cMsgProc, cCabec, {}})
					nPos := Len(aMsgErros)
				EndIf
				aAdd(aMsgErros[nPos, 04], {AllTrim(Ja284CmpPr(cAliasNat, "OHB_NATORI", aOfNat)),  AllTrim(Ja284CmpPr(cAliasNat, "OHB_NATDES",aOfNat) )})
			EndDo
			lProc := .F.
		EndIf
		(cAliasNat)->(DbSkip())
	EndDo
	
	If !lProc
		For nPos := 1 to Len(aMsgErros)
			cCabec := CRLF + aMsgErros[nPos, 02] + CRLF+;
					 space(3) + aMsgErros[nPos, 03]
			cMsgProc := ""
			aSort(aMsgErros[nPos, 04], ,, {|x, y| x[1] < y[1]})
			For nPos2 := 1 to Len(aMsgErros[nPos, 04])
				cMsgProc += CRLF + space(3) + aMsgErros[nPos, 04][nPos2, 01] + " - " + aMsgErros[nPos, 04][nPos2, 02]
			Next nPos
			cMsgErro += cCabec + cMsgProc
		Next nPos
	EndIf

	If lProc
		(cAliasNat)->(DbSeek("1"))

		Do While !lIncNat .And. !(cAliasNat)->(Eof()) .And. (cAliasNat)->VALIDNAT == "1"
			lIncNat := (cAliasNat)->OHB_VLNAC <> 0
			(cAliasNat)->(DbSkip())
		EndDo
	EndIf

Return lProc

//-------------------------------------------------------------------
/*/{Protheus.doc} J284VlGPE
Funcao para verificar todos os registros de Verbas(GPE) estao validos

@param cMsgErro, Mensagem de Erro
@param oTmpLanc, Tabela de Lancamentos (Cabecalho)
@param oTmpLDet, Tabela de Lancamentos (Detalhe)
@param lIncFol,  Registro Inclua­do
@param aOfPart,  Array contendo os campos protegidos

@return lProc - Dados existentes da Natureza estao validos

@author fabiana.silva
@since 28/10/2020
/*/
//-------------------------------------------------------------------
Static Function J284VlGPE(cMsgErro, oTmpLanc, oTmpLDet, lIncFol, aOfPart)
Local lProc      := .T.
Local cAliasLanc := oTmpLanc:GetAlias()
Local cAliasDet  := oTmpLDet:GetAlias()
Local aErros     := RetCodErros()
Local lNValLanc  := .F.
Local cMsgProc   := ""
Local cTmp       := ""
Local cCabec     := STR0056//"Código - Sigla - Nome - Matricula"
Local aMsgErros  := {} 
Local cCodErro   := "" //Codigo do Erro
Local nPos2      := 0
Local nPos       := 0
Local nTamRAFil  := SRA->(TamSX3("RA_FILIAL")[1])+1

	(cAliasLanc)->(DbSetOrder(2)) // VALIDFUNC + RD0_CODIGO
	(cAliasLanc)->(DbSeek("2")) 

	(cAliasDet)->(DbSetOrder(1)) // RD0_CODIGO

	Do While !(cAliasLanc)->(Eof()) .And. (cAliasLanc)->VALIDFUNC == "2"

			lNValLanc := .F.
			(cAliasDet)->(DbSeek((cAliasLanc)->RD0_CODIGO))

				Do While (cAliasDet)->(!Eof() .And. RD0_CODIGO == (cAliasLanc)->RD0_CODIGO)

					If lNValLanc := (cAliasDet)->RGB_VALOR <> 0
						Exit
					EndIf
					(cAliasDet)->(DbSkip(1))
				EndDo

				If lNValLanc
					cTmp   := (cAliasLanc)->CODERRFUN
					If Empty(cTmp)
						cTmp := "#"
					EndIf

					Do While !Empty(cTmp)
						cCodErro := Left(cTmp,1)
						If (nPos := aScan(aErros, {|e| e[1] == cCodErro})) > 0
							cMsgProc := aErros[nPos, 2]
						Else
							cCodErro := "#" // "Problema não identificado"
							cMsgProc := STR0029 
						EndIf
						cTmp := Substr(cTmp,2)
						If (nPos := aScan(aMsgErros, {|m| m[1] == cCodErro })) = 0
							aAdd(aMsgErros, { cCodErro, cMsgProc, cCabec, {}})
							nPos := Len(aMsgErros)
						EndIf
						aAdd(aMsgErros[nPos, 04], {AllTrim( Ja284CmpPr(cAliasLanc, "RD0_CODIGO", aOfPart)), ; 
												   AllTrim( Ja284CmpPr(cAliasLanc, "RD0_SIGLA", aOfPart)),;
												   AllTrim( Ja284CmpPr(cAliasLanc, "RD0_NOME", aOfPart)),;
												   AllTrim( Substr( Ja284CmpPr(cAliasLanc, "RDZ_CODENT", aOfPart),nTamRAFil)) })
					EndDo
					lProc := .F.
				EndIf
		(cAliasLanc)->(DbSkip())
	EndDo

	If !lProc
		For nPos := 1 to Len(aMsgErros)
			cCabec := CRLF + aMsgErros[nPos, 02] + CRLF+;
					 space(3) + aMsgErros[nPos, 03]
			cMsgProc := ""
			aSort(aMsgErros[nPos, 04], ,, {|x, y| x[1] < y[1]})
			For nPos2 := 1 to Len(aMsgErros[nPos, 04])
				cMsgProc += CRLF + space(3) + aMsgErros[nPos, 04][nPos2, 01] + " - " +aMsgErros[nPos, 04][nPos2, 02]+ " - " +aMsgErros[nPos, 04][nPos2, 03]+ " - " +aMsgErros[nPos, 04][nPos2, 04]
			Next nPos
			cMsgErro += cCabec + cMsgProc
		Next nPos
	EndIf

	If lProc
		(cAliasLanc)->(DbSeek("1"))

		Do While !lIncFol .And. (cAliasLanc)->(!Eof()) .And. (cAliasLanc)->VALIDFUNC == "1"
			(cAliasDet)->(DbSeek((cAliasLanc)->RD0_CODIGO))
			Do While (cAliasDet)->(!Eof() .And. RD0_CODIGO == (cAliasLanc)->RD0_CODIGO)
				If lIncFol := (cAliasDet)->RGB_VALOR <> 0
					Exit
				EndIf
				(cAliasDet)->(DbSkip(1))
			EndDo
			(cAliasLanc)->(DbSkip())
		EndDo
	EndIf

Return lProc

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur284GGPE
Funcao para gerar os registros de Verbas(GPE)

@param cLote,    Lote de Lancamentos
@param cMsgRet,  Retorno de Processamento
@param oTmpLanc, Tabela de Cabecalho de Lancamento
@param oTmpLDet, Tabela de Detalhe de Lancamentos

@return lProc - Dados gerados com sucesso

@author fabiana.silva
@since 06/11/2020

/*/
//-------------------------------------------------------------------
Static Function Jur284GGPE(cLote, cMsgRet, oTmpLanc, oTmpLDet)
Local lProc            := .T.
Local aCabec           := {}
Local aItens           := {}
Local aItensFinal      := {}
Local cTmpLanc         := oTmpLanc:GetAlias()
Local cTmpDet          := oTmpLDet:GetAlias()
Local cLog             := ""
Local cVerDeb          := SuperGetMV('MV_JVERDEB', .F., '') // Verba de Debito (Desconto)
Local cVerCred         := SuperGetMV('MV_JVERCRE', .F., '') // Verba de Credito (Provento)
Local cVerba           := ""
Local cSeq             := ""
Local cTpVerDeb        := ""
Local cTpVerCred       := ""
Local nOpc             := 3
Local cFilRGB          := xFilial("RGB")
Local aCabErro         := {}

Private lMsHelpAuto    := .F.
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

	(cTmpLanc)->(DbSetOrder(2))
	(cTmpLanc)->(DbSeek("1", .T.))

	(cTmpDet)->(DbSetOrder(1))

	Do While lProc .And. !(cTmpLanc)->(Eof())
		If (cTmpLanc)->VALIDFUNC == "1" .Or. (cTmpLanc)->VALIDFUNC == "3"
			nOpc   := J284OpGPE(cFilRGB, (cTmpLanc)->RGB_PROCES, (cTmpLanc)->RA_MAT, (cTmpLanc)->RGB_PERIOD, (cTmpLanc)->RGB_ROTEIR)

			aCabErro := {(cTmpLanc)->(RA_FILIAL+RA_MAT),  (cTmpLanc)->RGB_ROTEIR, (cTmpLanc)->RGB_PERIOD, cValToChar(nOpc)}
			aCabec := { {"RA_FILIAL" , (cTmpLanc)->RA_FILIAL , Nil },;
			            {"RA_MAT"    , (cTmpLanc)->RA_MAT    , Nil },;
			            {"CPERIODO"  , (cTmpLanc)->RGB_PERIOD, Nil },;
			            {"CROTEIRO"  , (cTmpLanc)->RGB_ROTEIR, Nil },;
			            {"CNUMPAGTO" , (cTmpLanc)->RGB_SEMANA, Nil };
			          }
			aItens      := {}
			aItensFinal := {}
			(cTmpDet)->(DbSeek((cTmpLanc)->RD0_CODIGO))

			Do While (cTmpDet)->(!Eof() .And. RD0_CODIGO ==  (cTmpLanc)->RD0_CODIGO)

				If (cTmpDet)->RGB_VALOR <> 0

					cVerba := (cTmpDet)->RGB_PD
					If Empty(cVerba)
						If (cTmpDet)->RGB_VALOR < 0
							If Empty(cTpVerDeb)
								cTpVerDeb := GetAdvFVal('SRV',"RV_TIPOCOD", xFilial('SRV') + cVerDeb,1,"")
								If !cTpVerDeb $ "2/4"
									lProc := .F.
									cMsgRet += CRLF + STR0052 + "MV_JVERDEB: "+cVerDeb + STR0053 //"Verba cadastrada no parâmetro "##" não é de desconto."
									Exit
								EndIf
							EndIf

							cVerba := cVerDeb
						Else
							If Empty(cTpVerCred)
								cTpVerCred := GetAdvFVal('SRV',"RV_TIPOCOD", xFilial('SRV') + cVerCred,1,"")
								If !cTpVerCred $ "1/3"
									lProc := .F.
									cMsgRet += CRLF + STR0052 + " MV_JVERCRE: "+cVerCred + STR0054//"Verba cadastrada no parâmetro "##" não é de provento." 
									Exit
								EndIf
							EndIf
							
							cVerba := cVerCred
						EndIf
					EndIf

					If !J284MaxVer(cFilRGB, (cTmpLanc)->RGB_PROCES, (cTmpLanc)->RA_MAT, (cTmpLanc)->RGB_PERIOD, (cTmpLanc)->RGB_ROTEIR, cVerba)
						lProc   := .F.
						cMsgRet += CRLF + I18n(STR0057, aCabErro) // "Problemas ao gerar lancamentos de verbas para a Matricula: #1  Roteiro: #2  Periodo de Pagamento: #3  Operacao: #4"
						cMsgRet += CRLF + I18N(STR0058, {cVerba}) // "Excedeu o numero de lancamentos permitidos para a verba '#1'."
						Exit
					EndIf

					cSeq := GetSeqVer(cFilRGB, (cTmpLanc)->RGB_PROCES, (cTmpLanc)->RA_MAT, (cTmpLanc)->RGB_PERIOD, ;
													(cTmpLanc)->RGB_SEMANA, (cTmpLanc)->RGB_ROTEIR, cVerba, (cTmpLanc)->RGB_CC )

					aItens := { {"RGB_FILIAL" , cFilRGB                  , Nil},;
								{"RGB_MAT"    , (cTmpLanc)->RA_MAT       , Nil},;
								{"RGB_PROCES" , (cTmpLanc)->RGB_PROCES   , Nil},;
								{"RGB_PD"     , cVerba                   , Nil},;
								{"RGB_TIPO1"  , "V"                      , Nil},;
								{"RGB_VALOR"  , Abs((cTmpDet)->RGB_VALOR), Nil},;
								{"RGB_CC"     , (cTmpLanc)->RGB_CC       , Nil},;
								{"RGB_CODFUN" , (cTmpLanc)->RGB_CODFUN   , Nil},;
								{"RGB_SEMANA" , (cTmpLanc)->RGB_SEMANA   , Nil},;
								{"RGB_LOTPLS" , cLote                    , Nil},;
								{"RGB_SEQ"    , cSeq                     , Nil},;
								{"RGB_TIPO2"  , "A"	                     , Nil};
							}

					Aadd(aItensFinal, aItens)
				EndIf
				(cTmpDet)->(DbSkip(1))
			EndDo

			If Len(aItensFinal) > 0

				lMsErroAuto    := .F.
				MsExecAuto({|w,x,y,z| GPEA580(w,x,y,z)} , nil ,aCabec, aItensFinal, nOpc )

				If lMsErroAuto
					cLog := CRLF + I18n(STR0057, aCabErro) // "Problemas ao gerar lançamentos de verbas para a Matrícula: #1  Roteiro: #2  Período de Pagamento: #3  Operacão:#4"
					aEval(GetAutoGRLog(), {|l| cLog += CRLF + l})
					lProc := .F.
					cMsgRet += cLog
					Exit
				EndIf
			EndIf
			JurFreeArr(aCabec)
			JurFreeArr(aCabErro)
			JurFreeArr(aItens)
			JurFreeArr(aItensFinal)
		EndIf
		(cTmpLanc)->(DbSkip(1))
	EndDo
	
Return lProc

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA284CLt
Funcao de Cancelamento dos Lancamentos do Lote

@param lAutomato,  Rotina Automatizada

@Return lProc,     Cancelamento realizado com sucesso

@author fabiana.silva
@since 22/10/2020

/*/
//-------------------------------------------------------------------
Function JURA284CLt(lAutomato)
Local cTmpOHB       := ""  // Lancamentos vinculados ao Lote
Local cMsgRet       := ""  // Mensagem de Erro
Local cUpdOHB       := ""  // Co.And. de atualizacao de lancamentos
Local cQuery        := ""  // Query dos Lancamentos a serem cancelados
Local oMdlJura284   := Nil // Modelo de Lote de Lancamentos
Local lProc         := .T. // Cancelamento realizado com sucesso
Local lIntGPE       := .F. // Habilita Integracao GPE 1= Nao, 2= Sim
Local oTmpRGB       := "" //Query para cancelamento dos Lancamentos
Local cRoteiro      := ""

Default lAutomato := .F.

	If !Empty(OHW->OHW_LOTE) .And. OHW->OHW_STATUS == "1"

		If  lAutomato .Or. MsgYesNo(STR0030) // "Confirma cancelamento do Lote?"
			lIntGPE := OHW->OHW_INTGPE == "2"

			cQuery := "SELECT OHB_FILIAL, OHB_CODIGO FROM " + RetSqlName("OHB") + " OHB " + ;
			          " WHERE OHB.OHB_FILIAL = '" + xFilial("OHB") + "'" + ;
			            " AND OHB.OHB_LOTE = '" + OHW->OHW_LOTE +  "' " + ;
			            " AND OHB.OHB_ORIGEM = '8' " + ;
			            " AND OHB.D_E_L_E_T_ = ' ' " + ;
			          " ORDER BY OHB_FILIAL, OHB_CODIGO "

			cTmpOHB :=  GetNextAlias()
			DbUseArea( .T., 'TOPCONN', TcGenQry(,, ChangeQuery(cQuery, .F.)), cTmpOHB, .T., .F.)

			If !(cTmpOHB)->(Eof()) .And. !(lProc := CtbValiDt(,OHW->OHW_DTINCL, .F.,,, {"PFS001"},)) // Calendário Válido
				cMsgRet :=  STR0014 + CRLF + I18n(STR0013, {cFilAnt}) // "Calendário Contábil bloqueado."#"Verifique o bloqueio do processo 'PFS001' no Calendário Contábil da filial '#1', para o período da data do lançamento."
			EndIf

			If lIntGPE .And. lProc 
				cQuery := " SELECT RGB_FILIAL, " +;
				                 " RGB_MAT, " +;
				                 " RGB_PROCES, " +;
				                 " RGB_PERIOD, " +;
				                 " RGB_SEMANA, " +;
				                 " RGB_ROTEIR, " +;
				                 " RGB_PD, " +;
				                 " RGB_TIPO1, " +;
				                 " RGB_VALOR, " +;
				                 " RGB_CC, " +;
				                 " RGB_CODFUN, " +;
				                 " RGB_LOTPLS, " +;
				                 " RGB_SEQ " +;
				            " FROM " + RetSqlName("RGB") + ;
				           " WHERE D_E_L_E_T_ = ' ' "+;
				             " AND RGB_FILIAL = '" + xFilial("RGB") + "'"+;
				             " AND RGB_LOTPLS = '" + OHW->OHW_LOTE + "'"+;
				             " AND RGB_CODRDA = ' '"

				oTmpRGB := JurCriaTmp(GetNextAlias(), cQuery, , { {"01","RGB_FILIAL+RGB_MAT+RGB_PROCES+RGB_PERIOD+RGB_SEMANA+RGB_PD",;
				                                                   TamSx3("RGB_FILIAL")[1] + TamSx3("RGB_MAT")[1] + TamSx3("RGB_PROCES")[1] +TamSx3("RGB_PERIOD")[1]+TamSx3("RGB_SEMANA")[1]+TamSx3("RGB_PD")[1]} })[1]

				lProc := Ja284VlCFp(OHW->OHW_LOTE, cRoteiro, oTmpRGB, @cMsgRet)
			EndIf

			If lProc
				Begin Transaction

					//Cancela os lancamentos da Folha
					If lIntGPE
						lProc := Jur284CGPE(oTmpRGB:GetAlias(), @cMsgRet)
					EndIf

					If lProc
					// Exclui lancamentos gerados pelo Finaceiro
						lProc := Jur284CLan(OHW->OHW_LOTE, @cMsgRet, cTmpOHB)
					EndIf
					//Remove código do lote dos lancamentos vinculados
					If lProc
						cUpdOHB := "UPDATE " + RetSqlName("OHB") + ;
						             " SET OHB_LOTE = ' ' " + ;
						           " WHERE OHB_LOTE = '" + OHW->OHW_LOTE  + "' " + ;
						             " AND OHB_FILIAL = '" + xFilial("OHB") + "'" + ;
						             " AND D_E_L_E_T_ = ' ' "
						If TCSQLExec(cUpdOHB) < 0 // Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()
							cMsgRet += CRLF +  STR0031+ AllTrim(TCSQLError())+"]" // "Problemas ao desvincular lote nos lançamentos ["
							lProc := .F.
						EndIf
					EndIf

					If lProc
						//Atualiza como cancelado o  lote de lancamentos
						oMdlJura284 := FwLoadModel("JURA284")
						oMdlJura284:SetOperation(4)
						oMdlJura284:Activate()

						lProc := lProc .And. oMdlJura284:SetValue("OHWMASTER", "OHW_STATUS", "2")
						lProc := lProc .And. oMdlJura284:SetValue("OHWMASTER","OHW_DTCANC", Date())

						lProc := lProc .And. oMdlJura284:VldData() .And. oMdlJura284:Commitdata()
						
						If !lProc
							cMsgRet += CRLF + JurShowErro(oMdlJura284:GetModel():GetErrormessage(), Nil, Nil, .F., .F.)
						EndIf

						oMdlJura284:DeActivate()
						oMdlJura284:Destroy()
					EndIf

					If !lProc
						DisarmTransaction()
					EndIf
				End Transaction
			EndIf

			If lIntGPE
				oTmpRGB:Delete()
			EndIf

			(cTmpOHB)->(DbCloseArea())
		Else
			cMsgRet := CRLF + STR0032 // "Processamento cancelado"
			lProc   := .F.
		EndIf
	Else
		cMsgRet := CRLF + STR0033 // "Lote não pode ser cancelado"
		lProc   := .F.
	EndIf

	If !lProc
		If !lAutomato
			JurErrLog(Substr(cMsgRet, Len(CRLF)+1),,STR0034)  // "Problemas ao Cancelar Lote"
		Else
			Help( ,,, 'JURA284CLt', STR0034+": " +Substr(cMsgRet, Len(CRLF)+1), 1, 0)
		EndIf
	EndIf

Return lProc

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur284CLan
Funcao de Cancelamento dos Lancamentos do Lote

@param cLote,    Codigo do Lote
@param cMsgProc, Mensagem de Erro
@param cTmpOHB,  Tabela com os lancamentos

@Return lProc,   Cancelamento realizado com sucesso

@author fabiana.silva
@since 22/10/2020

/*/
//-------------------------------------------------------------------
Static Function Jur284CLan(cLote, cMsgProc, cTmpOHB)
Local lProc      := .T. // Cancelamento realizado com sucesso
Local oMdJura241 := Nil // Modelo de Lancamentos
Local aOHBArea   := OHB->(GetArea()) // Lancamentos a serem cancelados

	OHB->(DbSetOrder(1)) //OHB_FILIAL + OHB_CODIGO
	(cTmpOHB)->(DbGoTop())

	oMdJura241 := FwLoadModel("JURA241")

	Do While (cTmpOHB)->(!Eof())

		If OHB->(DbSeek((cTmpOHB)->(OHB_FILIAL+OHB_CODIGO)))

			oMdJura241:SetOperation(MODEL_OPERATION_DELETE)
			If !oMdJura241:IsActive()
				oMdJura241:Activate()
			EndIf

			lProc := lProc .And. oMdJura241:VldData() .And.  oMdJura241:Commitdata()
			
			If !lProc
				cMsgProc += CRLF + JurShowErro(oMdJura241:GetModel():GetErrormessage(), Nil, Nil, .F., .F.)
			EndIf

			If oMdJura241:IsActive()
				oMdJura241:DeActivate()
			EndIf
		Else
			lProc := .T.
			cMsgProc += CRLF + STR0035 + (cTmpOHB)->(OHB_FILIAL+OHB_CODIGO) + "]" // "Registro de Lançamento não localizado chave ["
		EndIf

		If !lProc
			Exit
		EndIf

		(cTmpOHB)->(DbSkip())
	EndDo

	If !oMdJura241:IsActive()
		oMdJura241:DeActivate()
	EndIf
	
	oMdJura241:Destroy()

	RestArea(aOHBArea)

Return lProc

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja284VlCFp
Funcao para validar o cancelamentos das verbas GPE

@param cLote,    Lote de Lancamentos
@param cRoteiro, Roteiro de Lancamentos
@param oTmpRGB,  Tabela Temporaria de Lancamentos
@param cMsgRet,  Mensagem de Validacao

@return lProc,   Dados Validos

@author fabiana.silva
@since 06/11/2020
/*/
//-------------------------------------------------------------------
Static Function Ja284VlCFp(cLote, cRoteiro, oTmpRGB, cMsgRet)
Local lProc     := .T.
Local cTmpSem   := GetNextAlias()
Local cQuery    := ""
Local aPerFol   := {}
Local cRoteiro1 := fGetCalcRot("1")
Local cRoteiro2 := fGetCalcRot("9")
	
	If !Empty(cRoteiro1)
		cRoteiro := ",'" + cRoteiro1 + "'"
	EndIf

	If !Empty(cRoteiro2)
		cRoteiro += ",'" + cRoteiro2 + "'"
	EndIf

	If Len(cRoteiro) > 1
		cRoteiro := SubStr(cRoteiro, 2)
		cQuery := " SELECT DISTINCT RGB_FILIAL, RGB_MAT, RGB_PERIOD, RGB_ROTEIR  FROM " + oTmpRGB:GetRealName() + ;
				" WHERE RGB_LOTPLS = '" + cLote + "' AND RGB_ROTEIR NOT IN(" + cRoteiro + ") AND D_E_L_E_T_ = ' ' ORDER BY RGB_MAT, RGB_PERIOD"

		DbUseArea( .T., 'TOPCONN', TcGenQry(,, ChangeQuery(cQuery, .F.)), cTmpSem, .T., .F.)

		If (cTmpSem)->(!Eof())
			cMsgRet += CRLF + STR0044 + cRoteiro + ;////"Localizados no Lote roteiro diferente do padrão: "
							space(3)+ STR0045//"Matrícula - Período"
			Do While (cTmpSem)->(!Eof())
				cMsgRet += CRLF + (cTmpSem)->RGB_MAT + " - "+ (cTmpSem)->RGB_PERIOD
				(cTmpSem)->(DbSkip(1))
			EndDo
			lProc := .F.
		EndIf

		(cTmpSem)->(DbCloseArea())

		If lProc
			cQuery := " SELECT DISTINCT RGB_PROCES, RGB_PERIOD, RGB_SEMANA, RGB_ROTEIR FROM " + oTmpRGB:GetRealName() + ;
					" WHERE RGB_LOTPLS = '" + cLote + "' AND RGB_ROTEIR IN (" + cRoteiro + ") AND D_E_L_E_T_ = ' '"

			DbUseArea( .T., 'TOPCONN', TcGenQry(,, ChangeQuery(cQuery, .F.)), cTmpSem, .T., .F.)
			
			Do While lProc .AND. !Eof()
				aPerFol := {}
				If !fGetPerAtual( @aPerFol, NIL, (cTmpSem)->RGB_PROCES, (cTmpSem)->RGB_ROTEIR)
					lProc := .F.
					cMsgRet += CRLF + STR0047 + (cTmpSem)->RGB_PROCES + STR0048 + cRoteiro //"Falha ao carregar período atual de pagamento da folha. Processo :"##" Roteiro :"
				Else
					If (cTmpSem)->RGB_PERIOD <> aPerFol[1,1]  .OR.  (cTmpSem)->RGB_SEMANA <> aPerFol[1,2] 
						lProc := .F.
						cMsgRet += CRLF + STR0049 + aPerFol[1,1] + "/" + aPerFol[1,2] + STR0050 + (cTmpSem)->RGB_PROCES + STR0051 + (cTmpSem)->(RGB_PERIOD + "/" + RGB_SEMANA) //"Período Atual (Per/Sem): "##" do Processo: "## "  diverge do Lançado (Per/Sem): "             
					EndIf
				EndIf
				(cTmpSem)->(DbSkip(1))
			EndDo
			(cTmpSem)->(DbCloseArea())
		EndIf
	EndIf

Return lProc

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur284CGPE
Funcao para cancelar os registros de Verbas(GPE)

@param cAliasRGB, Alias da Tabela de Lancamentos da Folha
@param cMsgRet,   Mensagem de Erro de Processamento

@return lProc,    Dados gerados com sucesso

@author fabiana.silva
@since 06/11/2020
/*/
//-------------------------------------------------------------------
Static Function Jur284CGPE(cAliasRGB, cMsgRet)
Local lProc       := .T.
Local aCabec      := {}
Local aItens      := {}
Local aItensFinal := {}
Local cLog        := ""
Local cChave      := ""
Local cFilSRA     := xFilial("SRA")

	Do While (cAliasRGB)->(!Eof())
		If cChave <> cFilSRA + (cAliasRGB)->(RGB_MAT + RGB_PERIOD + RGB_ROTEIR + RGB_SEMANA)
			cChave := cFilSRA + (cAliasRGB)->(RGB_MAT + RGB_PERIOD + RGB_ROTEIR + RGB_SEMANA)
			aCabec :=   { {"RA_FILIAL" , cFilSRA                , Nil },;
			              {"RA_MAT"    , (cAliasRGB)->RGB_MAT   , Nil },;
			              {"CPERIODO"  , (cAliasRGB)->RGB_PERIOD, Nil },;
			              {"CROTEIRO"  , (cAliasRGB)->RGB_ROTEIR, Nil },;
			              {"CNUMPAGTO" , (cAliasRGB)->RGB_SEMANA, Nil };
			            }

			aItens      := {}
			aItensFinal := {}

			Do While (cAliasRGB)->(!Eof() .AND. cFilSRA+(cAliasRGB)->(RGB_MAT + RGB_PERIOD + RGB_ROTEIR + RGB_SEMANA) == cChave)
	
				aItens :=  { {"RGB_FILIAL" , (cAliasRGB)->RGB_FILIAL, Nil },;
				             {"RGB_MAT"    , (cAliasRGB)->RGB_MAT   , Nil },;
				             {"RGB_PROCES" , (cAliasRGB)->RGB_PROCES, Nil },;
				             {"RGB_PD"     , (cAliasRGB)->RGB_PD    , Nil },;
				             {"RGB_TIPO1"  , (cAliasRGB)->RGB_TIPO1 , Nil },;
				             {"RGB_VALOR"  , (cAliasRGB)->RGB_VALOR , Nil },;
				             {"RGB_CC"     , (cAliasRGB)->RGB_CC    , Nil },;
				             {"RGB_CODFUN" , (cAliasRGB)->RGB_CODFUN, Nil },;
				             {"RGB_SEMANA" , (cAliasRGB)->RGB_SEMANA, Nil },;
				             {"RGB_LOTPLS" , (cAliasRGB)->RGB_LOTPLS, Nil },;
				             {"RGB_SEQ"    , (cAliasRGB)->RGB_SEQ   , Nil };
				           }
				aAdd(aItensFinal, aItens)
				(cAliasRGB)->(DbSkip(1))
			EndDo

			If Len(aItensFinal) > 0
				lMsErroAuto    := .F.
				MsExecAuto({|w,x,y,z,r| GPEA580(w,x,y,z,r)} , nil ,aCabec, aItensFinal, 5, 2)
				If lMsErroAuto
					cLog := ""
					aEval(GetAutoGRLog(), {|l| cLog += CRLF + l})
					lProc := .F.
					cMsgRet += cLog
					Exit
				EndIf
			EndIf
		EndIf
	EndDo

Return lProc

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodErros
Retorna o código de Erros da rotina de processamento de registros

@return aRet - Codigos dos erros, onde [1] - Código do Erro, 
                                       [2] - Descricao do Código do Erro

@author fabiana.silva
@since 06/11/2020
/*/
//-------------------------------------------------------------------
Static Function RetCodErros()
Local aRet := {{"1", STR0022},; // "Natureza sem Participante definido"
				{"2", STR0023},; // "Participante sem Categoria Definida"
				{"3", STR0024},; // "Participante sem Natureza Definida na categoria"
				{"4", STR0025},; // "Participante sem vinculo com funcionario"
				{"5", STR0026},; // "Participante sem sigla cadastrada"
				{"6", STR0039},; // "Participante desligado"
				{"7", STR0040},; // "Verba invalida"
				{"8", STR0041} } // "Falha ao carregar pera­odo atual de pagamento da folha"
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSeqEve
Retorna a próxima sequencia do Lancamento da Verba

@param cFilRGB,  Filial do Lancamento
@param cProcess, Processo
@param cMat,     Matricula do Funcionario
@param cPeriod,  Periodo do Pagamento
@param cSemana,  Semana do Pagamento
@param cRoteiro, Roteiro de Pagamento
@param cVerba,   Verba de Pagamento
@param cCC,      CC de Pagamento

@return cSeq - Sequencia do do Lancamento do Verba

@author fabiana.silva
@since 06/11/2020
/*/
//-------------------------------------------------------------------
Static Function GetSeqVer(cFilRGB, cProcess, cMat, cPeriod,;
                          cSemana, cRoteiro, cVerba, cCC)
Local cSeq   := ""
Local cQuery := ""
Local cAlias := GetNextAlias()

	cQuery := " SELECT MAX(RGB_SEQ) RGB_SEQ FROM " + RetSqlName("RGB") +;
	           " WHERE D_E_L_E_T_ = ' ' " +;
	             " AND RGB_FILIAL = '" + cFilRGB + "'" +;
	             " AND RGB_PROCES = '" + cProcess + "'" +;
	             " AND RGB_MAT = '" + cMat + "'" +;
	             " AND RGB_PERIOD = '" + cPeriod + "'" +;
	             " AND RGB_SEMANA = '" + cSemana + "'" +;
	             " AND RGB_ROTEIR = '" + cRoteiro + "'" +;
	             " AND RGB_PD = '" + cVerba + "'" +;
	             " AND RGB_CC = '" + cCC + "'"

	DbUseArea( .T., 'TOPCONN', TcGenQry(,, ChangeQuery(cQuery, .F.)), cAlias, .T., .F.)
	If !(cAlias)->(Eof())
		cSeq := (cAlias)->RGB_SEQ
	EndIf
	cSeq := Soma1(cSeq)
	(cAlias)->(DbCloseArea())

Return cSeq 

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja284CmpPr
Retorna o conteudo do campo, verificando se o mesmo e protegido LGPD, 
devido aos metodos ToAnonymizeByRecNo e ToAnonymizeByRecNo nao 
funcionarem com tabelas temporarias

@param cAlias,    Alias do Registro
@param cField,    Nome do campo que deve ser tipo caractere
@param aOfFields, Array dos campos a serem protegidos

@return cCpo - Conteudo do campo

@author fabiana.silva
@since 09/11/2020
/*/
//-------------------------------------------------------------------
Function Ja284CmpPr(cAlias, cField, aOfFields)
Local cCpo := ""

Default cAlias := ""
Default cField := ""
Default aOfFields := ""

	If !Empty(cAlias)
		cCpo := (cAlias)->&(cField)
		If  !Empty(cCpo) .AND. aScan(aOfFields, {|f| f == cField } ) > 0
			cCpo := Replicate("*", Len(cCpo))
		EndIf
	EndIf

Return cCpo

//-------------------------------------------------------------------
/*/{Protheus.doc} J284OpGPE
Retorna a operacao a ser realizada

@param cFilRGB,  Filial do Lancamento
@param cProcess, Processo
@param cMat,     Matricula do Funcionario
@param cPeriod,  Periodo do Pagamento
@param cRoteiro, Roteiro de Pagamento

@return nOper,   Codigo da Operacao

@author fabiana.silva
@since 09/04/2021
/*/
//-------------------------------------------------------------------
Static Function J284OpGPE(cFilRGB, cProcess, cMat, cPeriod, cRoteiro)
Local aArea := GetArea()
Local cQry  := GetNextAlias()
Local nOper := 3

	BeginSQL Alias cQry
		%NoParser%
		SELECT 1 REC
		  FROM %Table:RGB% RGB
		 WHERE RGB.RGB_FILIAL = %Exp:cFilRGB%
		   AND RGB.RGB_PROCES = %Exp:cProcess%
		   AND RGB.RGB_PERIOD = %Exp:cPeriod%
		   AND RGB.RGB_ROTEIR = %Exp:cRoteiro%
		   AND RGB.RGB_MAT    = %Exp:cMat%
		   AND RGB.%NotDel%
	EndSQL

	nOper := IIF((cQry)->(EOF()), 3, 4)

	(cQry)->(DbCloseArea())
	
	RestArea(aArea)

Return nOper

//-------------------------------------------------------------------
/*/{Protheus.doc} J284VlVerb
Valida se ja foi utilizada a quantidade maxima de lancamentos para a
mesma verba considerando o agrupamento (Processo/Matricula/Periodo/Roteiro).

@param cFilRGB,  Filial do Lancamento
@param cProcess, Processo
@param cMat,     Matricula do Funcionario
@param cPeriod,  Periodo do Pagamento
@param cRoteiro, Roteiro de Pagamento
@param cVerba,   Verba que será incluida

@return lRet,    Se .T. verba pode ser utilizada

@author Abner Fogaca / Jonatas Martins
@since 06/05/2021
/*/
//-------------------------------------------------------------------
Static Function J284MaxVer(cFilRGB, cProcess, cMat, cPeriod, cRoteiro, cVerba)
Local aArea := GetArea()
Local cQry  := GetNextAlias()
Local lRet  := .T.

	BeginSQL Alias cQry
		%NoParser%
		SELECT Count(RGB_PD) TOTLANC
		  FROM %Table:SRV% SRV, %Table:RGB% RGB
		 WHERE SRV.RV_FILIAL  = %xFilial:SRV%
		   AND SRV.RV_COD     = %Exp:cVerba%
		   AND SRV.RV_QTDLANC = '1'
		   AND SRV.%NotDel%
		   AND RGB.RGB_FILIAL = %Exp:cFilRGB%
		   AND RGB.RGB_PD     = SRV.RV_COD
		   AND RGB.RGB_PROCES = %Exp:cProcess%
		   AND RGB.RGB_PERIOD = %Exp:cPeriod%
		   AND RGB.RGB_ROTEIR = %Exp:cRoteiro%
		   AND RGB.RGB_MAT    = %Exp:cMat%
		   AND RGB.%NotDel%
	EndSQL

	lRet := (cQry)->(EOF()) .Or. (cQry)->TOTLANC < 1

	(cQry)->(DbCloseArea())
	
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataVerba
Retorna o tratamento da verba, buscando o valor default

@param cTipoCC,  Tipo de Centro de Custo Jurídico
@param cIdPagto, Código do Pagamento
@param cOrigem,  Origem do Lancamento
@param cVerba,   Código da Verba
@param cQuery,   Tipo da Verba

@return cVerba,  Código da Verba

@author fabiana.silva
@since 19/01/2022
/*/
//-------------------------------------------------------------------
Static Function TrataVerba(cTipoCC, cIdPagto, cOrigem, cVerba, cTpVerb, cQuery)
Local aResult := {}

If Empty(cVerba) .And. (cTipoCC $ "7|6") .And. cOrigem == '1' .And. !Empty(cIdPagto)
	
	If Empty(cQuery)
		cQuery :=  "SELECT SRV.RV_COD, SRV.RV_TIPOCOD "
		cQuery +=   " FROM " + RetSqlName("FK7") + " FK7 "
		cQuery +=  " INNER JOIN " + RetSqlName("OI0") + " OI0 "
		cQuery +=     " ON (OI0.OI0_FILIAL = '"  + xFilial("SA2") + "' " //Tabela vai gravar a filial da sa2    
		cQuery +=    " AND  OI0.OI0_FORNEC = FK7.FK7_CLIFOR"
		cQuery +=    " AND  OI0.OI0_LOJA = FK7.FK7_LOJA "
		cQuery +=    " AND  OI0.D_E_L_E_T_ = ' ' ) "
		cQuery +=   " LEFT JOIN " + RetSqlName("SRV") + " SRV "
		cQuery +=     " ON (SRV.RV_FILIAL = '"  + xFilial("SRV") + "' "
		cQuery +=    " AND  SRV.RV_COD = OI0.OI0_VERBA "
		cQuery +=    " AND  SRV.D_E_L_E_T_ = ' ' ) "
		cQuery +=  " WHERE  FK7.FK7_FILIAL = '" + xFilial("FK7") + "' "
		cQuery +=    " AND  FK7.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND  FK7.FK7_ALIAS = 'SE2' "
	EndIf
	aResult := JurSql(cQuery + " AND FK7.FK7_CHAVE = '" + cIdPagto + "' ", {"RV_COD", "RV_TIPOCOD", "RV_COD2","RV_TIPOCO2"})
	
	If Len(aResult) > 0
		cVerba  := aResult[01, 01]
		cTpVerb := aResult[01, 02]
	EndIf
EndIf

Return cVerba
