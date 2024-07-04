#INCLUDE "QADA250.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
 
//-----------------------------------------------------------------------
/*/{Protheus.doc} QADA250
Cadastro de auditoria
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return NIL
/*/
//-----------------------------------------------------------------------
Function QADA250()
	Local   aArea   := GetArea()
	Local   oBrowse
	PRIVATE cCodAudit		
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QUB")
	oBrowse:AddLegend( "QUB_STATUS=='1'", "ENABLE",     STR0059 )
	oBrowse:AddLegend( "QUB_STATUS=='2'", "BR_AMARELO", STR0060 )
	oBrowse:AddLegend( "QUB_STATUS=='3'", "BR_PRETO",   STR0061 )
	oBrowse:AddLegend( "QUB_STATUS=='4'", "DISABLE",    STR0062 )
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE  STR0003  ACTION 'VIEWDEF.QADA250' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE  STR0004  ACTION 'VIEWDEF.QADA250' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE  STR0005  ACTION 'QAD250Up()'      OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE  STR0006  ACTION 'QAD250Dl()'      OPERATION MODEL_OPERATION_DELETE ACCESS 0 //Excluir
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := Nil
	Local oStruQUB  := FWFormStruct(1,"QUB") 
	Local oStruQUH  := FWFormStruct(1,"QUH") 
	Local oStruQUC  := FWFormStruct(1,'QUC')
	Local oStruQUI  := FWFormStruct(1,'QUI')
	Local oStruQUJ  := FWFormStruct(1,'QUJ')	
	Local oStruQUJ2 := FWFormModelStruct():New()
	Local oStruQUE  := FWFormStruct(1,'QUE')
	Local oStruQUK  := FWFormStruct(1,'QUK')
	Local oStruQUD  := FWFormStruct(1,'QUD')
	Local oStruREU  := FWFormModelStruct():New()
	Local aGatilho  := NIl
	Local nX
	
	oStruREU:AddField( ;                      // Ord. Tipo Desc.
	                   STR0051, ;             // [01] C Titulo do campo
	                   STR0051, ;             // [02] C ToolTip do campo
	                   "LREUNIAO", ;          // [03] C identificador (ID) do Field
	                   'L' , ;                // [04] C Tipo do campo
	                   1, ;                   // [05] N Tamanho do campo
	                   0 , ;                  // [06] N Decimal do campo
	                   NIL, ;                 // [07] B Code-block de validação do campo
	                   NIL, ;                 // [08] B Code-block de validação When do campo
	                   , ;                    // [09] A Lista de valores permitido do campo
	                   .F., ;                 // [10] L Indica se o campo tem preenchimento obrigatório
	                   {||.T.}, ;             // [11] B Code-block de inicializacao do campo
	                   .F., ;                 // [12] L Indica se trata de um campo chave
	                   .T., ;                 // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                  // [14] L Indica se o campo é virtual

	oStruQUJ2:AddTable("   ",{" "}," ")

	oStruQUJ2:AddField( ;                     // Ord. Tipo Desc.
	                   STR0063, ;             // [01] C Titulo do campo
	                   STR0064, ;             // [02] C ToolTip do campo
	                   "CHKOK", ;             // [03] C identificador (ID) do Field
	                   'L' , ;                // [04] C Tipo do campo
	                   1, ;                   // [05] N Tamanho do campo
	                   0 , ;                  // [06] N Decimal do campo
	                   NIL, ;                 // [07] B Code-block de validação do campo
	                   NIL, ;                 // [08] B Code-block de validação When do campo
	                   , ;                    // [09] A Lista de valores permitido do campo
	                   .F., ;                 // [10] L Indica se o campo tem preenchimento obrigatório
	                   NIL, ;                 // [11] B Code-block de inicializacao do campo
	                   .F., ;                 // [12] L Indica se trata de um campo chave
	                   .F., ;                 // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                  // [14] L Indica se o campo é virtual

	oStruQUJ2:AddField( ;                         // Ord. Tipo Desc.
	                   STR0040, ;                 // [01] C Titulo do campo
	                   STR0040, ;                 // [02] C ToolTip do campo
	                   "FILIAL", ;                // [03] C identificador (ID) do Field
	                   'C' , ;                    // [04] C Tipo do campo
	                   TAMSX3("QU4_FILIAL")[1], ; // [05] N Tamanho do campo
	                   0 , ;                      // [06] N Decimal do campo
	                   NIL, ;                     // [07] B Code-block de validação do campo
	                   NIL, ;                     // [08] B Code-block de validação When do campo
	                   , ;                        // [09] A Lista de valores permitido do campo
	                   .F., ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                   NIL, ;                     // [11] B Code-block de inicializacao do campo
	                   .F., ;                     // [12] L Indica se trata de um campo chave
	                   .T., ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                      // [14] L Indica se o campo é virtual

	oStruQUJ2:AddField( ;                         // Ord. Tipo Desc.
	                   STR0012, ;                 // [01] C Titulo do campo
	                   STR0012, ;                 // [02] C ToolTip do campo
	                   "CHKLST", ;                // [03] C identificador (ID) do Field
	                   'C' , ;                    // [04] C Tipo do campo
	                   TAMSX3("QU4_CHKLST")[1], ; // [05] N Tamanho do campo
	                   0 , ;                      // [06] N Decimal do campo
	                   NIL, ;                     // [07] B Code-block de validação do campo
	                   NIL, ;                     // [08] B Code-block de validação When do campo
	                   , ;                        // [09] A Lista de valores permitido do campo
	                   .F., ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                   NIL, ;                     // [11] B Code-block de inicializacao do campo
	                   .F., ;                     // [12] L Indica se trata de um campo chave
	                   .T., ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                      // [14] L Indica se o campo é virtual
	
	oStruQUJ2:AddField( ;                        // Ord. Tipo Desc.
	                   STR0043, ;                // [01] C Titulo do campo
	                   STR0043, ;                // [02] C ToolTip do campo
	                   "REVIS", ;                // [03] C identificador (ID) do Field
	                   'C' , ;                   // [04] C Tipo do campo
	                   TAMSX3("QU4_REVIS")[1], ; // [05] N Tamanho do campo
	                   0 , ;                     // [06] N Decimal do campo
	                   NIL, ;                    // [07] B Code-block de validação do campo
	                   NIL, ;                    // [08] B Code-block de validação When do campo
	                   , ;                       // [09] A Lista de valores permitido do campo
	                   .F., ;                    // [10] L Indica se o campo tem preenchimento obrigatório
	                   NIL, ;                    // [11] B Code-block de inicializacao do campo
	                   .F., ;                    // [12] L Indica se trata de um campo chave
	                   .T., ;                    // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                     // [14] L Indica se o campo é virtual
	                   
	oStruQUJ2:AddField( ;                         // Ord. Tipo Desc.
	                   STR0045, ;                 // [01] C Titulo do campo
	                   STR0045, ;                 // [02] C ToolTip do campo
	                   "CHKITE", ;                // [03] C identificador (ID) do Field
	                   'C' , ;                    // [04] C Tipo do campo
	                   TAMSX3("QU4_CHKITE")[1], ; // [05] N Tamanho do campo
	                   0 , ;                      // [06] N Decimal do campo
	                   NIL, ;                     // [07] B Code-block de validação do campo
	                   NIL, ;                     // [08] B Code-block de validação When do campo
	                   , ;                        // [09] A Lista de valores permitido do campo
	                   .F., ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                   NIL, ;                     // [11] B Code-block de inicializacao do campo
	                   .F., ;                     // [12] L Indica se trata de um campo chave
	                   .T., ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                      // [14] L Indica se o campo é virtual
	

	oStruQUJ2:AddField( ;                         // Ord. Tipo Desc.
	                   STR0047, ;                 // [01] C Titulo do campo
	                   STR0048, ;                 // [02] C ToolTip do campo
	                   "QSTITE", ;                // [03] C identificador (ID) do Field
	                   'C' , ;                    // [04] C Tipo do campo
	                   TAMSX3("QU4_QSTITE")[1], ; // [05] N Tamanho do campo
	                   0 , ;                      // [06] N Decimal do campo
	                   NIL, ;                     // [07] B Code-block de validação do campo
	                   NIL, ;                     // [08] B Code-block de validação When do campo
	                   , ;                        // [09] A Lista de valores permitido do campo
	                   .F., ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                   NIL, ;                     // [11] B Code-block de inicializacao do campo
	                   .F., ;                     // [12] L Indica se trata de um campo chave
	                   .T., ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                      // [14] L Indica se o campo é virtual

	oStruQUJ2:AddField( ;                     // Ord. Tipo Desc.
	                   STR0049, ;             // [01] C Titulo do campo
	                   STR0050, ;             // [02] C ToolTip do campo
	                   "TXTQST", ;            // [03] C identificador (ID) do Field
	                   'C' , ;                // [04] C Tipo do campo
	                   80, ;                  // [05] N Tamanho do campo
	                   0 , ;                  // [06] N Decimal do campo
	                   NIL, ;                 // [07] B Code-block de validação do campo
	                   NIL, ;                 // [08] B Code-block de validação When do campo
	                   , ;                    // [09] A Lista de valores permitido do campo
	                   .F., ;                 // [10] L Indica se o campo tem preenchimento obrigatório
	                   NIL, ;                 // [11] B Code-block de inicializacao do campo
	                   .F., ;                 // [12] L Indica se trata de um campo chave
	                   .T., ;                 // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                  // [14] L Indica se o campo é virtual  
	                   
	oStruQUE:AddField( ;                     // Ord. Tipo Desc.
	                   STR0063, ;            // [01] C Titulo do campo
	                   STR0064, ;            // [02] C ToolTip do campo
	                   "QUE_CHKOK", ;        // [03] C identificador (ID) do Field
	                   'L' , ;               // [04] C Tipo do campo
	                   1, ;                  // [05] N Tamanho do campo
	                   0 , ;                 // [06] N Decimal do campo
	                   NIL, ;                // [07] B Code-block de validação do campo
	                   NIL, ;                // [08] B Code-block de validação When do campo
	                   , ;                   // [09] A Lista de valores permitido do campo
	                   .F., ;                // [10] L Indica se o campo tem preenchimento obrigatório
	                   NIL, ;                // [11] B Code-block de inicializacao do campo
	                   .F., ;                // [12] L Indica se trata de um campo chave
	                   .F., ;                // [13] L Indica se o campo pode receber valor em uma operação de update.
	                   .T. )                 // [14] L Indica se o campo é virtual

	oStruQUB:SetProperty("QUB_ENCREA", MODEL_FIELD_OBRIGAT, .F.)
	oStruQUB:SetProperty("QUB_CONCLU", MODEL_FIELD_OBRIGAT, .F.)
	oStruQUB:SetProperty("QUB_STATUS", MODEL_FIELD_INIT, {||"1"})
	oStruQUH:SetProperty("QUH_EFETIV", MODEL_FIELD_INIT, {||"1"})
	oStruQUH:SetProperty("QUH_NUMAUD", MODEL_FIELD_INIT, {||M->QUB_NUMAUD})
	oStruQUI:SetProperty("QUI_USERNA", MODEL_FIELD_OBRIGAT, .F.)
	oStruQUI:SetProperty("QUI_EMAIL",  MODEL_FIELD_OBRIGAT, .F.)
	
	// Alterações de dicionário necessárias para que a tela normal e a MVC rodem ao mesmo tempo.
	oStruQUB:SetProperty("QUB_NUMAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_NUMAUD" , "ExistChav('QUB',M->QUB_NUMAUD,1,'AUDJAEXIST') .And. QA250chkAg() .And. FreeForUse('QUB',M->QUB_NUMAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_INIAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_INIAUD" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_ENCAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_ENCAUD" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_ENCREA" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_ENCREA" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCREA)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_FILMAT" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_FILMAT" , "QVldUsuQUB()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_AUDLID" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_AUDLID" , "QVldUsuQUB()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_CODFOR" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_CODFOR" , "Q250VldCpo()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_LOJA"   , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_LOJA"   , "Q250VldCpo()",.F.,.F. ))
	
	oStruQUB:SetProperty("QUB_ENCREA", MODEL_FIELD_INIT, Nil)
	
	oStruQUC:SetProperty("QUC_FILMAT" , MODEL_FIELD_VALID, MTBlcVld("QUC", "QUC_FILMAT" , "QVldUsuQUC()",.F.,.F. ))
	oStruQUC:SetProperty("QUC_CODAUD" , MODEL_FIELD_VALID, MTBlcVld("QUC", "QUC_CODAUD" , "QVldUsuQUC()",.F.,.F. ))
	oStruQUC:SetProperty("QUC_FILMAT", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUC:SetProperty("QUC_CODAUD", MODEL_FIELD_OBRIGAT, .T.)
	
	oStruQUE:SetProperty("QUE_NUMAUD",  MODEL_FIELD_OBRIGAT, .F.)
	oStruQUE:SetProperty("QUE_CHKLST",  MODEL_FIELD_OBRIGAT, .F.)
	oStruQUE:SetProperty("QUE_REVIS" ,  MODEL_FIELD_OBRIGAT, .F.)
	oStruQUE:SetProperty("QUE_CHKITE",  MODEL_FIELD_OBRIGAT, .F.)
	oStruQUE:SetProperty("QUE_QSTITE",  MODEL_FIELD_OBRIGAT, .F.)
	
	oStruQUH:SetProperty("QUH_FILMAT" , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_FILMAT" , "QVldUsuQUH()",.F.,.F. ))
	oStruQUH:SetProperty("QUH_CODAUD" , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_CODAUD" , "QVldUsuQUH()",.F.,.F. ))
	oStruQUH:SetProperty("QUH_DTIN"   , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_DTIN"   , "QVldDH('DTIN', M->QUH_DTIN)",.F.,.F. ))
	oStruQUH:SetProperty("QUH_HRIN"   , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_HRIN"   , "QVldDH('HRIN', M->QUH_HRIN)",.F.,.F. ))
	oStruQUH:SetProperty("QUH_DTFI"   , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_DTFI"   , "QVldDH('DTFI', M->QUH_DTFI)",.F.,.F. ))
	oStruQUH:SetProperty("QUH_HRFI"   , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_HRFI"   , "QVldDH('HRFI', M->QUH_HRFI)",.F.,.F. ))
	
	oStruQUH:SetProperty("QUH_DESTIN" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUH:SetProperty("QUH_FILMAT" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUH:SetProperty("QUH_CODAUD" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUH:SetProperty("QUH_CCUSTO" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUH:SetProperty("QUH_CONFID" , MODEL_FIELD_WHEN, {||.T.})
	
	oStruQUJ:SetProperty("QUJ_CHKLST" , MODEL_FIELD_VALID, MTBlcVld("QUJ", "QUJ_CHKLST" , "Q250ChkLst(M->QUJ_CHKLST,,,,.T.)",.F.,.F. ))
	oStruQUJ:SetProperty("QUJ_CHKITE" , MODEL_FIELD_VALID, MTBlcVld("QUJ", "QUJ_CHKITE" , "naovazio()",.F.,.F. ))
	oStruQUJ:SetProperty("QUJ_CHKLST" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUJ:SetProperty("QUJ_REVIS"  , MODEL_FIELD_WHEN, {||.T.})
	oStruQUJ:SetProperty("QUJ_CHKITE" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUJ:SetProperty("QUJ_NIVEL"  , MODEL_FIELD_WHEN, {||.T.})
	
	oStruQUK:SetProperty("QUK_CODREU", MODEL_FIELD_INIT, Nil)
	
	oStruQUK:SetProperty("QUK_CODREU", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_DESCR" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_ORIGEM", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_DATARE", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_HORARE", MODEL_FIELD_OBRIGAT, .T.)
	oStruQUK:SetProperty("QUK_LOCAL" , MODEL_FIELD_OBRIGAT, .T.)
	
	// Desativando as triggers da SX7 para não ocorrer conflito.
	For nX:=1 To Len(oStruQUJ:aTriggers)
		oStruQUJ:aTriggers[nX][3] := {|| .F. }
	Next nX
	
	For nX:=1 To Len(oStruQUC:aTriggers)
		oStruQUC:aTriggers[nX][3] := {|| .F. }
	Next nX
	
	oStruQUC:AddTrigger("QUC_CODAUD", "QUC_NOMAUD", {||.T.}, {|oModel|Posicione("QAA",1,oModel:GetValue("QUC_FILMAT")+oModel:GetValue("QUC_CODAUD"),"QAA_NOME")})
	oStruQUC:AddTrigger("QUC_CODAUD", "QUC_EMAIL" , {||.T.}, {|oModel|Posicione("QAA",1,oModel:GetValue("QUC_FILMAT")+oModel:GetValue("QUC_CODAUD"),"QAA_EMAIL")})
	//-----------------------------
	oStruQUJ:AddTrigger("QUJ_CHKITE", "QUJ_CHKITE", {||.T.}, {||LoadGrid()}) 
	oStruQUJ:AddTrigger("QUJ_CHKITE", "QUJ_CHKITE", {||.T.}, {||TrgQUJ()})

	oModel := MPFormModel():New( 'QADA250', , {|oModel|PosValidQUB(oModel)},{|oModel|A250Grv(oModel)},{|oModel|QA250Cancel(oModel)})
	oModel:AddFields( 'QUBMASTER', /*cOwner*/, oStruQUB , , )
	oModel:AddFields( 'REUNIAO', 'QUBMASTER', oStruREU , , , {||LoadREU()} )
	oModel:AddGrid( 'QUHDETAIL'  ,'QUBMASTER', oStruQUH , {|oModel, nLine, cAction|Pre250QUH(oModel, nLine, cAction)}, {||LinOkQUH()},,)
	oModel:AddGrid( 'QUCDETAIL'  ,'QUBMASTER', oStruQUC , , )
	oModel:AddGrid( 'QUIDETAIL'  ,'QUBMASTER', oStruQUI , , )
	oModel:AddGrid( 'QUJDETAIL'  ,'QUHDETAIL', oStruQUJ , {|oModel, nLine, cAction|Pre250QUJ(oModel, nLine, cAction)}, )
	oModel:AddGrid( 'QUJ2DETAIL' ,'QUJDETAIL', oStruQUJ2 ,,,,, {|oModel|LoadUpd(oModel)})
	oModel:AddGrid( 'QUEDETAIL'  ,'QUJDETAIL', oStruQUE , , {||PosVldQUE()}, )
	oModel:AddGrid( 'QUDDETAIL'  ,'QUBMASTER', oStruQUD , , )
	oModel:AddGrid( 'QUKDETAIL'  ,'QUBMASTER', oStruQUK , , )
	oModel:SetPrimaryKey( {} )
	oModel:SetRelation("QUHDETAIL", {{"QUH_FILIAL",'xFilial("QUH")'},{"QUH_NUMAUD","QUB_NUMAUD"}},QUH->(IndexKey(1)))
	oModel:SetRelation("QUCDETAIL", {{"QUC_FILIAL",'xFilial("QUC")'},{"QUC_NUMAUD","QUB_NUMAUD"}},QUC->(IndexKey(1)))
	oModel:SetRelation("QUIDETAIL", {{"QUI_FILIAL",'xFilial("QUI")'},{"QUI_NUMAUD","QUB_NUMAUD"}},QUI->(IndexKey(1)))
	oModel:SetRelation("QUDDETAIL", {{"QUD_FILIAL",'xFilial("QUD")'},{"QUD_NUMAUD","QUB_NUMAUD"}},QUD->(IndexKey(1)))
	oModel:SetRelation("QUKDETAIL", {{"QUK_FILIAL",'xFilial("QUK")'},{"QUK_NUMAUD","QUB_NUMAUD"}},QUK->(IndexKey(1)))
	oModel:SetRelation("QUJDETAIL", {{"QUJ_FILIAL",'xFilial("QUJ")'},{"QUJ_NUMAUD","QUB_NUMAUD"},{"QUJ_SEQ","QUH_SEQ"}},QUJ->(IndexKey(1)))
	oModel:SetRelation("QUEDETAIL", {{"QUE_FILIAL",'xFilial("QUE")'},{"QUE_NUMAUD","QUB_NUMAUD"},{"QUE_CHKLST", "QUJ_CHKLST"},{"QUE_REVIS", "QUJ_REVIS"}, {"QUE_CHKITE", "QUJ_CHKITE"}},QUE->(IndexKey(1)))
	//-----------
	oModel:SetDescription(STR0037)
	oModel:GetModel( 'QUBMASTER' ):SetDescription(STR0001)
	oModel:GetModel( 'QUHDETAIL' ):SetDescription(STR0001)
	oModel:GetModel( 'QUCDETAIL' ):SetDescription(STR0007)
	oModel:GetModel( 'QUIDETAIL' ):SetDescription(STR0008)
	oModel:GetModel( 'QUJDETAIL' ):SetDescription(STR0009)
	oModel:GetModel( 'QUJ2DETAIL'):SetDescription(STR0010)
	oModel:GetModel( 'QUDDETAIL' ):SetDescription("QUD")
	oModel:GetModel( 'QUKDETAIL' ):SetDescription("QUK")
	oModel:GetModel( 'REUNIAO'   ):SetDescription(STR0038)
	oModel:GetModel( 'QUEDETAIL' ):SetDescription(STR0039)

	FWMemoVirtual(oStruQUB, {{'QUB_DESCHV','QUB_DESCR1'}})
	FWMemoVirtual(oStruQUE, {{'QUE_TXTCHV','QUE_TXTQS1'}, {'QUE_OBSCHV','QUE_OBSER1'}, {'QUE_REQCHV','QUE_REQQS1'}})

	oModel:GetModel( 'QUJ2DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'QUJ2DETAIL' ):SetNoDeleteLine(.T.)

	oModel:GetModel( 'QUJDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QUJ2DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QUEDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QUIDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QUDDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QUKDETAIL' ):SetOptional(.T.)
	
	oStruQUB:SetProperty("QUB_NUMAUD", MODEL_FIELD_WHEN, {||oModel:GetValue('REUNIAO','LREUNIAO')})

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
	Local oModel    := FWLoadModel('QADA250')
	Local oStruQUB  := FWFormStruct(2,'QUB')
	Local oStruQUH  := FWFormStruct(2,'QUH')	
	Local oStruQUC  := FWFormStruct(2,'QUC')
	Local oStruQUI  := FWFormStruct(2,'QUI')
	Local oStruQUJ  := FWFormStruct(2,'QUJ')
	Local oStruQUJ2 := FWFormViewStruct():New()
	Local oStruQUE  := FWFormStruct(2,'QUE')
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oStruQUJ2:AddField( ;          // Ord. Tipo Desc.
	                   'CHKOK' , ; // [01] C Nome do Campo
	                   '01' , ;    // [02] C Ordem
	                   ' ' , ;     // [03] C Titulo do campo 
	                   ' ', ;      // [04] C Descrição do campo 
	                   {} , ;      // [05] A Array com Help 
	                   'L' , ;     // [06] C Tipo do campo
	                   '@!' , ;    // [07] C Picture
	                   NIL , ;     // [08] B Bloco de Picture Var
	                   '' , ;      // [09] C Consulta F3
	                   .T. , ;     // [10] L Indica se o campo é evitável
	                   NIL , ;     // [11] C Pasta do campo
	                   NIL , ;     // [12] C Agrupamento do campo
	                   Nil , ;     // [13] A Lista de valores permitido do campo (Combo)
	                   Nil , ;     // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;     // [15] C Inicializador de Browse
	                   .T. , ;     // [16] L Indica se o campo é virtual
	                   NIL , ;     // [17] C Picture Variável
						 .F.)	      // [18]  L   Indica pulo de linha após o campo

	oStruQUJ2:AddField( ;                     // Ord. Tipo Desc.
	                   "FILIAL" , ;           // [01] C Nome do Campo
	                   "2" , ;                // [02] C Ordem
	                   AllTrim( STR0040 ) , ; // [03] C Titulo do campo 
	                   AllTrim( STR0041 ) , ; // [04] C Descrição do campo 
	                   { STR0041 } , ;        // [05] A Array com Help 
	                   'C' , ;                // [06] C Tipo do campo
	                   '' , ;                 // [07] C Picture
	                   NIL , ;                // [08] B Bloco de Picture Var
	                   '' , ;                 // [09] C Consulta F3
	                   .F. , ;                // [10] L Indica se o campo é editável
	                   NIL , ;                // [11] C Pasta do campo
	                   NIL , ;                // [12] C Agrupamento do campo
	                   NIL , ;                // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                // [15] C Inicializador de Browse
	                   .T. , ;                // [16] L Indica se o campo é virtual
	                   NIL )                  // [17] C Picture Variável

	oStruQUJ2:AddField( ;                     // Ord. Tipo Desc.
	                   "CHKLST" , ;           // [01] C Nome do Campo
	                   "3" , ;                // [02] C Ordem
	                   AllTrim( STR0012 ) , ; // [03] C Titulo do campo 
	                   AllTrim( STR0042 ) , ; // [04] C Descrição do campo 
	                   { STR0042 } , ;        // [05] A Array com Help 
	                   'C' , ;                // [06] C Tipo do campo
	                   '' , ;                 // [07] C Picture
	                   NIL , ;                // [08] B Bloco de Picture Var
	                   '' , ;                 // [09] C Consulta F3
	                   .F. , ;                // [10] L Indica se o campo é evitável
	                   NIL , ;                // [11] C Pasta do campo
	                   NIL , ;                // [12] C Agrupamento do campo
	                   NIL , ;                // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                // [15] C Inicializador de Browse
	                   .T. , ;                // [16] L Indica se o campo é virtual
	                   NIL )                  // [17] C Picture Variável

	oStruQUJ2:AddField( ;                     // Ord. Tipo Desc.
	                   "REVIS" , ;            // [01] C Nome do Campo
	                   "4" , ;                // [02] C Ordem
	                   AllTrim( STR0043 ) , ; // [03] C Titulo do campo 
	                   AllTrim( STR0043 ) , ; // [04] C Descrição do campo 
	                   { STR0044 } , ;        // [05] A Array com Help 
	                   'C' , ;                // [06] C Tipo do campo
	                   '@ 99' , ;             // [07] C Picture
	                   NIL , ;                // [08] B Bloco de Picture Var
	                   '' , ;                 // [09] C Consulta F3
	                   .F. , ;                // [10] L Indica se o campo é evitável
	                   NIL , ;                // [11] C Pasta do campo
	                   NIL , ;                // [12] C Agrupamento do campo
	                   NIL , ;                // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                // [15] C Inicializador de Browse
	                   .T. , ;                // [16] L Indica se o campo é virtual
	                   NIL )                  // [17] C Picture Variável

	oStruQUJ2:AddField( ;                     // Ord. Tipo Desc.
	                   "CHKITE" , ;           // [01] C Nome do Campo
	                   "5" , ;                // [02] C Ordem
	                   AllTrim( STR0045 ) , ; // [03] C Titulo do campo 
	                   AllTrim( STR0045 ) , ; // [04] C Descrição do campo 
	                   { STR0046 } , ;        // [05] A Array com Help 
	                   'C' , ;                // [06] C Tipo do campo
	                   '' , ;                 // [07] C Picture
	                   NIL , ;                // [08] B Bloco de Picture Var
	                   '' , ;                 // [09] C Consulta F3
	                   .F. , ;                // [10] L Indica se o campo é evitável
	                   NIL , ;                // [11] C Pasta do campo
	                   NIL , ;                // [12] C Agrupamento do campo
	                   NIL , ;                // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                // [15] C Inicializador de Browse
	                   .T. , ;                // [16] L Indica se o campo é virtual
	                   NIL )                  // [17] C Picture Variável

	oStruQUJ2:AddField( ;                     // Ord. Tipo Desc.
	                   "QSTITE" , ;           // [01] C Nome do Campo
	                   "6" , ;                // [02] C Ordem
	                   AllTrim( STR0047 ) , ; // [03] C Titulo do campo 
	                   AllTrim( STR0048 ) , ; // [04] C Descrição do campo 
	                   { STR0048 } , ;        // [05] A Array com Help 
	                   'C' , ;                // [06] C Tipo do campo
	                   '@!' , ;               // [07] C Picture
	                   NIL , ;                // [08] B Bloco de Picture Var
	                   '' , ;                 // [09] C Consulta F3
	                   .F. , ;                // [10] L Indica se o campo é evitável
	                   NIL , ;                // [11] C Pasta do campo
	                   NIL , ;                // [12] C Agrupamento do campo
	                   NIL , ;                // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                // [15] C Inicializador de Browse
	                   .T. , ;                // [16] L Indica se o campo é virtual
	                   NIL )                  // [17] C Picture Variável

	oStruQUJ2:AddField( ;                     // Ord. Tipo Desc.
	                   "TXTQST" , ;           // [01] C Nome do Campo
	                   "7" , ;                // [02] C Ordem
	                   AllTrim( STR0049 ) , ; // [03] C Titulo do campo
	                   AllTrim( STR0050 ) , ; // [04] C Descrição do campo
	                   { STR0050 } , ;        // [05] A Array com Help
	                   'C' , ;                // [06] C Tipo do campo
	                   '' , ;                 // [07] C Picture
	                   NIL , ;                // [08] B Bloco de Picture Var
	                   '' , ;                 // [09] C Consulta F3
	                   .F. , ;                // [10] L Indica se o campo é evitável
	                   NIL , ;                // [11] C Pasta do campo
	                   NIL , ;                // [12] C Agrupamento do campo
	                   Nil , ;                // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                // [15] C Inicializador de Browse
	                   .T. , ;                // [16] L Indica se o campo é virtual
	                   NIL )                  // [17] C Picture Variável
	                   
	oStruQUE:AddField( ;               // Ord. Tipo Desc.
	                   'QUE_CHKOK' , ; // [01] C Nome do Campo
	                   '01' , ;        // [02] C Ordem
	                   ' ' , ;         // [03] C Titulo do campo 
	                   ' ', ;          // [04] C Descrição do campo 
	                   {} , ;          // [05] A Array com Help 
	                   'L' , ;         // [06] C Tipo do campo
	                   '@!' , ;        // [07] C Picture
	                   NIL , ;         // [08] B Bloco de Picture Var
	                   '' , ;          // [09] C Consulta F3
	                   .T. , ;         // [10] L Indica se o campo é evitável
	                   NIL , ;         // [11] C Pasta do campo
	                   NIL , ;         // [12] C Agrupamento do campo
	                   Nil , ;         // [13] A Lista de valores permitido do campo (Combo)
	                   Nil , ;         // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;         // [15] C Inicializador de Browse
	                   .T. , ;         // [16] L Indica se o campo é virtual
	                   NIL , ;         // [17] C Picture Variável
						 .F.)            // [18]  L   Indica pulo de linha após o campo

	oView:AddField( 'VIEW_QUB', oStruQUB,  'QUBMASTER' )
	oView:AddGrid( 'VIEW_QUH', oStruQUH,  'QUHDETAIL' )
	oView:AddGrid( 'VIEW_QUC', oStruQUC,  'QUCDETAIL' )
	oView:AddGrid( 'VIEW_QUI', oStruQUI,  'QUIDETAIL' )	
	oView:AddGrid( 'VIEW_QUJ', oStruQUJ,  'QUJDETAIL' )
	oView:AddGrid( 'VIEW_QUJ2', oStruQUJ2, 'QUJ2DETAIL')
	oView:AddGrid( 'VIEW_QUE', oStruQUE,  'QUEDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )
	
	oView:CreateVerticalBox( 'PASTINFV'       , 100    ,'INFERIOR' )
	
	oView:CreateFolder( 'PASTA_INFE','PASTINFV' )		
	oView:AddSheet( 'PASTA_INFE', 'ABA01', STR0011 )	
	oView:AddSheet( 'PASTA_INFE', 'ABA02', STR0007 )
	oView:AddSheet( 'PASTA_INFE', 'ABA03', STR0008 )		

	oView:CreateHorizontalBox( 'INFAREA'    , 50    , , , 'PASTA_INFE' , 'ABA01' )
	oView:CreateHorizontalBox( 'INFERIOR2'  , 50    , , , 'PASTA_INFE' , 'ABA01' )
	oView:CreateHorizontalBox( 'EQUIPE'     , 100    , , , 'PASTA_INFE' , 'ABA02' )
	oView:CreateHorizontalBox( 'EMAIL'      , 100    , , , 'PASTA_INFE' , 'ABA03' )
	
	oView:CreateVerticalBox(   'INF3'     , 100    ,'INFERIOR2', , 'PASTA_INFE' , 'ABA01' )

	oView:CreateFolder( 'FOLDERCHK','INF3' )
	oView:AddSheet( 'FOLDERCHK', 'ABA05',STR0012 )
	oView:AddSheet( 'FOLDERCHK', 'ABA06',STR0010 )
	oView:AddSheet( 'FOLDERCHK', 'ABA07',STR0039 , {||VldChkLst()})
	
	oView:CreateVerticalBox( 'CHECK'       , 100    , , , 'FOLDERCHK', 'ABA05')
	oView:CreateVerticalBox( 'PERGU'       , 100    , , , 'FOLDERCHK', 'ABA06')
	oView:CreateVerticalBox( 'PERGA'       , 100    , , , 'FOLDERCHK', 'ABA07')

	oView:SetOwnerView( 'VIEW_QUB' , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_QUH' , 'INFAREA' )	
	oView:SetOwnerView( 'VIEW_QUC' , 'EQUIPE' )
	oView:SetOwnerView( 'VIEW_QUI' , 'EMAIL' )
	oView:SetOwnerView( 'VIEW_QUJ' , 'CHECK' )
	oView:SetOwnerView( 'VIEW_QUJ2', 'PERGU' )
	oView:SetOwnerView( 'VIEW_QUE' , 'PERGA' )
	
	oView:AddIncrementField( 'VIEW_QUH', 'QUH_SEQ' )
	oView:AddIncrementField( 'VIEW_QUC', 'QUC_ITEM' )
	oView:AddIncrementField( 'VIEW_QUI', 'QUI_ITEM' )
	oView:AddIncrementField( 'VIEW_QUE', 'QUE_QSTITE' )
	
	oStruQUB:RemoveField("QUB_FILIAL") 
	oStruQUB:RemoveField("QUB_DESCHV") 
	oStruQUB:RemoveField("QUB_CONCLU")
	oStruQUB:RemoveField("QUB_SUGOBS")
	oStruQUB:RemoveField("QUB_ENCREA")
	oStruQUB:RemoveField("QUB_OK") 
	oStruQUB:RemoveField("QUB_CHAVE") 
	oStruQUB:RemoveField("QUB_SUGCHV") 
	oStruQUB:RemoveField("QUB_STATUS") 
	oStruQUC:RemoveField("QUC_FILIAL")
	oStruQUC:RemoveField("QUC_NUMAUD") 
	oStruQUH:RemoveField("QUH_FILIAL")
	oStruQUH:RemoveField("QUH_NUMAUD")
	oStruQUH:RemoveField("QUH_EFETIV")
	oStruQUI:RemoveField("QUI_FILIAL")
	oStruQUI:RemoveField("QUI_NUMAUD")
	oStruQUJ:RemoveField("QUJ_FILIAL")
	oStruQUJ:RemoveField("QUJ_NUMAUD")
	oStruQUJ:RemoveField("QUJ_SEQ")
	oStruQUJ:RemoveField("QUJ_EFETIV")
	oStruQUJ2:RemoveField("FILIAL")
	oStruQUJ2:RemoveField("CHKLST")
	oStruQUJ2:RemoveField("REVIS")
	oStruQUJ2:RemoveField("CHKITE")
	oStruQUE:RemoveField("QUE_FILIAL")
	oStruQUE:RemoveField("QUE_NUMAUD")
	oStruQUE:RemoveField("QUE_CHKLST")
	oStruQUE:RemoveField("QUE_REVIS")
	oStruQUE:RemoveField("QUE_CHKITE")
	oStruQUE:RemoveField("QUE_TXTCHV")
	oStruQUE:RemoveField("QUE_OBSCHV")
	oStruQUE:RemoveField("QUE_REQCHV")
	
	oView:AddUserButton( STR0051,'MAGIC_BMP', {|| QA250V() } )
	
Return oView
//--------------------------------------------------------------------
/*/{Protheus.doc} QA250V()
Definicao da View
@author Leonardo Bratti
@since 26/07/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function QA250V()	
	Local oModel    := FWModelActive()
	Local oModelQUB := oModel:GetModel('QUBMASTER')
	local nOper     := oModel:GetOperation()
	Local lRet      := .T.
	Local cTitulo   := IIF(nOper==3,STR0004,IIF(nOper==4,STR0005,IIF(nOper==5,STR0006,STR0003)))
	LOCAL aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0052},{.T.,STR0053},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	LOCAL nOk
	
	cCodAudit := oModelQUB:GetValue('QUB_NUMAUD')
	
	If !(Empty(cCodAudit))
		nOk := FWExecView(cTitulo,'QADA250A', nOper,,, { || .T. }, ,aButtons)
		IF (nOper == 3 .OR. nOper == 4) .AND. nOk == 0
			oModel:LoadValue('REUNIAO','LREUNIAO',.F.)
		ENDIF
	Else
		Help( , , 'Help', ,STR0013, 1, 0 )
		lRet := .F.
	EndIf
Return
//--------------------------------------------------------------------
/*/{Protheus.doc} QA250ChkAg()
Checa se existe agendamento para esta Auditoria
@author Leonardo Bratti
@since 14/08/2017
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function QA250ChkAg()
Local lRet:= .T.

If !isBlind()
	QUA->(DbSetOrder(3))
	If QUA->(DbSeek(xFilial("QUA")+M->QUB_NUMAUD))
		If QUA->QUA_STATUS <> "2"
			lRet:= MsgYesNo(OemToAnsi(STR0054),STR0001) 
		EndIf
	
	EndIf	
EndIf
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} Q250VldDat()
Verifica se a Data Inicio e maior que a Data Final
@author Leonardo Bratti
@since 14/08/2017
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function Q250VldDat(dGet1,dGet2)

Local lRetorno := .T.
If (dGet1 # Ctod('')) .And. (dGet2 # Ctod(''))
	If dGet1 > dGet2
		Help("",1,"100INVDATA") // A data informada e invalida       
		lRetorno := .F.
	EndIf		
EndIf		
Return (lRetorno)

//----------------------------------------------------------------------
/*/{Protheus.doc} QVldUsuQUB()
Validacao da filial/codigo do Auditor lider/alocado QUB	
@author Leonardo Bratti
@since 16/08/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QVldUsuQUB()
	Local oModel    := FWModelActive()
	Local oModelQUB := oModel:GetModel('QUBMASTER')
	Local lRetorno  := .T.
	Local cFilMat   := oModelQUB:GetValue('QUB_FILMAT')
	Local cCodMat   := oModelQUB:GetValue('QUB_AUDLID')
	Local cCampo    := ReadVar()
	
	If !Empty(cFilMat) .And. !Empty(cCodMat)                                       		
		lRetorno := QA_ChkMat(cFilMat,cCodMat)
		IF lRetorno
		   lRetorno:=POSICIONE("QAA",1,cFilMat+cCodMat,"QAA_AUDIT")=="1"
		   IF !lRetorno
		   		Help( , , 'Help', ,STR0055, 1, 0 ) 
		   Endif		
		Endif
	EndIf
Return (lRetorno)

//----------------------------------------------------------------------
/*/{Protheus.doc} Q250VldCpo()
Verifica se o conteudo do campo QUB_CODFOR esta cadastrado na tabela SA2. 
@author Leonardo Bratti
@since 16/08/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function Q250VldCpo()
	Local lRet      := .T.
	Local aAreaAnt  := GetArea()
	Local aAreaSA2  := SA2->(GetArea())
	Local cCampo    := ReadVar()
	Local cChave    := ""
	Local oModel    := FWModelActive()
	Local oModelQUB := oModel:GetModel("QUBMASTER")

	If cCampo == "M->QUB_CODFOR" .And. ValType(oModelQUB) == 'O' 
		cChave := &(ReadVar())
	    If !(Empty(oModelQUB:GetValue('QUB_LOJA')))
	        cChave += oModelQUB:GetValue('QUB_LOJA')
	    EndIf
	ElseIf cCampo == "M->QUB_LOJA" .And. ValType(oModelQUB) == 'O' 
	    If !(Empty(oModelQUB:GetValue("QUB_CODFOR")))
	        cChave += oModelQUB:GetValue("QUB_CODFOR")+&(ReadVar())
	    EndIf
	EndIf

	lRet := ExistCpo("SA2",cChave)

	RestArea(aAreaSA2)
	RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} QVldUsuQUH()
Validacao da filial/codigo do Auditor QUH
@author Luiz Henrique Bourscheid
@since 31/08/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QVldUsuQUH()
	Local oModel    := FWModelActive()
	Local oModelQUH := oModel:GetModel('QUHDETAIL')
	Local lRetorno  := .T.
	Local cFilMat   := oModelQUH:GetValue('QUH_FILMAT')
	Local cCodMat   := oModelQUH:GetValue('QUH_CODAUD')
	Local cCampo    := ReadVar()
	
	If !Empty(cFilMat) .And. !Empty(cCodMat)                                       		
		lRetorno := QA_ChkMat(cFilMat,cCodMat)
		IF lRetorno
		   lRetorno:=POSICIONE("QAA",1,cFilMat+cCodMat,"QAA_AUDIT")=="1"
		   IF !lRetorno
		   		Help( , , 'Help', ,STR0055, 1, 0 ) 
		   Endif		
		Endif
	EndIf
Return (lRetorno)
//----------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid()
Carrega as perguntas na aba de perguntas
@author Luiz Henrique Bourscheid
@since 31/08/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function LoadGrid()
	Local oModel     := FWModelActive()
	Local oModelQUJ  := oModel:GetModel("QUJDETAIL")
	Local oModelQUJ2 := oModel:GetModel("QUJ2DETAIL")
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local oModelQUH  := oModel:GetModel("QUHDETAIL")
	Local oModelQUE  := oModel:GetModel("QUEDETAIL")
	Local nLinha	   := 0
	Local nContCpo   := 0
	Local aFilCpos   := {}
	Local aDados     := {}
	Local nOperation := oModel:GetOperation()

	oModelQUE:LoadValue("QUE_QSTITE", Q250NexQst())

	oModelQUJ2:SetNoInsertLine(.F.)
	oModelQUJ2:SetNoUpdateLine(.F.)
	
	If !Empty(oModelQUJ:GetValue("QUJ_CHKITE"))		
		oModelQUJ:LoadValue("QUJ_DESCRI", AllTrim(Posicione("QU3", 1, xFilial("QU3")+oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE"),"QU3_DESCRI")))
		
		// -----------------------------------------------------------------------
		// Inserção dos registros de perguntas
		// -----------------------------------------------------------------------
		dbSelectArea("QU4")
		dbSetOrder(1)
		DbGoTop()
		DbSeek(xFilial("QU4")+oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE"))
		While QU4->(!Eof())
		   If oModelQUJ:GetValue("QUJ_CHKLST") == QU4->QU4_CHKLST .And. ;
		      oModelQUJ:GetValue("QUJ_REVIS") == QU4->QU4_REVIS .And. ;
		      oModelQUJ:GetValue("QUJ_CHKITE") == QU4->QU4_CHKITE
	
				If oModelQUJ2:GetLine() == nLinha
					nLinha := oModelQUJ2:AddLine()
				Else
					nLinha := oModelQUJ2:GetLine()
				EndIf
				oModelQUJ2:GoLine(nLinha)
				oModelQUJ2:SetValue("CHKOK",  .T.)
				oModelQUJ2:SetValue("FILIAL", xFilial("QU4"))
				oModelQUJ2:SetValue("CHKLST", QU4->QU4_CHKLST)
				oModelQUJ2:SetValue("REVIS",  QU4->QU4_REVIS)
				oModelQUJ2:SetValue("CHKITE", QU4->QU4_CHKITE)
				oModelQUJ2:SetValue("QSTITE", QU4->QU4_QSTITE)
				oModelQUJ2:SetValue("TXTQST", MsMM(QU4->QU4_TXTCHV, TamSX3("QU4_TXTQS1")[1]))  
	
			EndIf
			QU4->(DbSkip())
		EndDo
	Else	
		QUD->(dbSetOrder(1))
		QUD->(DbGoTop())
		QUD->(DbSeek(xFilial("QUD")+oModelQUB:GetValue("QUB_NUMAUD")+oModelQUJ:GetValue("QUJ_CHKLST")+;
		             oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE")))
		While QUD->(!Eof())
		   If oModelQUB:GetValue("QUB_NUMAUD") == QUD->QUD_NUMAUD .And. ;
		      oModelQUJ:GetValue("QUJ_CHKLST") == QUD->QUD_CHKLST .And. ;
		      oModelQUJ:GetValue("QUJ_REVIS") == QUD->QUD_REVIS .And. ;
		      oModelQUJ:GetValue("QUJ_CHKITE") == QUD->QUD_CHKITE .And. ;
		      QUD->QUD_TIPO == "2"
	
				If oModelQUJ2:GetLine() == nLinha
					nLinha := oModelQUJ2:AddLine()
				Else
					nLinha := oModelQUJ2:GetLine()
				EndIf
				oModelQUJ2:GoLine(nLinha)
				oModelQUJ2:SetValue("CHKOK",  .T.)
				oModelQUJ2:SetValue("FILIAL", xFilial("QUD"))
				oModelQUJ2:SetValue("CHKLST", QUD->QUD_CHKLST)
				oModelQUJ2:SetValue("REVIS",  QUD->QUD_REVIS)	
				oModelQUJ2:SetValue("CHKITE", QUD->QUD_CHKITE)
				oModelQUJ2:SetValue("QSTITE", QUD->QUD_QSTITE)
				oModelQUJ2:SetValue("TXTQST", MsMM(Posicione("QU4", 1, xFilial("QU4")+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE, "QU4_TXTCHV"), TamSX3("QU4_TXTQS1")[1]))
			EndIf
			QUD->(DbSkip())
		EndDo
	EndIf
	
	oModelQUJ2:SetNoInsertLine(.T.)
	oModelQUJ2:GoLine(1)

Return Nil
//----------------------------------------------------------------------
/*/{Protheus.doc} QVldUsuQUC()
Validacao da filial/codigo do Auditor QUC	
@author Luiz Henrique Bourscheid
@since 31/08/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QVldUsuQUC()
	Local oModel    := FWModelActive()
	Local oModelQUC := oModel:GetModel('QUCDETAIL')
	Local lRetorno  := .T.
	Local cFilMat   := oModelQUC:GetValue('QUC_FILMAT')
	Local cCodAud   := oModelQUC:GetValue('QUC_CODAUD')

	If !Empty(cFilMat) .And. !Empty(cCodAud)                                       		
		lRetorno := QA_ChkMat(cFilMat,cCodAud)
		IF lRetorno
		   lRetorno:=POSICIONE("QAA",1,cFilMat+cCodAud,"QAA_AUDIT")=="1"
		   IF !lRetorno
		   		Help( , , 'Help', ,STR0055, 1, 0 ) 
		   Endif		
		Endif
	EndIf
Return (lRetorno)
//----------------------------------------------------------------------
/*/{Protheus.doc} LinOkQUH()
Validacao da linha da tabela QUH
@author Luiz Henrique Bourscheid
@since 31/08/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function LinOkQUH()
	Local lRet      := .T.
	Local oModel    := FWModelActive()
	Local oModelQUH := oModel:GetModel('QUHDETAIL')
	Local lAudDep	:= SuperGetMV("MV_QADDEP",.T.,.F.)
	Local oModelQUJ  := oModel:GetModel("QUJDETAIL")
	
	If lAudDep
		QAA->(dbSetOrder(1))
		If QAA->(DBSeek(oModelQUH:GetValue('QUH_FILMAT') + oModelQUH:GetValue('QUH_CODAUD')))
			If QAA->QAA_CC == oModelQUH:GetValue('QUH_CCUSTO')
					Help( , , "Help" , , STR0056 ,1,0)
					lRet	:= .F.
			EndIf
		EndIf
	EndIf
	
	If lRet
		lRet := QA250VLDPR()
	EndIf
	
	If Empty(oModelQUJ:GetValue("QUJ_CHKLST"))
		Help("",1,"100CHKITEM") // "Nao existem check-lists relacionados para a" ### "Area Auditada"
		lRet := .F.
	EndIf

Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} QA250VLDPR()
Valida os períodos por auditor
@author Luiz Henrique Bourscheid
@since 31/08/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function QA250VLDPR()
	Local lRet      := .T.
	Local nDataHora := 0
	Local nDataHora2:= 0
	Local oModel    := FWModelActive()
	Local oModelQUH := oModel:GetModel('QUHDETAIL')
	Local dDTIn     := Ctod("  /  /  ")
	Local cHRIn     := ''
	Local dDTFim    := Ctod("  /  /  ")
	Local cHRFim    := ''
	Local nI        := ''
	Local nPosGrid  := 0
	Local aSaveLines := FWSaveRows()
	
	nPosGrid := oModelQUH:GetLine()
	dDTIn    := oModelQUH:GetValue('QUH_DTIN') 
	cHRIn    := oModelQUH:GetValue('QUH_HRIN') 
	dDTFim   := oModelQUH:GetValue('QUH_DTFI') 
	cHRFim   := oModelQUH:GetValue('QUH_HRFI') 
	cAud     := oModelQUH:GetValue('QUH_CODAUD') 	
	
	For nI := 1 To oModelQUH:Length()
		oModelQUH:GoLine( nI )
		If !(oModelQUH:IsDeleted())
			If oModelQUH:GetValue('QUH_CODAUD') == cAud
				If nI >= nPosGrid
					nDataHora := SubtHoras(  oModelQUH:GetValue('QUH_DTIN') , oModelQUH:GetValue('QUH_HRIN'),dDTFim ,cHRFim )
					If nDataHora < 0 .And. nDataHora2 < 0
						Help("",1,"Q_PERJAUTI") // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
						lRet := .F.
			 			Exit
	        		EndIf 
				ElseIf nPosGrid >= nI
						nDataHora := SubtHoras( oModelQUH:GetValue('QUH_DTFI') , oModelQUH:GetValue('QUH_HRFI') , dDTIn , cHRIn )
						nDataHora2 := SubtHoras( dDTFim, cHRFim,  oModelQUH:GetValue('QUH_DTIN') , oModelQUH:GetValue('QUH_HRIN') )
						If nDataHora < 0 .And. nDataHora2 < 0
							Help("",1,"Q_PERJAUTI") // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
							lRet := .F.
				 			Exit
	        			EndIf 
	        	Endif	
			EndIf			
		EndIf
	Next nI	
	FWRestRows( aSaveLines )
Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} A250Grv()
Realiza a gravação dos modelos.
@author Luiz Henrique Bourscheid
@since 01/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function A250Grv(oModel)
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local oModelQUH  := oModel:GetModel("QUHDETAIL")
	Local oModelQUC  := oModel:GetModel("QUCDETAIL")
	Local oModelQUI  := oModel:GetModel("QUIDETAIL")
	Local oModelQUJ  := oModel:GetModel("QUJDETAIL")
	Local oModelQUJ2 := oModel:GetModel("QUJ2DETAIL")
	Local oModelQUE  := oModel:GetModel("QUEDETAIL")
	Local lRet		   := .T.
	Local nX		   := 0
	Local nY		   := 0
	Local nZ		   := 0
	Local nOperation := oModel:GetOperation()
	Local cMessage
	Local cTitle
	Local bSendMail
	Local lGravaQUE  := .T.

	// Utilizado o método ClearData para que não seja commitada uma linha inicializada apenas com os inicializadores padrões. 
	If !oModelQUE:GetValue("QUE_CHKOK") .And. oModelQUE:GetValue("QUE_FAIXIN") == 0 .And. oModelQUE:GetValue("QUE_FAIXFI") == 0 .And. ;
	   Empty(oModelQUE:GetValue("QUE_TXTQS1")) .And. Empty(oModelQUE:GetValue("QUE_OBSER1")) .And. Empty(oModelQUE:GetValue("QUE_REQQS1")) .And. ;
	   oModelQUE:GetValue("QUE_PESO") == 0 .And. oModelQUE:Length() == 1
	 	oModelQUE:DelAllLine()
	 	lGravaQUE := .F.
	EndIf
	
	If nOperation == MODEL_OPERATION_INSERT
		For nX := 1 To oModelQUH:Length()  
			oModelQUH:GoLine(nX)
			For nY := 1 To oModelQUJ:Length()
				oModelQUJ:GoLine(nY)
				For nZ := 1 To oModelQUJ2:Length()
					oModelQUJ2:GoLine(nZ)
					RecLock("QUD",.T.)
					QUD->QUD_Filial := xFilial("QUD")
					QUD->QUD_NUMAUD := oModelQUB:GetValue("QUB_NUMAUD")
					QUD->QUD_SEQ    := oModelQUH:GetValue("QUH_SEQ")
					QUD->QUD_CHKLST := oModelQUJ:GetValue("QUJ_CHKLST")
					QUD->QUD_REVIS  := oModelQUJ:GetValue("QUJ_REVIS")
					QUD->QUD_CHKITE := oModelQUJ:GetValue("QUJ_CHKITE")
					QUD->QUD_QSTITE := oModelQUJ2:GetValue("QSTITE")  
					QUD->QUD_TIPO   := "1"
					QUD->QUD_FILMAT := oModelQUH:GetValue("QUH_FILMAT")
					QUD->QUD_CODAUD := oModelQUH:GetValue("QUH_CODAUD")
					QUD->QUD_APLICA := IIf(oModelQUJ2:GetValue("CHKOK"), "1", "2")
					QUD->(MsUnlock())
				Next nZ
				For nZ := 1 To oModelQUE:Length()
					oModelQUE:GoLine(nZ)
					If oModelQUE:GetValue("QUE_PESO") == 0 
						oModelQUE:SetValue("QUE_PESO", 1)
					EndIf
					If lGravaQUE
						RecLock("QUD",.T.)
						QUD->QUD_Filial := xFilial("QUD")
						QUD->QUD_NUMAUD := oModelQUB:GetValue("QUB_NUMAUD")
						QUD->QUD_SEQ    := oModelQUH:GetValue("QUH_SEQ")
						QUD->QUD_CHKLST := oModelQUJ:GetValue("QUJ_CHKLST")
						QUD->QUD_REVIS  := oModelQUJ:GetValue("QUJ_REVIS")
						QUD->QUD_CHKITE := oModelQUJ:GetValue("QUJ_CHKITE")
						QUD->QUD_QSTITE := oModelQUE:GetValue("QUE_QSTITE")
						QUD->QUD_TIPO   := "2"
						QUD->QUD_FILMAT := oModelQUH:GetValue("QUH_FILMAT")
						QUD->QUD_CODAUD := oModelQUH:GetValue("QUH_CODAUD")
						QUD->QUD_APLICA := IIf(oModelQUE:GetValue("QUE_CHKOK"), "1", "2")
						MsUnlock()
					EndIF
				Next nZ
			Next nY
		Next nX
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		For nX := 1 To oModelQUH:Length()  
			oModelQUH:GoLine(nX)
			For nY := 1 To oModelQUJ:Length()
				oModelQUJ:GoLine(nY)
				For nZ := 1 To oModelQUJ2:Length()
					oModelQUJ2:GoLine(nZ)
					QUD->(dbSetOrder(1))
					If QUD->(DbSeek(xFilial("QUD")+oModelQUB:GetValue("QUB_NUMAUD")+oModelQUH:GetValue("QUH_SEQ")+;
						             oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+;
						             oModelQUJ:GetValue("QUJ_CHKITE")+oModelQUJ2:GetValue("QSTITE")))
						RecLock("QUD",.F.)
						QUD->QUD_APLICA := IIf(oModelQUJ2:GetValue("CHKOK"), "1", "2")
						MsUnlock()
					Else
						RecLock("QUD",.T.)
						QUD->QUD_Filial := xFilial("QUD")
						QUD->QUD_NUMAUD := oModelQUB:GetValue("QUB_NUMAUD")
						QUD->QUD_SEQ    := oModelQUH:GetValue("QUH_SEQ")
						QUD->QUD_CHKLST := oModelQUJ:GetValue("QUJ_CHKLST")
						QUD->QUD_REVIS  := oModelQUJ:GetValue("QUJ_REVIS")
						QUD->QUD_CHKITE := oModelQUJ:GetValue("QUJ_CHKITE")
						QUD->QUD_QSTITE := oModelQUJ2:GetValue("QSTITE")  
						QUD->QUD_TIPO   := "1"
						QUD->QUD_FILMAT := oModelQUH:GetValue("QUH_FILMAT")
						QUD->QUD_CODAUD := oModelQUH:GetValue("QUH_CODAUD")
						QUD->QUD_APLICA := IIf(oModelQUJ2:GetValue("CHKOK"), "1", "2")
						MsUnlock()
					EndIf
				Next nZ
				For nZ := 1 To oModelQUE:Length()
					If oModelQUE:GetValue("QUE_PESO") == 0 
						oModelQUE:SetValue("QUE_PESO", 1)
					EndIf
					If QUD->(DbSeek(xFilial("QUD")+oModelQUB:GetValue("QUB_NUMAUD")+oModelQUH:GetValue("QUH_SEQ")+;
						             oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+;
						             oModelQUJ:GetValue("QUJ_CHKITE")+oModelQUJ2:GetValue("QSTITE")))
						RecLock("QUD",.F.)
						QUD->QUD_FILMAT := oModelQUH:GetValue("QUH_FILMAT")
						QUD->QUD_CODAUD := oModelQUH:GetValue("QUH_CODAUD")
						QUD->QUD_APLICA := IIf(oModelQUE:GetValue("QUE_CHKOK"), "1", "2")
						MsUnlock()
					Else
						oModelQUE:GoLine(nZ)
						RecLock("QUD",.T.)
						QUD->QUD_Filial := xFilial("QUD")
						QUD->QUD_NUMAUD := oModelQUH:GetValue("QUH_NUMAUD")
						QUD->QUD_SEQ    := oModelQUH:GetValue("QUH_SEQ")
						QUD->QUD_CHKLST := oModelQUJ:GetValue("QUJ_CHKLST")
						QUD->QUD_REVIS  := oModelQUJ:GetValue("QUJ_REVIS")
						QUD->QUD_CHKITE := oModelQUJ:GetValue("QUJ_CHKITE")
						QUD->QUD_QSTITE := oModelQUE:GetValue("QUE_QSTITE")
						QUD->QUD_TIPO   := "2"
						QUD->QUD_FILMAT := oModelQUH:GetValue("QUH_FILMAT")
						QUD->QUD_CODAUD := oModelQUH:GetValue("QUH_CODAUD")
						QUD->QUD_APLICA := IIf(oModelQUE:GetValue("QUE_CHKOK"), "1", "2")
						MsUnlock()
					EndIf
				Next nZ
			Next nY
		Next nX
	ElseIf nOperation == MODEL_OPERATION_DELETE
		
		QADELQUB(oModelQUB:GetValue("QUB_NUMAUD"))		
		
	EndIF
	
	lRet := FWFormCommit( oModel )
	
	// Envia e-mails aos envolvidos na Auditoria
	If !isBlind()
		If nOperation <> 5 .AND. MsgYesNo(STR0029) .And. lRet //"Deseja enviar email agora ? "
		    cMessage  := STR0030 //Enviando e-mail comunicando a programacao da Auditoria."
		    cTitle    := STR0031 //"Envio de e-mail"
			bSendMail := {||Q250SendAud(oModel, nOperation)}
			MsgRun(cMessage, cTitle, bSendMail)
	    EndIf
    EndIf
Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} QAD250Up()
Verifica o status da auditoria para atualização.
@author Luiz Henrique Bourscheid
@since 01/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QAD250Up()
	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local lSoLider := Empty(QUB->QUB_ENCREA) .And. SuperGetMv("MV_AUDSLID", .T., .F.)
	
	If QUB->QUB_STATUS == "4"
		Help("",1,STR0057)
		lRet := .F.
	EndIf
	
	If !QADCkAudit(QUB->QUB_NUMAUD,, lSolider)
		lRet := .F.
	EndIf
	
	If lRet
		FWExecView (STR0005, "QADA250", MODEL_OPERATION_UPDATE) 
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} QAD250Dl()
Verifica se a auditoria pode ser deletada.
@author Luiz Henrique Bourscheid
@since 01/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QAD250Dl()
	Local lRet     := .T.
	Local lSoLider := Empty(QUB->QUB_ENCREA) .And. SuperGetMv("MV_AUDSLID", .T., .F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a Auditoria possui Questoes respondidas			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	QUD->(dbSetOrder(1))
	QUD->(dbSeek(xFilial("QUD")+QUB->QUB_NUMAUD))
	While QUD->(!Eof()) .And. xFilial("QUD") == QUD->QUD_FILIAL .And.;
		QUD->QUD_NUMAUD == QUB->QUB_NUMAUD
		If !Empty(QUD->QUD_DTAVAL) 
			Help("",1,"100ADTRESP")
			lRet := .F.
			Exit
		EndIf
		QUD->(dbSkip())
	EndDo	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Verifica se existem nao-conformidades associadas			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	QUG->(dbSetOrder(1))
	QUG->(dbSeek(xFilial("QUG")+QUB->QUB_NUMAUD))
	If QUG->QUG_NUMAUD == QUB->QUB_NUMAUD
		Help("",1,"100ADTNAOC")
		lRet := .F.
	EndIf
	
	If !QADCkAudit(QUB->QUB_NUMAUD,, lSolider)
		lRet := .F.
	EndIf
	
	If lRet
		FWExecView (STR0006, "QADA250", MODEL_OPERATION_DELETE) 
	EndIf
	
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Q250NexQst()
Devolve a proxima sequencia da questao.
@author Luiz Henrique Bourscheid
@since 04/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function Q250NexQst()
	Local cRetQst
	Local oModel    := FWModelActive()
	Local oModelQUE := oModel:GetModel('QUEDETAIL')
	Local oModelQUB := oModel:GetModel('QUBMASTER')
	Local oModelQUJ := oModel:GetModel('QUJDETAIL')
	Local aSavArea  := GetArea()

	QUE->(dbSetOrder(1))
	If QUE->(dbSeek(xFilial("QUE")+oModelQUB:GetValue("QUB_NUMAUD")+oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE")))
		While QUE->(!Eof()) .And. QUE->QUE_FILIAL == xFilial("QUE") .And.;
			(QUE->QUE_NUMAUD+QUE->QUE_CHKLST+QUE->QUE_REVIS+QUE->QUE_CHKITE)==;
			(oModelQUB:GetValue("QUB_NUMAUD")+oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE"))
			QUE->(dbSkip())
		EndDo
		QUE->(dbSkip(-1))
		cRetQst := StrZero(Val(QUE->QUE_QSTITE)+1,Len(QUE->QUE_QSTITE))
	Else
		QU4->(dbSetOrder(1))
		If QU4->(dbSeek(xFilial("QU4")+oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE")))
			While QU4->(!Eof()) .And. QU4->QU4_FILIAL == xFilial("QU4") .And.;
				(QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE)==;
				(oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE"))
				QU4->(dbSkip())
			EndDo
			QU4->(dbSkip(-1))
			cRetQst := StrZero(Val(QU4->QU4_QSTITE)+1,Len(QU4->QU4_QSTITE))
		Else
			cRetQst := StrZero(1,Len(QU4->QU4_QSTITE))
		Endif
	EndIf     
	If Empty(oModelQUB:GetValue("QUB_NUMAUD")) .Or. Empty(oModelQUJ:GetValue("QUJ_CHKLST")) .Or.;
	   Empty(oModelQUJ:GetValue("QUJ_REVIS"))  .Or. Empty(oModelQUJ:GetValue("QUJ_CHKITE"))
		cRetQst := Space(Len(QUE->QUE_QSTITE))	
	EndIf

	RestArea(aSavArea)

Return(cRetQst)
//----------------------------------------------------------------------
/*/{Protheus.doc} LoadUpd()
Carrega as informações da grid temporária ao realizar uma atualização/exclusão.
@author Luiz Henrique Bourscheid
@since 05/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function LoadUpd()
	Local oModel      := FWModelActive()
	Local oModelQUB   := oModel:GetModel("QUBMASTER")
	Local oModelQUH   := oModel:GetModel("QUHDETAIL")
	Local oModelQUJ   := oModel:GetModel("QUJDETAIL")
	Local aDados      := {}
	Local oStruQUJ2   := oModel:GetModelStruct("QUJ2DETAIL")[3]:oFormModelStruct
	Local aCposVlr    := oStruQUJ2:GetFields()
	Local aFilCpos    := {}
	Local nContCpo    := 0
	Local nOperation  := oModel:GetOperation()

	If nOperation <> MODEL_OPERATION_INSERT
		QUD->(dbSetOrder(1))
		QUD->(DbGoTop())
		QUD->(DbSeek(xFilial("QUD")+oModelQUB:GetValue("QUB_NUMAUD")+oModelQUH:GetValue("QUH_SEQ")+;
		             oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE")))
		While QUD->(!Eof())
		   If oModelQUB:GetValue("QUB_NUMAUD") == QUD->QUD_NUMAUD .And. ;
		      oModelQUJ:GetValue("QUJ_CHKLST") == QUD->QUD_CHKLST .And. ;
		      oModelQUJ:GetValue("QUJ_REVIS")  == QUD->QUD_REVIS  .And. ;
		      oModelQUJ:GetValue("QUJ_CHKITE") == QUD->QUD_CHKITE .And. ;
		      QUD->QUD_TIPO == "1"
				aFilCpos := {}
				For nContCpo := 1 To Len(aCposVlr)
					If aCposVlr[nContCpo][3] == "CHKOK"
						AADD(aFilCpos, IIf(QUD->QUD_APLICA == "1", .T., .F.))
					ElseIf aCposVlr[nContCpo][3] == "FILIAL"
						AADD(aFilCpos, xFilial("QUD"))
					ElseIf aCposVlr[nContCpo][3] == "CHKLST"
						AADD(aFilCpos, QUD->QUD_CHKLST)
					ElseIf aCposVlr[nContCpo][3] == "REVIS"
						AADD(aFilCpos, QUD->QUD_REVIS)
					ElseIf aCposVlr[nContCpo][3] == "CHKITE"
						AADD(aFilCpos, QUD->QUD_CHKITE)
					ElseIf aCposVlr[nContCpo][3] == "QSTITE"
						AADD(aFilCpos, QUD->QUD_QSTITE)
					ElseIf aCposVlr[nContCpo][3] == "TXTQST"
						AADD(aFilCpos ,AllTrim(MsMM(Posicione("QU4", 1, xFilial("QU4")+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE, "QU4_TXTCHV"), TamSX3("QU4_TXTQS1")[1])))
					EndIf
				Next nContCpo
				AADD(aDados, {0, aFilCpos})
			EndIf
			QUD->(DbSkip())
		EndDo
	EndIF

Return aDados
//----------------------------------------------------------------------
/*/{Protheus.doc} Q250AudMail()
Monta email da Auditoria em Html.
@author Luiz Henrique Bourscheid
@since 05/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function Q250AudMail(cTipo,cMensag)

Local cText     := ""
Local aUsrMat   := QA_USUARIO()
Local cMatFil   := aUsrMat[2]
Local cMatCod   := aUsrMat[3]
Local cTitTop   := ""
Local cCodTop   := ""
Local nPosQUH   := 0
Local lSoLider  := GetMv("MV_AUDSLID", .T., .F.)
Local cTpMail   := QAA->QAA_TPMAIL
Local lPrimeiro := .T.
Local cMsg		  := ""

If cTpMail == "1"
	cTpMail:= "1" // HTML
Else
	cTpMail:= "2" // TEXTO
EndIf

If cTpMail == "1"
	cMsg:= '<HTML>'
	cMsg+= '  <TITLE>SIGAQAD</TITLE>'
	cMsg+= '<BODY>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
	cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
	cMsg+= '    <P align=center><FONT face="Courier New" color=#ffffff size=4>'
	cMsg+= '    <B>'+OemToAnsi(STR0015)+'</B></FONT></P></TD></TR>' // "MENSAGEM" 
	cMsg+= '  <TR><TD align=left width=606 height=32>'
	cMsg+= '    <P align=Center>'+cMensag+'</P></TD></TR>'
	cMsg+= '</TABLE><BR>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
	cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
	cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0016)+'</b></font></P></TD></TR>' // "AUDITORIA"
	cMsg+= '</TABLE>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD align=left width=77 height=32><b>'+RetTitle("QUB_NUMAUD")+'</b><br>'+QUB->QUB_NUMAUD+'</TD>' // Auditoria
	cMsg+= '    <TD align=left width=483 height=32><B>' +RetTitle("QUB_MOTAUD")+'</b><br>'+Posicione("SX5",1,xFilial("SX5")+"QE"+QUB->QUB_MOTAUD,"X5DESCRI()")+'</TD></TR>' // Motivo
	cMsg+= '</TABLE>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD align=left width=20% height=32><b>'+RetTitle("QUB_TIPAUD")+'</b><BR>'+QADCBox("QUB_TIPAUD", QUB->QUB_TIPAUD)+'</TD>' // Tipo
	cMsg+= '    <TD align=left width=20% height=32><b>'+RetTitle("QUB_REFAUD")+'</b><BR>'+dtoc(QUB->QUB_REFAUD)+'</TD>' // Referencia
	cMsg+= '    <TD align=left width=20% height=32><b>'+RetTitle("QUB_INIAUD")+'</b><BR>'+dtoc(QUB->QUB_INIAUD)+'</TD>' // Inicio
	cMsg+= '    <TD align=left width=20% height=32><b>'+OemToAnsi(STR0017)+'</b><BR>'+dtoc(QUB->QUB_ENCAUD)+'</TD>'     // "Enc. Previsto"
	cMsg+= '    <TD align=left width=20% height=32><b>'+OemToAnsi(STR0018)+'</b><BR>'+dtoc(QUB->QUB_ENCREA)+'</TD></TR>'// "Enc. Real"
	cMsg+= '</TABLE>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD align=left width=100% height=32><b>'+OemToAnsi(STR0019)+'</b><br>'+Posicione("QAA",1,QUB->QUB_FILMAT+QUB->QUB_AUDLID,"QAA_NOME")+'</TD></TR>' // "Auditor Lider"
	cMsg+= '</TABLE>'
	
	If !Empty(QUB->QUB_AUDRSP)
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		cMsg+= '  <TR><TD align=left width=100% height=32><b>'+OemToAnsi(STR0020)+'</b><br>'+QUB->QUB_AUDRSP+'</TD></TR>' // "Auditado Responsavel"
		cMsg+= '</TABLE>'
	EndIf
	
	If !Empty(QUB->QUB_CODFOR)
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		cMsg+= '  <TR><TD align=left width=86 height=32><b>'+RetTitle("QUB_CODFOR")+'</b><br>'+QUB->QUB_CODFOR+'</TD>' // Fornecedor
		cMsg+= '    <TD align=left width=543 height=32><b>'+OemToAnsi(STR0021)+'</b><br>'+Posicione("SA2",1,xFilial("SA2")+QUB->QUB_CODFOR,"A2_NOME")+'</TD></TR>' // "Razao Social"
		cMsg+= '</TABLE>'
	EndIf
	
	cMsg+= '&nbsp;'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descricao da Auditoria                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cText:= MsMM(QUB->QUB_DESCHV,TamSx3("QUB_DESCR1")[1])
	If !Empty(cText)
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 bgColor=#0099cc borderColorDark=#0099cc height=1>'
		cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0022))+'</b></font></P></TD></TR>' // DESCRICAO
		cMsg+= '</TABLE>'
		
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1><tr>'
		cMsg+= '  <TD align=left width=100% height=32>'+cText+'</TD></tr>'
		cMsg+= '</TABLE>'
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Areas Auditadas   				             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg+= '&nbsp;'
	cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border="1">'
	cMsg+= '  <tbody>'
	cMsg+= '    <tr>'
	cMsg+= '      <td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606" bgColor="#0099cc" borderColorDark="#0099cc" height="1">'
	cMsg+= '        <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0023))+'</b></font></p>'
	cMsg+= '      </td>'
	cMsg+= '    </tr>'
	cMsg+= '  </tbody>'
	cMsg+= '</table>'
	
	nPosQUH:= QUH->(RecNo())
	If QUH->(DbSeek(xFilial("QUH")+QUB->QUB_NUMAUD))
		While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+QUB->QUB_NUMAUD
			If 	lSoLider .And.;
				QUH->QUH_FILMAT + QUH->QUH_CODAUD <> cMatFil + cMatCod .And.;
				QUB->QUB_FILMAT + QUB->QUB_AUDLID <> cMatFil + cMatCod
				QUH->(DbSkip())
				Loop
			Endif
		
			If lPrimeiro
				cMsg+= '<br>'
				cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border="1">'
				cMsg+= '  <tbody>'
			Endif
			
			cMsg+= '    <tr>'
			cMsg+= '      <td align="left" width="286" height="32"><b>'+OemToAnsi(STR0025)+'</b><br>'+QUH->QUH_DESTIN+'</td> ' // Area Auditada
			cMsg+= '      <td align="left" width="343" height="32"><b>'+OemToAnsi(STR0026)+'</b><br>'+QA_NUSR(QUH->QUH_FILMAT,QUH->QUH_CODAUD)+'</td>' // Auditor 
			cMsg+= '    </tr>'
			
			lPrimeiro := .F.
	    	QUH->(DbSkip())
		EndDo
		If ! lPrimeiro
			cMsg+= '  </tbody>'
			cMsg+= '</table>'
		Endif
	EndIf
	QUH->(DbGoto(nPosQUH))
	
	cMsg+= '&nbsp;'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Equipe de Apoio     				             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QUC->(DbSeek(xFilial("QUC")+QUB->QUB_NUMAUD))
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
		cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
		cMsg+= '    <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0024))+'</b></font></TD></TR>' // "Equipe de Apoio"
		cMsg+= '</TABLE>'
		
		cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
		
		While QUC->(!Eof()) .And. QUC->QUC_FILIAL+QUC->QUC_NUMAUD == xFilial("QUC")+QUB->QUB_NUMAUD
			cMsg+= '  <tr><TD align=left width=100% height=32>'+QA_NUSR(QUC->QUC_FILMAT,QUC->QUC_CODAUD)+'</TD></tr>'
			QUC->(DbSkip())
		EndDo
		cMsg+= '</TABLE>'
	EndIf
	
	If cTipo == 2 // Encerramento de Auditoria
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao-Conformidades                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosQUH:= QUH->(RecNo())
		If QUH->(DbSeek(xFilial("QUH")+QUB->QUB_NUMAUD))
			While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+QUB->QUB_NUMAUD
				If 	lSoLider .And.;
					QUH->QUH_FILMAT + QUH->QUH_CODAUD <> cMatFil + cMatCod .And.;
					QUB->QUB_FILMAT + QUB->QUB_AUDLID <> cMatFil + cMatCod
					QUH->(DbSkip())
					Loop
				Endif
				
				QUG->(dbSetOrder(1))
				If QUG->(dbSeek(xFilial("QUG")+QUH->QUH_NUMAUD+QUH->QUH_SEQ))
					cMsg+= '&nbsp;'
					cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
					cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
					cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
					cMsg+= '    <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0027)+'</b></font></TD></TR>' // "NAO-CONFORMIDADES"
					cMsg+= '</TABLE>'
					
					While QUG->(!Eof()) .And. QUG->QUG_FILIAL+QUG->QUG_NUMAUD+QUG->QUG_SEQ == xFilial("QUG")+QUH->QUH_NUMAUD+QUH->QUH_SEQ
						
						cTitTop:= RetTitle("QU3_CHKITE")
						cCodTop:= QUG->QUG_CHKITE
						IF QU3->(DBSeeK(xFILIAL("QU3")+QUG->QUG_CHKLST+QUG->QUG_REVIS+cCodTop))
							cDesTop:= QU3->QU3_DESCRI
							If !Empty(QU3->QU3_NORMA)
								cTitTop+= ' / '+RetTitle("QU3_NORMA")
								cCodTop+= ' / '+QU3->QU3_NORMA
							EndIf
						EndIf
						
						cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
						cMsg+= '  <tr>'
						cMsg+= '    <TD align=left width=100% height=32><b>'+cTitTop+'</b><br>'+cCodTop+' - '+cDesTop+'</TD>' // Topico/Norma
						cMsg+= '  </tr>'
						cMsg+= '</TABLE>'
						
						cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
						cMsg+= '  <tr>'
						cMsg+= '    <TD align=left width=100% height=32><b>'+OemToAnsi(STR0025)+'</b><br>'+QUH->QUH_DESTIN+'</TD>'
						cMsg+= '  </tr>'
						cMsg+= '</TABLE>'
						
						cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
						cMsg+= '  <tr>'
						cMsg+= '    <TD align=left width=100% height=32><b>'+OemToAnsi(STR0022)+'</b><br>'+MsMM(QUG->QUG_DESCHV,TamSX3('QUG_DESC1')[1])+'</TD>'
						cMsg+= '  </tr>'
						cMsg+= '</TABLE>'
						
						QUG->(dbSkip())
					EndDo
				EndIf
				
				QUH->(DbSkip())
			EndDo
		EndIf
		QUH->(DbGoto(nPosQUH))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Observacao                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cText := MsMM(QUB->QUB_SUGCHV,TamSX3('QUB_SUGOBS')[1])
		If !Empty(cText)
			cMsg+= '&nbsp;'
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 bgColor=#0099cc borderColorDark=#0099cc height=1>'
			cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(RetTitle("QUB_SUGOBS"))+'</b></font></P></TD></TR>'
			cMsg+= '</TABLE>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1><tr>'
			cMsg+= '  <TD align=left width=100% height=32>'+cText+'</TD></tr>'
			cMsg+= '</TABLE>'
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conclusao da Auditoria                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cText:= M->QUB_CONCLU
		If !Empty(cText)
			cMsg+= '&nbsp;'
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 bgColor=#0099cc borderColorDark=#0099cc height=1>'
			cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(RetTitle("QUB_CONCLU"))+'</b></font></P></TD></TR>' // CONCLUSAO
			cMsg+= '</TABLE>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1><tr>'
			cMsg+= '  <TD align=left width=100% height=32>'+cText+'</TD></tr>'
			cMsg+= '</TABLE>'
		EndIf
	EndIf
	
	cMsg+= '<p><FONT size=2><EM>'+OemToAnsi(STR0028)+'</EM></FONT></p>' // "Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias"
	cMsg+= '</BODY>'
	cMsg+= '</HTML>'

ElseIf cTpMail == "2"

	cMsg:= cMensag+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMsg+= OemToAnsi(STR0016)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "AUDITORIA"
	cMsg+= RetTitle("QUB_NUMAUD")+": "+QUB->QUB_NUMAUD+CHR(13)+CHR(10) // Auditoria
	cMsg+= RetTitle("QUB_MOTAUD")+": "+Posicione("SX5",1,xFilial("SX5")+"QE"+QUB->QUB_MOTAUD,"X5DESCRI()")+CHR(13)+CHR(10) // Motivo
	cMsg+= RetTitle("QUB_TIPAUD")+": "+QADCBox("QUB_TIPAUD", QUB->QUB_TIPAUD)+CHR(13)+CHR(10) // Tipo
	cMsg+= RetTitle("QUB_REFAUD")+": "+dtoc(QUB->QUB_REFAUD)+CHR(13)+CHR(10) // Referencia
	cMsg+= RetTitle("QUB_INIAUD")+": "+dtoc(QUB->QUB_INIAUD)+CHR(13)+CHR(10) // Inicio
	cMsg+= OemToAnsi(STR0017)+":  "+dtoc(QUB->QUB_ENCAUD)+CHR(13)+CHR(10) // "Enc. Previsto"
	cMsg+= OemToAnsi(STR0018)+":  "+dtoc(QUB->QUB_ENCREA)+CHR(13)+CHR(10)// "Enc. Real"
	cMsg+= OemToAnsi(STR0019)+":  "+Posicione("QAA",1,QUB->QUB_FILMAT+QUB->QUB_AUDLID,"QAA_NOME")+CHR(13)+CHR(10) // "Auditor Lider"

	If !Empty(QUB->QUB_AUDRSP)
		cMsg+= OemToAnsi(STR0020)+": "+QUB->QUB_AUDRSP+CHR(13)+CHR(10) // "Auditado Responsavel"
	EndIf
	
	If !Empty(QUB->QUB_CODFOR)
		cMsg+= RetTitle("QUB_CODFOR")+": "+QUB->QUB_CODFOR+CHR(13)+CHR(10) // Fornecedor
		cMsg+= OemToAnsi(STR0021)+": "+Posicione("SA2",1,xFilial("SA2")+QUB->QUB_CODFOR,"A2_NOME")+CHR(13)+CHR(10) // "Razao Social"
	EndIf

	cMsg+= CHR(13)+CHR(10)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descricao da Auditoria                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cText:= MsMM(QUB->QUB_DESCHV,TamSx3("QUB_DESCR1")[1])
	If !Empty(cText)
		cMsg+= Upper(OemToAnsi(STR0022))+CHR(13)+CHR(10) // DESCRICAO
		cMsg+= cText+CHR(13)+CHR(10)
		cMsg+= CHR(13)+CHR(10)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Areas Auditadas   				             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg+= Upper(OemToAnsi(STR0023))+CHR(13)+CHR(10)+CHR(13)+CHR(10)

	nPosQUH:= QUH->(RecNo())
	If QUH->(DbSeek(xFilial("QUH")+QUB->QUB_NUMAUD))
		While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+QUB->QUB_NUMAUD
			If 	lSoLider .And.;
				QUH->QUH_FILMAT + QUH->QUH_CODAUD <> cMatFil + cMatCod .And.;
				QUB->QUB_FILMAT + QUB->QUB_AUDLID <> cMatFil + cMatCod
				QUH->(DbSkip())
				Loop
			Endif

			cMsg+= OemToAnsi(STR0025)+": "+QUH->QUH_DESTIN+CHR(13)+CHR(10) // Area Auditada
			cMsg+= OemToAnsi(STR0026)+": "+QA_NUSR(QUH->QUH_FILMAT,QUH->QUH_CODAUD)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Auditor

	    	QUH->(DbSkip())
		EndDo
	EndIf
	QUH->(DbGoto(nPosQUH))
	
	cMsg+= CHR(13)+CHR(10)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Equipe de Apoio        	                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QUC->(DbSeek(xFilial("QUC")+QUB->QUB_NUMAUD))
		cMsg+= Upper(OemToAnsi(STR0024))+CHR(13)+CHR(10) // "Equipe de Apoio"
		While QUC->(!Eof()) .And. QUC->QUC_FILIAL+QUC->QUC_NUMAUD == xFilial("QUC")+QUB->QUB_NUMAUD
			cMsg+= QA_NUSR(QUC->QUC_FILMAT,QUC->QUC_CODAUD)+CHR(13)+CHR(10)
			QUC->(DbSkip())
		EndDo
		cMsg+= CHR(13)+CHR(10)
	EndIf
	
	If cTipo == 2 // Encerramento de Auditoria
	
		nPosQUH:= QUH->(RecNo())
		If QUH->(DbSeek(xFilial("QUH")+QUB->QUB_NUMAUD))
			While QUH->(!Eof()) .And. QUH->QUH_FILIAL+QUH->QUH_NUMAUD == xFilial("QUH")+QUB->QUB_NUMAUD
				If 	lSoLider .And.;
					QUH->QUH_FILMAT + QUH->QUH_CODAUD <> cMatFil + cMatCod .And.;
					QUB->QUB_FILMAT + QUB->QUB_AUDLID <> cMatFil + cMatCod
					QUH->(DbSkip())
					Loop
				Endif
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao-Conformidades                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QUG->(dbSetOrder(1))
		If QUG->(dbSeek(xFilial("QUG")+QUH->QUH_NUMAUD+QUH->QUH_SEQ))
			cMsg+= OemToAnsi(STR0027)+CHR(13)+CHR(10) // "NAO-CONFORMIDADES"
			While QUG->(!Eof()) .And. QUG->QUG_FILIAL+QUG->QUG_NUMAUD+QUG->QUG_SEQ == xFilial("QUG")+QUH->QUH_NUMAUD+QUH->QUH_SEQ	
						
						cTitTop:= RetTitle("QU3_CHKITE")
						cCodTop:= QUG->QUG_CHKITE
						IF QU3->(DBSeeK(xFILIAL("QU3")+QUG->QUG_CHKLST+QUG->QUG_REVIS+cCodTop))
							cDesTop:= QU3->QU3_DESCRI
							If !Empty(QU3->QU3_NORMA)
								cTitTop+= ' / '+RetTitle("QU3_NORMA")
								cCodTop+= ' / '+QU3->QU3_NORMA
							EndIf
						Endif
						
						cMsg+= cTitTop+" - "+cCodTop+" - "+cDesTop+CHR(13)+CHR(10) // Topico/Norma
				cMsg+= OemToAnsi(STR0022)+": "+MsMM(QUG->QUG_DESCHV,TamSX3('QUG_DESC1')[1])+CHR(13)+CHR(10)
				cMsg+= CHR(13)+CHR(10)

				QUG->(dbSkip())
			EndDo
		EndIf    
				QUH->(DbSkip())
			EndDo
		EndIf
		QUH->(DbGoto(nPosQUH))
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Observacao                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cText := MsMM(QUB->QUB_SUGCHV,TamSX3('QUB_SUGOBS')[1])
		If !Empty(cText)
			cMsg+= Upper(RetTitle("QUB_SUGOBS"))+CHR(13)+CHR(10)
			cMsg+= cText+CHR(13)+CHR(10)+CHR(13)+CHR(10)
        EndIf
	    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conclusao da Auditoria                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cText:= M->QUB_CONCLU 
		If !Empty(cText)
			cMsg+= Upper(RetTitle("QUB_CONCLU"))+CHR(13)+CHR(10) // CONCLUSAO		
			cMsg+= cText+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		EndIf
	EndIf
	cMsg+= OemToAnsi(STR0028) // "Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias"
EndIf

IF cTipo == 1
	// ponto de entrada - permite a alteracao do conteudo cMsg QDO nao e Encerramento
	If ExistBlock( "Q100MAIL" )
		cMsg := ExecBlock( "Q100MAIL", .f., .f.,{cMsg} )
	Endif
Endif	

Return cMsg
//----------------------------------------------------------------------
/*/{Protheus.doc} Q250SendAud()
Envia e-mail referente a Auditoria para areas envolvidas.
@author Luiz Henrique Bourscheid
@since 05/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function Q250SendAud(oModel, nOpc)

Local nX         := 0
Local aUserMail  := {}
Local aUserMail2 := {}
Local cSubject   := ""
Local cInsFil    := ""
Local cMail      := AllTrim(Posicione("QAA", 1, M->QUB_FILMAT+M->QUB_AUDLID,"QAA_EMAIL"))	// E-Mail Auditor Lider
Local cAudMail   := ""
Local oModelQUB  := oModel:GetModel("QUBMASTER")
Local oModelQUH  := oModel:GetModel("QUHDETAIL")
Local oModelQUC  := oModel:GetModel("QUCDETAIL")
Local oModelQUI  := oModel:GetModel("QUIDETAIL")

cSubject:= Iif(nOpc <> 5, OemToAnsi(STR0032), OemToAnsi(STR0033)) + " - " + QUB->QUB_NUMAUD //"Realizacao de Auditoria"###"Auditoria Excluida"

If QUB->QUB_INIAUD # M->QUB_INIAUD .Or. QUB->QUB_ENCAUD # M->QUB_ENCAUD
	If nOpc == 4
		cSubject := OemToAnsi(STR0034) //"Alteracao na Data da Auditoria"
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta e-mail da Realizacao de Auditoria em Html. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cInsFil	 :=	 ""	 
For nX := 1 To oModelQUH:Length()  
		oModelQUH:GoLine(nX)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³e-mail da Area Auditada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(oModelQUH:GetValue("QUH_EMAIL"))
			Aadd(aUSerMail,{oModelQUH:GetValue("QUH_EMAIL"), cSubject, Q250AudMail(1,cSubject),cInsFil})
		Endif             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³e-mail do Auditor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(oModelQUH:GetValue("QUH_CODAUD"))
			QAA->(dbSetOrder(1))
			If QAA->(DBSeek(oModelQUH:GetValue("QUH_FILMAT")+oModelQUH:GetValue("QUH_CODAUD")))
				If !EMPTY(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
					cAudMail := QAA->QAA_EMAIL
					Aadd(aUSerMail,{cAudMail, cSubject, Q250AudMail(1,cSubject), cInsFil})
				EndIf
			EndIf
		EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³e-mail da Equipe de Apoio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To oModelQUC:Length()
	oModelQUC:GoLine(nX)
	If !Empty(oModelQUC:GetValue("QUC_EMAIL"))
		Aadd(aUSerMail,{oModelQUC:GetValue("QUC_EMAIL"), cSubject, Q250AudMail(1, cSubject),cInsFil})
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³e-mail dos  emails Associados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To oModelQUI:Length()
	oModelQUI:GoLine(nX)
	If !Empty(oModelQUI:GetValue("QUI_EMAIL"))	
		Aadd(aUSerMail,{oModel:GetValue("QUI_EMAIL"), cSubject, Q250AudMail(1, cSubject),cInsFil})
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³e-mail do Auditor Lider ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Ascan(aUserMail, { |x| Trim(Upper(x[1])) == Upper(Trim(cMail)) }) = 0	// Verifica se o auditor lider
	Aadd(aUSerMail,{cMail,cSubject, Q250AudMail(1,cSubject), cInsFil})	// ja teve o e-mail incluido
Endif

//verifica se há e-mails duplicados
For nX := 1 To Len(aUserMail)
	if Ascan(aUserMail2,{|X| X[1] == aUserMail[nX,1]}) == 0 
		aAdd (aUserMail2,aUserMail[nX])
	EndiF
Next nX													
         
//realiza a Conexao com o servidor
QAudEnvMail(aUserMail2,,,,.T.,"2")

Return NIL
//----------------------------------------------------------------------
/*/{Protheus.doc} PosValidQUB()
Envia e-mail referente a Auditoria para areas envolvidas.
@author Luiz Henrique Bourscheid
@since 05/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function PosValidQUB(oModel)
	Local cMessage
	Local cTitle
	Local bSendMail
	Local lRet := .T.
	
	If !isBlind()
		If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. MsgYesNo(STR0029) //"Deseja enviar email agora ? "
		   cMessage  := STR0035 //"Envio de E-mail comunicando a Exclusão da Auditoria"
		   cTitle    := STR0031 //"Envio de e-mail"
		   bSendMail := {||Q250SendAud(oModel, 5)}
		   MsgRun(cMessage ,cTitle, bSendMail)
		EndIf
	EndIf

Return lRet


//----------------------------------------------------------------------
/*/{Protheus.doc} VldChkLst()
Verifica se existe CheckList antes de incluir perguntas adicionais.
@author Luiz Henrique Bourscheid
@since 14/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function VldChkLst()
	Local oModel    := FWModelActive()
	Local oModelQUJ := oModel:GetModel("QUJDETAIL")
	
	If Empty(oModelQUJ:GetValue("QUJ_CHKLST"))
		Help("",1,STR0058) 
	EndIf

Return


//----------------------------------------------------------------------
/*/{Protheus.doc} QA250Cancel(oModel)
Deleta Reuniao da Auditoria.
@author Geovani.Figueira
@since 14/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
STATIC FUNCTION QA250Cancel(oModel)

	IF oModel:GetOperation() == MODEL_OPERATION_INSERT
		QADELQUB(oModel:GetValue("QUBMASTER","QUB_NUMAUD"))
	ENDIF
	
RETURN .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} QADELQUB(cNumAud)
Deleta a Reuniao da Auditoria.
@author Geovani.Figueira
@since 14/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
FUNCTION QADELQUB(cNumAud)
	LOCAL cQPathQAD
	LOCAL aQPath
	LOCAL cQPathTrm
	
	QUK->(dbSetOrder(1))
		If QUK->(DbSeek(xFilial("QUK")+cNumAud))
			cQPathQAD := Alltrim(GetMv("MV_QADPDOC"))
			aQPath    := QDOPATH()
			cQPathTrm := aQPath[3]
			
			IF !Right( cQPathQAD,1 ) == "\"
				cQPathQAD := cQPathQAD + "\"
			ENDIF
			IF !Right( cQPathTrm,1 ) == "\"
				cQPathTrm := cQPathTrm + "\"
			ENDIF
			
			While QUK->(!Eof()) .And. QUK->QUK_FILIAL == xFilial("QUK") .And. QUK->QUK_NUMAUD == cNumAud
				
				IF FILE(cQPathQAD+Alltrim(QUK->QUK_ANEXO))
					FERASE(cQPathQAD +Alltrim(QUK->QUK_ANEXO))
				ENDIF
		
				IF FILE(cQPathTrm+Alltrim(QUK->QUK_ANEXO))
					FERASE(cQPathTrm +Alltrim(QUK->QUK_ANEXO))
				ENDIF						
				
				MSMM(QUK->QUK_CODOBS ,,,,2)
				RecLock("QUK",.F.)
				QUK->(dbDelete())
				MsUnlock()
				
				QUK->(DbSkip())
			EndDo
		EndIf
		
RETURN .T.


//----------------------------------------------------------------------
/*/{Protheus.doc} LoadREU()
Carrega o Campo LREUNIAO no bLoad da field.
@author Geovani.Figueira
@since 14/09/2017
@version 1.0
@return aLoad
/*/
//----------------------------------------------------------------------
FUNCTION LoadREU()
	LOCAL aLoad := {}
	
	aAdd(aLoad, {.F.}) //dados
	aAdd(aLoad, 1) //recno
	
RETURN aLoad


//----------------------------------------------------------------------
/*/{Protheus.doc} Q250ALoad()
Retorna array com o codigo da auditoria para utilizar no bLoad da Reuniao QADA250A.
@author Geovani.Figueira
@since 11/09/2017
@version 1.0
@return aLoad
/*/
//----------------------------------------------------------------------
FUNCTION Q250ALoad()
	LOCAL aLoad := {}
	
	aAdd(aLoad, {cCodAudit}) //dados
	aAdd(aLoad, 1) //recno
		 	
RETURN aLoad


//----------------------------------------------------------------------
/*/{Protheus.doc} Q250AInit()
Retorna o codigo da auditoria para utilizar no bInit da Reuniao QADA250A.
@author Geovani.Figueira
@since 11/09/2017
@version 1.0
@return cCodAudit
/*/
//----------------------------------------------------------------------
FUNCTION Q250AInit()
	
RETURN cCodAudit
//----------------------------------------------------------------------
/*/{Protheus.doc} Pre250QUH()
Pré Validacao da linha da tabela QUH
@author Luiz Henrique Bourscheid
@since 14/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function Pre250QUH(oModel, nLine, cAction)
	Local oModel     := FWModelActive()
	Local oModelQUH  := oModel:GetModel("QUHDETAIL")
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local nOperation := oModel:GetOperation()
	Local lQEXIAUD   := SuperGetMV("MV_QEXIAUD", .T., .F.)
	Local lDelQUH    := .T.
	Local lRet       := .T.
	
	If nOperation == MODEL_OPERATION_UPDATE 
		If lQEXIAUD
			QUD->(dbSetOrder(1))
			If QUD->(DbSeek(xFilial("QUD")+oModelQUB:GetValue("QUB_NUMAUD")+oModelQUH:GetValue("QUH_SEQ")))
				While QUD->(!Eof()) .And. ;
				      QUD->QUD_FILIAL == xFilial("QUD") .And. ;
				      QUD->QUD_NUMAUD == oModelQUB:GetValue("QUB_NUMAUD") .And. ;
				      QUD->QUD_SEQ    == oModelQUH:GetValue("QUH_SEQ")
					If QUD->QUD_NOTA > 0
						lDelQUH := .F.
						Exit
					Endif
					QUD->(DbSkip())
				EndDo
			EndIf
		Else
			lDelQUH := .F.
		EndIf

		If !lDelQUH .And. cAction == "DELETE"
			Help("",1,"QADNAODEL")
			lRet := .F.
		EndIf
	EndIF

Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} Pre250QUJ()
Pré Validacao da linha da tabela QUJ
@author Luiz Henrique Bourscheid
@since 14/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function Pre250QUJ(oModel, nLine, cAction)
	Local oModel     := FWModelActive()
	Local oModelQUH  := oModel:GetModel("QUHDETAIL")
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local oModelQUJ  := oModel:GetModel("QUJDETAIL")
	Local nOperation := oModel:GetOperation()
	Local lQEXIAUD   := SuperGetMV("MV_QEXIAUD", .T., .F.)
	Local lDelQUJ    := .T.
	Local lRet       := .T.
	
	If nOperation == MODEL_OPERATION_UPDATE 
		If lQEXIAUD
			QUD->(dbSetOrder(1))
			If QUD->(DbSeek(xFilial("QUD")+oModelQUB:GetValue("QUB_NUMAUD")+oModelQUH:GetValue("QUH_SEQ")+;
			                oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE")))
				While QUD->(!Eof()) .And. ;
				      QUD->QUD_FILIAL == xFilial("QUD") .And. ;
				      QUD->QUD_NUMAUD == oModelQUB:GetValue("QUB_NUMAUD") .And. ;
				      QUD->QUD_SEQ    == oModelQUH:GetValue("QUH_SEQ")    .And. ;
				      QUD->QUD_CHKLST == oModelQUJ:GetValue("QUJ_CHKLST") .And. ;
		             QUD->QUD_REVIS  == oModelQUJ:GetValue("QUJ_REVIS")  .And. ;
		             QUD->QUD_CHKITE == oModelQUJ:GetValue("QUJ_CHKITE")
					If QUD->QUD_NOTA > 0
						lDelQUJ := .F.
						Exit
					Endif
					QUD->(DbSkip())
				EndDo
			EndIf
		Else
			lDelQUJ := .F.
		EndIf

		If !lDelQUJ .And. cAction == "DELETE"
			Help("",1,"QADNAODEL")
			lRet := .F.
		EndIf
	EndIF
	
Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} PosVldQUE()
POS Validacao da linha da tabela QUE
@author Luiz Henrique Bourscheid
@since 15/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function PosVldQUE()
	Local oModel     := FWModelActive()
	Local oModelQUE  := oModel:GetModel("QUEDETAIL")
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local lRet       := .T.
	
	If ((oModelQUE:GetValue("QUE_FAIXFI") - oModelQUE:GetValue("QUE_FAIXIN")) <= 0) .And.;
	 	oModelQUE:GetValue("QUE_CHKOK") .And. oModelQUE:IsUpdated() 
		Help(" ",1,"QU4NOTA")		
		lRet := .F.
	Endif	

Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} TrgQUJ()
POS Validacao da linha da tabela QUE
@author Luiz Henrique Bourscheid
@since 15/09/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function TrgQUJ()
	Local oModel     := FWModelActive()
	Local oModelQUJ  := oModel:GetModel("QUJDETAIL")
	Local oModelQUJ2 := oModel:GetModel("QUJ2DETAIL")
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local oModelQUH  := oModel:GetModel("QUHDETAIL")
	Local oModelQUE  := oModel:GetModel("QUEDETAIL")
	Local oView	   := FwViewActive()
	Local nLinha	   := 0
	Local lTopAut    := IIf(SuperGetMV("MV_QADTOPA",.T.,"2")=="1", .T., .F.)
	Local aQUJ       := {}
	Local nX
	Local lFaz := .T.
	Local lRet := .T.
	Private lFirst
	Private cCHKLST

	If lTopAut
		If Empty(cCHKLST)
			lFirst  := .T.
			cCHKLST := ""
		ElseIf !lFirst .And. cCHKLST != oModelQUJ:GetValue("QUJ_CHKLST")
			lFirst := .T.
		EndIf
	EndIf
	
	If !isBlind()
		If lTopAut .And. lFirst
			If MSGYesNO(OemToAnsi(STR0036))
				QU3->(DbSetOrder(1))
				QU3->(DbGoTop())
				QU3->(DbSeek(xFilial("QU3")+oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")))
				While QU3->(!Eof()) .And. ;
				      QU3->QU3_FILIAL == xFilial("QU3") .And. ;
				      QU3->QU3_CHKLST == oModelQUJ:GetValue("QUJ_CHKLST") .And. ;
				      QU3->QU3_REVIS  == oModelQUJ:GetValue("QUJ_REVIS")
				    For nX := 1 To oModelQUJ:Length()
				    	If oModelQUJ:GetValue("QUJ_CHKLST") == QU3->QU3_CHKLST .And. ;
				    	   oModelQUJ:GetValue("QUJ_REVIS")  == QU3->QU3_REVIS .And. ;
				    	   oModelQUJ:GetValue("QUJ_CHKITE") == QU3->QU3_CHKITE
				    		lFaz := .F.
				    	Else
				    		lFaz := .T.
				    	EndIf
				    Next nX
				    If lFaz
					    nLinha := oModelQUJ:AddLine()
					    oModelQUJ:GoLine(nLinha)
					    oModelQUJ:LoadValue("QUJ_CHKLST", QU3->QU3_CHKLST) 
					    oModelQUJ:LoadValue("QUJ_REVIS",  QU3->QU3_REVIS)
					    oModelQUJ:LoadValue("QUJ_CHKITE", QU3->QU3_CHKITE)
					    oModelQUJ:LoadValue("QUJ_DESCRI", AllTrim(Posicione("QU3", 1, xFilial("QU3")+oModelQUJ:GetValue("QUJ_CHKLST")+oModelQUJ:GetValue("QUJ_REVIS")+oModelQUJ:GetValue("QUJ_CHKITE"),"QU3_DESCRI")))
	                  LoadGrid()
	                  cCHKLST := QU3->QU3_CHKLST
					    lFirst  := .F.
					EndIf
					QU3->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	
	If !isBlind()
		oView:Refresh("VIEW_QUJ")
	EndIf
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Q250ChkLst()
Verifica a existencia do Check List e se o mesmo esta efetivado.
@author Luiz Henrique Bourscheid
@since 14/03/2018
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function Q250ChkLst(cKey,lEfetiva,lVerEfeChk,lVerObsChk,lBloKia)
Local lRetorno     := .T.              
Local aARea	       := GetArea()              
Default lEfetiva   := .T.
Default lVerEfeChk := .T.
Default lVerObsChk := .F.
Default lBloKia    := .F.	

DbSelectArea("QU2")
QU2->(dbSetOrder(1))
QU2->(dbSeek(xFilial("QU2")+cKey))
If QU2->(!Eof())
	If lVerEfeChk             
		If lEfetiva
			If (QU2->QU2_EFETIV == "3")
				Help("",1,"QADCHKNEFE")
				lRetorno := .F.
			EndIf
		Else
			If (QU2->QU2_EFETIV == "1") .Or. (QU2->QU2_EFETIV == "2")
				Help("",1,"QADCHKJEFE")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	If lVerObsChk
		If QU2->QU2_EFETIV == "2"
			Help("",1,"020CHKOBS") 
			lRetorno := .F.
		EndIf		
	Endif
Else
	Help("",1,"QADNCHKLST")
	lRetorno := .F.
EndIf

RestArea(aARea)
Return(lRetorno)