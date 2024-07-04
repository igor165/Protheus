#INCLUDE "PROTHEUS.CH"
#INCLUDE "QADA251.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
 
 
 Static lDel 	:= .F.
//-----------------------------------------------------------------------
/*/{Protheus.doc} QADA251
Resultado de auditoria
@author Leonardo Bratti
@since 24/08/2017
@version 1.0
@return NIL
/*/
//-----------------------------------------------------------------------
Function QADA251()
	Local   aArea   := GetArea()
	Local   oBrowse		
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QUB")
	oBrowse:AddLegend('QUB->QUB_STATUS == "1"','ENABLE'    ,STR0004)
 	oBrowse:AddLegend('QUB->QUB_STATUS == "2"','BR_AMARELO',STR0005)
 	oBrowse:AddLegend('QUB->QUB_STATUS == "3"','BR_PRETO'  ,STR0006)
 	oBrowse:AddLegend('QUB->QUB_STATUS == "4"','DISABLE'   ,STR0041)
	oBrowse:SetDescription("Resultados")
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Bratti
@since 24/08/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	
	Private aRotina := {}

	ADD OPTION aRotina TITLE  STR0001  ACTION 'Q251Resul' 		OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE  STR0002  ACTION 'VIEWDEF.QADA251' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE  STR0003  ACTION 'Q251Excl' 		OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Excluir
	ADD OPTION aRotina TITLE  "Conhecimento"  ACTION 'MsDocument' 		OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Conhecimento
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Bratti
@since 24/08/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruQUB  := FWFormStruct(1,"QUB",)
	Local oStruQUH  := FWFormStruct(1,"QUH",)
	Local oStruQUJ  := FWFormStruct(1,'QUJ')
	Local oStruQUD  := FWFormStruct(1,'QUD')
	Local oStruQUG  := FWFormStruct(1,'QUG')
	Local nX
	
	Local oModel := Nil	
	
	oModel := MPFormModel():New( 'QADA251',, ,{||A251Grv()})
	
   oStruQUD:AddField( ;                         // Ord. Tipo Desc.
                   STR0007, ;                   // [01] C Titulo do campo
                   STR0008, ;                   // [02] C ToolTip do campo
                   "QUD_TXTQ", ;                // [03] C identificador (ID) do Field
                   'M' , ;                      // [04] C Tipo do campo
                   TAMSX3("QU4_TXTQS1")[1], ;   // [05] N Tamanho do campo
                   0 , ;                        // [06] N Decimal do campo
                   NIL, ;                       // [07] B Code-block de validação do campo
                   {|| .T.}, ;                  // [08] B Code-block de validação When do campo
                   , ;                          // [09] A Lista de valores permitido do campo
                   .F., ;                       // [10] L Indica se o campo tem preenchimento obrigatório
                   {||LoadTxtQ()}, ;            // [11] B Code-block de inicializacao do campo
                   .F., ;                       // [12] L Indica se trata de um campo chave
                   .T., ;                       // [13] L Indica se o campo pode receber valor em uma operação de update.
                   .T. )                        // [14] L Indica se o campo é virtual
                   
   oStruQUD:AddField( ;                         // Ord. Tipo Desc.
                   STR0009, ;                   // [01] C Titulo do campo
                   STR0010, ;                   // [02] C ToolTip do campo
                   "QUD_TXTOBS", ;              // [03] C identificador (ID) do Field
                   'M' , ;                      // [04] C Tipo do campo
                   TAMSX3("QU4_OBSER1")[1], ;   // [05] N Tamanho do campo
                   0 , ;                        // [06] N Decimal do campo
                   NIL, ;                       // [07] B Code-block de validação do campo
                   {|| .T.}, ;                  // [08] B Code-block de validação When do campo
                   , ;                          // [09] A Lista de valores permitido do campo
                   .F., ;                       // [10] L Indica se o campo tem preenchimento obrigatório
                   {||LoadObsQ()}, ;            // [11] B Code-block de inicializacao do campo
                   .F., ;                       // [12] L Indica se trata de um campo chave
                   .T., ;                       // [13] L Indica se o campo pode receber valor em uma operação de update.
                   .T. )                        // [14] L Indica se o campo é virtual
                   
   oStruQUD:AddField( ;                         // Ord. Tipo Desc.
                   STR0011, ;                   // [01] C Titulo do campo
                   STR0012, ;                   // [02] C ToolTip do campo
                   "QUD_TXTREQ", ;              // [03] C identificador (ID) do Field
                   'M' , ;                      // [04] C Tipo do campo
                   TAMSX3("QU4_REQQS1")[1], ;   // [05] N Tamanho do campo
                   0 , ;                        // [06] N Decimal do campo
                   NIL, ;                       // [07] B Code-block de validação do campo
                   {|| .T.}, ;                  // [08] B Code-block de validação When do campo
                   , ;                          // [09] A Lista de valores permitido do campo
                   .F., ;                       // [10] L Indica se o campo tem preenchimento obrigatório
                   {||LoadReQ()}, ;             // [11] B Code-block de inicializacao do campo
                   .F., ;                       // [12] L Indica se trata de um campo chave
                   .T., ;                       // [13] L Indica se o campo pode receber valor em uma operação de update.
                   .T. )                        // [14] L Indica se o campo é virtual
                   
   oStruQUD:AddField( ;                          // Ord. Tipo Desc.
                   STR0013, ;                    // [01] C Titulo do campo
                   STR0014, ;                    // [02] C ToolTip do campo
                   "QUD_FAIXIN", ;               // [03] C identificador (ID) do Field
                   'N' , ;                       // [04] C Tipo do campo
                   TAMSX3("QU4_FAIXIN")[1], ;    // [05] N Tamanho do campo
                   0 , ;                         // [06] N Decimal do campo
                   NIL, ;                        // [07] B Code-block de validação do campo
                   {|| .T.}, ;                   // [08] B Code-block de validação When do campo
                   , ;                           // [09] A Lista de valores permitido do campo
                   .F., ;                        // [10] L Indica se o campo tem preenchimento obrigatório
                   {||LoadFaixin()}, ;           // [11] B Code-block de inicializacao do campo
                   .F., ;                        // [12] L Indica se trata de um campo chave
                   .T., ;                        // [13] L Indica se o campo pode receber valor em uma operação de update.
                   .T. )                         // [14] L Indica se o campo é virtual
                   
   oStruQUD:AddField( ;                          // Ord. Tipo Desc.
                   STR0015, ;                    // [01] C Titulo do campo
                   STR0016, ;                    // [02] C ToolTip do campo
                   "QUD_FAIXFI", ;               // [03] C identificador (ID) do Field
                   'N' , ;                       // [04] C Tipo do campo
                   TAMSX3("QU4_FAIXFI")[1], ;    // [05] N Tamanho do campo
                   0 , ;                         // [06] N Decimal do campo
                   NIL, ;                        // [07] B Code-block de validação do campo
                   {|| .T.}, ;                   // [08] B Code-block de validação When do campo
                   , ;                           // [09] A Lista de valores permitido do campo
                   .F., ;                        // [10] L Indica se o campo tem preenchimento obrigatório
                   {||LoadFaixfi()}, ;           // [11] B Code-block de inicializacao do campo
                   .F., ;                        // [12] L Indica se trata de um campo chave
                   .T., ;                        // [13] L Indica se o campo pode receber valor em uma operação de update.
                   .T. )                         // [14] L Indica se o campo é virtual
   
   oStruQUD:AddField( ;                          // Ord. Tipo Desc.
                   STR0017, ;                    // [01] C Titulo do campo
                   STR0018, ;                    // [02] C ToolTip do campo
                   "QUD_NOTADG", ;               // [03] C identificador (ID) do Field
                   'N' , ;                       // [04] C Tipo do campo
                   TAMSX3("QUD_NOTA")[1], ;      // [05] N Tamanho do campo
                   2 , ;                         // [06] N Decimal do campo
                   {|| VldNotaDg()}, ;           // [07] B Code-block de validação do campo
                   {|| ChkNotaDg()}, ;           // [08] B Code-block de validação When do campo
                   , ;                           // [09] A Lista de valores permitido do campo
                   .F., ;                        // [10] L Indica se o campo tem preenchimento obrigatório
                   {|| QUD->QUD_NOTA}, ;         // [11] B Code-block de inicializacao do campo
                   .F., ;                        // [12] L Indica se trata de um campo chave
                   .F., ;                        // [13] L Indica se o campo pode receber valor em uma operação de update.
                   .T. )                         // [14] L Indica se o campo é virtual
                   
   oStruQUD:AddField( ;                          // Ord. Tipo Desc.
                   STR0019, ;                    // [01] C Titulo do campo
                   STR0020, ;                    // [02] C ToolTip do campo
                   "QUD_NOTAALT", ;              // [03] C identificador (ID) do Field
                   'C' , ;                       // [04] C Tipo do campo
                   1, ;                          // [05] N Tamanho do campo
                    , ;                          // [06] N Decimal do campo
                   NIL, ;                        // [07] B Code-block de validação do campo
                   {|| ChkNotaAlt()}, ;          // [08] B Code-block de validação When do campo
                   , ;                           // [09] A Lista de valores permitido do campo
                   .F., ;                        // [10] L Indica se o campo tem preenchimento obrigatório
                   {|| AprsNtAlt()}, ;           // [11] B Code-block de inicializacao do campo
                   .F., ;                        // [12] L Indica se trata de um campo chave
                   .F., ;                        // [13] L Indica se o campo pode receber valor em uma operação de update.
                   .T. )                         // [14] L Indica se o campo é virtual
                  
   oStruQUD:AddField( ;                         // Ord. Tipo Desc.
                   STR0021, ;                   // [01] C Titulo do campo
                   STR0022, ;                   // [02] C ToolTip do campo
                   "QUD_PESO", ;                // [03] C identificador (ID) do Field
                   'N' , ;                      // [04] C Tipo do campo
                   TAMSX3("QU4_PESO")[1], ;     // [05] N Tamanho do campo
                   2, ;                         // [06] N Decimal do campo
                   NIL, ;                       // [07] B Code-block de validação do campo
                   {|| .T.}, ;                  // [08] B Code-block de validação When do campo
                   , ;                          // [09] A Lista de valores permitido do campo
                   .F., ;                       // [10] L Indica se o campo tem preenchimento obrigatório
                   {|| LoadPeso()}, ;           // [11] B Code-block de inicializacao do campo
                   .F., ;                       // [12] L Indica se trata de um campo chave
                   .T., ;                       // [13] L Indica se o campo pode receber valor em uma operação de update.
                   .T. )                        // [14] L Indica se o campo é virtual

    // Alterações de dicionário necessárias para que a tela normal e a MVC rodem ao mesmo tempo.
    oStruQUB:SetProperty("QUB_NUMAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_NUMAUD" , "ExistChav('QUB',M->QUB_NUMAUD,1,'AUDJAEXIST') .And. QA250chkAg() .And. FreeForUse('QUB',M->QUB_NUMAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_INIAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_INIAUD" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_ENCAUD" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_ENCAUD" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCAUD)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_ENCREA" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_ENCREA" , "Q250VldDat(M->QUB_INIAUD,M->QUB_ENCREA)",.F.,.F. ))
	oStruQUB:SetProperty("QUB_FILMAT" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_FILMAT" , "QVldUsuQUB()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_AUDLID" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_AUDLID" , "QVldUsuQUB()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_CODFOR" , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_CODFOR" , "Q250VldCpo()",.F.,.F. ))
	oStruQUB:SetProperty("QUB_LOJA"   , MODEL_FIELD_VALID, MTBlcVld("QUB", "QUB_LOJA"   , "Q250VldCpo()",.F.,.F. ))
	
	oStruQUD:SetProperty("QUD_NOTA"   , MODEL_FIELD_VALUES, {})
	oStruQUD:SetProperty("QUD_NOTA"   , MODEL_FIELD_VALID, {||.T.})
	
	oStruQUG:SetProperty("QUG_DESC1"  , MODEL_FIELD_INIT, {||If(oModel:GetOperation() == 3,'', MSMM(QUG->QUG_DESCHV))})
	
	oStruQUH:SetProperty("QUH_FILMAT" , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_FILMAT"   , "QVldUsuQUH()",.F.,.F. ))
	oStruQUH:SetProperty("QUH_CODAUD" , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_CODAUD"   , "QVldUsuQUH()",.F.,.F. ))
	oStruQUH:SetProperty("QUH_DTIN"   , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_DTIN"     , "QVldDH('DTIN', M->QUH_DTIN)",.F.,.F. ))
	oStruQUH:SetProperty("QUH_HRIN"   , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_HRIN"     , "QVldDH('HRIN', M->QUH_HRIN)",.F.,.F. ))
	oStruQUH:SetProperty("QUH_DTFI"   , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_DTFI"     , "QVldDH('DTFI', M->QUH_DTFI)",.F.,.F. ))
	oStruQUH:SetProperty("QUH_HRFI"   , MODEL_FIELD_VALID, MTBlcVld("QUH", "QUH_HRFI"     , "QVldDH('HRFI', M->QUH_HRFI)",.F.,.F. ))
	
	oStruQUH:SetProperty("QUH_DESTIN" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUH:SetProperty("QUH_FILMAT" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUH:SetProperty("QUH_CODAUD" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUH:SetProperty("QUH_CCUSTO" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUH:SetProperty("QUH_CONFID" , MODEL_FIELD_WHEN, {||.T.})
	
	oStruQUJ:SetProperty("QUJ_CHKITE" , MODEL_FIELD_VALID, MTBlcVld("QUJ", "QUJ_CHKITE"   , "naovazio()",.F.,.F. ))
	oStruQUJ:SetProperty("QUJ_CHKLST" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUJ:SetProperty("QUJ_REVIS"  , MODEL_FIELD_WHEN, {||.T.})
	oStruQUJ:SetProperty("QUJ_CHKITE" , MODEL_FIELD_WHEN, {||.T.})
	oStruQUJ:SetProperty("QUJ_NIVEL"  , MODEL_FIELD_WHEN, {||.T.})
	
	// Desativando as triggers da SX7 para não ocorrer conflito.
	For nX:=1 To Len(oStruQUJ:aTriggers)
		oStruQUJ:aTriggers[nX][3] := {|| .F. }
	Next nX
    //-----------------------------

	oModel:AddFields( 'QUBMASTER', /*cOwner*/, oStruQUB , , )
	oModel:AddGrid( 'QUHDETAIL'  ,'QUBMASTER', oStruQUH , , )
	oModel:AddGrid( 'QUJDETAIL'  ,'QUHDETAIL', oStruQUJ , , )
	oModel:AddGrid( 'QUDDETAIL'  ,'QUJDETAIL', oStruQUD , , {|oModelQUD| QUDLNOK(oModelQUD)})
	oModel:AddGrid( 'QUGDETAIL'  ,'QUDDETAIL', oStruQUG , , {|oModelQUG| QUGLNOK(oModelQUG)} )
	
	oModel:SetPrimaryKey( {} ) 
	oModel:SetRelation("QUHDETAIL", {{"QUH_FILIAL",'xFilial("QUH")'},{"QUH_NUMAUD","QUB_NUMAUD"}},QUH->(IndexKey(1)))
	oModel:SetRelation("QUJDETAIL", {{"QUJ_FILIAL",'xFilial("QUJ")'},{"QUJ_NUMAUD","QUH_NUMAUD"},{"QUJ_SEQ","QUH_SEQ"}},QUJ->(IndexKey(1)))
	oModel:SetRelation("QUDDETAIL", {{"QUD_FILIAL",'xFilial("QUD")'},{"QUD_NUMAUD","QUJ_NUMAUD"},{"QUD_SEQ","QUJ_SEQ"},{"QUD_CHKLST","QUJ_CHKLST"},{"QUD_REVIS","QUJ_REVIS"},{"QUD_CHKITE","QUJ_CHKITE"}},QUD->(IndexKey(1)))
	oModel:SetRelation("QUGDETAIL", {{"QUG_FILIAL",'xFilial("QUG")'},{"QUG_NUMAUD","QUD_NUMAUD"},{"QUG_SEQ","QUD_SEQ"},{"QUG_CHKLST","QUD_CHKLST"},{"QUG_REVIS","QUD_REVIS"},{"QUG_CHKITE","QUD_CHKITE"},{"QUG_QSTITE","QUD_QSTITE"}},QUG->(IndexKey(2)))
	
	oModel:SetDescription(STR0001)
	oModel:GetModel( 'QUBMASTER'  ):SetDescription(STR0023)
	oModel:GetModel( 'QUHDETAIL'  ):SetDescription(STR0024)
	oModel:GetModel( 'QUJDETAIL'  ):SetDescription(STR0025)
	oModel:GetModel( 'QUDDETAIL'  ):SetDescription(STR0026)
	oModel:GetModel( 'QUGDETAIL'  ):SetDescription(STR0027)
	
	oStruQUB:SetProperty("QUB_ENCREA", MODEL_FIELD_OBRIGAT, .F.)
	oStruQUB:SetProperty("QUB_STATUS", MODEL_FIELD_WHEN, {||.T.})
	oStruQUB:SetProperty("QUB_CONCLU", MODEL_FIELD_OBRIGAT, .F.) 
	
	oStruQUD:SetProperty("QUD_EVIDE1", MODEL_FIELD_INIT,{||MsMM(QUD->QUD_EVICHV, TamSX3("QUD_EVICHV")[1])}) 
	
	oStruQUD:AddTrigger("QUD_NOTADG", "QUD_NOTA"   , {||.T.}, {|oModelQUD| LoadNota(oModelQUD)})
	oStruQUD:AddTrigger("QUD_NOTAALT","QUD_NOTA"   , {||.T.}, {|oModelQUD| LoadNota(oModelQUD)})

	FWMemoVirtual(oStruQUD, {{'QUD_EVICHV','QUD_EVIDE1'}}) 
	FWMemoVirtual(oStruQUG, {{'QUG_DESCHV','QUG_DESC1'}})
	
	oModel:GetModel( 'QUGDETAIL' ):SetOptional(.T.) 
	oModel:GetModel( 'QUGDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'QUDDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'QUDDETAIL' ):SetNoDeleteLine(.T.)
	
Return oModel
//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Bratti
@since 24/08/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( 'QADA251' )
	Local oStruQUB  := FWFormStruct(2,"QUB",{|cCampo| ALLTRIM(cCampo) $ "QUB_NUMAUD|QUB_INIAUD|QUB_ENCAUD|QUB_MOTAUD|QUB_DSCMOT|QUB_TIPAUD"})
	Local oStruQUH  := FWFormStruct(2,'QUH')	 
	Local oStruQUJ  := FWFormStruct(2,'QUJ',{|cCampo| ALLTRIM(cCampo) $ "QUJ_CHKLST|QUJ_REVIS|QUJ_CHKITE|QUJ_NIVEL"})
	Local oStruQUD  := FWFormStruct(2,'QUD',{|cCampo| ALLTRIM(cCampo) $ "QUD_QSTITE|QUD_APLICA|QUD_EVIDE1"})
	Local oStruQUG  := FWFormStruct(2,'QUG',{|cCampo| ALLTRIM(cCampo) $ "QUG_ITESEQ|QUG_OCORNC|QUG_ACACOR|QUG_PRAZO|QUG_CATEG|QUG_DESC1"})
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )

	oStruQUD:AddField( ;                                // Ord. Tipo Desc.
	                   "QUD_TXTQ" , ;                   // [01] C Nome do Campo
	                   "04" , ;                         // [02] C Ordem
	                   STR0007 , ;                      // [03] C Titulo do campo
	                   STR0008 , ;                      // [04] C Descrição do campo
	                   { STR0008 } , ;                  // [05] A Array com Help
	                   'M' , ;                          // [06] C Tipo do campo
	                   '' , ;                           // [07] C Picture
	                   NIL , ;                          // [08] B Bloco de Picture Var
	                   '' , ;                           // [09] C Consulta F3
	                   .T. , ;                          // [10] L Indica se o campo é editável
	                   NIL , ;                          // [11] C Pasta do campo
	                   NIL , ;                          // [12] C Agrupamento do campo
	                   Nil , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                          // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                          // [15] C Inicializador de Browse
	                   .T. , ;                          // [16] L Indica se o campo é virtual
	                   NIL )                            // [17] C Picture Variável
	                   
	oStruQUD:AddField( ;                                // Ord. Tipo Desc.
	                   "QUD_TXTOBS" , ;                 // [01] C Nome do Campo
	                   "05" , ;                         // [02] C Ordem
	                   STR0009 , ;                      // [03] C Titulo do campo
	                   STR0010 , ;                      // [04] C Descrição do campo
	                   { STR0010 } , ;                  // [05] A Array com Help
	                   'M' , ;                          // [06] C Tipo do campo
	                   '' , ;                           // [07] C Picture
	                   NIL , ;                          // [08] B Bloco de Picture Var
	                   '' , ;                           // [09] C Consulta F3
	                   .T. , ;                          // [10] L Indica se o campo é editável
	                   NIL , ;                          // [11] C Pasta do campo
	                   NIL , ;                          // [12] C Agrupamento do campo
	                   Nil , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                          // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                          // [15] C Inicializador de Browse
	                   .T. , ;                          // [16] L Indica se o campo é virtual
	                   NIL )                            // [17] C Picture Variável
	                   
	oStruQUD:AddField( ;                                // Ord. Tipo Desc.
	                   "QUD_TXTREQ" , ;                 // [01] C Nome do Campo
	                   "06" , ;                         // [02] C Ordem
	                   STR0011, ;                       // [03] C Titulo do campo
	                   STR0012 , ;                      // [04] C Descrição do campo
	                   { STR0012 } , ;                  // [05] A Array com Help
	                   'M' , ;                          // [06] C Tipo do campo
	                   '' , ;                           // [07] C Picture
	                   NIL , ;                          // [08] B Bloco de Picture Var
	                   '' , ;                           // [09] C Consulta F3
	                   .T. , ;                          // [10] L Indica se o campo é editável
	                   NIL , ;                          // [11] C Pasta do campo
	                   NIL , ;                          // [12] C Agrupamento do campo
	                   Nil , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                          // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                          // [15] C Inicializador de Browse
	                   .T. , ;                          // [16] L Indica se o campo é virtual
	                   NIL )                            // [17] C Picture Variável
	                   
	oStruQUD:AddField( ;                                // Ord. Tipo Desc.
	                   "QUD_FAIXIN" , ;                 // [01] C Nome do Campo
	                   "07" , ;                         // [02] C Ordem
	                   STR0013 , ;                      // [03] C Titulo do campo
	                   STR0014 , ;                      // [04] C Descrição do campo
	                   {STR0014} , ;                    // [05] A Array com Help
	                   'N' , ;                          // [06] C Tipo do campo
	                   PesqPict("QU4","QU4_FAIXIN") , ; // [07] C Picture
	                   NIL , ;                          // [08] B Bloco de Picture Var
	                   '' , ;                           // [09] C Consulta F3
	                   .T. , ;                          // [10] L Indica se o campo é editável
	                   NIL , ;                          // [11] C Pasta do campo
	                   NIL , ;                          // [12] C Agrupamento do campo
	                   Nil , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                          // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                          // [15] C Inicializador de Browse
	                   .T. , ;                          // [16] L Indica se o campo é virtual
	                   NIL )                            // [17] C Picture Variável
	                   
	oStruQUD:AddField( ;                                // Ord. Tipo Desc.
	                   "QUD_FAIXFI" , ;                 // [01] C Nome do Campo
	                   "08" , ;                         // [02] C Ordem
	                   STR0015 , ;                      // [03] C Titulo do campo
	                   STR0016 , ;                      // [04] C Descrição do campo
	                   {STR0016} , ;                    // [05] A Array com Help
	                   'N' , ;                          // [06] C Tipo do campo
	                   PesqPict("QU4","QU4_FAIXFI") , ; // [07] C Picture
	                   NIL , ;                          // [08] B Bloco de Picture Var
	                   '' , ;                           // [09] C Consulta F3
	                   .T. , ;                          // [10] L Indica se o campo é editável
	                   NIL , ;                          // [11] C Pasta do campo
	                   NIL , ;                          // [12] C Agrupamento do campo
	                   Nil , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                          // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                          // [15] C Inicializador de Browse
	                   .T. , ;                          // [16] L Indica se o campo é virtual
	                   NIL )                            // [17] C Picture Variável
	  
	oStruQUD:AddField( ;                                // Ord. Tipo Desc.
	                   "QUD_NOTADG" , ;                 // [01] C Nome do Campo
	                   "10" , ;                         // [02] C Ordem
	                   STR0028 , ;                      // [03] C Titulo do campo
	                   STR0029 , ;                      // [04] C Descrição do campo
	                   {STR0030} , ;                    // [05] A Array com Help
	                   'N' , ;                          // [06] C Tipo do campo
	                   PesqPict("QUD","QUD_NOTA") , ;   // [07] C Picture
	                   NIL , ;                          // [08] B Bloco de Picture Var
	                   '' , ;                           // [09] C Consulta F3
	                   .T. , ;                          // [10] L Indica se o campo é editável
	                   NIL , ;                          // [11] C Pasta do campo
	                   NIL , ;                          // [12] C Agrupamento do campo
	                   Nil , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                          // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                          // [15] C Inicializador de Browse
	                   .T. , ;                          // [16] L Indica se o campo é virtual
	                   NIL )                            // [17] C Picture Variável
	                   
	oStruQUD:AddField( ;                                       // Ord. Tipo Desc.
	                   "QUD_NOTAALT" , ;                       // [01] C Nome do Campo
	                   "11" , ;                                // [02] C Ordem
	                   STR0031, ;                              // [03] C Titulo do campo
	                   STR0032, ;                              // [04] C Descrição do campo
	                   {STR0033} , ;                           // [05] A Array com Help
	                   'C' , ;                                 // [06] C Tipo do campo
	                   '@!' , ;                                // [07] C Picture
	                   NIL , ;                                 // [08] B Bloco de Picture Var
	                   '' , ;                                  // [09] C Consulta F3
	                   .T. , ;                                 // [10] L Indica se o campo é editável
	                   NIL , ;                                 // [11] C Pasta do campo
	                   NIL , ;                          		   // [12] C Agrupamento do campo
	                   {'1=Sim','2=Não','3=Não Informado'} , ; // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                                 // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                                 // [15] C Inicializador de Browse
	                   .T. , ;                                 // [16] L Indica se o campo é virtual
	                   NIL )                                   // [17] C Picture Variável
	                   
	oStruQUD:AddField( ;                                       // Ord. Tipo Desc.
	                   "QUD_PESO" , ;                          // [01] C Nome do Campo
	                   "09" , ;                                // [02] C Ordem
	                   STR0021 , ;                             // [03] C Titulo do campo
	                   STR0022 , ;                             // [04] C Descrição do campo
	                   {STR0022} , ;                           // [05] A Array com Help
	                   'N' , ;                                 // [06] C Tipo do campo
	                   PesqPict("QUD","QUD_NOTA") , ;          // [07] C Picture
	                   NIL , ;                                 // [08] B Bloco de Picture Var
	                   '' , ;                                  // [09] C Consulta F3
	                   .T. , ;                                 // [10] L Indica se o campo é editável
	                   NIL , ;                                 // [11] C Pasta do campo
	                   NIL , ;                          		   // [12] C Agrupamento do campo
	                   Nil , ;                                 // [13] A Lista de valores permitido do campo (Combo)
	                   NIL , ;                                 // [14] N Tamanho Máximo da maior opção do combo
	                   NIL , ;                                 // [15] C Inicializador de Browse
	                   .T. , ;                                 // [16] L Indica se o campo é virtual
	                   NIL )                                   // [17] C Picture Variável
               
	oView:AddField('VIEW_QUB',  oStruQUB,  'QUBMASTER' )
	oView:AddGrid( 'VIEW_QUH',  oStruQUH,  'QUHDETAIL' )
	oView:AddGrid( 'VIEW_QUJ',  oStruQUJ,  'QUJDETAIL' )
	oView:AddGrid( 'VIEW_QUD',  oStruQUD,  'QUDDETAIL' )
	oView:AddGrid( 'VIEW_QUG',  oStruQUG,  'QUGDETAIL' )
	
	oStruQUB:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
	
	oStruQUB:SetProperty( 'QUB_NUMAUD' , MVC_VIEW_ORDEM, '01' )
	oStruQUB:SetProperty( 'QUB_INIAUD' , MVC_VIEW_ORDEM, '02' )
	oStruQUB:SetProperty( 'QUB_ENCAUD' , MVC_VIEW_ORDEM, '03' )
	oStruQUB:SetProperty( 'QUB_MOTAUD' , MVC_VIEW_ORDEM, '04' )
	oStruQUB:SetProperty( 'QUB_DSCMOT' , MVC_VIEW_ORDEM, '05' )
	oStruQUB:SetProperty( 'QUB_TIPAUD' , MVC_VIEW_ORDEM, '06' )

	oStruQUD:SetProperty( 'QUD_QSTITE' , MVC_VIEW_ORDEM, '01' )
	oStruQUD:SetProperty( 'QUD_APLICA' , MVC_VIEW_ORDEM, '02' )	
	oStruQUD:SetProperty( 'QUD_EVIDE1' , MVC_VIEW_ORDEM, '03' )
	
	oView:CreateHorizontalBox( 'SUPERIOR', 17 )
	oView:CreateHorizontalBox( 'MEIOSUP',  23 )
	oView:CreateHorizontalBox( 'MEIOINF',  23 )
	oView:CreateHorizontalBox( 'INFERIOR', 37 )
	
	oView:CreateVerticalBox( 'VTMEIOSUP'       , 100      ,'MEIOSUP'  )
	oView:CreateVerticalBox( 'VTMEIOINF'       , 100      ,'MEIOINF'  )
	oView:CreateVerticalBox( 'VTINFERIOR'       , 100     ,'INFERIOR' )
	
	oView:CreateFolder( 'FDAREA','VTMEIOSUP' )		
	oView:AddSheet( 'FDAREA', 'ABA01',STR0024)
	oView:CreateHorizontalBox( 'HBAREAUD'     , 100    , , , 'FDAREA' , 'ABA01' )
	
	oView:CreateFolder( 'FDCHK','VTMEIOINF' )		
	oView:AddSheet( 'FDCHK', 'ABA01',STR0034)	
	oView:CreateHorizontalBox( 'HBCHK'     , 100    , , , 'FDCHK' , 'ABA01' )

	oView:CreateFolder( 'FDPERG','VTINFERIOR' )		
	oView:AddSheet( 'FDPERG', 'ABA01',STR0026)
	oView:AddSheet( 'FDPERG', 'ABA02',STR0027)	
	oView:CreateHorizontalBox( 'HBPERG'     , 100    , , , 'FDPERG' , 'ABA01' )
	oView:CreateHorizontalBox( 'HBNNC'     , 100    , , ,  'FDPERG' , 'ABA02' )

	oView:SetViewProperty('VIEW_QUH' , 'ONLYVIEW' )
	oView:SetViewProperty('VIEW_QUJ' , 'ONLYVIEW' )		
	oView:SetNoInsertLine('VIEW_QUH')
	oView:SetNoDeleteLine('VIEW_QUH')
	oView:SetNoInsertLine('VIEW_QUJ')
	oView:SetNoDeleteLine('VIEW_QUJ')
		
	
	oView:SetOwnerView( 'VIEW_QUB' , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_QUH' , 'HBAREAUD' )
	oView:SetOwnerView( 'VIEW_QUJ' , 'HBCHK'    )
	oView:SetOwnerView( 'VIEW_QUD' , 'HBPERG'   )
	oView:SetOwnerView( 'VIEW_QUG' , 'HBNNC'    )
	
	oView:AddIncrementField( 'VIEW_QUG', 'QUG_ITESEQ' )	

	oView:AddUserButton( 'Auditoria','MAGIC_BMP', {|| FWExecView ('Auditoria', "QADA250", MODEL_OPERATION_VIEW) } )
Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadTxtQ()
Retorna o texto da questão da tabela de questionário.
@author Leonardo Bratti
@since 02/09/2017
@version 1.0
@return cMsg
/*/
//--------------------------------------------------------------------
Static Function LoadTxtQ()
	Local cMsg       := " "
	Local cChave     := " "
	
	If !Empty(QUD->QUD_CHKLST) 
		If QUD_TIPO == '1'
			cChave := xFilial("QU4")+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			cMsg   := MsMM(Posicione("QU4",1,cChave,"QU4_TXTCHV"), TamSX3("QU4_TXTQS1")[1])
		Else 
			cChave := xFilial("QUE")+QUD->QUD_NUMAUD+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			cMsg   := MsMM(Posicione("QUE",1,cChave,"QUE_TXTCHV"), TamSX3("QUE_TXTQS1")[1])
		EndIf
	EndIf
	
Return cMsg

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadObsQ()
Retorna a observação da questão da tabela de questionário.
@author Leonardo Bratti
@since 02/09/2017
@version 1.0
@return cMsg
/*/
//--------------------------------------------------------------------
Static Function LoadObsQ()
	Local cMsg       := " "
	Local cChave     := " "
	
	If !Empty(QUD->QUD_CHKLST) 		
		If QUD_TIPO == '1'		
			cChave  := xFilial("QU4")+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			cMsg    := MsMM(Posicione("QU4",1,cChave,"QU4_OBSCHV"), TamSX3("QU4_OBSER1")[1])
		Else
			cChave  := xFilial("QUE")+QUD->QUD_NUMAUD+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			cMsg    := MsMM(Posicione("QUE",1,cChave,"QUE_OBSCHV"), TamSX3("QUE_OBSER1")[1])
		EndIf
	EndIf
	
Return cMsg

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadReQ()
Retorna o requisisto da questão da tabela de questionário.
@author Leonardo Bratti
@since 02/09/2017
@version 1.0
@return cMsg
/*/
//--------------------------------------------------------------------
Static Function LoadReQ()
	Local cMsg       := " "
	Local cChave     := " "
	
	If !Empty(QUD->QUD_CHKLST) 		
		If QUD_TIPO == '1'
			cChave := xFilial("QU4")+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			cMsg   := MsMM(Posicione("QU4",1,cChave,"QU4_REQCHV"), TamSX3("QU4_REQQS1")[1])
		Else
			cChave := xFilial("QUE")+QUD->QUD_NUMAUD+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			cMsg   := MsMM(Posicione("QUE",1,cChave,"QUE_REQCHV"), TamSX3("QUE_REQQS1")[1])
		EndIf
	EndIf
	
Return cMsg

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadFaixin()
Retorna a faixa inicial da questão da tabela de questionário.
@author Leonardo Bratti
@since 02/09/2017
@version 1.0
@return nNum
/*/
//--------------------------------------------------------------------
Static Function LoadFaixin()
	Local nNum       := 0
	Local cChave     := " "
	
	If !Empty(QUD->QUD_CHKLST) 		
		If QUD_TIPO == '1'
			cChave := xFilial("QU4")+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			nNum   := Posicione("QU4",1,cChave,"QU4_FAIXIN")			
		Else
			cChave := xFilial("QUE")+QUD->QUD_NUMAUD+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			nNum   := Posicione("QUE",1,cChave,"QUE_FAIXIN")
		EndIf
	EndIf
	
Return nNum

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadFaixfi()
Retorna a faixa final da questão da tabela de questionário.
@author Leonardo Bratti
@since 02/09/2017
@version 1.0
@return nNum
/*/
//--------------------------------------------------------------------
Static Function LoadFaixfi()
	Local nNum       := 0
	Local cChave     := " "
	
	If !Empty(QUD->QUD_CHKLST)		
		If QUD_TIPO == '1'
			cChave  := xFilial("QU4")+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			nNum    := Posicione("QU4",1,cChave,"QU4_FAIXFI")
		Else
			cChave  := xFilial("QUE")+QUD->QUD_NUMAUD+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			nNum    := Posicione("QUE",1,cChave,"QUE_FAIXFI")
		EndIf
	EndIf
	
Return nNum

//--------------------------------------------------------------------
/*/{Protheus.doc} ChkNotaDg()
Verifica se o a questão pode ter sua nota digitada
@author Leonardo Bratti
@since 07/09/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function ChkNotaDg()
	Local oModel     := FWModelActive()
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local oModelQUD  := oModel:GetModel("QUDDETAIL")
	Local cChave     :=  "" 
	Local lRet       := .F.
	
	If oModelQUD:GetValue("QUD_TIPO") == '1'
		cChave := xFilial("QU4")+oModelQUD:GetValue("QUD_CHKLST")+oModelQUD:GetValue("QUD_REVIS")+oModelQUD:GetValue("QUD_CHKITE")+oModelQUD:GetValue("QUD_QSTITE")
		lRet   := Posicione("QU4",1,cChave,"QU4_USAALT") == "2" 
	Else
		cChave := xFilial("QUE")+oModelQUD:GetValue("QUD_NUMAUD")+oModelQUD:GetValue("QUD_CHKLST")+oModelQUD:GetValue("QUD_REVIS")+oModelQUD:GetValue("QUD_CHKITE")+oModelQUD:GetValue("QUD_QSTITE")
		lRet   := Posicione("QUE",1,cChave,"QUE_USAALT") == "2" 
	Endif	
	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ChkNotaAlt()
Verifica se o a questão pode ser seleciona 
@author Leonardo Bratti
@since 07/09/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function ChkNotaAlt()
	Local oModel     := FWModelActive()
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local oModelQUD  := oModel:GetModel("QUDDETAIL")
	Local cChave     :=  xFilial("QU4")+oModelQUD:GetValue("QUD_CHKLST")+oModelQUD:GetValue("QUD_REVIS")+oModelQUD:GetValue("QUD_CHKITE")+oModelQUD:GetValue("QUD_QSTITE")
	Local lRet       := .F.
		
	If oModelQUD:GetValue("QUD_TIPO") == '1'
		cChave := xFilial("QU4")+oModelQUD:GetValue("QUD_CHKLST")+oModelQUD:GetValue("QUD_REVIS")+oModelQUD:GetValue("QUD_CHKITE")+oModelQUD:GetValue("QUD_QSTITE")
		lRet   := Posicione("QU4",1,cChave,"QU4_USAALT") == "1" 
	Else
		cChave := xFilial("QUE")+oModelQUD:GetValue("QUD_NUMAUD")+oModelQUD:GetValue("QUD_CHKLST")+oModelQUD:GetValue("QUD_REVIS")+oModelQUD:GetValue("QUD_CHKITE")+oModelQUD:GetValue("QUD_QSTITE")
		lRet   := Posicione("QUE",1,cChave,"QUE_USAALT") == "1" 
	Endif
	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} Q251Resul()
Confirma os resultado da auditoria
@author Leonardo Bratti
@since 07/09/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function Q251Resul()
	Local lRet := .T.
	Local aUsrMat	:= QA_USUARIO() 
	
	If Empty(QUB->QUB_ENCREA)
		If !QADCkAudit(QUB->QUB_NUMAUD) 
			lRet := .F. 
		EndIf
		dbSelectArea("QUJ")
		dbSetOrder(1)
		If !dbSeek(xFilial("QUJ") + QUB->QUB_NUMAUD)
			Help(" ",1,"QUFNEXIST")
			lRet := .F. 
		Endif
	Else
		Help(" ",1,"AUDITENC")
		lRet := .F.			
	EndIf

	If lRet
	 FWExecView (STR0001, "QADA251", MODEL_OPERATION_UPDATE,,{||.T.}) 
	EndIf
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} VldNotaDg()
Verifica se a nota se encontra na faixa cadastrada
@author Leonardo Bratti
@since 14/09/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function VldNotaDg()
	Local oModel     := FWModelActive()
	Local oModelQUD  := oModel:GetModel("QUDDETAIL")
	Local nNota := 0
	Local lRet  := .T.
	
	If !(ChkNotaAlt())	
		nNota:= oModelQUD:GetValue("QUD_NOTADG")
		If nNota < oModelQUD:GetValue("QUD_FAIXIN") .or. nNota > oModelQUD:GetValue("QUD_FAIXFI")
			Help( , , 'Help', ,STR0035, 1, 0 )
			lRet := .F.
		EndIf
	Endif
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} QUDLNOK()
Validação de linha da QUD
@author Leonardo Bratti
@since 14/09/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function QUDLNOK(oModelQUD)
	Local lRet := .T.
	Local lEvid := Empty(oModelQUD:GetValue("QUD_EVIDE1")) 
	
	If !lDel
		If oModelQUD:GetValue("QUD_NOTA") == 0 .And. !(lEvid)
			Help( , , 'Help', ,STR0036, 1, 0 )
			lRet := .F.					
		ElseIf oModelQUD:GetValue("QUD_NOTA") > 0 .And. lEvid
			Help( , , 'Help', ,STR0037, 1, 0 )
			lRet := .F.	
		EndIf
	EndIf

Return lRet 

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadNota(oModelQUD)
Carrega o valor do campo QUD_NOTA
@author Leonardo Bratti
@since 14/09/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
Static Function LoadNota(oModelQUD)
	Local nNota
	Local cValor := ''
	
	If ChkNotaAlt()
		cValor := oModelQUD:GetValue("QUD_NOTAALT")
			If cValor == '1'
				nNota := oModelQUD:GetValue("QUD_FAIXFI")
			Else
				nNota := IIF(cValor == '2',oModelQUD:GetValue("QUD_FAIXIN") , 0 )
			EndIf			
		oModelQUD:SetValue("QUD_NOTA",nNota)
	Else
		nNota := oModelQUD:GetValue("QUD_NOTADG")
		oModelQUD:SetValue("QUD_NOTA",nNota) 
	EndIf	
Return nNota
//--------------------------------------------------------------------
/*/{Protheus.doc} A251Grv()
Realiza a gravação do resultado
@author Leonardo Bratti
@since 15/09/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
Static Function A251Grv()
	Local oModel     := FWModelActive()
	Local aSaveLines := FWSaveRows()
	Local oModelQUB  := oModel:GetModel('QUBMASTER')
	Local oModelQUD  := oModel:GetModel('QUDDETAIL')
	Local oModelQUH  := oModel:GetModel('QUHDETAIL')
	Local oModelQUJ  := oModel:GetModel('QUJDETAIL')
	Local lQstZer    := SuperGetMv("MV_QADQZER",.T.,.T.)
	Local lRet 	     := .T.
	Local nPONOBT    := 0
	Local nMin       := 0
	Local nMax       := 0
	Local nPeso      := 0
	Local nPontos    := 0
	Local nPesoTotal := 0
	Local nSemAval   := 0
	Local nConAval   := 0
	Local nI         := 0
	Local nX         := 0
	Local nY         := 0
	Local lEvid      := .F.
	
	If lDel == .F.
		For nX := 1 To oModelQUH:Length()
			oModelQUH:GoLine( nX )
			For nY := 1 To oModelQUJ:Length()
				oModelQUJ:GoLine( nY )
				For nI := 1 To oModelQUD:Length()
					oModelQUD:GoLine( nI )
					If !(oModelQUD:IsDeleted())
						If oModelQUD:GetValue("QUD_APLICA") == '2'
							Loop
						EndIf		
						
						If !(Empty(oModelQUD:GetValue("QUD_EVIDE1")))
							oModelQUD:SetValue("QUD_DTAVAL",dDataBase)
						EndIf
							
						nMin    := oModelQUD:GetValue("QUD_FAIXIN")
						nMax    := oModelQUD:GetValue("QUD_FAIXFI")
						nPeso   := If( oModelQUD:GetValue("QUD_PESO")==0, 1 , oModelQUD:GetValue("QUD_PESO"))
						lAltern := ChkNotaAlt()
						
						nNota := oModelQUD:GetValue("QUD_NOTA")
		
						If lQstZer .And. lAltern
							If nNota == nMin
								nNota := 0
							EndIf	
						Endif				
						nSemAval   += If(Empty(oModelQUD:GetValue("QUD_DTAVAL")), 1, 0)
						nPontos    += (((nNota * nPeso)*100)/nMax)
						nPesoTotal += (nPeso)
						nConAval++
					EndIf
				Next nI
			Next nY
		Next nX
		FWRestRows( aSaveLines )
		
		If nSemAval > 0	
			If nConAval == nSemAval
				oModelQUB:LoadValue("QUB_STATUS","1")
			Else
				oModelQUB:LoadValue("QUB_STATUS","2")
			Endif
		Else
			oModelQUB:LoadValue("QUB_STATUS","3")
			nPONOBT := nPontos / nPesoTotal
		Endif	
		
		oModelQUB:LoadValue("QUB_PONOBT",nPONOBT)
		oModelQUB:LoadValue("QUB_PONPOS",QADSomPon(QUB->QUB_NUMAUD))
	EndIf
	
	FwFormCommit(oModel)
	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadPeso()
Retorna o peso da questão 
@author Leonardo Bratti
@since 15/09/2017
@version 1.0
@return nNum
/*/
//--------------------------------------------------------------------
Static Function LoadPeso()
	Local oModel     := FWModelActive()
	Local oModelQUB  := oModel:GetModel("QUBMASTER")
	Local oModelQUD  := oModel:GetModel("QUDDETAIL")
	Local nNum       := 0
	Local cChave     := " "
	
	If !Empty(QUD->QUD_CHKLST)		
		If QUD_TIPO == '1'
			cChave  := xFilial("QU4")+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			nNum    := Posicione("QU4",1,cChave,"QU4_PESO")
		Else
			cChave  := xFilial("QUE")+QUD->QUD_NUMAUD+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE
			nNum    := Posicione("QUE",1,cChave,"QUE_PESO")
		EndIf
	EndIf
	
Return nNum

//--------------------------------------------------------------------
/*/{Protheus.doc} AprsNtAlt()
Retorna o valor da nota para o campo virtual QUD_NOTAALT 
@author Leonardo Bratti
@since 15/09/2017
@version 1.0
@return nNum
/*/
//--------------------------------------------------------------------
Static Function AprsNtAlt()
	Local nNota      := 0
	Local nMax       := 0
	Local nNotaIN    := SuperGetMv("MV_QADININ",.T.,3) 
	If !Empty(QUD->QUD_CHKLST)
		
		nNota := QUD->QUD_NOTA
		nMax  := LoadFaixfi()		
		If nNota == 0
			nNota := nNotaIN
		Else
			nNota := IIF(nNota == nMax , 1 , 2)  
		EndIf	
				
	EndIf
Return nNota

//--------------------------------------------------------------------
/*/{Protheus.doc} QUGLNOK()
Validação de linha da QUG
@author Leonardo Bratti
@since 14/09/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function QUGLNOK(oModelQUG)
	Local lRet   := .T.
	Local lDesc  := Empty(oModelQUG:GetValue("QUG_DESC1")) 
	Local lPrazo := oModelQUG:GetValue("QUG_PRAZO") == 0
	Local lAcao  := Empty(oModelQUG:GetValue("QUG_ACACOR"))
	Local cMsg   := ""
	
	If !lDel
		If lDesc .Or. lPrazo .Or. lAcao
			If lDesc
				lRet := .F.
				cMsg := STR0038
			ElseIf lPrazo
				lRet := .F.
				cMsg := STR0039
			ElseIf lAcao
				lRet := .F.
				cMsg := STR0040
			EndIf			
			Help( , , 'Help', ,cMsg, 1, 0 )
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} Q251Excl()
Exclui os resultados.
@author Luiz Henrique Bourscheid
@since 09/07/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function Q251Excl()
	Local lRet := .T.
	
	lDel := .T.

	If ! Empty(QUB->QUB_ENCREA)
		Help(" ",1,"AUDITENC")	
		lRet := .F.
	Endif	
	
	IF QUB->QUB_STATUS=="1"  
        Help(" ",1,"Q130SEMRES")  //Auditoria sem resultado.     
		lRet := .F.
	Endif
	
	If lRet
		FWExecView (STR0003, "QADA251", MODEL_OPERATION_UPDATE,,{||.T.}, {||Q251AtForm()}) 
	EndIf


Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} Q251AtForm()
Prepara o modelo para exclusão dos resultados.
@author Luiz Henrique Bourscheid
@since 09/07/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static Function Q251AtForm()
	Local nSemAval  := 0
	Local nConAval  := 0  
	Local nX
	Local nY
	Local oModel    := FWModelActive()
	Local oModelQUB := oModel:GetModel("QUBMASTER")
	Local oModelQUD := oModel:GetModel("QUDDETAIL")
	Local oModelQUG := oModel:GetModel("QUGDETAIL")
	Local oModelQUH := oModel:GetModel("QUHDETAIL")
	Local oView     := FwViewActive()
	
	For nY := 1 To oModelQUH:Length()
		oModelQUH:GoLine( nY )
		For nX := 1 To oModelQUD:Length()	
			oModelQUD:GoLine( nX )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao-conformidades associadas								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QUG->(dbSetOrder(2))
			IF QUG->(dbSeek(xFilial("QUG")+QUB->QUB_NUMAUD+QUD->QUD_SEQ+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE))
				While QUG->(!Eof()) .And. xFilial("QUG")+QUB->QUB_NUMAUD+QUD->QUD_SEQ+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE == ;
					QUG->QUG_FILIAL+QUG->QUG_NUMAUD+QUG->QUG_SEQ+QUG->QUG_CHKLST+QUG->QUG_REVIS+QUG->QUG_CHKITE+QUG->QUG_QSTITE
					MSMM(QUG->QUG_DESCHV ,,,,2)
					RecLock("QUG",.F.)
					QUG->(dbDelete())
					MsUnlock()
					FKCommit()
					QUG->(dbSkip())
				EndDo
			Endif
			
			oModelQUD:LoadValue("QUD_NOTA", 0)
			oModelQUD:LoadValue("QUD_DTAVAL", CTOD(SPACE(8)))
			oModelQUD:LoadValue("QUD_EVICHV", "")
			oModelQUD:LoadValue("QUD_EVIDE1", "")
			nSemAval += If(Empty(oModelQUD:GetValue("QUD_DTAVAL")), 1, 0)
			nConAval++
		Next nX
	Next nY
	
	If nSemAval > 0
		IF nConAval == nSemAval
			oModelQUB:LoadValue("QUB_STATUS", "1")
			oModelQUB:LoadValue("QUB_PONOBT", 0)
			oModelQUB:LoadValue("QUB_PONPOS", QADSomPon(QUB->QUB_NUMAUD)) //Grava a pontuacao maxima na Auditoria
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Resultados Parcialmente Respondido   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oModelQUB:LoadValue("QUB_STATUS", "2")
			oModelQUB:LoadValue("QUB_PONOBT", 0)
			oModelQUB:LoadValue("QUB_PONPOS", QADSomPon(QUB->QUB_NUMAUD)) //Grava a pontuacao maxima na Auditoria
		Endif
	Endif
	
	oModel:lModify := .T.
	oView:SetModified(.T.)
	oView:Refresh()
Return .T.